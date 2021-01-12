VECTORS SEGMENT AT 0H           ;Set up segment to intercept Interrupts
        ORG     9H*4            ;The keyboard Interrupt
KEYBOARD_INT     LABEL   DWORD
        ORG     1CH*4           ;Timer Interrupt
TIMER_VECTOR      LABEL   DWORD
VECTORS ENDS

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
FIRST:  JMP     LOAD_KEEPER        ;First time through 

        COPY_RIGHT      DB      '(C)1985 S.HOLZNER' ;Ascii autograph
        PAD             DB      20*102 DUP(0)       ;Memory storage for pad  
        PAD_CURSOR      DW      9*102               ;Current position in pad
        ATTRIBUTE       DB      112             ;Pad Attribute -- reverse video
        LINE_ATTRIBUTE  DB      240             ;Flashing Rev video
        OLD_ATTRIBUTE   DB      7               ;Original screen attrib: normal
        PAD_OFFSET      DW      0               ;Chooses 1st 250 bytes or 2nd
        FIRST_POSITION  DW      ?               ;Position of 1st char on screen
        TRIGGER_FLAG    DW      0               ;Trigger on or off
        FULL_FLAG       DB      0               ;Buffer Full Flag
        LINE            DW      9               ;Line number, 0-9
        SCREEN_SEG_OFFSET       DW      0       ;0 for mono, 8000H for graphics
        IO_CHAR         DW      ?               ;Holds addr of Put or Get_Char
        STATUS_PORT     DW      ?               ;Video controller status port
        OLD_KEYBOARD_INT        DD      ?       ;Location of old kbd interrupt
        FINISHED_FLAG           DB      1       ;If not finished,f buffer 
        COMMAND_INDEX           DW      1       ;Stores positior timer)
        ROM_TIMER               DD      1       ;The Timer interrupt's address
        OLD_HEAD        DW      0

KEEPER   PROC    NEAR            ;The keyboard interrupt will now come here.
        ASSUME  CS:CODE_SEG
        PUSH    AX              ;Save the used registers for good form
        PUSH    BX
        PUSH    CX
        PUSH    DX
        PUSH    DI
        PUSH    SI
        PUSH    DS
        PUSH    ES
        PUSHF                           ;First, call old keyboard interrupt
        CALL    OLD_KEYBOARD_INT
        ASSUME  DS:ROM_BIOS_DATA        ;Examine the char just put in
        MOV     BX,ROM_BIOS_DATA
        MOV     DS,BX
        MOV     BX,TAIL                 ;Point to current tail
        CMP     BX,HEAD                 ;If at head, kbd int has deleted char
        JE      BYE                     ;So leave 
        MOV     DX,HEAD
        SUB     DX,2                    ;Point to just read in character
        CMP     DX,OFFSET BUFFER        ;Did we undershoot buffer?
        JAE     NOWRAP                  ;Nope
        MOV     DX,OFFSET BUFFER_END    ;Yes -- move to buffer top
        SUB     DX,2                    ;Compare two bytes back from head
NOWRAP: CMP     DX,TAIL                 ;If it's the tail, buffer is full
        JNE     NOTFULL                 ;We're OK, jump to NotFull
        CMP     FULL_FLAG,1             ;Check if keyboard buffer full
        JE      BYE                     ;Yep, leave
        MOV     FULL_FLAG,1             ;Oops, full, set flag and take
        JMP     CHK                     ; this last character
NOTFULL:MOV     FULL_FLAG,0             ;Always reset Full_Flag when buff clears
CHK:    CMP     TRIGGER_FLAG,0          ;Is the window on (triggered?)
        JNE     SUBT                    ;Yep, keep going
        MOV     DX,OLD_HEAD             ;Check position of buffer head
        CMP     DX,HEAD
        JNE     CONT
        MOV     OLD_HEAD,0
BYE:    JMP     OUT
CONT:   MOV     DX,HEAD
        MOV     OLD_HEAD,DX
SUBT:   SUB     BX,2                    ;Point to just read in character
        CMP     BX,OFFSET BUFFER        ;Did we undershoot buffer?
        JAE     NO_WRAP                 ;Nope
        MOV     BX,OFFSET BUFFER_END    ;Yes -- move to buffer top
        SUB     BX,2                    ;
