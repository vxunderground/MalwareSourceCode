VECTORS SEGMENT AT 0H           ;Set up segment to intercept Interrupts
        ORG     9H*4            ;The keyboard Interrupt
KEYBOARD_INT_VECTOR     LABEL   DWORD
        ORG     1CH*4           ;Timer Interrupt
TIMER_VECTOR      LABEL   DWORD
VECTORS ENDS

ROM_BIOS_DATA   SEGMENT AT 40H  ;The ROM BIOS data area in low memory
        ORG     1AH             ;This is where the keyboard buffer is.
ROM_BUFFER_HEAD DW      ?       ;The position of the buffer's head
ROM_BUFFER_TAIL DW      ?       ;And tail.
KB_BUFFER       DW      16 DUP (?)      ;Reserve space for the buffer itself
KB_BUFFER_END   LABEL   WORD    ;Buffer's end is stored here.        
ROM_BIOS_DATA   ENDS             

CODE_SEG        SEGMENT         ;Begin the Code segment holding the programs
        ASSUME  CS:CODE_SEG
        ORG     100H            ;Com files start at ORG 100H
BEGIN:  JMP     INIT_VECTORS    ;Skip over data area

COPY_RIGHT              DB      '(C) 1984 S. Holzner'   ;The Author's signature
KEYS                    DW      30 DUP(0)       ;The keys we replace
FINISHED_FLAG           DB      1     ;If not finished, timer will stuff buffer 
COMMANDS                DW      1530 DUP(0)    ;Scan and ASCII codes of commands
COMMAND_INDEX           DW      1       ;Stores position in command (for timer)
ROM_KEYBOARD_INT        DD      1       ;Called to interpret keyboard signals
ROM_TIMER               DD      1       ;The Timer interrupt's address

INTERCEPT_KEYBOARD_INT  PROC    NEAR    ;Here it is.             
        ASSUME  DS:NOTHING      ;Free DS
        PUSH    DS              ;Save all used registers
        PUSH    SI
        PUSH    DI
        PUSH    DX
        PUSH    CX
        PUSH    BX
        PUSH    AX
        PUSHF                   ;Pushf for Keyboard Int's IRET
        CALL    ROM_KEYBOARD_INT   ;Have new key put into keyboard buffer
        ASSUME  DS:ROM_BIOS_DATA        ;Set up to point at keyboard buffer.
        MOV     AX,ROM_BIOS_DATA
        MOV     DS,AX
                  
        MOV     BX,ROM_BUFFER_TAIL      ;Was there a character? If Tail equals
        CMP     BX,ROM_BUFFER_HEAD      ; Head then no real character typed.
        JNE     NEWCHAR
        JMP     NO_NEW_CHARACTERS       ;Jump out, no new characters.
NEWCHAR:SUB     BX,2                    ;Move back two bytes from tail;
        CMP     BX,OFFSET KB_BUFFER     ;Do we have to wrap?
        JAE     NO_WRAP                 ;No
        MOV     BX,OFFSET KB_BUFFER_END         ;Wrap by moving two bytes 
        SUB     BX,2                            ; before buffer end.
NO_WRAP:MOV     AX,[BX]                 ;Get the character into AX

        CMP     FINISHED_FLAG,1  ;Done stuffing the buffer with last command?
        JE      FIN                     ;Yes, proceed
        JMP     NO_NEW_CHARACTERS       ;No, leave.

FIN:    MOV     FINISHED_FLAG,1         ;Assume we'll finish

        LEA     SI,KEYS                 ;Point source index at keys to replace
        MOV     CX,30                   ;Loop over all of them
LOOPER: CMP     AX,CS:[SI]              ;Match to given key (in AX)?
        JE      FOUND                   ;Yes, key found, continue on.
        ADD     SI,2                    ;Point to next key to check it.
        LOOP    LOOPER                  ;Go back for next one.
        JMP     NO_NEW_CHARACTERS       ;Loop finished without match - leave.

FOUND:  CLI                     ;Turn off hardware (timer, keyboard) Interrupts
        LEA     SI,COMMANDS     ;Set up to read command
        NEG     CX              ;Find the location of first word of command
        ADD     CX,30
        MOV     AX,CX
        MOV     CX,102
        MUL     CL
        ADD     SI,AX
        MOV     COMMAND_INDEX,SI ;And move it into Command_Index

STUFF:  MOV     AX,CS:[SI]  ;Here we go - get ready to stuff word in buffer.
        ADD     SI,2                    ;Point to the command's next character
        CMP     AX,0                    ;Is it a zero? (End of command)
        JE      NO_NEW_CHARACTERS       ;Yes, leave with Finished_Flag=1
        MOV     DX,BX                   ;Find position in buffer from BX
        ADD     DX,2                    ;Move to next position for this word
        CMP     DX,OFFSET KB_BUFFER_END ;Are we past the end?
        JL      NO_WRAP2                ;No, don't wrap
        MOV     DX,OFFSET KB_BUFFER     ;Wrap
NO_WRAP2:
        CMP     DX,ROM_BUFFER_HEAD      ;Buffer full but not yet done?
        JE      BUFFER_FULL             ;Time to leave, set Finished_Flag=0.
        ADD     COMMAND_INDEX,2         ;Move to next word in command
        MOV     [BX],AX                 ;Put it into the buffer right here.
        ADD     BX,2                    ;Point to next space in buffer
        CMP     BX,OFFSET KB_BUFFER_END ;Wrap here?
        JL      NO_WRAP3                ;No, readjust buffer tail
        MOV     BX,OFFSET KB_BUFFER     ;Yes, wrap
