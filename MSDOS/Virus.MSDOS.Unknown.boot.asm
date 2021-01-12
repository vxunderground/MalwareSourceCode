;This is a simple boot sector that will load either MS-DOS or PC-DOS. It is not
;self-reproducing, but it will be used as the foundation on which to build a
;virus into a boot sector.

;This segment is where the first operating system file (IBMBIO.COM or IO.SYS)
;will be loaded and executed from. We don't know (or care) what is there, but
;we do need the address to jump to defined in a separate segment so we can
;execute a far jump to it.
DOS_LOAD        SEGMENT AT 0070H
                ASSUME  CS:DOS_LOAD

                ORG     0

LOAD:           DB      0               ;Start of the first operating system program

DOS_LOAD        ENDS


MAIN            SEGMENT BYTE
                ASSUME  CS:MAIN,DS:MAIN,SS:NOTHING

;This jump instruction is just here so we can compile this program as a COM
;file. It is never actually executed, and never becomes a part of the boot
;sector. Only the 512 bytes after the address 7C00 in this file become part of
;the boot sector.
                ORG     100H

START:          jmp     BOOTSEC

;The following two definitions are BIOS RAM bytes which contain information
;about the number and type of disk drives in the computer. These are needed by
;the virus to decide on where to look to find drives to infect. They are not
;normally needed by an ordinary boot sector.
;
;               ORG     0410H
;
;SYSTEM_INFO:    DB      ?                       ;System info byte: Take bits 6 & 7 and add 1 to get number of
;                                                ;disk drives on this system (eg 01 = 2 drives)
;
;                ORG     0475H
;
;HD_COUNT:       DB      ?                       ;Number of hard drives in the system
;
;This area is reserved for loading the first sector of the root directory, when
;checking for the existence of system files and loading the first system file.

                ORG     0500H

DISK_BUF:       DW      ?                       ;Start of the buffer

;Here is the start of the boot sector code. This is the chunk we will take out
;of the compiled COM file and put it in the first sector on a 360K floppy disk.
;Note that this MUST be loaded onto a 360K floppy to work, because the
;parameters in the data area that follow are set up to work only with a 360K
;disk!

                ORG     7C00H

BOOTSEC:        JMP     BOOT                    ;Jump to start of boot sector code

                ORG     7C03H                   ;This is needed because the jump will get coded as 2 bytes

DOS_ID:         DB      'EZBOOT  '              ;Name of this boot sector (8 bytes)
SEC_SIZE:       DW      200H                    ;Size of a sector, in bytes
SECS_PER_CLUST: DB      02                      ;Number of sectors in a cluster
FAT_START:      DW      1                       ;Starting sector for the first File Allocation Table (FAT)
FAT_COUNT:      DB      2                       ;Number of FATs on this disk
ROOT_ENTRIES:   DW      70H                     ;Number of root directory entries
SEC_COUNT:      DW      2D0H                    ;Total number of sectors on this disk
DISK_ID:        DB      0FDH                    ;Disk type code (This is 360KB)
SECS_PER_FAT:   DW      2                       ;Number of sectors per FAT
SECS_PER_TRK:   DW      9                       ;Sectors per track for this drive
HEADS:          DW      2                       ;Number of heads (sides) on this drive
HIDDEN_SECS:    DW      0                       ;Number of hidden sectors on the disk

DSKBASETBL:
                DB      0                       ;Specify byte 1: step rate time, head unload time
                DB      0                       ;Specify byte 2: Head load time, DMA mode
                DB      0                       ;Wait time until motor turned off, in clock ticks
                DB      0                       ;Bytes per sector (0=128, 1=256, 2=512, 3=1024)
                DB      12H                     ;Last sector number (we make it large enough to handle 1.2/1.44 MB floppies)
                DB      0                       ;Gap length between sectors for r/w operations, in bytes
                DB      0                       ;Data transfer length when sector length not specified
                DB      0                       ;Gap length between sectors for format operations, in bytes
                DB      0                       ;Value stored in newly formatted sectors
                DB      1                       ;Head settle time, in milliseconds (we set it small to speed operations)
                DB      0                       ;Motor startup time, in 1/8 seconds

