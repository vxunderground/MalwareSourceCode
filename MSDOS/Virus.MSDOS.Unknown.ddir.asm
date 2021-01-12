;	DDIR.ASM -- Double Column Sorted DIR Command
;	========
;			(C) Copyright Charles Petzold, 1985
;
;			COM file format
;
	
CSEG		Segment

		Assume	CS:CSEG, DS:CSEG

		Org	002Ch			; Offset of Environment
Environment	Label	Byte

		Org	007Bh			; Parameter for COMMAND.COM
NewParameter	Label	Byte

		Org	0080h			; Parameter passed to program
OldParameter	Label	Byte	

		Org	0100h			; Entry point
Entry:		Jmp	Begin

;	All Data
;	--------

		db	'(C) Copyright Charles Petzold, 1985'

DosVersMsg	db	"Needs DOS 2.0 +$"	; Error messages
MemAllocMsg	db	"Memory Problem$"
CommandMsg	db	"COMMAND Problem$"

Comspec		db	"COMSPEC="		; Search string in environment
CommandAsciiz	dd	?			; Eventual pointer to COMMAND 

ParamBlock	dw	?			; Parameter Block for EXEC
		dw	NewParameter,?		; First ? must be replaced
		dw	5Ch,?			;    with Environment segment;
		dw	6Ch,?			;    others with this segment

OldInterrupt21	dd	?			; For vector address storage

BufferPtr	dw	Offset FileBuffer	; For storing files listing
CharCounter	dw	0			; Keeps track of characters
NowDoingFile	db	0			; Flagged for file printed
WithinFileList	db	0			; Flagged for file list
FileCounter	dw	0			; Keeps track of files
LineCounter	db	0			; For pausing at screen end

PauseMessage	db	6 dup (205)," Press any key to continue "
		db	6 dup (205),181 
PauseMsgEnd	Label	Byte

;	Check DOS Version
;	-----------------

Begin:		Mov	AH,30h			; DOS Version function call
		Int	21h			; Call DOS
		Cmp	AL,2			; Check if version 2 
		Jae	DosVersOK		; If equal or over, all OK

		Mov	DX,Offset DosVersMsg	; Wrong DOS version message
ErrorExit:	Mov	AH,9			; Set up for string write
		Int	21h			; Call DOS for message

		Int	20h			; Dishonorable discharge

;	Adjust stack and un-allocate rest of memory 
;	-------------------------------------------

DosVersOK:	Mov	DI,Offset FileBuffer	; Place to save files
		Mov	CX,528 * 39		; Allow room for 528 files
		Mov	AL,' '			; Will clear with blanks
		Cld				; Forward direction
		Rep	Stosb			; Clear the area

		Mov 	BX,(Offset FileBuffer) + (528 * 39) + 100h
					 	; New end of program
		Mov	SP,BX			; Set the stack pointer
		Add	BX,15			; Add 15 for rounding
		Mov	CL,4			; Number of shifts
		Shr	BX,CL			; Convert AX to segment

		Mov	AH,4Ah			; DOS call to shrink down
		Int	21h			;    allocated memory

		Mov	DX,Offset MemAllocMsg	; Possible error message
		Jc	ErrorExit		; Only print it if Carry set

;	Search for Comspec in Environment
;	---------------------------------

		Mov	ES,[Environment]	; Environment Segment
		Sub	DI,DI			; Start search at beginning
		Cld				; String increment to forward

TryThis:	Cmp	Byte Ptr ES:[DI],0	; See if end of environment
		Jz	NoFindComSpec		; If so, we have failed
		
		Push	DI			; Save environment pointer
		Mov	SI,Offset ComSpec	; String to search for
		Mov	CX,8			; Characters in search string
		Repz	Cmpsb			; Check if strings are same
		Pop	DI			; Get back the pointer

		Jz	FoundComspec		; Found string only zero flag

		Sub	AL,AL			; Zero out AL
		Mov	CX,8000h		; Set for big search
		Repnz	Scasb			; Find the next zero in string
		Jmp	TryThis			; And do the search from there

