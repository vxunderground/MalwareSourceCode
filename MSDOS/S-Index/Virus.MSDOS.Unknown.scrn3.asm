	TITLE	scrn3.asm

;	AUTHOR	Tim Spencer - Compuserve [73657,1400]
;	DATE	March 17, 1987

_TEXT 	SEGMENT BYTE PUBLIC 'CODE'
_TEXT	ENDS

_DATA 	SEGMENT WORD PUBLIC 'DATA'
SCRN	STRUC		; screen data structure - defined in video.h
off	dw	0	; offset (cursor position) 
seg	dw	0	; screen buffer address
port	dw	0	; status port address
attrib	dw	0	; attribute to use 
cgacrd	dw	0	; enable retrace checking if not zero
SCRN 	ENDS

_DATA	ENDS

DGROUP	GROUP _DATA
	ASSUME CS:_TEXT, DS:DGROUP, SS:DGROUP, ES:NOTHING


_TEXT	SEGMENT BYTE PUBLIC 'CODE'

;-----------------------------------------------------------------------;
; scrn_restore - MSC callable function to restore a rectangular area	;
; 		 of the screen buffer.	Checks for vertical retrace	;
;		 only if the external structure member cga_card is	;
;		 non-zero. &scrn is the address of that structure.	;
;		 (see video.h).						;
;									;									;
; Note:	This procedure uses stosb in retrace checking mode (instead of	;
;       movsb) because it stuffs the char/attrib into the screen buffer	;
;       slightly faster.						;
;									;
; Usage:   scrn_restore(left, right, top, bottom, data_buff, &scrn)	;
;									;
;-----------------------------------------------------------------------;
_DATA SEGMENT
restore_args STRUC		; structure for easy argument reference
	dw	0		; saved BP value
	dw	0		; return address
rleft	dw	0		; rectangular boundries...
rright	dw	0
rtop	dw	0
rbottom	dw	0
mdata	dw	0		; address of data buffer to write to screen
mstruct	dw	0		; pointer to SCRN structure(defined in video.h)
restore_args ENDS

cga	db	0		; variable to hold cga_card value
_DATA ENDS

	PUBLIC	_scrn_restore

_scrn_restore	PROC	NEAR
	push	bp			; set up frame pointer
	mov	bp,sp		
	push	si			
	push	di
	mov	bx,[bp].mstruct		; get pointer to SCRN structure
	les	di,dword ptr[bx].off	; get scrn seg in es, off in di
	mov	dx,[bx].port		; get status port address
	mov	ax,[bx].cgacrd 		; hold cga status in variable cga
	mov	cga,al
	mov	si,[bp].mdata		; make si point to data buffer
	mov	bh,byte ptr[bp].rtop	; top will be incremented until it
	mov	bl,byte ptr[bp].rbottom	;  is greater than bottom, then exit.
	xor	cx,cx			; set initial logical cursor position
	mov	cl,bh			;  by getting top into cx,
	mov	al,80			;  multiplying by 80,
	mul	cl
	mov	cx,ax
	add	cx,[bp].rleft		;  adding left.
	shl	cx,1			;  and multiplying by 2
	mov	di,cx			;  put result into di 
	mov	cx,[bp].rright		; get the length of one line into
	sub	cx,[bp].rleft		;  cx by subtracting left from right
	add	cx,1			;  adding 1
	push	cx			;  save it
	mov	ax,79			; calculate offset from end of line to
	sub	ax,[bp].rright		;  the start of the next line
	add	ax,[bp].rleft
	shl	ax,1
	push	ax			;  and save it
write_line:
	cmp	cga,0			; cga card in use?
	jnz	rwait1			; yes, go wait
	rep	movsw			; no, warp speed.
	jmp	short rcheck_pos	; go check position	 
rwait1:
        in      al, dx                  ; wait for end of retrace
        shr     al, 1                   ; test horizontal trace bit
        jc      rwait1			; loop if still tracing
        cli                             ; disable writus interuptus
rwait2:
        in      al, dx                  ; now wait until the very moment
        shr     al, 1                   ; when the next retrace begins
        jnc     rwait2			; still waiting...
        mov     al,[si]			; load the char into al for stosb
        stosb				; write it and update pointer
        sti                             ; enable interrupts again
	inc	si			; point si at attribute
rwait3:
        in      al, dx                  ; repeat these steps for the attribute
        shr     al, 1
        jc      rwait3
        cli                             
