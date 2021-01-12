CODE_SEG        SEGMENT
        ASSUME  CS:CODE_SEG,DS:CODE_SEG,ES:CODE_SEG
        ORG     100H                    ;Start off right for a .COM file
ENTRY:  JMP     LOCATE                  ;Skip over Data area

        COPY_RIGHT DB '(C)1985 S.Holzner'       ;Author's Mark
        FOUND_MSG DB 13,10,13,10,'FOUND IN $'   ;Like it says
        LEN             DW 1                    ;The file length (low word)
        PATH_LEN        DW 0                    ;Length of Path.Dat
        NUMBER          DW 0                    ;Number of bytes read from file
        EXTRA_PATHS     DB 0                    ;=1 if we open & use Path.Dat
        OLD_BX          DW 0                    ;Save pointer to path at CS:DBH
        OLD_SI          DW 0                    ;Save SI as pointer also
        START_FLAG      DB 0                    ;For searches in Path.Dat
        PATH_DAT        DB "\PATH.DAT",0        ;ASCIIZ string of Path.Dat

LOCATE  PROC    NEAR            ;Here we go

        MOV     DX,0B0H         ;Move Disk Transfer Area to CS:0B0H
        MOV     AH,1AH          ;Matched file information goes there
        INT     21H

        MOV     DI,5CH          ;Use CS:5CH to put '*.*'0 at for search
        CALL    PUT             ; in current directory
        MOV     DX,5CH          ;Point to '*.*'0 for search
        MOV     AH,4EH          ; and find first matching file
        INT     21H             ;Match now at DTA, 0B0H
LOOP:                           ;Loop over matches now
        MOV     BX,0CAH         ;Get file length, came from match
        MOV     DX,[BX]
        MOV     LEN,DX          ;Store in Len
        CMP     DX,60*1024      ;Don't write over stack, allow < 64K files
        JB      NOT_BIG         ;Range extender (Find > 127 bytes ahead)
        JMP     FIND
NOT_BIG:CMP     DX,0            ;Was this a 0 length file (disk dir or label)?
        JA      FILE_OK         ;No, go on and read it
        JMP     FIND            ;Yes, find next file and skip this one
FILE_OK:CALL    READ_FILE       ;Get the file into memory
        MOV     CX,NUMBER       ;Prepare to loop over all read bytes
        MOV     DI,OFFSET PATHS+300     ;File starts at Offset Paths+300
SEARCH:                                 ;Use Repne Scasb & DI to search for the
        MOV     BX,82H          ;first letter of the string, which is at CS:82H
        MOV     AL,BYTE PTR [BX]        ;Load into AL for Repne Scasb
REPNE   SCASB                           ;Find first letter
        JCXZ    FIND            ;If out of file to search, find next file
        MOV     BX,80H          ;How many chars in string? Get from CS:80H
        XOR     DX,DX           ;Set DX to zero
        MOV     DL,[BX]         ;Get # of chars in string
        DEC     DX              ;Get rid of space typed after 'Locate'
        MOV     SI,83H          ;Search from second typed letter (1st matched)
CPLOOP: DEC     DX              ;Loop counter
        CMPSB                   ;See how far we get until no match
        JZ      CPLOOP
        DEC     DI              ;At end, reset DI (Scasb increments 1 too much)
        CMP     DX,0            ;If DX is not zero, all letters did not match
        JA      SEARCH          ;If not a match, go back and get next one
        LEA     DX,FOUND_MSG    ;FILE HAS BEEN FOUND, so say so.
        MOV     AH,9            ;Request string search
        INT     21H
        MOV     AH,2            ;Now to print filename. Without Path.Dat, at
        MOV     BX,0DBH         ; CS:CEH, with Path.Dat at CS:DBH
        CMP     EXTRA_PATHS,1   ; Using Path.Dat yet?
        JE      PRINT           ;Yes, print
        MOV     BX,0CEH         ;No, reset BX to point to CS:CEH
PRINT:  MOV     DL,[BX]         ;Print out the filename until 0 found
        CMP     DL,0            ;Is it 0?
        JE      MORE            ;If yes,print out sample at More:
        INT     21H             ;Print filename character
        INC     BX              ;Point to next character
        JMP     PRINT           ;Go back relentlessly until done
