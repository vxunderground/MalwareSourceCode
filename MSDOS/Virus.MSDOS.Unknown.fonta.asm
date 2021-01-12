
PAGE  59,132

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл								         лл
;лл			        FONTA				         лл
;лл								         лл
;лл      Created:   19-Jan-92					         лл
;лл      Code type: special					         лл
;лл      Passes:    5	       Analysis Options on: none	         лл
;лл								         лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

data_28e	equ	1003h			;*
data_29e	equ	1232h			;*
data_30e	equ	180Ch			;*
data_33e	equ	2005h			;*
data_36e	equ	2412h			;*
data_38e	equ	3079h			;*
data_47e	equ	7830h			;*
data_50e	equ	91F0h			;*
data_51e	equ	99BDh			;*
data_53e	equ	0A901h			;*
data_56e	equ	0B3A1h			;*
data_60e	equ	0BD01h			;*
data_61e	equ	0BF04h			;*
data_70e	equ	0F601h			;*
data_71e	equ	0F630h			;*
data_72e	equ	0F712h			;*

;--------------------------------------------------------------	seg_a  ----

seg_a		segment	byte public
		assume cs:seg_a , ds:seg_a

		mov	ax,3463h
		mov	dx,75Ch
		cmp	ax,sp
		jae	loc_2			; Jump if above or =
		mov	ax,sp
		sub	ax,344h
		and	ax,0FFF0h
		mov	di,ax
		mov	cx,0A2h
		mov	si,17Ch
		cld				; Clear direction
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		mov	bx,ax
		mov	cl,4
		shr	bx,cl			; Shift w/zeros fill
		mov	cx,ds
		add	bx,cx
		push	bx
		xor	bx,bx			; Zero register
		push	bx
		retf				; Return far
		db	 0Dh, 01h, 41h
		db	'nother Fine aHa/nBa Elite/WareZZ'
		db	'ZZZZZZZZZZZZZZZZNot enough memor'
		db	'y$'
loc_2:
		mov	ax,900h
		mov	dx,15Fh
		int	21h			; DOS Services  ah=function 09h
						;  display char string at ds:dx
		int	20h			; DOS program terminate
		nop
		std				; Set direction flag
		mov	di,ax
		dec	di
		dec	di
		mov	si,offset data_22
		add	si,dx
		mov	cx,dx
		shr	cx,1			; Shift w/zeros fill
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		cld				; Clear direction
		xchg	si,di
		inc	si
		inc	si
		mov	di,100h
		lodsw				; String [si] to ax
		xchg	ax,bp
		mov	dx,10h
		jmp	short loc_12
		db	90h
loc_3:
		lodsw				; String [si] to ax
		xchg	ax,bp
		mov	dl,10h
		jmp	short loc_14
loc_4:
		lodsw				; String [si] to ax
		xchg	ax,bp
		mov	dl,10h
		jmp	short loc_15
loc_5:
		lodsw				; String [si] to ax
		xchg	ax,bp
		mov	dl,10h
		jmp	short loc_16
loc_6:
		lodsw				; String [si] to ax
		xchg	ax,bp
		mov	dl,10h
		jmp	short loc_20
loc_7:
		lodsw				; String [si] to ax
		xchg	ax,bp
		mov	dl,10h
		jmp	short loc_21
loc_8:
		lodsw				; String [si] to ax
		xchg	ax,bp
		mov	dl,10h
		jmp	short loc_22
loc_9:
		lodsw				; String [si] to ax
		xchg	ax,bp
		mov	dl,10h
		jmp	short loc_23
loc_10:
		lodsw				; String [si] to ax
		xchg	ax,bp
		mov	dl,10h
		jc	loc_13			; Jump if carry Set
loc_11:
		movsb				; Mov [si] to es:[di]
loc_12:
		shr	bp,1			; Shift w/zeros fill
		dec	dx
		jz	loc_10			; Jump if zero
		jnc	loc_11			; Jump if carry=0
loc_13:
		xor	cx,cx			; Zero register
		xor	bx,bx			; Zero register
		shr	bp,1			; Shift w/zeros fill
		dec	dx
		jz	loc_3			; Jump if zero
