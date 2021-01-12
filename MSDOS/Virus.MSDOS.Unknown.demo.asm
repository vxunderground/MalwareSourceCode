  
PAGE  59,132
  
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
;€€								         €€
;€€			        DEMO				         €€
;€€								         €€
;€€      Created:   2-Mar-89					         €€
;€€      Version:						         €€
;€€      Passes:    5	       Analysis Options on: ABFOP	         €€
;€€      Copyright (C) 1986					         €€
;€€								         €€
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
  
movseg		 macro reg16, unused, Imm16     ; Fixup for Assembler
		 ifidn	<reg16>, <bx>
		 db	0BBh
		 endif
		 ifidn	<reg16>, <cx>
		 db	0B9h
		 endif
		 ifidn	<reg16>, <dx>
		 db	0BAh
		 endif
		 ifidn	<reg16>, <si>
		 db	0BEh
		 endif
		 ifidn	<reg16>, <di>
		 db	0BFh
		 endif
		 ifidn	<reg16>, <bp>
		 db	0BDh
		 endif
		 ifidn	<reg16>, <sp>
		 db	0BCh
		 endif
		 ifidn	<reg16>, <BX>
		 db	0BBH
		 endif
		 ifidn	<reg16>, <CX>
		 db	0B9H
		 endif
		 ifidn	<reg16>, <DX>
		 db	0BAH
		 endif
		 ifidn	<reg16>, <SI>
		 db	0BEH
		 endif
		 ifidn	<reg16>, <DI>
		 db	0BFH
		 endif
		 ifidn	<reg16>, <BP>
		 db	0BDH
		 endif
		 ifidn	<reg16>, <SP>
		 db	0BCH
		 endif
		 dw	seg Imm16
endm
DATA_1E		EQU	2CH			; (97DE:002C=0)
DATA_17E	EQU	0AC71H			; (97DE:AC71=0FFFFH)
  
SEG_A		SEGMENT	BYTE PUBLIC
		ASSUME	CS:SEG_A, DS:SEG_A
  
  
		ORG	100h
  
DEMO		PROC	FAR
  
START:
		JMP	LOC_31			; (24E1)
		OR	AX,2020H
		AND	[DI],CL
		OR	CL,[SI+4FH]
		PUSH	SP
		PUSH	BP
		PUSH	BX
		AND	[BX+SI+41H],CL
		DEC	SP
		AND	[SI+65H],AL
		DB	'monstration', 0DH, 0AH
COPYRIGHT	DB	'Copyright (C) 1986'
		DB	0DH, 0AH, 'Lotus Development Corp'
		DB	'oration', 0DH, 0AH, 'Singular So'
		DB	'lutions & GNP', 0DH, 0AH, 'All R'
		DB	'ights Reserved', 0DH, 0AH, 'Rele'
		DB	'ase 1.00', 0DH, 0AH
		DB	 1AH, 0DH
DATA_4		DB	0AH, 'Please wait ...', 0DH, 0AH, '$'
		DB	'MAGELLAN.DAT', 0
		DB	'MAGELLAN.DBD', 0
		DB	0DH, 0AH, 0AH, 'Cannot find MAGEL'
		DB	'LAN.DAT$'
		DB	0DH, 0AH, 0AH, 'Cannot find MAGEL'
		DB	'LAN.DBD$'
DATA_7		DB	80 DUP (0)
DATA_8		DB	0FCH
		DB	 20H, 00H
		DB	139 DUP (0)
		DB	'  -arg mono'
		DB	 00H, 00H, 49H, 02H
DATA_10		DW	0
		DB	 5CH, 00H
DATA_11		DW	0
		DB	 6CH, 00H
DATA_12		DW	0
  
DEMO		ENDP
  
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
;
;			External Entry Point
;
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
  
INT_23H_ENTRY	PROC	FAR
		MOV	AX,600H
		MOV	BH,7
		XOR	CX,CX			; Zero register
		MOV	DX,184FH
		INT	10H			; Video display   ah=functn 06h
						;  scroll up, al=lines
		MOV	AH,2
		MOV	BH,0
		XOR	DX,DX			; Zero register
		INT	10H			; Video display   ah=functn 02h
						;  set cursor location in dx
		MOV	AX,4C01H
		INT	21H			; DOS Services  ah=function 4Ch
						;  terminate with al=return code
		MOV	AX,2523H
		MOV	DX,2F0H
		INT	21H			; DOS Services  ah=function 25h
						;  set intrpt vector al to ds:dx
		CALL	SUB_3			; (03B1)
		MOV	SP,414H
		PUSHF				; Push flags
		MOV	AH,9
		MOV	DX,195H
		INT	21H			; DOS Services  ah=function 09h
						;  display char string at ds:dx
		MOV	AX,1B4H
		CALL	SUB_4			; (0495)
		MOV	DX,1DDH
		JC	LOC_5			; Jump if carry Set
		MOV	BX,AX
		MOV	AH,3EH			; '>'
		INT	21H			; DOS Services  ah=function 3Eh
						;  close file, bx=file handle
		PUSH	CS
		POP	ES
		MOV	SI,1F9H
		MOV	DI,24BH
		CLD				; Clear direction
LOC_2:
		INC	DATA_8			; (97DE:0249=0FCH)
		LODSB				; String [si] to al
		STOSB				; Store al to es:[di]
		OR	AL,AL			; Zero ?
		JNZ	LOC_2			; Jump if not zero
		SUB	DI,5
		MOV	SI,2D7H
		MOV	CX,1
		ADD	DATA_8,CL		; (97DE:0249=0FCH)
		REP	MOVSB			; Rep when cx >0 Mov [si] to es:[di]
		POPF				; Pop flags
		JC	LOC_3			; Jump if carry Set
		MOV	SI,2D8H
		MOV	CX,0AH
		ADD	DATA_8,CL		; (97DE:0249=0FCH)
		REP	MOVSB			; Rep when cx >0 Mov [si] to es:[di]
LOC_3:
		MOV	BYTE PTR [DI],0DH
		MOV	AX,1A7H
		CALL	SUB_4			; (0495)
		JC	LOC_4			; Jump if carry Set
		MOV	BX,AX
		MOV	AH,3EH			; '>'
		INT	21H			; DOS Services  ah=function 3Eh
						;  close file, bx=file handle
		MOV	BX,SP
		ADD	BX,0FH
		MOV	CL,4
		SHR	BX,CL			; Shift w/zeros fill
		PUSH	CS
		POP	ES
		MOV	AH,4AH			; 'J'
		INT	21H			; DOS Services  ah=function 4Ah
						;  change mem allocation, bx=siz
		MOV	AX,CS
		MOV	ES,AX
		MOV	DATA_10,AX		; (97DE:02E6=0)
		MOV	DATA_11,AX		; (97DE:02EA=0)
		MOV	DATA_12,AX		; (97DE:02EE=0)
		MOV	AX,4B00H
		MOV	DX,1F9H
		MOV	BX,2E2H
		INT	21H			; DOS Services  ah=function 4Bh
						;  run progm @ds:dx, parm @es:bx
		MOV	AX,CS
		MOV	SS,AX
		MOV	SP,39DH
		MOV	DS,AX
		JNC	LOC_6			; Jump if carry=0
LOC_4:
		MOV	DX,1C1H
LOC_5:
		MOV	AH,9
		INT	21H			; DOS Services  ah=function 09h
						;  display char string at ds:dx
LOC_6:
		MOV	AX,4C00H
		INT	21H			; DOS Services  ah=function 4Ch
						;  terminate with al=return code
DATA_13		DB	0
INT_23H_ENTRY	ENDP
  
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
SUB_3		PROC	NEAR
		MOV	AH,0FH
		INT	10H			; Video display   ah=functn 0Fh
						;  get state, al=mode, bh=page
		MOV	DATA_13,AL		; (97DE:03B0=0)
		CMP	AL,2
		JAE	LOC_7			; Jump if above or =
		ADD	AL,2
		MOV	AH,0
		INT	10H			; Video display   ah=functn 00h
						;  set display mode in al
LOC_7:
		XOR	DX,DX			; Zero register
		MOV	SI,5A0H
		CMP	DATA_13,7		; (97DE:03B0=0)
		JNE	LOC_8			; Jump if not equal
		MOV	SI,1540H
LOC_8:
		PUSH	DX
		PUSH	SI
		MOV	AH,2
		XOR	BH,BH			; Zero register
		INT	10H			; Video display   ah=functn 02h
						;  set cursor location in dx
		POP	SI
		CLD				; Clear direction
		LODSW				; String [si] to ax
		PUSH	SI
		MOV	BL,AH
		XOR	BH,BH			; Zero register
		MOV	AH,9
		MOV	CX,1
		INT	10H			; Video display   ah=functn 09h
						;  set char al & attrib bl @curs
		POP	SI
		POP	DX
		INC	DX
		CMP	DL,50H			; 'P'
		JB	LOC_8			; Jump if below
		INC	DH
		MOV	DL,0
		CMP	DH,19H
		JB	LOC_8			; Jump if below
		MOV	AH,2
		MOV	BH,0
		MOV	DX,1900H
		INT	10H			; Video display   ah=functn 02h
						;  set cursor location in dx
