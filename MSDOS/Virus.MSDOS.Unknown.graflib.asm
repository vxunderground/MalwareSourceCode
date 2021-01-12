;
; grafix --- graflib.asm
;
; miscellaneous assembly routines
;
; Written 4/87 by Scott Snyder (ssnyder@romeo.caltech.edu or @citromeo.bitnet)
;
; Modified 5/29/87 by sss to allow for different memory models
;

	title	graflib

include	macros.ah

buflen equ 32768

sseg
endss

dseg
endds

buf	segment public 'BUF'
	db buflen dup(?)
buf	ends

cseg	_graflib

pBegin	g_bufseg

	mov	ax, buf
	ret

pEnd	g_bufseg

pBegin	g_fmemcpy 

	push	bp
	mov	bp,sp
	push	di
	push	si
	push	ds

	cld 
	les	di,[bp+argbase]
	lds	si,[bp+argbase+4]
	mov	cx,[bp+argbase+8]
	shr	cx, 1
	jnc	c1
	movsb
c1:	rep	movsw
  
	pop	ds
	pop	si
	pop	di
	mov	sp,bp
	pop	bp
	ret

pEnd	g_fmemcpy

pBegin	g_fmemset

	push	bp
	mov	bp,sp
	push	di
	push	si

	cld 
	les	di,[bp+argbase]
	mov	al,[bp+argbase+4]
	mov	ah,al
	mov	cx,[bp+argbase+6]
	shr	cx,1
	jnc	s1
	stosb
s1:	rep	stosw
  
	pop	si
	pop	di
	mov	sp,bp
	pop	bp
	ret

pEnd	g_fmemset

	df_	g_fmemcpy
	df_	g_fmemset
	df_	g_bufseg

endcs	_graflib 
 
	end
