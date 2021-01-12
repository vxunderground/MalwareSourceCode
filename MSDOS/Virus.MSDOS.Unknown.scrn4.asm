	TITLE	scrn4.asm

;	AUTHOR	Tim Spencer - Compuserve [73657,1400]
;	DATE	March 19, 1987
	
_TEXT 	SEGMENT BYTE PUBLIC 'CODE'
_TEXT	ENDS

_DATA 	SEGMENT WORD PUBLIC 'DATA'
_DATA	ENDS

DGROUP	GROUP _DATA
	ASSUME CS:_TEXT, DS:DGROUP, SS:DGROUP, ES:NOTHING


_TEXT	SEGMENT BYTE PUBLIC 'CODE'

;-----------------------------------------------------------------------;
; vcard_type - Tests for type of video card in use			;
;									;
; Returns: 	0	=	MONOCHROME ADAPTER			;
;		1	=	COLOR GRAPHICS ADAPTER			;
;		2	=	ENHANCED GRAPHICS ADAPTER		;
;-----------------------------------------------------------------------;

	PUBLIC _vcard_type

_vcard_type	PROC	NEAR
	push	es
	mov	ax,40h			; point es to BIOS area
	mov	es,ax
	mov	al,es:[87h]		; is there an EGA card?
	cmp	al,0
	je	mono_test		; no ega, check for mono
	test	al,00001000b		; test bit 3
	jnz	mono_test		; bit 3 was set - ega not active card
	mov	ax,2			; ega is in use...return a 2 
	jmp	short exit
mono_test:
	mov	al,es:[10h]		; get video status byte
	and	al,00110000b		; isolate bits 4 and 5
	cmp	al,48			; is it a mono card?
	jne	assume_cga		; no, assume it's a cga
	mov	ax,0			; return 0 for mono card
	jmp	short exit
assume_cga:
	mov	ax,1			; return a 1 for cga card
exit:	pop	es
	ret
_vcard_type	ENDP

_TEXT	ENDS

	END
	