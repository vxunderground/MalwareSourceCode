INTERRUPTS      SEGMENT AT 0H    ;This is where the disk interrupt
        ORG     13H*4            ;holds the address of its service routine
DISK_INT        LABEL   DWORD
INTERRUPTS      ENDS

CODE_SEG        SEGMENT
        ASSUME  CS:CODE_SEG
        ORG     100H            ;ORG = 100H to make this into a .COM file
FIRST:  JMP     LOAD_CACHE      ;First time through jump to initialize routine

        CPY_RGT DB      '(C)1985 S.Holzner'     ;A signature in bytes
        TBL_LEN DW      64 ;<-- # OF SECTORS TO STORE IN CACHE, MIN=24, MAX=124.
  ;THIS IS THE ONLY PLACE YOU MUST SET THIS NUMBER. EACH SECTOR = 512 BYTES.
        TIME    DW      0       ;Time used to time-stamp each sector
        OLD_CX  DW      0       ;Stores original value of CX (CX is used often)
        LOW_TIM DW      0       ;Used in searching for least recently used sect.
        INT13H  DD      0       ;Stores the original INT 13H address
        RET_ADR LABEL   DWORD   ;Playing games with the stack here to preserve
        RET_ADR_WORD    DW      2 DUP(0)            ;flags returned by Int 13H

DISK_CACHE      PROC    FAR     ;The Disk interrupt will now come here.
        ASSUME  CS:CODE_SEG
        CMP     AX,201H         ;Is this a read (AH=2) of 1 sector (AL=1)?
        JE      READ            ;Yes, jump to Read
        CMP     AH,3            ;No. Perchance a write or format?
        JB      OLD_INT         ;No, release control to old disk Int.
        JMP     WRITE           ;Yes, jump to Write
OLD_INT:PUSHF                   ;Pushf for Int 13H's final Iret
        CALL    INT13H          ;Call the Disk Int
        JMP     PAST            ;And jump past all usual Pops
READ:   PUSH    BX              ;Push just about every register ever heard of
        PUSH    CX
        PUSH    DX
        PUSH    DI
        PUSH    SI
        PUSH    DS
        PUSH    ES
        MOV     DI,BX       ;Int 13H gets data address as ES:BX, switch to ES:DI
        ASSUME  DS:CODE_SEG     ;Make sure all labels found correctly
        PUSH    CS              ;Move CS into DS by pushing CS, popping DS
        POP     DS
        MOV     OLD_CX,CX       ;Save original CX since we're about to use it
        CMP     DH,0            ;DH holds requested head -- head 0?
        JNE     NOT_FAT1        ;Nope, this can't be the first Fat sector
        CMP     CX,6            ;If this is the directory, check if we have a
        JE      FAT1            ; new disk.
        CMP     CX,2            ;Track 0 (CH)? Sector 2 (CL)?
        JNE     NOT_FAT1        ;If not, this sure isn't the FAT1
FAT1:   CALL    FIND_MATCH  ;DOS reads in this sector first to check disk format
        JCXZ    NONE            ;We'll use it for a check-sum. Do we have it
        MOV     BX,DI           ; stored yet? CX=0-->no. If yes, restore BX
        MOV     CX,OLD_CX       ; and CX from original values
        PUSHF                   ;And now do the Pushf and call of Int13H to read
        CALL    INT13H          ; FAT1
        JC      ERR             ;If error, leave
        MOV     CX,256          ;No error, FAT1 was read, check our value
REPE    CMPSW                   ; with CMPSW -- if no match, disk was changed
        JCXZ    BYE             ;Everything checks out, Bingo, exit.
        LEA     SI,TABLE        ;New Disk! Zero all the old disk's sectors
        MOV     CX,TBL_LEN      ;Loop over all entries, DL holds drive #
CLR:    CMP     DS:[SI+2],DL    ;Is this stored sector from the old disk?
        JNE     NO_CLR          ;Nope, don't clear this entry
        MOV     WORD PTR DS:[SI],0      ;Match, zero this entry, zero first word
NO_CLR: ADD     SI,518      ;Move on to next stored sector (512 bytes of stored
        LOOP    CLR         ; sector and 3 words of identification & time-stamp)
        JMP     BYE             ;Reset for new disk, let's leave
NONE:   CALL    STORE_SECTOR    ;Store FAT1 if there was no match to it
        JC      ERR             ;Error -- exit ungraciously
        JMP     BYE             ;No Error, Bye.
NOT_FAT1:                       ;The requested sector was not FAT1. Let's
        CALL    FIND_MATCH      ;get it. Or do we have it already?
        JCXZ    NO_MATCH        ;No, jump to No_Match, store sector
        MOV     CX,512          ;ES:DI and DS:SI already set up from Find_Match
REP     MOVSB                   ;Move 512 bytes to requested memory area
        CMP     WORD PTR [BX+4],0FFFFH          ;Is this a a directory sector?
        JE      BYE             ;Yes, don't reset time (already highest poss.)
        INC     TIME            ;No, reset the time, this sector just accessed
        MOV     AX,TIME         ;Move time into Time word of sector's 3 words
        MOV     [BX+4],AX       ; of identification
        JMP     BYE             ;And leave. If there's an article you'd like to
