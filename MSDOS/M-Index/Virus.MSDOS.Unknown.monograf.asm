;	MONOGRAF.DRV -- Lotus Driver for Graphics on Monochrome Display
;	============
;
;		(For use with Lotus 1-2-3 Version 1A)
;
;	(C) Copyright Charles Petzold, 1985

CSEG		Segment
		Assume	CS:CSEG

		Org	0
Beginning	dw	Offset EndDriver,1,1,Offset Initialize

		Org	18h
		db	"Monochrome Graphics (C) Charles Petzold, 1985",0

		Org	40h
		dw	40 * 8 - 1		; Maximum Dot Column
		dw	25 * 8 - 1		; Maximum Dot Row
		dw	10, 7, 6, 10, 7, 6, 256
		db	-1			; For one monitor

		Org	53h
		Jmp	Near Ptr ClearScreen	; Call 0 -- Clear Screen
		Jmp	Near Ptr ColorSet	; Call 1 -- Set Color
		Jmp	Near Ptr SetAddress	; Call 2 -- Set Row/Col Addr
		Jmp	Near Ptr DrawLine	; Call 3 -- Draw a Line
		Jmp	Near Ptr Initialize	; Call 4 -- Write Dot (nothing)
		Jmp	Near Ptr WriteChar	; Call 5 -- Write a Character
		Jmp	Near Ptr DrawBlock	; Call 6 -- Draw a Block
		Jmp	Near Ptr Initialize	; Call 7 -- Read Dot (nothing)
		Jmp	Near Ptr Initialize	; Call 8 -- Video Reset

;	Initialization Routine
;	----------------------

Initialize	Proc	Far
		Mov	AX,0		; This is standard
		Or	AX,AX		;   for all drivers 
		Ret
Initialize	EndP

;	Common Data Used in Routines
;	-----------------------------------

CharacterRow	dw	?				; from 0 to 24
CharacterCol	dw	?				; from 0 to 79
ScreenAddress	dw	?,0B000h			; Offset & Segment
CurrentColor	db	?,7				; For Screen Output
Colors		db	219,219,178,177,176,219,178	; Actually blocks

;	Row and Column Conversion of AX from graphics to character
;	----------------------------------------------------------

Rounder		dw	0			; Value to add before division
Divisor		db	?			; Value to divide by
MaxDots		dw	?			; Number of dots

RowConvertRnd:	Mov	[Rounder],4		; Row rounding -- add 4
RowConvert:	Mov	[Divisor],8		; Row normal -- divide by 8
		Mov	[MaxDots],200		; 25 lines times 8 dots
		Jmp	Short Convert		; And do generalized conversion

ColConvertRnd:	Mov	[Rounder],2		; Column rounding -- add 2
ColConvert:	Mov	[Divisor],4		; Will divide by 4
		Mov	[MaxDots],320		; 40 columns times 4 dots

Convert:	Cmp	AX,[MaxDots]		; See if graphics value OK
		Jb	OKToConvert		; It is if under maximum
		Jl	Negative		; But could be negative
		Sub	AX,[MaxDots]		; Otherwise wrap down
		Jmp	Convert			; And check again
Negative:	Add	AX,[MaxDots]		; Negatives wrap up
		Jmp	Convert			; And check again

OkToConvert:	Add	AX,[Rounder]		; Add rounding value
		Div	[Divisor]		; Divide	
		Cbw				; And convert to word
		Mov	[Rounder],0		; For next time through
		Ret

;	Calc Offset -- DX, CX character positions in
;	-----------

CalcOffset:	Push	AX
		Push	DX

		Mov	AX,80			; Columns Per Line
		Mul	DX			; AX now at beginning of row
		Add	AX,CX			; Add column value
		Add	AX,AX			; Double for attributes
		Mov	[ScreenAddress],AX	; Save as the current address

		Pop	DX
		Pop	AX

		Ret

;	Address Convert -- DX, CX row and column converted to character
;	---------------

AddrConvert:	Push	AX

		Mov	AX,DX			; This is graphics row
		Call	RowConvert		; Convert to character row
		Mov	DX,AX			; Save back in DX
		Mov	[CharacterRow],AX	; And save value in memory

		Mov	AX,CX			; This is graphics column
		Call	ColConvert		; Convert to character column
		Mov	CX,AX			; Back in CX
		Mov	[CharacterCol],AX	; And value also saved

		Call	CalcOffset		; Find the screen destination

		Pop	AX

		Ret

;	Call 0 -- Clear Screen -- AL = 0 for B&W
;	======================        -1 for Color

ClearScreen	Proc	Far
		Mov	AX,0B000h	; Monochrome Segment 
		Mov	ES,AX		; Set EX to it 
		Sub	DI,DI		; Start at zero
		Mov	CX,25 * 80	; Number of characters
		Mov	AX,0720h	; Blanks only
		Cld			; Forward direction
		Rep	Stosw		; Do it
		Ret
ClearScreen	EndP

;	Call 1 -- Color Set -- AL = Color (0, 1-6)
;	-------------------

ColorSet	Proc	Far
		Mov	BX,Offset Colors	; Blocks for 7 colors 
		Xlat	Colors			; Translate the bytes
		Mov	[CurrentColor],AL	; And save it
		Ret
ColorSet	EndP

;	Call 2 -- Set Address -- DX = Graphics Row
;	---------------------	 CX = Graphics Columns

SetAddress	Proc	Far
		Call	AddrConvert		; One routine does it all
		Ret
SetAddress	EndP

;	Call 3 -- Draw Line -- DX = End Row
;	-------------------    CX = End Column