LOC_9:
		MOV	AX,0C08H
		INT	21H			; DOS Services  ah=function 0Ch
						;  clear keybd buffer & input al
		CMP	DATA_13,7		; (97DE:03B0=0)
		JE	LOC_11			; Jump if equal
		CMP	AL,4DH			; 'M'
		JE	LOC_11			; Jump if equal
		CMP	AL,6DH			; 'm'
		JE	LOC_11			; Jump if equal
		CMP	AL,43H			; 'C'
		JE	LOC_10			; Jump if equal
		CMP	AL,63H			; 'c'
		JE	LOC_10			; Jump if equal
		MOV	AX,0E07H
		XOR	BL,BL			; Zero register
		INT	10H			; Video display   ah=functn 0Eh
						;  write char al, teletype mode
		JMP	SHORT LOC_9		; (0402)
LOC_10:
		STC				; Set carry flag
		JMP	SHORT LOC_12		; (042B)
LOC_11:
		CLC				; Clear carry flag
LOC_12:
		PUSHF				; Push flags
		MOV	AX,600H
		MOV	BH,7
		XOR	CX,CX			; Zero register
		MOV	DX,184FH
		INT	10H			; Video display   ah=functn 06h
						;  scroll up, al=lines
		MOV	AH,2
		MOV	BH,0
		XOR	DX,DX			; Zero register
		INT	10H			; Video display   ah=functn 02h
						;  set cursor location in dx
		POPF				; Pop flags
		RETN
SUB_3		ENDP
  
		DB	81 DUP (0)
DATA_15		DW	0
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
SUB_4		PROC	NEAR
		MOV	DATA_15,AX		; (97DE:0493=0)
		MOV	DI,443H
		CALL	SUB_5			; (0529)
		JNC	LOC_RET_18		; Jump if carry=0
		MOV	ES,DS:DATA_1E		; (97DE:002C=0)
		XOR	SI,SI			; Zero register
		CMP	BYTE PTR ES:[SI],50H	; 'P'
		JE	LOC_21			; Jump if equal
LOC_13:
		CMP	WORD PTR ES:[SI],5000H
		JE	LOC_20			; Jump if equal
LOC_14:
		INC	SI
		CMP	WORD PTR ES:[SI-1],0
		JNE	LOC_13			; Jump if not equal
		MOV	AH,30H			; '0'
		INT	21H			; DOS Services  ah=function 30h
						;  get DOS version number ax
		CMP	AL,3
		JB	LOC_17			; Jump if below
		MOV	DI,443H
		XOR	CX,CX			; Zero register
LOC_15:
		MOV	AL,ES:[SI+3]
		INC	SI
		MOV	[DI],AL
		INC	DI
		INC	CX
		OR	AL,AL			; Zero ?
		JNZ	LOC_15			; Jump if not zero
  
LOCLOOP_16:
		CMP	BYTE PTR [DI-1],3AH	; ':'
		JE	LOC_19			; Jump if equal
		CMP	BYTE PTR [DI-1],5CH	; '\'
		JE	LOC_19			; Jump if equal
		DEC	DI
		LOOP	LOCLOOP_16		; Loop if cx > 0
  
LOC_17:
		STC				; Set carry flag
  
LOC_RET_18:
		RETN
LOC_19:
		CALL	SUB_5			; (0529)
		RETN
LOC_20:
		INC	SI
LOC_21:
		INC	SI
		CMP	WORD PTR ES:[SI],5441H
		JNE	LOC_14			; Jump if not equal
		INC	SI
		INC	SI
		CMP	WORD PTR ES:[SI],3D48H
		JNE	LOC_14			; Jump if not equal
		INC	SI
		INC	SI
LOC_22:
		MOV	DI,443H
LOC_23:
		MOV	AL,ES:[SI]
		CMP	AL,0
		JE	LOC_24			; Jump if equal
		INC	SI
		MOV	[DI],AL
		INC	DI
		CMP	AL,3BH			; ';'
		JNE	LOC_23			; Jump if not equal
		DEC	DI
		CMP	DI,443H
		JE	LOC_22			; Jump if equal
		CALL	SUB_5			; (0529)
		JC	LOC_22			; Jump if carry Set
		RETN
LOC_24:
		CMP	DI,443H
		JE	LOC_14			; Jump if equal
		CALL	SUB_5			; (0529)
		JC	LOC_14			; Jump if carry Set
		RETN
SUB_4		ENDP
  
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
SUB_5		PROC	NEAR
		MOV	WORD PTR [DI],0
		MOV	BX,445H
		MOV	AX,[BX-2]
		CMP	AH,3AH			; ':'
		JE	LOC_25			; Jump if equal
		MOV	AH,19H
		INT	21H			; DOS Services  ah=function 19h
						;  get default drive al  (0=a:)
		CBW				; Convrt byte to word
		ADD	AX,3A41H
		DEC	BX
		DEC	BX
LOC_25:
		CMP	AL,5AH			; 'Z'
		JBE	LOC_26			; Jump if below or =
		SUB	AL,20H			; ' '
LOC_26:
		MOV	WORD PTR DATA_7,AX	; (97DE:01F9=0)
		MOV	DI,1FBH
		CMP	BYTE PTR [BX],5CH	; '\'
		JE	LOC_28			; Jump if equal
		MOV	BYTE PTR [DI],5CH	; '\'
		INC	DI
		SUB	AL,40H			; '@'
		MOV	DL,AL
		MOV	AH,47H			; 'G'
		PUSH	SI
		MOV	SI,DI
		INT	21H			; DOS Services  ah=function 47h
						;  get present dir,drive dl,1=a:
		POP	SI
		DEC	DI
LOC_27:
		INC	DI
		CMP	BYTE PTR [DI],0
		JNE	LOC_27			; Jump if not equal
		CMP	BYTE PTR [DI-1],5CH	; '\'
		JE	LOC_28			; Jump if equal
		MOV	BYTE PTR [DI],5CH	; '\'
		INC	DI
LOC_28:
		MOV	AL,[BX]
		INC	BX
		MOV	[DI],AL
		INC	DI
		OR	AL,AL			; Zero ?
		JNZ	LOC_28			; Jump if not zero
		DEC	DI
		CMP	BYTE PTR [DI-1],5CH	; '\'
		JE	LOC_29			; Jump if equal
		MOV	BYTE PTR [DI],5CH	; '\'
		INC	DI
LOC_29:
		MOV	BX,DATA_15		; (97DE:0493=0)
LOC_30:
		MOV	AL,[BX]
		INC	BX
		MOV	[DI],AL
		INC	DI
		OR	AL,AL			; Zero ?
		JNZ	LOC_30			; Jump if not zero
		MOV	DX,1F9H
		MOV	AX,3D00H
		INT	21H			; DOS Services  ah=function 3Dh
						;  open file, al=mode,name@ds:dx
		RETN
SUB_5		ENDP
  
		AND	[BX],AL
		AND	[BX],AL
		INT	7
		INT	7
		INT	7
		INT	7
		INT	7
		INT	7
		INT	7
		INT	7
		INT	7
		INT	7
		INT	7
		INT	7
		INT	7
		INT	7
		INT	7
		INT	7
		INT	7
		INT	7
		INT	7
		INT	7
		INT	7
		INT	7
		INT	7
		INT	7
		INT	7
		INT	7
		INT	7
		INT	7
		INT	7
		AND	[BX],AL
		INC	DX
		POP	ES
		INC	BP
		POP	ES
		INC	SI
		POP	ES
		DEC	DI
		POP	ES
		PUSH	DX
		POP	ES
		INC	BP
		POP	ES
		AND	[BX],AL
		POP	CX
		POP	ES
		DEC	DI
		POP	ES
		PUSH	BP
		POP	ES
		AND	[BX],AL
		INC	DX
		POP	ES
		INC	BP
		POP	ES
		INC	DI
		POP	ES
		DEC	CX
		POP	ES
		DEC	SI
		POP	ES
		AND	[BX],AL
		INT	7
		INT	7
		INT	7
		INT	7
		INT	7
		INT	7
		INT	7
		INT	7
		INT	7
		INT	7
		INT	7
		INT	7
		INT	7
		INT	7
		INT	7
		INT	7
		INT	7
		INT	7
		INT	7
		INT	7
		INT	7
		INT	7
		INT	7
		INT	7
		INT	7
		INT	7
		INT	7
		INT	7
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		AND	[BX],AL
		DEC	CX