NoFindComSpec:	Mov	DX,Offset CommandMsg	; Message for COMSPEC error
		Jmp	ErrorExit		; Print it and exit

FoundComspec:	Add	DI,8			; So points after 'COMSPEC='
		Mov	Word Ptr [CommandASCIIZ],DI	; Save the address of
		Mov	Word Ptr [CommandASCIIZ + 2],ES	;    COMMAND ASCIIZ

; 	Set up parameter block for EXEC call
;	------------------------------------

		Mov	[ParamBlock],ES		; Segment of Environment string
		Mov	[ParamBlock + 4],CS	; Segment of this program
		Mov	[ParamBlock + 8],CS	;    so points to FCB's
		Mov	[ParamBlock + 12],CS	;    and NewParameter

;	Save and set Interrupt 21h vector address
;	----------------------------------------- 

		Mov	AX,3521h		; DOS call to get Interrupt 21
		Int	21h			;    vector address
		Mov	Word Ptr [OldInterrupt21],BX		; Save offset
		Mov	Word Ptr [OldInterrupt21 + 2],ES	; And segment	

		Mov	DX,Offset NewInterrupt21; Address of new Interrupt 21 
		Mov	AX,2521h		; Do DOS call to
		Int	21h			;    set the new address

;	Fix up new parameter for "/C DIR" String
;	------------------------------------

		Mov	AL,[OldParameter]	; Number of parameter chars 	
		Add	AL,5			; We'll be adding five more
		Mov	[NewParameter],AL	; Save it
		Mov	Word Ptr [NewParameter + 1],'C/'	; i.e. "/C"
		Mov	Word Ptr [NewParameter + 3],'ID'	; Then "DI"	
		Mov	Byte Ptr [NewParameter + 5],'R'		; And "R"

; 	Load COMMAND.COM
; 	-----------------
		
		Push	CS			; Push this segment so we can
		Pop	ES			;    set ES to it
		Mov	BX,Offset ParamBlock	; ES:BX = address of block
		Lds	DX,[CommandAsciiz]	; DS:DX = address of ASCIIZ
		Mov	AX,4B00h		; EXEC call 4Bh, type 0
		Int	21h			; Load command processor

; 	Return from COMMAND.COM
;	-----------------------

		Mov	AX,CS		; Get this segment in AX
		Mov	DS,AX		; Set DS to it
		Mov	SS,AX		; And SS for stack segment
		Mov	SP,(Offset FileBuffer) + (528 * 39) + 100h
					; Set Stack again

		PushF			; Save Carry for error check 
		Push	DS		; Save DS during next call

		Mov	DX,Word Ptr [OldInterrupt21]	; Old Int 21 offset
		Mov	DS,Word Ptr [OldInterrupt21 + 2]; and segment
		Mov	AX,2521h		; Call DOS to set vector
		Int	21h			;    address to original	

		Pop	DS			; Restore DS to this segment
		PopF				; Get back Carry flage

		Jnc	NormalEnd		; Continue if no error

		Mov	DX,Offset CommandMsg	; Otherwise we'll print error
		Jmp	ErrorExit		;    message and exit

NormalEnd:	Int	20h			; Terminate program

;	New Interrupt 21h
;	-----------------

NewInterrupt21	Proc	Far

		Sti				; Allow further interrupts
		Cmp	AH,40h			; Check if file / device write
		Je	CheckHandle		; If so, continue checks

SkipIntercept:	Jmp	CS:[OldInterrupt21]	; Just jump to old interrupt

