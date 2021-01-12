;
; grafix --- cgagrafa.asm
;
; stuff to plot points fast in 8086 assembler (BLEECH!!!)
;
; Written 4/87 by Scott Snyder (ssnyder@romeo.caltech.edu or @citromeo.bitnet)
;
; Modified 5/29/87 by sss to allow for different memory models
;

	title	cgagrafa

include macros.ah

sseg
endss

g_oddoff equ	02000h
g_linsiz equ	80

dseg

	ex g_drawbuf,     dword
	ex g_pixbyte,     word
	ex g_bitpix,      word
	ex g_colormask,   byte
	ex g_cmask_tbl,   byte
	ex g_hicolormask, byte
	ex g_xor,         word
	ex g_xcliplo,     word
	ex g_xcliphi,     word
	ex g_ycliplo,     word
	ex g_ycliphi,     word

endds

cseg _cgagrafa

; plot a point. ax = y; bl = c; cx = x;

pBegin	plot

	les	si, g_drawbuf		; get address of buffer
	sar	ax, 1			; y /= 2
	jnc	p1			; add in offset if it was odd
	add	si, g_oddoff
p1:	mov	dx, g_linsiz		; y * g_linsiz
	mul	dx
	add	si, ax			; add to offset
	mov	ax, cx			; x to AC (ohhh... what symmetry!)
	mov	dx, 0
	div	g_pixbyte
	add	si, ax			; add quotient to offset (now complete)
	and	bl, g_colormask		; get cmask
	mov	bl, g_cmask_tbl[bx]
	mov	cx, g_bitpix		; only works for bitpix = 0 or 1!
	dec	cx
	shl	dx, cl			; dx = mask shift count
	mov	cx, dx
	mov	dl, g_hicolormask	; get mask
	shr	dl, cl			; shift it
	and	bx, dx			; bx = cmask & mask
	mov	al, es:[si]		; get image byte
	cmp	g_xor, 0		; xor mode?
	jne	p2
	not	dl			; no - (*ptr & ~mask) | (cmask & mask)
	and	al, dl
	or	al, bl
	jmp	p3
p2:	xor	al, bl			; yes - *ptr ^ (cmask & mask)
p3:	mov	es:[si], al		; done!
	ret

pEnd	plot

;
; C interface for point plotter
;
; CGA_point(x, y, c)
;

pBegin	CGA_point
	push	bp
	mov	bp, sp
	push	si
	push	di

	mov	ax, [bp+argbase+2]
	mov	bx, [bp+argbase+4]
	mov	cx, [bp+argbase]
	call	plot

	pop	di
	pop	si
	mov	sp, bp
	pop	bp
	ret

pEnd	CGA_point

;
; write for pixels for circle drawing
;
; void CGA_write_pix(x1, y1, x2, y2, c)
;

pBegin	CGA_write_pix

	push	bp
	mov	bp, sp
	push	si
	push	di

	mov	bx, [bp+argbase+8]	; bx = c (for plot)
	mov	cx, [bp+argbase]	; cx = x1
	cmp	cx, g_xcliplo		; check for clipping
	jb	w2
	cmp	cx, g_xcliphi
	ja	w2

	mov	ax, [bp+argbase+2]	; ax = y1
	cmp	ax, g_ycliplo		; do clipping
	jb	w1
	cmp	ax, g_ycliphi
	ja	w1

	push	bx			; plot (x1, y1)
	push	cx
	call	plot
	pop	cx
	pop	bx

w1:	mov	ax, [bp+argbase+6]	; ax = y2
	cmp	ax, g_ycliplo
	jb	w2
	cmp	ax, g_ycliphi
	ja	w2

	push	bx			; plot (x1, y2)
	call	plot
	pop	bx

w2:	mov	cx, [bp+argbase+4]	; cx = x2
	cmp	cx, g_xcliplo
	jb	w4
	cmp	cx, g_xcliphi
	ja	w4

	mov	ax, [bp+argbase+2]	; ax = y1
	cmp	ax, g_ycliplo		; do clipping
	jb	w3
	cmp	ax, g_ycliphi
	ja	w3

	push	bx			; plot (x2, y1)
	push	cx
	call	plot
	pop	cx
	pop	bx

w3:	mov	ax, [bp+argbase+6]	; ax = y2
	cmp	ax, g_ycliplo
	jb	w4
	cmp	ax, g_ycliphi
	ja	w4

	call	plot			; plot (x2, y2)

w4:	pop	di
	pop	si
	mov	sp, bp
	pop	bp
	ret

pEnd	CGA_write_pix

	df_ CGA_point
	df_ CGA_write_pix

endcs	_cgagrafa

end
