;----------------------------------------------------------------------
;  Fontedit - Loads the current screen font and lets you modify it.
;  Saves font in a COM file with integral loader. Requires EGA or VGA.
;  Syntax:  FONTEDIT [filespec]
;  PC Magazine September 13, 1988
;----------------------------------------------------------------------
_TEXT          SEGMENT PUBLIC 'CODE'
               ASSUME  CS:_TEXT,DS:_TEXT
               ASSUME  ES:_TEXT,SS:_TEXT

               ORG     100H
START:         JMP     MAIN

;              DATA AREA
;              ---------
               DB      CR,SPACE,SPACE,SPACE,CR,LF

COPYRIGHT      DB      "FONTEDIT 1.0 (C) 1988 Ziff Communications Co. ",BOX
PROGRAMMER1    DB      " PC Magazine ",BOX," Michael J. Mefford",0,CTRL_Z

CR             EQU     13
LF             EQU     10
CTRL_Z         EQU     26
SPACE          EQU     32
BOX            EQU     254

ESC_SCAN       EQU     1
ENTER_SCAN     EQU     1CH
UP_ARROW       EQU     48H
DN_ARROW       EQU     50H
LEFT_ARROW     EQU     4BH
RIGHT_ARROW    EQU     4DH
Y_SCAN         EQU     15H
BS_SCAN        EQU     0EH
TAB_CHAR       EQU     9

MAX_POINTS     EQU     16
PIXEL_OFF      EQU     177
PIXEL_ON       EQU     219
EDIT_COL       EQU     32
EDIT_ROW       EQU     8
EDIT_TOP       EQU     EDIT_ROW SHL 8 + EDIT_COL
TEMPLATE_TOP   EQU     EDIT_TOP - 28
CHAR_TOP       EQU     EDIT_TOP + 28
BOX_TOP        EQU     EDIT_TOP + 1 - 400H
INTENSITY      EQU     1000B
MICKEY         EQU     20

BUTTONS        LABEL   WORD
LEFT_BUTTON    DB      0
RIGHT_BUTTON   DB      0
SHIFT_KEYS     EQU     3
SHIFT_STATE    DB      ?

HORIZONTAL     DW      0
VERTICAL       DW      0

NORMAL         EQU     07H
ATTRIBUTE      DB      07H
INVERSE        DB      70H
ROWS           DB      ?
MAX_LINES      DW      16
MOUSE_FLAG     DB      0
MODIFY_FLAG    DB      0
BLANKS         DB      0,32,255
FILE_FLAG      DB      0
FILE_HANDLE    DW      ?
FILENAME       DW      ?
LAST_PIXEL     DB      ?

;format: reg,value    SEQUENCER REGISTERS     GRAPHICS CONTROLLER REGISTERS
;                     MAP MASK   MEMORY MODE  MODE REG    MISC  READ MAP SELECT
ACCESS_A000H   DB     2,4,        4,7,        5,0,        6,4,        4,2
PROTECT_A000H  DB     2,3,        4,3,        5,10H,      6,0AH,      4,0

MENU           LABEL   BYTE
DB "F1 Del row    F2 Ins row    F3 Dup row    F4 Save $"
MENU1          LABEL   BYTE
DB "F5 Copy template char.    Tab = select edit/char box"
DB "   Use: arrow keys or mouse",CR,LF
DB "Hold Shift key or mouse button to drag.    Esc to exit"
DB "     Rows displayed = ",CR,LF
DB "Left button  = pixel on",CR,LF
DB "Right button = pixel off",CR,LF
DB "Space bar = toggle pixel$"
MENU2          LABEL   BYTE
DB "Enter = select char.",0
DB "Button = select char.",0
DB "PgUp/PgDn prev./next char.",0

CAPTIONS       DW      TEMPLATE_TOP - 2
               DB      "Template Char",0
               DW      EDIT_TOP - 2
               DB      "  Edit Char",0
               DW      CHAR_TOP - 2
               DB      "Character Set",0

CURRENT_BOX    DB      218, 5 DUP (196),   194, 5 DUP (196),   191
               DB      179, 5 DUP (SPACE), 179, 5 DUP (SPACE), 179
               DB      192, 5 DUP (196),   193, 5 DUP (196),   217

NOT_ENOUGH     DB      "Not enough memory$"
NOT_SUPPORTED  DB      "Font too tall$"
NOT_EGA_VGA    DB      "Ega/Vga not found$"
SAVE_MSG       DB      CR,LF,"Save ",0
FILE_MSG       DB      "file",0
CREATE_MSG     DB      CR,LF,"Create ",0
EXIST_MSG      DB      CR,LF,"Write over existing ",0
YES_NO         DB      "?  Y/N",0
FAILED_MSG     DB      CR,LF,"Failed$"
FILENAME_MSG   DB      CR,LF,"Enter filename",CR,LF,"$"
NOT_FONT_MSG   DB      " not font$"
COM            DB      ".COM",0
WARNING_MSG    DB      LF,"Warning!  The cursor row will be deleted in"
               DB      " EVERY character in this font.",CR,LF,"Continue$"

DISPATCH_KEY   DB      1,        4BH,      4DH,    48H,     50H,     49H
               DB      51H,      0FH,      39H,    1CH,     3BH,     53H
               DB      3CH,      52H,      3DH,    3EH,     3FH
DISPATCH_CNT   EQU     $ - DISPATCH_KEY

DISPATCH_TABLE DW      EXIT,    LEFT,    RIGHT,     UP,    DOWN,    PGUP
               DW      PGDN,    TAB,     SPACE_BAR, ENTER, DEL_ROW, DEL_ROW
               DW      INS_ROW, INS_ROW, DUP_ROW,   SAVE,  COPY_TEMP
DISPATCH_END   EQU     $ - 2

;              CODE AREA
;              ---------
MAIN           PROC    NEAR

               CLD                             ;All string operations forward.

               MOV     BX,1024                 ;Allocate 1024 paragraphs; 16K.
               MOV     AH,4AH
               INT     21H
               MOV     DX,OFFSET NOT_ENOUGH    ;Exit with message if not enough.
               JC      ERROR_MSG

               MOV     AX,500H                 ;Make sure zero video page.
               INT     10H

               MOV     AX,40H                  ;Point to BIOS data area.
               MOV     ES,AX

               MOV     AX,1A00H                ;Get display info.
               INT     10H
               CMP     AL,1AH                  ;Function supported?
               JNZ     CK_EGA                  ;If no, not VGA; check EGA.
               CMP     BL,7                    ;Else, monochrome VGA?
               JZ      GET_CRT_MODE            ;If yes, OK.
               CMP     BL,8                    ;Else, color VGA?
               JZ      GET_CRT_MODE            ;If yes, OK.

