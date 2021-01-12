;	BROWSE.ASM -- Full Screen File Pager
;	====================================

CSEG		Segment
		Assume	CS:CSEG, DS:CSEG, ES:CSEG, SS:CSEG
		Org	0080h
Parameter	Label	Byte
		Org	0100h
Entry:		Jmp Begin

;	All Data
;	--------

		db	'ATTR='
Attribute	db	0		; Current screen attribute
		db	'SHIFT='
ShiftHoriz	db	8		; Horizontal shift screen default
DosVersionFail	db	'Requires DOS 2.0 or above$'
NoSpaceFail	db	'Not enough memory$'
FileFail	db	'File Not Found$'
ScreenFail	db	'Unsupported video mode$'
Delimiters	db	9,' ,;=/'	; Delimiters in parameter
FileHandle	dw	?		; Use for saving file handle
WSMode		db	0FFh		; AND value for non-WordStar mode
LineLength	db	?		; Length of line (from BIOS)
NumberLines	db	25,0		; Number of lines (check EGA BIOS)
ScreenSize	dw	?		; Size of screen in bytes
CheckRetrace	db	1		; Flag zero if EGA or MONO used
Addr6845	dw	?		; Could use for retrace check	
ScreenAddr	Label	DWord		; Address of screen
ScreenOff	dw	0		; Higher for non-page 0
ScreenSeg	dw	0B800h		; Set to B000h for Mono Mode 7
ScreenStart	dw	?		; Points within buffer 
EndOfFile	dw	?		; Points within buffer
FileOffset	dw	-1, -1		; Address within file of buffer data
HorizOffset	dw	0		; Horizontal offset for display	
RightMargin	dw	0		; Right margin for offset display
Dispatch	dw	Home, Up, PgUp, Dummy, Left
		dw	Dummy, Right, Dummy, End, Down, PgDn

;	Check DOS Version for 2.0 or above
;	----------------------------------

Begin:		Cld			; All string directions forward
		Mov	AH,30h
		Int	21h		; Get DOS Version Number
		Cmp	AL,2		; Check for 2.0 or later
		Jae	DOSVerOK
		Mov	DX,Offset DOSVersionFail
ErrorExit:	Mov	AH,9		; Write error message
		Int	21h
		Int	20h

;	Parse Command Line to get File Name and WordStar flag
;	-----------------------------------------------------

DOSVerOK:	Mov	SI,1 + Offset Parameter	; Points to parameter
NameSearch:	Lodsb				; Get byte
		Cmp	AL,13			; Check if carriage return
		Jz	NoFileFound		; If so, no file name
		Mov	DI,Offset Delimiters	; String of delimiters
		Mov	CX,5			; Number of delimiters (no /)
		Repne	Scasb			; See if a match
		Je	NameSearch		; If a delimiter, keep looking
		Mov	DX,SI			; Otherwise found file name
		Dec	DX			; Points to beginning of it
EndSearch:	Lodsb				; Get next byte
		Cmp	AL,13			; See if carriage return
		Je	GotFileEnd		; If so, we're all done
		Mov	DI,Offset Delimiters	; String of delimiters
		Mov	CX,6			; Number (including /)
		Repne	Scasb			; See if a match
		Jne	EndSearch		; If not, still in file name
		Mov	Byte Ptr [SI - 1],0	; If so, mark end of file name
		Jcxz	GotFlag			; If slash, check for W
		Jmp	EndSearch		; Or continue flag search
GotFlag:	Lodsb				; Get byte after / flag
		Or	AL,20h			; Uncapitalize
		Cmp	AL,'w'			; See if w for WordStar mode
		Jnz	GotFileEnd		; If not, just ignore it
		Mov	[WSMode],7Fh		; AND value for WordStar

;	Open the File
;	-------------

GotFileEnd:	Mov	Byte Ptr [SI - 1],0	; Mark end of file name
						; DX still points to name
		Mov	AX,3D00h		; Open file for reading
		Int	21h			;   by calling DOS
		Jnc	GotTheFile		; If no error, continue	
