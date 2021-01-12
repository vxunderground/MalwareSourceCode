
memS	equ 1	       ;model small  convertable to COM model
;****************	RUNTIME LIBRARY OF KILLDIANA.COM     **************
include lcmac.mac
calln	macro	name
	call near ptr name
	endm
callp	macro	name
	lea	dx,name
	calln	print
	endm
callz	macro	name
	push	si
	lea	si,name
	calln	printz
	pop	si
	endm

dgroup	group data,udata,xstack
	assume ds:data

pgroup	group prog,tail
prog	segment byte public 'prog'
	assume cs:prog

	org	100h			;FOR MODEL COM

start	label	 far
	cli
	mov	ax,offset pgroup:xtail	;get end of code group
	add	ax,16			;calculate segment address of ds
	mov	cl,4			;calculate segment address of ds
	shr	ax,cl			;calculate segment address of ds
	mov	bx,cs			;calculate segment address of ds
	add	ax,bx			;calculate segment address of ds
	mov	ds,ax			;set ds to dgroup
	mov	es,ax			;set es to dgroup
	mov	ss,ax			;set ss to dgroup
	mov	ds:_ss,ax		;save stack segment for (do,for,while)
	mov	sp,offset dgroup:sbase + 512	;range of stack = 512 bytes
	mov	ds:_top,sp		;save stack pointer for (do,for,while)
	mov	bx,offset dgroup:sbase	;get  stack segment for (do,for,while)
	mov	ds:_base,bx		;save stack segment for (do,for,while)
	sti
	mov	ah,30h			;get dos version number
	int	21h
	mov	ds:_dos,ax		;save dos version for (do,for,while)
	callp	copyr
	callp	tryrem
	calln	remove
	callp	weak

	lea	di,fname
	mov	si,82h
getf:
	mov	al,cs:[si]
	cmp	al,0dh
	je	tonul
	cmp	al,' '
	jc	blank
	mov	[di],al
	inc	di
blank:	inc	si
	.br	getf
tonul:	clr	al
	mov	[di],al
	calln	prefix
	calln	comwrk
;	calln	exewrk
	mov	ah,4ch
	int	21h		;exit to DOS

print	proc	near
	mov	ah,9
	int	21h
	ret
print	endp

comwrk	proc	near
	calln	first
	jc	toret
	calln	workcom
ffnext:
	calln	fnext
	jc	toret
	calln	workcom
	.br	ffnext
toret:
	ret
comwrk	endp
fnext	proc	near
	mov	ah,4fh		;findnext
	int	21h
	jc	ercc
	jnc	foundf
fnext	endp
first	proc	near
	lea	dx,fname
	mov	cx,27h		;search all types of files
	mov	ah,4eh		;findfirst
	int	21h
	jnc	foundf
	callp	notfnd
ercc:	stc
	ret
foundf:
	calln	konka
	clc
	ret
first	endp
konka	proc	near
	mov	ah,2fh
	int	21h		;get dta  in es:bx
	add	bx,26
	mov	ax,es:[bx]
	mov	llfil,ax	;save lowlengh
	inc	bx
	inc	bx
	mov	ax,es:[bx]
	mov	lhfil,ax	;save highlengh
	inc	bx
	inc	bx		;pointed to fname
	lea	si,ffname
	lea	di,fname
	push	es
	push	ds
	pop	es
	mov	cx,40h
repe	cmpsb
	pop	es
	dec	si
copyf:	mov	al,es:[bx]
	mov	[si],al
	inc	si
	inc	bx
	or	al,al
	jne	copyf
	ret
konka	endp

prefix	proc	near
	lea	si,fname
	add	si,40h
	mov	cx,40h
	std
lodi:
	lodsb
	cmp	al,'\'
	je	founds
	cmp	al,':'
	je	founds
	loop	lodi
	mov	nepar,offset fname
	.br	endcp
founds:
	inc	si
	inc	si
	mov	nepar,si
	lea	si,fname
	lea	di,ffname
cpag:
	cmp	si,nepar
	jae	endcp
	mov	al,[si]
	mov	[di],al
	inc	si
	inc	di
	.br	cpag
endcp:
	cld
	ret
prefix	endp