CK_EGA:        MOV     MAX_LINES,14            ;Else, use 14 max lines for EGA.
               MOV     BL,10H                  ;Get EGA information.
               MOV     AH,12H
               INT     10H
               MOV     DX,OFFSET NOT_EGA_VGA
               CMP     BL,10H                  ;Is there an EGA?
               JZ      ERROR_MSG               ;If no, exit with message.
               TEST    ES:BYTE PTR [87H],8     ;Is EGA active?
               JNZ     ERROR_MSG               ;If no, exit with message.

GET_CRT_MODE:  MOV     BL,ES:[49H]             ;Retrieve CRT_MODE.
               CALL    INFORMATION             ;Get font information.
               MOV     DX,OFFSET NOT_SUPPORTED
               CMP     CX,MAX_POINTS           ;Font greater than 16 points?
               JBE     CK_MODE                 ;If no, OK.

ERROR_MSG:     CALL    PRINT_STRING            ;Print error message.
ERROR_EXIT:    MOV     AL,1                    ;ERRORLEVEL = 1
               JMP     TERMINATE               ;Exit.

CK_MODE:       CMP     BL,7                            ;CRT_MODE mono?
               JZ      SAVE_MODE                       ;If yes, skip.
               MOV     BYTE PTR PROTECT_A000H + 7,0EH  ;Else, change parameter.
               CMP     BL,2                            ;Is mode BW80?
               JZ      SAVE_MODE               ;If yes, defaults.
               MOV     ATTRIBUTE,17H           ;Else, use color attributes.       
               MOV     INVERSE,71H
               CMP     BL,3                    ;Are we in CO80?
               JZ      SAVE_MODE               ;If yes, done here.
               MOV     AX,3                    ;Else, change to CO80.
               INT     10H
               MOV     BL,3

SAVE_MODE:     MOV     CRT_MODE,BL             ;Save CRT_MODE in loader.
               CALL    SETUP                   ;Setup the display.

;************************** MAIN LOOP **************************;
; User input dispatcher.  AH = ASCII character; AL = Scan Code. ;
;***************************************************************;

INPUT:         CALL    HIDE_CURSOR             ;Park cursor off screen.
               CALL    GET_INPUT               ;Get some input from user.
               CMP     BUTTONS,0               ;Was a mouse button pressed?
               JZ      CK_ASCII                ;If no, check keyboard input.
               CALL    BUTTON_PRESS            ;Else, process button press.
               JMP     SHORT INPUT             ;Next input.

CK_ASCII:      OR      AL,AL                   ;Scan code zero?
               JZ      ALT_INPUT               ;If yes, ALT keypad entry.
               MOV     DI,OFFSET DISPATCH_KEY  ;Else, check dispatch table.
               MOV     CX,DISPATCH_CNT
               REPNZ   SCASB
               JNZ     ALT_INPUT               ;If no match, keyboard char.
               SHL     CX,1                    ;Else, look up subroutine
               MOV     DI,OFFSET DISPATCH_END
               SUB     DI,CX
               CALL    [DI]                    ; and process command.
               JMP     SHORT INPUT             ;Next input.

ALT_INPUT:     OR      AH,AH                   ;ASCII zero?
               JZ      INPUT                   ;If yes, skip.
               MOV     EDIT_CHAR,AH            ;Else, store as new character.
               CALL    SETUP_END               ;Display new edit character.
               JMP     SHORT INPUT             ;Next input.

;---------------------------------------------------;
; Exit.  If font was modified, prompt user to save. ;
;---------------------------------------------------;

EXIT:          CALL    CLS                     ;Clear the screen.
               CMP     MODIFY_FLAG,1           ;Font modified?
               JNZ     GOOD_EXIT               ;If no, return to DOS.
               MOV     SI,OFFSET FILE_MSG
               CMP     FILE_FLAG,1             ;If there a filename?
               JZ      DO_FILE                 ;If yes, display it.
               MOV     FILENAME,SI             ;Else, display "file".
DO_FILE:       MOV     SI,OFFSET SAVE_MSG
               CALL    PROMPT                  ;Prompt user to save.
               JNZ     GOOD_EXIT               ;If "Y"es not pressed, exit.
               CMP     FILE_FLAG,1             ;Else, is there a filename?
               JZ      DO_SAVE                 ;If yes, save it.
               CALL    GET_NAME                ;Else, get a filename.
               JC      GOOD_EXIT               ;If aborted, exit.

DO_SAVE:       CALL    SAVE_FILE               ;Save the font COM file.

GOOD_EXIT:     CALL    CLS                     ;Clear the screen.
               XOR     AL,AL                   ;ERRORLEVEL zero.
TERMINATE:     MOV     AH,4CH                  ;Return to DOS.
               INT     21H

MAIN           ENDP

;            ***************
;            * SUBROUTINES *
;            ***************

;-------------------------------------------------------------;
; What follows is the user input command processing routines. ;
;-------------------------------------------------------------;

BUTTON_PRESS:  CALL    GET_CURSOR              ;Is cursor in character box?
               JNZ     DO_ENTER                ;If yes, process as if Enter.
               CMP     LEFT_BUTTON,0           ;Else, left button press
               JZ      TURN_OFF                ; will turn on pixel.
               CALL    GET_PIXEL               ;Get the pixel.
               OR      [DI],AH                 ;Turn it on.
               JMP     SHORT BUTTON_END

TURN_OFF:      CALL    GET_PIXEL               ;Right button will turn off pixel
               XOR     AH,0FFH                 ;Invert bit mask.
               AND     [DI],AH                 ;Turn it off.

BUTTON_END:    CALL    UPDATE_CURSOR           ;Update the cursor.
               CALL    LOAD_CHAR               ;Load the character.
               RET

;--------------------------------;

ENTER:         CALL    GET_CURSOR              ;Is cursor in character box?
               JZ      ENTER_END               ;If no, ignore.
DO_ENTER:      CALL    GET_CHAR                ;Else, get the highlighted char.
               MOV     EDIT_CHAR,AL            ;Store it as new edit char.
               CALL    NEW_CHAR                ;Display the edit character.
ENTER_END:     RET

;--------------------------------;

LEFT:          MOV     BP,0FFH                 ;Movement = 0 rows; -1 cols.
               JMP     SHORT ARROWS

RIGHT:         MOV     BP,1                    ;Movement = 0 rows; +1 cols.
               JMP     SHORT ARROWS

UP:            MOV     BP,0FF00H               ;Movement = -1 rows; 0 cols.
               JMP     SHORT ARROWS

DOWN:          MOV     BP,100H                 ;Movement = +1 rows; 0 cols.