DrawLine	Proc	Far
		Les	DI,DWord Ptr [ScreenAddress]	; Beginning address
		Mov	AX,[CharacterCol]	; AX now beginning column
		Mov	BX,[CharacterRow]	; BX now beginning row

		Call	AddrConvert		; CX,DX now ending col, row

		Cmp	AX,CX			; See if cols are the same
		Je	VertLine		; If so, it's vertical line	

		Cmp	BX,DX			; See if rows are the same
		Jne	DrawLineEnd		; If not, don't draw anything

HorizLine:	Sub	CX,AX			; Find the number of bytes
		Mov	BX,2			; Increment for next byte
		Mov	AL,196			; The horizontal line
		Mov	AH,179			; The vertical line
		Jae	DrawTheLine		; If CX > AX, left to right
		Jmp	Short ReverseLine	; Otherwise right to left

VertLine:	Mov	CX,DX			; This is the ending column
		Sub	CX,BX			; Subtract beginning from it
		Mov	BX,80 * 2		; Increment for next line
		Mov	AL,179			; The vertical line
		Mov	AH,196			; The horizontal line
		Jae	DrawTheLine		; If CX > BX, up to down

ReverseLine:	Neg	BX			; Reverse Increment
		Neg	CX			; Make a positive value

DrawTheLine:	Inc	CX			; One more byte than calced 

DrawLineLoop:	Cmp	Byte Ptr ES:[DI],197	; See if criss-cross there
		Je	DrawLineCont		; If so, branch around

		Cmp	ES:[DI],AH		; See if opposite line
		Jne	NoOverLap		; If not, skip next code

		Mov	Byte Ptr ES:[DI],197	; Write out criss-cross
		Jmp	Short DrawLineCont	; And continue

NoOverLap:	Mov	ES:[DI],AL		; Display line chararacter

DrawLineCont:	Add	DI,BX			; Next destination
		Loop	DrawLineLoop		; For CX repetitions

DrawLineEnd:	Ret
DrawLine	EndP

;	Call 5 -- Write Character -- DX, CX = row, col; BX = count,
;	-------------------------	AH = direction, AL = type

Direction	db	?

WriteChar	Proc	Far

		Push	BX			; Save count
		Add	BX,BX			; Initialize adjustment
		Mov	[Direction],AH		; Save direction

		Or	AL,AL			; Branch according to type
		Jz	WriteType0
		Dec	AL
		Jz	WriteType1
		Dec	AL
		Jz	WriteType2
		Dec	AL
		Jz	WriteType3

WriteType4:	Mov	AX,4			; Adjustment to row
		Jmp	Short WriteCharCont

WriteType3:	Add	BX,BX			; Center on column
WriteType2:	Sub	AX,AX			; No adjustment to row
		Jmp	Short WriteCharCont

WriteType1:	Sub	BX,BX			; No adjustment on column
WriteType0:	Mov	AX,2			; Adjustment to row

WriteCharCont:	Cmp	[Direction],0		; Check the direction
		Jz	HorizChars

		Sub	DX,BX			; Vertical -- adjust row
		Sub	DX,BX
		Sub	CX,AX			; Adjust column
		Mov	AX,80 * 2 - 1		; Increment for writes 
		Jmp	Short DoWriteChar		

HorizChars:	Sub	DX,AX			; Horizontal -- adjust row
		Sub	DX,AX			
		Sub	CX,BX			; Adjust column
		Mov	AX,1			; Increment for writes

DoWriteChar:	Call	AddrConvert		; Convert the address
		Les	DI,DWord Ptr [ScreenAddress]	; Get video address
		Cld
		Pop	CX			; Get back character count
		Jcxz	WriteCharEnd		; Do nothing if no characters

CharacterLoop:	Movsb				; Write character to display
		Add	DI,AX			; Increment address
		Loop	CharacterLoop		; Do it CX times

WriteCharEnd:	Ret
WriteChar	EndP

;	Call 6 -- Draw Block -- BX,DX = Rows; AX,CX = Columns
;	--------------------

DrawBlock	Proc	Far
		Call	ColConvertRnd		; AX now first char col
		Xchg	AX,CX			; Switch with 2nd graph col
		Call	ColConvertRnd		; AX now 2nd char col
		Cmp	AX,CX			; Compare two char cols
		Je	DrawBlockEnd		; End routine if the same
		Ja	NowDoRow		; If CX lowest, just continue

		Xchg	AX,CX			; Otherwise switch them

NowDoRow:	Xchg	AX,BX			; AX now 1st graph row
		Call	RowConvertRnd		; AX now 1st char row
		Xchg	AX,DX			; AX now 2nd graph row
		Call	RowConvertRnd		; AX now 2nd char row
		Cmp	AX,DX			; Compare two character columns
		Je	DrawBlockEnd		; End routine if the same
		Ja	BlockRowLoop		; If DX lowest, just continue

		Xchg	AX,DX			; Otherwise switch them

BlockRowLoop:	Push	CX			; Beginning Column
		Push	BX			; Ending Column 

BlockColLoop:	Call	CalcOffset		; Calculate screen address
		Les	DI,DWord Ptr [ScreenAddress]	; And set ES:DI

		Push	Word Ptr [CurrentColor]	; Push the current color
		Pop	ES:[DI]			; And Pop it on the screen

		Inc	CX			; Next Column
		Cmp	CX,BX			; Are we an end?
		Jb	BlockColLoop		; Nope -- loop again

		Pop	BX			; Get back beginning col
		Pop	CX			; And the end

		Inc	DX			; Prepare for next row
		Cmp	DX,AX			; Are we at the end?
		Jb	BlockRowLoop		; If not, loop 

DrawBlockEnd:	Ret
DrawBlock	EndP

		Org	$ + 16 - (($ - Beginning) Mod 16)
EndDriver	Label	Byte

CSEG		EndS
		End
