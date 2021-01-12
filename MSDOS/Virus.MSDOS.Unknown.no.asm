;	NO.ASM -- Hides specified files from command that follows
;	======

CSEG		Segment
		Assume	CS:CSEG, DS:CSEG, ES:CSEG, SS:CSEG
		Org	002Ch
Environment	Label	Word		; Segment of Environment is here
		Org	0080h
Parameter	Label	Byte		; Parameter is here
		Org	0100h
Entry:		Jmp	Begin		; Entry Point

;	Most Data (some more at end of program)
;	---------------------------------------

		db	"Copyright 1986 Ziff-Davis Publishing Co.",1Ah
		db	" Programmed by Charles Petzold ",1Ah
SyntaxMsg	db	"Syntax: NO filespec command [parameters]$"
DosVersMsg	db	"NO: Needs DOS 2.0 +$"
FileSpecMsg	db	"NO: Incorrect File Spec$"
TooManyMsg	db	"NO: Too many files to hide$"
MemAllocMsg	db	"NO: Allocation Problem$"
CommandMsg	db	"NO: COMMAND Problem$"
Delimiters	db	9,' ,;='
FileList	dw	?		; Storage of found files
FileCount	dw	0		; Count of found files
FileListEnd	dw	?		; End of storage of found files
BreakState	db	?		; Store original break state here
Comspec		db	'COMSPEC='	; String for Environment search
ParamBlock	dw	?		; Parameter block for EXEC call
		dw	?, ?
		dw	5Ch, ?
		dw	6Ch, ?
StackPointer	dw	?		; Save SP during EXEC call

;	Check DOS Version
;	-----------------

Begin:		Mov	AH, 30h			; Check for DOS Version
		Int	21h			;   through DOS call
		Cmp	AL, 2			; See if it's 2.0 or above
		Jae	DosVersOK		; If so, continue

		Mov	DX, Offset DosVersMsg	; Error message
ErrorExit:	Mov	AH, 9			; Print String function call
		Int	21h			; Do it
		Int	20h			; And exit prematurely

;	Parse Command Line to get NO File specification
;	-----------------------------------------------

ScanParam:	Lodsb				; SUBROUTINE: Get byte
		Cmp	AL, 13			; See if end of parameter
		Je	ErrorExit		; If so, exit
		Mov	DI, Offset Delimiters	; Check if delimiter
		Mov	CX, 5			; There are 5 of them
		Repne	Scasb			; Scan the string
		Ret				; And return

DosVersOK:	Mov	DX, Offset SyntaxMsg	; Possible error msg 
		Mov	SI, 1+Offset Parameter	; NO Parameter string
		Cld				; Directions forward

BegSearch:	Call	ScanParam		; Check byte in subroutine
		Je	BegSearch		; If delimiter, keep searching
		Mov	BX, SI			; Save pointer in BX
		Dec	BX			; BX points to NO file spec

EndSearch:	Call	ScanParam		; Check byte in subroutine
		Jne	EndSearch		; If not delimiter, keep going

;	Construct full FilePath and save down at end of program
;	-------------------------------------------------------

		Dec	SI			; Points after NO file spec
		Xchg	SI, BX			; SI points to beg, BX to end
		Mov	DI, Offset FullPath	; Points to destination
		Cmp	Byte Ptr [SI + 1], ':'	; See if drive spec included
		Jnz	GetDrive		; If not, must get the drive
		Lodsw				; Otherwise, grab drive spec
		And	AL, 0DFh		; Capitalize drive letter
		Jmp	Short SaveDrive		; And skip next section

GetDrive:	Mov	AH, 19h			; Get current drive
		Int	21h			;   through DOS
		Add	AL, 'A'			; Convert to letter
		Mov	AH, ':'			; Colon after drive letter

SaveDrive:	Stosw				; Save drive spec and colon
		Mov	AL, '\'			; Directory divider byte
		Cmp	[SI], AL		; See if spec starts at root
		Jz	HaveFullPath		; If so, no need to get path
		Stosb				; Store that character
		Push	SI			; Save pointer to parameter
		Mov	SI, DI			; Destination of current path
		Mov	DL, [SI - 3]		; Drive letter specification
		Sub	DL, '@'			; Convert to number
		Mov	AH, 47h			; Get current directory
		Int	21h			;   through DOS
		Mov	DX, Offset FileSpecMsg	; Possible error message
		Jc	ErrorExit		; Exit if error
		Sub	AL, AL			; Search for terminating zero
		Cmp	[SI], AL		; Check if Root Directory
		Jz	RootDir			; If so, don't use it
		Mov	CX, 64			; Number of bytes to search
		Repnz	Scasb			; Do the search
		Dec	DI			; DI points to last zero
		Mov	AL, '\'			; Put a backslash in there
		Stosb				; So filespec can follow