ARROWS:        CALL    RESTORE                 ;Restore current cursor position.
               CALL    GET_CURSOR              ;Cursor in edit box?
               MOV     CX,BP
               JNZ     CHAR_ARROW              ;If no, do character movement.
               ADD     CL,CL                   ;Else, double up col. movement.
               CALL    CK_BOUNDS               ;Move cursor; check the boundary.
               SUB     AX,EDIT_TOP             ;AX has position; make relative.
               MOV     EDIT_CURSOR,AX          ;Store as new edit cursor.
               MOV     BH,LAST_PIXEL           ;Retrieve the last pixel.
               CALL    GET_PIXEL               ;Get pixel in new position.
               CMP     SHIFT_STATE,0           ;Button or Shift key depressed?
               JZ      UPDATE_PIXEL2           ;If no, update new cursor pos.

               OR      BH,BH                   ;Else, was last pixel on?
               JNZ     BIT_ON                  ;If yes, drag to new position.
               XOR     AH,0FFH                 ;Else, invert mask
               AND     BYTE PTR [DI],AH;       ; and drag pixel off.
               JMP     SHORT UPDATE_PIXEL1

BIT_ON:        OR      BYTE PTR [DI],AH        ;Turn the pixel on.

UPDATE_PIXEL1: CALL    LOAD_CHAR               ;Load the character.

UPDATE_PIXEL2: CALL    UPDATE_CURSOR           ;Update the cursor display.
               RET

;--------------------------------;

CHAR_ARROW:    CALL    CK_BOUNDS               ;Move cursor; check the boundary.
               SUB     AX,CHAR_TOP             ;Convert to relative position.
               MOV     CHAR_CURSOR,AX          ;Store new character box pos.
               CMP     SHIFT_STATE,0           ;Button or Shift key depressed?
               JZ      CHAR_END                ;If no, done here.
NEW_CHAR:      CALL    GET_CHAR                ;Else, get the character
               MOV     EDIT_CHAR,AL            ; and use as new edit character.
               CALL    DISPLAY_FONT            ;Display it.

CHAR_END:      CALL    UPDATE_CURSOR           ;Update the cursor display.
               RET

;--------------------------------; 

PGUP:          DEC     EDIT_CHAR               ;Next lower edit character.
               JMP     SHORT PAGE_END

PGDN:          INC     EDIT_CHAR               ;Next higher edit character.

PAGE_END:      CALL    SETUP_END               ;Display it.
               RET

;--------------------------------;

TAB:           CALL    RESTORE                 ;Restore current cursor position.
               XOR     EDIT_FLAG,1             ;Toggle Edit/char active box.
               CALL    UPDATE_CURSOR           ;Display cursor in new box.
               RET

;--------------------------------;

SPACE_BAR:     CALL    GET_CURSOR              ;Is cursor in character box?
               JNZ     SPACE_END               ;If yes, ignore.
               CALL    GET_PIXEL               ;Else, get the pixel.
               XOR     [DI],AH                 ;Toggle the pixel.
               CALL    UPDATE_PIXEL1           ;Update character and cursor.
SPACE_END:     RET

;--------------------------------;

DEL_ROW:       CALL    GET_CURSOR              ;Is cursor in character box?
               JNZ     DELETE_RETURN           ;If yes, ignore.
               MOV     BP,POINTS               ;Else, retrieve scan line points.
               CMP     BP,1                    ;Is there only one scan line?
               JZ      DELETE_RETURN           ;If yes, ignore.
               MOV     AL,AH                   ;Else, delete position equals
               XOR     AH,AH                   ; POINTS - relative ROW.
               SUB     BP,AX

               CALL    CLEAR_MENU              ;Clear part of the menu and
               MOV     DX,OFFSET WARNING_MSG   ; display warning message.
               CALL    PRINT_STRING
               CALL    QUERY                   ;Should we delete?
               JNZ     DELETE_END              ;If no, done here.

               MOV     BX,POINTS               ;Else, retrieve bytes/char.
               MOV     SI,OFFSET EDIT_FONT     ;Delete edit font.
               CALL    DELETE
               MOV     SI,OFFSET TEMPLATE_FONT ;Do same to template font.
               CALL    DELETE

               DEC     BX                             ;One less byte/char.
               MOV     BH,BL
               CMP     BYTE PTR EDIT_CURSOR + 1,BL    ;Was last row deleted?
               JNZ     LOAD_IT                        ;If no, OK.
               DEC     BL                             ;Else, move cursor up one
               MOV     BYTE PTR EDIT_CURSOR + 1,BL    ; row so it's on new char.

LOAD_IT:       MOV     BP,OFFSET EDIT_FONT
               CALL    USER_LOAD               ;Load the new font.
               CALL    INFORMATION             ;Get font information.
               MOV     MODIFY_FLAG,1           ;Note that font's been modified.
               CALL    CLS                     ;Clear the old display.
DELETE_END:    XOR     DX,DX
               CALL    SET_CURSOR
               CALL    DISPLAY_COPY            ;Display new font.
DELETE_RETURN: RET

;-----------------;

DELETE:        MOV     DI,SI                   ;Destination starts at source.
               MOV     CX,256                  ;256 characters to do.
NEXT_DELETE:   PUSH    CX                      ;Save character count.
               MOV     CX,BX                   ;BX has bytes/character.
CK_SKIP:       CMP     CX,BP                   ;Is this the row to delete?
               JZ      SKIP_ROW                ;If yes, skip it.
               MOVSB                           ;Else, move it down.
               JMP     SHORT LOOP_DELETE
SKIP_ROW:      INC     SI                      ;Skip deletion row.
LOOP_DELETE:   LOOP    CK_SKIP                 ;Do all character rows.
               POP     CX
               LOOP    NEXT_DELETE             ;Do all 256 characters.
               RET

;--------------------------------;

INS_ROW:       XOR     BL,BL                   ;Insert a zero byte.
               JMP     SHORT INS_EDIT

;--------------------------------;

DUP_ROW:       MOV     BL,-1                   ;Insert a duplicate byte.
INS_EDIT:      CALL    GET_CURSOR              ;Is cursor in character box?
               JNZ     INSERT_END              ;If yes, ignore.
               MOV     BH,AH                   ;Row to be inserted.
               INC     BH                      ;Adjust.
               MOV     BP,POINTS               ;Retrieve bytes/char.
               CMP     BP,MAX_LINES            ;Character maxed out?
               JZ      INSERT_END              ;If yes, done here.
               STD                             ;Else, backward moves.
               MOV     SI,OFFSET EDIT_FONT     ;Insert a row.
               CALL    INSERT
               MOV     SI,OFFSET TEMPLATE_FONT ;Do same to template font.
               CALL    INSERT

               CLD                             ;String operation back forward.
               MOV     BX,BP                   ;Increment bytes/character.
               MOV     BH,BL
               INC     BH
               MOV     BP,OFFSET EDIT_FONT     ;Load the new font.
               CALL    USER_LOAD
               CALL    INFORMATION             ;Get font information.
               MOV     MODIFY_FLAG,1           ;Note that font's been modified.
               CALL    SETUP_END               ;Display new font.
INSERT_END:    RET

;-----------------;

INSERT:        MOV     AX,BP                   ;Go to end of font
               MOV     CX,256                  ; (256 * points) - 1
               MUL     CX
               DEC     AX
               ADD     SI,AX
               MOV     DI,SI
               ADD     DI,CX                   ;New font = old font + 256.

