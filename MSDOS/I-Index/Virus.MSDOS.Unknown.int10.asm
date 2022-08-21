DOSCALL   SEGMENT 'CODE'
          ASSUME CS:DOSCALL,DS:DOSCALL
;
;Procedure DOSVIO(VAR: AX, BX, CX, DX: Word);
;
; Issue a DOS VIDEO I/O INT (10) with register values set by caller
;
; FRAME:  ADR   AX; 12
;         ADR   BX; 10
;         ADR   CX; 08
;         ADR   DX; 06
;         <RET BP>; 00
;
          PUBLIC DOSVIO
DOSVIO    PROC  FAR
          PUSH  BP             ;Save current BP value
          MOV   BP,SP          ;To address parms
          MOV   DI,[BP+12]     ;Address of AX
          MOV   AX,[DI]        ;Set AX value
          MOV   DI,[BP+10]     ;Address of BX
          MOV   BX,[DI]        ;Set BX value
          MOV   DI,[BP+08]     ;Address of CX
          MOV   CX,[DI]        ;Set CX value
          MOV   DI,[BP+06]     ;Address of DX
          MOV   DX,[DI]        ;Set DX value
 
          INT   10H            ;Call BIOS with caller's AX, BX, CX, DX
 
          MOV   DI,[BP+12]     ;Now put them all back...
          MOV   [DI],AX
          MOV   DI,[BP+10]
          MOV   [DI],BX
          MOV   DI,[BP+08]
          MOV   [DI],CX
          MOV   DI,[BP+06]
          MOV   [DI],DX
 
          POP   BP             ;Restore frame pointer
          RET   6              ;Return, poping 6 bytes
 
DOSVIO    ENDP
 
DOSCALL   ENDS
          END
                                                                      
*** CREATED 06/28/82 21:05:48 BY AMD *** 
