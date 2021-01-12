INTERRUPTS      SEGMENT AT 0H   ;This is where the keyboard interrupt
        ORG     9H*4            ;holds the address of its service routine
KEYBOARD_INT    LABEL   DWORD  
INTERRUPTS      ENDS

SCREEN  SEGMENT AT 0B000H       ;A dummy segment to use as the
SCREEN  ENDS                    ;Extra Segment 

ROM_BIOS_DATA   SEGMENT AT 40H  ;BIOS statuses held here, also keyboard buffer

        ORG     1AH
        HEAD DW      ?                  ;Unread chars go from Head to Tail
        TAIL DW      ?
        BUFFER       DW      16 DUP (?)         ;The buffer itself
        BUFFER_END   LABEL   WORD

ROM_BIOS_DATA   ENDS

CODE_SEG        SEGMENT
        ASSUME  CS:CODE_SEG
        ORG     100H            ;ORG = 100H to make this into a .COM file
FIRST:  JMP     LOAD_PAD        ;First time through jump to initialize routine

        CNTRL_N_FLAG    DW      0               ;Cntrl-N on or off
        PAD             DB      '_',499 DUP(' ')       ;Memory storage for pad  
        PAD_CURSOR      DW      0               ;Current position in pad
        PAD_OFFSET      DW      0               ;Chooses 1st 250 bytes or 2nd
        FIRST_POSITION  DW      ?               ;Position of 1st char on screen
        ATTRIBUTE       DB      112             ;Pad Attribute -- reverse video
        SCREEN_SEG_OFFSET       DW      0       ;0 for mono, 8000H for graphics
        IO_CHAR         DW      ?               ;Holds addr of Put or Get_Char
        STATUS_PORT     DW      ?               ;Video controller status port
        OLD_KEYBOARD_INT        DD      ?       ;Location of old kbd interrupt

N_PAD   PROC    NEAR            ;The keyboard interrupt will now come here.
        ASSUME  CS:CODE_SEG
        PUSH    AX              ;Save the used registers for good form
        PUSH    BX
        PUSH    CX
        PUSH    DX
        PUSH    DI
        PUSH    SI
        PUSH    DS
        PUSH    ES
        PUSHF                   ;First, call old keyboard interrupt
        CALL    OLD_KEYBOARD_INT

        ASSUME  DS:ROM_BIOS_DATA        ;Examine the char just put in
        MOV     BX,ROM_BIOS_DATA
        MOV     DS,BX
        MOV     BX,TAIL                 ;Point to current tail
        CMP     BX,HEAD                 ;If at head, kbd int has deleted char
        JE      IN                      ;So leave 
        SUB     BX,2                    ;Point to just read in character
        CMP     BX,OFFSET BUFFER        ;Did we undershoot buffer?
        JAE     NO_WRAP                 ;Nope
        MOV     BX,OFFSET BUFFER_END    ;Yes -- move to buffer top
        SUB     BX,2
NO_WRAP:MOV     DX,[BX]                 ;Char in DX now
        CMP     DX,310EH                ;Is the char a Cntrl-N?
        JNE     NOT_CNTRL_N             ;No
        MOV     TAIL,BX                 ;Yes -- delete it from buffer
        NOT     CNTRL_N_FLAG            ;Switch Modes
        CMP     CNTRL_N_FLAG,0          ;Cntrl-N off?
        JNE     CNTRL_N_ON              ;No, only other choice is on
CNTRL_N_OFF:
        MOV     ATTRIBUTE,7             ;Set up for normal video
        MOV     PAD_OFFSET,250          ;Point to 2nd half of pad
        LEA     AX,PUT_CHAR             ;Make IO call Put_Char as it scans
        MOV     IO_CHAR,AX              ;over all locations in pad on screen
        CALL    IO                      ;Restore screen
IN:     JMP     OUT                     ;Done
CNTRL_N_ON:
        MOV     PAD_OFFSET,250          ;Point to screen stroage part of pad
        LEA     AX,GET_CHAR             ;Make IO use Get_char so current screen
        MOV     IO_CHAR,AX              ;is stored
        CALL    IO                      ;Store Screen
        CALL    DISPLAY                 ;And put up the pad
        JMP     OUT                     ;Done here.
NOT_CNTRL_N:
        TEST    CNTRL_N_FLAG,1          ;Is Cntrl-N on?
        JZ      IN                      ;No -- leave
        MOV     TAIL,BX                 ;Yes, delete this char from buffer
        CMP     DX,5300H                ;Decide what to do -- is it a Delete?
        JNE     RUBOUT_TEST             ;No -- try Rubout
        MOV     BX,249                  ;Yes -- fill pad with spaces