NEXT_INSERT:   PUSH    CX                      ;Save character count.
               MOV     CX,BP                   ;Retrieve bytes/char.
MOVE_BYTE:     MOVSB                           ;Move a byte.
               CMP     CL,BH                   ;Is there an insert row?
               JNZ     LOOP_INSERT
               MOV     AL,BL                   ;If yes, assume zero insert.
               OR      BL,BL                   ;Is zero to be inserted?
               JZ      INSERT_IT               ;If yes, guessed right.
               MOV     AL,[SI+1]               ;Else, duplicate with byte below.
INSERT_IT:     STOSB                           ;Insert it.
LOOP_INSERT:   LOOP    MOVE_BYTE               ;Do all bytes/char.
               POP     CX
               LOOP    NEXT_INSERT             ;Do all 256 characters.
               RET

;--------------------------------;

COPY_TEMP:     CALL    GET_PIXEL               ;Get index to current char.
               MOV     DI,SI                   ;Destination = Source+(16 * 256).
               ADD     SI,MAX_POINTS * 256
               MOV     CX,POINTS               ;Bytes/character to copy.
               REP     MOVSB                   ;Copy them.
               CALL    SETUP_END               ;Update the display.
               CALL    LOAD_CHAR               ;Load the new character.
               RET

;--------------------------------;

SAVE:          CMP     FILE_FLAG,1             ;Is there a filename?
               JZ      SAVE_IT                 ;If yes, save it.
               CALL    CLS                     ;Else, clear screen.
               CALL    GET_NAME                ;Get a filename.
               PUSHF                           ;Save results.
               CALL    DISPLAY_HEAD            ;Redisplay menu.
               POPF                            ;Retrieve results.
               JC      SAVE_END                ;If user aborted, skip save.
SAVE_IT:       CALL    SAVE_FILE               ;Save the file.
SAVE_END:      RET

;*********** END OF COMMAND PROCESSING ROUTINES ***********;

;---------------------------;
; OUTPUT                    ;
;   If Edit cursor, ZF = 1  ;
;   If Char cursor, ZF = 0  ;
;   DX = cursor position.   ;
;   AX = relative position. ;
;---------------------------;

GET_CURSOR:    MOV     AX,EDIT_CURSOR          ;Assume edit cursor; retrieve it.
               MOV     DX,AX                   ;Cursor position = relative
               ADD     DX,EDIT_TOP             ; position + top left of edit box
               CMP     EDIT_FLAG,1             ;Are we in edit box?
               JZ      CURSOR_END              ;If yes, guessed right.
               MOV     AX,CHAR_CURSOR          ;Else, retrieve char. cursor.
               MOV     DX,AX                   ;Calculate cursor position.
               ADD     DX,CHAR_TOP

CURSOR_END:    RET

;---------------------------------------------------;
; Return highlighted cursor position to background. ;
;---------------------------------------------------;

RESTORE:       MOV     BL,ATTRIBUTE            ;Background attribute.
               CALL    GET_CURSOR              ;Is cursor in character box?
               JNZ     CHAR_RESTORE            ;If yes, restore char box.
               CALL    GET_PIXEL               ;Else, get pixel and write.
               CALL    WRITE_PIXEL
               RET

CHAR_RESTORE:  CALL    GET_CHAR                ;Get character and write.
               CALL    WRITE_CHAR
               RET

;--------------------------------;
; Highlight new cursor position. ;
;--------------------------------;

UPDATE_CURSOR: MOV     BL,ATTRIBUTE            ;Retrieve background attribute.
               OR      BL,INTENSITY            ;Turn on intensity bit.
               CALL    GET_CURSOR              ;Is cursor in character box?
               JNZ     DO_CHAR                 ;If yes, do character cursor.

FONT_CURSOR:   CALL    GET_PIXEL               ;Else, get pixel and write it.
               CALL    WRITE_PIXEL
               RET

DO_CHAR:       CALL    GET_CHAR                ;Retrieve character.
               MOV     DI,OFFSET BLANKS        ;Use inverse video for invisible
               MOV     CX,3                    ; characters 0, 32 and 255.
               REPNZ   SCASB
               JNZ     DO_CURSOR
               MOV     BL,INVERSE

DO_CURSOR:     CALL    WRITE_CHAR              ;Update the character cursor.
               RET

;-----------------------------------;
; INPUT                             ;
;   AX = Relative cursor position.  ;
;   DX = Actual cursor position.    ;
;   CX = Direction.                 ;
;                                   ;
; OUTPUT                            ;
;   DX = New cursor position.       ;
;   AX = New cursor position.       ;
;   BX preserved.                   ;
;-----------------------------------;

CK_BOUNDS:     ADD     DH,CH                   ;Add row direction
               ADD     DL,CL                   ; and column direction.
               PUSH    BX                      ;Save BX.
               MOV     BL,16                   ;Use 16 as bounds for char.
               CMP     EDIT_FLAG,1             ; box bottom.
               JNZ     CK_LEFT                 ;Use bytes/char bounds for edit
               MOV     BX,POINTS               ; box bottom.

CK_LEFT:       ADD     AL,CL                   ;Add column to relative pos.
               JGE     CK_RIGHT
               ADD     DL,16                   ;If too far left, 
               JMP     SHORT BOUNDS_END        ; wrap to right.

CK_RIGHT:      CMP     AL,16                   ;If too far right,
               JB      CK_UP
               SUB     DL,16                   ; wrap to left.

CK_UP:         ADD     AH,CH                   ;Add row to relative position.
               JGE     CK_DOWN
               ADD     DH,BL                   ;If too far up,
               JMP     SHORT BOUNDS_END        ; wrap to bottom

CK_DOWN:       CMP     AH,BL                   ;If too far down,
               JB      BOUNDS_END              ; wrap to top.
               MOV     DH,EDIT_ROW

BOUNDS_END:    MOV     AX,DX                   ;Return copy of cursor position.
               POP     BX                      ;Restore BX.
               RET

;----------------------------------;
; INPUT                            ;
;   AX = Relative cursor position. ;
;                                  ;
; OUTPUT                           ;
;   AL = character.                ;
;----------------------------------;

GET_CHAR:      MOV     CL,4                    ;Character = row * 16 + column.
               SHL     AH,CL
               ADD     AL,AH
               RET

;-------------------;
; Font information. ;
;-------------------;

INFORMATION:   MOV     BH,2                    ;Get information.
               MOV     AX,1130H
               INT     10H
               PUSH    CS                      ;Restore extra segment.
               POP     ES
               MOV     POINTS,CX               ;Store bytes/character.
               MOV     ROWS,DL                 ;Store rows on screen.
               RET

;----------------------------------------------------------------;
; Filename is parsed of white space and COM extension tacked on. ;
;----------------------------------------------------------------;

