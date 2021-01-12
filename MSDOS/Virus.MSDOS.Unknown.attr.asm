;	ATTR.ASM -- File Attribute Utility
;	==================================

CSEG		Segment
		Assume	CS:CSEG, DS:CSEG, ES:CSEG, SS:CSEG
		Org	0080h
Parameter	Label	Byte		; Parameter is here
		Org	0100h
Entry:		Jmp	Begin		; Entry Point

;	Most Data (some more at end of program)
;	---------------------------------------

		db	"ATTR (C) 1986, Ziff-Davis Publishing Co.",1Ah
		db	" Programmed by Charles Petzold ",1Ah
SyntaxMsg	db	"Syntax: ATTR [+A|-A] [+S|-S] [+H|-H] [+R|-R] "
		db	"[drive:][path]filename",13,10
		db	"             Archive System  Hidden  Read-Only$"   
DosVersMsg	db	"ATTR: Needs DOS 2.0 +$"
FlagErrMsg	db	"ATTR: Incorrect flag$"
FileSpecMsg	db	"ATTR: Incorrect File Spec$"
Delimiters	db	9,' ,;=',13
FlagList	db	"ASHR", 20h, 04h, 02h, 01h
AllFlagList	db	"    $Arc $Dir $$$$$$Sys $Hid $R-O$"
ChangeFlag	db	0
AndAttrBits	db	0
OrAttrBits	db	0
SearchString	dw	?
AppendFileName	dw	?

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

;	Parse Command Line to get file specification
;	--------------------------------------------

DosVersOK:	Mov	SI, 1+Offset Parameter	; Parameter string pointer
		Cld				; Directions forward

FlagSearch:	Lodsb				; Get Byte
		Mov	DI, Offset Delimiters	; Check if delimiter
		Mov	CX, 5			; Five delimiters to check
		Repne	Scasb			; Scan the string
		Je	FlagSearch		; If delimiter, circle back
		Mov	DX, Offset SyntaxMsg	; Possible error msg 
		Cmp	AL, 13			; If carriage return, no file
		Je	ErrorExit		;   so exit with message
				
		Mov	DI, Offset OrAttrBits	; Pointer to plus flag saver
		Cmp	AL, '+'			; See if plus sign
		Je	PlusOrMinus		; If so, save the bit
		Mov	DI, Offset AndAttrBits	; Pointer to minus flag saver
		Cmp	AL, '-'			; See if minus sign
		Jne	MustBeFile		; If not, it must be file name

PlusOrMinus:	Mov	[ChangeFlag],-1		; Set for changing
		Lodsb				; Get the next byte
		And	AL, 0DFh		; Capitalize it
		Mov	BX, Offset FlagList	; List for scanning
		Mov	CX, 4			; Scan for A, S, H, and R

SearchList:	Cmp	AL, [BX]		; See if a match
		Jz	FoundFlag		; If so, proceed to save	
		Inc	BX			; Kick up pointer 
		Loop	SearchList		; And loop around for next
		Mov	DX, Offset FlagErrMsg	; Otherwise, set message 
		Jmp	ErrorExit		; And terminate

FoundFlag:	Mov	AL, [BX + 4]		; Get bit mask
		Or	[DI], AL		; Turn saved bit on
		Jmp	FlagSearch		; And continue looking

MustBeFile:	Not	[AndAttrBits]		; Invert bits for turn off
		Mov	[SearchString], SI	; Save file name pointer
		Dec	[SearchString]		; Actually one byte lower

EndSearch:	Lodsb				; Get Byte
		Mov	DI, Offset Delimiters	; Check if delimiter
		Mov	CX, 6			; Six delimiters including CR
		Repne	Scasb			; Scan the string
		Jne	EndSearch		; If not delimiter, keep going

;	Transfer Search String down at end of program
;	---------------------------------------------

		Dec	SI			; Points after file spec
		Mov	Byte Ptr [SI], 0	; Make it ASCIIZ string
		Mov	CX, SI			; CX points to end
		Mov	SI, [SearchString]	; SI points to beginning
		Sub	CX, SI			; Now CX is length of it
		Mov	DI, Offset PathAndFile	; Destination of string
		Mov	[AppendFileName], DI	; Save it here also