NoFileFound:	Mov	DX,Offset FileFail	; Otherwise print a message 
		Jmp	ErrorExit
GotTheFile:	Mov	[FileHandle],AX		; Save the file handle

;	Get Screen Mode Information from BIOS Data Area
;	-----------------------------------------------

		Push	ES			; Save register
		Sub	AX,AX
		Mov	ES,AX			; Set ES to 0 (BIOS Data)
		Mov	AL,ES:[0449h]		; Current Video Mode
		Cmp	AL,3			; Check if Color Alpha
		Jbe	DisplayOK		; Continue if so
		Cmp	AL,7			; Check if monochrome display
		Je	Monochrome		; If so, branch
		Mov	DX,Offset ScreenFail	; We can't handle graphics
		Jmp	ErrorExit		; So print an error message
Monochrome:	Mov	[ScreenSeg],0B000h	; Use Monochrome Segment
		Mov	[CheckRetrace],0	; Don't have to check retrace
DisplayOK:	Mov	AL,ES:[044Ah]		; Number of Columns
		Mov	[LineLength],AL		; Save it
		Mov	AX,ES:[044Eh]		; Offset into screen buffer
		Mov	[ScreenOff],AX		; Save it		 
		Mov	AX,ES:[0463h]		; Address of 6845 Regsiter
		Mov	[Addr6845],AX		; Save it
		Push	ES
		Sub	DL,DL			; Set Rows to zero first
		Sub	BH,BH
		Mov	AX,1130h		; EGA BIOS: Get Information
		Int	10h
		Pop	ES
		Or	DL,DL			; Check if DL is still zero
		Jz	NoEGA			; If so, skip rest of stuff
		Inc	DL
		Mov	[NumberLines],DL	; Save Number of Lines
		Test	Byte Ptr ES:[0487h],4	; Check if must check retrace
		Jnz	NoEGA
		Mov	[CheckRetrace],0	; EGA says we don't have to
NoEGA:		Mov	BH,ES:[0462h]		; Get Current Page (use later)
		Pop	ES
		Mov	AL,[LineLength]		; Length of each line
		Mul	[NumberLines]		; Total chars on screen
		Add	AX,AX			; Double for attributes
		Mov	[ScreenSize],AX		; And Save it

;	See if enough memory is left
;	----------------------------

		Add	AX,Offset ScreenHold	; Add ScreenSize to code end
		Add	AX,256			; Add a little stack room
		Cmp	AX,SP			; Check against stack pointer
		Jbe	GotEnufMemory		; Continue if OK
		Mov	DX,Offset NoSpaceFail	; Otherwise end program
		Jmp	ErrorExit		;    with error messae
		
;	Get Current Screen Attribute
;	---------------------------- 

GotEnufMemory:	Cmp	[Attribute],0		; Check if attribute pre-set
		Jnz	GotAttribute		; If so, move on
		Mov	DL,' '			; Write out a byte
		Mov	AH,2			;   using DOS
		Int	21h
		Mov	AL,8			; Now backspace
		Mov	AH,14			;   using BIOS call
		Int	10h
		Mov	AH,8			; Read character & attribute
		Int	10h			;   using BIOS call (BH = pg)
		Mov	[Attribute],AH		; And save attribute

;	Save Current Screen
;	-------------------

GotAttribute:	Mov	DX,Offset Terminate	; Set Ctrl-Break exit
		Mov	AX,2523h		;   to terminate that way
		Int	21h
		Mov	DI,Offset ScreenHold	; Destination of screen
		Mov	CX,[ScreenSize]		; Size of screen
		Push	DS			; Save Source Segment
		Lds	SI,[ScreenAddr]		; Get screen address
		Rep	Movsb			; Move in the bytes
		Pop	DS			; Restore Source Segment

