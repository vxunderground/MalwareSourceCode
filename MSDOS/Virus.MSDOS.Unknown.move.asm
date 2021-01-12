CODE_SEG        SEGMENT
        ORG     100H                    ;ORG 100H for a .com file
        ASSUME  CS:CODE_SEG,DS:CODE_SEG
FIRST:  JMP     ENTRY                   ;Skip over data area
        COPYRIGHT       DB      '(C) S. HOLZNER 1984'
        TARGET_FCB      DB      37 DUP(0) ;FCB at 6CH will be written over
        END_FLAG        DW      0               ;Flag set after everything read
        FILE_SIZE_LO    DW      0               ;Low word of file size, in bytes
        FILE_SIZE_HI    DW      0               ;High word of same
        FILE_SIZE_K     DW      0               ;Number of Clusters to write
        DTA_OFFSET      DW      0               ;Used for 1K increments into DTA
        COPY_MSG_1      DB      13,10,'Copy $'  ;Part 1 of the copy prompt
        COPY_MSG_2      DB      ' (Y/N)?$'      ;And part 2
        FULL_MSG        DB      13,10,'Disk Full$'      ;Trouble message

MOVE    PROC    NEAR                    ;The main (and only) procedure
ENTRY:  MOV     CX,32                   ;Copy over 1st 32 bytes of default DTA
        MOV     SI,6CH                  ; from 6CH into Target_FCB area for 
        LEA     DI,TARGET_FCB           ; later use as new file name
REP     MOVSB
        MOV     DX,5CH                  ;The source FCB
        MOV     AH,11H                  ;Check if there is match to source file
        INT     21H
        CMP     AL,0FFH                 ;0FFH -> No match
        JNE     QUERY                   ;Match
        JMP     OUT                     ;No Match
QUERY:  MOV     AH,9H                   ;Print out prompt message
        LEA     DX,COPY_MSG_1
        INT     21H
        MOV     CX,11                   ;Print out 11 letters of found file name
        MOV     BX,81H                  ;Point to match in default DTA
        MOV     AH,2
QLOOP:  MOV     DL,[BX]                 ;Get letter of found file's name
        INC     BX                      ;Point to next letter
        INT     21H
        LOOP    QLOOP                   ;Keep going until all 11 printed
        MOV     AH,9H                   ;Print out 2nd half of prompt message
        LEA     DX,COPY_MSG_2
        INT     21H
        MOV     AH,1                    ;Get a 1 character response
        INT     21H
        CMP     AL,'Y'                  ;Was it a 'Y'?
        JE      DO_COPY                 ;Yes, copy the file
        CMP     AL,'y'                  ;No...perhaps a 'y'?
        JE      DO_COPY                 ;Yes, copy the file
        JMP     NEXT                    ;Get next match (if none, leave)
DO_COPY:MOV     CX,37                   ;Using given target file as a template,
        LEA     SI,TARGET_FCB           ; load its 37 characters into the FCB
        MOV     DI,0C0H                 ; for use as real target FCB, checking
        CMP     BYTE PTR [SI+1],' '     ; for wildcards. First, was DRIVE: given
        JNE     NLOOP                   ; as target? No, check wildcards.
        PUSH    DI                      ;Yes, fill Target_FCB with wildcard ?'s 
        PUSH    CX                      ; so found filename will be used
        LEA     DI,TARGET_FCB
        INC     DI
        MOV     CX,11                   ;Put in 11 ?'s
        MOV     AL,'?'
REP     STOSB                           ;Do the fill
        POP     CX                      ;Restore counter and dest. pointer
        POP     DI
NLOOP:  MOV     BX,0                    ;Move given target name into real used
        CMP     BYTE PTR [SI],'?'       ; target FCB at 0C0H. If a wildcard is 
        JNE     CHAR_OK                 ; found in given filename use corres-
        MOV     BX,80H                  ; ponding character in found filename
        SUB     BX,OFFSET TARGET_FCB    ;Wildcard found, adjust source (SI) to
        ADD     SI,BX                   ; point to the found filename
