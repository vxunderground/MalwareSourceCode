	TITLE	LC Interrupt trap routine
	NAME	LCINT
	INCLUDE DOS.MAC			; BE SURE TO INCLUDE THE CORRECT
					; DOS.MAC!!

;****************************************************************************
;
; This is the heart of a C driven interrupt handler. This file was used to
; write a critical error handler that remained resident. (It replaced the
; "Abort, Retry, Ignore" prompt with a window.) This file can be adapted to
; any interrupt and any C routine with a little work. THIS HAS BEEN USED ONLY
; IN THE S MODEL.
;
;****************************************************************************

DOS_INT		EQU 24H			; int to be replaced

WRITE_INT	EQU 25H			; DOS write int vector
READ_INT	EQU 35H			; DOS read int vector

XREG	STRUC
REG_AX	DW	?			; general purpose registers
REG_BX	DW	? 			
REG_CX	DW	?
REG_DX	DW	?
REG_SI	DW	?
REG_DI	DW	?
XREG	ENDS

SREGS	STRUC
REG_ES	DW	?			; segment registers
REG_CS	DW	?
REG_SS	DW	?
REG_DS	DW	?
SREGS	ENDS

	DSEG

	INT_REGS	XREG	<>		; saved regs. at int time
	INT_SEGREGS	SREGS	<>		; saved seg. regs.
	EXTRN		_TOP:WORD		; declared by C.ASM -- points
						; to top of stack
	ENDDS

	EXTRN	INTTIME:NEAR			; your int routine goes here!

	PSEG
;;
; interrupt time data storage
;;
C_ENVIRONMENT_DS DW ?			; filled by int init, used...
C_ENVIRONMENT_ES DW ?			; ...to recreate C environment
C_ENVIRONMENT_SS DW ?
C_ENVIRONMENT_SP DW ?

INT_TIME_ES	DW ?
INT_TIME_DS	DW ?			; temp save of DS at int time
INT_TIME_SI	DW ?  			; temp save of SI at int time

INT_TIME_BP	DW ? 			; added to account for no BP or SP...
INT_TIME_SP	DW ? 			; ...in above structures

RETURN_VALUE	DW ?			; return value from C service routine

DOS_SERVICE	DD ?			; address of DOS Service routine
INT_TWOONE	DD ?			; old INT 21 vector

INT_IN_PROGRESS DB ?			; interrupt in progress flag -- not
					; used here 'cause int 24H cannot be
					; recursive!

;;**************************************************************************
; name		LC_SERVICE_INT
;
; description	Entered at (software) interrupt time, this routine
;		restores the C enviroment and processes the interrupt
;		trapping all references to the quad file
;;

	IF	LPROG
LC_SERVICE_INT PROC	FAR
	ELSE
