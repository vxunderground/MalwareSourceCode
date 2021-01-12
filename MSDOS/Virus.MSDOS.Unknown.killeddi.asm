
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

dtas	struc
	resv	db	21 dup(?)
	atr	db	?
	hour	dw	?
	min	dw	?
	lfil	dw	?
	hfil	dw	?
	sname	db	14 dup(?)
dtas	ends

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
	push	cs
	pop	es

	mov	di,81h
getf:
	mov	cx,80
	cld
	mov	al,0dh
repne	scasb
	jne	quiter
	dec	di
	cmp	di,81h
	je	quiter
	mov	si,di
	mov	cx,di
	mov	cs:byte ptr[di],0
srcc:
	dec	si
	mov	al,cs:[si]
	cmp	al,'\'
	je	fndd
	cmp	al,':'
	je	fndd
	cmp	si,82h
	jae	srcc
	dec	si
fndd:
	sub	cx,si
	jcxz	quiter
	lea	di,fname
	inc	si
cpcp:	mov	al,cs:[si]
	cmp	al,' '
	jbe	incsi
	mov	[di],al
	inc	di
incsi:
	inc	si
	loop	cpcp
	callp	weak
	lea	dx,root
	mov	ah,3bh		;chdir to root
	int	21h		;chdir to root
	calln	findir
quiter:
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
	lea	dx,mydta
	mov	ah,1ah
	int	21h
	mov	ah,4fh		;findnext
	int	21h
	jc	ercc
	jnc	foundf
fnext	endp
first	proc	near
	lea	dx,mydta
	mov	ah,1ah
	int	21h
	lea	dx,fname
	mov	cx,27h		;search all types of files
	mov	ah,4eh		;findfirst
	int	21h
	jnc	foundf
;	callp	notfnd
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
copyf:	mov	al,es:[bx]
	mov	[si],al
	inc	si
	inc	bx
	or	al,al
	jne	copyf
	ret
konka	endp



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

findir	proc	near
	;	get dta
	mov	ah,2fh
	int	21h
	mov	word ptr olddta[0],bx
	mov	word ptr olddta[2],es
	;*****
	lea	dx,mydta
	mov	ah,1ah
	int	21h
	calln	comwrk
	mov	word ptr fflag,0
	calln	basewr

	; restore dta
	push	ds
	lds	dx,olddta
	mov	ah,1ah
	int	21h
	pop	ds
	ret
findir	endp

basewr	proc	near
	cmp	word ptr fflag,0
	jne	nnextt
	calln	fdir
	jc	baret
	jnc	checkk
nnextt:
	calln	ndir
	jc	baret
checkk:
	mov	bx,odta
	test	ds:byte ptr[bx + dtas.atr],10h
	je	nnextt
	cmp	byte ptr dtas.sname[bx],'.'
	je	nnextt
	mov	ah,3bh		;chdir
	mov	dx,offset dtas.sname
	add	dx,bx
	int	21h		;chdir
	calln	pdir
	calln	comwrk
	mov	fflag,0
	inc	coudir
	calln	basewr
bare:
	pushf
	lea	dx,point
	mov	ah,3bh		;chdir up
	int	21h		;chdir up
	dec	coudir
	jns	nosig
	mov	coudir,0
nosig:
	mov	fflag,1
	popf
	.br	nnextt

baret:
	ret
basewr	endp
ndir	proc	near
	calln	stdta
	mov	ah,4fh
	int	21h
	ret
ndir	endp
fdir	proc	near
	calln	stdta
	lea	dx,aster
	mov	cx,37h
	mov	ah,4eh
	int	21h
	ret
fdir	endp
stdta	proc	near
	mov	ax,44
	mul	word ptr coudir
	add	ax,offset dtatab
	mov	odta,ax
	mov	dx,ax
	mov	ah,1ah
	int	21h
	ret
stdta	endp
pdir	proc	near
	push	si
	lea	si,curdir
	clr	dl
	mov	ah,47h
	int	21h
	lea	si,curdir
	calln	printz
	callp	carret
	pop	si
	ret
pdir	endp
prog	ends

tail	segment word 'prog'     ;help segment to allocate end of code
xtail	dw	-1		;and set the data segment
tail	ends

data	segment para public 'data'     ;data segment


fname	db	10h dup(0)
ffname	db	10h dup(0)
mydta	db	48  dup(?)
bufer	db	28h dup(0)
dtatab	dtas	12  dup(<>)
curdir	db	64 dup(?)
_ss	dw	?	;Lattice variables
_base	dw	?	;Lattice variables
_dos	dw	?	;Lattice variables
_top	dw	?	;Lattice variables
odta	dw	0
olddta	dd	0
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
coudir	dw	0
fflag	dw	0
;notfnd  db	 'File not found',13,10,'$'
copyr	db	'Dianakiller program V1.1  (C)Copyright Deny_Soft 1989',13,10,'$'
tryrem	db	'Searching Diana in memory..',13,10,'$'
diakt	db	'Diana found',7,' and removed extra',13,10,'$'
dinakt	db	"Diana isn't active",13,10,"$"
weak	db	'Searching for weak  files...',13,10,'$'
file	db	'File $'
isok	db	9,9,' ... restored',13,10,'$'
carret	db	13,10,'$'
aster	db	'*.*',0
point	db	'..',0
root	db	'\',0

data	ends
	.pub	<_ss,_base,_dos,_top>	;make external
udata	segment public 'data'
udata	ends
xstack	segment 'data'
sbase	dw	512 dup (?)
xstack	ends
	end	start
