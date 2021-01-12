;	DISKSCAN.ASM -- Checks out disk by reading sectors
;	--------------------------------------------------

CSEG		Segment
		Assume	CS:CSEG, DS:CSEG, ES:CSEG, SS:CSEG
		Org	100h
Entry:		Jmp	Begin

;	All Data
;	--------
                db	' Copyright 1986 Ziff-Davis Publishing Co.'
		db	' Programmed by Charles Petzold '
DriveError	db	'Invalid Drive$'
DosVersErr	db	'Needs DOS 2.0+$'
MemoryError	db	'Needs 64K$'
ReadSegment	dw	?
DriveNum	db	?
DiskBlock	db	18 dup (?)
TotalSectors	dw	?
SectorsIn64K	dw	?
StartSector	dw	0
SectorLabel2	db	9,'Sector $' 
SectorLabel	db	13,'Sectors $'
DashLabel	db	' - $'
ErrorLabel	db	': Error!'
CRLF		db	13,10,'$'
ErrorAddr	dw	Err0,Err1,Err2,Err3,Err4,Err5,Err6,Err7
		dw	Err8,Err9,ErrA,ErrB,ErrC,ErrD,ErrD,ErrD  
Err0		db	'Write Protect$'
Err1		db	'Unknown Unit$'
Err2		db	'Drive Not Ready$'
Err3		db	'Unknown Command$'
Err4		db	'CRC Error$'
Err5		db	'Request Length$'
Err6		db	'Seek Error$'
Err7		db	'Unknown Media$'
Err8		db	'Sector Not Found$'
Err9		db	'No Paper$'
ErrA		db	'Write Fault$'
ErrB		db	'Read Fault$'
ErrC		db	'General Failure$'
ErrD		db	'Undocumented Error$'
BootSectMsg	db	'Boot Sector$'
RootDirMsg	db	'Root Directory$'
BadFatMsg	db	'File Alloc. Table$'
InUseMsg	db	'Used by file$'
NotInUseMsg	db	'Unallocated$'
BadFlagMsg	db	'Flagged as bad$'	
FatReadMsg	db	"Can't Read FAT$"
Divisors	dw	10000, 1000, 100, 10, 1	; For decimal conversion

;	Check Drive Parameter, DOS Version, and Enough Memory
;	-----------------------------------------------------

ErrorExit:	Mov	AH,9		; Write error message
		Int	21h		;      through DOS
		Int	20h		; And terminate

Begin:		Mov	DX, Offset DriveError	; Possible message
		Or	AL, AL		; Check Drive Validity Byte
		Jnz	ErrorExit	; If not zero, invalid drive
		Mov	DX, Offset DosVersErr	; Possible message
		Mov	AH, 30h
		Int	21h		; Get DOS Version Number
		Cmp	AL, 2		; Check for 2.0 or later
		Jb	ErrorExit	; If not, terminate with message 
		Mov	DX, Offset MemoryError	; Possible error message
		Mov	BX, 256+Offset EndProg	; Set beyond program 
		Mov	SP, BX		; Move stack closer to code
		Add	BX, 15		; Add 15 to round up
		Mov	CL, 4		; Divide BX by 16
		Shr	BX, CL
		Mov	AH, 4Ah		; Free allocated memory
		Int	21h		;   by calling DOS Set Block
		Jc	ErrorExit	; Terminate on error
		Mov	BX, 1000h	; Ask for 64K bytes
		Mov	AH, 48h		;   by using DOS
		Int	21h		;   Allocate Memory call
		Jc	ErrorExit	; Terminate on error
		Mov	[ReadSegment], AX	; Save segment of memory block

;	Get Disk Information From DOS
;	-----------------------------

		Mov	DL, DS:[005Ch]	; Get Drive Parameter
		Push	DS		; Save DS
		Mov	AH, 32h		; Call DOS to
		Int	21h		;   get DOS Disk Block (DS:BX)
		Mov	SI, BX		; Now DS:SI points to Disk Block
		Mov	DI, Offset DiskBlock	; DI points to destination
		Mov	CX, 18		; 18 bytes to copy'
		Cld			; Forward direction
		Rep	Movsb		; Move 'em in
		Pop	DS		; Get back DS
		Mov	BX, Offset DiskBlock	; BX to address Disk Block 
		Mov	DX, 1		; Set DX:AX to 65,536
		Sub	AX, AX
		Div	Word Ptr [BX + 2]	; Divide by Bytes Per Sector
		Mov	[SectorsIn64K], AX	; Save that values
		Mov	AX, [BX + 13]		; Last Cluster Number
		Dec	AX			; AX = Number of Clusters
		Mov	CL, [BX + 5]		; Cluster to Sector Shift
		Shl	AX, CL			; AX = Number Data Sectors
		Add	AX, [BX + 11]		; Add First Data Sector
		Mov	[TotalSectors], AX	; AX = Number Total Sectors
		Mov	AL, DS:[005Ch]	; Drive Number (0=def, 1=A)
		Dec	AL		; Make it 0=A, 1=B
		Jns	GotDriveNumber	; If no sign, not default drive
		Mov	AH, 19h		; Get current disk 
		Int	21h		;   by calling DOS