loc_14:
		rcl	bx,1			; Rotate thru carry
		shr	bp,1			; Shift w/zeros fill
		dec	dx
		jz	loc_4			; Jump if zero
loc_15:
		rcl	bx,1			; Rotate thru carry
		test	bx,bx
		jz	loc_18			; Jump if zero
		shr	bp,1			; Shift w/zeros fill
		dec	dx
		jz	loc_5			; Jump if zero
loc_16:
		rcl	bx,1			; Rotate thru carry
		cmp	bl,6
		jb	loc_18			; Jump if below
		shr	bp,1			; Shift w/zeros fill
		dec	dx
		jnz	loc_17			; Jump if not zero
		lodsw				; String [si] to ax
		xchg	ax,bp
		mov	dl,10h
loc_17:
		rcl	bx,1			; Rotate thru carry
loc_18:
		mov	cl,byte ptr cs:[11Ch][bx]
		cmp	cl,0Ah
		je	loc_26			; Jump if equal
loc_19:
		xor	bx,bx			; Zero register
		cmp	cx,2
		je	loc_25			; Jump if equal
		shr	bp,1			; Shift w/zeros fill
		dec	dx
		jz	loc_6			; Jump if zero
loc_20:
		jc	loc_25			; Jump if carry Set
		shr	bp,1			; Shift w/zeros fill
		dec	dx
		jz	loc_7			; Jump if zero
loc_21:
		rcl	bx,1			; Rotate thru carry
		shr	bp,1			; Shift w/zeros fill
		dec	dx
		jz	loc_8			; Jump if zero
loc_22:
		rcl	bx,1			; Rotate thru carry
		shr	bp,1			; Shift w/zeros fill
		dec	dx
		jz	loc_9			; Jump if zero
loc_23:
		rcl	bx,1			; Rotate thru carry
		cmp	bl,2
		jae	loc_27			; Jump if above or =
loc_24:
		mov	bh,byte ptr cs:[12Ch][bx]
loc_25:
		lodsb				; String [si] to al
		mov	bl,al
		push	si
		mov	si,di
		sub	si,bx
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	si
		jmp	short loc_12
loc_26:
		lodsb				; String [si] to al
		add	cl,al
		adc	ch,0
		cmp	al,0FFh
		jne	loc_19			; Jump if not equal
		jmp	short loc_31
loc_27:
		shr	bp,1			; Shift w/zeros fill
		dec	dx
		jnz	loc_28			; Jump if not zero
		lodsw				; String [si] to ax
		xchg	ax,bp
		mov	dl,10h
loc_28:
		rcl	bx,1			; Rotate thru carry
		cmp	bl,8
		jb	loc_24			; Jump if below
		shr	bp,1			; Shift w/zeros fill
		dec	dx
		jnz	loc_29			; Jump if not zero
		lodsw				; String [si] to ax
		xchg	ax,bp
		mov	dl,10h
loc_29:
		rcl	bx,1			; Rotate thru carry
		cmp	bl,17h
		jb	loc_24			; Jump if below
		shr	bp,1			; Shift w/zeros fill
		dec	dx
		jnz	loc_30			; Jump if not zero
		lodsw				; String [si] to ax
		xchg	ax,bp
		mov	dl,10h
loc_30:
		rcl	bx,1			; Rotate thru carry
		and	bx,0DFh
		xchg	bl,bh
		jmp	short loc_25
loc_31:
		xor	ax,ax			; Zero register
		push	es
		mov	bx,100h
		push	bx
		mov	bx,ax
		mov	cx,ax
		mov	dx,ax
		mov	bp,ax
		mov	si,ax
		mov	di,ax
		retf				; Return far
		db	 03h, 00h, 02h, 0Ah, 04h, 05h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 06h, 07h, 08h, 09h, 01h, 02h
		db	 00h, 00h, 03h, 04h, 05h, 06h
		db	 00h
		db	7 dup (0)
		db	 07h, 08h, 09h, 0Ah, 0Bh, 0Ch
		db	 0Dh, 90h,0A0h, 00h,0EBh, 33h
		db	 90h, 0Dh, 20h, 01h, 0Dh, 0Ah
		db	 20h, 41h, 6Eh, 6Fh, 00h, 00h
		db	'ther fine aHa/nB'
		db	0C0h
		db	9, 'a WAREZ'
		db	 01h, 00h, 1Ah, 03h, 00h, 40h
		db	 02h, 01h, 01h, 04h, 7Ah, 10h
		db	 00h, 01h,0B8h, 00h, 05h,0CDh
		db	 10h,0B4h, 0Fh, 01h, 80h, 04h
		db	0BFh, 2Ch, 01h, 8Ah, 25h, 3Ah
		db	0C4h, 74h, 06h, 8Ah,0C4h, 32h
		db	0E4h, 02h
		db	45h
