PAGE ,132
	title	\asm_sour\timer.asm  HIGH ACCURACY TIMER
	subttl	michael e. walraven
.MODEL MEDIUM

name timer
.cref
.lall

;
;	High resolution timer, returns a 32 bit high resolution
;	value which is the amount of elapsed time since the function
;	was last called.  The counts are 838.2ns each (1.19318 MHz)
;	time_int() must be called first to set the timer chip to
;	the proper mode.
;	Counter 0 is changed in time_int() and the data from this
;	counter is used in elaptime() so it must not be changed
;	between calls.
;	There should not be any interference in system timing 
;	max of 55 msec error introduced by time_int() into absolute
;	system time.

;	MEDIUM memory model/microsoft 5.00
;	FAR PROGRAM, NEAR DATA
;	cs: is code segment
;	es: and ds: are data segment
;	ss: within data segment
;	ax: for integer return
;	dx:ax: for long return

.DATA
;	these data items located in the DSEG and can be accessed
;	as near by C programs

	PUBLIC	SYS_HI
	PUBLIC	SYS_LOW
	PUBLIC	TIMER_COUNT

SYS_HI		DW	?	;TIMER_HI VALUE FOR PREVIOUS CALL
SYS_LOW		DW	?	;TIMER_LOW VALUE FOR PREVIOUS CALL
TIMER_COUNT	DW	?	;8253 TIMER COUNT FOR PREVIOUS CALL


;	NO ARGUMENTS PASSED to either function

TIMER_MODE	EQU	043H
TIMER0		EQU	040H

BIOS	SEGMENT	AT 040H
	ORG	06CH
TIMER_LOW	DW	?
TIMER_HI	DW	?
BIOS	ENDS

PAGE
.CODE

	PUBLIC	_time_int
_time_int	PROC

;	void far time_int(void);
;
;	SET THE TIMER MODE FOR PULSE OUTPUT, RATHER THAN SQUARE
;		MODE AS SET BY DOS

	MOV	AL,00110100B	;CTR 0, LSB THEN MSB
				;MODE 2, BINARY
	OUT	TIMER_MODE,AL	;MODE REGISTER FOR 8253
	SUB	AX,AX		;SET 0, RESULT IN MAX COUNT
	OUT	TIMER0,AL
	OUT	TIMER0,AL
	RET
_time_int	ENDP


	PUBLIC	_elaptime
_elaptime	PROC

;	long int far elaptime(void);
;
;	DETERMINE ELAPSED TIME SINCE LAST CALL
;	RETURNS 32 BIT (LONG) VALUE WHICH IS
;	NEW  - TIMER_HI:TIMER_LO:TIMER_COUNT   MINUS
;	OLD  - TIMER_HI:TIMER_LO:TIMER_COUNT
 
;	ASSUMPTION MADE THAT 32 BITS WILL NOT OVERFLOW!!!!

	PUSH	ES
	MOV	AX,BIOS
	MOV	ES,AX
	ASSUME	ES:BIOS

	MOV	AL,0		;PREPARE TO LATCH COUNTER
	OUT	TIMER_MODE,AL	;LATCH 8253

	PUSHF		;SAVE INTERRUPT STATE
	CLI		;TURN INTERRUPT OFF WHILE READING CODE
	IN	AL,TIMER0
	MOV	DL,AL
	IN	AL,TIMER0
	MOV	DH,AL		;DX HAS NEW CHIP COUNT(count down value)

	MOV	BX,ES:TIMER_LOW	;BX HAS SYSTEM TIME LOW WORD
	MOV	AX,ES:TIMER_HI	;AX HAS SYSTEM TIME HIGH WORD

;	NOW HAVE A 48 BIT WORD AX:BX:DX FOR THE PRESENT TIME
	MOV	CX,TIMER_COUNT	;SWAP AND SUBTRACT
	MOV	TIMER_COUNT,DX
	SUB	CX,DX

;	CX: HAS LOW 16 BITS OF DIFFERENCE

	MOV	DX,SYS_LOW	;SWAP AND SUBTRACT
	MOV	SYS_LOW,BX
	SBB	BX,DX

;	BX: HAS MID 16 BITS OF DIFFERENCE

	MOV	DX,SYS_HI	;SWAP AND SUBTRACT
	MOV	SYS_HI,AX
	SBB	AX,DX

;	AX: HAS HIGH 16 BITS OF DIFFERENCE

;	NOW HAVE A 48 BIT WORD THAT IS DIFFERENCE
;	ONLY PASS BACK 32 BITS AT PRESENT
;	AS DX:AX
 
	MOV	AX,CX	;LOW 16 BITS
	MOV	DX,BX	;MID 16 BITS


	POPF
	POP	ES
	RET
_elaptime	ENDP


	END
		