RootDir:	Pop	SI			; Get back SI

HaveFullPath:	Mov	CX, BX			; End of NO file spec
		Sub	CX, SI			; Number of bytes to transfer
		Rep	Movsb			; Transfer them
		Sub	AL, AL			; Terminating zero
		Stosb				; Save it
		Mov	[FileList], DI		; Repository for found files

;	Fix up parameter and ParamBlock for eventual COMMAND load
;	---------------------------------------------------------

		Sub	BX, 4			; Points to new param begin
		Mov	AL, [Parameter]		; Old byte count of parameter
		Add	AL, 80h			; Add beginning of old param
		Sub	AL, BL			; Subtract beginning of new
		Mov	AH, ' '			; Space separator
		Mov	Word Ptr [BX], AX	; Store it
		Mov	Word Ptr [BX + 2], 'C/'	; Add /C to beginning of rest
		Mov	AX, [Environment]	; Get environment segment
		Mov	[ParamBlock], AX	; Save it	
		Mov	[ParamBlock + 2], BX	; Save parameter pointer
		Mov	[ParamBlock + 4], CS	; Save segment of ParamBlock
		Mov	[ParamBlock + 8], CS
		Mov	[ParamBlock + 10], CS

;	Find Files from NO File Specification
;	-------------------------------------

		Mov	DX, Offset DTABuffer	; Set File Find buffer
		Mov	AH, 1Ah			;   by calling DOS
		Int	21h

		Mov	DI, [FileList]		; Address of destination
		Mov	DX, Offset FullPath	; Search string
		Sub	CX, CX			; Search Normal files only
		Mov	AH, 4Eh			; Find first file 

FindFile:	Int	21h			; Call DOS to find file
		Jnc	Continue		; If no error continue
		Cmp	AX, 18			; If no more files
		Jz	NoMoreFiles		;   get out of the loop
		Mov	DX, Offset FileSpecMsg	; Error message otherwise
		Jmp	ErrorExit		; Exit and print message

Continue:	Mov	AX, DI			; Address of destination
		Add	AX, 512			; See if near top of segment
		Jc	TooManyFiles 		; If so, too many files
		Cmp	AX, SP			; See if getting too many 
		Jb	StillOK			; If not, continue

TooManyFiles:	Mov	DX, Offset TooManyMsg	; Otherwise error message
		Jmp	ErrorExit		; And terminate

StillOK:	Mov	SI, 30+Offset DTABuffer	; Points to filename
		Call	AsciizTransfer		; Transfer it to list
		Inc	[FileCount]		; Kick up counter 
		Mov	AH, 4Fh			; Find next file
		Jmp	FindFile		; By looping around

NoMoreFiles:	Mov	[FileListEnd], DI	; Points after last file
		Mov	DI, [FileList]		; Points to end of find string
		Mov	CX, 64			; Search up to 64 bytes
		Mov	AL, '\'			; For the backslash
		Std				; Search backwards
		Repnz	Scasb			; Do the search
		Mov	Byte Ptr [DI + 2], 0	; Stick zero in there
		Cld				; Fix up direction flag

;	Stop Ctrl-Break Exits and Hide the files
;	----------------------------------------

		Mov	AX,3300h		; Get Break State
		Int	21h			; By calling DOS
		Mov	[BreakState],DL		; Save it
		Sub	DL,DL			; Set it to OFF
		Mov	AX,3301h		; Set Break State
		Int	21h			; By calling DOS
		Mov	BL, 0FFh		; Value to AND attribute
		Mov	BH, 02h			; Value to OR attribute
		Call	ChangeFileMode		; Hide all the files

;	Un-allocate rest of memory 
;	--------------------------

		Mov	BX, [FileListEnd]	; Beyond this we don't need
		Add	BX, 512			; Allow 512 bytes for stack
		Mov	SP, BX			; Set new stack pointer
		Add	BX, 15			; Prepare for truncation
		Mov	CL,4			; Prepare for shift
		Shr	BX,CL			; Convert to segment form
		Mov	AH,4Ah			; Shrink allocated memory
		Int	21h			; By calling DOS
		Mov	DX,Offset MemAllocMsg	; Possible Error Message
		Jc	ErrorExit2		; Print it and terminate