rwait4:
        in      al, dx                  
        shr     al, 1                   
	jnc     rwait4
        mov     al,[si]			; load the attribute
        stosb
        sti  
	inc	si			; point si at next char                           
	loop	rwait1
rcheck_pos:
	pop	ax			; restore offset to next line start
	pop	cx			; restore count
	inc	bh			; is top greater than bottom yet?
	cmp	bh,bl
	ja	rexit			; yes.
	push	cx			; no, save count again
	push	ax			; save line start offset again
	add	di,ax			; move di to start of next line
	jmp	short write_line	; write another line
rexit:
	pop	di
	pop	si
	pop	bp
	ret
_scrn_restore	ENDP



;-----------------------------------------------------------------------;
; scrn_save - MSC callable function to save a rectangular area of the	;
;	      screen to a user defined buffer. 				;
;									;
; Usage:	scrn_save(left, right, top, bottom, data_buff, &scrn)	;
;-----------------------------------------------------------------------;
_DATA	SEGMENT
save_args STRUC			; structure for easy argument reference	
	dw	0		; saved bp value
	dw	0		; return address
sleft	dw	0		; rectangular boundries
sright	dw	0		
stop	dw	0
sbottom	dw	0
sbuff	dw	0		; user defined buffer to hold screen contents
sstruct	dw	0		; pointer to SCRN structure (see video.h)
save_args ENDS		
_DATA	ENDS

scga	db	0		; store cga true/false value here - must be
				; declared outside data segment because es and
				; ds are swapped in this function.

	PUBLIC	_scrn_save

_scrn_save	PROC	NEAR
	push	bp			; set up frame pointer
	mov	bp,sp	
	push	si			
	push	di
	push	ds
	mov	bx,[bp].mstruct		; get pointer to SCRN structure
	mov	dx,[bx].port		; get status port address
	mov	ax,[bx].cgacrd 		; hold cga status in variable scga
	mov	scga,al
	mov	ax,ds
	mov	es,ax			; get data segment into es 
	mov	di,[bp].sbuff		;  and offset of user buffer in di	
	mov	ax,[bx].seg		; get the screen segment and
	mov	ds,ax			;  put in ds 	
	mov	bh,byte ptr[bp].stop	; top will be incremented until it
	mov	bl,byte ptr[bp].sbottom	;  is greater than bottom, then exit.
	xor	cx,cx			; set initial logical cursor position
	mov	cl,bh			;  by getting top into cx,
	mov	al,80			;  multiplying by 80,
	mul	cl
	mov	cx,ax
	add	cx,[bp].sleft		;  adding left.
	shl	cx,1			;  and multiplying by 2
	mov	si,cx			;  put result into si 
	mov	cx,[bp].sright		; get the length of one line into
	sub	cx,[bp].sleft		;  cx by subtracting left from right
	add	cx,1			;  adding 1
	push	cx			;  save it
	mov	ax,79			; calculate offset from end of line to
	sub	ax,[bp].sright		;  the start of the next line
	add	ax,[bp].sleft
	shl	ax,1
	push	ax			;  and save it
read_line:
	cmp	cga,0			; cga card in use?
	jnz	swait1			; yes, go wait
	rep	movsw			; no, warp speed.
	jmp	short scheck_pos	; go check position	 
swait1:
        in      al, dx                  ; wait for end of retrace
        shr     al, 1                   ; test horizontal trace bit
        jc      swait1			; loop if still tracing
        cli                             ; disable writus interuptus
swait2:
        in      al, dx                  ; now wait until the very moment
        shr     al, 1                   ; when the next retrace begins
        jnc     swait2			; still waiting...
        mov     al,[si]			; load the char into al for stosb
        stosb				; write it and update pointer
        sti                             ; enable interrupts again
	inc	si			; point si at attribute
swait3:
        in      al, dx                  ; repeat these steps for the attribute
        shr     al, 1
        jc      swait3
        cli                             
swait4:
        in      al, dx                  
        shr     al, 1                   
	jnc     swait4
        mov     al,[si]			; load the attribute
        stosb
        sti  
	inc	si			; point si at next char                           
	loop	swait1
scheck_pos:
	pop	ax			; restore offset to next line start
	pop	cx			; restore count
	inc	bh			; is top greater than bottom yet?
	cmp	bh,bl
	ja	sexit			; yes.
	push	cx			; no, save count again
	push	ax			; save line start offset again
	add	si,ax			; move di to start of next line
	jmp	short read_line		; write another line
sexit:
	pop	ds
	pop	di
	pop	si
	pop	bp
	ret
_scrn_save	ENDP


_TEXT	ENDS

	END