PARSE_FILE:    MOV     SI,81H                  ;Point to parameter.
NEXT_PARSE:    LODSB                           ;Get a byte.
               CMP     AL,SPACE                ;Is it leading space?
               JZ      NEXT_PARSE              ;If yes, ignore.
               CMP     AL,TAB_CHAR             ;Is it leading tab?
               JZ      NEXT_PARSE              ;If yes, ignore.
               DEC     SI                      ;Adjust pointer.
               MOV     FILENAME,SI             ;Store start of filename.

FIND_END:      LODSB                           ;Get a byte.
               CMP     AL,SPACE                ;Is it space or below?
               JBE     PARSE_END               ;If yes, end of filename.
               CMP     AL,"a"                  ;Capitalize.
               JB      CK_DOT
               CMP     AL,"z"
               JA      CK_DOT
               AND     BYTE PTR [SI-1],5FH
CK_DOT:        CMP     AL,"."                  ;Is it a dot?
               JNZ     FIND_END                ;If no, continue.
PARSE_END:     MOV     DI,SI                   ;Else, if dot or end of filename
               DEC     DI                      ; tack on ".COM".
               MOV     SI,OFFSET COM
               MOV     CX,5
               REP     MOVSB
               RET

;-----------------------------;
; OUTPUT                      ;
;   If file exists,    CY = 0 ;
;   If file not found, CY = 1 ;
;-----------------------------;

OPEN_FILE:     MOV     DX,FILENAME
               MOV     AX,3D02H                ;Open file for reading, writing.
               INT     21H
SAVE_HANDLE:   MOV     FILE_HANDLE,AX          ;Save filehandle.
               MOV     BX,AX
               RET

;------------------------;
; OUTPUT                 ;
;   If successful CY = 0 ;
;   If failed     CY = 1 ;
;------------------------;

CREATE_FILE:   MOV     DX,FILENAME
               XOR     CX,CX                   ;Create normal file.
               MOV     AH,3CH
               INT     21H
               JC      CREATE_END
               CALL    SAVE_HANDLE             ;If successful, save filehandle
               CALL    SAVE_FILE               ; and save font file.
CREATE_END:    RET

;-----------------------------------------------------------------------; 
; Read the parsed file.  Check if legitimate font file.  Load the font. ;
;-----------------------------------------------------------------------;

READ_FILE:     MOV     BX,FILE_HANDLE          ;Retrieve filehandle.
               MOV     DX,OFFSET LOADER        ;Point to loader.
               MOV     CX,LOADER_LENGTH        ;Bytes to read.
               MOV     AH,3FH                  ;Read from disk.
               INT     21H
               MOV     SI,OFFSET PROGRAMMER1   ;Use name as legitimate font
               MOV     DI,OFFSET PROGRAMMER2   ; file signature.
               MOV     CX,SIGNATURE_LEN / 2
               REPZ    CMPSW
               JZ      READ_END
               CALL    DISP_FILENAME
               MOV     DX,OFFSET NOT_FONT_MSG  ;If not font file, exit
               JMP     ERROR_MSG               ; with message.

READ_END:      MOV     FILE_FLAG,1             ;Else, note that filename found.
               PUSH    BX                      ;Save filehandle.
               MOV     BP,OFFSET EDIT_FONT     ;Point to font.
               MOV     BH,BYTE PTR POINTS      ;Bytes/character.
               CALL    USER_LOAD               ;Load the font.
               CALL    INFORMATION             ;Get font information.
               POP     BX                      ;Retrieve filehandle.

;--------------------------------;

CLOSE_FILE:    MOV     AH,3EH
               INT     21H
               RET

;--------------------------------;

SAVE_FILE:     CALL    OPEN_FILE               ;Open the file and write
               MOV     DX,OFFSET LOADER        ; font image and loader to disk.
               MOV     CX,LOADER_LENGTH
               MOV     AH,40H
               INT     21H
               MOV     MODIFY_FLAG,0           ;Reset modify flag.
               MOV     FILE_FLAG,1             ;Note that have a filename.
               JMP     SHORT CLOSE_FILE

;-------------------------------; 
; INPUT                         ;
;   SI = first string to write. ;
;                               ;
; OUTPUT                        ;
;   If "Y"es pressed, ZF = 1    ;
;   Else,             ZF = 0    ;
;-------------------------------;

PROMPT:        CALL    TTY_STRING              ;Write preface string.
               CALL    DISP_FILENAME           ;Write filename.
QUERY:         MOV     SI,OFFSET YES_NO        ;Write query string.
               CALL    TTY_STRING
               CALL    GET_KEY                 ;Get a response.
               CMP     AH,Y_SCAN               ;Check if "Y" pressed.
               RET

;-------------------------------; 
; OUTPUT                        ;
;   If name valid,       CY = 0 ;
;   If invalid or abort, CY = 1 ;
;-------------------------------;

GET_NAME:      MOV     DX,OFFSET FILENAME_MSG  ;Ask for filename.
               CALL    PRINT_STRING
               MOV     DI,81H                  ;Use PSP's DTA for input.
NEXT_NAME:     CALL    GET_KEY                 ;Get a keystroke.
               CMP     AH,ESC_SCAN             ;Esc?
               STC
               JZ      NAME_END                ;If yes, abort with CY = 1.
               CMP     AH,LEFT_ARROW           ;Backspace with left arrow
               JZ      DO_BS                   ; or backspace key.
               CMP     AH,BS_SCAN
               JZ      DO_BS
               CMP     AH,ENTER_SCAN           ;If Enter key, done here.
               JZ      STORE_BYTE
               CMP     AL,SPACE                ;Ignore space and below.
               JBE     NEXT_NAME
               JMP     SHORT STORE_BYTE

DO_BS:         DEC     DI                      ;TTY Backspace = the characters
               MOV     AL,8                    ; 8, space and 8.
               PUSH    AX
               CALL    WRITE_TTY
               MOV     AL,SPACE
               CALL    WRITE_TTY
               POP     AX
               JMP     SHORT DISPLAY_BYTE

STORE_BYTE:    STOSB
               CMP     AH,ENTER_SCAN           ;Done if Enter.
               JZ      PARSE_IT
DISPLAY_BYTE:  CALL    WRITE_TTY               ;Echo input to screen.
               JMP     SHORT NEXT_NAME

PARSE_IT:      CALL    PARSE_FILE              ;Parse the filename.
               CALL    OPEN_FILE               ;See if it exists.
               JC      CREATE_IT               ;If no, create it.
               MOV     SI,OFFSET EXIST_MSG     ;Else, ask if should write
               CALL    PROMPT                  ; over existing file.
               JNZ     GET_NAME

CREATE_IT:     CALL    CREATE_FILE             ;Create the file.
               JNC     NAME_END
               MOV     DX,OFFSET FAILED_MSG    ;If failed, inform user
               CALL    PRINT_STRING            ; and ask for new filename.
               JMP     SHORT GET_NAME
NAME_END:      RET

