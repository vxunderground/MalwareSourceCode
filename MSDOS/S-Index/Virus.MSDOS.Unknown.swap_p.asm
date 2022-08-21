.model large

;EXECSWAP.ASM
;  Swap memory and exec another program
;  Copyright (c) 1988 TurboPower Software
;  May be used freely as long as due credit is given
;-----------------------------------------------------------------------------
;DATA    SEGMENT BYTE PUBLIC
.data
        EXTRN   _BytesSwapped:DWORD      ;Bytes to swap to EMS/disk
        EXTRN   _EmsAllocated:BYTE       ;True when EMS allocated for swap
        EXTRN   _FileAllocated:BYTE      ;True when file allocated for swap
        EXTRN   _EmsHandle:WORD          ;Handle of EMS allocation block
        EXTRN   _FrameSeg:WORD           ;Segment of EMS page frame
        EXTRN   _FileHandle:WORD         ;Handle of DOS swap file
        EXTRN   _SwapName:BYTE           ;ASCIIZ name of swap file
        EXTRN   _PrefixSeg:WORD          ;Base segment of program
;DATA    ENDS
;-----------------------------------------------------------------------------
;CODE    SEGMENT BYTE PUBLIC
.code
;	ASSUME  CS:CODE,DS:DATA
	PUBLIC  EXECWITHSWAP, _FIRSTTOSAVE
	PUBLIC  ALLOCATESWAPFILE, DEALLOCATESWAPFILE
	PUBLIC  EMSINSTALLED, EMSPAGEFRAME
	PUBLIC  ALLOCATEEMSPAGES, DEALLOCATEEMSHANDLE
;-----------------------------------------------------------------------------
FileAttr        EQU     0               ;Swap file attribute (hidden+system)
EmsPageSize     EQU     16384           ;Size of EMS page
FileBlockSize   EQU     32768           ;Size of a file block
StkSize         EQU     128             ;Bytes in temporary stack
lo              EQU     (WORD PTR 0)    ;Convenient typecasts
hi              EQU     (WORD PTR 2)
ofst            EQU     (WORD PTR 0)
segm            EQU     (WORD PTR 2)
;-----------------------------------------------------------------------------
;Variables in CS
EmsDevice       DB      'EMMXXXX0',0    ;Name of EMS device driver
UsedEms         DB      0               ;1 if swapping to EMS, 0 if to file
BytesSwappedCS  DD      0               ;Bytes to move during a swap
EmsHandleCS     DW      0               ;EMS handle
FrameSegCS      DW      0               ;Segment of EMS page window
FileHandleCS    DW      0               ;DOS file handle
PrefixSegCS     DW      0               ;Segment of base of program
Status          DW      0               ;ExecSwap status code
LeftToSwap      DD      0               ;Bytes left to move
SaveSP          DW      0               ;Original stack pointer
SaveSS          DW      0               ;Original stack segment
PathPtr         DD      0               ;Pointer to program to execute
CmdPtr          DD      0               ;Pointer to command line to execute
ParasWeHave     DW      0               ;Paragraphs allocated to process
CmdLine         DB      128 DUP(0)      ;Terminated command line passed to DOS
Path            DB      64 DUP(0)       ;Terminated path name passed to DOS
FileBlock1      DB      16 DUP(0)       ;FCB passed to DOS
FileBlock2      DB      16 DUP(0)       ;FCB passed to DOS
BooBoo          DB      '$'
ComeBack        DB      '$'
EnvironSeg      DW      0               ;Segment of environment for child
CmdLinePtr      DD      0               ;Pointer to terminated command line
FilePtr1        DD      0               ;Pointer to FCB file
FilePtr2        DD      0               ;Pointer to FCB file
TempStack       DB      StkSize DUP(0)  ;Temporary stack
StackTop        LABEL   WORD            ;Initial top of stack
;-----------------------------------------------------------------------------
;Macros
MovSeg          MACRO Dest,Src          ;Set one segment register to another
        PUSH    Src
        POP     Dest
                ENDM

MovMem          MACRO Dest,Src          ;Move from memory to memory via AX
        MOV     AX,Src
        MOV     Dest,AX
                ENDM