;*		POP	CS			; Dangerous 8088 only
		DB	0FH
		DB	 66H, 0FH, 20H, 0FH, 79H, 0FH
		DB	 6FH, 0FH, 75H, 0FH, 72H, 0FH
		DB	 20H, 0FH, 6DH, 0FH, 6FH, 0FH
		DB	 6EH, 0FH, 69H, 0FH, 74H, 0FH
		DB	 6FH, 0FH, 72H, 0FH, 20H, 0FH
		DB	 69H, 0FH, 73H, 0FH, 3AH, 0FH
		DB	 20H, 0FH, 20H, 0FH, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 49H, 0FH
		DB	 66H, 0FH, 20H, 0FH, 79H, 0FH
		DB	 6FH, 0FH, 75H, 0FH, 72H, 0FH
		DB	 20H, 0FH, 6DH, 0FH, 6FH, 0FH
		DB	 6EH, 0FH, 69H, 0FH, 74H, 0FH
		DB	 6FH, 0FH, 72H, 0FH, 20H, 0FH
		DB	 69H, 0FH, 73H, 0FH, 3AH, 0FH
		DB	 20H, 0FH, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 0FH, 20H, 0FH
		DB	 20H, 0FH, 20H, 0FH, 20H, 0FH
		DB	 20H, 0FH, 20H, 0FH, 20H, 0FH
		DB	 20H, 0FH, 20H, 0FH, 20H, 0FH
		DB	 20H, 0FH, 20H, 0FH, 20H, 0FH
		DB	 20H, 0FH, 20H, 0FH, 20H, 0FH
		DB	 20H, 0FH, 20H, 0FH, 20H, 0FH
		DB	 20H, 0FH, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 0FH, 20H, 0FH
		DB	 20H, 0FH, 20H, 0FH, 20H, 0FH
		DB	 20H, 0FH, 20H, 0FH, 20H, 0FH
		DB	 20H, 0FH, 20H, 0FH, 20H, 0FH
		DB	 20H, 0FH, 20H, 0FH, 20H, 0FH
		DB	 20H, 0FH, 20H, 0FH, 20H, 0FH
		DB	 20H, 0FH, 20H, 0FH, 20H, 0FH
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 4DH, 0FH
		DB	 4FH, 0FH, 4EH, 0FH, 4FH, 0FH
		DB	 43H, 0FH, 48H, 0FH, 52H, 0FH
		DB	 4FH, 0FH, 4DH, 0FH, 45H, 0FH
		DB	 20H, 0FH, 6FH, 0FH, 72H, 0FH
		DB	 20H, 0FH, 50H, 0FH, 4FH, 0FH
		DB	 52H, 0FH, 54H, 0FH, 41H, 0FH
		DB	 42H, 0FH, 4CH, 0FH, 45H, 0FH
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 0FH, 20H, 0FH, 20H, 0FH
		DB	 20H, 0FH, 20H, 0FH, 20H, 0FH
		DB	 20H, 0FH, 43H, 0FH, 4FH, 0FH
		DB	 4CH, 0FH, 4FH, 0FH, 52H, 0FH
		DB	 20H, 0FH, 20H, 0FH, 20H, 0FH
		DB	 20H, 0FH, 20H, 0FH, 20H, 0FH
		DB	 20H, 0FH, 20H, 0FH, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	0C9H, 07H,0CDH, 07H,0CDH, 07H
		DB	0CDH, 07H,0CDH, 07H,0CDH, 07H
		DB	0CDH, 07H,0CDH, 07H,0CDH, 07H
		DB	0CDH, 07H,0CDH, 07H,0CDH, 07H
		DB	0CDH, 07H,0CDH, 07H,0CDH, 07H
		DB	0CDH, 07H,0CDH, 07H,0CDH, 07H
		DB	0CDH, 07H,0CDH, 07H,0CDH, 07H
		DB	0CDH, 07H,0CDH, 07H,0CDH, 07H
		DB	0CDH, 07H,0CDH, 07H,0CDH, 07H
		DB	0BBH, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	0C9H, 30H,0CDH, 30H,0CDH, 30H
		DB	0CDH, 30H,0CDH, 30H,0CDH, 30H
		DB	0CDH, 30H,0CDH, 30H,0CDH, 30H
		DB	0CDH, 30H,0CDH, 30H,0CDH, 30H
		DB	0CDH, 30H,0CDH, 30H,0CDH, 30H
		DB	0CDH, 30H,0CDH, 30H,0CDH, 30H
		DB	0CDH, 30H,0CDH, 30H,0CDH, 30H
		DB	0CDH, 30H,0CDH, 30H,0CDH, 30H
		DB	0CDH, 30H,0CDH, 30H,0CDH, 30H
		DB	0BBH, 30H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H,0BAH, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H,0BAH, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H,0BAH, 30H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H,0BAH, 30H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H,0BAH, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 54H, 0FH
		DB	 6FH, 0FH, 20H, 0FH, 69H, 0FH
		DB	 6EH, 0FH, 73H, 0FH, 75H, 0FH
		DB	 72H, 0FH, 65H, 0FH, 20H, 0FH
		DB	 74H, 0FH, 68H, 0FH, 65H, 0FH
		DB	 20H, 0FH, 62H, 0FH, 65H, 0FH
		DB	 73H, 0FH, 74H, 0FH, 20H, 0FH
		DB	 20H, 0FH, 20H, 0FH, 20H, 0FH
		DB	 20H, 07H,0BAH, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H,0BAH, 30H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 54H, 0FH
		DB	 6FH, 0FH, 20H, 0FH, 69H, 0FH
		DB	 6EH, 0FH, 73H, 0FH, 75H, 0FH
		DB	 72H, 0FH, 65H, 0FH, 20H, 0FH
		DB	 74H, 0FH, 68H, 0FH, 65H, 0FH
		DB	 20H, 0FH, 62H, 0FH, 65H, 0FH
		DB	 73H, 0FH, 74H, 0FH, 20H, 0FH
		DB	 20H, 0FH, 20H, 0FH, 20H, 07H
		DB	 20H, 07H,0BAH, 30H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 20H, 07H, 20H, 07H
		DB	0BAH, 07H, 20H, 07H, 20H, 07H
		DB	 20H, 07H, 64H, 0FH, 65H, 0FH
		DB	 6DH, 0FH, 6FH, 0FH