;	Get Keyboard Key and Decide on Action
;	-------------------------------------

		Call	Home			; Read file in
		Mov	[ScreenStart],SI	; Set buffer address
KeyLoop:	Call	UpDateScreen		; Write file to screen
GetKey:		Mov	AH,8			; Get key
		Int	21h			;   by calling DOS
		Cmp	AL,27			; Check if ESC
		Je	Terminate		; If so, terminate 
		Cmp	AL,0			; Check if extended
		Jnz	GetKey			; If not, try again
		Mov	AH,8			; Get extended code
		Int	21h			;   by calling DOS
		Sub	AL,71			; Subtract Home key value
		Jb	GetKey			; If below that, not valid
		Cmp	AL,(81 - 71)		; Check if above PgDn
		Ja	GetKey			; If so, ignore it
		Sub	AH,AH			; Zero out top byte
		Add	AX,AX			; Double for word access
		Mov	BX,AX			; Offset in dispatch table
		Mov	SI,[ScreenStart]	; Set current buffer pointer
		Call	[Dispatch + BX]		; Do the call
		Mov	[ScreenStart],SI	; Set new buffer pointer
		Jmp	KeyLoop			; And update the screen

;	Terminate -- Restore screen and close file
;	------------------------------------------

Terminate:	Mov	SI,Offset ScreenHold	; Address of Saved Screen
		Les	DI,[ScreenAddr]		; Address of Display
		Mov	CX,[ScreenSize]		; Number of characters
		Rep	Movsb			; Move them back 
		Mov	BX,[FileHandle]		; Get File Handle
		Mov	AH,3Eh			; Close File
		Int	21h
		Int	20h			; Terminate

;	Cursor Key Routines -- Home Key
;	-------------------------------

Home:		Sub	BX,BX			; For zeroing out values
		Mov	AX,[FileOffset]		; Check if read in file
		Or	AX,[FileOffset + 2]
		Mov	[FileOffset],BX		; Zero out file address
		Mov	[FileOffset + 2],BX
		Mov	[HorizOffset],BX	; Zero out horizontal offset	
		Mov	SI,Offset Buffer	; Reset buffer pointer	
		Jz	Dummy			; Skip file read if in already
		Mov	DX,Offset Buffer	; Area to read file in
		Mov	CX,32768		; Number of bytes to read
		Call	FileRead		; Read in file
Dummy:		Ret

;	Up and PgUp Keys
;	----------------

Up:		Call	GetPrevChar		; Get previous char in buffer
		Jc	UpDone			; If none available, finish
UpLoop:		Call	GetPrevChar		; Get previous char again
		Jc	UpDone			; if none, we're done
		Cmp	AL,10			; Check if line feed
		Jnz	UpLoop			; If not, try again 
		Call	GetNextChar		; Get char after line feed
UpDone:		Ret

PgUp:		Mov	CX,Word Ptr [NumberLines]	; Number of lines
PgUpLoop:	Call	Up			; Do UP that many times
		Loop	PgUpLoop
		Ret

;	Left and Right Keys
;	-------------------

Left:		Mov	[HorizOffset],0		; Reset Horizontal Offset
		Ret

Right:		Mov	AL,[ShiftHoriz]		; Get places to shift
		Sub	AH,AH
		Add	[HorizOffset],AX	; Move that many right
		Ret

;	End, Down, and PgDn Keys
;	------------------------

End:		Mov	BX,SI			; Save buffer pointer
		Call	PgDn			; Go page down
		Cmp	BX,SI			; Check if we did so
		Jnz	End			; If so, do it again
		Ret

Down:		Call	GetNextChar		; Get next character
		Jc	NoMoreDown		; If no more, we're done
DownLoop:	Call	GetNextChar		; Get one again
		Jc	UpLoop			; If no more, find prev LF
		Cmp	AL,10			; See if line feed
		Jnz	DownLoop		; If not, continue
NoMoreDown:	Ret