InitSwapCount   MACRO                   ;Initialize counter for bytes to swap
	MovMem  LeftToSwap.lo,BytesSwappedCS.lo
	MovMem  LeftToSwap.hi,BytesSwappedCS.hi
                ENDM

SetSwapCount    MACRO BlkSize           ;Return CX = bytes to move this block
        LOCAL   FullBlk                 ;...and reduce total bytes left to move
        MOV     CX,BlkSize              ;Assume we'll write a full block
        CMP     LeftToSwap.hi,0         ;Is high word still non-zero?
        JNZ     FullBlk                 ;Jump if so
        CMP     LeftToSwap.lo,BlkSize   ;Low word still a block or more?
        JAE     FullBlk                 ;Jump if so
        MOV     CX,LeftToSwap.lo        ;Otherwise, move what's left
FullBlk:SUB     LeftToSwap.lo,CX        ;Reduce number left to move
        SBB     LeftToSwap.hi,0
                ENDM

NextBlock       MACRO SegReg, BlkSize   ;Point SegReg to next block to move
        MOV     AX,SegReg
        ADD     AX,BlkSize/16           ;Add paragraphs to next segment
        MOV     SegReg,AX               ;Next block to move
        MOV     AX,LeftToSwap.lo
        OR      AX,LeftToSwap.hi        ;Bytes left to move?
                ENDM

EmsCall         MACRO FuncAH            ;Call EMM and prepare to check result
        MOV     AH,FuncAH               ;Set up function
        INT     67h
        OR      AH,AH                   ;Error code in AH
                ENDM

DosCallAH       MACRO FuncAH            ;Call DOS subfunction AH
        MOV     AH,FuncAH
        INT     21h
                ENDM

DosCallAX       MACRO FuncAX            ;Call DOS subfunction AX
        MOV     AX,FuncAX
        INT     21h
                ENDM

InitSwapFile    MACRO
        MOV     BX,FileHandleCS         ;BX = handle of swap file
        XOR     CX,CX
        XOR     DX,DX                   ;Start of file
        DosCallAX 4200h                 ;DOS file seek
                ENDM

HaltWithError   MACRO Level             ;Halt if non-recoverable error occurs
	PUSH	CS
	POP	DS
	MOV	DX,OFFSET BooBoo
	MOV	AH,9
	INT	21h
        MOV     AL,Level                ;Set errorlevel
        DosCallAH 4Ch
                ENDM

MoveFast        MACRO                   ;Move CX bytes from DS:SI to ES:DI
        CLD                             ;Forward
        RCR     CX,1                    ;Convert to words
        REP     MOVSW                   ;Move the words
        RCL     CX,1                    ;Get the odd byte, if any
        REP     MOVSB                   ;Move it
                ENDM

SetTempStack    MACRO                   ;Switch to temporary stack
        MOV     AX,OFFSET StackTop      ;Point to top of stack
        MOV     BX,CS                   ;Temporary stack in this code segment
        CLI                             ;Interrupts off
        MOV     SS,BX                   ;Change stack
        MOV     SP,AX
        STI                             ;Interrupts on
                ENDM
;-----------------------------------------------------------------------------
;function ExecWithSwap(Path, CmdLine : string) : Word;
EXECWITHSWAP   PROC FAR
        PUSH    BP
        MOV     BP,SP                   ;Set up stack frame

;Move variables to CS where we can easily access them later
        MOV     Status,1                ;Assume failure
	LES     DI,[BP+6]               ;ES:DI -> CmdLine
        MOV     CmdPtr.ofst,DI
        MOV     CmdPtr.segm,ES          ;CmdPtr -> command line string
	LES     DI,[BP+10]              ;ES:DI -> Path
        MOV     PathPtr.ofst,DI
        MOV     PathPtr.segm,ES         ;PathPtr -> path to execute
        MOV     SaveSP,SP               ;Save stack position
        MOV     SaveSS,SS
	MovMem  BytesSwappedCS.lo,_BytesSwapped.lo
	MovMem  BytesSwappedCS.hi,_BytesSwapped.hi
        MovMem  EmsHandleCS,_EmsHandle
        MovMem  FrameSegCS,_FrameSeg
        MovMem  FileHandleCS,_FileHandle
        MovMem  PrefixSegCS,_PrefixSeg
        InitSwapCount                   ;Initialize bytes LeftToSwap

