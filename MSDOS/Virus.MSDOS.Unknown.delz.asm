INTERRUPTS      SEGMENT AT 0H
        ORG     9H*4            ;holds the address of its service routine
KEYBOARD_INT    LABEL   DWORD  
        ORG     21H*4           ;This is to use INT 21H
INT_21H         LABEL   DWORD   ;which is the DOS function call interrupt
INTERRUPTS      ENDS

ROM_BIOS_DATA   SEGMENT AT 40H  ;BIOS statuses held here, also keyboard buffer

        ORG     1AH
        HEAD DW      ?                  ;Unread chars go from Head to Tail
        TAIL DW      ?
        BUFFER       DW      16 DUP (?)         ;The buffer itself
        BUFFER_END   LABEL   WORD

ROM_BIOS_DATA   ENDS

CODE_SEG        SEGMENT
        ASSUME  CS:CODE_SEG
        ORG     100H            ;ORG = 100H to make this into a 
                                ;".com" file
FIRST:  JMP     LOAD_INT_21H

        COPY_RIGHT      DB      '(C)1985 S Holzner'
        BYPASS_FLAG     DB      0       ;Bypass our checking for #? 1=Yes
        ZERO_FLAG       DB      0       ;Was there a zero in filename? 1=Yes
        CR_FLAG         DB      0
        DTA             DD      ?       ;The old disk transfer area address
        OLD_INT_21H     DD      ?       ;Address INT 21H uses normally
        OLD_KEYBOARD_INT        DD      ?       ;Location of old kbd interrupt
        COUNT           DW      ?
        FCB_OFFSET      DW      ?       ;Offset of given filename to be deleted
        FCB_SEG         DW      0       ;Segment address of the same.        
        COMMAND_INDEX   DW      0
        DEL_Z           DB      'DEL/Z',0
        CRLF    DB      13,10,'$'       ;Carriage return, linefeed for messages
        MSG     DB      ' ZEROED AND DELETED.',13,10,'$'      ;The message
        ERR     DB      'Error deleting $'              ;Error message

DELZ    PROC    FAR    ;The function call interrupt will now come here.

        PUSHF                   ;Save flags first (will get changed by CMPs)
        CMP     AH,13H          ;Are we deleting?
        JNE     JUMP            ;No, jump to function call Int and do not return
        CMP     ZERO_FLAG,1     ;Are we supposed to zero?
        JNE     JUMP            ;If not, don't
        TEST    BYPASS_FLAG,1   ;We are deleting. Is bypass on?
        JZ      DEL_CHECK       ;No, check if we should delete file.
