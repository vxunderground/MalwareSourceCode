.286
.model tiny
.code
	org	100H
start:	ror	si,1
	lodsb
	add	si,ax
	mov	[si],ah
	mov	dx,82H
	mov	ax,3D00H
	int	21H
	jc	rt
	mov	cx,40*200
	xchg	bx,ax
	push	0A000H
	pop	ds
	mov	al,13
	int	10H
	mov	si,10H
m10:	mov	dx,03C4H
	mov	al,2
	out	dx,al
	xchg	si,ax
	shr	al,1
	inc	dx
	out	dx,al
	xchg	si,ax
	mov	ah,3FH
	cwd
	int	21H
	or	ax,ax
	jnz	m10
	int	16H
rt:	ret
end	start
