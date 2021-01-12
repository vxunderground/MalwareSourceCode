	name	boot2_asm
	.radix	16

n_000100:
	inc	word ptr [7DF3]
	mov	bx,[7DF3]
	add	byte ptr [7EB2],2
	call	n_FFFF9D
	jmp	short n_00014B

n_000112:
	mov	ax,3
	test	byte ptr [7DF7],4
	je	n_00011D
	inc	ax
n_00011D:
	mul	si
	shr	ax,1
	sub	ah,byte ptr [7EB2]
	mov	bx,ax
	cmp	bx,1FF
	jnb	n_000100
	mov	dx,[bx+8000]
	test	byte ptr [7DF7],4
	jne	n_000145
	mov	cl,4
	test	si,1
	je	n_000142
	shr	dx,cl
n_000142:
	and	dh,0F
n_000145:
	test	dx,0FFFF
	jz	n_000151
n_00014B:
	inc	si
	cmp	si,di
	jbe	n_000112
	ret

n_000151:
	mov	dx,0FFF7
	test	byte ptr [7DF7],4
	jnz	n_000168
	and	dh,0F
	mov	cl,4
	test	si,1
	je	n_000168
	shl	dx,cl
n_000168:
	or	[bx+8000],dx
	mov	bx,[7DF3]
	call	n_FFFF98
	mov	ax,si
	sub	ax,2
	mov	bl,byte ptr [7C0Dh]
	xor	bh,bh
	mul	bx
	add	ax,[7DF5]
	mov	si,ax
	mov	bx,0
	call	n_FFFF9D
	mov	bx,si
	inc	bx
	call	n_FFFF98
	mov	bx,si
	mov	[7DF9],si
	push	cs
	pop	ax
	sub	ax,20
	mov	es,ax
	call	n_FFFF98
	push	cs
	pop	ax
	sub	ax,40
	mov	es,ax
	mov	bx,0
	call	n_FFFF98
	ret

	mov	ch,23
	add	dh,dh
	push	es
	idiv	word ptr [di+2]
	jne	n_0001DE
	or	byte ptr [7DF7],2
	mov	ax,0
	mov	ds,ax
	mov	ax,[20]
	mov	bx,[22]
	mov	[20],7EDF
	mov	[22],cs
	push	cs
	pop	ds
	mov	[7FC9],ax
	mov	[7FCBh],bx
n_0001DE:
	ret

	push	ds
	push	ax
	push	bx
	push	cx
	push	dx
	push	cs
	pop	ds
	mov	ah,0F		;Get video mode
	int	10
	mov	bl,al
	cmp	bx,[7FD4]
	je	n_000227
	mov	[7FD4],bx
	dec	ah
	mov	byte ptr [7FD6],ah
	mov	ah,1
	cmp	bl,7
	jne	n_000205
	dec	ah
n_000205:
	cmp	bl,4
	jnb	n_00020C
	dec	ah
n_00020C:
	mov	byte ptr [7FD3],ah
	mov	word ptr [7FCF],101
	mov	word ptr [7FD1],101
	mov	ah,3		;Read cursor position
	int	10
	push	dx
	mov	dx,[7FCF]
	jmp	short n_00024A

n_000227:
	mov	ah,3		;Read cursor position
	int	10
	push	dx
	mov	ah,2		;Set cursor position
	mov	dx,[7FCF]
	int	10
	mov	ax,[7FCDh]
	cmp	byte ptr [7FD3],1
	jne	n_000241
	mov	ax,8307
n_000241:
	mov	bl,ah
	mov	cx,1
	mov	ah,9		;Write character with attribute
	int	10
n_00024A:
	mov	cx,[7FD1]
	cmp	dh,0
	jne	n_000258
	xor	ch,0FF
	inc	ch
n_000258:
	cmp	dh,18
	jne	n_000262
	xor	ch,0FF
	inc	ch
n_000262:
	cmp	dl,0
	jne	n_00026C
	xor	cl,0FF
	inc	cl
n_00026C:
	cmp	dl,byte ptr [7FD6]
	jne	n_000277
	xor	cl,0FF
	inc	cl
n_000277:
	cmp	cx,[7FD1]
	jne	n_000294
	mov	ax,[7FCDh]
	and	al,7
	cmp	al,3
	jne	n_00028B
	xor	ch,0FF
	inc	ch
n_00028B:
	cmp	al,5
	jne	n_000294
	xor	cl,0FF
	inc	cl
n_000294:
	add	dl,cl
	add	dh,ch
	mov	[7FD1],cx
	mov	[7FCF],dx
	mov	ah,2		;Set cursor position
	int	10
	mov	ah,8		;Read character with attribute
	int	10
	mov	[7FCDh],ax
	mov	bl,ah
	cmp	byte ptr [7FD3],1
	jne	n_0002B6
	mov	bl,83