loc_33:
;*		pop	cs			; Dangerous 8088 only
		db	0Fh
		mov	bp,163h
		mov	di,data_29e
		cmp	ax,1B9h
		or	ah,[bp+di]
		xor	dx,dx			; Zero register
		xor	bl,bl			; Zero register
		mov	ax,1110h
		adc	al,0C3h
		nop
		sbb	ax,50h
		pop	es
		add	[bp-7Fh],di
		movsw				; Mov [si] to es:[di]
		add	word ptr ds:data_51e[bx+di],284Eh
		add	al,7Eh			; '~'
		adc	[si-2],bh
		db	0FEh,0D6h, 03h,0B8h,0A9h,0BAh
		db	0C6h,0FEh, 7Ch, 21h, 6Ch,0EEh
		db	 0Fh,0C2h, 8Dh, 01h, 7Ch, 38h
		db	 10h, 10h, 10h, 38h, 7Ch, 3Eh
		db	0ABh, 01h, 0Eh, 10h, 0Dh,0D4h
		db	 9Fh, 24h, 6Ch, 07h, 1Fh,0FEh
		db	0A4h, 43h,0FEh, 10h, 01h, 18h
		db	 3Ch, 9Ch, 26h, 01h, 18h, 0Bh
		db	0FFh, 01h,0E7h, 65h, 3Bh,0C3h
		db	 01h,0E7h, 0Ah,0FFh,0D5h, 7Dh
		db	 1Fh, 66h, 01h, 21h,0AAh,0BBh
		db	 1Fh, 99h, 01h, 21h, 80h, 74h
		db	 12h, 1Eh
		db	 0Eh, 1Eh, 36h, 78h,0CCh, 01h
		db	 78h, 9Eh,0B8h
		db	 42h, 2Dh, 7Eh
		db	 18h, 18h, 91h, 70h
loc_36:
		push	dx
		push	ds
		sbb	bl,ds:data_30e
		js	loc_36			; Jump if sign=1
		jo	loc_41			; Jump if overflow=1
		push	ax
		adc	byte ptr ds:[236h],bh
		db	 36h, 76h,0F6h, 66h, 4Eh, 12h
		db	 37h, 0Ch, 7Dh,0DBh, 7Eh, 33h
		db	 3Ch, 7Eh, 37h, 00h,0DBh, 30h
		db	 00h, 80h,0E0h,0F0h,0FCh,0FEh
		db	0FCh,0F0h,0E0h
		db	37h
data_22		db	80h
		db	 80h, 10h, 02h, 0Eh, 3Eh, 7Eh
		db	0FEh, 7Eh, 3Eh, 0Eh, 02h, 77h
		db	0D6h,0ADh, 5Ch, 61h,0EBh,0CCh
		db	0B2h, 66h, 01h, 08h, 93h, 24h
		db	 10h, 7Fh,0DBh, 01h, 7Bh, 1Bh
		db	 2Fh, 00h, 01h, 30h,0C6h,0C6h
		db	 60h, 7Ch,0F6h
loc_40:
		xchg	ax,sp
		xchg	bl,dh
		jl	$+0Eh			; Jump if <
		or	[si+0],bh
		push	si
loc_41:
		sbb	word ptr [bp+233h],0FA50h