remove	proc	near
	push	ds
	clr	ax
	mov	ds,ax
	les	bx,ds:[84h]	   ;21h vector
	mov	ax,cs
	mov	dx,es
	cmp	dx,ax
	jc	nodia
	cmp	bx,2eeh
	jne	nodia

	mov	ax,es:[74fh]
	mov	ds:[84h],ax	   ;restore 21h
	mov	ax,es:[751h]
	mov	ds:[86h],ax

	mov	ax,es:[74bh]
	mov	ds:[9ch],ax	   ;restore 27h
	mov	ax,es:[74dh]
	mov	ds:[9eh],ax
	mov	ax,es
	mov	bx,ax
	dec	ax
	mov	es,ax
	mov	es:byte ptr[0],5ah
	mov	es:word ptr[1],0
	pop	ds
	callp	diakt
	ret
nodia:
	pop	ds
	callp	dinakt
	ret
remove	endp

workcom proc	near
	lea	dx,ffname
	mov	ax,4300h	;get attrib
	int	21h
	jnc	kopa
	jmp	retga
kopa:
	mov	al,cl
	and	al,0feh
	cmp	al,cl
	je	nochatr

	mov	attr,cx
	mov	ax,4301h	;set attrib
	clr	cx		;to normal
	int	21h
	.br	nochh
nochatr:
	mov	attr,0
nochh:
	mov	ax,3d02h	;open file R/W
	int	21h
	jnc	kop1
	jmp	resatr
kop1:	mov	bx,ax
	calln	gettm
	mov	cx,18h
	lea	dx,bufer
	mov	ah,3fh		;read first 3 bytes
	int	21h
	jc	closs2
	mov	di,dx
	mov	ax,ds:[di]
	cmp	ax,5a4dh
	jne	commfil
	push	bx
	calln	exework
	pop	bx
	jc	chek2
	jmp	closs

commfil:
	mov	al,ds:[di]
	cmp	al,0e9h
	je	mak111
	jmp	closs
mak111: mov	si,ds:[di+1]	;relative offset
	add	si,3
	mov	di,si
	sub	si,68h
	mov	len,si

	clr	cx
	mov	dx,di
	mov	ax,4200h
	int	21h		;seek to found e80000
closs2: jc	clos21

	lea	dx,bufer
	add	dx,18h+3
	mov	cx,7		;read 7 bytes
	mov	ah,3fh
	int	21h		;read
clos21: jnc	chek1
chek2:	jmp	closs
chek1:
	mov	di,dx
	cmp	ds:byte ptr[di],0e8h
	jne	chek2
	cmp	ds:word ptr[di+1],0
	jne	chek2
	cmp	ds:word ptr[di+4],0ee81h
	jne	chek2
	cmp	ds:word ptr[di+6],6bh
	jne	chek2

	clr	cx
	mov	dx,si
	add	dx,705h
	mov	ax,4200h
	int	21h		;seek to found org 3bytes
	jc	closs
	lea	dx,bufer
	add	dx,18h
	mov	cx,3		;read 3 bytes
	mov	ah,3fh
	int	21h		;read
	jc	closs
	lea	si,bufer
restor3:
	mov	al,[si+18h]
	mov	[si],al
	inc	si
	loop	restor3
	clr	cx
	clr	dx
	mov	ax,4200h	;seek to begin
	int	21h
	jc	closs

	mov	cx,18h
	lea	dx,bufer
	mov	ah,40h		;write
	int	21h
	jc	closs

	clr	cx
	mov	dx,len
	mov	ax,4200h	;seek to end of real data
	int	21h
	jc	resatr
exelen:
	clr	cx
	mov	ah,40h		;truncate file
	int	21h
	push	bx
	callp	file
	callz	ffname
	callp	isok

	pop	bx
closs:
	calln	settm
	mov	ah,3eh
	int	21h		;close file

resatr:
	mov	cx,attr 	;to old attributes
	or	cx,cx
	je	retga
	lea	dx,ffname
	mov	ax,4301h	;set attrib
	int	21h
retga:
	ret
workcom endp
printz	proc	near
eter:	mov	ah,2
	lodsb
	or	al,al
	je	caret
	mov	dl,al
	int	21h
	.br	eter
caret:
	ret
printz	endp

gettm	proc	near
	mov	ax,5700h
	int	21h
	jc	qget
	mov	atcx,cx
	mov	atdx,dx
qget:
	ret
gettm	endp

settm	proc	near
	mov	ax,5701h
	mov	cx,atcx
	mov	dx,atdx
	or	cx,cx
	je	qset
	or	dx,dx
	je	qset
	int	21h
qset:
	ret