;Check for swapping to EMS or file
        CMP     _EmsAllocated,0          ;Check flag for EMS method
        JZ      NotEms                  ;Jump if EMS not used
        JMP     WriteE                  ;Swap to EMS
NotEms: CMP     _FileAllocated,0         ;Check flag for swap file method
        JNZ     WriteF                  ;Swap to file
        JMP     ESDone                  ;Exit if no swapping method set

;Write to swap file
WriteF: MovSeg  DS,CS                   ;DS = CS
        InitSwapFile                    ;Seek to start of swap file
        JNC     EF0                     ;Jump if success
        JMP     ESDone                  ;Exit if error
EF0:    SetSwapCount FileBlockSize      ;CX = bytes to write
	MOV     DX,OFFSET _FIRSTTOSAVE   ;DS:DX -> start of region to save
        DosCallAH 40h                   ;File write
        JC      EF1                     ;Jump if write error
        CMP     AX,CX                   ;All bytes written?
        JZ      EF2                     ;Jump if so
EF1:    JMP     ESDone                  ;Exit if error
EF2:    NextBlock DS,FileBlockSize      ;Point DS to next block to write
        JNZ     EF0                     ;Loop if bytes left to write
        MOV     UsedEms,0               ;Flag we used swap file for swapping
        JMP     SwapDone                ;Done swapping out

;Write to EMS
WriteE: MOV     ES,_FrameSeg             ;ES -> page window
	MOV     DX,_EmsHandle           ;DX = handle of our EMS block
        XOR     BX,BX                   ;BX = initial logical page
        MovSeg  DS,CS                   ;DS = CS
EE0:    XOR     AL,AL                   ;Physical page 0
        EmsCall 44h                     ;Map physical page
        JZ      EE1                     ;Jump if success
        JMP     ESDone                  ;Exit if error
EE1:    SetSwapCount EmsPageSize        ;CX = Bytes to move
        XOR     DI,DI                   ;ES:DI -> base of EMS page
	MOV     SI,OFFSET _FIRSTTOSAVE   ;DS:SI -> region to save
        MoveFast                        ;Move CX bytes from DS:SI to ES:DI
        INC     BX                      ;Next logical page
        NextBlock DS,EmsPageSize        ;Point DS to next page to move
        JNZ     EE0                     ;Loop if bytes left to move
        MOV     UsedEms,1               ;Flag we used EMS for swapping

;Shrink memory allocated to this process
SwapDone:MOV    AX,PrefixSegCS
        MOV     ES,AX                   ;ES = segment of our memory block
        DEC     AX
        MOV     DS,AX                   ;DS = segment of memory control block
        MOV     CX,DS:[0003h]           ;CX = current paragraphs owned
        MOV     ParasWeHave,CX          ;Save current paragraphs owned
        SetTempStack                    ;Switch to temporary stack
	MOV     AX,OFFSET _FIRSTTOSAVE+15
        MOV     CL,4
        SHR     AX,CL                   ;Convert offset to paragraphs
        ADD     BX,AX
        SUB     BX,PrefixSegCS          ;BX = new paragraphs to keep
        DosCallAH 4Ah                   ;SetBlock
        JNC     EX0                     ;Jump if successful
        JMP     EX5                     ;Swap back and exit

;Set up parameters and call DOS Exec
EX0:    MOV     AX,ES:[002Ch]           ;Get environment segment
        MOV     EnvironSeg,AX
        MovSeg  ES,CS                   ;ES = CS
        LDS     SI,PathPtr              ;DS:SI -> path to execute
        MOV     DI,OFFSET Path          ;ES:DI -> local ASCIIZ copy
        CLD
;	LODSB                           ;Read current length
;	CMP     AL,63                   ;Truncate if exceeds space set aside
;	JB      EX1
;	MOV     AL,63
;EX1:    MOV     CL,AL
;	XOR     CH,CH                   ;CX = bytes to copy
	MOV     CX, 63
        REP     MOVSB
