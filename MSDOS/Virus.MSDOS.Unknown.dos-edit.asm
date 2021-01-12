;	DOS-EDIT.ASM -- Resident DOS Command Line Editor
;	================================================

CSEG		Segment
		Assume	CS:CSEG

		Org	0080h
KeyboardBuffer	Label	Byte

		Org	0100h
Entry:		Jmp	Initialize

;	All Data
;	--------

		db	"(C) Copyright 1985 Ziff-Davis Publishing Co."

OldInterrupt21	dd	?		; Original Interrupt 21 vector
OldInterrupt16	dd	?		; Original Interrupt 16 vector
DoingBuffKey	db	0		; Flag for doing Function Call 0Ah
BufferPointer	dw	KeyboardBuffer	; Pointer to Keyboard Buffer
BufferCounter	db	0		; Number of characters in buffer
MaxCharCol	db	?		; Maximum Character Column on screen
OriginalCursor	dw	?		; Place to save cursor on full-screen
InsertOn	db	0		; Insert mode flag

KeyRoutine	dw	Home,Up,PgUp,Dummy,Left,Dummy,Right
		dw	Dummy,End,Down,PgDn,Insert,Delete

;	New Interrupt 21 (DOS Function Calls)
;	-------------------------------------

NewInterrupt21	Proc	Far

		Mov	CS:[DoingBuffKey],0	; Turn flag off initially

		Cmp	AH,0Ah			; Check if doing buffered input
		Jz	BufferedInput

		Jmp	CS:[OldInterrupt21]	; If not, do regular interrupt

BufferedInput:	Mov	CS:[DoingBuffKey],-1	; If so, turn on flag

		PushF				; Simulate regular interrupt
		Call	CS:[OldInterrupt21]

		Mov	CS:[DoingBuffKey],0	; Turn off flag
		Mov	CS:[BufferCounter],0	; Re-set character counter

		IRet				; Return to user program

NewInterrupt21	EndP

;	New Interrupt 16 (BIOS Keyboard Routine)
;	----------------------------------------

NewInterrupt16	Proc	Far

		Sti				; Re-enable interrupts
		Cmp	CS:[DoingBuffKey],0	; Check if doing call 0Ah
		Jz	DoNotIntercept		; If not, do old interrupt

		Cmp	CS:[BufferCounter],0	; Check if chars in buffer
		Jnz	Substitute		; If so, get them out

		Cmp	AH,0			; See if doing a get key
		Jz	CheckTheKey		; If so, get the key

DoNotIntercept:	Jmp	CS:[OldInterrupt16]	; Otherwise, do old interrupt

CheckTheKey:	PushF				; Save flags
		Call	CS:[OldInterrupt16]	; Do regular interrupt

		Cmp	AX,4800h		; Check if up cursor
		Jnz	NotTriggerKey		; If not, don't bother 

		Call	FullScreen		; Move around the screen
 
		Cmp	CS:[BufferCounter],0	; Any chars to deliver?
		Jz	CheckTheKey		; If not, get another key

ReturnBuffer:	Call	GetBufferChar		; Otherwise, pull one out

		Inc	CS:[BufferPointer]	; Kick up the pointer
		Dec	CS:[BufferCounter]	; And knock down the counter

NotTriggerKey:	IRet				; And go back to calling prog

;	Substitute Key from Buffer
;	--------------------------

Substitute:	Cmp	AH,2			; See if shift status check
		Jae	DoNotIntercept		; If so, can't be bothered

		Cmp	AH,0			; See if get a key
		Jz	ReturnBuffer		; If so, get the key above

		Call	GetBufferChar		; Otherwise get a key
		Cmp	CS:[BufferCounter],0	; And clear zero flag

		Ret	2			; Return with existing flags

NewInterrupt16	EndP

;	Get Buffer Character
;	--------------------

GetBufferChar:	Push	BX		
		Mov	BX,CS:[BufferPointer]	; Get pointer to key buffer
		Mov	AL,CS:[BX]		; Get the key
		Sub	AH,AH			; Blank out scan code
		Pop	BX
		Ret

;	Full Screen Routine
;	-------------------

FullScreen:	Push	AX			; Save all these registers
		Push	BX
		Push	CX
		Push	DX
		Push	DI
		Push	DS
		Push	ES

		Mov	AX,CS			; Set AX to this segment
		Mov	DS,AX			; Do DS is this segment
		Mov	ES,AX			; And ES is also

		Assume	DS:CSEG, ES:CSEG	; Tell the assembler

		Mov	AH,0Fh			; Get Video State
		Int	10h			;   through BIOS
		Dec	AH			; Number of columns on screen
		Mov	[MaxCharCol],AH		; Save maximum column
						; BH = Page Number throughout
		Mov	AH,03h			; Get cursor in DX
		Int	10h			;   through BIOS
		Mov	[OriginalCursor],DX	; And save the cursor position

		Call	Up			; Move cursor up	

