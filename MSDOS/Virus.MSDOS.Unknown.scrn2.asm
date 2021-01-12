	TITLE scrn2.asm

;	AUTHOR  Tim Spencer - Compuserve [73657,1400]
;	DATE	March 15, 1987

_TEXT 	SEGMENT BYTE PUBLIC 'CODE'
_TEXT	ENDS

_DATA 	SEGMENT WORD PUBLIC 'DATA'

SCRN	STRUC		; screen data structure - defined in video.h
off	dw	0	; offset (cursor position) 
seg	dw	0	; screen buffer address
port	dw	0	; status port address
attrib	dw	0	; attribute to use 
cgacrd	dw	0	; retrace checking enabled if not zero
SCRN 	ENDS

_DATA	ENDS

DGROUP	GROUP _DATA
	ASSUME CS:_TEXT, DS:DGROUP, SS:DGROUP, ES:NOTHING


_TEXT	SEGMENT BYTE PUBLIC 'CODE'

;-----------------------------------------------------------------------;
; scrn_puts - MSC callable routine for printing a string directly to 	;
;	      the screen buffer.					;
;									;
; Usage:	scrn_puts(string, attribute, &structure_name);		;
;-----------------------------------------------------------------------;
_DATA	SEGMENT
scrn_puts_args STRUC		; args as pushed by calling program
	dw	0		; saved bp value
	dw	0		; return address
str_ptr	dw	0		; address of string
sstruc	dw	0		; pointer to SCRN structure
scrn_puts_args ENDS
_DATA	ENDS

	PUBLIC _scrn_puts

_scrn_puts	PROC	NEAR
	push	bp			;set up frame pointer
	mov	bp,sp		
	push	di
	push	si
	mov	si,[bp].str_ptr		; get the string pointer 
        mov	bx,[bp].sstruc 		; get pointer to SCRN structure
	les	di,dword ptr[bx].off	; put offset in di, buffer addr in es   
	mov	ch,byte ptr[bx].attrib	; put attribute in cx
	mov	dx,[bx].port		; get status port address

load_one:
	lodsb				; load a char and advance str ptr
	or	al,al			; is it null ?
	jz	puts_exit		; yes, lovely chatting. Chow babe.
	mov	cl,al			; no, save in cl for a few millisecs
	cmp	[bx].cgacrd, 0		; cga card present?
	jnz	swait1			; yes...go wait
	mov	ax,cx			; no.
	stosw				; write it
	jmp	short load_one		; as fast as you can!
swait1:
        in      al, dx                  ; wait for end of retrace
        shr     al, 1                   ; test horizontal trace bit
        jc      swait1			; loop if still tracing
        cli                             ; disable writus interuptus
swait2:
        in      al, dx                  ; now wait until the very moment
        shr     al, 1                   ; when the next retrace begins
        jnc     swait2			; still waiting...
        mov     al,cl			; load the char into al for stosb
        stosb				; write it and update pointer
        sti                             ; enable interrupts again
swait3:
        in      al, dx                  ; repeat these steps for the attribute
        shr     al, 1
        jc      swait3
        cli                             
swait4:
        in      al, dx                  
        shr     al, 1                   
	jnc     swait4
        mov     al,ch			; load the attribute
        stosb
        sti                             
	jmp	short load_one		; and get another

puts_exit:
	mov	[bx].off,di 		; save new offset ( cur pos )
	pop	si
	pop	di
	pop	bp
	ret
_scrn_puts	ENDP