;	XOR     AL,AL
;	STOSB                           ;ASCIIZ terminate
        LDS     SI,CmdPtr               ;DS:SI -> Command line to pass
        MOV     DI,OFFSET CmdLine       ;ES:DI -> Local terminated copy
;	LODSB
;	CMP     AL,126                  ;Truncate command if exceeds space
;	JB      EX2
;	MOV     AL,126
;EX2:    STOSB
;	MOV     CL,AL
;	XOR     CH,CH                   ;CX = bytes to copy
	MOV     CX, 127
        REP     MOVSB
;	MOV     AL,0DH                  ;Terminate with ^M
;	STOSB

        MovSeg  DS,CS                   ;DS = CS
	MOV     SI,OFFSET CmdLine
	MOV     CmdLinePtr.ofst,SI
	MOV     CmdLinePtr.segm,DS      ;Store pointer to command line
;       INC     SI
	MOV     DI,OFFSET FileBlock1
	MOV     FilePtr1.ofst,DI
	MOV     FilePtr1.segm,ES        ;Store pointer to filename 1, if any
	DosCallAX 2901h                 ;Parse FCB
	MOV     DI,OFFSET FileBlock2
	MOV     FilePtr2.ofst,DI
	MOV     FilePtr2.segm,ES        ;Store pointer to filename 2, if any
	DosCallAX 2901h                 ;Parse FCB
	MOV     DX,OFFSET Path
	MOV     BX,OFFSET EnvironSeg
        DosCallAX 4B00h                 ;Exec
        JC      EX3                     ;Jump if error in DOS call
        XOR     AX,AX                   ;Return zero for success
EX3:    MOV     Status,AX               ;Save DOS error code

;Set up temporary stack and reallocate original memory block
        SetTempStack                    ;Set up temporary stack
        MOV     ES,PrefixSegCS
        MOV     BX,ParasWeHave
        DosCallAH 4Ah                   ;SetBlock
        JNC     EX4                     ;Jump if no error
        HaltWithError 0FFh              ;Must halt if failure here
EX4:    InitSwapCount                   ;Initialize LeftToSwap

;Check which swap method is in use
EX5:	PUSH	CS
	POP	DS
	MOV	DX,OFFSET ComeBack
	MOV	AH,9
	INT	21h
	CMP     UsedEms,0
        JZ      ReadF                   ;Jump to read back from file
        JMP     ReadE                   ;Read back from EMS

;Read back from swap file
ReadF:  MovSeg  DS,CS                   ;DS = CS
        InitSwapFile                    ;Seek to start of swap file
        JNC     EF3                     ;Jump if we succeeded
        HaltWithError 0FEh              ;Must halt if failure here
EF3:    SetSwapCount FileBlockSize      ;CX = bytes to read
	MOV     DX,OFFSET _FIRSTTOSAVE   ;DS:DX -> start of region to restore
        DosCallAH 3Fh                   ;Read file
        JNC     EF4                     ;Jump if no error
        HaltWithError 0FEh              ;Must halt if failure here
EF4:    CMP     AX,CX
        JZ      EF5                     ;Jump if full block read
        HaltWithError 0FEh              ;Must halt if failure here
EF5:    NextBlock DS,FileBlockSize      ;Point DS to next page to read
        JNZ     EF3                     ;Jump if bytes left to read
        JMP     ESDone                  ;We're done

;Copy back from EMS
ReadE:  MOV     DS,FrameSegCS           ;DS -> page window
        MOV     DX,EmsHandleCS          ;DX = handle of our EMS block
        XOR     BX,BX                   ;BX = initial logical page
        MovSeg  ES,CS                   ;ES = CS
EE3:    XOR     AL,AL                   ;Physical page 0
        EmsCall 44h                     ;Map physical page
        JZ      EE4                     ;Jump if success
        HaltWithError 0FDh              ;Must halt if failure here