GotDriveNumber:	Mov	[DriveNum], AL	; Save Drive Number (0=A, 1=B)

;	Start Reading
;	-------------	

MainLoop:	Mov	DX, Offset SectorLabel	; String to display on screen
		Call	StringWrite		; Display it
		Mov	AX, [StartSector]	; Starting sector number
		Call	WordWrite		; Display number on screen
		Mov	DX, Offset DashLabel	; String containing a dash
		Call	StringWrite		; Display it on the screen
		Mov	CX, [SectorsIn64K]	; Number of sectors to read
		Add	AX, CX			; Add it to starting sector
		Jc	NumRecalc
		Cmp	AX, [TotalSectors]	; See if bigger than total
		Jbe	NumSectorsOK		; If so, proceed

NumRecalc:	Mov	AX, [TotalSectors]	; Otherwise get total sectors
		Mov	CX, AX			; Move it to CX also
		Sub	CX, [StartSector]	; Now CX = sectors to read

NumSectorsOK:	Dec	AX			; AX = last sector to read
		Call	WordWrite		; Display it on screen
		Call	ReadSectors		; Read the sectors
		Jnc	NextSectors		; If no error, skip detail
		Call	ReadSectors		; Repeat read
		Jnc	NextSectors		; If still no error, skip

DiskError:	Mov	DX, Offset ErrorLabel	; String saying "Error!"
		Call	StringWrite		; Display it on screen

ErrorLoop:	Push	CX			; Now save previous number
		Mov	CX, 1			; So we can read one at a time
		Call	ReadSectors		; Read one sector
		Jnc	NoError			; If no error, proceed
		Mov	BL, AL			; Save error code
		Mov	DX, Offset SectorLabel2	; String with "Sector "
		Call	StringWrite		; Display it on screen
		Mov	AX, [StartSector]	; The sector we just read
		Call	WordWrite		; Display it on screen
		Mov	DX, Offset DashLabel	; String with a dash
		Call	StringWrite		; Display it on screen
		And	BL, 0Fh			; Blank out error top bits
		Sub	BH, BH			; Now BX is error code
		Add	BX, BX			; Double it for word access
		Mov	DX, [ErrorAddr + BX]	; Get address of message
		Call	StringWrite		; Display message on screen
		Call	FindSector		; See where sector is 
		Mov	DX, Offset CRLF		; String for new line 
		Call	StringWrite		; Do carriage ret & line feed 

NoError:	Inc	[StartSector]		; Kick up the start sector
		Pop	CX			; Get back counter
		Loop	ErrorLoop		; And read next sector
		Mov	AX, [StartSector]	; Sector of next group
		Jmp	Short CheckFinish	; Check if at end yet

NextSectors:	Mov	AX, [StartSector]	; For no error, increment 
		Add	AX, [SectorsIn64K]	;   StartSector for next group
		Jc	Terminate		; (If overflow, terminate)
		Mov	[StartSector], AX	; And save it

CheckFinish:	Cmp	AX, [TotalSectors]	; See if at then end
		Jae	Terminate		; If so, just terminate
		Jmp	MainLoop		; If not, do it again

Terminate:	Int	20h			; Terminate

;	Find Sector in FAT to see if used by file, etc.
;	-----------------------------------------------