CheckHandle:	Cmp	BX,1			; Check if standard output
		Jne	SkipIntercept		; Not interested if not

		PushF				; Push all registers that
		Push	AX			;    we'll be messing with
		Push	CX
		Push	SI
		Push	DI
		Push	ES

		Push	CS			; Push the code segment
		Pop	ES			; So we can set ES to it
		Cld				; Forward for string transfers
		Mov	SI,DX			; Now DS:SI = text source
		Mov	DI,CS:[BufferPtr]	; And ES:DI = text destination

		Cmp	CX,2			; See if two chars to write
		Jne	RegularChars		; If not, can't be CR/LF

		Cmp	Word Ptr DS:[SI],0A0Dh	; See if CR/LF being written
		Jne	RegularChars		; Skip rest if not CR/LF

		Mov	CX,CS:[CharCounter]	; Get characters in line
		Mov	CS:[CharCounter],0	; Start at new line
		Cmp	CS:[NowDoingFile],1	; See if CR/LF terminates file
		Jnz	AllowTransfer		; If not, just write to screen

		Mov	AX,39			; Max characters per line
		Sub	AX,CX			; Subtract those passed 
		Add	CS:[BufferPtr],AX	; Kick up pointer by that
		Mov	CS:[NowDoingFile],0	; Finished with file
		Jmp	PopAndReturn		; So just return to COMMAND

RegularChars:	Add	CS:[CharCounter],CX	; Kick up counter by number
		Cmp	CS:[CharCounter],CX	; See if beginning of line
		Jne	NotLineBegin		; If not, must be in middle

		Cmp	Byte Ptr DS:[SI],' '	; See if first char is blank
		Jne	ItsAFile		; If not, it's a file line

		Cmp	CS:[WithinFileList],1	; See if doing file listing
		Jne	AllowTransfer		; If not, just print stuff

		Call	SortAndList		; Files done -- sort and list
		Mov	CS:[WithinFileList],0	; Not doing files now
		Jmp	Short AllowTransfer	; So just print the stuff

ItsAFile:	Cmp	CS:[FileCounter],528	; See if 11 buffer filled up
		Jb	NotTooManyFiles		; If not just continue

		Push	CX			; Otherwise, save this register
		Call	SortAndList		; Print all up to now
		Mov	CS:[FileCounter],0	; Reset the counter
		Mov	DI,Offset FileBuffer	; And the pointer
		Mov	CS:[BufferPtr],DI	; Save the pointer
		Mov	CX,528 * 39		; Will clear for 528 files
		Mov	AL,' '			; With a blank
		Rep	Stosb			; Clear it out
		Pop	CX			; And get back register

NotTooManyFiles:Mov	CS:[WithinFileList],1	; We're doing files now
		Mov	CS:[NowDoingFile],1	; And a file in particular
		Inc	CS:[FileCounter]	; So kick up this counter

NotLineBegin:	Cmp	CS:[NowDoingFile],1	; See if doing files
		Je	StoreCharacters		; If so, store the stuff

AllowTransfer:	Pop	ES			; Pop all the registers
		Pop	DI
		Pop	SI
		Pop	CX
		Pop	AX
		PopF

		Jmp	SkipIntercept		; And go to DOS for print

StoreCharacters:Mov	DI,CS:[BufferPtr]	; Set destination
		Rep	Movsb			; Move characters to buffer
		Mov	CS:[BufferPtr],DI	; And save new pointer	

PopAndReturn:	Pop	ES			; Pop all the registers
		Pop	DI
		Pop	SI
		Pop	CX
		Pop	AX
		PopF

		Mov	AX,CX			; Set for COMMAND.COM
		Clc				; No error here 
		Ret	2			; Return with CY flag cleared

NewInterrupt21	EndP

;	Sort Files
;	----------

SortAndList:	Push	BX			; Push a bunch of registers
		Push	DX
		Push	SI
		Push	DS

		Push	CS			; Push CS
		Pop	DS			;    so we can set DS to it
		Assume	DS:CSEG			; And inform the assembler

		Mov	DI,Offset FileBuffer	; This is the beginning
		Mov	CX,[FileCounter]	; Number of files to sort
		Dec	CX			; Loop needs one less than that 
		Jcxz	AllSorted		; But zero means only one file

SortLoop1:	Push	CX			; Save the file counter
		Mov	SI,DI			; Set source to destination