;--------------------------------------;
; OUTPUT                               ;
;   AH = Bit mask                      ;
;   AL = PIXEL_ON or PIXEL_OFF         ;
;   SI = Pointer to start of Character ;
;   DI = Pointer to start of Scan Line ;
;   PIXEL = 0 or -1                    ;
;--------------------------------------;

GET_PIXEL:     MOV     SI,OFFSET EDIT_FONT     ;Point to start of edit font.
               CALL    CHAR_START              ;Index to current character.
               MOV     DI,SI                   ;Also into DI.
               MOV     CX,EDIT_CURSOR          ;Retrieve edit cursor.
               SHR     CL,1                    ;Two col/bit so divide by two.
               MOV     AH,10000000B            ;Bit starts in most significant.
               SHR     AH,CL                   ;Shift bit to column position.
               MOV     CL,CH                   ;Row in CL.
               XOR     CH,CH                   ;Zero in high half.
               ADD     DI,CX                   ;Add to character start.
               MOV     CL,[DI]                 ;Retrieve the current byte.
               MOV     AL,PIXEL_OFF            ;Assume it is off.
               MOV     LAST_PIXEL,0
               AND     CL,AH                   ;AND with bit mask.
               JZ      END_PIXEL               ;If off, guessed right.
               MOV     AL,PIXEL_ON             ;Else, pixel is on.
               MOV     LAST_PIXEL,-1
END_PIXEL:     RET

;--------------------------------;

WRITE_PIXEL:   CALL    WRITE_CHAR              ;Two characters/pixel.
               INC     DL
               CALL    WRITE_CHAR
               INC     DL
               RET

;----------------------------;
; INPUT                      ;
;   SI = Font start.         ;
;                            ;
; OUTPUT                     ;
;   AX = Edit character.     ;
;   SI = Start of character. ;
;----------------------------;

CHAR_START:    MOV     CX,POINTS               ;Retrieve bytes/character.
               MOV     AL,EDIT_CHAR            ;Retrieve edit character.
               XOR     AH,AH                   ;Zero in high half.
               PUSH    AX                      ;Preserve character.
               MUL     CL                      ;Char start = bytes/char * char.
               ADD     SI,AX                   ;Add to index.
               POP     AX                      ;Retrieve character.
               RET

;--------------------------------------------;
; OUTPUT                                     ;
;   AH = ASCII character.                    ;
;   AL = Scan code.                          ;
;   BUTTONS = button pressed.                ;
;   SHIFT_STATE = Shift or button depressed. ;
;--------------------------------------------;

GET_INPUT:     XOR     BP,BP                   ;Store input in BP; start with 0.
               MOV     SHIFT_STATE,0           ;Zero in Shift state.
               MOV     BUTTONS,0               ;Zero in Buttons also.
               CMP     MOUSE_FLAG,1            ;Is the mouse active?
               JNZ     CK_KEYBOARD             ;If no, skip mouse poll.

               XOR     BX,BX                   ;Left button.
               MOV     AX,5                    ;Button press information.
               INT     33H
               OR      SHIFT_STATE,AL          ;Store button depressed info.
               OR      LEFT_BUTTON,BL          ;Store button press info.
               MOV     BX,1                    ;Do same for right button.
               MOV     AX,5
               INT     33H
               OR      RIGHT_BUTTON,BL         ;Store button pressed info.
               CMP     BUTTONS,0               ;Any button pressed?
               JNZ     INPUT_END               ;If yes, done here.

MOUSE_MOTION:  MOV     AX,0BH                  ;Read mouse motion.
               INT     33H
               ADD     CX,HORIZONTAL           ;Add in last horizontal motion.
               ADD     DX,VERTICAL             ; and last vertical motion.
               MOV     AX,MICKEY               ;Retrieve mouse unit of motion.

               MOV     SI,RIGHT_ARROW          ;Assume right movement.
               CMP     CX,AX                   ;Is horizontal > mickey?
               JG      HORIZ                   ;If yes, guessed right.
               MOV     SI,DN_ARROW             ;Assume down movement.
               CMP     DX,AX                   ;Is vertical > mickey?
               JG      VERT                    ;if yes, guessed right.

               NEG     AX                      ;Else, negate mickey.
               MOV     SI,LEFT_ARROW           ;Assume left movement.
               CMP     CX,AX                   ;Is horizontal < mickey?
               JL      HORIZ                   ;If yes, guessed right.
               MOV     SI,UP_ARROW             ;Assume up movement.
               CMP     DX,AX                   ;Is vertical < mickey?
               JGE     STORE_MOTION            ;If yes, guessed right.

VERT:          SUB     DX,AX                   ;Subtract vertical mickey.
               JMP     SHORT STORE_SCAN        ;Update vertical.

HORIZ:         SUB     CX,AX                   ;Subtract horizontal mickey.

STORE_SCAN:    MOV     BP,SI                   ;Store scan code in BP.
STORE_MOTION:  MOV     HORIZONTAL,CX           ;Update movements.
               MOV     VERTICAL,DX

CK_KEYBOARD:   MOV     AH,2                    ;Keyboard Shift state.
               INT     16H
               AND     AL,SHIFT_KEYS           ;Mask off all but Shift keys.
               OR      SHIFT_STATE,AL          ;Store Shift state.

               MOV     AH,1                    ;Keystroke status.
               INT     16H
               JZ      STORE_INPUT             ;If none available, done here.
               CALL    GET_KEY                 ;Else, get keystroke
               XCHG    AL,AH                   ;Exchange scan/ASCII code.
               JMP     SHORT INPUT_END

STORE_INPUT:   MOV     AX,BP                   ;Return input in AX
               OR      AX,AX                   ;Is there input?
               JNZ     INPUT_END               ;If yes, done here.
               CMP     BUTTONS,0               ;Is there button pressed?
               JNZ     INPUT_END               ;If yes, done here.
               JMP     GET_INPUT               ;Else, wait until input.
INPUT_END:     RET

;--------------------------------;

DISPLAY_FONT:  MOV     AL,ROWS                 ;Retrieve rows on screen.
               INC     AL                      ;Zero based; adjust.
               MOV     DX,34EH                 ;Display at Row 2; Col. 77.
               MOV     CX,3                    ;Three bytes to write.
               MOV     BL,ATTRIBUTE            ;Use background attribute.
               CALL    DIVIDE                  ;Display the number.

               MOV     DX,BOX_TOP + 103H       ;Point to inside of info box.
               MOV     AL,EDIT_CHAR            ;Retrieve character.
               CALL    WRITE_CHAR              ;Display it.

               ADD     DL,7                    ;Move to end of number col.
               MOV     CX,3                    ;Three bytes to write.
               CALL    DIVIDE                  ;Display the number.

               MOV     BP,TEMPLATE_TOP         ;Display template character.
               MOV     SI,OFFSET TEMPLATE_FONT
               CALL    UPDATE_FONT

               MOV     BP,EDIT_TOP             ;Display edit character.
               MOV     SI,OFFSET EDIT_FONT