DATA_16		DB	6EH			; Data table (indexed access)
		DB	 0FH, 73H, 0FH, 74H, 0FH, 72H
		DB	 0FH, 61H, 0FH, 74H, 0FH, 69H
		DB	 0FH, 6FH, 0FH, 6EH, 0FH, 20H
		DB	 0FH, 6FH, 0FH, 66H, 0FH, 20H
		DB	 0FH, 20H, 0FH, 20H, 0FH, 20H
		DB	 0FH, 20H, 0FH, 20H, 0FH, 20H
		DB	 07H,0BAH, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H,0BAH, 30H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 64H, 0FH, 65H
		DB	 0FH, 6DH, 0FH, 6FH, 0FH, 6EH
		DB	 0FH, 73H, 0FH, 74H, 0FH, 72H
		DB	 0FH, 61H, 0FH, 74H, 0FH, 69H
		DB	 0FH, 6FH, 0FH, 6EH, 0FH, 20H
		DB	 0FH, 6FH, 0FH, 66H, 0FH, 20H
		DB	 0FH, 20H, 0FH, 20H, 0FH, 20H
		DB	 0FH, 20H, 0FH, 20H, 07H, 20H
		DB	 07H,0BAH, 30H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H,0BAH
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 4CH, 0FH, 6FH, 0FH, 74H
		DB	 0FH, 75H, 0FH, 73H, 0FH, 20H
		DB	 0FH, 4DH, 0FH, 61H, 0FH, 67H
		DB	 0FH, 65H, 0FH, 6CH, 0FH, 6CH
		DB	 0FH, 61H, 0FH, 6EH, 0FH, 20H
		DB	 0FH, 6FH, 0FH, 6EH, 0FH, 20H
		DB	 0FH, 61H, 0FH, 20H, 0FH, 20H
		DB	 0FH, 20H, 0FH, 20H, 07H,0BAH
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H,0BAH
		DB	 30H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 4CH, 0FH, 6FH, 0FH, 74H
		DB	 0FH, 75H, 0FH, 73H, 0FH, 20H
		DB	 0FH, 4DH, 0FH, 61H, 0FH, 67H
		DB	 0FH, 65H, 0FH, 6CH, 0FH, 6CH
		DB	 0FH, 61H, 0FH, 6EH, 0FH, 20H
		DB	 0FH, 6FH, 0FH, 6EH, 0FH, 20H
		DB	 0FH, 61H, 0FH, 20H, 0FH, 20H
		DB	 0FH, 20H, 07H, 20H, 07H,0BAH
		DB	 30H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H,0BAH, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 6DH
		DB	 0FH, 6FH, 0FH, 6EH, 0FH, 6FH
		DB	 0FH, 63H, 0FH, 68H, 0FH, 72H
		DB	 0FH, 6FH, 0FH, 6DH, 0FH, 65H
		DB	 0FH, 20H, 0FH, 6DH, 0FH, 6FH
		DB	 0FH, 6EH, 0FH, 69H, 0FH, 74H
		DB	 0FH, 6FH, 0FH, 72H, 0FH, 2CH
		DB	 0FH, 20H, 0FH, 20H, 0FH, 20H
		DB	 0FH, 20H, 07H,0BAH, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H,0BAH, 30H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 63H
		DB	 0FH, 6FH, 0FH, 6CH, 0FH, 6FH
		DB	 0FH, 72H, 0FH, 20H, 0FH, 6DH
		DB	 0FH, 6FH, 0FH, 6EH, 0FH, 69H
		DB	 0FH, 74H, 0FH, 6FH, 0FH, 72H
		DB	 0FH, 2CH, 0FH, 20H, 0FH, 20H
		DB	 0FH, 20H, 0FH, 20H, 0FH, 20H
		DB	 0FH, 20H, 0FH, 20H, 0FH, 20H
		DB	 07H, 20H, 07H,0BAH, 30H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H,0BAH, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 74H, 0FH, 75H
		DB	 0FH, 72H, 0FH, 6EH, 0FH, 20H
		DB	 0FH, 74H, 0FH, 68H, 0FH, 65H
		DB	 0FH, 20H, 0FH, 62H, 0FH, 72H
		DB	 0FH, 69H, 0FH, 67H, 0FH, 68H
		DB	 0FH, 74H, 0FH, 6EH, 0FH, 65H
		DB	 0FH, 73H, 0FH, 73H, 0FH, 20H
		DB	 0FH, 20H, 0FH, 20H, 0FH, 20H
		DB	 07H,0BAH, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H,0BAH, 30H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 74H, 0FH, 75H
		DB	 0FH, 72H, 0FH, 6EH, 0FH, 20H
		DB	 0FH, 74H, 0FH, 68H, 0FH, 65H
		DB	 0FH, 20H, 0FH, 62H, 0FH, 72H
		DB	 0FH, 69H, 0FH, 67H, 0FH, 68H
		DB	 0FH, 74H, 0FH, 6EH, 0FH, 65H
		DB	 0FH, 73H, 0FH, 73H, 0FH, 20H
		DB	 0FH, 20H, 0FH, 20H, 07H, 20H
		DB	 07H,0BAH, 30H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H,0BAH
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 61H, 0FH, 6EH, 0FH, 64H
		DB	 0FH, 20H, 0FH, 63H, 0FH, 6FH
		DB	 0FH, 6EH, 0FH, 74H, 0FH, 72H
		DB	 0FH, 61H, 0FH, 73H, 0FH, 74H
		DB	 0FH, 20H, 0FH, 6BH, 0FH, 6EH
		DB	 0FH, 6FH, 0FH, 62H, 0FH, 73H
		DB	 0FH, 20H, 0FH, 6FH, 0FH, 6EH
		DB	 0FH, 20H, 0FH, 20H, 07H,0BAH
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H,0BAH
		DB	 30H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 61H, 0FH, 6EH, 0FH, 64H
		DB	 0FH, 20H, 0FH, 63H, 0FH, 6FH
		DB	 0FH, 6EH, 0FH, 74H, 0FH, 72H
		DB	 0FH, 61H, 0FH, 73H, 0FH, 74H
		DB	 0FH, 20H, 0FH, 6BH, 0FH, 6EH
		DB	 0FH, 6FH, 0FH, 62H, 0FH, 73H
		DB	 0FH, 20H, 0FH, 6FH, 0FH, 6EH
		DB	 0FH, 20H, 07H, 20H, 07H,0BAH
		DB	 30H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H,0BAH, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 79H
		DB	 0FH, 6FH, 0FH, 75H, 0FH, 72H
		DB	 0FH, 20H, 0FH, 6DH, 0FH, 6FH
		DB	 0FH, 6EH, 0FH, 69H, 0FH, 74H
		DB	 0FH, 6FH, 0FH, 72H, 0FH, 20H
		DB	 0FH, 75H, 0FH, 6EH, 0FH, 74H
		DB	 0FH, 69H, 0FH, 6CH, 0FH, 20H
		DB	 0FH, 20H, 0FH, 20H, 0FH, 20H
		DB	 0FH, 20H, 07H,0BAH, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H,0BAH, 30H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 79H
		DB	 0FH, 6FH, 0FH, 75H, 0FH, 72H
		DB	 0FH, 20H, 0FH, 6DH, 0FH, 6FH
		DB	 0FH, 6EH, 0FH, 69H, 0FH, 74H
		DB	 0FH, 6FH, 0FH, 72H, 0FH, 20H
		DB	 0FH, 75H, 0FH, 6EH, 0FH, 74H
		DB	 0FH, 69H, 0FH, 6CH, 0FH, 20H
		DB	 0FH, 20H, 0FH, 20H, 0FH, 20H
		DB	 07H, 20H, 07H,0BAH, 30H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H,0BAH, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 61H, 0FH, 20H
		DB	 0FH, 62H, 0FH, 6FH, 0FH, 78H
		DB	 0FH, 20H, 0FH, 61H, 0FH, 70H
		DB	 0FH, 70H, 0FH, 65H, 0FH, 61H
		DB	 0FH, 72H, 0FH, 73H, 0FH, 20H
		DB	 0FH, 61H, 0FH, 72H, 0FH, 6FH
		DB	 0FH, 75H, 0FH, 6EH, 0FH, 64H
		DB	 0FH, 20H, 0FH, 20H, 0FH, 20H
		DB	 07H,0BAH, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H,0BAH, 30H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 61H, 0FH, 20H
		DB	 0FH, 62H, 0FH, 6FH, 0FH, 78H
		DB	 0FH, 20H, 0FH, 69H, 0FH, 73H
		DB	 0FH, 20H, 0FH, 63H, 0FH, 6CH
		DB	 0FH, 65H, 0FH, 61H, 0FH, 72H
		DB	 0FH, 6CH, 0FH, 79H, 0FH, 20H
		DB	 0FH, 20H, 0FH, 20H, 0FH, 20H
		DB	 0FH, 20H, 0FH, 20H, 07H, 20H
		DB	 07H,0BAH, 30H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H,0BAH
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 74H, 0FH, 68H, 0FH, 69H
		DB	 0FH, 73H, 0FH, 20H, 0FH, 74H
		DB	 0FH, 65H, 0FH, 78H, 0FH, 74H
		DB	 0FH, 2EH, 0FH, 20H, 0FH, 20H
		DB	 0FH, 54H, 0FH, 68H, 0FH, 65H
		DB	 0FH, 20H, 0FH, 74H, 0FH, 65H
		DB	 0FH, 78H, 0FH, 74H, 0FH, 20H
		DB	 0FH, 20H, 0FH, 20H, 07H,0BAH
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H,0BAH
		DB	 30H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 76H, 0FH, 69H, 0FH, 73H
		DB	 0FH, 69H, 0FH, 62H, 0FH, 6CH
		DB	 0FH, 65H, 0FH, 20H, 0FH, 61H
		DB	 0FH, 72H, 0FH, 6FH, 0FH, 75H
		DB	 0FH, 6EH, 0FH, 64H, 0FH, 20H
		DB	 0FH, 74H, 0FH, 68H, 0FH, 69H
		DB	 0FH, 73H, 0FH, 20H, 0FH, 20H
		DB	 0FH, 20H, 07H, 20H, 07H,0BAH
		DB	 30H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H,0BAH, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 73H
		DB	 0FH, 68H, 0FH, 6FH, 0FH, 75H
		DB	 0FH, 6CH, 0FH, 64H, 0FH, 20H
		DB	 0FH, 62H, 0FH, 65H, 0FH, 20H
		DB	 0FH, 62H, 0FH, 72H, 0FH, 69H
		DB	 0FH, 67H, 0FH, 68H, 0FH, 74H
		DB	 0FH, 65H, 0FH, 72H, 0FH, 20H
		DB	 0FH, 20H, 0FH, 20H, 0FH, 20H
		DB	 0FH, 20H, 07H,0BAH, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H,0BAH, 30H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 74H
		DB	 0FH, 65H, 0FH, 78H, 0FH, 74H
		DB	 0FH, 2EH, 0FH, 20H, 0FH, 20H
		DB	 0FH, 20H, 0FH, 20H, 0FH, 20H
		DB	 0FH, 20H, 0FH, 20H, 0FH, 20H
		DB	 0FH, 20H, 0FH, 20H, 0FH, 20H
		DB	 0FH, 20H, 0FH, 20H, 0FH, 20H
		DB	 0FH, 20H, 0FH, 20H, 0FH, 20H
		DB	 07H, 20H, 07H,0BAH, 30H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H,0BAH, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 74H, 0FH, 68H
		DB	 0FH, 61H, 0FH, 6EH, 0FH, 20H
		DB	 0FH, 74H, 0FH, 68H, 0FH, 65H
		DB	 0FH, 20H, 0FH, 62H, 0FH, 6FH
		DB	 0FH, 78H, 0FH, 2EH, 0FH, 20H
		DB	 0FH, 20H, 0FH, 20H, 0FH, 20H
		DB	 0FH, 20H, 0FH, 20H, 0FH, 20H
		DB	 0FH, 20H, 0FH, 20H, 0FH, 20H
		DB	 07H,0BAH, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H,0BAH, 30H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 0FH, 20H
		DB	 0FH, 20H, 0FH, 20H, 0FH, 20H
		DB	 0FH, 20H, 0FH, 20H, 0FH, 20H
		DB	 0FH, 20H, 0FH, 20H, 0FH, 20H
		DB	 0FH, 20H, 0FH, 20H, 0FH, 20H
		DB	 0FH, 20H, 0FH, 20H, 0FH, 20H
		DB	 0FH, 20H, 0FH, 20H, 0FH, 20H
		DB	 0FH, 20H, 0FH, 20H, 07H, 20H
		DB	 07H,0BAH, 30H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H,0BAH
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H,0BAH
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H,0BAH
		DB	 30H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H,0BAH
		DB	 30H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H,0BAH, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 54H
		DB	 0FH, 68H, 0FH, 65H, 0FH, 6EH
		DB	 0FH, 20H, 0FH, 70H, 0FH, 72H
		DB	 0FH, 65H, 0FH, 73H, 0FH, 73H
		DB	 0FH, 20H, 0FH, 20H, 0FH, 4DH
		DB	 07H, 20H, 0FH, 20H, 0FH, 74H
		DB	 0FH, 6FH, 0FH, 20H, 0FH, 20H
		DB	 0FH, 20H, 0FH, 20H, 0FH, 20H
		DB	 0FH, 20H, 07H,0BAH, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H,0BAH, 30H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 54H
		DB	 0FH, 68H, 0FH, 65H, 0FH, 6EH
		DB	 0FH, 20H, 0FH, 70H, 0FH, 72H
		DB	 0FH, 65H, 0FH, 73H, 0FH, 73H
		DB	 0FH, 20H, 0FH, 20H, 0FH, 43H
		DB	 07H, 20H, 0FH, 20H, 0FH, 74H
		DB	 0FH, 6FH, 0FH, 20H, 0FH, 20H
		DB	 0FH, 20H, 0FH, 20H, 0FH, 20H
		DB	 07H, 20H, 07H,0BAH, 30H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H,0BAH, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 63H, 0FH, 6FH
		DB	 0FH, 6EH, 0FH, 74H, 0FH, 69H
		DB	 0FH, 6EH, 0FH, 75H, 0FH, 65H
		DB	 0FH, 2EH, 0FH, 20H, 0FH, 20H
		DB	 0FH, 20H, 0FH, 20H, 0FH, 20H
		DB	 0FH, 20H, 0FH, 20H, 0FH, 20H
		DB	 0FH, 20H, 0FH, 20H, 0FH, 20H
		DB	 0FH, 20H, 0FH, 20H, 0FH, 20H
		DB	 07H,0BAH, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H,0BAH, 30H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 63H, 0FH, 6FH
		DB	 0FH, 6EH, 0FH, 74H, 0FH, 69H
		DB	 0FH, 6EH, 0FH, 75H, 0FH, 65H
		DB	 0FH, 2EH, 0FH, 20H, 0FH, 20H
		DB	 0FH, 20H, 0FH, 20H, 0FH, 20H
		DB	 0FH, 20H, 0FH, 20H, 0FH, 20H
		DB	 0FH, 20H, 0FH, 20H, 0FH, 20H
		DB	 0FH, 20H, 0FH, 20H, 07H, 20H
		DB	 07H,0BAH, 30H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H,0BAH
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H,0BAH
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H,0BAH
		DB	 30H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H,0BAH
		DB	 30H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H,0C8H, 07H,0CDH
		DB	 07H,0CDH, 07H,0CDH, 07H,0CDH
		DB	 07H,0CDH, 07H,0CDH, 07H,0CDH
		DB	 07H,0CDH, 07H,0CDH, 07H,0CDH
		DB	 07H,0CDH, 07H,0CDH, 07H,0CDH
		DB	 07H,0CDH, 07H,0CDH, 07H,0CDH
		DB	 07H,0CDH, 07H,0CDH, 07H,0CDH
		DB	 07H,0CDH, 07H,0CDH, 07H,0CDH
		DB	 07H,0CDH, 07H,0CDH, 07H,0CDH
		DB	 07H,0CDH, 07H,0BCH, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H,0C8H, 30H,0CDH
		DB	 30H,0CDH, 30H,0CDH, 30H,0CDH
		DB	 30H,0CDH, 30H,0CDH, 30H,0CDH
		DB	 30H,0CDH, 30H,0CDH, 30H,0CDH
		DB	 30H,0CDH, 30H,0CDH, 30H,0CDH
		DB	 30H,0CDH, 30H,0CDH, 30H,0CDH
		DB	 30H,0CDH, 30H,0CDH, 30H,0CDH
		DB	 30H,0CDH, 30H,0CDH, 30H,0CDH
		DB	 30H,0CDH, 30H,0CDH, 30H,0CDH
		DB	 30H,0CDH, 30H,0BCH, 30H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H,0CDH
		DB	 07H,0CDH, 07H,0CDH, 07H,0CDH
		DB	 07H,0CDH, 07H,0CDH, 07H,0CDH
		DB	 07H,0CDH, 07H,0CDH, 07H,0CDH
		DB	 07H,0CDH, 07H,0CDH, 07H,0CDH
		DB	 07H,0CDH, 07H,0CDH, 07H,0CDH
		DB	 07H,0CDH, 07H,0CDH, 07H,0CDH
		DB	 07H,0CDH, 07H,0CDH, 07H,0CDH
		DB	 07H,0CDH, 07H,0CDH, 07H,0CDH
		DB	 07H,0CDH, 07H,0CDH, 07H,0CDH
		DB	 07H, 20H, 07H, 42H, 07H, 45H
		DB	 07H, 46H, 07H, 4FH, 07H, 52H
		DB	 07H, 45H, 07H, 20H, 07H, 59H
		DB	 07H, 4FH, 07H, 55H, 07H, 20H
		DB	 07H, 42H, 07H, 45H, 07H, 47H
		DB	 07H, 49H, 07H, 4EH, 07H, 20H
		DB	 07H,0CDH, 07H,0CDH, 07H,0CDH
		DB	 07H,0CDH, 07H,0CDH, 07H,0CDH
		DB	 07H,0CDH, 07H,0CDH, 07H,0CDH
		DB	 07H,0CDH, 07H,0CDH, 07H,0CDH
		DB	 07H,0CDH, 07H,0CDH, 07H,0CDH
		DB	 07H,0CDH, 07H,0CDH, 07H,0CDH
		DB	 07H,0CDH, 07H,0CDH, 07H,0CDH
		DB	 07H,0CDH, 07H,0CDH, 07H,0CDH
		DB	 07H,0CDH, 07H,0CDH, 07H,0CDH
		DB	 07H,0CDH, 07H,0CDH, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H,0C9H, 07H,0CDH
		DB	 07H,0CDH, 07H,0CDH, 07H,0CDH
		DB	 07H,0CDH, 07H,0CDH, 07H,0CDH
		DB	 07H,0CDH, 07H,0CDH, 07H,0CDH
		DB	 07H,0CDH, 07H,0CDH, 07H,0CDH
		DB	 07H,0CDH, 07H,0CDH, 07H,0CDH
		DB	 07H,0CDH, 07H,0CDH, 07H,0CDH
		DB	 07H,0CDH, 07H,0CDH, 07H,0CDH
		DB	 07H,0CDH, 07H,0CDH, 07H,0CDH
		DB	 07H,0CDH, 07H,0CDH, 07H,0CDH
		DB	 07H,0CDH, 07H,0CDH, 07H,0CDH
		DB	 07H,0CDH, 07H,0CDH, 07H,0CDH
		DB	 07H,0CDH, 07H,0CDH, 07H,0CDH
		DB	 07H,0CDH, 07H,0CDH, 07H,0CDH
		DB	 07H,0CDH, 07H,0CDH, 07H,0BBH
		DB	 07H, 20H, 0FH, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H,0BAH, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H,0BAH, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H,0BAH
		DB	 07H, 20H, 07H, 20H, 07H, 54H
		DB	 0FH, 6FH, 0FH, 20H, 0FH, 69H
		DB	 0FH, 6EH, 0FH, 73H, 0FH, 75H
		DB	 0FH, 72H, 0FH, 65H, 0FH, 20H
		DB	 0FH, 74H, 0FH, 68H, 0FH, 65H
		DB	 0FH, 20H, 0FH, 62H, 0FH, 65H
		DB	 0FH, 73H, 0FH, 74H, 0FH, 20H
		DB	 0FH, 64H, 0FH, 65H, 0FH, 6DH
		DB	 0FH, 6FH, 0FH, 6EH, 0FH, 73H
		DB	 0FH, 74H, 0FH, 72H, 0FH, 61H
		DB	 0FH, 74H, 0FH, 69H, 0FH, 6FH
		DB	 0FH, 6EH, 0FH, 20H, 0FH, 6FH
		DB	 0FH, 66H, 0FH, 20H, 0FH, 20H
		DB	 0FH, 20H, 07H, 20H, 07H, 20H
		DB	 07H,0BAH, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H,0BAH, 07H, 20H
		DB	 07H, 20H, 07H, 4CH, 0FH, 6FH
		DB	 0FH, 74H, 0FH, 75H, 0FH, 73H
		DB	 0FH, 20H, 0FH, 4DH, 0FH, 61H
		DB	 0FH, 67H, 0FH, 65H, 0FH, 6CH
		DB	 0FH, 6CH, 0FH, 61H, 0FH, 6EH
		DB	 0FH, 2CH, 0FH, 20H, 0FH, 79H
		DB	 0FH, 6FH, 0FH, 75H, 0FH, 20H
		DB	 0FH, 6EH, 0FH, 65H, 0FH, 65H
		DB	 0FH, 64H, 0FH, 20H, 0FH, 74H
		DB	 0FH, 6FH, 0FH, 20H, 0FH, 61H
		DB	 0FH, 64H, 0FH, 6AH, 0FH, 75H
		DB	 0FH, 73H, 0FH, 74H, 0FH, 20H
		DB	 0FH, 79H, 0FH, 6FH, 0FH, 75H
		DB	 0FH, 72H, 0FH, 20H, 07H,0BAH
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H,0BAH, 07H, 20H, 07H, 20H
		DB	 07H, 6DH, 0FH, 6FH, 0FH, 6EH
		DB	 0FH, 69H, 0FH, 74H, 0FH, 6FH
		DB	 0FH, 72H, 0FH, 2EH, 0FH, 20H
		DB	 0FH, 20H, 0FH, 54H, 0FH, 75H
		DB	 0FH, 72H, 0FH, 6EH, 0FH, 20H
		DB	 0FH, 74H, 0FH, 68H, 0FH, 65H
		DB	 0FH, 20H, 0FH, 62H, 0FH, 72H
		DB	 0FH, 69H, 0FH, 67H, 0FH, 68H
		DB	 0FH, 74H, 0FH, 6EH, 0FH, 65H
		DB	 0FH, 73H, 0FH, 73H, 0FH, 20H
		DB	 0FH, 61H, 0FH, 6EH, 0FH, 64H
		DB	 0FH, 20H, 0FH, 20H, 0FH, 20H
		DB	 0FH, 20H, 0FH, 20H, 07H, 20H
		DB	 07H, 20H, 07H,0BAH, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H,0BAH
		DB	 07H, 20H, 07H, 20H, 07H, 63H
		DB	 0FH, 6FH, 0FH, 6EH, 0FH, 74H
		DB	 0FH, 72H, 0FH, 61H, 0FH, 73H
		DB	 0FH, 74H, 0FH, 20H, 0FH, 6BH
		DB	 0FH, 6EH, 0FH, 6FH, 0FH, 62H
		DB	 0FH, 73H, 0FH, 20H, 0FH, 6FH
		DB	 0FH, 6EH, 0FH, 20H, 0FH, 79H
		DB	 0FH, 6FH, 0FH, 75H, 0FH, 72H
		DB	 0FH, 20H, 0FH, 6DH, 0FH, 6FH
		DB	 0FH, 6EH, 0FH, 69H, 0FH, 74H
		DB	 0FH, 6FH, 0FH, 72H, 0FH, 20H
		DB	 0FH, 75H, 0FH, 6EH, 0FH, 74H
		DB	 0FH, 69H, 0FH, 6CH, 0FH, 20H
		DB	 0FH, 20H, 07H, 20H, 07H, 20H
		DB	 07H,0BAH, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H,0BAH, 07H, 20H
		DB	 07H, 20H, 07H, 61H, 0FH, 20H
		DB	 0FH, 62H, 0FH, 6FH, 0FH, 78H
		DB	 0FH, 20H, 0FH, 61H, 0FH, 70H
		DB	 0FH, 70H, 0FH, 65H, 0FH, 61H
		DB	 0FH, 72H, 0FH, 73H, 0FH, 20H
		DB	 0FH, 61H, 0FH, 72H, 0FH, 6FH
		DB	 0FH, 75H, 0FH, 6EH, 0FH, 64H
		DB	 0FH, 20H, 0FH, 74H, 0FH, 68H
		DB	 0FH, 69H, 0FH, 73H, 0FH, 20H
		DB	 0FH, 74H, 0FH, 65H, 0FH, 78H
		DB	 0FH, 74H, 0FH, 2EH, 0FH, 20H
		DB	 0FH, 20H, 0FH, 54H, 0FH, 68H
		DB	 0FH, 65H, 0FH, 20H, 0FH, 20H
		DB	 07H, 20H, 07H, 20H, 07H,0BAH
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H,0BAH, 07H, 20H, 07H, 20H
		DB	 07H, 74H, 0FH, 65H, 0FH, 78H
		DB	 0FH, 74H, 0FH, 20H, 0FH, 73H
		DB	 0FH, 68H, 0FH, 6FH, 0FH, 75H
		DB	 0FH, 6CH, 0FH, 64H, 0FH, 20H
		DB	 0FH, 62H, 0FH, 65H, 0FH, 20H
		DB	 0FH, 62H, 0FH, 72H, 0FH, 69H
		DB	 0FH, 67H, 0FH, 68H, 0FH, 74H
		DB	 0FH, 65H, 0FH, 72H, 0FH, 20H
		DB	 0FH, 74H, 0FH, 68H, 0FH, 61H
		DB	 0FH, 6EH, 0FH, 20H, 0FH, 74H
		DB	 0FH, 68H, 0FH, 65H, 0FH, 20H
		DB	 0FH, 62H, 0FH, 6FH, 0FH, 78H
		DB	 0FH, 2EH, 0FH, 20H, 07H, 20H
		DB	 07H, 20H, 07H,0BAH, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H,0BAH
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H,0BAH, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H,0BAH, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H,0BAH
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H,0C8H, 07H,0CDH, 07H,0CDH
		DB	 07H,0CDH, 07H,0CDH, 07H,0CDH
		DB	 07H,0CDH, 07H,0CDH, 07H,0CDH
		DB	 07H,0CDH, 07H,0CDH, 07H,0CDH
		DB	 07H,0CDH, 07H,0CDH, 07H,0CDH
		DB	 07H,0CDH, 07H,0CDH, 07H,0CDH
		DB	 07H,0CDH, 07H,0CDH, 07H,0CDH
		DB	 07H,0CDH, 07H,0CDH, 07H,0CDH
		DB	 07H,0CDH, 07H,0CDH, 07H,0CDH
		DB	 07H,0CDH, 07H,0CDH, 07H,0CDH
		DB	 07H,0CDH, 07H,0CDH, 07H,0CDH
		DB	 07H,0CDH, 07H,0CDH, 07H,0CDH
		DB	 07H,0CDH, 07H,0CDH, 07H,0CDH
		DB	 07H,0CDH, 07H,0CDH, 07H,0CDH
		DB	 07H,0CDH, 07H,0BCH, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 50H, 07H, 72H
		DB	 07H, 65H, 07H, 73H, 07H, 73H
		DB	 07H, 20H, 07H, 61H, 07H, 6EH
		DB	 07H, 79H, 07H, 20H, 07H, 6BH
		DB	 07H, 65H, 07H, 79H, 07H, 20H
		DB	 07H, 74H, 07H, 6FH, 07H, 20H
		DB	 07H, 63H, 07H, 6FH, 07H, 6EH
		DB	 07H, 74H, 07H, 69H, 07H, 6EH
		DB	 07H, 75H, 07H, 65H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 20H
		DB	 07H, 20H, 07H, 20H, 07H, 01H