NO_MATCH:                       ;see, by all means write in C/O PC Magazine.
        CALL    STORE_SECTOR    ;Don't have this sector yet, get it.
        JC      ERR             ;If read failed, exit with error
BYE:    CLC                     ;The exit point. Clear carry flag, set AX=1
        MOV     AX,1            ; CY=0 --> no error, AH=0 --> error code = 0
ERR:    POP     ES              ;If error, preserve flags and AX with error code
        POP     DS              ;Pop all conceivable registers (except AX)
        POP     SI
        POP     DI
        POP     DX
        POP     CX              ;Now that the flags are set, we want to get the
        POP     BX              ;old flags off the stack (put there by original
PAST:   POP     CS:RET_ADR_WORD ;Int call) To do that we save the return address
        POP     CS:RET_ADR_WORD[2]      ;first and then pop the flags harmlessly
        POP     CS:OLD_CX       ;into Old_CX, and then jump to RET_ADR.
        JMP     CS:RET_ADR      ;Done with read. Now let's consider write.
WRITE:  PUSH    BX              ;Push all registers, past and present
        PUSH    CX
        PUSH    DX
        PUSH    DI
        PUSH    SI
        PUSH    DS
        PUSH    ES
        PUSH    AX
        CMP     AX,301H         ;Is this a write of one sector?
        JNE     NOSAVE          ;No, don't save it in the sector bank
        PUSH    CS              ;Yep, set DS (for call to Int13H label) and
        POP     DS              ; write this sector out
        PUSHF
        CALL    INT13H
        JNC     SAVE       ;If there was an error we don't want to save sector
        POP     CS:OLD_CX       ;Save AH error code, Pop old AX into Old_CX
        JMP     ERR             ;And jump to an ignoble exit