NO_WRAP:MOV     DX,[BX]                 ;Char in DX now        
        ;------ CHAR IN DX NOW -------
        CMP     FINISHED_FLAG,0
        JE      IN             
        CMP     DX,310EH                ;Default trigger is a ^N here.
        JNE     NOT_TRIGGER             ;No
        MOV     TAIL,BX
        NOT     TRIGGER_FLAG            ;Switch Modes
        CMP     TRIGGER_FLAG,0          ;Trigger off?
        JNE     TRIGGER_ON              ;No, only other choice is on
TRIGGER_OFF:
        MOV     OLD_HEAD,0              ;Reset old head
        MOV     AH,OLD_ATTRIBUTE        ;Get ready to restore screen
        MOV     ATTRIBUTE,AH            ;Pad and blinking line set to orig.
        MOV     LINE_ATTRIBUTE,AH       ; values
        MOV     PAD_OFFSET,10*102       ;Point to 2nd half of pad
        LEA     AX,PUT_CHAR             ;Make IO call Put_Char as it scans
        MOV     IO_CHAR,AX              ;over all locations in pad on screen
        CALL    IO                      ;Restore screen
        CMP     LINE,9                  ;Was the window turned off without
        JE      IN                      ; using up-down keys? If so, exit
        MOV     AX,LINE                 ;No, there is a line to stuff in
        MOV     CL,102                  ; keyboard buffer
        MUL     CL                      ;Find its location in Pad
        MOV     COMMAND_INDEX,AX        ;And send to Put
        CALL    PUT                     ;Which will do actual stuffing
IN:     JMP     OUT                     ;Done
TRIGGER_ON:                             ;Window just turned on
        MOV     LINE,9                  ;Set blinking line to bottom
        MOV     PAD_OFFSET,10*102       ;Point to screen storage part of pad
        LEA     AX,GET_CHAR             ;Make IO use Get_char so current screen
        MOV     IO_CHAR,AX              ;is stored
        CALL    IO                      ;Store Screen
        CALL    DISPLAY                 ;And put up the pad
        JMP     OUT                     ;Done here.
NOT_TRIGGER:
        TEST    TRIGGER_FLAG,1          ;Is Trigger on?
        JZ      RUBOUT_TEST
        MOV     TAIL,BX                 ;Yes, delete this char from buffer
UP:     CMP     DX,4800H                ;An Up cursor key?
        JNE     DOWN                    ;No, try Down
        DEC     LINE                    ;Move blinker up one line
        CMP     LINE,0                  ;At top? If so, reset
        JGE     NOT_TOP
        MOV     LINE,9
NOT_TOP:CALL    DISPLAY                 ;Display result
        JMP     OUT                     ;And leave
DOWN:   CMP     DX,5000H                ;Perhaps Down cusor key pushed
        JNE     IN                      ;If not, ignore key
        INC     LINE                    ;If so, move down one
        CMP     LINE,9                  ;If at bottom, wrap to top
        JLE     NOT_BOT
        MOV     LINE,0
NOT_BOT:CALL    DISPLAY                 ;Show results
        JMP     OUT                     ;And exit
RUBOUT_TEST:
        CMP     DX,0E08H                ;Is it a Rubout?
        JNE     CHAR_TEST               ;No -- try carriage return-line feed
        MOV     BX,PAD_CURSOR           ;Yes -- get current pad location
        CMP     BX,9*102                ;Are we at beginning of last line?
        JLE     NEVER_MIND              ;Yes -- can't rubout past beginning
        SUB     PAD_CURSOR,2            ;No, rubout this char
        MOV     PAD[BX-2],20H           ;Move a space in instead (3920H)
        MOV     PAD[BX-1],39H
NEVER_MIND:
        JMP     OUT                     ;Done here.
CHAR_TEST:
        CMP     DL,13                   ;Is this a carriage return?
        JE      PLUG                    ;If yes, plug this line into Pad
        CMP     DL,32                   ;If this char < Ascii 32, delete line
        JGE     PLUG
        MOV     PAD_CURSOR,9*102        ;Clear the current line
        MOV     CX,51
        MOV     BX,9*102
CLEAR:  MOV     WORD PTR PAD[BX],0
        ADD     BX,2
        LOOP    CLEAR
        JMP     OUT                     ;And exit