LOC_31:
		CLI				; Disable interrupts
		MOV	BP,SP
		CALL	SUB_6			; (24E7)
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
SUB_6		PROC	NEAR
		POP	BX
		SUB	BX,131H
		TEST	BYTE PTR CS:COPYRIGHT+8[BX],1	; (97DE:012A=74H)
		JZ	$+11H			; Jump if zero
		LEA	SI,[BX+14DH]		; Load effective addr
		MOV	SP,682H
LOC_32:
		XOR	[SI],SI
		XOR	[SI],SP
		INC	SI
		DEC	SP
		JNZ	LOC_32			; Jump if not zero
		OR	AL,[BP+DI+4DH]
		ADC	AX,56CAH
		PUSH	DI
		CLD				; Clear direction
		POP	SP
		PUSH	SI
		PUSH	SI
		MOV	BL,5CH			; '\'
		INC	SP
		INC	SI
		INC	DX
		ADC	WORD PTR DS:[0AA46H][BX+DI],DI	; (97DE:AA46=0FFFFH)
		XLAT				; al=[al+[bx]] table
		INC	BP
		XCHG	AX,DI
		PUSH	AX
		POP	SS
		INC	DX
		JGE	$+5AH			; Jump if > or =
		POP	DX
		DB	 66H, 46H, 62H, 00H, 74H, 63H
		DB	 3AH, 21H, 6BH, 38H,0C9H,0B2H
		DB	 75H, 56H, 5AH,0B3H, 00H
		DB	 4FH, 42H, 42H, 46H, 46H
