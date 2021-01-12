;	KEY-FAKE.ASM -- Fakes keystrokes from internal keyboard buffer.
;	============

CSEG		Segment 
		Assume	CS:CSEG
		Org	0100h
Entry:		Jmp	Initialize

;	Most Resident Data
;	------------------

		db	'KEY-FAKE (C) Copyright Charles Petzold, 1985'
SearchLabelEnd	Label	Byte 

OldInterrupt16	dd	0
Pointer		dw	Offset KeyStrokeBuffer
Counter		db	0

;	New Interrupt 16 (Keyboard)
;	---------------------------

NewInterrupt16	Proc	Far

		Sti			; Allow futher interrupts	
		Cmp	CS:[Counter],0	; See if characters in buffer
		Jz	DoOldInterrupt	; If not, just do regular interrupt

		Or	AH,AH		; Check if AH is zero
		Jz	GetCharacter	; If so, call is to get character

		Cmp	AH,1		; Check if AH is one
		Jz	GetStatus	; If so, call is for status 

DoOldInterrupt:	Jmp	CS:[OldInterrupt16]	; Otherwise, go away

GetCharacter:	Push	BX
		Mov	BX,CS:[Pointer]	; BX points to current buffer position
		Mov	AX,CS:[BX]	; Get ASCII code and scan code
		Inc	BX		; Move buffer pointer ahead
		Inc	BX
		Mov	CS:[Pointer],BX	; Save new pointer
		Dec	CS:[Counter]	; One less character in counter
		Pop	BX

		Or	AX,AX		; See if 0 returned
		Jz	NewInterrupt16	; If so, take it from the top again
		
		IRet			; Return to calling program

GetStatus:	Push	BX
		Mov	BX,CS:[Pointer]	; BX points to current buffer position
		Mov	AX,CS:[BX]	; Get ASCII code and scan code
		Pop	BX

		Or	AX,AX		; See if special 0 keystroke
		Jnz	StatusReturn	; If not, return non-zero flag

		Add	CS:[Pointer],2	; If so, skip over it
		Dec	CS:[Counter]	; One less character
		Or	AX,AX		; Will set zero flag

StatusReturn:	Ret	2		; Do not pop flags

NewInterrupt16	EndP

;	Beginning of Key Stroke Buffer
;	------------------------------

KeyStrokeBuffer	Label	Byte		; 256 Byte Buffer for keystrokes

;	Initialization -- Search through Memory and see if label matches
;	----------------------------------------------------------------
;
;		If so, use the loaded program; if not, create a new interrupt

		Assume	DS:CSEG, ES:CSEG, SS:CSEG

Initialize:	Mov	Word Ptr [Entry],0	; Slightly modify search label
		Mov	Byte Ptr [Entry + 2],0	;   so no false matches

		Cld
		Mov	DX,CS			; This segment
		Sub	AX,AX			; Beginning of search
		Mov	ES,AX			; Search segment

SearchLoop:	Mov	SI,100h			; Address to search
		Mov	DI,SI			; Set pointers to same address
		Mov	CX,Offset SearchLabelEnd - Offset Entry
		Repz	Cmpsb			; Check for match
		Jz	ReadyForDecode		; If label matches

		Inc	AX			; Still the search segment 
		Mov	ES,AX			; ES to next segment

		Cmp	AX,DX			; Check if it's this segment
		Jnz	SearchLoop		; Try another compare

		Mov	Byte Ptr DS:[1],27h	; Since no match found,
						;   set up PSP for Terminate &
						;   remain resident.

;	Save and Set Interupt 16 if Staying Resident
;	--------------------------------------------

		Sub	AX,AX			; Set AX to zero
		Mov	DS,AX			; To access vector segment
		Assume	DS:Nothing		; Tell the assembler

		Mov	AX,Word Ptr DS:[16h * 4]	; Get vector offset
		Mov	Word Ptr CS:[OldInterrupt16],AX	; Save it
		Mov	AX,Word Ptr DS:[16h * 4 + 2]	; Get vector segment
		Mov	Word Ptr CS:[OldInterrupt16 + 2],AX	; and save it

		Cli					; Don't interrupt me
		Mov	DS:[16h * 4],Offset NewInterrupt16	; Store new
		Mov	DS:[16h * 4 + 2],CS		; address
		Sti					; Now you can talk

		Push	CS
		Pop	DS				; Restore DS
		Assume	DS:CSEG