PLUG:   MOV     BX,PAD_CURSOR           ;Get current pad location
        CMP     BX,10*102-2             ;Are we past the end of the pad?
        JGE     CRLF_TEST               ;Yes -- throw away char
        MOV     WORD PTR PAD[BX],DX     ;No -- move ASCII code into pad
        ADD     PAD_CURSOR,2            ;Increment pad location
CRLF_TEST:
        CMP     DX,1C0DH                ;Is it a carriage return-line feed?
        JNE     OUT                     ;No -- put it in the pad
        CALL    CRLF                    ;Yes -- move everything up in pad
OUT:    POP     ES                      ;Having done Pushes, here are the Pops
        POP     DS
        POP     SI
        POP     DI
        POP     DX
        POP     CX
        POP     BX
        POP     AX     
        IRET                    ;An interrupt needs an IRET
KEEPER   ENDP

DISPLAY PROC    NEAR                    ;Puts the whole pad on the screen
        PUSH    AX
        MOV     ATTRIBUTE,112           ;Use reverse video
        MOV     LINE_ATTRIBUTE,240
        MOV     PAD_OFFSET,0            ;Use 1st 250 bytes of pad memory
        LEA     AX,PUT_CHAR             ;Make IO use Put-Char so it does
        MOV     IO_CHAR,AX              
        CALL    IO                      ;Put result on screen
        POP     AX
        RET                             ;Leave
DISPLAY ENDP

CRLF    PROC    NEAR                    ;This handles carriage returns
        PUSH    BX                      ;Push everything conceivable
        PUSH    CX           
        PUSH    DI
        PUSH    SI
        PUSH    DS
        PUSH    ES   
        ASSUME  DS:CODE_SEG             ;Set DS to Code_Seg here
        PUSH    CS
        POP     DS
        ASSUME  ES:CODE_SEG             ;And ES too
        PUSH    DS
        POP     ES
        LEA     DI,PAD                  ;Get ready to move contents of Pad
        MOV     SI,DI                   ; up one line
        ADD     SI,102                  ;DI-top line, SI-one below top line
        MOV     CX,9*51
        MOV     BX,PAD_CURSOR           ;But first finish line with a 0        
        CMP     BX,9*102+2              ; as a flag letting Put know line is
        JE      POPS                    ; done.
        MOV     WORD PTR PAD[BX],0
REP     MOVSW                           ;Move up Pad contents
        MOV     CX,51                   ;Now fill the last line with spaces
        MOV     AX,3920H
REP     STOSW                           ;Using Stosw
POPS:   MOV     PAD_CURSOR,9*102        ;And finally reset Cursor to beginning
        POP     ES                      ; of the last line again.
        POP     DS
        POP     SI
        POP     DI
        POP     CX
        POP     BX
DONE:   RET                             ;And out.
CRLF    ENDP

GET_CHAR        PROC    NEAR    ;Gets a char from screen and advances position
        ASSUME  ES:SCREEN,DS:ROM_BIOS_DATA
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
LEAVE:  MOV     OLD_ATTRIBUTE,AH
        ADD     BX,2
        POP     DX
        RET
GET_CHAR        ENDP

PUT_CHAR        PROC    NEAR    ;Puts one char on screen and advances position
        PUSH    DX
        MOV     AH,PAD[BX]      ;Get the char to be put onto the screen
        CMP     AH,32
        JAE     GO
        MOV     AH,32
GO:     MOV     SI,2            ;Loop twice, once for char, once for attribute
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
        ADD     BX,2
        POP     DX
        RET                     ;Exeunt
PUT_CHAR        ENDP

IO      PROC    NEAR            ;This scans over all screen positions of the pad
        ASSUME  ES:SCREEN       ;Use screen as extra segment
        MOV     BX,SCREEN
        MOV     ES,BX
        
        PUSH    DS
        MOV     BX,ROM_BIOS_DATA
        MOV     DS,BX
        MOV     BX,4AH
        MOV     BX,DS:[BX]
        SUB     BX,51
        ADD     BX,BX
        MOV     FIRST_POSITION,BX
        POP     DS

        MOV     DI,SCREEN_SEG_OFFSET    ;DI will be pointer to screen postion
        ADD     DI,FIRST_POSITION       ;Add width of screen minus pad width
        MOV     BX,PAD_OFFSET           ;BX will be pad location pointer
        MOV     CX,10                   ;There will be 10 lines