PgDn:		Mov	CX,Word Ptr [NumberLines]	; Number of lines
PgDnLoop:	Call	Down			; Do DOWN that many times
		Loop	PgDnLoop
		Ret

;	Update Screen
;	-------------

UpdateScreen:	Push	ES
		Mov	SI,[ScreenStart]	; Address of data in buffer
		Les	DI,[ScreenAddr]		; Address of display
		Mov	CX,ScreenSize		; Number of bytes in screen
		Shr	CX,1			; Half for number of chars
		Mov	AL,' '			; Will blank screen
		Mov	AH,[Attribute]		; With screen attribute
		Rep	Stosw			; Blank it
		Mov	AL,[LineLength]		; Length of display line
		Sub	AH,AH
		Add	AX,[HorizOffset]	; Add Horizontal Offset
		Mov	[RightMargin],AX	; That's right display margin
		Sub	DL,DL			; Line Number
LineLoop:	Sub	BX,BX			; Column Number
		Mov	AL,[LineLength]		; Use Line Length
		Mul	DL			;   and Line Number
		Add	AX,AX			;     to recalculate
		Mov	DI,AX			;       display destination
		Add	DI,[ScreenOff]		; Add beginning address	
CharLoop:	Call	GetNextChar		; Get next character
		Jc	EndOfScreen		; If no more, we're done
		And	AL,[WSMode]		; Will be 7Fh for WordStar
		Cmp	AL,13			; Check for carriage return
		Je	CharLoop		; Do nothing if so
		Cmp	AL,10			; Check for line feed
		Je	LineFeed		; Do routine if so
		Cmp	AL,9			; Check for tab
		Je	Tab			; Do routine if so
		Mov	CX,1			; Just 1 char to display
PrintChar:	Cmp	BX,[HorizOffset]	; See if we can print it
		Jb	NoPrint		
		Cmp	BX,[RightMargin]	; See if within margin
		Jae	NoPrint
		Mov	AH,[Attribute]		; Attribute for display
		Cmp	[CheckRetrace],0	; See if must stop snow
		Jz	WriteIt			; If not, skip retrace wait
		Push	BX
		Push	DX
		Mov	BX,AX			; Save character and attribute
		Mov	DX,[Addr6845]		; Set up I/O address
		Add	DX,6 
RetraceWait1:	In	AL,DX			; Check until
		Shr	AL,1			;   vertical retrace
		Jc	RetraceWait1		;     ends
		Cli				; Clear interrupts
RetraceWait2:	In	AL,DX			; Check until
		Shr	AL,1			;   vertical retrace
		Jnc	RetraceWait2		;     begins
		Mov	AX,BX			; Get back character & attr
		Stosw				; Write to display
		Sti				; Enable interrupts again
		Pop	DX
		Pop	BX
		Jmp	Short NoPrint		; Skip around "no snow" write
WriteIt:	Stosw				; Write without retrace wait
NoPrint:	Inc	BX			; Bump up line counter
		Loop	PrintChar		; Do it CX times
		Jmp	CharLoop		; Then go back to top
Tab:		Mov	AX,BX			; Current column number
		And	AX,07h			; Take lower three bits
		Mov	CX,8
		Sub	CX,AX			; Subtract from 8
		Mov	AL,' '			; Will print CX blanks
		Jmp	PrintChar
LineFeed:	Inc	DL			; Next line
		Cmp	DL,[NumberLines]	; See if down at bottom
		Jb	LineLoop		; If not, continue
EndOfScreen:	Pop	ES			; All done -- leave
		Ret

;	Get Next Character from buffer
;	------------------------------
;		(Input is SI pointing to buffer, Returns AL, CY if no more)