settm	endp
exework proc	near
	mov	ax,[di+16h]	  ;get main lenght in pargarphs
	mov	cx,16
	mul	cx
	push	bx
	mov	bx,[di+8]
	mov	cl,4
	shl	bx,cl
	add	ax,[di+14h]	  ;get IP
	adc	dx,0
	add	ax,bx
	adc	dx,0
	pop	bx
	mov	exhlen,dx
	mov	exllen,ax
	mov	cx,dx
	mov	dx,ax
	mov	ax,4200h
	int	21h		;seek to begin Diana code

	lea	dx,bufer
	add	dx,18h+3
	mov	cx,7		;read 7 bytes
	mov	ah,3fh
	int	21h		;read
	jc	echek2
	mov	di,dx
	cmp	ds:byte ptr[di],0e8h
	jne	echek2
	cmp	ds:word ptr[di+1],0
	jne	echek2
	cmp	ds:word ptr[di+4],0ee81h
	jne	echek2
	cmp	ds:word ptr[di+6],6bh
	je	exgoin
echek2:
	stc
	ret
exgoin:
	sub	exllen,68h
	sbb	exhlen,0	;contains lenght of file

	mov	dx,exllen
	mov	cx,exhlen
	add	dx,707h
	adc	cx,0
	mov	ax,4200h
	int	21h		;seek to old vectors
	lea	dx,bufer
	add	dx,26h
	mov	cx,1
	mov	ah,3fh
	int	21h		;read	old cs:ip,  ss:sp
	jc	echek2

	mov	dx,exllen
	mov	cx,exhlen
	add	dx,6fdh
	adc	cx,0
	mov	ax,4200h
	int	21h		;seek to old vectors
	lea	dx,bufer
	add	dx,18h
	mov	cx,8
	mov	ah,3fh
	int	21h		;read	old cs:ip,  ss:sp
	jc	echek2

	mov	ax,llfil
	mov	dx,lhfil
	sub	ax,exllen
	sbb	dx,exhlen
	mov	lhfil,dx
	mov	llfil,ax
	lea	di,bufer
	mov	ax,[di+4]
	mov	cx,512
	mul	cx
	add	ax,[di+2]
	adc	dx,0
	sub	ax,llfil
	sbb	dx,lhfil
	div	cx
	mov	cx,dx
	mov	dl,[di+26h]
	sub	cx,dx
	mov	rema,cx
	mov	[di+2],dx	;store remainder of lenght
	mov	[di+4],ax	;store /512 lenght

	mov	ax,[di+18h]	;get ip
	mov	[di+14h],ax	;store
	mov	ax,[di+1ah]	;get cs:
	mov	[di+16h],ax	;store

	mov	ax,[di+1ch]	;get sp
	mov	[di+10h],ax	;store
	mov	ax,[di+1eh]	;get ss:
	mov	[di+0eh],ax	;store

	clr	cx
	clr	dx
	mov	ax,4200h
	int	21h		;seek to prefix
	mov	cx,18h		;to write new prefix
	lea	dx,bufer
	mov	ah,40h
	int	21h		;write 18h bytes prefix
	mov	cx,exhlen
	mov	dx,exllen
	sub	dx,rema
	sbb	cx,0
	mov	ax,4200h
	int	21h		;seek end of file
	jmp	exelen
exework endp

prog	ends

tail	segment word 'prog'     ;help segment to allocate end of code
xtail	dw	-1		;and set the data segment
tail	ends

data	segment para public 'data'     ;data segment

fname	db	40h dup(0)
ffname	db	40h dup(0)
bufer	db	27h dup(0)
_ss	dw	?	;Lattice variables
_base	dw	?	;Lattice variables
_dos	dw	?	;Lattice variables
_top	dw	?	;Lattice variables
nepar	dw	0
fhand	dw	0
exhlen	dw	0
exllen	dw	0
llfil	dw	0
lhfil	dw	0
len	dw	0
attr	dw	0
atcx	dw	0
atdx	dw	0
rema	dw	0
notfnd	db	'File not found',13,10,'$'
copyr	db	'Dianakiller program V1.0  (C)Copyright Deny_Soft 1989',13,10,'$'
tryrem	db	'Searching Diana in memory...',13,10,'$'
diakt	db	'Diana found',7,' and removed extra',13,10,'$'
dinakt	db	"Diana isn't active",13,10,"$"
weak	db	'Searching for weak files...',13,10,'$'
file	db	'File $'
isok	db	9,9,' ... restored',13,10,'$'

data	ends
	.pub	<_ss,_base,_dos,_top>	;make external
udata	segment public 'data'
udata	ends
xstack	segment 'data'
sbase	dw	512 dup (?)
xstack	ends
	end	start