;*		jg	loc_46			;*Jump if >
		db	 7Fh, 4Fh
		jle	$+5			; Jump if < or =
		db	 60h,0C0h,0FFh, 09h, 0Dh, 70h
		db	 01h, 0Ch, 0Eh,0FFh, 1Ah, 40h
		db	 0Eh, 0Ch, 01h,0A3h, 30h, 70h
		db	0FEh, 70h, 30h, 83h,0D2h, 02h
		db	0B4h,0C0h, 01h,0FEh, 41h,0C3h
		db	 01h, 0Fh, 24h, 66h,0FFh, 66h
		db	 24h, 02h, 90h
		db	42h
		db	 2Fh, 83h, 00h, 8Bh, 0Eh, 1Ah
		db	0FAh, 7Ch, 38h, 01h,0B1h, 04h
		db	 01h, 40h,0D5h, 9Dh, 7Ch, 7Dh
		db	 2Dh, 75h, 90h, 36h, 01h, 14h
		db	 02h
		db	 20h, 65h, 7Bh, 6Ch
		db	 01h,0FEh, 03h, 6Ch, 0Bh,0EAh
		db	0B0h,0F2h
loc_46:
		db	0C0h, 78h, 3Ch, 06h,0EEh, 05h
		db	 38h,0C2h, 00h, 62h, 66h, 0Ch
		db	 18h, 30h, 66h,0C6h, 81h, 80h
		db	 0Dh, 38h, 6Ch, 38h, 30h, 76h
		db	 7Eh,0B0h, 76h,0B3h
		db	0F4h,0CCh, 01h, 18h, 03h, 70h
		db	0DCh,0EEh, 2Bh, 01h, 18h,0E2h
		db	0DCh, 7Ah, 09h, 01h, 18h
		db	 00h,0E2h,0A1h, 0Fh, 42h,0FEh
		db	 38h, 6Ch, 02h,0A3h
		db	0F4h,0AEh,0EFh, 05h,0B7h, 04h
		db	 58h,0FEh,0BFh, 48h, 09h,0D8h
		db	 1Fh, 01h, 03h, 06h
		db	 5Dh, 2Eh
		db	 08h, 60h,0C0h,0F0h, 7Eh, 92h
		db	 0Fh, 7Dh,0DBh,0DBh, 05h, 3Ch
		db	0F8h, 90h, 78h, 82h,0B0h,0DDh
		db	0D0h, 30h,0C6h, 45h,0D5h, 54h
		db	 10h, 06h, 06h
		db	0EEh, 01h, 03h, 28h,0DEh, 0Ch
		db	 1Ch, 3Ch, 6Ch,0DDh,0E5h, 86h
		db	0FEh, 7Fh, 1Eh, 7Bh,0C2h,0C0h
		db	0C0h,0FCh, 1Eh,0A8h, 01h, 20h
		db	 1Eh, 10h,0FAh, 68h, 44h, 0Eh
		db	0FEh,0CFh, 9Fh, 4Fh, 01h, 60h
		db	0C6h, 7Ch,0BEh,0F5h, 01h, 20h
		db	 0Ch, 7Eh, 00h
		db	 40h, 7Dh
		db	0F6h,0DCh, 04h, 04h, 10h, 77h
		db	0FBh,0F0h,0CDh, 60h, 70h, 36h
		db	 40h,0FFh, 01h,0CCh,0FDh, 01h
		db	 1Bh,0C2h,0D3h,0B0h, 60h, 0Ch
		db	 18h, 00h,0E0h, 15h
