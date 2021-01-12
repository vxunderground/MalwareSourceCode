	page	,132
	title	BootThru  - v1.05

;------------------------------------------------------------------------
;
;  BootThru  -	Copyright (c) Bill Gibson - 1987
;		Lathrup Village, Mi 48076
;
;  Ver. 1.00 - Initial version			 (not rlsd) -  01/11/87
;	1.01 - revised code structure		      "     -  01/25/87
;	1.02 - revised Modify Proc		      "     -  02/01/87
;	1.03 - enhanced error message output	      "     -  02/06/87
;	1.04 - revised Print Proc		  released  -  02/07/87
;	1.05 - fix incompatibility plbm 		    -  02/09/87
;
;
;  For Public Domain Use.  Not for Sale or Hire.
;------------------------------------------------------------------------
COMMENT *

	  Routine to modify diskette boot record, using drive A: or B:,
	  thus circumventing DOS' non-system disk display error.

	  Usage:
		    BT A:	   -> transfer new boot record to drive A:
		    BT B:	   -> transfer new boot record to drive B:
		    BT		   -> starts program, default is drive A:
*
;------------------------------------------------------------------------
code		SEGMENT BYTE PUBLIC 'code'
ASSUME		CS:code,DS:code,SS:code
		ORG	5Ch			;drive id
param1		LABEL	BYTE
		ORG	5Dh			;elim spurrious characters
param2		LABEL	BYTE

		ORG	100h

BootThru	PROC	FAR
		MOV	CS:stk_ptr,SP		;save stack ptr to ensure ret
		CALL	Chk_Ver 		;dos 2.0 or greater

		CALL	Scan
		CALL	Dwrite
		JMP	SHORT exit
error:
		MOV	SP,stk_ptr		;insure proper return
		CALL	Print			;print error messages
		MOV	AL,1			;set errorlevel to 1
exit:
		MOV	AH,4Ch
		INT	21h

;------------------------------------------------------------------------
; Work Area - constants,equates,messages
;------------------------------------------------------------------------
drive		DB	0
stk_ptr 	DW	0

blank		EQU	020h		;ascii space code
cr		EQU	0Dh		;carriage return
lf		EQU	0Ah		;line feed
esc		EQU	01Bh		;escape char
stopper 	EQU	255		;end of display line indicator

logo	DB	cr,lf,'BootThru - The Diskette Modifier'
	DB	cr,lf,'Version 1.05 - Bill Gibson 1987',cr,lf,stopper

usage	DB	cr,lf,'Usage: BT [drive A: or B:]',cr,lf,stopper
sorry	DB	cr,lf,'Wrong PC DOS Version',cr,lf,stopper
msg1	DB	cr,lf,'Insert diskette in drive A, and press ENTER'
	DB	' when ready ...',stopper
msg2	DB	cr,lf,'Insert diskette in drive B, and press ENTER'
	DB	' when ready ...',stopper
msg3	DB	cr,lf,'Press ENTER to modify another disk',cr,lf
	DB	'or ESCape to quit...',stopper
msg4	DB	cr,lf,cr,lf,'Transferring New Boot Sector',cr,lf,stopper
msg5	DB	cr,lf,'Transfer Completed',cr,lf,stopper

msg80h	DB	cr,lf,cr,lf,'* Error *  Drive failed to respond.',cr,lf,cr,lf,stopper
msg40h	DB	cr,lf,cr,lf,'* Error *  Seek operation failed.',cr,lf,cr,lf,stopper
msg20h	DB	cr,lf,cr,lf,'* Error *  Controller failure.',cr,lf,cr,lf,stopper
msg10h	DB	cr,lf,cr,lf,'* Error *  Bad CRC on diskette write.',cr,lf,cr,lf,stopper
msg08h	DB	cr,lf,cr,lf,'* Error *  DMA overrun on operation.',cr,lf,cr,lf,stopper
msg04h	DB	cr,lf,cr,lf,'* Error *  Requested sector not found.',cr,lf,cr,lf,stopper
msg03h	DB	cr,lf,cr,lf,'* Error *  Write protected diskette.',cr,lf,cr,lf,stopper
msg02h	DB	cr,lf,cr,lf,'* Error *  Address mark not found.',cr,lf,cr,lf,stopper
msggen	DB	cr,lf,cr,lf,'* Unknown Error *',cr,lf,cr,lf,stopper