SortLoop2:	Add	SI,39			; Set source to next file

		Push	CX			; Save the counter,
		Push	SI			;    compare source,
		Push	DI			;    and compare destination

		Mov	CX,39			; 39 characters to compare
		Repz	Cmpsb			; Do the compare
		Jae	NoSwitch		; Jump if already in order

		Pop	DI			; Get back these registers
		Pop	SI

		Push	SI			; And push them again for move
		Push	DI

		Mov	CX,39			; 39 characters
SwitchLoop:	Mov	AL,ES:[DI]		; Character from destination 
		Movsb				; Source to destination
		Mov	DS:[SI - 1],AL		; Character to source
		Loop	SwitchLoop		; For the rest of the line

NoSwitch:	Pop	DI			; Get back the registers
		Pop	SI
		Pop	CX
		Loop	SortLoop2		; And loop for next file

		Pop	CX			; Get back file counter 
		Add	DI,39			; Compare with next file
		Loop	SortLoop1		; And loop again

;	Now Display Sorted Files
;	------------------------

AllSorted:	Mov	SI,Offset FileBuffer	; This is the beginning
		Mov	CX,[FileCounter]	; Number of files to list
		Inc	CX			; In case CX is odd
		Shr	CX,1			; CX now is number of lines

SetIncrement:	Mov	BX,24 * 39		; Increment for double list
		Cmp	CX,24			; But use it only if a full
		Jae	LineLoop		;    screen is printed	

		Mov	AX,39			; Otherwise find increment
		Mul	CX			;    by multiplying CX by 39
		Mov	BX,AX			; And make that the increment

LineLoop:	Call	PrintFile		; Print the first column file
		Mov	AL,' '			; Skip one space
		Call	PrintChar		;    by printing blank
		Mov	AL,179			; Put a line down the middle
		Call	PrintChar
		Mov	AL,' '			; Skip another space
		Call	PrintChar

		Add	SI,BX			; Bump up source by increment
		Sub	SI,39 			; But kick down by 39

		Call	PrintFile		; Print the second column file
		Call	CRLF			; And terminate line

		Sub	SI,BX			; Bring pointer back down

		Inc	[LineCounter]		; One more line completed
		Cmp	[LineCounter],24	; Have we done whole screen?
		Jz	PauseAtEnd		; If so, gotta pause now

		Loop	LineLoop		; Otherwise just loop
		Jmp	Short AllFinished	; And jump out when done

PauseAtEnd:	Mov	[LineCounter],0		; Reset the counter
		Add	SI,BX			; Go to next file

		Push	BX			; Save these registers
		Push	CX
		Mov	DX,Offset PauseMessage	; Test to print
		Mov	CX,Offset PauseMsgEnd - Offset PauseMessage
						; Number of characters
		Mov	BX,2			; Standard ERROR Output
		Mov	AH,40h			; Display to screen
		Int	21h			; By calling DOS 
		Pop	CX			; Retrieve pushed registers 
		Pop	BX

		Mov	AH,8			; Wait for character
		Int	21h			; Through DOS call

		Call	CRLF			; Go to next line 

		Loop	SetIncrement		; And recalculate increment

AllFinished:	Pop	DS			; Done with subroutine
		Pop	SI
		Pop	DX
		Pop	BX
		Ret				; So return to caller

;	Display Routines
;	----------------

PrintChar:	Mov	DL,AL			; Print character in AL
		Mov	AH,2			; By simple DOS call
		Int	21h
		Ret				; And return

CRLF:		Mov	AL,13			; Print a carriage return
		Call	PrintChar
		Mov	AL,10			; And a line feed
		Call	PrintChar
		Ret				; And return

PrintString:	Lodsb				; Get character from SI
		Call	PrintChar		; Print it
		Loop	PrintString		; Do that CX times
		Ret				; And return

PrintFile:	Push	CX			; Save the counter
		Mov	CX,32			; Bytes for Name, Size, & Date
		Call	PrintString		; Print it	
		Inc	SI			; Skip one space before time
		Mov	CX,6			; Bytes for Time
		Call	PrintString		; It's a print!
		Pop	CX		
		Ret				; And return

FileBuffer	Label	Byte			; Points to end of code

CSEG		EndS				; End of segment

		End	Entry			; Denotes entry point