LINE_LOOP:      
        PUSH    WORD PTR ATTRIBUTE
        PUSH    CX                      ;Figure out whether this is blinking 
        NEG     CX                      ; line and if so, temporarily change
        ADD     CX,10                   ; display attribute
        CMP     CX,LINE
        JNE     NOLINE
        MOV     CL,LINE_ATTRIBUTE
        MOV     ATTRIBUTE,CL
NOLINE: POP     CX
        MOV     DX,51                   ;And 51 spaces across
CHAR_LOOP:
        CALL    IO_CHAR                 ;Call Put-Char or Get-Char
        DEC     DX                      ;Decrement character loop counter
        JNZ     CHAR_LOOP               ;If not zero, scan over next character
        ADD     DI,FIRST_POSITION       ;Add width of screen minus pad width
                         
        POP     WORD PTR ATTRIBUTE
        LOOP    LINE_LOOP               ;And now go back to do next line
        RET                             ;Finished
IO      ENDP

PUT  PROC    NEAR    ;Here it is.             
        ASSUME  DS:ROM_BIOS_DATA      ;Free DS
        PUSH    DS                    ;Save all used registers
        PUSH    SI
        PUSH    DI
        PUSH    DX
        PUSH    CX
        PUSH    BX
        PUSH    AX
        MOV     AX,ROM_BIOS_DATA        ;Just to make sure
        MOV     DS,AX                   ;Set DS correctly
FIN:    MOV     FINISHED_FLAG,1         ;Assume we'll finish
        MOV     BX,TAIL                 ;Prepare to move to buffer's tail
        MOV     SI,COMMAND_INDEX        ;Get our source index

STUFF:  MOV     AX,WORD PTR PAD[SI]
        ADD     SI,2                    ;Point to the command's next character
        CMP     AX,0                    ;Is it a zero? (End of command)
        JE      NO_NEW_CHARACTERS       ;Yes, leave with Finished_Flag=1
        MOV     DX,BX                   ;Find position in buffer from BX
        ADD     DX,2                    ;Move to next position for this word
        CMP     DX,OFFSET BUFFER_END ;Are we past the end?
        JL      NO_WRAP2                ;No, don't wrap
        MOV     DX,OFFSET BUFFER        ;Wrap
NO_WRAP2:
        CMP     DX,HEAD                 ;Buffer full but not yet done?
        JE      BUFFER_FULL             ;Time to leave, set Finished_Flag=0.
        ADD     COMMAND_INDEX,2         ;Move to next word in command
        MOV     [BX],AX                 ;Put it into the buffer right here.
        ADD     BX,2                    ;Point to next space in buffer
        CMP     BX,OFFSET BUFFER_END ;Wrap here?
        JL      NO_WRAP3                ;No, readjust buffer tail
        MOV     BX,OFFSET BUFFER        ;Yes, wrap
NO_WRAP3: 
        MOV     TAIL,BX                 ;Reset buffer tail
        JMP     STUFF                   ;Back to stuff in another character.
BUFFER_FULL:                            ;If buffer is full, let timer take over
        MOV     FINISHED_FLAG,0         ; by setting Finished_Flag to 0.
NO_NEW_CHARACTERS:
        POP     AX                      ;Restore everything before departure.
        POP     BX
        POP     CX
        POP     DX
        POP     DI
        POP     SI
        POP     DS
        STI
        RET
PUT  ENDP

        ASSUME  DS:CODE_SEG
INTERCEPT_TIMER   PROC    NEAR          ;This completes filling the buffer
        PUSHF                           ;Store used flags
        PUSH    DS                      ;Save DS since we'll change it
        PUSH    CS                      ;Put current value of CS into DS
        POP     DS
        CALL    ROM_TIMER               ;Make obligatory call
        PUSHF
        CMP     FINISHED_FLAG,1         ;Do we have to do anything?
        JE      OUT1                     ;No, leave
        CLI                             ;Yes, start by clearing interrupts
        PUSH    DS                      ;Save these.
        PUSH    SI
        PUSH    DX
        PUSH    BX
        PUSH    AX
        ASSUME  DS:ROM_BIOS_DATA        ;Point to the keyboard buffer again.
        MOV     AX,ROM_BIOS_DATA
        MOV     DS,AX
        MOV     BX,TAIL                 ;Prepare to put characters in at tail
        MOV     FINISHED_FLAG,1         ;Assume we'll finish
        MOV     SI,COMMAND_INDEX        ;Find where we left ourselves