data_23		dw	705Eh			; Data table (indexed access)
		db	0DEh, 01h,0DCh,0C0h, 7Eh, 31h
		db	 08h, 22h, 38h, 38h, 6Ch,0FFh
		db	0E2h, 67h, 66h,0C0h, 01h, 8Ah
		db	 0Dh, 20h,0FCh,0B2h, 33h, 32h
		db	 3Ch, 32h, 33h, 05h,0FCh,0B0h
		db	 43h, 08h, 60h, 33h, 61h,0F2h
		db	 08h, 6Fh,0C4h, 6Ch,0DFh,0F8h
		db	 6Ch, 98h, 3Ch, 36h, 33h, 01h
		db	0F3h, 76h, 3Ch, 20h, 29h, 9Dh
		db	 7Ch,0DAh, 7Eh, 04h, 33h, 40h
		db	 07h, 83h, 21h,0FFh,0B0h, 32h
		db	 7Eh, 70h, 00h,0EFh, 00h, 1Ch
		db	 36h, 63h, 70h, 09h,0C1h,0C0h
		db	0CCh,0CCh,0DCh,0BFh, 00h, 50h
		db	 98h, 0Eh,0E6h, 66h, 6Fh,0FEh
		db	 04h, 66h, 6Eh,0E0h, 70h, 60h
		db	 0Eh, 1Bh, 1Fh,0FCh,0D8h, 7Fh
		db	 4Eh,0C1h, 0Ah,0BEh,0FFh, 1Bh
		db	 20h, 36h, 13h
		db	0CCh, 4Ch, 7Ch, 72h, 03h, 00h
		db	0CEh,0C3h,0C3h,0C6h,0CCh,0D8h
		db	0F0h,0F8h,0CCh,0C6h,0C0h, 80h
		db	 83h,0C5h, 3Eh, 6Fh, 37h,0FCh
		db	 09h,0E0h, 62h,0C0h,0E3h, 63h
		db	 73h, 7Fh, 5Bh, 43h, 43h,0C3h
		db	 80h, 92h,0E0h, 07h, 30h, 63h
		db	0B0h, 15h, 11h, 67h, 63h, 61h
		db	0E0h, 31h, 1Eh, 0Ah,0E3h,0F3h
		db	 80h,0C3h, 44h, 5Fh, 20h, 02h
		db	0C9h,0ACh,0F3h,0B3h, 33h, 3Bh
		db	 36h, 42h, 3Ch,0F0h, 0Dh,0C0h
		db	 21h,0E3h,0C1h,0C1h,0D1h,0DBh
		db	0DFh,0CEh, 7Eh, 07h, 03h, 80h
		db	 02h, 1Fh,0E6h
		db	'Pf|xnwIg@'
		db	 11h,0EEh, 3Eh
		db	0B0h, 95h, 70h, 1Ch, 06h, 66h
		db	 3Eh, 6Eh,0FFh, 99h, 0Ch, 7Fh
		db	 51h, 01h, 5Eh, 03h, 25h, 17h
		db	 7Bh, 01h,0C7h,0EEh, 58h,0F0h
		db	0C0h, 01h, 13h, 1Eh
		db	 36h, 08h
		db	 1Bh,0D0h
		db	 18h, 99h, 01h,0BDh,0E7h,0B3h
		db	 54h, 42h, 0Eh, 29h, 42h,0FBh
		db	 50h,0A9h,0CEh, 7Eh, 06h
		db	 42h, 0Ch, 29h
		db	0F9h, 10h, 81h
		dw	2412h			; Data table (indexed access)
		db	 3Ch, 14h, 02h
		db	 11h, 03h, 0Fh, 3Bh,0E3h,0CAh
		db	0C9h,0BEh, 33h, 25h,0F8h,0D1h
		db	 7Ch, 60h,0FDh,0D0h, 01h, 20h
		db	 80h, 02h, 2Eh,0FDh, 06h, 03h
		db	 01h,0BCh, 27h,0D0h, 8Dh, 20h
		db	 10h,0E8h, 61h, 38h, 6Ch,0C6h
		db	 00h, 0Eh, 01h,0A9h,0C3h, 50h
		db	 67h, 0Ch, 08h, 19h, 78h,0D8h
		db	0D8h,0DCh, 21h, 0Ch,0B0h, 00h
		db	0E0h,0C0h,0C7h, 5Eh, 7Eh,0F3h
		db	 33h, 33h, 53h,0C1h, 8Fh, 02h
		db	 4Ch,0F0h, 00h, 00h, 07h, 6Ch
		db	 7Eh,0CFh,0CCh,0CCh, 7Fh, 03h
		db	 4Ch, 3Eh, 3Ch, 67h,0C3h,0F3h
		db	0DEh,0C0h, 6Eh, 3Ch, 0Ch, 06h
		db	0A0h, 08h, 1Ch, 5Ch, 30h, 34h
		db	0FCh,0B0h, 09h, 78h, 00h,0D0h
		db	 7Bh,0CEh,0C6h,0CEh, 76h,0B8h
		db	0B8h,0E2h, 1Ch, 3Dh, 72h, 61h
		db	 03h,0A8h,0F0h, 0Eh, 01h, 61h
		db	 36h, 82h, 39h, 04h, 02h, 00h
		db	 03h, 03h,0C6h,0CCh, 8Fh, 8Fh
		db	 00h, 69h, 0Ah, 30h, 18h, 01h
		db	 12h, 66h,0FFh,0EBh,0E9h, 84h
		db	 63h, 01h, 40h, 0Eh, 40h, 60h
		db	 7Ch,0E6h, 65h, 5Eh,0B3h, 60h
		db	0C0h, 83h, 1Eh, 67h, 01h,0CEh
		db	 2Ch, 5Ah, 40h, 03h,0B3h, 5Ch
		db	 54h, 03h,0A5h, 04h,0E0h,0C1h
		db	0CEh,0CDh,0CCh,0CDh,0CEh, 7Ch
		db	0D2h, 86h, 9Fh, 41h, 62h, 60h
		db	 60h,0F8h,0DFh, 76h, 63h, 00h
		db	 2Fh, 71h, 6Ch, 3Ch, 3Fh, 3Eh
		db	 9Ah, 0Ch,0F0h,0B0h, 01h,0D0h
