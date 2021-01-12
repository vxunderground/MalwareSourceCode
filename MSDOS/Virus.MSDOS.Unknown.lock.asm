COMMENT*  Change ROR -> ROL in the TWO marked places to produce UNLOCK.ASM  *
CODE_SEG        SEGMENT
        ASSUME  CS:CODE_SEG
        ORG     100H
HERE:   JMP     THERE
        COPY_RIGHT      DB       '(C)1985 Steven Holzner'
        PROMPT  DB      'Phrase: $'     ;All the messages & prompts
        DEFAULT DB      'FILE.LOC',0
        NOTSEEN DB      13,10,'File Not Found$'
        FULL:   DB      13,10,'Disk Full$'
        FILETWO DW      0               ;Address of 2nd File name
        FILEND  DW      0               ;End of read-in files in memory
THERE   PROC    NEAR                    ;Our procedure
        MOV     BX,81H                  ;Make the filenames into ASCIIZ
UP:     INC     BX                      ;Scan type-in for space, <cr>
        CMP     BYTE PTR [BX],' '       ;Space?
        JNE     NOSPACE
        MOV     BYTE PTR [BX],0         ;Put the Z in ASCIIZ
        MOV     FILETWO,BX              
        INC     FILETWO                 ;Store filename starting location
NOSPACE:CMP     BYTE PTR [BX],13        ;If not a space, a <cr>?
        JNE     UP
        MOV     BYTE PTR [BX],0         ;If yes, replace with a 0
        CMP     FILETWO,0
        JNZ     OVER
        MOV     FILETWO,OFFSET DEFAULT  ;If no second file given, use default
OVER:   LEA     DX,PROMPT               ;Type out the prompt with string print
        MOV     AH,9
        INT     21H   
        MOV     BX,80H+40H-2            ;Prepare 40H (64) buffer for key phrase
        MOV     BYTE PTR [BX],40H
        PUSH    BX                      ;Set up buffer address
        POP     DX
        MOV     AH,0AH                  ;Buffered input
        INT     21H
        MOV     BX,80H+40H              ;Start of key phrase
        PUSH    BX
JUMP:   CMP     BYTE PTR [BX],13        ;Set up key phrase's ASCII values
        JE      READY                   ;Scan until <cr>
        OR      BYTE PTR [BX],1         ;Make it odd
        AND     BYTE PTR [BX],0FH       ;Use only lower four bits
        INC     BX
        JMP     JUMP                    ;Keep going until <cr>
READY:  POP     BX
        MOV     AX,3D00H                ;Open the file to encrypt
        MOV     DX,82H                  ;Point to its name
        INT     21H
        JNC     OKFILE                  ;Carry Flag --> some problem, assume
        LEA     DX,NOTSEEN              ;  file doesn't exist, say so
        MOV     AH,9
        INT     21H
        JMP     OUT                     ;Exit
                                        
OKFILE: PUSH    BX                      ;Store location in key phrase
        MOV     BX,AX                   ;Put handle into BX
        MOV     CX,62*1024              ;Ask for 62K bytes to be read from file
        LEA     DX,THEBOTTOM            ;And put at end of program
        MOV     AH,3FH                  ;Read
        INT     21H  
        ADD     AX,OFFSET THEBOTTOM     ;Actually read AX bytes
        MOV     FILEND,AX               
        DEC     FILEND                  ;Find how far the file extends in mem.
        MOV     AH,3EH                  ;Close file, thank you very much.
        INT     21H
        POP     BX
        LEA     CX,THEBOTTOM            ;Save current location in file in CX

SCRMBLE:MOV     SI,CX                   ;Will scramble from [SI] to [DI]
        CMP     SI,FILEND               ;Past end?
        JAE     DONE                    ;If yes, exit
        MOV     DI,CX
        XOR     AX,AX
        MOV     AL,[BX]                 ;How many to scramble? (from key phrase)
        ADD     DI,AX
        MOV     CX,DI                   
        INC     CX                   ;Store new starting location for next time

        INC     BX                   ;Also, get next character for next scramble
        CMP     BYTE PTR [BX],13        ;If at end of key phrase, wrap
        JNE     TWIST
        MOV     BX,80H+40H

TWIST:  CMP     DI,FILEND               ;Is DI past end?
        JBE     GRAB

        MOV     DI,FILEND               ;If yes, only scramble to file end
        PUSH    DI
        SUB     DI,SI                   ;What about last byte?
        TEST    DI,1
        POP     DI
        JNZ     GRAB                    ;If left over, rotate it once
        ROR     BYTE PTR [DI],1         ;<--- ROL FOR UNLOCK!!!
        DEC     DI
        CMP     SI,DI
        JAE     DONE

GRAB:   MOV     DH,[SI]                 ;Get byte 1
        MOV     DL,[DI]                 ;Get byte 2
        PUSH    CX
        MOV     CL,[BX]                 ;Get number of times to rotate

        INC     BX                      ;Set up key phrase char for next time
        CMP     BYTE PTR [BX],13
        JNE     TWISTER
        MOV     BX,80H+40H
                                        ;Rotate the hybrid word
TWISTER:ROR     DX,CL                   ;<--- ROL FOR UNLOCK!!!
        POP     CX
        MOV     [SI],DH                 ;And replace the parts
        MOV     [DI],DL
        INC     SI                      ;Point to next part to scramble
        CMP     SI,DI                   ;Have SI and DI met yet?
        JE      SCRMBLE             ;If yes, move on to next part to scramble
        DEC     DI
        JMP     GRAB                    ;Go back until done
DONE:   MOV     AH,3CH                  ;Done
        MOV     CX,0                    ;Prepare to write out scrambled version
        MOV     DX,FILETWO
        INT     21H                     ;Create the file
        JC      ERROR
        MOV     BX,AX
        MOV     AH,40H
        LEA     DX,THEBOTTOM
        MOV     CX,FILEND               ;File size to write
        SUB     CX,OFFSET THEBOTTOM
        INC     CX
        INT     21H                     ;Write it out
        CMP     AX,CX                   ;If error, (returned)AX .NE. (orig.)CX
        JE      CLOSE
ERROR:  LEA     DX,FULL                 ;Assume disk is full, say so, leave
        MOV     AH,9 
        INT     21H 
        JMP     OUT
CLOSE:  MOV     AH,3EH                  ;Otherwise, close the file and exit
        INT     21H   
OUT:    INT     20H
THERE   ENDP
THEBOTTOM:                              ;Read-in file starts here.
        CODE_SEG        ENDS            
        END     HERE


        
                         