LC_SERVICE_INT PROC	NEAR
	ENDIF

	MOV	CS:INT_IN_PROGRESS,1	; clear int in progress flag

	MOV	CS:INT_TIME_ES,ES	; save ES so it can be overwritten
	MOV	CS:INT_TIME_DS,DS	; save DS so it can be overwritten
	MOV	CS:INT_TIME_SI,SI 	; save SI so it can be overwritten
	MOV	CS:INT_TIME_BP,BP 	; save BP as structs do not have it
	MOV	CS:INT_TIME_SP,SP 	; save SP as structs do not have it

	MOV	DS,CS:C_ENVIRONMENT_DS	; set up C enviroment

	MOV	SI,OFFSET INT_REGS	; point to input regs struct

	MOV	DS:[SI].REG_AX,AX	; save general purpose regs
	MOV	DS:[SI].REG_BX,BX
	MOV	DS:[SI].REG_CX,CX
	MOV	DS:[SI].REG_DX,DX
	MOV	DS:[SI].REG_DI,DI
	MOV	AX,CS:INT_TIME_SI	; SI has been overwritten
	MOV	DS:[SI].REG_SI,AX

	MOV	SI,OFFSET INT_SEGREGS	; point to input segment regs struct

	MOV	AX,CS:INT_TIME_ES	; ES has been overwritten
	MOV	DS:[SI].REG_ES,AX
	MOV	DS:[SI].REG_SS,SS
	MOV	AX,CS:INT_TIME_DS	; DS has been overwritten
	MOV	DS:[SI].REG_DS,AX

	MOV	ES,CS:C_ENVIRONMENT_ES	; complete C environment
	MOV	SS,CS:C_ENVIRONMENT_SS
	MOV	SP,CS:C_ENVIRONMENT_SP

	CALL	INTTIME			; call the C routine
	MOV	CS:RETURN_VALUE,AX	; save return value
	XOR	AX,AX

	MOV	SI,OFFSET INT_REGS	; point to input regs struct

	MOV	AX,DS:[SI].REG_SI	; SI needs to be saved while used
	MOV	CS:INT_TIME_SI,AX

	MOV	AX,DS:[SI].REG_AX	; restore general purpose regs
	MOV	BX,DS:[SI].REG_BX
	MOV	CX,DS:[SI].REG_CX
	MOV	DX,DS:[SI].REG_DX
	MOV	DI,DS:[SI].REG_DI

	MOV	SI,OFFSET INT_SEGREGS 	; point to input segment regs struct

	MOV	ES,DS:[SI].REG_DS	; DS needs to be saved while used
	MOV	CS:INT_TIME_DS,ES

	MOV	ES,DS:[SI].REG_ES
	MOV	SS,DS:[SI].REG_SS

	MOV	SI,CS:INT_TIME_SI	; restore pointing registers
	MOV	DS,CS:INT_TIME_DS

	MOV	BP,CS:INT_TIME_BP	; special BP restore
	MOV	SP,CS:INT_TIME_SP	; special SP restore

	MOV	CS:INT_IN_PROGRESS,0	; clear int in progress flag

	MOV	AX,CS:RETURN_VALUE	; move the return value
	IRET				; return from interrupt

LC_SERVICE_INT	ENDP

;****************************************************************************
; description	set up the LC interrupt routines
;
;		INT_INIT -- Hooks into the specified int.
;		INT_TERM -- Unhooks (restores) the specified int.
;
; NOTE: INT_INIT must be called be int processing can begin...it saves the 
;       current C environment for use at interrupt time.
;;

		PUBLIC  INT_INIT
		IF	LPROG
INT_INIT	PROC	FAR
		ELSE
INT_INIT	PROC	NEAR
		ENDIF

	PUSH	DS			; save changed seg regs
	PUSH	ES

	MOV	CS:C_ENVIRONMENT_DS,DS	; save C environment for int time
	MOV	CS:C_ENVIRONMENT_ES,ES
	MOV	CS:C_ENVIRONMENT_SS,SS

	MOV	AX,_TOP			; determine int time SP
	SUB	AX,400H			; gives 1024 byte stack
	MOV	CS:C_ENVIRONMENT_SP,AX

	MOV	AH,READ_INT		; read int vector function
	MOV	AL,DOS_INT		; specify DOS service vector
	INT	21H

	MOV	WORD PTR CS:DOS_SERVICE+2,ES	; save current vector
	MOV	WORD PTR CS:DOS_SERVICE,BX

	LEA	DX,LC_SERVICE_INT	; Use DOS to set new int address
	PUSH	CS
	POP	DS
	MOV	AH,WRITE_INT
	MOV	AL,DOS_INT
	INT	21H

	POP	ES			; restore changed seg regs
	POP	DS
	RET

INT_INIT	ENDP

;********************* INT_TERM -- kill ints. *******************************

		PUBLIC INT_TERM
		IF	LPROG
INT_TERM	PROC	FAR
		ELSE
INT_TERM	PROC	NEAR
		ENDIF

	PUSH	DS			; DS gets changed

	MOV	DS,WORD PTR CS:DOS_SERVICE+2	; Restore previous DOS service vector
	MOV	DX,WORD PTR CS:DOS_SERVICE
	MOV	AH,WRITE_INT
	MOV	AL,DOS_INT
	INT	21H

	POP	DS			; restore DS
	RET
INT_TERM	ENDP

	ENDPS

	END