HEAD:           DB      0                       ;Current head to read from (scratch area used by boot sector)

;Here is the start of the boot sector code

BOOT:           CLI                                     ;interrupts off
                XOR     AX,AX                           ;prepare to set up segments
                MOV     ES,AX                           ;set ES=0
                MOV     SS,AX                           ;start stack at 0000:7C00
                MOV     SP,OFFSET BOOTSEC
                MOV     BX,1EH*4                        ;get address of disk
                LDS     SI,SS:[BX]                      ;param table in ds:si
                PUSH    DS
                PUSH    SI                              ;save that address
                PUSH    SS
                PUSH    BX                              ;and its address

                MOV     DI,OFFSET DSKBASETBL            ;and update default
                MOV     CX,11                           ;values to the table stored here
                CLD                                     ;direction flag cleared
DFLT1:          LODSB
                CMP     BYTE PTR ES:[DI],0              ;anything non-zero
                JNZ     SHORT DFLT2                     ;is not a default, so don't save it
                STOSB                                   ;else put default value in place
                JMP     SHORT DFLT3                     ;and go on to next
DFLT2:          INC     DI
DFLT3:          LOOP    DFLT1                           ;and loop until cx=0

                MOV     AL,AH                           ;set ax=0
                MOV     DS,AX                           ;set ds=0 so we can set disk tbl
                MOV     WORD PTR [BX+2],AX              ;to @DSKBASETBL (ax=0 here)
                MOV     WORD PTR [BX],OFFSET DSKBASETBL ;ok, done
                STI                                     ;now turn interrupts on
                INT     13H                             ;and reset disk drive system
ERROR1:         JC      ERROR1                          ;if an error, hang the machine

;Here we look at the first file on the disk to see if it is the first MS-DOS or
;PC-DOS system file, IO.SYS or IBMBIO.COM, respectively.
LOOK_SYS:
                MOV     AL,BYTE PTR [FAT_COUNT]         ;get fats per disk
                XOR     AH,AH
                MUL     WORD PTR [SECS_PER_FAT]         ;multiply by sectors per fat
                ADD     AX,WORD PTR [HIDDEN_SECS]       ;add hidden sectors
                ADD     AX,WORD PTR [FAT_START]         ;add starting fat sector

                PUSH    AX
                MOV     WORD PTR [DOS_ID],AX            ;root dir, save it

                MOV     AX,20H                          ;dir entry size
                MUL     WORD PTR [ROOT_ENTRIES]         ;dir size in ax
                MOV     BX,WORD PTR [SEC_SIZE]          ;sector size
                ADD     AX,BX                           ;add one sector
                DEC     AX                              ;decrement by 1
                DIV     BX                              ;ax=# sectors in root dir
                ADD     WORD PTR [DOS_ID],AX            ;DOS_ID=start of data
                MOV     BX,OFFSET DISK_BUF              ;set up disk read buffer at 0000:0500
                POP     AX
                CALL    CONVERT                         ;and go convert sequential sector number to bios data
                MOV     AL,1                            ;prepare for a disk read for 1 sector
                CALL    READ_DISK                       ;go read it

                MOV     DI,BX                           ;compare first file on disk with
                MOV     CX,11                           ;required file name
                MOV     SI,OFFSET SYSFILE_1             ;of first system file for PC DOS
                REPZ    CMPSB
                JZ      SYSTEM_THERE                    ;ok, found it, go load it

                MOV     DI,BX                           ;compare first file with
                MOV     CX,11                           ;required file name
                MOV     SI,OFFSET SYSFILE_2             ;of first system file for MS DOS
                REPZ    CMPSB
ERROR2:         JNZ     ERROR2                          ;not the same - an error, so hang the machine