loc_63:
		db	 6Ah,0BCh, 03h, 43h, 01h, 00h
		db	0A8h, 99h, 02h, 36h, 01h,0D0h
		db	 18h
loc_64:
		db	0C6h, 2Dh, 00h, 00h, 01h,0C3h
		db	 1Ch, 3Fh,0C1h, 3Ch, 66h,0C3h
		db	 10h, 80h, 08h,0B9h,0C1h, 63h
		db	 36h, 1Ch,0B1h
loc_65:
		add	word ptr ds:[0C1h],bp
		or	[bx+si-28h],bh
		xor	[si],ah
		jl	loc_64			; Jump if <
		dec	cx
		push	bx
		xor	dl,ch
		jo	loc_65			; Jump if overflow=1
		push	cs
		add	word ptr [bp+0],0
		nop				;*ASM fixup - displacement
		nop				;*ASM fixup - sign extn byte
		add	[bx+si],ax
		cmp	[di+1Ch],bx
		and	al,18h
		add	word ptr [bp+7600h],7DCh
		esc	6,al			; coprocessor escape
		mov	al,12h
		retn	8857h
		into				; Int 4 on overflow
		db	 66h,0CFh,0C6h, 64h, 81h, 82h
		db	 0Ch,0CCh, 5Fh,0C6h,0C6h, 4Ch
		db	 1Eh, 03h, 01h,0CEh, 76h, 1Dh
		db	0CAh
		db	 5Eh, 23h
		db	0FEh,0C0h,0A5h, 80h, 90h, 30h
		db	 78h,0CCh, 00h, 78h, 0Ch, 7Ch
		db	 90h, 8Bh,0C1h, 7Ah,0B0h, 20h
		db	0CCh, 04h, 10h, 8Ch, 87h,0F5h
		db	 03h, 10h
		db	0FFh, 04h, 30h,0C3h,0C2h, 12h
		db	 2Dh,0CEh, 2Eh, 0Ch, 43h, 50h
		db	 3Eh, 7Bh, 02h, 60h, 50h, 03h
		db	 70h,0B0h, 47h, 9Fh, 03h, 20h
		db	0B0h, 5Dh, 78h, 38h,0EFh, 3Ch
		db	0DEh, 67h,0AFh, 04h, 10h, 80h
		db	0CFh, 90h, 02h, 10h,0CFh, 02h
		db	0CAh,0B7h, 40h,0D2h, 8Fh, 4Fh
		db	 21h, 02h, 10h,0DFh,0FEh, 21h
		db	 1Fh, 4Ch, 50h, 01h,0B7h,0E0h
		db	 66h,0DBh, 1Bh, 7Fh,0D8h,0D8h
		db	0DFh,0B0h, 7Eh, 2Ah,0E9h, 0Bh
		db	 01h,0FEh, 04h,0DEh,0C3h,0B2h
		db	 00h,0A3h, 37h,0FBh, 90h, 48h
		db	 02h, 10h,0DDh,0B3h,0B0h, 00h
		db	 10h, 30h, 61h,0F6h, 02h, 50h
		db	0A0h, 02h, 10h, 0Bh, 9Fh, 6Fh
		db	0FCh,0F7h, 10h, 4Fh, 40h, 83h
		db	 7Fh, 8Fh, 70h, 05h, 5Fh, 70h
		db	0C0h,0A8h, 92h, 6Eh,0CDh,0BAh
		db	0F0h,0F8h,0E2h,0BEh, 66h,0F6h
		db	 6Ch, 9Fh, 48h,0EEh, 0Fh, 3Ch
		db	 20h, 70h, 88h, 7Bh,0FCh,0C0h
		db	0CCh,0DEh, 70h, 28h, 80h, 07h
		db	 0Eh, 56h, 48h, 1Bh, 18h, 3Fh
		db	 01h, 2Eh, 34h,0D8h, 70h, 01h
		db	 02h
		db	0CCh, 86h,0A0h, 10h, 02h, 40h
		db	 8Bh,0FFh, 00h, 80h,0F0h, 91h
		db	 48h, 3Eh, 04h, 7Eh,0D0h, 2Dh
		db	0F1h, 60h,0BCh, 5Fh,0E6h, 16h
		db	 1Ch, 0Fh, 2Bh,0E6h,0F6h,0DEh
		db	0CEh, 00h, 34h, 60h, 00h, 3Ch
		db	 6Ch, 6Ch, 3Eh, 00h, 7Eh, 00h
		db	 06h,0D1h, 7Ch, 7Ah, 38h, 00h
		db	 7Ch,0E2h, 90h, 02h,0CDh,0E0h
		db	 08h, 2Dh, 5Fh, 02h, 55h,0B6h
		db	 2Eh, 31h,0D2h, 03h, 1Ch,0E1h
		db	 95h, 51h, 72h, 48h,0CEh, 60h
		db	 62h, 66h, 6Ch, 85h,0CAh, 0Fh
		db	0DCh, 36h, 9Ah, 3Eh, 10h, 36h
		db	 6Eh,0DEh,0CEh, 25h, 36h, 7Eh
		db	 23h, 5Ah, 1Eh, 0Eh, 3Ch, 00h
		db	 62h, 11h, 7Ah,0C4h, 6Ch,0D8h
		db	 6Ch, 36h, 01h, 4Eh, 72h,0D2h
		db	 0Eh, 6Ch,0D8h, 0Bh, 11h, 44h
		db	0E9h, 74h, 04h, 02h,0AAh, 55h
		db	 04h, 02h,0DDh, 77h, 04h, 02h
		db	 5Dh, 7Fh, 18h
		db	 0Dh, 01h,0F8h, 05h, 0Eh,0DDh
		db	0EEh, 10h, 36h, 01h,0F6h, 08h
		db	 2Fh,0F4h,0A2h, 03h, 10h,0CEh
		db	0DBh, 06h, 30h,0F6h, 06h, 30h
		db	0EFh, 5Eh, 06h, 01h, 3Eh, 05h
		db	 20h, 0Fh,0DFh
		db	30h
		db	0BDh, 12h,0F7h, 6Fh, 10h, 90h
		db	 05h,0AAh,0EBh, 03h,0F8h, 05h
		db	0C0h
		db	 1Fh, 03h,0A5h, 79h, 30h, 01h
		db	0FFh, 06h, 2Ah, 6Fh,0A6h, 06h
		db	 30h, 05h
		db	74h