;--------------------------------------------------------------------------
; Sub-Routines:
;--------------------------------------------------------------------------
Chk_Ver 	PROC	NEAR
		MOV	AH,30h		;verify DOS 2.0 or later
		INT	21h
		CMP	AL,2
		JAE	SHORT chk_ok
		MOV	DX,OFFSET sorry
		JMP	error
chk_ok:
		RET
Chk_Ver 	ENDP

;--------------

Scan		PROC	NEAR		;check for any spurrious chars
		MOV	AL,[param2]
		CMP	AL,blank		;anything ?
		JNZ	shlp			;yes, give error msg
s1:
		MOV	AL,[param1]	;check for drive parameters
		OR	AL,AL			;anything ?
		JNZ	s2			;jump and test
		MOV	DX,OFFSET logo		;setup default drive A:
		CALL	Print
		MOV	drive,0
		MOV	DX,OFFSET msg1
		RET
s2:
		CMP	AL,01			;setup for drive A:
		JZ	SHORT sdrvA
		CMP	AL,02			;for drive B:
		JZ	SHORT sdrvB
shlp:
		MOV	DX,OFFSET usage 	;display for invalid drives
		JMP	error
sdrvA:
		MOV	DX,OFFSET logo
		CALL	Print
		MOV	drive,0
		MOV	DX,OFFSET msg1
		RET
sdrvB:
		MOV	DX,OFFSET logo
		CALL	Print
		MOV	drive,1
		MOV	DX,OFFSET msg2
		RET

Scan		ENDP

;--------------

Dwrite		PROC	NEAR		;transfer new disk boot sector

		CALL	Print		;get ready
d1:
		MOV	AH,8		;use function 8 in order to detect
		INT	21h		;ctrl-breaks
		CMP	AL,esc		;ESC & Ctrl-Break aborts process
		JZ	d5
		CMP	AL,cr
		JNZ	d1
d2:
		MOV	DX,OFFSET msg4		;setup for disk write
		CALL	Print
		MOV	AL,drive
		LEA	BX,head
		MOV	CX,0001
		MOV	DX,0000
drite:						;more setups
		PUSH	AX
		PUSH	BX
		PUSH	CX
		PUSH	DX
		INT	26h
		JC	derror			;processing error ?
		POPF				;done
		POP	DX
		POP	CX
		POP	BX
		POP	AX
d3:
		MOV	DX,OFFSET msg5		;transfer complete
		CALL	Print
		JMP	d4
derror: 					;display disk errror
		CALL	ErrorList
dend_of:
		CALL	Print
		POPF				;done
		POP	DX
		POP	CX
		POP	BX
		POP	AX
d4:
		MOV	DX,OFFSET msg3		;another ?
		CALL	Print
		JMP	d1			;loop
d5:
		RET
Dwrite		ENDP

;--------------

Print		PROC	NEAR		;a Great idea from Vern Buerg !
		PUSH	SI
		PUSH	BX
		PUSH	CX
		MOV	SI,DX		;DX has the offset to string
		SUB	CX,CX		;set to zero for count
p1:
		LODSB
		CMP	AL,stopper	;string ends in FFh
		JE	p9
		INC	CX		;increment text length
		JMP	p1
p9:
		MOV	AH,40h		;write using file handles
		MOV	BX,1
		INT	21h
		POP	CX
		POP	BX		;recover registers
		POP	SI
		RET
Print		ENDP

;--------------

ErrorList	PROC	NEAR		;error code interpretation
					;the upper byte (AH) contains error
err80h: 	CMP	AH,080h 		;attachment failed to respond
		JNZ	err40h
		MOV	DX,OFFSET msg80h
		RET
err40h:
		CMP	AH,040h 		;seek operation failed
		JNZ	err20h
		MOV	DX,OFFSET msg40h
		RET
err20h:
		CMP	AH,020h 		;controller failed
		JNZ	err10h
		MOV	DX,OFFSET msg20h
		RET
err10h:
		CMP	AH,010h 		;data error (bad CRC)
		JNZ	err08h
		MOV	DX,OFFSET msg10h
		RET
err08h:
		CMP	AH,08h			;direct memory access failure
		JNZ	err04h
		MOV	DX,OFFSET msg08h
		RET