JUMP:   POPF                    ;Restore flags
        JMP     OLD_INT_21H     ;Jump to function call Int. (CALL won't work).
DEL_CHECK:      ;DS:DX are pointing to filename to be deleted (from delete call)
        PUSH    BX              ;Save all used registers to be polite
        PUSH    CX
        PUSH    DX
        PUSH    SI
        PUSH    DI
        PUSH    AX    ;Save AX last since will pop first and return status in it

        MOV     FCB_OFFSET,DX   ;Save address of the file-to-be-deleted's FCB   
        MOV     FCB_SEG,DS      ;Ditto for the segment address

        MOV     AH,2FH          ;Now get Disk Transfer Area (DTA) address
        INT     21H             ;This will work since AH is not equal to 13H

        MOV     DTA,BX          ;Store DTA address Low part
        MOV     DTA[2],ES       ;Ditto High part
        PUSH    DS              ;Save file-to-be-deleted's FCB's Segment address
        MOV     AH,1AH          ;Put the new DTA in our Program Segment Prefix,
        MOV     DX,80H          ; CS:0080H (CS came from INT 21H vector we set)
        PUSH    CS              ;Now move DS into CS to set DTA
        POP     DS
        INT     21H             ;Set Disk Transfer Area (DTA)
        POP     DS              ;Restore Segment address of given file's FCB

        MOV     DX,FCB_OFFSET   ;Restore the given file's FCB's address low part
        MOV     AH,11H          ;Ask for DOS service 11H, which asks for the 
        INT     21H             ; first match to the given file's FCB

        TEST    AL,1            ;Was a match found?
        JZ      TOP             ;Yes, start checking if we should delete.
        POP     AX              ;No, return status 0FF (not found) in AL
        MOV     AL,0FFH
        JMP     NONE_FOUND      ;Over and out.
TOP:    
        MOV     SI,81H          ;the matching file's FCB is in DTA from search
        MOV     DI,0C0H         ;We will move the name to print and scan for #
        MOV     CX,0BH          ;11 characters per file
        PUSH    DS              ;Get ready for string move, set up DS and ES
        PUSH    CS              ;Set them both to CS (use program segment
        POP     DS              ; prefix area)
        MOV     DX,80H          ;Point to match to open file
        MOV     AH,0FH          ;Select the correct DOS call
        INT     21H
        CMP     AL,0            ;If error opening file, exit
        JNE     ERROR
        MOV     BX,80H          ;Set record size to 512
        MOV     WORD PTR [BX+14],512
        MOV     AX,[BX+16]              ;Find the file's size in sectors
        XOR     DX,DX                   
        TEST    AX,511                  ;Do we have to add an add'l sector?
        JZ      SHIF                    ;No, do the shift
        INC     DX                      ;Yes, add 1
SHIF:   MOV     CL,9                    ;Divide by 512
        SHR     AX,CL
        MOV     COUNT,AX                ;Store in Count
        ADD     COUNT,DX                ;And add possible add'l sector
        MOV     AX,[BX+18]              ;Now for the high part of size
        MOV     CL,7                    ;Mult by 65536 div by 512
        SHL     AX,CL
        ADD     COUNT,AX                ;And add to what we already have
        MOV     DX,80H                  ;Now prepare for sequential write
        MOV     CX,COUNT                ;Do COUNT sectors
        MOV     AH,15H
FILL:   INT     21H                     ;Fill with copies of this prog.
        CMP     AL,0                    ;Error writing?
        JNE     ERROR                   ;Yes, jump to ERROR
        LOOP    FILL                    ;No, go back for next one
        MOV     AH,10H                  ;Close the file now.
        INT     21H
        CMP     AL,0                    ;Error closing?
        JNE     ERROR                   ;Yep, go to ERROR
        MOV     AH,13H                  ;No, delete the file at last (Whew)
        MOV     BYPASS_FLAG,1           ;Don't intercept this call
        INT     21H
        MOV     BYPASS_FLAG,0
        CMP     AL,0                    ;Everything OK?
        JNE     ERROR                   ;No, go to ERROR
        CALL    PRINT_NAME              ;Yes, print the name
        LEA     DX,MSG                  ;And the zeroed message
        MOV     AH,9
        INT     21H
        JMP     SAVE
ERROR:  MOV     AH,10H                  ;First make sure file is closed
        INT     21H
        LEA     DX,ERR                  ;Then print error message and go on
        MOV     AH,9                    ; to next file
        INT     21H
        CALL    PRINT_NAME
SAVE:   POP     DS              ;Get segment of original given file's FCB
        MOV     DX,FCB_OFFSET   ;Search for next match -- point to original FCB
        MOV     AH,12H          ;Search for next match
        INT     21H             
        TEST    AL,1            ;Was a match found?
        JNZ     OUT
        JMP     TOP

OUT:    POP     AX              ;At least one file deleted, set AL acordingly,
        MOV     AL,0            ; which means set it to 0
NONE_FOUND:
        PUSH    DS              ;Now we have to reset the Disk Transfer Area
        PUSH    AX              ;Save AX since it contains success status
        MOV     AH,1AH          ;Function call 1AH will do want we want
        MOV     DX,DTA[2]       ;Get original DTA's segment into DS
        MOV     DS,DX
        MOV     DX,DTA          ;Now get offset inside that segment of same
        INT     21H             ;And reset DTA
        POP     AX              ;Restore AX with status
        POP     DS              ;And DS with original DS

        POP     DI              ;And restore the other registers 
        POP     SI
        POP     DX
        POP     CX
        POP     BX
        POPF                    ;We musn't forget our original PUSHF
        IRET                    ;An interrupt deserves an IRET

DELZ    ENDP            ;And that's it 

PRINT_NAME      PROC    NEAR    ;This small subroutine just prints
        MOV     BX,80H+1        ; file's name from the FCB
        MOV     AH,2            ;Use DOS service 2
        MOV     CX,11           ;Print all 11 letters
PRINT:  MOV     DL,[BX]         ;Printing loop
        INT     21H
        INC     BX              ;Get next letter
        LOOP    PRINT
        RET                     ;And return
PRINT_NAME      ENDP

READ_KEY   PROC    NEAR            ;The keyboard interrupt will now come here.
        ASSUME  CS:CODE_SEG
        PUSH    AX              ;Save the used registers for good form
        PUSH    BX
        PUSH    CX
        PUSH    DX
        PUSH    DI
        PUSH    SI
        PUSH    DS
        PUSHF                   ;First, call old keyboard interrupt
        CALL    OLD_KEYBOARD_INT

        ASSUME  DS:ROM_BIOS_DATA        ;Examine the char just put in
        MOV     BX,ROM_BIOS_DATA
        MOV     DS,BX
        MOV     BX,TAIL                 ;Point to current tail
        CMP     BX,HEAD                 ;If at head, kbd int has deleted char
        JNE     CR                      ;So leave 
        JMP     NOCR
CR:     SUB     BX,2                    ;Point to just read in character
        CMP     BX,OFFSET BUFFER        ;Did we undershoot buffer?
        JAE     NO_WRAP                 ;Nope
        MOV     BX,OFFSET BUFFER_END    ;Yes -- move to buffer top
        SUB     BX,2                    
NO_WRAP:MOV     DX,[BX]                 ;Char in DX now

        CMP     DL,'Z'                  ;Make sure we are in upper case
        JBE     CHAROK                  
        SUB     DL,'a'-'A'              ;Make REALLY sure.
CHAROK: PUSH    CS
        POP     DS                      ;Point to Code Seg with DS
        ASSUME  DS:CODE_SEG
        CMP     CR_FLAG,1               ;CR_Flag resets Zero_Flag
        JNE     CHECK
        MOV     CR_FLAG,0               ;Reset CR_Flag
        MOV     ZERO_FLAG,0             ;And Zero_Flag
        MOV     COMMAND_INDEX,0         ;As well as Command_Index
CHECK:  LEA     SI,DEL_Z                ;Check the typed character
        ADD     SI,COMMAND_INDEX        ;Find place in test string
        CMP     DL,[SI]                 ;Match?
        JNE     NOSET                   ;If not, forget it
        INC     COMMAND_INDEX           ;Match! Move to next char next time
        
        CMP     DL,'/'                  ;For DOS 3+, delete the /Z from buffer
        JNE     NOTSLSH
        ASSUME  DS:ROM_BIOS_DATA        ;Examine the char just put in
        MOV     CX,ROM_BIOS_DATA
        MOV     DS,CX
        MOV     TAIL,BX                 ;Erase character from buffer
        MOV     AH,10                   ;Get ready to print the character
        MOV     CX,1
        MOV     AL,DL
        XOR     BX,BX                   ;Display page 0
        INT     10H                     ;Print the '/'
        MOV     AH,3                    ;Now prepare to move cursor over 1
        INT     10H                     ;Get present position
        ADD     DX,1                    ;Add 1
        MOV     AH,2                    ;And reset cursor
        INT     10H

NOTSLSH:CMP     DL,'Z'                  ;For DOS 3+, delete the /Z from buffer
        JNE     NOTZ
        ASSUME  DS:ROM_BIOS_DATA        ;Examine the char just put in
        MOV     CX,ROM_BIOS_DATA
        MOV     DS,CX                   
        MOV     TAIL,BX                 ;Erase character from the buffer
        MOV     AH,10                   ;Prepare to type the 'Z'
        MOV     CX,1                       
        MOV     AL,DL
        XOR     BX,BX
        INT     10H
        MOV     AH,3                    ;And now adjust the cursor
        INT     10H                     ;Moving it to the left 1 space
        ADD     DX,1                    
        MOV     AH,2
        INT     10H

NOTZ:   ASSUME  DS:CODE_SEG
        PUSH    CS
        POP     DS

        CMP     BYTE PTR [SI+1],0
        JNE     NOSET
        MOV     ZERO_FLAG,1
        MOV     COMMAND_INDEX,0
NOSET:  MOV     CR_FLAG,0
        CMP     DX,1C0DH
        JNE     NOCR
        MOV     CR_FLAG,1
NOCR:   POP     DS
        POP     SI
        POP     DI
        POP     DX
        POP     CX
        POP     BX
        POP     AX
        IRET
READ_KEY        ENDP

LOAD_INT_21H   PROC    NEAR     ;This subroutine installs DELZ 

        ASSUME  DS:INTERRUPTS           ;Now set DS to point to INTERRUPTS seg.
        MOV     AX,INTERRUPTS
        MOV     DS,AX

        MOV     AX,KEYBOARD_INT         ;Get the old interrupt service routine
        MOV     OLD_KEYBOARD_INT,AX     ;address and put it into our location
        MOV     AX,KEYBOARD_INT[2]      ;OLD_KEYBOARD_INT so we can call it.
        MOV     OLD_KEYBOARD_INT[2],AX
        
        MOV     KEYBOARD_INT,OFFSET READ_KEY
        MOV     KEYBOARD_INT[2],CS         ;routine into the keyboard interrupt

        MOV     AX,INT_21H              ;Get the original function call INT's
        MOV     OLD_INT_21H,AX          ;address and put it into our location
        MOV     AX,INT_21H[2]           ;OLD_INT_21H so we can still jump there
        MOV     OLD_INT_21H[2],AX
          
        MOV     INT_21H[2],CS           ;Install our delete filter's address
        MOV     INT_21H,OFFSET DELZ     ; as new function call INT

        PUSH    CS                      ;Now point to CS in preparation for
        POP     DS                      ; terminate and stay resident call

        MOV     DX,OFFSET LOAD_INT_21H    ;Set up everything but LOAD_INT_21H to
        INT     27H                       ;stay and attach itself to DOS

LOAD_INT_21H   ENDP                       ;End of loading subroutine

        CODE_SEG        ENDS            ;End of Code Segment
        
        END     FIRST   ;END "FIRST" so 8088 will go to FIRST first.















