
PAGE  59,132

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл								         лл
;лл			        ZEP				         лл
;лл								         лл
;лл      Created:   12-Nov-92					         лл
;лл      Passes:    5	       Analysis Options on: none	         лл
;лл								         лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

data_1e		equ	0A0h
data_9e		equ	418h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	100h

zep		proc	far

start:
		jmp	short loc_1
		db	90h
data_2		db	0
data_3		dw	216h
		db	2
data_4		dw	0
		db	'TheDraw COM file Screen Save'
		db	1Ah
data_5		db	'Unsupported Video Mode', 0Dh, 0Ah
		db	'$'
loc_1:
		mov	ah,0Fh
		int	10h			; Video display   ah=functn 0Fh
						;  get state, al=mode, bh=page
						;   ah=columns on screen
		mov	bx,0B800h
		cmp	al,2
		je	loc_2			; Jump if equal
		cmp	al,3
		je	loc_2			; Jump if equal
		mov	data_2,0
		mov	bx,0B000h
		cmp	al,7
		je	loc_2			; Jump if equal
		mov	dx,offset data_5	; ('Unsupported Video Mode')
		mov	ah,9
		int	21h			; DOS Services  ah=function 09h
						;  display char string at ds:dx
		retn
loc_2:
		mov	es,bx
		mov	di,data_4
		mov	si,offset data_6
		mov	dx,3DAh
		mov	bl,9
		mov	cx,data_3
		cld				; Clear direction
		xor	ax,ax			; Zero register

locloop_4:
		lodsb				; String [si] to al
		cmp	al,1Bh
		jne	loc_5			; Jump if not equal
		xor	ah,80h
		jmp	short loc_20
loc_5:
		cmp	al,10h
		jae	loc_8			; Jump if above or =
		and	ah,0F0h
		or	ah,al
		jmp	short loc_20
loc_8:
		cmp	al,18h
		je	loc_11			; Jump if equal
		jnc	loc_12			; Jump if carry=0
		sub	al,10h
		add	al,al
		add	al,al
		add	al,al
		add	al,al
		and	ah,8Fh
		or	ah,al
		jmp	short loc_20
loc_11:
		mov	di,data_4
		add	di,data_1e
		mov	data_4,di
		jmp	short loc_20
loc_12:
		mov	bp,cx
		mov	cx,1
		cmp	al,19h
		jne	loc_13			; Jump if not equal
		lodsb				; String [si] to al
		mov	cl,al
		mov	al,20h			; ' '
		dec	bp
		jmp	short loc_14
loc_13:
		cmp	al,1Ah
		jne	loc_15			; Jump if not equal
		lodsb				; String [si] to al
		dec	bp
		mov	cl,al
		lodsb				; String [si] to al
		dec	bp
loc_14:
		inc	cx
loc_15:
		cmp	data_2,0
		je	loc_18			; Jump if equal
		mov	bh,al

locloop_16:
		in	al,dx			; port 3DAh, CGA/EGA vid status
		rcr	al,1			; Rotate thru carry
		jc	locloop_16		; Jump if carry Set
loc_17:
		in	al,dx			; port 3DAh, CGA/EGA vid status
		and	al,bl
		jnz	loc_17			; Jump if not zero
		mov	al,bh
		stosw				; Store ax to es:[di]
		loop	locloop_16		; Loop if cx > 0

		jmp	short loc_19
loc_18:
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
loc_19:
		mov	cx,bp
loc_20:
		jcxz	loc_ret_21		; Jump if cx=0
		loop	locloop_4		; Loop if cx > 0


loc_ret_21:
		retn