loc_72:
		push	word ptr [bx+0Dh]
		push	es
		inc	ax
		add	ax,1F2Eh
		add	ax,3A3Ah
		adc	[bx],dh
		add	ax,ax
		aaa				; Ascii adjust
		xor	[bx],bh
		add	bp,[bp+3Fh]
		popf				; Pop flags
		pop	si
		xor	[si],al
		and	bh,dh
		add	[si],al
		nop
		mov	dx,0E06h
		test	word ptr [di],3740h
		add	sp,[bx+si]
		db	0FFh,0FBh,0FFh, 30h, 40h,0BEh
		db	0BDh, 30h,0DEh, 04h, 20h,0BAh
		db	0DEh, 01h, 06h, 60h,0FFh, 06h
		db	0E0h,0A0h,0FBh, 05h, 88h, 3Fh
		db	 03h,0F0h, 1Fh, 70h, 6Ah, 40h
		db	 01h, 1Fh, 07h,0D0h, 75h, 20h
		db	 3Fh, 05h, 40h,0FFh, 04h, 90h
		db	0Dh
		db	 0Dh, 18h, 06h, 60h, 06h,0AFh
		db	0DEh,0B0h, 50h,0FFh, 05h, 01h
		db	0C2h,0A9h, 00h,0CAh, 01h