MORE:   PUSH    DI              ;Save DI,BX,CX
        PUSH    BX
        PUSH    CX
        MOV     CX,40           ;Prepare to type out total of 40 characters
        MOV     AH,2            ;With Int 21H service 2
        MOV     DL,':'          ;But first, add ':' to filename
        INT     21H             ;And a carriage return linefeed
        MOV     DL,13
        INT     21H
        MOV     DL,10
        INT     21H
        SUB     DI,20           ;DI points to end of found string, move back
        MOV     BX,OFFSET PATHS+300     ;Beginning of file
        CMP     DI,BX           ;If before beginning, start at beginning
        JA      GO
        MOV     DI,BX
GO:     ADD     BX,LEN          ;Now BX=end of file (to check if we're past it)
SHOW:   MOV     DL,[DI]         ;Get character from file
        INC     DI              ;And point to next one
        CMP     DI,BX           ;Past end?
        JA      SHOWS_OVER      ;Yes, jump out, look for next match
        CMP     DL,30           ;Unprintable character?
        JA      POK             ;No, OK
        MOV     DL,' '          ;Yes, make it a space
POK:    INT     21H             ;Print Character
        LOOP    SHOW            ;And return for the next one
SHOWS_OVER:                     ;End of printout
        POP     CX              ;Restore the registers used above
        POP     BX
        POP     DI
        JMP     SEARCH          ;Return to search more of the file
FIND:   CALL    FIND_FILE       ;This file done, find next match
        CMP     AL,18           ;AL=18 --> no match
        JE      OUT             ;And so we leave
        JMP     LOOP            ;If match found, go back once again
OUT:    INT     20H             ;End of Main Program
LOCATE  ENDP

PUT     PROC    NEAR                    ;This little gem puts a '*.*'0
        MOV     BYTE PTR [DI],'*'       ;Wherever you want it--just send
        MOV     BYTE PTR [DI+1],'.'     ; it a value in DI. '*.*'0 is used as
        MOV     BYTE PTR [DI+2],'*'     ; a universal wilcard in searches
        MOV     BYTE PTR [DI+3],0
        RET
PUT     ENDP

WS      PROC    NEAR                    ;Strip the bits for WordStar
        CMP     CX,0                    ;If there is a length of 0, e.g.
        JE      FIN                     ;Directory entries, etc. do nothing.
WSLOOP: AND BYTE PTR [BX],127           ;Set top bit to zero
        INC     BX                      ;Point to next unsuspecting byte
        LOOP    WSLOOP                  ;And get it too.
FIN:    RET                             ;To use, send this program BX and CX
WS      ENDP

FIND_FILE       PROC    NEAR    ;The file finder
        MOV     AH,4FH          ;Try service 4FH, find next match, first
        INT     21H
        CMP     AL,18           ;AL = 18 --> no match
        JE      CHECK           ;Range extender.
        JMP     NEW
CHECK:  CMP     EXTRA_PATHS,1   ;Have we used path.Dat?
        JE      NEXT_PATH       ;Yes, get next path, this one's used up
        INC     EXTRA_PATHS     ;No, set it to 1
        MOV     AX,3D00H        ;Request file opening for Path.Dat
        LEA     DX,PATH_DAT     ;Point to '\PATH.DAT'0
        INT     21H
        JNC     READ            ;If there was a carry, Path.Dat not found
DONE:   MOV     AL,18           ;And so we exit with AL=18
        JMP     END
READ:   MOV     CX,300          ;Assume the max length for Path.Dat, 300.
        MOV     BX,AX           ;Move found file handle into BX for read
        MOV     AH,3FH          ;Set up for file read
        LEA     DX,PATHS        ;Put the file at location Paths (at end)
        INT     21H             ;Read in the file
        ADD     AX,OFFSET PATHS         ;Full offset of end of Path.Dat
        MOV     PATH_LEN,AX     ;Get Path.Dat end point for loop
        MOV     AH,3EH          ;Now close the file
        INT     21H             ;Close file
        MOV     OLD_SI,OFFSET PATHS     ;Save for future path-readings
        MOV     CX,300                  ;Get ready to Un-WordStar
        MOV     BX,OFFSET PATHS         ;300 bytes at location Paths
        CALL    WS                      ;Strip high bit for WS
NEXT_PATH:              ;Come here to find next path to search for files
        MOV     SI,OLD_SI               ;Point to start of next path
        MOV     DI,5CH  ;Move will be to CS:5CH for '\path\*.*0' file find
        MOV     BX,0DBH ;Also to CS:DBH; will assemble full path & filename
        MOV     START_FLAG,0    ;Start the path search
CHAR:   CMP     SI,PATH_LEN     ;Past end of possible path names?
        JGE     DONE            ;Yes, we're done. Leave with AL=18
        CMP     BYTE PTR [SI],30        ;Carriage return or linefeed?
        JB      NEXT                    ;Yes, get next char
        MOV     START_FLAG,1            ;First char, stop skipping chars
        MOV     AL,[SI]                 ;Get char from Path.Dat
        MOV     [BX],AL                 ;Move char to DBH
        INC     BX                      ;And increment to next location there
        MOVSB                           ;Also move to 5CH area
        JMP     CHAR                    ;And go back for more
NEXT:   CMP     START_FLAG,1    ;Bad char, have we been reading a real pathname?
        JE      PDONE           ;Yes, we've reached the end of it.
        INC     SI              ;No, keep skipping chars to find pathname
        JMP     CHAR
PDONE:  MOV     OLD_SI,SI       ;Save SI for the next path.
        MOV     BYTE PTR [DI],'\'       ;Add '\' to both paths
        MOV     BYTE PTR [BX],'\'
        INC     BX                      ;Move BX on for next time
        MOV     OLD_BX,BX               ;And save it.
        INC     DI                      ;Move to next location at 5CH and
        CALL    PUT                     ;Put '*.*'0 there to find all files.
        MOV     DX,5CH                  ;Start the search for all files in
        MOV     AH,4EH                  ; the new path.
        MOV     CX,0                    ;Set the file attribute to 0
        INT     21H
        CMP     AL,18                   ;Did we find any new files in new path?
        JE      NEXT_PATH               ;No, get the next path.
NEW:    CMP     EXTRA_PATHS,1           ;Yes,Move found filename to DBH area to
        JNE     END                     ; read it in-only if DBH area is active
        MOV     BX,OLD_BX               ; (i.e. Extra_Paths=1). Restore BX
        MOV     SI,0CDH                 ;And point to found filename in DTA
CLOOP:  INC     SI                      ;Next letter from found filename
        MOV     AH,[SI]                 ;Move it to the DBH area so we can read
        MOV     [BX],AH                 ; in the file (needs pathname\filename)
        INC     BX                      ;Next character in 5CH area.
        CMP     BYTE PTR [SI],0         ;Is this the last character?
        JNE     CLOOP                   ;Nope, get next one
END:    RET                             ;After path & filename assembled, return
FIND_FILE       ENDP

READ_FILE       PROC    NEAR    ;Looks for filename at CEH or DBH & reads it
        PUSH    AX              ;Push everything to save it.
        PUSH    BX
        PUSH    CX
        PUSH    DX
        MOV     DX,0DBH         ;Try the DBH area
        CMP     EXTRA_PATHS,1   ;Has it been used?
        JE      OK              ;Yes
        MOV     DX,0CEH  ;No, not using paths yet, use filename only, at CEH
OK:     MOV     AX,3D00H        ;Prepare for file reading
        INT     21H             ;And do so.
        MOV     BX,AX           ;Move file handle into BX to read
        MOV     DX,OFFSET PATHS+300     ;Read into data area at Paths+300 bytes
        MOV     CX,LEN                  ;Read the full file's length in bytes
        MOV     AH,3FH                  ;Read it in at last
        INT     21H
        MOV     NUMBER,AX               ;Number of bytes actually read.
        MOV     AH,3EH                  ;Close file
        INT     21H
        MOV     BX,OFFSET PATHS+300     ;Clean up the Word Star high bit.
        MOV     CX,LEN                  ;For the full file
        CALL    WS                      ;Strip high bit for ws
        POP     DX                      ;Pop evrything and return
        POP     CX
        POP     BX
        POP     AX
        RET                             ;Fin of Read_File
READ_FILE       ENDP
PATHS:                                  ;Here's the end of program marker

CODE_SEG        ENDS
        END     ENTRY                   ;End 'Entry' so DOS starts at 'Entry'