MainLoop:	Cmp	DH,Byte Ptr [OriginalCursor + 1]	; If at line
		Jz	TermFullScreen		; stated from, terminate

		Mov	AH,02h			; Set cursor from DX
		Int	10h			;   through BIOS

GetKeyboard:	Mov	AH,0			; Get the next key
		PushF				; By simulating Interrupt 16h
		Call	CS:[OldInterrupt16]	;   which goes to BIOS

		Cmp	AL,1Bh			; See if Escape key
		Jz	TermFullScreen		; If so, terminate full screen

;	Back Space
;	----------

		Cmp	AL,08h			; See if back space
		Jnz	NotBackSpace		; If not, continue test

		Or	DL,DL			; Check if cursor at left
		Jz	MainLoop		; If so, do nothing	

		Dec	DL			; Otherwise, move cursor back
		Call	ShiftLeft		; And shift line to the left

		Jmp	MainLoop		; And continue for next key

;	Carriage Return
;	---------------

NotBackSpace:	Cmp	AL,0Dh			; See if Carriage Return
		Jnz	NotCarrRet		; If not, continue test

		Call	End			; Move line into buffer

		Mov	AL,0Dh			; Tack on a Carriage Return
		Stosb				; By writing to buffer
		Inc	[BufferCounter]		; One more character in buffer

		Jmp	MainLoop		; And continue

;	Normal Character
;	----------------

NotCarrRet:	Cmp	AL,' '			; See if normal character
		Jb	NotNormalChar		; If not, continue test

		Cmp	[InsertOn],0		; Check for Insert mode
		Jz	OverWrite		; If not, overwrite 

		Call	ShiftRight		; Shift line right for insert
		Jmp	Short NormalCharEnd	; And get ready to print

OverWrite:	Mov	CX,1			; Write one character
		Mov	AH,0Ah			; By calling BIOS
		Int	10h

NormalCharEnd:	Call	Right			; Cursor to right and print

		Jmp	MainLoop		; Back for another key

;	Cursor Key, Insert, or Delete Subroutine
;	----------------------------------------

NotNormalChar:	Xchg	AL,AH			; Put extended code in AL
		Sub	AX,71			; See if it's a cursor key
		Jc	GetKeyboard		; If not, no good

		Cmp	AX,12			; Another check for cursor
		Ja	GetKeyboard		; If not, skip it 

		Add	AX,AX			; Double for index
		Mov	DI,AX			;   into vector table

		Call	[KeyRoutine + DI]	; Do the routine

		Jmp	MainLoop		; Back for another key	

;	Terminate Full Screen Movement
;	------------------------------

TermFullScreen:	Mov	DX,[OriginalCursor]	; Set cursor to original
		Mov	AH,2			; And set it
		Int	10h			;   through BIOS

		Pop	ES			; Restore all registers
		Pop	DS
		Pop	DI
		Pop	DX
		Pop	CX
		Pop	BX
		Pop	AX

		Ret				; And return to New Int. 16h

;	Cursor Movement
;	---------------

Home:		Mov	DL,Byte Ptr [OriginalCursor]	; Move cursor to
		Ret				; to original column

Up:		Or	DH,DH			; Check if at top row
		Jz	UpEnd			; If so, do nothing
		Dec	DH			; If not, decrement row
UpEnd:		Ret

PgUp:		Sub	DL,DL			; Move cursor to far left 
		Ret

Left:		Or	DL,DL			; Check if cursor at far left
		Jnz	GoWest			; If not, move it left
		Mov	DL,[MaxCharCol]		; Move cursor to right
		Jmp	Up			; And go up one line
GoWest:		Dec	DL			; Otherwise, decrement column
		Ret

Right:		Cmp	DL,[MaxCharCol]		; Check if cursor at far right
		Jb	GoEast			; If not, move it right
		Sub	DL,DL			; Set cursor to left of screen
		Jmp	Down			; And go down one line
GoEast:		Inc	DL			; Otherwise, increment column
		Ret

End:		Call	TransferLine		; Move line to buffer
		Mov	DX,[OriginalCursor]	; Set cursor to original
		Ret

Down:		Inc	DH			; Move cursor down one row
		Ret