;	Parameter decoding when program segment has been found
;	------------------------------------------------------
;
;		ES = segment of loaded program (could be CS)

ReadyForDecode:	Mov	SI,80h		; SI points to parameter area
		Mov	DI,Offset KeyStrokeBuffer
		Mov	ES:[Pointer],DI	; ES:DI points to buffer area
		Mov	ES:[Counter],0	; Set keystroke counter to zero

		Lodsb			; Get parameter count
		Cbw			; Convert to word
		Mov	CX,AX		; CX = parameter count
		Inc	CX		; So catch last delimiter (0D)
		Or	AX,AX		; Check if parameter present
		Jnz	GoDecodeLoop	; If so, continue
		Jmp	EndDecode	; If not, cut out

GoDecodeLoop:	Jmp	DecodeLoop

;	End of Residence is end of Key Stroke Buffer
;	--------------------------------------------

		Org	256 + Offset KeyStrokeBuffer

EndResidence	Label	Byte

;	Data for Parameter Decoding
;	---------------------------

QuoteSign	db	0		; Flag for quoted strings
DoingNumber	db	0		; Flag for doing a number	
DoingExtended	db	0		; Flag for doing extended ASCII	
CalcNumber	db	0		; A calculated number 
Ten		db	10		; For MUL convenience 

;	Routine for doing quoted text
;	-----------------------------
		
DecodeLoop:	Lodsb			; Get character
		Cmp	[QuoteSign],0	; Check if doing quoted text
		Jz	NotDoingQuote	; If not, continue checks

		Cmp	AL,[QuoteSign]	; Check first if character is quote
		Jz	EndQuote	; If so, finish quoted text

		Sub	AH,AH		; Set scan code to zero
		Stosw			; Save it in buffer
		Inc	ES:[Counter]	; One more character
		Jmp	DoNextCharacter	; Go to bottom of routine

EndQuote:	Mov	[QuoteSign],0	; End of quoted text
		Jmp	DoNextCharacter	; Get the next character

;	Routine for Extended Ascii Character (@)
;	----------------------------------------

NotDoingQuote:	Cmp	AL,'@'		; See if character is for extended
		Jnz	NotExtended	; If not, hop over a little code

		Mov	[DoingExtended],1	; Flag for extended ASCII 
		Jmp	Delimiter		; To possibly dump number

;	Routine for Quote Sign ' or "
;	-----------------------------

NotExtended:	Cmp	AL,'"'		; Check for a double quote sign
		Jz	Quote	
		Cmp	AL,"'"		; Check for a single quote sign
		Jnz	NotAQuote

Quote:		Mov	[QuoteSign],AL	; Save the quote sign
		Jmp	Delimiter	; To possibly dump number

;	Routine for decimal number
;	--------------------------

NotAQuote:	Cmp	AL,'0'		; See if character >= 0
		Jb	Delimiter
		Cmp	AL,'9'		; See if character <= 9
		Ja	Delimiter

		Mov	[DoingNumber],1		; If so, doing number

		Sub	AL,'0'			; Convert to binary
		Xchg	AL,[CalcNumber]		; Get previously calculated
		Mul	[Ten]			; Multiply by 10
		Add	[CalcNumber],AL		; Add it to new digit

		Jmp	DoNextCharacter		; And continue

;	Anything else is considered a delimiter
;	---------------------------------------

Delimiter:	Cmp	[DoingNumber],1		; Check if doing a number
		Jnz	DoNextCharacter		; If not, do not dump

		Mov	AL,[CalcNumber]		; Set AX to ASCII number
		Sub	AH,AH			; Zero out scan code part
		Cmp	[DoingExtended],1	; Check if doing scan code
		Jnz	NumberOK

		Xchg	AL,AH			; Switch ASCII and scan code
		
NumberOK:	Stosw				; Store the two codes
		Inc	ES:[Counter]		; One more character in buffer

		Mov	[DoingNumber],0		; Clear out all flags
		Mov	[DoingExtended],0
		Mov	[CalcNumber],0

DoNextCharacter:Dec	CX			; One less character to do
		Jz	EndDecode		; If no more, we're done
		Jmp	DecodeLoop		; Otherwise, get next one

;	End Decode -- Ready to terminate (and possibly stay resident)
;	-------------------------------------------------------------

EndDecode:	Mov	DX,Offset EndResidence	; End of resident part
		Ret				; Int 20h or 27h

CSEG		EndS

		End Entry
