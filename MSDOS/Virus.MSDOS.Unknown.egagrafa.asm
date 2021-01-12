;
; grafix --- egagrafa.asm
;
; stuff to plot points fast in 8086 assembler (BLEECH!!!)
;
; Written 4/87 by Scott Snyder (ssnyder@romeo.caltech.edu or @citromeo.bitnet)
;
; Modified 5/29/87 by sss to allow for different memory models
;

	title	egagrafa

include macros.ah

sseg
endss

g_linsiz  equ	80
g_pixbyte equ	8
ega_gr_data equ 03cfh

dseg

	ex g_drawbuf,     dword
	ex g_xor,         word
	ex g_xcliplo,     word
	ex g_xcliphi,     word
	ex g_ycliplo,     word
	ex g_ycliphi,     word

endds

	exProc EGA_point_set
	exProc EGA_point_res

cseg	_egagrafa

EGA_plot label byte			; to get accurate profiling data

; plot a point. ax = y; bl = c; cx = x;

pBegin	plot

	les	si, g_drawbuf		; get address of buffer
	mov	dx, g_linsiz		; y * g_linsiz
	mul	dx
	add	si, ax			; add to offset
	mov	ax, cx			; x to AC (ohhh... what symmetry!)
	mov	cx, g_pixbyte		; move it to use it...
	div	cx
	add	si, ax			; add quotient to offset (now complete)
	mov	al, 80h			; make mask
	mov	cx, dx
	shr	ax, cl			; shift it
	mov	dx, ega_gr_data		; shove it out to the mask register
	out	dx, al
	mov	al, es:[si]		; read data into latches
	mov	es:[si], al		; and do a write
	ret

pEnd	plot

;
; C interface for point plotter
;
; EGA_point(x, y, c)
;

pBegin	EGA_point

	push	bp
	mov	bp, sp
	push	si
	push	di

	push	[bp+argbase+4]			; call setup routine
	call	EGA_point_set
	add	sp, 2

	mov	ax, [bp+argbase+2]
	mov	bx, [bp+argbase+4]
	mov	cx, [bp+argbase]
	call	plot

	call	EGA_point_res		; reset EGA

	pop	di
	pop	si
	mov	sp, bp
	pop	bp
	ret

pEnd	EGA_point

;
; write for pixels for circle drawing
;
; void EGA_write_pix(x1, y1, x2, y2, c)
;
; can just ignore color here 'cause that's all setup at setup time...
;

pBegin	EGA_write_pix

	push	bp
	mov	bp, sp
	push	si
	push	di

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

	push	cx			; plot (x1, y1)
	call	plot
	pop	cx

w1:	mov	ax, [bp+argbase+6]	; ax = y2
	cmp	ax, g_ycliplo
	jb	w2
	cmp	ax, g_ycliphi
	ja	w2

	call	plot			; plot (x1, y2)

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

	push	cx			; plot (x2, y1)
	call	plot
	pop	cx

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

pEnd	EGA_write_pix

	df_ EGA_point
	df_ EGA_write_pix
	df_ EGA_plot

endcs	_egagrafa

end