DEL_LOOP:
        MOV     PAD[BX],' '             ;Move space to current pad position
        DEC     BX                      ;and go back one
        JNZ     DEL_LOOP                ;until done.
        MOV     PAD,'_'                 ;Put the cursor at the beginning
        MOV     PAD_CURSOR,0            ;And start cursor over
        CALL    DISPLAY                 ;Put up the new pad on screen
        JMP     OUT                     ;And take our leave
RUBOUT_TEST:
        CMP     DX,0E08H                ;Is it a Rubout?
        JNE     CRLF_TEST               ;No -- try carriage return-line feed
        MOV     BX,PAD_CURSOR           ;Yes -- get current pad location
        CMP     BX,0                    ;Are we at beginning?
        JLE     NEVER_MIND              ;Yes -- can't rubout past beginning
        MOV     PAD[BX],' '             ;No -- move space to current position
        MOV     PAD[BX-1],'_'           ;And move cursor back one
        DEC     PAD_CURSOR              ;Set the pad location straight
NEVER_MIND:
        CALL    DISPLAY                 ;And put the result on the screen
        JMP     OUT                     ;Done here.
CRLF_TEST:
        CMP     DX,1C0DH                ;Is it a carriage return-line feed?
        JNE     CHAR_TEST               ;No -- put it in the pad
        CALL    CRLF                    ;Yes -- move to next line
        CALL    DISPLAY                 ;And display result on screen
        JMP     OUT                     ;Done.
CHAR_TEST:
        MOV     BX,PAD_CURSOR           ;Get current pad location
        CMP     BX,249                  ;Are we past the end of the pad?
        JGE     PAST_END                ;Yes -- throw away char
        MOV     PAD[BX],DL              ;No -- move ASCII code into pad
        MOV     PAD[BX+1],'_'           ;Advance cursor
        INC     PAD_CURSOR              ;Increment pad location
        PAST_END:
        CALL    DISPLAY                 ;Put result on screen
OUT:    POP     ES      ;Having done Pushes, here are the Pops
        POP     DS
        POP     SI
        POP     DI
        POP     DX
        POP     CX
        POP     BX
        POP     AX     
        IRET                    ;An interrupt needs an IRET
N_PAD   ENDP

DISPLAY PROC    NEAR                    ;Puts the whole pad on the screen
        PUSH    AX
        MOV     ATTRIBUTE,112           ;Use reverse video
        MOV     PAD_OFFSET,0            ;Use 1st 250 bytes of pad memory
        LEA     AX,PUT_CHAR             ;Make IO use Put-Char so it does
        MOV     IO_CHAR,AX              
        CALL    IO                      ;Put result on screen
        POP     AX
        RET                             ;Leave
DISPLAY ENDP

CRLF    PROC    NEAR                    ;This handles carriage returns
        CMP     PAD_CURSOR,225          ;Are we on last line?
        JGE     DONE                    ;Yes, can't do a carriage return, exit
NEXT_CHAR:
        MOV     BX,PAD_CURSOR           ;Get pad location
        MOV     AX,BX                   ;Get another copy for destructive tests
EDGE_TEST:
        CMP     AX,24                   ;Are we at the edge of the pad display?
        JE      AT_EDGE                 ;Yes -- fill pad with new cursor
        JL      ADD_SPACE               ;No -- Advance another space
        SUB     AX,25                   ;Subtract another line-width
        JMP     EDGE_TEST               ;Check if at edge now
ADD_SPACE:
        MOV     PAD[BX],' '             ;Add a space
        INC     PAD_CURSOR              ;Update pad location
        JMP     NEXT_CHAR               ;Check if at edge now
AT_EDGE:
        MOV     PAD[BX+1],'_'           ;Put cursor in next location
        INC     PAD_CURSOR              ;Update pad location to new cursor
DONE:   RET                             ;And out.
CRLF    ENDP

GET_CHAR        PROC    NEAR    ;Gets a char from screen and advances position
        PUSH    DX
        MOV     SI,2            ;Loop twice, once for char, once for attribute
        MOV     DX,STATUS_PORT  ;Get ready to read video controller status
G_WAIT_LOW:                     ;Start waiting for a new horizontal scan -
        IN      AL,DX           ;Make sure the video controller scan status
        TEST    AL,1            ;is low
        JNZ     G_WAIT_LOW