CHAR_OK:MOVS    [DI],[SI]
        SUB     SI,BX                   ;Restore SI if necessary
        LOOP    NLOOP                   ;Loop back until for all 11 name char.s
        MOV     DX,80H                  ;Target FCB now at 0C0H, source at 80H
        MOV     AH,0FH                  ;Use DOS service 15 to open source
        INT     21H                     ;Open source FCB
        MOV     DX,0C0H                 ;Use DOS service 12 to create target
        MOV     AH,16H
        INT     21H                     ;Create target FCB (or if the file 
        AND     END_FLAG,0              ; already exists, zero it and refill it)
        MOV     BX,80H + 14
        MOV     WORD PTR [BX],8000H     ;Set record size for source (32K)
        MOV     BX,80H + 16             ;Get file size from opened source FCB
        MOV     AX,[BX]
        MOV     FILE_SIZE_LO,AX         ;Store low word of size in FILE_SIZE_LO
        ADD     BX,2                    ;Point to high word
        MOV     DX,[BX]
        MOV     FILE_SIZE_HI,DX         ;Store high word of size in FILE_SIZE_HI
        MOV     CX,1024                 ;Div DX:AX (High:Low of size) by 1024
        DIV     CX
        MOV     FILE_SIZE_K,AX          ;Get file size in rounded-up K (1024)
        TEST    DX,0FFFFH               ;Was it an even K file:Mod(size,1024)=0?
        JZ      ROUND                   ;Yes, don't add cluster for file remnant
        INC     FILE_SIZE_K             ;No, add 1 more cluster for remainder
ROUND:  MOV     BX,0C0H + 14
        MOV     WORD PTR [BX],400H      ;Set record size for target (1K)
READ:   LEA     DX,DATA_POINT           ;Set up the 32K DTA we'll use
        MOV     AH,1AH                  ; at the end of this program
        INT     21H                     
        MOV     DX,80H                  ;Point to source FCB to prepare for read
        MOV     AH,14H
        INT     21H                     ;Do the read of 32K bytes
        CMP     AL,0                    ;AL = 0 if end of file not yet reached
        JLE     READ_OK
        OR      END_FLAG,1              ;Have read in the whole file, DTA is
READ_OK:MOV     CX,20H                  ; stuffed with zeroes after end of file
        LEA     DX,DATA_POINT           ;Reset our offset into 32K DTA to the
        MOV     DTA_OFFSET,DX           ; start
WLOOP:  MOV     DX,0C0H                 ;Point to target FCB, prepare for write
        MOV     AH,15H
        INT     21H                     ;Do the write 1K at a time
        CMP     AL,0                    ;Was the write a success?
        JE      COPY_OK                 ;Yes, check if done writing
        LEA     DX,FULL_MSG             ;No, assume the disk was full and say so
        MOV     AH,9H                   ;Print error string
        INT     21H
        JMP     OUT                     ;Exit 
COPY_OK:DEC     FILE_SIZE_K             ;Decrement number of clusters to write
        JZ      FINISH                  ;Done?
        ADD     DTA_OFFSET,400H         ;No, point to next 1K chunk of DTA
        MOV     DX,DTA_OFFSET           
        MOV     AH,1AH                  ;Set DTA to match
        INT     21H
        LOOP    WLOOP                   ;Repeat until 32K written or end of file
        TEST    END_FLAG,1              ;Have we read in the end of file?
        JZ      READ                    ;No, get next 32K block from source
FINISH: MOV     AX,FILE_SIZE_LO         ;Now adjust written file's size
        MOV     BX,0C0H + 16            ;Point to low word of size
        MOV     WORD PTR [BX],AX        ;And set it to the correct value
        ADD     BX,2                    ;Point to high word of size
        MOV     AX,FILE_SIZE_HI         ;And set it too
        MOV     WORD PTR [BX],AX
        MOV     AH,10H                  ;Request DOS service 16, close files
        MOV     DX,0C0H                 ;Point to target file's FCB
        INT     21H                     ;Close target with correct size
        MOV     DX,80H                  ;Point to source file's FCB
        INT     21H                     ;Close source
NEXT:   MOV     DX,80H                  ;Start looking for the next match
        MOV     AH,1AH          ;First, reset DTA to 80H for found file's FCB
        INT     21H             
        MOV     AH,12H                  ;Now search for next match-service 18
        MOV     DX,5CH                  ;Use given filename to match to
        INT     21H
        CMP     AL,0                    ;Match found?
        JNE     OUT                     ;No, exit.
        JMP     QUERY                   ;Yes, ask if it should be copied
OUT:    RET

MOVE    ENDP
DATA_POINT:                             ;The 32K DTA starts here
CODE_SEG        ENDS
        END     FIRST                   ;'END FIRST' so entry point set to FIRST