GetNextChar:	Cmp	SI,[EndOfFile]		; See if at end of file
		Jae	NoMoreNext		; If so, no more chars
		Cmp	SI,Offset BufferEnd	; See if at end of buffer
		Jb	CanGetNext		; If not, just get character
		Push	CX			; Otherwise save registers
		Push	DX
		Push	DI
		Push	ES
		Push	DS			; Set ES to DS
		Pop	ES			;   (could be different)
		Mov	SI,Offset BufferMid	; Move 2nd buffer half
		Mov	DI,Offset Buffer	;   to 1st buffer half	
		Mov	CX,16384	   
		Sub	[ScreenStart],CX	; New buffer pointer
		Rep	Movsb			; Move them
		Mov	SI,DI			; SI also buffer pointer
		Add	[FileOffset],32768 	; Adjust file addr to read
		Adc	[FileOffset + 2],0 
		Mov	DX,Offset BufferMid	; Place to read file
		Mov	CX,16384		; Number of bytes
		Call	FileRead		; Read the file
		Sub	[FileOffset],16384	; Now adjust so reflects
		Sbb	[FileOffset + 2],0	;   1st half of buffer
		Pop	ES			; Get back registers
		Pop	DI
		Pop	DX
		Pop	CX
		Jmp	GetNextChar		; And try again to get char
CanGetNext:	Lodsb				; Get the character
NoMoreNext:	Cmc				; So CY set if no more
		Ret				

;	Get Previous Character from buffer
;	----------------------------------

GetPrevChar:	Cmp	SI,Offset Buffer	; See if at top of buffer
		Ja	CanGetPrev		; If not, just get character
		Mov	AX,[FileOffset]		; See if at top of file
		Or	AX,[FileOffset + 2]
		Jz	AtTopAlready		; If so, can't get anymore
		Push	CX			; Save some registers
		Push	DX
		Mov	SI,Offset Buffer	; Move 1st half of buffer
		Mov	DI,Offset BufferMid	;   to 2nd half of buffer
		Mov	CX,16384
		Add	[ScreenStart],CX	; New buffer pointer
		Rep	Movsb			; Do the move
		Sub	[FileOffset],16384	; Adjust file addr for read
		Sbb	[FileOffset + 2],0
		Mov	DX,Offset Buffer	; Area to read file into
		Mov	CX,16384		; Number of bytes
		Call	FileRead		; Read the file
		Pop	DX			; Get back registers
		Pop	CX
		Jmp	Short CanGetPrev	; Now get character
AtTopAlready:	Stc				; CY flag set for no more
		Ret
CanGetPrev:	Dec	SI			; Move pointer back
		Mov	AL,[SI]			; Get the character
		Clc				; CY flag reset for success
		Ret

;	Read CX bytes from the file into DX buffer
;	------------------------------------------ 	

FileRead:	Push	AX			; Save some registers
		Push	BX
		Push	CX
		Push	DX
		Mov	[EndOfFile],-1		; Initialize this
		Mov	DX,[FileOffset]		; Get file address to read
		Mov	CX,[FileOffset + 2]
		Mov	BX,[FileHandle]		; Get file Handle
		Sub	AL,AL			; Do LSEEK from beginning
		Mov	AH,42h			; LSEEK call
		Int	21h
		Pop	DX			; Get back destination
		Pop	CX			; Get back count
		Mov	AH,3Fh			; Read file function call
		Int	21h
		Jnc	NoReadError		; If no error, continue
		Sub	AX,AX			; Otherwise read zero bytes
NoReadError:	Cmp	AX,CX			; See if 32K has been read
		Je	GotItAll		; If so, we're home free
		Add	AX,DX			; Otherwise add to buffer addr
		Mov	[EndOfFile],AX		; And save as end of file
GotItAll:	Pop	BX
		Pop	AX
		Ret

;	File Buffer and Screen Hold Areas
;	---------------------------------

Buffer		Label	Byte			; Area for file reads
BufferMid	equ	Buffer + 16384		; Halfway through it
BufferEnd	equ	BufferMid + 16384	; At end of it		
ScreenHold	equ	BufferEnd		; Area for holding screen
CSEG		EndS				; End of segment
		End	Entry			; Denotes entry point