;Ok, system file is there, so load it
SYSTEM_THERE:
                MOV     AX,WORD PTR [DISK_BUF+1CH]      ;get file size of IBMBIO.COM/IO.SYS
                XOR     DX,DX
                DIV     WORD PTR [SEC_SIZE]             ;and divide by sector size
                INC     AL                              ;ax=number of sectors to read
                MOV     BP,AX                           ;store that number in BP
                MOV     AX,WORD PTR [DOS_ID]            ;get sector number of start of data
                PUSH    AX
                MOV     BX,700H                         ;set disk read buffer to 0000:0700
RD_BOOT1:       MOV     AX,WORD PTR [DOS_ID]            ;and get sector to read
                CALL    CONVERT                         ;convert to bios Trk/Cyl/Sec info
                MOV     AL,1                            ;read one sector
                CALL    READ_DISK                       ;go read the disk
                SUB     BP,1                            ;subtract 1 from number of sectors to read
                JZ      DO_BOOT                         ;and quit if we're done
                ADD     WORD PTR [DOS_ID],1             ;add sectors read to sector to read
                ADD     BX,WORD PTR [SEC_SIZE]          ;and update buffer address
                JMP     RD_BOOT1                        ;then go for another


;Ok, the first system file has been read in, now transfer control to it
DO_BOOT:
                MOV     CH,BYTE PTR [DISK_ID]           ;Put drive type in ch
                MOV     DL,BYTE PTR [DRIVE]             ;Drive number in dl
                POP     BX
                JMP     FAR PTR LOAD                    ;and transfer control to the first system file


;Convert sequential sector number in ax to BIOS Track, Head, Sector information.
;Save track number in DX, sector number in CH,
CONVERT:
                XOR     DX,DX
                DIV     WORD PTR [SECS_PER_TRK]         ;divide ax by sectors per track
                INC     DL                              ;dl=sector number to start read on, al=track/head count
                MOV     CH,DL                           ;save it here
                XOR     DX,DX
                DIV     WORD PTR [HEADS]                ;divide ax by head count
                MOV     BYTE PTR [HEAD],DL              ;dl=head number, save it
                MOV     DX,AX                           ;ax=track number, save it in dx
                RET


;Read the disk for the number of sectors in al, into the buffer es:bx, using
;the track number in DX, the head number at HEAD, and the sector
;number at CH.
READ_DISK:
                MOV     AH,2                            ;read disk command
                MOV     CL,6                            ;shift possible upper 2 bits of track number to
                SHL     DH,CL                           ;the high bits in dh
                OR      DH,CH                           ;and put sector number in the low 6 bits
                MOV     CX,DX
                XCHG    CH,CL                           ;ch (0-5) = sector, cl, ch (6-7) = track
                MOV     DL,BYTE PTR [DRIVE]             ;get drive number from here
                MOV     DH,BYTE PTR [HEAD]              ;and head number from here
                INT     13H                             ;go read the disk
ERROR3:         JC      ERROR3                          ;hang in case of an error
                RET

;Move data that doesn't change from this boot sector to the one read in at
;DISK_BUF. That includes everything but the DRIVE ID (at offset 7DFDH) and
;the data area at the beginning of the boot sector.
MOVE_DATA:
                MOV     SI,OFFSET DSKBASETBL            ;Move all of the boot sector code after the data area
                MOV     DI,OFFSET DISK_BUF + (OFFSET DSKBASETBL - OFFSET BOOTSEC)
                MOV     CX,OFFSET DRIVE - OFFSET DSKBASETBL
                REP     MOVSB
                MOV     SI,OFFSET BOOTSEC               ;Move the initial jump and the sector ID
                MOV     DI,OFFSET DISK_BUF
                MOV     CX,11
                REP     MOVSB
                RET


SYSFILE_1:      DB      'IBMBIO  COM'                   ;PC DOS System file
SYSFILE_2:      DB      'IO      SYS'                   ;MS DOS System file

                ORG     7DFDH

DRIVE:          DB      0                               ;Drive number, used in disk reads, etc.
BOOT_ID:        DW      0AA55H                          ;Boot sector ID word


MAIN            ENDS


                END START