SAVE:   MOV     OLD_CX,CX       ;We're going to save this sector.
        MOV     DI,BX           ;Set up DI for string move (to store written
        CALL    FIND_MATCH      ; sector. Do we have it in memory? (set SI)
        JCXZ    LEAVE           ;Nope, Leave (like above's Bye).
        XCHG    DI,SI           ;Exchange destination and source
        PUSH    ES              ;Set up DS:SI to point to where data written
        POP     DS              ; from. We'll then use a string move
        PUSH    CS              ;Set up ES so ES:DI points to sector bank
        POP     ES              ; SI was set by Find_Match, Xchg'd into DI
        MOV     CX,512          ;Get ready to move 512 bytes
REP     MOVSB                   ;Here we go
LEAVE:  POP     AX              ;Here is the leave
        JMP     BYE             ;Which only pops AX and then jumps to Bye
NOSAVE: PUSH    CS              ;More than 1 sector written, don't save but
        POP     DS              ; do zero stored sectors that will be written
        MOV     AH,0            ;Use AX as loop index (AL=# of sectors to write)
TOP:    PUSH    CX              ;Save CX since destroyed by Find_Match
        CALL    FIND_MATCH      ;Do we have this one?
        JCXZ    NOPE            ;Nope if CX = 0
        MOV     WORD PTR [BX],0 ;There is a match, zero this sector
NOPE:   POP     CX              ;Restore CX, the sector index
        INC     CL              ;Move on to next one
        DEC     AX              ;Decrement loop index
        JNZ     TOP             ;And, unless that gives 0, go back again
POPS:   POP     AX              ;Pop 'em all, starting with AX
        POP     ES
        POP     DS
        POP     SI
        POP     DI
        POP     DX
        POP     CX
        POP     BX
        JMP     OLD_INT         ;And go back to OLD_INT for write.
DISK_CACHE      ENDP

FIND_MATCH      PROC    NEAR    ;This routine finds a sector in the sector bank
        PUSH    AX              ;And returns SI set to sector's entry, BX set
        LEA     SI,SECTORS      ; to the beginning of the 'table' -- the 3 words
        LEA     BX,TABLE        ;that precede all sectors. If there was no match
        MOV     AX,TBL_LEN      ; CX=0. When Int13H called, CH=trk #, CL=sec. #
        XCHG    AX,CX           ; DH=head #, DL=Drive #. Get Tbl_Len into CX
FIND:   CMP     DS:[BX],AX      ;Compare stored sector's original AX to current
        JNE     NO              ;If not, not.
        CMP     DS:[BX+2],DX    ;If so, check DX of stored sector with current
        JE      GOT_IT          ;Yes, there is a match, leave
NO:     ADD     BX,518          ;Point to next Table entry
        ADD     SI,518          ;And next sector too
        LOOP    FIND            ;Keep looping until there is a match
GOT_IT: POP     AX              ;If there is no match, CX will be left 0
        RET                     ;Return
FIND_MATCH      ENDP

STORE_SECTOR    PROC    NEAR    ;This routine, as it says, stores sectors
        MOV     BX,DI           ;Original BX (ES:BX was original data address)
        MOV     CX,OLD_CX       ; and CX restored (CX=trk#, Sector#)
        PUSHF                   ;Pushf for Int 13H's Iret and call it
        CALL    INT13H
        JNC     ALL_OK          ;If there was an exit, exit ignominiously
        JMP     FIN             ;If error, leave CY flag set, code in AH, exit
ALL_OK: PUSH    CX              ;No error, push used registers
        PUSH    BX              ; and find space for sector in sector bank
        PUSH    DX
        LEA     DI,SECTORS      ;Point to sector bank
        LEA     BX,TABLE        ; and Table
        MOV     CX,TBL_LEN      ; and get ready to loop over all of them to
CHK0:   CMP     WORD PTR DS:[BX],0      ;find if there is an unused sector
        JE      FOUND           ;If the first word is 0, use this sector
        ADD     DI,518          ;But this one isn't so update DI, SI and
        ADD     BX,518          ; loop again
        LOOP    CHK0
        MOV     LOW_TIM,0FFFEH  ;All sectors were filled, find least recently
        LEA     DI,SECTORS      ; used and write over that one
        LEA     SI,TABLE
        MOV     CX,TBL_LEN      ;Loop over all stored sectors
CHKTIM: MOV     DX,LOW_TIM      ;Compare stored sector to so-far low time
        CMP     [SI+4],DX
        JA      MORE_RECENT     ;If this one is more recent, don't use it
        MOV     AX,DI           ;This one is older than previous oldest
        MOV     BX,SI           ;Store sector bank address (DI) and table
        MOV     DX,[SI+4]       ; entry (now in SI)
        MOV     LOW_TIM,DX      ;And update the Low Time to this one
MORE_RECENT:
        ADD     DI,518          ;Move on to next stored sector
        ADD     SI,518          ;And next table entry
        LOOP    CHKTIM          ;Loop again until all covered
        MOV     DI,AX           ;Get Sector bank address of oldest into DI
FOUND:  POP     DX              ;Restore used registers
        POP     SI              ;Old BX (data read-to-address) --> SI
        POP     CX
        MOV     [BX],CX         ;Store the new CX as the sector's first word
        MOV     [BX+2],DX       ;2nd word of Table is sector's DX
        INC     TIME            ;Now find the new time
        MOV     AX,TIME         ;Prepare to move it into 3rd word of Table
        CMP     DH,0            ;Is this directory or FAT? (time-->FFFF)
        JNE     SIDE1           ;If head is not 0, check other head
        CMP     CX,9            ;Head zero, trk# 0, first sector? (directory)
        JLE     DIR             ;Yes, this is a piece we always want stored
        JMP     NOT_DIR         ;No, definitely not FAT or directory
SIDE1:  CMP     DH,1            ;Head 1?
        JNE     NOT_DIR         ;No, this is not File Alloc. Table or directory
        CMP     CX,2            ;Part of the top of the directory?
        JA      NOT_DIR         ;No, go to Not_Dir and set time
DIR:    MOV     AX,0FFFFH       ;Dir or FAT, set time high so always kept
NOT_DIR:MOV     [BX+4],AX       ;Not FAT or dir, store the incremented time
        PUSH    ES              ;And now get the data to fill the sector
        POP     DS              ;SI, DI already set. Now set ES and DS for
        PUSH    CS              ; string move.
        POP     ES
        MOV     CX,512          ;Move 512 bytes
REP     MOVSB                   ;Right here
        CLC                     ;Clear the carry flag (no error)
FIN:    RET                     ;Error exit here (do not reset CY flag)
STORE_SECTOR    ENDP
TABLE:  DW      3 DUP(0)        ;Table and sector storage begins right here
SECTORS:                        ;First thing to write over is the following
                                ; booster program.
LOAD_CACHE        PROC    NEAR  ;This procedure intializes everything
        LEA     BX,CLEAR
        ASSUME  DS:INTERRUPTS   ;The data segment will be the Interrupt area
        MOV     AX,INTERRUPTS
        MOV     DS,AX
        MOV     AX,word ptr DISK_INT    ;Get the old interrupt service routine
        MOV     word ptr INT13H,AX      ; address and put it into our location         MOV     AX,word ptr DISK_INT[2]
                                        ; INT13H so we can call it.
        MOV     word ptr INT13H[2],AX
        MOV     word ptr DISK_INT,OFFSET DISK_CACHE  ;Now load address of Cache
        MOV     word ptr DISK_INT[2],CS   ;routine into the Disk interrupt
        MOV     AX,TBL_LEN              ;The number of sectors to store in cache
        MOV     CX,518                  ;Multiply by 518 (3 words of id and 512
        MUL     CX                      ; bytes of sector data)
        MOV     CX,AX                   ;Also, zero all the bytes so that
ZERO:   MOV     BYTE PTR CS:[BX],0      ; Store_Sector will find 1st word a 0,
        INC     BX                      ; indicating virgin territory.
        LOOP    ZERO
        MOV     DX,OFFSET TABLE         ;To attach in memory, add # bytes to
        ADD     DX,AX                   ;store to Table's location and use
        INT     27H                     ; Int 27H
LOAD_CACHE        ENDP
CLEAR:
        CODE_SEG        ENDS
        END     FIRST           ;END "FIRST" so 8088 will go to FIRST first.