LOC_33:
		POP	DX
		PUSH	DX
		PUSH	SI
		PUSH	SI
		PUSH	DX
		PUSH	DX
		DB	 60H, 57H,0BEH, 5BH,0C2H
		DB	27H, '""', 27H, '&&}YVRRVVZ[FFVVR'
		DB	'R'
		DB	0B2H, 5AH, 56H, 0DH,0D3H,0B9H
		DB	0F5H, 57H, 74H,0D6H,0E9H, 32H
		DB	 63H, 4CH,0EFH,0E1H, 0CH, 5BH
		DB	 78H,0DDH,0D5H, 0AH, 57H,0F5H
		DB	 5AH, 5BH, 68H,0CCH,0C5H, 18H
		DB	 47H,0E4H, 58H, 5BH, 05H,0E2H
		DB	 62H, 9FH, 77H, 0DH, 66H, 58H
		DB	0D4H,0B7H, 1AH, 5DH,0EDH
LOC_34:
		XCHG	AX,BP
		MOVSW				; Mov [si] to es:[di]
		DB	 6AH,0A3H, 98H, 70H,0D0H,0AAH
		DB	0FFH, 0CH, 2CH, 4AH, 37H, 57H
		DB	0BAH, 5BH, 42H, 77H,0D2H,0D2H
		DB	 03H, 50H, 7FH,0AAH,0FAH, 0BH
		DB	 58H, 36H,0DDH
LOC_35:
		INC	AX
		PUSH	SP
		TEST	AL,44H			; 'D'
		RCR	BYTE PTR [BP+SI+7B0EH],CL	; Rotate thru carry
		ESC	0,DH			; coprocessor escape
		XOR	AL,54H			; 'T'
		JA	LOC_34			; Jump if above
		RETN	4026H
SUB_6		ENDP
  
		STC				; Set carry flag
		INC	BP
		MOV	CH,0D7H
		CWD				; Word to double word