;-----------------------------------------------------------------------;
; scrn_putca - MSC callable function to print a char and attribute	;
;	       directly to the screen buffer. The logical cursor	;
;	       position IS UPDATED on return.				;	
;									;
; Usage:	scrn_putca(char, attribute, &structure_name		;
;-----------------------------------------------------------------------;
_DATA	SEGMENT
scrn_putca_args STRUC			; args as pushed by calling program
	dw	0 			; saved bp value
	dw	0			; return address
pchar	dw	0			; char to write
pstruc	dw	0			; pointer to SCRN structure
scrn_putca_args ENDS
_DATA	ENDS

	PUBLIC	_scrn_putca	

_scrn_putca	PROC	NEAR
	push	bp			; set up frame pointer
	mov	bp,sp
	push	di
	mov	bx,[bp].pstruc		; get pointer to SCRN structure
	les	di,dword ptr[bx].off	; get offset in di, buffer addr in es
	mov	dx,[bx].port		; status port address
	mov	ch,byte ptr[bx].attrib	; get attribute into ch
	mov	cl,byte ptr[bp].pchar	;  and char into cl
	cmp	[bx].cgacrd, 0		; cga card present?
	jnz	cwait1			; yes...go wait
	mov	ax,cx			; no.
	stosw				; write it
	jmp	short cexit		; exit.

cwait1:
        in      al, dx                  ; wait for end of retrace
        shr     al, 1                   ; test horizontal trace bit
        jc      cwait1			; loop if still tracing
        cli                             ; disable writus interuptus
cwait2:
        in      al, dx                  ; now wait until the very moment
        shr     al, 1                   ; when the next retrace begins
        jnc     cwait2			; still waiting...
        mov     al,cl			; load the char into al for stosb
        stosb				; write it and update pointer
        sti                             ; enable interrupts again
cwait3:
        in      al, dx                  ; repeat these steps for the attribute
        shr     al, 1
        jc      cwait3
        cli                             
cwait4:
        in      al, dx                  
        shr     al, 1                   
	jnc     cwait4
        mov     al,ch			; load the attribute
        stosb
        sti				; whew...all done...enable interrupts
cexit:
	mov	[bx].off, di		; update logical cursor position
	pop	di			;  (offset) before leaving
	pop	bp
	ret	
_scrn_putca	ENDP


;-----------------------------------------------------------------------;
; _scrn_getca - get char and attrib from screen				;
;									;
; usage:	char = scrn_getca(&attrib,p_scn_data) 			;
;									;
;-----------------------------------------------------------------------;
_DATA	SEGMENT
getca_args STRUC		; input arguments
	dw	0		; saved BP value
	dw	0		; return address
gattrib	dw	0		; store attribute here 
gstruct	dw	0		; pointer to SCRN
getca_args ENDS
_DATA	ENDS

	PUBLIC	_scrn_getca

_scrn_getca	PROC	NEAR
	push	bp			; set up frame pointer
	mov	bp,sp		
	push	si
	
        mov	bx,[bp].gstruct		; get pointer to SCRN structure
	mov	dx,[bx].port		; get status port address
	push	ds			; lds uses ds - must save
	lds	si,dword ptr[bx].off	; get offset and segment address
gwait1:
        in      al, dx                  ; wait for end of retrace
        shr     al, 1                   ; test horizontal trace bit
        jc      gwait1			; loop if still tracing
        cli                             ; disable writus interuptus
gwait2:
        in      al, dx                  ; now wait until the very moment
        shr     al, 1                   ; when the next retrace begins
        jnc     gwait2			; still waiting...
        lodsb				; get the char into al
        sti                             ; enable interrupts again
	mov	cl,al			; save the char in cl
gwait3:
        in      al, dx                  ; repeat these steps for the attribute
        shr     al, 1
        jc      gwait3
        cli                             
gwait4:
        in      al, dx                  
        shr     al, 1                   
	jnc     gwait4
        lodsb				; get the attribute in al
        sti                             
	pop	ds			; restore data segment to norm
	mov	word ptr [bx],si 	; update offset (logical cursor)
	mov	si,word ptr[bp].gattrib	; get address to store attrib
        mov	byte ptr [si],al 	; store the attribute at "&attrib"
	mov	al,cl			; move the char to al and
	xor	ah,ah			;  zero out ah so that ax = char,
					;   the return value
	pop	si
	pop	bp
	ret
_scrn_getca	ENDP
		
_TEXT	ENDS

	END
		 