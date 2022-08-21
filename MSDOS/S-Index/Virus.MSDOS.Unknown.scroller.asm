; Resident program to provide flicker-free write_tty scroll for Color
;  Graphics Adapter clones with dual-ported memory.  M. Abrash 5/3/86.
; Make runnable with MASM-LINK-EXE2BIN.
cseg	segment
	assume	cs:cseg
	org	100h	;necessary for COM file
start	proc	near
	jmp	makeres
old_int10	dd	?
; front end routine for BIOS video handler to scroll without flicker
scroll_front_end:
	cmp	ax,0e0ah	;only intercept write_tty function
	jnz	pass_to_bios	; called with linefeed
	push	ax
	push	bx
	mov	ah,0fh
	int	10h		;get current page & mode
	cmp	al,2
	jz	check_row	;BIOS only blanks in modes 2 & 3, so
	cmp	al,3		; only intercept linefeed scroll in
	jnz	pass_to_bios2	; modes 2 & 3
check_row:			;see if cursor is on bottom row, in
	push	cx		; which case linefeed causes scroll
	push	dx
	mov	ah,3
	int	10h		;get cursor location in current page
	cmp	dh,24
	jnz	pass_to_bios3	;cursor not on bottom row, no scroll
	push	ds		;meets all the criteria, so perform
	push	es		; scroll in current page with special
	push	si		; routine that doesn't disable video
	push	di
	mov	ah,0fh
	int	10h		;get # columns & page
	mov	al,ah
	sub	ah,ah	;convert to word	
	push	ax	;set aside # columns
	mov	si,ax
	shl	si,1	;move from second row (each character=2 bytes)
	mov	ah,24
	mul	ah	;# words to move (24 rows)
	mov	cx,ax
	sub	ax,ax	;now adjust offsets for current page
	mov	ds,ax	;buffer length is stored in BIOS segment
	mov	al,bh	;get current page
	mul	word ptr ds:[44ch] ;offset of start of current page
	add	si,ax	;move data from second row of current page
	mov	di,ax	; to top of current page
	mov	ax,0b800h
	mov	ds,ax
	mov	es,ax		;will move data in display segment
	cld
    rep movsw		;scroll screen up
	mov	ah,8	;BH already has current page
	int	10h	;get attribute of character at cursor
	mov	al,' '	;fill with blanks & attribute just obtained
	pop	cx	;# of words per row
    rep	stosw		;blank bottom row-DI points to bottom row
	pop	di	;done
	pop	si
	pop	es
	pop	ds
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	iret
pass_to_bios3:
	pop	dx
	pop	cx
pass_to_bios2:
	pop	bx
	pop	ax
pass_to_bios:		;pass interrupt to normal BIOS handler
	jmp	cs:[old_int10]
endres:
; make scroll front end handler resident & revector interrupt 10 to it
makeres:
	push	cs
	pop	ds
	assume	ds:cseg
	mov	ax,3510h	;DOS get vector function, vector 10h
	int	21h		;get vector 10h
	mov	word ptr [old_int10],bx	;set aside old vector to
	mov	word ptr [old_int10+2],es	; allow pass to BIOS
	mov	ax,2510h	;DOS set vector function, vector 10h
	mov	dx,offset scroll_front_end	;revector interrupt
	int	21h			; 10h to front end routine
	mov	dx,offset endres ;# of paragraphs to make
	mov	cl,4		; resident-can't do with an
	shr	dx,cl		; expression because assembler can't
	inc	dx		; calculate w/relocatable label
	mov	ax,3100h 	;DOS make resident fn, exit code=0
	int	21h		;terminate & stay resident
start	endp
cseg	ends
	end	start

