TITLE	DRIP	5-26-87	[4-21-88]

;Goes TSR, activate/toggle with Scroll Lock key.
;Characters randomly drip down/off the screen

LF	EQU	0AH
CR	EQU	0DH
;

Cseg	SEGMENT
	ASSUME DS:Cseg, SS:Cseg ,CS:Cseg ,ES:Cseg
	ORG	100H


Drip	proc	near
	JMP	Start

int8Vec	dd	0			;save old Int 8 vector
saveDI	dw	0
saveSI	dw	0

video	dw	0B000H			;default mono screen memory

wcntr_13A	dw	40H		;counter
byte_13C	DB	0FFH
bflag_13D	DB	0
bcntr_13E	DB	0
bflag_13F	DB	0
bcntr_140	DB	0
word_2BE	dw	0
Drip	endp


NewInt8	proc	far
	ASSUME	DS:Nothing

	PUSHF				;save user's flags
	PUSH	AX			;and his Int 8 request
	MOV	AH,2			;get shift status
	INT	16H
	AND	AL,10H			;mask for Scroll Lock key
	JZ	Continue_Int8		; continue to Int 8
	CMP	CS:bcntr_13E,0		;counter zeroed?
	JZ	L01A0			; yep, time to act
	 DEC	CS:bcntr_13E		;decr counter
	 JMP	SHORT	Continue_Int8

L01A0:	CMP	CS:bflag_13D,0		;flag set?
	JNZ	Continue_Int8		; yep, just continue to Int 8
	 JMP	SHORT	L01B2		;time to act

Continue_Int8:
	POP	AX			;restore user's Int 8 svc
	POPF				;restore user's flags
	JMP	CS:int8Vec		;jump to old Int 8

L01B2:	PUSHF				;save flags
	CALL	CS:int8Vec		;call old Int 8
	PUSH	ES			;save all his regs
	PUSH	DS
	PUSH	DX
	PUSH	CX
	PUSH	DI
	PUSH	SI
	mov	ax,CS
	mov	DS,ax
	ASSUME	DS:Cseg

	MOV	AX,video
	MOV	ES,AX
	ASSUME	ES:Nothing

	cmp	bflag_13F,0		;flag clear?
	JZ	L01D9			; yep
	 MOV	DI,saveDI		;get our screen pointers
	 MOV	SI,saveSI
	 STI				;enable ints
	 JMP	SHORT	MoveChar	;go to work

L01D9:	MOV	bflag_13D,0FFH		;set flag
	STI				;enable interrupts
	MOV	bcntr_140,64H		;refresh counter
Lup1E4:	CMP	bcntr_140,0		;zeroed out?
	JNZ	L01EE			; nope
	 JMP	Pop_Iret		; return

L01EE:	DEC	bcntr_140		;count down
	CALL	L02AC
	AND	AX,0FFEH
	MOV	SI,AX
	MOV	AL,ES:[SI]
	CMP	AL,20H			;just a space?
	JZ	Lup1E4			; yep, try again
	or	al,al			;just a zero?
	JZ	Lup1E4			; yep, try again
	CMP	SI,0FA0H		;screen bottom?
	JNB	Lup1E4			; not yet, try again
	MOV	DI,SI			;point to new char location
	ADD	DI,0A0H			;move this far each time (1 line)
	CMP	DI,0FA0H		;screen bottom?
	JNB	L025B			;not yet, continue
	MOV	AL,ES:[DI]		;get char at new location
	CMP	AL,20H			;just a space?
	JZ	Save_Iret		;yep, save screen ptrs, Iret
	or	al,al			;just a zero?
	JNZ	Lup1E4			; yep, continue
Save_Iret:
	MOV	saveDI,DI			;save screen pointers
	MOV	saveSI,SI
	MOV	bflag_13F,0FFH			;reset flag
	JMP	SHORT	Pop_Iret		;return

MoveChar:
	MOV	bflag_13F,0			;turn flag off
	MOV	AL,ES:[SI]			;snarf screen char
	MOV	ES:[DI],AL			;move it here
	MOV	BYTE PTR ES:[SI],20H		;blank out old char
	MOV	SI,DI
	ADD	DI,0A0H
	CMP	DI,0FA0H			;screen bottom?
	JNB	L025B				; not yet
	MOV	AL,ES:[DI]			;get char
	CMP	AL,20H				;just a space?
	JZ	Save_Iret			; yep, save ptrs, Iret
	or	al,al				; a 0?
	JZ	Save_Iret			; yep, save ptrs, Iret
	JMP	SHORT	L025F

L025B:	MOV	BYTE PTR ES:[SI],20H		;stuff space on screen
L025F:	DEC	wcntr_13A			;decrement counter
	JNZ	L026F
	 SHR	byte_13C,1
	 MOV	wcntr_13A,40H			;refresh counter
L026F:	CALL	L02AC
	AND	AL,byte_13C
	MOV	bcntr_13E,AL
Pop_Iret:
	POP	SI
	POP	DI
	POP	CX
	POP	DX
	POP	DS
	POP	ES
	POP	AX
	POPF
	MOV	CS:bflag_13D,0			;clear flag
	IRET
NewInt8	endp

L02AC	proc	near
	MOV	AX,word_2BE
	PUSH	AX
	AND	AH,0B4H
	POP	AX
	JPE	L02B7
	 STC
L02B7:	RCL	AX,1
	MOV	word_2BE,AX
	RET
L02AC	endp


Start	proc	near
	MOV	ax,3508H		;get Int8 vector
	INT	21H
	mov	word ptr int8Vec,bx	;save ofs
	mov	word ptr int8Vec+2,ES	;save seg

	MOV	AH,2CH			;get DOS system time
	INT	21H
	MOV	word_2BE,DX		;save seconds, deciseconds
	MOV	bcntr_13E,0FFH		;refresh counter
	MOV	AH,0FH			;get current video mode
	INT	10H
	CMP	AL,6			;?
	JZ	Use_Mono		; yep
	CMP	AL,7			;mono?
	JZ	Use_Mono		;yep
	 MOV	video,0B800H		;use color screen

Use_Mono:
	MOV	DX,OFFSET NewInt8	;DS:dx = our service
	mov	ax,2508H		;set new Int 8 vector
	INT	21H

	MOV	DX,offset Start		;program end
	MOV	CL,4
	SHR	DX,CL			;compute size in paras
	INC	DX			;safeside
	MOV	AH,31H			;advanced TSR
	INT	21H

	DB	'DRIP Version 2.01',0	;,CR,LF
	DB	'G. Masters 5/25/87',0	;,CR,LF
	db	'Toad Hall 880421',0
;	DB	1AH
;	DB	90H
Start	endp


Cseg	ENDS
	END	Drip