;*		JMP	FAR PTR LOC_1		;*(68D0:B15D)
		DB	0EAH, 5DH,0B1H,0D0H, 68H
		PUSH	SS
		PUSH	SS
		SUB	AL,3EH			; '>'
		MOVSB				; Mov [si] to es:[di]
		POP	SP
		AND	SI,[DI+77H]
		SUB	AL,4DH			; 'M'
		DB	0D4H, 28H, 55H, 7FH, 75H, 20H
		DB	 54H,0D8H, 38H, 43H, 08H, 03H
		DB	 30H, 43H,0DAH, 24H, 5DH, 18H
		DB	 25H,0E6H,0EDH, 2EH, 59H,0D5H
		DB	0A8H, 28H,0EFH,0A4H, 4BH,0EEH
		DB	 6FH, 4FH, 55H, 73H,0D8H, 67H
		DB	 54H, 55H, 7FH,0D2H, 53H, 46H
		DB	 41H, 67H,0E6H, 46H, 59H, 7FH
		DB	 93H, 53H, 51H, 51H, 18H, 7EH
		DB	 89H, 13H,0E0H,0A5H, 4AH,0E7H
		DB	 28H, 63H, 09H,0EEH, 06H,0DDH
		DB	'èüw', 0DH, 'i•@Q'
		DB	 15H,0CFH,0F9H, 88H, 5DH,0D1H
		DB	0A1H,0EFH,0F7H, 54H,0ABH,0A5H
		DB	0FEH, 5CH,0EBH,0E9H, 12H, 60H
		DB	 37H,0ADH, 74H,0D6H,0D9H, 02H
		DB	 53H,0DFH,0D9H, 7CH, 5BH,0A9H
		DB	0E2H, 68H,0CEH, 4CH, 70H, 46H
		DB	 17H,0D4H, 93H, 70H,0DBH
		DB	'DUV|ú &"x'
		DB	 00H,0AAH, 54H
LOC_36:
		POP	BX
		PUSH	SI
		ADC	BX,SP
		XCHG	AX,DI
		DEC	AX
		PUSH	CX
		PUSH	SP
		INC	BP
		RETF				; Return far
		DB	0F1H, 68H, 43H,0F9H, 46H, 5BH
		DB	0E3H,0F3H, 50H,0AEH,0A1H,0F2H
		DB	 50H,0D7H, 5CH,0E2H, 64H, 32H
		DB	0A9H
		DB	'H°\vVVR|'
		DB	0DAH, 58H, 4CH, 5AH, 58H,0CBH
		DB	 54H, 5EH, 45H, 48H, 45H,0E2H
		DB	 77H, 73H, 9FH, 73H, 49H,0E2H
		DB	 40H,0E0H, 26H,0A6H, 6FH, 83H
		DB	 4EH, 55H, 5BH,0EFH, 7DH, 9AH
		DB	 72H,0D2H,0AEH, 93H, 5CH, 2CH
		DB	 22H, 33H, 69H,0C2H,0BEH,0FBH
		DB	 5CH, 2EH, 0AH, 49H,0EBH, 7BH
		DB	 62H, 9AH, 7AH, 75H,0EEH, 79H
		DB	 58H, 62H, 49H,0EBH, 5DH, 66H
		DB	 56H,0EFH, 7BH, 76H,0EDH
		DB	'u\UXäb\i'
		DB	0C7H, 55H, 0CH, 56H, 5FH,0B8H
		DB	 55H,0C7H,0D7H,0A5H, 51H, 55H
		DB	 13H,0CBH, 5EH, 25H, 9FH, 43H
		DB	 4EH,0BFH,0D3H, 52H, 13H, 79H
		DB	0F4H, 05H, 5AH, 69H,0E4H
		DB	'#BiÄ]?VVS'
		DB	0EBH, 4BH, 62H, 96H, 7AH, 49H
		DB	0EEH, 7DH, 50H, 66H, 49H,0D7H
		DB	 5DH, 62H, 56H, 4DH,0EBH, 4BH
		DB	 72H,0E1H,0E6H, 41H, 49H, 5CH
		DB	 8EH, 66H, 58H,0E0H, 8DH,0A8H
		DB	0BEH,0C4H,0ADH,0D7H,0ABH, 10H
		DB	 2FH,0B7H, 88H, 5DH, 8CH, 91H
		DB	0A7H,0E5H,0F0H, 03H, 78H, 96H
		DB	 54H, 61H, 57H,0D6H, 90H, 89H
		DB	 7AH,0BDH, 36H,0B7H, 7AH, 5AH
		DB	 2FH,0BEH,0CAH, 02H, 01H, 07H
		DB	 04H, 0CH, 0DH, 33H, 60H, 7CH
		DB	 4CH,0EFH, 70H, 1DH, 5BH, 78H
		DB	0DAH, 4CH, 1BH, 57H, 58H, 5DH
		DB	0E2H, 46H, 7BH, 8FH, 63H, 34H
		DB	 10H,0D1H, 82H,0EEH, 56H, 05H
		DB	 9FH, 77H, 78H,0D3H, 4CH, 65H
		DB	 27H, 0CH,0ABH, 28H, 63H, 5BH
		DB	0EEH, 69H, 58H, 4DH,0E8H, 78H
		DB	 57H,0E3H
		DB	'YFãc0q}õ/e'
		DB	0EEH, 50H, 10H, 65H, 9FH, 69H
		DB	 88H,0ABH, 47H, 4CH,0C1H, 2DH
		DB	 67H, 74H,0D3H, 40H, 1BH, 53H
		DB	0E6H, 68H, 9BH, 7BH, 74H,0C7H
		DB	 78H, 6CH, 43H, 0BH, 1CH, 2FH
		DB	 59H,0BFH, 91H, 52H, 7CH,0D5H
		DB	 68H, 17H, 5BH,0A6H,0D1H,0ABH
		DB	 8CH, 27H, 98H, 11H, 5CH, 6AH
		DB	0A8H, 23H, 56H,0B8H,0E2H, 5DH
		DB	 73H,0C1H, 7FH, 6BH, 44H,0A8H
		DB	 34H, 53H, 73H,0F0H, 1AH, 54H
		DB	 50H, 08H,0A8H, 73H, 66H, 67H
		DB	 4EH, 64H, 11H, 86H,0D9H, 5DH
		DB	 1EH, 7FH, 94H, 43H, 12H, 50H
		DB	 9CH, 7CH, 2FH, 9AH, 6FH,0CCH
		DB	 4BH, 00H, 40H,0DDH,0ACH, 71H
		DB	0A7H, 94H, 72H, 25H, 58H,0E5H
		DB	 5CH, 62H, 12H,0ECH,0E8H, 00H
		DB	 53H, 98H,0E5H, 53H, 6CH, 98H
		DB	 74H, 23H,0EFH,0D6H, 85H,0F9H
		DB	 43H, 07H, 76H, 88H, 72H, 8FH
		DB	 90H, 70H,0B9H, 05H, 56H, 22H
		DB	 49H,0E5H, 5DH, 23H, 4FH,0EEH
		DB	 6BH, 2CH, 60H, 73H,0D6H, 47H
		DB	 1AH, 54H, 98H, 70H,0E5H, 1DH
		DB	 6EH, 88H, 8CH, 64H,0AEH, 60H
		DB	0D1H,0E5H, 5DH, 13H, 62H, 9CH
		DB	 66H, 83H, 9CH, 7CH, 2FH,0B4H
		DB	 80H, 0BH,0E1H,0AFH,0ABH,0ACH
		DB	0ADH, 70H,0FDH, 0AH, 5BH,0EAH
		DB	 1EH,0E8H, 1DH, 4FH,0F7H, 49H
		DB	 4AH, 83H, 6FH,0EAH, 53H, 09H
		DB	 70H,0D1H, 4CH, 1DH, 5FH, 7CH
		DB	0D9H, 60H, 2BH, 6BH,0A7H, 4FH
		DB	0DAH, 6CH, 9FH, 7FH, 70H,0D1H
		DB	 54H, 1FH, 5FH,0A4H, 93H, 49H
		DB	 3BH, 4FH,0BCH, 8FH, 6EH, 27H
		DB	 58H,0E6H, 5FH, 19H, 74H, 9BH
		DB	 48H, 15H, 53H,0E3H, 0FH, 35H
		DB	 2DH, 73H, 71H, 0CH, 08H, 07H
		DB	 05H, 02H,0C7H,0B7H,0ECH,0ACH
		DB	 4CH, 40H, 51H, 19H, 1BH, 1CH
		DB	 1EH,0EBH, 55H, 5EH,0E5H, 2EH
		DB	 5BH,0A1H, 69H,0D9H, 15H, 90H
		DB	 7FH
		DB	'm!%å•', 0AH, 'OY'
		DB	0D1H, 4DH, 06H, 55H, 92H, 26H
		DB	 4CH,0B9H,0A8H,0C1H, 8CH, 14H
		DB	 0BH, 09H, 41H, 9DH, 44H, 5CH
		DB	 08H, 09H, 03H, 5CH,0A9H, 17H
		DB	0EAH,0AAH, 20H, 77H,0EDH, 35H
		DB	 5EH,0E1H, 37H, 5BH,0E6H, 57H
		DB	 53H,0AFH,0BCH,0EAH, 12H, 14H
		DB	 11H, 48H, 4CH, 90H, 09H, 41H
		DB	 09H,0D1H, 99H,0A9H, 75H, 01H
		DB	 6EH,0D9H, 6BH, 68H,0ADH,0BEH
		DB	0B3H, 50H, 59H, 05H, 5AH,0D0H
		DB	0AFH,0A9H, 55H, 07H, 4EH,0B0H
		DB	0C5H, 55H, 17H, 4EH, 27H, 41H
		DB	0E5H, 85H, 58H,0A1H,0B3H,0F7H
		DB	 5BH, 26H, 26H, 87H, 2AH, 5EH
		DB	0D8H,0C3H,0FBH, 52H, 2BH,0A4H
		DB	0F6H,0A0H, 05H, 40H, 0DH, 90H
		DB	 18H, 49H, 19H, 18H,0C4H, 97H
		DB	0D9H, 95H,0A9H, 79H, 09H, 5AH
		DB	0E9H, 5FH, 50H, 91H,0BEH, 8FH
		DB	 68H, 6DH, 35H, 6EH,0D8H,0ABH
		DB	0A9H, 59H, 0FH, 5AH,0A0H,0D1H
		DB	 55H, 0BH, 4EH, 3BH, 59H,0F1H
		DB	 95H, 4CH,0A9H,0BFH,0F7H, 57H
		DB	 2EH, 52H,0F7H, 5EH, 26H,0A4H
		DB	 43H, 06H,0ABH,0DEH, 55H, 25H
		DB	 91H,0F8H,0A5H, 05H, 00H, 5DH
		DB	 01H, 9DH, 03H, 03H,0C5H, 40H
		DB	 16H, 4BH,0ACH,0B0H, 0BH,0B0H
		DB	0A8H, 07H, 99H, 0AH,0BAH, 3FH
		DB	 66H, 50H, 4AH, 90H, 8CH, 0BH
		DB	 36H,0ADH
		DB	'nR*Tfz*Xn'
		DB	0ADH, 3AH, 4CH,0B2H, 89H,0B7H
		DB	 8DH, 6EH,0E2H, 2CH, 58H, 66H
		DB	 85H, 29H, 5CH,0ABH, 91H,0D6H
		DB	0EDH, 34H, 92H, 6EH, 2EH,0DCH
		DB	 8AH,0A5H,0FFH, 36H, 5AH, 65H
		DB	 58H, 3EH, 52H, 3AH,0B4H, 79H
		DB	 83H,0EFH, 22H, 52H, 13H
		DB	'*Ka\2^&•q'
		DB	0E5H,0ABH, 59H,0BCH,0D7H, 5DH
		DB	 52H,0A9H,0AFH, 74H,0F9H, 02H
		DB	 5FH, 91H, 1BH,0A5H,0A0H, 8CH
		DB	 4CH, 1DH, 4FH, 4AH, 4CH,0E6H
		DB	 1EH, 5AH,0D4H, 86H,0FFH, 1CH
		DB	 52H,0B1H, 0DH,0F0H,0ABH, 1CH
		DB	 51H,0EAH, 61H, 4CH,0EAH, 59H
		DB	 5FH, 08H, 90H, 41H, 0CH, 4AH
		DB	0CDH,0B3H,0B6H, 39H, 49H,0D9H
		DB	 47H, 0EH, 5CH,0EDH, 56H, 90H
		DB	 4DH,0D9H, 77H, 3FH, 6CH,0AFH
		DB	 6FH, 39H, 6CH, 51H, 96H, 5BH
		DB	 05H, 58H, 59H,0EDH, 61H, 56H
		DB	 25H, 7BH, 3FH, 4AH,0A0H,0ADH
		DB	 4DH, 96H, 57H, 05H, 5CH, 59H
		DB	0E1H, 61H, 5EH, 26H, 76H, 11H
		DB	 2FH, 5BH, 0AH,0EBH, 2BH, 05H
		DB	 50H, 5CH,0FDH, 0AH, 58H,0A3H
		DB	 9DH,0A7H, 77H, 1FH, 4CH,0EAH
		DB	 2BH, 4CH,0ECH
		DB	'5Pf[;X+^'
		DB	0F0H, 33H, 6CH, 85H, 02H, 97H
		DB	 2DH,0E6H,0A1H, 62H,0A2H, 1AH
		DB	0F8H, 3BH, 5CH, 8CH,0B1H, 6AH
		DB	0B5H, 3BH, 4AH,0A0H,0EDH, 4DH
		DB	0D1H, 5FH, 0AH, 5CH, 5BH,0F9H
		DB	 0FH, 5CH,0E5H, 51H, 45H,0E2H
		DB	 54H, 20H, 7EH, 0EH, 01H, 53H
		DB	0EAH, 5EH,0B2H, 18H,0A0H,0D4H
		DB	0A2H,0BAH,0C8H,0B0H,0A2H, 5BH
		DB	0B1H, 3CH, 80H,0BAH, 42H,0A1H
		DB	 28H, 97H,0FCH, 0BH, 53H,0DAH
		DB	 48H, 38H, 6BH,0E0H, 60H, 3DH
		DB	 53H,0E7H
		DB	'^†ú`h', 0DH, 'S%'
		DB	 1CH,0A6H, 2EH,0B4H, 74H, 68H
		DB	 04H, 53H, 2BH, 17H,0B2H,0B3H
		DB	0A0H, 2CH, 7AH,0BAH,0DAH,0D0H
		DB	 58H, 15H,0D0H,0E8H, 68H, 64H
		DB	 0DH, 5FH, 2DH, 6DH,0B6H, 17H
		DB	0ACH, 68H, 68H, 18H, 4BH, 3FH
		DB	 60H,0A6H, 9CH,0ACH, 2DH,0BBH
		DB	0B2H,0E4H,0A0H,0A0H, 9CH,0BAH
		DB	 58H, 90H,0C8H, 3FH, 6FH, 90H
		DB	 94H,0D2H, 78H, 09H, 5BH,0A7H
		DB	0A0H, 90H,0E2H, 72H,0A6H, 13H
		DB	0B4H,0B4H, 88H,0EEH, 07H, 53H
		DB	0B6H, 0BH,0A4H,0B9H, 5AH,0B6H
		DB	0DCH,0ACH,0E7H, 45H, 0CH, 5CH
		DB	0A8H,0F9H, 53H, 51H, 2BH, 5CH
		DB	0B2H, 07H,0A0H,0B7H,0D8H,0ADH
		DB	 01H, 3BH, 48H,0A2H, 1EH,0B0H
		DB	0B7H, 32H, 7BH,0A3H,0BDH
		DB	 3AH, 9CH
