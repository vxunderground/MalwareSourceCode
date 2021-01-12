

;       Phantasie Mutation Engine --- DEMO
;       This program will generate 50 mutation programs.
;       (C) Copyright 1995 Written by Burglar. All Rights Reserved.
;       Made In Taiwan.


        .MODEL  TINY

        .CODE

        ORG     100H

        EXTRN   PME:NEAR, PME_END:NEAR  ;must declare PME to external module.


BEGIN:
        MOV     DX,OFFSET GEN_MSG
        MOV     AH,9
        INT     21H

        MOV     CX,50
GEN:
        PUSH    CX

        MOV     DX,OFFSET FILENAME
        PUSH    CS
        POP     DS
        XOR     CX,CX
        MOV     AH,3CH
        INT     21H

        PUSH    AX

        MOV     DX,OFFSET PROG  ;DS:DX point to the head of program which you
                                ;want to be mutation.
        MOV     CX,OFFSET PROG_END - OFFSET PROG  ;CX hold the length of the
                                                  ;program which you want to
                                                  ;be mutation.
        MOV     BX,100H  ;BX sets the beginning offset when execution.

        PUSH    SS
        POP     AX
        ADD     AX,1000H
        MOV     ES,AX   ;ES point to a work segment.
                        ;for putting decryption routine + encrypted code.
                        ;just need the length of origin program + 512 bytes.

        CALL    PME     ;OK! when every thing is okay, you can call the PME.

                        ;When PME execute over, it will return :
                        ;DS:DX -> decryption routine + encrypted code.
                        ;CX -> length of the decryption routine + encrypted
                        ;code. (always origin length + 512 bytes)

        POP     BX
        MOV     AH,40H
        INT     21H

        MOV     AH,3EH
        INT     21H

        MOV     BX,OFFSET FILENAME
        INC     BYTE PTR CS:BX+7
        CMP     BYTE PTR CS:BX+7,'9'
        JBE     L0
        MOV     BYTE PTR CS:BX+7,'0'
        INC     BYTE PTR CS:BX+6
L0:
        POP     CX
        LOOP    GEN

        INT     20H

FILENAME DB     '00000000.COM',0

GEN_MSG DB      'Generating 50 mutation programs... $'

PROG:
        CALL    $+3
        POP     DX
        ADD     DX,OFFSET MSG - OFFSET PROG - 3
        MOV     AH,9
        INT     21H
        INT     20H
MSG     DB      'I am a mutation program.$'
PROG_END:


        END     BEGIN