EE4:    SetSwapCount EmsPageSize        ;CX = Bytes to move
        XOR     SI,SI                   ;DS:SI -> base of EMS page
	MOV     DI,OFFSET _FIRSTTOSAVE   ;ES:DI -> region to restore
        MoveFast                        ;Move CX bytes from DS:SI to ES:DI
        INC     BX                      ;Next logical page
        NextBlock ES,EmsPageSize        ;Point ES to next page to move
        JNZ     EE3                     ;Jump if so

ESDone: CLI                             ;Switch back to original stack
        MOV     SS,SaveSS
        MOV     SP,SaveSP
        STI
	MOV     AX,SEG DGROUP
        MOV     DS,AX                   ;Restore DS
        MOV     AX,Status               ;Return status
        POP     BP
	RET     8                       ;Remove parameters and return
EXECWITHSWAP   ENDP
;-----------------------------------------------------------------------------
;Label marks first location to swap
_FIRSTTOSAVE:
;-----------------------------------------------------------------------------
;function AllocateSwapFile : Boolean;
ALLOCATESWAPFILE PROC FAR
        MOV     CX,FileAttr             ;Attribute for swap file
		MOV     DX,OFFSET _SwapName     ;DS:DX -> ASCIIZ swap name
        DosCallAH 3Ch                   ;Create file
        MOV     _FileHandle,AX           ;Save handle assuming success
        MOV     AL,0                    ;Assume failure
        JC      ASDone                  ;Failed if carry set
        INC     AL                      ;Return true for success
ASDone: RET
ALLOCATESWAPFILE ENDP

;-----------------------------------------------------------------------------
;procedure DeallocateSwapFile;
DEALLOCATESWAPFILE PROC FAR
        MOV     BX,_FileHandle           ;Handle of swap file
        DosCallAH 3Eh                   ;Close file
        XOR     CX,CX                   ;Normal attribute
		MOV     DX,OFFSET _SwapName     ;DS:DX -> ASCIIZ swap name
        DosCallAX 4301h                 ;Set file attribute
        DosCallAH 41h                   ;Delete file
        RET
DEALLOCATESWAPFILE ENDP

;-----------------------------------------------------------------------------
;function EmsInstalled : Boolean;
EMSINSTALLED    PROC FAR

        PUSH    DS
        MovSeg  DS,CS                   ;DS = CS
        MOV     DX,OFFSET EmsDevice     ;DS:DX -> EMS driver name
        DosCallAX 3D02h                 ;Open for read/write
        POP     DS
        MOV     BX,AX                   ;Save handle in case one returned
        MOV     AL,0                    ;Assume FALSE
        JC      EIDone
	DosCallAH 3Eh                   ;Close file
	MOV     AL,1                    ;Return TRUE

EIDone: RET

EMSINSTALLED    ENDP

;-----------------------------------------------------------------------------
;function EmsPageFrame : Word;
EMSPAGEFRAME    PROC FAR

        EmsCall 41h                     ;Get page frame
        MOV     AX,BX                   ;AX = segment
        JZ      EPDone                  ;Done if Error = 0
	XOR     AX,AX                   ;Else segment = 0

EPDone: RET

EMSPAGEFRAME    ENDP

;-----------------------------------------------------------------------------
;function AllocateEmsPages(NumPages : Word) : Word;
ALLOCATEEMSPAGES PROC FAR

        MOV     BX,SP                   ;Set up stack frame
        MOV     BX,SS:[BX+4]            ;BX = NumPages
        EmsCall 43h                     ;Allocate EMS
        MOV     AX,DX                   ;Assume success
        JZ      APDone                  ;Done if not 0
	MOV     AX,0FFFFh               ;$FFFF for failure

APDone:	RET     2                       ;Remove parameter and return

ALLOCATEEMSPAGES ENDP

;-----------------------------------------------------------------------------
;procedure DeallocateEmsHandle(Handle : Word);
DEALLOCATEEMSHANDLE PROC FAR

        MOV     BX,SP                   ;Set up stack frame
        MOV     DX,SS:[BX+4]            ;DX = Handle
	EmsCall 45h                     ;Deallocate EMS

	RET     2                       ;Remove parameter and return

DEALLOCATEEMSHANDLE ENDP

;CODE    ENDS
        END