err04h:
		CMP	AH,04h			;requested sector not found
		JNZ	err03h
		MOV	DX,OFFSET msg04h
		RET
err03h:
		CMP	AH,03h			;write-protect fault
		JNZ	err02h
		MOV	DX,OFFSET msg03h
		RET
err02h:
		CMP	AH,02h			;bad address mark
		JNZ	errgen
		MOV	DX,OFFSET msg02h
		RET
errgen:
		MOV	DX,OFFSET msggen	;something new ?  (Unknown)
		RET
ErrorList	ENDP

;--------------

Modify		PROC	FAR
head:
cr		EQU	0Dh		;carriage return
lf		EQU	0Ah		;line feed
stopper 	EQU	255		;end of display line indicator
boot_area	EQU	0000h		;setup boot area
bogus_drv	EQU	0080h		;setup bogus drive
loc2		EQU	01FEh		;last two bytes of boot sector
eof_bootsec	EQU	0AA55h		;end of boot sector (reversed)
bulc		EQU	0DAh		;box upper left corner
burc		EQU	0BFh		;box upper right corner
bllc		EQU	0C0h		;box lower left corner
blrc		EQU	0D9h		;box lower right corner
bver		EQU	0B3h		;vertical
bhor		EQU	0C4h		;horizontal

		JMP	start		;1st byte of the sector must be a jmp
		DB	'BootThru'      ;8-byte system id
		DW	512		;sector size in bytes
		DB	2		;sectors per cluster
		DW	1		;reserved clusters
		DB	2		;number of fats
		DW	112		;root directory entries
		DW	720		;total sectors
		DB	0FDh		;format id  (2 sided, 9 sector)
		DW	2		;sectors per fat
		DW	9		;sectors per track
		DW	2		;sides
		DW	0		;special hidden sectors
		DB	0		;filler
		DB	0		;head
		DB	0Ah		;length of BIOS file
		DB	0DFh		;disk parameter table
		DB	02		;	  "
		DB	25h		;	  "
		DB	02		;	  "
		DB	09		;	  "
		DB	02Ah		;Int 1Eh points to this table,
		DB	0FFh		;the disk parameter table.
		DB	050h		;contents of this vector (1Eh)
		DB	0F6h		;are used as a pointer only,
		DB	0Fh		;Int 1Eh is not executed
		DB	02		;directly
intro_beg:
		DB   cr,lf,
		DB   cr,lf,bulc,46 DUP(bhor),burc
		DB   cr,lf,bver,'      This disk was modified by BootThru      ',bver
		DB   cr,lf,bver,'       Version 1.05 by Bill Gibson 1987       ',bver
		DB   cr,lf,bllc,46 DUP(bhor),blrc
		DB   cr,lf,stopper

intro_offset	EQU	intro_beg - head

start:
		MOV	AX,07C0h	;boot record location
		MOV	ES,AX
		MOV	DS,AX
		MOV	SI,intro_offset
strt1:
		MOV	AH,0Eh			;write teletype
		MOV	AL,[SI]
		CMP	AL,stopper
		JE	SHORT strt2
		PUSH	SI
		INT	10h
		POP	SI
		INC	SI
		JMP	SHORT strt1
strt2:
		CLD				;setup to bypass drive A:
		MOV	SI,OFFSET strt3 - OFFSET head
		MOV	DI,0200h		;boot sector size
		MOV	CX,0200h
		REPZ  MOVSB
		JMP	head + 200h
strt3:
		MOV	AH,2		;function 02h - read floppy disk
		MOV	BX,boot_area	;boot area
		MOV	CH,0		;track number
		MOV	CL,1		;sector
		MOV	DH,0		;head
		MOV	DL,bogus_drv	;bogus drive
		MOV	AL,1		;number of sectors
		INT	13h
strt4:
		MOV	BX,loc2 		;setup to pull ROM Basic in
		MOV	AX,[BX] 		;if an error occurs
		CMP	AX,eof_bootsec
		JNZ	strt9
		JMP	strt3 - 200h
strt9:
		INT	18h

		DB	'BootThru, Copyright (c) Bill Gibson, 02.09.87'
tail:

filler_amount	EQU	512 - (tail - head) - 2

		DB	filler_amount dup (0)	  ; filler
boot_id 	DB	055h,0AAh		  ; boot id

Modify		ENDP

BootThru	ENDP
code		ENDS
		END	BootThru