SearchTrans:	Lodsb				; Get byte of search string
		Stosb				; And save it down below
		Cmp	AL, ':'			; See if drive marker
		Je	PossibleEnd		; If so, take note of it
		Cmp	AL, '\'			; See if path separator
		Jne	NextCharacter  		; If not, skip next code

PossibleEnd:	Mov	[AppendFileName], DI	; This is the new end
NextCharacter:	Loop	SearchTrans		; Do it again until done

;	Find Files from Search String
;	-----------------------------

		Mov	DX, Offset DTABuffer	; Set File Find buffer
		Mov	AH, 1Ah			;   by calling DOS
		Int	21h

		Mov	DX, [SearchString]	; Search string
		Mov	CX, 16h			; Search Everything
		Mov	AH, 4Eh			; Find first file 

FindFile:	Int	21h			; Call DOS to find file
		Jnc	Continue		; If no error continue
		Cmp	AX, 18			; If not "no more files" error
		Jnz	FindError		;   print error message
		Jmp	NoMoreFiles		; Now get out of the loop

FindError:	Mov	DX, Offset FileSpecMsg	; Error message for file spec
		Jmp	ErrorExit		; Exit and print message

Continue:	Mov	SI, 30+Offset DTABuffer	; Points to filename
		Cmp	Byte Ptr [SI], '.'	; See if "dot" entry
		Jnz	FileIsOK		; If not, continue
		Jmp	FindNextFile		; If so, skip it

FileIsOK:	Mov	DI, [AppendFileName]	; Destination of file name
		Mov	CX, 14			; Number of bytes to display

TransferName:	Lodsb				; Get the byte in file name
		Stosb				; Save it
		Or	AL, AL			; See if terminating zero
		Jz	PadWithBlanks		; If so, display blanks
		Call	DisplayChar		; Display the character
		Loop	TransferName		; And loop back around

PadWithBlanks:	Mov	AL, ' '			; Pad names with blanks
		Call	DisplayChar
		Loop	PadWithBlanks		; And loop until CX is zero

;	Change And Display File Attributes
;	---------------------------------- 

		Mov	DX, Offset PathAndFile	; Points to ASCIIZ string
		Test	[ChangeFlag], -1	; See if changing attributes
		Jz	DisplayIt		; If not, just display them 

		Mov	AX, 4300h		; Get file attribute
		Int	21h			;   by calling DOS
		And	CL, 27h			; Zero out some bits
		And	CL, [AndAttrBits]	; Turn off some bits
		Or	CL, [OrAttrBits]	; Turn on some bits
		Mov	AX, 4301h		; Set file attribute
		Int	21h			;   by calling DOS

DisplayIt:	Mov	AX, 4300h		; Get file attribute
		Int	21h			;   by calling DOS
		Mov	BL, CL			; BL is attributes
		Or	BL, 08h			; Turn on Volume bit
		Shl	BL, 1			; Shift to get rid of
		Shl	BL, 1			;   unused bits
		Mov	CX, 6			; Number of bits left
		Mov	DX, 5+Offset AllFlagList; Storage of abbreviations
		
AttrListLoop:	Push	DX			; Save abbreviation pointer
		Shl	BL, 1			; Shift bit into carry
		Jc	FlagIsOn		; See if it's on
		Mov	DX, Offset AllFlagList	; If not, print blanks

FlagIsOn:	Mov	AH, 9			; Print string
		Int	21h			;   by calling DOS
		Pop	DX			; Get back abbreviation ptr
		Add	DX, 5			; Kick up for next bit
		Loop	AttrListLoop		; And loop around
		Mov	AL, 13			; Print carriage return
		Call	DisplayChar
		Mov	AL, 10			; Print line feed
		Call	DisplayChar

FindNextFile:	Mov	AH, 4Fh			; Find next file
		Jmp	FindFile		; By looping around

NoMoreFiles:	Int	20h			; Terminate

;	SUBROUTINE: Display Character in AL
;	-----------------------------------

DisplayChar:	Push	AX
		Push	DX
		Mov	DL, AL			; Move character to DL
		Mov	AH, 2			; Display it
		Int	21h			;   by calling DOS
		Pop	DX
		Pop	AX
		Ret

;	Some data stored at end to cut down COM size
;	--------------------------------------------

DTABuffer	Label	Byte			; For file find calls
PathAndFile	equ	DTABuffer + 43		; For file path and name 
CSEG		EndS				; End of the segment
		End	Entry			; Denotes entry point