UPDATE_FONT:   CALL    CHAR_START              ;Retrieve index to character.

NEXT_LINE:     LODSB                           ;Get a byte.
               MOV     AH,AL                   ;Store in AH.
               MOV     DI,AX                   ;Store in DI.
               PUSH    CX                      ;Preserve bytes/char.
               MOV     CX,8                    ;Eight bits/byte.
               MOV     DX,BP                   ;Top left of font display.

NEXT_PIXEL:    RCL     DI,1                    ;Get a bit.
               MOV     AL,PIXEL_ON             ;Assume it's on.
               JC      DISPLAY_IT              ;Did bit end up in carry flag?
               MOV     AL,PIXEL_OFF            ;If no, guessed wrong; pixel off.

DISPLAY_IT:    CALL    WRITE_PIXEL             ;Display the pixel.
               LOOP    NEXT_PIXEL              ;Do all 8 pixels.

               ADD     BP,100H                 ;Next display row.
               POP     CX                      ;Retrieve bytes/char.
               LOOP    NEXT_LINE               ;Do all rows.
               RET

;---------------------------;
; INPUT                     ;
;   Entry point = DIVIDE.   ;
;   AL = Number to display. ;
;   BL = Attribute.         ;
;   CX = Places to display. ;
;   DX = Cursor position.   ;
;---------------------------;

NEXT_COUNT:    MOV     AH,SPACE                ;Assume zero.
               OR      AL,AL                   ;Is it a zero?
               JZ      ASCII                   ;If yes, display space instead.
DIVIDE:        MOV     BH,10                   ;Divisor of ten.
               XOR     AH,AH                   ;Zero in high half.
               DIV     BH                      ;Divide by ten.
               ADD     AH,"0"                  ;Convert to ASCII.
ASCII:         XCHG    AL,AH                   ;Remainder in AL.
               CALL    WRITE_CHAR              ;Display it.
               XCHG    AL,AH                   ;Back to AH.
               DEC     DL                      ;Move back one column.
               LOOP    NEXT_COUNT              ;Display all three bytes.
               RET

;---------------------;
; INPUT               ;
;   AL = Character    ;
;   BL = Attribute    ;
;   AX, CX preserved. ;
;---------------------;

WRITE_CHAR:    PUSH    AX
               PUSH    CX
               CALL    SET_CURSOR
               MOV     CX,1
               MOV     AH,9                    ;Write attribute/character.
               INT     10H
               POP     CX
               POP     AX
               RET

;------------------------------------------------------------------------------;
; The Ega/Vga registers are programmed to access segment A000h where the       ;
; fonts are stored.  The font is retrieved and registers reset back to normal. ;
;------------------------------------------------------------------------------;

RETRIEVE_FONT: MOV     SI,OFFSET ACCESS_A000H  ;Point to access parameters.
               CALL    SET_REGISTERS           ;Set the registers.

               MOV     BX,POINTS               ;Retrieve bytes/character.
               MOV     AX,0A000H               ;Point to font segment.
               MOV     DS,AX
               MOV     DI,OFFSET EDIT_FONT     ;Point to destination.
               MOV     BP,256                  ;256 characters.
               XOR     DX,DX                   ;Source starting offset of zero.

NEXT_CHAR:     MOV     SI,DX                   ;Point to source.
               MOV     CX,BX                   ;Bytes/character.
               REP     MOVSB                   ;Retrieve the bytes.
               ADD     DX,20H                  ;Next character two paragraphs.
               DEC     BP                      ;Do all 256 characters.
               JNZ     NEXT_CHAR

               PUSH    CS                      ;Restore data segment.
               POP     DS

               MOV     SI,OFFSET EDIT_FONT     ;Copy the edit font to template.
               MOV     DI,OFFSET TEMPLATE_FONT
               MOV     CX,MAX_POINTS * 256 / 2
               REP     MOVSW

               MOV     SI,OFFSET PROTECT_A000H ;Point to normal parameters.

SET_REGISTERS: MOV     CX,2                    ;Two sequencer registers.
               MOV     DX,3C4H                 ;Indexing register.
               CALL    NEXT_REGISTER

               MOV     CX,3                    ;Three graphics controller regs.
               MOV     DL,0CEH                 ;Indexing registers.
NEXT_REGISTER: LODSB                           ;Get index.
               OUT     DX,AL
               INC     DX
               LODSB                           ;Get value.
               OUT     DX,AL
               DEC     DX
               LOOP    NEXT_REGISTER
               RET

;-----------------------------------------------------;
; Similar to RETRIEVE_FONT procedure except character ;
; is uploaded instead of entire font down loaded.     ;
;-----------------------------------------------------;

LOAD_CHAR:     MOV     SI,OFFSET ACCESS_A000H
               CLI
               CALL    SET_REGISTERS
               MOV     SI,OFFSET EDIT_FONT     ;Point to character
               CALL    CHAR_START              ; to upload.
               PUSH    CX                      ;Preserve bytes/char.
               MOV     CL,5                    ;32 bytes record for A000h font.
               SHL     AX,CL                   ;Index to appropriate character.
               MOV     DI,AX
               POP     CX
               MOV     AX,0A000H               ;Point to font segment.
               MOV     ES,AX
               REP     MOVSB                   ;Upload the bytes.
               PUSH    CS                      ;Restore extra segment.
               POP     ES
               MOV     SI,OFFSET PROTECT_A000H
               CALL    SET_REGISTERS
               STI
               MOV     MODIFY_FLAG,1           ;Note that font modified.
               RET

;--------------------------------;

SET_CURSOR:    PUSH    AX
               XOR     BH,BH
               MOV     AH,2                    ;Set cursor position.
               INT     10H
               POP     AX
               RET

;--------------------------------;

HIDE_CURSOR:   MOV     DH,ROWS
               INC     DH
               XOR     DL,DL                   ;Hide cursor one row below
               CALL    SET_CURSOR              ; displayable rows.
               RET

;--------------------------------;

CLEAR_MENU:    MOV     CX,100H                 ;Row 1; column zero.
               MOV     DX,34FH                 ;Row 3; column 79.
               JMP     SHORT SCROLL

CLS:           XOR     CX,CX                   ;Row zero; column zero.
               MOV     DH,ROWS                 ;Rows.
               MOV     DL,79                   ;Column 79.
SCROLL:        MOV     BH,7                    ;Attribute.
               MOV     AX,600H                 ;Scroll window of active page.
               INT     10H

               XOR     DX,DX
               CALL    SET_CURSOR
               RET

;--------------------------------;

GET_KEY:       XOR     AH,AH
               INT     16H
               RET

;--------------------------------;

PRINT_STRING:  MOV     AH,9
               INT     21H
               RET

;--------------------------------;

DISP_FILENAME: MOV     SI,FILENAME
               JMP     SHORT TTY_STRING

;-----------------;

DO_WRITE:      CALL    WRITE_TTY
TTY_STRING:    LODSB
               OR      AL,AL
               JNZ     DO_WRITE
               RET