STUFF2: MOV     AX,WORD PTR PAD[SI]     ;The same stuff loop as above.
        ADD     SI,2                    ;Point to next command character.
        CMP     AX,0                    ;Is it zero? (end of command)
        JNE     OVER                    ;No, continue.
        JMP     NO_NEW_CHARACTERS2      ;Yes, leave with Finished_Flag=1
OVER:   MOV     DX,BX                   ;Find position in buffer from BX
        ADD     DX,2                    ;Move to next position for this word
        CMP     DX,OFFSET BUFFER_END    ;Are we past the end?
        JL      NO_WRAP4                ;No, don't wrap
        MOV     DX,OFFSET BUFFER        ;Do the Wrap rap.
NO_WRAP4:                               
        CMP     DX,HEAD                 ;Buffer full but not yet done?
        JE      BUFFER_FULL2            ;Time to leave, come back later.
        ADD     COMMAND_INDEX,2         ;Point to next word of command.
        MOV     [BX],AX                 ;Put into buffer
        ADD     BX,2                    ;Point to next space in buffer
        CMP     BX,OFFSET BUFFER_END    ;Wrap here?
        JL      NO_WRAP5                ;No, readjust buffer tail
        MOV     BX,OFFSET BUFFER        ;Yes, wrap
NO_WRAP5:                               
        MOV     TAIL,BX                 ;Reset buffer tail
        JMP     STUFF2                  ;Back to stuff in another character
BUFFER_FULL2:
        MOV     FINISHED_FLAG,0         ;Set flag to not-done-yet.
NO_NEW_CHARACTERS2:
        POP     AX                      ;Restore these.
        POP     BX
        POP     DX
        POP     SI
        POP     DS
OUT1:   POPF                            ;And Exit.
        POP     DS
        IRET                            ;With customary IRET
INTERCEPT_TIMER   ENDP

LOAD_KEEPER        PROC    NEAR    ;This procedure intializes everything
        ASSUME  DS:VECTORS   ;The data segment will be the Interrupt area
        MOV     AX,VECTORS
        MOV     DS,AX
        
        MOV     AX,KEYBOARD_INT         ;Get the old interrupt service routine
        MOV     OLD_KEYBOARD_INT,AX     ;address and put it into our location
        MOV     AX,KEYBOARD_INT[2]      ;OLD_KEYBOARD_INT so we can call it.
        MOV     OLD_KEYBOARD_INT[2],AX
        
        MOV     KEYBOARD_INT,OFFSET KEEPER  ;Now load the address of our notepad
        MOV     KEYBOARD_INT[2],CS         ;routine into the keyboard interrupt
                                        
        MOV     AX,TIMER_VECTOR         ;Now same for timer
        MOV     ROM_TIMER,AX
        MOV     AX,TIMER_VECTOR[2]
        MOV     ROM_TIMER[2],AX

        MOV     TIMER_VECTOR,OFFSET INTERCEPT_TIMER
        MOV     TIMER_VECTOR[2],CS      ;And intercept that too.

        ASSUME  DS:ROM_BIOS_DATA
        MOV     AX,ROM_BIOS_DATA
        MOV     DS,AX
        MOV     BX,OFFSET BUFFER     ;Clear the keyboard buffer.
        MOV     HEAD,BX
        MOV     TAIL,BX
        MOV     AH,15                   ;Ask for service 15 of INT 10H 
        INT     10H                     ;This tells us how display is set up
        MOV     STATUS_PORT,03BAH        ;Assume this is a monochrome display
        TEST    AL,4                    ;Is it?
        JNZ     EXIT                    ;Yes - jump out
        MOV     SCREEN_SEG_OFFSET,8000H ;No - set up for graphics display
        MOV     STATUS_PORT,03DAH

EXIT:   MOV     DX,OFFSET LOAD_KEEPER      ;Set up everything but LOAD_PAD to
        INT     27H                     ;stay and attach itself to DOS
LOAD_KEEPER        ENDP

        CODE_SEG        ENDS
        
        END     FIRST   ;END "FIRST" so 8088 will go to FIRST first.