G_WAIT_HIGH:                    ;After port has gone low, it must go high
        IN      AL,DX           ;before it is safe to read directly from
        TEST    AL,1            ;the screen buffer in memory
        JZ      G_WAIT_HIGH
        MOV     AH,ES:[DI]      ;Do the move from the screen, one byte at a time
        INC     DI              ;Move to next screen location                   
        DEC     SI              ;Decrement loop counter
        CMP     SI,0            ;Are we done?
        JE      LEAVE           ;Yes
        MOV     PAD[BX],AH      ;No -- put char we got into the pad
        JMP     G_WAIT_LOW      ;Do it again
LEAVE:  INC     BX              ;Update pad location
        POP     DX
        RET
GET_CHAR        ENDP

PUT_CHAR        PROC    NEAR    ;Puts one char on screen and advances position
        PUSH    DX
        MOV     AH,PAD[BX]      ;Get the char to be put onto the screen
        MOV     SI,2            ;Loop twice, once for char, once for attribute
        MOV     DX,STATUS_PORT  ;Get ready to read video controller status
P_WAIT_LOW:                     ;Start waiting for a new horizontal scan -
        IN      AL,DX           ;Make sure the video controller scan status
        TEST    AL,1            ;is low
        JNZ     P_WAIT_LOW
P_WAIT_HIGH:                    ;After port has gone low, it must go high
        IN      AL,DX           ;before it is safe to write directly to
        TEST    AL,1            ;the screen buffer in memory
        JZ      P_WAIT_HIGH
        MOV     ES:[DI],AH      ;Move to screen, one byte at a time
        MOV     AH,ATTRIBUTE    ;Load attribute byte for second pass
        INC     DI              ;Point to next screen postion
        DEC     SI              ;Decrement loop counter
        JNZ     P_WAIT_LOW      ;If not zero, do it one more time
        INC     BX              ;Point to next char in pad
        POP     DX
        RET                     ;Exeunt
PUT_CHAR        ENDP

IO      PROC    NEAR           ;This scans over all screen positions of the pad
        ASSUME  ES:SCREEN               ;Use screen as extra segment
        MOV     BX,SCREEN
        MOV     ES,BX
        MOV     DI,SCREEN_SEG_OFFSET    ;DI will be pointer to screen postion
        ADD     DI,FIRST_POSITION       ;Add width of screen minus pad width
        MOV     BX,PAD_OFFSET           ;BX will be pad location pointer
        MOV     CX,10                   ;There will be 10 lines
LINE_LOOP:      
        MOV     DX,25                   ;And 25 spaces across
CHAR_LOOP:
        CALL    IO_CHAR                 ;Call Put-Char or Get-Char
        DEC     DX                      ;Decrement character loop counter
        JNZ     CHAR_LOOP               ;If not zero, scan over next character
        ADD     DI,FIRST_POSITION       ;Add width of screen minus pad width
        LOOP    LINE_LOOP               ;And now go back to do next line
        RET                             ;Finished
IO      ENDP

LOAD_PAD        PROC    NEAR    ;This procedure intializes everything
        ASSUME  DS:INTERRUPTS   ;The data segment will be the Interrupt area
        MOV     AX,INTERRUPTS
        MOV     DS,AX
        
        MOV     AX,KEYBOARD_INT         ;Get the old interrupt service routine
        MOV     OLD_KEYBOARD_INT,AX     ;address and put it into our location
        MOV     AX,KEYBOARD_INT[2]      ;OLD_KEYBOARD_INT so we can call it.
        MOV     OLD_KEYBOARD_INT[2],AX
        
        MOV     KEYBOARD_INT,OFFSET N_PAD  ;Now load the address of our notepad
        MOV     KEYBOARD_INT[2],CS         ;routine into the keyboard interrupt
                                        
        MOV     AH,15                   ;Ask for service 15 of INT 10H 
        INT     10H                     ;This tells us how display is set up
        SUB     AH,25                   ;Move to twenty places before edge
        SHL     AH,1                    ;Mult by two (char & attribute bytes)
        MOV     BYTE PTR FIRST_POSITION,AH      ;Set screen cursor
        MOV     STATUS_PORT,03BAH        ;Assume this is a monochrome display
        TEST    AL,4                    ;Is it?
        JNZ     EXIT                    ;Yes - jump out
        MOV     SCREEN_SEG_OFFSET,8000H ;No - set up for graphics display
        MOV     STATUS_PORT,03DAH

EXIT:   MOV     DX,OFFSET LOAD_PAD      ;Set up everything but LOAD_PAD to
        INT     27H                     ;stay and attach itself to DOS
LOAD_PAD        ENDP

        CODE_SEG        ENDS
        
        END     FIRST   ;END "FIRST" so 8088 will go to FIRST first.