NO_WRAP3: 
        MOV     ROM_BUFFER_TAIL,BX      ;Reset buffer tail
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
        IRET                            ;An interrupt deserves an IRET
INTERCEPT_KEYBOARD_INT  ENDP
        ASSUME  DS:CODE_SEG
INTERCEPT_TIMER   PROC    NEAR          ;This completes filling the buffer
        PUSHF                           ;Store used flags
        PUSH    DS                      ;Save DS since we'll change it
        PUSH    CS                      ;Put current value of CS into DS
        POP     DS
        CALL    ROM_TIMER               ;Make obligatory call
        PUSHF
        CMP     FINISHED_FLAG,1         ;Do we have to do anything?
        JE      OUT                     ;No, leave
        CLI                             ;Yes, start by clearing interrupts
        PUSH    DS                      ;Save these.
        PUSH    SI
        PUSH    DX
        PUSH    BX
        PUSH    AX
        ASSUME  DS:ROM_BIOS_DATA        ;Point to the keyboard buffer again.
        MOV     AX,ROM_BIOS_DATA
        MOV     DS,AX
        MOV     BX,ROM_BUFFER_TAIL      ;Prepare to put charaters in at tail
        MOV     FINISHED_FLAG,1         ;Assume we'll finish
        MOV     SI,COMMAND_INDEX        ;Find where we left ourselves

STUFF2: MOV     AX,CS:[SI]              ;The same stuff loop as above.
        ADD     SI,2                    ;Point to next command character.
        CMP     AX,0                    ;Is it zero? (end of command)
        JNE     OVER                    ;No, continue.
        JMP     NO_NEW_CHARACTERS2      ;Yes, leave with Finished_Flag=1
OVER:   MOV     DX,BX                   ;Find position in buffer from BX
        ADD     DX,2                    ;Move to next position for this word
        CMP     DX,OFFSET KB_BUFFER_END ;Are we past the end?
        JL      NO_WRAP4                ;No, don't wrap
        MOV     DX,OFFSET KB_BUFFER     ;Do the Wrap rap.
NO_WRAP4:                               
        CMP     DX,ROM_BUFFER_HEAD      ;Buffer full but not yet done?
        JE      BUFFER_FULL2            ;Time to leave, come back later.
        ADD     COMMAND_INDEX,2         ;Point to next word of command.
        MOV     [BX],AX                 ;Put into buffer
        ADD     BX,2                    ;Point to next space in buffer
        CMP     BX,OFFSET KB_BUFFER_END ;Wrap here?
        JL      NO_WRAP5                ;No, readjust buffer tail
        MOV     BX,OFFSET KB_BUFFER     ;Yes, wrap
NO_WRAP5:                               
        MOV     ROM_BUFFER_TAIL,BX      ;Reset buffer tail
        JMP     STUFF2                  ;Back to stuff in another character
BUFFER_FULL2:
        MOV     FINISHED_FLAG,0         ;Set flag to not-done-yet.
NO_NEW_CHARACTERS2:
        POP     AX                      ;Restore these.
        POP     BX
        POP     DX
        POP     SI
        POP     DS
OUT:    POPF                            ;And Exit.
        POP     DS
        IRET                            ;With customary IRET
INTERCEPT_TIMER   ENDP

INIT_VECTORS    PROC    NEAR    ;Rest Interrupt vectors here
        ASSUME  DS:VECTORS
        PUSH    DS
        MOV     AX,VECTORS
        MOV     DS,AX
        CLI                     ;Don't allow interrupts
        MOV     AX,KEYBOARD_INT_VECTOR  ;Get and store old interrupt address
        MOV     ROM_KEYBOARD_INT,AX
        MOV     AX,KEYBOARD_INT_VECTOR[2]
        MOV     ROM_KEYBOARD_INT[2],AX

        MOV     KEYBOARD_INT_VECTOR,OFFSET INTERCEPT_KEYBOARD_INT
        MOV     KEYBOARD_INT_VECTOR[2],CS  ;And put ours in place.
        MOV     AX,TIMER_VECTOR         ;Now same for timer
        MOV     ROM_TIMER,AX
        MOV     AX,TIMER_VECTOR[2]
        MOV     ROM_TIMER[2],AX

        MOV     TIMER_VECTOR,OFFSET INTERCEPT_TIMER
        MOV     TIMER_VECTOR[2],CS      ;And intercept that too.
        STI
        ASSUME  DS:ROM_BIOS_DATA
        MOV     AX,ROM_BIOS_DATA
        MOV     DS,AX
        MOV     BX,OFFSET KB_BUFFER     ;Clear the keyboard buffer.
        MOV     ROM_BUFFER_HEAD,BX
        MOV     ROM_BUFFER_TAIL,BX
        MOV     DX,OFFSET INIT_VECTORS  ;Prepare to attach in memory
        INT     27H                     ;And do so.
INIT_VECTORS    ENDP
CODE_SEG        ENDS
        END     BEGIN   ;End Begin so that we jump there first.
