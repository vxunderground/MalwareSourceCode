
PAGE  59,132

;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
;€€								         €€
;€€			        ROOT				         €€
;€€								         €€
;€€      Created:   30-Aug-92					         €€
;€€      Passes:    5	       Analysis Options on: none	         €€
;€€								         €€
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€

data_0001e	equ	78h
data_0002e	equ	7C0Bh			;*
data_0003e	equ	7C0Dh			;*
data_0004e	equ	7C0Eh			;*
data_0005e	equ	7C10h			;*
data_0006e	equ	7C11h			;*
data_0007e	equ	7C13h			;*
data_0008e	equ	7C15h			;*
data_0009e	equ	7C16h			;*
data_0010e	equ	7C18h			;*
data_0011e	equ	7C1Ah			;*
data_0012e	equ	7C1Ch			;*
data_0013e	equ	7C1Eh			;*
data_0014e	equ	7C20h			;*
data_0015e	equ	7C24h			;*
data_0016e	equ	7C25h			;*
data_0017e	equ	7C3Eh			;*
data_0018e	equ	7C49h			;*
data_0019e	equ	7C4Bh			;*
data_0020e	equ	7C4Dh			;*
data_0021e	equ	7C4Fh			;*
data_0022e	equ	7C50h			;*
data_0023e	equ	7C52h			;*
data_0024e	equ	7D9Eh			;*
data_0025e	equ	7DE6h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	100h

root		proc	far

start:
		jmp	short loc_0002
		db	90h
		db	'MSDOS5.0'
		db	 00h, 02h, 04h, 01h, 00h, 02h
		db	 00h, 02h,0FEh,0EFh,0F8h, 3Ch
		db	 00h, 11h, 00h, 0Fh, 00h, 11h
		db	7 dup (0)
		db	 80h, 00h, 29h, 27h, 45h, 08h
		db	 19h
		db	'MS-DOS_5   FAT16   '
loc_0002:
		cli				; Disable interrupts
		xor	ax,ax			; Zero register
		mov	ss,ax
		mov	sp,7C00h
		push	ss
		pop	es
		mov	bx,data_0001e
		lds	si,dword ptr ss:[bx]	; Load 32 bit ptr
		push	ds
		push	si
		push	ss
		push	bx
		mov	di,data_0017e
		mov	cx,0Bh
		cld				; Clear direction
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		push	es
		pop	ds
		mov	byte ptr [di-2],0Fh
		mov	cx,ds:data_0010e
		mov	[di-7],cl
		mov	[bx+2],ax
		mov	word ptr [bx],7C3Eh
		sti				; Enable interrupts
		int	13h			; Disk  dl=drive a  ah=func 00h
						;  reset disk, al=return status
		jc	loc_0004		; Jump if carry Set
		xor	ax,ax			; Zero register
		cmp	ds:data_0007e,ax
		je	loc_0003		; Jump if equal
		mov	cx,ds:data_0007e
		mov	ds:data_0014e,cx
loc_0003:
		mov	al,ds:data_0005e
		mul	word ptr ds:data_0009e	; ax = data * ax
		add	ax,ds:data_0012e
		adc	dx,ds:data_0013e
		add	ax,ds:data_0004e
		adc	dx,0
		mov	ds:data_0022e,ax
		mov	ds:data_0023e,dx
		mov	ds:data_0018e,ax
		mov	ds:data_0019e,dx
		mov	ax,20h
		mul	word ptr ds:data_0006e	; ax = data * ax
		mov	bx,ds:data_0002e
		add	ax,bx
		dec	ax
		div	bx			; ax,dx rem=dx:ax/reg
		add	ds:data_0018e,ax
		adc	word ptr ds:data_0019e,0
		mov	bx,500h
		mov	dx,ds:data_0023e
		mov	ax,ds:data_0022e
		call	sub_0002
		jc	loc_0004		; Jump if carry Set
		mov	al,1
		call	sub_0003
		jc	loc_0004		; Jump if carry Set
		mov	di,bx
		mov	cx,0Bh
		mov	si,data_0025e
		repe	cmpsb			; Rep zf=1+cx >0 Cmp [si] to es:[di]
		jnz	loc_0004		; Jump if not zero
		lea	di,[bx+20h]		; Load effective addr
		mov	cx,0Bh
		repe	cmpsb			; Rep zf=1+cx >0 Cmp [si] to es:[di]
		jz	loc_0006		; Jump if zero
loc_0004:
		mov	si,data_0024e
		call	sub_0001
		xor	ax,ax			; Zero register
		int	16h			; Keyboard i/o  ah=function 00h
						;  get keybd char in al, ah=scan
		pop	si
		pop	ds
		pop	word ptr [si]
		pop	word ptr [si+2]
		int	19h			; Bootstrap loader
loc_0005:
		pop	ax
		pop	ax
		pop	ax
		jmp	short loc_0004
loc_0006:
		mov	ax,[bx+1Ah]
		dec	ax
		dec	ax
		mov	bl,ds:data_0003e
		xor	bh,bh			; Zero register
		mul	bx			; dx:ax = reg * ax
		add	ax,ds:data_0018e
		adc	dx,ds:data_0019e
		mov	bx,700h
		mov	cx,3

locloop_0007:
		push	ax
		push	dx
		push	cx
		call	sub_0002
		jc	loc_0005		; Jump if carry Set
		mov	al,1
		call	sub_0003
		pop	cx
		pop	dx
		pop	ax
		jc	loc_0004		; Jump if carry Set
		add	ax,1
		adc	dx,0
		add	bx,ds:data_0002e
		loop	locloop_0007		; Loop if cx > 0

		mov	ch,ds:data_0008e
		mov	dl,ds:data_0015e
		mov	bx,ds:data_0018e
		mov	ax,ds:data_0019e
;*		jmp	far ptr loc_0001	;*
		db	0EAh, 00h, 00h, 70h, 00h

root		endp

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_0001	proc	near
loc_0008:
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jz	loc_ret_0010		; Jump if zero
		mov	ah,0Eh
		mov	bx,7
		int	10h			; Video display   ah=functn 0Eh
						;  write char al, teletype mode
		jmp	short loc_0008

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

sub_0002:
		cmp	dx,ds:data_0010e
		jae	loc_0009		; Jump if above or =
		div	word ptr ds:data_0010e	; ax,dxrem=dx:ax/data
		inc	dl
		mov	ds:data_0021e,dl
		xor	dx,dx			; Zero register
		div	word ptr ds:data_0011e	; ax,dxrem=dx:ax/data
		mov	ds:data_0016e,dl
		mov	ds:data_0020e,ax
		clc				; Clear carry flag
		retn
loc_0009:
		stc				; Set carry flag

loc_ret_0010:
		retn
sub_0001	endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_0003	proc	near
		mov	ah,2
		mov	dx,ds:data_0020e
		mov	cl,6
		shl	dh,cl			; Shift w/zeros fill
		or	dh,ds:data_0021e
		mov	cx,dx
		xchg	ch,cl
		mov	dl,ds:data_0015e
		mov	dh,ds:data_0016e
		int	13h			; Disk  dl=drive ?  ah=func 02h
						;  read sectors to memory es:bx
						;   al=#,ch=cyl,cl=sectr,dh=head
		retn
sub_0003	endp

		db	0Dh, 0Ah, 'Non-System disk or dis'
		db	'k error', 0Dh, 0Ah, 'Replace and'
		db	' press any key when ready', 0Dh, 0Ah
		db	0
		db	'IO      SYSMSDOS   SYS'
		db	 00h, 00h, 55h,0AAh

seg_a		ends



		end	start