loc_75:
           lock	jmp	short loc_75
		add	ax,0F01h
		add	ax,601h
		cmp	ds:data_56e[bx+si],dl
		int	10h			; ??INT Non-standard interrupt
		jcxz	$+2			; Jump if cx=0
		mov	al,byte ptr ds:[0CC78h]
		esc	0,[bp+si+3615h]		; coprocessor escape
		out	0DCh,al			; port 0DCh, DMA-2 clr mask reg
		db	0C0h, 70h,0C5h, 62h,0FEh, 66h
		db	 62h, 71h, 96h,0EDh, 00h, 5Fh
		db	 6Ch, 01h, 27h, 8Bh,0D0h, 62h
		db	 80h, 96h, 9Fh, 30h, 62h,0C6h
		db	 00h, 09h,0E5h, 73h, 7Eh,0D8h
		db	 20h,0D8h, 70h,0B3h,0E9h, 50h
		db	 01h, 7Ch, 2Bh,0B3h, 71h, 71h
		db	 81h, 61h, 01h, 1Ch,0FEh, 38h
		db	0EAh,0BDh, 90h, 6Ch, 06h, 40h
		db	0ECh, 89h, 9Fh, 33h,0CBh, 61h
		db	 0Fh, 0Eh, 01h,0EEh,0D5h, 8Ah
		db	0D0h, 89h, 3Ch, 66h, 7Ch,0BAh
		db	 12h, 00h, 19h,0EDh, 70h, 82h
		db	 53h, 40h, 63h, 02h, 06h, 7Ch
		db	0CEh,0DEh,0F6h,0F6h, 3Eh,0D9h
		db	 70h, 71h, 30h, 32h, 5Ah,0E0h
		db	 30h, 1Ch, 01h,0D9h,0ADh, 60h
		db	 01h, 01h, 6Ah,0F5h, 2Dh,0FEh
		db	 02h, 33h,0AAh,0BEh, 5Fh, 7Eh
		db	 6Ah, 55h, 90h, 06h, 8Dh,0ADh
		db	0ACh, 7Eh, 00h, 6Fh,0F2h,0A3h
		db	 6Dh, 72h, 0Ch, 1Eh, 1Ah, 29h
		db	 5Ah, 09h, 12h, 58h, 78h, 30h
		db	 00h,0A5h,0D5h, 7Ah, 7Eh, 00h
		db	 03h,0B1h,0B0h, 2Fh, 25h,0D0h
		db	 5Bh, 97h, 78h,0CCh, 01h,0CAh
		db	 07h,0FDh, 1Bh,0ADh, 11h, 05h
		db	0E1h,0D4h, 0Ah,0D8h,0D8h, 78h
		db	 38h, 14h,0D8h,0B0h,0A2h, 01h
		db	 8Ch, 00h,0D8h, 6Ch,0B4h,0A1h
		db	 04h, 3Fh, 7Eh,0F5h, 36h, 01h
		db	 00h, 1Ch, 01h,0FCh,0B4h,0A1h
		db	 00h,0FCh, 00h, 0Dh, 6Dh,0FCh
		db	 00h,0FCh, 68h, 43h, 00h,0FCh
		db	 00h, 1Bh,0DAh,0FCh, 00h,0FCh
		db	0D0h, 86h, 00h,0FCh, 00h, 36h
		db	0B4h,0FCh, 00h,0FCh,0A1h, 0Dh
		db	 00h,0FCh, 6Dh, 68h, 00h,0FCh
		db	 00h,0FCh, 43h, 1Bh, 00h,0FCh
		db	0DAh,0D0h, 00h,0FCh, 00h, 86h
		db	 06h, 8Ah, 00h,0FFh, 00h

seg_a		ends



		end