PgDn:		Mov	CL,[MaxCharCol]		; Get last column on screen
		Inc	CL			; Kick it up by one
		Sub	CL,DL			; Subtract current column
		Sub	CH,CH			; Set top byte to zero
		Mov	AL,' '			; Character to write
		Mov	AH,0Ah			; Write blanks to screen
		Int	10h			;   through BIOS
Dummy:		Ret

;	Insert and Delete
;	-----------------

Insert:		Xor	[InsertOn],-1		; Toggle the InsertOn flag
		Ret				;   and return	

Delete:		Call	ShiftLeft 		; Shift cursor line left
		Ret				;   and return

;	Transfer Line on Screen to Keyboard Buffer
;	------------------------------------------

TransferLine:	Sub	CX,CX			; Count characters in line
		Mov	DI,Offset KeyboardBuffer	; Place to store 'em
		Mov	[BufferPointer],DI	; Save that address
		Cld				; String direction forward

GetCharLoop:	Mov	AH,02h			; Set Cursor at DX
		Int	10h			;   through BIOS

		Mov	AH,08h			; Read Character & Attribute
		Int	10h			;   through BIOS

		Stosb				; Save the character

		Inc	CX			; Increment the counter
		Inc	DL			; Increment the cursor column
		Cmp	DL,[MaxCharCol]		; See if at end of line yet
		Jbe	GetCharLoop		; If not, continue

		Dec	DI			; Points to end of string
		Mov	AL,' '			; Character to search through
		Std				; Searching backwards
		Repz	Scasb			; Search for first non-blank
		Cld				; Forward direction again
		Jz	SetBufferCount		; If all blanks, skip down

		Inc	CL			; Number of non-blanks
		Inc	DI			; At last character
SetBufferCount:	Inc	DI			; After last character
		Mov	[BufferCounter],CL	; Save the character count

		Ret				; Return from routine

;	Shift Line One Space Right (For Insert)
;	---------------------------------------

ShiftRight:	Push	DX			; Save original cursor
		Mov	DI,AX			; Character to insert

ShiftRightLoop:	Call	ReadAndWrite		; Read character and write

		Inc	DL			; Kick up cursor column 
		Cmp	DL,[MaxCharCol]		; Check if it's rightmost
		Jbe	ShiftRightLoop		; If not, keep going

		Pop	DX			; Get back original cursor
		Ret				; And return from routine

;	Shift Line One Space Left (For Delete)
;	--------------------------------------

ShiftLeft:	Mov	DI,0020h		; Blank at end
		Mov	BL,DL			; Save cursor column
		Mov	DL,[MaxCharCol]		; Set cursor to end of line
		
ShiftLeftLoop:	Call	ReadAndWrite		; Read character and write

		Dec	DL			; Kick down cursor column
		Cmp	DL,BL			; See if at original yet
		Jge	ShiftLeftLoop		; If still higher, keep going 

		Inc	DL			; Put cursor back to original
		Ret				; And return from routine

;	Read and Write Character for Line Shifts
;	----------------------------------------

ReadAndWrite:	Mov	AH,2			; Set Cursor from DX
		Int	10h			;   through BIOS

		Mov	AH,08h			; Read Character and Attribute
		Int	10h			;   through BIOS

		Xchg	AX,DI			; Switch with previous char

		Mov	CX,1			; One character to write
		Mov	AH,0Ah			; Write character only
		Int	10h			;   through BIOS

		Ret				; Return from Routine

;	Initialization on Entry
;	-----------------------

Initialize:	Sub	AX,AX			; Make AX equal zero
		Mov	DS,AX			; To point to vector segment

		Les	BX,dword ptr DS:[21h * 4]; Get and save Int. 21h
		Mov	Word Ptr CS:[OldInterrupt21],BX
		Mov	Word Ptr CS:[OldInterrupt21 + 2],ES

		Les	BX,dword ptr DS:[16h * 4]; Get and save Int. 16h
		Mov	Word Ptr CS:[OldInterrupt16],BX
		Mov	Word Ptr CS:[OldInterrupt16 + 2],ES

		Push	CS			; Restore DS register
		Pop	DS			;   by setting to CS

		Mov	DX,Offset NewInterrupt21
		Mov	AX,2521h		; Set new Interrupt 21h
		Int	21h			;   through DOS

		Mov	DX,Offset NewInterrupt16
		Mov	AX,2516h		; Set new Interrupt 16h
		Int	21h			;   through DOS

		Mov	DX,Offset Initialize	; Number of bytes to stay
		Int	27h			; Terminate & remain resident

CSEG		EndS
		End	Entry