FindSector:	Mov	DX, Offset DashLabel		; Print dash
		Call	StringWrite
		Mov	AX, [StartSector]		; Sector with error
		Mov	DX, Offset BootSectMsg		; Set up message
		Cmp	AX, Word Ptr [DiskBlock + 6]	; See if sector boot
		Jb	PrintMsg			; If so, print as such
		Mov	DX, Offset BadFatMsg		; Set up message
		Cmp	AX, Word Ptr [DiskBlock + 16]	; See if sector in FAT
 		Jb	PrintMsg			; If so, print as such
		Mov	DX, Offset RootDirMsg		; Set up message
		Cmp	AX, Word Ptr [DiskBlock + 11]	; See if sector in dir
		Jb	PrintMsg			; If so, print as such
		Push	[StartSector]			; Save the sector
		Mov	AX, Word Ptr [DiskBlock + 6]	; Reserved sectors
		Mov	[StartSector], AX		; Start of first FAT
		Mov	CL, [DiskBlock + 15]		; Sectors for FAT
		Sub	CH, CH				; Zero out top byte		
		Call	ReadSectors			; Read in FAT
		Pop	[StartSector]			; Get back bad sector
		Mov	DX, Offset FatReadMsg		; Set up possible msg
		Jc	PrintMsg			; If read error, print
		Mov	AX, [StartSector]		; Get bad sector
		Sub	AX, Word Ptr [DiskBlock + 11]	; Subtract data start
		Mov	CL, [DiskBlock + 5]		; Sector Shift
		Shr	AX, CL				; Shift the sector
		Add	AX, 2				; AX is now cluster
		Push	ES			; Save ES for awhile				
		Mov	ES, [ReadSegment]	; ES segment of FAT
		Cmp	Word Ptr [DiskBlock + 13], 0FF0h; 12 or 16-bit FAT?
		Jge	Fat16Bit		; And jump accordingly
		Mov	BX, AX			; This is cluster number
		Mov	SI, AX			; So is this
		Shr	BX, 1			; This is one-half cluster
		Mov	AX, ES:[BX + SI]	; BX + SI = 1.5 CX
		Jnc	NoShift			; If no CY from shift, got it
		Mov	CL, 4			; If CY from shift must
		Shr	AX, CL			;   shift word 4 bits right

NoShift:	Or	AX, 0F000h		; Now put 1's in top bits
		Cmp	AX, 0F000h		; See if zero otherwise
		Jmp	Short CheckWord		; And continue checking

Fat16Bit:	Mov	BX, AX			; This is cluster number
		Shl	BX, 1			; Double it
		Mov	AX, ES:[BX]		; Pull out word from sector
		Or	AX, AX			; See if zero (unallocated)

CheckWord:	Pop	ES			; Get back ES
		Mov	DX, Offset NotInUseMsg	; Set up possible message
		Jz	PrintMsg		; If so, print message
		Mov	DX, Offset BadFlagMsg	; Set up possible message
		Cmp	AX, 0FFF7h		; See if cluster flagged bad
		Jz	PrintMsg		; If so, print message
		Mov	DX, Offset InUseMsg	; If not, cluster is in use

PrintMsg:	Call	StringWrite		; Print cluster disposition
		Ret				; And return

;	Read Sectors (CX = Number of Sectors, Return CY and AL for error)
;	-----------------------------------------------------------------

ReadSectors:	Push	BX			; Push all needed registers
		Push	CX
		Push	DX
		Push	DS
		Mov	AL, [DriveNum]		; Get the drive number code
		Sub	BX, BX			; Buffer address offset
		Mov	DX, [StartSector]	; Starting Sector
		Mov	DS, [ReadSegment]	; Buffer address segment
		Int	25h			; Absolute Disk Read
		Pop	BX			; Fix up stack
		Pop	DS			; Get back registers
		Pop	DX
		Pop	CX
		Pop	BX
		Ret				; Return to program 

;	Screen Display Routines
;	-----------------------

WordWrite:	Push	AX			; Push some registers
		Push	BX			; AX contains word to display
		Push	CX
		Push	DX
		Push	SI
		Mov	SI, Offset Divisors	; SI points to divisors
		Mov	CX, 4			; CL counter; CH zero blanker 

WordWriteLoop:	Mov	BX, [SI]		; Get divisor 
		Add	SI, 2			; Increment SI for next one
		Sub	DX, DX			; Prepare for division
		Div	BX			; Divide DX:AX by BX
		Push	DX			; Save remainder
		Or	CH, AL			; See if zero
		Jz	LeadZero		; If so, do not display it
		Add	AL, '0'			; Convert number to ASCII
		Mov	DL, AL			; Print out character
		Mov	AH, 2			;   by calling DOS
		Int	21h

LeadZero:	Pop	AX			; Get back remainder
		Dec	CL			; Decrement counter
		Jg	WordWriteLoop		; If CL still > 0, do it again
		Mov	CH, 1			; No more zero blanking
		Jz	WordWriteLoop		; Convert last digit to ASCII
		Pop	SI			; Get back pushed registers
		Pop	DX
		Pop	CX
		Pop	BX
		Pop	AX
		Ret

StringWrite:	Push	AX			; Displays string from DX
		Mov	AH, 9			;   to screen by calling DOS
		Int	21h
		Pop	AX
		Ret

EndProg		Label	Byte			; End of program
CSEG		EndS
		End	Entry