data_6		db	9
		db	 10h, 19h, 45h, 18h, 19h, 1Bh
		db	 01h,0D5h,0CDh,0CDh,0B8h, 04h
		db	0F3h, 09h,0A9h, 04h, 9Dh
		db	9
		db	0AAh, 04h,0F2h, 01h,0D5h,0CDh
		db	0CDh,0B8h, 19h, 1Ch, 18h, 19h
		db	 12h,0D5h, 1Ah, 0Ah,0CDh,0BEh
		db	 20h, 09h, 5Ch, 04h,0F6h, 09h
		db	 2Fh, 20h, 01h,0D4h, 1Ah, 0Ah
		db	0CDh,0B8h, 19h, 13h, 18h, 19h
		db	 03h,0C9h, 1Ah, 0Dh,0CDh,0BEh
		db	 19h, 03h, 0Fh,0D2h,0B7h, 19h
		db	 04h,0D6h, 1Ah, 03h,0C4h,0B7h
		db	 20h,0D2h,0D2h,0C4h,0C4h,0C4h
		db	0B7h, 19h, 04h, 01h,0D4h, 1Ah
		db	 0Eh,0CDh,0BBh, 19h, 03h, 18h
		db	 19h, 03h,0BAh, 19h, 12h, 07h
		db	0BAh,0BAh, 19h, 04h,0BAh, 19h
		db	 03h,0BDh, 20h,0BAh,0BAh, 19h
		db	 02h,0D3h,0B7h, 19h, 13h, 01h
		db	0BAh, 19h, 03h, 18h, 19h, 03h
		db	0BAh, 19h, 07h, 0Bh, 1Ah, 02h
		db	 04h, 19h, 07h, 08h,0BAh,0B6h
		db	 19h, 04h,0C7h,0C4h,0B6h, 19h
		db	 03h,0BAh,0B6h, 19h, 03h,0BAh
		db	 19h, 07h, 0Bh, 1Ah, 02h, 04h
		db	 19h, 08h, 01h,0BAh, 19h, 03h
		db	 18h,0D6h,0C4h,0C4h, 20h,0BAh
		db	 19h, 12h, 08h,0BAh,0D3h, 19h
		db	 02h,0B7h, 20h,0BAh, 19h, 03h
		db	0B7h, 20h,0BAh,0D3h, 19h, 02h
		db	0D6h,0BDh, 19h, 13h, 01h,0BAh
		db	 20h,0C4h,0C4h,0B7h, 18h,0D3h
		db	0C4h,0C4h,0C4h,0BDh, 19h, 12h
		db	 08h,0D3h, 1Ah, 03h,0C4h,0BDh
		db	 20h,0D3h, 1Ah, 03h,0C4h,0BDh
		db	 20h,0D0h, 1Ah, 03h,0C4h,0BDh
		db	 19h, 14h, 01h,0D3h,0C4h,0C4h
		db	0C4h,0BDh, 18h, 04h, 1Ah, 04h
		db	 3Eh, 19h, 03h, 0Fh,0D6h, 1Ah
		db	 04h,0C4h,0B7h, 20h,0D6h, 1Ah
		db	 03h,0C4h,0B7h, 20h,0D2h,0D2h
		db	0C4h,0C4h,0C4h,0B7h, 20h,0D2h
		db	0D2h,0C4h,0C4h,0C4h,0B7h, 20h
		db	0D6h, 1Ah, 03h,0C4h,0B7h, 20h
		db	0D2h,0B7h, 19h, 04h,0D2h, 20h
		db	 20h,0D2h,0D2h,0C4h,0C4h,0C4h
		db	0B7h, 19h, 03h, 04h, 1Ah, 04h
		db	 3Ch, 18h, 01h,0D6h,0C4h,0C4h
		db	0C4h,0B7h, 19h, 07h, 07h,0D6h
		db	0C4h,0BDh
		dd	319BA20h		; Data table (indexed access)
		db	0BDh, 20h,0BAh,0BDh, 19h, 02h
		db	0BAh, 20h,0BAh,0BDh, 19h, 02h
		db	0BAh, 20h,0BAh, 19h, 03h,0BDh
		db	 20h,0BAh,0BAh, 19h, 04h,0BAh
		db	 20h, 20h,0BAh,0BAh, 19h, 02h
		db	0BAh, 19h, 03h, 01h,0D6h,0C4h
		db	0C4h,0C4h,0B7h, 18h,0D3h,0C4h
		db	0C4h, 20h,0BAh, 19h, 06h, 08h
		db	 58h, 19h, 03h,0C7h,0C4h,0B6h
		db	 19h, 03h,0BAh, 1Ah, 03h,0C4h
		db	0BDh, 20h,0BAh, 1Ah, 03h,0C4h
		db	0BDh, 20h,0C7h,0C4h,0B6h, 19h
		db	 03h,0BAh,0B6h, 19h, 04h,0BAh
		db	 20h, 20h,0BAh,0B6h, 19h, 02h
		db	0BAh, 19h, 03h, 01h,0BAh, 20h
		db	0C4h,0C4h,0BDh, 18h, 19h, 03h
		db	0BAh, 19h, 03h, 08h,0D6h,0C4h
		db	0BDh, 19h, 04h,0BAh, 19h, 03h
		db	0B7h, 20h,0BAh, 19h, 05h,0BAh
		db	 19h, 05h,0BAh, 19h, 03h,0B7h
		db	 20h,0BAh,0D3h, 19h, 02h,0B7h
		db	 20h,0BAh, 20h, 20h,0BAh,0D3h
		db	 19h, 02h,0BAh, 19h, 03h, 01h
		db	0BAh, 19h, 03h, 18h, 19h, 03h
		db	0BAh, 19h, 03h, 08h,0D3h, 1Ah
		db	 04h,0C4h,0BDh, 20h,0D3h, 1Ah
		db	 03h,0C4h,0BDh, 20h,0BDh, 19h
		db	 05h,0BDh, 19h, 05h,0D3h, 1Ah
		db	 03h,0C4h,0BDh, 20h,0D3h, 1Ah
		db	 03h,0C4h,0BDh, 20h,0D0h, 20h
		db	 20h,0D0h, 19h, 03h,0D0h, 19h
		db	 03h, 01h,0BAh, 19h, 03h, 18h
		db	 19h, 03h,0C8h, 1Ah, 15h,0CDh
		db	0B8h, 19h, 0Ch,0D5h, 1Ah, 16h
		db	0CDh,0BCh, 19h, 03h, 18h, 19h
		db	 1Ah,0D4h,0CDh, 04h, 1Ah, 03h
		db	0F7h, 09h, 2Fh, 04h,0EAh, 09h
		db	 5Ch, 04h, 1Ah, 03h,0F7h, 01h
		db	0CDh,0BEh, 19h, 1Bh, 18h

zep		endp

seg_a		ends



		end	start
