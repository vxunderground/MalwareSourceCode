;assembly language shell for a simple COM file program


MAIN    SEGMENT BYTE
        ASSUME  CS:MAIN,DS:MAIN,SS:NOTHING

        ORG     100H

START:

FINISH: mov     ah,4CH
        mov     al,0
        int     21H             ;terminate normally with DOS

MAIN    ENDS


        END START