n_0002B6:
	mov	cx,1
	mov	ax,907		;Write character '\7' with attribute
	int	10
	pop	dx
	mov	ah,2		;Set cursor position
	int	10
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	pop	ds
	jmp	far ptr f_000020

	add	byte ptr [bx+si],al
	add	word ptr [bx+di],ax
	add	word ptr [bx+di],ax
	add	bh,bh
	call	word ptr [bx+si-49]
	mov	bh,0B7
	mov	dh,40
	inc	ax
	mov	dh,bl
	out	5A,al
	lodsb
	shl	ah,cl
	jmp	far ptr f_0F05E6

	db	'@d\`R@@@@db^b`'

	pop	si
	jo	n_000368
	inc	ax
	inc	cx
	mov	bh,0B7
	mov	bh,0B6
	jmp	n_000336

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

	db	0011h dup (000h)
	adc	al,byte ptr [bx][si]
	add	byte ptr [bx][si],al
	add	byte ptr [bx][di],al
	add	dl,bh

boot2:
	xor	ax,ax
	mov	ss,ax
	mov	sp,7C00
	push	ss
	pop	es
	mov	bx,78
	lds	si,ss:[bx]
	push	ds
	push	si
	push	ss
	push	bx
	mov	di,7C2Bh
	mov	cx,0Bh
	cld
n_000351:
	lodsb
	cmp	byte ptr es:[di],0
	je	n_00035B
	mov	al,byte ptr es:[di]
n_00035B:
	stosb
	mov	al,ah
	loop	n_000351
	push	es
	pop	ds
	mov	[bx+2],ax
	mov	[bx],7C2Bh
	sti
	int	13
	jc	n_0003D5
	mov	al,byte ptr [7C10]
	cbw
	mul	word ptr [7C16]
	add	ax,[7C1C]
	add	ax,[7C0E]
	mov	[7C3F],ax
	mov	[7C37],ax
	mov	ax,20
	mul	word ptr [7C11]
	mov	bx,[7C0Bh]
	add	ax,bx
	dec	ax
	div	bx
	add	[7C37],ax
	mov	bx,500
	mov	ax,[7C3F]
	call	n_000440
	mov	ax,201
	call	n_00045A
	jb	n_0003C2
	mov	di,bx
	mov	cx,0Bh
	mov	si,7DD6
	rep	cmpsb
	jne	n_0003C2
	lea	di,[bx+20]
	mov	si,7DE1
	mov	cx,0Bh
	rep	cmpsb
	je	n_0003DA
n_0003C2:
	mov	si,7D77
n_0003C5:
	call	n_000432
	xor	ah,ah
	int	16
	pop	si
	pop	ds
	pop	[si]
	pop	[si+2]
	int	19

n_0003D5:
	mov	si,7DC0
	jmp	n_0003C5

n_0003DA:
	mov	ax,[51C]
	xor	dx,dx
	div	word ptr [7C0Bh]
	inc	al
	mov	[7C3C],al
	mov	ax,[7C37]
	mov	[7C3Dh],ax
	mov	bx,700
n_0003F1:
	mov	ax,[7C37]
	call	n_000440
	mov	ax,[7C18]
	sub	al,[7C3Bh]
	inc	ax
	cmp	[7C3C],al
	jnb	n_000408
	mov	al,[7C3Ch]
n_000408:
	push	ax
	call	n_00045A
	pop	ax
	jb	n_0003D5
	sub	[7C3C],al
	je	n_000421
	add	[7C37],ax
	mul	word ptr [7C0Bh]
	add	bx,ax
	jmp	n_0003F1
n_000421:
	mov	ch,[7C15]
	mov	dl,[7DFDh]
	mov	bx,[7C3Dh]
	jmp	far ptr f_000700

n_000432:
	lodsb
	or	al,al
	je	n_000459
	mov	ah,0E		;Write character in TTY graphics mode
	mov	bx,7
	int	10
	jmp	n_000432

n_000440:
	xor	dx,dx
	div	word ptr [7C18]
	inc	dl
	mov	[7C3Bh],dl
	xor	dx,dx
	div	word ptr [7C1A]
	mov	[7C2A],dl
	mov	[7C39],ax
n_000459:
	ret

n_00045A:
	mov	ah,2
	mov	dx,[7C39]
	mov	cl,6
	shl	dh,cl
	or	dh,[7C3Bh]
	mov	cx,dx
	xchg	ch,cl
	mov	dl,[7DFDh]
	mov	dh,[7C2A]
	int	13
	ret

	db	0Dh,0A,'Non-System disk or disk error',0Dh,0A
	db	'Replace and strike any key when ready',0Dh,0A,0
	db	0Dh,0A,'Disk Boot failure',0Dh,0A,0
	db	'IBMBIO  SYS'
	db	'IBMDOS  SYS'
	db	12 dup (0)
	dw	0AA55

	extrn	f_000020:far,n_000336:near,n_000368:near
	extrn	n_FFFF9D:near,n_FFFF98:near
	extrn	f_000700:far,f_0F05E6:far,f_3FFF98:far
	extrn	f_3FFF9D:far