LOC_37:
		JNO	$-59H			; Jump if not overflw
		PUSH	BP
		CMP	[BP+62H],CH
		PUSH	DS
		AAA				; Ascii adjust
		INC	CX
		RCR	WORD PTR [DI+8],CL	; Rotate thru carry
		POP	SI
		POP	DX
		JNZ	$-5EH			; Jump if not zero
		PUSH	CX
		OR	AX,3A52H
		OR	DL,[DI+4DH]
		INC	CX
		PUSH	AX
		POP	BP
		PUSH	SP
;*		POP	CS			; Dangerous 8088 only
		DB	0FH
		OR	AL,0AH
		OR	[BX+DI],CX
		OR	BYTE PTR DS:[0FE3H],AL	; (97DE:0FE3=7)
		DB	0C9H, 0BH
		DB	'äO.nk[,X'
		DB	0E3H, 67H, 5BH,0BBH, 2DH,0B2H
		DB	 0FH,0E8H, 15H, 4EH,0ECH
		DB	 33H, 52H
LOC_38:
		MOV	BH,0C8H
		MOVSW				; Mov [si] to es:[di]
		JCXZ	$+5EH			; Jump if cx=0
		POP	DI
		MOV	BX,923DH
		DAS				; Decimal adjust
		PUSHF				; Push flags
		DEC	BP
		OR	BP,[BP+20H]
		PUSH	AX
		OUT	0A0H,AX			; port 0A0H, initialize, 4 byte
		MOVSB				; Mov [si] to es:[di]
		CLC				; Clear carry flag
		CMP	BX,[BP+0EH]
		OR	AL,11H
		ADC	AX,1012H
		POP	SS
		DEC	AX
		DEC	SP
		JGE	LOC_38			; Jump if > or =
		JNS	$+0EH			; Jump if not sign
		POP	DX
		MOV	AX,DS:DATA_17E		; (97DE:AC71=0FFFFH)
		JGE	LOC_37			; Jump if > or =
		SCASW				; Scan es:[di] for ax
		TEST	BL,[SI-58H]
		STC				; Set carry flag
		PUSH	BX
		POP	DX
		SUB	AL,[BP+DI+0AH]
		OR	CX,[SI]
		JMP	FAR PTR $+746BH
		MOV	BL,8EH
		DEC	CX
		CMP	AL,5FH			; '_'
		AND	AX,0DE5BH
		MOVSB				; Mov [si] to es:[di]
		PUSH	AX
		SUB	AL,58H			; 'X'
		JL	$-2CH			; Jump if <
		DEC	AX
		CMP	[BP+DI-63H],BP
		XOR	AL,37H			; '7'
		OR	BH,[SI-5FH]
		JO	$+63H			; Jump if overflow=1
		POP	BX
		POP	AX
		OR	AX,1AE6H
		CMC				; Complement carry
		AND	AX,874AH
		DB	 6FH, 15H
		DB	'!QßYôtòXRS/†'
		DB	0EAH, 24H, 31H, 1DH,0ADH,0ECH
		DB	 5EH, 5FH,0E3H,0FFH, 58H,0A2H
		DB	0A1H,0F6H,0F1H, 6DH, 4AH,0F4H
		DB	 6DH, 4FH, 51H, 64H, 15H, 5FH
		DB	0E3H,0D8H
		DB	'XxcgH_g-(å§'
		DB	0DCH, 86H,0EAH, 1AH, 69H, 8CH
		DB	0E7H,0F7H, 54H, 83H, 6FH,0D6H
		DB	 1AH,0FAH, 07H, 9FH, 73H, 06H
		DB	0C3H, 54H, 45H, 2CH,0E4H, 69H
		DB	 93H,0DBH, 18H,0ADH
		DB	 52H, 6DH
  
SEG_A		ENDS
  
  
  
		END	START