;-----------------;

WRITE_TTY:     MOV     AH,0EH
               INT     10H
               RET

;--------------------------------;

DO_CHAR_ATTR:  CALL    WRITE_CHAR
               INC     DL
CHAR_ATTRIB:   LODSB
               OR      AL,AL
               JNZ     DO_CHAR_ATTR
               RET

;--------------------------------;                               

SETUP:         CLI                             ;No interrupts.
               CALL    RETRIEVE_FONT           ;Retrieve font.
               STI                             ;Interrupts back on.
               CMP     BYTE PTR DS:[80H],0     ;Command line parameter?
               JZ      CK_MOUSE                ;If no, skip to mouse.
               CALL    PARSE_FILE              ;Else, parse the parameter.
               CALL    OPEN_FILE               ;Try to open the file.
               JC      CREATE_PROMPT           ;If not found, ask to create.
               CALL    READ_FILE               ;Else, read the file.
               JMP     SHORT CK_MOUSE          ;Done here.

CREATE_PROMPT: MOV     SI,OFFSET CREATE_MSG    ;Display create query.
               CALL    PROMPT
               JZ      CREATE                  ;If got thumbs up, create it.
               JMP     ERROR_EXIT              ;Else, exit.

CREATE:        CALL    CREATE_FILE             ;Create the file.
               MOV     DX,OFFSET FAILED_MSG    ;If failed, exit with message.
               JNC     CK_MOUSE
               JMP     ERROR_MSG

CK_MOUSE:      XOR     AX,AX                   ;Mouse reset and status.
               INT     33H
               OR      AX,AX                   ;Is mouse active?
               JZ      DISPLAY_HEAD            ;If no, skip.
               MOV     MOUSE_FLAG,1            ;Else, flag.

DISPLAY_HEAD:  CALL    CLS                     ;Clear the screen.
DISPLAY_COPY:  MOV     SI,OFFSET COPYRIGHT     ;Display copyright in
               MOV     BL,INVERSE              ; inverse video.
               CALL    CHAR_ATTRIB

               MOV     DX,100H                 ;Row 1; column 0.
               CALL    SET_CURSOR
               MOV     DX,OFFSET MENU          ;Display menu.
               CALL    PRINT_STRING
               CMP     FILE_FLAG,1             ;If filename, display it.
               JNZ     DISPLAY_MENU
               CALL    DISP_FILENAME

DISPLAY_MENU:  MOV     DX,200H                 ;Row 2; column 0.
               CALL    SET_CURSOR
               MOV     DX,OFFSET MENU1         ;Display more menu.
               CALL    PRINT_STRING

               MOV     SI,OFFSET MENU2
               MOV     BL,NORMAL
               MOV     DX,436H
               CALL    CHAR_ATTRIB
               MOV     DX,536H
               CALL    CHAR_ATTRIB
               MOV     DX,636H
               CALL    CHAR_ATTRIB

               MOV     SI,OFFSET CAPTIONS      ;Display three captions.
               MOV     CX,3

NEXT_CAPTION:  LODSW
               MOV     DX,AX                   ;Caption starting cursor pos.
NEXT_CAP:      LODSB
               CMP     AL,0                    ;End of string?
               JZ      END_CAPTION
               CALL    WRITE_CHAR              ;Write the caption.
               INC     DH                      ;Next row.
               JMP     SHORT NEXT_CAP
END_CAPTION:   LOOP    NEXT_CAPTION            ;Do all three captions.

               MOV     BL,ATTRIBUTE            ;Background attribute.
               MOV     SI,OFFSET CURRENT_BOX   ;Display char/ASCII box.
               MOV     DX,BOX_TOP              ;Starting position.
               MOV     BP,3                    ;Three rows.
NEXT_BOX:      MOV     CX,13                   ;13 characters/row.
NEXT_BOX_CHAR: LODSB
               CALL    WRITE_CHAR
               INC     DL                      ;Next column.
               LOOP    NEXT_BOX_CHAR
               MOV     DL,LOW BOX_TOP          ;Starting column.
               INC     DH                      ;Next row.
               DEC     BP
               JNZ     NEXT_BOX

               MOV     DX,CHAR_TOP             ;Display character set.
               XOR     AL,AL                   ;Start with ASCII zero.
NEXT_SET:      MOV     CX,16                   ;16 bytes/row.
NEXT_BYTE:     CALL    WRITE_CHAR
               INC     AL                      ;Next character.
               JZ      SETUP_END
               INC     DL                      ;Next row.
               LOOP    NEXT_BYTE
               MOV     DL,LOW CHAR_TOP         ;Starting column.
               INC     DH
               JMP     NEXT_SET

SETUP_END:     CALL    DISPLAY_FONT            ;Display the edit and template.
               CALL    UPDATE_CURSOR           ;Display the cursor.
               RET

;**************** FONTLOADER ****************;
; This is the code to load the font and      ;
; is followed by the edit and template font  ;
;********************************************;

LOADER         LABEL   BYTE
LOADER_OFFSET  EQU     100H - LOADER

               JMP     BEGINNING

;              DATA AREA
;              ---------
               DB      CR,SPACE,SPACE,SPACE,CR,LF

PROGRAMMER2    DB      " PC Magazine ",BOX," Michael J. Mefford",0,CTRL_Z
SIGNATURE_LEN  EQU     $ - PROGRAMMER2

CRT_MODE       DB      ?
EDIT_CURSOR    DW      102H
CHAR_CURSOR    DW      401H
EDIT_CHAR      DB      65
POINTS         DW      ?
EDIT_FLAG      DB      1

;              CODE AREA
;              ---------

BEGINNING:     MOV     AX,500H                 ;Active page zero
               INT     10H

               MOV     AH,0FH                  ;Current video state.
               INT     10H
               MOV     DI,OFFSET CRT_MODE + LOADER_OFFSET ;Font CRT_MODE.
               MOV     AH,[DI]
               CMP     AL,AH                   ;Same mode?
               JZ      LOAD_FONT               ;If yes, skip.
               MOV     AL,AH                   ;Else, change video mode.
               XOR     AH,AH
               INT     10H

LOAD_FONT:     MOV     BP,OFFSET EDIT_FONT + LOADER_OFFSET
               MOV     DI,OFFSET POINTS + LOADER_OFFSET
               MOV     BH,[DI]
USER_LOAD:     MOV     CX,256
               XOR     DX,DX
               XOR     BL,BL
               MOV     AX,1110H                ;User alpha load.
               INT     10H
               RET                             ;Terminate.

;--------------------------------;

EVEN
EDIT_FONT      LABEL   BYTE
TEMPLATE_FONT  EQU     EDIT_FONT + MAX_POINTS * 256
LOADER_END     EQU     TEMPLATE_FONT + MAX_POINTS * 256
LOADER_LENGTH  EQU     LOADER_END - LOADER

_TEXT          ENDS
               END     START