;	Search for Comspec in Environment
;	---------------------------------

		Push	ES			; We'll be changing this
		Mov	ES, [Environment]	; Set ES to Environment
		Sub	DI, DI			; Start at the beginning
		Mov	SI, Offset ComSpec	; String to search for
		Mov	DX, Offset CommandMsg	; Possible error message

TryThis:	Cmp	Byte Ptr ES:[DI], 0	; See if points to zero
		Jz	ErrorExit2		; If so, we can't go on
		Push	SI			; Temporarily save these
		Push	DI
		Mov	CX, 8			; Search string has 8 chars
		Repz	Cmpsb			; Do the string compare
		Pop	DI			; Get back the registers
		Pop	SI
		Jz	LoadCommand		; If equals, we've found it
		Sub	AL, AL			; Otherwise search for zero
		Mov	CX, -1			; For 'infinite' bytes 
		Repnz	Scasb			; Do the search
		Jmp	TryThis			; And try the next string

; 	Load COMMAND.COM
; 	-----------------
		
LoadCommand:	Add	DI, 8			; so points after 'COMSPEC='
		Push	DS			; Switch DS and ES registers
		Push	ES
		Pop	DS
		Pop	ES
		Mov	[StackPointer],SP	; Save Stack Pointer
		Mov	DX, DI			; DS:DX = Asciiz of COMMAND
		Mov	BX, Offset ParamBlock	; ES:BX = parameter block
		Mov	AX, 4B00h		; EXEC function call
		Int	21h			; Load command processor

; 	Return from COMMAND.COM
;	-----------------------

		Mov	AX, CS			; Current code segment
		Mov	DS, AX			; Reset DS to this segment
		Mov	ES, AX			; Reset ES to this segment
		Mov	SS, AX			; Reset stack segment to it
		Mov	SP, [StackPointer]	; Reset SP
		Pushf				; Save error flag
		Sub	DL,DL			; Set Ctrl Break to OFF
		Mov	AX,3301h
		Int	21h			; By calling DOS
		Popf				; Get back error flag	
		Mov	DX,Offset CommandMsg	; Set up possible error msg
		Jnc	Terminate		; And print if EXEC error

;	Unhide the Files, restore Ctrl-Break state, and exit
;	----------------------------------------------------

ErrorExit2:	Mov	AH,9			; Will print the string
		Int	21h			; Print it
Terminate:	Mov	BL, 0FDh		; AND value for change
		Mov	BH, 00h			; OR value for change
		Call	ChangeFileMode		; Change file attributes
		Mov	DL,[BreakState]		; Original break-state
		Mov	AX,3301h		; Change the break-state
		Int	21h			;   by calling DOS
		Int	20h			; Terminate

;	SUBROUTINE: Change File Mode (All files, BL = AND, BH = OR)
;	-----------------------------------------------------------

ChangeFileMode:	Mov	CX, [FileCount]		; Number of files
		Jcxz	EndOfChange		; If no files, do nothing
		Mov	SI, [FileList]		; Beginning of list
		Mov	DX, [FileListEnd]	; End of List
ChangeLoop:	Push	SI			; Save pointer
		Mov	SI, Offset FullPath	; Preceeding path string
		Mov	DI, DX			; Destination of full name
		Call	AsciizTransfer		; Transfer it
		Dec	DI			; Back up to end zero
		Pop	SI			; Get back pointer to filename
		Call	AsciizTransfer		; Transfer it
		Push	CX			; Save the counter
		Mov	AX, 4300h		; Get attribute
		Int	21h			;   by calling DOS
		And	CL, BL			; AND with BL
		Or	CL, BH			; OR with BH
		Mov	AX, 4301h		; Now set attribute	
		Int	21h			;   by calling DOS
		Pop	CX			; Get back counter
		Loop	ChangeLoop		; And do it again if necessary
EndOfChange:	Ret				; End of subroutine

;	SUBROUTINE: Asciiz String Transfer (SI, DI in, returned incremented)
;	--------------------------------------------------------------------

AsciizTransfer:	Movsb				; Transfer Byte
		Cmp	Byte Ptr [DI - 1], 0	; See if it was end
		Jnz	AsciizTransfer		; If not, loop
		Ret				; Or leave subroutine

;	Variable length data stored at end
;	----------------------------------

DTABuffer	Label	Byte			; For file find calls
FullPath	equ	DTABuffer + 43		; For file path and names 
CSEG		EndS				; End of the segment
		End	Entry			; Denotes entry point
